//===-- rename_tb.cpp - ooe_rename (go, Rename 1, free lists) against the model ===//
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
// writer counts ask for, and ooe_rat takes the go's take.
//
// The go's leads and a free's are the next cycle's, so the RTL runs a model
// cycle behind: a cycle is driven at the start of the one after next, once
// the next one's logs and its whole free interval (the pre-cycle hook: the
// frees the inputs made between cycles included) are in. Before the edge,
// the go's takes and lanes must be the model's; after it, every lane of the
// Rename 1 register must be the model's rename: slot, destinations, the new
// names the free lists gave, branch and checkpoint, and every read.
//
// A core is skipped when the RTL is not built for it (other slots, widths,
// checkpoints, pool sizes or free-list buffer, or sectioned names: the
// narrow allocator is slice 6). It is stopped, from that cycle on not driven
// at all, at a restore-allocate or an atomic (slice 7's later steps), or
// where the go's inputs and rename's log disagree on what the RTL cannot
// know (a lane order other than the go's, a head's write bits other than
// its rename's, allocations other than the renames' writers); each counted.
//
// Negative controls (RENAME_CONTROL=<name>) perturb the driving and must be
// caught: drop-free (frees never reach the free lists), no-lead (nor their
// leads), no-write-bits (no head's admission bits say it writes, so the go
// asks for no names), no-hold (the go's hold lead never reaches it) and
// drop-restore (no checkpoint restore reaches ooe_rat).
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

int ooeTestDirectedPrePostWith(void (*pre)(const Core &), void (*post)(const Core &), void (*cfg)(Config &));
void renameConfig(Config &c) { c.decq_warp_max = 6; }   // go_tb's: a slot never holds more heads than the window

namespace {
constexpr unsigned S = RENAME_S, R = RENAME_R, RP = RENAME_RP, C = RENAME_C, GW = RENAME_GW, PW = RENAME_PW,
                   NG = RENAME_NG, NP = RENAME_NP;
constexpr unsigned NC = S * R, PA = 7, LU = 5, LB = 6, LT = 3, H = 2 * R - 1, XM = 5 * R, FB = 8, FK = 4;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w ? w : 1; }
constexpr unsigned LS = bits(S), LC = bits(C), LX = bits(XM + 1);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_rename_tb> dut;
std::string control;
std::mt19937 rng(11);
uint64_t current = 0;
bool skip = false;      // a core this RTL is not built for
bool stopped = false;   // a core past a cycle this slice does not cover: no longer driven
unsigned long long cycles = 0, cores = 0, skipped = 0, stops = 0, takes = 0, lanes = 0, nops = 0, names = 0, pnames = 0,
                   frees = 0, mismatches = 0;

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
struct Cycle {
  Core::GoLog g;
  Core::RatLog w;
  std::vector<unsigned> gal, gfr, pal, pfr;
};
Cycle prev, cur;          // the cycle to drive, and the next one
bool have_prev = false, have_cur = false;
std::vector<Core::RatLog::Ret> prev_ret;   // the cycle before prev's retirements

void clearInputs() {
  clearAll(dut->hv_cq01h, S * H);
  clearAll(dut->ha_cq01h, S * H * PA);
  clearAll(dut->px_cq01h, 4 * LX);
  clearAll(dut->unmet_g_cq01h, S * LU);
  clearAll(dut->unmet_p_cq01h, S * LU);
  clearAll(dut->room_g_cq01h, S * LU);
  clearAll(dut->room_p_cq01h, S * LU);
  clearAll(dut->run_cq01h, S * LB);
  clearAll(dut->ret_cq01h, S * LT);
  dut->reach_cq01h = 0;
  dut->hold_l_cq00h = (1u << S) - 1;
  dut->rbusy_l_cq00h = 0;
  dut->sq_l_cq00h = 0;
  dut->dq_ev_cq01h = 0;
  dut->rob_en_cq01h = 0;
  dut->pool_en_cq01h = 0;
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
}

