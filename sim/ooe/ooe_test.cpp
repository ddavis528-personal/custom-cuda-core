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

#include <algorithm>
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
  return uint32_t(miu) << 12 | uint32_t(rcu) << 11 | uint32_t(cross) << 10 | uint32_t(wg) << 9 |
         uint32_t(wp) << 8 | memk << 6 | uint32_t(br) << 5 | ser << 3 | lat;
}

enum Kind { kLane, kRcuOp, kSetp, kPlogic, kLoad, kStore, kBranch, kExit, kBarrier, kChw, kSfu, kFp };

/// A kind's unit (its lat_class) and its consumer group (Config::byp).
unsigned unitOf(Kind k) { return k == kLane || k == kSetp || k == kFp ? 1 : k == kSfu ? 4 : 0; }
/// Its bypass group as a producer (sched_attr's bypass_group).
unsigned pgroupOf(Kind k) {
  return k == kSfu ? Config::kGrpSfu : k == kFp ? Config::kGrpFp : k == kPlogic ? Config::kGrpPred : Config::kGrpInt;
}
/// Its group as a consumer: a memop consumes as address calculation, and
/// an op RCU executes takes no bypass (V-48).
int groupOf(Kind k) {
  if (k == kLoad || k == kStore) return int(Config::kGrpAddr);
  if (k == kRcuOp || k == kPlogic || k == kBranch) return -1;
  return int(pgroupOf(k));
}

/// One instruction of a synthetic trace.
struct Op {
  Kind k = kLane;
  unsigned dst = 0, src[3] = {}, nsrc = 0, pdst = 0, pguard = 0, pq[2] = {};
  bool guard = false, cross = false, taken = false, pred_taken = false;
  uint32_t mask = kFullMask;
  unsigned w = 0;                ///< sectioned: the destination's width code
  bool backward = false;         ///< a backward branch (OA-14's rotation)
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
  for (unsigned i = 0; i != o.nsrc; ++i) u.shape.gpr_reads |= uint8_t(1u << i);
  u.shape.guard = o.guard;
  u.pred_guard = o.pguard;
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
  case kLoad: u.attr_raw = attr(1, 0, 0, 1, 0, 0, 0, 0, 2); break;
  case kStore: u.attr_raw = attr(1, 0, 0, 0, 0, 1, 0, 0, 3); break;
  case kBranch:
    u.attr_raw = attr(0, 1, 0, 0, 0, 0, 1, 0, 0);
    u.shape.guard = true;      // the condition is the guard (BRA_PRED)
    u.ckpt = ckpt;
    u.pred_taken = o.pred_taken;
    u.imm = 8;
    break;
  case kExit: u.attr_raw = attr(0, 1, 0, 0, 0, 0, 0, 0, 0); u.shape.exit = true; break;
  case kBarrier: u.attr_raw = attr(0, 1, 0, 0, 0, 0, 0, 2, 0); u.imm = 3; break;
  case kChw: u.attr_raw = attr(0, 1, 0, 0, 0, 0, 0, 1, 0); u.imm = 2; break;
  }
  u.attr_raw |= pgroupOf(o.k) << 13;
  if (o.k == kLoad || o.k == kStore) u.attr_raw = (u.attr_raw & 0x1fffu) | Config::kGrpAddr << 13;
  u.attr = SchedAttr::decode(u.attr_raw);
  return u;
}

// ---- the environment: FET, DEC, RCU and MIU at the core's interface ----------------

