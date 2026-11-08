//===-- lanes_tb.cpp - rcu_lanes against a value model of the lane path --===//
//
// Drives rtl/rcu/rcu_lanes.sv and holds it, cycle by cycle, to a value model
// of the lane path (Lane and memory paths tab; the RCU model's cycle(),
// sim/rcu/rcu_core.cpp): the lane message's lead fields in A+1 and payload
// in A+2, every copy; the bypass selects; LW and PL at A+4..A+6; SW at
// A+9..A+11; done slots 0-3 (valid A+6, payload A+7) and 4 (A+11, A+12)
// (rcu_lanes.sv, "Port timing", at CCV_LAT_LANE and CCV_LAT_SFU).
//
// Each cycle a group of S-slot ops: disjoint footprints, each op's lowest
// section its slot, footprints non-contiguous at times; lane ops, GPR
// copies, SFU ops (full width, slot 0) and ops of class 0 (nothing to the
// lanes). Rows from a small pool so that sources meet their producers at
// the bypass ages; the bench keeps the module's input contract: no source
// a lane producer younger than CCV_LAT_LANE_BYP has yet to write, never two
// producers matching. Leads at times a superset of what the payload uses.
// The bank reads are random bytes: the operands are checked as routed,
// not as a register file.
//
// A field group the op does not use (by its lead) holds its last value:
// those bytes are not checked. The bypass selects are checked whole.
//
// Runs: random traffic. --cg <idle|medium|high> <vcd> runs one clock-gating
// scenario (tools/check-cg.py). --control <bypage|immpos> expects a wrong
// rule (a forward's age one more; the immediate's port at position 0):
// the run must fail (test/rcu/run-rtl.sh). Exit 0 only with no mismatch.
//===----------------------------------------------------------------------===//
#include "Vrcu_lanes.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <algorithm>
#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <map>
#include <memory>
#include <random>
#include <string>
#include <type_traits>
#include <vector>

#include "ccv_params.h"

#ifndef LN_COPIES
#define LN_COPIES 32
#endif

namespace {

constexpr unsigned kN = LN_COPIES, kK = 4, kP = 4, kZero = 255, kWB = 5;
constexpr unsigned kLat = ccv::prov::kLatLane, kByp = ccv::prov::kLatLaneByp, kSfu = ccv::prov::kLatSfu;
constexpr unsigned kHi = kLat - 2;   // the oldest age forwarded

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
unsigned secmask(unsigned w, unsigned pos) { return (((1u << span(w)) - 1u) << pos) & 15u; }
constexpr uint32_t kLanes = kN >= 32 ? 0xffffffffu : (1u << kN) - 1u;

enum Cls : unsigned { None = 0, Lane = 1, Sfu = 2, Copy = 3 };

struct Op {
  unsigned cls = None, foot = 0;
  unsigned lsec = 0, lsrc = 0;
  bool limm = false, lmrg = false;
  bool gdst = false, immu = false, pdt = false, mrg = false, pwe = false;
  unsigned rds = 0, isl = 3, opc = 0, tag = 0, drow = 0;
  uint32_t imm = 0, act = 0, gv = 0;
  unsigned src[3]{}, spos[3]{}, swid[3]{};
  unsigned dst = kZero, odst = kZero, dpos = 0, dwid = 0, opos = 0, pd = 0, pod = 0;
  unsigned byp[kP]{};   // the expected selects
  bool rdp(unsigned i) const {
    if (cls == None) return false;
    return i < 3 ? cls != Copy && ((rds >> i) & 1u) : mrg;
  }
  unsigned prow(unsigned i) const { return i < 3 ? src[i] : odst; }
  unsigned ppos(unsigned i) const { return i < 3 ? spos[i] : opos; }
  bool use(unsigned i) const { return i < 3 ? ((lsrc >> i) & 1u) || (limm && isl == i) : lmrg; }
};
struct Group {
  std::array<bool, kK> v{};
  std::array<Op, kK> op{};
  std::vector<uint8_t> rd;   // bank k port i lane l at (k*kP + i)*kN + l
  unsigned owner(unsigned k) const {   // the slot owning section k, or kK
    for (unsigned s = 0; s < kK; ++s)
      if (v[s] && op[s].cls != None && ((op[s].foot >> k) & 1u)) return s;
    return kK;
  }
};

extern int g_argc;
extern char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vrcu_lanes> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  std::string control;
  std::map<uint64_t, Group> gs;   // by A

