//===-- rendep_tb.cpp - ooe_rendep (and ooe_prodmap) against the live model ===//
//
// Runs the model's directed and random unit tests (sim/ooe/ooe_test.cpp)
// and, after every core cycle, reads that cycle's renames (Core::ratLog:
// each uop's sources, names, entries and attributes) and the model's
// dependency matrix for the group's entries (Core::depBit, cellCode). The
// RTL runs behind, as rename feeds it: a cycle's group is driven into
// ooe_rendep's Rename 2 a tick after the model renamed it (its lead the
// tick before), into ooe_prodmap's Rename 3 the tick after, and its grant
// (each class's ports in allocation order, a masked load's copy on the RCU
// port after its main) the tick after that.
//
// After each edge, the stage register holds the group last in Rename 2. For
// each of its ports, every cell the model's row holds must be there, as
// the model would have rename send it: a producer in the same group as a
// grp_dep bit to its port, one in the group ahead (allocated at the edge
// before the row's) as a prv_dep bit to that group's port, any other as a
// row_dep bit; and each with the model's line code. A row_dep bit the model
// lacks is allowed only where ooe_rs masks it: an entry not valid before the
// row's edge, freed at it, or one the group ahead was granted (ooe_prodmap
// still held its last occupant's names). Codes are compared when the core
// runs the bypass table the RTL was built with (rendep-params.py, the
// default settings); predicate cells only under renamed predicates.
//
// Negative controls (RD_CONTROL=<name>) perturb the driving and must be
// caught: no-map (ooe_prodmap takes no names, so every producer two groups
// back or more goes missing), late-code (the model's codes taken as late)
// and no-copy-src (a masked load's copy reads the wrong old destination).
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: rendep_tb [seeds] | rendep_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_rendep_tb.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Config;
using ccv::ooe::Core;
using ccv::ooe::kNoEntry;

int ooeTestDirectedHooked(void (*hook)(const Core &));

namespace {
constexpr unsigned N = RD_N, NR = RD_NR, A = RD_A, NG = RD_NG, NP = RD_NP, P = 2 * A, NS = 4;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned W = bits(N), LP = bits(P), LG = bits(NG), LQ = bits(NP);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_rendep_tb> dut;
std::string control;
uint64_t current = 0;
CgRun cg;

// One renamed uop, as the model left it, and its ports.
struct Uop {
  Core::RatLog::Ren r;
  unsigned pm = 0, pc = 0;   // its main entry's port, its copy's
};
// A cycle: its group, the model's rows for the group's entries, and what
// ooe_rs would mask.
struct Cyc {
  std::vector<Uop> grp;
  std::vector<unsigned> port_of;      // entry -> port in this group, or P
  std::vector<uint8_t> dep, code;     // the model's rows, entry-major (N x N)
  std::vector<uint8_t> valid, rfree;  // each entry valid after the cycle, freed in it
  std::vector<uint8_t> eg_of, ep_of;  // debug: whether the entry is its names' model producer
  std::vector<std::string> why;
  bool codes = true, preds = true;
};
std::vector<Cyc> hist;   // newest last
unsigned long long cycles = 0, cores = 0, rows = 0, cells = 0, grp_cells = 0, prv_cells = 0, extra = 0,
                   skipped_codes = 0, skipped_preds = 0, mismatches = 0;
std::vector<uint8_t> ct_rtl;
std::vector<unsigned long long> alloc_at(64, 0);   // debug: the cycle that last allocated each entry
std::vector<unsigned> alloc_name(64, 0);   // the table the RTL was built with (default settings)

template <typename T> void setBit(T &w, unsigned i, bool v) {
  if constexpr (sizeof(T) <= 8) {
    if (v) w |= (T(1) << i); else w &= ~(T(1) << i);
  } else {
    if (v) w[i / 32] |= (1u << (i % 32)); else w[i / 32] &= ~(1u << (i % 32));
  }
}
template <typename T> bool getBit(const T &w, unsigned i) {
  if constexpr (sizeof(T) <= 8) return (w >> i) & 1u;
  else return (w[i / 32] >> (i % 32)) & 1u;
}
template <typename T> void setField(T &w, unsigned lo, unsigned n, unsigned v) {
  for (unsigned i = 0; i != n; ++i) setBit(w, lo + i, (v >> i) & 1u);
}
template <typename T> unsigned getField(const T &w, unsigned lo, unsigned n) {
  unsigned v = 0;
  for (unsigned i = 0; i != n; ++i) v |= unsigned(getBit(w, lo + i)) << i;
  return v;
}
template <typename T> void clearAll(T &w, unsigned n) {
  for (unsigned i = 0; i != n; ++i) setBit(w, i, false);
}

// The code table for a core's settings, as rendep-params.py builds the RTL's.
std::vector<uint8_t> ctOf(const Core &c) {
  const Config &k = c.config();
  const auto &pens = c.wakePens();
  std::vector<uint8_t> t(Config::kUnits * Config::kGroups * Config::kGroups, 3);
  for (unsigned u = 0; u != Config::kUnits; ++u)
    for (unsigned pg = 0; pg != Config::kGroups; ++pg)
      for (unsigned g = 0; g != Config::kGroups; ++g) {
        const unsigned w = k.bypass ? k.bypWake(u, pg, g) : 0;
        if (!w) continue;
        const unsigned pen = w - k.fastOf(u);
        for (unsigned i = 0; i != pens.size(); ++i)
          if (pens[i] == pen) t[(u * Config::kGroups + pg) * Config::kGroups + g] = uint8_t(i);
      }
  return t;
}

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}

