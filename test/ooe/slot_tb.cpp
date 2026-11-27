//===-- slot_tb.cpp - ooe_slot against the model's control step ------------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode) and,
// after every core cycle, takes the model's log of its control step
// (Core::slotLog): the allocations, the new demotes and the kill it took,
// the levels it read per slot (held, landed, ath, xr), its verdicts (the
// slots squashed with an epoch notice, the maps, the releases, the drained
// messages, the kill's ack) and each slot after it, state and identity.
//
// The RTL runs one log behind: each drive presents a cycle's inputs, with
// the leads of the next cycle's allocations and demotes (ev_l) and kill
// (kill_l), and after the edge every verdict and every slot must be the
// model's. A demote the model holds behind an atomic retries from the
// RTL's own flop (dmh), so only new demotes are driven. kill_ack is a
// level: the bench keeps the model's (set at an ack, cleared at the next
// kill) and compares it, with its epoch, every cycle.
//
// Negative controls (SLOT_CONTROL=<name>) must be caught: no-ath (an
// atomic at the head never holds a demote), no-xr (a demote is never
// refused), no-held (the ROB always reads empty), lnd-early (the notice
// always reads landed), no-kill-lead (the kill's lead never reaches it),
// no-ev-lead (the event lead never reaches it), no-free (a free never
// reaches it) and rsa-no-clear-restore (a restore-allocate never clears
// the slot's retired-since-allocation flop, so its pc_kept is lost).
//
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: slot_tb [seeds] | slot_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_slot_tb.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Core;

namespace {
constexpr unsigned S = SL_S, A = SL_A, D = SL_D, NW = 32, WC = 32, WI = 5, WB = 5, WT = 3, KE = 2;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned LS = bits(S), LW = bits(NW);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_slot_tb> dut;
std::string control;
bool skip_core = false;
unsigned long long proto_skipped = 0;
uint64_t current = 0;
Core::SlotLog pend;
bool have_pend = false;
bool exp_ack = false;
unsigned exp_ack_ep = 0;
unsigned long long kept_drains = 0, cycles = 0, cores = 0, mismatches = 0, allocs[4] = {}, demotes = 0, refused = 0, held_dm = 0,
                   kills = 0, acks = 0, acks_now = 0, ntcs = 0, maps = 0, drains = 0, rels = 0, skipped = 0,
                   max_al = 0, max_dm = 0;

template <typename T> void setField(T &w, unsigned lsb, unsigned n, uint64_t v) {
  for (unsigned b = 0; b != n; ++b) {
    const unsigned i = lsb + b;
    const bool x = (v >> b) & 1u;
    if constexpr (sizeof(T) <= 8) {
      if (x) w |= (T(1) << i); else w &= ~(T(1) << i);
    } else {
      if (x) w[i / 32] |= (1u << (i % 32)); else w[i / 32] &= ~(1u << (i % 32));
    }
  }
}
template <typename T> uint64_t getField(const T &w, unsigned lsb, unsigned n) {
  uint64_t v = 0;
  for (unsigned b = 0; b != n; ++b) {
    const unsigned i = lsb + b;
    bool x;
    if constexpr (sizeof(T) <= 8) x = (w >> i) & 1u;
    else x = (w[i / 32] >> (i % 32)) & 1u;
    v |= uint64_t(x) << b;
  }
  return v;
}

CgRun cg;

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}

void fail(const char *what, unsigned where, uint64_t rtl, uint64_t model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "%s, cycle %llu at %u: %s (rtl %llu, model %llu)\n", ooeTestName(), cycles, where, what,
                 (unsigned long long)rtl, (unsigned long long)model);
}

bool hasEvents(const Core::SlotLog &e) {
  bool al = !e.alloc.empty();
  if (control == "no-free") {
    al = false;
    for (const auto &a : e.alloc) al = al || a.op != 0;
  }
  return al || !e.demote.empty();
}