  explicit Bench(const char *vcd_path) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vrcu_lanes>(ctx.get());
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
  void eq(const char *what, uint64_t got, uint64_t want, unsigned a = 0, unsigned b = 0) {
    ++checked;
    if (got != want && ++fails <= 20)
      std::fprintf(stderr, "rcu_lanes: cycle %llu: %s [%u][%u]: got %llx, want %llx\n",
                   (unsigned long long)cyc, what, a, b, (unsigned long long)got, (unsigned long long)want);
  }
  const Group *g(uint64_t a) const {
    auto i = gs.find(a);
    return i == gs.end() ? nullptr : &i->second;
  }

  void drive(bool rst) {
    dut->rst_n = !rst;
    const uint64_t c = cyc;
    dut->iw_cr01h = g(c + 1) || g(c + 2) || g(c + 3);
    // A-1: the lead.
    dut->iv_cr01h = 0;
    dut->lsec_cr01h = 0;
    dut->lsrc_cr01h = 0;
    dut->limm_cr01h = 0;
    dut->lmrg_cr01h = 0;
    if (const Group *x = g(c + 1))
      for (unsigned s = 0; s < kK; ++s) {
        if (!x->v[s]) continue;
        const Op &o = x->op[s];
        put(dut->iv_cr01h, s, 1, 1);
        put(dut->lsec_cr01h, s * kK, kK, o.lsec);
        put(dut->lsrc_cr01h, s * 3, 3, o.lsrc);
        put(dut->limm_cr01h, s, 1, o.limm);
        put(dut->lmrg_cr01h, s, 1, o.lmrg);
      }
    // A: the payload, its decode and active.
    if (const Group *x = g(c))
      for (unsigned s = 0; s < kK; ++s) {
        const Op &o = x->op[s];
        put(dut->cls_cr02h, 2 * s, 2, x->v[s] ? o.cls : 0);
        put(dut->gdst_cr02h, s, 1, o.gdst);
        put(dut->rds_cr02h, 3 * s, 3, o.rds);
        put(dut->isl_cr02h, 2 * s, 2, o.isl);
        put(dut->immu_cr02h, s, 1, o.immu);
        put(dut->pdt_cr02h, s, 1, o.pdt);
        put(dut->foot_cr02h, kK * s, kK, o.foot);
        put(dut->opc_cr02h, 9 * s, 9, o.opc);
        put(dut->imm_cr02h, 32 * s, 32, o.imm);
        for (unsigned i = 0; i < 3; ++i) {
          put(dut->src_cr02h, (s * 3 + i) * 8, 8, o.src[i]);
          put(dut->spos_cr02h, s * 6 + 2 * i, 2, o.spos[i]);
          put(dut->swid_cr02h, s * 6 + 2 * i, 2, o.swid[i]);
        }
        put(dut->dst_cr02h, 8 * s, 8, o.dst);
        put(dut->odst_cr02h, 8 * s, 8, o.odst);
        put(dut->dpos_cr02h, 2 * s, 2, o.dpos);
        put(dut->dwid_cr02h, 2 * s, 2, o.dwid);
        put(dut->opos_cr02h, 2 * s, 2, o.opos);
        put(dut->mrg_cr02h, s, 1, o.mrg);
        put(dut->pwe_cr02h, s, 1, o.pwe);
        put(dut->pd_cr02h, 6 * s, 6, o.pd);
        put(dut->pod_cr02h, 6 * s, 6, o.pod);
        put(dut->tag_cr02h, 7 * s, 7, o.tag);
        put(dut->drow_cr02h, 2 * s, 2, o.drow);
      }
    else
      dut->cls_cr02h = 0;   // the rest of the payload holds: no message
    // A+1: rcu_pred's flops and the bank reads.
    if (const Group *x = g(c - 1)) {
      for (unsigned s = 0; s < kK; ++s) {
        put(dut->acta_cr03h, kN * s, kN, x->op[s].act);
        put(dut->gv_cr03h, kN * s, kN, x->op[s].gv);
      }
      for (unsigned j = 0; j < kK * kP * kN; ++j) put(dut->rd_cr03h, 8 * j, 8, x->rd[j]);
    }
    // A+6: the lanes' results, as due; their valid a cycle before (A+5).
    auto dueAt = [&](uint64_t cc) {
      unsigned d = 0;
      if (const Group *x = g(cc - (kLat - 1)))
        for (unsigned s = 0; s < kK; ++s)
          if (x->v[s] && (x->op[s].cls == Lane || x->op[s].cls == Copy)) d |= x->op[s].foot;
      if (const Group *x = g(cc - (kSfu - 1)))
        for (unsigned s = 0; s < kK; ++s)
          if (x->v[s] && x->op[s].cls == Sfu) d |= x->op[s].foot;
      return d;
    };
    const unsigned due = dueAt(c), due1 = dueAt(c + 1);
    for (unsigned l = 0; l < kN; ++l) {
      put(dut->lrv_cr07h, l, 1, due1 != 0);
      put(dut->lsv_cr08h, l * kK, kK, due);
    }
  }

