//===-- r_tb.cpp - rcu_r against a value model of the R pipe -------------===//
//
// Drives rtl/rcu/rcu_r.sv and holds it, cycle by cycle, to a value model of
// the R pipe (R unit tab; the RCU model's issueR, sim/rcu/rcu_core.cpp):
// what RW writes, what PR writes and what done slots 5 and 6 carry.
//
//   an op's valid and lead in t+1, A = t+2 (payload, R0 and R1 rows),
//   A+1 = t+3 (R2's row, active, RA, RB, rlow), A+2 = t+4 (the writes and the
//   done payload); an MIU slot's valid and lead in u+1, its data in u+2, forwarded to an R source in A = u+2 (rcu_r.sv, "Port timing").
//
// Every R kind, random fields, random bank rows; the MIU slots land at random
// with distinct rows, and an R source names a landing slot's register on
// about a third of its reads, so the forward is taken on its active lanes
// and the bank read on the rest. The bench keeps the module's input
// contract: one MIU slot a source, the predicate file's rlow the lowest lane
// of active, and a predicate-writing op has pred_we.
//
// Runs: random traffic (the bench's ordinary run). --cg <idle|medium|high>
// <vcd> runs one clock-gating scenario (tools/check-cg.py): idle is reset
// and then nothing; medium an op on about a third of the cycles; high one
// on most. Inputs change only with a message. --control <nofwd|retlow>
// expects a wrong rule (no MIU forward; ret's aux from the highest active
// lane): the run must fail (test/rcu/run-rtl.sh). Exit 0 only with no
// mismatch.
//===----------------------------------------------------------------------===//
#include "Vrcu_r.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <map>
#include <memory>
#include <random>
#include <string>
#include <type_traits>

namespace {

constexpr unsigned kN = 32, kNM = 4, kZero = 255, kPZero = 63;
enum Kind : unsigned { None, Bra, Call, Ret, Pand, Por, Pxor, Pmov, Movi, ShI, ShR, ShU, ShD, ShB,
                       VAny, VAll, Bal, Unb, kKinds };
const char *kName[kKinds] = {"none", "bra", "call", "ret", "pand", "por", "pxor", "pmov", "movi",
                             "shfl.idx.imm", "shfl.idx.reg", "shfl.up", "shfl.down", "shfl.bfly",
                             "vote.any", "vote.all", "ballot", "unballot"};

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

uint32_t em(unsigned w) { return w == 0 ? ~0u : (1u << (32u >> w)) - 1u; }
unsigned span(unsigned w) { return w == 0 ? 4 : w == 1 ? 2 : 1; }
unsigned secmask(unsigned w, unsigned pos) { return (((1u << span(w)) - 1u) << pos) & 15u; }
uint32_t align(uint32_t row, unsigned pos, unsigned w) { return (row >> (8 * pos)) & em(w); }
bool wg(unsigned k) { return k == Call || k == Movi || (k >= ShI && k <= ShB) || k == Bal; }
bool wp(unsigned k) { return (k >= Pand && k <= Pmov) || k == VAny || k == VAll || k == Unb; }
bool coll(unsigned k) { return (k >= ShI && k <= ShB) || k == VAny || k == VAll || k == Bal || k == Unb; }
bool isbr(unsigned k) { return k >= Bra && k <= Ret; }
bool uses0(unsigned k) { return k == Ret || (k >= ShI && k <= ShB) || k == Unb; }
bool uses1(unsigned k) { return k == ShR; }

struct Miu {   // one MIU slot landing
  unsigned row, pos, w;
  uint32_t am;
  std::array<uint32_t, kN> dat;
};
struct Op {
  unsigned kind, tag, drow, dst, dpos, dwid, opos, pd;
  unsigned src[2], spos[2], swid[2];
  bool mrg, pwe;
  uint32_t imask, imm, act, rpa, rpb;
  std::array<uint32_t, kN> rd[3];
  // The expected results.
  std::array<uint32_t, kN> wdat;
  uint32_t pval, pmm, bm, aux;
  bool bt;
  unsigned fwd_lanes;
};

extern int g_argc;
extern char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vrcu_r> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  std::map<uint64_t, Op> ops;                         // by valid cycle
  std::map<uint64_t, std::array<bool, kNM>> mvs;      // slots landing two cycles on, by valid cycle
  std::map<uint64_t, std::array<Miu, kNM>> mius;
  std::array<unsigned, kKinds> cov_kind{};
  unsigned cov_fwd = 0, cov_fwd_part = 0, cov_merge = 0, cov_shift = 0, cov_ret_multi = 0,
           cov_noact = 0;

