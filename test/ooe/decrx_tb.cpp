//===-- decrx_tb.cpp - ooe_decrx and its arrival compare against the model -===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode) and,
// just before every core cycle, takes the model's log of the cycle just run
// (Core::rxLog): the slots whose warp's epoch advanced (at a redirect, or
// at a demotion's or a kill's epoch notice), the slots released,
// the allocations, and every uop that arrived after the cycle (kept or
// dropped, with its warp and fetch_epoch), plus each slot's warp and its
// warp's epoch after it, and the slots ooe_decq flushed (Core::decqFlushed).
//
// The model's arrivals come after its cycle's events, so they compare
// against the epochs those events left: the RTL's events and arrivals share
// a drive, and the compare takes an advancing slot's next epoch, or the one
// after when a redirect and a notice land together (OA 428 (2)).
// A release and an allocation take effect from the next drive; an arrival
// for a warp allocated or released in its own drive is counted and fails
// the bench (the RTL has no bypass for it).
//
// The RTL runs one log behind, so the event lead (ev_l) goes a tick before
// its events. The arrivals are the lead form's (OA 432, re:OI-169): each
// port's valid, warp_id and fetch_epoch land a cycle ahead of the payload,
// and ooe_decrx compares them then. So each drive presents the next edge's
// arrivals beside this edge's events, and its verdict (kept valid and slot,
// from the flops ooe_decq takes them from) lands with their payload, at the
// next edge. The model's keep includes that edge's events; the RTL's does
// not. So, per arrival: a uop the model keeps must be kept, at its slot, and
// its slot must not flush at that edge (ooe_decq's late flush would drop a
// right-path uop); a uop the model drops may be kept only when its slot
// flushes at that edge (OA 430, re:OI-168 (B): ooe_decq's late flush drops
// it), and is counted (flush-dropped); any other keep differs. A dropped uop
// takes no decode-queue entry, so it never counts against ooe_decq's
// credits: used_cq02h is decq_tb's. Every slot's valid, warp and epoch must
// be the model's. OA 428's ordering invariant is the bench's assertion:
// every slot ooe_decq flushes in a drive had its advance (or its release)
// driven no later than that drive.
//
// Negative controls (DECRX_CONTROL=<name>) must be caught: adv-late (OA's:
// each advance reaches the RTL one drive late; caught by the ordering
// count and a right-path drop), late-lead (OA 432's: the lead fields come a
// cycle late, each port's warp_id and fetch_epoch the last drive's), no-adv-bypass (every arrival of a slot
// advancing in its drive has its slot's old and advanced epochs swapped,
// so the RTL decides as a compare without the bypass would: it keeps the
// old epoch's uops the model drops), no-double (a notice beside a redirect on one slot advances it
// once), no-double-adv (the same from the redirect's side: a redirect
// beside a notice is masked, so the slot takes the notice's single advance,
// not s2), keep-stale (a dropped uop reaches the ports with its warp's live
// epoch, so it must be kept: the bench expects the model's drop),
// no-ev-lead (the event lead never reaches it), no-rel (a release never
// reaches it) and no-walk (a demotion's notice never opens its straggler
// walk: the stragglers the model keeps for it are dropped, AR 395) and
// row-early (an arrival of a warp in its allocation's drive, a cycle before
// its row is written: keep_row_settled, by name; OA 509 (3c)).
//
// The straggler walk (AR 395, #71): a demotion's notice opens the slot's
// walk (wo, from the model's log), and every resident slot's walk bit and,
// while open, its epoch are compared after each edge.
//
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: decrx_tb [seeds] | decrx_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_decrx_tb.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Core;

