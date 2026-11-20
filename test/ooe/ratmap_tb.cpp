//===-- ratmap_tb.cpp - ooe_ratmap against the live model ---------------===//
//
// Runs the model's scenario "ratmap" (sim/ooe/ooe_test.cpp: the random
// tests under RAU's demotes and kills, sectioned and not, and the directed
// ones, the parked layout's among them) and, after every
// core cycle,
// drives ooe_ratmap with the cycle's map requests (Core::out.maps, each at
// its warp's slot: direction 0 a demotion's, 1 a restore-allocate's), each
// slot's warp, committed maps and committed widths, and a restore-allocate's
// read of the parked layout.
//
// The reference is the adapter's queue (sim/ooe/ooe_block.cpp): the
// cycle's maps in the model's order behind those waiting, one sent a cycle.
// A map the queue sends in cycle t must be ooe_ratmap's valid in t + 1 and
// its payload in t + 2: the warp, the direction, each register's row,
// position (0 for the zero register) and committed width, and each
// predicate's name. A cycle the queue sends nothing, the valid must be low.
// After a demotion's map, the parked layout's entry for its warp must be
// the model's (Core::parkedPos/parkedWidth); a restore-allocate's read of
// it, a cycle after its lead, must be the model's too.
//
// A register name is opaque here as in ooe_rat: the model names a GPR by
// row alone when it is not sectioned, so the bench gives those the RTL's
// form, the row at position 0.
//
// Negative controls (RATMAP_CONTROL=<name>) perturb the driving and must be
// caught: wrong-slot (a demotion's request on the next slot), cw-shift
// (each slot's widths from the next slot), no-read-lead (a
// restore-allocate's read is not led) and restore-first (ooe_ratmap's
// ctl_rfirst: among requests arriving together, a restore's is older).
//
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: ratmap_tb [seeds] | ratmap_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_ratmap.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <cstdio>
#include <cstdlib>
#include <deque>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Core;

int ooeTestScenario(const std::string &scenario, unsigned seeds, unsigned idle_cycles, void (*pre)(const Core &),
                    void (*post)(const Core &), void (*cfg)(ccv::ooe::Config &));

namespace {
constexpr unsigned S = RATMAP_S, GW = RATMAP_GW, PB = RATMAP_PB, PW = RATMAP_PW, WB = RATMAP_WB, LW = RATMAP_LW;
constexpr unsigned NG = 16, NP = 4, MW = NG * GW + NP * PW, RW = GW - PB, NW = 1u << LW;

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_ratmap> dut;
std::string control;
CgRun cg;
uint64_t current = 0;
bool skip = false;
unsigned scale = 1;
unsigned long long cycles = 0, cores = 0, skipped = 0, maps = 0, demotes = 0, restores = 0, queued = 0,
                   together = 0, parked_checks = 0, reads = 0, narrow = 0, posd = 0, mismatches = 0;

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

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}

void fail(const char *what, unsigned a, unsigned b, unsigned rtl, unsigned model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "cycle %llu: %s (%u, %u: rtl %u, model %u)\n", cycles, what, a, b, rtl, model);
}

// A GPR name in the RTL's form.
unsigned gname(unsigned n) { return n * scale; }

std::deque<ccv::ooe::RatMap> fifo;       // the adapter's queue
bool exp_v = false;                  // the queue sent a map last cycle: the valid now
ccv::ooe::RatMap exp_m;
std::vector<unsigned> park_due;      // warps whose parked entry is written by now
std::vector<unsigned> park_next;
std::vector<bool> written(NW, false);
int read_warp = -1;                  // a restore-allocate's read: its warp next cycle
unsigned read_pos[NG], read_w[NG];

void clearInputs() {
  dut->mq_cq02h = 0;
  dut->rq_cq02h = 0;
  dut->prl_cq00h = 0;
  dut->ctl_rfirst = control == "restore-first";
}

void checkParked(const Core &c, unsigned w) {
  dut->dbg_w = w;
  dut->eval();
  ++parked_checks;
  for (unsigned a = 0; a != NG; ++a) {
    const unsigned pos = getField(dut->dbg_pk, a * (PB + WB), PB), wd = getField(dut->dbg_pk, a * (PB + WB) + PB, WB);
    const unsigned mp = scale == 1 ? c.parkedPos(w, a) : 0;
    if (pos != mp) fail("parked position", w, a, pos, mp);
    if (wd != c.parkedWidth(w, a)) fail("parked width", w, a, wd, c.parkedWidth(w, a));
  }
}

