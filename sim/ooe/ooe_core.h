//===-- ooe_core.h - the OOE microarchitecture, port-agnostic --*- C++ -*-===//
//
// The Stage 4b timing model of OOE: decode queue, rename (GPR and predicate
// RATs, RAT checkpoints, a global free list with per-slot floor and
// ceiling), unified reservation stations split by class, the 2-bit-cell
// dependency matrix with per-pair bypass wakes, oldest-first select with a
// rotating warp tie-break, transitive cancel, four per-slot ROBs, squash in
// ROB order, deferred free, demotion, kill, restore and faults.
//
// The design is docs/design-snapshots/ooe-microarchitecture.md (the live doc
// wins); every policy the doc leaves open is decided in docs/ooe-model.md,
// and nothing here is a number without a parameter behind it there.
//
// This class knows no channel, no Bits and no testbench. It takes decoded
// inputs and produces decoded outputs, one cycle() per clock; the port
// adapter (ooe_block.cpp) packs and unpacks them at the swap boundary. The
// split exists so every recovery path -- squash, cancel, demotion, kill,
// restore -- has a unit test (ooe_test.cpp) long before a stub can reach it,
// and so the RTL (4c) has a reference with the same seams.
//===----------------------------------------------------------------------===//
#ifndef CCV_OOE_CORE_H
#define CCV_OOE_CORE_H

#include "ccv_params.h"

#include <array>
#include <cstdint>
#include <deque>
#include <functional>
#include <map>
#include <string>
#include <vector>

namespace ccv {
namespace ooe {

constexpr unsigned kArchGprs = ccv::kGprs;      ///< 16
constexpr unsigned kArchPreds = ccv::kPreds;    ///< 4
constexpr unsigned kWarpIds = ccv::kWarpContexts;
constexpr uint32_t kFullMask = 0xffffffffu;
constexpr unsigned kNoEntry = ~0u;

// ---- configuration --------------------------------------------------------------
//
// Every default comes from params/ccv_params.json. A field with no parameter
// behind it is marked KNOB: a sweep variable with a documented default
// (docs/ooe-model.md, "Knobs without a parameter"), owed a parameter by the
// top-level session before the RTL hard-codes anything.
struct Config {
  unsigned slots = ccv::kTier1Warps;              ///< tier-1 warps, one ROB each
  unsigned rob_depth = ccv::prov::kRobDepth;
  unsigned retire_per_rob = ccv::kRetirePerRob;
  unsigned issue_width = ccv::kIssueWidth;        ///< ccv_ooe_rcu_issue rate
  unsigned memop_width = ccv::kIssueWidth;        ///< ccv_ooe_miu_memop rate
  unsigned retire_msgs = ccv::kIssueWidth;        ///< ccv_ooe_miu_retire rate
  unsigned rename_width = ccv::kIssueWidth;       ///< doc: "4 uops per cycle"
  unsigned rs_rcu = ccv::prov::kRsRcu;
  unsigned rs_miu = ccv::prov::kRsMiu;
  unsigned rs_warp_cap = ccv::prov::kRsWarpCap;   ///< 0 or >= both classes = no cap
  unsigned decq = ccv::prov::kDecq;
  unsigned decq_warp_max = ccv::prov::kDecqWarpMax; ///< 0 or >= decq = no limit
  unsigned ckpts = ccv::prov::kBrCkpts;
  unsigned phys_regs = ccv::prov::kPhysRegs;
  unsigned pred_regs = ccv::prov::kPredRegs;
  unsigned ren_floor = ccv::prov::kRenFloor;
  unsigned ren_ceil = ccv::prov::kRenCeil;
  unsigned pred_ren_floor = ccv::prov::kPredRenFloor;
  unsigned pred_ren_ceil = ccv::prov::kPredRenCeil;
  unsigned phys_zero = ccv::prov::kPhysZero;
  unsigned pred_zero = ccv::prov::kPredZero;
  unsigned epochs = 1u << ccv::prov::kWFetchEpoch;
  // Wake latencies: the generated contract (A-47, A-57, A-61, A-63).
  unsigned lat_rcu = ccv::prov::kLatRcu;
  unsigned lat_lane = ccv::prov::kLatLane;
  unsigned lat_lane_byp = ccv::prov::kLatLaneByp;
  unsigned lat_l1_wake = ccv::prov::kLatL1Wake;
  unsigned lat_l1_cmpl = ccv::prov::kLatL1Cmpl;
  /// When an epoch notice has landed in FET: ccv_ooe_fet_redirect's fixed
  /// latency (A-74). The adapter sets it from the wiring.
  unsigned redirect_lat = ccv::kLatHop;
  /// The crossings of ccv_ooe_rcu_issue and ccv_rcu_ooe_done, for the
  /// arrival-cycle checker on done (V-35): the adapter sets both from the
  /// wiring, CCV_LAT_HOP + repeater stages (A-63).
  unsigned issue_link = ccv::kLatHop, done_link = ccv::kLatHop;
  /// Past L1, dependants wake on the completion (A-46) -- but MIU sends the
  /// data to RCU and the completion to OOE together, over different links.
  /// A dependant must reach RCU after the data does, so it wakes this many
  /// cycles after the completion lands: max(0, ccv_miu_rcu_data crossing -
  /// ccv_miu_ooe_cmpl crossing - ccv_ooe_rcu_issue crossing + 1). The
  /// CCV_LAT_L1_MISS_WAKE (OI-13), generated from the links; 0 with no repeaters.
  unsigned cmpl_wake_delay = ccv::prov::kLatL1MissWake;
  /// Select's payload-read stage (OA-1, OI-26): a grant leaves on the
  /// channel this many cycles later. Wakes count from the grant, so the
  /// stage shifts producer and dependant alike; only the contracts timed
  /// from the channel (V-35, V-44, the L1 shadow, a copy's landing) add it.
  /// 0 or 1.
  unsigned payload_stages = 1;
  /// Rename's stages (OA-1, OI-29): RAT read, producer lookup, matrix write.
  /// An entry renamed in cycle t can be selected from t + rename_stages.
  unsigned rename_stages = 3;
  /// Demotion trigger thresholds (CSRs, one per trigger; Q18), each its own
  /// parameter (OI-6); the values wait on OA-8.
  unsigned demote_fallback = ccv::prov::kDemotionThreshold;
  unsigned demote_mlc_miss = ccv::prov::kDemotionThresholdMlc;
  unsigned demote_barrier = ccv::prov::kDemotionThresholdBarrier;

