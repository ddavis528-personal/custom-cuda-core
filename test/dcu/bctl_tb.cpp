//===-- bctl_tb.cpp - dcu_bctl bench: one bank's arbitration and predictor --===//
//
// Drives one bank (BANK 0 at the unit's size) as the block does: each slot's
// lead on the channel's wires in H+1 (at most one naming the bank a cycle,
// MIU's A2; the others name other banks), its set from its dcu_cap in D0, its
// payload (req_id, pa_fold, drop) in D1, and dcu_btag's tag result in D2
// (noise on every wire that carries no lookup). MIU's entry credits bound
// the lookups in the bank to the queue's depth: a lead spends one, ent_ret
// returns one, a drop is refunded by MIU. dcu_fix asks for accesses and
// holds each until fxg shows it.
//
// A value model of the bank (the DCU tab's slice 1, "Bank arbitration" and
// "LRU and the predictor", as the DCU model's schedule() and serveLook()
// state them) is checked every cycle: the SRAM's ce, address and we and
// fxg; the answer carry (av, req_id, slot, late); the misses (mv); ent_ret;
// and the PLRU victim of a set the bench names. The bench keeps the tags
// (which line each way holds) and the fold table it preloads through the
// write port; lines in a set share folds often, so lookups mispredict,
// fold-match miss and no-match miss.
//
// Slice 2 (DI-36): every lookup holds a queue entry, its payload (line,
// op, exclusive, fold) on D1's wires from the slots' dcu_cap flops. The
// bench plays dcu_mshr: each lookup presented at D2 (dv) that missed gets an
// outcome a cycle on (placed, or waiting with a cause; a miss behind this
// cycle's wait waits for bank order), and the bank's retry offer (rov, its
// stamp and payload, checked against the model's miss-wait FIFO) is granted
// a cycle on at random, its outcome two cycles after the grant. The credits
// follow the entries: back at a waiter's access, a granted hit's D2, or a
// placement.
//
// Random mode covers: every arbitration outcome (re-read, aged waiter,
// fix, new lookup, waiter), the bypass of an empty queue,
// the queue at its deepest (two credits short, held by the pipeline), drops
// freeing the cycle, no-match misses freeing it, two credits due in a
// cycle, mispredicts. --cg <idle|medium|high> <vcd> runs one clock-gating
// scenario (tools/check-cg.py). --control flat (the model puts the new
// lookup ahead of the re-read), --control nofree (a dropped access keeps
// its cycle), --control order (a miss presented past the bank's waiter) and
// --control unheld (the model never holds a fill's write, DI-37) and
// --control nomargin (the model answers a lookup whose fold row was read in a
// fill's write cycle or the next at its hit slot, DI-42) must fail.
//
// Slice 2 part 1's fills (DI-39): the bench plays dcu_mshr and dcu_fill, a
// fill's lead (flv, the bank one hot) and a cycle on its payload (the set,
// fold and buffer) for a line the set does not hold. The model picks the
// victim at the payload's cycle (the lowest invalid way, else the PLRU
// victim, else the lowest way not reserved), reserves it, touches it in the
// PLRU two cycles on (seen three on), and grants the write as the RTL's order has it: a held
// write (its access at F+8 or later, K = 4) after the mispredict re-read,
// an unheld one only when nothing else takes the cycle. At W the SRAM's
// address, we, wdv and wdb are checked, and the way takes the line (the
// bench's tags and the fold table).
//===----------------------------------------------------------------------===//
#include "Vdcu_bctl.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../../sim/generated/ccv_params.h"   // CCV_DCU_WAYPRED_BITS, the fold width

#include <algorithm>
#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <deque>
#include <map>
#include <memory>
#include <random>
#include <string>
#include <vector>

namespace {

constexpr unsigned kSlots = 4, kNB = 3, kWS = 9, kWays = 8, kWI = ccv::prov::kWReqMiuDcu, kWF = ccv::prov::kDcuWaypredBits, kWR = kWS - kNB;
constexpr unsigned kSets = 1u << kWR, kQD = 16, kAge = 16, kBank = 0, kWWY = 3, kLines = 24;

uint64_t g_seed = 0x5eed;
constexpr unsigned kWl = 41;

template <typename W> void setBits(W &w, unsigned lsb, unsigned width, uint64_t v) {
  for (unsigned i = 0; i < width; ++i) {
    const unsigned bit = lsb + i, word = bit / 32, off = bit % 32;
    const uint32_t m = uint32_t(1) << off;
    w[word] = (v >> i) & 1 ? (w[word] | m) : (w[word] & ~m);
  }
}
int g_argc;
char **g_argv;

struct Gen {
  std::mt19937_64 r;
  explicit Gen(uint64_t s) : r(s) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
  uint64_t bits() { return r(); }
};

/// A lookup, by the cycle of its D0.
struct Look {
  bool valid = false;
  unsigned slot = 0, set = 0, rid = 0, line = 0, fold = 0;
  bool drop = false, hit = false, won = false, anym = false;
  unsigned way = 0, pway = 0;   // indices (pway valid when anym)
  uint64_t pa = 0;              // the line, PA[47:7]
  unsigned coh = 0, op = 0;
  bool excl = false;
  bool dvp = false;             // presented to dcu_mshr at D2 (no waiter ahead)
  bool dvx = false;             // what the check expects (--control order: dvp, waiters ignored)
};

enum class GK { None, New, Wait, RR, Fix, Fill };
struct Grant {
  GK k = GK::None;
  unsigned addr = 0, rid = 0, slot = 0;
  bool w = false;
  int line = -1;   // a fill's
  bool chg = false; // a fill's: its fold-table write gates the row whatever it holds
};
/// A fill's write slot, from its victim pick.
struct FSlot {
  unsigned set = 0, way = 0, buf = 0, line = 0;
  uint64_t pick = 0, gone = ~uint64_t(0);   // pick: its payload's cycle (F+2)
  uint64_t wayAt = ~uint64_t(0);            // the cycle its way is known (its snapshot's + 1)
  bool yd = false;                          // held, it yielded to the port once (DI-46)
};
constexpr unsigned kNfw = 4, kKh = ccv::prov::kDcuFillAge;   // CCV_DCU_FILL_AGE (DI-37)
struct Ent {
  unsigned addr = 0, rid = 0, slot = 0;
  uint64_t d2 = 0;
};

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vdcu_bctl> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  bool flat = false, nofree = false, order = false, unheld = false, nomargin = false;
  bool sameSet = false;   // the random run's: fills biased to the sets others hold
  // The fold table's port (DI-46): the driver's credits, its entries (the
  // cycle each is in the RTL's queue, the entries ahead then), the payload
  // to drive next cycle, and the write a credit's return answers.
  static constexpr unsigned kPc = 4;   // the port's credits (its queue holds kPc - 2)
  unsigned pcr = kPc;
  bool flood = false;   // --flood: a lead whenever a credit allows
  struct PEnt { unsigned set = 0, way = 0; uint64_t at = 0; unsigned ahead = 0; };
  std::deque<PEnt> pq;
  bool pPay = false;
  PEnt pNext;
  uint64_t pWrote = ~uint64_t(0);
  unsigned pwMax = 0, phMax = 0, hwMax = 0, pqMax = 0;
  std::map<unsigned, uint64_t> heldAt;   // a slot's buf -> when it was held (DI-37's wait)
  std::map<std::string, unsigned> cov;

