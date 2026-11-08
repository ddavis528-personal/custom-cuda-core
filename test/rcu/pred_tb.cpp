//===-- pred_tb.cpp - rcu_pred against a value model ----------------------===//
//
// Drives rtl/rcu/rcu_pred.sv and holds it, every cycle, to a value model of
// the predicate file's rules (Predicate file tab; the RCU model's stage I
// and its gatherWrites/commit, sim/rcu/rcu_core.cpp):
//
//   issue    valid (and R's guard lead) in t, payload in t+1 (A), the A+1
//            flops after t+1's edge: active, gv (S), pst (P), R's RA, RB,
//            rlow and branch lead. The guard is the row before A's writes
//            with the forward of MIU's writes landing in A.
//   MIU      lead in t, pred_result in t+1, written at t+1's edge.
//   merge    valid in t, rows in t+1, data in t+2, written at t+2's edge:
//            mm ? val : (merge ? old : 0) on lanes m, old read at write
//            time before that cycle's writes.
//   demotion valid in t, row in t+1, the row on dq in t+2, before that
//            cycle's writes.
//
// The bench keeps the module's input contract: no write names the zero
// predicate; ports on one row in a cycle write disjoint lanes (one
// deliberate pair: a predicate-only copy's inactive lanes beside MIU's
// return); no guard is written by a merge port in its own A; a guarded R
// op's lead names its guard.
//
// Runs: directed cases, then random traffic. --cg <idle|medium|high> <vcd>
// runs one clock-gating scenario (tools/check-cg.py). --control nofwd
// models no MIU forward, --control nomerge a merge's old value as 0; each
// run must fail (test/rcu/run-rtl.sh).
// Exit 0 only with no mismatch.
//===----------------------------------------------------------------------===//
#include "Vrcu_pred.h"
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

namespace {

constexpr unsigned kRows = 48, kZP = 63, kW = 6, kNS = 9, kSR = 8, kNK = 4, kNQ = 13, kNM = 4,
                   kND = 4;
constexpr uint32_t kAll = 0xffffffffu;

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

struct Iss {   // one slot's issue
  unsigned slot, g;
  bool neg, gt, pdt, br;
  uint32_t im;
  unsigned imm;   // R: [13:0]
  unsigned ft = 0;   // S: footprint (sections), disjoint among a cycle's lane messages
  bool lm = false;   // S: sends a lane message (lane, SFU or GPR copy)
};
struct Ld { unsigned slot, p; bool we; uint32_t am, pr; };
struct Mg { unsigned port, row, orow; bool mrg; uint32_t m, mm, val; };
struct Dm { unsigned port, row; };
struct Cycle {
  std::vector<Iss> iss;
  std::vector<Ld> ld;
  std::vector<Mg> mg;
  std::vector<Dm> dm;
};

extern int g_argc;
extern char **g_argv;
bool g_nofwd = false, g_nomerge = false, g_spbown = false;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vrcu_pred> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  std::array<uint32_t, kRows> row{};
  std::array<bool, kRows> known{};
  Cycle s1, s2;
  unsigned cov_spb = 0, cov_fwd = 0, cov_neg = 0, cov_force = 0, cov_pdata = 0, cov_merge = 0, cov_nomerge = 0, cov_br = 0, cov_zp = 0, cov_dm = 0;

  explicit Bench(const char *vcd_path) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vrcu_pred>(ctx.get());
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
  void fail(const char *fmt, unsigned a, unsigned b, uint32_t c, uint32_t d) {
    if (++fails <= 20) {
      std::fprintf(stderr, "pred: cycle %llu: ", (unsigned long long)cyc);
      std::fprintf(stderr, fmt, a, b, c, d);
      std::fputc('\n', stderr);
    }
  }
  uint32_t rd(unsigned p) const { return p < kRows ? row[p] : 0u; }
  bool kn(unsigned p) const { return p >= kRows || known[p]; }
  /// A read in A: the row, with the forward of MIU's writes landing then.
  uint32_t fwd(unsigned p, const std::vector<Ld> &lands, bool *hit = nullptr) const {
    uint32_t v = rd(p);
    if (g_nofwd) return v;
    for (const Ld &l : lands)
      if (l.we && l.p == p && p < kRows) {
        v = (v & ~l.am) | (l.pr & l.am);
        if (hit) *hit = true;
      }
    return v;
  }

