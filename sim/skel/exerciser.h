//===-- exerciser.h - Stage 3 S0: every slot, real traffic -------*- C++ -*-===//
//
// The first stub every block gets, before any instruction semantics exist.
// Each output channel instance sends a deterministic stream of messages;
// each input checks every message bit for bit against what its sender must
// have sent. Sending, consuming and stalling are randomised, so the credit
// protocol runs under real backpressure rather than a clean pipe.
//
// It honours the per-channel slot attributes (interface decisions,
// 2026-09-24), because a stub that ignored them would be the first receiver
// "written assuming" what the attributes exist to rule out:
//   atomic   -- a group launches on every slot or none, and is consumed whole
//   ordered  -- one sequence across slots, consumed in (arrival, slot) order;
//               the payload is keyed on that sequence, so consuming out of
//               order is a payload mismatch
//   bound    -- slots are kept separate streams; nothing pools them
//
// Every message also carries a trace identity whose class must be one the
// channel may carry. The ids are synthetic here -- a pure function of the
// message, like the payload -- because S0 has no fetch to number them at.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_EXERCISER_H
#define CCV_SKEL_EXERCISER_H

#include "machine.h"

#include <cstdint>

namespace ccv {
namespace skel {

struct ExerciseCfg {
  uint64_t seed = 1;
  double p_send = 0.7;    ///< chance a producer wants to send, per decision
  double p_pop = 0.6;     ///< chance a consumer drains, per decision
  double p_stall = 0.05;  ///< chance a consumer starts a 1-3 cycle stall
  bool force_atomic = false;  ///< treat EVERY multi-slot channel as atomic
  bool misorder = false;      ///< negative control: consume ordered channels
                              ///< newest-first
  bool wrong_class = false;   ///< negative control: stamp an id class the
                              ///< channel may not carry
};

/// Payload for a message. `key` is the slot sequence, or the channel
/// sequence on an ordered channel. Filled FIELD BY FIELD through the
/// generated table, so the layout code is exercised, not bypassed.
Bits expectedPayload(const ChanInst &ci, unsigned slot, uint64_t key);
/// Trace identity for the same message: class drawn from the channel's set.
uint64_t expectedTid(const ChanInst &ci, unsigned slot, uint64_t key);

std::unique_ptr<Block> makeExerciser(int inst, const ExerciseCfg &cfg);

struct ExerciseTotals {
  uint64_t sent = 0, received = 0;
  uint64_t mismatches = 0;       ///< payload wrong -- including out of order
  uint64_t tid_mismatches = 0;   ///< identity wrong
  uint64_t class_violations = 0; ///< id class the channel may not carry
  unsigned class_violation_channels = 0;  ///< distinct channels reporting one
};
ExerciseTotals exerciseTotals();

/// While draining, producers stop launching and consumers keep consuming,
/// so a run ends with every launched message delivered. That is what makes
/// "sent == received" an exact check rather than an approximate one.
void setDraining(bool on);

/// Every message launched: channel, payload bits 63:0, and identity.
/// Compared against the checker bank's EV_CH_XFER events, which proves the
/// bank sees the payload AND the trace sideband the channel carried.
struct Launched { uint16_t chan; uint32_t lo32, hi32; uint64_t tid; };
const std::vector<Launched> &launchedLog();

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_EXERCISER_H
