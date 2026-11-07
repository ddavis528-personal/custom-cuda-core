//===-- rob_tb.cpp - ooe_rob against the live model ------------------------===//
//
// Runs the model's directed and random unit tests (sim/ooe/ooe_test.cpp)
// with the ROB's window lag (retire_lag 1, OI-85), the random programs
// predicting every branch (ROB_MISPREDICT=1: as drawn), and, after every core
// cycle, drives ooe_rob with what the model's ROB saw in it (Core::robLog):
// each slot's allocations at the go, Rename 2's fills two cycles on, the
// RS's events per entry, RCU's dones and MIU's completions by rob_tag, the
// releases. It compares the retire decision (ooe_rat's and the free lists'
// leads) and the room rename's go reads with the model's in that cycle,
// and the retire-stage register and its frees with the model's a cycle
// before. The leads are the next cycle's, so the RTL runs a model cycle
// behind. A core stops being compared at the first thing the ROB does not
// build yet (RobLog::stop: a squash other than a branch's, a fault taken, a
// barrier port, an atomic, a kill); cores with other than RB_S tier-1 slots
// are skipped.
//
// Negative controls (ROB_CONTROL=<name>) perturb the driving and must be
// caught: drop-free (one RS free in a cycle never reaches the ROB: V-58's
// count stays up), no-copy (a copy is never in flight), no-lead (an
// allocation's lead never comes), fill-order (a cycle's fills in reverse
// lane order: each entry takes another's fields) and nop-real (a no-op is
// filled as a lane op, never complete at allocation) and two-in-a-cycle
// (a done sent twice in its cycle, for the same row, against RCU's one
// done per rob_tag and row a cycle, OA's rev 282: the assertion fires),
// and wrong-row (each cycle's first done names the next row: a row's count
// underflows, or the entry never completes); slice 2's flip-taken (every
// branch outcome inverted: right branches redirect) and right-always (every
// outcome agrees with its prediction: mispredicts never redirect, run with
// the programs mispredicting), branch-off-slot (a branch's done on a
// slot other than BS: the assertion fires) and no-branch-lead (a branch
// fill's lead never comes: the assertion fires); slice 2b's no-miu (a
// memop's send to MIU never reaches the ROB: a squash frees it with its op
// in flight), no-store (no fill is a store: a squash's discard is missed)
// and drop-killed-fill (the fill of an entry squashed before it landed
// never comes: its names are never freed), run mispredicting.
//
// Slice 3 (OI rev 304, OA rev 362): ccv_ooe_miu_retire's port WID is the
// slot's own (commit_per_slot 1), so the window takes one store a cycle and
// the commit leaves from the retire-stage register: last cycle's commits
// are compared, slot and rob_tag. Its controls: shared-ports (the model
// shares the ports, two stores retire in a window) and store-shift (a
// store's bit lands on the next lane's fill).
//
// Slice 2 (OI-85, form (a) of OI-86): the model at resolve_lag 1 and
// squash_act_lag 1. A branch's done goes on slot BS (CCV_DONE_SLOTS - 2, AR's RCU spec rev
// 14) with its outcome, the other dones on the lowest free slots; the
// resolution's registered outputs (the redirect lead per slot, the
// checkpoints right branches free) are compared with the model's resolve a
// cycle before, the redirect's payload a cycle after its lead.
//
// Slice 2b (OI-94's (C''), the ROB drops a killed fill): the squash acts in
// the model's squash cycle. Each squashed entry frees its new names (the
// GPR row's sections gname holds, the predicate under rename_preds): one
// filled with nothing in flight at once, in the frees the retire-stage
// check reads a cycle on; one held (dones owed, at MIU and not complete, a
// copy in flight) when its op lands and a cycle more (the release
// register); one whose fill had not landed when that fill arrives and a
// cycle more (the kill register). The free leads cover every free; a
// squash acting or an entry held or released in the last two cycles may
// raise them with none. The room, the window and the discard (a squashed
// store at MIU: the branch and the youngest entry, a cycle after the
// squash) are compared as ever; RS frees of an entry taken before its fill
// never reach the ROB. ROB_TRACE=<cycle> prints the log around a cycle,
// ROB_VCD=<file> dumps the run.
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: rob_tb [seeds] | rob_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_rob_tb.h"
#include "Vooe_rob_tb___024root.h"
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

int ooeTestDirectedHookedWith(void (*hook)(const Core &), void (*cfg)(Config &));
const char *ooeTestName();
void ooeTestPredictAll(bool on);
// Slice 2's form (a), OI-86: the redirect a cycle after the resolution, the
// squash acting a cycle after that (OA rev 284, pending DA's ruling).
void robConfig(Config &c) {
  c.retire_lag = 1;
  c.resolve_lag = 1;
  c.resolve_lag_ret_only = 0;   // every branch at lag 1: the RTL resolves from its outcome register until RCU's branch lead lands
  c.squash_act_lag = 1;
  c.held_room_lag = 1;
  c.squash_held_room_lag = 1;   // the ROB registers no run in a squash's cycle that leaves held entries
  c.kill_free_lag = 1;   // OI-94 (C''): a killed fill's names free as the RTL frees them
  // Slice 3 (OI 304): ccv_ooe_miu_retire's port WID is the slot's own, one
  // store commit a cycle; shared-ports runs the model with the ports shared.
  const char *ctl = std::getenv("ROB_CONTROL");
  c.commit_per_slot = !(ctl && std::string(ctl) == "shared-ports");
  // Slice 4: the RTL takes a fault at its registered head; fault-any-port
  // and fault-port0 run the model taking it on any port, or on port 0.
  c.fault_head_only = ctl && std::string(ctl) == "fault-any-port" ? 0 : ctl && std::string(ctl) == "fault-port0" ? 1 : 2;
}

