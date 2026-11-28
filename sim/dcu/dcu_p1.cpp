//===-- dcu_p1.cpp - MA's Phase 1 DCU resource model ----------------------===//
//
// The DCU stub's function (sim/skel/kernel.cpp, class Dcu: write-back L1,
// ownership, misses by req_id, fill notices) with Phase 1's bank timing on
// top: CCV_DCU_BANKS half-rate single-port banks, MA-17's store variants,
// MA-20's arbitration, conflict queue and within-page hash, and AR 364's
// age bound. Selected by CCV_DCU_IMPL=p1; the stub stays the functional
// reference. Reads only DCU's own receivers and writes only its own senders.
//
// Knobs (environment): CCV_P1_STORE = a | af | b (MA-17 RMW; with a
// forwarding write buffer; deferred read under lead_store), CCV_P1_ARB =
// fixed | rot, CCV_P1_HASH = 0 | 1, CCV_DCU_BANK_AGE, CCV_P1_GAP (a store
// hit's read to its write, 4 with ECC), CCV_P1_DLAT (cycles from a bank's
// grant to the response, calibrated against the stub's slack),
// CCV_DCU_BANKS, CCV_P1_QDEPTH (lookups a bank may hold waiting; past it a
// loser re-passes from MIU and arrives again CCV_P1_REPASS = 6 cycles on;
// unlimited by default), CCV_P1_STRICT=1 (a hit that waited at its bank answers
// CCV_P1_PAD = 5 cycles later still, past the stub's slack, so it loses the
// contract as the spec says; 0 lets the stub's slack absorb short waits,
// the optimistic bound), CCV_P1_WAYPRED = 0 | 1..16 (MA-23 (C2): fold bits of
// a per-way partial tag; a hit on a mispredicted way takes a second bank
// access and answers 1 cycle late, or CCV_P1_PAD under STRICT),
// CCV_P1_WPSEL = index | recent (among the ways whose fold matches, the
// predictor picks the lowest way index, or the most recently used; AR 381),
// CCV_P1_LDFIRST = 0 | 1 (a bank takes an on-time load before an on-time
// store; the store waits as deferred work), CCV_P1_DEFCAP (under (b), a
// bank holding this many entries with data takes a store as a lookup instead
// of deferring it, and queues no store past it: the store re-passes and its
// data stays in MIU; unlimited by default), CCV_P1_CREDIT=1 (MA-24 on AR
// 382: MIU holds per-bank credits, QDEPTH entries and DEFCAP store-data
// entries, a hard reservation that counts direct winners too; a request
// without its credit waits in MIU, in order, and is sent CCV_P1_CRWAIT = 2
// cycles after the credit returns at the earliest). Its measures
// print as the P1 line (coverage p1_*).
//
// The banks' waiters are held without limit, so the occupancy histogram
// (p1_qNN, lookups waiting in one bank each cycle) sizes MA-20 (3)'s queue
// at its 99.9th percentile; ccv_dcu_miu_rsp has no refusal, so DCU holds
// what it takes either way.
//===----------------------------------------------------------------------===//
#include <algorithm>
#include <array>
#include <cstdlib>
#include <deque>
#include <map>
#include <memory>
#include <set>
#include <string>
#include <vector>
#include "kernel.h"
#include "stub.h"

namespace ccv {
namespace skel {
namespace {

inline uint64_t indexLeadSet(uint64_t pa) {
  return (pa >> 7) & ((uint64_t(1) << ccv::prov::kWDcuSet) - 1);
}

class DcuP1 : public Stub {
public:
  DcuP1(int inst, Kernel &k) : Stub(inst, k), ids_(ch().dcu_mlc) {
    const char *v = std::getenv("CCV_P1_STORE");
    const std::string st = v ? v : "a";
    store_ = st == "af" ? kStAF : st == "b" ? kStB : kStA;
    v = std::getenv("CCV_P1_ARB");
    rot_ = v && std::string(v) == "rot";
    v = std::getenv("CCV_P1_WPSEL");
    wprecent_ = v && std::string(v) == "recent";
    hash_ = envU("CCV_P1_HASH", 0) != 0;
    age_ = envU("CCV_DCU_BANK_AGE", ccv::prov::kDcuBankAge);
    gap_ = envU("CCV_P1_GAP", 4);
    dlat_ = envU("CCV_P1_DLAT", 0);
    qdepth_ = envU("CCV_P1_QDEPTH", 1u << 30);
    repass_ = envU("CCV_P1_REPASS", 6);
    pad_ = envU("CCV_P1_STRICT", 0) ? envU("CCV_P1_PAD", 5) : 0;
    wp_ = envU("CCV_P1_WAYPRED", 0);
    if (wp_ > 16) wp_ = 16;
    ldfirst_ = envU("CCV_P1_LDFIRST", 0) != 0;
    defcap_ = envU("CCV_P1_DEFCAP", 1u << 30);
    credit_ = envU("CCV_P1_CREDIT", 0) != 0;
    crwait_ = envU("CCV_P1_CRWAIT", 2);
    banks_ = envU("CCV_DCU_BANKS", ccv::kDcuBanks);
    if (!banks_ || (banks_ & (banks_ - 1))) banks_ = ccv::kDcuBanks;
    lb_ = unsigned(__builtin_ctz(banks_));
    bfree_.assign(banks_, 0);
    bq_.resize(banks_);
    ptr_.assign(banks_, 0);
  }
  const char *kind() const override { return "dcu"; }

private:
  struct Op { unsigned slot; Bits req; uint64_t tid; };
  std::deque<Op> q_;
  /// A request to MLC in flight, by its req_id: a read's fill, the read half
  /// of a partial store's read-modify-write, or a write awaiting its ack.
  /// kAcquire: a store's line fetched with ownership, then merged; kPerm:
  /// ownership alone, for a store of the whole line; kEvict: a dirty line's
  /// writeback, which answers no one (DCU spec rev 8).
  /// kAtomRead: an atomic's read (AR-21, IS-21), the line with ownership.
  enum Kind { kFill, kRmwRead, kAck, kAcquire, kPerm, kEvict, kAtomRead };
  struct Miss { Op op; Kind kind; uint64_t line; };
  std::map<unsigned, Miss> miss_;
  std::set<uint64_t> busy_lines_;    ///< lines with a request to MLC in flight
  std::deque<std::pair<uint64_t, Line>> evict_;   ///< dirty lines waiting for a req_id
  IdPool ids_;
  std::deque<Q> to_mlc_, to_miu_;
  /// Refills promised by a notice on ccv_dcu_miu_fill_ntc (OA-23): each
  /// leaves at its cycle on its slot, which keeps a credit back for it
  /// until then (DCU spec, Internals).
  struct Promise { uint64_t at; Q q; uint64_t line; };
  std::deque<Promise> promised_;
  std::map<unsigned, unsigned> resv_;   ///< slot -> promises not yet sent
  /// A slot an ordinary response may use: a credit, and one more than its
  /// promises hold back.
  bool free(unsigned slot) {
    return can(ch().dcu_miu, slot) && credits(ch().dcu_miu, slot) > resv_[slot];
  }

