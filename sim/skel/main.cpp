//===-- main.cpp - ccv-skel: the Stage 3 skeleton ----------------------===//
//
// Runs the whole machine -- 45 block instances, 102 channel instances, 339
// credited slots -- with the SystemVerilog interface checker Verilated in at
// every slot. The bank is clocked with each cycle's channel signals, so the
// skeleton is judged by the same checker the RTL will be, and the
// load-bearing EV_CH_XFER stream comes from that same code.
//
//   ccv-skel [--cycles N] [--seed S] [--trace FILE] [--break MODE]
//
// --break exists to prove the bank is wired, slot by slot, to what it claims
// to check. A clean run from a bank that is not connected looks exactly like
// a clean run from one that is; a violation on EVERY slot, each reported by
// its own checker instance, does not.
//   phantom-all   every receiver returns a credit for nothing   (credit bit)
//   stall-all     every receiver stalls, every sender sends     (stall, valid)
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
  for (int i = 1; i < argc; ++i) {
    auto arg = [&](const char *f) { return !std::strcmp(argv[i], f) && i + 1 < argc; };
    if (arg("--cycles"))     cycles = std::strtoull(argv[++i], nullptr, 0);
    else if (arg("--seed"))  seed = std::strtoull(argv[++i], nullptr, 0);
    else if (arg("--trace")) trace = argv[++i];
    else if (arg("--break")) brk = argv[++i];
  }
  const bool breaking = brk != "none";
  if (breaking && brk != "phantom-all" && brk != "stall-all") {
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
  if (breaking)
    cfg.p_send = 0.0;     // no organic traffic to muddy the control
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
  std::printf("SKEL cycles=%llu blocks=%u chan_insts=%u slots=%u sent=%llu "
              "received=%llu mismatches=%llu overflows=%llu idle_slots=%u "
              "violations=%d\n",
              (unsigned long long)cycles, kNumBlkInsts, kNumChanInsts,
              kNumSlots, (unsigned long long)t.sent,
              (unsigned long long)t.received,
              (unsigned long long)t.mismatches,
              (unsigned long long)overflows, idle, ctx->errorCount());

  if (!trace.empty() && !breaking) {
    // The bank's EV_CH_XFER events must carry exactly the payloads the
    // senders launched: same channel, same bits 63:0, same multiset. That
    // is what proves the bank's PAYLOAD wiring -- the negative controls only
    // reach valid, credit and stall, because Verilator is two-state and
    // payload_known_when_due cannot fire here.
    std::vector<std::tuple<uint16_t, uint32_t, uint32_t>> ev, want;
    ccv::EventReader r;
    if (!r.open(trace)) {
      std::fprintf(stderr, "cannot reread trace: %s\n", r.error().c_str());
      return 1;
    }
    ccv::Event e;
    while (r.next(e))
      if (e.event_id == ccv::EV_CH_XFER)
        ev.push_back({uint16_t(e.a), e.b, e.c});
    for (const Launched &l : launchedLog())
      want.push_back({l.chan, l.lo32, l.hi32});
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
