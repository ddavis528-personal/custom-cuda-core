//===-- hitq_tb.cpp - miu_hitq bench: the first-pass delay line ------------===//
//
// Drives the line as its neighbours do. An A1 event at cycle H puts memops
// on some address slots: miu_cap's valids at H-1 (v_cm04h), miu_pair's
// entries held from H (a1e_cm05h; a slot without a new memop keeps its
// old entry), miu_lead's req valids and leader one-hots at H+1 (rv_cm06h,
// lq_cm06h: lookup slot k belongs to the memop whose footprint holds it,
// its leader in one quarter), and miu_a2's drops at H+2 (dr_cm07h). Events
// come at random footprints (1, 2 or 4 pipes, lead pipe = address slot),
// back to back as well as spread, a lookup slot launching or not.
// Checks, every cycle, R1's outputs (hv, he, hs at H+7) against a value
// model: lookup slot k's launch less its drop, its memop's MQ entry and
// address slot. he and hs are checked only under hv (a guarded payload).
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle no event; medium an event on about a third of
// the cycles; high one every cycle; inputs change only with an event.
// --control nodrop models the line without A2's drop; --control early
// expects R1 a cycle early. Each must fail.
//===----------------------------------------------------------------------===//
#include "Vmiu_hitq.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <deque>
#include <map>
#include <memory>
#include <random>
#include <string>

namespace {

constexpr unsigned kNS = 4, kNQ = 4, kNE = 40, kEW = 6, kSB = 2;
constexpr unsigned kLine = 7;   // H+1's launch to R1 (H+7): the expected cycle is H+7

struct Ev {               // one A1 event, at cycle H
  uint64_t h = 0;
  unsigned vmask = 0;     // address slots with a new memop
  unsigned ent[kNS] = {}; // their entries
  unsigned owner[kNS] = {};   // lookup slot k's address slot
  unsigned q[kNS] = {};       // its leader's quarter
  unsigned rv = 0, dr = 0;    // lookup slots that launch; of those, the dropped
  unsigned fp = 1;            // the footprint, pipes a memop
};

int g_argc;
char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vmiu_hitq> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  std::string ctl;

  Bench(const char *vcd_path, std::string c) : ctl(std::move(c)) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vmiu_hitq>(ctx.get());
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
    dut->v_cm04h = 0;
    dut->rv_cm06h = 0;
    dut->dr_cm07h = 0;
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();   // the flopped reset releases a cycle on (RST-1)
  }
};

struct Gen {
  std::mt19937_64 r;
  explicit Gen(uint64_t seed) : r(seed) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
  Ev ev(uint64_t h) {
    Ev e;
    e.h = h;
    const unsigned f = 1u << below(3);   // footprint: 1, 2 or 4 pipes
    e.fp = f;
    for (unsigned s = 0; s < kNS; s += f)
      if (below(4)) {
        e.vmask |= 1u << s;
        e.ent[s] = below(kNE);
        for (unsigned k = s; k < s + f; ++k) {
          e.owner[k] = s;
          e.q[k] = below(kNQ);
          if (below(5)) {
            e.rv |= 1u << k;
            if (!below(4)) e.dr |= 1u << k;
          }
        }
      }
    if (!e.vmask) {   // at least one memop
      e.vmask = 1;
      e.ent[0] = below(kNE);
      for (unsigned k = 0; k < f; ++k) e.owner[k] = 0, e.q[k] = below(kNQ), e.rv |= 1u << k;
    }
    return e;
  }
};

