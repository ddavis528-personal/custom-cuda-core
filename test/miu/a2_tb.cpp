//===-- a2_tb.cpp - miu_a2 bench: the leaders' L0 lookup, PA, drop, no-hit -===//
//
// Drives miu_a2 as its sources do: miu_cap's valids two cycles ahead of A2;
// in A2, per lookup slot, miu_lead's flops (rv, lsi, the leader's (address
// slot, quarter) one-hot lq among the slot's possible leaders, la, the form
// fm, l6 and R(ctx)'s two VPN halves), miu_agu8's per-octet lane 0 sums and
// miu_form's C per address slot, miu_grp's ge, and miu_tlb's L0 entries
// (each slot's 4, a hit planted on about half the lookups). With no memop
// in A2 the A2 fields carry noise in random mode and rv is 0.
//
// The value model is the spec's A2 (MIU tab, "Translation" and "The drop";
// MA rev 199): the leader's VPN by its form (local C[47:16], interleaved
// {l6[6] ? R1 : R0, l6[5:0]}, else S[47:16]), its offset (local C[15:0] |
// lane << 2, interleaved {S[10:2], lane, S[1:0]}, else S[15:0]), the L0's
// AND-OR on the matches; drop = !la | miss | a faulting lane of the memop
// (F-ALIGN; S[49:48] not 0; miu_agu8's window compare we true on an
// ordinary .global lane, false on an interleaved one) | a lower launching
// slot on the same bank | !ge; the miss
// asked of miu_tlb only for a launched lookup with its leader active; the
// no-hit per address slot, any launched lookup it leads dropped. Checks, a
// cycle on: with a memop in A2 every output; without one the payload held
// and the miss and the no-hit clear.
//
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle is reset and no memop, the wires still; medium
// a memop on about a third of the cycles; high nearly every cycle. Controls,
// each must fail: carry (the model's interleaved VPN reads R0 alone), bank
// (the model ignores a lower slot's launch on the same bank), addr (the
// model drops no S[49:48] F-ADDR), win (an ordinary lane in the run's
// windows not caught), iblk (an interleaved lane off W's block not caught),
// align (no F-ALIGN).
//===----------------------------------------------------------------------===//
#include "Vmiu_a2.h"
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

constexpr unsigned kNS = 4, kNQ = 4, kN0 = 6, kVW = 50, kSW = 9, kFW = 4, kBW = 3;
constexpr uint64_t kM50 = (uint64_t(1) << kVW) - 1u;
constexpr uint64_t kLine = (uint64_t(1) << 41) - 1u;   // VA[47:7]

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
template <typename S> void putS(S &w, unsigned o, unsigned n, uint64_t v) {
  const uint64_t m = (n >= 64 ? ~uint64_t(0) : (uint64_t(1) << n) - 1u) << o;
  w = S((uint64_t(w) & ~m) | ((v << o) & m));
}

/// One cycle's A2 inputs.
struct In {
  unsigned rv = 0, la = 0;
  std::array<unsigned, kNS> f{};              // address slot a's memop's F (0: none)
  std::array<uint32_t, kNS> am{};             // its active_mask
  std::array<std::array<uint64_t, 32>, kNS> lv{};   // its lanes' sums
  std::array<unsigned, kNS> lsi{}, fm{}, l6{}, a{}, q{};
  std::array<bool, kNS> lead{};               // lq has a bit
  std::array<uint32_t, kNS> r0{}, r1{};       // 26 bits each
  std::array<uint64_t, kNS * kNQ> va{};
  std::array<uint64_t, kNS> c{};
  std::array<unsigned, kNS> af{};             // its form: 0 ordinary .global, 1 local, 2 interleaved, 3 .shared
  std::array<uint32_t, kNS> fal{};            // its lanes' F-ALIGN (active lanes only)
  std::array<uint32_t, kNS> we{};             // its lanes' S[47:16+k] == W >> k (miu_agu8's)
  std::array<bool, kNS * kN0> l0v{};
  std::array<uint32_t, kNS * kN0> l0vpn{}, l0ppn{}, l0fold{}, l0pm{};
};

