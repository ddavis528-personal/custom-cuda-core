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
// disp zero-extended.
//===----------------------------------------------------------------------===//
#include "Vmiu_agu8.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>

namespace {

constexpr unsigned kNL = 8, kVW = 50, kDW = 29;
constexpr uint64_t kVMask = (1ull << kVW) - 1;

struct Op {
  uint32_t am = 0;
  uint32_t base[kNL] = {}, idx[kNL] = {};
  uint32_t disp = 0;   // kDW bits
  bool scale_en = false, shared = false;
  unsigned chw = 0, xs = 0;
};

struct Want {
  uint64_t va[kNL] = {};
  uint32_t fal = 0;
};

enum class Ctl { none, xfer, sext };

Want model(const Op &o, Ctl ctl) {
  Want w;
  const unsigned xs = ctl == Ctl::xfer ? 0u : o.xs;
  const unsigned span = o.chw == 0 ? 4u : o.chw == 1 ? 2u : 1u;
  const unsigned nb = xs == 1 ? 1u : xs == 2 ? 2u : span;
  const unsigned sh = o.scale_en ? (nb == 4 ? 2u : nb == 2 ? 1u : 0u) : 0u;
  const int64_t d = ctl == Ctl::sext ? int64_t(o.disp)
                                     : int64_t(uint64_t(o.disp) << (64 - kDW)) >> (64 - kDW);
  for (unsigned l = 0; l < kNL; ++l) {
    const int64_t b = o.shared ? int64_t(o.base[l]) : int64_t(uint64_t(o.base[l]) << 16);
    const int64_t s = b + (int64_t(o.idx[l]) << sh) + d;
    w.va[l] = uint64_t(s) & kVMask;
    const bool mis = (nb == 4 && (s & 3)) || (nb == 2 && (s & 1));
    if ((o.am >> l & 1u) && mis) w.fal |= 1u << l;
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
  Ctl ctl;
  bool vprev = false, known = false;
  Want want{};

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
    edge();
    if (vprev) {   // the address that landed last cycle is in A1 now
      want = model(o, ctl);
      known = true;
      cov_b2b += v;
      const Want w0 = model(o, Ctl::none);
      for (unsigned l = 0; l < kNL; ++l) {
        cov_neg += (w0.va[l] >> (kVW - 1)) & 1u;
        cov_hi += !o.shared && !(w0.va[l] >> (kVW - 1) & 1u) && (w0.va[l] >> 48);
      }
      cov_fal += w0.fal != 0;
      cov_shared += o.shared;
    } else if (known) {
      ++cov_noise;
    }
    vprev = v;
    if (!known) return;
    ++checked;
    bool ok = dut->fal_cm06h == want.fal;
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
              !b.cov_noise)) {
    std::fprintf(stderr,
                 "agu8: coverage: negative %u, past 2^48 %u, align faults %u, shared %u, "
                 "back to back %u, noise %u\n",
                 b.cov_neg, b.cov_hi, b.cov_fal, b.cov_shared, b.cov_b2b, b.cov_noise);
    ++b.fails;
  }
  const char *cn = ctl == Ctl::xfer ? " control xfer:" : ctl == Ctl::sext ? " control sext:" : ":";
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
