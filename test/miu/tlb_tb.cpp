//===-- tlb_tb.cpp - miu_tlb bench: the L0s at A2 and the 32-entry TLB at A3 -===//
//
// MA rev 199 (re:MI-31): each lookup slot's 4-entry L0, refilled from one
// 32-entry TLB at A3 through one port, round robin over the slots. The
// bench drives what miu_lead and miu_a2 would: each slot's request valid
// (the lead, rv_cm06h), and a cycle on the slot's leader VPN and its L0
// miss (vpn_cm07h, ms_cm07h); and the walker's fill (fv_cm05h, its VPN,
// PPN and perms a cycle on). A value model mirrors the module's flops cycle
// by cycle: the TLB's entries in fill order, each slot's pending refill
// (replaced by the slot's next lead), the grant, the compare a cycle on
// (an OR of every matching entry), and each slot's L0 written in turn.
// Every cycle it checks all 16 L0 entries (valid, VPN, PPN, fold, perms)
// and A3's miss with its VPN.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py); the wires change only with their valids. Controls,
// each of which must fail: early (the L0 written a cycle early) and norr
// (the grant always to the lowest pending slot).
//===----------------------------------------------------------------------===//
#include "Vmiu_tlb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "wayfold.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>

namespace {

constexpr unsigned kNS = 4, kN0 = 4, kNT = 32, kFW = 4;

struct Ent { bool v = false; uint32_t vpn = 0, ppn = 0, fold = 0, pm = 0; };

int g_argc;
char **g_argv;

struct In {
  unsigned rv = 0, ms = 0;     // per slot
  uint32_t vpn[kNS] = {};
  bool fv = false;             // the fill's valid; its payload a cycle on
  uint32_t fvpn = 0, fppn = 0, fpm = 0;
};

struct Model {
  bool fvq = false;
  unsigned tp = 0;
  Ent te[kNT];
  unsigned rq = 0, pm = 0, rr = 0;
  uint32_t vq[kNS] = {};
  bool sa = false;
  unsigned sg = 0;
  uint32_t sv = 0;
  bool ra = false, rh = false, tmo = false;
  unsigned rs = 0;
  uint32_t rp = 0, rf = 0, rg = 0, rvv = 0;
  unsigned wp[kNS] = {};
  Ent l0[kNS][kN0];
};

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vmiu_tlb> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  unsigned cov_hit = 0, cov_miss = 0, cov_contend = 0, cov_wrap = 0, cov_cancel = 0;
  std::string ctl;
  Model m;

  Bench(const char *vcd_path, std::string c) : ctl(std::move(c)) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vmiu_tlb>(ctx.get());
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
  void drive(const In &in) {
    dut->rv_cm06h = in.rv;
    dut->ms_cm07h = in.ms;
    for (unsigned s = 0; s < kNS; ++s) dut->vpn_cm07h[s] = in.vpn[s];
    dut->fv_cm05h = in.fv;
    dut->fvpn_cm06h = in.fvpn;
    dut->fppn_cm06h = in.fppn;
    dut->fpm_cm06h = in.fpm;
    dut->ffold_cm06h = ccv::skel::wayFoldTag(in.fppn, kFW);
  }
  void reset() {
    dut->rst_n = 0;
    drive(In{});
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();   // the flopped reset releases a cycle on (RST-1)
    m = Model{};
  }
  // The grant over pm from rr (norr: from 0), as a slot index, or kNS.
  unsigned grant(const Model &o) const {
    for (unsigned k = 0; k < kNS; ++k) {
      const unsigned s = ctl == "norr" ? k : (o.rr + k) % kNS;
      if (o.pm >> s & 1) return s;
    }
    return kNS;
  }
  // The next state from the old state o and this cycle's inputs.
  Model next(const Model &o, const In &in) {
    Model n = o;
    // The TLB's fill.
    n.fvq = in.fv;
    if (o.fvq) {
      n.te[o.tp] = {true, in.fvpn, in.fppn, ccv::skel::wayFoldTag(in.fppn, kFW), in.fpm};
      n.tp = (o.tp + 1) % kNT;
    }
    // The capture and the pending refills.
    n.rq = in.rv;
    const unsigned g = grant(o);
    for (unsigned s = 0; s < kNS; ++s) {
      if (o.rq >> s & 1) {
        n.vq[s] = in.vpn[s];
        cov_cancel += (o.pm >> s & 1) && g != s && !(in.ms >> s & 1);
        n.pm = (n.pm & ~(1u << s)) | ((in.ms >> s & 1) << s);
      } else if (g == s) {
        n.pm &= ~(1u << s);
      }
    }
    if (o.pm) n.rr = (g + 1) % kNS;
    cov_contend += __builtin_popcount(o.pm) > 1;
    // The grant's flops.
    n.sa = o.pm != 0;
    if (o.pm) { n.sg = g; n.sv = o.vq[g]; }
    // The compare, a cycle on: every matching entry ORed.
    bool hit = false;
    uint32_t p = 0, f = 0, pg = 0;
    for (const Ent &e : o.te)
      if (e.v && e.vpn == o.sv) { hit = true; p |= e.ppn; f |= e.fold; pg |= e.pm; }
    n.ra = o.sa;
    n.tmo = o.sa && !hit;
    if (o.sa) {
      n.rh = hit; n.rs = o.sg; n.rp = p; n.rf = f; n.rg = pg; n.rvv = o.sv;
      cov_hit += hit;
      cov_miss += !hit;
    }
    // Each slot's L0, a cycle on (early: from the compare itself).
    const bool w = ctl == "early" ? (o.sa && hit) : (o.ra && o.rh);
    const unsigned ws = ctl == "early" ? o.sg : o.rs;
    const Ent we = ctl == "early" ? Ent{true, o.sv, p, f, pg} : Ent{true, o.rvv, o.rp, o.rf, o.rg};
    if (w) {
      n.l0[ws][o.wp[ws]] = we;
      n.wp[ws] = (o.wp[ws] + 1) % kN0;
      cov_wrap += o.wp[ws] == kN0 - 1;
    }
    return n;
  }
  void step(const In &in) {
    drive(in);
    edge();
    m = next(m, in);
    ++checked;
    bool ok = bool(dut->tm_cm10h) == m.tmo && (!m.tmo || dut->tmv_cm10h == m.rvv);
    for (unsigned s = 0; s < kNS; ++s)
      for (unsigned e = 0; e < kN0; ++e) {
        const unsigned i = s * kN0 + e;
        const Ent &w = m.l0[s][e];
        ++checked;
        const bool v = dut->l0v_cm11h >> i & 1;
        ok = ok && v == w.v;
        if (!w.v) continue;
        ok = ok && dut->l0vpn_cm11h[i] == w.vpn && dut->l0ppn_cm11h[i] == w.ppn &&
             uint32_t(dut->l0fold_cm11h >> (i * kFW) & 0xf) == w.fold &&
             uint32_t(dut->l0pm_cm11h >> i & 1) == w.pm;
      }
    if (!ok && ++fails <= 20)
      std::fprintf(stderr, "tlb: cycle %llu: an L0 entry or A3's miss differs\n",
                   (unsigned long long)cyc);
  }
};

