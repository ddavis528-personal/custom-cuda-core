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
           miu_ready = chanId("ccv_miu_rau_ready");
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
                  kFaultIllegal = 2, kFaultRo = 8 };
/// A completion's status on ccv_miu_ooe_cmpl: 0 complete, 1 fault, 2 replay.
enum : unsigned { kCmplDone = 0, kCmplFault = 1, kCmplReplay = 2 };
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
enum : unsigned { kSerNone = 0, kSerChwidth = 1, kSerBarrier = 2, kSerExit = 3, kSerArrive = 4 };
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
  case kLoad: case kStore: return kBypAddr;
  case kPredLogic: return kBypPred;
  default: return kBypInt;
  }
}
inline uint32_t schedAttrOf(const OpInfo *op) {
  const bool mem = op->cls == kLoad || op->cls == kStore;
  const unsigned memk = op->cls == kStore ? kMemKStore : kMemKLoad;
  const unsigned lat = op->cls == kLoad ? kLatL1 : op->cls == kStore ? kLatCompletion
                     : execRcu(op) || op->cls == kExit ? kLatRcu : kLatLane;
  return uint32_t(bypGroupOf(op)) << 14 |
         uint32_t(mem) << 13 | uint32_t(execRcu(op) || op->cls == kExit) << 12 |
         uint32_t(op->cross) << 11 | uint32_t(op->gdst) << 10 |
         uint32_t(op->pwrite) << 9 | (mem ? memk : 0u) << 7 |
         uint32_t(op->cls == kBranch) << 6 | uint32_t(op->cls == kExit ? kSerExit : 0) << 3 |
         lat;
}
// The three fields DEC adds so OOE never decodes opcode (A-75, TI-1).
enum : unsigned { kPredUseNone = 0, kPredUseGuard = 1, kPredUseData = 2 };
enum : unsigned { kImmLiteral = 0, kImmPredSrcs = 1, kImmWarpBase = 2, kImmCtaid = 3, kImmLaneCtx = 4 };
/// Bit i: source i is a real read (src_arch's two fields, then src2_arch).
inline unsigned srcValidOf(const OpInfo *op) { return (1u << op->nsrc) - 1u; }
inline unsigned predUseOf(const OpInfo *op) {
  return op->guard ? kPredUseGuard : op->pdata ? kPredUseData : kPredUseNone;
}
inline unsigned immKindOf(const OpInfo *op) {
  return op->cls == kPredLogic ? kImmPredSrcs
         : op->srd_sel == 0     ? kImmWarpBase
         : op->srd_sel == 1     ? kImmCtaid
         : op->srd_sel == 2     ? kImmLaneCtx : kImmLiteral;
}
inline bool attrMem(uint32_t a) { return (a >> 13) & 1u; }
inline unsigned attrMemKind(uint32_t a) { return (a >> 7) & 3u; }
inline bool attrBranch(uint32_t a) { return (a >> 6) & 1u; }
inline unsigned attrBypGroup(uint32_t a) { return (a >> 14) & 7u; }
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
  // srd #2 (%lanectx, O-64): the immediate is the hardware warp context
  // << 5, the core's index above it; the lane ORs its index, as for #0.
  {"SRD",           kAlu,       0, true,  false, false, false, false, -1, -1, -1, -1, -1,  0,  0, 2, true},
  // A guarded load (Format Dp): MIU writes the active lanes, and the inactive
  // ones keep their old value through a copy-only op (A-33, A-38).
  {"LD_GLOBAL_P",   kLoad,      1, true,  true,  false, true,  false,  0, -1, -1,  0, -1, -1, -1},
  // rope's (CP's release kernel, TI-30). The lanes return ccv-sim's results,
  // so a row is the operand shape and where the op runs.
  {"ADD",           kAlu,       2, true,  false, false, false, false, -1, -1, -1, -1, -1, -1, -1},
  {"MUL_LO",        kAlu,       2, true,  false, false, false, false, -1, -1, -1, -1, -1, -1, -1},
  {"C_MUL_LO",      kAlu,       2, true,  false, false, false, false, -1, -1, -1, -1, -1, -1, -1},
  {"C_MOV",         kAlu,       1, true,  false, false, false, false, -1, -1, -1, -1, -1, -1, -1},
  {"C_ADDI",        kAlu,       1, true,  false, false, false, false, -1, -1, -1, -1, -1,  0,  1},
  {"C_SHLI",        kAlu,       1, true,  false, false, false, false, -1, -1, -1, -1, -1,  0,  1},
  {"C_SHRI",        kAlu,       1, true,  false, false, false, false, -1, -1, -1, -1, -1,  0,  1},
  // mad.lo under a guard: as add.p, the guard's off lanes keep the old value.
  {"MADLO_P",       kAlu,       3, true,  true,  false, true,  false, -1, -1, -1, -1, -1, -1, -1},
  // Format C" compares (O-32): no qualifier, every issue-mask lane written.
  {"SETP_EQ_NP",    kAlu,       2, false, false, true,  false, false, -1, -1, -1, -1, -1, -1, -1},
  {"SETP_LE_U_NP",  kAlu,       2, false, false, true,  false, false, -1, -1, -1, -1, -1, -1, -1},
  {"SETP_LT_U_NP",  kAlu,       2, false, false, true,  false, false, -1, -1, -1, -1, -1, -1, -1},
  {"SETP_LT_NPI",   kAlu,       1, false, false, true,  false, false, -1, -1, -1, -1, -1,  0,  1},
  // FP: integer lanes' timing for now, FP's bypass group (OI-16).
  {"C_FMUL",        kAlu,       2, true,  false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypFp},
  {"FNEG_F0",       kAlu,       1, true,  false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypFp},
  {"FFMA_F0",       kAlu,       3, true,  false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypFp},
  {"FFMA_ACC_F0",   kAlu,       3, true,  false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypFp},
  {"ST_GLOBAL",     kStore,     2, false, false, false, false, false,  1, -1,  0,  0, -1, -1, -1},
  {"C_BRA",         kBranch,    0, false, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},
  // pmov.imm: bit n of the immediate is lane n's predicate bit, for all 32
  // lanes, ungated by the issue mask (section 3): an immediate RCU writes.
  {"PMOV_IMM",      kImm,       0, false, false, true,  false, false, -1, -1, -1, -1, -1,  0,  0},
  // shfl.idx: each guarded issue lane takes the source register at one lane,
  // active or not (Format G): RCU, which holds every lane's register.
  {"SHFL_IDX",      kAlu,       1, true,  true,  false, true,  false, -1, -1, -1, -1, -1,  0, -1, -1, false, true},
  // The launch-slot forms (O-45; TI-31): [slot, rindex, scale, disp], the
  // window from launch slot `slot`, so no base register (base -1).
  {"LD_GLOBAL_SLOT", kLoad,     1, true,  false, false, false, false, -1,  0, -1,  2,  1, -1, -1, -1, false, false, -1, 0},
  {"ST_GLOBAL_SLOT", kStore,    2, false, false, false, false, false, -1,  1,  0,  2,  1, -1, -1, -1, false, false, -1, 0},
  // Predicate transfers (O-19, O-62, O-63; TI-36): [mask in quals, rbase,
  // disp]. ld.pred writes its predicate; st.pred reads it as data, renamed
  // as sel's selector is (pdata), never as a guard.
  {"LD_PRED_G",     kLoad,      1, false, false, true,  false, false,  0, -1, -1,  0, -1, -1, -1, -1, false, false, -1, -1, true},
  {"ST_PRED_G",     kStore,     1, false, true,  false, false, true,   0, -1, -1,  0, -1, -1, -1, -1, false, false, -1, -1, true},
  // The interleaved local forms (O-69; IS-19): [rdata, b] and [mask in
  // quals, b], no base register; the predicate forms crack as ld.pred's.
  {"LD_LOCAL",      kLoad,      0, true,  false, false, false, false, -1, -1, -1,  0, -1, -1, -1, -1, false, false, -1, -1, false, true},
  {"ST_LOCAL",      kStore,     1, false, false, false, false, false, -1, -1,  0,  0, -1, -1, -1, -1, false, false, -1, -1, false, true},
  {"LD_PRED_LOCAL", kLoad,      0, false, false, true,  false, false, -1, -1, -1,  0, -1, -1, -1, -1, false, false, -1, -1, true,  true},
  {"ST_PRED_LOCAL", kStore,     0, false, true,  false, false, true,  -1, -1, -1,  0, -1, -1, -1, -1, false, false, -1, -1, true,  true},
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
/// srd's opcode for a selector, or null: 3-15 are unallocated.
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

/// OOE's implementation behind the swap boundary: the S1 stub (ooe.cpp).
std::unique_ptr<Block> makeOoe(int inst, Kernel &k);

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_STUB_H
