//===-- kernel.cpp - S1 functional stubs ---------------------------------===//
//
// One stub per block type. Each reads only its own receivers and writes only
// its own senders, pops every message the cycle it lands (so the bank's
// bounded-response check measures the stub, not a backlog), and checks what
// arrived against the oracle record wherever the record says what it should
// be. Nothing here uses a message's trace identity to decide what to DO --
// only to find the record a check compares against. The two exceptions are
// named where they happen: fetch order and decode (strategy §1's "what"), and
// a lane's ALU result.
//===----------------------------------------------------------------------===//
#include "stub.h"

#include <algorithm>
#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <deque>
#include <fstream>
#include <list>
#include <set>
#include <tuple>
#include <unordered_map>

namespace ccv {
namespace skel {

void Kernel::fail(const char *fmt, ...) {
  // Every failure prints, up to a bound against a runaway: the controls in
  // tools/check-kernel.sh grep for one instruction's line, and with an
  // out-of-order OOE (sim/ooe/) which instruction fails first is a matter
  // of issue order, not of which check fired.
  if (failures < 10000) {
    va_list ap;
    va_start(ap, fmt);
    std::fprintf(stderr, "CHECK ");
    std::vfprintf(stderr, fmt, ap);
    std::fputc('\n', stderr);
    va_end(ap);
  }
  ++failures;
}

bool Kernel::lastUop(uint64_t tid) const {
  const Record *r = bySeq(uidSeq(tid));
  return !r || uidSub(tid) + 1u >= r->uops();
}

void Kernel::failHeld(const std::string &where, uint64_t tid, const char *fmt, ...) {
  char buf[512];
  va_list ap;
  va_start(ap, fmt);
  std::vsnprintf(buf, sizeof buf, fmt, ap);
  va_end(ap);
  held[{where, tid}].push_back(buf);
}

void Kernel::executing(const std::string &where, uint64_t tid) {
  if (!executed.insert({where, tid}).second) {
    held.erase({where, tid});      // a replay: the earlier execution is moot
    if (reexecuted.insert(tid).second) hit("reexec");
  }
}

void Kernel::flushHeld() {
  // A check held for a replay that a demotion's squash made moot: the
  // instruction is past its warp's retirement boundary, so it re-executes
  // from the resume PC after a restore, not here (TI-24). Dropped, and only
  // for a parked warp past the instructions it retired.
  std::map<unsigned, uint32_t> nret;
  for (uint64_t s : retire_order) ++nret[seqWarp(uint32_t(s))];
  for (const auto &h : held) {
    const uint32_t seq = uidSeq(h.first.second);
    if (parkedNow(seqWarp(seq)) && seqIndex(seq) >= nret[seqWarp(seq)]) continue;
    for (const std::string &m : h.second) fail("%s", m.c_str());
  }
  held.clear();
}

void Kernel::snapshotFinal(unsigned w) {
  Final &f = finals[w];
  const std::vector<unsigned> &r = ratOf(w);
  for (unsigned a = 0; a != kArchGprs; ++a) f.gpr[a] = gpr[r[a]];
  std::vector<unsigned> pmap = w < prat.size() ? prat[w] : std::vector<unsigned>();
  if (pmap.empty())
    for (unsigned p = 0; p != kArchPreds; ++p) pmap.push_back(physPred(w, p));
  if (brk == "swap-prat0" && w == 0) std::swap(pmap[0], pmap[1]);   // the control, here too
  for (unsigned p = 0; p != kArchPreds; ++p) f.pred[p] = pred[pmap[p]];
}

void Kernel::checkParked(unsigned w) {
  if (w >= orcs.size()) return;
  const Parked &pk = parked[w];
  const Oracle &o = orcs[w];
  uint32_t n = 0;
  for (uint64_t s : retire_order) n += seqWarp(uint32_t(s)) == w;
  std::array<std::array<uint32_t, kLanes>, kArchGprs> want{};
  std::array<uint32_t, kArchPreds> pwant{};
  for (uint32_t i = 0; i != n && i < o.recs.size(); ++i)
    for (const RegVal &d : o.recs[i].defs) {
      if (d.pred) pwant[d.idx & 3] = d.p;
      else if (d.idx < kArchGprs) want[d.idx] = d.v;
    }
  const uint64_t pc = n < o.recs.size() ? o.recs[n].pc : 0;
  if (pk.resume_pc != pc)
    fail("parked warp %u resumes at %llx; ccv-sim's next after %u retired is %llx", w,
         (unsigned long long)pk.resume_pc, n, (unsigned long long)pc);
  unsigned bad = 0;
  for (unsigned a = 0; a != kArchGprs; ++a) {
    auto row = pk.rows.find(a);   // one row per register, Ra as row a (TI-25 (1))
    for (unsigned l = 0; l != kLanes; ++l) {
      const uint32_t got = row == pk.rows.end() ? 0xbad0bad0u : row->second[l];
      if (got != want[a][l] && bad++ < 4)
        fail("parked warp %u R%u lane %u: PCA %08x, ccv-sim %08x", w, a, l, got, want[a][l]);
    }
  }
  auto prow = pk.rows.find(kArchGprs);
  for (unsigned p = 0; p != kArchPreds; ++p) {
    const uint32_t got = prow == pk.rows.end() ? 0xbad0bad0u : prow->second[p];
    if (got != pwant[p]) fail("parked warp %u P%u: PCA %08x, ccv-sim %08x", w, p, got, pwant[p]);
  }
  // Each lane's PC: the next instruction ccv-sim ran for it, held once
  // OOE's rewind beats have set them all (TI-24 (3)).
  if (pk.rewound)
    for (unsigned l = 0; l != kLanes; ++l) {
      uint64_t want_pc = o.recs.empty() ? 0 : o.recs.back().pc;
      for (size_t i = n; i < o.recs.size(); ++i)
        if (o.recs[i].mask >> l & 1u) { want_pc = o.recs[i].pc; break; }
      if (pk.lane_pc[l] != want_pc && bad++ < 8)
        fail("parked warp %u lane %u resumes at %llx; ccv-sim %llx", w, l,
             (unsigned long long)pk.lane_pc[l], (unsigned long long)want_pc);
    }
}

namespace {

// The testbench link: the flattened TL-C bundle CCV_L_W_TL_OUT / _IN were
// sized from -- A + C + E out, B + D in, each channel's fields at the stated
// parameters (512-bit beat, 48-bit address, 6-bit source, 4-bit sink), then a
// valid bit per TL channel at the top. A 128-byte line is therefore a
// TWO-BEAT burst, and EXB is where the sequencer lives. Flattened versus
// decomposed is still the EXB session's decision (tilelink_tlc).
enum : unsigned { kTlPutFull = 0, kTlGet = 4, kTlAck = 0, kTlAckData = 1 };
constexpr uint32_t kBeat = 64;                    // bytes per beat
constexpr uint32_t kBeats = kLine / kBeat;        // beats per line
constexpr uint32_t kTlSizeLine = 7;               // log2(128)
// A channel, at the bottom of tl_out
constexpr uint32_t kAOp = 0, kAParam = 3, kASize = 6, kASrc = 10, kAAddr = 16,
                   kAMask = 64, kAData = 128;
constexpr uint32_t kAValid = 1222;                // a_valid, c_valid, e_valid
// D channel, above B in tl_in
constexpr uint32_t kDOp = 641, kDSize = 646, kDSrc = 650, kDData = 661;
constexpr uint32_t kDValid = 1175;                // b_valid 1174, d_valid 1175
constexpr uint32_t kTlSrcW = 6;

void putBeat(Bits &b, uint32_t lsb, const Line &l, unsigned beat) {
  for (unsigned k = 0; k != kBeat; ++k) b.set(lsb + 8 * k, 8, l[beat * kBeat + k]);
}
void getBeat(const Bits &b, uint32_t lsb, Line &l, unsigned beat) {
  for (unsigned k = 0; k != kBeat; ++k)
    l[beat * kBeat + k] = uint8_t(b.get(lsb + 8 * k, 8));
}


// ---- testbench memory: the far end of EXTERNAL ---------------------------------

class Testbench : public Stub {
public:
  Testbench(int inst, Kernel &k) : Stub(inst, k) {
    // Every warp runs the same code from the same memory: warp 0's record of
    // them stands for all (Kernel::loadOracles holds the others to it).
    for (size_t i = 0; i != k.orcs[0].code.size(); ++i)
      k.mem[k.orcs[0].code_base + i] = k.orcs[0].code[i];
    for (auto &w : k.orcs[0].init_mem)
      for (unsigned b = 0; b != 4; ++b)
        k.mem[w.first + b] = uint8_t(w.second >> (8 * b));
  }
  const char *kind() const override { return "testbench"; }

private:
  static constexpr uint64_t kLatency = 10;   // placeholder DRAM
  /// A slow region, for a warp stalled on a miss as long as DRAM's: a line
  /// at kSlowBase or above answers kSlowLatency cycles after it is asked
  /// for (Daniel, 2026-10-21; the stall kernel). No other kernel reaches it.
  static constexpr uint64_t kSlowBase = 0x80000, kSlowLatency = 400;
  /// Two more regions within the slow one's range, for provswap: a line
  /// from kMidBase answers after kMidLatency cycles, and one from kDeepBase
  /// after kDeepLatency, so a warp that misses later than another can be
  /// ready first.
  static constexpr uint64_t kMidBase = 0xA0000, kMidLatency = 250;
  static constexpr uint64_t kDeepBase = 0xC0000, kDeepLatency = 1000;
  struct P { uint64_t due; Bits msg; uint64_t tid; bool first = true; };
  /// D beats, in the order they go: bursts by due cycle, each burst's beats
  /// together and one a cycle. Responses are matched by source, not order,
  /// so a fast line may pass a slow one; with one latency it is a FIFO.
  std::deque<P> q_;
  void enqueue(std::vector<P> burst) {
    auto at = q_.begin();
    if (at != q_.end() && !at->first)      // never split the burst going out
      while (at != q_.end() && !at->first) ++at;
    while (at != q_.end() && !(at->first && at->due > burst.front().due)) ++at;
    q_.insert(at, burst.begin(), burst.end());
  }
  struct Put { uint64_t addr; Line data{}; std::array<bool, kLine> mask{}; unsigned beats = 0; };
  std::map<unsigned, Put> puts_;             // bursts being received, by source

  Bits dBeat(unsigned op, unsigned src) {
    Bits r = msgOf(ch().ext_exb);
    r.set(kDOp, 3, op);
    r.set(kDSize, 4, kTlSizeLine);
    r.set(kDSrc, kTlSrcW, src);
    r.setBit(kDValid, true);
    return r;
  }

  void work() override {
    const Ch &c = ch();
    while (has(c.exb_ext, 0)) {
      Receiver::Msg m = take(c.exb_ext, 0);
      const Bits &a = m.payload;
      if (!a.bit(kAValid)) { k_.fail("testbench: a link message with no A beat"); continue; }
      const unsigned op = unsigned(a.get(kAOp, 3));
      const unsigned src = unsigned(a.get(kASrc, kTlSrcW));
      const uint64_t addr = a.get(kAAddr, 48);
      if (addr % kLine || a.get(kASize, 4) != kTlSizeLine)
        k_.fail("testbench: not a whole-line access at %llx", (unsigned long long)addr);
      if (op == kTlGet) {
        // AccessAckData: the line as a burst of beats, one a cycle.
        Line l{};
        for (unsigned k = 0; k != kLine; ++k) {
          auto it = k_.mem.find(addr + k);
          l[k] = it == k_.mem.end() ? 0 : it->second;
        }
        std::vector<P> burst;
        const uint64_t due = now_ + (addr >= kDeepBase  ? kDeepLatency
                          : addr >= kMidBase ? kMidLatency
                          : addr >= kSlowBase ? kSlowLatency
                                              : kLatency);
        for (unsigned beat = 0; beat != kBeats; ++beat) {
          Bits r = dBeat(kTlAckData, src);
          putBeat(r, kDData, l, beat);
          burst.push_back({due + beat, r, m.tid, beat == 0});
        }
        enqueue(std::move(burst));
      } else if (op == kTlPutFull) {
        // Collect the burst; write and acknowledge once it is whole.
        Put &p = puts_[src];
        if (p.beats == 0) p.addr = addr;
        getBeat(a, kAData, p.data, p.beats);
        for (unsigned k = 0; k != kBeat; ++k)
          p.mask[p.beats * kBeat + k] = a.bit(kAMask + k);
        if (++p.beats == kBeats) {
          for (unsigned k = 0; k != kLine; ++k)
            if (p.mask[k]) k_.mem[p.addr + k] = p.data[k];
          enqueue({{now_ + kLatency, dBeat(kTlAck, src), m.tid, true}});
          puts_.erase(src);
        }
      } else {
        k_.fail("testbench: unknown A opcode %u", op);
      }
    }
    if (!q_.empty() && q_.front().due <= now_ && can(c.ext_exb, 0)) {
      send(c.ext_exb, 0, q_.front().msg, q_.front().tid);
      q_.pop_front();
    }
  }
  bool busy() const override { return !q_.empty() || !puts_.empty(); }
};

// ---- EXB: the core's edge ----------------------------------------------------------

class Exb : public Stub {
public:
  using Stub::Stub;
  const char *kind() const override { return "exb"; }

private:
  std::deque<Q> out_, in_;
  bool corrupted_ = false;
  struct Gather { Line data{}; unsigned beats = 0; };
  std::map<unsigned, Gather> gather_;        // AccessAckData bursts, by source

  // The burst sequencer the flattened bundle stands in for: a line request
  // becomes one A beat (Get) or kBeats of them (PutFullData), and a line's
  // worth of D beats becomes one response to MLC.
  void work() override {
    const Ch &c = ch();
    if (has(c.mlc_exb, 0)) {
      Receiver::Msg m = take(c.mlc_exb, 0);
      const bool wr = get(m.payload, c.mlc_exb, "coh_op") == kCohWrite;
      const Line l = getLine(m.payload, field(c.mlc_exb, "writeback_data").lsb);
      for (unsigned beat = 0; beat != (wr ? kBeats : 1); ++beat) {
        Bits t = msgOf(c.exb_ext);
        t.set(kAOp, 3, wr ? kTlPutFull : kTlGet);
        t.set(kASize, 4, kTlSizeLine);
        t.set(kASrc, kTlSrcW, get(m.payload, c.mlc_exb, "req_id"));
        t.set(kAAddr, 48, get(m.payload, c.mlc_exb, "phys_addr"));
        t.setBit(kAValid, true);
        if (wr) {
          // mlc_exb_req has no byte mask: a write is always a whole line.
          for (unsigned k = 0; k != kBeat; ++k) t.setBit(kAMask + k, true);
          putBeat(t, kAData, l, beat);
        }
        out_.push_back({0, t, m.tid});
      }
    }
    if (has(c.ext_exb, 0)) {
      Receiver::Msg m = take(c.ext_exb, 0);
      const Bits &d = m.payload;
      const unsigned src = unsigned(d.get(kDSrc, kTlSrcW));
      bool whole = true;
      Line l{};
      if (!d.bit(kDValid)) {
        k_.fail("exb: an inbound message with no D beat (probes are not modelled)");
        whole = false;
      } else if (d.get(kDOp, 3) == kTlAckData) {
        Gather &g = gather_[src];
        getBeat(d, kDData, g.data, g.beats);
        whole = ++g.beats == kBeats;
        if (whole) { l = g.data; gather_.erase(src); }
      }
      if (whole && d.bit(kDValid)) {
        Bits r = msgOf(c.exb_mlc);
        putLine(r, field(c.exb_mlc, "line_data").lsb, l);
        put(r, c.exb_mlc, "req_id", src);
        put(r, c.exb_mlc, "probe_type", 0);          // a response, not a probe
        if (k_.brk == "corrupt-req-id" && !corrupted_) {
          put(r, c.exb_mlc, "req_id", get(r, c.exb_mlc, "req_id") ^ 1);
          corrupted_ = true;
        }
        put(r, c.exb_mlc, "miss", 1);
        in_.push_back({0, r, m.tid});
      }
    }
    if (!out_.empty() && can(c.exb_ext, 0)) {
      send(c.exb_ext, 0, out_.front().msg, out_.front().tid);
      out_.pop_front();
    }
    if (!in_.empty() && can(c.exb_mlc, 0)) {
      send(c.exb_mlc, 0, in_.front().msg, in_.front().tid);
      in_.pop_front();
    }
  }
  bool busy() const override {
    return !out_.empty() || !in_.empty() || !gather_.empty();
  }
};

// ---- MLC: no cache yet; forwards, and matches responses in order ------------------

class Mlc : public Stub {
public:
  Mlc(int inst, Kernel &k) : Stub(inst, k), ids_(ch().mlc_exb) {
    // CCV_MLC_WARM=1 (AR-24, AR's rev 182): a warm MLC, every line a hit.
    // It holds its own image of memory, loaded as the testbench's is, keeps
    // it with every write it passes on, and answers every read from it at
    // CCV_LAT_MLC_PIPE, never asking EXB. A timing knob, not the gate's.
    const char *w = std::getenv("CCV_MLC_WARM");
    warm_ = w && *w && *w != '0';
    if (warm_) {
      for (size_t i = 0; i != k.orcs[0].code.size(); ++i)
        img_[k.orcs[0].code_base + i] = k.orcs[0].code[i];
      for (auto &x : k.orcs[0].init_mem)
        for (unsigned b = 0; b != 4; ++b) img_[x.first + b] = uint8_t(x.second >> (8 * b));
    }
  }
  const char *kind() const override { return "mlc"; }

private:
  bool warm_ = false;
  std::unordered_map<uint64_t, uint8_t> img_;
  struct Due { uint64_t at; bool fet; Q q; };
  std::deque<Due> warm_q_;
  Line imgLine(uint64_t a) const {
    Line l{};
    for (unsigned b = 0; b != kLine; ++b) {
      auto it = img_.find(a + b);
      l[b] = it == img_.end() ? 0 : it->second;
    }
    return l;
  }
  enum Who { kDcu, kFet };
  /// What an EXB-side req_id stands for: who asked, and under which of
  /// THEIR ids -- each hop has its own id space.
  struct Owner { Who who; unsigned their_id; bool own = false; };
  struct R { Owner o; Bits msg; uint64_t tid; };
  std::deque<R> to_exb_;
  IdPool ids_;
  std::map<unsigned, Owner> owner_;   ///< by req_id toward EXB
  std::deque<Q> to_dcu_, to_fet_;

  void work() override {
    const Ch &c = ch();
    if (has(c.dcu_mlc, 0)) {
      Receiver::Msg m = take(c.dcu_mlc, 0);
      const unsigned coh = unsigned(get(m.payload, c.dcu_mlc, "coh_op"));
      if (coh == kCohAcquirePerm) {
        // Ownership without data (DCU spec rev 8): one core, nothing to
        // probe, so MLC grants it at once; memory sees the line on its
        // writeback.
        Bits r = msgOf(c.mlc_dcu);
        put(r, c.mlc_dcu, "req_id", get(m.payload, c.dcu_mlc, "req_id"));
        put(r, c.mlc_dcu, "ownership", k_.brk != "deny-ownership");
        to_dcu_.push_back({0, r, m.tid});
      } else if (warm_ && coh != kCohWrite) {
        // Warm: a hit, from MLC's own image, with ownership as on a fill.
        Bits r = msgOf(c.mlc_dcu);
        put(r, c.mlc_dcu, "req_id", get(m.payload, c.dcu_mlc, "req_id"));
        putLine(r, field(c.mlc_dcu, "line_data").lsb, imgLine(get(m.payload, c.dcu_mlc, "phys_addr")));
        put(r, c.mlc_dcu, "miss", 0);
        put(r, c.mlc_dcu, "ownership", coh == kCohAcquireData && k_.brk != "deny-ownership");
        warm_q_.push_back({now_ + ccv::prov::kLatMlcPipe, false, {0, r, m.tid}});
        k_.hit("mlc_warm_hit");
      } else {
      if (warm_) {
        // A write keeps the image current, and goes on to memory as ever.
        const uint64_t a = get(m.payload, c.dcu_mlc, "phys_addr");
        const Line l = getLine(m.payload, field(c.dcu_mlc, "writeback_data").lsb);
        for (unsigned b = 0; b != kLine; ++b) img_[a + b] = l[b];
      }
      Bits e = msgOf(c.mlc_exb);
      put(e, c.mlc_exb, "phys_addr", get(m.payload, c.dcu_mlc, "phys_addr"));
      put(e, c.mlc_exb, "size", kSizeLine);
      // AcquireData is a line read toward memory: ownership is MLC's to give.
      put(e, c.mlc_exb, "coh_op", coh == kCohAcquireData ? unsigned(kCohRead) : coh);
      put(e, c.mlc_exb, "core_id", get(m.payload, c.dcu_mlc, "core_id"));
      putLine(e, field(c.mlc_exb, "writeback_data").lsb,
              getLine(m.payload, field(c.dcu_mlc, "writeback_data").lsb));
      to_exb_.push_back({{kDcu, unsigned(get(m.payload, c.dcu_mlc, "req_id")),
                          coh == kCohAcquireData}, e, m.tid});
      }
    }
    if (has(c.fet_mlc, 0) && warm_) {
      Receiver::Msg m = take(c.fet_mlc, 0);
      Bits r = msgOf(c.mlc_fet);
      put(r, c.mlc_fet, "req_id", get(m.payload, c.fet_mlc, "req_id"));
      putLine(r, field(c.mlc_fet, "line_data").lsb, imgLine(get(m.payload, c.fet_mlc, "phys_addr")));
      warm_q_.push_back({now_ + ccv::prov::kLatMlcPipe, true, {0, r, m.tid}});
      k_.hit("mlc_warm_hit");
    }
    for (auto it = warm_q_.begin(); it != warm_q_.end() && it->at <= now_;) {
      (it->fet ? to_fet_ : to_dcu_).push_back(it->q);
      it = warm_q_.erase(it);
    }
    if (has(c.fet_mlc, 0)) {
      Receiver::Msg m = take(c.fet_mlc, 0);
      Bits e = msgOf(c.mlc_exb);
      put(e, c.mlc_exb, "phys_addr", get(m.payload, c.fet_mlc, "phys_addr"));
      put(e, c.mlc_exb, "size", kSizeLine);
      put(e, c.mlc_exb, "coh_op", kCohRead);
      to_exb_.push_back({{kFet, unsigned(get(m.payload, c.fet_mlc, "req_id"))}, e, m.tid});
    }
    if (!to_exb_.empty() && ids_.any() && can(c.mlc_exb, 0)) {
      R &r = to_exb_.front();
      const unsigned id = ids_.take();
      put(r.msg, c.mlc_exb, "req_id", id);
      owner_[id] = r.o;
      send(c.mlc_exb, 0, r.msg, r.tid);
      to_exb_.pop_front();
    }
    if (has(c.exb_mlc, 0)) {
      Receiver::Msg m = take(c.exb_mlc, 0);
      const unsigned id = unsigned(get(m.payload, c.exb_mlc, "req_id"));
      auto it = owner_.find(id);
      if (get(m.payload, c.exb_mlc, "probe_type") != 0) {
        k_.fail("mlc: an inbound probe -- not modelled in S1");
      } else if (it == owner_.end()) {
        k_.fail("mlc: a response for req_id %u, which is not outstanding", id);
      } else {
        const Line l = getLine(m.payload, field(c.exb_mlc, "line_data").lsb);
        if (it->second.who == kDcu) {
          Bits r = msgOf(c.mlc_dcu);
          put(r, c.mlc_dcu, "req_id", it->second.their_id);
          putLine(r, field(c.mlc_dcu, "line_data").lsb, l);
          put(r, c.mlc_dcu, "miss", 1);
          // One core, nothing to probe: an acquire is granted with its line.
          put(r, c.mlc_dcu, "ownership", it->second.own && k_.brk != "deny-ownership");
          to_dcu_.push_back({0, r, m.tid});
        } else {
          Bits r = msgOf(c.mlc_fet);
          put(r, c.mlc_fet, "req_id", it->second.their_id);
          putLine(r, field(c.mlc_fet, "line_data").lsb, l);
          to_fet_.push_back({0, r, m.tid});
        }
        owner_.erase(it);
        ids_.release(id);
      }
    }
    if (!to_dcu_.empty() && can(c.mlc_dcu, 0)) {
      send(c.mlc_dcu, 0, to_dcu_.front().msg, to_dcu_.front().tid);
      to_dcu_.pop_front();
    }
    if (!to_fet_.empty() && can(c.mlc_fet, 0)) {
      send(c.mlc_fet, 0, to_fet_.front().msg, to_fet_.front().tid);
      to_fet_.pop_front();
    }
  }
  bool busy() const override {
    return !to_exb_.empty() || !owner_.empty() || !to_dcu_.empty() ||
           !to_fet_.empty() || !warm_q_.empty();
  }
};

// ---- DCU: a small L1; a write is read-modify-write of the line ------------------
//
// dcu_mlc_req carries no byte mask, so a partial store cannot go below DCU
// as it arrived: DCU reads the line, merges the bytes the mask selects, and
// writes the whole line. Non-blocking: up to one request to MLC per req_id
// in flight (CCV_P_W_REQ_DCU_MLC, "sixteen fills in flight"), each tracked
// by its id, so a miss does not wait behind another line's (Daniel,
// 2026-10-21: a warp stalled on a long miss must not hold the others' up).
// Requests to one line keep their order: a line with a miss in flight takes
// nothing more until it is answered. One queued request starts a cycle.

class Dcu : public Stub {
public:
  Dcu(int inst, Kernel &k) : Stub(inst, k), ids_(ch().dcu_mlc) {}
  const char *kind() const override { return "dcu"; }

private:
  struct Op { unsigned slot; Bits req; uint64_t tid; };
  std::deque<Op> q_;
  /// A request to MLC in flight, by its req_id: a read's fill, the read half
  /// of a partial store's read-modify-write, or a write awaiting its ack.
  /// kAcquire: a store's line fetched with ownership, then merged; kPerm:
  /// ownership alone, for a store of the whole line; kEvict: a dirty line's
  /// writeback, which answers no one (DCU spec rev 8).
  enum Kind { kFill, kRmwRead, kAck, kAcquire, kPerm, kEvict };
  struct Miss { Op op; Kind kind; uint64_t line; };
  std::map<unsigned, Miss> miss_;
  std::set<uint64_t> busy_lines_;    ///< lines with a request to MLC in flight
  std::deque<std::pair<uint64_t, Line>> evict_;   ///< dirty lines waiting for a req_id
  IdPool ids_;
  std::deque<Q> to_mlc_, to_miu_;
  /// Refills promised by a notice on ccv_dcu_miu_fill_ntc (OA-23): each
  /// leaves at its cycle on its slot, which keeps a credit back for it
  /// until then (DCU spec, Internals).
  struct Promise { uint64_t at; Q q; uint64_t line; };
  std::deque<Promise> promised_;
  std::map<unsigned, unsigned> resv_;   ///< slot -> promises not yet sent
  /// A slot an ordinary response may use: a credit, and one more than its
  /// promises hold back.
  bool free(unsigned slot) {
    return can(ch().dcu_miu, slot) && credits(ch().dcu_miu, slot) > resv_[slot];
  }

  /// L1 (OI-5): a small direct-mapped array, so a load that revisits a line
  /// hits, and MIU can complete it at the L1 contract. A hit answers the
  /// cycle it arrives, ahead of any miss in flight: the contract is MIU's to
  /// keep (CCV_LAT_L1_HIT), and an answer early enough lets it.
  /// Write-back and write-allocate, with ownership (DCU spec rev 8; AR,
  /// TI-36): a read's fill installs the line shared; a store to a line DCU
  /// owns merges its bytes there, dirty, and nothing goes to MLC; a store
  /// to a shared line, or a partial miss, fetches the line with ownership,
  /// then merges; a store of the whole line that misses takes ownership
  /// alone. A dirty line leaves only whole, written back when another line
  /// takes its set. One core and no other writer, so nothing probes.
  /// write-through: every store goes to MLC as a read-merge-write, the
  /// policy before rev 8, which the merged values survive but the timing
  /// does not.
  static constexpr unsigned kSets = 64;
  struct Way { bool valid = false; uint64_t line = 0; Line data{}; bool owned = false, dirty = false; };
  std::array<Way, kSets> l1_{};
  Way &way(uint64_t pa) { return l1_[(pa / kLine) % kSets]; }
  const Line *lookup(uint64_t pa) {
    Way &w = way(pa);
    return w.valid && w.line == pa ? &w.data : nullptr;
  }
  /// The harness's view of what memory holds above the testbench.
  void shadow(const Way &w) {
    if (w.valid && w.dirty) k_.dcu_dirty[w.line].assign(w.data.begin(), w.data.end());
  }
  /// A line into its set: a dirty line there of another address is written
  /// back first, whole, and stays busy from now until MLC has it. It waits
  /// for a req_id of its own, ahead of every miss.
  void install(uint64_t pa, const Line &l, bool owned = false, bool dirty = false) {
    Way &w = way(pa);
    if (w.valid && w.dirty && w.line != pa) {
      evict_.push_back({w.line, w.data});
      busy_lines_.insert(w.line);
      k_.hit("dcu_evict");
    }
    w = {true, pa, l, owned, dirty};
    shadow(w);
  }
  /// A store's bytes into a line, under its byte mask.
  void mergeInto(Line &l, const Bits &req) const {
    const Line wd = getLine(req, field(ch().miu_dcu, "write_data").lsb);
    const uint32_t mlsb = field(ch().miu_dcu, "byte_mask").lsb;
    for (unsigned k = 0; k != kLine; ++k)
      if (req.bit(mlsb + k)) l[k] = wd[k];
  }

  /// A response to MIU answers its request by MIU's own req_id.
  Bits rspFor(const Bits &req) {
    Bits r = msgOf(ch().dcu_miu);
    put(r, ch().dcu_miu, "req_id", get(req, ch().miu_dcu, "req_id"));
    return r;
  }
  /// A read that hits: the line, hit set, no MLC miss.
  void hitRsp(const Op &o, const Line &l) {
    Bits r = rspFor(o.req);
    putLine(r, field(ch().dcu_miu, "read_data").lsb, l);
    put(r, ch().dcu_miu, "hit", 1);
    to_miu_.push_back({o.slot, r, o.tid});
  }

  /// A store whose byte mask covers its whole line: nothing of the old line
  /// survives it, so it needs no read (AR-19). skip-read-partial takes every
  /// store for one, and a partial store loses the bytes it does not write.
  bool fullLine(const Bits &req) const {
    if (k_.brk == "skip-read-partial") return true;
    const uint32_t mlsb = field(ch().miu_dcu, "byte_mask").lsb;
    for (unsigned k = 0; k != kLine; ++k)
      if (!req.bit(mlsb + k)) return false;
    return true;
  }

  void mlcReq(unsigned coh, uint64_t pa, const Line *data, const Op &o, Kind kind) {
    const Ch &c = ch();
    Bits r = msgOf(c.dcu_mlc);
    put(r, c.dcu_mlc, "phys_addr", pa);
    put(r, c.dcu_mlc, "coh_op", coh);
    const unsigned id = ids_.take();
    put(r, c.dcu_mlc, "req_id", id);
    if (data) putLine(r, field(c.dcu_mlc, "writeback_data").lsb, *data);
    to_mlc_.push_back({0, r, o.tid});
    miss_[id] = {o, kind, pa};
    busy_lines_.insert(pa);
  }

