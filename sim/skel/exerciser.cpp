//===-- exerciser.cpp ---------------------------------------------------===//
#include "exerciser.h"

#include "ccv_event_ids.h"

#include <cstdio>

namespace ccv {
namespace skel {

namespace {

uint64_t splitmix(uint64_t x) {
  x += 0x9e3779b97f4a7c15ull;
  x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9ull;
  x = (x ^ (x >> 27)) * 0x94d049bb133111ebull;
  return x ^ (x >> 31);
}

class Rng {
public:
  explicit Rng(uint64_t s) : s_(splitmix(s)) {}
  double uniform() { return double(next() >> 11) * (1.0 / 9007199254740992.0); }
  uint64_t next() { return s_ = splitmix(s_); }
private:
  uint64_t s_;
};

ExerciseTotals g_totals;
std::vector<Launched> g_launched;
bool g_draining = false;
bool g_class_bad[kNumChans] = {};

uint64_t messageKey(const ChanInst &ci, unsigned slot, uint64_t key) {
  return splitmix((uint64_t(ci.chan) << 48) ^ (uint64_t(ci.inst) << 40) ^
                  (uint64_t(slot) << 32) ^ key);
}

/// One channel instance, as seen from one end.
struct OutGroup {
  const ChanInst *ci;
  std::vector<Sender *> tx;
  std::vector<uint64_t> slot_seq;   ///< per slot
  uint64_t chan_seq = 0;            ///< ordered channels
};
struct InGroup {
  const ChanInst *ci;
  std::vector<Receiver *> rx;
  std::vector<uint64_t> slot_seq;
  uint64_t chan_seq = 0;
  std::vector<unsigned> stall_left;
};

class Exerciser : public Block {
public:
  Exerciser(int inst, const ExerciseCfg &cfg)
      : Block(inst), cfg_(cfg),
        rng_(cfg.seed * 1000003ull + uint64_t(inst + 1)) {}

  void cycle(uint64_t now) override {
    if (!built_) build();
    for (InGroup &g : in_) receive(g, now);
    for (OutGroup &g : out_) send(g);
  }

private:
  bool atomic(const ChanInst &ci) const {
    const ChanDesc &cd = kChans[ci.chan];
    return cd.rate > 1 && (cd.atomic || cfg_.force_atomic);
  }
  bool ordered(const ChanInst &ci) const {
    const ChanDesc &cd = kChans[ci.chan];
    return cd.rate > 1 && cd.ordered;
  }

  // Ports arrive slot by slot, grouped by channel instance and in slot
  // order, because the machine wires them that way.
  void build() {
    for (const Out &o : outs) {
      if (out_.empty() || out_.back().ci != o.ci) out_.push_back({o.ci, {}, {}});
      out_.back().tx.push_back(o.tx);
      out_.back().slot_seq.push_back(0);
    }
    for (const In &i : ins) {
      if (in_.empty() || in_.back().ci != i.ci) in_.push_back({i.ci, {}, {}, 0, {}});
      in_.back().rx.push_back(i.rx);
      in_.back().slot_seq.push_back(0);
      in_.back().stall_left.push_back(0);
    }
    built_ = true;
  }

