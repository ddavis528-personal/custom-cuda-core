//===-- rename_tb.cpp - ooe_rename (go, Rename 1 and 2) against the model ---===//
//
// Runs the model's directed unit tests and its random ones (sim/ooe/
// ooe_test.cpp) and drives ooe_rename as the core will hold it beside
// ooe_rat (test/ooe/ooe_rename_tb.sv; ooe-rtl-plan.md, slice 7's first
// step): the go reads what the model's go read (Core::goLog, as go_tb drives
// it), every candidate shows its head's fields (Core::ratLog's renames, as
// ren1_tb drives them; a head no lane takes shows random ones), and the free
// lists take the model's frees (FreeVec::cycleFrees, as freelist_tb drives
// them). Nothing tells the RTL what was taken or which names: its go takes,
// its Rename 1 picks the lanes, its free lists offer the names its go's
// writer counts ask for, and ooe_rat takes the go's take. Each candidate
// carries its head's Rename 2 attributes (c_x), and ooe_rs's grant is the
// model's allocation of the group, on the ports the model's order gives
// (rendep_tb's numbering), at the edge rendep_tb drives it.
//
// The go's leads and a free's are the next cycle's, so the RTL runs a model
// cycle behind: a cycle is driven at the start of the one after next, once
// the next one's logs and its whole free interval (the pre-cycle hook: the
// frees the inputs made between cycles included) are in. Before the edge,
// the go's takes and lanes must be the model's; after it, every lane of the
// Rename 1 register must be the model's rename: slot, destinations, the new
// names the free lists gave, branch and checkpoint, and every read. And
// ooe_rendep's stage register holds the group a cycle older: its request
// and each port's row must be the model's, as rendep_tb holds them.
//
// A core is skipped when the RTL is not built for it (other slots, widths,
// checkpoints, pool sizes, floors and ceilings (run-rtl.sh builds the
// ceiling test's too) or free-list buffer, or sectioned names: the
// narrow allocator is slice 6). It is stopped, from that cycle on not driven
// at all, at a restore-allocate or an atomic (slice 7's later steps), or
// where the go's inputs and rename's log disagree on what the RTL cannot
// know (a lane order other than the go's, a head's write bits other than
// its rename's, allocations other than the renames' writers); each counted.
//
// Negative controls (RENAME_CONTROL=<name>) perturb the driving and must be
// caught: drop-free (frees never reach the free lists), no-lead (nor their
// leads), no-write-bits (no head's admission bits say it writes, so the go
// asks for no names), no-hold (the go's hold lead never reaches it),
// drop-restore (no checkpoint restore reaches ooe_rat), no-reads (no head's
// attributes say it reads a source), no-grant (ooe_rs's grant never
// reaches rename), no-take-q (the go's pool correction drops the lagged
// take, a check-build input: OA's rev 208) and no-take-q2 (the names' pool
// register drops the older take: OA's rev 219). The last two need names
// that bind: run-rtl.sh's scarce build (RENAME_SCARCE), 144 rows and a
// GPR ceiling of 24, the model's set alike.
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: rename_tb [seeds] | rename_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_rename_tb.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <memory>
#include <random>
#include <string>
#include <vector>

using ccv::ooe::Config;
using ccv::ooe::Core;
using ccv::ooe::kNoEntry;

int ooeTestDirectedPrePostWith(void (*pre)(const Core &), void (*post)(const Core &), void (*cfg)(Config &));
// go_tb's: a slot never holds more heads than the window. The scarce build's
// names (RENAME_SCARCE): the RTL's rows and GPR ceiling.
void renameConfig(Config &c) {
  c.decq_warp_max = 6;
  if (RENAME_SCARCE) {
    c.phys_regs = RENAME_NG;
    c.ren_ceil = RENAME_CLG;
  }
}

namespace {
constexpr unsigned S = RENAME_S, R = RENAME_R, RP = RENAME_RP, C = RENAME_C, GW = RENAME_GW, PW = RENAME_PW,
                   NG = RENAME_NG, NP = RENAME_NP;
constexpr unsigned N = RENAME_N, NR = RENAME_NR, FLG = RENAME_FLG, CLG = RENAME_CLG, FLP = RENAME_FLP, CLP = RENAME_CLP;
constexpr unsigned NC = S * R, PA = 7, LU = 5, LB = 6, LT = 3, H = 2 * R - 1, XM = 6 * R, FB = 8, FK = 4, XW = 20,
                   P = 2 * R;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w ? w : 1; }
