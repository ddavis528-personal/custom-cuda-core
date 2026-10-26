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
// Each allocation's owner is the model's, given with the allocation
// (own_slot, as rename gives it; a port nothing takes gets a random slot,
// which the entry's next allocation overwrites); after each edge the
// frees counted by owner and group (fs) must be the bench's count of the
// frees driven, by the owners it gave, and each slot's total the model's
// (Core::slotFrees).
// The RTL's own assertions (every request granted, no double free, no free
// of an entry granted the same cycle, every free led) run too, under
// --assert.
//
// FL_NS 4 (the GPR rows' sections, OI-81) runs the model with sectioned
// registers and its narrow allocator in the RTL's form (cand 2, cand_lag
// 2, cand_return, cand_indep, ret_late, cand_home), and drives the section side
// instead of the free mask: the cycle's section frees (free_sec, under the
// free lead), Rename 2's section allocations a cycle after their grants
// (sa, under its lead) and its returned rows (rt). Before each edge it
// compares the candidates (valid and row, each slot's two) with those
// the model's group started from a cycle later, and the section bits,
// less the allocations driven two edges before (the RTL registers them
// first), with the bits they were found on (Core::candidate,
// candSections). Its controls: drop-sec-free (no section
// free reaches the RTL) and sa-early (Rename 2's allocations driven at
// their grants' step, a cycle early).
//
// FL_POOL selects the pool: 0 the GPR rows (CCV_P_PHYS_REGS), 1 the
// predicates (CCV_P_PRED_REGS). Each new core resets the RTL. Every
// allocation goes through the buffer and its ports, restore-allocate's too
// (OA's response OI-41), so a cycle with more allocations than ports fails.
//
// Negative controls (FL_CONTROL=<name>) perturb the driving and must be
// caught: drop-free (frees never reach the RTL), extra-alloc (one more
// request than the model made, in a cycle that has one), no-lead (a
// free's lead is never driven, so the free bits are not clocked for it)
// and wrong-owner (each entry is given the next slot as its owner).
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: freelist_tb [seeds] | freelist_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_freelist.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <algorithm>
#include <array>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <memory>
#include <random>
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
std::vector<int> prev_own;              // the owners of prev_al
std::mt19937 owner_rng(5);              // a port nothing takes: its slot
std::vector<int> owner_of;              // each entry's owner, as the bench gave it
std::vector<unsigned> prev_sf;          // each slot's frees in prev_fr, the model's
std::vector<unsigned> pend_tot;         // each slot's frees a step ago, due at fsp_cq03h
unsigned long long cycles = 0, allocs = 0, frees = 0, cores = 0, skipped = 0, mismatches = 0;
#ifndef FL_NS
#define FL_NS 0
#endif
constexpr unsigned NK = FL_NS ? 2 : 1;   // each slot's home candidates (cand_home)
// The model's kind of slot s's home candidate k: one section at s, the pair at 2(s % 2).
constexpr unsigned homeKind(unsigned s, unsigned k) { return k == 0 ? s % 4 : 4 + s % 2; }
// FL_NS: the section events, as recorded at each hook, and the model's
// candidates and their section bits, one hook back.
std::vector<Core::SecEvent> prev_sa, prev2_sa, prev_sfr;
std::vector<unsigned> prev_rt;
std::vector<std::array<unsigned, 6>> prev_cand, prev2_cand;
std::vector<uint8_t> prev_csec, prev2_csec;
std::vector<Core::SecEvent> driven_sa, driven_sa2;   // the allocations driven at the last edge, and the one before
unsigned long long sec_allocs = 0, sec_frees = 0, returns = 0, cands = 0;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned W = bits(FL_N), LM = bits(FL_N / FL_K), LS = FL_S > 1 ? bits(FL_S) : 1,
                   LT = bits(FL_N + 1);

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

