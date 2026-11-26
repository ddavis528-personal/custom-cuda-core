//===-- form_tb.cpp - miu_form bench: the address forms' state and reads -----===//
//
// Drives miu_form as its neighbours will: ccv_rau_miu_cta's capture (a
// CTA's local_base into its slot), window fills (a launch-block line's
// windows), and miu_pair's pairing (the enable a cycle before H-1, then
// each slot's entry) over a random miu_mq A1 view and issue masks, which
// change every cycle (noise the module must take only at a pairing).
// Checks, every cycle, the H flops against a value model of the MIU
// model's forms (sim/miu/miu_block.cpp, the AGU): the launch slot's window
// and its valid bit (O-45), the form selects with O-83's eligibility, W >> k,
// R(ctx) as the model forms it, ((base << 16) + (ctx << S)) split at the
// narrow sum's width with R_hi + 1 beside it (O-69 for the local form, O-83
// otherwise; MI-23 (b)): the CTA's region bits split for R(ctx)'s
// carry-select, {hi + 1, hi, lo8, bl}, and ctx, and lane d's one-hot.
// local_base is drawn unaligned and near carries, so ctx's add would carry
// into hi.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle is reset and nothing; medium a pairing on about
// a third of the cycles; high one nearly every cycle; CTA writes and fills
// now and then in both.
// Controls, each of which must fail: lane0 models lane d as lane 0 (the
// model's priv-lane0); nohi1 models hi + 1 as hi, the carry out of ctx's
// add dropped; noctx models ctx as 0
// (the model's priv-no-ctx and local-no-ctx).
//===----------------------------------------------------------------------===//
#include "Vmiu_form.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>

