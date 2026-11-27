//===-- dcu_core.h - the DCU's cycle-accurate model -----------*- C++ -*-===//
//
// The DCU block (L1 data cache) as MA's Phase 1 architecture times it (the
// DCU tab of the per-block specs, docs/design-snapshots/dcu-spec.md; the live
// doc wins; DI's handoff docs/dcu-impl.md). Every output on the spec's cycle,
// every hold, stall and idle period, every never-happens condition flagged.
// It is NOT an RTL clone: the arrays are values, and only the state the port
// timing needs is kept (Daniel, 2026-11-02 and 2026-11-10).
//
// The core knows nothing of the skeleton: dcu_block.cpp decodes the channels
// into the structs below and packs the core's outputs back, so the unit tests
// (dcu_test.cpp) drive it directly.
//
// THE CYCLE. cycle(t) is called once per cycle. Its inputs are the requests
// whose PAYLOAD lands in DCU in t (P), each one's valid, and with it its set
// index lead, having landed in t-1 (L). Its outputs are what DCU launches in
// t: each one's valid is on the wire in t+1 and its payload in t+2.
//
// THE PIPES (the MIU tab's L1-hit budget: H is MIU's A1, L = H+2, P = H+3).
// A lookup's data-bank access starts in D, and its response launches in
// D + kLaunch:
//   - A, CCV_LAT_L1_HIT 7 (strawman A, the params' value until MA-26 lands):
//     tags and data read on the lead, D = P, launch D+2 (= H+5);
//   - C, CCV_LAT_L1_HIT 8 (way prediction, CCV_DCU_WAYPRED_BITS k > 0): the
//     predicted way's line read in the payload cycle, D = P, launch D+3
//     (= H+6); a mispredict re-reads the true way in a second, ordinary bank
//     access under the half-rate rule and the queue, so it answers at due + 2
//     at the earliest, as a bank-conflict loser does, not as a late hit
//     (DI-2; MA rev 121, AR 390, OA 442; DCU tab rev 56);
//   - B, CCV_LAT_L1_HIT 9 (tag then data): D = P+1, launch D+3 (= H+7).
// A bank is single ported at half rate: an access holds it for D and D+1.
// The bank of each cycle is arbitrated in that cycle, from what DCU holds
// then (the lead of a D = P lookup landed in P-1, so its payload is in hand).
//===----------------------------------------------------------------------===//
#ifndef CCV_DCU_CORE_H
#define CCV_DCU_CORE_H

#include "ccv_params.h"

#include <array>
#include <bitset>
#include <cstdint>
#include <deque>
#include <map>
#include <optional>
#include <set>
#include <string>
#include <vector>

