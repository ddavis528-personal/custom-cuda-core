//===-- pair_tb.cpp - miu_pair bench: each address paired with its memop ---===//
//
// Drives ccv_ooe_miu_memop's four slots as OOE does: each cycle a set of
// memops with disjoint pipe footprints (one 32-bit, two 16-bit, four 8-bit,
// or a mix), each on a slot of its own footprint, and now and then a bulk
// discard (pipes 0) on a slot no memop takes; the valid at M, the payload's
// pipes a cycle on, with the MQ entry miu_mq would allocate it. In random
// mode the payload wires carry noise in every other cycle, which the module
// must not keep. miu_mq's read port is a value model: the A1 fields it
// answers for entry e are a hash of e, read from whatever entry re names.
// Checks, every cycle, against a value model of the contract (the address
// lands on the memop's lead pipe, ctz(pipes), LAG cycles after the memop):
// re a cycle after V names the memop's entry on its lead pipe's slot, and
// from H the slot's A1 valid, and its entry and fields under the valid.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle is reset and no memop, the wires still; medium
// memops on about a third of the cycles; high nearly every cycle; the
// payload's wires change only with a memop. --control arrival models the
// pairing on the memop's arrival slot instead of its lead pipe, and
// --control lag one cycle late; each must fail.
//===----------------------------------------------------------------------===//
#include "Vmiu_pair.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <deque>
#include <memory>
#include <random>
#include <string>
#include <vector>

namespace {

constexpr unsigned kNS = 4, kLAG = 3, kNE = 40, kEW = 6, kFW = 63;

int g_argc;
char **g_argv;

// The transfer's decode of an A1 view (miu_pair's a1x): {b2, b4, sh2, sh1}.
// Fields LSB first: xfer_signed 0, xfer_size 1-2, ..., scale_en 15, ...,
// chwidth 49-50 (mq_tb's static_asserts hold the payload's layout).
unsigned xferOf(uint64_t f) {
  const unsigned xs = unsigned(f >> 1) & 3u, cw = unsigned(f >> 49) & 3u, se = unsigned(f >> 15) & 1u;
  const unsigned nb = xs == 1 ? 1u : xs == 2 ? 2u : cw == 0 ? 4u : cw == 1 ? 2u : 1u;
  const unsigned b4 = nb == 4, b2 = nb == 2;
  return b2 << 3 | b4 << 2 | (se & b4) << 1 | (se & b2);
}

/// What miu_mq holds in entry e's A1 view: kFW bits, a hash of e.
uint64_t fieldsOf(unsigned e) {
  uint64_t x = 0x9e3779b97f4a7c15ull * (e + 1);
  x ^= x >> 29;
  x *= 0xbf58476d1ce4e5b9ull;
  x ^= x >> 32;
  return x & ((1ull << kFW) - 1);
}

/// kFW bits at bit offset o of a Verilator wide signal, and their write.
template <class W> uint64_t getBits(const W &w, unsigned o) {
  uint64_t v = 0;
  for (unsigned b = 0; b < kFW; ++b) v |= uint64_t((w[(o + b) / 32] >> ((o + b) % 32)) & 1) << b;
  return v;
}
template <class W> void putBits(W &w, unsigned o, uint64_t v) {
  for (unsigned b = 0; b < kFW; ++b) {
    const unsigned i = (o + b) / 32, s = (o + b) % 32;
    w[i] = (w[i] & ~(1u << s)) | (uint32_t((v >> b) & 1) << s);
  }
}

struct Memop {
  unsigned slot = 0, pipes = 0, entry = 0;   // pipes 0: a bulk discard
};

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vmiu_pair> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  unsigned cov_quad = 0, cov_off_lead = 0, cov_bulk = 0, cov_b2b = 0, cov_noise = 0;
  unsigned cov_x = 0;   // the transfer decodes seen, a bit each (5 can occur)
  std::string control;
  // Memops by the cycle of their valid, the newest at the back.
  std::deque<std::vector<Memop>> hist;
  bool prev_a1[kNS] = {};   // slot k paired last cycle

