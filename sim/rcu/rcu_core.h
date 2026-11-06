//===-- rcu_core.h - the RCU's cycle-accurate model -----------*- C++ -*-===//
//
// The RCU block as the CCV RCU Architecture spec times it
// (docs/design-snapshots/rcu-arch-*.md; the live doc wins): every output on
// the spec's cycle, every register-file write in the cycle it lands, every
// hazard and stall the spec implies, and the idle periods. It is NOT an RTL
// clone: the register file is values, and only the state the port timing
// needs is kept (Daniel, 2026-11-02; docs/rcu-impl.md section 5).
//
// The core knows nothing of the skeleton: rcu_block.cpp decodes the
// channels into the structs below and packs the core's outputs back, so the
// unit tests (rcu_test.cpp) drive it directly.
//
// THE CYCLE. cycle(t) is called once per cycle. Its inputs are the messages
// whose PAYLOAD is on RCU's input wires in t (the skeleton's receivers hand
// a message over in its payload cycle). Its outputs are the messages RCU
// launches in t: each one's valid is on the wire in t+1 and its payload in
// t+2. So for an issue in A (its payload cycle):
//   - a lane op, an address and an R done are launched in A (valid A+1);
//   - an R op's write lands in A+2; a lane op's in A + CCV_LAT_LANE - 1 (A+6 at 7, A+7 at 8);
//   - a lane op's done is launched in A+5 (valid A+6), from its descriptor,
//     not from its results.
// A write that lands in W is readable from W+1. Reads in A (guards,
// predicate sources, R0/R1) see writes up to W = A-1 plus MIU's writes in A
// (the guard's and R0/R1's MIU forward); reads in A+1 (lane, memop, R2)
// see writes up to W = A. A same-cycle hazard the spec says never happens
// is a failure, not a stall.
//===----------------------------------------------------------------------===//
#ifndef CCV_RCU_CORE_H
#define CCV_RCU_CORE_H

#include "ccv_params.h"

#include <algorithm>
#include <array>
#include <cstdint>
#include <deque>
#include <functional>
#include <map>
#include <optional>
#include <set>
#include <string>
#include <vector>

