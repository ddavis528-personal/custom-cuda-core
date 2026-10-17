//===-- wake_tb.cpp - ooe_wake against the live model ----------------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode:
// bypass, L1 speculation with hits and misses, completion delays, replays,
// squashes, several warps) and, after every core cycle t, clocks ooe_wake
// once with what reached each RS entry's wake timer (Core::wakeLog): the
// grants of cycle t - 1, with their kind and class, and the dones,
// completions and stops of cycle t, which the model takes before its select.
// After the edge, every valid entry's four lines must be the model's
// (Core::wakeLine at t, what select read), and every miss pulse the
// model's L1 miss cancel at t. The RTL's fin (the result is final) must be
// set for every entry the model confirmed on its timer's word at t, and
// equal Core::rsFinal for every other valid entry not stopped at t.
//
// A core whose bypass penalties or latencies differ from the RTL's
// parameters (a knob-set table in the unit tests) is skipped and counted.
//
// Negative controls (WAKE_CONTROL=<name>) perturb what the RTL is driven
// with, and must be caught: late-grant (each grant reaches the RTL a cycle
// late), drop-cmpl (completions never reach it) and drop-stop (replays and
// frees never reach it).
// Usage: wake_tb [seeds]
//===----------------------------------------------------------------------===//
#include "Vooe_wake.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Config;
using ccv::ooe::Core;

int ooeTestRandomHooked(unsigned seeds, void (*hook)(const Core &));

namespace {
constexpr unsigned N = WAKE_N, L = Core::kWakeLines;

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_wake> dut;
std::string control;
uint64_t current = 0;          // the serial of the core being followed
bool following = false;        // its configuration is the RTL's
Core::WakeLog held, held2;     // the grants of the last cycle (and the one before)
unsigned long long cycles = 0, skipped = 0, cores = 0, compared = 0, raised = 0, grants = 0,
                   cmpls = 0, misses = 0, stops = 0, fins = 0, mismatches = 0;

template <typename W> void setBit(W &w, unsigned i, bool v) {
  if constexpr (sizeof(W) <= 8) {
    if (v) w |= (W(1) << i); else w &= ~(W(1) << i);
  } else {
    if (v) w[i / 32] |= (1u << (i % 32)); else w[i / 32] &= ~(1u << (i % 32));
  }
}
template <typename W> bool getBit(const W &w, unsigned i) {
  if constexpr (sizeof(W) <= 8) return (w >> i) & 1u;
  else return (w[i / 32] >> (i % 32)) & 1u;
}

CgRun cg;   // --cg <scenario> <vcd>: a clock-gating unit's bench (cg_trace.h)

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}

// An idle cycle: nothing reaches a timer; a grant's kind and class hold.
void idleTick() {
  dut->grant_cq01h = 0;
  dut->done_cq01h = 0;
  dut->cmpl_cq01h = 0;
  dut->stop_cq01h = 0;
  tick();
}

void fail(const char *what, unsigned e, unsigned k, bool rtl, bool model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "cycle %llu entry %u line %u: %s (rtl %d, model %d)\n", cycles, e, k, what,
                 int(rtl), int(model));
}

/// The RTL's parameters are the model's defaults; a core configured
/// otherwise is not followed.
bool sameConfig(const Core &c) {
  const Config &g = c.config();
  const std::vector<unsigned> pens = {WAKE_PEN0, WAKE_PEN1, WAKE_PEN2};
  if (!c.wakeLinesFit() || c.wakePens().size() != WAKE_NPEN) return false;
  for (unsigned k = 0; k != WAKE_NPEN; ++k)
    if (c.wakePens()[k] != pens[k]) return false;
  const unsigned lat[8] = {WAKE_LAT0, WAKE_LAT1, WAKE_LAT2, WAKE_LAT3, WAKE_LAT4, WAKE_LAT5, WAKE_LAT6, WAKE_LAT7};
  const unsigned fast[8] = {WAKE_FAST0, WAKE_FAST1, WAKE_FAST2, WAKE_FAST3, WAKE_FAST4, WAKE_FAST5, WAKE_FAST6, WAKE_FAST7};
  for (unsigned u = 0; u != 8; ++u)
    if (g.unitLat(u) != lat[u] || g.fastOf(u) != fast[u]) return false;
  return g.lat_lane == WAKE_LAT_COPY && g.lat_l1_wake == WAKE_LAT_SPEC &&
         g.payload_stages + g.lat_l1_cmpl == WAKE_LAT_MISS && g.cmpl_wake_delay == WAKE_CMPL_DLY &&
         c.rsRcuEntries() == WAKE_NR && !g.inject_early_wake;
}

