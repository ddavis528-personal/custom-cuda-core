//===-- oracle.h - what each instruction does, from ccv-sim -------*- C++ -*-===//
//
// Strategy §1: the timing model "calls into ccv-sim for what an instruction
// does and owns when". S1 takes the WHAT from a record ccv-sim writes
// (`ccv-sim -oracle`, one JSON line per issue group), generated each gate
// run by tools/gen-oracle.sh from a PINNED compiler snapshot's built ccv-sim
// (tools/compiler.lock) into build/oracle/<kernel>/ -- never checked in.
//
// What the record may be used for is the whole point of S1, so it is stated
// here once:
//
//   - FETCH ORDER and DECODE (which registers an instruction reads and
//     writes) come from the record. The skeleton has no decoder yet.
//   - ALU RESULTS come from the record: a lane returns the value ccv-sim
//     computed. That is the "what".
//   - Everything else is CARRIED, not looked up: instruction bytes come from
//     testbench memory through the memory path, operands come out of RCU's
//     register file, load data comes back from memory, store data leaves the
//     register file. Every consumer checks what arrived against the record,
//     and the final register file and memory are compared with ccv-sim's.
//   - Immediates come from the record's `imms` and then travel: a
//     displacement and scale enable on the memop to MIU's AGU, an ALU
//     immediate on the issue to RCU, which substitutes it into an operand.
//
// The instruction's trace identity (uid seq == record seq) is how a checker
// finds the record. It is trace-only, so no block may use it to decide what
// to DO -- only to check what it did.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_ORACLE_H
#define CCV_SKEL_ORACLE_H

#include <array>
#include <cstdint>
#include <string>
#include <utility>
#include <vector>

namespace ccv {
namespace skel {

constexpr unsigned kLanes = 32, kArchGprs = 16, kArchPreds = 4;

struct RegVal {
  bool pred = false;                 ///< P<idx> rather than R<idx>
  unsigned idx = 0;
  std::array<uint32_t, kLanes> v{};  ///< GPR: one value per lane
  uint32_t p = 0;                    ///< predicate: one bit per lane
};

struct MemAcc {
  unsigned lane = 0;
  bool shared = false, write = false;
  uint64_t addr = 0;
  unsigned bytes = 0;
  uint32_t val = 0;   ///< absent on a faulting record, which writes nothing
};

struct Record {
  uint64_t seq = 0, pc = 0;
  unsigned size = 0;
  std::vector<uint8_t> bytes;
  uint32_t mask = 0;
  std::string op, kind;
  bool load = false, store = false;
  std::vector<int64_t> imms;         ///< immediate operands, operand order
  std::vector<unsigned> quals;       ///< predicate qualifiers as encoded:
                                     ///< [1:0] index, [2] negate
  uint32_t taken = 0;                ///< branch: lanes that take it
  uint64_t target = 0;               ///< branch: where they go
  std::vector<RegVal> uses, defs;    ///< operand order; uses before, defs after
  std::vector<MemAcc> mem;           ///< ascending lane
  /// The barrier waits ccv-sim tried just before this record and blocked
  /// (TI-40): each try's PC, group and blocked lanes. The tries are not
  /// instructions, but each was a pick, and its lanes then sat at the wait.
  struct StallTry { uint64_t pc; uint32_t mask, blocked; };
  std::vector<StallTry> stalls_before;
  /// Every GPR's width code as the record executes, 2 bits per register
  /// (R0 lowest): ccv-sim keeps the bits above a narrow element as the
  /// slice last held them, so a value is compared only within its width.
  uint32_t widths = 0;
  unsigned widthOf(unsigned g) const { return widths >> (2 * (g & 15)) & 3u; }