struct Out {
  std::array<uint64_t, kNS> pa{};
  std::array<unsigned, kNS> pf{}, pm{};
  std::array<uint32_t, kNS> vpn{};
  unsigned dr = 0, ms = 0, nh = 0;
};

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vmiu_a2> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  std::string ctl;
  unsigned v1 = 0, v2 = 0;   // the valids one and two cycles ago
  Out held;                  // the payload flops' last write
  unsigned cov_hit = 0, cov_miss = 0, cov_fa = 0, cov_bank = 0, cov_c1 = 0, cov_ilv = 0,
           cov_loc = 0, cov_ord = 0, cov_nh = 0, cov_skip = 0, cov_ge = 0, cov_hold = 0,
           cov_al = 0, cov_win = 0, cov_ib = 0;
  std::array<unsigned, 3> cov_gok{}, cov_gdr{};   // the group check passed, failed: F 1, 2, 4

  Bench(const char *vcd_path, const std::string &c) : ctl(c) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    ctx->fatalOnError(false);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vmiu_a2>(ctx.get());
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
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();
    edge();
    edge();
  }
  void drive(const In &x) {
    dut->rv_cm06h = x.rv;
    dut->la_cm06h = x.la;
    dut->lsi_cm06h = 0;
    dut->lq_cm06h = 0;
    dut->fm_cm06h = 0;
    dut->l6_cm06h = 0;
    for (unsigned k = 0; k < kNS; ++k) {
      putS(dut->lsi_cm06h, k * kSW, kSW, x.lsi[k]);
      if (x.lead[k]) putS(dut->lq_cm06h, (k * kNS + x.a[k]) * kNQ + x.q[k], 1, 1);
      putS(dut->fm_cm06h, k * 2, 2, x.fm[k]);
      putS(dut->l6_cm06h, k * 7, 7, x.l6[k]);
      putBits(dut->rh_cm06h, k * 52, 26, x.r0[k]);
      putBits(dut->rh_cm06h, k * 52 + 26, 26, x.r1[k]);
      putBits(dut->c_cm06h, k * kVW, kVW, x.c[k]);
    }
    for (unsigned i = 0; i < kNS * kNQ; ++i) putBits(dut->va_cm06h, i * kVW, kVW, x.va[i]);
    dut->ilv_cm06h = 0;
    dut->ow_cm06h = 0;
    for (unsigned a = 0; a < kNS; ++a) {
      putBits(dut->fal_cm06h, a * 32, 32, x.fal[a]);
      putBits(dut->we_cm06h, a * 32, 32, x.we[a]);
      for (unsigned u = 0; u < kNQ; ++u) {
        putS(dut->ilv_cm06h, a * kNQ + u, 1, x.af[a] == 2);
        putS(dut->ow_cm06h, a * kNQ + u, 1, x.af[a] == 0);
      }
      putBits(dut->am_cm06h, a * 32, 32, x.am[a]);
      for (unsigned l = 0; l < 32; ++l) putBits(dut->lv_cm06h, (a * 32 + l) * kVW, kVW, x.lv[a][l]);
      // miu_agu8's keep copies: lanes 0's and 16's lines.
      putBits(dut->lc_cm06h, a * 82, 41, x.lv[a][0] >> 7);
      putBits(dut->lc_cm06h, a * 82 + 41, 41, x.lv[a][16] >> 7);
    }
    dut->l0v_cm11h = 0;
    dut->l0pm_cm11h = 0;
    for (unsigned i = 0; i < kNS * kN0; ++i) {
      putS(dut->l0v_cm11h, i, 1, x.l0v[i]);
      putBits(dut->l0vpn_cm11h, i * 32, 32, x.l0vpn[i]);
      putBits(dut->l0ppn_cm11h, i * 32, 32, x.l0ppn[i]);
      putBits(dut->l0fold_cm11h, i * kFW, kFW, x.l0fold[i]);
      putS(dut->l0pm_cm11h, i, 1, x.l0pm[i]);
    }
  }
  /// The leader's VPN under x's fields (the model's, used to plant hits).
  uint32_t vpnOf(const In &x, unsigned k, bool use_ctl) const {
    const uint64_t s = x.lead[k] ? x.va[x.a[k] * kNQ + x.q[k]] : 0, c = x.lead[k] ? x.c[x.a[k]] : 0;
    const bool il = x.fm[k] >> 1 & 1u, lc = x.fm[k] & 1u;
    const bool hi = (x.l6[k] >> 6 & 1u) && !(use_ctl && ctl == "carry");
    return lc ? uint32_t(c >> 16) : il ? ((hi ? x.r1[k] : x.r0[k]) << 6 | (x.l6[k] & 63u)) : uint32_t(s >> 16);
  }
  /// Address slot a's group and page check (MA rev 203, drop_line and
  /// drop_split): F groups of 32/F lanes, each led by its first lane; an
  /// active lane off its leader's line, or two active groups' leaders in
  /// different pages, fails it. Controls: line (no line check), split (no
  /// page check), fone (F taken as 1).
  bool grpOk(const In &x, unsigned a) {
    const unsigned f = ctl == "fone" ? 1u : x.f[a], gs = 32u / f;
    bool ok = true;
    uint64_t pg0 = 0;
    bool any = false;
    for (unsigned g = 0; g < f; ++g) {
      const unsigned gl = g * gs;
      bool act = false;
      for (unsigned l = gl; l < gl + gs; ++l) {
        if (!(x.am[a] >> l & 1u)) continue;
        act = true;
        if (ctl != "line" && (x.lv[a][l] >> 7 & kLine) != (x.lv[a][gl] >> 7 & kLine)) ok = false;
      }
      const uint64_t pg = x.lv[a][gl] >> 16 & 0xffffffffu;   // VA[47:16]
      if (act && ctl != "split") {
        if (any && pg != pg0) ok = false;
        if (!any) pg0 = pg;
        any = true;
      }
    }
    return ok;
  }
  /// Address slot a's lanes' faults: F-ALIGN; F-ADDR, an ordinary .global or
  /// interleaved lane's S[49:48] not 0; the window check on miu_agu8's
  /// compare we: an ordinary lane in the run's windows, an interleaved
  /// lane's b outside [0, L). Controls: align, addr, win (the
  /// ordinary lane in the windows), iblk (the interleaved lane off its block). f: 1 align, 2 addr, 4 window, 8 interleaved.
  unsigned faults(const In &x, unsigned a) const {
    unsigned f = 0;
    const bool iv = x.af[a] == 2, ov = x.af[a] == 0;
    for (unsigned l = 0; l < 32; ++l) {
      if (!(x.am[a] >> l & 1u)) continue;
      const uint64_t v = x.lv[a][l];
      const bool hi = (v >> 48) != 0, eq = x.we[a] >> l & 1u;
      if (ctl != "align" && (x.fal[a] >> l & 1u)) f |= 1;
      if (ctl != "addr" && hi && (iv || ov)) f |= 2;
      if (ctl != "win" && ov && eq && !hi) f |= 4;
      if (ctl != "iblk" && iv && !eq && !hi) f |= 8;
    }
    return f;
  }
  Out model(const In &x) {
    Out o;
    std::array<bool, kNS> gok{};
    std::array<unsigned, kNS> ft{};
    for (unsigned a = 0; a < kNS; ++a) gok[a] = x.f[a] != 0 && grpOk(x, a), ft[a] = faults(x, a);
    for (unsigned k = 0; k < kNS; ++k) {
      const uint64_t s = x.lead[k] ? x.va[x.a[k] * kNQ + x.q[k]] : 0, c = x.lead[k] ? x.c[x.a[k]] : 0;
      const unsigned ln = x.lead[k] ? 8u * x.q[k] : 0u;
      const bool il = x.fm[k] >> 1 & 1u, lc = x.fm[k] & 1u;
      const uint32_t vpn = vpnOf(x, k, true);
      const uint64_t off = lc ? ((c & 0xffffu) | (ln << 2))
                         : il ? (((s >> 2) & 0x1ffu) << 7 | ln << 2 | (s & 3u))
                              : (s & 0xffffu);
      bool hit = false;
      uint32_t ppn = 0, fo = 0, pg = 0;
      for (unsigned e = 0; e < kN0; ++e) {
        const unsigned i = k * kN0 + e;
        if (!x.l0v[i] || x.l0vpn[i] != vpn) continue;
        hit = true;
        ppn |= x.l0ppn[i];
        fo |= x.l0fold[i];
        pg |= x.l0pm[i];
      }
      const unsigned fk = x.lead[k] ? ft[x.a[k]] : 0u;
      const bool fa = fk != 0;
      bool bl = false;
      if (ctl != "bank")
        for (unsigned j = 0; j < k; ++j)
          bl = bl || ((x.rv >> j & 1u) && (x.lsi[j] & 7u) == (x.lsi[k] & 7u));
      const bool la = x.la >> k & 1u, ge = x.lead[k] && gok[x.a[k]], rv = x.rv >> k & 1u;
      const bool dr = !la || !hit || fa || bl || !ge;
      o.pa[k] = uint64_t(ppn) << 16 | off;
      o.pf[k] = fo;
      o.pm[k] = pg;
      o.vpn[k] = vpn;
      o.dr |= unsigned(dr) << k;
      o.ms |= unsigned(rv && la && !hit) << k;
      if (rv && dr && x.lead[k]) o.nh |= 1u << x.a[k];
      if (rv) {
        cov_hit += hit && !dr;
        cov_miss += la && !hit;
        if (la && hit) {
          cov_fa += fk == 2;
          cov_al += fk == 1;
          cov_win += fk == 4;
          cov_ib += fk == 8;
        }
        cov_bank += bl && la && hit && !fa;
        cov_c1 += il && (x.l6[k] >> 6 & 1u) && x.r0[k] != x.r1[k];
        cov_ilv += il && !lc;
        cov_loc += lc;
        cov_ord += !lc && !il;
        cov_skip += !la;
        cov_ge += !ge && la && hit;
        if (x.lead[k] && la && hit) {
          const unsigned f = x.f[x.a[k]];
          (ge ? cov_gok : cov_gdr)[f == 4 ? 2 : f == 2 ? 1 : 0]++;
        }
      }
    }
    cov_nh += o.nh != 0;
    return o;
  }
  /// One cycle: valids v (for A2 two cycles on), A2's inputs x; the edge; the checks.
  void step(unsigned v, const In &x) {
    dut->v_cm04h = v;
    drive(x);
    const bool pay = v2 != 0;
    Out want;
    if (pay) {
      want = model(x);
      held = want;
    } else {
      want = held;
      want.ms = 0;
      want.nh = 0;
      ++cov_hold;
    }
    edge();
    Out got;
    for (unsigned k = 0; k < kNS; ++k) {
      got.pa[k] = getBits(dut->pa_cm07h, k * 48, 48);
      got.pf[k] = unsigned(dut->pf_cm07h >> (k * kFW)) & 15u;
      got.pm[k] = unsigned(dut->pm_cm07h >> k) & 1u;
      got.vpn[k] = uint32_t(getBits(dut->vpn_cm07h, k * 32, 32));
    }
    got.dr = dut->dr_cm07h;
    got.ms = dut->ms_cm07h;
    got.nh = dut->nh_cm07h;
    ++checked;
    if ((got.dr != want.dr || got.ms != want.ms || got.nh != want.nh) && ++fails <= 20)
      std::fprintf(stderr, "a2: cycle %llu: dr %x ms %x nh %x, want %x %x %x\n", (unsigned long long)cyc,
                   got.dr, got.ms, got.nh, want.dr, want.ms, want.nh);
    for (unsigned k = 0; k < kNS; ++k) {
      ++checked;
      if ((got.pa[k] != want.pa[k] || got.pf[k] != want.pf[k] || got.pm[k] != want.pm[k] ||
           got.vpn[k] != want.vpn[k]) && ++fails <= 20)
        std::fprintf(stderr, "a2: cycle %llu: slot %u: pa %012llx pf %x pm %u vpn %08x, want %012llx %x %u %08x\n",
                     (unsigned long long)cyc, k, (unsigned long long)got.pa[k], got.pf[k], got.pm[k],
                     got.vpn[k], (unsigned long long)want.pa[k], want.pf[k], want.pm[k], want.vpn[k]);
    }
    v2 = v1;
    v1 = v;
  }
};

