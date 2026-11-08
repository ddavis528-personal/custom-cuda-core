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
// L0-L3 and M0-M2 come from the issue slots (P2): the bench encodes each
// read as the S (P) slot owning section K, its rows on the sources the
// port reads (M: the memop's base, index and data sources, an opcode that
// has them, test/rcu/dec_tb.h), beside leads elsewhere, the owner's
// continuations, and idle slots whose stale payload claims K. --control
// lown puts the L rows on slot 0, msrc the M rows on src slot = port: the
// run must fail.
//
// Written by LW (owned sections), SW and RW (secmask, or the whole row zero
// above the register under FULL_ROW), and MW (per MIU slot: the slot that
// covers the bank, its byte K - pos, a 4-bit load's low nibble). The bench
// keeps the module's input contract: one write a row a cycle, one load slot
// a bank (RA-28), rows named inside the pool or the zero register for
// reads and loads.
//
// Migration (rcu_mig) beside the R op on R2 and RW: R2 is the R op's when
// its lead and its decode (of its opcode and merge_en) say it reads R2, else migration's under
// migration's lead; RW writes the restore's row, every lane and section,
// when migration's lead and its decision (gw_sel) say so, the R op's write
// ignored, else the R op's. The traffic covers each mix: R alone, migration
// alone, both with the R op first on R2, the R op's lead with no R2 use
// beside migration's read, a restore write beside the R op's lead, and
// migration's RW lead with no decision beside an R op write or none.
// --control rfirst expects migration's row on R2 when both read: the run
// must fail.
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
#include <tuple>
#include <type_traits>
#include <vector>

#include "dec_tb.h"

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
// R2 (port 9): rlead the R op's lead, ruse its decode (it reads R2), mig
// migration's lead; `row` is the row the port reads, `other` the row the
// source that loses names.
struct Read { unsigned port, row; bool rlead = true, ruse = true, mig = false; unsigned other = 0; };
// RW (port 2): rlead the R op's lead, mig migration's lead, gsel its
// decision (the restore writes `row`, every lane, the R op's `other` row
// ignored); with mig and no gsel the R op writes `row` if rlead, else
// nothing.
struct Write {
  unsigned port, row, sec;
  std::array<uint8_t, kL> dat;
  unsigned lm;
  bool rlead = true, mig = false, gsel = false;
  unsigned other = 0;
};
struct Load { unsigned slot, row, w, pos, lm; std::array<uint32_t, kL> word; };
// An S or P slot of the issue channel as the slice reads it (P2): valid,
// continuation, footprint, its three source rows (phys_src[15:8], [7:0],
// phys_src2), phys_old_dst (S) or opcode and done_row (P). `drive` false:
// the payload holds (an idle slot).
struct Slot {
  bool v = false, cont = false, drive = false;
  unsigned foot = 0, src[3]{}, odst = 0, opc = 0, drw = 0;
};
struct Cycle {   // what one cycle's valids started
  std::vector<Read> rd;
  std::vector<Write> wr;
  std::vector<Load> ld;
  std::array<Slot, 4> ss{}, ps{};   // filled by Bench::encode
};

// The memops that read each set of M ports (bit i: M0 base, M1 index, M2
// data), each source on its own src slot: (opcode, done_row).
struct MemOps {
  std::array<std::vector<std::pair<unsigned, unsigned>>, 8> by;
  MemOps() {
    for (unsigned drw = 0; drw < 4; ++drw)
      for (unsigned c : dectb::allOpcodes()) {
        dectb::R::OpClass oc;
        if (!dectb::classOf(c, drw, false, oc) || oc.unit != dectb::R::Unit::Mem) continue;
        const int src[3] = {oc.base_src, oc.index_src, oc.data_src};
        for (unsigned m = 1; m < 8; ++m) {
          bool ok = true;
          unsigned used = 0;
          for (unsigned i = 0; i < 3; ++i)
            if ((m >> i) & 1u) {
              if (src[i] < 0 || ((used >> src[i]) & 1u)) ok = false;
              else used |= 1u << src[i];
            }
          if (ok) by[m].push_back({c, drw});
        }
      }
    if (by[1].empty() || by[3].empty() || by[5].empty()) {
      std::fprintf(stderr, "bank_slice: no memop reads base, base and index, or base and data\n");
      std::exit(2);
    }
  }
  int src(unsigned opc, unsigned drw, unsigned i) const {
    dectb::R::OpClass oc;
    dectb::classOf(opc, drw, false, oc);
    return i == 0 ? oc.base_src : i == 1 ? oc.index_src : oc.data_src;
  }
};
const MemOps &memOps() {
  static const MemOps m;
  return m;
}

