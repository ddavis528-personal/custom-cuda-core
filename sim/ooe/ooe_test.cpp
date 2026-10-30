//===-- ooe_test.cpp - unit tests of ooe::Core ---------------------------===//
//
// The paths no S1 kernel reaches yet (docs/coverage.md, "What is not
// reached"): wrong-path squash, deferred free, bulk discard, speculative L1
// wake and transitive cancel, bypass, predicate renaming, several warps,
// demotion, kill, restore, faults and barriers -- plus exact wake timings.
//
// Env stands in for FET, DEC, RCU and MIU at the core's decoded interface,
// honouring every contract (fixed latency, L1 hit at exactly CCV_LAT_L1_CMPL,
// one completion per memop), and checks three things on every run:
//   - dataflow: no source is read before its producer's value is readable
//     under the contract (a speculative read is allowed only if that issue is
//     later cancelled and the uop reissues; a memop never reads one);
//   - no late write: an op's result never lands in a register a younger
//     producer has since been issued to write (deferred free, V-22);
//   - retirement: exactly the correct path, in program order per warp.
// The core's own invariants (V-01 ...) run every cycle; any error fails.
//
// Usage: ooe-test [--seeds N]. Exit status 0 iff every test passes.
//===----------------------------------------------------------------------===//
#include "ooe_core.h"
#include "ccv_interfaces.h"

#include <algorithm>
#include <functional>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <random>
#include <set>
#include <string>
#include <vector>

using namespace ccv::ooe;