namespace ccv {
namespace dcu {

constexpr unsigned kLineBytes = 128;
using Line = std::array<uint8_t, kLineBytes>;
using Mask = std::bitset<kLineBytes>;
constexpr unsigned kSlots = ccv::prov::kDcacheLookups;

/// What MIU asks (ccv_miu_dcu_req's coh_op, as the block decodes it).
enum class Op { Read, AtomRead, Store };
/// What DCU asks MLC (ccv_dcu_mlc_req's coh_op).
enum class MlcOp { Read, Write, AcquireData, AcquirePerm };

/// A request as it lands (its payload cycle).
struct Req {
  unsigned slot = 0, req_id = 0;
  uint64_t pa = 0;   ///< the line's address (line aligned)
  Op op = Op::Read;
  Mask mask;         ///< a store's byte mask
  Line wdata{};      ///< a store's data
  uint64_t tid = 0;  ///< trace identity, carried to the response
  bool reread = false;   ///< pipe C: the true way's read after a mispredict
  bool ent_gone = false; ///< its entry credit went back already (a re-read, a relook)
  uint64_t born_p = 0;   ///< a store hit's P, its identity in stp_ (model only)
};

/// A response launched on ccv_dcu_miu_rsp.
struct Rsp {
  unsigned slot = 0, req_id = 0;
  bool data = false;   ///< read_data carries a line
  Line line{};
  bool hit = false, mlc_miss = false;
  /// The stored bit in error under `line` (MA-28 (c), AR 401), or -1: the
  /// block sends the check bits of `line` as written and this bit flipped.
  int flip = -1;
  /// A second stored bit in error, or -1: with `flip`, a double-bit syndrome
  /// in one word, a recovered UE's first answer (part 4; TI-528, MI-20).
  int flip2 = -1;
  bool ue_first = false;   ///< a recovered UE's first answer; the fill's is its second
  uint64_t tid = 0;
  /// A late answer read from a bank (a queue waiter or a re-read): it takes
  /// any free slot, lowest bank first, and holds its bank until it leaves
  /// (slice 1, response slots); -1 for a contracted answer, on its own slot.
  int bank = -1;
  /// A fill's answer (slice 2, part 1): its miss buffer entry, which stays
  /// valid until every answer has left; -1 for any other.
  int fid = -1;
  uint64_t born = 0;   ///< the cycle it was owed (a late answer's age)
};

/// A request launched on ccv_dcu_mlc_req.
struct MlcReq {
  unsigned id = 0;
  uint64_t pa = 0;
  MlcOp op = MlcOp::Read;
  bool data = false;
  Line line{};
  uint64_t tid = 0;
};

/// A fill or grant landing from ccv_mlc_dcu_rsp.
struct Fill {
  unsigned id = 0;
  Line line{};
  bool miss = false, own = false;
};

struct Config {
  unsigned sets = ccv::prov::kDcuSets, ways = ccv::prov::kDcuWays;
  unsigned banks = ccv::kDcuBanks;
  unsigned age = ccv::prov::kDcuBankAge;   ///< CCV_DCU_BANK_AGE
  unsigned qdepth = 16;                    ///< CCV_DCU_BANK_QDEPTH (MA-25)
  unsigned stdata = 12;                    ///< CCV_DCU_BANK_STDATA (MA-25)
  bool credits_strict = true;    ///< an overflow fails (MIU holds credits since 92e3d2a2), else a bin
  unsigned lat_hit = ccv::prov::kLatL1Hit; ///< CCV_LAT_L1_HIT: picks pipe A, B or C
  unsigned wp_bits = ccv::prov::kDcuWaypredBits;     ///< CCV_DCU_WAYPRED_BITS (MA-26)
  bool wp_recent = ccv::prov::kDcuWaypredSel == 1;   ///< CCV_DCU_WAYPRED_SEL: 1 recent, 0 index
  bool wp_mru = false;   ///< CCV_DCU_WAYPRED_SEL=mru: the set's MRU way, no tag fold (MA-29, pricing)
  unsigned gap = 5;              ///< a store hit's read to its write (MA-17, TI-483)
  /// Test knob (DI-38, TI-530): MLC's writeback acknowledgement takes
  /// effect this many cycles after it lands, so its line stays in the
  /// writeback buffer longer and a refetch meets it (CCV_DCU_WB_ACK_DELAY).
  unsigned wb_ack_delay = 0;
  /// A fill's victim pick, cycles after F (DI-39, MA rev 177): 1 is the
  /// model's form; 2 is the RTL's (a lead at F+1 from dcu_mshr's F read,
  /// the payload at F+2), its write waiter a cycle later too
  /// (CCV_DCU_VICTIM_AT; priced once TI's tblat lands).
  unsigned victim_at = 1;
  unsigned lat_notice = ccv::prov::kLatFillNotice;   ///< CCV_LAT_FILL_NOTICE
  bool notice = false;           ///< refill notices: off by default, CCV_DCU_NOTICE=1 on (DI-4, MA rev 130)
  unsigned merge = 4;            ///< requests a miss buffer holds (MA-12)
  unsigned ids = ccv::kDcuMshrPerBank;   ///< miss buffers: MLC req_ids (one bank's 16 until MA-34's split)
  unsigned wb = 2;               ///< the writeback buffer's entries
  bool hash = false;             ///< CCV_DCU_BANK_HASH (MA-20), off
  bool no_cycle_conflict = false;///< refuse two lookups due in one bank in one cycle (MIU model: DI-25 (4))
  unsigned ue_every = 0;         ///< CCV_DCU_UE_INJECT: every Nth read hit a UE
  unsigned ue_track = ccv::prov::kDcuUeTrack;   ///< CCV_DCU_UE_TRACK
  unsigned ecc_every = 0;        ///< CCV_DCU_ECC_INJECT: a stored bit of every Nth read hit flipped
  std::string brk = "none";      ///< the run's negative control (--break)
};

/// What the block knows of its senders as the cycle starts.
struct Ports {
  std::array<bool, kSlots> rsp_can{};       ///< ccv_dcu_miu_rsp may launch on a slot
  std::array<unsigned, kSlots> rsp_credits{};///< its credits held, per slot
  std::array<bool, kSlots> ntc_can{};       ///< ccv_dcu_miu_fill_ntc may launch
  bool mlc_can = false;                     ///< ccv_dcu_mlc_req may launch
  bool prb_can = true;                      ///< ccv_dcu_mlc_probe_ack may launch
};

/// A probe landed from ccv_mlc_dcu_probe (slice 2, part 4).
struct Probe {
  unsigned id = 0;     ///< req_id: its probe buffer (4)
  uint64_t pa = 0;     ///< the line
  bool inval = true;   ///< invalidate (else downgrade)
};

/// An ack launched on ccv_dcu_mlc_probe_ack: ack = 1 iff dirty_data carries
/// the line (DCU's reading of the field until MLC's session states it).
struct ProbeAck {
  unsigned id = 0;
  bool data = false;
  Line line{};
};

struct Out {
  std::vector<Rsp> rsps;
  struct Notice { unsigned slot, req_id; uint64_t tid; };
  std::vector<Notice> notices;   ///< ccv_dcu_miu_fill_ntc launches
  std::optional<MlcReq> mlc;
  bool ue_raise = false;           ///< ccv_dcu_cru_err's sticky ue, launched now
  uint8_t ent_ret = 0, std_ret = 0;///< MA-25's credit-return vectors, a bit a bank
  /// Fill buffers freed now (slice 2, part 1): each returns its
  /// ccv_mlc_dcu_rsp credit (written and every answer gone; an
  /// acknowledgement's at once).
  unsigned fill_release = 0;
  std::optional<ProbeAck> prb_ack;   ///< its payload launch returns the probe's credit
};

struct Hooks {
  virtual ~Hooks() = default;
  virtual void fail(const std::string &msg) = 0;
  virtual void hit(const char *bin, uint64_t n = 1) { (void)bin; (void)n; }
  virtual void peak(const char *bin, uint64_t v) { (void)bin; (void)v; }
  /// The harness's view of memory above the testbench: a dirty line's
  /// value, and a line memory holds again (its writeback sent).
  virtual void dirty(uint64_t line, const Line &l) { (void)line; (void)l; }
  virtual void clean(uint64_t line) { (void)line; }
  virtual void fatal() {}   ///< a core-fatal machine error (AR 370)
  /// A read DCU withholds because a core-fatal UE hit it (AR 389, TI-487 (3)).
  virtual void withheld(unsigned req_id) { (void)req_id; }
};

class Core {
public:
  Core(const Config &c, Hooks &h);
  const Config &config() const { return c_; }