  // -- what the neighbours can do today (docs/ooe-model.md, "S1 modes") -------
  /// Bypass groups (docs/ooe-model.md, "Bypass groups"; OI-16, Daniel's
  /// responses OA-4). A producer's lat_class sets its full latency and its
  /// fastest bypass point; its bypass_group and the consumer's index the
  /// penalty table. A consumer may issue on the result fast[unit] +
  /// byp[producer group][consumer group] cycles after the producer's issue,
  /// if that is under the full latency; kNoByp, or a unit with no fastest
  /// point (single-time: RCU, warp-collective, loads), means the PRF read.
  bool bypass = true;            ///< master enable
  static constexpr unsigned kUnits = ccv::prelim::kPLatClasses;
  static constexpr unsigned kGroups = ccv::prelim::kPBypGroups;
  enum : unsigned { kGrpInt = 0, kGrpFp = 1, kGrpAddr = 2, kGrpSfu = 3, kGrpColl = 4, kGrpPred = 5 };
  static constexpr uint8_t kNoByp = 0xFF;
  std::array<std::array<uint8_t, kGroups>, kGroups> byp = defaultByp();
  /// The fastest bypass point per lat_class; 0 for a single-time unit. The
  /// lane's is lat_lane_byp (CCV_LAT_LANE_BYP). SFU has none until a
  /// CCV_LAT_SFU_BYP exists (OA's response OI-16), so SFU wakes at its
  /// full latency.
  std::array<unsigned, kUnits> fast{};
  /// Full latency of lat_class codes 4-7: SFU and warp-collective from
  /// their parameters, the spares 0 (wake on the done).
  std::array<unsigned, kUnits> unit_lat = {0, 0, 0, 0, ccv::prov::kLatSfu, ccv::prov::kLatCollective, 0, 0};
  static std::array<std::array<uint8_t, kGroups>, kGroups> defaultByp() {
    std::array<std::array<uint8_t, kGroups>, kGroups> t;
    for (auto &row : t) row.fill(kNoByp);
    const unsigned same = ccv::prov::kLatBypPenSame, intfp = ccv::prov::kLatBypPenIntFp,
                   sfu = ccv::prov::kLatBypPenSfu;
    t[kGrpInt][kGrpInt] = t[kGrpFp][kGrpFp] = t[kGrpSfu][kGrpSfu] = uint8_t(same);
    t[kGrpInt][kGrpFp] = t[kGrpFp][kGrpInt] = uint8_t(intfp);
    t[kGrpInt][kGrpSfu] = t[kGrpFp][kGrpSfu] = t[kGrpSfu][kGrpInt] = t[kGrpSfu][kGrpFp] = uint8_t(sfu);
    return t;
  }
  unsigned fastOf(unsigned unit) const { return unit == 1 ? lat_lane_byp : fast[unit]; }
  /// The bypass wake for a pair, in cycles after the producer's issue, or
  /// 0 for none: the consumer waits the producer's full latency.
  unsigned bypWake(unsigned unit, unsigned pg, unsigned cg) const {
    if (unit >= kUnits || pg >= kGroups || cg >= kGroups || byp[pg][cg] == kNoByp) return 0;
    const unsigned f = fastOf(unit);
    if (!f) return 0;
    const unsigned w = f + byp[pg][cg];
    return w < unitLat(unit) ? w : 0;
  }
  /// A unit's full latency: when any reader may issue on its result through
  /// the register file; 0 if it wakes on its done.
  unsigned unitLat(unsigned unit) const {
    return unit == 0 ? lat_rcu : unit == 1 ? lat_lane : unit >= 4 ? unit_lat[unit] : 0;
  }
  /// Speculative wake of L1-load dependants at CCV_LAT_L1_WAKE, cancelled on
  /// a miss (A-46). Off while MIU completes no load at the L1 contract.
  bool l1_spec = true;
  // -- narrow registers and lane sections (OI-28 to OI-33, Daniel's 2026-10-08) -
  /// Sectioned lanes: a register is a slice of a PRF row, named row * 4 +
  /// position, an op claims the union of its operands' sections widened to
  /// its unit's minimum, and select grants nine resources (S0-S3, R, P0-P3).
  /// Off in S1 until OI-32's schema carries positions: names are then rows.
  bool sectioned = false;
  /// Placement of a narrow destination with no narrow source (OA-14):
  /// 0 the warp's home position, its tier-1 slot index; 1 position 0 for
  /// every warp; 2 the home position, advanced at each taken backward branch
  /// from 0; 3 the same, from the slot index (OA-14 leaves the start open);
  /// 4 the slot index plus the architectural destination (OI-34's own arm).
  unsigned place = 0;
  /// OA-13: a load passes older loads of its warp, blocked only by an older
  /// unissued store, atomic, fence or ordered access. Off: memops issue in
  /// program order per warp (OI-15).
  bool loads_pass_loads = false;
  /// CCV_FOOT_MIN[bypass_group] in sections (AR-12): integer 1, FP 2,
  /// address calculation 1 (in MIU pipes), SFU 4; warp-collective and
  /// predicate 0 (RCU only).
  std::array<unsigned, kGroups> foot_min = {1, 2, 1, 4, 0, 0, 1, 1};
  /// Rename predicates through the predicate RAT and pool (Q-21, A-39). Off
  /// while RCU reads predicate-logic sources and the final compare reads
  /// predicates by a fixed window (physPred), which A-75 and a testbench
  /// hook settle. Off, each warp's predicates live at a fixed window and
  /// OOE orders predicate writes behind older readers and writers itself.
  bool rename_preds = true;
  /// The fixed window's base for warp_id w, predicate p: w * 4 + p.
  std::function<unsigned(unsigned, unsigned)> pred_window =
      [](unsigned w, unsigned p) { return w * kArchPreds + p; };
  /// RCU sends a done for memops too (the S1 RCU does: for a store when it
  /// sends the address, for a load when it writes the data). When set, a
  /// memop completes only after both, so no late done meets a reused tag.
  bool memop_rcu_done = false;
  /// INTERIM (TI, sectioned lanes; OI-31 replaces it): one footprint per
  /// select resource group a cycle. A lane op claims every lane section, a
  /// memop every MIU pipe and an RCU-only op R, since nothing is placed by
  /// slice yet and every S1 op is full width. So at most one lane op (a
  /// masked load's copy among them), one memop and one RCU op issue a cycle,
  /// which is what ccv_ooe_rcu_issue's nine resource slots carry at 32 bits.
  /// Off, select keeps today's single four-wide budget (the unit tests).
  bool resource_cap = false;