struct Env {
  Config cfg;
  Core core;
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
  };
  std::vector<Warp> w;
  std::map<uint64_t, Op> op_of;                  ///< tid -> op
  uint64_t lane_ops = 0, lane_ops_one_section = 0;   ///< sectioned stats
  std::map<uint64_t, bool> correct;              ///< tid -> correct path
  std::map<uint64_t, size_t> idx_of;             ///< tid -> program index
  std::multimap<uint64_t, Uop> fetched;          ///< arrival cycle -> uop
  std::multimap<uint64_t, Done> dones;
  std::multimap<uint64_t, Cmpl> cmpls;
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
  std::vector<Outputs> log;
  bool keep_log = false;

  explicit Env(const Config &c, unsigned seed = 1) : cfg(c), core(c), rng(seed) {
    core.on_error = [this](const std::string &m) { errors.push_back(m); };
    if (const char *d = std::getenv("OOE_TEST_TRACE"))
      core.on_event = [this, d](const char *n, unsigned w, uint64_t a, uint64_t b, uint64_t tid) {
        if (std::to_string(tid) == d || std::string(d) == "all")
          std::fprintf(stderr, "  t=%llu %s w%u a=%llu b=%llu tid=%llu\n", (unsigned long long)t, n, w,
                       (unsigned long long)a, (unsigned long long)b, (unsigned long long)tid);
      };
  }

  unsigned rnd(unsigned n) { return n ? unsigned(rng() % n) : 0; }

  void launch(unsigned warp, unsigned slot, std::vector<Op> prog) {
    Warp x;
    x.id = warp;
    x.slot = slot;
    x.prog = std::move(prog);
    w.push_back(x);
    Alloc a;
    a.warp = warp;
    a.slot = slot;
    a.op = kAllocLaunch;
    a.ctaid = 7;
    core.alloc(a);
  }

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
      if (!x.launched || x.exited) continue;
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
        if (o.k == kBranch) x.ckpt_of[tid] = ck;
        if (corr) {
          idx_of[tid] = x.next++;
          if (o.k == kBranch && o.taken != o.pred_taken) {
            x.wrong = true;                      // fetch the wrong path until redirected
            x.wrong_branch_tid = tid;
            x.junk = 0;
            break;
          }
          if (o.k == kExit) break;
        }
      }
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
        for (Warp &y : w) if (y.slot == b / cfg.ckpts && y.launched) x = &y;
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

  void onIssue(const Issue &is) {
    const Op &o = op_of[is.tid];
    if (is.copy) {
      checkRead(is.tid, is.pold, false, int(Config::kGrpInt));
      return;
    }
    last_issue[is.tid] = t;
    issues_of[is.tid] += std::to_string(t) + "@" + std::to_string(is.port) + "/tag" + std::to_string(is.rob_tag) + " ";
    const int group = groupOf(o.k);
    for (unsigned i = 0; i != o.nsrc; ++i) checkRead(is.tid, is.psrc[i], false, group);
    if (is.merge && is.pdst && o.k != kLoad) checkRead(is.tid, is.pold, false, group);
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
    if (is.pdst && o.k != kLoad) {
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
        d.branch_mask = d.branch_taken ? kFullMask : 0;
      }
      dones.insert({t + (rcu_fast ? 2 : bound), d});
    }
  }

  void onMemop(const Memop &m) {
    if (m.mem_op == 0xF) return;
    const Op &o = op_of[m.tid];
    // V-17: a memop never reads an unconfirmed (here: unreadable) source.
    const size_t before = viol[m.tid].size();
    (void)before;
    Cmpl c;
    c.rob_tag = m.rob_tag;
    uint64_t when;
    if (o.k == kLoad && cfg.l1_spec) {
      const bool hit = rnd(100) >= miss_pct;
      hit_of[m.tid] = hit;
      when = t + cfg.lat_l1_cmpl + (hit ? 0 : 1 + rnd(miss_extra));
      if (m.pdst) {
        // Readable at the L1 wake on a hit; on a miss, after the completion.
        const uint64_t rd = hit ? t + cfg.lat_l1_wake : when + data_after_cmpl;
        gready[m.pdst] = {t, rd, m.tid, 2, Config::kGrpAddr, false, false};
        gwriter[m.pdst] = {m.tid, t};
        landings.insert({rd, {m.pdst, m.tid}});
      }
    } else {
      when = t + 4 + rnd(miss_extra);
      if (o.k == kLoad && m.pdst) {
        const uint64_t rd = when + data_after_cmpl;
        gready[m.pdst] = {t, rd, m.tid, 2, Config::kGrpAddr, false, false};
        gwriter[m.pdst] = {m.tid, t};
        landings.insert({rd, {m.pdst, m.tid}});
      }
      c.mlc_miss = true;
    }
    cmpls.insert({when, c});
    if (cfg.memop_rcu_done) {
      Done d;
      d.rob_tag = m.rob_tag;
      dones.insert({when + 1, d});
    }
  }

  void step() {
    // inputs due this cycle
    for (auto it = dones.begin(); it != dones.end() && it->first <= t;) { core.done(it->second); it = dones.erase(it); }
    for (auto it = cmpls.begin(); it != cmpls.end() && it->first <= t;) { core.cmpl(it->second); it = cmpls.erase(it); }
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
    core.cycle(t);
    const Outputs o = core.out;
    if (keep_log) log.push_back(o);
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
    for (const Retired &r : core.retired) {
      Warp *x = warpOf(r.warp);
      x->retired.push_back(r.tid);
      if (r.exit) x->exited = true;
    }
    for (Warp &x : w) x.launched = true;
    fetch();
    // DEC: up to six uops a cycle, in fetch order, as credit allows.
    unsigned n = 0;
    std::set<unsigned> held;
    for (auto it = fetched.begin(); it != fetched.end() && it->first <= t && n != 6;) {
      if (held.count(it->second.warp)) { ++it; continue; }
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

void testFloorCeiling() {
  g_test = "floor-ceiling";
  // A small pool: two slots, a ceiling well under the ROB.
  Config c = baseConfig();
  c.l1_spec = false;
  c.slots = 2;
  c.phys_regs = 64;
  c.ren_floor = 8;
  c.ren_ceil = 12;
  c.pred_regs = 16;
  c.pred_ren_floor = 2;
  c.pred_ren_ceil = 4;
  Env e(c, 3);
  std::vector<Op> p;
  for (unsigned i = 0; i != 60; ++i) { Op a; a.k = kLane; a.dst = i % 16; a.src[0] = (i + 15) % 16; a.nsrc = 1; p.push_back(a); }
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  e.launch(1, 1, p);
  e.finish();
  EXPECT(e.core.counters["stall.gpr_ceiling"] > 0, "the ceiling never held a warp");
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
  Alloc ra; ra.warp = 0; ra.slot = 0; ra.op = kAllocRestoreAlloc;
  e.core.alloc(ra);
  e.step();
  bool map1 = false;
  for (const RatMap &m : e.log.back().maps) map1 = m.direction == 1 && m.gpr[0] != c.phys_zero;
  EXPECT(map1, "no restore map");
  EXPECT(e.core.heldGprs(0) == 16, "restore allocated %u", e.core.heldGprs(0));
  for (const std::string &x : e.errors) EXPECT(false, "%s", x.c_str());
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
  for (unsigned i = 0; i != 3; ++i) { Op a; a.k = kLane; a.dst = i; a.nsrc = 1; p.push_back(a); }
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  // Fault the second op: its done carries exec_fault.
  bool faulted = false;
  unsigned faults = 0;
  for (unsigned k = 0; k != 100; ++k) {
    for (auto &d : e.dones) if ((d.second.rob_tag & 31) == 1 && !faulted) { d.second.exec_fault = true; faulted = true; }
    e.step();
    for (const Status &s : e.log.back().status) faults += s.fault_taken;
  }
  EXPECT(faults == 1, "fault_taken %u times", faults);
  EXPECT(e.w[0].retired.size() == 1, "%zu retired; V-24 stops at the fault", e.w[0].retired.size());
  e.core.kill(1u, 1);
  for (unsigned k = 0; k != 20; ++k) e.step();
  EXPECT(e.core.freeGprs() == c.phys_regs, "kill after a fault left %zu free", e.core.freeGprs());
}

void testBarrier() {
  g_test = "barrier";
  Config c = baseConfig();
  c.l1_spec = false;
  Env e(c);
  e.keep_log = true;
  std::vector<Op> p;
  Op a; a.k = kLane; a.dst = 1; a.nsrc = 1; p.push_back(a);
  Op b; b.k = kBarrier; p.push_back(b);
  Op d; d.k = kLane; d.dst = 2; d.nsrc = 1; p.push_back(d);
  Op ex; ex.k = kExit; p.push_back(ex);
  e.launch(0, 0, p);
  uint64_t bar_at = 0;
  for (unsigned k = 0; k != 40; ++k) {
    e.step();
    for (const Bar &x : e.log.back().bars) { bar_at = e.t - 1; EXPECT(x.barrier_id == 3, "barrier id"); }
  }
  EXPECT(bar_at, "no barrier wait sent");
  EXPECT(issueCount(e, 3) == 0, "a uop younger than the barrier issued before release (V-09)");
  EXPECT(e.w[0].retired.size() == 1, "retired %zu before release", e.w[0].retired.size());
  e.core.barRelease(1u);
  e.finish();
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
    if (i.tid == 2) EXPECT(i.chwidth == 2, "the younger op read chwidth %u, not the committed one", i.chwidth);
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
  g_test = "sections: FP widens to a section pair";
  EXPECT(maxLane(run(cfgS(0), kFp, 2, {0, 1})) == 1, "FP ops in sections 0 and 1 co-issued");
  EXPECT(maxLane(run(cfgS(0), kFp, 2, {0, 2})) == 2, "FP ops in sections 0 and 2 did not co-issue");
  g_test = "sections: SFU takes the whole lane";
  EXPECT(maxLane(run(cfgS(0), kSfu, 2, {0, 2})) == 1, "two SFU ops in a cycle");

  g_test = "sections: a narrow op follows its source; a merge keeps its position";
  {
    Config c = cfgS(0);
    Env e(c);
    e.keep_log = true;
    std::vector<Op> p;
    // Slot 1's home is section 1 (8-bit) or sections 2-3 (16-bit); the
    // source and merge rules must override it.
    Op a; a.k = kLane; a.dst = 4; a.w = 1; p.push_back(a);                               // tid 1: 16-bit, sections 2-3
    Op b; b.k = kLane; b.dst = 5; b.w = 2; b.src[0] = 4; b.nsrc = 1; p.push_back(b);     // tid 2: follows R4 to 2
    Op m; m.k = kLane; m.dst = 5; m.w = 2; m.mask = 0xffff; p.push_back(m);              // tid 3: merges R5 at 2
    Op ex; ex.k = kExit; p.push_back(ex);
    e.launch(5, 1, p);
    e.finish();
    unsigned seen = 0;
    for (const Outputs &o : e.log)
      for (const Issue &i : o.issues)
        if (i.port < 4 && !i.copy) {
          ++seen;
          EXPECT(e.core.namePos(i.pdst) == 2, "tid %llu placed at %u, not section 2",
                 (unsigned long long)i.tid, e.core.namePos(i.pdst));
          EXPECT(i.port == 2, "tid %llu issued on port %u", (unsigned long long)i.tid, i.port);
        }
    EXPECT(seen == 3, "%u lane issues", seen);
    EXPECT(e.errors.empty(), "%s", e.errors.empty() ? "" : e.errors[0].c_str());
  }

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

void testRandom(unsigned seeds) {
  for (unsigned seed = 1; seed <= seeds; ++seed) {
    for (int mode = 0; mode != 8; ++mode) {
      g_test = "random seed " + std::to_string(seed) + " mode " + std::to_string(mode);
      if (const char *only = std::getenv("OOE_TEST_ONLY")) if (g_test != only) continue;
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
      std::mt19937 rng(seed * 4 + unsigned(mode));
      // Every fifth seed: a floorplan where load data lands after the
      // completion (the links split does this), and the core told so.
      if (seed % 5 == 0) c.cmpl_wake_delay = 2;
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
      {"rename_width", {1, 2, 3, 4}, &Config::rename_width},
      {"retire_per_rob", {1, 2, 4}, &Config::retire_per_rob},
  };
  auto run = [](const Config &c) {
    uint64_t total = 0;
    for (unsigned seed = 1; seed <= 6; ++seed) {
      std::mt19937 rng(seed);
      Env e(c, seed);
      e.miss_pct = 20;
      for (unsigned i = 0; i != 4; ++i) e.launch(i, i, randomProgram(rng, 300, true));
      e.finish();
      total += e.t;
    }
    return double(total) / 6;
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
}


/// OI-34: placement and OA-13 arms on synthetic narrow loops, one warp and
/// four. Each kernel is a loop body repeated with a backward taken branch:
///   vaddN: ld a, ld b (N-bit), add, st;
///   redN: ld x, acc += x (loop-carried, N-bit), and the final store;
///   cvt8: ld x (8-bit), x + x (8-bit), a convert to FP32, an FP op, st;
///   aluN: eight N-bit accumulators, initialised, one op each per
///   iteration, each reading a shared narrow operand R12 (lane-bound; alu32
///   is the full-width reference); aluN-self the same with no shared
///   operand (acc = acc op acc), the ceiling for a lone warp.
/// The loop control (an RCU index add, a 32-bit setp, the branch) is in
/// every body, as compiled code carries it.
void sweepSections() {
  enum KK { kVadd, kRed, kCvt, kAlu, kAluSelf };
  auto body = [](KK kk, unsigned w, unsigned iters) {
    std::vector<Op> p;
    for (unsigned i = 0; i != 4; ++i) { Op o; o.k = kRcuOp; o.dst = i; p.push_back(o); }
    // aluN: the narrow operand R12 and eight accumulators, each initialised.
    for (unsigned r = 4; r != 13 && (kk == kAlu || kk == kAluSelf); ++r) { Op o; o.k = kLane; o.dst = r; o.w = w; p.push_back(o); }
    for (unsigned it = 0; it != iters; ++it) {
      if (kk == kAlu || kk == kAluSelf) {
        // Eight independent accumulators, one op each per iteration.
        for (unsigned j = 0; j != 8; ++j) {
          Op a; a.k = kLane; a.dst = 4 + j; a.w = w; a.src[0] = 4 + j; a.src[1] = kk == kAlu ? 12 : 4 + j; a.nsrc = 2; p.push_back(a);
        }
      } else {
        Op x; x.k = kLoad; x.dst = 4; x.w = w; x.src[0] = 0; x.nsrc = 1; p.push_back(x);
      }
      if (kk == kAlu || kk == kAluSelf) {
      } else if (kk == kVadd) {
        Op y; y.k = kLoad; y.dst = 5; y.w = w; y.src[0] = 0; y.nsrc = 1; p.push_back(y);
        Op a; a.k = kLane; a.dst = 6; a.w = w; a.src[0] = 4; a.src[1] = 5; a.nsrc = 2; p.push_back(a);
        Op s; s.k = kStore; s.src[0] = 0; s.src[1] = 6; s.nsrc = 2; p.push_back(s);
      } else if (kk == kRed) {
        Op a; a.k = kLane; a.dst = 7; a.w = w; a.src[0] = 7; a.src[1] = 4; a.nsrc = 2; p.push_back(a);
      } else {
        Op a; a.k = kLane; a.dst = 5; a.w = w; a.src[0] = 4; a.src[1] = 4; a.nsrc = 2; p.push_back(a);
        Op c; c.k = kFp; c.dst = 8; c.src[0] = 5; c.nsrc = 1; p.push_back(c);            // cvt to FP32
        Op f; f.k = kFp; f.dst = 9; f.src[0] = 8; f.src[1] = 8; f.nsrc = 2; p.push_back(f);
        Op s; s.k = kStore; s.src[0] = 0; s.src[1] = 9; s.nsrc = 2; p.push_back(s);
      }
      Op r; r.k = kRcuOp; r.dst = 0; r.src[0] = 0; r.nsrc = 1; p.push_back(r);           // index += stride
      Op t; t.k = kSetp; t.pdst = 1; t.src[0] = 0; t.src[1] = 1; t.nsrc = 2; p.push_back(t);
      const bool more = it + 1 != iters;
      Op b; b.k = kBranch; b.pguard = 1; b.taken = b.pred_taken = more; b.backward = true; p.push_back(b);
    }
    if (kk == kRed) { Op s; s.k = kStore; s.src[0] = 0; s.src[1] = 7; s.nsrc = 2; p.push_back(s); }
    Op e; e.k = kExit; p.push_back(e);
    return p;
  };
  struct Kern { const char *name; KK kk; unsigned w; };
  const Kern ks[] = {{"alu8", kAlu, 2}, {"alu16", kAlu, 1}, {"alu32", kAlu, 0}, {"alu8-self", kAluSelf, 2},
                     {"alu32-self", kAluSelf, 0}, {"vadd8", kVadd, 2},
                     {"vadd16", kVadd, 1}, {"red8", kRed, 2}, {"cvt8", kCvt, 2}};
  const char *pn[] = {"slot", "0", "rotate-0", "rotate-slot", "slot+reg"};
  std::printf("| kernel | warps | place | OA-13 | cycles | vs slot | sections/narrow op | idle sections/cycle | lost resource |\n"
              "|---|---|---|---|---|---|---|---|---|\n");
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
          uint64_t cyc = 0, narrow = 0, nsec = 0, cycles_seen = 0, idle = 0, lost = 0;
          const unsigned seeds = 4;
          for (unsigned seed = 1; seed <= seeds; ++seed) {
            Env e(c, seed);
            e.miss_pct = 10;
            for (unsigned i = 0; i != warps; ++i) e.launch(i * 5, i, body(k.kk, k.w, 32));
            e.finish();
            EXPECT(e.errors.empty(), "%s", e.errors.empty() ? "" : e.errors[0].c_str());
            cyc += e.t;
            for (auto &h : e.core.histograms["sections_per_op.w" + std::to_string(k.w)]) { narrow += h.second; nsec += h.first * h.second; }
            for (auto &h : e.core.histograms["sections_idle"]) { cycles_seen += h.second; idle += h.first * h.second; }
            lost += e.core.counters["select.lost_resource"];
          }
          const double cy = double(cyc) / seeds;
          if (place == 0 && !oa13) ref = cy;
          std::printf("| %s | %u | %s | %s | %.0f | %.3f | %.2f | %.2f | %.0f |\n", k.name, warps, pn[place],
                      oa13 ? "on" : "off", cy, cy / ref, narrow ? double(nsec) / narrow : 0.0,
                      cycles_seen ? double(idle) / cycles_seen : 0.0, double(lost) / seeds);
        }
    }
}

} // namespace

int main(int argc, char **argv) {
  unsigned seeds = 25;
  for (int i = 1; i < argc; ++i)
    if (std::string(argv[i]) == "--seeds" && i + 1 < argc) seeds = unsigned(std::atoi(argv[++i]));
  if (argc > 1 && std::string(argv[1]) == "--sweep-sections") {
    sweepSections();
    return g_fail ? 1 : 0;
  }
  if (argc > 1 && std::string(argv[1]) == "--sweep") {
    sweep();
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
  testFloorCeiling();
  testDemote();
  testKill();
  testFault();
  testBarrier();
  testChwidth();
  testSections();
  testFreeVec();
  testV59();
  testFixedWindowPreds();
  testRandom(seeds);
  testControls();
  std::printf("ooe-test: %s (%d failure%s)\n", g_fail ? "FAIL" : "PASS", g_fail, g_fail == 1 ? "" : "s");
  return g_fail ? 1 : 0;
}