namespace ccv {
namespace rcu {

constexpr unsigned kLanes = 32;
constexpr unsigned kSecs = ccv::kSections;
constexpr unsigned kAllSecs = (1u << kSecs) - 1;
constexpr unsigned kPipes = ccv::kMiuPipes;
constexpr unsigned kRes = ccv::kIssueResources;
constexpr unsigned kSlotS0 = 0, kSlotP0 = kSecs, kSlotR = kSecs + kPipes;
static_assert(kSlotR + 1 == kRes, "issue slots are S0-S3, P0-P3, R");
constexpr unsigned kPorts = ccv::prelim::kOperandsPerLane + 1;   ///< 3 operands + merge_data
constexpr unsigned kMergePort = kPorts - 1;
constexpr unsigned kRows = ccv::prov::kPhysRegs, kZero = ccv::prov::kPhysZero;
constexpr unsigned kPRows = ccv::prov::kPredRegs, kPZero = ccv::prov::kPredZero;
constexpr unsigned kArchGprs = ccv::kGprs, kArchPreds = ccv::kPreds;
constexpr unsigned kMigRows = kArchGprs + 1;   ///< R0-R15, then the predicate row
constexpr unsigned kDoneSlots = ccv::prov::kDoneSlots;
/// Fixed done slots (RA-29 (b); Done tab): a lane op's lead section k on
/// slot k, SFU on 4, RCU-only on CCV_DONE_SLOT_RCU (5), collectives on 6.
constexpr unsigned kDoneSfu = kSecs, kDoneRcu = ccv::prov::kDoneSlotRcu, kDoneColl = kDoneRcu + 1;
static_assert(kDoneColl < kDoneSlots, "the collective done slot is a slot");
/// W = A + LAT - 1 for the fixed-latency write-backs (Pipeline tab).
constexpr unsigned kLaneW = ccv::prov::kLatLane - 1;
constexpr unsigned kSfuW = ccv::prov::kLatSfu - 1;
constexpr unsigned kRW = 2;   ///< R's write, A+2: the A+2 rule (RA-29 (a))
static_assert(kRW + 1 == ccv::prov::kLatRcu, "R writes at A+2, readable at A + CCV_LAT_RCU");
/// The lane bypass window (Lane and memory tab): ages LAT_LANE_BYP to LAT_LANE - 2.
constexpr unsigned kBypLo = ccv::prov::kLatLaneByp, kBypHi = ccv::prov::kLatLane - 2;
/// KILL_DRAIN = 2 + link(issue) + CCV_LAT_SFU + 1 + link(done), 15 abutted at SFU 12, 16 at 13
/// (Done tab). The parameter is RA-16 (g), still to land; the links' extra
/// stages come from the block (Config).
constexpr unsigned kKillDrainBase = 2 + ccv::prov::kLatSfu + 1;

using Word = std::array<uint32_t, kLanes>;   ///< one 32-bit element a lane

inline unsigned spanOf(unsigned chw) { return chw == 0 ? 4u : chw == 1 ? 2u : 1u; }
inline uint32_t elemMask(unsigned chw) { return chw == 0 ? ~0u : (1u << (32u >> chw)) - 1u; }
/// The sections a register of width code `chw` at `pos` occupies.
inline unsigned secMask(unsigned chw, unsigned pos) { return ((1u << spanOf(chw)) - 1u) << pos; }
inline uint32_t byteMask(unsigned secs) {
  uint32_t m = 0;
  for (unsigned k = 0; k != kSecs; ++k)
    if ((secs >> k) & 1u) m |= 0xffu << (8 * k);
  return m;
}

// ---- the issue, decoded -------------------------------------------------------

/// What executes it (the op-class decode, Pipeline tab).
enum class Unit : uint8_t { Lane, Sfu, Mem, ROnly, Coll, Copy, PredCopy };
enum class RKind : uint8_t { None, Bra, Call, Ret, Pand, Por, Pxor, PmovImm, Movi, ShflIdxImm,
                             ShflIdxReg, ShflUp, ShflDown, ShflBfly, VoteAny, VoteAll, Ballot,
                             Unballot };
enum class MemKind : uint8_t { None, Load, Store, PredLoad, PredStore, Fence };

/// The decoded class fields (Pipeline tab, "Op-class decode"), filled by the
/// block from its op table: the core compares no opcode.
struct OpClass {
  Unit unit = Unit::Lane;
  RKind rk = RKind::None;
  MemKind mk = MemKind::None;
  bool guarded = false;   ///< the guard narrows active
  bool pdata = false;     ///< the guard port is data: active = issue mask
  bool gdst = false;      ///< writes a GPR
  int imm_slot = -1;      ///< lane operand port the immediate replaces, or -1
  bool imm_used = false;  ///< the payload's imm is read (the lead's imm promise)
  unsigned reads = 0;     ///< GPR source ports 0-2 read
  int base_src = -1, index_src = -1, data_src = -1;   ///< memop operand map
};

struct Lead {   ///< the issue lead slice (RA-31), as the payload's lead fields
  unsigned sec = 0, src = 0;
  bool imm = false, merge = false, guard = false;
  unsigned gpred = 0;
};

struct Issue {
  bool cont = false;
  unsigned tag = 0, done_row = 0, warp = 0;
  uint32_t issue_mask = 0;
  std::array<unsigned, 3> src{}, src_pos{}, src_w{};
  unsigned dst = kZero, dst_pos = 0, dst_w = 0, old_dst = kZero, old_pos = 0;
  unsigned pguard = kPZero, pdst = kPZero, pold = kPZero;
  bool pneg = false, pwe = false, merge = false;
  unsigned foot = 0;
  uint32_t imm = 0;
  unsigned opcode = 0;   ///< carried to the lanes as sec_opcode, never decoded here
  Lead lead;
  OpClass oc;
  uint64_t tid = 0;      ///< trace identity, for the block's checks only
  const char *name = ""; ///< the op's name, for messages only
};

// ---- the other inputs -----------------------------------------------------------

/// ccv_lane_rcu_res from all 32 lanes, one message a cycle (lockstep).
struct LaneRes {
  Word result{};
  std::array<uint8_t, kLanes> sec_valid{}, sec_pred_out{};
};
struct MiuData {
  uint32_t active = 0, pred_result = 0;
  unsigned dst = kZero, pos = 0, w = 0, ppred = kPZero;
  bool pwe = false;
  Word data{};
  uint64_t tid = 0;
};
struct MapMsg {
  unsigned warp = 0, dir = 0;
  std::array<unsigned, kArchGprs> gpr{};
  std::array<unsigned, kArchPreds> pred{};
};
struct CmdMsg { unsigned warp = 0, dir = 0; };
struct MigRow { unsigned warp = 0, row = 0; Word data{}; };

struct In {
  std::array<std::optional<Issue>, kRes> iss;
  std::optional<LaneRes> lres;
  std::array<std::optional<MiuData>, kPipes> mdat;
  std::optional<MapMsg> map;
  std::optional<CmdMsg> cmd;
  std::optional<MigRow> pca;   ///< a row from PCA, landed this cycle
  bool pca_can_send = true;    ///< rcu_pca_mig has a credit and no stall (can())
  /// Fixed-latency outputs with no credit: sending on one is a failure.
  std::array<bool, kDoneSlots> done_can{};
  std::array<bool, kPipes> addr_can{};
  bool lane_can = true;
};

// ---- outputs --------------------------------------------------------------------

/// One section of the lane message.
struct LaneSec {
  bool en = false;
  unsigned owner = 0, opcode = 0;
  std::array<unsigned, kPorts> pos{}, w{}, byp{};
  unsigned dst_pos = 0, dst_w = 0;
};
/// rcu_lane_ops, the same control on every lane; operands per lane.
struct LaneMsg {
  std::array<LaneSec, kSecs> sec;
  std::array<std::array<uint32_t, kPorts>, kLanes> opnd{};   ///< ports 0-2, then merge_data
  std::array<uint8_t, kLanes> pred_bit{}, pred_data{};       ///< per lane, a bit per section
  uint64_t tid = 0;                                          ///< the lowest slot's op
};
struct Done {
  unsigned slot = 0, tag = 0, row = 0;
  bool bt = false, lbt = false;
  uint32_t bm = 0, aux = 0, lbm = 0;
  bool aux_set = false;   ///< slot-field-aux: an aux the slot does not define
  uint64_t tid = 0;
};
struct Addr {
  unsigned slot = 0, tag = 0;
  uint32_t active = 0;
  Word base{}, index{}, data{};
  uint64_t tid = 0;
};

struct Out {
  std::optional<LaneMsg> lane;
  std::vector<Done> dones;
  std::vector<Addr> addrs;
  std::optional<MigRow> pca;
  /// Credits to return this cycle (each on the wire next cycle): the block
  /// takes one message off that receiver. Map and command entries free at
  /// launch or a kill drop; PCA rows when written or popped dead.
  bool map_credit = false, cmd_credit = false, pca_credit = false;
};

// ---- events ---------------------------------------------------------------------

/// What happens inside RCU, each in its cycle (docs/rcu-impl.md section 5).
/// schema/events.json has no RCU events yet; until it does these are the
/// model's own log, which the unit tests and the RTL lock-step read.
enum class Ev : uint8_t {
  GprWrite,     ///< a: row, b: lanes, c: sections, d: port
  PredWrite,    ///< a: row, b: value written, c: lanes changed mask, d: port
  Branch,       ///< a: rob_tag, b: taken, c: branch_mask, d: aux
  GuardFwd,     ///< a: slot, b: MIU slot, c: predicate row
  RsrcFwd,      ///< a: R source (0/1), b: MIU slot, c: row
  BypassSel,    ///< a: slot, b: port, c: select, d: sections
  KillDrain,    ///< a: mask, b: epoch, c: KILL_DRAIN
  KillAck,      ///< a: epoch
  MigPair,      ///< a: warp, b: direction
  MigRowOut,    ///< a: warp, b: mig_row
  MigRowIn,     ///< a: warp, b: mig_row (written)
  MigWaitR,     ///< a: warp, b: next row: R2 (demote) or RW (restore) taken by R
  MigWaitCredit,///< a: warp, b: next row: no rcu_pca_mig credit or a stall
  RestoreHold,  ///< a: warp at the FIFO head waiting for its pairing
  RestoreDone,  ///< a: warp
  Idle,         ///< RCU quiesced: its block gate may close
  Wake,         ///< RCU busy again
};
const char *evName(Ev e);
struct Event { uint64_t t = 0; Ev ev = Ev::Idle; uint32_t a = 0, b = 0, c = 0, d = 0; };

// ---- configuration and hooks ----------------------------------------------------

struct Config {
  /// Repeater stages on the issue and done links (params/links.json), for
  /// KILL_DRAIN.
  unsigned issue_stages = 0, done_stages = 0;
  /// AR-24's interim on a full row (this build: no narrowing; the RTL's
  /// FULL_ROW, Register file tab rev 7, run lock-step at one setting): SW, MW and RW
  /// write a narrow register zero-extended across all four banks, so a row
  /// holds one register and is zero above its element. Off, they write
  /// secmask(width, pos) only, as the Register file tab says.
  bool full_row = false;
  /// Negative controls (tools/check-kernel.sh), by name; empty for none.
  std::string brk;
  /// CCV_RCU_KILL_DRAIN_CUT=<n>: the kill drain n cycles short (M4's control).
  unsigned kill_drain_cut = 0;
};

/// What the core reports to its host. fail() is a check failure (a contract
/// the spec says never breaks); the rest are observations for the host's
/// checks against the oracle, which the core never consults.
struct Hooks {
  virtual ~Hooks() = default;
  virtual void fail(const std::string &msg) = 0;
  virtual void event(const Event &) {}
  /// An R op's result at compute (A+1), before its write: the GPR value on
  /// the lanes it writes (lanes, under em) and/or the predicate as written,
  /// merged with its old destination.
  virtual void rResult(const Issue &, uint32_t /*lanes*/, const Word & /*gnew*/, uint32_t /*em*/,
                       bool /*pw*/, uint32_t /*pval*/) {}
  /// A branch or ret outcome, as its done carries it.
  virtual void branch(const Issue &, const Done &) {}
  /// A restore's predicate row was written: the warp's maps are its restore map's.
  virtual void restored(const MapMsg &) {}
  /// A coverage bin (Kernel::hit): lane_byp, pred_copy.
  virtual void hit(const char *) {}
};

/// The register files RCU holds: the block points them at the testbench's
/// (Kernel::gpr, Kernel::pred), which the final-state compare reads.
struct Files {
  std::vector<Word> *gpr = nullptr;
  std::vector<uint32_t> *pred = nullptr;
};

class Core {
public:
  Core(const Config &cfg, Files f, Hooks &h);

