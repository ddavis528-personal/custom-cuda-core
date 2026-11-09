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
           rau_ooe = chanId("ccv_rau_ooe_alloc"), rau_miu = chanId("ccv_rau_miu_cta"),
           // Notices (OA-23): each promises its partner's valid on the same
           // slot a fixed lead after the notice lands.
           fill_ntc = chanId("ccv_dcu_miu_fill_ntc"), cmpl_hint = chanId("ccv_miu_ooe_cmpl_hint"),
           // Demotion and migration (TI-24).
           ooe_status = chanId("ccv_ooe_rau_status"), rau_demote = chanId("ccv_rau_ooe_demote"),
           ooe_drained = chanId("ccv_ooe_rau_drained"), ooe_map = chanId("ccv_ooe_rcu_map"),
           rau_rcu_mig = chanId("ccv_rau_rcu_mig"), rau_fet_mig = chanId("ccv_rau_fet_mig"),
           rcu_pca = chanId("ccv_rcu_pca_mig"), fet_pca = chanId("ccv_fet_pca_mig"),
           pca_done = chanId("ccv_pca_rau_mig_done"), rau_pca_mig = chanId("ccv_rau_pca_mig"),
           pca_rcu = chanId("ccv_pca_rcu_mig"), pca_fet = chanId("ccv_pca_fet_mig"),
           // The replay drain (TI-21): a demoted warp's orphans are home.
           miu_ready = chanId("ccv_miu_rau_ready"),
           // Barriers (TI-40): SYU's inputs and its three answers.
           rau_syu = chanId("ccv_rau_syu_alloc"), ooe_syu = chanId("ccv_ooe_syu_bar"),
           syu_ooe = chanId("ccv_syu_ooe_rel"), syu_fet = chanId("ccv_syu_fet_rel"),
           syu_rau = chanId("ccv_syu_rau_ready"),
           // .shared (TI's rev 230): MIU's passes to SPM and its answers.
           miu_spm = chanId("ccv_miu_spm_req"), spm_miu = chanId("ccv_spm_miu_rsp"),
           // TI-46 (b): decode-queue credits back to FET.
           ooe_cred = chanId("ccv_ooe_fet_decq_credit");
};
inline const Ch &ch() { static const Ch c; return c; }
/// ccv_ooe_syu_bar's bar_kind and ccv_rau_syu_alloc's syu_alloc_op (TI-40).
enum : unsigned { kBarArriveK = 0, kBarWaitK = 1, kBarWaitPhaseK = 2, kBarExitK = 3 };
enum : unsigned { kSyuFree = 0, kSyuAlloc = 1, kSyuDemote = 2, kSyuRestore = 3 };

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
// coh_op. Read and write (a writeback) as before; the acquires DCU's write
// policy needs (DCU spec rev 8): a line with ownership, or ownership alone
// for a store that writes the whole line (TL-C's AcquireBlock and
// AcquirePerm). The stub's codes until CCV_L_W_COH_OP's TL-C subset is
// enumerated.
enum : unsigned { kCohRead = 0, kCohWrite = 1, kCohAcquireData = 2, kCohAcquirePerm = 3 };
enum : unsigned { kStatusComplete = 0, kStatusFault = 1, kStatusReplay = 2 };   // miu_ooe_cmpl.status
enum : unsigned { kMemLoad = 0, kMemStore = 1, kMemPredLoad = 4, kMemPredStore = 5,   // ooe_miu_memop.mem_op
                  kMemAtomicRead = 2, kMemAtomicWrite = 3, // OOE's (AR-21, V-72)
                  kMemFence = 0xE, kMemBulkDiscard = 0xF };
enum : unsigned { kAllocFree = 0, kAllocLaunch = 1,      // rau_ooe_alloc.alloc_op
                  kAllocRestoreAlloc = 2, kAllocRestoreActivate = 3 };
enum : unsigned { kSpaceGlobal = 0, kSpaceShared = 1 }; // ooe_miu_memop.space
enum : unsigned { kFaultNone = 0, kFaultFetch = 1,          // CCV_W_FAULT_CAUSE (ISA §12)
                  kFaultIllegal = 2, kFaultAddr = 6, kFaultShared = 7, kFaultRo = 8 };