  /// One cycle: `next` starts; s1's payloads and s2's data go in.
  void step(const Cycle &next, bool rst = false) {
    dut->rst_n = !rst;
    dut->iv_cr01h = 0;
    dut->lgu_cr01h = 0;
    dut->mv_cr01h = 0;
    dut->mwe_cr01h = 0;
    dut->qv_cr00h = 0;
    dut->dv_cr00h = 0;
    for (const Iss &i : next.iss) {
      put(dut->iv_cr01h, i.slot, 1, 1);
      if (i.slot == kSR && i.gt) {
        dut->lgu_cr01h = 1;
        dut->lgp_cr01h = i.g;
      }
    }
    for (const Ld &l : next.ld) {
      put(dut->mv_cr01h, l.slot, 1, 1);
      put(dut->mwe_cr01h, l.slot, 1, l.we);
      put(dut->mp_cr01h, l.slot * kW, kW, l.p);
      put(dut->mam_cr01h, l.slot * 32, 32, l.am);
    }
    for (const Mg &m : next.mg) put(dut->qv_cr00h, m.port, 1, 1);
    for (const Dm &d : next.dm) put(dut->dv_cr00h, d.port, 1, 1);
    // Payloads a cycle on; unused fields hold.
    for (const Iss &i : s1.iss) {
      put(dut->gd_cr02h, i.slot * kW, kW, i.g);
      put(dut->ng_cr02h, i.slot, 1, i.neg);
      put(dut->im_cr02h, i.slot * 32, 32, i.im);
      put(dut->gt_cr02h, i.slot, 1, i.gt);
      put(dut->pdt_cr02h, i.slot, 1, i.pdt);
      if (i.slot < kNK) {
        put(dut->ft_cr02h, i.slot * kNK, kNK, i.ft);
        put(dut->lm_cr02h, i.slot, 1, i.lm);
      }
      if (i.slot == kSR) {
        dut->br_cr02h = i.br;
        dut->rimm_cr02h = i.imm;
      }
    }
    for (const Ld &l : s1.ld) put(dut->mr_cr02h, l.slot * 32, 32, l.pr);
    for (const Mg &m : s1.mg) {
      put(dut->qrow_cr01h, m.port * kW, kW, m.row);
      put(dut->qorow_cr01h, m.port * kW, kW, m.orow);
      put(dut->qmrg_cr01h, m.port, 1, m.mrg);
    }
    for (const Dm &d : s1.dm) put(dut->drow_cr01h, d.port * kW, kW, d.row);
    for (const Mg &m : s2.mg) {
      put(dut->qm_cr02h, m.port * 32, 32, m.m);
      put(dut->qmm_cr02h, m.port * 32, 32, m.mm);
      put(dut->qval_cr02h, m.port * 32, 32, m.val);
    }
    dut->rcu_core_clk = 0;
    eval();

    struct Want { unsigned what, idx; uint32_t v; };
    std::vector<Want> want;   // after the edge
    // sec_pred_bit_a: lane l, section k = active[o][l] of k's owner o, 0
    // without one; a section whose owner's active is unknown is not checked.
    std::array<uint32_t, kNK> spb{}, spb_kn{};
    spb_kn.fill(kAll);
    bool spb_first = true;
    if (!rst) {
      // Demotion reads, before this cycle's writes.
      for (const Dm &d : s2.dm) {
        if (!kn(d.row)) continue;
        ++checked;
        ++cov_dm;
        const uint32_t got = uint32_t(get(dut->dq_cr02h, d.port * 32, 32));
        if (got != rd(d.row)) fail("demotion port %u row %u: %08x, want %08x", d.port, d.row, got, rd(d.row));
      }
      // Stage I for s1's issues (A now): MIU's writes landing now are s1's loads.
      for (const Iss &i : s1.iss) {
        const unsigned gp = (i.slot == kSR && !i.gt) ? kZP : i.g;
        if (!kn(gp)) {
          if (i.slot < kNK && i.lm)
            for (unsigned k = 0; k < kNK; ++k)
              if ((i.ft >> k) & 1u) spb_kn[k] = 0;
          continue;
        }
        bool hit = false;
        const uint32_t raw = fwd(gp, s1.ld, &hit);
        const uint32_t gv = i.neg ? ~raw : raw;
        const bool gated = i.gt && !i.pdt;
        const uint32_t act = i.im & (gated ? gv : kAll);
        cov_fwd += hit;
        cov_neg += i.neg;
        cov_force += !gated;
        cov_pdata += i.pdt;
        cov_zp += gp == kZP;
        want.push_back({0, i.slot, act});
        // spbown (control): the first lane message owns every section.
        const unsigned ft = g_spbown ? (spb_first ? 0xfu : 0u) : i.ft;
        if (i.slot < kNK && i.lm) spb_first = false;
        if (i.slot < kNK && i.lm)
          for (unsigned k = 0; k < kNK; ++k)
            if ((ft >> k) & 1u) {
              spb[k] = act;
              cov_spb += act != 0;
            }
        if (i.slot < kNK) want.push_back({1, i.slot, gv});
        if (i.slot >= kNK && i.slot < kSR) want.push_back({2, i.slot - kNK, raw});
        if (i.slot == kSR) {
          const unsigned pa = i.imm & 63, pb = (i.imm >> 7) & 63;
          if (kn(pa) && kn(pb)) {
            const uint32_t va = fwd(pa, s1.ld), vb = fwd(pb, s1.ld);
            want.push_back({3, 0, (i.imm >> 6) & 1u ? ~va : va});
            want.push_back({4, 0, (i.imm >> 13) & 1u ? ~vb : vb});
          }
          want.push_back({5, 0, act & (~act + 1u)});
          want.push_back({6, 0, i.br ? act : 0u});
          want.push_back({7, 0, i.br && act ? 1u : 0u});
          cov_br += i.br && act;
        }
      }
      apply(s2.mg, s1.ld);
    }
    dut->rcu_core_clk = 1;
    eval();
    if (!rst)
      for (unsigned k = 0; k < kNK; ++k)
        for (unsigned l = 0; l < 32; ++l) {
          if (!((spb_kn[k] >> l) & 1u)) continue;
          ++checked;
          const unsigned got = unsigned(get(dut->spb_cr03h, l * kNK + k, 1));
          if (got != ((spb[k] >> l) & 1u)) fail("sec_pred_bit lane %u section %u: %x, want %x", l, k, got, (spb[k] >> l) & 1u);
        }
    for (const Want &w : want) {
      uint32_t got = 0;
      const char *n = "";
      switch (w.what) {
      case 0: got = uint32_t(get(dut->act_cr03h, w.idx * 32, 32)); n = "active slot %u (%u): %08x, want %08x"; break;
      case 1: got = uint32_t(get(dut->gv_cr03h, w.idx * 32, 32)); n = "gv slot %u (%u): %08x, want %08x"; break;
      case 2: got = uint32_t(get(dut->pst_cr03h, w.idx * 32, 32)); n = "pst P%u (%u): %08x, want %08x"; break;
      case 3: got = uint32_t(get(dut->rpa_cr03h, 0, 32)); n = "rpa %u (%u): %08x, want %08x"; break;
      case 4: got = uint32_t(get(dut->rpb_cr03h, 0, 32)); n = "rpb %u (%u): %08x, want %08x"; break;
      case 5: got = uint32_t(get(dut->low_cr03h, 0, 32)); n = "rlow %u (%u): %08x, want %08x"; break;
      case 6: got = uint32_t(get(dut->lbm_cr03h, 0, 32)); n = "lead_br_mask %u (%u): %08x, want %08x"; break;
      case 7: got = uint32_t(dut->lbt_cr03h); n = "lead_br_taken %u (%u): %x, want %x"; break;
      }
      ++checked;
      if (got != w.v) fail(n, w.idx, w.what, got, w.v);
    }
    ++cyc;
    s2 = s1;
    s1 = next;
  }

