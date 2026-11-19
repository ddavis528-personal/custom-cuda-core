//===-- miu_res.h - the MIU model's resources, apart from the ports -------===//
//
// The structures MA's Phase 1 architecture sizes (MIU tab, "MA's Phase 1
// architecture"), each a small class with no skeleton dependency, so its
// unit tests (miu_test.cpp) hold it to the spec's sentence alone:
//
//   MemopCredits  the memop queue's credits (MA-5): 10 a slot over one
//                 40-entry queue, each entry returning its credit on its
//                 arrival slot through a per-slot owed count, one a slot a
//                 cycle; the drain guard's withheld credit (MA-11).
//   BankCredits   DCU's per-bank credits (MA-24, MA-25): QDEPTH lookup
//                 entries and STDATA store-data entries a bank, reset full.
//   Tlb           32 entries, fully associative, LRU (MA-8).
//   Walker        one page-table walker shared with FET's ITLB (MA-8), one
//                 walk at a time, each level one dependent DCU read (MI-2's
//                 proposed default until MA answers).
//
// Sizes are constructor arguments: the block passes the generated params
// where they exist and the named defaults below where TI has not added
// them yet (miu-impl.md section 7).
//===----------------------------------------------------------------------===//
#pragma once

#include <algorithm>
#include <cstdint>
#include <deque>
#include <vector>

namespace ccv {
namespace miu {

/// Defaults for what the params do not hold yet (MA-25, MA-26, MI-2). Each
/// moves to its generated parameter when TI adds it.
struct Pending {
  static constexpr unsigned kBankQdepth = 16;   ///< CCV_DCU_BANK_QDEPTH (MA-25)
  static constexpr unsigned kBankStdata = 12;   ///< CCV_DCU_BANK_STDATA (MA-25)
  static constexpr unsigned kWayPredBits = 5;   ///< CCV_DCU_WAYPRED_BITS (MA-26)
  static constexpr unsigned kTlbEntries = 32;   ///< MIU tab, Structures (MA-8)
  static constexpr unsigned kWalkLevels = 2;    ///< MI-2's proposal
  static constexpr uint64_t kWalkBase = uint64_t(0xF0) << 40;   ///< MI-2: a table region no kernel touches
  static constexpr unsigned kDrainWait = 16;    ///< N_drain (MA-11)
};

/// MA-5's memop credits. One physical queue of slots x per_slot entries;
/// each entry records its arrival slot and frees there. Freed entries are
/// owed on their slot and go back one a cycle a slot (a credit return is a
/// 1-bit pulse a slot a cycle). The drain guard withholds one owed credit
/// while it is set.
class MemopCredits {
public:
  MemopCredits(unsigned slots, unsigned per_slot)
      : per_(per_slot), held_(slots, 0), owed_(slots, 0) {}

  unsigned slots() const { return unsigned(held_.size()); }
  unsigned perSlot() const { return per_; }
  unsigned held(unsigned s) const { return held_[s]; }
  unsigned owed(unsigned s) const { return owed_[s]; }
  unsigned heldTotal() const {
    unsigned n = 0;
    for (unsigned h : held_) n += h;
    return n;
  }

  /// A memop takes an entry on its arrival slot. False: more entries than
  /// the slot has credits, which OOE's credit makes impossible.
  bool arrive(unsigned s) {
    if (held_[s] + owed_[s] >= per_) return false;
    ++held_[s];
    return true;
  }
  /// The entry frees: its credit is owed on its arrival slot. False: the
  /// slot held no entry.
  bool free(unsigned s) {
    if (!held_[s]) return false;
    --held_[s];
    ++owed_[s];
    return true;
  }
  /// One cycle of returns: bit s set when slot s returns a credit now. With
  /// `withhold`, one owed credit stays back (the drain guard, MA-11): the
  /// lowest slot owing one keeps it while the guard holds.
  uint32_t tick(bool withhold) {
    uint32_t back = 0;
    int keep = -1;
    if (withhold)
      for (unsigned s = 0; s != owed_.size() && keep < 0; ++s)
        if (owed_[s]) keep = int(s);
    for (unsigned s = 0; s != owed_.size(); ++s) {
      if (owed_[s] > 1) ++owed_past_one_cycles_;
      if (!owed_[s]) continue;
      if (int(s) == keep && owed_[s] == 1) {
        ++withheld_cycles_;
        continue;
      }
      --owed_[s];
      back |= 1u << s;
    }
    return back;
  }
  uint64_t owedPastOneCycles() const { return owed_past_one_cycles_; }
  uint64_t withheldCycles() const { return withheld_cycles_; }

private:
  unsigned per_;
  std::vector<unsigned> held_, owed_;
  uint64_t owed_past_one_cycles_ = 0, withheld_cycles_ = 0;
};

/// DCU's per-bank credits as MIU holds them (MA-25): every request to a
/// bank spends an entry credit, a store a store-data credit too; DCU returns
/// them on two per-bank vectors. A hard reservation, reset full.
class BankCredits {
public:
  BankCredits(unsigned banks, unsigned qdepth, unsigned stdata)
      : q_(qdepth), sd_(stdata), ent_(banks, qdepth), std_(banks, stdata) {}

