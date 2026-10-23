//===-- ren1_tb.cpp - Rename 1 against the live model ---------------------===//
//
// Runs the model's directed unit tests and its random ones (sim/ooe/
// ooe_test.cpp, every mode) and, after every core cycle, drives Rename 1 as
// ooe_rename holds it (test/ooe/ooe_ren1_tb.sv: ooe_headrd per slot,
// ooe_ren1, the Rename 1 register, beside ooe_rat; OI-67) with what the
// model renamed in it (Core::ratLog), and ooe_rat with the rest of the RAT
// log as test/ooe/rat_tb.cpp does.
//
// The cycle's renames, in rename order, are the lanes: lane k renames slot
// s's head h, where h counts the earlier renames of s this cycle (a warp's
// take is a prefix of its heads). Each such candidate shows that uop's
// fields; every other candidate shows random ones, which no lane may read.
// The free lists offer the cycle's new names in lane order, then random
// ones, and each taken candidate's writer counts (ooe_go's) are its
// writers before it in lane order; go_tb holds the go's to the model.
// After the edge, every lane in the Rename 1 register must be the
// model's: its slot, destinations and new names, branch and checkpoint, and
// its reads, through the pending group (the register itself, last cycle's)
// and the in-group writers (three sources, the old destination, the guard,
// the old predicate destination and predicate logic's two sources).
// rat_tb holds the maps themselves.
//
// Driven, not compared, as in slice 2: a core with sectioned names (the
// narrow allocator is not in this slice), a restore-allocate or an atomic
// (each counted). From its first such cycle a core is no longer compared.
//
// Negative controls (REN1_CONTROL=<name>) perturb the driving and must be
// caught: lane-swap (lanes 0 and 1 take each other's candidates),
// name-reverse (the free lists offer their heads in reverse) and
// drop-restore (no checkpoint restore reaches ooe_rat).
// Usage: ren1_tb [seeds]
//===----------------------------------------------------------------------===//
#include "Vooe_ren1_tb.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <memory>
#include <random>
#include <string>
#include <vector>

using ccv::ooe::Core;

int ooeTestDirectedHooked(void (*hook)(const Core &));

namespace {
constexpr unsigned S = REN1_S, R = REN1_R, RP = REN1_RP, C = REN1_C, GW = REN1_GW, GR = REN1_GR, PW = REN1_PW;
constexpr unsigned NC = S * R;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w ? w : 1; }
constexpr unsigned LS = bits(S), LC = bits(C);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_ren1_tb> dut;
std::string control;
CgRun cg;
std::mt19937 rng(7);
uint64_t current = 0;
bool skip = false;      // a core this RTL is not built for
bool stopped = false;   // a core past a cycle this slice does not cover: driven, not compared
unsigned long long cycles = 0, cores = 0, skipped = 0, stops = 0, lanes = 0, in_group = 0, names = 0,
                   pnames = 0, mismatches = 0;

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
  clearAll(dut->lane_v_cq02h, R);
  clearAll(dut->lane_c_cq02h, R * NC);
  clearAll(dut->tk_cq00h, S * R);
  clearAll(dut->hbr_cq00h, S * R);
  clearAll(dut->rstl_cq00h, S);
  clearAll(dut->rgl_cq00h, S * RP);
  clearAll(dut->rpl_cq00h, S * RP);
  clearAll(dut->ret_gwe_cq01h, S * RP);
  clearAll(dut->ret_pwe_cq01h, S * RP);
  clearAll(dut->restore_cq00h, S);
  clearAll(dut->squash_cq00h, S);
  clearAll(dut->release_cq00h, S);
}

void fail(const char *what, unsigned a, unsigned b, unsigned rtl, unsigned model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "cycle %llu: %s (%u, %u: rtl %u, model %u)\n", cycles, what, a, b, rtl, model);
}

unsigned gname(unsigned n) { return n * 4; }   // a whole row: the row at position 0

// Every candidate a random uop; the taken ones are overwritten.
void randomCandidates() {
  for (unsigned c = 0; c != NC; ++c) {
    for (unsigned i = 0; i != 3; ++i) setField(dut->c_src_cq01h, (c * 3 + i) * 4, 4, rng() & 15);
    setField(dut->c_dst_cq01h, c * 4, 4, rng() & 15);
    setBit(dut->c_gwe_cq01h, c, rng() & 1);
    setField(dut->c_pguard_cq01h, c * 2, 2, rng() & 3);
    setField(dut->c_pdst_cq01h, c * 2, 2, rng() & 3);
    setBit(dut->c_pwe_cq01h, c, rng() & 1);
    for (unsigned i = 0; i != 2; ++i) setField(dut->c_pq_cq01h, (c * 2 + i) * 2, 2, rng() & 3);
    setBit(dut->c_br_cq01h, c, rng() & 1);
    setField(dut->c_ckpt_cq01h, c * LC, LC, rng() % C);
  }
  for (unsigned c = 0; c != NC; ++c)
    for (unsigned b = 0; b != 2; ++b) setField(dut->wb_cq02h, (c * 2 + b) * R, R, (1u << (rng() % (R + 1))) - 1u);
  for (unsigned k = 0; k != R; ++k) {
    setField(dut->galloc_cq02h, k * GR, GR, rng() & ((1u << GR) - 1));
    setField(dut->palloc_cq02h, k * PW, PW, rng() & ((1u << PW) - 1));
  }
}