namespace {
constexpr unsigned S = RX_S, E = RX_E, NW = 32, EP = 3, P = 16;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned LS = bits(S), LW = bits(NW);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_decrx_tb> dut;
std::string control;
uint64_t current = 0;
// A cycle as the model logged it, and the slots after it.
struct Edge {
  Core::RxLog log;
  uint32_t fl = 0;
  bool sv[S] = {};
  unsigned sw[S] = {}, se[S] = {};
  bool wo[S] = {};
  unsigned wep[S] = {};
};
Edge pend;
bool have_pend = false;
uint32_t late_adv = 0, late_adn = 0, late_wo = 0;
// A stale uop kept in its lead cycle whose slot flushes as it reaches
// ooe_decq: dropped there (OA 430). A right-path one so dropped fails.
uint64_t held_flush = 0, right_path = 0, walk_held = 0;
// late-lead: the last drive's lead fields, per port.
unsigned last_warp[E] = {}, last_ep[E] = {};
unsigned long long cycles = 0, arrivals = 0, kept = 0, dropped = 0, advs = 0, doubles = 0, reloc = 0, rels = 0, allocs = 0, flushes = 0,
                   same_drive = 0, cores = 0, mismatches = 0, order_fails = 0,
                   walks_open = 0;

template <typename T> void setField(T &w, unsigned lsb, unsigned n, uint64_t v) {
  for (unsigned b = 0; b != n; ++b) {
    const unsigned i = lsb + b;
    const bool x = (v >> b) & 1u;
    if constexpr (sizeof(T) <= 8) {
      if (x) w |= (T(1) << i); else w &= ~(T(1) << i);
    } else {
      if (x) w[i / 32] |= (1u << (i % 32)); else w[i / 32] &= ~(1u << (i % 32));
    }
  }
}
template <typename T> unsigned getField(const T &w, unsigned lsb, unsigned n) {
  unsigned v = 0;
  for (unsigned b = 0; b != n; ++b) {
    const unsigned i = lsb + b;
    bool x;
    if constexpr (sizeof(T) <= 8) x = (w >> i) & 1u;
    else x = (w[i / 32] >> (i % 32)) & 1u;
    v |= unsigned(x) << b;
  }
  return v;
}

CgRun cg;

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}

void fail(const char *what, unsigned where, unsigned rtl, unsigned model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "%s, cycle %llu at %u: %s (rtl %u, model %u)\n", ooeTestName(), cycles, where, what, rtl,
                 model);
}

// The leads per source (OA 447): slot s's ooe_rob_w for its advance (bit
// s), ooe_slot for a notice's advance, a release or an allocation (bit S).
uint32_t evLeads(const Edge &e) {
  uint32_t m = 0;
  for (unsigned s : e.log.adv) if (s < S) m |= 1u << s;
  if (!e.log.adn.empty() || e.log.rel || !e.log.alloc.empty()) m |= 1u << S;
  return m;
}