void drive(const Core::SlotLog &e, const Core::SlotLog *nx) {
  ++cycles;
  // The inputs.
  if (e.alloc.size() > A || e.demote.size() > D) {
    fail("more allocations or demotes than ports", 0, e.alloc.size(), e.demote.size());
    return;
  }
  // A protocol error the model's own tests make (restore-activate beside
  // its restore-allocate: testRestore): the RTL asserts it, so the core is
  // left there.
  for (unsigned i = 0; i != e.alloc.size(); ++i)
    for (unsigned j = i + 1; j != e.alloc.size(); ++j)
      if (e.alloc[i].slot == e.alloc[j].slot && e.alloc[i].op && e.alloc[j].op) {
        ++proto_skipped;
        skip_core = true;
        have_pend = false;
        return;
      }
  max_al = std::max<unsigned long long>(max_al, e.alloc.size());
  max_dm = std::max<unsigned long long>(max_dm, e.demote.size());
  dut->al_v_cq01h = 0;
  unsigned k = 0;
  for (const auto &a : e.alloc) {
    ++allocs[a.op & 3];
    if (control == "no-free" && a.op == 0) continue;
    dut->al_v_cq01h |= 1u << k;
    setField(dut->al_slot_cq01h, k * LS, LS, a.slot);
    setField(dut->al_op_cq01h, k * 2, 2, a.op);
    setField(dut->al_warp_cq01h, k * LW, LW, a.warp);
    setField(dut->al_ctaid_cq01h, k * WC, WC, a.ctaid);
    setField(dut->al_wic_cq01h, k * WI, WI, a.wic);
    setField(dut->al_barc_cq01h, k * WB, WB, a.barc);
    setField(dut->al_cta_cq01h, k * WT, WT, a.cta);
    ++k;
  }
  dut->dm_v_cq01h = 0;
  for (unsigned d = 0; d != e.demote.size(); ++d) {
    dut->dm_v_cq01h |= 1u << d;
    setField(dut->dm_warp_cq01h, d * LW, LW, e.demote[d]);
  }
  demotes += e.demote.size();
  dut->kill_mask_cq01h = e.kill ? e.kill_mask : 0;
  dut->kill_ep_cq01h = e.kill ? e.kill_epoch : 0;
  dut->held_cq01h = control == "no-held" ? 0 : e.held;
  dut->lnd_cq01h = control == "lnd-early" ? (1u << S) - 1 : e.landed;
  dut->ath_cq01h = control == "no-ath" ? 0 : e.ath;
  dut->xr_cq01h = control == "no-xr" ? 0 : e.xr;
  // pc_kept (OA 470): the retirements, and the control rsa-no-clear-restore,
  // a retirement on every restore-allocate's own cycle, so rsa survives it.
  uint32_t ret = e.ret;
  if (control == "rsa-no-clear-restore")
    for (const auto &a : e.alloc)
      if (a.op == 2) ret |= 1u << a.slot;
  dut->ret_cq01h = ret;
  // The next cycle's leads.
  dut->ev_l_cq00h = nx && hasEvents(*nx) && control != "no-ev-lead";
  dut->kill_l_cq00h = nx && nx->kill && control != "no-kill-lead";
  tick();
  // The verdicts.
  ntcs += __builtin_popcount(e.ntc);
  maps += __builtin_popcount(e.map);
  rels += __builtin_popcount(e.release);
  kills += e.kill;
  held_dm += __builtin_popcount(e.dmh);
  if (dut->ntc_cq02h != e.ntc) fail("squash and notice differ", 0, dut->ntc_cq02h, e.ntc);
  if (dut->map_cq02h != e.map) fail("maps differ", 0, dut->map_cq02h, e.map);
  if (dut->rel_cq02h != e.release) fail("releases differ", 0, dut->rel_cq02h, e.release);
  if (dut->dmh_cq02h != e.dmh) fail("held demotes differ", 0, dut->dmh_cq02h, e.dmh);
  uint32_t drn = 0, ref = 0, kept = 0;
  for (const auto &d : e.drained) {
    int s = -1;
    for (unsigned t = 0; t != S; ++t)
      if ((e.st[t] == 2 || e.st[t] == 5) && e.warp[t] == d.warp) s = int(t);
    if (s < 0) { fail("a drained message for a warp no slot holds", 0, 0, d.warp); continue; }
    drn |= 1u << s;
    if (d.refused) ref |= 1u << s;
    else if (d.kept) { kept |= 1u << s; ++kept_drains; }
    ++(d.refused ? refused : drains);
  }
  if (dut->drn_cq02h != drn) fail("drained messages differ", 0, dut->drn_cq02h, drn);
  else if ((dut->drn_ref_cq02h & drn) != ref) fail("drained refusals differ", 0, dut->drn_ref_cq02h & drn, ref);
  else if ((dut->drn_kept_cq02h & drn & ~ref) != kept)
    fail("drained pc_kept differs", 0, dut->drn_kept_cq02h & drn & ~ref, kept);
  if (e.kill_ack >= 0) {
    exp_ack = true;
    exp_ack_ep = unsigned(e.kill_ack);
    ++acks;
    acks_now += e.kill && !e.ntc;
  } else if (e.kill) {
    exp_ack = false;
  }
  if (dut->kack_cq02h != exp_ack) fail("kill_ack level differs", 0, dut->kack_cq02h, exp_ack);
  else if (exp_ack && dut->kack_ep_cq02h != exp_ack_ep) fail("kill_ack_epoch differs", 0, dut->kack_ep_cq02h, exp_ack_ep);
  // The slots.
  for (unsigned s = 0; s != S; ++s) {
    const unsigned st = unsigned(getField(dut->st_cq02h, s * 3, 3));
    if (st != e.st[s]) { fail("slot state differs", s, st, e.st[s]); continue; }
    if (!st) continue;
    if (getField(dut->warp_cq02h, s * LW, LW) != e.warp[s]) fail("slot warp differs", s, getField(dut->warp_cq02h, s * LW, LW), e.warp[s]);
    if (getField(dut->ctaid_cq02h, s * WC, WC) != e.ctaid[s]) fail("slot ctaid differs", s, getField(dut->ctaid_cq02h, s * WC, WC), e.ctaid[s]);
    if (getField(dut->wic_cq02h, s * WI, WI) != e.wic[s]) fail("slot warp_in_cta differs", s, getField(dut->wic_cq02h, s * WI, WI), e.wic[s]);
    if (getField(dut->barc_cq02h, s * WB, WB) != e.barc[s]) fail("slot barrier_count differs", s, getField(dut->barc_cq02h, s * WB, WB), e.barc[s]);
    if (getField(dut->cta_cq02h, s * WT, WT) != e.cta[s]) fail("slot cta_slot differs", s, getField(dut->cta_cq02h, s * WT, WT), e.cta[s]);
  }
}

