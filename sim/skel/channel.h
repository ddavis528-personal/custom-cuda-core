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
//   - LEAD fields (schema lead_fields) are the exception to "the payload
//     follows valid": that slice of the same register is written with valid.
//     On the wire it carries the lead of the message whose valid is up, while
//     the rest carries the previous message's payload; the receiver takes the
//     lead in the valid cycle and puts the message back together when the
//     rest lands. The lane mask is why (Q-40): a lane gates itself before
//     the operands it gates arrive.
//
// A slot is one of `rate` independent credited channels -- decided
// (interface decisions, 2026-09-24): the permissive superset, tightened per
// channel by the acceptance / ordering / slot_binding attributes.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_CHANNEL_H
#define CCV_SKEL_CHANNEL_H

#include "bits.h"

#include <deque>
#include <vector>

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

/// One end of a slot: the signals as the block at that end sees them.
struct SlotEnd {
  SlotSignals cur, nxt;
};

/// A slot: a sender's end and a receiver's end, and between them `stages`
/// sequential repeater stages (params/links.json), modelled flop for flop
/// as rtl/phys/ccv_seq_rpt.sv builds them. With no stages -- every abutted
/// link -- the two ends are one and the same, exactly the old model.
struct Slot {
  Bits lead_mask;        ///< payload bits driven with valid; empty if none
  bool has_lead = false;
  /// Negative control (--break late-lead): the lead is driven with the rest
  /// of the payload, a cycle late, while the receiver still takes it with
  /// valid. Nothing in a real run sets it.
  bool late_lead = false;
  explicit Slot(uint32_t bits, const Bits &lead = Bits(), unsigned stages = 0)
      : lead_mask(lead.size() ? lead : Bits(bits)), has_lead(lead.any()),
        pipe_(stages, Stage{false, false, false, Bits(bits), Bits(bits), 0}) {
    for (SlotEnd *e : {&a_, &b_})
      e->cur.payload = e->nxt.payload = Bits(bits);
  }

  unsigned stages() const { return unsigned(pipe_.size()); }
  SlotEnd &src() { return a_; }
  SlotEnd &dst() { return pipe_.empty() ? a_ : b_; }

  /// Start of a cycle. The payload register HOLDS unless its producer writes
  /// it; the pulse signals are rewritten by their drivers every cycle.
  void begin() {
    SlotEnd &s = src(), &d = dst();
    s.nxt.payload = s.cur.payload;
    s.nxt.tid = s.cur.tid;
    s.nxt.valid = false;
    d.nxt.credit = d.nxt.stall = false;
    if (pipe_.empty()) s.nxt.credit = s.nxt.stall = false;
  }

  /// End of a cycle: every flop takes its input. The ends' own registers,
  /// and the repeater stages between them, all at once.
  void commit() {
    if (pipe_.empty()) {
      a_.cur = a_.nxt;
      return;
    }
    const unsigned n = stages();
    std::vector<Stage> next(pipe_);
    for (unsigned k = 0; k != n; ++k) {
      const SlotSignals f = at(k), b = at(k + 1);
      Stage &q = next[k];
      q.valid = f.valid;                    // pulses: every cycle
      q.credit = b.credit;
      q.stall = b.stall;
      if (pipe_[k].valid) {                 // the previous cycle's valid
        q.pay = f.payload;
        q.tid = f.tid;
      }
      if (has_lead && f.valid)              // a lead rides with valid;
        q.lead = f.payload;                 // only its lead bits are read
    }
    pipe_ = std::move(next);
    a_.cur.valid = a_.nxt.valid;
    a_.cur.payload = a_.nxt.payload;
    a_.cur.tid = a_.nxt.tid;
    b_.cur.credit = b_.nxt.credit;
    b_.cur.stall = b_.nxt.stall;
    const SlotSignals head = at(0), tail = at(n);
    a_.cur.credit = head.credit;
    a_.cur.stall = head.stall;
    b_.cur.valid = tail.valid;
    b_.cur.payload = tail.payload;
    b_.cur.tid = tail.tid;
  }

  /// The link `node` stages from the sender, as a probe there would see it
  /// this cycle: forward signals after `node` stages, backward ones with
  /// stages() - node still to go. Where the checker bank watches.
  SlotSignals at(unsigned node) const {
    const unsigned n = stages();
    SlotSignals o;
    if (node == 0) {
      o.valid = a_.cur.valid;
      o.payload = a_.cur.payload;
      o.tid = a_.cur.tid;
    } else {
      const Stage &q = pipe_[node - 1];
      o.valid = q.valid;
      o.payload = q.pay;
      if (has_lead) o.payload.mergeFrom(q.lead, lead_mask);
      o.tid = q.tid;
    }
    if (node == n) {
      o.credit = (n ? b_ : a_).cur.credit;
      o.stall = (n ? b_ : a_).cur.stall;
    } else {
      o.credit = pipe_[node].credit;
      o.stall = pipe_[node].stall;
    }
    return o;
  }

private:
  struct Stage {
    bool valid, credit, stall;
    Bits pay, lead;
    uint64_t tid;
  };
  SlotEnd a_, b_;             ///< a_ the sender's end; b_ the receiver's
  std::vector<Stage> pipe_;   ///< stage k sits k stages from the sender
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
        promised_(s.src().cur.payload.size()) {}

