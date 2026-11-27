//===-- agu8_tb.cpp - miu_agu8 bench: A1's sums for one lane octet ----------===//
//
// Drives one slot's octet as miu_cap and miu_pair hold it: the valid
// (v_cm04h) a cycle before A1, then the lanes' base and index and the
// memop's disp and space held in A1, with the transfer's scale and size as
// miu_pair decodes them from scale_en, chwidth and xfer_size, and
// noise in every other cycle (random mode), which the module must not take.
// Checks, every cycle, the held sums and align faults against a value
// model of the model's AGU (sim/miu/miu_block.cpp): the exact sum to 50
// bits, two's complement, and F-ALIGN on active lanes at the transfer's
// size. Operands are drawn to reach the edges: disp at both signs and its
// extremes, base and index at 0 and all ones, sums below 0 and at or past
// 2^48, every chwidth and xfer_size.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle is reset and no address, the wires still;
// medium an address on about a third of the cycles; high one nearly every
// cycle; the operand wires change only with an address.
// Controls, each of which must fail: xfer models the transfer from chwidth
// alone (O-80's xfer_size ignored, the model's xfer-ignored); sext models
// disp zero-extended; wnoc models the window compare (we, S[47:16+k] ==
// W >> k, for A2's window F-ADDR) without the carry into bit 16 + k, which
// the carry-save compare must supply.
//===----------------------------------------------------------------------===//
#include "Vmiu_agu8.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdint>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>

