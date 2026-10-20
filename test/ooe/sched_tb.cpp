//===-- sched_tb.cpp - ooe_sched against the live model --------------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp) and drives
// ooe_sched one model cycle behind, cycle for cycle, from what the model
// held and did (Core::wakeLog and the RS's state at each cycle's end):
//
//   - the ready and request registers' next values: each valid row's
//     dependency bits and line selects, each valid producer's wake lines as
//     they stand next cycle (Core::wakeLineNext), and each entry's valid,
//     issued (as ooe_wake holds it after the edge: the model's, less this
//     cycle's grants, which ooe_wake takes from the grant register at the
//     next), slot, copy flag and its slot's warp active;
//   - the leads: ooe_wake's timer lead per producer (Core::wakeLineChanges), ooe_rs's
//     allocation (a row written at this edge), and from the next model
//     cycle, which is why the bench runs a cycle behind, the hop's missed
//     bits (hop_msd: what ooe_wake holds after this edge) and ooe_wake's
//     event lead (a miss or a completion at the next cycle, changing lines
//     at its edge: cmpl_wake_delay is 1, so a completion past L1 is no
//     timer's);
//   - select's live terms, as the model's select logged them (sel_*),
//     with the age matrices from allocation order.
//
// After each edge: the grant register must be the model's grants, the
// request register the model's (Core::requestRegister, exactly), and the
// ready register the model's on every row V-73 holds (valid and past
// rename's stages next cycle). The model's ready register captures a
// change the timers did not predict (a stop, a miss) on its own edge by
// fiat; the RTL by the stop lead and the miss lead, so this comparison is
// OI-54's claim that those leads suffice.
//
// Followed: cores with the sectioned select, the ready and request
// registers, renamed predicates and memops in program order, whose bypass
// penalties fit the wake lines. Others are skipped and counted.
//
// Negative controls (SCHED_CONTROL=<name>) perturb the driving and must be
// caught: no-msd (the missed bits never reach the stop lead), no-miss-lead
// (no event lead),
// late-leads (the miss lead and missed bits a cycle late, as their own
// flops would give them) and no-alloc-lead.
//
// With --cg <scenario> <vcd> it is ooe_sched's clock-gating bench
// (test/ooe/cg_trace.h), and compares nothing.
// Usage: sched_tb [seeds] | sched_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_sched.h"
#include "Vooe_sched___024root.h"
#include "verilated.h"
#include "ooe_core.h"
#include "cg_trace.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Config;
using ccv::ooe::Core;

int ooeTestRandomHooked(unsigned seeds, void (*hook)(const Core &));

namespace {
constexpr unsigned N = SCH_N, NR = SCH_NR, NM = N - NR, S = SCH_S, WL = Core::kWakeLines;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned LS = bits(S), W = bits(N);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_sched> dut;
std::string control;
CgRun cg;   // --cg <scenario> <vcd>: a clock-gating unit's bench (cg_trace.h)
unsigned long long cycles = 0, followed = 0, skipped = 0, cores = 0, grants = 0, rq_set = 0, ready_rows = 0,
                   misses = 0, stops = 0, mismatches = 0;

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

// One model cycle, as the bench drives and checks it.
struct Snap {
  bool live = false;              // the sectioned select ran, and this core is followed
  // The registers' next values and the leads this cycle formed.
  std::vector<uint8_t> dep, code, wake, valid, iss, slot, copy, msd, wtl;
  unsigned active = 0;
  bool alloc = false, miss = false;
  // Select's live terms and its grants.
  std::vector<uint8_t> svalid, selig, siss, sconf, sslot, chas, grant;
  std::vector<unsigned> res, cidx;
  std::vector<uint64_t> age;
  unsigned busy = 0, block = 0;
  // The model's registers at the cycle's end, and V-73's rows.
  std::vector<uint8_t> ready_q, req_q, v73;
};

Snap prev;
bool have_prev = false;
uint64_t current = 0;
bool follow = false;

Snap snap(const Core &c) {
  Snap s;
  const Core::WakeLog &w = c.wakeLog();
  s.live = w.sel_live;
  s.dep.assign(N * N, 0);
  s.code.assign(N * N, 0);
  s.wake.assign(N * WL, 0);
  for (unsigned i = 0; i != N; ++i)
    for (unsigned j = 0; j != N; ++j)
      if (c.rsValid(i) && c.depBit(i, j)) {
        s.dep[i * N + j] = 1;
        s.code[i * N + j] = uint8_t(c.cellCode(i, j));
      }
  for (unsigned j = 0; j != N; ++j)
    for (unsigned k = 0; k != WL; ++k) s.wake[j * WL + k] = c.rsValid(j) && c.wakeLineNext(j, k);
  s.wtl.resize(N * WL);
  for (unsigned j = 0; j != N; ++j)
    for (unsigned k = 0; k != WL; ++k) s.wtl[j * WL + k] = c.rsValid(j) && c.wakeLineChanges(j, k);
  s.valid.resize(N); s.iss.resize(N); s.slot.resize(N); s.copy.resize(N); s.msd.assign(N, 0);
  s.ready_q.resize(N); s.req_q.resize(N); s.v73.resize(N);
  for (unsigned e = 0; e != N; ++e) {
    s.valid[e] = c.rsValid(e);
    s.iss[e] = c.rsIssued(e);
    s.slot[e] = uint8_t(c.rsSlot(e));
    s.copy[e] = c.rsCopy(e);
    if (e < w.hop_msd.size() && w.hop_live) s.msd[e] = w.hop_msd[e];
    s.ready_q[e] = c.readyQ(e);
    s.req_q[e] = c.reqQ(e);
    s.v73[e] = c.rsValid(e) && c.rsEligibleNext(e);
  }
  for (unsigned si = 0; si != S; ++si)
    if (c.slotActive(si)) s.active |= 1u << si;
  s.alloc = !w.ralloc.empty();
  for (unsigned e = 0; e != N && e < w.miss.size(); ++e) s.miss = s.miss || w.miss[e];
  for (unsigned e = 0; e != N && e < w.cmpl.size(); ++e) s.miss = s.miss || w.cmpl[e] == 2;
  s.svalid = w.sel_valid; s.selig = w.sel_elig; s.siss = w.sel_iss; s.sconf = w.sel_conf;
  s.sslot = w.sel_slot; s.chas = w.sel_chas; s.grant = w.sel_grant; s.res = w.sel_res; s.cidx = w.sel_cidx;
  s.busy = w.sel_busy >> 5;
  s.block = w.sel_block;
  s.age.resize(N);
  for (unsigned e = 0; e != N; ++e) s.age[e] = c.rsAge(e);
  return s;
}

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}

