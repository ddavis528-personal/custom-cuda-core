//===-- mshr_tb.cpp - dcu_mshr bench: one bank's miss buffers ---------------===//
//
// Drives one bank's dcu_mshr (BK = MSHR_BK, the build's -GBK) as its
// neighbours do: dcu_cap's lookups (the lead at H+2 with its set index,
// whose low bits are the bank; the payload at D1; other banks' lookups and
// dropped ones in other slots beside this bank's one live lookup, MA-27),
// dcu_bctl's lookup at D2 (dv, its slot) with dcu_btag's hit (a miss is
// dv && !hit), dcu_mpick's retry grants (any bank's lead; this bank's
// retry, its valid and payload, a cycle on) and MLC sends (it sends from
// this bank's offer at random, never the cycle after it sent from it, as
// dcu_mpick passes over the bank), dcu_fill's reads (the fill's valid a
// cycle ahead, then its req_id, any bank's) and frees (any bank's). The
// driver keeps the bank's waiters in order as dcu_bctl does, learning a
// presentation's outcome a cycle late, so a new miss behind one that just
// waited is presented and must wait too (bank order).
//
// Checks, every cycle, against a value model of the DCU model's miss
// buffers (sim/dcu/dcu_core.cpp, startMiss() and the MLC request in step())
// at the RTL's stages (rtl/dcu/dcu_mshr.sv's header): the outcome and wait
// cause at D3, the MLC offers (head valid and stamp, straight), the offered
// payload a cycle on, the entry a fill reads at F+1 (zero for another
// bank's) and its write request.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py). --control nomerge models a second miss to a line
// allocating its own entry (dcu-mshr-nomerge), --control order a new miss
// passing a waiting one (dcu-miss-reorder), and --control straight a miss
// offered straight while an older entry is unsent (DI-64); each must fail.
//===----------------------------------------------------------------------===//
#include "Vdcu_mshr.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../../sim/generated/ccv_params.h"   // the req_id widths

#include <algorithm>
#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <deque>
#include <memory>
#include <optional>
#include <random>
#include <string>
#include <vector>

#ifndef MSHR_BK
#define MSHR_BK 0
#endif

