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

struct Kernel {
  Oracle orc;
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
  std::string brk = "none";

  // -- filled in by the stubs ------------------------------------------------
  std::map<uint64_t, uint8_t> mem;                 ///< testbench memory
  std::vector<std::array<uint32_t, kLanes>> gpr;   ///< RCU physical GPRs
  std::vector<uint32_t> pred;                      ///< RCU physical predicates
  std::vector<unsigned> rat0;                      ///< OOE's GPR map for warp 0
  /// OOE's committed predicate map for warp 0, which the final compare reads
  /// through (OI-3). An OOE that renames predicates sets it at retirement,
  /// as it does rat0; left empty, the compare reads the fixed physPred
  /// windows, which is right only while predicates are not renamed.
  std::vector<unsigned> prat0;
  uint64_t retired = 0;
  std::vector<uint64_t> retire_order;              ///< seq, as retired
  bool exited = false;
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
      "zero_read", "reg_reuse", "line_split", "lines_peak", "partial_line",
      "dcu_id_wait", "epoch_drop", "l1_hit", "l1_late", "reexec", "lane_byp"};
  std::map<std::string, uint64_t> cover;
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
/// allocates nothing (A-30). GPRs are renamed (Kernel::rat0 is warp 0's map
/// at the end); predicates are not, so each warp keeps a fixed window.
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