std::vector<Core::RatLog::Ret> prev_ret;

// Last cycle's retirements, as the ROB's retire-stage register holds them.
void driveRetire() {
  std::vector<unsigned> rport(S, 0);
  for (const auto &r : prev_ret) {
    const unsigned q = r.slot * RP + rport[r.slot]++;
    setBit(dut->ret_gwe_cq01h, q, r.gwe);
    setField(dut->ret_dst_cq01h, q * 4, 4, r.dst);
    setField(dut->ret_gname_cq01h, q * GW, GW, gname(r.gname));
    setBit(dut->ret_pwe_cq01h, q, r.pwe);
    setField(dut->ret_pdst_cq01h, q * 2, 2, r.pdst);
    setField(dut->ret_pname_cq01h, q * PW, PW, r.pname);
  }
}

void hook(const Core &c) {
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    const auto &cfg = c.config();
    skip = c.slots() != S || cfg.ckpts != C || cfg.rename_width > R || cfg.retire_per_rob > RP ||
           cfg.pred_zero != (1u << PW) - 1 || cfg.sectioned;
    stopped = false;
    clearInputs();
    driveRetire();
    tick();
    clearInputs();
    dut->ooe_rst_r00h = 1;
    tick();
    tick();   // the flopped reset
    dut->ooe_rst_r00h = 0;
    prev_ret.clear();
  }
  if (skip) { ++skipped; return; }
  const Core::RatLog &w = c.ratLog();
  // A cycle this slice does not cover: from it on, the core is driven only.
  if (!stopped)
    for (const auto &r : w.ren)
      if (r.rst || r.atomic) {
        stopped = true;
        ++stops;
        break;
      }
  ++cycles;
  clearInputs();
  for (const auto &r : w.restore) {
    if (control == "drop-restore") continue;
    setBit(dut->restore_cq00h, r.first, true);
    setField(dut->restore_ckpt_cq00h, r.first * LC, LC, r.second);
  }
  for (unsigned s = 0; s != S; ++s) {
    if ((w.squash >> s) & 1u) setBit(dut->squash_cq00h, s, true);
    if ((w.release >> s) & 1u) setBit(dut->release_cq00h, s, true);
  }
  std::vector<Core::RatLog::Ret> ret;
  std::vector<unsigned> rport(S, 0);
  for (const auto &r : w.ret) {
    const unsigned q = r.slot * RP + rport[r.slot]++;
    if (rport[r.slot] > RP) { fail("more retirements than ports", r.slot, 0, RP + 1, RP); return; }
    setBit(dut->rgl_cq00h, q, r.gwe);
    setBit(dut->rpl_cq00h, q, r.pwe);
    ret.push_back(r);
  }
  // The lanes: rename order; each its slot's next head.
  randomCandidates();
  std::vector<Core::RatLog::Ren> ren;
  for (const auto &r : w.ren)
    if (!r.rst) ren.push_back(r);
  if (ren.size() > R) { fail("more renames than lanes", 0, 0, unsigned(ren.size()), R); return; }
  std::vector<unsigned> head(S, 0), cand(ren.size());
  std::vector<unsigned> gnew, pnew;
  for (unsigned k = 0; k != ren.size(); ++k) {
    const auto &r = ren[k];
    const unsigned h = head[r.slot]++;
    if (h >= R) { fail("a slot renames past its heads", r.slot, h, h, R); return; }
    const unsigned x = h * S + r.slot;
    cand[k] = x;
    for (unsigned i = 0; i != 3; ++i) setField(dut->c_src_cq01h, (x * 3 + i) * 4, 4, r.src[i]);
    setField(dut->c_dst_cq01h, x * 4, 4, r.dst);
    setBit(dut->c_gwe_cq01h, x, r.gwe);
    setField(dut->c_pguard_cq01h, x * 2, 2, r.pguard);
    setField(dut->c_pdst_cq01h, x * 2, 2, r.pdst);
    setBit(dut->c_pwe_cq01h, x, r.pwe);
    for (unsigned i = 0; i != 2; ++i) setField(dut->c_pq_cq01h, (x * 2 + i) * 2, 2, r.pq[i]);
    setBit(dut->c_br_cq01h, x, r.br);
    setField(dut->c_ckpt_cq01h, x * LC, LC, r.ckpt);
    setField(dut->wb_cq02h, (x * 2 + 0) * R, R, (1u << gnew.size()) - 1u);
    setField(dut->wb_cq02h, (x * 2 + 1) * R, R, (1u << pnew.size()) - 1u);
    if (r.gwe) gnew.push_back(r.gname);
    if (r.pwe) pnew.push_back(r.pname);
    // ooe_rat's leads: rename's takes and the heads' branch fields.
    setBit(dut->tk_cq00h, r.slot * R + h, true);
    setBit(dut->hbr_cq00h, r.slot * R + h, r.br);
    setField(dut->hck_cq00h, (r.slot * R + h) * LC, LC, r.ckpt);
    for (unsigned j = 0; j != k; ++j) in_group += ren[j].slot == r.slot;
  }
  std::vector<unsigned> lane(cand);
  if (control == "lane-swap" && lane.size() >= 2) std::swap(lane[0], lane[1]);
  for (unsigned k = 0; k != lane.size(); ++k) {
    setBit(dut->lane_v_cq02h, k, true);
    setBit(dut->lane_c_cq02h, k * NC + lane[k], true);
  }
  if (control == "name-reverse") {
    std::reverse(gnew.begin(), gnew.end());
    std::reverse(pnew.begin(), pnew.end());
  }
  for (unsigned k = 0; k != gnew.size(); ++k) setField(dut->galloc_cq02h, k * GR, GR, gnew[k]);
  for (unsigned k = 0; k != pnew.size(); ++k) setField(dut->palloc_cq02h, k * PW, PW, pnew[k]);
  driveRetire();
  dut->ooe_core_clk = 0;
  dut->eval();
  tick();
  prev_ret = ret;
  if (!stopped) {
    // After it: the Rename 1 register, lane by lane.
    for (unsigned k = 0; k != R; ++k) {
      const bool v = getBit(dut->q_v, k);
      if (v != (k < ren.size())) { fail("lane valid differs", k, 0, v, k < ren.size()); continue; }
      if (!v) continue;
      const auto &r = ren[k];
      ++lanes;
      auto eq = [&](const char *what, unsigned i, unsigned got, unsigned want) {
        if (got != want) fail(what, k, i, got, want);
      };
      eq("slot", 0, getField(dut->q_slot, k * LS, LS), r.slot);
      eq("GPR write", 0, getBit(dut->q_gwe, k), r.gwe);
      eq("predicate write", 0, getBit(dut->q_pwe, k), r.pwe);
      eq("branch", 0, getBit(dut->q_br, k), r.br);
      if (r.gwe) { eq("destination", 0, getField(dut->q_dst, k * 4, 4), r.dst); ++names; }
      if (r.gwe) eq("new GPR name", 0, getField(dut->q_gname, k * GW, GW), gname(r.gname));
      if (r.pwe) { eq("predicate destination", 0, getField(dut->q_pdst, k * 2, 2), r.pdst); ++pnames; }
      if (r.pwe) eq("new predicate name", 0, getField(dut->q_pname, k * PW, PW), r.pname);
      if (r.br) eq("checkpoint", 0, getField(dut->q_ckpt, k * LC, LC), r.ckpt);
      for (unsigned i = 0; i != 3; ++i) eq("source read", i, getField(dut->q_g, (k * 4 + i) * GW, GW), gname(r.psrc[i]));
      eq("old destination", 0, getField(dut->q_g, (k * 4 + 3) * GW, GW), gname(r.pold));
      eq("guard", 0, getField(dut->q_p, (k * 4 + 0) * PW, PW), r.ppguard);
      eq("old predicate destination", 0, getField(dut->q_p, (k * 4 + 1) * PW, PW), r.ppold);
      for (unsigned i = 0; i != 2 && r.plogic; ++i)
        eq("predicate-logic source", i, getField(dut->q_p, (k * 4 + 2 + i) * PW, PW), r.pqn[i]);
    }
  }
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("REN1_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_ren1_tb>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  const int model_fails = (cg.on() ? 0 : ooeTestDirectedHooked(hook)) + cg.run(seeds, nullptr, hook);
  cg.close();
  dut->final();
  std::printf("ren1_tb control=%s seeds=%u cores=%llu cycles=%llu skipped=%llu stopped=%llu lanes=%llu "
              "in-group=%llu gpr-names=%llu pred-names=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, skipped, stops, lanes, in_group,
              names, pnames, mismatches, model_fails);
  const int rc = mismatches || model_fails || !lanes ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