constexpr unsigned LS = bits(S), LC = bits(C), LX = bits(XM + 1), W = bits(N);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_rename_tb> dut;
std::string control;
std::mt19937 rng(11);
uint64_t current = 0;
bool skip = false;      // a core this RTL is not built for
bool stopped = false;   // a core past a cycle this slice does not cover: no longer driven
unsigned long long cycles = 0, cores = 0, skipped = 0, stops = 0, takes = 0, lanes = 0, nops = 0, names = 0, pnames = 0,
                   frees = 0, counted = 0, rows = 0, cells = 0, grp_cells = 0, prv_cells = 0, extra = 0, mismatches = 0;
std::vector<uint8_t> ct_rtl;
unsigned long long core_steps = 0;   // the code table the RTL was built with (default settings)

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
template <typename T> void setField(T &w, unsigned lsb, unsigned n, unsigned v) {
  for (unsigned b = 0; b != n; ++b) setBit(w, lsb + b, (v >> b) & 1u);
}
template <typename T> unsigned getField(const T &w, unsigned lsb, unsigned n) {
  unsigned v = 0;
  for (unsigned b = 0; b != n; ++b) v |= unsigned(getBit(w, lsb + b)) << b;
  return v;
}
template <typename T> void clearAll(T &w, unsigned n) { for (unsigned i = 0; i != n; ++i) setBit(w, i, false); }
unsigned sat(unsigned v, unsigned w) { return std::min(v, (1u << w) - 1); }
unsigned gname(unsigned n) { return n * 4; }   // a whole row: the row at position 0

CgRun cg;   // --cg <scenario> <vcd>: a clock-gating unit's bench (cg_trace.h)

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}
void fail(const char *what, unsigned a, unsigned b, unsigned rtl, unsigned model) {
  if (++mismatches <= 8)
    std::fprintf(stderr, "cycle %llu: %s (%u, %u: rtl %u, model %u)\n", cycles, what, a, b, rtl, model);
}

// One model cycle: its logs (the post-cycle hook) and its free lists' whole
// interval (the next pre-cycle hook).
// Its group as Rename 2 and 3 see it (rendep_tb's Cyc): each renamed uop
// with its ports, and the model's rows for the group's entries.
struct Uop {
  Core::RatLog::Ren r;
  unsigned pm = 0, pc = 0;   // its main entry's port, its copy's
};
struct Grp {
  std::vector<Uop> grp;
  std::vector<unsigned> port_of;      // entry -> port in this group, or P
  std::vector<uint8_t> dep, code;     // the model's rows, entry-major (N x N)
  std::vector<uint8_t> valid, rfree;  // each entry valid after the cycle, freed in it
  bool codes = true;
};
struct Cycle {
  Core::GoLog g;
  Core::RatLog w;
  Core::RenEvents ev;
  Grp y;
  std::vector<unsigned> gal, gfr, pal, pfr;
};
std::vector<Grp> past;    // the groups stepped, oldest first: the last three
Cycle prev, cur;          // the cycle to drive, and the next one
bool have_prev = false, have_cur = false;
std::vector<Core::RatLog::Ret> prev_ret;   // the cycle before prev's retirements

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

// A cycle's group and the model's rows for it, after the cycle.
Grp snapGroup(const Core &c) {
  Grp y;
  y.port_of.assign(N, P);
  unsigned ri = 0, mi = 0;
  for (const auto &r : c.ratLog().ren) {
    if (r.rst || r.main == kNoEntry) continue;
    Uop x;
    x.r = r;
    x.pm = r.mem ? R + mi++ : ri++;
    x.pc = r.copy != kNoEntry ? ri++ : 0;
    if (x.pm < P) y.port_of[r.main] = x.pm;
    if (r.copy != kNoEntry && x.pc < P) y.port_of[r.copy] = x.pc;
    y.grp.push_back(x);
  }
  if (ri > R || mi > R) fail("more allocations than ports", 0, 0, ri + mi, R);
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
  y.codes = ctOf(c) == ct_rtl;
  return y;
}

