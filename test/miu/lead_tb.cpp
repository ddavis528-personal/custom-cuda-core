//===-- lead_tb.cpp - miu_lead bench: A1 leaders, set index and the gate ---===//
//
// Drives miu_lead as its sources do: miu_cap's valids a cycle ahead of the
// A1 fields; per valid address slot a memop whose footprint (1, 2 or 4
// pipes, disjoint across slots, its lead pipe the slot: ctz(pipes) = s),
// lane mask, operands, forms and per-quarter {sh2, sh1, disp} copies sit on
// the wires in A1; miu_cred's ge1/ge2 every cycle. Slots with no valid
// carry noise in random mode.
//
// The value model is the MIU model's leadersOf and A1 gate
// (sim/miu/miu_block.cpp): lookup slot k's group is the memop owning pipe k,
// its lanes [g*32/F, (g+1)*32/F) for g the memop's pipes below k, the
// leader its first lane by position (MA rev 199, CCV_MIU_LEAD_POS), the
// lookup launching if the group has an active lane. The set index is S[15:7] of the leader's
// sum's low 16 bits, (index << scale) + disp; S[10:2] for an interleaved
// form (the eligible bit and lane d's base equal to W); disp[10:2] for the
// local form. The gate: every bank's used[b] ? ge2[b] : ge1[b], used the
// banks of last cycle's launches. Checks, a cycle on: every valid, and for
// each slot with a leader the set index, the (slot, quarter) one-hot, the
// leader lane's activity, the form, the interleaved VPN's l6 = {0, S[15:11]}
// + bl and R(ctx)'s VPN[31:6] for carry 0 and 1.
//
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle is reset and no memop, the wires still; medium
// a memop on about a third of the cycles; high nearly every cycle; the
// fields change only with a memop. Controls, each must fail: used (the
// model's gate reads ge1 alone, never last cycle's launches), scale (the
// model ignores the index's scale), lowest (the model's leader is a group's
// lowest active lane, the pick the fixed leader replaced).
//===----------------------------------------------------------------------===//
#include "Vmiu_lead.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>

namespace {

constexpr unsigned kNS = 4, kNL = 32, kNQ = 4, kNB = 8, kSW = 9;

int g_argc;
char **g_argv;

template <typename W> void putBits(W &w, unsigned o, unsigned n, uint64_t v) {
  for (unsigned b = 0; b < n; ++b) {
    const unsigned i = o + b;
    w[i / 32] = (w[i / 32] & ~(1u << (i % 32))) | (uint32_t((v >> b) & 1u) << (i % 32));
  }
}
template <typename W> uint64_t getBits(const W &w, unsigned o, unsigned n) {
  uint64_t v = 0;
  for (unsigned b = 0; b < n; ++b) v |= uint64_t((w[(o + b) / 32] >> ((o + b) % 32)) & 1u) << b;
  return v;
}

/// One address slot's A1 fields.
struct Slot {
  bool ld = false;
  unsigned pipes = 0, fs = 0, dlane = 0;   // fs: {ilv-eligible, local, slot}
  unsigned sh1 = 0, sh2 = 0, disp = 0;      // disp: its low 16 bits
  uint32_t am = 0, wh = 0;
  uint64_t rk = 0;                          // {ctx 7, hi + 1 20, hi 20, lo8 8, bl 6}
  std::array<uint32_t, kNL> base{}, idx{};
};

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vmiu_lead> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  std::string ctl;
  unsigned vq = 0, used = 0;   // the valids a cycle ago; last cycle's launch banks
  // Coverage.
  unsigned cov_f[5] = {}, cov_hold = 0, cov_used = 0, cov_ilv = 0, cov_loc = 0, cov_ord = 0,
           cov_sc[3] = {}, cov_skip = 0, cov_c1 = 0;

