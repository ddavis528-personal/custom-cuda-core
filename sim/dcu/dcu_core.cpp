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
  ent_owed_.assign(c_.banks, 0);
  std_owed_.assign(c_.banks, 0);
  ent_used_.assign(c_.banks, 0);
  seen_ent_.assign(c_.banks, 0);
  seen_std_.assign(c_.banks, 0);
  std_used_.assign(c_.banks, 0);
  for (unsigned i = 0; i != c_.ids; ++i) free_ids_.insert(i);
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

void Core::arrive(const Req &r, uint64_t t) {
  const unsigned b = bankOf(r.pa);
  ++ent_used_[b];
  if (r.op == Op::Store) ++std_used_[b];
  ++st_.lookups;
  // A line with a miss in flight takes the request into its buffer's merge
  // list (MA-12), so it is answered from the fill, in order.
  for (auto &m : miss_)
    if (m.second.line == r.pa && m.second.k != MK::Evict) {
      entLeave(b);   // its store data stays held until the fill merges it
      missOrWait(r);
      return;
    }
  // A store hit to an owned line, variant (b) (MA-17, MA-24): its read and
  // its whole-line write wait in the bank's queue as deferred work, holding
  // its data and mask; MIU's ack leaves on the hit's cycle.
  if (r.op == Op::Store && !needsMlc(r) && !wb_lines_.count(r.pa)) {
    Acc a{Acc::StoreR, t, t, r.pa, r, 0, {}};
    bq_[b].push_back(a);
    hold(r.pa);   // pinned (no eviction) until its write is done
    respond(t + dOff() + launchOff(), rspFor(r));
    h_.hit("store_hit");
    h_.hit("dcu_store_deferred");
    ++st_.store_def;
    return;
  }
  // A store or atomic that needs MLC is known a miss from the tags (D2).
  if (r.op != Op::Read && needsMlc(r) && !wb_lines_.count(r.pa)) {
    // The lookup entry leaves now; the store-data entry is held until the
    // store's write leaves, when the fill merges it (DCU spec, MA-25).
    entLeave(b);
    missOrWait(r);
    return;
  }
  ontime_[t + dOff()].push_back(r);
}

// ---- the banks --------------------------------------------------------------

