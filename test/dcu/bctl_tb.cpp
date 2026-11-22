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
// Random mode covers: every arbitration outcome (re-read, aged waiter,
// fix, new lookup, waiter), the bypass of an empty queue,
// the queue at its deepest (two credits short, held by the pipeline), drops
// freeing the cycle, no-match misses freeing it, two credits due in a
// cycle, mispredicts. --cg <idle|medium|high> <vcd> runs one clock-gating
// scenario (tools/check-cg.py). --control flat (the model puts the new
// lookup ahead of the re-read) and --control nofree (a dropped access keeps
// its cycle) must fail.
//===----------------------------------------------------------------------===//
#include "Vdcu_bctl.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

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

constexpr unsigned kSlots = 4, kNB = 3, kWS = 9, kWays = 8, kWI = 6, kWF = 5, kWR = kWS - kNB;
constexpr unsigned kSets = 1u << kWR, kQD = 16, kAge = 16, kBank = 0, kWWY = 3, kLines = 24;

uint64_t g_seed = 0x5eed;
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
};

enum class GK { None, New, Wait, RR, Fix };
struct Grant {
  GK k = GK::None;
  unsigned addr = 0, rid = 0, slot = 0;
  bool w = false;
};
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
  bool flat = false, nofree = false;
  std::map<std::string, unsigned> cov;

  // The bench's tags and folds: per set, each way's line (-1 invalid).
  std::array<std::array<int, kWays>, kSets> tags{};
  static unsigned foldOf(unsigned line, unsigned set) { return (line * 7 + set) % 6; }

  // The model.
  std::vector<Look> L;   // by D0 cycle
  Grant G;               // this cycle's access
  std::deque<Ent> Q;
  unsigned owed = 0, qmax = 0;
  std::map<uint64_t, bool> wantEr;
  struct Ans { bool v = false; unsigned rid = 0, slot = 0; bool late = false; };
  std::map<uint64_t, Ans> wantAv, wantMv;
  std::array<std::array<uint8_t, kWays - 1>, kSets> pl{};
  std::map<uint64_t, std::pair<unsigned, unsigned>> plTouch;   // visible-from cycle -> set, way
  std::map<uint64_t, unsigned> wantPv;

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
  void fail(const std::string &what) {
    if (++fails <= 20) std::fprintf(stderr, "bctl: cycle %llu: %s\n", (unsigned long long)cyc, what.c_str());
  }
  void quiet() {
    dut->rv_cc01h = 0;
    dut->fwe_cc00h = 0;
    dut->fxv_cc03h = 0;
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
  void step(Gen &g, bool lead, unsigned rnd, bool hitBias) {
    const uint64_t c = cyc;
    if (L.size() < c + 3) L.resize(c + 3);
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
      uint32_t r = rnd ? g.below(64) : lastRid >> (s * kWI) & 63,
               f = rnd ? g.below(32) : lastFold >> (s * kWF) & 31, d = rnd ? g.below(2) : 0;
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
    const unsigned pvs = rnd ? g.below(kSets) : 0;
    dut->pvs_cc04h = pvs;
    dut->fwe_cc00h = 0;
    dut->eval();

    // ---- the model, this cycle ----
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
    chk("we", dut->we_cc04h, G.k == GK::Fix && G.w);
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
      auto im = wantMv.find(c);
      const Ans m = im != wantMv.end() ? im->second : Ans{};
      chk("mv", dut->mv_cc04h, m.v);
      if (m.v) {
        chk("mrid", dut->mrid_cc04h, m.rid);
        chk("mslot", dut->mslot_cc04h, m.slot);
      }
      if (im != wantMv.end()) wantMv.erase(im);
      auto ip = wantPv.find(c);
      if (ip != wantPv.end()) {
        chk("pvw", dut->pvw_cc05h, ip->second);
        wantPv.erase(ip);
      }
    }
    // PLRU: updates visible from this cycle, then the victim read now.
    for (auto it = plTouch.begin(); it != plTouch.end() && it->first <= c;) {
      plTouchRef(pl[it->second.first], it->second.second);
      it = plTouch.erase(it);
    }
    wantPv[c + 1] = plVictimRef(pl[pvs]);

    const bool wn2 = l2v && l2.won && !l2.drop, lq2 = l2v && !l2.won && !l2.drop;
    const bool mp = wn2 && l2.hit && l2.way != l2.pway;
    const bool aged = !Q.empty() && c - Q.front().d2 >= kAge - 2;
    std::deque<Ent> cand = Q;
    const bool l2wait = lq2 && l2.hit;
    if (l2wait) cand.push_back(Ent{l2.set << kWWY | l2.way, l2.rid, l2.slot, c});
    Grant n;
    bool popped = false;
    const bool l0v = l0.valid;
    if (!busy) {
      if (mp && !flat) {
        n = Grant{GK::RR, l2.set << kWWY | l2.way, l2.rid, l2.slot, false};
        ++cov["reread"];
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
    const bool e1 = (G.k == GK::New && !l1.drop) || G.k == GK::Wait;
    const bool e2 = lq2 && !l2.hit;
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
    if ((wn2 || lq2) && !l2.hit) wantMv[c + 1] = Ans{true, l2.rid, l2.slot, false};
    if ((wn2 || lq2) && l2.hit) plTouch[c + 2] = {l2.set, l2.way};
    // dcu_fix sees its access and lets go.
    if (G.k == GK::Fix) {
      fxs = 0;
      fxGap = 2;
    }
    G = n;
    edge();
  }
};

int run(const std::string &scenario, const char *vcd, bool flat, bool nofree) {
  Bench b(vcd);
  b.flat = flat;
  b.nofree = nofree;
  Gen g(g_seed);
  b.reset();
  const bool rnd = scenario.empty();
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
    b.step(g, lead, rnd, !rnd);
  }
  if (rnd) {
    for (const char *k : {"reread", "aged", "fix", "new", "waiter", "bypass", "queue_deep",
                          "drop_freed", "nomatch_freed", "mispredict", "fold_match_miss",
                          "no_match_miss", "two_credits"})
      if (!b.cov[k]) {
        std::fprintf(stderr, "bctl: coverage: %s never happened\n", k);
        ++b.fails;
      }
    std::fprintf(stderr, "bctl: coverage:");
    for (auto &kv : b.cov) std::fprintf(stderr, " %s=%u", kv.first.c_str(), kv.second);
    std::fprintf(stderr, " queue_max=%u\n", b.qmax);
  }
  const char *ctl = flat ? " control flat:" : nofree ? " control nofree:" : ":";
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
  bool flat = false, nofree = false;
  for (int i = 1; i + 1 < argc; ++i) {
    if (!std::strcmp(argv[i], "--control")) {
      if (!std::strcmp(argv[i + 1], "flat")) flat = true;
      else if (!std::strcmp(argv[i + 1], "nofree")) nofree = true;
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
  return run(scenario, vcd, flat, nofree);
}