  void cycle(uint64_t t, const In &in, Out &out);
  /// The kill's mask cycle K (schema kill_valid leads it by one).
  void kill(uint32_t mask, unsigned epoch);
  /// Ack-ready (Done tab): the drain is over and migration holds nothing of
  /// a killed warp.
  bool killQuiet() const;
  /// rcu_idle_q: nothing in flight, nothing pending (Done tab, block gate).
  bool idle() const { return idle_; }
  uint64_t idleCycles() const { return idle_cycles_; }
  const Config &config() const { return cfg_; }
  /// KILL_DRAIN at the build's links, less kill_drain_cut (M4's control).
  unsigned killDrain() const { return kKillDrainBase + cfg_.issue_stages + cfg_.done_stages - cfg_.kill_drain_cut; }

  /// Statistics for the M5 report and the sweep.
  struct Stats {
    uint64_t lane_ops = 0, r_ops = 0, memops = 0, dones = 0, gpr_writes = 0, pred_writes = 0;
    uint64_t byp_sels = 0, demote_rows = 0, restore_rows = 0, mig_r_waits = 0,
             mig_credit_waits = 0, restore_holds = 0, max_demote_cycles = 0, max_restore_cycles = 0;
  };
  const Stats &stats() const { return st_; }

private:
  // Writes, landing in a cycle.
  struct GWrite {
    unsigned port, row, secs;
    uint32_t lanes;
    Word data;   ///< each lane's word, already steered: only secs's bytes are written
    int slot = -1;   ///< the MIU slot of an MW write
  };
  struct PWrite {
    unsigned port, row;
    uint32_t m;            ///< lanes written
    uint32_t val, mm;      ///< D = (old & ~mm) | (val & mm), old read at write time
    int oldrow;            ///< the old destination's row, or -1 for 0
    bool miu;
    int slot = -1;         ///< the MIU slot of a PM write
  };
  /// A lane op in flight, from its issue to its write-back.
  struct LaneDesc {
    unsigned lead, secs;   ///< lead section and owned sections
    bool gdst, copy, pwe, merge, sfu;
    unsigned dst, dst_pos, dst_w, pdst, pold;
    uint32_t active;
    unsigned tag, done_row;
    uint64_t tid, a;
    uint64_t acc;   ///< the issue's A, where RCU took it (a held copy leaves later)
    int dslot = -1; ///< a done slot other than the lead's (movi-in-lane's movi keeps R's)
  };
  /// The bypass history: a lane producer of a GPR, by issue cycle.
  struct Producer { uint64_t a; unsigned row, pos, secs, lead; };
  // Migration.
  struct MapEnt { MapMsg m; uint64_t landed; unsigned id; };
  struct CmdEnt { CmdMsg c; uint64_t landed; unsigned id; };
  struct FifoEnt { MigRow r; bool dead; };
  struct Pick { bool v = false; unsigned mi = 0, ci = 0, warp = 0; };   ///< entry ids