// ooe_rs's registered grant: a group's entries on its ports.
void driveGrant(const Grp *y) {
  clearAll(dut->gnt_v_cq03h, P);
  clearAll(dut->gnt_idx_cq03h, P * W);
  if (!y || control == "no-grant") return;
  for (const Uop &x : y->grp) {
    setBit(dut->gnt_v_cq03h, x.pm, true);
    setField(dut->gnt_idx_cq03h, x.pm * W, W, x.r.main);
    if (x.r.copy != kNoEntry) {
      setBit(dut->gnt_v_cq03h, x.pc, true);
      setField(dut->gnt_idx_cq03h, x.pc * W, W, x.r.copy);
    }
  }
}

// ooe_rendep's stage register against the model's rows for group y, whose
// group ahead is a (allocated at the edge before y's): rendep_tb's compare.
void compareRows(const Grp &y, const Grp *a) {
  std::vector<uint8_t> req(P, 0);
  for (const Uop &x : y.grp) {
    req[x.pm] = 1;
    if (x.r.copy != kNoEntry) req[x.pc] = 1;
  }
  for (unsigned p = 0; p != P; ++p)
    if (getBit(dut->req_cq04h, p) != bool(req[p])) fail("RS request", p, 0, getBit(dut->req_cq04h, p), req[p]);
  for (const Uop &x : y.grp)
    for (unsigned k = 0; k != 2; ++k) {
      const unsigned e = k == 0 ? x.r.main : x.r.copy;
      if (k == 1 && e == kNoEntry) continue;
      const unsigned p = k == 0 ? x.pm : x.pc;
      ++rows;
      const bool prod = k == 1 || x.r.gwe || x.r.pwe;
      if (getBit(dut->row_prod_cq04h, p) != prod) fail("row_prod", p, 0, getBit(dut->row_prod_cq04h, p), prod);
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
        const bool got = getBit(dut->row_dep_cq04h, p * N + j);
        if (want_row[j] && !got) fail("row_dep missing", p, j, 0, 1);
        // ooe_rs's masks: not valid before the row's edge (the cycle ahead's
        // state), freed at it, or the group ahead's.
        if (!want_row[j] && got) {
          if (!a || !a->valid[j] || y.rfree[j] || a->port_of[j] < P) ++extra;
          else fail("row_dep extra", p, j, 1, 0);
        }
        if (want_row[j] && got && y.codes) {
          const unsigned gc = getField(dut->row_code_cq04h, (p * N + j) * 2, 2);
          if (gc != code_row[j]) fail("row_code", p, j, gc, code_row[j]);
        }
      }
      for (unsigned q = 0; q != P; ++q) {
        const bool gg = getBit(dut->grp_dep_cq04h, p * P + q), gp = getBit(dut->prv_dep_cq04h, p * P + q);
        if (gg != bool(want_grp[q])) fail("grp_dep", p, q, gg, want_grp[q]);
        if (gp != bool(want_prv[q])) fail("prv_dep", p, q, gp, want_prv[q]);
        if (gg && want_grp[q] && y.codes) {
          const unsigned c = getField(dut->grp_code_cq04h, (p * P + q) * 2, 2);
          if (c != code_grp[q]) fail("grp_code", p, q, c, code_grp[q]);
        }
        if (gp && want_prv[q] && y.codes) {
          const unsigned c = getField(dut->prv_code_cq04h, (p * P + q) * 2, 2);
          if (c != code_prv[q]) fail("prv_code", p, q, c, code_prv[q]);
        }
      }
    }
}

void clearInputs() {
  clearAll(dut->hv_cq01h, S * H);
  clearAll(dut->ha_cq01h, S * H * PA);
  dut->occ_cq01h = 0;
  dut->occ_l_cq00h = 0;
  dut->rsf_l_cq00h = 0;
  dut->fpr_cq01h = dut->fpm_cq01h = 0;
  dut->flr_cq01h = dut->flm_cq01h = 0;
  dut->ctl_notq = control == "no-take-q";
  dut->ctl_notq2 = control == "no-take-q2";
  clearAll(dut->run_cq01h, S * LB);
  clearAll(dut->ret_cq01h, S * LT);
  dut->reach_cq01h = 0;
  dut->hold_l_cq00h = (1u << S) - 1;
  dut->rbusy_l_cq00h = 0;
  dut->sq_l_cq00h = 0;
  dut->dq_ev_cq01h = 0;
  dut->rob_en_cq01h = 0;
  dut->gfree_l_cq00h = 0;
  dut->pfree_l_cq00h = 0;
  clearAll(dut->gfree_cq01h, NG);
  clearAll(dut->pfree_cq01h, NP);
  clearAll(dut->rstl_cq00h, S);
  clearAll(dut->rgl_cq00h, S * RP);
  clearAll(dut->rpl_cq00h, S * RP);
  clearAll(dut->ret_gwe_cq01h, S * RP);
  clearAll(dut->ret_pwe_cq01h, S * RP);
  clearAll(dut->restore_cq00h, S);
  clearAll(dut->squash_cq00h, S);
  clearAll(dut->release_cq00h, S);
  clearAll(dut->gnt_v_cq03h, P);
  clearAll(dut->gnt_idx_cq03h, P * W);
}