  void work() override {
    const Ch &c = ch();
    for (unsigned s = 0; s != kChans[c.miu_dcu].rate; ++s)
      while (has(c.miu_dcu, s)) {
        Receiver::Msg m = take(c.miu_dcu, s);
        const Op o{s, m.payload, m.tid};
        const Line *l = get(m.payload, c.miu_dcu, "coh_op") == kCohRead
                            ? lookup(get(m.payload, c.miu_dcu, "phys_addr"))
                            : nullptr;
        if (l) {
          // A hit answered past a miss in flight or waiting (A-46).
          if (!miss_.empty() || !q_.empty()) k_.hit("hit_under_miss");
          hitRsp(o, *l);
        } else {
          q_.push_back(o);
        }
      }
    if (has(c.mlc_dcu, 0)) {
      Receiver::Msg m = take(c.mlc_dcu, 0);
      const unsigned id = unsigned(get(m.payload, c.mlc_dcu, "req_id"));
      auto it = miss_.find(id);
      if (it == miss_.end() || !ids_.release(id)) {
        k_.fail("dcu: MLC answered req_id %u, which is not outstanding", id);
      } else {
        const Miss x = it->second;
        miss_.erase(it);
        if (x.kind == kEvict) {
          busy_lines_.erase(x.line);   // a writeback's ack: memory has the line
        } else {
        // A promised refill keeps its line busy until it leaves (refill), so
        // a read queued behind the fill still answers after it.
        const bool noticed = x.kind == kFill && promise(x);
        if (!noticed) busy_lines_.erase(x.line);
        Bits r = rspFor(x.op.req);
        if (x.kind == kFill) {
          const Line l = getLine(m.payload, field(c.mlc_dcu, "line_data").lsb);
          putLine(r, field(c.dcu_miu, "read_data").lsb, l);
          put(r, c.dcu_miu, "mlc_miss", get(m.payload, c.mlc_dcu, "miss"));
          install(x.line, l);
          if (noticed)
            refill(x.op.slot, r, x.op.tid, unsigned(get(r, c.dcu_miu, "req_id")), x.line);
          else
            to_miu_.push_back({x.op.slot, r, x.op.tid});
        } else if ((x.kind == kAcquire || x.kind == kPerm) &&
                   !get(m.payload, c.mlc_dcu, "ownership")) {
          k_.fail("dcu: MLC answered the acquire of line %llx (req_id %u) without ownership",
                  (unsigned long long)x.line, id);
        } else if (x.kind == kAcquire) {
          // The line with ownership: the store's bytes merged, dirty.
          Line l = getLine(m.payload, field(c.mlc_dcu, "line_data").lsb);
          mergeInto(l, x.op.req);
          install(x.line, l, true, true);
          to_miu_.push_back({x.op.slot, r, x.op.tid});   // the store's ack
        } else if (x.kind == kPerm) {
          // Ownership alone: the store wrote every byte.
          install(x.line, getLine(x.op.req, field(c.miu_dcu, "write_data").lsb), true, true);
          to_miu_.push_back({x.op.slot, r, x.op.tid});
        } else if (x.kind == kRmwRead) {
          Line l = getLine(m.payload, field(c.mlc_dcu, "line_data").lsb);
          const Line w = getLine(x.op.req, field(c.miu_dcu, "write_data").lsb);
          const uint32_t mlsb = field(c.miu_dcu, "byte_mask").lsb;
          for (unsigned k = 0; k != kLine; ++k)
            if (x.op.req.bit(mlsb + k)) l[k] = w[k];
          install(x.line, l);
          mlcReq(kCohWrite, x.line, &l, x.op, kAck);
        } else {
          to_miu_.push_back({x.op.slot, r, x.op.tid});   // the write's ack
        }
        }
      }
    }
    // A writeback leaves first. The harness's view keeps the line until it
    // is sent; from there on memory has it, in order ahead of any read.
    while (!evict_.empty() && ids_.any()) {
      if (k_.brk == "drop-writeback") busy_lines_.erase(evict_.front().first);
      else mlcReq(kCohWrite, evict_.front().first, &evict_.front().second,
             Op{0, Bits(), makeUid(IdClass::kTxn, g_unowned_txn++)}, kEvict);
      k_.dcu_dirty.erase(evict_.front().first);
      evict_.pop_front();
    }
    // The oldest queued request whose line has nothing in flight, nor an
    // older request waiting, starts: a hit (a read queued behind the fill
    // that brought its line in hits now, late for the contract, which is
    // MIU's to judge), a whole-line write, or a read to MLC.
    std::set<uint64_t> held;
    for (auto it = q_.begin(); it != q_.end(); ++it) {
      const uint64_t pa = get(it->req, c.miu_dcu, "phys_addr");
      if (busy_lines_.count(pa) || held.count(pa)) { held.insert(pa); continue; }
      const bool rd = get(it->req, c.miu_dcu, "coh_op") == kCohRead;
      const Line *l = rd ? lookup(pa) : nullptr;
      // A store to a line DCU owns merges here (DCU spec rev 8).
      Way &wy = way(pa);
      const bool owned_hit = !rd && wy.valid && wy.line == pa && wy.owned &&
                             k_.brk != "write-through";
      if (owned_hit) {
        const Op o = *it;
        q_.erase(it);
        mergeInto(wy.data, o.req);
        wy.dirty = true;
        shadow(wy);
        to_miu_.push_back({o.slot, rspFor(o.req), o.tid});
        k_.hit("store_hit");
        break;
      }
      if (!l && (!ids_.any() || !evict_.empty())) break;   // wait, in order
      if (!l && k_.brk == "dcu-one-miss" && !miss_.empty()) break;   // a blocking DCU
      const Op o = *it;
      q_.erase(it);
      if (l) {
        hitRsp(o, *l);
      } else if (!rd && k_.brk == "write-through") {
        if (fullLine(o.req)) {
          const Line w = getLine(o.req, field(c.miu_dcu, "write_data").lsb);
          install(pa, w);
          mlcReq(kCohWrite, pa, &w, o, kAck);
          k_.hit("full_line");
        } else {
          mlcReq(kCohRead, pa, nullptr, o, kRmwRead);
        }
      } else if (!rd && fullLine(o.req)) {
        // The whole line written: ownership alone, no data (AcquirePerm).
        mlcReq(kCohAcquirePerm, pa, nullptr, o, kPerm);
        k_.hit("full_line");
      } else if (!rd) {
        // A partial store, missing or to a shared line: the line with
        // ownership, then the merge (AcquireBlock).
        mlcReq(kCohAcquireData, pa, nullptr, o, kAcquire);
        k_.hit("l1_miss");
      } else {
        mlcReq(kCohRead, pa, nullptr, o, kFill);
        k_.hit("l1_miss");
      }
      break;
    }
    if (!to_mlc_.empty() && can(c.dcu_mlc, 0)) {
      send(c.dcu_mlc, 0, to_mlc_.front().msg, to_mlc_.front().tid);
      to_mlc_.pop_front();
    }
    // Promised refills first: each at its cycle, on its reserved credit.
    for (auto it = promised_.begin(); it != promised_.end();) {
      if (it->at != now_) { ++it; continue; }
      if (!can(c.dcu_miu, it->q.slot))
        k_.fail("dcu: the refill promised on slot %u at cycle %llu has no credit",
                it->q.slot, (unsigned long long)now_);
      else
        send(c.dcu_miu, it->q.slot, it->q.msg, it->q.tid);
      --resv_[it->q.slot];
      busy_lines_.erase(it->line);
      it = promised_.erase(it);
    }
    for (auto it = to_miu_.begin(); it != to_miu_.end();)
      if (free(it->slot)) {
        send(c.dcu_miu, it->slot, it->msg, it->tid);
        it = to_miu_.erase(it);
      } else {
        ++it;
      }
  }
  /// A refill is noticed (OA-23) if the notice's slot and a credit beyond
  /// those already promised are free; else it is sent as it can be.
  bool promise(const Miss &x) {
    return can(ch().fill_ntc, x.op.slot) && credits(ch().dcu_miu, x.op.slot) > resv_[x.op.slot];
  }
  /// A noticed refill: the notice, naming MIU's req_id, launches now, so its
  /// payload lands two cycles on; the refill launches the cycle before its
  /// valid is due, exactly CCV_LAT_FILL_NOTICE cycles after that.
  void refill(unsigned slot, const Bits &r, uint64_t tid, unsigned id, uint64_t line) {
    const Ch &c = ch();
    Bits n = msgOf(c.fill_ntc);
    put(n, c.fill_ntc, "req_id", k_.brk == "notice-wrong-id" ? id ^ 1u : id);
    send(c.fill_ntc, slot, n, tid);
    promised_.push_back({now_ + 1 + ccv::prov::kLatFillNotice +
                             (k_.brk == "late-refill" ? 1 : 0),
                         {slot, r, tid}, line});
    ++resv_[slot];
    k_.hit("fill_notice");
  }

  bool busy() const override {
    return !q_.empty() || !miss_.empty() || !to_mlc_.empty() || !to_miu_.empty() ||
           !promised_.empty();
  }
};

// ---- MIU -------------------------------------------------------------------------

class Miu : public Stub {
public:
  Miu(int inst, Kernel &k) : Stub(inst, k), ids_(ch().miu_dcu) {}
  const char *kind() const override { return "miu"; }

private:
  /// discarded: a bulk discard covered it before its address came, so the
  /// address ends it with a replay completion (TI-21).
  struct Memop { unsigned slot; Bits msg; uint64_t at; uint64_t tid; bool discarded = false; };
  struct Addr { unsigned slot; Bits msg; uint64_t tid; };
  struct LineReq { uint64_t line; Line data{}; std::array<bool, kLine> mask{}; uint16_t sub; };
  struct Job {
    bool store = false;
    unsigned tag = 0, memop_slot = 0, addr_slot = 0, warp = 0;
    unsigned phys_dst = 0, phys_pred = 0;   ///< echoed on miu_rcu_data
    unsigned rs_idx = 0;                    ///< echoed on miu_ooe_cmpl (OA-23)
    unsigned dst_pos = 0, chw = 0;          ///< likewise: the slice a load writes
    uint32_t active = 0;             ///< lanes that may access memory
    uint64_t tid = 0;
    std::array<uint64_t, kLanes> addr{};
    std::vector<LineReq> lines;
    unsigned next = 0, back = 0;     ///< lines requested / answered
    std::map<uint64_t, Line> got;
    bool global = false;             ///< .global: the L1 contract applies
    bool hit = true;                 ///< every line hit in DCU
    bool mlc_miss = false;           ///< some line's fill missed MLC
    uint64_t due = 0;                ///< a global load's L1-contract cycle
    uint64_t serial = 0;             ///< names it to the DCU responses
    uint64_t promised = 0;           ///< a hinted completion's launch cycle, or 0 (OA-23)
    bool frame = false;              ///< its lanes span windows: O-30 frames (AR-23)
    /// A predicate transfer (TI-36): one word at lane 0's address. A store
    /// carries its predicate's word, merged into memory's after commit.
    bool pxfer = false;
    unsigned bytes = 4;              ///< per lane: the data register's width
    uint32_t pdata = 0;
    unsigned rmw = 0;                ///< a predicate store's drain: 1 reading, 2 writing
  };
  /// A predicate transfer's oracle access: the uop's word, its sub-th of
  /// the instruction's, ascending (TI-36).
  static const MemAcc *xferAcc(const Record *r, uint64_t tid) {
    return r && uidSub(tid) < r->mem.size() ? &r->mem[uidSub(tid)] : nullptr;
  }
  /// A hit's completion and data, held for the contract cycle.
  struct Timed { uint64_t at; Q data, cmpl; bool data_only = false; };
  std::deque<Timed> timed_;

  std::map<unsigned, Memop> memop_;
  std::map<unsigned, Addr> addr_;
  /// F-RO's .const range by CTA slot, [base, limit), from RAU (TI-26).
  std::map<unsigned, std::pair<uint64_t, uint64_t>> ro_;
  /// The lanes of a store F-RO refuses (AR's responses TI-26): any lane
  /// whose four bytes touch the launch window (address bits [47:16] equal
  /// to 2, the whole window) or the CTA's .const range. Compared on the
  /// effective address, which this MIU never maps. no-ro drops the check.
  uint32_t roLanes(const Job &j, unsigned cta) const {
    if (!j.store || k_.brk == "no-ro") return 0;
    const auto r = ro_.find(cta);
    const uint64_t base = r == ro_.end() ? 0 : r->second.first;
    const uint64_t limit = r == ro_.end() ? 0 : r->second.second;
    uint32_t ro = 0;
    for (unsigned l = 0; l != kLanes; ++l) {
      if (!(j.active >> l & 1u)) continue;
      const uint64_t a = j.addr[l];
      const bool launch = (a >> 16) == 2 || ((a + 3) >> 16) == 2;
      const bool cnst = a < limit && a + 4 > base;
      if (launch || cnst) ro |= 1u << l;
    }
    return ro;
  }
  /// The launch-slot windows (TI-31, AR's response): by CTA slot, the
  /// sixteen 32-bit words at launch_block_addr + 32 + 8k and their valid
  /// bits. Filled a line at a time on first use; cleared on the slot's
  /// rau_miu_cta and on a kill.
  /// gen counts the clears: a fill sent before one lands nothing.
  /// Entry kLocalBase is O-69's local_base, the word at byte 24 (IS-19).
  /// For the check that a CTA slot names one CTA: each slot's CTA and each
  /// CTA's slot, with the warp first seen naming it.
  std::map<unsigned, std::pair<unsigned, unsigned>> slot_cta_, cta_slot_;
  struct Windows {
    uint64_t block = 0;
    std::array<uint32_t, 17> w{};
    uint32_t valid = 0;
    unsigned gen = 0;
    void clear() { valid = 0; ++gen; }
  };
  std::map<unsigned, Windows> win_;
  /// A window fill's request to DCU, by req_id: its CTA slot and line, and
  /// the table's gen when it was sent.
  struct Fill { unsigned cta; uint64_t line; unsigned gen; };
  std::map<unsigned, Fill> fills_;
  /// Memops that waited on a fill: an L1 miss, whatever DCU says.
  std::set<unsigned> win_miss_;
  static constexpr unsigned kLocalBase = 16;
  static uint64_t slotAddr(const Windows &t, unsigned k) {
    return k == kLocalBase ? t.block + 24 : t.block + 32 + 8 * k;
  }
  /// Every slot of `t` in `line`, filled from it.
  static void fillWindows(Windows &t, uint64_t line, const Line &d) {
    for (unsigned k = 0; k != 17; ++k) {
      const uint64_t a = slotAddr(t, k);
      if (a / kLine * kLine != line) continue;
      uint32_t v = 0;
      for (unsigned b = 0; b != 4; ++b) v |= uint32_t(d[a % kLine + b]) << (8 * b);
      t.w[k] = v;
      t.valid |= 1u << k;
    }
  }
  void onKill(uint32_t, unsigned) override {
    for (auto &t : win_) t.second.clear();
  }
  std::deque<unsigned> order_;               ///< memops, as OOE issued them
  std::map<unsigned, Job> stores_;           ///< awaiting commit, by rob tag
  std::deque<Job> committed_;
  /// A load's fault, held to its L1 contract cycle (V-44).
  std::vector<std::pair<uint64_t, Q>> late_faults_;
  /// Jobs in flight, oldest first, up to CCV_MIU_PIPES (AR-19): each sends
  /// its line requests and completes on its own, so DCU holds requests from
  /// more than one memop and a hit is not held behind an older miss. One
  /// starts a cycle, in issue order; a committed store's write never shares
  /// a line with a job in flight, and a load never with a store's write
  /// queued or in flight, so neither reads a line around the other.
  std::list<Job> jobs_;
  uint64_t serial_ = 0;
  bool dropped_ = false;
  IdPool ids_;
  /// The job and line of each request to DCU, by req_id.
  std::map<unsigned, std::pair<uint64_t, uint64_t>> outstanding_;
  std::deque<Q> to_rcu_, to_ooe_, to_dcu_, to_fet_;
  /// Hints promised to OOE (OA-23), each launched at its cycle; and the
  /// credits held back for hinted completions and their data, by slot.
  struct Hint { uint64_t at; Q q; };
  std::deque<Hint> hints_;
  std::map<std::pair<unsigned, unsigned>, unsigned> resv_;
  /// The replay drain (TI-21): requests a bulk discard abandoned at DCU, by
  /// req_id, and each warp's count of them. Their responses are dropped,
  /// and a warp is reported ready to RAU when its count returns to zero.
  std::map<unsigned, unsigned> orphan_;
  std::map<unsigned, unsigned> orphans_;
  std::deque<Q> to_rau_;
  /// A slot an ordinary message may use: a credit, and one more than the
  /// hinted completions hold back.
  bool free(unsigned chan, unsigned slot) {
    return can(chan, slot) && credits(chan, slot) > resv_[{chan, slot}];
  }
  bool spare(unsigned chan, unsigned slot) {
    return credits(chan, slot) > resv_[{chan, slot}];
  }

  /// A refill notice (OA-23): its refill's valid lands CCV_LAT_FILL_NOTICE
  /// cycles from now, its payload a cycle later, and a load waiting on
  /// nothing else completes as it lands. So the completion launches then
  /// and its hint CCV_LAT_CMPL_HINT + 1 cycles before, on the completion's
  /// slot, with that slot's credit, the hint's and the data's held back.
  void notice(unsigned id) {
    const Ch &c = ch();
    auto o = outstanding_.find(id);
    if (o == outstanding_.end()) return;   // a notice names what DCU owes; nothing here to hint
    for (Job &j : jobs_) {
      if (j.serial != o->second.first) continue;
      if (j.store || j.promised || j.next != j.lines.size() || j.back + 1 != j.lines.size())
        return;
      const uint64_t at = now_ + ccv::prov::kLatFillNotice + 1;
      const uint64_t h = at - ccv::kLatCmplHint - 1;
      const unsigned ms = j.memop_slot, as = j.addr_slot;
      if (h < now_ + 1 || !spare(c.cmpl_hint, ms) || !spare(c.miu_ooe, ms) ||
          !spare(c.miu_rcu, as))
        return;
      Bits m = msgOf(c.cmpl_hint);
      put(m, c.cmpl_hint, "rs_idx", j.rs_idx);
      put(m, c.cmpl_hint, "rob_tag", k_.brk == "hint-wrong-tag" ? j.tag ^ 1u : j.tag);
      hints_.push_back({h, {ms, m, j.tid}});
      ++resv_[{c.cmpl_hint, ms}];
      ++resv_[{c.miu_ooe, ms}];
      ++resv_[{c.miu_rcu, as}];
      j.promised = at;
      return;
    }
  }

  void work() override {
    const Ch &c = ch();
    for (unsigned s = 0; s != kChans[c.fill_ntc].rate; ++s)
      while (has(c.fill_ntc, s))
        notice(unsigned(get(take(c.fill_ntc, s).payload, c.fill_ntc, "req_id")));
    for (auto it = hints_.begin(); it != hints_.end();) {
      if (it->at != now_) { ++it; continue; }
      if (!can(c.cmpl_hint, it->q.slot))
        k_.fail("miu: the hint promised on slot %u at cycle %llu has no credit",
                it->q.slot, (unsigned long long)now_);
      else
        send(c.cmpl_hint, it->q.slot, it->q.msg, it->q.tid);
      --resv_[{c.cmpl_hint, it->q.slot}];
      k_.hit("cmpl_hint");
      it = hints_.erase(it);
    }
    if (has(c.fet_miu, 0)) {
      // Identity translation: the page table is not modelled yet.
      Receiver::Msg m = take(c.fet_miu, 0);
      Bits r = msgOf(c.miu_fet);
      put(r, c.miu_fet, "itlb_refill", get(m.payload, c.fet_miu, "virtual_page"));
      to_fet_.push_back({0, r, m.tid});
    }
    if (has(c.rau_miu, 0)) {
      // A CTA's configuration: of it, F-RO's .const range (TI-26).
      const Bits m = take(c.rau_miu, 0).payload;
      const unsigned cta = unsigned(get(m, c.rau_miu, "cta_slot"));
      ro_[cta] = {get(m, c.rau_miu, "const_base"), get(m, c.rau_miu, "const_limit")};
      // And where its launch-slot windows come from; the old launch's go.
      Windows &t = win_[cta];
      t.block = get(m, c.rau_miu, "launch_block_addr");
      t.clear();
    }
    for (unsigned s = 0; s != kChans[c.ooe_miu].rate; ++s)
      while (has(c.ooe_miu, s)) {
        Receiver::Msg m = take(c.ooe_miu, s);
        const unsigned tag = unsigned(get(m.payload, c.ooe_miu, "rob_tag"));
        // The memop's pipe footprint (OI-33): its width's span of pipes, from
        // its data position. MIU sizes its per-pipe work by it. A bulk
        // discard's fields are reserved zero (A-41), pipes among them.
        const unsigned chw = unsigned(get(m.payload, c.ooe_miu, "chwidth"));
        const unsigned pos = unsigned(get(m.payload, c.ooe_miu, "dst_pos"));
        const unsigned pipes = unsigned(get(m.payload, c.ooe_miu, "pipes"));
        if (get(m.payload, c.ooe_miu, "mem_op") != kMemBulkDiscard && pipes != maskOf(chw, pos))
          k_.fail("miu: rob tag %u has pipes %x, but a %u-bit memop at position %u takes %x",
                  tag, pipes, 32u >> chw, pos, maskOf(chw, pos));
        // Only a fence carries an ordering (IS-11; AR's response, 0xE).
        const unsigned ord = unsigned(get(m.payload, c.ooe_miu, "ordering"));
        if (ord != 0 && get(m.payload, c.ooe_miu, "mem_op") != kMemFence)
          k_.fail("miu: rob tag %u has ordering %u but is not a fence", tag, ord);
        if (get(m.payload, c.ooe_miu, "mem_op") == kMemBulkDiscard) {
          discard(m.payload);
          continue;
        }
        if (uidClass(m.tid) != IdClass::kInstr)
          k_.fail("miu: rob tag %u is a memop with id class %u; only a discard may carry none",
                  tag, unsigned(uidClass(m.tid)));
        // The CTA slot OOE stamps, RAU's for the warp (TI-34): the window
        // table, F-RO's range and the launch block are indexed by it.
        {
          const unsigned w = unsigned(get(m.payload, c.ooe_miu, "warp_id"));
          const unsigned cs = unsigned(get(m.payload, c.ooe_miu, "cta_slot"));
          if (k_.cta_slot_of.count(w) && cs != k_.cta_slot_of[w]) {
            k_.fail("miu: rob tag %u (warp %u) names CTA slot %u; RAU gave it %u", tag, w, cs,
                    k_.cta_slot_of[w]);
          }
          // A slot is one CTA's, and a CTA has one slot (CP-30): the warps
          // ccv-sim ran as one CTA share its state here, and no other's.
          // Checked once the slot is RAU's, so a memop is refused once.
          else if (w < k_.cta_of.size()) {
            const unsigned cta = k_.cta_of[w];
            auto a = slot_cta_.emplace(cs, std::make_pair(cta, w)).first;
            auto b = cta_slot_.emplace(cta, std::make_pair(cs, w)).first;
            if (a->second.first != cta)
              k_.fail("miu: CTA slot %u holds warp %u of ctaid %u and warp %u of ctaid %u", cs,
                      a->second.second, k_.orcs[a->second.second].ctaid, w, k_.orcs[w].ctaid);
            else if (b->second.first != cs)
              k_.fail("miu: warps %u and %u of ctaid %u name CTA slots %u and %u", b->second.second,
                      w, k_.orcs[w].ctaid, b->second.first, cs);
          }
        }
        memop_[tag] = {s, m.payload, now_, m.tid};
        order_.push_back(tag);
      }
    for (unsigned s = 0; s != kChans[c.rcu_miu].rate; ++s)
      while (has(c.rcu_miu, s)) {
        Receiver::Msg m = take(c.rcu_miu, s);
        const unsigned tag = unsigned(get(m.payload, c.rcu_miu, "rob_tag"));
        auto mo = memop_.find(tag);
        if (mo != memop_.end() && mo->second.discarded) {
          replay(tag, mo->second);   // a discarded memop's address: it ends here
          continue;
        }
        addr_[tag] = {s, m.payload, m.tid};
      }
    for (unsigned s = 0; s != kChans[c.ooe_ret].rate; ++s)
      while (has(c.ooe_ret, s)) {
        Receiver::Msg m = take(c.ooe_ret, s);
        const unsigned tag = unsigned(get(m.payload, c.ooe_ret, "rob_tag"));
        auto it = stores_.find(tag);
        if (it == stores_.end()) {
          k_.fail("miu: retire for rob tag %u, which holds no store", tag);
          continue;
        }
        if (get(m.payload, c.ooe_ret, "commit_or_discard")) {
          if (k_.brk == "drop-store" && !dropped_) dropped_ = true;
          else committed_.push_back(it->second);
        }
        stores_.erase(it);
      }
    for (unsigned s = 0; s != kChans[c.dcu_miu].rate; ++s)
      while (has(c.dcu_miu, s)) {
        Receiver::Msg m = take(c.dcu_miu, s);
        // Matched by req_id, not by slot or arrival order: DCU may answer
        // four outstanding requests in any order.
        const unsigned id = unsigned(get(m.payload, c.dcu_miu, "req_id"));
        auto fl = fills_.find(id);
        if (fl != fills_.end()) {
          // A window fill: every slot its line holds (TI-31).
          Windows &t = win_[fl->second.cta];
          if (t.gen == fl->second.gen)
            fillWindows(t, fl->second.line,
                        getLine(m.payload, field(c.dcu_miu, "read_data").lsb));
          fills_.erase(fl);
          ids_.release(id);
          continue;
        }
        auto orph = orphan_.find(id);
        if (orph != orphan_.end()) {
          // An orphan's response: dropped, no data, no completion (TI-21).
          const unsigned w = orph->second;
          orphan_.erase(orph);
          ids_.release(id);
          if (--orphans_[w] == 0 && k_.brk != "early-ready") ready(w);
          continue;
        }
        auto o = outstanding_.find(id);
        if (o == outstanding_.end()) {
          k_.fail("miu: a DCU response for req_id %u, which is not outstanding", id);
          continue;
        }
        const auto [serial, line] = o->second;
        outstanding_.erase(o);
        ids_.release(id);
        for (Job &j : jobs_)
          if (j.serial == serial) {
            j.got[line] = getLine(m.payload, field(c.dcu_miu, "read_data").lsb);
            if (!get(m.payload, c.dcu_miu, "hit")) j.hit = false;
            if (get(m.payload, c.dcu_miu, "mlc_miss")) j.mlc_miss = true;
            ++j.back;
          }
      }

    if (jobs_.size() < kMiuPipes) start();
    advance();
    // A hit's completion and data leave together at the contract cycle, or
    // not as a hit at all: if either channel has no credit then, both go
    // late and OOE takes it for a miss (A-46), never a completion on time
    // with its data behind it.
    while (!timed_.empty() && timed_.front().at <= now_) {
      Timed t = timed_.front();
      timed_.pop_front();
      if (t.data_only) {                   // late-hit-data's data, behind
        to_rcu_.push_back(t.data);
        continue;
      }
      if (t.at == now_ && free(c.miu_rcu, t.data.slot) && free(c.miu_ooe, t.cmpl.slot)) {
        send(c.miu_ooe, t.cmpl.slot, t.cmpl.msg, t.cmpl.tid);
        if (k_.brk == "late-hit-data")
          // The data a cycle behind its completion: dependants woken by the
          // contract read the register before the load lands.
          timed_.push_front({now_ + 1, t.data, t.cmpl, true});
        else
          send(c.miu_rcu, t.data.slot, t.data.msg, t.data.tid);
        k_.hit("l1_hit");
      } else {
        to_rcu_.push_back(t.data);
        to_ooe_.push_back(t.cmpl);
        k_.hit("l1_late");
      }
    }

    for (auto it = late_faults_.begin(); it != late_faults_.end();)
      if (it->first <= now_) { to_ooe_.push_back(it->second); it = late_faults_.erase(it); }
      else ++it;
    auto drain = [&](std::deque<Q> &q, unsigned chan) {
      for (auto it = q.begin(); it != q.end();)
        if (free(chan, it->slot)) { send(chan, it->slot, it->msg, it->tid); it = q.erase(it); }
        else ++it;
    };
    drain(to_fet_, c.miu_fet);
    drain(to_rcu_, c.miu_rcu);
    drain(to_ooe_, c.miu_ooe);
    drain(to_dcu_, c.miu_dcu);
    drain(to_rau_, c.miu_ready);
  }

  /// Whether rob_tag lies in a bulk discard's circular range (branch, tail]
  /// of the same ROB. branch == tail is the whole ROB: a squash to
  /// retirement of a full ROB, since a discard is never sent for an empty
  /// range.
  static bool inRange(unsigned tag, unsigned branch, unsigned tail) {
    const unsigned w = ccv::prov::kWRobIdx, d = 1u << w, mask = d - 1;
    if (tag >> w != branch >> w) return false;
    const unsigned b = branch & mask;
    const unsigned len = (tail - b) & mask;
    return ((tag & mask) - b - 1 & mask) < (len ? len : d);
  }

  /// A bulk discard (A-41; TI-21): the warp's stores in its range are
  /// dropped, and every memop in it that has not completed is completed now
  /// with status replay: one not started yet, or a load in flight, whose
  /// requests to DCU become orphans. A load whose completion is promised by
  /// a hint, or already on its way, completes as it would have: one
  /// completion either way.
  void discard(const Bits &m) {
    const Ch &c = ch();
    const unsigned w = unsigned(get(m, c.ooe_miu, "warp_id"));
    const unsigned branch = unsigned(get(m, c.ooe_miu, "rob_tag"));
    const unsigned tail =
        (branch & ~((1u << ccv::prov::kWRobIdx) - 1)) |
        unsigned(m.get(field(c.ooe_miu, "disp").lsb, ccv::prov::kWRobIdx));
    k_.hit("bulk_discard");
    for (auto it = stores_.begin(); it != stores_.end();)
      if (it->second.warp == w && inRange(it->first, branch, tail)) it = stores_.erase(it);
      else ++it;
    std::vector<unsigned> now;
    for (unsigned tag : order_) {
      Memop &mo = memop_[tag];
      if (unsigned(get(mo.msg, c.ooe_miu, "warp_id")) != w || !inRange(tag, branch, tail)) continue;
      if (addr_.erase(tag)) now.push_back(tag);
      else mo.discarded = true;   // ended by its address, which is on its way
    }
    for (unsigned tag : now) replay(tag, memop_[tag]);
    for (auto it = jobs_.begin(); it != jobs_.end();) {
      Job &j = *it;
      if (j.store || j.warp != w || j.promised || !inRange(j.tag, branch, tail)) { ++it; continue; }
      for (auto o = outstanding_.begin(); o != outstanding_.end();)
        if (o->second.first == j.serial) {
          orphan_[o->first] = w;
          ++orphans_[w];
          k_.hit("orphan");
          o = outstanding_.erase(o);
        } else {
          ++o;
        }
      if (k_.brk != "drop-replay") to_ooe_.push_back({j.memop_slot, replayMsg(j.tag, j.rs_idx), j.tid});
      if (k_.brk == "replay-twice") to_ooe_.push_back({j.memop_slot, cmpl(j), j.tid});
      k_.hit("replay");
      it = jobs_.erase(it);
    }
    // early-ready: reported at the discard, not when its orphans are home.
    if (!orphans_[w] || k_.brk == "early-ready") ready(w);
  }

  /// A memop not started, ended by a discard: its replay completion.
  void replay(unsigned tag, const Memop &mo) {
    const Ch &c = ch();
    if (k_.brk != "drop-replay")
      to_ooe_.push_back(
          {mo.slot, replayMsg(tag, unsigned(get(mo.msg, c.ooe_miu, "rs_idx"))), mo.tid});
    k_.hit("replay");
    order_.erase(std::find(order_.begin(), order_.end(), tag));
    memop_.erase(tag);
    win_miss_.erase(tag);
  }

  Bits replayMsg(unsigned tag, unsigned rs_idx) {
    const Ch &c = ch();
    Bits m = msgOf(c.miu_ooe);
    put(m, c.miu_ooe, "rob_tag", tag);
    put(m, c.miu_ooe, "rs_idx", rs_idx);
    put(m, c.miu_ooe, "status", kStatusReplay);
    return m;
  }

  void ready(unsigned w) {
    if (k_.brk == "no-ready") return;
    Bits r = msgOf(ch().miu_ready);
    put(r, ch().miu_ready, "warp_id", w);
    to_rau_.push_back({0, r, makeUid(IdClass::kNone, 0)});
  }