  // Slice 2: the miss-wait FIFO (oldest first), the head's stamp, the
  // offer, the retry's grants (this cycle, one and two back) and dcu_mshr's
  // outcomes, which the bench plays.
  struct Wt { uint64_t pa = 0; unsigned rid = 0, op = 0, fold = 0, cause = 0; bool excl = false; };
  std::deque<Wt> W;
  uint64_t hstamp = 0;
  bool rovM = false, g0 = false, g1 = false, g2 = false, rovPrev = false;
  bool stampK = false;
  uint64_t stampOff = 0;
  unsigned wmax = 0;
  struct Out { bool v = false, wait = false; unsigned why = 0; };
  std::map<uint64_t, Out> outAt;
  struct D3 { bool v = false, miss = false, pres = false; Wt w; } d3;
  uint64_t lastPa = 0, lastCoh = 0;
  uint32_t lastFold1 = 0, lastExcl = 0;
  static uint64_t paOf(unsigned line, unsigned set) {
    return (uint64_t((line * 0x9E3779B1u) & 0xFFFFFFFFu) << 9) | uint64_t(set) << kNB | kBank;
  }

  // The bench's tags and folds: per set, each way's line (-1 invalid).
  std::array<std::array<int, kWays>, kSets> tags{};
  static unsigned foldOf(unsigned line, unsigned set) { return (line * 7 + set) % 6; }   // < 2^kWF
  static_assert(kWF >= 3, "the bench's folds take 3 bits");

  // The model.
  std::vector<Look> L;   // by D0 cycle
  Grant G;               // this cycle's access
  std::deque<Ent> Q;
  unsigned owed = 0, qmax = 0;
  std::map<uint64_t, bool> wantEr;
  struct Ans { bool v = false; unsigned rid = 0, slot = 0; bool late = false; };
  std::map<uint64_t, Ans> wantAv;
  std::array<std::array<uint8_t, kWays - 1>, kSets> pl{};
  std::multimap<uint64_t, std::pair<unsigned, unsigned>> plTouch;   // visible-from cycle -> set, way (in order)
  std::multimap<uint64_t, std::pair<unsigned, unsigned>> plFill;    // a fill's touch: after the hits' that cycle
  // Fills: the write slots, the lead sent last cycle (its payload now).
  std::vector<FSlot> FS;
  bool fLead = false;
  FSlot fNext;
  uint32_t lastFset = 0, lastFfold = 0, lastFbuf = 0;
  // The fill's fold writes per set (the last two cycles that changed its
  // entry): a granted lookup whose D0 is one of them or a cycle after takes
  // the re-read (DI-42's margin).
  std::map<unsigned, std::pair<int64_t, int64_t>> ftw;

  // The credit loop and dcu_fix.
  unsigned out = 0;      // lookups in the bank (credits spent)
  uint64_t lastLsi = 0;  // the wires held still between lookups (--cg)
  uint32_t lastRid = 0, lastFold = 0;
  // dcu_fix: 0 idle, 1 the lead now, 2 the payload now, 3 pending (granted
  // from the cycle after the payload), then a gap.
  unsigned fxs = 0;
  bool fxw = false;
  unsigned fxa = 0, fxGap = 0;

  Bench(const char *vcd_path) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vdcu_bctl>(ctx.get());
    if (vcd_path) {
      vcd = std::make_unique<VerilatedVcdC>();
      dut->trace(vcd.get(), 99);
      vcd->open(vcd_path);
    }
    for (auto &s : tags) s.fill(-1);
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
  void chkPort(bool got, bool want) {
    ++checked;
    if (got != want) fail(std::string("fwcr: got ") + (got ? "1" : "0") + " want " + (want ? "1" : "0"));
  }
  void fail(const std::string &what) {
    if (++fails <= 20) std::fprintf(stderr, "bctl: cycle %llu: %s\n", (unsigned long long)cyc, what.c_str());
  }
  void quiet() {
    dut->rv_cc01h = 0;
    dut->fwe_cc00h = 0;
    dut->flv_cc03h = 0;
    dut->fxv_cc03h = 0;
    dut->ov_cc04h = 0;
    dut->owait_cc04h = 0;
    dut->rgv_cc04h = 0;
  }
  void reset() {
    dut->rst_n = 0;
    quiet();
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();
  }