void drive(const Edge &e, const Edge *nx, uint32_t lead) {
  ++cycles;
  uint32_t adv = 0, adn = 0;
  for (unsigned s : e.log.adv) {
    if (adv >> s & 1u) fail("two redirects of a slot in a cycle", s, 0, 0);
    adv |= 1u << s;
  }
  for (unsigned s : e.log.adn) {
    if (adn >> s & 1u) fail("two epoch notices of a slot in a cycle", s, 0, 0);
    adn |= 1u << s;
  }
  advs += e.log.adv.size() + e.log.adn.size();
  doubles += __builtin_popcount(adv & adn);
  uint32_t drv_adv = adv, drv_adn = adn;
  uint32_t drv_wo = control == "no-walk" ? 0 : e.log.wopen;
  if (e.log.wopen & ~adn) fail("a walk opened without its notice", e.log.wopen & ~adn, 0, adn);
  if (control == "adv-late") {
    drv_adv = late_adv; late_adv = adv; drv_adn = late_adn; late_adn = adn;
    const uint32_t w = drv_wo; drv_wo = late_wo; late_wo = w;
  }
  if (control == "no-double") drv_adn &= ~drv_adv;
  if (control == "no-double-adv") drv_adv &= ~drv_adn;
  const uint32_t rel = control == "no-rel" ? 0 : e.log.rel;
  rels += __builtin_popcount(e.log.rel);
  // OA 428's ordering invariant: a flushed slot's advance (or its release)
  // is driven no later than the flush.
  if (e.fl & ~(drv_adv | drv_adn | rel)) {
    ++order_fails;
    fail("a flush before its slot's advance", e.fl & ~(drv_adv | drv_adn | rel), drv_adv | drv_adn, adv | adn);
  }
  flushes += __builtin_popcount(e.fl);
  dut->adv_cq01h = drv_adv;
  dut->adn_cq01h = drv_adn;
  dut->wo_cq01h = drv_wo & drv_adn;
  dut->rel_cq01h = rel;
  dut->al_v_cq01h = 0;
  uint32_t al_warps = 0;
  for (const auto &a : e.log.alloc) {
    if (dut->al_v_cq01h >> a.first & 1u) fail("two allocations of a slot in a cycle", a.first, 0, 0);
    dut->al_v_cq01h |= 1u << a.first;
    setField(dut->al_warp_cq01h, a.first * LW, LW, a.second);
    al_warps |= 1u << a.second;
    ++allocs;
    for (unsigned t = 0; t != S; ++t)
      if ((dut->sv_cq02h >> t & 1u) && !(e.log.rel >> t & 1u) && getField(dut->sw_cq02h, t * LW, LW) == a.second)
        fail("an allocation of a warp resident elsewhere", a.first, t, a.second);
    for (unsigned t = 0; t != S; ++t)
      reloc += (e.log.rel >> t & 1u) && getField(dut->sw_cq02h, t * LW, LW) == a.second;
  }
  uint32_t rel_warps = 0;
  for (unsigned s = 0; s != S; ++s)
    if (e.log.rel >> s & 1u) rel_warps |= 1u << getField(dut->sw_cq02h, s * LW, LW);   // the RTL's, before the edge
  // adv-late carries this drive's advances to the next, so it leads them
  // there: the control tests the ordering invariant, not the lead.
  if (control == "adv-late" && (late_adv | late_adn)) lead |= 1u << S;
  dut->ev_l_cq00h = control == "no-ev-lead" ? 0 : lead;
  // The next edge's arrivals, in arrival order: their lead cycle is this
  // drive.
  static const std::vector<Core::RxArrival> none;
  const auto &arr = nx ? nx->log.arr : none;
  if (arr.size() > E) { fail("more arrivals than ports", 0, unsigned(arr.size()), E); return; }
  const uint32_t nfl = nx ? nx->fl : 0;
  dut->arv_v_cq01h = 0;
  unsigned cur_warp[E] = {}, cur_ep[E] = {};
  for (unsigned k = 0; k != arr.size(); ++k) {
    const auto &a = arr[k];
    unsigned ep = a.fetch_epoch;
    if (control == "keep-stale" && !a.kept) {
      // The drop's warp's live epoch, so the RTL keeps what the model dropped.
      for (unsigned s = 0; s != S; ++s)
        if (nx->sv[s] && nx->sw[s] == a.warp) ep = nx->se[s];
    }
    if (control == "no-adv-bypass")
      // The bypassed compare made to decide as one without it: an arrival
      // of an advancing slot has its slot's old epoch and the advanced one
      // swapped.
      for (unsigned s = 0; s != S; ++s)
        if ((dut->sv_cq02h >> s & 1u) && ((drv_adv | drv_adn) >> s & 1u) &&
            getField(dut->sw_cq02h, s * LW, LW) == a.warp) {
          const unsigned old = getField(dut->se_cq02h, s * EP, EP);
          const unsigned adv = (drv_adv >> s & 1u) && (drv_adn >> s & 1u) ? getField(dut->s2_cq02h, s * EP, EP)
                                                                         : getField(dut->sn_cq02h, s * EP, EP);
          if (ep == old) ep = adv;
          else if (ep == adv) ep = old;
        }
    cur_warp[k] = a.warp;
    cur_ep[k] = ep;
    dut->arv_v_cq01h |= 1u << k;
    setField(dut->arv_warp_cq01h, k * LW, LW, control == "late-lead" ? last_warp[k] : a.warp);
    setField(dut->arv_ep_cq01h, k * EP, EP, control == "late-lead" ? last_ep[k] : ep);
    if ((al_warps | rel_warps) >> a.warp & 1u) { ++same_drive; fail("an arrival led in its warp's allocation or release", a.warp, 0, 0); }
  }
  // row-early (OA 509 (3c)): an arrival of a warp allocated in this drive,
  // on a free port, so u_keep reads its slot's row a cycle before the
  // allocation writes it; ooe_decrx's keep_row_settled must name it.
  if (control == "row-early" && !e.log.alloc.empty() && arr.size() < E) {
    const unsigned k = unsigned(arr.size());
    dut->arv_v_cq01h |= 1u << k;
    setField(dut->arv_warp_cq01h, k * LW, LW, e.log.alloc.front().second);
    setField(dut->arv_ep_cq01h, k * EP, EP, 0);
  }
  for (unsigned k = 0; k != E; ++k) { last_warp[k] = cur_warp[k]; last_ep[k] = cur_ep[k]; }
  tick();
  // After the edge: the verdict, from the flops ooe_decq takes it from, with
  // the payload.
  for (unsigned k = 0; k != arr.size(); ++k) {
    const auto &a = arr[k];
    (a.kept ? kept : dropped) += 1;
    const bool v = dut->enq_v_cq02h >> k & 1u;
    if (a.kept && !v) { fail("a kept uop dropped", k, v, a.kept); continue; }
    if (v) {
      const unsigned g = getField(dut->enq_slot_cq02h, k * LS, LS);
      if (a.kept && g != unsigned(a.slot)) { fail("kept slot differs", k, g, unsigned(a.slot)); continue; }
      const bool gfl = nfl >> g & 1u;
      // A demotion's flush holds its slot's uops for the walk (AR 395, OA
      // 451): when the event that flushes the slot opens its walk, ooe_decq
      // reads the walk bit (wo_o, set at the same edge its late flush
      // lands) and holds the slot's uops, so a uop kept in that flush's
      // cycle is held, not dropped. ooe_decq's walk is to be built (#71).
      const bool opens = nx && (nx->log.wopen >> g & 1u);
      if (a.kept && gfl && opens) ++walk_held;
      else if (a.kept && gfl) { ++right_path; fail("a right-path uop dropped by ooe_decq's late flush", k, g, a.warp); }
      else if (!a.kept && gfl) ++held_flush;
      else if (!a.kept) fail("a dropped uop kept, its slot not flushed", k, g, a.warp);
    }
  }
  arrivals += arr.size();
  for (unsigned k = unsigned(arr.size()); k != E; ++k)
    if (dut->enq_v_cq02h >> k & 1u) fail("an idle port kept", k, 1, 0);
  // After the edge: the slots as the model left them.
  for (unsigned s = 0; s != S; ++s) {
    const bool v = dut->sv_cq02h >> s & 1u;
    if (v != e.sv[s]) { fail("slot valid differs", s, v, e.sv[s]); continue; }
    if (!v) continue;
    const unsigned w = getField(dut->sw_cq02h, s * LW, LW);
    if (w != e.sw[s]) { fail("slot warp differs", s, w, e.sw[s]); continue; }
    const unsigned ep = getField(dut->se_cq02h, s * EP, EP);
    if (ep != e.se[s]) fail("slot epoch differs", s, ep, e.se[s]);
    const unsigned sn = getField(dut->sn_cq02h, s * EP, EP);
    if (sn != ((e.se[s] + 1) & ((1u << EP) - 1))) fail("slot next epoch differs", s, sn, (e.se[s] + 1) & 7u);
    const unsigned s2 = getField(dut->s2_cq02h, s * EP, EP);
    if (s2 != ((e.se[s] + 2) & ((1u << EP) - 1))) fail("slot second epoch differs", s, s2, (e.se[s] + 2) & 7u);
    const bool wo = dut->wo_cq02h >> s & 1u;
    if (wo != e.wo[s]) { fail("slot walk differs", s, wo, e.wo[s]); continue; }
    if (wo) {
      walks_open += 1;
      const unsigned wep = getField(dut->wep_cq02h, s * EP, EP);
      if (wep != e.wep[s]) fail("slot walk epoch differs", s, wep, e.wep[s]);
    }
  }
}