// The go's inputs, as go_tb drives them: decq's heads and rename's and the
// ROB's registers from this cycle, the leads from the next.
void driveGo(const Core::GoLog &g, const Core::GoLog &nx) {
  for (unsigned s = 0; s != S; ++s) setBit(dut->hold_l_cq00h, s, nx.hold[s] && control != "no-hold");
  dut->rbusy_l_cq00h = nx.restore;
  dut->sq_l_cq00h = nx.flush & ((1u << S) - 1);
  for (unsigned s = 0; s != S; ++s) {
    setBit(dut->dq_ev_cq01h, s, g.adm[s] != nx.adm[s]);
    setBit(dut->rob_en_cq01h, s, g.run[s] != nx.run[s] || g.reach[s] != nx.reach[s] || g.ret[s] != nx.ret[s]);
    setBit(dut->occ_cq01h, s, g.occ[s]);
    setBit(dut->occ_l_cq00h, s, nx.occ[s]);
  }
  for (unsigned s = 0; s != S; ++s) {
    const auto &q = g.adm[s];
    for (unsigned p = 0; p != H && p < q.size(); ++p) {
      setBit(dut->hv_cq01h, s * H + p, true);
      unsigned a = q[p];
      if (control == "no-write-bits") a &= ~(3u << 3);
      setField(dut->ha_cq01h, (s * H + p) * PA, PA, a);
    }
    setField(dut->run_cq01h, s * LB, LB, sat(g.run[s], LB));
    setBit(dut->reach_cq01h, s, g.reach[s]);
    setField(dut->ret_cq01h, s * LT, LT, sat(g.ret[s], LT));
  }
}

// Every candidate a random uop; the taken ones are overwritten.
void randomCandidates() {
  for (unsigned c = 0; c != NC; ++c) {
    for (unsigned i = 0; i != 3; ++i) setField(dut->c_src_cq01h, (c * 3 + i) * 4, 4, rng() & 15);
    setField(dut->c_dst_cq01h, c * 4, 4, rng() & 15);
    setField(dut->c_pguard_cq01h, c * 2, 2, rng() & 3);
    setField(dut->c_pdst_cq01h, c * 2, 2, rng() & 3);
    for (unsigned i = 0; i != 2; ++i) setField(dut->c_pq_cq01h, (c * 2 + i) * 2, 2, rng() & 3);
    setBit(dut->c_br_cq01h, c, rng() & 1);
    setField(dut->c_ckpt_cq01h, c * LC, LC, rng() % C);
    setField(dut->c_x_cq01h, c * XW, XW, rng() & ((1u << XW) - 1));
  }
}

// A renamed head's Rename 2 attributes (ooe_rename's c_x).
unsigned attrOf(const Core::RatLog::Ren &r) {
  unsigned x = 0;
  x |= unsigned(r.atomic) << 0;
  x |= unsigned(r.cguard) << 1;
  x |= unsigned(r.cgroup == 7) << 2;
  x |= unsigned(r.nob) << 3;
  if (control != "no-reads") {
    x |= (r.greads & 7u) << 4;
    x |= unsigned(r.gmerge) << 7;
    x |= unsigned(r.pguse) << 8;
    x |= unsigned(r.plogic) << 9;
    x |= unsigned(r.pmerge) << 10;
  }
  x |= (r.cgroup == 7 ? 0u : r.cgroup & 7u) << 11;
  x |= (r.unit & 7u) << 14;
  x |= (r.pgroup & 7u) << 17;
  return x;
}

