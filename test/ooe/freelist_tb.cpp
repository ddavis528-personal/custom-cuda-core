//===-- freelist_tb.cpp - ooe_freelist against the live model -----------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode) and,
// just before every core cycle, does two things with one pool of the
// model's (FreeVec, buffered form, OA's response OI-38):
//   1. compares the RTL's state, which has seen one more edge than the
//      model has allocated against, with the model's state just after that
//      edge (FreeVec::lastEdge): free bits, the buffer in order, each bank's
//      pointer and the bank order;
//   2. drives one edge's activity (FreeVec::cycleAllocs, cycleFrees: the
//      last cycle's, plus those its inputs made since): as many allocation
//      requests as the model made, which the RTL must grant with exactly
//      the model's entries in order, and the frees as a mask. Then it ticks.
// The RTL's own assertions (every request granted, no double free) run too,
// under --assert.
//
// FL_POOL selects the pool: 0 the GPR rows (CCV_P_PHYS_REGS), 1 the
// predicates (CCV_P_PRED_REGS). Each new core resets the RTL. Every
// allocation goes through the buffer and its ports, restore-allocate's too
// (OA's response OI-41), so a cycle with more allocations than ports fails.
//
// Negative controls (FL_CONTROL=<name>) perturb the driving and must be
// caught: drop-free (frees never reach the RTL) and extra-alloc (one more
// request than the model made, in a cycle that has one).
// Usage: freelist_tb [seeds]
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

int ooeTestRandomPreHooked(unsigned seeds, void (*hook)(const Core &));

namespace {
std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_freelist> dut;
std::string control;
uint64_t current = 0;   // the serial of the core being followed
bool desync = false;     // a core whose pool size differs from the RTL's: skipped
CgRun cg;                // --cg <scenario> <vcd>: a clock-gating unit's bench (cg_trace.h)
// In a clock-gating run the idle cycles turn the RTL's bank order where the
// model's does not, so the two refill differently: each model entry maps to
// the entry the RTL granted in its place, and frees go through the map.
std::vector<int> rtl_of;
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

// An idle cycle: no allocation, no free.
void idleTick() {
  dut->alloc_req_cq01h = 0;
  for (unsigned p = 0; p != FL_N; ++p) setBit(dut->free_mask_cq01h, p, false);
  tick();
}

// A clock-gating run's edge: the model's allocations, as many as the RTL's
// buffer holds, and its frees of entries the RTL granted.
void cgEdge(const FreeVec &fv) {
  const auto &al = fv.cycleAllocs();
  const auto &fr = fv.cycleFrees();
  dut->ooe_core_clk = 0;
  dut->eval();
  const unsigned req = std::min<unsigned>({unsigned(al.size()), unsigned(dut->cnt_cq02h), FL_A});
  dut->alloc_req_cq01h = (1u << req) - 1u;
  for (unsigned p = 0; p != FL_N; ++p) setBit(dut->free_mask_cq01h, p, false);
  for (unsigned p : fr)
    if (rtl_of[p] >= 0) {
      setBit(dut->free_mask_cq01h, unsigned(rtl_of[p]), true);
      rtl_of[p] = -1;
    }
  dut->eval();
  for (unsigned k = 0; k != req; ++k) rtl_of[al[k]] = int(getField(dut->alloc_idx_cq02h, k * W, W));
  tick();
  for (unsigned g = 0; g != cg.gaps(); ++g) idleTick();
}

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
    for (unsigned p = 0; p != FL_N; ++p) setBit(dut->free_mask_cq01h, p, false);
    dut->ooe_rst_r00h = 1;
    tick();
    dut->ooe_rst_r00h = 0;
    rtl_of.assign(FL_N, -1);
  }
  if (desync) { ++skipped; return; }
  if (cg.on()) { cgEdge(fv); return; }
  ++cycles;
  // 1. The state after the last edge.
  dut->ooe_core_clk = 0;
  dut->eval();
  const FreeVec::Edge &e = fv.lastEdge();
  for (unsigned p = 0; p != FL_N; ++p)
    if (getBit(dut->free_cq02h, p) != bool(e.bits[p])) { fail("free bit differs", getBit(dut->free_cq02h, p), e.bits[p]); break; }
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
  // 2. This edge's allocations and frees.
  const auto &al = fv.cycleAllocs();
  if (al.size() > FL_A) { fail("more allocations than ports", unsigned(al.size()), FL_A); desync = true; return; }
  const auto &fr = fv.cycleFrees();
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
  if (cg.on()) {
    cg.open(*dut, vcd);
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
  std::printf("freelist_tb pool=%s control=%s seeds=%u cores=%llu cycles=%llu allocs=%llu frees=%llu "
              "skipped=%llu mismatches=%llu model_failures=%d\n",
              FL_POOL ? "pred" : "gpr", control.empty() ? "none" : control.c_str(), seeds, cores, cycles,
              allocs, frees, skipped, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