  /// Committed stores first (they are older than anything still issuing),
  /// then the oldest memop whose address has arrived.
  void start() {
    const Ch &c = ch();
    if (!committed_.empty()) {
      if (inFlight(committed_.front(), false)) return;
      Job &cj = committed_.front();
      // A predicate store drains as a read-merge-write of its word (MIU
      // spec rev 25, O-63): its line read and held, then the merged word
      // written. With no lane in its mask, nothing is read or written.
      if (cj.pxfer) cj.rmw = 1;
      if (!(cj.pxfer && cj.lines.empty())) launch(cj);
      committed_.pop_front();
      return;
    }
    if (order_.empty()) return;
    const unsigned tag = order_.front();
    auto a = addr_.find(tag);
    if (a == addr_.end()) return;
    const Memop &mo = memop_[tag];
    // The launch-slot form (TI-31): its window must be in the table. If not,
    // the memop waits, and every one behind it, while its line is read: an
    // L1 miss, never a hit (AR's response). no-window-fill: the table is
    // taken as filled, its words zero.
    const bool slot = get(mo.msg, c.ooe_miu, "slot_form") != 0;
    // The interleaved local form (IS-19) waits the same way for local_base,
    // the table's word from the launch block's first line.
    const bool local = get(mo.msg, c.ooe_miu, "local_form") != 0;
    const unsigned cta = unsigned(get(mo.msg, c.ooe_miu, "cta_slot"));
    const unsigned k = local ? kLocalBase : unsigned(get(mo.msg, c.ooe_miu, "arg_slot"));
    if ((slot || local) && k_.brk != "no-window-fill" && !(win_[cta].valid >> k & 1u)) {
      const uint64_t line = slotAddr(win_[cta], k) / kLine * kLine;
      win_miss_.insert(tag);
      for (const auto &f : fills_)
        if (f.second.cta == cta && f.second.line == line && f.second.gen == win_[cta].gen)
          return;                                               // on its way
      for (unsigned s = 0; s != kChans[c.miu_dcu].rate; ++s) {
        if (!free(c.miu_dcu, s) || !ids_.any()) continue;
        Bits r = msgOf(c.miu_dcu);
        const unsigned id = ids_.take();
        put(r, c.miu_dcu, "req_id", id);
        put(r, c.miu_dcu, "phys_addr", line);
        put(r, c.miu_dcu, "size", kSizeLine);
        put(r, c.miu_dcu, "coh_op", kCohRead);
        send(c.miu_dcu, s, r, makeUid(IdClass::kTxn, uidSeq(mo.tid), 0, /*owned=*/true));
        fills_[id] = {cta, line, win_[cta].gen};
        k_.hit("window_fill");
        k_.hit("dcu_lookups");
        break;
      }
      return;
    }
    // A fence (IS-11): every older store of its warp written to DCU before
    // it completes, so what follows it, a barrier arrive among them (TI-40),
    // comes after those writes are visible to every warp. Memops arrive in
    // program order per warp, so the warp's stores still uncommitted here are
    // all older; one committed but not yet written waits in committed_ or in
    // flight. No kernel here can see a fence that does not wait: this MIU
    // also holds any load while a store to its line is in flight.
    if (get(mo.msg, c.ooe_miu, "mem_op") == kMemFence) {
      const unsigned w = unsigned(get(mo.msg, c.ooe_miu, "warp_id"));
      bool pending = false;
      for (const auto &st : stores_) pending = pending || st.second.warp == w;
      for (const Job &cj : committed_) pending = pending || cj.warp == w;
      for (const Job &f : jobs_) pending = pending || (f.store && f.warp == w);
      if (pending) { k_.hit("fence_wait"); return; }
      Job f;
      f.tag = tag;
      f.warp = w;
      f.memop_slot = mo.slot;
      f.rs_idx = unsigned(get(mo.msg, c.ooe_miu, "rs_idx"));
      f.tid = a->second.tid;
      to_ooe_.push_back({f.memop_slot, cmpl(f), f.tid});
      order_.pop_front();
      memop_.erase(tag);
      addr_.erase(a);
      k_.hit("fence");
      return;
    }
    Job j;
    j.tag = tag;
    const unsigned mop = unsigned(get(mo.msg, c.ooe_miu, "mem_op"));
    j.store = mop == kMemStore || mop == kMemPredStore;
    j.pxfer = mop == kMemPredLoad || mop == kMemPredStore;
    j.memop_slot = mo.slot;
    j.warp = unsigned(get(mo.msg, c.ooe_miu, "warp_id"));
    j.phys_dst = unsigned(get(mo.msg, c.ooe_miu, "phys_dst"));
    j.phys_pred = unsigned(get(mo.msg, c.ooe_miu, "phys_pred"));
    j.rs_idx = unsigned(get(mo.msg, c.ooe_miu, "rs_idx"));
    j.dst_pos = unsigned(get(mo.msg, c.ooe_miu, "dst_pos"));
    j.chw = unsigned(get(mo.msg, c.ooe_miu, "chwidth"));
    j.addr_slot = a->second.slot;
    j.tid = a->second.tid;
    // The L1 contract (A-46, A-61): a hit's completion reaches OOE at its
    // issue + CCV_LAT_L1_CMPL. The memop's arrival says when OOE issued it,
    // since it left on that cycle and the link is fixed, so the completion
    // must leave MIU CCV_LAT_L1_CMPL less both crossings after it arrived.
    // Timed from the issue, not from when MIU got to it: a load MIU starts
    // late cannot be a hit, and one whose address came early is not early.
    j.due = mo.at + ccv::prov::kLatL1Cmpl - crossing(c.ooe_miu) - crossing(c.miu_ooe) -
            (k_.brk == "early-hit" ? 1 : 0);
    const Bits &am = a->second.msg;
    // Two DIFFERENT masks: the issue mask from OOE, and active = issue AND
    // guard from RCU. They differ for any predicated op, correctly; what
    // must hold is that no lane is active outside the issue group.
    j.active = uint32_t(get(am, c.rcu_miu, "active_mask"));
    const uint32_t issue = uint32_t(get(mo.msg, c.ooe_miu, "issue_mask"));
    // The AGU (§5.1): .global is (base << 16) + (index << scale) + disp, and
    // the scale is log2 of the element size, from chwidth, when enabled.
    // .shared has no window shift. disp is sign-extended from CCV_W_DISP.
    const FieldDesc &df = field(c.ooe_miu, "disp");
    const uint64_t draw = get(mo.msg, c.ooe_miu, "disp");
    const int64_t disp = int64_t(draw << (64 - df.width)) >> (64 - df.width);
    const unsigned chw = unsigned(get(mo.msg, c.ooe_miu, "chwidth"));
    const unsigned sh = get(mo.msg, c.ooe_miu, "scale_en") ? 2 - std::min(chw, 2u) : 0;
    const bool global = get(mo.msg, c.ooe_miu, "space") == kSpaceGlobal;
    j.global = global;
    // The base is per lane (TI-32), or a launch slot's window (TI-31).
    // window-from-base: a slot form's window taken from base_per_lane.
    if (win_miss_.count(tag)) j.hit = false;
    const bool from_win = slot && k_.brk != "window-from-base";
    if (slot) k_.hit("slot_form");
    // O-69's address (IS-19): lane l's byte b of the warp's spill frame is
    // ((local_base + CCV_LANE_CONTEXTS) << 16) + (ctx << 22) + 128 (b / 4)
    // + 4l + b % 4, ctx the warp's hardware context, which MIU forms from
    // the memop's warp_id and its core's index (OA's proposal IS-19).
    // local-no-ctx: ctx taken as 0, so every warp spills to one frame.
    // local-base-slot: local_base read from launch slot 0's word.
    const uint64_t lbase =
        win_[cta].w[k_.brk == "local-base-slot" ? 0u : unsigned(kLocalBase)];
    const uint64_t ctx = k_.brk == "local-no-ctx"
                             ? 0 : (uint64_t(ccv::prov::kCoreId) << ccv::kWWarpId) | j.warp;
    auto localAddr = [&](uint64_t b, unsigned l) {
      return ((lbase + ccv::prov::kLaneContexts) << 16) + (ctx << 22) + 128 * (b / 4) + 4 * l + b % 4;
    };
    // A predicate transfer has one address, lane 0's base whether or not
    // lane 0 is active (O-62), and moves a predicate's word: every active
    // lane names it, so F-RO's lanes and a fault's are the issue mask's.
    // xfer-low-lane: the lowest active lane's base, the slot that moves
    // when a group splits.
    if (j.pxfer) {
      const unsigned bl = k_.brk == "xfer-low-lane" && j.active ? __builtin_ctz(j.active) : 0;
      // In the local form, warp-scoped: the formula's address with l = 0.
      const uint64_t a =
          local ? localAddr(uint64_t(disp), 0)
                : (uint64_t(getLane(am, c.rcu_miu, "base_per_lane", bl)) << (global ? 16 : 0)) +
                      uint64_t(disp);
      for (unsigned l = 0; l != kLanes; ++l)
        if ((j.active >> l) & 1u) j.addr[l] = a;
      j.pdata = getLane(am, c.rcu_miu, "store_data", 0);
    }
    for (unsigned l = 0; l != kLanes && !j.pxfer; ++l)
      if ((j.active >> l) & 1u && local) {
        j.addr[l] = localAddr(uint64_t(disp), l);
      } else if ((j.active >> l) & 1u) {
        const uint64_t b = from_win ? uint64_t(win_[cta].w[k])
                                    : uint64_t(getLane(am, c.rcu_miu, "base_per_lane", l));
        j.addr[l] = (b << (global ? 16 : 0)) +
                    (uint64_t(getLane(am, c.rcu_miu, "index_per_lane", l)) << sh) +
                    uint64_t(disp);
      }
    // Lines touched by ACTIVE lanes, in first-touch order; each lane moves
    // its data register's width (AR-24 (d): 4, 2 or 1 bytes from chwidth).
    // An inactive lane's address is never looked at. wide-xfer: every
    // access moves four bytes, as the 32-bit-only stubs did.
    const unsigned nb = k_.brk == "wide-xfer" ? 4u : spanOf(chw);
    j.bytes = nb;
    std::map<uint64_t, size_t> at;
    for (unsigned l = 0; l != kLanes; ++l) {
      if (!((j.active >> l) & 1u)) continue;
      // one-line: MIU takes the warp's access to lie in the line its first
      // active lane falls in, so the lanes past a line boundary are wrong.
      const uint64_t line =
          (k_.brk == "one-line" && !j.lines.empty() ? j.lines[0].line : j.addr[l]) / kLine * kLine;
      if (!at.count(line)) {
        at[line] = j.lines.size();
        j.lines.push_back({line, {}, {}, uint16_t(j.lines.size())});
      }
      if (j.store && !j.pxfer) {   // a predicate store's word lands at its drain's merge
        LineReq &lr = j.lines[at[line]];
        const uint32_t v = getLane(am, c.rcu_miu, "store_data", l);
        for (unsigned b = 0; b != nb; ++b) {
          const unsigned off = unsigned(j.addr[l] % kLine) + b;
          lr.data[off] = uint8_t(v >> (8 * b));
          lr.mask[off] = true;
        }
      }
    }
    // A load waits, and every memop behind it, while a store's write to one
    // of its lines is in flight: DCU would answer it from the line as it was.
    if (!j.store && inFlight(j, true)) return;
    // It also waits while an OLDER store of its warp to one of its lines
    // has not committed (MIU's disambiguation, MIU spec): this MIU forwards
    // nothing, so the load reads the line once the store's write has
    // landed. Memops issue in program order per warp (OI-15), so every
    // older store is already here; a younger one's write the load must not
    // see, and is not waited for (spinwait: lane 0's flag load behind lane
    // 1's store; AR's response TI-27 (d)).
    // no-st-wait: the load reads past the older store, and sees the flag
    // still clear.
    if (!j.store && k_.brk != "no-st-wait" && olderStore(j)) { k_.hit("st_ld_wait"); return; }
    if (j.active & ~issue)
      k_.fail("miu: rob tag %u has active lanes %08x outside its issue group",
              tag, j.active & ~issue);
    check(j, am);
    if (j.pxfer) k_.hit("pred_xfer");
    if (local) k_.hit("local_form");
    if (j.lines.size() > 1) k_.hit("line_split");
    // AR-23's measure: an access whose active lanes lie in more than one
    // 64 KiB window, as every O-30 frame access does.
    for (unsigned l = 0; l != kLanes; ++l)
      if ((j.active >> l & 1u) && j.addr[l] >> 16 != j.addr[__builtin_ctz(j.active)] >> 16)
        j.frame = true;
    k_.peak("lines_peak", j.lines.size());
    if (j.store)
      for (const LineReq &lr : j.lines)
        if (std::count(lr.mask.begin(), lr.mask.end(), true) != int(kLine)) k_.hit("partial_line");
    // F-ADDR (O-75): a .global address is the exact sum, never wrapped, and
    // one outside [0, 2^48) maps nothing; per lane, after F-ALIGN and before
    // F-RO, so where any lane has it, it is the instruction's cause (section
    // 12.5). addr-wrap: the sum taken modulo 2^48, so nothing faults.
    uint32_t bad = 0;
    for (unsigned l = 0; l != kLanes; ++l)
      if ((j.active >> l & 1u) && j.global && j.addr[l] >> ccv::kAddrBits && k_.brk != "addr-wrap")
        bad |= 1u << l;
    const uint32_t ro = bad ? 0u : roLanes(j, unsigned(get(mo.msg, c.ooe_miu, "cta_slot")));
    order_.pop_front();
    memop_.erase(tag);
    win_miss_.erase(tag);
    addr_.erase(a);
    if (bad) {
      // As F-RO's: no lane has any effect, and the completion is the fault,
      // with the lowest faulting lane's address in full (section 12.6).
      Bits m = cmpl(j);
      put(m, c.miu_ooe, "status", kCmplFault);
      put(m, c.miu_ooe, "cause", kFaultAddr);
      put(m, c.miu_ooe, "lane_mask", bad);
      put(m, c.miu_ooe, "address", j.addr[__builtin_ctz(bad)]);
      // A load's completion never comes before the L1 contract's cycle (A-46,
      // V-44), a fault's included: OOE would have woken nothing on it, and
      // takes an early one for a broken contract.
      if (!j.store && j.due > now_) late_faults_.push_back({j.due, {j.memop_slot, m, j.tid}});
      else to_ooe_.push_back({j.memop_slot, m, j.tid});
      k_.hit("addr_fault");
      return;
    }
    if (ro) {
      // F-RO: the store has no effect on any lane, so nothing waits for
      // retirement. The completion is the fault: its lanes, and the lowest
      // one's address (section 12.6). OOE takes it at retirement.
      Bits m = cmpl(j);
      put(m, c.miu_ooe, "status", kCmplFault);
      put(m, c.miu_ooe, "cause", kFaultRo);
      put(m, c.miu_ooe, "lane_mask", ro);
      put(m, c.miu_ooe, "address", j.addr[__builtin_ctz(ro)]);
      to_ooe_.push_back({j.memop_slot, m, j.tid});
      k_.hit("ro_fault");
      return;
    }
    if (j.store) {
      // Translated and checked; the write waits for retirement.
      stores_[tag] = j;
      to_ooe_.push_back({j.memop_slot, cmpl(j), j.tid});
      return;
    }
    launch(j);
  }

  void launch(Job j) {
    j.serial = ++serial_;
    jobs_.push_back(std::move(j));
  }

  /// Whether an uncommitted store older than load `j`, of its warp, touches
  /// one of its lines.
  bool olderStore(const Job &j) const {
    const uint32_t ls = uidSeq(j.tid);
    for (const auto &st : stores_) {
      const uint32_t ss = uidSeq(st.second.tid);
      if (seqWarp(ss) != seqWarp(ls) || seqIndex(ss) >= seqIndex(ls)) continue;
      for (const LineReq &a : st.second.lines)
        for (const LineReq &b : j.lines)
          if (a.line == b.line) return true;
    }
    return false;
  }

  /// Whether a job in flight, any or only a store's write, touches one of
  /// `j`'s lines.
  bool inFlight(const Job &j, bool stores_only) const {
    for (const Job &f : jobs_)
      if (!stores_only || f.store)
        for (const LineReq &a : f.lines)
          for (const LineReq &b : j.lines)
            if (a.line == b.line) return true;
    return false;
  }

  /// The addresses and store data MIU computed from what it was SENT, against
  /// what ccv-sim says the instruction accessed.
  void check(const Job &j, const Bits &am) {
    const Record *r = rec(j.tid, "miu");
    if (!r) return;
    if (j.pxfer) {
      // One word per uop (TI-36): its address, and a store's data, which is
      // the predicate's 32 bits. The word it writes, merged, is checked at
      // the drain; the one a load reads, where it lands.
      const MemAcc *a = xferAcc(r, j.tid);
      if (!a || !j.active) {
        if (!a) k_.fail("miu: seq %llu uop %u has no predicate word in ccv-sim's record",
                        (unsigned long long)r->seq, unsigned(uidSub(j.tid)));
        return;
      }
      const uint64_t at = j.addr[__builtin_ctz(j.active)];
      if (a->addr != at || a->bytes != 4)
        k_.fail("miu: seq %llu uop %u address %llx, oracle %llx", (unsigned long long)r->seq,
                unsigned(uidSub(j.tid)), (unsigned long long)at, (unsigned long long)a->addr);
      if (j.store) {
        const unsigned p = r->xferPred(uidSub(j.tid));
        for (const RegVal &u : r->uses)
          if (u.pred && u.idx == p && u.p != j.pdata)
            k_.fail("miu: seq %llu P%u's word %08x, oracle %08x", (unsigned long long)r->seq, p,
                    j.pdata, u.p);
      }
      return;
    }
    uint32_t lanes = 0;
    for (const MemAcc &a : r->mem) lanes |= 1u << a.lane;
    if (lanes != j.active || r->store != j.store) {
      k_.fail("miu: seq %llu active_mask %08x, but ccv-sim's %s touched lanes %08x",
              (unsigned long long)r->seq, j.active, r->store ? "store" : "load", lanes);
      return;
    }
    for (const MemAcc &a : r->mem) {
      if (a.addr != j.addr[a.lane] || a.shared)
        k_.fail("miu: seq %llu lane %u address %llx, oracle %llx",
                (unsigned long long)r->seq, a.lane,
                (unsigned long long)j.addr[a.lane], (unsigned long long)a.addr);
      else if (a.bytes != j.bytes)
        k_.fail("miu: seq %llu lane %u moves %u bytes, oracle %u", (unsigned long long)r->seq,
                a.lane, j.bytes, a.bytes);
      // A narrow store sends its register's row; only its element is data.
      const uint32_t bm = j.bytes == 4 ? ~0u : (1u << (8 * j.bytes)) - 1;
      if (j.store && r->kind != "fault" &&
          (getLane(am, ch().rcu_miu, "store_data", a.lane) & bm) != (a.val & bm))
        k_.fail("miu: seq %llu lane %u store data %08x, oracle %08x",
                (unsigned long long)r->seq, a.lane,
                getLane(am, ch().rcu_miu, "store_data", a.lane) & bm, a.val & bm);
    }
  }

  Bits cmpl(const Job &j) {
    const Ch &c = ch();
    Bits m = msgOf(c.miu_ooe);
    put(m, c.miu_ooe, "rob_tag", j.tag);
    // The RS entry, echoed from the memop as phys_dst is to RCU, so MIU holds
    // no table of it and OOE wakes the entry with no lookup (OA-23).
    put(m, c.miu_ooe, "rs_idx", k_.brk == "rs-echo" ? j.rs_idx ^ 1u : j.rs_idx);
    put(m, c.miu_ooe, "lane_mask", j.active);
    for (unsigned l = 0; l != kLanes; ++l)
      if ((j.active >> l) & 1u) { put(m, c.miu_ooe, "address", j.addr[l]); break; }
    put(m, c.miu_ooe, "mlc_miss", j.mlc_miss ? 1 : 0);
    return m;
  }

  /// A whole crossing of a channel: CCV_LAT_HOP plus its repeater stages.
  static unsigned crossing(unsigned chan) {
    for (const ChanInst &ci : kChanInsts)
      if (ci.chan == chan) return kLatHop + ci.stages;
    return kLatHop;
  }

  void advance() {
    const Ch &c = ch();
    const unsigned rate = kChans[c.miu_dcu].rate;
    // Up to one line request per DCU slot per cycle, the oldest job's first.
    bool want = false;
    for (const Job &j : jobs_) want = want || j.next != j.lines.size();
    if (want && !ids_.any()) k_.hit("dcu_id_wait");
    unsigned s = 0;
    for (Job &job_ : jobs_)
    for (; s != rate && job_.next != job_.lines.size(); ++s) {
      if (!can(c.miu_dcu, s) || !ids_.any()) continue;
      const LineReq &lr = job_.lines[job_.next++];
      Bits r = msgOf(c.miu_dcu);
      const unsigned id = ids_.take();
      put(r, c.miu_dcu, "req_id", id);
      put(r, c.miu_dcu, "phys_addr", lr.line);
      put(r, c.miu_dcu, "size", kSizeLine);
      const bool wr = job_.store && job_.rmw != 1;   // a drain's read first
      put(r, c.miu_dcu, "coh_op", wr ? kCohWrite : kCohRead);
      if (wr) {
        putLine(r, field(c.miu_dcu, "write_data").lsb, lr.data);
        const uint32_t mlsb = field(c.miu_dcu, "byte_mask").lsb;
        for (unsigned k = 0; k != kLine; ++k) r.setBit(mlsb + k, lr.mask[k]);
      }
      const uint64_t tid =
          makeUid(IdClass::kTxn, uidSeq(job_.tid), lr.sub, /*owned=*/true);
      send(c.miu_dcu, s, r, tid);
      outstanding_[id] = {job_.serial, lr.line};
      k_.hit("dcu_lookups");
      if (job_.frame) k_.hit("frame_lookups");
    }
    for (auto it = jobs_.begin(); it != jobs_.end();) {
      if (it->back != it->lines.size()) { ++it; continue; }
      if (it->rmw == 1) { merge(*it); ++it; continue; }
      if (!it->store) complete(*it);
      it = jobs_.erase(it);
    }
  }

  /// A predicate store's drain, its line read: the word merged under its
  /// mask, new = (old & ~m) | (d & m), and held to ccv-sim's; then written.
  /// m is active_mask, the issue mask (st.pred has no guard). The line stays
  /// in flight from the read to the write, so nothing reaches it between.
  /// stpred-whole-word: every lane's bit stored, the group's or not.
  void merge(Job &j) {
    LineReq &lr = j.lines[0];
    const uint64_t a = j.addr[__builtin_ctz(j.active)];
    const unsigned off = unsigned(a % kLine);
    const Line &old_line = j.got.at(lr.line);
    uint32_t old = 0;
    for (unsigned b = 0; b != 4; ++b) old |= uint32_t(old_line[off + b]) << (8 * b);
    const uint32_t m = k_.brk == "stpred-whole-word" ? ~0u : j.active;
    const uint32_t v = (old & ~m) | (j.pdata & m);
    if (const MemAcc *o = xferAcc(rec(j.tid, "miu"), j.tid))
      if (o->val != v)
        k_.fail("miu: seq %llu P%u merged %08x into %llx, oracle %08x",
                (unsigned long long)uidSeq(j.tid),
                rec(j.tid, "miu")->xferPred(uidSub(j.tid)), v, (unsigned long long)a, o->val);
    for (unsigned b = 0; b != 4; ++b) {
      lr.data[off + b] = uint8_t(v >> (8 * b));
      lr.mask[off + b] = true;
    }
    k_.hit("pred_merge");
    j.rmw = 2;
    j.next = j.back = 0;
    j.got.clear();
  }

  /// A load with every line back: its data to RCU and its completion to OOE,
  /// at the L1 contract if every line hit in time, else as a miss.
  void complete(const Job &job_) {
    const Ch &c = ch();
    {
      Bits d = msgOf(c.miu_rcu);
      put(d, c.miu_rcu, "rob_tag", job_.tag);
      put(d, c.miu_rcu, "active_mask", job_.active);
      put(d, c.miu_rcu, "phys_dst",
          job_.phys_dst + (k_.brk == "corrupt-echo" && uidSeq(job_.tid) == 12 ? 1u : 0u));
      put(d, c.miu_rcu, "dst_pos", job_.dst_pos);
      put(d, c.miu_rcu, "dst_width", job_.chw);
      put(d, c.miu_rcu, "phys_pred", job_.phys_pred);
      put(d, c.miu_rcu, "pred_we", 0);          // a load writes no predicate
      const Record *r = rec(job_.tid, "miu");
      if (job_.pxfer && job_.active) {
        // A predicate load (TI-36): its word is the predicate, lane i's bit
        // for lane i, written by RCU under active_mask (O-62), the copy op
        // writing the rest. No GPR: phys_dst is the zero register.
        // ldpred-whole-word: every lane's bit written, the group's or not.
        const uint64_t a = job_.addr[__builtin_ctz(job_.active)];
        const Line &ln = job_.got.at(a / kLine * kLine);
        uint32_t v = 0;
        for (unsigned b = 0; b != 4; ++b) v |= uint32_t(ln[a % kLine + b]) << (8 * b);
        if (const MemAcc *o = xferAcc(r, job_.tid))
          if (o->val != v)
            k_.fail("miu: seq %llu P%u loaded %08x from %llx, oracle %08x",
                    (unsigned long long)uidSeq(job_.tid), r->xferPred(uidSub(job_.tid)), v,
                    (unsigned long long)a, o->val);
        put(d, c.miu_rcu, "pred_we", 1);
        put(d, c.miu_rcu, "pred_result", v);
        put(d, c.miu_rcu, "phys_dst", ccv::prov::kPhysZero);   // no GPR: RCU writes none
        if (k_.brk == "ldpred-whole-word") put(d, c.miu_rcu, "active_mask", ~0u);
      }
      for (unsigned l = 0; l != kLanes && !job_.pxfer; ++l) {
        if (!((job_.active >> l) & 1u)) continue;
        const Line &ln = job_.got.at(k_.brk == "one-line" ? job_.lines[0].line
                                                          : job_.addr[l] / kLine * kLine);
        const unsigned off = unsigned(job_.addr[l] % kLine);
        uint32_t v = 0;
        for (unsigned b = 0; b != job_.bytes; ++b) v |= uint32_t(ln[off + b]) << (8 * b);
        // What came back from memory, against what ccv-sim loaded.
        if (r)
          for (const MemAcc &a : r->mem)
            if (a.lane == l && a.val != v)
              k_.fail("miu: seq %llu lane %u loaded %08x, oracle %08x",
                      (unsigned long long)r->seq, l, v, a.val);
        if (k_.brk == "corrupt-load" && r && r->seq == 13 && l == 5) v ^= 1;
        putLane(d, c.miu_rcu, "load_data", l, v);
      }
      if (job_.promised) {
        // Hinted: the completion and its data leave now, on the credits held
        // back for them, or the promise is broken and the bank says so.
        --resv_[{c.miu_ooe, job_.memop_slot}];
        --resv_[{c.miu_rcu, job_.addr_slot}];
        if (now_ != job_.promised)
          k_.fail("miu: rob tag %u's hinted completion due at cycle %llu is ready at %llu",
                  job_.tag, (unsigned long long)job_.promised, (unsigned long long)now_);
        if (k_.brk == "late-cmpl") {
          // The hinted completion a cycle after its promise, with its data.
          timed_.push_back({now_ + 1, {job_.addr_slot, d, job_.tid},
                            {job_.memop_slot, cmpl(job_), job_.tid}});
        } else if (now_ == job_.promised && can(c.miu_ooe, job_.memop_slot) &&
                   can(c.miu_rcu, job_.addr_slot)) {
          send(c.miu_ooe, job_.memop_slot, cmpl(job_), job_.tid);
          send(c.miu_rcu, job_.addr_slot, d, job_.tid);
        } else {
          to_rcu_.push_back({job_.addr_slot, d, job_.tid});
          to_ooe_.push_back({job_.memop_slot, cmpl(job_), job_.tid});
        }
      } else if (job_.hit && job_.global && now_ <= job_.due) {
        timed_.push_back({job_.due, {job_.addr_slot, d, job_.tid},
                          {job_.memop_slot, cmpl(job_), job_.tid}});
      } else {
        if (job_.hit) k_.hit("l1_late");
        to_rcu_.push_back({job_.addr_slot, d, job_.tid});
        to_ooe_.push_back({job_.memop_slot, cmpl(job_), job_.tid});
      }
    }
  }

  bool busy() const override {
    return !jobs_.empty() || !late_faults_.empty() || !order_.empty() || !stores_.empty() || !timed_.empty() ||
           !hints_.empty() || !orphan_.empty() || !to_rau_.empty() ||
           !committed_.empty() || !to_rcu_.empty() || !to_ooe_.empty() ||
           !to_dcu_.empty() || !to_fet_.empty();
  }
};

// ---- LANE: one of 32; operands in, oracle result out ------------------------------

// Sectioned lanes (OI-28 to OI-31, TI-9): ccv_rcu_lane_ops is one message a
// cycle, and up to four ops share it, each in its own sections. The
// per-section fields pack section 0 at the LSBs. The per-port ones
// (sec_opnd_pos, sec_opnd_width, operand_byp) pack a section's four ports
// together, the three operands then merge_data, so entry k * kBypOperands + i
// is section k's port i. sec_owner names, per section, the lead section of
// the op holding it (TI-10). The S1 stubs model full-width ops only: one op
// a message, holding every section, owned by S0.
constexpr unsigned kBypOperands = ccv::prelim::kOperandsPerLane + 1;
constexpr unsigned kBypMerge = ccv::prelim::kOperandsPerLane;
constexpr unsigned clog2c(unsigned x) { return x <= 1 ? 0 : 1 + clog2c((x + 1) / 2); }
/// The lane-local bypass select (A-59, TI-8): LSB first, forward, the
/// producer's lead section, and its age less CCV_LAT_LANE_BYP.
constexpr unsigned kBypSecBits = clog2c(kSecs);
static_assert(ccv::prov::kWLaneBypSel == 1 + kBypSecBits + ccv::prov::kWLaneBypAge,
              "operand_byp's layout is forward, lead section, age");
constexpr unsigned kAllSecs = (1u << kSecs) - 1;

/// Entry `k`, `w` bits wide, of a per-section (or per-section-per-port) field.
inline unsigned getSec(const Bits &b, unsigned chan, const char *f, unsigned k, unsigned w) {
  return unsigned(b.get(field(chan, f).lsb + w * k, w));
}
inline void putSec(Bits &b, unsigned chan, const char *f, unsigned k, unsigned w, unsigned v) {
  b.set(field(chan, f).lsb + w * k, w, v);
}

class Lane : public Stub {
public:
  Lane(int inst, Kernel &k) : Stub(inst, k), lane_(kBlkInsts[inst].index) {}
  const char *kind() const override { return "lane"; }

private:
  /// The lane pipeline: a result leaves kPipe cycles after its operands
  /// arrive, so it lands in RCU's PRF CCV_LAT_LANE - 1 cycles after RCU took
  /// the issue: the cycle before a dependant woken at the full latency reads
  /// it (V-35). Stages on either lane channel add to CCV_LAT_LANE, not here.
  static constexpr unsigned kPipe = ccv::prov::kLatLaneBase - 1 - 2 * kLatHop;
  static_assert(ccv::prov::kLatLaneBase >= 1 + 2 * kLatHop, "no room for the lane pipeline");
  static_assert(ccv::prov::kLatLaneByp >= kPipe,
                "a dependant at CCV_LAT_LANE_BYP would arrive before its producer's result");

  struct Out { Bits msg; uint64_t tid, at; };
  /// This lane's results by arrival cycle, with the lead section of the op
  /// that held each section (-1: none): what its bypass mux can forward,
  /// kept until RCU's register file holds them (A-59).
  struct Res { uint64_t at; std::array<int, kSecs> lead; uint32_t v; };

  unsigned lane_;
  std::deque<Out> q_;
  std::deque<Res> hist_;

  /// Port i, or merge_data for kBypMerge, section by section: the byte RCU
  /// read or, with that section's operand_byp select set, the byte this lane
  /// computed for the op the select names by lead section, `age` cycles
  /// before this message arrived.
  uint32_t operand(const Receiver::Msg &m, unsigned i, uint64_t seq) {
    const Ch &c = ch();
    uint32_t v = i == kBypMerge
                     ? uint32_t(get(m.payload, c.rcu_lane, "merge_data"))
                     : uint32_t(m.payload.get(field(c.rcu_lane, "operand").lsb + 32 * i, 32));
    for (unsigned k = 0; k != kSecs; ++k) {
      const unsigned sel = getSec(m.payload, c.rcu_lane, "operand_byp", k * kBypOperands + i,
                                  ccv::prov::kWLaneBypSel);
      if (!(sel & 1u)) continue;
      const unsigned lead = (sel >> 1) & ((1u << kBypSecBits) - 1);
      const unsigned age = (sel >> (1 + kBypSecBits)) + ccv::prov::kLatLaneByp;
      const Res *h = nullptr;
      for (const Res &r : hist_)
        if (r.at + age == now_ && r.lead[k] == int(lead)) h = &r;
      if (!h) {
        k_.fail("lane %u: seq %llu operand %u section %u forwards the op led by section %u "
                "from %u cycles back, where nothing arrived",
                lane_, (unsigned long long)seq, i, k, lead, age);
        continue;
      }
      const uint32_t byte = 0xffu << (8 * k);
      v = (v & ~byte) | (h->v & byte);
    }
    return v;
  }

  void work() override {
    const Ch &c = ch();
    while (!hist_.empty() && hist_.front().at + ccv::prov::kLatLane <= now_) hist_.pop_front();
    while (has(c.rcu_lane, 0, lane_)) {
      Receiver::Msg m = take(c.rcu_lane, 0, lane_);
      Bits r = msgOf(c.lane_rcu);
      const unsigned en = unsigned(get(m.payload, c.rcu_lane, "section_en"));
      const unsigned own = unsigned(get(m.payload, c.rcu_lane, "sec_owner"));
      Res h{now_, {}, 0};
      h.lead.fill(-1);
      if (en != kAllSecs || own != 0) {
        k_.fail("lane %u: sections %x owned %02x; only a full-width op is modelled in the S1 "
                "stubs", lane_, en, own);
      } else {
        h.lead.fill(0);
        execute(m, r);
        // Every section the op held has its result here; a full-width op's
        // predicate out rides on its lead section.
        put(r, c.lane_rcu, "sec_valid", en);
      }
      h.v = uint32_t(get(r, c.lane_rcu, "result"));
      // The copy-only op writes only inactive lanes and is never a producer.
      if (getSec(m.payload, c.rcu_lane, "sec_opcode", 0, ccv::prelim::kWOpcode) != kOpCopy)
        hist_.push_back(h);
      q_.push_back({r, m.tid, now_ + kPipe});
    }
    if (!q_.empty() && q_.front().at <= now_ && can(c.lane_rcu, 0, lane_)) {
      send(c.lane_rcu, 0, q_.front().msg, q_.front().tid, lane_);
      q_.pop_front();
    }
  }
  bool busy() const override { return !q_.empty(); }

