//===-- rnrs_tb.cpp - rename's lookup into ooe_rs, against the live model ===//
//
// ooe_prodmap, ooe_rendep and ooe_rs as the design wires them
// (test/ooe/ooe_rnrs.sv; OA's rev 168): rename's stage register is ooe_rs's
// rows, and ooe_rs's registered grant is the grant both rename modules read.
// The model drives the outer ports only: rename's fields from its renames
// (Core::ratLog), as rendep_tb drives them, and ooe_rs's requests, frees,
// leads and completions from its RS (Core::wakeLog), as rs_tb drives them.
// Each runs at its stage: after model cycle k, ooe_rendep's lead is k's
// group, its Rename 2 k - 1's, ooe_prodmap's Rename 3 and ooe_rs's
// allocation k - 2's.
//
// After each edge, ooe_rs's grants, valid bits, column flags and every
// valid row are compared with the model's, as rs_tb compares them: so a
// stale bit rename sent that ooe_rs's mask failed to drop, or a producer
// rename missed, is a difference. The rows' line selects are compared on
// cores whose bypass table is the RTL's (rendep-params.py); cores with
// predicate renaming off are driven but not compared (ooe_rendep renames
// predicates). The wrapper's assertion (surviving_named) holds the rows
// to the names: every bit written names an entry of the same group or one
// whose occupant produces one of the row's sources (the bench drives each
// port's source names, chk_*).
//
// Negative controls (RNRS_CONTROL=<name>) perturb the driving and must be
// caught by the assertion: stale-live (a row on its way to ooe_rs also
// names a valid entry from two edges ago or more that none of its sources
// names, which ooe_rs's mask keeps, as a stale name of an entry the mask
// does not cover would) and wrong-names (the assertion's names for each
// port are another port's, so it must fire on correct rows).
// Usage: rnrs_tb [seeds]
//===----------------------------------------------------------------------===//
#include "Vooe_rnrs.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <cstdio>
#include <cstdlib>
#include <deque>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Config;
using ccv::ooe::Core;
using ccv::ooe::kNoEntry;

int ooeTestDirectedHookedWith(void (*hook)(const Core &), void (*cfg)(Config &));
void rsConfig(Config &c) {
  c.fits_stale = 6;
  c.rs_same_edge = false;
}