namespace {

constexpr unsigned kBk = MSHR_BK;
constexpr unsigned kSlots = 4, kBanks = 8, kNe = 16, kLd = 4;
constexpr unsigned kWl = 41;   // the line's PA bits
constexpr unsigned kWi = ccv::prov::kWReqMiuDcu;   // MIU req_id
constexpr unsigned kWle = kWi + 7;                  // list item {req_id, op, exclusive, std index}
constexpr unsigned kWs = 9;                         // lead set index
constexpr unsigned kStampMask = (1u << 10) - 1;
constexpr uint64_t kLineMask = (uint64_t(1) << kWl) - 1;

int g_argc;
char **g_argv;

// Bits of a Verilator port wider than 64 bits (or any, through words).
template <typename W> void setBits(W &w, unsigned lsb, unsigned width, uint64_t v) {
  for (unsigned i = 0; i < width; ++i) {
    const unsigned bit = lsb + i, word = bit / 32, off = bit % 32;
    const uint32_t m = uint32_t(1) << off;
    w[word] = (v >> i) & 1 ? (w[word] | m) : (w[word] & ~m);
  }
}
template <typename W> uint64_t getBits(const W &w, unsigned lsb, unsigned width) {
  uint64_t v = 0;
  for (unsigned i = 0; i < width; ++i) {
    const unsigned bit = lsb + i;
    v |= uint64_t((w[bit / 32] >> (bit % 32)) & 1) << i;
  }
  return v;
}
template <typename T> void setInt(T &w, unsigned lsb, unsigned width, uint64_t v) {
  const T m = T(((uint64_t(1) << width) - 1) << lsb);
  w = T((w & ~m) | ((T(v) << lsb) & m));
}

struct Req {   // a lookup's payload as dcu_mshr sees it
  uint64_t pa = 0;
  unsigned rid = 0, op = 0, fold = 0, sti = 0;
  bool excl = false;
  uint64_t seq = 0;   // arrival order (the driver's)
  uint32_t item() const { return (rid << 7) | (op << 5) | (unsigned(excl) << 4) | sti; }
};

struct Entry {
  bool v = false;
  unsigned st = 0, cnt = 0, coh = 0, fold = 0, stamp = 0;   // st: 0 unsent, 1 sent, 2 filled
  uint64_t pa = 0;
  std::array<uint32_t, kLd> list{};
};

struct Offer {
  unsigned id = 0, coh = 0;
  uint64_t pa = 0;
};

struct Out {
  bool ov = false, ow = false;
  unsigned why = 0;
  bool hv = false, sv = false;
  unsigned hstp = 0;
  std::optional<Offer> offer;   // what the bank offered (its payload a cycle on)
  std::optional<Entry> snap;    // the fill's read
};

unsigned cohOf(unsigned op) { return op == 0 ? 0 : 2; }   // the coh_op the bank sends

// The value model, a step a cycle from the state at the cycle's start.
struct Model {
  std::array<Entry, kNe> e{};
  std::deque<unsigned> unsent;   // allocation order (the age matrix)
  std::optional<unsigned> head, offPrev;
  bool owPrev = false;
  bool nomerge = false, noorder = false, straightCtl = false;
  // The offered id and the pick a cycle ahead (rtl/dcu/dcu_mshr.sv: DI-34 (2)).
  std::optional<unsigned> nf = 0u, pk = 1u;
  std::array<bool, kNe> ua{};
  // Coverage.
  unsigned merges = 0, allocs = 0, sends = 0, straight = 0, reads = 0, frees = 0, skipped = 0;
  std::array<unsigned, 4> waits{};

  // pq: the request at D2 (a retry or the bank's new miss). pres: a lead
  // at D2 (the RTL's next-id update runs then, or on a free). snt: last
  // cycle's offer was sent.
  Out step(const std::optional<Req> &pq, bool retry, bool pres, std::optional<unsigned> fill,
           std::optional<unsigned> freeId, bool snt, unsigned now) {
    Out o;
    std::array<bool, kNe> vStart{};
    for (unsigned i = 0; i < kNe; ++i) vStart[i] = e[i].v;
    if (snt) {
      const unsigned id = *offPrev;
      e[id].st = 1;
      unsent.erase(std::find(unsent.begin(), unsent.end(), id));
      ++sends;
    }
    o.hv = head.has_value();
    o.hstp = head ? e[*head].stamp : 0;
    bool mg = false, al = false;
    int mid = -1;
    unsigned aid = 0;
    if (pq) {
      bool any = false, filled = false, full = false;
      for (unsigned i = 0; i < kNe; ++i)
        if (e[i].v && e[i].pa == pq->pa && !nomerge) {
          any = true;
          mid = int(i);
          filled = filled || e[i].st == 2 || (fill && *fill == i);
          full = full || e[i].cnt == kLd;
        }
      const bool ord = !retry && owPrev && !noorder;
      mg = any && !filled && !full && !ord;
      al = !any && !ord && nf.has_value();
      if (al) aid = *nf;
      o.ov = true;
      o.ow = !mg && !al;
      o.why = ord ? 3 : filled ? 2 : full ? 1 : 0;
      if (o.ow) ++waits[o.why];
    }
    // The offers: the head picked last cycle, else this D2's allocation.
    o.sv = al && (!o.hv || straightCtl);
    if (o.hv) o.offer = Offer{*head, e[*head].coh, e[*head].pa};
    else if (al) o.offer = Offer{aid, cohOf(pq->op), pq->pa};
    offPrev = o.offer ? std::optional<unsigned>(o.offer->id) : std::nullopt;
    // The fill's read, from the cycle's start.
    if (fill) {
      o.snap = e[*fill];
      ++reads;
    }
    if (al) {
      Entry &x = e[aid];
      x = Entry{};
      x.v = true;
      x.cnt = 1;
      x.pa = pq->pa;
      x.fold = pq->fold;
      x.coh = cohOf(pq->op);
      x.stamp = now;
      x.list[0] = pq->item();
      unsent.push_back(aid);
      ++allocs;
      straight += o.sv;
    }
    if (mg) {
      Entry &x = e[unsigned(mid)];
      x.list[x.cnt++] = pq->item();
      ++merges;
    }
    // The next id: a request takes the offer; it, or an empty offer, takes
    // last cycle's pick; the new pick is the lowest free (or freed now)
    // entry less the offer, the pick and the offer taken last cycle.
    if (pres || freeId || (pk && !nf)) {
      std::optional<unsigned> nn = nf;
      std::array<bool, kNe> ua2{};
      if (pq && nf) ua2[*nf] = true;
      if (pq || !nf) {
        nn = pk;
        skipped += pq && !nn;
      }
      std::optional<unsigned> np;
      for (unsigned i = 0; i < kNe && !np; ++i)
        if (((!vStart[i] && !ua[i]) || (freeId && *freeId == i)) && !(nf && *nf == i) && !(pk && *pk == i))
          np = i;
      pk = np;
      nf = nn;
      ua = ua2;
    } else {
      ua = {};
    }
    if (fill) e[*fill].st = 2;
    if (freeId) {
      e[*freeId].v = false;
      e[*freeId].cnt = 0;
      ++frees;
    }
    head = unsent.empty() ? std::nullopt : std::optional<unsigned>(unsent.front());
    owPrev = o.ov && o.ow;
    return o;
  }
};

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vdcu_mshr> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;