namespace {
constexpr unsigned NR = 4;
constexpr unsigned S = RB_S, D = RB_D, RP = RB_RP, A = RB_A, ND = RB_ND, NM = RB_NM, GW = RB_GW, GR = RB_GR,
                   NG = RB_NG, NS = RB_NS, PW = RB_PW, NP = RB_NP, NK = RB_NK, PCW = RB_PCW, CW = RB_CW, LB = 6, LT = 3,
                   BS = ND - 2;   // RCU-only ops' fixed done slot (AR's RCU spec rev 14, OA rev 287)
constexpr unsigned NSB = NS ? NS : 1;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned LS = S > 1 ? bits(S) : 1, LD = bits(D), TW = LS + LD, LA = bits(A + 1), LK = NK > 1 ? bits(NK) : 1;
constexpr uint64_t PCM = (uint64_t(1) << PCW) - 1;

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_rob_tb> dut;
std::string control;
uint64_t current = 0;
bool live = false, stopped = false;
unsigned long long cycles = 0, cores = 0, skipped = 0, stops = 0, retires = 0, allocs = 0, nops = 0, gfrees = 0,
                   pfrees = 0, events = 0, mismatches = 0, resolves = 0, redirects = 0, ckfrees = 0,
                   squashes = 0, sq_ents = 0, sq_held = 0, sq_kills = 0, hrels = 0, discards = 0, commits = 0, faults = 0;
bool rename_preds = true;
std::map<std::string, unsigned long long> stop_why;

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
template <typename T> void setField64(T &w, unsigned lo, unsigned n, uint64_t v) {
  for (unsigned i = 0; i != n; ++i) setBit(w, lo + i, (v >> i) & 1u);
}
template <typename T> uint64_t getField64(const T &w, unsigned lo, unsigned n) {
  uint64_t v = 0;
  for (unsigned i = 0; i != n; ++i) v |= uint64_t(getBit(w, lo + i)) << i;
  return v;
}
template <typename T> void clearAll(T &w, unsigned n) { for (unsigned i = 0; i != n; ++i) setBit(w, i, false); }

CgRun cg;

// two-resolutions: after the edge that registers a branch's outcome,
// every resolved bit cleared, so each completed branch still in the ROB is
// a candidate again beside it (one_resolution must fire).
bool force_rsv = false;
void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  if (force_rsv) {
    force_rsv = false;
    // Every per-warp instance's (OA-24): the harness's g_w[w].u_w.
    auto *r = dut->rootp;
    for (auto *w : {&r->ooe_rob_tb__DOT__g_w__BRA__0__KET____DOT__u_w__DOT__rsv_cq02h,
                    &r->ooe_rob_tb__DOT__g_w__BRA__1__KET____DOT__u_w__DOT__rsv_cq02h,
                    &r->ooe_rob_tb__DOT__g_w__BRA__2__KET____DOT__u_w__DOT__rsv_cq02h,
                    &r->ooe_rob_tb__DOT__g_w__BRA__3__KET____DOT__u_w__DOT__rsv_cq02h})
      for (unsigned i = 0; i != RB_D; ++i) setBit(*w, i, false);
    dut->eval();
  }
  cg.dump();
}
void fail(const char *what, unsigned a, unsigned rtl, unsigned model) {
  if (++mismatches <= 8)
    std::fprintf(stderr, "cycle %llu: %s (%u: rtl %u, model %u)\n", cycles, what, a, rtl, model);
}

// A cycle as the bench drives it: the model's log, and its go log's room.
struct Cyc {
  Core::RobLog r;
  unsigned long long n = 0;                    // the bench's cycle index
  std::vector<unsigned> run, ret;
  std::vector<uint8_t> reach;
};
// The allocations of the last cycles, newest last: Rename 2 fills each two
// cycles on (fill-late: three).
std::deque<std::vector<Core::RobLog::Alloc>> hist;
size_t fillLag() { return 2; }

bool slotOf(unsigned tag, unsigned &s, unsigned &i) {
  s = tag >> LD;
  i = tag & (D - 1);
  return s < S;
}
bool hasEvent(const Core::RobLog &r, unsigned s) {
  for (const auto *v : {&r.owe, &r.cpi, &r.cpl, &r.rsf, &r.miu})
    for (unsigned t : *v) if ((t >> LD) == s) return true;
  return false;
}

// ROB_DEBUG: a shadow of each tag's dones owed, as the RTL counts them.
std::vector<int> owed_dbg(S * D, 0);
std::vector<unsigned> tl_dbg(S, 0);
std::vector<std::string> hist_dbg(S * D);
// Each tag's branch fields, from its allocation: a done on it is routed to
// slot BS, and the controls read its prediction.
std::vector<Core::RobLog::Alloc> br_of(S * D);
unsigned long long br_two = 0;

// A cycle's dones by slot (-1 none): a branch's on slot BS, the rest from
// the lowest free slot in the log's order (the stub's choice), BS last. RCU
// sends one branch done a cycle (its fixed slot); branch-off-slot sends it
// on the lowest free slot instead.
std::vector<int> doneSlots(const Core::RobLog &r) {
  std::vector<int> sl(ND, -1);
  std::vector<size_t> rest;
  bool br_seen = false;
  for (size_t k = 0; k != r.done.size(); ++k) {
    const unsigned t = r.done[k];
    const bool br = t < S * D && br_of[t].br && (k >= r.dpay.size() || r.dpay[k].row == 0);
    if (br && !br_seen && control != "branch-off-slot") { sl[BS] = int(k); br_seen = true; }
    else { if (br && br_seen) ++br_two; rest.push_back(k); }
  }
  for (size_t k : rest) {
    unsigned p = 0;
    while (p != ND && (p == BS || sl[p] >= 0)) ++p;
    if (p == ND && sl[BS] < 0) p = BS;
    if (p != ND) sl[p] = int(k);
  }
  return sl;
}

