//===-- bank_slice_tb.cpp - rcu_bank_slice against a value model ---------===//
//
// Drives rtl/rcu/rcu_bank_slice.sv and holds it, every cycle, to a value
// model of the register file's rules (Register file tab; the RCU model's
// commit(), sim/rcu/rcu_core.cpp): what each read port returns and what each
// write port leaves in the rows.
//
//   valid in t, row in t+1, a read's data and a write's data in t+2
//   (rcu_bank_slice.sv, "Port timing"); MW takes its valid with its lead,
//   in t+1. R0 and R1 (read ports 7 and 8): the R valid lead in t+1, the
//   row on the wire in t+2, the value in rsrc after t+2's edge. A read in
//   t+2 of a row written in t+2 sees the old value, but for R0/R1 of an MW
//   write (the write-through, on its lanes). --control nowt expects none:
//   the run must fail (test/rcu/run-rtl.sh).
//
// Written by LW (owned sections), SW and RW (secmask, or the whole row zero
// above the register under FULL_ROW), and MW (per MIU slot: the slot that
// covers the bank, its byte K - pos, a 4-bit load's low nibble). The bench
// keeps the module's input contract: one write a row a cycle, one load slot
// a bank (RA-28), rows named inside the pool or the zero register for
// reads and loads.
//
// Runs: directed cases, then random traffic (the bench's ordinary run, the
// high scenario). --cg <idle|medium|high> <vcd> runs one clock-gating
// scenario (tools/check-cg.py; docs/rtl-coding-style.md, "Local clock
// gating") and dumps the ports: idle is reset and then nothing; medium is
// work on about a third of the cycles; high is work every cycle. Inputs
// change only with a message. Exit 0 only with no mismatch.
//
// Built by test/rcu/cg-build.sh: BS_ROWS, BS_K, BS_FULL_ROW.
//===----------------------------------------------------------------------===//
#include "Vrcu_bank_slice.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <array>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <random>
#include <string>
#include <type_traits>
#include <vector>

#ifndef BS_ROWS
#define BS_ROWS 192
#endif
#ifndef BS_K
#define BS_K 0
#endif
#ifndef BS_FULL_ROW
#define BS_FULL_ROW 1
#endif


namespace {

constexpr unsigned kRows = BS_ROWS, kK = BS_K, kZero = 255;
constexpr bool kFullRow = BS_FULL_ROW != 0;
constexpr unsigned kNR = 10, kNW = 3, kNM = 4, kL = 4;
// Logical read ports 0-9 (L0-L3, M0-M2, R0-R2): R0 and R1 are the
// module's rr ports 0 and 1; the rest its rd ports, R2 at 7.
bool isRR(unsigned q) { return q == 7 || q == 8; }
unsigned rdIdx(unsigned q) { return q == 9 ? 7 : q; }
enum { kLW = 0, kSW = 1, kRW = 2 };

// ---- Port bits: plain integers and VlWide alike -----------------------
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

unsigned span(unsigned w) { return w == 0 ? 4 : w == 1 ? 2 : 1; }
unsigned secmask(unsigned w, unsigned pos) { return ((1u << span(w)) - 1u) << pos; }
bool covers(unsigned w, unsigned pos) { return (secmask(w, pos) >> kK) & 1u; }

// ---- Operations -------------------------------------------------------
struct Read { unsigned port, row; };
struct Write { unsigned port, row, sec; std::array<uint8_t, kL> dat; unsigned lm; };
struct Load { unsigned slot, row, w, pos, lm; std::array<uint32_t, kL> word; };
struct Cycle {   // what one cycle's valids started
  std::vector<Read> rd;
  std::vector<Write> wr;
  std::vector<Load> ld;
};

extern int g_argc;
extern char **g_argv;
extern bool g_nowt;   // --control nowt: expect no write-through (the run must fail)

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vrcu_bank_slice> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0;
  std::vector<std::array<uint8_t, kL>> row = std::vector<std::array<uint8_t, kL>>(kRows);
  std::vector<bool> known = std::vector<bool>(kRows, false);
  Cycle s1, s2;   // started one and two cycles ago
  // Coverage of the rules the random traffic must reach.
  unsigned cov_wt = 0;
  unsigned cov_read = 0, cov_zero = 0, cov_lw = 0, cov_lw_skip = 0, cov_zfill = 0, cov_mw = 0,
           cov_mw_nib = 0, cov_mw_shift = 0, cov_hold = 0, cov_same = 0;

  Bench(const char *vcd_path) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vrcu_bank_slice>(ctx.get());
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
  void fail(const char *fmt, unsigned a, unsigned b, unsigned c, unsigned d) {
    if (++fails <= 20) {
      std::fprintf(stderr, "bank_slice: cycle %llu: ", (unsigned long long)cyc);
      std::fprintf(stderr, fmt, a, b, c, d);
      std::fputc('\n', stderr);
    }
  }

