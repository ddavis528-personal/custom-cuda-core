//===-- main.cpp - ccv-skel: the Stage 3 skeleton ----------------------===//
//
// Runs the whole machine -- 45 block instances, 108 channel instances, 345
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
//   misgroup      every binding key names the wrong group (fet->dec's
//                 tier1_id); only the binding checker may fire
//
// --force-atomic runs every multi-slot channel as atomic (stubs AND checks)
// with ordinary traffic, which must be clean -- the partner to atomic-all.
//
// --kernel ORACLE replaces the exercisers with S1's functional stubs and runs
// the kernel ccv-sim recorded in ORACLE (test/golden/<kernel>/oracle.jsonl)
// to completion, then compares the final register file and memory with
// ccv-sim's. Its negative controls, each of which must fail the run:
//   corrupt-fetch  one instruction byte flipped between FET and DEC
//   corrupt-load   one lane's load data flipped between MIU and RCU
//   drop-store     a committed store discarded by MIU
//   corrupt-req-id the first EXB->MLC response answers the wrong req_id
//   itlb-double    FET has two ITLB misses outstanding
//   corrupt-disp   one load's displacement is off by 4 on its way OOE->MIU
//   drop-negate    guard negates dropped at issue: @!P0 resolves backwards
//   drop-pred-data RCU sends no pred_data: sel's selector reads as 0
//   corrupt-echo   MIU echoes the wrong phys_dst for one load
//   movi-in-lane   RCU sends movi/movi48 to the lanes, which must refuse them
//   srd-selector   DEC sees srd selector 2, which is unallocated
//   corrupt-ctaid  RAU sends OOE the wrong CTA index
//   conflate-pred  DEC names the guard as the predicate destination (pguard)
//===----------------------------------------------------------------------===//
#include "Vccv_skel_checkers.h"
#include "verilated.h"

#include "ccv/event.h"
#include "exerciser.h"
#include "kernel.h"
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

/// The bank's EV_CH_XFER events must carry exactly the payloads the senders
/// launched: same channel, same bits 63:0, same trace identity, same
/// multiset. That is what proves the bank's PAYLOAD and trace-sideband
/// wiring -- the negative controls only reach valid, credit and stall,
/// because Verilator is two-state and payload_known_when_due cannot fire.
int xferCheck(const std::string &trace) {
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
              ev.size(), want.size(), ev == want ? "yes" : "no", seen.size());
  return 0;
}

/// S1: a kernel through the machine, to completion.
int runKernel(const std::string &path, const std::string &brk, uint64_t cap,
              const std::string &trace, VerilatedContext &ctx,
              Vccv_skel_checkers &bank) {
  Kernel k;
  if (std::string e = k.orc.load(path); !e.empty()) {
    std::fprintf(stderr, "%s\n", e.c_str());
    return 1;
  }
  k.brk = brk;
  {
    const size_t sl = path.find_last_of('/');
    const std::string dir = sl == std::string::npos ? "." : path.substr(0, sl);
    const size_t s2 = dir.find_last_of('/');
    k.name = s2 == std::string::npos ? dir : dir.substr(s2 + 1);
  }
  Machine m(2, [&](int inst) { return makeKernelBlock(inst, k); });
  bank.pair_enable = 1;

  // Finished = the exit has retired, no block has work left, and nothing is
  // in flight on any slot -- then a short tail, so a late message would
  // still be seen by the bank.
  const uint64_t kReset = 2, kTail = 8;
  uint64_t c = 0, quiet = 0, finish = 0;
  bool finished = false;
  for (; c != cap && quiet != kTail; ++c) {
    bank.rst_n = c >= kReset;
    drive(bank, m);
    bank.clk = 0; bank.eval(); ctx.timeInc(5);
    bank.clk = 1; bank.eval(); ctx.timeInc(5);
    k.busy = 0;
    m.step(c < kReset);
    bool in_flight = false;
    for (unsigned s = 0; s != kNumSlots && !in_flight; ++s)
      in_flight = m.tx(s).sent() != m.rx(s).received();
    if (c >= kReset && k.exited && k.busy == 0 && !in_flight) {
      if (!finished) finish = c;
      finished = true;
      ++quiet;
    } else {
      quiet = 0;
      finished = false;
    }
  }
  bank.final();
  ccv::traceWriter().close();

  const KernelReport r = compareFinal(k);
  uint64_t overflows = 0;
  for (unsigned s = 0; s != kNumSlots; ++s) overflows += m.rx(s).overflows();
  std::printf("KERNEL name=%s finished=%d cycles=%llu retired=%llu "
              "issue_groups=%u order=%s gpr_mismatch=%u pred_mismatch=%u "
              "mem_mismatch=%u check_failures=%llu class_violations=%llu "
              "overflows=%llu channels_used=%u/%u violations=%d\n",
              k.name.c_str(), int(finished), (unsigned long long)finish,
              (unsigned long long)k.retired, k.orc.issue_groups,
              r.order_ok ? "ok" : "bad", r.gpr_mismatch, r.pred_mismatch,
              r.mem_mismatch, (unsigned long long)k.failures,
              (unsigned long long)k.class_violations,
              (unsigned long long)overflows, r.channels_used, kNumChans,
              ctx.errorCount());
  std::printf("UNUSED %s\n", r.unused.c_str());
  if (!trace.empty() && brk == "none") return xferCheck(trace);
  return 0;
}