/// ccv_miu_spm_req's spm_op (CCV_L_W_SPM_OP, preliminary): a pass reads or
/// writes its banks' words under byte_mask.
enum : unsigned { kSpmRead = 0, kSpmWrite = 1 };
/// A completion's status on ccv_miu_ooe_cmpl: 0 complete, 1 fault, 2 replay.
enum : unsigned { kCmplDone = 0, kCmplFault = 1, kCmplReplay = 2 };
enum : unsigned { kSizeLine = 7 };                      // size: 2^7 bytes
// ---- the opcode table ---------------------------------------------------------
//
// The skeleton's decoder: an opcode per operation vadd uses, and the operand
// shape rename and register read need. Opcode values are skeleton-local
// (payload spec: opcode is 9 bits, preliminary) -- 0 is reserved.
// kFence orders the warp's memory ops at MIU (IS-11); kBarArrive and
// kBarWait are ISA v1.9's bar.arrive and bar.wait (O-27), reported to SYU
// at retire (TI-40).
// kAtomic: a Format M read-modify-write (O-72; IS-21, AR-21): two decode
// slots, a pair, which OOE splits into A1 (read), A2 (lane op), A3 (write).
// kNop: a hint with no architectural effect (C_RECONV, reconv.hint; RA-16
// (f), OA's rev 393), serial 5: OOE completes it at rename, and it runs
// nowhere.
enum UopClass : uint8_t { kAlu, kLoad, kStore, kBranch, kExit, kPredLogic, kImm,
                          kFence, kBarArrive, kBarWait, kAtomic, kNop };
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
  /// Moves data between lanes (shfl): RCU executes it beside the register
  /// file, which every lane's operand is in (Q-32), and sched_attr's
  /// cross_lane is set.
  bool cross = false;
  /// The bypass group, where the class's is not the op's: FP (OI-16).
  int8_t byp = -1;
  /// Format D's launch-slot mode (O-45): the immediate naming the launch
  /// slot whose window is the base, which no register holds (TI-31).
  int8_t slot_imm = -1;
  /// A predicate transfer (O-19; TI-36): mem_op 4 or 5, one uop per
  /// predicate of its mask, its address lane 0's base.
  bool pxfer = false;
  /// Format D's interleaved local mode (O-69; IS-19): no base register, the
  /// immediate an unsigned byte offset into the warp's spill frame, which
  /// MIU forms from the CTA's local_base and the warp's context.
  bool local = false;
  /// ccv-sim lists a guarded move's old destination first among its uses
  /// (mov.p); it is the merge (A-33), which rename supplies, not a source.
  bool old_dst_use = false;
  /// ccv-sim lists every register field the encoding names, read or not
  /// (cvt.sext's Format A form names rs1 and rs2): the first nsrc are the
  /// op's sources.
  bool unread_fields = false;
  /// chwidth (O-6): 1 the single form, `chwidth rd, width`, 2 the multi
  /// form, `chwidth.multi #regmask, width`, which DEC cracks into one
  /// chwidth uop per register of its mask (AR-24; OA's to settle as one
  /// uop). Each holds rename until it retires (serial = chwidth).
  uint8_t chw = 0;
  /// ret: its source is the link register, which ccv-sim's record does not
  /// list; the compressed form names it in imm[7:4] (Format K, opcode 53).
  bool ret = false;
  /// .shared (ISA section 5.1): space 1 on the memop, no window shift, and
  /// MIU sends it to SPM rather than DCU (TI's rev 230).
  bool shared = false;
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
inline bool execRcu(const OpInfo *op) { return inRcu(op->cls) || op->cross; }

// sched_attr on ccv_dec_ooe_uop (A-66): what OOE schedules on, decoded by DEC
// so OOE need not decode opcode. Layout MSB first, CCV_P_W_SCHED_ATTR bits:
// bypass_group[3], rs_miu, exec_rcu, cross_lane, writes_gpr, writes_pred,
// mem_kind[2], branch, serial[3], lat_class[3]. Preliminary codes (the schema
// owner's). serial 4, barrier arrive, and the 3-bit field: TI-41, OA's rev 198.
enum : unsigned { kMemKLoad = 0, kMemKStore = 1, kMemKAtomic = 2, kMemKFence = 3 };
enum : unsigned { kLatRcu = 0, kLatLane = 1, kLatL1 = 2, kLatCompletion = 3,
                  kLatSfu = 4, kLatCollective = 5 };
// serial 5, no-op: complete at rename (C_RECONV; RA-16 (f), OA's rev 393).
enum : unsigned { kSerNone = 0, kSerChwidth = 1, kSerBarrier = 2, kSerExit = 3, kSerArrive = 4,
                  kSerNop = 5 };
// Above bypass_group (CCV_P_W_SCHED_ATTR 21): the CAS pair's first and second
// slots (17, 18; TI-39, OA's rev 189), ret (19: OOE takes its target from
// ccv_rcu_ooe_done.aux and sets stay; AR-24 (b)), and commit_width
// (20: a chwidth.multi sibling commits its width without the hold, which
// sits on the last sibling; AR-24 (c), OA's rev 222).
enum : unsigned { kAttrPairFirstBit = 17, kAttrPairSecondBit = 18, kAttrRetBit = 19,
                  kAttrCommitWidthBit = 20 };
static_assert(kAttrCommitWidthBit < ccv::prelim::kPWSchedAttr, "sched_attr is too narrow for its bits");
// bypass_group (OI-16; Daniel's responses OA-4): which bypass penalties an
// op takes, as producer and as consumer, the codes of CCV_P_BYP_GROUPS.
enum : unsigned { kBypInt = 0, kBypFp = 1, kBypAddr = 2, kBypSfu = 3,
                  kBypCollective = 4, kBypPred = 5 };