  /// May the block take new requests this cycle? False while a missing
  /// request waits for a miss buffer, or for room in its line's merge list:
  /// the hold TI-22 and MA-12 allow, and the only one.
  /// DCU never refuses the channel (MA-12): a miss with no entry waits in
  /// its bank's queue on its entry credit (slice 2, part 1).
  bool accepting() const { return true; }
  /// One cycle: `in` the requests whose payload lands now, in slot order;
  /// `fill` MLC's response landing now.
  Out cycle(uint64_t t, const std::vector<Req> &in, const std::optional<Fill> &fill,
            const Ports &p, const std::optional<Probe> &prb = std::nullopt);
  bool busy() const;

  enum class Pipe { A, B, C };
  Pipe pipe() const { return pipe_; }
  unsigned dOff() const { return pipe_ == Pipe::B ? 1 : 0; }    ///< D - P
  unsigned launchOff() const { return pipe_ == Pipe::A ? 2 : 3; }///< launch - D
  unsigned bankOf(uint64_t pa) const;
  /// The line's way, or -1 (tests).
  int wayOf(uint64_t pa) const;
  /// pa's set's PLRU victim way (tests).
  unsigned victimWay(uint64_t pa) const { return plruVictim(size_t((pa / kLineBytes) % c_.sets)); }
  bool dirtyLine(uint64_t pa) const;
  bool ownedLine(uint64_t pa) const;