  // -- fault injection: the negative controls the core itself must carry ------
  bool inject_free_new = false;   ///< retire frees the new mapping (free-new)
  bool inject_shallow_cancel = false;  ///< cancel stops after one hop (V-15)
  bool inject_early_wake = false;      ///< fixed-latency wakes a cycle early
  bool inject_complete_early = false;  ///< complete before RS entries free (V-58)
  bool inject_narrow_footprint = false; ///< a lane op claims only its lowest section (OI-30)

  /// Apply "name=value,..." over these defaults; returns an error or "".
  std::string apply(const std::string &spec);
  /// The elaboration-time checks (V-31, V-51, V-55); returns an error or "".
  std::string check() const;
};

// ---- decoded inputs -----------------------------------------------------------------

/// sched_attr, decoded (A-66). MSB first: rs_miu, exec_rcu, cross_lane,
/// writes_gpr, writes_pred, mem_kind[2], branch, serial[2], lat_class[3].
struct SchedAttr {
  bool rs_miu = false, exec_rcu = false, cross_lane = false;
  bool writes_gpr = false, writes_pred = false, branch = false;
  unsigned mem_kind = 0, serial = 0, lat_class = 0;
  unsigned bypass_group = 0;    ///< OI-16: [15:13]
  static SchedAttr decode(uint32_t a);
};
enum : unsigned { kMemKLoad = 0, kMemKStore = 1, kMemKAtomic = 2, kMemKFence = 3 };
enum : unsigned { kLatClsRcu = 0, kLatClsLane = 1, kLatClsL1 = 2, kLatClsCompletion = 3 };
enum : unsigned { kSerNone = 0, kSerChwidth = 1, kSerBarrier = 2, kSerExit = 3 };

/// What A-75 has yet to put on ccv_dec_ooe_uop. Until it does, the adapter
/// derives these from the skeleton's opcode table -- the one place OOE still
/// looks at opcode, marked temporary there.
struct UopShape {
  uint8_t gpr_reads = 0;      ///< bit i: src i is a real read
  bool guard = false;         ///< the predicate read is a guard (an enable)
  bool pdata = false;         ///< the predicate read is data (sel)
  bool pred_logic = false;    ///< two predicate sources, qualifiers in imm
  bool exit = false;
  int srd = -1;               ///< -1, or the identity: 0 %ctatid, 1 %ctaid
};

struct Uop {
  uint64_t tid = 0;
  unsigned warp = 0;
  uint64_t pc = 0;
  uint32_t group_mask = 0;
  unsigned fetch_epoch = 0;
  SchedAttr attr;
  uint32_t attr_raw = 0;
  unsigned mem_op = 0, space = 0, ordering = 0;
  unsigned opcode = 0;               ///< passed to RCU unexamined
  unsigned src[3] = {}, dst = 0;     ///< architectural GPRs
  unsigned pred_guard = 0, pred_dst = 0;
  bool pred_neg = false, pred_we = false;
  uint32_t imm = 0;
  unsigned ilen = 0;
  unsigned ckpt = 0;
  bool pred_taken = false;
  bool scale_en = false;
  bool decode_fault = false;
  /// The destination's element width, from the committed chwidth table:
  /// 0 32-bit, 1 16-bit, 2 8-bit, 3 4-bit (sectioned; a 4-bit register takes
  /// an 8-bit section, OI-29). Sources carry their own in their names.
  unsigned w = 0;
  bool backward = false;             ///< a branch whose target is behind it (OA-14)
  UopShape shape;
};

struct Done {           ///< ccv_rcu_ooe_done
  unsigned rob_tag = 0;
  bool exec_fault = false;
  bool branch_taken = false;
  uint32_t branch_mask = 0, fault_lane_mask = 0;
};
struct Cmpl {           ///< ccv_miu_ooe_cmpl
  unsigned rob_tag = 0, status = 0, cause = 0;
  uint32_t lane_mask = 0;
  uint64_t address = 0;
  bool mlc_miss = false;
};
enum : unsigned { kAllocFree = 0, kAllocLaunch = 1, kAllocRestoreAlloc = 2,
                  kAllocRestoreActivate = 3 };
struct Alloc {          ///< ccv_rau_ooe_alloc
  unsigned warp = 0, slot = 0, op = 0;
  uint32_t ctaid = 0, warp_in_cta = 0;
};

// ---- decoded outputs ----------------------------------------------------------------

struct Issue {          ///< ccv_ooe_rcu_issue
  uint64_t tid = 0;
  unsigned port = 0;    ///< issue slot
  unsigned rob_tag = 0, warp = 0;
  uint32_t issue_mask = 0;
  unsigned psrc[3] = {}, pdst = 0, pold = 0;
  unsigned ppguard = 0, ppdst = 0, ppold = 0;
  bool pred_neg = false, pred_we = false, merge = false;
  unsigned opcode = 0;
  bool copy = false;    ///< the copy-only op (A-38): opcode CCV_OP_PRF_COPY
  bool send_imm = false;
  uint32_t imm = 0;
  unsigned chwidth = 0;
  bool guarded = false;          ///< for the adapter's coverage only
  uint8_t gpr_reads = 0;         ///< likewise
  /// The resource group the op issues on (ccv_ooe_rcu_issue's slots) and
  /// its footprint there: lane sections, MIU pipes, or R alone (footprint 0).
  enum : uint8_t { kLaneOp = 0, kMemop = 1, kRcuOp = 2 };
  uint8_t res = kLaneOp;
  uint8_t footprint = 0xF;
  uint8_t byp_group = 0;         ///< sched_attr's bypass_group (OI-16)
};
struct Memop {          ///< ccv_ooe_miu_memop
  uint64_t tid = 0;
  unsigned port = 0;
  unsigned rob_tag = 0, warp = 0;
  unsigned mem_op = 0;           ///< DEC's (A-68), or 0xF for a bulk discard
  uint32_t issue_mask = 0;
  unsigned pdst = 0, ppred = 0;
  uint32_t disp = 0;             ///< the uop's imm; the discard tail on 0xF
  bool scale_en = false;
  unsigned space = 0, ordering = 0, chwidth = 0;
};
struct Commit {         ///< ccv_ooe_miu_retire
  uint64_t tid = 0;
  unsigned port = 0, rob_tag = 0;
  bool commit = true;
};
struct Redirect {       ///< ccv_ooe_fet_redirect
  uint64_t tid = 0;
  unsigned warp = 0, slot = 0, ckpt = 0, epoch = 0;
  uint32_t taken_mask = 0;
  uint64_t target_pc = 0;
  bool epoch_only = false;
};
struct Status {         ///< ccv_ooe_rau_status
  unsigned warp = 0;
  bool fault_taken = false, stalled = false, mlc_miss_seen = false;
  uint32_t retired_since_restore = 0;
};
struct Fault {          ///< ccv_ooe_cru_fault
  unsigned warp = 0, cause = 0, cta_slot = 0;
  uint64_t pc = 0, address = 0;
  uint32_t lane_mask = 0;
};
struct Drained {        ///< ccv_ooe_rau_drained
  unsigned warp = 0;
  uint64_t resume_pc = 0;
};
struct RatMap {         ///< ccv_ooe_rcu_map
  unsigned warp = 0, direction = 0;
  std::array<unsigned, kArchGprs> gpr{};
  std::array<unsigned, kArchPreds> pred{};
};
struct Bar {            ///< ccv_ooe_syu_bar
  unsigned warp = 0, cta_slot = 0, barrier_id = 0;
  bool wait = true;
};

/// Everything the core sends in one cycle. The adapter drains it.
struct Outputs {
  std::vector<Issue> issues;
  std::vector<Memop> memops;
  std::vector<Commit> commits;
  std::vector<Redirect> redirects;     ///< at most one: the channel is rate 1
  uint64_t free_mask = 0;              ///< ccv_ooe_fet_ckpt_free, 0 = none
  std::vector<Status> status;
  std::vector<Fault> faults;
  std::vector<Drained> drained;
  std::vector<RatMap> maps;
  std::vector<Bar> bars;
  /// Kills acknowledged this cycle (kill_ack), by kill epoch.
  std::vector<unsigned> kill_acks;
  void clear() { *this = Outputs(); }
};

/// Retirement, reported for the testbench (retire bookkeeping, rat0).
struct Retired {
  uint64_t tid = 0;
  unsigned warp = 0, rob_tag = 0;
  bool exit = false;
  bool writes_gpr = false;
  unsigned dst = 0, pnew = 0;
  bool writes_pred = false;         ///< a renamed predicate destination
  unsigned pdst = 0, ppnew = 0;
};

// ---- the model -------------------------------------------------------------------------

/// A free list as the RTL builds it (OI-22, docs/ooe-rtl-plan.md item 2): one
/// bit per register, allocated by a priority encoder that starts at a rotating
/// pointer and moves past each register it hands out, so a freed register
/// comes back late. A free sets its bit at the clock edge (clock()), so a
/// register freed in a cycle is not allocated in that cycle. Any number of
/// frees a cycle costs nothing.
/// OOE's structural events (docs/ooe-model.md, "Events"; OI-7), in the order
/// of their ids in schema/events.json, EV_OOE_GPR_EMPTY first. Each carries
/// warp_id as a; b and c are the schema's fields.
enum class OoeEv : unsigned {
  kGprEmpty, kRenameLimit, kPredEmpty, kRobFull, kRobSlotHeld, kRsFull, kRsWarpCap,
  kDecqFull, kDecqWarpMax, kChwidthHold, kBarrierHold, kRedirectBusy, kMemopHeld,
  kMemopHoldCycles, kDeferredFree, kReadyNotSelected, kCancelReplay, kDemoteTrigger,
  kCrossGroupSquash, kCopyIssue, kCount
};

class FreeVec {
public:
  void reset(unsigned n) {
    bit_.assign(n, 1);
    pend_.assign(n, 0);
    ready_ = n;
    npend_ = 0;
    ptr_ = 0;
  }
  /// Free registers, including those freed this cycle.
  size_t size() const { return ready_ + npend_; }
  /// Free registers allocation can take this cycle.
  size_t ready() const { return ready_; }
  bool empty() const { return ready_ == 0; }
  bool has(unsigned p) const { return bit_[p] || pend_[p]; }
  unsigned alloc() {
    const unsigned n = unsigned(bit_.size());
    for (unsigned i = 0; i != n; ++i) {
      const unsigned p = (ptr_ + i) % n;
      if (!bit_[p]) continue;
      bit_[p] = 0;
      --ready_;
      ptr_ = (p + 1) % n;
      return p;
    }
    return n;   // caller checked ready()
  }
  /// False when the register is already free (a double free).
  bool free(unsigned p) {
    if (has(p)) return false;
    pend_[p] = 1;
    ++npend_;
    return true;
  }
  void clock() {
    if (!npend_) return;
    for (size_t p = 0; p != pend_.size(); ++p)
      if (pend_[p]) { pend_[p] = 0; bit_[p] = 1; }
    ready_ += npend_;
    npend_ = 0;
  }

private:
  std::vector<uint8_t> bit_, pend_;
  size_t ready_ = 0, npend_ = 0;
  unsigned ptr_ = 0;
};

class Core {
public:
  explicit Core(const Config &cfg);