std::map<std::string, unsigned long long> kinds;   // mismatches by kind
void fail(const char *what, unsigned p, unsigned j, unsigned got, unsigned want) {
  ++kinds[what];
  if (++mismatches <= 8 || std::getenv("RD_VERBOSE"))
    std::fprintf(stderr, "cycle %llu: %s, port %u, cell %u: rtl %u, model %u\n", cycles, what, p, j, got, want);
}

// ooe_rendep's Rename 2: a group's fields, or none.
void driveDep(const Cyc *y) {
  dut->d_v_cq01h = dut->d_mem_cq01h = dut->d_cp_cq01h = dut->d_atom_cq01h = 0;
  dut->d_gwe_cq01h = dut->d_pwe_cq01h = dut->d_cguard_cq01h = dut->d_cnone_cq01h = dut->d_nob_cq01h = 0;
  dut->d_gsv_cq01h = 0;
  dut->d_psv_cq01h = 0;
  clearAll(dut->d_gname_cq01h, A * LG);
  clearAll(dut->d_pname_cq01h, A * LQ);
  clearAll(dut->d_gsn_cq01h, A * NS * LG);
  clearAll(dut->d_psn_cq01h, A * 4 * LQ);
  dut->d_cg_cq01h = dut->d_unit_cq01h = dut->d_pg_cq01h = 0;
  if (!y) return;
  for (unsigned u = 0; u != y->grp.size(); ++u) {
    const auto &r = y->grp[u].r;
    setBit(dut->d_v_cq01h, u, true);
    setBit(dut->d_mem_cq01h, u, r.mem);
    setBit(dut->d_cp_cq01h, u, r.copy != kNoEntry);
    setBit(dut->d_atom_cq01h, u, r.atomic);
    setBit(dut->d_gwe_cq01h, u, r.gwe && r.gname < NG);
    setField(dut->d_gname_cq01h, u * LG, LG, r.gname);
    setBit(dut->d_pwe_cq01h, u, r.pwe && r.pname < NP);
    setField(dut->d_pname_cq01h, u * LQ, LQ, r.pname);
    for (unsigned s = 0; s != 3; ++s) {
      setBit(dut->d_gsv_cq01h, u * NS + s, (r.greads >> s) & 1u);
      setField(dut->d_gsn_cq01h, (u * NS + s) * LG, LG, r.psrc[s]);
    }
    setBit(dut->d_gsv_cq01h, u * NS + 3, r.gmerge);
    setField(dut->d_gsn_cq01h, (u * NS + 3) * LG, LG, control == "no-copy-src" && r.copy != kNoEntry ? 0 : r.pold);
    const unsigned pn[4] = {r.ppguard, r.pqn[0], r.pqn[1], r.ppold};
    const bool pu[4] = {r.pguse, r.plogic, r.plogic, r.pmerge};
    for (unsigned s = 0; s != 4; ++s) {
      setBit(dut->d_psv_cq01h, u * 4 + s, pu[s]);
      setField(dut->d_psn_cq01h, (u * 4 + s) * LQ, LQ, pn[s]);
    }
    setBit(dut->d_cguard_cq01h, u, r.cguard);
    setBit(dut->d_cnone_cq01h, u, r.cgroup == 7);
    setField(dut->d_cg_cq01h, u * 3, 3, r.cgroup == 7 ? 0 : r.cgroup);
    setField(dut->d_unit_cq01h, u * 3, 3, r.unit);
    setField(dut->d_pg_cq01h, u * 3, 3, r.pgroup);
    setBit(dut->d_nob_cq01h, u, r.nob);
  }
}

