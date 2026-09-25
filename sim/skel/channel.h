//===-- channel.h - one credited slot, both ends ----------------*- C++ -*-===//
//
// THE CYCLE MODEL, and why it is this simple. Every boundary is registered on
// both sides, no exceptions (the grill-me's round-trip rule). So no
// combinational path crosses a block boundary, and a cycle is two phases:
//
//   1. every block reads `cur` -- the flop outputs during cycle t -- and
//      writes `nxt`, the flop outputs during cycle t+1;
//   2. every slot commits nxt -> cur.
//
// Block evaluation order cannot matter, because nothing reads `nxt`. That is
// what lets a Verilated RTL block sit in the same place: it is clocked with
// `cur` on its inputs and its outputs land in `nxt`.
//
// THE PROTOCOL, implemented once here so no stub can get it wrong:
//   - a credit is consumed at the edge that launches valid
//   - the payload follows valid by exactly one cycle, binding even if a stall
//     arrives in between
//   - no valid the cycle after a stall -- the stall seen THIS cycle gates the
//     valid launched for next cycle (test/smoke/credit_smoke.sv used a
//     registered stall, one cycle late, and violated this at 14 of 28 phases)
//   - the receiver returns one credit per message it consumes
//
// A slot is one of `rate` independent credited channels -- decided
// (interface decisions, 2026-09-24): the permissive superset, tightened per
// channel by the acceptance / ordering / slot_binding attributes.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_CHANNEL_H
#define CCV_SKEL_CHANNEL_H

#include "bits.h"

#include <deque>

namespace ccv {
namespace skel {

struct SlotSignals {
  bool valid = false;   ///< producer
  Bits payload;         ///< producer; meaningful the cycle after valid
  /// TRACE-ONLY identity of the message whose payload is on the wire. Beside
  /// the payload, never inside it: the RTL carries it in a sideband that
  /// exists only under CCV_TRACE (schema/events.json uid_layout).
  uint64_t tid = 0;
  bool credit = false;  ///< consumer
  bool stall = false;   ///< consumer
};

struct Slot {
  SlotSignals cur, nxt;
  explicit Slot(uint32_t bits) { cur.payload = nxt.payload = Bits(bits); }

  /// Start of a cycle. The payload register HOLDS unless its producer writes
  /// it; the pulse signals are rewritten by their drivers every cycle.
  void begin() {
    nxt.payload = cur.payload;
    nxt.tid = cur.tid;
    nxt.valid = nxt.credit = nxt.stall = false;
  }
  void commit() { cur = nxt; }
};

/// Producer end.
class Sender {
public:
  // promised_ has the slot's width from the start, like the RTL register it
  // models. It began as a zero-width Bits, which no ordinary run can expose
  // -- a launch always sets it -- but the stall-all negative control forces a
  // valid with no launch, put a zero-width payload on the wire, and aborted.
  Sender(Slot &s, unsigned depth)
      : s_(s), depth_(depth), credits_(depth),
        promised_(s.cur.payload.size()) {}

  bool canSend() const { return credits_ != 0 && !s_.cur.stall; }

  /// Call exactly once per cycle. If `launch` (and allowed), a message is
  /// launched: valid rises next cycle and `msg` lands the cycle after.
  /// Returns whether a message was launched.
  bool cycle(bool launch, const Bits &msg, uint64_t tid = 0) {
    // The payload promised by the valid that is up THIS cycle goes on the
    // wire next cycle. Done before a new launch, which may be back to back.
    if (s_.cur.valid) {
      s_.nxt.payload = promised_;
      s_.nxt.tid = promised_tid_;
      ++landed_;
    }
    const bool go = launch && canSend();
    s_.nxt.valid = go;
    if (go) {
      promised_ = msg;
      promised_tid_ = tid;
    }
    // Same accounting as the RTL reference: a credit arriving this cycle is
    // not usable for a launch decided this cycle.
    if (go && !s_.cur.credit)
      --credits_;
    else if (!go && s_.cur.credit)
      ++credits_;
    if (go)
      ++sent_;
    return go;
  }

  /// Negative-control hooks. They exist to prove the checker bank is wired
  /// to the slot it claims to check; nothing in a real run calls them.
  void forceValid() { s_.nxt.valid = true; }

  uint64_t sent() const { return sent_; }
  unsigned credits() const { return credits_; }
  unsigned depth() const { return depth_; }

private:
  Slot &s_;
  unsigned depth_;
  unsigned credits_;
  Bits promised_;
  uint64_t promised_tid_ = 0;
  uint64_t sent_ = 0, landed_ = 0;
};

/// Consumer end.
class Receiver {
public:
  struct Msg {
    Bits payload;
    uint64_t tid;       ///< trace identity, beside the payload
    uint64_t arrived;   ///< cycle the payload landed: the ORDER key, with slot
  };

  Receiver(Slot &s, unsigned depth) : s_(s), depth_(depth) {}

  /// Call exactly once per cycle, before front()/pop(). Captures a payload
  /// that lands this cycle.
  void cycle(uint64_t now) {
    if (landing_) {
      buf_.push_back({s_.cur.payload, s_.cur.tid, now});
      // Credits bound what can be outstanding, so this cannot overflow if
      // the sender is correct. Checked here as well as by the checker bank:
      // two witnesses, and this one does not depend on the bank being wired.
      if (buf_.size() > depth_)
        ++overflows_;
    }
    landing_ = s_.cur.valid;
  }

  bool empty() const { return buf_.empty(); }
  const Msg &front() const { return buf_.front(); }

  /// Consume the oldest message; its credit goes back next cycle.
  void pop() {
    buf_.pop_front();
    s_.nxt.credit = true;
    ++received_;
  }
  void stall(bool on) { s_.nxt.stall = on; }

  /// Negative-control hook: a credit for nothing.
  void forceCredit() { s_.nxt.credit = true; }

  uint64_t received() const { return received_; }
  uint64_t overflows() const { return overflows_; }

private:
  Slot &s_;
  unsigned depth_;
  std::deque<Msg> buf_;
  bool landing_ = false;
  uint64_t received_ = 0, overflows_ = 0;
};

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_CHANNEL_H