  /// The write rules at an edge: merges and MIU's loads, old values read
  /// before any of this cycle's writes.
  void apply(const std::vector<Mg> &mg, const std::vector<Ld> &ld) {
    const std::array<uint32_t, kRows> before = row;
    const std::array<bool, kRows> kbefore = known;
    for (const Mg &m : mg) {
      const bool okn = !m.mrg || m.orow >= kRows || kbefore[m.orow];
      const uint32_t old = m.mrg && m.orow < kRows && !g_nomerge ? before[m.orow] : 0u;
      (m.mrg ? cov_merge : cov_nomerge)++;
      const uint32_t d = (m.val & m.mm) | (old & ~m.mm);
      row[m.row] = (row[m.row] & ~m.m) | (d & m.m);
      known[m.row] = (kbefore[m.row] || m.m == kAll) && (okn || (m.m & ~m.mm) == 0);
    }
    for (const Ld &l : ld) {
      if (!l.we) continue;
      row[l.p] = (row[l.p] & ~l.am) | (l.pr & l.am);
      known[l.p] = kbefore[l.p] || l.am == kAll;
    }
  }
};

struct Gen {
  std::mt19937 rng;
  explicit Gen(unsigned seed) : rng(seed) {}
  unsigned rnd(unsigned n) { return unsigned(rng() % n); }
  bool coin(double p) { return std::uniform_real_distribution<double>(0, 1)(rng) < p; }
  uint32_t mask() {
    const unsigned x = rnd(8);
    return x == 0 ? kAll : x == 1 ? 0u : x == 2 ? (kAll << rnd(32)) : uint32_t(rng());
  }
  unsigned prow() { return coin(0.05) ? kZP : rnd(kRows); }

