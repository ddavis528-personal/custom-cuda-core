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
#include "kernel.h"

#include "ccv/event.h"
#include "exerciser.h"

#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <deque>
#include <set>
#include <tuple>

namespace ccv {
namespace skel {

void Kernel::fail(const char *fmt, ...) {
  if (failures < 12) {
    va_list ap;
    va_start(ap, fmt);
    std::fprintf(stderr, "CHECK ");
    std::vfprintf(stderr, fmt, ap);
    std::fputc('\n', stderr);
    va_end(ap);
  }
  ++failures;
}

namespace {

// ---- channels and fields, by name --------------------------------------------

unsigned chanId(const char *n) {
  for (const ChanDesc &cd : kChans)
    if (!std::strcmp(cd.name, n)) return cd.id;
  std::fprintf(stderr, "kernel stubs: no channel %s in the wiring\n", n);
  std::abort();
}

struct Ch {
  unsigned fet_dec = chanId("ccv_fet_dec_instr"), dec_ooe = chanId("ccv_dec_ooe_uop"),
           ooe_rcu = chanId("ccv_ooe_rcu_issue"), rcu_lane = chanId("ccv_rcu_lane_ops"),
           lane_rcu = chanId("ccv_lane_rcu_res"), rcu_ooe = chanId("ccv_rcu_ooe_done"),
           rcu_miu = chanId("ccv_rcu_miu_addr"), miu_rcu = chanId("ccv_miu_rcu_data"),
           ooe_miu = chanId("ccv_ooe_miu_memop"), miu_ooe = chanId("ccv_miu_ooe_cmpl"),
           ooe_ret = chanId("ccv_ooe_miu_retire"), ooe_fet = chanId("ccv_ooe_fet_redirect"), miu_dcu = chanId("ccv_miu_dcu_req"),
           dcu_miu = chanId("ccv_dcu_miu_rsp"), dcu_mlc = chanId("ccv_dcu_mlc_req"),
           mlc_dcu = chanId("ccv_mlc_dcu_rsp"), fet_mlc = chanId("ccv_fet_mlc_ifill"),
           mlc_fet = chanId("ccv_mlc_fet_ifill_rsp"), miu_fet = chanId("ccv_miu_fet_itlb"),
           fet_miu = chanId("ccv_fet_miu_itlb_req"), mlc_exb = chanId("ccv_mlc_exb_req"),
           exb_mlc = chanId("ccv_exb_mlc_rsp"), exb_ext = chanId("ccv_exb_ext_out"),
           ext_exb = chanId("ccv_ext_exb_in"), rau_fet = chanId("ccv_rau_fet_launch"),
           rau_ooe = chanId("ccv_rau_ooe_alloc"), rau_miu = chanId("ccv_rau_miu_cta");
};
const Ch &ch() { static const Ch c; return c; }

const FieldDesc &field(unsigned chan, const char *n) {
  const ChanDesc &cd = kChans[chan];
  for (unsigned f = 0; f != cd.nfields; ++f)
    if (!std::strcmp(cd.fields[f].name, n)) return cd.fields[f];
  std::fprintf(stderr, "kernel stubs: %s has no field %s\n", cd.name, n);
  std::abort();
}
uint64_t get(const Bits &b, unsigned chan, const char *f) {
  const FieldDesc &fd = field(chan, f);
  return b.get(fd.lsb, fd.width < 64 ? fd.width : 64);
}
void put(Bits &b, unsigned chan, const char *f, uint64_t v) {
  const FieldDesc &fd = field(chan, f);
  b.set(fd.lsb, fd.width < 64 ? fd.width : 64, v);
}
/// Per-lane 32-bit element L of a wide field: bits [32L+31 : 32L] of it.
uint32_t getLane(const Bits &b, unsigned chan, const char *f, unsigned l) {
  return uint32_t(b.get(field(chan, f).lsb + 32 * l, 32));
}
void putLane(Bits &b, unsigned chan, const char *f, unsigned l, uint32_t v) {
  b.set(field(chan, f).lsb + 32 * l, 32, v);
}
Bits msgOf(unsigned chan) { return Bits(kChans[chan].bits); }

constexpr unsigned kLine = 128;            // bytes: CCV_W_DATA / 8
using Line = std::array<uint8_t, kLine>;

void putLine(Bits &b, uint32_t lsb, const Line &l) {
  for (unsigned k = 0; k != kLine; ++k) b.set(lsb + 8 * k, 8, l[k]);
}
Line getLine(const Bits &b, uint32_t lsb) {
  Line l;
  for (unsigned k = 0; k != kLine; ++k) l[k] = uint8_t(b.get(lsb + 8 * k, 8));
  return l;
}

// ---- S1 wire conventions (docs/skeleton.md lists them) ------------------------
//
// Placeholders for encodings the payload spec leaves to the owning block.
enum : unsigned { kCohRead = 0, kCohWrite = 1 };        // coh_op
enum : unsigned { kMemLoad = 0, kMemStore = 1 };        // ooe_miu_memop.mem_op
enum : unsigned { kSpaceGlobal = 0, kSpaceShared = 1 }; // ooe_miu_memop.space
enum : unsigned { kSizeLine = 7 };                      // size: 2^7 bytes
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

// ---- the opcode table ---------------------------------------------------------
//
// The skeleton's decoder: an opcode per operation vadd uses, and the operand
// shape rename and register read need. Opcode values are skeleton-local
// (payload spec: opcode is 9 bits, preliminary) -- 0 is reserved.
enum UopClass : uint8_t { kAlu, kLoad, kStore, kBranch, kExit, kPredLogic, kImm };
struct OpInfo {
  const char *name;
  UopClass cls;
  uint8_t nsrc;         ///< GPR sources, in src_arch order
  bool gdst, pread, pwrite;
  bool guard;           ///< the predicate read is a guard (@pq): an enable
  bool pdata;           ///< the predicate read is DATA to the lane (sel)
  int8_t base_src;      ///< memory: the window base's source
  int8_t index_src;     ///< memory: the per-lane index's source, or -1
  int8_t data_src;      ///< store: the data's source
  // Immediates, as indices into the record's `imms` (operand order), -1 if
  // none. disp/scale go to MIU's AGU on the memop; alu goes to RCU on the
  // issue, which substitutes it into operand slot `imm_slot`.
  int8_t disp_imm, scale_imm, alu_imm, imm_slot;
  // srd: the selector this opcode decodes from, and whether the lane ORs its
  // own index into the operand. The selector is decoded once, by DEC, into
  // one of two opcodes: OOE picks the identity by opcode, and the lane picks
  // OR or pass-through by opcode, so no field carries it past decode.
  int8_t srd_sel = -1;
  bool or_lane = false;
};
// Where each executes (Q-32, Q-38): the lane executes any opcode with a
// per-lane input -- a GPR, or its own hardwired index (srd #0). RCU executes
// the opcodes whose inputs are all warp-level -- the predicate file, an
// immediate: predicate logic, pmov, movi, movi48, branch resolution -- plus
// the ops that move data horizontally between lanes. setp, add.pp, cas and
// sel run in the lane although they touch predicates. srd stays in the lane
// whole: selector 1 is warp-uniform, but splitting one opcode across two
// blocks to save an operand trip on a prologue instruction is a bad trade.
// Memory ops go to MIU.
bool inRcu(UopClass c) { return c == kPredLogic || c == kBranch || c == kImm; }
/// A per-lane input: a GPR source, or the lane's own index.
bool perLaneInput(const OpInfo *op, const Record &r) {
  return !r.gprUses().empty() || op->srd_sel >= 0;
}
constexpr OpInfo kOps[] = {
  //                            nsrc gdst  pread  pwrite guard  pdata  base idx data disp scl alu slot
  {"POR",           kPredLogic, 0, false, true,  true,  false, false, -1, -1, -1, -1, -1, -1, -1},
  {"MOVI48",        kImm,       0, true,  false, false, false, false, -1, -1, -1, -1, -1,  0,  0},
  // srd #0 (%ctatid): the immediate is warp_base, and the lane ORs its index.
  {"SRD",           kAlu,       0, true,  false, false, false, false, -1, -1, -1, -1, -1,  0,  0, 0, true},
  {"LD_GLOBAL",     kLoad,      1, true,  false, false, false, false,  0, -1, -1,  0, -1, -1, -1},
  {"MADLO",         kAlu,       3, true,  false, false, false, false, -1, -1, -1, -1, -1, -1, -1},
  {"SETP_LT",       kAlu,       2, false, true,  true,  true,  false, -1, -1, -1, -1, -1, -1, -1},
  {"BRA_PRED",      kBranch,    0, false, true,  false, true,  false, -1, -1, -1, -1, -1, -1, -1},
  {"LD_GLOBAL_IDX", kLoad,      2, true,  false, false, false, false,  0,  1, -1,  1,  0, -1, -1},
  {"C_ADD",         kAlu,       2, true,  false, false, false, false, -1, -1, -1, -1, -1, -1, -1},
  {"ST_GLOBAL_IDX", kStore,     3, false, false, false, false, false,  1,  2,  0,  1,  0, -1, -1},
  {"C_EXIT",        kExit,      0, false, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},
  {"MOVI",          kImm,       0, true,  false, false, false, false, -1, -1, -1, -1, -1,  0,  0},
  // sel's qualifier is DATA: every issue-mask lane writes rd, choosing rs0 or
  // rs1 by it. So no enable narrowing, and the predicate rides as pred_data.
  // (Format A always encodes rs2; the sel kernel names R2 for it, which the
  // oracle folds into the rs1 use.)
  {"SEL",           kAlu,       2, true,  true,  false, false, true,  -1, -1, -1, -1, -1, -1, -1},
  // srd #1 (%ctaid): the immediate is the value; the lane passes it through.
  {"SRD",           kAlu,       0, true,  false, false, false, false, -1, -1, -1, -1, -1,  0,  0, 1, false},
};
constexpr unsigned kNumOps = sizeof kOps / sizeof kOps[0];
unsigned opcodeOf(const OpInfo *o) { return unsigned(o - kOps) + 1; }
const OpInfo *opByName(const std::string &n) {
  for (const OpInfo &o : kOps) if (n == o.name) return &o;
  return nullptr;
}
/// srd's opcode for a selector, or null: 2-15 are unallocated.
const OpInfo *srdBySel(int64_t sel) {
  for (const OpInfo &o : kOps) if (o.srd_sel >= 0 && o.srd_sel == sel) return &o;
  return nullptr;
}
const OpInfo *opByCode(unsigned c) {
  return c >= 1 && c <= kNumOps ? &kOps[c - 1] : nullptr;
}

/// req_id allocation on one hop: the lowest free id below 2^width, where the
/// width is the hop's own (CCV_P_W_REQ_*). Running out is a stall, not a
/// wrap -- a reused id would let a response match the wrong request.
class IdPool {
public:
  explicit IdPool(unsigned chan) : n_(1u << field(chan, "req_id").width) {}
  bool any() const { return used_.size() < n_; }
  unsigned take() {
    unsigned i = 0;
    while (used_.count(i)) ++i;
    used_.insert(i);
    return i;
  }
  bool release(unsigned i) { return used_.erase(i) != 0; }
  bool empty() const { return used_.empty(); }
private:
  unsigned n_;
  std::set<unsigned> used_;
};

uint64_t instrUid(uint64_t seq) { return makeUid(IdClass::kInstr, uint32_t(seq)); }
uint32_t g_unowned_txn = 0;   ///< sequence for transactions no instruction owns

void emit(uint64_t now, uint64_t uid, EventId id, Unit u, uint32_t a = 0,
          uint32_t b = 0, uint32_t c = 0) {
  traceWriter().emit(now, uid, id, uint16_t(u), a, b, c);
}

// ---- the stub base --------------------------------------------------------------

class Stub : public Block {
public:
  Stub(int inst, Kernel &k) : Block(inst), k_(k) {}

