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
//   - the receiver returns one credit per message it consumes: by default
//     (CreditAt::Pop) the cycle after the pop that consumes it, so a message
//     taken the cycle it lands (valid at t, payload at t+1) credits at t+2;
//     under CreditAt::Landing (Receiver::creditAt; RI-36 (2), RI-37 (0)) in
//     the landing cycle itself, t+1, from the receiver's flop of valid, as an
//     RTL receiver's `<ch>_credit = <ch>_v_q` does. A two-phase model cannot
//     decide that credit in the landing cycle (what a block writes there is
//     seen a cycle later), so it is a mode, armed before the first message:
//     Receiver::cycle drives the credit in the valid cycle, nxt, and pop
//     drives none. The block must then take each message the cycle it
//     lands, as the RTL does, or corLate() counts it -- the same promise as
//     credit on receipt (Slot::cor, RA-41), whose credit is the boundary
//     stage's flop of valid rather than the block's own.
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

#include <algorithm>
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
/// as rtl/phys/ccv_common_rpt.sv builds them. With no stages -- every abutted
/// link -- the two ends are one and the same, exactly the old model.
struct Slot {
  Bits lead_mask;        ///< payload bits driven with valid; empty if none
  bool has_lead = false;
  /// Negative control (--break late-lead): the lead is driven with the rest
  /// of the payload, a cycle late, while the receiver still takes it with
  /// valid. Nothing in a real run sets it.
  bool late_lead = false;
  /// Credit on receipt (ChanInst::cor; params/links.json, AR's rev 322,
  /// RA-41): the last stage, the receiving end's boundary flop, loads its
  /// credit from its own valid flop, as rtl/phys/ccv_common_rpt.sv's
  /// CREDIT_ON_RECEIPT does; the receiver's credit is not read. Its receiver
  /// takes every message the cycle it lands, or counts corLate().
  bool cor = false;
  /// Negative controls on a credit-on-receipt slot; nothing in a real run
  /// sets them. cor_series: one more flop in series on that credit, the
  /// register credit on receipt exists to remove (--break fixed-all: the
  /// credit a cycle past landing). cor_inject: a credit for nothing out of
  /// the boundary stage this cycle (--break phantom-all), set by
  /// Receiver::forceCredit, since the block has no credit of its own there.
  bool cor_series = false;
  bool cor_inject = false;
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
      if (cor && k + 1 == n) {              // the boundary stage's own valid
        q.credit = cor_series ? cor_q_ : pipe_[k].valid;
        cor_q_ = pipe_[k].valid;
        q.credit = q.credit || cor_inject;
        cor_inject = false;
      }
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
  bool cor_q_ = false;        ///< cor_series's flop
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
/// When a Receiver returns a message's credit (see THE PROTOCOL above).
enum class CreditAt {
  Pop,       ///< the cycle after the pop that consumes it (the default)
  Landing,   ///< the cycle its payload lands: credit = the flop of valid
  Release,   ///< when the block calls release(): the resource the message
             ///< holds frees (a memop's queue entry, MA-5, AR rev 345), one
             ///< credit a cycle, the cycle after release() when the wire is free
};

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
    now_ = now;
    // Credit on receipt: the wrapper returned this slot's credit the cycle
    // each message was presented, on the block's promise to take it in the
    // cycle it lands here. One still buffered from an earlier cycle was
    // taken late, or dropped: counted every cycle it stays, and required 0
    // (AR's rev 322 (b)).
    if (s_.cor || land_credit_)
      cor_late_ += buf_.size() + held_.size();
    if (release_) {                 // holdNext(false): a cycle late
      for (Msg &m : held_) buf_.push_back(m);
      held_.clear();
      release_ = false;
    }
    if (landing_) {
      Bits p = s_.dst().cur.payload;
      // The lead was taken off the wire in the valid cycle; the wire's lead
      // slice now belongs to the NEXT message.
      if (s_.has_lead) {
        p.mergeFrom(leads_.front(), s_.lead_mask);
        leads_.pop_front();
      }
      if (hold_ && s_.cor) {
        held_.push_back({p, s_.dst().cur.tid, now});
        release_ = hold_ == 1;
        hold_ = 0;
      } else {
        buf_.push_back({p, s_.dst().cur.tid, now});
      }
      // Credits bound what can be outstanding, so this cannot overflow if
      // the sender is correct. Checked here as well as by the checker bank:
      // two witnesses, and this one does not depend on the bank being wired.
      if (buf_.size() > depth_)
        ++overflows_;
    }
    landing_ = s_.dst().cur.valid;
    // CreditAt::Landing: the credit is the flop of this valid, up the cycle
    // its payload lands (t+1), whether or not the block pops then.
    if (land_credit_ && landing_)
      s_.dst().nxt.credit = true;
    // CreditAt::Release: one owed credit a cycle, the wire being one bit.
    if (rel_credit_ && owed_) {
      s_.dst().nxt.credit = true;
      --owed_;
    }
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
  ///
  /// On a credit-on-receipt slot (Slot::cor) the block has no credit: the
  /// wrapper's boundary stage returned it when the message was presented,
  /// and the SV top has no port for one, so pop drives none.
  ///
  /// Under CreditAt::Landing, likewise: the credit went back the cycle the
  /// message landed (cycle() drove it), so pop drives none.
  void pop() {
    const bool drives = !s_.cor && !land_credit_ && !rel_credit_;
    if (drives && s_.dst().nxt.credit)
      ++leaks_;
    max_age_ = std::max(max_age_, now_ - buf_.front().arrived);
    buf_.pop_front();
    if (drives) s_.dst().nxt.credit = true;
    ++received_;
  }
  /// When this receiver returns credits (CreditAt; THE PROTOCOL above).
  /// Set it before the first message is presented -- a block's first
  /// cycle -- and never change it: a message presented under one mode and
  /// popped under the other would lose its credit or return two. Landing on a credit-on-receipt slot changes nothing but
  /// pop (which drives none there anyway): the boundary stage returns it.
  void creditAt(CreditAt c) {
    land_credit_ = c == CreditAt::Landing && !s_.cor;
    rel_credit_ = c == CreditAt::Release && !s_.cor;
  }
  CreditAt creditAt() const {
    return land_credit_ ? CreditAt::Landing : rel_credit_ ? CreditAt::Release : CreditAt::Pop;
  }
  /// CreditAt::Release: the resource one popped message held is free, so
  /// its credit goes up next cycle, or the first cycle after with the
  /// wire free, released credits in order.
  /// More releases than pops is the block's error: counted, required 0.
  void release() {
    if (!rel_credit_) return;   // credits on pop or landing: nothing owed
    if (released_ == received_) { ++over_released_; return; }
    ++released_;
    if (s_.dst().nxt.credit) ++owed_;   // the wire's one bit is taken
    else s_.dst().nxt.credit = true;    // up next cycle, as pop() drives
  }
  /// Credits a CreditAt::Release block owes still: popped and not released,
  /// plus released and not yet driven. A block's end-of-run quiesce.
  uint64_t unreleased() const { return received_ - released_ + owed_; }
  uint64_t overReleased() const { return over_released_; }
  void stall(bool on) { s_.dst().nxt.stall = on; }