  struct Stats {
    uint64_t lookups = 0, hits = 0, misses = 0, merged = 0, losers = 0, waited = 0,
             age_blocks = 0, wp_wrong = 0, wp_right = 0, store_def = 0, rd_wr_cycles = 0,
             fill_wait = 0, fills = 0, evicts = 0, notices = 0, held_cycles = 0,
             rsp_credit_wait = 0, at_qdepth = 0, at_stdata = 0, idle = 0, ce = 0, ce_full = 0;
  };
  const Stats &stats() const { return st_; }

private:
  Config c_;
  Hooks &h_;
  Pipe pipe_ = Pipe::A;
  uint64_t now_ = 0;
  Stats st_;

  // ---- the arrays: tags, state, LRU, data -----------------------------------
  struct Way {
    bool valid = false, owned = false, dirty = false;
    int flip = -1;     ///< a stored data bit in error (CCV_DCU_ECC_INJECT), or -1
    bool ecc_wr = false;   ///< its corrected line's rewrite is queued
    uint64_t line = 0, used = 0;
    Line data{};
    int rsv = -1;   ///< the fill entry that chose it as victim, until its write (W)
    bool fvalid = false;   ///< dcu_bctl's fold valid bit (tracks valid; part 4's CHECK)
  };
  std::vector<Way> l1_;
  uint64_t tick_ = 0;
  Way *find(uint64_t pa);
  const Way *find(uint64_t pa) const;
  Way *setOf(uint64_t pa) { return &l1_[size_t((pa / kLineBytes) % c_.sets) * c_.ways]; }
  /// Each set's tree-PLRU bits (MA-30: ways - 1 of them, 7 at 8 ways, in
  /// dcu_bctl's flops). Node n's children are 2n+1 and 2n+2; a bit points at
  /// the half the next victim comes from, and a touch points it away.
  std::vector<uint8_t> plru_;
  void touch(Way &w) {
    w.used = ++tick_;
    const size_t i = size_t(&w - l1_.data());
    plruTouch(i / c_.ways, unsigned(i % c_.ways));
  }
  void plruTouch(size_t set, unsigned way);
  /// A lookup's hit touches its way a cycle after its D2 (D + 3), winner or
  /// bank-conflict loser alike, and only then (dcu_bctl: pu_q, MA's DI-26
  /// answer): a queued serve and a mispredict's re-read touch nothing more.
  /// Kept by way, as the RTL's update is: (cycle, way index). Only the PLRU
  /// bits wait: a way's recency (`used`, the wp-mru predictor's) moves at
  /// serve, as before.
  std::multimap<uint64_t, size_t> touch_at_;
  void touchLater(const Way &w) { touch_at_.emplace(now_ + 3, size_t(&w - l1_.data())); }
  void plruTouchWay(size_t i) { plruTouch(i / c_.ways, unsigned(i % c_.ways)); }
  unsigned plruVictim(size_t set) const;
  unsigned fold(uint64_t pa) const;
  /// The way the predictor names for pa (nullptr with no fold match);
  /// read before the hit touches LRU.
  const Way *predictedWay(uint64_t pa);
  /// The control that completes a mispredict at due with the predicted way's
  /// line: wp-late-at-due, or dcu-wp-nocompare (AR 405, TI-518).
  bool noCompare() const { return c_.brk == "wp-late-at-due" || c_.brk == "dcu-wp-nocompare"; }
  /// Pipe C: the predicted way of pa's set is its own (true) or another.
  bool predicted(uint64_t pa);
  /// Whether any valid way of pa's set has pa's fold (slice 1: no match is
  /// a miss with no data read).
  bool foldMatch(uint64_t pa);

