//===-- channel_test.cpp - Receiver credit timing, alone ---------*- C++ -*-===//
//
// When a Receiver's credit reaches the wire (channel.h, THE PROTOCOL), on one
// slot driven cycle by cycle as the machine does: begin, the ends, commit.
// One message launched in cycle 0 is valid in cycle 1 and lands in cycle 2,
// where the block pops it. The credit at the receiver's end must be up in
//   CreditAt::Pop      cycle 3 only (a cycle after the pop: unchanged)
//   CreditAt::Landing  cycle 2 only (the landing cycle, as <ch>_v_q)
// and at the sender back home, on an abutted slot and on one with repeater
// stages. Its controls, each of which must fail the property it guards:
//   late     under Landing, the block takes the message a cycle after it
//            lands: corLate() counts it
//   swapped  the two modes' expectations exchanged: both runs mismatch
// Prints one line; exits 0 when every check and every control holds.
//===----------------------------------------------------------------------===//
#include "channel.h"

#include <cstdio>
#include <string>

using namespace ccv::skel;

namespace {

struct Run {
  std::string credit;   // the cycles the receiver's end shows a credit, "2,..."
  uint64_t late = 0, leaks = 0, received = 0;
  unsigned home = 0;    // the sender's credits at the end
};

Run run(CreditAt mode, unsigned stages, unsigned pop_at) {
  Slot s(8, Bits(), stages);
  Sender tx(s, 1);
  Receiver rx(s, 1);
  rx.creditAt(mode);
  Bits msg(8);
  msg.set(0, 8, 0x5a);
  Run r;
  for (uint64_t t = 0; t != 12; ++t) {
    s.begin();
    rx.cycle(t);
    if (t == pop_at && !rx.empty()) rx.pop();
    tx.cycle(t == 0, msg, 0);
    if (s.at(s.stages()).credit)
      r.credit += (r.credit.empty() ? "" : ",") + std::to_string(t);
    s.commit();
  }
  r.late = rx.corLate();
  r.leaks = rx.leaks();
  r.received = rx.received();
  r.home = tx.credits();
  return r;
}

} // namespace

int main() {
  int bad = 0;
  auto expect = [&](bool c, const char *what) {
    if (!c) {
      std::printf("channel_test: FAIL %s\n", what);
      ++bad;
    }
  };
  for (unsigned st : {0u, 2u}) {
    // The payload lands stages cycles later on a repeated slot.
    const unsigned land = 2 + st;
    const Run p = run(CreditAt::Pop, st, land);
    const Run l = run(CreditAt::Landing, st, land);
    expect(p.credit == std::to_string(land + 1), "Pop: credit a cycle after the pop");
    expect(l.credit == std::to_string(land), "Landing: credit in the landing cycle");
    expect(p.received == 1 && l.received == 1, "one message received");
    expect(p.home == 1 && l.home == 1, "the credit back home");
    expect(!p.leaks && !l.leaks && !p.late && !l.late, "no leak, nothing late");
    // Control late: a block that takes it a cycle after it lands.
    const Run k = run(CreditAt::Landing, st, land + 1);
    expect(k.late == 1, "control late: a late take under Landing counted");
    // Control swapped: each mode held to the other's cycle must mismatch.
    expect(p.credit != std::to_string(land) && l.credit != std::to_string(land + 1),
           "control swapped: the modes distinguishable");
  }
  if (!bad)
    std::printf("channel_test: Pop credits at landing+1, Landing at landing "
                "(0 and 2 stages); controls late, swapped caught\n");
  return bad ? 1 : 0;
}