  explicit Bench(const char *vcd_path) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vrcu_r>(ctx.get());
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
  void fail(const char *what, uint64_t got, uint64_t want, unsigned lane = 0) {
    if (++fails <= 20)
      std::fprintf(stderr, "rcu_r: cycle %llu: %s (lane %u): got %llx, want %llx\n",
                   (unsigned long long)cyc, what, lane, (unsigned long long)got, (unsigned long long)want);
  }
  void eq(const char *what, uint64_t got, uint64_t want, unsigned lane = 0) {
    ++checked;
    if (got != want) fail(what, got, want, lane);
  }
  const Op *op(uint64_t c) const {
    auto i = ops.find(c);
    return i == ops.end() ? nullptr : &i->second;
  }

  void drive(bool rst) {
    dut->rcu_rst_r00h = rst;
    const uint64_t c = cyc;
    dut->iv_cr01h = op(c - 1) != nullptr;   // the valid comes with the lead
    if (const Op *o = op(c - 1)) {   // the lead
      dut->lsu_cr01h = (uses0(o->kind) ? 1 : 0) | (uses1(o->kind) ? 2 : 0);
      put(dut->lsrc_cr01h, 0, 8, o->src[0]);
      put(dut->lsrc_cr01h, 8, 8, o->src[1]);
    }
    if (const Op *o = op(c - 2)) {   // A: the payload, R0 and R1
      dut->kind_cr02h = o->kind;
      dut->tag_cr02h = o->tag;
      dut->drow_cr02h = o->drow;
      dut->imask_cr02h = o->imask;
      dut->imm_cr02h = o->imm;
      dut->dst_cr02h = o->dst;
      dut->dpos_cr02h = o->dpos;
      dut->dwid_cr02h = o->dwid;
      dut->opos_cr02h = o->opos;
      dut->spos_cr02h = o->spos[0] | o->spos[1] << 2;
      dut->swid_cr02h = o->swid[0] | o->swid[1] << 2;
      dut->pd_cr02h = o->pd;
      dut->mrg_cr02h = o->mrg;
      dut->pwe_cr02h = o->pwe;
      for (unsigned l = 0; l < kN; ++l) {
        dut->rd0_cr02h[l] = o->rd[0][l];
        dut->rd1_cr02h[l] = o->rd[1][l];
      }
    }
    if (const Op *o = op(c - 3)) {   // A+1: R2 and the predicate file's flops
      for (unsigned l = 0; l < kN; ++l) dut->rd2_cr03h[l] = o->rd[2][l];
      dut->act_cr03h = o->act;
      dut->rpa_cr03h = o->rpa;
      dut->rpb_cr03h = o->rpb;
      dut->low_cr03h = o->act & (~o->act + 1u);
    }
    dut->mv_cr01h = 0;
    if (auto m = mvs.find(c - 1); m != mvs.end())
      for (unsigned j = 0; j < kNM; ++j)
        if (m->second[j]) {
          const Miu &s = mius[c - 1][j];
          put(dut->mv_cr01h, j, 1, 1);
          put(dut->mrow_cr01h, j * 8, 8, s.row);
          put(dut->mpos_cr01h, j * 2, 2, s.pos);
          put(dut->mam_cr01h, j * 32, 32, s.am);
        }
    if (auto m = mvs.find(c - 2); m != mvs.end())
      for (unsigned j = 0; j < kNM; ++j)
        if (m->second[j])
          for (unsigned l = 0; l < kN; ++l) dut->mdat_cr02h[j * kN + l] = mius[c - 2][j].dat[l];
  }