  void check() {
    const uint64_t c = cyc;
    // A+1: the lead fields, every copy.
    {
      const Group *x = g(c - 1);
      for (unsigned l = 0; l < kN; ++l) {
        unsigned sen = 0;
        if (x)
          for (unsigned k = 0; k < kK; ++k) {
            const unsigned o = x->owner(k);
            if (o == kK) continue;
            sen |= 1u << k;
          }
        eq("valid", get(dut->lv_cr03h, l, 1), sen != 0, l);
        eq("section_en", get(dut->sen_cr03h, l * kK, kK), sen, l);
      }
    }
    // A+2: the payload of every owned section.
    if (const Group *x = g(c - 2))
      for (unsigned k = 0; k < kK; ++k) {
        const unsigned s = x->owner(k);
        if (s == kK) continue;
        const Op &o = x->op[s];
        for (unsigned l = 0; l < kN; ++l) {
          const unsigned e = l * kK + k;
          eq("sec_opcode", get(dut->sop_cr04h, e * 9, 9), o.opc, l, k);
          eq("sec_owner", get(dut->sown_cr04h, e * 2, 2), s, l, k);
          eq("sec_dst_pos", get(dut->sdpos_cr04h, e * 2, 2), o.dpos, l, k);
          eq("sec_dst_width", get(dut->sdwid_cr04h, e * 2, 2), o.dwid, l, k);
          eq("sec_pred_data", get(dut->spd_cr04h, e, 1), o.pdt ? (o.gv >> l) & 1u : 0u, l, k);
          for (unsigned i = 0; i < kP; ++i) {
            const unsigned q = e * kP + i;
            unsigned pos = i < 3 ? o.spos[i] : o.opos;
            if (i < 3 && o.isl == i) pos = control == "immpos" ? 0 : s;
            eq("sec_opnd_pos", get(dut->sopos_cr04h, q * 2, 2), pos, l, k * kP + i);
            eq("sec_opnd_width", get(dut->sowid_cr04h, q * 2, 2), i < 3 ? o.swid[i] : o.dwid, l, k * kP + i);
            eq("operand_byp", get(dut->sbyp_cr04h, q * kWB, kWB), o.byp[i], l, k * kP + i);
            if (!o.use(i)) continue;   // the group holds: don't-care
            unsigned b = o.rdp(i) ? x->rd[(k * kP + i) * kN + l] : 0u;
            if (i < 3 && o.isl == i) b = (o.imm >> (8 * (k - s))) & 0xffu;
            eq("operand", get(dut->opd_cr04h, (l * kP + i) * 32 + 8 * k, 8), b, l, k * kP + i);
          }
        }
      }
    // LW and PL: valid A+4, rows A+5, write A+6; dones valid A+6, payload A+7.
    const uint64_t a4 = c - (kLat - 3), a5 = c - (kLat - 2), a6 = c - (kLat - 1), a7 = c - kLat;
    for (unsigned k = 0; k < kK; ++k) {
      auto wv = [&](const Group *x) {
        const unsigned o = x ? x->owner(k) : kK;
        return o != kK && (x->op[o].cls == Copy || (x->op[o].cls == Lane && x->op[o].gdst));
      };
      auto lead = [&](const Group *x, auto f) { return x && x->v[k] && f(x->op[k]); };
      auto pv = [](const Op &o) { return o.cls == Lane && o.pwe; };
      auto dv = [](const Op &o) { return o.cls == Lane; };
      eq("lw_v", get(dut->lwv_cr06h, k, 1), wv(g(a4)), k);
      if (wv(g(a5))) {
        const Group *x = g(a5);
        eq("lw_row", get(dut->lwrow_cr07h, 8 * k, 8), x->op[x->owner(k)].dst, k);
        eq("lw_sec", get(dut->lwsec_cr07h, kK * k, kK), 1u << k, k);
      }
      if (wv(g(a6))) {
        const Op &o = g(a6)->op[g(a6)->owner(k)];
        eq("lw_lm", get(dut->lwlm_cr08h, kN * k, kN), o.cls == Copy ? ~o.act & kLanes : kLanes, k);
      }
      eq("pl_v", get(dut->plv_cr06h, k, 1), lead(g(a4), pv), k);
      if (lead(g(a5), pv)) {
        const Op &o = g(a5)->op[k];
        eq("pl_row", get(dut->plrow_cr07h, 6 * k, 6), o.pd, k);
        eq("pl_orow", get(dut->plorow_cr07h, 6 * k, 6), o.pod, k);
        eq("pl_mrg", get(dut->plmrg_cr07h, k, 1), o.mrg, k);
      }
      if (lead(g(a6), pv)) eq("pl_mm", get(dut->plmm_cr08h, kN * k, kN), g(a6)->op[k].act & kLanes, k);
      eq("done_v", get(dut->dnv_cr08h, k, 1), lead(g(a6), dv), k);
      if (lead(g(a7), dv)) {
        eq("done_tag", get(dut->dntag_cr09h, 7 * k, 7), g(a7)->op[k].tag, k);
        eq("done_row", get(dut->dnrow_cr09h, 2 * k, 2), g(a7)->op[k].drow, k);
      }
    }
    // SW: valid A+9, row A+10, write A+11; SFU done valid A+11, payload A+12.
    auto sfu = [](const Group *x) -> const Op * {
      if (x)
        for (unsigned s = 0; s < kK; ++s)
          if (x->v[s] && x->op[s].cls == Sfu) return &x->op[s];
      return nullptr;
    };
    const Op *s9 = sfu(g(c - (kSfu - 3))), *s10 = sfu(g(c - (kSfu - 2))), *s11 = sfu(g(c - (kSfu - 1))),
             *s12 = sfu(g(c - kSfu));
    eq("sw_v", dut->swv_cr11h, s9 && s9->gdst);
    if (s10 && s10->gdst) {
      eq("sw_row", dut->swrow_cr12h, s10->dst);
      eq("sw_sec", dut->swsec_cr12h, secmask(s10->dwid, s10->dpos));
    }
    eq("sfu_done_v", dut->sdv_cr13h, s11 != nullptr);
    if (s12) {
      eq("sfu_done_tag", dut->sdtag_cr14h, s12->tag);
      eq("sfu_done_row", dut->sdrow_cr14h, s12->drow);
    }
  }