/// A payload for a forced valid on `slot` that no payload check objects to:
/// zero, except a binding key naming the slot's own group. The wiring
/// controls force valids with no message behind them, and each is meant to
/// trip exactly one property.
Bits wellFormed(Machine &m, unsigned slot) {
  const ChanInst &ci = m.chanInstOf(slot);
  const ChanDesc &cd = kChans[ci.chan];
  Bits b(cd.bits);
  if (cd.bind_key >= 0) {
    const FieldDesc &f = cd.fields[cd.bind_key];
    b.set(f.lsb, f.width, (slot - ci.slot_base) / cd.bind_group);
  }
  return b;
}

} // namespace

int main(int argc, char **argv) {
  uint64_t cycles = 2000, seed = 1;
  std::string trace, brk = "none", dump_wiring, kernel;
  bool cycles_given = false;
  bool force_atomic = false;
  for (int i = 1; i < argc; ++i) {
    auto arg = [&](const char *f) { return !std::strcmp(argv[i], f) && i + 1 < argc; };
    if (arg("--cycles"))     { cycles = std::strtoull(argv[++i], nullptr, 0); cycles_given = true; }
    else if (arg("--kernel")) kernel = argv[++i];
    else if (arg("--seed"))  seed = std::strtoull(argv[++i], nullptr, 0);
    else if (arg("--trace")) trace = argv[++i];
    else if (arg("--break")) brk = argv[++i];
    else if (arg("--dump-wiring")) dump_wiring = argv[++i];
    else if (!std::strcmp(argv[i], "--force-atomic")) force_atomic = true;
  }
  // Wiring controls silence organic traffic so nothing else can fire; the
  // semantic ones (misorder, wrong-class) need traffic to be wrong about.
  const bool breaking = brk == "phantom-all" || brk == "stall-all" ||
                        brk == "atomic-all" || brk == "lockstep-all";
  const bool kbreak = brk == "corrupt-fetch" || brk == "corrupt-load" ||
                      brk == "drop-store" || brk == "corrupt-req-id" ||
                      brk == "itlb-double" || brk == "corrupt-disp" ||
                      brk == "drop-negate" || brk == "drop-pred-data" ||
                      brk == "corrupt-echo" || brk == "movi-in-lane" ||
                      brk == "srd-selector" || brk == "corrupt-ctaid" ||
                      brk == "conflate-pred";
  if (kbreak && kernel.empty()) {
    std::fprintf(stderr, "--break %s needs --kernel\n", brk.c_str());
    return 2;
  }
  if (brk != "none" && !breaking && brk != "misorder" &&
      brk != "wrong-class" && brk != "misbind" && brk != "misgroup" &&
      !kbreak) {
    std::fprintf(stderr, "unknown --break mode %s\n", brk.c_str());
    return 2;
  }

  // The skeleton's connectivity, one line per slot: channel, copy, slot,
  // producer instance, consumer instance. tools/check-top-wiring.py compares
  // it with connectivity EXTRACTED from the elaborated SV top, so the two
  // realisations of the wiring are checked against each other. The instance
  // naming rule is implemented here separately from tools/gen-top.py on
  // purpose.
  if (!dump_wiring.empty()) {
    auto name = [](int16_t idx) -> std::string {
      if (idx < 0) return "EXTERNAL";
      const BlkInst &b = kBlkInsts[idx];
      unsigned same = 0;
      for (const BlkInst &o : kBlkInsts) same += o.type == b.type;
      char buf[64];
      if (same == 1) std::snprintf(buf, sizeof buf, "u_%s", blkName(b.type));
      else std::snprintf(buf, sizeof buf, "u_%s_%02u", blkName(b.type), b.index);
      return buf;
    };
    std::FILE *f = std::fopen(dump_wiring.c_str(), "w");
    if (!f) { std::fprintf(stderr, "cannot write %s\n", dump_wiring.c_str()); return 1; }
    for (const ChanInst &ci : kChanInsts)
      for (unsigned s = 0; s != kChans[ci.chan].rate; ++s)
        std::fprintf(f, "%s %u %u %s %s\n", kChans[ci.chan].name, ci.inst, s,
                     name(ci.src).c_str(), name(ci.dst).c_str());
    std::fclose(f);
    return 0;
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

  if (!kernel.empty()) {
    if (brk != "none" && !kbreak) {
      std::fprintf(stderr, "--break %s is an S0 control; not with --kernel\n", brk.c_str());
      return 2;
    }
    return runKernel(kernel, brk, cycles_given ? cycles : 20000, trace, *ctx, *bank);
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
  cfg.misgroup = brk == "misgroup";
  bank->force_atomic = cfg.force_atomic;
  // The exerciser's traffic is synthetic: it sends requests and responses
  // independently, so a request/response pairing cannot hold (see
  // ccv_outstanding_checker). The functional stubs turn it on.
  bank->pair_enable = 0;
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
        for (unsigned k = 0; k != kNumSlots; ++k) m.tx(k).forceValid(wellFormed(m, k));
      // atomic-all: a whole group (legal), then ONE slot's credit, then ONE
      // slot's valid. Each is legal for the credit checker -- slot 0 has a
      // message outstanding, and credit to spare -- so only the atomic
      // checks may fire, and each must, on every multi-slot instance.
      if (brk == "atomic-all")
        for (const ChanInst &ci : kChanInsts) {
          if (kChans[ci.chan].rate < 2) continue;
          if (c == kBreakAt)
            for (unsigned s = 0; s != kChans[ci.chan].rate; ++s)
              m.tx(ci.slot_base + s).forceValid(wellFormed(m, ci.slot_base + s));
          if (c == kBreakAt + 3) m.rx(ci.slot_base).forceCredit();
          if (c == kBreakAt + 5) m.tx(ci.slot_base).forceValid(wellFormed(m, ci.slot_base));
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

  if (!trace.empty() && brk == "none") return xferCheck(trace);
  return 0;
}