  /// One cycle's new work, each port busy with probability p. s1 is the
  /// work started a cycle ago: its merges land with this cycle's loads, and
  /// write in this cycle's issues' A.
  Cycle cycle(double p, const Cycle &s1) {
    Cycle c;
    std::array<bool, kRows> busy1{};   // rows a merge writes at the edge this work's A ends
    for (const Mg &m : s1.mg) busy1[m.row] = true;
    // Issues: no guard on a row a merge writes in its A.
    auto guard = [&]() {
      for (;;) {
        const unsigned g = prow();
        if (g == kZP || !busy1[g]) return g;
      }
    };
    unsigned ftaken = 0;
    for (unsigned s = 0; s < kNS; ++s) {
      if (!coin(p)) continue;
      Iss i{s, guard(), coin(0.4), coin(0.7), coin(0.15), coin(0.5), mask(), 0};
      if (s < kNK) {
        // A lane message's footprint: sections no other S slot of this
        // cycle has, now and then none left (it sends nothing).
        i.lm = coin(0.8);
        if (i.lm) {
          for (unsigned k = 0; k < kNK; ++k)
            if (!((ftaken >> k) & 1u) && coin(0.4)) i.ft |= 1u << k;
          ftaken |= i.ft;
        } else {
          i.ft = rnd(16);   // ignored without a lane message
        }
      }
      if (s == kSR) {
        const unsigned pa = guard(), pb = guard();
        i.imm = pa | unsigned(coin(0.3)) << 6 | pb << 7 | unsigned(coin(0.3)) << 13;
        if (i.pdt) i.gt = false;   // R ops have no data predicate
      }
      c.iss.push_back(i);
    }
    // Loads landing in this work's A: rows a merge of s1 does not write,
    // but now and then a copy's partner: MIU's active lanes beside the
    // copy's inactive ones.
    std::array<bool, kRows> ltaken{};
    for (unsigned j = 0; j < kNM; ++j) {
      if (!coin(p * 0.5)) continue;
      Ld l{j, rnd(kRows), coin(0.7), mask(), uint32_t(rng())};
      bool ok = false;
      for (int tries = 0; tries < 8 && !ok; ++tries) {
        l.p = rnd(kRows);
        ok = !ltaken[l.p] && !busy1[l.p];
      }
      if (!ok) {
        for (const Mg &m : s1.mg)
          if (!ltaken[m.row] && m.m != kAll && coin(0.5)) {
            l.p = m.row;
            l.am = ~m.m;
            ok = true;
            break;
          }
      }
      if (!ok) continue;
      ltaken[l.p] = l.we;
      if (!l.we) ltaken[l.p] = false;
      c.ld.push_back(l);
    }
    // Merges: distinct rows.
    std::array<bool, kRows> mtaken{};
    for (unsigned q = 0; q < kNQ; ++q) {
      if (!coin(p * 0.6)) continue;
      Mg m{q, rnd(kRows), prow(), coin(0.6), kAll, mask(), uint32_t(rng())};
      if (mtaken[m.row]) continue;
      mtaken[m.row] = true;
      if (q >= 5 && q <= 8) {   // PC: inactive lanes, the old value
        m.m = ~mask();
        m.mm = 0;
        m.mrg = true;
      } else if (q >= 9) {      // PG: the whole row
        m.mm = kAll;
        m.mrg = false;
      }
      c.mg.push_back(m);
    }
    for (unsigned d = 0; d < kND; ++d)
      if (coin(p * 0.4)) c.dm.push_back({d, prow()});
    return c;
  }
};

