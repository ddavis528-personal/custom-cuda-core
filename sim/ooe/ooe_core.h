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

#include <algorithm>
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
  /// The free lists' candidate buffer and refill banks (OA's response
  /// OI-38); fl_buf 0 is the earlier rotating-pointer list. To be raised as
  /// parameters if they stay (TI's response of 2026-10-16).
  unsigned fl_buf = 8;
  unsigned fl_banks = 4;
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
  /// The decode queue's credit return: an entry freed in a cycle takes no
  /// arrival until the next, so this cycle's arrivals see it still held.
  /// On (DA's response OI-39), because ooe_decq fits its stage only so.
  bool decq_late_credit = true;
  /// A squash's flush of the decode queue is registered and applied an edge
  /// late (ooe_decq, OA's response OI-58): the flushed entries hold their
  /// credits one cycle more.
  bool decq_flush_late = true;
  /// Rename's take is registered in the decode queue and popped an edge
  /// late: the taken entries hold their credits one cycle more. On (OA-21,
  /// DA 2026-10-20), because ooe_decq fits its stage only so.
  bool decq_take_late = true;
  /// How a go that lets several warps take in a cycle (rename_one_warp 0,
  /// or 2 and up) keeps their sum within the shared credits (RS room per
  /// class, GPR and predicate names), each warp's fits being formed alone
  /// (OA-21). 0: exact, the model's running credits. 1: each warp's fits
  /// against the credits less the rename width. 2: one warp takes while any
  /// shared credit is below the rename width (a registered bit), several
  /// otherwise. 3: OA-22's registered go, 2 as the RTL can build it from
  /// registered state alone: rename sees this cycle's RS frees and ROB
  /// retirements a cycle late wherever they could matter. Short is tested
  /// on the credits without them, RS RCU against twice the width when a
  /// candidate head uop is a copy; a short cycle's warp takes without
  /// them; and a warp's fits count its ROB retirements a cycle late. 2
  /// (OA-21, DA 2026-10-20: rename's interleaved go forms each warp's fits
  /// alone, and its exact forms do not fit a stage). The default is 3
  /// (OA-22, OA 2026-10-20: the go the RTL builds).
  unsigned fits_conservative = 3;
  /// OA's response OI-65 (a): rename's per-warp fits are registered a cycle
  /// ahead, for every take the warp may make, so they see the decode
  /// queue and the credits as the cycle before left them. A uop is taken
  /// no sooner than the second cycle after it arrives, and frees (ROB
  /// retirements; RS frees in the short test) reach the fits two cycles
  /// late. Off until OA settles OI-65; the sweep measures it. 2, OA's
  /// (a2): the held heads' fits as 1, but a refill (uops arriving into a
  /// slot whose held heads do not fill the window) is taken at once and
  /// re-checked in Rename 1, a failing tail waiting in the skid, which
  /// costs what not taking it does; ROB retirements a cycle late (ret_n
  /// reaches the fits in time); the short test on the last cycle's shared
  /// credits against twice the width (RCU three times with a copy in a
  /// head), and a short cycle's warp against the shared credits less it.
  /// 3, OA's per-warp shares (OI-65): as 2, but no short path: each cycle
  /// every shared credit (as registered, without this cycle's frees) is
  /// split equally among the warps with a head, the remainder to the first
  /// in rotation, and each warp admits against its own share. 4, OA's
  /// stateful shares: each warp keeps its share of each shared credit, its
  /// own takes lower it; frees, and the shares of warps four cycles without
  /// a head, form a pool split each cycle equally among the warps with a
  /// head (the remainder to the first in rotation); the shares and the pool
  /// sum to the credit, as registered (checked). 5: as 3, the remainder
  /// given to no warp (the split's add gone; test/ooe/probes/share_probe.sv).
  /// 6: as 3, as the RTL registers it: a warp admits against an allowance
  /// split a cycle ahead, with the fits, from the credit no allowance then
  /// holds, less at most the width (what a cycle can take of any credit),
  /// so no take counts twice; under one warp each warp's allowance is that
  /// whole pool. The credits are rename's counters (renCredits).
  /// 7: OA's stateful shares as the RTL registers them: each warp keeps
  /// its share of each credit, its takes lower it; the credit no share
  /// holds (frees, returns) is split each cycle among the warps with a
  /// head into a register, and reaches a warp's fits a cycle after that, so
  /// a split is usable two cycles on; a warp share_return cycles without a
  /// take returns its share (decided on its registered takes, the fits at
  /// offset 0 formed without it). The credits are rename's counters.
  unsigned fits_stale = 6;
  /// Whether RS allocation may take an entry freed in the same cycle
  /// (same-edge reuse, DA's response OI-39). With confirmation inside
  /// ooe_rs (OI-45) the free reaches allocation from its own flops at 25.7
  /// NGD, over the stage, so 0 allocates only entries free at the cycle's
  /// start. Rename's counters (fits_stale 6) never count a free in its own
  /// cycle, so only which entry is taken changes.
  bool rs_same_edge = false;
  unsigned share_return = 2;   ///< fits_stale 7: cycles without a take before a warp returns its share
  /// fits_stale 2 to 7: a uop that arrived after the last cycle's start,
  /// which the registered fits do not hold, is taken (the refill, OA's (a2):
  /// re-checked in Rename 1 against the state as it stands). false: it
  /// waits until the fits hold it, as the RTL's fits with no arrival term
  /// (test/ooe/probes/sharefits_probe.sv, AR 0) do.
  bool take_young = false;
  /// A retirement's ROB slot counts in rename's room in its own cycle (the
  /// fits' ret_n term: test/ooe/probes/fitsk2_probe.sv, RET 1). false:
  /// under fits_conservative 3 and the shares, a cycle late.
  bool ret_now = true;
  /// A copy's request sees its sources' confirmation a cycle late, as the
  /// composed RTL does (OI-45: ooe_rs decides a confirmation while
  /// ooe_sched is a model cycle on).
  bool copy_conf_late = true;
  /// The request register's enable also takes the allocation lead: a row
  /// written at an edge enters at the next (ooe_sched, OI-45 (a)).
  bool req_alloc_lead = true;
  /// ooe_sched's request register sees ooe_rs's rows and ooe_wake's
  /// issued bits two cycles late, as the composed RTL does (OI-45: both
  /// take the grant register an edge after ooe_sched, and a row written at
  /// an edge reaches the register at the next): a row freed or written in
  /// the last two cycles requests on its state before them, and the
  /// allocation lead comes with the row.
  bool req_rows_late = true;
  /// The ready register reads ooe_wake's lead lines, which drop an L1
  /// load's wake two cycles before its miss when no completion hint has
  /// come (OA-23): a spec load whose hint has not come is not ready from
  /// its miss cycle on. The environment sends Core::hint.
  bool miss_lead = true;
  /// The ready register sees a source's replay two cycles late, as the
  /// composed RTL does (OI-45: ooe_wake takes the replay while ooe_sched is
  /// a cycle on, and its lead lines had risen on the timer it replaced):
  /// until then it reads that timer.
  bool ready_rep_late = true;
  /// When rename sees an RS entry or ROB slot freed this cycle. 0: in the
  /// same cycle, every free (same-edge reuse, the ideal). 1: a cycle late,
  /// every free (OA's stage-boundary item 4, rename's own credits; not
  /// accepted, DA 2026-10-19). 2: TI-19 as OA answers it: a confirmation's
  /// RS free and a retirement's ROB free count in their cycle, the RS's up
  /// to ren_free_cap per class (its thermometer), and the rest, past the cap
  /// or from a squash, kill or landing, a cycle late. 2 at cap 4 is the
  /// design (accepted by Daniel, 2026-10-19).
  unsigned ren_credit = 2;
  unsigned ren_free_cap = 4;
  /// Select reads a registered ready (OA's response OI-51), as ooe_sched
  /// does: a row is ready at select if its lines say so now, or said so at
  /// the end of the last cycle for this one. Rises are unchanged (every
  /// wake rises a cycle early into the register); a drop (a producer
  /// returned to Waiting) reaches select a cycle late, so an entry may be
  /// granted on a stale bit and is returned by the next hop (OA-17).
  /// false: select reads the lines as they stand.
  bool ready_reg = true;
  /// Select's fallback pick on the lane sections (OA's response IS-9,
  /// pickResources): 0 none, 1 section-only (the design: section-plus-half
  /// measured 26.8 NGD in ooe_select, over the stage; section-only 24.3),
  /// 2 section-plus-half.
  unsigned pick_fallback = 1;
  /// Select's request register (OA's response OI-53): one bit per entry,
  /// written at an earlier cycle's end, of the terms that need only earlier
  /// state: not issued, warp active, and a copy's sources confirmed. Its
  /// enable (ooe_sched's, from its own flops, CG-5) is a grant last cycle
  /// and a flop of "the register differs from its next value and this edge
  /// does not capture it", so a change
  /// other than a grant is captured one edge late. Valid and past rename's
  /// stages (ooe_rs's bit), the matrix's ready (ready_reg) and a memop's
  /// terms (confirmation, order, its copy's issue) stay live. false: every
  /// term live.
  bool req_reg = true;
  /// KNOB (OI-56, OA's measurement): a branch ends its rename group, so its
  /// checkpoint is the RAT's state at the next edge. 0 off; 1 the branch's
  /// slot renames nothing more that cycle; 2 nothing renames after it.
  unsigned branch_ends_group = 0;
  /// KNOB (OA's responses OI-63): rename takes a prefix from each of up to
  /// this many warps a cycle, in the rotating order, each warp's before the
  /// next's (the RTL's go over rename's registered per-slot fits: 1, or 2
  /// with a second pick). 0: uop by uop, warps interleaved round robin.
  unsigned rename_one_warp = 0;
  /// CCV_FOOT_MIN[bypass_group] in sections, from the generated
  /// CCV_P_FOOT_MIN_* (TI's response IS-7), so a change to a parameter
  /// reaches the model: integer, FP (provisional, IS-7), address
  /// calculation (in MIU pipes), SFU; warp-collective and predicate 0 (R
  /// only). Groups 6 and 7 are spare and take the integer minimum.
  std::array<unsigned, kGroups> foot_min = {
      ccv::prov::kFootMinInt, ccv::prov::kFootMinFp, ccv::prov::kFootMinAddr, ccv::prov::kFootMinSfu,
      ccv::prov::kFootMinCollective, ccv::prov::kFootMinPred, ccv::prov::kFootMinInt, ccv::prov::kFootMinInt};
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

  // -- fault injection: the negative controls the core itself must carry ------
  bool inject_free_new = false;   ///< retire frees the new mapping (free-new)
  bool inject_shallow_cancel = false;  ///< cancel stops after one hop (V-15)
  bool inject_early_wake = false;      ///< fixed-latency wakes a cycle early
  bool inject_complete_early = false;  ///< complete before RS entries free (V-58)
  bool inject_narrow_footprint = false; ///< a lane op claims only its lowest section (OI-30)
  /// Sectioned select grants one more lane op a cycle onto sections already
  /// held, unchecked (V-60): the kernels' no-resource-cap control, which RCU
  /// must refuse.
  bool inject_double_grant = false;
  /// The ready register's enable takes no allocation lead (V-73's control):
  /// a row allocated into a quiet machine is never captured as ready.
  bool inject_no_alloc_lead = false;
  /// No F-BARRIER check at dispatch: a barrier past its CTA's count goes to
  /// SYU (testBarrierFault's control).
  bool inject_no_bar_fault = false;
  /// No F-WIDTH check at dispatch (testWidthFault's control).
  bool inject_no_width_fault = false;
  /// No F-FORMAT check at dispatch (testFormatFault's control).
  bool inject_no_format_fault = false;
  /// The fault-address register takes every faulting completion, not only
  /// an older one (V-74's control).
  bool inject_fa_youngest = false;
  /// The ready register captures a stop's or a miss's change one edge late
  /// (OI-54's control): a producer re-granted inside the stale window lets
  /// a dependant confirm on a result it read too early.
  bool inject_late_event = false;
  /// AR-21's controls: an atomic's read issues away from its warp's head
  /// (V-69); its consumers wake on its first write, not its last (V-71); a
  /// demote is taken mid-atomic (V-70).
  bool inject_atom_off_head = false;
  /// The PRF's read ports (DA's response OA-6: 16 read, 8 write; no
  /// parameter yet). Select keeps a cycle's operand reads within the read
  /// ports a migration leaves (TI-21: a demote's 17 reads hold one for 17
  /// cycles). 0: no limit.
  unsigned prf_read_ports = 16;
  /// TI-21's fixes for a stalled warp's RS room (OA's rev 130), off until
  /// measured: (1) stall-aware shares, a warp whose oldest RS entry waits
  /// on a memory miss past the L1 window gets no share of RS room (one
  /// registered bit per warp); (2) a per-warp cap on each class's entries
  /// (0: none; rs_warp_cap stays the cap over both).
  bool share_stall_aware = false;
  /// TI-24's control: a demotion's rewind beats youngest first.
  bool inject_rewind_order = false;
  unsigned rs_warp_cap_rcu = 0, rs_warp_cap_miu = 0;
  bool inject_atom_early_wake = false;
  bool inject_atom_demote_mid = false;
  /// PF-23 (OA's rev 160, AR's rev 106): a demotion's discard takes its
  /// warp's outstanding loads, so drained waits for their replay
  /// completions, not their fills. Off: the drain waits for the fills.
  bool replay_drain = true;
  /// PF-23's control: drained waits for no squashed load at MIU.
  bool inject_drain_early = false;
  /// TI-25's controls: a demote of a warp whose exit retired is not
  /// refused; a restore drops the parked layout (32 bits at position 0).
  bool inject_no_refuse = false;
  bool inject_park_layout_lost = false;

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
  /// A fault found before OOE, from ccv_dec_ooe_uop's cause: 1 F-FETCH or
  /// 2 F-ILLEGAL, else 0 (IS-16). The uop is a no-op that faults at its head.
  unsigned cause = 0;
  /// F-FORMAT's inputs (OI-57; TI's 57048d7): bit i set where the op's
  /// format code is reserved at width code i, and the operand whose
  /// committed width selects the bit (0-2 src0-src2, 3 the destination).
  unsigned fmt_rsv = 0, fmt_opnd = 0;
  /// The destination's element width, from the committed chwidth table:
  /// 0 32-bit, 1 16-bit, 2 8-bit, 3 4-bit (sectioned; a 4-bit register takes
  /// an 8-bit section, OI-29). Sources carry their own in their names.
  unsigned w = 0;
  bool backward = false;             ///< a branch whose target is behind it (OA-14)
  UopShape shape;
};

