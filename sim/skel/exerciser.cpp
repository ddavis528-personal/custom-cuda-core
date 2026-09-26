//===-- exerciser.cpp ---------------------------------------------------===//
#include "exerciser.h"

#include "ccv_event_ids.h"
#include "ccv/event.h"

#include <algorithm>
#include <cstdio>
#include <map>
#include <tuple>

namespace ccv {
namespace skel {

namespace {

uint64_t splitmix(uint64_t x) {
  x += 0x9e3779b97f4a7c15ull;
  x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9ull;
  x = (x ^ (x >> 27)) * 0x94d049bb133111ebull;
  return x ^ (x >> 31);
}

double toUnit(uint64_t h) { return double(h >> 11) * (1.0 / 9007199254740992.0); }

class Rng {
public:
  explicit Rng(uint64_t s) : s_(splitmix(s)) {}
  double uniform() { return toUnit(next()); }
  uint64_t next() { return s_ = splitmix(s_); }
private:
  uint64_t s_;
};

ExerciseTotals g_totals;
std::vector<Launched> g_launched;
bool g_draining = false;
bool g_class_bad[kNumChans] = {};
bool g_mismatch_chan[kNumChans] = {};

constexpr uint64_t kStreamGroup = 0x1000, kStreamKey = 0x2000;
constexpr uint64_t kPatience = 8;   // cycles an eligible head may be passed over
constexpr unsigned kKeyValues = 4;   // up to four warps, as on dec->ooe

/// Key values a field-keyed channel's sender draws from: few enough that
/// messages sharing a key are common, which is when ordering matters.
unsigned keyValues(const ChanDesc &cd) {
  const unsigned w = cd.fields[cd.order_field].width;
  return w >= 2 ? kKeyValues : (1u << w);
}

uint64_t fieldOf(const ChanDesc &cd, const Bits &b) {
  const FieldDesc &f = cd.fields[cd.order_field];
  return b.get(f.lsb, f.width < 64 ? f.width : 64);
}

struct OutGroup {
  const ChanInst *ci;
  std::vector<Sender *> tx;
  std::map<uint64_t, uint64_t> seq;   ///< per stream
};
struct InGroup {
  const ChanInst *ci;
  std::vector<Receiver *> rx;
  std::map<uint64_t, uint64_t> seq;
  std::vector<unsigned> stall_left;
};

class Exerciser : public Block {
public:
  Exerciser(int inst, const ExerciseCfg &cfg)
      : Block(inst), cfg_(cfg),
        rng_(cfg.seed * 1000003ull + uint64_t(inst + 1)) {}

  void cycle(uint64_t now) override {
    if (!built_) build();
    for (auto &kv : in_) receive(kv.first, kv.second, now);
    for (auto &kv : out_) send(kv.first, kv.second, now);
  }

private:
  // -- the decision a unit makes -------------------------------------------
  // Private to this block, unless the unit spans blocks (lockstep), in which
  // case every block computes the same value from (channel, unit, cycle).
  double decide(bool shared, unsigned chan, unsigned unit, uint64_t now,
                uint64_t salt) {
    if (!shared) return rng_.uniform();
    return toUnit(splitmix(cfg_.seed ^ (uint64_t(chan) << 48) ^
                           (uint64_t(unit) << 40) ^ (now << 4) ^ salt));
  }

  bool atomic(const ChanDesc &cd) const {
    return cd.rate > 1 && (cd.atomic || cfg_.force_atomic);
  }

  void build() {
    for (const Out &o : outs) {
      auto &v = out_[o.ci->chan];
      if (v.empty() || v.back().ci != o.ci) v.push_back({o.ci, {}, {}});
      v.back().tx.push_back(o.tx);
    }
    for (const In &i : ins) {
      auto &v = in_[i.ci->chan];
      if (v.empty() || v.back().ci != i.ci) v.push_back({i.ci, {}, {}, {}});
      v.back().rx.push_back(i.rx);
      v.back().stall_left.push_back(0);
    }
    built_ = true;
  }

