//===-- age_tb.cpp - ooe_age against the live model ------------------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode) and,
// just before every core cycle, takes a snapshot of one RS class: which
// entries are valid and their ages (Core::rsValid, Core::rsAge). Between two
// snapshots, an entry valid in the second with an age it did not have in the
// first was allocated at the edge between them: a group, in age order.
// ooe_age updates one edge after the RS (OA's response OI-58), so the bench
// runs it a snapshot behind: each tick drives the newest group's lead
// (alloc_l), and the group before it as ooe_rs's grant register with the
// valid bits of its snapshot. After the edge, for every pair of entries
// valid in that snapshot, the RTL's bit must say what the ages say. The
// RTL's assertions (a grant to an entry not valid, distinct ports, the lead
// exact, V-13's antisymmetry) run too, under --assert.
//
// AGE_CLS selects the class: 0 RCU (entries 0 to CCV_P_RS_RCU - 1), 1 MIU
// (the rest). Each new core resets the RTL, whose matrix is payload: only
// the valid input is cleared.
//
// Negative controls (AGE_CONTROL=<name>) perturb the driving and must be
// caught: no-valid (the valid input is all clear, so a new entry finds
// nothing older), port-reverse (a cycle's allocations reach the ports
// youngest first) and no-lead (the lead is never driven, so the matrix is
// never clocked).
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD ooe_age's clock-gating unit measures, checking as ever.
// Usage: age_tb [seeds] | age_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_age.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Core;


namespace {
std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_age> dut;
std::string control;
uint64_t current = 0;    // the serial of the core being followed
std::vector<bool> was_valid;
std::vector<uint64_t> was_age;
// The group the RTL updates at its next edge, and its snapshot.
std::vector<unsigned> pend;
uint64_t pend_valid = 0;
std::vector<bool> pend_was_valid;
std::vector<uint64_t> pend_was_age;
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

CgRun cg;   // --cg <scenario> <vcd>: a clock-gating unit's bench (cg_trace.h)

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}

// Drive the pending group as ooe_rs's grant register, with its valid bits.
void drivePend() {
  dut->valid_cq02h = control == "no-valid" ? 0 : pend_valid;
  dut->gnt_v_cq02h = 0;
  dut->gnt_idx_cq02h = 0;
  for (unsigned k = 0; k != pend.size(); ++k) {
    dut->gnt_v_cq02h |= 1u << k;
    dut->gnt_idx_cq02h |= decltype(dut->gnt_idx_cq02h)(pend[k]) << (k * W);
  }
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
    pend.clear();
    pend_valid = 0;
    pend_was_valid.assign(n, false);
    pend_was_age.assign(n, 0);
    dut->valid_cq02h = 0;
    dut->alloc_l_cq01h = 0;
    dut->gnt_v_cq02h = 0;
    dut->ooe_rst_r00h = 1;
    tick();
    tick();
    dut->ooe_rst_r00h = 0;
  }
  ++cycles;
  // The allocations since the last snapshot, oldest first, and the entries
  // that stayed.
  std::vector<std::pair<uint64_t, unsigned>> fresh;
  uint64_t now_valid = 0;
  for (unsigned e = 0; e != n; ++e) {
    const bool v = c.rsValid(base + e);
    const uint64_t a = c.rsAge(base + e);
    if (v && (!was_valid[e] || was_age[e] != a)) fresh.push_back({a, e});
    if (v) now_valid |= uint64_t(1) << e;
  }
  std::sort(fresh.begin(), fresh.end());
  if (fresh.size() > AGE_A) { fail("more allocations than ports", unsigned(fresh.size()), AGE_A); return; }
  if (control == "port-reverse") std::reverse(fresh.begin(), fresh.end());
  allocs += fresh.size();
  multi += fresh.size() > 1;
  // This tick: the new group's lead, and the pending group applied.
  dut->alloc_l_cq01h = !fresh.empty() && control != "no-lead";
  drivePend();
  tick();
  // The matrix now holds every group up to the pending one: compare the
  // pairs valid in its snapshot.
  for (unsigned e = 0; e != n; ++e)
    for (unsigned j = 0; j != n; ++j) {
      if (e == j || !pend_was_valid[e] || !pend_was_valid[j]) continue;
      ++pairs;
      const bool want = pend_was_age[j] < pend_was_age[e];
      if (getBit(dut->older_cq03h, e * n + j) != want) fail(want ? "older bit clear" : "older bit set", e, j);
    }
  pend.clear();
  for (auto &f : fresh) pend.push_back(f.second);
  pend_valid = now_valid;
  for (unsigned e = 0; e != n; ++e) {
    was_valid[e] = c.rsValid(base + e);
    was_age[e] = c.rsAge(base + e);
  }
  pend_was_valid = was_valid;
  pend_was_age = was_age;
}
} // namespace

int main(int argc, char **argv) {
  static_assert(AGE_N <= 64, "the valid input is driven as one word");
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("AGE_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_age>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  const int model_fails = cg.run(seeds, hook, nullptr);
  cg.close();
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
