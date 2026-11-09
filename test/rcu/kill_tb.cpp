//===-- kill_tb.cpp - rcu_kill against a value model ----------------------===//
//
// Drives rtl/rcu/rcu_kill.sv and holds every output, every cycle, to a
// value model of the Done, kill and reset tab: the kill registers
// (kill_v_q, kill_ep_q, kill_drain, kill_ack_q, kill_ack_ep_q, ack-ready
// with migration's quiesce term), the credit flops, the done wake, the
// idle term and the CSR responder. KILL_DRAIN is the tab's formula at the
// build's links, bnd_rx included: CCV_LAT_RCU_KILL_DRAIN (RA-42).
//
// Runs: directed kills (one alone, one during a drain, a late quiesce),
// then random traffic. --cg <idle|medium|high> <vcd> runs one clock-gating
// scenario (tools/check-cg.py). --control drain models KILL_DRAIN - 1,
// and the run must fail (test/rcu/run-rtl.sh). Exit 0 only with no
// mismatch.
//===----------------------------------------------------------------------===//
#include "Vrcu_kill.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>
#include <type_traits>

#include "ccv_params.h"


namespace {

constexpr unsigned kNS = 9, kNL = 32, kNM = 4, kNB = 6;
unsigned g_drain = ccv::prov::kLatRcuKillDrain;   // links and bnd_rx in (RA-42)

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

struct In {   // one cycle's inputs
  bool kv = false, mq = true, csr = false;
  unsigned dbusy = 0;   // ND = 2 terms
  unsigned kep = 0, busy = 0, mv = 0;
  uint32_t iv = 0, lv = 0;
};

extern int g_argc;
extern char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vrcu_kill> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0, acks = 0, rekills = 0;
  // The model's registers.
  bool kv_q = false, ack = false, pend = false, dwake = false, idle = false, csr = false;
  unsigned kep = 0, aep = 0, drain = 0;
  uint64_t cr = 0;
  bool rst_q = true;    // the module's flopped reset (RST-1): unknown, so held, until the first edge

  explicit Bench(const char *vcd_path) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vrcu_kill>(ctx.get());
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
  void chk(const char *what, uint64_t got, uint64_t want) {
    ++checked;
    if (got != want && ++fails <= 20)
      std::fprintf(stderr, "kill: cycle %llu: %s %llx, want %llx\n", (unsigned long long)cyc, what,
                   (unsigned long long)got, (unsigned long long)want);
  }

  void step(const In &in, bool rst = false) {
    dut->rst_n = !rst;
    dut->kv_cr00h = in.kv;
    dut->kep_cr01h = in.kep;
    dut->mq_cr01h = in.mq;
    dut->iv_cr00h = in.iv;
    dut->lv_cr00h = in.lv;
    dut->mv_cr00h = in.mv;
    dut->dbusy_cr00h = in.dbusy;
    dut->busy_cr00h = in.busy;
    dut->csr_v_cr00h = in.csr;
    dut->rcu_core_clk = 0;
    eval();
    // The edge: every register from this cycle's inputs and state, under
    // the reset as the module flops it.
    const bool rr = rst_q;
    rst_q = rst;
    if (rr) {
      kv_q = ack = pend = dwake = idle = csr = false;
      aep = drain = 0;
      cr = 0;
    } else {
      const bool rdy = pend && drain == 0 && in.mq;
      const bool en = kv_q || pend;
      const bool kv1 = kv_q;
      bool nack = ack, npend = pend;
      unsigned nkep = kep, ndrain = drain, naep = aep;
      if (en) {
        if (kv_q) {
          nkep = in.kep;
          naep = in.kep;   // the ack epoch takes it at K: the ack is low until ack-ready
          ndrain = g_drain;
          nack = false;
          rekills += pend;
          npend = true;
        } else {
          if (drain) --ndrain;
          if (rdy) {
            nack = true;
            npend = false;
            ++acks;
          }
        }
      }
      // lane results and kill land at no-flop ends: idle reads their
      // captures (the credit flops' lane field, kv_q), a cycle on.
      const bool lv_q = ((cr >> kNS) & ((uint64_t(1) << kNL) - 1)) != 0;
      const bool nidle = !in.busy && !in.dbusy && !in.iv && !lv_q && !in.mv && !kv1 &&
                         drain == 0 && !dwake;
      dwake = in.iv || in.dbusy;
      idle = nidle;
      cr = uint64_t(in.iv) | uint64_t(in.lv) << kNS | uint64_t(in.mv) << (kNS + kNL);
      csr = in.csr;
      kv_q = in.kv;
      ack = nack;
      pend = npend;
      kep = nkep;
      drain = ndrain;
      aep = naep;
    }
    dut->rcu_core_clk = 1;
    eval();
    if (!rr) {
      chk("kill_ack", dut->kack_cr02h, ack);
      chk("kill_ack_epoch", dut->kaep_cr02h, aep);
      chk("credits", get(dut->cr_cr01h, 0, kNS + kNL + kNM), cr);
      chk("done wake", dut->dwake_cr01h, dwake);
      chk("idle", dut->idle_cr01h, idle);
      chk("csr done", dut->csr_done_cr01h, csr);
      chk("csr credit", dut->csr_cr_cr01h, csr);
      chk("csr data", dut->csr_data_cr01h, 0);
    }
    ++cyc;
  }
};

