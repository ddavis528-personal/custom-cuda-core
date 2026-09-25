//===-- main.cpp - ccv-skel: the Stage 3 skeleton ----------------------===//
//
// Runs the whole machine -- 45 block instances, 102 channel instances, 339
// credited slots -- with the SystemVerilog interface checker Verilated in at
// every slot. The bank is clocked with each cycle's channel signals, so the
// skeleton is judged by the same checker the RTL will be, and the
// load-bearing EV_CH_XFER stream comes from that same code.
//
//   ccv-skel [--cycles N] [--seed S] [--trace FILE] [--force-atomic]
//            [--break MODE]
//
// --break exists to prove the bank is wired, slot by slot, to what it claims
// to check. A clean run from a bank that is not connected looks exactly like
// a clean run from one that is; a violation on EVERY slot, each reported by
// its own checker instance, does not.
//   phantom-all   every receiver returns a credit for nothing   (credit bit)
//   stall-all     every receiver stalls, every sender sends     (stall, valid)
//   atomic-all    every multi-slot channel checked as atomic, then its
//                 lockstep broken, credits and valids separately
//   lockstep-all  on every lockstep channel, ONE instance's slot 0 valid,
//                 then its credit, without its siblings
//   misbind       lane 7 of a lockstep channel carries slot k+1's
//                 instruction in slot k: matching valids, different ids
//   misorder      ordered channels: a head taken that is not the oldest of
//                 its stream or key
//   wrong-class   every message stamped with an id class its channel may
//                 not carry
//
// --force-atomic runs every multi-slot channel as atomic (stubs AND checks)
// with ordinary traffic, which must be clean -- the partner to atomic-all.
//===----------------------------------------------------------------------===//
#include "Vccv_skel_checkers.h"
#include "verilated.h"

#include "ccv/event.h"
#include "exerciser.h"
#include "machine.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <tuple>

using namespace ccv::skel;

namespace {

template <typename W> void setBit(W &w, uint64_t i, bool v) {
  const uint32_t m = 1u << (i % 32);
  w[i / 32] = v ? (w[i / 32] | m) : (w[i / 32] & ~m);
}

/// Present this cycle's signals -- `cur` -- to the checker bank.
void drive(Vccv_skel_checkers &bank, Machine &m) {
  auto &slots = m.slots();
  for (unsigned k = 0; k != kNumSlots; ++k) {
    setBit(bank.valid, k, slots[k].cur.valid);
    setBit(bank.credit, k, slots[k].cur.credit);
    setBit(bank.stall, k, slots[k].cur.stall);
    // Trace sideband: 64 bits per slot, present because the skeleton is
    // always built with CCV_TRACE.
    for (unsigned b = 0; b != 64; ++b)
      setBit(bank.tid, uint64_t(k) * 64 + b, (slots[k].cur.tid >> b) & 1u);
  }
  for (const ChanInst &ci : kChanInsts) {
    const ChanDesc &cd = kChans[ci.chan];
    for (unsigned s = 0; s != cd.rate; ++s) {
      const Bits &p = slots[ci.slot_base + s].cur.payload;
      const uint64_t base = ci.payload_base + uint64_t(s) * cd.bits;
      for (uint32_t b = 0; b != cd.bits; ++b)
        setBit(bank.payload, base + b, p.bit(b));
    }
  }
}

} // namespace

