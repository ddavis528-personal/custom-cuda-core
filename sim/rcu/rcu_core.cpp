//===-- rcu_core.cpp - the RCU's cycle-accurate model ---------------------===//
//
// See rcu_core.h for the cycle convention. Section references are to the
// CCV RCU Architecture spec's tabs (docs/design-snapshots/rcu-arch-*.md).
//===----------------------------------------------------------------------===//
#include "rcu_core.h"

#include <cstdarg>
#include <cstdio>

namespace ccv {
namespace rcu {

namespace {
constexpr unsigned clog2c(unsigned x) { return x <= 1 ? 0 : 1 + clog2c((x + 1) / 2); }
constexpr unsigned kBypSecBits = clog2c(kSecs);
static_assert(ccv::prov::kWLaneBypSel == 1 + kBypSecBits + ccv::prov::kWLaneBypAge,
              "operand_byp is forward, lead section, age");
static_assert(kBypHi - kBypLo < (1u << ccv::prov::kWLaneBypAge), "the bypass window fits its age field");
constexpr uint32_t kAll = 0xffffffffu;
/// The trace identity's seq (ccv_event_ids.h's uidSeq: the low 32 bits), as messages print it.
inline unsigned long long seqOf(uint64_t tid) { return tid & 0xffffffffu; }
constexpr unsigned kFifoDepth = ccv::kCreditDepth;   // the restore FIFO (RA-28 (c))
constexpr unsigned kPairDepth = ccv::kTier1Warps;    // each pairing queue (RA-28 (d))

// Write ports, for the events and the hazard checks (Register file and
// Predicate file tabs). RS is RW carrying a restore row, PG the restore's
// predicate ports.
enum : unsigned { kLW = 0, kSW = 1, kMW = 2, kRWp = 3, kRS = 4 };
enum : unsigned { kPL = 0, kPM = 1, kPR = 2, kPC = 3, kPG = 4 };

unsigned lowest(uint32_t m) { return m ? unsigned(__builtin_ctz(m)) : 32u; }
std::string secBits(unsigned f) {
  std::string b;
  for (unsigned k = kSecs; k-- != 0;) b += (f >> k) & 1u ? '1' : '0';
  return b;
}
const char *resName(unsigned s) {
  static const char *n[] = {"S0", "S1", "S2", "S3", "P0", "P1", "P2", "P3", "R"};
  return s < kRes ? n[s] : "?";
}
unsigned groupOf(unsigned s) { return s < kSlotP0 ? kSlotS0 : s < kSlotR ? kSlotP0 : kSlotR; }
} // namespace

const char *evName(Ev e) {
  switch (e) {
  case Ev::GprWrite: return "gpr_write";
  case Ev::PredWrite: return "pred_write";
  case Ev::Branch: return "branch";
  case Ev::GuardFwd: return "guard_fwd";
  case Ev::RsrcFwd: return "rsrc_fwd";
  case Ev::BypassSel: return "bypass_sel";
  case Ev::KillDrain: return "kill_drain";
  case Ev::KillAck: return "kill_ack";
  case Ev::MigPair: return "mig_pair";
  case Ev::MigRowOut: return "mig_row_out";
  case Ev::MigRowIn: return "mig_row_in";
  case Ev::MigWaitR: return "mig_wait_r";
  case Ev::MigWaitCredit: return "mig_wait_credit";
  case Ev::RestoreHold: return "restore_hold";
  case Ev::RestoreDone: return "restore_done";
  case Ev::Idle: return "idle";
  case Ev::Wake: return "wake";
  }
  return "?";
}

Core::Core(const Config &cfg, Files f, Hooks &h) : cfg_(cfg), f_(f), h_(h) {}

void Core::fail(const char *fmt, ...) {
  char b[512];
  va_list ap;
  va_start(ap, fmt);
  std::vsnprintf(b, sizeof b, fmt, ap);
  va_end(ap);
  h_.fail(std::string("rcu: ") + b);
}

void Core::ev(Ev e, uint32_t a, uint32_t b, uint32_t c, uint32_t d) {
  h_.event(Event{now_, e, a, b, c, d});
}

// ---- reads ------------------------------------------------------------------------

// The zero registers have no row: they decode to no select and read 0
// (A-64). dirty-zero reads them as garbage, which the merge kernel must show.
uint32_t Core::rdPred(unsigned row) const {
  if (row == kPZero) return cfg_.brk == "dirty-zero" ? 0xa5a5a5a5u : 0u;
  if (row >= kPRows) return 0;
  return (*f_.pred)[row];
}
uint32_t Core::rdGpr(unsigned row, unsigned l) const {
  if (row == kZero) return cfg_.brk == "dirty-zero" ? 0x5a5a5a5au : 0u;
  if (row >= kRows) return 0;
  return (*f_.gpr)[row][l];
}
Word Core::rdReg(unsigned row, unsigned pos, unsigned w) const {
  Word v{};
  for (unsigned l = 0; l != kLanes; ++l) v[l] = (rdGpr(row, l) >> (8 * pos)) & elemMask(w);
  return v;
}

bool Core::hazardG(unsigned row, unsigned secs) const {
  for (const GWrite &w : gnow_)
    if (w.port != kMW && w.row == row && (w.secs & secs) && w.lanes) return true;
  return false;
}
bool Core::hazardP(unsigned row) const {
  for (const PWrite &w : pnow_)
    if (!w.miu && w.row == row && w.m) return true;
  return false;
}

// ---- write-back --------------------------------------------------------------------

void Core::gatherWrites(uint64_t t, const In &in, std::vector<GWrite> &gw, std::vector<PWrite> &pw) {
  // Lane results (LW, PL): due at A + CCV_LAT_LANE - 1 from their descriptors.
  auto due = lanes_.find(t);
  if (due == lanes_.end()) {
    if (in.lres) fail("lane results for nothing in flight");
  } else {
    std::vector<LaneDesc> ds = std::move(due->second);
    lanes_.erase(due);
    if (!in.lres) {
      fail("lane results due in cycle %llu (CCV_LAT_LANE %u) did not arrive",
           (unsigned long long)t, ccv::prov::kLatLane);
    } else {
      const LaneRes &r = *in.lres;
      unsigned want = 0;
      for (const LaneDesc &d : ds) want |= d.secs;
      for (unsigned l = 0; l != kLanes; ++l)
        if (r.sec_valid[l] != want) {
          // The lanes' sec_valid must equal the descriptors' (Lane and
          // memory tab); it is never an enable.
          fail("lane %u's results hold sections %s, not the %s in flight", l,
               secBits(r.sec_valid[l]).c_str(), secBits(want).c_str());
          break;
        }
      for (const LaneDesc &d : ds) {
        // A copy lands within CCV_LAT_LANE of RCU taking it: the contract
        // OOE clears the load's copy-pending on (late-copy breaks it).
        if (d.copy && t - d.acc > ccv::prov::kLatLane)
          fail("seq %llu's copy reached the PRF %llu cycles after RCU took it; CCV_LAT_LANE is %u",
               seqOf(d.tid), (unsigned long long)(t - d.acc), ccv::prov::kLatLane);
        // SW (A+11): not modelled yet (RA-3's field). When it is, it writes
        // like MW and RW: all four banks zero-extended under full_row (RA's
        // response RI-5, Register file tab rev 7), secmask otherwise.
        if (d.sfu) { fail("an SFU result is not modelled yet (RA-3's field)"); continue; }
        // LW writes every bank the op owns (Register file tab, LW's enable):
        // a chwidth widening names its old width in dst_width (AR-24) and
        // its footprint covers the new one. The Lane and memory tab's
        // descriptor says secmask(dst) instead (RI row to RA).
        const unsigned ws = d.secs;
        if (d.gdst && ws) {
          GWrite g{kLW, d.dst, ws, d.copy ? ~d.active : kAll, r.result};
          gw.push_back(g);
        }
        if (d.pwe) {
          uint32_t po = 0;
          for (unsigned l = 0; l != kLanes; ++l) po |= uint32_t((r.sec_pred_out[l] >> d.lead) & 1u) << l;
          // The lanes' bits on active lanes, the old destination's elsewhere
          // (A-43). ignore-mask drops the mask.
          const uint32_t on = cfg_.brk == "ignore-mask" ? kAll : d.active;
          pw.push_back({kPL, d.pdst, kAll, po, on, d.merge ? int(d.pold) : -1, false});
        }
        if (!d.copy) ++st_.gpr_writes;
      }
    }
  }
  // Load write-back (MW, PM): stateless, everything echoed by MIU.
  unsigned msecs = 0;
  for (unsigned j = 0; j != kPipes; ++j) {
    if (!in.mdat[j]) continue;
    const MiuData &m = *in.mdat[j];
    const bool pred_only = m.dst == kZero && m.pwe;
    if (m.dst == kZero && !pred_only) fail("MIU slot %u's load writes the zero register", j);
    if (m.dst != kZero) {
      const unsigned s = secMask(m.w, m.pos);
      if (s & ~kAllSecs) fail("MIU slot %u's %u-bit load at position %u overruns its row", j, 32u >> m.w, m.pos);
      // One load write per bank a cycle (RA-28 (a)).
      if (s & msecs) fail("two MIU slots write section bank(s) %s in one cycle (RA-28)", secBits(s & msecs).c_str());
      msecs |= s;
      GWrite g{kMW, m.dst, cfg_.full_row ? kAllSecs : s & kAllSecs, m.active, {}, int(j)};
      for (unsigned l = 0; l != kLanes; ++l) g.data[l] = (m.data[l] & elemMask(m.w)) << (8 * m.pos);
      gw.push_back(g);
    }
    if (m.pwe) pw.push_back({kPM, m.ppred, m.active, m.pred_result, kAll, -1, true, int(j)});
  }
  // R, the predicate-only copy, and restores: scheduled at their decision.
  if (auto g = gsched_.find(t); g != gsched_.end()) {
    for (GWrite &w : g->second) gw.push_back(w);
    gsched_.erase(g);
  }
  if (auto p = psched_.find(t); p != psched_.end()) {
    for (PWrite &w : p->second) pw.push_back(w);
    psched_.erase(p);
  }
  // Never two ports on one row, section and lane; never a zero register.
  std::map<unsigned, std::array<uint32_t, kSecs>> taken;
  for (const GWrite &w : gw) {
    if (w.row == kZero || w.row >= kRows) {
      fail("a write (port %u) selects row %u, which has no register (A-64)", w.port, w.row);
      continue;
    }
    auto &tk = taken[w.row];
    for (unsigned k = 0; k != kSecs; ++k)
      if ((w.secs >> k) & 1u) {
        if (tk[k] & w.lanes)
          fail("two write ports on row %u section %u lanes %08x in one cycle", w.row, k, tk[k] & w.lanes);
        tk[k] |= w.lanes;
      }
  }
  std::map<unsigned, uint32_t> ptaken;
  for (PWrite &w : pw) {
    if (w.row == kPZero || w.row >= kPRows) {
      fail("a predicate write (port %u) selects predicate %u, which has no row (A-64)", w.port, w.row);
      continue;
    }
    if (ptaken[w.row] & w.m)
      fail("two predicate write ports on %u share lanes %08x in one cycle", w.row, ptaken[w.row] & w.m);
    ptaken[w.row] |= w.m;
    // The old destination is read at write time, before this cycle's writes.
    const uint32_t old = w.oldrow >= 0 ? rdPred(unsigned(w.oldrow)) : 0u;
    w.val = (old & ~w.mm) | (w.val & w.mm);
    w.mm = kAll;
    w.oldrow = -1;
  }
}

void Core::commit(const std::vector<GWrite> &gw, const std::vector<PWrite> &pw, bool miu) {
  for (const GWrite &w : gw) {
    if ((w.port == kMW) != miu || w.row == kZero || w.row >= kRows) continue;
    const uint32_t bm = byteMask(w.secs);
    auto &row = (*f_.gpr)[w.row];
    for (unsigned l = 0; l != kLanes; ++l)
      if ((w.lanes >> l) & 1u) row[l] = (row[l] & ~bm) | (w.data[l] & bm);
    if (dm_busy_)   // chk_dm_stable (Migration tab)
      for (unsigned a = 0; a != kArchGprs; ++a)
        if (dm_.gpr[a] == w.row) fail("chk_dm_stable: row %u of demoting warp %u written", w.row, dm_.warp);
    if (w.port == kRS) unwritten_.erase(w.row);
    ev(Ev::GprWrite, w.row, w.lanes, w.secs, w.port);
  }
  for (const PWrite &w : pw) {
    if (w.miu != miu || w.row == kPZero || w.row >= kPRows) continue;
    uint32_t &p = (*f_.pred)[w.row];
    p = (p & ~w.m) | (w.val & w.m);
    if (dm_busy_)
      for (unsigned q = 0; q != kArchPreds; ++q)
        if (dm_.pred[q] == w.row) fail("chk_dm_stable: predicate %u of demoting warp %u written", w.row, dm_.warp);
    if (w.port == kPG) unwritten_p_.erase(w.row);
    ++st_.pred_writes;
    ev(Ev::PredWrite, w.row, p, w.m, w.port);
  }
}

// ---- issue checks --------------------------------------------------------------------

void Core::checkIssues(const In &in, std::array<int, kRes> &owner) {
  owner.fill(-1);
  auto seq = [&](unsigned s) { return seqOf(in.iss[s]->tid); };
  for (unsigned s = 0; s != kRes; ++s) {
    if (!in.iss[s]) continue;
    const Issue &is = *in.iss[s];
    if (is.cont) {
      if (is.lead.sec || is.lead.src || is.lead.imm || is.lead.merge)
        fail("seq %llu's continuation on %s carries a lead; a continuation's lead is zero", seq(s), resName(s));
      continue;
    }
    const unsigned base = groupOf(s);
    if (base == kSlotR) {
      if (is.foot) fail("seq %llu holds R with footprint %s; R takes none", seq(s), secBits(is.foot).c_str());
      owner[s] = int(s);
      continue;
    }
    for (unsigned b = 0; b != kSecs; ++b) {
      if (!((is.foot >> b) & 1u)) continue;
      const unsigned t = base + b;
      if (owner[t] >= 0) {
        fail("V-60: seq %llu's footprint %s overlaps seq %llu's at %s", seq(s), secBits(is.foot).c_str(),
             seq(unsigned(owner[t])), resName(t));
        continue;
      }
      owner[t] = int(s);
    }
    if (!is.foot || base + lowest(is.foot) != s)
      fail("seq %llu sits in %s, which is not its footprint %s's lowest", seq(s), resName(s),
           secBits(is.foot).c_str());
  }
  for (unsigned s = 0; s != kRes; ++s) {
    if (!in.iss[s]) continue;
    const int o = owner[s];
    if (o < 0) fail("%s carries seq %llu outside every footprint", resName(s), seq(s));
    else if (unsigned(o) != s && (!in.iss[s]->cont || in.iss[s]->tag != in.iss[unsigned(o)]->tag))
      fail("%s, in seq %llu's footprint, carries no continuation of it", resName(s), seq(unsigned(o)));
  }
  for (unsigned s = 0; s != kRes; ++s)
    if (owner[s] >= 0 && unsigned(owner[s]) != s && !in.iss[s])
      fail("%s, in seq %llu's footprint, carries nothing", resName(s), seq(unsigned(owner[s])));

  for (unsigned s = 0; s != kRes; ++s) {
    if (!in.iss[s] || in.iss[s]->cont) continue;
    const Issue &is = *in.iss[s];
    const OpClass &oc = is.oc;
    // Each class on its own resources.
    const unsigned want = oc.unit == Unit::Mem ? kSlotP0
                          : oc.unit == Unit::ROnly || oc.unit == Unit::Coll ? kSlotR : kSlotS0;
    if (groupOf(s) != want)
      fail("seq %llu issued on %s; its class issues on %s", seq(s), resName(s),
           want == kSlotS0 ? "S0-S3" : want == kSlotP0 ? "P0-P3" : "R");
    // The lead's promises (RA-31; Partition tab, superset rule): a clear
    // bit says the op does not use that group, which RCU then never loads.
    const char *why = (is.foot & ~is.lead.sec) ? "a section outside its lead's mask"
                      : (oc.reads & ~is.lead.src) ? "a source its lead says is unused"
                      : oc.imm_used && !is.lead.imm ? "an immediate its lead says is unused"
                      : is.merge && !is.lead.merge ? "a merge its lead says is unused"
                      : s == kSlotR && oc.guarded && (!is.lead.guard || is.lead.gpred != is.pguard)
                          ? "a guard its lead does not name"
                      : nullptr;
    if (why)
      fail("seq %llu, %s, reads %s (lead sections %s, sources %s)", seq(s), is.name, why,
           secBits(is.lead.sec).c_str(), secBits(is.lead.src).c_str());
    // Every register named fits its row.
    auto fits = [&](const char *what, unsigned w, unsigned pos) {
      if (secMask(w, pos) & ~kAllSecs)
        fail("seq %llu's %s, a %u-bit register at position %u, overruns its row", seq(s), what, 32u >> w, pos);
    };
    if (oc.gdst || oc.unit == Unit::Copy) fits("destination", is.dst_w, is.dst_pos);
    if (is.merge) fits("old destination", is.dst_w, is.old_pos);
    for (unsigned i = 0; i != 3; ++i)
      if ((oc.reads >> i) & 1u) fits("source", is.src_w[i], is.src_pos[i]);
    // A restored warp's registers are read only once their rows are written
    // (TI-13): done means written.
    for (unsigned i = 0; i != 3; ++i)
      if (((oc.reads >> i) & 1u) && unwritten_.count(is.src[i]))
        fail("seq %llu reads row %u before its restore row is written", seq(s), is.src[i]);
    if ((oc.guarded || oc.pdata) && unwritten_p_.count(is.pguard))
      fail("seq %llu reads predicate %u before its restore row is written", seq(s), is.pguard);
    if (oc.unit != Unit::Copy && oc.unit != Unit::PredCopy &&
        ((oc.gdst && is.dst == kZero) || (is.pwe && is.pdst == kPZero)))
      fail("seq %llu writes a zero register", seq(s));
  }
}

// ---- the cycle -------------------------------------------------------------------------

void Core::cycle(uint64_t t, const In &in, Out &out) {
  now_ = t;
  const std::string &brk = cfg_.brk;
  std::vector<GWrite> gw;
  std::vector<PWrite> pw;
  gatherWrites(t, in, gw, pw);
  gnow_ = gw;
  pnow_ = pw;
  // no-rcu-bypass: every read sees the register file before this cycle's
  // writes, as the S1 RCU did, so an L1 hit's dependant reads stale data.
  const bool late = brk == "no-rcu-bypass";
  if (!late) commit(gw, pw, true);   // MIU's writes: the guard's and R0/R1's forward

  std::array<int, kRes> owner;
  checkIssues(in, owner);

  // Stage I (A): guards, active, predicate sources, R0/R1.
  struct AState { uint32_t active = 0, guardv = 0, rpa = 0, rpb = 0, pstore = 0; Word r0{}, r1{}; };
  std::array<AState, kRes> a{};
  for (unsigned s = 0; s != kRes; ++s) {
    if (!in.iss[s] || in.iss[s]->cont) continue;
    const Issue &is = *in.iss[s];
    const OpClass &oc = is.oc;
    AState &x = a[s];
    if ((oc.guarded || oc.pdata) && hazardP(is.pguard))
      fail("seq %llu's guard %u is written by a non-MIU port in its own A", seqOf(is.tid),
           is.pguard);
    for (const PWrite &w : pnow_)
      if (w.miu && w.row == is.pguard && (oc.guarded || oc.pdata)) ev(Ev::GuardFwd, s, unsigned(w.slot), w.row);
    const uint32_t g = rdPred(is.pguard);
    x.guardv = is.pneg ? ~g : g;
    // pdata-guard: a predicate read as data taken as a guard too (TI-36 (c)).
    const bool gated = oc.guarded || (brk == "pdata-guard" && oc.pdata);
    x.active = is.issue_mask & (gated ? x.guardv : kAll);
    if (oc.mk == MemKind::PredStore) x.pstore = g;   // the raw row, no negate
    if (s == kSlotR) {
      // Predicate sources in imm (TI-1): [5:0] and its negate [6], then
      // [12:7] and [13]. arch-pred-srcs reads DEC's qualifiers instead.
      constexpr unsigned w = ccv::prov::kWPhysPred;
      auto psrc = [&](uint32_t q) {
        const unsigned p = q & ((1u << w) - 1);
        if (hazardP(p)) fail("seq %llu's predicate source %u is written in its own A", seqOf(is.tid), p);
        const uint32_t v = rdPred(p);
        return (q >> w) & 1u ? ~v : v;
      };
      if (oc.rk == RKind::Pand || oc.rk == RKind::Por || oc.rk == RKind::Pxor || oc.rk == RKind::VoteAny ||
          oc.rk == RKind::VoteAll || oc.rk == RKind::Ballot) {
        x.rpa = psrc(is.imm);
        x.rpb = psrc(is.imm >> (w + 1));
        if (brk == "arch-pred-srcs") {
          auto arch = [&](uint32_t q) {
            const uint32_t v = rdPred(q & 3);
            return (q >> 2) & 1u ? ~v : v;
          };
          x.rpa = arch(is.imm & 7);
          x.rpb = arch((is.imm >> 3) & 7);
        }
      }
      // R0 and R1 are read in A (RA-39), with MIU's forward.
      for (unsigned i = 0; i != 2; ++i) {
        if (!((oc.reads >> i) & 1u)) continue;
        if (hazardG(is.src[i], secMask(is.src_w[i], is.src_pos[i])))
          fail("seq %llu's R%u source row %u is written by a non-MIU port in its own A",
               seqOf(is.tid), i, is.src[i]);
        for (const GWrite &w : gnow_)
          if (w.port == kMW && w.row == is.src[i]) ev(Ev::RsrcFwd, i, unsigned(w.slot), w.row);
        (i == 0 ? x.r0 : x.r1) = rdReg(is.src[i], is.src_pos[i], is.src_w[i]);
      }
    }
  }
  if (!late) commit(gw, pw, false);

  // Stage R (A+1 reads; the model launches everything in A).
  LaneMsg msg;
  bool any_lane = false;
  std::vector<LaneDesc> descs;
  // late-copy's held copies whose time has come join this cycle's message.
  for (auto it = late_.begin(); it != late_.end();) {
    if (it->at > t) { ++it; continue; }
    bool clash = false;
    for (unsigned k = 0; k != kSecs; ++k)
      if (((it->d.secs >> k) & 1u) && msg.sec[k].en) clash = true;
    if (clash) { ++it; continue; }
    for (unsigned k = 0; k != kSecs; ++k)
      if ((it->d.secs >> k) & 1u) {
        msg.sec[k] = it->msg.sec[k];
        for (unsigned l = 0; l != kLanes; ++l) {
          for (unsigned i = 0; i != kPorts; ++i)
            msg.opnd[l][i] = (msg.opnd[l][i] & ~byteMask(1u << k)) | (it->msg.opnd[l][i] & byteMask(1u << k));
          msg.pred_bit[l] |= it->msg.pred_bit[l] & (1u << k);
        }
      }
    if (!any_lane) msg.tid = it->msg.tid;
    any_lane = true;
    LaneDesc d = it->d;
    d.a = t;
    descs.push_back(d);
    if (!d.copy && d.gdst && !d.sfu) hist_.push_back({t, d.dst, d.dst_pos, secMask(d.dst_w, d.dst_pos), d.lead});
    it = late_.erase(it);
  }
  while (!hist_.empty() && t - hist_.front().a > kBypHi) hist_.pop_front();

  const bool movi_lane = brk == "movi-in-lane";
  for (unsigned s = 0; s != kRes; ++s) {
    if (!in.iss[s] || in.iss[s]->cont) continue;
    Issue is = *in.iss[s];
    const AState &x = a[s];
    if (movi_lane && is.oc.rk == RKind::Movi) {
      // movi-in-lane: the movi goes to the lanes, which must refuse it.
      is.oc.unit = Unit::Lane;
      is.oc.imm_slot = 0;
      is.foot = kAllSecs;
    }
    switch (is.oc.unit) {
    case Unit::Mem:
      ++st_.memops;
      issueMem(is, s - kSlotP0, x.active, x.pstore, out);
      continue;
    case Unit::ROnly:
    case Unit::Coll:
      ++st_.r_ops;
      issueR(t, is, x.active, x.r0, x.r1, x.rpa, x.rpb, out);
      continue;
    case Unit::PredCopy: {
      // ld.pred's copy (TI-36 (b)) never reaches a lane: PC writes the
      // predicate at A+2, its inactive lanes from the old destination.
      // drop-pred-copy drops it.
      h_.hit("pred_copy");
      if (brk != "drop-pred-copy")
        psched_[t + kRW].push_back({kPC, is.pdst, ~x.active, 0, 0, int(is.pold), false});
      continue;
    }
    case Unit::Lane:
    case Unit::Sfu:
    case Unit::Copy:
      break;
    }
    // A lane op: its sections of the lane message (Lane and memory tab).
    const bool copy = is.oc.unit == Unit::Copy;
    const unsigned lead = s == kSlotR ? 0 : s - kSlotS0;
    if (copy) {
      if (!is.merge) fail("a copy-only op without merge_en has nothing to copy");
      if (is.pwe) fail("a copy-only op with a predicate destination is not modelled");
      if (is.dst == kZero) fail("a copy-only op writes the zero register");
    }
    ++st_.lane_ops;
    LaneMsg own;
    std::array<unsigned, kPorts> rows{}, pos{}, wid{};
    std::array<bool, kPorts> rd{};
    for (unsigned i = 0; i != 3; ++i) {
      rows[i] = is.src[i];
      pos[i] = is.src_pos[i];
      wid[i] = is.src_w[i];
      rd[i] = !copy && ((is.oc.reads >> i) & 1u);
    }
    // The merge port: the old destination (A-33). wrong-merge reads the
    // second source; copy-from-new the copy's fresh destination.
    rows[kMergePort] = brk == "wrong-merge" ? is.src[1] : copy && brk == "copy-from-new" ? is.dst : is.old_dst;
    pos[kMergePort] = is.old_pos;
    wid[kMergePort] = is.dst_w;
    rd[kMergePort] = is.merge;
    // The bypass (A-59): a source a lane producer of age 4-5 has yet to
    // write; younger is a contract breach, older is in the PRF.
    std::array<unsigned, kPorts> byp{};
    bool fwd = false;
    for (unsigned i = 0; i != kPorts; ++i) {
      if (!rd[i] || rows[i] == kZero) continue;
      int hits = 0;
      for (const Producer &p : hist_) {
        if (p.row != rows[i]) continue;
        const uint64_t age = t - p.a;
        if (age < kBypLo) {
          fail("seq %llu reads operand %u %llu cycles after its lane producer; CCV_LAT_LANE_BYP is %u",
               seqOf(is.tid), i, (unsigned long long)age, kBypLo);
          continue;
        }
        if (p.pos != pos[i]) continue;
        ++hits;
        const unsigned sel = 1u | p.lead << 1 | unsigned(age - kBypLo) << (1 + kBypSecBits);
        if (brk != "no-lane-bypass") byp[i] = sel;
        fwd = true;
        ++st_.byp_sels;
        ev(Ev::BypassSel, s, i, sel, is.foot);
      }
      if (hits > 1) fail("seq %llu's operand %u matches %d producers", seqOf(is.tid), i, hits);
    }
    if (fwd) h_.hit("lane_byp");
    for (unsigned k = 0; k != kSecs; ++k) {
      if (!((is.foot >> k) & 1u)) continue;
      LaneSec &sc = own.sec[k];
      sc.en = true;
      sc.owner = lead;
      sc.opcode = is.opcode;
      for (unsigned i = 0; i != kPorts; ++i) {
        sc.pos[i] = pos[i];
        sc.w[i] = wid[i];
        sc.byp[i] = byp[i];
      }
      // The immediate's port takes the lead section as its position.
      if (is.oc.imm_slot >= 0) sc.pos[unsigned(is.oc.imm_slot)] = lead;
      sc.dst_pos = is.dst_pos;
      sc.dst_w = is.dst_w;
    }
    const uint32_t bm = byteMask(is.foot);
    for (unsigned l = 0; l != kLanes; ++l) {
      for (unsigned i = 0; i != kPorts; ++i) {
        uint32_t v = 0;
        if (int(i) == is.oc.imm_slot) v = lead == 0 ? is.imm : is.imm << (8 * lead);
        else if (rd[i]) v = rdGpr(rows[i], l);
        own.opnd[l][i] = v & bm;
      }
      if ((x.active >> l) & 1u) own.pred_bit[l] = uint8_t(is.foot);
      if (is.oc.pdata && brk != "drop-pred-data" && ((x.guardv >> l) & 1u)) own.pred_data[l] = uint8_t(is.foot);
    }
    LaneDesc d{lead, is.foot, copy || is.oc.gdst, copy, is.pwe && !copy, is.merge, is.oc.unit == Unit::Sfu,
               is.dst, is.dst_pos, is.dst_w, is.pdst, is.pold, x.active, is.tag, is.done_row, is.tid, t, t};
    // late-copy: the copy waits CCV_LAT_LANE cycles, landing after the
    // contract OOE wakes the load's readers on.
    own.tid = is.tid;
    if (copy && brk == "late-copy") {
      late_.push_back({t + ccv::prov::kLatLane, own, d});
      continue;
    }
    if (movi_lane && in.iss[s]->oc.rk == RKind::Movi) {
      // The misplaced movi leaves R's pipe for the lanes at A+2, R's write
      // cycle, and completes on R's slot. Lane ops issued after it queue
      // behind it in order, as the stub's one-message-a-cycle lane queue
      // does, so the control's late dones are the stub's.
      d.dslot = int(kDoneRcu);
      late_.push_back({t + kRW, own, d});
      movi_a_ = t;
      movi_hold_ = t + kRW;
      continue;
    }
    if (movi_lane && t > movi_a_ && t <= movi_hold_) {
      late_.push_back({movi_hold_ + 1, own, d});
      movi_hold_ = movi_hold_ + 1;
      continue;
    }
    for (unsigned k = 0; k != kSecs; ++k)
      if ((is.foot >> k) & 1u) msg.sec[k] = own.sec[k];
    for (unsigned l = 0; l != kLanes; ++l) {
      for (unsigned i = 0; i != kPorts; ++i) msg.opnd[l][i] |= own.opnd[l][i];
      msg.pred_bit[l] |= own.pred_bit[l];
      msg.pred_data[l] |= own.pred_data[l];
    }
    if (!any_lane) msg.tid = is.tid;
    any_lane = true;
    descs.push_back(d);
    // A lane producer of a GPR enters the bypass history (copies never do).
    if (!copy && is.oc.gdst && is.oc.unit == Unit::Lane)
      hist_.push_back({t, is.dst, is.dst_pos, secMask(is.dst_w, is.dst_pos), lead});
  }
  if (any_lane) {
    if (!in.lane_can) fail("rcu_lane_ops sent without a credit (a fixed-latency channel)");
    out.lane = msg;
    for (const LaneDesc &d : descs) {
      const uint64_t w = d.a + (d.sfu ? kSfuW : kLaneW);
      lanes_[w].push_back(d);
      if (d.copy) continue;   // a copy completes on the load's (OI-4)
      Done dn{d.dslot >= 0 ? unsigned(d.dslot) : d.sfu ? kDoneSfu : d.lead, d.tag, d.done_row};
      dn.tid = d.tid;
      if (brk == "slot-field-aux") dn.aux_set = true;
      dsched_[w - 1].push_back(dn);
    }
  }

  // Dones launched this cycle: lane ops' at A+5 from their descriptors.
  if (auto dd = dsched_.find(t); dd != dsched_.end()) {
    for (Done &d : dd->second) out.dones.push_back(d);
    dsched_.erase(dd);
  }
  {
    unsigned used = 0;
    for (Done &d : out.dones) {
      if (brk == "done-row") d.row = (d.row + 1) & 3u;
      if (d.slot >= kDoneSlots) { fail("done slot %u", d.slot); continue; }
      if ((used >> d.slot) & 1u) fail("two dones on slot %u in one cycle", d.slot);
      used |= 1u << d.slot;
    }
    // rcu-done-pool: the RCU-only class takes the lowest slot free of the rest.
    if (brk == "rcu-done-pool")
      for (Done &d : out.dones)
        if (d.slot == kDoneRcu) {
          unsigned s = 0;
          while (s < kDoneSlots && ((used >> s) & 1u)) ++s;
          if (s < kDoneSlots) { used |= 1u << s; d.slot = s; }
        }
    for (const Done &d : out.dones) {
      if (d.slot < kDoneSlots && !in.done_can[d.slot])
        fail("done on slot %u without a credit (a fixed-latency channel)", d.slot);
      ++st_.dones;
    }
  }

  // Migration, on the R ports this cycle's R op leaves free.
  bool r2_busy = false, rw_busy = false;
  if (in.iss[kSlotR] && !in.iss[kSlotR]->cont) {
    const Issue &r = *in.iss[kSlotR];
    r2_busy = r.merge && r.oc.gdst;
    rw_busy = r.oc.gdst || r.oc.unit == Unit::Coll;
  }
  migrate(t, in, r2_busy, rw_busy, out);

  if (late) {
    commit(gw, pw, true);
    commit(gw, pw, false);
  }

  // The kill drain (Done tab): KILL_DRAIN, loaded at K's edge, to 0.
  if (drain_ && !drain_loaded_) --drain_;
  drain_loaded_ = false;
  if (kill_pend_ && killQuiet()) { ev(Ev::KillAck, kill_epoch_); kill_pend_ = false; }

  // rcu_idle_q: nothing valid in any stage and nothing pending.
  bool input = in.lres.has_value() || in.map || in.cmd || in.pca;
  for (const auto &i : in.iss) input = input || i.has_value();
  for (const auto &m : in.mdat) input = input || m.has_value();
  const bool sent = out.lane || !out.dones.empty() || !out.addrs.empty() || out.pca;
  bool dead = false;
  for (const FifoEnt &e : fifo_) dead = dead || e.dead;
  const bool idle = !input && !sent && gsched_.empty() && psched_.empty() && lanes_.empty() && dsched_.empty() &&
                    late_.empty() && hist_.empty() && !dm_busy_ && !rs_busy_ && !dead && drain_ == 0 &&
                    !map_drops_ && !cmd_drops_ && !pca_pop_ && rpop_.empty();
  if (idle != idle_) ev(idle ? Ev::Idle : Ev::Wake);
  idle_ = idle;
  if (idle) ++idle_cycles_;
}

// ---- memops ----------------------------------------------------------------------

void Core::issueMem(const Issue &is, unsigned slot, uint32_t active, uint32_t pstore, Out &out) {
  // Valid at A+1 on the memop's lead pipe's slot (RA-21; CCV_LAT_RCU_ADDR_BASE
  // = 1, PF-47). Operands right-aligned at their width and position; a
  // missing one is 0. A fence carries only rob_tag and active_mask.
  Addr ad;
  ad.slot = slot;
  ad.tag = is.tag;
  ad.active = active;
  ad.tid = is.tid;
  const OpClass &oc = is.oc;
  auto opnd = [&](int src) {
    return rdReg(is.src[unsigned(src)], is.src_pos[unsigned(src)], is.src_w[unsigned(src)]);
  };
  if (oc.mk != MemKind::Fence) {
    if (oc.base_src >= 0) {
      ad.base = opnd(oc.base_src);
      if (cfg_.brk == "scalar-base") ad.base.fill(ad.base[0]);
    }
    if (oc.index_src >= 0) ad.index = opnd(oc.index_src);
    if (oc.mk == MemKind::PredStore) ad.data[0] = pstore;   // lane 0, raw (TI-36)
    else if (oc.mk == MemKind::Store && oc.data_src >= 0) ad.data = opnd(oc.data_src);
  }
  out.addrs.push_back(ad);
}

// ---- the R pipe ----------------------------------------------------------------------

void Core::issueR(uint64_t t, const Issue &is, uint32_t active, const Word &r0, const Word &r1, uint32_t rpa,
                  uint32_t rpb, Out &out) {
  const OpClass &oc = is.oc;
  const uint32_t em = elemMask(is.dst_w);
  // R2, the old destination, read in A+1 when the write merges into a GPR.
  Word old{};
  if (is.merge && oc.gdst) old = rdReg(is.old_dst, is.old_pos, is.dst_w);
  Word gnew{};
  uint32_t glanes = active;   // the lanes the GPR result is written on
  bool pw = false;
  uint32_t pval = 0, pmm = is.issue_mask;
  Done d{oc.unit == Unit::Coll ? kDoneColl : kDoneRcu, is.tag, is.done_row};
  d.tid = is.tid;
  auto shfl = [&](auto idxOf) {
    for (unsigned l = 0; l != kLanes; ++l) gnew[l] = r0[idxOf(l) & 31u] & em;
  };
  switch (oc.rk) {
  case RKind::Bra:
  case RKind::Call:
    d.bt = active != 0;
    d.bm = active;
    d.lbt = d.bt != (cfg_.brk == "lead-corrupt");
    d.lbm = active;
    // call's link: OOE puts pc + length in imm (imm_kind 6; RA-18).
    if (oc.rk == RKind::Call)
      for (unsigned l = 0; l != kLanes; ++l) gnew[l] = is.imm & em;
    break;
  case RKind::Ret: {
    // aux: the lowest active lane's rs; branch_mask: the active lanes whose
    // rs equals it. The leads are don't-care, and 0.
    const unsigned lo = lowest(active);
    d.aux = lo < kLanes ? r0[lo] : 0u;
    for (unsigned l = 0; l != kLanes; ++l)
      if (((active >> l) & 1u) && r0[l] == d.aux) d.bm |= 1u << l;
    d.bt = active != 0;
    break;
  }
  case RKind::Pand: pw = true; pval = rpa & rpb; break;
  case RKind::Por: pw = true; pval = rpa | rpb; break;
  case RKind::Pxor: pw = true; pval = rpa ^ rpb; break;
  case RKind::PmovImm:   // merged by the issue mask (RA-19); pmov-all-lanes writes all 32
    pw = true;
    pval = is.imm;
    if (cfg_.brk == "pmov-all-lanes") pmm = kAll;
    break;
  case RKind::Movi:
    for (unsigned l = 0; l != kLanes; ++l) gnew[l] = is.imm & em;
    break;
  case RKind::ShflIdxImm: shfl([&](unsigned) { return is.imm; }); break;
  case RKind::ShflIdxReg: shfl([&](unsigned l) { return r1[l]; }); break;
  case RKind::ShflUp:
  case RKind::ShflDown:
  case RKind::ShflBfly: {
    // Out of 0..31 the lane keeps its own (O-85).
    const unsigned c = is.imm & 31u;
    shfl([&](unsigned l) {
      const int j = oc.rk == RKind::ShflUp ? int(l) - int(c) : oc.rk == RKind::ShflDown ? int(l + c) : int(l ^ c);
      return j < 0 || j >= int(kLanes) ? l : unsigned(j);
    });
    break;
  }
  case RKind::VoteAny:
  case RKind::VoteAll: {
    const bool r = oc.rk == RKind::VoteAny ? (rpa & active) != 0 : (rpa & active) == active;
    pw = true;
    pval = r ? kAll : 0u;
    pmm = active;
    break;
  }
  case RKind::Ballot:
    for (unsigned l = 0; l != kLanes; ++l) gnew[l] = (rpa & active) & em;
    break;
  case RKind::Unballot: {
    // Diagonal (O-85): lane l's bit l of its own rs, 0 past rs's width.
    const unsigned bits = 32u >> is.src_w[0];
    pw = true;
    pval = 0;
    for (unsigned l = 0; l != kLanes && l < bits; ++l) pval |= ((r0[l] >> l) & 1u) << l;
    pmm = active;
    break;
  }
  case RKind::None:
    fail("seq %llu on R has no R kind", seqOf(is.tid));
    break;
  }
  if (pw && !is.pwe) fail("seq %llu writes a predicate without pred_we", seqOf(is.tid));
  if (pw && is.pwe)
    psched_[t + kRW].push_back({kPR, is.pdst, kAll, pval, pmm, is.merge ? int(is.pold) : -1, false});
  if (oc.gdst) {
    // RW at A+2: steer(merge(new, old, active), pos) into the destination's
    // sections, every lane.
    GWrite g{kRWp, is.dst, cfg_.full_row ? kAllSecs : secMask(is.dst_w, is.dst_pos) & kAllSecs, kAll, {}};
    for (unsigned l = 0; l != kLanes; ++l) {
      const uint32_t v = ((glanes >> l) & 1u) ? gnew[l] : old[l];
      g.data[l] = (v & em) << (8 * is.dst_pos);
    }
    gsched_[t + kRW].push_back(g);
  }
  if (pw) {
    const uint32_t old = is.merge ? rdPred(is.pold) : 0u;
    pval = (old & ~pmm) | (pval & pmm);
  }
  h_.rResult(is, glanes, gnew, em, pw, pval);
  if (oc.rk == RKind::Bra || oc.rk == RKind::Call || oc.rk == RKind::Ret) {
    ev(Ev::Branch, is.tag, d.bt, d.bm, d.aux);
    h_.branch(is, d, active);
  }
  if (cfg_.brk == "slot-field-aux" && d.slot != kDoneRcu) d.aux_set = true;
  out.dones.push_back(d);
}

// ---- migration ------------------------------------------------------------------------

void Core::migrate(uint64_t t, const In &in, bool r2_busy, bool rw_busy, Out &out) {
  // Restore writes that landed this cycle pop their FIFO entries; the credit
  // is on the wire next cycle (TI-13: a credit means written).
  bool popped = false;
  if (auto p = rpop_.find(t); p != rpop_.end()) {
    rpop_.erase(p);
    if (fifo_.empty() || rs_inflight_ == 0) {
      fail("restore FIFO pop with nothing in flight");
    } else {
      const MigRow r = fifo_.front().r;
      fifo_.pop_front();
      --rs_inflight_;
      popped = true;
      ++st_.restore_rows;
      ev(Ev::MigRowIn, r.warp, r.row);
      if (r.row == kArchGprs && rs_busy_ && r.warp == rs_.warp) {
        // The predicate row closes the transfer (PCA sends it last).
        rs_busy_ = false;
        rs_last_ = false;
        st_.max_restore_cycles = std::max<uint64_t>(st_.max_restore_cycles, t - rs_start_);
        ev(Ev::RestoreDone, r.warp);
        h_.restored(rs_);
      }
    }
  }
  // A dead head row pops without a write, one credit a cycle.
  if (!popped && rs_inflight_ == 0 && !fifo_.empty() && fifo_.front().dead) {
    fifo_.pop_front();
    popped = true;
  }
  out.pca_credit = popped;

  // Launch, from the picks flopped last cycle.
  auto launch = [&](Pick &pk, unsigned dir) {
    MapEnt *me = nullptr;
    CmdEnt *ce = nullptr;
    for (auto &m : mq_) if (m.id == pk.mi) me = &m;
    for (auto &c : cq_) if (c.id == pk.ci) ce = &c;
    if (!me || !ce) return false;   // dropped by a kill since
    if (dir == 0) {
      dm_busy_ = true;
      dm_ = me->m;
      dm_row_ = 0;
      dm_wcnt_ = ccv::kWakeLat - 1;
      dm_start_ = t;
    } else {
      rs_busy_ = true;
      rs_ = me->m;
      rs_next_ = 0;
      rs_start_ = t;
    }
    ev(Ev::MigPair, me->m.warp, dir);
    const unsigned mid = me->id, cid = ce->id;
    mq_.erase(std::remove_if(mq_.begin(), mq_.end(), [&](const MapEnt &m) { return m.id == mid; }), mq_.end());
    cq_.erase(std::remove_if(cq_.begin(), cq_.end(), [&](const CmdEnt &c) { return c.id == cid; }), cq_.end());
    ++map_drops_;   // a launch returns both channels' credits next cycle
    ++cmd_drops_;
    return true;
  };
  if (dpick_.v && !dm_busy_) launch(dpick_, 0);
  if (rpick_.v && !rs_busy_ && !fifo_.empty() && !fifo_.front().dead && fifo_.front().r.warp == rpick_.warp)
    launch(rpick_, 1);
  else if (!rs_busy_ && !fifo_.empty() && !fifo_.front().dead) {
    ++st_.restore_holds;
    ev(Ev::RestoreHold, fifo_.front().r.warp);
  }

  // Demotion: a row a cycle, when R leaves R2 free (or the predicate row,
  // which reads D0-D3), there is a credit, and the wake has led by
  // CCV_WAKE_LAT. Read in A+1, sent valid A+1, payload A+2.
  if (dm_busy_ && dm_wcnt_ == 0 && dm_row_ <= kArchGprs) {
    const bool prow = dm_row_ == kArchGprs;
    if (!prow && r2_busy) {
      ++st_.mig_r_waits;
      ev(Ev::MigWaitR, dm_.warp, dm_row_);
    } else if (!in.pca_can_send) {
      ++st_.mig_credit_waits;
      ev(Ev::MigWaitCredit, dm_.warp, dm_row_);
    } else {
      MigRow r;
      r.warp = dm_.warp;
      if (prow) {
        for (unsigned p = 0; p != kArchPreds; ++p) r.data[p] = dm_.pred[p] == kPZero ? 0u : rdPred(dm_.pred[p]);
      } else {
        const unsigned g = dm_.gpr[dm_row_];
        for (unsigned l = 0; l != kLanes; ++l) r.data[l] = g == kZero ? 0u : rdGpr(g, l);
      }
      // mig-row-order: GPR rows numbered from the end.
      r.row = !prow && cfg_.brk == "mig-row-order" ? kArchGprs - 1 - dm_row_ : dm_row_;
      out.pca = r;
      ++st_.demote_rows;
      ev(Ev::MigRowOut, r.warp, r.row);
      if (prow) {
        dm_busy_ = false;
        st_.max_demote_cycles = std::max<uint64_t>(st_.max_demote_cycles, t - dm_start_);
      }
      ++dm_row_;
    }
  }
  // The launch cycle is c1 (the launch edge ended the pick's c0), whose
  // edge already counts: the first decision is c4 (Migration tab, wake lead).
  if (dm_busy_ && dm_wcnt_) --dm_wcnt_;

  // Restore: decide the next FIFO row of the warp in A, write it in A+2 on
  // RW when R writes no GPR (PG0-PG3 for the predicate row).
  if (rs_busy_ && !rs_last_ && fifo_.size() > rs_inflight_) {
    const FifoEnt &e = fifo_[rs_inflight_];
    if (!e.dead) {
      if (e.r.warp != rs_.warp) {
        fail("restore of warp %u: a row of warp %u before its predicate row (RA-28 (b))", rs_.warp, e.r.warp);
      } else {
        // Rows 0..16 in order is PCA's contract (RA-28 (b)), asserted; the
        // write still goes by the row's own mig_row, decoded at land.
        if (e.r.row != rs_next_)
          fail("restore of warp %u: row %u where row %u is next (RA-28 (b))", rs_.warp, e.r.row, rs_next_);
        const bool prow = e.r.row == kArchGprs;
        if (!prow && rw_busy) {
          ++st_.mig_r_waits;
          ev(Ev::MigWaitR, rs_.warp, e.r.row);
        } else {
          if (prow) {
            for (unsigned p = 0; p != kArchPreds; ++p)
              psched_[t + kRW].push_back({kPG, rs_.pred[p], kAll, e.r.data[p], kAll, -1, false});
            rs_last_ = true;
          } else {
            gsched_[t + kRW].push_back({kRS, rs_.gpr[e.r.row], kAllSecs, kAll, e.r.data});
          }
          rpop_[t + kRW] = 1;
          ++rs_inflight_;
          rs_next_ = e.r.row + 1;
        }
      }
    }
  }

  // Landing: a map, a command or a PCA row in its payload cycle, visible
  // to the pick from the next cycle.
  if (in.map) {
    const MapMsg &m = *in.map;
    if (m.dir == 1)
      for (unsigned i = 0; i != kArchGprs; ++i) {
        if (m.gpr[i] == kZero) fail("warp %u's restore map names the zero register (A-64)", m.warp);
        for (unsigned j = 0; j != i; ++j)
          if (m.gpr[j] == m.gpr[i]) fail("warp %u's restore map gives R%u and R%u one row", m.warp, j, i);
      }
    if (mq_.size() >= kPairDepth) fail("a map lands with the pairing queue full (RA-28 (d))");
    // A restore's rows are unwritten from its map's landing (TI-13): OOE
    // may issue the warp's readers once RAU says done, never before the
    // rows are written, whether or not the restore has launched.
    if (m.dir == 1) {
      for (unsigned g : m.gpr) unwritten_.insert(g);
      for (unsigned p : m.pred) unwritten_p_.insert(p);
    }
    mq_.push_back({m, t, next_id_++});
    kmask_ &= ~(1u << m.warp);
  }
  if (in.cmd) {
    if (cq_.size() >= kPairDepth) fail("a command lands with the pairing queue full (RA-28 (d))");
    cq_.push_back({*in.cmd, t, next_id_++});
  }
  if (in.pca) {
    if (fifo_.size() >= kFifoDepth) fail("restore FIFO overrun");
    fifo_.push_back({*in.pca, ((kmask_ >> in.pca->warp) & 1u) != 0});
  }

  // The picks for the next cycle: the lowest (oldest) map entry with a
  // matching command, per direction, from entries landed before this cycle.
  for (unsigned dir = 0; dir != 2; ++dir) {
    Pick pk;
    for (const MapEnt &m : mq_) {
      if (pk.v) break;
      if (m.m.dir != dir || m.landed >= t) continue;
      for (const CmdEnt &c : cq_)
        if (c.c.dir == dir && c.c.warp == m.m.warp && c.landed < t) {
          pk = {true, m.id, c.id, m.m.warp};
          break;
        }
    }
    (dir == 0 ? dpick_ : rpick_) = pk;
  }

  // Credits: one per channel a cycle (a kill may free several entries).
  out.map_credit = map_drops_ != 0;
  out.cmd_credit = cmd_drops_ != 0;
  if (map_drops_) --map_drops_;
  if (cmd_drops_) --cmd_drops_;
}

void Core::kill(uint32_t mask, unsigned epoch) {
  drain_ = killDrain();
  drain_loaded_ = true;
  ev(Ev::KillDrain, mask, epoch, drain_);
  kill_pend_ = true;
  kill_epoch_ = epoch;
  kmask_ |= mask;
  auto killed = [&](unsigned w) { return ((mask >> w) & 1u) != 0; };
  // Unpaired entries of killed warps are dropped, their credits returned.
  for (auto it = mq_.begin(); it != mq_.end();)
    if (killed(it->m.warp)) {
      if (it->m.dir == 1) {
        for (unsigned g : it->m.gpr) unwritten_.erase(g);
        for (unsigned p : it->m.pred) unwritten_p_.erase(p);
      }
      it = mq_.erase(it);
      ++map_drops_;
    }
    else ++it;
  for (auto it = cq_.begin(); it != cq_.end();)
    if (killed(it->c.warp)) { it = cq_.erase(it); ++cmd_drops_; }
    else ++it;
  if (dpick_.v && killed(dpick_.warp)) dpick_.v = false;
  if (rpick_.v && killed(rpick_.warp)) rpick_.v = false;
  // A demotion stops at a row boundary.
  if (dm_busy_ && killed(dm_.warp)) dm_busy_ = false;
  // A restore stops; its FIFO rows are dead and drain without a write.
  if (rs_busy_ && killed(rs_.warp)) {
    rs_busy_ = false;
    rs_last_ = false;
    unwritten_.clear();
    unwritten_p_.clear();
  }
  for (size_t i = rs_inflight_; i < fifo_.size(); ++i)
    if (killed(fifo_[i].r.warp)) fifo_[i].dead = true;
}

bool Core::killQuiet() const {
  if (drain_ != 0) return false;
  for (const FifoEnt &e : fifo_)
    if (e.dead) return false;
  return true;
}

} // namespace rcu
} // namespace ccv