  /// Decision units: sets of (group, slot) that move together this cycle.
  template <typename G>
  std::vector<std::vector<std::pair<G *, unsigned>>>
  units(std::vector<G> &gs, const ChanDesc &cd) {
    std::vector<std::vector<std::pair<G *, unsigned>>> u;
    const unsigned n = cd.rate;
    if (atomic(cd) && cd.lockstep) {
      u.emplace_back();
      for (G &g : gs) for (unsigned s = 0; s != n; ++s) u.back().push_back({&g, s});
    } else if (atomic(cd)) {
      for (G &g : gs) {
        u.emplace_back();
        for (unsigned s = 0; s != n; ++s) u.back().push_back({&g, s});
      }
    } else if (cd.lockstep) {
      for (unsigned s = 0; s != n; ++s) {
        u.emplace_back();
        for (G &g : gs) u.back().push_back({&g, s});
      }
    } else {
      for (G &g : gs)
        for (unsigned s = 0; s != n; ++s) u.push_back({{&g, s}});
    }
    return u;
  }

  // -- receiving ------------------------------------------------------------
  void verify(InGroup &g, unsigned s, const Receiver::Msg &m) {
    const ChanDesc &cd = kChans[g.ci->chan];
    const uint64_t kv = cd.order == Order::kField ? fieldOf(cd, m.payload) : 0;
    const uint64_t st = streamOf(cd, s, kv);
    const uint64_t q = g.seq[st]++;
    if (m.payload != expectedPayload(*g.ci, st, q, kv)) {
      // The first on each CHANNEL, not the first five in all: the misorder
      // control is judged by which channels report, and a cap across all of
      // them let one busy channel hide another (found on a repeated link).
      if (!g_mismatch_chan[g.ci->chan]) {
        g_mismatch_chan[g.ci->chan] = true;
        std::fprintf(stderr, "MISMATCH %s[%u] slot %u stream %llx message %llu\n",
                     cd.name, g.ci->inst, s, (unsigned long long)st,
                     (unsigned long long)q);
      }
      ++g_totals.mismatches;
    }
    if (m.tid != expectedTid(*g.ci, st, q))
      ++g_totals.tid_mismatches;
    if (!((cd.id_classes >> unsigned(uidClass(m.tid))) & 1u)) {
      if (g_totals.class_violations < 5)
        std::fprintf(stderr, "CLASS %s carries id class %u, not in its set\n",
                     cd.name, unsigned(uidClass(m.tid)));
      ++g_totals.class_violations;
      g_class_bad[g.ci->chan] = true;
    }
    ++g_totals.received;
  }

  /// A head is ELIGIBLE if no buffered message on this channel instance is
  /// older by (arrival, slot) and shares its stream -- its binding group or
  /// its key value. Different streams may pass each other; one never passes
  /// itself.
  bool eligible(InGroup &g, const ChanDesc &cd, unsigned s) {
    const Receiver::Msg &h = g.rx[s]->front();
    const uint64_t kv = cd.order == Order::kField ? fieldOf(cd, h.payload) : 0;
    const uint64_t st = streamOf(cd, s, kv);
    for (unsigned t = 0; t != g.rx.size(); ++t)
      for (size_t i = 0; i != g.rx[t]->size(); ++i) {
        const Receiver::Msg &m = g.rx[t]->at(i);
        const uint64_t mkv = cd.order == Order::kField ? fieldOf(cd, m.payload) : 0;
        if (streamOf(cd, t, mkv) != st) continue;
        if (m.arrived < h.arrived || (m.arrived == h.arrived && t < s))
          return false;
      }
    return true;
  }