namespace {

// CCV_AGU8_LC: the unit's LC (cg-build.sh), lc checked only at 1.
#ifndef CCV_AGU8_LC
#define CCV_AGU8_LC 0
#endif
constexpr unsigned kNL = 8, kVW = 50, kDW = 29, kLanes = 32, kWL = 32;
constexpr uint64_t kVMask = (1ull << kVW) - 1;
// The forms (MI-21): the unit's sizes.
constexpr uint64_t kLC = 4096, kPW = 1;
constexpr unsigned kPK = 0, kNN = 22, kBL = kNN - 16, kHH = kVW - kNN - 8, kCXW = 7, kCore = 0;
constexpr uint64_t kL = kPW << 16;

struct Op {
  uint32_t am = 0;
  uint32_t base[kNL] = {}, idx[kNL] = {};
  uint32_t disp = 0;   // kDW bits
  bool scale_en = false, shared = false;
  unsigned chw = 0, xs = 0;
  // The forms, as miu_form flops them, and every lane's base.
  unsigned oct = 0, warp = 0;
  bool slot = false, local = false, elig = false;
  uint32_t win = 0, issue = 0;
  uint64_t lbase = 0;
  uint32_t bw[kLanes] = {};
};

struct Want {
  uint64_t va[kNL] = {};
  uint32_t fal = 0;
  bool ilv = false, loc = false, ow = false;
  uint32_t we = 0;   // each lane's S[47:16+k] == W >> k
};

enum class Ctl { none, xfer, sext, lane0, noshift, lcl1, wnoc };

Want model(const Op &o, Ctl ctl) {
  Want w;
  const unsigned xs = ctl == Ctl::xfer ? 0u : o.xs;
  const unsigned span = o.chw == 0 ? 4u : o.chw == 1 ? 2u : 1u;
  const unsigned nb = xs == 1 ? 1u : xs == 2 ? 2u : span;
  const unsigned sh = o.scale_en ? (nb == 4 ? 2u : nb == 2 ? 1u : 0u) : 0u;
  const int64_t d = ctl == Ctl::sext ? int64_t(o.disp)
                                     : int64_t(uint64_t(o.disp) << (64 - kDW)) >> (64 - kDW);
  // O-83's decision on lane d (sim/miu/miu_block.cpp): rbase(d) >> k == W >> k,
  // d the issue mask's lowest lane. lane0: ccv-sim's priv-lane0 control.
  const uint64_t W = o.lbase + 3 * kLC;
  const unsigned dl = ctl == Ctl::lane0 ? 0u : o.issue ? unsigned(__builtin_ctz(o.issue)) : 0u;
  w.ilv = o.elig && o.issue && (uint64_t(o.bw[dl]) >> kPK) == (W >> kPK);
  w.loc = o.local;
  // An ordinary .global access, which A2 checks against the run's windows.
  w.ow = !o.shared && !o.local && !w.ilv;
  for (unsigned l = 0; l < kNL; ++l) {
    // MI-25 (D): A1 is the ordinary sum S over the slot form's window or the
    // lane's rbase; the forms are A2's, by wiring on S. noshift: S taken
    // without rbase's << 16, which b = S - (W << 16) needs.
    const uint64_t bs = o.slot ? o.win : o.base[l];
    const int64_t b = o.shared || ctl == Ctl::noshift ? int64_t(bs) : int64_t(uint64_t(bs) << 16);
    const uint64_t a = uint64_t(b + (int64_t(o.idx[l]) << sh) + d);
    w.va[l] = a & kVMask;
    // F-ALIGN on the address's two low bits: S's, or disp's for the local form.
    const uint64_t lo = o.local ? uint64_t(d) : a;
    const bool mis = (nb == 4 && (lo & 3)) || (nb == 2 && (lo & 1));
    if ((o.am >> l & 1u) && mis) w.fal |= 1u << l;
    // The window F-ADDR's compare (O-83, IS's rev 171): S[47:16+k] against
    // W >> k (miu_form's WHW-bit wh), every lane, A2 making it the fault.
    // wnoc: the sum's bits taken without the carry into bit 16 + k, which
    // the carry-save compare must supply.
    uint64_t sv = w.va[l];
    if (ctl == Ctl::wnoc) {
      const uint64_t lm = (uint64_t(1) << (16 + kPK)) - 1u;
      const uint64_t lo = (uint64_t(b) & lm) + ((uint64_t(int64_t(o.idx[l]) << sh)) & lm) + (uint64_t(d) & lm);
      sv -= (lo >> (16 + kPK)) << (16 + kPK);
    }
    const bool eq = (sv >> (16 + kPK) & ((uint64_t(1) << (32 - kPK)) - 1u)) ==
                    uint64_t(uint32_t(W >> kPK));
    w.we |= uint32_t(eq) << l;
  }
  return w;
}

int g_argc;
char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vmiu_agu8> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  unsigned cov_neg = 0, cov_hi = 0, cov_fal = 0, cov_shared = 0, cov_b2b = 0, cov_noise = 0;
  unsigned cov_slot = 0, cov_local = 0, cov_ilv = 0, cov_fad = 0, cov_dhi = 0, cov_carry = 0;
  unsigned cov_win = 0, cov_wc = 0;   // an ordinary lane in the windows; a compare the low carry decides
  Ctl ctl;
  bool vprev = false, known = false;
  Want want{};
  Op dbg{};