void resetDut() {
  dut->ev_l_cq00h = 0;
  dut->kill_l_cq00h = 0;
  dut->al_v_cq01h = 0;
  dut->dm_v_cq01h = 0;
  dut->held_cq01h = 0;
  dut->lnd_cq01h = 0;
  dut->ath_cq01h = 0;
  dut->xr_cq01h = 0;
  dut->ret_cq01h = 0;
  dut->ooe_rst_r00h = 1;
  tick();
  tick();
  dut->ooe_rst_r00h = 0;
  tick();
  exp_ack = false;
}

void push(const Core::SlotLog &e) {
  if (have_pend) drive(pend, &e);
  if (skip_core) { have_pend = false; return; }
  pend = e;
  have_pend = true;
}

void flushPend(const Core::SlotLog *nx) {
  if (have_pend) { drive(pend, nx); have_pend = false; }
}

void pre(const Core &c) {
  if (c.serial() == current) return;
  flushPend(nullptr);
  current = c.serial();
  ++cores;
  // Cores the model runs with a control injected into its control step
  // (its own negative controls) and cores with other than S slots.
  const auto &cf = c.config();
  skip_core = cf.slots != S || cf.inject_no_refuse || cf.inject_atom_demote_mid;
  skipped += skip_core;
  if (skip_core) return;
  resetDut();
  // A null cycle ahead of the core's first carries the lead of its launches.
  pend = Core::SlotLog();
  have_pend = true;
}

void post(const Core &c) {
  if (skip_core || c.serial() != current) return;
  const auto &l = c.slotLog();
  if (!l.ran) return;
  push(l);
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("SLOT_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_slot_tb>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  const int model_fails = cg.on() ? cg.run(seeds, pre, post) : ooeTestScenario("slot", seeds, 0, pre, post, nullptr);
  flushPend(nullptr);
  cg.close();
  dut->final();
  std::printf("slot_tb control=%s seeds=%u cores=%llu (skipped: other slots or a model control=%llu) cycles=%llu allocs=%llu/%llu/%llu/%llu "
              "(free/launch/ralloc/ract, max %llu a cycle) demotes=%llu (max %llu) refused=%llu held-at-atomic=%llu "
              "kills=%llu acks=%llu (naming none=%llu) notices=%llu maps=%llu drained=%llu releases=%llu "
              "pc_kept=%llu protocol-error cores left=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, skipped, cycles, allocs[0], allocs[1], allocs[2],
              allocs[3], max_al, demotes, max_dm, refused, held_dm, kills, acks, acks_now, ntcs, maps, drains, rels,
              kept_drains, proto_skipped, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