  // -- inputs. Completions and RAU's messages before cycle(), and they take
  // effect in it; uops after it (the decode queue is written behind rename).
  /// Can the decode queue take a uop of this warp? (Credit: the adapter
  /// leaves a uop in the channel while this is false.)
  bool canAccept(unsigned warp) const;
  /// The adapter left a uop of this warp in the channel because canAccept
  /// said no: count which limit held it (the decode-queue events).
  void noteRefused(unsigned warp);
  void uop(const Uop &u);
  void done(const Done &d);
  void cmpl(const Cmpl &c);
  void alloc(const Alloc &a);
  void demote(unsigned warp);
  void barRelease(uint32_t warp_mask);
  void kill(uint32_t warp_mask, unsigned epoch);

  /// One clock.
  void cycle(uint64_t now);
  Outputs out;
  std::vector<Retired> retired;        ///< this cycle's retirements, in order

  // -- observation ------------------------------------------------------------------
  /// Hooks for events and coverage: (name, warp, a, b, tid).
  std::function<void(const char *, unsigned, uint64_t, uint64_t, uint64_t)> on_event;
  /// The structural events, (kind, warp, b, c, tid); see OoeEv.
  std::function<void(OoeEv, unsigned, uint64_t, uint64_t, uint64_t)> on_ooe_event;
  /// A broken invariant or a contract violation: the adapter makes it a
  /// check failure.
  std::function<void(const std::string &)> on_error;
  /// Run every invariant (V-01 ... ) once; cycle() calls it when enabled.
  bool check_invariants = true;
  void checkInvariants();