  void step(bool rst = false) {
    drive(rst);
    dut->rcu_core_clk = 0;
    eval();
    if (!rst) check();
    dut->rcu_core_clk = 1;
    eval();
    gs.erase(cyc - kSfu - 1);
    ++cyc;
  }
};

struct Gen {
  std::mt19937_64 r;
  std::string control;
  unsigned cov_byp[2]{}, cov_imm_hi = 0, cov_copy = 0, cov_sfu = 0, cov_pdt = 0, cov_split = 0,
           cov_super = 0, cov_multi = 0, cov_pwe = 0;
  explicit Gen(uint64_t seed) : r(seed) {}
  uint32_t u32() { return uint32_t(r()); }
  unsigned below(unsigned n) { return unsigned(r() % n); }
  bool p(double x) { return std::uniform_real_distribution<double>(0, 1)(r) < x; }
  unsigned row() { return p(0.08) ? kZero : below(10); }
  void place(unsigned &w, unsigned &pos) {
    w = below(4);
    pos = w == 0 ? 0 : w == 1 ? 2 * below(2) : below(4);
  }

  // The history of lane producers of a GPR: {A, row, pos, lead}.
  struct Prod { uint64_t a; unsigned row, pos, lead; };
  std::vector<Prod> hist;

  // Legal: no producer younger than the bypass age on the row; at most one
  // at a forwarded age on (row, pos).
  bool legal(uint64_t a, unsigned row, unsigned pos) const {
    if (row == kZero) return true;
    int hits = 0;
    for (const Prod &h : hist) {
      const uint64_t age = a - h.a;
      if (age > kHi || h.row != row) continue;   // age 0: this group's own
      if (age < kByp) return false;
      if (h.pos == pos) ++hits;
    }
    return hits < 2;
  }
  void source(uint64_t a, unsigned &row, unsigned &pos, unsigned w) {
    // Now and then a producer at a forwarded age; else from the pool.
    std::vector<const Prod *> fw;
    for (const Prod &h : hist)
      if (h.a < a && a - h.a >= kByp && a - h.a <= kHi) fw.push_back(&h);
    for (int tries = 0; tries < 16; ++tries) {
      if (!fw.empty() && p(0.35)) {
        const Prod *h = fw[below(unsigned(fw.size()))];
        row = h->row;
        pos = h->pos;
      } else {
        row = row_pick();
        pos = w == 0 ? 0 : w == 1 ? 2 * below(2) : below(4);
      }
      if (legal(a, row, pos)) return;
    }
    row = kZero;
  }
  unsigned row_pick() { return row(); }