  static void plTouchRef(std::array<uint8_t, kWays - 1> &b, unsigned way) {
    unsigned n = 0;
    for (unsigned half = kWays / 2, lo = 0; half; half /= 2) {
      const bool right = way >= lo + half;
      b[n] = !right;
      if (right) lo += half;
      n = 2 * n + 1 + right;
    }
  }
  static unsigned plVictimRef(const std::array<uint8_t, kWays - 1> &b) {
    unsigned n = 0, lo = 0;
    for (unsigned half = kWays / 2; half; half /= 2) {
      const bool right = b[n];
      if (right) lo += half;
      n = 2 * n + 1 + right;
    }
    return lo;
  }

  // Preload a set's way through the fold write port (and the bench's tags).
  void fill(unsigned set, unsigned way, int line) {
    tags[set][way] = line;
    dut->fwe_cc00h = 1;
    edge();
    dut->fwe_cc00h = 0;
    dut->fws_cc01h = set;
    dut->fwy_cc01h = way;
    dut->fwf_cc01h = foldOf(unsigned(line), set);
    edge();
  }

  /// One cycle: lead (D0 next cycle) and fix decided by the caller.
  void step(Gen &g, bool lead, unsigned rnd, bool hitBias, bool flead) {
    const uint64_t c = cyc;
    if (L.size() < c + 3) L.resize(c + 3);
    // W: the fill's way takes its line (the fold table's write lands at the
    // end of this cycle, so the next D0 sees it).
    if (G.k == GK::Fill) {
      const unsigned fs = G.addr >> kWWY, fw = G.addr & (kWays - 1);
      const int old = tags[fs][fw];
      // (the RTL decides a cycle ahead: a grant in the cycle the slot takes its
      // payload or its way counts as a change, its fields on the bypass)
      if (G.chg || old < 0 || foldOf(unsigned(old), fs) != foldOf(unsigned(G.line), fs)) {
        auto &e = ftw.try_emplace(fs, std::make_pair(int64_t(-9), int64_t(-9))).first->second;
        e = {int64_t(c), e.first};
      }
      tags[fs][fw] = G.line;
    }
    // The lead on the wires now names this bank at D0 = c + 1.
    unsigned rv = 0;
    uint32_t lsbw = 0;
    int ls = -1;
    if (lead && out < kQD) {
      ls = int(g.below(kSlots));
      Look &n = L[c + 1];
      n.valid = true;
      n.slot = unsigned(ls);
      n.set = g.below(kSets);
      n.rid = g.below(1u << kWI);
      // A resident line most of the time.
      const auto &ts = tags[n.set];
      int line = -1;
      if (g.below(10) < (hitBias ? 9u : 7u)) {
        const unsigned w0 = g.below(kWays);
        for (unsigned k = 0; k < kWays && line < 0; ++k) line = ts[(w0 + k) % kWays];
      }
      if (line < 0) line = int(g.below(kLines));
      n.line = unsigned(line);
      n.fold = foldOf(n.line, n.set);
      n.drop = rnd && g.below(16) == 0;
      n.pa = paOf(n.line, n.set);
      static const unsigned cohs[6] = {0, 0, 0, 2, 1, 3};
      n.coh = cohs[g.below(6)];
      n.op = n.coh == 0 ? 0 : n.coh == 2 ? 1 : 2;
      n.excl = g.below(2);
      n.hit = false;
      for (unsigned w = 0; w < kWays; ++w)
        if (ts[w] == line) { n.hit = true; n.way = w; }
      n.anym = false;
      for (unsigned w = 0; w < kWays && !n.anym; ++w)
        if (ts[w] >= 0 && foldOf(unsigned(ts[w]), n.set) == n.fold) { n.anym = true; n.pway = w; }
      ++out;
      rv |= 1u << ls;
      lsbw |= kBank << (ls * kNB);
    }
    // Other slots: other banks (noise).
    for (unsigned s = 0; s < kSlots; ++s)
      if (int(s) != ls && rnd && g.below(3) == 0) {
        rv |= 1u << s;
        lsbw |= (1 + g.below(7)) << (s * kNB);
      }
    dut->rv_cc01h = rv;
    dut->lsb_cc01h = lsbw;
    // D0's set; D1's payload; D2's tag result.
    const Look &l0 = L[c], &l1 = c >= 1 ? L[c - 1] : L[c], &l2 = c >= 2 ? L[c - 2] : L[c];
    uint64_t lsi = 0;
    for (unsigned s = 0; s < kSlots; ++s) {
      uint64_t v = rnd ? g.below(512) : lastLsi >> (s * kWS) & 511;
      if (l0.valid && l0.slot == s) v = uint64_t(l0.set) << kNB | kBank;
      lsi |= v << (s * kWS);
    }
    dut->lsi_cc02h = lsi;
    lastLsi = lsi;
    uint32_t rid = 0, fold = 0, drop = 0;
    for (unsigned s = 0; s < kSlots; ++s) {
      uint32_t r = rnd ? g.below(1u << kWI) : lastRid >> (s * kWI) & ((1u << kWI) - 1),
               f = rnd ? g.below(1u << kWF) : lastFold >> (s * kWF) & ((1u << kWF) - 1), d = rnd ? g.below(2) : 0;
      if (l0.valid && l0.slot == s) { r = l0.rid; f = l0.fold; d = l0.drop; }
      rid |= r << (s * kWI);
      fold |= f << (s * kWF);
      drop |= d << s;
    }
    dut->rid_cc02h = rid;
    dut->fold_cc02h = fold;
    dut->drop_cc02h = drop;
    lastRid = rid;
    lastFold = fold;
    // D1's payload from the slots' dcu_cap flops.
    {
      const bool l1v0 = c >= 1 && l1.valid;
      uint32_t f1 = 0, ex = 0;
      uint64_t co = 0;
      for (unsigned s = 0; s < kSlots; ++s) {
        uint64_t pa = rnd ? (g.bits() & ((uint64_t(1) << kWl) - 1)) : lastPa;
        uint32_t f = rnd ? g.below(1u << kWF) : lastFold1 >> (s * kWF) & ((1u << kWF) - 1);
        uint64_t ch = rnd ? g.below(16) : lastCoh >> (s * 4) & 15;
        uint32_t e = rnd ? g.below(2) : lastExcl >> s & 1;
        if (l1v0 && l1.slot == s) { pa = l1.pa; f = l1.fold; ch = l1.coh; e = l1.excl; }
        setBits(dut->pa_cc03h, s * kWl, kWl, pa);
        f1 |= f << (s * kWF);
        co |= ch << (s * 4);
        ex |= e << s;
      }
      dut->fold_cc03h = f1;
      dut->coh_cc03h = uint32_t(co);
      dut->excl_cc03h = ex;
      lastFold1 = f1;
      lastCoh = co;
      lastExcl = ex;
    }
    // dcu_mshr: this cycle's outcome for the bank, and the retry's grant
    // (the bank offered last cycle and was not granted then).
    Out o;
    {
      auto it = outAt.find(c);
      if (it != outAt.end()) { o = it->second; outAt.erase(it); }
      dut->ov_cc04h = o.v;
      dut->owait_cc04h = o.v ? o.wait : rnd ? g.below(2) : 0;
      dut->owhy_cc04h = o.v ? o.why : rnd ? g.below(4) : 0;
      g0 = rovPrev && !g1 && g.below(3) != 0;
      if (g0) {
        dut->rgv_cc04h = 1;
        dut->rgb_cc04h = kBank;
      } else {
        dut->rgv_cc04h = rnd && g.below(2);
        dut->rgb_cc04h = 1 + g.below(7);
      }
    }
    if (l2.valid && c >= 2) {
      dut->hit_cc04h = l2.hit;
      dut->way_cc04h = l2.hit ? 1u << l2.way : 0;
    } else if (rnd) {
      dut->hit_cc04h = g.below(2);
      dut->way_cc04h = 1u << g.below(8);
    }
    // dcu_fix: a request held until its access.
    if (fxs == 1) fxs = 2;
    else if (fxs == 2) fxs = 3;
    else if (fxs == 0 && fxGap) --fxGap;
    else if (fxs == 0 && rnd && g.below(40) == 0) {
      fxs = 1;
      fxw = g.below(2);
      fxa = g.below(512);
    }
    dut->fxv_cc03h = fxs == 1;
    dut->fxw_cc04h = fxs == 2 ? fxw : rnd ? g.below(2) : 0;
    dut->fxa_cc04h = fxs == 2 ? fxa : rnd ? g.below(512) : 0;
    // dcu_mshr's and dcu_fill's fill: the payload of last cycle's lead, and
    // a new lead (this bank's, when a slot and a line are free; another
    // bank's as noise).
    const bool fPay = fLead;
    if (fPay) {
      dut->fwset_cc03h = fNext.set;
      dut->fwfold_cc03h = foldOf(fNext.line, fNext.set);
      dut->fwb_cc03h = fNext.buf;
    } else {
      dut->fwset_cc03h = rnd ? g.below(kSets) : lastFset;
      dut->fwfold_cc03h = rnd ? g.below(1u << kWF) : lastFfold;
      dut->fwb_cc03h = rnd ? g.below(kNfw) : lastFbuf;
    }
    lastFset = dut->fwset_cc03h;
    lastFfold = dut->fwfold_cc03h;
    lastFbuf = dut->fwb_cc03h;
    fLead = false;
    FSlot fNew;
    unsigned pend = fPay, busyBuf = fPay ? 1u << fNext.buf : 0;
    for (const FSlot &f : FS)
      if (f.gone > c) ++pend, busyBuf |= 1u << f.buf;
    dut->flv_cc03h = 0;
    dut->fbk_cc03h = rnd ? g.below(256) & ~1u : 0;
    if (flead && pend < kNfw) {
      fNew.set = g.below(kSets);
      // In the random run, half the time a set another fill holds (the
      // reservations, DI-43); the clock-gating scenarios keep their stimulus.
      if (sameSet && !FS.empty() && g.below(2) == 0) fNew.set = FS[g.below(unsigned(FS.size()))].set;
      std::vector<unsigned> free;
      for (unsigned l = 0; l < kLines; ++l) {
        bool used = false;
        for (unsigned w = 0; w < kWays; ++w) used |= tags[fNew.set][w] == int(l);
        for (const FSlot &f : FS) used |= f.gone > c && f.set == fNew.set && f.line == l;
        if (fPay) used |= fNext.set == fNew.set && fNext.line == l;
        if (!used) free.push_back(l);
      }
      bool portSet = pPay && pNext.set == fNew.set;
      for (const PEnt &e : pq) portSet |= e.set == fNew.set;
      if (portSet) free.clear();   // the port's write would restore the way's old fold
      if (!free.empty()) {
        fNew.line = free[g.below(unsigned(free.size()))];
        while (busyBuf >> fNew.buf & 1) ++fNew.buf;
        fLead = true;
        dut->flv_cc03h = 1;
        dut->fbk_cc03h = 1u << kBank;
      }
    } else if (rnd && g.below(4) == 0) {
      dut->flv_cc03h = 1;   // another bank's
    }
    // The write port's other user (part 4's invalidations; DI-45): in the
    // random run, now and then a write of a valid way's own fold, in a set
    // no fill holds or is about to, so it changes nothing but takes the
    // port: its lead now, its payload next cycle, the write the cycle after.
    dut->fwe_cc00h = 0;
    if (pPay) {
      dut->fws_cc01h = pNext.set;
      dut->fwy_cc01h = pNext.way;
      dut->fwf_cc01h = foldOf(unsigned(tags[pNext.set][pNext.way]), pNext.set);
      pq.push_back(pNext);
      pqMax = std::max(pqMax, unsigned(pq.size()));
      pPay = false;
    }
    if (sameSet && pcr && (flood || g.below(16) == 0)) {
      const unsigned s = g.below(kSets), w = g.below(kWays);
      bool held = tags[s][w] < 0 || (fPay && fNext.set == s) || (fLead && fNew.set == s);
      for (const FSlot &f : FS) held |= f.set == s;
      if (!held) {
        pNext = PEnt{s, w, c + 2, unsigned(pq.size())};
        pPay = true;
        --pcr;
        dut->fwe_cc00h = 1;
        ++cov["port_write"];
      }
    }
    dut->eval();

    // ---- the model, this cycle ----
    // The port: the credit returned for last cycle's write; the head writes
    // now unless the fill does (W), and the entry's wait is checked.
    chkPort(dut->fwcr_cc03h, pWrote + 1 == c);
    if (dut->fwcr_cc03h) ++pcr;
    if (!pq.empty() && pq.front().at <= c && G.k != GK::Fill) {
      const PEnt &e = pq.front();
      const unsigned w = unsigned(c - e.at);
      pwMax = std::max(pwMax, w);
      if (w) ++cov["port_wait"];
      if (w > 4 + 2 * e.ahead)
        fail("model: a port write waited " + std::to_string(w) + " cycles, " + std::to_string(e.ahead) + " ahead");
      pq.pop_front();
      pWrote = c;
    }
    const bool pwn = !pq.empty() && pq.front().at <= c + 1;
    const bool l1v = c >= 1 && l1.valid, l2v = c >= 2 && l2.valid;
    unsigned wsa = 0;
    if (G.k == GK::New) wsa = l1.set << kWWY | (l1.anym ? l1.pway : 0);
    else if (G.k == GK::Fix) wsa = fxa;
    else wsa = G.addr;
    const bool realAcc = G.k == GK::New ? (!l1.drop && l1.anym) : G.k != GK::None;
    auto chk = [&](const char *what, uint64_t got, uint64_t want) {
      ++checked;
      if (got != want) fail(std::string(what) + ": got " + std::to_string(got) + " want " + std::to_string(want));
    };
    chk("ce", dut->ce_cc04h, realAcc);
    const bool busy = nofree ? G.k != GK::None : realAcc;
    if (realAcc) chk("sa", dut->sa_cc04h, wsa);
    chk("fxg", dut->fxg_cc04h, G.k == GK::Fix);
    chk("we", dut->we_cc04h, (G.k == GK::Fix && G.w) || G.k == GK::Fill);
    chk("wdv", dut->wdv_cc04h, G.k == GK::Fill);
    if (G.k == GK::Fill) chk("wdb", dut->wdb_cc04h, G.slot);
    {
      auto it = wantEr.find(c);
      chk("ent_ret", dut->ent_ret_cc04h, it != wantEr.end() && it->second);
      if (it != wantEr.end()) wantEr.erase(it);
      if (dut->ent_ret_cc04h) --out;
    }
    {
      auto it = wantAv.find(c);
      const Ans a = it != wantAv.end() ? it->second : Ans{};
      chk("av", dut->av_cc04h, a.v);
      if (a.v) {
        chk("arid", dut->arid_cc04h, a.rid);
        chk("aslot", dut->aslot_cc04h, a.slot);
        chk("alate", dut->alate_cc04h, a.late);
      }
      if (it != wantAv.end()) wantAv.erase(it);
      const bool d2 = c >= 2 && l2.valid && !l2.drop;
      chk("dv", dut->dv_cc04h, d2 && l2.dvx);
      if (d2 && l2.dvp) chk("mslot", dut->mslot_cc04h, l2.slot);
      chk("rov", dut->rov_cc04h, rovM);
      if (rovM) {
        const Wt &h = W.front();
        const uint64_t k = (dut->rstp_cc04h - hstamp) & 1023;
        if (!stampK) { stampK = true; stampOff = k; }
        chk("rstp", k, stampOff);
        if (c - hstamp >= 512) fail("bench: an offered stamp 512 cycles old");
        chk("rpa", dut->rpa_cc04h, h.pa);
        chk("rrid", dut->rrid_cc04h, h.rid);
        chk("rop", dut->rop_cc04h, h.op);
        chk("rexcl", dut->rexcl_cc04h, h.excl);
        chk("rfold", dut->rfold_cc04h, h.fold);
        chk("rsti", dut->rsti_cc04h, 0);
      }
      rovPrev = dut->rov_cc04h;
    }
    // PLRU: updates visible from this cycle, then the victim read now.
    for (auto it = plTouch.begin(); it != plTouch.end() && it->first <= c;) {
      plTouchRef(pl[it->second.first], it->second.second);
      it = plTouch.erase(it);
    }
    for (auto it = plFill.begin(); it != plFill.end() && it->first <= c;) {
      plTouchRef(pl[it->second.first], it->second.second);
      it = plFill.erase(it);
    }

    const bool wn2 = l2v && l2.won && !l2.drop, lq2 = l2v && !l2.won && !l2.drop;
    // DI-42: its D0 (c - 2) in the margin of a fill's fold write to its set.
    bool mg2 = false;
    if (l2v && !nomargin) {
      auto it = ftw.find(l2.set);
      if (it != ftw.end())
        for (int64_t e : {it->second.first, it->second.second})
          mg2 = mg2 || e == int64_t(c) - 2 || e == int64_t(c) - 3;
    }
    const bool mp = wn2 && l2.hit && (mg2 || l2.way != l2.pway);
    if (wn2 && l2.hit && mg2) ++cov["margin_reread"];
    const bool aged = !Q.empty() && c - Q.front().d2 >= kAge - 2;
    std::deque<Ent> cand = Q;
    const bool l2wait = lq2 && l2.hit;
    if (l2wait) cand.push_back(Ent{l2.set << kWWY | l2.way, l2.rid, l2.slot, c});
    Grant n;
    bool popped = false;
    const bool l0v = l0.valid;
    if (!busy) {
      // The fills' writes waiting now: the oldest held, else the oldest.
      int fh = -1, fa = -1;
      for (size_t k = 0; k != FS.size(); ++k) {
        const FSlot &f = FS[k];
        if (f.pick >= c || f.gone <= c) continue;
        if (fa < 0 || f.pick < FS[size_t(fa)].pick) fa = int(k);
        if (!unheld && c - f.pick >= kKh + 1 && (fh < 0 || f.pick < FS[size_t(fh)].pick)) fh = int(k);
      }
      // The head (the oldest) is a waiter once it has its way (DI-43).
      if (fa >= 0 && FS[size_t(fa)].wayAt > c) fa = -1, fh = -1;
      // The port holds an entry next cycle: an unheld fill yields to it, a
      // held one once (DI-46), leaving the cycle idle (the others wait behind
      // it); a mispredict's re-read goes first all the same.
      if (pwn && !(mp && !flat)) {
        if (fh >= 0 && !FS[size_t(fh)].yd) {
          FS[size_t(fh)].yd = true;
          fh = -2;
          ++cov["fill_yield"];
        } else if (fh < 0 && fa >= 0) {
          fa = -1;
          ++cov["fill_yield_unheld"];
        } else if (fh >= 0) {
          ++cov["fill_wins_port"];
        }
      }
      auto fillGrant = [&](int k, const char *bin) {
        FSlot &f = FS[size_t(k)];
        n = Grant{GK::Fill, f.set << kWWY | f.way, 0, f.buf, true, int(f.line),
                  c == f.pick + 1 || c == f.wayAt};
        f.gone = c + 1;
        if (c >= f.pick + kKh + 1) hwMax = std::max(hwMax, unsigned(c - (f.pick + kKh + 1)));
        ++cov[bin];
        if (c - f.pick > kKh + 2) ++cov["fill_late"];
      };
      if (mp && !flat) {
        n = Grant{GK::RR, l2.set << kWWY | l2.way, l2.rid, l2.slot, false};
        ++cov["reread"];
        if (fh >= 0) ++cov["fill_held_reread"];
      } else if (fh == -2) {
      } else if (fh >= 0) {
        if (l0v || aged || fxs == 3 || !cand.empty()) ++cov["fill_held_block"];
        fillGrant(fh, "fill_held");
      } else if (aged) {
        n = Grant{GK::Wait, Q.front().addr, Q.front().rid, Q.front().slot, false};
        Q.pop_front();
        ++cov["aged"];
      } else if (fxs == 3) {
        n = Grant{GK::Fix, 0, 0, 0, fxw};
        ++cov["fix"];
      } else if (l0v) {
        n = Grant{GK::New, 0, 0, 0, false};
        L[c].won = true;
        ++cov["new"];
      } else if (mp && flat) {
        n = Grant{GK::RR, l2.set << kWWY | l2.way, l2.rid, l2.slot, false};
      } else if (!cand.empty()) {
        n = Grant{GK::Wait, cand.front().addr, cand.front().rid, cand.front().slot, false};
        if (!Q.empty()) Q.pop_front();
        else popped = true, ++cov["bypass"];
        ++cov["waiter"];
      } else if (fa >= 0) {
        fillGrant(fa, "fill_unheld");
      }
    } else if (l0v && G.k == GK::New && l1.drop) ++cov["drop_busy"];
    if (G.k == GK::New && !realAcc && (n.k != GK::None)) ++cov[l1.drop ? "drop_freed" : "nomatch_freed"];
    if (l2wait && !popped) Q.push_back(Ent{l2.set << kWWY | l2.way, l2.rid, l2.slot, c});
    if (Q.size() > kQD) fail("model: the queue overflows its credits");
    if (Q.size() > qmax) qmax = unsigned(Q.size());
    if (Q.size() + 3 >= kQD) ++cov["queue_deep"];
    if (mp) ++cov["mispredict"];
    if (l2v && !l2.drop && !l2.hit && l2.anym) ++cov["fold_match_miss"];
    if (l2v && !l2.drop && !l2.hit && !l2.anym) ++cov["no_match_miss"];
    // Credits.
    // Slice 2's D3: the D2 lookup of last cycle leaves, or waits; the retry's
    // outcome; the head's stamp; the next offer; the D1 lookup presented?
    bool e2 = false;
    {
      const size_t n0 = W.size();
      if (d3.v && d3.miss) {
        if (d3.pres && !o.v) fail("bench: no outcome for a presented miss");
        if (d3.pres && o.v && !o.wait) {
          e2 = true;
          ++cov["placed"];
        } else {
          Wt w = d3.w;
          w.cause = d3.pres ? o.why : 3;
          W.push_back(w);
          ++cov[d3.pres ? (o.why == 3 ? "wait_order" : "wait_mshr") : "wait_held"];
        }
      }
      if (g2) {
        if (W.empty()) fail("model: a retry's outcome with no waiter");
        else if (!o.wait) {
          W.pop_front();
          e2 = true;
          ++cov["retry_placed"];
        } else {
          W.front().cause = o.why;
          ++cov["retry_again"];
        }
      }
      if (g2 || (d3.v && d3.miss && n0 == 0)) hstamp = c;
      if (W.size() > wmax) wmax = unsigned(W.size());
      if (W.size() >= 3) ++cov["waiters_deep"];
      rovM = !W.empty() && !g0 && !g1;
      if (g0) ++cov["retry_grant"];
      const bool held = (wn2 || lq2) && !l2.dvp && !l2.hit;
      if (l1v) {
        L[c - 1].dvp = !l1.drop && W.empty() && !held;
        L[c - 1].dvx = order ? !l1.drop : L[c - 1].dvp;
      }
      // dcu_mshr's outcome for a miss presented now, a cycle on (a miss
      // behind this cycle's wait waits too: its bank order).
      if ((wn2 || lq2) && l2.dvp && !l2.hit) {
        Out n;
        n.v = true;
        if (o.v && o.wait) n.wait = true, n.why = 3;
        else if (g.below(3) == 0) n.wait = true, n.why = g.below(3);
        if (outAt.count(c + 1)) fail("bench: two outcomes in a cycle");
        outAt[c + 1] = n;
      }
      if (g0) {
        Out n;
        n.v = true;
        if (g.below(3) == 0) n.wait = true, n.why = g.below(3);
        if (outAt.count(c + 2)) fail("bench: two outcomes in a cycle");
        outAt[c + 2] = n;
      }
      d3 = D3{};
      if (wn2 || lq2) {
        d3.v = true;
        d3.miss = !l2.hit;
        d3.pres = l2.dvp;
        d3.w = Wt{l2.pa, l2.rid, l2.op, l2.fold, 0, l2.excl};
      }
      g2 = g1;
      g1 = g0;
    }
    const bool e1 = G.k == GK::Wait || (wn2 && l2.hit);
    owed += e1 + e2;
    if (e1 && e2) ++cov["two_credits"];
    if (owed) {
      wantEr[c + 1] = true;
      --owed;
    }
    // Drops: MIU refunds the credit.
    if (l1v && l1.drop) --out;
    // Answers and misses.
    if (wn2 && l2.hit && !mp) wantAv[c + 1] = Ans{true, l2.rid, l2.slot, false};
    if (G.k == GK::Wait || G.k == GK::RR) wantAv[c + 2] = Ans{true, G.rid, G.slot, true};
    if ((wn2 || lq2) && l2.hit) plTouch.emplace(c + 2, std::make_pair(l2.set, l2.way));
    // The victim's snapshot (DI-43, MA rev 184): one a cycle, of a set outside
    // the fold table's margin: the oldest slot still without a way, else the
    // new payload (F+2), which otherwise waits without a way. Reserved: the
    // ways of the slots that have them, and of the write at W (held until the
    // snapshot sees it).
    auto inMargin = [&](unsigned set) {
      auto it = ftw.find(set);
      if (it == ftw.end()) return false;
      for (int64_t e : {it->second.first, it->second.second})
        if (e == int64_t(c) || e + 1 == int64_t(c)) return true;
      return false;
    };
    {
      int pk = -1;
      for (size_t k = 0; k != FS.size(); ++k) {
        const FSlot &x = FS[k];
        if (x.gone > c && x.pick < c && x.wayAt == ~uint64_t(0) && !inMargin(x.set) &&
            (pk < 0 || x.pick < FS[size_t(pk)].pick))
          pk = int(k);
      }
      if (fPay) {
        FSlot f = fNext;
        f.pick = c;
        FS.push_back(f);
        if (pk >= 0 || inMargin(f.set)) ++cov["fill_resnap"];
        if (pk < 0 && !inMargin(f.set)) pk = int(FS.size() - 1);
      }
      if (pk >= 0) {
        FSlot &f = FS[size_t(pk)];
        unsigned rsv = 0;
        for (const FSlot &x : FS)
          if (&x != &f && x.set == f.set && x.gone >= c && x.wayAt <= c) {
            rsv |= 1u << x.way;
            if (x.gone <= c + 1) ++cov[x.gone == c ? "victim_rsv_at_w" : "victim_rsv_at_grant"];
          }
        int vw = -1;
        for (unsigned w = 0; w < kWays && vw < 0; ++w)
          if (tags[f.set][w] < 0 && !(rsv >> w & 1)) vw = int(w);
        if (vw >= 0) ++cov["victim_invalid"];
        else {
          const unsigned pv = plVictimRef(pl[f.set]);
          if (!(rsv >> pv & 1)) vw = int(pv), ++cov["victim_plru"];
          else {
            ++cov["victim_skip"];
            for (unsigned w = 0; w < kWays && vw < 0; ++w)
              if (!(rsv >> w & 1)) vw = int(w);
          }
        }
        if (rsv) ++cov["victim_rsv_set"];
        f.way = unsigned(vw);
        f.wayAt = c + 1;
        const uint64_t wt = c - f.pick;
        ++cov["snap_wait_" + std::to_string(wt)];
        if (wt > 3 * (kNfw - 1) + 2) fail("model: a fill waited past its snapshot bound");
        plFill.emplace(c + 3, std::make_pair(f.set, f.way));
      }
      if (fPay) ++cov["fill"];
    }
    FS.erase(std::remove_if(FS.begin(), FS.end(), [&](const FSlot &x) { return x.gone <= c; }), FS.end());
    if (fLead) fNext = fNew;
    // dcu_fix sees its access and lets go.
    if (G.k == GK::Fix) {
      fxs = 0;
      fxGap = 2;
    }
    G = n;
    edge();
  }
};