  /// A full-width op: one opcode, one enable and one predicate-as-data, the
  /// same in every section, and each operand a 32-bit register at position 0.
  void execute(const Receiver::Msg &m, Bits &r) {
    const Ch &c = ch();
    const unsigned opc = getSec(m.payload, c.rcu_lane, "sec_opcode", 0, ccv::prelim::kWOpcode);
    const unsigned pb = unsigned(get(m.payload, c.rcu_lane, "sec_pred_bit"));
    const unsigned pdv = unsigned(get(m.payload, c.rcu_lane, "sec_pred_data"));
    bool uniform = (pb == 0 || pb == kAllSecs) && (pdv == 0 || pdv == kAllSecs);
    for (unsigned k = 1; k != kSecs; ++k)
      uniform = uniform &&
                getSec(m.payload, c.rcu_lane, "sec_opcode", k, ccv::prelim::kWOpcode) == opc;
    // A narrow operand or destination is a full row at position 0 (AR-24's
    // interim): its width code is semantics, and the result ccv-sim's.
    for (unsigned i = 0; i != kBypOperands; ++i)
      uniform = uniform && getSec(m.payload, c.rcu_lane, "sec_opnd_pos", i, ccv::kWPhysPos) == 0;
    uniform = uniform && getSec(m.payload, c.rcu_lane, "sec_dst_pos", 0, ccv::kWPhysPos) == 0;
    if (!uniform) {
      k_.fail("lane %u: a full-width op whose sections, operands or destination disagree",
              lane_);
      return;
    }
    // The enable arrived with valid, a cycle ahead of the operands (the
    // channel's lead fields, Q-40). A lane it switches off does nothing:
    // it never captures its operands, never computes, and drives no result
    // -- modelled as poison on its outputs, so a receiver that wrote back a
    // masked-off lane would be caught by the final compare.
    const bool on = pb != 0;
    if (opc == kOpCopy) {
      copy(m, r, on);
      return;
    }
    const Record *rc = rec(m.tid, "lane");
    if (!rc) return;
    const std::string at = "lane " + std::to_string(lane_);
    k_.executing(at, m.tid);
    const OpInfo *op = opByCode(opc);
    if (op && execRcu(op))
      k_.fail("lane %u: %s reached a lane; it executes in RCU", lane_, op->name);
    if (op && !perLaneInput(op, *rc))
      k_.fail("lane %u: %s has no per-lane input; RCU executes it (Q-32)", lane_, op->name);
    if (!op || rc->op != op->name)
      k_.fail("lane %u: seq %llu opcode is not %s", lane_, (unsigned long long)rc->seq,
              rc->op.c_str());
    // Operands: what RCU read out of its register file, each against the
    // record's value of the register it names (srcRegs: folded repeats,
    // listed-but-unread fields; AR-24). A register the record lists no use
    // of (chwidth.multi's) is not checked.
    bool g_ok = true;
    const unsigned sub = uidSub(m.tid);
    const std::vector<unsigned> g = op ? srcRegs(op, *rc, sub, g_ok) : std::vector<unsigned>{};
    auto useOf = [&](unsigned idx) -> const RegVal * {
      for (const RegVal *u : rc->gprUses()) if (u->idx == idx) return u;
      return nullptr;
    };
    // Each is compared within its register's width, the record's, and its
    // width code is held to it (AR-24 (d)): ccv-sim keeps the bits above a
    // narrow element as the slice last held them, and the row holds zeros.
    for (size_t i = 0; on && i != g.size() && i < 3; ++i) {
      const RegVal *u = useOf(g[i]);
      if (!u) continue;
      const unsigned w = rc->widthOf(u->idx);
      const unsigned ow = getSec(m.payload, c.rcu_lane, "sec_opnd_width", unsigned(i), ccv::kWChwidth);
      if (ow != w)
        k_.failHeld(at, m.tid, "lane %u: seq %llu operand %zu (R%u) at width code %u, the record's %u",
                    lane_, (unsigned long long)rc->seq, i, u->idx, ow, w);
      const uint32_t em = elemMask(w);
      const uint32_t got = operand(m, unsigned(i), rc->seq);
      if ((got & em) != (u->v[lane_] & em))
        k_.failHeld(at, m.tid, "lane %u: seq %llu operand %zu (R%u) %08x, oracle %08x", lane_,
                    (unsigned long long)rc->seq, i, u->idx, got & em, u->v[lane_] & em);
    }
    // A chwidth's destination is its register (uop k of chwidth.multi: the
    // mask's k-th), and its def is that register's, if the value changed.
    const RegVal *gdef = op && op->chw ? rc->gprDefOf(g.empty() ? 0u : g[0]) : rc->gprDef();
    // An immediate RCU substituted into its operand slot. srd's is
    // identity from OOE rather than the encoded selector, and its
    // check is the lane's own result check below.
    if (on && op && op->alu_imm >= 0 && op->srd_sel < 0 && size_t(op->alu_imm) < rc->imms.size()) {
      const uint32_t got = uint32_t(
          m.payload.get(field(c.rcu_lane, "operand").lsb + 32 * unsigned(op->imm_slot), 32));
      if (got != uint32_t(rc->imms[op->alu_imm]))
        k_.fail("lane %u: seq %llu immediate operand %08x, oracle %08x", lane_,
                (unsigned long long)rc->seq, got, uint32_t(rc->imms[op->alu_imm]));
    }
    // sec_pred_bit is this lane's enable: in the issue group AND past the
    // guard. Without a guard it is the issue mask alone.
    bool want = (rc->mask >> lane_) & 1u;
    if (op && op->guard)
      if (const RegVal *p = rc->predUse()) {
        const bool neg = !rc->quals.empty() && ((rc->quals[0] >> 2) & 1);
        want = want && ((((p->p >> lane_) & 1u) != 0) != neg);
      }
    if (on != want)
      k_.failHeld(at, m.tid, "lane %u: seq %llu pred_bit is not issue mask AND guard", lane_,
                  (unsigned long long)rc->seq);
    // The result: what ccv-sim computed (the "what", §1) -- except srd's,
    // which the lane computes: the immediate RCU substituted, with the
    // lane's hardwired index ORed in for %ctatid. OOE's identity, not the
    // oracle, supplies the value.
    if (!on) {
      // Switched off: no compute; the result is the old destination RCU
      // carried here (A-33, A-44). The oracle's post-state for an inactive
      // lane IS its old value, so the merge is checked here.
      const uint32_t md = operand(m, kBypMerge, rc->seq);
      put(r, c.lane_rcu, "result", md);
      if (const RegVal *d = gdef) {
        const uint32_t em = elemMask(rc->widthOf(d->idx));
        if ((md & em) != (d->v[lane_] & em))
          k_.failHeld(at, m.tid, "lane %u: seq %llu merge_data %08x, but R%u keeps %08x", lane_,
                      (unsigned long long)rc->seq, md & em, d->idx, d->v[lane_] & em);
      }
      // sec_pred_out is don't-care here (RCU merges predicates): poison.
      if (const RegVal *d = rc->predDef())
        put(r, c.lane_rcu, "sec_pred_out", ((d->p >> lane_) & 1u) ^ 1u);
    } else if (op && op->chw) {
      // A chwidth: the register's row as read, kept within its new width.
      // A widening must find the row already zero above the old element,
      // since every narrow write zero-extends (O-38): ccv-sim's widened
      // value is zero there, so a bit left behind fails here.
      // The new width is the instruction's (its immediate, as the record
      // has it), not OOE's dst_width, which names the old one (OI, AR-24).
      const size_t wi = op->chw == 2 ? 1 : 0;
      const unsigned nw = wi < rc->imms.size() ? unsigned(rc->imms[wi]) & 3u : kChw32;
      const uint32_t v = operand(m, 0, rc->seq) & elemMask(nw);
      if (const RegVal *d = gdef)
        if (v != (d->v[lane_] & elemMask(nw)))
          k_.failHeld(at, m.tid, "lane %u: seq %llu chwidth R%u to width code %u reads %08x, oracle %08x",
                      lane_, (unsigned long long)rc->seq, d->idx, nw, v, d->v[lane_] & elemMask(nw));
      put(r, c.lane_rcu, "result", v);
    } else if (const RegVal *d = gdef) {
      // A narrow destination is written zero-extended at its width code
      // (AR-24's interim on a full row), held to the record's width.
      const unsigned dw = unsigned(get(m.payload, c.rcu_lane, "sec_dst_width"));
      if (dw != rc->widthOf(d->idx))
        k_.failHeld(at, m.tid, "lane %u: seq %llu R%u written at width code %u, the record's %u", lane_,
                    (unsigned long long)rc->seq, d->idx, dw, rc->widthOf(d->idx));
      // lane-unmasked: ccv-sim's value as recorded, the slice's old bits
      // above the element and all, for the widening to find.
      const uint32_t dm = k_.brk == "lane-unmasked" ? ~0u : elemMask(dw);
      uint32_t v = d->v[lane_] & dm;
      // The lane wraps a narrow add or subtract itself, at its width (the
      // operands as they came, an immediate in its slot): the result is the
      // lane's, held to ccv-sim's. narrow-carry: the sum not wrapped, its
      // carry left above the element, for the widening to find.
      if (dm != ~0u && op && arithSign(op)) {
        const uint32_t a0 = operand(m, 0, rc->seq), a1 = operand(m, 1, rc->seq);
        const uint32_t full = arithSign(op) > 0 ? a0 + a1 : a0 - a1;
        if ((full & dm) != v)
          k_.failHeld(at, m.tid, "lane %u: seq %llu %s at width code %u gives %08x, oracle %08x", lane_,
                      (unsigned long long)rc->seq, op->name, dw, full & dm, v);
        v = k_.brk == "narrow-carry" ? full : full & dm;
        k_.hit("narrow_arith");
      }
      if (op && op->srd_sel >= 0) {
        const uint32_t o0 = operand(m, 0, rc->seq);
        v = op->or_lane ? (o0 | lane_) : o0;
        if (v != d->v[lane_])
          k_.fail("lane %u: seq %llu srd %u, oracle %u", lane_, (unsigned long long)rc->seq, v,
                  d->v[lane_]);
      }
      put(r, c.lane_rcu, "result", v);
    }
    if (on)
      if (const RegVal *d = rc->predDef())
        put(r, c.lane_rcu, "sec_pred_out", (d->p >> lane_) & 1u);
    // A predicate read as DATA (sel's selector), negate applied.
    if (on && op && op->pdata)
      if (const RegVal *p = rc->predUse()) {
        const bool neg = !rc->quals.empty() && ((rc->quals[0] >> 2) & 1);
        const bool want = (((p->p >> lane_) & 1u) != 0) != neg;
        if ((pdv != 0) != want)
          k_.failHeld(at, m.tid, "lane %u: seq %llu pred_data (sel's selector) wrong", lane_,
                      (unsigned long long)rc->seq);
      }
  }

  /// The copy-only op (A-38): no compute. An inactive lane returns
  /// merge_data, the masked load's old destination, which is what ccv-sim
  /// says the lane keeps; an enabled lane's result is don't-care, driven as
  /// poison, since RCU writes only the inactive lanes.
  void copy(const Receiver::Msg &m, Bits &r, bool on) {
    const Ch &c = ch();
    const Record *rc = rec(m.tid, "lane");
    if (!rc) return;
    const OpInfo *op = opByName(rc->op);
    if (!op || op->cls != kLoad) {
      k_.fail("lane %u: a copy-only op for seq %llu, which is not a load", lane_,
              (unsigned long long)rc->seq);
      return;
    }
    bool want = (rc->mask >> lane_) & 1u;
    if (op->guard)
      if (const RegVal *p = rc->predUse()) {
        const bool neg = !rc->quals.empty() && ((rc->quals[0] >> 2) & 1);
        want = want && ((((p->p >> lane_) & 1u) != 0) != neg);
      }
    if (on != want)
      k_.fail("lane %u: seq %llu's copy has pred_bit %u, not the load's enable", lane_,
              (unsigned long long)rc->seq, unsigned(on));
    const uint32_t md = operand(m, kBypMerge, rc->seq);
    if (!on)
      if (const RegVal *d = rc->gprDef())
        if (md != d->v[lane_])
          k_.fail("lane %u: seq %llu's copy carries %08x, but R%u keeps %08x", lane_,
                  (unsigned long long)rc->seq, md, d->idx, d->v[lane_]);
    put(r, c.lane_rcu, "result", on ? 0xbad0c0deu ^ lane_ : md);
  }
};

// ---- RCU: the register file ----------------------------------------------------------

class Rcu : public Stub {
public:
  Rcu(int inst, Kernel &k) : Stub(inst, k) {
    // A register file comes up holding garbage: each physical GPR a distinct
    // pattern, so a read of one nothing wrote -- a missed merge or copy, a
    // rename that skipped the zero register -- cannot pass by reading zero.
    // The zero registers read zero (A-64).
    k.gpr.assign(256, {});
    for (unsigned p = 0; p != ccv::prov::kPhysRegs; ++p)
      for (unsigned l = 0; l != kLanes; ++l) k.gpr[p][l] = 0xdead0000u | p << 5 | l;
    k.pred.assign(256, 0);
    // A restore's rows wait until the warp's map is here (TI-13).
    holdsBack(ch().pca_rcu);
  }
  const char *kind() const override { return "rcu"; }

private:
  static constexpr unsigned kRes = ccv::kIssueResources;

  struct Alu {
    unsigned tag; const OpInfo *op; unsigned pdst, ppred; bool pwe;
    uint32_t active; uint64_t tid;
    bool merge; unsigned ppold;   ///< predicate merge source (A-43)
    bool copy = false;            ///< the copy-only op (A-38): op is null
    uint64_t accepted = 0;        ///< the cycle RCU took the issue
    uint64_t serial = 0;          ///< its key in wr_
    unsigned foot = kAllSecs;     ///< the sections it holds
  };
  /// One op's 32 lane messages, held until every lane has a credit, and
  /// which of its operands were read from a register a lane op in flight
  /// has yet to write (wr_): the lanes forward those (A-59).
  struct LaneOp {
    std::vector<Bits> lanes; Alu alu; uint64_t not_before = 0;
    std::array<int, kBypOperands> from_reg;       ///< -1: read from the PRF
    std::array<uint64_t, kBypOperands> from{};    ///< the producer's serial
    LaneOp(std::vector<Bits> l, const Alu &a, uint64_t nb = 0)
        : lanes(std::move(l)), alu(a), not_before(nb) { from_reg.fill(-1); }
  };
  /// A lane op in flight that writes a GPR, from RCU taking its issue until
  /// its results land, by destination. A dependant OOE woke at
  /// CCV_LAT_LANE_BYP reads a register named here, before the write: RCU
  /// names the producer's lead section and age in operand_byp and the lane
  /// forwards its own result (A-59, TI-8). RCU needs the destinations only.
  struct Writer { uint64_t serial; unsigned lead; uint64_t sent = ~0ull; };

  std::deque<LaneOp> lane_q_;   ///< accepted, not yet sent to the lanes
  std::deque<Alu> alu_;         ///< sent to the lanes, in the order they answer
  std::deque<Q> to_ooe_, to_miu_;
  std::map<unsigned, Writer> wr_;
  uint64_t serial_ = 0;

  Bits done(unsigned tag) {
    Bits d = msgOf(ch().rcu_ooe);
    put(d, ch().rcu_ooe, "rob_tag", tag);
    return d;
  }
  /// The first slot of slot s's resource group: S0, P0 or R.
  static unsigned groupOf(unsigned s) {
    return s < kSlotP0 ? kSlotS0 : s < kSlotR ? kSlotP0 : kSlotR;
  }
  /// Slot s by its resource's name, and a footprint as S3..S0 (or P3..P0).
  static std::string res(unsigned s) {
    return s == kSlotR ? "R" : (s < kSlotP0 ? "S" : "P") + std::to_string(s - groupOf(s));
  }
  static std::string bits(unsigned f) {
    std::string b;
    for (unsigned k = kSecs; k-- != 0;) b += (f >> k) & 1u ? '1' : '0';
    return b;
  }

  /// Migration (TI-24; A-45): ccv_ooe_rcu_map and ccv_rau_rcu_mig, paired
  /// by warp and direction in either order.
  ///
  /// Out: the warp's rows to PCA one a cycle, one per architectural
  /// register, Ra as mig_row a, with no merging (TI-25 (1)); the zero
  /// register reads zero. The predicate row goes last,
  /// mig_row CCV_GPRS, its four predicates 32 bits each from bit 0, so PCA
  /// knows the transfer is whole when it lands (TI-24 (4)).
  ///
  /// In: PCA's rows, taken only once the warp's restore map and command are
  /// both here (until then they wait in their slot, credits held), each
  /// written as it is taken (TI-13): row a into the register the restore map
  /// names for Ra, the predicate row into its four predicates.
  struct MigReq { bool map = false, cmd = false, armed = false; std::vector<unsigned> gpr, pred; };
  std::map<std::pair<unsigned, unsigned>, MigReq> mig_;   ///< (warp, direction)
  std::deque<std::pair<unsigned, Bits>> rows_out_;        ///< warp, row message
  std::set<unsigned> unwritten_, unwritten_p_;            ///< a restore's rows and predicates, until written

  void migrate() {
    const Ch &c = ch();
    if (has(c.ooe_map, 0)) {
      const Bits m = take(c.ooe_map, 0).payload;
      const unsigned w = unsigned(get(m, c.ooe_map, "warp_id"));
      const unsigned dir = unsigned(get(m, c.ooe_map, "direction"));
      MigReq &q = mig_[{w, dir}];
      const FieldDesc &gm = field(c.ooe_map, "gpr_map"), &pm = field(c.ooe_map, "pred_map");
      const unsigned gw = gm.width / kArchGprs, pw = pm.width / kArchPreds;
      q.gpr.clear();
      q.pred.clear();
      for (unsigned a = 0; a != kArchGprs; ++a) q.gpr.push_back(unsigned(m.get(gm.lsb + a * gw, gw)));
      for (unsigned p = 0; p != kArchPreds; ++p) q.pred.push_back(unsigned(m.get(pm.lsb + p * pw, pw)));
      q.map = true;
      if (dir == 1)
        for (unsigned a = 0; a != kArchGprs; ++a) {
          if (q.gpr[a] == ccv::prov::kPhysZero)
            k_.fail("rcu: warp %u's restore map names the zero register (A-64)", w);
          // Restore gives each register a row of its own (TI-25 (1)).
          for (unsigned b = 0; b != a; ++b)
            if (q.gpr[b] == q.gpr[a])
              k_.fail("rcu: warp %u's restore map gives R%u and R%u one row", w, b, a);
        }
    }
    if (has(c.rau_rcu_mig, 0)) {
      const Bits m = take(c.rau_rcu_mig, 0).payload;
      const unsigned w = unsigned(get(m, c.rau_rcu_mig, "warp_id"));
      mig_[{w, unsigned(get(m, c.rau_rcu_mig, "direction"))}].cmd = true;
    }
    // A restore paired: every row and predicate its map names is unwritten
    // until its row lands.
    for (auto &[key, q] : mig_)
      if (key.second == 1 && q.map && q.cmd && !q.armed) {
        for (unsigned g : q.gpr) unwritten_.insert(g);
        for (unsigned p : q.pred) unwritten_p_.insert(p);
        q.armed = true;
      }
    for (auto it = mig_.begin(); it != mig_.end();) {
      const auto [w, dir] = it->first;
      const MigReq &q = it->second;
      if (dir != 0 || !q.map || !q.cmd) { ++it; continue; }
      // One row per architectural register, Ra as row a, with no merging of
      // shared or zero rows (AR's rev 114, TI-25 (1)): a register naming
      // the zero register moves a row of zeros.
      for (unsigned a = 0; a != kArchGprs; ++a) {
        const unsigned r = q.gpr[a];
        Bits row = msgOf(c.rcu_pca);
        put(row, c.rcu_pca, "warp_id", w);
        // mig-row-order: rows numbered from the end.
        put(row, c.rcu_pca, "mig_row", k_.brk == "mig-row-order" ? kArchGprs - 1 - a : a);
        const unsigned dl = field(c.rcu_pca, "row_data").lsb;
        for (unsigned l = 0; l != kLanes; ++l)
          row.set(dl + 32 * l, 32, r == ccv::prov::kPhysZero ? 0u : k_.gpr[r][l]);
        rows_out_.push_back({w, row});
      }
      Bits pr = msgOf(c.rcu_pca);
      put(pr, c.rcu_pca, "warp_id", w);
      put(pr, c.rcu_pca, "mig_row", kArchGprs);
      const unsigned dl = field(c.rcu_pca, "row_data").lsb;
      for (unsigned p = 0; p != kArchPreds; ++p)
        pr.set(dl + 32 * p, 32, q.pred[p] == ccv::prov::kPredZero ? 0u : k_.pred[q.pred[p]]);
      rows_out_.push_back({w, pr});
      it = mig_.erase(it);
    }
    if (!rows_out_.empty() && can(c.rcu_pca, 0)) {
      send(c.rcu_pca, 0, rows_out_.front().second, makeUid(IdClass::kNone, 0));
      rows_out_.pop_front();
    }
    // In: a row is taken only when its warp's restore map and command are
    // both here; it waits in its slot until then.
    if (has(c.pca_rcu, 0)) {
      const Bits &head = peek(c.pca_rcu, 0).payload;
      const unsigned w = unsigned(get(head, c.pca_rcu, "warp_id"));
      auto q = mig_.find({w, 1u});
      if (q != mig_.end() && q->second.map && q->second.cmd) {
        const Bits m = take(c.pca_rcu, 0).payload;
        const unsigned r = unsigned(get(m, c.pca_rcu, "mig_row"));
        const unsigned dl = field(c.pca_rcu, "row_data").lsb;
        const MigReq &mq = q->second;
        if (r >= kArchGprs) {
          for (unsigned p = 0; p != kArchPreds; ++p) {
            k_.pred[mq.pred[p]] = uint32_t(m.get(dl + 32 * p, 32));
            unwritten_p_.erase(mq.pred[p]);
          }
          // The predicate row closes the transfer: the warp's maps, for the
          // final compare, are the restore map's (an observation).
          for (unsigned a = 0; a != kArchGprs; ++a) k_.ratOf(w)[a] = mq.gpr[a];
          if (!k_.prat.empty() && w < k_.prat.size() && !k_.prat[w].empty())
            for (unsigned p = 0; p != kArchPreds; ++p) k_.prat[w][p] = mq.pred[p];
          mig_.erase(q);
        } else {
          // Row a is Ra's, written into the register the restore map names.
          for (unsigned l = 0; l != kLanes; ++l) k_.gpr[mq.gpr[r]][l] = uint32_t(m.get(dl + 32 * l, 32));
          unwritten_.erase(mq.gpr[r]);
        }
      }
    }
  }

  void work() override {
    migrate();
    const Ch &c = ch();
    // Register read sees this cycle's writes (OI-5): lane results and load
    // data land before the issues they may feed are read. CCV_LAT_L1_WAKE
    // brings an L1 hit's dependant to RCU in the very cycle its data does,
    // so without this a dependant OOE woke by the contract reads the old
    // value. no-rcu-bypass reads first, as the S1 RCU did.
    if (k_.brk == "no-rcu-bypass") issues();

    // Lane results, one message a cycle: all 32 lanes, or it is not lockstep.
    unsigned n = 0;
    for (unsigned l = 0; l != kLanes; ++l) n += has(c.lane_rcu, 0, l);
    if (n != 0 && n != kLanes) k_.fail("rcu: %u of 32 lanes answered", n);
    else if (n != 0 && alu_.empty()) k_.fail("rcu: lane results for nothing");
    else if (n != 0) {
      const Alu a = alu_.front();
      alu_.pop_front();
      land(a);
    }

    for (unsigned s = 0; s != kChans[c.miu_rcu].rate; ++s)
      while (has(c.miu_rcu, s)) {
        Receiver::Msg m = take(c.miu_rcu, s);
        // Stateless write-back: every destination arrives with the data,
        // echoed by MIU from the memop. No done: a memop's completion is
        // MIU's, on ccv_miu_ooe_cmpl (OI-4).
        const unsigned pd = unsigned(get(m.payload, c.miu_rcu, "phys_dst"));
        const uint32_t active = uint32_t(get(m.payload, c.miu_rcu, "active_mask"));
        // A predicate load (ld.pred, TI-36) writes its predicate alone: its
        // phys_dst is the zero register, which no write reaches.
        const bool pred_only = pd == ccv::prov::kPhysZero && get(m.payload, c.miu_rcu, "pred_we");
        if (pd == ccv::prov::kPhysZero && !pred_only)
          k_.fail("rcu: a load writes the zero register");
        // The slice it writes: dst_pos and dst_width, a whole row in S1.
        const unsigned dw = unsigned(get(m.payload, c.miu_rcu, "dst_width"));
        const unsigned dp = unsigned(get(m.payload, c.miu_rcu, "dst_pos"));
        if (dp != 0)
          k_.fail("rcu: a %u-bit load at position %u; only full-row loads are modelled in "
                  "the S1 stubs", 32u >> dw, dp);
        // A narrow load writes its row zero-extended from its width (AR-24's
        // interim; OA's rev 225).
        const uint32_t wmask = dw == kChw32 ? ~0u : (1u << (32u >> dw)) - 1;
        for (unsigned l = 0; l != kLanes && !pred_only; ++l)
          if ((active >> l) & 1u)   // an inactive lane keeps its old value
            k_.gpr[pd][l] = getLane(m.payload, c.miu_rcu, "load_data", l) & wmask;
        if (get(m.payload, c.miu_rcu, "pred_we")) {
          const unsigned pp = unsigned(get(m.payload, c.miu_rcu, "phys_pred"));
          const uint32_t pr = uint32_t(get(m.payload, c.miu_rcu, "pred_result"));
          k_.pred[pp] = (k_.pred[pp] & ~active) | (pr & active);
        }
      }
    if (k_.brk != "no-rcu-bypass") issues();

    // One lane message a cycle, every lane or none (lockstep): the oldest
    // op whose hold has passed. Only late-copy holds one, and the ops behind
    // it go first, as their contract requires.
    bool all = true;
    for (unsigned l = 0; l != kLanes; ++l) all = all && can(c.rcu_lane, 0, l);
    for (auto it = lane_q_.begin(); all && it != lane_q_.end(); ++it) {
      if (it->not_before > now_) continue;
      forward(*it);
      for (unsigned l = 0; l != kLanes; ++l) send(c.rcu_lane, 0, it->lanes[l], it->alu.tid, l);
      for (auto &w : wr_)
        if (w.second.serial == it->alu.serial) w.second.sent = now_;
      alu_.push_back(it->alu);
      lane_q_.erase(it);
      break;
    }
    // ccv_rcu_ooe_done's slots are a free pool: any done takes any slot,
    // oldest first. A lane op's done leaves the cycle its write lands, at
    // V-35's bound exactly, so it cannot wait for a particular slot.
    for (auto it = to_ooe_.begin(); it != to_ooe_.end();) {
      unsigned s = 0;
      while (s != kChans[c.rcu_ooe].rate && !can(c.rcu_ooe, s)) ++s;
      if (s == kChans[c.rcu_ooe].rate) break;
      send(c.rcu_ooe, s, it->msg, it->tid);
      it = to_ooe_.erase(it);
    }
    for (auto it = to_miu_.begin(); it != to_miu_.end();)
      if (can(c.rcu_miu, it->slot)) { send(c.rcu_miu, it->slot, it->msg, it->tid); it = to_miu_.erase(it); }
      else ++it;
  }

  /// A lane op's results: every section it held, from all 32 lanes.
  void land(const Alu &a) {
    const Ch &c = ch();
    uint32_t po_mask = 0;
    for (unsigned l = 0; l != kLanes; ++l) {
      Receiver::Msg m = take(c.lane_rcu, 0, l);
      if (m.tid != a.tid) k_.fail("rcu: lane %u answered for another instruction", l);
      if (get(m.payload, c.lane_rcu, "sec_valid") != a.foot)
        k_.fail("rcu: lane %u's results hold sections %x, not seq %llu's %x", l,
                unsigned(get(m.payload, c.lane_rcu, "sec_valid")),
                (unsigned long long)uidSeq(a.tid), a.foot);
      const uint32_t v = uint32_t(get(m.payload, c.lane_rcu, "result"));
      if (a.copy) {
        // The copy writes only the load's inactive lanes (A-38, A-44).
        if (!((a.active >> l) & 1u)) k_.gpr[a.pdst][l] = v;
        continue;
      }
      // Per-lane write enables (A-44), all on for an ordinary op: an
      // inactive lane's result is its merge_data, so a partial write
      // preserves what it does not write (ISA invariant 10) by merging.
      if (a.op->gdst) k_.gpr[a.pdst][l] = v;
      // A full-width op's predicate rides on its lead section, S0.
      po_mask |= uint32_t(get(m.payload, c.lane_rcu, "sec_pred_out") & 1u) << l;
    }
    if (a.copy) {
      // Within CCV_LAT_LANE of acceptance: the contract OOE clears the
      // load's copy-pending on.
      if (now_ - a.accepted > ccv::prov::kLatLane)
        k_.fail("rcu: seq %llu's copy reached the PRF %llu cycles after RCU took it; "
                "CCV_LAT_LANE is %u", (unsigned long long)uidSeq(a.tid),
                (unsigned long long)(now_ - a.accepted), ccv::prov::kLatLane);
      return;
    }
    if (a.op->gdst) {
      auto w = wr_.find(a.pdst);
      if (w != wr_.end() && w->second.serial == a.serial) wr_.erase(w);
    }
    // Predicates merge HERE, by read-modify-write of the 32-bit row from
    // the old destination (A-43): the lanes' bits on active lanes, the
    // old ones elsewhere. ignore-mask drops the mask, which writes the
    // switched-off lanes' poison.
    if (a.pwe) {
      const uint32_t on = k_.brk == "ignore-mask" ? 0xffffffffu : a.active;
      k_.pred[a.ppred] = ((a.merge ? k_.pred[a.ppold] : 0u) & ~on) | (po_mask & on);
    }
    to_ooe_.push_back({0, done(a.tag), a.tid});
  }

  /// This cycle's issues, one slot per select resource: S0-S3, P0-P3, R.
  /// V-60 first. Each lead sits in its footprint's lowest slot, every other
  /// slot of the footprint carries its continuation, and no slot belongs to
  /// two footprints. Then each lead, in slot order.
  void issues() {
    const Ch &c = ch();
    std::array<Receiver::Msg, kRes> m{};
    std::array<bool, kRes> got{};
    for (unsigned s = 0; s != kRes; ++s)
      if ((got[s] = has(c.ooe_rcu, s))) m[s] = take(c.ooe_rcu, s);
    auto cont = [&](unsigned s) { return get(m[s].payload, c.ooe_rcu, "cont") != 0; };
    auto tag = [&](unsigned s) { return unsigned(get(m[s].payload, c.ooe_rcu, "rob_tag")); };
    auto seq = [&](unsigned s) { return (unsigned long long)uidSeq(m[s].tid); };
    std::array<int, kRes> owner;
    owner.fill(-1);
    for (unsigned s = 0; s != kRes; ++s) {
      if (!got[s] || cont(s)) continue;
      const unsigned fp = unsigned(get(m[s].payload, c.ooe_rcu, "footprint"));
      const unsigned base = groupOf(s);
      if (base == kSlotR) {
        if (fp)
          k_.fail("rcu: seq %llu holds R with footprint %s; R takes none", seq(s),
                  bits(fp).c_str());
        owner[s] = int(s);
        continue;
      }
      for (unsigned b = 0; b != kSecs; ++b) {
        if (!((fp >> b) & 1u)) continue;
        const unsigned t = base + b;
        if (owner[t] >= 0) {
          k_.fail("rcu: V-60: seq %llu's footprint %s overlaps seq %llu's at %s", seq(s),
                  bits(fp).c_str(), seq(unsigned(owner[t])), res(t).c_str());
          continue;
        }
        owner[t] = int(s);
      }
      if (!fp || base + unsigned(__builtin_ctz(fp)) != s)
        k_.fail("rcu: seq %llu sits in %s, which is not its footprint %s's lowest", seq(s),
                res(s).c_str(), bits(fp).c_str());
    }
    for (unsigned s = 0; s != kRes; ++s) {
      if (!got[s]) continue;
      const int o = owner[s];
      if (o < 0)
        k_.fail("rcu: %s carries seq %llu outside every footprint", res(s).c_str(), seq(s));
      else if (unsigned(o) != s && (!cont(s) || tag(s) != tag(unsigned(o))))
        k_.fail("rcu: %s, in seq %llu's footprint, carries no continuation of it",
                res(s).c_str(), seq(unsigned(o)));
    }
    for (unsigned s = 0; s != kRes; ++s)
      if (owner[s] >= 0 && unsigned(owner[s]) != s && !got[s])
        k_.fail("rcu: %s, in seq %llu's footprint, carries nothing", res(s).c_str(),
                seq(unsigned(owner[s])));
    for (unsigned s = 0; s != kRes; ++s)
      if (got[s] && !cont(s)) issue(s, m[s]);
  }

  /// A register a lane op reads or writes, by its position and width code,
  /// never past its row. A narrow register sits in a full row at position 0
  /// (AR-24's interim, DA tab rev 87; OA's rev 225): its width code is its
  /// semantics, not its placement. A packed one, at another position, waits
  /// for the full narrow-register build.
  void slice(const Receiver::Msg &m, const char *what, unsigned w, unsigned pos) {
    const unsigned long long seq = uidSeq(m.tid);
    if (maskOf(w, pos) & ~kAllSecs)
      k_.fail("rcu: seq %llu's %s, a %u-bit register at position %u, overruns its row", seq,
              what, 32u >> w, pos);
    else if (w != kChw32 && pos != 0)
      k_.fail("rcu: seq %llu's %s is a %u-bit register at position %u; only full-row "
              "registers are modelled in the S1 stubs", seq, what, 32u >> w, pos);
  }

  /// At the lane op's send: name each operand read before its producer's
  /// write in operand_byp, by the producer's lead section and its age, the
  /// cycles since the producer left for the lanes. The lanes see the same
  /// distance between the two arrivals, since both cross the same link.
  void forward(LaneOp &lo) {
    const Ch &c = ch();
    bool fwd = false;
    for (unsigned i = 0; i != kBypOperands; ++i) {
      if (lo.from_reg[i] < 0) continue;
      const unsigned preg = unsigned(lo.from_reg[i]);
      const unsigned long long seq = uidSeq(lo.alu.tid);
      auto w = wr_.find(preg);
      if (w == wr_.end() || w->second.serial != lo.from[i]) {
        // The write landed between RCU's read and this send, which only a
        // send held for credit can see: read it again.
        for (unsigned l = 0; l != kLanes; ++l)
          if (i == kBypMerge) put(lo.lanes[l], c.rcu_lane, "merge_data", k_.gpr[preg][l]);
          else lo.lanes[l].set(field(c.rcu_lane, "operand").lsb + 32 * i, 32, k_.gpr[preg][l]);
        continue;
      }
      if (w->second.sent == ~0ull) {
        k_.fail("rcu: seq %llu leaves for the lanes before the producer of its operand %u",
                seq, i);
        continue;
      }
      const uint64_t age = now_ - w->second.sent;
      if (age < ccv::prov::kLatLaneByp) {
        k_.fail("rcu: seq %llu reads operand %u %llu cycles after its lane producer; "
                "CCV_LAT_LANE_BYP is %u", seq, i, (unsigned long long)age,
                ccv::prov::kLatLaneByp);
        continue;
      }
      if (age - ccv::prov::kLatLaneByp >= (1u << ccv::prov::kWLaneBypAge)) {
        k_.fail("rcu: seq %llu operand %u's producer is %llu cycles ahead, past the "
                "bypass window", seq, i, (unsigned long long)age);
        continue;
      }
      if (k_.brk == "no-lane-bypass") continue;
      // Every section of the port: the consumer is full width, and so is
      // its producer, whose lead section names it.
      const unsigned sel = 1u | w->second.lead << 1 |
                           unsigned(age - ccv::prov::kLatLaneByp) << (1 + kBypSecBits);
      for (unsigned l = 0; l != kLanes; ++l)
        for (unsigned k = 0; k != kSecs; ++k)
          if ((lo.alu.foot >> k) & 1u)
            putSec(lo.lanes[l], c.rcu_lane, "operand_byp", k * kBypOperands + i,
                   ccv::prov::kWLaneBypSel, sel);
      fwd = true;
    }
    if (fwd) k_.hit("lane_byp");
  }

  /// Record which of a lane op's operands a lane op in flight has yet to
  /// write, and enter the op itself in wr_ if it writes a GPR.
  void inFlight(LaneOp &lo, unsigned lead, const std::array<int, kBypOperands> &reads,
                int writes) {
    lo.alu.serial = ++serial_;
    for (unsigned i = 0; i != kBypOperands; ++i) {
      if (reads[i] < 0) continue;
      auto w = wr_.find(unsigned(reads[i]));
      if (w == wr_.end()) continue;
      lo.from_reg[i] = reads[i];
      lo.from[i] = w->second.serial;
    }
    if (writes >= 0) wr_[unsigned(writes)] = {lo.alu.serial, lead};
  }