  Bench(const char *vcd_path, const std::string &c) : ctl(c) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    ctx->fatalOnError(false);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vmiu_lead>(ctx.get());
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
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();   // the flopped reset releases a cycle on (RST-1)
    edge();
  }
  void drive(const std::array<Slot, kNS> &a, unsigned ge1, unsigned ge2) {
    dut->ld_cm05h = 0;
    dut->pipes_cm05h = 0;
    dut->fs_cm05h = 0;
    for (unsigned s = 0; s < kNS; ++s) {
      const Slot &x = a[s];
      dut->ld_cm05h |= unsigned(x.ld) << s;
      dut->pipes_cm05h |= x.pipes << (s * kNS);
      dut->fs_cm05h |= x.fs << (s * 3);
      for (unsigned h = 0; h < kNQ; ++h)
        putBits(dut->dq_cm05h, (s * kNQ + h) * 18, 18, uint64_t(x.sh2) << 17 | uint64_t(x.sh1) << 16 | x.disp);
      putBits(dut->am_cm05h, s * kNL, kNL, x.am);
      putBits(dut->wh_cm05h, s * 32, 32, x.wh);
      putBits(dut->dh_cm05h, s * kNL, kNL, uint64_t(1) << x.dlane);
      putBits(dut->rk_cm05h, s * 61, 61, x.rk);
      for (unsigned l = 0; l < kNL; ++l) {
        putBits(dut->base_cm05h, (s * kNL + l) * 32, 32, x.base[l]);
        putBits(dut->idx_cm05h, (s * kNL + l) * 16, 16, x.idx[l] & 0xffffu);
      }
    }
    dut->ge1_cm05h = ge1;
    dut->ge2_cm05h = ge2;
  }
  // One cycle: valids v (for next cycle's A1), A1 fields a, the gate's
  // flops; the edge; the checks.
  void step(unsigned v, const std::array<Slot, kNS> &a, unsigned ge1, unsigned ge2) {
    dut->v_cm04h = v;
    drive(a, ge1, ge2);
    // The value model, from this cycle's wires.
    bool gate = true;
    for (unsigned b = 0; b < kNB; ++b) {
      const bool u = ctl != "used" && (used >> b & 1u);
      gate = gate && ((u ? ge2 : ge1) >> b & 1u);
    }
    bool any[kNS] = {};
    unsigned lsi[kNS] = {}, lane[kNS] = {}, slot[kNS] = {}, la[kNS] = {}, fm[kNS] = {}, l6[kNS] = {};
    uint64_t rh[kNS] = {};
    for (unsigned k = 0; k < kNS; ++k)
      for (unsigned s = 0; s < kNS; ++s) {
        const Slot &x = a[s];
        if (!(vq >> s & 1u) || !x.ld || !(x.pipes >> k & 1u)) continue;
        const unsigned f = unsigned(__builtin_popcount(x.pipes)), per = kNL / f;
        const unsigned g = unsigned(__builtin_popcount(x.pipes & ((1u << k) - 1u)));
        const uint32_t grp = uint32_t(((uint64_t(1) << per) - 1u) << (g * per)) & x.am;
        if (!grp) continue;
        const unsigned l = ctl == "lowest" ? unsigned(__builtin_ctz(grp)) : g * per;
        const unsigned sc = ctl == "scale" ? 0u : x.sh2 ? 2u : x.sh1 ? 1u : 0u;
        const unsigned sum = ((x.idx[l] << sc) + x.disp) & 0xffffu;
        const bool loc = x.fs >> 1 & 1u, ilv = (x.fs >> 2 & 1u) && x.base[x.dlane] == x.wh;
        any[k] = true;
        lsi[k] = loc ? (x.disp >> 2) & 0x1ffu : ilv ? (sum >> 2) & 0x1ffu : (sum >> 7) & 0x1ffu;
        lane[k] = l;
        slot[k] = s;
        la[k] = x.am >> l & 1u;
        fm[k] = (!loc && ilv) << 1 | loc;
        l6[k] = ((sum >> 11) & 31u) + unsigned(x.rk & 63u);
        const unsigned cx = unsigned(x.rk >> 54) & 0x7fu, l8 = unsigned(x.rk >> 6) & 0xffu;
        const uint64_t h0 = (x.rk >> 14) & 0xfffffu, h1 = (x.rk >> 34) & 0xfffffu;
        auto rr = [&](unsigned t) { return ((t >> 8 ? h1 : h0) & 0x3ffffu) << 8 | (t & 0xffu); };
        rh[k] = rr(l8 + cx + 1) << 26 | rr(l8 + cx);
        cov_c1 += l6[k] >> 6;
        ++cov_f[f];
        cov_sc[sc] += 1;
        cov_skip += !la[k];   // the leader lane inactive, the group not
        if (loc) ++cov_loc;
        else if (ilv) ++cov_ilv;
        else ++cov_ord;
      }
    edge();
    unsigned rv = 0, nused = 0;
    for (unsigned k = 0; k < kNS; ++k)
      if (any[k] && gate) {
        rv |= 1u << k;
        nused |= 1u << (lsi[k] & (kNB - 1));
      }
    for (unsigned k = 0; k < kNS; ++k)
      if (any[k] && !gate) {
        ++cov_hold;
        break;
      }
    cov_used += used != 0 && rv != 0;
    ++checked;
    if (unsigned(dut->rv_cm06h) != rv && ++fails <= 20)
      std::fprintf(stderr, "lead: cycle %llu: rv %x, want %x\n", (unsigned long long)cyc,
                   unsigned(dut->rv_cm06h), rv);
    for (unsigned k = 0; k < kNS; ++k) {
      if (!any[k]) continue;
      ++checked;
      const unsigned gl = unsigned(uint64_t(dut->lsi_cm06h) >> (k * kSW)) & 0x1ffu;
      const unsigned lq = unsigned(uint64_t(dut->lq_cm06h) >> (k * kNS * kNQ)) & 0xffffu;
      const unsigned gla = dut->la_cm06h >> k & 1u, gfm = dut->fm_cm06h >> (2 * k) & 3u;
      const unsigned gl6 = unsigned(dut->l6_cm06h >> (7 * k)) & 0x7fu;
      const uint64_t grh = getBits(dut->rh_cm06h, k * 52, 52);
      if ((gl != lsi[k] || lq != (1u << (slot[k] * kNQ + lane[k] / 8)) || gla != la[k] ||
           gfm != fm[k] || (fm[k] == 2 && gl6 != l6[k]) || (fm[k] == 2 && grh != rh[k])) && ++fails <= 20)
        std::fprintf(stderr, "lead: cycle %llu: slot %u: set %03x lq %04x la %u fm %u l6 %02x, want %03x %u/%u %u %u %02x\n",
                     (unsigned long long)cyc, k, gl, lq, gla, gfm, gl6, lsi[k], slot[k], lane[k], la[k], fm[k], l6[k]);
    }
    vq = v;
    used = nused;
  }
};

