//===-- dcu_core.cpp - the DCU's cycle-accurate model ---------------------===//
//
// See dcu_core.h for the cycle and the pipes. The DCU tab's Internals are the
// spec; the comments cite the rows that decide each rule.
//===----------------------------------------------------------------------===//
#include "dcu_core.h"
#include "../skel/wayfold.h"   // the one fold MIU and DCU share (AR 405 (3)); header only

#include <algorithm>
#include <cstdio>

namespace ccv {
namespace dcu {

namespace {
/// A waiting miss's next MSHR decision: the RTL's offer, grant and retry (DI-36).
constexpr uint64_t kRetryLag = 5;
/// DI-37 (MA, DCU tab rev 114; CCV_DCU_FILL_AGE, TI-533): K, the cycles a ready fill write waits
/// before it beats new lookups; it writes within K + 5 of ready.
constexpr uint64_t kFillHold = ccv::prov::kDcuFillAge;
/// DI-43 (MA rev 184): in the RTL's form a fill's victim snapshot waits for
/// its bank's older fills' snapshots and for the fold table's margin of
/// their writes, at most 3 cycles for each other fill the bank holds (its
/// snapshot, its write's two-cycle margin) and 2 for a write already at W.
constexpr uint64_t kSnapWait = 3 * (kCreditDepth - 1) + 2;
std::string fmt(const char *f, unsigned long long a = 0, unsigned long long b = 0,
                unsigned long long c = 0) {
  char buf[256];
  std::snprintf(buf, sizeof buf, f, a, b, c);
  return buf;
}
} // namespace

Core::Core(const Config &c, Hooks &h) : c_(c), h_(h) {
  if (c_.lat_hit == 7) pipe_ = Pipe::A;
  else if (c_.lat_hit == 8) pipe_ = Pipe::C;
  else if (c_.lat_hit == 9) pipe_ = Pipe::B;
  else h_.fail(fmt("dcu: CCV_LAT_L1_HIT %llu has no pipe (7 A, 8 C, 9 B; MA-26)", c_.lat_hit));
  if (pipe_ == Pipe::C && !c_.wp_bits)
    h_.fail("dcu: CCV_LAT_L1_HIT 8 needs way prediction (CCV_DCU_WAYPRED_BITS > 0; MA-26)");
  if (pipe_ != Pipe::C) c_.wp_bits = 0;
  if (!c_.banks || (c_.banks & (c_.banks - 1)) || c_.sets % c_.banks)
    h_.fail(fmt("dcu: %llu banks do not divide %llu sets", c_.banks, c_.sets));
  l1_.assign(size_t(c_.sets) * c_.ways, Way{});
  plru_.assign(size_t(c_.sets) * (c_.ways > 1 ? c_.ways - 1 : 0), 0);
  bfree_.assign(c_.banks, 0);
  bq_.resize(c_.banks);
  book_.resize(c_.banks);
  ent_owed_.assign(c_.banks, 0);
  std_owed_.assign(c_.banks, 0);
  ent_used_.assign(c_.banks, 0);
  ent_due_.clear();
  wb_ack_due_.clear();
  seen_ent_.assign(c_.banks, 0);
  seen_std_.assign(c_.banks, 0);
  std_used_.assign(c_.banks, 0);
  for (unsigned i = 0; i != c_.banks * c_.ids; ++i) free_ids_.insert(i);
  nf_.assign(c_.banks, std::nullopt);
  pk_.assign(c_.banks, std::nullopt);
  for (unsigned b = 0; b != c_.banks; ++b) {
    nf_[b] = pickFree(b, {});
    pk_[b] = nf_[b] ? pickFree(b, {*nf_[b]}) : std::nullopt;
  }
}

// ---- the arrays -------------------------------------------------------------

Core::Way *Core::find(uint64_t pa) {
  Way *s = setOf(pa);
  for (unsigned i = 0; i != c_.ways; ++i)
    if (s[i].valid && s[i].line == pa) return &s[i];
  return nullptr;
}
const Core::Way *Core::find(uint64_t pa) const { return const_cast<Core *>(this)->find(pa); }
int Core::wayOf(uint64_t pa) const {
  const Way *w = find(pa);
  return w ? int(w - &l1_[size_t((pa / kLineBytes) % c_.sets) * c_.ways]) : -1;
}
bool Core::dirtyLine(uint64_t pa) const { const Way *w = find(pa); return w && w->dirty; }
bool Core::ownedLine(uint64_t pa) const { const Way *w = find(pa); return w && w->owned; }

/// The bank: the set index's low bits (line address [9:7] at 8 banks), or
/// under CCV_DCU_BANK_HASH the within-page XOR (MA-20, AR 372 (2)). One
/// function, so the hash changes one place.
unsigned Core::bankOf(uint64_t pa) const {
  const uint64_t m = c_.banks - 1, l = pa / kLineBytes;
  uint64_t b = l & m;
  if (c_.hash) {
    const unsigned lb = unsigned(__builtin_ctz(c_.banks));
    b ^= ((l >> lb) & m) ^ ((l >> (2 * lb)) & m);
  }
  return unsigned(b);
}

/// The way predictor's fold of pa's tag, PA[47:16] in k-bit chunks XORed:
/// MIU's pa_fold and the fold table's entry, one function (TI-518, AR 405 (3)).
unsigned Core::fold(uint64_t pa) const { return ccv::skel::wayFold(pa, c_.wp_bits); }

/// Pipe C's predictor (MA-23 (C), MA-26): among the valid ways whose fold
/// matches pa's, CCV_DCU_WAYPRED_SEL picks the lowest way (index) or the most
/// recently used (recent, true LRU); mru (MA-29) ignores the fold and picks
/// the set's most recently used valid way. Read before the hit touches LRU.
bool Core::predicted(uint64_t pa) {
  const Way *p = predictedWay(pa);
  return p && p->line == pa;
}

const Core::Way *Core::predictedWay(uint64_t pa) {
  const Way *s = setOf(pa), *pick = nullptr;
  if (c_.wp_mru) {   // MA-29's candidate: the set's most recently used valid way, by LRU state alone
    for (unsigned i = 0; i != c_.ways; ++i)
      if (s[i].valid && (!pick || s[i].used > pick->used)) pick = &s[i];
    return pick;
  }
  const unsigned f = fold(pa);
  for (unsigned i = 0; i != c_.ways; ++i)
    if (s[i].valid && fold(s[i].line) == f) {
      if (!pick || (c_.wp_recent && s[i].used > pick->used)) pick = &s[i];
      if (!c_.wp_recent) break;
    }
  return pick;
}

bool Core::foldMatch(uint64_t pa) {
  const Way *s = setOf(pa);
  const unsigned f = fold(pa);
  for (unsigned i = 0; i != c_.ways; ++i)
    if (s[i].valid && fold(s[i].line) == f) return true;
  return false;
}

void Core::merge(Line &l, const Req &r) const {
  for (unsigned k = 0; k != kLineBytes; ++k)
    if (r.mask[k]) l[k] = r.wdata[k];
}

/// A store whose byte mask covers its line needs no read (AR-19).
/// skip-read-partial takes every store for one.
bool Core::fullLine(const Req &r, const std::string &brk) {
  return brk == "skip-read-partial" || r.mask.all();
}

// Tree-PLRU over a power-of-two number of ways (MA-30). Bit 0 sends the
// victim left (lower ways), 1 right.
void Core::plruTouch(size_t set, unsigned way) {
  if (c_.ways < 2) return;
  uint8_t *b = &plru_[set * (c_.ways - 1)];
  unsigned n = 0;
  for (unsigned half = c_.ways / 2, lo = 0; half; half /= 2) {
    const bool right = way >= lo + half;
    b[n] = !right;   // point away from the way just used
    if (right) lo += half;
    n = 2 * n + 1 + right;
  }
}

unsigned Core::plruVictim(size_t set) const {
  if (c_.ways < 2) return 0;
  const uint8_t *b = &plru_[set * (c_.ways - 1)];
  unsigned n = 0, lo = 0;
  for (unsigned half = c_.ways / 2; half; half /= 2) {
    const bool right = b[n];
    if (right) lo += half;
    n = 2 * n + 1 + right;
  }
  return lo;
}

/// pa's line into its set: its own way if resident, else the lowest invalid
/// way, else the tree-PLRU victim (MA-30); if a pending write or store holds
/// that one, the lowest way none holds (slice 2 sets the held case).
/// A dirty victim is read from its bank (EvictR) and written back whole.
Core::Way *Core::install(uint64_t pa, const Line &l, bool owned, bool dirty) {
  Way *w = find(pa);
  if (!w) {
    Way *s = setOf(pa);
    for (unsigned i = 0; i != c_.ways && !w; ++i)
      if (!s[i].valid) w = &s[i];
    if (!w) {
      Way *v = &s[plruVictim(size_t(s - l1_.data()) / c_.ways)];
      if (!held(v->line)) w = v;
      else {
        h_.hit("dcu_plru_held");
        for (unsigned i = 0; i != c_.ways && !w; ++i)
          if (!held(s[i].line)) w = &s[i];
      }
    }
    if (!w) {
      h_.fail(fmt("dcu: every way of line %llx's set is held: no victim", pa));
      w = s;
    }
    if (w->valid && w->dirty)   // only write-through's RMW installs here, and it dirties nothing
      h_.fail(fmt("dcu: write-through's install of line %llx found a dirty victim", pa));
  }
  w->valid = true;
  w->fvalid = true;
  w->flip = -1;   // a fill writes good check bits
  w->ecc_wr = false;
  w->line = pa;
  w->data = l;
  w->owned = owned;
  w->dirty = dirty;
  touch(*w);
  if (dirty) h_.dirty(pa, l);
  return w;
}

// ---- requests in ------------------------------------------------------------

Rsp Core::rspFor(const Req &r) const {
  Rsp s;
  s.slot = r.slot;
  s.req_id = r.req_id;
  s.tid = r.tid;
  return s;
}

/// A store, or an atomic's read, that cannot finish in L1 (not resident,
/// not owned) goes to MLC; so does any read that misses.
bool Core::needsMlc(const Req &r) const {
  const Way *w = find(r.pa);
  if (r.op == Op::Read) return !w;
  if (r.op == Op::Store && c_.brk == "write-through") return true;
  if (r.op == Op::Store && c_.brk == "dcu-st-shared") return !w;   // writes a shared line in place
  return !w || !w->owned;
}

/// A store's write left: its store-data credit goes home (MA-25). Freeing an
/// entry the bank does not hold is a model bug, refused by name.
void Core::stdLeave(unsigned b) {
  if (!std_used_[b]) {
    h_.fail(fmt("dcu: bank %u frees a store-data entry it does not hold", b));
    return;
  }
  ++std_owed_[b];
  --std_used_[b];
}

bool Core::rsvDirty(const Way *w) const {
  if (!w || w->rsv < 0 || !w->dirty || c_.brk == "dcu-wb-store") return false;
  auto it = miss_.find(unsigned(w->rsv));
  return it != miss_.end() && it->second.line != w->line;
}

void Core::arrive(const Req &r, uint64_t t) {
  const unsigned b = bankOf(r.pa);
  ++ent_used_[b];
  if (r.op == Op::Store) ++std_used_[b];
  ++st_.lookups;
  // A line with a miss in flight takes the request into its buffer's merge
  // list (MA-12), so it is answered from the fill, in order.
  for (auto &m : miss_)
    if (m.second.line == r.pa && m.second.k != MK::Evict) {
      missOrWait(r, t + 1);   // its store data stays held until the fill merges it
      return;
    }
  // A store hit to an owned line, variant (b) (MA-17, MA-24): its read and
  // its whole-line write wait in the bank's queue as deferred work, holding
  // its data and mask; MIU's ack leaves on the hit's cycle.
  if (r.op == Op::Store && !needsMlc(r) && !wb_lines_.count(r.pa) && rsvDirty(find(r.pa))) {
    // A store hitting a reserved dirty victim (slice 2, part 2) waits in its
    // bank's queue as miss-wait, its credits held, and looks up again after
    // the fill's write; dcu-wb-store, the control, lets it write.
    h_.hit("dcu_store_rsv_wait");
    h_.hit("dcu_miss_wait");
    bq_[b].push_back(Acc{Acc::MissW, t, t + 1, r.pa, r, 0, {}});
    return;
  }
  if (r.op == Op::Store && !needsMlc(r) && !wb_lines_.count(r.pa)) {
    Acc a{Acc::StoreR, t, t, r.pa, r, 0, {}};
    a.req.born_p = t;
    bq_[b].push_back(a);
    stp_.emplace(r.pa, t);
    hold(r.pa);   // pinned (no eviction) until its write is done
    Rsp ack = rspFor(r);
    ack.hit = true;   // part 3: hit 1, no data: the ack that frees MIU's store
    respond(t + dOff() + launchOff(), ack);
    h_.hit("store_hit");
    h_.hit("dcu_store_deferred");
    ++st_.store_def;
    return;
  }
  // A store or atomic that needs MLC is known a miss from the tags (D2).
  if (r.op != Op::Read && needsMlc(r) && !wb_lines_.count(r.pa)) {
    // The lookup entry leaves at its placement; the store-data entry is
    // held until the store's write leaves, when the fill merges it (DCU
    // spec, MA-25).
    missOrWait(r, t + 1);
    return;
  }
  ontime_[t + dOff()].push_back(r);
}

// ---- the banks --------------------------------------------------------------

bool Core::olderLook(unsigned b, size_t upto, uint64_t line, bool store) const {
  if (c_.brk == "dcu-st-noorder") return false;
  for (size_t j = 0; j != upto && j != bq_[b].size(); ++j) {
    const Acc &x = bq_[b][j];
    if (x.line == line && (x.k == Acc::Look || x.k == Acc::StoreR) && (store || storeLike(x)))
      return true;
  }
  return false;
}

/// A store hit's read may go when its write can be booked `gap` on: at most
/// two a bank between read and write, and no booked write in the access's
/// two cycles (part 3: reads at R and R+2, writes at R+5 and R+7).
bool Core::bookable(unsigned b) const {
  if (book_[b].size() >= 2) return false;
  const uint64_t w = now_ + c_.gap;
  for (const auto &x : book_[b])
    if (x.first + 1 >= w && x.first <= w + 1) return false;
  return true;
}

/// A waiter may go: ready; a lookup or store read only with no older one of
/// its line ahead, no write of its line outstanding (a later lookup waits
/// for a store's or a fill's write; DCU tab, hit pipeline) and its line not
/// being written back; a fill's write only after the victim reads queued
/// ahead of it in its bank (a victim leaves before its way is overwritten).
bool Core::eligible(unsigned b, size_t i) const {
  const Acc &a = bq_[b][i];
  if (a.ready > now_) return false;
  switch (a.k) {
  case Acc::Look:
  case Acc::StoreR: {
    if (olderLook(b, i, a.line, storeLike(a)) || inWb(a.line)) return false;
    if (a.k == Acc::StoreR && !bookable(b)) return false;
    if (c_.brk == "dcu-st-noorder") return true;
    // A store read holds its own line from arrival: only another's write
    // blocks it, which its hold count shows as more than the store reads
    // queued for the line.
    unsigned reads = 0;
    for (const Acc &x : bq_[b]) reads += x.k == Acc::StoreR && x.line == a.line;
    auto it = held_.find(a.line);
    const unsigned h = it == held_.end() ? 0 : it->second;
    return h <= reads;
  }
  case Acc::FillW:
    // (the RTL's form: its way is known a cycle after its snapshot, the
    // write a cycle on, however late the snapshot; DI-43)
    if (c_.victim_at >= 2 && a.fb != ~0u && now_ < a.born + 2) return false;
    if (c_.brk == "dcu-wb-early") return true;
    for (size_t j = 0; j != i; ++j)
      if (bq_[b][j].k == Acc::EvictR && bq_[b][j].fb == a.fb) return false;
    return true;
  case Acc::EvictR:
    return wb_used_ < c_.wb;   // DI-21: waits for a writeback buffer
  case Acc::StoreW:
  case Acc::EccR:
  case Acc::EccW:
    return true;
  case Acc::MissW:
    return false;   // no bank access: retryWaits() takes it
  case Acc::Prb: {
    // Behind every older store to its line, queued or between read and
    // write (part 3's order; dcu-prb-nostore, the control, passes them); a
    // dirty line's read needs a writeback buffer (DI-21).
    if (c_.brk != "dcu-prb-nostore" && (held(a.line) || olderLook(b, i, a.line, false))) return false;
    const Way *w = find(a.line);
    return !(w && w->dirty) || wb_used_ < c_.wb;
  }
  }
  return true;
}

/// A bank access starts now: the single-ported half-rate bank must be free
/// (it takes one access every other cycle; AR 364). Never-happens: two
/// accesses in one bank's busy cycles (the control bank-both-granted).
void Core::claim(unsigned b) {
  if (bfree_[b] > now_)
    h_.fail(fmt("dcu: bank %llu accessed at cycle %llu, busy until %llu", b, now_, bfree_[b]));
  bfree_[b] = now_ + 2;
}

void Core::unhold(uint64_t line) {
  auto it = held_.find(line);
  if (it == held_.end() || !it->second) {
    h_.fail(fmt("dcu: line %llx released a write it did not hold", line));
    return;
  }
  if (!--it->second) held_.erase(it);
}

void Core::serveLook(const Req &r, uint64_t born) {
  const unsigned b = bankOf(r.pa);
  const unsigned late = unsigned(now_ - born - dOff());   // cycles past its D
  // Its entry credit (DI-36): a waiter's goes back at its access, a granted
  // lookup's at its D2 hit, a miss's at its placement (missOrWait).
  const uint64_t hit_ret = late ? now_ : now_ + 1;
  if (late) {
    ++st_.waited;
    h_.peak("dcu_wait_max", late);
  }
  Way *w = stale_way_ ? stale_way_ : find(r.pa);
  stale_way_ = nullptr;
  if (r.op == Op::Store && rsvDirty(w)) {   // back in its queue, its credit out
    h_.hit("dcu_store_rsv_wait");
    h_.hit("dcu_miss_wait");
    bq_[b].push_back(Acc{Acc::MissW, born, now_ + 1, r.pa, r, 0, {}});
    return;
  }
  if (r.op == Op::Store) {
    // A store that waited as a lookup (its line was being written back, or
    // it lost its bank): an owned hit merges now; else it misses, and its
    // store-data entry stays held until the fill merges it.
    if (w && w->owned && c_.brk != "write-through") {
      stdLeave(b);
      entLeave(b, r, hit_ret);
      // CHECK (slice 2, part 2): no store writes a reserved victim whose read
      // has gone to the writeback buffer (dcu-wb-store, the control).
      if (w->rsv >= 0 && miss_.count(unsigned(w->rsv)) && miss_.at(unsigned(w->rsv)).vread &&
          miss_.at(unsigned(w->rsv)).line != w->line)
        h_.fail(fmt("dcu: a store wrote line %llx after its victim read", w->line));
      w->flip = -1;   // the RMW's read corrects, its write is good (MA-28 (c))
      w->ecc_wr = false;
      merge(w->data, r);
      w->dirty = true;
      touch(*w);
      h_.dirty(r.pa, w->data);
      Rsp ack = rspFor(r);
      ack.hit = true;
      respond(now_ + launchOff(), ack);
      h_.hit("store_hit");
      return;
    }
    missOrWait(r, now_ - dOff() + 1, late || r.reread);
    return;
  }
  const bool hit = w && (r.op == Op::Read || w->owned);
  // Pipe C's fold compare (slice 1, MA-30): a lookup whose fold matches no
  // valid way of its set is a miss that reads nothing (dcu_bctl clears the
  // SRAM ce at D1, so the bank's next cycle is free); a fold match on a
  // miss reads the predicted way's word and discards it. A tag hit always
  // has a fold match (the CHECK).
  const bool fm = c_.wp_bits && !r.reread && !c_.wp_mru && foldMatch(r.pa);
  // DI-42 (MA's DCU tab rev 121): a granted lookup whose fold row was read
  // (D0 = H+2, a cycle before P) in a fill's fold write cycle or the next
  // discards its compare; on a hit it takes the mispredict's re-read.
  const bool mg = c_.wp_bits && !r.reread && !late && inMargin(r.pa, born - 1);
  // CHECK (part 4): a way's fold valid bit tracks its tag's valid bit, so
  // after an invalidate no fold match names it (dcu-prb-stale, the control).
  if (c_.wp_bits) {
    const Way *set = setOf(r.pa);
    for (unsigned k = 0; k != c_.ways; ++k)
      if (set[k].fvalid && !set[k].valid)
        h_.fail(fmt("dcu: way %llu of line %llx's set has its fold valid bit set, invalid", k, r.pa));
  }
  if (c_.wp_bits && !r.reread && !c_.wp_mru) {
    if (hit && !fm && !mg) h_.fail(fmt("dcu: a tag hit on line %llx without a fold match", r.pa));
    if (!hit && fm) {
      h_.hit("dcu_wp_fold_miss");
      h_.hit("dcu_wp_reaccess_cycles", 2);
    } else if (!hit) {
      h_.hit("dcu_wp_nomatch_miss");
      if (bfree_[b] == now_ + 2 && c_.brk != "wp-nomatch-reads") bfree_[b] = now_ + 1;
    }
  }
  if (!hit) {
    missOrWait(r, now_ - dOff() + 1, late || r.reread);
    return;
  }
  // CHECK (part 3): no load reads a line an older store to it has not yet
  // written (dcu-st-noorder, the control).
  for (auto it = stp_.lower_bound(r.pa); it != stp_.end() && it->first == r.pa; ++it)
    if (it->second < born)
      h_.fail(fmt("dcu: a load of line %llx read before an older store's write", r.pa));
  if (mg && c_.brk != "dcu-ft-margin") {
    h_.hit("dcu_ft_margin_reread");
    h_.hit("dcu_wp_reaccess_cycles", 2);
    entLeave(b, r, now_ + 1);
    Req x = r;
    x.reread = true;
    x.ent_gone = true;
    bq_[b].push_back(Acc{Acc::Look, born, now_ + 2, r.pa, x, 0, {}});
    bq_[b].back().tway = int(w - l1_.data());
    return;
  }
  // CHECK (DI-42): no lookup answers from a fold row read in the margin
  // (dcu-ft-margin, the control, answers it at its hit slot).
  if (mg) h_.fail(fmt("dcu: a lookup of line %llx answered from a fold row read in a fill's write margin", r.pa));
  if (c_.wp_bits && !r.reread) {
    if (predicted(r.pa)) {
      ++st_.wp_right;
      h_.hit("dcu_wp_right");
    } else if (!noCompare()) {
      // A mispredict (DI-2; MA rev 121, AR 390, OA 442): the true way is
      // re-read in a second, ordinary access, under the half-rate rule and
      // the bank's queue, so it answers no earlier than due + 2, as a
      // bank-conflict loser would. It keeps its queue entry until then.
      // wp-late-at-due (dcu-wp-nocompare, AR 405's name for it), the control,
      // answers at due with the predicted way's line, which the oracle must
      // catch.
      ++st_.wp_wrong;
      h_.hit("dcu_wp_wrong");
      if (!c_.wp_mru) h_.hit("dcu_wp_alias");   // another valid way shares its fold
      h_.hit("dcu_wp_reaccess_cycles", 2);
      entLeave(b, r, now_ + 1);   // its hit at D2 frees its entry (dcu_bctl)
      Req x = r;
      x.reread = true;
      x.ent_gone = true;
      bq_[b].push_back(Acc{Acc::Look, born, now_ + 2, r.pa, x, 0, {}});
      bq_[b].back().tway = int(w - l1_.data());
      return;
    } else {
      ++st_.wp_wrong;
      h_.hit("dcu_wp_wrong");
    }
  }
  const int ue = ueOnHit(*w);
  if (ue == 1) {   // recovered: the line is gone, the read refetches it
    // Part 4: the refetch merges or allocates under the same req_id; the
    // fill's answer is the second. dcu-ue-noanswer drops the refetch;
    // dcu-ue-stale keeps the line and looks it up again (no fill).
    ue_open_[{r.slot, r.req_id}] = now_;
    // The first answer (TI-528, MI-20): the line as read, with a double-bit
    // syndrome in its first word, on the lookup's own slot. MIU withholds
    // the completion and keeps the req_id for the second.
    Rsp f = rspFor(r);
    f.data = true;
    f.line = w->data;
    f.flip = 0;
    f.flip2 = 1;
    f.hit = true;
    f.ue_first = true;
    if ((late || r.reread) && c_.brk != "late-own-slot") f.bank = int(b);
    f.born = born + dOff();
    respond(now_ + launchOff(), f);
    if (c_.brk == "dcu-ue-noanswer") return;
    if (c_.brk == "dcu-ue-stale") {
      w->valid = true;
      bq_[b].push_back(Acc{Acc::Look, born, now_ + 2, r.pa, r, 0, {}});
      return;
    }
    missOrWait(r, now_ - dOff() + 1, late || r.reread);
    return;
  }
  entLeave(b, r, hit_ret);
  if (ue == 2) {
    // Core-fatal (AR 370 (4), AR 389, TI-487 (3)): DCU withholds the read.
    // MIU completes it on the machine-check kill, with no data. ue-answer,
    // the control, answers it anyway, and MIU must refuse the answer.
    h_.withheld(r.req_id);
    if (c_.brk != "ue-answer") return;
  }
  // Read before touch(): once touched, the line asked for is the set's most
  // recent, and a recent-way predictor would always name it (TI, MI-9 (3):
  // the control below never fired).
  const bool wp_miss = c_.wp_bits && !predicted(r.pa);
  // A granted lookup's touch, at D + 3 (a loser's was set when it lost;
  // a re-read's with its first access). plru-at-serve, the control, touches
  // now, at serve, as the model did before slice 1.
  if (c_.brk == "plru-at-serve") {
    touch(*w);
  } else {
    w->used = ++tick_;
    if (!late && !r.reread) touchLater(*w);
  }
  ++st_.hits;
  if (!miss_.empty()) h_.hit("hit_under_miss");
  Rsp s = rspFor(r);
  s.data = true;
  s.line = w->data;
  s.flip = eccOnHit(*w, r);
  s.hit = true;
  if (noCompare() && wp_miss) {
    s.flip = -1;
    // The predicted way's line, not the line asked for (the control): the
    // picked way's data completed without the tag compare. With no fold
    // match there is no predicted way, and the lookup is a miss above.
    const Way *p = predictedWay(r.pa);
    if (p) s.line = p->data;
  }
  if (r.reread) h_.hit("dcu_wp_reread");
  if ((late || r.reread) && c_.brk != "late-own-slot") s.bank = int(b);
  s.born = born + dOff();   // its D: a late answer's age counts from there
  respond(now_ + launchOff(), s);
}

void Core::serve(const Acc &a, uint64_t born) {
  const unsigned b = bankOf(a.line);
  switch (a.k) {
  case Acc::Look:
    if (a.stale) {
      // Its tags read again in a free RF cycle before its data read: the
      // model's lookup re-finds its line. dcu-fill-nostale, the control,
      // reads the way its first tag result named, now the fill's line.
      if (c_.brk == "dcu-fill-nostale") stale_way_ = &l1_[size_t(a.tway)];
      else h_.hit("dcu_tag_stale_relook");
    }
    serveLook(a.req, born);
    break;
  case Acc::StoreR: {
    // The store's read (SECDED-corrected, 2 stages): D3 merges under the
    // mask, and the whole line goes back to the bank `gap` cycles on.
    entLeave(b);
    Way *w = find(a.line);
    if (!w) {
      h_.fail(fmt("dcu: a deferred store's line %llx left L1 before its read", a.line));
      break;
    }
    // CHECKs (part 3): no store writes a line that is not owned
    // (dcu-st-shared), nor before an older load of its line has read.
    if (!w->owned) {
      h_.fail(fmt("dcu: a store wrote line %llx, which is not owned", a.line));
      break;
    }
    for (const Acc &x : bq_[b])
      if (x.k == Acc::Look && x.line == a.line && !storeLike(x) && x.born < a.born)
        h_.fail(fmt("dcu: a store to line %llx read before an older load of it", a.line));
    // CHECK (slice 2, part 2): no store writes a reserved victim whose read
    // has gone to the writeback buffer (dcu-wb-store, the control).
    if (w->rsv >= 0 && miss_.count(unsigned(w->rsv)) && miss_.at(unsigned(w->rsv)).vread &&
        miss_.at(unsigned(w->rsv)).line != w->line)
      h_.fail(fmt("dcu: a store wrote line %llx after its victim read", w->line));
    w->flip = -1;   // the RMW's read corrects, its write is good (MA-28 (c))
    w->ecc_wr = false;
    merge(w->data, a.req);
    if (c_.brk != "dcu-st-dirty") {   // the control's write leaves the bit clear
      w->dirty = true;
      h_.dirty(a.line, w->data);
    }
    touch(*w);
    const uint64_t at = c_.brk == "store-write-early" ? now_ + 1 : now_ + c_.gap;
    book_[b].emplace(at, Acc{Acc::StoreW, now_, at, a.line, a.req, 0, {}});
    h_.peak("dcu_store_booked_max", book_[b].size());
    h_.hit("dcu_store_read");
    break;
  }
  case Acc::StoreW: {
    stdLeave(b);
    unhold(a.line);
    for (auto it = stp_.lower_bound(a.line); it != stp_.end() && it->first == a.line; ++it)
      if (it->second == a.req.born_p) {
        stp_.erase(it);
        break;
      }
    st_.rd_wr_cycles += now_ - a.born;
    h_.hit("dcu_store_write");
    h_.hit("dcu_store_rdwr_sum", now_ - a.born);
    if (now_ - a.born < c_.gap) h_.fail(fmt("dcu: store write %llu cycles after its read, under the gap %llu (TI-483)", now_ - a.born, c_.gap));
    if (now_ - a.born > c_.gap) h_.fail(fmt("dcu: store write %llu cycles after its read, not the gap %llu (part 3)", now_ - a.born, c_.gap));
    break;
  }
  case Acc::FillW:
    if (a.fb == ~0u) {   // write-through's RMW fill (installed at F)
      unhold(a.line);
      h_.hit("dcu_fill_write");
    } else {
      if (now_ - a.born >= c_.age) h_.hit("dcu_fill_write_aged");
      // CHECK (DI-37): a fill writes within K + gap + 1 of ready (a store
      // write booked just before its hold began can still go first), so its
      // buffer's ccv_mlc_dcu_rsp credit returns inside the channel's bound.
      // In the RTL's form a snapshot that waited past the hold (DI-43) moves
      // the bound to its way's write: held at once, so within gap + 1.
      const uint64_t from = c_.victim_at >= 2 ? std::max(a.ready + kFillHold, a.born + 2) : a.ready + kFillHold;
      if (now_ > from + c_.gap + 1)
        h_.fail(fmt("dcu: fill buffer %llu wrote its line %llu cycles after ready (DI-37: K + gap + 1)", a.fb,
                    now_ - a.ready));
      fillWrite(a.fb);
    }
    break;
  case Acc::EccR: {
    // dcu_fix's read of the line in error (slice 1): corrected, flopped,
    // encoded, flopped, then written kFixRdWr cycles on. A rewrite whose
    // line has left (a fill wrote good bits) or that an RMW rewrote is moot.
    Way *w = find(a.line);
    if (!w || !w->ecc_wr) {
      h_.hit("dcu_ecc_write_moot");
      h_.hit("ce_rewrite_cancelled");
      fixDone();
      break;
    }
    h_.hit("dcu_ecc_read");
    bq_[b].push_back(Acc{Acc::EccW, now_, now_ + kFixRdWr, a.line, a.req, 0, {}});
    break;
  }
  case Acc::EccW: {
    // The corrected line goes back (MA-28 (c)): the stored bit is good again.
    if (now_ - a.born < kFixRdWr)
      h_.fail(fmt("dcu: CE rewrite written %llu cycles after its read, under %llu", now_ - a.born, kFixRdWr));
    Way *w = find(a.line);
    if (!w || !w->ecc_wr) {
      h_.hit("dcu_ecc_write_moot");   // the line left, or an RMW rewrote it
      h_.hit("ce_rewrite_cancelled");
    } else {
      w->flip = -1;
      w->ecc_wr = false;
      h_.hit("dcu_ecc_write");
    }
    fixDone();
    break;
  }
  case Acc::MissW:
    h_.fail("dcu: a waiting miss was served as a bank access");
    break;
  case Acc::Prb:
    probeServe(a.fb);
    break;
  case Acc::EvictR: {
    // The dirty victim's read (slice 2, part 2) into a writeback buffer;
    // its fill's write takes the bank's next access, 2 cycles on.
    Miss &m = miss_.at(a.fb);
    m.wb = l1_[size_t(m.way)].data;
    if (l1_[size_t(m.way)].flip >= 0) h_.hit("dcu_evict_read_ce");
    m.vread = true;
    ++wb_used_;
    h_.peak("dcu_wb_max", wb_used_);
    h_.hit("dcu_evict_read");
    for (Acc &x : bq_[b])
      if (x.k == Acc::FillW && x.fb == a.fb) x.ready = std::max(x.ready, now_ + 2);
    h_.hit("dcu_fill_wait_victim");
    break;
  }
  }
}

/// Each bank, each cycle it is free, takes, in slice 1's order (DCU tab,
/// bank arbitration): a mispredict's re-read; the oldest eligible waiter
/// once it has waited CCV_DCU_BANK_AGE (it blocks new lookups and fills until
/// served; AR 364); dcu_fix's CE rewrite read or write; the first lookup due
/// now in slot order (MA-7); else the oldest eligible waiter (a fill writes
/// only in a cycle with no lookup to its bank: AR's MA-7 ask). Lookups due
/// now that do not win wait in the bank's queue and answer later, as a miss
/// would. bank-order-flat, the control, drops the re-read's and the
/// rewrite's precedence.
void Core::schedule() {
  std::vector<Req> due;
  auto it = ontime_.find(now_);
  if (it != ontime_.end()) {
    due = std::move(it->second);
    ontime_.erase(it);
  }
  for (unsigned b = 0; b != c_.banks; ++b) {
    std::vector<Req> in;
    for (const Req &r : due)
      if (bankOf(r.pa) == b) in.push_back(r);
    std::stable_sort(in.begin(), in.end(), [](const Req &x, const Req &y) { return x.slot < y.slot; });
    // Two lookups due in one bank in one cycle: the stub MIU sends them, but
    // MIU's A2 drops all but the lowest slot (MA-27), so under the MIU model
    // this never happens (the CHECK; DI-25 (4), MA rev 156).
    if (in.size() > 1) {
      h_.hit("dcu_cycle_conflict", in.size() - 1);
      if (c_.no_cycle_conflict)
        h_.fail(fmt("dcu: %llu lookups due in bank %llu at cycle %llu; MIU's A2 drops all but one (MA-27)",
                    in.size(), b, now_));
    }
    // The RTL's fill form (CCV_DCU_VICTIM_AT >= 2; dcu_bctl, DI-39): a fill's
    // write is no ordinary waiter: it goes held (below) or only when no
    // lookup waiter is eligible, and never ages.
    const bool rf = c_.victim_at >= 2;
    size_t old = bq_[b].size(), oldf = bq_[b].size();
    for (size_t i = 0; i != bq_[b].size(); ++i)
      if (eligible(b, i)) {
        if (rf && bq_[b][i].k == Acc::FillW) {
          if (oldf == bq_[b].size()) oldf = i;
          continue;
        }
        old = i;
        break;
      }
    const bool aged = old != bq_[b].size() && now_ - bq_[b][old].born >= c_.age &&
                      c_.brk != "bank-age-ignored";
    // The re-read and the CE rewrite, which go ahead of new lookups.
    const bool flat = c_.brk == "bank-order-flat";
    size_t rr = bq_[b].size(), fx = bq_[b].size();
    for (size_t i = 0; i != bq_[b].size() && !flat; ++i) {
      const Acc &x = bq_[b][i];
      if (rr == bq_[b].size() && x.k == Acc::Look && x.req.reread && eligible(b, i)) rr = i;
      if (fx == bq_[b].size() && (x.k == Acc::EccR || x.k == Acc::EccW) && eligible(b, i)) fx = i;
    }
    size_t win = in.size();
    for (size_t i = 0; i != in.size() && win == in.size(); ++i) {
      const uint64_t l = in[i].pa;
      bool earlier = false;
      for (size_t j = 0; j != i; ++j) earlier |= in[j].pa == l;
      const bool noord = c_.brk == "dcu-st-noorder";
      if (!earlier && (noord || !held(l)) && !olderLook(b, bq_[b].size(), l, in[i].op == Op::Store) && !inWb(l))
        win = i;
    }
    bool fill_waits = false;
    for (size_t i = 0; i != bq_[b].size(); ++i)
      fill_waits |= bq_[b][i].k == Acc::FillW && eligible(b, i);
    // A held fill (DI-37, MA's ruling, DCU tab rev 114): a fill write ready
    // K cycles takes the bank ahead of new lookups and queued work, but not
    // a booked store write (served above) nor an older store to its set
    // (the victim's (set, way)); so it writes within K + 5 of ready and the
    // fill buffer's ccv_mlc_dcu_rsp credit comes back inside its bound.
    // dcu-fill-unheld, the control, keeps the old order, and the CHECK in
    // serve() must catch the late write.
    size_t hf = bq_[b].size();
    for (size_t i = 0; i != bq_[b].size() && hf == bq_[b].size() && !flat; ++i) {
      const Acc &x = bq_[b][i];
      if (x.k != Acc::FillW || now_ < x.ready + kFillHold || c_.brk == "dcu-fill-unheld") continue;
      // DI-37's unbounded terms (MA, DCU tab rev 115) rely on the channel's
      // 32-cycle check, each with its longest wait: a fill behind its
      // victim's read (no writeback buffer), behind an older store to its
      // victim (the hold suspended, its age kept), or in a bank a late
      // answer holds (in the response loop).
      if (!eligible(b, i)) {
        h_.peak("dcu_fill_wait_victim_max", now_ - x.ready);
        continue;
      }
      // Its (set, way): the way its buffer reserved, whose line an older
      // store may still be reading or writing.
      const Way *set = setOf(x.line);
      uint64_t vl = ~uint64_t(0);
      for (unsigned k = 0; k != c_.ways; ++k)
        if (set[k].valid && set[k].rsv == int(x.fb)) vl = set[k].line;
      bool st = false;
      for (size_t j = 0; j != i; ++j)
        st |= (bq_[b][j].k == Acc::StoreR || bq_[b][j].k == Acc::StoreW) &&
              (bq_[b][j].line == vl || bq_[b][j].line == x.line);
      if (!st) hf = i;
      else h_.peak("dcu_fill_wait_store_max", now_ - x.ready);
    }
    const bool both = c_.brk == "bank-both-granted";
    // A store's booked write takes the bank now; an access now would still
    // be busy at a write booked next cycle.
    auto bk = book_[b].begin();   // due now (one overdue is refused by the gap CHECK)
    if (bk != book_[b].end() && bk->first <= now_ && bfree_[b] <= now_) {
      const Acc a = bk->second;
      book_[b].erase(bk);
      claim(b);
      serve(a, a.born);
    }
    const bool next_booked = book_[b].count(now_ + 1) != 0;
    if ((bfree_[b] <= now_ && !next_booked) || (both && win != in.size())) {
      if (hf != bq_[b].size() && !(rf && rr != bq_[b].size())) {
        if (!in.empty()) h_.hit("dcu_fill_held_block");
        h_.hit("dcu_fill_held");
        const Acc a = bq_[b][hf];
        bq_[b].erase(bq_[b].begin() + long(hf));
        claim(b);
        serve(a, a.born);
      } else if (rr != bq_[b].size() || (!aged && fx != bq_[b].size())) {
        const size_t i = rr != bq_[b].size() ? rr : fx;
        if (!in.empty()) h_.hit(rr != bq_[b].size() ? "dcu_reread_block" : "dcu_fix_block");
        const Acc a = bq_[b][i];
        bq_[b].erase(bq_[b].begin() + long(i));
        claim(b);
        serve(a, a.born);
      } else if (aged) {
        if (!in.empty() || fill_waits) {
          ++st_.age_blocks;
          h_.hit("dcu_age_block");
        }
        const Acc a = bq_[b][old];
        bq_[b].erase(bq_[b].begin() + long(old));
        claim(b);
        serve(a, a.born);
      } else if (win != in.size()) {
        const Req r = in[win];
        in.erase(in.begin() + long(win));
        claim(b);
        if (fill_waits) {
          ++st_.fill_wait;
          h_.hit("dcu_fill_wait");
        }
        serveLook(r, now_ - dOff());
        // bank-both-granted: the control grants every lookup due now.
        while (both && !in.empty()) {
          const Req x = in.front();
          in.erase(in.begin());
          claim(b);
          serveLook(x, now_ - dOff());
        }
      } else if (old != bq_[b].size() || oldf != bq_[b].size()) {
        const size_t i = old != bq_[b].size() ? old : oldf;
        const Acc a = bq_[b][i];
        bq_[b].erase(bq_[b].begin() + long(i));
        claim(b);
        serve(a, a.born);
      }
    } else if (fill_waits) {
      ++st_.fill_wait;
      h_.hit("dcu_fill_wait");
    }
    for (size_t li = 0; li != in.size(); ++li) {
      const Req &r = in[li];
      const bool wb = inWb(r.pa);
      const bool ord = held(r.pa) || olderLook(b, bq_[b].size(), r.pa, r.op == Op::Store);
      bool earlier = false;   // an earlier lookup of its line this cycle
      for (size_t j = 0; j != li; ++j) earlier |= in[j].pa == r.pa;
      if (wb) h_.hit("dcu_miss_wait_wb");   // its line's writeback awaits MLC's ack
      if (ord) h_.hit("dcu_order_first");
      ++st_.losers;
      h_.hit("dcu_bank_loser");
      h_.hit(r.slot == 0 ? "dcu_bank_loser_s0" : r.slot == 1 ? "dcu_bank_loser_s1"
             : r.slot == 2 ? "dcu_bank_loser_s2" : "dcu_bank_loser_s3");
      // A loser's tag result is known at its D2 (dcu_bctl: "a lead that lost
      // the bank waits for its tag result"); a read that misses goes to
      // dcu_mshr then, on its slot's port, and never waits for the bank:
      // only hits join the queue (DI-48). One that waits for order (a held
      // line, an older lookup of its line, its writeback, an earlier lookup
      // of its line now) keeps the queue's order. dcu-loser-miss-late, the
      // control, decides it at its access instead, a late miss that retries
      // on port 0 (MA-33), so it leaves the winner's cycle late.
      if (r.op == Op::Read && !find(r.pa) && !wb && !ord && !earlier &&
          c_.brk != "dcu-loser-miss-late") {
        h_.hit("dcu_loser_miss");
        missOrWait(r, now_ - dOff() + 1);
        continue;
      }
      bq_[b].push_back(Acc{Acc::Look, now_ - dOff(), now_, r.pa, r, 0, {}});
      if (const Way *tw = find(r.pa))
        if (r.op == Op::Read || tw->owned) bq_[b].back().tway = int(tw - l1_.data());
      // Its tag result is known at its D2: a hit touches at D + 3 (dcu_bctl
      // updates PLRU for every hit, a loser included; MA's DI-26 answer).
      if (c_.brk != "plru-at-serve" && r.op != Op::Store) {
        const Way *w = find(r.pa);
        if (w && (r.op == Op::Read || w->owned)) touchLater(*w);
      }
    }
  }
}

// ---- the miss path ------------------------------------------------------------

void Core::mlcReq(MlcOp op, uint64_t pa, const Line *d, unsigned id, uint64_t tid, uint64_t d2) {
  MlcReq m;
  m.id = id;
  m.pa = pa;
  m.op = op;
  m.tid = tid;
  if (d) {
    m.data = true;
    m.line = *d;
  }
  to_mlc_.push_back({d2, m});
}

/// Slice 2, part 1: a miss merges or allocates at D2; else it takes an
/// entry in its bank's queue, marked miss-wait, keeping its entry credit
/// (MA-12's hold: MIU's credits stop the channel, nothing is refused). A
/// miss also waits while its bank already holds a waiting one, so a line's
/// requests stay in arrival order (one line is one bank); dcu-miss-reorder,
/// the control, lets a new miss pass a waiting one of its line.
void Core::missOrWait(const Req &r, uint64_t d2, bool late) {
  const unsigned b = bankOf(r.pa);
  // A late lookup's miss (MA-33): a waiter, or a re-read, decides its miss
  // at its access, cycles past its D; it waits and retries on port 0. Per
  // bank (MA-34) it can no longer meet another miss of its bank at one D2,
  // so this is kept by choice, one path for every miss that waits (DCU tab
  // rev 148, DI-61); dcu-late-miss-port, its control, is retired.
  // A second miss in one bank in one cycle (MA-34: one dcu_mshr a bank,
  // one new miss a cycle): a bank-conflict loser deciding its miss at D2
  // beside its bank's winner waits the same way and retries on port 0.
  // dcu-bank-two-miss, the control, lets it in (the CHECK in startMiss).
  if (!late && nm_.count({b, d2}) && c_.brk != "dcu-bank-two-miss") {
    h_.hit("dcu_bank_miss_busy");
    h_.hit("dcu_miss_wait");
    bq_[b].push_back(Acc{Acc::MissW, now_, d2 + kRetryLag, r.pa, r, 0, {}});
    return;
  }
  if (late) {
    h_.hit("dcu_late_miss_retry");
    h_.hit("dcu_miss_wait");
    bq_[b].push_back(Acc{Acc::MissW, now_, d2 + kRetryLag, r.pa, r, 0, {}});
    return;
  }
  bool waits = false;
  for (const Acc &x : bq_[b]) {
    if (x.k != Acc::MissW) continue;
    if (c_.brk == "dcu-miss-reorder" && x.line == r.pa) continue;
    waits = true;
    break;
  }
  const char *why = "dcu_miss_wait_order";
  const unsigned port = r.slot + 1;
  if (waits) nf_pq_ |= 1u << b;   // it presents its request and waits
  else {
    for (const Acc &x : bq_[b])
      if (x.k == Acc::MissW && x.line == r.pa)
        h_.fail(fmt("dcu: a miss to line %llx passed a waiting one", r.pa));
    if (startMiss(r, d2, port, &why)) {
      entLeave(b, r, d2 + 1);   // placed: it leaves at D3 (dcu_bctl)
      return;
    }
  }
  // CHECK: a line's misses never pass a waiting one (slice 2, part 1).
  // Its entry credit stays out until it leaves the queue.
  h_.hit(why);
  h_.hit("dcu_miss_wait");
  // The RTL's retry (DI-35, DI-36): the wait is known at D3 (d2 + 1), the
  // head is offered a cycle on, granted the next, and the retry's D2 (its
  // MSHR decision) comes two cycles after the grant: d2 + 5 at the earliest.
  bq_[b].push_back(Acc{Acc::MissW, now_, d2 + kRetryLag, r.pa, r, 0, {}});
}

/// Waiting misses retry on the MSHR's one retry port (spec DCU tab rev
/// 110): each bank offers its oldest waiter, and the oldest of those by
/// age takes the port, ahead of every new miss. Age is the RTL's (DI-35):
/// a 10-bit stamp of when the waiter became its bank's head, compared
/// modulo 2^10, ties to the lowest bank; a retry that waits again is
/// stamped anew (MA's rule), so no offered stamp ages past half the range. A line its fill has since
/// written is a hit: it looks up again in its own bank (a late answer),
/// with no retry. Leaving the queue returns its entry credit.
namespace {
constexpr uint64_t kStampBits = 10;   // the RTL's retry stamp (DI-35)
/// a strictly older than b, by the RTL's stamps modulo 2^kStampBits.
bool older(uint64_t a, uint64_t b) {
  const uint64_t m = (uint64_t(1) << kStampBits) - 1, d = (b - a) & m;
  return d != 0 && d <= (m >> 1);
}
}  // namespace

void Core::retryWaits() {
  int pb = -1;
  size_t pi = 0;
  for (unsigned b = 0; b != c_.banks; ++b) {
    for (size_t i = 0; i != bq_[b].size(); ++i) {
      Acc &a = bq_[b][i];
      if (a.k != Acc::MissW) continue;
      if (!a.headed) {   // the bank's head from now: stamped (DI-35)
        a.headed = true;
        a.stamp = now_;
      }
      h_.hit("dcu_miss_wait_cycles");
      if (a.ready > now_) break;
      const Req &r = a.req;
      const Way *w = find(r.pa);
      if (r.op == Op::Store && rsvDirty(w)) break;   // until its fill's write
      if (w && (r.op == Op::Read || w->owned)) {
        a.k = Acc::Look;   // keeps its place and its credit: served as a waiter
        h_.hit("dcu_miss_wait_relook");
        break;
      }
      if (pb < 0 || older(a.stamp, bq_[unsigned(pb)][pi].stamp)) {
        pb = int(b);
        pi = i;
      }
      break;   // a bank offers its oldest
    }
  }
  if (pb < 0) return;
  const unsigned b = unsigned(pb);
  const Req r = bq_[b][pi].req;
  const char *why = nullptr;
  if (startMiss(r, now_, 0, &why)) {   // its retry is its D2, on port 0
    bq_[b].erase(bq_[b].begin() + long(pi));
    entLeave(b, r, now_ + 1);   // placed at its D3
    h_.hit("dcu_miss_wait_done");
  } else {
    bq_[b][pi].stamp = now_;   // waits again: stamped anew (DI-35)
    // Its outcome at R+3, re-offered at R+4, its next D2 at R+7: now + 5.
    bq_[b][pi].ready = now_ + kRetryLag;
    h_.hit("dcu_miss_wait_again");
  }
}

/// A writeback's acknowledgement takes effect: its line leaves the
/// writeback buffer and its entry frees.
void Core::wbAcked(unsigned id) {
  auto it = miss_.find(id);
  if (it == miss_.end()) return;
  wb_lines_.erase(it->second.line);
  it->second.acked = true;
  maybeFree(id);
}

void Core::freeId(unsigned id) {
  free_ids_.insert(id);
  freed_.insert(id);
}

/// Bank b's lowest free id not in `out` (an id freed this cycle counts as
/// free; one taken last cycle does not yet).
std::optional<unsigned> Core::pickFree(unsigned b, const std::set<unsigned> &out) const {
  for (unsigned i = b * c_.ids; i != (b + 1) * c_.ids; ++i)
    if (((free_ids_.count(i) && !ua_.count(i)) || freed_.count(i)) && !out.count(i)) return i;
  return std::nullopt;
}

/// The next cycle's offers and picks, a bank at a time, under the RTL's
/// enable: a request, a free in the bank, or a pick for an empty offer.
void Core::nfNext() {
  std::set<unsigned> ua;
  for (unsigned b = 0; b != c_.banks; ++b) {
    const bool req = (nf_pq_ >> b) & 1;
    bool fr = false;
    for (unsigned i : freed_) fr = fr || idBank(i) == b;
    if (!(req || fr || (pk_[b] && !nf_[b]))) continue;
    if (req && nf_[b]) ua.insert(*nf_[b]);
    if (req || !nf_[b]) {
      nf_[b] = pk_[b];
      if (req && !nf_[b]) h_.hit("dcu_mshr_id_skipped");
    }
  }
  // The picks see the offers taken last cycle as in use (ua_), then this
  // cycle's are added for the cycle after.
  for (unsigned b = 0; b != c_.banks; ++b) {
    std::set<unsigned> out;
    if (nf_[b]) out.insert(*nf_[b]);
    for (unsigned i : ua) out.insert(i);
    pk_[b] = pickFree(b, out);
  }
  ua_ = std::move(ua);
  nf_pq_ = 0;
  while (!nm_.empty() && nm_.begin()->second + 64 < now_) nm_.erase(nm_.begin());
  freed_.clear();
}

/// A missing request: into its line's buffer's merge list if one is in
/// flight and has room, else a buffer of its own if one is free (with
/// dcu-one-miss, only when none is). False: it stalls, and so does the
/// channel (accepting()).
bool Core::startMiss(const Req &r, uint64_t d2, unsigned, const char **why) {   // its port: its bank (MA-34)
  const char *dummy;
  if (!why) why = &dummy;
  const unsigned bk = bankOf(r.pa);
  // CHECK (MA-34): a bank takes at most one new miss a cycle, a retry or a
  // slot's (A2 sends no two lookups to one bank, MA-27; a bank holding a
  // waiter queues its own new miss behind it).
  if (!nm_.insert({bk, d2}).second) h_.fail(fmt("dcu: bank %u started two misses in one cycle (D2 %llu)", bk, d2));
  nf_pq_ |= 1u << bk;   // every request takes its bank's offer
  for (auto &m : miss_)
    if (m.second.line == r.pa && m.second.k != MK::Evict && c_.brk != "dcu-mshr-nomerge") {
      if (m.second.filled) {   // filled, not yet written (slice 2, part 1)
        *why = "dcu_miss_wait_filled";
        return false;
      }
      if (m.second.reqs.size() >= c_.merge) {
        *why = "dcu_miss_wait_list";
        return false;
      }
      m.second.reqs.push_back(r);
      ++st_.merged;
      h_.hit("dcu_merged");
      return true;
    }
  // Its writeback first (part 2): the line comes back after MLC's ack.
  if (wb_lines_.count(r.pa) && c_.brk != "dcu-wb-refetch") {
    *why = "dcu_miss_wait_wb";
    return false;
  }
  if (!nf_[bk]) {   // no id of its bank offered
    *why = "dcu_miss_wait_entry";
    return false;
  }
  if (c_.brk == "dcu-one-miss")
    for (auto &m : miss_)
      if (m.second.k != MK::Evict) {
        *why = "dcu_miss_wait_entry";
        return false;
      }
  // CHECKs (slice 2): no two valid entries hold one line, and a line is
  // never fetched while its writeback awaits MLC's acknowledgement.
  for (auto &m : miss_)
    if (m.second.line == r.pa)
      h_.fail(fmt("dcu: a second miss buffer entry for line %llx", r.pa));
  if (wb_lines_.count(r.pa))   // dcu-wb-refetch, the control (DI-48)
    h_.fail(fmt("dcu: line %llx fetched while its writeback awaits MLC's acknowledgement", r.pa));
  // dcu-miss-other-bank, the control (DI-58): the miss takes another
  // bank's offered id, which the CHECK below refuses.
  unsigned ob = bk;
  if (c_.brk == "dcu-miss-other-bank")
    for (unsigned k = 1; k != c_.banks; ++k)
      if (nf_[(bk + k) % c_.banks]) {
        ob = (bk + k) % c_.banks;
        break;
      }
  const unsigned id = *nf_[ob];
  if (!free_ids_.erase(id)) h_.fail(fmt("dcu: miss buffer id %u offered while in use", id));
  nf_[ob].reset();   // taken: its bank's next pick is offered next cycle
  // CHECK (MA-34): an id's bank is its line's bank.
  if (idBank(id) != bk) h_.fail(fmt("dcu: miss buffer id %u for line %llx of bank %u", id, r.pa, bk));
  ++st_.misses;
  h_.peak("dcu_mshr_max", miss_.size() + 1);
  if (r.op == Op::Read) {
    miss_[id] = newMiss(MK::Fill, r.pa, {r}, {});
    mlcReq(MlcOp::Read, r.pa, nullptr, id, r.tid, d2);
    h_.hit("l1_miss");
  } else if (r.op == Op::AtomRead) {
    miss_[id] = newMiss(MK::AcqData, r.pa, {r}, {});
    mlcReq(MlcOp::AcquireData, r.pa, nullptr, id, r.tid, d2);
    h_.hit("l1_miss");
    h_.hit("atomic_acquire");
  } else if (c_.brk == "write-through") {
    // The policy before rev 8: every store a read-merge-write in MLC.
    if (fullLine(r, c_.brk)) {
      miss_[id] = newMiss(MK::WriteAck, r.pa, {r}, r.wdata);
      Way *w = find(r.pa);
      if (w) w->data = r.wdata;
      mlcReq(MlcOp::Write, r.pa, &r.wdata, id, r.tid, d2);
      stdLeave(bankOf(r.pa));   // the whole line's write leaves for MLC
      h_.hit("full_line");
    } else {
      miss_[id] = newMiss(MK::RmwRead, r.pa, {r}, {});
      mlcReq(MlcOp::Read, r.pa, nullptr, id, r.tid, d2);
    }
  } else if (fullLine(r, c_.brk)) {
    h_.hit(find(r.pa) ? "dcu_upgrade_perm" : "dcu_store_miss");
    miss_[id] = newMiss(MK::AcqPerm, r.pa, {r}, {});
    mlcReq(MlcOp::AcquirePerm, r.pa, nullptr, id, r.tid, d2);
    h_.hit("full_line");
  } else {
    h_.hit(find(r.pa) ? "dcu_upgrade_data" : "dcu_store_miss");
    miss_[id] = newMiss(MK::AcqData, r.pa, {r}, {});
    mlcReq(MlcOp::AcquireData, r.pa, nullptr, id, r.tid, d2);
    h_.hit("l1_miss");
  }
  return true;
}

/// A fill, a grant or a writeback's acknowledgement (slice 2, parts 1-2).
/// A fill lands in its fill buffer at F and answers its merged requests from
/// it (valid at F + CCV_LAT_FILL_NOTICE at the earliest); its victim is
/// chosen at F+1, and its bank write (W) takes a free access from F+3 on,
/// behind a dirty victim's read. Its entry stays valid until W and its last
/// answer; then a dirty victim's writeback takes the entry over.
void Core::onFill(const Fill &f) {
  auto it = miss_.find(f.id);
  if (it == miss_.end() || (it->second.filled && it->second.k != MK::Evict)) {
    h_.fail(fmt("dcu: MLC answered req_id %llu, which is not outstanding", f.id));
    ++fill_release_;
    return;
  }
  Miss &m = it->second;
  if (idBank(f.id) != bankOf(m.line))   // CHECK (MA-34): an id's bank is its line's
    h_.fail(fmt("dcu: MLC answered req_id %llu for line %llx of bank %u", f.id, m.line, bankOf(m.line)));
  const uint64_t at = floorAt() - (c_.brk == "dcu-fill-early" ? 1 : 0);
  switch (m.k) {
  case MK::Evict:
    // MLC's acknowledgement: no fill buffer, the credit back at once, and
    // the entry free (CHECK: it names a writeback whose request has gone).
    ++fill_release_;
    if (!m.written || std::find(wbsend_.begin(), wbsend_.end(), f.id) != wbsend_.end())
      h_.fail(fmt("dcu: MLC acknowledged req_id %llu, a writeback not yet sent", f.id));
    if (c_.wb_ack_delay) wb_ack_due_.emplace(now_ + c_.wb_ack_delay, f.id);
    else wbAcked(f.id);
    return;
  case MK::WriteAck: {
    Miss w = std::move(m);
    miss_.erase(it);
    freeId(f.id);
    ++fill_release_;
    respond(at, rspFor(w.reqs.front()));
    for (size_t i = 1; i < w.reqs.size(); ++i) {   // merged behind it: look up again
      const unsigned b = bankOf(w.line);
      // Its entry credit went back when it merged; a store's data entry is
      // still held from its arrival.
      Req x = w.reqs[i];
      x.ent_gone = true;
      bq_[b].push_back(Acc{Acc::Look, now_, now_, w.line, x, 0, {}});
    }
    return;
  }
  case MK::RmwRead: {
    Miss w = std::move(m);
    miss_.erase(it);
    freeId(f.id);
    ++fill_release_;
    Line l = f.line;
    merge(l, w.reqs.front());
    stdLeave(bankOf(w.line));   // the partial store's write leaves with the merge
    install(w.line, l, false, false);
    hold(w.line);
    bq_[bankOf(w.line)].push_back(Acc{Acc::FillW, now_, now_, w.line, Req{}, ~0u, {}});
    // Write-through only: no port; its own bank's lowest free id (the
    // read's, just freed, at the latest).
    const unsigned wb_b = bankOf(w.line);
    unsigned id = ~0u;
    for (unsigned i = wb_b * c_.ids; i != (wb_b + 1) * c_.ids && id == ~0u; ++i)
      if (free_ids_.count(i)) id = i;
    if (id == ~0u) h_.fail(fmt("dcu: no free miss buffer id in bank %u for a write-through", wb_b));
    free_ids_.erase(id);
    for (auto &o : nf_)
      if (o && *o == id) o.reset();
    for (auto &o : pk_)
      if (o && *o == id) o.reset();
    miss_[id] = newMiss(MK::WriteAck, w.line, std::move(w.reqs), l);
    mlcReq(MlcOp::Write, w.line, &l, id, miss_[id].reqs.front().tid, now_);
    return;
  }
  default:
    break;
  }
  ++st_.fills;
  const bool want_own = m.k != MK::Fill;
  if (want_own && !f.own) {
    h_.fail(fmt("dcu: MLC answered the acquire of line %llx (req_id %llu) without ownership",
                m.line, f.id));
    return;
  }
  m.filled = m.fb = true;
  m.f_at = now_;
  // AcquirePerm's grant carries no data: the buffer starts from zeros and
  // its one full-line store covers every byte (part 3).
  Line l = m.k == MK::AcqPerm ? m.reqs.front().wdata : f.line;
  bool dirty = false;
  const unsigned b = bankOf(m.line);
  // Part 3: the fill buffer takes the stores ahead of the list's first load,
  // in order, one a cycle (the j-th merges at F+j+2, freeing its store-data
  // entry then); a store behind a load, and all after it, look up again
  // after the write (W). Anything needing ownership a shared fill did not
  // bring does too. dcu-st-mergeall, the control, merges every store.
  const bool all = c_.brk == "dcu-st-mergeall";
  size_t cut = 0;
  bool seen_load = false;
  for (; cut != m.reqs.size(); ++cut) {
    const Req &r = m.reqs[cut];
    if (r.op != Op::Read && !want_own) break;
    if (r.op == Op::Store) {
      if (seen_load && !all) {
        h_.hit("dcu_st_merge_behind");
        break;
      }
      if (m.k != MK::AcqPerm || cut) merge(l, r);
      ++m.kst;
      dirty = true;
      std_at_.emplace(now_ + m.kst + 1, b);
      // CHECK (part 3): a fill merges no store behind a load (a load never
      // sees a store MIU sent after it; dcu-st-mergeall, the control).
      if (seen_load) h_.fail(fmt("dcu: the fill of line %llx merged a store behind a load", m.line));
      h_.hit(seen_load ? "dcu_st_merge_behind" : "dcu_st_merge_ahead");
    } else {
      seen_load = true;
    }
  }
  // Answers: valid at F+4 with no store merged; else the encode follows the
  // last merge (F+k+3), so valid at F+k+5 (launch F+k+4), un-noticed.
  const uint64_t at_k = floorAt() + (m.kst ? m.kst + 1 : 0) - (c_.brk == "dcu-fill-early" ? 1 : 0);
  size_t i = 0;
  for (; i != cut; ++i) {
    const Req &r = m.reqs[i];
    Rsp s = rspFor(r);
    s.fid = int(f.id);
    s.born = now_;
    ++m.owed;
    if (r.op == Op::Store) {   // merged: a late answer, hit 0, no data
      respond(at_k, s);
      continue;
    }
    s.data = true;
    s.line = l;
    s.mlc_miss = f.miss;
    if (r.op == Op::Read && !m.kst) refill(s, *ports_);
    else respond(at_k, s);
  }
  // What needed ownership a shared fill did not bring looks up again, in
  // order, after the fill's write (W).
  for (; i != m.reqs.size(); ++i) m.relook.push_back(m.reqs[i]);
  m.fl = l;
  m.fown = want_own;
  m.fdirty = dirty;
  hold(m.line);   // lookups of its line queued behind the write
  vpend_.push_back(f.id);
  h_.peak("dcu_fill_max", size_t(std::count_if(miss_.begin(), miss_.end(),
                                                [](const auto &x) { return x.second.fb; })));
}

/// F+1 (slice 2, part 1): the fill's way. Its line's own way if resident (an
/// upgrade), else the lowest invalid way, else the tree-PLRU victim,
/// skipping a way another fill reserves or a pending write holds. Reserved
/// until W and marked most recently used. A dirty victim is read first
/// (part 2), no earlier than F+3; the fill's write follows it.
bool Core::pickVictim(unsigned id) {
  Miss &m = miss_.at(id);
  Way *s = setOf(m.line);
  // In the RTL's form a way written this cycle (W) stays reserved: its
  // write is not yet in the fold table the snapshot reads (DI-43, MA rev
  // 184). dcu-fill-rsv-grant, the control, releases it, and the CHECK below
  // must catch the pick.
  const bool rf = c_.victim_at >= 2;
  auto wn = [&](const Way &x) {
    return rf && c_.brk != "dcu-fill-rsv-grant" &&
           std::count(wnow_.begin(), wnow_.end(), size_t(&x - l1_.data())) != 0;
  };
  auto free_way = [&](const Way &x) { return x.rsv < 0 && !wn(x) && !(x.valid && held(x.line)); };
  Way *w = find(m.line);
  if (w && w->rsv >= 0) w = nullptr;
  if (!w)
    for (unsigned k = 0; k != c_.ways && !w; ++k)
      if (!s[k].valid && s[k].rsv < 0) w = &s[k];
  bool plru = false;
  if (!w) {
    Way *v = &s[plruVictim(size_t(s - l1_.data()) / c_.ways)];
    if (free_way(*v)) {
      w = v;
      plru = true;
    } else {
      h_.hit("dcu_victim_skipped");
      h_.hit("dcu_plru_held");
      for (unsigned k = 0; k != c_.ways && !w; ++k)
        if (free_way(s[k])) w = &s[k];
    }
  }
  if (!w) {
    h_.hit("dcu_fill_victim_wait");
    m.vnofree = true;
    return false;
  }
  // CHECK (DI-43): no fill takes a way another fill writes now, whose line
  // the snapshot cannot see (two fills on one way, the first one's lost).
  if (rf && std::count(wnow_.begin(), wnow_.end(), size_t(w - l1_.data())))
    h_.fail(fmt("dcu: a fill of line %llx took way %llu, which a fill writes this cycle (DI-43)", m.line,
                unsigned(w - l1_.data()) % c_.ways));
  if (!w->valid) h_.hit("dcu_victim_invalid");
  else if (plru) h_.hit("dcu_victim_plru");
  w->rsv = int(id);
  m.way = int(w - l1_.data());
  // Made most recently used: at once, or, in the RTL's form, from dcu_bctl's
  // flops a cycle on (seen two cycles after the pick).
  if (c_.victim_at >= 2) {
    w->used = ++tick_;
    touch_at_.emplace(now_ + 2, size_t(w - l1_.data()));   // after a hit's due the same cycle
  } else {
    touch(*w);
  }
  const unsigned b = bankOf(m.line);
  const uint64_t ready = m.f_at + 2 + c_.victim_at + (m.kst ? m.kst + 2 : 0);   // encode F+1, or F+k+3 (part 3)
  if (w->valid && w->line != m.line) {
    h_.hit("dcu_evict");
    ++st_.evicts;
    if (w->dirty) {
      h_.hit("dcu_evict_dirty");
      m.vdirty = true;
      m.vline = w->line;
      bq_[b].push_back(Acc{Acc::EvictR, now_, ready, w->line, Req{}, id, {}});
    } else {
      h_.hit("dcu_evict_clean");
    }
  }
  bq_[b].push_back(Acc{Acc::FillW, now_, ready, m.line, Req{}, id, {}});
  // dcu-wb-early, the control: the fill's write ahead of its victim's read.
  if (c_.brk == "dcu-wb-early" && m.vdirty) std::swap(bq_[b][bq_[b].size() - 1], bq_[b][bq_[b].size() - 2]);
  return true;
}

/// The RTL's form (CCV_DCU_VICTIM_AT >= 2; DI-43, MA rev 184): after the
/// bank's access, so that this cycle's write (W) is known. One snapshot a
/// bank a cycle, to its oldest fill still without a way whose set is
/// outside the fold table's margin (a fill's fold write this cycle or
/// last); dcu-fill-nomargin, the control, ignores the margin.
void Core::pickVictims() {
  std::vector<char> took(c_.banks, 0);
  for (size_t k = 0; k != vpend_.size();) {
    Miss &m = miss_.at(vpend_[k]);
    const unsigned b = bankOf(m.line);
    if (m.f_at + c_.victim_at > now_ || took[b]) {
      ++k;
      continue;
    }
    if (c_.wp_bits && c_.brk != "dcu-fill-nomargin" && inMargin(m.line, now_)) {
      h_.hit("dcu_fill_snap_margin");
      ++k;
      continue;
    }
    took[b] = 1;
    const uint64_t wait = now_ - (m.f_at + c_.victim_at);
    if (!pickVictim(vpend_[k])) {
      ++k;
      continue;
    }
    if (wait) h_.hit("dcu_fill_snap_late");
    h_.peak("dcu_fill_snap_wait_max", wait);
    // CHECK (DI-43): the snapshot waits at most kSnapWait (unless a pick
    // found no free way, the model's own held lines, which the RTL has not).
    if (!m.vnofree && wait > kSnapWait)
      h_.fail(fmt("dcu: fill of line %llx waited %llu cycles for its victim snapshot, past %llu (DI-43)", m.line,
                  wait, kSnapWait));
    vpend_.erase(vpend_.begin() + long(k));
  }
}

/// W: the fill's line, tags and fold go into its reserved way together. A
/// dirty victim's entry becomes its writeback (part 2); requests that need
/// ownership the fill did not bring look up again now.
void Core::fillWrite(unsigned id) {
  Miss &m = miss_.at(id);
  Way &w = l1_[size_t(m.way)];
  if (m.vdirty && !m.vread)
    h_.fail(fmt("dcu: the fill of line %llx wrote over dirty victim %llx before its read", m.line, m.vline));
  // DI-42: the fill's fold write, when it changes the way's entry (dcu_bctl
  // skips an unchanged one), opens the set's read-after-write margin.
  if (!w.fvalid || fold(w.line) != fold(m.line)) {
    auto &e = ftw_.try_emplace(size_t((m.line / kLineBytes) % c_.sets), ~0ull, ~0ull).first->second;
    e = {now_, e.first};
  }
  wnow_.push_back(size_t(m.way));
  w.valid = true;
  w.fvalid = true;
  w.flip = -1;   // a fill writes good check bits
  w.ecc_wr = false;
  w.line = m.line;
  w.data = m.fl;
  w.owned = m.fown;
  w.dirty = m.fdirty;
  w.rsv = -1;
  // Tag-stale marking (slice 2, part 1): a queued lookup whose tag result
  // named this way would read the fill's line under its old tag.
  for (Acc &x : bq_[bankOf(m.line)])
    if (x.k == Acc::Look && x.tway == m.way && x.line != m.line && !x.stale) {
      x.stale = true;
      h_.hit("dcu_tag_stale");
    }
  if (m.fdirty) h_.dirty(m.line, m.fl);
  unhold(m.line);
  m.written = true;
  h_.hit("dcu_fill_write");
  h_.hit("dcu_fill_write_wait", now_ - (m.f_at + 2 + c_.victim_at));
  const unsigned b = bankOf(m.line);
  for (Req r : m.relook) {
    r.ent_gone = true;   // its entry credit went back when it merged; its store data stays
    h_.hit("dcu_merge_relook");
    if (r.op == Op::Store) h_.hit("dcu_st_relook");
    bq_[b].push_back(Acc{Acc::Look, now_, now_, m.line, r, 0, {}});
  }
  m.relook.clear();
  if (m.vdirty) {
    m.k = MK::Evict;
    m.line = m.vline;
    wb_lines_.insert(m.vline);
    wbsend_.push_back(id);
  }
  maybeFree(id);
}

void Core::answered(unsigned id) {
  auto it = miss_.find(id);
  if (it == miss_.end() || !it->second.owed) {
    h_.fail(fmt("dcu: a fill answer for entry %llu, which owes none", id));
    return;
  }
  --it->second.owed;
  maybeFree(id);
}

/// A fill buffer frees once written and answered (its credit home); the
/// entry once its fill is written and answered, or, as a writeback, once
/// MLC has acknowledged it.
void Core::maybeFree(unsigned id) {
  auto it = miss_.find(id);
  Miss &m = it->second;
  if (m.fb && m.written && !m.owed) {
    m.fb = false;
    ++fill_release_;
  }
  const bool done = m.k == MK::Evict ? m.acked && !m.fb : m.written && !m.fb;
  if (done) {
    miss_.erase(it);
    freeId(id);
  }
}

/// OA-23: a refill noticed leaves exactly CCV_LAT_FILL_NOTICE after its
/// notice's payload lands (valid at F+6), its slot and credit reserved when
/// the notice goes; it may slip never. Un-noticed, it goes at the floor,
/// valid at F+4, if it can (DI-4, MA rev 129).
void Core::refill(const Rsp &r, const Ports &p) {
  const uint64_t at = now_ + 1 + c_.lat_notice + (c_.brk == "late-refill" ? 1 : 0);
  const unsigned s = r.slot;
  const bool ok = c_.notice && p.ntc_can[s] && p.rsp_credits[s] > resv_[s] && !promise_at_.count({at, s}) &&
                  std::none_of(notices_.begin(), notices_.end(),
                               [&](const Out::Notice &n) { return n.slot == s; });
  if (!ok) {
    // Un-noticed: the floor, 2 cycles ahead of a noticed one.
    respond(floorAt() - (c_.brk == "dcu-fill-early" ? 1 : 0), r);
    return;
  }
  notices_.push_back({s, c_.brk == "notice-wrong-id" ? r.req_id ^ 1u : r.req_id, r.tid});
  promised_.emplace(at, r);
  promise_at_.insert({at, s});
  ++resv_[s];
  ++st_.notices;
  h_.hit("fill_notice");
}

// ---- ECC on a read hit (MA-28 (c), AR 401; CCV_DCU_ECC_INJECT) -------------
/// Every Nth read hit flips one stored data bit of its line, under the check
/// bits of the line as written (the knob that replaced MIU's
/// CCV_MIU_ECC_INJECT; the count is the DCU stub's). The read carries it to
/// MIU, which finds it by the syndrome and withholds the completion; DCU's
/// own syndrome, over the same words (the slot's read), finds it too:
/// it counts the CE and queues the corrected line's rewrite `gap` cycles on,
/// a bank write like a store's RMW. It does not hold the line: a read before
/// the rewrite finds the same bit and is corrected the same way, so nothing
/// waits on it, and a rewrite whose line has left (a fill wrote good bits)
/// is dropped. The check bits are the block's: dcu-ecc-recode, the
/// control, codes the bad line, so MIU's syndrome is zero and the oracle
/// must catch the bad data.
int Core::eccOnHit(Way &w, const Req &r) {
  if (c_.ecc_every && w.flip < 0 && ++ecc_hits_ % c_.ecc_every == 0)
    w.flip = int((ecc_hits_ / c_.ecc_every * 67) % (kLineBytes * 8));
  if (w.flip < 0) return -1;
  ++st_.ce;
  h_.hit("dcu_ce");
  if (!w.ecc_wr) {
    if (fix_.size() >= 2 && c_.brk != "ce-rewrite-unbounded") {
      // dcu_fix holds one rewrite and one pending: this CE is counted and
      // not rewritten; the line is corrected again on its next read.
      ++st_.ce_full;
      h_.hit("ce_rewrite_full");
    } else {
      w.ecc_wr = true;
      fix_.push_back(r.pa);
      if (fix_.size() > 2) h_.fail(fmt("dcu: %zu CE rewrites held, dcu_fix holds 2", fix_.size()));
      if (fix_.size() == 1) fixStart(now_ + kFixStart);
    }
  }
  return w.flip;
}

/// dcu_fix's front rewrite asks its bank for the read.
void Core::fixStart(uint64_t ready) {
  const uint64_t l = fix_.front();
  bq_[bankOf(l)].push_back(Acc{Acc::EccR, now_, ready, l, Req{}, 0, {}});
}

/// The front rewrite is written (or moot): the pending one starts.
void Core::fixDone() {
  if (fix_.empty()) {
    h_.fail("dcu: a CE rewrite finished that dcu_fix did not hold");
    return;
  }
  fix_.pop_front();
  if (!fix_.empty()) fixStart(now_ + 1);
}

// ---- machine errors (AR 370, MA-19; the stub's injection, CCV_DCU_UE_INJECT) --

/// Every Nth read hit is a double-bit error at the array row the line
/// occupies (its set and way). A clean line at a row the track table does
/// not hold, with room in it, is recovered: the row recorded, the line
/// invalidated, the read refetched as a miss (1). A dirty line, a second UE
/// at a recorded row, or a full table is core-fatal (2): ue rises on
/// ccv_dcu_cru_err. Controls: ue-no-track, ue-dirty-recover.
int Core::ueOnHit(Way &w) {
  if (!c_.ue_every || ue_raised_ || ++ue_hits_ % c_.ue_every) return 0;
  const uint64_t loc = uint64_t(&w - l1_.data());
  const bool hard = std::find(ue_loc_.begin(), ue_loc_.end(), loc) != ue_loc_.end();
  const bool full = ue_loc_.size() >= c_.ue_track;
  if ((!w.dirty || c_.brk == "ue-dirty-recover") &&
      (c_.brk == "ue-no-track" || (!hard && !full))) {
    if (c_.brk != "ue-no-track") ue_loc_.push_back(loc);
    w.valid = false;
    w.fvalid = false;
    h_.hit("ue_recover");
    return 1;
  }
  ue_raised_ = true;
  h_.hit("ue_fatal");
  h_.fatal();
  std::fprintf(stderr, "UE dcu: core-fatal at set %llu way %llu (%s), line %llx\n",
               (unsigned long long)(loc / c_.ways), (unsigned long long)(loc % c_.ways),
               w.dirty ? "dirty" : hard ? "a recorded location" : "table full",
               (unsigned long long)w.line);
  return 2;
}

// ---- probes (slice 2, part 4) -------------------------------------------------

/// A probe checks the miss buffers before its lookup: an entry sent and not
/// filled acks at once (DCU does not hold the line; waiting could deadlock
/// against an MLC holding the grant for the ack); one filled and not written,
/// or a reserved dirty victim, waits for the fill's write; one in writeback
/// acks with no data, since the writeback carries the line, unless the
/// writeback has not launched: then the probe takes the line from its
/// buffer with the data, and the writeback is cancelled, so the line reaches
/// MLC once (AR-409, DCU tab rev 108; dcu-prb-double, the control, sends it
/// too). Its buffer and entry free when the ack launches, and misses to the
/// line wait until then. Else it looks up, a queue entry of its bank.
void Core::probeStart(unsigned id) {
  PrbBuf &x = prb_.at(id);
  const uint64_t pa = x.p.pa;
  for (const auto &m : miss_) {
    if (m.second.line != pa) continue;
    if (m.second.k == MK::Evict) {
      auto q = std::find(wbsend_.begin(), wbsend_.end(), m.first);
      if (q != wbsend_.end()) {
        if (c_.brk != "dcu-prb-double") wbsend_.erase(q);
        Miss &w = miss_.at(m.first);
        w.pcancel = true;
        x.dirty = x.wb = true;
        x.wbid = int(m.first);
        x.ack.data = true;
        x.ack.line = w.wb;
        h_.clean(pa);   // its line leaves with the ack
        h_.hit("dcu_prb_wb_cancel");
      }
      return probeDone(id, "dcu_prb_ack_wb");
    }
    if (m.second.filled && !m.second.written) {
      x.s = PrbBuf::WaitW;
      x.wfid = int(m.first);
      h_.hit("dcu_prb_wait_fill");
      return;
    }
    return probeDone(id, "dcu_prb_ack_sent");
  }
  if (const Way *w = find(pa))
    if (w->rsv >= 0 && w->dirty && miss_.count(unsigned(w->rsv)) && miss_.at(unsigned(w->rsv)).line != pa) {
      x.s = PrbBuf::WaitW;
      x.wfid = w->rsv;
      h_.hit("dcu_prb_wait_fill");
      return;
    }
  x.s = PrbBuf::Queued;
  const unsigned b = bankOf(pa);
  for (const Acc &a : bq_[b])
    if (a.line == pa && storeLike(a)) {
      h_.hit("dcu_prb_wait_store");
      break;
    }
  bq_[b].push_back(Acc{Acc::Prb, now_, now_ + 1, pa, Req{}, id, {}});
}

/// The probe's lookup (the tag RF's read-modify-write) and its outcome:
/// absent, ack; invalidate, the way invalid (fold valid and dirty cleared);
/// downgrade, an owned line shared; a dirty line's data read into a
/// writeback buffer and carried by the ack. Lookups that named its way are
/// tag-stale (part 1's rule).
void Core::probeServe(unsigned id) {
  PrbBuf &x = prb_.at(id);
  const uint64_t pa = x.p.pa;
  // CHECK (part 4): no acked store is lost to a probe (dcu-prb-nostore).
  if (stp_.count(pa)) h_.fail(fmt("dcu: probe %llu read line %llx before an acked store's write", id, pa));
  Way *w = find(pa);
  if (!w) return probeDone(id, x.p.inval ? "dcu_prb_inval_absent" : "dcu_prb_down_absent");
  const bool dirty = w->dirty;
  if (dirty) {
    x.dirty = true;
    x.wb = true;
    ++wb_used_;
    h_.peak("dcu_wb_max", wb_used_);
    h_.hit("dcu_prb_data_read");
    if (w->flip >= 0) h_.hit("dcu_prb_read_ce");
    if (c_.brk != "dcu-prb-nodirty") {
      x.ack.data = true;
      x.ack.line = w->data;
    }
    h_.clean(pa);   // its line leaves with the ack
  }
  const char *bin;
  if (x.p.inval) {
    bin = dirty ? "dcu_prb_inval_dirty" : w->owned ? "dcu_prb_inval_owned" : "dcu_prb_inval_shared";
    w->valid = w->owned = w->dirty = false;
    if (c_.brk != "dcu-prb-stale") w->fvalid = false;
  } else {
    bin = dirty ? "dcu_prb_down_dirty" : w->owned ? "dcu_prb_down_owned" : "dcu_prb_down_shared";
    w->owned = w->dirty = false;
  }
  const int way = int(w - l1_.data());
  for (Acc &a : bq_[bankOf(pa)])
    if (a.k == Acc::Look && a.tway == way && !a.stale) {
      a.stale = true;
      h_.hit("dcu_tag_stale");
      h_.hit("dcu_prb_relook");
    }
  probeDone(id, bin);
}

void Core::probeDone(unsigned id, const char *bin) {
  PrbBuf &x = prb_.at(id);
  x.s = PrbBuf::Done;
  x.ack.id = id;
  h_.hit(bin);
  prb_done_.push_back(id);
}

// ---- the cycle ----------------------------------------------------------------

Out Core::cycle(uint64_t t, const std::vector<Req> &in, const std::optional<Fill> &fill,
                const Ports &p, const std::optional<Probe> &prb) {
  now_ = t;
  ports_ = &p;
  notices_.clear();
  Out o;
  // Hits' PLRU touches due now (D + 3), before this cycle's victim picks.
  for (auto it = touch_at_.begin(); it != touch_at_.end() && it->first <= now_; it = touch_at_.erase(it))
    plruTouchWay(it->second);
  // Merged stores' store-data entries free at their merge (part 3).
  for (auto it = std_at_.begin(); it != std_at_.end() && it->first <= now_; it = std_at_.erase(it))
    stdLeave(it->second);
  fill_release_ = 0;
  // Victims for the fills that landed before now (F+1), oldest first; a
  // fill whose set has no free way waits in its buffer (its credit held).
  wnow_.clear();
  if (c_.victim_at < 2)
    for (size_t k = 0; k != vpend_.size();) {
      if (miss_.at(vpend_[k]).f_at + c_.victim_at <= now_ && pickVictim(vpend_[k])) vpend_.erase(vpend_.begin() + long(k));
      else ++k;
    }
  while (!wb_ack_due_.empty() && wb_ack_due_.begin()->first <= now_) {
    wbAcked(wb_ack_due_.begin()->second);
    wb_ack_due_.erase(wb_ack_due_.begin());
  }
  if (fill) onFill(*fill);
  // Probes (part 4): a landed one takes its buffer; those waiting on a
  // fill's write look again once it is done.
  if (prb) {
    if (prb_.count(prb->id) || prb_.size() >= kPrbBufs)
      h_.fail(fmt("dcu: probe req_id %llu landed with no free buffer", prb->id));
    else {
      prb_[prb->id].p = *prb;
      h_.hit(prb->inval ? "dcu_prb_inval" : "dcu_prb_down");
      probeStart(prb->id);
    }
  }
  for (auto &x : prb_)
    if (x.second.s == PrbBuf::WaitW) {
      auto it = miss_.find(unsigned(x.second.wfid));
      if (it == miss_.end() || it->second.written) probeStart(x.first);
    }
  retryWaits();
  // dcu_fill_bufs_full (MA-34, DI-58): cycles every fill buffer was held,
  // so MLC could send no fill; the recheck of 4 buffers under gtw reads it.
  if (size_t(std::count_if(miss_.begin(), miss_.end(), [](const auto &x) { return x.second.fb; })) >= c_.fills)
    h_.hit("dcu_fill_bufs_full");
  // dcu_wb_full (DI-21): cycles a victim read waited for a writeback buffer.
  if (wb_used_ >= c_.wb) {
    bool waits = false;
    for (const auto &q : bq_)
      for (const Acc &x : q) waits |= x.k == Acc::EvictR && x.ready <= now_;
    if (waits) h_.hit("dcu_wb_full");
  }
  for (const Req &r : in) arrive(r, t);
  schedule();
  if (c_.victim_at >= 2) pickVictims();
  // ccv_dcu_mlc_req, one a cycle (slice 2, part 2): writebacks first,
  // oldest first, each on its fill's entry (it frees a writeback buffer, so
  // lets a fill write); then misses. drop-writeback (dcu-wb-drop), the
  // control, never sends a dirty victim's line.
  if (p.mlc_can && !wbsend_.empty()) {
    const unsigned id = wbsend_.front();
    wbsend_.pop_front();
    // CHECK (part 4): a writeback a probe took is never sent too
    // (dcu-prb-double; its entry may have freed with the probe's ack).
    auto mi = miss_.find(id);
    if (mi == miss_.end() || mi->second.pcancel)
      h_.fail(fmt("dcu: writeback of entry %llu sent after a probe took it", id));
    if (mi != miss_.end()) {
      Miss &m = mi->second;
      --wb_used_;
      h_.clean(m.line);
      if (c_.brk == "drop-writeback" || c_.brk == "dcu-wb-drop") {
        wb_lines_.erase(m.line);
        m.acked = true;
        maybeFree(id);
      } else {
        MlcReq q;
        q.id = id;
        q.pa = m.line;
        q.op = MlcOp::Write;
        q.data = true;
        q.line = m.wb;
        o.mlc = q;
        h_.hit("dcu_wb_sent");
      }
    }
  } else if (p.mlc_can) {
    // The oldest unsent miss, its valid no earlier than D2 + 1 (H+5 for a
    // lookup's own D2): straight from D2 when nothing older waits. A bank
    // whose miss launched last cycle is passed over now (dcu_mpick: a bank
    // learns of its send a cycle on, its head picked a cycle ahead; DI-65),
    // as DI-35's retry grant passes over the bank it granted.
    auto it = to_mlc_.begin();
    for (; it != to_mlc_.end() && it->first < t; ++it)
      if (!(mlc_last_t_ + 1 == t && bankOf(it->second.pa) == mlc_last_bank_)) break;
    if (it != to_mlc_.end() && it->first < t) {
      if (it != to_mlc_.begin()) h_.hit("dcu_mpick_pass");
      if (it->first + 1 == t) h_.hit("dcu_mlc_straight");
      // dcu_mpick's stamp is 10 bits, taken at D2 and compared modulo
      // (DI-64, DCU tab rev 150): a miss picked past half the range would
      // order wrongly in the RTL, so the bin counts any (dcu_mpick_alias).
      if (t - it->first > 512) h_.hit("dcu_mpick_alias");
      o.mlc = it->second;
      mlc_last_t_ = t;
      mlc_last_bank_ = bankOf(it->second.pa);
      to_mlc_.erase(it);
    } else if (!to_mlc_.empty() && to_mlc_.front().first < t) {
      h_.hit("dcu_mpick_pass");
    }
  }
  // Probe acks, one a cycle, in the order their probes finished; the
  // payload's launch frees the buffer, its credit and a writeback buffer.
  if (!prb_done_.empty() && p.prb_can) {
    const unsigned id = prb_done_.front();
    prb_done_.pop_front();
    PrbBuf &x = prb_.at(id);
    if (x.dirty != x.ack.data)
      h_.fail(fmt("dcu: probe %llu acked ", id) + (x.ack.data ? "with data for a clean line" : "without data for a dirty line"));
    if (x.wb) --wb_used_;
    if (x.wbid >= 0 && miss_.count(unsigned(x.wbid))) {   // the cancelled writeback's entry
      Miss &w = miss_.at(unsigned(x.wbid));
      wb_lines_.erase(w.line);
      w.acked = true;
      maybeFree(unsigned(x.wbid));
    }
    o.prb_ack = x.ack;
    prb_.erase(id);
  }
  // Responses: promised refills first (a promise never slips), then those
  // due now, then those owed, one a slot a cycle.
  std::array<bool, kSlots> used{};
  std::array<unsigned, kSlots> cr = p.rsp_credits;
  for (auto it = promised_.begin(); it != promised_.end() && it->first <= t;) {
    const unsigned s = it->second.slot;
    if (it->first < t || !p.rsp_can[s] || used[s]) {
      h_.fail(fmt("dcu: the refill promised on slot %llu at cycle %llu cannot launch", s, it->first));
    } else {
      o.rsps.push_back(it->second);
      used[s] = true;
      --cr[s];
    }
    --resv_[s];
    promise_at_.erase({it->first, s});
    it = promised_.erase(it);
  }
  for (auto it = timed_.begin(); it != timed_.end() && it->first <= t; it = timed_.erase(it))
    late_.push_back(it->second);
  // Contracted answers (and the miss path's) on their own slot first; then
  // late bank answers, lowest bank first, each on the lowest free slot. One
  // that finds none keeps its word and holds its bank (slice 1, response
  // slots): the bank takes no access next cycle.
  // Slice 2, part 1's order for the late ones: a bank's late answer that
  // has waited CCV_DCU_BANK_AGE, then fill answers oldest first, then the
  // banks' other late answers, lowest bank first. Fill answers, like bank
  // ones, take any free slot.
  auto rank = [&](const Rsp &x) {
    if (x.bank < 0 && x.fid < 0) return 0;
    if (x.bank >= 0 && t - x.born >= c_.age) return 1;
    return x.fid >= 0 ? 2 : 3;
  };
  std::stable_sort(late_.begin(), late_.end(), [&](const Rsp &x, const Rsp &y) {
    const int a = rank(x), b = rank(y);
    if (a != b) return a < b;
    if (a == 2) return x.born < y.born;
    if (a == 3 || a == 1) return x.bank < y.bank;
    return false;
  });
  for (auto it = late_.begin(); it != late_.end();) {
    int s = -1;
    if (it->bank < 0 && it->fid < 0) {
      if (!used[it->slot] && p.rsp_can[it->slot] && cr[it->slot] > resv_[it->slot]) s = int(it->slot);
    } else {
      for (unsigned k = 0; k != kSlots && s < 0; ++k)
        if (!used[k] && p.rsp_can[k] && cr[k] > resv_[k]) s = int(k);
    }
    if (s >= 0) {
      it->slot = unsigned(s);
      o.rsps.push_back(*it);
      used[s] = true;
      --cr[s];
      it = late_.erase(it);
    } else {
      ++st_.rsp_credit_wait;
      h_.hit("dcu_rsp_wait");
      if (it->fid >= 0) h_.hit("dcu_fill_rsp_wait");
      if (it->bank >= 0) {
        h_.hit("dcu_late_holds_bank");
        for (const Acc &x : bq_[unsigned(it->bank)])
          if (x.k == Acc::FillW && t >= x.ready + kFillHold)
            h_.peak("dcu_fill_wait_late_max", t - x.ready);
        bfree_[unsigned(it->bank)] = std::max(bfree_[unsigned(it->bank)], t + 1);
      }
      ++it;
    }
  }
  // Fill answers that launched: their entries owe one fewer.
  // CHECKs (part 4): a recovered UE's second answer comes from a fill, and
  // comes (within kUeAnswerBound cycles).
  for (const Rsp &r : o.rsps) {
    if (r.ue_first) continue;
    auto it = ue_open_.find({r.slot, r.req_id});
    if (it == ue_open_.end() || it->second == t) continue;
    if (r.fid < 0) h_.fail(fmt("dcu: a recovered UE's second answer (req_id %llu) is not a fill's", r.req_id));
    ue_open_.erase(it);
  }
  for (const auto &u : ue_open_)
    if (t - u.second == kUeAnswerBound)
      h_.fail(fmt("dcu: a recovered UE (req_id %llu) has no second answer after %llu cycles", u.first.second,
                  kUeAnswerBound));
  // CHECK (slice 2, part 1): no fill answer's valid reaches MIU before
  // F+4, so none launches before F+3 (dcu-fill-early, the control).
  for (const Rsp &r : o.rsps)
    if (r.fid >= 0) {
      if (t + 1 < r.born + c_.lat_notice)
        h_.fail(fmt("dcu: a fill answer launched at F+%llu", t - r.born));
      answered(unsigned(r.fid));
    }
  o.notices = notices_;
  // MA-25's credit returns: at most one of each a bank a cycle.
  while (!ent_due_.empty() && ent_due_.begin()->first <= t) {
    entLeave(ent_due_.begin()->second);
    ent_due_.erase(ent_due_.begin());
  }
  for (unsigned b = 0; b != c_.banks; ++b) {
    h_.peak("dcu_ent_owed_max", ent_owed_[b]);   // dcu_bctl's owed counter (MA's DI-26 answer)
    if (ent_owed_[b]) { --ent_owed_[b]; o.ent_ret |= uint8_t(1u << b); h_.hit("dcu_ent_ret"); }
    if (std_owed_[b]) { --std_owed_[b]; o.std_ret |= uint8_t(1u << b); h_.hit("dcu_std_ret"); }
    // The queue's bounds, which MIU's credits keep (MA-25).
    size_t looks = ent_used_[b];
    if (looks >= c_.qdepth) { ++st_.at_qdepth; h_.hit("dcu_at_qdepth"); }
    if (std_used_[b] >= c_.stdata) { ++st_.at_stdata; h_.hit("dcu_at_stdata"); }
    // Refused once per admission past a bound, as the stub does, not every
    // cycle the bank stays over.
    const bool rose = looks > seen_ent_[b] || std_used_[b] > seen_std_[b];
    seen_ent_[b] = looks;
    seen_std_[b] = std_used_[b];
    if (rose && (looks > c_.qdepth || std_used_[b] > c_.stdata)) {
      if (c_.credits_strict)
        h_.fail(fmt("dcu: bank %llu holds %llu lookup entries and %llu store-data entries, past its credits (MA-25)",
                    b, looks, std_used_[b]));
      else
        h_.hit("dcu_queue_over");
    }
    h_.peak("dcu_qpeak", looks);
    h_.peak("dcu_stpeak", std_used_[b]);
  }
  if (ue_raised_ && !ue_sent_) {
    o.ue_raise = true;
    ue_sent_ = true;
  }
  if (!busy()) {
    ++st_.idle;
    h_.hit("dcu_idle_cycles");
  }
  o.fill_release = fill_release_;
  nfNext();
  return o;
}

bool Core::busy() const {
  if (!vpend_.empty() || !wbsend_.empty() || !ontime_.empty() || !miss_.empty() || !to_mlc_.empty() ||
      !timed_.empty() || !late_.empty() || !promised_.empty() ||
      !ent_due_.empty() || !wb_ack_due_.empty() || (ue_raised_ && !ue_sent_))
    return true;
  for (const auto &q : bq_)
    if (!q.empty()) return true;
  for (const auto &q : book_)
    if (!q.empty()) return true;
  if (!std_at_.empty() || !prb_.empty()) return true;
  return false;
}

} // namespace dcu
} // namespace ccv
