//===-- oracle.h - what each instruction does, from ccv-sim -------*- C++ -*-===//
//
// Strategy §1: the timing model "calls into ccv-sim for what an instruction
// does and owns when". S1 takes the WHAT from a record ccv-sim writes
// (`ccv-sim -oracle`, one JSON line per issue group), checked in under
// test/golden/<kernel>/ so this repo runs without the compiler repo.
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
  uint32_t val = 0;
};

struct Record {
  uint64_t seq = 0, pc = 0;
  unsigned size = 0;
  std::vector<uint8_t> bytes;
  uint32_t mask = 0;
  std::string op, kind;
  bool load = false, store = false;
  std::vector<int64_t> imms;         ///< immediate operands, operand order
  std::vector<RegVal> uses, defs;    ///< operand order; uses before, defs after
  std::vector<MemAcc> mem;           ///< ascending lane

  std::vector<const RegVal *> gprUses() const;
  const RegVal *predUse() const;
  const RegVal *gprDef() const;
  const RegVal *predDef() const;
};

struct Oracle {
  uint64_t code_base = 0;
  unsigned threads = 0, ctaid = 0;
  std::vector<uint8_t> code;
  std::vector<std::pair<uint64_t, uint32_t>> init_mem;
  std::vector<Record> recs;
  uint32_t final_gpr[kArchGprs][kLanes] = {};
  uint32_t final_pred[kArchPreds] = {};
  std::vector<std::pair<uint64_t, uint32_t>> final_mem;
  unsigned issue_groups = 0;

  /// Empty string on success, else what was wrong with the file.
  std::string load(const std::string &path);
  const Record *bySeq(uint64_t seq) const {
    return seq < recs.size() ? &recs[seq] : nullptr;
  }
};

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_ORACLE_H