// Slice 2b: what a squash frees and when the RTL's free masks show it,
// keyed by the cycle whose retire-stage check reads them (the frees of a
// cycle's retirements are keyed by that cycle): a filled entry with nothing
// in flight at the squash's cycle q; a held one at its release's n + 1 (the
// release register); one whose fill had not landed (OI-94 (C''): the ROB
// drops its fill and frees its names through the kill register) at its
// fill's cycle + 1, its allocation's + 3. Its new names: the GPR row's
// sections it holds, the predicate it allocated under rename_preds.
struct Frees { std::vector<uint8_t> g, p; };
std::map<unsigned long long, Frees> sq_frees;
std::vector<unsigned long long> alloc_cyc(S * D, 0);
std::map<unsigned, Core::RobLog::Alloc> held;   // squashed, held for an op in flight
std::vector<uint8_t> killed(S * D, 0);           // squashed before its fill landed
bool kill_dropped = false;
std::vector<Core::RobLog::Alloc> late_fl;   // late-fill: the cycle's fills it holds back
bool late_done = false;
// Squash or held activity (a squash acting, an entry held or released) in
// each of the last two cycles: the free leads' supersets reach that far.
bool act1 = false, act2 = false;
Frees &freesAt(unsigned long long key) {
  Frees &f = sq_frees[key];
  if (f.g.empty()) { f.g.assign(NG * NSB, 0); f.p.assign(NP, 0); }
  return f;
}
void addFree(unsigned long long key, const Core::RobLog::Alloc &a) {
  if (a.nop) return;
  Frees &f = freesAt(key);
  const bool palloc = a.pwe && rename_preds;
  if (a.gwe && a.gnsec) {
    const unsigned row = a.gname >> (GW - GR);
    for (unsigned j = 0; j != NSB; ++j) if ((a.gnsec >> j) & 1u) f.g[row * NSB + j] = 1;
  }
  if (palloc && a.pname < NP) f.p[a.pname] = 1;
}
bool unfilledAt(unsigned tag, unsigned long long q) { return alloc_cyc[tag] + fillLag() >= q; }
// The cycle's squash, as the model logged it, before the RTL is driven
// (the RS frees of an entry taken before its fill never reach the ROB: it
// has no entry).
void account(Cyc &c) {
  const unsigned long long q = c.n;
  squashes += c.r.squash.size();
  std::vector<uint8_t> unf(S * D, 0);
  for (const auto &e : c.r.sq_ent) {
    const unsigned t = e.first;
    if (t >= S * D) continue;
    ++sq_ents;
    const Core::RobLog::Alloc &a = br_of[t];
    if (unfilledAt(t, q)) {
      if (e.second) fail("held entry not yet filled", t, 0, 1);
      unf[t] = 1;
      killed[t] = 1;
      ++sq_kills;
      addFree(alloc_cyc[t] + fillLag() + 1, a);
    } else if (e.second) {
      ++sq_held;
      held[t] = a;
    } else addFree(q, a);
  }
  for (unsigned t : c.r.hrel) {
    auto it = held.find(t);
    if (it == held.end()) { fail("held release of an entry not held", t, 0, 0); continue; }
    ++hrels;
    addFree(q + 1, it->second);
    held.erase(it);
  }
  std::vector<unsigned> rsf;
  for (unsigned t : c.r.rsf) if (t >= S * D || !unf[t]) rsf.push_back(t);
  c.r.rsf = rsf;
}

void clearInputs() {
  dut->al_l_cq01h = 0;
  clearAll(dut->al_n_cq02h, S * LA);
  clearAll(dut->al_nop_cq02h, S * A);
  clearAll(dut->al_flt_cq02h, S * A);
  clearAll(dut->al_cause_cq02h, S * A * CW);
  clearAll(dut->al_pc_cq02h, S * A * 31);
  clearAll(dut->al_pchi_cq02h, S * A * 16);
  clearAll(dut->al_gm_cq02h, S * A * 32);
  dut->fl_l_cq01h = 0;
  dut->fl_brl_cq01h = 0;
  for (auto *p : {&dut->fl_v_cq02h, &dut->fl_nop_cq02h, &dut->fl_mem_cq02h, &dut->fl_gwe_cq02h, &dut->fl_pwe_cq02h,
                  &dut->fl_pfree_cq02h})
    *p = 0;
  clearAll(dut->fl_slot_cq02h, A * LS);
  clearAll(dut->fl_rs_cq02h, A * 2);
  clearAll(dut->fl_dst_cq02h, A * 4);
  clearAll(dut->fl_gname_cq02h, A * GW);
  clearAll(dut->fl_gold_cq02h, A * GW);
  clearAll(dut->fl_gsec_cq02h, A * NSB);
  clearAll(dut->fl_pdst_cq02h, A * 2);
  clearAll(dut->fl_pname_cq02h, A * PW);
  clearAll(dut->fl_pold_cq02h, A * PW);
  for (auto *p : {&dut->fl_br_cq02h, &dut->fl_ptaken_cq02h, &dut->fl_ret_cq02h}) *p = 0;
  clearAll(dut->fl_ckpt_cq02h, A * LK);
  clearAll(dut->fl_gmask_cq02h, A * 32);
  clearAll(dut->fl_pcn_cq02h, A * PCW);
  clearAll(dut->fl_tgt_cq02h, A * PCW);
  clearAll(dut->fl_pchi_cq02h, A * 16);
  clearAll(dut->fl_gnsec_cq02h, A * NSB);
  dut->fl_palloc_cq02h = 0;
  dut->fl_store_cq02h = 0;
  dut->ev_l_cq01h = 0;
  clearAll(dut->ev_owe_cq02h, S * D * NR);
  clearAll(dut->ev_cpi_cq02h, S * D);
  clearAll(dut->ev_cpl_cq02h, S * D);
  clearAll(dut->ev_rsf_cq02h, S * D * 2);
  clearAll(dut->ev_miu_cq02h, S * D);
  dut->dn_l_cq01h = 0;
  clearAll(dut->dn_tag_cq02h, ND * TW);
  clearAll(dut->dn_row_cq02h, ND * 2);
  dut->dn_taken_cq02h = 0;
  dut->dn_mask_cq02h = 0;
  dut->dn_aux_cq02h = 0;
  dut->cm_l_cq01h = 0;
  clearAll(dut->cm_tag_cq02h, NM * TW);
  dut->rel_l_cq01h = 0;
}