struct Gen {
  std::mt19937_64 r;
  explicit Gen(uint64_t seed) : r(seed) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
  /// The memops' pipes, as miu_lead assigns them: slot 0's F = 4
  /// owns every pipe, quarter k on pipe k; else each slot s may own pipe s
  /// (quarter 0) and, at F = 2, a free pipe above it (quarter 2).
  void leaders(In &x) {
    if (below(6) == 0) {
      x.f[0] = 4;
      for (unsigned k = 0; k < kNS; ++k) x.lead[k] = true, x.a[k] = 0, x.q[k] = k;
      return;
    }
    for (unsigned s = 0; s < kNS; ++s) {
      if (x.lead[s] || below(8) == 0) continue;
      x.lead[s] = true, x.a[s] = s, x.q[s] = 0, x.f[s] = 1;
      unsigned up[kNS], n = 0;
      for (unsigned k = s + 1; k < kNS; ++k)
        if (!x.lead[k]) up[n++] = k;
      if (n && below(2)) {
        const unsigned k = up[below(n)];
        x.lead[k] = true, x.a[k] = s, x.q[k] = 2, x.f[s] = 2;
      }
    }
  }
  /// Slot a's lanes: each on its group leader's line, low bits random, the
  /// leaders (its octets' lane 0, va's) on one page; now and then a lane or
  /// a leader off it, and sparse masks.
  void lanes(In &x, unsigned a) {
    const unsigned f = x.f[a], gs = 32u / f;
    const uint64_t pm = ~uint64_t(0) << 16, lm = ~uint64_t(0) << 7;
    const uint64_t pg0 = x.va[a * kNQ] & pm;
    for (unsigned g = 1; g < f; ++g) {   // the other leaders, on lane 0's page mostly
      uint64_t &v = x.va[a * kNQ + g * gs / 8];
      if (below(6)) v = (v & ~(pm & ((uint64_t(1) << 48) - 1u))) | (pg0 & ((uint64_t(1) << 48) - 1u));
    }
    for (unsigned u = 0; u < kNQ; ++u) {   // the octets' lane 0 that lead nothing
      const unsigned gl = (u * 8) & ~(gs - 1u);
      if (gl != u * 8) {
        uint64_t &v = x.va[a * kNQ + u];
        v = (x.va[a * kNQ + gl / 8] & lm) | (v & ~lm);
        if (below(64) == 0) v ^= uint64_t(1) << (7 + below(43));
      }
    }
    for (unsigned l = 0; l < 32; ++l) {
      if (l % 8 == 0) {
        x.lv[a][l] = x.va[a * kNQ + l / 8];
        continue;
      }
      const unsigned gl = l & ~(gs - 1u);
      uint64_t v = (x.va[a * kNQ + gl / 8] & lm) | (r() & ~lm & kM50);
      if (below(256) == 0) v ^= uint64_t(1) << (7 + below(43));
      x.lv[a][l] = v & kM50;
    }
    const unsigned m = below(8);
    x.am[a] = m == 0 ? uint32_t(r()) : m == 1 ? uint32_t(r()) & uint32_t(r()) & uint32_t(r()) : ~0u;
  }
  /// A2's inputs; with live, rv only on slots with a leader.
  void fill(In &x, const Bench &b, bool live) {
    x = In{};
    for (unsigned i = 0; i < kNS * kNQ; ++i) {
      x.va[i] = r() & kM50;
      if (below(6)) x.va[i] &= (uint64_t(1) << 48) - 1u;   // F-ADDR now and then
    }
    leaders(x);
    for (unsigned a = 0; a < kNS; ++a) {
      x.af[a] = below(4);
      // In the run's windows: most interleaved memops' lanes, few ordinary
      // ones'; now and then one lane the other way.
      const bool in = below(8) < (x.af[a] == 2 ? 6u : 1u);
      x.we[a] = in ? ~0u : 0u;
      if (below(4) == 0) x.we[a] ^= 1u << below(32);
    }
    for (unsigned a = 0; a < kNS; ++a)
      if (x.f[a]) lanes(x, a);
    for (unsigned k = 0; k < kNS; ++k) {
      x.c[k] = r() & ((uint64_t(1) << 48) - 1u);
      x.lsi[k] = below(1u << kSW);
      // The form miu_lead flops for its leader: its memop's ({il, lc}).
      x.fm[k] = !x.lead[k] ? below(3) : x.af[x.a[k]] == 1 ? 1u : x.af[x.a[k]] == 2 ? 2u : 0u;
      x.l6[k] = below(128);
      x.r0[k] = uint32_t(r()) & 0x3ffffffu;
      x.r1[k] = below(4) ? (x.r0[k] + 1u) & 0x3ffffffu : uint32_t(r()) & 0x3ffffffu;
      if (live && x.lead[k] && below(8)) x.rv |= 1u << k;
      if (below(8)) x.la |= 1u << k;
      if (x.lead[k]) {
        const uint32_t b = 1u << (8 * x.q[k]);
        x.am[x.a[k]] = (x.la >> k & 1u) ? x.am[x.a[k]] | b : x.am[x.a[k]] & ~b;
      }
      for (unsigned e = 0; e < kN0; ++e) {
        const unsigned i = k * kN0 + e;
        x.l0v[i] = below(4) != 0;
        x.l0vpn[i] = uint32_t(r());
        x.l0ppn[i] = uint32_t(r());
        x.l0fold[i] = below(16);
        x.l0pm[i] = below(2);
      }
      // A hit on about half the lookups: one entry holds the leader's VPN.
      if (x.lead[k] && below(2)) {
        const unsigned i = k * kN0 + below(kN0);
        x.l0v[i] = true;
        x.l0vpn[i] = b.vpnOf(x, k, false);
      }
    }
    for (unsigned a = 0; a < kNS; ++a)   // F-ALIGN on an active lane now and then
      x.fal[a] = below(8) == 0 ? x.am[a] & (1u << below(32)) : 0u;
  }
};

