//===-- rat_tb.cpp - ooe_rat and its read against the live model -------===//
//
// Runs the model's directed unit tests (demotion, kill, restore-allocate,
// faults, squashes) and its random ones (sim/ooe/ooe_test.cpp, every mode:
// mispredicts, several warps) and, after every
// core cycle, drives ooe_rat and Rename 1's read of it (ooe_ratread, under
// test/ooe/ooe_rat_read.sv: OA's response OI-46) with what reached the
// model's register alias
// tables in it (Core::ratLog): checkpoint restores, squashes to retirement,
// slot releases, the committed maps' writes at retirement, and rename's
// ports in rename order, a restore-allocate's writes among them.
//
// ooe_rat writes an edge after the model (OA's response OI-58): a cycle's
// group from rename's register at the next, its retirements from the
// retire-stage register, its whole-map events from ooe_rat's own register;
// the bench drives each cycle's leads (rename's takes, decq's head branch
// fields, a restore-allocate, the ROB's retire decision) with it. Before
// the edge, every rename port's reads, through the pending group, must be
// the model's: three sources, the old destination, the guard, the old
// predicate destination and, for predicate logic, its two sources. After
// it, every slot's speculative and committed maps must be the model's an
// edge before, and every then-live checkpoint's contents.
//
// A register name is opaque to the RAT. The model names a GPR by row alone
// when it is not sectioned, so the bench gives those the RTL's form, the
// row at position 0; the zero register is then the same name in both.
//
// Negative controls (RAT_CONTROL=<name>) perturb the driving and must be
// caught: port-reverse (a cycle's rename ports in reverse order, so the
// in-group override reads the wrong writes), drop-restore (no checkpoint
// restore reaches the RTL), drop-retire (no retirement write does) and
// drop-squash (no squash to retirement does), no-pending (last cycle's
// group never reaches the RTL) and no-lead (rename's takes and
// restore-allocates are not led).
//
// With --cg <scenario> <vcd> it is ooe_rat's clock-gating bench
// (test/ooe/cg_trace.h), and compares nothing.
// Usage: rat_tb [seeds] | rat_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_rat_read.h"
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
std::unique_ptr<Vooe_rat_read> dut;
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
  clearAll(dut->pw_v_cq01h, A);
  clearAll(dut->tk_cq00h, S * A);
  clearAll(dut->rstl_cq00h, S);
  clearAll(dut->rgl_cq00h, S * R);
  clearAll(dut->rpl_cq00h, S * R);
  clearAll(dut->ret_gwe_cq01h, S * R);
  clearAll(dut->ret_pwe_cq01h, S * R);
  clearAll(dut->restore_cq00h, S);
  clearAll(dut->squash_cq00h, S);
  clearAll(dut->release_cq00h, S);
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

// ooe_rat writes an edge after the model (OA's response OI-58): the group
// renamed in a cycle reaches it the next from rename's register, a
// retirement from the retire-stage register, a whole-map event from its
// own register. So after each edge its maps are the model's an edge
// before: the snapshot taken at the last cycle.
struct Snap {
  std::vector<unsigned> rat, crat, ckpt;   // GPRs then predicates, per slot (and checkpoint)
  std::vector<uint8_t> live;
};
Snap snap;
bool have_snap = false;
std::vector<Core::RatLog::Ren> prev_ren;   // last cycle's group, in the order driven
std::vector<Core::RatLog::Ret> prev_ret;

Snap take(const Core &c) {
  Snap n;
  for (unsigned s = 0; s != S; ++s) {
    for (unsigned a = 0; a != NG; ++a) { n.rat.push_back(gname(c.ratGpr(s, a))); n.crat.push_back(gname(c.cratGpr(s, a))); }
    for (unsigned a = 0; a != NP; ++a) { n.rat.push_back(c.ratPred(s, a)); n.crat.push_back(c.cratPred(s, a)); }
    for (unsigned k = 0; k != C; ++k) {
      n.live.push_back(c.ckptLive(s, k));
      for (unsigned a = 0; a != NG; ++a) n.ckpt.push_back(gname(c.ckptGpr(s, k, a)));
      for (unsigned a = 0; a != NP; ++a) n.ckpt.push_back(c.ckptPred(s, k, a));
    }
  }
  return n;
}