  // ---- the banks and their queues (MA-7, MA-24, MA-25, AR 364) -------------
  struct Acc {
    enum K { Look, StoreR, StoreW, FillW, EvictR, EccR, EccW, MissW, Prb } k;
    uint64_t born, ready, line;
    Req req;           ///< Look, StoreR
    unsigned fb = 0;   ///< FillW: its fill buffer
    Line data{};       ///< EvictR: the victim
    int tway = -1;     ///< Look: the way its tag result named, a hit (tag-stale marking)
    bool stale = false;   ///< Look: a fill wrote that way since: it reads its tags again
    uint64_t stamp = 0;   ///< MissW: when it became its bank's head, or last waited again (the retry pick's age; DI-35)
    bool headed = false;  ///< MissW: it has been its bank's head (stamped then)
  };
  std::vector<uint64_t> bfree_;            ///< the first cycle each bank is free
  std::vector<std::deque<Acc>> bq_;        ///< deferred work, oldest first
  std::map<uint64_t, std::vector<Req>> ontime_;   ///< D -> lookups due then
  std::map<uint64_t, unsigned> held_;      ///< line -> its writes not yet done
  std::vector<unsigned> ent_owed_, std_owed_, ent_used_, std_used_;
  std::vector<unsigned> seen_ent_, seen_std_;  ///< last cycle's counts, so an overflow is refused once
  void arrive(const Req &r, uint64_t t);
  void schedule();
  void claim(unsigned b);
  bool eligible(unsigned b, size_t i) const;
  /// An older lookup of `line` ahead of position `upto` that this one may
  /// not pass (slice 2, part 3): a store ahead of anything, or anything
  /// ahead of a store (`store`); loads pass loads.
  bool olderLook(unsigned b, size_t upto, uint64_t line, bool store = true) const;
  static bool storeLike(const Acc &x) { return x.k == Acc::StoreR || (x.k == Acc::Look && x.req.op == Op::Store); }
  /// Store hits' writes, booked at their read (part 3): cycle -> the write.
  std::vector<std::multimap<uint64_t, Acc>> book_;
  bool bookable(unsigned b) const;
  /// Stores between arrival and write, by line: their P (part 3's CHECK).
  std::multimap<uint64_t, uint64_t> stp_;
  /// Merged stores' store-data credits, due back at their merge (part 3).
  std::multimap<uint64_t, unsigned> std_at_;
  void serve(const Acc &a, uint64_t born);
  void serveLook(const Req &r, uint64_t born);
  void entLeave(unsigned b) { ++ent_owed_[b]; --ent_used_[b]; }
  std::multimap<uint64_t, unsigned> wb_ack_due_;   ///< wb_ack_delay: cycle -> the acked id
  void wbAcked(unsigned id);
  /// The RTL's credit timing (DI-36): an entry leaves at its D2 hit or its
  /// placement (D3), not its access; the return goes out from cycle t.
  void entLeaveAt(unsigned b, uint64_t t) { ent_due_.emplace(t, b); }
  void entLeave(unsigned b, const Req &r, uint64_t t) { if (!r.ent_gone) entLeaveAt(b, t); }
  std::multimap<uint64_t, unsigned> ent_due_;
  void stdLeave(unsigned b);
  bool held(uint64_t line) const { auto it = held_.find(line); return it != held_.end() && it->second; }
  void hold(uint64_t line) { ++held_[line]; }
  void unhold(uint64_t line);

