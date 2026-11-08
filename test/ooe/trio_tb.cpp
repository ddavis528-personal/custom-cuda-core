//===-- trio_tb.cpp - ooe_rs, ooe_wake and ooe_sched, assembled ------===//
//
// The assembled check (OA's response OI-45): test/ooe/ooe_trio.sv wires the
// three modules as the design does, and this bench drives only their outer
// ports from the live model, each module at its own bench's lag behind the
// model (ooe_rs four cycles, ooe_wake and ooe_sched three; the grant
// register links them, so the lags differ by its one edge). Every link
// between them is the RTL's own: the grant register, the matrix, the wake
// lines and leads, issued, the held misses and miss pulses, and the final
// bits. After each edge each module is held to the model as its own bench
// holds it: ooe_sched's grant register to the model's grants; ooe_rs's
// valid bits and rows; ooe_wake's issued bits and lead lines.
//
// ooe_sched's grants feed ooe_rs and ooe_wake, so one grant that differs
// moves both from then on: the bench reports each core's first divergence,
// and counts every mismatch by kind. The select's live terms (valid and
// past rename, select's issued view, the sections, the age matrices) and
// the RS payload are still the model's (outer ports).
//
// The model runs the composed RTL's timing, its default for the sectioned
// select (docs/ooe-model.md, "The composed RTL's timing"), under the go the
// counters serve (fits_stale 6). ooe_trio asserts V-65 (ooe_sched's issued
// against ooe_rs's issued register).
//
// A known difference, explained and not a grant's (OA's response OI-45,
// rev 153): the ready register in the cycle after a replayed source
// re-issues. The RTL's register holds its stale ready until one of its
// enables comes; the model captures the change on its own edge. 2 bits at
// 100 seeds, none at the gate's 25.
//
// Not compared: the ready bit of a row a squash frees at the next edge.
// ooe_wake drops its producers' lead lines on the squash lead, an edge
// before the model's register sees the squash, so the RTL's bit may fall
// first. The row is dead, and the grant register is still compared
// exactly, so a grant the bit could change would still be caught;
// squash_ready_skipped counts the bits left out.
//
// Negative controls (TRIO_CONTROL, ooe_trio's ctl), ooe_sched's: no-msd,
// no-miss-lead, late-leads, no-alloc-lead, no-ret-hold (ooe_sched sees no
// ret, so the ret hold, OA's rev 293, holds nothing), no-rep-lead (the
// ready register's enable without its replay lead: the bench rewrites the
// enable's flop, the lead being internal), no-idle-r (no migration
// reaches ooe_sched, so RA-17's force never holds R), no-force (the bench
// clears the force register after each edge, the lead kept: ooe_sched's
// idle_r assertion must name it), no-c9h (the model's completions and hint
// acting as they land, without C9h's capture: OA rev 372).
//
// ooe_sched's idle-R force (RA-17): the runs above have no migration
// under idle_r_k, so testIdleR's (three warps keeping R busy beside warp
// swaps) follows, the migration lead driven a cycle ahead from the
// model's sel_mig; R must be forced idle some cycle.
//
// ooe_sched's ret hold: the random runs have no rets, so they are followed
// by testRetHold's mix (every third branch a ret) under ret_hold and its
// settings, which must hold some branch.
//
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD ooe_sched's clock-gating unit measures (its scope is
// u_sched), checking as ever: ooe_sched's enables are leads of ooe_wake's
// lead lines and ooe_rs's rows, which only the assembled modules give it in
// their own frame.
// Usage: trio_tb [seeds] | trio_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_trio.h"
#include "Vooe_trio___024root.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <deque>
#include <map>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Config;
using ccv::ooe::Core;

const char *ooeTestName();
int ooeTestRandomRetsHookedWith(unsigned seeds, void (*hook)(const Core &), void (*cfg)(Config &));
int ooeTestIdleRHookedWith(unsigned seeds, void (*hook)(const Core &), void (*cfg)(Config &));

void trioConfig(Config &c) {
  c.fits_stale = 6;
  c.rs_same_edge = false;
  c.copy_conf_late = true;
  c.req_alloc_lead = true;
  c.req_rows_late = true;
  c.miss_lead = true;
  c.ready_rep_late = true;
  // no-c9h: the model without C9h (OA rev 372), its completions and hint
  // acting as they land, against RTL built for C9h.
  if (const char *s = std::getenv("TRIO_CONTROL"); s && std::string(s) == "no-c9h") c.cmpl_split = c.rx_lag = 0;
}
/// The ret hold's run (OA's rev 293): testRetHold's settings over the trio's.
void trioRetConfig(Config &c) {
  trioConfig(c);
  c.resolve_lag = 1;
  c.resolve_lag_ret_only = 1;
  c.squash_act_lag = 1;
  c.ret_hold = 2;   // OA's rev 320: a held win cancelled after the pick
}
/// RA-17's idle-R run: testIdleR's migrations over the trio's settings, at
/// ooe_trio's IRK.
void trioIdleRConfig(Config &c) {
  trioConfig(c);
  c.idle_r_k = 4;
}