// prev's retirements a cycle later, as the ROB's retire-stage register holds them.
void driveRetire() {
  std::vector<unsigned> rport(S, 0);
  for (const auto &r : prev_ret) {
    const unsigned q = r.slot * RP + rport[r.slot]++;
    setBit(dut->ret_gwe_cq01h, q, r.gwe);
    setField(dut->ret_dst_cq01h, q * 4, 4, r.dst);
    setField(dut->ret_gname_cq01h, q * GW, GW, gname(r.gname));
    setBit(dut->ret_pwe_cq01h, q, r.pwe);
    setField(dut->ret_pdst_cq01h, q * 2, 2, r.pdst);
    setField(dut->ret_pname_cq01h, q * PW, PW, r.pname);
  }
}

// Why a core stopped: the go's log missing, a restore-allocate or an
// atomic, the lane order, a head's write bits, the allocations, the takes.
enum Why { kNoLog, kRstAtomic, kOrder, kBits, kAlloc, kTook, kWhys };
const char *const kWhyName[kWhys] = {"no-log", "rst-atomic", "order", "write-bits", "allocs", "took"};
unsigned long long why[kWhys] = {};
void stop(Why w) {
  stopped = true;
  ++stops;
  ++why[w];
}

// Cycle P, driven with the leads of N, then compared.
void step(const Cycle &P, const Cycle &N) {
  const Core::GoLog &g = P.g;
  const Core::RatLog &w = P.w;
  if (!g.valid || g.adm.size() != S || !N.g.valid || N.g.adm.size() != S) { stop(kNoLog); return; }
  for (const auto &r : w.ren)
    if (r.rst || r.atomic) { stop(kRstAtomic); return; }
  if (g.lanes.size() > R) { fail("more lanes than the width", 0, 0, unsigned(g.lanes.size()), R); stop(kOrder); return; }
  // The go's lanes, each with its rename: rename order is lane order. A
  // head with neither class bit (an exit, a decode fault) takes its lane
  // and renames nothing, so no rename logs it; any other lane is the next
  // rename, of its slot, its write bits its admission bits'.
  std::vector<const Core::RatLog::Ren *> lane(g.lanes.size(), nullptr);
  std::vector<unsigned> head(S, 0);
  unsigned gw = 0, pw = 0, j = 0;
  for (unsigned k = 0; k != g.lanes.size(); ++k) {
    const unsigned s = g.lanes[k].first, h = g.lanes[k].second;
    if (s >= S || h != head[s]++ || h >= g.adm[s].size()) { stop(kOrder); return; }
    const uint8_t a = g.adm[s][h];
    if ((a & 3u) == 0) { ++nops; continue; }
    if (j == w.ren.size() || w.ren[j].slot != s) { stop(kOrder); return; }
    const auto &r = w.ren[j++];
    if (bool((a >> 3) & 1u) != r.gwe || bool((a >> 4) & 1u) != r.pwe) { stop(kBits); return; }
    if (r.main == kNoEntry || bool((a >> 1) & 1u) != r.mem || bool((a >> 2) & 1u) != (r.copy != kNoEntry)) {
      stop(kBits);
      return;
    }
    lane[k] = &r;
    gw += r.gwe;
    pw += r.pwe;
  }
  if (j != w.ren.size()) { stop(kOrder); return; }
  if (P.gal.size() != gw || P.pal.size() != pw) { stop(kAlloc); return; }
  for (unsigned s = 0; s != S; ++s)
    if (head[s] != g.took[s]) { stop(kTook); return; }
  for (const auto &r : w.ret)
    if (std::count_if(w.ret.begin(), w.ret.end(), [&](const auto &x) { return x.slot == r.slot; }) > RP) {
      fail("more retirements than ports", r.slot, 0, RP + 1, RP);
      stop(kOrder);
      return;
    }

  ++cycles;
  ++core_steps;
  clearInputs();
  driveGo(g, N.g);
  // ooe_rs's frees, as rencred_tb drives them: this cycle's within its
  // prompt count, a thermometer, and last cycle's past it; and their lead.
  auto thermo = [](unsigned n, unsigned w) { return unsigned(n >= w ? (1u << w) - 1u : (1u << n) - 1u); };
  dut->fpr_cq01h = thermo(P.ev.rs_prompt[0], 4);
  dut->fpm_cq01h = thermo(P.ev.rs_prompt[1], 4);
  dut->flr_cq01h = P.ev.rs_late_prev[0];
  dut->flm_cq01h = P.ev.rs_late_prev[1];
  dut->rsf_l_cq00h = N.ev.rs_prompt[0] || N.ev.rs_prompt[1] || N.ev.rs_late_prev[0] || N.ev.rs_late_prev[1];
  randomCandidates();
  for (unsigned k = 0; k != g.lanes.size(); ++k) {
    const unsigned x = g.lanes[k].second * S + g.lanes[k].first;
    // A nop lane's fields are random but its branch bit: it makes no
    // checkpoint (decq's branch bit is its admission bit's).
    if (!lane[k]) { setBit(dut->c_br_cq01h, x, false); continue; }
    const auto &r = *lane[k];
    for (unsigned i = 0; i != 3; ++i) setField(dut->c_src_cq01h, (x * 3 + i) * 4, 4, r.src[i]);
    setField(dut->c_dst_cq01h, x * 4, 4, r.dst);
    setField(dut->c_pguard_cq01h, x * 2, 2, r.pguard);
    setField(dut->c_pdst_cq01h, x * 2, 2, r.pdst);
    for (unsigned i = 0; i != 2; ++i) setField(dut->c_pq_cq01h, (x * 2 + i) * 2, 2, r.pq[i]);
    setBit(dut->c_br_cq01h, x, r.br);
    setField(dut->c_ckpt_cq01h, x * LC, LC, r.ckpt);
    setField(dut->c_x_cq01h, x * XW, XW, attrOf(r));
  }
  // ooe_rs's grant, for the group three steps back.
  driveGrant(past.size() >= 3 ? &past[past.size() - 3] : nullptr);
  // ooe_rat's events, as rat_tb drives them.
  for (const auto &r : w.restore) {
    if (control == "drop-restore") continue;
    setBit(dut->restore_cq00h, r.first, true);
    setField(dut->restore_ckpt_cq00h, r.first * LC, LC, r.second);
  }
  for (unsigned s = 0; s != S; ++s) {
    setBit(dut->squash_cq00h, s, (w.squash >> s) & 1u);
    setBit(dut->release_cq00h, s, (w.release >> s) & 1u);
  }
  std::vector<unsigned> rport(S, 0);
  for (const auto &r : w.ret) {
    const unsigned q = r.slot * RP + rport[r.slot]++;
    setBit(dut->rgl_cq00h, q, r.gwe);
    setBit(dut->rpl_cq00h, q, r.pwe);
  }
  driveRetire();
  // The free lists: this cycle's frees, the next one's lead.
  if (control != "drop-free") {
    for (unsigned p : P.gfr) setBit(dut->gfree_cq01h, p, true);
    for (unsigned p : P.pfr) setBit(dut->pfree_cq01h, p, true);
  }
  dut->gfree_l_cq00h = !N.gfr.empty() && control != "no-lead";
  dut->pfree_l_cq00h = !N.pfr.empty() && control != "no-lead";
  frees += P.gfr.size() + P.pfr.size();
  dut->ooe_core_clk = 0;
  dut->eval();

  // Before the edge: the go's takes, per slot a thermometer.
  for (unsigned s = 0; s != S; ++s) {
    unsigned t = 0;
    for (unsigned r = 0; r != R; ++r) t += getBit(dut->take_cq02h, s * R + r);
    for (unsigned r = 0; r != R; ++r)
      if (getBit(dut->take_cq02h, s * R + r) != (r < t)) fail("take is no thermometer", s, r, t, 0);
    if (t != g.took[s]) fail("take differs", s, 0, t, g.took[s]);
    takes += t;
  }
  // Rename's counters as the go reads them: each credit on time (the
  // lagged counter less its lagged take), each slot's unmet floor and room.
  for (unsigned r = 0; r != 4; ++r) {
    if (r == 3 && g.cred[3] >= 1000) continue;   // predicates not renamed
    const unsigned got = getField(dut->chk_cred_cq04h, r * 8, 8);
    if (got != g.cred[r]) fail("credit differs", r, 0, got, g.cred[r]);
  }
  for (unsigned s = 0; s != S; ++s) {
    auto chk = [&](const char *what, const auto &port, unsigned want) {
      const unsigned got = getField(port, s * LU, LU);
      if (got != sat(want, LU)) fail(what, s, 0, got, sat(want, LU));
    };
    if (std::getenv("RENAME_VERBOSE") && mismatches < 3 &&
        (getField(dut->chk_unmet_g_cq04h, s * LU, LU) != sat(g.unmet_g[s], LU) ||
         getField(dut->chk_room_g_cq04h, s * LU, LU) != sat(g.room_g[s], LU)))
      std::fprintf(stderr, "  step %llu of core %llu: slot %u occ %d unmet_g %u room_g %u, rtl %u %u\n", core_steps, cores, s,
                   int(g.occ[s]), g.unmet_g[s], g.room_g[s], getField(dut->chk_unmet_g_cq04h, s * LU, LU),
                   getField(dut->chk_room_g_cq04h, s * LU, LU));
    chk("unmet GPR floor differs", dut->chk_unmet_g_cq04h, g.unmet_g[s]);
    chk("unmet predicate floor differs", dut->chk_unmet_p_cq04h, g.unmet_p[s]);
    chk("GPR room differs", dut->chk_room_g_cq04h, g.room_g[s]);
    chk("predicate room differs", dut->chk_room_p_cq04h, g.room_p[s]);
  }
  ++counted;
  tick();
  prev_ret = w.ret;

  // ooe_rendep's stage register: the group a step back, its group ahead two.
  if (!past.empty()) compareRows(past.back(), past.size() >= 2 ? &past[past.size() - 2] : nullptr);
  past.push_back(P.y);
  if (past.size() > 3) past.erase(past.begin());

  // After it: the Rename 1 register, lane by lane; a nop lane writes nothing.
  for (unsigned k = 0; k != R; ++k) {
    const bool v = getBit(dut->q_v_cq03h, k), want = k < g.lanes.size();
    if (v != want) { fail("lane valid differs", k, 0, v, want); continue; }
    if (!v) continue;
    if (!lane[k]) {
      if (getField(dut->q_slot_cq03h, k * LS, LS) != g.lanes[k].first)
        fail("nop lane's slot", k, 0, getField(dut->q_slot_cq03h, k * LS, LS), g.lanes[k].first);
      if (getBit(dut->q_gwe_cq03h, k) || getBit(dut->q_pwe_cq03h, k)) fail("a nop lane writes", k, 0, 1, 0);
      continue;
    }
    const auto &r = *lane[k];
    ++lanes;
    auto eq = [&](const char *what, unsigned i, unsigned got, unsigned want) {
      if (got != want) fail(what, k, i, got, want);
    };
    eq("slot", 0, getField(dut->q_slot_cq03h, k * LS, LS), r.slot);
    eq("GPR write", 0, getBit(dut->q_gwe_cq03h, k), r.gwe);
    eq("predicate write", 0, getBit(dut->q_pwe_cq03h, k), r.pwe);
    eq("branch", 0, getBit(dut->q_br_cq03h, k), r.br);
    if (r.gwe) { eq("destination", 0, getField(dut->q_dst_cq03h, k * 4, 4), r.dst); ++names; }
    if (r.gwe) eq("new GPR name", 0, getField(dut->q_gname_cq03h, k * GW, GW), gname(r.gname));
    if (r.pwe) { eq("predicate destination", 0, getField(dut->q_pdst_cq03h, k * 2, 2), r.pdst); ++pnames; }
    if (r.pwe) eq("new predicate name", 0, getField(dut->q_pname_cq03h, k * PW, PW), r.pname);
    if (r.br) eq("checkpoint", 0, getField(dut->q_ckpt_cq03h, k * LC, LC), r.ckpt);
    for (unsigned i = 0; i != 3; ++i) eq("source read", i, getField(dut->q_g_cq03h, (k * 4 + i) * GW, GW), gname(r.psrc[i]));
    eq("old destination", 0, getField(dut->q_g_cq03h, (k * 4 + 3) * GW, GW), gname(r.pold));
    eq("guard", 0, getField(dut->q_p_cq03h, (k * 4 + 0) * PW, PW), r.ppguard);
    eq("old predicate destination", 0, getField(dut->q_p_cq03h, (k * 4 + 1) * PW, PW), r.ppold);
    for (unsigned i = 0; i != 2 && r.plogic; ++i)
      eq("predicate-logic source", i, getField(dut->q_p_cq03h, (k * 4 + 2 + i) * PW, PW), r.pqn[i]);
  }
}