// ooe_prodmap's Rename 3: a group's names and ports, or none.
void driveMap(const Cyc *y) {
  dut->m_v_cq01h = dut->m_gwe_cq01h = dut->m_pwe_cq01h = dut->m_cv_cq01h = 0;
  clearAll(dut->m_gname_cq01h, A * LG);
  clearAll(dut->m_pname_cq01h, A * LQ);
  dut->m_pm_cq01h = dut->m_pc_cq01h = 0;
  clearAll(dut->m_cvc_cq01h, A * 16);
  if (!y) return;
  for (unsigned u = 0; u != y->grp.size(); ++u) {
    const Uop &x = y->grp[u];
    setBit(dut->m_v_cq01h, u, true);
    setBit(dut->m_gwe_cq01h, u, x.r.gwe && x.r.gname < NG);
    setBit(dut->m_pwe_cq01h, u, x.r.pwe && x.r.pname < NP);
    setBit(dut->m_cv_cq01h, u, x.r.copy != kNoEntry);
    setField(dut->m_gname_cq01h, u * LG, LG, x.r.gname);
    setField(dut->m_pname_cq01h, u * LQ, LQ, x.r.pname);
    setField(dut->m_pm_cq01h, u * LP, LP, x.pm);
    setField(dut->m_pc_cq01h, u * LP, LP, x.pc);
    // Its codes by consumer group, from the table the RTL is built with, as
    // ooe_rendep's codes_of gives them: late with no bypass.
    for (unsigned g = 0; g != Config::kGroups; ++g) {
      const unsigned code = x.r.nob ? 3u : ct_rtl[(x.r.unit * Config::kGroups + x.r.pgroup) * Config::kGroups + g];
      setField(dut->m_cvc_cq01h, u * 16 + g * 2, 2, code);
    }
  }
}

void driveGrant(const Cyc *y) {
  dut->gnt_v = 0;
  clearAll(dut->gnt_idx, P * W);
  if (!y) return;
  for (const Uop &x : y->grp) {
    setBit(dut->gnt_v, x.pm, true);
    setField(dut->gnt_idx, x.pm * W, W, x.r.main);
    if (x.r.copy != kNoEntry) {
      setBit(dut->gnt_v, x.pc, true);
      setField(dut->gnt_idx, x.pc * W, W, x.r.copy);
    }
  }
}