namespace {

// The unit's sizes: ccv_params_pkg's defaults.
constexpr unsigned kNS = 4, kNE = 40, kFW = 63, kIW = 32, kNC = 8, kNWN = 16;
constexpr unsigned kCXW = 7, kCore = 0, kWIW = 5;
constexpr uint64_t kLC = 4096, kPW = 1;
constexpr unsigned kPK = 0, kNN = 22, kVW = 50, kRHW = kVW - kNN, kWHW = 32 - kPK;
constexpr unsigned kEW = 6, kBL = kNN - 16, kHH = kRHW - 8, kRK = kCXW + 2 * kHH + 8 + kBL;
// The A1 view's fields, LSB first (miu_pair's decode).
constexpr unsigned kLF = 3, kAS = 4, kSF = 8, kSP = 14, kCS = kFW - kWIW - 3, kWI = kFW - kWIW;

enum class Ctl { none, lane0, nohi1, noctx, cflat };
unsigned g_cov_cb = 0, g_cov_ch = 0;   // C's carries, counted by the model

template <class W> void setBits(W *w, unsigned at, unsigned n, uint64_t v) {
  for (unsigned i = 0; i < n; ++i) {
    const unsigned p = at + i;
    const uint32_t m = 1u << (p % 32);
    if (v >> i & 1u) w[p / 32] |= m;
    else w[p / 32] &= ~m;
  }
}
template <class W> uint64_t getBits(const W *w, unsigned at, unsigned n) {
  uint64_t v = 0;
  for (unsigned i = 0; i < n; ++i) {
    const unsigned p = at + i;
    v |= uint64_t(w[p / 32] >> (p % 32) & 1u) << i;
  }
  return v;
}
uint64_t bitsOf(uint64_t v, unsigned at, unsigned n) { return (v >> at) & ((1ull << n) - 1); }

struct Cta {
  uint64_t lbase = 0;
  bool set = false;
};
struct Table {
  Cta cta[kNC];
  uint32_t w[kNC][kNWN] = {};
  uint16_t v[kNC] = {};
};
struct Entry {
  unsigned cta = 0, warp = 0, as = 0;
  bool sf = false, lf = false, shared = false;
  uint32_t im = 0;
  uint64_t raw = 0;   // the FW bits
};
struct Want {
  uint32_t win[kNS] = {};
  uint32_t wv = 0, fs[kNS] = {}, wh[kNS] = {}, dh[kNS] = {};
  uint64_t rk[kNS] = {};   // {ctx, hi + 1, hi, lo8, bl}
  uint64_t c[kNS] = {};    // O-69's C
};

Want model(const Table &t, const Entry *e, Ctl ctl) {
  Want w;
  for (unsigned k = 0; k < kNS; ++k) {
    const Entry &x = e[k];
    const Cta &c = t.cta[x.cta];
    w.win[k] = t.w[x.cta][x.as];
    w.wv |= (t.v[x.cta] >> x.as & 1u) << k;
    const uint64_t W = c.lbase + 3 * kLC;
    const bool elig = !x.shared && !x.sf && !x.lf && (W >> 32) == 0;
    w.fs[k] = (elig << 2) | (x.lf << 1) | x.sf;
    w.wh[k] = uint32_t(bitsOf(W, kPK, kWHW));
    const uint64_t ctx = ctl == Ctl::noctx ? 0 : (uint64_t(kCore) << kWIW) | x.warp;
    const uint64_t base = x.lf ? c.lbase + kLC : W + kPW;
    // The region's bits, split at the narrow sum: bl below it, then lo8,
    // then hi and hi + 1 (MI-23 (b)).
    const uint64_t bl = bitsOf(base, 0, kBL), bh = base >> kBL;
    const uint64_t lo8 = bitsOf(bh, 0, 8), hi = bitsOf(bh, 8, kHH);
    const uint64_t hi1 = ctl == Ctl::nohi1 ? hi : bitsOf(hi + 1, 0, kHH);
    w.rk[k] = bl | lo8 << kBL | hi << (kBL + 8) | hi1 << (kBL + 8 + kHH) |
              ctx << (kBL + 8 + 2 * kHH);
    w.dh[k] = ctl == Ctl::lane0 ? 1u : x.im & (~x.im + 1);
    // O-69's address less the lane (MI-25 (D)): b the disp's 17 low bits,
    // unsigned (MA rev 195), the local region whatever the form. cflat: b
    // added as it is, not rearranged around the lane's bits [6:2].
    const uint64_t b = bitsOf(x.raw, kSP + 2, 17);
    const uint64_t cx = ctl == Ctl::noctx ? 0 : (uint64_t(kCore) << kWIW) | x.warp;
    const uint64_t rb = ctl == Ctl::cflat ? b : 128 * (b / 4) + b % 4;
    w.c[k] = bitsOf(((c.lbase + kLC) << 16) + (cx << 22) + rb, 0, kVW);
    // Coverage: b's carry out of bits [21:0] reaching lo8 + ctx, and that
    // sum's carry picking hi + 1.
    const uint64_t L = (c.lbase + kLC) << 16;
    g_cov_cb += c.set && ((L & 0x3fffff) + rb) >> 22;
    g_cov_ch += c.set && ((L + (cx << 22) + rb) >> 30) != ((L + (cx << 22)) >> 30) &&
                ((L + rb) >> 30) == (L >> 30);
  }
  return w;
}

int g_argc;
char **g_argv;

struct Gen {
  std::mt19937_64 r;
  explicit Gen(uint64_t seed) : r(seed) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
  uint64_t lbase() {
    // Unaligned, near the carries of ctx's add and of hi + 1, below 2^33
    // windows for both regions; now and then W past 2^32 (no eligibility).
    switch (below(6)) {
      case 0: return (uint64_t(1) << 32) - 3 * kLC + below(8);         // W at 2^32
      case 1: return (0xfffull << 20) - kLC - below(4);                 // lo8 near full
      case 2: return uint64_t(r()) & 0xffffff;
      case 3: return ((uint64_t(r()) & 0x3ff) << 22) - kLC + (r() & 0x3f);
      default: return uint64_t(r()) & 0xfffffffull;
    }
  }
  uint32_t mask() {
    switch (below(5)) {
      case 0: return 0xffffffffu;
      case 1: return 1u << below(32);
      case 2: return 0;
      default: return uint32_t(r());
    }
  }
};

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vmiu_form> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  unsigned cov_slot_v = 0, cov_slot_inv = 0, cov_local = 0, cov_elig = 0, cov_far = 0,
           cov_carry = 0, cov_noise = 0, cov_b2b = 0;
  Ctl ctl;
  Table tab;
  Entry ent[kNE];
  bool known = false, pnew = false;
  bool cknown = false;
  uint64_t cwant[kNS] = {}, cnext[kNS] = {};
  struct CtW {
    bool v = false;
    unsigned c = 0;
    uint64_t lb = 0;
  } ct[3];
  struct FlW {
    bool v = false;
    unsigned c = 0;
    uint16_t m = 0;
    uint32_t w[kNWN] = {};
  } fl[3];
  int force_cta = -1;
  Want want{};

