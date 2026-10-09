//===-- ooe_core.cpp - the OOE microarchitecture, port-agnostic ----------===//
//
// See ooe_core.h. Section names follow the design doc
// (docs/design-snapshots/ooe-microarchitecture.md); decisions the doc leaves
// open are in docs/ooe-model.md and cited here by its section names.
//===----------------------------------------------------------------------===//
#include "ooe_core.h"

#include <algorithm>
#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <set>
#include <sstream>

namespace ccv {
namespace ooe {

// ---- configuration --------------------------------------------------------------

std::string Config::apply(const std::string &spec) {
  std::map<std::string, unsigned *> u = {
      {"slots", &slots}, {"rob_depth", &rob_depth}, {"retire_per_rob", &retire_per_rob},
      {"issue_width", &issue_width}, {"memop_width", &memop_width},
      {"rename_width", &rename_width}, {"rs_rcu", &rs_rcu}, {"rs_miu", &rs_miu},
      {"rs_warp_cap", &rs_warp_cap}, {"decq", &decq}, {"decq_warp_max", &decq_warp_max},
      {"phys_regs", &phys_regs}, {"pred_regs", &pred_regs}, {"ren_floor", &ren_floor},
      {"ren_ceil", &ren_ceil}, {"pred_ren_floor", &pred_ren_floor},
      {"pred_ren_ceil", &pred_ren_ceil}, {"lat_rcu", &lat_rcu}, {"lat_lane", &lat_lane},
      {"lat_lane_byp", &lat_lane_byp}, {"lat_l1_wake", &lat_l1_wake},
      {"lat_l1_cmpl", &lat_l1_cmpl}, {"cmpl_wake_delay", &cmpl_wake_delay}, {"payload_stages", &payload_stages}, {"rename_stages", &rename_stages}, {"demote_fallback", &demote_fallback},
      {"demote_mlc_miss", &demote_mlc_miss}, {"demote_barrier", &demote_barrier}, {"place", &place}};
  // `sectioned` itself is not a knob until the adapter places operands by
  // position (OI-32); place, loads_pass_loads and foot act only under it.
  std::map<std::string, bool *> b = {{"bypass", &bypass}, {"l1_spec", &l1_spec}, {"resource_cap", &resource_cap},
                                     {"rename_preds", &rename_preds}, {"loads_pass_loads", &loads_pass_loads}};
  std::stringstream ss(spec);
  // byp.P.C=N (a penalty, 255 for none), fast.U=N and lat.U=N: the bypass
  // table by group, the units' fastest points and the latencies 4-7.
  std::map<std::string, uint8_t *> bt;
  for (unsigned p = 0; p != kGroups; ++p)
    for (unsigned g = 0; g != kGroups; ++g)
      bt["byp." + std::to_string(p) + "." + std::to_string(g)] = &byp[p][g];
  for (unsigned p = 0; p != kUnits; ++p) u["fast." + std::to_string(p)] = &fast[p];
  for (unsigned g = 0; g != kGroups; ++g) u["foot." + std::to_string(g)] = &foot_min[g];
  for (unsigned p = 4; p != kUnits; ++p) u["lat." + std::to_string(p)] = &unit_lat[p];
  std::string kv;
  while (std::getline(ss, kv, ',')) {
    if (kv.empty()) continue;
    const size_t eq = kv.find('=');
    if (eq == std::string::npos) return "ooe config: '" + kv + "' is not name=value";
    const std::string k = kv.substr(0, eq), v = kv.substr(eq + 1);
    char *end = nullptr;
    const unsigned long n = std::strtoul(v.c_str(), &end, 0);
    if (!end || *end) return "ooe config: '" + v + "' is not a number";
    if (u.count(k)) *u[k] = unsigned(n);
    else if (bt.count(k)) *bt[k] = uint8_t(n);
    else if (b.count(k)) *b[k] = n != 0;
    else return "ooe config: no knob '" + k + "'";
  }
  return check();
}

std::string Config::check() const {
  char buf[200];
  if (payload_stages > 1) return "payload_stages: 0 or 1";
  if (rename_stages < 1) return "rename_stages: at least 1";
  if (sectioned && resource_cap) return "resource_cap is the unsectioned interim; sectioned select replaces it";
  if (place > 4) return "place: 0 (home = slot), 1 (home = 0), 2 (rotate from 0), 3 (rotate from slot) or 4 (slot + register)";
  for (unsigned f : foot_min)
    if (f != 0 && f != 1 && f != 2 && f != 4) return "foot.G: 0, 1, 2 or 4 sections";
  // V-59 (elaboration): every wake offset is at least 2 + the cancel's hop
  // time, 1 cycle, so a transitive cancel lands before the next hop's ready
  // computation (OA-1). Wakes are raised a cycle early, so a dependant of a
  // producer granted at t is selected no sooner than t + 3.
  {
    unsigned lo = std::min({lat_rcu, lat_lane, lat_l1_wake});
    for (unsigned u = 0; u != kUnits; ++u) {
      if (unit_lat[u]) lo = std::min(lo, unit_lat[u]);
      for (unsigned pg = 0; pg != kGroups && bypass; ++pg)
        for (unsigned cg = 0; cg != kGroups; ++cg)
          if (bypWake(u, pg, cg)) lo = std::min(lo, bypWake(u, pg, cg));
    }
    if (lo < 3) {
      std::snprintf(buf, sizeof buf, "V-59: a wake offset of %u, under 2 + the 1-cycle cancel hop", lo);
      return buf;
    }
  }
  // V-31: ceiling + (slots - 1) x floor <= rename pool, both pools (A-40).
  const unsigned gren = phys_regs - slots * kArchGprs;
  if (phys_regs < slots * kArchGprs || ren_ceil + (slots - 1) * ren_floor > gren) {
    std::snprintf(buf, sizeof buf, "V-31: GPR ceiling %u + %u x floor %u exceeds the rename pool %u",
                  ren_ceil, slots - 1, ren_floor, gren);
    return buf;
  }
  const unsigned pren = pred_regs - slots * kArchPreds;
  if (pred_regs < slots * kArchPreds || pred_ren_ceil + (slots - 1) * pred_ren_floor > pren) {
    std::snprintf(buf, sizeof buf, "V-31: predicate ceiling %u + %u x floor %u exceeds %u",
                  pred_ren_ceil, slots - 1, pred_ren_floor, pren);
    return buf;
  }
  // V-51: the zero registers lie outside their pools.
  if (phys_zero < phys_regs || pred_zero < pred_regs) return "V-51: a zero register inside its pool";
  // V-55: the epoch cannot wrap within one flight (A-70).
  if (epochs <= ckpts + 1) return "V-55: 2^CCV_P_W_FETCH_EPOCH must exceed CCV_P_BR_CKPTS + 1";
  if (rob_depth > (1u << ccv::prov::kWRobIdx)) return "rob_depth exceeds rob_tag's index field";
  if (slots > ccv::kTier1Warps || slots == 0) return "slots must be 1..CCV_TIER1_WARPS";
  if (ckpts > (1u << ccv::prov::kWCkptId)) return "ckpts exceeds checkpoint_id";
  if (issue_width == 0 || rename_width == 0 || retire_per_rob == 0) return "a zero width";
  if (lat_lane_byp > lat_lane) return "CCV_LAT_LANE_BYP exceeds CCV_LAT_LANE";
  for (unsigned u = 0; u != kUnits; ++u)
    if (fastOf(u) && fastOf(u) >= unitLat(u)) {
      std::snprintf(buf, sizeof buf, "unit %u's fastest bypass %u is not under its latency %u",
                    u, fastOf(u), unitLat(u));
      return buf;
    }
  return "";
}

SchedAttr SchedAttr::decode(uint32_t a) {
  SchedAttr s;
  s.rs_miu = (a >> 12) & 1u;
  s.exec_rcu = (a >> 11) & 1u;
  s.cross_lane = (a >> 10) & 1u;
  s.writes_gpr = (a >> 9) & 1u;
  s.writes_pred = (a >> 8) & 1u;
  s.mem_kind = (a >> 6) & 3u;
  s.branch = (a >> 5) & 1u;
  s.serial = (a >> 3) & 3u;
  s.lat_class = a & 7u;
  s.bypass_group = (a >> 13) & 7u;
  return s;
}

// ---- construction ------------------------------------------------------------------

Core::Core(const Config &cfg) : cfg_(cfg) {
  const std::string e = cfg_.check();
  if (!e.empty()) {
    std::fprintf(stderr, "ooe: %s\n", e.c_str());
    std::abort();
  }
  kPos_ = cfg_.sectioned ? 4 : 1;
  slot_.resize(cfg_.slots);
  for (Slot &s : slot_) {
    s.rob.resize(cfg_.rob_depth);
    s.ckpt.resize(cfg_.ckpts);
    s.rat.fill(zeroName());
    s.crat.fill(zeroName());
    s.prat.fill(cfg_.pred_zero);
    s.cprat.fill(cfg_.pred_zero);
  }
  slot_of_.fill(-1);
  n_ = cfg_.rs_rcu + cfg_.rs_miu;
  rs_.resize(n_);
  cell_.assign(size_t(n_) * n_, 0);
  woff_.assign(size_t(n_) * n_, kLateOff);
  cok_.assign(size_t(n_) * n_, 0);
  skew_ = cfg_.inject_early_wake ? 1 : 0;
  const unsigned names = cfg_.phys_regs * kPos_;
  gprod_.assign(names, {kNoEntry, kNoEntry});
  pprod_.assign(std::max(cfg_.pred_regs, 4u * kWarpIds), {kNoEntry, kNoEntry});
  gfree_.reset(cfg_.phys_regs);
  pfree_.reset(cfg_.pred_regs);
  gowner_.assign(names, 0);
  powner_.assign(cfg_.pred_regs, 0);
  gever_.assign(names, 0);
  gw_.assign(names, 0);
  rowOwner_.assign(cfg_.phys_regs, 0);
  rowSec_.assign(cfg_.phys_regs, 0);
}

void Core::ev(const char *name, unsigned warp, uint64_t a, uint64_t b, uint64_t tid) {
  if (on_event) on_event(name, warp, a, b, tid);
}

void Core::err(const char *fmt, ...) {
  char buf[512];
  va_list ap;
  va_start(ap, fmt);
  std::vsnprintf(buf, sizeof buf, fmt, ap);
  va_end(ap);
  ++counters["errors"];
  if (on_error) on_error(buf);
  else std::fprintf(stderr, "ooe: %s\n", buf);
}

int Core::slotOf(unsigned warp) const { return slot_of_[warp % kWarpIds]; }

Core::RobEntry *Core::byTag(unsigned tag, unsigned *slot) {
  const unsigned s = tag >> ccv::prov::kWRobIdx, i = tag & ((1u << ccv::prov::kWRobIdx) - 1);
  if (s >= slot_.size() || i >= cfg_.rob_depth || !slot_[s].rob[i].valid) return nullptr;
  if (slot) *slot = s;
  return &slot_[s].rob[i];
}

// ---- inputs ---------------------------------------------------------------------------

bool Core::canAccept(unsigned warp) const {
  const unsigned max = cfg_.decq_warp_max ? cfg_.decq_warp_max : cfg_.decq;
  if (decq_.size() >= cfg_.decq) return false;
  const int s = slotOf(warp);
  if (s < 0) return true;      // refused, and reported, when it is taken
  return slot_[s].decq < max;
}

void Core::noteRefused(unsigned warp) {
  if (decq_.size() >= cfg_.decq) {
    count("stall.decq_full");
    oev(OoeEv::kDecqFull, warp, decq_.size());
    return;
  }
  count("stall.decq_warp_max");
  const int s = slotOf(warp);
  oev(OoeEv::kDecqWarpMax, warp, s < 0 ? 0 : slot_[s].decq,
      cfg_.decq_warp_max ? cfg_.decq_warp_max : cfg_.decq);
}

/// Into the decode queue, after this cycle's rename: renamed from the next.
void Core::uop(const Uop &u) {
  const int si = slotOf(u.warp);
  if (si < 0) { err("uop for warp %u, which holds no tier-1 slot", u.warp); return; }
  // A uop fetched before its warp's last epoch change is wrong-path (A-70).
  if (u.fetch_epoch != epoch_[u.warp % kWarpIds]) {
    ev("epoch_drop", u.warp, u.fetch_epoch, 0, u.tid);
    return;
  }
  decq_.push_back(u);
  ++slot_[si].decq;
}
void Core::done(const Done &d) { dones_.push_back(d); }
void Core::cmpl(const Cmpl &c) { cmpls_.push_back(c); }
void Core::alloc(const Alloc &a) { allocs_.push_back(a); }
void Core::demote(unsigned warp) { demotes_.push_back(warp); }
void Core::barRelease(uint32_t m) { released_ |= m; }
void Core::kill(uint32_t mask, unsigned epoch) {
  kill_pending_ = true;
  kill_mask_ = mask;
  kill_epoch_ = epoch;
}

// ---- the clock --------------------------------------------------------------------------

void Core::cycle(uint64_t now) {
  now_ = now;
  gfree_.clock();      // last cycle's frees become allocatable
  pfree_.clock();
  out.clear();
  retired.clear();
  takeCompletions();   // dones, completions: complete, resolve, squash
  advanceWakes();      // timed wakes, L1 miss cancel, copy landing, confirm, free
  control();           // RAU's alloc and demote, kill, barrier release
  retire();
  select();
  // Payload read (OA-1): what select granted leaves on the channels a cycle
  // later, so this cycle's grants wait and last cycle's go out.
  if (cfg_.payload_stages) {
    std::swap(out.issues, held_issues_);
    std::swap(out.memops, held_memops_);
  }
  rename();            // the decode queue; uop() refills it after the clock
  sendRedirect();
  if (check_invariants) checkInvariants();
}

bool Core::busy() const {
  if (!decq_.empty() || !redirects_.empty() || free_mask_ ||
      !commits_.empty() || !discards_.empty() || !held_issues_.empty() ||
      !held_memops_.empty())
    return true;
  for (const Slot &s : slot_) {
    if (s.count) return true;
    for (const RobEntry &r : s.rob) if (r.valid) return true;
  }
  return false;
}

std::vector<unsigned> Core::committedGprMap(unsigned warp) const {
  const int s = slotOf(warp);
  if (s < 0) return std::vector<unsigned>(kArchGprs, zeroName());
  return std::vector<unsigned>(slot_[s].crat.begin(), slot_[s].crat.end());
}

std::array<unsigned, kArchPreds> Core::committedPredMap(unsigned warp) const {
  std::array<unsigned, kArchPreds> m;
  m.fill(cfg_.pred_zero);
  const int s = slotOf(warp);
  if (s >= 0) m = slot_[s].cprat;
  return m;
}

// ---- free lists, floors and ceilings (A-26, A-34, A-39, A-40) ------------------------

bool Core::gprAllowed(unsigned slot, unsigned n) const {
  const Slot &s = slot_[slot];
  if (gfree_.ready() < n) return false;
  if (s.held_gpr + n > kArchGprs + cfg_.ren_ceil) return false;
  // Every other tier-1 slot, occupied or not, keeps its architectural 16
  // plus its floor reserved: free registers must still cover them.
  unsigned owed = 0;
  for (unsigned v = 0; v != slot_.size(); ++v)
    if (v != slot) {
      const unsigned want = kArchGprs + cfg_.ren_floor;
      owed += slot_[v].held_gpr < want ? want - slot_[v].held_gpr : 0;
    }
  return gfree_.ready() - n >= owed;
}

bool Core::predAllowed(unsigned slot, unsigned n) const {
  const Slot &s = slot_[slot];
  if (pfree_.ready() < n) return false;
  if (s.held_pred + n > kArchPreds + cfg_.pred_ren_ceil) return false;
  unsigned owed = 0;
  for (unsigned v = 0; v != slot_.size(); ++v)
    if (v != slot) {
      const unsigned want = kArchPreds + cfg_.pred_ren_floor;
      owed += slot_[v].held_pred < want ? want - slot_[v].held_pred : 0;
    }
  return pfree_.ready() - n >= owed;
}

unsigned Core::allocGpr(unsigned slot) {
  if (cfg_.sectioned) return allocSlice(slot, 0, 0);
  const unsigned p = gfree_.alloc();
  if (gowner_[p]) err("V-03: GPR p%u allocated while slot %u owns it", p, gowner_[p] - 1);
  gowner_[p] = uint8_t(slot + 1);
  ++slot_[slot].held_gpr;
  if (gever_[p]) ev("reg_reuse", slot_[slot].warp, p);
  gever_[p] = 1;
  return p;
}

/// Sectioned allocation (OI-29). A 32-bit register takes a free row. A
/// narrow one takes its sections at the wanted position in a row its slot
/// already owns, else a free row; failing both, another position in an
/// owned row (its footprint then widens, but it does not wait).
unsigned Core::planSlice(unsigned slot, unsigned w, unsigned &pos, bool allow_row) const {
  if (w == 0) { pos = 0; return allow_row && gfree_.ready() ? 1 : 2; }
  const unsigned step = w == 1 ? 2 : 1;
  pos = w == 1 ? (pos & 2u) : (pos & 3u);
  auto partial = [&](unsigned p) {
    const unsigned m = secMask(w, p);
    for (unsigned row = 0; row != cfg_.phys_regs; ++row)
      if (rowOwner_[row] == slot + 1 && !(rowSec_[row] & m)) return true;
    return false;
  };
  if (partial(pos)) return 0;
  if (allow_row && gfree_.ready()) return 1;
  for (unsigned k = step; k < 4; k += step) {
    const unsigned p = (pos + k) & 3u;
    if (partial(p)) { pos = p; return 0; }
  }
  return 2;
}

unsigned Core::allocSlice(unsigned slot, unsigned w, unsigned pos) {
  unsigned want = pos;
  const unsigned plan = planSlice(slot, w, want, gprAllowed(slot, 1));
  if (plan == 2) { err("V-04: no slice for slot %u at width %u", slot, w); return zeroName(); }
  const unsigned m = secMask(w, want);
  unsigned row = cfg_.phys_regs;
  if (plan == 0) {
    for (unsigned r = 0; r != cfg_.phys_regs && row == cfg_.phys_regs; ++r)
      if (rowOwner_[r] == slot + 1 && !(rowSec_[r] & m)) row = r;
  } else {
    row = gfree_.alloc();
    if (rowOwner_[row]) err("V-03: row %u allocated while slot %u owns it", row, rowOwner_[row] - 1);
    rowOwner_[row] = uint8_t(slot + 1);
    ++slot_[slot].held_gpr;
  }
  rowSec_[row] = uint8_t(rowSec_[row] | m);
  const unsigned p = row * kPos_ + want;
  gw_[p] = uint8_t(w);
  if (gever_[p]) ev("reg_reuse", slot_[slot].warp, p);
  gever_[p] = 1;
  if (want != (w == 1 ? (pos & 2u) : (pos & 3u))) count("place.fallback_position");
  return p;
}

/// Where a narrow destination goes (AR-15, OA-14): a merged op's old
/// destination's position; else an existing narrow source's, never a
/// third; else the warp's home position (place: slot index, 0, or the
/// slot's rotating counter).
unsigned Core::placePos(unsigned slot, const Uop &u, bool merge) const {
  const unsigned w = u.w;
  if (!cfg_.sectioned || w == 0) return 0;
  const Slot &s = slot_[slot];
  auto align = [&](unsigned p) { return w == 1 ? (p & 2u) : (p & 3u); };
  const unsigned old = s.rat[u.dst & 15];
  if (merge && !isZeroName(old) && nameWidth(old) == w) return align(namePos(old));
  for (unsigned i = 0; i != 3; ++i) {
    if (!((u.shape.gpr_reads >> i) & 1u)) continue;
    const unsigned n = s.rat[u.src[i] & 15];
    if (!isZeroName(n) && nameWidth(n) != 0) return align(namePos(n));
  }
  const unsigned home = cfg_.place == 1   ? 0
                        : cfg_.place == 2 ? s.home_ctr
                        : cfg_.place == 3 ? s.home_ctr + slot
                        : cfg_.place == 4 ? slot + (u.dst & 15)
                                          : slot;
  return w == 1 ? (home % 2) * 2 : home % 4;
}

/// An entry's resources (OI-31, OI-33, AR-12). A memop takes the MIU pipes
/// of its data register's sections; an op RCU executes, or a
/// warp-collective or predicate op, takes R; a lane op takes the union of
/// its operands' sections (OI-30 revised), widened to its unit's minimum.
unsigned Core::resOf(const RobEntry &r, bool copy_half) const {
  const Uop &u = r.u;
  const SchedAttr &a = u.attr;
  if (r.is_mem && !copy_half) {
    // The data register: a load's destination; a store's highest read source.
    unsigned data = r.alloc_gpr ? r.pnew : zeroName();
    if (!r.alloc_gpr)
      for (unsigned i = 0; i != 3; ++i)
        if ((u.shape.gpr_reads >> i) & 1u) data = r.psrc[i];
    unsigned m = sectionsOf(data);
    if (!m) m = 0xFu;
    return m << 5;
  }
  if (!copy_half && (a.exec_rcu || u.shape.exit || u.decode_fault)) return 1u << 4;
  const unsigned fm = copy_half ? 1 : cfg_.foot_min[a.bypass_group & 7];
  if (!fm) return 1u << 4;
  unsigned m = 0;
  if (r.alloc_gpr) m |= sectionsOf(r.pnew);
  if (copy_half) {
    m |= sectionsOf(r.pold);
  } else {
    for (unsigned i = 0; i != 3; ++i)
      if ((u.shape.gpr_reads >> i) & 1u) m |= sectionsOf(r.psrc[i]);
    if (r.merge && r.alloc_gpr) m |= sectionsOf(r.pold);
  }
  if (!m) m = 1;                       // no GPR operand: section 0
  if (cfg_.inject_narrow_footprint) return m & (~m + 1u);
  if (fm >= 4) m = 0xFu;
  else if (fm == 2) m |= ((m & 0x5u) << 1) | ((m & 0xAu) >> 1);
  return m;
}

unsigned Core::allocPred(unsigned slot, unsigned arch) {
  if (!cfg_.rename_preds) return cfg_.pred_window(slot_[slot].warp, arch);
  const unsigned p = pfree_.alloc();
  if (powner_[p]) err("V-03: predicate pp%u allocated while slot %u owns it", p, powner_[p] - 1);
  powner_[p] = uint8_t(slot + 1);
  ++slot_[slot].held_pred;
  return p;
}

void Core::freeGpr(unsigned slot, unsigned p) {
  if (isZeroName(p)) return;                // never freed (A-64)
  if (cfg_.sectioned) {
    // A slice frees its sections; its row returns to the pool when its last
    // live section frees (OI-29).
    const unsigned row = nameRow(p);
    if (row >= cfg_.phys_regs) { err("V-29: free of GPR %u outside the pool", p); return; }
    if (rowOwner_[row] != slot + 1) {
      err("V-62: slot %u frees p%u in row %u, owned by %d", slot, p, row, int(rowOwner_[row]) - 1);
      return;
    }
    const unsigned m = sectionsOf(p);
    if ((rowSec_[row] & m) != m) { err("V-01: GPR p%u freed twice", p); return; }
    rowSec_[row] = uint8_t(rowSec_[row] & ~m);
    if (!rowSec_[row]) {
      rowOwner_[row] = 0;
      --slot_[slot].held_gpr;
      if (!gfree_.free(row)) err("V-01: row %u freed twice", row);
    }
    return;
  }
  if (p >= cfg_.phys_regs) { err("V-29: free of GPR %u outside the pool", p); return; }
  if (gowner_[p] != slot + 1) {
    err("V-01: slot %u frees GPR p%u, owned by %d", slot, p, int(gowner_[p]) - 1);
    return;
  }
  gowner_[p] = 0;
  --slot_[slot].held_gpr;
  if (!gfree_.free(p)) err("V-01: GPR p%u freed twice", p);
}

void Core::freePred(unsigned slot, unsigned p) {
  if (!cfg_.rename_preds || p == cfg_.pred_zero) return;
  if (p >= cfg_.pred_regs) { err("V-29: free of predicate %u outside the pool", p); return; }
  if (powner_[p] != slot + 1) {
    err("V-02: slot %u frees predicate pp%u, owned by %d", slot, p, int(powner_[p]) - 1);
    return;
  }
  powner_[p] = 0;
  --slot_[slot].held_pred;
  if (!pfree_.free(p)) err("V-02: predicate pp%u freed twice", p);
}

// ---- reservation stations and the dependency matrix (A-62, A-73) ---------------------

unsigned Core::rsAlloc(RsCls c, unsigned slot, unsigned rob, bool copy) {
  const unsigned lo = c == RsCls::kRcu ? 0 : cfg_.rs_rcu;
  const unsigned hi = c == RsCls::kRcu ? cfg_.rs_rcu : n_;
  for (unsigned e = lo; e != hi; ++e)
    if (!rs_[e].valid) {
      rs_[e] = RsEntry();
      rs_[e].valid = true;
      rs_[e].cls = c;
      rs_[e].slot = slot;
      rs_[e].rob = rob;
      rs_[e].copy = copy;
      rs_[e].age = next_age_++;
      rs_[e].eligible_at = now_ + cfg_.rename_stages;
      for (unsigned j = 0; j != n_; ++j) {
        cell(e, j) = 0;
        woff_[size_t(e) * n_ + j] = kLateOff;
        cok_[size_t(e) * n_ + j] = 0;
      }
      ++slot_[slot].rs_held;
      return e;
    }
  return kNoEntry;
}

void Core::rsFree(unsigned e) {
  RsEntry &x = rs_[e];
  if (!x.valid) return;
  for (unsigned i = 0; i != n_; ++i) {   // its column: satisfied for good
    cell(i, e) = 0;
    cok_[size_t(i) * n_ + e] = 0;
  }
  for (unsigned j = 0; j != n_; ++j) cell(e, j) = 0;
  for (auto &p : gprod_) for (unsigned &q : p) if (q == e) q = kNoEntry;
  for (auto &p : pprod_) for (unsigned &q : p) if (q == e) q = kNoEntry;
  RobEntry &r = slot_[x.slot].rob[x.rob];
  if (r.rs_main == e) r.rs_main = kNoEntry;
  if (r.rs_copy == e) r.rs_copy = kNoEntry;
  --slot_[x.slot].rs_held;
  x.valid = false;
}

/// Record that entry e reads physical register preg. `group` is the
/// consumer's bypass group for this use (Config::byp), or -1 for a use no
/// bypass reaches: a predicate read as guard, data or merge source (A-62).
/// The cell waits for a bypass wake only if every use it makes of the
/// producer may take that bypass (V-48), else for the full-latency wake.
void Core::dep(unsigned e, unsigned preg, bool pred, int group) {
  if (pred ? preg == cfg_.pred_zero : isZeroName(preg)) return;
  const auto &prods = pred ? pprod_[preg] : gprod_[preg];
  for (unsigned j : prods) {
    if (j == kNoEntry || !rs_[j].valid) continue;
    if (j == e) { err("V-10: entry %u depends on itself", e); continue; }
    const RsEntry &p = rs_[j];
    const RobEntry &pr = slot_[p.slot].rob[p.rob];
    const unsigned unit = pr.u.attr.lat_class;
    uint8_t off = kLateOff;
    // Only a fixed-latency, non-cross-lane producer bypasses (A-59): never a
    // memop, a copy-only op or a unit that wakes on its done.
    if (cfg_.bypass && group >= 0 && !p.copy && !pr.is_mem && !pr.u.attr.cross_lane &&
        unit < Config::kUnits && cfg_.unitLat(unit)) {
      const unsigned b = cfg_.bypWake(unit, pr.u.attr.bypass_group, unsigned(group));
      if (b) off = uint8_t(b);
    }
    uint8_t &c = cell(e, j);
    uint8_t &w = woff_[size_t(e) * n_ + j];
    if (!(c & 1)) { c = 1; w = off; }
    else if (w != kLateOff && (off == kLateOff || off > w)) w = off;   // the later wins
  }
}

void Core::addDeps(unsigned e, const RobEntry &r, bool copy_half) {
  const Uop &u = r.u;
  // The consumer's bypass group for its GPR operands: its bypass_group; a
  // memop consumes as address calculation, since RCU sends its address and
  // data to MIU; and an op RCU executes takes no bypass (V-48).
  const int group = r.is_mem ? int(Config::kGrpAddr) : u.attr.exec_rcu ? -1 : int(u.attr.bypass_group);
  if (copy_half) {
    // The copy-only op: the old destination through a lane as merge_data,
    // under the load's guard (A-38).
    dep(e, r.pold, false, int(Config::kGrpInt));
    if (u.shape.guard) dep(e, r.ppguard, true, -1);
    return;
  }
  for (unsigned i = 0; i != 3; ++i)
    if ((u.shape.gpr_reads >> i) & 1u) dep(e, r.psrc[i], false, group);
  // The old destination is a fourth source when the write merges (A-33),
  // except for a masked load, whose copy reads it instead.
  if (r.merge && r.alloc_gpr && !r.copy) dep(e, r.pold, false, group);
  if (u.shape.guard || u.shape.pdata) dep(e, r.ppguard, true, -1);
  if (u.shape.pred_logic) {
    dep(e, r.pq[0], true, -1);
    dep(e, r.pq[1], true, -1);
  }
  // The old predicate destination when the predicate write merges (A-43).
  if (u.pred_we && r.merge) dep(e, r.ppold, true, -1);
}

bool Core::cellOk(unsigned i, unsigned j) const {
  if (!(cell(i, j) & 1)) return true;
  const RsEntry &p = rs_[j];
  const uint8_t w = woff_[size_t(i) * n_ + j];
  if (w == kLateOff) return p.late;
  // A bypass wake: its offset after the producer's issue, while that issue
  // stands (a cancel clears issued). dep() gives offsets only to timed
  // producers.
  return p.issued && now_ + skew_ >= p.issue_at + w;
}

bool Core::rowReady(unsigned i) const {
  for (unsigned j = 0; j != n_; ++j)
    if (!cellOk(i, j)) return false;
  return true;
}

bool Core::rowConfirmed(unsigned i) const {
  for (unsigned j = 0; j != n_; ++j)
    if ((cell(i, j) & 1) && !rs_[j].confirmed) return false;
  return true;
}

// ---- wake, cancel, confirm ---------------------------------------------------------------

void Core::setWakes(unsigned e) {
  RsEntry &x = rs_[e];
  const RobEntry &r = slot_[x.slot].rob[x.rob];
  const SchedAttr &a = r.u.attr;
  x.late = false;
  x.spec = x.on_completion = false;
  if (x.copy) {
    x.late_at = now_ + cfg_.lat_lane;     // a lane op; no done (A-38)
    return;
  }
  if (r.is_mem) {
    // Only an L1-contracted global load wakes before its completion (A-46);
    // scratchpad loads, atomics and everything past L1 wake on completion.
    if (cfg_.l1_spec && r.is_load && a.lat_class == kLatClsL1 && r.u.space == 0) {
      x.spec = true;
      x.late_at = now_ + cfg_.lat_l1_wake;
    } else {
      x.on_completion = true;
    }
    return;
  }
  // A fixed-latency unit: the full-latency wake at its latency, and its
  // bypass wakes at each cell's offset (cellOk). A unit with no latency
  // named yet -- lat_class 3, or a spare code -- wakes on its done.
  const unsigned lat = a.lat_class < Config::kUnits ? cfg_.unitLat(a.lat_class) : 0;
  if (lat) x.late_at = now_ + lat;
  else x.on_completion = true;
}

void Core::wake(unsigned e) { rs_[e].late = true; }

/// EV_WAKEUP for every operand whose wake was satisfied this cycle: the
/// dependant's RS entry and the producer's.
void Core::emitWakeups() {
  for (unsigned i = 0; i != n_; ++i) {
    if (!rs_[i].valid || rs_[i].issued) continue;
    for (unsigned j = 0; j != n_; ++j) {
      if (!(cell(i, j) & 1)) continue;
      uint8_t &k = cok_[size_t(i) * n_ + j];
      const bool ok = cellOk(i, j);
      if (ok && !k)
        ev("wakeup", slot_[rs_[i].slot].warp, i, j, slot_[rs_[i].slot].rob[rs_[i].rob].u.tid);
      k = ok;
    }
  }
}

/// A load missed its L1 slot: withdraw its wakes and poison everything that
/// issued on them, transitively through the matrix (A-46; V-15). Poisoned
/// entries are still in the RS -- held until confirmed -- and return to
/// Waiting; the load itself stays at MIU and wakes again on its completion.
void Core::cancel(unsigned e) {
  RsEntry &x = rs_[e];
  x.late = false;
  x.spec = false;
  x.on_completion = true;
  count("cancel.miss");
  // One hop now; cancelHop() takes one more a cycle until nothing changes
  // (OA-1: transitive cancel moves one hop per cycle, held by V-59).
  if (!cancel_live_) cancel_depth_ = 0;
  cancel_live_ = true;
  cancelHop(e);
}

/// One hop of transitive cancel: every issued, unconfirmed entry whose row
/// is no longer ready -- a producer it issued on was withdrawn or returned
/// to Waiting -- returns to Waiting. False when nothing changed.
bool Core::cancelHop(unsigned root) {
  // Decide the whole hop first, so a return to Waiting in this hop does not
  // reach that entry's own dependants until the next.
  std::vector<unsigned> hop;
  for (unsigned i = 0; i != n_; ++i) {
    const RsEntry &y = rs_[i];
    if (y.valid && y.issued && !y.confirmed && i != root && !rowReady(i)) hop.push_back(i);
  }
  bool changed = false;
  {
    for (unsigned i : hop) {
      RsEntry &y = rs_[i];
      // Issued on a wake that has been withdrawn: back to Waiting.
      RobEntry &r = slot_[y.slot].rob[y.rob];
      if (r.is_mem || y.copy) {
        err("V-17: memop entry %u was issued on an unconfirmed source", i);
        continue;
      }
      y.issued = false;
      y.late = false;
      ++y.replays;
      // Its done still comes, at the contracted cycle: void it (A-47). If
      // it has come already, void what it said.
      if (r.rcu_dones_owed > r.stale_dones) {
        ++r.stale_dones;
      } else if (r.rcu_done) {
        r.rcu_done = false;
        r.resolved = false;
      }
      count("cancel.replay");
      ev("cancel", slot_[y.slot].warp, i, cancel_depth_ + 1, r.u.tid);
      oev(OoeEv::kCancelReplay, slot_[y.slot].warp, i, cancel_depth_ + 1, r.u.tid);
      changed = true;
    }
  }
  if (changed) ++cancel_depth_;
  return changed;
}

/// Confirm results that can no longer be cancelled, oldest first (producers
/// are older, V-10), and free the RS entries whose sources and result are
/// confirmed (V-16).
void Core::confirmPass() {
  std::vector<unsigned> order;
  for (unsigned e = 0; e != n_; ++e)
    if (rs_[e].valid && rs_[e].issued && !rs_[e].confirmed) order.push_back(e);
  std::sort(order.begin(), order.end(),
            [&](unsigned a, unsigned b) { return rs_[a].age < rs_[b].age; });
  for (unsigned e : order) {
    RsEntry &x = rs_[e];
    if (!rowConfirmed(e)) continue;
    if (!x.produces) { x.confirmed = true; continue; }   // nothing to wake
    if (x.late && !x.spec) x.confirmed = true;
  }
  for (unsigned e : order)
    if (rs_[e].valid && rs_[e].confirmed) {
      const unsigned slot = rs_[e].slot, rob = rs_[e].rob;
      rsFree(e);
      complete(slot, rob);
    }
}

void Core::advanceWakes() {
  // Transitive cancel's next hop, from what the last cycle withdrew.
  if (cancel_live_) {
    if (cfg_.inject_shallow_cancel || !cancelHop(kNoEntry)) {
      ++histograms["cancel_depth"][cancel_depth_];
      cancel_live_ = false;
    }
  }
  for (unsigned e = 0; e != n_; ++e) {
    RsEntry &x = rs_[e];
    if (!x.valid || !x.issued || x.on_completion) continue;
    if (now_ + skew_ >= x.late_at) wake(e);
  }
  // L1 contract: no completion at CCV_LAT_L1_CMPL is the miss (A-46, A-54).
  for (unsigned e = cfg_.rs_rcu; e != n_; ++e) {
    RsEntry &x = rs_[e];
    if (x.valid && x.issued && x.spec && now_ >= x.issue_at + cfg_.payload_stages + cfg_.lat_l1_cmpl)
      cancel(e);
  }
  // Copy-only ops land at their contracted cycle and send no done (A-38).
  for (unsigned s = 0; s != slot_.size(); ++s)
    for (unsigned i = 0; i != cfg_.rob_depth; ++i) {
      RobEntry &r = slot_[s].rob[i];
      if (r.valid && r.copy_pending && now_ >= r.copy_land) {
        r.copy_pending = false;
        if (!r.squashed) complete(s, i);
      }
    }
  confirmPass();
  // Squashed entries held for an outstanding op release when it lands (V-22).
  for (unsigned s = 0; s != slot_.size(); ++s)
    for (unsigned i = 0; i != cfg_.rob_depth; ++i) {
      RobEntry &r = slot_[s].rob[i];
      if (r.valid && r.squashed && !outstanding(r)) releaseEntry(s, i);
    }
  emitWakeups();
}

// ---- completions -------------------------------------------------------------------------

bool Core::outstanding(const RobEntry &r) const {
  return r.rcu_dones_owed > 0 || (r.at_miu && !r.miu_done) || r.copy_pending;
}

void Core::complete(unsigned slot, unsigned idx) {
  RobEntry &r = slot_[slot].rob[idx];
  if (r.complete || r.squashed) return;
  bool c;
  if (r.u.shape.exit || r.u.decode_fault) c = true;
  else if (r.u.attr.serial == kSerBarrier) c = false;   // completed by release
  else if (r.is_mem) c = r.miu_done && (!cfg_.memop_rcu_done || r.rcu_done) &&
                         !r.copy_pending && r.rcu_dones_owed == 0;
  else c = r.rcu_done && r.rcu_dones_owed == 0;
  // A ROB entry outlives its RS entries: it completes only once every one
  // is confirmed and freed, so no result it reports can still be cancelled
  // and no RS entry ever names a retired ROB slot.
  c = c && ((r.rs_main == kNoEntry && r.rs_copy == kNoEntry) || cfg_.inject_complete_early);
  if (!c) return;
  r.complete = true;
  // A branch acts on its outcome only once confirmed: a resolution read
  // from a cancelled wake would squash on garbage.
  if (r.u.attr.branch && r.resolved) resolveBranch(slot, idx);
}

void Core::takeCompletions() {
  for (const Done &d : dones_) {
    unsigned s;
    RobEntry *r = byTag(d.rob_tag, &s);
    if (!r) { err("done for rob tag %u, which is not in the ROB", d.rob_tag); continue; }
    if (r->rcu_dones_owed == 0) {
      err("done for rob tag %u, which owes none", d.rob_tag);
      continue;
    }
    --r->rcu_dones_owed;
    if (r->stale_dones) { --r->stale_dones; count("done.voided"); continue; }
    if (r->squashed) { count("done.after_squash"); continue; }   // dropped (A-58)
    const unsigned idx = d.rob_tag & ((1u << ccv::prov::kWRobIdx) - 1);
    if (!r->is_mem) {
      const unsigned lc = r->u.attr.lat_class;
      const uint64_t took = now_ - (r->rcu_issue_at + cfg_.payload_stages);
      ++histograms["done_after_issue.lat" + std::to_string(lc)][took];
      // V-35, the arrival-cycle checker on ccv_rcu_ooe_done (repo Q-53).
      // A dependant issued at the contracted latency reaches RCU one issue
      // crossing later and must read the result, so RCU has written it by
      // the cycle before, and its done -- sent with the write -- lands no
      // later than issue + issue link + latency - 1 + done link. Earlier is
      // a faster RCU, which is safe; later broke the contract dependants
      // were woken on.
      if (lc < Config::kUnits && cfg_.unitLat(lc)) {
        const uint64_t lat = cfg_.unitLat(lc);
        const uint64_t bound = cfg_.issue_link + lat - 1 + cfg_.done_link;
        if (took > bound)
          err("V-35: seq %u (rob tag %u) done %llu cycles after issue; latency class %u "
              "allows %llu", uint32_t(r->u.tid) /* the uid's sequence field */, d.rob_tag,
              (unsigned long long)took, lc, (unsigned long long)bound);
      }
    }
    r->rcu_done = true;
    if (d.exec_fault) {
      r->fault = true;
      r->fault_cause = 1;
      r->fault_lanes = d.fault_lane_mask;
    }
    // A done is a completion for an RS entry that wakes on it.
    if (r->rs_main != kNoEntry && rs_[r->rs_main].valid && rs_[r->rs_main].on_completion &&
        rs_[r->rs_main].cls == RsCls::kRcu)
      wake(r->rs_main);
    if (r->u.attr.branch) {
      r->resolved = true;
      r->taken = d.branch_taken;
      r->taken_mask = d.branch_mask;
    }
    complete(s, idx);
  }
  dones_.clear();
  for (const Cmpl &c : cmpls_) {
    unsigned s;
    RobEntry *r = byTag(c.rob_tag, &s);
    if (!r) { err("completion for rob tag %u, which is not in the ROB", c.rob_tag); continue; }
    if (!r->at_miu || r->miu_done) {
      err("V-43: a second completion for rob tag %u", c.rob_tag);
      continue;
    }
    r->miu_done = true;
    if (r->squashed) { count("cmpl.after_squash"); continue; }
    const unsigned idx = c.rob_tag & ((1u << ccv::prov::kWRobIdx) - 1);
    if (c.status) {
      r->fault = true;
      r->fault_cause = c.cause ? c.cause : 2;
      r->fault_lanes = c.lane_mask;
      r->fault_addr = c.address;
    }
    r->mlc_miss = c.mlc_miss;
    if (r->rs_main != kNoEntry && rs_[r->rs_main].valid) {
      RsEntry &x = rs_[r->rs_main];
      if (x.spec) {
        // An L1 hit lands at exactly CCV_LAT_L1_CMPL (A-46, V-44).
        if (now_ != x.issue_at + cfg_.payload_stages + cfg_.lat_l1_cmpl)
          err("V-44: rob tag %u completed %llu cycles after issue; the L1 contract is %u",
              c.rob_tag, (unsigned long long)(now_ - x.issue_at - cfg_.payload_stages),
              cfg_.lat_l1_cmpl);
        x.spec = false;               // the speculative wake stands
        count("load.l1_hit");
      } else {
        if (r->is_load) count("load.past_l1");
        // Wake once the data is readable at RCU (Config::cmpl_wake_delay).
        x.on_completion = false;
        x.late_at = now_ + cfg_.cmpl_wake_delay;
        if (!cfg_.cmpl_wake_delay) wake(r->rs_main);
      }
    }
    complete(s, idx);
  }
  cmpls_.clear();
}

// ---- branches and squash (A-41, A-42, A-56, A-58) ------------------------------------

void Core::freeCkptsFrom(unsigned slot, unsigned idx) {
  // The branch at idx and every younger branch: OOE's RAT checkpoints. FET
  // frees its own on the redirect (A-56), so no free bit is sent for these,
  // and any not yet sent this cycle is withdrawn (A-58).
  Slot &s = slot_[slot];
  for (unsigned k = robAge(s, idx); k < s.count; ++k) {
    RobEntry &r = s.rob[(s.head + k) % cfg_.rob_depth];
    if (r.valid && r.ckpt_live) {
      s.ckpt[r.u.ckpt].live = false;
      r.ckpt_live = false;
      free_mask_ &= ~(uint64_t(1) << (slot * cfg_.ckpts + r.u.ckpt));
    }
  }
}

void Core::resolveBranch(unsigned slot, unsigned idx) {
  Slot &s = slot_[slot];
  RobEntry &r = s.rob[idx];
  if (!r.ckpt_live) {
    err("V-07: branch at rob tag %u resolved without a live checkpoint", tagOf(slot, idx));
    return;
  }
  // V-41: a redirect exactly when the outcome disagrees with pred_taken.
  if (r.taken == r.u.pred_taken) {
    free_mask_ |= uint64_t(1) << (slot * cfg_.ckpts + r.u.ckpt);
    s.ckpt[r.u.ckpt].live = false;
    r.ckpt_live = false;
    count("branch.correct");
    return;
  }
  count("branch.mispredict");
  ev("redirect", s.warp, tagOf(slot, idx), r.u.ckpt, r.u.tid);
  const Ckpt cp = s.ckpt[r.u.ckpt];
  freeCkptsFrom(slot, idx);
  squashAfter(slot, int(idx), false);
  // Restore OOE's RAT in the same cycle FET restores its groups (Q8).
  s.rat = cp.gpr;
  s.prat = cp.pred;
  advanceEpoch(slot);
  Redirect rd;
  rd.tid = r.u.tid;
  rd.warp = s.warp;
  rd.slot = slot;
  rd.ckpt = r.u.ckpt;
  rd.taken_mask = r.taken_mask;
  // imm is the architectural offset, in halfwords from the next instruction
  // (arch open A-8); the length rides in ilen.
  const uint64_t next = r.u.pc + 2 * (r.u.ilen + 1);
  rd.target_pc = r.taken ? next + uint64_t(2 * int64_t(int32_t(r.u.imm))) : next;
  rd.epoch = epoch_[s.warp];
  // A queued redirect of this warp is for a branch this squash removed.
  for (auto it = redirects_.begin(); it != redirects_.end();)
    if (it->slot == slot && !it->epoch_only) { it = redirects_.erase(it); count("redirect.superseded"); }
    else ++it;
  redirects_.push_back(rd);
}

void Core::releaseEntry(unsigned slot, unsigned idx) {
  RobEntry &r = slot_[slot].rob[idx];
  if (r.alloc_gpr) freeGpr(slot, r.pnew);
  if (r.alloc_pred) freePred(slot, r.ppnew);
  if (r.ckpt_live) { slot_[slot].ckpt[r.u.ckpt].live = false; r.ckpt_live = false; }
  r = RobEntry();
}

/// Squash every entry of the slot younger than keep_idx, in ROB order; with
/// to_retirement, every entry. The caller restores the RAT.
void Core::squashAfter(unsigned slot, int keep_idx, bool to_retirement) {
  Slot &s = slot_[slot];
  const unsigned first = to_retirement ? 0 : robAge(s, unsigned(keep_idx)) + 1;
  const uint32_t gmask = to_retirement ? 0 : s.rob[unsigned(keep_idx)].u.group_mask;
  bool stores_at_miu = false;
  unsigned n = 0, deferred = 0, other = 0;
  for (unsigned k = first; k < s.count; ++k) {
    const unsigned idx = (s.head + k) % cfg_.rob_depth;
    RobEntry &r = s.rob[idx];
    ++n;
    if (!to_retirement && r.u.group_mask != gmask) { count("squash.cross_group"); ++other; }   // A-31
    if (r.rs_main != kNoEntry) rsFree(r.rs_main);
    if (r.rs_copy != kNoEntry) rsFree(r.rs_copy);
    r.rs_main = r.rs_copy = kNoEntry;
    if (r.is_store && r.at_miu && !r.committed) stores_at_miu = true;
    if (s.chwidth_hold && s.chwidth_rob == idx) s.chwidth_hold = false;
    if (r.u.attr.serial == kSerBarrier) s.bar_hold = false;
    if (outstanding(r)) {
      // Keeps its destinations and rob_tag until the op lands (V-22).
      r.squashed = true;
      r.stale_dones = r.rcu_dones_owed;
      ++deferred;
      ev("deferred_free", s.warp, tagOf(slot, idx), 0, r.u.tid);
      oev(OoeEv::kDeferredFree, s.warp, tagOf(slot, idx), 0, r.u.tid);
    } else {
      releaseEntry(slot, idx);
    }
  }
  if (other)
    oev(OoeEv::kCrossGroupSquash, s.warp, other, tagOf(slot, unsigned(keep_idx)),
        s.rob[unsigned(keep_idx)].u.tid);
  count("squash.entries", n);
  count("squash.deferred", deferred);
  if (stores_at_miu) {
    // One bulk discard of the circular range (branch, tail] (A-41, A-53).
    Memop d;
    d.tid = s.rob[to_retirement ? s.head : unsigned(keep_idx)].u.tid;
    d.warp = s.warp;
    d.mem_op = 0xF;
    const unsigned branch = to_retirement ? (s.head + cfg_.rob_depth - 1) % cfg_.rob_depth
                                          : unsigned(keep_idx);
    d.rob_tag = tagOf(slot, branch);
    d.disp = (s.head + s.count - 1) % cfg_.rob_depth;   // youngest allocated
    discards_.push_back(d);
    count("bulk_discard");
  }
  s.count = first;
  s.tail = (s.head + s.count) % cfg_.rob_depth;
  // Wrong-path uops still in the decode queue: their epoch is stale once the
  // caller advances it, so drop them now and free the space.
  for (auto it = decq_.begin(); it != decq_.end();)
    if (it->warp == s.warp) { it = decq_.erase(it); --s.decq; ev("epoch_drop", s.warp); }
    else ++it;
}

void Core::advanceEpoch(unsigned slot) {
  const unsigned w = slot_[slot].warp;
  epoch_[w] = (epoch_[w] + 1) % cfg_.epochs;
}

void Core::epochNotice(unsigned slot) {
  Redirect n;
  n.warp = slot_[slot].warp;
  n.slot = slot;
  n.epoch = epoch_[n.warp];
  n.epoch_only = true;
  slot_[slot].notice_sent = false;
  redirects_.push_back(n);
}

// ---- RAU, kill and barriers ----------------------------------------------------------------

void Core::releaseSlot(unsigned slot) {
  Slot &s = slot_[slot];
  for (unsigned i = 0; i != cfg_.rob_depth; ++i)
    if (s.rob[i].valid) err("V-28: slot %u released with rob entry %u", slot, i);
  for (unsigned a = 0; a != kArchGprs; ++a) freeGpr(slot, s.crat[a]);
  for (unsigned a = 0; a != kArchPreds; ++a) freePred(slot, s.cprat[a]);
  if (s.held_gpr || (cfg_.rename_preds && s.held_pred))
    err("V-01: slot %u released holding %u GPRs, %u predicates", slot, s.held_gpr, s.held_pred);
  slot_of_[s.warp % kWarpIds] = -1;
  const unsigned keep_epoch_warp = s.warp;
  (void)keep_epoch_warp;    // the epoch is per warp_id and survives (A-74)
  Slot fresh;
  fresh.rob.resize(cfg_.rob_depth);
  fresh.ckpt.resize(cfg_.ckpts);
  fresh.rat.fill(zeroName());
  fresh.crat.fill(zeroName());
  fresh.prat.fill(cfg_.pred_zero);
  fresh.cprat.fill(cfg_.pred_zero);
  s = fresh;
}

void Core::control() {
  for (const Alloc &a : allocs_) {
    if (a.slot >= slot_.size()) { err("alloc names tier-1 slot %u", a.slot); continue; }
    Slot &s = slot_[a.slot];
    switch (a.op) {
    case kAllocLaunch:
    case kAllocRestoreAlloc: {
      if (s.st != WarpState::kFree) {
        err("alloc op %u for slot %u, which holds warp %u", a.op, a.slot, s.warp);
        break;
      }
      s.warp = a.warp;
      s.ctaid = a.ctaid;
      s.warp_in_cta = a.warp_in_cta;
      slot_of_[a.warp % kWarpIds] = int(a.slot);
      if (a.op == kAllocLaunch) {
        // Every architectural register maps to the zero registers (A-64):
        // no zeroing traffic, and nothing from another context is readable.
        s.st = WarpState::kActive;
        ev("launch", a.warp, a.slot);
        break;
      }
      // Restore-allocate (A-64): 16 GPRs and 4 predicates from the slot's
      // reservation, which the floor guarantees (V-30), then the map so
      // PCA's rows land in them. The warp waits for restore-activate.
      if (!gprAllowed(a.slot, kArchGprs) || (cfg_.rename_preds && !predAllowed(a.slot, kArchPreds)))
        err("V-30: restore-allocate for slot %u finds its reservation short", a.slot);
      for (unsigned g = 0; g != kArchGprs && !gfree_.empty(); ++g) s.crat[g] = s.rat[g] = allocGpr(a.slot);
      for (unsigned p = 0; p != kArchPreds; ++p) s.cprat[p] = s.prat[p] = allocPred(a.slot, p);
      RatMap m;
      m.warp = a.warp;
      m.direction = 1;
      std::copy(s.crat.begin(), s.crat.end(), m.gpr.begin());
      std::copy(s.cprat.begin(), s.cprat.end(), m.pred.begin());
      out.maps.push_back(m);
      s.st = WarpState::kAllocated;
      s.retired_since_restore = 0;
      break;
    }
    case kAllocRestoreActivate:
      if (s.st != WarpState::kAllocated || s.warp != a.warp)
        err("V-49: restore-activate for slot %u without its restore-allocate", a.slot);
      else s.st = WarpState::kActive;
      break;
    case kAllocFree:
      if (s.st == WarpState::kFree) break;
      if (s.warp != a.warp) { err("free of warp %u names slot %u, which holds %u", a.warp, a.slot, s.warp); break; }
      // After a demotion, migration is complete: only now are the
      // registers freed (V-27).
      if (s.st == WarpState::kDemoting) err("V-27: slot %u freed before it drained", a.slot);
      releaseSlot(a.slot);
      break;
    }
  }
  allocs_.clear();

  for (unsigned w : demotes_) {
    const int si = slotOf(w);
    if (si < 0) { err("demote of warp %u, which is not resident", w); continue; }
    Slot &s = slot_[si];
    if (s.st != WarpState::kActive) { err("demote of warp %u in state %d", w, int(s.st)); continue; }
    // Squash to retirement (Demotion): the resume PC is the oldest
    // unretired instruction's, or the next after the last retirement.
    s.resume_pc = s.count ? s.rob[s.head].u.pc : s.next_pc;
    if (!s.count)
      for (const Uop &u : decq_) if (u.warp == w) { s.resume_pc = u.pc; break; }
    for (unsigned c = 0; c != cfg_.ckpts; ++c) s.ckpt[c].live = false;   // FET resets its own
    for (unsigned k = 0; k != s.count; ++k) s.rob[(s.head + k) % cfg_.rob_depth].ckpt_live = false;
    squashAfter(unsigned(si), -1, true);
    s.rat = s.crat;
    s.prat = s.cprat;
    s.chwidth_hold = s.bar_hold = false;
    advanceEpoch(unsigned(si));
    epochNotice(unsigned(si));
    s.st = WarpState::kDemoting;
    s.map_sent = false;
    count("demote");
  }
  demotes_.clear();

  if (kill_pending_) {
    kill_pending_ = false;
    for (unsigned si = 0; si != slot_.size(); ++si) {
      Slot &s = slot_[si];
      if (s.st == WarpState::kFree || !((kill_mask_ >> (s.warp % 32)) & 1u)) continue;
      for (unsigned c = 0; c != cfg_.ckpts; ++c) s.ckpt[c].live = false;
      for (unsigned k = 0; k != s.count; ++k) s.rob[(s.head + k) % cfg_.rob_depth].ckpt_live = false;
      squashAfter(si, -1, true);
      s.rat = s.crat;
      s.prat = s.cprat;
      advanceEpoch(si);
      epochNotice(si);
      s.st = WarpState::kKilling;
      s.kill_epoch = kill_epoch_;
      count("kill");
    }
    // A kill naming nothing OOE holds is acked at once.
    bool any = false;
    for (const Slot &s : slot_) any = any || s.st == WarpState::kKilling;
    if (!any) out.kill_acks.push_back(kill_epoch_);
  }

  // Demotion and kill progress: wait for every outstanding memop and held
  // entry, and for the epoch notice to land in FET (A-74, V-57).
  bool killing = false, kill_done = true;
  for (unsigned si = 0; si != slot_.size(); ++si) {
    Slot &s = slot_[si];
    bool held = false;
    for (const RobEntry &r : s.rob) held = held || r.valid;
    const bool landed = s.notice_sent && now_ >= s.notice_lands;
    if (s.st == WarpState::kDemoting && !held && landed) {
      if (!s.map_sent) {
        RatMap m;
        m.warp = s.warp;
        m.direction = 0;
        std::copy(s.crat.begin(), s.crat.end(), m.gpr.begin());
        std::copy(s.cprat.begin(), s.cprat.end(), m.pred.begin());
        out.maps.push_back(m);
        s.map_sent = true;
      } else {
        out.drained.push_back({s.warp, s.resume_pc});
        s.st = WarpState::kDrained;
      }
    }
    if (s.st == WarpState::kKilling) {
      killing = true;
      if (!held && landed) {
        releaseSlot(si);
      } else {
        kill_done = false;
      }
    }
  }
  if (killing && kill_done) out.kill_acks.push_back(kill_epoch_);

  if (released_) {
    for (unsigned si = 0; si != slot_.size(); ++si) {
      Slot &s = slot_[si];
      if (s.st == WarpState::kFree || !s.bar_hold || !((released_ >> (s.warp % 32)) & 1u)) continue;
      for (unsigned k = 0; k != s.count; ++k) {
        const unsigned idx = (s.head + k) % cfg_.rob_depth;
        RobEntry &r = s.rob[idx];
        if (r.u.attr.serial == kSerBarrier && !r.complete) { r.complete = true; break; }
      }
    }
    released_ = 0;
  }
}

// ---- retire (V-19, V-24) -------------------------------------------------------------------

void Core::retire() {
  unsigned ports = 0;
  for (unsigned k = 0; k != slot_.size(); ++k) {
    const unsigned si = (rr_select_ + k) % slot_.size();
    Slot &s = slot_[si];
    if (s.st != WarpState::kActive) continue;
    // Head-stall timer: the demotion triggers' input (Demotion; Q18).
    if (s.count) {
      const unsigned h = tagOf(si, s.head);
      if (s.head_seen != h) { s.head_seen = h; s.head_since = now_; s.stalled_reported = s.miss_reported = false; }
    }
    unsigned n = 0;
    while (n != cfg_.retire_per_rob && s.count && !s.fault_stop) {
      RobEntry &r = s.rob[s.head];
      // A barrier wait leaves OOE only once it is the oldest instruction, so
      // it is never sent from a wrong path; younger uops hold at rename.
      if (r.u.attr.serial == kSerBarrier && !r.committed) {
        Bar b;
        b.warp = s.warp;
        b.barrier_id = r.u.imm;    // temporary: A-75 names the field
        out.bars.push_back(b);
        r.committed = true;
      }
      if (!r.complete) break;
      if (r.fault) {
        // Faults are taken at retirement: stop, report, let RAU's kill clean
        // up (Faults; V-24). OOE does not squash.
        s.fault_stop = true;
        Status st;
        st.warp = s.warp;
        st.fault_taken = true;
        out.status.push_back(st);
        Fault f;
        f.warp = s.warp;
        f.cause = r.fault_cause;
        f.pc = r.u.pc;
        f.lane_mask = r.fault_lanes;
        f.address = r.fault_addr;
        out.faults.push_back(f);
        count("fault");
        ev("fault", s.warp, r.fault_cause, r.u.pc, r.u.tid);
        break;
      }
      if (r.is_store && !r.committed) {
        if (ports == cfg_.retire_msgs) { count("stall.retire_port"); break; }
        Commit c;
        c.tid = r.u.tid;
        c.port = ports++;
        c.rob_tag = tagOf(si, s.head);
        out.commits.push_back(c);
        r.committed = true;
      }
      // Commit the mapping; free the one it replaced: no older instruction
      // can still read it, and every younger one reads the new name.
      if (r.alloc_gpr) {
        s.crat[r.u.dst & 15] = r.pnew;
        freeGpr(si, cfg_.inject_free_new ? r.pnew : r.pold);
      }
      if (r.u.pred_we) {
        if (cfg_.rename_preds) {
          s.cprat[r.u.pred_dst & 3] = r.ppnew;
          freePred(si, r.ppold);
        } else {
          s.cprat[r.u.pred_dst & 3] = r.ppnew;
        }
      }
      if (r.u.attr.serial == kSerChwidth) {
        s.chwidth = r.u.imm & 3u;     // temporary: A-75 names the field
        s.chwidth_hold = false;
      }
      if (r.u.attr.serial == kSerBarrier) s.bar_hold = false;
      const uint64_t next = r.u.pc + 2 * (r.u.ilen + 1);
      s.next_pc = r.u.attr.branch && r.taken ? next + uint64_t(2 * int64_t(int32_t(r.u.imm))) : next;
      Retired rt;
      rt.tid = r.u.tid;
      rt.warp = s.warp;
      rt.rob_tag = tagOf(si, s.head);
      rt.exit = r.u.shape.exit;
      rt.writes_gpr = r.alloc_gpr;
      rt.dst = r.u.dst & 15;
      rt.pnew = r.pnew;
      rt.writes_pred = r.alloc_pred;
      rt.pdst = r.u.pred_dst & 3;
      rt.ppnew = r.ppnew;
      retired.push_back(rt);
      ev("retire", s.warp, rt.rob_tag, r.u.group_mask, r.u.tid);
      ++s.retired_since_restore;
      r = RobEntry();
      s.head = (s.head + 1) % cfg_.rob_depth;
      --s.count;
      ++n;
    }
    ++histograms["retire_per_cycle"][n];
    // Demotion triggers at the head (Q18): reported to RAU, which decides.
    if (s.count && !s.fault_stop) {
      const RobEntry &h = s.rob[s.head];
      const uint64_t stall = now_ - s.head_since;
      if (h.is_load && h.mlc_miss && stall > cfg_.demote_mlc_miss && !s.miss_reported) {
        out.status.push_back({s.warp, false, true, true, s.retired_since_restore});
        s.miss_reported = true;
        count("demote_trigger.mlc_miss");
        oev(OoeEv::kDemoteTrigger, s.warp, 0, stall, h.u.tid);
      }
      const unsigned lim = s.bar_hold ? cfg_.demote_barrier : cfg_.demote_fallback;
      if (stall > lim && !s.stalled_reported) {
        out.status.push_back({s.warp, false, true, h.mlc_miss, s.retired_since_restore});
        s.stalled_reported = true;
        count(s.bar_hold ? "demote_trigger.barrier" : "demote_trigger.fallback");
        oev(OoeEv::kDemoteTrigger, s.warp, s.bar_hold ? 1 : 2, stall, h.u.tid);
      }
    }
  }
}

// ---- select (Select; Q-4) --------------------------------------------------------------------

/// The fixed-window predicate fallback (Config::rename_preds off): a write
/// to a window register waits until every older reader of it has issued in
/// an earlier cycle and every older writer of it has completed.
bool Core::predHold(unsigned slot, const RobEntry &r) const {
  if (cfg_.rename_preds || !r.u.pred_we) return false;
  const Slot &s = slot_[slot];
  const unsigned me = r.ppnew;
  for (unsigned k = 0; k != s.count; ++k) {
    const RobEntry &o = s.rob[(s.head + k) % cfg_.rob_depth];
    if (&o == &r) break;
    if (!o.valid) continue;
    if (o.u.pred_we && o.ppnew == me && !o.complete) return true;     // WAW
    bool reads = false;
    if ((o.u.shape.guard || o.u.shape.pdata) && o.ppguard == me) reads = true;
    if (o.u.shape.pred_logic && (o.pq[0] == me || o.pq[1] == me)) reads = true;
    if (o.u.pred_we && o.merge && o.ppold == me) reads = true;
    if (!reads) continue;
    if (o.complete) continue;
    const bool issued_before = o.rs_main == kNoEntry ||
        (rs_[o.rs_main].issued && rs_[o.rs_main].issue_at < now_);
    if (!issued_before) return true;                                    // WAR
  }
  return false;
}

/// Select over resources (OI-31, OI-33): S0-S3, R and P0-P3, bits 0 to 8.
/// Each resource grants its oldest ready requester; an entry issues only
/// if it wins every resource its footprint names, so co-issued footprints
/// are disjoint by construction (V-60) and no grant count feeds another
/// pick. The oldest ready entry wins all its resources, so it always
/// issues. A masked load's copy is a lane op of its own and issues at
/// least a cycle before its load (V-61).
void Core::selectSectioned() {
  constexpr unsigned kRes = 9, kP0 = 5;
  unsigned busy = 0;
  std::vector<bool> memop_block(slot_.size(), false);
  // A bulk discard takes P0 for the cycle, and no memop of its warp goes
  // with it (V-23).
  if (!discards_.empty()) {
    Memop d = discards_.front();
    discards_.pop_front();
    d.port = 0;
    busy |= 1u << kP0;
    const int si = slotOf(d.warp);
    if (si >= 0) memop_block[si] = true;
    out.memops.push_back(d);
  }
  auto memopOrderOk = [&](const Slot &s, const RobEntry &r) {
    // Program order per warp (OI-15), or OA-13's relaxation: a plain load
    // passes older loads, never a store, atomic, fence or ordered access.
    const bool plain_load = r.is_load && r.u.ordering == 0 && r.u.attr.mem_kind == kMemKLoad;
    for (unsigned k = 0; k != s.count; ++k) {
      const RobEntry &o = s.rob[(s.head + k) % cfg_.rob_depth];
      if (&o == &r) break;
      if (!o.valid || !o.is_mem || o.rs_main == kNoEntry || rs_[o.rs_main].issued) continue;
      if (cfg_.loads_pass_loads && plain_load && o.is_load && o.u.ordering == 0 &&
          o.u.attr.mem_kind == kMemKLoad)
        continue;
      return false;
    }
    return true;
  };
  auto ready = [&](unsigned e) -> bool {
    const RsEntry &x = rs_[e];
    if (!x.valid || x.issued || x.eligible_at > now_ || (x.res & busy)) return false;
    const Slot &s = slot_[x.slot];
    if (s.st != WarpState::kActive) return false;
    if (!rowReady(e)) return false;
    const RobEntry &r = s.rob[x.rob];
    if (predHold(x.slot, r)) return false;
    // The copy's sources are confirmed before it issues, so it cannot be
    // cancelled once its load has gone (V-61).
    if (x.copy) return rowConfirmed(e);
    if (x.cls != RsCls::kMiu) return true;
    if (memop_block[x.slot] || !rowConfirmed(e)) return false;
    // V-61: the copy went in an earlier cycle (or has confirmed and freed).
    if (r.copy && r.rs_copy != kNoEntry && (!rs_[r.rs_copy].issued || rs_[r.rs_copy].issue_at >= now_))
      return false;
    return memopOrderOk(s, r);
  };
  std::vector<unsigned> cand;
  for (unsigned e = 0; e != n_; ++e)
    if (ready(e)) cand.push_back(e);
  std::array<unsigned, kRes> win;
  win.fill(kNoEntry);
  for (unsigned e : cand)
    for (unsigned k = 0; k != kRes; ++k)
      if (((rs_[e].res >> k) & 1u) && (win[k] == kNoEntry || rs_[e].age < rs_[win[k]].age)) win[k] = e;
  std::vector<unsigned> grant;
  for (unsigned e : cand) {
    bool all = true, some = false;
    for (unsigned k = 0; k != kRes; ++k)
      if ((rs_[e].res >> k) & 1u) {
        if (win[k] == e) some = true;
        else all = false;
      }
    if (all) grant.push_back(e);
    else if (some) count("select.lost_resource");   // won a section, lost another
  }
  std::sort(grant.begin(), grant.end(), [&](unsigned a, unsigned b) { return rs_[a].age < rs_[b].age; });
  unsigned used = busy, issued = 0;
  for (unsigned e : grant) {
    if (used & rs_[e].res) { err("V-60: a resource granted twice in a cycle"); continue; }
    used |= rs_[e].res;
    const RsEntry &x = rs_[e];
    const RobEntry &r = slot_[x.slot].rob[x.rob];
    const unsigned port = unsigned(__builtin_ctz(x.res));
    const unsigned secs = unsigned(__builtin_popcount(x.res & 0xFu));
    if (secs) ++histograms["sections_per_op.w" + std::to_string(r.u.w)][secs];
    // V-63: every lane operand inside the footprint.
    if (!(x.res >> 4) && !cfg_.inject_narrow_footprint) {
      const unsigned want = resOf(r, x.copy) & 0xFu;
      if ((want & ~x.res) != 0) err("V-63: rob tag %u has an operand outside its footprint", tagOf(x.slot, x.rob));
    }
    if (x.copy) issueCopy(x.slot, x.rob, port);
    else doIssue(e, port, false, 0);
    ++issued;
  }
  ++histograms["issue_per_cycle"][issued];
  ++histograms["sections_idle"][4 - unsigned(__builtin_popcount(used & 0xFu))];
  for (unsigned e : cand)
    if (!rs_[e].issued) {
      count("ready_not_selected");
      oev(OoeEv::kReadyNotSelected, slot_[rs_[e].slot].warp, e, 0, slot_[rs_[e].slot].rob[rs_[e].rob].u.tid);
    }
  rr_select_ = (rr_select_ + 1) % slot_.size();
}

void Core::select() {
  if (cfg_.sectioned) { selectSectioned(); return; }
  unsigned ports = 0, mports = 0;
  // resource_cap's groups claimed this cycle: lane sections, pipes, R.
  bool lane_used = false, pipes_used = false, r_used = false;
  std::vector<bool> memop_block(slot_.size(), false);
  // Bulk discards first: each takes a memop slot, and no memop of the same
  // warp goes in the same cycle (V-23).
  while (!discards_.empty() && mports != cfg_.memop_width) {
    Memop d = discards_.front();
    discards_.pop_front();
    d.port = mports++;
    const int si = slotOf(d.warp);
    if (si >= 0) memop_block[si] = true;
    out.memops.push_back(d);
  }

  // Ready entries per warp, oldest first, per class.
  auto ready = [&](unsigned e, bool miu) -> bool {
    const RsEntry &x = rs_[e];
    if (!x.valid || x.issued || x.copy || x.eligible_at > now_) return false;
    const Slot &s = slot_[x.slot];
    if (s.st != WarpState::kActive) return false;
    if (!rowReady(e)) return false;
    const RobEntry &r = s.rob[x.rob];
    if (predHold(x.slot, r)) return false;
    if (!miu) return true;
    // A memop issues only once its sources are confirmed (V-17), in program
    // order within its warp (MIU orders memory; OOE does not disambiguate).
    if (!rowConfirmed(e)) return false;
    if (r.copy && (rs_[r.rs_copy].issued || !rowReady(r.rs_copy) || !rowConfirmed(r.rs_copy)))
      return false;
    for (unsigned k = 0; k != s.count; ++k) {
      const RobEntry &o = s.rob[(s.head + k) % cfg_.rob_depth];
      if (&o == &r) break;
      if (o.valid && o.is_mem && o.rs_main != kNoEntry && !rs_[o.rs_main].issued) return false;
    }
    return true;
  };
  auto oldest = [&](unsigned slot, bool miu) -> unsigned {
    const unsigned lo = miu ? cfg_.rs_rcu : 0, hi = miu ? n_ : cfg_.rs_rcu;
    unsigned best = kNoEntry;
    for (unsigned e = lo; e != hi; ++e)
      if (rs_[e].valid && rs_[e].slot == slot && ready(e, miu) &&
          (best == kNoEntry || rs_[e].age < rs_[best].age))
        best = e;
    return best;
  };


  // MIU class first, then RCU: each round gives every warp, from the
  // rotating priority, its oldest ready entry (Select).
  for (int pass = 0; pass != 2; ++pass) {
    const bool miu = pass == 0;
    for (bool progress = true; progress;) {
      progress = false;
      for (unsigned k = 0; k != slot_.size(); ++k) {
        const unsigned si = (rr_select_ + k) % slot_.size();
        if (ports == cfg_.issue_width) break;
        if (miu && (mports == cfg_.memop_width || memop_block[si])) continue;
        const unsigned e = oldest(si, miu);
        if (e == kNoEntry) continue;
        const RobEntry &r = slot_[si].rob[rs_[e].rob];
        const unsigned need = r.copy ? 2 : 1;
        if (ports + need > cfg_.issue_width) { count("stall.copy_port"); continue; }
        if (cfg_.resource_cap) {
          const bool rcu_op = !miu && r.u.attr.exec_rcu;
          const bool lane = (!miu && !rcu_op) || r.copy;
          if ((lane && lane_used) || (miu && pipes_used) || (rcu_op && r_used)) {
            count("stall.resource");
            continue;
          }
          lane_used |= lane;
          pipes_used |= miu;
          r_used |= rcu_op;
        }
        const unsigned port = ports;
        ports += need;
        if (miu) ++mports;
        doIssue(e, port, r.copy, port + 1);
        progress = true;
      }
    }
  }
  ++histograms["issue_per_cycle"][ports];
  for (unsigned e = 0; e != n_; ++e) {
    const RsEntry &x = rs_[e];
    if (!x.valid || x.issued || x.copy || x.eligible_at > now_ ||
        slot_[x.slot].st != WarpState::kActive || !rowReady(e))
      continue;
    const bool miu = e >= cfg_.rs_rcu;
    if (miu && !x.ready_seen) {
      rs_[e].ready_seen = true;
      rs_[e].ready_since = now_;
    }
    // Counterfactual (Memory operations): a memop held only on an
    // unconfirmed source while an MIU slot went unused.
    const unsigned w = slot_[x.slot].warp;
    const uint64_t tid = slot_[x.slot].rob[x.rob].u.tid;
    if (miu && !rowConfirmed(e) && mports != cfg_.memop_width) {
      count("memop.held_unconfirmed");
      oev(OoeEv::kMemopHeld, w, e, 0, tid);
    } else if (predHold(x.slot, slot_[x.slot].rob[x.rob])) {
      count("hold.pred_window");
    } else {
      count("ready_not_selected");   // per entry per cycle (Events)
      oev(OoeEv::kReadyNotSelected, w, e, 0, tid);
    }
  }
  rr_select_ = (rr_select_ + 1) % slot_.size();
}

/// The issue a granted entry sends on ccv_ooe_rcu_issue.
Issue Core::makeIssue(unsigned slot, unsigned idx, unsigned port) const {
  const Slot &s = slot_[slot];
  const RobEntry &r = s.rob[idx];
  const Uop &u = r.u;
  Issue is;
  is.tid = u.tid;
  is.port = port;
  is.rob_tag = tagOf(slot, idx);
  is.warp = s.warp;
  is.issue_mask = u.group_mask;          // V-54: the mask it arrived with
  for (unsigned i = 0; i != 3; ++i) is.psrc[i] = r.psrc[i];
  is.pdst = r.alloc_gpr ? r.pnew : 0;
  is.merge = r.merge;
  is.pold = r.merge ? r.pold : 0;
  is.ppguard = r.ppguard;
  is.pred_neg = u.pred_neg;
  // Fixed-window mode names the window even unwritten, as the S1 stub did.
  is.ppdst = u.pred_we ? r.ppnew : cfg_.rename_preds ? 0 : cfg_.pred_window(s.warp, u.pred_dst);
  is.pred_we = u.pred_we;
  is.ppold = r.merge ? r.ppold : 0;
  is.opcode = u.opcode;
  is.chwidth = s.chwidth;
  is.guarded = u.shape.guard;
  is.gpr_reads = u.shape.gpr_reads;
  // The resource group and footprint. Sectioned: the entry's own resources
  // (resOf). Otherwise every op is full width (TI's interim resource_cap).
  is.res = r.is_mem ? Issue::kMemop : u.attr.exec_rcu ? Issue::kRcuOp : Issue::kLaneOp;
  is.footprint = is.res == Issue::kRcuOp ? 0 : 0xF;
  if (cfg_.sectioned) {
    const unsigned m = resOf(r, false);
    is.res = m >> 5 ? Issue::kMemop : m >> 4 ? Issue::kRcuOp : Issue::kLaneOp;
    is.footprint = uint8_t(is.res == Issue::kMemop ? m >> 5 : is.res == Issue::kRcuOp ? 0 : m & 0xFu);
  }
  is.byp_group = uint8_t((u.attr_raw >> 13) & 7u);
  if (!r.is_mem) {
    is.send_imm = true;
    // srd: identity is OOE's to substitute (A-25): warp_base for %ctatid
    // (the lane ORs its index in), %ctaid for selector 1.
    is.imm = u.shape.srd == 0 ? s.warp_in_cta << 5 : u.shape.srd == 1 ? s.ctaid : u.imm;
    // Predicate logic's two sources, renamed: each physical predicate with
    // its negate above it, where DEC's qualifiers were (TI-1).
    if (u.shape.pred_logic) {
      constexpr unsigned w = ccv::prov::kWPhysPred;
      auto q = [&](unsigned pp, unsigned qual) { return pp | ((qual >> 2) & 1u) << w; };
      is.imm = q(r.pq[0], u.imm & 7) | q(r.pq[1], (u.imm >> 3) & 7) << (w + 1);
    }
  }
  return is;
}

/// The masked load's copy-only op (A-33, A-38): the load's issue under
/// CCV_OP_PRF_COPY. An unguarded load masked only by its issue mask names
/// the zero predicate negated: all ones.
void Core::issueCopy(unsigned slot, unsigned idx, unsigned copy_port) {
  Slot &s = slot_[slot];
  RobEntry &r = s.rob[idx];
  const Uop &u = r.u;
  const Issue is = makeIssue(slot, idx, copy_port);
  RsEntry &c = rs_[r.rs_copy];
  c.issued = true;
  c.issue_at = now_;
  c.ever_issued = true;
  setWakes(r.rs_copy);
  Issue cp = is;
  cp.port = copy_port;
  cp.copy = true;
  cp.res = Issue::kLaneOp;       // the copy runs through a lane
  cp.footprint = uint8_t(cfg_.sectioned ? resOf(r, true) & 0xFu : 0xFu);
  cp.send_imm = true;
  cp.imm = 0;
  if (!u.shape.guard) {
    cp.ppguard = cfg_.pred_zero;
    cp.pred_neg = true;
  }
  out.issues.push_back(cp);
  r.copy_pending = true;
  r.copy_land = now_ + cfg_.payload_stages + cfg_.lat_lane;
  ev("copy", s.warp, is.rob_tag, 0, u.tid);
  oev(OoeEv::kCopyIssue, s.warp, is.rob_tag, copy_port, u.tid);
  ev("issue", s.warp, copy_port, r.rs_copy, u.tid);
}

void Core::doIssue(unsigned e, unsigned port, bool with_copy, unsigned copy_port) {
  RsEntry &x = rs_[e];
  Slot &s = slot_[x.slot];
  RobEntry &r = s.rob[x.rob];
  const Uop &u = r.u;
  x.issued = true;
  x.issue_at = now_;
  // Memop hold cycles (Events): from the first cycle its operands were all
  // woken to its issue, the cost of waiting for confirmation.
  if (x.cls == RsCls::kMiu) {
    const uint64_t held = x.ready_seen ? now_ - x.ready_since : 0;
    ++histograms["memop_hold_cycles"][held];
    oev(OoeEv::kMemopHoldCycles, s.warp, tagOf(x.slot, x.rob), held, u.tid);
  }
  const bool first = !x.ever_issued;
  x.ever_issued = true;
  setWakes(e);
  // V-05: merge_en = 0 only with a full mask and no guard.
  if (!r.merge && (u.group_mask != kFullMask || u.shape.guard))
    err("V-05: rob tag %u issues without merge under a partial mask or guard", tagOf(x.slot, x.rob));

  const Issue is = makeIssue(x.slot, x.rob, port);
  out.issues.push_back(is);
  if (!r.is_mem || cfg_.memop_rcu_done) ++r.rcu_dones_owed;
  r.rcu_issue_at = now_;
  ev("issue", s.warp, port, e, u.tid);
  if (first) {
    if (r.merge) ev("merge", s.warp, is.rob_tag, 0, u.tid);
    for (unsigned i = 0; i != 3; ++i)
      if (((u.shape.gpr_reads >> i) & 1u) && isZeroName(r.psrc[i])) ev("zero_read", s.warp, i, 0, u.tid);
    if (r.merge && r.alloc_gpr && isZeroName(r.pold)) ev("zero_read", s.warp, 3, 0, u.tid);
  } else {
    count("reissue");
  }

  if (with_copy) issueCopy(x.slot, x.rob, copy_port);
  if (r.is_mem) {
    Memop m;
    m.tid = u.tid;
    m.port = cfg_.sectioned ? port - 5 : port;   // sectioned: the pipe, P0-P3
    m.rob_tag = is.rob_tag;
    m.warp = s.warp;
    m.mem_op = u.mem_op;                 // DEC's, unexamined (A-68)
    m.issue_mask = u.group_mask;
    m.pdst = r.alloc_gpr ? r.pnew : 0;
    m.ppred = u.pred_we ? r.ppnew : cfg_.rename_preds ? 0 : cfg_.pred_window(s.warp, u.pred_dst);
    m.disp = u.imm;
    m.scale_en = u.scale_en;
    m.space = u.space;
    m.ordering = u.ordering;
    m.chwidth = s.chwidth;
    out.memops.push_back(m);
    r.at_miu = true;
  }
}

// ---- rename (Rename) ---------------------------------------------------------------------------

bool Core::tryRename(unsigned si, const Uop &u) {
  Slot &s = slot_[si];
  if (s.st != WarpState::kActive) { count("hold.inactive"); return false; }
  if (s.fault_stop) { count("hold.fault"); return false; }
  if (s.chwidth_hold) {
    count("hold.chwidth");
    oev(OoeEv::kChwidthHold, s.warp, tagOf(si, s.chwidth_rob), 0, u.tid);
    return false;
  }
  if (s.bar_hold) {
    count("hold.barrier");
    oev(OoeEv::kBarrierHold, s.warp, s.bar_id, 0, u.tid);
    return false;
  }
  if (s.count == cfg_.rob_depth) {
    count("stall.rob_full");
    oev(OoeEv::kRobFull, s.warp, s.count, 0, u.tid);
    return false;
  }
  if (s.rob[s.tail].valid) {
    count("stall.rob_slot_held");
    oev(OoeEv::kRobSlotHeld, s.warp, tagOf(si, s.tail), 0, u.tid);
    return false;
  }
  const SchedAttr &a = u.attr;
  const bool nop = u.shape.exit || u.decode_fault;
  const bool mem = !nop && a.rs_miu;
  const bool full = u.group_mask == kFullMask;
  const bool merge = !nop && (!full || u.shape.guard);
  const bool wgpr = !nop && a.writes_gpr;
  const bool copy = mem && a.mem_kind == kMemKLoad && wgpr && merge;
  // Reservation stations: class space and the per-warp cap (V-14).
  if (!nop) {
    unsigned free_rcu = 0, free_miu = 0;
    for (unsigned e = 0; e != cfg_.rs_rcu; ++e) free_rcu += !rs_[e].valid;
    for (unsigned e = cfg_.rs_rcu; e != n_; ++e) free_miu += !rs_[e].valid;
    const unsigned need_rcu = (mem ? 0 : 1) + (copy ? 1 : 0), need_miu = mem ? 1 : 0;
    if (free_rcu < need_rcu) {
      count("stall.rs_full.rcu");
      oev(OoeEv::kRsFull, s.warp, 0, free_rcu, u.tid);
      return false;
    }
    if (free_miu < need_miu) {
      count("stall.rs_full.miu");
      oev(OoeEv::kRsFull, s.warp, 1, free_miu, u.tid);
      return false;
    }
    const unsigned cap = cfg_.rs_warp_cap ? cfg_.rs_warp_cap : n_;
    if (s.rs_held + need_rcu + need_miu > cap) {
      count("stall.rs_warp_cap");
      oev(OoeEv::kRsWarpCap, s.warp, s.rs_held, cap, u.tid);
      return false;
    }
  }
  unsigned pos = 0, plan = 0;
  if (wgpr && cfg_.sectioned) {
    pos = placePos(si, u, merge);
    plan = planSlice(si, u.w, pos, gprAllowed(si, 1));
  }
  if (wgpr && (cfg_.sectioned ? plan == 2 : !gprAllowed(si, 1))) {
    if (gfree_.empty()) {
      count("stall.gpr_empty");
      oev(OoeEv::kGprEmpty, s.warp, s.held_gpr, gfree_.size(), u.tid);
    } else if (s.held_gpr + 1 > kArchGprs + cfg_.ren_ceil) {
      count("stall.gpr_ceiling");
      oev(OoeEv::kRenameLimit, s.warp, 1, 0, u.tid);
    } else {
      count("stall.gpr_floor");
      oev(OoeEv::kRenameLimit, s.warp, 0, 0, u.tid);
    }
    return false;
  }
  if (!nop && u.pred_we && cfg_.rename_preds && !predAllowed(si, 1)) {
    if (pfree_.empty()) {
      count("stall.pred_empty");
      oev(OoeEv::kPredEmpty, s.warp, s.held_pred, 0, u.tid);
    } else {
      count("stall.pred_floor_ceiling");
      oev(OoeEv::kRenameLimit, s.warp, s.held_pred + 1 > kArchPreds + cfg_.pred_ren_ceil ? 1 : 0,
          1, u.tid);
    }
    return false;
  }
  if (!nop && a.branch) {
    if (u.ckpt >= cfg_.ckpts) { err("branch names checkpoint %u", u.ckpt); return false; }
    if (s.ckpt[u.ckpt].live) {
      err("V-07: warp %u branch takes checkpoint %u, which is live", s.warp, u.ckpt);
      return false;
    }
  }

  // -- commit the rename ---------------------------------------------------------------
  const unsigned idx = s.tail;
  RobEntry &r = s.rob[idx];
  r = RobEntry();
  r.valid = true;
  r.u = u;
  r.seq = s.next_seq++;
  r.is_mem = mem;
  r.is_store = mem && a.mem_kind == kMemKStore;
  r.is_load = mem && a.mem_kind == kMemKLoad;
  r.copy = copy;
  r.merge = merge;          // merge_en: as the issue carries it (V-05)
  if (!nop) {
    // Sources and old destinations read the RAT before this uop's writes.
    for (unsigned i = 0; i != 3; ++i) r.psrc[i] = s.rat[u.src[i] & 15];
    r.pold = s.rat[u.dst & 15];
    r.ppguard = s.prat[u.pred_guard & 3];
    r.ppold = s.prat[u.pred_dst & 3];
    if (u.shape.pred_logic) {
      r.pq[0] = s.prat[u.imm & 3];
      r.pq[1] = s.prat[(u.imm >> 3) & 3];
    }
    if (wgpr) {
      r.pnew = cfg_.sectioned ? allocSlice(si, u.w, pos) : allocGpr(si);
      r.alloc_gpr = true;
      s.rat[u.dst & 15] = r.pnew;
    }
    if (u.pred_we) {
      r.ppnew = allocPred(si, u.pred_dst & 3);
      r.alloc_pred = cfg_.rename_preds;
      s.prat[u.pred_dst & 3] = r.ppnew;
    }
    if (a.branch) {
      // The RAT checkpoint, under FET's checkpoint ID (Q8, A-42).
      Ckpt &c = s.ckpt[u.ckpt];
      c.live = true;
      c.gpr = s.rat;
      c.pred = s.prat;
      r.ckpt_live = true;
    }
    if (a.serial == kSerChwidth) { s.chwidth_hold = true; s.chwidth_rob = idx; }
    if (a.serial == kSerBarrier) { s.bar_hold = true; s.bar_id = u.imm; }   // A-75 names the field
    // Reservation stations: the main entry, and a masked load's copy (A-38).
    r.rs_main = rsAlloc(mem ? RsCls::kMiu : RsCls::kRcu, si, idx, false);
    rs_[r.rs_main].produces = wgpr || u.pred_we;
    if (copy) {
      r.rs_copy = rsAlloc(RsCls::kRcu, si, idx, true);
      rs_[r.rs_copy].produces = true;
    }
    addDeps(r.rs_main, r, false);
    if (copy) addDeps(r.rs_copy, r, true);
    if (cfg_.sectioned) {
      rs_[r.rs_main].res = resOf(r, false);
      if (copy) rs_[r.rs_copy].res = resOf(r, true);
    }
    // OA-14: the rotating home advances at each taken backward branch. It is
    // a hint, not state: nothing checkpoints or restores it.
    if (a.branch && u.pred_taken && u.backward) s.home_ctr = (s.home_ctr + 1) & 3u;
    // This uop is now the producer of its destinations.
    if (wgpr) gprod_[r.pnew] = {r.rs_main, copy ? r.rs_copy : kNoEntry};
    if (u.pred_we) pprod_[r.ppnew] = {r.rs_main, kNoEntry};
  }
  if (u.decode_fault) {
    r.fault = true;
    r.fault_cause = 3;      // placeholder: the cause encoding is CRU's
  }
  s.tail = (s.tail + 1) % cfg_.rob_depth;
  ++s.count;
  if (nop) complete(si, idx);
  ev("dispatch", s.warp, tagOf(si, idx), 0, u.tid);
  return true;
}

void Core::rename() {
  unsigned budget = cfg_.rename_width;
  std::vector<bool> blocked(slot_.size(), false);
  for (bool progress = true; progress && budget;) {
    progress = false;
    for (unsigned k = 0; k != slot_.size() && budget; ++k) {
      const unsigned si = (rr_rename_ + k) % slot_.size();
      if (blocked[si] || slot_[si].st == WarpState::kFree) continue;
      const unsigned w = slot_[si].warp;
      auto it = std::find_if(decq_.begin(), decq_.end(), [&](const Uop &u) { return u.warp == w; });
      if (it == decq_.end()) continue;
      // V-53: no stale-epoch uop is renamed.
      if (it->fetch_epoch != epoch_[w]) {
        ev("epoch_drop", w, it->fetch_epoch, 0, it->tid);
        decq_.erase(it);
        --slot_[si].decq;
        progress = true;
        continue;
      }
      if (tryRename(si, *it)) {
        decq_.erase(it);
        --slot_[si].decq;
        --budget;
        progress = true;
      } else {
        blocked[si] = true;
      }
    }
  }
  if (!budget) count("rename.full_width");
  rr_rename_ = (rr_rename_ + 1) % slot_.size();
}

void Core::sendRedirect() {
  // Rate 1 (A-6): one redirect or epoch notice a cycle, oldest first.
  if (!redirects_.empty()) {
    const Redirect r = redirects_.front();
    redirects_.pop_front();
    out.redirects.push_back(r);
    const int si = slotOf(r.warp);
    if (r.epoch_only && si >= 0) {
      slot_[si].notice_sent = true;
      slot_[si].notice_lands = now_ + cfg_.redirect_lat;
    }
    if (!redirects_.empty()) {
      count("stall.redirect_busy", redirects_.size());
      oev(OoeEv::kRedirectBusy, redirects_.front().warp, redirects_.size(), 0, redirects_.front().tid);
    }
  }
  // Every checkpoint freed this cycle, in one message (A-56).
  out.free_mask = free_mask_;
  free_mask_ = 0;
}

// ---- invariants -----------------------------------------------------------------------------------

void Core::checkInvariants() {
  static const unsigned kReportOnce = 1;
  std::map<std::string, unsigned> seen;
  auto bad = [&](const std::string &id, const std::string &what) {
    ++counters["invariant." + id];
    if (counters["invariant." + id] <= kReportOnce) err("%s: %s", id.c_str(), what.c_str());
  };
  char buf[256];
  // V-01: free list + every slot's owned registers partition the pool, and
  // a slot owns exactly its committed map plus its in-flight destinations.
  std::vector<int> where(cfg_.phys_regs, -1);
  for (unsigned p = 0; p != cfg_.phys_regs; ++p)
    if (gfree_.has(p)) where[p] = 99;
  for (unsigned si = 0; si != slot_.size(); ++si) {
    const Slot &s = slot_[si];
    std::set<unsigned> own;
    for (unsigned p : s.crat) if (!isZeroName(p)) own.insert(p);
    for (const RobEntry &r : s.rob)
      if (r.valid && r.alloc_gpr) {
        if (isZeroName(r.pnew)) bad("V-29", "a write names the zero register");
        if (!own.insert(r.pnew).second) {
          std::snprintf(buf, sizeof buf, "slot %u: p%u is both committed and in flight", si, r.pnew);
          bad("V-01", buf);
        }
      }
    if (cfg_.sectioned) {
      // Sectioned (OI-29): the slot's live slices, by row. Every live section
      // of a row belongs to its owner (V-62), the row's section mask is
      // exactly its live slices', which never overlap, and the slot counts
      // its rows.
      std::map<unsigned, unsigned> rowsec;
      for (unsigned p : own) {
        const unsigned row = nameRow(p), m = sectionsOf(p);
        if (rowsec[row] & m) {
          std::snprintf(buf, sizeof buf, "slot %u: slices overlap in row %u", si, row);
          bad("V-01", buf);
        }
        rowsec[row] |= m;
      }
      for (const auto &rm : rowsec) {
        if (rm.first >= cfg_.phys_regs) continue;
        if (rowOwner_[rm.first] != si + 1 || rowSec_[rm.first] != rm.second) {
          std::snprintf(buf, sizeof buf, "row %u: owner %d, sections %x; slot %u lives in %x", rm.first,
                        int(rowOwner_[rm.first]) - 1, unsigned(rowSec_[rm.first]), si, rm.second);
          bad("V-62", buf);
        }
      }
      own.clear();
      for (const auto &rm : rowsec) own.insert(rm.first);
    }
    if (own.size() != s.held_gpr) {
      std::snprintf(buf, sizeof buf, "slot %u owns %zu registers but counts %u", si, own.size(), s.held_gpr);
      bad("V-01", buf);
    }
    for (unsigned p : own) {
      if (p >= cfg_.phys_regs) continue;
      if (where[p] != -1) {
        std::snprintf(buf, sizeof buf, "p%u is owned by slot %u and %s", p, si,
                      where[p] == 99 ? "free" : "another slot");
        bad("V-01", buf);
      }
      where[p] = int(si);
    }
    // V-04: at or under the ceiling.
    if (s.held_gpr > kArchGprs + cfg_.ren_ceil) bad("V-04", "a slot over its GPR ceiling");
    if (cfg_.rename_preds && s.held_pred > kArchPreds + cfg_.pred_ren_ceil)
      bad("V-04", "a slot over its predicate ceiling");
    // V-07: live checkpoints match unresolved branches one to one.
    unsigned live = 0;
    for (const Ckpt &c : s.ckpt) live += c.live;
    unsigned branches = 0;
    for (unsigned k = 0; k != s.count; ++k) {
      const RobEntry &r = s.rob[(s.head + k) % cfg_.rob_depth];
      if (r.valid && r.ckpt_live) {
        ++branches;
        if (!s.ckpt[r.u.ckpt].live) bad("V-07", "a branch names a dead checkpoint");
      }
    }
    if (live != branches) bad("V-07", "live checkpoints and unresolved branches differ");
    // V-58 (OI-11): a ROB entry completes only after every RS entry of its
    // uop has confirmed and freed.
    for (const RobEntry &r : s.rob)
      if (r.valid && !r.squashed && r.complete &&
          (r.rs_main != kNoEntry || r.rs_copy != kNoEntry))
        bad("V-58", "a complete ROB entry still holds an RS entry");
    if (s.rs_held > (cfg_.rs_warp_cap ? cfg_.rs_warp_cap : n_)) bad("V-14", "a warp over its RS cap");
  }
  unsigned accounted = 0;
  for (int w : where) accounted += w != -1;
  if (accounted != cfg_.phys_regs) {
    std::snprintf(buf, sizeof buf, "%u of %u GPRs are neither free nor owned", cfg_.phys_regs - accounted,
                  cfg_.phys_regs);
    bad("V-01", buf);
  }
  // V-04: free registers cover every slot's unmet floor.
  unsigned owed = 0;
  for (const Slot &s : slot_) {
    const unsigned want = kArchGprs + cfg_.ren_floor;
    owed += s.held_gpr < want ? want - s.held_gpr : 0;
  }
  if (gfree_.size() < owed) bad("V-04", "free GPRs no longer cover the slots' floors");
  if (cfg_.rename_preds) {
    // V-02, the predicate pool, by count.
    unsigned owned = 0, powed = 0;
    for (const Slot &s : slot_) {
      owned += s.held_pred;
      const unsigned want = kArchPreds + cfg_.pred_ren_floor;
      powed += s.held_pred < want ? want - s.held_pred : 0;
    }
    if (owned + pfree_.size() != cfg_.pred_regs) bad("V-02", "predicates neither free nor owned");
    if (pfree_.size() < powed) bad("V-04", "free predicates no longer cover the floors");
  }
  // V-10: dependencies only on older entries of the same warp, never self.
  for (unsigned i = 0; i != n_; ++i)
    for (unsigned j = 0; j != n_; ++j)
      if (cell(i, j) & 1) {
        if (!rs_[i].valid || !rs_[j].valid) bad("V-10", "a dependency on or from a free entry");
        else if (i == j) bad("V-10", "an entry depends on itself");
        else if (rs_[i].slot != rs_[j].slot) bad("V-10", "a dependency across warps");
        else if (rs_[j].age > rs_[i].age) bad("V-10", "a dependency on a younger entry");
      }
  // V-15: after a cancel settles, nothing issued and unconfirmed is waiting
  // on a withdrawn wake. While one spreads, a hop a cycle (V-59), the
  // entries it has not reached yet are exactly such entries.
  for (unsigned i = 0; i != n_ && !cancel_live_; ++i)
    if (rs_[i].valid && rs_[i].issued && !rs_[i].confirmed && !rowReady(i))
      bad("V-15", "an issued entry's producer is no longer woken");
}

} // namespace ooe
} // namespace ccv
