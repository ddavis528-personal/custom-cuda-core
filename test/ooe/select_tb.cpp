//===-- select_tb.cpp - ooe_select against the live model ------------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp) and, after
// every core cycle in which the sectioned select ran, drives ooe_select
// with the inputs that select logged as it saw them (Core::wakeLog:
// sel_*): each entry's request term (ooe_sched's request register), ready
// and grant registers, valid and past rename, issued and sources-confirmed
// bits, slot, footprint, and a memop's copy, and the bulk discard's pipes
// and warps. The age matrices come from the entries' allocation order
// (Core::rsAge). The dependency rows come from the sources-confirmed bits:
// an entry with unconfirmed sources gets one bit, on itself, which is all
// ooe_select reads of a row (any bit set).
//
// Its candidates must be the select's, and its grants the select's.
//
// Followed: cores with sectioned lanes, renamed predicates and memops in
// program order (OA-13's loads-pass-loads is not built: OI-15 holds).
// Others are skipped and counted.
//
// Negative controls (SELECT_CONTROL=<name>) perturb the driving and must
// be caught: no-order (every memop sees no older unissued memop of its
// warp), no-conf (every source counts as confirmed) and no-busy (a bulk
// discard takes nothing).
// Usage: select_tb [seeds]
//===----------------------------------------------------------------------===//
#include "Vooe_select.h"
#include "verilated.h"
#include "ooe_core.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>

using ccv::ooe::Config;
using ccv::ooe::Core;

int ooeTestRandomHooked(unsigned seeds, void (*hook)(const Core &));

namespace {
constexpr unsigned N = SEL_N, NR = SEL_NR, NM = N - NR, S = SEL_S;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned LS = bits(S), W = bits(N);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_select> dut;
std::string control;
unsigned long long cycles = 0, followed = 0, cands = 0, grants = 0, memops = 0, mismatches = 0;

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

void fail(const char *what, unsigned e, bool rtl, bool model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "cycle %llu entry %u: %s (rtl %d, model %d)\n", cycles, e, what, int(rtl), int(model));
}

void hook(const Core &c) {
  ++cycles;
  const Core::WakeLog &w = c.wakeLog();
  const Config &g = c.config();
  if (!w.sel_live || !g.rename_preds || g.loads_pass_loads) return;
  if (c.rsEntries() != N || c.rsRcuEntries() != NR) {
    std::fprintf(stderr, "select_tb: the core has %u RS entries (%u RCU), the RTL %u (%u)\n", c.rsEntries(),
                 c.rsRcuEntries(), N, NR);
    std::exit(2);
  }
  ++followed;
  for (unsigned e = 0; e != N; ++e) {
    setBit(dut->rq_cq03h, e, w.sel_valid[e] && w.sel_rq[e]);
    setBit(dut->ready_cq03h, e, w.sel_valid[e] && w.sel_ready[e]);
    setBit(dut->gnt_cq03h, e, w.sel_valid[e] && w.sel_gnt[e]);
    setBit(dut->vel_cq03h, e, w.sel_valid[e] && w.sel_elig[e]);
    setBit(dut->iss_cq03h, e, w.sel_valid[e] && w.sel_iss[e]);
    setField(dut->slot_cq03h, e * LS, LS, w.sel_slot[e]);
    setField(dut->res_cq03h, e * 9, 9, w.sel_res[e]);
    setBit(dut->chas_cq03h, e, w.sel_chas[e]);
    setField(dut->cidx_cq03h, e * W, W, w.sel_cidx[e]);
    const bool conf = w.sel_conf[e] || control == "no-conf";
    for (unsigned j = 0; j != N; ++j) setBit(dut->dep_cq03h, e * N + j, !conf && j == e);
  }
  // A bulk discard takes MIU pipes only (V-23).
  if (w.sel_busy & 0x1Fu) {
    std::fprintf(stderr, "select_tb: a bulk discard took a lane resource (busy %#x)\n", w.sel_busy);
    std::exit(2);
  }
  dut->busy_cq03h = control == "no-busy" ? 0 : w.sel_busy >> 5;
  dut->block_cq03h = control == "no-busy" ? 0 : w.sel_block;
  for (unsigned e = 0; e != NR; ++e)
    for (unsigned j = 0; j != NR; ++j)
      setBit(dut->older_r_cq03h, e * NR + j, c.rsAge(j) < c.rsAge(e));
  for (unsigned e = 0; e != NM; ++e)
    for (unsigned j = 0; j != NM; ++j)
      setBit(dut->older_m_cq03h, e * NM + j,
             control != "no-order" && c.rsAge(NR + j) < c.rsAge(NR + e));
  dut->eval();
  for (unsigned e = 0; e != N; ++e) {
    const bool cd = getBit(dut->cand_cq03h, e), gr = getBit(dut->grant_cq03h, e);
    cands += w.sel_cand[e];
    grants += w.sel_grant[e];
    memops += e >= NR && w.sel_grant[e];
    if (cd != bool(w.sel_cand[e])) fail("candidate differs", e, cd, w.sel_cand[e]);
    if (gr != bool(w.sel_grant[e])) fail("grant differs", e, gr, w.sel_grant[e]);
  }
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("SELECT_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  dut = std::make_unique<Vooe_select>(ctx.get());
  const int model_fails = ooeTestRandomHooked(seeds, hook);
  dut->final();
  std::printf("select_tb control=%s seeds=%u cycles=%llu followed=%llu candidates=%llu grants=%llu "
              "memops=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cycles, followed, cands, grants, memops,
              mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