void resetRtl() {
  clearInputs();
  hist.clear();
  br_of.assign(S * D, Core::RobLog::Alloc());
  alloc_cyc.assign(S * D, 0);
  killed.assign(S * D, 0);
  sq_frees.clear();
  held.clear();
  act1 = act2 = false;
  tl_dbg.assign(S, 0);
  owed_dbg.assign(S * D, 0);
  // A core can end a cycle after a lead promised it more (a done next
  // cycle); the first reset edge, before the flopped reset rises, still
  // sees that lead. No assertion looks across the reset.
  ctx->assertOn(false);
  dut->ooe_rst_r00h = 1;
  tick();
  tick();
  dut->ooe_rst_r00h = 0;
  tick();
  ctx->assertOn(true);
  tick();
}


// Rename 2's fills: the allocations fillLag() cycles before. A stopped
// core's last cycles take an empty allocation and still land the fills
// owed (fill_at_alloc_2 holds across the stop).
void driveFills(const std::vector<Core::RobLog::Alloc> &alloc) {
  hist.push_back(alloc);
  if (hist.size() > 4) hist.pop_front();
  if (hist.size() > fillLag()) {
    std::vector<Core::RobLog::Alloc> fl = hist[hist.size() - 1 - fillLag()];
    if (control == "fill-order") std::reverse(fl.begin(), fl.end());
    // late-fill: one cycle's fills arrive a cycle late, at the first cycle
    // that has fills and none due next (fill_at_alloc_2 must fire).
    if (control == "late-fill" && !late_done) {
      if (!late_fl.empty()) { fl = late_fl; late_fl.clear(); late_done = true; }
      else if (!fl.empty() && hist[hist.size() - fillLag()].empty()) { late_fl = fl; fl.clear(); }
    }
    // drop-killed-fill: the first fill of an entry a squash took before it
    // landed never comes (its names are never freed, the kill count waits).
    if (control == "drop-killed-fill" && !kill_dropped)
      for (auto it = fl.begin(); it != fl.end(); ++it)
        if (it->slot < S && killed[it->slot * D + it->idx]) { fl.erase(it); kill_dropped = true; break; }
    for (const auto &a : fl) if (a.slot < S) killed[a.slot * D + a.idx] = 0;
    unsigned l = 0;
    for (const auto &a : fl) {
      if (l == A) { fail("more fills than lanes", 0, l, unsigned(fl.size())); break; }
      setBit(dut->fl_v_cq02h, l, true);
      setField(dut->fl_slot_cq02h, l * LS, LS, a.slot);
      setBit(dut->fl_nop_cq02h, l, a.nop && control != "nop-real");
      setBit(dut->fl_mem_cq02h, l, a.mem);
      setField(dut->fl_rs_cq02h, l * 2, 2, a.rs);
      setBit(dut->fl_gwe_cq02h, l, a.gwe);
      setField(dut->fl_dst_cq02h, l * 4, 4, a.dst);
      setField(dut->fl_gname_cq02h, l * GW, GW, a.gname);
      setField(dut->fl_gold_cq02h, l * GW, GW, a.gold);
      setField(dut->fl_gsec_cq02h, l * NSB, NSB, a.gsec);
      setBit(dut->fl_pwe_cq02h, l, a.pwe);
      setField(dut->fl_pdst_cq02h, l * 2, 2, a.pdst);
      setField(dut->fl_pname_cq02h, l * PW, PW, a.pname);
      setField(dut->fl_pold_cq02h, l * PW, PW, a.pold);
      setBit(dut->fl_pfree_cq02h, l, a.pfree);
      setField(dut->fl_gnsec_cq02h, l * NSB, NSB, a.gnsec);
      setBit(dut->fl_palloc_cq02h, l, a.pwe && rename_preds);
      setBit(dut->fl_store_cq02h, l, a.store && control != "no-store" && control != "store-shift");
      // store-shift: a store's bit lands on the next lane's fill.
      if (control == "store-shift" && a.store) setBit(dut->fl_store_cq02h, (l + 1) % A, true);
      setBit(dut->fl_br_cq02h, l, a.br);
      setField(dut->fl_ckpt_cq02h, l * LK, LK, a.ckpt);
      setBit(dut->fl_ptaken_cq02h, l, a.ptaken);
      setBit(dut->fl_ret_cq02h, l, a.ret);
      setField64(dut->fl_gmask_cq02h, l * 32, 32, a.gmask);
      setField64(dut->fl_pcn_cq02h, l * PCW, PCW, a.pcn & PCM);
      setField64(dut->fl_tgt_cq02h, l * PCW, PCW, a.tgt & PCM);
      setField(dut->fl_pchi_cq02h, l * 16, 16, a.pchi);
      ++l;
    }
  }
}