  /// L1 (OI-5): a small set-associative array, CCV_DCU_WAYS x CCV_DCU_SETS
  /// (8 x 64 by default; the DCU spec's 8 ways, since 31168a3), so a load that
  /// revisits a line hits, and MIU can complete it at the L1 contract. A hit answers the
  /// cycle it arrives, ahead of any miss in flight: the contract is MIU's to
  /// keep (CCV_LAT_L1_HIT), and an answer early enough lets it.
  /// Write-back and write-allocate, with ownership (DCU spec rev 8; AR,
  /// TI-36): a read's fill installs the line shared; a store to a line DCU
  /// owns merges its bytes there, dirty, and nothing goes to MLC; a store
  /// to a shared line, or a partial miss, fetches the line with ownership,
  /// then merges; a store of the whole line that misses takes ownership
  /// alone. A dirty line leaves only whole, written back when another line
  /// takes its set. One core and no other writer, so nothing probes.
  /// write-through: every store goes to MLC as a read-merge-write, the
  /// policy before rev 8, which the merged values survive but the timing
  /// does not.
  /// CCV_DCU_SETS sets (a power of two) of CCV_DCU_WAYS ways, defaults the
  /// params' (64 and 8, 64 KiB; MA-15), each overridable from the
  /// environment for a sweep; least recently used replaced: the DCU spec's 8
  /// ways, settled by TI rev 234's 1-to-8-way sweep (AR rev 320). Before it
  /// the default was 1 way, and three arrays 64 KiB apart (rbase<<16) fought
  /// for one set (J9). A kernel that needs evictions sets CCV_DCU_WAYS=1.
  static unsigned setsOf() {
    const char *v = std::getenv("CCV_DCU_SETS");
    const unsigned n = v && *v ? unsigned(std::strtoul(v, nullptr, 10)) : ccv::prov::kDcuSets;
    return n >= 1 && n <= 65536 && !(n & (n - 1)) ? n : ccv::prov::kDcuSets;
  }
  const unsigned sets_ = setsOf();
  struct Way {
    bool valid = false; uint64_t line = 0; Line data{}; bool owned = false, dirty = false;
    uint64_t used = 0;
  };
  static unsigned waysOf() {
    const char *v = std::getenv("CCV_DCU_WAYS");
    const unsigned n = v && *v ? unsigned(std::strtoul(v, nullptr, 10)) : ccv::prov::kDcuWays;
    return n >= 1 && n <= 16 ? n : ccv::prov::kDcuWays;
  }
  const unsigned ways_ = waysOf();
  std::vector<Way> l1_ = std::vector<Way>(size_t(sets_) * ways_);
  uint64_t lru_tick_ = 0;
  /// The way holding pa, else the one an install of pa would take: an
  /// invalid way, else the least recently used.
  Way &way(uint64_t pa) {
    Way *set = &l1_[size_t((pa / kLine) % sets_) * ways_];
    Way *victim = &set[0];
    for (unsigned i = 0; i != ways_; ++i) {
      if (set[i].valid && set[i].line == pa) { set[i].used = ++lru_tick_; return set[i]; }
      if (victim->valid && (!set[i].valid || set[i].used < victim->used)) victim = &set[i];
    }
    return *victim;
  }
  const Line *lookup(uint64_t pa) {
    Way &w = way(pa);
    return w.valid && w.line == pa ? &w.data : nullptr;
  }
  /// A read's hit: any valid line for a plain read; for an atomic's read
  /// (coh_op AcquireBlock, IS-21) only a line DCU owns, which the atomic's
  /// write then merges into without a further request (DCU spec rev 8).
  const Line *readHit(const Bits &req) {
    const unsigned co = unsigned(get(req, ch().miu_dcu, "coh_op"));
    const uint64_t pa = get(req, ch().miu_dcu, "phys_addr");
    if (co == kCohRead) return lookup(pa);
    if (co != kCohAcquireData) return nullptr;
    Way &w = way(pa);
    return w.valid && w.line == pa && w.owned ? &w.data : nullptr;
  }
  static bool isRead(unsigned co) { return co == kCohRead || co == kCohAcquireData; }
  /// The harness's view of what memory holds above the testbench.
  void shadow(const Way &w) {
    if (w.valid && w.dirty) k_.dcu_dirty[w.line].assign(w.data.begin(), w.data.end());
  }
  /// A line into its set: a dirty line there of another address is written
  /// back first, whole, and stays busy from now until MLC has it. It waits
  /// for a req_id of its own, ahead of every miss.
  void install(uint64_t pa, const Line &l, bool owned = false, bool dirty = false) {
    Way &w = way(pa);
    if (w.valid && w.dirty && w.line != pa) {
      evict_.push_back({w.line, w.data});
      busy_lines_.insert(w.line);
      k_.hit("dcu_evict");
      defer(Acc::kEvictR, w.line);
    }
    defer(Acc::kFillW, pa);
    w = {true, pa, l, owned, dirty, ++lru_tick_};
    shadow(w);
  }
  /// A store's bytes into a line, under its byte mask.
  void mergeInto(Line &l, const Bits &req) const {
    const Line wd = getLine(req, field(ch().miu_dcu, "write_data").lsb);
    const uint32_t mlsb = field(ch().miu_dcu, "byte_mask").lsb;
    for (unsigned k = 0; k != kLine; ++k)
      if (req.bit(mlsb + k)) l[k] = wd[k];
  }