struct Done {           ///< ccv_rcu_ooe_done
  unsigned rob_tag = 0;
  bool branch_taken = false;
  uint32_t branch_mask = 0;
};
struct Cmpl {           ///< ccv_miu_ooe_cmpl
  unsigned rob_tag = 0, status = 0, cause = 0;
  unsigned rs_idx = 0;  ///< the memop's RS entry, echoed (OA-23): an atomic's A1 or A3
  uint32_t lane_mask = 0;
  uint64_t address = 0;
  bool mlc_miss = false;
  bool more = false;    ///< an atomic's A3: lanes remain, re-issue the three steps (AR-21)
};
/// Completion status (ccv_miu_ooe_cmpl's doc: 0 complete, 1 fault, 2 replay).
enum : unsigned { kCmplOk = 0, kCmplFault = 1, kCmplReplay = 2 };
enum : unsigned { kAllocFree = 0, kAllocLaunch = 1, kAllocRestoreAlloc = 2,
                  kAllocRestoreActivate = 3 };
struct Alloc {          ///< ccv_rau_ooe_alloc
  unsigned warp = 0, slot = 0, op = 0;
  uint32_t ctaid = 0, warp_in_cta = 0;
  unsigned barrier_count = 0;      ///< launch and restore-allocate: the CTA's barriers, 0 to 16 (IS-16)
};
/// Fault causes (CCV_W_FAULT_CAUSE; ISA v1.9 section 12's table order).
enum : unsigned { kCauseWidth = 3, kCauseFormat = 4, kCauseBarrier = 9 };
/// mem_op codes OOE reads or generates (OA's six, TI's a4fa218): an
/// atomic's read (A1) and write (A3) are OOE's alone, as 0xF is (V-72).
enum : unsigned { kMemOpAtomicRead = 2, kMemOpAtomicWrite = 3, kMemOpFence = 0xE };

