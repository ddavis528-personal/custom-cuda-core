//===-- exerciser.cpp ---------------------------------------------------===//
#include "exerciser.h"

#include <cstdio>

namespace ccv {
namespace skel {

namespace {

uint64_t splitmix(uint64_t x) {
  x += 0x9e3779b97f4a7c15ull;
  x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9ull;
  x = (x ^ (x >> 27)) * 0x94d049bb133111ebull;
  return x ^ (x >> 31);
}

class Rng {
public:
  explicit Rng(uint64_t s) : s_(splitmix(s)) {}
  double uniform() { return double(next() >> 11) * (1.0 / 9007199254740992.0); }
  uint64_t next() { return s_ = splitmix(s_); }
private:
  uint64_t s_;
};

ExerciseTotals g_totals;
std::vector<Launched> g_launched;
bool g_draining = false;

class Exerciser : public Block {
public:
  Exerciser(int inst, const ExerciseCfg &cfg)
      : Block(inst), cfg_(cfg),
        rng_(cfg.seed * 1000003ull + uint64_t(inst + 1)) {}

  void cycle(uint64_t) override {
    if (txseq_.size() != outs.size()) txseq_.assign(outs.size(), 0);
    if (rxseq_.size() != ins.size()) {
      rxseq_.assign(ins.size(), 0);
      stall_left_.assign(ins.size(), 0);
    }

    for (size_t i = 0; i != ins.size(); ++i) {
      In &p = ins[i];
      p.rx->cycle();
      if (!p.rx->empty() && rng_.uniform() < cfg_.p_pop) {
        const Bits want = expectedPayload(*p.ci, p.slot, rxseq_[i]);
        if (p.rx->front() != want) {
          if (g_totals.mismatches < 5)
            std::fprintf(stderr, "MISMATCH %s[%u] slot %u message %llu\n",
                         kChans[p.ci->chan].name, p.ci->inst, p.slot,
                         (unsigned long long)rxseq_[i]);
          ++g_totals.mismatches;
        }
        p.rx->pop();
        ++rxseq_[i];
        ++g_totals.received;
      }
      if (stall_left_[i] == 0 && rng_.uniform() < cfg_.p_stall)
        stall_left_[i] = 1 + unsigned(rng_.next() % 3);
      if (stall_left_[i] != 0) {
        p.rx->stall(true);
        --stall_left_[i];
      }
    }

    for (size_t i = 0; i != outs.size(); ++i) {
      Out &p = outs[i];
      const bool want = !g_draining && rng_.uniform() < cfg_.p_send;
      if (want && p.tx->canSend()) {
        const Bits msg = expectedPayload(*p.ci, p.slot, txseq_[i]);
        if (p.tx->cycle(true, msg)) {
          const uint32_t n = msg.size();
          g_launched.push_back(
              {p.ci->chan, uint32_t(msg.get(0, n < 32 ? n : 32)),
               uint32_t(n <= 32 ? 0 : msg.get(32, n < 64 ? n - 32 : 32))});
          ++txseq_[i];
          ++g_totals.sent;
        }
      } else {
        p.tx->cycle(false, Bits());
      }
    }
  }

private:
  ExerciseCfg cfg_;
  Rng rng_;
  std::vector<uint64_t> txseq_, rxseq_;
  std::vector<unsigned> stall_left_;
};

} // namespace

Bits expectedPayload(const ChanInst &ci, unsigned slot, uint64_t seq) {
  const ChanDesc &cd = kChans[ci.chan];
  Bits b(cd.bits);
  const uint64_t key =
      splitmix((uint64_t(ci.chan) << 48) ^ (uint64_t(ci.inst) << 40) ^
               (uint64_t(slot) << 32) ^ seq);
  for (unsigned f = 0; f != cd.nfields; ++f) {
    const FieldDesc &fd = cd.fields[f];
    for (uint32_t off = 0; off < fd.width; off += 64) {
      const uint32_t w = fd.width - off < 64 ? fd.width - off : 64;
      b.set(fd.lsb + off, w, splitmix(key ^ (uint64_t(f) << 20) ^ off));
    }
  }
  return b;
}

std::unique_ptr<Block> makeExerciser(int inst, const ExerciseCfg &cfg) {
  return std::make_unique<Exerciser>(inst, cfg);
}

ExerciseTotals exerciseTotals() { return g_totals; }
void setDraining(bool on) { g_draining = on; }
const std::vector<Launched> &launchedLog() { return g_launched; }

} // namespace skel
} // namespace ccv