  /// One cycle: `next` starts now (valids); s1's rows and s2's data go in.
  void step(const Cycle &next, bool rst = false) {
    dut->rcu_rst_r00h = rst;
    dut->rd_v_cr00h = 0;
    dut->wr_v_cr00h = 0;
    dut->rv_cr02h = 0;
    dut->mw_v_cr01h = 0;
    for (const Read &r : next.rd)
      if (!isRR(r.port)) put(dut->rd_v_cr00h, rdIdx(r.port), 1, 1);
    for (const Write &w : next.wr) put(dut->wr_v_cr00h, w.port, 1, 1);
    // Rows and leads, a cycle after the valid (R0, R1 and MW: with theirs).
    // Unused fields hold.
    for (const Read &r : s1.rd) {
      if (isRR(r.port)) {
        dut->rv_cr02h = 1;
      } else {
        put(dut->rd_row_cr01h, rdIdx(r.port) * 8, 8, r.row);
      }
    }
    for (const Load &l : s1.ld) put(dut->mw_v_cr01h, l.slot, 1, 1);
    for (const Read &r : s2.rd)
      if (isRR(r.port)) put(dut->rr_row_cr03h, (r.port - 7) * 8, 8, r.row);
    for (const Write &w : s1.wr) {
      put(dut->wr_row_cr01h, w.port * 8, 8, w.row);
      put(dut->wr_sec_cr01h, w.port * 4, 4, w.sec);
    }
    for (const Load &l : s1.ld) {
      put(dut->mw_row_cr01h, l.slot * 8, 8, l.row);
      put(dut->mw_wid_cr01h, l.slot * 2, 2, l.w);
      put(dut->mw_pos_cr01h, l.slot * 2, 2, l.pos);
      put(dut->mw_lm_cr01h, l.slot * kL, kL, l.lm);
    }
    // Data, two cycles after the valid.
    for (const Write &w : s2.wr) {
      for (unsigned l = 0; l < kL; ++l) put(dut->wr_dat_cr02h, w.port * 32 + 8 * l, 8, w.dat[l]);
      put(dut->wr_lm_cr02h, w.port * kL, kL, w.lm);
    }
    for (const Load &ld : s2.ld)
      for (unsigned l = 0; l < kL; ++l) put(dut->mw_dat_cr02h, (ld.slot * kL + l) * 32, 32, ld.word[l]);
    dut->rcu_core_clk = 0;
    eval();
    std::vector<std::pair<unsigned, std::array<unsigned, kL>>> rs_want;   // R0/R1: in rsrc after the edge
    if (!rst) {
      // s2's reads: the rows as they stand before this cycle's writes.
      for (const Read &r : s2.rd) {
        const bool zero = r.row == kZero;
        if (!zero && !known[r.row]) continue;
        ++cov_read;
        cov_zero += zero;
        for (unsigned l = 0; l < kL; ++l) {
          unsigned want = zero ? 0u : row[r.row][l];
          if (isRR(r.port)) {
            if (!zero && !g_nowt)
              for (const Load &ld : s2.ld) {
                const int b = loadByte(ld, l);
                if (ld.row == r.row && b >= 0) {
                  want = unsigned(b);
                  ++cov_wt;
                }
              }
            if (l == 0) rs_want.push_back({r.port - 7, {}});
            rs_want.back().second[l] = want;
            continue;
          }
          const unsigned got = unsigned(get(dut->rd_cr03h, rdIdx(r.port) * 32 + 8 * l, 8));
          if (got != want) fail("read port %u row %u lane %u: %02x", r.port, r.row, l, got);
        }
      }
      apply(s2);
    }
    dut->rcu_core_clk = 1;
    eval();
    for (const auto &[q, want] : rs_want)
      for (unsigned l = 0; l < kL; ++l) {
        const unsigned got = unsigned(get(dut->rs_cr04h, q * 32 + 8 * l, 8));
        if (got != want[l]) fail("rsrc R%u lane %u: %02x, want %02x", q, l, got, want[l]);
      }
    ++cyc;
    s2 = s1;
    s1 = next;
  }

  /// What a load writes in this slice on lane l: its byte, or -1 for none.
  static int loadByte(const Load &ld, unsigned l) {
    const bool cov = covers(ld.w, ld.pos);
    if (!(cov || kFullRow) || ld.row == kZero || !((ld.lm >> l) & 1u)) return -1;
    if (!cov) return 0;
    uint8_t b = uint8_t(ld.word[l] >> (8 * (kK - ld.pos)));
    if (ld.w == 3) b &= 0x0f;
    return b;
  }