  Bench(const char *vcd_path, std::string ctl) : control(std::move(ctl)) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vmiu_pair>(ctx.get());
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
    // miu_mq's held view: each entry's A1 fields, fixed for the run.
    for (unsigned e = 0; e < kNE; ++e) putBits(dut->mqa_cm02h, e * kFW, fieldsOf(e));
    dut->rst_n = 0;
    dut->mv_cm00h = 0;
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();   // the flopped reset releases a cycle on (RST-1)
  }
  /// The memop whose address the model pairs on slot k from the memops
  /// whose valid was at cycle M (lead pipe; --control arrival: arrival slot).
  const Memop *pairOn(const std::vector<Memop> &at, unsigned k) const {
    for (const Memop &m : at) {
      if (!m.pipes) continue;
      const unsigned s = control == "arrival" ? m.slot : unsigned(__builtin_ctz(m.pipes));
      if (s == k) return &m;
    }
    return nullptr;
  }
  /// One cycle: the memops whose valid is now, the payload wires (pipes and
  /// entries a slot), then the edge and the checks of what it captured.
  void step(const std::vector<Memop> &now, uint32_t mp, uint32_t me) {
    uint32_t mv = 0;
    for (const Memop &m : now) mv |= 1u << m.slot;
    dut->mv_cm00h = mv;
    dut->mp_cm01h = mp;
    dut->me_cm01h = me;
    edge();
    hist.push_back(now);
    if (hist.size() > 8) hist.pop_front();
    // Visible now: cycle c + 1, c the cycle just ended. The A1 slot (stage
    // 05) belongs to the memops whose valid was at M = c + 1 - 5. --control
    // lag: a cycle later.
    const unsigned late = control == "lag" ? 1 : 0;
    const size_t n = hist.size();
    // hist.back() is cycle c; cycle c - d is hist[n - 1 - d].
    auto at = [&](unsigned d) -> const std::vector<Memop> * {
      return d < n ? &hist[n - 1 - d] : nullptr;
    };
    const std::vector<Memop> *a1_m = at(kLAG + 1 + late);   // M = c + 1 - (LAG + 2)
    for (unsigned k = 0; k < kNS; ++k) {
      const Memop *m = a1_m ? pairOn(*a1_m, k) : nullptr;
      ++checked;
      const bool v = (dut->a1v_cm05h >> k) & 1;
      if (v != bool(m) && ++fails <= 20)
        std::fprintf(stderr, "pair: cycle %llu: a1v[%u] %d, want %d\n",
                     (unsigned long long)cyc, k, int(v), int(bool(m)));
      // The A1 entry and fields are a guarded payload: checked under the
      // valid only (the cycle the valid clears may load anything).
      if (!m) continue;
      cov_off_lead += m->slot != k;
      cov_b2b += prev_a1[k];
      ++checked;
      const unsigned e = (dut->a1e_cm05h >> (k * kEW)) & ((1u << kEW) - 1);
      const uint64_t f = fieldsOf(m->entry);
      const unsigned x = unsigned(dut->a1x_cm05h >> (k * 4)) & 0xfu;
      // miu_lead's copies, one per lane quarter (MA rev 203): {sh2, sh1, disp[15:0]}, disp
      // at bit 16 of the view.
      bool qok = true;
      for (unsigned q = 0; q < 4; ++q) {
        const unsigned o = (k * 4 + q) * 18;
        unsigned v = 0;
        for (unsigned b = 0; b < 18; ++b) v |= ((dut->a1q_cm05h[(o + b) / 32] >> ((o + b) % 32)) & 1u) << b;
        qok = qok && v == ((x & 3u) << 16 | unsigned(f >> 16) & 0xffffu);
      }
      const bool ok = e == m->entry && getBits(dut->a1f_cm05h, k * kFW) == f && x == xferOf(f) && qok;
      cov_x |= 1u << x;
      if (!ok && ++fails <= 20)
        std::fprintf(stderr, "pair: cycle %llu: slot %u's A1 entry %u, want %u%s\n",
                     (unsigned long long)cyc, k, e, m->entry, e == m->entry ? " (fields differ)" : "");
    }
    for (unsigned k = 0; k < kNS; ++k) prev_a1[k] = a1_m && pairOn(*a1_m, k);
  }
};