/// An op's bypass group. S1's table has no FP, SFU or warp-collective op;
/// movi and movi48 are integer although RCU executes them, and a memop
/// consumes as address calculation. An op that writes no result and reads
/// no GPR (a branch, exit) takes 0, don't-care.
inline unsigned bypGroupOf(const OpInfo *op) {
  if (op->byp >= 0) return unsigned(op->byp);
  if (op->cross) return kBypCollective;
  switch (op->cls) {
  case kLoad: case kStore: case kAtomic: return kBypAddr;
  case kPredLogic: return kBypPred;
  default: return kBypInt;
  }
}
/// A barrier uop: like exit, OOE completes it without issue (TI-40).
inline bool isBarrier(const OpInfo *op) { return op->cls == kBarArrive || op->cls == kBarWait; }
inline uint32_t schedAttrOf(const OpInfo *op) {
  const bool mem = op->cls == kLoad || op->cls == kStore || op->cls == kFence || op->cls == kAtomic;
  const unsigned memk = op->cls == kStore ? kMemKStore : op->cls == kFence ? kMemKFence
                      : op->cls == kAtomic ? kMemKAtomic : kMemKLoad;
  const bool ctl = op->cls == kExit || isBarrier(op);
  const unsigned ser = op->cls == kExit ? kSerExit : op->cls == kBarWait ? kSerBarrier
                     : op->cls == kBarArrive ? kSerArrive : op->cls == kNop ? kSerNop
                     : op->chw ? kSerChwidth : kSerNone;
  // A cross-lane op (shfl) is RCU's but warp-collective: lat_class 5 at
  // CCV_LAT_COLLECTIVE (Daniel's responses OA-4; AR's rev 259, TI's rev
  // 274). RCU may finish it sooner, which V-35 allows; its dependants wake
  // at 5.
  // An atomic wakes its dependants on its last write's completion (A-46).
  // A no-op (serial 5) sets no other bit: lat_class 0 (RA-16 (f)).
  const unsigned lat = op->cls == kNop ? kLatRcu
                     : op->cls == kLoad ? kLatL1
                     : op->cls == kStore || op->cls == kFence || op->cls == kAtomic ? kLatCompletion
                     : op->cross ? kLatCollective
                     : execRcu(op) || ctl ? kLatRcu : kLatLane;
  return uint32_t(op->ret) << kAttrRetBit |
         uint32_t(bypGroupOf(op)) << 14 |
         uint32_t(mem) << 13 | uint32_t(execRcu(op) || ctl) << 12 |
         uint32_t(op->cross) << 11 | uint32_t(op->gdst) << 10 |
         uint32_t(op->pwrite) << 9 | (mem ? memk : 0u) << 7 |
         uint32_t(op->cls == kBranch) << 6 | ser << 3 |
         lat;
}
// The three fields DEC adds so OOE never decodes opcode (A-75, TI-1).
enum : unsigned { kPredUseNone = 0, kPredUseGuard = 1, kPredUseData = 2 };
enum : unsigned { kImmLiteral = 0, kImmPredSrcs = 1, kImmWarpBase = 2, kImmCtaid = 3, kImmLaneCtx = 4,
                  kImmPrivOff = 5, kImmCallLink = 6 };
/// A call (call, call.short): a branch that writes a GPR, its link (RA-18).
inline bool isCall(const OpInfo *op) { return op->cls == kBranch && op->gdst; }
/// Bit i: source i is a real read (src_arch's two fields, then src2_arch).
inline unsigned srcValidOf(const OpInfo *op) { return (1u << op->nsrc) - 1u; }
inline unsigned predUseOf(const OpInfo *op) {
  return op->guard ? kPredUseGuard : op->pdata ? kPredUseData : kPredUseNone;
}
/// A collective that reads a predicate source (vote.any, vote.all, ballot):
/// it rides in imm, renamed by OOE as predicate logic's (O-85; TI rev 284).
inline bool collPred(const OpInfo *op) {
  return op->cross && op->nsrc == 0;
}
inline unsigned immKindOf(const OpInfo *op) {
  return op->cls == kPredLogic || collPred(op) ? kImmPredSrcs
         : isCall(op)           ? kImmCallLink
         : op->srd_sel == 0     ? kImmWarpBase
         : op->srd_sel == 1     ? kImmCtaid
         : op->srd_sel == 2     ? kImmLaneCtx
         : op->srd_sel == 3     ? kImmPrivOff : kImmLiteral;
}
inline bool attrMem(uint32_t a) { return (a >> 13) & 1u; }
inline unsigned attrMemKind(uint32_t a) { return (a >> 7) & 3u; }
inline bool attrBranch(uint32_t a) { return (a >> 6) & 1u; }
inline unsigned attrBypGroup(uint32_t a) { return (a >> 14) & 7u; }
inline unsigned attrSerial(uint32_t a) { return (a >> 3) & 7u; }
/// A per-lane input: a GPR source, or the lane's own index.
inline bool perLaneInput(const OpInfo *op, const Record &r) {
  return !r.gprUses().empty() || op->srd_sel >= 0 || op->chw;
}
// The table itself is generated from params/ops.json (RI-21 (4)): a row
// per opcode, its opcode the row's position + 1, appended only.
#include "ccv_ops.h"
/// The copy-only op (A-38): the all-ones opcode, outside the table.
constexpr unsigned kOpCopy = ccv::prelim::kOpPrfCopy;