/// Every row written whole, through the restore ports.
void fill(Bench &b, Gen &g) {
  const Cycle none;
  for (unsigned p = 0; p < kRows; p += 4) {
    Cycle c;
    for (unsigned k = 0; k < 4; ++k) c.mg.push_back({9 + k, p + k, kZP, false, kAll, kAll, uint32_t(g.rng())});
    b.step(c);
  }
  b.step(none);
  b.step(none);
}

void directed(Bench &b) {
  const Cycle none;
  auto run = [&](const Cycle &c) {
    b.step(c);
    b.step(none);
    b.step(none);
  };
  // A guard forwarded from MIU in its own A, and the same read without it.
  Cycle c;
  c.iss.push_back({0, 7, false, true, false, false, kAll, 0});
  c.iss.push_back({kSR, 7, true, true, false, true, 0x00ff00ffu, (9u) | (1u << 6) | (7u << 7)});
  c.ld.push_back({2, 7, true, 0x0000ffffu, 0x12345678u});
  run(c);
  // A copy beside MIU's return on one row, a merge with the old value.
  Cycle m;
  m.mg.push_back({5, 11, 12, true, 0xffff0000u, 0, 0});
  m.mg.push_back({0, 13, 12, true, kAll, 0x0f0f0f0fu, 0xa5a5a5a5u});
  b.step(m);
  Cycle l;
  l.ld.push_back({1, 11, true, 0x0000ffffu, 0xcafef00du});
  b.step(l);
  b.step(none);
  run(Cycle{{}, {}, {}, {{0, 11}, {1, 13}, {2, kZP}}});
  // Unguarded and pdata issues: active is the issue mask.
  Cycle u;
  u.iss.push_back({1, 3, true, false, false, false, 0x13579bdfu, 0});
  u.iss.push_back({2, 3, true, true, true, false, 0x2468ace0u, 0});
  u.iss.push_back({4, 5, false, true, false, false, kAll, 0});
  run(u);
}

int g_argc;
char **g_argv;

int run(const std::string &scenario, const char *vcd) {
  Bench b(vcd);
  const Cycle none;
  for (int i = 0; i < 8; ++i) b.step(none, true);
  b.step(none);
  Gen g(0x9eed);
  if (scenario != "idle") fill(b, g);
  if (scenario.empty()) directed(b);
  const unsigned n = scenario == "idle" ? 3000 : 4000;
  for (unsigned i = 0; i < n; ++i) {
    Cycle c;
    if (scenario == "medium") c = i % 3 == 0 ? g.cycle(0.8, b.s1) : none;
    else if (scenario != "idle") c = g.cycle(0.9, b.s1);
    b.step(c);
  }
  b.step(none);
  b.step(none);
  if (scenario != "idle" && (!b.cov_spb || !b.cov_neg || !b.cov_force || !b.cov_pdata || !b.cov_merge ||
                             !b.cov_nomerge || !b.cov_br || !b.cov_zp || !b.cov_dm ||
                             (!g_nofwd && !b.cov_fwd))) {
    std::fprintf(stderr, "pred: coverage: spb %u fwd %u neg %u force %u pdata %u merge %u nomerge %u br %u zp %u dm %u\n",
                 b.cov_spb, b.cov_fwd, b.cov_neg, b.cov_force, b.cov_pdata, b.cov_merge, b.cov_nomerge, b.cov_br,
                 b.cov_zp, b.cov_dm);
    ++b.fails;
  }
  std::printf("pred%s%s%s %s: %llu cycles, %u values checked, %u mismatches: %s\n",
              g_nofwd ? ", control nofwd:" : "", g_nomerge ? ", control nomerge:" : "",
              g_spbown ? ", control spbown:" : "", scenario.empty() ? "directed+random" : scenario.c_str(),
              (unsigned long long)b.cyc, b.checked, b.fails, b.fails ? "FAIL" : "PASS");
  return b.fails ? 1 : 0;
}

} // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string scenario;
  const char *vcd = nullptr;
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control")) {
      g_nofwd = g_nofwd || !std::strcmp(argv[i + 1], "nofwd");
      g_nomerge = g_nomerge || !std::strcmp(argv[i + 1], "nomerge");
      g_spbown = g_spbown || !std::strcmp(argv[i + 1], "spbown");
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "pred: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd);
}