  void cycle(uint64_t now) final {
    if (!built_) build();
    now_ = now;
    for (const In &i : ins) i.rx->cycle(now);
    work();
    // Every sender is clocked exactly once a cycle, launching or not.
    for (size_t j = 0; j != outs.size(); ++j) {
      Pend &p = pend_[j];
      outs[j].tx->cycle(p.go, p.msg, p.tid);
      if (p.go) logLaunch(uint16_t(outs[j].ci->chan), p.msg, p.tid);
      p.go = false;
    }
    if (busy()) ++k_.busy;
    // A message left in a receiver is one this stub does not handle. The
    // bank's response_within_n will report it; say which, once.
    for (const In &i : ins)
      if (!i.rx->empty() && unhandled_.insert(i.ci->chan).second)
        k_.fail("%s: nothing consumes %s", kind(), kChans[i.ci->chan].name);
  }

protected:
  virtual void work() = 0;
  virtual bool busy() const { return false; }
  virtual const char *kind() const = 0;

  bool can(unsigned chan, unsigned slot, unsigned inst = 0) {
    const int j = outIdx(chan, slot, inst);
    return !pend_[j].go && outs[j].tx->canSend();
  }
  void send(unsigned chan, unsigned slot, const Bits &msg, uint64_t tid,
            unsigned inst = 0) {
    const int j = outIdx(chan, slot, inst);
    if (pend_[j].go || !outs[j].tx->canSend()) {
      std::fprintf(stderr, "%s: send on %s slot %u without a credit\n", kind(),
                   kChans[chan].name, slot);
      std::abort();
    }
    pend_[j] = {true, msg, tid};
  }
  bool has(unsigned chan, unsigned slot, unsigned inst = 0) {
    return !rx(chan, slot, inst).empty();
  }
  /// Consume the oldest message on a slot, checking its id class.
  Receiver::Msg take(unsigned chan, unsigned slot, unsigned inst = 0) {
    Receiver &r = rx(chan, slot, inst);
    Receiver::Msg m = r.front();
    r.pop();
    ++k_.rx_per_chan[chan];
    const ChanDesc &cd = kChans[chan];
    if (!((cd.id_classes >> unsigned(uidClass(m.tid))) & 1u)) {
      ++k_.class_violations;
      k_.fail("%s carries id class %u, not in its set", cd.name,
              unsigned(uidClass(m.tid)));
    }
    return m;
  }
  const Record *rec(uint64_t tid, const char *where) {
    const Record *r = uidClass(tid) == IdClass::kNone
                          ? nullptr : k_.orc.bySeq(uidSeq(tid));
    if (!r) k_.fail("%s: no oracle record for identity %016llx", where,
                    (unsigned long long)tid);
    return r;
  }

  Kernel &k_;
  uint64_t now_ = 0;

private:
  Receiver &rx(unsigned chan, unsigned slot, unsigned inst) {
    auto it = in_.find({chan, inst, slot});
    if (it == in_.end()) {
      std::fprintf(stderr, "%s: no input %s[%u] slot %u\n", kind(),
                   kChans[chan].name, inst, slot);
      std::abort();
    }
    return *ins[it->second].rx;
  }
  int outIdx(unsigned chan, unsigned slot, unsigned inst) {
    auto it = out_.find({chan, inst, slot});
    if (it == out_.end()) {
      std::fprintf(stderr, "%s: no output %s[%u] slot %u\n", kind(),
                   kChans[chan].name, inst, slot);
      std::abort();
    }
    return it->second;
  }
  void build() {
    for (size_t j = 0; j != outs.size(); ++j)
      out_[{outs[j].ci->chan, outs[j].ci->inst, outs[j].slot}] = int(j);
    for (size_t j = 0; j != ins.size(); ++j)
      in_[{ins[j].ci->chan, ins[j].ci->inst, ins[j].slot}] = int(j);
    pend_.resize(outs.size());
    built_ = true;
  }

  struct Pend { bool go = false; Bits msg; uint64_t tid = 0; };
  bool built_ = false;
  std::map<std::tuple<unsigned, unsigned, unsigned>, int> out_, in_;
  std::vector<Pend> pend_;
  std::set<unsigned> unhandled_;
};

/// A queued outbound message: slot, payload, identity.
struct Q { unsigned slot; Bits msg; uint64_t tid; };

// ---- testbench memory: the far end of EXTERNAL ---------------------------------

class Testbench : public Stub {
public:
  Testbench(int inst, Kernel &k) : Stub(inst, k) {
    for (size_t i = 0; i != k.orc.code.size(); ++i)
      k.mem[k.orc.code_base + i] = k.orc.code[i];
    for (auto &w : k.orc.init_mem)
      for (unsigned b = 0; b != 4; ++b)
        k.mem[w.first + b] = uint8_t(w.second >> (8 * b));
  }
  const char *kind() const override { return "testbench"; }

private:
  static constexpr uint64_t kLatency = 10;   // placeholder DRAM
  struct P { uint64_t due; Bits msg; uint64_t tid; };
  std::deque<P> q_;                          // D beats, in order
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
        for (unsigned beat = 0; beat != kBeats; ++beat) {
          Bits r = dBeat(kTlAckData, src);
          putBeat(r, kDData, l, beat);
          q_.push_back({now_ + kLatency + beat, r, m.tid});
        }
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
          q_.push_back({now_ + kLatency, dBeat(kTlAck, src), m.tid});
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
  Mlc(int inst, Kernel &k) : Stub(inst, k), ids_(ch().mlc_exb) {}
  const char *kind() const override { return "mlc"; }

private:
  enum Who { kDcu, kFet };
  /// What an EXB-side req_id stands for: who asked, and under which of
  /// THEIR ids -- each hop has its own id space.
  struct Owner { Who who; unsigned their_id; };
  struct R { Owner o; Bits msg; uint64_t tid; };
  std::deque<R> to_exb_;
  IdPool ids_;
  std::map<unsigned, Owner> owner_;   ///< by req_id toward EXB
  std::deque<Q> to_dcu_, to_fet_;

  void work() override {
    const Ch &c = ch();
    if (has(c.dcu_mlc, 0)) {
      Receiver::Msg m = take(c.dcu_mlc, 0);
      Bits e = msgOf(c.mlc_exb);
      put(e, c.mlc_exb, "phys_addr", get(m.payload, c.dcu_mlc, "phys_addr"));
      put(e, c.mlc_exb, "size", kSizeLine);
      put(e, c.mlc_exb, "coh_op", get(m.payload, c.dcu_mlc, "coh_op"));
      put(e, c.mlc_exb, "core_id", get(m.payload, c.dcu_mlc, "core_id"));
      putLine(e, field(c.mlc_exb, "writeback_data").lsb,
              getLine(m.payload, field(c.dcu_mlc, "writeback_data").lsb));
      to_exb_.push_back({{kDcu, unsigned(get(m.payload, c.dcu_mlc, "req_id"))}, e, m.tid});
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
           !to_fet_.empty();
  }
};

// ---- DCU: no cache yet; a write is read-modify-write of the line -----------------
//
// dcu_mlc_req carries no byte mask, so a partial store cannot go below DCU
// as it arrived: DCU reads the line, merges the bytes the mask selects, and
// writes the whole line. One request at a time.

class Dcu : public Stub {
public:
  Dcu(int inst, Kernel &k) : Stub(inst, k), ids_(ch().dcu_mlc) {}
  const char *kind() const override { return "dcu"; }

private:
  struct Op { unsigned slot; Bits req; uint64_t tid; };
  std::deque<Op> q_;
  enum { kIdle, kWaitLine, kWaitAck } st_ = kIdle;
  Op cur_{0, Bits(), 0};
  IdPool ids_;
  unsigned mlc_id_ = 0;              ///< the one request to MLC outstanding
  std::deque<Q> to_mlc_, to_miu_;

