//===-- decrx_tb.cpp - ooe_decrx and its arrival compare against the model -===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode) and,
// just before every core cycle, takes the model's log of the cycle just run
// (Core::rxLog): the slots whose warp's epoch advanced (at a redirect, or
// at a demotion's or a kill's epoch notice), the slots released,
// the allocations, and every uop that arrived after the cycle (kept or
// dropped, with its warp and fetch_epoch), plus each slot's warp and its
// warp's epoch after it, and the slots ooe_decq flushed (Core::decqFlushed).
//
// The model's arrivals come after its cycle's events, so they compare
// against the epochs those events left: the RTL's events and arrivals share
// a drive, and the compare takes an advancing slot's next epoch, or the one
// after when a redirect and a notice land together (OA 428 (2)).
// A release and an allocation take effect from the next drive; an arrival
// for a warp allocated or released in its own drive is counted and fails
// the bench (the RTL has no bypass for it).
//
// The RTL runs one log behind, so the event lead (ev_l) goes a tick before
// its events. Per drive: every port's keep and slot must be the model's (a
// dropped uop takes no decode-queue entry, so it never counts against
// ooe_decq's credits: used_cq02h is decq_tb's, unchanged); after the edge,
// every slot's valid, warp and epoch must be the model's. OA 428's ordering
// invariant is the bench's assertion: every slot ooe_decq flushes in a drive
// had its advance (or its release) driven no later than that drive.
//
// Negative controls (DECRX_CONTROL=<name>) must be caught: adv-late (OA's:
// each advance reaches the RTL one drive late), no-adv-bypass (the compare
// never takes an advancing slot's next epoch), no-double (a notice beside a
// redirect on one slot advances it once), keep-stale (a dropped uop
// reaches the ports with its warp's live epoch, so it must be kept: the
// bench expects the model's drop), no-ev-lead (the event lead never reaches
// it) and no-rel (a release never reaches it).
//
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: decrx_tb [seeds] | decrx_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_decrx_tb.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Core;

namespace {
constexpr unsigned S = RX_S, E = RX_E, NW = 32, EP = 3;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned LS = bits(S), LW = bits(NW);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_decrx_tb> dut;
std::string control;
uint64_t current = 0;
// A cycle as the model logged it, and the slots after it.
struct Edge {
  Core::RxLog log;
  uint32_t fl = 0;
  bool sv[S] = {};
  unsigned sw[S] = {}, se[S] = {};
};
Edge pend;
bool have_pend = false;
uint32_t late_adv = 0, late_adn = 0;   // adv-late: the advances held for the next drive
unsigned long long cycles = 0, arrivals = 0, kept = 0, dropped = 0, advs = 0, doubles = 0, reloc = 0, rels = 0, allocs = 0, flushes = 0,
                   same_drive = 0, cores = 0, mismatches = 0, order_fails = 0;

template <typename T> void setField(T &w, unsigned lsb, unsigned n, uint64_t v) {
  for (unsigned b = 0; b != n; ++b) {
    const unsigned i = lsb + b;
    const bool x = (v >> b) & 1u;
    if constexpr (sizeof(T) <= 8) {
      if (x) w |= (T(1) << i); else w &= ~(T(1) << i);
    } else {
      if (x) w[i / 32] |= (1u << (i % 32)); else w[i / 32] &= ~(1u << (i % 32));
    }
  }
}
template <typename T> unsigned getField(const T &w, unsigned lsb, unsigned n) {
  unsigned v = 0;
  for (unsigned b = 0; b != n; ++b) {
    const unsigned i = lsb + b;
    bool x;
    if constexpr (sizeof(T) <= 8) x = (w >> i) & 1u;
    else x = (w[i / 32] >> (i % 32)) & 1u;
    v |= unsigned(x) << b;
  }
  return v;
}

CgRun cg;

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}

void fail(const char *what, unsigned where, unsigned rtl, unsigned model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "%s, cycle %llu at %u: %s (rtl %u, model %u)\n", ooeTestName(), cycles, where, what, rtl,
                 model);
}

bool hasEvents(const Edge &e) {
  return !e.log.adv.empty() || !e.log.adn.empty() || e.log.rel || !e.log.alloc.empty();
}

