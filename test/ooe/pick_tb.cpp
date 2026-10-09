//===-- pick_tb.cpp - ccv_ooe_pick against ooe::pickResources -----------===//
//
// The RTL's per-resource select held in lockstep with the model's: random
// RS states (valid entries with distinct ages, random readiness, random
// footprints), the same requesters into both, every output compared.
//
// Also checked on the RTL alone, every vector: issued footprints are
// disjoint (V-60), and a granted entry won each resource it requested.
//
// Invalid entries' rows of the age matrix are filled with random bits, the
// un-reset payload the RTL may hold there: no output may depend on them.
//
// Negative controls (PICK_CONTROL=<name>) perturb the REFERENCE, and the
// comparison must catch each: youngest-wins (age inverted), any-wins (an
// entry issues if it wins any resource), and no-mask (an invalid entry's
// garbage row counts). Usage: pick_tb [vectors] [seed].
//===----------------------------------------------------------------------===//
#include "Vccv_ooe_pick.h"
#include "verilated.h"
#include "ooe_core.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <random>
#include <string>
#include <vector>

#ifndef PICK_N
#error "build with -DPICK_N and -DPICK_R matching -GN and -GR"
#endif
constexpr unsigned N = PICK_N, R = PICK_R;

template <typename W> void setBit(W &w, unsigned i, bool v) {
  if constexpr (sizeof(W) <= 8) {
    if (v) w |= (W(1) << i); else w &= ~(W(1) << i);
  } else {
    if (v) w[i / 32] |= (1u << (i % 32)); else w[i / 32] &= ~(1u << (i % 32));
  }
}
template <typename W> bool getBit(const W &w, unsigned i) {
  if constexpr (sizeof(W) <= 8) return (w >> i) & 1u;
  else return (w[i / 32] >> (i % 32)) & 1u;
}

int main(int argc, char **argv) {
  const unsigned vectors = argc > 1 ? unsigned(std::atoi(argv[1])) : 200000;
  const unsigned seed = argc > 2 ? unsigned(std::atoi(argv[2])) : 1;
  const char *ctl = std::getenv("PICK_CONTROL");
  const std::string control = ctl ? ctl : "";
  std::mt19937_64 rng(seed);
  VerilatedContext ctx;
  Vccv_ooe_pick dut{&ctx};
  unsigned fails = 0, issued_total = 0, lost_total = 0, multi_total = 0;

  for (unsigned v = 0; v != vectors && fails < 10; ++v) {
    // An RS state: which entries are valid, and their ages (a permutation).
    std::vector<bool> valid(N);
    std::vector<uint64_t> age(N);
    std::vector<unsigned> perm(N);
    for (unsigned i = 0; i != N; ++i) perm[i] = i;
    std::shuffle(perm.begin(), perm.end(), rng);
    const unsigned fill = unsigned(rng() % 101);     // percent valid
    for (unsigned i = 0; i != N; ++i) {
      valid[i] = rng() % 100 < fill;
      age[i] = perm[i];
    }
    // Footprints: mostly one or two resources, sometimes all; readiness.
    std::vector<unsigned> res(N, 0);
    const unsigned ready_pct = unsigned(rng() % 101);
    for (unsigned i = 0; i != N; ++i) {
      if (!valid[i] || rng() % 100 >= ready_pct) continue;
      const unsigned shape = unsigned(rng() % 4);
      if (shape == 0) res[i] = (1u << R) - 1;
      else if (shape == 1) res[i] = 1u << (rng() % R);
      else res[i] = unsigned(rng() & ((1u << R) - 1));
      if (!res[i]) res[i] = 1u << (rng() % R);
    }
    // Drive the RTL. Invalid rows of `older` are garbage.
    for (unsigned e = 0; e != N; ++e) {
      for (unsigned k = 0; k != R; ++k) setBit(dut.req_cq03h, e * R + k, (res[e] >> k) & 1u);
      for (unsigned j = 0; j != N; ++j) {
        const bool known = valid[e] && valid[j];
        setBit(dut.older_cq03h, e * N + j, known ? age[j] < age[e] : bool(rng() & 1u));
      }
    }
    dut.eval();

    // The reference over the same requesters.
    std::vector<ccv::ooe::PickReq> req;
    std::vector<unsigned> idx;
    for (unsigned e = 0; e != N; ++e)
      if (res[e]) {
        uint64_t a = control == "youngest-wins" ? ~age[e] : age[e];
        req.push_back({res[e], a});
        idx.push_back(e);
      }
    if (control == "no-mask")
      for (unsigned e = 0; e != N; ++e)
        if (!valid[e] && rng() % 2) { req.push_back({1u, 0}); idx.push_back(N); }  // phantom oldest
    unsigned lost_ref = 0;
    std::vector<bool> won = ccv::ooe::pickResources(req, R, &lost_ref);
    std::vector<bool> want(N, false);
    for (size_t i = 0; i != req.size(); ++i) {
      bool w = won[i];
      if (control == "any-wins") {
        // An entry issues if it is the oldest requester of any one resource.
        w = false;
        for (unsigned k = 0; k != R; ++k) {
          if (!((req[i].res >> k) & 1u)) continue;
          bool oldest = true;
          for (size_t j = 0; j != req.size(); ++j)
            if (((req[j].res >> k) & 1u) && req[j].age < req[i].age) oldest = false;
          w = w || oldest;
        }
      }
      if (idx[i] < N) want[idx[i]] = w;
    }

    unsigned used = 0, lost_rtl = 0, issued = 0;
    for (unsigned e = 0; e != N; ++e) {
      const bool got = getBit(dut.issue_cq03h, e);
      lost_rtl += getBit(dut.lost_cq03h, e);
      if (got != want[e]) {
        if (++fails <= 5)
          std::fprintf(stderr, "vector %u: entry %u issue rtl=%d ref=%d (res %x, age %llu)\n", v, e,
                       got, int(want[e]), res[e], (unsigned long long)age[e]);
      }
      if (got) {
        ++issued;
        if (used & res[e]) { ++fails; std::fprintf(stderr, "vector %u: V-60, entry %u overlaps\n", v, e); }
        used |= res[e];
        for (unsigned k = 0; k != R; ++k)
          if (((res[e] >> k) & 1u) && !getBit(dut.win_cq03h, e * R + k)) {
            ++fails; std::fprintf(stderr, "vector %u: entry %u issued without winning %u\n", v, e, k);
          }
      }
    }
    if (control.empty() && lost_rtl != lost_ref) {
      ++fails; std::fprintf(stderr, "vector %u: lost rtl=%u ref=%u\n", v, lost_rtl, lost_ref);
    }
    issued_total += issued;
    lost_total += lost_rtl;
    multi_total += issued > 1;
  }
  std::printf("pick_tb N=%u R=%u control=%s vectors=%u issued=%u lost=%u multi-issue=%u fails=%u\n", N, R,
              control.empty() ? "none" : control.c_str(), vectors, issued_total, lost_total, multi_total, fails);
  return fails ? 1 : 0;
}
