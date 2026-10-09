//===-- stub.h - what every S1 functional stub shares --------*- C++ -*-===//
//
// Channel and field access by name, the S1 wire conventions, the skeleton's
// opcode table, and the Stub base: a Block that reads only its own receivers
// and writes only its own senders, with the testbench hooks a block model may
// use (Kernel: fail, hit/peak, brk, rec for oracle CHECKS only). Split out of
// kernel.cpp so a block model can live in its own file (ooe.cpp is the first)
// and replace its stub through makeKernelBlock without touching the others.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_STUB_H
#define CCV_SKEL_STUB_H

#include "kernel.h"

#include "ccv/event.h"
#include "ccv_params.h"
#include "exerciser.h"

#include <array>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <deque>
#include <map>
#include <memory>
#include <set>
#include <string>
#include <tuple>
#include <vector>

namespace ccv {
namespace skel {

// ---- channels and fields, by name --------------------------------------------

inline unsigned chanId(const char *n) {
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
           ooe_ret = chanId("ccv_ooe_miu_retire"), ooe_fet = chanId("ccv_ooe_fet_redirect"),
           ooe_free = chanId("ccv_ooe_fet_ckpt_free"), miu_dcu = chanId("ccv_miu_dcu_req"),
           dcu_miu = chanId("ccv_dcu_miu_rsp"), dcu_mlc = chanId("ccv_dcu_mlc_req"),
           mlc_dcu = chanId("ccv_mlc_dcu_rsp"), fet_mlc = chanId("ccv_fet_mlc_ifill"),
           mlc_fet = chanId("ccv_mlc_fet_ifill_rsp"), miu_fet = chanId("ccv_miu_fet_itlb"),
           fet_miu = chanId("ccv_fet_miu_itlb_req"), mlc_exb = chanId("ccv_mlc_exb_req"),
           exb_mlc = chanId("ccv_exb_mlc_rsp"), exb_ext = chanId("ccv_exb_ext_out"),
           ext_exb = chanId("ccv_ext_exb_in"), rau_fet = chanId("ccv_rau_fet_launch"),
           rau_ooe = chanId("ccv_rau_ooe_alloc"), rau_miu = chanId("ccv_rau_miu_cta");
};
inline const Ch &ch() { static const Ch c; return c; }

inline const FieldDesc &field(unsigned chan, const char *n) {
  const ChanDesc &cd = kChans[chan];
  for (unsigned f = 0; f != cd.nfields; ++f)
    if (!std::strcmp(cd.fields[f].name, n)) return cd.fields[f];
  std::fprintf(stderr, "kernel stubs: %s has no field %s\n", cd.name, n);
  std::abort();
}
inline uint64_t get(const Bits &b, unsigned chan, const char *f) {
  const FieldDesc &fd = field(chan, f);
  return b.get(fd.lsb, fd.width < 64 ? fd.width : 64);
}
inline void put(Bits &b, unsigned chan, const char *f, uint64_t v) {
  const FieldDesc &fd = field(chan, f);
  b.set(fd.lsb, fd.width < 64 ? fd.width : 64, v);
}
/// Per-lane 32-bit element L of a wide field: bits [32L+31 : 32L] of it.
inline uint32_t getLane(const Bits &b, unsigned chan, const char *f, unsigned l) {
  return uint32_t(b.get(field(chan, f).lsb + 32 * l, 32));
}
inline void putLane(Bits &b, unsigned chan, const char *f, unsigned l, uint32_t v) {
  b.set(field(chan, f).lsb + 32 * l, 32, v);
}
inline Bits msgOf(unsigned chan) { return Bits(kChans[chan].bits); }

constexpr unsigned kLine = 128;            // bytes: CCV_W_DATA / 8
using Line = std::array<uint8_t, kLine>;

inline void putLine(Bits &b, uint32_t lsb, const Line &l) {
  for (unsigned k = 0; k != kLine; ++k) b.set(lsb + 8 * k, 8, l[k]);
}
inline Line getLine(const Bits &b, uint32_t lsb) {
  Line l;
  for (unsigned k = 0; k != kLine; ++k) l[k] = uint8_t(b.get(lsb + 8 * k, 8));
  return l;
}

// ---- S1 wire conventions (docs/skeleton.md lists them) ------------------------
//
// Placeholders for encodings the payload spec leaves to the owning block.
enum : unsigned { kCohRead = 0, kCohWrite = 1 };        // coh_op
enum : unsigned { kMemLoad = 0, kMemStore = 1,          // ooe_miu_memop.mem_op
                  kMemBulkDiscard = 0xF };
enum : unsigned { kAllocFree = 0, kAllocLaunch = 1,      // rau_ooe_alloc.alloc_op
                  kAllocRestoreAlloc = 2, kAllocRestoreActivate = 3 };
enum : unsigned { kSpaceGlobal = 0, kSpaceShared = 1 }; // ooe_miu_memop.space
enum : unsigned { kSizeLine = 7 };                      // size: 2^7 bytes
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
inline bool inRcu(UopClass c) { return c == kPredLogic || c == kBranch || c == kImm; }

// sched_attr on ccv_dec_ooe_uop (A-66): what OOE schedules on, decoded by DEC
// so OOE need not decode opcode. Layout MSB first, CCV_P_W_SCHED_ATTR bits:
// bypass_group[3], rs_miu, exec_rcu, cross_lane, writes_gpr, writes_pred,
// mem_kind[2], branch, serial[2], lat_class[3]. Preliminary codes (the schema
// owner's).
enum : unsigned { kMemKLoad = 0, kMemKStore = 1, kMemKAtomic = 2, kMemKFence = 3 };
enum : unsigned { kLatRcu = 0, kLatLane = 1, kLatL1 = 2, kLatCompletion = 3,
                  kLatSfu = 4, kLatCollective = 5 };
enum : unsigned { kSerNone = 0, kSerChwidth = 1, kSerBarrier = 2, kSerExit = 3 };
// bypass_group (OI-16; Daniel's responses OA-4): which bypass penalties an
// op takes, as producer and as consumer, the codes of CCV_P_BYP_GROUPS.
enum : unsigned { kBypInt = 0, kBypFp = 1, kBypAddr = 2, kBypSfu = 3,
                  kBypCollective = 4, kBypPred = 5 };
/// An op's bypass group. S1's table has no FP, SFU or warp-collective op;
/// movi and movi48 are integer although RCU executes them, and a memop
/// consumes as address calculation. An op that writes no result and reads
/// no GPR (a branch, exit) takes 0, don't-care.
inline unsigned bypGroupOf(const OpInfo *op) {
  switch (op->cls) {
  case kLoad: case kStore: return kBypAddr;
  case kPredLogic: return kBypPred;
  default: return kBypInt;
  }
}
inline uint32_t schedAttrOf(const OpInfo *op) {
  const bool mem = op->cls == kLoad || op->cls == kStore;
  const unsigned memk = op->cls == kStore ? kMemKStore : kMemKLoad;
  const unsigned lat = op->cls == kLoad ? kLatL1 : op->cls == kStore ? kLatCompletion
                     : inRcu(op->cls) || op->cls == kExit ? kLatRcu : kLatLane;
  return uint32_t(bypGroupOf(op)) << 13 |
         uint32_t(mem) << 12 | uint32_t(inRcu(op->cls) || op->cls == kExit) << 11 |
         0u << 10 /* no S1 op is cross-lane */ | uint32_t(op->gdst) << 9 |
         uint32_t(op->pwrite) << 8 | (mem ? memk : 0u) << 6 |
         uint32_t(op->cls == kBranch) << 5 | uint32_t(op->cls == kExit ? kSerExit : 0) << 3 |
         lat;
}
// The three fields DEC adds so OOE never decodes opcode (A-75, TI-1).
enum : unsigned { kPredUseNone = 0, kPredUseGuard = 1, kPredUseData = 2 };
enum : unsigned { kImmLiteral = 0, kImmPredSrcs = 1, kImmWarpBase = 2, kImmCtaid = 3 };
/// Bit i: source i is a real read (src_arch's two fields, then src2_arch).
inline unsigned srcValidOf(const OpInfo *op) { return (1u << op->nsrc) - 1u; }
inline unsigned predUseOf(const OpInfo *op) {
  return op->guard ? kPredUseGuard : op->pdata ? kPredUseData : kPredUseNone;
}
inline unsigned immKindOf(const OpInfo *op) {
  return op->cls == kPredLogic ? kImmPredSrcs
         : op->srd_sel == 0     ? kImmWarpBase
         : op->srd_sel == 1     ? kImmCtaid : kImmLiteral;
}
inline bool attrMem(uint32_t a) { return (a >> 12) & 1u; }
inline unsigned attrMemKind(uint32_t a) { return (a >> 6) & 3u; }
inline bool attrBranch(uint32_t a) { return (a >> 5) & 1u; }
inline unsigned attrBypGroup(uint32_t a) { return (a >> 13) & 7u; }
/// A per-lane input: a GPR source, or the lane's own index.
inline bool perLaneInput(const OpInfo *op, const Record &r) {
  return !r.gprUses().empty() || op->srd_sel >= 0;
}
inline constexpr OpInfo kOps[] = {
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
  // add under a guard (Format Ap): the guard switches lanes off, and they
  // keep the destination's old value, carried as merge_data (A-33, A-44).
  {"ADD_P",         kAlu,       2, true,  true,  false, true,  false, -1, -1, -1, -1, -1, -1, -1},
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
  // A guarded load (Format Dp): MIU writes the active lanes, and the inactive
  // ones keep their old value through a copy-only op (A-33, A-38).
  {"LD_GLOBAL_P",   kLoad,      1, true,  true,  false, true,  false,  0, -1, -1,  0, -1, -1, -1},
};
/// The copy-only op (A-38): the all-ones opcode, outside the table.
constexpr unsigned kOpCopy = ccv::prelim::kOpPrfCopy;

// Sectioned lanes (Daniel's responses OI-28 to OI-31; change doc "Interface
// spec changes -- sectioned lanes"). ccv_ooe_rcu_issue's slots are select
// resources: the lane sections S0-S3, the MIU pipes P0-P3, then R. An op
// sits in its footprint's lowest slot and marks the rest continuation.
constexpr unsigned kSecs = ccv::kSections;
constexpr unsigned kSlotS0 = 0, kSlotP0 = kSecs, kSlotR = kSecs + ccv::kMiuPipes;
static_assert(kSlotR + 1 == ccv::kIssueResources, "S0-S3, P0-P3, R");
/// chwidth's codes, and the sections (or pipes) a register of each spans.
enum : unsigned { kChw32 = 0, kChw16 = 1, kChw8 = 2, kChw4 = 3 };
inline unsigned spanOf(unsigned chw) { return chw == kChw32 ? 4u : chw == kChw16 ? 2u : 1u; }
/// The footprint mask of a register at a position: its span from there.
inline unsigned maskOf(unsigned chw, unsigned pos) { return ((1u << spanOf(chw)) - 1u) << pos; }

constexpr unsigned kNumOps = sizeof kOps / sizeof kOps[0];
static_assert(kOpCopy > kNumOps, "the copy-only op's code collides with the table");
inline unsigned opcodeOf(const OpInfo *o) { return unsigned(o - kOps) + 1; }
inline const OpInfo *opByName(const std::string &n) {
  for (const OpInfo &o : kOps) if (n == o.name) return &o;
  return nullptr;
}
/// srd's opcode for a selector, or null: 2-15 are unallocated.
inline const OpInfo *srdBySel(int64_t sel) {
  for (const OpInfo &o : kOps) if (o.srd_sel >= 0 && o.srd_sel == sel) return &o;
  return nullptr;
}
inline const OpInfo *opByCode(unsigned c) {
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

inline uint64_t instrUid(uint64_t seq) { return makeUid(IdClass::kInstr, uint32_t(seq)); }
inline uint32_t g_unowned_txn = 0;   ///< sequence for transactions no instruction owns

inline void emit(uint64_t now, uint64_t uid, EventId id, Unit u, uint32_t a = 0,
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

/// OOE's implementation behind the swap boundary: the S1 stub (ooe.cpp).
std::unique_ptr<Block> makeOoe(int inst, Kernel &k);

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_STUB_H