  void check() {
    const uint64_t c = cyc;
    const Op *o2 = op(c - 2), *o3 = op(c - 3), *o4 = op(c - 4);
    eq("rw_v", dut->rw_v_cr02h, o2 != nullptr);
    eq("pr_v", dut->pr_v_cr02h, o2 != nullptr);
    eq("dn_v", dut->dn_v_cr03h, o3 ? (coll(o3->kind) ? 2u : 1u) : 0u);
    if (o3) {
      eq("rw_row", dut->rw_row_cr03h, wg(o3->kind) ? o3->dst : kZero);
      eq("rw_sec", dut->rw_sec_cr03h, wg(o3->kind) ? secmask(o3->dwid, o3->dpos) : 0u);
      eq("pr_row", dut->pr_row_cr03h, wp(o3->kind) ? o3->pd : kPZero);
      eq("pr_mrg", dut->pr_mrg_cr03h, o3->mrg);
    }
    if (o4) {
      eq("dn_tag", dut->dn_tag_cr04h, o4->tag);
      eq("dn_row", dut->dn_row_cr04h, o4->drow);
      if (!coll(o4->kind)) {
        eq("dn_bt", dut->dn_bt_cr04h, o4->bt);
        eq("dn_bm", dut->dn_bm_cr04h, o4->bm);
        eq("dn_aux", dut->dn_aux_cr04h, o4->aux);
      }
      if (wg(o4->kind))
        for (unsigned l = 0; l < kN; ++l) eq("rw_dat", dut->rw_dat_cr04h[l], o4->wdat[l], l);
      if (wp(o4->kind)) {
        eq("pr_val", dut->pr_val_cr04h, o4->pval);
        eq("pr_mm", dut->pr_mm_cr04h, o4->pmm);
      }
    }
  }

  void step(bool rst = false) {
    drive(rst);
    dut->rcu_core_clk = 0;
    eval();
    if (!rst) check();
    dut->rcu_core_clk = 1;
    eval();
    ops.erase(cyc - 4);
    mvs.erase(cyc - 2);
    mius.erase(cyc - 2);
    ++cyc;
  }
};

struct Gen {
  std::mt19937_64 r;
  std::string control;
  explicit Gen(uint64_t seed) : r(seed) {}
  uint32_t u32() { return uint32_t(r()); }
  unsigned below(unsigned n) { return unsigned(r() % n); }
  bool p(double x) { return std::uniform_real_distribution<double>(0, 1)(r) < x; }
  // A register's placement: width code, then a position it fits.
  void place(unsigned &w, unsigned &pos) {
    const unsigned x = below(20);
    w = x < 8 ? 0 : x < 13 ? 1 : x < 17 ? 2 : 3;
    pos = w == 0 ? 0 : w == 1 ? 2 * below(2) : below(4);
  }
  unsigned row() { return 1 + below(23); }

  // MIU slots landing at u + 2: distinct rows, so one slot a source.
  void miu(Bench &b, uint64_t u, double rate) {
    std::array<bool, kNM> v{};
    std::array<Miu, kNM> m{};
    bool any = false;
    unsigned used = 0;
    for (unsigned j = 0; j < kNM; ++j) {
      if (!p(rate)) continue;
      unsigned rw;
      do rw = row(); while (used & (1u << rw));
      used |= 1u << rw;
      v[j] = any = true;
      m[j].row = rw;
      place(m[j].w, m[j].pos);
      const unsigned x = below(4);
      m[j].am = x == 0 ? ~0u : x == 1 ? 0u : u32();
      for (unsigned l = 0; l < kN; ++l) m[j].dat[l] = u32() & em(m[j].w);
    }
    if (any) {
      b.mvs[u] = v;
      b.mius[u] = m;
    }
  }

