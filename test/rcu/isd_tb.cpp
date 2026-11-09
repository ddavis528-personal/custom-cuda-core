//===-- isd_tb.cpp - rcu_isd bench: a slot's class word from its lead ------===//
//
// Drives the slot's lead (opcode, done_row, pred_we, phys_dst) beside its
// valid in A-1, noise off a valid, and checks the slot's class in A against
// the model's decode on every input, then at random (test/rcu/cls_pack.h, the word rcu_dec_pkg packs; the
// module decodes with rcu_cls_a1, the depth-built form):
// loaded under the valid, held otherwise. Opcodes are drawn from every one
// the decode names, the copy's included, atomics at every done_row, and the
// copy's predicate-only form (pred_we and the zero GPR).
// The slot's lead copies (RA 131 (1); ISD_LS, the unit's LS: 42 bits on
// S0-S3, else 2) ride the same capture and are checked the same way.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py). --control pcopy models the copy without its
// predicate-only form, and --control xfree the copies loaded every cycle
// (not held off a valid); each must fail.
//===----------------------------------------------------------------------===//
#include "Vrcu_isd.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>
#include <type_traits>
#include <vector>

#include "cls_pack.h"
#include "dec_tb.h"

namespace {

#ifndef ISD_LS
#define ISD_LS 0
#endif
constexpr unsigned kNS = 1, kOW = 9, kWR = 8, kCW = 27, kXW = ISD_LS ? 42 : 2;

template <typename T> void put(T &s, unsigned lsb, unsigned w, uint64_t v) {
  for (unsigned i = 0; i < w; ++i) {
    const unsigned b = lsb + i;
    const uint64_t bit = (v >> i) & 1u;
    if constexpr (std::is_integral_v<T>) {
      s = T((s & ~(T(1) << b)) | (T(bit) << b));
    } else {
      s[b / 32] = (s[b / 32] & ~(1u << (b % 32))) | (uint32_t(bit) << (b % 32));
    }
  }
}
template <typename T> uint64_t get(const T &s, unsigned lsb, unsigned w) {
  uint64_t v = 0;
  for (unsigned i = 0; i < w; ++i) {
    const unsigned b = lsb + i;
    uint64_t bit;
    if constexpr (std::is_integral_v<T>) bit = (uint64_t(s) >> b) & 1u;
    else bit = (s[b / 32] >> (b % 32)) & 1u;
    v |= bit << i;
  }
  return v;
}

struct Lead { unsigned opc = 0, drow = 0, dst = 0; bool pwe = false; uint64_t x = 0; };

extern int g_argc;
extern char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vrcu_isd> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0, cov_pcopy = 0, cov_atom = 0, cov_hold = 0;
  bool ctl = false, xfree = false;
  bool known[kNS] = {};
  uint64_t want[kNS] = {}, wantx[kNS] = {};

  Bench(const char *vcd_path, bool control, bool xf) : ctl(control), xfree(xf) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vrcu_isd>(ctx.get());
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
  uint64_t model(const Lead &l) {
    const bool pc = l.pwe && l.dst == dectb::R::kZero;
    return clspack::clsWord(l.opc, l.drow, pc && !ctl);
  }
  // One cycle: these leads (valid where v), then the edge, then A's check.
  void step(uint32_t v, const Lead *ld) {
    dut->iv_cr01h = v;
    for (unsigned s = 0; s < kNS; ++s) {
      put(dut->lop_cr01h, s * kOW, kOW, ld[s].opc);
      put(dut->ldrw_cr01h, s * 2, 2, ld[s].drow);
      put(dut->lpwe_cr01h, s, 1, ld[s].pwe);
      put(dut->ldst_cr01h, s * kWR, kWR, ld[s].dst);
      put(dut->lx_cr01h, s * kXW, kXW, ld[s].x);
    }
    dut->rcu_core_clk = 0;
    eval();
    dut->rcu_core_clk = 1;
    eval();
    ++cyc;
    for (unsigned s = 0; s < kNS; ++s) {
      if ((v >> s) & 1u) {
        want[s] = model(ld[s]);
        wantx[s] = ld[s].x;
        known[s] = true;
        const bool pc = ld[s].pwe && ld[s].dst == dectb::R::kZero && ld[s].opc == ccv::skel::kOpCopy;
        cov_pcopy += pc;
        cov_atom += ccv::skel::opByCode(ld[s].opc) &&
                    ccv::skel::opByCode(ld[s].opc)->cls == ccv::skel::kAtomic;
      } else if (known[s]) {
        ++cov_hold;
        if (xfree) wantx[s] = ld[s].x;
      }
      if (!known[s]) continue;
      ++checked;
      const uint64_t got = get(dut->cls_cr02h, s * kCW, kCW);
      if (got != want[s] && ++fails <= 20)
        std::fprintf(stderr, "isd: cycle %llu slot %u: class %07llx, want %07llx\n",
                     (unsigned long long)cyc, s, (unsigned long long)got,
                     (unsigned long long)want[s]);
      ++checked;
      const uint64_t gx = get(dut->x_cr02h, s * kXW, kXW);
      if (gx != wantx[s] && ++fails <= 20)
        std::fprintf(stderr, "isd: cycle %llu slot %u: lead copies %llx, want %llx\n",
                     (unsigned long long)cyc, s, (unsigned long long)gx,
                     (unsigned long long)wantx[s]);
    }
  }
};