// The go's inputs, as go_tb drives them: decq's heads and rename's and the
// ROB's registers from this cycle, the leads from the next.
void driveGo(const Core::GoLog &g, const Core::GoLog &nx) {
  for (unsigned s = 0; s != S; ++s) setBit(dut->hold_l_cq00h, s, nx.hold[s] && control != "no-hold");
  dut->rbusy_l_cq00h = nx.restore;
  dut->sq_l_cq00h = nx.flush & ((1u << S) - 1);
  bool pool = false;
  for (unsigned r = 0; r != 4; ++r) pool = pool || g.cred[r] != nx.cred[r];
  for (unsigned r = 0; r != 2; ++r) pool = pool || g.owed[r] != nx.owed[r];
  for (unsigned s = 0; s != S; ++s) {
    pool = pool || g.unmet_g[s] != nx.unmet_g[s] || g.unmet_p[s] != nx.unmet_p[s] || g.room_g[s] != nx.room_g[s] ||
           g.room_p[s] != nx.room_p[s];
    setBit(dut->dq_ev_cq01h, s, g.adm[s] != nx.adm[s]);
    setBit(dut->rob_en_cq01h, s, g.run[s] != nx.run[s] || g.reach[s] != nx.reach[s] || g.ret[s] != nx.ret[s]);
  }
  dut->pool_en_cq01h = pool;
  for (unsigned r = 0; r != 4; ++r) {
    const unsigned owed = r >= 2 ? g.owed[r - 2] : 0;
    setField(dut->px_cq01h, r * LX, LX, std::min(g.cred[r] - std::min(g.cred[r], owed), XM));
  }
  for (unsigned s = 0; s != S; ++s) {
    const auto &q = g.adm[s];
    for (unsigned p = 0; p != H && p < q.size(); ++p) {
      setBit(dut->hv_cq01h, s * H + p, true);
      unsigned a = q[p];
      if (control == "no-write-bits") a &= ~(3u << 3);
      setField(dut->ha_cq01h, (s * H + p) * PA, PA, a);
    }
    setField(dut->unmet_g_cq01h, s * LU, LU, sat(g.unmet_g[s], LU));
    setField(dut->unmet_p_cq01h, s * LU, LU, sat(g.unmet_p[s], LU));
    setField(dut->room_g_cq01h, s * LU, LU, sat(g.room_g[s], LU));
    setField(dut->room_p_cq01h, s * LU, LU, sat(g.room_p[s], LU));
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
  }
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
  clearInputs();
  driveGo(g, N.g);
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
  }
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
  tick();
  prev_ret = w.ret;

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
         gf.bufferCap() != FB || gf.banks() != FK || pf.bufferCap() != FB || pf.banks() != FK;
  skipped += skip;
  stopped = false;
  have_prev = have_cur = false;
  // The last core's retirements leave ooe_rat's retire stage as its leads
  // said, then the reset.
  clearInputs();
  driveRetire();
  tick();
  prev_ret.clear();
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
  have_cur = true;
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("RENAME_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_rename_tb>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  // The directed tests in the ordinary run; a scenario is the random tests'.
  const int model_fails =
      (cg.on() ? 0 : ooeTestDirectedPrePostWith(pre, post, renameConfig)) + cg.run(seeds, pre, post, renameConfig);
  cg.close();
  dut->final();
  std::printf("rename_tb control=%s seeds=%u cores=%llu cycles=%llu skipped=%llu stopped=%llu takes=%llu "
              "lanes=%llu nops=%llu gpr-names=%llu pred-names=%llu frees=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, skipped, stops, takes, lanes, nops, names,
              pnames, frees, mismatches, model_fails);
  std::printf("rename_tb stops:");
  for (unsigned k = 0; k != kWhys; ++k) std::printf(" %s=%llu", kWhyName[k], why[k]);
  std::printf("\n");
  const int rc = mismatches || model_fails || (!cg.on() && !lanes) ? 1 : 0;   // idle has no lanes
  dut.reset();
  ctx.reset();
  return rc;
}
