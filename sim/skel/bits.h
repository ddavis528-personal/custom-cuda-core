//===-- bits.h - a payload, as the packed bits RTL sees ------------*- C++ -*-===//
//
// The skeleton carries payloads as their PACKED bits, laid out exactly as the
// SystemVerilog packed struct (first field most significant). Not as C++
// structs: at 4d an RTL block is swapped in behind the same channel, and it
// sees bits. Keeping the C++ side in bits means the swap changes who produces
// them, never their shape.
//
// Field positions come from sim/generated/ccv_skel_wiring.h; nothing here
// knows any layout.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_BITS_H
#define CCV_SKEL_BITS_H

#include <cassert>
#include <cstdint>
#include <vector>

namespace ccv {
namespace skel {

class Bits {
public:
  explicit Bits(uint32_t n = 0) : w_((n + 63) / 64, 0), n_(n) {}

  uint32_t size() const { return n_; }
  const std::vector<uint64_t> &words() const { return w_; }

  bool bit(uint32_t i) const {
    assert(i < n_);
    return (w_[i / 64] >> (i % 64)) & 1u;
  }
  void setBit(uint32_t i, bool v) {
    assert(i < n_);
    const uint64_t m = uint64_t(1) << (i % 64);
    w_[i / 64] = v ? (w_[i / 64] | m) : (w_[i / 64] & ~m);
  }

  /// A field of at most 64 bits.
  uint64_t get(uint32_t lsb, uint32_t width) const {
    assert(width <= 64 && lsb + width <= n_);
    uint64_t v = 0;
    for (uint32_t k = 0; k != width; ++k)
      v |= uint64_t(bit(lsb + k)) << k;
    return v;
  }
  /// Bits of `v` above `width` are dropped, so a caller cannot widen a field
  /// by accident -- an out-of-range value is the value RTL would truncate to.
  void set(uint32_t lsb, uint32_t width, uint64_t v) {
    assert(width <= 64 && lsb + width <= n_);
    for (uint32_t k = 0; k != width; ++k)
      setBit(lsb + k, (v >> k) & 1u);
  }

  /// Take `src`'s bits where `mask` is set, keep this one's elsewhere.
  void mergeFrom(const Bits &src, const Bits &mask) {
    for (size_t i = 0; i != w_.size(); ++i)
      w_[i] = (w_[i] & ~mask.w_[i]) | (src.w_[i] & mask.w_[i]);
  }
  bool any() const {
    for (uint64_t x : w_) if (x) return true;
    return false;
  }
  bool operator==(const Bits &o) const { return n_ == o.n_ && w_ == o.w_; }
  bool operator!=(const Bits &o) const { return !(*this == o); }

private:
  std::vector<uint64_t> w_;
  uint32_t n_;
};

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_BITS_H
