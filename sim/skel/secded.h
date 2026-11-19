//===-- secded.h - the arrays' SECDED code, as the RTL computes it -*- C++ -*-===//
//
// The C++ host's view of rtl/common/ccv_common_secded_enc.sv, _syn.sv and
// _fix.sv
// (DA rulings TI-474 to TI-476, Daniel, 2026-11-17: every SRAM holds SECDED
// ECC, its logic the block's), bit for bit (test/vl/vl_secded_tb.cpp holds
// them together), for a block model that keeps an SRAM's check bits as its
// RTL will, and for the model's error injection.
//
// A Hsiao code: K data bits, R check bits, R the least with
// 2^(R-1) - R >= K (clog2(K + clog2(K) + 1) + 1 for every K the design
// uses). Data bit i's column of the parity-check matrix is the i-th R-bit
// vector of odd weight 3 or more, by weight and then by value; check bit
// j's is the unit vector j. decode(): the syndrome is the check bits
// recomputed XOR those stored; zero, no error; a column, that one bit was
// wrong (sec; a data bit's is corrected in q); anything else, two or more
// (ded; q is the data unchanged).
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_SECDED_H
#define CCV_SKEL_SECDED_H

#include "bits.h"

#include <cassert>
#include <cstdint>
#include <vector>

namespace ccv {
namespace skel {

class Secded {
public:
  static uint32_t checkBits(uint32_t k) {
    uint32_t r = 2;
    while ((uint32_t(1) << (r - 1)) - r < k) ++r;
    return r;
  }

  explicit Secded(uint32_t k) : k_(k), r_(checkBits(k)) {
    assert(k >= 3 && r_ <= 16);
    for (uint32_t w = 3; w <= r_ && col_.size() < k_; w += 2)
      for (uint32_t v = 0; v < (uint32_t(1) << r_) && col_.size() < k_; ++v)
        if (uint32_t(__builtin_popcount(v)) == w) col_.push_back(v);
    assert(col_.size() == k_);
  }
  uint32_t dataBits() const { return k_; }
  uint32_t checkBits() const { return r_; }
  /// Data bit i's column: tests swap two to prove a check would see it.
  std::vector<uint32_t> &columns() { return col_; }

  /// The check bits of `d` (K bits), bit j in bit j.
  uint32_t encode(const Bits &d) const {
    assert(d.size() == k_);
    uint32_t c = 0;
    for (uint32_t i = 0; i != k_; ++i)
      if (d.bit(i)) c ^= col_[i];
    return c;
  }

  struct Result {
    Bits q;
    bool sec = false, ded = false;
    uint32_t syn = 0;
  };
  Result decode(const Bits &d, uint32_t chk) const {
    Result out;
    out.q = d;
    out.syn = encode(d) ^ (chk & ((uint32_t(1) << r_) - 1));
    if (!out.syn) return out;
    for (uint32_t i = 0; i != k_; ++i)
      if (col_[i] == out.syn) {
        out.q.setBit(i, !d.bit(i));
        out.sec = true;
        return out;
      }
    out.sec = __builtin_popcount(out.syn) == 1;   // a check bit's own error
    out.ded = !out.sec;
    return out;
  }

private:
  uint32_t k_, r_;
  std::vector<uint32_t> col_;
};

} // namespace skel
} // namespace ccv

#endif // CCV_SKEL_SECDED_H