// The stage register against the model's rows for group y, whose group
// ahead is a (allocated at the edge before y's).
void compare(const Cyc &y, const Cyc *a) {
  for (const Uop &x : y.grp)
    for (unsigned k = 0; k != 2; ++k) {
      const unsigned e = k == 0 ? x.r.main : x.r.copy;
      if (k == 1 && e == kNoEntry) continue;
      const unsigned p = k == 0 ? x.pm : x.pc;
      ++rows;
      const bool prod = k == 1 || x.r.gwe || x.r.pwe;
      if (getBit(dut->row_prod_cq02h, p) != prod) fail("row_prod", p, 0, getBit(dut->row_prod_cq02h, p), prod);
      std::vector<uint8_t> want_row(N, 0), want_grp(P, 0), want_prv(P, 0);
      std::vector<uint8_t> code_row(N, 0), code_grp(P, 0), code_prv(P, 0);
      for (unsigned j = 0; j != N; ++j) {
        if (!y.dep[e * N + j]) continue;
        ++cells;
        const uint8_t c = y.code[e * N + j];
        if (y.port_of[j] < P) {
          want_grp[y.port_of[j]] = 1;
          code_grp[y.port_of[j]] = c;
          ++grp_cells;
        } else if (a && a->port_of[j] < P) {
          want_prv[a->port_of[j]] = 1;
          code_prv[a->port_of[j]] = c;
          ++prv_cells;
        } else {
          want_row[j] = 1;
          code_row[j] = c;
        }
      }
      for (unsigned j = 0; j != N; ++j) {
        const bool got = getBit(dut->row_dep_cq02h, p * N + j);
        if (want_row[j] && !got) fail("row_dep missing", p, j, 0, 1);
        if (!want_row[j] && got) {
          // ooe_rs's masks: not valid before the row's edge (the cycle
          // ahead's state), freed at it, or the group ahead's (granted at
          // the last edge: ooe_prodmap still held its last occupant's names).
          if (!a || !a->valid[j] || y.rfree[j] || a->port_of[j] < P) ++extra;
          else {
            if (std::getenv("RD_VERBOSE") && mismatches < 6) {
              std::fprintf(stderr, "  extra: entry %u (rtl map: g%d n%u p%d n%u), model producer of:%s; consumer k%u reads G",
                           j, int(getBit(dut->dbg_eg, j)), getField(dut->dbg_egn, j * LG, LG), int(getBit(dut->dbg_ep, j)),
                           getField(dut->dbg_epn, j * LQ, LQ), y.why[j].c_str(), k);
              std::fprintf(stderr, "[allocated cycle %llu name %u, now %llu] ", alloc_at[j], alloc_name[j], cycles);
              for (unsigned s2 = 0; s2 != 3; ++s2) if ((x.r.greads >> s2) & 1u) std::fprintf(stderr, " %u", x.r.psrc[s2]);
              std::fprintf(stderr, " old %u(%d) P guard %u(%d) q %u %u(%d) old %u(%d)\n", x.r.pold, int(x.r.gmerge), x.r.ppguard,
                           int(x.r.pguse), x.r.pqn[0], x.r.pqn[1], int(x.r.plogic), x.r.ppold, int(x.r.pmerge));
            }
            fail("row_dep extra", p, j, 1, 0);
          }
        }
        if (want_row[j] && got && y.codes) {
          const unsigned gc = getField(dut->row_code_cq02h, (p * N + j) * 2, 2);
          if (gc != code_row[j]) fail("row_code", p, j, gc, code_row[j]);
        }
      }
      for (unsigned q = 0; q != P; ++q) {
        const bool gg = getBit(dut->grp_dep_cq02h, p * P + q), gp = getBit(dut->prv_dep_cq02h, p * P + q);
        if (gg != bool(want_grp[q])) fail("grp_dep", p, q, gg, want_grp[q]);
        if (gp != bool(want_prv[q])) fail("prv_dep", p, q, gp, want_prv[q]);
        if (gg && want_grp[q] && y.codes) {
          const unsigned c = getField(dut->grp_code_cq02h, (p * P + q) * 2, 2);
          if (c != code_grp[q]) fail("grp_code", p, q, c, code_grp[q]);
        }
        if (gp && want_prv[q] && y.codes) {
          const unsigned c = getField(dut->prv_code_cq02h, (p * P + q) * 2, 2);
          if (c != code_prv[q]) fail("prv_code", p, q, c, code_prv[q]);
        }
      }
    }
}

void resetRtl() {
  hist.clear();
  dut->d_v_l_cq00h = 0;
  dut->m_v_l_cq00h = 0;
  driveDep(nullptr);
  driveMap(nullptr);
  driveGrant(nullptr);
  dut->ooe_rst_r00h = 1;
  tick();
  tick();
  dut->ooe_rst_r00h = 0;
  tick();   // the flopped reset falls: a lead on the next tick is taken
}