int run(const std::string &scenario, const char *vcd, const std::string &ctl) {
  Bench b(vcd, ctl);
  Gen g(0xa2a2);
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 60000 : scenario == "idle" ? 3000 : 4000;
  In x{};
  for (unsigned i = 0; i < n; ++i) {
    const unsigned dens = scenario == "idle" ? 0 : scenario == "medium" ? (i % 3 == 0 ? 8 : 0)
                          : scenario == "high" ? 9 : (i / 64) % 2 ? 9 : 3;
    unsigned v = 0;
    for (unsigned s = 0; s < kNS; ++s)
      if (g.below(10) < dens) v |= 1u << s;
    const bool live = b.v2 != 0;
    if (live || rnd) g.fill(x, b, live);
    else x.rv = 0;
    b.step(v, x);
  }
  bool cov = true;
  if (rnd) {
    cov = b.cov_hit && b.cov_miss && b.cov_fa && b.cov_bank && b.cov_c1 && b.cov_ilv && b.cov_loc &&
          b.cov_ord && b.cov_nh && b.cov_skip && b.cov_ge && b.cov_hold && b.cov_al && b.cov_win &&
          b.cov_ib;
    for (unsigned i = 0; i < 3; ++i) cov = cov && b.cov_gok[i] && b.cov_gdr[i];
    if (!cov) {
      std::fprintf(stderr,
                   "a2: coverage: hit %u miss %u faddr %u bank %u carry %u ilv %u local %u ord %u "
                   "no-hit %u inactive %u ge %u hold %u\n",
                   b.cov_hit, b.cov_miss, b.cov_fa, b.cov_bank, b.cov_c1, b.cov_ilv, b.cov_loc, b.cov_ord,
                   b.cov_nh, b.cov_skip, b.cov_ge, b.cov_hold);
      std::fprintf(stderr, "a2: coverage: faults align %u window %u interleaved %u\n", b.cov_al,
                   b.cov_win, b.cov_ib);
      std::fprintf(stderr, "a2: coverage: group ok F1 %u F2 %u F4 %u, dropped %u %u %u\n", b.cov_gok[0],
                   b.cov_gok[1], b.cov_gok[2], b.cov_gdr[0], b.cov_gdr[1], b.cov_gdr[2]);
      ++b.fails;
    }
  }
  std::printf("a2%s %s: %llu cycles, %u values checked, %u mismatches: %s\n",
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
      if (ctl != "carry" && ctl != "bank" && ctl != "addr" && ctl != "line" && ctl != "split" &&
          ctl != "fone" && ctl != "win" && ctl != "iblk" && ctl != "align") {
        std::fprintf(stderr, "a2: unknown control %s\n", ctl.c_str());
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "a2: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