bool Core::olderLook(unsigned b, size_t upto, uint64_t line) const {
  for (size_t j = 0; j != upto && j != bq_[b].size(); ++j)
    if (bq_[b][j].line == line && (bq_[b][j].k == Acc::Look || bq_[b][j].k == Acc::StoreR))
      return true;
  return false;
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
    if (olderLook(b, i, a.line) || wb_lines_.count(a.line)) return false;
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
  entLeave(b);
  const unsigned late = unsigned(now_ - born - dOff());   // cycles past its D
  if (late) {
    ++st_.waited;
    h_.peak("dcu_wait_max", late);
  }
  Way *w = find(r.pa);
  if (r.op == Op::Store) {
    // A store that waited as a lookup (its line was being written back, or
    // it lost its bank): an owned hit merges now; else it misses, and its
    // store-data entry stays held until the fill merges it.
    if (w && w->owned && c_.brk != "write-through") {
      stdLeave(b);
      w->flip = -1;   // the RMW's read corrects, its write is good (MA-28 (c))
      w->ecc_wr = false;
      merge(w->data, r);
      w->dirty = true;
      touch(*w);
      h_.dirty(r.pa, w->data);
      respond(now_ + launchOff(), rspFor(r));
      h_.hit("store_hit");
      return;
    }
    missOrWait(r);
    return;
  }
  const bool hit = w && (r.op == Op::Read || w->owned);
  // Pipe C's fold compare (slice 1, MA-30): a lookup whose fold matches no
  // valid way of its set is a miss that reads nothing (dcu_bctl clears the
  // SRAM ce at D1, so the bank's next cycle is free); a fold match on a
  // miss reads the predicted way's word and discards it. A tag hit always
  // has a fold match (the CHECK).
  const bool fm = c_.wp_bits && !r.reread && !c_.wp_mru && foldMatch(r.pa);
  if (c_.wp_bits && !r.reread && !c_.wp_mru) {
    if (hit && !fm) h_.fail(fmt("dcu: a tag hit on line %llx without a fold match", r.pa));
    if (!hit && fm) {
      h_.hit("dcu_wp_fold_miss");
      h_.hit("dcu_wp_reaccess_cycles", 2);
    } else if (!hit) {
      h_.hit("dcu_wp_nomatch_miss");
      if (bfree_[b] == now_ + 2 && c_.brk != "wp-nomatch-reads") bfree_[b] = now_ + 1;
    }
  }
  if (!hit) {
    missOrWait(r);
    return;
  }
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
      ++ent_used_[b];
      --ent_owed_[b];
      Req x = r;
      x.reread = true;
      bq_[b].push_back(Acc{Acc::Look, born, now_ + 2, r.pa, x, 0, {}});
      return;
    } else {
      ++st_.wp_wrong;
      h_.hit("dcu_wp_wrong");
    }
  }
  const int ue = ueOnHit(*w);
  if (ue == 1) {   // recovered: the line is gone, the read refetches it
    missOrWait(r);
    return;
  }
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
    serveLook(a.req, born);
    break;
  case Acc::StoreR: {
    // The store's read (SECDED-corrected, 2 stages): D3 merges under the
    // mask, and the whole line goes back to the bank `gap` cycles on.
    entLeave(b);
    Way *w = find(a.line);
    if (!w || !w->owned) {
      h_.fail(fmt("dcu: a deferred store's line %llx left L1 before its read", a.line));
      break;
    }
    w->flip = -1;   // the RMW's read corrects, its write is good (MA-28 (c))
    w->ecc_wr = false;
    merge(w->data, a.req);
    w->dirty = true;
    touch(*w);
    h_.dirty(a.line, w->data);
    const uint64_t at = c_.brk == "store-write-early" ? now_ + 1 : now_ + c_.gap;
    bq_[b].push_back(Acc{Acc::StoreW, now_, at, a.line, a.req, 0, {}});
    h_.hit("dcu_store_read");
    break;
  }
  case Acc::StoreW:
    stdLeave(b);
    unhold(a.line);
    st_.rd_wr_cycles += now_ - a.born;
    h_.hit("dcu_store_write");
    h_.hit("dcu_store_rdwr_sum", now_ - a.born);
    if (now_ - a.born < c_.gap) h_.fail(fmt("dcu: store write %llu cycles after its read, under the gap %llu (TI-483)", now_ - a.born, c_.gap));
    break;
  case Acc::FillW:
    if (a.fb == ~0u) {   // write-through's RMW fill (installed at F)
      unhold(a.line);
      h_.hit("dcu_fill_write");
    } else {
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
  case Acc::EvictR: {
    // The dirty victim's read (slice 2, part 2) into a writeback buffer;
    // its fill's write takes the bank's next access, 2 cycles on.
    Miss &m = miss_.at(a.fb);
    m.wb = l1_[size_t(m.way)].data;
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
    size_t old = bq_[b].size();
    for (size_t i = 0; i != bq_[b].size(); ++i)
      if (eligible(b, i)) { old = i; break; }
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
      if (!earlier && !held(l) && !olderLook(b, bq_[b].size(), l) && !wb_lines_.count(l)) win = i;
    }
    bool fill_waits = false;
    for (size_t i = 0; i != bq_[b].size(); ++i)
      fill_waits |= bq_[b][i].k == Acc::FillW && eligible(b, i);
    const bool both = c_.brk == "bank-both-granted";
    if (bfree_[b] <= now_ || (both && win != in.size())) {
      if (rr != bq_[b].size() || (!aged && fx != bq_[b].size())) {
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
      } else if (old != bq_[b].size()) {
        const Acc a = bq_[b][old];
        bq_[b].erase(bq_[b].begin() + long(old));
        claim(b);
        serve(a, a.born);
      }
    } else if (fill_waits) {
      ++st_.fill_wait;
      h_.hit("dcu_fill_wait");
    }
    for (const Req &r : in) {
      ++st_.losers;
      h_.hit("dcu_bank_loser");
      h_.hit(r.slot == 0 ? "dcu_bank_loser_s0" : r.slot == 1 ? "dcu_bank_loser_s1"
             : r.slot == 2 ? "dcu_bank_loser_s2" : "dcu_bank_loser_s3");
      bq_[b].push_back(Acc{Acc::Look, now_ - dOff(), now_, r.pa, r, 0, {}});
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

void Core::mlcReq(MlcOp op, uint64_t pa, const Line *d, unsigned id, uint64_t tid) {
  MlcReq m;
  m.id = id;
  m.pa = pa;
  m.op = op;
  m.tid = tid;
  if (d) {
    m.data = true;
    m.line = *d;
  }
  to_mlc_.push_back(m);
}

/// Slice 2, part 1: a miss merges or allocates at D2; else it takes an
/// entry in its bank's queue, marked miss-wait, keeping its entry credit
/// (MA-12's hold: MIU's credits stop the channel, nothing is refused). A
/// miss also waits while its bank already holds a waiting one, so a line's
/// requests stay in arrival order (one line is one bank); dcu-miss-reorder,
/// the control, lets a new miss pass a waiting one of its line.
void Core::missOrWait(const Req &r) {
  const unsigned b = bankOf(r.pa);
  bool waits = false;
  for (const Acc &x : bq_[b]) {
    if (x.k != Acc::MissW) continue;
    if (c_.brk == "dcu-miss-reorder" && x.line != r.pa) continue;
    waits = true;
    break;
  }
  const char *why = "dcu_miss_wait_order";
  if (!waits) {
    for (const Acc &x : bq_[b])
      if (x.k == Acc::MissW && x.line == r.pa)
        h_.fail(fmt("dcu: a miss to line %llx passed a waiting one", r.pa));
    if (startMiss(r, &why)) return;
  }
  // CHECK: a line's misses never pass a waiting one (slice 2, part 1).
  ++ent_used_[b];   // its entry credit stays out until it leaves the queue
  --ent_owed_[b];
  h_.hit(why);
  h_.hit("dcu_miss_wait");
  bq_[b].push_back(Acc{Acc::MissW, now_, now_ + 1, r.pa, r, 0, {}});
}

/// Each bank's oldest waiting miss retries, one a cycle, ahead of the
/// bank's new misses. A line its fill has since written is a hit: it looks
/// up again (a late answer). Leaving the queue returns its entry credit.
void Core::retryWaits() {
  for (unsigned b = 0; b != c_.banks; ++b) {
    for (size_t i = 0; i != bq_[b].size(); ++i) {
      Acc &a = bq_[b][i];
      if (a.k != Acc::MissW) continue;
      h_.hit("dcu_miss_wait_cycles");
      if (a.ready > now_) break;
      const Req r = a.req;
      const Way *w = find(r.pa);
      if (w && (r.op == Op::Read || w->owned)) {
        a.k = Acc::Look;   // keeps its place and its credit: served as a waiter
        h_.hit("dcu_miss_wait_relook");
        break;
      }
      const char *why = nullptr;
      if (startMiss(r, &why)) {
        bq_[b].erase(bq_[b].begin() + long(i));
        entLeave(b);
        h_.hit("dcu_miss_wait_done");
      }
      break;   // one a bank a cycle, oldest first
    }
  }
}

/// A missing request: into its line's buffer's merge list if one is in
/// flight and has room, else a buffer of its own if one is free (with
/// dcu-one-miss, only when none is). False: it stalls, and so does the
/// channel (accepting()).
bool Core::startMiss(const Req &r, const char **why) {
  const char *dummy;
  if (!why) why = &dummy;
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
  if (free_ids_.empty()) {
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
  const unsigned id = *free_ids_.begin();
  free_ids_.erase(free_ids_.begin());
  ++st_.misses;
  if (r.op == Op::Read) {
    miss_[id] = newMiss(MK::Fill, r.pa, {r}, {});
    mlcReq(MlcOp::Read, r.pa, nullptr, id, r.tid);
    h_.hit("l1_miss");
  } else if (r.op == Op::AtomRead) {
    miss_[id] = newMiss(MK::AcqData, r.pa, {r}, {});
    mlcReq(MlcOp::AcquireData, r.pa, nullptr, id, r.tid);
    h_.hit("l1_miss");
    h_.hit("atomic_acquire");
  } else if (c_.brk == "write-through") {
    // The policy before rev 8: every store a read-merge-write in MLC.
    if (fullLine(r, c_.brk)) {
      miss_[id] = newMiss(MK::WriteAck, r.pa, {r}, r.wdata);
      Way *w = find(r.pa);
      if (w) w->data = r.wdata;
      mlcReq(MlcOp::Write, r.pa, &r.wdata, id, r.tid);
      stdLeave(bankOf(r.pa));   // the whole line's write leaves for MLC
      h_.hit("full_line");
    } else {
      miss_[id] = newMiss(MK::RmwRead, r.pa, {r}, {});
      mlcReq(MlcOp::Read, r.pa, nullptr, id, r.tid);
    }
  } else if (fullLine(r, c_.brk)) {
    miss_[id] = newMiss(MK::AcqPerm, r.pa, {r}, {});
    mlcReq(MlcOp::AcquirePerm, r.pa, nullptr, id, r.tid);
    h_.hit("full_line");
  } else {
    miss_[id] = newMiss(MK::AcqData, r.pa, {r}, {});
    mlcReq(MlcOp::AcquireData, r.pa, nullptr, id, r.tid);
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
  const uint64_t at = floorAt() - (c_.brk == "dcu-fill-early" ? 1 : 0);
  switch (m.k) {
  case MK::Evict:
    // MLC's acknowledgement: no fill buffer, the credit back at once, and
    // the entry free (CHECK: it names a writeback whose request has gone).
    ++fill_release_;
    if (!m.written || std::find(wbsend_.begin(), wbsend_.end(), f.id) != wbsend_.end())
      h_.fail(fmt("dcu: MLC acknowledged req_id %llu, a writeback not yet sent", f.id));
    wb_lines_.erase(m.line);
    m.acked = true;
    maybeFree(f.id);
    return;
  case MK::WriteAck: {
    Miss w = std::move(m);
    miss_.erase(it);
    free_ids_.insert(f.id);
    ++fill_release_;
    respond(at, rspFor(w.reqs.front()));
    for (size_t i = 1; i < w.reqs.size(); ++i) {   // merged behind it: look up again
      const unsigned b = bankOf(w.line);
      ++ent_used_[b];   // a store's data entry is still held from its arrival
      bq_[b].push_back(Acc{Acc::Look, now_, now_, w.line, w.reqs[i], 0, {}});
    }
    return;
  }
  case MK::RmwRead: {
    Miss w = std::move(m);
    miss_.erase(it);
    free_ids_.insert(f.id);
    ++fill_release_;
    Line l = f.line;
    merge(l, w.reqs.front());
    stdLeave(bankOf(w.line));   // the partial store's write leaves with the merge
    install(w.line, l, false, false);
    hold(w.line);
    bq_[bankOf(w.line)].push_back(Acc{Acc::FillW, now_, now_, w.line, Req{}, ~0u, {}});
    const unsigned id = *free_ids_.begin();
    free_ids_.erase(free_ids_.begin());
    miss_[id] = newMiss(MK::WriteAck, w.line, std::move(w.reqs), l);
    mlcReq(MlcOp::Write, w.line, &l, id, miss_[id].reqs.front().tid);
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
  Line l = m.k == MK::AcqPerm ? m.reqs.front().wdata : f.line;
  bool dirty = false;
  const unsigned b = bankOf(m.line);
  size_t i = 0;
  for (; i != m.reqs.size(); ++i) {
    const Req &r = m.reqs[i];
    if (r.op != Op::Read && !want_own) break;   // needs ownership: re-looks up
    Rsp s = rspFor(r);
    s.fid = int(f.id);
    s.born = now_;
    ++m.owed;
    if (r.op == Op::Store) {
      merge(l, r);
      stdLeave(b);   // its write leaves: the store-data credit goes home
      dirty = true;
      respond(at, s);   // the store's ack
      continue;
    }
    s.data = true;
    s.line = l;
    s.mlc_miss = f.miss;
    if (r.op == Op::Read) refill(s, *ports_);
    else respond(at, s);
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
  auto free_way = [&](const Way &x) { return x.rsv < 0 && !(x.valid && held(x.line)); };
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
    return false;
  }
  if (!w->valid) h_.hit("dcu_victim_invalid");
  else if (plru) h_.hit("dcu_victim_plru");
  w->rsv = int(id);
  m.way = int(w - l1_.data());
  touch(*w);
  const unsigned b = bankOf(m.line);
  const uint64_t ready = m.f_at + 3;
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
  return true;
}

/// W: the fill's line, tags and fold go into its reserved way together. A
/// dirty victim's entry becomes its writeback (part 2); requests that need
/// ownership the fill did not bring look up again now.
void Core::fillWrite(unsigned id) {
  Miss &m = miss_.at(id);
  Way &w = l1_[size_t(m.way)];
  if (m.vdirty && !m.vread)
    h_.fail(fmt("dcu: the fill of line %llx wrote over dirty victim %llx before its read", m.line, m.vline));
  w.valid = true;
  w.flip = -1;   // a fill writes good check bits
  w.ecc_wr = false;
  w.line = m.line;
  w.data = m.fl;
  w.owned = m.fown;
  w.dirty = m.fdirty;
  w.rsv = -1;
  if (m.fdirty) h_.dirty(m.line, m.fl);
  unhold(m.line);
  m.written = true;
  h_.hit("dcu_fill_write");
  h_.hit("dcu_fill_write_wait", now_ - (m.f_at + 3));
  const unsigned b = bankOf(m.line);
  for (const Req &r : m.relook) {
    ++ent_used_[b];   // a store's data entry is still held from its arrival
    h_.hit("dcu_merge_relook");
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
    free_ids_.insert(id);
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
    respond(floorAt(), r);   // un-noticed: the floor, 2 cycles ahead of a noticed one
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

// ---- the cycle ----------------------------------------------------------------

Out Core::cycle(uint64_t t, const std::vector<Req> &in, const std::optional<Fill> &fill,
                const Ports &p) {
  now_ = t;
  ports_ = &p;
  notices_.clear();
  Out o;
  // Hits' PLRU touches due now (D + 3), before this cycle's victim picks.
  for (auto it = touch_at_.begin(); it != touch_at_.end() && it->first <= now_; it = touch_at_.erase(it))
    plruTouchWay(it->second);
  fill_release_ = 0;
  // Victims for the fills that landed before now (F+1), oldest first; a
  // fill whose set has no free way waits in its buffer (its credit held).
  for (size_t k = 0; k != vpend_.size();) {
    if (miss_.at(vpend_[k]).f_at < now_ && pickVictim(vpend_[k])) vpend_.erase(vpend_.begin() + long(k));
    else ++k;
  }
  if (fill) onFill(*fill);
  retryWaits();
  for (const Req &r : in) arrive(r, t);
  schedule();
  // ccv_dcu_mlc_req, one a cycle (slice 2, part 2): writebacks first,
  // oldest first, each on its fill's entry (it frees a writeback buffer, so
  // lets a fill write); then misses. drop-writeback (dcu-wb-drop), the
  // control, never sends a dirty victim's line.
  if (p.mlc_can && !wbsend_.empty()) {
    const unsigned id = wbsend_.front();
    wbsend_.pop_front();
    Miss &m = miss_.at(id);
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
  } else if (!to_mlc_.empty() && p.mlc_can) {
    o.mlc = to_mlc_.front();
    to_mlc_.pop_front();
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
      if (it->bank >= 0) {
        h_.hit("dcu_late_holds_bank");
        bfree_[unsigned(it->bank)] = std::max(bfree_[unsigned(it->bank)], t + 1);
      }
      ++it;
    }
  }
  // Fill answers that launched: their entries owe one fewer.
  for (const Rsp &r : o.rsps)
    if (r.fid >= 0) answered(unsigned(r.fid));
  o.notices = notices_;
  // MA-25's credit returns: at most one of each a bank a cycle.
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
  return o;
}

bool Core::busy() const {
  if (!vpend_.empty() || !wbsend_.empty() || !ontime_.empty() || !miss_.empty() || !to_mlc_.empty() ||
      !timed_.empty() || !late_.empty() || !promised_.empty() ||
      (ue_raised_ && !ue_sent_))
    return true;
  for (const auto &q : bq_)
    if (!q.empty()) return true;
  return false;
}

} // namespace dcu
} // namespace ccv