// ---- decoded outputs ----------------------------------------------------------------

/// One ready requester of the per-resource select: its resource mask and
/// its age (smaller is older).
struct PickReq {
  unsigned res = 0;
  uint64_t age = 0;
};
/// The per-resource select (OI-31, V-60), the reference the RTL's
/// ooe_pick is checked against: each resource grants its oldest
/// requester, and a requester issues only if it wins every resource it
/// names. Returns which requesters issue; *lost counts those that won some
/// resources but not all (in that pick, before any fallback).
///
/// The fallback (OA's response IS-9), on resources 0-3, the lane sections:
/// a section whose winner did not issue grants instead its oldest
/// requester that names that section alone (1); and with 2, an aligned
/// half (sections 0-1, 2-3) whose sections both fell through grants its
/// oldest half-footprint requester, when that is the oldest of the half's
/// pair and single-section requesters. Every pick is a parallel
/// oldest-of-N over the same ages, so the RTL needs no second pass.
std::vector<bool> pickResources(const std::vector<PickReq> &req, unsigned nres, unsigned *lost = nullptr,
                                unsigned fallback = 0);

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
  unsigned rs_idx = 0;           ///< its RS entry, which MIU echoes (OA-23); 0 on a discard
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
  /// A demotion's rewind beat (TI-24 (3), OA's revs 150-151; TI's e95a6a8):
  /// with epoch_only, FET sets the PCs of the lanes in taken_mask to
  /// target_pc, each the oldest unretired uop of those lanes.
  bool rewind = false;
};
struct Status {         ///< ccv_ooe_rau_status
  unsigned warp = 0;
  bool fault_taken = false, stalled = false, mlc_miss_seen = false;
  uint32_t retired_since_restore = 0;
  /// A level (OA's rev 149): the warp's exit has retired and it holds no
  /// ROB entry and no memop at MIU, until RAU frees the slot. Sent once,
  /// as it rises.
  bool exited = false;
};
struct Fault {          ///< ccv_ooe_cru_fault
  unsigned warp = 0, cause = 0, cta_slot = 0;
  uint64_t pc = 0, address = 0;
  uint32_t lane_mask = 0;
};
struct Drained {        ///< ccv_ooe_rau_drained
  unsigned warp = 0;
  uint64_t resume_pc = 0;
  bool refused = false;  ///< the warp's exit retired before the demote (TI-25)
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

/// A free list (OI-22; structure OA's response OI-38). A bit per entry, set
/// while it is free. With a candidate buffer (cap > 0, the default) the
/// only source of allocations is a buffer of up to `cap` free entries, in
/// order; alloc() takes its head. At each clock edge the buffer is refilled
/// from `banks` interleaved banks (entry mod banks), in a rotating bank
/// order: each bank appends at most one entry, the first free one not
/// already buffered at or after its own rotating pointer, while there is
/// room. A free reaches the free bits at the next edge, so it is visible
/// to refill a cycle after it is freed and to allocation the cycle after
/// that. Buffered entries stay free in the bits, so the admission floors
/// (ready()) count them. An allocation clears its entry's free bit at the
/// edge, but leaves the buffer a cycle later (OA's response OI-52): the
/// free list registers each cycle's take, and pops that many at the next
/// edge, so its buffer's clock enable comes from its own flops. Meanwhile
/// those entries, in transit, sit at the buffer's head, and allocation
/// takes the entries behind them. With cap 0 it is the earlier structure: the first
/// free entry at or after one rotating pointer, a free allocatable from the
/// next cycle. ooe_freelist builds the buffered form.
class FreeVec {
public:
  void reset(unsigned n, unsigned cap = 0, unsigned banks = 1) {
    bit_.assign(n, 1);
    pend_.assign(n, 0);
    inbuf_.assign(n, 0);
    buf_.clear();
    transit_ = took_ = 0;
    ready_ = n;
    npend_ = 0;
    ptr_ = 0;
    cap_ = cap;
    banks_ = cap ? banks : 1;
    bptr_.assign(banks_, 0);
    rot_ = 0;
    edge_ = Edge{buf_, bit_, bptr_, rot_};
  }
  /// Free entries, including those freed this cycle.
  size_t size() const { return ready_ + npend_; }
  /// Free entries the admission floors count: all but this cycle's frees.
  size_t ready() const { return ready_; }
  /// Entries allocation can take this cycle: the buffer behind the entries
  /// in transit, or the free bits.
  size_t avail() const { return cap_ ? buf_.size() - transit_ - took_ : ready_; }
  bool empty() const { return avail() == 0; }
  bool has(unsigned p) const { return bit_[p] || pend_[p]; }
  /// Taken since the last clock(): ooe_freelist clears a taken entry's free
  /// bit at the next edge, so a free of it now would be lost (OI-58).
  bool takenNow(unsigned p) const { return std::find(allocs_.begin(), allocs_.end(), p) != allocs_.end(); }
  unsigned alloc() {
    const unsigned n = unsigned(bit_.size());
    if (cap_) {
      if (!avail()) return n;   // caller checked avail()
      const unsigned p = buf_[transit_ + took_++];
      take(p);
      return p;
    }
    for (unsigned i = 0; i != n; ++i) {
      const unsigned p = (ptr_ + i) % n;
      if (!bit_[p]) continue;
      take(p);
      ptr_ = (p + 1) % n;
      return p;
    }
    return n;   // caller checked avail()
  }
  /// False when the entry is already free (a double free).
  bool free(unsigned p) {
    if (has(p)) return false;
    pend_[p] = 1;
    ++npend_;
    frees_.push_back(p);
    return true;
  }
  /// The allocations, in order, and frees since the last clock(): one clock
  /// edge's worth, including those made by inputs between cycles
  /// (ooe_freelist's testbench drives the RTL with them).
  const std::vector<unsigned> &cycleAllocs() const { return allocs_; }
  const std::vector<unsigned> &cycleFrees() const { return frees_; }
  unsigned pointer() const { return ptr_; }
  unsigned capacity() const { return unsigned(bit_.size()); }
  unsigned bufferCap() const { return cap_; }
  unsigned banks() const { return banks_; }
  /// The buffer, head first, the entries in transit included; how many
  /// those are (last cycle's allocations); each bank's pointer (an index
  /// within the bank); the bank refill starts with next edge.
  const std::deque<unsigned> &buffer() const { return buf_; }
  unsigned inTransit() const { return transit_; }
  unsigned bankPointer(unsigned b) const { return bptr_[b]; }
  unsigned rotation() const { return rot_; }
  bool bit(unsigned p) const { return bit_[p]; }
  /// The clock edge: refill the buffer from the free bits as they stand,
  /// then this cycle's frees join the bits.
  void clock() {
    allocs_.clear();
    frees_.clear();
    if (cap_) {
      // Last cycle's allocations leave the buffer; this cycle's stay, in
      // transit, until the next edge.
      for (unsigned i = 0; i != transit_; ++i) {
        inbuf_[buf_.front()] = 0;
        buf_.pop_front();
      }
      transit_ = took_;
      took_ = 0;
      refill();
    }
    if (npend_) {
      for (size_t p = 0; p != pend_.size(); ++p)
        if (pend_[p]) { pend_[p] = 0; bit_[p] = 1; }
      ready_ += npend_;
      npend_ = 0;
    }
    edge_.buf = buf_;
    edge_.bits = bit_;
    edge_.bptr = bptr_;
    edge_.rot = rot_;
    edge_.transit = transit_;
  }
  /// The state just after the last clock edge, before any allocation since:
  /// what ooe_freelist holds after the same edge (its testbench compares).
  struct Edge {
    std::deque<unsigned> buf;
    std::vector<uint8_t> bits;
    std::vector<unsigned> bptr;
    unsigned rot = 0;
    unsigned transit = 0;
  };
  const Edge &lastEdge() const { return edge_; }

private:
  void take(unsigned p) {
    bit_[p] = 0;
    --ready_;
    allocs_.push_back(p);
  }
  void refill() {
    const unsigned n = unsigned(bit_.size()), per = n / banks_;
    for (unsigned j = 0; j != banks_ && buf_.size() < cap_; ++j) {
      const unsigned b = (rot_ + j) % banks_;
      for (unsigned i = 0; i != per; ++i) {
        const unsigned q = (bptr_[b] + i) % per, p = q * banks_ + b;
        if (!bit_[p] || inbuf_[p]) continue;
        buf_.push_back(p);
        inbuf_[p] = 1;
        bptr_[b] = (q + 1) % per;
        break;
      }
    }
    rot_ = (rot_ + 1) % banks_;
  }

