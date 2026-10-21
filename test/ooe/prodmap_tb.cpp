//===-- prodmap_tb.cpp - ooe_prodmap against the live model ---------===//
//
// Runs the model's directed and random unit tests (sim/ooe/ooe_test.cpp)
// and, after every core cycle, reads that cycle's renames (Core::ratLog:
// each uop's GPR and predicate names and its RS entries) and takes a
// snapshot of the model's producer map (Core::gprodOf, pprodOf) and RS
// valid bits. The RTL runs two cycles behind, as rename feeds it: a
// cycle's group is its lead first (rename's Rename 2 valid), then its
// names and ports (Rename 3), then ooe_rs's registered grant, the entries
// by port in allocation order (each class's ports in order; a masked
// load's copy on the RCU port after its main entry's).
//
// After each edge the RTL holds every group up to the one granted; for
// each GPR and predicate name, the compare rename makes (the valid entries
// whose occupant names it) must find exactly the model's producers in that
// group's snapshot. The RTL's assertions run too, under --assert.
//
// Negative controls (PM_CONTROL=<name>) perturb the driving and must be
// caught: no-ename (the copy port's entry takes no names, so a masked
// load's copy is never found), port-swap (a group's two RCU ports are
// exchanged in the grant) and no-lead (the lead is never driven).
// With --cg <scenario> <vcd> it is ooe_prodmap's clock-gating bench
// (test/ooe/cg_trace.h), and compares nothing.
// Usage: prodmap_tb [seeds] | prodmap_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_prodmap.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Core;
using ccv::ooe::kNoEntry;

int ooeTestRandomHooked(unsigned seeds, void (*hook)(const Core &));
int ooeTestDirectedHooked(void (*hook)(const Core &));

namespace {
constexpr unsigned N = PM_N, NR = PM_NR, A = PM_A, NG = PM_NG, NP = PM_NP, P = 2 * A;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned W = bits(N), LP = bits(P), LG = bits(NG), LQ = bits(NP);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_prodmap> dut;
std::string control;
uint64_t current = 0;
CgRun cg;

// One uop's write: its names and its entries and ports.
struct Wr {
  bool gwe = false, pwe = false, cv = false;
  unsigned gname = 0, pname = 0, main = 0, copy = 0, pm = 0, pc = 0;
};
// A cycle as the model left it: its group and its snapshot.
struct Cyc {
  std::vector<Wr> grp;
  std::vector<unsigned> gm, gc, pm;   // the model's producers, kNoEntry for none
  std::vector<bool> valid;
  bool preds = true;   // the core renames predicates (the RTL's one scheme)
};
std::vector<Cyc> hist;   // newest last: [granted, named, lead]
unsigned long long cycles = 0, cores = 0, writes = 0, copies = 0, live = 0, names = 0, mismatches = 0;

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

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}

void fail(const char *what, unsigned n, unsigned got, unsigned want) {
  if (++mismatches <= 8)
    std::fprintf(stderr, "cycle %llu: %s, name %u: rtl %u, model %u\n", cycles, what, n, got, want);
}

// Drive a group's names and ports (Rename 3), or none.
void driveNames(const std::vector<Wr> *g) {
  dut->v_cq01h = 0;
  dut->gwe_cq01h = 0;
  dut->pwe_cq01h = 0;
  dut->cv_cq01h = 0;
  clearAll(dut->gname_cq01h, A * LG);
  clearAll(dut->pname_cq01h, A * LQ);
  clearAll(dut->pm_cq01h, A * LP);
  clearAll(dut->pc_cq01h, A * LP);
  if (!g) return;
  for (unsigned u = 0; u != g->size(); ++u) {
    const Wr &w = (*g)[u];
    setBit(dut->v_cq01h, u, true);
    setBit(dut->gwe_cq01h, u, w.gwe);
    setBit(dut->pwe_cq01h, u, w.pwe);
    setBit(dut->cv_cq01h, u, w.cv && control != "no-ename");
    setField(dut->gname_cq01h, u * LG, LG, w.gname);
    setField(dut->pname_cq01h, u * LQ, LQ, w.pname);
    setField(dut->pm_cq01h, u * LP, LP, w.pm);
    setField(dut->pc_cq01h, u * LP, LP, w.pc);
  }
}

// Drive a group's grant: each port's entry.
void driveGrant(const std::vector<Wr> *g) {
  dut->gnt_v_cq02h = 0;
  clearAll(dut->gnt_idx_cq02h, P * W);
  if (!g) return;
  for (const Wr &w : *g) {
    unsigned pm = w.pm, pc = w.pc;
    if (control == "port-swap") {
      auto sw = [](unsigned p) { return p == 0 ? 1u : p == 1 ? 0u : p; };
      pm = sw(pm);
      pc = sw(pc);
    }
    setBit(dut->gnt_v_cq02h, w.pm, true);
    setField(dut->gnt_idx_cq02h, pm * W, W, w.main);
    if (w.cv) {
      setBit(dut->gnt_v_cq02h, w.pc, true);
      setField(dut->gnt_idx_cq02h, pc * W, W, w.copy);
    }
  }
}

