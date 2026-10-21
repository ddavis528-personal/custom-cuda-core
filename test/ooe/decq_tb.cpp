//===-- decq_tb.cpp - ooe_decq against the live model ----------------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode) and,
// just before every core cycle, takes a snapshot of the model's decode queue
// (Core::decodeQueue: each uop's slot and arrival number) and the slots a
// squash flushed in the cycle just run (Core::decqFlushed). Between two
// snapshots, per slot: the uops gone from the front of its old queue are
// rename's dequeues (unless a squash flushed the slot), and the uops new to
// the queue are the arrivals, which go to ooe_decq's ports in arrival
// order. The payload is the arrival number's low bits.
//
// The RTL runs one snapshot behind, so that the arrival lead (DEC's channel
// valid, OA's response OI-58) goes a tick before its uops. A flush is
// registered and applied an edge late: meanwhile the slot still shows its
// old uops (rename takes none: its rule), and they hold their credits.
//
// Before the edge, every slot's R oldest on the RTL's outputs must be the
// model's, in order; after it, every slot's count and the pool's credit
// count must be the model's (a slot flushed at that edge still showing its
// old uops and holding their credits). The RTL's assertions (rename within the count,
// arrivals within credit, payload reads through busy entries) run too,
// under --assert.
//
// Negative controls (DECQ_CONTROL=<name>) perturb the driving and must be
// caught: drop-flush (a squash's flush never reaches the RTL), enq-swap (a
// slot's two oldest arrivals in a cycle reach the ports youngest first),
// no-enq-lead (the arrival lead never reaches it) and no-take-enable
// (rename's "some warp takes" bit never reaches the take register).
//
// Rename's take is registered and popped at the next edge (OA-21): the
// outputs read past it at once, and its entries hold their credits that
// edge longer, as the model's decq_take_late holds them.
// Usage: decq_tb [seeds]
//===----------------------------------------------------------------------===//
#include "Vooe_decq.h"
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

int ooeTestRandomPreHooked(unsigned seeds, void (*hook)(const Core &));