  /// A response to MIU answers its request by MIU's own req_id.
  Bits miuRsp() {
    Bits r = msgOf(ch().dcu_miu);
    put(r, ch().dcu_miu, "req_id", get(cur_.req, ch().miu_dcu, "req_id"));
    return r;
  }

  void mlcReq(unsigned coh, uint64_t pa, const Line *data) {
    const Ch &c = ch();
    Bits r = msgOf(c.dcu_mlc);
    put(r, c.dcu_mlc, "phys_addr", pa);
    put(r, c.dcu_mlc, "coh_op", coh);
    mlc_id_ = ids_.take();
    put(r, c.dcu_mlc, "req_id", mlc_id_);
    if (data) putLine(r, field(c.dcu_mlc, "writeback_data").lsb, *data);
    to_mlc_.push_back({0, r, cur_.tid});
  }

  void work() override {
    const Ch &c = ch();
    for (unsigned s = 0; s != kChans[c.miu_dcu].rate; ++s)
      while (has(c.miu_dcu, s)) {
        Receiver::Msg m = take(c.miu_dcu, s);
        q_.push_back({s, m.payload, m.tid});
      }
    if (has(c.mlc_dcu, 0)) {
      Receiver::Msg m = take(c.mlc_dcu, 0);
      const bool wr = get(cur_.req, c.miu_dcu, "coh_op") == kCohWrite;
      const unsigned id = unsigned(get(m.payload, c.mlc_dcu, "req_id"));
      if (st_ == kIdle || id != mlc_id_ || !ids_.release(id))
        k_.fail("dcu: MLC answered req_id %u, which is not outstanding", id);
      Bits r = miuRsp();
      if (st_ == kWaitLine && !wr) {
        putLine(r, field(c.dcu_miu, "read_data").lsb,
                getLine(m.payload, field(c.mlc_dcu, "line_data").lsb));
        to_miu_.push_back({cur_.slot, r, cur_.tid});
        st_ = kIdle;
      } else if (st_ == kWaitLine) {
        Line l = getLine(m.payload, field(c.mlc_dcu, "line_data").lsb);
        const Line w = getLine(cur_.req, field(c.miu_dcu, "write_data").lsb);
        const uint32_t mlsb = field(c.miu_dcu, "byte_mask").lsb;
        for (unsigned k = 0; k != kLine; ++k)
          if (cur_.req.bit(mlsb + k)) l[k] = w[k];
        mlcReq(kCohWrite, get(cur_.req, c.miu_dcu, "phys_addr"), &l);
        st_ = kWaitAck;
      } else if (st_ == kWaitAck) {
        to_miu_.push_back({cur_.slot, r, cur_.tid});   // the write's ack
        st_ = kIdle;
      } else {
        k_.fail("dcu: a line from MLC it did not ask for");
      }
    }
    if (st_ == kIdle && !q_.empty()) {
      cur_ = q_.front();
      q_.pop_front();
      mlcReq(kCohRead, get(cur_.req, c.miu_dcu, "phys_addr"), nullptr);
      st_ = kWaitLine;
    }
    if (!to_mlc_.empty() && can(c.dcu_mlc, 0)) {
      send(c.dcu_mlc, 0, to_mlc_.front().msg, to_mlc_.front().tid);
      to_mlc_.pop_front();
    }
    for (auto it = to_miu_.begin(); it != to_miu_.end();)
      if (can(c.dcu_miu, it->slot)) {
        send(c.dcu_miu, it->slot, it->msg, it->tid);
        it = to_miu_.erase(it);
      } else {
        ++it;
      }
  }
  bool busy() const override {
    return !q_.empty() || st_ != kIdle || !to_mlc_.empty() || !to_miu_.empty();
  }
};

// ---- MIU -------------------------------------------------------------------------

class Miu : public Stub {
public:
  Miu(int inst, Kernel &k) : Stub(inst, k), ids_(ch().miu_dcu) {}
  const char *kind() const override { return "miu"; }

private:
  struct Memop { unsigned slot; Bits msg; };
  struct Addr { unsigned slot; Bits msg; uint64_t tid; };
  struct LineReq { uint64_t line; Line data{}; std::array<bool, kLine> mask{}; uint16_t sub; };
  struct Job {
    bool store = false;
    unsigned tag = 0, memop_slot = 0, addr_slot = 0;
    unsigned phys_dst = 0, phys_pred = 0;   ///< echoed on miu_rcu_data
    uint32_t active = 0;             ///< lanes that may access memory
    uint64_t tid = 0;
    std::array<uint64_t, kLanes> addr{};
    std::vector<LineReq> lines;
    unsigned next = 0, back = 0;     ///< lines requested / answered
    std::map<uint64_t, Line> got;
  };

  std::map<unsigned, Memop> memop_;
  std::map<unsigned, Addr> addr_;
  std::deque<unsigned> order_;               ///< memops, as OOE issued them
  std::map<unsigned, Job> stores_;           ///< awaiting commit, by rob tag
  std::deque<Job> committed_;
  bool active_ = false;
  Job job_;
  bool dropped_ = false;
  IdPool ids_;
  std::map<unsigned, uint64_t> outstanding_;   ///< line, by req_id to DCU
  std::deque<Q> to_rcu_, to_ooe_, to_dcu_, to_fet_;

  void work() override {
    const Ch &c = ch();
    if (has(c.fet_miu, 0)) {
      // Identity translation: the page table is not modelled yet.
      Receiver::Msg m = take(c.fet_miu, 0);
      Bits r = msgOf(c.miu_fet);
      put(r, c.miu_fet, "itlb_refill", get(m.payload, c.fet_miu, "virtual_page"));
      to_fet_.push_back({0, r, m.tid});
    }
    if (has(c.rau_miu, 0)) take(c.rau_miu, 0);   // CTA config: nothing reads it yet
    for (unsigned s = 0; s != kChans[c.ooe_miu].rate; ++s)
      while (has(c.ooe_miu, s)) {
        Receiver::Msg m = take(c.ooe_miu, s);
        const unsigned tag = unsigned(get(m.payload, c.ooe_miu, "rob_tag"));
        memop_[tag] = {s, m.payload};
        order_.push_back(tag);
      }
    for (unsigned s = 0; s != kChans[c.rcu_miu].rate; ++s)
      while (has(c.rcu_miu, s)) {
        Receiver::Msg m = take(c.rcu_miu, s);
        addr_[unsigned(get(m.payload, c.rcu_miu, "rob_tag"))] = {s, m.payload, m.tid};
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
        auto o = outstanding_.find(id);
        if (!active_ || o == outstanding_.end()) {
          k_.fail("miu: a DCU response for req_id %u, which is not outstanding", id);
          continue;
        }
        const uint64_t line = o->second;
        outstanding_.erase(o);
        ids_.release(id);
        job_.got[line] = getLine(m.payload, field(c.dcu_miu, "read_data").lsb);
        ++job_.back;
      }

    if (!active_) start();
    if (active_) advance();

    auto drain = [&](std::deque<Q> &q, unsigned chan) {
      for (auto it = q.begin(); it != q.end();)
        if (can(chan, it->slot)) { send(chan, it->slot, it->msg, it->tid); it = q.erase(it); }
        else ++it;
    };
    drain(to_fet_, c.miu_fet);
    drain(to_rcu_, c.miu_rcu);
    drain(to_ooe_, c.miu_ooe);
    drain(to_dcu_, c.miu_dcu);
  }

  /// Committed stores first (they are older than anything still issuing),
  /// then the oldest memop whose address has arrived.
  void start() {
    const Ch &c = ch();
    if (!committed_.empty()) {
      job_ = committed_.front();
      committed_.pop_front();
      active_ = true;
      return;
    }
    if (order_.empty()) return;
    const unsigned tag = order_.front();
    auto a = addr_.find(tag);
    if (a == addr_.end()) return;
    const Memop &mo = memop_[tag];
    Job j;
    j.tag = tag;
    j.store = get(mo.msg, c.ooe_miu, "mem_op") == kMemStore;
    j.memop_slot = mo.slot;
    j.phys_dst = unsigned(get(mo.msg, c.ooe_miu, "phys_dst"));
    j.phys_pred = unsigned(get(mo.msg, c.ooe_miu, "phys_pred"));
    j.addr_slot = a->second.slot;
    j.tid = a->second.tid;
    const Bits &am = a->second.msg;
    // Two DIFFERENT masks: the issue mask from OOE, and active = issue AND
    // guard from RCU. They differ for any predicated op, correctly; what
    // must hold is that no lane is active outside the issue group.
    j.active = uint32_t(get(am, c.rcu_miu, "active_mask"));
    const uint32_t issue = uint32_t(get(mo.msg, c.ooe_miu, "issue_mask"));
    if (j.active & ~issue)
      k_.fail("miu: rob tag %u has active lanes %08x outside its issue group",
              tag, j.active & ~issue);
    // The AGU (§5.1): .global is (base << 16) + (index << scale) + disp, and
    // the scale is log2 of the element size, from chwidth, when enabled.
    // .shared has no window shift. disp is sign-extended from CCV_W_DISP.
    const FieldDesc &df = field(c.ooe_miu, "disp");
    const uint64_t draw = get(mo.msg, c.ooe_miu, "disp");
    const int64_t disp = int64_t(draw << (64 - df.width)) >> (64 - df.width);
    const unsigned chw = unsigned(get(mo.msg, c.ooe_miu, "chwidth"));
    const unsigned sh = get(mo.msg, c.ooe_miu, "scale_en") ? 2 - chw : 0;
    const bool global = get(mo.msg, c.ooe_miu, "space") == kSpaceGlobal;
    const uint64_t base = get(am, c.rcu_miu, "base") << (global ? 16 : 0);
    for (unsigned l = 0; l != kLanes; ++l)
      if ((j.active >> l) & 1u)
        j.addr[l] = base +
                    (uint64_t(getLane(am, c.rcu_miu, "index_per_lane", l)) << sh) +
                    uint64_t(disp);
    // Lines touched by ACTIVE lanes, in first-touch order; four bytes per
    // lane (32-bit only). An inactive lane's address is never looked at.
    std::map<uint64_t, size_t> at;
    for (unsigned l = 0; l != kLanes; ++l) {
      if (!((j.active >> l) & 1u)) continue;
      const uint64_t line = j.addr[l] / kLine * kLine;
      if (!at.count(line)) {
        at[line] = j.lines.size();
        j.lines.push_back({line, {}, {}, uint16_t(j.lines.size())});
      }
      if (j.store) {
        LineReq &lr = j.lines[at[line]];
        const uint32_t v = getLane(am, c.rcu_miu, "store_data", l);
        for (unsigned b = 0; b != 4; ++b) {
          const unsigned off = unsigned(j.addr[l] % kLine) + b;
          lr.data[off] = uint8_t(v >> (8 * b));
          lr.mask[off] = true;
        }
      }
    }
    check(j, am);
    order_.pop_front();
    memop_.erase(tag);
    addr_.erase(a);
    if (j.store) {
      // Translated and checked; the write waits for retirement.
      stores_[tag] = j;
      to_ooe_.push_back({j.memop_slot, cmpl(j), j.tid});
      return;
    }
    for (const LineReq &lr : j.lines)
      for (const auto &s : stores_)
        for (const LineReq &sl : s.second.lines)
          if (sl.line == lr.line)
            k_.fail("miu: load overlaps an uncommitted store -- forwarding is "
                    "not modelled");
    job_ = j;
    active_ = true;
  }

