//===-- age_tb.cpp - ooe_age against the live model ------------------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode) and,
// just before every core cycle, takes a snapshot of one RS class: which
// entries are valid and their ages (Core::rsValid, Core::rsAge). Between two
// snapshots, an entry valid in the second with an age it did not have in the
// first was allocated; those go to ooe_age's ports in age order, and the
// entries valid in both with the same age are its valid input. After the
// edge, for every pair of entries valid in the new snapshot, the RTL's bit
// must say what the ages say. The RTL's assertions (allocation to an invalid
// entry, distinct ports, V-13's antisymmetry) run too, under --assert.
//
// AGE_CLS selects the class: 0 RCU (entries 0 to CCV_P_RS_RCU - 1), 1 MIU
// (the rest). Each new core resets the RTL, whose matrix is payload: only
// the valid input is cleared.
//
// Negative controls (AGE_CONTROL=<name>) perturb the driving and must be
// caught: no-valid (the valid input is all clear, so a new entry finds
// nothing older) and port-reverse (a cycle's allocations reach the ports
// youngest first).
// Usage: age_tb [seeds]
//===----------------------------------------------------------------------===//
#include "Vooe_age.h"
#include "verilated.h"
#include "ooe_core.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Core;

int ooeTestRandomPreHooked(unsigned seeds, void (*hook)(const Core &));

namespace {
std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_age> dut;
std::string control;
uint64_t current = 0;    // the serial of the core being followed
std::vector<bool> was_valid;
std::vector<uint64_t> was_age;
unsigned long long cycles = 0, allocs = 0, multi = 0, pairs = 0, cores = 0, mismatches = 0;
constexpr unsigned W = []() { unsigned w = 0; while ((1u << w) < AGE_N) ++w; return w; }();

template <typename T> void setBit(T &w, unsigned i, bool v) {
  if constexpr (sizeof(T) <= 8) {
    if (v) w |= (T(1) << i); else w &= ~(T(1) << i);
  } else {
    if (v) w[i / 32] |= (1u << (i % 32)); else w[i / 32] &= ~(1u << (i % 32));
  }
}
template <typename T> bool getBit(const T &w, unsigned i) {
  if constexpr (sizeof(T) <= 8) return (w >> i) & 1u;
  else return (w[i / 32] >> (i % 32)) & 1u;
}

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  dut->ooe_core_clk = 1;
  dut->eval();
}

void fail(const char *what, unsigned e, unsigned j) {
  if (++mismatches <= 5) std::fprintf(stderr, "cycle %llu: %s (entries %u, %u)\n", cycles, what, e, j);
}

void hook(const Core &c) {
  const unsigned base = AGE_CLS ? c.rsRcuEntries() : 0;
  const unsigned n = AGE_CLS ? c.rsEntries() - c.rsRcuEntries() : c.rsRcuEntries();
  if (n != AGE_N) {
    std::fprintf(stderr, "age_tb: the core's class has %u entries, the RTL %u\n", n, AGE_N);
    std::exit(2);
  }
  if (c.serial() != current) {
    // A new core: nothing valid, the RTL's valid input clear.
    current = c.serial();
    ++cores;
    was_valid.assign(n, false);
    was_age.assign(n, 0);
    dut->valid_cq01h = 0;
    dut->alloc_v_cq01h = 0;
    dut->ooe_rst_r00h = 1;
    tick();
    dut->ooe_rst_r00h = 0;
  }
  ++cycles;
  // The allocations since the last snapshot, oldest first, and the entries
  // that stayed.
  std::vector<std::pair<uint64_t, unsigned>> fresh;
  uint64_t stay = 0;
  for (unsigned e = 0; e != n; ++e) {
    const bool v = c.rsValid(base + e);
    const uint64_t a = c.rsAge(base + e);
    if (v && (!was_valid[e] || was_age[e] != a)) fresh.push_back({a, e});
    else if (v && was_valid[e]) stay |= uint64_t(1) << e;
  }
  std::sort(fresh.begin(), fresh.end());
  if (fresh.size() > AGE_A) { fail("more allocations than ports", unsigned(fresh.size()), AGE_A); return; }
  if (control == "port-reverse") std::reverse(fresh.begin(), fresh.end());
  allocs += fresh.size();
  multi += fresh.size() > 1;
  dut->valid_cq01h = control == "no-valid" ? 0 : stay;
  dut->alloc_v_cq01h = 0;
  dut->alloc_idx_cq01h = 0;
  for (unsigned k = 0; k != fresh.size(); ++k) {
    dut->alloc_v_cq01h |= 1u << k;
    dut->alloc_idx_cq01h |= decltype(dut->alloc_idx_cq01h)(fresh[k].second) << (k * W);
  }
  tick();
  for (unsigned e = 0; e != n; ++e) {
    was_valid[e] = c.rsValid(base + e);
    was_age[e] = c.rsAge(base + e);
  }
  for (unsigned e = 0; e != n; ++e)
    for (unsigned j = 0; j != n; ++j) {
      if (e == j || !was_valid[e] || !was_valid[j]) continue;
      ++pairs;
      const bool want = was_age[j] < was_age[e];
      if (getBit(dut->older_cq02h, e * n + j) != want) fail(want ? "older bit clear" : "older bit set", e, j);
    }
}
} // namespace

int main(int argc, char **argv) {
  static_assert(AGE_N <= 64, "the valid input is driven as one word");
  const unsigned seeds = argc > 1 ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("AGE_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  dut = std::make_unique<Vooe_age>(ctx.get());
  const int model_fails = ooeTestRandomPreHooked(seeds, hook);
  dut->final();
  std::printf("age_tb class=%s control=%s seeds=%u cores=%llu cycles=%llu allocs=%llu multi-alloc=%llu "
              "pairs=%llu mismatches=%llu model_failures=%d\n",
              AGE_CLS ? "miu" : "rcu", control.empty() ? "none" : control.c_str(), seeds, cores, cycles,
              allocs, multi, pairs, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