  // ---- the miss path (MA-12): buffers by MLC req_id, merged requests -------
  enum class MK { Fill, AcqData, AcqPerm, Evict, RmwRead, WriteAck };
  struct Miss {
    MK k;
    uint64_t line;
    std::vector<Req> reqs;   ///< the primary first, then merged, in order
    Line wb{};               ///< Evict, RmwRead's write: the line out
    // Slice 2, parts 1-2: a fill held in its fill buffer from F until its
    // write (W) and its last answer; then, for a dirty victim, the entry
    // turns into the victim's writeback until MLC acknowledges it.
    bool filled = false, written = false, fb = false;
    uint64_t f_at = 0;       ///< F: the fill's payload landed
    unsigned owed = 0;       ///< answers not yet launched
    int way = -1;            ///< the way chosen at F+1 (index into l1_)
    Line fl{};               ///< the fill buffer's line
    bool fown = false, fdirty = false;
    uint64_t vline = 0;      ///< the dirty victim's line, written back at W
    bool vdirty = false, vread = false, acked = false;
    std::vector<Req> relook; ///< merged requests that look up again after W
    unsigned kst = 0;        ///< stores merged into the fill buffer (part 3)
    bool pcancel = false;    ///< a probe took its unlaunched writeback (part 4, AR-409)
    bool vnofree = false;    ///< its pick found no free way once (DI-43's bound then is not its)
  };
  static Miss newMiss(MK k, uint64_t line, std::vector<Req> reqs, const Line &wb) {
    Miss m;
    m.k = k;
    m.line = line;
    m.reqs = std::move(reqs);
    m.wb = wb;
    return m;
  }
  std::map<unsigned, Miss> miss_;
  std::set<unsigned> free_ids_;
  /// Miss buffer ids are offered a cycle ahead (spec DCU tab rev 110; the
  /// RTL's rule, rtl/dcu/dcu_mshr.sv): each MSHR port (0 the retry, 1 + slot
  /// a slot's new miss) holds an offer, the id it allocates. A requesting
  /// port's offer is taken whatever it did; it, and a port with none, takes
  /// the next of last cycle's picks in port order. Picks (lowest, highest,
  /// second lowest, second highest, third lowest) come from the free ids,
  /// one freed now too, less the offers, the picks and the offers taken
  /// last cycle; so an id freed or left unused is offered two cycles on.
  static constexpr unsigned kNfIds = 5;   ///< MSHR ports
  std::array<std::optional<unsigned>, kNfIds> nf_;
  std::vector<unsigned> pk_;
  std::set<unsigned> ua_;      ///< offers taken last cycle
  std::set<unsigned> freed_;   ///< ids freed this cycle
  unsigned nf_pq_ = 0;         ///< this cycle's requesting ports (a mask)
  void nfNext();
  void freeId(unsigned id);
  static std::vector<unsigned> offerOrder(const std::vector<unsigned> &av);
  std::deque<std::pair<uint64_t, MlcReq>> to_mlc_;   ///< (its D2, the request), oldest first
  std::set<uint64_t> wb_lines_;        ///< lines written back, not yet acked
  unsigned wb_used_ = 0;               ///< writeback buffers: victim read, request not yet launched
  std::deque<unsigned> wbsend_;        ///< writeback entries unsent, oldest first
  std::deque<unsigned> vpend_;         ///< fills whose victim is not chosen yet
  std::vector<size_t> wnow_;           ///< ways a fill writes this cycle (W; DI-43's reservation)
  void pickVictims();                  ///< the RTL's form: one snapshot a bank a cycle (DI-43)
  unsigned fill_release_ = 0;          ///< this cycle's freed fill buffers
  bool pickVictim(unsigned id);        ///< F+1: choose, reserve and touch; false if none
  void fillWrite(unsigned id);         ///< W
  void answered(unsigned id);          ///< one of its answers launched
  void maybeFree(unsigned id);
  /// Merge or allocate; false (and why) if the miss must wait.
  bool startMiss(const Req &r, uint64_t d2, unsigned port, const char **why = nullptr);
  /// A miss whose entry credit has gone home: merge or allocate now, or wait
  /// in its bank's queue (MissW), taking the credit back until it leaves.
  void missOrWait(const Req &r, uint64_t d2, bool late = false);
  void retryWaits();                   ///< each bank's oldest waiting miss, one a cycle
  bool needsMlc(const Req &r) const;
  /// A dirty victim a fill has reserved (slice 2, part 2): its stores wait.
  bool rsvDirty(const Way *w) const;
  /// A line whose writeback awaits MLC's ack: its lookups wait (part 2);
  /// dcu-wb-refetch, the control, lets them miss and fetch it again.
  bool inWb(uint64_t line) const { return wb_lines_.count(line) && c_.brk != "dcu-wb-refetch"; }
  Way *stale_way_ = nullptr;   ///< dcu-fill-nostale: the way a stale lookup reads
  /// DI-42: each set's last two cycles a fill's write changed its fold-table
  /// entry (dcu_bctl's second writer); a lookup whose D0 read the row in one
  /// of them, or a cycle after, takes the mispredict's re-read.
  std::map<size_t, std::pair<uint64_t, uint64_t>> ftw_;
  bool inMargin(uint64_t pa, uint64_t d0) const {
    const auto it = ftw_.find(size_t((pa / kLineBytes) % c_.sets));
    if (it == ftw_.end()) return false;
    for (uint64_t e : {it->second.first, it->second.second})
      if (e != ~0ull && (e == d0 || e + 1 == d0)) return true;
    return false;
  }
  void mlcReq(MlcOp op, uint64_t pa, const Line *d, unsigned id, uint64_t tid, uint64_t d2);
  void onFill(const Fill &f);
  Way *install(uint64_t pa, const Line &l, bool owned, bool dirty);
  static bool fullLine(const Req &r, const std::string &brk);
  void merge(Line &l, const Req &r) const;