  /// The write rules, at the edge ending a write's data cycle.
  void apply(const Cycle &c) {
    for (const Write &w : c.wr) {
      const bool mine = (w.sec >> kK) & 1u;
      const bool act = mine || (kFullRow && w.port != kLW);
      if (w.port == kLW) (mine ? cov_lw : cov_lw_skip)++;
      if (!act) continue;
      if (!mine) ++cov_zfill;
      for (unsigned l = 0; l < kL; ++l)
        if ((w.lm >> l) & 1u) row[w.row][l] = mine ? w.dat[l] : 0;
        else ++cov_hold;
      known[w.row] = known[w.row] || w.lm == 0xf;
    }
    for (const Load &ld : c.ld) {
      const bool cov = covers(ld.w, ld.pos);
      if (!(cov || kFullRow) || ld.row == kZero) continue;
      ++cov_mw;
      if (cov && ld.pos != 0) ++cov_mw_shift;
      if (cov && ld.w == 3) ++cov_mw_nib;
      for (unsigned l = 0; l < kL; ++l) {
        if (!((ld.lm >> l) & 1u)) { ++cov_hold; continue; }
        uint8_t b = 0;
        if (cov) {
          b = uint8_t(ld.word[l] >> (8 * (kK - ld.pos)));
          if (ld.w == 3) b &= 0x0f;
        }
        row[ld.row][l] = b;
      }
      known[ld.row] = known[ld.row] || ld.lm == 0xf;
    }
  }
};

// ---- Traffic ----------------------------------------------------------
struct Gen {
  std::mt19937 rng;
  explicit Gen(unsigned seed) : rng(seed) {}
  unsigned rnd(unsigned n) { return unsigned(rng() % n); }
  bool coin(double p) { return std::uniform_real_distribution<double>(0, 1)(rng) < p; }
  /// A legal (width, position): 32 bits at 0, 16 at 0 or 2, 8 and 4 anywhere.
  /// Weighted as kernels are: mostly 32-bit registers (60%), the rest
  /// narrow (16, 8 and 4 bits, 15% each, then 10%).
  void reg(unsigned &w, unsigned &pos) {
    const unsigned x = rnd(20);
    w = x < 12 ? 0 : x < 15 ? 1 : x < 18 ? 2 : 3;
    pos = w == 0 ? 0 : w == 1 ? 2 * rnd(2) : rnd(4);
  }
  /// One cycle's new operations, each port busy with probability p.
  Cycle cycle(double p) {
    Cycle c;
    std::vector<bool> taken(kRows, false);
    auto freeRow = [&]() {
      for (;;) {
        const unsigned r = rnd(kRows);
        if (!taken[r]) { taken[r] = true; return r; }
      }
    };
    for (unsigned q = 0; q < kNR; ++q)
      if (coin(p)) c.rd.push_back({q, coin(0.1) ? kZero : rnd(kRows)});
    for (unsigned q = 0; q < kNW; ++q) {
      if (!coin(p)) continue;
      Write w{q, freeRow(), 0, {}, 0xf};
      unsigned wd, pos;
      reg(wd, pos);
      w.sec = q == kLW && coin(0.5) ? 0xfu : secmask(wd, pos);
      for (auto &b : w.dat) b = uint8_t(rng());
      if (q == kLW && coin(0.2)) w.lm = rnd(16);   // the copy: inactive lanes only
      c.wr.push_back(w);
    }
    unsigned banks = 0;   // MIU's contract: one slot a bank (RA-28)
    for (unsigned j = 0; j < kNM; ++j) {
      if (!coin(p * 0.5)) continue;
      Load ld{j, coin(0.05) ? kZero : freeRow(), 0, 0, coin(0.8) ? 0xfu : rnd(16), {}};
      reg(ld.w, ld.pos);
      const unsigned m = kFullRow ? 0xfu : secmask(ld.w, ld.pos);
      if (banks & m) continue;
      banks |= m;
      for (auto &x : ld.word) x = uint32_t(rng());
      c.ld.push_back(ld);
    }
    // R0 or R1 on a row a load lands in: the write-through.
    for (Read &r : c.rd)
      if (isRR(r.port) && !c.ld.empty() && coin(0.5)) r.row = c.ld[rnd(unsigned(c.ld.size()))].row;
    return c;
  }
};

