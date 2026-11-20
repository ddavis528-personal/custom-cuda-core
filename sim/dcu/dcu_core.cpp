//===-- dcu_core.cpp - the DCU's cycle-accurate model ---------------------===//
//
// See dcu_core.h for the cycle and the pipes. The DCU tab's Internals are the
// spec; the comments cite the rows that decide each rule.
//===----------------------------------------------------------------------===//
#include "dcu_core.h"

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
  bfree_.assign(c_.banks, 0);
  bq_.resize(c_.banks);
  ent_owed_.assign(c_.banks, 0);
  std_owed_.assign(c_.banks, 0);
  ent_used_.assign(c_.banks, 0);
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

/// A k-bit XOR fold of the tag (the line address above the set index).
unsigned Core::fold(uint64_t pa) const {
  uint64_t t = pa / kLineBytes / c_.sets, f = 0;
  for (; t; t >>= c_.wp_bits) f ^= t & ((1u << c_.wp_bits) - 1);
  return unsigned(f);
}

/// Pipe C's predictor (MA-23 (C), MA-26): among the valid ways whose fold
/// matches pa's, CCV_DCU_WAYPRED_SEL picks the lowest way (index) or the most
/// recently used (recent, true LRU). Read before the hit touches LRU.
bool Core::predicted(uint64_t pa) {
  const Way *s = setOf(pa), *pick = nullptr;
  const unsigned f = fold(pa);
  for (unsigned i = 0; i != c_.ways; ++i)
    if (s[i].valid && fold(s[i].line) == f) {
      if (!pick || (c_.wp_recent && s[i].used > pick->used)) pick = &s[i];
      if (!c_.wp_recent) break;
    }
  return pick && pick->line == pa;
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

/// Whether pa's line can be installed now: resident, or a way of its set
/// that no pending write or deferred store holds.
bool Core::canInstall(uint64_t pa) {
  if (find(pa)) return true;
  const Way *set = setOf(pa);
  for (unsigned i = 0; i != c_.ways; ++i)
    if (!set[i].valid || !held(set[i].line)) return true;
  return false;
}

/// pa's line into its set: its own way if resident, else an invalid way,
/// else the least recently used of the ways no pending write or store holds.
/// A dirty victim is read from its bank (EvictR) and written back whole.
Core::Way *Core::install(uint64_t pa, const Line &l, bool owned, bool dirty) {
  Way *w = find(pa);
  if (!w) {
    Way *s = setOf(pa);
    for (unsigned i = 0; i != c_.ways; ++i) {
      if (held(s[i].line) && s[i].valid) continue;
      if (!w || (w->valid && (!s[i].valid || s[i].used < w->used))) w = &s[i];
      if (!w->valid) break;
    }
    if (!w) {
      h_.fail(fmt("dcu: every way of line %llx's set is held: no victim", pa));
      w = s;
    }
    if (w->valid && w->dirty) {
      h_.hit("dcu_evict");
      ++st_.evicts;
      if (wb_pending_ >= c_.wb) h_.hit("dcu_wb_full");
      ++wb_pending_;
      wb_lines_.insert(w->line);
      const unsigned b = bankOf(w->line);
      Acc a{Acc::EvictR, now_, now_, w->line, Req{}, 0, w->data};
      bq_[b].push_back(a);
    }
  }
  w->valid = true;
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

void Core::arrive(const Req &r, uint64_t t) {
  const unsigned b = bankOf(r.pa);
  ++ent_used_[b];
  if (r.op == Op::Store) ++std_used_[b];
  ++st_.lookups;
  // A line with a miss in flight takes the request into its buffer's merge
  // list (MA-12), so it is answered from the fill, in order.
  for (auto &m : miss_)
    if (m.second.line == r.pa && m.second.k != MK::Evict) {
      entLeave(b);
      if (r.op == Op::Store) stdLeave(b);
      if (!startMiss(r)) stalled_.push_back(r);
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
    entLeave(b);
    if (r.op == Op::Store) stdLeave(b);
    if (!startMiss(r)) stalled_.push_back(r);
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
    for (size_t j = 0; j != i; ++j)
      if (bq_[b][j].k == Acc::EvictR) return false;
    return true;
  case Acc::EvictR:
    return true;
  case Acc::StoreW:
    return true;
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
    // it lost its bank): an owned hit merges now; else it misses.
    stdLeave(b);
    if (w && w->owned && c_.brk != "write-through") {
      merge(w->data, r);
      w->dirty = true;
      touch(*w);
      h_.dirty(r.pa, w->data);
      respond(now_ + launchOff(), rspFor(r));
      h_.hit("store_hit");
      return;
    }
    if (!startMiss(r)) stalled_.push_back(r);
    return;
  }
  const bool hit = w && (r.op == Op::Read || w->owned);
  if (!hit) {
    if (!startMiss(r)) stalled_.push_back(r);
    return;
  }
  if (c_.wp_bits && !r.reread) {
    if (predicted(r.pa)) {
      ++st_.wp_right;
      h_.hit("dcu_wp_right");
    } else if (c_.brk != "wp-late-at-due") {
      // A mispredict (DI-2; MA rev 121, AR 390, OA 442): the true way is
      // re-read in a second, ordinary access, under the half-rate rule and
      // the bank's queue, so it answers no earlier than due + 2, as a
      // bank-conflict loser would. It keeps its queue entry until then.
      // wp-late-at-due, the control, answers at due with the predicted way's
      // line, which MIU's oracle must catch.
      ++st_.wp_wrong;
      h_.hit("dcu_wp_wrong");
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
    if (!startMiss(r)) stalled_.push_back(r);
    return;
  }
  if (ue == 2) {
    // Core-fatal (AR 370 (4), AR 389, TI-487 (3)): DCU withholds the read.
    // MIU completes it on the machine-check kill, with no data. ue-answer,
    // the control, answers it anyway, and MIU must refuse the answer.
    h_.withheld(r.req_id);
    if (c_.brk != "ue-answer") return;
  }
  touch(*w);
  ++st_.hits;
  if (!miss_.empty()) h_.hit("hit_under_miss");
  Rsp s = rspFor(r);
  s.data = true;
  s.line = w->data;
  s.hit = true;
  if (c_.brk == "wp-late-at-due" && c_.wp_bits && !predicted(r.pa)) {
    // The predicted way's line, not the line asked for (the control).
    const Way *set = setOf(r.pa);
    for (unsigned i = 0; i != c_.ways; ++i)
      if (set[i].valid && set[i].line != r.pa) { s.line = set[i].data; break; }
  }
  if (r.reread) h_.hit("dcu_wp_reread");
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
    unhold(a.line);
    h_.hit("dcu_fill_write");
    break;
  case Acc::EvictR:
    wbq_.push_back({a.line, a.data});
    h_.hit("dcu_evict_read");
    break;
  }
}

/// Each bank, each cycle it is free, takes: the oldest eligible waiter once
/// it has waited CCV_DCU_BANK_AGE (it blocks new lookups and fills until
/// served; AR 364), else the first lookup due now in slot order (MA-7), else
/// the oldest eligible waiter (a fill writes only in a cycle with no lookup
/// to its bank: AR's MA-7 ask). Lookups due now that do not win wait in the
/// bank's queue and answer later, as a miss would.
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
    size_t old = bq_[b].size();
    for (size_t i = 0; i != bq_[b].size(); ++i)
      if (eligible(b, i)) { old = i; break; }
    const bool aged = old != bq_[b].size() && now_ - bq_[b][old].born >= c_.age &&
                      c_.brk != "bank-age-ignored";
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
      if (aged) {
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

/// A missing request: into its line's buffer's merge list if one is in
/// flight and has room, else a buffer of its own if one is free (with
/// dcu-one-miss, only when none is). False: it stalls, and so does the
/// channel (accepting()).
bool Core::startMiss(const Req &r) {
  for (auto &m : miss_)
    if (m.second.line == r.pa && m.second.k != MK::Evict) {
      if (m.second.reqs.size() >= c_.merge) {
        h_.hit("dcu_merge_full");
        return false;
      }
      m.second.reqs.push_back(r);
      ++st_.merged;
      h_.hit("dcu_merged");
      return true;
    }
  if (wb_lines_.count(r.pa)) return false;   // its writeback first
  if (free_ids_.empty()) {
    h_.hit("dcu_buffers_full");
    return false;
  }
  if (c_.brk == "dcu-one-miss")
    for (auto &m : miss_)
      if (m.second.k != MK::Evict) return false;
  const unsigned id = *free_ids_.begin();
  free_ids_.erase(free_ids_.begin());
  ++st_.misses;
  if (r.op == Op::Read) {
    miss_[id] = Miss{MK::Fill, r.pa, {r}, {}};
    mlcReq(MlcOp::Read, r.pa, nullptr, id, r.tid);
    h_.hit("l1_miss");
  } else if (r.op == Op::AtomRead) {
    miss_[id] = Miss{MK::AcqData, r.pa, {r}, {}};
    mlcReq(MlcOp::AcquireData, r.pa, nullptr, id, r.tid);
    h_.hit("l1_miss");
    h_.hit("atomic_acquire");
  } else if (c_.brk == "write-through") {
    // The policy before rev 8: every store a read-merge-write in MLC.
    if (fullLine(r, c_.brk)) {
      miss_[id] = Miss{MK::WriteAck, r.pa, {r}, r.wdata};
      Way *w = find(r.pa);
      if (w) w->data = r.wdata;
      mlcReq(MlcOp::Write, r.pa, &r.wdata, id, r.tid);
      h_.hit("full_line");
    } else {
      miss_[id] = Miss{MK::RmwRead, r.pa, {r}, {}};
      mlcReq(MlcOp::Read, r.pa, nullptr, id, r.tid);
    }
  } else if (fullLine(r, c_.brk)) {
    miss_[id] = Miss{MK::AcqPerm, r.pa, {r}, {}};
    mlcReq(MlcOp::AcquirePerm, r.pa, nullptr, id, r.tid);
    h_.hit("full_line");
  } else {
    miss_[id] = Miss{MK::AcqData, r.pa, {r}, {}};
    mlcReq(MlcOp::AcquireData, r.pa, nullptr, id, r.tid);
    h_.hit("l1_miss");
  }
  return true;
}

/// A fill or grant: answer its requests from its own data, in order, and
/// write the line into its bank when the bank has no lookup (FillW).
void Core::onFill(const Fill &f) {
  auto it = miss_.find(f.id);
  if (it == miss_.end()) {
    h_.fail(fmt("dcu: MLC answered req_id %llu, which is not outstanding", f.id));
    return;
  }
  Miss m = std::move(it->second);
  miss_.erase(it);
  free_ids_.insert(f.id);
  const uint64_t at = now_ + 1 + c_.lat_notice;   // fill to response (the floor)
  switch (m.k) {
  case MK::Evict:
    wb_lines_.erase(m.line);
    --wb_pending_;
    return;
  case MK::WriteAck:
    respond(at, rspFor(m.reqs.front()));
    for (size_t i = 1; i < m.reqs.size(); ++i) {   // merged behind it: look up again
      const unsigned b = bankOf(m.line);
      ++ent_used_[b];
      if (m.reqs[i].op == Op::Store) ++std_used_[b];
      bq_[b].push_back(Acc{Acc::Look, now_, now_, m.line, m.reqs[i], 0, {}});
    }
    return;
  case MK::RmwRead: {
    Line l = f.line;
    merge(l, m.reqs.front());
    install(m.line, l, false, false);
    hold(m.line);
    bq_[bankOf(m.line)].push_back(Acc{Acc::FillW, now_, now_, m.line, Req{}, f.id, {}});
    const unsigned id = *free_ids_.begin();
    free_ids_.erase(free_ids_.begin());
    miss_[id] = Miss{MK::WriteAck, m.line, std::move(m.reqs), l};
    mlcReq(MlcOp::Write, m.line, &l, id, miss_[id].reqs.front().tid);
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
  Line l = m.k == MK::AcqPerm ? m.reqs.front().wdata : f.line;
  bool dirty = false;
  const unsigned b = bankOf(m.line);
  size_t i = 0;
  for (; i != m.reqs.size(); ++i) {
    const Req &r = m.reqs[i];
    if (r.op != Op::Read && !want_own) break;   // needs ownership: re-looks up
    Rsp s = rspFor(r);
    if (r.op == Op::Store) {
      merge(l, r);
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
  install(m.line, l, want_own, dirty);
  hold(m.line);
  bq_[b].push_back(Acc{Acc::FillW, now_, now_, m.line, Req{}, f.id, {}});
  // What needed ownership a shared fill did not bring looks up again, in
  // order, after the fill's write.
  for (; i != m.reqs.size(); ++i) {
    ++ent_used_[b];
    if (m.reqs[i].op == Op::Store) ++std_used_[b];
    h_.hit("dcu_merge_relook");
    bq_[b].push_back(Acc{Acc::Look, now_, now_, m.line, m.reqs[i], 0, {}});
  }
}

/// OA-23: a refill noticed leaves exactly CCV_LAT_FILL_NOTICE after its
/// notice's payload lands, its slot and credit reserved when the notice
/// goes; it may slip never. Un-noticed, it goes at the floor if it can.
void Core::refill(const Rsp &r, const Ports &p) {
  const uint64_t at = now_ + 1 + c_.lat_notice + (c_.brk == "late-refill" ? 1 : 0);
  const unsigned s = r.slot;
  const bool ok = p.ntc_can[s] && p.rsp_credits[s] > resv_[s] && !promise_at_.count({at, s}) &&
                  std::none_of(notices_.begin(), notices_.end(),
                               [&](const Out::Notice &n) { return n.slot == s; });
  if (!ok) {
    respond(now_ + 1 + c_.lat_notice, r);
    return;
  }
  notices_.push_back({s, c_.brk == "notice-wrong-id" ? r.req_id ^ 1u : r.req_id, r.tid});
  promised_.emplace(at, r);
  promise_at_.insert({at, s});
  ++resv_[s];
  ++st_.notices;
  h_.hit("fill_notice");
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
  // A fill waits in its fill buffer while every way of its set is held by a
  // pending write or a deferred store (no victim yet); fills leave in order.
  if (fill) fills_.push_back(*fill);
  while (!fills_.empty()) {
    auto it = miss_.find(fills_.front().id);
    if (it != miss_.end() && it->second.k != MK::Evict && it->second.k != MK::WriteAck &&
        !canInstall(it->second.line)) {
      ++st_.fill_wait;
      h_.hit("dcu_fill_victim_wait");
      break;
    }
    onFill(fills_.front());
    fills_.pop_front();
  }
  for (const Req &r : in) arrive(r, t);
  schedule();
  // Stalled misses take freed buffers, oldest first; the channel holds
  // while any waits.
  while (!stalled_.empty() && startMiss(stalled_.front())) stalled_.pop_front();
  if (!stalled_.empty()) {
    ++st_.held_cycles;
    h_.hit("dcu_hold_cycles");
  }
  // Victims read from their banks leave on a req_id of their own.
  while (!wbq_.empty() && !free_ids_.empty()) {
    const auto v = wbq_.front();
    wbq_.pop_front();
    h_.clean(v.first);
    if (c_.brk == "drop-writeback") {
      wb_lines_.erase(v.first);
      --wb_pending_;
      continue;
    }
    const unsigned id = *free_ids_.begin();
    free_ids_.erase(free_ids_.begin());
    miss_[id] = Miss{MK::Evict, v.first, {}, v.second};
    mlcReq(MlcOp::Write, v.first, &v.second, id, 0);
  }
  if (!to_mlc_.empty() && p.mlc_can) {
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
  for (auto it = late_.begin(); it != late_.end();) {
    const unsigned s = it->slot;
    if (!used[s] && p.rsp_can[s] && cr[s] > resv_[s]) {
      o.rsps.push_back(*it);
      used[s] = true;
      --cr[s];
      it = late_.erase(it);
    } else {
      ++st_.rsp_credit_wait;
      h_.hit("dcu_rsp_wait");
      ++it;
    }
  }
  o.notices = notices_;
  // MA-25's credit returns: at most one of each a bank a cycle.
  for (unsigned b = 0; b != c_.banks; ++b) {
    if (ent_owed_[b]) { --ent_owed_[b]; o.ent_ret |= uint8_t(1u << b); h_.hit("dcu_ent_ret"); }
    if (std_owed_[b]) { --std_owed_[b]; o.std_ret |= uint8_t(1u << b); h_.hit("dcu_std_ret"); }
    // The queue's bounds, which MIU's credits keep (MA-25).
    size_t looks = ent_used_[b];
    if (looks >= c_.qdepth) { ++st_.at_qdepth; h_.hit("dcu_at_qdepth"); }
    if (std_used_[b] >= c_.stdata) { ++st_.at_stdata; h_.hit("dcu_at_stdata"); }
    if (looks > c_.qdepth || std_used_[b] > c_.stdata) {
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
  return o;
}

bool Core::busy() const {
  if (!fills_.empty() || !ontime_.empty() || !miss_.empty() || !stalled_.empty() || !to_mlc_.empty() ||
      !timed_.empty() || !late_.empty() || !promised_.empty() || !wbq_.empty() ||
      (ue_raised_ && !ue_sent_))
    return true;
  for (const auto &q : bq_)
    if (!q.empty()) return true;
  return false;
}

} // namespace dcu
} // namespace ccv
