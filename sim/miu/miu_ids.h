//===-- miu_ids.h - the MIU model's DCU req_ids, as rtl/miu/miu_ids.sv -----===//
//
// The CCV_MIU_DCU_IDS req_ids toward DCU (160 in an 8-bit req_id; MA-34,
// Daniel's option B) in NS interleaved quarters, quarter s holding ids
// i * NS + s, as rtl/miu/miu_ids.sv (MI-48); lookup slot s takes only from
// quarter s, each quarter's next id preselected a cycle ahead (MI-28,
// MA rev 197: the model matches the RTL). Cycle by cycle, as the RTL:
// - take(s) takes slot s's preselected id; any(s) says whether it holds one.
// - At the cycle's end (tick), a quarter that took or held no id picks the
//   lowest id free during the cycle, but the one it held; then the takes
//   leave the free set and the frees due arrive in it.
// - A release is free three cycles after the response that releases it
//   lands (miu_rcap's capture at R2, miu_ids's read there and the release a
//   cycle on, free the cycle after), and a dropped lookup's id three cycles
//   after its take (miu_a2's drop flop a cycle on, held a cycle, free the
//   cycle after).
// A coverage cap (the environment's CCV_MIU_DCU_IDS = c, below the
// parameter) keeps each quarter's lowest c / NS ids and never frees the rest.
//===----------------------------------------------------------------------===//
#pragma once

#include <cstdint>
#include <cstdlib>
#include <deque>
#include <vector>

namespace ccv_miu {

class MiuIds {
public:
  static constexpr unsigned kFreeDelay = 3;   // cycles from a release or a drop's take

  /// `ids`: the ids the block holds (ccv::kMiuDcuIds), at most 1 << width
  /// and a multiple of `slots`.
  MiuIds(unsigned width, unsigned slots, unsigned ids, const char *cap_env)
      : n_(ids >= 1 && ids <= (1u << width) ? ids : 1u << width), ns_(slots), qn_(n_ / slots),
        free_(n_, true), pv_(slots, false), cap_(n_ / slots), pq_(slots, 0), took_(slots, false) {
    if (n_ % ns_ != 0 || qn_ < 2) std::abort();   // as miu_ids.sv's $error
    if (const char *v = cap_env ? std::getenv(cap_env) : nullptr; v && *v) {
      const unsigned c = unsigned(std::strtoul(v, nullptr, 10));
      if (c >= 1 && c < n_) {
        // Spread over the quarters, each keeping its lowest c / slots ids
        // (at least one), so every slot still reaches the pool.
        const unsigned per = c / ns_ ? c / ns_ : 1;
        cap_ = per;
        for (unsigned i = 0; i != n_; ++i)
          if (i / ns_ >= per) free_[i] = false;
      }
    }
    tick();   // the first picks, from the reset free set
  }
  unsigned slots() const { return ns_; }
  /// Pricing knob (MI-28): a slot may borrow another quarter's preselected
  /// id when its own holds none, MA's alternative to the quarter rule.
  bool borrow = false;
  bool own(unsigned s) const { return pv_[s] && !took_[s]; }
  bool any(unsigned s) const { return own(s) || (borrow && anyFree()); }
  bool anyFree() const {
    for (unsigned s = 0; s != ns_; ++s)
      if (own(s)) return true;
    return false;
  }
  /// Whether quarter s holds no preselected id.
  bool quarterEmpty(unsigned s) const { return !pv_[s]; }
  /// Slot s's preselected id (or, borrowing, the first quarter's that holds
  /// one), taken now; with drop, it is given back.
  unsigned take(unsigned s, bool drop = false) {
    if (!own(s))
      for (unsigned q = 0; q != ns_; ++q)
        if (own(q)) {
          s = q;
          break;
        }
    took_[s] = true;
    const unsigned id = idOf(s, pq_[s]);
    if (drop) pend_.push_back({id, kFreeDelay, true});
    return id;
  }
  void release(unsigned id) {
    if (id < n_) pend_.push_back({id, kFreeDelay, false});
  }
  /// Whether quarter s holds an id a drop has not yet given back.
  bool dropHeld(unsigned s) const {
    for (const Pend &p : pend_)
      if (p.drop && p.id % ns_ == s) return true;
    return false;
  }
  bool empty() const {
    for (unsigned i = 0; i != n_; ++i)
      if (i / ns_ < cap_ && !free_[i]) return false;
    return pend_.empty();
  }
  /// The cycle's end.
  void tick() {
    std::vector<bool> nf = free_;
    for (unsigned s = 0; s != ns_; ++s) {
      const unsigned id = idOf(s, pq_[s]);
      if (took_[s]) nf[id] = false;
      if (pv_[s] && !took_[s]) continue;
      bool v = false;
      unsigned q = 0;
      for (unsigned i = 0; i != qn_ && !v; ++i)
        if (free_[idOf(s, i)] && !(pv_[s] && i == pq_[s])) v = true, q = i;
      pv_[s] = v;
      pq_[s] = q;
      took_[s] = false;
    }
    for (auto it = pend_.begin(); it != pend_.end();)
      if (--it->left == 0) {
        nf[it->id] = true;
        it = pend_.erase(it);
      } else
        ++it;
    free_ = std::move(nf);
  }

  /// The ids the pool holds; whether `id` is one of them.
  unsigned size() const { return n_; }
  bool holds(unsigned id) const { return id < n_; }

private:
  /// Quarter s's i-th id (interleaved, as miu_ids.sv).
  unsigned idOf(unsigned s, unsigned i) const { return i * ns_ + s; }
  struct Pend {
    unsigned id, left;   // cycles until free
    bool drop;
  };
  unsigned n_, ns_, qn_;
  std::vector<bool> free_, pv_;
  unsigned cap_;
  std::vector<unsigned> pq_;
  std::vector<bool> took_;
  std::deque<Pend> pend_;
};

}  // namespace ccv_miu
