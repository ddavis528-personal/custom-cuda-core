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
//                 walk at a time, each level one dependent DCU read, in the
//                 Common tab's format (MI-2, AR 391, AR 392).
//
// Sizes are constructor arguments: the block passes the generated params
// where they exist and the named defaults below where TI has not added
// them yet (miu-impl.md section 7).
//===----------------------------------------------------------------------===//
#pragma once

#include <algorithm>
#include <cstdint>
#include <deque>
#include <utility>
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
  static constexpr unsigned kWalkBits[3] = {6, 13, 13};   ///< Common tab rev 9 (AR 392), root first
  static constexpr unsigned kPteBytes = 8;      ///< AR 391: a model parameter
  static constexpr unsigned kWalkExtra = 0;     ///< AR 391: cycles a level adds past its read
  /// The page-table base CSR's value (CRU's, its address TI's): a region no
  /// kernel touches, which the block asserts (MI-2).
  static constexpr uint64_t kWalkBase = uint64_t(0xF0) << 40;
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
  /// fifo: replaced in fill order, a hit leaving its age (the L0's round
  /// robin, rtl/miu/miu_tlb.sv); else least recently used.
  explicit Tlb(unsigned entries, bool fifo = false) : e_(entries), fifo_(fifo) {}

  /// Whether vpn is held; a hit refreshes its age unless fifo.
  bool lookup(uint64_t vpn) {
    for (Ent &e : e_)
      if (e.valid && e.vpn == vpn) { if (!fifo_) e.used = ++tick_; ++hits_; return true; }
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
  bool fifo_;
  uint64_t tick_ = 0, hits_ = 0, misses_ = 0;
};

/// The page-table walker (MA-8): one, shared by the data side and FET's
/// ITLB, one walk at a time, the oldest request first. The format is the
/// specs doc's Common tab (AR 392, rev 9): 64 KiB pages, three levels
/// indexed by VA[47:42], VA[41:29] and VA[28:16] (6, 13 and 13 bits), each
/// level one dependent PTE read; a 512-byte root and 64 KiB nodes. The
/// translation is the identity and the PTE's value is unused (MI-2), so the
/// nodes sit where an identity table laid out from the base would put them:
/// the root at the base, then every middle node, then every leaf node, each
/// a 64 KiB page. The block sends each read when wantRead() names it on a
/// slot no first pass uses, and reports its answer with got(). Requests for
/// a page already waiting or walking merge.
class Walker {
public:
  enum Src : unsigned { kData = 1, kItlb = 2 };

  /// `bits`: each level's index width, root first. `extra`: cycles each
  /// level waits past its read's answer (AR 391; 0, a level costs its read).
  Walker(std::vector<unsigned> bits, uint64_t base, unsigned page_shift,
         unsigned pte_bytes = 8, unsigned extra = 0)
      : bits_(std::move(bits)), base_(base), shift_(page_shift), pte_(pte_bytes),
        extra_(extra) {}

  unsigned levels() const { return unsigned(bits_.size()); }
  unsigned vpnBits() const {
    unsigned n = 0;
    for (unsigned b : bits_) n += b;
    return n;
  }
  /// The bytes the tables span from the base: what no kernel may touch.
  uint64_t span() const {
    uint64_t nodes = 0, at = 1;
    for (unsigned l = 0; l + 1 < bits_.size(); ++l) { at <<= bits_[l]; nodes += at; }
    return (uint64_t(1) << shift_) * (1 + nodes);
  }

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
  /// The page the walk in flight is for (valid while busy()).
  uint64_t curVpn() const { return cur_.vpn; }
  bool idle() const { return !busy_ && q_.empty(); }

  /// One cycle: a level's extra wait counts down, and the next walk starts
  /// if none is in flight. Call once a cycle, before wantRead().
  void cycle() {
    if (busy_) ++busy_cycles_;
    if (wait_) --wait_;
    if (busy_ || q_.empty()) return;
    cur_ = q_.front();
    q_.pop_front();
    busy_ = true;
    level_ = 0;
    sent_ = false;
    wait_ = 0;
    ++walks_;
  }
  /// The read the walk needs now, if one is due and not yet sent: this
  /// level's PTE in its node.
  bool wantRead(uint64_t &addr) const {
    if (!busy_ || sent_ || wait_) return false;
    addr = pteAddr(cur_.vpn, level_);
    return true;
  }
  /// The PTE address of `vpn` at `level`, from the layout above.
  uint64_t pteAddr(uint64_t vpn, unsigned level) const {
    // The node: the root, else its index among this level's nodes, after
    // every node of the levels above.
    uint64_t node = 0, before = 1, at = 1;
    unsigned used = 0;
    for (unsigned l = 0; l < level; ++l) {
      used += bits_[l];
      at <<= bits_[l];
      if (l + 1 < level) before += at;
    }
    if (level) node = before + (vpn >> (vpnBits() - used));
    const unsigned below = vpnBits() - used - bits_[level];
    const uint64_t idx = (vpn >> below) & ((uint64_t(1) << bits_[level]) - 1);
    return base_ + (node << shift_) + idx * pte_;
  }
  void sent() { sent_ = true; }
  /// This level's read is back. True when the walk is done: doneVpn() names it.
  bool got() {
    sent_ = false;
    if (++level_ != bits_.size()) { wait_ = extra_; return false; }
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
  std::vector<unsigned> bits_;
  uint64_t base_;
  unsigned shift_, pte_, extra_;
  std::deque<Req> q_;
  Req cur_, done_;
  bool busy_ = false, sent_ = false;
  unsigned level_ = 0, wait_ = 0;
  uint64_t walks_ = 0, busy_cycles_ = 0, itlb_waits_ = 0;
};

/// F-SHARED (section 12.5; MI-46, MA rev 221): a .shared lane's address is
/// its AGU sum modulo 2^32 (O-79), an offset into its CTA's region of size
/// bytes, and never taken signed: a negative sum is an offset near 2^32 and
/// faults as any byte past the region does. A2's window check (miu_a2's ow)
/// takes no .shared access, so this is the fault a negative .shared sum
/// raises.
inline bool sharedFault(uint64_t sum, unsigned bytes, uint64_t size) {
  return (sum & 0xffffffffu) + bytes > size;
}
/// A .shared offset at or above 2^31: a negative sum, since no region is
/// that large (the MIUBINS bin shared_neg_fault).
inline bool sharedNegative(uint64_t sum) { return ((sum >> 31) & 1u) != 0; }

} // namespace miu
} // namespace ccv