  void op(Bench &b, uint64_t c) {
    Op o{};
    o.kind = 1 + below(kKinds - 1);
    o.tag = below(128);
    o.drow = below(4);
    o.dst = row();
    place(o.dwid, o.dpos);
    o.opos = o.dwid == 0 ? 0 : o.dwid == 1 ? 2 * below(2) : below(4);
    o.pd = below(48);
    o.mrg = p(0.6);
    o.pwe = wp(o.kind) || p(0.5);
    const unsigned xm = below(4);
    o.imask = xm == 0 ? ~0u : u32();
    const unsigned xa = below(6);
    o.act = xa == 0 ? 0u : xa == 1 ? o.imask : o.imask & u32();
    o.rpa = u32();
    o.rpb = u32();
    o.imm = u32();
    if (o.kind == ShR) o.imm = 0;
    for (auto &rd : o.rd)
      for (auto &w : rd) w = u32();
    // The sources: rows, and on about a third a landing MIU slot's register.
    const auto mv = b.mvs.find(c);
    for (unsigned s = 0; s < 2; ++s) {
      const bool used = s == 0 ? uses0(o.kind) : uses1(o.kind);
      if (!used) {
        o.src[s] = 0;
        o.spos[s] = o.swid[s] = 0;
        continue;
      }
      o.src[s] = row();
      place(o.swid[s], o.spos[s]);
      if (mv != b.mvs.end() && p(0.4)) {
        const unsigned j = below(kNM);
        if (mv->second[j]) {
          const Miu &m = b.mius[c][j];
          o.src[s] = m.row;
          if (p(0.8)) {
            o.swid[s] = m.w;
            o.spos[s] = m.pos;
          }
        }
      }
    }
    if (o.kind == Ret && p(0.5)) {   // equal return addresses on several lanes
      const uint32_t v = u32();
      for (unsigned l = 0; l < kN; ++l)
        if (p(0.6)) o.rd[0][l] = v << (8 * o.spos[0]);
    }
    expect(b, c, o);
    b.ops[c] = o;
  }

  // The model's issueR, from the op's fields.
  void expect(Bench &b, uint64_t c, Op &o) {
    std::array<uint32_t, kN> v[2];
    const auto mv = b.mvs.find(c);
    for (unsigned s = 0; s < 2; ++s)
      for (unsigned l = 0; l < kN; ++l) {
        v[s][l] = align(o.rd[s][l], o.spos[s], o.swid[s]);
        if (mv == b.mvs.end() || control == "nofwd") continue;
        if (!(s == 0 ? uses0(o.kind) : uses1(o.kind))) continue;
        for (unsigned j = 0; j < kNM; ++j) {
          const Miu &m = b.mius[c][j];
          if (mv->second[j] && m.row == o.src[s] && m.pos == o.spos[s] && ((m.am >> l) & 1u)) {
            v[s][l] = m.dat[l] & em(o.swid[s]);
            ++o.fwd_lanes;
          }
        }
      }
    if (o.fwd_lanes) ++b.cov_fwd;
    const uint32_t e = em(o.dwid), act = o.act;
    std::array<uint32_t, kN> gnew{}, old{};
    for (unsigned l = 0; l < kN; ++l) old[l] = o.mrg ? align(o.rd[2][l], o.opos, o.dwid) : 0u;
    const unsigned cc = o.imm & 31u;
    auto shfl = [&](auto idx) {
      for (unsigned l = 0; l < kN; ++l) gnew[l] = v[0][idx(l) & 31u] & e;
    };
    o.pmm = o.imask;
    o.bt = false;
    o.bm = o.aux = 0;
    switch (o.kind) {
    case Bra:
    case Call:
      o.bt = act != 0;
      o.bm = act;
      if (o.kind == Call) gnew.fill(o.imm & e);
      break;
    case Ret: {
      unsigned lo = kN;
      for (unsigned l = 0; l < kN; ++l)
        if ((act >> l) & 1u) {
          if (lo == kN || control == "retlow") lo = l;
          if (control != "retlow") break;
        }
      o.aux = lo < kN ? v[0][lo] : 0u;
      for (unsigned l = 0; l < kN; ++l)
        if (((act >> l) & 1u) && v[0][l] == o.aux) o.bm |= 1u << l;
      o.bt = act != 0;
      if (__builtin_popcount(o.bm) > 1) ++b.cov_ret_multi;
      break;
    }
    case Pand: o.pval = o.rpa & o.rpb; break;
    case Por: o.pval = o.rpa | o.rpb; break;
    case Pxor: o.pval = o.rpa ^ o.rpb; break;
    case Pmov: o.pval = o.imm; break;
    case Movi: gnew.fill(o.imm & e); break;
    case ShI: shfl([&](unsigned) { return cc; }); break;
    case ShR: shfl([&](unsigned l) { return v[1][l]; }); break;
    case ShU: shfl([&](unsigned l) { return l < cc ? l : l - cc; }); break;
    case ShD: shfl([&](unsigned l) { return l + cc >= kN ? l : l + cc; }); break;
    case ShB: shfl([&](unsigned l) { return l ^ cc; }); break;
    case VAny:
    case VAll: {
      const bool r = o.kind == VAny ? (o.rpa & act) != 0 : (o.rpa & act) == act;
      o.pval = r ? ~0u : 0u;
      o.pmm = act;
      break;
    }
    case Bal: gnew.fill((o.rpa & act) & e); break;
    case Unb: {
      const unsigned bits = 32u >> o.swid[0];
      o.pval = 0;
      for (unsigned l = 0; l < kN && l < bits; ++l) o.pval |= ((v[0][l] >> l) & 1u) << l;
      o.pmm = act;
      break;
    }
    default: break;
    }
    for (unsigned l = 0; l < kN; ++l) {
      const uint32_t x = ((act >> l) & 1u) ? gnew[l] : old[l];
      o.wdat[l] = (x & e) << (8 * o.dpos);
    }
    ++b.cov_kind[o.kind];
    if (wg(o.kind) && o.mrg && act != ~0u) ++b.cov_merge;
    if (wg(o.kind) && o.dpos) ++b.cov_shift;
    if (!act) ++b.cov_noact;
  }
};

