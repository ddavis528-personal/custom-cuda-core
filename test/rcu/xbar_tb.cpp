//===-- xbar_tb.cpp - rcu_xbar against the crossbar's rule -----------------===//
//
// out[l] = src[idx[l]] (R unit tab, Crossbar; the model's shfl): every lane
// index, the immediate form (every idx equal), and random indices and data.
// A wrong lane fails the run. Built and run by test/rcu/run-rtl.sh.
//===----------------------------------------------------------------------===//
#include "Vrcu_xbar.h"
#include "verilated.h"
#include <cstdint>
#include <cstdio>
#include <random>

int main(int argc, char **argv) {
  VerilatedContext ctx;
  ctx.commandArgs(argc, argv);
  Vrcu_xbar x(&ctx);
  std::mt19937 rng(0x5bf1);
  unsigned fails = 0, checks = 0;
  uint32_t src[32];
  unsigned idx[32];
  for (int t = 0; t < 2000; ++t) {
    for (unsigned l = 0; l < 32; ++l) src[l] = rng();
    for (unsigned l = 0; l < 32; ++l)
      idx[l] = t < 32 ? unsigned(t) : t < 64 ? (l ^ unsigned(t)) & 31u : rng() & 31u;
    for (unsigned l = 0; l < 32; ++l) x.src[l] = src[l];
    for (unsigned w = 0; w < 5; ++w) x.idx[w] = 0;
    for (unsigned l = 0; l < 32; ++l)
      for (unsigned b = 0; b < 5; ++b)
        if ((idx[l] >> b) & 1u) x.idx[(l * 5 + b) / 32] |= 1u << ((l * 5 + b) % 32);
    x.eval();
    for (unsigned l = 0; l < 32; ++l, ++checks)
      if (x.out[l] != src[idx[l]] && ++fails <= 10)
        std::fprintf(stderr, "xbar: test %d lane %u: %08x, not %08x (idx %u)\n", t, l, x.out[l], src[idx[l]], idx[l]);
  }
  std::printf("xbar: %u lanes checked, %u wrong: %s\n", checks, fails, fails ? "FAIL" : "PASS");
  return fails ? 1 : 0;
}