/// Directed cases from the Register file tab, each its own short sequence.
void directed(Bench &b) {
  const Cycle none;
  auto run = [&](const Cycle &c) {
    b.step(c);
    b.step(none);
    b.step(none);
  };
  const std::array<uint8_t, kL> d1{0x11, 0x22, 0x33, 0x44}, d2{0xa5, 0x5a, 0xc3, 0x3c};
  const unsigned r1 = 5 % kRows, r2 = 17 % kRows, r3 = (kRows - 1);
  // LW, all lanes, owned section K; then read it back on every port.
  run(Cycle{{}, {{kLW, r1, 1u << kK, d1, 0xf}}, {}});
  Cycle rd;
  for (unsigned q = 0; q < kNR; ++q) rd.rd.push_back({q, r1});
  run(rd);
  // LW not owning K writes nothing; the copy's lane mask keeps lanes.
  run(Cycle{{}, {{kLW, r1, 0xfu & ~(1u << kK), d2, 0xf}}, {}});
  run(Cycle{{}, {{kLW, r1, 1u << kK, d2, 0x5}}, {}});
  run(Cycle{{{0, r1}}, {}, {}});
  // SW and RW outside K: nothing, or zero under FULL_ROW.
  run(Cycle{{}, {{kSW, r2, 0xf, d1, 0xf}, {kRW, r3, 0xf, d2, 0xf}}, {}});
  run(Cycle{{}, {{kSW, r2, 0xfu & ~(1u << kK), d2, 0xf}}, {}});
  run(Cycle{{{1, r2}, {2, r3}}, {}, {}});
  // The zero register reads 0.
  run(Cycle{{{3, kZero}}, {}, {}});
  // Loads: a 16-bit and a 4-bit one at positions covering K, and a slot
  // that does not cover it.
  const unsigned p16 = kK >= 2 ? 2 : 0;
  run(Cycle{{}, {}, {{1, r2, 1, p16, 0xf, {0x12345678u, 0x9abcdef0u, 0x0f1e2d3cu, 0x4b5a6978u}}}});
  run(Cycle{{{4, r2}}, {}, {}});
  run(Cycle{{}, {}, {{3, r2, 3, kK, 0xf, {0xffu, 0xa7u, 0x3cu, 0x81u}}}});
  run(Cycle{{{5, r2}}, {}, {}});
  run(Cycle{{}, {}, {{2, r3, 2, (kK + 1) % 4, 0xf, {1, 2, 3, 4}}}});
  run(Cycle{{{6, r3}}, {}, {}});
  // A read and a write of one row in one cycle: the read sees the old value.
  b.step(Cycle{{}, {{kRW, r1, 0xf, d1, 0xf}}, {}});
  b.step(none);
  b.step(Cycle{{{7, r1}}, {}, {}});
  b.step(none);
  b.step(none);
  b.cov_same++;
}

int g_argc;
char **g_argv;
bool g_nowt = false;

int run(const std::string &scenario, const char *vcd) {
  Bench b(vcd);
  const Cycle none;
  for (int i = 0; i < 8; ++i) b.step(none, true);
  b.step(none);   // the flopped reset (RST-1) falls a cycle after its input
  Gen g(0xcc5eed + kK);
  if (scenario.empty()) directed(b);
  const unsigned n = scenario == "idle" ? 3000 : 4000;
  for (unsigned i = 0; i < n; ++i) {
    Cycle c;
    if (scenario == "medium") c = i % 3 == 0 ? g.cycle(0.8) : none;
    else if (scenario != "idle") c = g.cycle(0.9);
    b.step(c);
  }
  b.step(none);
  b.step(none);
  if (scenario != "idle" && (!b.cov_read || !b.cov_zero || !b.cov_lw || !b.cov_lw_skip || !b.cov_mw ||
                             !b.cov_mw_nib || !b.cov_mw_shift || !b.cov_hold || (kFullRow && !b.cov_zfill))) {
    std::fprintf(stderr, "bank_slice: coverage: read %u zero %u lw %u lw_skip %u zfill %u mw %u nib %u shift %u hold %u\n",
                 b.cov_read, b.cov_zero, b.cov_lw, b.cov_lw_skip, b.cov_zfill, b.cov_mw, b.cov_mw_nib,
                 b.cov_mw_shift, b.cov_hold);
    ++b.fails;
  }
  if (scenario != "idle" && !g_nowt && !b.cov_wt) {
    std::fprintf(stderr, "bank_slice: coverage: no write-through\n");
    ++b.fails;
  }
  std::printf("bank_slice: rows %u K %u full_row %d%s %s: %llu cycles, %u reads checked, %u mismatches: %s\n",
              kRows, kK, int(kFullRow), g_nowt ? ", control nowt:" : "", scenario.empty() ? "directed+random" : scenario.c_str(),
              (unsigned long long)b.cyc, b.cov_read, b.fails, b.fails ? "FAIL" : "PASS");
  return b.fails ? 1 : 0;
}

} // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string scenario;
  const char *vcd = nullptr;
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control") && !std::strcmp(argv[i + 1], "nowt")) g_nowt = true;
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "bank_slice: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd);
}