void resetDut() {
  dut->ev_l_cq00h = 0;
  dut->adv_cq01h = 0;
  dut->adn_cq01h = 0;
  dut->wo_cq01h = 0;
  dut->rel_cq01h = 0;
  dut->al_v_cq01h = 0;
  dut->arv_v_cq01h = 0;
  dut->ooe_rst_r00h = 1;
  tick();
  tick();
  dut->ooe_rst_r00h = 0;
  tick();
}

// After each core cycle (post): its events and the slots they left.
// Before the next (pre): the arrivals that followed it, which complete the
// edge. A core's last cycle (the random tests' frees) has no pre hook after
// it, so the next core's first pre hook drives it.
Edge cur;
bool have_cur = false;

void push(Edge &&e) {
  if (have_pend) drive(pend, &e, evLeads(e));
  pend = std::move(e);
  have_pend = true;
}

void post(const Core &c) {
  if (c.serial() != current) {
    // A core whose first cycle the pre hook did not see.
    fail("a core with no pre hook", 0, 0, 0);
    return;
  }
  cur = Edge();
  cur.log = c.rxLog();
  cur.fl = c.decqFlushed();
  for (unsigned w = 0; w != NW; ++w) {
    const int s = c.slotOfWarp(w);
    if (s < 0) continue;
    cur.sv[s] = true;
    cur.sw[s] = w;
    cur.se[s] = c.epoch(w);
    cur.wo[s] = c.walkOpen(unsigned(s));
    cur.wep[s] = c.walkEpoch(unsigned(s));
  }
  have_cur = true;
}

