//===-- cred_tb.cpp - miu_cred bench: DCU bank credits and the A1 gate ------===//
//
// Plays miu_lead, miu_a2 and DCU around miu_cred. Each cycle a memop may be
// in A1 on any slot (a1v); the next cycle each such slot may launch, to a
// random bank, only if the gate it read in A1 passed, used[b] ? ge2[b] :
// ge1[b], used[b] the bench's own launches to b that cycle; a launch may be
// a store, when its bank has a store-data credit left. Two cycles after A1,
// A2 drops some launches and miu_cred refunds them. DCU returns every
// credit it holds, at most one of each kind a bank a cycle, its valid a
// cycle ahead of its payload, back to back or spread.
// Checks, every cycle, ge1 and ge2 against a value model of the model's
// counters (sim/miu/miu_block.cpp): a spend counted at its launch, a refund
// at A2's flopped drop, a return the cycle after its payload lands, and the
// gate flops from the counts after the cycle before. miu_cred's assertion
// (no count below 0 or past full) fails the run if it fires.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle is reset and nothing; medium a memop in A1 on
// about a third of the cycles; high nearly every cycle.
// Controls, each of which must fail: early models a return counted the
// cycle its payload lands; norefund models A2's drops never refunded.
//===----------------------------------------------------------------------===//
#include "Vmiu_cred.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <deque>
#include <memory>
#include <random>
#include <string>
#include <vector>

namespace {

constexpr unsigned kNS = 4, kNB = 8, kQD = 16, kSD = 12, kLK = 4;

enum class Ctl { none, early, norefund };

int g_argc;
char **g_argv;

struct Launch {
  bool v = false, store = false;
  unsigned bank = 0;
};

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vmiu_cred> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  unsigned cov_ge1_off = 0, cov_ge2_off = 0, cov_held = 0, cov_ret_b2b = 0, cov_refund = 0,
           cov_multi = 0, cov_store = 0;
  Ctl ctl;
  // The value model: counts after the last cycle, and the gate flops.
  int ent[kNB], std_[kNB];
  bool ge1[kNB], ge2[kNB];
  // DCU's side: credits it holds, a bank each kind.
  int held_ent[kNB] = {}, held_std[kNB] = {};

  Bench(const char *vcd_path, Ctl c) : ctl(c) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vmiu_cred>(ctx.get());
    if (vcd_path) {
      vcd = std::make_unique<VerilatedVcdC>();
      dut->trace(vcd.get(), 99);
      vcd->open(vcd_path);
    }
    for (unsigned b = 0; b < kNB; ++b) {
      ent[b] = kQD;
      std_[b] = kSD;
      ge1[b] = kQD >= kLK;
      ge2[b] = kQD >= 2 * kLK;
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
    dut->a1v_cm05h = 0;
    dut->sv_cm06h = 0;
    dut->rv_cm07h = 0;
    dut->cv_cm04h = 0;
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();   // the flopped reset releases a cycle on (RST-1)
  }
};

unsigned dut_ge(const Bench &b, int n) { return n == 1 ? b.dut->ge1_cm07h : b.dut->ge2_cm07h; }

struct Gen {
  std::mt19937_64 r;
  explicit Gen(uint64_t seed) : r(seed) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
};

