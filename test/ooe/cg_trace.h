//===-- cg_trace.h - the OOE live benches' scenarios ---------------===//
//
// tools/check-cg.py measures a module from a bench that runs three
// scenarios and dumps the DUT's ports to a VCD (docs/rtl-coding-style.md,
// "Local clock gating"). Every scenario is the model's own traffic
// (ooeTestScenario), so a bench drives and checks each exactly as it does
// any run: there is no stimulus a bench makes only for clock gating, and a
// difference fails the run, which check-cg refuses.
//
//   idle    a core with nothing launched;
//   medium  the random tests, DEC delivering one uop on one cycle in three;
//   high    the random tests as they are, the bench's ordinary run.
//
// --cg <scenario> <vcd> picks the scenario and dumps the VCD; nothing else
// changes. What a bench drives must be legal in every run, and the module's
// own assertions hold it to that (the input contract, in the RTL).
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

namespace ccv {
namespace ooe {
class Core;
struct Config;
} // namespace ooe
} // namespace ccv
int ooeTestScenario(const std::string &scenario, unsigned seeds, unsigned idle_cycles,
                    void (*pre)(const ccv::ooe::Core &), void (*post)(const ccv::ooe::Core &),
                    void (*cfg)(ccv::ooe::Config &));

struct CgRun {
  std::string scenario;               // empty: not a clock-gating run (high, the bench's seeds)
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0;
  bool on() const { return !scenario.empty(); }
  /// Cycles the idle scenario runs.
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
  /// Before the DUT goes: the writer holds the DUT's trace.
  void close() {
    if (vcd) vcd->close();
    vcd.reset();
  }
  /// The run: this scenario (high when not a clock-gating run, at the
  /// bench's seeds), with the bench's hooks and settings. Returns the
  /// model's failure count.
  int run(unsigned seeds, void (*pre)(const ccv::ooe::Core &), void (*post)(const ccv::ooe::Core &),
          void (*cfg)(ccv::ooe::Config &) = nullptr) const {
    return ooeTestScenario(on() ? scenario : "high", on() ? kSeeds : seeds, kIdleCycles, pre, post, cfg);
  }
};