template <typename T> void setField(T &w, unsigned lsb, unsigned n, unsigned v) {
  for (unsigned b = 0; b != n; ++b) setBit(w, lsb + b, (v >> b) & 1u);
}

bool lead(const std::vector<unsigned> &next_fr) { return !next_fr.empty() && control != "no-lead"; }

// The cycle's allocations' owners and each slot's frees, as the model has them now.
void record(const Core &c, const FreeVec &fv) {
  prev_al = fv.cycleAllocs();
  prev_fr = fv.cycleFrees();
  prev_own.clear();
  for (unsigned p : prev_al) prev_own.push_back(FL_POOL ? c.predOwner(p) : c.gprRowOwner(p));
  prev_sf.assign(FL_S, 0);
  for (unsigned s = 0; s != FL_S && s != c.slots(); ++s) prev_sf[s] = c.slotFrees(s, FL_POOL);
  if (FL_NS) {
    prev2_sa = prev_sa;
    prev_sa = c.cycleSecAllocs();
    prev_sfr = c.cycleSecFrees();
    prev_rt = c.cycleReturns();
    prev2_cand = prev_cand;
    prev2_csec = prev_csec;
    prev_cand.assign(FL_S, {});
    for (unsigned s = 0; s != FL_S; ++s)
      for (unsigned k = 0; k != 6; ++k) prev_cand[s][k] = c.candidate(s, k);
    prev_csec = c.candSections();
  }
}

std::map<std::string, unsigned> fail_kinds;
void fail(const char *what, unsigned a, unsigned b) {
  ++fail_kinds[what];
  if (++mismatches <= 5 || (std::getenv("FL_DEBUG") && mismatches <= 40)) std::fprintf(stderr, "cycle %llu: %s (rtl %u, model %u)\n", cycles, what, a, b);
}