  /// The addresses and store data MIU computed from what it was SENT, against
  /// what ccv-sim says the instruction accessed.
  void check(const Job &j, const Bits &am) {
    const Record *r = rec(j.tid, "miu");
    if (!r) return;
    uint32_t lanes = 0;
    for (const MemAcc &a : r->mem) lanes |= 1u << a.lane;
    if (lanes != j.active || r->store != j.store) {
      k_.fail("miu: seq %llu active_mask %08x, but ccv-sim's %s touched lanes %08x",
              (unsigned long long)r->seq, j.active, r->store ? "store" : "load", lanes);
      return;
    }
    for (const MemAcc &a : r->mem) {
      if (a.addr != j.addr[a.lane] || a.bytes != 4 || a.shared)
        k_.fail("miu: seq %llu lane %u address %llx, oracle %llx",
                (unsigned long long)r->seq, a.lane,
                (unsigned long long)j.addr[a.lane], (unsigned long long)a.addr);
      if (j.store && getLane(am, ch().rcu_miu, "store_data", a.lane) != a.val)
        k_.fail("miu: seq %llu lane %u store data %08x, oracle %08x",
                (unsigned long long)r->seq, a.lane,
                getLane(am, ch().rcu_miu, "store_data", a.lane), a.val);
    }
  }

  Bits cmpl(const Job &j) {
    const Ch &c = ch();
    Bits m = msgOf(c.miu_ooe);
    put(m, c.miu_ooe, "rob_tag", j.tag);
    put(m, c.miu_ooe, "lane_mask", j.active);
    for (unsigned l = 0; l != kLanes; ++l)
      if ((j.active >> l) & 1u) { put(m, c.miu_ooe, "address", j.addr[l]); break; }
    put(m, c.miu_ooe, "mlc_miss", 1);
    return m;
  }

  void advance() {
    const Ch &c = ch();
    const unsigned rate = kChans[c.miu_dcu].rate;
    // Up to one line request per DCU slot per cycle.
    for (unsigned s = 0; s != rate && job_.next != job_.lines.size(); ++s) {
      if (!can(c.miu_dcu, s) || !ids_.any()) continue;
      const LineReq &lr = job_.lines[job_.next++];
      Bits r = msgOf(c.miu_dcu);
      const unsigned id = ids_.take();
      put(r, c.miu_dcu, "req_id", id);
      put(r, c.miu_dcu, "phys_addr", lr.line);
      put(r, c.miu_dcu, "size", kSizeLine);
      put(r, c.miu_dcu, "coh_op", job_.store ? kCohWrite : kCohRead);
      if (job_.store) {
        putLine(r, field(c.miu_dcu, "write_data").lsb, lr.data);
        const uint32_t mlsb = field(c.miu_dcu, "byte_mask").lsb;
        for (unsigned k = 0; k != kLine; ++k) r.setBit(mlsb + k, lr.mask[k]);
      }
      const uint64_t tid =
          makeUid(IdClass::kTxn, uidSeq(job_.tid), lr.sub, /*owned=*/true);
      send(c.miu_dcu, s, r, tid);
      outstanding_[id] = lr.line;
    }
    if (job_.back != job_.lines.size()) return;
    if (!job_.store) {
      Bits d = msgOf(c.miu_rcu);
      put(d, c.miu_rcu, "rob_tag", job_.tag);
      put(d, c.miu_rcu, "active_mask", job_.active);
      put(d, c.miu_rcu, "phys_dst",
          job_.phys_dst + (k_.brk == "corrupt-echo" && uidSeq(job_.tid) == 12 ? 1u : 0u));
      put(d, c.miu_rcu, "phys_pred", job_.phys_pred);
      put(d, c.miu_rcu, "pred_we", 0);          // a load writes no predicate
      const Record *r = rec(job_.tid, "miu");
      for (unsigned l = 0; l != kLanes; ++l) {
        if (!((job_.active >> l) & 1u)) continue;
        const Line &ln = job_.got[job_.addr[l] / kLine * kLine];
        const unsigned off = unsigned(job_.addr[l] % kLine);
        uint32_t v = 0;
        for (unsigned b = 0; b != 4; ++b) v |= uint32_t(ln[off + b]) << (8 * b);
        // What came back from memory, against what ccv-sim loaded.
        if (r)
          for (const MemAcc &a : r->mem)
            if (a.lane == l && a.val != v)
              k_.fail("miu: seq %llu lane %u loaded %08x, oracle %08x",
                      (unsigned long long)r->seq, l, v, a.val);
        if (k_.brk == "corrupt-load" && r && r->seq == 13 && l == 5) v ^= 1;
        putLane(d, c.miu_rcu, "load_data", l, v);
      }
      to_rcu_.push_back({job_.addr_slot, d, job_.tid});
      to_ooe_.push_back({job_.memop_slot, cmpl(job_), job_.tid});
    }
    active_ = false;
  }

  bool busy() const override {
    return active_ || !order_.empty() || !stores_.empty() ||
           !committed_.empty() || !to_rcu_.empty() || !to_ooe_.empty() ||
           !to_dcu_.empty() || !to_fet_.empty();
  }
};

// ---- LANE: one of 32; operands in, oracle result out ------------------------------

class Lane : public Stub {
public:
  Lane(int inst, Kernel &k) : Stub(inst, k), lane_(kBlkInsts[inst].index) {}
  const char *kind() const override { return "lane"; }

private:
  unsigned lane_;
  std::deque<Q> q_;

