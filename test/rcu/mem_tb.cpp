//===-- mem_tb.cpp - rcu_mem against a value model of the memory path ----===//
//
// Drives rtl/rcu/rcu_mem.sv and holds it, cycle by cycle, to a value model
// of the memop operand assembly (Lane and memory paths tab, Memop operands;
// the RCU model's issueMem, sim/rcu/rcu_core.cpp): the address valid in
// A+1 on each memop's lead pipe's slot and its payload in A+2
// (rcu_mem.sv, "Port timing"), and the wake a cycle ahead of the valid.
//
// Each cycle a group of P-slot memops: disjoint footprints, each one's
// lowest pipe its slot, at times non-contiguous; the footprint's other
// pipes' slots are continuations (valid, no memop). Loads, stores,
// predicate loads and stores, fences; slot-form memops with no base,
// memops with no index; operands at every width and position inside the
// footprint, sources shared at times. Leads at times a superset of what
// the class reads. The bank reads are random bytes: the operands are
// checked as routed, not as a register file.
//
// A fence's operands and a non-store's store data are don't-care (not
// checked); a missing base or index must be 0.
//
// Runs: random traffic. --cg <idle|medium|high> <vcd> runs one clock-gating
// scenario (tools/check-cg.py). --control <align|pstlane> expects a wrong
// rule (operands not right-aligned; a predicate store's word in lane 1):
// the run must fail (test/rcu/run-rtl.sh). Exit 0 only with no mismatch.
//===----------------------------------------------------------------------===//
#include "Vrcu_mem.h"
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
#include <vector>

#include "dec_tb.h"

#ifndef MM_COPIES
#define MM_COPIES 32
#endif

namespace {

constexpr unsigned kN = MM_COPIES, kK = 4, kM = 3, kWT = 7;
constexpr uint32_t kLanes = kN >= 32 ? 0xffffffffu : (1u << kN) - 1u;

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

enum Kind : unsigned { Load, Store, PLoad, PStore, Fence };

struct Op {
  bool mem = false;   // false: a continuation
  unsigned kind = Load, foot = 0, lsrc = 0, tag = 0;
  unsigned opc = 0, drow = 0;   // the payload the module decodes (test/rcu/dec_tb.h)
  unsigned sl[kM] = {3, 3, 3};   // base, index, data: source, 3 none
  unsigned spos[3]{}, swid[3]{};
  uint32_t act = 0, pst = 0;
};
struct Group {
  std::array<bool, kK> v{};
  std::array<Op, kK> op{};
  std::vector<uint8_t> rd;   // bank k port m lane l at (k*kM + m)*kN + l
};

extern int g_argc;
extern char **g_argv;
int g_argc;
char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vrcu_mem> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  std::string control;
  std::map<uint64_t, Group> gs;   // by A
  bool iw_last = false;