// Sectioned lanes (Daniel's responses OI-28 to OI-31; change doc "Interface
// spec changes -- sectioned lanes"). ccv_ooe_rcu_issue's slots are select
// resources: the lane sections S0-S3, the MIU pipes P0-P3, then R. An op
// sits in its footprint's lowest slot and marks the rest continuation.
constexpr unsigned kSecs = ccv::kSections;
constexpr unsigned kSlotS0 = 0, kSlotP0 = kSecs, kSlotR = kSecs + ccv::kMiuPipes;
static_assert(kSlotR + 1 == ccv::kIssueResources, "S0-S3, P0-P3, R");
static_assert(kSlotR == ccv::kIssueSlotR, "R's slot (CCV_ISSUE_SLOT_R)");
/// ccv_ooe_rcu_issue's lead (RA-31; OA's rev 307, AR's rev 267; RA's revs
/// 108-113, RA-43, OA's revs 387-391): what OOE knows at select from the RS
/// entry's static fields, opcode-blind, sent a cycle ahead so RCU's end can
/// be zero-cycle. Three kinds (schema lead_why):
///  - ENABLES, a superset each: lead_src_used, lead_imm_used,
///    lead_merge_used, lead_guard_used. A clear bit is a promise.
///    lead_sec_mask is EXACT (OA's rev 403 on RI-31): the footprint, bit for
///    bit, on a lead's slot, and zero on a continuation. lead-sec-superset
///    sets a section beyond the footprint on every lead that leaves one
///    (R's, footprint 0), which RCU must refuse (legal before rev 403);
///    lead-sec-cont sets one on every continuation (fillIssueLeadCopies).
///    lead-src-clear promises no source on every op: RCU must refuse each op
///    that reads one.
///  - MOVED (no payload copy left): lead_guard_pred on every slot, the op's
///    guard or data predicate (RA 109 (a)); lead_phys_src and
///    lead_phys_src2 on R, R's source rows (RA 109 (b); placeIssueSrcRows;
///    on S0-S3 both are copies, lead_phys_src2's since RA's rev 132 and OA's
///    rev 403 on RI-31),
///    and lead_rpsrc on R, R's whole imm (RA's rev 114 (2); issueImm).
///    RCU reads them from the lead (issueGuardPred, issueSrcRows).
///  - COPIES, equal to their payload field (kIssueLeadCopies).
///    A sender calls finishIssueLeads last on every slot, continuations too.
/// putIssueLead sets the enables and the guard: guard_used is set when the
/// op reads its predicate, as guard or data, and it is not the always-true
/// one; guard_pred is the predicate whatever guard_used says.
inline void putIssueLead(Bits &m, unsigned chan, unsigned /*slot*/, unsigned fp, unsigned src_used,
                         bool imm_used, bool merge, bool guard_used, unsigned guard_pred,
                         const std::string &brk) {
  // lead-sec-superset: the lowest section outside the footprint, on every
  // lead that leaves one (R's, whose footprint is 0, and a narrow op's).
  const unsigned out = ~fp & 0xFu;
  put(m, chan, "lead_sec_mask", fp | (brk == "lead-sec-superset" ? out & (0u - out) : 0u));
  put(m, chan, "lead_src_used", brk == "lead-src-clear" ? 0u : src_used & 7u);
  put(m, chan, "lead_imm_used", imm_used);
  put(m, chan, "lead_merge_used", merge);
  put(m, chan, "lead_guard_used", guard_used);
  // lead-guard-corrupt (RA 109 (a)): a moved lead names the wrong
  // predicate on a guarded op. No payload copy is left to compare, so RCU
  // reads the wrong guard, and the result must be wrong.
  const unsigned gp = brk == "lead-guard-corrupt" && guard_used ? guard_pred ^ 1u : guard_pred;
  put(m, chan, "lead_guard_pred", gp);
}
/// The source rows: in the payload on S0-S3 and P0-P3, in the lead on R
/// (moved) and on S0-S3 (a copy). A sender puts phys_src and phys_src2 as
/// ever; on a slot that does not carry them (R) this moves them to the lead
/// and clears the payload's. lead-src-corrupt (RA 109 (b)) names a wrong
/// first-source row in R's moved lead.
inline void placeIssueSrcRows(Bits &m, unsigned chan, unsigned slot, const std::string &brk) {
  if ((field(chan, "phys_src").slots >> slot) & 1u) return;   // a copy, if any: fillIssueLeadCopies
  const uint64_t ps = get(m, chan, "phys_src"), ps2 = get(m, chan, "phys_src2");
  put(m, chan, "phys_src", 0);
  put(m, chan, "phys_src2", 0);
  if (!((field(chan, "lead_phys_src").slots >> slot) & 1u)) return;
  put(m, chan, "lead_phys_src", brk == "lead-src-corrupt" ? ps ^ (1u << ccv::prov::kWPhysReg) : ps);
  put(m, chan, "lead_phys_src2", ps2);
  // R's imm moves to lead_rpsrc too (RA's rev 114 (2)).
  if ((field(chan, "lead_rpsrc").slots >> slot) & 1u && !((field(chan, "imm").slots >> slot) & 1u)) {
    put(m, chan, "lead_rpsrc", get(m, chan, "imm"));
    put(m, chan, "imm", 0);
  }
}
/// The immediate as RCU reads it: the payload's where it carries one, R's
/// moved lead_rpsrc on R (RA's rev 114 (2)).
inline uint32_t issueImm(const Bits &m, unsigned chan, unsigned slot) {
  return uint32_t(get(m, chan, (field(chan, "imm").slots >> slot) & 1u ? "imm" : "lead_rpsrc"));
}
/// The lead copies (RA-43, RA 109 (c)): each lead field and the payload
/// field it mirrors. A copy is filled only on a slot that carries both.
struct IssueLeadCopy { const char *lead, *field; };
inline constexpr IssueLeadCopy kIssueLeadCopies[] = {
    {"lead_opcode", "opcode"},           {"lead_phys_dst", "phys_dst"},
    {"lead_dst_pos", "dst_pos"},         {"lead_dst_width", "dst_width"},
    {"lead_done_row", "done_row"},       {"lead_pred_we", "pred_we"},
    {"lead_phys_pred_dst", "phys_pred_dst"}, {"lead_cont", "cont"},
    {"lead_pred_neg", "pred_neg"},       {"lead_phys_src", "phys_src"},
    {"lead_phys_old_dst", "phys_old_dst"}, {"lead_old_dst_pos", "old_dst_pos"},
    {"lead_src_pos", "src_pos"},         {"lead_phys_src2", "phys_src2"},
};
inline bool issueCopyOn(unsigned chan, const IssueLeadCopy &x, unsigned slot) {
  return (field(chan, x.lead).slots >> slot) & (field(chan, x.field).slots >> slot) & 1u;
}
/// Fill every copy from the payload as built: call it last, on a lead's slot
/// and on each continuation alike. lead-copy-corrupt (the control) flips a
/// bit of lead_phys_dst on every slot that is not a continuation, which the
/// receiving RCU must refuse by name.
inline void fillIssueLeadCopies(Bits &m, unsigned chan, unsigned slot, const std::string &brk) {
  for (const IssueLeadCopy &x : kIssueLeadCopies)
    if (issueCopyOn(chan, x, slot)) put(m, chan, x.lead, get(m, chan, x.field));
  if (brk == "lead-copy-corrupt" && !get(m, chan, "cont"))
    put(m, chan, "lead_phys_dst", get(m, chan, "lead_phys_dst") ^ 1u);
  // lead-src2-copy (RA's rev 132, OA's rev 403 on RI-31): S0's
  // lead_phys_src2 copy off by one bit on every lead there.
  if (brk == "lead-src2-copy" && slot == 0 && !get(m, chan, "cont"))
    put(m, chan, "lead_phys_src2", get(m, chan, "lead_phys_src2") ^ 1u);
  // lead-sec-cont (OA's rev 403): a continuation's section mask set.
  if (brk == "lead-sec-cont" && get(m, chan, "cont"))
    put(m, chan, "lead_sec_mask", 1u << (slot % kSecs));
}
/// What a sender does last on each ccv_ooe_rcu_issue slot, once it knows the
/// slot: R's source rows to their lead, then every copy (RA-43).
inline void finishIssueLeads(Bits &m, unsigned chan, unsigned slot, const std::string &brk) {
  placeIssueSrcRows(m, chan, slot, brk);
  fillIssueLeadCopies(m, chan, slot, brk);
}
/// The first copy on this slot that differs from its payload field, or null.
inline const IssueLeadCopy *issueLeadCopyBroken(const Bits &m, unsigned chan, unsigned slot) {
  for (const IssueLeadCopy &x : kIssueLeadCopies)
    if (issueCopyOn(chan, x, slot) && get(m, chan, x.lead) != get(m, chan, x.field)) return &x;
  return nullptr;
}
/// The moved fields, as RCU reads them: the guard's predicate from the lead
/// on every slot, the source rows from the payload where it carries them
/// and from the lead on R.
inline unsigned issueGuardPred(const Bits &m, unsigned chan) {
  return unsigned(get(m, chan, "lead_guard_pred"));
}
inline void issueSrcRows(const Bits &m, unsigned chan, unsigned slot, unsigned src[3]) {
  const bool pl = (field(chan, "phys_src").slots >> slot) & 1u;
  const unsigned ps = unsigned(get(m, chan, pl ? "phys_src" : "lead_phys_src"));
  src[0] = (ps >> ccv::prov::kWPhysReg) & ((1u << ccv::prov::kWPhysReg) - 1u);
  src[1] = ps & ((1u << ccv::prov::kWPhysReg) - 1u);
  src[2] = unsigned(get(m, chan, pl ? "phys_src2" : "lead_phys_src2"));
}
/// chwidth's codes, and the sections (or pipes) a register of each spans.
enum : unsigned { kChw32 = 0, kChw16 = 1, kChw8 = 2, kChw4 = 3 };
inline unsigned spanOf(unsigned chw) { return chw == kChw32 ? 4u : chw == kChw16 ? 2u : 1u; }
/// A width code's element bits: what a register of that width holds. A
/// narrow write zero-extends to the row (O-38), and a value is compared
/// with ccv-sim's only within it, since ccv-sim keeps the slice's old bits.
inline uint32_t elemMask(unsigned chw) { return chw == kChw32 ? ~0u : (1u << (32u >> chw)) - 1u; }
/// The footprint mask of a register at a position: its span from there.
inline unsigned maskOf(unsigned chw, unsigned pos) { return ((1u << spanOf(chw)) - 1u) << pos; }