// An idle cycle, between model cycles: nothing arrives (no lead, no line
// or row changes), and ooe_sched keeps issuing what its registers hold
// ready, each grant counted issued from the next edge as ooe_wake would
// take it (iss_cq02h's contract, and select's live issued bits).
void idleTick() {
  for (unsigned e = 0; e != N; ++e) {
    for (unsigned k = 0; k != WL; ++k) setBit(dut->wtl_cq02h, e * WL + k, false);
    if (getBit(dut->grant_cq04h, e)) {
      setBit(dut->iss_cq02h, e, true);
      setBit(dut->siss_cq03h, e, true);
    }
  }
  dut->wml_cq02h = 0;
  dut->alloc_cq02h = 0;
  for (unsigned e = 0; e != N; ++e) setBit(dut->msd_cq02h, e, false);
  tick();
}

void reset() {
  for (unsigned e = 0; e != N * WL; ++e) setBit(dut->wtl_cq02h, e, false);
  dut->wml_cq02h = dut->alloc_cq02h = 0;
  dut->ooe_rst_r00h = 1;
  tick();
  tick();
  dut->ooe_rst_r00h = 0;
}

void fail(const char *what, unsigned e, bool rtl, bool model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "cycle %llu entry %u: %s (rtl %d, model %d)\n", cycles, e, what, int(rtl), int(model));
}