extern int g_argc;
extern char **g_argv;
extern bool g_nowt;   // --control nowt: expect no write-through (the run must fail)
extern bool g_rfirst; // --control rfirst: expect migration's row on R2 beside the R op's (must fail)
extern std::string g_ctl;   // --control lown|msrc: the L rows on slot 0, the M rows by port (must fail)

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
  unsigned cov_m2 = 0, cov_m2r = 0, cov_m2n = 0, cov_mrw = 0, cov_mrwr = 0, cov_mrwn = 0;
  unsigned cov_lown[4]{}, cov_mown[4]{}, cov_stale = 0, cov_cont = 0;
  std::mt19937 erng{0x5107u + kK};
  unsigned erow() { return unsigned(erng() % kRows); }

  /// The issue slots for c's L and M reads (P2): an owner of section K
  /// among slots 0..K, the rest leads elsewhere, continuations of the
  /// owner, idle, or idle with a stale payload that would claim K.
  void encode(Cycle &c) {
    unsigned lrow[4], mrow[3], lm = 0, mm = 0;
    for (const Read &r : c.rd) {
      if (r.port < 4) lrow[r.port] = r.row, lm |= 1u << r.port;
      else if (r.port < 7) mrow[r.port - 4] = r.row, mm |= 1u << (r.port - 4);
    }
    auto fill = [&](std::array<Slot, 4> &sl, bool own, bool mem) {
      const unsigned o = own ? unsigned(erng() % (kK + 1)) : 4;
      unsigned ofoot = 0;
      if (own) {
        ofoot = (1u << o) | (1u << kK);
        for (unsigned b = o + 1; b < 4; ++b)
          if (erng() % 4 == 0) ofoot |= 1u << b;
      }
      for (unsigned j = 0; j < 4; ++j) {
        Slot &x = sl[j];
        x = Slot{};
        for (auto &r : x.src) r = erow();
        x.odst = erow();
        if (mem) {
          const auto &any = memOps().by[1];
          std::tie(x.opc, x.drw) = any[erng() % any.size()];
        }
        if (j == o) {
          x.v = x.drive = true;
          x.foot = ofoot;
        } else if ((ofoot >> j) & 1u) {   // inside the owner's footprint: its continuation
          x.v = x.drive = erng() % 2;
          x.cont = true;
          x.foot = erng() % 16;
          cov_cont += x.v;
        } else if (j != kK && erng() % 3 == 0) {   // a lead elsewhere
          x.v = x.drive = true;
          x.foot = 1u << j;
        } else if (erng() % 3 == 0) {   // idle, its stale payload claiming K
          x.drive = true;
          x.foot = (1u << j) | (j <= kK ? 1u << kK : 0u);
          cov_stale += j <= kK;
        }
      }
      return o;
    };
    const unsigned so = fill(c.ss, lm != 0 || erng() % 4 == 0, false);
    if (so < 4) {
      Slot &x = c.ss[g_ctl == "lown" ? 0 : so];
      if (lm) ++cov_lown[so];
      for (unsigned i = 0; i < 3; ++i)
        if ((lm >> i) & 1u) x.src[i] = lrow[i];
      if (lm & 8u) x.odst = lrow[3];
    }
    const unsigned po = fill(c.ps, mm != 0 || erng() % 4 == 0, true);
    if (po < 4 && mm) {
      Slot &x = c.ps[po];
      ++cov_mown[po];
      const auto &ops = memOps().by[mm];
      if (ops.empty()) {
        std::fprintf(stderr, "bank_slice: no memop reads M ports %x\n", mm);
        std::exit(2);
      }
      std::tie(x.opc, x.drw) = ops[erng() % ops.size()];
      for (unsigned i = 0; i < 3; ++i)
        if ((mm >> i) & 1u) x.src[g_ctl == "msrc" ? i : unsigned(memOps().src(x.opc, x.drw, i))] = mrow[i];
    }
  }

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
  // The R op's opcode and merge_en, which the slice decodes to "reads R2"
  // (merge_en and a GPR destination; test/rcu/dec_tb.h); salt picks among
  // the opcodes, and among the ways not to read R2.
  void rOp(bool ruse, unsigned salt) {
    using dectb::R::OpClass;
    using dectb::R::Unit;
    auto isR = [](const OpClass &oc) { return oc.unit == Unit::ROnly || oc.unit == Unit::Coll; };
    static const dectb::OpPool gd("an R op writing a GPR", 0, [&](const OpClass &oc) { return isR(oc) && oc.gdst; });
    static const dectb::OpPool ng("an R op writing no GPR", 0, [&](const OpClass &oc) { return isR(oc) && !oc.gdst; });
    const bool g = ruse || (salt & 1u);
    const auto &ops = g ? gd.ops : ng.ops;
    dut->ropc_cr01h = ops[(salt >> 1) % ops.size()];
    dut->rmrg_cr01h = ruse || (!g && (salt & 2u));
  }

  void step(const Cycle &next_in, bool rst = false) {
    Cycle next = next_in;
    encode(next);
    dut->rst_n = !rst;
    dut->sv_cr00h = 0;
    dut->pv_cr00h = 0;
    dut->r2v_cr00h = 0;
    dut->wr_v_cr00h = 0;
    dut->rv_cr02h = 0;
    dut->mw_v_cr01h = 0;
    dut->g2_v_cr00h = 0;
    dut->gw_v_cr00h = 0;
    dut->ropc_cr01h = 0;
    dut->rmrg_cr01h = 0;
    dut->gw_sel_cr01h = 0;
    for (unsigned j = 0; j < 4; ++j) {
      put(dut->sv_cr00h, j, 1, next.ss[j].v);
      put(dut->pv_cr00h, j, 1, next.ps[j].v);
    }
    for (const Read &r : next.rd)
      if (r.port == 9) {
        if (r.rlead) dut->r2v_cr00h = 1;
        if (r.mig) dut->g2_v_cr00h = 1;
      }
    for (unsigned j = 0; j < 4; ++j) {
      const Slot &x = s1.ss[j], &y = s1.ps[j];
      if (x.drive) {
        put(dut->scont_cr01h, j, 1, x.cont);
        put(dut->sfoot_cr01h, 4 * j, 4, x.foot);
        for (unsigned i = 0; i < 3; ++i) put(dut->ssrc_cr01h, (j * 3 + i) * 8, 8, x.src[i]);
        put(dut->sodst_cr01h, 8 * j, 8, x.odst);
      }
      if (y.drive) {
        put(dut->pcont_cr01h, j, 1, y.cont);
        put(dut->pfoot_cr01h, 4 * j, 4, y.foot);
        for (unsigned i = 0; i < 3; ++i) put(dut->psrc_cr01h, (j * 3 + i) * 8, 8, y.src[i]);
        put(dut->popc_cr01h, 9 * j, 9, y.opc);
        put(dut->pdrw_cr01h, 2 * j, 2, y.drw);
      }
    }
    for (const Write &w : next.wr) {
      if (w.rlead) put(dut->wr_v_cr00h, w.port, 1, 1);
      if (w.mig) dut->gw_v_cr00h = 1;
    }
    // Rows and leads, a cycle after the valid (R0, R1 and MW: with theirs).
    // Unused fields hold.
    for (const Read &r : s1.rd) {
      if (isRR(r.port)) {
        dut->rv_cr02h = 1;
      } else if (r.port == 9) {   // R2: the R op's row and migration's
        dut->r2row_cr01h = r.ruse ? r.row : r.other;
        dut->g2_row_cr01h = r.ruse ? r.other : r.row;
        rOp(r.ruse, r.row ^ r.other);
      }
    }
    for (const Load &l : s1.ld) put(dut->mw_v_cr01h, l.slot, 1, 1);
    for (const Read &r : s2.rd)
      if (isRR(r.port)) put(dut->rr_row_cr03h, (r.port - 7) * 8, 8, r.row);
    for (const Write &w : s1.wr) {
      if (w.port == kRW && w.mig && w.gsel) {   // the restore's row; the R op's ignored
        dut->gw_sel_cr01h = 1;
        dut->gw_row_cr01h = w.row;
        put(dut->wr_row_cr01h, w.port * 8, 8, w.other);
        put(dut->wr_sec_cr01h, w.port * 4, 4, w.sec ^ 0xf);
        continue;
      }
      put(dut->wr_row_cr01h, w.port * 8, 8, w.row);
      put(dut->wr_sec_cr01h, w.port * 4, 4, w.sec);
      if (w.mig) dut->gw_row_cr01h = w.other;
    }
    for (const Load &l : s1.ld) {
      put(dut->mw_row_cr01h, l.slot * 8, 8, l.row);
      put(dut->mw_wid_cr01h, l.slot * 2, 2, l.w);
      put(dut->mw_pos_cr01h, l.slot * 2, 2, l.pos);
      put(dut->mw_lm_cr01h, l.slot * kL, kL, l.lm);
    }
    // Data, two cycles after the valid.
    for (const Write &w : s2.wr) {
      if (w.port == kRW && w.mig && w.gsel) {   // the restore's data; the R op's lanes junk
        for (unsigned l = 0; l < kL; ++l) put(dut->gw_dat_cr02h, 8 * l, 8, w.dat[l]);
        for (unsigned l = 0; l < kL; ++l) put(dut->wr_dat_cr02h, w.port * 32 + 8 * l, 8, uint8_t(~w.dat[l]));
        put(dut->wr_lm_cr02h, w.port * kL, kL, 0);
        continue;
      }
      for (unsigned l = 0; l < kL; ++l) put(dut->wr_dat_cr02h, w.port * 32 + 8 * l, 8, w.dat[l]);
      put(dut->wr_lm_cr02h, w.port * kL, kL, w.lm);
      if (w.mig)
        for (unsigned l = 0; l < kL; ++l) put(dut->gw_dat_cr02h, 8 * l, 8, uint8_t(~w.dat[l]));
    }
    for (const Load &ld : s2.ld)
      for (unsigned l = 0; l < kL; ++l) put(dut->mw_dat_cr02h, (ld.slot * kL + l) * 32, 32, ld.word[l]);
    dut->rcu_core_clk = 0;
    eval();
    std::vector<std::pair<unsigned, std::array<unsigned, kL>>> rs_want;   // R0/R1: in rsrc after the edge
    if (!rst) {
      // s2's reads: the rows as they stand before this cycle's writes.
      for (const Read &r : s2.rd) {
        if (r.port == 9 && g_rfirst && r.ruse && r.mig) {   // the control: migration's row expected
          Read m = r;
          m.row = r.other;
          if (m.row != kZero && !known[m.row]) continue;
          for (unsigned l = 0; l < kL; ++l) {
            const unsigned want = m.row == kZero ? 0u : row[m.row][l];
            const unsigned got = unsigned(get(dut->rd_cr03h, rdIdx(r.port) * 32 + 8 * l, 8));
            if (got != want) fail("read port %u row %u lane %u: %02x", r.port, m.row, l, got);
          }
          continue;
        }
        const bool zero = r.row == kZero;
        if (!zero && !known[r.row]) continue;
        ++cov_read;
        if (r.port == 9 && r.mig) {
          ++cov_m2;
          cov_m2r += r.ruse;
          cov_m2n += r.rlead && !r.ruse;
        }
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
      if (w.port == kRW && w.mig) {
        if (w.gsel) {   // the restore: every lane, the whole row
          ++cov_mrw;
          cov_mrwr += w.rlead;
          for (unsigned l = 0; l < kL; ++l) row[w.row][l] = w.dat[l];
          known[w.row] = true;
          continue;
        }
        ++cov_mrwn;
        if (!w.rlead) continue;   // migration's lead and no decision: no write
      }
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
      // A shifted load (pos != 0) that still covers section K: none can at
      // K = 0, which only pos 0 covers, so the bin is required for K > 0.
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
    for (unsigned q = 0; q < kNR; ++q) {
      if (!coin(p)) continue;
      Read rd{q, coin(0.1) ? kZero : rnd(kRows)};
      if (q == 9 && coin(0.6)) {   // migration on R2: alone, beside the R op's read, or its unused lead
        const unsigned k = rnd(3);
        rd.mig = true;
        rd.rlead = k != 0;
        rd.ruse = k == 1;
        rd.other = coin(0.1) ? kZero : rnd(kRows);
      }
      c.rd.push_back(rd);
    }
    for (unsigned q = 0; q < kNW; ++q) {
      if (!coin(p)) continue;
      Write w{q, freeRow(), 0, {}, 0xf};
      unsigned wd, pos;
      reg(wd, pos);
      w.sec = q == kLW && coin(0.5) ? 0xfu : secmask(wd, pos);
      for (auto &b : w.dat) b = uint8_t(rng());
      if (q == kLW && coin(0.2)) w.lm = rnd(16);   // the copy: inactive lanes only
      if (q == kRW && coin(0.6)) {   // migration on RW
        const unsigned k = rnd(4);
        w.mig = true;
        w.gsel = k < 2;          // the restore writes: alone, or beside the R op's lead
        w.rlead = k == 1 || k == 2;   // or no decision: beside an R op write, or alone
        w.other = freeRow();
        if (w.gsel) w.lm = 0xf;
      }
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
  // LW and SW in the same cycle on every lane, each its own row and data
  // (an SFU op landing beside a lane op: SW writes sfu_result, LW result;
  // RA rev 120): each row holds its own port's bytes.
  run(Cycle{{}, {{kLW, r1, 1u << kK, d1, 0xf}, {kSW, r2, 1u << kK, d2, 0xf}}, {}});
  run(Cycle{{{0, r1}, {1, r2}}, {}, {}});
  // A 16-bit SFU op at position 2 (RA rev 124): sfu_result arrives steered,
  // SW's secmask is 1100; banks 2-3 take it, 0-1 keep their bytes, or take
  // zero under FULL_ROW.
  run(Cycle{{}, {{kSW, r2, 0xc, d1, 0xf}}, {}});
  run(Cycle{{{2, r2}}, {}, {}});
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
bool g_rfirst = false;
std::string g_ctl;

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
                             !b.cov_mw_nib || (kK > 0 && !b.cov_mw_shift) || !b.cov_hold || (kFullRow && !b.cov_zfill))) {
    std::fprintf(stderr, "bank_slice: coverage: read %u zero %u lw %u lw_skip %u zfill %u mw %u nib %u shift %u hold %u\n",
                 b.cov_read, b.cov_zero, b.cov_lw, b.cov_lw_skip, b.cov_zfill, b.cov_mw, b.cov_mw_nib,
                 b.cov_mw_shift, b.cov_hold);
    ++b.fails;
  }
  if (scenario != "idle" && (!b.cov_m2 || !b.cov_m2r || !b.cov_m2n || !b.cov_mrw || !b.cov_mrwr || !b.cov_mrwn)) {
    std::fprintf(stderr, "bank_slice: coverage: R2 migration %u beside R %u beside an unused lead %u; RW restore %u beside R's lead %u, no decision %u\n",
                 b.cov_m2, b.cov_m2r, b.cov_m2n, b.cov_mrw, b.cov_mrwr, b.cov_mrwn);
    ++b.fails;
  }
  {
    bool own = b.cov_stale && b.cov_cont;
    for (unsigned j = 0; j <= kK; ++j) own = own && b.cov_lown[j] && b.cov_mown[j];
    if (scenario != "idle" && !own) {
      std::fprintf(stderr, "bank_slice: coverage: L owners %u %u %u %u, M owners %u %u %u %u, stale %u, cont %u\n",
                   b.cov_lown[0], b.cov_lown[1], b.cov_lown[2], b.cov_lown[3], b.cov_mown[0], b.cov_mown[1],
                   b.cov_mown[2], b.cov_mown[3], b.cov_stale, b.cov_cont);
      ++b.fails;
    }
  }
  if (scenario != "idle" && !g_nowt && !b.cov_wt) {
    std::fprintf(stderr, "bank_slice: coverage: no write-through\n");
    ++b.fails;
  }
  std::printf("bank_slice: rows %u K %u full_row %d%s %s: %llu cycles, %u reads checked, %u mismatches: %s\n",
              kRows, kK, int(kFullRow), g_nowt ? ", control nowt:" : g_rfirst ? ", control rfirst:" : g_ctl.empty() ? "" : (", control " + g_ctl + ":").c_str(), scenario.empty() ? "directed+random" : scenario.c_str(),
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
    else if (!std::strcmp(argv[i], "--control") && !std::strcmp(argv[i + 1], "rfirst")) g_rfirst = true;
    else if (!std::strcmp(argv[i], "--control")) g_ctl = argv[i + 1];
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
