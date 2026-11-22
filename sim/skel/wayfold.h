//===-- wayfold.h - the L1 way predictor's fold, as the RTL computes it -*- C++ -*-===//
//
// The C++ host's view of rtl/common/ccv_common_wayfold.sv, bit for bit
// (tools/check-skel.sh's lockstep, test/vl/vl_wayfold_tb.cpp, holds the two
// together, as it does secded.h and the SECDED helpers). MA-30, AR 405 and
// MA's response to it (MA tab rev 155): one fold, used by MIU (each TLB
// entry keeps fold(PFN) beside its PFN, written at the fill; A2 sends it as
// ccv_miu_dcu_req's pa_fold) and by DCU's fold-table write at a fill.
//
// The tag is PA[47:16], above the 7 line-offset bits and the 9 set-and-bank
// bits; with CCV_L_PAGE_SHIFT 16 it is exactly the PFN. fold(PA) is the XOR
// of the tag's k-bit chunks from bit 16 upward, the last chunk
// zero-extended: 8 chunks at k = 4. k = 0 is no prediction, fold 0.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_WAYFOLD_H
#define CCV_SKEL_WAYFOLD_H

#include <cstdint>

namespace ccv {
namespace skel {

constexpr unsigned kWayFoldLo = 16;   ///< the tag's low PA bit
constexpr unsigned kWayFoldW = 32;    ///< the tag's width, PA[47:16]

/// The fold of a tag (PA[47:16], right-justified) into k bits.
inline unsigned wayFoldTag(uint64_t tag, unsigned k) {
  if (!k) return 0;
  tag &= (uint64_t(1) << kWayFoldW) - 1;
  uint64_t f = 0;
  for (unsigned i = 0; i < kWayFoldW; i += k) f ^= (tag >> i) & ((uint64_t(1) << k) - 1);
  return unsigned(f);
}
/// The fold of a physical address's tag.
inline unsigned wayFold(uint64_t pa, unsigned k) { return wayFoldTag(pa >> kWayFoldLo, k); }

} // namespace skel
} // namespace ccv

#endif
