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
// Before the edge, every slot's R oldest on the RTL's outputs must be the
// model's, in order; after it, every slot's count and the pool's credit
// count must be the model's. The RTL's assertions (rename within the count,
// arrivals within credit, payload reads through busy entries) run too,
// under --assert.
//
// Negative controls (DECQ_CONTROL=<name>) perturb the driving and must be
// caught: drop-flush (a squash's flush never reaches the RTL) and
// enq-swap (a slot's two oldest arrivals in a cycle reach the ports
// youngest first).
// Usage: decq_tb [seeds]
//===----------------------------------------------------------------------===//
#include "Vooe_decq.h"
#include "verilated.h"
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

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  dut->ooe_core_clk = 1;
  dut->eval();
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

void hook(const Core &c) {
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    was.assign(S, {});
    dut->enq_v_cq01h = 0;
    dut->deq_n_cq01h = 0;
    dut->flush_cq01h = 0;
    dut->ooe_rst_r00h = 1;
    tick();
    dut->ooe_rst_r00h = 0;
  }
  ++cycles;
  // Before the edge: the RTL shows the old queues.
  dut->ooe_core_clk = 0;
  dut->eval();
  for (unsigned s = 0; s != S; ++s)
    for (unsigned k = 0; k != R; ++k) {
      const bool v = getField(dut->head_v_cq02h, s * R + k, 1);
      if (v != (k < was[s].size())) { fail("head valid differs", s, v, k < was[s].size()); continue; }
      if (!v) continue;
      ++heads;
      const unsigned got = getField(dut->head_pay_cq02h, (s * R + k) * P, P);
      if (got != (was[s][k] & 0xffffu)) fail("head payload differs", s, got, unsigned(was[s][k] & 0xffffu));
    }
  // The edge: dequeues, flushes, arrivals.
  const auto now = bySlot(c);
  const uint32_t fl = c.decqFlushed();
  uint64_t last = 0;   // the newest arrival number already queued
  for (const auto &q : was) for (uint64_t x : q) last = std::max(last, x + 1);
  std::vector<std::pair<uint64_t, unsigned>> fresh;
  dut->deq_n_cq01h = 0;
  dut->flush_cq01h = 0;
  for (unsigned s = 0; s != S; ++s) {
    size_t keep = 0;   // old uops still queued: a suffix of the old queue
    for (uint64_t x : now[s]) if (x < last) ++keep;
    for (size_t i = 0; i != keep; ++i)
      if (now[s][i] != was[s][was[s].size() - keep + i]) { fail("survivors not the old queue's tail", s, 0, 0); break; }
    for (size_t i = keep; i != now[s].size(); ++i) fresh.push_back({now[s][i], s});
    const bool flushed = (fl >> s) & 1u;
    if (flushed && keep) fail("a flushed slot kept uops", s, unsigned(keep), 0);
    const unsigned gone = unsigned(was[s].size() - keep);
    if (flushed) {
      ++flushes;
      if (control != "drop-flush") dut->flush_cq01h |= 1u << s;
    } else {
      if (gone > R) fail("rename took more than its width", s, gone, R);
      setField(dut->deq_n_cq01h, s * LR, LR, gone);
      taken += gone;
    }
  }
  std::sort(fresh.begin(), fresh.end());
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
  tick();
  // After the edge: the counts and the credits.
  unsigned total = 0;
  for (unsigned s = 0; s != S; ++s) {
    const unsigned got = getField(dut->cnt_cq02h, s * LC, LC);
    if (got != now[s].size()) fail("count differs", s, got, unsigned(now[s].size()));
    total += unsigned(now[s].size());
  }
  full += total == DQ_Q;
  if (unsigned(dut->used_cq02h) != total) fail("credits differ", 0, unsigned(dut->used_cq02h), total);
  was = now;
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("DECQ_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  dut = std::make_unique<Vooe_decq>(ctx.get());
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