  explicit Bench(const char *vcd_path) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vdcu_mshr>(ctx.get());
    if (vcd_path) {
      vcd = std::make_unique<VerilatedVcdC>();
      dut->trace(vcd.get(), 99);
      vcd->open(vcd_path);
    }
  }
  ~Bench() {
    if (vcd) vcd->close();
    dut->final();
  }
  void eval() {
    dut->eval();
    if (vcd) vcd->dump(t);
    t += 5;
  }
  void edge() {
    dut->dcu_core_clk = 0;
    eval();
    dut->dcu_core_clk = 1;
    eval();
    ++cyc;
  }
  void quiet() {
    dut->v_cc02h = 0;
    dut->drop_cc03h = 0;
    dut->dv_cc04h = 0;
    dut->hit_cc04h = 0;
    dut->rgv_cc03h = 0;
    dut->rv_cc04h = 0;
    dut->snt_cc05h = 0;
    dut->fv_cc03h = 0;
    dut->xv_cc04h = 0;
  }
  void reset() {
    dut->rst_n = 0;
    quiet();
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();   // the flopped reset releases a cycle on (RST-1)
  }
  void fail(const std::string &what) {
    if (++fails <= 20)
      std::fprintf(stderr, "mshr bank %u: cycle %llu: %s\n", kBk, (unsigned long long)cyc, what.c_str());
  }
  void expect(bool ok, const std::string &what) {
    ++checked;
    if (!ok) fail(what);
  }
};

struct Gen {
  std::mt19937_64 r;
  std::vector<uint64_t> lines;
  explicit Gen(uint64_t seed) : r(seed) {
    // This bank's lines (the low bits of a line are its bank), few enough
    // that misses merge and the 16 entries run out.
    for (unsigned i = 0; i < 32; ++i) lines.push_back(((r() & kLineMask) & ~uint64_t(kBanks - 1)) | kBk);
  }
  unsigned below(unsigned n) { return unsigned(r() % n); }
  unsigned otherBank() { return (kBk + 1 + below(kBanks - 1)) % kBanks; }
  bool spread = false;   // all lines alike (more lines than entries: none left)
  Req req() {
    Req q;
    // Else half from four hot lines (merges, full lists).
    q.pa = lines[!spread && below(2) ? below(4) : below(unsigned(lines.size()))];
    q.rid = below(1u << kWi);
    q.op = below(3);
    q.fold = below(16);
    q.excl = r() & 1;
    return q;
  }
  Req other() {   // another bank's lookup
    Req q = req();
    q.pa = (q.pa & ~uint64_t(kBanks - 1)) | otherBank();
    return q;
  }
};

