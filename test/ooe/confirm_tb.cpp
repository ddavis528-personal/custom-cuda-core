//===-- confirm_tb.cpp - ooe_confirm against the live model ----------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode:
// L1 speculation with misses, transitive cancels, completion delays,
// squashes, several warps) and, after every core cycle, drives ooe_confirm
// with the inputs the model's cancel hop and confirmation pass logged
// (Core::wakeLog): each entry issued and unconfirmed, the dependency bits
// and this cycle's misses for the hop; the result final and a destination
// for confirmation. The RTL's replays must be the hop's, its confirmations
// the pass's. Then it clocks once, so its register of last cycle's replays
// carries the next hop, as the model's state does.
//
// Negative controls (CONFIRM_CONTROL=<name>) perturb the driving and must
// be caught: no-miss (misses never reach the RTL), no-fin (every result
// is called final), no-dep (the dependency bits never reach it) and
// no-carry (the RTL is reset after every cycle, so no hop reaches past the
// first).
// Usage: confirm_tb [seeds]
//===----------------------------------------------------------------------===//
#include "Vooe_confirm.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>

using ccv::ooe::Core;

int ooeTestRandomHooked(unsigned seeds, void (*hook)(const Core &));

namespace {
constexpr unsigned N = CONFIRM_N;

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_confirm> dut;
std::string control;
uint64_t current = 0;    // the serial of the core being followed
unsigned long long cycles = 0, cores = 0, hops = 0, misses = 0, replays = 0, confs = 0, mismatches = 0;

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

// An idle cycle: no miss arrives; the state inputs hold.
void idleTick() {
  for (unsigned i = 0; i != N; ++i) setBit(dut->miss_cq01h, i, false);
  tick();
}

void fail(const char *what, unsigned e, bool rtl, bool model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "cycle %llu entry %u: %s (rtl %d, model %d)\n", cycles, e, what, int(rtl), int(model));
}

void hook(const Core &c) {
  if (c.rsEntries() != N) {
    std::fprintf(stderr, "confirm_tb: the core has %u RS entries, the RTL %u\n", c.rsEntries(), N);
    std::exit(2);
  }
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    dut->ooe_rst_r00h = 1;
    tick();
    dut->ooe_rst_r00h = 0;
  }
  ++cycles;
  const Core::WakeLog &w = c.wakeLog();
  // The hop and the pass see one matrix and one issued set in the RTL; the
  // model logs each where it ran (the pass's issued set already excludes
  // the hop's replays, which the RTL's own exclusion matches).
  const auto &iss = w.hop_live ? w.hop_iss : w.cf_iss;
  const auto &dep = w.hop_live ? w.hop_dep : w.cf_dep;
  hops += w.hop_live;
  for (unsigned i = 0; i != N; ++i) {
    setBit(dut->iss_cq01h, i, iss[i]);
    setBit(dut->miss_cq01h, i, w.miss[i] && control != "no-miss");
    setBit(dut->fin_cq01h, i, w.cf_fin[i] || control == "no-fin");
    setBit(dut->prod_cq01h, i, w.cf_prod[i]);
    misses += w.miss[i];
    for (unsigned j = 0; j != N; ++j)
      setBit(dut->dep_cq01h, i * N + j, !dep.empty() && dep[size_t(i) * N + j] && control != "no-dep");
  }
  dut->eval();
  for (unsigned i = 0; i != N && !cg.on(); ++i) {
    const bool rep = getBit(dut->replay_cq02h, i), cf = getBit(dut->conf_cq01h, i);
    replays += w.replay[i];
    confs += w.conf[i];
    if (rep != bool(w.replay[i])) fail("replay differs", i, rep, w.replay[i]);
    if (cf != bool(w.conf[i])) fail("confirm differs", i, cf, w.conf[i]);
  }
  if (control == "no-carry") dut->ooe_rst_r00h = 1;
  tick();
  dut->ooe_rst_r00h = 0;
  for (unsigned g = 0; g != cg.gaps(); ++g) idleTick();
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("CONFIRM_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_confirm>(ctx.get());
  if (cg.on()) {
    cg.open(*dut, vcd);
    dut->ooe_rst_r00h = 1;
    for (unsigned k = 0; k != 4; ++k) tick();
    dut->ooe_rst_r00h = 0;
    if (cg.idle()) {
      for (unsigned k = 0; k != CgRun::kIdleCycles; ++k) idleTick();
    } else {
      current = 0;
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
  std::printf("confirm_tb control=%s seeds=%u cores=%llu cycles=%llu hops=%llu misses=%llu replays=%llu "
              "confirms=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, hops, misses, replays, confs,
              mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
