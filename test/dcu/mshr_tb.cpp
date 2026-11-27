//===-- mshr_tb.cpp - dcu_mshr bench: miss buffers and the request to MLC --===//
//
// Drives dcu_mshr as its neighbours do: dcu_cap's lookups (the valid at D0,
// the payload at D1), dcu_bctl's lookups at D2 (dv, one a bank, its slot
// naming the staged payload) with dcu_btag's hit (a miss is dv && !hit;
// noise on banks with none), and its retries of each bank's miss-wait waiters (a
// lead a cycle ahead, then the waiter's payload), dcu_fill's reads (the
// fill's valid a cycle ahead, then its req_id) and frees, and MLC's credits.
// The driver keeps each bank's waiters in order as dcu_bctl does, learning a
// presentation's outcome a cycle late, so a bank's new miss behind one that
// just waited is presented and must wait too (bank order).
//
// Checks, every cycle, against a value model of the DCU model's miss
// buffers (sim/dcu/dcu_core.cpp, missOrWait(), startMiss(), mlcReq()) at
// the RTL's stages (rtl/dcu/dcu_mshr.sv's header): each bank's outcome and
// wait cause at D3, ccv_dcu_mlc_req's valid at D3 and payload a cycle on,
// and the entry a fill reads at F+1.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py). --control nomerge models a second miss to a line
// allocating its own entry (dcu-mshr-nomerge), and --control order a new
// miss passing a waiting one of its bank (dcu-miss-reorder), and --control
// credit a send gate that ignores last cycle's send (MA's condition on the
// credit counted a cycle late), and --control retry a retry pick of the
// lowest offering bank, not the oldest (DI-35); each must fail.
//===----------------------------------------------------------------------===//
#include "Vdcu_mshr.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../../sim/generated/ccv_params.h"   // the req_id widths

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

namespace {

constexpr unsigned kSlots = 4, kBanks = 8, kNe = 16, kLd = 4, kPorts = kSlots + 1, kNf = kPorts,
                   kCr = 4;
constexpr unsigned kWl = 41;   // the line's PA bits
constexpr unsigned kWi = ccv::prov::kWReqMiuDcu;   // MIU req_id
constexpr unsigned kWle = kWi + 7;                  // list item {req_id, op, exclusive, std index}
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
template <typename T> void setInt(T &w, unsigned lsb, unsigned width, uint64_t v) {
  const T m = T(((uint64_t(1) << width) - 1) << lsb);
  w = T((w & ~m) | ((T(v) << lsb) & m));
}

struct Req {   // a lookup's payload as dcu_mshr sees it
  uint64_t pa = 0;
  unsigned rid = 0, op = 0, fold = 0, sti = 0;
  bool excl = false;
  uint64_t seq = 0;   // arrival order (the driver's)
  unsigned stamp = 0; // when it became its bank's head, or last waited again (DI-35)
  uint32_t item() const { return (rid << 7) | (op << 5) | (unsigned(excl) << 4) | sti; }
};

struct Entry {
  bool v = false;
  unsigned st = 0, cnt = 0, coh = 0, fold = 0;   // st: 0 unsent, 1 sent, 2 filled
  uint64_t pa = 0;
  std::array<uint32_t, kLd> list{};
};

struct Out {
  std::array<bool, kBanks> ov{}, ow{};
  std::array<unsigned, kBanks> why{};
  std::optional<unsigned> send;
  std::optional<Entry> snap;   // the fill's read
};

// The value model, a step a cycle from the state at the cycle's start.
struct Model {
  std::array<Entry, kNe> e{};
  std::deque<unsigned> fifo;
  int cr = kCr;
  bool sentPrev = false;   // last cycle's send (--control credit's stale count)
  bool crNeg = false;      // credits went negative (the RTL's mshr_credit_floor)
  unsigned crStalls = 0;   // a send held for credits (coverage)
  std::array<bool, kBanks> owPrev{};
  bool nomerge = false, noorder = false, stale = false;
  // Coverage.
  unsigned merges = 0, allocs = 0, straight = 0, queued = 0, reads = 0, frees = 0, skipped = 0;
  std::array<unsigned, 4> waits{};

  // Each port's offered id (rtl/dcu/dcu_mshr.sv: DI-34 (2)).
  std::array<std::optional<unsigned>, kPorts> nf = initialOffers();
  std::vector<unsigned> pk = offerOrder({3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13});
  std::array<bool, 16> ua{};