  void work() override {
    const Ch &c = ch();
    for (unsigned s = 0; s != kChans[c.rcu_lane].rate; ++s)
      while (has(c.rcu_lane, s, lane_)) {
        Receiver::Msg m = take(c.rcu_lane, s, lane_);
        Bits r = msgOf(c.lane_rcu);
        // The mask arrived with valid, a cycle ahead of the operands (the
        // channel's lead fields, Q-40). A lane it switches off does nothing:
        // it never captures its operands, never computes, and drives no
        // result -- modelled as poison on its outputs, so a receiver that
        // wrote back a masked-off lane would be caught by the final compare.
        const bool on = get(m.payload, c.rcu_lane, "pred_bit") != 0;
        if (const Record *rc = rec(m.tid, "lane")) {
          const OpInfo *op = opByCode(unsigned(get(m.payload, c.rcu_lane, "opcode")));
          if (op && inRcu(op->cls))
            k_.fail("lane %u: %s reached a lane; its class executes in RCU", lane_, op->name);
          if (op && !perLaneInput(op, *rc))
            k_.fail("lane %u: %s has no per-lane input; RCU executes it (Q-32)",
                    lane_, op->name);
          if (!op || rc->op != op->name)
            k_.fail("lane %u: seq %llu opcode is not %s", lane_,
                    (unsigned long long)rc->seq, rc->op.c_str());
          // Operands: what RCU read out of its register file.
          const auto g = rc->gprUses();
          for (size_t i = 0; on && i != g.size() && i < 3; ++i) {
            const uint32_t got = uint32_t(m.payload.get(
                field(c.rcu_lane, "operand").lsb + 32 * unsigned(i), 32));
            if (got != g[i]->v[lane_])
              k_.fail("lane %u: seq %llu operand %zu (R%u) %08x, oracle %08x",
                      lane_, (unsigned long long)rc->seq, i, g[i]->idx, got,
                      g[i]->v[lane_]);
          }
          // An immediate RCU substituted into its operand slot. srd's is
          // identity from OOE rather than the encoded selector, and its
          // check is the lane's own result check below.
          if (on && op && op->alu_imm >= 0 && op->srd_sel < 0 &&
              size_t(op->alu_imm) < rc->imms.size()) {
            const uint32_t got = uint32_t(m.payload.get(
                field(c.rcu_lane, "operand").lsb + 32 * unsigned(op->imm_slot), 32));
            if (got != uint32_t(rc->imms[op->alu_imm]))
              k_.fail("lane %u: seq %llu immediate operand %08x, oracle %08x",
                      lane_, (unsigned long long)rc->seq, got,
                      uint32_t(rc->imms[op->alu_imm]));
          }
          // pred_bit is this lane's enable: in the issue group AND past the
          // guard. Without a guard it is the issue mask alone.
          bool want = (rc->mask >> lane_) & 1u;
          if (op && op->guard)
            if (const RegVal *p = rc->predUse()) {
              const bool neg = !rc->quals.empty() && ((rc->quals[0] >> 2) & 1);
              want = want && ((((p->p >> lane_) & 1u) != 0) != neg);
            }
          if ((get(m.payload, c.rcu_lane, "pred_bit") != 0) != want)
            k_.fail("lane %u: seq %llu pred_bit is not issue mask AND guard",
                    lane_, (unsigned long long)rc->seq);
          // The result: what ccv-sim computed (the "what", §1) -- except
          // srd's, which the lane computes: the immediate RCU substituted,
          // with the lane's hardwired index ORed in for %ctatid. OOE's
          // identity, not the oracle, supplies the value.
          if (!on) {
            put(r, c.lane_rcu, "result", 0xdeadbeefu);
            if (const RegVal *d = rc->predDef())
              put(r, c.lane_rcu, "pred_out", ((d->p >> lane_) & 1u) ^ 1u);
          } else if (const RegVal *d = rc->gprDef()) {
            uint32_t v = d->v[lane_];
            if (op && op->srd_sel >= 0) {
              const uint32_t o0 = uint32_t(m.payload.get(field(c.rcu_lane, "operand").lsb, 32));
              v = op->or_lane ? (o0 | lane_) : o0;
              if (v != d->v[lane_])
                k_.fail("lane %u: seq %llu srd %u, oracle %u", lane_,
                        (unsigned long long)rc->seq, v, d->v[lane_]);
            }
            put(r, c.lane_rcu, "result", v);
          }
          if (on)
            if (const RegVal *d = rc->predDef())
              put(r, c.lane_rcu, "pred_out", (d->p >> lane_) & 1u);
          // A predicate read as DATA (sel's selector), negate applied.
          if (on && op && op->pdata)
            if (const RegVal *p = rc->predUse()) {
              const bool neg = !rc->quals.empty() && ((rc->quals[0] >> 2) & 1);
              const bool want = (((p->p >> lane_) & 1u) != 0) != neg;
              if ((get(m.payload, c.rcu_lane, "pred_data") != 0) != want)
                k_.fail("lane %u: seq %llu pred_data (sel's selector) wrong", lane_,
                        (unsigned long long)rc->seq);
            }
        }
        q_.push_back({s, r, m.tid});
      }
    for (auto it = q_.begin(); it != q_.end();)
      if (can(c.lane_rcu, it->slot, lane_)) {
        send(c.lane_rcu, it->slot, it->msg, it->tid, lane_);
        it = q_.erase(it);
      } else {
        ++it;
      }
  }
  bool busy() const override { return !q_.empty(); }
};

// ---- RCU: the register file ----------------------------------------------------------

class Rcu : public Stub {
public:
  Rcu(int inst, Kernel &k) : Stub(inst, k) {
    k.gpr.assign(256, {});
    k.pred.assign(256, 0);
  }
  const char *kind() const override { return "rcu"; }

private:
  struct Alu {
    unsigned tag; const OpInfo *op; unsigned pdst, ppred; bool pwe;
    uint32_t active; uint64_t tid;
  };

  std::array<std::deque<Alu>, 4> alu_;            ///< per issue slot: bound lanes
  std::array<std::deque<std::pair<std::vector<Bits>, uint64_t>>, 4> lane_q_;
  std::deque<Q> to_ooe_, to_miu_;

  Bits done(unsigned tag) {
    Bits d = msgOf(ch().rcu_ooe);
    put(d, ch().rcu_ooe, "rob_tag", tag);
    return d;
  }

  void work() override {
    const Ch &c = ch();
    const unsigned rate = kChans[c.ooe_rcu].rate;
    for (unsigned s = 0; s != rate; ++s)
      while (has(c.ooe_rcu, s)) issue(s, take(c.ooe_rcu, s));

    // Lane results, slot by slot: all 32 lanes, or it is not lockstep.
    for (unsigned s = 0; s != rate; ++s) {
      unsigned n = 0;
      for (unsigned l = 0; l != kLanes; ++l) n += has(c.lane_rcu, s, l);
      if (n == 0) continue;
      if (n != kLanes) { k_.fail("rcu: %u of 32 lanes answered on slot %u", n, s); continue; }
      if (alu_[s].empty()) { k_.fail("rcu: lane results on slot %u for nothing", s); continue; }
      const Alu a = alu_[s].front();
      alu_[s].pop_front();
      for (unsigned l = 0; l != kLanes; ++l) {
        Receiver::Msg m = take(c.lane_rcu, s, l);
        if (m.tid != a.tid) k_.fail("rcu: lane %u slot %u answered for another instruction", l, s);
        const uint32_t v = uint32_t(get(m.payload, c.lane_rcu, "result"));
        const uint32_t po = uint32_t(get(m.payload, c.lane_rcu, "pred_out"));
        // A partial write preserves what it does not write (ISA invariant
        // 10): only the active lanes take a result.
        if (!((a.active >> l) & 1u) && k_.brk != "ignore-mask") continue;
        if (a.op->gdst) k_.gpr[a.pdst][l] = v;
        if (a.pwe) k_.pred[a.ppred] = (k_.pred[a.ppred] & ~(1u << l)) | (po << l);
      }
      to_ooe_.push_back({s, done(a.tag), a.tid});
    }

    for (unsigned s = 0; s != kChans[c.miu_rcu].rate; ++s)
      while (has(c.miu_rcu, s)) {
        Receiver::Msg m = take(c.miu_rcu, s);
        // Stateless write-back: every destination arrives with the data,
        // echoed by MIU from the memop.
        const unsigned tag = unsigned(get(m.payload, c.miu_rcu, "rob_tag"));
        const unsigned pd = unsigned(get(m.payload, c.miu_rcu, "phys_dst"));
        const uint32_t active = uint32_t(get(m.payload, c.miu_rcu, "active_mask"));
        for (unsigned l = 0; l != kLanes; ++l)
          if ((active >> l) & 1u)   // an inactive lane keeps its old value
            k_.gpr[pd][l] = getLane(m.payload, c.miu_rcu, "load_data", l);
        if (get(m.payload, c.miu_rcu, "pred_we")) {
          const unsigned pp = unsigned(get(m.payload, c.miu_rcu, "phys_pred"));
          const uint32_t pr = uint32_t(get(m.payload, c.miu_rcu, "pred_result"));
          k_.pred[pp] = (k_.pred[pp] & ~active) | (pr & active);
        }
        to_ooe_.push_back({s, done(tag), m.tid});
      }

    for (unsigned s = 0; s != rate; ++s) {
      if (lane_q_[s].empty()) continue;
      bool all = true;
      for (unsigned l = 0; l != kLanes; ++l) all = all && can(c.rcu_lane, s, l);
      if (!all) continue;     // lockstep: every lane or none
      for (unsigned l = 0; l != kLanes; ++l)
        send(c.rcu_lane, s, lane_q_[s].front().first[l], lane_q_[s].front().second, l);
      lane_q_[s].pop_front();
    }
    for (auto *q : {&to_ooe_, &to_miu_}) {
      const unsigned chan = q == &to_ooe_ ? c.rcu_ooe : c.rcu_miu;
      for (auto it = q->begin(); it != q->end();)
        if (can(chan, it->slot)) { send(chan, it->slot, it->msg, it->tid); it = q->erase(it); }
        else ++it;
    }
  }