constexpr unsigned kNumOps = sizeof kOps / sizeof kOps[0];
/// An atomic's three steps as RCU reads them (AR-21; IS-21), told apart by
/// the issue's done_row (OI-85: 0 A1, 2 A2, 3 A3), since OOE sends each
/// under the atomic's own opcode. A1 reads the address, rbase and rindex,
/// into T like a load; A2 is the lane op, T and rs into N, under the
/// atomic's opcode; A3 sends N, the write's data, like a store's. Not in
/// kOps: never an opcode of their own.
inline constexpr OpInfo kAtomA1 = {"ATOM.A1", kLoad,  2, true,  false, false, false, false,  0,  1, -1, -1, -1, -1, -1};
inline constexpr OpInfo kAtomA2 = {"ATOM.A2", kAlu,   2, true,  false, false, false, false, -1, -1, -1, -1, -1, -1, -1};
inline constexpr OpInfo kAtomA3 = {"ATOM.A3", kStore, 1, false, false, false, false, false, -1, -1,  0, -1, -1, -1, -1};
/// A CAS (OI-127, OA rev 380): its steps are guarded by its qualifier, and
/// A2 reads T, rs_cmp and rs_swap, and writes N and pd, merging pd's
/// inactive lanes from its old name (A-43).
inline constexpr OpInfo kCasA1 = {"CAS.A1", kLoad,  2, true,  true,  false, true,  false,  0,  1, -1, -1, -1, -1, -1};
inline constexpr OpInfo kCasA2 = {"CAS.A2", kAlu,   3, true,  true,  true,  true,  false, -1, -1, -1, -1, -1, -1, -1};
inline constexpr OpInfo kCasA3 = {"CAS.A3", kStore, 1, false, true,  false, true,  false, -1, -1,  0, -1, -1, -1, -1};
/// A Format M compare-and-swap (CAS_G, CAS_S).
inline bool isCas(const OpInfo *op) { return op && !std::strncmp(op->name, "CAS_", 4); }
/// The step's shape; `op`, the atomic's own row, picks a CAS's.
inline const OpInfo *atomStep(unsigned row, const OpInfo *op = nullptr) {
  if (isCas(op)) return row == 0 ? &kCasA1 : row == 2 ? &kCasA2 : row == 3 ? &kCasA3 : nullptr;
  return row == 0 ? &kAtomA1 : row == 2 ? &kAtomA2 : row == 3 ? &kAtomA3 : nullptr;
}
static_assert(kOpCopy > kNumOps, "the copy-only op's code collides with the table");
inline unsigned opcodeOf(const OpInfo *o) { return unsigned(o - kOps) + 1; }
/// O-80: a sized form's transfer, as xfer_size codes it (1 a byte, 2 a
/// halfword), and whether its load sign-extends; 0 and false otherwise.
inline unsigned xferOf(const OpInfo *op) {
  const std::string n = op->name;
  if (n.rfind("SZ_", 0) != 0) return 0;
  return n.find("16") != std::string::npos ? 2u : 1u;
}
inline bool xferSigned(const OpInfo *op) {
  const std::string n = op->name;
  return n.rfind("SZ_", 0) == 0 && n.find("_LD_S") != std::string::npos;
}