  /// A response as it leaves: the stored check bits of its line (MA-28 (c),
  /// AR 401), as the stub's DCU does; p1 had not been sealing since then (AR 412).
  Bits seal(Bits r) {
    const Ch &c = ch();
    const Line l = getLine(r, field(c.dcu_miu, "read_data").lsb);
    putCheckBits(r, field(c.dcu_miu, "check_bits").lsb, l);
    return r;
  }
  /// A response to MIU answers its request by MIU's own req_id.
  Bits rspFor(const Bits &req) {
    Bits r = msgOf(ch().dcu_miu);
    put(r, ch().dcu_miu, "req_id", get(req, ch().miu_dcu, "req_id"));
    return r;
  }
  /// A read that hits: the line, hit set, no MLC miss.
  void hitRsp(const Op &o, const Line &l) {
    Bits r = rspFor(o.req);
    putLine(r, field(ch().dcu_miu, "read_data").lsb, l);
    put(r, ch().dcu_miu, "hit", 1);
    to_miu_.push_back({o.slot, r, o.tid});
  }

  /// A store whose byte mask covers its whole line: nothing of the old line
  /// survives it, so it needs no read (AR-19). skip-read-partial takes every
  /// store for one, and a partial store loses the bytes it does not write.
  bool fullLine(const Bits &req) const {
    if (k_.brk == "skip-read-partial") return true;
    const uint32_t mlsb = field(ch().miu_dcu, "byte_mask").lsb;
    for (unsigned k = 0; k != kLine; ++k)
      if (!req.bit(mlsb + k)) return false;
    return true;
  }

  void mlcReq(unsigned coh, uint64_t pa, const Line *data, const Op &o, Kind kind) {
    const Ch &c = ch();
    Bits r = msgOf(c.dcu_mlc);
    put(r, c.dcu_mlc, "phys_addr", pa);
    put(r, c.dcu_mlc, "coh_op", coh);
    const unsigned id = ids_.take();
    put(r, c.dcu_mlc, "req_id", id);
    if (data) putLine(r, field(c.dcu_mlc, "writeback_data").lsb, *data);
    to_mlc_.push_back({0, r, o.tid});
    miss_[id] = {o, kind, pa};
    busy_lines_.insert(pa);
  }

  /// AR 362: the lead's set index is a copy of the lookup's phys_addr
  /// bits, bit for bit, and DCU refuses one that differs, by name (--break
  /// dcu-set-lead). The stub reads its set from the payload, so the lead
  /// changes no state here (AR 362 (3)).
  void checkIndexLead(unsigned s, const Bits &req) {
    const Ch &c = ch();
    const uint64_t pa = get(req, c.miu_dcu, "phys_addr");
    const uint64_t set = indexLeadSet(pa);
    const uint64_t ls = get(req, c.miu_dcu, "lead_set_index");
    if (ls != set)
      k_.fail("dcu: slot %u req_id %u lead_set_index %llx is not its phys_addr %llx's set %llx",
              s, unsigned(get(req, c.miu_dcu, "req_id")), (unsigned long long)ls,
              (unsigned long long)pa, (unsigned long long)set);
  }

  // MA-25's credit returns on ccv_dcu_miu_cred (DI-8: without them the MIU
  // stub's per-bank credits run dry). Banks here are MIU's (CCV_DCU_BANKS,
  // line-address low bits), whatever CCV_P1_HASH does inside p1. An entry
  // credit goes home once its request no longer waits in a bank queue (p1's
  // entry, the one MA-24's sweep sized QDEPTH from), a store-data credit once
  // no deferred read, write or store lookup holds its data. At most one of
  // each a bank a cycle.
  std::array<uint64_t, ccv::kDcuBanks> rcv_ent_{}, rcv_std_{}, ret_ent_{}, ret_std_{};
  static unsigned miuBank(uint64_t pa) { return unsigned((pa / kLine) % ccv::kDcuBanks); }
  /// A store spends a store-data credit (MIU: a store but an atomic's RMW;
  /// DCU: coh_op Write), as the stub DCU counts it.
  static bool isWrite(const Bits &req) {
    return unsigned(get(req, ch().miu_dcu, "coh_op")) == kCohWrite;
  }
  void heldPerMiuBank(std::array<uint64_t, ccv::kDcuBanks> &ent,
                      std::array<uint64_t, ccv::kDcuBanks> &std) const {
    ent.fill(0);
    std.fill(0);
    auto hold = [&](const Op &o) {
      const unsigned b = miuBank(lineOf(o.req));
      ++ent[b];
      if (isWrite(o.req)) ++std[b];
    };
    for (const auto &in : arr_)
      for (const Op &o : in) hold(o);
    for (const auto &q : cr_)
      for (const auto &h : q) hold(h.second);
    for (const auto &a : again_) hold(a.second);
    // A store's miss holds its data until the fill merges it (MA-25).
    // (A victim's writeback carries no request of MIU's: its req is empty.)
    for (const auto &x : miss_)
      if (x.second.op.req.size() && isWrite(x.second.op.req)) ++std[miuBank(x.second.line)];
    for (const auto &q : bq_)
      for (const Acc &a : q) {
        if (a.k == Acc::kLook) hold(a.op);
        else if (a.k == Acc::kStoreW || a.k == Acc::kStoreR) ++std[miuBank(a.line)];
      }
  }
  bool credOwed() const {
    std::array<uint64_t, ccv::kDcuBanks> he, hs;
    heldPerMiuBank(he, hs);
    for (unsigned b = 0; b != ccv::kDcuBanks; ++b)
      if (rcv_ent_[b] - ret_ent_[b] > he[b] || rcv_std_[b] - ret_std_[b] > hs[b]) return true;
    return false;
  }
  void returnCredits() {
    const Ch &c = ch();
    std::array<uint64_t, ccv::kDcuBanks> he, hs;
    heldPerMiuBank(he, hs);
    uint64_t ent = 0, std = 0;
    for (unsigned b = 0; b != ccv::kDcuBanks; ++b) {
      if (rcv_ent_[b] - ret_ent_[b] > he[b]) ent |= uint64_t(1) << b;
      if (rcv_std_[b] - ret_std_[b] > hs[b]) std |= uint64_t(1) << b;
    }
    if ((!ent && !std) || !can(c.dcu_cred, 0)) return;
    Bits m = msgOf(c.dcu_cred);
    put(m, c.dcu_cred, "ent_ret", ent);
    put(m, c.dcu_cred, "std_ret", std);
    send(c.dcu_cred, 0, m, makeUid(IdClass::kNone, 0));
    for (unsigned b = 0; b != ccv::kDcuBanks; ++b) {
      if (ent >> b & 1) { ++ret_ent_[b]; k_.hit("dcu_ent_ret"); }
      if (std >> b & 1) { ++ret_std_[b]; k_.hit("dcu_std_ret"); }
    }
  }