namespace {
constexpr unsigned N = RN_N, NR = RN_NR, A = RN_A, NG = RN_NG, NP = RN_NP, NCL = RN_NC, P = 2 * A, NS = 4;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned W = bits(N), LP = bits(P), LG = bits(NG), LQ = bits(NP);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_rnrs> dut;
std::string control;
uint64_t current = 0;
std::vector<uint8_t> hcol;
std::vector<uint8_t> ct_rtl;

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
template <typename T> void clearAll(T &w, unsigned n) { for (unsigned i = 0; i != n; ++i) setBit(w, i, false); }

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

// -- A core cycle as the model ended it ------------------------------------------
struct Uop {
  Core::RatLog::Ren r;
  unsigned pm = 0, pc = 0;   // its main entry's port, its copy's
};
struct Snap {
  // The RS (rs_tb's).
  std::vector<unsigned> ralloc, cidx;
  std::vector<uint8_t> rfree, grant, valid, dep, code, prod, fin, iss, wtl3, msd, cfin, sqf;
  bool sq = false, cmpl = false, codes = false, preds = true;
  // Rename's group (rendep_tb's).
  std::vector<Uop> grp;
};
Snap empty() {
  Snap y;
  y.rfree.assign(N, 0); y.grant.assign(N, 0); y.valid.assign(N, 0); y.dep.assign(N * N, 0);
  y.code.assign(N * N, 0); y.prod.assign(N, 0); y.fin.assign(N, 0); y.iss.assign(N, 0); y.wtl3.assign(N, 0);
  y.msd.assign(N, 0); y.cfin.assign(N, 0); y.sqf.assign(N, 0);
  return y;
}
unsigned long long cycles = 0, cores = 0, allocs = 0, rows = 0, cells = 0, skipped = 0, mismatches = 0;
void fail(const char *what, unsigned a, unsigned b, unsigned rtl, unsigned model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "cycle %llu: %s (%u, %u: rtl %u, model %u)\n", cycles, what, a, b, rtl, model);
}
Snap snapCycle(const Core &c) {
  const Core::WakeLog &w = c.wakeLog();
  Snap y = empty();
  y.ralloc = w.ralloc;
  y.codes = c.wakeLinesFit() && ctOf(c) == ct_rtl;
  y.preds = c.config().rename_preds;
  for (unsigned i = 0; i != N; ++i) {
    y.rfree[i] = w.rfree[i];
    y.grant[i] = i < w.grant.size() && w.grant[i];
    y.valid[i] = c.rsValid(i);
    y.prod[i] = c.rsProduces(i);
    y.fin[i] = c.rsFinal(i) || (i < w.conf.size() && w.conf[i]);
    y.iss[i] = c.rsIssued(i);
    y.wtl3[i] = c.rsValid(i) && c.wakeLineChanges(i, 3);
    if (w.rfree[i] && !(i < w.conf.size() && w.conf[i])) y.sq = true;
    y.msd[i] = i < w.hop_msd.size() && w.hop_msd[i];
    y.cfin[i] = i < w.cf_fin.size() && w.cf_fin[i];
    y.sqf[i] = w.rfree[i] && !(i < w.conf.size() && w.conf[i]);
    if (i < w.cmpl.size() && w.cmpl[i]) { y.cmpl = true; y.cidx.push_back(i); }
    for (unsigned j = 0; j != N; ++j) {
      y.dep[i * N + j] = c.depBit(i, j);
      y.code[i * N + j] = uint8_t(c.cellCode(i, j));
    }
  }
  unsigned ri = 0, mi = 0;
  for (const auto &r : c.ratLog().ren) {
    if (r.rst || r.main == kNoEntry) continue;
    Uop x;
    x.r = r;
    x.pm = r.mem ? A + mi++ : ri++;
    x.pc = r.copy != kNoEntry ? ri++ : 0;
    y.grp.push_back(x);
  }
  if (ri > A || mi > A || y.grp.size() > A) fail("more renames than ports", 0, 0, unsigned(y.grp.size()), A);
  return y;
}
std::deque<Snap> hist;   // oldest first; the newest is the model's latest cycle

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  dut->ooe_core_clk = 1;
  dut->eval();
}

// Each allocation of a cycle on its class's next port (rs_tb's numbering).
bool portsOf(const Snap &y, std::vector<unsigned> &entry_of, std::vector<int> &port_of) {
  entry_of.assign(P, N);
  port_of.assign(N, -1);
  unsigned next[2] = {0, 0};
  for (unsigned e : y.ralloc) {
    const unsigned cls = e >= NR;
    if (next[cls] == A) return false;
    const unsigned p = cls * A + next[cls]++;
    port_of[e] = int(p);
    entry_of[p] = e;
  }
  return true;
}