void drive(const Cyc &c, const Cyc &nx) {
  clearInputs();
  const Core::RobLog &r = c.r;
  if (std::getenv("ROB_DEBUG")) {
    std::vector<unsigned> &tl = tl_dbg;
    for (unsigned q = 0; q != S; ++q) if ((r.release >> q) & 1u) tl[q] = 0;
    for (const auto &a : r.alloc) if (a.slot < S) {
      if (a.idx != tl[a.slot] && mismatches < 3) {
        std::fprintf(stderr, "ROB_DEBUG cycle %llu: slot %u allocates %u, tail %u\n", cycles, a.slot, a.idx, tl[a.slot]);
        ++mismatches;
      }
      tl[a.slot] = (a.idx + 1) % D;
      owed_dbg[a.slot * D + a.idx] = 0; hist_dbg[a.slot * D + a.idx] = "A" + std::to_string(cycles);
    }
    for (unsigned t : r.owe) if (t < S * D) { ++owed_dbg[t]; hist_dbg[t] += " o" + std::to_string(cycles); }
    for (unsigned t : r.done) if (t < S * D) {
      hist_dbg[t] += " d" + std::to_string(cycles);
      if (--owed_dbg[t] < 0 && mismatches < 3) {
        std::fprintf(stderr, "ROB_DEBUG cycle %llu: tag %u done with none owed: %s\n", cycles, t, hist_dbg[t].c_str());
        ++mismatches;
      }
    }
  }
  // The go's allocations, in order per slot.
  std::vector<unsigned> n(S, 0);
  for (const auto &a : r.alloc) {
    if (a.slot >= S || n[a.slot] == A) continue;
    // A rename-time fault is no no-op to the ROB (slice 4): it never completes.
    setBit(dut->al_nop_cq02h, a.slot * A + n[a.slot], a.nop && !a.fault && control != "nop-real");
    // Slice 4: the fault record's fields, every allocation.
    const unsigned al = a.slot * A + n[a.slot];
    setBit(dut->al_flt_cq02h, al, a.fault && control != "no-fault");
    setField(dut->al_cause_cq02h, al * CW, CW, a.cause ^ (control == "fault-cause" ? 1u : 0u));
    setField(dut->al_pc_cq02h, al * 31, 31, a.pclo);
    setField(dut->al_pchi_cq02h, al * 16, 16, a.epchi);
    setField(dut->al_gm_cq02h, al * 32, 32, a.egmask);
    br_of[a.slot * D + a.idx] = a;
    alloc_cyc[a.slot * D + a.idx] = c.n;
    ++n[a.slot];
    ++allocs;
    nops += a.nop;
  }
  for (unsigned s = 0; s != S; ++s) setField(dut->al_n_cq02h, s * LA, LA, n[s]);
  driveFills(r.alloc);
  // The RS's events, per entry.
  unsigned s, i;
  // Each issue owing a done, at its row (OA's rev 282): the log's owe_row
  // beside owe.
  for (size_t k = 0; k != r.owe.size(); ++k)
    if (slotOf(r.owe[k], s, i)) setBit(dut->ev_owe_cq02h, (s * D + i) * NR + (k < r.owe_row.size() ? r.owe_row[k] : 0), true);
  for (unsigned t : r.cpi) if (slotOf(t, s, i) && control != "no-copy") setBit(dut->ev_cpi_cq02h, s * D + i, true);
  for (unsigned t : r.cpl) if (slotOf(t, s, i)) setBit(dut->ev_cpl_cq02h, s * D + i, true);
  // no-miu: a memop's send to MIU never reaches the ROB (a squash frees
  // its entry with the op in flight, and a store there is not discarded).
  for (unsigned t : r.miu) if (slotOf(t, s, i) && control != "no-miu") setBit(dut->ev_miu_cq02h, s * D + i, true);
  bool dropped = false;
  for (unsigned t : r.rsf)
    if (slotOf(t, s, i)) {
      if (control == "drop-free" && !dropped) { dropped = true; continue; }
      setField(dut->ev_rsf_cq02h, (s * D + i) * 2, 2, getField(dut->ev_rsf_cq02h, (s * D + i) * 2, 2) + 1);
    }
  events += r.owe.size() + r.cpi.size() + r.cpl.size() + r.rsf.size() + r.miu.size();
  // RCU's dones and MIU's completions.
  // Each done's row is the one RCU echoed (done_row, TI's 6ba08b1).
  // A branch's on slot BS, with its outcome (taken, the lanes, a ret's aux).
  const std::vector<int> sl = doneSlots(r);
  // wrong-row: the log's first done names the next row.
  auto drow = [&](unsigned p) {
    const size_t k = size_t(sl[p]);
    const unsigned w = k < r.dpay.size() ? r.dpay[k].row : 0u;
    return control == "wrong-row" && k == 0 ? (w + 1) % NR : w;
  };
  int first = -1;
  for (unsigned p = 0; p != ND; ++p) {
    if (sl[p] < 0) continue;
    if (first < 0) first = int(p);
    setField(dut->dn_tag_cq02h, p * TW, TW, r.done[size_t(sl[p])]);
    setField(dut->dn_row_cq02h, p * 2, 2, drow(p));
  }
  // The outcome rides slot BS (don't-care elsewhere).
  if (sl[BS] >= 0 && size_t(sl[BS]) < r.dpay.size()) {
    const Core::RobLog::DonePay &d = r.dpay[size_t(sl[BS])];
    const Core::RobLog::Alloc &b = br_of[r.done[size_t(sl[BS])] % (S * D)];
    bool taken = d.taken;
    uint32_t mask = d.mask;
    // right-always: every outcome agrees with its prediction (a missed
    // mispredict); flip-taken: every outcome inverted (a right branch read
    // as wrong).
    if (control == "right-always") { taken = b.ptaken; mask = b.gmask; }
    if (control == "flip-taken") taken = !taken;
    dut->dn_taken_cq02h = taken;
    dut->dn_mask_cq02h = mask;
    dut->dn_aux_cq02h = d.aux;
    if (control == "two-resolutions" && b.br) force_rsv = true;
  }
  // two-in-a-cycle: the first done again, on the first free slot.
  unsigned dup = ND;
  if (control == "two-in-a-cycle" && first >= 0)
    for (unsigned p = 0; p != ND; ++p) if (sl[p] < 0 && p != BS) { dup = p; break; }
  if (dup != ND) {
    setField(dut->dn_tag_cq02h, dup * TW, TW, r.done[size_t(sl[unsigned(first)])]);
    setField(dut->dn_row_cq02h, dup * 2, 2, drow(unsigned(first)));
  }
  for (unsigned p = 0; p != r.cmpl.size() && p != NM; ++p) setField(dut->cm_tag_cq02h, p * TW, TW, r.cmpl[p]);
  events += r.done.size() + r.cmpl.size();
  // The leads: the next cycle's. A stopping cycle is driven empty (the
  // stop tail), so it has none.
  if (nx.r.stop) return;
  for (unsigned q = 0; q != S; ++q) {
    bool al = false;
    for (const auto &a : nx.r.alloc) al = al || a.slot == q;
    setBit(dut->al_l_cq01h, q, al && control != "no-lead");
    setBit(dut->ev_l_cq01h, q, hasEvent(nx.r, q));
    setBit(dut->rel_l_cq01h, q, (nx.r.release >> q) & 1u);
  }
  // A fill next cycle: the allocations fillLag() - 1 cycles before this one.
  dut->fl_l_cq01h = hist.size() >= fillLag() && !hist[hist.size() - fillLag()].empty();
  // ... and whether a branch is among them (no-branch-lead: never).
  bool brl = false;
  if (hist.size() >= fillLag())
    for (const auto &a : hist[hist.size() - fillLag()]) brl = brl || a.br;
  dut->fl_brl_cq01h = brl && control != "no-branch-lead";
  // The dones' leads: next cycle's slots, as it will place them (its
  // allocations are this cycle's, so br_of already holds them).
  const std::vector<int> nsl = doneSlots(nx.r);
  bool nany = false;
  for (unsigned p = 0; p != ND; ++p) if (nsl[p] >= 0) { setBit(dut->dn_l_cq01h, p, true); nany = true; }
  if (control == "two-in-a-cycle" && nany)
    for (unsigned p = 0; p != ND; ++p) if (nsl[p] < 0 && p != BS) { setBit(dut->dn_l_cq01h, p, true); break; }
  if (std::getenv("ROB_DEBUG") && (!r.done.empty() || !nx.r.done.empty()))
    std::fprintf(stderr, "ROB_DEBUG drive cycle %llu dones %zu next %zu\n", cycles, r.done.size(), nx.r.done.size());
  for (unsigned p = 0; p != nx.r.cmpl.size() && p != NM; ++p) setBit(dut->cm_l_cq01h, p, true);
}

