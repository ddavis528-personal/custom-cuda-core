//===-- mq_tb.cpp - miu_mq bench: entries, held payloads, memop credits -----===//
//
// Drives ccv_ooe_miu_memop's four slots as OOE does, each slot under its own
// CCV_MEMOP_CREDITS credits: a memop or a bulk discard (mem_op 0xF, the rest
// zero) spends one, the valid at M and the 126-bit payload a cycle on. In
// random mode the payload wires carry noise in cycles with no payload,
// which the module must not keep. The completion side frees held entries
// through the four free ports, at most one port an entry, and returns each
// credit it gets back to the slot's count. Checks, every cycle, against a
// value model of slice 1's MQ:
//   - me: the entry each slot's memop takes is its slot's lowest free one
//     (slot j owns entries j*NC .. j*NC + NC - 1);
//   - every held entry's two views (A1 and HI, miu_pkg) are its payload,
//     from the cycle after it is written until it is freed;
//   - cr: a credit on the entry's slot for each freed entry and each bulk
//     discard, one a cycle a slot, the excess on the following cycles.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle is reset and no memop; medium memops on about a
// third of the cycles; high nearly every cycle; the payload's wires change
// only with a memop. --control slot models a freed entry's credit returned
// on the next slot, and --control discard a bulk discard taking an entry;
// each must fail.
//===----------------------------------------------------------------------===//
#include "Vmiu_mq.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <map>
#include <memory>
#include <random>
#include <set>
#include <string>
#include <vector>

namespace {

constexpr unsigned kNS = 4, kNC = 10, kNE = kNS * kNC, kNF = 4, kEW = 6;
constexpr unsigned kAW = 63, kHW = 63, kPL = kAW + kHW;
constexpr unsigned kMemOpLsb = 51;   // miu_pkg::A1_MEM_OP

int g_argc;
char **g_argv;

struct Pay {
  uint64_t a1 = 0, hi = 0;   // the A1 view (bits 0..62) and HI (63..125)
  bool operator==(const Pay &o) const { return a1 == o.a1 && hi == o.hi; }
  bool discard() const { return ((a1 >> kMemOpLsb) & 0xF) == 0xF; }
};

template <class W> uint64_t getBits(const W &w, unsigned o, unsigned n) {
  uint64_t v = 0;
  for (unsigned b = 0; b < n; ++b) v |= uint64_t((w[(o + b) / 32] >> ((o + b) % 32)) & 1) << b;
  return v;
}
template <class W> void putBits(W &w, unsigned o, unsigned n, uint64_t v) {
  for (unsigned b = 0; b < n; ++b) {
    const unsigned i = (o + b) / 32, s = (o + b) % 32;
    w[i] = (w[i] & ~(1u << s)) | (uint32_t((v >> b) & 1) << s);
  }
}

struct Memop {
  unsigned slot = 0;
  Pay pay;
};

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vmiu_mq> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  unsigned cov_full = 0, cov_owed = 0, cov_discard = 0, cov_noise = 0, cov_four_free = 0;
  std::string control;
  // The model: each slot's free entries, held payloads, credits owed.
  std::set<unsigned> free_[kNS];
  std::map<unsigned, Pay> held;
  unsigned owed[kNS] = {};
  // Last cycle's memops and frees, which the module takes this cycle.
  std::vector<Memop> prev_m;
  std::vector<unsigned> prev_f;
  bool want_cr[kNS] = {};