  uint32_t rdPred(unsigned row) const;
  uint32_t rdGpr(unsigned row, unsigned lane) const;
  /// A register's value on every lane, right-aligned and zero-extended.
  Word rdReg(unsigned row, unsigned pos, unsigned w) const;
  void gatherWrites(uint64_t t, const In &in, std::vector<GWrite> &gw, std::vector<PWrite> &pw);
  void commit(const std::vector<GWrite> &gw, const std::vector<PWrite> &pw, bool miu);
  bool hazardG(unsigned row, unsigned secs = kAllSecs) const;   ///< a non-MIU GPR write in t
  bool hazardP(unsigned row) const;                             ///< a non-MIU predicate write in t
  void checkIssues(const In &in, std::array<int, kRes> &owner);
  void issueR(uint64_t t, const Issue &is, uint32_t active, const Word &r0, const Word &r1,
              uint32_t rpa, uint32_t rpb, Out &out);
  void issueMem(const Issue &is, unsigned slot, uint32_t active, uint32_t pstore, Out &out);
  void migrate(uint64_t t, const In &in, bool r2_busy, bool rw_busy, Out &out);
  void ev(Ev e, uint32_t a = 0, uint32_t b = 0, uint32_t c = 0, uint32_t d = 0);
  void fail(const char *fmt, ...);

