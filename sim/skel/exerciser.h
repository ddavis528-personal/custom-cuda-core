//===-- exerciser.h - Stage 3 S0: every slot, real traffic -------*- C++ -*-===//
//
// The first stub every block gets, before any instruction semantics exist.
// Each output channel instance sends a deterministic stream of messages;
// each input checks every message bit for bit against what its sender must
// have sent. Sending, consuming and stalling are randomised, so the credit
// protocol runs under real backpressure rather than a clean pipe.
//
// It honours every slot attribute, because a stub that ignored them would be
// the first receiver "written assuming" what they exist to rule out:
//
//   atomic      a group launches on every slot of an instance or none, and is
//               consumed whole
//   lockstep    slot k moves on every instance or none. The decision comes
//               from a hash of (channel, slot, cycle) shared by every block,
//               not a block's private RNG -- 32 lane blocks deciding
//               independently would break lockstep by construction
//   binding     slots stay separate streams; nothing pools them
//   ordering    none: per-slot FIFO only. slot_group: one sequence per
//               binding group, consumed oldest-first. A field key (warp_id):
//               one sequence per VALUE of the field, and a head may be taken
//               only if no older message shares its key -- so different
//               warps pass each other and one warp never passes itself
//
// A message's payload and trace id are pure functions of its stream (slot,
// group or key value) and its sequence in that stream, so consuming out of
// order shows up as a payload mismatch. On a lockstep channel the id ignores
// the instance: slot k carries the same instruction on every lane.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_EXERCISER_H
#define CCV_SKEL_EXERCISER_H

#include "machine.h"

#include <cstdint>
#include <string>
#include <vector>

namespace ccv {
namespace skel {

struct ExerciseCfg {
  uint64_t seed = 1;
  double p_send = 0.7;    ///< chance a producer wants to send, per decision
  double p_pop = 0.6;     ///< chance a consumer drains, per decision
  double p_stall = 0.05;  ///< chance a consumer starts a 1-3 cycle stall
  bool force_atomic = false;  ///< treat EVERY multi-slot channel as atomic
  bool misorder = false;      ///< negative control: take a head that is NOT
                              ///< the oldest of its stream/key
  bool wrong_class = false;   ///< negative control: stamp an id class the
                              ///< channel may not carry
  bool misbind = false;       ///< negative control: on lane 7 of a lockstep
                              ///< channel, carry slot k+1's id in slot k
  bool misgroup = false;      ///< negative control: a binding key naming the
                              ///< wrong group, on every keyed channel
  bool double_pop = false;    ///< negative control: a keyed receiver may take
                              ///< one slot twice a cycle -- two consumed, one
                              ///< credit: the leak it had until 2026-09-26
};

/// Stream of a message: its slot, its binding group, or its key value.
uint64_t streamOf(const ChanDesc &cd, unsigned slot, uint64_t keyval);
Bits expectedPayload(const ChanInst &ci, uint64_t stream, uint64_t seq,
                     uint64_t keyval);
uint64_t expectedTid(const ChanInst &ci, uint64_t stream, uint64_t seq);

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
/// Append to that log. The exerciser logs its own launches; S1's functional
/// stubs call this so the same bank-vs-launch comparison covers them.
void logLaunch(uint16_t chan, const Bits &msg, uint64_t tid);

/// The bank's EV_CH_XFER events in `trace` must carry exactly the payloads
/// the senders launched: same channel, same bits 63:0, same trace identity,
/// same multiset. Prints the XFER line; returns nonzero only if the trace
/// cannot be read.
int xferCheck(const std::string &trace);

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_EXERCISER_H
