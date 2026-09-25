//===-- exerciser.h - Stage 3 S0: every slot, real traffic -------*- C++ -*-===//
//
// The first stub every block gets, before any instruction semantics exist.
// Each output slot sends a deterministic stream of messages; each input slot
// checks every message bit-for-bit against what its sender must have sent, in
// order. Sending, consuming and stalling are all randomised, so the credit
// protocol is exercised under real backpressure rather than a clean pipe.
//
// What that proves, before any block does anything real: every channel
// instance is wired to the right two ends, every slot carries traffic, the
// protocol holds under backpressure (the checker bank says so), and every
// payload bit arrives where the field table says it should. Every later stub
// replaces this one behind the same ports.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_EXERCISER_H
#define CCV_SKEL_EXERCISER_H

#include "machine.h"

#include <cstdint>

namespace ccv {
namespace skel {

struct ExerciseCfg {
  uint64_t seed = 1;
  double p_send = 0.7;    ///< chance a producer wants to send, per slot-cycle
  double p_pop = 0.6;     ///< chance a consumer drains, per slot-cycle
  double p_stall = 0.05;  ///< chance a consumer starts a 1-3 cycle stall
};

/// The payload for message `seq` on a slot, every bit derived from
/// (channel instance, slot, seq). Filled FIELD BY FIELD through the generated
/// table, so the layout code is exercised, not bypassed.
Bits expectedPayload(const ChanInst &ci, unsigned slot, uint64_t seq);

std::unique_ptr<Block> makeExerciser(int inst, const ExerciseCfg &cfg);

struct ExerciseTotals {
  uint64_t sent = 0, received = 0, mismatches = 0;
};
/// Summed over every exerciser -- mismatches are payloads that arrived wrong.
ExerciseTotals exerciseTotals();

/// While draining, producers stop launching and consumers keep consuming,
/// so a run ends with every launched message delivered. That is what makes
/// "sent == received" an exact check rather than an approximate one.
void setDraining(bool on);

/// Every (channel id, payload bits 31:0 and 63:32) the senders launched. Compared
/// against the checker bank's EV_CH_XFER events, which proves the bank sees
/// the payload bits the channel actually carried.
struct Launched { uint16_t chan; uint32_t lo32, hi32; };
const std::vector<Launched> &launchedLog();

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_EXERCISER_H