// Drive model cycle p, with the next cycle's missed bits and miss (n), and
// clock the edge at its end.
void drive(const Snap &p, const Snap &n) {
  const bool late = control == "late-leads";
  const Snap &l = late ? p : n;
  for (unsigned i = 0; i != N * N; ++i) {
    setBit(dut->dep_cq02h, i, p.dep[i]);
    setBit(dut->code_cq02h, i * 2, p.code[i] & 1u);
    setBit(dut->code_cq02h, i * 2 + 1, (p.code[i] >> 1) & 1u);
  }
  for (unsigned i = 0; i != N * WL; ++i) setBit(dut->wake_cq02h, i, p.wake[i]);
  for (unsigned e = 0; e != N; ++e) {
    setBit(dut->valid_cq02h, e, p.valid[e]);
    // Issued after this edge as ooe_wake holds it: the grant leaving now
    // counted, this cycle's own (the grant register's next) not yet.
    setBit(dut->iss_cq02h, e, p.iss[e] && !(e < p.grant.size() && p.grant[e]));
    setField(dut->slot_cq02h, e * LS, LS, p.slot[e]);
    setBit(dut->copy_cq02h, e, p.copy[e]);
    setBit(dut->msd_cq02h, e, control != "no-msd" && l.msd[e]);
  }
  dut->active_cq02h = p.active;
  for (unsigned j = 0; j != N * WL; ++j) setBit(dut->wtl_cq02h, j, p.wtl[j]);
  dut->wml_cq02h = control != "no-miss-lead" && l.miss;
  dut->alloc_cq02h = control != "no-alloc-lead" && p.alloc;
  // Select's live terms.
  for (unsigned e = 0; e != N; ++e) {
    const bool v = e < p.svalid.size() && p.svalid[e];
    setBit(dut->vel_cq03h, e, v && p.selig[e]);
    setBit(dut->siss_cq03h, e, v && p.siss[e]);
    for (unsigned j = 0; j != N; ++j) setBit(dut->sdep_cq03h, e * N + j, v && !p.sconf[e] && j == e);
    setField(dut->sslot_cq03h, e * LS, LS, v ? p.sslot[e] : 0);
    setField(dut->res_cq03h, e * 9, 9, v ? p.res[e] : 0);
    setBit(dut->chas_cq03h, e, v && p.chas[e]);
    setField(dut->cidx_cq03h, e * W, W, v ? p.cidx[e] : 0);
  }
  for (unsigned e = 0; e != NR; ++e)
    for (unsigned j = 0; j != NR; ++j) setBit(dut->older_r_cq03h, e * NR + j, p.age[j] < p.age[e]);
  for (unsigned e = 0; e != NM; ++e)
    for (unsigned j = 0; j != NM; ++j) setBit(dut->older_m_cq03h, e * NM + j, p.age[NR + j] < p.age[NR + e]);
  dut->busy_cq03h = p.busy;
  dut->block_cq03h = p.block;
  tick();
}

void check(const Snap &p) {
  // The registers, read inside the DUT (built --public-flat-rw).
  const auto *r = dut->rootp;
  for (unsigned e = 0; e != N; ++e) {
    const bool g = getBit(dut->grant_cq04h, e);
    const bool want = e < p.grant.size() && p.grant[e];
    grants += want;
    if (g != want) fail("grant differs", e, g, want);
    const bool q = getBit(r->ooe_sched__DOT__rq_cq03h, e);
    rq_set += p.req_q[e];
    if (q != bool(p.req_q[e])) {
      fail("request register differs", e, q, p.req_q[e]);
      if (std::getenv("SCHED_DEBUG") && mismatches <= 5)
        std::fprintf(stderr, "  valid %d iss %d slot %u active %#x copy %d dep-row %d grant %d\n", p.valid[e], p.iss[e],
                     p.slot[e], p.active, p.copy[e], [&] { for (unsigned j = 0; j != N; ++j) if (p.dep[e * N + j]) return 1; return 0; }(),
                     e < p.grant.size() ? int(p.grant[e]) : -1);
    }
    if (!p.v73[e]) continue;
    ++ready_rows;
    const bool rd = getBit(r->ooe_sched__DOT__ready_cq03h, e);
    if (rd != bool(p.ready_q[e])) fail("ready register differs (V-73)", e, rd, p.ready_q[e]);
  }
}

void hook(const Core &c) {
  ++cycles;
  if (c.rsEntries() != N || c.rsRcuEntries() != NR) {
    std::fprintf(stderr, "sched_tb: the core has %u RS entries (%u RCU), the RTL %u (%u)\n", c.rsEntries(),
                 c.rsRcuEntries(), N, NR);
    std::exit(2);
  }
  if (c.serial() != current) {
    current = c.serial();
    const Config &g = c.config();
    follow = g.sectioned && g.ready_reg && g.req_reg && g.rename_preds && !g.loads_pass_loads;
    have_prev = false;
    ++cores;
    reset();
  }
  if (follow && !c.wakeLinesFit()) follow = false;
  if (!follow) { ++skipped; return; }
  Snap s = snap(c);
  if (have_prev) {
    ++followed;
    for (unsigned e = 0; e != N; ++e) stops += s.msd[e];
    misses += s.miss;
    drive(prev, s);
    if (cg.on()) {
      for (unsigned g = 0; g != cg.gaps(); ++g) idleTick();
    } else {
      check(prev);
    }
  }
  prev = std::move(s);
  have_prev = true;
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("SCHED_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_sched>(ctx.get());
  if (cg.on()) {
    cg.open(*dut, vcd);
    reset();
    if (cg.idle()) {
      for (unsigned k = 0; k != CgRun::kIdleCycles; ++k) idleTick();
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
  const int model_fails = ooeTestRandomHooked(seeds, hook);
  dut->final();
  std::printf("sched_tb control=%s seeds=%u cores=%llu cycles=%llu followed=%llu skipped=%llu grants=%llu "
              "requests=%llu ready_rows=%llu misses=%llu missed_bits=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, followed, skipped, grants, rq_set,
              ready_rows, misses, stops, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
