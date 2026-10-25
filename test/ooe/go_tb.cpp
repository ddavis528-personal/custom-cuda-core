//===-- go_tb.cpp - ooe_go against the live model -------------------------===//
//
// Runs the model's directed and random unit tests (sim/ooe/ooe_test.cpp) and,
// after every core cycle, drives ooe_go with what the model's go read in it
// (Core::goLog, under go_static: decq's heads and their decode-time
// admission bits, rename's credits less their floors owed, and the unmet floors, each
// slot's ROB run, reach and retirements), then compares the go's takes, per
// slot and lane by lane, with the model's before the edge registers the next
// cycle's fits; and each lane's candidate's writers before it, GPR and
// predicate, and the cycle's totals, by the heads' decode-time write bits
// (rename's names in lane order, OI-67). The leads (a warp's hold, a restore owning the ports, a
// slot's squash) are the next cycle's, so the RTL runs a model cycle behind,
// each cycle driven when the next one's log is in; a core's last cycle is
// not compared. Cores with other than RD_S tier-1 slots are skipped; the
// decode queue's per-warp limit is 6 (CCV_P_DECQ_WARP_MAX's value once TI's
// change is merged: a slot then never holds more heads than the go's
// window).
//
// Negative controls (GO_CONTROL=<name>) perturb the driving and must be
// caught: no-hold (the hold lead never reaches the go), no-rbusy (nor the
// restore's), no-squash (nor the squash's), no-dq-ev, no-rob-en and
// no-pool-en (a change lead for the fits' clock enables never reaches it:
// decq's heads, the ROB room, rename's credits), no-ret (this cycle's
// retirements never reach the ROB term), adm-shift (each head carries
// the next head's admission bits), no-write-bits (no head writes a GPR
// or a predicate), no-room (no slot's room to its ceiling binds) and no-corr
// (the pool register's correction never reaches the go) and no-pair-bit (no
// head marks a CAS pair's first slot). GO_DEBUG=1 dumps the first
// mismatching cycles: the heads, splits and the model's counter changes.
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: go_tb [seeds] | go_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_go.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <memory>
#include <random>
#include <string>
#include <vector>

using ccv::ooe::Config;
using ccv::ooe::Core;

int ooeTestDirectedHookedWith(void (*hook)(const Core &), void (*cfg)(Config &));
int ooeTestAtomicHookedWith(unsigned seeds, void (*hook)(const Core &), void (*cfg)(Config &));
void goConfig(Config &c) { c.decq_warp_max = 6; }