  // The RTL's offer order of the free ids (ascending): lowest, highest,
  // second lowest, second highest, third lowest, as many as there are.
  static std::array<std::optional<unsigned>, kPorts> initialOffers() {
    std::array<std::optional<unsigned>, kPorts> a;
    const std::vector<unsigned> o = offerOrder({0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15});
    for (unsigned p = 0; p < kPorts; ++p) a[p] = o[p];
    return a;
  }
  static std::vector<unsigned> offerOrder(const std::vector<unsigned> &av) {
    std::vector<unsigned> o;
    const size_t n = av.size();
    const size_t pick[5][2] = {{0, 0}, {1, 0}, {0, 1}, {1, 1}, {0, 2}};   // {from the top, index}
    for (size_t i = 0; i < kNf && i < n; ++i)
      o.push_back(pick[i][0] ? av[n - 1 - pick[i][1]] : av[pick[i][1]]);
    return o;
  }

  // pq: port 0 the retry, ports 1 to 4 the slots' new misses. pres: a lookup
  // at D2 or a retry (the RTL's next-id update runs then, or on a free).
  Out step(const std::array<std::optional<Req>, kPorts> &pq, bool pres, std::optional<unsigned> fill,
           std::optional<unsigned> freeId, bool credit) {
    Out o;
    std::array<bool, kNe> vStart{};
    for (unsigned i = 0; i < kNe; ++i) vStart[i] = e[i].v;
    std::array<bool, kPorts> mg{}, al{};
    std::array<int, kPorts> mid{};
    std::array<unsigned, kPorts> aid{};
    unsigned n = 0;
    for (unsigned p = 0; p < kPorts; ++p) {
      mid[p] = -1;
      if (!pq[p]) continue;
      ++n;
      const unsigned b = unsigned(pq[p]->pa & 7);
      bool any = false, filled = false, full = false;
      for (unsigned i = 0; i < kNe; ++i)
        if (e[i].v && e[i].pa == pq[p]->pa && !nomerge) {
          any = true;
          mid[p] = int(i);
          filled = filled || e[i].st == 2 || (fill && *fill == i);
          full = full || e[i].cnt == kLd;
        }
      const bool ord = p != 0 && owPrev[b] && !noorder;
      mg[p] = any && !filled && !full && !ord;
      al[p] = !any && !ord && nf[p].has_value();
      if (al[p]) aid[p] = *nf[p];
      o.ov[b] = true;
      o.ow[b] = !mg[p] && !al[p];
      o.why[b] = ord ? 3 : filled ? 2 : full ? 1 : 0;
      if (o.ow[b]) ++waits[o.why[b]];
    }
    const unsigned npq = n;
    // The send.
    const bool une = !fifo.empty();
    int sp = -1;
    for (unsigned p = 0; p < kPorts; ++p)
      if (al[p]) {
        sp = int(p);
        break;
      }
    // The gate sees the credits less this cycle's send: --control credit
    // reads the count before last cycle's send left it (the RTL's cr_q
    // without the subtraction of mvi_q), so it may send past zero.
    const int crg = cr + (stale && sentPrev ? 1 : 0);
    const bool str = sp >= 0 && !une && crg > 0;
    if (crg <= 0 && (une || sp >= 0)) ++crStalls;
    if (crg > 0 && (une || str)) o.send = une ? fifo.front() : aid[unsigned(sp)];
    // The fill's read, from the cycle's start.
    if (fill) {
      o.snap = e[*fill];
      ++reads;
    }
    // Writes.
    for (unsigned p = 0; p < kPorts; ++p) {
      if (al[p]) {
        Entry &x = e[aid[p]];
        x = Entry{};
        x.v = true;
        x.cnt = 1;
        x.pa = pq[p]->pa;
        x.fold = pq[p]->fold;
        x.coh = pq[p]->op == 0 ? 0 : 2;
        x.list[0] = pq[p]->item();
        ++allocs;
        if (!(str && unsigned(sp) == p)) {
          fifo.push_back(aid[p]);
          ++queued;
        } else {
          ++straight;
        }
      }
      if (mg[p]) {
        Entry &x = e[unsigned(mid[p])];
        x.list[x.cnt++] = pq[p]->item();
        ++merges;
      }
    }
    // The next ids: a requesting port's offer is taken; it, and a port with
    // none, takes last cycle's next pick, in port order; the new picks come
    // from the free (or freed now) entries less the offers, the picks and
    // the offers taken last cycle.
    bool holes = false;
    for (unsigned p = 0; p < kPorts; ++p) holes = holes || !nf[p];
    if (pres || freeId || (!pk.empty() && holes)) {
      std::array<bool, kNe> out{};
      for (unsigned p = 0; p < kPorts; ++p)
        if (nf[p]) out[*nf[p]] = true;
      for (unsigned id : pk) out[id] = true;
      std::vector<unsigned> av;
      for (unsigned i = 0; i < kNe; ++i)
        if (((!vStart[i] && !ua[i]) || (freeId && *freeId == i)) && !out[i]) av.push_back(i);
      std::array<std::optional<unsigned>, kPorts> nn = nf;
      ua = {};
      size_t j = 0;
      bool left = false;
      for (unsigned p = 0; p < kPorts; ++p) {
        if (pq[p] && nf[p]) ua[*nf[p]] = true;
        if (pq[p] || !nf[p]) nn[p] = j < pk.size() ? std::optional<unsigned>(pk[j++]) : std::nullopt;
        left = left || !nn[p];
      }
      skipped += npq > 0 && left;
      pk = offerOrder(av);
      nf = nn;
    } else {
      ua = {};
    }
    if (o.send) {
      if (une) fifo.pop_front();
      e[*o.send].st = 1;
    }
    if (fill) e[*fill].st = 2;
    if (freeId) {
      e[*freeId].v = false;
      e[*freeId].cnt = 0;
      ++frees;
    }
    cr = cr - (o.send ? 1 : 0) + (credit ? 1 : 0);
    if (cr < 0) crNeg = true;
    sentPrev = o.send.has_value();
    for (unsigned b = 0; b < kBanks; ++b) owPrev[b] = o.ov[b] && o.ow[b];
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
    dut->dv_cc04h = 0;
    dut->hit_cc04h = 0;
    dut->rov_cc02h = 0;
    dut->mcr_cc04h = 0;
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
      std::fprintf(stderr, "mshr: cycle %llu: %s\n", (unsigned long long)cyc, what.c_str());
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
    // Half the lines on banks 0 to 2, so a bank's misses come back to back
    // (bank order) as well as spread.
    for (unsigned i = 0; i < 40; ++i)
      lines.push_back(i < 20 ? ((r() & kLineMask) & ~uint64_t(7)) | (i % 3) : r() & kLineMask);
  }
  unsigned below(unsigned n) { return unsigned(r() % n); }
  Req req() {
    Req q;
    q.pa = lines[below(unsigned(lines.size()))];
    q.rid = below(1u << kWi);
    q.op = below(3);
    q.fold = below(16);
    q.excl = r() & 1;
    return q;
  }
};

unsigned cohOf(unsigned op) { return op == 0 ? 0 : op == 1 ? 2 : 1; }   // MIU's coh_op

int run(const std::string &scenario, const char *vcd, const std::string &ctl, uint64_t seed) {
  Bench b(vcd);
  Gen g(seed);
  Model m;
  m.nomerge = ctl == "nomerge";
  m.noorder = ctl == "order";
  m.stale = ctl == "credit";
  const bool lowpick = ctl == "retry";
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 60000 : scenario == "idle" ? 3000 : 4000;

  std::array<std::optional<Req>, kSlots> look1{}, look2{};   // at D1, at D2
  std::array<std::deque<Req>, kBanks> waiters;
  // The retry (DI-35): each bank (as dcu_bctl) offers its oldest waiter
  // from a flop; the RTL grants the oldest offer a cycle on and takes the
  // granted bank's payload a cycle later still, its D2. A bank learns of its
  // grant a cycle late (its offer that cycle stands, and is passed over) and
  // offers again once it has read its retry's outcome.
  std::array<bool, kBanks> offer{};                          // this cycle's offers (the banks' flops)
  std::array<bool, kBanks> inflight{};                       // granted, outcome unread
  std::optional<unsigned> pick1, pick2;                      // the grants of 1 and 2 cycles back
  std::optional<unsigned> retryNext;                         // the retry at D2 now
  std::array<bool, kBanks> pendNew{}, pendRetry{};           // presented last cycle, outcome unread
  unsigned cov_regrant = 0, cov_retry_race = 0;
  constexpr unsigned kStampMask = (1u << 10) - 1;
  const auto older = [&](unsigned a, unsigned b2) {          // a strictly older than b2 (mod 2^10)
    const unsigned dd = (b2 - a) & kStampMask;
    return dd != 0 && dd <= (kStampMask >> 1);
  };
  std::array<Req, kBanks> pendReq{};
  std::optional<Out> lastOut;
  std::optional<unsigned> sendPrev, fillLead, freeLead;
  std::optional<Entry> snapPrev;   // last cycle's fill read (its write payload now)
  bool creditPrev = false;
  std::vector<unsigned> credBack;                            // the cycles credits come back
  std::array<bool, kNe> fillPend{}, freePend{};
  unsigned cov_ord = 0, cov_retry_placed = 0;
  uint64_t seqNo = 0;

  for (unsigned c = 0; c < n; ++c) {
    Vdcu_mshr &d = *b.dut;
    b.quiet();
    const bool on = scenario == "idle"     ? false
                    : scenario == "medium" ? c % 3 == 0
                    : scenario == "high"   ? true
                                           : (c / 200) % 3 != 0;
    // D0: new lookups; D1: last cycle's payloads on the pins.
    std::array<std::optional<Req>, kSlots> look0{};
    for (unsigned s = 0; s < kSlots; ++s)
      if (on && g.below(10) < (rnd ? 6u : 8u)) {
        look0[s] = g.req();
        d.v_cc02h |= 1u << s;
      }
    for (unsigned s = 0; s < kSlots; ++s) {
      const Req q = look1[s] ? *look1[s] : rnd ? g.req() : Req{};   // noise when none (random runs)
      setInt(d.rid_cc03h, s * kWi, kWi, q.rid);
      setBits(d.pa_cc03h, s * kWl, kWl, q.pa);
      setInt(d.fold_cc03h, s * 4, 4, q.fold);
      setInt(d.coh_cc03h, s * 4, 4, cohOf(q.op));
      setInt(d.excl_cc03h, s, 1, q.excl);
    }
    // D2: retries whose leads went out last cycle, then new misses. The
    // driver sees waiters as of the outcomes it has read (a cycle late).
    std::array<std::optional<Req>, kBanks> rq{};
    std::array<bool, kBanks> isNew{};
    std::array<std::optional<Req>, kPorts> pq{};
    retryNext = pick2;
    if (retryNext) {
      const Req q = waiters[*retryNext].front();
      rq[*retryNext] = q;
      pq[0] = q;
    }
    // Each bank's offer (valid and its head's stamp) and its head's payload,
    // held in its flops (noise when it has none, in random runs).
    std::optional<unsigned> pick;
    for (unsigned bk = 0; bk < kBanks; ++bk) {
      const Req q = !waiters[bk].empty() ? waiters[bk].front() : rnd ? g.req() : Req{};
      if (offer[bk]) d.rov_cc02h |= 1u << bk;
      setBits(d.rstp_cc02h, bk * 10, 10, offer[bk] || rnd ? q.stamp & kStampMask : 0);
      setBits(d.rpa_cc03h, bk * kWl, kWl, q.pa);
      setInt(d.rrid_cc03h, bk * kWi, kWi, q.rid);
      setInt(d.rop_cc03h, bk * 2, 2, q.op);
      setInt(d.rexcl_cc03h, bk, 1, q.excl);
      setInt(d.rfold_cc03h, bk * 4, 4, q.fold);
      setInt(d.rsti_cc03h, bk * 4, 4, 0);
      // The oldest offer, ties to the lowest bank; last cycle's grant is
      // passed over.
      if (!offer[bk] || (pick1 && *pick1 == bk)) {
        if (offer[bk]) ++cov_regrant;
        continue;
      }
      b.expect(c - q.stamp < 512, "an offered stamp under 512 cycles old (DI-35)");
      if (!pick || (!lowpick && older(q.stamp & kStampMask, waiters[*pick].front().stamp & kStampMask))) pick = bk;
    }
    // dcu_btag's hit on every bank (noise where no lookup is presented).
    d.hit_cc04h = rnd ? unsigned(g.below(256)) : 0;
    for (unsigned s = 0; s < kSlots; ++s) {
      if (!look2[s]) continue;
      const unsigned bk0 = unsigned(look2[s]->pa & 7);
      if (g.below(10) < 4) {   // a hit: presented with its hit, or held behind a waiter
        if (!(d.dv_cc04h >> bk0 & 1) && !rq[bk0] && waiters[bk0].empty() && !pendRetry[bk0] &&
            !inflight[bk0]) {
          d.dv_cc04h |= 1u << bk0;
          d.hit_cc04h |= 1u << bk0;
          setInt(d.mslot_cc04h, bk0 * 2, 2, s);
        }
        continue;
      }
      Req q = *look2[s];
      q.seq = ++seqNo;
      const unsigned bk = unsigned(q.pa & 7);
      if (rq[bk] && isNew[bk]) continue;   // another slot's miss has the bank: this one hit
      if (rq[bk] || !waiters[bk].empty() || pendRetry[bk] || inflight[bk]) {
        waiters[bk].push_back(q);   // dcu_bctl holds it behind the bank's waiters
        waiters[bk].back().stamp = c;
        continue;
      }
      rq[bk] = q;
      pq[s + 1] = q;
      isNew[bk] = true;
      d.dv_cc04h |= 1u << bk;
      d.hit_cc04h &= ~(1u << bk);
      setInt(d.mslot_cc04h, bk * 2, 2, s);
    }
    bool pres = bool(pq[0]);
    for (unsigned s = 0; s < kSlots; ++s) pres = pres || bool(look2[s]);
    // A fill's lead (its read next cycle) and a free; MLC's credit.
    std::optional<unsigned> fillNow = fillLead, freeNow = freeLead;
    fillLead.reset();
    freeLead.reset();
    if (fillNow) d.frid_cc04h = *fillNow;
    if (g.below(10) < 4) {
      std::vector<unsigned> c2;
      for (unsigned i = 0; i < kNe; ++i)
        if (m.e[i].v && m.e[i].st == 1 && !fillPend[i] && !(fillNow && *fillNow == i)) c2.push_back(i);
      if (!c2.empty()) {
        fillLead = c2[g.below(unsigned(c2.size()))];
        fillPend[*fillLead] = true;
        d.fv_cc03h = 1;
      }
    }
    if (g.below(10) < 4) {
      std::vector<unsigned> c2;
      for (unsigned i = 0; i < kNe; ++i)
        if (m.e[i].v && m.e[i].st == 2 && !freePend[i]) c2.push_back(i);
      if (!c2.empty()) {
        freeLead = c2[g.below(unsigned(c2.size()))];
        freePend[*freeLead] = true;
        d.xv_cc04h = 1;
        d.xid_cc04h = *freeLead;
      }
    } else {
      d.xid_cc04h = rnd ? g.below(kNe) : 0;   // noise (random runs; a clock-gating
                                                 // scenario's inputs rest when idle)
    }
    bool credit = false;
    for (size_t i = 0; i < credBack.size(); ++i)
      if (credBack[i] <= c) {
        credBack.erase(credBack.begin() + long(i));
        credit = true;
        break;
      }
    d.mcr_cc04h = credit;

    // The model's cycle, then the edge, then the checks.
    std::optional<unsigned> freeApply = freeNow;   // a free lands a cycle after its pin
    const Out o = m.step(pq, pres, fillNow, freeApply, creditPrev);
    b.expect(!m.crNeg, "credits never negative (reference)");
    if (fillNow) fillPend[*fillNow] = false;
    if (freeApply) freePend[*freeApply] = false;
    creditPrev = credit;
    b.edge();
    b.expect(bool(d.rgv_cc03h) == bool(pick), "retry grant valid");
    if (pick) b.expect(d.rgb_cc03h == *pick, "retry grant bank");
    for (unsigned bk = 0; bk < kBanks; ++bk) {
      const bool ov = (d.ov_cc05h >> bk) & 1, ow = (d.owait_cc05h >> bk) & 1;
      b.expect(ov == o.ov[bk], "bank " + std::to_string(bk) + " outcome valid");
      if (o.ov[bk]) {
        b.expect(ow == o.ow[bk], "bank " + std::to_string(bk) + (o.ow[bk] ? " should wait" : " should place"));
        if (o.ow[bk])
          b.expect(((d.owhy_cc05h >> (2 * bk)) & 3) == o.why[bk], "bank " + std::to_string(bk) + " wait cause");
      }
    }
    b.expect(bool(d.mv_cc05h) == bool(o.send), "request valid");
    if (sendPrev) {
      const Entry &x = m.e[*sendPrev];
      b.expect(d.mrid_cc06h == *sendPrev, "request req_id");
      b.expect(d.mpa_cc06h == (x.pa << 7), "request PA");
      b.expect(d.mcoh_cc06h == x.coh, "request coh_op");
      b.expect(d.mcid_cc06h == 0, "request core_id");
    }
    // The fill's bank write request (DI-39): the lead at F+1, its line and
    // fold a cycle on.
    b.expect(bool(d.flv_cc05h) == o.snap.has_value(), "fill write lead");
    if (o.snap) b.expect(d.fbk_cc05h == (1u << (o.snap->pa & (kBanks - 1))), "fill write bank");
    if (snapPrev) {
      b.expect(d.fwpa_cc06h == snapPrev->pa, "fill write: line");
      b.expect(d.fwfold_cc06h == snapPrev->fold, "fill write: fold");
    }
    snapPrev = o.snap;
    if (o.snap) {
      const Entry &x = *o.snap;
      b.expect(d.fpa_cc05h == x.pa, "fill read: line");
      b.expect(d.ffold_cc05h == x.fold, "fill read: fold");
      b.expect(d.fcoh_cc05h == x.coh, "fill read: coh_op");
      b.expect(d.fcnt_cc05h == x.cnt, "fill read: count");
      for (unsigned k = 0; k < x.cnt; ++k)
        b.expect(((d.flist_cc05h >> (kWle * k)) & ((1u << kWle) - 1)) == x.list[k], "fill read: list item " + std::to_string(k));
    }
    // A control's model diverges, and its driving would then break the
    // RTL's input contract: stop at its first mismatch.
    if (!ctl.empty() && b.fails) break;
    sendPrev = o.send;
    if (o.send) credBack.push_back(c + 3 + g.below(8));
    // The driver reads last cycle's outcomes now (dcu_bctl's view a cycle
    // late), in bank order: a placed retry leaves, a waiting new miss joins.
    if (lastOut)
      for (unsigned bk = 0; bk < kBanks; ++bk) {
        if (pendRetry[bk]) {
          if (!lastOut->ow[bk]) {
            waiters[bk].pop_front();
            if (!waiters[bk].empty()) waiters[bk].front().stamp = c;   // the new head's (DI-35)
            ++cov_retry_placed;
          } else {
            waiters[bk].front().stamp = c;   // waits again: stamped anew (DI-35)
          }
          inflight[bk] = false;
        } else if (pendNew[bk] && lastOut->ow[bk]) {
          // It joins in arrival order: ahead of anything queued since.
          std::deque<Req> &w = waiters[bk];
          auto at = w.begin();
          while (at != w.end() && at->seq < pendReq[bk].seq) ++at;
          at = w.insert(at, pendReq[bk]);
          at->stamp = c;
          cov_ord += lastOut->why[bk] == 3;
        }
      }
    for (unsigned bk = 0; bk < kBanks; ++bk) {
      pendNew[bk] = isNew[bk];
      pendRetry[bk] = retryNext && *retryNext == bk;
      if (rq[bk]) pendReq[bk] = *rq[bk];
    }
    // The banks' offers for next cycle, from what each knows now: its grant
    // (the RTL's output this cycle) and the outcomes it has read.
    if (pick1) inflight[*pick1] = true;
    for (unsigned bk = 0; bk < kBanks; ++bk) {
      const bool was = offer[bk];
      offer[bk] = !waiters[bk].empty() && !inflight[bk] && (g.below(8) != 0 || !rnd);
      if (was && pick1 && *pick1 == bk && pick && *pick != bk) ++cov_retry_race;
    }
    pick2 = pick1;
    pick1 = pick;
    lastOut = o;
    look2 = look1;
    look1 = look0;
  }
  if (rnd && (!m.merges || !m.allocs || !m.straight || !m.queued || !m.reads || !m.frees ||
              !m.waits[0] || !m.waits[1] || !m.waits[2] || !m.waits[3] || !cov_retry_placed || !m.crStalls || !cov_regrant)) {
    std::fprintf(stderr,
                 "mshr: coverage: merges %u allocs %u straight %u queued %u reads %u frees %u "
                 "waits %u/%u/%u/%u retries placed %u credit stalls %u regrants passed over %u\n",
                 m.merges, m.allocs, m.straight, m.queued, m.reads, m.frees, m.waits[0], m.waits[1],
                 m.waits[2], m.waits[3], cov_retry_placed, m.crStalls, cov_regrant);
    if (ctl.empty()) ++b.fails;
  }
  const std::string tag = ctl.empty() ? ":" : " control " + ctl + ":";
  std::printf("mshr%s %s: %llu cycles, %u values checked, %u mismatches: %s\n", tag.c_str(),
              rnd ? "random" : scenario.c_str(), (unsigned long long)b.cyc, b.checked, b.fails,
              b.fails ? "FAIL" : "PASS");
  (void)cov_ord;
  (void)cov_retry_race;
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
      if (ctl != "nomerge" && ctl != "order" && ctl != "credit" && ctl != "retry") {
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
