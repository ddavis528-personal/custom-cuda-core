//===-- rat_tb.cpp - ooe_rat against the live model -------------------===//
//
// Runs the model's directed unit tests (demotion, kill, restore-allocate,
// faults, squashes) and its random ones (sim/ooe/ooe_test.cpp, every mode:
// mispredicts, several warps) and, after every
// core cycle, drives ooe_rat with what reached the model's register alias
// tables in it (Core::ratLog): checkpoint restores, squashes to retirement,
// slot releases, the committed maps' writes at retirement, and rename's
// ports in rename order, a restore-allocate's writes among them.
//
// Before the edge, every rename port's reads must be the model's: three
// sources, the old destination, the guard, the old predicate destination
// and, for predicate logic, its two sources. After it, every slot's
// speculative and committed maps must be the model's, and every live
// checkpoint's contents.
//
// A register name is opaque to the RAT. The model names a GPR by row alone
// when it is not sectioned, so the bench gives those the RTL's form, the
// row at position 0; the zero register is then the same name in both.
//
// Negative controls (RAT_CONTROL=<name>) perturb the driving and must be
// caught: port-reverse (a cycle's rename ports in reverse order, so the
// in-group override reads the wrong writes), drop-restore (no checkpoint
// restore reaches the RTL), drop-retire (no retirement write does) and
// drop-squash (no squash to retirement does).
//
// With --cg <scenario> <vcd> it is ooe_rat's clock-gating bench
// (test/ooe/cg_trace.h), and compares nothing.
// Usage: rat_tb [seeds] | rat_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_rat.h"
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

int ooeTestRandomHooked(unsigned seeds, void (*hook)(const Core &));
int ooeTestDirectedHooked(void (*hook)(const Core &));

namespace {
constexpr unsigned S = RAT_S, A = RAT_A, R = RAT_R, C = RAT_C, GW = RAT_GW, PW = RAT_PW;
constexpr unsigned NG = 16, NP = 4, MW = NG * GW + NP * PW;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w ? w : 1; }
constexpr unsigned LS = bits(S), LC = bits(C);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_rat> dut;
std::string control;
CgRun cg;   // --cg <scenario> <vcd>: a clock-gating unit's bench (cg_trace.h)
uint64_t current = 0;
bool skip = false;      // a core this RTL is not built for
unsigned scale = 1;     // the model's name to the RTL's: x4 when not sectioned
unsigned long long cycles = 0, cores = 0, skipped = 0, renames = 0, restores = 0, retires = 0, squashes = 0,
                   releases = 0, ckpts = 0, rst_writes = 0, in_group = 0, mismatches = 0;

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
template <typename T> void setField(T &w, unsigned lsb, unsigned n, unsigned v) {
  for (unsigned b = 0; b != n; ++b) setBit(w, lsb + b, (v >> b) & 1u);
}
template <typename T> unsigned getField(const T &w, unsigned lsb, unsigned n) {
  unsigned v = 0;
  for (unsigned b = 0; b != n; ++b) v |= unsigned(getBit(w, lsb + b)) << b;
  return v;
}
template <typename T> void clearAll(T &w, unsigned n) { for (unsigned i = 0; i != n; ++i) setBit(w, i, false); }

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}

void clearInputs() {
  clearAll(dut->ren_v_cq01h, A);
  clearAll(dut->ret_gwe_cq01h, S * R);
  clearAll(dut->ret_pwe_cq01h, S * R);
  clearAll(dut->restore_cq01h, S);
  clearAll(dut->squash_cq01h, S);
  clearAll(dut->release_cq01h, S);
}

// An idle cycle: nothing reaches the maps; the ports' fields hold.
void idleTick() {
  clearInputs();
  tick();
}

void fail(const char *what, unsigned a, unsigned b, unsigned rtl, unsigned model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "cycle %llu: %s (%u, %u: rtl %u, model %u)\n", cycles, what, a, b, rtl, model);
}

unsigned gname(unsigned n) { return n * scale; }

