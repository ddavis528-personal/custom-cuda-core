//===-- wake_tb.cpp - ooe_wake against the live model ----------------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode:
// bypass, L1 speculation with hits and misses, completion delays, replays,
// squashes, several warps) and clocks ooe_wake once per core cycle, one
// cycle behind the model, so that each lead is driven a cycle before its
// event (OA's response OI-58). The edge for cycle t takes what reached each
// RS entry's wake timer (Core::wakeLog): the grants of cycle t - 1, with
// their kind, class and whether they write a register (Core::rsProduces),
// and the completions (as RS indices) of cycle t, which the model takes
// before its select, ooe_rs's matrix as t's cancel hop read it (hop_dep)
// and t's frees that are no confirmation (the registered squash's); and the
// leads of cycle t + 1: the completion channel's valid, and a squash's.
// ooe_wake replays and confirms on its own (OI-45): its stops must be the
// model's, which the issued bits show, and its held misses (msd_cq02h) the
// hop's (hop_msd). Its lines lead the model's by two cycles (OA's response
// OI-45): after the edge into t they must be the model's at t + 2 on every
// entry no stop reaches before then, with the completion hints driven from
// the model's completions two cycles on (OA-23), so the bench runs three
// cycles behind the model.
// After the edge, every valid entry's four lines and its issued bit must be
// the model's (Core::wakeLine and Core::rsIssued at t, what select read), and every miss pulse the
// model's L1 miss cancel at t. The RTL's fin (the result is final) must be
// set for every entry the model confirmed on its timer's word at t, and
// equal Core::rsFinal for every other valid entry not stopped at t.
//
// A core whose bypass penalties or latencies differ from the RTL's
// parameters (a knob-set table in the unit tests) is skipped and counted.
//
// Negative controls (WAKE_CONTROL=<name>) perturb what the RTL is driven
// with, and must be caught: late-grant (each grant reaches the RTL a cycle
// late), drop-cmpl (completions never reach it), no-dep (the matrix never
// does, so no replay and every issued entry confirms on its word),
// drop-squash-free (a squash's frees never reach it), no-cmpl-lead (the
// completion channel's valid never does) and no-sq-lead (nor a squash's
// lead) and no-hint (the completion hints never do).
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: wake_tb [seeds] | wake_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_wake.h"
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

int ooeTestDirectedHooked(void (*hook)(const Core &));

namespace {
constexpr unsigned N = WAKE_N, L = Core::kWakeLines;

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_wake> dut;
std::string control;
uint64_t current = 0;          // the serial of the core being followed
bool following = false;        // its configuration is the RTL's
// A cycle as the model ended it: its log, and what the bench reads of the
// core then.
struct Cyc {
  Core::WakeLog w;
  std::vector<uint8_t> prod, valid, fin, line, iss, wtl, sqf;
  bool wml = false;              // a miss, or a completion past L1
  bool sq = false;               // the squash frees an entry (a free that is no confirmation)
  unsigned ncmpl = 0;
};
unsigned long long extra_leads = 0;
unsigned long long cycles = 0, skipped = 0, cores = 0, compared = 0, raised = 0, grants = 0,
                   cmpls = 0, misses = 0, stops = 0, fins = 0, mismatches = 0;

template <typename W> void setBit(W &w, unsigned i, bool v) {
  if constexpr (sizeof(W) <= 8) {
    if (v) w |= (W(1) << i); else w &= ~(W(1) << i);
  } else {
    if (v) w[i / 32] |= (1u << (i % 32)); else w[i / 32] &= ~(1u << (i % 32));
  }
}
template <typename W> bool getBit(const W &w, unsigned i) {
  if constexpr (sizeof(W) <= 8) return (w >> i) & 1u;
  else return (w[i / 32] >> (i % 32)) & 1u;
}

CgRun cg;   // --cg <scenario> <vcd>: a clock-gating unit's bench (cg_trace.h)

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}

// The leads of a cycle's events, driven a tick before them.
// The completions' (n: the cycle whose completions the next edge takes) and
// the squash's (s: the cycle whose squash frees the next edge lands).
void driveLeads(const Cyc *n, const Cyc *s) {
  dut->cmpl_l_cq00h = 0;
  dut->sq_l_cq00h = 0;
  if (n && control != "no-cmpl-lead")
    for (unsigned k = 0; k != n->ncmpl && k != WAKE_NC; ++k) dut->cmpl_l_cq00h |= 1u << k;
  dut->sq_l_cq00h = s && s->sq && control != "no-sq-lead";
}