namespace {
constexpr unsigned S = DQ_S, E = DQ_E, R = DQ_R, P = 16;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned LS = bits(S), LC = bits(DQ_D + 1), LR = bits(R + 1);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_decq> dut;
std::string control;
uint64_t current = 0;    // the serial of the core being followed
std::vector<std::vector<uint64_t>> was;   // each slot's queue, oldest first
// An edge as the model made it: the queues before and after, the flushes.
struct Edge {
  std::vector<std::vector<uint64_t>> was, now;
  uint32_t fl = 0;
};
Edge pend;                                // the edge the RTL takes next
std::vector<std::vector<uint64_t>> held_q; // each slot's uops a flush at the last edge still shows
bool have_pend = false;
unsigned long long cycles = 0, arrivals = 0, taken = 0, flushes = 0, heads = 0, full = 0, cores = 0, mismatches = 0;

template <typename T> void setField(T &w, unsigned lsb, unsigned n, uint64_t v) {
  for (unsigned b = 0; b != n; ++b) {
    const unsigned i = lsb + b;
    const bool x = (v >> b) & 1u;
    if constexpr (sizeof(T) <= 8) {
      if (x) w |= (T(1) << i); else w &= ~(T(1) << i);
    } else {
      if (x) w[i / 32] |= (1u << (i % 32)); else w[i / 32] &= ~(1u << (i % 32));
    }
  }
}
template <typename T> unsigned getField(const T &w, unsigned lsb, unsigned n) {
  unsigned v = 0;
  for (unsigned b = 0; b != n; ++b) {
    const unsigned i = lsb + b;
    bool x;
    if constexpr (sizeof(T) <= 8) x = (w >> i) & 1u;
    else x = (w[i / 32] >> (i % 32)) & 1u;
    v |= unsigned(x) << b;
  }
  return v;
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

// An idle cycle: nothing arrives, nothing is taken or flushed. The last
// one before an edge with arrivals carries their lead.
void idleTick(bool lead = false) {
  dut->enq_v_cq01h = 0;
  dut->deq_n_cq01h = 0;
  dut->deq_any_cq01h = 0;
  dut->flush_cq01h = 0;
  dut->enq_l_cq00h = lead && control != "no-enq-lead";
  tick();
}

void fail(const char *what, unsigned slot, unsigned rtl, unsigned model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "cycle %llu slot %u: %s (rtl %u, model %u)\n", cycles, slot, what, rtl, model);
}

std::vector<std::vector<uint64_t>> bySlot(const Core &c) {
  std::vector<std::vector<uint64_t>> q(S);
  for (const auto &u : c.decodeQueue()) {
    if (u.slot >= S) { fail("a queued uop with no slot", u.slot, 0, 0); continue; }
    q[u.slot].push_back(u.seq);
  }
  return q;
}

// The uops new to the queues at an edge: arrivals, oldest first.
std::vector<std::pair<uint64_t, unsigned>> freshOf(const Edge &e) {
  uint64_t last = 0;   // the newest arrival number already queued
  for (const auto &q : e.was) for (uint64_t x : q) last = std::max(last, x + 1);
  std::vector<std::pair<uint64_t, unsigned>> fresh;
  for (unsigned s = 0; s != S; ++s)
    for (uint64_t x : e.now[s]) if (x >= last) fresh.push_back({x, s});
  std::sort(fresh.begin(), fresh.end());
  return fresh;
}

void drive(const Edge &e, bool lead) {
  ++cycles;
  // Before the edge: the RTL shows the old queues.
  dut->ooe_core_clk = 0;
  dut->eval();
  for (unsigned s = 0; s != S; ++s)
    for (unsigned k = 0; k != R; ++k) {
      const bool v = getField(dut->head_v_cq02h, s * R + k, 1);
      const auto &q = held_q[s].empty() ? e.was[s] : held_q[s];
      if (v != (k < q.size())) { fail("head valid differs", s, v, k < q.size()); continue; }
      if (!v) continue;
      ++heads;
      const unsigned got = getField(dut->head_pay_cq02h, (s * R + k) * P, P);
      if (got != (q[k] & 0xffffu)) fail("head payload differs", s, got, unsigned(q[k] & 0xffffu));
    }
  // The edge: dequeues, flushes, arrivals.
  uint64_t last = 0;
  for (const auto &q : e.was) for (uint64_t x : q) last = std::max(last, x + 1);
  dut->deq_n_cq01h = 0;
  dut->flush_cq01h = 0;
  unsigned held = 0;   // a flushed slot's entries, held until the flush applies
  unsigned in_transit = 0;   // the take registered at this edge, popped at the next
  for (unsigned s = 0; s != S; ++s) {
    size_t keep = 0;   // old uops still queued: a suffix of the old queue
    for (uint64_t x : e.now[s]) if (x < last) ++keep;
    for (size_t i = 0; i != keep; ++i)
      if (e.now[s][i] != e.was[s][e.was[s].size() - keep + i]) { fail("survivors not the old queue's tail", s, 0, 0); break; }
    const bool flushed = (e.fl >> s) & 1u;
    if (flushed && keep) fail("a flushed slot kept uops", s, unsigned(keep), 0);
    const unsigned gone = unsigned(e.was[s].size() - keep);
    if (flushed) {
      ++flushes;
      if (control != "drop-flush") { dut->flush_cq01h |= 1u << s; held += unsigned(e.was[s].size()); }
    } else {
      if (gone > R) fail("rename took more than its width", s, gone, R);
      setField(dut->deq_n_cq01h, s * LR, LR, gone);
      taken += gone;
      in_transit += gone;
    }
  }
  dut->deq_any_cq01h = in_transit != 0 && control != "no-take-enable";
  auto fresh = freshOf(e);
  if (fresh.size() > E) { fail("more arrivals than ports", 0, unsigned(fresh.size()), E); return; }
  if (control == "enq-swap")
    for (size_t i = 0; i + 1 < fresh.size(); ++i)
      for (size_t j = i + 1; j != fresh.size(); ++j)
        if (fresh[i].second == fresh[j].second) { std::swap(fresh[i], fresh[j]); i = fresh.size(); break; }
  dut->enq_v_cq01h = 0;
  dut->enq_slot_cq01h = 0;
  for (unsigned k = 0; k != fresh.size(); ++k) {
    dut->enq_v_cq01h |= 1u << k;
    setField(dut->enq_slot_cq01h, k * LS, LS, fresh[k].second);
    setField(dut->enq_pay_cq01h, k * P, P, fresh[k].first & 0xffffu);
  }
  arrivals += fresh.size();
  dut->enq_l_cq00h = lead && !cg.gaps() && control != "no-enq-lead";
  tick();
  // After the edge: the counts and the credits.
  unsigned total = 0;
  held_q.assign(S, {});
  for (unsigned s = 0; s != S; ++s) {
    if (((e.fl >> s) & 1u) && control != "drop-flush") held_q[s] = e.was[s];
    const unsigned want = unsigned(held_q[s].empty() ? e.now[s].size() : held_q[s].size());
    const unsigned got = getField(dut->cnt_cq02h, s * LC, LC);
    if (got != want) fail("count differs", s, got, want);
    total += unsigned(e.now[s].size());
  }
  full += total == DQ_Q;
  // The take registered at this edge holds its entries until the next
  // (the model's decq_take_late).
  if (unsigned(dut->used_cq02h) != total + held + in_transit)
    fail("credits differ", 0, unsigned(dut->used_cq02h), total + held + in_transit);
  for (unsigned g = 0; g != cg.gaps(); ++g) idleTick(lead && g + 1 == cg.gaps());
}

void hook(const Core &c) {
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    was.assign(S, {});
    held_q.assign(S, {});
    have_pend = false;
    dut->enq_v_cq01h = 0;
    dut->deq_n_cq01h = 0;
    dut->deq_any_cq01h = 0;
    dut->flush_cq01h = 0;
    dut->enq_l_cq00h = 0;
    dut->ooe_rst_r00h = 1;
    tick();
    dut->ooe_rst_r00h = 0;
    tick();
  }
  Edge e;
  e.was = was;
  e.now = bySlot(c);
  e.fl = c.decqFlushed();
  was = e.now;
  if (have_pend) drive(pend, !freshOf(e).empty());
  else if (!freshOf(e).empty()) fail("arrivals in a core's first cycle, with no lead", 0, 0, 0);
  pend = std::move(e);
  have_pend = true;
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("DECQ_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_decq>(ctx.get());
  if (cg.on()) {
    // Idle cycles change nothing, so the comparisons still hold; the run
    // passes or fails only on the bench's exit, which this mode ignores.
    cg.open(*dut, vcd);
    dut->enq_l_cq00h = 0;
    dut->ooe_rst_r00h = 1;
    for (unsigned k = 0; k != 4; ++k) idleTick();
    dut->ooe_rst_r00h = 0;
    if (cg.idle()) {
      for (unsigned k = 0; k != CgRun::kIdleCycles; ++k) idleTick();
    } else {
      ooeTestRandomPreHooked(CgRun::kSeeds, hook);
    }
    cg.close();
    dut->final();
    cg.vcd.reset();
    dut.reset();
    ctx.reset();
    return 0;
  }
  const int model_fails = ooeTestRandomPreHooked(seeds, hook);
  dut->final();
  std::printf("decq_tb control=%s seeds=%u cores=%llu cycles=%llu arrivals=%llu taken=%llu flushes=%llu "
              "heads=%llu pool-full=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, arrivals, taken, flushes, heads, full,
              mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