  bool busy() const;
  const Config &config() const { return cfg_; }
  /// Per-warp_id committed GPR map, for the final compare (Kernel::rat0).
  std::vector<unsigned> committedGprMap(unsigned warp) const;
  /// Counters: every structural stall and event of the doc's Events table.
  std::map<std::string, uint64_t> counters;
  std::map<std::string, std::map<uint64_t, uint64_t>> histograms;
  /// Free-list depths and a slot's owned registers, for tests and sweeps.
  size_t freeGprs() const { return gfree_.size(); }
  size_t freePreds() const { return pfree_.size(); }
  unsigned heldGprs(unsigned slot) const { return slot_[slot].held_gpr; }
  /// The warp's speculative and committed predicate maps (rename_preds).
  std::array<unsigned, kArchPreds> committedPredMap(unsigned warp) const;
  /// The warp's current fetch epoch (A-70).
  unsigned epoch(unsigned warp) const { return epoch_[warp % kWarpIds]; }

private:
  // -- structures ----------------------------------------------------------------------
  enum class RsCls : uint8_t { kRcu, kMiu };

  struct RobEntry {
    bool valid = false;
    bool squashed = false;         ///< held after a squash (deferred free)
    Uop u;
    unsigned seq = 0;              ///< per-warp program order, for age
    unsigned psrc[3] = {}, pold = 0, pnew = 0;
    unsigned ppguard = 0, ppold = 0, ppnew = 0, pq[2] = {};
    bool merge = false;            ///< merge_en: some lane keeps its old value
    bool alloc_gpr = false, alloc_pred = false;
    bool is_mem = false, is_store = false, is_load = false, copy = false;
    unsigned rs_main = kNoEntry, rs_copy = kNoEntry;
    // completion
    unsigned rcu_dones_owed = 0;   ///< issues to RCU whose done has not landed
    unsigned stale_dones = 0;      ///< of those, issues a cancel voided
    bool rcu_done = false, miu_done = false, at_miu = false;
    bool copy_pending = false;
    uint64_t copy_land = 0;        ///< the copy's scheduled landing
    uint64_t rcu_issue_at = 0;     ///< the latest issue to RCU
    bool complete = false;
    // branch
    bool resolved = false, taken = false;
    uint32_t taken_mask = 0;
    bool ckpt_live = false;
    // fault
    bool fault = false;
    unsigned fault_cause = 0;
    uint32_t fault_lanes = 0;
    uint64_t fault_addr = 0;
    bool mlc_miss = false;
    bool committed = false;        ///< a store's commit has gone to MIU
  };