namespace {
#ifndef TR_LW
#define TR_LW 12   // ooe_trio's LW: the lead tag's bits
#endif
#ifndef TR_PW
#define TR_PW 16   // ooe_trio's PW: the payload tag's bits
#endif
constexpr unsigned N = TR_N, NR = TR_NR, NM = N - NR, A = TR_A, P = 2 * A, S = TR_S, L = Core::kWakeLines,
                   NC = TR_NC;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned W = bits(N), LS = bits(S);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_trio> dut;
uint64_t current = 0;
bool following = false;
unsigned long long held = 0;                   // RCU entries the ret hold took (the model's)
unsigned long long migs = 0, forced = 0;       // cycles a migration was in flight, and R forced idle (the model's)
unsigned long long squash_ready_skipped = 0;   // ready bits of rows a squash frees next edge
unsigned long long cycles = 0, cores = 0, skipped = 0, grants = 0, mismatches = 0, diverged = 0,
                   first_sum = 0, compared_cores = 0;
std::map<std::string, unsigned long long> kinds;
bool core_diverged = false, grant_diverged = false;
uint64_t errs_seen = 0;   // the model's errors so far in this core
unsigned control = 0;     // TRIO_CONTROL, as ooe_trio's ctl
std::map<std::string, unsigned long long> first_kinds;   // each core's first mismatch
int prev_rq[TR_N], prev_rd[TR_N], t_prev_req[TR_N], t_prev_ready[TR_N];
unsigned long long grant_cores = 0, grant_first_sum = 0;
unsigned long long core_cycle = 0;
// The issue slots the last edge's issue register held, and their payloads:
// the second payload register's, a cycle after its valid (OA's rev 343).
unsigned prev_v = 0;
uint16_t prev_pay[9] = {};
// The payload (RA-39 (c)): each entry's tag and slot as its allocation
// drove them, and the grant register the issue register reads.
uint16_t tag_of[TR_N], home_of[TR_N], lead_of[TR_N];
unsigned tag_next = 0;
unsigned long long issued_slots = 0;

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

// An entry's issue slot (ccv_ooe_rcu_issue's binding: S0-S3, P0-P3, R),
// one-hot, from its footprint (ooe_select's res: S0-S3, R, P0-P3): its
// lowest resource in the slot order.
uint16_t homeSlot(unsigned res) {
  for (unsigned k = 0; k != 4; ++k) if (res >> k & 1) return uint16_t(1u << k);
  for (unsigned k = 0; k != 4; ++k) if (res >> (5 + k) & 1) return uint16_t(1u << (4 + k));
  return res >> 4 & 1 ? uint16_t(1u << 8) : 0;
}

// One model cycle, all three benches' views of it.
struct Snap {
  Core::WakeLog w;
  std::vector<unsigned> cidx;
  std::vector<uint8_t> valid, iss, prod, fin, sqf, dep, code, line, wtl, wnext, slot, copy, ready_q, req_q, v73;
  std::vector<uint64_t> age;
  std::vector<uint8_t> akind, acls;   // each entry allocated this cycle: its timer's kind and class
  std::vector<uint16_t> ahome;        // and its issue slot, one-hot (RA-39 (c)): its footprint's lowest resource
  uint64_t now = 0;   // the model's cycle
  bool stop_q = false;   // the model's stop lead register
  unsigned active = 0, ncmpl = 0;
  bool sq = false, alloc = false, codes = false;
};
Snap emptySnap() {
  Snap y;
  y.w.grant.assign(N, 0); y.w.kind.assign(N, 0); y.w.cls.assign(N, 0); y.w.rfree.assign(N, 0);
  y.akind.assign(N, 0); y.acls.assign(N, 0); y.ahome.assign(N, 0);
  y.w.stop.assign(N, 0); y.w.cmpl.assign(N, 0); y.w.miss.assign(N, 0);
  y.valid.assign(N, 0); y.iss.assign(N, 0); y.prod.assign(N, 0); y.fin.assign(N, 0); y.sqf.assign(N, 0);
  y.dep.assign(N * N, 0); y.code.assign(N * N, 0); y.line.assign(N * L, 0); y.wtl.assign(N * L, 0);
  y.wnext.assign(N * L, 0); y.slot.assign(N, 0); y.copy.assign(N, 0);
  y.ready_q.assign(N, 0); y.req_q.assign(N, 0); y.v73.assign(N, 0); y.age.assign(N, 0);
  return y;
}
Snap snapCycle(const Core &c) {
  Snap y = emptySnap();
  y.w = c.wakeLog();
  y.now = c.now();
  y.stop_q = c.reqStopQ();
  y.codes = c.wakeLinesFit();
  for (unsigned e : y.w.ralloc) {
    const auto kc = c.wakeKindClass(e);
    y.akind[e] = kc.first;
    y.acls[e] = kc.second;
    y.ahome[e] = homeSlot(c.rsRes(e));
  }
  for (unsigned i = 0; i != N; ++i) {
    y.valid[i] = c.rsValid(i);
    y.iss[i] = c.rsIssued(i);
    y.prod[i] = c.rsProduces(i);
    y.fin[i] = c.rsFinal(i);
    const bool conf = i < y.w.conf.size() && y.w.conf[i];
    y.sqf[i] = i < y.w.rfree.size() && y.w.rfree[i] && !conf;
    y.sq = y.sq || y.sqf[i];
    if (i < y.w.cmpl.size() && y.w.cmpl[i]) { y.cidx.push_back(i); ++y.ncmpl; }
    for (unsigned j = 0; j != N; ++j) {
      y.dep[i * N + j] = c.depBit(i, j);
      y.code[i * N + j] = uint8_t(c.cellCode(i, j));
    }
    for (unsigned k = 0; k != L; ++k) {
      y.line[i * L + k] = c.wakeLine(i, k);
      y.wtl[i * L + k] = c.wakeLineChanges(i, k);
      y.wnext[i * L + k] = c.rsValid(i) && c.wakeLineNext(i, k);
    }
    y.slot[i] = uint8_t(c.rsSlot(i));
    y.copy[i] = c.rsCopy(i);
    y.ready_q[i] = c.readyQ(i);
    y.req_q[i] = c.reqQ(i);
    y.v73[i] = c.rsValid(i) && c.rsEligibleNext(i);
    y.age[i] = c.rsAge(i);
  }
  for (unsigned si = 0; si != S; ++si)
    if (c.slotActive(si)) y.active |= 1u << si;
  y.alloc = !y.w.ralloc.empty();
  return y;
}
std::deque<Snap> H;   // H[k] is model cycle T - 5 + k, T the hook's

bool r_stop() { return dut->rootp->ooe_trio__DOT__u_sched__DOT__stop_cq03h; }

CgRun cg;   // --cg <scenario> <vcd>: a clock-gating unit's bench (cg_trace.h)

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  // no-rep-lead: ooe_sched's ready register enable without its replay lead
  // (the flop rewritten after the edge, from its other leads before it).
  auto *r = dut->rootp;
  const bool drop = control == 6 && r->ooe_trio__DOT__u_sched__DOT__rl_cq02h &&
                    !(r->ooe_trio__DOT__u_sched__DOT__tl_cq02h || r->ooe_trio__DOT__u_sched__DOT__wml_cq02h ||
                      r->ooe_trio__DOT__u_sched__DOT__alloc_cq02h || r->ooe_trio__DOT__u_sched__DOT__stop_cq02h);
  dut->ooe_core_clk = 1;
  dut->eval();
  if (drop) {
    r->ooe_trio__DOT__u_sched__DOT__ready_en_cq03h = 0;
    dut->eval();
  }
  // no-force: ooe_sched's idle-R force register cleared after every edge,
  // the migration lead kept, so its idle_r assertion must fire.
  if (control == 8) {
    r->ooe_trio__DOT__u_sched__DOT__force_cq04h = 0;
    dut->eval();
  }
  cg.dump();
}

