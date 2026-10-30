//===-- rob_tb.cpp - ooe_rob against the live model ------------------------===//
//
// Runs the model's directed and random unit tests (sim/ooe/ooe_test.cpp)
// with the ROB's window lag (retire_lag 1, OI-85), the random programs
// predicting every branch (slice 1 has no squash), and, after every core
// cycle, drives ooe_rob with what the model's ROB saw in it (Core::robLog):
// each slot's allocations at the go, Rename 2's fills two cycles on, the
// RS's events per entry, RCU's dones and MIU's completions by rob_tag, the
// releases. It compares the retire decision (ooe_rat's and the free lists'
// leads) and the room rename's go reads with the model's in that cycle,
// and the retire-stage register and its frees with the model's a cycle
// before. The leads are the next cycle's, so the RTL runs a model cycle
// behind. A core stops being compared at the first thing slice 1 does not
// build (RobLog::stop: a squash, a fault taken, a retire port, an atomic,
// a kill); cores with other than RB_S tier-1 slots are skipped.
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
// underflows, or the entry never completes).
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: rob_tb [seeds] | rob_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_rob.h"
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
void robConfig(Config &c) { c.retire_lag = 1; }

namespace {
constexpr unsigned NR = 4;
constexpr unsigned S = RB_S, D = RB_D, RP = RB_RP, A = RB_A, ND = RB_ND, NM = RB_NM, GW = RB_GW, GR = RB_GR,
                   NG = RB_NG, NS = RB_NS, PW = RB_PW, NP = RB_NP, LB = 6, LT = 3;
constexpr unsigned NSB = NS ? NS : 1;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned LS = S > 1 ? bits(S) : 1, LD = bits(D), TW = LS + LD, LA = bits(A + 1);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_rob> dut;
std::string control;
uint64_t current = 0;
bool live = false, stopped = false;
unsigned long long cycles = 0, cores = 0, skipped = 0, stops = 0, retires = 0, allocs = 0, nops = 0, gfrees = 0,
                   pfrees = 0, events = 0, mismatches = 0;
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
template <typename T> void clearAll(T &w, unsigned n) { for (unsigned i = 0; i != n; ++i) setBit(w, i, false); }

CgRun cg;

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}
void fail(const char *what, unsigned a, unsigned rtl, unsigned model) {
  if (++mismatches <= 8)
    std::fprintf(stderr, "cycle %llu: %s (%u: rtl %u, model %u)\n", cycles, what, a, rtl, model);
}

// A cycle as the bench drives it: the model's log, and its go log's room.
struct Cyc {
  Core::RobLog r;
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
  for (const auto *v : {&r.owe, &r.cpi, &r.cpl, &r.rsf})
    for (unsigned t : *v) if ((t >> LD) == s) return true;
  return false;
}

// ROB_DEBUG: a shadow of each tag's dones owed, as the RTL counts them.
std::vector<int> owed_dbg(S * D, 0);
std::vector<unsigned> tl_dbg(S, 0);
std::vector<std::string> hist_dbg(S * D);

void clearInputs() {
  dut->al_l_cq01h = 0;
  clearAll(dut->al_n_cq02h, S * LA);
  clearAll(dut->al_nop_cq02h, S * A);
  dut->fl_l_cq01h = 0;
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
  dut->ev_l_cq01h = 0;
  clearAll(dut->ev_owe_cq02h, S * D * NR);
  clearAll(dut->ev_cpi_cq02h, S * D);
  clearAll(dut->ev_cpl_cq02h, S * D);
  clearAll(dut->ev_rsf_cq02h, S * D * 2);
  dut->dn_l_cq01h = 0;
  clearAll(dut->dn_tag_cq02h, ND * TW);
  clearAll(dut->dn_row_cq02h, ND * 2);
  dut->cm_l_cq01h = 0;
  clearAll(dut->cm_tag_cq02h, NM * TW);
  dut->rel_l_cq01h = 0;
}