  std::vector<uint8_t> bit_, pend_, inbuf_;
  std::deque<unsigned> buf_;
  std::vector<unsigned> allocs_, frees_, bptr_;
  size_t ready_ = 0, npend_ = 0;
  unsigned ptr_ = 0, cap_ = 0, banks_ = 1, rot_ = 0;
  unsigned transit_ = 0, took_ = 0;   // last cycle's allocations, and this cycle's
  Edge edge_;
};

class Core {
public:
  explicit Core(const Config &cfg);

  // -- inputs. Completions and RAU's messages before cycle(), and they take
  // effect in it; uops after it (the decode queue is written behind rename).
  /// Can the decode queue take a uop of this warp? (Credit: the adapter
  /// leaves a uop in the channel while this is false.)
  bool canAccept(unsigned warp) const;
  /// Decode-queue entries the credit check counts as held: the queue, plus
  /// under decq_late_credit those freed this cycle.
  unsigned decqHeld() const {
    return unsigned(decq_.size()) + (cfg_.decq_late_credit ? decq_freed_ : 0) +
           (cfg_.decq_flush_late ? decq_flush_prev_ : 0) + (cfg_.decq_take_late ? decq_take_prev_ : 0);
  }
  /// The adapter left a uop of this warp in the channel because canAccept
  /// said no: count which limit held it (the decode-queue events).
  void noteRefused(unsigned warp);
  void uop(const Uop &u);
  void done(const Done &d);
  void cmpl(const Cmpl &c);
  /// OA-23's completion hint: the completion for rob_tag comes two cycles
  /// from now (read only under Config::miss_lead).
  void hint(unsigned rob_tag);
  uint64_t now() const { return now_; }   ///< the last cycle run
  bool reqStopQ() const { return req_stop_q_; }   ///< req_rows_late's stop lead (benches)
  void alloc(const Alloc &a);
  void demote(unsigned warp);
  /// The PRF read ports a migration holds this cycle (RCU's, TI-21): set
  /// before cycle(), as the other inputs are.
  void migrationReads(unsigned n) { mig_reads_ = n; }
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
  /// RS entries slot holds in a class (TI-21's measure).
  unsigned rsHeldIn(unsigned slot, bool miu) const {
    unsigned n = 0;
    for (const RsEntry &x : rs_) n += x.valid && x.slot == slot && (x.cls == RsCls::kMiu) == miu;
    return n;
  }
  /// A slot's committed map (the demotion map's source).
  std::array<unsigned, kArchGprs> committedGprs(unsigned slot) const { return slot_[slot].crat; }
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
    // An atomic (AR-21): A1 is rs_main, an exclusive read into T; A2 the
    // lane op, T and the operands into N; A3 the write of N and the release.
    // T is pnew for atom (rd's new name) and a temporary for red; N is
    // always one. Both free at retire.
    bool atomic = false;
    unsigned rs_a2 = kNoEntry, rs_a3 = kNoEntry;
    unsigned ptmp_t = kNoEntry, ptmp_n = kNoEntry;   ///< temporaries, kNoEntry when none
    unsigned atom_t = 0;               ///< T: pnew or ptmp_t
    bool atom_started = false;         ///< its first A1 has issued
    bool atom_pass = false;            ///< a pass in flight: A1 issued, A3 not complete
    bool atom_final = false;           ///< the last pass's A3 completed (more = 0), or A1 faulted
    unsigned atom_passes = 0;
    uint64_t atom_pass_at = 0;         ///< this pass's A1 issue (hold cycles)
    uint64_t atom_ready_at = 0;        ///< A1 first issuable but not at the head (head wait)
    bool atom_waiting = false;
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
    bool hinted = false;           ///< its completion's hint came (OA-23; miss_lead)
    /// ready_rep_late: its last replay's cycle and the timer it replaced.
    uint64_t rep_at = ~uint64_t(0), rep_issue_at = 0, rep_late_at = 0;
    bool rep_late = false, rep_on_completion = false;
    bool on_completion = false;    ///< wakes on its completion, not a time
    uint64_t late_at = 0;
    bool late = false;             ///< the full-latency wake (bypass wakes are per cell)
    bool confirmed = false;        ///< result can no longer be cancelled
    bool msd = false;              ///< missed its L1 slot, until its completion (OI-50's msd)
    bool msd_end = false;          ///< its completion came: msd clears after this cycle's hop
    bool stale = false;            ///< granted on a stale ready bit (OI-51), until its next replay or issue
    bool ever_issued = false;
    unsigned replays = 0;
    bool ready_seen = false;       ///< for EV_WAKEUP / ready-not-selected
    uint64_t ready_since = 0;      ///< first cycle a memop's row was ready
    uint64_t eligible_at = 0;      ///< first cycle select may take it (rename's stages)
    unsigned res = 0;              ///< sectioned: the resources it needs (resOf)
    uint8_t atom = 0;              ///< an atomic's step: 1 A1, 2 A2, 3 A3 (AR-21); 0 none
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
    unsigned bar_count = 0;                   ///< the CTA's barriers, from launch or restore-allocate (IS-16)
    /// The committed width per architectural GPR (OA's response OI-57): a
    /// width code (0 32, 1 16, 2 8, 3 4 bits), written when a chwidth
    /// retires, 32 at launch and at restore-allocate. F-WIDTH reads it.
    std::array<uint8_t, 16> cw{};
    /// V-74 (OA's response IS-16): the oldest unsquashed faulting memop's
    /// address and ROB index, one register per warp, read at the head.
    bool fa_valid = false;
    unsigned fa_idx = 0;
    uint64_t fa_addr = 0;
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
    unsigned rewind_pending = 0;              ///< a demotion's beats not yet sent (TI-24 (3))
    bool exit_retired = false, exited_sent = false;   ///< OA's rev 149
    unsigned kill_epoch = 0;
    uint64_t resume_pc = 0;
    /// Restore-allocate in progress (OI-41): registers still to take, and
    /// the cycle it was accepted (V-64).
    bool restoring = false;
    unsigned restore_gpr = 0, restore_pred = 0;
    uint64_t restore_at = 0;
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
  /// The row's lines as they will stand next cycle, from the state now:
  /// what the ready register holds then (OI-51).
  bool rowReadyNext(unsigned i) const { return rowReadyAt(i, now_ + 1); }
  /// The row's lines at cycle t by the producers' timers, from the state now.
  bool rowReadyAt(unsigned i, uint64_t t) const;
  /// A memop's program order in its warp (OI-15; OA-13 when loads pass loads).
  bool memopOrderOk(const Slot &s, const RobEntry &r) const;
  /// What select reads: the ready register (OI-51), or the lines now.
  bool rowReadySel(unsigned i) const { return cfg_.ready_reg ? bool(ready_q_[i]) : rowReady(i); }
  /// The request register's next value for entry e (req_reg).
  bool requestNext(unsigned e) const;
  void requestRegister();
  /// Producer j's line k at cycle t by its timers alone, from the state
  /// now: what ooe_wake's timers say ahead of time.
  bool lineAt(unsigned j, unsigned k, uint64_t t) const;
  /// The ready register's enable for the edge ending this cycle and the
  /// lead it takes for the next (OA's response OI-53, V-73).
  void readyRegister();
  bool rowConfirmed(unsigned i) const;
  void doIssue(unsigned e, unsigned port, bool with_copy, unsigned copy_port);
  void setWakes(unsigned e);
  void wake(unsigned e);
  void emitWakeups();
  void cancel(unsigned e);
  bool cancelHop();
  void confirmPass();
  bool predHold(unsigned slot, const RobEntry &r) const;
  void complete(unsigned slot, unsigned idx);
  void resolveBranch(unsigned slot, unsigned idx);
  /// discard_all: send the bulk discard whatever reached MIU (a demotion's,
  /// TI-21), which MIU's replay drain and ready report key on.
  void squashAfter(unsigned slot, int keep_idx, bool to_retirement, bool discard_all = false);
  void releaseEntry(unsigned slot, unsigned idx);
  bool outstanding(const RobEntry &r) const;
  bool gprAllowed(unsigned slot, unsigned n) const;
  bool predAllowed(unsigned slot, unsigned n) const;
  unsigned allocGpr(unsigned slot);
  /// Sectioned: allocate a register of width code w for a slot, preferring
  /// position pos (a hint: another position if it must).
  unsigned allocSlice(unsigned slot, unsigned w, unsigned pos, bool own_row = false);
  /// Sectioned: how a width w register at pos would be placed, without
  /// placing it: 0 an owned partial row, 1 a new row, 2 neither (stall).
  unsigned planSlice(unsigned slot, unsigned w, unsigned &pos, bool allow_row) const;
  unsigned placePos(unsigned slot, const Uop &u, bool merge) const;
  /// The resources an entry needs (OI-31): bits 0-3 lane sections S0-S3,
  /// 4 RCU (R), 5-8 MIU pipes P0-P3.
  unsigned resOf(const RobEntry &r, bool copy_half, bool widen = true) const;
  /// An RS entry's resources: resOf for its ROB entry, or an atomic step's.
  unsigned resEntry(unsigned e, bool widen = true) const;
  void selectSectioned();
  /// step: an atomic's (RsEntry::atom), 0 for any other entry.
  Issue makeIssue(unsigned slot, unsigned idx, unsigned port, unsigned step = 0) const;
  // -- atomics (AR-21) -----------------------------------------------------------------
  /// May entry e issue as an atomic's step? A1 only at its warp's head (V-69).
  bool atomIssueOk(unsigned e) const;
  /// An entry of a killed warp's atomic pass in flight still issues, so the
  /// pass writes and releases its hold (V-70).
  bool atomFinishing(const RsEntry &x) const;
  /// The head is an atomic in progress: no demotion trigger, and a demote
  /// waits (V-70).
  bool atomAtHead(unsigned slot) const;
  void atomCmpl(unsigned slot, unsigned idx, const Cmpl &c);
  /// Return the three steps to Waiting for the next pass.
  void atomNextPass(RobEntry &r);
  /// Free whatever RS entries an atomic still holds.
  void atomFree(RobEntry &r);
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
  std::deque<uint64_t> decq_seq_;           ///< each queued uop's arrival number
  uint64_t next_decq_seq_ = 0;
  uint64_t decq_seq_at_ = 0, decq_seq_prev_ = 0;   ///< next_decq_seq_ at this cycle's start, the last's (fits_stale)
  uint32_t decq_flushed_ = 0;               ///< slots a squash flushed this cycle
public:
  /// What reached each RS entry's wake timer this cycle, for ooe_wake
  /// (test/ooe/wake_tb.cpp): its grant with the timer kind and latency
  /// class, a done or completion for its ROB entry (cmpl 2: one past L1,
  /// which sets the late line's timer), a stop (a replay clearing issued,
  /// or the entry freed), the L1 miss its timer found, and
  /// the results confirmed on the timer's word (its full-latency wake, not
  /// speculative). Observation only: nothing in the model reads it.
  enum : uint8_t { kWakeTimed = 0, kWakeCopy = 1, kWakeSpec = 2, kWakeMem = 3 };
  struct WakeLog {
    std::vector<uint8_t> grant, kind, cls, done, cmpl, stop, miss, fin;
    /// ooe_confirm's (test/ooe/confirm_tb.cpp): the cancel hop's inputs as
    /// it ran (each entry issued and unconfirmed, the dependency bits) and
    /// the entries it returned to Waiting; confirmation's inputs (issued and
    /// unconfirmed, the result final, a destination, the dependency bits)
    /// and the entries it confirmed. hop_live: a hop ran this cycle.
    std::vector<uint8_t> replay, conf, hop_iss, hop_dep, hop_msd, cf_iss, cf_fin, cf_prod, cf_dep;
    bool hop_live = false;
    /// ooe_rs's (test/ooe/rs_tb.cpp): the RS entries allocated this cycle,
    /// in allocation order, and those freed.
    std::vector<unsigned> ralloc;
    std::vector<uint8_t> rfree;
    /// ooe_select's (test/ooe/select_tb.cpp), as the sectioned select saw
    /// them: each entry's valid, issued, eligible (rename's stages past),
    /// warp active, ready and sources-confirmed bits, its slot, footprint
    /// (resOf), whether it is a copy, and a memop's live copy (sel_chas,
    /// sel_cidx); the resources and warps a bulk discard took; then the
    /// candidates and the grants. sel_live: the sectioned select ran.
    std::vector<uint8_t> sel_valid, sel_elig, sel_iss, sel_rq, sel_gnt, sel_ready, sel_conf, sel_slot, sel_copy,
        sel_chas, sel_cand, sel_grant;
    std::vector<unsigned> sel_res, sel_cidx;
    unsigned sel_busy = 0, sel_block = 0;
    bool sel_live = false;
  };
  /// The timer's word on an entry: issued, its full-latency wake raised, and
  /// not speculative, so confirmation may take it (confirmPass).
  /// A free entry is neither (its fields keep their last values): ooe_wake
  /// stops a freed timer, and ooe_rs asserts it reports no free entry.
  bool rsFinal(unsigned e) const { return rs_[e].valid && rs_[e].issued && rs_[e].late && !rs_[e].spec; }
  const WakeLog &wakeLog() const { return wlog_; }
  /// What reached the register alias tables this cycle, for ooe_rat
  /// (test/ooe/rat_tb.cpp), in the order the model applied it: checkpoint
  /// restores (a mispredict), squashes to retirement (a demotion or kill:
  /// the speculative maps take the committed ones), slot releases, the
  /// committed maps' writes at retirement, then rename's reads and writes in
  /// rename order, a restore-allocate's writes among them (rst: both maps).
  /// Observation only: nothing in the model reads it.
  struct RatLog {
    struct Ren {
      unsigned slot = 0, src[3] = {}, dst = 0, gname = 0, pguard = 0, pdst = 0, pname = 0, pq[2] = {}, ckpt = 0;
      bool gwe = false, pwe = false, plogic = false, br = false, rst = false;
      /// What the reads returned: the model's own values.
      unsigned psrc[3] = {}, pold = 0, ppguard = 0, ppold = 0, pqn[2] = {};
      /// Its RS entries: the main one (MIU class when mem), a masked
      /// load's copy (RCU), else kNoEntry; kNoEntry for a no-op.
      unsigned main = kNoEntry, copy = kNoEntry;
      bool mem = false;
    };
    struct Ret {
      unsigned slot = 0, dst = 0, gname = 0, pdst = 0, pname = 0;
      bool gwe = false, pwe = false;
    };
    std::vector<std::pair<unsigned, unsigned>> restore;   ///< {slot, checkpoint}
    uint32_t squash = 0, release = 0;                       ///< slot masks
    std::vector<Ret> ret;
    std::vector<Ren> ren;
  };
  const RatLog &ratLog() const { return rlog_; }
  /// A tier-1 slot's maps and checkpoints, for test/ooe/rat_tb.cpp.
  unsigned ratGpr(unsigned s, unsigned a) const { return slot_[s].rat[a]; }
  unsigned ratPred(unsigned s, unsigned a) const { return slot_[s].prat[a]; }
  unsigned cratGpr(unsigned s, unsigned a) const { return slot_[s].crat[a]; }
  unsigned cratPred(unsigned s, unsigned a) const { return slot_[s].cprat[a]; }
  bool ckptLive(unsigned s, unsigned c) const { return slot_[s].ckpt[c].live; }
  unsigned ckptGpr(unsigned s, unsigned c, unsigned a) const { return slot_[s].ckpt[c].gpr[a]; }
  unsigned ckptPred(unsigned s, unsigned c, unsigned a) const { return slot_[s].ckpt[c].pred[a]; }
  unsigned slots() const { return unsigned(slot_.size()); }
  /// The producer map, for test/ooe/prodmap_tb.cpp: name n's RS entries
  /// (k 0 the main one, 1 a masked load's copy) or kNoEntry, and the
  /// GPR names there are (rows by positions).
  unsigned gprodOf(unsigned n, unsigned k) const { return gprod_[n][k]; }
  unsigned pprodOf(unsigned n) const { return pprod_[n][0]; }
  unsigned gprodNames() const { return unsigned(gprod_.size()); }
  unsigned pprodNames() const { return unsigned(pprod_.size()); }
  bool rsLive(unsigned e) const { return rs_[e].valid; }
  /// Rename's shared credits as its counters hold them (fits_stale 6; the
  /// RTL's ooe_rename, slice 3), at rename: RS room per class, without
  /// this cycle's frees nor last cycle's past ooe_rs's prompt count (a
  /// squash's, or past the cap); GPR and predicate names, without this
  /// cycle's frees. The prompt and late parts are what the counters add.
  struct RenCredits {
    unsigned c[4] = {};          ///< RS RCU, RS MIU, GPR names, predicate names
    unsigned prompt[2] = {};     ///< this cycle's RS frees within ooe_rs's prompt count
    unsigned late[2] = {};       ///< and the rest, which the counters add an edge late
  };
  RenCredits renCredits() const {
    RenCredits r;
    for (unsigned e = 0; e != n_; ++e) r.c[e < cfg_.rs_rcu ? 0 : 1] += !rs_[e].valid;
    for (unsigned k = 0; k != 2; ++k) {
      r.c[k] -= rs_free_now_[k] + rs_late_prev_[k];
      r.prompt[k] = std::min(rs_free_now_[k], std::min(rs_prompt_[k], cfg_.ren_free_cap));
      r.late[k] = rs_free_now_[k] - r.prompt[k];
    }
    r.c[2] = unsigned(gfree_.ready());
    r.c[3] = cfg_.rename_preds ? unsigned(pfree_.ready()) : 1000u;
    return r;
  }
  /// What rename's counters count over the cycle just run, for
  /// test/ooe/rencred_tb.cpp: the RS entries, names and ROB slots rename
  /// took, the RS frees within ooe_rs's prompt count and past it, the
  /// names allocated and freed, and the state the counters must reach at
  /// the next edge.
  struct RenEvents {
    unsigned rs_take[2] = {}, rs_prompt[2] = {}, rs_late[2] = {}, rs_late_prev[2] = {};
    unsigned rs_free[2] = {};     ///< RS entries not valid now
    unsigned name_take[2] = {}, name_alloc[2] = {}, name_free[2] = {}, names[2] = {};
    std::vector<unsigned> uops, rob_freed, rob_room;   ///< per slot
  };
  RenEvents renEvents() const {
    RenEvents v;
    for (unsigned e : wlog_.ralloc) ++v.rs_take[e < cfg_.rs_rcu ? 0 : 1];
    for (unsigned e = 0; e != n_; ++e) v.rs_free[e < cfg_.rs_rcu ? 0 : 1] += !rs_[e].valid;
    for (unsigned k = 0; k != 2; ++k) {
      v.rs_prompt[k] = std::min(rs_free_now_[k], std::min(rs_prompt_[k], cfg_.ren_free_cap));
      v.rs_late[k] = rs_free_now_[k] - v.rs_prompt[k];
      v.rs_late_prev[k] = rs_late_prev_[k];
    }
    const FreeVec *fl[2] = {&gfree_, &pfree_};
    for (unsigned k = 0; k != 2; ++k) {
      v.name_take[k] = ren_tot_[2 + k];
      v.name_alloc[k] = unsigned(fl[k]->cycleAllocs().size());
      v.name_free[k] = unsigned(fl[k]->cycleFrees().size());
      v.names[k] = unsigned(fl[k]->size());
    }
    for (unsigned si = 0; si != slot_.size(); ++si) {
      v.uops.push_back(si < took_.size() ? took_[si] : 0);
      v.rob_freed.push_back(si < rob_freed_now_.size() ? rob_freed_now_[si] : 0);
      // Slots not valid: a squashed entry whose op is still out (a deferred
      // free) leaves the count at once but holds its slot until it lands.
      unsigned room = 0;
      for (const RobEntry &r : slot_[si].rob) room += !r.valid;
      v.rob_room.push_back(room);
    }
    return v;
  }
  /// The distinct bypass penalties, sorted: wake line k is penalty k's.
  const std::vector<unsigned> &wakePens() const { return pens_; }
private:
  WakeLog wlog_;
  RatLog rlog_;
  unsigned decq_freed_ = 0;                 ///< entries freed this cycle (decq_late_credit)
  unsigned decq_flush_now_ = 0, decq_flush_prev_ = 0;   ///< flushed this cycle, the last (decq_flush_late)
  unsigned decq_take_now_ = 0, decq_take_prev_ = 0;     ///< taken by rename this cycle, the last (decq_take_late)
  /// Per slot, the uops rename took this cycle: ooe_decq's slot count
  /// subtracts its registered take, so they are no room for that slot until
  /// the next edge, under the per-warp limit too (CCV_P_DECQ_WARP_MAX).
  std::vector<unsigned> decq_slot_take_;
  std::array<unsigned, 4> ren_tot_{};      ///< RS RCU, RS MIU, GPR, predicate names renamed this cycle
  std::vector<std::array<unsigned, 4>> ren_slot_;   ///< the same, per slot
  unsigned ren_margin_ = 0;               ///< fits_conservative's margin this cycle
  bool ren_late_frees_ = false;           ///< fits_conservative 3, a short cycle: this cycle's RS frees unseen
  std::vector<uint8_t> rob_prompt_;       ///< ROB slots freed this cycle that rename sees in it
  std::vector<unsigned> audit_room_;      ///< each slot's ROB room as the cycle starts (the settings audit)
  unsigned auditRobRoom(unsigned si) const;
  std::vector<uint8_t> audit_squash_;     ///< a slot squashed this cycle (the settings audit)
  std::vector<uint8_t> row_conf_prev_;    ///< each row confirmed at the last request register update (copy_conf_late)
  bool req_alloc_q_ = false;              ///< a row was written this cycle (req_alloc_lead's flop)
  bool req_alloc_q2_ = false;             ///< and a cycle before (req_rows_late)
  bool req_stop_q_ = false;               ///< ooe_sched's registered stop lead (req_rows_late)
  bool ren_floors_in_share_ = false;      ///< rename's admission: the allowance holds the floors (fits_stale 6)
  std::vector<unsigned> hints_;           ///< completion hints sent before this cycle (miss_lead)
  /// req_rows_late: each row's state one and two updates ago (bit 0
  /// valid, 1 issued, 2 confirmed, 3 freed or written in that cycle, 4
  /// held miss, 5 miss pulse, 6 final, 7 produces), and issued as
  /// ooe_sched forms it this cycle.
  std::vector<uint8_t> req_row_q_[2], req_ise_;
  std::vector<uint8_t> req_dep_q_[2];     ///< the matrix one and two updates ago (req_rows_late)
  std::vector<uint8_t> req_cnf_;          ///< ooe_sched's confirmations this cycle (req_rows_late)
  std::vector<uint8_t> rob_prompt_prev_;  ///< the last cycle's (fits_stale: two cycles late)
  unsigned rs_prompt_prev_[2] = {};       ///< the last cycle's prompt RS frees (fits_stale)
  unsigned shr_prev_[4] = {};             ///< the last cycle's shared credits at rename (fits_stale 2)
  bool shr_copy_prev_ = false;            ///< and a copy among its candidate heads
  bool shares_on_ = false;                ///< fits_stale 3 this cycle
  std::vector<std::array<unsigned, 4>> share_;   ///< each slot's share: RS RCU, RS MIU, GPR, predicate names
  std::vector<std::array<unsigned, 4>> share_reg_;   ///< fits_stale 6: the allowances split for the next cycle
  std::vector<std::array<unsigned, 4>> pend_a_, pend_b_;  ///< fits_stale 7: splits in flight, two cycles and one from use
  std::array<unsigned, 4> pool_{};               ///< fits_stale 4: the credit no warp holds
  std::vector<unsigned> headless_;               ///< fits_stale 4: cycles each slot has gone without a take
  std::vector<unsigned> took_;                   ///< uops each slot renamed this cycle
  std::vector<uint8_t> rs_late_;            ///< RS entries freed this cycle that rename sees late (ren_credit)
  std::vector<uint8_t> rob_late_;           ///< ROB slots likewise, per slot
  unsigned rs_prompt_[2] = {};              ///< this cycle's prompt RS frees per class (ren_credit 2)
  /// fits_stale 6, rename's RS counters as the RTL keeps them: every RS
  /// free this cycle, per class, and last cycle's past ooe_rs's prompt count
  /// (a squash's, or past the cap), which reach the counters an edge late.
  unsigned rs_free_now_[2] = {}, rs_late_prev_[2] = {};
  std::vector<unsigned> rob_freed_now_;   ///< ROB slots each slot freed this cycle (RenEvents)
  bool free_prompt_ = false;                ///< an RS free now is a confirmation's
  /// Held for rename this cycle: valid, or freed this cycle and seen late.
  bool rsHeld(unsigned e) const { return rs_[e].valid || rs_late_[e]; }
  bool robHeld(unsigned si, unsigned i) const {
    const size_t k = size_t(si) * cfg_.rob_depth + i;
    return slot_[si].rob[i].valid || rob_late_[k] ||
           ((ren_late_frees_ || cfg_.fits_conservative == 3) && rob_prompt_[k] && !cfg_.ret_now) ||
           (cfg_.fits_stale == 1 && rob_prompt_prev_[k]);
  }
  /// A ROB slot freed this cycle: prompt for a retirement under ren_credit 2.
  void robFreed(unsigned si, unsigned i, bool retire) {
    if (rob_freed_now_.size() != slot_.size()) rob_freed_now_.assign(slot_.size(), 0);
    ++rob_freed_now_[si];
    if (cfg_.ren_credit == 1 || (cfg_.ren_credit == 2 && !retire)) rob_late_[size_t(si) * cfg_.rob_depth + i] = 1;
    else rob_prompt_[size_t(si) * cfg_.rob_depth + i] = 1;
  }

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
  std::vector<uint8_t> ready_q_;      ///< the registered ready (OI-51): rowReadyNext at the last cycle's end
  std::vector<uint8_t> req_q_;        ///< select's request register (req_reg)
  bool req_lead_q_ = false;           ///< its change lead: the register differed from its next value
  std::vector<uint8_t> req_gnt_q_;    ///< the grant register: last cycle's grants, which mask select
  std::vector<uint8_t> req_gnt_now_;  ///< this cycle's grants, for the grant register at its end
  std::vector<uint8_t> row_pred_;     ///< each row's readiness for next cycle, as the timers said a cycle ago
  bool row_pred_live_ = false;
  bool ready_lead_q_ = false;         ///< the ready register's enable at this cycle's edge
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
  // The ready path as the RTL builds it (OA-1; A-62, A-73, OA-4): each
  // producer drives kWakeLines wake lines, its fastest bypass point plus
  // each bypass penalty, and the PRF read; each matrix cell selects one.
  std::vector<unsigned> pens_;        ///< the distinct penalties, sorted
  uint64_t serial_ = 0;
  bool pens_fit_ = true;              ///< at most kWakeLines - 1 of them
public:
  static constexpr unsigned kWakeLines = 4, kLateLine = kWakeLines - 1;
  /// A matrix cell: entry i waits on entry j.
  bool depBit(unsigned i, unsigned j) const { return cell(i, j) & 1; }
  /// The wake line cell (i, j) selects: a bypass penalty's index into the
  /// producer's lines, or kLateLine for the PRF read.
  unsigned cellCode(unsigned i, unsigned j) const;
  /// Producer j's wake line k this cycle.
  bool wakeLine(unsigned j, unsigned k) const;
  /// Whether the configured penalties fit the lines (a knob-set table may
  /// not); the structural check runs only when they do.
  bool wakeLinesFit() const { return pens_fit_; }
  /// A number unique to this core among all constructed in the process, so
  /// an observer can tell a new core from one at a reused address.
  uint64_t serial() const { return serial_; }
  /// The GPR row free list and the predicate free list (ooe_freelist).
  const FreeVec &gprFree() const { return gfree_; }
  const FreeVec &predFree() const { return pfree_; }
  unsigned rsEntries() const { return n_; }
  bool rsValid(unsigned e) const { return rs_[e].valid; }
  bool rsIssued(unsigned e) const { return rs_[e].valid && rs_[e].issued; }
  /// ooe_wake's age saturation (its AW of 5): a replay must come before it.
  static constexpr unsigned kWakeAgeMax = 31;
  /// Writes a register some entry may wake on (ooe_wake's prod, taken at grant).
  bool rsProduces(unsigned e) const { return rs_[e].produces; }
  /// Allocation order (smaller is older): what ooe_age's matrix encodes.
  uint64_t rsAge(unsigned e) const { return rs_[e].age; }
  /// The decode queue in arrival order, for ooe_decq: each uop's tier-1
  /// slot and its arrival number (a count over the core's life).
  struct DecqView { unsigned slot; uint64_t seq; };
  std::vector<DecqView> decodeQueue() const;
  /// Slots whose decode-queue uops a squash dropped since this cycle began.
  uint32_t decqFlushed() const { return decq_flushed_; }
  /// The first RCU-class entry index past the last; MIU entries follow.
  unsigned rsRcuEntries() const { return cfg_.rs_rcu; }
  bool rsReady(unsigned e) const { return rowReady(e); }
  /// The assembled bench's (test/ooe/trio_tb.cpp), at a cycle's end: a producer's
  /// wake line as it stands next cycle (what the ready register captures),
  /// each entry's slot, copy flag and past rename next cycle, a slot's warp
  /// active, and the ready and request registers.
  bool wakeLineNext(unsigned j, unsigned k) const { return lineAt(j, k, now_ + 1); }
  /// ooe_wake's timer lead: producer j's line k changes at the edge after
  /// next.
  bool wakeLineChanges(unsigned j, unsigned k) const { return lineAt(j, k, now_ + 2) != lineAt(j, k, now_ + 1); }
  unsigned rsSlot(unsigned e) const { return rs_[e].slot; }
  bool rsCopy(unsigned e) const { return rs_[e].copy; }
  bool rsEligibleNext(unsigned e) const { return rs_[e].eligible_at <= now_ + 1; }
  bool slotActive(unsigned s) const { return s < slot_.size() && slot_[s].st == WarpState::kActive; }
  bool readyQ(unsigned e) const { return ready_q_[e]; }
  /// A slot's barrier count, as launch or restore-allocate set it (IS-16).
  unsigned slotBarCount(unsigned s) const { return slot_[s].bar_count; }
  /// A slot's committed width code for architectural GPR a (OI-57).
  unsigned slotWidth(unsigned s, unsigned a) const { return slot_[s].cw[a & 15]; }
  bool reqQ(unsigned e) const { return req_q_[e]; }
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
  std::vector<unsigned> demotes_held_;   ///< a demote waiting for an atomic at the head (V-70)
  /// TI-25 (AR's rev 112): the parked layout, per warp_id, each GPR's
  /// position and committed width (2 + 2 bits, 64 bits a warp, 2 Kb for
  /// the 32 contexts). Written at the demotion's map, read at
  /// restore-allocate, which gives each register its own row with them.
  struct Parked { std::array<uint8_t, 16> pos{}, w{}; };
  std::array<Parked, kWarpIds> parked_{};
  unsigned mig_reads_ = 0;
  std::vector<uint8_t> stall_bit_;       ///< share_stall_aware's registered bit per slot
  /// The slot's oldest RS entry waits on a memory miss past the L1 window.
  bool missStalled(unsigned slot) const;
  /// GPR operand reads an issue of entry e makes (the PRF read-port charge).
  unsigned readsOf(unsigned e) const;
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
  bool miss_now_ = false;             ///< an L1 miss this cycle (inject_shallow_cancel)
  // Restore-allocate's 20 registers bypass the candidate buffer (OI-41).
  size_t gAvail() const { return gfree_.avail(); }
  size_t pAvail() const { return pfree_.avail(); }
  unsigned gTake() { return gfree_.alloc(); }
  unsigned pTake() { return pfree_.alloc(); }
  /// Restore-allocate (OA's response OI-41): accepted slots, oldest first.
  /// The front one drains the candidate buffers through rename's ports,
  /// and rename stalls for every warp until the queue is empty.
  std::deque<unsigned> restore_q_;
  void restoreStep();
  bool gprReserved(unsigned slot, unsigned n) const;
  bool predReserved(unsigned slot, unsigned n) const;
  unsigned unmetFloor(unsigned slot, bool pred) const;
  unsigned floorsOwed(bool pred) const;
  unsigned cancel_depth_ = 0;
  std::vector<Issue> held_issues_;
  std::vector<Memop> held_memops_;
};

} // namespace ooe
} // namespace ccv
#endif // CCV_OOE_CORE_H