void fail(const char *what, unsigned a, unsigned b, unsigned rtl, unsigned model) {
  if (!mismatches++) std::fprintf(stderr, "first mismatch in %s (core %llu)\n", ooeTestName(), (unsigned long long)current);
  if (++kinds[what] <= 3)
    std::fprintf(stderr, "cycle %llu (core cycle %llu): %s (%u, %u: rtl %u, model %u)\n", cycles, core_cycle, what, a,
                 b, rtl, model);
  if (!core_diverged) {
    core_diverged = true;
    ++diverged;
    first_sum += core_cycle;
    ++first_kinds[what];
    if (std::getenv("TRIO_FIRST"))
      std::fprintf(stderr, "core first: cycle %llu (core cycle %llu): %s (%u, %u: rtl %u, model %u)\n", cycles,
                   core_cycle, what, a, b, rtl, model);
  }
}

bool sameConfig(const Core &c) {
  const Config &g = c.config();
  return g.sectioned && g.ready_reg && g.req_reg && g.rename_preds && !g.loads_pass_loads && c.wakeLinesFit() &&
         c.rsRcuEntries() == NR && !g.inject_early_wake && g.cmpl_wake_delay == TR_CMPL_DLY &&
         g.payload_stages + g.lat_l1_cmpl == TR_LAT_MISS;
}

// A cycle's allocations on their class's ports, in the model's order.
bool portsOf(const Snap &y, std::vector<unsigned> &entry_of, std::vector<int> &port_of) {
  entry_of.assign(P, N);
  port_of.assign(N, -1);
  unsigned next[2] = {0, 0};
  for (unsigned e : y.w.ralloc) {
    const unsigned cls = e >= NR;
    if (next[cls] == A) return false;
    const unsigned p = cls * A + next[cls]++;
    port_of[e] = int(p);
    entry_of[p] = e;
  }
  return true;
}

void reset() {
  dut->ooe_rst_r00h = 1;
  tick();
  tick();
  dut->ooe_rst_r00h = 0;
}