int run(const std::string &scenario, const char *vcd, Ctl ctl) {
  Bench b(vcd, ctl);
  Gen g(0xc4ed);
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 60000 : scenario == "idle" ? 3000 : 4000;
  unsigned a1v_prev = 0;               // A1 last cycle: may launch now
  bool gate_prev[kNS][kNB] = {};       // the gate each A1 slot read, a bank each
  Launch launch_prev[kNS] = {};        // launched last cycle: A2 may drop now
  bool cv_prev = false;                // DCU's valid last cycle: its payload now
  unsigned er_next = 0, dr_next = 0;   // that payload
  unsigned er_land = 0, dr_land = 0;   // the payload that landed last cycle
  bool land_prev = false;
  for (unsigned i = 0; i < n; ++i) {
    // Activity.
    const unsigned dens = scenario == "idle"     ? 0
                          : scenario == "medium" ? (i % 3 == 0 ? 7 : 0)
                          : scenario == "high"   ? 9
                                                 : (i / 128) % 2 ? 9 : 3;
    // A1: memops this cycle; each reads the gate now (the DUT's flops).
    unsigned a1v = 0;
    for (unsigned k = 0; k < kNS; ++k)
      if (g.below(10) < dens) a1v |= 1u << k;
    // H+1: launches from last cycle's A1, through the gate it read.
    Launch launch[kNS] = {};
    unsigned used_now = 0, sv = 0, sb = 0, ss = 0;
    int std_left[kNB];
    for (unsigned bk = 0; bk < kNB; ++bk) std_left[bk] = b.std_[bk];
    unsigned per_bank[kNB] = {};
    // A launch's bank: concentrated on a few banks often, so the gate bites.
    const unsigned hot = g.below(kNB);
    for (unsigned k = 0; k < kNS; ++k) {
      if (!(a1v_prev >> k & 1u)) continue;
      const unsigned bk = g.below(3) ? hot : g.below(kNB);
      if (!gate_prev[k][bk]) {
        ++b.cov_held;
        continue;
      }
      launch[k].v = true;
      launch[k].bank = bk;
      if (std_left[bk] > 0 && g.below(3) == 0) {
        launch[k].store = true;
        --std_left[bk];
        ++b.cov_store;
      }
      sv |= 1u << k;
      sb |= bk << (k * 3);
      ss |= unsigned(launch[k].store) << k;
      used_now |= 1u << bk;
      if (++per_bank[bk] > 1) ++b.cov_multi;
    }
    // A1's gate, read now from the DUT's flops (the counts after last
    // cycle), with used[b] this cycle's launches, which they do not hold.
    bool gate_now[kNS][kNB];
    for (unsigned k = 0; k < kNS; ++k)
      for (unsigned bk = 0; bk < kNB; ++bk) {
        const bool used = used_now >> bk & 1u;
        const bool g1 = (dut_ge(b, 1) >> bk) & 1u, g2 = (dut_ge(b, 2) >> bk) & 1u;
        gate_now[k][bk] = used ? g2 : g1;
      }
    // H+2: A2 drops some of last cycle's launches; refunded now.
    unsigned rv = 0, rb = 0;
    for (unsigned k = 0; k < kNS; ++k)
      if (launch_prev[k].v && g.below(4) == 0) {
        rv |= 1u << k;
        rb |= launch_prev[k].bank << (k * 3);
        ++b.cov_refund;
      }
    // DCU: holds the launches not dropped (a launch is DCU's once its
    // payload lands; the bench counts it at A2, when it is not dropped).
    for (unsigned k = 0; k < kNS; ++k)
      if (launch_prev[k].v && !(rv >> k & 1u)) {
        ++b.held_ent[launch_prev[k].bank];
        if (launch_prev[k].store) ++b.held_std[launch_prev[k].bank];
      }
    // DCU's return: a payload now if its valid went last cycle; a valid now
    // for next cycle's payload, a bit a bank of what it holds.
    const unsigned er_wire = cv_prev ? er_next : 0, dr_wire = cv_prev ? dr_next : 0;
    bool cv = false;
    unsigned er_n = 0, dr_n = 0;
    if (g.below(10) < (scenario == "idle" ? 0 : 6)) {
      for (unsigned bk = 0; bk < kNB; ++bk) {
        if (b.held_ent[bk] > 0 && g.below(2)) {
          er_n |= 1u << bk;
          --b.held_ent[bk];
        }
        if (b.held_std[bk] > 0 && g.below(2)) {
          dr_n |= 1u << bk;
          --b.held_std[bk];
        }
      }
      cv = er_n || dr_n;
      b.cov_ret_b2b += cv && cv_prev;
    }
    // Drive and clock.
    b.dut->a1v_cm05h = a1v;
    b.dut->sv_cm06h = sv;
    b.dut->sb_cm06h = sb;
    b.dut->ss_cm06h = ss;
    b.dut->rv_cm07h = rv;
    b.dut->rb_cm07h = rb;
    b.dut->cv_cm04h = cv;
    b.dut->er_cm05h = er_wire;
    b.dut->dr_cm05h = dr_wire;
    b.edge();
    // The model: this cycle's spends and refunds, and the return that
    // landed last cycle (early: the one landing now).
    for (unsigned k = 0; k < kNS; ++k) {
      if (launch[k].v) {
        --b.ent[launch[k].bank];
        if (launch[k].store) --b.std_[launch[k].bank];
      }
      if ((rv >> k & 1u) && ctl != Ctl::norefund) ++b.ent[launch_prev[k].bank];
    }
    const unsigned er_cnt = ctl == Ctl::early ? er_wire : land_prev ? er_land : 0;
    const unsigned dr_cnt = ctl == Ctl::early ? dr_wire : land_prev ? dr_land : 0;
    for (unsigned bk = 0; bk < kNB; ++bk) {
      b.ent[bk] += er_cnt >> bk & 1u;
      b.std_[bk] += dr_cnt >> bk & 1u;
      b.ge1[bk] = b.ent[bk] >= int(kLK);
      b.ge2[bk] = b.ent[bk] >= int(2 * kLK);
      b.cov_ge1_off += !b.ge1[bk];
      b.cov_ge2_off += b.ge1[bk] && !b.ge2[bk];
    }
    ++b.checked;
    unsigned w1 = 0, w2 = 0;
    for (unsigned bk = 0; bk < kNB; ++bk) {
      w1 |= unsigned(b.ge1[bk]) << bk;
      w2 |= unsigned(b.ge2[bk]) << bk;
    }
    if ((dut_ge(b, 1) != w1 || dut_ge(b, 2) != w2) && ++b.fails <= 20)
      std::fprintf(stderr, "cred: cycle %llu: ge1 %02x ge2 %02x, want %02x %02x\n",
                   (unsigned long long)b.cyc, dut_ge(b, 1), dut_ge(b, 2), w1, w2);
    // Roll.
    land_prev = cv_prev;
    er_land = er_wire;
    dr_land = dr_wire;
    cv_prev = cv;
    er_next = er_n;
    dr_next = dr_n;
    a1v_prev = a1v;
    std::memcpy(gate_prev, gate_now, sizeof gate_now);
    for (unsigned k = 0; k < kNS; ++k) launch_prev[k] = launch[k];
    if (Verilated::gotError() || b.ctx->gotFinish()) {
      ++b.fails;
      std::fprintf(stderr, "cred: cycle %llu: an assertion fired\n", (unsigned long long)b.cyc);
      break;
    }
  }
  if (rnd && (!b.cov_ge1_off || !b.cov_ge2_off || !b.cov_held || !b.cov_ret_b2b ||
              !b.cov_refund || !b.cov_multi || !b.cov_store)) {
    std::fprintf(stderr,
                 "cred: coverage: ge1 off %u, ge2 off %u, held %u, returns back to back %u, "
                 "refunds %u, two on a bank %u, stores %u\n",
                 b.cov_ge1_off, b.cov_ge2_off, b.cov_held, b.cov_ret_b2b, b.cov_refund,
                 b.cov_multi, b.cov_store);
    ++b.fails;
  }
  const char *cn = ctl == Ctl::early ? " control early:" : ctl == Ctl::norefund ? " control norefund:" : ":";
  std::printf("cred%s %s: %llu cycles, %u values checked, %u mismatches: %s\n", cn,
              rnd ? "random" : scenario.c_str(), (unsigned long long)b.cyc, b.checked, b.fails,
              b.fails ? "FAIL" : "PASS");
  return b.fails ? 1 : 0;
}

}  // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string scenario;
  const char *vcd = nullptr;
  Ctl ctl = Ctl::none;
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control")) {
      if (!std::strcmp(argv[i + 1], "early")) ctl = Ctl::early;
      else if (!std::strcmp(argv[i + 1], "norefund")) ctl = Ctl::norefund;
      else {
        std::fprintf(stderr, "cred: unknown control %s\n", argv[i + 1]);
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "cred: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
