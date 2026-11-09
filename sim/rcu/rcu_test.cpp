//===-- rcu_test.cpp - unit tests of rcu::Core ---------------------------===//
//
// The RCU model's timing, driven at its decoded interface, with no skeleton:
// each test builds issues and inputs cycle by cycle and checks the cycle of
// every output and register-file write against the spec
// (docs/design-snapshots/rcu-arch-*.md; the live doc wins), plus the
// hazards the spec says never happen, each as a negative control that must
// fail. The kernels (tools/check-kernel.sh with the model in place) cover
// the data paths; these pin the cycles and reach what no kernel does yet:
// the bypass window's edges, MIU's guard forward, kill's drain, and a full
// demotion and restore.
//
// Usage: rcu-test [-v]. Exit status 0 iff every test passes.
//===----------------------------------------------------------------------===//
#include "rcu_core.h"

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

using namespace ccv::rcu;

namespace {

int g_fail = 0;
bool g_verbose = false;
std::string g_test;

#define EXPECT(c, ...)                                                              \
  do {                                                                              \
    if (!(c)) {                                                                     \
      ++g_fail;                                                                     \
      std::fprintf(stderr, "FAIL %s:%d [%s] %s: ", __FILE__, __LINE__, g_test.c_str(), #c); \
      std::fprintf(stderr, __VA_ARGS__);                                            \
      std::fputc('\n', stderr);                                                     \
    }                                                                               \
  } while (0)

/// A negative control: the hazard must be refused. Each caught one prints
/// "control <name> caught" (TI's rev 310), so the gate can count them.
#define CONTROL(name, c, ...)                                                       \
  do {                                                                              \
    const bool caught_ = (c);                                                       \
    EXPECT(caught_, __VA_ARGS__);                                                   \
    if (caught_) std::printf("control %s caught\n", name);                          \
  } while (0)

/// A core with its own register files, recording failures and events.
struct Env : Hooks {
  std::vector<Word> gpr = std::vector<Word>(kRows);
  std::vector<uint32_t> pred = std::vector<uint32_t>(kPRows);
  std::vector<std::string> fails;
  std::vector<Event> evs;
  Core core;
  uint64_t t = 0;

  explicit Env(const std::string &brk = {}, bool full_row = false)
      : core(Config{0, 0, full_row, brk}, Files{&gpr, &pred}, *this) {
    for (unsigned r = 0; r != kRows; ++r)
      for (unsigned l = 0; l != kLanes; ++l) gpr[r][l] = r == kZero ? 0u : (r * 0x01010101u) ^ (l << 24);
    for (unsigned p = 0; p != kPRows; ++p) pred[p] = p == kPZero ? 0u : 0x5a5a0000u | p;
  }
  void fail(const std::string &m) override {
    fails.push_back(m);
    if (g_verbose) std::fprintf(stderr, "  [%s] core: %s\n", g_test.c_str(), m.c_str());
  }
  void event(const Event &e) override { evs.push_back(e); }

  static In idleIn() {
    In in;
    in.done_can.fill(true);
    in.addr_can.fill(true);
    return in;
  }
  Out step(const In &in) {
    Out o;
    core.cycle(t++, in, o);
    return o;
  }
  Out step() { return step(idleIn()); }
  /// The cycle of the first event of kind e on row (a), or -1.
  long first(Ev e, uint32_t a) const {
    for (const Event &x : evs)
      if (x.ev == e && x.a == a) return long(x.t);
    return -1;
  }
  bool failed(const char *needle) const {
    for (const std::string &f : fails)
      if (f.find(needle) != std::string::npos) return true;
    return false;
  }
};

// ---- issue builders -----------------------------------------------------------------

Issue movi(unsigned dst, uint32_t imm, unsigned tag) {
  Issue is;
  is.tag = tag;
  is.tid = tag;
  is.issue_mask = ~0u;
  is.dst = dst;
  is.imm = imm;
  is.oc.unit = Unit::ROnly;
  is.oc.rk = RKind::Movi;
  is.oc.gdst = true;
  is.oc.imm_used = true;
  is.lead.imm = true;
  return is;
}
Issue pmovImm(unsigned pdst, uint32_t imm, unsigned tag) {
  Issue is = movi(kZero, imm, tag);
  is.oc.gdst = false;
  is.oc.rk = RKind::PmovImm;
  is.pwe = true;
  is.pdst = pdst;
  return is;
}
/// A 32-bit lane op on all four sections, lead S0, reading sources 0 and 1.
Issue laneOp(unsigned dst, unsigned s0, unsigned s1, unsigned tag) {
  Issue is;
  is.tag = tag;
  is.tid = tag;
  is.issue_mask = ~0u;
  is.dst = dst;
  is.src = {s0, s1, kZero};
  is.foot = kAllSecs;
  is.opcode = 1;
  is.oc.unit = Unit::Lane;
  is.oc.gdst = true;
  is.oc.reads = 3;
  is.lead.sec = kAllSecs;
  is.lead.src = 3;
  return is;
}
/// Its four continuations on S1-S3.
void placeLane(In &in, const Issue &is) {
  in.iss[kSlotS0] = is;
  for (unsigned k = 1; k != kSecs; ++k) {
    Issue c;
    c.cont = true;
    c.tag = is.tag;
    c.tid = is.tid;
    in.iss[kSlotS0 + k] = c;
  }
}
LaneRes laneRes(uint32_t v) {
  LaneRes r;
  r.result.fill(v);
  r.sec_valid.fill(uint8_t(kAllSecs));
  return r;
}

// ---- tests ----------------------------------------------------------------------------

/// R's write lands at A+2 (CCV_LAT_RCU 3), its done is launched in A on
/// CCV_DONE_SLOT_RCU.
void testRTiming() {
  g_test = "r-timing";
  Env e;
  e.t = 10;
  In in = Env::idleIn();
  in.iss[kSlotR] = movi(5, 0x1234, 7);
  const uint32_t before = e.gpr[5][0];
  Out o = e.step(in);
  EXPECT(o.dones.size() == 1 && o.dones[0].slot == kDoneRcu && o.dones[0].tag == 7, "done in A on slot %u",
         kDoneRcu);
  e.step();   // A+1
  EXPECT(e.gpr[5][0] == before, "written before A+2");
  e.step();   // A+2
  EXPECT(e.gpr[5][0] == 0x1234 && e.gpr[5][31] == 0x1234, "not written at A+2: %08x", e.gpr[5][0]);
  EXPECT(e.first(Ev::GprWrite, 5) == 12, "GprWrite at %ld, not 12", e.first(Ev::GprWrite, 5));
  EXPECT(e.fails.empty(), "%s", e.fails.empty() ? "" : e.fails[0].c_str());
}

/// A lane op: the lane message in A, its done launched at A + CCV_LAT_LANE - 2,
/// its results expected and written at A + CCV_LAT_LANE - 1 (kLaneW; A+6 at
/// CCV_LAT_LANE 7, the default since Z). Early or missing results fail.
void testLaneTiming() {
  g_test = "lane-timing";
  for (int mode = 0; mode != 3; ++mode) {   // 0 on time, 1 missing, 2 early
    Env e;
    e.t = 20;
    In in = Env::idleIn();
    placeLane(in, laneOp(9, 3, 4, 2));
    Out o = e.step(in);
    EXPECT(o.lane.has_value(), "no lane message in A");
    if (o.lane) {
      EXPECT(o.lane->opnd[5][0] == e.gpr[3][5] && o.lane->opnd[5][1] == e.gpr[4][5], "operands read wrong");
      for (unsigned k = 0; k != kSecs; ++k) EXPECT(o.lane->sec[k].en && o.lane->sec[k].owner == 0, "section %u", k);
    }
    long done_at = -1;
    const uint64_t a = 20, w = a + kLaneW;
    for (uint64_t c = a + 1; c != w + 1; ++c) {
      In x = Env::idleIn();
      if ((mode == 0 && c == w) || (mode == 2 && c == w - 1)) x.lres = laneRes(0xabcd0000u);
      Out oo = e.step(x);
      if (!oo.dones.empty()) {
        done_at = long(c);
        EXPECT(oo.dones[0].slot == 0 && oo.dones[0].tag == 2, "done slot %u", oo.dones[0].slot);
      }
    }
    if (mode == 0) {
      EXPECT(done_at == long(w - 1), "done launched at %ld, not A+%u", done_at, kLaneW - 1);
      EXPECT(e.gpr[9][0] == 0xabcd0000u, "not written at A+%u", kLaneW);
      EXPECT(e.first(Ev::GprWrite, 9) == long(w), "GprWrite at %ld", e.first(Ev::GprWrite, 9));
      EXPECT(e.fails.empty(), "%s", e.fails.empty() ? "" : e.fails[0].c_str());
    } else {
      CONTROL(mode == 1 ? "lane-missing" : "lane-early", e.failed(mode == 1 ? "did not arrive" : "nothing in flight"), "control %d passed", mode);
    }
  }
}

/// The bypass window, ages CCV_LAT_LANE_BYP (kBypLo, 4) to CCV_LAT_LANE - 2
/// (kBypHi; 5 at CCV_LAT_LANE 7, the default since Z): select forward | lead << 1 |
/// (age - kBypLo) << 3; past kBypHi the PRF holds it; below kBypLo a read is a
/// contract breach.
void testBypassWindow() {
  g_test = "bypass";
  for (unsigned age = kBypLo - 1; age != kBypHi + 3; ++age) {
    Env e;
    e.t = 40;
    In in = Env::idleIn();
    placeLane(in, laneOp(11, 3, 4, 1));
    e.step(in);
    for (unsigned c = 1; c <= std::max(age, kLaneW); ++c) {
      In x = Env::idleIn();
      if (c == kLaneW) x.lres = laneRes(0x77777777u);
      if (c == age) placeLane(x, laneOp(12, 11, 3, 2));
      Out o = e.step(x);
      if (c != age || !o.lane) continue;
      const unsigned sel = o.lane->sec[0].byp[0];
      if (age >= kBypLo && age <= kBypHi)
        EXPECT(sel == (1u | (age - kBypLo) << 3), "age %u select %u", age, sel);
      if (age > kBypHi) {
        EXPECT(sel == 0, "age %u bypasses (%u)", age, sel);
        EXPECT(o.lane->opnd[0][0] == 0x77777777u, "age %u reads %08x, not the PRF's", age, o.lane->opnd[0][0]);
      }
      EXPECT(o.lane->sec[0].byp[1] == 0, "the unrelated port bypasses");
    }
    if (age < kBypLo) CONTROL("byp-age3", e.failed("CCV_LAT_LANE_BYP"), "age 3 read passed");
    else {
      // Drain the second op's results.
      while (e.t <= 40 + age + kLaneW) {
        In x = Env::idleIn();
        if (e.t == 40 + age + kLaneW) x.lres = laneRes(0);
        e.step(x);
      }
      EXPECT(e.fails.empty(), "age %u: %s", age, e.fails.empty() ? "" : e.fails[0].c_str());
    }
  }
}

/// A guard read in A sees MIU's predicate write in A (the forward), but a
/// non-MIU write landing in the guard's own A is a hazard; from A+1 it reads.
void testGuardForward() {
  g_test = "guard-forward";
  for (int mode = 0; mode != 3; ++mode) {   // 0 MIU in A, 1 R write in A (fails), 2 R write in A-1
    Env e;
    e.t = 50;
    const unsigned P = 9;
    uint64_t a = 0;
    if (mode == 0) {
      a = 50;
    } else {
      In x = Env::idleIn();
      x.iss[kSlotR] = pmovImm(P, 0x0000ffffu, 1);
      e.step(x);           // writes at 52
      e.step();
      a = mode == 1 ? 52 : 53;
      while (e.t < a) e.step();
    }
    In in = Env::idleIn();
    Issue br = movi(kZero, 0, 3);
    br.oc.rk = RKind::Bra;
    br.oc.gdst = false;
    br.oc.guarded = true;
    br.oc.imm_used = false;
    br.lead = Lead{};
    br.lead.guard = true;
    br.lead.gpred = P;
    br.pguard = P;
    in.iss[kSlotR] = br;
    if (mode == 0) {
      MiuData m;
      m.dst = kZero;
      m.pwe = true;
      m.ppred = P;
      m.active = ~0u;
      m.pred_result = 0x00ff00ffu;
      in.mdat[0] = m;
    }
    Out o = e.step(in);
    const uint32_t want = mode == 0 ? 0x00ff00ffu : 0x0000ffffu;
    if (mode == 1) {
      CONTROL("guard-hazard", e.failed("non-MIU port in its own A"), "same-A predicate hazard passed");
    } else {
      EXPECT(e.fails.empty(), "mode %d: %s", mode, e.fails.empty() ? "" : e.fails[0].c_str());
      EXPECT(o.dones.size() == 1 && o.dones[0].bm == want, "branch mask %08x, not %08x",
             o.dones.empty() ? 0u : o.dones[0].bm, want);
      if (mode == 0) EXPECT(e.first(Ev::GuardFwd, kSlotR) == 50, "no GuardFwd event");
    }
  }
}

/// V-60: two lane ops' footprints overlap.
void testV60() {
  g_test = "v60";
  Env e;
  In in = Env::idleIn();
  placeLane(in, laneOp(9, 3, 4, 1));
  Issue b = laneOp(10, 3, 4, 2);
  b.foot = 0x2;
  b.lead.sec = 0x2;
  in.iss[kSlotS0 + 1] = b;
  e.step(in);
  CONTROL("v60", e.failed("V-60") || e.failed("continuation"), "overlap passed");
}

/// lead_sec_mask is exact (OA 403, RA 133, TI 400): a mask wider than the
/// footprint, or narrower, is refused.
void testLeadSecExact() {
  g_test = "leadsec";
  {
    Env e;
    In in = Env::idleIn();
    Issue a = laneOp(9, 3, 4, 1);
    a.foot = 0x1;
    a.lead.sec = 0x3;
    in.iss[kSlotS0] = a;
    e.step(in);
    CONTROL("leadsec-wide", e.failed("wider than its footprint"), "a lead mask wider than its footprint passed");
  }
  {
    Env e;
    In in = Env::idleIn();
    Issue a = laneOp(9, 3, 4, 1);
    a.foot = 0x3;
    a.lead.sec = 0x1;
    in.iss[kSlotS0] = a;
    in.iss[kSlotS0 + 1] = Issue();
    in.iss[kSlotS0 + 1]->cont = true;
    in.iss[kSlotS0 + 1]->tag = a.tag;
    in.iss[kSlotS0 + 1]->tid = a.tid;
    e.step(in);
    CONTROL("leadsec-narrow", e.failed("outside its lead's mask"), "a lead mask narrower than its footprint passed");
  }
}

/// Kill: the drain is KILL_DRAIN cycles from K's edge; ack-ready after it.
void testKillDrain() {
  g_test = "kill-drain";
  Env e;
  e.t = 100;
  e.step();
  e.core.kill(0x1, 0);
  const unsigned d = e.core.killDrain();
  // No links and, since RA-43, no boundary flop on either end: the params'
  // derived drain itself (RA-42, RA rev 125), 15 at SFU 12.
  const unsigned want = 2 + ccv::prov::kLatSfu + 1;
  EXPECT(d == want && d == ccv::prov::kLatRcuKillDrain, "KILL_DRAIN %u, not %u (CCV_LAT_RCU_KILL_DRAIN %u)", d,
         want, ccv::prov::kLatRcuKillDrain);
  e.step();   // K
  unsigned n = 0;
  while (!e.core.killQuiet() && n < 40) { e.step(); ++n; }
  EXPECT(n == d, "quiet after %u cycles past K, not %u", n, d);
  EXPECT(e.first(Ev::KillAck, 0) >= 0, "no KillAck once quiet");
  EXPECT(e.core.idle(), "not idle once drained");
}

MapMsg mapOf(unsigned warp, unsigned dir, unsigned base) {
  MapMsg m;
  m.warp = warp;
  m.dir = dir;
  for (unsigned i = 0; i != kArchGprs; ++i) m.gpr[i] = base + i;
  for (unsigned p = 0; p != kArchPreds; ++p) m.pred[p] = 1 + p + (base % 4) * kArchPreds;
  return m;
}

/// Demotion then restore of one warp: rows 0-15 then the predicate row, in
/// order, a row a cycle from CCV_WAKE_LAT after the launch; R2 taken by R
/// stalls it a cycle. The restore writes each row at A+2 and frees its FIFO
/// entry when written.
void testMigration(const char *brk) {
  g_test = std::string("migration") + (*brk ? std::string(":") + brk : "");
  Env e(brk);
  e.t = 200;
  const MapMsg dm = mapOf(2, 0, 20);
  {
    In x = Env::idleIn();
    x.map = dm;
    x.cmd = CmdMsg{2, 0};
    e.step(x);   // 200: land
  }
  std::vector<MigRow> rows;
  std::vector<uint64_t> at;
  bool stalled = false;
  for (unsigned c = 0; c != 40 && rows.size() < kMigRows; ++c) {
    In x = Env::idleIn();
    // An R merge op holding R2 on the fifth row's cycle.
    if (rows.size() == 4 && !stalled) {
      Issue m = movi(40, 1, 9);
      m.merge = true;
      m.old_dst = 41;
      m.lead.merge = true;
      x.iss[kSlotR] = m;
      stalled = true;
    }
    Out o = e.step(x);
    if (o.pca) { rows.push_back(*o.pca); at.push_back(e.t - 1); }
  }
  EXPECT(rows.size() == kMigRows, "%zu rows demoted", rows.size());
  if (*brk) {
    bool order = true;
    for (unsigned i = 0; i != rows.size(); ++i) order = order && rows[i].row == i;
    CONTROL("mig-row-order", !order, "mig-row-order's rows came out in order");
    return;
  }
  for (unsigned i = 0; i != rows.size(); ++i) {
    EXPECT(rows[i].row == i && rows[i].warp == 2, "row %u is %u", i, rows[i].row);
    if (i < kArchGprs) EXPECT(rows[i].data[3] == e.gpr[dm.gpr[i]][3], "row %u's data", i);
  }
  // Launch at 202 (pick at 201), wake counter CCV_WAKE_LAT - 1: first row at 205.
  EXPECT(!at.empty() && at[0] == 202 + ccv::kWakeLat - 1, "first row at %llu",
         at.empty() ? 0ull : (unsigned long long)at[0]);
  EXPECT(at.size() == kMigRows && at.back() - at[0] == kMigRows, "%u-row demote took %llu cycles (one R2 wait)",
         kMigRows, at.size() ? (unsigned long long)(at.back() - at[0]) : 0ull);
  EXPECT(e.core.stats().mig_r_waits == 1, "%llu R waits", (unsigned long long)e.core.stats().mig_r_waits);
  // Drain the R op's write.
  e.step();
  e.step();

  // Restore into fresh rows: the map and command, then the rows, two of them
  // ahead of the pairing (the FIFO holds them).
  const MapMsg rm = mapOf(2, 1, 60);
  unsigned sent = 0, credits = 0;
  const uint64_t t0 = e.t;
  uint64_t done_at = 0;
  for (unsigned c = 0; c != 60; ++c) {
    In x = Env::idleIn();
    if (c == 3) { x.map = rm; x.cmd = CmdMsg{2, 1}; }
    // PCA sends a row a cycle while it holds a credit (CCV_CREDIT_DEPTH).
    if (sent < rows.size() && sent - credits < ccv::kCreditDepth && c >= 1) {
      MigRow r = rows[sent];
      if (r.row < kArchGprs) for (unsigned l = 0; l != kLanes; ++l) r.data[l] = 0xc0de0000u | (r.row << 8) | l;
      else for (unsigned p = 0; p != kArchPreds; ++p) r.data[p] = 0xf0f00000u | p;
      x.pca = r;
      ++sent;
    }
    Out o = e.step(x);
    credits += o.pca_credit;
    for (const Event &ev : e.evs)
      if (ev.ev == Ev::RestoreDone && !done_at) done_at = ev.t;
  }
  EXPECT(credits == kMigRows, "%u restore credits, not %u", credits, kMigRows);
  EXPECT(done_at != 0, "the restore never finished");
  for (unsigned i = 0; i != kArchGprs; ++i)
    EXPECT(e.gpr[rm.gpr[i]][7] == (0xc0de0000u | (i << 8) | 7), "R%u restored as %08x", i, e.gpr[rm.gpr[i]][7]);
  for (unsigned p = 0; p != kArchPreds; ++p)
    EXPECT(e.pred[rm.pred[p]] == (0xf0f00000u | p), "P%u restored as %08x", p, e.pred[rm.pred[p]]);
  EXPECT(e.fails.empty(), "%s", e.fails.empty() ? "" : e.fails[0].c_str());
  if (g_verbose) std::fprintf(stderr, "  restore done %llu cycles after its first row\n",
                              (unsigned long long)(done_at - t0));
}

/// A restore map naming the zero register is refused (A-64).
void testRestoreZero() {
  g_test = "restore-zero";
  Env e;
  MapMsg m = mapOf(1, 1, 20);
  m.gpr[3] = kZero;
  In x = Env::idleIn();
  x.map = m;
  e.step(x);
  CONTROL("restore-zero", e.failed("zero register"), "a zero row in a restore map passed");
}

/// A 16-bit load at position 1 (sections 1-2): the Register file tab's MW
/// writes secmask only; AR-24's interim writes the row, zero-extended.
void testNarrowWrite() {
  for (bool fr : {false, true}) {
    g_test = fr ? "narrow-write:full-row" : "narrow-write";
    Env e({}, fr);
    const uint32_t before = e.gpr[30][4];
    In x = Env::idleIn();
    MiuData m;
    m.dst = 30;
    m.pos = 1;
    m.w = 1;
    m.active = ~0u;
    m.data.fill(0x1234abcdu);
    x.mdat[2] = m;
    e.step(x);
    const uint32_t want = fr ? 0x00abcd00u : (before & 0xff0000ffu) | 0x00abcd00u;
    EXPECT(e.gpr[30][4] == want, "row %08x, not %08x", e.gpr[30][4], want);
    EXPECT(e.fails.empty(), "%s", e.fails.empty() ? "" : e.fails[0].c_str());
  }
}

/// SW (A + CCV_LAT_SFU - 1) writes sfu_result, never result, which is LW's
/// (RA rev 120). An SFU op issued kSfuW - kLaneW cycles before a lane op
/// lands in the same cycle on every lane: SW takes sfu_result into its row,
/// LW result into its own. Controls: sw-from-result feeds SW from result,
/// and an SFU op due with no sfu_valid is refused.
void testSfuWrite() {
  for (int mode = 0; mode != 3; ++mode) {   // 0 clean, 1 sw-from-result, 2 no sfu_valid
    g_test = mode == 0 ? "sfu-write" : mode == 1 ? "sfu-write:sw-from-result" : "sfu-write:no-sfu-valid";
    Env e(mode == 1 ? "sw-from-result" : "");
    e.t = 40;
    const uint64_t a = 40, w = a + kSfuW, b = w - kLaneW;
    Issue sf = laneOp(9, 3, 4, 2);
    sf.oc.unit = Unit::Sfu;
    for (uint64_t c = a; c != w + 1; ++c) {
      In x = Env::idleIn();
      if (c == a) placeLane(x, sf);
      if (c == b) placeLane(x, laneOp(10, 5, 6, 3));
      if (c == w) {
        LaneRes r = laneRes(0xabcd0000u);
        r.sfu_result.fill(0x12345678u);
        if (mode != 2) r.sfu_valid.fill(1);
        x.lres = r;
      }
      e.step(x);
    }
    if (mode == 0) {
      EXPECT(e.gpr[9][0] == 0x12345678u && e.gpr[9][31] == 0x12345678u, "SW wrote %08x, not sfu_result",
             e.gpr[9][0]);
      EXPECT(e.gpr[10][0] == 0xabcd0000u && e.gpr[10][31] == 0xabcd0000u, "LW wrote %08x beside SW",
             e.gpr[10][0]);
      EXPECT(e.first(Ev::GprWrite, 9) == long(w) && e.first(Ev::GprWrite, 10) == long(w),
             "SW at %ld, LW at %ld, not both %llu", e.first(Ev::GprWrite, 9), e.first(Ev::GprWrite, 10),
             (unsigned long long)w);
      EXPECT(e.fails.empty(), "%s", e.fails.empty() ? "" : e.fails[0].c_str());
    } else if (mode == 1) {
      CONTROL("sw-from-result", e.gpr[9][0] != 0x12345678u, "SW took sfu_result under sw-from-result");
    } else {
      CONTROL("sfu-valid-missing", e.failed("no sfu_valid"), "an SFU op due with no sfu_valid passed");
    }
  }
}

/// A narrow SFU op (RA rev 124, OA-15): the lane sends sfu_result already
/// steered, like result, and RCU writes it as it comes. A 16-bit op at
/// position 2 writes bytes 2-3 only (FULL_ROW 0); under FULL_ROW a 16-bit op
/// at position 0 writes the whole row, the lane's zeros above the width
/// with it. Controls: sw-resteer steers sfu_result a second time; under
/// FULL_ROW, bits outside the element are refused.
void testSfuNarrow() {
  for (int mode = 0; mode != 4; ++mode) {   // 0 pos 2, 1 full-row pos 0, 2 sw-resteer, 3 dirty above width
    const bool fr = mode == 1 || mode == 3;
    g_test = mode == 0 ? "sfu-narrow" : mode == 1 ? "sfu-narrow:full-row" : mode == 2 ? "sfu-narrow:sw-resteer"
                                                                                       : "sfu-narrow:dirty";
    Env e(mode == 2 ? "sw-resteer" : "", fr);
    e.t = 40;
    const unsigned pos = fr ? 0 : 2;
    const uint32_t before = e.gpr[9][0], sres = fr ? (mode == 3 ? 0x0001beefu : 0x0000beefu) : 0xbeef0000u;
    const uint64_t a = 40, w = a + kSfuW;
    Issue sf = laneOp(9, 3, 4, 2);
    sf.oc.unit = Unit::Sfu;
    sf.dst_w = 1;
    sf.dst_pos = pos;
    for (uint64_t c = a; c != w + 1; ++c) {
      In x = Env::idleIn();
      if (c == a) placeLane(x, sf);
      if (c == w) {
        LaneRes r = laneRes(0);
        r.sec_valid.fill(0);   // no lane op due: SW alone
        r.sfu_result.fill(sres);
        r.sfu_valid.fill(1);
        x.lres = r;
      }
      e.step(x);
    }
    const uint32_t want = fr ? sres : (before & 0x0000ffffu) | sres;
    if (mode < 2) {
      EXPECT(e.gpr[9][0] == want && e.gpr[9][31] == want, "row %08x, not %08x", e.gpr[9][0], want);
      EXPECT(e.fails.empty(), "%s", e.fails.empty() ? "" : e.fails[0].c_str());
    } else if (mode == 2) {
      CONTROL("sw-resteer", e.gpr[9][0] != want, "SW wrote %08x, steered twice", e.gpr[9][0]);
    } else {
      CONTROL("sfu-dirty-above-width", e.failed("outside its"), "bits above the width passed under FULL_ROW");
    }
  }
}

/// Idle: nothing in flight is idle; an op keeps it busy until its write.
void testIdle() {
  g_test = "idle";
  Env e;
  e.step();
  EXPECT(e.core.idle(), "not idle at rest");
  In x = Env::idleIn();
  x.iss[kSlotR] = movi(5, 1, 1);
  e.step(x);
  EXPECT(!e.core.idle(), "idle with a write pending");
  e.step();
  e.step();
  e.step();
  EXPECT(e.core.idle(), "not idle after the write");
}

} // namespace

int main(int argc, char **argv) {
  for (int i = 1; i < argc; ++i)
    if (!std::strcmp(argv[i], "-v")) g_verbose = true;
  testRTiming();
  testLaneTiming();
  testBypassWindow();
  testGuardForward();
  testV60();
  testLeadSecExact();
  testKillDrain();
  testMigration("");
  testMigration("mig-row-order");
  testRestoreZero();
  testNarrowWrite();
  testSfuWrite();
  testSfuNarrow();
  testIdle();
  std::printf("rcu-test: %s (%d failures)\n", g_fail ? "FAIL" : "PASS", g_fail);
  return g_fail ? 1 : 0;
}
