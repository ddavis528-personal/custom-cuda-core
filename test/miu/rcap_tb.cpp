//===-- rcap_tb.cpp - miu_rcap bench: one ccv_dcu_miu_rsp slot's capture ---===//
//
// Drives one response slot as DCU does: the valid a cycle ahead of the
// payload's fields (no lead field), and noise on the payload wires in every
// other cycle (random mode), which the module must not keep. Checks, every
// cycle, the valid a cycle on (rv_cm12h) and two cycles on (cv_cm13h), and
// the held capture (req_id, read_data, hit, ownership_granted, mlc_miss,
// check_bits) against a value model: the payload of the last message, from
// the edge after its payload cycle (R2) until the next message's.
// Messages come back to back as well as spread, so a capture under a
// capture is covered.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle is reset and no message, the wires still;
// medium a message on about a third of the cycles; high one nearly every
// cycle; the payload's wires change only with a message. --control early
// models the capture a cycle early (the payload taken in V, as if it led);
// it must fail.
//===----------------------------------------------------------------------===//
#include "Vmiu_rcap.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>

namespace {

constexpr unsigned kWD = 1024, kWW = kWD / 32, kCW = 72, kCWW = (kCW + 31) / 32;

struct Msg {
  uint32_t rid = 0, hit = 0, own = 0, mlc = 0;
  uint32_t rd[kWW] = {}, cb[kCWW] = {};
};

int g_argc;
char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vmiu_rcap> dut;
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
    dut = std::make_unique<Vmiu_rcap>(ctx.get());
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
    dut->v_cm11h = 0;
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();   // the flopped reset releases a cycle on (RST-1)
  }
  // One cycle: valid v on the wire, payload wires w; then the edge, then
  // the checks of what the edge captured.
  void step(bool v, const Msg &w) {
    dut->v_cm11h = v;
    dut->rid_cm12h = w.rid;
    dut->hit_cm12h = w.hit;
    dut->own_cm12h = w.own;
    dut->mlc_cm12h = w.mlc;
    for (unsigned i = 0; i < kWW; ++i) dut->rd_cm12h[i] = w.rd[i];
    for (unsigned i = 0; i < kCWW; ++i) dut->cb_cm12h[i] = w.cb[i];
    edge();
    // The value model: the payload is on the wire a cycle after the valid
    // (early: with it).
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
    if ((bool(dut->rv_cm12h) != v || bool(dut->cv_cm13h) != vprev) && ++fails <= 20)
      std::fprintf(stderr, "rcap: cycle %llu: rv %d cv %d, want %d %d\n", (unsigned long long)cyc,
                   int(dut->rv_cm12h), int(dut->cv_cm13h), int(v), int(vprev));
    vprev = v;
    if (!known) return;
    ++checked;
    bool ok = dut->rid_cm13h == want.rid && dut->hit_cm13h == want.hit &&
              dut->own_cm13h == want.own && dut->mlc_cm13h == want.mlc;
    for (unsigned i = 0; i < kWW; ++i) ok = ok && dut->rd_cm13h[i] == want.rd[i];
    for (unsigned i = 0; i < kCWW; ++i) ok = ok && dut->cb_cm13h[i] == want.cb[i];
    if (!ok && ++fails <= 20)
      std::fprintf(stderr, "rcap: cycle %llu: capture differs (req_id %u, want %u)\n",
                   (unsigned long long)cyc, unsigned(dut->rid_cm13h), want.rid);
  }
};

struct Gen {
  std::mt19937_64 r;
  explicit Gen(uint64_t seed) : r(seed) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
  Msg msg() {
    Msg m;
    m.rid = below(64);
    m.hit = below(2);
    m.own = below(2);
    m.mlc = below(2);
    for (unsigned i = 0; i < kWW; ++i) m.rd[i] = uint32_t(r());
    for (unsigned i = 0; i < kCWW; ++i) m.cb[i] = uint32_t(r());
    m.cb[kCWW - 1] &= (1u << (kCW % 32)) - 1u;
    return m;
  }
};

int run(const std::string &scenario, const char *vcd, bool ctl) {
  Bench b(vcd, ctl);
  Gen g(0x2ca9);
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
    std::fprintf(stderr, "rcap: coverage: back to back %u, holds %u, noise held off %u\n",
                 b.cov_b2b, b.cov_hold, b.cov_noise);
    ++b.fails;
  }
  std::printf("rcap%s %s: %llu cycles, %u values checked, %u mismatches: %s\n",
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
        std::fprintf(stderr, "rcap: unknown control %s\n", argv[i + 1]);
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "rcap: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
