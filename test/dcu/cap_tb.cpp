//===-- cap_tb.cpp - dcu_cap bench: one ccv_miu_dcu_req slot's capture ----===//
//
// Drives one request slot as MIU does: the valid and lead_set_index in H+1,
// the payload's fields in H+2, and noise on the lead wires whenever no valid
// is up and on the payload wires in every cycle that carries no payload
// (random mode), which the module must not keep. Checks, every cycle, the
// valid and the set a cycle on (D0) and the held payload (req_id, the line's
// PA, pa_fold, drop, coh_op, exclusive_req) from D1 until the next lookup's,
// against a value model of the DCU model's intake (sim/dcu/dcu_block.cpp).
// Lookups come back to back as well as spread, so a capture under a capture
// is covered, and dropped lookups among them (MA-27).
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle is reset and no lookup, the wires still; medium
// a lookup on about a third of the cycles; high one nearly every cycle; the
// wires change only with a lookup. --control early models the payload
// captured with its valid (as if it all led); it must fail.
//===----------------------------------------------------------------------===//
#include "Vdcu_cap.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "ccv_params.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>

namespace {

struct Pay {
  uint32_t rid = 0;
  uint64_t pa = 0;   // the line's PA, bits [47:7]
  uint32_t fold = 0, coh = 0;
  bool drop = false, excl = false;
  bool operator==(const Pay &o) const {
    return rid == o.rid && pa == o.pa && fold == o.fold && coh == o.coh && drop == o.drop &&
           excl == o.excl;
  }
};

int g_argc;
char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vdcu_cap> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0, cov_b2b = 0, cov_hold = 0, cov_noise = 0, cov_drop = 0;
  bool early = false;
  bool vprev = false, known = false;
  uint32_t lsi_want = 0;
  Pay want{};

  Bench(const char *vcd_path, bool ctl) : early(ctl) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vdcu_cap>(ctx.get());
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
    dut->dcu_core_clk = 0;
    eval();
    dut->dcu_core_clk = 1;
    eval();
    ++cyc;
  }
  void reset() {
    dut->rst_n = 0;
    dut->rv_cc01h = 0;
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();   // the flopped reset releases a cycle on (RST-1)
  }
  void fail(const char *what) {
    if (++fails <= 20) std::fprintf(stderr, "cap: cycle %llu: %s\n", (unsigned long long)cyc, what);
  }
  // One cycle: the valid v and the set lsi on the wire, payload wires w;
  // then the edge, then the checks of what the edge captured.
  void step(bool v, uint32_t lsi, const Pay &w) {
    dut->rv_cc01h = v;
    dut->lsi_cc01h = lsi;
    dut->rid_cc02h = w.rid;
    dut->pa_cc02h = w.pa;
    dut->fold_cc02h = w.fold;
    dut->drop_cc02h = w.drop;
    dut->coh_cc02h = w.coh;
    dut->excl_cc02h = w.excl;
    edge();
    // The value model: the payload is on the wire a cycle after its valid
    // (early: with it).
    const bool take = early ? v : vprev;
    if (take) {
      cov_b2b += known && vprev && v;
      want = w;
      known = true;
      cov_drop += w.drop;
    } else if (known) {
      ++cov_hold;
      cov_noise += !(w == want);
    }
    ++checked;
    if (bool(dut->v_cc02h) != v) fail("v_cc02h differs");
    if (v) {   // the set is read only beside its valid
      ++checked;
      if (dut->lsi_cc02h != lsi) fail("lsi_cc02h differs");
    }
    vprev = v;
    if (!known) return;
    ++checked;
    Pay got;
    got.rid = dut->rid_cc03h;
    got.pa = dut->pa_cc03h;
    got.fold = dut->fold_cc03h;
    got.drop = dut->drop_cc03h;
    got.coh = dut->coh_cc03h;
    got.excl = dut->excl_cc03h;
    if (!(got == want)) fail("payload capture differs");
  }
};

struct Gen {
  std::mt19937_64 r;
  explicit Gen(uint64_t seed) : r(seed) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
  Pay pay() {
    Pay p;
    p.rid = unsigned(r()) & 63;
    p.pa = r() & ((uint64_t(1) << 41) - 1);
    p.fold = unsigned(r()) & ((1u << ccv::prov::kDcuWaypredBits) - 1);
    p.drop = below(5) == 0;
    p.coh = unsigned(r()) & 15;
    p.excl = r() & 1;
    return p;
  }
};

int run(const std::string &scenario, const char *vcd, bool ctl) {
  Bench b(vcd, ctl);
  Gen g(0xdc0);
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 50000 : scenario == "idle" ? 3000 : 4000;
  Pay w{}, next{};
  uint32_t lsi = 0;
  bool pend = false;   // a valid went out last cycle: its payload goes on the wire now
  for (unsigned i = 0; i < n; ++i) {
    const bool v = scenario == "idle"     ? false
                   : scenario == "medium" ? (i % 3 == 0 && g.below(10) < 8)
                   : scenario == "high"   ? g.below(10) < 9
                                          : (i / 64) % 2 ? g.below(10) < 9 : g.below(4) == 0;
    if (pend) w = next;
    else if (rnd && g.below(2)) w = g.pay();
    if (v) {
      next = g.pay();
      lsi = g.below(512);
    } else if (rnd && g.below(2)) {
      lsi = g.below(512);   // noise on the lead wires with no valid
    }
    pend = v;
    b.step(v, lsi, w);
  }
  if (rnd && (!b.cov_b2b || !b.cov_hold || !b.cov_noise || !b.cov_drop)) {
    std::fprintf(stderr, "cap: coverage: back to back %u, holds %u, noise held off %u, drops %u\n",
                 b.cov_b2b, b.cov_hold, b.cov_noise, b.cov_drop);
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
