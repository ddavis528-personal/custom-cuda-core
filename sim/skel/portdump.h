//===-- portdump.h - one block's ports, cycle by cycle, as a VCD -*- C++ -*-===//
//
// RA-34: the stimulus for a block's clock-gating units is a checked replay
// of what the block saw and drove in a skeleton run (docs/rcu-impl.md,
// "Clock-gating stimulus"). This writes one block instance's ports, named
// as rtl/top/ports/ccv_<blk>_ports.svh names them, one sample a cycle, in a
// VCD that tools/check-cg.py's read_vcd takes as it takes a bench's: scope
// u_<blk>[_NN], clock core_clk, each value as it stands before the edge
// that ends its cycle.
//
// What the dump shows is the block's own view of each port:
//   - an input channel's valid and payload as they reach the block, after
//     any repeater stages and the wrapper's boundary flop (a flopped
//     receiving end, bnd_rx); its credit and stall from the block's own
//     registers;
//   - an output channel's valid and payload from the block's output
//     register; at a flopped sending end (bnd_src) the wrapper's flop
//     replaces that register (the hidden-stage rule), so the port carries
//     the value one cycle before the flop does, which is the next sample's;
//   - the kill fabric as the block reads and drives it (a gather's end gets
//     every source's copy, source i at bits [i*w +: w]);
//   - each channel instance's wake, which no stub drives (Q-33): DERIVED as
//     the latest legal one, high exactly CCV_WAKE_LAT cycles before each
//     valid at that port. A gating block replayed with it is woken in time
//     for every message and never earlier.
// Not modelled by the skeleton, so absent: the CSR ports (no CSR traffic;
// a replay ties them to their idle 0), and the CCV_CHECK / CCV_TRACE ports.
// tools/check-port-dump.py holds the names and widths to the ports file.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_PORTDUMP_H
#define CCV_SKEL_PORTDUMP_H

#include "machine.h"

#include <cstdio>
#include <deque>
#include <string>
#include <vector>

namespace ccv {
namespace skel {

class PortDump {
public:
  /// `spec` is INST=FILE, INST a block instance as the SV top names it,
  /// with or without its u_ (rcu, lane_03, u_miu). Returns an error, or "".
  std::string open(const std::string &spec, const std::string &comment = "");
  bool active() const { return f_ != nullptr; }
  /// The ports during the cycle about to run: called at the start of
  /// Machine::step, before any block reads them.
  void sample(Machine &m, bool in_reset);
  /// Writes what the lookahead still holds (no valid after the run's end,
  /// so no wake) and closes the file.
  void close();
  ~PortDump() { close(); }

private:
  enum Src : uint8_t { kFwdValid, kFwdPayload, kBack, kFab, kGather, kWake, kRst };
  struct Var {
    std::string name, id;
    uint32_t width;
    Src src;
    unsigned slot = 0;      ///< kFwd*, kBack: the slot; kFab, kGather: fabric slot
    bool credit = false;    ///< kBack: credit, else stall
    bool at_src = false;    ///< kFwd*, kBack: the block is the slot's sender
    bool shift = false;     ///< kFwd*: a flopped sending end (bnd_src)
    unsigned n = 1;         ///< kGather: sources
    std::vector<unsigned> slots;   ///< kWake: the vars of the instance's valids
  };
  using Sample = std::vector<std::string>;   ///< one value per var, MSB first

  Sample take(Machine &m, bool in_reset) const;
  void emit(size_t i);
  void build();

  std::FILE *f_ = nullptr;
  int inst_ = -1;
  std::string scope_, comment_;
  std::vector<Var> vars_;
  std::deque<Sample> la_;     ///< lookahead: samples not yet written
  std::vector<std::string> last_;
  uint64_t t_ = 0;            ///< cycles written
};

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_PORTDUMP_H