  void issue(unsigned s, const Receiver::Msg &m) {
    const Ch &c = ch();
    const unsigned tag = unsigned(get(m.payload, c.ooe_rcu, "rob_tag"));
    const OpInfo *op = opByCode(unsigned(get(m.payload, c.ooe_rcu, "opcode")));
    if (!op) { k_.fail("rcu: unknown opcode"); return; }
    const unsigned ps = unsigned(get(m.payload, c.ooe_rcu, "phys_src"));
    const unsigned pd = unsigned(get(m.payload, c.ooe_rcu, "phys_dst"));
    const unsigned pp = unsigned(get(m.payload, c.ooe_rcu, "phys_pred_guard"));
    const unsigned ppd = unsigned(get(m.payload, c.ooe_rcu, "phys_pred_dst"));
    const bool pwe = get(m.payload, c.ooe_rcu, "pred_we") != 0;
    const unsigned src[3] = {(ps >> 8) & 0xff, ps & 0xff,
                             unsigned(get(m.payload, c.ooe_rcu, "phys_src2"))};
    // Active lanes = issue mask AND guard. RCU is the one block holding both
    // -- the issue mask arrives here, the predicate values live here -- so
    // it is the sole producer of active_mask, and pred_bit is the same
    // computation per lane. A predicate read as DATA (por's sources) is not
    // a guard and does not narrow it (Q-27).
    const uint32_t issue = uint32_t(get(m.payload, c.ooe_rcu, "issue_mask"));
    const uint32_t guard = get(m.payload, c.ooe_rcu, "pred_neg") ? ~k_.pred[pp] : k_.pred[pp];
    const uint32_t active = issue & (op->guard ? guard : 0xffffffffu);
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
    if (op->cls == kImm && k_.brk != "movi-in-lane") {
      for (unsigned l = 0; l != kLanes; ++l)
        if ((active >> l) & 1u) k_.gpr[pd][l] = imm0;
      if (const Record *r = rec(m.tid, "rcu"))
        if (const RegVal *d = r->gprDef())
          for (unsigned l = 0; l != kLanes; ++l)
            if (((active >> l) & 1u) && k_.gpr[pd][l] != d->v[l]) {
              k_.fail("rcu: seq %llu R%u lane %u = %08x, oracle %08x",
                      (unsigned long long)r->seq, d->idx, l, k_.gpr[pd][l], d->v[l]);
              break;
            }
      to_ooe_.push_back({s, done(tag), m.tid});
      return;
    }
    // Predicate logic executes HERE, beside the predicate file, and never
    // reaches a lane (O-33's second obligation; round 16). Sources are two
    // qualifiers in imm: [2:0] ps0, [5:3] ps1, each [1:0] index + [2] negate.
    if (op->cls == kPredLogic) {
      auto src = [&](unsigned q) {
        const uint32_t v = k_.pred[physPred(0, q & 3)];
        return (q >> 2) & 1 ? ~v : v;
      };
      const uint32_t a = src(imm0 & 7), b = src((imm0 >> 3) & 7);
      uint32_t v = 0;
      if (!std::strcmp(op->name, "POR")) v = a | b;
      else k_.fail("rcu: predicate op %s has no semantics here", op->name);
      if (!pwe) k_.fail("rcu: %s without pred_we", op->name);
      k_.pred[ppd] = (k_.pred[ppd] & ~issue) | (v & issue);
      if (const Record *r = rec(m.tid, "rcu"))
        if (const RegVal *d = r->predDef())
          if (k_.pred[ppd] != d->p)
            k_.fail("rcu: seq %llu P%u = %08x, oracle %08x",
                    (unsigned long long)r->seq, d->idx, k_.pred[ppd], d->p);
      to_ooe_.push_back({s, done(tag), m.tid});
      return;
    }
    // Branches resolve HERE too: the condition is a predicate. The taken
    // lanes are issue mask AND guard; any lane taking it is a redirect.
    if (op->cls == kBranch) {
      Bits d = done(tag);
      put(d, c.rcu_ooe, "branch_taken", active != 0);
      put(d, c.rcu_ooe, "branch_mask", active);
      if (const Record *r = rec(m.tid, "rcu"))
        if (r->taken != active)
          k_.fail("rcu: seq %llu branch taken by %08x, oracle %08x",
                  (unsigned long long)r->seq, active, r->taken);
      to_ooe_.push_back({s, d, m.tid});
      return;
    }

    if (op->cls == kLoad || op->cls == kStore) {
      Bits a = msgOf(c.rcu_miu);
      put(a, c.rcu_miu, "rob_tag", tag);
      put(a, c.rcu_miu, "active_mask", active);
      // Register values only: the AGU is MIU's, and the displacement and
      // scale reach it on the memop.
      const auto &b = k_.gpr[src[op->base_src]];
      for (unsigned l = 1; l != kLanes; ++l)
        if (((active >> l) & 1u) && b[l] != b[0]) {
          k_.fail("rcu: window base differs across lanes; rcu_miu_addr.base is scalar");
          break;
        }
      put(a, c.rcu_miu, "base", b[0]);
      for (unsigned l = 0; l != kLanes; ++l) {
        if (op->index_src >= 0)
          putLane(a, c.rcu_miu, "index_per_lane", l, k_.gpr[src[op->index_src]][l]);
        if (op->cls == kStore)
          putLane(a, c.rcu_miu, "store_data", l, k_.gpr[src[op->data_src]][l]);
      }
      to_miu_.push_back({s, a, m.tid});
      // A load's write-back is MIU's echo; RCU remembers nothing of it.
      if (op->cls == kStore) to_ooe_.push_back({s, done(tag), m.tid});
      return;
    }
    // An ALU immediate is substituted into its operand slot here, at
    // register read: lanes never see an immediate, only operands.
    const uint32_t imm = imm0;
    std::vector<Bits> lanes;
    for (unsigned l = 0; l != kLanes; ++l) {
      Bits o = msgOf(c.rcu_lane);
      put(o, c.rcu_lane, "opcode", opcodeOf(op));
      const uint32_t olsb = field(c.rcu_lane, "operand").lsb;
      for (unsigned i = 0; i != op->nsrc; ++i)
        o.set(olsb + 32 * i, 32, k_.gpr[src[i]][l]);
      if (op->alu_imm >= 0) o.set(olsb + 32 * unsigned(op->imm_slot), 32, imm);
      put(o, c.rcu_lane, "pred_bit", (active >> l) & 1u);
      if (op->pdata && k_.brk != "drop-pred-data")
        put(o, c.rcu_lane, "pred_data", (guard >> l) & 1u);
      put(o, c.rcu_lane, "section_en", 1);
      lanes.push_back(o);
    }
    lane_q_[s].push_back({lanes, m.tid});
    alu_[s].push_back({tag, op, pd, ppd, pwe, active, m.tid});
  }

  bool busy() const override {
    for (unsigned s = 0; s != 4; ++s)
      if (!alu_[s].empty() || !lane_q_[s].empty()) return true;
    return !to_ooe_.empty() || !to_miu_.empty();
  }
};

// ---- OOE: in-order issue with a scoreboard, in-order retire ------------------------

class Ooe : public Stub {
public:
  using Stub::Stub;
  const char *kind() const override { return "ooe"; }

private:
  struct E {
    uint64_t tid, pc;
    unsigned tag, warp;
    const OpInfo *op;
    unsigned src[3], dst, pguard, pdst;   ///< architectural
    uint32_t imm = 0;
    bool scale_en = false, pneg = false, pwe = false;
    bool taken = false;
    uint32_t taken_mask = 0;
    bool issued = false, rcu = false, miu = false, committed = false;
    bool complete() const {
      const bool mem = op->cls == kLoad || op->cls == kStore;
      return op->cls == kExit ? issued : issued && rcu && (!mem || miu);
    }
  };
  std::deque<E> rob_;
  unsigned next_tag_ = 0;
  unsigned prf_base_[32] = {};
  // Identity, shadowed from RAU's table on every activation (Q-38).
  uint32_t ctaid_[32] = {}, warp_in_cta_[32] = {};
  static constexpr unsigned kRob = 128;

  void work() override {
    const Ch &c = ch();
    if (has(c.rau_ooe, 0)) {
      Receiver::Msg m = take(c.rau_ooe, 0);
      const unsigned w = unsigned(get(m.payload, c.rau_ooe, "warp_id"));
      prf_base_[w] = unsigned(get(m.payload, c.rau_ooe, "prf_base"));
      ctaid_[w] = uint32_t(get(m.payload, c.rau_ooe, "ctaid"));
      warp_in_cta_[w] = uint32_t(get(m.payload, c.rau_ooe, "warp_in_cta"));
      if (w == 0) k_.prf_base = prf_base_[w];
    }
    // Uops: oldest first by (arrival, slot) -- all landed this cycle, so slot
    // order is age order; the key (warp_id) keeps each warp's own order.
    for (unsigned s = 0; s != kChans[c.dec_ooe].rate; ++s)
      while (has(c.dec_ooe, s)) dispatch(take(c.dec_ooe, s));
    for (unsigned s = 0; s != kChans[c.rcu_ooe].rate; ++s)
      while (has(c.rcu_ooe, s)) {
        Receiver::Msg m = take(c.rcu_ooe, s);
        if (E *e = byTag(unsigned(get(m.payload, c.rcu_ooe, "rob_tag")))) {
          e->rcu = true;
          e->taken = get(m.payload, c.rcu_ooe, "branch_taken") != 0;
          e->taken_mask = uint32_t(get(m.payload, c.rcu_ooe, "branch_mask"));
          if (e->op->cls == kBranch && e->taken) redirect(*e);
        } else {
          k_.fail("ooe: done for a tag not in the ROB");
        }
      }
    for (unsigned s = 0; s != kChans[c.miu_ooe].rate; ++s)
      while (has(c.miu_ooe, s)) {
        Receiver::Msg m = take(c.miu_ooe, s);
        if (get(m.payload, c.miu_ooe, "status") != 0) k_.fail("ooe: memory op failed");
        if (E *e = byTag(unsigned(get(m.payload, c.miu_ooe, "rob_tag")))) e->miu = true;
        else k_.fail("ooe: completion for a tag not in the ROB");
      }
    issueOne();
    retireOne();
    if (!redirects_.empty() && can(c.ooe_fet, 0)) {
      send(c.ooe_fet, 0, redirects_.front().msg, redirects_.front().tid);
      redirects_.pop_front();
    }
  }

  /// RCU resolved a branch some lane takes: tell FET, which owns the PC.
  /// Group masks: the taken lanes, then the lanes that fall through.
  unsigned fetch_epoch_ = 0;
  std::deque<Q> redirects_;
  void redirect(const E &e) {
    const Ch &c = ch();
    Bits r = msgOf(c.ooe_fet);
    put(r, c.ooe_fet, "warp_id", e.warp);
    put(r, c.ooe_fet, "tier1_id", 0);
    put(r, c.ooe_fet, "target_pc", e.pc + uint64_t(int64_t(int32_t(e.imm))));
    const FieldDesc &gm = field(c.ooe_fet, "group_masks");
    r.set(gm.lsb, 32, e.taken_mask);
    r.set(gm.lsb + 32, 32, 0xffffffffu & ~e.taken_mask);   // issue mask: all 32
    fetch_epoch_ = (fetch_epoch_ + 1) % (1u << field(c.ooe_fet, "fetch_epoch").width);
    put(r, c.ooe_fet, "fetch_epoch", fetch_epoch_);
    redirects_.push_back({0, r, e.tid});
  }

  E *byTag(unsigned t) {
    for (E &e : rob_) if (e.tag == t) return &e;
    return nullptr;
  }

