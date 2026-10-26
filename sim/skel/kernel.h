//===-- kernel.h - Stage 3 S1: a kernel through the machine -------*- C++ -*-===//
//
// Functional stubs behind the same ports the S0 exerciser used, one per
// block, so a real instruction stream flows over the real channel path with
// the checker bank still judging every slot. Timing is placeholder (§8:
// fixed latency, no arbitration worth the name); what S1 establishes is that
// every value an instruction needs can travel the channels that exist, and
// where it cannot.
//
// The path, as vadd exercises it:
//
//   RAU --launch--> FET --itlb--> MIU --itlb--> FET
//   FET --ifill--> MLC --req--> EXB --tl_out--> testbench memory
//       testbench --tl_in--> EXB --rsp--> MLC --ifill_rsp--> FET
//   FET --instr--> DEC --uop--> OOE --issue--> RCU --ops--> 32 LANEs
//       LANEs --res--> RCU --done--> OOE
//   loads/stores: OOE --memop--> MIU;  RCU --addr--> MIU --req--> DCU
//       DCU --req--> MLC --> EXB --> testbench, and back;
//       MIU --data--> RCU, MIU --cmpl--> OOE, OOE --retire--> MIU (stores)
//
// Encodings the payload spec leaves open are chosen here and listed in
// docs/skeleton.md ("S1 wire conventions"); each is a placeholder the owning
// block's session replaces.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_KERNEL_H
#define CCV_SKEL_KERNEL_H

#include "machine.h"
#include "oracle.h"

#include <algorithm>
#include <map>
#include <set>
#include <string>
#include <vector>