  Bench(const char *vcd_path, Ctl c) : ctl(c) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vmiu_agu8>(ctx.get());
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
  }
  // One cycle: v on the wire, the A1 operands o held; then the edge and the
  // checks of what it captured.
  void step(bool v, const Op &o) {
    dut->v_cm04h = v;
    dut->am_cm05h = o.am;
    for (unsigned l = 0; l < kNL; ++l) {
      dut->base_cm05h[l] = o.base[l];
      dut->idx_cm05h[l] = o.idx[l];
    }
    dut->disp_cm05h = o.disp;
    dut->shared_cm05h = o.shared;
    // miu_pair's decode of the transfer, a stage ahead.
    const unsigned span = o.chw == 0 ? 4u : o.chw == 1 ? 2u : 1u;
    const unsigned nb = o.xs == 1 ? 1u : o.xs == 2 ? 2u : span;
    dut->sh2_cm05h = o.scale_en && nb == 4;
    dut->sh1_cm05h = o.scale_en && nb == 2;
    dut->b4_cm05h = nb == 4;
    dut->b2_cm05h = nb == 2;
    // miu_form's flops: the forms, W >> k, R(ctx)'s region bits and ctx,
    // and lane d's one-hot; every lane's base.
    dut->win_cm05h = o.win;
    dut->sl_cm05h = o.slot;
    dut->fs_cm05h = (o.elig << 2) | (o.local << 1) | o.slot;
    const uint64_t W = o.lbase + 3 * kLC;
    dut->wh_cm05h = uint32_t(W >> kPK);
    dut->dh_cm05h = o.issue & (~o.issue + 1);
    for (unsigned i = 0; i < kLanes; ++i) dut->bw_cm05h[i] = o.bw[i];
    edge();
    if (vprev) {   // the address that landed last cycle is in A1 now
      want = model(o, ctl);
      dbg = o;
      known = true;
      cov_b2b += v;
      const Want w0 = model(o, Ctl::none);
      for (unsigned l = 0; l < kNL; ++l) {
        cov_neg += (w0.va[l] >> (kVW - 1)) & 1u;
        cov_hi += !o.shared && !(w0.va[l] >> (kVW - 1) & 1u) && (w0.va[l] >> 48);
      }
      cov_fal += w0.fal != 0;
      cov_shared += o.shared;
      cov_slot += o.slot;
      cov_local += o.local;
      cov_ilv += w0.ilv;
      for (unsigned l = 0; l < kNL && w0.ilv; ++l)   // an interleaved lane off W's block
        cov_fad += (w0.va[l] >> (16 + kPK)) != ((o.lbase + 3 * kLC) >> kPK);
      cov_dhi += w0.ilv && __builtin_ctz(o.issue) >= 8;   // lane d outside octet 0
      for (unsigned l = 0; l < kNL && w0.ow; ++l)   // an ordinary lane in W's block
        cov_win += (o.am >> l & 1u) &&
                   (w0.va[l] >> (16 + kPK) & ((uint64_t(1) << (32 - kPK)) - 1u)) ==
                       uint64_t(uint32_t((o.lbase + 3 * kLC) >> kPK));
      cov_wc += w0.we != model(o, Ctl::wnoc).we;
      for (unsigned l = 0; l < kNL && w0.ilv; ++l)   // in W's block from an rbase != W
        cov_carry += o.base[l] != uint32_t(o.lbase + 3 * kLC) &&
                     (w0.va[l] >> (16 + kPK)) == ((o.lbase + 3 * kLC) >> kPK);
    } else if (known) {
      ++cov_noise;
    }
    vprev = v;
    if (!known) return;
    ++checked;
    bool ok = dut->fal_cm06h == want.fal && bool(dut->ilv_cm06h) == want.ilv &&
              bool(dut->loc_cm06h) == want.loc && bool(dut->ow_cm06h) == want.ow &&
              uint32_t(dut->we_cm06h) == want.we;
    if (bool(dut->ilv_cm06h) != want.ilv || bool(dut->loc_cm06h) != want.loc ||
        bool(dut->ow_cm06h) != want.ow || uint32_t(dut->we_cm06h) != want.we)
      if (fails < 20)
        std::fprintf(stderr, "agu8: cycle %llu: ilv %u loc %u ow %u we %02x, want %u %u %u %02x\n",
                     (unsigned long long)cyc, unsigned(dut->ilv_cm06h), unsigned(dut->loc_cm06h),
                     unsigned(dut->ow_cm06h), unsigned(dut->we_cm06h), unsigned(want.ilv),
                     unsigned(want.loc), unsigned(want.ow), unsigned(want.we));
    for (unsigned l = 0; l < kNL; ++l) {
      const unsigned bit = l * kVW;
      uint64_t got = 0;
      for (unsigned i = 0; i < kVW; ++i) {
        const unsigned p = bit + i;
        got |= uint64_t(dut->va_cm06h[p / 32] >> (p % 32) & 1u) << i;
      }
      if (got != want.va[l]) {
        ok = false;
        if (fails < 20)
          std::fprintf(stderr, "agu8: cycle %llu: lane %u sum %013llx, want %013llx\n",
                       (unsigned long long)cyc, l, (unsigned long long)got,
                       (unsigned long long)want.va[l]);
        if (getenv("AGU8_DBG") && fails < 3)
          std::fprintf(stderr, "  base %08x idx %08x disp %08x se %u chw %u xs %u sh %u sl %u lo %u el %u "
                       "oct %u warp %u lbase %llx issue %08x bw[d] %08x\n", dbg.base[l], dbg.idx[l],
                       dbg.disp, dbg.scale_en, dbg.chw, dbg.xs, dbg.shared, dbg.slot, dbg.local,
                       dbg.elig, dbg.oct, dbg.warp, (unsigned long long)dbg.lbase, dbg.issue,
                       dbg.issue ? dbg.bw[__builtin_ctz(dbg.issue)] : 0);
      }
    }
    // lc: lane 0's line again (LC = 1, MA rev 209); lcl1, lane 1's.
    {
      const uint64_t lm = (1ull << 41) - 1;
      const uint64_t wl = CCV_AGU8_LC ? (want.va[ctl == Ctl::lcl1 ? 1 : 0] >> 7) & lm : 0;
      if ((uint64_t(dut->lc_cm06h) & lm) != wl) {
        ok = false;
        if (fails < 20)
          std::fprintf(stderr, "agu8: cycle %llu: lc %011llx, want %011llx\n",
                       (unsigned long long)cyc, (unsigned long long)dut->lc_cm06h,
                       (unsigned long long)wl);
      }
    }
    if (!ok && ++fails <= 20 && dut->fal_cm06h != want.fal)
      std::fprintf(stderr, "agu8: cycle %llu: align faults %02x, want %02x\n",
                   (unsigned long long)cyc, unsigned(dut->fal_cm06h), want.fal);
  }
};