  struct RsEntry {
    bool valid = false;
    RsCls cls = RsCls::kRcu;
    unsigned slot = 0, rob = 0;    ///< owner
    uint64_t age = 0;              ///< allocation order: the age matrix's order
    bool copy = false;             ///< the copy-only half of a masked load
    bool produces = false;         ///< writes a register some entry may wake on
    bool issued = false;
    uint64_t issue_at = 0;
    bool spec = false;             ///< woken speculatively (an L1 load)
    bool on_completion = false;    ///< wakes on its completion, not a time
    uint64_t late_at = 0;
    bool late = false;             ///< the full-latency wake (bypass wakes are per cell)
    bool confirmed = false;        ///< result can no longer be cancelled
    bool ever_issued = false;
    unsigned replays = 0;
    bool ready_seen = false;       ///< for EV_WAKEUP / ready-not-selected
    uint64_t ready_since = 0;      ///< first cycle a memop's row was ready
    uint64_t eligible_at = 0;      ///< first cycle select may take it (rename's stages)
    unsigned res = 0;              ///< sectioned: the resources it needs (resOf)
  };

  struct Ckpt {
    bool live = false;
    std::array<unsigned, kArchGprs> gpr{};
    std::array<unsigned, kArchPreds> pred{};
  };

  enum class WarpState : uint8_t { kFree, kAllocated, kActive, kDemoting,
                                   kDrained, kKilling };
  struct Slot {
    WarpState st = WarpState::kFree;
    unsigned warp = 0;
    uint32_t ctaid = 0, warp_in_cta = 0;
    std::array<unsigned, kArchGprs> rat{}, crat{};      ///< speculative, committed
    std::array<unsigned, kArchPreds> prat{}, cprat{};
    std::vector<Ckpt> ckpt;
    std::vector<RobEntry> rob;
    unsigned head = 0, tail = 0, count = 0;
    unsigned next_seq = 0;
    unsigned held_gpr = 0, held_pred = 0;     ///< owned registers (floor/ceiling)
    unsigned rs_held = 0;                     ///< RS entries (per-warp cap)
    unsigned decq = 0;                        ///< decode-queue entries
    unsigned chwidth = 0;                     ///< committed (serialisation)
    bool chwidth_hold = false, bar_hold = false;
    unsigned bar_id = 0;                      ///< the held barrier (events)
    unsigned home_ctr = 0;                    ///< OA-14's rotating home position
    unsigned chwidth_rob = 0;                 ///< the holding instruction
    bool fault_stop = false;                  ///< V-24
    uint64_t head_since = 0;                  ///< head-stall timer (demotion)
    unsigned head_seen = ~0u;
    bool stalled_reported = false, miss_reported = false;
    uint32_t retired_since_restore = 0;
    uint64_t next_pc = 0;                     ///< after the last retirement
    bool map_sent = false;                    ///< demotion: map to RCU
    uint64_t notice_lands = 0;                ///< epoch notice in FET (A-74)
    bool notice_sent = false;
    unsigned kill_epoch = 0;
    uint64_t resume_pc = 0;
  };

