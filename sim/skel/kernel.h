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

#include <map>
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
  ///   ignore-mask    RCU writes back every lane, including those the mask
  ///                  switched off, whose outputs are poison (pguard kernel)
  ///   conflate-pred  DEC writes a guarded compare's predicate to its guard,
  ///                  as one pred_reg field did (Q-21; run on the pguard kernel)
  std::string brk = "none";

  // -- filled in by the stubs ------------------------------------------------
  std::map<uint64_t, uint8_t> mem;                 ///< testbench memory
  std::vector<std::array<uint32_t, kLanes>> gpr;   ///< RCU physical GPRs
  std::vector<uint32_t> pred;                      ///< RCU physical predicates
  unsigned prf_base = 0;                           ///< warp 0's, from RAU
  uint64_t retired = 0;
  std::vector<uint64_t> retire_order;              ///< seq, as retired
  bool exited = false;
  uint64_t failures = 0;                           ///< check failures
  uint64_t class_violations = 0;
  std::vector<uint64_t> rx_per_chan = std::vector<uint64_t>(kNumChans, 0);
  unsigned busy = 0;                               ///< blocks with work left

  void fail(const char *fmt, ...);
};

std::unique_ptr<Block> makeKernelBlock(int inst, Kernel &k);

/// Physical predicate index of arch P<idx> for a warp: preds are not renamed.
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