  /// Negative-control hook: a credit for nothing. On a credit-on-receipt
  /// slot the block has no credit, so it comes out of the boundary stage.
  void forceCredit() {
    if (s_.cor) s_.cor_inject = true;
    else s_.dst().nxt.credit = true;
  }
  /// Negative-control hook (--break cor-late): the next message to land
  /// reaches the block a cycle late, as a block that takes it a cycle after
  /// it is presented, or drops it if `drop`. Credit-on-receipt slots only.
  void holdNext(bool drop) { hold_ = drop ? 2 : 1; }

  uint64_t received() const { return received_; }
  uint64_t overflows() const { return overflows_; }
  uint64_t leaks() const { return leaks_; }
  /// Credit on receipt or CreditAt::Landing: message-cycles a landed
  /// message sat here past the cycle it landed in (taken late or never).
  /// Required 0.
  uint64_t corLate() const { return cor_late_; }
  /// The longest a message waited here, from landing to being taken: a
  /// backpressured channel's measured maximum age (AR's response TI-22).
  uint64_t maxAge() const { return max_age_; }

private:
  Slot &s_;
  unsigned depth_;
  std::deque<Msg> buf_;
  std::deque<Bits> leads_;   ///< lead slices taken in valid cycles, in order
  bool landing_ = false;
  bool land_credit_ = false; ///< CreditAt::Landing
  bool rel_credit_ = false;  ///< CreditAt::Release
  uint64_t owed_ = 0, released_ = 0, over_released_ = 0;
  uint64_t received_ = 0, overflows_ = 0, leaks_ = 0, cor_late_ = 0;
  unsigned hold_ = 0;        ///< holdNext armed: 1 a cycle late, 2 dropped
  bool release_ = false;     ///< hand held_ to the block this cycle
  std::deque<Msg> held_;     ///< what holdNext keeps from the block
  uint64_t now_ = 0, max_age_ = 0;   ///< the cycle, and the longest wait (maxAge)
};

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_CHANNEL_H