void resetRtl() {
  clearInputs();
  hist.clear();
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
    setBit(dut->al_nop_cq02h, a.slot * A + n[a.slot], a.nop && control != "nop-real");
    ++n[a.slot];
    ++allocs;
    nops += a.nop;
  }
  for (unsigned s = 0; s != S; ++s) setField(dut->al_n_cq02h, s * LA, LA, n[s]);
  // Rename 2's fills: the allocations fillLag() cycles before.
  hist.push_back(r.alloc);
  if (hist.size() > 4) hist.pop_front();
  if (hist.size() > fillLag()) {
    std::vector<Core::RobLog::Alloc> fl = hist[hist.size() - 1 - fillLag()];
    if (control == "fill-order") std::reverse(fl.begin(), fl.end());
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
      ++l;
    }
  }
  // The RS's events, per entry.
  unsigned s, i;
  // Each issue owing a done, at its row (OA's rev 282): the log's owe_row
  // beside owe.
  for (size_t k = 0; k != r.owe.size(); ++k)
    if (slotOf(r.owe[k], s, i)) setBit(dut->ev_owe_cq02h, (s * D + i) * NR + (k < r.owe_row.size() ? r.owe_row[k] : 0), true);
  for (unsigned t : r.cpi) if (slotOf(t, s, i) && control != "no-copy") setBit(dut->ev_cpi_cq02h, s * D + i, true);
  for (unsigned t : r.cpl) if (slotOf(t, s, i)) setBit(dut->ev_cpl_cq02h, s * D + i, true);
  bool dropped = false;
  for (unsigned t : r.rsf)
    if (slotOf(t, s, i)) {
      if (control == "drop-free" && !dropped) { dropped = true; continue; }
      setField(dut->ev_rsf_cq02h, (s * D + i) * 2, 2, getField(dut->ev_rsf_cq02h, (s * D + i) * 2, 2) + 1);
    }
  events += r.owe.size() + r.cpi.size() + r.cpl.size() + r.rsf.size();
  // RCU's dones and MIU's completions.
  // Each done's row is the one RCU echoed (done_row, TI's 6ba08b1).
  auto drow = [&](size_t p) {
    const unsigned w = p < r.dpay.size() ? r.dpay[p].row : 0u;
    return control == "wrong-row" && p == 0 ? (w + 1) % NR : w;
  };
  for (unsigned p = 0; p != r.done.size() && p != ND; ++p) {
    setField(dut->dn_tag_cq02h, p * TW, TW, r.done[p]);
    setField(dut->dn_row_cq02h, p * 2, 2, drow(p));
  }
  if (control == "two-in-a-cycle" && !r.done.empty() && r.done.size() < ND) {
    setField(dut->dn_tag_cq02h, r.done.size() * TW, TW, r.done[0]);
    setField(dut->dn_row_cq02h, r.done.size() * 2, 2, drow(0));
  }
  for (unsigned p = 0; p != r.cmpl.size() && p != NM; ++p) setField(dut->cm_tag_cq02h, p * TW, TW, r.cmpl[p]);
  events += r.done.size() + r.cmpl.size();
  // The leads: the next cycle's.
  for (unsigned q = 0; q != S; ++q) {
    bool al = false;
    for (const auto &a : nx.r.alloc) al = al || a.slot == q;
    setBit(dut->al_l_cq01h, q, al && control != "no-lead");
    setBit(dut->ev_l_cq01h, q, hasEvent(nx.r, q));
    setBit(dut->rel_l_cq01h, q, (nx.r.release >> q) & 1u);
  }
  // A fill next cycle: the allocations fillLag() - 1 cycles before this one.
  dut->fl_l_cq01h = hist.size() >= fillLag() && !hist[hist.size() - fillLag()].empty();
  for (unsigned p = 0; p != nx.r.done.size() && p != ND; ++p) setBit(dut->dn_l_cq01h, p, true);
  if (control == "two-in-a-cycle" && !nx.r.done.empty() && nx.r.done.size() < ND)
    setBit(dut->dn_l_cq01h, nx.r.done.size(), true);
  if (std::getenv("ROB_DEBUG") && (!r.done.empty() || !nx.r.done.empty()))
    std::fprintf(stderr, "ROB_DEBUG drive cycle %llu dones %zu next %zu\n", cycles, r.done.size(), nx.r.done.size());
  for (unsigned p = 0; p != nx.r.cmpl.size() && p != NM; ++p) setBit(dut->cm_l_cq01h, p, true);
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
  if (dut->gfree_l_cq02h != gf) fail("GPR free lead differs", 0, dut->gfree_l_cq02h, gf);
  if (dut->pfree_l_cq02h != pf) fail("predicate free lead differs", 0, dut->pfree_l_cq02h, pf);
  if (!prev) return;
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
  for (unsigned b = 0; b != NG * NSB; ++b) {
    if (getBit(dut->gfree_cq03h, b) != bool(gm[b])) { fail("GPR section freed differs", b, getBit(dut->gfree_cq03h, b), gm[b]); break; }
    gfrees += gm[b];
  }
  for (unsigned b = 0; b != NP; ++b) {
    if (getBit(dut->pfree_cq03h, b) != bool(pm[b])) { fail("predicate freed differs", b, getBit(dut->pfree_cq03h, b), pm[b]); break; }
    pfrees += pm[b];
  }
}

Cyc pend, prev;
bool pending = false, have_prev = false;

void hook(const Core &c) {
  const Core::GoLog &g = c.goLog();
  if (c.serial() != current) {
    if (pending && live && !stopped) ++skipped;    // the last core's last cycle: no next log for its leads
    pending = have_prev = false;
    current = c.serial();
    const Config &k = c.config();
    live = k.slots == S && k.rob_depth == D && k.retire_per_rob == RP && k.rename_width <= A && k.sectioned == (NS > 0);
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
      return;
    }
    ++cycles;
    drive(pend, now);
    dut->eval();
    check(pend, have_prev ? &prev : nullptr);
    tick();
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
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_rob>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  // The random programs mispredict nothing, so a core runs past where its
  // first squash would stop it (slice 2's); ROB_MISPREDICT=1 runs them as
  // drawn.
  ooeTestPredictAll(std::getenv("ROB_MISPREDICT") == nullptr);
  const int model_fails = (cg.on() ? 0 : ooeTestDirectedHookedWith(hook, robConfig)) +
                          cg.run(seeds, nullptr, hook, robConfig);
  cg.close();
  dut->final();
  std::printf("rob_tb control=%s seeds=%u cores=%llu cycles=%llu allocs=%llu nops=%llu events=%llu retires=%llu "
              "gpr-frees=%llu pred-frees=%llu stopped=%llu skipped=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, allocs, nops, events, retires, gfrees,
              pfrees, stops, skipped, mismatches, model_fails);
  for (const auto &kv : stop_why) std::printf("  stopped at %s: %llu\n", kv.first.c_str(), kv.second);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