struct Gen {
  std::mt19937 rng;
  explicit Gen(unsigned seed) : rng(seed) {}
  bool coin(double p) { return std::uniform_real_distribution<double>(0, 1)(rng) < p; }
  bool mq = true;
  unsigned ep = 0;
  In cycle(double p) {
    In in;
    if (coin(0.05)) mq = !mq;   // migration quiesces on its own time
    in.mq = mq;
    in.kv = coin(p * 0.02);
    in.kep = ep;
    if (in.kv) ep = (ep + 1) & 3;
    for (unsigned s = 0; s < kNS; ++s) if (coin(p * 0.4)) in.iv |= 1u << s;
    for (unsigned c = 0; c < kNL; ++c) if (coin(p * 0.3)) in.lv |= 1u << c;
    for (unsigned j = 0; j < kNM; ++j) if (coin(p * 0.3)) in.mv |= 1u << j;
    in.dbusy = (coin(p * 0.5) ? 1u : 0u) | (coin(p * 0.2) ? 2u : 0u);
    for (unsigned b = 0; b < kNB; ++b) if (coin(p * 0.2)) in.busy |= 1u << b;
    in.csr = coin(p * 0.02);
    return in;
  }
};

void directed(Bench &b) {
  In q;
  // A kill alone: ack after the drain.
  In k = q;
  k.kv = true;
  b.step(k);
  In e = q;
  e.kep = 2;
  b.step(e);
  for (unsigned i = 0; i < g_drain + 4; ++i) b.step(q);
  // A kill during a drain: answered once, with the new epoch.
  b.step(k);
  e.kep = 3;
  b.step(e);
  for (unsigned i = 0; i < 5; ++i) b.step(q);
  b.step(k);
  e.kep = 1;
  b.step(e);
  for (unsigned i = 0; i < g_drain + 4; ++i) b.step(q);
  // Migration not quiet: the ack waits for it.
  b.step(k);
  In n = q;
  n.mq = false;
  n.kep = 0;
  for (unsigned i = 0; i < g_drain + 6; ++i) b.step(n);
  for (unsigned i = 0; i < 3; ++i) b.step(q);
  // A CSR request.
  In c = q;
  c.csr = true;
  b.step(c);
  b.step(q);
}

int g_argc;
char **g_argv;

int run(const std::string &scenario, const char *vcd, bool ctl) {
  Bench b(vcd);
  const In none;
  for (int i = 0; i < 8; ++i) b.step(none, true);
  b.step(none);
  Gen g(0x4111);
  if (scenario.empty()) directed(b);
  const unsigned n = scenario == "idle" ? 3000 : 4000;
  for (unsigned i = 0; i < n; ++i) {
    In in;
    if (scenario == "medium") in = i % 3 == 0 ? g.cycle(0.8) : none;
    else if (scenario != "idle") in = g.cycle(0.9);
    b.step(in);
  }
  if (scenario != "idle" && (!b.acks || !b.rekills)) {
    std::fprintf(stderr, "kill: coverage: acks %u rekills %u\n", b.acks, b.rekills);
    ++b.fails;
  }
  std::printf("kill drain %u%s %s: %llu cycles, %u values checked, %u mismatches: %s\n", g_drain,
              ctl ? ", control drain:" : "", scenario.empty() ? "directed+random" : scenario.c_str(),
              (unsigned long long)b.cyc, b.checked, b.fails, b.fails ? "FAIL" : "PASS");
  return b.fails ? 1 : 0;
}

} // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string scenario;
  const char *vcd = nullptr;
  bool ctl = false;
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control") && !std::strcmp(argv[i + 1], "drain")) {
      ctl = true;
      --g_drain;
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "kill: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
