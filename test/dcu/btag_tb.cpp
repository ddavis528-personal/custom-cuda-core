//===-- btag_tb.cpp - dcu_btag bench: one bank's tag RFs and compare -------===//
//
// Drives one bank (BANK 0 at the unit's size) as the block does: each
// request slot's lead (its valid and lead_set_index's bank bits) on the
// channel's wires in H+1; each slot's set from its dcu_cap in D0, which
// dcu_cap captures every cycle (noise included) from the lead wires; each
// slot's line PA from its dcu_cap in D1, held from the payload a lookup
// brought until the next; and writes on the tag RFs' port, the lead a cycle
// ahead of the set and the words. Checks, every cycle, the result flops
// (hit, the way one-hot, its state and dirty) against a value model of the
// DCU model's tag lookup (sim/dcu/dcu_core.cpp, find()): the lowest slot
// whose lead names the bank reads the set's words at D0's edge, read before
// a write at the same edge; the words are compared with that slot's tag at
// D1; the result holds until the next lookup's.
// Random mode covers: several slots naming the bank in one cycle, hits in
// every way, misses on an invalid way with a matching tag, a write to the
// set being read at the same edge, back-to-back lookups and holds.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle is reset and no work; medium preloads the tags
// and then looks up on about a third of the cycles; high nearly every
// cycle; both hit about nine times in ten, as an L1 does. --control highest (the model picks the highest slot) and --control
// wbr (the model sees a same-edge write before the read) must fail.
//===----------------------------------------------------------------------===//
#include "Vdcu_btag.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>
#include <vector>

namespace {

constexpr unsigned kSlots = 4, kNB = 3, kWS = 9, kWays = 8, kWT = 32, kWE = kWT + 3;
constexpr unsigned kWL = 41, kNRF = 2, kWPR = 4, kWW = kWPR * kWE, kSets = 1u << (kWS - kNB);
constexpr unsigned kBank = 0;

struct Ent {
  uint32_t tag = 0;
  unsigned st = 0;   // 0 invalid
  bool dirty = false;
};
using Set = std::array<Ent, kWays>;

struct Res {
  bool hit = false;
  unsigned way = 0;   // one-hot
  unsigned st = 0;
  bool dirty = false;
  bool operator==(const Res &o) const {
    return hit == o.hit && way == o.way && st == o.st && dirty == o.dirty;
  }
};

/// One cycle's wires, as generated.
struct Wires {
  unsigned rv = 0;                  // a bit a slot
  std::array<uint32_t, kSlots> lsi{};   // the lead wires (bank bits included)
  std::array<uint64_t, kSlots> pa{};    // the payload wires' line PA
  unsigned twe = 0;                 // a bit an RF: a write's lead
  uint32_t twa = 0;                 // its set and words, on the wire a cycle on
  std::array<Set, 1> words{};       // the set's 8 ways, both RFs' words
};

template <class W> void setBits(W &w, unsigned lo, unsigned n, uint64_t v) {
  for (unsigned i = 0; i < n; ++i) {
    const unsigned b = lo + i;
    const uint32_t m = 1u << (b % 32);
    if ((v >> i) & 1) w[b / 32] |= m;
    else w[b / 32] &= ~m;
  }
}

int g_argc;
char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vdcu_btag> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  unsigned cov_multi = 0, cov_miss_inv = 0, cov_same_edge = 0, cov_b2b = 0, cov_hold = 0;
  std::array<unsigned, kWays> cov_way{};
  bool highest = false, wbr = false;

  // The value model.
  std::vector<Set> mem = std::vector<Set>(kSets);
  std::array<uint64_t, kSlots> hold{};   // each dcu_cap's held line PA
  Wires prev, prev2;                     // the wires one and two cycles back
  int pick1 = -1, pick2 = -1;            // the pick of the leads 1 and 2 cycles back
  Set rd{};                              // the words the last read took
  bool have = false;
  Res want{};