/// An add (+1) or subtract (-1) the lane stub computes itself when its
/// destination is narrow, to wrap it at the width (AR-24); 0 otherwise.
inline int arithSign(const OpInfo *op) {
  for (const char *n : {"ADD", "C_ADD", "ADDI", "C_ADDI"})
    if (!std::strcmp(op->name, n)) return 1;
  for (const char *n : {"SUB", "C_SUB"})
    if (!std::strcmp(op->name, n)) return -1;
  return 0;
}
inline const OpInfo *opByName(const std::string &n) {
  for (const OpInfo &o : kOps) if (n == o.name) return &o;
  return nullptr;
}
/// The registers an instruction's sources name, in src_arch order, from
/// its record's GPR uses (AR-24): ccv-sim folds a repeated source into one
/// use (mul.lo R9, R9), lists a guarded move's old destination, and lists
/// register fields an op does not read. chwidth's source is the register
/// it sets (uop k of chwidth.multi: the mask's k-th register), and ret's
/// the link register its immediate names. Empty with ok = false when the
/// record cannot be made to fit the row.
inline std::vector<unsigned> srcRegs(const OpInfo *op, const Record &r, unsigned sub, bool &ok) {
  std::vector<unsigned> g;
  if (op->cls == kAtomic) {
    // Format M (O-72): rbase [18:15], rs [22:19], rindex [26:23], from the
    // encoding, since the record lists a register once however often it is
    // named (an atomic on .shared with rbase = rindex = R0).
    uint32_t w = 0;
    for (unsigned b = 0; b != 4 && b < r.bytes.size(); ++b) w |= uint32_t(r.bytes[b]) << (8 * b);
    // CAS (Format M', 48 bits): rs_cmp [22:19], rs_swap [26:23], rindex
    // [35:32]: {rbase, rindex, rs_cmp, rs_swap}.
    if (isCas(op)) {
      ok = r.bytes.size() >= 6;
      return {(w >> 15) & 15u, ok ? r.bytes[4] & 15u : 0u, (w >> 19) & 15u, (w >> 23) & 15u};
    }
    ok = r.bytes.size() >= 4;
    return {(w >> 15) & 15u, (w >> 23) & 15u, (w >> 19) & 15u};
  }
  for (const RegVal *u : r.gprUses()) g.push_back(u->idx);
  ok = true;
  if (op->chw == 1) {
    const RegVal *d = r.gprDef();
    g.assign(1, d ? d->idx : g.empty() ? 0u : g[0]);
    ok = d || r.gprUses().size() == 1;
    return g;
  }
  if (op->chw == 2) {
    g.assign(1, r.chwReg(sub));
    return g;
  }
  if (op->ret) {
    g.assign(1, r.imms.empty() ? 14u : unsigned(r.imms[0] >> 4) & 15u);
    return g;
  }
  const RegVal *d = r.gprDef();
  if (op->old_dst_use && d && g.size() > op->nsrc && g[0] == d->idx) g.erase(g.begin());
  if (op->unread_fields && g.size() > op->nsrc) g.resize(op->nsrc);
  // A folded repeat: the record names fewer registers than the op reads.
  if (op->cls == kAlu && !g.empty())
    while (g.size() < op->nsrc) g.push_back(g.back());
  ok = g.size() == op->nsrc;
  return g;
}
/// srd's opcode for a selector, or null: 4-15 are unallocated (O-83 took 3).
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
    killIn();
    work();
    killOut();
    // Every sender is clocked exactly once a cycle, launching or not.
    for (size_t j = 0; j != outs.size(); ++j) {
      Pend &p = pend_[j];
      outs[j].tx->cycle(p.go, p.msg, p.tid);
      if (p.go) logLaunch(uint16_t(outs[j].ci->chan), p.msg, p.tid);
      p.go = false;
    }
    if (busy() || kill_pending_) ++k_.busy;
    // A message left in a receiver is one this stub does not handle. The
    // bank's response_within_n will report it; say which, once. A channel
    // the stub holds back on purpose (holdsBack) is its credit backpressure,
    // bounded by that same check, not a message it cannot handle.
    for (const In &i : ins)
      if (!i.rx->empty() && !holds_.count(i.ci->chan) && unhandled_.insert(i.ci->chan).second)
        k_.fail("%s: nothing consumes %s", kind(), kChans[i.ci->chan].name);
  }