  /// The lane message's control for a full-width op: every section holds
  /// it, S0 owns them all, and the lead carries each port's and the
  /// destination's position and width. Operands, merge_data and the enables
  /// are per lane.
  Bits laneMsg(const Receiver::Msg &m, unsigned opc) {
    const Ch &c = ch();
    Bits o = msgOf(c.rcu_lane);
    for (unsigned k = 0; k != kSecs; ++k)
      putSec(o, c.rcu_lane, "sec_opcode", k, ccv::prelim::kWOpcode, opc);
    put(o, c.rcu_lane, "section_en", kAllSecs);
    put(o, c.rcu_lane, "sec_owner", 0);   // every section S0's: one op
    for (unsigned i = 0; i != kBypOperands; ++i) {
      const bool mg = i == kBypMerge;
      putSec(o, c.rcu_lane, "sec_opnd_width", i, ccv::kWChwidth,
             mg ? unsigned(get(m.payload, c.ooe_rcu, "dst_width"))
                : getSec(m.payload, c.ooe_rcu, "src_width", i, ccv::kWChwidth));
      putSec(o, c.rcu_lane, "sec_opnd_pos", i, ccv::kWPhysPos,
             mg ? unsigned(get(m.payload, c.ooe_rcu, "old_dst_pos"))
                : getSec(m.payload, c.ooe_rcu, "src_pos", i, ccv::kWPhysPos));
    }
    put(o, c.rcu_lane, "sec_dst_width", get(m.payload, c.ooe_rcu, "dst_width"));
    put(o, c.rcu_lane, "sec_dst_pos", get(m.payload, c.ooe_rcu, "dst_pos"));
    return o;
  }

  void issue(unsigned s, const Receiver::Msg &m) {
    const Ch &c = ch();
    // dirty-zero: the zero registers read as garbage. The merge kernel's
    // first guarded writes and its read of an unwritten register must show
    // it (A-64).
    if (k_.brk == "dirty-zero") {
      k_.gpr[ccv::prov::kPhysZero].fill(0x5a5a5a5au);
      k_.pred[ccv::prov::kPredZero] = 0xa5a5a5a5u;
    }
    const unsigned tag = unsigned(get(m.payload, c.ooe_rcu, "rob_tag"));
    const unsigned opc = unsigned(get(m.payload, c.ooe_rcu, "opcode"));
    const OpInfo *op = opc == kOpCopy ? nullptr : opByCode(opc);
    if (!op && opc != kOpCopy) { k_.fail("rcu: unknown opcode"); return; }
    // Each class on its own resources: lane ops (the copy among them) on
    // the sections, memops on the pipes, RCU-only ops on R.
    const bool mem = op && (op->cls == kLoad || op->cls == kStore || op->cls == kFence);
    const unsigned want = mem ? kSlotP0 : op && execRcu(op) ? kSlotR : kSlotS0;
    if (groupOf(s) != want)
      k_.fail("rcu: seq %llu, %s, issued on %s; its class issues on %s",
              (unsigned long long)uidSeq(m.tid), op ? op->name : "a copy", res(s).c_str(),
              want == kSlotS0 ? "S0-S3" : want == kSlotP0 ? "P0-P3" : "R");
    const unsigned fp = unsigned(get(m.payload, c.ooe_rcu, "footprint"));
    // A predicate-only load's copy merges in RCU and reaches no lane, so it
    // has no width of its own to model (TI-36 (b)).
    const bool pred_copy = !op && get(m.payload, c.ooe_rcu, "pred_we") &&
                           get(m.payload, c.ooe_rcu, "phys_dst") == ccv::prov::kPhysZero;
    if (want != kSlotR && fp != kAllSecs && !pred_copy)
      k_.fail("rcu: seq %llu's footprint %s; only full-width ops are modelled in the S1 stubs",
              (unsigned long long)uidSeq(m.tid), bits(fp).c_str());
    // Every register named, at its width and position.
    const unsigned dw = unsigned(get(m.payload, c.ooe_rcu, "dst_width"));
    const bool merge = get(m.payload, c.ooe_rcu, "merge_en") != 0;
    if (!op || op->gdst)
      slice(m, "destination", dw, unsigned(get(m.payload, c.ooe_rcu, "dst_pos")));
    if (merge) slice(m, "old destination", dw, unsigned(get(m.payload, c.ooe_rcu, "old_dst_pos")));
    for (unsigned i = 0; op && i != op->nsrc; ++i)
      if (!(op->alu_imm >= 0 && int(i) == op->imm_slot))
        slice(m, i == 0 ? "first source" : i == 1 ? "second source" : "third source",
              getSec(m.payload, c.ooe_rcu, "src_width", i, ccv::kWChwidth),
              getSec(m.payload, c.ooe_rcu, "src_pos", i, ccv::kWPhysPos));
    if (!op) { issueCopy(s, m); return; }
    const unsigned ps = unsigned(get(m.payload, c.ooe_rcu, "phys_src"));
    const unsigned pd = unsigned(get(m.payload, c.ooe_rcu, "phys_dst"));
    const unsigned pp = unsigned(get(m.payload, c.ooe_rcu, "phys_pred_guard"));
    const unsigned ppd = unsigned(get(m.payload, c.ooe_rcu, "phys_pred_dst"));
    const bool pwe = get(m.payload, c.ooe_rcu, "pred_we") != 0;
    // Merge (A-33, A-43): the old destinations, read like any source. Only
    // with merge_en set may a lane be inactive, so only then are they read.
    const unsigned pold = unsigned(get(m.payload, c.ooe_rcu, "phys_old_dst"));
    const unsigned ppold = unsigned(get(m.payload, c.ooe_rcu, "phys_pred_old_dst"));
    const unsigned src[3] = {(ps >> 8) & 0xff, ps & 0xff,
                             unsigned(get(m.payload, c.ooe_rcu, "phys_src2"))};
    // A restored warp's registers are read only once their rows are
    // written (TI-13, OA's check on Q-39): done means written.
    for (unsigned i = 0; i != op->nsrc; ++i)
      if (!(op->alu_imm >= 0 && int(i) == op->imm_slot) && unwritten_.count(src[i]))
        k_.fail("rcu: seq %llu reads row %u before its restore row is written",
                (unsigned long long)uidSeq(m.tid), src[i]);
    if ((op->guard || op->pdata) && unwritten_p_.count(pp))
      k_.fail("rcu: seq %llu reads predicate %u before its restore row is written",
              (unsigned long long)uidSeq(m.tid), pp);
    // The zero registers are read, never written (A-64).
    if ((op->gdst && pd == ccv::prov::kPhysZero) || (pwe && ppd == ccv::prov::kPredZero))
      k_.fail("rcu: seq %llu writes a zero register", (unsigned long long)uidSeq(m.tid));
    // Active lanes = issue mask AND guard. RCU is the one block holding both
    // -- the issue mask arrives here, the predicate values live here -- so
    // it is the sole producer of active_mask, and sec_pred_bit is the same
    // computation per lane. A predicate read as DATA (por's sources) is not
    // a guard and does not narrow it (Q-27).
    const uint32_t issue = uint32_t(get(m.payload, c.ooe_rcu, "issue_mask"));
    const uint32_t guard = get(m.payload, c.ooe_rcu, "pred_neg") ? ~k_.pred[pp] : k_.pred[pp];
    // pdata-guard: a predicate read as data (st.pred's, sel's) taken as a
    // guard too, narrowing the lanes it acts on (OA's response TI-36 (c)).
    const bool gated = op->guard || (k_.brk == "pdata-guard" && op->pdata);
    const uint32_t active = issue & (gated ? guard : 0xffffffffu);
    const uint32_t imm0 = uint32_t(get(m.payload, c.ooe_rcu, "imm"));

    // An op RCU executes must have no per-lane input: RCU has the register
    // file, but per-lane work is the lanes' (Q-32).
    if (inRcu(op->cls))
      if (const Record *r = rec(m.tid, "rcu"))
        if (perLaneInput(op, *r))
          k_.fail("rcu: %s has a per-lane input; the lane executes it (Q-32)", op->name);
    // An immediate move is warp-level: RCU writes the immediate straight into
    // the register file on the issue-mask lanes, with no lane round trip.
    // (--break movi-in-lane sends it to the lanes instead, which must refuse.)
    // pmov.imm (section 3): the immediate's bit n is lane n's predicate bit,
    // all 32 lanes, ungated by the issue mask, so no merge.
    if (op->cls == kImm && op->pwrite) {
      if (!pwe) k_.fail("rcu: %s without pred_we", op->name);
      k_.pred[ppd] = imm0;
      if (const Record *r = rec(m.tid, "rcu"))
        if (const RegVal *d = r->predDef())
          if (k_.pred[ppd] != d->p)
            k_.fail("rcu: seq %llu P%u = %08x, oracle %08x", (unsigned long long)r->seq, d->idx,
                    k_.pred[ppd], d->p);
      to_ooe_.push_back({0, done(tag), m.tid});
      return;
    }
    // shfl.idx (Format G): each guarded issue lane takes the source at one
    // lane, read whether or not that lane is active. The register file is
    // RCU's, so it moves the value; inactive lanes keep the old destination.
    // OOE wakes it early behind an L1 load and replays it on a miss, so it is
    // judged, as a lane's op is, only on its last execution.
    if (op->cross) {
      k_.executing("rcu", m.tid);
      const unsigned from = imm0 & 31;
      // A narrow destination zero-extends at its width code (AR-24).
      const uint32_t em = elemMask(unsigned(get(m.payload, c.ooe_rcu, "dst_width")));
      const uint32_t v = k_.gpr[src[0]][from] & em;
      for (unsigned l = 0; l != kLanes; ++l)
        k_.gpr[pd][l] = (active >> l) & 1u ? v : k_.gpr[pold][l];
      if (const Record *r = rec(m.tid, "rcu"))
        if (const RegVal *d = r->gprDef())
          for (unsigned l = 0; l != kLanes; ++l)
            if (((active >> l) & 1u) && k_.gpr[pd][l] != (d->v[l] & em)) {
              k_.failHeld("rcu", m.tid, "rcu: seq %llu R%u lane %u = %08x, oracle %08x",
                          (unsigned long long)r->seq, d->idx, l, k_.gpr[pd][l], d->v[l]);
              break;
            }
      to_ooe_.push_back({0, done(tag), m.tid});
      return;
    }
    if (op->cls == kImm && k_.brk != "movi-in-lane") {
      // RCU executes it, so RCU merges it: inactive lanes keep the old
      // destination's values (merge_en is set whenever one can exist).
      // A narrow destination zero-extends at its width code (AR-24).
      const uint32_t em = elemMask(unsigned(get(m.payload, c.ooe_rcu, "dst_width")));
      for (unsigned l = 0; l != kLanes; ++l)
        k_.gpr[pd][l] = (active >> l) & 1u ? imm0 & em : k_.gpr[pold][l];
      if (const Record *r = rec(m.tid, "rcu"))
        if (const RegVal *d = r->gprDef())
          for (unsigned l = 0; l != kLanes; ++l)
            if (((active >> l) & 1u) && k_.gpr[pd][l] != (d->v[l] & em)) {
              k_.fail("rcu: seq %llu R%u lane %u = %08x, oracle %08x",
                      (unsigned long long)r->seq, d->idx, l, k_.gpr[pd][l], d->v[l]);
              break;
            }
      to_ooe_.push_back({0, done(tag), m.tid});
      return;
    }
    // Predicate logic executes HERE, beside the predicate file, and never
    // reaches a lane (O-33's second obligation; round 16). Its two sources
    // arrive renamed, in imm (TI-1): each CCV_P_W_PHYS_PRED bits of physical
    // predicate and a negate above it, read as phys_pred_guard is.
    if (op->cls == kPredLogic) {
      constexpr unsigned w = ccv::prov::kWPhysPred;
      auto src = [&](unsigned q) {
        const unsigned pp = q & ((1u << w) - 1);
        if (pp >= k_.pred.size()) {
          k_.fail("rcu: seq %llu names predicate %u", (unsigned long long)uidSeq(m.tid), pp);
          return 0u;
        }
        const uint32_t v = k_.pred[pp];
        return (q >> w) & 1 ? ~v : v;
      };
      uint32_t a = src(imm0), b = src(imm0 >> (w + 1));
      // arch-pred-srcs: RCU reads DEC's qualifiers ([2:0] and [5:3]) as
      // before TI-1, not OOE's renamed sources; plog's P3 must come out wrong.
      if (k_.brk == "arch-pred-srcs") {
        auto arch = [&](unsigned q) {
          const uint32_t v = k_.pred[q & 3];
          return (q >> 2) & 1 ? ~v : v;
        };
        a = arch(imm0 & 7);
        b = arch((imm0 >> 3) & 7);
      }
      uint32_t v = 0;
      if (!std::strcmp(op->name, "POR")) v = a | b;
      else if (!std::strcmp(op->name, "PAND")) v = a & b;
      else k_.fail("rcu: predicate op %s has no semantics here", op->name);
      if (!pwe) k_.fail("rcu: %s without pred_we", op->name);
      k_.pred[ppd] = ((merge ? k_.pred[ppold] : 0u) & ~issue) | (v & issue);
      if (const Record *r = rec(m.tid, "rcu"))
        if (const RegVal *d = r->predDef())
          if (k_.pred[ppd] != d->p)
            k_.fail("rcu: seq %llu P%u = %08x, oracle %08x",
                    (unsigned long long)r->seq, d->idx, k_.pred[ppd], d->p);
      to_ooe_.push_back({0, done(tag), m.tid});
      return;
    }
    // Branches resolve HERE too: the condition is a predicate. The taken
    // lanes are issue mask AND guard; any lane taking it is a redirect.
    if (op->cls == kBranch) {
      Bits d = done(tag);
      put(d, c.rcu_ooe, "branch_taken", active != 0);
      put(d, c.rcu_ooe, "branch_mask", active);
      const Record *r = rec(m.tid, "rcu");
      // A ret's lanes are judged by target below: ccv-sim's record takes every
      // lane at once, the skeleton's ret a target group a pass.
      if (r && r->taken != active && !op->ret)
        k_.fail("rcu: seq %llu branch taken by %08x, oracle %08x",
                (unsigned long long)r->seq, active, r->taken);
      // call writes its link register on the active lanes, as movi does:
      // the next instruction's address, ccv-sim's value (CP-9, AR-22).
      if (op->gdst) {
        const RegVal *ld = r ? r->gprDef() : nullptr;
        if (r && !ld) k_.fail("rcu: seq %llu call without its link", (unsigned long long)r->seq);
        for (unsigned l = 0; l != kLanes; ++l)
          k_.gpr[pd][l] = (active >> l) & 1u && ld ? ld->v[l] : k_.gpr[pold][l];
      }
      // ret (AR-24 (b), OA's revs 222, 223): aux is the lowest active
      // lane's rs, the target's offset in the ret's code window, and
      // branch_mask the active lanes whose rs equals it. OOE redirects those
      // to {PC[47:32], aux} with stay, and the ret re-issues for the
      // rest, a pass per distinct target.
      if (op->ret) {
        uint32_t tgt = 0, same = 0;
        bool first = true;
        for (unsigned l = 0; l != kLanes; ++l)
          if ((active >> l) & 1u) {
            const uint32_t v = k_.gpr[src[0]][l];
            if (first) { tgt = v; first = false; }
            if (v == tgt) same |= 1u << l;
          }
        put(d, c.rcu_ooe, "branch_mask", same);
        put(d, c.rcu_ooe, "branch_taken", same != 0);
        put(d, c.rcu_ooe, "aux", tgt);
        if (r && same && tgt != uint32_t(r->target))
          k_.fail("rcu: seq %llu ret to %08x, oracle %08llx", (unsigned long long)r->seq, tgt,
                  (unsigned long long)r->target);
      }
      to_ooe_.push_back({0, d, m.tid});
      return;
    }

    if (mem) {
      Bits a = msgOf(c.rcu_miu);
      put(a, c.rcu_miu, "rob_tag", tag);
      put(a, c.rcu_miu, "active_mask", active);
      // Register values only: the AGU is MIU's, and the displacement and
      // scale reach it on the memop. The base is per lane (TI-32): an O-30
      // frame pointer differs on every lane. A launch-slot form has none,
      // and its base is don't-care (TI-31). scalar-base: lane 0's base on
      // every lane, the S1 channel's.
      for (unsigned l = 0; l != kLanes; ++l) {
        if (op->base_src >= 0)
          putLane(a, c.rcu_miu, "base_per_lane", l,
                  k_.gpr[src[op->base_src]][k_.brk == "scalar-base" ? 0 : l]);
        if (op->index_src >= 0)
          putLane(a, c.rcu_miu, "index_per_lane", l, k_.gpr[src[op->index_src]][l]);
        // A predicate store's data is its predicate's 32 bits, read here
        // from the predicate file, in lane 0's slot (TI-36).
        if (op->cls == kStore && op->pxfer)
          putLane(a, c.rcu_miu, "store_data", l, l == 0 ? k_.pred[pp] : 0u);
        else if (op->cls == kStore)
          putLane(a, c.rcu_miu, "store_data", l, k_.gpr[src[op->data_src]][l]);
      }
      // On the slot of the memop's lead pipe.
      to_miu_.push_back({groupOf(s) == kSlotP0 ? s - kSlotP0 : 0, a, m.tid});
      // A load's write-back is MIU's echo; RCU remembers nothing of it, and
      // sends no done for either kind: the completion is MIU's (OI-4).
      return;
    }
    // An ALU immediate is substituted into its operand slot here, at
    // register read: lanes never see an immediate, only operands.
    const uint32_t imm = imm0;
    const Bits ctl = laneMsg(m, opcodeOf(op));
    std::vector<Bits> lanes;
    for (unsigned l = 0; l != kLanes; ++l) {
      Bits o = ctl;
      const uint32_t olsb = field(c.rcu_lane, "operand").lsb;
      for (unsigned i = 0; i != op->nsrc; ++i)
        o.set(olsb + 32 * i, 32, k_.gpr[src[i]][l]);
      if (op->alu_imm >= 0) o.set(olsb + 32 * unsigned(op->imm_slot), 32, imm);
      put(o, c.rcu_lane, "sec_pred_bit", (active >> l) & 1u ? kAllSecs : 0u);
      if (op->pdata && k_.brk != "drop-pred-data")
        put(o, c.rcu_lane, "sec_pred_data", (guard >> l) & 1u ? kAllSecs : 0u);
      // The old destination, carried to the lane: an inactive lane returns
      // it as its result (A-33, A-44). Don't-care without merge_en.
      // wrong-merge: the merge value read from the second source, not the
      // old destination; the lanes must refuse it (A-33, A-44).
      put(o, c.rcu_lane, "merge_data",
          !merge ? 0u : k_.gpr[k_.brk == "wrong-merge" ? src[1] : pold][l]);
      lanes.push_back(o);
    }
    std::array<int, kBypOperands> reads;
    reads.fill(-1);
    for (unsigned i = 0; i != op->nsrc; ++i)
      if (!(op->alu_imm >= 0 && int(i) == op->imm_slot)) reads[i] = int(src[i]);
    if (merge) reads[kBypMerge] = int(k_.brk == "wrong-merge" ? src[1] : pold);
    Alu a{tag, op, pd, ppd, pwe, active, m.tid, merge, ppold};
    a.accepted = now_;
    LaneOp lo(std::move(lanes), a);
    inFlight(lo, groupOf(s) == kSlotS0 ? s - kSlotS0 : 0, reads, op->gdst ? int(pd) : -1);
    lane_q_.push_back(std::move(lo));
  }

  /// The copy-only op of a masked load (A-33, A-38): the old destination
  /// through a lane, as merge_data, written back on the inactive lanes only.
  /// It takes the load's rob_tag and produces no done. RCU computes the
  /// active lanes as for any op -- issue mask AND guard -- so the copy and
  /// MIU's write-back, gated by the same mask, split the lanes between them.
  void issueCopy(unsigned s, const Receiver::Msg &m) {
    const Ch &c = ch();
    const unsigned tag = unsigned(get(m.payload, c.ooe_rcu, "rob_tag"));
    const unsigned pd = unsigned(get(m.payload, c.ooe_rcu, "phys_dst"));
    const unsigned pold = unsigned(get(m.payload, c.ooe_rcu, "phys_old_dst"));
    const unsigned pp = unsigned(get(m.payload, c.ooe_rcu, "phys_pred_guard"));
    if (!get(m.payload, c.ooe_rcu, "merge_en"))
      k_.fail("rcu: a copy-only op without merge_en has nothing to copy");
    const uint32_t issue = uint32_t(get(m.payload, c.ooe_rcu, "issue_mask"));
    const uint32_t guard = get(m.payload, c.ooe_rcu, "pred_neg") ? ~k_.pred[pp] : k_.pred[pp];
    const uint32_t active = issue & guard;
    // A predicate-only load's copy (ld.pred, O-62; OA's response TI-36 (b)):
    // the predicate file is RCU's, so RCU merges it here, the new
    // predicate's inactive lanes from the old one's, with no lane trip. The
    // load's write-back takes the active lanes, so the order is free.
    // drop-pred-copy: the copy is dropped, and the inactive lanes keep
    // whatever the fresh predicate held.
    if (get(m.payload, c.ooe_rcu, "pred_we") && pd == ccv::prov::kPhysZero) {
      const unsigned ppd = unsigned(get(m.payload, c.ooe_rcu, "phys_pred_dst"));
      const unsigned ppold = unsigned(get(m.payload, c.ooe_rcu, "phys_pred_old_dst"));
      if (k_.brk != "drop-pred-copy")
        k_.pred[ppd] = (k_.pred[ppd] & active) | (k_.pred[ppold] & ~active);
      k_.hit("pred_copy");
      return;
    }
    if (get(m.payload, c.ooe_rcu, "pred_we"))   // cas's predicate: not in S1
      k_.fail("rcu: a copy-only op with a predicate destination is not modelled");
    if (pd == ccv::prov::kPhysZero) k_.fail("rcu: a copy-only op writes the zero register");
    const Bits ctl = laneMsg(m, kOpCopy);
    std::vector<Bits> lanes;
    for (unsigned l = 0; l != kLanes; ++l) {
      Bits o = ctl;
      put(o, c.rcu_lane, "sec_pred_bit", (active >> l) & 1u ? kAllSecs : 0u);
      // copy-from-new: the copy reads the load's fresh destination, not its
      // old one -- a copy onto itself, which keeps nothing.
      put(o, c.rcu_lane, "merge_data", k_.gpr[k_.brk == "copy-from-new" ? pd : pold][l]);
      lanes.push_back(o);
    }
    // late-copy: the copy waits CCV_LAT_LANE cycles before leaving for the
    // lanes, so it lands after the contract OOE wakes the load's readers on.
    // The copy reads its merge_data like any lane op, so a lane producer
    // still in flight is forwarded to it; it writes only the load's inactive
    // lanes, so it is never a producer itself (A-38).
    Alu a{tag, nullptr, pd, 0, false, active, m.tid, true, 0};
    a.copy = true;
    a.accepted = now_;
    LaneOp lo(std::move(lanes), a, k_.brk == "late-copy" ? now_ + ccv::prov::kLatLane : 0);
    std::array<int, kBypOperands> reads;
    reads.fill(-1);
    reads[kBypMerge] = int(k_.brk == "copy-from-new" ? pd : pold);
    inFlight(lo, groupOf(s) == kSlotS0 ? s - kSlotS0 : 0, reads, -1);
    lane_q_.push_back(std::move(lo));
  }

  bool busy() const override {
    return !alu_.empty() || !lane_q_.empty() || !to_ooe_.empty() || !to_miu_.empty() ||
           !mig_.empty() || !rows_out_.empty();
  }
};

// ---- DEC ---------------------------------------------------------------------------

class Dec : public Stub {
public:
  using Stub::Stub;
  const char *kind() const override { return "dec"; }

private:
  std::deque<std::pair<Bits, uint64_t>> q_;
  /// A kill drops the killed warps' uops not yet sent to OOE (V-24).
  void onKill(uint32_t mask, unsigned) override {
    for (auto it = q_.begin(); it != q_.end();) {
      const unsigned w = unsigned(get(it->first, ch().dec_ooe, "warp_id"));
      it = mask >> (w & 31) & 1u ? q_.erase(it) : std::next(it);
    }
  }

  void work() override {
    const Ch &c = ch();
    // fet_dec_instr is ordered per binding group; everything taken this
    // cycle landed this cycle, so ascending slot within a group is age order.
    for (unsigned s = 0; s != kChans[c.fet_dec].rate; ++s)
      while (has(c.fet_dec, s)) decode(take(c.fet_dec, s));
    // Up to one uop per slot, in age order into ascending slots, so OOE can
    // recover the order from (arrival, slot).
    for (unsigned s = 0; s != kChans[c.dec_ooe].rate && !q_.empty(); ++s) {
      if (!can(c.dec_ooe, s)) break;
      send(c.dec_ooe, s, q_.front().first, q_.front().second);
      q_.pop_front();
    }
  }

  void decode(const Receiver::Msg &m) {
    const Ch &c = ch();
    const Bits &f = m.payload;
    const Record *r = rec(m.tid, "dec");
    if (!r) return;
    const unsigned len = 2 * (unsigned(get(f, c.fet_dec, "length")) + 1);
    const uint64_t pc = get(f, c.fet_dec, "pc");
    const uint64_t word = get(f, c.fet_dec, "instr");
    // The bytes FETCH delivered -- fetched from testbench memory through the
    // ifill path -- against the bytes ccv-sim executed.
    bool same = len == r->size && pc == r->pc;
    for (unsigned b = 0; b != r->size && same; ++b)
      same = uint8_t(word >> (8 * b)) == r->bytes[b];
    if (!same)
      k_.fail("dec: seq %llu fetched %u bytes at %llx that are not what ccv-sim ran",
              (unsigned long long)r->seq, len, (unsigned long long)pc);
    if (get(f, c.fet_dec, "fetch_fault")) k_.fail("dec: fetch fault");

    // Decode itself is the oracle's: which registers the instruction reads
    // and writes. The table checks the record has the shape the uop can hold.
    const OpInfo *op = opByName(r->op);
    // DEC's second illegal-instruction obligation, separate from the
    // reserved-field zero checks: srd's selector is a legal field that may
    // hold an unallocated value, so this is a range comparison. Selector 2,
    // %lanectx, is allocated (O-64); 3-15 are not.
    if (op && op->srd_sel >= 0) {
      const int64_t sel = (r->imms.empty() ? 0 : r->imms[0]) +
                          (k_.brk == "srd-selector" ? 3 : 0);
      op = srdBySel(sel);
      if (!op) {
        k_.fail("dec: seq %llu srd selector %lld is unallocated (a legal field, "
                "an illegal value)", (unsigned long long)r->seq, (long long)sel);
        Bits u = msgOf(c.dec_ooe);
        put(u, c.dec_ooe, "warp_id", get(f, c.fet_dec, "warp_id"));
        put(u, c.dec_ooe, "pc", pc);
        put(u, c.dec_ooe, "cause", kFaultIllegal);
        q_.push_back({u, m.tid});
        return;
      }
    }
    Bits u = msgOf(c.dec_ooe);
    put(u, c.dec_ooe, "warp_id", get(f, c.fet_dec, "warp_id"));
    put(u, c.dec_ooe, "pc", pc);
    // FET's group mask and epoch pass through (A-69, A-70).
    put(u, c.dec_ooe, "group_mask", get(f, c.fet_dec, "group_mask"));
    put(u, c.dec_ooe, "final_exit", get(f, c.fet_dec, "final_exit"));
    put(u, c.dec_ooe, "all_waiting", get(f, c.fet_dec, "all_waiting"));   // TI-40
    put(u, c.dec_ooe, "fetch_epoch", get(f, c.fet_dec, "fetch_epoch"));
    if (!op) {
      k_.fail("dec: %s is not in the skeleton's opcode table", r->op.c_str());
      put(u, c.dec_ooe, "cause", kFaultIllegal);
      q_.push_back({u, m.tid});
      return;
    }
    bool g_ok = true;
    const std::vector<unsigned> g = srcRegs(op, *r, 0, g_ok);
    const RegVal *gd = r->gprDef(), *pu = r->predUse(), *pd = r->predDef();
    // A predicate load's record lists the predicates it merges into as
    // uses (its copy reads them, O-62), and a reload of an unchanged value
    // as no def: MIU holds its word to the record's access instead.
    const bool pload = op->pxfer && op->cls == kLoad;
    const bool pu_ok = bool(pu) == op->pread || pload;
    const bool pd_ok = bool(pd) == op->pwrite || pload;
    // A faulting instruction (ccv-sim's fault record) wrote nothing, so its
    // record names no destination; it never retires, so none is needed.
    // A chwidth writes its register whether or not the value changes: the
    // record has a def only when a widening cleared set bits (AR-24 (c)).
    const bool gd_ok = bool(gd) == op->gdst || (r->kind == "fault" && !gd) || op->chw;
    if (!g_ok || !gd_ok || !pu_ok || !pd_ok)
      k_.fail("dec: seq %llu %s has an operand shape the table does not",
              (unsigned long long)r->seq, op->name);
    const unsigned dst = op->chw ? g[0] : gd ? gd->idx : 0;
    // The guard and the predicate destination are separate fields, as they
    // are in the encoding (Format C: qualifier [29:27], destination [31:30]),
    // so @P0 setp P1 is one uop (Q-21).
    unsigned pguard = 0, pneg = 0;
    if (op->guard || op->pdata) {
      // The qualifier is quals[0]: [1:0] the predicate, [2] negate. vadd's
      // branch is @!P0, and the index alone would resolve it backwards.
      if (r->quals.empty()) k_.fail("dec: seq %llu has no guard qualifier",
                                    (unsigned long long)r->seq);
      else { pguard = r->quals[0] & 3; pneg = (r->quals[0] >> 2) & 1; }
    }
    unsigned pdst = pd ? pd->idx : 0;
    // The old single field: the destination named by the guard.
    if (k_.brk == "conflate-pred" && pd && op->guard) pdst = pguard;
    put(u, c.dec_ooe, "uop_class", op->cls);
    // attr-store-as-load: DEC tells OOE a store is a load (A-66's control).
    uint32_t attr = schedAttrOf(op);
    if (k_.brk == "attr-store-as-load" && op->cls == kStore)
      attr &= ~(3u << 7);
    put(u, c.dec_ooe, "sched_attr", attr);
    // What OOE schedules and renames on instead of opcode (A-75, TI-1).
    // drop-src-valid: DEC calls a two-source op's second source unread, so
    // OOE neither renames nor waits on it.
    unsigned sv = srcValidOf(op);
    if (k_.brk == "drop-src-valid" && op->nsrc == 2 && op->cls == kAlu) sv &= ~2u;
    put(u, c.dec_ooe, "src_valid", sv);
    put(u, c.dec_ooe, "pred_use", predUseOf(op));
    // lanectx-literal: srd #2's imm_kind sent as a literal, so OOE substitutes
    // no context, and the lanes refuse the value.
    put(u, c.dec_ooe, "imm_kind",
        k_.brk == "lanectx-literal" && immKindOf(op) == kImmLaneCtx ? kImmLiteral : immKindOf(op));
    // fmt_rsv and fmt_opnd stay 0: no op in the skeleton's table has an FP
    // format field, so none can raise F-FORMAT (OI-57).
    // The memop's fields are DEC's to decode too (A-68); OOE copies them to
    // MIU unexamined. 0xF is OOE's bulk discard, never DEC's (V-52).
    if (op->cls == kLoad || op->cls == kStore) {
      // A predicate transfer's own codes (TI-36): MIU forms its one address
      // from lane 0 and moves a predicate's word, not lanes' data.
      const unsigned mop = op->pxfer ? (op->cls == kStore ? kMemPredStore : kMemPredLoad)
                                     : op->cls == kStore ? kMemStore : kMemLoad;
      if (mop == kMemBulkDiscard || mop == kMemAtomicRead || mop == kMemAtomicWrite)
        k_.fail("dec: mem_op %x is OOE's to generate (V-52, V-72)", mop);
      put(u, c.dec_ooe, "mem_op", mop);
      put(u, c.dec_ooe, "space", kSpaceGlobal);     // every memory op in the table
      // ordering-on-load: DEC's table gives a load an ordering, which only a
      // fence may carry (IS-11): asserted on DEC's output, as V-52 is.
      // memop-ordering: the same, from a DEC without that assertion, so the
      // ordering reaches MIU on the memop: MIU refuses it.
      const bool bad_ord = (k_.brk == "ordering-on-load" || k_.brk == "memop-ordering") && op->cls == kLoad;
      const unsigned ord = bad_ord ? 1 : 0;
      const uint32_t sa = schedAttrOf(op);
      if (ord != 0 && k_.brk != "memop-ordering" && !(attrMem(sa) && attrMemKind(sa) == kMemKFence))
        k_.fail("dec: pc 0x%llx has ordering %u but is not a fence",
                (unsigned long long)pc, ord);
      put(u, c.dec_ooe, "ordering", ord);
    } else if (op->cls == kFence) {
      // A fence (IS-11): its encoded ordering, scope [2:0] and ordering
      // [4:3], is the one memop field it carries; it moves no data.
      put(u, c.dec_ooe, "mem_op", kMemFence);
      put(u, c.dec_ooe, "space", kSpaceGlobal);
      put(u, c.dec_ooe, "ordering", r->imms.empty() ? 0u : unsigned(r->imms[0]));
    }
    put(u, c.dec_ooe, "opcode", opcodeOf(op));
    // Three source fields: Format A's rs2 is an independent source (mad.lo's
    // and dp4's accumulator input), with rd independent of it.
    put(u, c.dec_ooe, "src_arch",
        ((g.size() > 0 ? g[0] : 0u) << 4) | (g.size() > 1 ? g[1] : 0u));
    put(u, c.dec_ooe, "src2_arch", g.size() > 2 ? g[2] : 0u);
    put(u, c.dec_ooe, "dst_arch", dst);
    // The uop's one immediate: the displacement for a memory op, else the ALU
    // immediate. The scale enable rides beside it.
    auto immOf = [&](int8_t k) -> int64_t {
      if (k < 0) return 0;
      if (size_t(k) >= r->imms.size()) {
        k_.fail("dec: seq %llu %s has no immediate %d", (unsigned long long)r->seq,
                op->name, k);
        return 0;
      }
      return r->imms[k];
    };
    uint32_t imm = uint32_t(op->disp_imm >= 0 ? immOf(op->disp_imm) : immOf(op->alu_imm));
    if (op->cls == kBranch) {
      // A branch's imm is its architectural offset, in halfwords from the
      // next instruction; the length rides beside it in ilen, and OOE
      // computes the target (arch open A-8).
      imm = uint32_t(immOf(0));
    } else if (op->cls == kPredLogic) {
      // Predicate logic executes in RCU (O-33, round 16). Its two source
      // qualifiers ride in imm: [2:0] ps0, [5:3] ps1.
      if (r->quals.size() < 2) k_.fail("dec: seq %llu predicate logic without two sources",
                                       (unsigned long long)r->seq);
      else imm = (r->quals[0] & 7) | ((r->quals[1] & 7) << 3);
    } else if (isBarrier(op)) {
      // bar.arrive and bar.wait: the barrier id, OOE's to report (TI-40).
      imm = uint32_t(immOf(0));
    } else if (op->chw) {
      // chwidth: the width code, which rename commits for its register when
      // the uop retires (OOE's committed table, OI-57).
      imm = uint32_t(immOf(op->chw == 2 ? 1 : 0)) & 3u;
    }
    put(u, c.dec_ooe, "imm", imm);
    put(u, c.dec_ooe, "ilen", r->size / 2 - 1);
    put(u, c.dec_ooe, "pred_neg", pneg);
    put(u, c.dec_ooe, "scale_en", immOf(op->scale_imm) != 0);
    // The launch-slot form (O-45; TI-31): its slot, an immediate where the
    // base register would be, for MIU's window table.
    if (op->slot_imm >= 0) {
      put(u, c.dec_ooe, "slot_form", 1);
      put(u, c.dec_ooe, "arg_slot", uint32_t(immOf(op->slot_imm)) & 15u);
    }
    // The interleaved local form (O-69; IS-19): no base, imm the offset b.
    if (op->local) put(u, c.dec_ooe, "local_form", 1);
    put(u, c.dec_ooe, "pred_guard", pguard);
    put(u, c.dec_ooe, "pred_dst", pdst);
    put(u, c.dec_ooe, "pred_we", pd != nullptr);
    // FET's checkpoint and prediction pass through on a branch (A-42).
    put(u, c.dec_ooe, "checkpoint_id", get(f, c.fet_dec, "checkpoint_id"));
    put(u, c.dec_ooe, "pred_taken", get(f, c.fet_dec, "pred_taken"));
    if (op->chw == 2) {
      // chwidth.multi cracks (AR-24 (c), until OA rules on one masked uop):
      // a chwidth per register of its mask, ascending, each its register's
      // source and destination, sharing the instruction's id but for sub.
      // The hold sits on the last sibling only, one drain as O-6 intends; the
      // earlier ones commit their widths at retire without it (OA's rev 222).
      for (unsigned k = 0; k != r->uops(); ++k) {
        const unsigned reg = r->chwReg(k);
        Bits v = u;
        put(v, c.dec_ooe, "src_arch", reg << 4);
        put(v, c.dec_ooe, "dst_arch", reg);
        if (k + 1 != r->uops()) {
          const uint32_t sa = schedAttrOf(op);
          put(v, c.dec_ooe, "sched_attr",
              (sa & ~(7u << 3)) | (kSerNone << 3) | 1u << kAttrCommitWidthBit);
        }
        q_.push_back({v, m.tid | uint64_t(k) << kUidSubLsb});
      }
      return;
    }
    if (op->pxfer) {
      // A predicate transfer cracks (TI-36): one uop per predicate of its
      // mask, ascending, uop k moving Pk's word, the frame's word k at
      // disp + 4k, Pk its destination (ld.pred) or its data (st.pred). The
      // uops share the instruction's id but for its sub field. The frame is
      // 16-byte aligned, so a fault any word raises the first raises too,
      // and the instruction stays precise (AR's response TI-36).
      const int64_t disp = immOf(op->disp_imm);
      for (unsigned k = 0; k != r->uops(); ++k) {
        const unsigned p = r->xferPred(k);
        Bits v = u;
        put(v, c.dec_ooe, "imm", uint32_t(disp + 4 * int64_t(p)));
        if (op->cls == kLoad) {
          put(v, c.dec_ooe, "pred_dst", p);
          put(v, c.dec_ooe, "pred_we", 1);
        } else {
          put(v, c.dec_ooe, "pred_guard", p);
          put(v, c.dec_ooe, "pred_neg", 0);
        }
        q_.push_back({v, m.tid | uint64_t(k) << kUidSubLsb});
      }
      return;
    }
    q_.push_back({u, m.tid});
  }