void drive(const Edge &e, bool lead) {
  ++cycles;
  uint32_t adv = 0, adn = 0;
  for (unsigned s : e.log.adv) {
    if (adv >> s & 1u) fail("two redirects of a slot in a cycle", s, 0, 0);
    adv |= 1u << s;
  }
  for (unsigned s : e.log.adn) {
    if (adn >> s & 1u) fail("two epoch notices of a slot in a cycle", s, 0, 0);
    adn |= 1u << s;
  }
  advs += e.log.adv.size() + e.log.adn.size();
  doubles += __builtin_popcount(adv & adn);
  uint32_t drv_adv = adv, drv_adn = adn;
  if (control == "adv-late") { drv_adv = late_adv; late_adv = adv; drv_adn = late_adn; late_adn = adn; }
  if (control == "no-double") drv_adn &= ~drv_adv;
  const uint32_t rel = control == "no-rel" ? 0 : e.log.rel;
  rels += __builtin_popcount(e.log.rel);
  // OA 428's ordering invariant: a flushed slot's advance (or its release)
  // is driven no later than the flush.
  if (e.fl & ~(drv_adv | drv_adn | rel)) {
    ++order_fails;
    fail("a flush before its slot's advance", e.fl & ~(drv_adv | drv_adn | rel), drv_adv | drv_adn, adv | adn);
  }
  flushes += __builtin_popcount(e.fl);
  dut->adv_cq01h = drv_adv;
  dut->kadv_cq01h = control == "no-adv-bypass" ? 0 : drv_adv;
  dut->adn_cq01h = drv_adn;
  dut->kadn_cq01h = control == "no-adv-bypass" ? 0 : drv_adn;
  dut->rel_cq01h = rel;
  dut->al_v_cq01h = 0;
  uint32_t al_warps = 0;
  for (const auto &a : e.log.alloc) {
    if (dut->al_v_cq01h >> a.first & 1u) fail("two allocations of a slot in a cycle", a.first, 0, 0);
    dut->al_v_cq01h |= 1u << a.first;
    setField(dut->al_warp_cq01h, a.first * LW, LW, a.second);
    al_warps |= 1u << a.second;
    ++allocs;
    for (unsigned t = 0; t != S; ++t)
      if ((dut->sv_cq02h >> t & 1u) && !(e.log.rel >> t & 1u) && getField(dut->sw_cq02h, t * LW, LW) == a.second)
        fail("an allocation of a warp resident elsewhere", a.first, t, a.second);
    for (unsigned t = 0; t != S; ++t)
      reloc += (e.log.rel >> t & 1u) && getField(dut->sw_cq02h, t * LW, LW) == a.second;
  }
  uint32_t rel_warps = 0;
  for (unsigned s = 0; s != S; ++s)
    if (e.log.rel >> s & 1u) rel_warps |= 1u << getField(dut->sw_cq02h, s * LW, LW);   // the RTL's, before the edge
  // adv-late carries this drive's advances to the next, so it leads them
  // there: the control tests the ordering invariant, not the lead.
  if (control == "adv-late" && (late_adv | late_adn)) lead = true;
  dut->ev_l_cq00h = lead && control != "no-ev-lead";
  // The arrivals, in arrival order.
  if (e.log.arr.size() > E) { fail("more arrivals than ports", 0, unsigned(e.log.arr.size()), E); return; }
  dut->arv_v_cq01h = 0;
  for (unsigned k = 0; k != e.log.arr.size(); ++k) {
    const auto &a = e.log.arr[k];
    unsigned ep = a.fetch_epoch;
    if (control == "keep-stale" && !a.kept) {
      // The drop's warp's live epoch, so the RTL keeps what the model dropped.
      for (unsigned s = 0; s != S; ++s)
        if (e.sv[s] && e.sw[s] == a.warp) ep = e.se[s];
    }
    dut->arv_v_cq01h |= 1u << k;
    setField(dut->arv_warp_cq01h, k * LW, LW, a.warp);
    setField(dut->arv_ep_cq01h, k * EP, EP, ep);
    if ((al_warps | rel_warps) >> a.warp & 1u) { ++same_drive; fail("an arrival for a warp allocated or released in its cycle", a.warp, 0, 0); }
  }
  dut->ooe_core_clk = 0;
  dut->eval();
  for (unsigned k = 0; k != e.log.arr.size(); ++k) {
    const auto &a = e.log.arr[k];
    ++arrivals;
    (a.kept ? kept : dropped) += 1;
    const bool v = dut->enq_v_cq01h >> k & 1u;
    if (v != a.kept) { fail("keep differs", k, v, a.kept); continue; }
    if (v) {
      const unsigned g = getField(dut->enq_slot_cq01h, k * LS, LS);
      if (g != unsigned(a.slot)) fail("kept slot differs", k, g, unsigned(a.slot));
    }
  }
  for (unsigned k = unsigned(e.log.arr.size()); k != E; ++k)
    if (dut->enq_v_cq01h >> k & 1u) fail("an idle port kept", k, 1, 0);
  tick();
  // After the edge: the slots as the model left them.
  for (unsigned s = 0; s != S; ++s) {
    const bool v = dut->sv_cq02h >> s & 1u;
    if (v != e.sv[s]) { fail("slot valid differs", s, v, e.sv[s]); continue; }
    if (!v) continue;
    const unsigned w = getField(dut->sw_cq02h, s * LW, LW);
    if (w != e.sw[s]) { fail("slot warp differs", s, w, e.sw[s]); continue; }
    const unsigned ep = getField(dut->se_cq02h, s * EP, EP);
    if (ep != e.se[s]) fail("slot epoch differs", s, ep, e.se[s]);
    const unsigned sn = getField(dut->sn_cq02h, s * EP, EP);
    if (sn != ((e.se[s] + 1) & ((1u << EP) - 1))) fail("slot next epoch differs", s, sn, (e.se[s] + 1) & 7u);
    const unsigned s2 = getField(dut->s2_cq02h, s * EP, EP);
    if (s2 != ((e.se[s] + 2) & ((1u << EP) - 1))) fail("slot second epoch differs", s, s2, (e.se[s] + 2) & 7u);
  }
}