struct Gen {
  std::mt19937_64 r;
  explicit Gen(uint64_t seed) : r(seed) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
  uint32_t mask() {
    switch (below(6)) {
      case 0: return ~0u;
      case 1: return 0;
      case 2: return uint32_t(r()) & uint32_t(r()) & uint32_t(r());   // sparse
      case 3: return 1u << below(32);
      default: return uint32_t(r());
    }
  }
  Slot slot(unsigned pipes) {
    Slot x;
    x.ld = below(8) != 0;
    x.pipes = pipes;
    x.am = mask();
    x.fs = below(8);
    x.dlane = below(kNL);
    const unsigned sc = below(3);
    x.sh1 = sc == 1;
    x.sh2 = sc == 2;
    x.disp = below(0x10000);
    for (unsigned l = 0; l < kNL; ++l) {
      x.base[l] = below(4) ? uint32_t(r()) : 0x1234u;
      x.idx[l] = below(0x10000);
    }
    x.wh = below(2) ? x.base[x.dlane] : uint32_t(r());
    x.rk = r() & ((uint64_t(1) << 61) - 1u);
    return x;
  }
  /// Valid slots for the next A1 and their footprints: disjoint, each a
  /// memop's lead pipe its slot.
  unsigned plan(unsigned dens, std::array<unsigned, kNS> &pipes) {
    unsigned v = 0, taken = 0;
    pipes.fill(0);
    for (unsigned s = 0; s < kNS; ++s) {
      if (taken >> s & 1u || below(10) >= dens) continue;
      const unsigned free_above = ~taken & ~((2u << s) - 1u) & 0xfu;
      unsigned p = 1u << s;
      const unsigned pick = below(3);
      if (pick == 2 && s == 0 && taken == 0) p = 0xfu;
      else if (pick >= 1 && free_above) {
        unsigned t;
        do t = below(kNS); while (!(free_above >> t & 1u));
        p |= 1u << t;
      }
      taken |= p;
      pipes[s] = p;
      v |= 1u << s;
    }
    return v;
  }
};