// Every name: the compare (the valid entries whose occupant names it) must
// find exactly the model's producers, in the snapshot of the group just
// granted, after whose edge every entry it names has its names written.
void compare(const Cyc &y) {
  std::vector<std::vector<unsigned>> gby(NG), pby(NP);
  for (unsigned e = 0; e != N; ++e) {
    if (!y.valid[e]) continue;
    if (getBit(dut->eg_cq03h, e)) gby[getField(dut->egn_cq03h, e * LG, LG)].push_back(e);
    if (getBit(dut->ep_cq03h, e)) pby[getField(dut->epn_cq03h, e * LQ, LQ)].push_back(e);
  }
  for (unsigned n = 0; n != y.gm.size() && n != NG; ++n) {
    ++names;
    std::vector<unsigned> want;
    if (y.gm[n] != kNoEntry) want.push_back(y.gm[n]);
    if (y.gc[n] != kNoEntry) want.push_back(y.gc[n]);
    std::vector<unsigned> got = gby[n];
    std::sort(want.begin(), want.end());
    std::sort(got.begin(), got.end());
    if (got != want) fail("GPR producers", n, got.empty() ? N : got[0], want.empty() ? N : want[0]);
    for (unsigned e : got)   // the copy flag marks exactly the model's copy
      if (getBit(dut->ec_cq03h, e) != (e == y.gc[n])) fail("copy flag", n, e, y.gc[n]);
    live += got.size();
  }
  // Under the S1 fixed-window mode (no predicate renaming, a directed test)
  // a window name has many producers in flight; the RTL renames them.
  for (unsigned n = 0; y.preds && n != y.pm.size() && n != NP; ++n) {
    std::vector<unsigned> want;
    if (y.pm[n] != kNoEntry) want.push_back(y.pm[n]);
    if (pby[n] != want) fail("predicate producers", n, pby[n].empty() ? N : pby[n][0], want.empty() ? N : want[0]);
    live += pby[n].size();
  }
}

void resetRtl() {
  hist.clear();
  dut->v_l_cq00h = 0;
  driveNames(nullptr);
  driveGrant(nullptr);
  dut->ooe_rst_r00h = 1;
  tick();
  tick();
  dut->ooe_rst_r00h = 0;
  tick();   // the flopped reset falls: a lead on the next tick is taken
}

void hook(const Core &c) {
  if (c.rsEntries() != N || c.rsRcuEntries() != NR) {
    std::fprintf(stderr, "prodmap_tb: the core has %u RS entries (%u RCU), the RTL %u (%u)\n", c.rsEntries(),
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
  unsigned ri = 0, mi = 0;
  for (const auto &r : c.ratLog().ren) {
    if (r.rst || r.main == kNoEntry) continue;
    Wr w;
    w.gwe = r.gwe && r.gname < NG;
    w.gname = r.gname;
    w.pwe = r.pwe && r.pname < NP;
    w.pname = r.pname;
    w.main = r.main;
    w.pm = r.mem ? A + mi++ : ri++;
    w.cv = r.copy != kNoEntry;
    w.copy = w.cv ? r.copy : 0;
    w.pc = w.cv ? ri++ : 0;
    y.grp.push_back(w);
    writes += 1;
    copies += w.cv;
  }
  if (ri > A || mi > A || y.grp.size() > A) {
    fail("more allocations than ports", 0, unsigned(y.grp.size()), A);
    return;
  }
  y.gm.resize(c.gprodNames());
  y.gc.resize(c.gprodNames());
  for (unsigned n = 0; n != c.gprodNames(); ++n) {
    y.gm[n] = c.gprodOf(n, 0);
    y.gc[n] = c.gprodOf(n, 1);
  }
  y.pm.resize(c.pprodNames());
  for (unsigned n = 0; n != c.pprodNames(); ++n) y.pm[n] = c.pprodOf(n);
  y.preds = c.config().rename_preds;
  y.valid.resize(N);
  for (unsigned e = 0; e != N; ++e) y.valid[e] = c.rsLive(e);
  if (cg.on()) {
    // Clock-gating mode: a group's lead, names and grant on three ticks in
    // a row, then the scenario's gaps, so no gap falls inside a group.
    if (!y.grp.empty()) {
      dut->v_l_cq00h = 1;
      driveNames(nullptr);
      driveGrant(nullptr);
      tick();
      dut->v_l_cq00h = 0;
      driveNames(&y.grp);
      tick();
      driveNames(nullptr);
      driveGrant(&y.grp);
      tick();
      driveGrant(nullptr);
    }
    for (unsigned g = 0; g != cg.gaps(); ++g) tick();
    return;
  }
  hist.push_back(y);
  // hist: ..., [granted], [named], [lead]
  const size_t k = hist.size();
  const Cyc *named = k >= 2 ? &hist[k - 2] : nullptr;
  const Cyc *granted = k >= 3 ? &hist[k - 3] : nullptr;
  dut->v_l_cq00h = !y.grp.empty() && control != "no-lead";
  driveNames(named && !named->grp.empty() ? &named->grp : nullptr);
  driveGrant(granted && !granted->grp.empty() ? &granted->grp : nullptr);
  tick();
  if (granted) compare(*granted);
  if (k > 3) hist.erase(hist.begin());
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("PM_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_prodmap>(ctx.get());
  if (cg.on()) {
    cg.open(*dut, vcd);
    resetRtl();
    if (cg.idle()) {
      for (unsigned k = 0; k != CgRun::kIdleCycles; ++k) tick();
    } else {
      ooeTestRandomHooked(CgRun::kSeeds, hook);
    }
    cg.close();
    dut->final();
    cg.vcd.reset();
    dut.reset();
    ctx.reset();
    return 0;
  }
  const int model_fails = ooeTestDirectedHooked(hook) + ooeTestRandomHooked(seeds, hook);
  dut->final();
  std::printf("prodmap_tb control=%s seeds=%u cores=%llu cycles=%llu writes=%llu copies=%llu names=%llu "
              "live=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, writes, copies, names, live,
              mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
