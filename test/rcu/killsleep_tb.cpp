//===-- killsleep_tb.cpp - ccv_rcu bench: a kill that lands while RCU sleeps -===//
//
// RA rev 127 (AR 336 (b)): RCU acts on a kill that lands while its block
// clock is gated. kill_valid is in the gate's wake OR, but a wake opens the
// gate only from the edge after next, so ccv_rcu's kill detector flops it on
// the ungated clock and rcu_kill and rcu_mig read that flop as kill_v_q.
// The whole block, every other input idle, runs on its own gate:
//   awake   a kill while the gate is open: the reference ack latency
//   case 1  a kill landing while asleep is acked with its epoch at the
//           awake timing, high from K + KILL_DRAIN + 2: the drain is loaded
//           at K's edge and ack-ready's edge sets the ack (a hold, not a
//           delay)
//   case 2  two kills a cycle apart across the wake keep the later epoch
// --control drop1 / drop2 clear the detector's held kill in case 1 / in the
// later kill of case 2 (the hold dropped), and each must fail.
//===----------------------------------------------------------------------===//
#include "Vccv_rcu.h"
#include "Vccv_rcu___024root.h"
#include "verilated.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <string>

#include "ccv_params.h"

namespace {

constexpr unsigned kDrain = ccv::prov::kLatRcuKillDrain;

int g_argc;
char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vccv_rcu> dut;
  uint64_t cyc = 0;
  unsigned fails = 0;
  std::string ctl;

  explicit Bench(const std::string &c) : ctl(c) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    dut = std::make_unique<Vccv_rcu>(ctx.get());
  }
  ~Bench() { dut->final(); }
  bool asleep() const { return dut->clk_gated; }   // the coming edge is not delivered
  // One cycle: inputs set, then the edge. drop clears the detector's flop
  // right after the edge (the control).
  void step(bool kv, unsigned ep, uint32_t mask, bool drop = false) {
    dut->kill_valid = kv;
    dut->kill_epoch = ep;
    dut->kill_warp_mask = mask;
    dut->core_clk = 0;
    dut->eval();
    dut->core_clk = 1;
    dut->eval();
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
  // The ack's timing (Done, kill and reset tab): the drain is loaded at K's
  // edge with KILL_DRAIN and reaches 0 KILL_DRAIN edges on; ack-ready's edge
  // sets kill_ack, high from K + KILL_DRAIN + 2. Asleep, the same.
  if (awake != kDrain + 2) b.fail("awake: acked %u cycles after K, want KILL_DRAIN + 2 = %u", awake, kDrain + 2);
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

}  // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string ctl;
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control")) ctl = argv[i + 1];
  if (!ctl.empty() && ctl != "drop1" && ctl != "drop2") {
    std::fprintf(stderr, "killsleep: unknown control %s\n", ctl.c_str());
    return 2;
  }
  return run(ctl);
}