void hook(const Core &c) {
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    following = sameConfig(c);
    H.clear();
    core_diverged = false;
    grant_diverged = false;
    errs_seen = 0;
    ctx->assertOn(true);
    core_cycle = 0;
    prev_v = 0;
    if (following) ++compared_cores;
    if (following && std::getenv("TRIO_FIRST")) std::fprintf(stderr, "compared core starts at cycle %llu\n", cycles + 1);
    clearAll(dut->req_cq01h, P);
    clearAll(dut->req_l_cq00h, P);
    clearAll(dut->sqf_cq01h, N);
    dut->sq_l_cq00h = dut->cmpl_l_cq00h = dut->hint_l_cq00h = 0;
    reset();
  }
  ++cycles;
  ++core_cycle;
  if (!following) { ++skipped; return; }
  {
    const auto it = c.counters.find("errors");
    const uint64_t errs = it == c.counters.end() ? 0 : it->second;
    if (errs > errs_seen && std::getenv("TRIO_FIRST"))
      std::fprintf(stderr, "model error in a compared core at core cycle %llu (grants diverged before it: %d)\n",
                   core_cycle, int(grant_diverged));
    errs_seen = errs;
  }
  if (H.empty())
    for (unsigned k = 0; k != 5; ++k) H.push_back(emptySnap());
  H.push_back(snapCycle(c));
  // H: T - 5 .. T. ooe_rs drives a = T - 4; ooe_wake and ooe_sched t = P = T - 3.
  const Snap &am1 = H[0], &a = H[1], &t = H[2], &tp1 = H[3], &tp2 = H[4], &tp3 = H[5];
  // -- ooe_rs: cycle a's allocations and rows, as rs_tb drives them (am1's
  // allocations are the last edge's grant, which prv_dep names by port).
  std::vector<unsigned> entry_of, entry_prev;
  std::vector<int> port_of, port_prev;
  if (!portsOf(a, entry_of, port_of)) { fail("more allocations than ports", 0, 0, 0, 0); H.pop_front(); return; }
  portsOf(am1, entry_prev, port_prev);
  clearAll(dut->req_cq01h, P);
  clearAll(dut->row_dep_cq01h, P * N);
  clearAll(dut->row_code_cq01h, 2 * P * N);
  clearAll(dut->grp_dep_cq01h, P * P);
  clearAll(dut->grp_code_cq01h, 2 * P * P);
  clearAll(dut->prv_dep_cq01h, P * P);
  clearAll(dut->prv_code_cq01h, 2 * P * P);
  clearAll(dut->row_prod_cq01h, P);
  for (unsigned p = 0; p != P; ++p) {
    const unsigned e = entry_of[p];
    if (e == N) continue;
    setBit(dut->req_cq01h, p, true);
    setBit(dut->row_prod_cq01h, p, a.prod[e]);
    for (unsigned j = 0; j != N; ++j) {
      if (!a.dep[e * N + j]) continue;
      const unsigned code = a.codes ? a.code[e * N + j] & 3u : 0;
      if (port_of[j] >= 0) {
        const unsigned q = unsigned(port_of[j]);
        setBit(dut->grp_dep_cq01h, p * P + q, true);
        setField(dut->grp_code_cq01h, (p * P + q) * 2, 2, code);
      } else if (port_prev[j] >= 0) {
        const unsigned q = unsigned(port_prev[j]);
        setBit(dut->prv_dep_cq01h, p * P + q, true);
        setField(dut->prv_code_cq01h, (p * P + q) * 2, 2, code);
      } else {
        setBit(dut->row_dep_cq01h, p * N + j, true);
        setField(dut->row_code_cq01h, (p * N + j) * 2, 2, code);
      }
    }
  }
  std::vector<unsigned> next_of;
  std::vector<int> nport;
  portsOf(t, next_of, nport);   // a + 1 = t
  clearAll(dut->req_l_cq00h, P);
  for (unsigned p = 0; p != P; ++p) if (next_of[p] != N) setBit(dut->req_l_cq00h, p, true);
  // -- shared: the registered squash's frees of a (ooe_wake's t - 1), its
  // lead (t's), the completions of t with their valid a cycle before, and
  // their hints two cycles ahead.
  for (unsigned j = 0; j != N; ++j) setBit(dut->sqf_cq01h, j, a.sqf[j]);
  dut->sq_l_cq00h = t.sq;
  clearAll(dut->cmpl_idx_cq00h, NC * W);
  for (unsigned k = 0; k != t.cidx.size() && k != NC; ++k) setField(dut->cmpl_idx_cq00h, k * W, W, t.cidx[k]);
  dut->cmpl_l_cq00h = 0;
  for (unsigned k = 0; k != tp1.ncmpl && k != NC; ++k) dut->cmpl_l_cq00h |= 1u << k;
  clearAll(dut->hint_idx_cq01h, NC * W);
  for (unsigned k = 0; k != tp2.cidx.size() && k != NC; ++k) setField(dut->hint_idx_cq01h, k * W, W, tp2.cidx[k]);
  dut->hint_l_cq00h = 0;
  for (unsigned k = 0; k != tp3.ncmpl && k != NC; ++k) dut->hint_l_cq00h |= 1u << k;
  // -- Each port's kind and class with its row (a's: ooe_rs writes them
  // at this edge, OA re:OI-104), and ooe_wake's grant payload: the grants
  // of t - 1 = a.
  clearAll(dut->akind_cq01h, 2 * P);
  clearAll(dut->acls_cq01h, 3 * P);
  clearAll(dut->pay_cq01h, P * TR_PW);
  clearAll(dut->lead_cq01h, P * TR_LW);
  clearAll(dut->home_cq01h, P * 9);
  for (unsigned p = 0; p != P; ++p)
    if (entry_of[p] != N) {
      const unsigned e = entry_of[p];
      setField(dut->akind_cq01h, p * 2, 2, a.akind[e]);
      setField(dut->acls_cq01h, p * 3, 3, a.acls[e]);
      // Its payload, a tag of the bench's, and its slot. Control
      // pay-port drives each RCU port's payload on its neighbour's port,
      // no-home drives no slot: both must be caught.
      tag_of[e] = uint16_t(++tag_next);
      home_of[e] = a.ahome[e];
      const unsigned pp = control == 9 && p < A ? (p ^ 1) : p;
      setField(dut->pay_cq01h, pp * TR_PW, TR_PW, tag_of[e]);
      lead_of[e] = uint16_t((tag_of[e] * 2654435761u >> 7) & ((1u << TR_LW) - 1));
      setField(dut->lead_cq01h, pp * TR_LW, TR_LW, lead_of[e]);
      if (control != 10) setField(dut->home_cq01h, p * 9, 9, home_of[e]);
    }
  for (unsigned j = 0; j != N; ++j) setBit(dut->prod_cq01h, j, a.prod[j]);
  // -- ooe_sched's outer terms for P = t: the payload, the allocation lead
  // (a row written at this edge: a's), and select's live terms.
  for (unsigned e = 0; e != N; ++e) {
    setField(dut->slot_cq02h, e * LS, LS, t.slot[e]);
    setBit(dut->copy_cq02h, e, t.copy[e]);
  }
  dut->active_cq02h = t.active;
  dut->alloc_cq02h = a.alloc;
  const Core::WakeLog &sw = t.w;
  for (unsigned e = 0; e != N; ++e) {
    const bool v = e < sw.sel_valid.size() && sw.sel_valid[e];
    setBit(dut->vel_cq03h, e, v && sw.sel_elig[e]);
    setBit(dut->siss_cq03h, e, v && sw.sel_iss[e]);
    for (unsigned j = 0; j != N; ++j) setBit(dut->sdep_cq03h, e * N + j, v && !sw.sel_conf[e] && j == e);
    setField(dut->sslot_cq03h, e * LS, LS, v ? sw.sel_slot[e] : 0);
    setField(dut->res_cq03h, e * 9, 9, v ? sw.sel_res[e] : 0);
    setBit(dut->chas_cq03h, e, v && sw.sel_chas[e]);
    if (e < NR) {
      setBit(dut->ret_cq03h, e, v && sw.sel_ret[e]);
      setBit(dut->brk_cq03h, e, v && sw.sel_brk[e]);
      held += v && sw.sel_hold[e];
    }
    setField(dut->cidx_cq03h, e * W, W, v ? sw.sel_cidx[e] : 0);
  }
  for (unsigned e = 0; e != NR; ++e)
    for (unsigned j = 0; j != NR; ++j) setBit(dut->older_r_cq03h, e * NR + j, t.age[j] < t.age[e]);
  for (unsigned e = 0; e != NM; ++e)
    for (unsigned j = 0; j != NM; ++j) setBit(dut->older_m_cq03h, e * NM + j, t.age[NR + j] < t.age[NR + e]);
  dut->busy_cq03h = sw.sel_busy >> 5;
  dut->mig_cq02h = tp1.w.sel_mig;   // RA-17's migration, a cycle ahead (a lead)
  migs += sw.sel_mig;
  forced += sw.sel_mig && ((sw.sel_busy >> 4) & 1u);
  dut->block_cq03h = sw.sel_block;
  dut->ctl = control <= 7 ? control : 0;   // 8 is the bench's alone
  if (const char *tr = std::getenv("TRIO_ROWAT")) {
    // One row of ooe_sched's matrix inputs before this edge: "core,cycle,entry".
    unsigned long long cc = 0, cy = 0;
    unsigned en = 0;
    if (std::sscanf(tr, "%llu,%llu,%u", &cc, &cy, &en) == 3 && cc == current && cy == core_cycle) {
      dut->ooe_core_clk = 0;
      dut->eval();
      const auto *r = dut->rootp;
      std::fprintf(stderr, "  row %u before the edge: valid %d copy %d dep", en, int(getBit(dut->valid_cq02h, en)),
                   int(getBit(dut->copy_cq02h, en)));
      for (unsigned j = 0; j != N; ++j)
        if (getBit(dut->dep_cq02h, en * N + j))
          std::fprintf(stderr, " %u(dpm %d)", j, int(getBit(r->ooe_trio__DOT__u_sched__DOT__dpm_cq02h, en * N + j)));
      std::fprintf(stderr, " | rq_d %d\n", int((r->ooe_trio__DOT__u_sched__DOT__rq_cq02h >> en) & 1));
      for (unsigned j = 0; j != N; ++j)
        if (getBit(dut->dep_cq02h, en * N + j)) {
          bool emp = true;
          for (unsigned k = 0; k != N; ++k) emp = emp && !getBit(dut->dep_cq02h, j * N + k);
          std::fprintf(stderr, "    src %u: iss %d gnt %d fin %d prod %d row empty %d valid %d\n", j, int(getBit(dut->iss_cq02h, j)),
                       int((r->ooe_trio__DOT__u_sched__DOT__gnt_cq04h >> j) & 1), int(getBit(dut->fin_cq02h, j)),
                       int((r->ooe_trio__DOT__prod_o >> j) & 1), int(emp), int(getBit(dut->valid_cq02h, j)));
        }
    }
  }
  if (const char *tv = std::getenv("TRIO_V65AT")) {
    // Both modules' replay terms for one entry before this edge: "core,cycle,entry".
    unsigned long long cc = 0, cy = 0;
    unsigned en = 0;
    if (std::sscanf(tv, "%llu,%llu,%u", &cc, &cy, &en) == 3 && cc == current && cy == core_cycle) {
      dut->ooe_core_clk = 0;
      dut->eval();
      const auto *r = dut->rootp;
      auto b = [](uint64_t x, unsigned i) { return int((x >> i) & 1); };
      std::fprintf(stderr, "  v65 terms, entry %u: rs iss %d rep %d conf %d free %d | sched isg %d rep %d ise %d | wake iss %d gnt %d msd %d\n",
                   en, b(r->ooe_trio__DOT__u_rs__DOT__iss_cq02h, en), b(r->ooe_trio__DOT__u_rs__DOT__rep_cq02h, en),
                   b(r->ooe_trio__DOT__u_rs__DOT__conf_cq02h, en), b(r->ooe_trio__DOT__u_rs__DOT__free_cq02h, en),
                   b(r->ooe_trio__DOT__u_sched__DOT__isg_cq02h, en), b(r->ooe_trio__DOT__u_sched__DOT__rep_cq02h, en),
                   b(r->ooe_trio__DOT__u_sched__DOT__ise_cq02h, en), int(getBit(dut->iss_cq02h, en)),
                   b(r->ooe_trio__DOT__u_sched__DOT__gnt_cq04h, en), int(getBit(dut->msd_cq02h, en)));
      for (unsigned j = 0; j != N; ++j)
        if (getBit(r->ooe_trio__DOT__u_rs__DOT__dep_cq02h, en * N + j) || getBit(dut->dep_cq02h, en * N + j))
          std::fprintf(stderr, "    src %u: rs dep %d out dep %d | rs iss %d free %d | sched isg %d | wake iss %d msd %d\n", j,
                       int(getBit(r->ooe_trio__DOT__u_rs__DOT__dep_cq02h, en * N + j)), int(getBit(dut->dep_cq02h, en * N + j)),
                       b(r->ooe_trio__DOT__u_rs__DOT__iss_cq02h, j), b(r->ooe_trio__DOT__u_rs__DOT__free_cq02h, j),
                       b(r->ooe_trio__DOT__u_sched__DOT__isg_cq02h, j), int(getBit(dut->iss_cq02h, j)), int(getBit(dut->msd_cq02h, j)));
    }
  }
  if (const char *ts = std::getenv("TRIO_STOPAT")) {
    // ooe_sched's stop lead terms before this edge, at one core cycle.
    if (core_cycle == std::strtoull(ts, nullptr, 10)) {
      dut->ooe_core_clk = 0;
      dut->eval();
      const auto *r = dut->rootp;
      const uint64_t ise = r->ooe_trio__DOT__u_sched__DOT__ise_cq02h, gon = r->ooe_trio__DOT__u_sched__DOT__gon_cq02h;
      for (unsigned i = 0; i != N; ++i) {
        if (!((ise >> i) & 1)) continue;
        for (unsigned j = 0; j != N; ++j)
          if (getBit(r->ooe_trio__DOT__u_sched__DOT__dpm_cq02h, i * N + j) && ((gon >> j) & 1))
            std::fprintf(stderr, "  stop term: entry %u on %u (iss %d msd %d mis %d gnt %d | model t: iss %d/%d valid %d/%d)\n", i, j,
                         int(getBit(dut->iss_cq02h, j)), int(getBit(dut->msd_cq02h, j)), int(getBit(dut->miss_cq02h, j)),
                         int((r->ooe_trio__DOT__u_sched__DOT__gnt_cq04h >> j) & 1), t.iss[j], a.iss[j], t.valid[j], a.valid[j]);
      }
    }
  }
  if (std::getenv("TRIO_V65")) {
    // The V-65 assertion's terms, as it reads them at this edge.
    const auto *r = dut->rootp;
    uint64_t v = 0;
    for (unsigned j = 0; j != N; ++j) v |= uint64_t(getBit(dut->valid_cq02h, j)) << j;
    const uint64_t d = (r->ooe_trio__DOT__ise_q ^ r->ooe_trio__DOT__u_rs__DOT__iss_cq02h) & v &
                       ~r->ooe_trio__DOT__fre_q & ~r->ooe_trio__DOT__gr_q;
    if (d) std::fprintf(stderr, "v65 at core %llu cycle %llu: bits %llx (ise_q %llx rs iss %llx)\n",
                        (unsigned long long)current, core_cycle, (unsigned long long)d,
                        (unsigned long long)r->ooe_trio__DOT__ise_q,
                        (unsigned long long)r->ooe_trio__DOT__u_rs__DOT__iss_cq02h);
  }
  uint64_t gr_before = 0;   // the grant register the issue register reads at this edge
  for (unsigned e = 0; e != N; ++e) gr_before |= uint64_t(getBit(dut->grant_cq04h, e)) << e;
  tick();
  // -- After the edge. ooe_rs's issue register: slot k holds the entry of
  // the last grant register whose slot is k, its valid with the lead slice
  // its allocation drove (RA-31), and the rest of its payload (RA-39 (c))
  // in the second register a cycle later (OA's rev 343, (A)). Control
  // pay-with-valid holds the payload to its valid's cycle instead.
  {
    unsigned want_v = 0;
    uint16_t want_pay[9] = {}, want_lead[9] = {};
    for (unsigned e = 0; e != N; ++e)
      if (gr_before >> e & 1)
        for (unsigned k = 0; k != 9; ++k)
          if (home_of[e] >> k & 1) { want_v |= 1u << k; want_pay[k] = tag_of[e]; want_lead[k] = lead_of[e]; }
    const unsigned pv = control == 11 ? want_v : prev_v;
    for (unsigned k = 0; k != 9; ++k) {
      const bool gv = getBit(dut->iss_v_cq05h, k);
      if (gv != bool(want_v >> k & 1)) fail("issue slot valid differs", k, 0, gv, want_v >> k & 1);
      else if (gv) {
        ++issued_slots;
        const unsigned gl = unsigned(getField(dut->iss_lead_cq05h, k * TR_LW, TR_LW));
        if (gl != want_lead[k]) fail("issue lead differs", k, 0, gl, want_lead[k]);
      }
      if (pv >> k & 1) {
        const unsigned gp = unsigned(getField(dut->iss_pay_cq05h, k * TR_PW, TR_PW));
        const unsigned wp = control == 11 ? want_pay[k] : prev_pay[k];
        if (gp != wp) fail("issue payload differs", k, 0, gp, wp);
      }
    }
    prev_v = want_v;
    for (unsigned k = 0; k != 9; ++k) prev_pay[k] = want_pay[k];
  }
  // -- ooe_sched: its grant register is the model's grants of t.
  for (unsigned e = 0; e != N; ++e) {
    const bool want = e < sw.sel_grant.size() && sw.sel_grant[e], got = getBit(dut->grant_cq04h, e);
    grants += want;
    if (want != got) {
      // From a core's first differing grant on, the model's outer ports no
      // longer match the RTL's state: its assertions stand down until the
      // next core.
      if (!grant_diverged) {
        grant_diverged = true;
        ++grant_cores;
        grant_first_sum += core_cycle;
        // no-force's divergence is the force's own cycle, a cycle before
        // idle_r reads the run it leaves: its assertions stay on.
        if (control != 8) ctx->assertOn(false);
        if (std::getenv("TRIO_FIRST")) {
          // Every entry select saw differently (before this edge: the
          // registers' values the bench read after the last one).
          std::fprintf(stderr, "first grant divergence, core cycle %llu:", core_cycle);
          for (unsigned x = 0; x != N; ++x)
            if (prev_rq[x] != t_prev_req[x] || prev_rd[x] != t_prev_ready[x])
              std::fprintf(stderr, " e%u(rq %d/%d rd %d/%d)", x, prev_rq[x], t_prev_req[x], prev_rd[x], t_prev_ready[x]);
          std::fprintf(stderr, "\n");
        }
      }
      fail("grant differs", e, 0, got, want);
      if (kinds["grant differs"] <= 2 && std::getenv("TRIO_DEBUG")) {
        const auto *r = dut->rootp;
        std::fprintf(stderr, "  entry %u: rq %d (model %d), ready %d (model %d, v73 %d), vel %d, siss %d, wake iss %d, "
                     "msd %d; model valid %d iss %d\n", e, int(getBit(r->ooe_trio__DOT__u_sched__DOT__rq_cq03h, e)),
                     t.req_q[e], int(getBit(r->ooe_trio__DOT__u_sched__DOT__ready_cq03h, e)), t.ready_q[e], t.v73[e],
                     int(sw.sel_valid[e] && sw.sel_elig[e]), int(sw.sel_iss[e]), int(getBit(dut->iss_cq02h, e)),
                     int(getBit(dut->msd_cq02h, e)), t.valid[e], t.iss[e]);
      }
    }
  }
  if (const char *te = std::getenv("TRIO_TRACE")) {
    const unsigned e = unsigned(std::atoi(te));
    const char *tw = std::getenv("TRIO_WINDOW");   // "lo,hi" in bench cycles
    unsigned long long lo = 5296, hi = 5320;
    if (tw) std::sscanf(tw, "%llu,%llu", &lo, &hi);
    if (cycles <= hi && cycles >= lo) {
      const auto *r = dut->rootp;
      std::fprintf(stderr, "  [%llu/core %llu now %llu] e%u model(t): valid %d iss %d grant %d rq %d alloc-in-a %d | rtl: rq %d iss %d valid %d "
                   "grant %d rd %d/%d v73 %d\n", core_cycle, (unsigned long long)current, (unsigned long long)t.now, e, t.valid[e], t.iss[e], int(e < sw.sel_grant.size() && sw.sel_grant[e]), t.req_q[e],
                   int(std::count(a.w.ralloc.begin(), a.w.ralloc.end(), e)),
                   int(getBit(r->ooe_trio__DOT__u_sched__DOT__rq_cq03h, e)), int(getBit(dut->iss_cq02h, e)),
                   int(getBit(dut->valid_cq02h, e)), int(getBit(dut->grant_cq04h, e)),
                   int(getBit(r->ooe_trio__DOT__u_sched__DOT__ready_cq03h, e)), t.ready_q[e], t.v73[e]);
      // Its sources: the model's lines at t, t + 1, t + 2 and the RTL's
      // lead lines (t + 2's frame), issued and held miss.
      for (unsigned j = 0; j != N; ++j) {
        if (!t.dep[e * N + j]) continue;
        std::fprintf(stderr, "       src %u code %u: valid %d iss %d | lines t", j, unsigned(t.code[e * N + j] & 3),
                     t.valid[j], t.iss[j]);
        for (const Snap *y : {&t, &tp1, &tp2}) {
          std::fprintf(stderr, " ");
          for (unsigned k = 0; k != L; ++k) std::fprintf(stderr, "%d", int(y->line[j * L + k]));
        }
        std::fprintf(stderr, " | rtl lead ");
        for (unsigned k = 0; k != L; ++k) std::fprintf(stderr, "%d", int(getBit(dut->wake_cq02h, j * L + k)));
        std::fprintf(stderr, " iss %d msd %d stop t/t1/t2 %d%d%d\n", int(getBit(dut->iss_cq02h, j)),
                     int(getBit(dut->msd_cq02h, j)), int(t.w.stop[j]), int(tp1.w.stop[j]), int(tp2.w.stop[j]));
      }
    }
  }
  if (std::getenv("TRIO_STOP")) {
    const bool rs = r_stop();
    if (rs != t.stop_q && !grant_diverged)
      std::fprintf(stderr, "stop lead differs at core %llu cycle %llu (now %llu): rtl %d model %d\n",
                   (unsigned long long)current, core_cycle, (unsigned long long)t.now, int(rs), int(t.stop_q));
  }
  // ooe_sched's registers (read inside it): the request register exactly,
  // the ready register on V-73's rows.
  {
    const auto *r = dut->rootp;
    for (unsigned e = 0; e != N; ++e) {
      const bool q = getBit(r->ooe_trio__DOT__u_sched__DOT__rq_cq03h, e);
      if (q != bool(t.req_q[e])) fail("sched request register differs", e, 0, q, t.req_q[e]);
      if (!t.v73[e]) continue;
      // A row a squash frees at the next edge: ooe_wake drops its
      // producers' lead lines on the squash lead, an edge before the
      // model's register sees the squash. Its ready bit can change no
      // grant the grant register's exact comparison would not catch.
      if (tp1.sqf[e]) { ++squash_ready_skipped; continue; }
      const bool rd = getBit(r->ooe_trio__DOT__u_sched__DOT__ready_cq03h, e);
      if (rd != bool(t.ready_q[e])) fail("sched ready register differs", e, 0, rd, t.ready_q[e]);
    }
  }
  // ooe_rs: its valid bits and rows, the model's at the end of a.
  for (unsigned i = 0; i != N; ++i) {
    const bool v = getBit(dut->valid_cq02h, i);
    if (v != bool(a.valid[i])) { fail("rs valid differs", i, 0, v, a.valid[i]); continue; }
    if (!v) continue;
    for (unsigned j = 0; j != N; ++j) {
      const bool d = getBit(dut->dep_cq02h, i * N + j);
      if (d != bool(a.dep[i * N + j])) fail("rs dependency bit differs", i, j, d, a.dep[i * N + j]);
    }
  }
  // ooe_wake: issued at the end of t - 1 = a, and its lead lines, the
  // model's at t + 2 on an entry no stop reaches before then.
  for (unsigned j = 0; j != N; ++j) {
    const bool got_iss = getBit(dut->iss_cq02h, j), want_iss = a.valid[j] && a.iss[j];
    if (got_iss != want_iss) fail("wake issued differs", j, 0, got_iss, want_iss);
    const bool stopped = t.w.stop[j] || tp1.w.stop[j] || tp2.w.stop[j];
    if (tp2.valid[j] && !stopped)
      for (unsigned k = 0; k != L; ++k) {
        const bool want = tp2.line[j * L + k], got = getBit(dut->wake_cq02h, j * L + k);
        if (want != got) fail("wake lead line differs", j, k, got, want);
      }
  }
  {
    const auto *r = dut->rootp;
    for (unsigned x = 0; x != N; ++x) {
      prev_rq[x] = getBit(r->ooe_trio__DOT__u_sched__DOT__rq_cq03h, x);
      prev_rd[x] = getBit(r->ooe_trio__DOT__u_sched__DOT__ready_cq03h, x);
      t_prev_req[x] = t.req_q[x];
      t_prev_ready[x] = t.ready_q[x];
    }
  }
  H.pop_front();
}
} // namespace