  Bench(const char *vcd_path, Ctl c) : ctl(c) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vmiu_form>(ctx.get());
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
  void quiet() {
    dut->ctv_cm01h = 0;
    dut->fv_cm01h = 0;
    dut->pen_cm03h = 0;
  }
  void reset() {
    dut->rst_n = 0;
    quiet();
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();
  }
  void putEntry(unsigned e, const Entry &x) {
    ent[e] = x;
    setBits(dut->mqa_cm02h.data(), e * kFW, kFW, x.raw);
    setBits(dut->mqi_cm02h.data(), e * kIW, kIW, x.im);
  }
  Entry randEntry(Gen &g) {
    Entry x;
    x.raw = g.r() & ((1ull << kFW) - 1);
    x.cta = unsigned(bitsOf(x.raw, kCS, 3));
    x.warp = unsigned(bitsOf(x.raw, kWI, kWIW));
    x.as = unsigned(bitsOf(x.raw, kAS, 4));
    // Forms: slot, local or neither, never both (OOE's decode).
    const unsigned f = g.below(4);
    x.sf = f == 0;
    x.lf = f == 1;
    x.raw &= ~((1ull << kSF) | (1ull << kLF));
    x.raw |= uint64_t(x.sf) << kSF | uint64_t(x.lf) << kLF;
    x.shared = bitsOf(x.raw, kSP, 1);
    x.im = g.mask();
    return x;
  }
  // One cycle. pen: a pairing's enable now; pe: the slots' entries, read at
  // H-1 (meaningful the cycle after pen); the table writes on the wires.
  void step(Gen &g, bool pen, const unsigned *pe, bool noise, bool ctw, bool fil) {
    // The A1 view: noise in random mode; the entries stay put otherwise.
    if (noise)
      for (unsigned e = 0; e < kNE; ++e)
        if (g.below(4) == 0) putEntry(e, randEntry(g));
    dut->pen_cm03h = pen;
    for (unsigned k = 0; k < kNS; ++k) setBits(&dut->pe_cm04h, k * kEW, kEW, pe[k]);
    // Table writes: each valid on the wire, its fields a cycle on (the
    // fill's words a cycle later still), applied at the edge two cycles on.
    ct[2] = ct[1];
    ct[1] = ct[0];
    ct[0] = CtW{};
    fl[2] = fl[1];
    fl[1] = fl[0];
    fl[0] = FlW{};
    if (ctw) {
      ct[0].v = true;
      ct[0].c = force_cta >= 0 ? unsigned(force_cta) : g.below(kNC);
      ct[0].lb = g.lbase();
    }
    if (fil) {
      fl[0].v = true;
      fl[0].c = g.below(kNC);
      fl[0].m = g.below(2) ? 0x0fff : 0xf000;   // a line holds slots 0-11 or 12-15
      for (unsigned j = 0; j < kNWN; ++j) fl[0].w[j] = uint32_t(g.r());
    }
    dut->ctv_cm01h = ct[0].v;
    if (ct[1].v) {
      dut->ctc_cm02h = ct[1].c;
      dut->ctl_cm02h = ct[1].lb;
    } else if (noise) {
      dut->ctc_cm02h = g.below(kNC);
      dut->ctl_cm02h = g.r() & ((1ull << 48) - 1);
    }
    dut->fv_cm01h = fl[0].v;
    if (fl[1].v) {
      dut->fc_cm02h = fl[1].c;
      dut->fm_cm02h = fl[1].m;
    } else if (noise) {
      dut->fc_cm02h = g.below(kNC);
      dut->fm_cm02h = g.below(1u << 16);
    }
    if (fl[2].v)
      for (unsigned j = 0; j < kNWN; ++j) dut->fw_cm03h[j] = fl[2].w[j];
    else if (noise)
      for (unsigned j = 0; j < kNWN; ++j) dut->fw_cm03h[j] = uint32_t(g.r());
    // What H captures at this edge, if pnew: the table before the edge.
    Entry e[kNS];
    for (unsigned k = 0; k < kNS; ++k) e[k] = ent[pe[k]];
    if (pnew) {
      want = model(tab, e, ctl);
      known = true;
      cov_b2b += pen;
      const Want w0 = model(tab, e, Ctl::none);
      for (unsigned k = 0; k < kNS; ++k) {
        if (e[k].sf) (w0.wv >> k & 1u ? cov_slot_v : cov_slot_inv) += 1;
        cov_local += e[k].lf && tab.cta[e[k].cta].set;
        cov_elig += (w0.fs[k] >> 2) & 1u;
        cov_far += !e[k].shared && !e[k].sf && !e[k].lf && !(w0.fs[k] >> 2 & 1u);
        // ctx's add carried into hi.
        const Cta &c = tab.cta[e[k].cta];
        const uint64_t base = e[k].lf ? c.lbase + kLC : c.lbase + 3 * kLC + kPW;
        const uint64_t ctxv = (uint64_t(kCore) << kWIW) | e[k].warp;
        const uint64_t R = (base << 16) + (ctxv << (e[k].lf ? 22 : 21 + kPK));
        cov_carry += c.set && (R >> kNN >> 8) != ((base << 16) >> kNN >> 8);
      }
    } else if (known) {
      ++cov_noise;
    }
    edge();
    // The table after the edge.
    if (ct[2].v) {
      tab.cta[ct[2].c].lbase = ct[2].lb;
      tab.cta[ct[2].c].set = true;
      tab.v[ct[2].c] = 0;
    }
    if (fl[2].v) {
      tab.v[fl[2].c] |= fl[2].m;
      for (unsigned j = 0; j < kNWN; ++j)
        if (fl[2].m >> j & 1u) tab.w[fl[2].c][j] = fl[2].w[j];
    }
    pnew = pen;
    // C is a stage later (A2): the last known cycle's want, now.
    const bool ck = cknown;
    cknown = known;
    for (unsigned k = 0; k < kNS; ++k) { cwant[k] = cnext[k]; cnext[k] = want.c[k]; }
    if (!known && !ck) return;
    bool ok = true;
    auto chk = [&](const char *what, unsigned k, uint64_t got, uint64_t exp) {
      if (got == exp) return;
      ok = false;
      if (fails < 20)
        std::fprintf(stderr, "form: cycle %llu: slot %u %s %llx, want %llx\n",
                     (unsigned long long)cyc, k, what, (unsigned long long)got,
                     (unsigned long long)exp);
    };
    if (ck)
      for (unsigned k = 0; k < kNS; ++k)
        chk("c", k, getBits(dut->c_cm06h.data(), k * kVW, kVW), cwant[k]);
    if (!known) { if (!ok) ++fails; return; }
    ++checked;
    for (unsigned k = 0; k < kNS; ++k) {
      for (unsigned u = 0; u < 4; ++u) {   // each octet's copy
        chk("win", k, dut->win_cm05h[k * 4 + u], want.win[k]);
        chk("sl", k, dut->sl_cm05h >> (k * 4 + u) & 1u, want.fs[k] & 1u);
      }
      chk("wv", k, dut->wv_cm05h >> k & 1u, want.wv >> k & 1u);
      chk("fs", k, dut->fs_cm05h >> (3 * k) & 7u, want.fs[k]);
      chk("wh", k, getBits(dut->wh_cm05h.data(), k * kWHW, kWHW), want.wh[k]);
      chk("rk", k, getBits(dut->rk_cm05h.data(), k * kRK, kRK), want.rk[k]);
      chk("dh", k, dut->dh_cm05h[k], want.dh[k]);
    }
    if (!ok) ++fails;
  }
};