// -- Rename's inputs (rendep_tb's driving) ----------------------------------------
void driveDep(const Snap *y) {
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
    setField(dut->d_gsn_cq01h, (u * NS + 3) * LG, LG, r.pold);
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
void driveMap(const Snap *y) {
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
    for (unsigned g = 0; g != Config::kGroups; ++g) {
      const unsigned code = x.r.nob ? 3u : ct_rtl[(x.r.unit * Config::kGroups + x.r.pgroup) * Config::kGroups + g];
      setField(dut->m_cvc_cq01h, u * 16 + g * 2, 2, code);
    }
  }
}
// The assertion's names: each port's sources, as ooe_rendep reads them (a
// copy reads the old destination and the guard).
void driveChk(const Snap &y) {
  clearAll(dut->chk_gsv_cq01h, P * NS);
  clearAll(dut->chk_gsn_cq01h, P * NS * LG);
  clearAll(dut->chk_psv_cq01h, P * 4);
  clearAll(dut->chk_psn_cq01h, P * 4 * LQ);
  for (unsigned u = 0; u != y.grp.size(); ++u) {
    const Uop &x = y.grp[u];
    const auto &r = x.r;
    unsigned p = x.pm, pc = x.pc;
    if (control == "wrong-names") { p = (p + 1) % P; pc = (pc + 1) % P; }
    for (unsigned s = 0; s != 3; ++s) {
      setBit(dut->chk_gsv_cq01h, p * NS + s, (r.greads >> s) & 1u);
      setField(dut->chk_gsn_cq01h, (p * NS + s) * LG, LG, r.psrc[s]);
    }
    setBit(dut->chk_gsv_cq01h, p * NS + 3, r.gmerge);
    setField(dut->chk_gsn_cq01h, (p * NS + 3) * LG, LG, r.pold);
    const unsigned pn[4] = {r.ppguard, r.pqn[0], r.pqn[1], r.ppold};
    const bool pu[4] = {r.pguse, r.plogic, r.plogic, r.pmerge};
    for (unsigned s = 0; s != 4; ++s) {
      setBit(dut->chk_psv_cq01h, p * 4 + s, pu[s]);
      setField(dut->chk_psn_cq01h, (p * 4 + s) * LQ, LQ, pn[s]);
    }
    if (r.copy == kNoEntry) continue;
    setBit(dut->chk_gsv_cq01h, pc * NS + 3, true);
    setField(dut->chk_gsn_cq01h, (pc * NS + 3) * LG, LG, r.pold);
    setBit(dut->chk_psv_cq01h, pc * 4 + 0, r.cguard);
    setField(dut->chk_psn_cq01h, (pc * 4 + 0) * LQ, LQ, r.ppguard);
  }
}

// -- ooe_rs's other inputs (rs_tb's driving) ----------------------------------------
void driveCmplLead(const Snap *c) {
  clearAll(dut->cmpl_l_cq00h, NCL);
  if (!c) return;
  for (unsigned k = 0; k != c->cidx.size() && k != NCL; ++k) setBit(dut->cmpl_l_cq00h, k, true);
}
void drivePayload(const Snap &c) {
  clearAll(dut->cmpl_idx_cq00h, NCL * W);
  for (unsigned k = 0; k != c.cidx.size() && k != NCL; ++k) setField(dut->cmpl_idx_cq00h, k * W, W, c.cidx[k]);
}
void driveLeads(const Snap *n, const Snap *c) {
  clearAll(dut->req_l_cq00h, P);
  dut->sq_l_cq00h = 0;
  driveCmplLead(c);
  if (!n) return;
  std::vector<unsigned> entry_of;
  std::vector<int> port_of;
  portsOf(*n, entry_of, port_of);
  for (unsigned p = 0; p != P; ++p)
    if (entry_of[p] != N) setBit(dut->req_l_cq00h, p, true);
  dut->sq_l_cq00h = n->sq;
}

void resetRtl() {
  hcol.assign(N, 0);
  clearAll(dut->req_cq01h, P);
  clearAll(dut->sqf_cq01h, N);
  clearAll(dut->msd_cq01h, N);
  clearAll(dut->cfin_cq01h, N);
  driveLeads(nullptr, nullptr);
  clearAll(dut->cmpl_idx_cq00h, NCL * W);
  dut->d_v_l_cq00h = dut->m_v_l_cq00h = 0;
  driveDep(nullptr);
  driveMap(nullptr);
  driveChk(empty());
  clearAll(dut->ctl_row_cq01h, P * N);
  dut->ooe_rst_r00h = 1;
  tick();
  tick();
  dut->ooe_rst_r00h = 0;
  tick();
}