  void receive(unsigned chan, std::vector<InGroup> &gs, uint64_t now) {
    const ChanDesc &cd = kChans[chan];
    for (InGroup &g : gs) for (Receiver *r : g.rx) r->cycle(now);
    // This block holds every instance of a lockstep channel: it is the
    // single receiver, and must stall them together too.
    const bool sole = cd.lockstep && gs.size() == cd.ninst;

    if (cd.order != Order::kNone && !atomic(cd)) {
      // Keyed consumption: up to `rate` heads a cycle, each one ELIGIBLE,
      // chosen AT RANDOM among the eligible. Not the first in slot order:
      // that is a fixed priority, and the first version of this loop starved
      // fet->dec's higher binding groups until response_within_n fired 175
      // times -- the bounded-response check doing exactly its job, on the
      // stub. Not the oldest either, which is plain FIFO and would never let
      // one stream pass another. `misorder` takes an ineligible head.
      for (InGroup &g : gs) {
        // One head per SLOT per cycle: a slot returns one credit a cycle,
        // so a second pop there would lose one (Receiver::pop).
        bool taken[64] = {};
        for (unsigned step = 0; step != cd.rate; ++step) {
          unsigned ok[64], nok = 0;
          int bad = -1;
          for (unsigned s = 0; s != cd.rate; ++s) {
            if (g.rx[s]->empty() || taken[s]) continue;
            if (eligible(g, cd, s)) ok[nok++] = s;
            else if (bad < 0) bad = int(s);
          }
          int pick = nok ? int(ok[rng_.next() % nok]) : -1;
          // ...but patience runs out: an eligible head that has waited
          // kPatience cycles goes first, oldest first. A random pick alone
          // has no bound on how long one message can keep losing the draw,
          // and the first repeated links -- credit depth 2 + 2N, so deeper
          // queues -- found it: response_within_n on every cycle.
          for (unsigned x = 0; x != nok; ++x) {
            const uint64_t a = g.rx[ok[x]]->front().arrived;
            if (now - a >= kPatience &&
                (pick < 0 || a < g.rx[pick]->front().arrived ||
                 now - g.rx[pick]->front().arrived < kPatience))
              pick = int(ok[x]);
          }
          if (cfg_.misorder && bad >= 0) pick = bad;
          if (pick < 0) break;
          // One coin per step, not stop-at-the-first-failure: that drained
          // ~1.5 messages a cycle against the unordered receiver's 0.6 x
          // rate, and the tail of 16 in-flight messages crossed N.
          if (rng_.uniform() >= cfg_.p_pop) continue;
          verify(g, unsigned(pick), g.rx[pick]->front());
          g.rx[pick]->pop();
          taken[pick] = true;
        }
      }
    } else {
      unsigned uid = 0;
      for (auto &u : units(gs, cd)) {
        bool all = true;
        for (auto &m : u) all = all && !m.first->rx[m.second]->empty();
        if (all && decide(cd.lockstep, chan, uid, now, 0x9) < cfg_.p_pop)
          for (auto &m : u) {
            verify(*m.first, m.second, m.first->rx[m.second]->front());
            m.first->rx[m.second]->pop();
          }
        ++uid;
      }
    }

    for (InGroup &g : gs)
      for (unsigned s = 0; s != cd.rate; ++s) {
        bool st;
        if (sole) {
          // Shared per slot, memoryless: every instance's slot s together.
          st = decide(true, chan, s, now, 0x5) < cfg_.p_stall;
        } else {
          // Private, with a duration. On a lockstep channel whose receivers
          // are the many instances (the lanes), this is what makes the single
          // sender hold EVERY lane for one lane's stall.
          if (g.stall_left[s] == 0 && rng_.uniform() < cfg_.p_stall)
            g.stall_left[s] = 1 + unsigned(rng_.next() % 3);
          st = g.stall_left[s] != 0;
          if (st) --g.stall_left[s];
        }
        if (st) g.rx[s]->stall(true);
      }
  }