// The resolution: last cycle's (the model's resolve, logged in the cycle
// before the RTL's registered outputs show it): each slot's redirect lead
// and the checkpoints right branches free; and the redirect's payload, a
// cycle after its lead (p2, the cycle before that).
void checkRes(const Cyc *p1, const Cyc *p2) {
  if (p1) {
    std::vector<uint8_t> rd(S, 0), ck(S * NK, 0);
    for (const auto &q : p1->r.redirect) if (q.slot < S) rd[q.slot] = 1;
    for (const auto &q : p1->r.ckfree) if (q.first < S && q.second < NK) ck[q.first * NK + q.second] = 1;
    resolves += p1->r.resolve.size();
    redirects += p1->r.redirect.size();
    ckfrees += p1->r.ckfree.size();
    for (unsigned s = 0; s != S; ++s)
      if (getBit(dut->rd_l_cq03h, s) != bool(rd[s])) fail("redirect lead differs", s, getBit(dut->rd_l_cq03h, s), rd[s]);
    for (unsigned b = 0; b != S * NK; ++b)
      if (getBit(dut->ckf_cq03h, b) != bool(ck[b])) fail("checkpoint free differs", b, getBit(dut->ckf_cq03h, b), ck[b]);
  }
  if (p2)
    for (const auto &q : p2->r.redirect) {
      if (q.slot >= S) continue;
      const unsigned s = q.slot;
      if (getField(dut->rd_ckpt_cq04h, s * LK, LK) != q.ckpt) fail("redirect checkpoint differs", s, getField(dut->rd_ckpt_cq04h, s * LK, LK), q.ckpt);
      if (uint32_t(getField64(dut->rd_tmask_cq04h, s * 32, 32)) != q.taken_mask)
        fail("redirect taken mask differs", s, unsigned(getField64(dut->rd_tmask_cq04h, s * 32, 32)), q.taken_mask);
      if (getField64(dut->rd_tgt_cq04h, s * PCW, PCW) != (q.target & PCM))
        fail("redirect target differs", s, unsigned(getField64(dut->rd_tgt_cq04h, s * PCW, PCW)), unsigned(q.target));
      if (getBit(dut->rd_stay_cq04h, s) != q.stay) fail("redirect stay differs", s, getBit(dut->rd_stay_cq04h, s), q.stay);
    }
}