int run(const std::string &scenario, const char *vcd, Ctl ctl) {
  Bench b(vcd, ctl);
  Gen g(0xf04);
  b.reset();
  const bool rnd = scenario.empty();
  // Every CTA slot set first, as RAU dispatches before any memop.
  for (unsigned i = 0; i < kNE; ++i) b.putEntry(i, b.randEntry(g));
  unsigned pe[kNS] = {};
  for (unsigned c = 0; c < kNC + 2 && scenario != "idle"; ++c) {
    b.force_cta = int(c);
    b.step(g, false, pe, false, c < kNC, false);
  }
  b.force_cta = -1;
  b.quiet();
  const unsigned n = rnd ? 60000 : scenario == "idle" ? 3000 : 4000;
  for (unsigned i = 0; i < n; ++i) {
    const bool pen = scenario == "idle"     ? false
                     : scenario == "medium" ? (i % 3 == 0 && g.below(10) < 8)
                     : scenario == "high"   ? g.below(10) < 9
                                            : (i / 64) % 2 ? g.below(10) < 9 : g.below(4) == 0;
    const bool act = scenario != "idle";
    const bool ctw = act && g.below(rnd ? 40 : 200) == 0;
    const bool fil = act && g.below(rnd ? 6 : 40) == 0;
    // The entries a pairing reads, the cycle after its enable.
    if (b.pnew || rnd)
      for (unsigned k = 0; k < kNS; ++k) pe[k] = g.below(kNE);
    b.step(g, pen, pe, rnd, ctw, fil);
  }
  if (rnd && (!b.cov_slot_v || !b.cov_slot_inv || !b.cov_local || !b.cov_elig || !b.cov_far ||
              !b.cov_carry || !b.cov_noise || !b.cov_b2b || !g_cov_cb || !g_cov_ch)) {
    std::fprintf(stderr,
                 "form: coverage: slot valid %u, slot invalid %u, local %u, eligible %u, "
                 "W past 2^32 %u, ctx carry %u, noise %u, back to back %u, C carry to ctx %u, "
                 "C carry to hi %u\n",
                 b.cov_slot_v, b.cov_slot_inv, b.cov_local, b.cov_elig, b.cov_far, b.cov_carry,
                 b.cov_noise, b.cov_b2b, g_cov_cb, g_cov_ch);
    ++b.fails;
  }
  const char *cn = ctl == Ctl::lane0    ? " control lane0:"
                   : ctl == Ctl::nohi1 ? " control nohi1:"
                   : ctl == Ctl::noctx  ? " control noctx:"
                   : ctl == Ctl::cflat  ? " control cflat:"
                                        : ":";
  std::printf("form%s %s: %llu cycles, %u values checked, %u mismatches: %s\n", cn,
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
      if (!std::strcmp(argv[i + 1], "lane0")) ctl = Ctl::lane0;
      else if (!std::strcmp(argv[i + 1], "nohi1")) ctl = Ctl::nohi1;
      else if (!std::strcmp(argv[i + 1], "noctx")) ctl = Ctl::noctx;
      else if (!std::strcmp(argv[i + 1], "cflat")) ctl = Ctl::cflat;
      else {
        std::fprintf(stderr, "form: unknown control %s\n", argv[i + 1]);
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "form: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