namespace ccv {
namespace skel {

/// An instruction's identity carries its warp in the sequence's top bits
/// and its place in that warp's oracle stream below (kSeqWarpLsb): each
/// warp's identities rise in fetch order, and warp 0's are the oracle's
/// own sequence numbers, as before there were several.
constexpr unsigned kSeqWarpLsb = 24;
inline uint32_t warpSeq(unsigned warp, uint64_t seq) {
  return uint32_t(warp) << kSeqWarpLsb | uint32_t(seq & ((1u << kSeqWarpLsb) - 1));
}
inline unsigned seqWarp(uint32_t seq) { return seq >> kSeqWarpLsb; }
inline uint32_t seqIndex(uint32_t seq) { return seq & ((1u << kSeqWarpLsb) - 1); }

struct Kernel {
  /// ccv-sim's run of each warp: warp w is one CTA, ctaid orcs[w].ctaid,
  /// alone in its CTA, since ccv-sim runs one warp a CTA. One unless the
  /// kernel launches several (kernel.cfg CTAS, tools/gen-oracle.sh).
  std::vector<Oracle> orcs = std::vector<Oracle>(1);
  /// Load the oracle at `path` as warp 0 and its siblings, <path less
  /// .jsonl>.<w>.jsonl for w = 1, 2, ..., as warps 1 upward.
  std::string loadOracles(const std::string &path);
  const Record *bySeq(uint32_t seq) const {
    const unsigned w = seqWarp(seq);
    return w < orcs.size() ? orcs[w].bySeq(seqIndex(seq)) : nullptr;
  }
  /// Whether tid is its instruction's last uop: a cracked predicate
  /// transfer retires, as an instruction, with its last uop (TI-36).
  bool lastUop(uint64_t tid) const;
  std::string name;
  /// Negative controls. Each must make the run FAIL, and say where:
  ///   corrupt-fetch  one instruction byte flipped on its way FET -> DEC
  ///   corrupt-load   one lane's load data flipped on its way MIU -> RCU
  ///   drop-store     MIU discards a committed store instead of writing it
  ///   corrupt-req-id the first EXB -> MLC response carries the wrong req_id,
  ///                  proving responses are matched by id, not by order
  ///   itlb-double    FET asks for a second translation with one outstanding,
  ///                  which the bank's outstanding checker must catch
  ///   corrupt-disp   seq 6's displacement +4 between OOE and MIU, so the AGU
  ///                  computes a wrong address from what it was sent
  ///   drop-negate    OOE drops the guard's negate bit, so vadd's @!P0 branch
  ///                  resolves as taken and redirects fetch to the wrong place
  ///   drop-pred-data RCU withholds pred_data, so sel's lanes see a clear
  ///                  selector (run on the sel kernel)
  ///   corrupt-echo   MIU echoes phys_dst + 1 for seq 12's load, so a stateless
  ///                  RCU writes a[i] into R9 instead of R8
  ///   movi-in-lane   RCU forwards movi/movi48 to the lanes instead of writing
  ///                  the immediate itself; the lanes must refuse them (Q-38)
  ///   srd-selector   DEC reads srd's selector as 2, which is unallocated; its
  ///                  range check, not the zero checks, must catch it
  ///   corrupt-ctaid  RAU sends OOE ctaid + 1, so srd #1's lanes compute a
  ///                  value the oracle disagrees with (run on the srd kernel)
  ///   late-lead      the lane mask is driven with the operands instead of with
  ///                  valid, so each lane takes a stale mask (Q-40)
  ///   corrupt-ckpt   drop-negate's mispredict, with the redirect naming a
  ///                  checkpoint FET did not take for that branch (A-42)
  ///   stale-free     drop-negate's mispredict, with OOE also freeing the
  ///                  checkpoint its redirect restores: the redirect lands
  ///                  first, so FET sees a free for a dead checkpoint (A-58)
  ///   dirty-zero     the zero registers read as garbage instead of zero, so
  ///                  the merge kernel's first guarded writes and its read of
  ///                  an unwritten register take it (A-64)
  ///   wrong-merge    RCU sends a guarded write's second source as merge_data
  ///                  instead of its old destination (merge kernel; A-44)
  ///   skip-copy      OOE issues a masked load without its copy-only op, so
  ///                  the inactive lanes keep the fresh register's stale value
  ///                  (mload kernel; A-38)
  ///   late-copy      RCU holds the copy-only op CCV_LAT_LANE cycles before
  ///                  sending it to the lanes: it lands after the wake OOE
  ///                  cleared copy-pending on (mload kernel; A-38)
  ///   copy-from-new  the copy-only op carries the load's new destination as
  ///                  merge_data instead of its old one (mload kernel; A-33)
  ///   free-new       OOE's retire frees the write's own new register instead
  ///                  of the one it replaced: once the free list wraps, live
  ///                  values are reallocated and overwritten (loop kernel)
  ///   one-line       MIU takes a warp's access to lie in the line of its first
  ///                  active lane, the aligned-only shortcut (unal kernel)
  ///   corrupt-group-mask  FET drops lane 31 from seq 5's group mask, which
  ///                  OOE issues as its issue mask: the lanes refuse it (A-69)
  ///   stale-epoch    FET tags the first instruction after a redirect with the
  ///                  epoch before it; OOE drops it, and it never retires (A-70)
  ///   attr-store-as-load  DEC's sched_attr calls each store a load, so OOE
  ///                  sends MIU a load and the store never lands (A-66)
  ///   ignore-mask    RCU's predicate merge ignores the active mask, so the
  ///                  switched-off lanes' poison lands (pguard kernel; A-43)
  ///   conflate-pred  DEC writes a guarded compare's predicate to its guard,
  ///                  as one pred_reg field did (Q-21; run on the pguard kernel)
  ///   swap-prat0     the final compare reads P0 and P1 through a predicate
  ///                  map with the two swapped, as an OOE reporting a wrong
  ///                  committed map would (OI-3; pguard kernel)
  ///   drop-src-valid DEC clears a two-source ALU op's second src_valid bit,
  ///                  so OOE does not wait on it (TI-1; vadd: seq 14 reads R9
  ///                  stale)
  ///   arch-pred-srcs RCU reads predicate logic's sources as DEC's qualifiers,
  ///                  not OOE's renamed predicates (TI-1; plog)
  ///   no-lane-bypass RCU never sets operand_byp, so a dependant OOE woke at
  ///                  CCV_LAT_LANE_BYP takes the stale value it read from the
  ///                  register file (TI-8; with CCV_OOE_CONFIG=bypass=1)
  ///   no-resource-cap OOE's select grants a second lane op and a second memop
  ///                  onto resources already held (inject_double_grant), and
  ///                  the second lead takes the next free slot of
  ///                  ccv_ooe_rcu_issue: RCU refuses the overlap (V-60, TI-9)
  ///   bad-pos        OOE names the first GPR-writing lane op's 32-bit
  ///                  destination at position 1, overrunning its row: RCU
  ///                  refuses it (TI-9)
  ///   narrow-pipes   OOE gives every memop the one pipe P0, not a 32-bit
  ///                  memop's four: MIU refuses it (OI-33, TI-9)
  ///   ordering-on-load DEC gives every load ordering 1, which only a fence
  ///                  may carry: DEC's output assertion refuses it (IS-11)
  ///   memop-ordering the same from a DEC without that assertion: MIU
  ///                  refuses each memop it reaches (IS-11, mem_op 0xE)
  ///   dcu-one-miss   DCU keeps one miss in flight, as it once did: a fast
  ///                  miss waits behind a slow one, and the stall kernel's
  ///                  other warps finish after the stalled one
  std::string brk = "none";

