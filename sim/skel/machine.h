//===-- machine.h - the whole machine, wired from the schema ----*- C++ -*-===//
//
// 45 block instances and 108 channel instances, built from the generated
// wiring tables rather than listed by hand: a connection that exists here
// and not in the RTL would be a generation error, not a typo.
//
// A Block is the SWAP BOUNDARY (strategy §1, §8 Stage 4d). It sees only its
// own channel ends -- Senders for the slots it drives, Receivers for the ones
// it consumes -- and one cycle() call per clock. Whatever sits behind that,
// a fixed-latency stub, the Stage 4b timing-model internals, or a Verilated
// RTL block, the rest of the machine cannot tell.
//===----------------------------------------------------------------------===//
#ifndef CCV_SKEL_MACHINE_H
#define CCV_SKEL_MACHINE_H

#include "channel.h"
#include "ccv_skel_wiring.h"

#include <functional>
#include <memory>
#include <vector>

namespace ccv {
namespace skel {

class Block {
public:
  struct Out { const ChanInst *ci; unsigned slot; Sender *tx; };
  struct In  { const ChanInst *ci; unsigned slot; Receiver *rx; };

  explicit Block(int inst) : inst_(inst) {}
  virtual ~Block() = default;

  /// One clock. Read only `cur` (via the ports), write only `nxt`.
  virtual void cycle(uint64_t now) = 0;

  /// kBlkInsts index, or -1 for the testbench's external end.
  int inst() const { return inst_; }
  std::vector<Out> outs;
  std::vector<In> ins;

private:
  int inst_;
};

class Machine {
public:
  using Factory = std::function<std::unique_ptr<Block>(int inst)>;

  /// `depth` is the credit depth of every slot: the round trip, 2 today.
  Machine(unsigned depth, const Factory &make);

  /// Advance one cycle. Blocks run only out of reset. `inject`, if given,
  /// runs after the blocks and before the commit -- the only place a
  /// negative control can override what a block drove.
  void step(bool in_reset, const std::function<void()> &inject = {});

  uint64_t now() const { return now_; }
  std::vector<Slot> &slots() { return slots_; }
  Sender &tx(unsigned slot) { return *tx_[slot]; }
  Receiver &rx(unsigned slot) { return *rx_[slot]; }
  std::vector<std::unique_ptr<Block>> &blocks() { return blocks_; }

  /// kChanInsts entry that owns a slot, and the slot's index within it.
  const ChanInst &chanInstOf(unsigned slot) const { return *owner_[slot]; }

private:
  std::vector<Slot> slots_;
  std::vector<std::unique_ptr<Sender>> tx_;
  std::vector<std::unique_ptr<Receiver>> rx_;
  std::vector<const ChanInst *> owner_;
  std::vector<std::unique_ptr<Block>> blocks_;   ///< kNumBlkInsts, then TB end
  uint64_t now_ = 0;
};

/// Checks the generated field table tiles every payload exactly -- no gap,
/// no overlap. A layout bug here would reach a swapped-in RTL block as
/// silently wrong fields. Returns the number of channels that fail.
unsigned checkFieldTiling();

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_MACHINE_H
