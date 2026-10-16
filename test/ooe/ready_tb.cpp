//===-- ready_tb.cpp - ooe_ready against the live model --------------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode:
// bypass, L1 speculation, sectioned lanes, several warps, mispredicts and
// misses) and, after every core cycle, drives ooe_ready from the core's
// own state: each cell's dependency bit and line select (Core::depBit,
// Core::cellCode) and each producer's wake lines (Core::wakeLine). The
// RTL's ready must equal the model's rowReady for every valid entry.
//
// Cycles whose bypass table has more distinct penalties than the lines
// carry (a knob-set table in the unit tests) are skipped and counted.
//
// Negative controls (READY_CONTROL=<name>) perturb what the RTL is driven
// with, and must be caught: code-shift (every cell selects the next line)
// and no-late (the PRF-read line never rises).
// Usage: ready_tb [seeds]
//===----------------------------------------------------------------------===//
#include "Vooe_ready.h"
#include "verilated.h"
#include "ooe_core.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>

using ccv::ooe::Core;

int ooeTestRandomHooked(unsigned seeds, void (*hook)(const Core &));

namespace {
std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_ready> dut;
std::string control;
unsigned long long cycles = 0, skipped = 0, compared = 0, ready_seen = 0, mismatches = 0;

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

void hook(const Core &c) {
  ++cycles;
  if (!c.wakeLinesFit()) { ++skipped; return; }
  const unsigned n = c.rsEntries();
  if (n != READY_N) {
    std::fprintf(stderr, "ready_tb: the core has %u RS entries, the RTL %u\n", n, READY_N);
    std::exit(2);
  }
  constexpr unsigned W = Core::kWakeLines;
  for (unsigned i = 0; i != n; ++i)
    for (unsigned j = 0; j != n; ++j) {
      const bool d = c.rsValid(i) && c.depBit(i, j);
      setBit(dut->dep_cq02h, i * n + j, d);
      unsigned k = d ? c.cellCode(i, j) : 0;
      if (control == "code-shift") k = (k + 1) % W;
      setBit(dut->code_cq02h, (i * n + j) * 2, k & 1u);
      setBit(dut->code_cq02h, (i * n + j) * 2 + 1, (k >> 1) & 1u);
    }
  for (unsigned j = 0; j != n; ++j)
    for (unsigned k = 0; k != W; ++k) {
      bool l = c.rsValid(j) && c.wakeLine(j, k);
      if (control == "no-late" && k == Core::kLateLine) l = false;
      setBit(dut->wake_cq02h, j * W + k, l);
    }
  dut->eval();
  for (unsigned i = 0; i != n; ++i) {
    if (!c.rsValid(i)) continue;
    ++compared;
    const bool want = c.rsReady(i), got = getBit(dut->ready_cq02h, i);
    ready_seen += want;
    if (got != want && ++mismatches <= 5)
      std::fprintf(stderr, "cycle %llu entry %u: rtl %s, model %s\n", cycles, i, got ? "ready" : "waiting",
                   want ? "ready" : "waiting");
  }
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("READY_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  dut = std::make_unique<Vooe_ready>(ctx.get());
  const int model_fails = ooeTestRandomHooked(seeds, hook);
  dut->final();
  std::printf("ready_tb control=%s seeds=%u cycles=%llu skipped=%llu compared=%llu ready=%llu "
              "mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cycles, skipped, compared, ready_seen,
              mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