  // -- filled in by the stubs ------------------------------------------------
  std::map<uint64_t, uint8_t> mem;                 ///< testbench memory
  std::vector<std::array<uint32_t, kLanes>> gpr;   ///< RCU physical GPRs
  std::vector<uint32_t> pred;                      ///< RCU physical predicates
  /// OOE's committed GPR map, by warp, which the final compare reads.
  std::vector<std::vector<unsigned>> rat;
  /// OOE's committed predicate map, by warp, which the final compare reads
  /// through (OI-3). An OOE that renames predicates sets it at retirement,
  /// as it does rat; left empty, the compare reads the fixed physPred
  /// windows, which is right only while predicates are not renamed.
  std::vector<std::vector<unsigned>> prat;
  /// A warp's maps, made at its first use: the zero register for every GPR,
  /// and the zero predicate for every predicate if `preds` (A-64).
  std::vector<unsigned> &ratOf(unsigned w);
  std::vector<unsigned> &pratOf(unsigned w, bool preds);
  uint64_t retired = 0;
  std::vector<uint64_t> retire_order;              ///< seq, as retired
  /// The cycle FET first sent DEC an instruction. The KERNEL line counts the
  /// run from it beside the total (from_fetch, AR-19), so a comparison need
  /// not carry the launch and the cold ITLB and ifill misses before it.
  uint64_t first_fetch = 0;
  bool fetched = false;
  unsigned exits = 0;                              ///< warps whose exit retired
  /// Warps that ended in a fault CRU took (TI-26), by warp: what it reported.
  struct FaultSeen { unsigned cause = 0; uint64_t pc = 0, addr = 0; uint32_t lanes = 0; };
  std::map<unsigned, FaultSeen> faults;
  std::set<unsigned> killed;                       ///< warps RAU's kill ended (V-24)
  /// A kill RAU has broadcast and not seen through: the owners whose ack at
  /// its epoch has not come (kFabs kill_ack order), else 0.
  uint32_t kill_unacked = 0;
  /// A demoted warp, as the blocks that moved it saw it (TI-24). Observed for
  /// the check at the end, never read by a block: the resume PC RAU got, the
  /// rows RCU read out (each arch register's row name, in the map OOE sent),
  /// and the rows and PC groups PCA holds. With no restore yet (TI-24 (1)), a
  /// parked warp ends its run parked, and its state is checked against
  /// ccv-sim's at the retirement boundary instead of at the end.
  struct Parked {
    uint64_t resume_pc = 0;
    std::map<unsigned, std::array<uint32_t, kLanes>> rows;  ///< PCA's, by mig_row
    std::array<uint64_t, kLanes> lane_pc{};                 ///< PCA's, from FET (IS-17)
    bool rewound = false;                                   ///< FET had OOE's beats
    bool done = false;                                      ///< PCA acked it
    bool restored = false;                                  ///< and it came back
  };
  std::map<unsigned, Parked> parked;
  /// Whether RAU restores what it parks (CCV_RAU_RESTORE, on unless 0): if
  /// not, a parked warp ends its run parked and counts as finished.
  bool restores = true;
  bool parkedNow(unsigned w) const {
    auto p = parked.find(w);
    return p != parked.end() && p->second.done && !p->second.restored;
  }
  unsigned parked_done() const {
    unsigned n = 0;
    for (auto &p : parked) n += p.second.done && !p.second.restored;
    return n;
  }
  bool exited() const {
    return exits + killed.size() + (restores ? 0 : parked_done()) >= orcs.size();
  }
  /// A warp's architectural registers and predicates as it exits, read
  /// through its maps before OOE frees them for another warp: the final
  /// compare reads these, since a slot reused after an exit reallocates the
  /// registers (an observation; RAU takes it at the exit's quiesce).
  struct Final { std::array<std::array<uint32_t, kLanes>, kArchGprs> gpr{}; std::array<uint32_t, kArchPreds> pred{}; };
  std::map<unsigned, Final> finals;
  void snapshotFinal(unsigned w);
  /// The check of a warp PCA has just acked: its rows, predicates and PCs
  /// against ccv-sim's state after the instructions it has retired, which
  /// is its boundary, since the demotion squashed the rest (TI-24).
  void checkParked(unsigned w);
  uint64_t failures = 0;                           ///< check failures
  uint64_t class_violations = 0;
  std::vector<uint64_t> rx_per_chan = std::vector<uint64_t>(kNumChans, 0);
  unsigned busy = 0;                               ///< blocks with work left