int g_argc;
char **g_argv;

int run(const std::string &scenario, const char *vcd, const std::string &control) {
  Bench b(vcd);
  for (int i = 0; i < 8; ++i) b.step(true);
  b.step();   // the flopped reset (RST-1) falls a cycle after its input
  Gen g(0x5eed00 + scenario.size());
  g.control = control;
  const unsigned n = scenario == "idle" ? 3000 : 6000;
  for (unsigned i = 0; i < n; ++i) {
    const uint64_t c = b.cyc;
    if (scenario == "medium") {
      if (i % 3 == 0) {
        g.miu(b, c, 0.3);
        if (g.p(0.9)) g.op(b, c);
      }
    } else if (scenario != "idle") {
      g.miu(b, c, 0.4);
      if (g.p(0.9)) g.op(b, c);
    }
    b.step();
  }
  for (int i = 0; i < 6; ++i) b.step();
  bool cov = true;
  if (scenario != "idle") {
    for (unsigned k = 1; k < kKinds; ++k) cov &= b.cov_kind[k] != 0;
    cov &= b.cov_fwd && b.cov_merge && b.cov_shift && b.cov_ret_multi && b.cov_noact;
    if (!cov) {
      std::fprintf(stderr, "rcu_r: coverage: fwd %u merge %u shift %u ret_multi %u noact %u; kinds",
                   b.cov_fwd, b.cov_merge, b.cov_shift, b.cov_ret_multi, b.cov_noact);
      for (unsigned k = 1; k < kKinds; ++k) std::fprintf(stderr, " %s %u", kName[k], b.cov_kind[k]);
      std::fputc('\n', stderr);
      ++b.fails;
    }
  }
  std::printf("rcu_r: %s%s%s: %llu cycles, %u values checked, %u ops forwarded, %u mismatches: %s\n",
              scenario.empty() ? "random" : scenario.c_str(), control.empty() ? "" : ", control ",
              control.c_str(), (unsigned long long)b.cyc, b.checked, b.cov_fwd, b.fails,
              b.fails ? "FAIL" : "PASS");
  return b.fails ? 1 : 0;
}

} // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string scenario, control;
  const char *vcd = nullptr;
  for (int i = 1; i < argc; ++i) {
    if (!std::strcmp(argv[i], "--cg") && i + 2 < argc) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "rcu_r: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
    if (!std::strcmp(argv[i], "--control") && i + 1 < argc) control = argv[i + 1];
  }
  return run(scenario, vcd, control);
}