struct Gen {
  std::mt19937_64 r;
  std::vector<unsigned> ops = dectb::allOpcodes();
  explicit Gen(uint64_t seed) : r(seed) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
  Lead lead() {
    Lead l;
    const unsigned k = below(16);
    l.opc = k == 0 ? below(512) : k == 1 ? ccv::skel::kOpCopy : ops[below(unsigned(ops.size()))];
    l.drow = below(4);
    l.pwe = below(2);
    l.dst = below(4) == 0 ? dectb::R::kZero : below(256);
    l.x = r() & ((uint64_t(1) << kXW) - 1);
    return l;
  }
};

int g_argc;
char **g_argv;

int run(const std::string &scenario, const char *vcd, bool ctl, bool xfree) {
  Bench b(vcd, ctl, xfree);
  Gen g(0x15d0);
  Lead ld[kNS];
  const unsigned n = scenario.empty() ? 100000 : scenario == "idle" ? 3000 : 4000;
  // Every input first (opcode, done_row, pcopy or not), each under its valid.
  for (unsigned i = 0; scenario.empty() && i < 512 * 4 * 2; ++i) {
    for (unsigned s = 0; s < kNS; ++s) {
      ld[s].opc = i >> 3;
      ld[s].drow = (i >> 1) & 3u;
      ld[s].pwe = i & 1u;
      ld[s].dst = dectb::R::kZero;
      ld[s].x = (uint64_t(i) * 0x9e3779b97f4a7c15ull >> 20) & ((uint64_t(1) << kXW) - 1);
    }
    b.step((1u << kNS) - 1, ld);
  }
  for (unsigned i = 0; i < n; ++i) {
    uint32_t v = 0;
    for (unsigned s = 0; s < kNS; ++s) {
      const bool on = scenario == "idle"     ? false
                      : scenario == "medium" ? (i % 3 == 0 && g.below(10) < 8)
                      : scenario == "high"   ? g.below(10) < 9
                                             : g.below(2);
      // Random: noise off a valid, which the module must not keep. A
      // clock-gating scenario holds the lead off a valid, as OOE's gated
      // lead flop does, so input activity follows the valid's.
      if (on || scenario.empty()) ld[s] = g.lead();
      v |= uint32_t(on) << s;
    }
    b.step(v, ld);
  }
  if (scenario.empty() && (!b.cov_pcopy || !b.cov_atom || !b.cov_hold)) {
    std::fprintf(stderr, "isd: coverage: pcopy %u atomics %u holds %u\n", b.cov_pcopy,
                 b.cov_atom, b.cov_hold);
    ++b.fails;
  }
  std::printf("isd%s%s %s: %llu cycles, %u values checked, %u mismatches: %s\n",
              ISD_LS ? " (LS)" : "", ctl ? ", control pcopy:" : xfree ? ", control xfree:" : "", scenario.empty() ? "random" : scenario.c_str(),
              (unsigned long long)b.cyc, b.checked, b.fails, b.fails ? "FAIL" : "PASS");
  return b.fails ? 1 : 0;
}

}  // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string scenario;
  const char *vcd = nullptr;
  bool ctl = false, xfree = false;
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control")) {
      if (!std::strcmp(argv[i + 1], "pcopy")) ctl = true;
      else if (!std::strcmp(argv[i + 1], "xfree")) xfree = true;
      else {
        std::fprintf(stderr, "isd: unknown control %s\n", argv[i + 1]);
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "isd: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl, xfree);
}
