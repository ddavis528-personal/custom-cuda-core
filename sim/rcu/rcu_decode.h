//===-- rcu_decode.h - the RCU's op-class decode, from the op table --*- C++ -*-===//
//
// The Pipeline tab's op-class decode: the class fields the core and the RTL
// read, from an issue's opcode (and, for a copy or an atomic, the payload
// fields that pick its class). One definition, used by the model
// (rcu_block.cpp) and by test/rcu/gen_dec.cpp, which writes the RTL's
// rtl/rcu/rcu_dec_pkg.sv from it, so the two decodes cannot drift (RI-21
// (4); TI's generated package replaces it, TI rev 378).
//===----------------------------------------------------------------------===//
#ifndef CCV_RCU_DECODE_H
#define CCV_RCU_DECODE_H

#include <cstring>
#include <string>
#include "stub.h"
#include "rcu_core.h"

namespace ccv {
namespace skel {
namespace rcudec {

namespace R = ccv::rcu;

/// The op-class decode (Pipeline tab) of an opcode, from the op table.
inline R::OpClass classOf(const OpInfo *op, bool copy, bool pred_copy) {
  R::OpClass oc;
  if (copy) {
    oc.unit = pred_copy ? R::Unit::PredCopy : R::Unit::Copy;
    oc.guarded = true;   // a copy's active lanes are issue mask AND guard
    return oc;
  }
  oc.guarded = op->guard;
  oc.pdata = op->pdata;
  oc.gdst = op->gdst;
  for (unsigned i = 0; i != op->nsrc; ++i)
    if (!(op->alu_imm >= 0 && int(i) == op->imm_slot)) oc.reads |= 1u << i;
  oc.imm_used = op->alu_imm >= 0 || op->srd_sel >= 0 || op->cls == kPredLogic;
  oc.base_src = op->base_src;
  oc.index_src = op->index_src;
  oc.data_src = op->data_src;
  const bool mem = op->cls == kLoad || op->cls == kStore || op->cls == kFence;
  if (mem) {
    oc.unit = R::Unit::Mem;
    oc.mk = op->cls == kFence ? R::MemKind::Fence
            : op->cls == kLoad ? (op->pxfer ? R::MemKind::PredLoad : R::MemKind::Load)
                               : (op->pxfer ? R::MemKind::PredStore : R::MemKind::Store);
    // A predicate transfer's active mask is the issue mask (TI-36).
    if (op->pxfer) oc.guarded = false;
    return oc;
  }
  if (op->cross) {
    // O-85's collectives, by the op table's name (TI, 2026-11-07). The _R
    // shuffles take their index from source port 1; vote and ballot read
    // their predicate from imm (imm_kind 1), as predicate logic does.
    oc.unit = R::Unit::Coll;
    const std::string nm = op->name;
    const bool reg = nm.size() > 2 && nm.compare(nm.size() - 2, 2, "_R") == 0;
    oc.rk = nm == "SHFL_IDX" ? R::RKind::ShflIdxImm
            : nm == "SHFL_IDX_R" ? R::RKind::ShflIdxReg
            : nm.rfind("SHFL_UP", 0) == 0 ? R::RKind::ShflUp
            : nm.rfind("SHFL_DOWN", 0) == 0 ? R::RKind::ShflDown
            : nm.rfind("SHFL_BFLY", 0) == 0 ? R::RKind::ShflBfly
            : nm == "VOTE_ANY" ? R::RKind::VoteAny
            : nm == "VOTE_ALL" ? R::RKind::VoteAll
            : nm == "BALLOT" ? R::RKind::Ballot
            : nm == "UNBALLOT" ? R::RKind::Unballot : R::RKind::None;
    oc.ireg = reg && oc.rk != R::RKind::ShflIdxReg;
    if (op->nsrc == 0) oc.imm_used = true;   // vote, ballot: the predicate in imm
    return oc;
  }
  if (inRcu(op->cls)) {
    oc.unit = R::Unit::ROnly;
    switch (op->cls) {
    case kBranch: oc.rk = op->ret ? R::RKind::Ret : op->gdst ? R::RKind::Call : R::RKind::Bra; break;
    case kPredLogic:
      oc.rk = !std::strcmp(op->name, "POR") ? R::RKind::Por
              : !std::strcmp(op->name, "PAND") ? R::RKind::Pand
              : !std::strcmp(op->name, "PXOR") ? R::RKind::Pxor : R::RKind::None;
      break;
    case kImm: oc.rk = op->pwrite ? R::RKind::PmovImm : R::RKind::Movi; break;
    default: break;
    }
    // ret reads its link register as R0 (the op table lists it as nsrc).
    if (op->ret) oc.reads |= 1u;
    return oc;
  }
  oc.unit = R::Unit::Lane;
  oc.imm_slot = op->alu_imm >= 0 ? op->imm_slot : -1;
  return oc;
}

/// An issue's class, as the block decodes it: a copy by its opcode (a
/// predicate-only copy when it writes a predicate and the zero GPR), an
/// atomic as its step (done_row; nullptr op if none), any other op by its
/// table entry. Returns false for an opcode with no entry or an atomic on a
/// row with no step; `op` is the entry decoded (the step's for an atomic).
inline bool decodeClass(unsigned opcode, unsigned done_row, bool pwe, unsigned dst, R::OpClass &oc,
                        const OpInfo *&op) {
  const bool copy = opcode == kOpCopy;
  op = copy ? nullptr : opByCode(opcode);
  if (!copy && !op) return false;
  if (op && op->cls == kAtomic) {
    op = atomStep(done_row);
    if (!op) return false;
  }
  oc = classOf(op, copy, copy && pwe && dst == R::kZero);
  return true;
}

}  // namespace rcudec
}  // namespace skel
}  // namespace ccv

#endif