int run(const std::string &scenario, const char *vcd, bool flat, bool nofree, bool order, bool unheld,
        bool nomargin, bool flood, bool creditPlus) {
  Bench b(vcd);
  b.flood = flood;
  if (creditPlus) b.pcr = Bench::kPc + 1;   // the control: a credit the port has no entry for
  b.flat = flat;
  b.nofree = nofree;
  b.order = order;
  b.unheld = unheld;
  b.nomargin = nomargin;
  // A control proves the bench's own comparison catches its fault: the RTL's
  // assertions, which a diverged stimulus can trip first, are off for it.
  if (flat || nofree || order || unheld || nomargin) Verilated::assertOn(false);
  Gen g(g_seed);
  b.reset();
  const bool rnd = scenario.empty();
  b.sameSet = rnd;
  // Preload: each set's ways, a few left invalid, lines sharing folds.
  if (scenario != "idle") {
    for (unsigned s = 0; s < kSets; ++s) {
      std::vector<unsigned> pool;
      for (unsigned l = 0; l < kLines; ++l) pool.push_back(l);
      for (unsigned w = 0; w < kWays; ++w) {
        if (rnd && g.below(8) == 0) continue;
        const unsigned k = g.below(unsigned(pool.size()));
        b.fill(s, w, int(pool[k]));
        pool.erase(pool.begin() + k);
      }
    }
    b.edge();
    b.edge();
  }
  const unsigned n = rnd ? 80000 : scenario == "idle" ? 3000 : 6000;
  for (unsigned i = 0; i < n; ++i) {
    const unsigned phase = (i / 500) % 4;
    bool lead;
    if (scenario == "idle") lead = false;
    else if (scenario == "medium") lead = g.below(3) == 0;
    else if (scenario == "high") lead = g.below(10) < 9;
    else lead = phase == 0 ? g.below(10) < 9 : phase == 1 ? g.below(3) == 0
               : phase == 2 ? true : g.below(2) == 0;
    // Fills: a few in medium, more in high and random (a burst now and then,
    // so a set's ways are reserved together and writes wait for the bank).
    bool flead;
    if (scenario == "idle") flead = false;
    else if (scenario == "medium") flead = g.below(16) == 0;
    else if (scenario == "high") flead = g.below(6) == 0;
    else flead = phase == 2 ? g.below(6) == 0 : g.below(30) == 0;
    b.step(g, lead, rnd, !rnd, flead);
    // --control unheld: its model's slots part from the RTL's, and the bench
    // would then drive past the RTL's contract: stop at the first mismatch.
    if (unheld && b.fails) break;
  }
  if (rnd) {
    for (const char *k : {"reread", "aged", "fix", "new", "waiter", "bypass", "queue_deep",
                          "drop_freed", "nomatch_freed", "mispredict", "fold_match_miss",
                          "no_match_miss", "two_credits", "placed", "wait_mshr", "wait_order",
                          "wait_held", "retry_grant", "retry_placed", "retry_again", "waiters_deep",
                          "fill", "victim_invalid", "victim_plru", "victim_skip", "victim_rsv_set",
                          "fill_held", "fill_unheld", "fill_held_block", "fill_held_reread",
                          "margin_reread", "fill_resnap", "victim_rsv_at_grant", "victim_rsv_at_w",
                          "port_write", "fill_yield", "fill_yield_unheld", "fill_wins_port", "port_wait"})
      if (!b.cov[k]) {
        std::fprintf(stderr, "bctl: coverage: %s never happened\n", k);
        ++b.fails;
      }
    std::fprintf(stderr, "bctl: coverage:");
    for (auto &kv : b.cov) std::fprintf(stderr, " %s=%u", kv.first.c_str(), kv.second);
    std::fprintf(stderr, " queue_max=%u waiters_max=%u port_wait_max=%u held_wait_max=%u port_queue_max=%u\n",
                 b.qmax, b.wmax, b.pwMax, b.hwMax, b.pqMax);
  }
  const char *ctl = flat     ? " control flat:"
                    : nofree ? " control nofree:"
                    : order  ? " control order:"
                    : unheld ? " control unheld:"
                    : nomargin ? " control nomargin:"
                             : ":";
  std::printf("bctl%s %s: %llu cycles, %u values checked, %u mismatches: %s\n", ctl,
              rnd ? "random" : scenario.c_str(), (unsigned long long)b.cyc, b.checked, b.fails,
              b.fails ? "FAIL" : "PASS");
  return b.fails ? 1 : 0;
}

}  // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string scenario;
  const char *vcd = nullptr;
  bool flat = false, nofree = false, order = false, unheld = false, nomargin = false;
  bool flood = false, creditPlus = false;
  for (int i = 1; i < argc; ++i)
    if (!std::strcmp(argv[i], "--flood")) flood = true;
  for (int i = 1; i + 1 < argc; ++i) {
    if (!std::strcmp(argv[i], "--control")) {
      if (!std::strcmp(argv[i + 1], "flat")) flat = true;
      else if (!std::strcmp(argv[i + 1], "nofree")) nofree = true;
      else if (!std::strcmp(argv[i + 1], "order")) order = true;
      else if (!std::strcmp(argv[i + 1], "unheld")) unheld = true;
      else if (!std::strcmp(argv[i + 1], "nomargin")) nomargin = true;
      else if (!std::strcmp(argv[i + 1], "credit_plus")) creditPlus = true;
      else {
        std::fprintf(stderr, "bctl: unknown control %s\n", argv[i + 1]);
        return 2;
      }
    }
    if (!std::strcmp(argv[i], "--seed")) g_seed = std::strtoull(argv[i + 1], nullptr, 0);
  }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "bctl: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, flat, nofree, order, unheld, nomargin, flood, creditPlus);
}