void resetDut() {
  dut->ev_l_cq00h = 0;
  dut->adv_cq01h = 0;
  dut->kadv_cq01h = 0;
  dut->adn_cq01h = 0;
  dut->kadn_cq01h = 0;
  dut->rel_cq01h = 0;
  dut->al_v_cq01h = 0;
  dut->arv_v_cq01h = 0;
  dut->ooe_rst_r00h = 1;
  tick();
  tick();
  dut->ooe_rst_r00h = 0;
  tick();
}

// After each core cycle (post): its events and the slots they left.
// Before the next (pre): the arrivals that followed it, which complete the
// edge. A core's last cycle (the random tests' frees) has no pre hook after
// it, so the next core's first pre hook drives it.
Edge cur;
bool have_cur = false;

void push(Edge &&e) {
  if (have_pend) drive(pend, hasEvents(e));
  pend = std::move(e);
  have_pend = true;
}

void post(const Core &c) {
  if (c.serial() != current) {
    // A core whose first cycle the pre hook did not see.
    fail("a core with no pre hook", 0, 0, 0);
    return;
  }
  cur = Edge();
  cur.log = c.rxLog();
  cur.fl = c.decqFlushed();
  for (unsigned w = 0; w != NW; ++w) {
    const int s = c.slotOfWarp(w);
    if (s < 0) continue;
    cur.sv[s] = true;
    cur.sw[s] = w;
    cur.se[s] = c.epoch(w);
  }
  have_cur = true;
}

void pre(const Core &c) {
  if (c.serial() != current) {
    if (have_cur) { push(std::move(cur)); have_cur = false; }
    if (have_pend) { drive(pend, false); have_pend = false; }
    current = c.serial();
    ++cores;
    late_adv = late_adn = 0;
    resetDut();
    // A null edge ahead of the core's first cycle carries the lead of its
    // launches.
    pend = Edge();
    have_pend = true;
    return;
  }
  if (!have_cur) return;
  cur.log.arr = c.rxLog().arr;   // the arrivals after the cycle
  push(std::move(cur));
  have_cur = false;
}

void flushLast() {
  if (have_cur) { push(std::move(cur)); have_cur = false; }
  if (have_pend) { drive(pend, false); have_pend = false; }
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("DECRX_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_decrx_tb>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  const int model_fails = cg.on() ? cg.run(seeds, pre, post) : ooeTestScenario("rx", seeds, 0, pre, post, nullptr);
  flushLast();
  cg.close();
  dut->final();
  std::printf("decrx_tb control=%s seeds=%u cores=%llu cycles=%llu arrivals=%llu kept=%llu dropped=%llu "
              "(no entry, no credit) advances=%llu (doubles=%llu) releases=%llu allocations=%llu (of a warp released beside it=%llu) flushes=%llu same-drive=%llu "
              "order-fails=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, arrivals, kept, dropped, advs, doubles, rels,
              allocs, reloc, flushes, same_drive, order_fails, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