  Group make(uint64_t a) {
    Group x;
    x.rd.resize(kK * kP * kN);
    for (auto &b : x.rd) b = uint8_t(u32());
    unsigned taken = 0;
    hist.erase(std::remove_if(hist.begin(), hist.end(), [&](const Prod &h) { return a - h.a > kHi; }),
               hist.end());
    unsigned nops = 0;
    for (unsigned s = 0; s < kK; ++s) {
      if ((taken >> s) & 1u) continue;
      if (!p(0.7)) continue;
      Op o;
      const unsigned roll = below(100);
      o.cls = roll < 62 ? Lane : roll < 75 ? Copy : roll < 88 ? None : Sfu;
      if (o.cls == Sfu && (s != 0 || taken)) o.cls = Lane;
      if (o.cls == Sfu) {
        o.foot = 15;
      } else {
        o.foot = 1u << s;
        for (unsigned k = s + 1; k < kK; ++k)
          if (!((taken >> k) & 1u) && p(0.35)) o.foot |= 1u << k;
      }
      taken |= o.foot;
      if (o.cls != None && (o.foot & (o.foot >> 1)) != o.foot >> 1) ++cov_split;   // a gap
      o.tag = below(128);
      o.drow = below(4);
      o.opc = o.cls == Copy ? 511u : below(511);
      o.imm = u32();
      o.act = p(0.5) ? 0xffffffffu : u32();
      o.gv = u32();
      for (unsigned i = 0; i < 3; ++i) place(o.swid[i], o.spos[i]);
      place(o.dwid, o.dpos);
      o.opos = o.dpos;
      if (o.cls == Copy) {
        o.mrg = true;
        o.gdst = false;
        o.rds = 0;
      } else {
        o.rds = below(8);
        if (p(0.3)) {
          o.isl = below(3);
          o.rds &= ~(1u << o.isl);
        }
        o.immu = o.isl != 3 || p(0.1);
        o.pdt = p(0.2);
        o.mrg = p(0.4);
        o.gdst = o.cls == Lane ? p(0.8) : o.cls == Sfu ? p(0.9) : p(0.5);
        o.pwe = o.cls == Lane && p(0.3);
      }
      o.dst = (o.gdst || o.cls == Copy) ? below(10) : row();
      o.pd = below(48);
      o.pod = below(48);
      for (unsigned i = 0; i < 3; ++i)
        if (o.rdp(i)) source(a, o.src[i], o.spos[i], o.swid[i]);
        else o.src[i] = row();
      if (o.rdp(3)) source(a, o.odst, o.opos, o.dwid);
      else o.odst = row();
      // Leads: the payload's use, at times a superset.
      o.lsec = o.foot;
      o.lsrc = o.rds;
      o.limm = o.immu;
      o.lmrg = o.mrg;
      if (p(0.1)) { o.lsec |= 1u << below(4); ++cov_super; }
      if (p(0.1)) o.lsrc |= 1u << below(3);
      if (p(0.05)) o.limm = true;
      if (p(0.05)) o.lmrg = true;
      if (o.cls == Copy) o.lsrc = 0;
      // The expected bypass selects.
      for (unsigned i = 0; i < kP; ++i) {
        if (!o.rdp(i) || o.prow(i) == kZero) continue;
        for (const Prod &h : hist) {
          const uint64_t age = a - h.a;
          if (h.a >= a || age < kByp || age > kHi || h.row != o.prow(i) || h.pos != o.ppos(i)) continue;
          const unsigned ag = unsigned(age - kByp) + (control == "bypage" ? 1u : 0u);
          o.byp[i] = 1u | h.lead << 1 | (ag & 3u) << 3;
          ++cov_byp[age - kByp];
        }
      }
      if (o.cls == Copy) ++cov_copy;
      if (o.cls == Sfu) ++cov_sfu;
      if (o.pdt && o.cls != None) ++cov_pdt;
      if (o.isl != 3 && s > 0 && o.cls != None) ++cov_imm_hi;
      if (o.pwe) ++cov_pwe;
      if (o.cls != None) ++nops;
      if (o.cls == Lane && o.gdst) hist.push_back({a, o.dst, o.dpos, s});
      x.v[s] = true;
      x.op[s] = o;
    }
    if (nops > 1) ++cov_multi;
    return x;
  }
};