  // -- sending --------------------------------------------------------------
  void launch(OutGroup &g, unsigned s) {
    const ChanDesc &cd = kChans[g.ci->chan];
    const uint64_t kv = cd.order == Order::kField
                            ? rng_.next() % keyValues(cd) : 0;
    const uint64_t st = streamOf(cd, s, kv);
    const uint64_t q = g.seq[st]++;
    Bits msg = expectedPayload(*g.ci, st, q, kv);
    if (cfg_.misgroup && cd.bind_key >= 0) {
      // Every message names the NEXT group: a slot carrying another
      // stream's traffic, which binding exists to rule out.
      const FieldDesc &fd = cd.fields[cd.bind_key];
      msg.set(fd.lsb, fd.width, msg.get(fd.lsb, fd.width) + 1);
    }
    uint64_t tid = expectedTid(*g.ci, st, q);
    if (cfg_.misbind && cd.lockstep && g.ci->inst == 7)
      // Lane 7 carries slot s+1's instruction in slot s -- the SIMD
      // violation binding exists to rule out.
      tid = expectedTid(*g.ci, streamOf(cd, (s + 1) % cd.rate, kv), q);
    if (cfg_.wrong_class)
      for (unsigned k = 0; k != 3; ++k)
        if (!((cd.id_classes >> k) & 1u)) {
          tid = makeUid(IdClass(k), uidSeq(tid));
          break;
        }
    g.tx[s]->cycle(true, msg, tid);
    logLaunch(g.ci->chan, msg, tid);
    ++g_totals.sent;
  }

  void send(unsigned chan, std::vector<OutGroup> &gs, uint64_t now) {
    const ChanDesc &cd = kChans[chan];
    unsigned uid = 0;
    // Units are built slot-ascending within an instance, so an ordered
    // stream's sequence follows (cycle, slot) by construction.
    for (auto &u : units(gs, cd)) {
      bool all = true;
      for (auto &m : u) all = all && m.first->tx[m.second]->canSend();
      const bool go = all && !g_draining &&
                      decide(cd.lockstep, chan, uid, now, 0x3) < cfg_.p_send;
      for (auto &m : u) {
        if (go) launch(*m.first, m.second);
        else m.first->tx[m.second]->cycle(false, Bits());
      }
      ++uid;
    }
  }