  // ---- responses: on time, promised (OA-23), and waiting for a credit ------
  struct Timed { uint64_t at; Rsp r; };
  std::multimap<uint64_t, Rsp> timed_;     ///< launch cycle -> response
  std::deque<Rsp> late_;                   ///< owed, waiting for a slot's credit
  std::multimap<uint64_t, Rsp> promised_;  ///< noticed refills, at their cycle
  std::array<unsigned, kSlots> resv_{};    ///< promises not yet sent, per slot
  std::set<std::pair<uint64_t, unsigned>> promise_at_;   ///< (cycle, slot) taken
  std::vector<Out::Notice> notices_;   ///< this cycle's
  void respond(uint64_t at, const Rsp &r) { timed_.emplace(at, r); }
  Rsp rspFor(const Req &r) const;
  /// A refill's answer: noticed if its slot can take a notice and a credit
  /// beyond its promises, at a cycle not already promised; else sent as it can.
  void refill(const Rsp &r, const Ports &p);
  /// An un-noticed answer to a fill whose payload landed now: its valid at
  /// F + CCV_LAT_FILL_NOTICE (DI-4), so it launches a cycle earlier.
  uint64_t floorAt() const { return now_ + c_.lat_notice - 1; }
  const Ports *ports_ = nullptr;

  // ---- machine errors (AR 370, MA-19) -------------------------------------
  unsigned ue_hits_ = 0;
  std::vector<uint64_t> ue_loc_;
  /// Recovered UEs' req_ids awaiting their second answer, from a fill
  /// (part 4): (slot, req_id) -> the cycle of the first.
  std::map<std::pair<unsigned, unsigned>, uint64_t> ue_open_;
  static constexpr uint64_t kUeAnswerBound = 2000;
  // ---- probes (slice 2, part 4) ----
  static constexpr unsigned kPrbBufs = 4;   ///< ccv_mlc_dcu_probe's credits
  struct PrbBuf {
    Probe p;
    enum S { Start, WaitW, Queued, Done } s = Start;
    int wfid = -1;          ///< WaitW: the entry whose fill write it waits for
    bool dirty = false;     ///< the line was dirty: the ack must carry it
    bool wb = false;        ///< its data holds a writeback buffer until the ack
    int wbid = -1;          ///< the writeback it cancelled, freed with the ack
    ProbeAck ack;
  };
  std::map<unsigned, PrbBuf> prb_;
  std::deque<unsigned> prb_done_;   ///< acks, in the order their probes finished
  void probeStart(unsigned id);
  void probeServe(unsigned id);
  void probeDone(unsigned id, const char *bin);
  bool ue_raised_ = false, ue_sent_ = false;
  unsigned ecc_hits_ = 0;
  /// dcu_fix (slice 1, DI-18): one rewrite in flight (its read, then its
  /// write 5 cycles on) and one pending, block-wide; the front is in flight.
  std::deque<uint64_t> fix_;
  static constexpr uint64_t kFixRdWr = 5;   ///< read to write (fix, flop, encode, flop)
  static constexpr uint64_t kFixStart = 5;  ///< the CE's read access to its rewrite's read request (D1 to past D5)
  void fixStart(uint64_t ready);
  void fixDone();
  /// A read hit's SECDED check (MA-28 (c), AR 401): the injection, and on a
  /// non-zero syndrome the correction's rewrite, queued like an RMW's write.
  int eccOnHit(Way &w, const Req &r);
  int ueOnHit(Way &w);
};

} // namespace dcu
} // namespace ccv
#endif // CCV_DCU_CORE_H