  explicit Bench(const char *vcd_path) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vrcu_mem>(ctx.get());
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
      std::fprintf(stderr, "rcu_mem: cycle %llu: %s [%u][%u]: got %llx, want %llx\n",
                   (unsigned long long)cyc, what, a, b, (unsigned long long)got, (unsigned long long)want);
  }
  const Group *g(uint64_t a) const {
    auto i = gs.find(a);
    return i == gs.end() ? nullptr : &i->second;
  }

  void drive(bool rst) {
    dut->rst_n = !rst;
    const uint64_t c = cyc;
    const bool iw = g(c + 1) || g(c + 2) || g(c + 3);
    dut->iw_cr01h = iw;
    // A-1: the lead.
    dut->iv_cr01h = 0;
    dut->lsrc_cr01h = 0;
    if (const Group *x = g(c + 1))
      for (unsigned j = 0; j < kK; ++j) {
        if (!x->v[j]) continue;
        put(dut->iv_cr01h, j, 1, 1);
        put(dut->lsrc_cr01h, 3 * j, 3, x->op[j].lsrc);
      }
    // A: the payload and its decode.
    if (const Group *x = g(c))
      for (unsigned j = 0; j < kK; ++j) {
        const Op &o = x->op[j];
        put(dut->opc_cr02h, 9 * j, 9, o.opc);
        put(dut->cont_cr02h, j, 1, x->v[j] && !o.mem);
        put(dut->drw_cr02h, 2 * j, 2, o.drow);
        put(dut->foot_cr02h, kK * j, kK, o.foot);
        for (unsigned i = 0; i < 3; ++i) {
          put(dut->spos_cr02h, 6 * j + 2 * i, 2, o.spos[i]);
          put(dut->swid_cr02h, 6 * j + 2 * i, 2, o.swid[i]);
        }
        put(dut->tag_cr02h, kWT * j, kWT, o.tag);
      }
    else
      dut->cont_cr02h = 0;   // the rest of the payload holds: no valid, no message
    // A+1: rcu_pred's flops and the bank reads.
    if (const Group *x = g(c - 1)) {
      for (unsigned j = 0; j < kK; ++j) {
        put(dut->act_cr03h, kN * j, kN, x->op[j].act);
        put(dut->pst_cr03h, kN * j, kN, x->op[j].pst);
      }
      for (unsigned i = 0; i < kK * kM * kN; ++i) put(dut->rd_cr03h, 8 * i, 8, x->rd[i]);
    }
  }

  // Operand m of slot j's memop, lane l, as the model reads it.
  uint32_t opnd(const Group &x, unsigned j, unsigned m, unsigned l) const {
    const Op &o = x.op[j];
    const unsigned s = o.sl[m];
    if (s == 3) return 0;
    const unsigned pos = control == "align" ? 0 : o.spos[s], nb = span(o.swid[s]);
    uint32_t w = 0;
    for (unsigned b = 0; b < nb; ++b) w |= uint32_t(x.rd[((pos + b) * kM + m) * kN + l]) << (8 * b);
    return w;
  }

  void check() {
    const uint64_t c = cyc;
    // The wake, a cycle after the issue wake.
    eq("wake", dut->mwk_cr02h, iw_last);
    // A+1: the valid.
    {
      const Group *x = g(c - 1);
      unsigned v = 0;
      if (x)
        for (unsigned j = 0; j < kK; ++j)
          if (x->v[j] && x->op[j].mem) v |= 1u << j;
      eq("valid", dut->mv_cr03h, v);
    }
    // A+2: each memop's payload.
    if (const Group *x = g(c - 2))
      for (unsigned j = 0; j < kK; ++j) {
        if (!x->v[j] || !x->op[j].mem) continue;
        const Op &o = x->op[j];
        eq("rob_tag", get(dut->mtag_cr04h, kWT * j, kWT), o.tag, j);
        eq("active_mask", get(dut->mam_cr04h, kN * j, kN), o.act, j);
        if (o.kind == Fence) continue;
        for (unsigned l = 0; l < kN; ++l) {
          eq("base", dut->mbase_cr04h[j * kN + l], opnd(*x, j, 0, l), j, l);
          eq("index", dut->midx_cr04h[j * kN + l], opnd(*x, j, 1, l), j, l);
          if (o.kind == Store) eq("store_data", dut->msd_cr04h[j * kN + l], opnd(*x, j, 2, l), j, l);
          if (o.kind == PStore) {
            const unsigned l0 = control == "pstlane" ? 1 : 0;
            eq("store_data", dut->msd_cr04h[j * kN + l], l == l0 ? o.pst : 0, j, l);
          }
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
    iw_last = dut->iw_cr01h && !rst;
    gs.erase(cyc - 4);
    ++cyc;
  }
};

struct Gen {
  std::mt19937_64 r;
  unsigned tag = 0;
  // Coverage.
  unsigned cov_kind[5]{}, cov_noidx = 0, cov_slot = 0, cov_w16 = 0, cov_w8 = 0, cov_split = 0,
           cov_cont = 0, cov_multi = 0, cov_super = 0, cov_shared = 0, cov_atom = 0;
  explicit Gen(uint64_t seed) : r(seed) {}
  bool p(double q) { return std::uniform_real_distribution<double>(0, 1)(r) < q; }
  unsigned u(unsigned n) { return unsigned(r() % n); }

  // A width and position inside the footprint f.
  void place(unsigned f, unsigned &w, unsigned &pos) {
    std::vector<std::pair<unsigned, unsigned>> ok;
    for (unsigned ww = 0; ww < 3; ++ww)
      for (unsigned pp = 0; pp + span(ww) <= 4; ++pp)
        if ((secmask(ww, pp) & ~f) == 0) ok.push_back({ww, pp});
    const auto &c = ok[u(unsigned(ok.size()))];
    w = c.first;
    pos = c.second;
  }

  // The opcodes the decode makes each kind of memop at a done_row.
  static const dectb::OpPool &pool(unsigned kind, unsigned drow) {
    static std::map<unsigned, dectb::OpPool> m;
    const unsigned key = kind * 4 + drow;
    auto it = m.find(key);
    if (it == m.end()) {
      using MK = dectb::R::MemKind;
      const MK mk = kind == Load ? MK::Load : kind == Store ? MK::Store : kind == PLoad ? MK::PredLoad
                    : kind == PStore ? MK::PredStore : MK::Fence;
      it = m.emplace(key, dectb::OpPool("a memop kind", drow, [mk](const dectb::R::OpClass &oc) {
             return oc.unit == dectb::R::Unit::Mem && oc.mk == mk;
           })).first;
    }
    return it->second;
  }

  Group make() {
    Group x;
    unsigned used = 0, n = 0;
    for (unsigned j = 0; j < kK; ++j) {
      if ((used >> j) & 1u) continue;
      if (!p(0.6)) continue;
      // The footprint: the slot and some free pipes above it.
      unsigned f = 1u << j;
      if (p(0.5))
        for (unsigned k = j + 1; k < kK; ++k)
          if (!((used >> k) & 1u) && p(0.5)) f |= 1u << k;
      used |= f;
      Op &o = x.op[j];
      x.v[j] = true;
      o.mem = true;
      o.foot = f;
      o.tag = tag++ & 127u;
      o.act = uint32_t(r()) & kLanes;
      o.pst = uint32_t(r()) & kLanes;
      const unsigned roll = u(20);
      o.kind = roll < 7 ? Load : roll < 13 ? Store : roll < 15 ? PLoad : roll < 17 ? PStore : Fence;
      ++cov_kind[o.kind];
      for (unsigned i = 0; i < 3; ++i) {
        o.spos[i] = u(4);   // don't-care unless read
        o.swid[i] = u(3);
      }
      // An opcode the decode makes this kind, an atomic's step now and then
      // (done_row 0 its A1, a load; 3 its A3, a store); its operand map.
      o.drow = u(4) == 0 ? 3 : 0;
      o.opc = pool(o.kind, o.drow).pick(r);
      dectb::R::OpClass oc;
      dectb::classOf(o.opc, o.drow, false, oc);
      auto sl = [](int x) { return x < 0 ? 3u : unsigned(x); };
      o.sl[0] = sl(oc.base_src);
      o.sl[1] = sl(oc.index_src);
      o.sl[2] = sl(oc.data_src);
      cov_atom += o.drow != 0 && ccv::skel::opByCode(o.opc)->cls == ccv::skel::kAtomic;
      unsigned placed = 0;
      for (unsigned m = 0; m < kM; ++m) {
        const unsigned s = o.sl[m];
        if (s == 3) continue;
        if ((placed >> s) & 1u) {
          ++cov_shared;
          continue;
        }
        placed |= 1u << s;
        place(f, o.swid[s], o.spos[s]);
        o.lsrc |= 1u << s;
        if (o.swid[s] == 1) ++cov_w16;
        if (o.swid[s] == 2) ++cov_w8;
      }
      if (o.kind != Fence && o.sl[1] == 3) ++cov_noidx;
      if (o.kind == Load && o.sl[0] == 3) ++cov_slot;
      if (p(0.2)) {
        o.lsrc |= u(8);
        ++cov_super;
      }
      if (((f >> j) & ((f >> j) + 1u)) != 0) ++cov_split;   // not contiguous
      ++n;
    }
    // The footprints' other pipes: continuations.
    for (unsigned j = 0; j < kK; ++j)
      if (x.v[j])
        for (unsigned k = j + 1; k < kK; ++k)
          if ((x.op[j].foot >> k) & 1u) {
            x.v[k] = true;
            x.op[k] = Op{};
            x.op[k].spos[0] = u(4);
            ++cov_cont;
          }
    if (n > 1) ++cov_multi;
    x.rd.resize(kK * kM * kN);
    for (auto &b : x.rd) b = uint8_t(r());
    return x;
  }
};

int run(const std::string &scenario, const char *vcd, const std::string &control) {
  Bench b(vcd);
  b.control = control;
  for (int i = 0; i < 8; ++i) b.step(true);
  b.step();   // the flopped reset (RST-1) falls a cycle after its input
  Gen gen(0x3e3e1 + scenario.size());
  const unsigned n = scenario == "idle" ? 3000 : scenario.empty() ? 20000 : 6000;
  for (unsigned i = 0; i < n; ++i) {
    const uint64_t a = b.cyc + 1;   // the group whose lead is driven this cycle
    bool go = false;
    if (scenario == "medium") go = gen.p(0.3);
    else if (scenario == "high") go = gen.p(0.95);
    else if (scenario.empty()) go = gen.p(0.7);
    if (go) {
      Group x = gen.make();
      bool any = false;
      for (unsigned j = 0; j < kK; ++j) any = any || x.v[j];
      if (any) b.gs[a] = x;
    }
    b.step();
  }
  for (unsigned i = 0; i < 6; ++i) b.step();
  if (scenario != "idle") {
    bool cov = gen.cov_noidx && gen.cov_slot && gen.cov_w16 && gen.cov_w8 && gen.cov_split && gen.cov_cont &&
               gen.cov_multi && gen.cov_super && gen.cov_atom;
    // shared (two operands of one source) is counted, not required: no
    // opcode's operand map reads a source twice (rcu_dec_pkg).
    for (unsigned k = 0; k < 5; ++k) cov = cov && gen.cov_kind[k];
    if (!cov) {
      std::fprintf(stderr, "rcu_mem: coverage: load %u store %u pload %u pstore %u fence %u noidx %u slot %u "
                           "w16 %u w8 %u split %u cont %u multi %u super %u shared %u atom %u\n",
                   gen.cov_kind[0], gen.cov_kind[1], gen.cov_kind[2], gen.cov_kind[3], gen.cov_kind[4],
                   gen.cov_noidx, gen.cov_slot, gen.cov_w16, gen.cov_w8, gen.cov_split, gen.cov_cont,
                   gen.cov_multi, gen.cov_super, gen.cov_shared, gen.cov_atom);
      ++b.fails;
    }
  }
  std::printf("rcu_mem: %s%s%s: %llu cycles, %u lanes, %u values checked, %u mismatches: %s\n",
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
        std::fprintf(stderr, "rcu_mem: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
    if (!std::strcmp(argv[i], "--control") && i + 1 < argc) control = argv[i + 1];
  }
  return run(scenario, vcd, control);
}