  void dispatch(const Receiver::Msg &m) {
    const Ch &c = ch();
    const Bits &u = m.payload;
    E e;
    e.tid = m.tid;
    e.pc = get(u, c.dec_ooe, "pc");
    e.warp = unsigned(get(u, c.dec_ooe, "warp_id"));
    e.op = opByCode(unsigned(get(u, c.dec_ooe, "opcode")));
    if (!e.op || get(u, c.dec_ooe, "decode_fault")) {
      k_.fail("ooe: a uop it cannot execute");
      return;
    }
    if (rob_.size() == kRob) k_.fail("ooe: ROB overflow");
    const unsigned sa = unsigned(get(u, c.dec_ooe, "src_arch"));
    e.src[0] = (sa >> 4) & 15;
    e.src[1] = sa & 15;
    e.src[2] = unsigned(get(u, c.dec_ooe, "src2_arch"));
    e.dst = unsigned(get(u, c.dec_ooe, "dst_arch"));
    e.imm = uint32_t(get(u, c.dec_ooe, "imm"));
    e.scale_en = get(u, c.dec_ooe, "scale_en") != 0;
    e.pneg = get(u, c.dec_ooe, "pred_neg") != 0;
    e.pguard = unsigned(get(u, c.dec_ooe, "pred_guard"));
    e.pdst = unsigned(get(u, c.dec_ooe, "pred_dst"));
    e.pwe = get(u, c.dec_ooe, "pred_we") != 0;
    e.tag = next_tag_;
    next_tag_ = (next_tag_ + 1) % kRob;
    emit(now_, e.tid, EV_DISPATCH, UNIT_OOE, e.warp, e.tag);
    rob_.push_back(e);
  }

  /// Registers an entry reads and writes, as (kind, index) pairs.
  static void regs(const E &e, std::vector<unsigned> &rd, std::vector<unsigned> &wr) {
    for (unsigned i = 0; i != e.op->nsrc; ++i) rd.push_back(e.src[i]);
    if (e.op->guard || e.op->pdata) rd.push_back(100 + e.pguard);
    if (e.op->cls == kPredLogic) {    // its sources are qualifiers in imm
      rd.push_back(100 + (e.imm & 3));
      rd.push_back(100 + ((e.imm >> 3) & 3));
    }
    if (e.op->gdst) wr.push_back(e.dst);
    if (e.pwe) wr.push_back(100 + e.pdst);
  }

  void issueOne() {
    const Ch &c = ch();
    size_t i = 0;
    while (i != rob_.size() && rob_[i].issued) ++i;
    if (i == rob_.size()) return;
    E &e = rob_[i];
    std::vector<unsigned> rd, wr;
    regs(e, rd, wr);
    const bool mem = e.op->cls == kLoad || e.op->cls == kStore;
    for (size_t j = 0; j != i; ++j) {
      if (rob_[j].complete()) continue;
      std::vector<unsigned> ord, owr;
      regs(rob_[j], ord, owr);
      for (unsigned w : owr) {
        for (unsigned r : rd) if (r == w) return;    // RAW
        for (unsigned x : wr) if (x == w) return;    // WAW
      }
      const bool omem = rob_[j].op->cls == kLoad || rob_[j].op->cls == kStore;
      if (mem && omem) return;                       // memory in order
      if (e.op->cls == kExit) return;                // exit waits for all
    }
    if (e.op->cls == kExit) { e.issued = true; return; }
    const unsigned slot = e.tag % kChans[c.ooe_rcu].rate;
    if (!can(c.ooe_rcu, slot) || (mem && !can(c.ooe_miu, slot))) return;
    const unsigned pb = prf_base_[e.warp];
    Bits is = msgOf(c.ooe_rcu);
    put(is, c.ooe_rcu, "rob_tag", e.tag);
    put(is, c.ooe_rcu, "warp_id", e.warp);
    // The issue group's lanes. OOE chose the PC group, so this is its to
    // send; vadd never diverges, so it is all 32 (lanes check the oracle).
    const uint32_t issue_mask = 0xffffffffu;
    put(is, c.ooe_rcu, "issue_mask", issue_mask);
    put(is, c.ooe_rcu, "phys_src", ((pb + e.src[0]) << 8) | (pb + e.src[1]));
    put(is, c.ooe_rcu, "phys_src2", pb + e.src[2]);
    // srd's value is identity, which OOE holds, so it goes in the immediate
    // here and RCU substitutes it like any other: warp_base for %ctatid
    // (the lane ORs its index in), %ctaid itself for selector 1.
    uint32_t imm = e.imm;
    if (e.op->srd_sel >= 0)
      imm = e.op->or_lane ? warp_in_cta_[e.warp] << 5 : ctaid_[e.warp];
    if (!mem) put(is, c.ooe_rcu, "imm", imm);
    put(is, c.ooe_rcu, "phys_dst", pb + e.dst);
    put(is, c.ooe_rcu, "phys_pred_guard", physPred(e.warp, e.pguard));
    put(is, c.ooe_rcu, "phys_pred_dst", physPred(e.warp, e.pdst));
    put(is, c.ooe_rcu, "pred_we", e.pwe);
    put(is, c.ooe_rcu, "pred_neg", e.pneg && k_.brk != "drop-negate");
    put(is, c.ooe_rcu, "opcode", opcodeOf(e.op));
    send(c.ooe_rcu, slot, is, e.tid);
    if (mem) {
      Bits mo = msgOf(c.ooe_miu);
      put(mo, c.ooe_miu, "rob_tag", e.tag);
      put(mo, c.ooe_miu, "warp_id", e.warp);
      put(mo, c.ooe_miu, "mem_op", e.op->cls == kStore ? kMemStore : kMemLoad);
      // The issue mask, not the active mask: only RCU holds the predicate
      // values, so only RCU computes active = issue AND guard.
      put(mo, c.ooe_miu, "issue_mask", issue_mask);
      // Write-back destinations, for MIU to echo: RCU keeps no load table.
      put(mo, c.ooe_miu, "phys_dst", pb + e.dst);
      put(mo, c.ooe_miu, "phys_pred", physPred(e.warp, e.pdst));
      put(mo, c.ooe_miu, "disp",                    // truncated to CCV_W_DISP
          e.imm + (k_.brk == "corrupt-disp" && uidSeq(e.tid) == 6 ? 4u : 0u));
      put(mo, c.ooe_miu, "scale_en", e.scale_en);
      put(mo, c.ooe_miu, "space", kSpaceGlobal);   // every memory op in the table
      send(c.ooe_miu, slot, mo, e.tid);
    }
    e.issued = true;
    emit(now_, e.tid, EV_ISSUE, UNIT_OOE, e.warp, slot, e.tag);
  }

  void retireOne() {
    const Ch &c = ch();
    if (rob_.empty() || !rob_.front().complete()) return;
    E &e = rob_.front();
    if (e.op->cls == kStore && !e.committed) {
      const unsigned slot = e.tag % kChans[c.ooe_ret].rate;
      if (!can(c.ooe_ret, slot)) return;
      Bits r = msgOf(c.ooe_ret);
      put(r, c.ooe_ret, "rob_tag", e.tag);
      put(r, c.ooe_ret, "commit_or_discard", 1);
      send(c.ooe_ret, slot, r, e.tid);
      e.committed = true;
    }
    // No active-lane mask reaches OOE: active_mask is RCU's alone (Q-23),
    // so every group retires with all 32 lanes.
    emit(now_, e.tid, EV_RETIRE, UNIT_OOE, e.warp, e.tag, 0xffffffffu);
    ++k_.retired;
    k_.retire_order.push_back(uidSeq(e.tid));
    if (e.op->cls == kExit) k_.exited = true;
    rob_.pop_front();
  }

  bool busy() const override { return !rob_.empty() || !redirects_.empty(); }
};

// ---- DEC ---------------------------------------------------------------------------

class Dec : public Stub {
public:
  using Stub::Stub;
  const char *kind() const override { return "dec"; }

private:
  std::deque<std::pair<Bits, uint64_t>> q_;

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
    // hold an unallocated value, so this is a range comparison. Allocating
    // selector 2 later is one line here.
    if (op && op->srd_sel >= 0) {
      const int64_t sel = (r->imms.empty() ? 0 : r->imms[0]) +
                          (k_.brk == "srd-selector" ? 2 : 0);
      op = srdBySel(sel);
      if (!op) {
        k_.fail("dec: seq %llu srd selector %lld is unallocated (a legal field, "
                "an illegal value)", (unsigned long long)r->seq, (long long)sel);
        Bits u = msgOf(c.dec_ooe);
        put(u, c.dec_ooe, "warp_id", get(f, c.fet_dec, "warp_id"));
        put(u, c.dec_ooe, "pc", pc);
        put(u, c.dec_ooe, "decode_fault", 1);
        q_.push_back({u, m.tid});
        return;
      }
    }
    Bits u = msgOf(c.dec_ooe);
    put(u, c.dec_ooe, "warp_id", get(f, c.fet_dec, "warp_id"));
    put(u, c.dec_ooe, "pc", pc);
    if (!op) {
      k_.fail("dec: %s is not in the skeleton's opcode table", r->op.c_str());
      put(u, c.dec_ooe, "decode_fault", 1);
      q_.push_back({u, m.tid});
      return;
    }
    const auto g = r->gprUses();
    const RegVal *gd = r->gprDef(), *pu = r->predUse(), *pd = r->predDef();
    if (g.size() != op->nsrc || bool(gd) != op->gdst || bool(pu) != op->pread ||
        bool(pd) != op->pwrite)
      k_.fail("dec: seq %llu %s has an operand shape the table does not",
              (unsigned long long)r->seq, op->name);
    const unsigned dst = gd ? gd->idx : 0;
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
    put(u, c.dec_ooe, "opcode", opcodeOf(op));
    // Three source fields: Format A's rs2 is an independent source (mad.lo's
    // and dp4's accumulator input), with rd independent of it.
    put(u, c.dec_ooe, "src_arch",
        ((g.size() > 0 ? g[0]->idx : 0u) << 4) | (g.size() > 1 ? g[1]->idx : 0u));
    put(u, c.dec_ooe, "src2_arch", g.size() > 2 ? g[2]->idx : 0u);
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
      // A branch's imm is its byte offset from its OWN pc: DEC knows the
      // length, which the uop does not carry, so it folds it in here
      // (offsets are halfwords, from the next instruction).
      imm = uint32_t(int64_t(r->size) + 2 * immOf(0));
    } else if (op->cls == kPredLogic) {
      // Predicate logic executes in RCU (O-33, round 16). Its two source
      // qualifiers ride in imm: [2:0] ps0, [5:3] ps1.
      if (r->quals.size() < 2) k_.fail("dec: seq %llu predicate logic without two sources",
                                       (unsigned long long)r->seq);
      else imm = (r->quals[0] & 7) | ((r->quals[1] & 7) << 3);
    }
    put(u, c.dec_ooe, "imm", imm);
    put(u, c.dec_ooe, "pred_neg", pneg);
    put(u, c.dec_ooe, "scale_en", immOf(op->scale_imm) != 0);
    put(u, c.dec_ooe, "pred_guard", pguard);
    put(u, c.dec_ooe, "pred_dst", pdst);
    put(u, c.dec_ooe, "pred_we", pd != nullptr);
    q_.push_back({u, m.tid});
  }