  void work() override {
    const Ch &c = ch();
    returnCredits();    // what last cycle let go
    releaseCredits();   // older held requests take returned credits first
    for (unsigned s = 0; s != kChans[c.miu_dcu].rate; ++s)
      while (has(c.miu_dcu, s)) {
        Receiver::Msg m = take(c.miu_dcu, s);
        // A dropped lookup (MA-27, AR 400; DI-63): no read, no queue entry,
        // no credit return (MIU refunds its own, DI-12), no answer.
        // dcu-drop-answers serves it anyway, as the stub and DCU model do.
        if (get(m.payload, c.miu_dcu, "drop") && k_.brk != "dcu-drop-answers") continue;
        checkIndexLead(s, m.payload);
        {
          const unsigned b = miuBank(get(m.payload, c.miu_dcu, "phys_addr"));
          ++rcv_ent_[b];
          if (isWrite(m.payload)) ++rcv_std_[b];
        }
        offer(Op{s, m.payload, m.tid});
      }
    while (!again_.empty() && again_.front().first <= now_) {
      const uint64_t pl = lineOf(again_.front().second.req);
      if (!--pend_[pl]) pend_.erase(pl);
      arrive(again_.front().second);
      again_.pop_front();
    }
    schedule();
    if (has(c.mlc_dcu, 0)) {
      Receiver::Msg m = take(c.mlc_dcu, 0);
      const unsigned id = unsigned(get(m.payload, c.mlc_dcu, "req_id"));
      auto it = miss_.find(id);
      if (it == miss_.end() || !ids_.release(id)) {
        k_.fail("dcu: MLC answered req_id %u, which is not outstanding", id);
      } else {
        const Miss x = it->second;
        miss_.erase(it);
        if (x.kind == kEvict) {
          busy_lines_.erase(x.line);   // a writeback's ack: memory has the line
        } else {
        // A promised refill keeps its line busy until it leaves (refill), so
        // a read queued behind the fill still answers after it.
        const bool noticed = x.kind == kFill && promise(x);
        if (!noticed) busy_lines_.erase(x.line);
        Bits r = rspFor(x.op.req);
        if (x.kind == kFill) {
          const Line l = getLine(m.payload, field(c.mlc_dcu, "line_data").lsb);
          putLine(r, field(c.dcu_miu, "read_data").lsb, l);
          put(r, c.dcu_miu, "mlc_miss", get(m.payload, c.mlc_dcu, "miss"));
          install(x.line, l);
          if (noticed)
            refill(x.op.slot, r, x.op.tid, unsigned(get(r, c.dcu_miu, "req_id")), x.line);
          else
            to_miu_.push_back({x.op.slot, r, x.op.tid});
        } else if ((x.kind == kAcquire || x.kind == kPerm || x.kind == kAtomRead) &&
                   !get(m.payload, c.mlc_dcu, "ownership")) {
          k_.fail("dcu: MLC answered the acquire of line %llx (req_id %u) without ownership",
                  (unsigned long long)x.line, id);
        } else if (x.kind == kAtomRead) {
          // An atomic's read: the line, owned and clean, to MIU.
          const Line l = getLine(m.payload, field(c.mlc_dcu, "line_data").lsb);
          putLine(r, field(c.dcu_miu, "read_data").lsb, l);
          put(r, c.dcu_miu, "mlc_miss", get(m.payload, c.mlc_dcu, "miss"));
          install(x.line, l, true, false);
          to_miu_.push_back({x.op.slot, r, x.op.tid});
        } else if (x.kind == kAcquire) {
          // The line with ownership: the store's bytes merged, dirty.
          Line l = getLine(m.payload, field(c.mlc_dcu, "line_data").lsb);
          mergeInto(l, x.op.req);
          install(x.line, l, true, true);
          to_miu_.push_back({x.op.slot, r, x.op.tid});   // the store's ack
        } else if (x.kind == kPerm) {
          // Ownership alone: the store wrote every byte.
          install(x.line, getLine(x.op.req, field(c.miu_dcu, "write_data").lsb), true, true);
          to_miu_.push_back({x.op.slot, r, x.op.tid});
        } else if (x.kind == kRmwRead) {
          Line l = getLine(m.payload, field(c.mlc_dcu, "line_data").lsb);
          const Line w = getLine(x.op.req, field(c.miu_dcu, "write_data").lsb);
          const uint32_t mlsb = field(c.miu_dcu, "byte_mask").lsb;
          for (unsigned k = 0; k != kLine; ++k)
            if (x.op.req.bit(mlsb + k)) l[k] = w[k];
          install(x.line, l);
          mlcReq(kCohWrite, x.line, &l, x.op, kAck);
        } else {
          to_miu_.push_back({x.op.slot, r, x.op.tid});   // the write's ack
        }
        }
      }
    }
    // A writeback leaves first. The harness's view keeps the line until it
    // is sent; from there on memory has it, in order ahead of any read.
    while (!evict_.empty() && ids_.any()) {
      if (k_.brk == "drop-writeback") busy_lines_.erase(evict_.front().first);
      else mlcReq(kCohWrite, evict_.front().first, &evict_.front().second,
             Op{0, Bits(), makeUid(IdClass::kTxn, g_unowned_txn++)}, kEvict);
      k_.dcu_dirty.erase(evict_.front().first);
      evict_.pop_front();
    }
    // The oldest queued request whose line has nothing in flight, nor an
    // older request waiting, starts: a hit (a read queued behind the fill
    // that brought its line in hits now, late for the contract, which is
    // MIU's to judge), a whole-line write, or a read to MLC.
    std::set<uint64_t> held;
    for (auto it = q_.begin(); it != q_.end(); ++it) {
      const uint64_t pa = get(it->req, c.miu_dcu, "phys_addr");
      if (busy_lines_.count(pa) || held.count(pa)) { held.insert(pa); continue; }
      const unsigned co = unsigned(get(it->req, c.miu_dcu, "coh_op"));
      const bool rd = isRead(co);
      const Line *l = readHit(it->req);
      // A store to a line DCU owns merges here (DCU spec rev 8).
      Way &wy = way(pa);
      const bool owned_hit = !rd && wy.valid && wy.line == pa && wy.owned &&
                             k_.brk != "write-through";
      if (owned_hit) {
        const Op o = *it;
        q_.erase(it);
        mergeInto(wy.data, o.req);
        wy.dirty = true;
        shadow(wy);
        to_miu_.push_back({o.slot, rspFor(o.req), o.tid});
        k_.hit("store_hit");
        storeWrite(pa, now_);
        break;
      }
      if (!l && (!ids_.any() || !evict_.empty())) break;   // wait, in order
      if (!l && k_.brk == "dcu-one-miss" && !miss_.empty()) break;   // a blocking DCU
      const Op o = *it;
      q_.erase(it);
      if (l) {
        hitRsp(o, *l);
      } else if (!rd && k_.brk == "write-through") {
        if (fullLine(o.req)) {
          const Line w = getLine(o.req, field(c.miu_dcu, "write_data").lsb);
          install(pa, w);
          mlcReq(kCohWrite, pa, &w, o, kAck);
          k_.hit("full_line");
        } else {
          mlcReq(kCohRead, pa, nullptr, o, kRmwRead);
        }
      } else if (!rd && fullLine(o.req)) {
        // The whole line written: ownership alone, no data (AcquirePerm).
        mlcReq(kCohAcquirePerm, pa, nullptr, o, kPerm);
        k_.hit("full_line");
      } else if (!rd) {
        // A partial store, missing or to a shared line: the line with
        // ownership, then the merge (AcquireBlock).
        mlcReq(kCohAcquireData, pa, nullptr, o, kAcquire);
        k_.hit("l1_miss");
      } else if (co == kCohAcquireData) {
        // An atomic's read (IS-21): the line with ownership, held owned so
        // its write merges here.
        mlcReq(kCohAcquireData, pa, nullptr, o, kAtomRead);
        k_.hit("l1_miss");
        k_.hit("atomic_acquire");
      } else {
        mlcReq(kCohRead, pa, nullptr, o, kFill);
        k_.hit("l1_miss");
      }
      break;
    }
    if (!to_mlc_.empty() && can(c.dcu_mlc, 0)) {
      send(c.dcu_mlc, 0, to_mlc_.front().msg, to_mlc_.front().tid);
      to_mlc_.pop_front();
    }
    // Promised refills first: each at its cycle, on its reserved credit.
    for (auto it = promised_.begin(); it != promised_.end();) {
      if (it->at != now_) { ++it; continue; }
      if (!can(c.dcu_miu, it->q.slot))
        k_.fail("dcu: the refill promised on slot %u at cycle %llu has no credit",
                it->q.slot, (unsigned long long)now_);
      else
        send(c.dcu_miu, it->q.slot, seal(it->q.msg), it->q.tid);
      --resv_[it->q.slot];
      busy_lines_.erase(it->line);
      it = promised_.erase(it);
    }
    while (!timed_.empty() && timed_.front().at <= now_) {
      to_miu_.push_back(timed_.front().q);
      timed_.pop_front();
    }
    for (auto it = to_miu_.begin(); it != to_miu_.end();)
      if (free(it->slot)) {
        send(c.dcu_miu, it->slot, seal(it->msg), it->tid);
        it = to_miu_.erase(it);
      } else {
        ++it;
      }
  }
  /// A refill is noticed (OA-23) if the notice's slot and a credit beyond
  /// those already promised are free; else it is sent as it can be.
  bool promise(const Miss &x) {
    return can(ch().fill_ntc, x.op.slot) && credits(ch().dcu_miu, x.op.slot) > resv_[x.op.slot];
  }
  /// A noticed refill: the notice, naming MIU's req_id, launches now, so its
  /// payload lands two cycles on; the refill launches the cycle before its
  /// valid is due, exactly CCV_LAT_FILL_NOTICE cycles after that.
  void refill(unsigned slot, const Bits &r, uint64_t tid, unsigned id, uint64_t line) {
    const Ch &c = ch();
    Bits n = msgOf(c.fill_ntc);
    put(n, c.fill_ntc, "req_id", k_.brk == "notice-wrong-id" ? id ^ 1u : id);
    send(c.fill_ntc, slot, n, tid);
    promised_.push_back({now_ + 1 + ccv::prov::kLatFillNotice +
                             (k_.brk == "late-refill" ? 1 : 0),
                         {slot, r, tid}, line});
    ++resv_[slot];
    k_.hit("fill_notice");
  }