  bool busy() const override { return !q_.empty(); }
};

// ---- FET: trace-driven fetch -------------------------------------------------------
//
// FET picks what it fetches (IS-17 (b), FET spec rev 16): it holds each
// lane's PC, the lanes not yet exited and O-60's fairness pointer and
// counter, and every fetch issues the group min-PC and the fairness rule
// choose. Groups are the lanes with equal PCs: a divergent branch splits
// them at its redirect, and they reconverge when their PCs meet. Each pick
// is checked against ccv-sim's record, whose order is the same rule at
// CCV_FAIR_N (gen-oracle passes it), so the oracle checks the pick and
// never makes it. What the oracle still decides is whether FET will
// mispredict a branch: FET fetches no wrong path, since it has no record
// for one (docs/coverage.md, item 1). The BYTES are read out of lines
// fetched through ITLB and the ifill path.

class Fet : public Stub {
public:
  Fet(int inst, Kernel &k) : Stub(inst, k), ids_(ch().fet_mlc) {}
  const char *kind() const override { return "fet"; }

private:
  static constexpr unsigned kPage = 4096;
  std::map<uint64_t, uint64_t> page_;       ///< virtual page -> physical page
  std::set<uint64_t> itlb_wait_;
  std::map<uint64_t, Line> line_;           ///< by virtual line address
  IdPool ids_;
  std::map<unsigned, uint64_t> ifill_wait_; ///< virtual line, by req_id
  std::deque<Q> fills_, itlbs_;
  static constexpr unsigned kCkpts = ccv::prov::kBrCkpts;
  static_assert(kCkpts <= 64, "FET's checkpoint timestamps hold 64");
  /// A launched warp, by warp_id: its place in its own oracle stream, its
  /// tier-1 slot (A-65), and its checkpoints, which are live and in what
  /// order they were taken, so a redirect can free the one it restores and
  /// every younger one. Warps fetch side by side, each in its slot's binding
  /// group of ccv_fet_dec_instr; the ITLB and the fills are shared.
  struct Warp {
    bool launched = false;
    size_t next = 0;
    unsigned tier1 = 0;   ///< kNoSlot once another warp takes it
    uint32_t live = 0;
    std::deque<unsigned> taken_order;
    std::map<uint64_t, unsigned> ckpt_of;   ///< checkpoint, by branch seq
    uint64_t ckpt_at[64] = {};              ///< cycle each checkpoint was taken (AR-24)
    bool await_redirect = false;            ///< fetched a branch it mispredicts
    bool stopped = false;                   ///< an epoch notice: demoted or killed
    bool restoring = false;                 ///< RAU's restore command, PCs to come
    /// Lanes OOE's rewind beats set, and to what (TI-24 (3)): the stub's
    /// fetch order is the oracle's, so it keeps per-lane PCs only for this.
    uint32_t rewound = 0;
    std::array<uint64_t, kLanes> lane_pc{};
    uint64_t boundary_tid = 0;              ///< the oldest beat's uop (trace-only)
    /// The divergence state (IS-17 (b)): each lane's PC, the lanes not yet
    /// exited, and the fairness rule's pointer and counter (O-60).
    std::array<uint64_t, kLanes> pc{};
    uint32_t lanes = 0;   ///< live lanes: not yet exited
    unsigned fair_ptr = 0, fair_cnt = 0;
    /// The live lanes before each record's pick, by record (trace-only):
    /// FET clears a group's lanes when it fetches its exit, ahead of
    /// retirement, and after a demotion's beats its mask must equal the
    /// boundary's (AR's response TI-27 (b)), which this checks.
    std::vector<uint32_t> lanes_at;
    bool marked = false;     ///< early-mark: one exit already marked final
    bool restored = false;   ///< restored at least once: its order may leave ccv-sim's (TI-27 (c))
    uint32_t br_mask = 0;   ///< a branch FET mispredicts: its group, until the redirect
    unsigned br_len = 0;    ///< its length: a ret's staying lanes go back by it
    uint64_t br_next = 0;   ///< and the group's fall-through
  };
  std::map<unsigned, Warp> warps_;
  /// A kill (V-24): the killed warps fetch no more, and leave their slots.
  void onKill(uint32_t mask, unsigned) override {
    for (auto &w : warps_)
      if (mask >> (w.first & 31) & 1u) {
        w.second.stopped = true;
        w.second.await_redirect = false;
        w.second.tier1 = kNoSlot;
      }
  }
  /// CCV_FAIR_N, which ccv-sim's -fairness must equal (gen-oracle). The N
  /// sweep sets both through CCV_FAIR_N; 0 is strict min-PC, the rule off.
  /// CCV_FET_PERFECT=1 (AR-24): perfect fetch. A branch every lane it
  /// issues on takes is predicted taken, and FET moves its lanes to the
  /// target itself, so OOE sees the prediction right and raises no redirect
  /// (V-41): the run's front end costs nothing but checkpoints. A branch
  /// that splits its group still mispredicts. The gap to today's run is what
  /// prediction, return-address prediction (PF-36) and the checkpoints
  /// (PF-17) are worth. The oracle decides the direction here: a knob for a
  /// bound, never the default.
  const bool perfect_ = getenv("CCV_FET_PERFECT") && std::string(getenv("CCV_FET_PERFECT")) == "1";
  const unsigned fair_n_ = getenv("CCV_FAIR_N") ? unsigned(std::strtoul(getenv("CCV_FAIR_N"), nullptr, 0))
                                                : ccv::prov::kFairN;
  /// One pick: the group's PC and lanes, and the fairness state after it.
  struct Pick { uint64_t pc = 0; uint32_t mask = 0; unsigned ptr = 0, cnt = 0; bool fair = false; };
  /// FET's pick for a warp, as the FET spec states it: the lowest PC among
  /// live lanes, except that once lane r's group has gone N picks without
  /// issuing, the pick is that group. Its issue, either way, restarts the
  /// count and moves r to the next live lane. No lane waits at a barrier or
  /// a sleep in these kernels; a barrier's kind fails at fetch.
  Pick pick(const Warp &x) const {
    Pick p;
    p.ptr = x.fair_ptr;
    p.cnt = x.fair_cnt;
    if (!x.lanes) return p;
    p.pc = UINT64_MAX;
    for (unsigned l = 0; l != kLanes; ++l)
      if (x.lanes >> l & 1u) p.pc = std::min(p.pc, x.pc[l]);
    const unsigned n = k_.brk == "fair-off" ? 0 : k_.brk == "fair-late" ? fair_n_ + 1 : fair_n_;
    if (n) {
      unsigned r = p.ptr;
      while (!(x.lanes >> r & 1u)) r = (r + 1) % kLanes;
      bool served = x.pc[r] == p.pc;
      if (!served && ++p.cnt == n) { p.pc = x.pc[r]; served = p.fair = true; }
      if (served) {
        p.cnt = 0;
        p.ptr = (r + 1) % kLanes;
        while (!(x.lanes >> p.ptr & 1u)) p.ptr = (p.ptr + 1) % kLanes;
      }
    }
    for (unsigned l = 0; l != kLanes; ++l)
      if ((x.lanes >> l & 1u) && x.pc[l] == p.pc) p.mask |= 1u << l;
    return p;
  }
  /// The fairness state after issuing a given group, by the same rule: the
  /// counter restarts if it holds lane r, and otherwise counts, up to N.
  Pick issued(const Warp &x, uint64_t pc, uint32_t mask) const {
    Pick p;
    p.pc = pc;
    p.mask = mask;
    p.ptr = x.fair_ptr;
    p.cnt = x.fair_cnt;
    if (fair_n_ && x.lanes) {
      unsigned r = p.ptr;
      while (!(x.lanes >> r & 1u)) r = (r + 1) % kLanes;
      if (mask >> r & 1u) {
        p.cnt = 0;
        p.ptr = (r + 1) % kLanes;
        while (!(x.lanes >> p.ptr & 1u)) p.ptr = (p.ptr + 1) % kLanes;
      } else {
        p.cnt = std::min(p.cnt + 1, fair_n_);
      }
    }
    return p;
  }
  /// The warp's groups: its live lanes' distinct PCs.
  static unsigned groups(const Warp &x) {
    std::set<uint64_t> g;
    for (unsigned l = 0; l != kLanes; ++l)
      if (x.lanes >> l & 1u) g.insert(x.pc[l]);
    return unsigned(g.size());
  }
  static constexpr unsigned kNoSlot = ~0u;
  /// A warp takes a tier-1 slot, at launch or restore. Whoever held it,
  /// exited or parked, holds it no longer, so a checkpoint free for the
  /// slot reaches the warp in it now.
  void take_slot(Warp &x, unsigned slot) {
    for (auto &w : warps_)
      if (&w.second != &x && w.second.tier1 == slot) w.second.tier1 = kNoSlot;
    x.tier1 = slot;
  }
  // Each warp's fetch epoch, by warp_id, as OOE last sent it (A-70, A-74).
  // FET advances nothing itself, and never resets it at launch.
  unsigned epoch_[32] = {};
  static constexpr unsigned kEpochs = 1u << ccv::prov::kWFetchEpoch;
  bool stale_next_ = false, stale_done_ = false;   ///< stale-epoch control
  std::deque<std::pair<Bits, uint64_t>> pca_q_;     ///< PCs out to PCA, with where it resumes

  void work() override {
    const Ch &c = ch();
    if (has(c.rau_fet, 0)) {
      Receiver::Msg m = take(c.rau_fet, 0);
      const unsigned w = unsigned(get(m.payload, c.rau_fet, "warp_id"));
      const uint64_t start = get(m.payload, c.rau_fet, "start_pc");
      if (w >= k_.orcs.size()) {
        k_.fail("fet: a launch of warp %u, which ccv-sim never ran", w);
      } else {
        const auto &recs = k_.orcs[w].recs;
        if (recs.empty() || start != recs[0].pc)
          k_.fail("fet: warp %u launches at %llx, but ccv-sim began elsewhere", w,
                  (unsigned long long)start);
        Warp &x = warps_[w];
        x.launched = true;
        take_slot(x, unsigned(get(m.payload, c.rau_fet, "tier1_id")));   // A-65
        // Every live lane starts at the entry: the lanes are RAU's, from the
        // CTA's thread count (AR's response TI-27 (a)).
        x.pc.fill(start);
        x.lanes = uint32_t(get(m.payload, c.rau_fet, "live_mask"));
        x.fair_ptr = x.fair_cnt = 0;
      }
    }
    if (has(c.ooe_fet, 0)) {
      // A redirect. Fetch ORDER is still the oracle's, so what FET can do is
      // check the redirect says where ccv-sim went, and take the new epoch
      // (a real FET discards in-flight fetches from older epochs).
      Receiver::Msg m = take(c.ooe_fet, 0);
      const unsigned rw = unsigned(get(m.payload, c.ooe_fet, "warp_id"));
      const unsigned fe = unsigned(get(m.payload, c.ooe_fet, "fetch_epoch"));
      // An epoch notice (A-74): OOE advanced the warp's epoch for a demotion
      // or kill. FET takes the epoch and nothing else -- no restore, no PC
      // change -- and fetches no more for the warp: either way it leaves its
      // slot (TI-24).
      if (get(m.payload, c.ooe_fet, "epoch_only") && get(m.payload, c.ooe_fet, "rewind")) {
        // A rewind beat (TI-24 (3)): the lanes in taken_mask resume at
        // target_pc. A lane in no beat keeps FET's PC.
        Warp &x = warps_[rw];
        const uint32_t lanes = uint32_t(get(m.payload, c.ooe_fet, "taken_mask"));
        const uint64_t pc = get(m.payload, c.ooe_fet, "target_pc");
        for (unsigned l = 0; l != kLanes; ++l)
          if (lanes >> l & 1u) x.lane_pc[l] = pc;
        x.rewound |= lanes;
        // The oldest beat's uop, on the trace sideband: where this stub's
        // oracle-ordered fetch resumes after a restore (trace-only).
        if (uidClass(m.tid) == IdClass::kInstr &&
            (!x.boundary_tid || seqIndex(uidSeq(m.tid)) < seqIndex(uidSeq(x.boundary_tid))))
          x.boundary_tid = m.tid;
      } else if (get(m.payload, c.ooe_fet, "epoch_only")) {
        epoch_[rw & 31] = fe;
        warps_[rw].stopped = true;
      } else {
        Warp &x = warps_[rw];
        const uint64_t tgt = get(m.payload, c.ooe_fet, "target_pc");
        const uint32_t tmask = uint32_t(get(m.payload, c.ooe_fet, "taken_mask"));
        const unsigned ck = unsigned(get(m.payload, c.ooe_fet, "checkpoint_id"));
        if (const Record *r = rec(m.tid, "fet")) {
          if (tgt != r->target || tmask != r->taken)
            k_.fail("fet: seq %llu redirect to %llx for lanes %08x; ccv-sim %llx for %08x",
                    (unsigned long long)r->seq, (unsigned long long)tgt, tmask,
                    (unsigned long long)r->target, r->taken);
          // The checkpoint is FET's own: the one it took for this branch, back
          // through DEC and OOE. FET rebuilds the groups from it and tmask.
          auto k = x.ckpt_of.find(r->seq);
          if (k == x.ckpt_of.end() || k->second != ck)
            k_.fail("fet: seq %llu redirect names checkpoint %u, not the one FET took",
                    (unsigned long long)r->seq, ck);
        }
        // Restoring a checkpoint frees it and every younger one: the branches
        // that took them were on the wrong path (A-56). Applied before any free
        // landing this cycle -- the pair is latency-matched (A-58).
        for (auto it = x.taken_order.begin(); it != x.taken_order.end(); ++it)
          if (*it == ck) {
            // The restored branch resolved here (AR-24's fetch-to-resolve);
            // the younger ones never will.
            k_.hit("br_resolved");
            k_.hit("br_resolve_cycles", now_ - x.ckpt_at[ck]);
            for (auto j = it; j != x.taken_order.end(); ++j) x.live &= ~(1u << *j);
            x.taken_order.erase(it, x.taken_order.end());
            break;
          }
        x.await_redirect = false;
        // The split (IS-17 (b)): the branch's lanes OOE names as taken go to
        // the target, the rest of its group falls through. split-swap
        // sends each half the other's way.
        const bool swap = k_.brk == "split-swap";
        const uint32_t to_tgt = swap ? x.br_mask & ~tmask : tmask;
        // stay (AR-24 (b)): a ret's other lanes stay at the ret, to re-issue
        // with their own targets, rather than fall through. A trace-driven
        // FET has no record for the re-issue, so a peel it must follow fails.
        const bool stay = get(m.payload, c.ooe_fet, "stay") != 0;
        if (stay && (x.br_mask & ~to_tgt))
          k_.fail("fet: a ret peels lanes %08x off to re-issue; ccv-sim's record has them return "
                  "at once", x.br_mask & ~to_tgt);
        const unsigned before = groups(x);
        for (unsigned l = 0; l != kLanes; ++l)
          if (x.br_mask >> l & 1u)
            x.pc[l] = to_tgt >> l & 1u ? tgt : stay ? x.br_next - x.br_len : x.br_next;
        if ((tmask & x.br_mask) && (tmask & x.br_mask) != x.br_mask) k_.hit("split");
        if (groups(x) < before) k_.hit("reconverge");
        k_.peak("groups_peak", groups(x));
        x.br_mask = 0;
        epoch_[rw & 31] = fe;
        stale_next_ = k_.brk == "stale-epoch" && !stale_done_;
        stale_done_ = stale_done_ || stale_next_;
      }
    }
    // A demotion's migration (TI-24): the warp's PCs out to PCA, one a lane
    // within its window (IS-17). A lane OOE's beats rewound goes at the
    // boundary they named; any other at the next instruction the oracle's
    // order has for it from where fetch had reached, which is the boundary
    // only once OOE sends beats (TI-24 (3), the model's to send).
    if (has(c.rau_fet_mig, 0)) {
      const Bits m = take(c.rau_fet_mig, 0).payload;
      const unsigned w = unsigned(get(m, c.rau_fet_mig, "warp_id"));
      if (get(m, c.rau_fet_mig, "direction") != 0) {
        // A restore: the slot it lands in, before PCA's PCs arrive (A-65).
        Warp &x = warps_[w];
        take_slot(x, unsigned(get(m, c.rau_fet_mig, "tier1_id")));
        x.restoring = true;
      } else {
        Warp &x = warps_[w];
        const auto &recs = k_.orcs[w].recs;
        Bits g = msgOf(c.fet_pca);
        put(g, c.fet_pca, "warp_id", w);
        const FieldDesc &lp = field(c.fet_pca, "lane_pcs");
        const unsigned lw = lp.width / kLanes;
        uint64_t upper = 0;
        for (unsigned l = 0; l != kLanes; ++l) {
          uint64_t pc = recs.empty() ? 0 : recs.back().pc;
          if (x.rewound >> l & 1u) {
            pc = x.lane_pc[l];
          } else {
            for (size_t i = x.next; i < recs.size(); ++i)
              if (recs[i].mask >> l & 1u) { pc = recs[i].pc; break; }
          }
          g.set(lp.lsb + l * lw, lw, pc >> 1);
          upper = pc >> ccv::kWPcWindow;
        }
        put(g, c.fet_pca, "pc_upper", upper);
        // The live lanes after the beats (AR's response TI-27 (b)): every lane
        // a beat names is live again, which undoes an exit the squash took
        // back. Exact by then, so held to the boundary's mask.
        // beats-dead: FET keeps the lanes its fetched exits cleared.
        const uint32_t live = x.lanes | (k_.brk == "beats-dead" ? 0u : x.rewound);
        // The boundary by instruction: a cracked one's later uop (TI-36)
        // names its instruction, which a restore runs again whole.
        size_t bi = x.next;
        if (x.boundary_tid)
          for (size_t i = 0; i != recs.size(); ++i)
            if (warpSeq(w, recs[i].seq) == uidSeq(x.boundary_tid)) { bi = i; break; }
        if (bi < x.lanes_at.size() && live != x.lanes_at[bi])
          k_.fail("fet: warp %u's live mask after the beats is %08x; at its boundary, %08x", w, live,
                  x.lanes_at[bi]);
        put(g, c.fet_pca, "live_mask", live);
        // The fairness state (TI-27 (c)): FET cannot know the boundary's, so it
        // keeps its pointer, moved on to a live lane, and saturates the
        // counter, so lane r's group takes the first pick after the restore.
        unsigned ptr = x.fair_ptr;
        for (unsigned i = 0; live && !(live >> ptr & 1u) && i != kLanes; ++i) ptr = (ptr + 1) % kLanes;
        put(g, c.fet_pca, "fair_ptr", ptr);
        put(g, c.fet_pca, "fair_cnt", fair_n_);
        k_.parked[w].rewound = x.rewound == ~0u;
        if (k_.parked[w].rewound) k_.hit("rewound");
        // The trace identity of where it resumes rides with the PCs to PCA,
        // and back on a restore (trace-only).
        const uint64_t at = x.boundary_tid ? x.boundary_tid
                            : x.next < recs.size() ? instrUid(warpSeq(w, recs[x.next].seq)) : 0;
        pca_q_.push_back({g, at});
      }
    }
    if (!pca_q_.empty() && can(c.fet_pca, 0)) {
      send(c.fet_pca, 0, pca_q_.front().first, pca_q_.front().second);
      pca_q_.pop_front();
    }
    // A restored warp's PCs (IS-17): FET resumes it. This stub fetches in
    // the oracle's order, so it resumes at the record the trace identity
    // names, and holds each lane's PC to that record's.
    if (has(c.pca_fet, 0)) {
      const Receiver::Msg mm = take(c.pca_fet, 0);
      const unsigned w = unsigned(get(mm.payload, c.pca_fet, "warp_id"));
      Warp &x = warps_[w];
      const auto &recs = k_.orcs[w].recs;
      // It resumes at the instruction the identity names, from its first
      // uop: a demotion between a cracked instruction's uops runs it again
      // whole, which both transfers allow (AR's response TI-36).
      // resume-mid: past an instruction whose first uop retired, losing the
      // rest of its uops.
      size_t at = recs.size();
      for (size_t i = 0; i != recs.size(); ++i)
        if (warpSeq(w, recs[i].seq) == uidSeq(mm.tid)) { at = i; break; }
      if (k_.brk == "resume-mid" && uidSub(mm.tid) && at != recs.size()) ++at;
      if (uidSub(mm.tid)) k_.hit("crack_split");
      if (!x.restoring || at == recs.size()) {
        k_.fail("fet: PCs for warp %u, which is not being restored to a known place", w);
      } else {
        const FieldDesc &lp = field(c.pca_fet, "lane_pcs");
        const unsigned lw = lp.width / kLanes;
        const uint64_t up = get(mm.payload, c.pca_fet, "pc_upper");
        for (unsigned l = 0; l != kLanes; ++l) {
          const uint64_t pc = up << ccv::kWPcWindow | mm.payload.get(lp.lsb + l * lw, lw) << 1;
          if ((recs[at].mask >> l & 1u) && pc != recs[at].pc)
            k_.fail("fet: restored warp %u lane %u at %llx, but it resumes at %llx", w, l,
                    (unsigned long long)pc, (unsigned long long)recs[at].pc);
          x.pc[l] = pc;
        }
        // The live lanes and the fairness state come back with the PCs.
        x.lanes = uint32_t(get(mm.payload, c.pca_fet, "live_mask"));
        x.restored = true;
        x.fair_ptr = unsigned(get(mm.payload, c.pca_fet, "fair_ptr"));
        x.fair_cnt = unsigned(get(mm.payload, c.pca_fet, "fair_cnt"));
        x.br_mask = 0;
        x.next = at;
        x.launched = true;
        x.stopped = x.restoring = x.await_redirect = false;
        x.live = 0;
        x.taken_order.clear();
        x.ckpt_of.clear();
        x.rewound = 0;
        x.boundary_tid = 0;
        k_.hit("resumed");
      }
    }
    if (has(c.syu_fet, 0)) {
      // SYU's answer to a parked wait (TI-40). This FET parks none: it marks
      // every wait it follows converged, whose answer goes to OOE, so any
      // answer here is one for lanes not waiting (no-wait-mark's symptom).
      const Bits m = take(c.syu_fet, 0).payload;
      k_.fail("fet: SYU releases warp %u lanes %08x, which are not waiting in FET",
              unsigned(get(m, c.syu_fet, "warp_id")), uint32_t(get(m, c.syu_fet, "lane_mask")));
    }
    if (has(c.ooe_free, 0)) {
      // Checkpoints freed by correct resolutions. Every bit must name one
      // live here when it lands (V-46): a free that overtook its redirect, or
      // one for a squashed branch, would release another branch's.
      Receiver::Msg m = take(c.ooe_free, 0);
      const uint64_t fm = get(m.payload, c.ooe_free, "free_mask");
      for (unsigned b = 0; b != kChans[c.ooe_free].bits; ++b) {
        if (!(fm >> b & 1)) continue;
        const unsigned slot = b / kCkpts, ck = b % kCkpts;
        Warp *x = nullptr;
        for (auto &w : warps_)
          if (w.second.launched && w.second.tier1 == slot) x = &w.second;
        if (!x || !(x->live >> ck & 1)) {
          k_.fail("fet: a free for tier-1 slot %u checkpoint %u, which is not live", slot, ck);
          continue;
        }
        x->live &= ~(1u << ck);
        k_.hit("ckpt_free");
        k_.hit("br_resolved");
        k_.hit("br_resolve_cycles", now_ - x->ckpt_at[ck]);
        for (auto it = x->taken_order.begin(); it != x->taken_order.end(); ++it)
          if (*it == ck) { x->taken_order.erase(it); break; }
      }
    }
    if (has(c.miu_fet, 0)) {
      Receiver::Msg m = take(c.miu_fet, 0);
      // One miss outstanding, so the refill answers the one page waiting.
      if (itlb_wait_.empty()) { k_.fail("fet: an ITLB refill it did not ask for"); }
      else {
        page_[*itlb_wait_.begin()] = get(m.payload, c.miu_fet, "itlb_refill");
        itlb_wait_.erase(itlb_wait_.begin());
      }
    }
    if (has(c.mlc_fet, 0)) {
      Receiver::Msg m = take(c.mlc_fet, 0);
      const unsigned id = unsigned(get(m.payload, c.mlc_fet, "req_id"));
      auto w = ifill_wait_.find(id);
      if (w == ifill_wait_.end()) {
        k_.fail("fet: a fill for req_id %u, which is not outstanding", id);
      } else {
        const uint64_t vl = w->second;
        line_[vl] = getLine(m.payload, field(c.mlc_fet, "line_data").lsb);
        ifill_wait_.erase(w);
        ids_.release(id);
      }
    }
    // Each warp fetches in its tier-1 slot's binding group, the slot RAU
    // placed it in (A-65): slots tier1 * bind_group upward, in order.
    const unsigned bg = kChans[c.fet_dec].bind_group;
    for (auto &wx : warps_) {
    const unsigned w = wx.first;
    Warp &x = wx.second;
    const auto &recs = k_.orcs[w].recs;
    if (x.tier1 == kNoSlot) continue;   // exited or parked, its slot taken
    // AR-24's front-end cost: cycles a warp's fetch waits on a redirect.
    if (x.launched && !x.stopped && x.await_redirect) k_.hit("redirect_wait");
    for (unsigned s = x.tier1 * bg; s != x.tier1 * bg + bg && x.launched && !x.stopped &&
                                    !x.await_redirect &&
                                    x.next != recs.size(); ++s) {
      // FET's own pick, checked against the record ccv-sim issued next.
      // After a restore the saturated counter may pick a group ccv-sim did
      // not (AR's response TI-27 (c)). Checking that order per lane needs
      // instructions ccv-sim never issued, which a trace-driven FET cannot
      // fetch; so a restored warp that departs follows ccv-sim's group,
      // counted, with its fairness state moved as that group's issue moves
      // it. Any other departure is a failure.
      Pick pk = pick(x);
      if (!pk.mask) break;   // no live lane: the warp has exited
      const Record &r = recs[x.next];
      const bool departs = pk.pc != r.pc || pk.mask != r.mask;
      if (departs && x.restored) pk = issued(x, r.pc, r.mask);
      bool ready = true;
      for (uint64_t a = pk.pc / kLine * kLine; a < pk.pc + r.size; a += kLine)
        if (!line_.count(a)) { ready = false; want(a); }
      if (!ready || !can(c.fet_dec, s)) break;
      if (departs && x.restored)
        k_.hit("order_diff");
      else if (departs)
        k_.fail("fet: warp %u picks %llx for lanes %08x; ccv-sim issued %llx for %08x (seq %llu)", w,
                (unsigned long long)pk.pc, pk.mask, (unsigned long long)r.pc, r.mask,
                (unsigned long long)r.seq);
      if (r.kind != "advance" && r.kind != "branch" && r.kind != "branchpred" && r.kind != "exit" &&
          r.kind != "fault" && r.kind != "return")
        k_.fail("fet: warp %u seq %llu is a %s, which this FET does not follow", w,
                (unsigned long long)r.seq, r.kind.c_str());
      uint64_t word = 0;
      for (unsigned b = 0; b != r.size; ++b) {
        const uint64_t a = r.pc + b;
        word |= uint64_t(line_[a / kLine * kLine][a % kLine]) << (8 * b);
      }
      if (k_.brk == "corrupt-fetch" && w == 0 && r.seq == 5) word ^= 0x100;
      Bits f = msgOf(c.fet_dec);
      put(f, c.fet_dec, "warp_id", w);
      put(f, c.fet_dec, "tier1_id", s / kChans[c.fet_dec].bind_group);
      put(f, c.fet_dec, "pc", r.pc);
      put(f, c.fet_dec, "instr", word);
      put(f, c.fet_dec, "length", r.size / 2 - 1);
      // The PC group's lanes and the warp's epoch ride with the instruction
      // (A-69, A-70). FET owns the groups; with no divergence model the
      // group is the lanes ccv-sim issued it to. corrupt-group-mask drops
      // lane 31 from one instruction's group; stale-epoch tags the first
      // instruction after a redirect with the epoch before it.
      uint32_t gmask = r.mask;
      if (k_.brk == "corrupt-group-mask" && w == 0 && r.seq == 5) gmask &= 0x7fffffffu;
      put(f, c.fet_dec, "group_mask", gmask);
      // The final exit (TI-27): the exit whose fetch clears the warp's last
      // live lanes. early-mark marks the first exit that leaves some live.
      if (r.kind == "exit") {
        const bool last = !(x.lanes & ~r.mask);
        const bool early = k_.brk == "early-mark" && !last && !x.marked;
        x.marked = x.marked || early;
        put(f, c.fet_dec, "final_exit", last || early);
      }
      // A barrier wait (TI-40; FET spec rev 22): a wait whose group is every
      // live lane is converged, marked all_waiting, and not parked: OOE holds
      // rename behind it until SYU's answer, and FET fetches on. A diverged
      // wait parks its lanes in FET until SYU answers them on ccv_syu_fet_rel,
      // which this oracle-ordered FET does not model yet: it refuses one.
      // no-wait-mark: the converged wait goes unmarked.
      if (const OpInfo *op = opByName(r.op); op && op->cls == kBarWait) {
        if (r.mask != x.lanes)
          k_.fail("fet: warp %u seq %llu waits at a barrier diverged (lanes %08x of %08x); this FET "
                  "follows converged waits only", w, (unsigned long long)r.seq, r.mask, x.lanes);
        put(f, c.fet_dec, "all_waiting", k_.brk != "no-wait-mark");
        k_.hit("bar_wait");
      }
      const unsigned ep = epoch_[w & 31];
      put(f, c.fet_dec, "fetch_epoch", stale_next_ ? (ep + kEpochs - 1) % kEpochs : ep);
      stale_next_ = false;
      // A branch takes a checkpoint of the PC groups, and FET predicts it.
      // The prediction is static not-taken (uniform-only prediction is the
      // FET session's). With all CCV_P_BR_CKPTS live, fetch stalls until
      // ccv_ooe_fet_ckpt_free or a redirect frees one (A-56). FET cannot
      // fetch a wrong path it has no oracle for, so after a branch it will
      // mispredict it fetches nothing until the redirect: the redirect then
      // frees only the branch's own checkpoint, and no free is ever owed for
      // a squashed branch.
      bool mispredict = false, pred_taken = false;
      if (const OpInfo *op = opByName(r.op); op && op->cls == kBranch) {
        unsigned ck = 0;
        while (ck != kCkpts && (x.live >> ck & 1)) ++ck;
        if (ck == kCkpts) { k_.hit("ckpt_full"); break; }   // every checkpoint live
        x.live |= 1u << ck;
        x.ckpt_at[ck] = now_;
        k_.hit("branches");
        x.taken_order.push_back(ck);
        k_.peak("ckpt_peak", x.taken_order.size());
        x.ckpt_of[r.seq] = ck;
        put(f, c.fet_dec, "checkpoint_id", ck);
        pred_taken = perfect_ && r.taken != 0 && r.taken == r.mask;
        put(f, c.fet_dec, "pred_taken", pred_taken);
        mispredict = r.taken != 0 && !pred_taken;
        if (pred_taken) k_.hit("fet_perfect_taken");
        if (perfect_ && mispredict) k_.hit("fet_perfect_split");
      }
      send(c.fet_dec, s, f, instrUid(warpSeq(w, r.seq)));
      if (!k_.fetched) { k_.fetched = true; k_.first_fetch = now_; }
      if (r.kind == "return") k_.hit("ret");
      else if (r.op == "CALL") k_.hit("call");
      // The pick is made: record the fairness state it started from, take
      // the new one, and move the group's lanes on. After a mismatch the
      // record's lanes move, so one wrong pick is reported once.
      if (x.lanes_at.size() <= x.next) x.lanes_at.resize(x.next + 1);
      x.lanes_at[x.next] = x.lanes;
      x.fair_ptr = pk.ptr;
      x.fair_cnt = pk.cnt;
      if (pk.fair) k_.hit("fair_pick");
      const unsigned before = groups(x);
      if (r.kind == "exit") {
        x.lanes &= ~r.mask;
      } else if (mispredict) {
        x.br_mask = r.mask;      // split or moved at the redirect
        x.br_next = r.pc + r.size;
        x.br_len = r.size;
      } else if (pred_taken) {
        for (unsigned l = 0; l != kLanes; ++l)
          if (r.mask >> l & 1u) x.pc[l] = r.target;
        if (groups(x) < before) k_.hit("reconverge");
      } else {
        for (unsigned l = 0; l != kLanes; ++l)
          if (r.mask >> l & 1u) x.pc[l] = r.pc + r.size;
        if (groups(x) < before) k_.hit("reconverge");
      }
      ++x.next;
      if (mispredict) { x.await_redirect = true; break; }
    }
    }
    if (!itlbs_.empty() && can(c.fet_miu, 0)) {
      send(c.fet_miu, 0, itlbs_.front().msg, itlbs_.front().tid);
      itlbs_.pop_front();
    }
    if (!fills_.empty() && can(c.fet_mlc, 0)) {
      send(c.fet_mlc, 0, fills_.front().msg, fills_.front().tid);
      fills_.pop_front();
    }
  }