  std::vector<const RegVal *> gprUses() const;
  /// A predicate transfer, ld.pred or st.pred (O-19), and its mask,
  /// quals[0]: one bit per P0-P3, word i of the frame for Pi.
  bool predXfer() const {
    return op == "LD_PRED_G" || op == "ST_PRED_G" || op == "LD_PRED_LOCAL" || op == "ST_PRED_LOCAL";
  }
  unsigned predMask() const { return quals.empty() ? 0u : quals[0] & 15u; }
  /// The uops DEC issues for it: one per predicate of a transfer's mask,
  /// ascending (TI-36), else one.
  unsigned uops() const {
    if (chwMulti()) return chwMask() ? unsigned(__builtin_popcount(chwMask())) : 1u;
    return predXfer() && predMask() ? unsigned(__builtin_popcount(predMask())) : 1u;
  }
  /// chwidth.multi #regmask, width (O-6): its mask, imms[0], and width
  /// code, imms[1]. DEC cracks it into one chwidth uop per register of the
  /// mask, ascending (AR-24 (c)).
  bool chwMulti() const { return op == "CHWIDTH_MULTI"; }
  uint32_t chwMask() const { return imms.empty() ? 0u : uint32_t(imms[0]) & 0xffffu; }
  unsigned chwReg(unsigned k) const {
    for (unsigned g = 0, n = 0; g != 16; ++g)
      if (chwMask() >> g & 1u && n++ == k) return g;
    return 0;
  }
  /// The def of GPR g, if the record has one.
  const RegVal *gprDefOf(unsigned g) const {
    for (const RegVal &d : defs) if (!d.pred && d.idx == g) return &d;
    return nullptr;
  }
  /// Uop k's predicate: the mask's k-th set bit, ascending.
  unsigned xferPred(unsigned k) const {
    for (unsigned p = 0, n = 0; p != 4; ++p)
      if (predMask() >> p & 1u && n++ == k) return p;
    return 0;
  }
  const RegVal *predUse() const;
  const RegVal *gprDef() const;
  const RegVal *predDef() const;
};

struct Oracle {
  uint64_t code_base = 0;
  /// The launch's entry, an offset from code_base: the kernel.cfg's ENTRY,
  /// which gen-oracle writes beside the records (a release kernel's
  /// launch.txt entry; AR-24). 0 for a kernel that starts at its base.
  uint64_t entry = 0;
  unsigned threads = 0, ctaid = 0;
  unsigned warp_in_cta = 0;   ///< which of its CTA's warps this file is (ccv-sim -cta, CP-30)
  /// The hardware warp context srd #2 named in this run (ccv-sim -context,
  /// TI-35; O-64). ccv-sim records it only where it is not the default,
  /// its warp_in_cta, so a file without it ran as context warp_in_cta.
  unsigned lane_context = 0;
  std::vector<uint8_t> code;
  std::vector<std::pair<uint64_t, uint32_t>> init_mem;
  /// F-RO's .const range, [const_base, const_limit); empty when equal (TI-26).
  uint64_t const_base = 0, const_limit = 0;
  /// The launch block, LAUNCH_BASE: ccv-sim's is 0x20000, window 2 (ISA
  /// v1.9 section 5.2), and its launch slots are at +32 + 8k (O-45).
  uint64_t launch_block = 0x20000;
  /// The run's fault, when it ends in one (TI-28): its cause by name, the
  /// faulting instruction's pc, the faulting lanes and the reported address.
  /// The faulting instruction is the last record, kind "fault".
  struct Fault { std::string cause; uint64_t pc = 0, addr = 0; uint32_t lanes = 0; };
  bool faults = false;
  Fault fault;
  std::vector<Record> recs;
  uint32_t final_gpr[kArchGprs][kLanes] = {};
  uint32_t final_widths = 0;   ///< as Record::widths, after the last record
  uint32_t final_pred[kArchPreds] = {};
  std::vector<std::pair<uint64_t, uint32_t>> final_mem;
  unsigned issue_groups = 0;
  unsigned stalls = 0;   ///< barrier waits ccv-sim retried, dropped at load (TI-40)
  std::vector<Record::StallTry> tries;   ///< the tries since the last record, at load

  /// Empty string on success, else what was wrong with the file.
  std::string load(const std::string &path);
  const Record *bySeq(uint64_t seq) const {
    return seq < recs.size() ? &recs[seq] : nullptr;
  }
};

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_ORACLE_H
