//===-- confirm_tb.cpp - ooe_confirm against the live model ----------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode:
// L1 speculation with misses, transitive cancels, completion delays,
// squashes, several warps) and, after every core cycle, drives ooe_confirm
// with the inputs the model's cancel hop and confirmation pass logged
// (Core::wakeLog): each entry issued and unconfirmed, the dependency bits
// and the held misses (msd) as the hop saw them at the cycle's start; the
// result final and a destination for confirmation. The RTL's replays must
// be the hop's, its confirmations the pass's, and never both (V-16).
//
// Then OA-17's directed case, which the model cannot reach (it selects on
// the wake lines directly, with no ready register): a load L misses; its
// child C, granted from a stale ready bit, issues only after the miss.
// ooe_confirm must return C to Waiting in the cycle it issues, from L's
// held miss (V-67), and keep doing so while C stays issued.
//
// Negative controls (CONFIRM_CONTROL=<name>) perturb the driving and must
// be caught: no-msd (no held miss reaches the RTL), msd-pulse (a miss is
// driven only in its first cycle, the pulse hop OA-17 found unsafe: the
// directed case must fail), no-fin (every result is called final) and
// no-dep (the dependency bits never reach it).
// Usage: confirm_tb [seeds]
//===----------------------------------------------------------------------===//
#include "Vooe_confirm.h"
#include "verilated.h"
#include "ooe_core.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Core;

int ooeTestRandomHooked(unsigned seeds, void (*hook)(const Core &));

namespace {
constexpr unsigned N = CONFIRM_N;

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_confirm> dut;
std::string control;
uint64_t current = 0;           // the serial of the core being followed
std::vector<uint8_t> msd_was;   // last cycle's held misses (msd-pulse)
unsigned long long cycles = 0, cores = 0, held = 0, replays = 0, confs = 0, mismatches = 0;

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

void fail(const char *what, unsigned e, bool rtl, bool model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "cycle %llu entry %u: %s (rtl %d, model %d)\n", cycles, e, what, int(rtl), int(model));
}

// The held misses as driven: under msd-pulse, only a miss's first cycle.
bool msdDriven(unsigned i, bool msd) {
  if (control == "no-msd") return false;
  if (control == "msd-pulse") return msd && !msd_was[i];
  return msd;
}

void hook(const Core &c) {
  if (c.rsEntries() != N) {
    std::fprintf(stderr, "confirm_tb: the core has %u RS entries, the RTL %u\n", c.rsEntries(), N);
    std::exit(2);
  }
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    msd_was.assign(N, 0);
  }
  ++cycles;
  const Core::WakeLog &w = c.wakeLog();
  // The hop and the pass read one matrix and one issued set in the RTL: the
  // state at the cycle's start, as the hop logged it. The pass ran after
  // the hop's replays, which it excludes; the RTL excludes them too, since
  // a replayed entry's row is not empty.
  for (unsigned i = 0; i != N; ++i) {
    setBit(dut->iss_cq01h, i, w.hop_iss[i]);
    setBit(dut->msd_cq01h, i, msdDriven(i, w.hop_msd[i]));
    setBit(dut->fin_cq01h, i, w.cf_fin[i] || control == "no-fin");
    setBit(dut->prod_cq01h, i, w.cf_prod[i]);
    held += w.hop_msd[i];
    for (unsigned j = 0; j != N; ++j)
      setBit(dut->dep_cq01h, i * N + j, w.hop_dep[size_t(i) * N + j] && control != "no-dep");
  }
  dut->eval();
  for (unsigned i = 0; i != N; ++i) {
    const bool rep = getBit(dut->replay_cq01h, i), cf = getBit(dut->conf_cq01h, i);
    replays += w.replay[i];
    confs += w.conf[i];
    if (rep != bool(w.replay[i])) fail("replay differs", i, rep, w.replay[i]);
    if (cf != bool(w.conf[i])) fail("confirm differs", i, cf, w.conf[i]);
    if (rep && cf) fail("replayed and confirmed (V-16)", i, true, false);
    msd_was[i] = w.hop_msd[i];
  }
}

// OA-17 (a), driven directly: entries L (a load) and C (its child). Cycle
// 0: L issued, then missed (msd from here on); C not yet issued. Cycles 1
// to 3: C issued, granted from a stale ready bit after the miss pulse. C
// must replay in each cycle it is issued, and never confirm.
void directed() {
  const unsigned L = 0, C = 1;
  for (unsigned i = 0; i != N; ++i) {
    setBit(dut->iss_cq01h, i, false);
    setBit(dut->msd_cq01h, i, false);
    setBit(dut->fin_cq01h, i, false);
    setBit(dut->prod_cq01h, i, true);
    for (unsigned j = 0; j != N; ++j) setBit(dut->dep_cq01h, i * N + j, false);
  }
  setBit(dut->dep_cq01h, C * N + L, control != "no-dep");
  msd_was.assign(N, 0);
  for (unsigned t = 0; t != 4; ++t) {
    ++cycles;
    setBit(dut->iss_cq01h, L, true);
    setBit(dut->msd_cq01h, L, msdDriven(L, true));
    setBit(dut->iss_cq01h, C, t >= 1);
    setBit(dut->fin_cq01h, C, control == "no-fin");
    dut->eval();
    msd_was[L] = 1;
    if (t >= 1 && !getBit(dut->replay_cq01h, C)) fail("OA-17: C issued after its load's miss, not replayed", C, false, true);
    if (getBit(dut->conf_cq01h, C)) fail("OA-17: C confirmed on a missed load", C, true, false);
  }
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("CONFIRM_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  dut = std::make_unique<Vooe_confirm>(ctx.get());
  const int model_fails = ooeTestRandomHooked(seeds, hook);
  const unsigned long long before = mismatches;
  directed();
  const bool oa17 = mismatches == before;
  dut->final();
  std::printf("confirm_tb control=%s seeds=%u cores=%llu cycles=%llu held=%llu replays=%llu confirms=%llu "
              "oa17=%s mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, held, replays, confs,
              oa17 ? "pass" : "fail", mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
