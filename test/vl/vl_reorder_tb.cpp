// tools/check-vl-reorder.sh: the frozen decode queue in both flop forms,
// driven with the same random, legal stimulus (no dequeue past a slot's
// count, no arrival past the free entries, flushes and resets now and then),
// every output compared before every edge. Any difference fails.
// VL_CONTROL=plant feeds the if/else copy one wrong payload: it must be
// caught, or the comparison is not looking.
#include "Vvl_reorder_top.h"
#include "verilated.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <random>
#include <string>

namespace {
constexpr unsigned S = 4, Q = 12, E = 6, R = 4, P = 16, LS = 2, LC = 4, LR = 3;

template <typename T> void setField(T &w, unsigned lsb, unsigned n, unsigned v) {
  for (unsigned b = 0; b != n; ++b) {
    const unsigned i = lsb + b;
    const bool x = (v >> b) & 1u;
    if constexpr (sizeof(T) <= 8) w = x ? (w | (T(1) << i)) : (w & ~(T(1) << i));
    else w[i / 32] = x ? (w[i / 32] | (1u << (i % 32))) : (w[i / 32] & ~(1u << (i % 32)));
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
template <typename T> bool same(const T &a, const T &b) { return std::memcmp(&a, &b, sizeof(T)) == 0; }
} // namespace

int main(int argc, char **argv) {
  const unsigned long cycles = argc > 1 ? std::strtoul(argv[1], nullptr, 10) : 200000;
  const std::string control = std::getenv("VL_CONTROL") ? std::getenv("VL_CONTROL") : "";
  auto ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  auto m = std::make_unique<Vvl_reorder_top>(ctx.get());
  std::mt19937 rng(20261016);
  auto pick = [&](unsigned n) { return unsigned(rng() % n); };
  unsigned long diffs = 0, arrivals = 0, resets = 0, flushes = 0;
  auto tick = [&] { m->clk = 0; m->eval(); m->clk = 1; m->eval(); };
  m->rst = 1;
  tick();
  tick();
  for (unsigned long t = 0; t != cycles; ++t) {
    m->clk = 0;
    m->eval();
    const bool differ = !same(m->a_cnt, m->b_cnt) || !same(m->a_hv, m->b_hv) ||
                        !same(m->a_hp, m->b_hp) || !same(m->a_used, m->b_used);
    if (differ && ++diffs <= 3)
      std::fprintf(stderr, "cycle %lu: the two forms differ (used %u vs %u, slot 0 count %u vs %u)\n", t,
                   unsigned(m->a_used), unsigned(m->b_used), getField(m->a_cnt, 0, LC), getField(m->b_cnt, 0, LC));
    m->rst = pick(400) == 0;
    resets += m->rst;
    m->enq_v = 0;
    m->deq_n = 0;
    m->flush = 0;
    if (!m->rst) {
      for (unsigned s = 0; s != S; ++s) {
        if (pick(40) == 0) { m->flush |= 1u << s; ++flushes; continue; }
        const unsigned cnt = getField(m->a_cnt, s * LC, LC);
        setField(m->deq_n, s * LR, LR, pick(std::min(cnt, R) + 1));
      }
      // Arrivals take only entries idle before this edge.
      unsigned room = Q - unsigned(m->a_used);
      for (unsigned k = 0; k != E && room; ++k)
        if (pick(3)) {
          m->enq_v |= 1u << k;
          --room;
          ++arrivals;
          setField(m->enq_slot, k * LS, LS, pick(S));
          setField(m->enq_pay, k * P, P, pick(1u << P));
        }
    }
    std::memcpy(&m->b_enq_pay, &m->enq_pay, sizeof(m->enq_pay));
    if (control == "plant" && t == cycles / 2 && m->enq_v) {
      const unsigned k = unsigned(__builtin_ctz(m->enq_v));
      setField(m->b_enq_pay, k * P, P, getField(m->enq_pay, k * P, P) ^ 1u);
    }
    m->clk = 1;
    m->eval();
  }
  m->final();
  std::printf("vl_reorder control=%s cycles=%lu arrivals=%lu flushes=%lu resets=%lu differences=%lu\n",
              control.empty() ? "none" : control.c_str(), cycles, arrivals, flushes, resets, diffs);
  return diffs ? 1 : 0;
}