  Config cfg_;
  Files f_;
  Hooks &h_;
  uint64_t now_ = 0;

  std::map<uint64_t, std::vector<GWrite>> gsched_;   ///< R and restore writes, by W
  std::map<uint64_t, std::vector<PWrite>> psched_;
  std::vector<GWrite> gnow_;   ///< this cycle's landing writes (for the hazard checks)
  std::vector<PWrite> pnow_;
  std::map<uint64_t, std::vector<LaneDesc>> lanes_;   ///< by W (A+6), then SFU at A+11
  std::map<uint64_t, std::vector<Done>> dsched_;      ///< dones by launch cycle
  std::deque<Producer> hist_;
  struct Deferred { uint64_t at; LaneMsg msg; LaneDesc d; };
  std::deque<Deferred> late_;   ///< held lane messages (late-copy, movi-in-lane)
  uint64_t movi_a_ = 0, movi_hold_ = 0;   ///< movi-in-lane: the movi's A, the lane queue's tail

  // Migration state (Migration tab).
  std::vector<MapEnt> mq_;
  std::vector<CmdEnt> cq_;
  Pick dpick_, rpick_;
  bool dm_busy_ = false;
  MapMsg dm_;
  unsigned dm_row_ = 0, dm_wcnt_ = 0;
  uint64_t dm_start_ = 0;
  bool rs_busy_ = false;
  MapMsg rs_;
  uint64_t rs_start_ = 0;
  unsigned rs_next_ = 0;        ///< the restore row expected next (RA-28 (b))
  std::map<uint64_t, unsigned> rpop_;   ///< restore writes' FIFO pops, by W
  unsigned next_id_ = 0;
  std::deque<FifoEnt> fifo_;
  unsigned rs_inflight_ = 0;    ///< FIFO head entries decided, not yet written
  bool rs_last_ = false;        ///< the predicate row is decided, not yet written
  unsigned map_drops_ = 0, cmd_drops_ = 0;   ///< kill-dropped entries' credits owed
  bool pca_pop_ = false;        ///< a PCA credit is owed (a dead row popped)
  uint32_t kmask_ = 0;          ///< warps killed since their last map (mig_kmask)
  std::set<unsigned> unwritten_, unwritten_p_;   ///< a restore's rows, until written

  // Kill.
  unsigned drain_ = 0;
  bool drain_loaded_ = false;
  bool kill_pend_ = false;    ///< a kill not yet quiet: KillAck when it is
  unsigned kill_epoch_ = 0;
  bool idle_ = false;
  uint64_t idle_cycles_ = 0;

  Stats st_;
};

} // namespace rcu
} // namespace ccv
#endif // CCV_RCU_CORE_H
