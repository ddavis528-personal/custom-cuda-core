//===-- cg_trace.h - clock-gating scenarios for the OOE live benches --===//
//
// tools/check-cg.py measures a module from a bench that runs three
// scenarios and dumps the DUT's ports to a VCD (docs/rtl-coding-style.md,
// "Local clock gating"). The OOE benches already drive their module from
// the live model; with --cg <scenario> <vcd> they do so as a unit's bench:
//
//   idle    the module held in reset a few cycles, then given no work: its
//           control inputs quiet, its data inputs still;
//   medium  the model's traffic, each model cycle followed by two idle
//           cycles, so about a third of the cycles carry work;
//   high    the model's traffic, one model cycle a clock.
//
// In this mode a bench compares nothing: its idle cycles are not model
// cycles. What it must do is keep its inputs legal (an idle cycle is one
// in which nothing arrives), and change a data input only with the message
// it belongs to.
//===----------------------------------------------------------------------===//
#pragma once
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <string>

struct CgRun {
  std::string scenario;               // empty: not a clock-gating run
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0;
  bool on() const { return !scenario.empty(); }
  bool idle() const { return scenario == "idle"; }
  /// Idle cycles a bench inserts after each model cycle.
  unsigned gaps() const { return scenario == "medium" ? 2 : 0; }
  /// Cycles the idle scenario runs, after its reset.
  static constexpr unsigned kIdleCycles = 3000;
  /// The random tests' seeds a medium or high scenario runs: two, since
  /// odd seeds run the bypass-group configuration, which some benches do
  /// not follow.
  static constexpr unsigned kSeeds = 2;

  /// --cg <scenario> <vcd> anywhere in argv: the scenario, and the VCD path.
  bool parse(int argc, char **argv, std::string &path) {
    for (int i = 1; i + 2 < argc; ++i)
      if (!std::strcmp(argv[i], "--cg")) {
        scenario = argv[i + 1];
        path = argv[i + 2];
        if (scenario != "idle" && scenario != "medium" && scenario != "high") {
          std::fprintf(stderr, "cg: unknown scenario %s\n", scenario.c_str());
          std::exit(2);
        }
        return true;
      }
    return false;
  }
  /// Before the DUT is built.
  static void prepare(VerilatedContext &ctx) { ctx.traceEverOn(true); }
  template <typename D> void open(D &dut, const std::string &path) {
    vcd = std::make_unique<VerilatedVcdC>();
    dut.trace(vcd.get(), 99);
    vcd->open(path.c_str());
  }
  /// After each eval of a clock phase.
  void dump() {
    if (vcd) vcd->dump(t);
    t += 5;
  }
  void close() {
    if (vcd) vcd->close();
  }
};