unsigned miuCoh(unsigned op) { return op == 0 ? 0 : op == 1 ? 2 : 1; }   // MIU's coh_op

struct Look {   // a slot's lookup at D0 to D2
  Req q;
  bool mine = false, drop = false;
};

int run(const std::string &scenario, const char *vcd, const std::string &ctl, uint64_t seed) {
  Bench b(vcd);
  Gen g(seed);
  Model m;
  m.nomerge = ctl == "nomerge";
  m.noorder = ctl == "order";
  m.straightCtl = ctl == "straight";
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 60000 : scenario == "idle" ? 3000 : 4000;

  std::array<std::optional<Look>, kSlots> look1{}, look2{};   // at D1, at D2
  std::deque<Req> waiters;
  bool grantPrev = false;        // this bank granted last cycle: its retry is at D2 now
  bool inflight = false;         // a retry granted, its outcome unread
  bool pendNew = false, pendRetry = false;   // presented last cycle, outcome unread
  Req pendReq{};
  std::optional<Out> lastOut;
  std::optional<Offer> offerPrev;
  bool sentPrev = false;         // dcu_mpick sent from this bank last cycle
  std::optional<unsigned> fillLead, freeLead;
  bool otherLead = false;
  std::optional<Entry> snapPrev;
  std::array<bool, kNe> fillPend{}, freePend{};
  unsigned cov_retry_placed = 0, cov_ord = 0, cov_passed = 0, cov_other_fill = 0, cov_drop = 0,
           cov_head_sent = 0;
  uint64_t seqNo = 0;

  for (unsigned c = 0; c < n; ++c) {
    Vdcu_mshr &d = *b.dut;
    b.quiet();
    // Random runs go in stretches: as is; slow fills over all lines alike
    // (the entries run out); slow frees (a filled entry lingers, and new
    // misses to its line wait, and those behind them: bank order).
    const unsigned phase = rnd ? (c / 1500) % 3 : 0;
    g.spread = phase == 1;
    const bool on = scenario == "idle"     ? false
                    : scenario == "medium" ? c % 3 == 0
                    : scenario == "high"   ? true
                                           : (c / 200) % 3 != 0;
    // D0: new lookups, at most one live one for this bank (MA-27), others
    // for other banks, and now and then a dropped one for this bank.
    std::array<std::optional<Look>, kSlots> look0{};
    // This bank's lookup in one slot on about a fifth of the cycles (a
    // third in the clock-gating scenarios): one bank of eight, its waiters
    // retried one at a time.
    const int mineSlot = on && g.below(rnd ? 5 : 3) == 0 ? int(g.below(kSlots)) : -1;
    for (unsigned s = 0; s < kSlots; ++s) {
      if (int(s) != mineSlot && (!on || g.below(10) >= (rnd ? 6u : 8u))) continue;
      Look l;
      if (int(s) == mineSlot) {
        l.q = g.req();
        // Now and then a line held by a filled entry: a new miss that waits
        // while no waiter is queued, and the miss behind it (bank order).
        if (rnd && g.below(4) == 0) {
          std::vector<uint64_t> fl;
          for (const Entry &x : m.e)
            if (x.v && x.st == 2) fl.push_back(x.pa);
          if (!fl.empty()) l.q.pa = fl[g.below(unsigned(fl.size()))];
        }
        l.mine = true;
      } else if (rnd && g.below(8) == 0) {
        l.q = g.req();
        l.mine = true;
        l.drop = true;   // dropped at D1: not looked up
      } else {
        l.q = g.other();
      }
      look0[s] = l;
      d.v_cc02h |= 1u << s;
      setInt(d.lsi_cc02h, s * kWs, kWs, (g.below(64) << 3) | (l.q.pa & (kBanks - 1)));
    }
    if (rnd)   // noise on the set index of an idle slot
      for (unsigned s = 0; s < kSlots; ++s)
        if (!look0[s]) setInt(d.lsi_cc02h, s * kWs, kWs, g.below(512));
    for (unsigned s = 0; s < kSlots; ++s) {
      const Req q = look1[s] ? look1[s]->q : rnd ? g.req() : Req{};
      setInt(d.rid_cc03h, s * kWi, kWi, q.rid);
      setBits(d.pa_cc03h, s * kWl, kWl, q.pa);
      setInt(d.fold_cc03h, s * 4, 4, q.fold);
      setInt(d.coh_cc03h, s * 4, 4, miuCoh(q.op));
      setInt(d.excl_cc03h, s, 1, q.excl);
      if (look1[s] && look1[s]->drop) {
        d.drop_cc03h |= 1u << s;
        ++cov_drop;
      }
    }
    // D2: the retry granted last cycle, else a new miss.
    std::optional<Req> pq;
    bool isNew = false;
    const bool retryNow = grantPrev;
    if (retryNow) {
      pq = waiters.front();
      d.rv_cc04h = 1;
    }
    const Req rp = retryNow ? waiters.front() : rnd ? g.req() : Req{};
    d.rpa_cc04h = rp.pa;
    d.rrid_cc04h = rp.rid;
    d.rop_cc04h = rp.op;
    d.rexcl_cc04h = rp.excl;
    d.rfold_cc04h = rp.fold;
    d.rsti_cc04h = 0;
    d.hit_cc04h = rnd ? g.below(2) : 0;   // noise when no lookup
    d.mslot_cc04h = rnd ? g.below(4) : 0;
    for (unsigned s = 0; s < kSlots; ++s) {
      if (!look2[s] || !look2[s]->mine || look2[s]->drop) continue;
      if (g.below(10) < 4) {   // a hit: presented with its hit, or held behind a waiter
        if (!retryNow && waiters.empty() && !pendRetry && !inflight) {
          d.dv_cc04h = 1;
          d.hit_cc04h = 1;
          d.mslot_cc04h = s;
        }
        continue;
      }
      Req q = look2[s]->q;
      q.seq = ++seqNo;
      if (retryNow || !waiters.empty() || pendRetry || inflight) {
        waiters.push_back(q);   // dcu_bctl holds it behind the bank's waiters
        continue;
      }
      pq = q;
      isNew = true;
      d.dv_cc04h = 1;
      d.hit_cc04h = 0;
      d.mslot_cc04h = s;
    }
    bool pres = retryNow;
    for (unsigned s = 0; s < kSlots; ++s) pres = pres || (look2[s] && look2[s]->mine);
    // dcu_mpick's grant (the retry's lead): this bank's oldest waiter, or
    // another bank's.
    bool grant = false;
    if (!waiters.empty() && !inflight && !grantPrev && !pendRetry && g.below(4) != 0) {
      grant = true;
      d.rgv_cc03h = 1;
      d.rgb_cc03h = kBk;
    } else if (rnd && g.below(3) == 0) {
      d.rgv_cc03h = 1;
      d.rgb_cc03h = g.otherBank();
    } else {
      d.rgb_cc03h = rnd ? g.below(kBanks) : 0;
    }
    // A fill's lead (its read next cycle; this bank's sent entry or another
    // bank's id) and a free (likewise).
    std::optional<unsigned> fillNow = fillLead, freeNow = freeLead;
    const bool otherNow = otherLead;
    otherLead = false;
    fillLead.reset();
    freeLead.reset();
    if (fillNow) d.frid_cc04h = (kBk << 4) | *fillNow;
    else if (otherNow) d.frid_cc04h = (g.otherBank() << 4) | g.below(kNe);
    else if (rnd) d.frid_cc04h = g.below(128);
    const unsigned fillRate = phase == 1 ? 1 : 8;
    const unsigned fillDen = phase == 1 ? 20 : 20;
    if (g.below(fillDen) < fillRate) {
      std::vector<unsigned> c2;
      for (unsigned i = 0; i < kNe; ++i)
        if (m.e[i].v && m.e[i].st == 1 && !fillPend[i] && !(fillNow && *fillNow == i)) c2.push_back(i);
      if (!c2.empty()) {
        fillLead = c2[g.below(unsigned(c2.size()))];
        fillPend[*fillLead] = true;
        d.fv_cc03h = 1;
      }
    }
    if (!fillLead && rnd && g.below(6) == 0) {   // another bank's fill: read next cycle, not here
      d.fv_cc03h = 1;
      otherLead = true;
    }
    if (g.below(10) < (phase == 2 ? 1u : 4u)) {
      std::vector<unsigned> c2;
      for (unsigned i = 0; i < kNe; ++i)
        if (m.e[i].v && m.e[i].st == 2 && !freePend[i]) c2.push_back(i);
      if (!c2.empty()) {
        freeLead = c2[g.below(unsigned(c2.size()))];
        freePend[*freeLead] = true;
        d.xv_cc04h = 1;
        d.xid_cc04h = (kBk << 4) | *freeLead;
      }
    }
    if (!freeLead) {
      if (rnd && g.below(4) == 0) {   // another bank's free
        d.xv_cc04h = 1;
        d.xid_cc04h = (g.otherBank() << 4) | g.below(kNe);
      } else {
        d.xid_cc04h = rnd ? g.below(128) : 0;
      }
    }
    d.snt_cc05h = sentPrev;

    // The model's cycle; the offers and last cycle's offered payload before
    // the edge; then the edge and the flopped outputs.
    const Out o = m.step(pq, retryNow, pres, fillNow, freeNow, sentPrev, c & kStampMask);
    if (fillNow) fillPend[*fillNow] = false;
    if (freeNow) freePend[*freeNow] = false;
    b.eval();
    b.expect(bool(d.hv_cc05h) == o.hv, "head offer valid");
    if (o.hv) b.expect(d.hstp_cc05h == o.hstp, "head offer stamp");
    b.expect(bool(d.sv_cc05h) == o.sv, o.sv ? "should offer straight" : "should not offer straight");
    if (offerPrev) {
      b.expect(d.pid_cc05h == offerPrev->id, "offered payload: entry");
      b.expect(uint64_t(d.ppa_cc05h) == offerPrev->pa, "offered payload: line");
      b.expect(d.pcoh_cc05h == offerPrev->coh, "offered payload: coh_op");
    }
    // dcu_mpick: it sends from this bank's offer, at random, but never the
    // cycle after a send from it (passed over: the head may be stale).
    const bool offered = o.hv || o.sv;
    if (offered && sentPrev) ++cov_passed;
    const bool send = offered && !sentPrev && (rnd ? g.below(3) != 0 : true);
    cov_head_sent += send && o.hv;
    if (!ctl.empty() && b.fails) break;
    b.edge();
    b.expect(bool(d.ov_cc05h) == o.ov, "outcome valid");
    if (o.ov) {
      b.expect(bool(d.owait_cc05h) == o.ow, o.ow ? "should wait" : "should place");
      if (o.ow) b.expect(d.owhy_cc05h == o.why, "wait cause");
    }
    // The fill's read (zero for another bank's) and its write request.
    b.expect(bool(d.flv_cc05h) == o.snap.has_value(), "fill write lead");
    if (o.snap) b.expect(d.fbk_cc05h == (1u << kBk), "fill write bank");
    if (snapPrev) {
      b.expect(uint64_t(d.fwpa_cc06h) == snapPrev->pa, "fill write: line");
      b.expect(d.fwfold_cc06h == snapPrev->fold, "fill write: fold");
    }
    snapPrev = o.snap;
    if (o.snap) {
      const Entry &x = *o.snap;
      b.expect(uint64_t(d.fpa_cc05h) == x.pa, "fill read: line");
      b.expect(d.ffold_cc05h == x.fold, "fill read: fold");
      b.expect(d.fcoh_cc05h == x.coh, "fill read: coh_op");
      b.expect(d.fcnt_cc05h == x.cnt, "fill read: count");
      for (unsigned k = 0; k < x.cnt; ++k)
        b.expect(((d.flist_cc05h >> (kWle * k)) & ((uint64_t(1) << kWle) - 1)) == x.list[k],
                 "fill read: list item " + std::to_string(k));
    } else if (otherNow) {   // another bank's fill: read as zeros here
      b.expect(uint64_t(d.fpa_cc05h) == 0 && d.fcnt_cc05h == 0 && d.fbk_cc05h == 0,
               "another bank's fill reads zero");
    }
    if (!ctl.empty() && b.fails) break;
    // The driver reads last cycle's outcome now (dcu_bctl's view a cycle
    // late): a placed retry leaves, a waiting new miss joins in order.
    if (lastOut) {
      if (pendRetry) {
        if (!lastOut->ow) {
          waiters.pop_front();
          ++cov_retry_placed;
        }
        inflight = false;
      } else if (pendNew && lastOut->ow) {
        auto at = waiters.begin();
        while (at != waiters.end() && at->seq < pendReq.seq) ++at;
        waiters.insert(at, pendReq);
        cov_ord += lastOut->why == 3;
      }
    }
    pendNew = isNew;
    pendRetry = retryNow;
    if (pq) pendReq = *pq;
    if (grant) inflight = true;
    grantPrev = grant;
    offerPrev = o.offer;
    sentPrev = send;
    if (otherNow) ++cov_other_fill;
    lastOut = o;
    look2 = look1;
    look1 = look0;
  }
  if (rnd && (!m.merges || !m.allocs || !m.straight || !cov_head_sent || !m.reads || !m.frees ||
              !m.waits[0] || !m.waits[1] || !m.waits[2] || !m.waits[3] || !cov_retry_placed ||
              !cov_passed || !cov_other_fill || !cov_drop || !m.skipped)) {
    std::fprintf(stderr,
                 "mshr bank %u: coverage: merges %u allocs %u straight %u head sends %u reads %u "
                 "frees %u waits %u/%u/%u/%u retries placed %u passed over %u other fills %u "
                 "drops %u ids skipped %u\n",
                 kBk, m.merges, m.allocs, m.straight, cov_head_sent, m.reads, m.frees, m.waits[0],
                 m.waits[1], m.waits[2], m.waits[3], cov_retry_placed, cov_passed, cov_other_fill,
                 cov_drop, m.skipped);
    if (ctl.empty()) ++b.fails;
  }
  const std::string tag = ctl.empty() ? ":" : " control " + ctl + ":";
  std::printf("mshr bank %u%s %s: %llu cycles, %u values checked, %u mismatches: %s\n", kBk, tag.c_str(),
              rnd ? "random" : scenario.c_str(), (unsigned long long)b.cyc, b.checked, b.fails,
              b.fails ? "FAIL" : "PASS");
  (void)cov_ord;
  return b.fails ? 1 : 0;
}

}  // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string scenario, ctl;
  const char *vcd = nullptr;
  uint64_t seed = 1;
  for (int i = 1; i + 1 < argc; ++i) {
    if (!std::strcmp(argv[i], "--control")) {
      ctl = argv[i + 1];
      if (ctl != "nomerge" && ctl != "order" && ctl != "straight") {
        std::fprintf(stderr, "mshr: unknown control %s\n", ctl.c_str());
        return 2;
      }
    }
    if (!std::strcmp(argv[i], "--seed")) seed = std::strtoull(argv[i + 1], nullptr, 0);
  }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "mshr: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl, seed);
}