  /// Ask for a line: translate its page first, then fill it. Each once.
  void want(uint64_t vline) {
    const Ch &c = ch();
    const uint64_t vp = vline / kPage;
    for (auto &w : ifill_wait_) if (w.second == vline) return;
    auto p = page_.find(vp);
    if (p == page_.end()) {
      // At most ONE miss outstanding: the refill names no page, so a second
      // miss would be unmatchable. Asserted across the pair by the bank's
      // ccv_common_chk_outstanding. itlb-double breaks it on purpose, by also
      // asking for the next page.
      if (!itlb_wait_.empty()) return;
      if (k_.brk == "itlb-double") {
        Bits r2 = msgOf(c.fet_miu);
        put(r2, c.fet_miu, "virtual_page", vp + 1);
        itlbs_.push_back({0, r2, makeUid(IdClass::kTxn, g_unowned_txn++)});
        itlb_wait_.insert(vp + 1);
      }
      Bits r = msgOf(c.fet_miu);
      put(r, c.fet_miu, "virtual_page", vp);
      itlbs_.push_back({0, r, makeUid(IdClass::kTxn, g_unowned_txn++)});
      itlb_wait_.insert(vp);
      return;
    }
    if (!ids_.any()) return;                 // all fills in flight: wait
    Bits r = msgOf(c.fet_mlc);
    const unsigned id = ids_.take();
    put(r, c.fet_mlc, "req_id", id);
    const uint64_t pa = p->second * kPage + vline % kPage;
    put(r, c.fet_mlc, "phys_addr", pa);
    const uint64_t tid = makeUid(IdClass::kTxn, g_unowned_txn++);
    fills_.push_back({0, r, tid});
    ifill_wait_[id] = vline;
  }

  bool busy() const override {
    bool left = false;
    for (auto &w : warps_)
      left = left || (w.second.launched && !w.second.stopped &&
                      w.second.next != k_.orcs[w.first].recs.size());
    return left || !itlb_wait_.empty() ||
           !ifill_wait_.empty() || !fills_.empty() || !itlbs_.empty() || !pca_q_.empty();
  }
};

// ---- RAU: launches the kernel's warps, and swaps them ------------------------------

/// One warp a CTA (ccv-sim's model). RAU holds CCV_TIER1_WARPS slots and
/// gives a free one to the oldest ready warp: one waiting to launch, ready
/// from the start, before one parked in PCA. A launch is the warp's
/// allocation, its CTA configured, then FET's launch, each a message a
/// channel a cycle; an exit frees its slot (ccv_ooe_rau_status exited,
/// TI-24 (2)).
///
/// Swaps (TI-24, aligned with OI's swap environment, sim/ooe/ooe_test.cpp):
/// OOE raises the triggers at the ROB head and reports them on
/// ccv_ooe_rau_status (Q18); RAU decides. CCV_RAU_DEMOTE=mlc demotes on a
/// report whose head load is outstanding past the threshold (the trigger),
/// =fallback on any stall report, and unset demotes nothing. One demotion
/// and one restore at a time, and a restored warp is not demoted again until
/// it has retired CCV_RAU_P instructions (8, the environment's P). A
/// demotion: drained -> the three commands out -> PCA's ack -> free. A
/// restore: restore-allocate (OOE allocates and sends RCU its map) -> the
/// three commands in -> PCA's ack, once every row is written ->
/// restore-activate. CCV_RAU_RESTORE=0 keeps what it parks, which ends its
/// run parked.
class Rau : public Stub {
public:
  Rau(int inst, Kernel &k) : Stub(inst, k) {
    k.restores = restore_;
    for (unsigned s = 0; s != ccv::kTier1Warps; ++s) free_.insert(s);
    for (unsigned w = 0; w != k.orcs.size(); ++w) waiting_.push_back(w);
  }
  const char *kind() const override { return "rau"; }

private:
  static const char *env(const char *n, const char *d) { return getenv(n) ? getenv(n) : d; }
  const std::string policy_ = env("CCV_RAU_DEMOTE", "");
  const bool restore_ = std::string(env("CCV_RAU_RESTORE", "1")) != "0";
  const unsigned P_ = unsigned(std::strtoul(env("CCV_RAU_P", "8"), nullptr, 0));
  /// CCV_RAU_CONCURRENT=1 lets demotions overlap, where the environment's
  /// RAU runs one at a time and declines a report that arrives meanwhile:
  /// a stress knob, for runs that need several warps parked at once.
  const bool concurrent_ = std::string(env("CCV_RAU_CONCURRENT", "0")) == "1";
  /// RAU restores only warps MIU has reported ready (RAU spec rev 25).
  /// CCV_RAU_READY=0 also restores one that is not into a slot that would
  /// otherwise idle, provisionally (AR's rev 115; about 1% lost on OI's
  /// sweep, so a knob, and provswap keeps it covered).
  const bool provisional_on_ = std::string(env("CCV_RAU_READY", "1")) == "0";
  /// Evict (DA, 2026-10-22, TI-21): RAU demotes a warp its trigger names
  /// whether or not another warp waits for the slot. CCV_RAU_MODE=swap
  /// demotes only when one does: a ready parked warp or a launch.
  const bool swap_ = std::string(env("CCV_RAU_MODE", "evict")) == "swap";

  std::set<unsigned> free_;                  ///< tier-1 slots
  std::map<unsigned, unsigned> slot_of_;     ///< resident or moving warp -> its slot
  std::deque<unsigned> waiting_;             ///< warps not yet launched, in order
  std::deque<unsigned> parked_;              ///< in PCA, oldest first
  std::set<unsigned> restored_;              ///< restored at least once
  std::map<unsigned, unsigned> retired_;     ///< last retired_since_restore reported
  std::set<unsigned> demoting_;              ///< demoted, not yet parked
  std::set<unsigned> ready_;                 ///< MIU's orphans home since the last demote (TI-21)
  /// Restored before its ready report (RAU spec rev 24): it may demote
  /// whenever a ready warp or a launch wants its slot, and its P count
  /// starts at the report, from the retirements counted then.
  std::set<unsigned> provisional_;
  std::map<unsigned, unsigned> p_base_;
  std::set<unsigned> exited_;                ///< exited while RAU demotes it, awaiting the refusal (TI-25)
  bool restore_busy_ = false;

  /// Messages to OOE on ccv_rau_ooe_alloc, in order: a free lands before
  /// the slot's next allocation.
  struct AllocMsg { Bits m; int launch = -1; };   ///< launch: the warp it allocates
  std::deque<AllocMsg> alloc_q_;
  /// A launch's CTA configuration and FET's launch, after its allocation.
  struct Launch { unsigned w, slot; bool cta = false; };
  std::deque<Launch> launch_q_;
  /// A migration's three commands, to RCU, FET and PCA (A-45; TI-24 (1)),
  /// in that order, either way.
  struct Mig { unsigned w, slot, place, dir, sent; };
  std::deque<Mig> mig_q_;
  std::set<unsigned> places_ = [] {
    std::set<unsigned> p;
    for (unsigned i = 0; i != ccv::kParkedWarps; ++i) p.insert(i);
    return p;
  }();
  std::map<unsigned, unsigned> place_of_;    ///< parked or moving warp -> its place

  /// RAU's warp-to-CTA table: a CTA slot per CTA, whose warps all name it
  /// (CP-30). cta-per-warp gives each warp its own; cta-shared gives every
  /// warp slot 0.
  unsigned ctaSlot(unsigned w) const {
    return k_.brk == "cta-per-warp" ? w : k_.brk == "cta-shared" ? 0 : k_.cta_of[w];
  }
  std::set<unsigned> cta_sent_;              ///< CTA slots whose rau_miu_cta is out
  static constexpr unsigned kBarriers = 1u << ccv::kWBarId;
  /// SYU's allocate, demote, restore and free (TI-40), in order.
  std::deque<Bits> syu_q_;
  std::set<unsigned> syu_ready_;             ///< SYU's answer since the last demote (TI-40)
  std::map<unsigned, unsigned> cta_left_;    ///< warps of each CTA slot not yet exited
  void syuOp(unsigned op, unsigned w) {
    const Ch &c = ch();
    Bits m = msgOf(c.rau_syu);
    put(m, c.rau_syu, "syu_alloc_op", op);
    put(m, c.rau_syu, "cta_slot", ctaSlot(w));
    put(m, c.rau_syu, "warp_id", w);
    if (op == kSyuAlloc || op == kSyuFree) {
      // The CTA whole (AR's rev 161): its warp contexts, its entries, and
      // its last warp's live lanes less one; every other warp has 32.
      uint32_t mask = 0;
      unsigned last = w;
      for (unsigned v = 0; v != k_.orcs.size(); ++v)
        if (ctaSlot(v) == ctaSlot(w)) {
          mask |= 1u << (v & 31);
          if (k_.orcs[v].warp_in_cta >= k_.orcs[last].warp_in_cta) last = v;
        }
      const Oracle &o = k_.orcs[last];
      const unsigned first = 32 * o.warp_in_cta;
      const unsigned n = !o.threads ? kLanes : o.threads <= first ? 1 : std::min(o.threads - first, kLanes);
      put(m, c.rau_syu, "warp_id", last);
      put(m, c.rau_syu, "warp_mask", mask);
      put(m, c.rau_syu, "last_lanes", n - 1);
      put(m, c.rau_syu, "barrier_base", ctaSlot(w) * kBarriers % (1u << ccv::kWBarEntry));
      put(m, c.rau_syu, "barrier_count", kBarriers);
      if (op == kSyuAlloc) cta_left_[ctaSlot(w)] = unsigned(__builtin_popcount(mask));
    }
    syu_q_.push_back(m);
  }
  /// Restorable: MIU's orphans home, and SYU's answer in (TI-21, TI-40).
  bool isReady(unsigned w) const { return ready_.count(w) && syu_ready_.count(w); }

  Bits allocMsg(unsigned w, unsigned slot, unsigned op) {
    const Ch &c = ch();
    Bits a = msgOf(c.rau_ooe);
    put(a, c.rau_ooe, "warp_id", w);
    put(a, c.rau_ooe, "alloc_op", op);
    put(a, c.rau_ooe, "tier1_id", slot);
    if (op == kAllocLaunch || op == 2) {
      // Identity from RAU's warp-to-CTA table: each warp warp 0 of its CTA.
      put(a, c.rau_ooe, "ctaid", k_.orcs[w].ctaid + (k_.brk == "corrupt-ctaid" ? 1u : 0u));
      put(a, c.rau_ooe, "warp_in_cta", k_.orcs[w].warp_in_cta);
      // The CTA's barriers, the launch's (AR's rev 159 (3)): ccv-sim runs with
      // -barriers, 16 by default, until Q-50's descriptor carries them.
      put(a, c.rau_ooe, "barrier_count", kBarriers);
      // Its CTA's slot (TI-34): the one rau_miu_cta names. Recorded for the
      // checks on what OOE stamps with it.
      put(a, c.rau_ooe, "cta_slot", ctaSlot(w));
      k_.cta_slot_of[w] = ctaSlot(w);
    }
    return a;
  }

  /// A free slot to the oldest ready warp: a launch, else a parked warp.
  void place() {
    while (!free_.empty() && !waiting_.empty()) {
      const unsigned slot = *free_.begin(), w = waiting_.front();
      free_.erase(free_.begin());
      waiting_.pop_front();
      slot_of_[w] = slot;
      alloc_q_.push_back({allocMsg(w, slot, kAllocLaunch), int(w)});
      launch_q_.push_back({w, slot});
    }
    // The oldest parked warp MIU has reported ready: its replayed loads hit.
    // With none, and no launch pending, the oldest parked warp,
    // provisionally: the slot would idle, and its replay merges at DCU
    // into the fill in flight, so the wait saves nothing.
    auto p = parked_.begin();
    while (p != parked_.end() && !isReady(*p)) ++p;
    bool prov = false;
    if (p == parked_.end() && provisional_on_ && waiting_.empty() && !parked_.empty()) {
      p = parked_.begin();
      prov = true;
    }
    if (!free_.empty() && p != parked_.end() && !restore_busy_ && restore_) {
      const unsigned slot = *free_.begin(), w = *p;
      if (prov) {
        provisional_.insert(w);
        k_.hit("provisional");
      }
      p_base_[w] = retired_[w] = 0;   // OOE counts from the restore
      free_.erase(free_.begin());
      parked_.erase(p);
      slot_of_[w] = slot;
      restore_busy_ = true;
      alloc_q_.push_back({allocMsg(w, slot, 2), -1});   // restore-allocate (A-64)
      mig_q_.push_back({w, slot, place_of_[w], 1, 0});
    }
  }

  void status() {
    const Ch &c = ch();
    if (!has(c.ooe_status, 0)) return;
    const Bits m = take(c.ooe_status, 0).payload;
    const unsigned w = unsigned(get(m, c.ooe_status, "warp_id"));
    retired_[w] = unsigned(get(m, c.ooe_status, "retired_since_restore"));
    // A fatal fault (IS-2): RAU kills the context, every valid warp context
    // of it, and launches nothing more for it.
    if (get(m, c.ooe_status, "fault_taken")) {
      startKill(w);
      return;
    }
    if (get(m, c.ooe_status, "exited")) {
      // An exit that raced its own demotion (TI-25): OOE refuses the
      // demote, and the slot is freed once the refusal is in, so the free
      // never overtakes the demote at OOE.
      if (demoting_.count(w)) {
        exited_.insert(w);
        return;
      }
      exit(w);
      return;
    }
    const bool want = policy_ == "fallback" ? get(m, c.ooe_status, "stalled") != 0
                      : policy_ == "mlc"    ? get(m, c.ooe_status, "mlc_miss_seen") != 0
                                            : false;
    if (want) demote(w);
  }
  /// The exit's quiesce: free the slot, and with it the CTA's (one warp a
  /// CTA, so every exit is its CTA's last).
  void exit(unsigned w) {
    auto s = slot_of_.find(w);
    if (s == slot_of_.end()) { k_.fail("rau: warp %u exits, and holds no slot", w); return; }
    k_.snapshotFinal(w);
    alloc_q_.push_back({allocMsg(w, s->second, kAllocFree), -1});
    free_.insert(s->second);
    slot_of_.erase(s);
    // The CTA's last warp: its barrier entries go (TI-40).
    if (cta_left_.count(ctaSlot(w)) && --cta_left_[ctaSlot(w)] == 0) syuOp(kSyuFree, w);
    k_.hit("slot_reuse", waiting_.empty() && parked_.empty() ? 0 : 1);
  }

  /// The kill (V-24; RAU spec, Kill): the mask of every valid warp context,
  /// resident, moving or parked, broadcast with an epoch, kill_valid a cycle
  /// ahead of the mask; then the eight owners' acks, each counted only at
  /// this epoch (a late ack from an earlier kill cannot satisfy this one);
  /// then RAU's tables let the killed warps go. no-kill: RAU never kills.
  enum class Kill { kNone, kValid, kWait } kill_ = Kill::kNone;
  uint32_t kill_mask_ = 0, kill_acked_ = 0;
  unsigned kill_epoch_ = 0;
  void startKill(unsigned faulted) {
    if (kill_ != Kill::kNone || k_.brk == "no-kill") return;
    k_.snapshotFinal(faulted);   // its state at the fault, before OOE releases it
    uint32_t mask = 0;
    for (const auto &s : slot_of_) mask |= 1u << (s.first & 31);
    for (unsigned w : parked_) mask |= 1u << (w & 31);
    for (unsigned w : demoting_) mask |= 1u << (w & 31);
    for (const auto &p : place_of_) mask |= 1u << (p.first & 31);
    kill_mask_ = mask;
    kill_epoch_ = (kill_epoch_ + 1) % (1u << ccv::prov::kWKillEpoch);
    kill_acked_ = 0;
    kill_ = Kill::kValid;
    // Nothing more launches for the context: a warp still waiting is gone.
    for (unsigned w : waiting_) k_.killed.insert(w);
    waiting_.clear();
    k_.hit("kill");
  }
  void killStep() {
    if (kill_ == Kill::kValid) {
      fabOut("kill_valid", 1);
      kill_ = Kill::kWait;
      return;
    }
    if (kill_ != Kill::kWait) return;
    fabOut("kill_warp_mask", kill_mask_);
    fabOut("kill_epoch", kill_epoch_);
    const FabDesc &acks = Stub::fab("kill_ack");
    for (unsigned i = 0; i != acks.nblks; ++i)
      if (fabIn("kill_ack", i) && fabIn("kill_ack_epoch", i) == kill_epoch_) kill_acked_ |= 1u << i;
    k_.kill_unacked = ((1u << acks.nblks) - 1) & ~kill_acked_;
    if (k_.kill_unacked) return;
    // Every owner has quiesced: the killed warps hold nothing anywhere.
    for (unsigned w = 0; w != 32; ++w) {
      if (!(kill_mask_ >> w & 1u)) continue;
      k_.killed.insert(w);
      auto s = slot_of_.find(w);
      if (s != slot_of_.end()) { free_.insert(s->second); slot_of_.erase(s); }
      auto p = place_of_.find(w);
      if (p != place_of_.end()) { places_.insert(p->second); place_of_.erase(p); }
      parked_.erase(std::remove(parked_.begin(), parked_.end(), w), parked_.end());
      demoting_.erase(w);
      ready_.erase(w);
      syu_ready_.erase(w);
      provisional_.erase(w);
      exited_.erase(w);
    }
    launch_q_.clear();
    mig_q_.clear();
    demote_q_.clear();
    restore_busy_ = false;
    kill_ = Kill::kNone;
  }

  /// A ready parked warp or a launch waits for a slot: what lets a
  /// provisional warp demote, and any warp under swap.
  bool wanted() const {
    if (!waiting_.empty()) return true;
    for (unsigned w : parked_)
      if (isReady(w)) return true;
    return false;
  }

  void demote(unsigned w) {
    const Ch &c = ch();
    if ((!concurrent_ && !demoting_.empty()) || demoting_.count(w) || !slot_of_.count(w) || k_.parkedNow(w) ||
        (k_.parked.count(w) && !k_.parked[w].restored) ||
        (restored_.count(w) && (!provisional_.count(w) || k_.brk == "guard-at-restore") &&
         retired_[w] < p_base_[w] + P_) ||
        (provisional_.count(w) && !wanted() && k_.brk != "demote-unwanted") ||
        (swap_ && !wanted()))
      return;
    if (provisional_.erase(w)) k_.hit("prov_demote");
    demoting_.insert(w);
    ready_.erase(w);   // the demotion's own discard reports it again
    syu_ready_.erase(w);
    syuOp(kSyuDemote, w);   // SYU answers its waits to RAU from now (TI-40)
    k_.parked[w] = Kernel::Parked();
    Bits d = msgOf(c.rau_demote);
    put(d, c.rau_demote, "warp_id", w);
    put(d, c.rau_demote, "squash_to_retirement", 1);
    demote_q_.push_back(d);
  }
  std::deque<Bits> demote_q_;

  /// OOE's drained report: a demotion's migration starts, or, refused, ends.
  void drained(const Bits &m) {
    const Ch &c = ch();
    const unsigned w = unsigned(get(m, c.ooe_drained, "warp_id"));
    if (!demoting_.count(w) || !slot_of_.count(w)) k_.fail("rau: warp %u drained, but RAU never demoted it", w);
    if (get(m, c.ooe_drained, "refused") && k_.brk != "ignore-refused") {
      // Refused (TI-25): the exit retired first. No migration; the exit
      // frees the slot, now if its report is in, else when it comes.
      demoting_.erase(w);
      k_.parked.erase(w);
      syuOp(kSyuRestore, w);   // resident after all
      k_.hit("refused");
      if (exited_.erase(w)) exit(w);
      return;
    }
    if (exited_.count(w))
      k_.fail("rau: warp %u drained after its exit retired, where OOE refuses (TI-25)", w);
    k_.parked[w].resume_pc = get(m, c.ooe_drained, "resume_pc");
    if (places_.empty()) {
      k_.fail("rau: warp %u drained, and PCA has no free place", w);
    } else {
      const unsigned pl = *places_.begin();
      // pca-place: a place handed out and never taken off the free list,
      // so the next demotion gets it again and PCA must refuse it.
      if (k_.brk != "pca-place") places_.erase(places_.begin());
      place_of_[w] = pl;
      mig_q_.push_back({w, slot_of_[w], pl, 0, 0});
    }
  }

  void migration() {
    const Ch &c = ch();
    const uint64_t none = makeUid(IdClass::kNone, 0);
    if (!demote_q_.empty() && can(c.rau_demote, 0)) {
      send(c.rau_demote, 0, demote_q_.front(), none);
      k_.hit("demote");
      demote_q_.pop_front();
    }
    if (has(c.miu_ready, 0)) {
      const unsigned w = unsigned(get(take(c.miu_ready, 0).payload, c.miu_ready, "warp_id"));
      ready_.insert(w);
      k_.hit("ready");
      // A provisional warp's report clears the mark and starts its P count.
      if (provisional_.erase(w)) p_base_[w] = retired_[w];
    }
    if (has(c.syu_rau, 0)) {
      syu_ready_.insert(unsigned(get(take(c.syu_rau, 0).payload, c.syu_rau, "warp_id")));
      k_.hit("syu_ready");
    }
    if (!syu_q_.empty() && can(c.rau_syu, 0)) {
      send(c.rau_syu, 0, syu_q_.front(), none);
      syu_q_.pop_front();
    }
    if (has(c.ooe_drained, 0)) drained(take(c.ooe_drained, 0).payload);
    // The three commands, either way: to FET also the slot (vacated or
    // taken), to PCA the place.
    if (!mig_q_.empty()) {
      Mig &g = mig_q_.front();
      if (g.dir == 1 && g.sent == 0 && !alloc_q_.empty()) {
        // the restore-allocate goes first, so OOE's map is on its way
      } else if (g.sent == 0 && can(c.rau_rcu_mig, 0)) {
        Bits r = msgOf(c.rau_rcu_mig);
        put(r, c.rau_rcu_mig, "warp_id", g.w);
        put(r, c.rau_rcu_mig, "direction", g.dir);
        send(c.rau_rcu_mig, 0, r, none);
        ++g.sent;
      } else if (g.sent == 1 && can(c.rau_fet_mig, 0)) {
        Bits f = msgOf(c.rau_fet_mig);
        put(f, c.rau_fet_mig, "warp_id", g.w);
        put(f, c.rau_fet_mig, "tier1_id", g.slot);
        put(f, c.rau_fet_mig, "direction", g.dir);
        send(c.rau_fet_mig, 0, f, none);
        ++g.sent;
      } else if (g.sent == 2 && can(c.rau_pca_mig, 0)) {
        Bits q = msgOf(c.rau_pca_mig);
        put(q, c.rau_pca_mig, "warp_id", g.w);
        put(q, c.rau_pca_mig, "direction", g.dir);
        put(q, c.rau_pca_mig, "pca_place", g.place);
        send(c.rau_pca_mig, 0, q, none);
        mig_q_.pop_front();
      }
    }
    if (has(c.pca_done, 0)) {
      const Bits m = take(c.pca_done, 0).payload;
      const unsigned w = unsigned(get(m, c.pca_done, "warp_id"));
      const unsigned dir = unsigned(get(m, c.pca_done, "direction"));
      if (dir == 0 && demoting_.count(w) && slot_of_.count(w)) {
        // PCA holds both halves: OOE frees the warp's registers now and
        // not before (V-27), and the slot goes to the oldest ready warp.
        alloc_q_.push_back({allocMsg(w, slot_of_[w], kAllocFree), -1});
        free_.insert(slot_of_[w]);
        slot_of_.erase(w);
        parked_.push_back(w);
        demoting_.erase(w);
        k_.parked[w].done = true;
        k_.checkParked(w);
        k_.hit("parked");
      } else if (dir == 1 && restore_busy_ && slot_of_.count(w)) {
        // Every row written: the warp may issue (A-64).
        alloc_q_.push_back({allocMsg(w, slot_of_[w], 3), -1});   // restore-activate
        syuOp(kSyuRestore, w);
        places_.insert(place_of_[w]);
        place_of_.erase(w);
        restore_busy_ = false;
        restored_.insert(w);
        k_.parked[w].restored = true;
        k_.hit("restored");
      } else {
        k_.fail("rau: PCA acks a migration of warp %u (direction %u) that RAU did not start", w, dir);
      }
    }
  }

  void work() override {
    const Ch &c = ch();
    const uint64_t none = makeUid(IdClass::kNone, 0);
    status();
    killStep();
    if (kill_ != Kill::kNone) {
      // Nothing launches or moves meanwhile. Reports about warps being
      // killed (ready, drained, a migration's ack) are taken and dropped.
      if (has(c.miu_ready, 0)) take(c.miu_ready, 0);
      if (has(c.syu_rau, 0)) take(c.syu_rau, 0);
      if (has(c.ooe_drained, 0)) take(c.ooe_drained, 0);
      if (has(c.pca_done, 0)) take(c.pca_done, 0);
      return;
    }
    // CCV_RAU_DEMOTE=at:<cycle>: a stimulus, not a policy. Every resident
    // warp is demoted at that cycle, wherever its retirement stands, so a
    // sweep of the cycle lands a demotion between a cracked instruction's
    // uops (AR's response TI-36).
    if (policy_.compare(0, 3, "at:") == 0 && now_ == std::strtoull(policy_.c_str() + 3, nullptr, 0)) {
      std::vector<unsigned> res;
      for (const auto &kv : slot_of_) res.push_back(kv.first);
      for (unsigned w : res) demote(w);
    }
    migration();
    place();
    if (!alloc_q_.empty() && can(c.rau_ooe, 0)) {
      send(c.rau_ooe, 0, alloc_q_.front().m, none);
      // A launch's CTA and FET's launch follow its own allocation.
      for (Launch &l : launch_q_)
        if (int(l.w) == alloc_q_.front().launch) l.cta = true;
      alloc_q_.pop_front();
    }
    // Launch last, once the warp's allocation is sent, so its registers
    // exist before its first instruction can reach them.
    if (!launch_q_.empty() && launch_q_.front().cta) {
      Launch &l = launch_q_.front();
      // The CTA's configuration goes to MIU once, with its first warp.
      const unsigned cs = ctaSlot(l.w);
      const bool first = !cta_sent_.count(cs);
      if ((!first || can(c.rau_miu, 0)) && can(c.rau_fet, 0)) {
        if (first) {
          Bits a = msgOf(c.rau_miu);
          put(a, c.rau_miu, "cta_slot", cs);
          // F-RO's .const range, the grid's from its module (TI-26): the
          // launch's, which ccv-sim was run with, until Q-50's descriptor.
          put(a, c.rau_miu, "const_base", k_.orcs[l.w].const_base);
          put(a, c.rau_miu, "const_limit", k_.orcs[l.w].const_limit);
          // Where MIU's window table fills from (TI-31).
          put(a, c.rau_miu, "launch_block_addr", k_.orcs[l.w].launch_block);
          send(c.rau_miu, 0, a, none);
          cta_sent_.insert(cs);
          syuOp(kSyuAlloc, l.w);   // the CTA's barriers, before any warp of it runs
        }
        const Oracle &o = k_.orcs[l.w];
        Bits f = msgOf(c.rau_fet);
        put(f, c.rau_fet, "warp_id", l.w);
        put(f, c.rau_fet, "tier1_id", l.slot);
        put(f, c.rau_fet, "cta_slot", cs);
        put(f, c.rau_fet, "start_pc", o.code_base + k_.orcs[0].entry);
        // The warp's lanes (AR's responses TI-27 (a), rev 134): [0, n), n
        // the CTA's threads past this warp's first, T - 32 x warp_in_cta, at
        // most 32. T is the launch's, which ccv-sim was run with.
        // whole-cta-mask: every warp takes the CTA's first warp's lanes.
        const unsigned first = k_.brk == "whole-cta-mask" ? 0 : 32 * o.warp_in_cta;
        const unsigned n = !o.threads ? kLanes : o.threads <= first ? 0 : std::min(o.threads - first, kLanes);
        put(f, c.rau_fet, "live_mask", n == kLanes ? ~0u : (1u << n) - 1);
        // code_bounds: [63:0] base, [103:64] length (placeholder split).
        const FieldDesc &cb = field(c.rau_fet, "code_bounds");
        f.set(cb.lsb, 64, o.code_base);
        f.set(cb.lsb + 64, cb.width - 64, o.code.size());
        send(c.rau_fet, 0, f, none);
        launch_q_.pop_front();
      }
    }
  }
  bool busy() const override {
    return !waiting_.empty() || !launch_q_.empty() || !alloc_q_.empty() || !mig_q_.empty() ||
           !demote_q_.empty() || !demoting_.empty() || restore_busy_ || (restore_ && !parked_.empty()) ||
           !exited_.empty() || kill_ != Kill::kNone || !syu_q_.empty();
  }
};

// ---- PCA: the parked contexts ------------------------------------------------------

/// Demotion only (TI-24): PCA takes a warp's rows from RCU and its PC groups
/// from FET, and acks once it holds both. The rows are whole when the
/// predicate row (mig_row CCV_GPRS) lands, which RCU sends last (TI-24 (4)).
/// No restore: nothing commands PCA to send a warp back (TI-24 (1), Q-39).
class Pca : public Stub {
public:
  using Stub::Stub;
  const char *kind() const override { return "pca"; }

private:
  /// A demotion in progress, by warp until RAU's command names its place:
  /// the rows, the PCs, and the command, in any order.
  struct Ctx {
    std::map<unsigned, std::array<uint32_t, kLanes>> rows;
    bool preds = false, pcs = false, cmd = false;
    unsigned place = 0;
    Bits pc_msg;
    uint64_t pc_tid = 0;
  };
  std::map<unsigned, Ctx> ctx_;
  /// The parked array, by place: the rows, and the PCs as FET sent them,
  /// with the trace identity FET's message carried (a trace-driven FET's
  /// place in the oracle's order, trace-only).
  struct Place { unsigned warp = 0; std::map<unsigned, std::array<uint32_t, kLanes>> rows; Bits pcs; uint64_t tid = 0; };
  std::map<unsigned, Place> array_;
  /// Acks to RAU, warp and direction.
  std::deque<std::pair<unsigned, unsigned>> done_;
  /// A restore in progress (TI-24 (1)): its rows to RCU in their saved
  /// order, the predicate row last, its PCs to FET, then the ack once every
  /// row's credit is home, which is when RCU has written it (TI-13).
  struct Out { unsigned w; std::deque<Bits> rows; bool pcs_sent = false; Bits pcs; uint64_t tid; };
  std::deque<Out> out_;
  uint64_t hold_until_ = 0;            ///< early-restore-done's delay

