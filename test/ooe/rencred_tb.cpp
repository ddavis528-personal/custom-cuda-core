//===-- rencred_tb.cpp - ooe_rencred against the live model ----------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode),
// under the go the counters serve (fits_stale 6: the registered per-cycle
// shares, admitting against the counters), and
// holds rename's credit counters as ooe_rename's flops will: RS room per
// class, free GPR and predicate names, each slot's ROB room. After every
// core cycle it drives ooe_rencred with the counters and the cycle's events
// as the model logged them (Core::renEvents): the RS frees within ooe_rs's
// prompt count, as its thermometer, and last cycle's past it; the names
// freed less those drawn other than by rename (a restore-allocate); each slot's
// ROB slots freed; and rename's takes, as thermometers. The next value
// must be the model's credits at the next edge, from its state: RS entries
// not valid less this cycle's frees past the prompt count; the free lists'
// sizes; each slot's ROB room. Then the counters take it. A counter is
// set from the model at a core's first cycle.
//
// Negative controls (RENCRED_CONTROL=<name>) perturb the driving and must
// be caught: no-late (the frees past the prompt count never reach the
// counters), no-draw (a restore-allocate's names are not drawn) and
// no-rob-free (no ROB slot is returned).
// Usage: rencred_tb [seeds]
//===----------------------------------------------------------------------===//
#include "Vooe_rencred.h"
#include "verilated.h"
#include "ooe_core.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Config;
using ccv::ooe::Core;

int ooeTestRandomHookedWith(unsigned seeds, void (*hook)(const Core &), void (*cfg)(Config &));
int ooeTestDirectedHookedWith(void (*hook)(const Core &), void (*cfg)(Config &));

namespace {
constexpr unsigned S = RC_S, A = RC_A, F = RC_F, LD = RC_LD;

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_rencred> dut;
std::string control;
uint64_t current = 0;
bool fresh = true;
unsigned rc = 0, mc = 0, gc = 0, pc = 0;
std::vector<unsigned> robc;
unsigned long long cycles = 0, cores = 0, takes = 0, lates = 0, draws = 0, mismatches = 0, skipped = 0, other_cycles = 0;

unsigned thermo(unsigned n, unsigned w) {
  if (n > w) {
    std::fprintf(stderr, "rencred_tb: a count of %u past its thermometer's %u\n", n, w);
    std::exit(2);
  }
  return (1u << n) - 1u;
}

void fail(const char *what, unsigned rtl, unsigned model) {
  if (++mismatches <= 8)
    std::fprintf(stderr, "cycle %llu: %s (rtl %u, model %u)\n", cycles, what, rtl, model);
}

void hook(const Core &c) {
  // A directed test's core of another size: the RTL's slots are fixed.
  if (c.slots() != S) {
    ++other_cycles;
    return;
  }
  const Core::RenEvents v = c.renEvents();
  // The model's credits at the next edge.
  const unsigned want_r = v.rs_free[0] - v.rs_late[0], want_m = v.rs_free[1] - v.rs_late[1];
  const unsigned want_g = v.names[0], want_p = v.names[1];
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    fresh = true;
  }
  ++cycles;
  if (fresh) {
    // A core's first cycle: the counters are set from it.
    fresh = false;
    rc = want_r;
    mc = want_m;
    gc = want_g;
    pc = want_p;
    robc = v.rob_room;
    return;
  }
  dut->rc_cq02h = rc;
  dut->mc_cq02h = mc;
  dut->gc_cq02h = gc;
  dut->pc_cq02h = pc;
  uint32_t ro = 0, rf = 0, tu = 0;
  for (unsigned s = 0; s != S; ++s) {
    ro |= robc[s] << (s * LD);
    rf |= (control == "no-rob-free" ? 0u : v.rob_freed[s]) << (s * LD);
    tu |= thermo(v.uops[s], A) << (s * A);
    takes += v.uops[s];
  }
  dut->robc_cq02h = ro;
  dut->robf_cq01h = rf;
  dut->tku_cq01h = tu;
  dut->fpr_cq01h = thermo(v.rs_prompt[0], F);
  dut->fpm_cq01h = thermo(v.rs_prompt[1], F);
  dut->flr_cq01h = control == "no-late" ? 0 : v.rs_late_prev[0];
  dut->flm_cq01h = control == "no-late" ? 0 : v.rs_late_prev[1];
  lates += v.rs_late_prev[0] + v.rs_late_prev[1];
  dut->tkr_cq01h = thermo(v.rs_take[0], A);
  dut->tkm_cq01h = thermo(v.rs_take[1], A);
  // Names: rename's takes (each uop writing one, at most the width), the
  // rest of the cycle's allocations drawn outside it.
  unsigned tk[2], dr[2];
  for (unsigned k = 0; k != 2; ++k) {
    tk[k] = std::min({v.name_take[k], v.name_alloc[k], A});
    dr[k] = v.name_alloc[k] - tk[k];
    draws += dr[k];
  }
  dut->tkg_cq01h = thermo(tk[0], A);
  dut->tkp_cq01h = thermo(tk[1], A);
  // The names' net change, two's complement, as the parent forms it.
  const unsigned lg = RC_LG, lp = RC_LP;
  const int gn = int(v.name_free[0]) - int(control == "no-draw" ? 0 : dr[0]);
  const int pn = int(v.name_free[1]) - int(control == "no-draw" ? 0 : dr[1]);
  dut->gn_cq01h = unsigned(gn) & ((1u << (lg + 1)) - 1u);
  dut->pn_cq01h = unsigned(pn) & ((1u << (lp + 1)) - 1u);
  dut->eval();
  rc = dut->rc_nx;
  mc = dut->mc_nx;
  gc = dut->gc_nx;
  pc = dut->pc_nx;
  if (rc != want_r) fail("RS RCU room differs", rc, want_r);
  if (mc != want_m) fail("RS MIU room differs", mc, want_m);
  if (gc != want_g) fail("free GPR names differ", gc, want_g);
  if (pc != want_p) fail("free predicate names differ", pc, want_p);
  for (unsigned s = 0; s != S; ++s) {
    robc[s] = (dut->robc_nx >> (s * LD)) & ((1u << LD) - 1u);
    if (robc[s] != v.rob_room[s]) fail("ROB room differs", robc[s], v.rob_room[s]);
  }
  // A counter that differs is reset from the model, so one slip is one
  // mismatch, not every cycle after it.
  if (rc != want_r || mc != want_m || gc != want_g || pc != want_p || robc != v.rob_room) {
    ++skipped;
    rc = want_r;
    mc = want_m;
    gc = want_g;
    pc = want_p;
    robc = v.rob_room;
  }
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("RENCRED_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  dut = std::make_unique<Vooe_rencred>(ctx.get());
  // The go the counters serve: the registered per-cycle shares, which
  // admit against the counters (fits_stale 6). Another go may take what
  // the counters do not yet show.
  auto cfg = [](Config &c) { c.fits_stale = 6; };
  int model_fails = ooeTestRandomHookedWith(seeds, hook, cfg);
  // The directed tests too: restores, kills, faults and squashes, which
  // random traffic does not take (a restore-allocate draws names).
  const unsigned long long before = cycles;
  model_fails += ooeTestDirectedHookedWith(hook, cfg);
  std::printf("rencred_tb directed: cycles=%llu (and %llu on cores of another size)\n", cycles - before, other_cycles);
  dut->final();
  std::printf("rencred_tb control=%s seeds=%u cores=%llu cycles=%llu uops=%llu late_frees=%llu draws=%llu "
              "mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, takes, lates, draws, mismatches,
              model_fails);
  const int rc_out = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc_out;
}