void fail(const char *what, unsigned e, unsigned k, bool rtl, bool model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "cycle %llu entry %u line %u: %s (rtl %d, model %d)\n", cycles, e, k, what,
                 int(rtl), int(model));
}

/// The RTL's parameters are the model's defaults; a core configured
/// otherwise is not followed.
bool sameConfig(const Core &c) {
  const Config &g = c.config();
  const std::vector<unsigned> pens = {WAKE_PEN0, WAKE_PEN1, WAKE_PEN2};
  if (!c.wakeLinesFit() || c.wakePens().size() != WAKE_NPEN) return false;
  for (unsigned k = 0; k != WAKE_NPEN; ++k)
    if (c.wakePens()[k] != pens[k]) return false;
  const unsigned lat[8] = {WAKE_LAT0, WAKE_LAT1, WAKE_LAT2, WAKE_LAT3, WAKE_LAT4, WAKE_LAT5, WAKE_LAT6, WAKE_LAT7};
  const unsigned fast[8] = {WAKE_FAST0, WAKE_FAST1, WAKE_FAST2, WAKE_FAST3, WAKE_FAST4, WAKE_FAST5, WAKE_FAST6, WAKE_FAST7};
  for (unsigned u = 0; u != 8; ++u)
    if (g.unitLat(u) != lat[u] || g.fastOf(u) != fast[u]) return false;
  return g.lat_lane == WAKE_LAT_COPY && g.lat_l1_wake == WAKE_LAT_SPEC &&
         g.payload_stages + g.lat_l1_cmpl == WAKE_LAT_MISS && g.cmpl_wake_delay == WAKE_CMPL_DLY &&
         c.rsRcuEntries() == WAKE_NR && !g.inject_early_wake;
}

void clearInputs() {
  dut->grant_cq01h = 0;
  for (unsigned j = 0; j != N; ++j) setBit(dut->sqf_cq01h, j, false);
  for (unsigned c = 0; c != N * N; ++c) setBit(dut->dep_cq01h, c, false);
  dut->prod_cq01h = 0;
  dut->cmpl_l_cq00h = 0;
  dut->hint_l_cq00h = 0;
  dut->sq_l_cq00h = 0;
  for (unsigned j = 0; j != N; ++j) {
    for (unsigned b = 0; b != 2; ++b) setBit(dut->kind_cq01h, j * 2 + b, false);
    for (unsigned b = 0; b != 3; ++b) setBit(dut->cls_cq01h, j * 3 + b, false);
  }
}

constexpr unsigned IW = []() { unsigned w = 0; while ((1u << w) < N) ++w; return w; }();

Cyc snapCycle(const Core &c) {
  Cyc y;
  y.w = c.wakeLog();
  y.sqf.resize(N); y.prod.resize(N); y.valid.resize(N); y.fin.resize(N); y.iss.resize(N); y.line.resize(N * L); y.wtl.resize(N * L);
  for (unsigned j = 0; j != N; ++j) {
    y.prod[j] = c.rsProduces(j);
    y.valid[j] = c.rsValid(j);
    y.fin[j] = c.rsFinal(j);
    y.iss[j] = c.rsIssued(j);
    for (unsigned k = 0; k != L; ++k) {
      y.line[j * L + k] = c.wakeLine(j, k);
      y.wtl[j * L + k] = c.wakeLineChanges(j, k);
    }
    y.wml = y.wml || (j < y.w.miss.size() && y.w.miss[j]) || (j < y.w.cmpl.size() && y.w.cmpl[j] == 2);
    const bool conf = j < y.w.conf.size() && y.w.conf[j];
    // The frees that are no confirmation: the registered squash's.
    y.sqf[j] = y.w.rfree[j] && !conf;
    if (y.sqf[j]) y.sq = true;
    y.ncmpl += y.w.cmpl[j] != 0;
  }
  return y;
}