void hook(const Core &c) {
  const FreeVec &fv = FL_POOL ? c.predFree() : c.gprFree();
  if (c.serial() != current) {
    // A new core: reset the RTL to all free, the buffer empty.
    current = c.serial();
    ++cores;
    desync = fv.capacity() != FL_N || fv.bufferCap() != FL_B || fv.banks() != FL_K || c.slots() > FL_S;
    // FL_NS: a core in the RTL's allocator form only.
    if (FL_NS && (!c.config().sectioned || c.config().cand != 2 || !c.config().cand_return || c.config().cand_lag != 2 ||
                  !c.config().ret_late || !c.config().cand_home))
      desync = true;
    dut->alloc_req_cq01h = 0;
    dut->free_l_cq00h = 0;
    for (unsigned k = 0; k != FL_A * LS; ++k) setBit(dut->own_slot_cq01h, k, false);
    owner_of.assign(FL_N, -1);
    for (unsigned p = 0; p != FL_N; ++p) setBit(dut->free_mask_cq01h, p, false);
    if (FL_NS) {
      for (unsigned b = 0; b != FL_N * FL_NS; ++b) setBit(dut->free_sec_cq01h, b, false);
      dut->sa_l_cq00h = 0;
      dut->rt_l_cq00h = 0;
      dut->sa_v_cq01h = 0;
      dut->rt_v_cq01h = 0;
      prev_sa.clear();
      prev2_sa.clear();
      prev_sfr.clear();
      prev_rt.clear();
      prev_cand.clear();
      prev_csec.clear();
      prev2_cand.clear();
      prev2_csec.clear();
      driven_sa.clear();
      driven_sa2.clear();
    }
    // The reset is flopped before use (RST-1): the state resets at the
    // edge after the one that captures it, and again at the next, the first
    // driven: the model's first clock, which refills nothing (FreeVec).
    dut->ooe_rst_r00h = 1;
    tick();
    tick();
    dut->ooe_rst_r00h = 0;
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
    record(c, fv);
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
  // FL_NS: the candidates this step's Rename 2 sees, and the bits found on.
  if (FL_NS && !prev2_cand.empty()) {
    for (unsigned s = 0; s != FL_S; ++s)
      for (unsigned k = 0; k != NK; ++k) {
        const unsigned i = s * NK + k;
        const bool v = getBit(dut->cand_v_cq02h, i);
        const unsigned row = getField(dut->cand_row_cq02h, i * W, W), m = prev2_cand[s][homeKind(s, k)];
        const bool mv = m != Core::kNoRow;
        ++cands;
        if (v != mv) fail("a candidate's valid differs", v, mv);
        else if (v && row != m) fail("a candidate's row differs", row, m);
      }
    std::vector<unsigned> sa_bits(FL_N, 0);
    for (const auto &a : driven_sa2) sa_bits[a.row] |= a.sec;
    for (unsigned r = 0; r != FL_N && r != prev2_csec.size(); ++r) {
      const unsigned got = getField(dut->sec_cq02h, r * FL_NS, FL_NS) & ~sa_bits[r];
      if (got != prev2_csec[r]) { fail("a row's sections differ", got, prev2_csec[r]); break; }
    }
  }
  // 2. That edge's allocations and frees, and the next one's lead.
  const auto &al = prev_al;
  if (al.size() > FL_A) { fail("more allocations than ports", unsigned(al.size()), FL_A); desync = true; return; }
  const auto &fr = prev_fr;
  dut->free_l_cq00h = FL_NS ? !c.cycleSecFrees().empty() && control != "no-lead" : lead(fv.cycleFrees());
  unsigned req = unsigned(al.size());
  if (control == "extra-alloc" && req && req < FL_A) ++req;
  dut->alloc_req_cq01h = (1u << req) - 1u;
  for (unsigned p = 0; p != FL_N; ++p) setBit(dut->free_mask_cq01h, p, false);
  if (control != "drop-free" && !FL_NS)
    for (unsigned p : fr) setBit(dut->free_mask_cq01h, p, true);
  if (FL_NS) {
    // The section side: this step's section frees, Rename 2's allocations
    // of the step before's grants, its returns, and the next step's lead.
    for (unsigned b = 0; b != FL_N * FL_NS; ++b) setBit(dut->free_sec_cq01h, b, false);
    if (std::getenv("FL_DEBUG") && cycles >= 28 && cycles <= 32) {
      std::fprintf(stderr, "step %llu: fr", cycles);
      for (unsigned p : fr) std::fprintf(stderr, " %u", p);
      std::fprintf(stderr, " | sfree");
      for (const auto &f : prev_sfr) std::fprintf(stderr, " %u:%x(rtl sec %x)", f.row, f.sec, getField(dut->sec_cq02h, f.row * FL_NS, FL_NS));
      std::fprintf(stderr, " | sa");
      for (const auto &a : prev2_sa) std::fprintf(stderr, " %u:%x", a.row, a.sec);
      std::fprintf(stderr, " | rt");
      for (unsigned r : prev_rt) std::fprintf(stderr, " %u", r);
      std::fprintf(stderr, " | al");
      for (unsigned r : al) std::fprintf(stderr, " %u", r);
      std::fprintf(stderr, "\n");
    }
    if (control != "drop-sec-free")
      for (const auto &f : prev_sfr)
        for (unsigned j = 0; j != FL_NS; ++j)
          if ((f.sec >> j) & 1u) setBit(dut->free_sec_cq01h, f.row * FL_NS + j, true);
    const auto &sa = control == "sa-early" ? prev_sa : prev2_sa;
    if (sa.size() > FL_A || prev_rt.size() > FL_A) {
      fail("more section allocations or returns than lanes", unsigned(prev2_sa.size()), FL_A);
      desync = true;
      return;
    }
    dut->sa_v_cq01h = 0;
    dut->rt_v_cq01h = 0;
    for (unsigned k = 0; k != sa.size(); ++k) {
      dut->sa_v_cq01h |= 1u << k;
      setField(dut->sa_row_cq01h, k * W, W, sa[k].row);
      setField(dut->sa_sec_cq01h, k * FL_NS, FL_NS, sa[k].sec);
    }
    for (unsigned k = 0; k != prev_rt.size(); ++k) {
      dut->rt_v_cq01h |= 1u << k;
      setField(dut->rt_row_cq01h, k * W, W, prev_rt[k]);
    }
    // The lead: the next step's allocations (this hook's prev_sa) or returns.
    // Each lane's lead: the next step's allocation or return on it.
    const auto &nsa = control == "sa-early" ? c.cycleSecAllocs() : prev_sa;
    auto lanes = [](size_t n) { return n ? (1u << std::min<size_t>(n, FL_A)) - 1u : 0u; };
    dut->sa_l_cq00h = lanes(nsa.size());
    dut->rt_l_cq00h = lanes(c.cycleReturns().size());
    driven_sa2 = driven_sa;
    driven_sa = sa;
    sec_allocs += sa.size();
    sec_frees += prev_sfr.size();
    returns += prev_rt.size();
  }
  // Each port's owner: its allocation's, a random slot where none.
  for (unsigned k = 0; k != FL_A; ++k) {
    int o = k < prev_own.size() ? prev_own[k] : int(owner_rng() % FL_S);
    if (o < 0) { fail("an allocation the model owns to no slot", k, 0); o = 0; }
    if (control == "wrong-owner" && k < prev_own.size()) o = (o + 1) % FL_S;
    setField(dut->own_slot_cq01h, k * LS, LS, unsigned(o));
  }
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
  // Last step's frees, a cycle on through the second stage: each slot's
  // pair, which must sum to them exactly (no carry dropped).
  for (unsigned s = 0; s != pend_tot.size(); ++s) {
    const unsigned lo = getField(dut->fsp_cq03h, (2 * s) * LT, LT), hi = getField(dut->fsp_cq03h, (2 * s + 1) * LT, LT);
    if (lo + hi != pend_tot[s]) fail("a slot's frees pair differs", lo + hi, pend_tot[s]);
  }
  pend_tot.clear();
  // The frees just driven, by owner, and each slot's total.
  if (control != "drop-free") {
    std::vector<unsigned> tot(FL_S, 0);
    for (unsigned p : fr)
      if (p < owner_of.size() && owner_of[p] >= 0) ++tot[unsigned(owner_of[p])];
      else fail("a free of an entry the bench gave no owner", p, 0);
    for (unsigned s = 0; s != FL_S; ++s)
      if (tot[s] != prev_sf[s]) fail("a slot's frees differ from the model's", tot[s], prev_sf[s]);
    pend_tot = tot;
  }
  for (unsigned p : fr) owner_of[p] = -1;
  for (unsigned k = 0; k != al.size(); ++k) owner_of[al[k]] = prev_own[k];
  prev_edge = fv.lastEdge();
  record(c, fv);
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
  const int model_fails = FL_NS ? cg.run(seeds, hook, nullptr, [](ccv::ooe::Config &k) {
    k.sectioned = true;
    k.cand = 2;
    k.cand_return = true;
    k.cand_indep = true;
    k.cand_lag = 2;
    k.ret_late = true;
    k.cand_home = true;
  }) : cg.run(seeds, hook, nullptr);
  cg.close();
  dut->final();
  std::printf("freelist_tb pool=%s%s control=%s seeds=%u cores=%llu cycles=%llu allocs=%llu frees=%llu "
              "sec_allocs=%llu sec_frees=%llu returns=%llu candidates=%llu skipped=%llu mismatches=%llu model_failures=%d\n",
              FL_POOL ? "pred" : "gpr", FL_NS ? "-sections" : "", control.empty() ? "none" : control.c_str(), seeds,
              cores, cycles, allocs, frees, sec_allocs, sec_frees, returns, cands, skipped, mismatches, model_fails);
  for (const auto &kv : fail_kinds) std::printf("  %u x %s\n", kv.second, kv.first.c_str());
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
