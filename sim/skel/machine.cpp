//===-- machine.cpp - wiring --------------------------------------------===//
#include "machine.h"

#include <cstdio>

namespace ccv {
namespace skel {

Machine::Machine(unsigned depth, const Factory &make) {
  slots_.reserve(kNumSlots);
  owner_.resize(kNumSlots, nullptr);
  for (const ChanInst &ci : kChanInsts) {
    const ChanDesc &cd = kChans[ci.chan];
    Bits lead(cd.bits);
    for (unsigned f = 0; f != cd.nfields; ++f)
      if (cd.fields[f].lead)
        for (uint32_t b = 0; b != cd.fields[f].width; ++b)
          lead.setBit(cd.fields[f].lsb + b, true);
    for (unsigned s = 0; s != cd.rate; ++s) {
      slots_.emplace_back(cd.bits, lead, ci.stages);
      owner_[ci.slot_base + s] = &ci;
    }
  }
  // Senders and receivers hold references into slots_, so it must not
  // reallocate from here on.
  // A repeated link's round trip is 2N longer, and so is its credit depth
  // (docs/physical.md): the sender's credits and the receiver's buffer.
  for (unsigned k = 0; k != kNumSlots; ++k) {
    const unsigned d = depth + 2 * owner_[k]->stages;
    tx_.push_back(std::make_unique<Sender>(slots_[k], d));
    rx_.push_back(std::make_unique<Receiver>(slots_[k], d));
  }

  for (unsigned b = 0; b != kNumBlkInsts; ++b)
    blocks_.push_back(make(int(b)));
  blocks_.push_back(make(-1));            // the testbench end of EXTERNAL

  auto blockAt = [&](int16_t idx) -> Block & {
    return idx < 0 ? *blocks_.back() : *blocks_[idx];
  };
  for (const ChanInst &ci : kChanInsts) {
    const ChanDesc &cd = kChans[ci.chan];
    for (unsigned s = 0; s != cd.rate; ++s) {
      const unsigned k = ci.slot_base + s;
      blockAt(ci.src).outs.push_back({&ci, s, tx_[k].get()});
      blockAt(ci.dst).ins.push_back({&ci, s, rx_[k].get()});
    }
  }
}

void Machine::step(bool in_reset, const std::function<void()> &inject) {
  for (Slot &s : slots_)
    s.begin();
  if (!in_reset)
    for (auto &b : blocks_)
      b->cycle(now_);
  if (inject)
    inject();
  for (Slot &s : slots_)
    s.commit();
  ++now_;
}

unsigned checkFieldTiling() {
  unsigned bad = 0;
  for (const ChanDesc &cd : kChans) {
    std::vector<bool> used(cd.bits, false);
    bool ok = true;
    for (unsigned f = 0; f != cd.nfields; ++f) {
      const FieldDesc &fd = cd.fields[f];
      for (uint32_t b = fd.lsb; b != fd.lsb + fd.width; ++b) {
        if (b >= cd.bits || used[b]) { ok = false; break; }
        used[b] = true;
      }
    }
    for (bool u : used)
      ok = ok && u;
    if (!ok) {
      std::fprintf(stderr, "field table does not tile %s\n", cd.name);
      ++bad;
    }
  }
  return bad;
}

} // namespace skel
} // namespace ccv