  Bench(const char *vcd_path, bool hi, bool wb) : highest(hi), wbr(wb) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vdcu_btag>(ctx.get());
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
    dut->dcu_core_clk = 0;
    eval();
    dut->dcu_core_clk = 1;
    eval();
    ++cyc;
  }
  void reset() {
    dut->rst_n = 0;
    dut->rv_cc01h = 0;
    dut->twe_cc05h = 0;
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();   // the flopped reset releases a cycle on (RST-1)
  }
  void fail(const char *what) {
    if (++fails <= 20) std::fprintf(stderr, "btag: cycle %llu: %s\n", (unsigned long long)cyc, what);
  }
  int pickOf(const Wires &w) const {
    int p = -1;
    for (unsigned s = 0; s < kSlots; ++s)
      if ((w.rv >> s & 1) && (w.lsi[s] & ((1u << kNB) - 1)) == kBank) {
        if (p < 0 || highest) p = int(s);
      }
    return p;
  }
  static uint64_t wordBits(const Set &x, unsigned r, unsigned k) {   // way r*4+k's entry
    const Ent &e = x[r * kWPR + k];
    return uint64_t(e.tag) | uint64_t(e.st) << kWT | uint64_t(e.dirty) << (kWT + 2);
  }

  /// One cycle: `w` is this cycle's wires; `noise` puts values on wires that
  /// carry nothing this cycle.
  void step(const Wires &w, uint64_t noise) {
    dut->rv_cc01h = w.rv;
    uint32_t lsb = 0;
    uint64_t lsi2 = 0;
    for (unsigned s = 0; s < kSlots; ++s) {
      lsb |= (w.lsi[s] & 7u) << (s * kNB);
      lsi2 |= uint64_t(prev.lsi[s]) << (s * kWS);   // dcu_cap holds last cycle's lead wires
    }
    dut->lsb_cc01h = lsb;
    dut->lsi_cc02h = lsi2;
    for (unsigned s = 0; s < kSlots; ++s) setBits(dut->pa_cc03h, s * kWL, kWL, hold[s]);
    dut->twe_cc05h = w.twe;
    // The write's set and words follow its lead by a cycle; noise otherwise.
    const bool wr = prev.twe != 0;
    dut->twa_cc06h = wr ? prev.twa : uint32_t(noise & (kSets - 1));
    for (unsigned r = 0; r < kNRF; ++r)
      for (unsigned k = 0; k < kWPR; ++k)
        setBits(dut->twd_cc06h, r * kWW + k * kWE, kWE,
                wr ? wordBits(prev.words[0], r, k) : (noise * (r * 4 + k + 1)) & ((uint64_t(1) << kWE) - 1));
    edge();

    // The model's edge: the read (pick of last cycle's leads, at the set its
    // dcu_cap held) before the write (lead last cycle, data this cycle).
    const int pk = pickOf(prev);
    auto doRead = [&] {
      if (pk >= 0) rd = mem[prev.lsi[pk] >> kNB];
    };
    auto doWrite = [&] {
      if (!wr) return;
      Set &x = mem[prev.twa];
      for (unsigned r = 0; r < kNRF; ++r)
        if (prev.twe >> r & 1)
          for (unsigned k = 0; k < kWPR; ++k) x[r * kWPR + k] = prev.words[0][r * kWPR + k];
    };
    // The compare: the read of two cycles' leads back, at this cycle's PA.
    if (pick1 >= 0) {
      const uint32_t tag = uint32_t(hold[pick1] >> kWS);
      Res r{};
      for (unsigned i = 0; i < kWays; ++i)
        if (rd[i].st && rd[i].tag == tag) {
          r.hit = true;
          r.way |= 1u << i;
          r.st |= rd[i].st;
          r.dirty |= rd[i].dirty;
          ++cov_way[i];
        } else if (!rd[i].st && rd[i].tag == tag) {
          ++cov_miss_inv;
        }
      cov_b2b += have && pick2 >= 0;
      want = r;
      have = true;
    } else if (have) {
      ++cov_hold;
    }
    if (pk >= 0 && wr && prev.twa == prev.lsi[pk] >> kNB) ++cov_same_edge;
    if (wbr) { doWrite(); doRead(); }
    else     { doRead(); doWrite(); }

    // dcu_cap's hold: a slot valid last cycle takes this cycle's payload.
    for (unsigned s = 0; s < kSlots; ++s)
      if (prev.rv >> s & 1) hold[s] = w.pa[s];
    pick2 = pick1;
    pick1 = pk;
    prev2 = prev;
    prev = w;

    if (!have) return;
    ++checked;
    Res got;
    got.hit = dut->hit_cc04h;
    got.way = dut->way_cc04h;
    got.st = dut->st_cc04h;
    got.dirty = dut->dty_cc04h;
    if (!(got == want)) {
      char m[160];
      std::snprintf(m, sizeof m, "result differs: got hit %d way %02x st %u dirty %d, want hit %d way %02x st %u dirty %d",
                    got.hit, got.way, got.st, got.dirty, want.hit, want.way, want.st, want.dirty);
      fail(m);
    }
  }
};

struct Gen {
  std::mt19937_64 r;
  std::array<uint32_t, 12> pool{};
  explicit Gen(uint64_t seed) : r(seed) {
    for (auto &p : pool) p = uint32_t(r());
  }
  unsigned below(unsigned n) { return unsigned(r() % n); }
  uint32_t tag() { return below(5) ? pool[below(unsigned(pool.size()))] : uint32_t(r()); }
  /// A set's 8 ways: no tag in two valid ways (a line is in one way).
  Set set() {
    Set x{};
    for (unsigned i = 0; i < kWays; ++i) {
      x[i].st = below(4) ? 1 + below(3) : 0;
      x[i].dirty = r() & 1;
      for (;;) {
        x[i].tag = pool[below(unsigned(pool.size()))];
        bool dup = false;
        for (unsigned j = 0; j < i; ++j) dup |= x[j].st && x[i].st && x[j].tag == x[i].tag;
        if (!dup) break;
      }
    }
    return x;
  }
};