struct Gen {
  std::mt19937_64 r;
  explicit Gen(uint64_t seed) : r(seed) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
  uint32_t word() {
    switch (below(6)) {
      case 0: return 0;
      case 1: return ~0u;
      case 2: return uint32_t(r()) & 0xff;
      default: return uint32_t(r());
    }
  }
  Op op() {
    Op o;
    o.am = below(8) == 0 ? 0xffu : below(8) == 0 ? 0u : uint32_t(r()) & 0xffu;
    for (unsigned l = 0; l < kNL; ++l) {
      o.base[l] = word();
      o.idx[l] = word();
      // Aligned lanes too, so F-ALIGN's clean case is common.
      if (below(2)) o.idx[l] &= ~3u;
    }
    const uint32_t dm = (1u << kDW) - 1;
    switch (below(6)) {
      case 0: o.disp = 0; break;
      case 1: o.disp = dm; break;                  // -1
      case 2: o.disp = 1u << (kDW - 1); break;     // the most negative
      case 3: o.disp = dm >> 1; break;             // the most positive
      default: o.disp = uint32_t(r()) & dm; break;
    }
    if (below(2)) o.disp &= ~3u;
    o.scale_en = below(2);
    o.shared = below(4) == 0;
    o.chw = below(4);
    o.xs = below(4) == 3 ? 0 : below(3);
    // The forms. local_base: low enough for W < 2^32 mostly (the
    // interleaved form's eligibility), sometimes anywhere in 48 bits.
    o.oct = below(4);
    o.warp = below(32);
    o.lbase = below(4) ? r() % ((1ull << 32) - 3 * kLC) : r() & ((1ull << 48) - 1);
    const uint64_t W = o.lbase + 3 * kLC;
    o.issue = below(8) == 0 ? 0u : uint32_t(r()) | (below(2) ? 0u : 1u << below(32));
    for (unsigned i = 0; i < kLanes; ++i) o.bw[i] = word();
    o.win = word();
    switch (below(6)) {
      case 0: o.slot = true; break;
      case 1:
        if (!o.shared) {
          o.local = true;
          o.disp = uint32_t(r()) & 0xffffu;   // a spill frame's byte, [0, 2^16)
        }
        break;
      case 2: case 3: case 4: {
        // Into the private run: lane d's rbase is W, and the octet's lanes
        // lie at W, or a window either side, with small offsets.
        if (!o.issue) o.issue = 1u << below(32);
        const unsigned d = unsigned(__builtin_ctz(o.issue));
        o.bw[d] = uint32_t(W);
        for (unsigned l = 0; l < kNL; ++l) {
          const unsigned k = below(8);
          o.base[l] = uint32_t(W + (k == 0 ? -1 : k == 1 ? 1 : 0));
          o.idx[l] = below(4) ? uint32_t(r()) & 0x3fffu : word();
          o.bw[8 * o.oct + l] = o.base[l];
        }
        if (below(4)) o.disp = uint32_t(r()) & 0x3ffu;
        if (below(3) == 0) o.bw[d] = uint32_t(W) ^ (1u << below(32));   // just outside
        if (d / 8 == o.oct) o.base[d % 8] = o.bw[d];   // lane d in this octet
        break;
      }
      default: break;
    }
    o.elig = !o.shared && !o.slot && !o.local && W < (1ull << 32);
    return o;
  }
};