int main(int argc, char **argv) {
  uint64_t cycles = 2000, seed = 1;
  std::string trace, brk = "none";
  bool force_atomic = false;
  for (int i = 1; i < argc; ++i) {
    auto arg = [&](const char *f) { return !std::strcmp(argv[i], f) && i + 1 < argc; };
    if (arg("--cycles"))     cycles = std::strtoull(argv[++i], nullptr, 0);
    else if (arg("--seed"))  seed = std::strtoull(argv[++i], nullptr, 0);
    else if (arg("--trace")) trace = argv[++i];
    else if (arg("--break")) brk = argv[++i];
    else if (!std::strcmp(argv[i], "--force-atomic")) force_atomic = true;
  }
  // Wiring controls silence organic traffic so nothing else can fire; the
  // semantic ones (misorder, wrong-class) need traffic to be wrong about.
  const bool breaking = brk == "phantom-all" || brk == "stall-all" ||
                        brk == "atomic-all" || brk == "lockstep-all";
  if (brk != "none" && !breaking && brk != "misorder" &&
      brk != "wrong-class" && brk != "misbind") {
    std::fprintf(stderr, "unknown --break mode %s\n", brk.c_str());
    return 2;
  }

  if (unsigned bad = checkFieldTiling()) {
    std::fprintf(stderr, "%u channel(s) with a broken field table\n", bad);
    return 1;
  }

  auto ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  // Count violations and keep going, rather than stopping at the first: a
  // report that says how many and where is worth more than one that says
  // "something".
  ctx->errorLimit(1 << 30);
  auto bank = std::make_unique<Vccv_skel_checkers>(ctx.get(), "bank");

  if (!trace.empty() && !ccv::traceWriter().open(trace)) {
    std::fprintf(stderr, "cannot open trace %s\n", trace.c_str());
    return 1;
  }

  ExerciseCfg cfg;
  cfg.seed = seed;
  if (breaking) {
    // No organic traffic, consumption or stalls to muddy the control. A
    // random stall landing on a forced valid is a genuine stall_honoured
    // violation -- the first atomic-all run reported 32 of them.
    cfg.p_send = 0.0;
    cfg.p_pop = 0.0;
    cfg.p_stall = 0.0;
  }
  cfg.force_atomic = force_atomic || brk == "atomic-all";
  cfg.misorder = brk == "misorder";
  cfg.wrong_class = brk == "wrong-class";
  cfg.misbind = brk == "misbind";
  bank->force_atomic = cfg.force_atomic;
  Machine m(2, [&](int inst) { return makeExerciser(inst, cfg); });

  const uint64_t kReset = 2, kDrain = 16, kBreakAt = 6;
  for (uint64_t c = 0; c != cycles; ++c) {
    const bool in_reset = c < kReset;
    setDraining(c + kDrain >= cycles);

    bank->rst_n = !in_reset;
    drive(*bank, m);
    bank->clk = 0; bank->eval(); ctx->timeInc(5);
    bank->clk = 1; bank->eval(); ctx->timeInc(5);

    m.step(in_reset, [&] {
      if (brk == "phantom-all" && c == kBreakAt)
        for (unsigned k = 0; k != kNumSlots; ++k) m.rx(k).forceCredit();
      if (brk == "stall-all" && c == kBreakAt)
        for (unsigned k = 0; k != kNumSlots; ++k) m.rx(k).stall(true);
      if (brk == "stall-all" && c == kBreakAt + 1)
        for (unsigned k = 0; k != kNumSlots; ++k) m.tx(k).forceValid();
      // atomic-all: a whole group (legal), then ONE slot's credit, then ONE
      // slot's valid. Each is legal for the credit checker -- slot 0 has a
      // message outstanding, and credit to spare -- so only the atomic
      // checks may fire, and each must, on every multi-slot instance.
      if (brk == "atomic-all")
        for (const ChanInst &ci : kChanInsts) {
          if (kChans[ci.chan].rate < 2) continue;
          if (c == kBreakAt)
            for (unsigned s = 0; s != kChans[ci.chan].rate; ++s)
              m.tx(ci.slot_base + s).forceValid();
          if (c == kBreakAt + 3) m.rx(ci.slot_base).forceCredit();
          if (c == kBreakAt + 5) m.tx(ci.slot_base).forceValid();
        }
      // lockstep-all: instance 0's slot 0 alone -- a valid, then (legally,
      // for that slot) its credit. Only the lockstep checks may fire.
      if (brk == "lockstep-all")
        for (const ChanInst &ci : kChanInsts) {
          if (!kChans[ci.chan].lockstep || ci.inst != 0) continue;
          if (c == kBreakAt) m.tx(ci.slot_base).forceValid();
          if (c == kBreakAt + 3) m.rx(ci.slot_base).forceCredit();
        }
    });
  }
  bank->final();
  ccv::traceWriter().close();

  // -- summary: one line, machine-readable, for tools/check-skel.sh --------
  const ExerciseTotals t = exerciseTotals();
  uint64_t overflows = 0;
  unsigned idle = 0;
  for (unsigned k = 0; k != kNumSlots; ++k) {
    overflows += m.rx(k).overflows();
    if (m.rx(k).received() == 0) ++idle;
  }
  std::printf("SKEL cycles=%llu blocks=%u chan_types=%u chan_insts=%u "
              "slots=%u sent=%llu received=%llu mismatches=%llu "
              "tid_mismatches=%llu class_violations=%llu "
              "class_violation_channels=%u overflows=%llu idle_slots=%u "
              "violations=%d\n",
              (unsigned long long)cycles, kNumBlkInsts, kNumChans,
              kNumChanInsts, kNumSlots, (unsigned long long)t.sent,
              (unsigned long long)t.received,
              (unsigned long long)t.mismatches,
              (unsigned long long)t.tid_mismatches,
              (unsigned long long)t.class_violations,
              t.class_violation_channels,
              (unsigned long long)overflows, idle, ctx->errorCount());

  if (!trace.empty() && brk == "none") {
    // The bank's EV_CH_XFER events must carry exactly the payloads the
    // senders launched: same channel, same bits 63:0, same trace identity,
    // same multiset. That is what proves the bank's PAYLOAD and trace-
    // sideband wiring -- the negative controls only reach valid, credit and
    // stall, because Verilator is two-state and payload_known_when_due
    // cannot fire here.
    std::vector<std::tuple<uint16_t, uint32_t, uint32_t, uint64_t>> ev, want;
    ccv::EventReader r;
    if (!r.open(trace)) {
      std::fprintf(stderr, "cannot reread trace: %s\n", r.error().c_str());
      return 1;
    }
    ccv::Event e;
    while (r.next(e))
      if (e.event_id == ccv::EV_CH_XFER)
        ev.push_back({uint16_t(e.a), e.b, e.c, e.instr_uid});
    for (const Launched &l : launchedLog())
      want.push_back({l.chan, l.lo32, l.hi32, l.tid});
    std::sort(ev.begin(), ev.end());
    std::sort(want.begin(), want.end());
    std::vector<uint16_t> seen;
    for (auto &p : ev) seen.push_back(std::get<0>(p));
    seen.erase(std::unique(seen.begin(), seen.end()), seen.end());
    std::printf("XFER events=%zu launched=%zu match=%s channels_seen=%zu\n",
                ev.size(), want.size(), ev == want ? "yes" : "no",
                seen.size());
  }
  return 0;
}