int run(const std::string &scenario, const char *vcd, bool hi, bool wb) {
  Bench b(vcd, hi, wb);
  Gen g(0xb7a9);
  b.reset();
  const bool rnd = scenario.empty();
  // Preload every set, both RFs (random mode and the busy scenarios).
  if (scenario != "idle") {
    for (unsigned s = 0; s < kSets; ++s) {
      Wires w{};
      w.twe = 3;
      w.twa = s;
      w.words[0] = g.set();
      b.step(w, 0);
    }
    b.step(Wires{}, 0);
  }
  const unsigned n = rnd ? 60000 : scenario == "idle" ? 3000 : 4000;
  Wires last{};
  for (unsigned i = 0; i < n; ++i) {
    Wires w{};
    unsigned rate = scenario == "idle" ? 0 : scenario == "medium" ? (i % 3 == 0 ? 9 : 0)
                    : scenario == "high" ? 9 : ((i / 64) % 2 ? 9 : 3);
    for (unsigned s = 0; s < kSlots; ++s) {
      const bool v = g.below(10) < rate && (rnd || s == 0 || g.below(4) == 0);
      // A lookup names this bank half the time in random mode.
      const uint32_t set = g.below(kSets);
      const uint32_t bank = rnd ? (g.below(2) ? kBank : g.below(8)) : kBank;
      if (v) {
        w.rv |= 1u << s;
        w.lsi[s] = set << kNB | bank;
      } else {
        w.lsi[s] = rnd && g.below(2) ? g.below(512) : last.lsi[s];   // noise, or still
      }
      // The payload wire: the line PA a lookup led last cycle, its set's bits
      // agreeing with its lead; else noise or still.
      if (last.rv >> s & 1) {
        // The clock-gating scenarios look up as an L1 does, hitting about
        // nine times in ten, in whichever way holds the line; random mode
        // draws from the tag pool (hits, misses and invalid-way matches).
        uint32_t tag = g.tag();
        const Set &x = b.mem[last.lsi[s] >> kNB];
        if (!rnd && g.below(10) < 9) {
          const unsigned w0 = g.below(kWays);
          for (unsigned k = 0; k < kWays; ++k)
            if (x[(w0 + k) % kWays].st) { tag = x[(w0 + k) % kWays].tag; break; }
        }
        w.pa[s] = uint64_t(tag) << kWS | last.lsi[s];
      }
      else w.pa[s] = rnd && g.below(2) ? (g.r() & ((uint64_t(1) << kWL) - 1)) : last.pa[s];
    }
    if (rnd && __builtin_popcount(w.rv) > 1) {
      unsigned named = 0;
      for (unsigned s = 0; s < kSlots; ++s) named += (w.rv >> s & 1) && (w.lsi[s] & 7) == kBank;
      b.cov_multi += named > 1;
    }
    // Writes (random mode): to a set a lookup names now, often, so a write
    // and a read meet at one edge.
    if (rnd && g.below(6) == 0) {
      w.twe = 1 + g.below(3);
      w.twa = g.below(2) && b.prev.rv ? (b.prev.lsi[__builtin_ctz(b.prev.rv)] >> kNB) : g.below(kSets);
      // Keep a line in one way: the RF a write leaves alone keeps its ways.
      Set x = g.set();
      const Set &cur = b.mem[w.twa];
      for (unsigned r = 0; r < kNRF; ++r)
        if (!(w.twe >> r & 1))
          for (unsigned k = 0; k < kWPR; ++k) x[r * kWPR + k] = cur[r * kWPR + k];
      bool ok = true;
      for (unsigned i = 0; i < kWays; ++i)
        for (unsigned j = 0; j < i; ++j) ok &= !(x[i].st && x[j].st && x[i].tag == x[j].tag);
      if (!ok) w.twe = 0;
      w.words[0] = x;
    }
    // A write already in flight to the same set changes it a cycle on; a
    // second write to a set in the next cycle could pair with the first
    // RF's old ways, so writes do not come back to back.
    if (b.prev.twe) w.twe = 0;
    b.step(w, rnd ? g.r() : 0);
    last = w;
  }
  bool cov_ways = true;
  for (unsigned c : b.cov_way) cov_ways &= c > 0;
  if (rnd && (!b.cov_multi || !b.cov_miss_inv || !b.cov_same_edge || !b.cov_b2b || !b.cov_hold || !cov_ways)) {
    std::fprintf(stderr, "btag: coverage: several slots %u, invalid-way tag matches %u, same-edge writes %u, back to back %u, holds %u, every way hit %d\n",
                 b.cov_multi, b.cov_miss_inv, b.cov_same_edge, b.cov_b2b, b.cov_hold, cov_ways);
    ++b.fails;
  }
  const char *ctl = hi ? " control highest:" : wb ? " control wbr:" : ":";
  std::printf("btag%s %s: %llu cycles, %u values checked, %u mismatches: %s\n", ctl,
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
  bool hi = false, wb = false;
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control")) {
      if (!std::strcmp(argv[i + 1], "highest")) hi = true;
      else if (!std::strcmp(argv[i + 1], "wbr")) wb = true;
      else {
        std::fprintf(stderr, "btag: unknown control %s\n", argv[i + 1]);
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "btag: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, hi, wb);
}