int run(const std::string &scenario, const char *vcd, Ctl ctl) {
  Bench b(vcd, ctl);
  Gen g(0xa68);
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 50000 : scenario == "idle" ? 3000 : 4000;
  Op o{}, next{};
  bool pend = false;   // a valid went out last cycle: its operands are in A1 now
  for (unsigned i = 0; i < n; ++i) {
    const bool v = scenario == "idle"     ? false
                   : scenario == "medium" ? (i % 3 == 0 && g.below(10) < 8)
                   : scenario == "high"   ? g.below(10) < 9
                                          : (i / 64) % 2 ? g.below(10) < 9 : g.below(4) == 0;
    if (pend) o = next;
    else if (rnd && g.below(2)) o = g.op();
    if (v) next = g.op();
    pend = v;
    b.step(v, o);
  }
  if (rnd && (!b.cov_neg || !b.cov_hi || !b.cov_fal || !b.cov_shared || !b.cov_b2b ||
              !b.cov_noise || !b.cov_slot || !b.cov_local || !b.cov_ilv || !b.cov_fad ||
              !b.cov_dhi || !b.cov_carry || !b.cov_win || !b.cov_wc)) {
    std::fprintf(stderr,
                 "agu8: coverage: negative %u, past 2^48 %u, align faults %u, shared %u, "
                 "back to back %u, noise %u, slot %u, local %u, interleaved %u, F-ADDR %u, "
                 "lane d past 7 %u, in W's block from rbase != W %u, ordinary in W's block %u, "
                 "compare by the low carry %u\n",
                 b.cov_neg, b.cov_hi, b.cov_fal, b.cov_shared, b.cov_b2b, b.cov_noise,
                 b.cov_slot, b.cov_local, b.cov_ilv, b.cov_fad, b.cov_dhi, b.cov_carry, b.cov_win,
                 b.cov_wc);
    ++b.fails;
  }
  const char *cn = ctl == Ctl::xfer    ? " control xfer:"
                   : ctl == Ctl::sext  ? " control sext:"
                   : ctl == Ctl::lane0 ? " control lane0:"
                   : ctl == Ctl::noshift ? " control noshift:"
                   : ctl == Ctl::lcl1 ? " control lcl1:"
                   : ctl == Ctl::wnoc ? " control wnoc:"
                                       : ":";
  std::printf("agu8%s %s: %llu cycles, %u values checked, %u mismatches: %s\n", cn,
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
      if (!std::strcmp(argv[i + 1], "xfer")) ctl = Ctl::xfer;
      else if (!std::strcmp(argv[i + 1], "sext")) ctl = Ctl::sext;
      else if (!std::strcmp(argv[i + 1], "lane0")) ctl = Ctl::lane0;
      else if (!std::strcmp(argv[i + 1], "noshift")) ctl = Ctl::noshift;
      else if (!std::strcmp(argv[i + 1], "lcl1")) ctl = Ctl::lcl1;
      else if (!std::strcmp(argv[i + 1], "wnoc")) ctl = Ctl::wnoc;
      else {
        std::fprintf(stderr, "agu8: unknown control %s\n", argv[i + 1]);
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "agu8: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