  // ---- Phase 1: the banks (MA-16, MA-17, MA-20, MA-21) ----------------------
  //
  // CCV_DCU_BANKS half-rate single-port banks: an access holds its bank for
  // two cycles from the cycle it starts, each bank on its own phase. A bank
  // takes, each cycle it is free: the oldest waiter that has reached
  // CCV_DCU_BANK_AGE, else an on-time lookup that arrived this cycle (slot
  // order, or a rotating pointer under CCV_P1_ARB=rot), else the oldest
  // waiter. Waiters are deferred work (AR 364, AR 372 (3)): lookups that lost
  // their bank, fill writes, store writes, a victim's read. A request to one
  // line never passes an older one to the same line.
  enum StoreVar { kStA, kStAF, kStB };
  StoreVar store_ = kStA;
  bool rot_ = false, hash_ = false;
  unsigned age_ = 16, gap_ = 4, dlat_ = 0, pad_ = 0, banks_ = 8, lb_ = 3;
  unsigned wp_ = 0;   ///< CCV_P1_WAYPRED: way-prediction fold bits, 0 off
  bool wprecent_ = false;   ///< CCV_P1_WPSEL=recent: most recent fold match
  bool ldfirst_ = false;   ///< CCV_P1_LDFIRST: on-time loads beat on-time stores
  unsigned defcap_ = 1u << 30;   ///< CCV_P1_DEFCAP: a bank's cap on entries holding data
  bool credit_ = false;          ///< CCV_P1_CREDIT: MIU-held per-bank credits (MA-24)
  unsigned crwait_ = 2;          ///< CCV_P1_CRWAIT: a held request's earliest send
  /// Requests MIU holds for a credit, per bank, oldest first, with the
  /// cycle each may first go.
  std::vector<std::deque<std::pair<uint64_t, Op>>> cr_;
  bool isStore(const Op &o) const {
    return !isRead(unsigned(get(o.req, ch().miu_dcu, "coh_op")));
  }
  /// Entry credits in use: lookups waiting in the bank and this cycle's
  /// arrivals. Store-data credits in use: a store's deferred read or write,
  /// a store waiting as a lookup, and stores arriving this cycle.
  size_t entriesUsed(unsigned b) const {
    size_t n = arr_.size() > b ? arr_[b].size() : 0;
    for (const Acc &a : bq_[b]) n += a.k == Acc::kLook;
    return n;
  }
  size_t storeDataUsed(unsigned b) const {
    size_t n = 0;
    if (arr_.size() > b)
      for (const Op &o : arr_[b]) n += isStore(o);
    for (const Acc &a : bq_[b])
      n += a.k == Acc::kStoreW || a.k == Acc::kStoreR || (a.k == Acc::kLook && isStore(a.op));
    return n;
  }
  bool hasCredit(unsigned b, const Op &o) const {
    return entriesUsed(b) < qdepth_ && (!isStore(o) || storeDataUsed(b) < defcap_);
  }
  /// MIU's send under CCV_P1_CREDIT: a request goes only with its credits
  /// and only if nothing it must follow is held (an older held request to
  /// its line, or for a store an older held store to its bank).
  void offer(const Op &o) {
    if (!credit_) { arrive(o); return; }
    if (arr_.size() != banks_) arr_.resize(banks_);
    if (cr_.size() != banks_) cr_.resize(banks_);
    const uint64_t pa = lineOf(o.req);
    const unsigned b = bankOf(pa);
    bool follow = false;
    for (const auto &h : cr_[b])
      follow |= lineOf(h.second.req) == pa || (isStore(o) && isStore(h.second));
    if (!follow && hasCredit(b, o)) { arrive(o); return; }
    k_.hit(isStore(o) ? "p1_credit_hold_st" : "p1_credit_hold_ld");
    born_.emplace(get(o.req, ch().miu_dcu, "req_id"), now_);
    cr_[b].push_back({now_ + crwait_, o});
  }
  /// Held requests go oldest first as their credits come back. A store held
  /// and then sent is the coverage point MA-24 (4) names.
  void releaseCredits() {
    if (!credit_ || cr_.size() != banks_) return;
    if (arr_.size() != banks_) arr_.resize(banks_);
    for (unsigned b = 0; b != banks_; ++b) {
      std::deque<std::pair<uint64_t, Op>> &q = cr_[b];
      std::vector<uint64_t> lines;
      bool storeHeld = false;
      for (size_t i = 0; i != q.size();) {
        const Op &o = q[i].second;
        const uint64_t pa = lineOf(o.req);
        const bool blocked = std::find(lines.begin(), lines.end(), pa) != lines.end() ||
                             (isStore(o) && storeHeld);
        if (!blocked && q[i].first <= now_ && hasCredit(b, o)) {
          if (isStore(o)) k_.hit("p1_credit_hold_then_sent");
          const Op go = o;
          q.erase(q.begin() + long(i));
          arrive(go);
          continue;
        }
        lines.push_back(pa);
        storeHeld |= isStore(o);
        ++i;
      }
      size_t sd = storeDataUsed(b);
      k_.peak("p1_store_data_peak", sd);
    }
  }