  bool canSend() const { return credits_ != 0 && !s_.src().cur.stall; }

  /// Call exactly once per cycle. If `launch` (and allowed), a message is
  /// launched: valid rises next cycle and `msg` lands the cycle after.
  /// Returns whether a message was launched.
  bool cycle(bool launch, const Bits &msg, uint64_t tid = 0) {
    // The payload promised by the valid that is up THIS cycle goes on the
    // wire next cycle. Done before a new launch, which may be back to back.
    if (s_.src().cur.valid) {
      s_.src().nxt.payload = promised_;
      s_.src().nxt.tid = promised_tid_;
      ++landed_;
    }
    const bool go = launch && canSend();
    s_.src().nxt.valid = go;
    if (go) {
      promised_ = msg;
      promised_tid_ = tid;
      // The lead goes out WITH valid, into the same register, over whatever
      // the previous message's payload left in the rest of it.
      if (s_.has_lead && !s_.late_lead)
        s_.src().nxt.payload.mergeFrom(msg, s_.lead_mask);
    }
    // Same accounting as the RTL reference: a credit arriving this cycle is
    // not usable for a launch decided this cycle.
    if (go && !s_.src().cur.credit)
      --credits_;
    else if (!go && s_.src().cur.credit)
      ++credits_;
    if (go)
      ++sent_;
    return go;
  }

  /// Negative-control hooks. They exist to prove the checker bank is wired
  /// to the slot it claims to check; nothing in a real run calls them.
  void forceValid() { s_.src().nxt.valid = true; }
  /// ...carrying `msg`, so a control aimed at one property does not also
  /// trip a payload check (a binding key) with whatever was last promised.
  void forceValid(const Bits &msg) { promised_ = msg; s_.src().nxt.valid = true; }

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
      Bits p = s_.dst().cur.payload;
      // The lead was taken off the wire in the valid cycle; the wire's lead
      // slice now belongs to the NEXT message.
      if (s_.has_lead) {
        p.mergeFrom(leads_.front(), s_.lead_mask);
        leads_.pop_front();
      }
      buf_.push_back({p, s_.dst().cur.tid, now});
      // Credits bound what can be outstanding, so this cannot overflow if
      // the sender is correct. Checked here as well as by the checker bank:
      // two witnesses, and this one does not depend on the bank being wired.
      if (buf_.size() > depth_)
        ++overflows_;
    }
    landing_ = s_.dst().cur.valid;
    if (s_.has_lead && s_.dst().cur.valid)
      leads_.push_back(s_.dst().cur.payload);
  }

  bool empty() const { return buf_.empty(); }
  size_t size() const { return buf_.size(); }
  const Msg &front() const { return buf_.front(); }
  /// Every buffered message, oldest first -- a keyed-ordering receiver needs
  /// to see past the head to know whether a head is the oldest of its key.
  const Msg &at(size_t i) const { return buf_[i]; }

  /// Consume the oldest message; its credit goes back next cycle. A second
  /// pop in the same cycle would return one credit for two messages -- a
  /// credit LOST, silently: the sender runs one short for ever, and the
  /// checker only notices once the orphan ages out on an idle slot. The S0
  /// exerciser did exactly that, 7 to 10 times a run, until repeated links
  /// deepened the queues enough to starve a slot. Counted, and required 0.
  void pop() {
    if (s_.dst().nxt.credit)
      ++leaks_;
    buf_.pop_front();
    s_.dst().nxt.credit = true;
    ++received_;
  }
  void stall(bool on) { s_.dst().nxt.stall = on; }

  /// Negative-control hook: a credit for nothing.
  void forceCredit() { s_.dst().nxt.credit = true; }

  uint64_t received() const { return received_; }
  uint64_t overflows() const { return overflows_; }
  uint64_t leaks() const { return leaks_; }

private:
  Slot &s_;
  unsigned depth_;
  std::deque<Msg> buf_;
  std::deque<Bits> leads_;   ///< lead slices taken in valid cycles, in order
  bool landing_ = false;
  uint64_t received_ = 0, overflows_ = 0, leaks_ = 0;
};

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_CHANNEL_H