  /// A kill drops every killed warp's context, parked or moving (V-24).
  void onKill(uint32_t mask, unsigned) override {
    for (auto it = ctx_.begin(); it != ctx_.end();)
      it = mask >> (it->first & 31) & 1u ? ctx_.erase(it) : std::next(it);
    for (auto it = array_.begin(); it != array_.end();)
      it = mask >> (it->second.warp & 31) & 1u ? array_.erase(it) : std::next(it);
    for (auto it = out_.begin(); it != out_.end();)
      it = mask >> (it->w & 31) & 1u ? out_.erase(it) : std::next(it);
    for (auto it = done_.begin(); it != done_.end();)
      it = mask >> (it->first & 31) & 1u ? done_.erase(it) : std::next(it);
  }

  void work() override {
    const Ch &c = ch();
    const uint64_t none = makeUid(IdClass::kNone, 0);
    if (has(c.rau_pca_mig, 0)) {
      const Bits m = take(c.rau_pca_mig, 0).payload;
      const unsigned w = unsigned(get(m, c.rau_pca_mig, "warp_id"));
      const unsigned pl = unsigned(get(m, c.rau_pca_mig, "pca_place"));
      if (get(m, c.rau_pca_mig, "direction") == 0) {
        if (array_.count(pl)) k_.fail("pca: place %u is already held, by warp %u", pl, array_[pl].warp);
        // or claimed by a demotion still arriving
        for (auto &[v, x] : ctx_)
          if (v != w && x.cmd && x.place == pl)
            k_.fail("pca: place %u is already held, by warp %u", pl, v);
        ctx_[w].cmd = true;
        ctx_[w].place = pl;
        check(w);
      } else {
        auto a = array_.find(pl);
        if (a == array_.end() || a->second.warp != w) {
          k_.fail("pca: a restore of warp %u from place %u, which does not hold it", w, pl);
        } else {
          Out o{w, {}, false, a->second.pcs, a->second.tid};
          const unsigned dl = field(c.pca_rcu, "row_data").lsb;
          for (auto &[r, row] : a->second.rows) {      // ascending: GPR rows, then predicates
            Bits b = msgOf(c.pca_rcu);
            put(b, c.pca_rcu, "warp_id", w);
            put(b, c.pca_rcu, "mig_row", r);
            for (unsigned l = 0; l != kLanes; ++l) b.set(dl + 32 * l, 32, row[l]);
            o.rows.push_back(b);
          }
          // pca-row-order: the GPR rows renumbered last to first, so RCU
          // writes each into another register's row.
          if (k_.brk == "pca-row-order" && o.rows.size() > 2) {
            std::vector<unsigned> rs;
            for (auto &[r, row] : a->second.rows) if (r < kArchGprs) rs.push_back(r);
            for (size_t i = 0; i != rs.size(); ++i) put(o.rows[i], c.pca_rcu, "mig_row", rs[rs.size() - 1 - i]);
          }
          out_.push_back(o);
          array_.erase(a);
        }
      }
    }
    if (has(c.rcu_pca, 0)) {
      const Bits m = take(c.rcu_pca, 0).payload;
      const unsigned w = unsigned(get(m, c.rcu_pca, "warp_id"));
      const unsigned r = unsigned(get(m, c.rcu_pca, "mig_row"));
      const unsigned dl = field(c.rcu_pca, "row_data").lsb;
      std::array<uint32_t, kLanes> row{};
      for (unsigned l = 0; l != kLanes; ++l) row[l] = uint32_t(m.get(dl + 32 * l, 32));
      Ctx &x = ctx_[w];
      x.rows[r] = row;
      k_.parked[w].rows[r] = row;
      if (r >= kArchGprs) x.preds = true;
      check(w);
    }
    if (has(c.fet_pca, 0)) {
      const Receiver::Msg mm = take(c.fet_pca, 0);
      const Bits &m = mm.payload;
      const unsigned w = unsigned(get(m, c.fet_pca, "warp_id"));
      // The PCs, as FET sent them (IS-17): recorded per lane for the check.
      const FieldDesc &lp = field(c.fet_pca, "lane_pcs");
      const uint64_t up = get(m, c.fet_pca, "pc_upper");
      const unsigned lw = lp.width / kLanes;
      for (unsigned l = 0; l != kLanes; ++l)
        k_.parked[w].lane_pc[l] = up << ccv::kWPcWindow | m.get(lp.lsb + l * lw, lw) << 1;
      Ctx &x = ctx_[w];
      x.pcs = true;
      x.pc_msg = m;
      x.pc_tid = mm.tid;
      check(w);
    }
    // A restore: one row a cycle, then the PCs, then the ack.
    // early-restore-done: the PCs and the ack first, the rows 40 cycles
    // later, so the restored warp reads registers RCU has not written.
    if (!out_.empty() && k_.brk == "early-restore-done" && !out_.front().pcs_sent) {
      Out &o = out_.front();
      if (can(c.pca_fet, 0)) {
        Bits b = msgOf(c.pca_fet);
        for (unsigned k = 0; k != kChans[c.fet_pca].bits; ++k) b.setBit(k, o.pcs.bit(k));
        send(c.pca_fet, 0, b, o.tid);
        o.pcs_sent = true;
        done_.push_back({o.w, 1});
        hold_until_ = now_ + 40;
      }
    } else if (!out_.empty() && now_ < hold_until_) {
      // held
    } else if (!out_.empty()) {
      Out &o = out_.front();
      if (!o.rows.empty()) {
        if (can(c.pca_rcu, 0)) {
          send(c.pca_rcu, 0, o.rows.front(), none);
          o.rows.pop_front();
        }
      } else if (!o.pcs_sent) {
        if (can(c.pca_fet, 0)) {
          Bits b = msgOf(c.pca_fet);
          const unsigned n = kChans[c.fet_pca].bits;
          for (unsigned k = 0; k != n; ++k) b.setBit(k, o.pcs.bit(k));   // the same layout
          send(c.pca_fet, 0, b, o.tid);
          o.pcs_sent = true;
        }
      } else if (k_.brk == "early-restore-done") {
        out_.pop_front();                   // acked already, with the PCs
      } else if (allHome(c.pca_rcu, 0)) {
        done_.push_back({o.w, 1});
        out_.pop_front();
      }
    }
    if (!done_.empty() && can(c.pca_done, 0)) {
      Bits d = msgOf(c.pca_done);
      put(d, c.pca_done, "warp_id", done_.front().first);
      put(d, c.pca_done, "direction", done_.front().second);
      send(c.pca_done, 0, d, none);
      done_.pop_front();
    }
  }
  /// Whole once the rows (the predicate row is last), the PCs and the
  /// command have all come: filed at the place, and acked.
  void check(unsigned w) {
    Ctx &x = ctx_[w];
    if (!x.preds || !x.pcs || !x.cmd) return;
    Place &p = array_[x.place];
    p.warp = w;
    p.rows = x.rows;
    p.pcs = x.pc_msg;
    p.tid = x.pc_tid;
    ctx_.erase(w);
    done_.push_back({w, 0});
  }
  bool busy() const override { return !done_.empty() || !ctx_.empty() || !out_.empty(); }
};

// ---- CRU: takes a warp's fault --------------------------------------------------

/// A fault OOE took at retirement (ccv_ooe_cru_fault) ends its warp here
/// (TI-26). CRU's record and the kill it leads to (RAU's kill_req) are the
/// CRU session's to build; this stub checks the report against the fault
/// ccv-sim ended the warp's run with: cause, pc, lanes and address.
class Cru : public Stub {
public:
  Cru(int inst, Kernel &k) : Stub(inst, k), chan_(chanId("ccv_ooe_cru_fault")) {}
  const char *kind() const override { return "cru"; }

private:
  const unsigned chan_;
  static unsigned code(const std::string &n) {
    static const char *const names[] = {"", "F-FETCH", "F-ILLEGAL", "F-WIDTH", "F-FORMAT",
                                        "F-ALIGN", "F-ADDR", "F-SHARED", "F-RO", "F-BARRIER"};
    for (unsigned i = 1; i != sizeof names / sizeof *names; ++i)
      if (n == names[i]) return i;
    return 0;
  }
  void work() override {
    if (!has(chan_, 0)) return;
    const Bits m = take(chan_, 0).payload;
    Kernel::FaultSeen f;
    const unsigned w = unsigned(get(m, chan_, "warp_id"));
    f.cause = unsigned(get(m, chan_, "cause"));
    f.pc = get(m, chan_, "pc");
    f.lanes = uint32_t(get(m, chan_, "lane_mask"));
    f.addr = get(m, chan_, "address");
    // The CTA slot OOE stamps, RAU's for the warp (TI-34).
    const unsigned cs = unsigned(get(m, chan_, "cta_slot"));
    if (k_.cta_slot_of.count(w) && cs != k_.cta_slot_of[w])
      k_.fail("cru: warp %u's fault names CTA slot %u; RAU gave it %u", w, cs, k_.cta_slot_of[w]);
    if (k_.faults.count(w)) k_.fail("cru: warp %u faults twice", w);
    k_.faults[w] = f;
    k_.hit("fault");
    if (w >= k_.orcs.size() || !k_.orcs[w].faults) {
      k_.fail("cru: warp %u faults (cause %u at pc %llx), but ccv-sim ran it to its end", w,
              f.cause, (unsigned long long)f.pc);
      return;
    }
    const Oracle::Fault &o = k_.orcs[w].fault;
    if (f.cause != code(o.cause) || f.pc != o.pc || f.lanes != o.lanes || f.addr != o.addr)
      k_.fail("cru: warp %u fault cause %u pc %llx lanes %08x addr %llx; ccv-sim %s pc %llx "
              "lanes %08x addr %llx", w, f.cause, (unsigned long long)f.pc, f.lanes,
              (unsigned long long)f.addr, o.cause.c_str(), (unsigned long long)o.pc, o.lanes,
              (unsigned long long)o.addr);
  }
};

// ---- SYU: the barrier table --------------------------------------------------------

/// The barrier table (TI-40; SYU spec rev 7, AR's rev 162). Per warp context:
/// its CTA slot, its live lanes (set from RAU's allocate, cleared by OOE's exit
/// reports), whether it is resident, and per barrier id the lanes arrived in
/// the phase in progress and whether its last arrival's phase has completed,
/// ccv-sim's arrival epoch kept per context. A barrier completes when every
/// context of the CTA has every live lane arrived (or none live): the arrivals
/// clear, each context that arrived has its phase completed, and the waits
/// pending at that id are answered. A wait whose last arrival has completed is
/// answered at once. The answer goes where the wait waits: a held wait (a
/// converged warp, OOE holding rename) on ccv_syu_ooe_rel, a parked one on
/// ccv_syu_fet_rel with its lanes, and a context not resident to RAU as its
/// readiness on ccv_syu_rau_ready, which also answers a demote at once when
/// the context waits for nothing.
///   bar-own-warp   a barrier completes on its own warp's lanes alone
///   bar-no-exit    the exit reports are ignored, so an exited lane is waited for
///   bar-full-last  the CTA's last warp taken as 32 lanes, not RAU's count
class Syu : public Stub {
public:
  using Stub::Stub;
  const char *kind() const override { return "syu"; }

private:
  static constexpr unsigned kIds = 1u << ccv::kWBarId;
  struct Ctx {
    bool valid = false, resident = true;
    unsigned cta = 0;
    uint32_t live = 0;
    std::array<uint32_t, kIds> arrived{};
    std::array<bool, kIds> done{};
    /// A wait not yet answered: its id, lanes, and whether OOE holds for it.
    bool waiting = false, held = false;
    unsigned wait_id = 0;
    uint32_t wait_lanes = 0;
  };
  std::array<Ctx, 32> ctx_{};
  struct Out { unsigned chan; Bits msg; };
  std::deque<Out> out_;

  void answerTo(unsigned w, uint32_t lanes, bool held) {
    const Ch &c = ch();
    if (!ctx_[w].resident) {
      Bits r = msgOf(c.syu_rau);
      put(r, c.syu_rau, "warp_id", w);
      out_.push_back({c.syu_rau, r});
      k_.hit("bar_ready");
    } else if (held) {
      Bits r = msgOf(c.syu_ooe);
      put(r, c.syu_ooe, "warp_id", w);
      out_.push_back({c.syu_ooe, r});
      k_.hit("bar_release");
    } else {
      Bits r = msgOf(c.syu_fet);
      put(r, c.syu_fet, "warp_id", w);
      put(r, c.syu_fet, "lane_mask", lanes);
      out_.push_back({c.syu_fet, r});
      k_.hit("bar_release");
    }
  }
  /// Every context of w's CTA arrived at id, or with no lane live.
  bool complete(unsigned w, unsigned id) const {
    bool any = false;
    for (unsigned v = 0; v != 32; ++v) {
      const Ctx &x = ctx_[v];
      if (!x.valid || x.cta != ctx_[w].cta) continue;
      if (k_.brk == "bar-own-warp" && v != w) continue;
      any = any || x.arrived[id];
      if ((x.arrived[id] | ~x.live) != ~0u) return false;
    }
    return any;
  }
  void tryComplete(unsigned w, unsigned id) {
    if (!complete(w, id)) return;
    k_.hit("bar_complete");
    for (unsigned v = 0; v != 32; ++v) {
      Ctx &x = ctx_[v];
      if (!x.valid || x.cta != ctx_[w].cta || !x.arrived[id]) continue;
      if (k_.brk == "bar-own-warp" && v != w) continue;
      x.arrived[id] = 0;
      x.done[id] = true;
      if (x.waiting && x.wait_id == id) {
        x.waiting = false;
        answerTo(v, x.wait_lanes, x.held);
      }
    }
  }

  void work() override {
    const Ch &c = ch();
    if (has(c.rau_syu, 0)) {
      const Bits m = take(c.rau_syu, 0).payload;
      const unsigned op = unsigned(get(m, c.rau_syu, "syu_alloc_op"));
      const unsigned w = unsigned(get(m, c.rau_syu, "warp_id")) & 31;
      if (op == kSyuAlloc) {
        // A CTA admitted whole: its contexts, each with 32 live lanes but
        // the last warp, which has last_lanes + 1.
        const uint32_t mask = uint32_t(get(m, c.rau_syu, "warp_mask"));
        const unsigned last = unsigned(get(m, c.rau_syu, "last_lanes")) + 1;
        for (unsigned v = 0; v != 32; ++v) {
          if (!(mask >> v & 1u)) continue;
          ctx_[v] = Ctx();
          ctx_[v].valid = true;
          ctx_[v].cta = unsigned(get(m, c.rau_syu, "cta_slot"));
          ctx_[v].live = v == w && last < 32 && k_.brk != "bar-full-last" ? (1u << last) - 1 : ~0u;
        }
      } else if (op == kSyuFree) {
        const unsigned cta = unsigned(get(m, c.rau_syu, "cta_slot"));
        for (Ctx &x : ctx_)
          if (x.valid && x.cta == cta) x = Ctx();
      } else if (op == kSyuDemote) {
        // Not resident: a wait it has pending is answered to RAU when its
        // barrier completes; with none, RAU has it ready at once.
        Ctx &x = ctx_[w];
        x.resident = false;
        x.held = false;   // the rewind took OOE's hold back to the wait
        if (!x.waiting) answerTo(w, 0, false);
      } else {
        ctx_[w].resident = true;
        ctx_[w].waiting = false;   // the restored warp asks again
      }
    }
    if (has(c.ooe_syu, 0)) {
      const Receiver::Msg rm = take(c.ooe_syu, 0);
      const Bits &m = rm.payload;
      const unsigned w = unsigned(get(m, c.ooe_syu, "warp_id")) & 31;
      const unsigned kindv = unsigned(get(m, c.ooe_syu, "bar_kind"));
      const unsigned id = unsigned(get(m, c.ooe_syu, "barrier_id")) % kIds;
      const uint32_t issue = uint32_t(get(m, c.ooe_syu, "issue_mask"));
      const uint32_t guard = uint32_t(get(m, c.ooe_syu, "guard_mask"));
      Ctx &x = ctx_[w];
      if (!x.valid) {
        k_.fail("syu: warp %u reports a barrier, and RAU allocated it no CTA", w);
      } else if (unsigned(get(m, c.ooe_syu, "cta_slot")) != x.cta) {
        k_.fail("syu: warp %u's report names CTA slot %u; RAU gave it %u", w,
                unsigned(get(m, c.ooe_syu, "cta_slot")), x.cta);
      } else if (kindv == kBarArriveK) {
        x.arrived[id] |= issue & guard;
        x.done[id] = false;
        k_.hit("bar_arrive");
        tryComplete(w, id);
      } else if (kindv == kBarWaitK) {
        const bool held = get(m, c.ooe_syu, "held") != 0;
        if (x.done[id]) {
          answerTo(w, issue, held);   // its arrival's phase has completed
        } else {
          x.waiting = true;
          x.held = held;
          x.wait_id = id;
          x.wait_lanes = issue;
        }
      } else if (kindv == kBarExitK) {
        // Its lanes are waited for no more: any barrier of the CTA may now
        // be complete.
        if (k_.brk != "bar-no-exit") x.live &= ~issue;
        for (unsigned i = 0; i != kIds; ++i) tryComplete(w, i);
      } else {
        k_.fail("syu: warp %u's bar.wait.phase, which no kernel here uses yet (IS-22)", w);
      }
    }
    while (!out_.empty() && can(out_.front().chan, 0)) {
      send(out_.front().chan, 0, out_.front().msg, makeUid(IdClass::kNone, 0));
      out_.pop_front();
    }
  }
  bool busy() const override { return !out_.empty(); }
};

/// SPM: nothing on any kernel's path yet.
class Idle : public Stub {
public:
  Idle(int inst, Kernel &k, const char *n) : Stub(inst, k), n_(n) {}
  const char *kind() const override { return n_; }
private:
  void work() override {}
  const char *n_;
};

} // namespace

std::unique_ptr<Block> makeKernelBlock(int inst, Kernel &k) {
  if (inst < 0) return std::make_unique<Testbench>(inst, k);
  switch (kBlkInsts[inst].type) {
  case Blk::FET:  return std::make_unique<Fet>(inst, k);
  case Blk::DEC:  return std::make_unique<Dec>(inst, k);
  case Blk::OOE:  return makeOoe(inst, k);          // ooe.cpp
  case Blk::RCU:  return std::make_unique<Rcu>(inst, k);
  case Blk::LANE: return std::make_unique<Lane>(inst, k);
  case Blk::MIU:  return std::make_unique<Miu>(inst, k);
  case Blk::DCU:  return std::make_unique<Dcu>(inst, k);
  case Blk::MLC:  return std::make_unique<Mlc>(inst, k);
  case Blk::EXB:  return std::make_unique<Exb>(inst, k);
  case Blk::RAU:  return std::make_unique<Rau>(inst, k);
  case Blk::PCA:  return std::make_unique<Pca>(inst, k);
  case Blk::CRU:  return std::make_unique<Cru>(inst, k);
  case Blk::SYU:  return std::make_unique<Syu>(inst, k);
  default:
    return std::make_unique<Idle>(inst, k, blkName(kBlkInsts[inst].type));
  }
}

KernelReport compareFinal(Kernel &k) {
  k.flushHeld();
  KernelReport r;
  // How many of each warp's instructions retired, in order.
  std::vector<uint32_t> nret(k.orcs.size(), 0);
  for (uint64_t s : k.retire_order)
    if (seqWarp(uint32_t(s)) < nret.size()) ++nret[seqWarp(uint32_t(s))];
  auto isParked = [&](unsigned w) { return k.parkedNow(w); };
  // Each warp's registers against its own run of ccv-sim.
  // A warp the kill ended mid-run (V-24) has no final state to compare: it
  // is held only to its retire order, a prefix of ccv-sim's, below. A
  // faulted warp is compared as its fault left it.
  auto cut = [&](unsigned w) { return k.killed.count(w) && !k.orcs[w].faults; };
  // The kill (V-24): every owner acked it at its epoch, and every warp that
  // faulted was killed.
  if (k.kill_unacked) {
    std::string who;
    for (const FabDesc &f : kFabs)
      if (!std::strcmp(f.name, "kill_ack"))
        for (unsigned i = 0; i != f.nblks; ++i)
          if (k.kill_unacked >> i & 1u) who += std::string(who.empty() ? "" : " ") + blkName(f.blks[i]);
    k.fail("rau: the kill never completed: no ack at its epoch from %s", who.c_str());
  }
  for (const auto &f : k.faults)
    if (!k.killed.count(f.first)) k.fail("rau: warp %u faulted and was never killed", f.first);
  for (unsigned w = 0; w != k.orcs.size(); ++w) {
    if (isParked(w) || cut(w)) continue;
    const Oracle &o = k.orcs[w];
    // A run ccv-sim ended in a fault must end in CRU's fault too (TI-26);
    // CRU's stub held its fields to ccv-sim's as it took it.
    if (o.faults && !k.faults.count(w))
      k.fail("cru: warp %u never faulted; ccv-sim ended it with %s at pc %llx", w,
             o.fault.cause.c_str(), (unsigned long long)o.fault.pc);
    const std::vector<unsigned> &rat = k.ratOf(w);
    const char *who = k.orcs.size() == 1 ? "" : "warp ";
    const std::string wn = k.orcs.size() == 1 ? "" : std::to_string(w) + " ";
    // As it exited, if RAU saw it exit; else the registers as they are now.
    auto fin = k.finals.find(w);
    for (unsigned a = 0; a != kArchGprs; ++a)
      for (unsigned l = 0; l != kLanes; ++l) {
        // Within the register's final width: ccv-sim keeps the bits above
        // a narrow element as the slice last held them (AR-24).
        const uint32_t em = elemMask(o.final_widths >> 2 * a & 3u);
        const uint32_t got = fin != k.finals.end() ? fin->second.gpr[a][l] : k.gpr[rat[a]][l];
        if ((got & em) != (o.final_gpr[a][l] & em)) {
          if (r.gpr_mismatch++ < 4)
            std::fprintf(stderr, "FINAL %s%sR%u lane %u: machine %08x, ccv-sim %08x\n", who,
                         wn.c_str(), a, l, got & em, o.final_gpr[a][l] & em);
        }
      }
    std::vector<unsigned> pmap = w < k.prat.size() ? k.prat[w] : std::vector<unsigned>();
    if (pmap.empty())
      for (unsigned p = 0; p != kArchPreds; ++p) pmap.push_back(physPred(w, p));
    if (k.brk == "swap-prat0" && w == 0) std::swap(pmap[0], pmap[1]);
    for (unsigned p = 0; p != kArchPreds; ++p) {
      const uint32_t got = fin != k.finals.end() ? fin->second.pred[p] : k.pred[pmap[p]];
      if (got != o.final_pred[p]) {
        ++r.pred_mismatch;
        std::fprintf(stderr, "FINAL %s%sP%u: machine %08x, ccv-sim %08x\n", who, wn.c_str(), p,
                     got, o.final_pred[p]);
      }
    }
  }
  // Memory: what each warp's run left changed from the memory they all began
  // with, together. Each CTA must write words of its own: two runs leaving
  // one word differently is a kernel that races, refused as a mismatch.
  std::map<uint64_t, uint32_t> init, want;
  for (auto &w : k.orcs[0].init_mem) init[w.first] = w.second;
  // A parked warp never ran past its boundary, so its run's final memory is
  // not what the machine holds: it is left out (no parked kernel stores).
  for (unsigned ow = 0; ow != k.orcs.size(); ++ow)
    for (auto &w : isParked(ow) ? std::vector<std::pair<uint64_t, uint32_t>>() : k.orcs[ow].final_mem) {
      auto i = init.find(w.first);
      const bool changed = i == init.end() ? w.second != 0 : i->second != w.second;
      if (!changed && !want.count(w.first)) { want[w.first] = w.second; continue; }
      if (!changed) continue;
      auto o2 = want.find(w.first);
      const bool other = o2 != want.end() &&
                         o2->second != (i == init.end() ? 0u : i->second) && o2->second != w.second;
      if (other && r.mem_mismatch++ < 4)
        std::fprintf(stderr, "FINAL [%llx]: two warps' runs leave it %08x and %08x\n",
                     (unsigned long long)w.first, o2->second, w.second);
      want[w.first] = w.second;
    }
  for (auto &w : want) {
    uint32_t v = 0;
    for (unsigned b = 0; b != 4; ++b) {
      // Through DCU's dirty lines first: write-back keeps them there.
      const uint64_t a = w.first + b, line = a / 128 * 128;
      auto d = k.dcu_dirty.find(line);
      auto it = k.mem.find(a);
      v |= uint32_t(d != k.dcu_dirty.end() ? d->second[a - line]
                    : it == k.mem.end() ? 0 : it->second) << (8 * b);
    }
    if (v != w.second && r.mem_mismatch++ < 4)
      std::fprintf(stderr, "FINAL [%llx]: machine %08x, ccv-sim %08x\n",
                   (unsigned long long)w.first, v, w.second);
  }
  // Each warp retires its own instructions in its own order.
  unsigned groups = 0;
  // A faulting instruction counts in ccv-sim's issue groups and never retires.
  for (unsigned w = 0; w != k.orcs.size(); ++w)
    groups += isParked(w) || cut(w) ? nret[w] : k.orcs[w].issue_groups - (k.orcs[w].faults ? 1 : 0);
  r.order_ok = k.retired == groups;
  std::vector<uint32_t> next(k.orcs.size(), 0);
  for (uint64_t s : k.retire_order) {
    const unsigned w = seqWarp(uint32_t(s));
    r.order_ok = r.order_ok && w < next.size() && seqIndex(uint32_t(s)) == next[w]++;
  }
  for (unsigned c = 0; c != kNumChans; ++c) {
    if (k.rx_per_chan[c]) ++r.channels_used;
    else r.unused += std::string(r.unused.empty() ? "" : " ") + kChans[c].name;
  }
  return r;
}

std::vector<unsigned> &Kernel::ratOf(unsigned w) {
  if (rat.size() <= w) rat.resize(w + 1);
  if (rat[w].empty()) rat[w].assign(kArchGprs, ccv::prov::kPhysZero);
  return rat[w];
}

std::vector<unsigned> &Kernel::pratOf(unsigned w, bool preds) {
  if (prat.size() <= w) prat.resize(w + 1);
  if (preds && prat[w].empty()) prat[w].assign(kArchPreds, ccv::prov::kPredZero);
  return prat[w];
}

std::string Kernel::loadOracles(const std::string &path) {
  orcs.assign(1, Oracle());
  if (std::string e = orcs[0].load(path); !e.empty()) return e;
  // The launch entry, from the file gen-oracle writes beside the records:
  // every warp of the kernel starts there.
  {
    const size_t sl = path.rfind('/');
    std::ifstream ef((sl == std::string::npos ? std::string(".") : path.substr(0, sl)) + "/entry");
    std::string t;
    if (ef >> t) orcs[0].entry = std::strtoull(t.c_str(), nullptr, 0);
  }
  // The OOE model's settings a kernel runs under (kernel.cfg's OOE_CONFIG,
  // which gen-oracle writes beside the records: narrowadd's full_rows, AR-24's
  // interim). An explicit CCV_OOE_CONFIG follows it and so wins. Read here,
  // before either host builds its blocks.
  {
    const size_t sl = path.rfind('/');
    std::ifstream cf((sl == std::string::npos ? std::string(".") : path.substr(0, sl)) + "/ooe_config");
    std::string t;
    if (cf >> t) {
      const char *cur = std::getenv("CCV_OOE_CONFIG");
      const std::string v = cur && *cur ? t + "," + cur : t;
      setenv("CCV_OOE_CONFIG", v.c_str(), 1);
    }
  }
  // Each run stands for one warp, which RAU gives warp_id w, its hardware
  // context: srd #2's %lanectx names it (O-64), so the run must have named
  // the same context (gen-oracle passes ccv-sim -context w; TI-35).
  auto ctx = [](const Oracle &o, unsigned w, const std::string &p) -> std::string {
    return o.lane_context != w
               ? p + ": ccv-sim ran it as context " + std::to_string(o.lane_context) +
                     ", but RAU gives it warp_id " + std::to_string(w)
               : "";
  };
  if (std::string e = ctx(orcs[0], 0, path); !e.empty()) return e;
  const std::string base =
      path.size() > 6 && path.compare(path.size() - 6, 6, ".jsonl") == 0
          ? path.substr(0, path.size() - 6) : path;
  for (unsigned w = 1;; ++w) {
    const std::string p = base + "." + std::to_string(w) + ".jsonl";
    if (FILE *f = std::fopen(p.c_str(), "r")) std::fclose(f);
    else break;
    Oracle o;
    if (std::string e = o.load(p); !e.empty()) return e;
    if (o.code != orcs[0].code || o.code_base != orcs[0].code_base || o.init_mem != orcs[0].init_mem)
      return p + ": not the code and memory warp 0 ran";
    if (std::string e = ctx(o, w, p); !e.empty()) return e;
    orcs.push_back(std::move(o));
  }
  // The runs' CTAs: the warps of one ccv-sim -cta run share its ctaid and
  // are one CTA (CP-30); each CTAS run is a CTA of its own. RAU gives each
  // CTA one CTA slot, so there may be no more than CCV_P_MAX_CTA of them.
  std::map<unsigned, unsigned> slot;
  cta_of.clear();
  for (const Oracle &o : orcs) cta_of.push_back(slot.emplace(o.ctaid, unsigned(slot.size())).first->second);
  ctas = unsigned(slot.size());
  if (ctas > ccv::prov::kMaxCta)
    return path + ": more CTAs than CCV_P_MAX_CTA, and RAU gives each a CTA slot";
  return "";
}

std::string kernelName(const std::string &path) {
  const size_t sl = path.find_last_of('/');
  const std::string dir = sl == std::string::npos ? "." : path.substr(0, sl);
  const size_t s2 = dir.find_last_of('/');
  return s2 == std::string::npos ? dir : dir.substr(s2 + 1);
}

bool KernelEnd::after(uint64_t c, Kernel &k, Machine &m) {
  bool in_flight = false;
  for (unsigned s = 0; s != kNumSlots && !in_flight; ++s)
    in_flight = m.tx(s).sent() != m.rx(s).received();
  if (c >= kReset && k.exited() && k.busy == 0 && !in_flight) {
    if (!finished) finish = c;
    finished = true;
    ++quiet;
  } else {
    quiet = 0;
    finished = false;
  }
  k.busy = 0;
  return quiet == kTail;
}

void printKernelReport(Kernel &k, Machine &m, const KernelEnd &e,
                       int violations) {
  const KernelReport r = compareFinal(k);
  uint64_t overflows = 0, leaks = 0;
  for (unsigned s = 0; s != kNumSlots; ++s) {
    overflows += m.rx(s).overflows();
    leaks += m.rx(s).leaks();
  }
  const uint64_t from_fetch =
      k.fetched && e.finish >= k.first_fetch ? e.finish - k.first_fetch : 0;
  std::printf("KERNEL name=%s finished=%d cycles=%llu from_fetch=%llu retired=%llu "
              "issue_groups=%u order=%s gpr_mismatch=%u pred_mismatch=%u "
              "mem_mismatch=%u check_failures=%llu class_violations=%llu "
              "overflows=%llu credit_leaks=%llu channels_used=%u/%u violations=%d\n",
              k.name.c_str(), int(e.finished), (unsigned long long)e.finish,
              (unsigned long long)from_fetch, (unsigned long long)k.retired,
              [&] { unsigned n = 0; for (const Oracle &o : k.orcs) n += o.issue_groups; return n; }(),
              r.order_ok ? "ok" : "bad", r.gpr_mismatch, r.pred_mismatch,
              r.mem_mismatch, (unsigned long long)k.failures,
              (unsigned long long)k.class_violations,
              (unsigned long long)overflows, (unsigned long long)leaks,
              r.channels_used, kNumChans,
              violations);
  std::printf("UNUSED %s\n", r.unused.c_str());
  // Each backpressured channel's longest wait from landing to take, over its
  // slots: the measure CCV_P_TIMEOUT_BP is a watchdog over (AR's response
  // TI-22). Not part of the KERNEL line the two hosts compare.
  for (const ChanInst &ci : kChanInsts) {
    if (!kChans[ci.chan].held) continue;
    uint64_t age = 0;
    for (unsigned s = 0; s != kChans[ci.chan].rate; ++s)
      age = std::max(age, m.rx(ci.slot_base + s).maxAge());
    std::printf("BPAGE %s max=%llu watchdog=%u\n", kChans[ci.chan].name,
                (unsigned long long)age, unsigned(ccv::prov::kTimeoutBp));
  }
  std::printf("COVER");
  for (const char *b : Kernel::kCoverBins)
    std::printf(" %s=%llu", b, (unsigned long long)(k.cover.count(b) ? k.cover.at(b) : 0));
  std::printf("\n");
  // AR-24's per-run measures, not coverage bins (no kernel need reach them):
  // redirects and the warp-cycles fetch waited on them, warp-cycles fetch
  // stalled with every checkpoint live, rets and calls fetched, DCU lookups
  // and those for frames (AR-23), warp-cycles a load waited behind an older
  // store of its warp (PF-42), and perfect fetch's taken and split branches.
  std::printf("PERF");
  for (const char *b : {"redirect", "redirect_wait", "ckpt_full", "branches", "br_resolved",
                        "br_resolve_cycles", "l1_miss", "mlc_warm_hit", "ret", "call", "dcu_lookups",
                        "frame_lookups", "st_ld_wait", "fet_perfect_taken", "fet_perfect_split"})
    std::printf(" %s=%llu", b, (unsigned long long)(k.cover.count(b) ? k.cover.at(b) : 0));
  std::printf("\n");
}

} // namespace skel
} // namespace ccv