  unsigned banks() const { return unsigned(ent_.size()); }
  unsigned entries(unsigned b) const { return ent_[b]; }
  unsigned storeData(unsigned b) const { return std_[b]; }
  bool can(unsigned b, bool store) const { return ent_[b] && (!store || std_[b]); }
  /// Spend the request's credits. False: none to spend (a send without a
  /// credit, which the model must never make).
  bool take(unsigned b, bool store) {
    if (!can(b, store)) return false;
    --ent_[b];
    if (store) --std_[b];
    return true;
  }
  /// DCU's returns, bit b for bank b. False: a return past the reset count
  /// (DCU returned a credit MIU never spent).
  bool ret(uint32_t ent, uint32_t std) {
    bool ok = true;
    for (unsigned b = 0; b != ent_.size(); ++b) {
      if (ent >> b & 1u) { if (ent_[b] == q_) ok = false; else ++ent_[b]; }
      if (std >> b & 1u) { if (std_[b] == sd_) ok = false; else ++std_[b]; }
    }
    return ok;
  }
  bool allHome() const {
    for (unsigned b = 0; b != ent_.size(); ++b)
      if (ent_[b] != q_ || std_[b] != sd_) return false;
    return true;
  }

private:
  unsigned q_, sd_;
  std::vector<unsigned> ent_, std_;
};

/// A fully associative TLB, least recently used replaced (MA-8). It holds
/// virtual page numbers; the model's translation is the identity (MI-2), so
/// a hit's frame is its page.
class Tlb {
public:
  explicit Tlb(unsigned entries) : e_(entries) {}

  /// Whether vpn is held; a hit refreshes its age.
  bool lookup(uint64_t vpn) {
    for (Ent &e : e_)
      if (e.valid && e.vpn == vpn) { e.used = ++tick_; ++hits_; return true; }
    ++misses_;
    return false;
  }
  /// Whether vpn is held, with no effect: what A2 may ask twice in a cycle.
  bool holds(uint64_t vpn) const {
    for (const Ent &e : e_)
      if (e.valid && e.vpn == vpn) return true;
    return false;
  }
  /// Install vpn: an invalid entry, else the least recently used.
  void fill(uint64_t vpn) {
    if (holds(vpn)) return;
    Ent *v = &e_[0];
    for (Ent &e : e_) {
      if (!e.valid) { v = &e; break; }
      if (e.used < v->used) v = &e;
    }
    *v = {true, vpn, ++tick_};
  }
  /// Q-60's invalidate: every entry.
  void clear() {
    for (Ent &e : e_) e.valid = false;
  }
  uint64_t hits() const { return hits_; }
  uint64_t misses() const { return misses_; }

private:
  struct Ent { bool valid = false; uint64_t vpn = 0; uint64_t used = 0; };
  std::vector<Ent> e_;
  uint64_t tick_ = 0, hits_ = 0, misses_ = 0;
};

/// The page-table walker (MA-8): one, shared by the data side and FET's
/// ITLB, one walk at a time, the oldest request first. A walk is `levels`
/// dependent reads; the block sends each when wantRead() names it and a
/// slot no first pass uses is free, and reports its answer with got().
/// Requests for a page already waiting or walking merge.
class Walker {
public:
  enum Src : unsigned { kData = 1, kItlb = 2 };

  Walker(unsigned levels, uint64_t base, unsigned page_shift)
      : levels_(levels), base_(base), shift_(page_shift) {}

  /// Ask for vpn's translation. A request for a page already queued or in
  /// walk adds its source and starts nothing new.
  void request(uint64_t vpn, Src src) {
    if (busy_ && cur_.vpn == vpn) { cur_.src |= src; return; }
    for (Req &r : q_)
      if (r.vpn == vpn) { r.src |= src; return; }
    // An ITLB miss behind a data-side walk, in flight or queued ahead of it.
    bool behind_data = busy_ && (cur_.src & kData);
    for (const Req &r : q_) behind_data = behind_data || (r.src & kData);
    if (src == kItlb && behind_data) ++itlb_waits_;
    q_.push_back({vpn, unsigned(src)});
  }
  bool busy() const { return busy_; }
  bool idle() const { return !busy_ && q_.empty(); }

  /// Start the next walk if none is in flight. Call once a cycle.
  void cycle() {
    if (busy_) ++busy_cycles_;
    if (busy_ || q_.empty()) return;
    cur_ = q_.front();
    q_.pop_front();
    busy_ = true;
    level_ = 0;
    sent_ = false;
    ++walks_;
  }
  /// The read the walk needs now, if one is due and not yet sent: the
  /// 8-byte entry of this level's 16-bit index (MI-2's default format).
  bool wantRead(uint64_t &addr) const {
    if (!busy_ || sent_) return false;
    const unsigned bits = 16;
    const unsigned at = shift_ + bits * (levels_ - 1 - level_);
    const uint64_t idx = (cur_.vpn << shift_ >> at) & ((uint64_t(1) << bits) - 1);
    addr = base_ + (uint64_t(level_) << 24) + idx * 8;
    return true;
  }
  void sent() { sent_ = true; }
  /// This level's read is back. True when the walk is done: done() names it.
  bool got() {
    sent_ = false;
    if (++level_ != levels_) return false;
    busy_ = false;
    done_ = cur_;
    return true;
  }
  uint64_t doneVpn() const { return done_.vpn; }
  unsigned doneSrc() const { return done_.src; }

  uint64_t walks() const { return walks_; }
  uint64_t busyCycles() const { return busy_cycles_; }
  /// ITLB requests that found a data-side walk in flight (MA-8's statistic).
  uint64_t itlbWaits() const { return itlb_waits_; }

private:
  struct Req { uint64_t vpn = 0; unsigned src = 0; };
  unsigned levels_;
  uint64_t base_;
  unsigned shift_;
  std::deque<Req> q_;
  Req cur_, done_;
  bool busy_ = false, sent_ = false;
  unsigned level_ = 0;
  uint64_t walks_ = 0, busy_cycles_ = 0, itlb_waits_ = 0;
};

} // namespace miu
} // namespace ccv