  Bench(const char *vcd_path, std::string ctl) : control(std::move(ctl)) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vmiu_mq>(ctx.get());
    if (vcd_path) {
      vcd = std::make_unique<VerilatedVcdC>();
      dut->trace(vcd.get(), 99);
      vcd->open(vcd_path);
    }
    for (unsigned j = 0; j < kNS; ++j)
      for (unsigned l = 0; l < kNC; ++l) free_[j].insert(j * kNC + l);
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
    dut->mv_cm00h = 0;
    dut->fv_cm00h = 0;
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();   // the flopped reset releases a cycle on (RST-1)
  }
  unsigned lowest(unsigned j) const { return free_[j].empty() ? j * kNC : *free_[j].begin(); }
  void bad(const char *what, unsigned a, unsigned b) {
    if (++fails <= 20)
      std::fprintf(stderr, "mq: cycle %llu: %s %u, want %u\n", (unsigned long long)cyc, what, a, b);
  }

  /// One cycle: this cycle's memops (valid) and frees (valid and entry);
  /// the payload of last cycle's memops on the wires; then the edge and
  /// the checks of what the module holds.
  void step(const std::vector<Memop> &now, const std::vector<unsigned> &frees, bool noise,
            std::mt19937_64 &r) {
    // me now names the entry each of last cycle's memops takes.
    for (const Memop &m : prev_m) {
      const bool takes = !m.pay.discard() || control == "discard";
      if (!takes) continue;
      ++checked;
      const unsigned me = (dut->me_cm01h >> (m.slot * kEW)) & ((1u << kEW) - 1);
      if (me != lowest(m.slot)) bad("me", me, lowest(m.slot));
    }
    // Wires.
    uint32_t mv = 0;
    for (const Memop &m : now) mv |= 1u << m.slot;
    dut->mv_cm00h = mv;
    for (unsigned j = 0; j < kNS; ++j) {
      const Memop *m = nullptr;
      for (const Memop &x : prev_m)
        if (x.slot == j) m = &x;
      if (m) {
        putBits(dut->pay_cm01h, j * kPL, kAW, m->pay.a1);
        putBits(dut->pay_cm01h, j * kPL + kAW, kHW, m->pay.hi);
      } else if (noise && r() % 2) {
        putBits(dut->pay_cm01h, j * kPL, kAW, r() & ((1ull << kAW) - 1));
        putBits(dut->pay_cm01h, j * kPL + kAW, kHW, r() & ((1ull << kHW) - 1));
        ++cov_noise;
      }
    }
    uint32_t fv = 0, fe = 0;
    for (unsigned p = 0; p < frees.size(); ++p) {
      fv |= 1u << p;
      fe |= frees[p] << (p * kEW);
    }
    if (noise)
      for (unsigned p = unsigned(frees.size()); p < kNF; ++p) fe |= unsigned(r() % 64) << (p * kEW);
    dut->fv_cm00h = fv;
    dut->fe_cm00h = fe;
    // The model takes last cycle's memops and frees now.
    unsigned ret[kNS] = {};
    for (const Memop &m : prev_m) {
      if (m.pay.discard() && control != "discard") {
        ++ret[m.slot];
        continue;
      }
      const unsigned e = lowest(m.slot);
      free_[m.slot].erase(e);
      held[e] = m.pay;
    }
    unsigned per_slot[kNS] = {};
    for (unsigned e : prev_f) {
      const unsigned j = e / kNC;
      free_[j].insert(e);
      held.erase(e);
      ++per_slot[j];
      ++ret[control == "slot" ? (j + 1) % kNS : j];
    }
    for (unsigned j = 0; j < kNS; ++j) {
      cov_four_free += per_slot[j] >= 3;
      cov_full += free_[j].empty();
      const unsigned due = owed[j] + ret[j];
      want_cr[j] = due != 0;
      owed[j] = due ? due - 1 : 0;
      cov_owed += owed[j] != 0;
    }
    edge();
    prev_m = now;
    prev_f = frees;
    // Visible now: the credits, and every held entry's views.
    for (unsigned j = 0; j < kNS; ++j) {
      ++checked;
      const bool cr = (dut->cr_cm02h >> j) & 1;
      if (cr != want_cr[j]) bad("cr on slot", cr, want_cr[j]);
    }
    for (const auto &[e, p] : held) {
      ++checked;
      const Pay got{getBits(dut->a1_cm02h, e * kAW, kAW), getBits(dut->hi_cm02h, e * kHW, kHW)};
      if (!(got == p)) bad("payload differs in entry", e, e);
    }
  }
};

int run(const std::string &scenario, const char *vcd, const std::string &ctl) {
  Bench b(vcd, ctl);
  std::mt19937_64 r(0x3a7);
  auto below = [&](unsigned n) { return unsigned(r() % n); };
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 60000 : scenario == "idle" ? 3000 : 4000;
  unsigned cred[kNS];
  for (unsigned j = 0; j < kNS; ++j) cred[j] = kNC;
  for (unsigned i = 0; i < n; ++i) {
    // Phases: random mode alternates a filling phase (few frees, slots run
    // out of credits) with a draining one (many frees, slot-heavy bursts).
    const bool fill = rnd && (i / 200) % 2;
    const unsigned busy = scenario == "idle"     ? 0
                          : scenario == "medium" ? (i % 3 == 0 ? 6 : 0)
                          : scenario == "high"   ? 9
                                                 : fill ? 8 : 5;
    std::vector<Memop> now;
    for (unsigned j = 0; j < kNS; ++j) {
      if (!cred[j] || below(10) >= busy) continue;
      Memop m{j, {}};
      if (below(16) == 0) {
        m.pay.a1 = uint64_t(0xF) << kMemOpLsb;   // a bulk discard
        ++b.cov_discard;
      } else {
        m.pay.a1 = r() & ((1ull << kAW) - 1);
        if (((m.pay.a1 >> kMemOpLsb) & 0xF) == 0xF) m.pay.a1 &= ~(uint64_t(1) << kMemOpLsb);
        m.pay.hi = r() & ((1ull << kHW) - 1);
      }
      --cred[j];
      now.push_back(m);
    }
    // Frees: held entries, at most kNF a cycle, slot-heavy when draining.
    std::vector<unsigned> frees;
    std::vector<unsigned> cand;
    // Held, and not freed last cycle (the model takes that free now).
    const std::set<unsigned> pending(b.prev_f.begin(), b.prev_f.end());
    for (const auto &[e, p] : b.held)
      if (!pending.count(e)) cand.push_back(e);
    const unsigned pf = scenario == "idle" ? 0 : scenario == "medium" ? 2 : rnd ? (fill ? 1 : 6) : 5;
    if (!rnd || !fill || below(4) == 0) {
      const unsigned hot = below(kNS);
      for (unsigned e : cand)
        if (frees.size() < kNF && below(10) < pf && (!rnd || fill || e / kNC == hot || below(3) == 0))
          frees.push_back(e);
    }
    b.step(now, frees, rnd, r);
    for (unsigned j = 0; j < kNS; ++j)
      if ((b.dut->cr_cm02h >> j) & 1) ++cred[j];
  }
  if (rnd && (!b.cov_full || !b.cov_owed || !b.cov_discard || !b.cov_noise || !b.cov_four_free)) {
    std::fprintf(stderr, "mq: coverage: slot full %u, credits owed %u, discards %u, noise %u, 3+ frees a slot %u\n",
                 b.cov_full, b.cov_owed, b.cov_discard, b.cov_noise, b.cov_four_free);
    ++b.fails;
  }
  std::printf("mq%s %s: %llu cycles, %u values checked, %u mismatches: %s\n",
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
      if (ctl != "slot" && ctl != "discard") {
        std::fprintf(stderr, "mq: unknown control %s\n", ctl.c_str());
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "mq: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