struct Gen {
  std::mt19937_64 r;
  explicit Gen(uint64_t seed) : r(seed) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
  /// A cycle's memops: disjoint footprints over the four pipes, each on a
  /// slot of its own footprint, and maybe a bulk discard on a free slot.
  std::vector<Memop> cycle(unsigned busy) {
    std::vector<Memop> v;
    if (!busy) return v;
    // Split the pipes into a 32-bit footprint, two 16-bit halves or 8-bit
    // quarters, each half taking one memop or none.
    std::vector<unsigned> feet;
    const unsigned shape = below(4);
    if (shape == 0) feet = {0xF};
    else if (shape == 1) feet = {0x3, 0xC};
    else if (shape == 2) feet = {0x1, 0x2, 0x4, 0x8};
    else feet = {0x3, 0x4, 0x8};
    unsigned used = 0;
    for (unsigned f : feet) {
      if (below(4) == 0) continue;
      unsigned sl;
      do sl = below(kNS); while (!((f >> sl) & 1));
      v.push_back({sl, f, below(kNE)});
      used |= 1u << sl;
    }
    if (below(16) == 0 && used != 0xF) {
      unsigned sl;
      do sl = below(kNS); while ((used >> sl) & 1);
      v.push_back({sl, 0, 0});
    }
    return v;
  }
};

int run(const std::string &scenario, const char *vcd, const std::string &ctl) {
  Bench b(vcd, ctl);
  Gen g(0x9a1);
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 50000 : scenario == "idle" ? 3000 : 4000;
  uint32_t mp = 0, me = 0;
  std::vector<Memop> prev;   // last cycle's memops: their payload goes on the wire now
  for (unsigned i = 0; i < n; ++i) {
    const bool busy = scenario == "idle"     ? false
                      : scenario == "medium" ? (i % 3 == 0 && g.below(10) < 8)
                      : scenario == "high"   ? g.below(10) < 9
                                             : (i / 64) % 2 ? g.below(10) < 9 : g.below(4) == 0;
    // Wires: each slot whose memop's valid was last cycle carries its
    // payload; any other slot holds still, or carries noise in random mode.
    for (unsigned j = 0; j < kNS; ++j) {
      const Memop *m = nullptr;
      for (const Memop &x : prev)
        if (x.slot == j) m = &x;
      if (m) {
        mp = (mp & ~(0xFu << (4 * j))) | (m->pipes << (4 * j));
        me = (me & ~(0x3Fu << (kEW * j))) | (m->entry << (kEW * j));
      } else if (rnd && g.below(2)) {
        mp = (mp & ~(0xFu << (4 * j))) | (g.below(16) << (4 * j));
        me = (me & ~(0x3Fu << (kEW * j))) | (g.below(64) << (kEW * j));
        ++b.cov_noise;
      }
    }
    std::vector<Memop> now = g.cycle(busy);
    unsigned leads = 0;
    for (const Memop &m : now) {
      if (m.pipes) ++leads;
      b.cov_bulk += !m.pipes;
    }
    b.cov_quad += leads == 4;
    b.step(now, mp, me);
    prev = now;
  }
  if (rnd && b.cov_x != 0x0351u) {
    std::fprintf(stderr, "pair: coverage: transfer decodes %04x, want 0351\n", b.cov_x);
    ++b.fails;
  }
  if (rnd && (!b.cov_quad || !b.cov_off_lead || !b.cov_bulk || !b.cov_b2b || !b.cov_noise)) {
    std::fprintf(stderr, "pair: coverage: four memops %u, off their lead %u, bulk %u, back to back %u, noise %u\n",
                 b.cov_quad, b.cov_off_lead, b.cov_bulk, b.cov_b2b, b.cov_noise);
    ++b.fails;
  }
  std::printf("pair%s %s: %llu cycles, %u values checked, %u mismatches: %s\n",
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
      if (ctl != "arrival" && ctl != "lag") {
        std::fprintf(stderr, "pair: unknown control %s\n", ctl.c_str());
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "pair: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