namespace {

int g_fail = 0;
bool g_quiet = false;     ///< a negative control's expected failures
/// Called after every core cycle of every Env: an RTL testbench compiled
/// with OOE_TEST_AS_LIBRARY uses it to check RTL against the live core.
void (*g_cycle_hook)(const Core &) = nullptr;
void (*g_config_hook)(Config &) = nullptr;   // an RTL bench's settings, over every test's
/// An RTL bench's settings over each random test's own (randomConfig's last
/// step): what the bench's build is for, whatever the seed and mode chose.
void (*g_random_config_hook)(Config &) = nullptr;
/// Called just before every core cycle, after that cycle's inputs: the
/// whole interval between two FreeVec::clock() calls is then visible.
void (*g_pre_cycle_hook)(const Core &) = nullptr;
/// DEC delivers up to g_dec_width uops on one cycle in g_dec_every: a
/// scenario's traffic (ooeTestScenario; docs/rtl-coding-style.md, the
/// clock-gating scenarios).
unsigned g_dec_every = 1, g_dec_width = 6;
std::string g_test;
#define EXPECT(c, ...)                                                      \
  do {                                                                      \
    if (!(c)) {                                                             \
      ++g_fail;                                                             \
      if (!g_quiet) {                                                       \
        std::fprintf(stderr, "FAIL %s:%d [%s] %s: ", __FILE__, __LINE__,    \
                     g_test.c_str(), #c);                                   \
        std::fprintf(stderr, __VA_ARGS__);                                  \
        std::fputc('\n', stderr);                                           \
      }                                                                     \
    }                                                                       \
  } while (0)

uint32_t attr(bool miu, bool rcu, bool cross, bool wg, bool wp, unsigned memk, bool br,
              unsigned ser, unsigned lat) {
  return uint32_t(miu) << 13 | uint32_t(rcu) << 12 | uint32_t(cross) << 11 | uint32_t(wg) << 10 |
         uint32_t(wp) << 9 | memk << 7 | uint32_t(br) << 6 | ser << 3 | lat;
}

enum Kind { kLane, kRcuOp, kSetp, kPlogic, kLoad, kStore, kBranch, kExit, kBarrier, kChw, kSfu, kFp, kAtomic };

/// A kind's unit (its lat_class) and its consumer group (Config::byp).
unsigned unitOf(Kind k) { return k == kLane || k == kSetp || k == kFp || k == kAtomic ? 1 : k == kSfu ? 4 : 0; }
/// Its bypass group as a producer (sched_attr's bypass_group).
unsigned pgroupOf(Kind k) {
  return k == kSfu ? Config::kGrpSfu : k == kFp ? Config::kGrpFp : k == kPlogic ? Config::kGrpPred : Config::kGrpInt;
}
/// Its group as a consumer: a memop consumes as address calculation, and
/// an op RCU executes takes no bypass (V-48).
int groupOf(Kind k) {
  if (k == kLoad || k == kStore || k == kAtomic) return int(Config::kGrpAddr);
  if (k == kRcuOp || k == kPlogic || k == kBranch) return -1;
  return int(pgroupOf(k));
}

/// One instruction of a synthetic trace.
struct Op {
  Kind k = kLane;
  unsigned dst = 0, src[3] = {}, nsrc = 0, pdst = 0, pguard = 0, pq[2] = {};
  bool guard = false, cross = false, taken = false, pred_taken = false;
  uint32_t mask = kFullMask;
  uint32_t tmask = kFullMask;    ///< kBranch: the lanes that take it, when taken
  unsigned w = 0;                ///< sectioned: the destination's width code
  bool backward = false;         ///< a backward branch (OA-14's rotation)
  unsigned cause = 0;            ///< a fault DEC found (1 F-FETCH, 2 F-ILLEGAL)
  unsigned chw = 2;              ///< kChw: the width code it sets on dst
  unsigned fmt_rsv = 0, fmt_opnd = 0;   ///< F-FORMAT's decoded inputs
  // kAtomic (AR-21; O-72, TI-39): src[0] rbase, src[1] rindex (A1's
  // base+index address), src[2] rs (an RMW's operand), dst rd (atom)
  // unless red; MIU runs it in `passes` passes, or faults its first read.
  // cas: a CAS, two decode slots, the second with rs_cmp and rs_swap
  // (csrc, ncsrc of them read) and the destination; late2, the second
  // reaches DEC a cycle after the first.
  unsigned passes = 1;
  bool red = false, afault = false;
  bool cas = false, late2 = false;
  unsigned csrc[2] = {}, ncsrc = 0;
  /// kExit (TI-27): last, its fetch clears the warp's last live lanes, so
  /// FET fetches no further; final, the mark FET sends (the last exit's, or
  /// under the control the exit before it).
  bool last = false, final = false;
  int srd = -1;                  ///< kLane: an srd identity OOE substitutes (A-25, O-64)
  bool pred_only = false;        ///< kLoad: ld.pred, its only destination predicate pdst (TI-36)
  bool local = false;            ///< a memop: an interleaved local form, no base (IS-19, O-69)
  /// A load that misses to DRAM (TI-21's stall_hole): its fill this many
  /// cycles after its issue, or 0 for the environment's DRAM draw.
  bool dram = false;
  unsigned fill = 0;
  /// kBarrier (TI-40, TI-41): arrive, bar.arrive (serial 4) rather than a
  /// wait; phase, wait.phase, its expected phases a predicate data source;
  /// aw, FET's all_waiting mark (a converged wait, held at rename). lanes:
  /// a guarded one's guard lanes, or wait.phase's phases, on its done. An
  /// unguarded arrive or wait completes without issue.
  /// mark: all_waiting on any other kind (the barrier timer's start).
  bool arrive = false, phase = false, aw = true, mark = false;
  /// kChw: a chwidth.multi sibling (AR-24 (c)): serial 0 and commit_width.
  bool sibling = false;
  bool chw_writes = false;   ///< kChw: writes its register (DEC's gdst), so it renames a destination
  bool diverged = false;     ///< kChw: FET's converged mark clear (O-81), so it faults
  unsigned xfer = 0;         ///< a memop's sized transfer (O-80): 0 rdata's width, 1 a byte, 2 a halfword
  /// kBranch: a ret (AR-24 (b)), its target offset in the code window on
  /// its done's aux.
  bool ret = false;
  uint32_t ret_to = 0;
  uint32_t lanes = 0;
};

Uop makeUop(const Op &o, unsigned warp, uint64_t tid, unsigned epoch, unsigned ckpt) {
  Uop u;
  u.tid = tid;
  u.warp = warp;
  u.pc = 0x1000 + 4 * (tid & 0xffff);
  u.group_mask = o.mask;
  u.fetch_epoch = epoch;
  u.ilen = 1;
  for (unsigned i = 0; i != 3; ++i) u.src[i] = o.src[i];
  u.dst = o.dst;
  u.w = o.w;
  u.backward = o.backward;
  u.cause = o.cause;
  u.shape.srd = o.srd;
  u.fmt_rsv = o.fmt_rsv;
  u.fmt_opnd = o.fmt_opnd;
  for (unsigned i = 0; i != o.nsrc; ++i) u.shape.gpr_reads |= uint8_t(1u << i);
  u.shape.guard = o.guard;
  u.pred_guard = o.pguard;
  u.local_form = o.local ? 1u : 0u;
  switch (o.k) {
  case kLane: u.attr_raw = attr(0, 0, o.cross, 1, 0, 0, 0, 0, 1); break;
  case kFp: u.attr_raw = attr(0, 0, 0, 1, 0, 0, 0, 0, 1); break;     // a lane FP op
  case kSfu: u.attr_raw = attr(0, 0, 0, 1, 0, 0, 0, 0, 4); break;   // a spare lane unit
  case kRcuOp: u.attr_raw = attr(0, 1, 0, 1, 0, 0, 0, 0, 0); break;
  case kSetp:
    u.attr_raw = attr(0, 0, 0, 0, 1, 0, 0, 0, 1);
    u.pred_we = true;
    u.pred_dst = o.pdst;
    break;
  case kPlogic:
    u.attr_raw = attr(0, 1, 0, 0, 1, 0, 0, 0, 0);
    u.pred_we = true;
    u.pred_dst = o.pdst;
    u.shape.pred_logic = true;
    u.imm = o.pq[0] | o.pq[1] << 3;
    break;
  case kLoad:
    if (o.pred_only) {          // ld.pred (TI-36): a predicate destination only
      u.attr_raw = attr(1, 0, 0, 0, 1, 0, 0, 0, 2);
      u.pred_we = true;
      u.pred_dst = o.pdst;
    } else {
      u.attr_raw = attr(1, 0, 0, 1, 0, 0, 0, 0, 2);
    }
    break;
  case kStore: u.attr_raw = attr(1, 0, 0, 0, 0, 1, 0, 0, 3); break;
  case kAtomic:
    // mem_kind atomic: OOE splits it; the opcode is A2's, unexamined. An
    // atomic is two decode slots (OI-80 (d), DA tab rev 94): the first
    // carries rbase and rindex and names no destination; the second an
    // RMW's rs, or a CAS's rs_cmp and rs_swap, and the destination
    // (atomSecond).
    u.attr_raw = attr(1, 0, 0, 0, 0, 2, 0, 0, 3) | 1u << 17;
    u.opcode = o.cas ? 0x2B : 0x2A;
    u.src[2] = 0;
    u.shape.gpr_reads &= 3u;
    break;
  case kBranch:
    u.attr_raw = attr(0, 1, 0, 0, 0, 0, 1, 0, 0);
    u.shape.guard = true;      // the condition is the guard (BRA_PRED)
    u.ckpt = ckpt;
    u.pred_taken = o.pred_taken;
    u.imm = 8;
    if (o.ret) u.attr_raw |= 1u << 19;
    break;
  case kExit:
    u.attr_raw = attr(0, 1, 0, 0, 0, 0, 0, 0, 0);
    u.shape.exit = true;
    u.shape.final_exit = o.final;
    break;
  case kBarrier:
    u.attr_raw = attr(0, 1, 0, 0, 0, 0, 0, o.arrive ? kSerArrive : kSerBarrier, 0);
    u.imm = 3;
    u.shape.pdata = o.phase;
    break;
  case kChw:
    u.attr_raw = attr(0, 1, 0, o.chw_writes, 0, 0, 0, o.sibling ? 0 : 1, 0) | (o.sibling ? 1u << 20 : 0u);
    u.imm = o.chw;
    break;
  }
  // A chwidth carries FET's converged mark (O-81) unless the test diverges it.
  u.all_waiting = o.k == kBarrier ? o.aw && !o.arrive : o.k == kChw ? !o.diverged : o.mark;
  u.xfer_size = o.xfer;
  u.attr_raw |= pgroupOf(o.k) << 14;
  if (o.k == kLoad || o.k == kStore || o.k == kAtomic) u.attr_raw = (u.attr_raw & ~(7u << 14)) | Config::kGrpAddr << 14;
  u.attr = SchedAttr::decode(u.attr_raw);
  return u;
}

/// An atomic's second decode slot (TI-39, AR's rev 156; OI-80 (d)): a
/// CAS's rs_cmp and rs_swap, or an RMW's rs, in src0 and src1; the
/// destination unless a reduction; the first slot's instruction, marked
/// second.
Uop atomSecond(const Op &o, const Uop &first) {
  Uop u = first;
  if (o.cas) {
    u.src[0] = o.csrc[0];
    u.src[1] = o.csrc[1];
    u.shape.gpr_reads = uint8_t((1u << o.ncsrc) - 1u);
  } else {
    u.src[0] = o.src[2];
    u.src[1] = 0;
    u.shape.gpr_reads = uint8_t(o.nsrc > 2 ? 1u : 0u);
  }
  u.src[2] = 0;
  u.dst = o.dst;
  u.attr_raw = (first.attr_raw & ~(1u << 17)) | 1u << 18 | (o.red ? 0u : 1u << 10);   // writes_gpr: rd
  u.attr = SchedAttr::decode(u.attr_raw);
  return u;
}

// ---- the environment: FET, DEC, RCU and MIU at the core's interface ----------------

struct Env {
  Config cfg;
  Core core;
  /// A GPR destination: none is the zero register's name (TI-37), not 0,
  /// which is a real row.
  bool gpr(unsigned p) const { return !core.isZeroName(p); }
  uint64_t t = 0;
  std::mt19937 rng;
  std::vector<std::string> errors;

  // contract knobs
  unsigned fetch_delay = 3;          ///< FET to OOE, so stale uops are in flight
  unsigned miss_pct = 0;             ///< loads that miss L1
  unsigned miss_extra = 25;          ///< past-L1 latency beyond CCV_LAT_L1_CMPL
  bool rcu_fast = false;             ///< dones earlier than the bound
  /// Load data past L1 becomes readable this many cycles after the
  /// completion lands (a longer ccv_miu_rcu_data link, in issue-time terms).
  unsigned data_after_cmpl = 0;

  struct Warp {
    unsigned id = 0, slot = 0, epoch = 0;
    std::vector<Op> prog;
    size_t next = 0;                 ///< next correct-path op
    bool launched = false, exited = false;
    // FET's checkpoints, in the order taken
    std::vector<unsigned> taken_order;
    unsigned live = 0;
    bool wrong = false;              ///< fetching a wrong path
    uint64_t wrong_branch_tid = 0;
    unsigned junk = 0;
    std::vector<uint64_t> retired;
    std::map<uint64_t, unsigned> ckpt_of;   ///< branch tid -> checkpoint
    // TI-21's swap: parked (not in a slot), ready from ready_at, restored at
    // least once (P applies), and the fill its demoting miss waits for.
    bool parked = false, restored = false, restoring = false;
    bool demoting = false;                  ///< demoted; FET resets it at the epoch notice
    uint64_t ready_at = 0, fill_at = 0;
    uint64_t abandon_at = 0;                ///< PF-23: its last abandoned load's own answer
    /// AR's rev 115: restored before its ready report (provisional); its P
    /// count starts at that report, from the retirements it had then.
    bool provisional = false, prov_based = false;
    uint64_t parked_at = 0;                 ///< when it last parked (FET's epoch notice), for RAU's age order
    size_t prov_base = 0;
    uint64_t rewind_pc = 0;                 ///< the oldest unretired uop's PC at its demote, or 0
    bool rewind_seen = false;
    uint64_t exit_at = 0;                   ///< its exit's retirement
    unsigned cta_slot = 0;                  ///< its CTA slot at RAU (TI-34), on its allocs
  };
  /// RAU's CTA slot for a warp (TI-34): any value the field holds, here
  /// from its warp_id so that a wrong slot's is caught.
  static unsigned ctaSlotOf(unsigned warp) { return warp % 7 + 1; }   // never 0, the control's
  std::vector<Warp> w;
  std::map<uint64_t, Op> op_of;                  ///< tid -> op
  uint64_t lane_ops = 0, lane_ops_one_section = 0;   ///< sectioned stats
  std::map<uint64_t, bool> correct;              ///< tid -> correct path
  std::map<uint64_t, size_t> idx_of;             ///< tid -> program index
  std::multimap<uint64_t, Uop> fetched;          ///< arrival cycle -> uop
  std::multimap<uint64_t, Done> dones;
  std::multimap<uint64_t, Cmpl> cmpls;
  /// PF-23: each load outstanding at MIU, by rob tag, so a demotion's
  /// discard can abandon it: its completion, its data beat and its done.
  struct Pend { uint64_t tid = 0; unsigned warp = 0; uint64_t when = 0, rd = 0; unsigned pdst = 0; };
  std::map<unsigned, Pend> pend;
  uint64_t abandoned = 0, abandon_started = 0;
  unsigned replay_spread = 0;   ///< PF-23: MIU's replays come up to this many cycles after the discard
  std::multimap<uint64_t, Redirect> redirects;   ///< at FET
  std::multimap<uint64_t, uint64_t> frees;       ///< at FET
  uint64_t next_tid = 1;

  // dataflow model: when each physical register's value is readable
  /// When a register's value is readable: `late` for every reader; a timed
  /// producer's bypass readers from issue + the table's offset for the pair.
  struct Ready {
    uint64_t issue = 0, late = 0, tid = 0;
    unsigned unit = 0, pgroup = 0;
    bool timed = false, cross = false;
  };
  uint64_t readableFor(const Ready &r, int group) const {
    if (!r.timed || r.cross || group < 0 || !cfg.bypass) return r.late;
    const unsigned b = cfg.bypWake(r.unit, r.pgroup, unsigned(group));
    return b ? r.issue + b : r.late;
  }
  std::map<unsigned, Ready> gready, pready;
  struct Viol { uint64_t at; std::string what; };
  std::map<uint64_t, std::vector<Viol>> viol;    ///< tid -> violations
  std::map<uint64_t, uint64_t> last_issue;       ///< tid -> cycle
  std::map<uint64_t, std::string> issues_of;     ///< tid -> "c@port,..."
  std::map<unsigned, std::pair<uint64_t, uint64_t>> gwriter;  ///< preg -> (tid, issue cycle)
  std::multimap<uint64_t, std::pair<unsigned, uint64_t>> landings;   ///< cycle -> (preg, tid)
  std::map<uint64_t, bool> hit_of;               ///< load tid -> L1 hit
  /// MIU's side of an atomic (AR-21, V-72): its passes left, whether a pass
  /// holds its lines (from its read to its write), and when the pass's old
  /// values are readable for A2.
  struct Atom {
    unsigned left = 0, passes = 0;
    bool started = false, hold = false, faulted = false, final = false;
    uint64_t t_ready = 0;
    unsigned T = 0;
  };
  std::map<uint64_t, Atom> atom;
  unsigned atom_mlc_pct = 0;                     ///< atomic reads that report an MLC miss
  std::vector<Outputs> log;
  bool keep_log = false;

  // ---- TI-21: RAU, PCA and FET's side of a warp swap -----------------------------
  // AR's rev 86 as OA adopted it (revs 132-133): a crossing is CCV_LAT_HOP
  // and RAU decides in a cycle, so a demote reaches OOE 2 hops + 1 after
  // OOE's trigger and a pick a hop + 1 after both its conditions hold. A
  // demote: drained to RAU, migrate to RCU, 17 rows to PCA (the first a hop
  // on), done to RAU; the slot is then free. A restore: restore-allocate,
  // with PCA's command beside it, 17 rows to RCU, done to RAU, activate. One
  // demote and one restore in flight, across different slots; a slot's
  // restore waits for its own demote.
  struct Swap {
    bool rau = false;                 ///< the environment's RAU acts: frees, demotes and restores
    /// kNever, kSwap (demote only with a ready parked warp) or kEvict
    /// (always): evict is the policy (DA, OA's rev 64), swap a knob.
    unsigned mode = kEvict;
    unsigned P = 8;                   ///< retirements before a restored warp may demote again
    unsigned dram_pm = 0;             ///< loads that miss to DRAM, per mille
    unsigned dram_lo = 700, dram_hi = 1300;
    bool charge_ports = true;         ///< a demote's reads hold a PRF read port (OA's rev 132)
    /// AR's rev 115: a free slot with no ready parked warp takes the oldest
    /// parked warp that is not ready, provisionally.
    bool provisional = false;
    /// PF-41 (AR's revs 116-117): with provisional, a provisional warp is
    /// demoted the moment a ready parked warp appears, no threshold wait.
    bool preempt = false;
  } swap;
  enum : unsigned { kNever = 0, kSwap = 1, kEvict = 2 };
  unsigned hop = ccv::kLatHop;
  std::multimap<uint64_t, std::function<void()>> acts;   ///< RAU, PCA and FET's actions, by cycle
  bool demote_busy = false, restore_busy = false;
  std::set<unsigned> free_slots;                         ///< slots RAU holds free
  std::map<std::pair<unsigned, size_t>, uint64_t> served;   ///< (warp, index) -> when its DRAM fill lands
  std::vector<std::pair<uint64_t, uint64_t>> read_busy, write_busy;   ///< migration port intervals
  uint64_t write_conflicts = 0;          ///< cycles a restore's write port would have been short
  std::map<std::pair<unsigned, size_t>, uint64_t> tid_at;   ///< (warp, index) -> its latest correct-path tid
  std::map<unsigned, unsigned> slot_owner;                  ///< slot -> its latest occupant (launch, activate)
  // Measures: swaps, each demoted slot's empty time (from the miss at the
  // head to the restored warp's first rename) with its drain D and refetch R.
  struct Gap { unsigned warp = 0, slot = 0; uint64_t head = 0, demote = 0, drained = 0, activate = 0, rename = 0; };
  std::vector<Gap> gaps;
  unsigned swaps = 0, declined = 0, refused = 0, provisional = 0, merged_fills = 0, preempted = 0;
  std::string swap_errors_note;

  void park(unsigned warp, std::vector<Op> prog, uint64_t ready_at = 0) {
    swap.rau = true;
    Warp x;
    x.id = warp;
    x.prog = std::move(prog);
    markExits(x.prog);
    x.parked = true;
    x.launched = true;
    x.ready_at = ready_at;
    x.cta_slot = ctaSlotOf(warp);
    w.push_back(x);
  }

  /// The oldest ready parked warp (RAU's pick), or null.
  Warp *readyParked() {
    Warp *best = nullptr;
    for (Warp &x : w)
      if (x.parked && !x.exited && x.ready_at <= t && (!best || x.ready_at < best->ready_at)) best = &x;
    return best;
  }

  /// RAU: restore into a free slot when a parked warp is ready.
  /// decide: RAU's decision cycle (the cycle after both conditions hold, or
  /// the decision that freed the slot).
  void rauRestore(uint64_t decide) {
    if (restore_busy || free_slots.empty()) return;
    Warp *x = readyParked();
    bool prov = false;
    if (!x && swap.provisional) {
      // AR's rev 115 (a): no ready warp and no launch pending (the
      // environment launches nothing later), the oldest parked warp (the
      // longest parked) whose drain is done but whose fill is not.
      for (Warp &y : w)
        if (y.parked && !y.exited && y.ready_at != ~uint64_t(0) && y.ready_at > t &&
            (!x || y.parked_at < x->parked_at))
          x = &y;
      prov = x != nullptr;
    }
    if (!x) return;
    x->provisional = prov;
    x->prov_based = false;
    provisional += prov;
    const unsigned slot = *free_slots.begin();
    free_slots.erase(free_slots.begin());
    restore_busy = true;
    x->parked = false;               // reserved for the slot
    x->restoring = true;
    x->slot = slot;
    const unsigned id = x->id;
    const uint64_t a = decide;
    acts.insert({a + hop, [this, id, slot] {
      Alloc ra;
      ra.warp = id;
      ra.slot = slot;
      ra.op = kAllocRestoreAlloc;
      ra.cta_slot = ctaSlotOf(id);
      ra.ctaid = 7;
      ra.barrier_count = 16;
      core.alloc(ra);
    }});
    // PCA's command beside it: the first row a hop on, 16 more, done to RAU,
    // RAU's decision, activate.
    const uint64_t first = a + 2 * hop;
    write_busy.push_back({first, first + ccv::kMigrationCycles});
    acts.insert({first + 16 + hop + 1 + hop, [this, id, slot] {
      Alloc ac;
      ac.warp = id;
      ac.slot = slot;
      ac.op = kAllocRestoreActivate;
      core.alloc(ac);
      Warp *y = warpOf(id);
      y->slot = slot;
      y->restored = true;
      y->restoring = false;
      slot_owner[slot] = id;
      y->next = y->retired.size();
      for (Gap &g : gaps)
        if (g.slot == slot && !g.activate) g.activate = t;
      restore_busy = false;
      ++swaps;
    }});
  }

  /// RAU on OOE's report: a stalled head with an outstanding load.
  void rauStatus(const Status &st) {
    Warp *x = warpOf(st.warp);
    if (!x || x->parked) return;
    if (st.exited) {
      // RAU frees the slot (alloc_op 0), and at the same decision may pick a
      // parked warp for it: the free lands first.
      const unsigned slot = x->slot;
      const uint64_t decide = t + hop + 1;
      acts.insert({decide, [this, slot, id = x->id, decide] {
        acts.insert({decide + hop, [this, slot, id] {
          Alloc f;
          f.warp = id;
          f.slot = slot;
          f.op = kAllocFree;
          core.alloc(f);
        }});
        free_slots.insert(slot);
        rauRestore(decide);
      }});
      return;
    }
    if (!st.stalled || !st.mlc_miss_seen || swap.mode == kNever) return;
    // RAU decides a hop after OOE's trigger.
    acts.insert({t + hop, [this, st] {
      Warp *y = warpOf(st.warp);
      if (!y || y->parked || y->exited || demote_busy) { ++declined; return; }
      // P (AR's rev 115 (b)): a provisional warp's count starts at its
      // ready report, and before it the warp may demote on the trigger.
      if (y->restored && y->provisional) {
        if (t >= y->ready_at && y->retired.size() - y->prov_base < swap.P) { ++declined; return; }
      } else if (y->restored && st.retired_since_restore < swap.P) {
        ++declined;
        return;
      }
      if (swap.mode == kSwap && !readyParked()) { ++declined; return; }
      rauDemote(y, t - hop - (cfg.demote_mlc_miss + 1));
    }});
  }

  /// RAU demotes y, deciding this cycle (the demote reaches OOE a hop and a
  /// cycle on); head: the cycle the slot's gap counts from.
  void rauDemote(Warp *y, uint64_t head) {
    {
      demote_busy = true;
      Gap g;
      g.warp = y->id;
      g.slot = y->slot;
      g.head = head;
      gaps.push_back(g);
      acts.insert({t + 1 + hop, [this, id = y->id] {
        core.demote(id);
        for (Gap &q : gaps)
          if (q.warp == id && !q.demote) q.demote = t;
        Warp *z = warpOf(id);
        const auto ta = tid_at.find({id, z->retired.size()});
        z->rewind_pc = ta != tid_at.end() ? 0x1000 + 4 * (ta->second & 0xffff) : 0;
        z->rewind_seen = false;
        z->demoting = true;
      }});
    }
  }

  /// PF-41: a ready parked warp and no free slot pre-empt a provisional
  /// warp still waiting for its own fill.
  void rauPreempt() {
    if (!swap.preempt || demote_busy || !free_slots.empty() || !readyParked()) return;
    for (Warp &y : w)
      if (y.provisional && !y.prov_based && !y.parked && !y.restoring && !y.exited && !y.demoting &&
          t < y.ready_at) {
        ++preempted;
        rauDemote(&y, t);
        return;
      }
  }

  /// OOE's drained: migrate out; the slot is free when PCA's done reaches RAU.
  void rauDrained(const Drained &d) {
    Warp *x = warpOf(d.warp);
    if (d.refused) {
      // TI-25: RAU cancels the demotion; exited frees the slot.
      ++refused;
      demote_busy = false;
      x->demoting = false;
      for (auto it = gaps.begin(); it != gaps.end(); ++it)
        if (it->warp == d.warp && !it->drained) { gaps.erase(it); break; }
      return;
    }
    for (Gap &g : gaps)
      if (g.warp == d.warp && !g.drained) g.drained = t;
    // The knob's own bench (OA's rev 131): the squash freed exactly the
    // warp's RS entries, and it holds exactly its committed registers.
    {
      const unsigned slot = x->slot;
      if (core.rsHeldIn(slot, false) || core.rsHeldIn(slot, true))
        errors.push_back("TI-21: warp " + std::to_string(d.warp) + " drained holding RS entries");
      std::set<unsigned> names;
      for (unsigned p : core.committedGprs(slot)) if (!core.isZeroName(p)) names.insert(cfg.sectioned ? p / 4 : p);
      if (!cfg.sectioned && names.size() != core.heldGprs(slot))
        errors.push_back("TI-21: warp " + std::to_string(d.warp) + " drained holding " +
                         std::to_string(core.heldGprs(slot)) + " registers, its map " + std::to_string(names.size()));
      if (x->rewind_seen && d.resume_pc != x->rewind_pc)
        errors.push_back("TI-24: drained's resume PC is not the oldest beat's");
    }
    const uint64_t migrate = t + hop + 1;            // drained to RAU, its decision
    const uint64_t first = migrate + 2 * hop;        // migrate to RCU, the first row to PCA
    if (swap.charge_ports) read_busy.push_back({migrate + hop, migrate + hop + ccv::kMigrationCycles});
    const unsigned slot = x->slot, id = x->id;
    const uint64_t decide = first + 16 + hop + 1;     // done to RAU, its decision
    acts.insert({decide, [this, slot, id, decide] {
      // Free the slot (alloc_op 0) and, at the same decision, pick a parked
      // warp for it; the warp is parked, ready when its fill has landed.
      acts.insert({decide + hop, [this, slot, id] {
        Alloc f;
        f.warp = id;
        f.slot = slot;
        f.op = kAllocFree;
        core.alloc(f);
      }});
      Warp *y = warpOf(id);
      // Ready when its fill has landed: under PF-23, when its last
      // abandoned load has been answered (ccv_miu_rau_ready, AR's rev 107).
      y->ready_at = std::max({t, y->fill_at, y->abandon_at});
      free_slots.insert(slot);
      demote_busy = false;
      rauRestore(decide);
    }});
  }

  explicit Env(const Config &c, unsigned seed = 1) : cfg(c), core(c), rng(seed) {
    core.on_error = [this](const std::string &m) { errors.push_back(m); };
    const char *d = std::getenv("OOE_TEST_TRACE");
    core.on_event = [this, d](const char *n, unsigned w, uint64_t a, uint64_t b, uint64_t tid) {
      // TI-21: a restored warp's first rename ends its slot's gap.
      if (!gaps.empty() && n[0] == 'd' && std::string(n) == "dispatch")
        for (Gap &g : gaps)
          if (g.activate && !g.rename && warpOf(w) && warpOf(w)->slot == g.slot) g.rename = t;
      if (d && (std::to_string(tid) == d || std::string(d) == "all"))
        std::fprintf(stderr, "  t=%llu %s w%u a=%llu b=%llu tid=%llu\n", (unsigned long long)t, n, w,
                     (unsigned long long)a, (unsigned long long)b, (unsigned long long)tid);
    };
  }

  unsigned rnd(unsigned n) { return n ? unsigned(rng() % n) : 0; }

  void launch(unsigned warp, unsigned slot, std::vector<Op> prog, unsigned barriers = 16) {
    Warp x;
    x.id = warp;
    x.slot = slot;
    x.prog = std::move(prog);
    markExits(x.prog);
    x.cta_slot = ctaSlotOf(warp);
    w.push_back(x);
    slot_owner[slot] = warp;
    Alloc a;
    a.warp = warp;
    a.slot = slot;
    a.op = kAllocLaunch;
    a.cta_slot = ctaSlotOf(warp);
    a.ctaid = 7;
    a.barrier_count = barriers;
    core.alloc(a);
    // A test's narrow registers (Op::w) are its warp's committed widths
    // (OA's rev 166: rename takes the table's), as though their chwidths
    // had retired before the program; set once the launch has landed.
    if (cfg.sectioned) {
      std::array<uint8_t, 16> cw{};
      std::array<bool, 16> seen{};
      bool any = false;
      for (const Op &o : w.back().prog)
        if ((o.k == kLane || o.k == kRcuOp || o.k == kLoad || o.k == kSfu || o.k == kFp) && !seen[o.dst & 15]) {
          seen[o.dst & 15] = true;
          cw[o.dst & 15] = uint8_t(o.w);
          any = any || o.w;
        }
      if (any) preset_cw[slot] = cw;
    }
  }
  std::map<unsigned, std::array<uint8_t, 16>> preset_cw;   ///< slot -> widths, applied after its launch lands

  Op junkOp() {
    Op o;
    const unsigned r = rnd(4);
    o.k = r == 0 ? kLoad : r == 1 ? kStore : kLane;
    o.dst = rnd(16);
    o.src[0] = rnd(16);
    o.src[1] = rnd(16);
    o.nsrc = o.k == kLoad ? 1 : 2;
    return o;
  }

  /// FET: up to two uops per warp per cycle into the DEC path.
  void fetch() {
    for (Warp &x : w) {
      if (!x.launched || x.exited || x.parked || x.restoring) continue;
      for (unsigned n = 0; n != 2; ++n) {
        Op o;
        bool corr = true;
        if (x.wrong) {
          if (x.junk >= 12) break;
          o = junkOp();
          corr = false;
          ++x.junk;
        } else {
          if (x.next == x.prog.size()) break;
          o = x.prog[x.next];
        }
        unsigned ck = 0;
        if (o.k == kBranch) {
          while (ck != cfg.ckpts && (x.live >> ck & 1)) ++ck;
          if (ck == cfg.ckpts) break;            // every checkpoint live: stall
          x.live |= 1u << ck;
          x.taken_order.push_back(ck);
        }
        const uint64_t tid = next_tid++;
        op_of[tid] = o;
        correct[tid] = corr;
        Uop u = makeUop(o, x.id, tid, x.epoch, ck);
        fetched.insert({t + fetch_delay, u});
        // An atomic is two slots of one instruction; nothing of the warp is
        // fetched between them (a late second ends the cycle's fetch).
        if (o.k == kAtomic) fetched.insert({t + fetch_delay + (o.late2 ? 1 : 0), atomSecond(o, u)});
        if (o.k == kBranch) x.ckpt_of[tid] = ck;
        if (corr) {
          tid_at[{x.id, x.next}] = tid;
          idx_of[tid] = x.next++;
          if (o.k == kBranch && (o.taken != o.pred_taken || (o.pred_taken && o.taken && o.tmask != kFullMask))) {
            x.wrong = true;                      // fetch the wrong path until redirected
            x.wrong_branch_tid = tid;
            x.junk = 0;
            break;
          }
          if (o.k == kExit && o.last) break;
        }
        if (o.k == kAtomic) break;
      }
    }
  }

  /// FET's final-exit mark (TI-27, OA's rev 170): the exit whose fetch
  /// clears the last live lanes, in program order (the correct path's).
  void markExits(std::vector<Op> &p) const {
    uint32_t lanes = kFullMask;
    int prev = -1;
    for (size_t i = 0; i != p.size(); ++i) {
      if (p[i].k != kExit) continue;
      lanes &= ~p[i].mask;
      if (lanes == 0) {
        p[i].last = true;
        if (cfg.inject_final_exit_early && prev >= 0) p[size_t(prev)].final = true;
        else p[i].final = true;
        break;
      }
      prev = int(i);
    }
  }

  Warp *warpOf(unsigned id) {
    for (Warp &x : w) if (x.id == id) return &x;
    return nullptr;
  }

  void fetApply() {
    for (auto it = redirects.begin(); it != redirects.end() && it->first <= t;) {
      const Redirect &r = it->second;
      Warp *x = warpOf(r.warp);
      if (r.epoch_only) {
        x->epoch = r.epoch;
        if (x->demoting && !r.rewind) {
          // FET at a demotion's epoch notice: the warp stops fetching, resets
          // its checkpoints, and resumes at its oldest unretired instruction
          // (the rewind); what is in flight carries the old epoch.
          x->demoting = false;
          x->parked = true;
          x->parked_at = t;
          x->ready_at = ~uint64_t(0);
          x->wrong = false;
          x->junk = 0;
          x->live = 0;
          x->taken_order.clear();
          for (auto it = fetched.begin(); it != fetched.end();)
            it = it->second.warp == x->id ? fetched.erase(it) : std::next(it);
        }
        // TI-24 (3): the first beat is the oldest unretired uop's PC.
        if (r.rewind && !x->rewind_seen) {
          x->rewind_seen = true;
          if (x->rewind_pc && r.target_pc != x->rewind_pc)
            errors.push_back("TI-24: warp " + std::to_string(r.warp) + "'s first rewind beat is not its oldest unretired uop");
        }
      } else {
        if (!x->wrong || r.tid != x->wrong_branch_tid)
          errors.push_back("redirect for a branch FET did not mispredict");
        if (x->ckpt_of[r.tid] != r.ckpt) errors.push_back("redirect names the wrong checkpoint");
        // Restoring frees the checkpoint and every younger one (A-56).
        for (size_t i = 0; i != x->taken_order.size(); ++i)
          if (x->taken_order[i] == r.ckpt) {
            for (size_t j = i; j != x->taken_order.size(); ++j) x->live &= ~(1u << x->taken_order[j]);
            x->taken_order.resize(i);
            break;
          }
        x->wrong = false;
        x->epoch = r.epoch;
      }
      it = redirects.erase(it);
    }
    for (auto it = frees.begin(); it != frees.end() && it->first <= t;) {
      for (unsigned b = 0; b != 64; ++b) {
        if (!(it->second >> b & 1)) continue;
        Warp *x = nullptr;
        const auto own = slot_owner.find(b / cfg.ckpts);
        if (own != slot_owner.end()) x = warpOf(own->second);
        const unsigned ck = b % cfg.ckpts;
        if (!x || !(x->live >> ck & 1)) { errors.push_back("V-46: a free for a dead checkpoint"); continue; }
        x->live &= ~(1u << ck);
        for (size_t i = 0; i != x->taken_order.size(); ++i)
          if (x->taken_order[i] == ck) { x->taken_order.erase(x->taken_order.begin() + long(i)); break; }
      }
      it = frees.erase(it);
    }
  }

  std::string what_extra;
  void violation(uint64_t tid, const std::string &what) { viol[tid].push_back({t, what}); }

  /// When a source written by `p` is readable for this consumer.
  void checkRead(uint64_t tid, unsigned preg, bool pred, int group) {
    if (pred ? preg == cfg.pred_zero : core.isZeroName(preg)) return;
    auto &m = pred ? pready : gready;
    auto it = m.find(preg);
    if (it == m.end()) return;    // never written: architectural state
    const uint64_t at = readableFor(it->second, pred ? -1 : group);
    if (t < at && !pred && op_of[it->second.tid].k == kAtomic && op_of[tid].k != kAtomic) {
      // An atomic's consumers wake once, on its last write (V-71): an
      // earlier read is never a speculation a replay may clean up.
      errors.push_back("V-71: tid " + std::to_string(tid) + " reads atomic tid " + std::to_string(it->second.tid) +
                       "'s result at " + std::to_string(t) + ", before its last pass");
      return;
    }
    if (t < at) {
      char b[160];
      std::snprintf(b, sizeof b, "(kind %d) reads %s%u at %llu, readable at %llu, written by tid %llu (kind %d)",
                    int(op_of[tid].k), pred ? "pp" : "p", preg, (unsigned long long)t,
                    (unsigned long long)at, (unsigned long long)it->second.tid,
                    int(op_of[it->second.tid].k));
      what_extra = " prod issues: " + issues_of[it->second.tid] + " my issues: " + issues_of[tid];
      violation(tid, std::string(b) + what_extra);
    }
  }

  /// TI-37 (OA's rev 182): an op that writes no GPR names the zero register
  /// as its destination, and one that writes a GPR never does.
  void noneName(uint64_t tid, const Op &o, unsigned pdst, const char *what) {
    const bool wg = makeUop(o, 0, tid, 0, 0).attr.writes_gpr;
    if (wg == core.isZeroName(pdst))
      errors.push_back(std::string("TI-37: tid ") + std::to_string(tid) + "'s " + what + " names p" +
                       std::to_string(pdst) + (wg ? ", the zero register, for its GPR" : " for no GPR destination"));
  }

  void onIssue(const Issue &is) {
    const Op &o = op_of[is.tid];
    if (o.k != kAtomic) noneName(is.tid, o, is.pdst, is.copy ? "copy" : "issue");
    if (is.copy) {
      checkRead(is.tid, is.pold, false, int(Config::kGrpInt));
      return;
    }
    if (o.k == kAtomic) { atomIssue(is, o); return; }
    last_issue[is.tid] = t;
    issues_of[is.tid] += std::to_string(t) + "@" + std::to_string(is.port) + "/tag" + std::to_string(is.rob_tag) + " ";
    const int group = groupOf(o.k);
    for (unsigned i = 0; i != o.nsrc; ++i) checkRead(is.tid, is.psrc[i], false, group);
    if (is.merge && gpr(is.pdst) && o.k != kLoad) checkRead(is.tid, is.pold, false, group);
    if (o.guard || o.k == kBranch) checkRead(is.tid, is.ppguard, true, -1);
    if (o.k == kPlogic) {
      // the qualifier sources: the core renamed them; find them by RAT is
      // not visible here, so they are checked through the predicate merge
      // and the guard paths only.
    }
    if (is.pred_we && is.merge) checkRead(is.tid, is.ppold, true, -1);
    // Results: when they are readable, and when they land.
    const unsigned unit = unitOf(o.k);
    const unsigned lat = cfg.unitLat(unit);
    if (gpr(is.pdst) && o.k != kLoad) {
      gready[is.pdst] = {t, t + lat, is.tid, unit, pgroupOf(o.k), true, o.cross};
      gwriter[is.pdst] = {is.tid, t};
      landings.insert({t + lat, {is.pdst, is.tid}});
    }
    if (is.pred_we) pready[is.ppdst] = {t, t + lat, is.tid, unit, pgroupOf(o.k), true, false};
    // RCU's done: within the bound (V-35), at a fixed latency per issue.
    if (o.k != kLoad && o.k != kStore) {
      const unsigned bound = cfg.issue_link + lat - 1 + cfg.done_link;
      Done d;
      d.rob_tag = is.rob_tag;
      if (o.k == kBranch) {
        d.branch_taken = correct[is.tid] ? o.taken : rnd(2);
        d.branch_mask = d.branch_taken ? (correct[is.tid] ? o.tmask : kFullMask) : 0;
        if (o.ret) d.aux = o.ret_to;
      }
      // A guarded barrier's guard lanes on branch_mask, wait.phase's
      // phases on aux (TI-40, OA's rev 226).
      if (o.k == kBarrier && o.guard) d.branch_mask = o.lanes;
      if (o.k == kBarrier && o.phase) d.aux = o.lanes;
      dones.insert({doneRoom(t + (rcu_fast ? 2 : bound)), d});
    }
  }

  /// An atomic's issue to RCU: A1's address, A3's data (each a memop's
  /// operand read, never speculative), or A2, the lane op.
  void atomIssue(const Issue &is, const Op &o) {
    issues_of[is.tid] += std::to_string(t) + "@" + std::to_string(is.port) + "/a" + std::to_string(is.res) + " ";
    const Atom &a = atom[is.tid];
    if (is.res == Issue::kMemop) {
      const size_t before = viol[is.tid].size();
      if (gpr(is.pdst)) {
        // A1: the address is rbase and rindex, as many as the op reads
        // (O-72's base+index; TI-39).
        const unsigned want = (1u << std::min(o.nsrc, 2u)) - 1u;
        if ((is.gpr_reads & 3u) != want)
          errors.push_back("TI-39: tid " + std::to_string(is.tid) + "'s A1 reads address sources " +
                           std::to_string(is.gpr_reads & 3u) + ", want " + std::to_string(want));
        for (unsigned i = 0; i != 2; ++i)
          if ((is.gpr_reads >> i) & 1u) checkRead(is.tid, is.psrc[i], false, int(Config::kGrpAddr));
      } else {
        checkRead(is.tid, is.psrc[0], false, int(Config::kGrpAddr));
      }
      if (o.guard) checkRead(is.tid, is.ppguard, true, -1);
      // A memop's read is never speculative (V-17).
      for (size_t i = before; i != viol[is.tid].size(); ++i)
        errors.push_back("atomic memop step: " + viol[is.tid][i].what);
      viol[is.tid].resize(before);
      return;
    }
    last_issue[is.tid] = t;
    // A2: inside a pass, after the pass's read data lands.
    if (!a.hold) errors.push_back("AR-21: tid " + std::to_string(is.tid) + "'s lane op issues outside a pass");
    else if (t < a.t_ready)
      violation(is.tid, "A2 reads T at " + std::to_string(t) + ", readable at " + std::to_string(a.t_ready));
    // A2's operands after T: an RMW's rs, a CAS's rs_cmp and rs_swap.
    const unsigned want = o.cas ? (1u << o.ncsrc) - 1u : o.nsrc >= 3 ? 1u : 0u;
    if (((is.gpr_reads >> 1) & 3u) != want || !(is.gpr_reads & 1u))
      errors.push_back("TI-39: tid " + std::to_string(is.tid) + "'s A2 reads " + std::to_string(is.gpr_reads) +
                       ", want T and operands " + std::to_string(want));
    for (unsigned i = 1; i != 3; ++i)
      if ((is.gpr_reads >> i) & 1u) checkRead(is.tid, is.psrc[i], false, int(Config::kGrpInt));
    if (o.guard) checkRead(is.tid, is.ppguard, true, -1);
    const unsigned lat = cfg.unitLat(1);
    gready[is.pdst] = {t, t + lat, is.tid, 1, Config::kGrpInt, true, false};
    gwriter[is.pdst] = {is.tid, t};
    landings.insert({t + lat, {is.pdst, is.tid}});
    Done d;
    d.rob_tag = is.rob_tag;
    dones.insert({doneRoom(t + (rcu_fast ? 2 : cfg.issue_link + lat - 1 + cfg.done_link)), d});
  }

  /// MIU's half of an atomic: a read holds its pass's lines, the write
  /// releases them and says whether lanes remain (more).
  void atomMemop(const Memop &m, const Op &o) {
    Atom &a = atom[m.tid];
    Cmpl c;
    c.rob_tag = m.rob_tag;
    c.rs_idx = m.rs_idx;
    const uint64_t when = cmplRoom(t + 4 + rnd(miss_extra));
    const std::string who = "tid " + std::to_string(m.tid);
    if (m.mem_op == kMemOpAtomicRead) {
      if (a.hold) errors.push_back("V-69: " + who + " reads again before its pass's write");
      if (a.final) errors.push_back("AR-21: " + who + " reads after its last pass");
      const bool first = !a.started;
      // V-69: the read issues only once every older instruction of the warp
      // has retired.
      const Warp *x = warpOf(m.warp);
      if (x && idx_of.count(m.tid) && x->retired.size() != idx_of[m.tid])
        errors.push_back("V-69: " + who + "'s read issues with " +
                         std::to_string(idx_of[m.tid] - x->retired.size()) + " older instructions unretired");
      if (first) {
        a.started = true;
        a.left = o.passes;
        a.T = m.pdst;
      }
      if (first && o.afault) {
        // Every lane checked before any hold: the fault comes with none.
        c.status = kCmplFault;
        c.cause = 6;                     // F-ADDR
        c.lane_mask = 1;
        c.address = 0xA70;
        a.faulted = a.final = true;
        cmpls.insert({when, c});
        return;
      }
      a.hold = true;
      a.t_ready = when + data_after_cmpl;
      c.mlc_miss = rnd(100) < atom_mlc_pct;
      // T's consumers read it only after the last pass (V-71).
      gready[m.pdst] = {t, ~uint64_t(0) >> 1, m.tid, 2, Config::kGrpAddr, false, false};
      gwriter[m.pdst] = {m.tid, t};
      landings.insert({a.t_ready, {m.pdst, m.tid}});
    } else {
      if (!a.hold) errors.push_back("V-69: " + who + " writes with no read in its pass");
      if (a.faulted) errors.push_back("V-72: " + who + " writes after its read faulted");
      a.hold = false;
      ++a.passes;
      if (a.left) --a.left;
      c.more = a.left > 0;
      if (!c.more) {
        a.final = true;
        if (gready.count(a.T)) gready[a.T].late = when + data_after_cmpl;
      }
    }
    cmpls.insert({when, c});
    if (cfg.memop_rcu_done) {
      Done d;
      d.rob_tag = m.rob_tag;
      dones.insert({when + 1, d});
    }
  }

  /// The latest cycle at or before `when`, and after the issue at t, with a
  /// lane free on ccv_rcu_ooe_done: RCU may be early, never late (V-35), and
  /// never sends more than the channel's rate.
  uint64_t doneRoom(uint64_t when) const {
    while (when > t + 1 && dones.count(when) >= ccv::channelInfo(ccv::CH_RCU_OOE_DONE).rate) --when;
    return when;
  }

  /// The first cycle from `when` with a lane free on ccv_miu_ooe_cmpl (its
  /// hint channel's rate is the same): MIU never sends more than its rate.
  uint64_t cmplRoom(uint64_t when) const {
    while (cmpls.count(when) >= ccv::channelInfo(ccv::CH_MIU_OOE_CMPL).rate) ++when;
    return when;
  }

  /// PF-23 (OA's rev 160, AR's rev 106): a bulk discard abandons the
  /// warp's outstanding loads in its range (every discard takes them,
  /// TI-21). Each is answered at once with replay; its data is never
  /// written and its own response is dropped, so nothing lands in a
  /// register freed to the slot's next occupant. A load whose
  /// beat or completion is already under way finishes as it is (exactly
  /// one completion, A-41). The line still fills: served stands.
  void abandonLoads(const Memop &d) {
    // The circular range (branch, tail]; branch == tail is the whole ROB
    // (a demotion's, full or empty).
    const unsigned D = cfg.rob_depth, mask = (1u << ccv::prov::kWRobIdx) - 1;
    const unsigned branch = d.rob_tag & mask, tail = d.disp & mask;
    auto covered = [&](unsigned tag) {
      const unsigned i = tag & mask;
      return branch == tail || (i + D - branch - 1) % D < (tail + D - branch) % D;
    };
    for (auto &pe : pend) {
      Pend &q = pe.second;
      if (q.warp != d.warp || !covered(pe.first)) continue;
      if (q.when <= t + 1 || (q.rd && q.rd <= t + 1)) {
        ++abandon_started;
        continue;
      }
      const unsigned tag = pe.first;
      Cmpl c;
      bool found = false;
      for (auto r = cmpls.equal_range(q.when); r.first != r.second; ++r.first)
        if (r.first->second.rob_tag == tag) { c = r.first->second; cmpls.erase(r.first); found = true; break; }
      if (!found) { errors.push_back("PF-23: no completion pending for rob tag " + std::to_string(tag)); continue; }
      for (auto r = landings.equal_range(q.rd); q.rd && r.first != r.second; ++r.first)
        if (r.first->second.second == q.tid) { landings.erase(r.first); break; }
      // Nothing will write it: once freed, its next holder (a restore's row,
      // say) sees no pending write.
      if (gpr(q.pdst) && gready.count(q.pdst) && gready[q.pdst].tid == q.tid) gready[q.pdst].late = t + 1;
      if (Warp *x = warpOf(q.warp)) x->abandon_at = std::max(x->abandon_at, q.when);
      const uint64_t old = q.when;
      c.status = kCmplReplay;
      c.mlc_miss = false;
      q.when = cmplRoom(t + 1 + (replay_spread ? rnd(replay_spread + 1) : 0));
      q.rd = 0;
      cmpls.insert({q.when, c});
      if (cfg.memop_rcu_done)
        for (auto r = dones.equal_range(old + 1); r.first != r.second; ++r.first)
          if (r.first->second.rob_tag == tag) {
            Done dn = r.first->second;
            dones.erase(r.first);
            dones.insert({q.when + 1, dn});
            break;
          }
      ++abandoned;
    }
  }

  void onMemop(const Memop &m) {
    if (m.mem_op == 0xF) {
      abandonLoads(m);
      return;
    }
    const Op &o = op_of[m.tid];
    if (o.k == kAtomic) {
      if (m.mem_op != kMemOpAtomicRead && m.mem_op != kMemOpAtomicWrite)
        errors.push_back("V-72: an atomic reaches MIU as mem_op " + std::to_string(m.mem_op));
      else atomMemop(m, o);
      return;
    }
    if (m.mem_op == kMemOpAtomicRead || m.mem_op == kMemOpAtomicWrite)
      errors.push_back("V-72: a non-atomic reaches MIU as mem_op " + std::to_string(m.mem_op));
    noneName(m.tid, o, m.pdst, "memop");
    // V-17: a memop never reads an unconfirmed (here: unreadable) source.
    const size_t before = viol[m.tid].size();
    (void)before;
    Cmpl c;
    c.rob_tag = m.rob_tag;
    c.rs_idx = m.rs_idx;
    uint64_t when;
    // TI-21: a load that misses to DRAM, once per program position (its
    // replay after a restore hits the landed fill).
    {
      Warp *x = warpOf(m.warp);
      const bool corr = correct.count(m.tid) && correct[m.tid];
      const std::pair<unsigned, size_t> at{m.warp, corr ? idx_of[m.tid] : ~size_t(0)};
      const bool dram = o.k == kLoad && corr && !served.count(at) &&
                        (o.dram || (swap.dram_pm && rnd(1000) < swap.dram_pm));
      if (dram) {
        const unsigned fill = o.fill ? o.fill : swap.dram_lo + rnd(swap.dram_hi - swap.dram_lo + 1);
        when = cmplRoom(t + fill);
        served[at] = when;
        hit_of[m.tid] = false;
        if (x) x->fill_at = std::max(x->fill_at, when);
        if (gpr(m.pdst)) {
          const uint64_t rd = when + data_after_cmpl;
          gready[m.pdst] = {t, rd, m.tid, 2, Config::kGrpAddr, false, false};
          gwriter[m.pdst] = {m.tid, t};
          landings.insert({rd, {m.pdst, m.tid}});
        }
        c.mlc_miss = true;
        cmpls.insert({when, c});
        pend[m.rob_tag] = {m.tid, m.warp, when, gpr(m.pdst) ? when + data_after_cmpl : 0, m.pdst};
        return;
      }
      // A replay of a load whose line is still filling (a provisional
      // restore, AR's rev 115) merges into that fill at DCU.
      const auto sv = served.find(at);
      if (o.k == kLoad && corr && sv != served.end() && sv->second > t + cfg.lat_l1_cmpl) {
        when = cmplRoom(sv->second);
        hit_of[m.tid] = false;
        if (gpr(m.pdst)) {
          const uint64_t rd = when + data_after_cmpl;
          gready[m.pdst] = {t, rd, m.tid, 2, Config::kGrpAddr, false, false};
          gwriter[m.pdst] = {m.tid, t};
          landings.insert({rd, {m.pdst, m.tid}});
        }
        c.mlc_miss = true;
        cmpls.insert({when, c});
        pend[m.rob_tag] = {m.tid, m.warp, when, gpr(m.pdst) ? when + data_after_cmpl : 0, m.pdst};
        ++merged_fills;
        return;
      }
    }
    if (o.k == kLoad && cfg.l1_spec) {
      bool hit = rnd(100) >= miss_pct;
      when = cmplRoom(t + cfg.lat_l1_cmpl + (hit ? 0 : 1 + rnd(miss_extra)));
      // A hit the channel has no room for at the L1 contract completes
      // later, which is a miss.
      hit = hit && when == t + cfg.lat_l1_cmpl;
      hit_of[m.tid] = hit;
      if (gpr(m.pdst)) {
        // Readable at the L1 wake on a hit; on a miss, after the completion.
        const uint64_t rd = hit ? t + cfg.lat_l1_wake : when + data_after_cmpl;
        gready[m.pdst] = {t, rd, m.tid, 2, Config::kGrpAddr, false, false};
        gwriter[m.pdst] = {m.tid, t};
        landings.insert({rd, {m.pdst, m.tid}});
      }
    } else {
      when = cmplRoom(t + 4 + rnd(miss_extra));
      if (o.k == kLoad && gpr(m.pdst)) {
        const uint64_t rd = when + data_after_cmpl;
        gready[m.pdst] = {t, rd, m.tid, 2, Config::kGrpAddr, false, false};
        gwriter[m.pdst] = {m.tid, t};
        landings.insert({rd, {m.pdst, m.tid}});
      }
      c.mlc_miss = true;
    }
    cmpls.insert({when, c});
    if (o.k == kLoad) pend[m.rob_tag] = {m.tid, m.warp, when, gpr(m.pdst) ? gready[m.pdst].late : 0, m.pdst};
    if (cfg.memop_rcu_done) {
      Done d;
      d.rob_tag = m.rob_tag;
      dones.insert({when + 1, d});
    }
  }

  void step() {
    // inputs due this cycle
    for (auto it = dones.begin(); it != dones.end() && it->first <= t;) { core.done(it->second); it = dones.erase(it); }
    for (auto it = cmpls.begin(); it != cmpls.end() && it->first <= t;) {
      core.cmpl(it->second);
      pend.erase(it->second.rob_tag);
      it = cmpls.erase(it);
    }
    // OA-23's hint, two cycles ahead of its completion; none for an
    // abandoned load (PF-23).
    for (auto r = cmpls.equal_range(t + 2); r.first != r.second; ++r.first)
      if (r.first->second.status != kCmplReplay) core.hint(r.first->second.rob_tag);
    // TI-21: a restore's rows hold a PRF write port (OA's rev 132): count
    // the cycles its landings would have found the ports short.
    if (!write_busy.empty()) {
      unsigned busy = 0, land = 0;
      for (const auto &b : write_busy) busy += b.first <= t && t < b.second;
      for (auto r = landings.equal_range(t); r.first != r.second; ++r.first) ++land;
      if (busy && land + busy > 8) ++write_conflicts;
    }
    // a result landing in a register a younger producer was issued to write
    for (auto it = landings.begin(); it != landings.end() && it->first <= t;) {
      const unsigned p = it->second.first;
      const uint64_t tid = it->second.second;
      auto wr = gwriter.find(p);
      if (wr != gwriter.end() && wr->second.first != tid && wr->second.second < t)
        errors.push_back("late write: tid " + std::to_string(tid) + " lands in p" +
                         std::to_string(p) + " after tid " + std::to_string(wr->second.first) +
                         " was issued to write it");
      it = landings.erase(it);
    }
    fetApply();
    for (auto it = acts.begin(); it != acts.end() && it->first <= t;) {
      auto f = it->second;
      it = acts.erase(it);
      f();
    }
    if (swap.rau) rauRestore(t + 1);
    if (swap.rau) rauPreempt();
    for (Warp &x : w)
      if (x.provisional && !x.prov_based && !x.parked && t >= x.ready_at) {
        x.prov_based = true;            // its ready report (c): P counts from here
        x.prov_base = x.retired.size();
      }
    // No slot runs two warps (OA's rev 131).
    if (swap.rau) {
      std::map<unsigned, unsigned> in;
      for (const Warp &x : w)
        if ((!x.parked || x.restoring) && !x.exited && ++in[x.slot] > 1)
          errors.push_back("TI-21: slot " + std::to_string(x.slot) + " runs two warps at " + std::to_string(t));
    }
    {
      unsigned busy = 0;
      for (const auto &b : read_busy) busy += b.first <= t && t < b.second;
      core.migrationReads(busy);
    }
    if (g_pre_cycle_hook) g_pre_cycle_hook(core);
    const auto presets = std::move(preset_cw);
    preset_cw.clear();
    core.cycle(t);
    for (const auto &pc : presets) core.presetWidths(pc.first, pc.second);
    if (g_cycle_hook) g_cycle_hook(core);
    const Outputs o = core.out;
    if (keep_log) log.push_back(o);
    // TI-34: every memop, barrier and fault carries RAU's CTA slot for its
    // warp, from OOE's per-slot register.
    auto ctaCheck = [&](const char *what, unsigned warp, unsigned slot) {
      const Warp *x = warpOf(warp);
      if (x && slot != x->cta_slot)
        errors.push_back(std::string("TI-34: ") + what + " of warp " + std::to_string(warp) + " carries CTA slot " +
                         std::to_string(slot) + ", RAU's " + std::to_string(x->cta_slot));
    };
    for (const Memop &m : o.memops) ctaCheck("a memop", m.warp, m.cta_slot);
    for (const Bar &b : o.bars) ctaCheck("a barrier", b.warp, b.cta_slot);
    for (const Fault &f : o.faults) ctaCheck("a fault", f.warp, f.cta_slot);
    for (const Retired &r : core.retired) {
      Warp *x = warpOf(r.warp);
      x->retired.push_back(r.tid);
      if (r.exit && op_of[r.tid].last) { x->exited = true; x->exit_at = t; }
    }
    // PF-23: drained only once every load of the warp has its completion.
    for (const Drained &d : o.drained)
      for (const auto &pe : pend)
        if (!d.refused && pe.second.warp == d.warp) {
          errors.push_back("PF-23: warp " + std::to_string(d.warp) + " drained with rob tag " +
                           std::to_string(pe.first) + " still owed a completion");
          break;
        }
    if (swap.rau) {
      for (const Status &st : o.status) rauStatus(st);
      for (const Drained &d : o.drained) rauDrained(d);
    }
    for (const Issue &is : o.issues) onIssue(is);
    for (const Memop &m : o.memops) onMemop(m);
    // Sectioned lanes (OI-28): the lane ops leaving in one cycle use
    // disjoint sections of the four operand ports, each op every section its
    // operands sit in. Checked from the names alone, not the core's
    // footprints.
    if (cfg.sectioned) {
      unsigned used = 0;
      for (const Issue &is : o.issues) {
        const Op &op = op_of[is.tid];
        const bool lane = is.copy || op.k == kLane || op.k == kSfu || op.k == kSetp || op.k == kFp;
        if (!lane) continue;
        unsigned m = 0;
        if (is.copy) {
          m = core.sectionsOf(is.pdst) | core.sectionsOf(is.pold);
        } else {
          if (op.k != kSetp) m |= core.sectionsOf(is.pdst);
          for (unsigned i = 0; i != op.nsrc; ++i) m |= core.sectionsOf(is.psrc[i]);
          if (is.merge && op.k != kSetp) m |= core.sectionsOf(is.pold);
        }
        if (used & m)
          errors.push_back("cycle " + std::to_string(t) + ": two lane ops share a section (tid " +
                           std::to_string(is.tid) + ")");
        used |= m;
        ++lane_ops;
        if (m && !(m & (m - 1))) ++lane_ops_one_section;
      }
    }
    for (const Redirect &r : o.redirects) redirects.insert({t + cfg.redirect_lat, r});
    if (o.free_mask) frees.insert({t + cfg.redirect_lat, o.free_mask});
    for (Warp &x : w) x.launched = true;
    fetch();
    // DEC: up to six uops a cycle, in fetch order, as credit allows (a
    // scenario's traffic: up to g_dec_width on one cycle in g_dec_every).
    const unsigned width = t % g_dec_every ? 0 : g_dec_width;
    unsigned n = 0;
    std::set<unsigned> held;
    for (auto it = fetched.begin(); it != fetched.end() && it->first <= t && n != width;) {
      if (held.count(it->second.warp)) { ++it; continue; }
      // A CAS's two slots go together, on credit for both (TI-39): its first
      // alone could wait at the queue's head for a second that no credit
      // lets in.
      if (it->second.attr.pair_first) {
        auto it2 = std::next(it);
        while (it2 != fetched.end() && it2->second.warp != it->second.warp) ++it2;
        if (it2 == fetched.end() || it2->first > t || n + 2 > width || !core.canAccept(it->second.warp, 2)) {
          held.insert(it->second.warp);
          ++it;
          continue;
        }
        core.uop(it->second);
        core.uop(it2->second);
        fetched.erase(it2);
        it = fetched.erase(it);
        n += 2;
        continue;
      }
      if (!core.canAccept(it->second.warp)) { held.insert(it->second.warp); ++it; continue; }
      core.uop(it->second);
      it = fetched.erase(it);
      ++n;
    }
    ++t;
  }

  bool done() const {
    for (const Warp &x : w) if (!x.exited) return false;
    return !core.busy() && dones.empty() && cmpls.empty();
  }

  /// Run to the end; check retirement and dataflow.
  void finish(uint64_t limit = 200000) {
    while (!done() && t < limit) step();
    for (unsigned k = 0; k != 20; ++k) step();
    EXPECT(done(), "did not finish by cycle %llu", (unsigned long long)t);
    for (const Warp &x : w) {
      size_t i = 0;
      bool ok = true;
      for (uint64_t tid : x.retired) {
        if (!correct[tid]) { ok = false; EXPECT(false, "warp %u retired wrong-path tid %llu", x.id, (unsigned long long)tid); break; }
        if (idx_of[tid] != i) { ok = false; EXPECT(false, "warp %u retired index %zu, want %zu", x.id, idx_of[tid], i); break; }
        ++i;
      }
      EXPECT(ok && i == x.prog.size(), "warp %u retired %zu of %zu", x.id, i, x.prog.size());
    }
    std::set<uint64_t> ret;
    for (const Warp &x : w) ret.insert(x.retired.begin(), x.retired.end());
    for (const auto &v : viol) {
      const uint64_t tid = v.first;
      const Op &o = op_of[tid];
      for (const Viol &x : v.second) {
        // Acceptable only for a speculative issue that was later replayed,
        // or whose uop a squash removed; never for a memop (V-17).
        const bool replayed = last_issue.count(tid) && last_issue[tid] > x.at;
        EXPECT((replayed || !ret.count(tid)) && o.k != kLoad && o.k != kStore, "tid %llu %s",
               (unsigned long long)tid, x.what.c_str());
      }
    }
    for (const auto &a : atom)
      EXPECT(!a.second.hold, "tid %llu's atomic still holds its lines (V-70)", (unsigned long long)a.first);
    for (const std::string &e : errors) EXPECT(false, "%s", e.c_str());
    errors.clear();
  }
};

// ---- program generators ----------------------------------------------------------------

std::vector<Op> randomProgram(std::mt19937 &rng, unsigned n, bool preds_renamed, bool sfu = false,
                              bool narrow = false) {
  auto r = [&](unsigned k) { return unsigned(rng() % k); };
  std::vector<Op> p;
  // Sectioned: each architectural register has one width for the program,
  // as the committed chwidth table gives it: R0-R3 32-bit, the rest any.
  std::array<unsigned, 16> width{};
  for (unsigned i = 4; i != 16 && narrow; ++i) width[i] = r(4);
  // a prologue that writes some registers and predicates
  for (unsigned i = 0; i != 4; ++i) { Op o; o.k = kRcuOp; o.dst = i; p.push_back(o); }
  { Op o; o.k = kSetp; o.pdst = 1; o.src[0] = 0; o.src[1] = 1; o.nsrc = 2; p.push_back(o); }
  for (unsigned i = 0; i != n; ++i) {
    Op o;
    const unsigned c = r(100);
    o.dst = r(16);
    o.src[0] = r(16);
    o.src[1] = r(16);
    o.src[2] = r(16);
    if (c < 35) { o.k = sfu && r(3) == 0 ? kSfu : kLane; o.nsrc = 1 + r(3); o.cross = o.k == kLane && r(8) == 0; }
    else if (c < 45) { o.k = kRcuOp; }
    else if (c < 58) { o.k = kLoad; o.nsrc = 1; }
    else if (c < 66) { o.k = kStore; o.nsrc = 2; }
    else if (c < 74) { o.k = kSetp; o.nsrc = 2; o.pdst = r(4); }
    else if (c < 78 && preds_renamed) { o.k = kPlogic; o.pdst = r(4); o.pq[0] = r(4); o.pq[1] = r(4); }
    else if (c < 88) { o.k = kBranch; o.pguard = r(4); o.taken = r(2); o.pred_taken = r(3) ? o.taken : !o.taken; }
    else { o.k = kLane; o.nsrc = 2; }
    if ((o.k == kLane || o.k == kLoad || o.k == kSetp) && r(5) == 0) { o.guard = true; o.pguard = r(4); }
    if ((o.k == kLane || o.k == kSfu || o.k == kLoad) && r(6) == 0) o.mask = 0x0000ffffu;
    // A memory access whose data register is 4 bits wide faults (F-WIDTH,
    // from the committed table rename now reads): keep the data 8 bits or
    // wider (a load's destination, a store's first source, src_arch[0]).
    if (o.k == kLoad && width[o.dst] == 3) { o.k = kLane; o.nsrc = 1; }
    if (o.k == kStore && width[o.src[0]] == 3) o.src[0] = r(4);
    o.w = width[o.dst];
    o.backward = o.k == kBranch && r(2) == 0;
    p.push_back(o);
  }
  Op e;
  e.k = kExit;
  p.push_back(e);
  return p;
}

Config baseConfig() {
  Config c;
  c.memop_rcu_done = false;
  if (g_config_hook) g_config_hook(c);
  return c;
}

/// A bypass-group configuration: an SFU-like unit 4 a long way from the ALUs,
/// with its own bypass back to itself, slower ones across, and RCU-only
/// results bypassed to the lanes a cycle early.
Config groupConfig() {
  Config c = baseConfig();
  c.unit_lat[4] = 12;
  c.fast[4] = 6;                                   // SFU's fastest bypass point
  c.byp[Config::kGrpSfu][Config::kGrpSfu] = 0;     // SFU -> SFU at 6
  c.byp[Config::kGrpSfu][Config::kGrpInt] = 3;     // SFU -> ALU at 9
  c.byp[Config::kGrpInt][Config::kGrpSfu] = 1;     // ALU -> SFU at 4 + 1
  return c;
}

// ---- targeted tests ----------------------------------------------------------------------

uint64_t issueCycle(const Env &e, uint64_t tid) {
  for (size_t c = 0; c != e.log.size(); ++c)
    for (const Issue &i : e.log[c].issues) if (i.tid == tid && !i.copy) return c;
  return ~0ull;
}
unsigned issueCount(const Env &e, uint64_t tid) {
  unsigned n = 0;
  for (const Outputs &o : e.log) for (const Issue &i : o.issues) n += i.tid == tid && !i.copy;
  return n;
}

void testWakeTimes() {
  g_test = "wake-times";
  // A lane producer and three readers: a lane op (bypass), an RCU op (late)
  // and a lane op of a cross-lane producer (late).
  for (int byp = 0; byp != 2; ++byp) {
    Config c = baseConfig();
    c.bypass = byp;
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    Op a; a.k = kLane; a.dst = 1; a.nsrc = 1; p.push_back(a);                   // tid 1
    Op b; b.k = kLane; b.dst = 2; b.src[0] = 1; b.nsrc = 1; p.push_back(b);     // tid 2: lane reads lane
    Op s; s.k = kStore; s.src[0] = 1; s.src[1] = 1; s.nsrc = 2; p.push_back(s); // tid 3: memop reads lane
    Op x; x.k = kLane; x.cross = true; x.dst = 3; x.nsrc = 1; p.push_back(x);  // tid 4: cross-lane
    Op y; y.k = kLane; y.dst = 4; y.src[0] = 3; y.nsrc = 1; p.push_back(y);     // tid 5: reads cross-lane
    Op z; z.k = kRcuOp; z.dst = 5; p.push_back(z);                              // tid 6
    Op q; q.k = kLane; q.dst = 6; q.src[0] = 5; q.nsrc = 1; p.push_back(q);     // tid 7: reads RCU op
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    e.finish();
    const uint64_t t1 = issueCycle(e, 1), t2 = issueCycle(e, 2), t4 = issueCycle(e, 4),
                   t5 = issueCycle(e, 5), t6 = issueCycle(e, 6), t7 = issueCycle(e, 7);
    EXPECT(t2 - t1 == (byp ? c.lat_lane_byp : c.lat_lane), "lane->lane %llu (bypass %d)",
           (unsigned long long)(t2 - t1), byp);
    EXPECT(t5 - t4 == c.lat_lane, "cross-lane producer woke its reader at %llu",
           (unsigned long long)(t5 - t4));
    EXPECT(t7 - t6 == c.lat_rcu, "RCU op -> lane %llu", (unsigned long long)(t7 - t6));
    EXPECT(issueCycle(e, 3) - t1 >= c.lat_lane, "a memop read a bypassed value");
  }
}

void testBypassGroups() {
  g_test = "bypass-groups";
  Config c = groupConfig();
  EXPECT(c.check().empty(), "%s", c.check().c_str());
  Env e(c);
  e.keep_log = true;
  std::vector<Op> p;
  auto add = [&](Kind k, unsigned dst, int src) {
    Op o; o.k = k; o.dst = dst;
    if (src >= 0) { o.src[0] = unsigned(src); o.nsrc = 1; }
    p.push_back(o);
  };
  add(kSfu, 1, -1);   // tid 1
  add(kSfu, 2, 1);    // tid 2: SFU -> SFU, 6
  add(kLane, 3, 1);   // tid 3: SFU -> ALU, 9
  add(kLane, 4, -1);  // tid 4
  add(kSfu, 5, 4);    // tid 5: ALU -> SFU, 5
  add(kLane, 6, 4);   // tid 6: ALU -> ALU, the default CCV_LAT_LANE_BYP
  add(kRcuOp, 7, -1); // tid 7
  add(kLane, 8, 7);   // tid 8: RCU -> ALU: single-time, CCV_LAT_RCU
  add(kRcuOp, 9, 4);  // tid 9: ALU -> RCU: no bypass, CCV_LAT_LANE
  add(kRcuOp, 10, 1); // tid 10: SFU -> RCU: no bypass, the SFU's 12
  add(kFp, 11, 4);    // tid 11: ALU -> FP, CCV_LAT_LANE_BYP + 2
  add(kLane, 12, 11); // tid 12: FP -> ALU, + 2
  add(kFp, 13, 11);   // tid 13: FP -> FP, in-unit + 0
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  e.finish();
  struct W { uint64_t prod, cons; unsigned want; const char *what; };
  const W ws[] = {{1, 2, 6, "SFU -> SFU"}, {1, 3, 9, "SFU -> ALU"}, {4, 5, 5, "ALU -> SFU"},
                  {4, 6, c.lat_lane_byp, "ALU -> ALU"}, {7, 8, c.lat_rcu, "RCU -> ALU"},
                  {4, 9, c.lat_lane, "ALU -> RCU"}, {1, 10, 12, "SFU -> RCU"},
                  {4, 11, c.lat_lane_byp + 2, "ALU -> FP"}, {11, 12, c.lat_lane_byp + 2, "FP -> ALU"},
                  {11, 13, c.lat_lane_byp, "FP -> FP"}};
  for (const W &w : ws)
    EXPECT(issueCycle(e, w.cons) - issueCycle(e, w.prod) == w.want, "%s woke after %llu, want %u",
           w.what, (unsigned long long)(issueCycle(e, w.cons) - issueCycle(e, w.prod)), w.want);
  // A fastest point at or over the unit's latency is refused at elaboration.
  Config bad = groupConfig();
  bad.fast[4] = 12;
  EXPECT(!bad.check().empty(), "a bypass no faster than the register file was accepted");
}

void testL1Spec() {
  g_test = "l1-spec";
  for (int miss = 0; miss != 2; ++miss) {
    Config c = baseConfig();
    // A long shadow, one lane latency past the wake, so a grandchild issues
    // inside it. (It read 20, against a wake of 13, until CCV_LAT_RCU_ADDR_BASE
    // moved the wake to 16: OA-5.)
    c.lat_l1_cmpl = c.lat_l1_wake + c.lat_lane;
    Env e(c);
    e.keep_log = true;
    e.miss_pct = miss ? 100 : 0;
    e.miss_extra = 10;
    std::vector<Op> p;
    Op ld; ld.k = kLoad; ld.dst = 1; ld.nsrc = 1; p.push_back(ld);               // tid 1
    Op ch; ch.k = kRcuOp; ch.dst = 2; p.push_back(ch);                          // tid 2: independent
    Op a; a.k = kLane; a.dst = 3; a.src[0] = 1; a.nsrc = 1; p.push_back(a);     // tid 3: child
    Op g; g.k = kLane; g.dst = 4; g.src[0] = 3; g.nsrc = 1; p.push_back(g);     // tid 4: grandchild
    Op st; st.k = kStore; st.src[0] = 4; st.src[1] = 4; st.nsrc = 2; p.push_back(st);  // tid 5
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    e.finish();
    const uint64_t tl = issueCycle(e, 1);
    EXPECT(issueCycle(e, 3) - tl == c.lat_l1_wake, "child woke at %llu", (unsigned long long)(issueCycle(e, 3) - tl));
    if (!miss) {
      EXPECT(issueCount(e, 3) == 1 && issueCount(e, 4) == 1, "a hit replayed something");
    } else {
      // Child and grandchild both issued in the shadow, both replayed (V-15).
      EXPECT(issueCount(e, 3) == 2, "child issued %u times", issueCount(e, 3));
      EXPECT(issueCount(e, 4) == 2, "grandchild issued %u times", issueCount(e, 4));
      EXPECT(e.core.counters["cancel.replay"] == 2, "replays %llu",
             (unsigned long long)e.core.counters["cancel.replay"]);
      EXPECT(issueCount(e, 5) == 1, "the store issued %u times", issueCount(e, 5));
    }
  }
}

void testL1WakeAfterCmpl() {
  // Slow links can put CCV_LAT_L1_WAKE after CCV_LAT_L1_CMPL (the links
  // split does): a miss is known before any dependant wakes, so nothing
  // issues speculatively and nothing replays.
  for (int miss = 0; miss != 2; ++miss) {
    g_test = std::string("l1-wake-after-cmpl ") + (miss ? "miss" : "hit");
    Config c = baseConfig();
    c.lat_l1_wake = 18;
    c.lat_l1_cmpl = 15;
    Env e(c);
    e.keep_log = true;
    e.miss_pct = miss ? 100 : 0;
    std::vector<Op> p;
    Op ld; ld.k = kLoad; ld.dst = 1; ld.nsrc = 1; p.push_back(ld);             // tid 1
    Op a; a.k = kLane; a.dst = 3; a.src[0] = 1; a.nsrc = 1; p.push_back(a);   // tid 2
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    e.finish();
    if (!miss) EXPECT(issueCycle(e, 2) - issueCycle(e, 1) == c.lat_l1_wake, "woke at %llu",
                      (unsigned long long)(issueCycle(e, 2) - issueCycle(e, 1)));
    EXPECT(issueCount(e, 2) == 1, "the dependant issued %u times", issueCount(e, 2));
  }
}

void testMaskedLoad() {
  g_test = "masked-load";
  Config c = baseConfig();
  c.l1_spec = false;
  Env e(c);
  e.keep_log = true;
  std::vector<Op> p;
  Op w; w.k = kLane; w.dst = 5; w.nsrc = 1; p.push_back(w);                         // tid 1: old R5
  Op ld; ld.k = kLoad; ld.dst = 5; ld.nsrc = 1; ld.mask = 0xffff; p.push_back(ld);  // tid 2: masked
  Op u; u.k = kLane; u.dst = 6; u.src[0] = 5; u.nsrc = 1; p.push_back(u);           // tid 3
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  e.finish();
  unsigned copies = 0;
  uint64_t copy_at = 0;
  for (size_t cyc = 0; cyc != e.log.size(); ++cyc)
    for (const Issue &i : e.log[cyc].issues)
      if (i.copy) { ++copies; copy_at = cyc; EXPECT(i.merge && !e.core.isZeroName(i.pold), "copy without its old destination"); }
  EXPECT(copies == 1, "%u copies (V-20: exactly one)", copies);
  EXPECT(copy_at == issueCycle(e, 2), "the copy left apart from its load");
  EXPECT(copy_at - issueCycle(e, 1) >= c.lat_lane, "the copy read R5 before it landed");
  EXPECT(e.core.counters["errors"] == 0, "errors");
}

void testSquash() {
  g_test = "squash";
  Config c = baseConfig();
  c.l1_spec = false;
  Env e(c, 7);
  e.keep_log = true;
  e.miss_extra = 60;               // memops outstanding across the squash
  std::vector<Op> p;
  Op s; s.k = kSetp; s.pdst = 1; s.nsrc = 2; p.push_back(s);
  Op ld; ld.k = kLoad; ld.dst = 2; ld.nsrc = 1; p.push_back(ld);
  Op b; b.k = kBranch; b.pguard = 1; b.taken = true; b.pred_taken = false; p.push_back(b);
  for (unsigned i = 0; i != 4; ++i) { Op a; a.k = kLane; a.dst = 3 + i; a.src[0] = 2; a.nsrc = 1; p.push_back(a); }
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  e.finish();
  unsigned discards = 0, redirects = 0;
  for (const Outputs &o : e.log) {
    for (const Memop &m : o.memops) if (m.mem_op == 0xF) ++discards;
    for (const Redirect &r : o.redirects) if (!r.epoch_only) {
      ++redirects;
      EXPECT(r.target_pc == 0x1000 + 4 * 3 + 4 + 16, "target %llx", (unsigned long long)r.target_pc);
      EXPECT(r.epoch == 1, "epoch %u", r.epoch);
    }
    EXPECT(!(o.free_mask & 1), "a free for the mispredicted branch's checkpoint (A-58)");
  }
  EXPECT(redirects == 1, "%u redirects", redirects);
  EXPECT(e.core.counters["squash.entries"] > 0, "nothing was squashed");
  EXPECT(e.core.counters["branch.mispredict"] == 1, "mispredicts");
  // Wrong-path stores that reached MIU went with one bulk discard each squash.
  EXPECT(discards <= 1, "%u bulk discards", discards);
  EXPECT(e.core.freeGprs() + e.core.heldGprs(0) == c.phys_regs, "register leak");
}

/// The floors and the ceiling, which binds: two slots, a ceiling well under
/// the ROB. The ceiling is a term of the go (OI-73 (3), OA's rev 207): it
/// holds each warp at its ceiling, and the check after the go never fires.
/// The control drops the go's term, so a take passes the ceiling (V-04).
void testFloorCeiling() {
  for (const bool control : {false, true}) {
    g_test = control ? "floor-ceiling (control)" : "floor-ceiling";
    Config c = baseConfig();
    c.l1_spec = false;
    c.slots = 2;
    c.phys_regs = 64;
    c.ren_floor = 8;
    c.ren_ceil = 12;
    c.pred_regs = 16;
    c.pred_ren_floor = 2;
    c.pred_ren_ceil = 4;
    c.inject_no_ceil_term = control;
    const int saved = g_fail;
    const bool quiet = g_quiet;
    g_quiet = control;
    Env e(c, 3);
    std::vector<Op> p;
    for (unsigned i = 0; i != 60; ++i) { Op a; a.k = kLane; a.dst = i % 16; a.src[0] = (i + 15) % 16; a.nsrc = 1; p.push_back(a); }
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    e.launch(1, 1, p);
    e.finish();
    g_quiet = quiet;
    if (control) {
      g_fail = saved;
      const bool caught = e.core.counters["errors"] > 0;
      std::printf("  %-24s %s\n", "control no-ceil-term", caught ? "caught" : "MISSED");
      EXPECT(caught, "a take past the ceiling went unnoticed without the go's term");
      continue;
    }
    EXPECT(e.core.counters["stall.ceiling.gpr"] > 0, "the go's ceiling term never held a warp");
    EXPECT(e.core.counters["stall.gpr_ceiling"] == 0, "the check after the go refused %llu takes",
           (unsigned long long)e.core.counters["stall.gpr_ceiling"]);
    EXPECT(e.core.counters["errors"] == 0, "errors");
  }
}

/// The ceiling at the RTL's size (four slots, the parameters' pools), so
/// the go's benches see it bind (OI-73 (3)): one warp alone runs long
/// enough to reach a small ceiling, which holds it there.
void testCeilingGo() {
  g_test = "ceiling-go";
  Config c = baseConfig();
  c.l1_spec = false;
  c.ren_floor = 4;
  c.ren_ceil = 8;
  Env e(c);
  std::vector<Op> p;
  for (unsigned i = 0; i != 60; ++i) { Op a; a.k = kLane; a.dst = i % 16; a.src[0] = (i + 15) % 16; a.nsrc = 1; p.push_back(a); }
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  e.finish();
  EXPECT(e.core.counters["stall.ceiling.gpr"] > 0, "the go's ceiling term never held the warp");
  EXPECT(e.core.counters["stall.gpr_ceiling"] == 0, "the check after the go refused a take");
  EXPECT(e.core.counters["errors"] == 0, "errors");
}

void testDemote() {
  g_test = "demote";
  Config c = baseConfig();
  c.l1_spec = false;
  Env e(c);
  e.keep_log = true;
  e.miss_extra = 40;
  std::vector<Op> p;
  for (unsigned i = 0; i != 6; ++i) { Op a; a.k = kLane; a.dst = i; a.nsrc = 1; p.push_back(a); }
  Op ld; ld.k = kLoad; ld.dst = 7; ld.nsrc = 1; p.push_back(ld);
  for (unsigned i = 0; i != 10; ++i) { Op a; a.k = kLane; a.dst = 8; a.src[0] = 7; a.nsrc = 1; p.push_back(a); }
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  for (unsigned k = 0; k != 25; ++k) e.step();
  e.core.demote(0);
  uint64_t notice = 0, map_at = 0, drained_at = 0;
  RatMap map{};
  for (unsigned k = 0; k != 200; ++k) {
    e.step();
    const Outputs &o = e.log.back();
    for (const Redirect &r : o.redirects) if (r.epoch_only) notice = e.t - 1;
    for (const RatMap &m : o.maps) { map_at = e.t - 1; map = m; }
    for (const Drained &d : o.drained) {
      drained_at = e.t - 1;
      EXPECT(d.resume_pc >= 0x1000, "resume pc %llx", (unsigned long long)d.resume_pc);
    }
  }
  EXPECT(notice, "no epoch notice (A-74)");
  EXPECT(map_at && map.direction == 0, "no demotion map");
  EXPECT(drained_at > map_at && drained_at >= notice + c.redirect_lat, "drained at %llu, notice %llu, map %llu (V-26, V-57)",
         (unsigned long long)drained_at, (unsigned long long)notice, (unsigned long long)map_at);
  // Registers stay held until RAU frees the slot after migration (V-27).
  const size_t held = e.core.heldGprs(0);
  EXPECT(held > 0, "registers freed before migration");
  Alloc f; f.warp = 0; f.slot = 0; f.op = kAllocFree;
  e.core.alloc(f);
  e.step();
  EXPECT(e.core.freeGprs() == c.phys_regs, "free list %zu after the free", e.core.freeGprs());
  // Restore into the same slot: allocate, map direction 1, activate.
  Alloc ra; ra.warp = 0; ra.slot = 0; ra.op = kAllocRestoreAlloc; ra.cta_slot = Env::ctaSlotOf(0);
  e.core.alloc(ra);
  bool map1 = false;
  for (unsigned k = 0; k != 10 && !map1; ++k) {
    e.step();
    for (const RatMap &m : e.log.back().maps) map1 = m.direction == 1 && m.gpr[0] != c.phys_zero;
  }
  EXPECT(map1, "no restore map");
  EXPECT(e.core.heldGprs(0) == 16, "restore allocated %u", e.core.heldGprs(0));
  for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
}

/// TI-25 (AR's rev 112) (2): a demote that lands after the warp's exit
/// retired is refused. Exactly one drained, refused = 1, and nothing
/// moves: no squash, no map, no epoch notice or rewind beat; exited
/// follows. The control demotes it anyway. Returns whether the checks held.
bool demoteRefused(bool control) {
  Config c = baseConfig();
  c.l1_spec = false;
  c.inject_no_refuse = control;
  Env e(c);
  e.keep_log = true;
  std::vector<Op> p;
  for (unsigned i = 0; i != 4; ++i) { Op a; a.k = kLane; a.dst = 4 + i; a.nsrc = 1; p.push_back(a); }
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  for (unsigned k = 0; k != 200 && !e.warpOf(0)->exited; ++k) e.step();
  const size_t from = e.log.size();
  e.core.demote(0);
  for (unsigned k = 0; k != 40; ++k) e.step();
  unsigned drained = 0, refused = 0, maps = 0, notices = 0, exited = 0;
  for (size_t i = 0; i != e.log.size(); ++i) {
    const Outputs &o = e.log[i];
    for (const Status &st : o.status) exited += st.exited;
    if (i < from) continue;
    for (const Drained &d : o.drained) { ++drained; refused += d.refused; }
    maps += unsigned(o.maps.size());
    for (const Redirect &r : o.redirects) notices += r.epoch_only;
  }
  const bool ok = e.warpOf(0)->exited && drained == 1 && refused == 1 && maps == 0 && notices == 0 && exited == 1 &&
                  e.errors.empty();
  if (!control) {
    g_test = "demote refused";
    EXPECT(e.warpOf(0)->exited, "the exit did not retire");
    EXPECT(drained == 1 && refused == 1, "%u drained, %u refused", drained, refused);
    EXPECT(maps == 0 && notices == 0, "a refused demote sent %u maps and %u notices", maps, notices);
    EXPECT(exited == 1, "exited sent %u times", exited);
    for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
  }
  return ok;
}

void testDemoteRefused() {
  demoteRefused(false);
  const bool held = demoteRefused(true);
  std::printf("  %-24s %s\n", "control no-refuse", held ? "MISSED" : "caught");
  g_test = "demote refused (control)";
  EXPECT(!held, "demoting an exited warp should break the refused checks");
}

/// TI-25 (1): the parked layout. A sectioned warp holds narrow registers
/// at positions other than 0 and a committed width from chwidth; after a
/// demotion and a restore into another slot, each register has its own
/// row (16 distinct rows) at its parked position and width, and the
/// committed width table came back. The control restores at 32 bits,
/// position 0, and loses the table.
bool parkedLayout(bool control) {
  Config c = baseConfig();
  c.sectioned = true;
  c.place = 0;
  c.l1_spec = false;
  c.inject_park_layout_lost = control;
  Env e(c);
  e.keep_log = true;
  e.miss_extra = 300;
  std::vector<Op> p;
  Op a; a.k = kLane; a.dst = 4; a.w = 1; p.push_back(a);                              // 16-bit, sections 2-3
  Op b; b.k = kLane; b.dst = 5; b.w = 2; b.src[0] = 4; b.nsrc = 1; p.push_back(b);    // 8-bit, follows R4 to 2
  Op d; d.k = kLane; d.dst = 6; d.w = 2; p.push_back(d);                              // 8-bit, slot 1's home
  Op w; w.k = kChw; w.dst = 7; w.chw = 3; p.push_back(w);
  Op ld; ld.k = kLoad; ld.dst = 8; ld.nsrc = 1; p.push_back(ld);
  Op u; u.k = kLane; u.dst = 9; u.src[0] = 8; u.nsrc = 1; p.push_back(u);
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(5, 1, p);
  for (unsigned k = 0; k != 200 && e.warpOf(5)->retired.size() < 4; ++k) e.step();
  e.core.demote(5);
  bool drained = false;
  for (unsigned k = 0; k != 600 && !drained; ++k) {
    e.step();
    for (const Drained &x : e.log.back().drained) drained = drained || (x.warp == 5 && !x.refused);
  }
  const auto before = e.core.committedGprs(1);
  unsigned moved = 0;
  for (unsigned r = 0; r != kArchGprs; ++r) moved += e.core.namePos(before[r]) != 0;
  Alloc f; f.warp = 5; f.slot = 1; f.op = kAllocFree;
  e.core.alloc(f);
  e.step();
  Alloc ra; ra.warp = 5; ra.slot = 3; ra.op = kAllocRestoreAlloc; ra.cta_slot = Env::ctaSlotOf(5);
  e.core.alloc(ra);
  bool map1 = false;
  for (unsigned k = 0; k != 20 && !map1; ++k) {
    e.step();
    for (const RatMap &m : e.log.back().maps) map1 = map1 || m.direction == 1;
  }
  const auto after = e.core.committedGprs(3);
  std::set<unsigned> rows;
  unsigned same = 0;
  for (unsigned r = 0; r != kArchGprs; ++r) {
    rows.insert(e.core.nameRow(after[r]));
    const bool z = e.core.isZeroName(before[r]);
    same += z ? e.core.nameWidth(after[r]) == e.core.slotWidth(3, r) && e.core.namePos(after[r]) == 0
              : e.core.nameWidth(after[r]) == e.core.nameWidth(before[r]) &&
                    e.core.namePos(after[r]) == e.core.namePos(before[r]);
  }
  const bool ok = drained && map1 && moved >= 2 && rows.size() == kArchGprs && same == kArchGprs &&
                  e.core.slotWidth(3, 7) == 3 && e.errors.empty();
  if (!control) {
    g_test = "parked layout";
    EXPECT(drained && map1, "drained %d, restore map %d", drained, map1);
    EXPECT(moved >= 2, "only %u registers off position 0: the test shows nothing", moved);
    EXPECT(rows.size() == kArchGprs, "the restore shares rows: %zu for 16 registers", rows.size());
    EXPECT(same == kArchGprs, "%u of 16 registers came back at their position and width", same);
    EXPECT(e.core.slotWidth(3, 7) == 3, "R7's committed width came back %u", e.core.slotWidth(3, 7));
    for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
  }
  return ok;
}

/// OA's rev 166: a destination's width is its committed width, read from
/// the table at rename, not DEC's (no channel carries one). A warp whose
/// table says 32 bits writes R4 and R5 with a test's narrow hint, then
/// demotes: its names are 32 bits wide, and the park's assertion (each
/// committed name at its committed width) holds. The control takes the
/// hint's width, and the assertion must fire.
bool widthFromTable(bool control) {
  Config c = baseConfig();
  c.sectioned = true;
  c.l1_spec = false;
  c.inject_width_from_dec = control;
  Env e(c);
  e.keep_log = true;
  e.miss_extra = 300;
  std::vector<Op> p;
  Op a; a.k = kLane; a.dst = 4; a.w = 1; p.push_back(a);
  Op b; b.k = kLane; b.dst = 5; b.w = 2; p.push_back(b);
  Op ld; ld.k = kLoad; ld.dst = 8; ld.nsrc = 1; p.push_back(ld);
  Op u; u.k = kLane; u.dst = 9; u.src[0] = 8; u.nsrc = 1; p.push_back(u);
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(5, 1, p);
  e.preset_cw.clear();                       // the table stays at 32 bits
  for (unsigned k = 0; k != 200 && e.warpOf(5)->retired.size() < 2; ++k) e.step();
  e.core.demote(5);
  for (unsigned k = 0; k != 600; ++k) e.step();
  const auto names = e.core.committedGprs(1);
  const bool wide = e.core.nameWidth(names[4]) == 0 && e.core.nameWidth(names[5]) == 0;
  const bool ok = wide && e.errors.empty();
  if (!control) {
    g_test = "width from the committed table";
    EXPECT(wide, "R4 and R5 renamed at widths %u and %u, the table's 0", e.core.nameWidth(names[4]),
           e.core.nameWidth(names[5]));
    for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
  }
  return ok;
}

void testWidthFromTable() {
  widthFromTable(false);
  const bool held = widthFromTable(true);
  std::printf("  %-24s %s\n", "control width-from-dec", held ? "MISSED" : "caught");
  g_test = "width from the committed table (control)";
  EXPECT(!held, "renaming at DEC's width should break the committed-width assertion");
}

/// AR's rev 118: the MLC trigger's threshold governs RAU's MLC policy. With
/// the MLC threshold at 100 and the fallback at 50, a head load that misses
/// L1 and stays out past both reports the fallback's stall first, without
/// mlc_miss_seen, and the MLC trigger some 50 cycles later. The control has
/// the fallback's report claim the miss, so RAU would demote at 50.
bool mlcTrigger(bool control) {
  Config c = baseConfig();
  c.demote_mlc_miss = 100;
  c.demote_fallback = 50;
  c.inject_fallback_claims_mlc = control;
  Env e(c);
  e.keep_log = true;
  e.miss_pct = 100;
  e.miss_extra = 600;
  std::vector<Op> p;
  Op ld; ld.k = kLoad; ld.dst = 8; ld.nsrc = 1; p.push_back(ld);
  Op u; u.k = kLane; u.dst = 9; u.src[0] = 8; u.nsrc = 1; p.push_back(u);
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  uint64_t stalled_at = 0, mlc_at = 0;
  for (unsigned k = 0; k != 600; ++k) {
    e.step();
    for (const Status &st : e.log.back().status) {
      if (st.stalled && !stalled_at) stalled_at = e.t;
      if (st.stalled && st.mlc_miss_seen && !mlc_at) mlc_at = e.t;
    }
  }
  const bool ok = stalled_at && mlc_at && mlc_at >= stalled_at + 40;
  if (!control) {
    g_test = "MLC trigger at its own threshold";
    EXPECT(ok, "the fallback's stall at cycle %llu, mlc_miss_seen first at %llu: want it about 50 later",
           (unsigned long long)stalled_at, (unsigned long long)mlc_at);
  }
  return ok;
}

void testMlcTrigger() {
  mlcTrigger(false);
  const bool held = mlcTrigger(true);
  std::printf("  %-24s %s\n", "control fallback-claims-mlc", held ? "MISSED" : "caught");
  g_test = "MLC trigger at its own threshold (control)";
  EXPECT(!held, "a fallback report claiming the miss should demote at the fallback's threshold");
}

/// TI-34 (OA's revs 176-177): every memop, barrier and fault carries the
/// warp's CTA slot from its tier-1 slot's register, loaded at launch (the
/// environment's check, every cycle of every test). Here a warp loads,
/// stores and waits at a barrier; the control stamps slot 0, which the
/// check must catch.
bool ctaSlot(bool control) {
  Config c = baseConfig();
  c.inject_cta_slot_zero = control;
  Env e(c);
  e.keep_log = true;
  std::vector<Op> p;
  Op ld; ld.k = kLoad; ld.dst = 8; ld.nsrc = 1; p.push_back(ld);
  Op st; st.k = kStore; st.nsrc = 2; st.src[0] = 8; st.src[1] = 4; p.push_back(st);
  Op b; b.k = kBarrier; p.push_back(b);
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(5, 1, p);
  unsigned memops = 0, bars = 0;
  for (unsigned k = 0; k != 300; ++k) {
    e.step();
    memops += unsigned(e.log.back().memops.size());
    bars += unsigned(e.log.back().bars.size());
  }
  const bool ok = memops >= 2 && bars >= 1 && e.errors.empty();
  if (!control) {
    g_test = "CTA slot on memops and barriers";
    EXPECT(memops >= 2 && bars >= 1, "%u memops, %u barriers: the test shows nothing", memops, bars);
    for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
  }
  return ok;
}

/// O-64 (OA's rev 177): srd #2, %lanectx: OOE substitutes the hardware warp
/// context, the core's index above warp_id, shifted 5 (the lane ORs its
/// index in), as it does warp_in_cta for selector 0.
void testLaneCtx() {
  g_test = "srd #2 (%lanectx)";
  for (unsigned core : {0u, 3u}) {
    Config c = baseConfig();
    c.core_id = core;
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    Op a; a.k = kLane; a.dst = 4; a.srd = 2; p.push_back(a);
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(13, 1, p);
    bool seen = false;
    for (unsigned k = 0; k != 100 && !seen; ++k) {
      e.step();
      for (const Issue &is : e.log.back().issues)
        if (is.warp == 13 && is.send_imm && !is.copy) {
          seen = true;
          EXPECT(is.imm == (((core << 5) | 13u) << 5), "core %u: %%lanectx substituted as %08x", core, is.imm);
        }
    }
    EXPECT(seen, "core %u: the srd never issued", core);
    for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
  }
}

/// TI-36 (b) (OA's rev 180): a load whose only destination is a predicate
/// (ld.pred) at a partial mask makes the masked-load copy, as a GPR load
/// does: the copy-only op carries the old predicate to the new, so the
/// inactive lanes keep their bits; the load itself then reads no old
/// predicate. At a full, unguarded mask it is elided. The control makes
/// none. Model-only (main()): no stub carries ld.pred, and ooe_rendep's copy
/// reads the old GPR destination until it does.
bool ldPredCopy(bool control) {
  bool ok = true;
  for (uint32_t mask : {0x0000ffffu, kFullMask}) {
    Config c = baseConfig();
    c.inject_pred_copy_lost = control;
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    Op sp; sp.k = kSetp; sp.nsrc = 2; sp.pdst = 1; p.push_back(sp);
    Op ld; ld.k = kLoad; ld.nsrc = 1; ld.pred_only = true; ld.pdst = 1; ld.mask = mask; p.push_back(ld);
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(6, 0, p);
    unsigned copies = 0, setp_dst = ~0u, copy_old = ~0u, copy_dst = 0;
    for (unsigned k = 0; k != 400 && !e.warpOf(6)->exited; ++k) {
      e.step();
      for (const Issue &is : e.log.back().issues) {
        if (is.warp != 6) continue;
        if (!is.copy && setp_dst == ~0u) setp_dst = is.ppdst;   // the setp issues first
        if (is.copy) { ++copies; copy_old = is.ppold; copy_dst = is.pdst; }
      }
    }
    const bool want = mask != kFullMask;
    const bool good = e.warpOf(6)->exited && copies == (want ? 1u : 0u) && (!want || copy_old == setp_dst) &&
                      e.errors.empty();
    ok = ok && good;
    if (!control) {
      g_test = "ld.pred's copy (TI-36)";
      EXPECT(e.warpOf(6)->exited, "mask %08x: the warp never finished", mask);
      EXPECT(copies == (want ? 1u : 0u), "mask %08x: %u copies", mask, copies);
      EXPECT(!want || copy_old == setp_dst, "mask %08x: the copy carries old predicate pp%u, the setp's pp%u", mask,
             copy_old, setp_dst);
      // TI-37: no GPR destination names the zero register, never row 0.
      EXPECT(!want || e.core.isZeroName(copy_dst), "mask %08x: the copy names GPR p%u", mask, copy_dst);
      for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
    }
  }
  return ok;
}

void testLdPredCopy() {
  ldPredCopy(false);
  const bool held = ldPredCopy(true);
  std::printf("  %-24s %s\n", "control pred-copy-lost", held ? "MISSED" : "caught");
  g_test = "ld.pred's copy (control)";
  EXPECT(!held, "a partial-mask ld.pred without its copy should fail the check");
}

/// TI-37 (OA's rev 182): no GPR destination is the zero register's name on
/// the issue and the memop: a setp, ld.pred at a partial mask (and its copy)
/// and a store. The control sends 0, a real row.
bool noneIsZero(bool control) {
  Config c = baseConfig();
  c.inject_none_row_zero = control;
  Env e(c);
  std::vector<Op> p;
  Op sp; sp.k = kSetp; sp.nsrc = 2; sp.pdst = 1; p.push_back(sp);
  Op ld; ld.k = kLoad; ld.nsrc = 1; ld.pred_only = true; ld.pdst = 1; ld.mask = 0x0000ffffu; p.push_back(ld);
  Op st; st.k = kStore; st.nsrc = 2; p.push_back(st);
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(6, 0, p);
  for (unsigned k = 0; k != 400 && !e.warpOf(6)->exited; ++k) e.step();
  if (!control) {
    g_test = "no GPR destination (TI-37)";
    EXPECT(e.warpOf(6)->exited, "the warp never finished");
    for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
  }
  // Held unless the TI-37 check itself names it.
  bool named = false;
  for (const std::string &x : e.errors) named = named || x.rfind("TI-37:", 0) == 0;
  return e.warpOf(6)->exited && !named;
}

void testNoneIsZero() {
  noneIsZero(false);
  const bool held = noneIsZero(true);
  std::printf("  %-24s %s\n", "control none-row-zero", held ? "MISSED" : "caught");
  g_test = "no GPR destination (control)";
  EXPECT(!held, "no GPR destination sent as row 0 should fail the check");
}

/// IS-19 / O-69 (OA's rev 183): a local form is an ordinary memop with no
/// base source. ld.local behind a slow producer of the register its base
/// would name issues on nothing, carries local_form to MIU, and at a
/// partial mask makes the masked-load copy. The control gives it a base
/// read, so it waits for the producer.
bool ldLocal(bool control) {
  Config c = groupConfig();
  Env e(c);
  e.keep_log = true;
  std::vector<Op> p;
  Op sf; sf.k = kSfu; sf.dst = 1; p.push_back(sf);
  Op ld; ld.k = kLoad; ld.local = true; ld.src[0] = 1; ld.nsrc = control ? 1 : 0; ld.dst = 2;
  ld.mask = 0x0000ffffu; p.push_back(ld);
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(6, 0, p);
  uint64_t sf_at = ~uint64_t(0), ld_at = ~uint64_t(0);
  unsigned copies = 0, local = 0;
  for (unsigned k = 0; k != 400 && !e.warpOf(6)->exited; ++k) {
    e.step();
    for (const Issue &is : e.log.back().issues) {
      if (is.warp != 6) continue;
      if (!is.copy && is.res != Issue::kMemop && sf_at == ~uint64_t(0)) sf_at = k;
      copies += is.copy;
    }
    for (const Memop &m : e.log.back().memops)
      if (m.warp == 6 && m.mem_op != 0xF) {
        if (ld_at == ~uint64_t(0)) ld_at = k;
        local += m.local_form;
      }
  }
  const bool early = sf_at != ~uint64_t(0) && ld_at < sf_at + c.unit_lat[4];
  const bool ok = e.warpOf(6)->exited && early && local == 1 && copies == 1 && e.errors.empty();
  if (!control) {
    g_test = "ld.local (IS-19)";
    EXPECT(e.warpOf(6)->exited, "the warp never finished");
    EXPECT(early, "the local load's memop at %llu waits on the producer issued at %llu",
           (unsigned long long)ld_at, (unsigned long long)sf_at);
    EXPECT(local == 1, "%u memops carry local_form", local);
    EXPECT(copies == 1, "%u copies at a partial mask", copies);
    for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
  }
  return ok;
}

void testLdLocal() {
  ldLocal(false);
  const bool held = ldLocal(true);
  std::printf("  %-24s %s\n", "control local-base", held ? "MISSED" : "caught");
  g_test = "ld.local (control)";
  EXPECT(!held, "a local form reading a base should wait for its producer");
}

void testCtaSlot() {
  ctaSlot(false);
  const bool held = ctaSlot(true);
  std::printf("  %-24s %s\n", "control cta-slot-zero", held ? "MISSED" : "caught");
  g_test = "CTA slot (control)";
  EXPECT(!held, "memops with CTA slot 0 should break the TI-34 check");
}

void testParkedLayout() {
  parkedLayout(false);
  const bool held = parkedLayout(true);
  std::printf("  %-24s %s\n", "control park-layout-lost", held ? "MISSED" : "caught");
  g_test = "parked layout (control)";
  EXPECT(!held, "a restore without the layout should break the parked-layout checks");
}

/// TI-27 (OA's rev 170): the final-exit bit. Lanes 0-15 exit (a partial
/// exit, unmarked), the warp goes on in lanes 16-31 and is demoted on a
/// miss there: drained, not refused. A second run, undisturbed, ends the
/// warp at the marked exit of lanes 16-31: exited once, after it, and the
/// model's assertion (every lane has a retired exit) holds. The control
/// marks the first exit final, one exit early: the assertion must fire.
bool finalExit(bool control) {
  auto prog = [] {
    std::vector<Op> p;
    Op a; a.k = kLane; a.dst = 4; p.push_back(a);
    Op x0; x0.k = kExit; x0.mask = 0x0000ffffu; p.push_back(x0);
    Op ld; ld.k = kLoad; ld.dst = 8; ld.nsrc = 1; ld.mask = 0xffff0000u; p.push_back(ld);
    Op u; u.k = kLane; u.dst = 9; u.src[0] = 8; u.nsrc = 1; u.mask = 0xffff0000u; p.push_back(u);
    Op x1; x1.k = kExit; x1.mask = 0xffff0000u; p.push_back(x1);
    return p;
  };
  Config c = baseConfig();
  c.l1_spec = false;
  c.inject_final_exit_early = control;
  // Demoted after the partial exit: drained, not refused.
  bool drained = false, refused = false, early = false;
  {
    Env e(c);
    e.keep_log = true;
    e.miss_extra = 300;
    e.launch(5, 1, prog());
    for (unsigned k = 0; k != 200 && e.warpOf(5)->retired.size() < 2; ++k) e.step();
    e.core.demote(5);
    for (unsigned k = 0; k != 600 && !drained && !refused; ++k) {
      e.step();
      for (const Drained &d : e.log.back().drained)
        if (d.warp == 5) (d.refused ? refused : drained) = true;
    }
    for (const Outputs &o : e.log)
      for (const Status &st : o.status) early = early || st.exited;
  }
  // Undisturbed: exited once, after the marked exit's retire.
  Env e(c);
  e.keep_log = true;
  e.launch(5, 1, prog());
  for (unsigned k = 0; k != 1000 && !e.warpOf(5)->exited; ++k) e.step();
  for (unsigned k = 0; k != 20; ++k) e.step();
  unsigned exited = 0;
  for (const Outputs &o : e.log)
    for (const Status &st : o.status) exited += st.exited;
  const bool ok = drained && !refused && !early && e.warpOf(5)->exited && exited == 1 && e.errors.empty();
  if (!control) {
    g_test = "final-exit bit";
    EXPECT(drained && !refused, "demoted after a partial exit: drained %d, refused %d", drained, refused);
    EXPECT(!early, "exited sent while lanes 16-31 were live");
    EXPECT(e.warpOf(5)->exited && exited == 1, "the marked exit retired %d, exited sent %u times",
           e.warpOf(5)->exited, exited);
    for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
  }
  return ok;
}

void testFinalExit() {
  finalExit(false);
  const bool held = finalExit(true);
  std::printf("  %-24s %s\n", "control final-exit-early", held ? "MISSED" : "caught");
  g_test = "final-exit bit (control)";
  EXPECT(!held, "a final exit marked one exit early should break the final-exit assertion");
}

/// Restore-allocate through the candidate buffers (OA's response OI-41):
/// rename stalls for every warp while it takes its registers, its map
/// comes within V-64's bound, and a restore-activate before the map is
/// refused (V-49).
void testRestore() {
  g_test = "restore";
  Config c = baseConfig();
  c.l1_spec = false;
  Env e(c);
  e.keep_log = true;
  std::mt19937 rng(3);
  e.launch(5, 1, randomProgram(rng, 80, false));
  for (unsigned k = 0; k != 6; ++k) e.step();
  const uint64_t stalls = e.core.counters["stall.restore"];
  Alloc ra; ra.warp = 0; ra.slot = 0; ra.op = kAllocRestoreAlloc; ra.cta_slot = Env::ctaSlotOf(0);
  ra.barrier_count = 5;
  e.core.alloc(ra);
  unsigned took = 0;
  RatMap map{};
  bool got = false;
  while (!got && took != 20) {
    e.step();
    ++took;
    for (const RatMap &m : e.log.back().maps)
      if (m.direction == 1) { map = m; got = true; }
  }
  const unsigned w = c.rename_width, least = (kArchGprs + w - 1) / w, bound = least + 1;
  EXPECT(got, "no restore map");
  EXPECT(took >= least && took <= bound, "the map came %u cycles after acceptance; ports allow %u, V-64 %u",
         took, least, bound);
  EXPECT(e.core.counters["stall.restore"] - stalls == took, "rename stalled %llu cycles for a %u-cycle restore",
         (unsigned long long)(e.core.counters["stall.restore"] - stalls), took);
  EXPECT(e.core.heldGprs(0) == kArchGprs, "restore allocated %u", e.core.heldGprs(0));
  // The CTA's barrier count rides restore-allocate too: the warp may land
  // in another slot than it launched in (OA's response IS-16).
  EXPECT(e.core.slotBarCount(0) == 5, "restore-allocate left barrier count %u", e.core.slotBarCount(0));
  const std::set<unsigned> rows(map.gpr.begin(), map.gpr.end());
  EXPECT(rows.size() == kArchGprs && !rows.count(c.phys_zero), "the map names %zu distinct rows", rows.size());
  Alloc act; act.warp = 0; act.slot = 0; act.op = kAllocRestoreActivate;
  e.core.alloc(act);
  e.finish();   // the other warp, stalled meanwhile, still retires its program
  for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
  // Activating before the map is a protocol error.
  e.errors.clear();
  Alloc rb; rb.warp = 10; rb.slot = 2; rb.op = kAllocRestoreAlloc; rb.cta_slot = Env::ctaSlotOf(10);
  Alloc ab = rb; ab.op = kAllocRestoreActivate;
  e.core.alloc(rb);
  e.core.alloc(ab);
  e.step();
  bool refused = false;
  for (const std::string &x : e.errors) refused = refused || x.find("before its map") != std::string::npos;
  EXPECT(refused, "a restore-activate before the map was accepted");
}

/// A consumer final long before its producer: an SFU op of 30 cycles,
/// bypassed to a lane op that issues at 9 and is final at 16, then waits on
/// its row until the SFU op confirms. ooe_rs leads that confirmation from
/// the lane op's final bit alone (OA's response OI-61): its bench's no-fin
/// control is caught here.
void testFinalBeforeProducer() {
  g_test = "final-before-producer";
  Config c = groupConfig();
  c.unit_lat[4] = 30;
  Env e(c, 13);
  std::vector<Op> p;
  Op f; f.k = kSfu; f.dst = 2; f.src[0] = 1; f.nsrc = 1; p.push_back(f);
  Op l; l.k = kLane; l.dst = 3; l.src[0] = 2; l.nsrc = 1; p.push_back(l);
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  e.finish();
  EXPECT(e.core.counters["errors"] == 0, "errors");
  EXPECT(e.core.freeGprs() + e.core.heldGprs(0) == c.phys_regs, "register leak");
}

/// A squash that reaches loads whose wake timers have saturated: the
/// mispredicted branch waits on a chain of SFU ops, nearly fifty cycles,
/// while the wrong path's loads issue at once and wait longer still for
/// their completions. ooe_wake clocks such a timer only on the squash's
/// lead (OA's responses OI-58, OI-62): its bench's no-sq-lead control is
/// caught here.
void testSquashSaturated() {
  g_test = "squash-saturated";
  Config c = baseConfig();
  c.l1_spec = false;
  Env e(c, 11);
  e.miss_extra = 150;              // wrong-path loads outstanding past saturation
  std::vector<Op> p;
  for (unsigned i = 0; i != 4; ++i) {
    Op f; f.k = kSfu; f.dst = 2 + i; f.src[0] = 1 + i; f.nsrc = 1; p.push_back(f);
  }
  Op s; s.k = kSetp; s.pdst = 1; s.src[0] = 5; s.nsrc = 1; p.push_back(s);
  Op b; b.k = kBranch; b.pguard = 1; b.taken = true; b.pred_taken = false; p.push_back(b);
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  e.finish();
  EXPECT(e.core.counters["errors"] == 0, "errors");
  EXPECT(e.core.counters["squash.entries"] > 0, "nothing was squashed");
  EXPECT(e.core.counters["branch.mispredict"] == 1, "mispredicts");
  EXPECT(e.core.freeGprs() + e.core.heldGprs(0) == c.phys_regs, "register leak");
}

void testKill() {
  g_test = "kill";
  Config c = baseConfig();
  c.l1_spec = false;
  Env e(c);
  e.keep_log = true;
  e.miss_extra = 50;
  std::vector<Op> p;
  for (unsigned i = 0; i != 3; ++i) { Op ld; ld.k = kLoad; ld.dst = i; ld.nsrc = 1; p.push_back(ld); }
  for (unsigned i = 0; i != 8; ++i) { Op a; a.k = kLane; a.dst = 4; a.src[0] = i % 3; a.nsrc = 1; p.push_back(a); }
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  for (unsigned k = 0; k != 20; ++k) e.step();
  e.core.kill(1u, 2);
  uint64_t ack = 0, notice = 0, last_cmpl = 0;
  for (unsigned k = 0; k != 200; ++k) {
    if (!e.cmpls.empty()) last_cmpl = e.cmpls.rbegin()->first;
    e.step();
    for (const Redirect &r : e.log.back().redirects) if (r.epoch_only) notice = e.t - 1;
    for (unsigned a : e.log.back().kill_acks) { EXPECT(a == 2, "ack epoch %u", a); if (!ack) ack = e.t - 1; }
  }
  EXPECT(ack && notice && ack >= notice + c.redirect_lat, "ack %llu notice %llu (V-57)",
         (unsigned long long)ack, (unsigned long long)notice);
  EXPECT(ack >= last_cmpl, "acked at %llu before the memops completed at %llu (V-28)",
         (unsigned long long)ack, (unsigned long long)last_cmpl);
  EXPECT(e.core.freeGprs() == c.phys_regs, "kill left %zu free", e.core.freeGprs());
  for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
}

void testFault() {
  g_test = "fault";
  Config c = baseConfig();
  c.l1_spec = false;
  Env e(c);
  e.keep_log = true;
  std::vector<Op> p;
  // The second op came from DEC with a fault (TI's 75b6a19: the uop's cause).
  for (unsigned i = 0; i != 3; ++i) { Op a; a.k = kLane; a.dst = i; a.nsrc = 1; a.cause = i == 1 ? 2 : 0; p.push_back(a); }
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  unsigned faults = 0, cause = 0;
  for (unsigned k = 0; k != 100; ++k) {
    e.step();
    for (const Status &s : e.log.back().status) faults += s.fault_taken;
    for (const Fault &f : e.log.back().faults) cause = f.cause;
  }
  EXPECT(cause == 2, "cause %u, want DEC's F-ILLEGAL (2)", cause);
  EXPECT(faults == 1, "fault_taken %u times", faults);
  EXPECT(e.w[0].retired.size() == 1, "%zu retired; V-24 stops at the fault", e.w[0].retired.size());
  e.core.kill(1u, 1);
  for (unsigned k = 0; k != 20; ++k) e.step();
  EXPECT(e.core.freeGprs() == c.phys_regs, "kill after a fault left %zu free", e.core.freeGprs());
}

/// OI-84 (OA's rev 264): four warps, each with an atomic pair at its head
/// again and again, CASes and RMWs, so every round-0 head is a first slot.
/// Under OI-79 (b)'s rounds each pair's second falls past the width and
/// the cut takes nothing, cycle after cycle; under (a) a pair's second
/// takes the lane after its first, and every warp finishes.
// control: pair-rounds (inject_pair_rounds), which must not finish.
void testPairHeads(bool control = false) {
  g_test = "atomic pairs at four heads";
  Config c = baseConfig();
  c.l1_spec = false;
  c.inject_pair_rounds = control;
  Env e(c, 9);
  for (unsigned w = 0; w != 4; ++w) {
    std::vector<Op> p;
    for (unsigned i = 0; i != 6; ++i) {
      Op x; x.k = kAtomic; x.dst = 4 + (i & 1); x.src[0] = 5; x.src[1] = 6;
      if ((i + w) % 2) {
        x.cas = true; x.nsrc = 2; x.csrc[0] = 7; x.csrc[1] = 8; x.ncsrc = 2;
      } else {
        x.src[2] = 7; x.nsrc = 3;
      }
      p.push_back(x);
    }
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(w * 5, w, p);
  }
  e.finish();
  if (control) return;
  EXPECT(e.core.counters["rename.cas_pair"] == 24, "%llu atomic pairs renamed, want 24",
         (unsigned long long)e.core.counters["rename.cas_pair"]);
}

/// OI-79 (b)'s cut: two warps, one of predicate writes, one of a lane op
/// and a CAS again and again, so a CAS's first slot often takes the cycle's
/// last lane and its second would be the next's; the take stops before the
/// first. Neither warp writes enough GPRs or MIU rows for the cycle's ports
/// to bind (OI-80), so go_tb holds the RTL's cut to the model's.
// control: OI-80's liveness rule dropped (inject_no_first_need), which must
// fail: both warps a CAS stream from two MIU rows in all, so the equal split
// gives each one and a pair needs two (A1's and A3's, OI-80 (d)); only the
// rotation's reserve lets a pair through, and without it neither warp moves.
void testPairCut(bool control = false) {
  g_test = "CAS pair cut";
  Config c = baseConfig();
  c.l1_spec = false;
  c.inject_no_first_need = control;
  if (control) c.rs_miu = 2;
  Env e(c, 5);
  std::vector<Op> a, b;
  if (control)
    for (unsigned i = 0; i != 12; ++i) {
      Op x; x.k = kAtomic; x.cas = true; x.dst = 4; x.src[0] = 5; x.src[1] = 6; x.nsrc = 2;
      x.csrc[0] = 7; x.csrc[1] = 8; x.ncsrc = 2; a.push_back(x);
    }
  else
    for (unsigned i = 0; i != 60; ++i) { Op s; s.k = kSetp; s.pdst = 1 + i % 3; s.nsrc = 2; a.push_back(s); }
  for (unsigned i = 0; i != 12; ++i) {
    Op l; l.k = kLane; l.dst = 3; l.nsrc = 1; b.push_back(l);
    Op x; x.k = kAtomic; x.cas = true; x.dst = 4; x.src[0] = 5; x.src[1] = 6; x.nsrc = 2;
    x.csrc[0] = 7; x.csrc[1] = 8; x.ncsrc = 2; b.push_back(x);
  }
  Op ex; ex.k = kExit;
  a.push_back(ex);
  b.push_back(ex);
  e.launch(0, 0, a);
  e.launch(1, 1, b);
  e.finish();
  if (control) return;
  EXPECT(e.core.counters["rename.pair_cut"] > 0, "no take was cut before a pair (%llu pairs)",
         (unsigned long long)e.core.counters["rename.cas_pair"]);
  EXPECT(e.core.counters["stall.rename_ports"] == 0, "the cycle's ports bound %llu times",
         (unsigned long long)e.core.counters["stall.rename_ports"]);
}

/// Every barrier report a run sent, in order.
std::vector<Bar> barsOf(const Env &e) {
  std::vector<Bar> v;
  for (const Outputs &o : e.log) v.insert(v.end(), o.bars.begin(), o.bars.end());
  return v;
}

/// Barriers (TI-40, TI-41; AR's revs 161-164, OA's revs 200-204): every
/// arrive, wait and exit is reported at its retire. A converged wait (FET's
/// all_waiting) is reported held and holds rename behind it until SYU's
/// ccv_syu_ooe_rel; a diverged one holds nothing (FET parks its lanes), nor
/// does an arrive, whose guard lanes come back on its done. The control
/// bar-no-hold drops the hold, so a younger uop issues before the release.
void testBarrier() {
  for (const bool control : {false, true}) {
    g_test = control ? "barrier held (control)" : "barrier held";
    Config c = baseConfig();
    c.l1_spec = false;
    c.inject_bar_no_hold = control;
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    Op a; a.k = kLane; a.dst = 1; a.nsrc = 1; p.push_back(a);
    Op b; b.k = kBarrier; p.push_back(b);
    Op d; d.k = kLane; d.dst = 2; d.nsrc = 1; p.push_back(d);
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    for (unsigned k = 0; k != 40; ++k) e.step();
    std::vector<Bar> v = barsOf(e);
    const bool held = v.size() == 1 && v[0].kind == kBarWait && v[0].held;
    const bool younger = issueCount(e, 3) != 0;
    if (control) {
      const bool caught = younger || !held;
      std::printf("  %-24s %s\n", "control bar-no-hold", caught ? "caught" : "MISSED");
      EXPECT(caught, "dropping the hold should let a younger uop issue");
      continue;
    }
    EXPECT(held, "%zu reports, want one held wait", v.size());
    if (!v.empty()) {
      EXPECT(v[0].barrier_id == 3, "barrier id %u", v[0].barrier_id);
      EXPECT(v[0].issue_mask == kFullMask && v[0].guard_mask == ~0u, "masks %08x %08x", v[0].issue_mask, v[0].guard_mask);
    }
    EXPECT(!younger, "a uop younger than the held wait issued before release (V-09)");
    EXPECT(issueCount(e, 2) == 0, "an unguarded wait issued: it completes without issue, as exit");
    EXPECT(e.w[0].retired.size() == 2, "retired %zu before release: the wait retires", e.w[0].retired.size());
    e.core.barRelease(1u);
    e.finish();
    v = barsOf(e);
    EXPECT(v.size() == 2 && v[1].kind == kBarExit && v[1].issue_mask == kFullMask, "%zu reports, want the exit's", v.size());
    EXPECT(e.core.counters["bar.release"] == 1, "releases %llu", (unsigned long long)e.core.counters["bar.release"]);
  }
  {
    // A diverged wait: reported, not held; a release before it is stale.
    g_test = "barrier diverged";
    Config c = baseConfig();
    c.l1_spec = false;
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    Op b; b.k = kBarrier; b.aw = false; p.push_back(b);
    Op d; d.k = kLane; d.dst = 2; d.nsrc = 1; p.push_back(d);
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    e.core.barRelease(1u);
    e.finish();
    const std::vector<Bar> v = barsOf(e);
    EXPECT(v.size() == 2 && v[0].kind == kBarWait && !v[0].held,
           "%zu reports, want an unheld wait", v.size());
    EXPECT(e.core.counters["hold.barrier"] == 0, "a diverged wait held rename");
    EXPECT(e.core.counters["bar.release_dropped"] == 1, "the stale release was not dropped");
  }
  for (const bool guarded : {false, true}) {
    // bar.arrive: no hold; a guarded one's guard lanes from its done.
    g_test = "barrier arrive";
    Config c = baseConfig();
    c.l1_spec = false;
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    Op b; b.k = kBarrier; b.arrive = true; b.guard = guarded; b.lanes = 0x00ff00ff; p.push_back(b);
    Op d; d.k = kLane; d.dst = 2; d.nsrc = 1; p.push_back(d);
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    e.finish();
    const std::vector<Bar> v = barsOf(e);
    EXPECT(v.size() == 2 && v[0].kind == kBarArrive && !v[0].held, "%zu reports, want an arrive", v.size());
    if (!v.empty())
      EXPECT(v[0].guard_mask == (guarded ? 0x00ff00ffu : ~0u), "guard lanes %08x", v[0].guard_mask);
    EXPECT(e.core.counters["hold.barrier"] == 0, "an arrive held rename");
    EXPECT(issueCount(e, 1) == (guarded ? 1u : 0u), "the arrive issued %u times: only a guarded one goes to RCU",
           issueCount(e, 1));
  }
  {
    // wait.phase: its expected phases from its done; held as a wait.
    g_test = "barrier wait.phase";
    Config c = baseConfig();
    c.l1_spec = false;
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    Op b; b.k = kBarrier; b.phase = true; b.lanes = 0x5555aaaa; p.push_back(b);
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    for (unsigned k = 0; k != 40; ++k) e.step();
    const std::vector<Bar> v = barsOf(e);
    EXPECT(v.size() == 1 && v[0].kind == kBarWaitPhase && v[0].held && v[0].phase_mask == 0x5555aaaa,
           "%zu reports, want a held wait.phase", v.size());
    e.core.barRelease(1u);
    e.finish();
  }
}

/// A demotion of a warp held behind a retired converged wait (TI-40, AR's
/// rev 164): its rewind beat sets rewind_held, and held_long for a 32-bit
/// wait, at the PC past the wait, whether a younger uop waits in the
/// decode queue or nothing does. The control beat-unheld drops the flag.
void testBarrierDemote() {
  for (const bool control : {false, true}) {
    for (const bool tail : {true, false}) {
      g_test = control ? "barrier demote (control)" : "barrier demote";
      Config c = baseConfig();
      c.l1_spec = false;
      c.inject_beat_unheld = control;
      Env e(c);
      e.keep_log = true;
      std::vector<Op> p;
      Op a; a.k = kLane; a.dst = 1; a.nsrc = 1; p.push_back(a);
      Op b; b.k = kBarrier; p.push_back(b);
      if (tail) { Op d; d.k = kLane; d.dst = 2; d.nsrc = 1; p.push_back(d); }
      e.launch(0, 0, p);
      for (unsigned k = 0; k != 40; ++k) e.step();
      uint64_t wait_pc = 0;
      for (const Outputs &o : e.log)
        for (const Bar &x : o.bars) wait_pc = 0x1000 + 4 * (x.tid & 0xffff);
      e.core.demote(0);
      std::vector<Redirect> beats;
      for (unsigned k = 0; k != 40; ++k) {
        e.step();
        for (const Redirect &r : e.log.back().redirects) if (r.rewind) beats.push_back(r);
      }
      const bool flagged = beats.size() == 1 && beats[0].rewind_held && beats[0].held_long &&
                           beats[0].own_pc == !tail;
      if (control) {
        if (tail) {
          std::printf("  %-24s %s\n", "control beat-unheld", !flagged ? "caught" : "MISSED");
          EXPECT(!flagged, "dropping the flag should leave the beat unheld");
        }
        continue;
      }
      EXPECT(wait_pc, "no wait report");
      EXPECT(flagged, "%zu beats, want one with rewind_held, held_long, and own_pc iff nothing follows",
             beats.size());
      if (!beats.empty()) {
        EXPECT(beats[0].target_pc == wait_pc + 4, "beat at %llx, the wait at %llx",
               (unsigned long long)beats[0].target_pc, (unsigned long long)wait_pc);
        EXPECT(beats[0].taken_mask == kFullMask, "beat lanes %08x", beats[0].taken_mask);
      }
      EXPECT(e.core.counters["demote.held_wait"] == 1, "the demotion did not see the held wait");
      EXPECT(e.core.counters["errors"] == 0, "errors");
    }
  }
}

/// The barrier demotion timer (TI-40): from a held wait's retire, or a
/// marked uop's that leaves the ROB empty, the trigger fires once the ROB
/// has stayed empty past demote_barrier; a younger uop's arrival stops it.
void testBarrierTimer() {
  // Held wait; a marked lane op (no start: AR's rev 186); a marked partial
  // exit; a marked partial exit with more behind it.
  for (const unsigned mode : {0u, 1u, 2u, 3u}) {
    g_test = "barrier timer";
    Config c = baseConfig();
    c.l1_spec = false;
    c.demote_barrier = 30;
    Env e(c);
    std::vector<Op> p;
    Op a; a.k = kLane; a.dst = 1; a.nsrc = 1; p.push_back(a);
    if (mode == 0) { Op b; b.k = kBarrier; p.push_back(b); }
    else if (mode == 1) { Op m; m.k = kLane; m.dst = 2; m.nsrc = 1; m.mark = true; p.push_back(m); }
    else { Op m; m.k = kExit; m.mark = true; p.push_back(m); }
    if (mode == 3) {
      Op d; d.k = kLane; d.dst = 3; d.nsrc = 1; p.push_back(d);
      Op ex; ex.k = kExit; ex.last = ex.final = true; p.push_back(ex);
    }
    e.launch(0, 0, p);
    for (unsigned k = 0; k != 120; ++k) e.step();
    const unsigned long long fired = e.core.counters["demote_trigger.barrier"];
    EXPECT(fired == (mode == 0 || mode == 2 ? 1u : 0u), "mode %u: %llu barrier triggers", mode, fired);
  }
}

/// F-BARRIER (IS-16, ISA v1.9 O-59): a barrier whose ID is at or above its
/// CTA's allocated count faults at dispatch, cause 9, and never reaches
/// SYU; one below it waits as before. The control drops the check, so the
/// wait goes out and no fault is taken.
void testBarrierFault() {
  for (const bool control : {false, true}) {
    for (const unsigned count : {3u, 4u}) {
      g_test = control ? "barrier fault (control)" : "barrier fault";
      Config c = baseConfig();
      c.l1_spec = false;
      c.inject_no_bar_fault = control;
      Env e(c);
      e.keep_log = true;
      std::vector<Op> p;
      Op a; a.k = kLane; a.dst = 1; a.nsrc = 1; p.push_back(a);
      Op b; b.k = kBarrier; p.push_back(b);     // ID 3
      Op ex; ex.k = kExit; p.push_back(ex);
      e.launch(0, 0, p, count);
      unsigned bars = 0, faults = 0, cause = 0;
      for (unsigned k = 0; k != 40; ++k) {
        e.step();
        for (const Bar &x : e.log.back().bars) bars += x.kind != kBarExit;
        for (const Fault &f : e.log.back().faults) { ++faults; cause = f.cause; }
      }
      const bool want_fault = count <= 3 && !control;
      if (control) {
        if (count == 3) {
          const bool caught = faults == 0 && bars == 1;
          std::printf("  %-24s %s\n", "control no-bar-fault", caught ? "caught" : "MISSED");
          EXPECT(caught, "dropping the check should send the wait");
        }
        continue;
      }
      EXPECT((faults == 1) == want_fault, "count %u: %u faults", count, faults);
      if (want_fault) {
        EXPECT(cause == kCauseBarrier, "cause %u, want F-BARRIER (%u)", cause, kCauseBarrier);
        EXPECT(bars == 0, "a faulting barrier reached SYU");
      } else {
        EXPECT(bars == 1, "count %u: %u barrier waits", count, bars);
      }
    }
  }
}

/// V-74 (OA's response IS-16): one fault-address register per warp holds
/// the oldest faulting memop's address, whatever order the completions come
/// in, and the fault record reads it at the head. Two loads both fault: in
/// one run the older completes first, in the other the younger. Each must
/// report the older's address and MIU's cause. The control lets every
/// faulting completion write the register, so the younger's, landing
/// second, overwrites the older's, and V-74 must fire.
void testMemFault() {
  for (const bool control : {false, true}) {
    unsigned caught = 0;
    for (const bool younger_first : {false, true}) {
      g_test = control ? "mem fault (control)" : "mem fault";
      Config c = baseConfig();
      c.l1_spec = false;
      c.inject_fa_youngest = control;
      Env e(c);
      e.keep_log = true;
      // A slow SFU op ahead holds the head, so both completions land before
      // the fault is taken.
      std::vector<Op> p;
      Op sl; sl.k = kSfu; sl.dst = 5; sl.nsrc = 1; p.push_back(sl);
      for (unsigned i = 0; i != 2; ++i) { Op a; a.k = kLoad; a.dst = 1 + i; a.nsrc = 1; a.src[0] = 6; p.push_back(a); }
      Op ex; ex.k = kExit; p.push_back(ex);
      e.launch(0, 0, p);
      bool marked[3] = {false, false, false};
      std::vector<Fault> faults;
      const int before = g_fail;
      for (unsigned k = 0; k != 120; ++k) {
        // Fault both loads' completions, and delay one so the other lands first.
        std::vector<std::pair<uint64_t, Cmpl>> moved;
        for (auto it = e.cmpls.begin(); it != e.cmpls.end();) {
          const unsigned idx = it->second.rob_tag & 31;
          if (idx >= 1 && idx <= 2 && !marked[idx]) {
            marked[idx] = true;
            Cmpl x = it->second;
            x.status = kCmplFault;
            x.cause = 6;                      // F-ADDR
            x.address = 0x1000 + idx - 1;
            // Older first: both land in one cycle, the older's processed
            // first, before the head can take it. Younger first: two cycles.
            const uint64_t due = younger_first ? (idx == 1 ? 42 : 40) : 40;
            moved.push_back({due, x});
            it = e.cmpls.erase(it);
          } else {
            ++it;
          }
        }
        std::sort(moved.begin(), moved.end(),
                  [](const auto &a, const auto &b) { return (a.second.rob_tag & 31) < (b.second.rob_tag & 31); });
        for (auto &m : moved) e.cmpls.insert(m);
        g_quiet = control;
        e.step();
        g_quiet = false;
        for (const Fault &f : e.log.back().faults) faults.push_back(f);
      }
      if (control) {
        caught += g_fail != before || !e.errors.empty();
        g_fail = before;
        continue;
      }
      for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
      EXPECT(faults.size() == 1, "%zu fault records", faults.size());
      if (!faults.empty()) {
        EXPECT(faults[0].address == 0x1000, "address %#llx, want the older load's 0x1000",
               (unsigned long long)faults[0].address);
        EXPECT(faults[0].cause == 6, "cause %u, want MIU's 6 (F-ADDR)", faults[0].cause);
      }
    }
    if (control) {
      g_test = "mem fault (control)";
      std::printf("  %-24s %s\n", "control fa-youngest", caught ? "caught" : "MISSED");
      EXPECT(caught, "a register taking every completion should break V-74");
    }
  }
}

/// The free list as the RTL builds it (OI-22): allocation from a rotating
/// pointer, so a freed register comes back only once the pointer wraps, and a
/// register freed in a cycle is not allocated until the next.
/// V-59 is an elaboration check: a configuration whose shortest wake is
/// under 3 cycles is refused, since cancel moves one hop a cycle (OA-1).
void testV59() {
  g_test = "v-59";
  Config c = baseConfig();
  EXPECT(c.check().empty(), "the base configuration passes: %s", c.check().c_str());
  c.lat_rcu = 2;
  EXPECT(c.check().rfind("V-59", 0) == 0, "an RCU latency of 2 refused: '%s'", c.check().c_str());
  c = baseConfig();
  c.bypass = true;
  c.lat_lane_byp = 2;
  EXPECT(c.check().rfind("V-59", 0) == 0, "a bypass at 2 refused: '%s'", c.check().c_str());
}

/// OI-51: select reads a registered ready, so a drop reaches it a cycle
/// late. Under misses a warp's dependants are granted on stale bits, and
/// the next hop returns each; select on the lines as they stand never is.
void testReadyReg() {
  g_test = "ready register: stale grants, each replayed";
  for (bool on : {true, false}) {
    uint64_t stale = 0, rstale = 0;
    for (unsigned seed = 1; seed <= 6; ++seed) {
      std::mt19937 rng(seed);
      Config c = baseConfig();
      c.ready_reg = on;
      Env e(c, seed);
      e.miss_pct = 20;
      for (unsigned i = 0; i != 4; ++i) e.launch(i, i, randomProgram(rng, 300, true));
      e.finish();
      EXPECT(e.errors.empty(), "%s", e.errors.empty() ? "" : e.errors[0].c_str());
      stale += e.core.counters["select.stale_grant"];
      rstale += e.core.counters["cancel.replay_stale"];
    }
    if (on) EXPECT(stale && rstale && rstale <= stale, "stale grants %llu, their replays %llu",
                   (unsigned long long)stale, (unsigned long long)rstale);
    else EXPECT(!stale && !rstale, "stale grants %llu with no ready register", (unsigned long long)stale);
  }
  // OI-54's control: a stop or miss captured one edge late lets a replayed
  // producer be re-granted inside its dependant's stale window; the
  // dependant, granted on its stale bit, is never replayed and confirms on
  // a result it read too early. The model's OA-17 check must see it.
  // Directed, one warp: a load L that misses by a cycle, a producer P
  // reading it (replayed, then re-granted as L's data lands) and P's
  // dependant D, whose ready register holds P's old line an edge too long.
  // A random hunt found it in one run in 100 to 700, and every change to
  // rename's traffic moved it; this family hits in about one case in 9 of
  // its wider search, and without the injection none of it errs.
  g_test = "ready register: a late capture confirms a stale grant (OI-54's control)";
  const int saved = g_fail;
  bool seen = false;
  auto run = [&](Kind pk, Kind dk, unsigned gap, unsigned extra, bool late, bool &hit, bool &other) {
    Config c = baseConfig();
    c.inject_late_event = late;
    Env e(c, 1);
    e.miss_pct = 100;
    e.miss_extra = extra;
    std::vector<Op> p;
    Op ld; ld.k = kLoad; ld.dst = 1; ld.src[0] = 9; ld.nsrc = 1; p.push_back(ld);
    Op pp; pp.k = pk; pp.dst = 2; pp.src[0] = 1; pp.nsrc = 1; p.push_back(pp);
    for (unsigned i = 0; i != gap; ++i) { Op f; f.k = kLane; f.dst = 12 + i; p.push_back(f); }
    Op dd; dd.k = dk; dd.dst = 3; dd.src[0] = 2; dd.nsrc = 1; p.push_back(dd);
    Op st; st.k = kStore; st.src[0] = 3; st.src[1] = 3; st.nsrc = 2; p.push_back(st);
    Op ex; ex.k = kExit; p.push_back(ex);
    e.core.on_error = [&](const std::string &m) {
      if (m.find("OA-17") != std::string::npos) hit = true;
      else other = true;
    };
    e.launch(0, 0, p);
    g_quiet = true;
    e.finish(5000);
    g_quiet = false;
  };
  bool clean = true;
  for (Kind pk : {kRcuOp, kLane, kSfu})
    for (Kind dk : {kLane, kRcuOp})
      for (unsigned gap = 0; gap != 3 && !seen; ++gap)
        for (unsigned extra = 1; extra != 4 && !seen; ++extra) {
          bool hit = false, other = false;
          run(pk, dk, gap, extra, true, hit, other);
          if (!hit) continue;
          seen = true;
          bool h2 = false, o2 = false;   // the same case, no injection: nothing errs
          run(pk, dk, gap, extra, false, h2, o2);
          clean = !h2 && !o2;
        }
  g_fail = saved;
  EXPECT(seen, "late capture never confirmed a stale grant");
  EXPECT(clean, "the late-event case errs without the injection");
  std::printf("  %-24s %s\n", "control late-event", seen ? "caught" : "MISSED");
}

void testFreeVec() {
  g_test = "free-vec";
  FreeVec f;
  f.reset(8);
  for (unsigned i = 0; i != 3; ++i) EXPECT(f.alloc() == i, "first pass in order");
  EXPECT(f.free(1), "free p1");
  EXPECT(!f.free(1), "a double free is refused");
  EXPECT(f.size() == 6 && f.ready() == 5, "p1 pending until the clock");
  for (unsigned i = 3; i != 8; ++i) EXPECT(f.alloc() == i, "past the freed p1 to the end");
  EXPECT(f.empty(), "p1 not allocatable in the cycle it was freed");
  f.clock();
  EXPECT(f.alloc() == 1, "p1 after the pointer wraps");
  EXPECT(f.empty() && f.size() == 0, "all allocated");
  for (unsigned p : {6u, 2u, 4u}) f.free(p);
  f.clock();
  EXPECT(f.alloc() == 2 && f.alloc() == 4 && f.alloc() == 6, "rotating from p2");
}

void testChwidth() {
  g_test = "chwidth";
  Config c = baseConfig();
  Env e(c);
  e.keep_log = true;
  std::vector<Op> p;
  Op a; a.k = kChw; p.push_back(a);
  Op d; d.k = kLane; d.dst = 2; d.nsrc = 1; p.push_back(d);
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  e.finish();
  for (const Outputs &o : e.log) for (const Issue &i : o.issues)
    if (i.tid == 2)   // AR-24 (d): each operand its own register's width
      EXPECT(i.src_w[0] == 2 && i.dst_w == 0, "the younger op read widths %u (R0) and %u (R2), not the committed 2 and 0",
             i.src_w[0], i.dst_w);
  // The registered hold's split (TI's rev 188): each refusal counted once
  // under its cause, the chwidth's here, summing to the total.
  auto &k = e.core.counters;
  const unsigned long long tot = k["hold.registered"],
      sum = k["hold.registered.inactive"] + k["hold.registered.chwidth"] + k["hold.registered.barrier"] +
            k["hold.registered.other"];
  EXPECT(tot == sum, "hold.registered %llu, its split sums to %llu", tot, sum);
  EXPECT(k["hold.registered.chwidth"] > 0, "no registered hold behind the chwidth (%llu in all)", tot);
  // The head-wait split (TI's rev 193) sums to its total.
  unsigned long long hw = 0;
  for (const char *c : {"rob_full", "load_at_miu", "load_unissued", "store", "mem_other", "branch", "rcu",
                        "lane_unissued", "lane_unconfirmed", "lane_confirmed"})
    hw += k[std::string("retire.head_wait.") + c];
  EXPECT(hw == k["retire.head_wait"] && hw > 0, "retire.head_wait %llu, its split %llu",
         (unsigned long long)k["retire.head_wait"], hw);
}

/// V-41 (FET spec rev 28, TI's rev 199): a branch or ret FET predicts taken
/// is right only if every active lane took it. Taken by half its group, it
/// is a mispredict: one redirect, for the lanes that took it (a ret with
/// stay). The control partial-taken counts it right, so nothing redirects.
void testPartialTaken(bool control = false) {
  for (const bool ret : {false, true}) {
      g_test = ret ? "partial taken ret" : "partial taken branch";
      Config c = baseConfig();
      c.l1_spec = false;
      c.inject_partial_taken_ok = control;
      Env e(c, 7);
      e.keep_log = true;
      std::vector<Op> p;
      Op a; a.k = kLane; a.dst = 3; a.nsrc = 1; p.push_back(a);
      Op b; b.k = kBranch; b.taken = b.pred_taken = true; b.tmask = 0x0000ffffu; b.ret = ret; b.ret_to = 0x2468;
      p.push_back(b);
      Op d; d.k = kLane; d.dst = 4; d.nsrc = 1; p.push_back(d);
      Op ex; ex.k = kExit; p.push_back(ex);
      e.launch(0, 0, p);
      e.finish();
      unsigned n = 0;
      for (const Outputs &o : e.log)
        for (const Redirect &r : o.redirects)
          if (!r.epoch_only) {
            ++n;
            EXPECT(r.taken_mask == 0x0000ffffu, "redirect lanes %08x", r.taken_mask);
            EXPECT(r.stay == ret, "stay %u", unsigned(r.stay));
          }
      EXPECT(n == 1, "%u redirects", n);
      EXPECT(e.core.counters["branch.mispredict"] == 1, "mispredicts %llu",
             (unsigned long long)e.core.counters["branch.mispredict"]);
    }
}

/// AR-24 (b) (OA's rev 223): a ret resolves at RCU, whose done names the
/// lowest active lane's target offset on aux and the lanes sharing it on
/// branch_mask. Mispredicted (FET predicts no ret target), it redirects
/// those lanes to {PC[47:32], aux} with stay, so the rest re-issue the ret.
/// A conditional branch's redirect never sets stay.
void testRet() {
  for (const bool ret : {true, false}) {
    g_test = ret ? "ret redirect" : "branch redirect, no stay";
    Config c = baseConfig();
    c.l1_spec = false;
    Env e(c, 7);
    e.keep_log = true;
    std::vector<Op> p;
    Op a; a.k = kLane; a.dst = 3; a.nsrc = 1; p.push_back(a);
    Op b; b.k = kBranch; b.taken = true; b.pred_taken = false; b.ret = ret; b.ret_to = 0x2468; p.push_back(b);
    Op d; d.k = kLane; d.dst = 4; d.nsrc = 1; p.push_back(d);
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    e.finish();
    unsigned n = 0;
    for (const Outputs &o : e.log)
      for (const Redirect &r : o.redirects)
        if (!r.epoch_only) {
          ++n;
          EXPECT(r.stay == ret, "stay %u", unsigned(r.stay));
          if (ret) EXPECT(r.target_pc == 0x2468, "ret target %llx, want {PC[47:32], aux} = 0x2468",
                          (unsigned long long)r.target_pc);
        }
    EXPECT(n == 1, "%u redirects", n);
    EXPECT(e.core.counters["branch.ret_redirect"] == (ret ? 1u : 0u), "ret redirects %llu",
           (unsigned long long)e.core.counters["branch.ret_redirect"]);
  }
}

/// AR-24 (c) (OA's rev 222): chwidth.multi cracks into a uop per register,
/// each but the last a commit_width sibling (serial 0) that commits its
/// register's width at retire with no hold; the last holds as a chwidth.
/// After the three, a lane op reads R4, R5 and R6 at 8 bits. The control
/// sibling-uncommitted drops the siblings' commits, so R4 and R5 stay 32.
void testChwidthMulti() {
  for (const bool control : {false, true}) {
    g_test = control ? "chwidth.multi (control)" : "chwidth.multi";
    Config c = baseConfig();
    c.inject_sibling_uncommitted = control;
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    for (unsigned r : {4u, 5u, 6u}) {
      Op w; w.k = kChw; w.dst = r; w.chw = 2; w.sibling = r != 6; p.push_back(w);
    }
    Op a; a.k = kLane; a.dst = 7; a.src[0] = 4; a.src[1] = 5; a.src[2] = 6; a.nsrc = 3; p.push_back(a);
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    e.finish();
    bool seen = false, ok = false;
    for (const Outputs &o : e.log)
      for (const Issue &i : o.issues)
        if (i.tid == 4) {
          seen = true;
          ok = i.src_w[0] == 2 && i.src_w[1] == 2 && i.src_w[2] == 2;
        }
    if (control) {
      std::printf("  %-24s %s\n", "control sibling-uncommitted", seen && !ok ? "caught" : "MISSED");
      EXPECT(seen && !ok, "dropping the siblings' commits should leave R4 and R5 at 32 bits");
      continue;
    }
    EXPECT(seen && ok, "the lane op read R4-R6 at other than 8 bits");
    // A chwidth that writes its register names it at the new width (TI's
    // rev 185): its destination's code is the width it sets.
    {
      Env f(c);
      f.keep_log = true;
      std::vector<Op> q;
      Op w; w.k = kChw; w.dst = 4; w.chw = 2; w.chw_writes = true; w.src[0] = 4; w.nsrc = 1; q.push_back(w);
      Op ex2; ex2.k = kExit; q.push_back(ex2);
      f.launch(0, 0, q);
      f.finish();
      bool got = false;
      for (const Outputs &o : f.log)
        for (const Issue &i : o.issues)
          if (i.tid == 1) {
            got = true;
            EXPECT(i.dst_w == 2 && i.src_w[0] == 0, "chwidth's widths dst %u src %u, want 2 and 0", i.dst_w, i.src_w[0]);
          }
      EXPECT(got, "the chwidth never issued");
    }
    EXPECT(e.core.counters["chwidth.sibling"] == 2, "%llu siblings committed",
           (unsigned long long)e.core.counters["chwidth.sibling"]);
  }
}

/// AR-24 (d)'s traffic for the rename bench (non-sectioned, so
/// test/ooe/rename_tb.cpp runs it): two warps narrow registers by chwidth
/// and by chwidth.multi's siblings, then many ops read and write them at
/// their widths, and one widens a register back.
void testWidthTraffic() {
  g_test = "width traffic";
  Config c = baseConfig();
  c.l1_spec = false;
  Env e(c, 11);
  auto prog = [](unsigned seed) {
    std::vector<Op> p;
    std::mt19937 r(seed);
    for (unsigned reg : {4u, 5u, 6u}) {   // a chwidth.multi: two siblings and the last
      Op w; w.k = kChw; w.dst = reg; w.chw = reg == 4 ? 1 : 2; w.sibling = reg != 6; p.push_back(w);
    }
    Op w7; w7.k = kChw; w7.dst = 7; w7.chw = 3; p.push_back(w7);
    for (unsigned i = 0; i != 40; ++i) {
      Op a; a.k = kLane; a.dst = 4 + r() % 6; a.nsrc = 1 + r() % 3;
      for (unsigned j = 0; j != a.nsrc; ++j) a.src[j] = 3 + r() % 6;
      p.push_back(a);
      if (i == 20) { Op b; b.k = kChw; b.dst = 5; b.chw = 0; b.chw_writes = true; b.src[0] = 5; b.nsrc = 1; p.push_back(b); }
    }
    Op ex; ex.k = kExit; p.push_back(ex);
    return p;
  };
  e.launch(0, 0, prog(1));
  e.launch(1, 1, prog(2));
  e.finish();
  EXPECT(e.core.slotWidth(0, 4) == 1 && e.core.slotWidth(0, 6) == 2 && e.core.slotWidth(0, 5) == 0,
         "widths R4 %u R5 %u R6 %u", e.core.slotWidth(0, 4), e.core.slotWidth(0, 5), e.core.slotWidth(0, 6));
}

/// AR-24 (d): each operand carries its own register's width, from the
/// committed table at rename, and a memop its data register's. Under the
/// interim full_rows (DA tab rev 87; OA's rev 225, AR's rev 174) the 8-bit
/// R2 takes a full row at position 0, yet its width code on the issue and
/// the store stays 8-bit; off, it takes an 8-bit slice.
void testWidthCodes() {
  for (const bool full : {false, true}) {
    g_test = full ? "width codes (full rows)" : "width codes";
    Config c = baseConfig();
    c.sectioned = true;
    c.full_rows = full;
    c.l1_spec = false;
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    Op w; w.k = kChw; w.dst = 2; w.chw = 2; p.push_back(w);
    Op a; a.k = kLane; a.dst = 2; a.w = 2; a.src[0] = 1; a.nsrc = 1; p.push_back(a);
    Op st; st.k = kStore; st.nsrc = 2; st.src[0] = 2; st.src[1] = 4; p.push_back(st);
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    e.finish();
    bool lane = false, store = false;
    for (const Outputs &o : e.log) {
      for (const Issue &i : o.issues)
        if (i.tid == 2) {
          lane = true;
          EXPECT(i.dst_w == 2 && i.src_w[0] == 0 && i.chwidth == 2, "lane op widths dst %u src %u op %u, want 2, 0, 2",
                 i.dst_w, i.src_w[0], i.chwidth);
          EXPECT(e.core.nameWidth(i.pdst) == (full ? 0u : 2u), "R2 allocated at width %u", e.core.nameWidth(i.pdst));
          if (full) EXPECT(e.core.namePos(i.pdst) == 0, "R2 at position %u under full rows", e.core.namePos(i.pdst));
        }
      for (const Memop &m : o.memops)
        if (m.tid == 3) {
          store = true;
          EXPECT(m.chwidth == 2, "the store's chwidth %u, want its data register's 2", m.chwidth);
        }
    }
    EXPECT(lane && store, "the lane op or the store never issued");
  }
}

/// F-WIDTH (ISA v1.9 section 12.3; OA's response OI-57): the committed
/// per-register width table is written when a chwidth retires, and a
/// memory access whose data register is then at 4 bits faults at dispatch,
/// cause 3, as a no-op. A load into R4 after chwidth R4, 4-bit faults; one
/// into R5 does not. The control drops the check.
void testWidthFault() {
  for (const bool control : {false, true}) {
    g_test = control ? "width fault (control)" : "width fault";
    Config c = baseConfig();
    c.l1_spec = false;
    c.inject_no_width_fault = control;
    for (const unsigned dst : {4u, 5u}) {
      Env e(c);
      e.keep_log = true;
      std::vector<Op> p;
      Op w; w.k = kChw; w.dst = 4; w.chw = 3; p.push_back(w);
      Op ld; ld.k = kLoad; ld.dst = dst; ld.nsrc = 1; ld.src[0] = 6; p.push_back(ld);
      Op ex; ex.k = kExit; p.push_back(ex);
      e.launch(0, 0, p);
      unsigned faults = 0, cause = 0;
      for (unsigned k = 0; k != 80; ++k) {
        e.step();
        for (const Fault &f : e.log.back().faults) { ++faults; cause = f.cause; }
      }
      const bool want = dst == 4 && !control;
      if (control && dst == 4) {
        std::printf("  %-24s %s\n", "control no-width-fault", faults == 0 ? "caught" : "MISSED");
        EXPECT(faults == 0, "dropping the check should let the load through");
        continue;
      }
      if (control) continue;
      EXPECT(e.core.slotWidth(0, 4) == 3, "the table holds %u for R4 after its chwidth", e.core.slotWidth(0, 4));
      EXPECT((faults == 1) == want, "R%u: %u faults", dst, faults);
      if (want) EXPECT(cause == kCauseWidth, "cause %u, want F-WIDTH (%u)", cause, kCauseWidth);
    }
  }
}

/// O-80 (DA tab rev 90): a sized load passes xfer_size to MIU, and one
/// wider than its data register's width faults at dispatch with F-WIDTH:
/// with R4 at 8 bits, a halfword load into R4 faults and a byte load does
/// not. O-81 (DA tab rev 91): a chwidth without FET's converged mark faults
/// with F-WIDTH, a no-op that sets no width. Controls no-sized-fault and
/// no-converged-fault drop the two checks.
void testSizedAndConverged() {
  for (const bool control : {false, true}) {
    for (const unsigned xfer : {2u, 1u}) {
      g_test = control ? "sized fault (control)" : "sized fault";
      Config c = baseConfig();
      c.l1_spec = false;
      c.inject_no_sized_fault = control;
      Env e(c);
      e.keep_log = true;
      std::vector<Op> p;
      Op w; w.k = kChw; w.dst = 4; w.chw = 2; p.push_back(w);
      Op ld; ld.k = kLoad; ld.dst = 4; ld.nsrc = 1; ld.src[0] = 6; ld.xfer = xfer; p.push_back(ld);
      Op ex; ex.k = kExit; p.push_back(ex);
      e.launch(0, 0, p);
      unsigned faults = 0, cause = 0, sized = 0;
      for (unsigned k = 0; k != 80; ++k) {
        e.step();
        for (const Fault &f : e.log.back().faults) { ++faults; cause = f.cause; }
        for (const Memop &m : e.log.back().memops) if (m.tid == 2) sized = m.xfer_size;
      }
      const bool want = xfer == 2 && !control;
      if (control) {
        if (xfer == 2) {
          std::printf("  %-24s %s\n", "control no-sized-fault", faults == 0 ? "caught" : "MISSED");
          EXPECT(faults == 0, "dropping the check should let the halfword load through");
        }
        continue;
      }
      EXPECT((faults == 1) == want, "xfer %u into an 8-bit R4: %u faults", xfer, faults);
      if (want) EXPECT(cause == kCauseWidth, "cause %u, want F-WIDTH (%u)", cause, kCauseWidth);
      else EXPECT(sized == xfer, "the memop carried xfer_size %u, want %u", sized, xfer);
    }
  }
  for (const bool control : {false, true}) {
    for (const bool diverged : {true, false}) {
      g_test = control ? "diverged chwidth (control)" : "diverged chwidth";
      Config c = baseConfig();
      c.l1_spec = false;
      c.inject_no_converged_fault = control;
      Env e(c);
      e.keep_log = true;
      std::vector<Op> p;
      Op w; w.k = kChw; w.dst = 4; w.chw = 2; w.diverged = diverged; p.push_back(w);
      Op ex; ex.k = kExit; p.push_back(ex);
      e.launch(0, 0, p);
      unsigned faults = 0, cause = 0;
      for (unsigned k = 0; k != 60; ++k) {
        e.step();
        for (const Fault &f : e.log.back().faults) { ++faults; cause = f.cause; }
      }
      const bool want = diverged && !control;
      if (control) {
        if (diverged) {
          std::printf("  %-24s %s\n", "control no-converged-fault", faults == 0 ? "caught" : "MISSED");
          EXPECT(faults == 0, "dropping the check should let the diverged chwidth through");
        }
        continue;
      }
      EXPECT((faults == 1) == want, "%s chwidth: %u faults", diverged ? "a diverged" : "a converged", faults);
      if (want) {
        EXPECT(cause == kCauseWidth, "cause %u, want F-WIDTH (%u)", cause, kCauseWidth);
        EXPECT(e.core.slotWidth(0, 4) == 0, "a faulting chwidth set R4's width to %u", e.core.slotWidth(0, 4));
      }
    }
  }
}

/// F-FORMAT (ISA v1.9 section 12.3; OA's response OI-57): an FP op whose
/// format code DEC marks reserved at its operand's committed width faults
/// at dispatch, cause 4. With R4 at 4 bits and src0 = R4, a format reserved
/// at 4 bits only (fmt_rsv bit 3) faults; one reserved at 32 bits only
/// (bit 0) does not. The control drops the check.
void testFormatFault() {
  for (const bool control : {false, true}) {
    g_test = control ? "format fault (control)" : "format fault";
    Config c = baseConfig();
    c.l1_spec = false;
    c.inject_no_format_fault = control;
    for (const unsigned rsv : {8u, 1u}) {
      Env e(c);
      e.keep_log = true;
      std::vector<Op> p;
      Op w; w.k = kChw; w.dst = 4; w.chw = 3; p.push_back(w);
      Op f; f.k = kFp; f.dst = 5; f.nsrc = 1; f.src[0] = 4; f.fmt_rsv = rsv; f.fmt_opnd = 0; p.push_back(f);
      Op ex; ex.k = kExit; p.push_back(ex);
      e.launch(0, 0, p);
      unsigned faults = 0, cause = 0;
      for (unsigned k = 0; k != 80; ++k) {
        e.step();
        for (const Fault &x : e.log.back().faults) { ++faults; cause = x.cause; }
      }
      if (control) {
        if (rsv == 8) {
          std::printf("  %-24s %s\n", "control no-format-fault", faults == 0 ? "caught" : "MISSED");
          EXPECT(faults == 0, "dropping the check should let the op through");
        }
        continue;
      }
      const bool want = rsv == 8;
      EXPECT((faults == 1) == want, "fmt_rsv %#x: %u faults", rsv, faults);
      if (want) EXPECT(cause == kCauseFormat, "cause %u, want F-FORMAT (%u)", cause, kCauseFormat);
    }
  }
}

/// Placement across and within a rename group (AR-15; OI-81 (ii), OA's rev
/// 252). Across groups a narrow op follows its source's position and a
/// merge keeps its old destination's; within a group a source or old
/// destination written earlier in it is not seen, so the op takes its
/// warp's home (8-bit: the slot index). Slot 1, so home is section 1 for
/// 8 bits and sections 2-3 for 16. The control, in-group-follows, runs the
/// old rule (cand_indep off), which follows inside the group too.
bool narrowPlacement(bool control = false) {
  Config c = baseConfig();
  c.sectioned = true;
  c.place = 0;
  c.l1_spec = false;
  c.cand_indep = !control;
  if (!control) g_test = "sections: placement within a rename group and across groups";
  bool ok = true;
  auto check = [&](bool cond, const std::string &what) {
    if (cond) return;
    ok = false;
    if (!control) EXPECT(false, "%s", what.c_str());
  };
  auto at = [](const char *where, unsigned long long tid, unsigned v, const char *what) {
    return std::string(where) + ": tid " + std::to_string(tid) + " " + what + " " + std::to_string(v);
  };
  // (1) In one group: tid 1 writes R4 at 16 bits (home, 2); tid 2 reads it
  // at 8 bits and tid 3 merges R5, both written in the group: home, 1.
  {
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    Op a; a.k = kLane; a.dst = 4; a.w = 1; p.push_back(a);
    Op b; b.k = kLane; b.dst = 5; b.w = 2; b.src[0] = 4; b.nsrc = 1; p.push_back(b);
    Op m; m.k = kLane; m.dst = 5; m.w = 2; m.mask = 0xffff; p.push_back(m);
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(5, 1, p);
    e.finish();
    unsigned seen = 0;
    for (const Outputs &o : e.log)
      for (const Issue &i : o.issues)
        if (i.port < 4 && !i.copy) {
          ++seen;
          const unsigned want = i.tid == 1 ? 2 : 1;
          check(e.core.namePos(i.pdst) == want, at("in one group", i.tid, e.core.namePos(i.pdst), "placed at"));
        }
    check(seen == 3, "in one group: " + std::to_string(seen) + " lane issues");
    check(e.errors.empty(), "in one group: " + (e.errors.empty() ? std::string() : e.errors[0]));
  }
  // (2) Across groups (three 32-bit ops between, so never in a group of
  // the width): tid 5 follows R4 to 2, and tid 9's merge of R5 keeps 2.
  {
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    auto fill = [&]() {
      for (unsigned r = 8; r != 11; ++r) { Op f; f.k = kLane; f.dst = r; f.w = 0; p.push_back(f); }
    };
    Op a; a.k = kLane; a.dst = 4; a.w = 1; p.push_back(a);
    fill();
    Op b; b.k = kLane; b.dst = 5; b.w = 2; b.src[0] = 4; b.nsrc = 1; p.push_back(b);
    fill();
    Op m; m.k = kLane; m.dst = 5; m.w = 2; m.mask = 0xffff; p.push_back(m);
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(5, 1, p);
    e.finish();
    unsigned seen = 0;
    for (const Outputs &o : e.log)
      for (const Issue &i : o.issues)
        if (i.port < 4 && !i.copy && (i.tid == 1 || i.tid == 5 || i.tid == 9)) {
          ++seen;
          check(e.core.namePos(i.pdst) == 2, at("across groups", i.tid, e.core.namePos(i.pdst), "placed at"));
          check(i.port == 2, at("across groups", i.tid, i.port, "issued on port"));
        }
    check(seen == 3, "across groups: " + std::to_string(seen) + " narrow lane issues");
    check(e.errors.empty(), "across groups: " + (e.errors.empty() ? std::string() : e.errors[0]));
  }
  return ok;
}

/// Sectioned lanes (OI-29 to OI-33): narrow registers placed in sections,
/// footprints widened per unit, and lane ops co-issued on disjoint sections.
void testSections() {
  auto cfgS = [](unsigned place) {
    Config c = baseConfig();
    c.sectioned = true;
    c.place = place;
    c.l1_spec = false;
    return c;
  };
  // Independent ops per warp, each writing its own register at width w.
  auto indep = [](Kind k, unsigned w, unsigned n) {
    std::vector<Op> p;
    for (unsigned i = 0; i != n; ++i) { Op o; o.k = k; o.dst = 4 + i; o.w = w; p.push_back(o); }
    Op ex; ex.k = kExit; p.push_back(ex);
    return p;
  };
  // The most lane ops issued in any one cycle.
  auto maxLane = [](const Env &e) {
    size_t m = 0;
    for (const Outputs &o : e.log) {
      size_t n = 0;
      for (const Issue &i : o.issues) n += i.port < 4;
      m = std::max(m, n);
    }
    return m;
  };
  auto run = [&](const Config &c, Kind k, unsigned w, std::vector<unsigned> slots) {
    Env e(c);
    e.keep_log = true;
    for (unsigned s : slots) e.launch(s * 5, s, indep(k, w, 8));
    e.finish();
    EXPECT(e.errors.empty(), "%s", e.errors.empty() ? "" : e.errors[0].c_str());
    return e;
  };

  g_test = "sections: 8-bit ops of four warps co-issue";
  {
    Env e = run(cfgS(0), kLane, 2, {0, 1, 2, 3});
    EXPECT(maxLane(e) == 4, "at most %zu lane ops in a cycle", maxLane(e));
    EXPECT(e.lane_ops_one_section == e.lane_ops, "%llu of %llu took one section",
           (unsigned long long)e.lane_ops_one_section, (unsigned long long)e.lane_ops);
    // Home = slot index: warp s's registers sit in section s.
    for (const Outputs &o : e.log)
      for (const Issue &i : o.issues)
        if (i.port < 4) EXPECT(e.core.namePos(i.pdst) == (i.warp / 5) % 4 && i.port == (i.warp / 5) % 4,
                               "warp %u wrote section %u from port %u", i.warp, e.core.namePos(i.pdst), i.port);
  }
  g_test = "sections: 32-bit ops take the whole lane";
  EXPECT(maxLane(run(cfgS(0), kLane, 0, {0, 1, 2, 3})) == 1, "two 32-bit ops in a cycle");
  g_test = "sections: home 0 puts every warp in section 0";
  EXPECT(maxLane(run(cfgS(1), kLane, 2, {0, 1, 2, 3})) == 1, "two ops shared section 0");
  g_test = "sections: 16-bit ops pair up";
  EXPECT(maxLane(run(cfgS(0), kLane, 1, {0, 1, 2, 3})) == 2, "16-bit ops not two a cycle");
  g_test = "sections: FP widens to its minimum";
  {
    // At an FP minimum of 2, ops in sections 0 and 1 widen to one pair and
    // cannot co-issue; in 0 and 2 they can. Set here, so the widening stays
    // tested whatever CCV_P_FOOT_MIN_FP holds.
    Config c = cfgS(0);
    c.foot_min[Config::kGrpFp] = 2;
    EXPECT(maxLane(run(c, kFp, 2, {0, 1})) == 1, "FP ops in sections 0 and 1 co-issued at a minimum of 2");
    EXPECT(maxLane(run(c, kFp, 2, {0, 2})) == 2, "FP ops in sections 0 and 2 did not co-issue at a minimum of 2");
    // The default is the parameter: 1 under DA's response IS-7, so 8-bit FP
    // of four warps co-issues four a cycle, as integer does.
    const size_t want = 4 / ccv::prov::kFootMinFp;
    const size_t got = maxLane(run(cfgS(0), kFp, 2, {0, 1, 2, 3}));
    EXPECT(got == want, "8-bit FP of four warps: %zu a cycle, want %zu at CCV_P_FOOT_MIN_FP %u", got, want,
           ccv::prov::kFootMinFp);
  }
  g_test = "sections: SFU takes the whole lane";
  EXPECT(maxLane(run(cfgS(0), kSfu, 2, {0, 2})) == 1, "two SFU ops in a cycle");

  narrowPlacement();

  g_test = "sections: narrow loads of two warps take their own MIU pipes";
  {
    Config c = cfgS(0);
    Env e(c);
    e.keep_log = true;
    for (unsigned s : {0u, 2u}) {
      std::vector<Op> p;
      for (unsigned i = 0; i != 6; ++i) { Op l; l.k = kLoad; l.dst = 4 + i; l.w = 2; l.nsrc = 1; p.push_back(l); }
      Op ex; ex.k = kExit; p.push_back(ex);
      e.launch(s * 5, s, p);
    }
    e.finish();
    size_t most = 0;
    for (const Outputs &o : e.log) {
      unsigned used = 0;
      for (const Memop &m : o.memops) {
        EXPECT(m.port == (m.warp / 5) % 4, "warp %u's load on pipe %u", m.warp, m.port);
        EXPECT(!(used >> m.port & 1u), "pipe %u granted twice", m.port);
        used |= 1u << m.port;
      }
      most = std::max(most, o.memops.size());
    }
    EXPECT(most == 2, "at most %zu loads in a cycle", most);
    EXPECT(e.errors.empty(), "%s", e.errors.empty() ? "" : e.errors[0].c_str());
  }

  g_test = "sections: a masked load's copy issues before its load (V-61)";
  {
    Config c = cfgS(0);
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    Op w; w.k = kLane; w.dst = 5; w.w = 2; p.push_back(w);                                  // tid 1
    Op ld; ld.k = kLoad; ld.dst = 5; ld.w = 2; ld.nsrc = 1; ld.mask = 0xffff; p.push_back(ld);  // tid 2
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    e.finish();
    uint64_t copy_at = ~0ull;
    for (size_t cyc = 0; cyc != e.log.size(); ++cyc)
      for (const Issue &i : e.log[cyc].issues) if (i.copy) copy_at = cyc;
    uint64_t load_at = ~0ull;
    for (size_t cyc = 0; cyc != e.log.size(); ++cyc)
      for (const Memop &m : e.log[cyc].memops) if (m.tid == 2) load_at = cyc;
    EXPECT(copy_at != ~0ull && load_at != ~0ull && copy_at < load_at, "copy at %llu, load at %llu",
           (unsigned long long)copy_at, (unsigned long long)load_at);
    EXPECT(e.errors.empty(), "%s", e.errors.empty() ? "" : e.errors[0].c_str());
  }

  g_test = "sections: a load passes an older waiting load only under OA-13";
  for (int pass = 0; pass != 2; ++pass) {
    Config c = cfgS(0);
    c.loads_pass_loads = pass;
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    Op f; f.k = kSfu; f.dst = 1; p.push_back(f);                                    // tid 1: a slow address
    Op a; a.k = kLoad; a.dst = 4; a.src[0] = 1; a.nsrc = 1; p.push_back(a);         // tid 2: waits on it
    Op b; b.k = kLoad; b.dst = 5; b.src[0] = 0; b.nsrc = 1; p.push_back(b);         // tid 3: ready
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    e.finish();
    uint64_t at[4] = {};
    for (size_t cyc = 0; cyc != e.log.size(); ++cyc)
      for (const Memop &m : e.log[cyc].memops) if (m.tid < 4) at[m.tid] = cyc;
    EXPECT(pass ? at[3] < at[2] : at[3] > at[2], "loads at %llu and %llu with loads_pass_loads=%d",
           (unsigned long long)at[2], (unsigned long long)at[3], pass);
    EXPECT(e.errors.empty(), "%s", e.errors.empty() ? "" : e.errors[0].c_str());
  }
}

/// A random test's core configuration, by seed and mode.
Config randomConfig(unsigned seed, int mode) {
  // Odd seeds run the bypass-group configuration, SFU ops included.
  const bool groups = seed % 2 == 1;
  Config c = groups ? groupConfig() : baseConfig();
  c.bypass = mode & 1;
  c.l1_spec = (mode & 2) != 0;
  // Modes 4-7: sectioned lanes and narrow registers, each placement
  // rule in turn, with loads passing loads on odd seeds (OA-13).
  const bool sec = (mode & 4) != 0;
  c.sectioned = sec;
  c.place = seed % 5;
  c.loads_pass_loads = sec && seed % 2 == 1;
  // Every fifth seed: a floorplan where load data lands after the
  // completion (the links split does this), and the core told so.
  if (seed % 5 == 0) c.cmpl_wake_delay = 2;
  // Every seventh seed from the third: a long L1 shadow, the completion
  // a lane latency past the wake, so grandchildren issue on a load that
  // then misses and transitive cancel takes more than one hop.
  if (seed % 7 == 3) c.lat_l1_cmpl = c.lat_l1_wake + c.lat_lane;
  if (g_random_config_hook) g_random_config_hook(c);
  return c;
}

void testRandom(unsigned seeds) {
  for (unsigned seed = 1; seed <= seeds; ++seed) {
    for (int mode = 0; mode != 8; ++mode) {
      g_test = "random seed " + std::to_string(seed) + " mode " + std::to_string(mode);
      if (const char *only = std::getenv("OOE_TEST_ONLY")) if (g_test != only) continue;
      const bool groups = seed % 2 == 1, sec = (mode & 4) != 0;
      const Config c = randomConfig(seed, mode);
      std::mt19937 rng(seed * 4 + unsigned(mode));
      Env e(c, seed * 7 + unsigned(mode));
      e.miss_pct = 30;
      e.data_after_cmpl = c.cmpl_wake_delay;
      e.rcu_fast = seed % 3 == 0;
      const unsigned warps = 1 + seed % 4;
      for (unsigned i = 0; i != warps; ++i) e.launch(i * 5, i, randomProgram(rng, 150, true, groups, sec));
      e.finish();
      const int before = g_fail;
      for (unsigned i = 0; i != warps; ++i) {
        Alloc f; f.warp = i * 5; f.slot = i; f.op = kAllocFree;
        e.core.alloc(f);
      }
      e.step();
      EXPECT(e.core.freeGprs() == c.phys_regs, "%zu of %u GPRs free at the end", e.core.freeGprs(), c.phys_regs);
      EXPECT(e.core.freePreds() == c.pred_regs, "%zu of %u predicates free", e.core.freePreds(), c.pred_regs);
      if (g_fail != before) return;
    }
  }
}

void testFixedWindowPreds() {
  // The S1 mode: predicates at fixed windows, ordered by OOE itself.
  for (unsigned seed = 1; seed <= 20; ++seed) {
    g_test = "fixed-window seed " + std::to_string(seed);
    Config c = baseConfig();
    c.rename_preds = false;
    c.l1_spec = false;
    c.bypass = false;
    c.memop_rcu_done = true;
    std::mt19937 rng(seed);
    Env e(c, seed);
    e.launch(0, 0, randomProgram(rng, 120, false));
    // Readability of a window predicate: track it per window register; the
    // generic dataflow check covers RAW, and the WAR/WAW hold is what keeps
    // a younger write from landing first (checked by the late-write rule on
    // GPRs; for predicates by the core's own ordering).
    e.finish();
  }
}

/// The harness's own negative controls: each injected bug must fail it.
// ---- atomics: read, lane op, write (AR-21) -------------------------------------------

/// Issue cycles of tid's steps, in order: 'r' A1, 'o' A2, 'w' A3, from the
/// memops (A1, A3) and the lane issues (A2).
std::string atomSteps(const Env &e, uint64_t tid) {
  std::string out;
  for (const Outputs &o : e.log) {
    for (const Issue &i : o.issues)
      if (i.tid == tid && !i.copy && i.res == Issue::kLaneOp) out += 'o';
    for (const Memop &m : o.memops)
      if (m.tid == tid) out += m.mem_op == kMemOpAtomicRead ? 'r' : m.mem_op == kMemOpAtomicWrite ? 'w' : '?';
  }
  return out;
}

/// An atomic's three steps, pass by pass, at its warp's head (V-69); its
/// consumers once, after the last pass (V-71); younger memops behind it,
/// younger lane ops around it; red, a masked atom with its copy, and a
/// guarded one, in each select form.
void testAtomic() {
  struct M { const char *name; void (*set)(Config &); };
  const M ms[] = {
      {"base", [](Config &) {}},
      {"no-bypass", [](Config &c) { c.bypass = false; }},
      {"l1-spec", [](Config &c) { c.l1_spec = true; }},
      {"sectioned", [](Config &c) { c.sectioned = true; }},
      {"cmpl-delay", [](Config &c) { c.cmpl_wake_delay = 2; }},
  };
  for (const M &m : ms)
    for (unsigned variant = 0; variant != 6; ++variant) {
      g_test = std::string("atomic ") + m.name + " " + std::to_string(variant);
      Config c = baseConfig();
      m.set(c);
      Env e(c, 3 + variant);
      e.keep_log = true;
      e.data_after_cmpl = c.cmpl_wake_delay;
      std::vector<Op> p;
      for (unsigned i = 0; i != 4; ++i) { Op o; o.k = kRcuOp; o.dst = i; p.push_back(o); }
      { Op o; o.k = kSetp; o.pdst = 1; o.src[0] = 0; o.src[1] = 1; o.nsrc = 2; p.push_back(o); }
      // An older load that misses holds the head: the read waits for it.
      Op ld; ld.k = kLoad; ld.dst = 6; ld.src[0] = 0; ld.nsrc = 1; p.push_back(ld);
      Op at;
      at.k = kAtomic;
      at.dst = 3;
      at.src[0] = 1;                                           // rbase
      at.src[1] = 2;                                           // rindex
      at.src[2] = 0;                                           // rs
      at.nsrc = 3;
      at.passes = 3;
      at.red = variant == 1;
      if (variant == 2) at.mask = 0x0000ffffu;              // masked: the copy keeps T's other lanes
      if (variant == 3) { at.guard = true; at.pguard = 1; }   // guarded: the copy too
      if (variant >= 4) {
        // A CAS (TI-39): rbase and rindex in the first slot; rs_cmp and
        // rs_swap in the second, which reaches DEC a cycle late in 5.
        at.cas = true;
        at.nsrc = 2;
        at.csrc[0] = 0;
        at.csrc[1] = 2;
        at.ncsrc = 2;
        at.late2 = variant == 5;
      }
      const size_t at_idx = p.size();
      p.push_back(at);
      Op yl; yl.k = kLane; yl.dst = 8; yl.src[0] = 2; yl.nsrc = 1; p.push_back(yl);     // around it
      Op ym; ym.k = kLoad; ym.dst = 9; ym.src[0] = 0; ym.nsrc = 1; p.push_back(ym);     // behind it
      Op cons; cons.k = kLane; cons.dst = 10; cons.src[0] = at.red ? 2 : 3; cons.nsrc = 1; p.push_back(cons);
      Op ex; ex.k = kExit; p.push_back(ex);
      e.launch(0, 0, p);
      e.finish();
      uint64_t at_tid = 0, yl_tid = 0, ym_tid = 0, ld_tid = 0;
      for (const auto &kv : e.idx_of) {
        if (kv.second == at_idx) at_tid = kv.first;
        if (kv.second == at_idx + 1) yl_tid = kv.first;
        if (kv.second == at_idx + 2) ym_tid = kv.first;
        if (kv.second == at_idx - 1) ld_tid = kv.first;
      }
      const std::string st = atomSteps(e, at_tid);
      EXPECT(st == "rowrowrow", "steps %s, want three passes of read, op, write", st.c_str());
      // The read waits for the older load to retire; younger lane work does not wait.
      uint64_t first_read = ~0ull, last_write = 0, ym_at = ~0ull;
      for (size_t cy = 0; cy != e.log.size(); ++cy)
        for (const Memop &mo : e.log[cy].memops) {
          if (mo.tid == at_tid && mo.mem_op == kMemOpAtomicRead) first_read = std::min<uint64_t>(first_read, cy);
          if (mo.tid == at_tid && mo.mem_op == kMemOpAtomicWrite) last_write = cy;
          if (mo.tid == ym_tid) ym_at = std::min<uint64_t>(ym_at, cy);
        }
      EXPECT(issueCycle(e, ld_tid) < first_read, "the read went before the older load");
      EXPECT(issueCycle(e, yl_tid) < last_write, "a younger lane op waited for the atomic (%llu, %llu)",
             (unsigned long long)issueCycle(e, yl_tid), (unsigned long long)last_write);
      EXPECT(ym_at > last_write, "a younger memop at %llu, before the atomic's last write at %llu",
             (unsigned long long)ym_at, (unsigned long long)last_write);
      unsigned copies = 0;
      for (const Outputs &o : e.log) for (const Issue &i : o.issues) copies += i.tid == at_tid && i.copy;
      EXPECT(copies == (variant == 2 || variant == 3 ? 1u : 0u), "%u copies", copies);
      EXPECT(e.core.histograms["atomic.passes"][3] == 1, "the passes histogram");
      EXPECT(e.core.counters["rename.cas_pair"] == 1u, "%llu atomic pairs renamed",
             (unsigned long long)e.core.counters["rename.cas_pair"]);
      EXPECT(e.core.freeGprs() + e.core.heldGprs(0) == c.phys_regs, "registers lost");
    }
}

/// A fault at the first read: no hold, no lane op, no write; the entry
/// faults at the head with MIU's cause, and a kill cleans up (V-72).
void testAtomicFault() {
  g_test = "atomic fault";
  Config c = baseConfig();
  Env e(c);
  e.keep_log = true;
  std::vector<Op> p;
  for (unsigned i = 0; i != 3; ++i) { Op o; o.k = kRcuOp; o.dst = i; p.push_back(o); }
  Op at; at.k = kAtomic; at.dst = 3; at.src[0] = 1; at.src[1] = 2; at.src[2] = 0; at.nsrc = 3; at.passes = 4; at.afault = true;
  p.push_back(at);
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  std::vector<Fault> faults;
  for (unsigned k = 0; k != 150; ++k) {
    e.step();
    for (const Fault &f : e.log.back().faults) faults.push_back(f);
  }
  uint64_t tid = 0;
  for (const auto &kv : e.idx_of) if (kv.second == 3) tid = kv.first;
  EXPECT(atomSteps(e, tid) == "r", "steps %s, want the read alone", atomSteps(e, tid).c_str());
  EXPECT(faults.size() == 1 && faults[0].cause == 6 && faults[0].address == 0xA70, "%zu fault records", faults.size());
  e.core.kill(1u, 1);
  for (unsigned k = 0; k != 40; ++k) e.step();
  Alloc f; f.warp = 0; f.slot = 0; f.op = kAllocFree;
  e.core.alloc(f);
  e.step();
  EXPECT(e.core.freeGprs() == c.phys_regs, "%zu of %u GPRs free", e.core.freeGprs(), c.phys_regs);
  for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
}

/// A kill mid-atomic: the pass in flight writes and releases, no later pass
/// starts, and the kill is acknowledged only after that write's completion
/// (V-70).
void testAtomicKill() {
  g_test = "atomic kill";
  Config c = baseConfig();
  Env e(c);
  e.keep_log = true;
  std::vector<Op> p;
  for (unsigned i = 0; i != 3; ++i) { Op o; o.k = kRcuOp; o.dst = i; p.push_back(o); }
  Op at; at.k = kAtomic; at.dst = 3; at.src[0] = 1; at.src[1] = 2; at.src[2] = 0; at.nsrc = 3; at.passes = 6;
  p.push_back(at);
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  uint64_t tid = 0;
  unsigned reads = 0;
  for (unsigned k = 0; k != 600 && reads < 2; ++k) {
    e.step();
    for (const Memop &m : e.log.back().memops) reads += m.mem_op == kMemOpAtomicRead;
  }
  for (const auto &kv : e.idx_of) if (kv.second == 3) tid = kv.first;
  EXPECT(reads == 2, "the second pass never read");
  e.core.kill(1u, 5);
  uint64_t ack = 0, last_cmpl = 0;
  for (unsigned k = 0; k != 300; ++k) {
    for (const auto &cm : e.cmpls) last_cmpl = std::max(last_cmpl, cm.first);
    e.step();
    for (unsigned a : e.log.back().kill_acks) if (a == 5 && !ack) ack = e.t - 1;
  }
  EXPECT(atomSteps(e, tid) == "rowrow", "steps %s, want the second pass finished and no third",
         atomSteps(e, tid).c_str());
  EXPECT(ack && ack >= last_cmpl, "kill acked at %llu, the write completed at %llu", (unsigned long long)ack,
         (unsigned long long)last_cmpl);
  EXPECT(!e.atom[tid].hold, "the kill left the lines held");
  EXPECT(e.core.freeGprs() == c.phys_regs, "%zu of %u GPRs free", e.core.freeGprs(), c.phys_regs);
  for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
}

/// No demotion mid-atomic (V-70): no trigger while it is at the head in
/// progress, and a demote that arrives then waits for its last pass, so
/// none of its passes is applied twice when the warp resumes. With the
/// control the demote is taken at once.
void testAtomicDemote() {
  for (const bool control : {false, true}) {
    g_test = control ? "atomic demote (control)" : "atomic demote";
    Config c = baseConfig();
    c.inject_atom_demote_mid = control;
    c.demote_mlc_miss = 5;
    c.demote_fallback = 30;
    Env e(c);
    e.keep_log = true;
    e.miss_extra = 40;
    e.atom_mlc_pct = 100;           // every read misses the MLC: triggers due
    std::vector<Op> p;
    for (unsigned i = 0; i != 3; ++i) { Op o; o.k = kRcuOp; o.dst = i; p.push_back(o); }
    Op at; at.k = kAtomic; at.dst = 3; at.src[0] = 1; at.src[1] = 2; at.src[2] = 0; at.nsrc = 3; at.passes = 5;
    p.push_back(at);
    for (unsigned i = 0; i != 4; ++i) { Op o; o.k = kLane; o.dst = 4; o.src[0] = 3; o.nsrc = 1; p.push_back(o); }
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(0, 0, p);
    uint64_t tid = 0;
    unsigned triggers = 0, reads = 0;
    bool demoted = false, drained = false;
    const int before = g_fail;
    g_quiet = control;
    for (unsigned k = 0; k != 1500 && !drained; ++k) {
      e.step();
      const Outputs &o = e.log.back();
      for (const Status &st : o.status) triggers += st.stalled;
      for (const Memop &m : o.memops) reads += m.mem_op == kMemOpAtomicRead;
      if (reads == 2 && !demoted) {
        e.core.demote(0);
        demoted = true;
      }
      drained = drained || !o.drained.empty();
    }
    for (const auto &kv : e.idx_of) if (kv.second == 3) tid = kv.first;
    const Env::Atom &a = e.atom[tid];
    EXPECT(drained, "the warp never drained");
    // Every pass applied, once: the atomic finished before the warp left.
    EXPECT(a.final && a.passes == 5 && !a.hold, "the warp left mid-atomic: %u of 5 passes, %s", a.passes,
           a.hold ? "lines held" : "nothing held");
    EXPECT(!control || e.core.counters["demote.held_atomic"] == 0, "control: the demote was held");
    if (!control) {
      EXPECT(e.core.counters["demote.held_atomic"] > 0, "the demote was not held");
      EXPECT(e.core.counters["demote_trigger.held_atomic"] > 0, "no trigger was held");
      for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
    }
    g_quiet = false;
    if (control) {
      const bool caught = g_fail != before || !e.errors.empty();
      g_fail = before;
      g_test = "atomic demote (control)";
      std::printf("  %-24s %s\n", "control atom-demote-mid", caught ? "caught" : "MISSED");
      EXPECT(caught, "a demote mid-atomic should leave it partly applied (V-70)");
    }
  }
}

/// Random programs with atomics, several warps, every select form: the
/// environment's dataflow, retirement, hold and head checks on every run.
/// Not in the benches' random set: no OOE RTL re-issues on more yet.
void testAtomicRandom(unsigned seeds, Config (*base)(unsigned, int), int control = 0, bool one_warp = false) {
  std::map<std::string, uint64_t> tot;
  std::map<std::string, std::map<uint64_t, uint64_t>> hist;
  struct Report {
    std::map<std::string, uint64_t> &tot;
    std::map<std::string, std::map<uint64_t, uint64_t>> &hist;
    bool on;
    ~Report() {
      if (!on || !tot["atomic"]) return;
      auto mean = [&](const char *k) {
        uint64_t n = 0, sum = 0;
        for (const auto &b : hist[k]) { n += b.second; sum += b.first * b.second; }
        return n ? double(sum) / double(n) : 0.0;
      };
      std::printf("  atomic random: %llu atomics, %.2f passes each, hold %.1f cycles a pass, head wait %.1f,"
                  " %llu cycles of held demote triggers, %llu rename port stalls; %llu CAS pairs, %llu"
                  " takes cut before a pair the width would split, %llu waits past the warp's heads; %llu cycles\n",
                  (unsigned long long)tot["atomic"], mean("atomic.passes"), mean("atomic.hold_cycles"),
                  mean("atomic.head_wait"), (unsigned long long)tot["demote_trigger.held_atomic"],
                  (unsigned long long)tot["stall.rename_ports"], (unsigned long long)tot["rename.cas_pair"],
                  (unsigned long long)tot["rename.pair_cut"], (unsigned long long)tot["rename.pair_window"],
                  (unsigned long long)tot["cycles"]);
    }
  } report{tot, hist, control == 0};
  for (unsigned seed = 1; seed <= seeds; ++seed)
    for (int mode = 0; mode != 8; ++mode) {
      g_test = "atomic random seed " + std::to_string(seed) + " mode " + std::to_string(mode);
      Config c = base(seed, mode);
      c.inject_atom_off_head = control == 1;
      c.inject_atom_early_wake = control == 2;
      c.inject_a1_base_only = control == 3;
      c.inject_cas_split = control == 4;
      c.inject_pair_split = control == 5;
      std::mt19937 rng(seed * 13 + unsigned(mode));
      Env e(c, seed * 11 + unsigned(mode));
      e.miss_pct = 30;
      e.data_after_cmpl = c.cmpl_wake_delay;
      e.atom_mlc_pct = 20;
      const unsigned warps = one_warp ? 1 : 1 + seed % 4;
      for (unsigned i = 0; i != warps; ++i) {
        std::vector<Op> prog = randomProgram(rng, 120, true, seed % 2 == 1, (mode & 4) != 0);
        // About one op in twelve an atomic, each 1 to 4 passes, now and then 32.
        for (size_t k = 5; k + 1 < prog.size(); ++k)
          if (rng() % 12 == 0) {
            Op a;
            a.k = kAtomic;
            a.dst = rng() % 16;
            a.src[0] = rng() % 16;
            a.src[1] = rng() % 16;
            a.src[2] = rng() % 16;
            a.nsrc = 1 + rng() % 3;
            a.red = rng() % 4 == 0;
            // One in four a CAS (TI-39): two slots, the second now and then late.
            // CCV_TEST_CAS_ALL (a measurement's): every atomic a CAS.
            static const bool cas_all = std::getenv("CCV_TEST_CAS_ALL") != nullptr;
            if (rng() % 4 == 0 || cas_all) {
              a.cas = true;
              a.red = false;
              a.nsrc = 1 + rng() % 2;
              a.csrc[0] = rng() % 16;
              a.csrc[1] = rng() % 16;
              a.ncsrc = 2;
              a.late2 = rng() % 3 == 0;
            }
            a.passes = rng() % 16 == 0 ? 32 : 1 + rng() % 4;
            if (rng() % 6 == 0) a.mask = 0x0000ffffu;
            else if (rng() % 6 == 0) { a.guard = true; a.pguard = rng() % 4; }
            prog[k] = a;
          }
        e.launch(i * 5, i, prog);
      }
      const int before = g_fail;
      if (control) g_quiet = true;
      e.finish(control ? 30000 : 200000);
      g_quiet = false;
      tot["cycles"] += e.t;
      for (const char *k : {"atomic", "demote_trigger.held_atomic", "stall.rename_ports", "rename.cas_pair",
                            "rename.pair_cut", "rename.pair_window"})
        tot[k] += e.core.counters[k];
      for (const char *k : {"atomic.passes", "atomic.hold_cycles", "atomic.head_wait"})
        for (const auto &b : e.core.histograms[k]) hist[k][b.first] += b.second;
      if (control) {
        if (g_fail != before) return;   // caught: the caller reports
        continue;
      }
      for (unsigned i = 0; i != warps; ++i) {
        Alloc f; f.warp = i * 5; f.slot = i; f.op = kAllocFree;
        e.core.alloc(f);
      }
      e.step();
      EXPECT(e.core.freeGprs() == c.phys_regs, "%zu of %u GPRs free at the end", e.core.freeGprs(), c.phys_regs);
      if (g_fail != before) return;
    }
}

void testControls() {
  struct C { const char *name; void (*set)(Config &); };
  const C cs[] = {
      {"free-new", [](Config &c) { c.inject_free_new = true; }},
      {"shallow-cancel", [](Config &c) { c.inject_shallow_cancel = true; }},
      {"early-wake", [](Config &c) { c.inject_early_wake = true; }},
      {"cmpl-wake-delay-ignored", [](Config &c) { c.cmpl_wake_delay = 0; c.inject_free_new = false; }},
      {"bypass-faster-than-contract", [](Config &c) { c = groupConfig(); c.l1_spec = true; c.lat_l1_cmpl = c.lat_l1_wake + c.lat_lane; c.fast[4] = 3; }},
      {"complete-before-rs-free", [](Config &c) { c.inject_complete_early = true; }},
      {"narrow-footprint", [](Config &c) { c.sectioned = true; c.inject_narrow_footprint = true; }},
      {"no-alloc-lead", [](Config &c) { c.inject_no_alloc_lead = true; }},   // V-73
  };
  for (const C &x : cs) {
    const int saved = g_fail;
    const std::string name = std::string("control ") + x.name;
    unsigned caught = 0;
    for (unsigned seed = 1; seed <= 10 && !caught; ++seed) {
      g_test = name;
      Config c = baseConfig();
      c.l1_spec = true;
      c.lat_l1_cmpl = c.lat_l1_wake + c.lat_lane;   // a shadow long enough for grandchildren
      x.set(c);
      std::mt19937 rng(seed);
      Env e(c, seed);
      e.miss_pct = 50;
      // The last control: data lands two cycles after its completion, and
      // the core is not told.
      if (std::string(x.name) == "cmpl-wake-delay-ignored") e.data_after_cmpl = 2;
      // The core bypasses SFU at 3 (SFU -> ALU at 6); the contract says 6 (9).
      const bool groups = std::string(x.name) == "bypass-faster-than-contract";
      if (groups) e.cfg.fast[4] = 6;
      // An RCU faster than its contract is what exposes completing early.
      if (std::string(x.name) == "complete-before-rs-free") e.rcu_fast = true;
      // A footprint narrower than the operands: four warps of narrow
      // registers, so two lane ops land in one cycle on a shared section.
      if (c.inject_narrow_footprint)
        for (unsigned i = 0; i != 4; ++i) e.launch(i * 5, i, randomProgram(rng, 150, true, false, true));
      else
        e.launch(0, 0, randomProgram(rng, 150, true, groups));
      const int before = g_fail;
      g_quiet = true;
      e.finish(20000);
      g_quiet = false;
      caught += g_fail != before;
    }
    g_fail = saved;
    g_test = name;
    EXPECT(caught, "the harness missed it");
    std::printf("  %-24s %s\n", name.c_str(), caught ? "caught" : "MISSED");
  }
}

// ---- TI-21: a stalled warp, the swap, and the hole it leaves ------------------------

/// stall_hole's warp 0 (OA's rev 129): a load that misses to DRAM, then 64
/// uops each depending on it directly or through the chain, at the usual
/// mix; fetching (f) keeps going with dependent work, so its heads never
/// run out; held (h) ends there.
std::vector<Op> stallProgram(std::mt19937 &rng, bool fetching, unsigned fill) {
  auto r = [&](unsigned k) { return unsigned(rng() % k); };
  std::vector<Op> p;
  for (unsigned i = 0; i != 4; ++i) { Op o; o.k = kRcuOp; o.dst = i; p.push_back(o); }
  Op ld;
  ld.k = kLoad;
  ld.dst = 4;
  ld.src[0] = 0;
  ld.nsrc = 1;
  ld.dram = true;
  ld.fill = fill;
  p.push_back(ld);
  unsigned prev = 4;
  const unsigned n = fetching ? 64 + 600 : 64;
  for (unsigned i = 0; i != n; ++i) {
    Op o;
    const unsigned c = r(100);
    o.k = c < 55 ? kLane : c < 70 ? kRcuOp : c < 88 ? kLoad : kStore;
    const unsigned dep = r(3) == 0 ? 4 : prev;
    o.src[0] = dep;
    o.src[1] = r(4);
    o.nsrc = o.k == kLoad ? 1 : 2;
    if (o.k == kStore) { o.src[0] = dep; o.src[1] = r(4); }
    o.dst = 5 + i % 10;
    if (o.k != kStore) prev = o.dst;
    p.push_back(o);
  }
  Op e;
  e.k = kExit;
  p.push_back(e);
  return p;
}

/// One stall_hole run. arm 0: swap off (no demotion), warp 0's fill 400
/// (OA's rev 129); 1: swap, no parked warp ready (the stress); 2: swap, one
/// parked warp ready from cycle 0; 3: evict, none ready. Arms 1-3 miss to
/// DRAM (700 to 1,300); 4: the reference for arm 2, the parked warp's
/// program live in slot 0 from cycle 0 and no stall, which prices a fourth
/// live warp. solo: warps 1-3 alone.
struct HoleRun {
  uint64_t cycles = 0;          ///< until warps 1-3 have all exited
  bool starved = false;         ///< 800 cycles in which warps 1-3 retired nothing
  unsigned peak[2] = {0, 0};    ///< warp 0's RS entries over its stall, RCU and MIU
  double mean[2] = {0, 0};
  bool gap = false;             ///< arm 2: the slot's gap was measured
  uint64_t empty = 0, T = 0, D = 0, R = 0;
  unsigned swaps = 0;
  uint64_t reads_charged = 0;
};
HoleRun runHole(const Config &c, unsigned seed, bool fetching, int arm, bool solo) {
  Env e(c, seed);
  e.miss_pct = 20;
  std::mt19937 rng(seed), rng0(seed * 977 + 1);
  if (arm && arm != 4) {
    e.swap.rau = true;
    e.swap.mode = arm == 3 ? 2 : 1;
  }
  std::vector<Op> progs[3];
  for (auto &q : progs) q = randomProgram(rng, 300, true);
  if (!solo && arm == 4) {
    // The reference: the program a ready parked warp would run, live in
    // slot 0 from cycle 0, and no stall.
    (void)stallProgram(rng0, fetching, 0);
    e.launch(20, 0, randomProgram(rng0, 300, true));
  } else if (!solo) {
    e.launch(0, 0, stallProgram(rng0, fetching, arm == 0 ? 400 : 0));
  }
  for (unsigned i = 0; i != 3; ++i) e.launch(5 * (i + 1), i + 1, progs[i]);
  if (!solo && arm == 2) e.park(20, randomProgram(rng0, 300, true));   // warp ids are 0-31 (CCV_WARP_CONTEXTS)
  HoleRun h;
  uint64_t last = 0, samples = 0;
  size_t before = 0;
  auto retired13 = [&] {
    size_t n = 0;
    for (const auto &x : e.w) if (x.id && x.id <= 15) n += x.retired.size();
    return n;
  };
  auto done13 = [&] {
    for (const auto &x : e.w) if (x.id && x.id <= 15 && !x.exited) return false;
    return true;
  };
  while (!e.done() && e.t < 60000) {
    e.step();
    const size_t n = retired13();
    if (n != before) { before = n; last = e.t; }
    if (!done13() && e.t - last > 800) h.starved = true;
    // Warp 0's RS room while its fill is out and it holds slot 0.
    const Env::Warp *w0 = solo ? nullptr : e.warpOf(0);
    if (w0 && !w0->parked && !w0->exited && w0->slot == 0 && w0->fill_at && e.t < w0->fill_at) {
      for (unsigned k = 0; k != 2; ++k) {
        const unsigned v = e.core.rsHeldIn(0, k == 1);
        h.peak[k] = std::max(h.peak[k], v);
        h.mean[k] += v;
      }
      ++samples;
    }
    if (done13() && !h.cycles) {
      for (const auto &x : e.w) if (x.id && x.id <= 15) h.cycles = std::max(h.cycles, x.exit_at);
    }
  }
  for (unsigned k = 0; k != 2; ++k) h.mean[k] = samples ? h.mean[k] / double(samples) : 0;
  e.finish(60000);
  for (const Env::Gap &g : e.gaps)
    if (g.warp == 0 && g.rename) {
      h.gap = true;
      h.empty = g.rename - g.head;
      h.T = c.demote_mlc_miss;
      h.D = g.drained - g.demote;
      h.R = g.rename - g.activate;
      break;
    }
  h.swaps = e.swaps;
  return h;
}

/// stall_hole (OA's revs 129-133), every arm, under each go form: warps 1-3
/// against solo, warp 0's RS room over its stall, starvation, and (arm 2)
/// the slot's gap against T + D + 56 + R. Returns the failures of the
/// bounds: 10% held, 15% fetching, no starvation, and the gap.
int stallHole(unsigned seeds, bool print, int only_fix = -1) {
  struct Form { const char *name; unsigned one; };
  const Form forms[] = {{"interleave, shares", 0}, {"one warp", 1}, {"two warps", 2}};
  const char *arms[] = {"swap off (fill 400)", "swap, none ready", "swap, one ready", "evict, none ready",
                        "reference: four live warps"};
  int fails = 0;
  if (print)
    std::printf("| fix | go | arm | variant | warps 1-3 vs solo | worst seed | starved | warp 0 RS peak RCU/MIU | mean RCU/MIU |"
                " gap: empty, bound (T + D + 56 + R) | swaps |\n|---|---|---|---|---|---|---|---|---|---|---|\n");
  const char *fixes[] = {"none", "stall-aware shares", "per-class caps 20 / 10", "decq per warp 6", "decq per warp 4",
                         "decq per warp 6, stall-aware shares"};
  constexpr int kFixes = 6;
  auto applyFix = [](Config &c, int fix) {
    c.share_stall_aware = fix == 1 || fix == 5;
    if (fix == 2) { c.rs_warp_cap_rcu = 20; c.rs_warp_cap_miu = 10; }
    if (fix == 3 || fix == 5) c.decq_warp_max = 6;
    if (fix == 4) c.decq_warp_max = 4;
  };
  // Each fix's cost on the even-stall sweep (OA's rev 130): four warps of
  // the sweep's programs, against no fix, under the decided go.
  if (print) {
    auto sweepRun = [&](const Config &c) {
      uint64_t total = 0;
      for (unsigned seed = 1; seed <= seeds; ++seed) {
        std::mt19937 rng(seed);
        Env e(c, seed);
        e.miss_pct = 20;
        for (unsigned i = 0; i != 4; ++i) e.launch(i, i, randomProgram(rng, 300, true));
        e.finish();
        total += e.t;
      }
      return double(total) / seeds;
    };
    Config b = baseConfig();
    b.decq = 13;
    const double ref = sweepRun(b);
    std::printf("| fix | even-stall sweep, cycles | vs no fix |\n|---|---|---|\n");
    for (int fix = 0; fix != kFixes; ++fix) {
      Config c = b;
      applyFix(c, fix);
      const double cy = sweepRun(c);
      std::printf("| %s | %.0f | %.3f |\n", fixes[fix], cy, cy / ref);
    }
    std::printf("\n");
  }
  for (int fix = 0; fix != kFixes; ++fix)
  for (const Form &f : forms)
    for (int arm = 0; arm != 5; ++arm)
      for (bool fetching : {false, true}) {
        if (only_fix >= 0 && fix != only_fix) continue;
        Config c = baseConfig();
        c.decq = 13;
        c.rename_one_warp = f.one;
        applyFix(c, fix);
        double sum = 0, worst = 0;
        unsigned starved = 0, pk[2] = {0, 0}, swaps = 0;
        double mn[2] = {0, 0};
        uint64_t worst_gap = 0, gap_bound = 0, gaps = 0, gap_over = 0, Rmax = 0;
        for (unsigned seed = 1; seed <= seeds; ++seed) {
          const HoleRun solo = runHole(c, seed, fetching, arm, true);
          const HoleRun h = runHole(c, seed, fetching, arm, false);
          const double r = double(h.cycles) / double(solo.cycles);
          sum += r;
          worst = std::max(worst, r);
          starved += h.starved;
          for (unsigned k = 0; k != 2; ++k) { pk[k] = std::max(pk[k], h.peak[k]); mn[k] += h.mean[k]; }
          swaps += h.swaps;
          if (h.gap) {
            ++gaps;
            const uint64_t bound = h.T + h.D + 56 + h.R;
            if (h.empty > bound + 2) ++gap_over;
            if (h.empty > worst_gap) { worst_gap = h.empty; gap_bound = bound; }
            Rmax = std::max(Rmax, h.R);
          }
        }
        const double mean = sum / seeds;
        const double lim = fetching ? 1.15 : 1.10;
        // The bounds (OA's revs 129, 131): arms 0, 1 and 2 hold them; evict
        // is reported beside them.
        const bool bound_arm = arm < 3;
        const bool miss = bound_arm && (mean > lim || starved || (arm == 2 && (gap_over || gaps != seeds)));
        if (miss && f.one == 0 && fix == 0) ++fails;   // the decided go: a bench failure
        if (print)
          std::printf("| %s | %s | %s | %s | %.3f%s | %.3f | %u | %u / %u | %.1f / %.1f | %s | %u |\n", fixes[fix], f.name,
                      arms[arm], fetching ? "fetching" : "held", mean, miss ? " (over)" : "", worst, starved, pk[0], pk[1],
                      mn[0] / seeds, mn[1] / seeds,
                      arm == 2 ? (std::to_string(worst_gap) + ", " + std::to_string(gap_bound) + " (R " +
                                  std::to_string(Rmax) + ", " + std::to_string(gaps) + " of " + std::to_string(seeds) +
                                  " seeds" + (gap_over ? ", " + std::to_string(gap_over) + " over" : "") + ")")
                                     .c_str()
                               : "-",
                      swaps);
      }
  return fails;
}

/// TI-21's workload (1): 8 warps, 4 resident and 4 parked, each a sweep
/// program, 2% of loads missing to DRAM. Swap against swap-off (the parked
/// warps enter as residents exit), per go form, with the swap count, the
/// slots' gaps, and the PRF ports' charge; and the threshold and P swept.
void swapSweep(unsigned seeds) {
  struct R { double cycles = 0, gap = 0, gap_dr = 0; unsigned swaps = 0, gaps = 0, declined = 0, prov = 0, merged = 0, pre = 0; uint64_t wc = 0, prf = 0; };
  auto run = [&](Config c, unsigned mode, unsigned P, bool charge, bool prov = false, bool preempt = false) {
    R r;
    for (unsigned seed = 1; seed <= seeds; ++seed) {
      std::mt19937 rng(seed);
      Env e(c, seed);
      e.miss_pct = 20;
      e.swap.rau = true;
      e.swap.mode = mode;
      e.swap.P = P;
      e.swap.dram_pm = 20;
      e.swap.charge_ports = charge;
      e.swap.provisional = prov;
      e.swap.preempt = preempt;
      for (unsigned i = 0; i != 4; ++i) e.launch(i, i, randomProgram(rng, 300, true));
      for (unsigned i = 4; i != 8; ++i) e.park(i, randomProgram(rng, 300, true));
      e.finish(200000);
      r.cycles += double(e.t);
      r.swaps += e.swaps;
      r.declined += e.declined;
      r.prov += e.provisional;
      r.merged += e.merged_fills;
      r.pre += e.preempted;
      r.wc += e.write_conflicts;
      r.prf += e.core.counters["select.prf_read_ports"];
      for (const Env::Gap &g : e.gaps)
        if (g.rename) { r.gap += double(g.rename - g.head); r.gap_dr += double(g.rename - g.drained); ++r.gaps; }
    }
    r.cycles /= seeds;
    if (r.gaps) { r.gap /= r.gaps; r.gap_dr /= r.gaps; }
    return r;
  };
  Config base = baseConfig();
  base.decq = 13;
  std::printf("| go | policy | threshold | P | ports charged | cycles | vs swap off | restores | demotes declined | "
              "gap from the miss at the head | from drained | reads held back | write-port short cycles |\n"
              "|---|---|---|---|---|---|---|---|---|---|---|---|---|\n");
  for (unsigned one : {0u, 1u, 2u}) {
    Config c = base;
    c.rename_one_warp = one;
    const char *go = one == 0 ? "interleave, shares" : one == 1 ? "one warp" : "two warps";
    const R off = run(c, 0, 8, true);
    auto line = [&](const char *pol, unsigned thr, unsigned P, bool charge, const R &r) {
      std::printf("| %s | %s | %u | %u | %s | %.0f | %.3f | %u | %u | %.0f | %.0f | %llu | %llu |\n", go, pol, thr, P,
                  charge ? "yes" : "no", r.cycles, r.cycles / off.cycles, r.swaps, r.declined, r.gap, r.gap_dr,
                  (unsigned long long)r.prf, (unsigned long long)r.wc);
    };
    line("swap off", c.demote_mlc_miss, 8, true, off);
    // Evict, the policy (DA), across the threshold; then AR's revs 115-117
    // under it: a free slot with no ready warp restores a not-ready one,
    // provisionally, and (PF-41) a ready warp pre-empts it.
    for (unsigned thr : {25u, 50u, 100u, 150u, 200u, 300u}) {
      Config t = c;
      t.demote_mlc_miss = thr;
      line("evict", thr, 8, true, run(t, Env::kEvict, 8, true));
    }
    for (const bool pre : {false, true}) {
      const R r = run(c, Env::kEvict, 8, true, true, pre);
      line((std::string(pre ? "evict, provisional, pre-empting" : "evict, provisional") + " (" +
            std::to_string(r.prov) + " provisional, " + std::to_string(r.merged) + " replays merged" +
            (pre ? ", " + std::to_string(r.pre) + " pre-empted" : std::string()) + ")")
               .c_str(),
           c.demote_mlc_miss, 8, true, r);
    }
    if (one == 0) {
      for (unsigned P : {1u, 32u}) line("evict", c.demote_mlc_miss, P, true, run(c, Env::kEvict, P, true));
      line("evict", c.demote_mlc_miss, 8, false, run(c, Env::kEvict, 8, false));
    }
    // Swap, the knob.
    line("swap", c.demote_mlc_miss, 8, true, run(c, Env::kSwap, 8, true));
    if (one == 0) {
      const R r = run(c, Env::kSwap, 8, true, true);
      line(("swap, provisional (" + std::to_string(r.prov) + " provisional, " + std::to_string(r.merged) +
            " replays merged)").c_str(), c.demote_mlc_miss, 8, true, r);
    }
  }
}

/// The swap knob's own bench (OA's rev 131), on the 8-warp workload: the
/// environment checks that a demote's squash frees exactly the warp's RS
/// entries and leaves its committed registers, that the first rewind beat is
/// the oldest unretired uop and drained names it, and that no slot runs two
/// warps; every warp retires its whole program, through swaps.
void testSwap() {
  // The policy, evict (DA), under every go form; swap, the knob, beside it.
  uint64_t abandoned = 0;
  for (unsigned mode : {Env::kEvict, Env::kSwap})
    for (unsigned one : {0u, 1u, 2u})
      for (unsigned seed = 1; seed <= 6; ++seed) {
        if (mode == Env::kSwap && one != 0) continue;
        g_test = std::string(mode == Env::kEvict ? "evict" : "swap") + " go " + std::to_string(one) + " seed " +
                 std::to_string(seed);
        Config c = baseConfig();
        c.decq = 13;
        c.rename_one_warp = one;
        std::mt19937 rng(seed);
        Env e(c, seed);
        e.miss_pct = 20;
        e.swap.rau = true;
        e.swap.mode = mode;
        e.swap.dram_pm = 40;
        e.replay_spread = 60;
        for (unsigned i = 0; i != 4; ++i) e.launch(i, i, randomProgram(rng, 200, true));
        for (unsigned i = 4; i != 8; ++i) e.park(i, randomProgram(rng, 200, true));
        e.finish(200000);
        EXPECT(e.swaps > 0, "no swap");
        unsigned demotes = 0;
        for (const Env::Gap &g : e.gaps) demotes += g.drained != 0;
        EXPECT(demotes > 0, "no demotion");
        abandoned += e.abandoned;
      }
  // PF-23: the demotions abandoned loads, each answered with replay.
  EXPECT(abandoned > 0, "no demotion abandoned a load (PF-23)");
  // AR's revs 115-117, under evict: provisional restores, their replays
  // merged into the fills still in flight, and (PF-41) a provisional warp
  // pre-empted when a ready one appears; every warp still retires its
  // whole program. A pre-emption is rare here, a few in a run at most, and
  // which seeds reach one moves with the timing (the decode queue's
  // per-warp limit, TI's rev 106), so the check sums twelve seeds: 3
  // pre-emptions at a limit of 6, 5 at 13.
  for (const bool preempt : {false, true}) {
    unsigned prov = 0, merged = 0, pre = 0;
    for (unsigned seed = 1; seed <= 12; ++seed) {
      g_test = std::string(preempt ? "evict, pre-empt" : "evict, provisional") + ", seed " + std::to_string(seed);
      Config c = baseConfig();
      c.decq = 13;
      std::mt19937 rng(seed);
      Env e(c, seed);
      e.miss_pct = 20;
      e.swap.rau = true;
      e.swap.dram_pm = 40;
      e.swap.provisional = true;
      e.swap.preempt = preempt;
      e.replay_spread = 60;
      for (unsigned i = 0; i != 4; ++i) e.launch(i, i, randomProgram(rng, 200, true));
      for (unsigned i = 4; i != 8; ++i) e.park(i, randomProgram(rng, 200, true));
      e.finish(200000);
      prov += e.provisional;
      merged += e.merged_fills;
      pre += e.preempted;
    }
    g_test = preempt ? "evict, pre-empt, seeds 1 to 12" : "evict, provisional, seeds 1 to 12";
    EXPECT(prov > 0 && merged > 0, "%u provisional restores, %u replays merged", prov, merged);
    if (preempt) EXPECT(pre > 0, "no provisional warp pre-empted (PF-41)");
  }
  // The control: beats youngest first, so FET resumes past the oldest
  // unretired uop of the lanes that have two beats.
  unsigned caught = 0;
  const int before = g_fail;
  for (unsigned seed = 1; seed <= 6 && !caught; ++seed) {
    g_test = "swap (control)";
    Config c = baseConfig();
    c.decq = 13;
    c.inject_rewind_order = true;
    std::mt19937 rng(seed);
    Env e(c, seed);
    e.miss_pct = 20;
    e.swap.rau = true;
    e.swap.dram_pm = 40;
    for (unsigned i = 0; i != 4; ++i) e.launch(i, i, randomProgram(rng, 200, true));
    for (unsigned i = 4; i != 8; ++i) e.park(i, randomProgram(rng, 200, true));
    g_quiet = true;
    e.finish(200000);
    g_quiet = false;
    caught += g_fail != before;
    g_fail = before;
  }
  std::printf("  %-24s %s\n", "control rewind-order", caught ? "caught" : "MISSED");
  EXPECT(caught, "beats youngest first should break the rewind check");
  // PF-23's control: drained waits for no abandoned load's replay, so it
  // leaves a completion owed to a slot that is freed.
  caught = 0;
  for (unsigned seed = 1; seed <= 6 && !caught; ++seed) {
    g_test = "swap (control drain-early)";
    Config c = baseConfig();
    c.decq = 13;
    c.inject_drain_early = true;
    std::mt19937 rng(seed);
    Env e(c, seed);
    e.miss_pct = 20;
    e.swap.rau = true;
    e.swap.dram_pm = 40;
    e.replay_spread = 60;
    for (unsigned i = 0; i != 4; ++i) e.launch(i, i, randomProgram(rng, 200, true));
    for (unsigned i = 4; i != 8; ++i) e.park(i, randomProgram(rng, 200, true));
    g_quiet = true;
    e.finish(200000);
    g_quiet = false;
    caught += g_fail != before;
    g_fail = before;
  }
  std::printf("  %-24s %s\n", "control drain-early", caught ? "caught" : "MISSED");
  EXPECT(caught, "a drain that waits for no replay should break the PF-23 check");
}

/// Sizing sweep on synthetic four-warp traces, in the design's own modes
/// (bypass and L1 speculation on): cycles per knob value, the mean over
/// several seeds, normalised to the default. The S1 kernels are one warp and
/// short, so they cannot show a knee; this can, until the corpus runs.
void sweep() {
  struct K { const char *name; std::vector<unsigned> vals; unsigned Config::*f; };
  const std::vector<K> ks = {
      {"rs_rcu", {6, 10, 15, 20, 30, 45}, &Config::rs_rcu},
      {"rs_miu", {3, 5, 8, 15, 24}, &Config::rs_miu},
      {"rs_warp_cap", {6, 10, 15, 0}, &Config::rs_warp_cap},
      {"rob_depth", {8, 12, 16, 24, 32}, &Config::rob_depth},
      {"decq", {4, 6, 8, 12, 18}, &Config::decq},
      {"fl_buf", {0, 4, 8, 16}, &Config::fl_buf},
      {"rename_width", {1, 2, 3, 4}, &Config::rename_width},
      {"retire_per_rob", {1, 2, 4}, &Config::retire_per_rob},
      {"rename_one_warp", {0, 1, 2}, &Config::rename_one_warp},
  };
  auto run = [](const Config &c, unsigned seeds = 6) {
    uint64_t total = 0;
    for (unsigned seed = 1; seed <= seeds; ++seed) {
      std::mt19937 rng(seed);
      Env e(c, seed);
      e.miss_pct = 20;
      for (unsigned i = 0; i != 4; ++i) e.launch(i, i, randomProgram(rng, 300, true));
      e.finish();
      total += e.t;
    }
    return double(total) / seeds;
  };
  Config base = baseConfig();
  // No per-warp limits unless swept: the parameters' "no limit" values
  // equal today's sizes, and would limit a larger one.
  base.rs_warp_cap = base.decq_warp_max = 0;
  const double ref = run(base);
  std::printf("| knob | value | cycles | vs default |\n|---|---|---|---|\n");
  std::printf("| (default) | | %.0f | 1.000 |\n", ref);
  for (const K &k : ks)
    for (unsigned v : k.vals) {
      Config c = base;
      c.*(k.f) = v;
      if (!c.check().empty()) continue;
      const double cy = run(c);
      std::printf("| %s | %u | %.0f | %.3f |\n", k.name, v, cy, cy / ref);
    }
  // The decode queue with same-edge reuse, as before DA's response OI-39.
  for (unsigned v : {6u, 8u, 12u}) {
    Config c = base;
    c.decq = v;
    c.decq_late_credit = false;
    const double cy = run(c);
    std::printf("| decq, decq_late_credit=0 | %u | %.0f | %.3f |\n", v, cy, cy / ref);
  }
  // OA-21 (a): rename's take registered in decq and popped an edge late,
  // its entries holding their credits a cycle more, under each go: the
  // interleave (0), one warp and two warps a cycle. 48 seeds against the
  // default (interleave, the take popped at its own edge).
  // The reference: the interleave with an on-time take and exact credits.
  Config ontime = base;
  ontime.decq_take_late = false;
  ontime.fits_conservative = 0;
  {
    const double r48 = run(ontime, 48);
    for (unsigned w : {0u, 1u, 2u})
      for (unsigned late : {0u, 1u, 2u}) {
        // 2: the take late, the queue an entry larger, against its credit.
        Config c = ontime;
        c.rename_one_warp = w;
        c.decq_take_late = late != 0;
        c.decq += late == 2;
        const double cy = run(c, 48);
        std::printf("| rename_one_warp, decq_take_late (48 seeds, on time %.0f) | %u, %u%s | %.0f | %.3f |\n", r48, w,
                    unsigned(late != 0), late == 2 ? ", decq +1" : "", cy, cy / r48);
      }
  }
  // OA-21 (2): the go's fits against shared credits, exact (the model's
  // running credits) or conservative (less the rename width, for a go that
  // lets several warps take), under each go, the take late, decq 12 and 13.
  {
    const double r48 = run(ontime, 48);
    for (unsigned w : {1u, 2u, 0u})
      for (unsigned dq : {base.decq, base.decq + 1})
        for (unsigned cons : {0u, 1u, 2u, 3u}) {
          if (cons && w == 1) continue;   // one warp's fits are its own
          Config c = ontime;
          c.rename_one_warp = w;
          c.decq_take_late = true;
          c.decq = dq;
          c.fits_conservative = cons;
          const double cy = run(c, 48);
          std::printf("| go, decq, fits (48 seeds, take late, on time %.0f) | %s, %u, %s | %.0f | %.3f |\n", r48,
                      w == 0 ? "interleave" : w == 1 ? "one warp" : "two warps", dq,
                      (const char *[]){"exact", "less the width", "one warp when short", "registered go"}[cons],
                      cy, cy / r48);
        }
  }
  // OI-65 (a): the per-warp fits registered a cycle ahead (fits_stale):
  // a uop taken no sooner than the second cycle after it arrives, frees two
  // cycles late. 48 seeds against the default, under each go.
  {
    const double r48 = run(base, 48);
    for (unsigned w : {0u, 1u, 2u})
      for (unsigned st : {0u, 1u, 2u, 3u, 4u, 5u, 6u, 7u}) {
        Config c = base;
        c.rename_one_warp = w;
        c.fits_stale = st;
        const double cy = run(c, 48);
        std::printf("| rename_one_warp, fits_stale (48 seeds, default %.0f) | %u, %u | %.0f | %.3f |\n", r48, w,
                    unsigned(st), cy, cy / r48);
      }
  }
  // When rename sees this cycle's RS and ROB frees (ren_credit), against
  // the design's TI-19 at cap 4: the same-edge ideal, every free a cycle
  // late (OA's item 4, not accepted) and the 2-step trim. Their differences
  // are a few percent, under six seeds' noise, so these run 48 against
  // their own reference.
  const double ref48 = run(base, 48);
  struct RC { unsigned credit, cap; const char *name; };
  for (const RC &k : {RC{0, 4, "same edge"}, RC{1, 4, "all late"}, RC{2, 2, "TI-19, cap 2"}}) {
    Config c = base;
    c.ren_credit = k.credit;
    c.ren_free_cap = k.cap;
    const double cy = run(c, 48);
    std::printf("| ren_credit (48 seeds, TI-19 cap 4 %.0f) | %s | %.0f | %.3f |\n", ref48, k.name, cy, cy / ref48);
  }
  // Select on the lines as they stand, against the registered ready
  // (OA's response OI-51), 48 seeds: the stale grants it adds, and the
  // replays they cost, apart from the miss replays.
  {
    struct R { double cy = 0, stale = 0, rstale = 0, rmiss = 0; };
    auto runc = [](const Config &c, unsigned seeds) {
      R r;
      for (unsigned seed = 1; seed <= seeds; ++seed) {
        std::mt19937 rng(seed);
        Env e(c, seed);
        e.miss_pct = 20;
        for (unsigned i = 0; i != 4; ++i) e.launch(i, i, randomProgram(rng, 300, true));
        e.finish();
        r.cy += double(e.t) / seeds;
        r.stale += double(e.core.counters["select.stale_grant"]) / seeds;
        r.rstale += double(e.core.counters["cancel.replay_stale"]) / seeds;
        r.rmiss += double(e.core.counters["cancel.replay"]) / seeds;
      }
      return r;
    };
    for (bool on : {true, false}) {
      Config c = base;
      c.ready_reg = on;
      const R r = runc(c, 48);
      std::printf("| ready_reg (48 seeds; stale grants / their replays / miss replays per run) | %d | %.0f | %.3f | %.1f / %.1f / %.1f |\n",
                  int(on), r.cy, r.cy / ref48, r.stale, r.rstale, r.rmiss);
    }
  }
}


/// The settings audit (OA's rev 122; docs/ooe-model.md, "What the RTL
/// reads"): the sweep's workload, 48 seeds, under the go DA decided
/// (OA-21: the interleave with per-cycle shares, fits_stale 6), counting
/// every admission the RTL's registered fits could not make the same way:
/// a uop taken in the cycle after it arrives (the refill, which the fits
/// do not hold), a take past the slot's registered ROB room and this
/// cycle's retirements, and every refusal on live state behind the
/// allowances (RS room, the free lists, the floors and ceilings, the warp
/// cap). Then the go with each such admission removed, in cycles.
void audit() {
  struct R { double cy = 0; std::map<std::string, double> n; };
  const char *keys[] = {"rename.refill", "rename.refill_fail", "rename.too_young", "audit.rob_past_registered", "audit.rob_refused_within_registered", "audit.rob_refused.full", "audit.rob_refused.tail_valid",
                        "audit.rob_refused.late_credit", "audit.rob_refused.squash_cycle",
                        "stall.share.rs", "stall.share.names", "stall.share_frag",
                        "stall.rs_full.rcu", "stall.rs_full.miu", "stall.rs_warp_cap",
                        "stall.gpr_buffer", "stall.gpr_empty", "stall.gpr_ceiling", "stall.gpr_floor",
                        "stall.pred_buffer", "stall.pred_empty", "stall.pred_floor_ceiling",
                        "stall.rob_full", "stall.rob_slot_held", "stall.rob_late_credit",
                        "hold.chwidth", "hold.barrier", "hold.fault", "hold.inactive", "rename.full_width"};
  auto run = [&](const Config &c) {
    R r;
    const char *as = std::getenv("AUDIT_SEEDS");   // the audit's runs (48 by default)
    const unsigned seeds = as ? unsigned(std::atoi(as)) : 48;
    for (unsigned seed = 1; seed <= seeds; ++seed) {
      std::mt19937 rng(seed);
      Env e(c, seed);
      e.miss_pct = 20;
      for (unsigned i = 0; i != 4; ++i) e.launch(i, i, randomProgram(rng, 300, true));
      e.finish();
      r.cy += double(e.t) / seeds;
      for (const char *k : keys) r.n[k] += double(e.core.counters[k]) / seeds;
    }
    return r;
  };
  Config base = baseConfig();
  base.fits_stale = 6;
  if (const char *ac = std::getenv("AUDIT_CFG")) {   // a setting the audit runs under, as CCV_OOE_CONFIG (e.g. scarce names)
    const std::string e = base.apply(ac);
    if (!e.empty()) { std::fprintf(stderr, "%s\n", e.c_str()); return; }
  }
  const R d = run(base);
  std::printf("audit: the decided go (fits_stale 6), 48 seeds: %.0f cycles\n", d.cy);
  {
    // OI-74 (iii), OI-75 (b) and OI-76, OA's revs 216 and 219: rename's held
    // and name counts see frees three edges late, the pool's floors are owed
    // from held before last cycle's takes, and the names' pool is formed
    // from last cycle's held. Against all of it exact.
    Config c = base;
    c.held_late = 0;
    c.owed_lag = false;
    c.names_pool_lag = false;
    const R x = run(c);
    std::printf("audit: frees seen at once, the pool exact (held_late 0, owed_lag 0, names_pool_lag 0): %.1f cycles (%+.2f%%)\n",
                x.cy, 100.0 * (x.cy / d.cy - 1));
  }
  {
    // OI-76: the names' pool from last cycle's held (names_pool_lag), against
    // OA's rev 216's form.
    Config c = base;
    c.names_pool_lag = false;
    const R x = run(c);
    std::printf("audit: the names' pool from this cycle's held (names_pool_lag 0): %.1f cycles (%+.2f%%)\n", x.cy,
                100.0 * (x.cy / d.cy - 1));
  }
  {
    // OA's rev 216's lateness, before the free list's second stage.
    Config c = base;
    c.held_late = 2;
    const R x = run(c);
    std::printf("audit: frees two edges late (held_late 2): %.1f cycles (%+.2f%%)\n", x.cy, 100.0 * (x.cy / d.cy - 1));
  }
  for (const char *k : keys) std::printf("audit:   %-28s %10.1f per run\n", k, d.n.at(k));
  Config ny = base;
  ny.take_young = false;
  const R y = run(ny);
  std::printf("audit: no refill (take_young 0): %.0f cycles, %+.1f%%\n", y.cy, 100.0 * (y.cy / d.cy - 1));
  Config rn = base;
  rn.ret_now = true;
  const R t = run(rn);
  std::printf("audit: retirements in their cycle (ret_now 1): %.0f cycles, %+.1f%%; refused within registered %.1f\n",
              t.cy, 100.0 * (t.cy / d.cy - 1), t.n.at("audit.rob_refused_within_registered"));
  rn.take_young = false;
  const R b = run(rn);
  std::printf("audit: both (ret_now 1, take_young 0): %.0f cycles, %+.1f%%\n", b.cy, 100.0 * (b.cy / d.cy - 1));
  // OA's response OI-45: the RTL's wake-to-select loop as composed. A
  // completion's wake a cycle later (cmpl_wake_delay + 1), and the matrix
  // and valid reaching select two cycles later (rename_stages + 2), each
  // and both, under the go slice 4 builds (ret_now 1, take_young 0).
  {
    Config g = base;
    g.ret_now = true;
    g.take_young = false;
    const R r0 = run(g);
    Config a1 = g;
    a1.cmpl_wake_delay += 1;
    const R x1 = run(a1);
    Config a2 = g;
    a2.rename_stages += 2;
    const R x2 = run(a2);
    Config a3 = a1;
    a3.rename_stages += 2;
    const R x3 = run(a3);
    std::printf("audit: loop, against the slice-4 go (%.0f): completion wake +1 %.0f (%+.1f%%), rename_stages +2 %.0f "
                "(%+.1f%%), both %.0f (%+.1f%%)\n", r0.cy, x1.cy, 100.0 * (x1.cy / r0.cy - 1), x2.cy,
                100.0 * (x2.cy / r0.cy - 1), x3.cy, 100.0 * (x3.cy / r0.cy - 1));
    Config b1 = g;
    b1.rename_stages += 1;
    const R y1 = run(b1);
    b1.cmpl_wake_delay += 1;
    const R y2 = run(b1);
    std::printf("audit: loop: rename_stages +1 %.0f (%+.1f%%), with the completion wake +1 %.0f (%+.1f%%)\n", y1.cy,
                100.0 * (y1.cy / r0.cy - 1), y2.cy, 100.0 * (y2.cy / r0.cy - 1));
    Config c1 = g;
    c1.copy_conf_late = true;
    const R z1 = run(c1);
    std::printf("audit: loop: a copy's request a cycle after its sources confirm %.0f (%+.2f%%)\n", z1.cy,
                100.0 * (z1.cy / r0.cy - 1));
  }
  // OI-45's assembled check: the composed RTL's timing, which trio_tb
  // holds the RTL to, on the sectioned select the RTL builds, against the
  // same go with the model's own timing. Each knob alone, then all.
  {
    Config g = base;
    g.ret_now = true;
    g.take_young = false;
    g.sectioned = true;
    const R s0 = run(g);
    std::printf("audit: composed timing, against the sectioned slice-4 go (%.0f):", s0.cy);
    struct K { const char *name; bool Config::*knob; };
    const K ks[] = {{"rs_same_edge 0", nullptr}, {"copy_conf_late", &Config::copy_conf_late},
                    {"req_alloc_lead", &Config::req_alloc_lead}, {"req_rows_late", &Config::req_rows_late},
                    {"miss_lead", &Config::miss_lead}, {"ready_rep_late", &Config::ready_rep_late}};
    Config all = g;
    for (const K &k : ks) {
      Config c = g;
      if (k.knob) c.*k.knob = true; else c.rs_same_edge = false;
      if (k.knob) all.*k.knob = true; else all.rs_same_edge = false;
      const R x = run(c);
      std::printf(" %s %.0f (%+.2f%%),", k.name, x.cy, 100.0 * (x.cy / s0.cy - 1));
    }
    const R xa = run(all);
    std::printf(" all %.0f (%+.2f%%)\n", xa.cy, 100.0 * (xa.cy / s0.cy - 1));
  }
}

/// OI-34: placement and OA-13 arms on synthetic narrow loops, one warp and
/// four. Each kernel is a loop body repeated with a backward taken branch:
///   vaddN: ld a, ld b (N-bit), add, st;
///   redN: ld x, acc += x (loop-carried, N-bit), and the final store;
///   cvt8: ld x (8-bit), x + x (8-bit), a convert to FP32, an FP op, st;
///   aluN: eight N-bit accumulators, initialised, one op each per
///   iteration, each reading a shared narrow operand R12 (lane-bound; alu32
///   is the full-width reference); aluN-self the same with no shared
///   operand (acc = acc op acc), the ceiling for a lone warp;
///   fpN-self: the same in N-bit FP (E4M3 at 8 bits, IS-7), where the
///   unit minimum, not placement, sets the footprint.
/// The loop control (an RCU index add, a 32-bit setp, the branch) is in
/// every body, as compiled code carries it.
void sweepSections() {
  enum KK { kVadd, kRed, kCvt, kAlu, kAluSelf };
  auto body = [](KK kk, unsigned w, unsigned iters, Kind op = kLane) {
    std::vector<Op> p;
    for (unsigned i = 0; i != 4; ++i) { Op o; o.k = kRcuOp; o.dst = i; p.push_back(o); }
    // aluN: the narrow operand R12 and eight accumulators, each initialised.
    for (unsigned r = 4; r != 13 && (kk == kAlu || kk == kAluSelf); ++r) { Op o; o.k = kLane; o.dst = r; o.w = w; p.push_back(o); }
    for (unsigned it = 0; it != iters; ++it) {
      if (kk == kAlu || kk == kAluSelf) {
        // Eight independent accumulators, one op each per iteration.
        for (unsigned j = 0; j != 8; ++j) {
          Op a; a.k = op; a.dst = 4 + j; a.w = w; a.src[0] = 4 + j; a.src[1] = kk == kAlu ? 12 : 4 + j; a.nsrc = 2; p.push_back(a);
        }
      } else {
        Op x; x.k = kLoad; x.dst = 4; x.w = w; x.src[0] = 0; x.nsrc = 1; p.push_back(x);
      }
      if (kk == kAlu || kk == kAluSelf) {
      } else if (kk == kVadd) {
        Op y; y.k = kLoad; y.dst = 5; y.w = w; y.src[0] = 0; y.nsrc = 1; p.push_back(y);
        Op a; a.k = kLane; a.dst = 6; a.w = w; a.src[0] = 4; a.src[1] = 5; a.nsrc = 2; p.push_back(a);
        Op s; s.k = kStore; s.src[0] = 6; s.src[1] = 0; s.nsrc = 2; p.push_back(s);
      } else if (kk == kRed) {
        Op a; a.k = kLane; a.dst = 7; a.w = w; a.src[0] = 7; a.src[1] = 4; a.nsrc = 2; p.push_back(a);
      } else {
        Op a; a.k = kLane; a.dst = 5; a.w = w; a.src[0] = 4; a.src[1] = 4; a.nsrc = 2; p.push_back(a);
        Op c; c.k = kFp; c.dst = 8; c.src[0] = 5; c.nsrc = 1; p.push_back(c);            // cvt to FP32
        Op f; f.k = kFp; f.dst = 9; f.src[0] = 8; f.src[1] = 8; f.nsrc = 2; p.push_back(f);
        Op s; s.k = kStore; s.src[0] = 9; s.src[1] = 0; s.nsrc = 2; p.push_back(s);
      }
      Op r; r.k = kRcuOp; r.dst = 0; r.src[0] = 0; r.nsrc = 1; p.push_back(r);           // index += stride
      Op t; t.k = kSetp; t.pdst = 1; t.src[0] = 0; t.src[1] = 1; t.nsrc = 2; p.push_back(t);
      const bool more = it + 1 != iters;
      Op b; b.k = kBranch; b.pguard = 1; b.taken = b.pred_taken = more; b.backward = true; p.push_back(b);
    }
    if (kk == kRed) { Op s; s.k = kStore; s.src[0] = 7; s.src[1] = 0; s.nsrc = 2; p.push_back(s); }
    Op e; e.k = kExit; p.push_back(e);
    return p;
  };
  struct Kern { const char *name; KK kk; unsigned w; Kind op = kLane; };
  const Kern ks[] = {{"alu8", kAlu, 2}, {"alu16", kAlu, 1}, {"alu32", kAlu, 0}, {"alu8-self", kAluSelf, 2},
                     {"alu32-self", kAluSelf, 0}, {"vadd8", kVadd, 2},
                     {"vadd16", kVadd, 1}, {"red8", kRed, 2}, {"cvt8", kCvt, 2},
                     {"fp8-self", kAluSelf, 2, kFp}, {"fp32-self", kAluSelf, 0, kFp}};
  const char *pn[] = {"slot", "0", "rotate-0", "rotate-slot", "slot+reg"};
  // Footprint and operand spread per bypass group (AR's response OI-34):
  // integer at the kernel's width, FP over every width (cvt writes 32 bits).
  // AR-16: under the decided default (place 0, home = slot index) one
  // warp's narrow ops share a section, so its rows are 1.0x by design.
  std::printf("One-warp rows at place=slot are 1.0x by design (AR-16): narrow rates are aggregate across warps.\n\n");
  std::printf("| kernel | warps | place | OA-13 | cycles | vs slot | element ops/cycle | outside setp cycles | int foot / spread | FP foot / spread | idle sections/cycle | lost resource | rows in use |\n"
              "|---|---|---|---|---|---|---|---|---|---|---|---|---|\n");
  for (const Kern &k : ks)
    for (unsigned warps : {1u, 4u}) {
      double ref = 0;
      for (unsigned place = 0; place != 5; ++place)
        for (int oa13 = 0; oa13 != 2; ++oa13) {
          if (k.kk != kVadd && oa13) continue;   // at most one load per body: OA-13 moves nothing
          if (k.w == 0 && place) continue;        // 32-bit: no placement
          Config c = baseConfig();
          c.sectioned = true;
          c.place = place;
          c.loads_pass_loads = oa13;
          uint64_t cyc = 0, cycles_seen = 0, idle = 0, lost = 0, narrow = 0, full = 0, rows_n = 0, rows_sum = 0;
          // [int, FP] x [footprint, spread]: op count and section sum.
          uint64_t n[2][2] = {}, sum[2][2] = {};
          const unsigned seeds = 4;
          for (unsigned seed = 1; seed <= seeds; ++seed) {
            Env e(c, seed);
            e.miss_pct = 10;
            for (unsigned i = 0; i != warps; ++i) e.launch(i * 5, i, body(k.kk, k.w, 32, k.op));
            e.finish();
            EXPECT(e.errors.empty(), "%s", e.errors.empty() ? "" : e.errors[0].c_str());
            cyc += e.t;
            for (auto &kv : e.core.histograms) {
              const std::string &name = kv.first;
              const bool foot = name.rfind("foot.", 0) == 0, spread = name.rfind("spread.", 0) == 0;
              if (!foot && !spread) continue;
              const std::string gw = name.substr(foot ? 5 : 7);
              int g = -1;
              if (gw == "g0.w" + std::to_string(k.w)) g = 0;
              else if (gw.rfind("g1.", 0) == 0) g = 1;
              if (g < 0) continue;
              for (auto &h : kv.second) { n[g][spread] += h.second; sum[g][spread] += h.first * h.second; }
            }
            for (auto &h : e.core.histograms["sections_idle"]) { cycles_seen += h.second; idle += h.first * h.second; }
            for (auto &h : e.core.histograms["rows_in_use"]) { rows_n += h.second; rows_sum += h.first * h.second; }
            lost += e.core.counters["select.lost_resource"];
            narrow += e.core.counters["select.lane_elem"];
            full += e.core.counters["select.lane_ctl_cycles"];
          }
          const double cy = double(cyc) / seeds;
          if (place == 0 && !oa13) ref = cy;
          auto mean = [&](int g, int sp) { return n[g][sp] ? double(sum[g][sp]) / double(n[g][sp]) : 0.0; };
          char fp[32] = "-";
          if (n[1][0]) std::snprintf(fp, sizeof fp, "%.2f / %.2f", mean(1, 0), mean(1, 1));
          std::printf("| %s | %u | %s | %s | %.0f | %.3f | %.2f | %.2f | %.2f / %.2f | %s | %.2f | %.0f | %.1f |\n", k.name, warps,
                      pn[place], oa13 ? "on" : "off", cy, cy / ref, double(narrow) / double(cyc),
                      cyc > full ? double(narrow) / double(cyc - full) : 0.0, mean(0, 0), mean(0, 1), fp,
                      cycles_seen ? double(idle) / cycles_seen : 0.0, double(lost) / seeds,
                      rows_n ? double(rows_sum) / double(rows_n) : 0.0);
        }
    }
}

} // namespace

#ifdef OOE_TEST_AS_LIBRARY
/// The random tests with a hook on every core cycle: what an RTL testbench
/// runs. Returns the failure count.
int ooeTestRandomHooked(unsigned seeds, void (*hook)(const Core &)) {
  g_cycle_hook = hook;
  testRandom(seeds);
  g_cycle_hook = nullptr;
  return g_fail;
}
/// The same, every core configured first by cfg (a setting the RTL under
/// test assumes, set over each test's own).
int ooeTestRandomHookedWith(unsigned seeds, void (*hook)(const Core &), void (*cfg)(Config &)) {
  g_config_hook = cfg;
  const int f = ooeTestRandomHooked(seeds, hook);
  g_config_hook = nullptr;
  return f;
}
/// The directed tests (every one that drives a core and injects no bug:
/// demotion, kill, restore, faults, squashes and the rest) with a hook on
/// every core cycle, for the paths random traffic does not take. Returns
/// the failure count.
int ooeTestDirectedHooked(void (*hook)(const Core &)) {
  g_cycle_hook = hook;
  testWakeTimes();
  testBypassGroups();
  testL1Spec();
  testL1WakeAfterCmpl();
  testMaskedLoad();
  testSquash();
  testSquashSaturated();
  testFinalBeforeProducer();
  testFloorCeiling();
  testCeilingGo();
  testDemote();
  testRestore();
  testKill();
  testFault();
  testBarrier();
  testChwidth();
  testWidthCodes();
  testWidthTraffic();
  testSections();
  testV59();
  testFixedWindowPreds();
  g_cycle_hook = nullptr;
  return g_fail;
}
/// The directed tests likewise, every core configured first by cfg.
/// The random atomics (CAS pairs among them), one warp a core, with a hook
/// on every core cycle, configured by cfg: test/ooe/go_tb.cpp's pairs
/// (OI-79). One warp: the go's per-warp fits are then the cycle's, so the
/// cycle's rename ports, which an atomic's two rows can overrun across
/// warps, never bind beyond them (OI-80). First the directed pair-cut, two
/// warps whose ports never bind; not among the directed tests above, whose
/// other benches build no atomics yet.
int ooeTestAtomicHookedWith(unsigned seeds, void (*hook)(const Core &), void (*cfg)(Config &)) {
  g_cycle_hook = hook;
  g_config_hook = cfg;
  testPairCut();
  testPairHeads();
  testAtomicRandom(seeds, randomConfig);
  g_config_hook = nullptr;
  g_cycle_hook = nullptr;
  return g_fail;
}
int ooeTestDirectedHookedWith(void (*hook)(const Core &), void (*cfg)(Config &)) {
  g_config_hook = cfg;
  const int f = ooeTestDirectedHooked(hook);
  g_config_hook = nullptr;
  return f;
}
/// The same, with the hook just before each core cycle instead.
int ooeTestRandomPreHooked(unsigned seeds, void (*hook)(const Core &)) {
  g_pre_cycle_hook = hook;
  testRandom(seeds);
  g_pre_cycle_hook = nullptr;
  return g_fail;
}
/// The directed tests with both hooks, before and after each core cycle,
/// every core configured first by cfg (test/ooe/rename_tb.cpp: the free
/// lists' whole interval between two edges, and the cycle's logs).
int ooeTestDirectedPrePostWith(void (*pre)(const Core &), void (*post)(const Core &), void (*cfg)(Config &)) {
  g_pre_cycle_hook = pre;
  const int f = ooeTestDirectedHookedWith(post, cfg);
  g_pre_cycle_hook = nullptr;
  return f;
}
/// A bench's run in one of the clock-gating scenarios (docs/rtl-coding-
/// style.md; test/ooe/cg_trace.h), each the model's own traffic, so a bench
/// checks every scenario as it checks any run:
///   idle    a core with nothing launched, for idle_cycles, in each of
///           the random tests' configurations (seed 2's modes), so a bench
///           idles in those it follows;
///   medium  the random tests, DEC delivering one uop on one cycle in
///           three, so the core works on a fraction of cycles;
///   high    the random tests as they are.
/// pre and post are the hooks before and after each core cycle, cfg the
/// settings the RTL under test assumes (any may be null). Returns the
/// failure count.
/// Settings a bench holds each random test to, after the test's own.
void ooeTestRandomOver(void (*cfg)(Config &)) { g_random_config_hook = cfg; }

int ooeTestScenario(const std::string &scenario, unsigned seeds, unsigned idle_cycles,
                    void (*pre)(const Core &), void (*post)(const Core &), void (*cfg)(Config &)) {
  g_pre_cycle_hook = pre;
  g_cycle_hook = post;
  g_config_hook = cfg;
  if (scenario == "idle") {
    for (int mode = 0; mode != 8; ++mode) {
      Env e(randomConfig(2, mode));
      for (unsigned k = 0; k != idle_cycles; ++k) e.step();
    }
  } else {
    const bool medium = scenario == "medium";
    g_dec_every = medium ? 3 : 1;
    g_dec_width = medium ? 1 : 6;
    testRandom(seeds);
    g_dec_every = 1;
    g_dec_width = 6;
  }
  g_pre_cycle_hook = nullptr;
  g_cycle_hook = nullptr;
  g_config_hook = nullptr;
  return g_fail;
}
#else
int main(int argc, char **argv) {
  unsigned seeds = 25;
  // OOE_TEST_CONFIG="name=value,...": settings over every test's, for the
  // measurement modes' arms (replay_drain=0, decq_warp_max=6).
  static std::string spec;
  if (const char *e = std::getenv("OOE_TEST_CONFIG")) {
    spec = e;
    Config probe;
    const std::string bad = probe.apply(spec);
    if (!bad.empty()) { std::fprintf(stderr, "OOE_TEST_CONFIG: %s\n", bad.c_str()); return 2; }
    g_config_hook = [](Config &c) { c.apply(spec); };
  }
  for (int i = 1; i < argc; ++i)
    if (std::string(argv[i]) == "--seeds" && i + 1 < argc) seeds = unsigned(std::atoi(argv[++i]));
  if (argc > 1 && std::string(argv[1]) == "--sweep-sections") {
    sweepSections();
    return g_fail ? 1 : 0;
  }
  if (argc > 1 && std::string(argv[1]) == "--atomic") {   // the atomics' tests alone
    testAtomic();
    testAtomicRandom(2, randomConfig);
    std::printf("ooe-test --atomic: %s (%d failure%s)\n", g_fail ? "FAIL" : "PASS", g_fail, g_fail == 1 ? "" : "s");
    return g_fail ? 1 : 0;
  }
  if (argc > 1 && std::string(argv[1]) == "--audit") {
    audit();
    return g_fail ? 1 : 0;
  }
  if (argc > 1 && std::string(argv[1]) == "--stall-hole") {
    const char *only = std::getenv("OOE_TEST_HOLE_FIX");   // one fix's rows, by its index
    const int f = stallHole(seeds == 25 ? 48 : seeds, true, only ? std::atoi(only) : -1);
    std::printf("stall_hole: %d bound(s) missed by the decided go\n", f);
    return g_fail ? 1 : 0;
  }
  if (argc > 1 && std::string(argv[1]) == "--swap-sweep") {
    swapSweep(seeds == 25 ? 48 : seeds);
    return g_fail ? 1 : 0;
  }
  if (argc > 1 && std::string(argv[1]) == "--sweep") {
    sweep();
    return g_fail ? 1 : 0;
  }
  if (std::getenv("OOE_TEST_SWAP")) {     // the swap bench alone, for debugging
    testDemoteRefused();
    testParkedLayout();
    testFinalExit();
    testWidthFromTable();
    testMlcTrigger();
    testSwap();
    std::printf("ooe-test: %s (%d failures)\n", g_fail ? "FAIL" : "PASS", g_fail);
    return g_fail ? 1 : 0;
  }
  if (std::getenv("OOE_TEST_ATOMIC")) {   // the atomic tests alone, for debugging
    testAtomic();
    testAtomicFault();
    testAtomicKill();
    testAtomicDemote();
    testAtomicRandom(seeds, randomConfig);
    std::printf("ooe-test: %s (%d failures)\n", g_fail ? "FAIL" : "PASS", g_fail);
    return g_fail ? 1 : 0;
  }
  if (std::getenv("OOE_TEST_ONLY")) {   // one random case, for debugging
    testRandom(seeds);
    return g_fail ? 1 : 0;
  }
  testWakeTimes();
  testBypassGroups();
  testL1Spec();
  testL1WakeAfterCmpl();
  testMaskedLoad();
  testSquash();
  testSquashSaturated();
  testFinalBeforeProducer();
  testFloorCeiling();
  testCeilingGo();
  testDemote();
  testRestore();
  testKill();
  testFault();
  testBarrier();
  testBarrierDemote();
  testBarrierTimer();
  testBarrierFault();
  testMemFault();
  testChwidth();
  testChwidthMulti();
  testRet();
  testPartialTaken();
  testWidthTraffic();
  testWidthCodes();
  testWidthFault();
  testSizedAndConverged();
  testFormatFault();
  testSections();
  testFreeVec();
  testReadyReg();
  testV59();
  testFixedWindowPreds();
  testRandom(seeds);
  testAtomic();
  testLdPredCopy();
  testNoneIsZero();
  testLdLocal();
  testAtomicFault();
  testAtomicKill();
  testAtomicDemote();
  testAtomicRandom(seeds, randomConfig);
  testPairCut();
  testPairHeads();
  testSwap();
  testDemoteRefused();
  testParkedLayout();
  testFinalExit();
  testCtaSlot();
  testLaneCtx();
  testWidthFromTable();
  testMlcTrigger();
  for (int k : {1, 2, 3, 4, 5}) {
    const char *name = k == 1 ? "control atom-off-head" : k == 2 ? "control atom-early-wake"
                     : k == 3 ? "control a1-base-only" : k == 4 ? "control cas-split" : "control pair-split";
    const int saved = g_fail;
    testAtomicRandom(10, randomConfig, k);
    const bool caught = g_fail != saved;
    g_fail = saved;
    g_test = name;
    EXPECT(caught, "the harness missed it");
    std::printf("  %-24s %s\n", name, caught ? "caught" : "MISSED");
  }
  {
    const char *name = "control in-group-follows";
    const bool caught = !narrowPlacement(true);
    g_test = name;
    EXPECT(caught, "the harness missed it");
    std::printf("  %-24s %s\n", name, caught ? "caught" : "MISSED");
  }
  {
    const char *name = "control partial-taken";
    const int saved = g_fail;
    testPartialTaken(true);
    const bool caught = g_fail != saved;
    g_fail = saved;
    g_test = name;
    EXPECT(caught, "the harness missed it");
    std::printf("  %-24s %s\n", name, caught ? "caught" : "MISSED");
  }
  {
    const char *name = "control no-first-need";
    const int saved = g_fail;
    testPairCut(true);
    const bool caught = g_fail != saved;
    g_fail = saved;
    g_test = name;
    EXPECT(caught, "the harness missed it");
    std::printf("  %-24s %s\n", name, caught ? "caught" : "MISSED");
  }
  {
    const char *name = "control pair-rounds";
    const int saved = g_fail;
    testPairHeads(true);
    const bool caught = g_fail != saved;
    g_fail = saved;
    g_test = name;
    EXPECT(caught, "the harness missed it");
    std::printf("  %-24s %s\n", name, caught ? "caught" : "MISSED");
  }
  testControls();
  std::printf("ooe-test: %s (%d failure%s)\n", g_fail ? "FAIL" : "PASS", g_fail, g_fail == 1 ? "" : "s");
  return g_fail ? 1 : 0;
}
#endif