protected:
  virtual void work() = 0;
  virtual bool busy() const { return false; }
  virtual const char *kind() const = 0;
  /// The kill (V-24; schema kill_valid): a block that owns warp state drops
  /// the killed warps' when the mask arrives, and acks once quiesced -- it
  /// holds nothing for them and has nothing in flight on their behalf.
  /// onKill runs before work() on the mask's cycle; killQuiet is asked
  /// after work() every cycle until it holds. By default a block is quiet
  /// when it is not busy, exact for a context-wide kill (a fatal fault
  /// kills every warp of the context, IS-2), which is the only one yet.
  virtual void onKill(uint32_t /*mask*/, unsigned /*epoch*/) {}
  virtual bool killQuiet(uint32_t /*mask*/) const { return !busy(); }

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
    // slot_fields (OA's response OI-93): a field defined on other slots
    // only is zero here, or a link that drops it there would lose it.
    const ChanDesc &cd = kChans[chan];
    for (unsigned f = 0; f != cd.nfields; ++f) {
      const FieldDesc &fd = cd.fields[f];
      if ((fd.slots >> slot) & 1u) continue;
      for (uint32_t b = 0; b < fd.width; b += 64)
        if (msg.get(fd.lsb + b, fd.width - b < 64 ? fd.width - b : 64)) {
          k_.fail("%s: %s is set on slot %u; it is defined only on slots %#x (slot_fields)",
                  cd.name, fd.name, slot, unsigned(fd.slots));
          break;
        }
    }
    pend_[j] = {true, msg, tid};
  }
  /// The credits a slot holds now: a sender that promises a message for a
  /// later cycle (a notice's partner, OA-23) keeps one back for it.
  unsigned credits(unsigned chan, unsigned slot, unsigned inst = 0) {
    return outs[outIdx(chan, slot, inst)].tx->credits();
  }
  /// Every credit of a slot home: each message sent on it has been taken.
  bool allHome(unsigned chan, unsigned slot, unsigned inst = 0) {
    const int j = outIdx(chan, slot, inst);
    return !pend_[j].go && outs[j].tx->credits() == outs[j].tx->depth();
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
  /// A fabric (kFabs) as this block reads it, the value as the cycle
  /// starts: a broadcast's value, or at a gather's end source `from`'s copy
  /// (its index in the fabric's blks).
  uint64_t fabIn(const char *name, unsigned from = 0) const {
    const FabDesc &f = fab(name);
    const bool end = f.end == myType();
    if (f.kind == FabKind::BROADCAST ? !member(f) : !end || from >= f.nblks) {
      std::fprintf(stderr, "%s: reads fabric %s it does not take\n", kind(), name);
      std::abort();
    }
    return fab_cur[f.slot_base + (f.kind == FabKind::GATHER ? from : 0)];
  }
  /// Drive a fabric for the next cycle: a broadcast from its end, or this
  /// block's own copy of a gather. Undriven, it reads 0 next cycle.
  void fabOut(const char *name, uint64_t v) {
    const FabDesc &f = fab(name);
    unsigned at = 0;
    if (f.kind == FabKind::BROADCAST) {
      if (f.end != myType()) at = ~0u;
    } else {
      at = ~0u;
      for (unsigned i = 0; i != f.nblks; ++i)
        if (f.blks[i] == myType()) at = i;
    }
    if (at == ~0u) {
      std::fprintf(stderr, "%s: drives fabric %s it does not\n", kind(), name);
      std::abort();
    }
    fab_nxt[f.slot_base + at] = v & (f.width == 64 ? ~0ull : (1ull << f.width) - 1);
  }
  /// Whether this block takes part in a fabric: a broadcast's reader or a
  /// gather's source.
  bool member(const FabDesc &f) const {
    for (unsigned i = 0; i != f.nblks; ++i)
      if (f.blks[i] == myType()) return true;
    return false;
  }
  static const FabDesc &fab(const char *name) {
    for (const FabDesc &f : kFabs)
      if (!std::strcmp(f.name, name)) return f;
    std::fprintf(stderr, "no fabric %s\n", name);
    std::abort();
  }
  Blk myType() const { return inst() < 0 ? Blk::EXTERNAL : kBlkInsts[inst()].type; }

  /// The oldest message on a slot, left in place.
  const Receiver::Msg &peek(unsigned chan, unsigned slot, unsigned inst = 0) {
    return rx(chan, slot, inst).front();
  }
  /// Messages on `chan` may wait in their receiver while this stub cannot
  /// take them: its credit backpressure, as OOE's decode queue full is
  /// DEC's (OOE doc, Decode queue).
  void holdsBack(unsigned chan) { holds_.insert(chan); }
  const Record *rec(uint64_t tid, const char *where) {
    const Record *r = uidClass(tid) == IdClass::kNone
                          ? nullptr : k_.bySeq(uidSeq(tid));
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

  /// The kill broadcast leads its mask by a cycle (schema kill_valid): seen
  /// valid, the next cycle's mask and epoch are the kill's.
  void killIn() {
    if (!member(fab("kill_valid"))) return;
    if (kill_armed_) {
      kill_mask_ = uint32_t(fabIn("kill_warp_mask"));
      kill_epoch_ = unsigned(fabIn("kill_epoch"));
      kill_pending_ = true;
      kill_acking_ = false;
      onKill(kill_mask_, kill_epoch_);
    }
    kill_armed_ = fabIn("kill_valid") != 0;
  }
  /// The ack, a level with its epoch from quiescence until the next kill.
  /// withheld-ack: MIU never acks; stale-ack: FET acks the epoch before.
  void killOut() {
    if (!member(fab("kill_ack"))) return;
    if (kill_pending_ && killQuiet(kill_mask_) && !(k_.brk == "withheld-ack" && myType() == Blk::MIU)) {
      kill_pending_ = false;
      kill_acking_ = true;
    }
    if (kill_acking_) {
      const unsigned stale = k_.brk == "stale-ack" && myType() == Blk::FET ? 1u : 0u;
      fabOut("kill_ack", 1);
      fabOut("kill_ack_epoch", kill_epoch_ - stale);
    }
  }
  bool kill_armed_ = false, kill_pending_ = false, kill_acking_ = false;
  uint32_t kill_mask_ = 0;
  unsigned kill_epoch_ = 0;

  struct Pend { bool go = false; Bits msg; uint64_t tid = 0; };
  bool built_ = false;
  std::map<std::tuple<unsigned, unsigned, unsigned>, int> out_, in_;
  std::vector<Pend> pend_;
  std::set<unsigned> unhandled_;
  std::set<unsigned> holds_;          ///< channels held back on purpose (holdsBack)
};

/// A queued outbound message: slot, payload, identity.
struct Q { unsigned slot; Bits msg; uint64_t tid; };
/// RCU's dones on ccv_rcu_ooe_done name no slot when queued, only their class:
/// the RCU-only class's one slot (CCV_DONE_SLOT_RCU), or the pool of the rest
/// (OA's response OI-93). Not slot numbers.
enum : unsigned { kPoolDone = ~0u, kRcuOnlyDone = ~0u - 1 };
/// The class that completes on CCV_DONE_SLOT_RCU: what RCU executes alone at
/// CCV_LAT_RCU (a cross-lane op is RCU's too, but warp-collective).
inline bool rcuOnlyDone(const OpInfo *op) { return inRcu(op->cls) || isBarrier(op); }
/// R's GPR write (RA-16 (a), RA-29 (a); AR's rev 265): one write port, RW,
/// for every class R executes, because each writes at A+2: the RCU-only
/// class (movi, call's link) at CCV_LAT_RCU - 1, and the collectives early,
/// at the same cycle, though their dependants wake at CCV_LAT_COLLECTIVE
/// (V-35 allows it). params' pipe list counts RW once for both
/// (CCV_PRF_GPR_WRITE_PORTS), which holds only while this does. `coll_late`
/// is the control: collectives write at A + CCV_LAT_COLLECTIVE - 1 instead,
/// which the RCU stub must refuse.
constexpr unsigned kRWriteAt = ccv::prov::kLatRcu - 1;
static_assert(kRWriteAt == 2, "R writes at A+2 (RA-29 (a))");
inline unsigned rWriteAt(const OpInfo *op, bool coll_late) {
  return op->cross && coll_late ? ccv::prov::kLatCollective - 1 : kRWriteAt;
}

/// OOE's implementation behind the swap boundary: the S1 stub (ooe.cpp).
std::unique_ptr<Block> makeOoe(int inst, Kernel &k);

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_STUB_H