  ExerciseCfg cfg_;
  Rng rng_;
  bool built_ = false;
  std::map<unsigned, std::vector<OutGroup>> out_;
  std::map<unsigned, std::vector<InGroup>> in_;
};

uint64_t messageKey(const ChanInst &ci, bool with_inst, uint64_t stream,
                    uint64_t seq) {
  return splitmix((uint64_t(ci.chan) << 48) ^
                  (with_inst ? uint64_t(ci.inst) << 40 : 0) ^
                  (stream << 24) ^ seq);
}

} // namespace

uint64_t streamOf(const ChanDesc &cd, unsigned slot, uint64_t keyval) {
  if (cd.rate < 2) return 0;
  switch (cd.order) {
  case Order::kSlotGroup: return kStreamGroup + slot / cd.bind_group;
  case Order::kField:     return kStreamKey + keyval;
  case Order::kNone:      break;
  }
  return slot;
}

Bits expectedPayload(const ChanInst &ci, uint64_t stream, uint64_t seq,
                     uint64_t keyval) {
  const ChanDesc &cd = kChans[ci.chan];
  Bits b(cd.bits);
  // Payload is per instance even on a lockstep channel: each lane has its
  // own operands. Only the IDENTITY is shared across lanes.
  const uint64_t k = messageKey(ci, true, stream, seq);
  for (unsigned f = 0; f != cd.nfields; ++f) {
    const FieldDesc &fd = cd.fields[f];
    for (uint32_t off = 0; off < fd.width; off += 64) {
      const uint32_t w = fd.width - off < 64 ? fd.width - off : 64;
      b.set(fd.lsb + off, w, splitmix(k ^ (uint64_t(f) << 20) ^ off));
    }
  }
  if (cd.order == Order::kField) {
    const FieldDesc &fd = cd.fields[cd.order_field];
    b.set(fd.lsb, fd.width < 64 ? fd.width : 64, keyval);
  }
  if (cd.bind_key >= 0) {
    // The binding key names the message's group. Only a slot_group-ordered
    // channel has one today, and there the stream IS the group.
    if (cd.order != Order::kSlotGroup) {
      std::fprintf(stderr, "%s: a binding key on a channel not ordered by "
                   "slot group -- the exerciser does not know its group\n", cd.name);
      std::abort();
    }
    const FieldDesc &fd = cd.fields[cd.bind_key];
    b.set(fd.lsb, fd.width, stream - kStreamGroup);
  }
  return b;
}

uint64_t expectedTid(const ChanInst &ci, uint64_t stream, uint64_t seq) {
  const ChanDesc &cd = kChans[ci.chan];
  // On a lockstep channel slot k carries the same instruction on every
  // instance, so the id does not depend on which instance it is.
  const uint64_t h = splitmix(messageKey(ci, !cd.lockstep, stream, seq) ^ 0x7157ull);
  unsigned allowed[3], n = 0;
  for (unsigned c = 0; c != 3; ++c)
    if ((cd.id_classes >> c) & 1u) allowed[n++] = c;
  const IdClass cls = IdClass(allowed[h % n]);
  switch (cls) {
  case IdClass::kInstr: return makeUid(cls, uint32_t(h >> 8));
  case IdClass::kTxn:
    return makeUid(cls, uint32_t(h >> 8), uint16_t(h >> 40), (h >> 60) & 1u);
  case IdClass::kNone: break;
  }
  return makeUid(IdClass::kNone, 0);
}

std::unique_ptr<Block> makeExerciser(int inst, const ExerciseCfg &cfg) {
  return std::make_unique<Exerciser>(inst, cfg);
}

ExerciseTotals exerciseTotals() {
  ExerciseTotals t = g_totals;
  for (bool b : g_class_bad) t.class_violation_channels += b;
  return t;
}
void setDraining(bool on) { g_draining = on; }
const std::vector<Launched> &launchedLog() { return g_launched; }
void logLaunch(uint16_t chan, const Bits &msg, uint64_t tid) {
  const uint32_t nb = msg.size();
  g_launched.push_back(
      {chan, uint32_t(msg.get(0, nb < 32 ? nb : 32)),
       uint32_t(nb <= 32 ? 0 : msg.get(32, nb < 64 ? nb - 32 : 32)), tid});
}

/// That is what proves the bank's PAYLOAD and trace-sideband wiring -- the
/// negative controls only reach valid, credit and stall, because Verilator is
/// two-state and payload_known_when_due cannot fire.
int xferCheck(const std::string &trace) {
  std::vector<std::tuple<uint16_t, uint32_t, uint32_t, uint64_t>> ev, want;
  ccv::EventReader r;
  if (!r.open(trace)) {
    std::fprintf(stderr, "cannot reread trace: %s\n", r.error().c_str());
    return 1;
  }
  ccv::Event e;
  while (r.next(e))
    if (e.event_id == ccv::EV_CH_XFER)
      ev.push_back({uint16_t(e.a), e.b, e.c, e.instr_uid});
  for (const Launched &l : launchedLog())
    want.push_back({l.chan, l.lo32, l.hi32, l.tid});
  std::sort(ev.begin(), ev.end());
  std::sort(want.begin(), want.end());
  std::vector<uint16_t> seen;
  for (auto &p : ev) seen.push_back(std::get<0>(p));
  seen.erase(std::unique(seen.begin(), seen.end()), seen.end());
  std::printf("XFER events=%zu launched=%zu match=%s channels_seen=%zu\n",
              ev.size(), want.size(), ev == want ? "yes" : "no", seen.size());
  return 0;
}

} // namespace skel
} // namespace ccv
