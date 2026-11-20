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
};

/// A response launched on ccv_dcu_miu_rsp.
struct Rsp {
  unsigned slot = 0, req_id = 0;
  bool data = false;   ///< read_data carries a line
  Line line{};
  bool hit = false, mlc_miss = false;
  uint64_t tid = 0;
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
  unsigned qdepth = 16;                    ///< CCV_DCU_BANK_QDEPTH (MA-25; TI to land)
  unsigned stdata = 12;                    ///< CCV_DCU_BANK_STDATA (MA-25; TI to land)
  bool credits_strict = false;   ///< an overflow fails (once MIU holds credits), else a bin
  unsigned lat_hit = ccv::prov::kLatL1Hit; ///< CCV_LAT_L1_HIT: picks pipe A, B or C
  unsigned wp_bits = ccv::prov::kDcuWaypredBits;     ///< CCV_DCU_WAYPRED_BITS (MA-26)
  bool wp_recent = ccv::prov::kDcuWaypredSel == 1;   ///< CCV_DCU_WAYPRED_SEL: 1 recent, 0 index
  unsigned gap = 5;              ///< a store hit's read to its write (MA-17, TI-483)
  unsigned lat_notice = ccv::prov::kLatFillNotice;   ///< CCV_LAT_FILL_NOTICE
  unsigned merge = 4;            ///< requests a miss buffer holds (MA-12)
  unsigned ids = 1u << ccv::prov::kWReqDcuMlc;       ///< miss buffers: MLC req_ids
  unsigned wb = 2;               ///< the writeback buffer's entries
  bool hash = false;             ///< CCV_DCU_BANK_HASH (MA-20), off
  unsigned ue_every = 0;         ///< CCV_DCU_UE_INJECT: every Nth read hit a UE
  unsigned ue_track = ccv::prov::kDcuUeTrack;   ///< CCV_DCU_UE_TRACK
  std::string brk = "none";      ///< the run's negative control (--break)
};

/// What the block knows of its senders as the cycle starts.
struct Ports {
  std::array<bool, kSlots> rsp_can{};       ///< ccv_dcu_miu_rsp may launch on a slot
  std::array<unsigned, kSlots> rsp_credits{};///< its credits held, per slot
  std::array<bool, kSlots> ntc_can{};       ///< ccv_dcu_miu_fill_ntc may launch
  bool mlc_can = false;                     ///< ccv_dcu_mlc_req may launch
};

struct Out {
  std::vector<Rsp> rsps;
  struct Notice { unsigned slot, req_id; uint64_t tid; };
  std::vector<Notice> notices;   ///< ccv_dcu_miu_fill_ntc launches
  std::optional<MlcReq> mlc;
  bool ue_raise = false;           ///< ccv_dcu_cru_err's sticky ue, launched now
  uint8_t ent_ret = 0, std_ret = 0;///< MA-25's credit-return vectors, a bit a bank
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

  /// May the block take new requests this cycle? False while a missing
  /// request waits for a miss buffer, or for room in its line's merge list:
  /// the hold TI-22 and MA-12 allow, and the only one.
  bool accepting() const { return stalled_.empty(); }
  /// One cycle: `in` the requests whose payload lands now, in slot order;
  /// `fill` MLC's response landing now.
  Out cycle(uint64_t t, const std::vector<Req> &in, const std::optional<Fill> &fill,
            const Ports &p);
  bool busy() const;

  enum class Pipe { A, B, C };
  Pipe pipe() const { return pipe_; }
  unsigned dOff() const { return pipe_ == Pipe::B ? 1 : 0; }    ///< D - P
  unsigned launchOff() const { return pipe_ == Pipe::A ? 2 : 3; }///< launch - D
  unsigned bankOf(uint64_t pa) const;
  /// The line's way, or -1 (tests).
  int wayOf(uint64_t pa) const;
  bool dirtyLine(uint64_t pa) const;
  bool ownedLine(uint64_t pa) const;

  struct Stats {
    uint64_t lookups = 0, hits = 0, misses = 0, merged = 0, losers = 0, waited = 0,
             age_blocks = 0, wp_wrong = 0, wp_right = 0, store_def = 0, rd_wr_cycles = 0,
             fill_wait = 0, fills = 0, evicts = 0, notices = 0, held_cycles = 0,
             rsp_credit_wait = 0, at_qdepth = 0, at_stdata = 0, idle = 0;
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
    uint64_t line = 0, used = 0;
    Line data{};
  };
  std::vector<Way> l1_;
  uint64_t tick_ = 0;
  Way *find(uint64_t pa);
  const Way *find(uint64_t pa) const;
  Way *setOf(uint64_t pa) { return &l1_[size_t((pa / kLineBytes) % c_.sets) * c_.ways]; }
  void touch(Way &w) { w.used = ++tick_; }
  unsigned fold(uint64_t pa) const;
  /// Pipe C: the predicted way of pa's set is its own (true) or another.
  bool predicted(uint64_t pa);

  // ---- the banks and their queues (MA-7, MA-24, MA-25, AR 364) -------------
  struct Acc {
    enum K { Look, StoreR, StoreW, FillW, EvictR } k;
    uint64_t born, ready, line;
    Req req;           ///< Look, StoreR
    unsigned fb = 0;   ///< FillW: its fill buffer
    Line data{};       ///< EvictR: the victim
  };
  std::vector<uint64_t> bfree_;            ///< the first cycle each bank is free
  std::vector<std::deque<Acc>> bq_;        ///< deferred work, oldest first
  std::map<uint64_t, std::vector<Req>> ontime_;   ///< D -> lookups due then
  std::map<uint64_t, unsigned> held_;      ///< line -> its writes not yet done
  std::vector<unsigned> ent_owed_, std_owed_, ent_used_, std_used_;
  void arrive(const Req &r, uint64_t t);
  void schedule();
  void claim(unsigned b);
  bool eligible(unsigned b, size_t i) const;
  bool olderLook(unsigned b, size_t upto, uint64_t line) const;
  void serve(const Acc &a, uint64_t born);
  void serveLook(const Req &r, uint64_t born);
  void entLeave(unsigned b) { ++ent_owed_[b]; --ent_used_[b]; }
  void stdLeave(unsigned b) { ++std_owed_[b]; --std_used_[b]; }
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
  };
  std::map<unsigned, Miss> miss_;
  std::set<unsigned> free_ids_;
  std::deque<Req> stalled_;            ///< missing requests with no buffer yet
  std::deque<MlcReq> to_mlc_;
  std::deque<std::pair<uint64_t, Line>> wbq_;   ///< victims read, waiting for an id
  std::set<uint64_t> wb_lines_;        ///< lines written back, not yet acked
  unsigned wb_pending_ = 0;            ///< victims booked (EvictR queued, or in wbq_)
  bool startMiss(const Req &r);        ///< false: no buffer, the request stalls
  bool needsMlc(const Req &r) const;
  void mlcReq(MlcOp op, uint64_t pa, const Line *d, unsigned id, uint64_t tid);
  void onFill(const Fill &f);
  Way *install(uint64_t pa, const Line &l, bool owned, bool dirty);
  bool canInstall(uint64_t pa);
  std::deque<Fill> fills_;   ///< fills landed, waiting for a victim
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
  const Ports *ports_ = nullptr;

  // ---- machine errors (AR 370, MA-19) -------------------------------------
  unsigned ue_hits_ = 0;
  std::vector<uint64_t> ue_loc_;
  bool ue_raised_ = false, ue_sent_ = false;
  int ueOnHit(Way &w);
};

} // namespace dcu
} // namespace ccv
#endif // CCV_DCU_CORE_H