  void verify(InGroup &g, unsigned s, const Receiver::Msg &m, uint64_t key) {
    const ChanDesc &cd = kChans[g.ci->chan];
    if (m.payload != expectedPayload(*g.ci, s, key)) {
      if (g_totals.mismatches < 5)
        std::fprintf(stderr, "MISMATCH %s[%u] slot %u message %llu%s\n",
                     cd.name, g.ci->inst, s, (unsigned long long)key,
                     ordered(*g.ci) ? " (ordered: out of order?)" : "");
      ++g_totals.mismatches;
    }
    if (m.tid != expectedTid(*g.ci, s, key))
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

  void receive(InGroup &g, uint64_t now) {
    const unsigned n = unsigned(g.rx.size());
    for (Receiver *r : g.rx) r->cycle(now);

    if (atomic(*g.ci)) {
      // A whole group or nothing: every slot must hold a message.
      bool all = true;
      for (Receiver *r : g.rx) all = all && !r->empty();
      if (all && rng_.uniform() < cfg_.p_pop)
        for (unsigned s = 0; s != n; ++s) {
          const uint64_t key = ordered(*g.ci) ? g.chan_seq++ : g.slot_seq[s]++;
          verify(g, s, g.rx[s]->front(), key);
          g.rx[s]->pop();
        }
    } else if (ordered(*g.ci)) {
      // One sequence across the slots, consumed in (arrival, slot) order --
      // each step takes the oldest head. `misorder` takes the newest, which
      // must surface as payload mismatches.
      for (unsigned step = 0; step != n; ++step) {
        int pick = -1;
        for (unsigned s = 0; s != n; ++s) {
          if (g.rx[s]->empty()) continue;
          if (pick < 0) { pick = int(s); continue; }
          const uint64_t a = g.rx[s]->front().arrived;
          const uint64_t b = g.rx[pick]->front().arrived;
          if (cfg_.misorder ? (a >= b) : (a < b)) pick = int(s);
        }
        if (pick < 0 || rng_.uniform() >= cfg_.p_pop) break;
        verify(g, unsigned(pick), g.rx[pick]->front(), g.chan_seq++);
        g.rx[pick]->pop();
      }
    } else {
      for (unsigned s = 0; s != n; ++s)
        if (!g.rx[s]->empty() && rng_.uniform() < cfg_.p_pop) {
          verify(g, s, g.rx[s]->front(), g.slot_seq[s]++);
          g.rx[s]->pop();
        }
    }

    for (unsigned s = 0; s != n; ++s) {
      if (g.stall_left[s] == 0 && rng_.uniform() < cfg_.p_stall)
        g.stall_left[s] = 1 + unsigned(rng_.next() % 3);
      if (g.stall_left[s] != 0) {
        g.rx[s]->stall(true);
        --g.stall_left[s];
      }
    }
  }

  void launch(OutGroup &g, unsigned s, uint64_t key) {
    const Bits msg = expectedPayload(*g.ci, s, key);
    uint64_t tid = expectedTid(*g.ci, s, key);
    if (cfg_.wrong_class) {
      // Stamp the first class this channel may NOT carry. Every channel
      // excludes at least one, so every channel must report.
      const ChanDesc &cd = kChans[g.ci->chan];
      for (unsigned k = 0; k != 3; ++k)
        if (!((cd.id_classes >> k) & 1u)) {
          tid = makeUid(IdClass(k), uidSeq(tid));
          break;
        }
    }
    g.tx[s]->cycle(true, msg, tid);
    const uint32_t nb = msg.size();
    g_launched.push_back(
        {g.ci->chan, uint32_t(msg.get(0, nb < 32 ? nb : 32)),
         uint32_t(nb <= 32 ? 0 : msg.get(32, nb < 64 ? nb - 32 : 32)), tid});
    ++g_totals.sent;
  }

  void send(OutGroup &g) {
    const unsigned n = unsigned(g.tx.size());
    if (atomic(*g.ci)) {
      bool all = true;
      for (Sender *t : g.tx) all = all && t->canSend();
      const bool go = all && !g_draining && rng_.uniform() < cfg_.p_send;
      for (unsigned s = 0; s != n; ++s) {
        if (go) launch(g, s, ordered(*g.ci) ? g.chan_seq++ : g.slot_seq[s]++);
        else g.tx[s]->cycle(false, Bits());
      }
      return;
    }
    // Slots in index order, so an ordered channel's sequence follows
    // (cycle, slot) by construction.
    for (unsigned s = 0; s != n; ++s) {
      const bool want = !g_draining && rng_.uniform() < cfg_.p_send;
      if (want && g.tx[s]->canSend())
        launch(g, s, ordered(*g.ci) ? g.chan_seq++ : g.slot_seq[s]++);
      else
        g.tx[s]->cycle(false, Bits());
    }
  }

  ExerciseCfg cfg_;
  Rng rng_;
  bool built_ = false;
  std::vector<OutGroup> out_;
  std::vector<InGroup> in_;
};

} // namespace

Bits expectedPayload(const ChanInst &ci, unsigned slot, uint64_t key) {
  const ChanDesc &cd = kChans[ci.chan];
  Bits b(cd.bits);
  // An ordered channel's key is the channel sequence, which already names
  // the message uniquely; the slot it happened to ride on is not part of it.
  const uint64_t k = messageKey(ci, cd.ordered && cd.rate > 1 ? 0 : slot, key);
  for (unsigned f = 0; f != cd.nfields; ++f) {
    const FieldDesc &fd = cd.fields[f];
    for (uint32_t off = 0; off < fd.width; off += 64) {
      const uint32_t w = fd.width - off < 64 ? fd.width - off : 64;
      b.set(fd.lsb + off, w, splitmix(k ^ (uint64_t(f) << 20) ^ off));
    }
  }
  return b;
}

uint64_t expectedTid(const ChanInst &ci, unsigned slot, uint64_t key) {
  const ChanDesc &cd = kChans[ci.chan];
  const uint64_t h = splitmix(
      messageKey(ci, cd.ordered && cd.rate > 1 ? 0 : slot, key) ^ 0x7157ull);
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

} // namespace skel
} // namespace ccv