void hook(const Core &c) {
  if (c.rsEntries() != N || c.rsRcuEntries() != NR) {
    std::fprintf(stderr, "rendep_tb: the core has %u RS entries (%u RCU), the RTL %u (%u)\n", c.rsEntries(),
                 c.rsRcuEntries(), N, NR);
    std::exit(2);
  }
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    resetRtl();
  }
  ++cycles;
  Cyc y;
  y.port_of.assign(N, P);
  unsigned ri = 0, mi = 0;
  for (const auto &r : c.ratLog().ren) {
    if (r.rst || r.main == kNoEntry) continue;
    Uop x;
    x.r = r;
    x.pm = r.mem ? A + mi++ : ri++;
    x.pc = r.copy != kNoEntry ? ri++ : 0;
    if (x.pm < P) y.port_of[r.main] = x.pm;
    if (r.main < 64) { alloc_at[r.main] = cycles; alloc_name[r.main] = r.gname; }
    if (r.copy < 64) { alloc_at[r.copy] = cycles; alloc_name[r.copy] = r.gname; }
    if (r.copy != kNoEntry && x.pc < P) y.port_of[r.copy] = x.pc;
    y.grp.push_back(x);
  }
  if (ri > A || mi > A || y.grp.size() > A) {
    fail("more allocations than ports", 0, 0, unsigned(y.grp.size()), A);
    return;
  }
  y.dep.assign(size_t(N) * N, 0);
  y.code.assign(size_t(N) * N, 0);
  y.valid.assign(N, 0);
  y.rfree.assign(N, 0);
  const Core::WakeLog &wl = c.wakeLog();
  for (unsigned e = 0; e != N; ++e) {
    y.valid[e] = c.rsValid(e);
    y.rfree[e] = e < wl.rfree.size() && wl.rfree[e];
    for (unsigned j = 0; j != N; ++j) {
      y.dep[e * N + j] = c.depBit(e, j);
      y.code[e * N + j] = uint8_t(c.cellCode(e, j));
    }
  }
  y.eg_of.assign(N, 0); y.ep_of.assign(N, 0); y.why.assign(N, "");
  if (std::getenv("RD_VERBOSE")) {
    for (unsigned nm = 0; nm != c.gprodNames(); ++nm)
      for (unsigned k = 0; k != 2; ++k)
        if (c.gprodOf(nm, k) < N) { y.eg_of[c.gprodOf(nm, k)] = 1; y.why[c.gprodOf(nm, k)] += " G" + std::to_string(nm); }
    for (unsigned nm = 0; nm != c.pprodNames(); ++nm)
      if (c.pprodOf(nm) < N) { y.ep_of[c.pprodOf(nm)] = 1; y.why[c.pprodOf(nm)] += " P" + std::to_string(nm); }
  }
  y.codes = ctOf(c) == ct_rtl;
  if (!y.codes && !y.grp.empty()) ++skipped_codes;
  y.preds = c.config().rename_preds;
  if (control == "late-code" && !y.grp.empty())
    for (auto &v : y.code) v = 3;
  hist.push_back(y);
  // hist: ..., [granted: k-3], [named: k-2], [in Rename 2: k-1], [lead: k]
  const size_t n = hist.size();
  const Cyc *lead = &hist[n - 1];
  const Cyc *dep = n >= 2 ? &hist[n - 2] : nullptr;
  const Cyc *named = n >= 3 ? &hist[n - 3] : nullptr;
  const Cyc *granted = n >= 4 ? &hist[n - 4] : nullptr;
  dut->d_v_l_cq00h = !lead->grp.empty();
  driveDep(dep && !dep->grp.empty() ? dep : nullptr);
  dut->m_v_l_cq00h = dep && !dep->grp.empty();
  driveMap(named && !named->grp.empty() && control != "no-map" ? named : nullptr);
  driveGrant(granted && !granted->grp.empty() ? granted : nullptr);
  tick();
  if (dep && !dep->grp.empty()) {
    if (!dep->preds) ++skipped_preds;
    else compare(*dep, named);
  }
  if (n > 4) hist.erase(hist.begin());
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("RD_CONTROL")) control = c;
  {
    Config base;
    Core c(base);
    ct_rtl = ctOf(c);
  }
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_rendep_tb>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  const int model_fails = (cg.on() ? 0 : ooeTestDirectedHooked(hook)) + cg.run(seeds, nullptr, hook);
  cg.close();
  dut->final();
  for (const auto &k : kinds) std::fprintf(stderr, "  %-28s %llu\n", k.first.c_str(), k.second);
  std::printf("rendep_tb control=%s seeds=%u cores=%llu cycles=%llu rows=%llu cells=%llu grp=%llu prv=%llu "
              "masked_extra=%llu codes_skipped=%llu preds_skipped=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, rows, cells, grp_cells, prv_cells,
              extra, skipped_codes, skipped_preds, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