void pre(const Core &c) {
  if (c.serial() != current) {
    if (have_cur) { push(std::move(cur)); have_cur = false; }
    if (have_pend) { drive(pend, nullptr, 0); have_pend = false; }
    current = c.serial();
    ++cores;
    late_adv = late_adn = late_wo = 0;
    for (unsigned k = 0; k != E; ++k) last_warp[k] = last_ep[k] = 0;
    resetDut();
    // A null edge ahead of the core's first cycle carries the lead of its
    // launches.
    pend = Edge();
    have_pend = true;
    return;
  }
  if (!have_cur) return;
  cur.log.arr = c.rxLog().arr;   // the arrivals after the cycle
  push(std::move(cur));
  have_cur = false;
}

void flushLast() {
  if (have_cur) { push(std::move(cur)); have_cur = false; }
  if (have_pend) { drive(pend, nullptr, 0); have_pend = false; }
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("DECRX_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_decrx_tb>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  const int model_fails = cg.on() ? cg.run(seeds, pre, post) : ooeTestScenario("rx", seeds, 0, pre, post, nullptr);
  flushLast();
  cg.close();
  dut->final();
  std::printf("decrx_tb control=%s seeds=%u cores=%llu cycles=%llu arrivals=%llu kept=%llu dropped=%llu "
              "(no entry, no credit) advances=%llu (doubles=%llu) releases=%llu allocations=%llu (of a warp released beside it=%llu) flushes=%llu same-drive=%llu "
              "walk-slot-cycles=%llu walk-held=%llu order-fails=%llu flush-dropped=%llu right-path-dropped=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, arrivals, kept, dropped, advs, doubles, rels,
              allocs, reloc, flushes, same_drive, walks_open, (unsigned long long)walk_held, order_fails, (unsigned long long)held_flush, (unsigned long long)right_path, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
