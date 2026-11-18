//===-- dec_tb.h - benches pick opcodes by the model's op-class decode ----===//
//
// The modules decode an issue's opcode themselves (rtl/rcu/rcu_dec_pkg.sv,
// written from sim/rcu/rcu_decode.h). A bench that wants a class drives an
// opcode the model decodes to it: OpPool lists every table opcode (and the
// copy's) whose class at a given done_row matches a predicate, and pick()
// draws one. A class no opcode has fails the bench at construction (unless
// the bench allows it and then never draws it), so a bench never drives a
// class the decode cannot produce.
//===----------------------------------------------------------------------===//
#ifndef CCV_RCU_DEC_TB_H
#define CCV_RCU_DEC_TB_H

#include <cstdio>
#include <cstdlib>
#include <functional>
#include <vector>
#include "rcu_decode.h"

namespace dectb {

namespace R = ccv::rcu;
using ccv::skel::OpInfo;

/// Every opcode the decode names: the table's, then the copy's.
inline std::vector<unsigned> allOpcodes() {
  std::vector<unsigned> v;
  for (unsigned c = 1; c <= ccv::skel::kNumOps; ++c) v.push_back(c);
  v.push_back(ccv::skel::kOpCopy);
  return v;
}

/// The model's class of (opcode, done_row, pcopy); false if it has none.
inline bool classOf(unsigned opc, unsigned drow, bool pcopy, R::OpClass &oc) {
  const OpInfo *op;
  return ccv::skel::rcudec::decodeClass(opc, drow, pcopy, pcopy ? R::kZero : 1u, oc, op);
}

struct OpPool {
  std::vector<unsigned> ops;
  OpPool(const char *what, unsigned drow, const std::function<bool(const R::OpClass &)> &want,
         bool pcopy = false, bool may_be_empty = false) {
    for (unsigned c : allOpcodes()) {
      R::OpClass oc;
      if (classOf(c, drow, pcopy, oc) && want(oc)) ops.push_back(c);
    }
    if (ops.empty() && !may_be_empty) {
      std::fprintf(stderr, "dec_tb: no opcode decodes to %s\n", what);
      std::exit(2);
    }
  }
  bool empty() const { return ops.empty(); }
  template <typename Rng> unsigned pick(Rng &rng) const { return ops[rng() % ops.size()]; }
};

}  // namespace dectb

#endif
