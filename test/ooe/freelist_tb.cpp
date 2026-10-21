//===-- freelist_tb.cpp - ooe_freelist against the live model -----------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode) and,
// just before every core cycle, does two things with one pool of the
// model's (FreeVec, buffered form, OA's response OI-38). The RTL runs one
// edge behind the model, so that a free's lead (free_l, OA's response
// OI-58) is driven a cycle before the free:
//   1. compares the RTL's state with the model's state just after the
//      edge before last (FreeVec::lastEdge, kept a hook): free bits (the
//      entries in transit still set in the RTL's, which clears them at the
//      late edge), the buffer in order, the entries in transit at its head
//      (last cycle's allocations, which leave it at the next edge: OA's
//      response OI-52) and the count rename sees, each bank's pointer and
//      the bank order;
//   2. drives that edge's activity (FreeVec::cycleAllocs, cycleFrees: the
//      cycle's, plus those its inputs made since, kept a hook): as many
//      allocation requests as the model made, which the RTL must grant with
//      exactly the model's entries in order, and the frees as a mask; and
//      the lead of the next edge's frees. Then it ticks.
// The RTL's own assertions (every request granted, no double free, no free
// of an entry granted the same cycle, every free led) run too, under
// --assert.
//
// FL_POOL selects the pool: 0 the GPR rows (CCV_P_PHYS_REGS), 1 the
// predicates (CCV_P_PRED_REGS). Each new core resets the RTL. Every
// allocation goes through the buffer and its ports, restore-allocate's too
// (OA's response OI-41), so a cycle with more allocations than ports fails.
//
// Negative controls (FL_CONTROL=<name>) perturb the driving and must be
// caught: drop-free (frees never reach the RTL), extra-alloc (one more
// request than the model made, in a cycle that has one) and no-lead (a
// free's lead is never driven, so the free bits are not clocked for it).
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: freelist_tb [seeds] | freelist_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_freelist.h"
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
using ccv::ooe::FreeVec;