  // -- pipeline steps (cycle() calls them in this order) ------------------------
  void takeCompletions();
  void advanceWakes();
  void retire();
  void select();
  void rename();
  void control();
  void sendRedirect();

  // -- helpers ---------------------------------------------------------------------------
  int slotOf(unsigned warp) const;
  RobEntry *byTag(unsigned tag, unsigned *slot = nullptr);
  unsigned tagOf(unsigned slot, unsigned idx) const {
    return slot << ccv::prov::kWRobIdx | idx;
  }
  unsigned robAge(const Slot &s, unsigned idx) const {
    return (idx + cfg_.rob_depth - s.head) % cfg_.rob_depth;
  }
  bool tryRename(unsigned slot, const Uop &u);
  unsigned rsAlloc(RsCls c, unsigned slot, unsigned rob, bool copy);
  void rsFree(unsigned e);
  void addDeps(unsigned e, const RobEntry &r, bool copy_half);
  void dep(unsigned e, unsigned preg, bool pred, int group);
  bool cellOk(unsigned i, unsigned j) const;
  bool rowReady(unsigned i) const;
  bool rowConfirmed(unsigned i) const;
  void doIssue(unsigned e, unsigned port, bool with_copy, unsigned copy_port);
  void setWakes(unsigned e);
  void wake(unsigned e);
  void emitWakeups();
  void cancel(unsigned e);
  bool cancelHop(unsigned root);
  void confirmPass();
  bool predHold(unsigned slot, const RobEntry &r) const;
  void complete(unsigned slot, unsigned idx);
  void resolveBranch(unsigned slot, unsigned idx);
  void squashAfter(unsigned slot, int keep_idx, bool to_retirement);
  void releaseEntry(unsigned slot, unsigned idx);
  bool outstanding(const RobEntry &r) const;
  bool gprAllowed(unsigned slot, unsigned n) const;
  bool predAllowed(unsigned slot, unsigned n) const;
  unsigned allocGpr(unsigned slot);
  /// Sectioned: allocate a register of width code w for a slot, preferring
  /// position pos (a hint: another position if it must).
  unsigned allocSlice(unsigned slot, unsigned w, unsigned pos);
  /// Sectioned: how a width w register at pos would be placed, without
  /// placing it: 0 an owned partial row, 1 a new row, 2 neither (stall).
  unsigned planSlice(unsigned slot, unsigned w, unsigned &pos, bool allow_row) const;
  unsigned placePos(unsigned slot, const Uop &u, bool merge) const;
  /// The resources an entry needs (OI-31): bits 0-3 lane sections S0-S3,
  /// 4 RCU (R), 5-8 MIU pipes P0-P3.
  unsigned resOf(const RobEntry &r, bool copy_half) const;
  void selectSectioned();
  Issue makeIssue(unsigned slot, unsigned idx, unsigned port) const;
  void issueCopy(unsigned slot, unsigned idx, unsigned port);
  unsigned secMask(unsigned w, unsigned pos) const {
    return w == 0 ? 0xFu : w == 1 ? (3u << (pos & 2u)) : (1u << (pos & 3u));
  }
  unsigned allocPred(unsigned slot, unsigned arch);
  void freeGpr(unsigned slot, unsigned p);
  void freePred(unsigned slot, unsigned p);
  void freeCkptsFrom(unsigned slot, unsigned idx);
  void advanceEpoch(unsigned slot);
  void epochNotice(unsigned slot);
  void releaseSlot(unsigned slot);
  void ev(const char *name, unsigned warp = 0, uint64_t a = 0, uint64_t b = 0,
          uint64_t tid = 0);
  void oev(OoeEv k, unsigned warp, uint64_t b = 0, uint64_t c = 0, uint64_t tid = 0) {
    if (on_ooe_event) on_ooe_event(k, warp, b, c, tid);
  }
  void err(const char *fmt, ...);
  void count(const std::string &k, uint64_t n = 1) { counters[k] += n; }