int g_argc;
char **g_argv;

int run(const std::string &scenario, const char *vcd, const std::string &control) {
  Bench b(vcd);
  b.control = control;
  for (int i = 0; i < 8; ++i) b.step(true);
  b.step();   // the flopped reset (RST-1) falls a cycle after its input
  Gen gen(0x1a9e5 + scenario.size());
  gen.control = control;
  const unsigned n = scenario == "idle" ? 3000 : 6000;
  for (unsigned i = 0; i < n; ++i) {
    const uint64_t a = b.cyc + 1;   // the group whose lead is driven this cycle
    bool go = false;
    // medium: about a third of cycles, at random spacing so that ages 4 and 5
    // (the forwarded ones) still occur; a fixed stride of 3 never forwards.
    if (scenario == "medium") go = gen.p(0.3);
    else if (scenario != "idle") go = gen.p(0.9);
    if (go) b.gs[a] = gen.make(a);
    else gen.hist.erase(std::remove_if(gen.hist.begin(), gen.hist.end(),
                                       [&](const Gen::Prod &h) { return a - h.a > kHi; }),
                        gen.hist.end());
    b.step();
  }
  for (unsigned i = 0; i < kSfu + 4; ++i) b.step();
  if (scenario != "idle") {
    const bool cov = gen.cov_byp[0] && gen.cov_byp[1] && gen.cov_imm_hi && gen.cov_copy && gen.cov_sfu &&
                     gen.cov_pdt && gen.cov_split && gen.cov_super && gen.cov_multi && gen.cov_pwe;
    if (!cov) {
      std::fprintf(stderr, "rcu_lanes: coverage: byp %u/%u imm_hi %u copy %u sfu %u pdata %u split %u "
                           "super %u multi %u pwe %u\n", gen.cov_byp[0], gen.cov_byp[1], gen.cov_imm_hi,
                   gen.cov_copy, gen.cov_sfu, gen.cov_pdt, gen.cov_split, gen.cov_super, gen.cov_multi,
                   gen.cov_pwe);
      ++b.fails;
    }
  }
  std::printf("rcu_lanes: %s%s%s: %llu cycles, %u copies, %u values checked, %u mismatches: %s\n",
              scenario.empty() ? "random" : scenario.c_str(), control.empty() ? "" : ", control ",
              control.c_str(), (unsigned long long)b.cyc, kN, b.checked, b.fails, b.fails ? "FAIL" : "PASS");
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
        std::fprintf(stderr, "rcu_lanes: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
    if (!std::strcmp(argv[i], "--control") && i + 1 < argc) control = argv[i + 1];
  }
  return run(scenario, vcd, control);
}
