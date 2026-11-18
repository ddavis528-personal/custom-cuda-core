//===-- killsleep_tb.cpp - ccv_rcu bench: a kill that lands while RCU sleeps -===//
//
// RA rev 127 (AR 336 (b)): RCU acts on a kill that lands while its block
// clock is gated. kill_valid is in the gate's wake OR, but a wake opens the
// gate only from the edge after next, so ccv_rcu's kill detector flops it on
// the ungated clock and rcu_kill and rcu_mig read that flop as kill_v_q.
// The whole block, every other input idle, runs on its own gate:
//   awake   a kill while the gate is open: the reference ack latency
//   case 1  a kill landing while asleep is acked with its epoch at the
//           awake timing, high from K + KILL_DRAIN + 1: the drain is loaded
//           at K's edge with KILL_DRAIN - 1, K its first cycle, and
//           ack-ready's edge sets the ack (a hold, not a delay; RI-36)
//   case 2  two kills a cycle apart across the wake keep the later epoch
// --control drop1 / drop2 clear the detector's held kill in case 1 / in the
// later kill of case 2 (the hold dropped), and each must fail.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario for the unit
// ccv_rcu (tools/check-cg.py), which measures the block top's own flops, the
// detector's, its children black boxes: idle no kill, medium a kill on about
// 2% of the cycles, high on 8%, each OOE's: a new epoch (the last + 1) and a
// random mask, the next only once the last is acked. Traced to the top's
// own nets (trace depth 2), every child's port included.
//===----------------------------------------------------------------------===//
#include "Vccv_rcu.h"
#include "Vccv_rcu___024root.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>

#include "ccv_params.h"

namespace {

constexpr unsigned kDrain = ccv::prov::kLatRcuKillDrain;

int g_argc;
char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vccv_rcu> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t cyc = 0;
  unsigned fails = 0;
  std::string ctl;

  explicit Bench(const std::string &c, const char *vcd_path = nullptr) : ctl(c) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vccv_rcu>(ctx.get());
    if (vcd_path) {
      vcd = std::make_unique<VerilatedVcdC>();
      dut->trace(vcd.get(), 2);
      vcd->open(vcd_path);
    }
  }
  ~Bench() {
    dut->final();
    if (vcd) vcd->close();
  }
  bool asleep() const { return dut->clk_gated; }   // the coming edge is not delivered
  // One cycle: inputs set, then the edge. drop clears the detector's flop
  // right after the edge (the control).
  void step(bool kv, unsigned ep, uint32_t mask, bool drop = false) {
    dut->kill_valid = kv;
    dut->kill_epoch = ep;
    dut->kill_warp_mask = mask;
    dut->core_clk = 0;
    dut->eval();
    if (vcd) vcd->dump(2 * cyc);
    dut->core_clk = 1;
    dut->eval();
    if (vcd) vcd->dump(2 * cyc + 1);
    if (drop) {
      dut->rootp->ccv_rcu__DOT__kill_detect_v_cr01h = 0;
      dut->eval();
    }
    ++cyc;
  }
  void fail(const char *fmt, unsigned a, unsigned b) {
    ++fails;
    std::fprintf(stderr, "killsleep: cycle %llu: ", (unsigned long long)cyc);
    std::fprintf(stderr, fmt, a, b);
    std::fputc('\n', stderr);
  }
  // Idle until the gate has been closed for a few cycles.
  bool sleep() {
    for (unsigned n = 0, i = 0; i < 200; ++i) {
      step(false, 0, 0);
      if ((n = asleep() ? n + 1 : 0) >= 4) return true;
    }
    return false;
  }
  // A kill whose valid is in this cycle (K-1), epoch and mask in K; then
  // idle. kv2: a second kill a cycle later (its valid in K, epoch in K+1).
  // Returns the cycles from K to the ack's rise with the wanted epoch, or
  // ~0u; ack must fall first.
  unsigned kill(unsigned ep, bool kv2, unsigned ep2, bool drop_first, bool drop_second,
                bool sleeping = true) {
    if (sleeping && !asleep()) fail("not asleep at K-1 (%u %u)", 0, 0);
    step(true, 0, 0, drop_first);                        // K-1; the detector holds kill 1 in K
    step(kv2, ep, 0xffffffffu, kv2 && drop_second);      // K; it holds kill 2 in K+1
    if (kv2) step(false, ep2, 0xffffffffu);              // K+1
    const unsigned k0 = kv2 ? 2 : 1;                     // cycles stepped since K's start
    const unsigned want = kv2 ? ep2 : ep;
    bool fell = !dut->kill_ack;
    for (unsigned i = k0; i < kDrain + 8; ++i) {
      if (dut->kill_ack && fell) {
        if (dut->kill_ack_epoch != want) {
          fail("ack rose with epoch %u, want %u", dut->kill_ack_epoch, want);
          return ~0u;
        }
        return i;
      }
      fell |= !dut->kill_ack;
      step(false, 0, 0);
    }
    fail("no ack with epoch %u within %u cycles of K", want, kDrain + 8);
    return ~0u;
  }
};