  /// Way prediction (MA-23 (C2), AR 376-378): each way keeps a wp_-bit XOR
  /// fold of its tag; the payload's PA fold picks the valid way that matches
  /// (the lowest way index, or under CCV_P1_WPSEL=recent the most recently
  /// used: an age compare over L1's true LRU stamps), and the data read
  /// starts on it. A hit whose predicted way is
  /// wrong re-reads on the full compare's way: one more bank access, and a
  /// hit one cycle past its contract (CCV_P1_STRICT: past the stub's slack).
  /// Returns the cycles the hit is delayed, 0 when predicted right.
  unsigned wayPredict(uint64_t pa) {
    if (!wp_) return 0;
    auto fold = [&](uint64_t line) {
      uint64_t t = line / kLine / sets_, f = 0;
      for (; t; t >>= wp_) f ^= t & ((1u << wp_) - 1);
      return f;
    };
    const Way *set = &l1_[size_t((pa / kLine) % sets_) * ways_];
    const uint64_t f = fold(pa);
    const Way *pick = nullptr;
    for (unsigned i = 0; i != ways_; ++i)
      if (set[i].valid && fold(set[i].line) == f) {
        if (!pick || (wprecent_ && set[i].used > pick->used)) pick = &set[i];
        if (!wprecent_) break;
      }
    if (pick && pick->line == pa) { k_.hit("p1_wp_right"); return 0; }
    k_.hit("p1_wp_wrong");
    bfree_[bankOf(pa)] += 2;
    return pad_ ? pad_ : 1;
  }
  unsigned qdepth_ = 1u << 30, repass_ = 6;
  std::deque<std::pair<uint64_t, Op>> again_;   ///< re-passes, by the cycle they return
  std::map<uint64_t, unsigned> pend_;   ///< line -> lookups out on a re-pass
  bool repassing(uint64_t line) const { return pend_.count(line) != 0; }
  /// A re-passed lookup's first arrival, by its MIU req_id, so its wait and
  /// the strict contract count from there.
  std::map<uint64_t, uint64_t> born_;
  uint64_t bornOf(const Op &o) {
    const uint64_t id = get(o.req, ch().miu_dcu, "req_id");
    auto it = born_.find(id);
    return it == born_.end() ? now_ : it->second;
  }
  unsigned waited_ = 0;   ///< the lookup being served waited this many cycles
  static unsigned envU(const char *n, unsigned d) {
    const char *v = std::getenv(n);
    return v && *v ? unsigned(std::strtoul(v, nullptr, 10)) : d;
  }
  struct Acc {
    enum K { kLook, kFillW, kStoreW, kStoreR, kEvictR } k;
    uint64_t born, ready, line;
    Op op;
  };
  std::vector<uint64_t> bfree_;
  std::vector<std::deque<Acc>> bq_;
  std::vector<unsigned> ptr_;
  std::map<uint64_t, unsigned> held_;   ///< line -> store writes not yet done
  struct Timed { uint64_t at; Q q; };
  std::deque<Timed> timed_;

  /// The bank: the line address's low bits, or under CCV_P1_HASH the
  /// within-page XOR of AR 372 (2), [9:7] ^ [12:10] ^ [15:13] at 8 banks.
  unsigned bankOf(uint64_t pa) const {
    const uint64_t m = banks_ - 1, l = pa >> 7;
    uint64_t b = l & m;
    if (hash_) b ^= ((l >> lb_) & m) ^ ((l >> (2 * lb_)) & m);
    return unsigned(b);
  }
  void defer(Acc::K k, uint64_t line, uint64_t ready = 0, const Op &o = Op{}) {
    bq_[bankOf(line)].push_back({k, now_, ready ? ready : now_, line, o});
  }
  /// A store hit's merged line goes back to its bank gap_ cycles after its
  /// read (MA-17; 4 with ECC, AR 367). Under (a) and (b) a later lookup of
  /// the line waits for it; under (a+f) a write buffer forwards it.
  void storeWrite(uint64_t line, uint64_t read_at) {
    defer(Acc::kStoreW, line, read_at + gap_);
    if (store_ != kStAF) ++held_[line];
  }
  /// Entries of bank b that hold a line or a store's data and mask.
  size_t dataHeld(unsigned b) const {
    size_t n = 0;
    for (const Acc &a : bq_[b])
      n += a.k == Acc::kFillW || a.k == Acc::kStoreW || a.k == Acc::kStoreR ||
           (a.k == Acc::kLook && !isRead(unsigned(get(a.op.req, ch().miu_dcu, "coh_op"))));
    return n;
  }
  bool held(uint64_t line) const {
    auto it = held_.find(line);
    return it != held_.end() && it->second;
  }
  static uint64_t lineOf(const Bits &req) { return get(req, ch().miu_dcu, "phys_addr"); }
  bool olderSameLine(unsigned b, uint64_t line) const {
    for (const Acc &a : bq_[b])
      if (a.line == line && (a.k == Acc::kLook || a.k == Acc::kStoreR)) return true;
    return false;
  }

