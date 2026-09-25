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

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_KERNEL_H
