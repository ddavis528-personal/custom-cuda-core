//===-- kdet_tb.cpp - rcu_kdet against a value model ----------------------===//
//
// Drives rtl/rcu/rcu_kdet.sv, RCU's kill detector on the ungated clock, and
// holds every output, every cycle, to a value model: kv_cr01h is
// kill_valid a cycle on (reset low), and the epoch and the warp mask of
// the cycle after a valid are taken at that cycle's edge and held until the
// next kill (AR 338). Runs: directed kills (one alone, two back to back, a
// kill at the first cycle out of reset), then random traffic with noise on
// the epoch and the mask between kills. --cg <idle|medium|high> <vcd> runs
// one clock-gating scenario (tools/check-cg.py). --control follow models
// the epoch and the mask flopped every cycle (the detector before
// 2026-11-09), and the run must fail (test/rcu/run-rtl.sh). Exit 0 only
// with no mismatch.
//===----------------------------------------------------------------------===//
#include "Vrcu_kdet.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>

namespace {

int g_argc;
char **g_argv;
bool g_follow = false;

struct In { bool kv = false; unsigned ep = 0; uint32_t km = 0; };

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vrcu_kdet> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0, kills = 0;
  bool rst_q = true, kv = false, known = false;
  unsigned ep = 0;
  uint32_t km = 0;

  explicit Bench(const char *vcd_path) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vrcu_kdet>(ctx.get());
    if (vcd_path) {
      vcd = std::make_unique<VerilatedVcdC>();
      dut->trace(vcd.get(), 99);
      vcd->open(vcd_path);
    }
  }
  ~Bench() {
    if (vcd) vcd->close();
    dut->final();
  }
  void eval() {
    dut->eval();
    if (vcd) vcd->dump(t);
    t += 5;
  }
  void chk(const char *what, uint64_t got, uint64_t want) {
    ++checked;
    if (got != want && ++fails <= 20)
      std::fprintf(stderr, "kdet: cycle %llu: %s %llx, want %llx\n", (unsigned long long)cyc, what,
                   (unsigned long long)got, (unsigned long long)want);
  }
  void step(const In &in, bool rst = false) {
    dut->rst_n = !rst;
    dut->kill_valid = in.kv;
    dut->kill_epoch = in.ep;
    dut->kill_warp_mask = in.km;
    dut->core_clk = 0;
    eval();
    const bool rr = rst_q;
    rst_q = rst;
    // The epoch and the mask: taken under kv (this cycle's kill_v_q).
    if (kv || g_follow) {
      ep = in.ep;
      km = in.km;
      known = known || kv;
    }
    kills += kv;
    kv = rr ? false : in.kv;
    dut->core_clk = 1;
    eval();
    if (!rr) {
      chk("kv", dut->kv_cr01h, kv);
      if (known) {
        chk("epoch", dut->kep_cr02h, ep);
        chk("warp mask", dut->km_cr02h, km);
      }
    }
    ++cyc;
  }
};

void directed(Bench &b) {
  In q, k, e;
  k.kv = true;
  e.ep = 2;
  e.km = 0x0000f00fu;
  b.step(k);       // a kill alone: K-1
  b.step(e);       // K: its epoch and mask
  for (int i = 0; i < 6; ++i) { In n; n.ep = 1; n.km = 0xdeadbeefu; b.step(n); }   // noise: held
  In ke = e;       // two back to back: the second's valid beside the first's epoch
  ke.kv = true;
  b.step(k);
  b.step(ke);
  In e2;
  e2.ep = 3;
  e2.km = 0x80000001u;
  b.step(e2);
  for (int i = 0; i < 4; ++i) b.step(q);
}

int run(const std::string &scenario, const char *vcd) {
  Bench b(vcd);
  const In none;
  for (int i = 0; i < 8; ++i) b.step(none, true);
  In k0;           // a kill at the first cycle out of reset
  k0.kv = true;
  b.step(k0);
  In e0;
  e0.ep = 1;
  e0.km = 0x5u;
  b.step(e0);
  std::mt19937 rng(0x6b64u);
  auto coin = [&](double p) { return std::uniform_real_distribution<double>(0, 1)(rng) < p; };
  if (scenario.empty()) directed(b);
  const unsigned n = scenario == "idle" ? 3000 : 4000;
  const double p = scenario == "idle" ? 0 : scenario == "medium" ? 0.02 : 0.08;
  for (unsigned i = 0; i < n; ++i) {
    In in;
    if (scenario.empty() || scenario == "medium" || scenario == "high") {
      in.kv = coin(scenario.empty() ? 0.05 : p);
      if (scenario.empty() || coin(0.5)) {   // noise on the epoch and the mask
        in.ep = unsigned(rng()) & 3u;
        in.km = uint32_t(rng());
      }
    }
    b.step(in);
  }
  if (scenario != "idle" && b.kills < 4) {
    std::fprintf(stderr, "kdet: coverage: kills %u\n", b.kills);
    ++b.fails;
  }
  std::printf("kdet%s %s: %llu cycles, %u values checked, %u mismatches: %s\n",
              g_follow ? ", control follow:" : "", scenario.empty() ? "directed+random" : scenario.c_str(),
              (unsigned long long)b.cyc, b.checked, b.fails, b.fails ? "FAIL" : "PASS");
  return b.fails ? 1 : 0;
}

} // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string scenario;
  const char *vcd = nullptr;
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control") && !std::strcmp(argv[i + 1], "follow")) g_follow = true;
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "kdet: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd);
}
