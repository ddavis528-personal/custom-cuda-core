//===-- wayfold.h - the L1 way predictor's fold, as the RTL computes it -*- C++ -*-===//
//
// The C++ host's view of rtl/common/ccv_common_wayfold.sv, bit for bit
// (tools/check-skel.sh's lockstep, test/vl/vl_wayfold_tb.cpp, holds the two
// together, as it does secded.h and the SECDED helpers). MA-30, AR 405 and
// MA's response to it (MA tab rev 155): one fold, used by MIU (each TLB
// entry keeps fold(PFN) beside its PFN, written at the fill; A2 sends it as
// ccv_miu_dcu_req's pa_fold) and by DCU's fold-table write at a fill.
//
// The tag is PA[47:7+s], above the 7 line-offset bits and the s set-and-bank
// bits (s = log2 sets, 9 at the built 512). fold(PA) is the XOR of two folds,
// each the XOR of its field's k-bit chunks from the field's low bit, the last
// chunk zero-extended: the page's, PA[47:16] (with CCV_L_PAGE_SHIFT 16
// exactly the PFN, so MIU keeps it in each TLB entry), and the page offset's
// tag bits, PA[15:7+s], empty at 512 sets and folded by MIU at A2 from the
// VA's offset (MA-33 (3)). 8 chunks at k = 4 and 512 sets. k = 0 is no
// prediction, fold 0.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_WAYFOLD_H
#define CCV_SKEL_WAYFOLD_H

#include <cstdint>

namespace ccv {
namespace skel {

constexpr unsigned kWayFoldLo = 16;   ///< the page's low PA bit
constexpr unsigned kWayFoldW = 32;    ///< the page's width, PA[47:16]
constexpr unsigned kWayFoldLine = 7;  ///< the line offset's bits

/// The fold of a field's low w bits into k bits.
inline unsigned wayFoldField(uint64_t x, unsigned w, unsigned k) {
  if (!k || !w) return 0;
  if (w < 64) x &= (uint64_t(1) << w) - 1;
  uint64_t f = 0;
  for (unsigned i = 0; i < w; i += k) f ^= (x >> i) & ((uint64_t(1) << k) - 1);
  return unsigned(f);
}
/// The fold of a page (PA[47:16], right-justified) into k bits: what MIU's
/// TLB keeps beside each PFN.
inline unsigned wayFoldTag(uint64_t tag, unsigned k) { return wayFoldField(tag, kWayFoldW, k); }
/// The fold of the page offset's tag bits, PA[15:7+setBits]: 0 at 512 sets
/// and above (MA-33 (3)).
inline unsigned wayFoldLow(uint64_t pa, unsigned k, unsigned setBits) {
  const unsigned lo = kWayFoldLine + setBits;
  return lo >= kWayFoldLo ? 0 : wayFoldField(pa >> lo, kWayFoldLo - lo, k);
}
/// The fold of a physical address's tag, PA[47:7+setBits], at a cache of
/// 2^setBits sets.
inline unsigned wayFold(uint64_t pa, unsigned k, unsigned setBits) {
  return wayFoldTag(pa >> kWayFoldLo, k) ^ wayFoldLow(pa, k, setBits);
}
/// log2 of a power-of-two set count.
inline unsigned wayFoldSetBits(unsigned sets) {
  unsigned b = 0;
  while ((1u << b) < sets) ++b;
  return b;
}

} // namespace skel
} // namespace ccv

#endif