  std::vector<std::vector<Op>> arr_;
  /// An arrival waits for its bank's turn, except under (b) a store to a
  /// line DCU owns, which merges now and defers its read and write
  /// (lead_store, AR 365 (b)) unless an older lookup of the line waits.
  void arrive(const Op &o) {
    if (arr_.size() != banks_) arr_.resize(banks_);
    const uint64_t pa = lineOf(o.req);
    const unsigned co = unsigned(get(o.req, ch().miu_dcu, "coh_op"));
    if (store_ == kStB && !isRead(co) && k_.brk != "write-through") {
      Way &wy = way(pa);
      // A load of the line that lost its bank, waiting or out on a re-pass,
      // keeps later stores to it from merging past it (else a store-hot
      // line stays held and starves it).
      bool contested = olderSameLine(bankOf(pa), pa) || held(pa) || repassing(pa);
      for (const Op &e : arr_[bankOf(pa)]) contested |= lineOf(e.req) == pa;
      // CCV_P1_DEFCAP: a bank whose entries holding data are at the cap
      // takes the store as a lookup instead (bounded storage, MA-6); it
      // waits in the bank only below the cap, else re-passes (schedule()).
      if (!credit_ && !contested && dataHeld(bankOf(pa)) >= defcap_) {
        contested = true;
        k_.hit("p1_defcap");
      }
      if (wy.valid && wy.line == pa && wy.owned && !contested) {
        mergeInto(wy.data, o.req);
        wy.dirty = true;
        shadow(wy);
        timed_.push_back({now_ + dlat_, {o.slot, rspFor(o.req), o.tid}});
        k_.hit("store_hit");
        defer(Acc::kStoreR, pa);
        ++held_[pa];
        k_.hit("p1_store_deferred");
        // It leaves here, never served as a lookup: forget its first
        // arrival, or a later request reusing its req_id inherits it (it
        // would read as tens of thousands of cycles old, age at once and,
        // under STRICT, answer late).
        born_.erase(get(o.req, ch().miu_dcu, "req_id"));
        return;
      }
    }
    arr_[bankOf(pa)].push_back(o);
  }