namespace {
constexpr unsigned S = GO_S, R = GO_R, PA = 9, LU = 5, LB = 6, LT = 3, H = 2 * R - 1, XM = 6 * R;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned LX = bits(XM + 1);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_go> dut;
std::string control;
std::mt19937 split_rng(7);   // the pool registers' split (drive)
uint64_t current = 0;
bool live = false;
unsigned long long cycles = 0, cores = 0, skipped = 0, takes = 0, writers = 0, restores = 0, mismatches = 0, pairs = 0;

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
unsigned sat(unsigned v, unsigned w) { return std::min(v, (1u << w) - 1); }

CgRun cg;   // --cg <scenario> <vcd>: a clock-gating unit's bench (cg_trace.h)

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

void drive(const Core::GoLog *g, const Core::GoLog *nx) {
  clearAll(dut->hv_cq01h, S * H);
  clearAll(dut->ha_cq01h, S * H * PA);
  clearAll(dut->px_cq01h, 4 * LX);
  clearAll(dut->pl_cq01h, 4 * (R + 1));
  for (unsigned r = 0; r != 4; ++r) setBit(dut->pl_cq01h, r * (R + 1), true);   // no correction: the model's credit is on time
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
  if (nx) {
    for (unsigned s = 0; s != S; ++s) setBit(dut->hold_l_cq00h, s, nx->hold[s] && control != "no-hold");
    dut->rbusy_l_cq00h = nx->restore && control != "no-rbusy";
    dut->sq_l_cq00h = control == "no-squash" ? 0 : nx->flush & ((1u << S) - 1);
  }
  // The change leads (OA's rev 174), each its producer's register enable:
  // decq's heads for a slot re-form at the next edge, a slot's ROB room
  // changes, rename's pool or floor registers change. Here exact, from the
  // next cycle's log.
  dut->dq_ev_cq01h = 0;
  dut->rob_en_cq01h = 0;
  dut->pool_en_cq01h = 0;
  if (g && nx) {
    bool pool = false;
    for (unsigned r = 0; r != 4; ++r) pool = pool || g->cred[r] != nx->cred[r] || g->pin[r] != nx->pin[r];
    for (unsigned r = 0; r != 2; ++r) pool = pool || g->owed[r] != nx->owed[r];
    for (unsigned s = 0; s != S; ++s) {
      pool = pool || g->unmet_g[s] != nx->unmet_g[s] || g->unmet_p[s] != nx->unmet_p[s] ||
             g->room_g[s] != nx->room_g[s] || g->room_p[s] != nx->room_p[s];
      if (control != "no-dq-ev") setBit(dut->dq_ev_cq01h, s, g->adm[s] != nx->adm[s]);
      if (control != "no-rob-en")
        setBit(dut->rob_en_cq01h, s, g->run[s] != nx->run[s] || g->reach[s] != nx->reach[s] || g->ret[s] != nx->ret[s]);
    }
    dut->pool_en_cq01h = pool && control != "no-pool-en";
  }
  if (!g) return;
  // Rename's pool registers: each credit less its floors owed, saturated
  // (the names' as OI-76's lag gives them, the split's own), split at random
  // into the register and its correction (a lagged take k, one-hot), as
  // rename's lagged counters give them (OI-74).
  for (unsigned r = 0; r != 4; ++r) {
    const unsigned owed = r >= 2 ? g->owed[r - 2] : 0;
    const unsigned v = g->pin_set ? g->pin[r] : g->cred[r] - std::min(g->cred[r], owed);
    unsigned k = unsigned(split_rng() % (R + 1));
    if (v + k > XM) k = 0;
    setField(dut->px_cq01h, r * LX, LX, std::min(v + k, XM));
    for (unsigned j = 0; j != R + 1; ++j) setBit(dut->pl_cq01h, r * (R + 1) + j, j == (control == "no-corr" ? 0 : k));
  }
  for (unsigned s = 0; s != S; ++s) {
    const auto &q = g->adm[s];
    for (unsigned p = 0; p != H && p < q.size(); ++p) {
      setBit(dut->hv_cq01h, s * H + p, true);
      unsigned a = control == "adm-shift" ? (p + 1 < q.size() ? q[p + 1] : 0) : q[p];
      if (control == "no-write-bits") a &= ~(3u << 3);
      // no-pair-bit: no head marks a CAS pair's first slot, so the go may
      // end a fit on one, or let the width split a pair (OI-79 (b)).
      if (control == "no-pair-bit") a &= ~(1u << 7);
      if ((a >> 7) & 1u) ++pairs;
      setField(dut->ha_cq01h, (s * H + p) * PA, PA, a);
    }
    setField(dut->unmet_g_cq01h, s * LU, LU, sat(g->unmet_g[s], LU));
    setField(dut->unmet_p_cq01h, s * LU, LU, sat(g->unmet_p[s], LU));
    // Each slot's room to its ceiling (OI-73 (3)); no-room: none binds.
    setField(dut->room_g_cq01h, s * LU, LU, control == "no-room" ? (1u << LU) - 1 : sat(g->room_g[s], LU));
    setField(dut->room_p_cq01h, s * LU, LU, control == "no-room" ? (1u << LU) - 1 : sat(g->room_p[s], LU));
    setField(dut->run_cq01h, s * LB, LB, sat(g->run[s], LB));
    setBit(dut->reach_cq01h, s, g->reach[s]);
    setField(dut->ret_cq01h, s * LT, LT, control == "no-ret" ? 0 : sat(g->ret[s], LT));
  }
}

void resetRtl() {
  drive(nullptr, nullptr);
  dut->ooe_rst_r00h = 1;
  tick();
  tick();
  dut->ooe_rst_r00h = 0;
  tick();
}

// The cycle before the latest: driven once the latest's log gives its leads.
Core::GoLog pend;
bool pending = false;

void check(const Core::GoLog &g, const Core::GoLog &nx) {
  ++cycles;
  restores += g.restore;
  drive(&g, &nx);
  dut->eval();
  // This cycle's takes, from last cycle's fits: per slot a thermometer, and
  // per lane its candidate, one-hot.
  for (unsigned s = 0; s != S; ++s) {
    unsigned t = 0;
    for (unsigned r = 0; r != R; ++r) t += getBit(dut->take_cq02h, s * R + r);
    for (unsigned r = 0; r != R; ++r)
      if (getBit(dut->take_cq02h, s * R + r) != (r < t)) fail("take is no thermometer", s, r, t);
    if (t != g.took[s]) {
      fail("take differs", s, t, g.took[s]);
      if (std::getenv("GO_DEBUG") && mismatches < 3) {
        std::fprintf(stderr, "  slot %u heads:", s);
        for (unsigned p = 0; p != g.adm[s].size(); ++p) std::fprintf(stderr, " %03x", g.adm[s][p]);
        std::fprintf(stderr, "  run %u reach %u ret %u hold %u took", g.run[s], unsigned(g.reach[s]), g.ret[s],
                     unsigned(g.hold[s]));
        for (unsigned q = 0; q != S; ++q) std::fprintf(stderr, " %u", g.took[q]);
        std::fprintf(stderr, " lanes %zu room_g %u room_p %u unmet_g %u cred %u %u %u %u", g.lanes.size(), g.room_g[s],
                     g.room_p[s], g.unmet_g[s], g.cred[0], g.cred[1], g.cred[2], g.cred[3]);
        if (s < g.split.size()) std::fprintf(stderr, " split %u %u %u %u", g.split[s][0], g.split[s][1], g.split[s][2], g.split[s][3]);
        std::fprintf(stderr, "\n");
      }
    }
    if (t && !getBit(dut->sel_cq02h, s)) fail("a take without its take-enable", s, 0, 1);
  }
  for (unsigned l = 0; l != R; ++l) {
    const bool v = getBit(dut->lane_v_cq02h, l);
    const bool w = l < g.lanes.size();
    if (v != w) { fail("lane valid differs", l, v, w); continue; }
    unsigned hits = 0, cand = 0;
    for (unsigned c = 0; c != R * S; ++c)
      if (getBit(dut->lane_c_cq02h, l * R * S + c)) { ++hits; cand = c; }
    if (hits != unsigned(v)) { fail("lane's candidate not one-hot", l, hits, v); continue; }
    if (!v) continue;
    ++takes;
    const unsigned s = cand % S, h = cand / S;
    if (s != g.lanes[l].first) fail("lane's slot differs", l, s, g.lanes[l].first);
    if (h != g.lanes[l].second) fail("lane's head differs", l, h, g.lanes[l].second);
  }
  // Each lane's writers before it, at its candidate, and the totals (OI-67):
  // rename's names in lane order, by the heads' decode-time write bits.
  unsigned before[2] = {0, 0};
  for (unsigned l = 0; l != g.lanes.size() && l != R; ++l) {
    const unsigned s = g.lanes[l].first, h = g.lanes[l].second, cand = h * S + s;
    const uint16_t a = h < g.adm[s].size() ? g.adm[s][h] : 0;
    for (unsigned b = 0; b != 2; ++b) {
      const unsigned got = getField(dut->wb_cq02h, (cand * 2 + b) * R, R);
      if (got != (1u << before[b]) - 1u) fail(b ? "predicate writers before differ" : "GPR writers before differ", l, got, (1u << before[b]) - 1u);
      before[b] += (a >> (3 + b)) & 1u;
    }
  }
  for (unsigned b = 0; b != 2; ++b) {
    const unsigned got = getField(dut->wt_cq02h, b * R, R);
    if (got != (1u << before[b]) - 1u) fail(b ? "predicate writers differ" : "GPR writers differ", 0, got, (1u << before[b]) - 1u);
    writers += before[b];
  }
  tick();
}

std::map<std::string, uint64_t> c_last;   // GO_DEBUG: the checked cycle's counter changes
void hook(const Core &c) {
  const Core::GoLog &g = c.goLog();
  if (c.serial() != current) {
    if (pending) ++skipped;          // the last core's last cycle: no next log for its leads
    pending = false;
    current = c.serial();
    live = g.adm.size() == S;
    if (live) ++cores;
    resetRtl();
  }
  if (!live || !g.valid || g.adm.size() != S) { ++skipped; return; }
  // GO_DEBUG: the model's counter changes over the cycle checked (pend's).
  static std::map<std::string, uint64_t> c_prev, c_pend;
  if (std::getenv("GO_DEBUG")) {
    c_pend.clear();
    for (const auto &kv : c.counters) {
      const uint64_t was = c_prev.count(kv.first) ? c_prev[kv.first] : 0;
      if (kv.second != was && (kv.first.rfind("rename", 0) == 0 || kv.first.rfind("stall", 0) == 0 ||
                               kv.first.rfind("hold", 0) == 0))
        c_pend[kv.first] = kv.second - was;
    }
    c_prev = c.counters;
  }
  const unsigned long long m0 = mismatches;
  if (pending) check(pend, g);
  if (std::getenv("GO_DEBUG") && pend.took.size() == S && mismatches != m0 && m0 < 3) {
    std::fprintf(stderr, "  [cycle %llu]\n", cycles);
    for (const auto &kv : c_last) std::fprintf(stderr, "    model %s +%llu\n", kv.first.c_str(), (unsigned long long)kv.second);
    for (unsigned s = 0; s != S; ++s) {
      std::fprintf(stderr, "    slot %u took %u heads:", s, pend.took[s]);
      for (unsigned p = 0; p != pend.adm[s].size(); ++p) std::fprintf(stderr, " %03x", pend.adm[s][p]);
      if (s < pend.split.size()) std::fprintf(stderr, "  split %u %u %u %u", pend.split[s][0], pend.split[s][1], pend.split[s][2], pend.split[s][3]);
      std::fprintf(stderr, "\n");
    }
    std::fprintf(stderr, "    cred %u %u %u %u owed %u %u prio %u lanes:", pend.cred[0], pend.cred[1], pend.cred[2], pend.cred[3], pend.owed[0], pend.owed[1], pend.prio);
    for (const auto &l : pend.lanes) std::fprintf(stderr, " %u.%u", l.first, l.second);
    std::fprintf(stderr, "\n");
  }
  c_last = c_pend;
  pend = g;
  pending = true;
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("GO_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_go>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  // The directed tests in the ordinary run; a scenario is the random tests'.
  // And the random atomics, whose CAS pairs the go takes whole (OI-79 (b)).
  const int model_fails = (cg.on() ? 0 : ooeTestDirectedHookedWith(hook, goConfig) +
                                         ooeTestAtomicHookedWith(seeds ? 4 : 0, hook, goConfig)) +
                          cg.run(seeds, nullptr, hook, goConfig);
  cg.close();
  dut->final();
  std::printf("go_tb control=%s seeds=%u cores=%llu cycles=%llu takes=%llu writers=%llu restore_cycles=%llu "
              "pair-heads=%llu skipped=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, takes, writers, restores, pairs, skipped,
              mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