void hook(const Core &c) {
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    const auto &cfg = c.config();
    skip = c.slots() != S || cfg.ckpts != C || cfg.rename_width > A || cfg.retire_per_rob > R ||
           cfg.pred_zero != (1u << PW) - 1;
    scale = cfg.sectioned ? 1 : 4;
    clearInputs();
    dut->ooe_rst_r00h = 1;
    tick();
    dut->ooe_rst_r00h = 0;
  }
  if (skip) { ++skipped; return; }
  ++cycles;
  const Core::RatLog &w = c.ratLog();
  clearInputs();
  for (const auto &r : w.restore) {
    if (control == "drop-restore") continue;
    setBit(dut->restore_cq01h, r.first, true);
    setField(dut->restore_ckpt_cq01h, r.first * LC, LC, r.second);
    ++restores;
  }
  for (unsigned s = 0; s != S; ++s) {
    if (((w.squash >> s) & 1u) && control != "drop-squash") { setBit(dut->squash_cq01h, s, true); ++squashes; }
    if ((w.release >> s) & 1u) { setBit(dut->release_cq01h, s, true); ++releases; }
  }
  std::vector<unsigned> rport(S, 0);
  for (const auto &r : w.ret) {
    if (control == "drop-retire") continue;
    const unsigned q = r.slot * R + rport[r.slot]++;
    if (rport[r.slot] > R) { fail("more retirements than ports", r.slot, 0, R + 1, R); return; }
    setBit(dut->ret_gwe_cq01h, q, r.gwe);
    setField(dut->ret_dst_cq01h, q * 4, 4, r.dst);
    setField(dut->ret_gname_cq01h, q * GW, GW, gname(r.gname));
    setBit(dut->ret_pwe_cq01h, q, r.pwe);
    setField(dut->ret_pdst_cq01h, q * 2, 2, r.pdst);
    setField(dut->ret_pname_cq01h, q * PW, PW, r.pname);
    ++retires;
  }
  if (w.ren.size() > A) { fail("more renames than ports", 0, 0, unsigned(w.ren.size()), A); return; }
  std::vector<unsigned> order(w.ren.size());
  for (unsigned k = 0; k != order.size(); ++k) order[k] = k;
  if (control == "port-reverse") std::reverse(order.begin(), order.end());
  for (unsigned k = 0; k != order.size(); ++k) {
    const auto &r = w.ren[order[k]];
    setBit(dut->ren_v_cq01h, k, true);
    setField(dut->ren_slot_cq01h, k * LS, LS, r.slot);
    setBit(dut->ren_rst_cq01h, k, r.rst);
    for (unsigned i = 0; i != 3; ++i) setField(dut->ren_src_cq01h, (k * 3 + i) * 4, 4, r.src[i]);
    setField(dut->ren_dst_cq01h, k * 4, 4, r.dst);
    setBit(dut->ren_gwe_cq01h, k, r.gwe);
    setField(dut->ren_gname_cq01h, k * GW, GW, gname(r.gname));
    setField(dut->ren_pguard_cq01h, k * 2, 2, r.pguard);
    setField(dut->ren_pdst_cq01h, k * 2, 2, r.pdst);
    setBit(dut->ren_pwe_cq01h, k, r.pwe);
    setField(dut->ren_pname_cq01h, k * PW, PW, r.pname);
    for (unsigned i = 0; i != 2; ++i) setField(dut->ren_pq_cq01h, (k * 2 + i) * 2, 2, r.pq[i]);
    setBit(dut->ren_br_cq01h, k, r.br);
    setField(dut->ren_ckpt_cq01h, k * LC, LC, r.ckpt);
    if (r.rst) ++rst_writes; else ++renames;
    ckpts += r.br && !r.rst;
    for (unsigned j = 0; j != k; ++j) in_group += !r.rst && w.ren[order[j]].slot == r.slot;
  }
  // Before the edge: every rename port's reads.
  dut->ooe_core_clk = 0;
  dut->eval();
  for (unsigned k = 0; k != order.size() && !cg.on(); ++k) {
    const auto &r = w.ren[order[k]];
    if (r.rst) continue;
    for (unsigned i = 0; i != 3; ++i) {
      const unsigned got = getField(dut->ren_psrc_cq01h, (k * 3 + i) * GW, GW);
      if (got != gname(r.psrc[i])) fail("source read differs", k, i, got, gname(r.psrc[i]));
    }
    unsigned got = getField(dut->ren_pold_cq01h, k * GW, GW);
    if (got != gname(r.pold)) fail("old destination differs", k, 0, got, gname(r.pold));
    got = getField(dut->ren_ppguard_cq01h, k * PW, PW);
    if (got != r.ppguard) fail("guard differs", k, 0, got, r.ppguard);
    got = getField(dut->ren_ppold_cq01h, k * PW, PW);
    if (got != r.ppold) fail("old predicate destination differs", k, 0, got, r.ppold);
    for (unsigned i = 0; i != 2 && r.plogic; ++i) {
      got = getField(dut->ren_ppq_cq01h, (k * 2 + i) * PW, PW);
      if (got != r.pqn[i]) fail("predicate-logic source differs", k, i, got, r.pqn[i]);
    }
  }
  tick();
  if (cg.on()) {
    for (unsigned g = 0; g != cg.gaps(); ++g) idleTick();
    return;
  }
  // After it: every map, and every live checkpoint.
  for (unsigned s = 0; s != S; ++s) {
    for (unsigned a = 0; a != NG; ++a) {
      unsigned got = getField(dut->rat_cq02h, s * MW + a * GW, GW);
      if (got != gname(c.ratGpr(s, a))) fail("speculative GPR map differs", s, a, got, gname(c.ratGpr(s, a)));
      got = getField(dut->crat_cq02h, s * MW + a * GW, GW);
      if (got != gname(c.cratGpr(s, a))) fail("committed GPR map differs", s, a, got, gname(c.cratGpr(s, a)));
    }
    for (unsigned a = 0; a != NP; ++a) {
      unsigned got = getField(dut->rat_cq02h, s * MW + NG * GW + a * PW, PW);
      if (got != c.ratPred(s, a)) fail("speculative predicate map differs", s, a, got, c.ratPred(s, a));
      got = getField(dut->crat_cq02h, s * MW + NG * GW + a * PW, PW);
      if (got != c.cratPred(s, a)) fail("committed predicate map differs", s, a, got, c.cratPred(s, a));
    }
    for (unsigned k = 0; k != C; ++k) {
      if (!c.ckptLive(s, k)) continue;
      const unsigned base = (s * C + k) * MW;
      for (unsigned a = 0; a != NG; ++a) {
        const unsigned got = getField(dut->ckpt_cq02h, base + a * GW, GW);
        if (got != gname(c.ckptGpr(s, k, a))) fail("checkpoint GPR differs", s * C + k, a, got, gname(c.ckptGpr(s, k, a)));
      }
      for (unsigned a = 0; a != NP; ++a) {
        const unsigned got = getField(dut->ckpt_cq02h, base + NG * GW + a * PW, PW);
        if (got != c.ckptPred(s, k, a)) fail("checkpoint predicate differs", s * C + k, a, got, c.ckptPred(s, k, a));
      }
    }
  }
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("RAT_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_rat>(ctx.get());
  if (cg.on()) {
    cg.open(*dut, vcd);
    clearInputs();
    dut->ooe_rst_r00h = 1;
    for (unsigned k = 0; k != 4; ++k) tick();
    dut->ooe_rst_r00h = 0;
    if (cg.idle()) {
      for (unsigned k = 0; k != CgRun::kIdleCycles; ++k) idleTick();
    } else {
      ooeTestRandomHooked(CgRun::kSeeds, hook);
    }
    cg.close();
    dut->final();
    cg.vcd.reset();
    dut.reset();
    ctx.reset();
    return 0;
  }
  // The directed tests first: demotion, kill and restore-allocate, which
  // random traffic never reaches.
  const int model_fails = ooeTestDirectedHooked(hook) + ooeTestRandomHooked(seeds, hook);
  dut->final();
  std::printf("rat_tb control=%s seeds=%u cores=%llu cycles=%llu skipped=%llu renames=%llu in-group=%llu "
              "checkpoints=%llu restores=%llu squashes=%llu releases=%llu retires=%llu restore-writes=%llu "
              "mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, skipped, renames, in_group, ckpts,
              restores, squashes, releases, retires, rst_writes, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