// This cycle's retirements, from the decision; last cycle's, from the
// retire-stage register.
void check(const Cyc &c, const Cyc *prev) {
  const Core::RobLog &r = c.r;
  std::vector<unsigned> port(S, 0);
  std::vector<unsigned> g(S * RP, 0), p(S * RP, 0);
  bool gf = false, pf = false;
  for (const auto &q : r.ret) {
    if (q.slot >= S || port[q.slot] == RP) { fail("more retirements than ports", q.slot, 0, port[q.slot]); continue; }
    const unsigned k = q.slot * RP + port[q.slot]++;
    g[k] = q.gwe;
    p[k] = q.pwe;
    gf = gf || (q.gwe && q.gsec);
    pf = pf || q.pfree;
    ++retires;
  }
  for (unsigned s = 0; s != S; ++s) {
    const unsigned n = getField(dut->ret_cq02h, s * LT, LT);
    if (n != port[s]) fail("retirements differ", s, n, port[s]);
    for (unsigned k = 0; k != RP; ++k) {
      if (getBit(dut->rgl_cq02h, s * RP + k) != bool(g[s * RP + k])) fail("GPR commit lead differs", s * RP + k, getBit(dut->rgl_cq02h, s * RP + k), g[s * RP + k]);
      if (getBit(dut->rpl_cq02h, s * RP + k) != bool(p[s * RP + k])) fail("predicate commit lead differs", s * RP + k, getBit(dut->rpl_cq02h, s * RP + k), p[s * RP + k]);
    }
    if (s < c.run.size()) {
      const unsigned run = getField(dut->run_cq02h, s * LB, LB);
      if (run != std::min(c.run[s], (1u << LB) - 1)) fail("ROB run differs", s, run, c.run[s]);
      if (getBit(dut->reach_cq02h, s) != bool(c.reach[s])) fail("ROB reach differs", s, getBit(dut->reach_cq02h, s), c.reach[s]);
      if (n != c.ret[s]) fail("the go's retirements differ", s, n, c.ret[s]);
    }
  }
  // A squash's frees keyed by this cycle need the lead too; a squash
  // acting, or an entry held now or last cycle, may raise it with none (the
  // RTL's squash and held leads are supersets, OI-94).
  bool sg = false, sp = false;
  if (auto it = sq_frees.find(c.n); it != sq_frees.end()) {
    for (uint8_t b : it->second.g) sg = sg || b;
    for (uint8_t b : it->second.p) sp = sp || b;
  }
  const bool loose = !r.squash.empty() || !held.empty() || !r.hrel.empty() || act1 || act2;
  if (dut->gfree_l_cq02h ? !(gf || sg || loose) : (gf || sg)) fail("GPR free lead differs", 0, dut->gfree_l_cq02h, gf || sg);
  if (dut->pfree_l_cq02h ? !(pf || sp || loose) : (pf || sp)) fail("predicate free lead differs", 0, dut->pfree_l_cq02h, pf || sp);
  // A squash's store-and-load discard: last cycle's, from its register.
  if (prev) {
    std::vector<int> dbr(S, -1), ddp(S, -1);
    for (const auto &d : prev->r.discard) if (d.slot < S) { dbr[d.slot] = int(d.branch); ddp[d.slot] = int(d.disp); }
    for (unsigned q = 0; q != S; ++q) {
      const bool v = getBit(dut->dc_v_cq03h, q);
      if (v != (dbr[q] >= 0)) { fail("discard differs", q, v, dbr[q] >= 0); continue; }
      if (!v) continue;
      ++discards;
      if (getField(dut->dc_br_cq03h, q * LD, LD) != unsigned(dbr[q])) fail("discard branch differs", q, getField(dut->dc_br_cq03h, q * LD, LD), unsigned(dbr[q]));
      if (getField(dut->dc_disp_cq03h, q * LD, LD) != unsigned(ddp[q])) fail("discard youngest differs", q, getField(dut->dc_disp_cq03h, q * LD, LD), unsigned(ddp[q]));
    }
  }
  if (!prev) return;
  // Last cycle's store commits (slice 3): one a slot, its rob_tag.
  {
    std::vector<int> ci(S, -1);
    for (const auto &q : prev->r.commit) {
      if (q.first >= S) continue;
      if (ci[q.first] >= 0) fail("two commits in a slot", q.first, 0, 2);
      ci[q.first] = int(q.second);
    }
    for (unsigned q = 0; q != S; ++q) {
      const bool v = getBit(dut->cmt_v_cq03h, q);
      if (v != (ci[q] >= 0)) { fail("store commit differs", q, v, ci[q] >= 0); continue; }
      if (!v) continue;
      ++commits;
      const unsigned want = q * D + unsigned(ci[q]);
      if (getField(dut->cmt_tag_cq03h, q * TW, TW) != want) fail("store commit tag differs", q, getField(dut->cmt_tag_cq03h, q * TW, TW), want);
    }
  }
  // Last cycle's faults taken (slice 4): one a slot at most, its record.
  {
    std::vector<int> fi(S, -1);
    for (size_t k = 0; k != prev->r.fault.size(); ++k) {
      const auto &q = prev->r.fault[k];
      if (q.slot >= S) continue;
      if (fi[q.slot] >= 0) fail("two faults in a slot", q.slot, 0, 2);
      fi[q.slot] = int(k);
    }
    for (unsigned q = 0; q != S; ++q) {
      const bool v = getBit(dut->ft_v_cq03h, q);
      if (v != (fi[q] >= 0)) { fail("fault taken differs", q, v, fi[q] >= 0); continue; }
      if (!v) continue;
      ++faults;
      const auto &f = prev->r.fault[size_t(fi[q])];
      if (getField(dut->ft_cause_cq03h, q * CW, CW) != f.cause) fail("fault cause differs", q, getField(dut->ft_cause_cq03h, q * CW, CW), f.cause);
      if (getField64(dut->ft_pc_cq03h, q * PCW, PCW) != (f.pc & PCM))
        fail("fault pc differs", q, unsigned(getField64(dut->ft_pc_cq03h, q * PCW, PCW)), unsigned(f.pc));
      if (getField64(dut->ft_lanes_cq03h, q * 32, 32) != f.lanes)
        fail("fault lanes differ", q, unsigned(getField64(dut->ft_lanes_cq03h, q * 32, 32)), f.lanes);
    }
  }
  // Last cycle's: what ooe_rat commits, and the frees.
  std::vector<unsigned> pp(S, 0);
  std::vector<uint8_t> gm(NG * NSB, 0), pm(NP, 0);
  for (const auto &q : prev->r.ret) {
    if (q.slot >= S || pp[q.slot] == RP) continue;
    const unsigned k = q.slot * RP + pp[q.slot]++;
    if (getBit(dut->ret_gwe_cq03h, k) != q.gwe) fail("retired GPR write differs", k, getBit(dut->ret_gwe_cq03h, k), q.gwe);
    if (getBit(dut->ret_pwe_cq03h, k) != q.pwe) fail("retired predicate write differs", k, getBit(dut->ret_pwe_cq03h, k), q.pwe);
    if (q.gwe) {
      if (getField(dut->ret_dst_cq03h, k * 4, 4) != q.dst) fail("retired GPR destination differs", k, getField(dut->ret_dst_cq03h, k * 4, 4), q.dst);
      if (getField(dut->ret_gname_cq03h, k * GW, GW) != q.gname) fail("retired GPR name differs", k, getField(dut->ret_gname_cq03h, k * GW, GW), q.gname);
      if (q.gsec) {
        const unsigned row = q.gold >> (GW - GR);
        for (unsigned j = 0; j != NSB; ++j) if ((q.gsec >> j) & 1u) gm[row * NSB + j] = 1;
      }
    }
    if (q.pwe) {
      if (getField(dut->ret_pdst_cq03h, k * 2, 2) != q.pdst) fail("retired predicate destination differs", k, getField(dut->ret_pdst_cq03h, k * 2, 2), q.pdst);
      if (getField(dut->ret_pname_cq03h, k * PW, PW) != q.pname) fail("retired predicate name differs", k, getField(dut->ret_pname_cq03h, k * PW, PW), q.pname);
      if (q.pfree) pm[q.pold] = 1;
    }
  }
  if (auto it = sq_frees.find(prev->n); it != sq_frees.end()) {
    for (unsigned b = 0; b != NG * NSB; ++b) {
      if (it->second.g[b] && gm[b]) fail("GPR section freed twice", b, 0, 2);
      gm[b] |= it->second.g[b];
    }
    for (unsigned b = 0; b != NP; ++b) {
      if (it->second.p[b] && pm[b]) fail("predicate freed twice", b, 0, 2);
      pm[b] |= it->second.p[b];
    }
    sq_frees.erase(it);
  }
  for (unsigned b = 0; b != NG * NSB; ++b) {
    if (getBit(dut->gfree_cq03h, b) != bool(gm[b])) { fail("GPR section freed differs", b, getBit(dut->gfree_cq03h, b), gm[b]); break; }
    gfrees += gm[b];
  }
  for (unsigned b = 0; b != NP; ++b) {
    if (getBit(dut->pfree_cq03h, b) != bool(pm[b])) { fail("predicate freed differs", b, getBit(dut->pfree_cq03h, b), pm[b]); break; }
    pfrees += pm[b];
  }
}

