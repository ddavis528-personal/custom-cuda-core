//===-- csa_tb.cpp - ccv_common_csa against arithmetic ------------------===//
//
// Drives ccv_common_csa (rtl/common/ccv_common_csa.sv) at the -G N and W
// it is built with (CSA_N, CSA_W) with random operands, and checks: sum is
// the operands' sum modulo 2^W, as is pair's two; and where the operands
// are counts summing under 2^W, pair's two sum to it exactly, as
// ooe_freelist's pair is read (no carry dropped). Corner operands (all
// ones, all zero) come one test in eight.
//
// Negative control (CSA_CONTROL=drop-op): the bench drives the last
// operand as zero but still expects it; must be caught.
// Usage: csa_tb [tests]
//===----------------------------------------------------------------------===//
#include "Vccv_common_csa.h"
#include "verilated.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <random>
#include <string>
#include <type_traits>

namespace {
constexpr unsigned N = CSA_N, W = CSA_W;
constexpr unsigned long long MASK = (1ull << W) - 1;

template <typename T> void setField(T &w, unsigned lsb, unsigned n, unsigned long long v) {
  for (unsigned i = 0; i != n; ++i) {
    const bool b = (v >> i) & 1u;
    const unsigned k = lsb + i;
    if constexpr (std::is_integral_v<T>) {
      if (b) w |= (T(1) << k); else w &= ~(T(1) << k);
    } else {
      if (b) w[k / 32] |= (1u << (k % 32)); else w[k / 32] &= ~(1u << (k % 32));
    }
  }
}
template <typename T> unsigned long long getField(const T &w, unsigned lsb, unsigned n) {
  unsigned long long v = 0;
  for (unsigned i = 0; i != n; ++i) {
    const unsigned k = lsb + i;
    bool b;
    if constexpr (std::is_integral_v<T>) b = (w >> k) & 1u;
    else b = (w[k / 32] >> (k % 32)) & 1u;
    v |= (unsigned long long)b << i;
  }
  return v;
}
} // namespace

int main(int argc, char **argv) {
  const unsigned tests = argc > 1 ? unsigned(std::atoi(argv[1])) : 200000;
  const std::string control = std::getenv("CSA_CONTROL") ? std::getenv("CSA_CONTROL") : "";
  auto ctx = std::make_unique<VerilatedContext>();
  auto d = std::make_unique<Vccv_common_csa>(ctx.get());
  std::mt19937_64 rng(1);
  unsigned long long bad = 0, exact = 0;
  for (unsigned t = 0; t != tests; ++t) {
    // A count test: operands whose sum stays under 2^W.
    const bool counts = t % 2 == 1;
    unsigned long long want = 0, room = MASK;
    for (unsigned i = 0; i != N; ++i) {
      unsigned long long v;
      if (counts) {
        v = room ? rng() % (room / (N - i) + 1) : 0;
        room -= v;
      } else if (t % 8 == 0) {
        v = (t / 8) % 2 ? MASK : 0;
      } else {
        v = rng() & MASK;
      }
      want += v;
      setField(d->op, i * W, W, control == "drop-op" && i == N - 1 ? 0 : v);
    }
    d->eval();
    const unsigned long long sum = getField(d->sum, 0, W), lo = getField(d->pair, 0, W), hi = getField(d->pair, W, W);
    bool ok = sum == (want & MASK) && ((lo + hi) & MASK) == (want & MASK);
    if (counts) {
      ok = ok && lo + hi == want;
      ++exact;
    }
    if (!ok && ++bad <= 3)
      std::fprintf(stderr, "test %u: want %llu, sum %llu, pair %llu + %llu\n", t, want, sum, lo, hi);
  }
  d->final();
  std::printf("csa_tb N=%u W=%u control=%s tests=%u exact=%llu bad=%llu\n", N, W, control.empty() ? "none" : control.c_str(),
              tests, exact, bad);
  return bad != 0;
}