int run(const std::string &ctl) {
  Bench b(ctl);
  for (int i = 0; i < 6; ++i) {
    b.dut->rst_n = 0;
    b.step(false, 0, 0);
  }
  b.dut->rst_n = 1;
  for (int i = 0; i < 8; ++i) b.step(false, 0, 0);

  // Awake: hold the gate open with a kill already in its drain, then kill.
  unsigned awake = ~0u;
  {
    b.step(true, 0, 0);
    b.step(false, 1, 0);
    for (int i = 0; i < 3; ++i) b.step(false, 0, 0);
    if (b.asleep()) b.fail("gate closed during a drain (%u %u)", 0, 0);
    awake = b.kill(2, false, 0, false, false, false);
    while (!b.dut->kill_ack) b.step(false, 0, 0);
  }
  // Case 1: asleep, one kill.
  unsigned c1 = ~0u;
  if (!b.sleep()) b.fail("the gate never closed (%u %u)", 0, 0);
  else c1 = b.kill(3, false, 0, ctl == "drop1", false);
  // The ack's timing (the model's, RI-36; the tab says K + KILL_DRAIN + 2):
  // the drain is loaded at K's edge with KILL_DRAIN - 1 and reaches 0
  // KILL_DRAIN - 1 edges on; ack-ready's edge sets kill_ack, high from
  // K + KILL_DRAIN + 1. Asleep, the same.
  if (awake != kDrain + 1) b.fail("awake: acked %u cycles after K, want KILL_DRAIN + 1 = %u", awake, kDrain + 1);
  if (c1 != ~0u && c1 != awake)
    b.fail("case 1: acked %u cycles after K, the awake latency %u", c1, awake);
  // Case 2: asleep, two kills a cycle apart across the wake.
  unsigned c2 = ~0u;
  if (!b.sleep()) b.fail("the gate never closed (%u %u)", 1, 0);
  else c2 = b.kill(1, true, 2, false, ctl == "drop2");
  // From the later kill's K (a cycle after the first's).
  if (c2 != ~0u && c2 - 1 != awake)
    b.fail("case 2: acked %u cycles after the later K, the awake latency %u", c2 - 1, awake);

  std::printf("killsleep%s: awake ack %u, case 1 %u, case 2 %u (from the later K), KILL_DRAIN %u: %s\n",
              ctl.empty() ? "" : (", control " + ctl).c_str(), awake, c1, c2 == ~0u ? c2 : c2 - 1,
              kDrain, b.fails ? "FAIL" : "PASS");
  return b.fails ? 1 : 0;
}

// One clock-gating scenario: reset, then kills at the scenario's rate, each
// waiting for the last one's ack (OOE's protocol), with a fresh epoch and
// mask in K so that every kill the gate takes changes its flops.
int run_cg(const std::string &scenario, const char *vcd) {
  Bench b("", vcd);
  for (int i = 0; i < 6; ++i) {
    b.dut->rst_n = 0;
    b.step(false, 0, 0);
  }
  b.dut->rst_n = 1;
  std::mt19937 rng(0x6b73u);
  auto coin = [&](double p) { return std::uniform_real_distribution<double>(0, 1)(rng) < p; };
  const unsigned n = scenario == "idle" ? 3000 : 4000;
  const double p = scenario == "idle" ? 0 : scenario == "medium" ? 0.02 : 0.08;
  unsigned ep = 0, kills = 0;
  bool busy = false, fell = false;
  for (unsigned i = 0; i < n; ++i) {
    if (busy) {
      fell |= !b.dut->kill_ack;
      if (fell && b.dut->kill_ack) busy = false;
    }
    if (!busy && coin(p)) {
      ep = (ep + 1) & 3u;
      b.step(true, 0, 0);                              // K-1
      b.step(false, ep, uint32_t(rng()) | 1u);         // K
      i += 1;
      ++kills;
      busy = true;
      fell = false;
      continue;
    }
    b.step(false, 0, 0);
  }
  const bool cov = scenario == "idle" || kills >= 4;
  if (!cov) ++b.fails;
  std::printf("killsleep --cg %s: %llu cycles, %u kills: %s\n", scenario.c_str(),
              (unsigned long long)b.cyc, kills, b.fails ? "FAIL" : "PASS");
  return b.fails ? 1 : 0;
}

}  // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string ctl;
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control")) ctl = argv[i + 1];
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      const std::string sc = argv[i + 1];
      if (sc != "idle" && sc != "medium" && sc != "high") {
        std::fprintf(stderr, "killsleep: unknown scenario %s\n", sc.c_str());
        return 2;
      }
      return run_cg(sc, argv[i + 2]);
    }
  if (!ctl.empty() && ctl != "drop1" && ctl != "drop2") {
    std::fprintf(stderr, "killsleep: unknown control %s\n", ctl.c_str());
    return 2;
  }
  return run(ctl);
}