void clearInputs() {
  dut->grant_cq01h = 0;
  dut->done_cq01h = 0;
  dut->cmpl_cq01h = 0;
  dut->stop_cq01h = 0;
  for (unsigned j = 0; j != N; ++j) {
    for (unsigned b = 0; b != 2; ++b) setBit(dut->kind_cq01h, j * 2 + b, false);
    for (unsigned b = 0; b != 3; ++b) setBit(dut->cls_cq01h, j * 3 + b, false);
  }
}

void hook(const Core &c) {
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    following = sameConfig(c);
    if (c.rsEntries() != N) {
      std::fprintf(stderr, "wake_tb: the core has %u RS entries, the RTL %u\n", c.rsEntries(), N);
      std::exit(2);
    }
    held = held2 = Core::WakeLog();
    clearInputs();
    dut->ooe_rst_r00h = 1;
    tick();
    dut->ooe_rst_r00h = 0;
  }
  ++cycles;
  if (!following) { ++skipped; return; }
  const Core::WakeLog &w = c.wakeLog();
  // The edge into this cycle: last cycle's grants, this cycle's events.
  const Core::WakeLog &g = control == "late-grant" ? held2 : held;
  clearInputs();
  for (unsigned j = 0; j != N; ++j) {
    const bool gr = j < g.grant.size() && g.grant[j];
    if (gr) {
      setBit(dut->grant_cq01h, j, true);
      for (unsigned b = 0; b != 2; ++b) setBit(dut->kind_cq01h, j * 2 + b, (g.kind[j] >> b) & 1u);
      for (unsigned b = 0; b != 3; ++b) setBit(dut->cls_cq01h, j * 3 + b, (g.cls[j] >> b) & 1u);
    }
    if (w.done[j]) setBit(dut->done_cq01h, j, true);
    if (w.cmpl[j] && control != "drop-cmpl") { setBit(dut->cmpl_cq01h, j, true); ++cmpls; }
    if (w.stop[j] && control != "drop-stop") { setBit(dut->stop_cq01h, j, true); ++stops; }
  }
  tick();
  // After it: what select read this cycle.
  for (unsigned j = 0; j != N; ++j) {
    const bool want_miss = w.miss[j], got_miss = getBit(dut->miss_cq02h, j);
    misses += want_miss;
    if (want_miss != got_miss) fail("miss differs", j, 0, got_miss, want_miss);
    const bool got_fin = getBit(dut->fin_cq02h, j);
    if (w.fin[j]) {
      ++fins;
      if (!got_fin) fail("confirmed, but not final", j, 0, got_fin, true);
    } else if (c.rsValid(j) && !w.stop[j] && got_fin != c.rsFinal(j)) {
      fail("final differs", j, 0, got_fin, c.rsFinal(j));
    }
    if (!c.rsValid(j)) continue;
    for (unsigned k = 0; k != L; ++k) {
      ++compared;
      const bool want = c.wakeLine(j, k), got = getBit(dut->wake_cq02h, j * L + k);
      raised += want;
      if (want != got) fail("line differs", j, k, got, want);
    }
  }
  for (unsigned j = 0; j != N; ++j) grants += w.grant[j];
  held2 = held;
  held = w;
  for (unsigned g = 0; g != cg.gaps(); ++g) idleTick();
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("WAKE_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_wake>(ctx.get());
  if (cg.on()) {
    cg.open(*dut, vcd);
    clearInputs();
    dut->ooe_rst_r00h = 1;
    for (unsigned k = 0; k != 4; ++k) tick();
    dut->ooe_rst_r00h = 0;
    if (cg.idle()) {
      for (unsigned k = 0; k != CgRun::kIdleCycles; ++k) idleTick();
    } else {
      ooeTestRandomHooked(CgRun::kSeeds, hook);
    }
    cg.close();
    dut->final();
    cg.vcd.reset();
    dut.reset();
    ctx.reset();
    return 0;
  }
  const int model_fails = ooeTestRandomHooked(seeds, hook);
  dut->final();
  std::printf("wake_tb control=%s seeds=%u cores=%llu cycles=%llu skipped=%llu grants=%llu cmpls=%llu "
              "misses=%llu stops=%llu fins=%llu compared=%llu raised=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, skipped, grants, cmpls,
              misses, stops, fins, compared, raised, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