  /// Coverage bins: what each kernel exists to reach, counted where it
  /// happens, so a stub change that stops reaching a path fails the gate
  /// instead of passing it vacuously (docs/coverage.md). kCoverBins is the
  /// COVER line's order; every bin prints, reached or not.
  static constexpr const char *kCoverBins[] = {
      "redirect", "ckpt_free", "ckpt_full", "ckpt_peak", "merge", "copy",
      "zero_read", "reg_reuse", "line_split", "lines_peak", "partial_line", "full_line", "store_hit", "dcu_evict",
      "dcu_id_wait", "epoch_drop", "l1_hit", "l1_late", "hit_under_miss", "reexec",
      "lane_byp", "fill_notice", "cmpl_hint", "demote", "parked", "rewound", "restored", "resumed", "slot_reuse",
      "bulk_discard", "replay", "orphan", "ready", "refused", "provisional", "prov_demote",
      "split", "reconverge", "groups_peak", "fair_pick", "st_ld_wait", "order_diff", "ro_fault", "fault", "kill",
      "slot_form", "window_fill", "dcu_lookups", "frame_lookups", "local_form",
      "pred_xfer", "pred_merge", "pred_copy", "crack_split",
      // Fences and barriers (IS-11, TI-40).
      "fence", "fence_wait", "bar_wait", "bar_arrive", "bar_complete", "bar_release", "bar_ready",
      "syu_ready", "addr_fault", "narrow_arith", "chw_converged", "chw_diverged", "ret_pass",
      "fet_pred_partial",
      // .shared through SPM (TI's rev 230).
      "spm_pass", "spm_conflict", "spm_passes_peak", "spm_wait", "shared_fault"};
  std::map<std::string, uint64_t> cover;
  /// DCU's dirty lines (DCU spec rev 8: write-back), by line address: what
  /// memory holds that the testbench does not yet. For the final memory
  /// compare only, never for a decision.
  std::map<uint64_t, std::vector<uint8_t>> dcu_dirty;
  /// Each warp's CTA slot, as RAU gave it (TI-34): for the checks on the
  /// cta_slot OOE stamps on memops and faults, never for a decision.
  std::map<unsigned, unsigned> cta_slot_of;
  /// Each warp's CTA, by the order ccv-sim's runs name ctaids: the warps of
  /// one -cta run share one (CP-30), each CTAS run has its own. RAU gives a
  /// CTA one slot, and MIU checks a slot names one CTA (oracle, for checks).
  std::vector<unsigned> cta_of;
  unsigned ctas = 0;
  void hit(const char *bin, uint64_t n = 1) { cover[bin] += n; }
  void peak(const char *bin, uint64_t v) { cover[bin] = std::max(cover[bin], v); }

  void fail(const char *fmt, ...);
  /// A check on the VALUES an execution read, held rather than failed. OOE
  /// may issue an op on an L1 hit it speculated, cancel it when the hit does
  /// not come, and replay it under the same id (A-46): the cancelled
  /// execution read stale operands by design. A held failure is dropped if
  /// the same instruction executes again at the same place (`executing`),
  /// and fails at the end of the run if it never does (flushHeld, before the
  /// final compare). The lane returns ccv-sim's result whatever its
  /// operands, so a dropped execution cannot hide a wrong architectural
  /// value; the final compare would still see one.
  void failHeld(const std::string &where, uint64_t tid, const char *fmt, ...);
  void executing(const std::string &where, uint64_t tid);
  void flushHeld();
  std::map<std::pair<std::string, uint64_t>, std::vector<std::string>> held;
  std::set<std::pair<std::string, uint64_t>> executed;
  std::set<uint64_t> reexecuted;                   ///< tids that ran twice
};

std::unique_ptr<Block> makeKernelBlock(int inst, Kernel &k);

/// Physical predicate of arch P<idx> for a warp. OOE owns the RATs and RAU
/// allocates nothing (A-30). GPRs are renamed (Kernel::rat holds each warp's
/// map at the end); predicates are not, so each warp keeps a fixed window.
inline unsigned physPred(unsigned warp, unsigned idx) { return warp * 4 + idx; }

struct KernelReport {
  unsigned gpr_mismatch = 0, pred_mismatch = 0, mem_mismatch = 0;
  bool order_ok = false;
  unsigned channels_used = 0;
  std::string unused;   ///< channels that carried nothing, space separated
};
/// Compare the machine's final architectural state with ccv-sim's.
KernelReport compareFinal(Kernel &k);

/// The kernel's name: the directory its oracle record sits in.
std::string kernelName(const std::string &oracle_path);

/// When a kernel run is over, by ONE rule for both hosts -- the C++ loop in
/// main.cpp and the SV-hosted testbench (dpi_host.cpp): the exit has retired,
/// no block has work left, nothing is in flight on any slot, and that has held
/// for a short tail, so a late message would still be seen by the bank.
/// Call once per cycle, after every block has run it; it clears k.busy.
struct KernelEnd {
  static constexpr uint64_t kReset = 2, kTail = 8;
  uint64_t quiet = 0, finish = 0;
  bool finished = false;
  /// True once the tail has run out.
  bool after(uint64_t c, Kernel &k, Machine &m);
};

/// The KERNEL and UNUSED lines, the same from either host, so
/// tools/check-sv-hosted.sh can compare them as text.
void printKernelReport(Kernel &k, Machine &m, const KernelEnd &e,
                       int violations);

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_KERNEL_H
