//===-- cls_pack.h - the RTL's op-class word, packed from the model's decode -===//
//
// rcu_dec_pkg::rcu_cls(opcode, done_row, pcopy) as the model computes it
// (sim/rcu/rcu_decode.h), packed LSB first in kFields' layout. gen_dec.cpp
// prints rcu_dec_pkg.sv from clsWord(), and the benches drive the class
// word rcu_isd would hold (RA-43, RI-25) from the same function, so the
// package, the benches and the model cannot drift.
//===----------------------------------------------------------------------===//
#ifndef CCV_RCU_CLS_PACK_H
#define CCV_RCU_CLS_PACK_H

#include <cstdint>
#include "rcu_decode.h"

namespace clspack {

namespace R = ccv::rcu;

// Field layout of a class vector, LSB first: name, width.
struct Field { const char *name; unsigned w; };
inline constexpr Field kFields[] = {{"UNIT", 3},  {"RK", 5},   {"MK", 3},    {"GUARDED", 1},
                                    {"PDATA", 1}, {"GDST", 1}, {"ISLOT", 2}, {"IMMU", 1},
                                    {"IREG", 1},  {"READS", 3}, {"BSRC", 2}, {"XSRC", 2},
                                    {"DSRC", 2}};
inline constexpr unsigned kNone = 7;   // UNIT of an opcode with no class (or an atomic on no step)
inline constexpr unsigned kOpcW = 9;

inline unsigned clsWidth() {
  unsigned w = 0;
  for (const Field &f : kFields) w += f.w;
  return w;
}

inline unsigned src2(int s) { return s < 0 ? 3u : unsigned(s); }

inline uint64_t pack(const R::OpClass &oc) {
  const unsigned v[] = {unsigned(oc.unit), unsigned(oc.rk), unsigned(oc.mk), oc.guarded, oc.pdata,
                        oc.gdst, src2(oc.imm_slot), oc.imm_used, oc.ireg, oc.reads & 7u,
                        src2(oc.base_src), src2(oc.index_src), src2(oc.data_src)};
  uint64_t r = 0;
  unsigned at = 0, i = 0;
  for (const Field &f : kFields) {
    r |= uint64_t(v[i++] & ((1u << f.w) - 1)) << at;
    at += f.w;
  }
  return r;
}

/// rcu_cls(opc, drow, pcopy): the class word, or kNone in UNIT for an
/// opcode the decode names no class for.
inline uint64_t clsWord(unsigned opc, unsigned drow, bool pcopy) {
  using namespace ccv::skel;
  R::OpClass oc;
  const OpInfo *d;
  if (opc == kOpCopy) {
    rcudec::decodeClass(opc, 0, pcopy, pcopy ? R::kZero : 1u, oc, d);
    return pack(oc);
  }
  const OpInfo *op = opc == 0 || opc >= (1u << kOpcW) ? nullptr : opByCode(opc);
  if (!op) return kNone;
  if (op->cls == kAtomic)
    return rcudec::decodeClass(opc, drow & 3u, false, 1, oc, d) ? pack(oc) : uint64_t(kNone);
  rcudec::decodeClass(opc, 0, false, 1, oc, d);
  return pack(oc);
}

/// An SFU op's class word: the lane opcode's class with UNIT SFU. The
/// model's decode classes no opcode SFU until RA-16 (b), so the lanes bench
/// drives this to reach SW, done slot 4 and swb_d (RA rev 140 (3)).
inline uint64_t sfuWord(unsigned opc, unsigned drow) {
  R::OpClass oc;
  using namespace ccv::skel;
  const OpInfo *d;
  rcudec::decodeClass(opc, drow & 3u, false, 1, oc, d);
  oc.unit = R::Unit::Sfu;
  return pack(oc);
}

}  // namespace clspack

#endif
