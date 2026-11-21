//===-- cap_tb.cpp - miu_cap bench: one ccv_rcu_miu_addr slot's capture ----===//
//
// Drives one address slot as RCU does: the valid in V, the payload's fields
// in V+1 (no lead field), and noise on the payload wires in every other
// cycle (random mode), which the module must not keep. Checks, every cycle,
// the valid a cycle on (v_cm01h) and the held capture (active_mask,
// base_per_lane, index_per_lane) against a value model: the payload of the
// last message, from the edge after its V+1 (H) until the next message's.
// Messages come back to back as well as spread, so a capture under a
// capture is covered.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle is reset and no message, the wires still;
// medium a message on about a third of the cycles; high one nearly every
// cycle; the payload's wires change only with a message. --control early
// models the capture a cycle early (the payload taken in V, as if it led);
// it must fail.
//===----------------------------------------------------------------------===//
#include "Vmiu_cap.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>

namespace {

constexpr unsigned kWD = 1024, kWW = kWD / 32;   // lanes, a per-lane field's bits and words

struct Msg {
  uint32_t am = 0;
  uint32_t base[kWW] = {}, idx[kWW] = {};
};

int g_argc;
char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vmiu_cap> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0, cov_b2b = 0, cov_hold = 0, cov_noise = 0;
  bool early = false;
  bool vprev = false, known = false;   // the valid a cycle ago; a capture held
  Msg want{};                          // the held capture

  Bench(const char *vcd_path, bool ctl) : early(ctl) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vmiu_cap>(ctx.get());
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
  void edge() {
    dut->miu_core_clk = 0;
    eval();
    dut->miu_core_clk = 1;
    eval();
    ++cyc;
  }
  void reset() {
    dut->rst_n = 0;
    dut->av_cm00h = 0;
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();   // the flopped reset releases a cycle on (RST-1)
  }
  // One cycle: valid v on the wire, payload wires w; then the edge, then
  // the checks of what the edge captured.
  void step(bool v, const Msg &w) {
    dut->av_cm00h = v;
    dut->am_cm01h = w.am;
    for (unsigned i = 0; i < kWW; ++i) {
      dut->base_cm01h[i] = w.base[i];
      dut->idx_cm01h[i] = w.idx[i];
    }
    edge();
    // The value model: the payload is on the wire in V+1 (early: in V).
    const bool take = early ? v : vprev;
    if (take) {
      want = w;
      known = true;
      cov_b2b += vprev && v;
    } else if (known) {
      ++cov_hold;
      cov_noise += std::memcmp(&w, &want, sizeof w) != 0;
    }
    ++checked;
    if (bool(dut->v_cm01h) != v && ++fails <= 20)
      std::fprintf(stderr, "cap: cycle %llu: v_cm01h %d, want %d\n", (unsigned long long)cyc,
                   int(dut->v_cm01h), int(v));
    vprev = v;
    if (!known) return;
    ++checked;
    bool ok = dut->am_cm02h == want.am;
    for (unsigned i = 0; i < kWW; ++i)
      ok = ok && dut->base_cm02h[i] == want.base[i] && dut->idx_cm02h[i] == want.idx[i];
    if (!ok && ++fails <= 20)
      std::fprintf(stderr, "cap: cycle %llu: capture differs (active_mask %08x, want %08x)\n",
                   (unsigned long long)cyc, unsigned(dut->am_cm02h), want.am);
  }
};

struct Gen {
  std::mt19937_64 r;
  explicit Gen(uint64_t seed) : r(seed) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
  Msg msg() {
    Msg m;
    m.am = below(8) == 0 ? 0xffffffffu : below(8) == 0 ? 0u : uint32_t(r());
    for (unsigned i = 0; i < kWW; ++i) {
      m.base[i] = uint32_t(r());
      m.idx[i] = uint32_t(r());
    }
    return m;
  }
};

int run(const std::string &scenario, const char *vcd, bool ctl) {
  Bench b(vcd, ctl);
  Gen g(0xca9);
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 50000 : scenario == "idle" ? 3000 : 4000;
  Msg w{}, next{};
  bool pend = false;   // a valid went out last cycle: its payload goes on the wire now
  for (unsigned i = 0; i < n; ++i) {
    const bool v = scenario == "idle"     ? false
                   : scenario == "medium" ? (i % 3 == 0 && g.below(10) < 8)
                   : scenario == "high"   ? g.below(10) < 9
                                          : (i / 64) % 2 ? g.below(10) < 9 : g.below(4) == 0;
    // The payload on the wire now: the last valid's message; otherwise
    // noise in random mode, and still wires in a clock-gating scenario.
    if (pend) w = next;
    else if (rnd && g.below(2)) w = g.msg();
    if (v) next = g.msg();
    pend = v;
    b.step(v, w);
  }
  if (rnd && (!b.cov_b2b || !b.cov_hold || !b.cov_noise)) {
    std::fprintf(stderr, "cap: coverage: back to back %u, holds %u, noise held off %u\n",
                 b.cov_b2b, b.cov_hold, b.cov_noise);
    ++b.fails;
  }
  std::printf("cap%s %s: %llu cycles, %u values checked, %u mismatches: %s\n",
              ctl ? " control early:" : ":", rnd ? "random" : scenario.c_str(),
              (unsigned long long)b.cyc, b.checked, b.fails, b.fails ? "FAIL" : "PASS");
  return b.fails ? 1 : 0;
}

}  // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string scenario;
  const char *vcd = nullptr;
  bool ctl = false;
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control")) {
      if (!std::strcmp(argv[i + 1], "early")) ctl = true;
      else {
        std::fprintf(stderr, "cap: unknown control %s\n", argv[i + 1]);
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "cap: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