void newCore(const Core &c) {
  current = c.serial();
  ++cores;
  const auto &cfg = c.config();
  const auto &gf = c.gprFree(), &pf = c.predFree();
  skip = c.slots() != S || cfg.ckpts != C || cfg.rename_width > R || cfg.retire_per_rob > RP ||
         cfg.pred_zero != (1u << PW) - 1 || cfg.sectioned || !cfg.rename_preds || gf.capacity() != NG || pf.capacity() != NP ||
         gf.bufferCap() != FB || gf.banks() != FK || pf.bufferCap() != FB || pf.banks() != FK || c.rsEntries() != N ||
         c.rsRcuEntries() != NR || cfg.ren_floor != FLG || cfg.ren_ceil != CLG || cfg.pred_ren_floor != FLP ||
         cfg.pred_ren_ceil != CLP;
  skipped += skip;
  stopped = false;
  have_prev = have_cur = false;
  // The last core's retirements leave ooe_rat's retire stage as its leads
  // said, then the reset.
  clearInputs();
  driveRetire();
  tick();
  prev_ret.clear();
  past.clear();
  core_steps = 0;
  // The flopped reset (RST-1), as go_tb's: its last edge is the model's
  // first clock, so the rotation starts where the model's does. The free
  // lists refill an edge later than the model's, at the end of the first
  // cycle, which allocates nothing.
  clearInputs();
  dut->ooe_rst_r00h = 1;
  tick();
  tick();
  dut->ooe_rst_r00h = 0;
  tick();
  if (!skip && (!gf.cycleFrees().empty() || !pf.cycleFrees().empty())) fail("a free before a core's first cycle", 0, 0, 1, 0);
}