  Config cfg_;
  uint64_t now_ = 0;
  std::vector<Slot> slot_;
  std::array<int, kWarpIds> slot_of_;
  std::array<unsigned, kWarpIds> epoch_{};

  // decode queue: shared, in arrival order
  std::deque<Uop> decq_;

  // reservation stations and the matrix
  std::vector<RsEntry> rs_;           ///< [0, rs_rcu) RCU, then MIU
  std::vector<uint8_t> cell_;         ///< N x N: bit 0 dependency
  /// Per cell, which of the producer's wakes it waits for: kLateOff for the
  /// full-latency wake, else a bypass offset from the producer's issue. A
  /// producer broadcasts one wake per distinct offset in its column, so the
  /// cell's select is log2 of that count wide (A-73's late bit, generalised).
  std::vector<uint8_t> woff_;
  std::vector<uint8_t> cok_;          ///< per cell, satisfied last cycle (EV_WAKEUP)
  static constexpr uint8_t kLateOff = 0xFF;
  uint64_t skew_ = 0;                 ///< inject_early_wake
  unsigned n_ = 0;
  uint8_t &cell(unsigned i, unsigned j) { return cell_[i * n_ + j]; }
  uint8_t cell(unsigned i, unsigned j) const { return cell_[i * n_ + j]; }
  uint64_t next_age_ = 0;
  unsigned rr_rename_ = 0, rr_select_ = 0;

  // producers of each physical register still in the RS (up to two: a
  // masked load and its copy), and whether its value has landed
  std::vector<std::array<unsigned, 2>> gprod_, pprod_;

  // free lists: bit-vectors with rotating-start allocation (OI-22)
  FreeVec gfree_, pfree_;
  std::vector<uint8_t> gowner_, powner_;      ///< slot + 1, 0 = free
  std::vector<uint8_t> gever_;                ///< ever allocated (reg_reuse)
  // Sectioned registers: a name is row * kPos_ + position (kPos_ 1 when not
  // sectioned, so a name is a row). A row is owned by one tier-1 slot while
  // any of its sections is live (OI-29); gfree_ holds the wholly free rows.
  unsigned kPos_ = 1;
  std::vector<uint8_t> gw_;                   ///< name -> width code
  std::vector<uint8_t> rowOwner_, rowSec_;    ///< row -> slot + 1; live sections
public:
  unsigned nameRow(unsigned n) const { return n / kPos_; }
  unsigned namePos(unsigned n) const { return n % kPos_; }
  bool isZeroName(unsigned n) const { return n / kPos_ == cfg_.phys_zero; }
  unsigned zeroName() const { return cfg_.phys_zero * kPos_; }
  unsigned nameWidth(unsigned n) const { return n < gw_.size() ? gw_[n] : 0; }
  /// The sections a register occupies; none for the zero register.
  unsigned sectionsOf(unsigned n) const {
    if (isZeroName(n)) return 0;
    return cfg_.sectioned ? secMask(nameWidth(n), namePos(n)) : 0xFu;
  }
private:

  // inputs not yet taken
  std::vector<Done> dones_;
  std::vector<Cmpl> cmpls_;
  std::vector<Alloc> allocs_;
  std::vector<unsigned> demotes_;
  uint32_t released_ = 0;
  bool kill_pending_ = false;
  uint32_t kill_mask_ = 0;
  unsigned kill_epoch_ = 0;

  // outbound queues on rate-limited channels
  std::deque<Redirect> redirects_;
  uint64_t free_mask_ = 0;
  std::deque<Commit> commits_;
  std::deque<Memop> discards_;       ///< bulk discards, waiting for a slot
  // granted last cycle, in the payload-read stage (payload_stages = 1)
  bool cancel_live_ = false;          ///< a transitive cancel still spreading
  unsigned cancel_depth_ = 0;
  std::vector<Issue> held_issues_;
  std::vector<Memop> held_memops_;
};

} // namespace ooe
} // namespace ccv
#endif // CCV_OOE_CORE_H