void hook(const Core &c) {
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    const auto &cfg = c.config();
    skip = c.slots() != S;
    scale = cfg.sectioned ? 1 : 4;
    clearInputs();
    dut->ooe_rst_r00h = 1;
    tick();
    tick();
    dut->ooe_rst_r00h = 0;
    fifo.clear();
    exp_v = false;
    park_due.clear();
    park_next.clear();
    written.assign(NW, false);
    read_warp = -1;
  }
  if (skip) { ++skipped; return; }
  ++cycles;
  const Core::SlotLog &sl = c.slotLog();
  clearInputs();
  // This cycle's map requests, in the model's order.
  unsigned dq = 0, rq = 0;
  for (const ccv::ooe::RatMap &m : c.out.maps) {
    const int si = c.slotOfWarp(m.warp);
    if (si < 0 || unsigned(si) >= S) { fail("map of a warp with no slot", m.warp, m.direction, 0, 0); continue; }
    unsigned t = unsigned(si);
    if (m.direction == 0 && control == "wrong-slot") t = (t + 1) % S;
    setBit(m.direction ? dut->rq_cq02h : dut->mq_cq02h, t, true);
    (m.direction ? rq : dq) |= 1u << t;
    for (unsigned a = 0; a != NG; ++a) narrow += m.w[a] != 0, posd += (gname(m.gpr[a]) & 3) != 0;
    fifo.push_back(m);
    ++maps;
    ++(m.direction ? restores : demotes);
  }
  if (dq && rq) ++together;
  // Each slot's warp, committed maps and widths, as they stand.
  for (unsigned t = 0; t != S; ++t) {
    setField(dut->sw_cq02h, t * LW, LW, sl.warp[t] % NW);
    for (unsigned a = 0; a != NG; ++a) {
      setField(dut->crat_cq02h, t * MW + a * GW, GW, gname(c.cratGpr(t, a)));
      const unsigned src = control == "cw-shift" ? (t + 1) % S : t;
      setField(dut->cw_cq02h, (t * NG + a) * WB, WB, c.slotWidth(src, a));
    }
    for (unsigned p = 0; p != NP; ++p) setField(dut->crat_cq02h, t * MW + NG * GW + p * PW, PW, c.cratPred(t, p));
  }
  // A restore-allocate's read of the parked layout: led this cycle, its
  // warp the next.
  dut->prw_cq01h = read_warp >= 0 ? unsigned(read_warp) : 0;
  const int was_read = read_warp;
  unsigned rd_pos[NG], rd_w[NG];
  for (unsigned r = 0; r != NG; ++r) rd_pos[r] = read_pos[r], rd_w[r] = read_w[r];
  read_warp = -1;
  for (const Core::SlotAlloc &a : sl.alloc)
    if (a.op == ccv::ooe::kAllocRestoreAlloc && written[a.warp % NW]) {
      if (control != "no-read-lead") dut->prl_cq00h = 1;
      read_warp = int(a.warp % NW);
      for (unsigned r = 0; r != NG; ++r) {
        read_pos[r] = scale == 1 ? c.parkedPos(a.warp, r) : 0;
        read_w[r] = c.parkedWidth(a.warp, r);
      }
    }
  // The queue sends its oldest.
  const bool send = !fifo.empty();
  ccv::ooe::RatMap sent;
  if (send) { sent = fifo.front(); fifo.pop_front(); }
  queued += fifo.size();
  tick();
  // The valid of the pick made at this edge, and the payload of the last.
  if (bool(dut->map_v_cq03h) != send) fail("map valid", send, 0, dut->map_v_cq03h, send);
  if (exp_v) {
    const ccv::ooe::RatMap &m = exp_m;
    if (dut->map_warp_cq04h != m.warp % NW) fail("map warp", m.warp, 0, dut->map_warp_cq04h, m.warp);
    if (dut->map_dir_cq04h != m.direction) fail("map direction", m.warp, 0, dut->map_dir_cq04h, m.direction);
    for (unsigned a = 0; a != NG; ++a) {
      const unsigned n = gname(m.gpr[a]), row = n >> PB, zero = row == (1u << RW) - 1;
      const unsigned pos = zero ? 0 : n & ((1u << PB) - 1);
      if (getField(dut->map_gpr_cq04h, a * RW, RW) != row) fail("map row", m.warp, a, getField(dut->map_gpr_cq04h, a * RW, RW), row);
      if (getField(dut->map_pos_cq04h, a * PB, PB) != pos) fail("map position", m.warp, a, getField(dut->map_pos_cq04h, a * PB, PB), pos);
      if (getField(dut->map_w_cq04h, a * WB, WB) != m.w[a]) fail("map width", m.warp, a, getField(dut->map_w_cq04h, a * WB, WB), m.w[a]);
    }
    for (unsigned p = 0; p != NP; ++p)
      if (getField(dut->map_pred_cq04h, p * PW, PW) != m.pred[p])
        fail("map predicate", m.warp, p, getField(dut->map_pred_cq04h, p * PW, PW), m.pred[p]);
    if (m.direction == 0) park_next.push_back(m.warp % NW);
  }
  // A demotion's parked write lands at the edge after its payload's.
  for (unsigned w : park_due) { checkParked(c, w); written[w] = true; }
  park_due.swap(park_next);
  park_next.clear();
  // A read led last cycle, its warp this cycle: its result after this edge.
  if (was_read >= 0) {
    ++reads;
    for (unsigned r = 0; r != NG; ++r) {
      const unsigned pos = getField(dut->pk_pos_cq02h, r * PB, PB), wd = getField(dut->pk_w_cq02h, r * WB, WB);
      if (pos != rd_pos[r]) fail("parked read position", unsigned(was_read), r, pos, rd_pos[r]);
      if (wd != rd_w[r]) fail("parked read width", unsigned(was_read), r, wd, rd_w[r]);
    }
  }
  exp_v = send;
  exp_m = sent;
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("RATMAP_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_ratmap>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  const int model_fails = cg.on() ? cg.run(seeds, nullptr, hook) : ooeTestScenario("ratmap", seeds, 0, nullptr, hook, nullptr);
  cg.close();
  dut->final();
  std::printf("ratmap_tb control=%s seeds=%u cores=%llu cycles=%llu skipped=%llu maps=%llu demotes=%llu "
              "restores=%llu queued=%llu together=%llu parked=%llu reads=%llu narrow=%llu positioned=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, skipped, maps, demotes, restores,
              queued, together, parked_checks, reads, narrow, posd, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