// Last cycle's group and retirements, as rename's and the ROB's registers
// hold them this cycle.
void drivePending() {
  for (unsigned k = 0; k != prev_ren.size(); ++k) {
    const auto &r = prev_ren[k];
    setBit(dut->pw_v_cq01h, k, control != "no-pending");
    setField(dut->pw_slot_cq01h, k * LS, LS, r.slot);
    setBit(dut->pw_rst_cq01h, k, r.rst);
    setField(dut->pw_dst_cq01h, k * 4, 4, r.dst);
    setBit(dut->pw_gwe_cq01h, k, r.gwe);
    setField(dut->pw_gname_cq01h, k * GW, GW, gname(r.gname));
    setField(dut->pw_pdst_cq01h, k * 2, 2, r.pdst);
    setBit(dut->pw_pwe_cq01h, k, r.pwe);
    setField(dut->pw_pname_cq01h, k * PW, PW, r.pname);
    setBit(dut->pw_br_cq01h, k, r.br);
    setField(dut->pw_ckpt_cq01h, k * LC, LC, r.ckpt);
  }
  std::vector<unsigned> rport(S, 0);
  for (const auto &r : prev_ret) {
    const unsigned q = r.slot * R + rport[r.slot]++;
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
    skip = c.slots() != S || cfg.ckpts != C || cfg.rename_width > A || cfg.retire_per_rob > R ||
           cfg.pred_zero != (1u << PW) - 1;
    // The last core's pending writes land first: their leads are flopped.
    clearInputs();
    drivePending();
    tick();
    scale = cfg.sectioned ? 1 : 4;
    clearInputs();
    dut->ooe_rst_r00h = 1;
    tick();
    tick();   // the flopped reset
    dut->ooe_rst_r00h = 0;
    have_snap = false;
    prev_ren.clear();
    prev_ret.clear();
  }
  if (skip) { ++skipped; return; }
  ++cycles;
  const Core::RatLog &w = c.ratLog();
  clearInputs();
  // This cycle's whole-map events, which ooe_rat registers.
  for (const auto &r : w.restore) {
    if (control == "drop-restore") continue;
    setBit(dut->restore_cq00h, r.first, true);
    setField(dut->restore_ckpt_cq00h, r.first * LC, LC, r.second);
    ++restores;
  }
  for (unsigned s = 0; s != S; ++s) {
    if (((w.squash >> s) & 1u) && control != "drop-squash") { setBit(dut->squash_cq00h, s, true); ++squashes; }
    if ((w.release >> s) & 1u) { setBit(dut->release_cq00h, s, true); ++releases; }
  }
  // This cycle's retirements: the decision, as ooe_rat's lead.
  std::vector<Core::RatLog::Ret> ret;
  std::vector<unsigned> rport(S, 0);
  for (const auto &r : w.ret) {
    if (control == "drop-retire") continue;
    const unsigned q = r.slot * R + rport[r.slot]++;
    if (rport[r.slot] > R) { fail("more retirements than ports", r.slot, 0, R + 1, R); return; }
    setBit(dut->rgl_cq00h, q, r.gwe);
    setBit(dut->rpl_cq00h, q, r.pwe);
    ret.push_back(r);
    ++retires;
  }
  // This cycle's group: Rename 1's read, and its leads into ooe_rat.
  if (w.ren.size() > A) { fail("more renames than ports", 0, 0, unsigned(w.ren.size()), A); return; }
  std::vector<unsigned> order(w.ren.size());
  for (unsigned k = 0; k != order.size(); ++k) order[k] = k;
  if (control == "port-reverse") std::reverse(order.begin(), order.end());
  std::vector<Core::RatLog::Ren> ren;
  std::vector<unsigned> taken(S, 0);
  for (unsigned k = 0; k != order.size(); ++k) {
    const auto &r = w.ren[order[k]];
    ren.push_back(r);
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
    if (r.rst) {
      setBit(dut->rstl_cq00h, r.slot, control != "no-lead");
      ++rst_writes;
    } else {
      const unsigned j = taken[r.slot]++;
      setBit(dut->tk_cq00h, r.slot * A + j, control != "no-lead");
      setBit(dut->hbr_cq00h, r.slot * A + j, r.br);
      setField(dut->hck_cq00h, (r.slot * A + j) * LC, LC, r.ckpt);
      ++renames;
    }
    ckpts += r.br && !r.rst;
    for (unsigned j = 0; j != k; ++j) in_group += !r.rst && w.ren[order[j]].slot == r.slot;
  }
  drivePending();
  // Before the edge: every rename port's reads, through the pending group.
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
  prev_ren = ren;
  prev_ret = ret;
  if (cg.on()) {
    // A gap after the cycle: its pending writes still land at the next
    // edge, with nothing new led.
    for (unsigned g = 0; g != cg.gaps(); ++g) {
      clearInputs();
      if (g == 0) drivePending();
      tick();
      prev_ren.clear();
      prev_ret.clear();
    }
    return;
  }
  // After it: every map, and every live checkpoint, as the model's an edge
  // before.
  if (have_snap)
    for (unsigned s = 0; s != S; ++s) {
      for (unsigned a = 0; a != NG + NP; ++a) {
        const unsigned w0 = a < NG ? GW : PW, lsb = s * MW + (a < NG ? a * GW : NG * GW + (a - NG) * PW);
        unsigned got = getField(dut->rat_cq02h, lsb, w0);
        if (got != snap.rat[s * (NG + NP) + a]) fail("speculative map differs", s, a, got, snap.rat[s * (NG + NP) + a]);
        got = getField(dut->crat_cq02h, lsb, w0);
        if (got != snap.crat[s * (NG + NP) + a]) fail("committed map differs", s, a, got, snap.crat[s * (NG + NP) + a]);
      }
      for (unsigned k = 0; k != C; ++k) {
        if (!snap.live[s * C + k]) continue;
        for (unsigned a = 0; a != NG + NP; ++a) {
          const unsigned w0 = a < NG ? GW : PW;
          const unsigned lsb = (s * C + k) * MW + (a < NG ? a * GW : NG * GW + (a - NG) * PW);
          const unsigned got = getField(dut->ckpt_cq02h, lsb, w0), want = snap.ckpt[(s * C + k) * (NG + NP) + a];
          if (got != want) fail("checkpoint differs", s * C + k, a, got, want);
        }
      }
    }
  snap = take(c);
  have_snap = true;
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("RAT_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_rat_read>(ctx.get());
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