int run(const std::string &scenario, const char *vcd, const std::string &ctl) {
  Bench b(vcd, ctl);
  Gen g(0x1ead);
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 50000 : scenario == "idle" ? 3000 : 4000;
  std::array<Slot, kNS> a{};
  std::array<unsigned, kNS> pipes{}, next{};
  unsigned vnext = 0, ge1 = 0xff, ge2 = 0xff;
  for (unsigned i = 0; i < n; ++i) {
    const unsigned dens = scenario == "idle" ? 0 : scenario == "medium" ? (i % 3 == 0 ? 8 : 0)
                          : scenario == "high" ? 9 : (i / 64) % 2 ? 9 : 3;
    // This cycle's A1 fields: last cycle's plan.
    pipes = next;
    const unsigned vnow = vnext;
    if (vnow || rnd)
      for (unsigned s = 0; s < kNS; ++s)
        if (vnow >> s & 1u) a[s] = g.slot(pipes[s]);
        else if (rnd) a[s] = g.slot(g.below(16));   // noise
    if (rnd || vnow) {
      ge1 = g.below(4) ? 0xffu : uint32_t(g.r()) & 0xffu;
      ge2 = g.below(2) ? ge1 : ge1 & uint32_t(g.r());
    }
    vnext = g.plan(dens, next);
    b.step(vnext, a, ge1, ge2);
  }
  bool cov = true;
  if (rnd) {
    cov = b.cov_f[1] && b.cov_f[2] && b.cov_f[4] && b.cov_hold && b.cov_used && b.cov_ilv &&
          b.cov_loc && b.cov_ord && b.cov_sc[0] && b.cov_sc[1] && b.cov_sc[2] && b.cov_skip && b.cov_c1;
    if (!cov) {
      std::fprintf(stderr,
                   "lead: coverage: F1 %u F2 %u F4 %u, holds %u, used %u, ilv %u local %u ord %u, "
                   "scales %u %u %u, leader inactive %u, l6 carry %u\n",
                   b.cov_f[1], b.cov_f[2], b.cov_f[4], b.cov_hold, b.cov_used, b.cov_ilv, b.cov_loc,
                   b.cov_ord, b.cov_sc[0], b.cov_sc[1], b.cov_sc[2], b.cov_skip, b.cov_c1);
      ++b.fails;
    }
  }
  std::printf("lead%s %s: %llu cycles, %u values checked, %u mismatches: %s\n",
              ctl.empty() ? ":" : (" control " + ctl + ":").c_str(), rnd ? "random" : scenario.c_str(),
              (unsigned long long)b.cyc, b.checked, b.fails, b.fails ? "FAIL" : "PASS");
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
      if (ctl != "used" && ctl != "scale" && ctl != "lowest") {
        std::fprintf(stderr, "lead: unknown control %s\n", ctl.c_str());
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "lead: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
