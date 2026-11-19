//===-- miu_test.cpp - unit tests of the MIU model's resources ------------===//
//
// Each test holds one structure of miu_res.h to its sentence in the MIU tab,
// and each has a negative: the broken behaviour the test must refuse.
// Run by sim/miu/run-tests.sh (the check-miu-unit job, MI-1).
//===----------------------------------------------------------------------===//
#include "miu_res.h"

#include <cstdio>
#include <cstdlib>

using namespace ccv::miu;

static int fails = 0, checks = 0;
#define CHECK(c)                                                              \
  do {                                                                        \
    ++checks;                                                                 \
    if (!(c)) {                                                               \
      ++fails;                                                                \
      std::fprintf(stderr, "%s:%d: FAIL %s\n", __FILE__, __LINE__, #c);       \
    }                                                                         \
  } while (0)

// MA-5: 10 credits a slot; an entry frees on its arrival slot; a slot
// returns at most one credit a cycle, so two frees in a cycle take two.
static void memopCredits() {
  MemopCredits mc(4, 10);
  for (unsigned i = 0; i != 10; ++i) CHECK(mc.arrive(2));
  CHECK(!mc.arrive(2));                 // the 11th on slot 2: refused
  CHECK(mc.arrive(0));                  // other slots unaffected
  CHECK(mc.heldTotal() == 11);
  CHECK(mc.free(2) && mc.free(2));      // two entries of slot 2 free at once
  CHECK(mc.owed(2) == 2);
  CHECK(!mc.arrive(2));                 // owed credits are not OOE's yet
  CHECK(mc.tick(false) == 0x4u);        // one pulse on slot 2 ...
  CHECK(mc.tick(false) == 0x4u);        // ... and the second a cycle later
  CHECK(mc.tick(false) == 0);
  CHECK(mc.owedPastOneCycles() == 1);
  CHECK(mc.arrive(2));
  CHECK(!mc.free(1));                   // slot 1 holds nothing: refused
  // The drain guard keeps one owed credit back while set.
  CHECK(mc.free(0));
  CHECK(mc.tick(true) == 0);
  CHECK(mc.tick(true) == 0);
  CHECK(mc.withheldCycles() == 2);
  CHECK(mc.tick(false) == 0x1u);
  // With two owed on the guarded slot, one still goes.
  CHECK(mc.arrive(0) && mc.arrive(0) && mc.free(0) && mc.free(0));
  CHECK(mc.tick(true) == 0x1u);
  CHECK(mc.tick(true) == 0);
}

// MA-25: entry credits per bank; a store needs an entry and a store-data
// credit; returns refill; a return past the reset count is refused.
static void bankCredits() {
  BankCredits bc(8, 16, 12);
  for (unsigned i = 0; i != 12; ++i) CHECK(bc.take(3, true));
  CHECK(!bc.can(3, true));              // store data spent
  CHECK(bc.can(3, false));              // a lookup still has entries
  for (unsigned i = 0; i != 4; ++i) CHECK(bc.take(3, false));
  CHECK(!bc.can(3, false) && !bc.take(3, false));
  CHECK(bc.can(4, true));               // banks are independent
  CHECK(bc.ret(1u << 3, 0) && bc.can(3, false) && !bc.can(3, true));
  CHECK(bc.ret(0, 1u << 3) && bc.can(3, true));
  CHECK(!bc.ret(1u << 5, 0));           // bank 5 spent nothing
  BankCredits full(8, 16, 12);
  CHECK(full.allHome());
}

// MA-8: 32 entries, fully associative, LRU.
static void tlb() {
  Tlb t(4);
  for (uint64_t p = 0; p != 4; ++p) { CHECK(!t.lookup(p)); t.fill(p); }
  CHECK(t.lookup(0));                   // 0 is now the most recent
  t.fill(9);                            // evicts 1, the least recent
  CHECK(t.holds(0) && !t.holds(1) && t.holds(9));
  t.fill(9);                            // a page held twice is one entry
  CHECK(t.holds(2) && t.holds(3));
  t.clear();
  CHECK(!t.holds(0) && !t.holds(9));
  CHECK(t.hits() == 1 && t.misses() == 4);
}

// MA-8 with MI-2's default: one walk at a time, oldest first, two dependent
// reads, requests for one page merged, FET's wait behind a data walk counted.
static void walker() {
  Walker w(2, uint64_t(0xF0) << 40, 16);
  uint64_t a = 0;
  CHECK(w.idle() && !w.wantRead(a));
  w.request(0x12345, Walker::kData);
  w.request(0x777, Walker::kItlb);      // waits behind the data walk
  w.request(0x12345, Walker::kItlb);    // merges into the queued data walk
  w.cycle();
  CHECK(w.busy() && w.wantRead(a));
  CHECK(a == (uint64_t(0xF0) << 40) + 0x0001 * 8);   // level 0: VPN bits [31:16]
  w.sent();
  CHECK(!w.wantRead(a));                // one read in flight at a time
  w.cycle();
  CHECK(!w.got());                      // level 0 back: not done
  CHECK(w.wantRead(a));
  CHECK(a == (uint64_t(0xF0) << 40) + (uint64_t(1) << 24) + 0x2345 * 8);
  w.sent();
  CHECK(w.got());                       // level 1 back: done
  CHECK(w.doneVpn() == 0x12345 && w.doneSrc() == (Walker::kData | Walker::kItlb));
  w.cycle();                            // the ITLB's walk starts next
  CHECK(w.busy() && w.walks() == 2);
  w.sent();
  w.got();
  w.sent();
  CHECK(w.got() && w.doneVpn() == 0x777 && w.doneSrc() == Walker::kItlb);
  CHECK(w.itlbWaits() == 1);
  CHECK(w.idle());
}

int main() {
  memopCredits();
  bankCredits();
  tlb();
  walker();
  std::printf("miu unit: %d checks, %d failed\n", checks, fails);
  return fails ? 1 : 0;
}