void hook(const Core &c) {
  if (c.rsEntries() != N || c.rsRcuEntries() != NR) {
    std::fprintf(stderr, "rnrs_tb: the core has %u RS entries (%u RCU), the RTL %u (%u)\n", c.rsEntries(),
                 c.rsRcuEntries(), N, NR);
    std::exit(2);
  }
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    resetRtl();
    // Empty cycles ahead of the core's first, so that every lead goes
    // before its event.
    hist.assign(3, empty());
  }
  hist.push_back(snapCycle(c));
  // hist: [a - 1, a, a + 1 (Rename 2), a + 2 (the lead)]; ooe_rs allocates a.
  const Snap &y = hist[1], &n1 = hist[2], &n2 = hist[3];
  ++cycles;
  // Rename's stages: a + 2's lead, a + 1 in Rename 2, a in ooe_prodmap's
  // Rename 3 (a + 1's lead).
  dut->d_v_l_cq00h = !n2.grp.empty();
  driveDep(n1.grp.empty() ? nullptr : &n1);
  dut->m_v_l_cq00h = !n1.grp.empty();
  driveMap(y.grp.empty() ? nullptr : &y);
  // ooe_rs: a's requests, by port; rename numbered the same ports.
  std::vector<unsigned> entry_of;
  std::vector<int> port_of;
  if (!portsOf(y, entry_of, port_of)) { fail("more allocations than ports", 0, 0, A + 1, A); hist.pop_front(); return; }
  std::vector<unsigned> ren_of(P, N);
  for (const Uop &x : y.grp) {
    ren_of[x.pm] = x.r.main;
    if (x.r.copy != kNoEntry) ren_of[x.pc] = x.r.copy;
  }
  for (unsigned p = 0; p != P; ++p)
    if (ren_of[p] != entry_of[p]) fail("rename's port and the RS's differ", p, 0, ren_of[p], entry_of[p]);
  clearAll(dut->req_cq01h, P);
  for (unsigned p = 0; p != P; ++p)
    if (entry_of[p] != N) { setBit(dut->req_cq01h, p, true); ++allocs; }
  driveChk(y);
  // stale-live: port 0's row also names the lowest valid entry that the
  // model's row lacks, allocated two edges ago or more (valid before a - 1).
  clearAll(dut->ctl_row_cq01h, P * N);
  if (control == "stale-live" && entry_of[0] != N)
    for (unsigned j = 0; j != N; ++j)
      if (hist[0].valid[j] && y.valid[j] && !y.rfree[j] && port_of[j] < 0 && !y.dep[entry_of[0] * N + j]) {
        setBit(dut->ctl_row_cq01h, j, true);
        break;
      }
  for (unsigned j = 0; j != N; ++j) {
    setBit(dut->sqf_cq01h, j, y.sqf[j]);
    setBit(dut->msd_cq01h, j, y.msd[j]);
    setBit(dut->cfin_cq01h, j, y.cfin[j]);
    setBit(dut->wtl3_cq00h, j, hist[0].wtl3[j]);
    setBit(dut->fin_cq00h, j, y.fin[j]);
    setBit(dut->gnt_cq01h, j, y.grant[j]);
  }
  drivePayload(n1);
  driveLeads(&n1, &n2);
  tick();
  // The assertion's view, ahead of the edge that checks it (RN_VERBOSE).
  if (dut->chk_bad && std::getenv("RN_VERBOSE")) {
    std::fprintf(stderr, "cycle %llu (core %llu): surviving_named on ports %x\n", cycles, cores, unsigned(dut->chk_bad));
    for (unsigned p = 0; p != P; ++p) {
      if (!getBit(dut->chk_bad, p)) continue;
      const unsigned i = getField(dut->gnt_idx_cq03h, p * W, W);
      std::fprintf(stderr, "  port %u entry %u row:", p, i);
      for (unsigned j = 0; j != N; ++j)
        if (getBit(dut->dep_cq02h, i * N + j))
          std::fprintf(stderr, " %u%s%s", j, y.dep[i * N + j] ? "" : "(model 0)", getBit(dut->valid_out_cq02h, j) ? "" : "(invalid)");
      std::fprintf(stderr, "\n");
      for (unsigned j = 0; j != N; ++j)
        if (getBit(dut->dep_cq02h, i * N + j))
          std::fprintf(stderr, "    entry %u: map g%d %u p%d %u\n", j, int(getBit(dut->dbg_eg, j)),
                       getField(dut->dbg_egn, j * LG, LG), int(getBit(dut->dbg_ep, j)), getField(dut->dbg_epn, j * LQ, LQ));
      for (const Uop &x : y.grp)
        if (x.pm == p || (x.r.copy != kNoEntry && x.pc == p))
          std::fprintf(stderr, "    uop main %u copy %u greads %x src %u %u %u merge %d old %u guard %d %u logic %d %u %u pmerge %d %u\n",
                       x.r.main, x.r.copy, x.r.greads, x.r.psrc[0], x.r.psrc[1], x.r.psrc[2], int(x.r.gmerge), x.r.pold,
                       int(x.r.pguse), x.r.ppguard, int(x.r.plogic), x.r.pqn[0], x.r.pqn[1], int(x.r.pmerge), x.r.ppold);
    }
  }
  // After the edge, as rs_tb: the grants, the column flags, the valid bits
  // and every valid row.
  for (unsigned p = 0; p != P; ++p) {
    const unsigned e = entry_of[p];
    const bool v = getBit(dut->gnt_v_cq03h, p);
    if (e == N) {
      if (v) fail("a port the model did not allocate on was granted", p, 0, 1, 0);
      continue;
    }
    const unsigned idx = getField(dut->gnt_idx_cq03h, p * W, W);
    if (!v) fail("a port the model allocated on was not granted", p, e, 0, 1);
    else if (idx != e) fail("granted a different entry", p, 0, idx, e);
  }
  std::vector<uint8_t> named(N, 0);
  for (unsigned p = 0; p != P; ++p)
    if (entry_of[p] != N)
      for (unsigned j = 0; j != N; ++j) named[j] |= y.dep[entry_of[p] * N + j];
  if (!y.preds) {
    ++skipped;
  } else {
    for (unsigned j = 0; j != N; ++j) {
      hcol[j] = ((hcol[j] && !y.rfree[j]) || named[j]) ? 1 : 0;
      const bool h = getBit(dut->hcol_cq02h, j);
      if (h != bool(hcol[j])) fail("column flag differs", j, 0, h, hcol[j]);
    }
    for (unsigned i = 0; i != N; ++i) {
      const bool v = getBit(dut->valid_out_cq02h, i);
      if (v != bool(y.valid[i])) { fail("valid differs", i, 0, v, y.valid[i]); continue; }
      if (!v) continue;
      ++rows;
      for (unsigned j = 0; j != N; ++j) {
        const bool d = getBit(dut->dep_cq02h, i * N + j);
        if (d != bool(y.dep[i * N + j])) { fail("dependency bit differs", i, j, d, y.dep[i * N + j]); continue; }
        if (!d || !y.codes) continue;
        ++cells;
        const unsigned code = getField(dut->code_cq02h, (i * N + j) * 2, 2);
        if (code != y.code[i * N + j]) fail("line select differs", i, j, code, y.code[i * N + j]);
      }
    }
  }
  hist.pop_front();
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("RNRS_CONTROL")) control = c;
  {
    Config base;
    Core c(base);
    ct_rtl = ctOf(c);
  }
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  dut = std::make_unique<Vooe_rnrs>(ctx.get());
  // The directed tests, then the random ones as rs_tb runs them.
  CgRun cg;
  const int model_fails = ooeTestDirectedHookedWith(hook, rsConfig) + cg.run(seeds, nullptr, hook, rsConfig);
  dut->final();
  std::printf("rnrs_tb control=%s seeds=%u cores=%llu cycles=%llu allocs=%llu rows=%llu cells=%llu "
              "preds_off_cycles=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, allocs, rows, cells, skipped,
              mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