int run(const std::string &scenario, const char *vcd, const std::string &ctl) {
  Bench b(vcd, ctl);
  Gen g(0x417c);
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 50000 : scenario == "idle" ? 3000 : 4000;
  std::map<uint64_t, Ev> evs;   // by H
  // The wires' held values: a slot's entry until its next memop, the
  // one-hots and drops until the next event's.
  uint32_t a1e = 0;
  uint64_t lq = 0;
  unsigned cov_drop = 0, cov_b2b = 0, cov_f[3] = {0, 0, 0};
  // Expected R1 outputs by the cycle they are seen (after the edge).
  struct Want { unsigned hv = 0, he[kNS] = {}, hs[kNS] = {}; };
  std::map<uint64_t, Want> want;
  const uint64_t base = b.cyc;
  for (uint64_t i = 0; i < n; ++i) {
    const uint64_t c = base + i;   // this cycle: inputs apply now, the edge ends it
    // A new event at H = c + 1 (its valids go out now, at H-1).
    const bool go = i + 8 < n && (scenario == "idle"     ? false
                                  : scenario == "medium" ? (i % 3 == 0)
                                  : scenario == "high"   ? true
                                                         : ((i / 64) % 2 ? g.below(10) < 9 : g.below(4) == 0));
    if (go) {
      Ev e = g.ev(c + 1);
      cov_b2b += evs.count(c) != 0;
      ++cov_f[e.fp == 1 ? 0 : e.fp == 2 ? 1 : 2];
      evs[c + 1] = e;
    }
    unsigned v04 = 0, rv = 0, dr = 0;
    if (auto it = evs.find(c + 1); it != evs.end()) v04 = it->second.vmask;
    if (auto it = evs.find(c); it != evs.end())   // H = c: entries held from now
      for (unsigned s = 0; s < kNS; ++s)
        if (it->second.vmask >> s & 1u)
          a1e = (a1e & ~(((1u << kEW) - 1) << (s * kEW))) | (it->second.ent[s] << (s * kEW));
    if (auto it = evs.find(c - 1); it != evs.end()) {   // H+1: launches and leaders
      const Ev &e = it->second;
      rv = e.rv;
      lq = 0;
      for (unsigned k = 0; k < kNS; ++k)
        if (e.vmask >> e.owner[k] & 1u)
          lq |= uint64_t(1) << ((k * kNS + e.owner[k]) * kNQ + e.q[k]);
    }
    if (auto it = evs.find(c - 2); it != evs.end()) {   // H+2: drops
      const Ev &e = it->second;
      dr = e.dr & e.rv;
      cov_drop += dr != 0;
      // The value model: R1 = H+7, seen after the edge ending cycle H+6.
      Want w;
      const unsigned rvm = e.rv & ~(b.ctl == "nodrop" ? 0u : dr);
      for (unsigned k = 0; k < kNS; ++k)
        if (rvm >> k & 1u) {
          w.hv |= 1u << k;
          w.he[k] = e.ent[e.owner[k]];
          w.hs[k] = e.owner[k];
        }
      want[e.h + kLine - 1 - (b.ctl == "early" ? 1 : 0)] = w;
      evs.erase(it);
    }
    b.dut->v_cm04h = v04;
    b.dut->a1e_cm05h = a1e;
    b.dut->rv_cm06h = rv;
    b.dut->lq_cm06h = lq;
    b.dut->dr_cm07h = dr;
    b.edge();
    // After the edge ending cycle c: R1's outputs of the event with H+6 = c.
    Want w{};
    if (auto it = want.find(c); it != want.end()) {
      w = it->second;
      want.erase(it);
    }
    ++b.checked;
    bool ok = b.dut->hv_cm12h == w.hv;
    for (unsigned k = 0; k < kNS; ++k)
      if (w.hv >> k & 1u) {
        ok = ok && ((b.dut->he_cm12h >> (k * kEW)) & ((1u << kEW) - 1)) == w.he[k];
        ok = ok && ((b.dut->hs_cm12h >> (k * kSB)) & ((1u << kSB) - 1)) == w.hs[k];
      }
    if (!ok && ++b.fails <= 20)
      std::fprintf(stderr, "hitq: cycle %llu: hv %x he %06x hs %02x, want hv %x\n",
                   (unsigned long long)c, unsigned(b.dut->hv_cm12h), unsigned(b.dut->he_cm12h),
                   unsigned(b.dut->hs_cm12h), w.hv);
  }
  if (rnd && (!cov_drop || !cov_b2b || !cov_f[0] || !cov_f[1] || !cov_f[2])) {
    std::fprintf(stderr, "hitq: coverage: drops %u, back to back %u, footprints 1/2/4 %u %u %u\n",
                 cov_drop, cov_b2b, cov_f[0], cov_f[1], cov_f[2]);
    ++b.fails;
  }
  std::printf("hitq%s%s %s: %llu cycles, %u values checked, %u mismatches: %s\n",
              ctl.empty() ? "" : " control ", ctl.empty() ? ":" : (ctl + ":").c_str(),
              rnd ? "random" : scenario.c_str(), (unsigned long long)b.cyc, b.checked, b.fails,
              b.fails ? "FAIL" : "PASS");
  return b.fails ? 1 : 0;
}

}  // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string scenario, ctl;
  const char *vcd = nullptr;
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control")) {
      ctl = argv[i + 1];
      if (ctl != "nodrop" && ctl != "early") {
        std::fprintf(stderr, "hitq: unknown control %s\n", ctl.c_str());
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "hitq: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
