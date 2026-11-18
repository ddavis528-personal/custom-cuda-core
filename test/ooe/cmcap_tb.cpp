//===-- cmcap_tb.cpp - ooe_cmcap against the live model's completions ---===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp) and, after
// every core cycle, drives ooe_cmcap with that cycle's completions as the
// ROB takes them (Core::robLog().cmpl, the ROB tags): their lead valid a
// cycle before their payload, as ccv_miu_ooe_cmpl carries them. Each
// output must be its input a cycle later: the slices' lead (cv) the lead's,
// and every slice's payload the payload's, in its valid lanes.
//
// Negative controls (CMCAP_CONTROL=<name>) perturb the drive and must be
// caught: no-lead (the lead is never driven, so nothing is captured) and
// late-pay (the payload is driven a cycle late). Slice 4: lead_fault (fv)
// and the fault's fields likewise, in the lanes with a fault; no-fault-lead
// never drives lead_fault.
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h).
// Usage: cmcap_tb [seeds] | cmcap_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_cmcap.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Core;

int ooeTestDirectedHooked(void (*hook)(const Core &));

namespace {
constexpr unsigned NC = CM_NC, PW = CM_PW, R = CM_R;
std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_cmcap> dut;
std::string control;
unsigned long long cycles = 0, cores = 0, cmpls = 0, compared = 0, mismatches = 0;
uint64_t current = ~0ull;
CgRun cg;   // --cg <scenario> <vcd>: a clock-gating unit's bench (cg_trace.h)

template <typename T> void setField(T &w, unsigned lo, unsigned n, uint64_t v) {
  for (unsigned i = 0; i != n; ++i) {
    const bool b = (v >> i) & 1u;
    if constexpr (sizeof(T) <= 8) {
      if (b) w |= (T(1) << (lo + i)); else w &= ~(T(1) << (lo + i));
    } else {
      const unsigned k = lo + i;
      if (b) w[k / 32] |= (1u << (k % 32)); else w[k / 32] &= ~(1u << (k % 32));
    }
  }
}
template <typename T> uint64_t getField(const T &w, unsigned lo, unsigned n) {
  uint64_t v = 0;
  for (unsigned i = 0; i != n; ++i) {
    const unsigned k = lo + i;
    bool b;
    if constexpr (sizeof(T) <= 8) b = (w >> k) & 1u;
    else b = (w[k / 32] >> (k % 32)) & 1u;
    v |= uint64_t(b) << i;
  }
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

void fail(const char *what, unsigned k) {
  if (++mismatches <= 5) std::fprintf(stderr, "cycle %llu: %s (lane %u)\n", cycles, what, k);
}

// The drive's history: each step's completions (a step's payload is driven
// a step after its lead), and what the outputs must show.
std::vector<unsigned> pay_now, pay_prev;   // this step's payload, and the last's
unsigned lead_prev = 0;                    // the lead the last step's completions call for
using CF = Core::RobLog::CmplFault;
std::vector<CF> fpay_now, fpay_prev;       // their fault fields
unsigned flead_prev = 0;
constexpr unsigned CW = 4, FW = CW + 32 + 64;
void setFault(unsigned k, const CF &f) {
  setField(dut->cmpl_f_cq01h, k * FW, CW, f.cause);
  setField(dut->cmpl_f_cq01h, k * FW + CW, 32, f.lanes);
  setField(dut->cmpl_f_cq01h, k * FW + CW + 32, 64, f.addr);
}

void hook(const Core &c) {
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    dut->cmpl_l_cq00h = 0;
    dut->cmpl_lf_cq00h = 0;
    dut->ooe_rst_r00h = 1;
    tick();
    tick();
    dut->ooe_rst_r00h = 0;
    pay_now.clear();
    pay_prev.clear();
    lead_prev = 0;
    fpay_now.clear();
    fpay_prev.clear();
    flead_prev = 0;
  }
  ++cycles;
  // This model cycle's completions: their lead now, their payload at the
  // next step, with the last step's completions' payload now.
  std::vector<unsigned> cm(c.robLog().cmpl.begin(), c.robLog().cmpl.end());
  if (cm.size() > NC) cm.resize(NC);
  cmpls += cm.size();
  unsigned want_lead = 0;
  for (unsigned k = 0; k != cm.size(); ++k) want_lead |= 1u << k;
  const unsigned lead = control == "no-lead" ? 0 : want_lead;
  const std::vector<unsigned> &pay = control == "late-pay" ? pay_prev : pay_now;
  for (unsigned k = 0; k != NC; ++k) setField(dut->cmpl_pay_cq01h, k * PW, PW, k < pay.size() ? pay[k] : 0);
  dut->cmpl_l_cq00h = lead;
  std::vector<CF> cf(c.robLog().cmplf.begin(), c.robLog().cmplf.end());
  if (cf.size() > NC) cf.resize(NC);
  unsigned want_flead = 0;
  for (unsigned k = 0; k != cf.size(); ++k) want_flead |= unsigned(cf[k].fault) << k;
  dut->cmpl_lf_cq00h = control == "no-fault-lead" ? 0 : want_flead;
  const std::vector<CF> &fpay = control == "late-pay" ? fpay_prev : fpay_now;
  for (unsigned k = 0; k != NC; ++k) setFault(k, k < fpay.size() ? fpay[k] : CF{});
  // Before the edge: the outputs hold the last step's lead (cv) and the
  // payload driven a step ago, for the lead before it.
  const unsigned cv = dut->cv_cq01h;
  if (cv != lead_prev) fail("cv is not the last step's lead", 0);
  if (unsigned(dut->fv_cq01h) != flead_prev) fail("fv is not the last step's lead_fault", 0);
  ++compared;
  tick();
  // After the edge: each slice's payload is what was driven before it, in
  // the lanes the lead it followed named.
  for (unsigned r = 0; r != R; ++r)
    for (unsigned k = 0; k != NC; ++k) {
      if (!((lead_prev >> k) & 1u)) continue;
      ++compared;
      const uint64_t want = k < pay_now.size() ? pay_now[k] : 0;
      if (getField(dut->pay_cq02h, (r * NC + k) * PW, PW) != want) fail("a slice's payload is not the one driven", k);
    }
  for (unsigned k = 0; k != NC; ++k) {
    if (!((flead_prev >> k) & 1u)) continue;
    ++compared;
    const CF want = k < fpay_now.size() ? fpay_now[k] : CF{};
    if (getField(dut->f_cq02h, k * FW, CW) != want.cause || getField(dut->f_cq02h, k * FW + CW, 32) != want.lanes ||
        getField(dut->f_cq02h, k * FW + CW + 32, 64) != want.addr)
      fail("a fault's fields are not the ones driven", k);
  }
  lead_prev = want_lead;
  pay_prev = pay_now;
  pay_now = cm;
  flead_prev = want_flead;
  fpay_prev = fpay_now;
  fpay_now = cf;
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("CMCAP_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_cmcap>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  // The directed tests too, outside a clock-gating run: the MIU faults
  // (testMemFault) are among them, and the random tests have none.
  const int model_fails = (cg.on() ? 0 : ooeTestDirectedHooked(hook)) + cg.run(seeds, nullptr, hook);
  cg.close();
  dut->final();
  std::printf("cmcap_tb control=%s seeds=%u cores=%llu cycles=%llu completions=%llu compared=%llu "
              "mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, cmpls, compared, mismatches,
              model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
