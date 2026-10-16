//===-- freelist_tb.cpp - ooe_freelist against the live model -----------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode) and,
// just before every core cycle, drives ooe_freelist with one clock edge's
// activity on the model's own free list (FreeVec::cycleAllocs, cycleFrees:
// the last cycle's, plus those its inputs made since): as many allocation
// requests as the model made, and the frees as a mask. The RTL must grant
// exactly the model's entries, in order, and after the clock edge hold the
// same free set and pointer the model is about to start the cycle with. The RTL's own assertions (every request granted, no
// double free) run too, under --assert.
//
// FL_POOL selects the pool: 0 the GPR rows (CCV_P_PHYS_REGS), 1 the
// predicates (CCV_P_PRED_REGS). Each new core resets the RTL.
//
// Negative controls (FL_CONTROL=<name>) perturb the driving and must be
// caught: drop-free (frees never reach the RTL) and extra-alloc (one more
// request than the model made, in a cycle that has one).
// Usage: freelist_tb [seeds]
//===----------------------------------------------------------------------===//
#include "Vooe_freelist.h"
#include "verilated.h"
#include "ooe_core.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>

using ccv::ooe::Core;
using ccv::ooe::FreeVec;

int ooeTestRandomPreHooked(unsigned seeds, void (*hook)(const Core &));

namespace {
std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_freelist> dut;
std::string control;
uint64_t current = 0;   // the serial of the core being followed
bool desync = false;     // a core whose pool size differs from the RTL's: skipped
unsigned long long cycles = 0, allocs = 0, frees = 0, cores = 0, skipped = 0, mismatches = 0;
constexpr unsigned W = []() { unsigned w = 0; while ((1u << w) < FL_N) ++w; return w; }();

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
  dut->ooe_core_clk = 1;
  dut->eval();
}

void fail(const char *what, unsigned a, unsigned b) {
  if (++mismatches <= 5) std::fprintf(stderr, "cycle %llu: %s (rtl %u, model %u)\n", cycles, what, a, b);
}

void hook(const Core &c) {
  const FreeVec &fv = FL_POOL ? c.predFree() : c.gprFree();
  if (c.serial() != current) {
    // A new core: reset the RTL to all free, pointer 0.
    current = c.serial();
    ++cores;
    desync = fv.capacity() != FL_N;
    dut->alloc_req_cq01h = 0;
    for (unsigned p = 0; p != FL_N; ++p) setBit(dut->free_mask_cq01h, p, false);
    dut->ooe_rst_r00h = 1;
    tick();
    dut->ooe_rst_r00h = 0;
  }
  if (desync) { ++skipped; return; }
  ++cycles;
  const auto &al = fv.cycleAllocs();
  if (al.size() > FL_A) { ++skipped; desync = true; return; }   // beyond the ports: stop comparing this core
  const auto &fr = fv.cycleFrees();
  unsigned req = unsigned(al.size());
  if (control == "extra-alloc" && req && req < FL_A) ++req;
  dut->alloc_req_cq01h = (1u << req) - 1u;
  for (unsigned p = 0; p != FL_N; ++p) setBit(dut->free_mask_cq01h, p, false);
  if (control != "drop-free")
    for (unsigned p : fr) setBit(dut->free_mask_cq01h, p, true);
  dut->ooe_core_clk = 0;
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
  // After the edge: the free set and pointer the model starts the next cycle with.
  for (unsigned p = 0; p != FL_N; ++p)
    if (getBit(dut->free_cq02h, p) != fv.has(p)) { fail("free bit differs", getBit(dut->free_cq02h, p), fv.has(p)); break; }
  if (unsigned(dut->ptr_cq02h) != fv.pointer()) fail("pointer differs", unsigned(dut->ptr_cq02h), fv.pointer());
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("FL_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  dut = std::make_unique<Vooe_freelist>(ctx.get());
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