int main(int argc, char **argv) {
  if (const char *c = std::getenv("TRIO_CONTROL")) {
    const std::string n = c;
    control = n == "no-msd" ? 1 : n == "no-miss-lead" ? 2 : n == "late-leads" ? 3 : n == "no-alloc-lead" ? 4
            : n == "no-ret-hold" ? 5 : n == "no-rep-lead" ? 6 : n == "no-idle-r" ? 7 : n == "no-force" ? 8
            : n == "pay-port" ? 9 : n == "no-home" ? 10 : n == "pay-with-valid" ? 11
            : n == "no-c9h" ? 12 : 0;
    if (!control) { std::fprintf(stderr, "trio_tb: unknown control %s\n", c); return 2; }
  }
  const unsigned seeds = argc > 1 ? unsigned(std::atoi(argv[1])) : 25;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_trio>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  int model_fails = cg.run(seeds, nullptr, hook, trioConfig);
  if (!cg.on()) model_fails += ooeTestRandomRetsHookedWith(std::max(2u, seeds / 4), hook, trioRetConfig);
  if (!cg.on()) model_fails += ooeTestIdleRHookedWith(std::max(1u, seeds / 8), hook, trioIdleRConfig);
  cg.close();
  dut->final();
  for (const auto &k : kinds) std::fprintf(stderr, "  %-30s %llu\n", k.first.c_str(), k.second);
  for (const auto &k : first_kinds) std::fprintf(stderr, "  first: %-23s %llu\n", k.first.c_str(), k.second);
  std::printf("trio_tb seeds=%u cores=%llu compared=%llu cycles=%llu skipped=%llu grants=%llu "
              "grant_diverged_cores=%llu first_grant_divergence_mean=%.0f squash_ready_skipped=%llu held=%llu migs=%llu forced=%llu issued_slots=%llu mismatches=%llu model_failures=%d\n",
              seeds, cores, compared_cores, cycles, skipped, grants, grant_cores,
              grant_cores ? double(grant_first_sum) / double(grant_cores) : 0.0, squash_ready_skipped, held, migs, forced, issued_slots, mismatches,
              model_fails);
  if (!cg.on() && !held) std::fprintf(stderr, "trio_tb: the ret hold never held an entry\n");
  if (!cg.on() && !forced) std::fprintf(stderr, "trio_tb: the idle-R force never held R\n");
  const int rc = mismatches || model_fails || (!cg.on() && (!held || !forced)) ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