Cyc pend, prev, prev2;
bool pending = false, have_prev = false, have_prev2 = false;

void hook(const Core &c) {
  const Core::GoLog &g = c.goLog();
  if (c.serial() != current) {
    if (pending && live && !stopped) ++skipped;    // the last core's last cycle: no next log for its leads
    pending = have_prev = have_prev2 = false;
    current = c.serial();
    const Config &k = c.config();
    live = k.slots == S && k.rob_depth == D && k.retire_per_rob == RP && k.rename_width <= A && k.sectioned == (NS > 0) &&
           k.defer_release_lag == 0;
    rename_preds = k.rename_preds;
    stopped = false;
    if (live) ++cores;
    if (std::getenv("ROB_DEBUG")) std::fprintf(stderr, "ROB_DEBUG core %llu: %s%s\n", (unsigned long long)current, ooeTestName(), live ? "" : " (skipped)");
    resetRtl();
  }
  if (!live || stopped) return;
  Cyc now;
  now.r = c.robLog();
  if (g.valid && g.run.size() == S) {
    now.run = g.run;
    now.ret = g.ret;
    now.reach = g.reach;
  }
  if (pending) {
    if (pend.r.stop) {
      ++stops;
      ++stop_why[pend.r.stop];
      stopped = true;
      // The stopping cycle and one more, driven empty: the resolution
      // registered from the last compared cycle (a squash's redirect lead,
      // the squash itself slice 2's next part) and its payload.
      clearInputs();
      driveFills({});
      dut->eval();
      checkRes(have_prev ? &prev : nullptr, have_prev2 ? &prev2 : nullptr);
      tick();
      clearInputs();
      driveFills({});
      dut->eval();
      checkRes(nullptr, have_prev ? &prev : nullptr);
      tick();
      return;
    }
    ++cycles;
    pend.n = cycles;
    account(pend);
    drive(pend, now);
    dut->eval();
    if (const char *w = std::getenv("ROB_TRACE")) {
      const unsigned long long lo = std::strtoull(w, nullptr, 10);
      if (cycles + 12 >= lo && cycles <= lo + 4) {
        std::string t = "TRACE " + std::to_string(cycles) + " t" + std::to_string(cg.t) + ":";
        for (const auto &a : pend.r.alloc) t += " A" + std::to_string(a.slot * D + a.idx);
        for (const auto &q : pend.r.squash) t += " SQ" + std::to_string(q.slot) + "/" + std::to_string(q.keep);
        for (const auto &e : pend.r.sq_ent) t += std::string(e.second ? " h" : " s") + std::to_string(e.first);
        for (unsigned x : pend.r.hrel) t += " R" + std::to_string(x);
        for (const auto &q : pend.r.ret) t += " ret" + std::to_string(q.slot * D + q.idx);
        for (unsigned x : pend.r.miu) t += " m" + std::to_string(x);
        for (unsigned x : pend.r.done) t += " d" + std::to_string(x);
        for (unsigned x : pend.r.cmpl) t += " c" + std::to_string(x);
        for (unsigned x : pend.r.owe) t += " o" + std::to_string(x);
        if (!pend.run.empty())
          t += " | run " + std::to_string(pend.run[0]) + "/" + std::to_string(int(pend.reach[0])) + " rtl " +
               std::to_string(getField(dut->run_cq02h, 0, LB)) + "/" + std::to_string(getBit(dut->reach_cq02h, 0));
        std::fprintf(stderr, "%s\n", t.c_str());
      }
    }
    check(pend, have_prev ? &prev : nullptr);
    checkRes(have_prev ? &prev : nullptr, have_prev2 ? &prev2 : nullptr);
    tick();
    act2 = act1;
    act1 = !pend.r.squash.empty() || !held.empty() || !pend.r.hrel.empty();
    prev2 = prev;
    have_prev2 = have_prev;
    prev = pend;
    have_prev = true;
  }
  pend = now;
  pending = true;
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("ROB_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd) || std::getenv("ROB_VCD")) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_rob_tb>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  else if (const char *dv = std::getenv("ROB_VCD")) cg.open(*dut, dv);   // debugging
  // The random programs mispredict nothing, so a core runs past where its
  // first squash would stop it (slice 2's next part); ROB_MISPREDICT=1 runs
  // them as drawn, each core to its first squash, its redirect compared
  // drawn (right-always needs mispredicts to miss).
  // The squash's controls need squashes.
  const bool sq_control = control == "no-miu" || control == "no-store" || control == "drop-killed-fill";
  ooeTestPredictAll(std::getenv("ROB_MISPREDICT") == nullptr && control != "right-always" && !sq_control);
  const int model_fails = (cg.on() ? 0 : ooeTestDirectedHookedWith(hook, robConfig)) +
                          cg.run(seeds, nullptr, hook, robConfig);
  cg.close();
  dut->final();
  std::printf("rob_tb control=%s seeds=%u cores=%llu cycles=%llu allocs=%llu nops=%llu events=%llu retires=%llu "
              "gpr-frees=%llu pred-frees=%llu resolves=%llu redirects=%llu ckpt-frees=%llu stopped=%llu skipped=%llu "
              "squashes=%llu squashed=%llu held=%llu killed=%llu held-releases=%llu discards=%llu commits=%llu faults=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, allocs, nops, events, retires, gfrees,
              pfrees, resolves, redirects, ckfrees, stops, skipped, squashes, sq_ents, sq_held, sq_kills, hrels, discards,
              commits, faults, mismatches, model_fails);
  if (br_two) std::printf("  cycles with two branch dones (RCU's one a cycle): %llu\n", br_two);
  for (const auto &kv : stop_why) std::printf("  stopped at %s: %llu\n", kv.first.c_str(), kv.second);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