  bool busy() const override { return !q_.empty(); }
};

// ---- FET: trace-driven fetch -------------------------------------------------------
//
// The ORDER of fetch comes from the oracle (no branch unit yet: a taken
// branch would simply be the next record's pc). The BYTES do not: they are
// read out of lines fetched through ITLB and the ifill path.

class Fet : public Stub {
public:
  Fet(int inst, Kernel &k) : Stub(inst, k), ids_(ch().fet_mlc) {}
  const char *kind() const override { return "fet"; }

private:
  static constexpr unsigned kPage = 4096;
  bool launched_ = false;
  size_t next_ = 0;
  std::map<uint64_t, uint64_t> page_;       ///< virtual page -> physical page
  std::set<uint64_t> itlb_wait_;
  std::map<uint64_t, Line> line_;           ///< by virtual line address
  IdPool ids_;
  std::map<unsigned, uint64_t> ifill_wait_; ///< virtual line, by req_id
  std::deque<Q> fills_, itlbs_;
  unsigned epoch_ = 0;                      ///< from the last redirect

  void work() override {
    const Ch &c = ch();
    const auto &recs = k_.orc.recs;
    if (has(c.rau_fet, 0)) {
      Receiver::Msg m = take(c.rau_fet, 0);
      const uint64_t start = get(m.payload, c.rau_fet, "start_pc");
      if (recs.empty() || start != recs[0].pc)
        k_.fail("fet: launch at %llx, but ccv-sim began elsewhere",
                (unsigned long long)start);
      launched_ = true;
    }
    if (has(c.ooe_fet, 0)) {
      // A redirect. Fetch ORDER is still the oracle's, so what FET can do is
      // check the redirect says where ccv-sim went, and take the new epoch
      // (a real FET discards in-flight fetches from older epochs).
      Receiver::Msg m = take(c.ooe_fet, 0);
      const uint64_t tgt = get(m.payload, c.ooe_fet, "target_pc");
      const uint32_t tmask = uint32_t(m.payload.get(field(c.ooe_fet, "group_masks").lsb, 32));
      if (const Record *r = rec(m.tid, "fet")) {
        if (tgt != r->target || tmask != r->taken)
          k_.fail("fet: seq %llu redirect to %llx for lanes %08x; ccv-sim %llx for %08x",
                  (unsigned long long)r->seq, (unsigned long long)tgt, tmask,
                  (unsigned long long)r->target, r->taken);
      }
      epoch_ = unsigned(get(m.payload, c.ooe_fet, "fetch_epoch"));
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
    // Warp 0 is tier-1 stream 0: binding group 0, slots 0 and 1, in order.
    for (unsigned s = 0; s != 2 && launched_ && next_ != recs.size(); ++s) {
      const Record &r = recs[next_];
      bool ready = true;
      for (uint64_t a = r.pc / kLine * kLine; a < r.pc + r.size; a += kLine)
        if (!line_.count(a)) { ready = false; want(a); }
      if (!ready || !can(c.fet_dec, s)) break;
      uint64_t word = 0;
      for (unsigned b = 0; b != r.size; ++b) {
        const uint64_t a = r.pc + b;
        word |= uint64_t(line_[a / kLine * kLine][a % kLine]) << (8 * b);
      }
      if (k_.brk == "corrupt-fetch" && r.seq == 5) word ^= 0x100;
      Bits f = msgOf(c.fet_dec);
      put(f, c.fet_dec, "warp_id", 0);
      put(f, c.fet_dec, "tier1_id", s / kChans[c.fet_dec].bind_group);
      put(f, c.fet_dec, "pc", r.pc);
      put(f, c.fet_dec, "instr", word);
      put(f, c.fet_dec, "length", r.size / 2 - 1);
      send(c.fet_dec, s, f, instrUid(r.seq));
      ++next_;
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
      // ccv_outstanding_checker. itlb-double breaks it on purpose, by also
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
    return (launched_ && next_ != k_.orc.recs.size()) || !itlb_wait_.empty() ||
           !ifill_wait_.empty() || !fills_.empty() || !itlbs_.empty();
  }
};

// ---- RAU: launches the one warp -------------------------------------------------------

class Rau : public Stub {
public:
  using Stub::Stub;
  const char *kind() const override { return "rau"; }

private:
  bool launch_ = false, alloc_ = false, cta_ = false;

  void work() override {
    const Ch &c = ch();
    const uint64_t none = makeUid(IdClass::kNone, 0);
    if (!alloc_ && can(c.rau_ooe, 0)) {
      Bits a = msgOf(c.rau_ooe);
      put(a, c.rau_ooe, "warp_id", 0);
      put(a, c.rau_ooe, "prf_base", 0);
      put(a, c.rau_ooe, "prf_size", kArchGprs);
      put(a, c.rau_ooe, "activate_or_free", 1);
      // Identity from RAU's warp-to-CTA table: one warp, warp 0 of its CTA.
      put(a, c.rau_ooe, "ctaid", k_.orc.ctaid + (k_.brk == "corrupt-ctaid" ? 1u : 0u));
      put(a, c.rau_ooe, "warp_in_cta", 0);
      send(c.rau_ooe, 0, a, none);
      alloc_ = true;
    }
    if (!cta_ && can(c.rau_miu, 0)) {
      Bits a = msgOf(c.rau_miu);
      put(a, c.rau_miu, "cta_slot", 0);
      send(c.rau_miu, 0, a, none);
      cta_ = true;
    }
    // Launch last, a cycle after the allocation, so the warp's registers
    // exist before its first instruction can reach them.
    if (alloc_ && cta_ && !launch_ && can(c.rau_fet, 0)) {
      Bits l = msgOf(c.rau_fet);
      put(l, c.rau_fet, "warp_id", 0);
      put(l, c.rau_fet, "start_pc", k_.orc.code_base);
      // code_bounds: [63:0] base, [103:64] length (placeholder split).
      const FieldDesc &cb = field(c.rau_fet, "code_bounds");
      l.set(cb.lsb, 64, k_.orc.code_base);
      l.set(cb.lsb + 64, cb.width - 64, k_.orc.code.size());
      send(c.rau_fet, 0, l, none);
      launch_ = true;
    }
  }
  bool busy() const override { return !launch_; }
};

/// SPM, SYU, PCA, CRU: nothing on vadd's path.
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
  case Blk::OOE:  return std::make_unique<Ooe>(inst, k);
  case Blk::RCU:  return std::make_unique<Rcu>(inst, k);
  case Blk::LANE: return std::make_unique<Lane>(inst, k);
  case Blk::MIU:  return std::make_unique<Miu>(inst, k);
  case Blk::DCU:  return std::make_unique<Dcu>(inst, k);
  case Blk::MLC:  return std::make_unique<Mlc>(inst, k);
  case Blk::EXB:  return std::make_unique<Exb>(inst, k);
  case Blk::RAU:  return std::make_unique<Rau>(inst, k);
  default:
    return std::make_unique<Idle>(inst, k, blkName(kBlkInsts[inst].type));
  }
}

KernelReport compareFinal(Kernel &k) {
  KernelReport r;
  const Oracle &o = k.orc;
  for (unsigned a = 0; a != kArchGprs; ++a)
    for (unsigned l = 0; l != kLanes; ++l)
      if (k.gpr[k.prf_base + a][l] != o.final_gpr[a][l]) {
        if (r.gpr_mismatch++ < 4)
          std::fprintf(stderr, "FINAL R%u lane %u: machine %08x, ccv-sim %08x\n",
                       a, l, k.gpr[k.prf_base + a][l], o.final_gpr[a][l]);
      }
  for (unsigned p = 0; p != kArchPreds; ++p)
    if (k.pred[physPred(0, p)] != o.final_pred[p]) {
      ++r.pred_mismatch;
      std::fprintf(stderr, "FINAL P%u: machine %08x, ccv-sim %08x\n", p,
                   k.pred[physPred(0, p)], o.final_pred[p]);
    }
  for (auto &w : o.final_mem) {
    uint32_t v = 0;
    for (unsigned b = 0; b != 4; ++b) {
      auto it = k.mem.find(w.first + b);
      v |= uint32_t(it == k.mem.end() ? 0 : it->second) << (8 * b);
    }
    if (v != w.second && r.mem_mismatch++ < 4)
      std::fprintf(stderr, "FINAL [%llx]: machine %08x, ccv-sim %08x\n",
                   (unsigned long long)w.first, v, w.second);
  }
  r.order_ok = k.retired == o.issue_groups;
  for (size_t i = 0; i != k.retire_order.size(); ++i)
    r.order_ok = r.order_ok && k.retire_order[i] == i;
  for (unsigned c = 0; c != kNumChans; ++c) {
    if (k.rx_per_chan[c]) ++r.channels_used;
    else r.unused += std::string(r.unused.empty() ? "" : " ") + kChans[c].name;
  }
  return r;
}

} // namespace skel
} // namespace ccv