namespace {
std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_freelist> dut;
std::string control;
uint64_t current = 0;   // the serial of the core being followed
bool desync = false;     // a core whose pool size differs from the RTL's: skipped
CgRun cg;                // --cg <scenario> <vcd>: the scenario, and its VCD (cg_trace.h)
// The model's edge the RTL takes next: its state before, its allocations
// and frees (none before a core's first hook).
bool have_prev = false;
FreeVec::Edge prev_edge;
std::vector<unsigned> prev_al, prev_fr;
unsigned long long cycles = 0, allocs = 0, frees = 0, cores = 0, skipped = 0, mismatches = 0;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned W = bits(FL_N), LM = bits(FL_N / FL_K);

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

bool lead(const std::vector<unsigned> &next_fr) { return !next_fr.empty() && control != "no-lead"; }

void fail(const char *what, unsigned a, unsigned b) {
  if (++mismatches <= 5) std::fprintf(stderr, "cycle %llu: %s (rtl %u, model %u)\n", cycles, what, a, b);
}

void hook(const Core &c) {
  const FreeVec &fv = FL_POOL ? c.predFree() : c.gprFree();
  if (c.serial() != current) {
    // A new core: reset the RTL to all free, the buffer empty.
    current = c.serial();
    ++cores;
    desync = fv.capacity() != FL_N || fv.bufferCap() != FL_B || fv.banks() != FL_K;
    dut->alloc_req_cq01h = 0;
    dut->free_l_cq00h = 0;
    for (unsigned p = 0; p != FL_N; ++p) setBit(dut->free_mask_cq01h, p, false);
    // The reset is flopped before use (RST-1): the state resets at the
    // edge after the one that captures it.
    dut->ooe_rst_r00h = 1;
    tick();
    dut->ooe_rst_r00h = 0;
    tick();
    have_prev = false;
    prev_al.clear();
    prev_fr.clear();
  }
  if (desync) { ++skipped; return; }
  if (!have_prev) {
    // A core's first hook: nothing to take yet. Its frees would need a lead
    // during reset, but nothing is allocated before them.
    if (!fv.cycleFrees().empty()) fail("a free in a core's first cycle", unsigned(fv.cycleFrees().size()), 0);
    have_prev = true;
    prev_edge = fv.lastEdge();
    prev_al = fv.cycleAllocs();
    prev_fr = fv.cycleFrees();
    return;
  }
  ++cycles;
  // 1. The state after the edge before last.
  dut->ooe_core_clk = 0;
  dut->eval();
  const FreeVec::Edge &e = prev_edge;
  std::vector<bool> transit(FL_N, false);
  for (unsigned i = 0; i != e.transit && i != e.buf.size(); ++i) transit[e.buf[i]] = true;
  for (unsigned p = 0; p != FL_N; ++p)
    if (getBit(dut->free_cq02h, p) != (e.bits[p] || transit[p])) {
      fail("free bit differs", getBit(dut->free_cq02h, p), e.bits[p]);
      break;
    }
  const unsigned cnt = unsigned(dut->cnt_cq02h);
  if (cnt != e.buf.size()) fail("buffer count differs", cnt, unsigned(e.buf.size()));
  for (unsigned i = 0; i != cnt && i != e.buf.size(); ++i) {
    const unsigned got = getField(dut->buf_cq02h, i * W, W);
    if (got != e.buf[i]) { fail("buffer entry differs", got, e.buf[i]); break; }
  }
  for (unsigned b = 0; b != FL_K; ++b) {
    const unsigned got = getField(dut->bptr_cq02h, b * LM, LM);
    if (got != e.bptr[b]) fail("bank pointer differs", got, e.bptr[b]);
  }
  if (unsigned(dut->rot_cq02h) != e.rot) fail("bank order differs", unsigned(dut->rot_cq02h), e.rot);
  if (unsigned(dut->transit_cq02h) != e.transit) fail("entries in transit differ", unsigned(dut->transit_cq02h), e.transit);
  if (unsigned(dut->avail_cq02h) != e.buf.size() - e.transit)
    fail("available count differs", unsigned(dut->avail_cq02h), unsigned(e.buf.size() - e.transit));
  // 2. That edge's allocations and frees, and the next one's lead.
  const auto &al = prev_al;
  if (al.size() > FL_A) { fail("more allocations than ports", unsigned(al.size()), FL_A); desync = true; return; }
  const auto &fr = prev_fr;
  dut->free_l_cq00h = lead(fv.cycleFrees());
  unsigned req = unsigned(al.size());
  if (control == "extra-alloc" && req && req < FL_A) ++req;
  dut->alloc_req_cq01h = (1u << req) - 1u;
  for (unsigned p = 0; p != FL_N; ++p) setBit(dut->free_mask_cq01h, p, false);
  if (control != "drop-free")
    for (unsigned p : fr) setBit(dut->free_mask_cq01h, p, true);
  dut->eval();
  for (unsigned k = 0; k != al.size(); ++k) {
    const bool v = (dut->alloc_v_cq02h >> k) & 1u;
    const unsigned idx = getField(dut->alloc_idx_cq02h, k * W, W);
    if (!v) fail("a port the model allocated on was not granted", k, al[k]);
    else if (idx != al[k]) fail("granted a different entry", idx, al[k]);
  }
  allocs += al.size();
  frees += fr.size();
  tick();
  prev_edge = fv.lastEdge();
  prev_al = fv.cycleAllocs();
  prev_fr = fv.cycleFrees();
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("FL_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_freelist>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  const int model_fails = cg.run(seeds, hook, nullptr);
  cg.close();
  dut->final();
  std::printf("freelist_tb pool=%s control=%s seeds=%u cores=%llu cycles=%llu allocs=%llu frees=%llu "
              "skipped=%llu mismatches=%llu model_failures=%d\n",
              FL_POOL ? "pred" : "gpr", control.empty() ? "none" : control.c_str(), seeds, cores, cycles,
              allocs, frees, skipped, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