Cyc emptyCyc() {
  Cyc y;
  y.w.grant.assign(N, 0); y.w.kind.assign(N, 0); y.w.cls.assign(N, 0);
  y.prod.assign(N, 0); y.valid.assign(N, 0); y.iss.assign(N, 0); y.sqf.assign(N, 0); y.fin.assign(N, 0);
  y.line.assign(N * L, 0); y.wtl.assign(N * L, 0);
  y.w.stop.assign(N, 0); y.w.cmpl.assign(N, 0); y.w.miss.assign(N, 0);
  return y;
}
// The snapshots: H[k] is cycle t - 2 + k, where t is the cycle the next
// edge drives. The lines lead the model's by two cycles and the hints come
// two before their completions, so the bench runs three cycles behind.
std::deque<Cyc> H;

void hook(const Core &c) {
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    following = sameConfig(c);
    if (c.rsEntries() != N) {
      std::fprintf(stderr, "wake_tb: the core has %u RS entries, the RTL %u\n", c.rsEntries(), N);
      std::exit(2);
    }
    H.clear();
    clearInputs();
    dut->ooe_rst_r00h = 1;
    tick();
    dut->ooe_rst_r00h = 0;
    tick();
  }
  ++cycles;
  if (!following) { ++skipped; return; }
  // A core's first cycle: nothing granted or stopped before it.
  if (H.empty()) { H.push_back(emptyCyc()); H.push_back(emptyCyc()); }
  H.push_back(snapCycle(c));
  if (H.size() < 6) return;
  const Cyc &cm2 = H[0], &cm1 = H[1], &c0 = H[2], &cp1 = H[3], &cp2 = H[4], &cp3 = H[5];
  // The edge into cycle t (c0): the grants of t - 1 (late-grant: of t - 2),
  // the stops of t - 1 (its hop's matrix and its squash's frees), t's
  // completions and, LEAD = 2 cycles ahead, their hints; the leads of each.
  const Cyc &g = control == "late-grant" ? cm2 : cm1;
  const Core::WakeLog &w = c0.w;
  clearInputs();
  for (unsigned j = 0; j != N; ++j) {
    const bool gr = j < g.w.grant.size() && g.w.grant[j];
    if (gr) {
      setBit(dut->grant_cq01h, j, true);
      for (unsigned b = 0; b != 2; ++b) setBit(dut->kind_cq01h, j * 2 + b, (g.w.kind[j] >> b) & 1u);
      for (unsigned b = 0; b != 3; ++b) setBit(dut->cls_cq01h, j * 3 + b, (g.w.cls[j] >> b) & 1u);
      setBit(dut->prod_cq01h, j, g.prod[j]);
    }
    stops += w.stop[j];
    setBit(dut->sqf_cq01h, j, cm1.sqf[j] && control != "drop-squash-free");
    const std::vector<uint8_t> &dep = cm1.w.hop_dep;
    for (unsigned i = 0; i != N && control != "no-dep"; ++i)
      if (j * N + i < dep.size() && dep[j * N + i]) setBit(dut->dep_cq01h, j * N + i, true);
  }
  // A cycle's completions as RS indices on the channel's lanes.
  auto lanes = [&](const Cyc &y, auto &idx, bool on) {
    unsigned k = 0;
    for (unsigned j = 0; j != N && on; ++j)
      if (y.w.cmpl[j]) {
        if (k == WAKE_NC) { fail("more completions than lanes", j, k, false, true); break; }
        for (unsigned b = 0; b != IW; ++b) setBit(idx, k * IW + b, (j >> b) & 1u);
        ++k;
      }
  };
  lanes(c0, dut->cmpl_idx_cq01h, control != "drop-cmpl");
  for (unsigned j = 0; j != N; ++j) cmpls += w.cmpl[j] != 0;
  // The hints (OA-23): t + 2's completions, their valid a cycle before.
  lanes(cp2, dut->hint_idx_cq01h, control != "no-hint");
  dut->hint_l_cq00h = 0;
  if (control != "no-hint")
    for (unsigned k = 0; k != cp3.ncmpl && k != WAKE_NC; ++k) dut->hint_l_cq00h |= 1u << k;
  driveLeads(&cp1, &c0);
  tick();
  // After it: the model's state in t, and its lines two cycles on.
  for (unsigned j = 0; j != N; ++j) {
    const bool want_miss = w.miss[j], got_miss = getBit(dut->miss_cq02h, j);
    misses += want_miss;
    // The model squashes before its L1 check; ooe_wake frees a squashed
    // entry at the edge after (the squash is registered), with all that
    // is younger in its warp, so a miss pulse there reaches nothing.
    if (want_miss != got_miss && !c0.sqf[j]) fail("miss differs", j, 0, got_miss, want_miss);
    const bool got_fin = getBit(dut->fin_cq02h, j);
    if (w.fin[j]) {
      ++fins;
      if (!got_fin) fail("confirmed, but not final", j, 0, got_fin, true);
    } else if (c0.valid[j] && !w.stop[j] && got_fin != bool(c0.fin[j])) {
      fail("final differs", j, 0, got_fin, c0.fin[j]);
    }
    // Issued as the timer holds it, on every entry: the model's at the end
    // of t - 1, with its grants and stops (t's reach the timer at the next
    // edge); and clear on a free entry, which every free's stop leaves so
    // (a stop the timer missed would leave it issued).
    const bool got_iss = getBit(dut->iss_cq02h, j), want_iss = cm1.valid[j] && cm1.iss[j];
    if (got_iss != want_iss) fail("issued differs", j, 0, got_iss, want_iss);
    // The held misses, as t's hop reads them, but on an entry the squash
    // frees at t, which the model's hop reads after the free: whatever
    // depends on it is younger in its warp, freed with it.
    const bool got_msd = getBit(dut->msd_cq02h, j), want_msd = j < w.hop_msd.size() && w.hop_msd[j];
    if (got_msd != want_msd && !c0.sqf[j]) fail("held miss differs", j, 0, got_msd, want_msd);
    // The lines lead the model's by two cycles (OA's response OI-45): the
    // model's at t + 2, on an entry valid then and stopped at none of t,
    // t + 1 and t + 2, which the timer cannot foresee.
    const bool stopped = w.stop[j] || cp1.w.stop[j] || cp2.w.stop[j];
    if (cp2.valid[j] && !stopped)
      for (unsigned k = 0; k != L; ++k) {
        ++compared;
        const bool want = cp2.line[j * L + k], got = getBit(dut->wake_cq02h, j * L + k);
        raised += want;
        if (want != got) fail("lead line differs", j, k, got, want);
      }
    // ooe_rs's confirmation lead: the model-frame full-latency line's
    // change at the next edge, as the model predicted it a cycle ago
    // (Core::wakeLineChanges at t - 1), on an entry valid at t and not
    // stopped at t.
    if (c0.valid[j] && !w.stop[j]) {
      const bool want = cm1.valid[j] && cm1.wtl[j * L + 3], got = getBit(dut->flt_cq02h, j);
      if (want != got) fail("model-frame lead differs", j, 3, got, want);
    }
    // ooe_sched's timer lead: the lead lines' change at the next edge, the
    // model's at t + 3 against t + 2 (Core::wakeLineChanges at t + 1), on
    // an entry stopped at neither t nor t + 1, nor granted at t: a grant's
    // lead line can rise at the edge it arrives, which ooe_sched leads from
    // its own grant register. It may be a superset (a foreseen miss drops a
    // lead line where the model's timers see none).
    if (cp1.valid[j] && !w.stop[j] && !cp1.w.stop[j] && !w.grant[j])
      for (unsigned k = 0; k != L; ++k) {
        const bool want = cp1.wtl[j * L + k], got = getBit(dut->wtl_cq02h, j * L + k);
        if (want && !got) fail("timer lead missed", j, k, got, want);
        extra_leads += got && !want;
      }
  }
  // Its event lead: the hints of t + 2 move lead lines at the next edge.
  if (cp2.ncmpl && !dut->wml_cq02h) fail("event lead missed", 0, 0, false, true);
  for (unsigned j = 0; j != N; ++j) grants += w.grant[j];
  H.pop_front();
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("WAKE_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_wake>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  // The directed tests too: long misses across a squash, demotions, kills
  // and restores, which random traffic seldom keeps a timer saturated for.
  // (The ordinary run; a scenario is the random tests'.)
  const int model_fails = (cg.on() ? 0 : ooeTestDirectedHooked(hook)) + cg.run(seeds, nullptr, hook);
  cg.close();
  dut->final();
  std::printf("wake_tb control=%s seeds=%u cores=%llu cycles=%llu skipped=%llu grants=%llu cmpls=%llu "
              "misses=%llu stops=%llu fins=%llu compared=%llu raised=%llu extra_leads=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, skipped, grants, cmpls,
              misses, stops, fins, compared, raised, extra_leads, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
