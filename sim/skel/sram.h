//===-- sram.h - the SRAM hard macros' cycle model ----------------*- C++ -*-===//
//
// The C++ host's view of rtl/macro/ccv_common_sram_1rw.sv and
// ccv_common_sram_1r1w.sv (AR's register rev 344; docs/rtl-coding-style.md,
// "Hard macros"), cycle for cycle, for a block model that keeps an array as
// its RTL will: behind a macro's ports, its index flopped at the macro's
// edge and its data a cycle later.
//
// A cycle is: set the inputs, read rdata() (the value since the last edge),
// then edge(). Every input is sampled at the edge, as the macro's input
// register does it, so an edge's effect is visible only after it:
//   Sram1rw   ce && we: write the bytes wmask selects (no read that cycle);
//             ce && !we: rdata is word addr after the edge; !ce: nothing.
//   Sram1r1w  we: write; re: rdata is word raddr after the edge, as it stood
//             BEFORE this edge's write (read before write).
// rdata holds the last word read when there is no read, as the RTL's. An
// unwritten word reads as zero here and as whatever the simulator gives in
// RTL; a lockstep check writes before it reads (sram_test.cpp).
//
// W is in bits, a multiple of 8; wmask has a bit per byte, byte 0 in bit 0.
// Data is Bits (bits.h): bit i of a word is bit i of the RTL's vector.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_SRAM_H
#define CCV_SKEL_SRAM_H

#include "bits.h"

#include <cassert>
#include <cstdint>
#include <vector>

namespace ccv {
namespace skel {

namespace sram_detail {
/// Bytes of `src` into `dst` where `mask` (a bit per byte) is set.
inline void writeBytes(Bits &dst, const Bits &src, const Bits &mask) {
  assert(dst.size() == src.size() && mask.size() * 8 == dst.size());
  for (uint32_t b = 0; b != mask.size(); ++b)
    if (mask.bit(b)) dst.set(b * 8, 8, src.get(b * 8, 8));
}
} // namespace sram_detail

/// One port: read or write, a cycle each.
class Sram1rw {
public:
  Sram1rw(uint32_t w, uint32_t d) : w_(w), mem_(d, Bits(w)), rdata_(w) {
    assert(w % 8 == 0 && d >= 2);
  }
  uint32_t width() const { return w_; }
  uint32_t depth() const { return uint32_t(mem_.size()); }

  // The inputs, as the pins hold them this cycle.
  bool ce = false, we = false;
  uint32_t addr = 0;
  Bits wdata, wmask;

  const Bits &rdata() const { return rdata_; }

  void edge() {
    if (!ce) return;
    assert(addr < mem_.size());
    if (we)
      sram_detail::writeBytes(mem_[addr], wdata, wmask);
    else
      rdata_ = mem_[addr];
  }

private:
  uint32_t w_;
  std::vector<Bits> mem_;
  Bits rdata_;
};

/// A read port and a write port on one clock, read before write.
class Sram1r1w {
public:
  Sram1r1w(uint32_t w, uint32_t d) : w_(w), mem_(d, Bits(w)), rdata_(w) {
    assert(w % 8 == 0 && d >= 2);
  }
  uint32_t width() const { return w_; }
  uint32_t depth() const { return uint32_t(mem_.size()); }

  bool re = false, we = false;
  uint32_t raddr = 0, waddr = 0;
  Bits wdata, wmask;

  const Bits &rdata() const { return rdata_; }

  void edge() {
    // The read first: it sees the word as it stood before this edge.
    if (re) {
      assert(raddr < mem_.size());
      rdata_ = mem_[raddr];
    }
    if (we) {
      assert(waddr < mem_.size());
      sram_detail::writeBytes(mem_[waddr], wdata, wmask);
    }
  }

private:
  uint32_t w_;
  std::vector<Bits> mem_;
  Bits rdata_;
};

} // namespace skel
} // namespace ccv

#endif // CCV_SKEL_SRAM_H