struct Gen {
  std::mt19937_64 r;
  explicit Gen(uint64_t seed) : r(seed) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
  uint32_t page() { return 0x1000u + below(48); }   // 48 pages: the TLB holds 32
};

int run(const std::string &scenario, const char *vcd, const std::string &ctl) {
  Bench b(vcd, ctl);
  Gen g(0x71b0);
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 60000 : scenario == "idle" ? 3000 : 4000;
  In prev{}, cur{};
  for (unsigned i = 0; i < n; ++i) {
    // Rates: valid per slot, miss given a valid, fill.
    unsigned pv = 0, pmiss = 0, pf = 0;
    if (scenario == "medium") { pv = 8; pmiss = 25; pf = 4; }
    else if (scenario == "high") { pv = 30; pmiss = 50; pf = 15; }
    else if (rnd) { const bool busy = (i / 128) % 2; pv = busy ? 60 : 15; pmiss = busy ? 60 : 30; pf = busy ? 25 : 5; }
    In in{};
    // The lead now; the VPN and miss a cycle on, under last cycle's lead.
    for (unsigned s = 0; s < kNS; ++s) {
      if (g.below(100) < pv) in.rv |= 1u << s;
      if (prev.rv >> s & 1) {
        in.vpn[s] = g.page();
        if (g.below(100) < pmiss) in.ms |= 1u << s;
      } else {
        in.vpn[s] = rnd && g.below(2) ? uint32_t(g.r()) : prev.vpn[s];
        if (rnd) in.ms = (in.ms & ~(1u << s)) | (g.below(2) << s);
      }
    }
    in.fv = g.below(100) < pf;
    if (prev.fv) {
      in.fvpn = g.page();
      in.fppn = uint32_t(g.r());
      in.fpm = g.below(2);
    } else {
      in.fvpn = rnd && g.below(2) ? uint32_t(g.r()) : prev.fvpn;
      in.fppn = rnd && g.below(2) ? uint32_t(g.r()) : prev.fppn;
      in.fpm = rnd ? g.below(2) : prev.fpm;
    }
    // Keep the TLB's fills distinct from what it holds at random: a fill of
    // a held page is the walker's to avoid, not the TLB's.
    if (prev.fv)
      for (const Ent &e : b.m.te)
        if (e.v && e.vpn == in.fvpn) { in.fvpn = 0x2000u + g.below(1u << 20); break; }
    b.step(in);
    prev = in;
    cur = in;
  }
  (void)cur;
  if (rnd && (!b.cov_hit || !b.cov_miss || !b.cov_contend || !b.cov_wrap || !b.cov_cancel)) {
    std::fprintf(stderr, "tlb: coverage: hit %u miss %u contend %u wrap %u cancel %u\n",
                 b.cov_hit, b.cov_miss, b.cov_contend, b.cov_wrap, b.cov_cancel);
    ++b.fails;
  }
  std::printf("tlb%s%s %s: %llu cycles, %u values checked, %u mismatches: %s\n",
              ctl.empty() ? "" : " control ", ctl.empty() ? ":" : (ctl + ":").c_str(),
              rnd ? "random" : scenario.c_str(), (unsigned long long)b.cyc, b.checked, b.fails,
              b.fails ? "FAIL" : "PASS");
  if (rnd && !ctl.empty())
    std::printf("tlb: coverage: hit %u miss %u contend %u wrap %u cancel %u\n", b.cov_hit,
                b.cov_miss, b.cov_contend, b.cov_wrap, b.cov_cancel);
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
      if (ctl != "early" && ctl != "norr") {
        std::fprintf(stderr, "tlb: unknown control %s\n", ctl.c_str());
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "tlb: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