void pre(const Core &c) {
  if (c.serial() != current) { newCore(c); return; }
  if (skip || stopped || !have_cur) return;
  // cur's whole free interval is in.
  cur.gal = c.gprFree().cycleAllocs();
  cur.gfr = c.gprFree().cycleFrees();
  cur.pal = c.predFree().cycleAllocs();
  cur.pfr = c.predFree().cycleFrees();
  if (have_prev) step(prev, cur);
  prev = cur;
  have_prev = true;
  have_cur = false;
}

void post(const Core &c) {
  if (c.serial() != current) newCore(c);   // a core no pre-cycle hook saw: skipped below
  if (skip) return;
  if (stopped) return;
  cur.g = c.goLog();
  cur.w = c.ratLog();
  cur.y = snapGroup(c);
  cur.ev = c.renEvents();
  have_cur = true;
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("RENAME_CONTROL")) control = c;
  {
    Config base;
    Core c(base);
    ct_rtl = ctOf(c);
  }
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_rename_tb>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  // A reset before anything: a core's first tick (its retirements' leads)
  // comes before its own reset, and the registers start unknown.
  clearInputs();
  dut->ooe_rst_r00h = 1;
  tick();
  tick();
  dut->ooe_rst_r00h = 0;
  // The directed tests in the ordinary run; a scenario is the random tests'.
  const int model_fails =
      (cg.on() ? 0 : ooeTestDirectedPrePostWith(pre, post, renameConfig)) + cg.run(seeds, pre, post, renameConfig);
  cg.close();
  dut->final();
  std::printf("rename_tb control=%s seeds=%u cores=%llu cycles=%llu skipped=%llu stopped=%llu takes=%llu "
              "lanes=%llu nops=%llu gpr-names=%llu pred-names=%llu frees=%llu rows=%llu cells=%llu grp=%llu prv=%llu "
              "masked=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, skipped, stops, takes, lanes, nops, names,
              pnames, frees, rows, cells, grp_cells, prv_cells, extra, mismatches, model_fails);
  std::printf("rename_tb stops:");
  for (unsigned k = 0; k != kWhys; ++k) std::printf(" %s=%llu", kWhyName[k], why[k]);
  std::printf("\n");
  const int rc = mismatches || model_fails || (!cg.on() && (!lanes || !rows)) ? 1 : 0;   // idle has no lanes
  dut.reset();
  ctx.reset();
  return rc;
}