  /// A lookup at its bank: a hit answers dlat_ cycles on; a store to an owned
  /// line merges and books its write; anything else takes the stub's miss
  /// path, in order.
  void serveLook(const Op &o) {
    const uint64_t pa = lineOf(o.req);
    const unsigned co = unsigned(get(o.req, ch().miu_dcu, "coh_op"));
    k_.hit("p1_lookup");
    if (!isRead(co) && k_.brk != "write-through") {
      Way &wy = way(pa);
      if (wy.valid && wy.line == pa && wy.owned) {
        const unsigned late = wayPredict(pa);
        mergeInto(wy.data, o.req);
        wy.dirty = true;
        shadow(wy);
        timed_.push_back({now_ + dlat_ + late, {o.slot, rspFor(o.req), o.tid}});
        k_.hit("store_hit");
        storeWrite(pa, now_ + late);
        return;
      }
    }
    if (isRead(co)) {
      if (const Line *l = readHit(o.req)) {
        if (!miss_.empty()) k_.hit("hit_under_miss");
        Bits r = rspFor(o.req);
        putLine(r, field(ch().dcu_miu, "read_data").lsb, *l);
        put(r, ch().dcu_miu, "hit", 1);
        // Strict (CCV_P1_STRICT): a hit that waited for its bank has lost
        // the contract (MA-7), so it answers past the stub's slack.
        const unsigned late = wayPredict(pa);
        timed_.push_back({now_ + dlat_ + std::max(waited_ ? pad_ : 0u, late), {o.slot, r, o.tid}});
        return;
      }
    }
    q_.push_back(o);
  }
  void serve(const Acc &a) {
    switch (a.k) {
    case Acc::kLook:
      if (now_ > a.born) {
        k_.hit("p1_lookup_late");
        k_.hit("p1_wait_sum", now_ - a.born);
        k_.peak("p1_wait_max", now_ - a.born);
        k_.hit(waitBin(now_ - a.born));
      }
      waited_ = unsigned(now_ - a.born);
      born_.erase(get(a.op.req, ch().miu_dcu, "req_id"));
      serveLook(a.op);
      waited_ = 0;
      break;
    case Acc::kStoreR:
      k_.hit("p1_store_read");
      storeWrite(a.line, now_);
      if (held_[a.line]) --held_[a.line];   // storeWrite booked its own hold
      break;
    case Acc::kStoreW:
      k_.hit("p1_store_write");
      if (store_ != kStAF && held_[a.line] && !--held_[a.line]) held_.erase(a.line);
      break;
    case Acc::kFillW: k_.hit("p1_fill_write"); break;
    case Acc::kEvictR: k_.hit("p1_evict_read"); break;
    }
  }
  static const char *waitBin(uint64_t w) {
    static const char *n[] = {"p1_w00", "p1_w01", "p1_w02", "p1_w03", "p1_w04", "p1_w05",
                              "p1_w06", "p1_w07", "p1_w08", "p1_w09", "p1_w10", "p1_w11",
                              "p1_w12", "p1_w13", "p1_w14", "p1_w15", "p1_w16_31",
                              "p1_w32_63", "p1_w64up"};
    return w < 16 ? n[w] : w < 32 ? n[16] : w < 64 ? n[17] : n[18];
  }
  static const char *occBin(size_t n) {
    static const char *b[] = {"p1_q00", "p1_q01", "p1_q02", "p1_q03", "p1_q04", "p1_q05",
                              "p1_q06", "p1_q07", "p1_q08", "p1_q09_15", "p1_q16up"};
    return n < 9 ? b[n] : n < 16 ? b[9] : b[10];
  }
  /// A waiter may go: it is ready, no older lookup of its line waits ahead
  /// of it, and a lookup's line has no store write outstanding.
  bool eligible(unsigned b, size_t i) const {
    const Acc &a = bq_[b][i];
    if (a.ready > now_) return false;
    if (a.k == Acc::kLook || a.k == Acc::kStoreR) {
      if (a.k == Acc::kLook && held(a.line)) return false;
      for (size_t j = 0; j != i; ++j)
        if (bq_[b][j].line == a.line &&
            (bq_[b][j].k == Acc::kLook || bq_[b][j].k == Acc::kStoreR))
          return false;
    }
    return true;
  }
  void schedule() {
    if (arr_.size() != banks_) arr_.resize(banks_);
    size_t dsum = 0;
    for (unsigned b = 0; b != banks_; ++b) {
      std::vector<Op> &in = arr_[b];
      std::stable_sort(in.begin(), in.end(),
                       [](const Op &x, const Op &y) { return x.slot < y.slot; });
      // The oldest eligible waiter, and whether it has reached the bound.
      size_t old = bq_[b].size();
      for (size_t i = 0; i != bq_[b].size(); ++i)
        if (eligible(b, i)) { old = i; break; }
      const bool aged = old != bq_[b].size() && now_ - bq_[b][old].born >= age_;
      // The arrival that may win: the first in slot order from the pointer,
      // with no earlier arrival of its line this cycle and no waiter of it.
      size_t win = in.size();
      if (!aged) {
        const unsigned n = unsigned(in.size());
        unsigned start = 0;
        if (rot_ && n)
          for (unsigned i = 0; i != n; ++i)
            if (in[i].slot >= ptr_[b]) { start = i; break; }
        // CCV_P1_LDFIRST: a first pass takes only reads, so an on-time load
        // beats an on-time store; the store waits as deferred work under the
        // age bound. An earlier arrival of the same line still blocks a later
        // one, so a load never passes an older store to its line.
        for (unsigned pass = ldfirst_ ? 0 : 1; pass != 2 && win == in.size(); ++pass)
          for (unsigned t = 0; t != n && win == in.size(); ++t) {
            const unsigned i = (start + t) % n;
            if (!pass && !isRead(unsigned(get(in[i].req, ch().miu_dcu, "coh_op")))) continue;
            const uint64_t pa = lineOf(in[i].req);
            if (held(pa) || olderSameLine(b, pa)) continue;
            bool earlier = false;
            for (unsigned j = 0; j != i; ++j)
              if (lineOf(in[j].req) == pa) earlier = true;
            if (!earlier) win = i;
          }
        // How often the rule decided: a load won while a store arrived too.
        if (ldfirst_ && win != in.size())
          for (const Op &e : in)
            if (!isRead(unsigned(get(e.req, ch().miu_dcu, "coh_op")))) { k_.hit("p1_ldfirst"); break; }
      }
      if (bfree_[b] <= now_) {
        if (aged) {
          k_.hit("p1_age_hold");
          const Acc a = bq_[b][old];
          bq_[b].erase(bq_[b].begin() + old);
          bfree_[b] = now_ + 2;
          serve(a);
        } else if (win != in.size()) {
          const Op o = in[win];
          in.erase(in.begin() + win);
          ptr_[b] = o.slot + 1;
          bfree_[b] = now_ + 2;
          serve(Acc{Acc::kLook, bornOf(o), now_, lineOf(o.req), o});
        } else if (old != bq_[b].size()) {
          const Acc a = bq_[b][old];
          bq_[b].erase(bq_[b].begin() + old);
          bfree_[b] = now_ + 2;
          if (a.k == Acc::kFillW && !in.empty()) k_.hit("p1_fill_collide");
          serve(a);
        }
      } else if (!in.empty()) {
        k_.hit("p1_bank_busy", in.size());
      }
      // A loser waits in its bank's queue while it has room
      // (CCV_P1_QDEPTH, MA-20 (3)); else it re-passes from MIU's load
      // queue and arrives again CCV_P1_REPASS cycles on (today's scheme).
      size_t waiting = 0;
      for (const Acc &a : bq_[b]) waiting += a.k == Acc::kLook;
      for (const Op &o : in) {
        k_.hit("p1_lost");
        // CCV_P1_DEFCAP also bounds a store that waits as a lookup: it holds
        // its data and mask here, so at the cap it re-passes and its data
        // stays in MIU (RH on MA-7: else the cap never bounds data_peak).
        const bool capped = !credit_ &&
            !isRead(unsigned(get(o.req, ch().miu_dcu, "coh_op"))) && dataHeld(b) >= defcap_;
        if (capped) k_.hit("p1_defcap_repass");
        if (waiting < qdepth_ && !capped) {
          bq_[b].push_back({Acc::kLook, bornOf(o), now_, lineOf(o.req), o});
          ++waiting;
        } else {
          k_.hit("p1_repass");
          born_.emplace(get(o.req, ch().miu_dcu, "req_id"), now_);
          again_.push_back({now_ + repass_, o});
          ++pend_[lineOf(o.req)];
        }
      }
      in.clear();
      size_t looks = 0;
      for (const Acc &a : bq_[b]) looks += a.k == Acc::kLook;
      k_.hit(occBin(looks));
      k_.peak("p1_defer_peak", bq_[b].size());
      // Entries that hold a line or a store's data and mask (MA-5 area): a
      // fill or store write, a store's read, a store lookup; peak per bank,
      // and summed over the banks each cycle.
      const size_t data = dataHeld(b);
      k_.peak("p1_data_peak", data);
      dsum += data;
    }
    k_.peak("p1_data_sum_peak", dsum);
  }

  bool crBusy() const {
    for (const auto &q : cr_)
      if (!q.empty()) return true;
    return false;
  }
  bool busy() const override {
    if (!q_.empty() || !miss_.empty() || !to_mlc_.empty() || !to_miu_.empty() ||
        !promised_.empty() || !timed_.empty() || !again_.empty() || crBusy() ||
        credOwed())
      return true;
    for (const auto &q : bq_)
      if (!q.empty()) return true;
    return false;
  }
};

// ---- MIU -------------------------------------------------------------------------

} // namespace

std::unique_ptr<Block> makeDcuP1(int inst, Kernel &k) { return std::make_unique<DcuP1>(inst, k); }

} // namespace skel
} // namespace ccv
