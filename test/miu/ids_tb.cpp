//===-- ids_tb.cpp - miu_ids bench: DCU req_ids, picks and the entry table -===//
//
// Plays miu_lead, miu_a2 and the response side around miu_ids. A lookup in
// A1 on slot k (the lead lv) may take slot k's preselected id the next cycle
// (only when it holds one) for a random MQ entry, and A2 drops one take in
// eight a cycle later (dp), its id free two cycles on. A captured response
// (the lead rs) reads up to four distinct held ids through the id-to-entry
// table the next cycle (miu_rcap's req_ids), and a cycle after that each
// read's id is released, seven in eight (the rest a recovered UE's first
// answer, kept live for a later read).
// Checks, every cycle, each slot's preselected id and its valid against a
// value model of miu_ids's scheme (64 ids in quarters of 16, slot k on
// quarter k; the next pick the lowest free id of the quarter but the one
// preselected; an id released free from the next cycle, a dropped one a
// cycle later), and each read's entry, a cycle on, against the entry its id
// was taken for. The module's assertions (a take holds an id and was led; a
// read was led; a release follows a read and frees an id held; a drop
// follows a take) fail the run if they fire.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle is reset and nothing; medium takes on about a
// third of the cycles; high nearly every cycle.
// Controls, each of which must fail: noskip models the next pick taking
// the lowest free id even when it is the one taken now; relnow models a
// release free for the pick of the same cycle; nodrop keeps a dropped
// lookup's id held.
//===----------------------------------------------------------------------===//
#include "Vmiu_ids.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <random>
#include <string>
#include <vector>

namespace {

constexpr unsigned kNS = 4, kNI = 64, kQN = kNI / kNS, kIW = 6, kEW = 6, kNE = 40, kNR = 4;

enum class Ctl { none, noskip, relnow, nodrop };

int g_argc;
char **g_argv;

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vmiu_ids> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  unsigned cov_drop = 0, cov_empty = 0, cov_refill = 0, cov_b2b = 0, cov_rel4 = 0, cov_read[kNS] = {},
           cov_low = 0;
  Ctl ctl;
  // The value model.
  bool free_[kNI];
  bool pv[kNS] = {};
  unsigned pq[kNS] = {};
  unsigned ent[kNI] = {};

  Bench(const char *vcd_path, Ctl c) : ctl(c) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    ctx->fatalOnError(false);   // an assertion fails the run, below, not abort()
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vmiu_ids>(ctx.get());
    if (vcd_path) {
      vcd = std::make_unique<VerilatedVcdC>();
      dut->trace(vcd.get(), 99);
      vcd->open(vcd_path);
    }
    for (unsigned i = 0; i < kNI; ++i) free_[i] = true;
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
    dut->miu_core_clk = 0;
    eval();
    dut->miu_core_clk = 1;
    eval();
    ++cyc;
  }
  void quiet() {
    dut->lv_cm05h = 0;
    dut->rs_cm04h = 0;
    dut->tk_cm06h = 0;
    dut->dp_cm06h = 0;
    dut->rl_cm06h = 0;
    dut->qv_cm05h = 0;
  }
  void reset() {
    dut->rst_n = 0;
    quiet();
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();   // the flopped reset releases a cycle on (RST-1)
    // The first picks, from the free vector reset full.
    pick(nullptr, nullptr);
    edge();
  }
  // The model's picks at an edge: slot k picks when it took or holds none,
  // from the free vector before the edge, but its preselected id.
  void pick(const bool *tk, const bool *rel) {
    for (unsigned k = 0; k < kNS; ++k) {
      if (pv[k] && !(tk && tk[k])) continue;
      bool f[kQN];
      for (unsigned i = 0; i < kQN; ++i)
        f[i] = free_[k * kQN + i] || (ctl == Ctl::relnow && rel && rel[k * kQN + i]);
      if (pv[k] && ctl != Ctl::noskip) f[pq[k]] = false;
      pv[k] = false;
      for (unsigned i = 0; i < kQN; ++i)
        if (f[i]) {
          pv[k] = true;
          pq[k] = i;
          break;
        }
    }
  }
};

void setBits(uint32_t &w, unsigned lo, unsigned n, unsigned v) {
  w = (w & ~(((1u << n) - 1u) << lo)) | ((v & ((1u << n) - 1u)) << lo);
}

struct Gen {
  std::mt19937_64 r;
  explicit Gen(uint64_t seed) : r(seed) {}
  unsigned below(unsigned n) { return unsigned(r() % n); }
};

int run(const std::string &scenario, const char *vcd, Ctl ctl) {
  Bench b(vcd, ctl);
  Gen g(0x1d5);
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 60000 : scenario == "idle" ? 3000 : 4000;
  bool rd_prev = false;
  unsigned want_qe[kNR] = {};
  bool want_qv[kNR] = {};
  unsigned tk_prev = 0;
  unsigned lv = 0;   // the leads driven last cycle: a lookup in A1 a slot,
  bool rs = false;   // a response captured
  unsigned dp = 0;   // drops due now, of the ids taken last cycle
  unsigned dpid[kNS] = {};
  std::vector<unsigned> dpend;   // ids dropped last cycle, freed at this edge
  unsigned rdid[kNR] = {};       // the ids read last cycle
  for (unsigned i = 0; i < n; ++i) {
    // The DUT's picks now, against the model's.
    ++b.checked;
    bool ok = true;
    for (unsigned k = 0; k < kNS; ++k) {
      const bool dv = b.dut->pv_cm06h >> k & 1u;
      const unsigned did = b.dut->pid_cm06h >> (k * kIW) & 63u;
      if (dv != b.pv[k] || (dv && did != k * kQN + b.pq[k])) {
        ok = false;
        if (b.fails < 20)
          std::fprintf(stderr, "ids: cycle %llu: slot %u pick %u/%u, want %u/%u\n",
                       (unsigned long long)b.cyc, k, dv, did, b.pv[k], k * kQN + b.pq[k]);
      }
      b.cov_empty += !b.pv[k];
    }
    // Last cycle's reads, flopped now.
    if (rd_prev)
      for (unsigned j = 0; j < kNR; ++j)
        if (want_qv[j]) {
          const unsigned got = b.dut->qe_cm06h >> (j * kEW) & 63u;
          if (got != want_qe[j]) {
            ok = false;
            if (b.fails < 20)
              std::fprintf(stderr, "ids: cycle %llu: read %u entry %u, want %u\n",
                           (unsigned long long)b.cyc, j, got, want_qe[j]);
          }
        }
    if (!ok) ++b.fails;
    // Activity: bursts that empty a quarter, then quiet that refills it.
    const unsigned dens = scenario == "idle"     ? 0
                          : scenario == "medium" ? (i % 3 == 0 ? 8 : 0)
                          : scenario == "high"   ? 9
                                                 : (i / 200) % 2 ? 10 : 3;
    const unsigned rdens = scenario == "idle" ? 0 : rnd ? ((i / 200) % 2 ? 2 : 9) : dens;
    // Leads for the next cycle: a lookup in A1 on slot k; a response.
    unsigned lvn = 0;
    for (unsigned k = 0; k < kNS; ++k)
      if (g.below(10) < dens) lvn |= 1u << k;
    const bool rsn = g.below(10) < rdens;
    // Takes: a lookup in A2 (led last cycle) that is not dropped.
    bool tk[kNS] = {};
    uint32_t tkw = 0, tew = 0;
    unsigned dpn = 0;
    for (unsigned k = 0; k < kNS; ++k)
      if ((lv >> k & 1u) && b.pv[k] && g.below(10) < 9) {
        tk[k] = true;
        tkw |= 1u << k;
        const unsigned e = g.below(kNE);
        setBits(tew, k * kEW, kEW, e);
        b.cov_b2b += tk_prev >> k & 1u;
        b.cov_low += b.pq[k] == 0;
        if (g.below(8) == 0) dpn |= 1u << k;   // A2 drops it
      }
    // Held ids, before this cycle's takes, but one dropped now or to be, and
    // one read last cycle (its release, or not, is now).
    bool doomed[kNI] = {};
    for (unsigned k = 0; k < kNS; ++k)
      if (dp >> k & 1u) doomed[dpid[k]] = true;
    for (unsigned id : dpend) doomed[id] = true;
    for (unsigned j = 0; j < kNR; ++j)
      if (want_qv[j]) doomed[rdid[j]] = true;
    // Releases: of last cycle's reads, seven in eight (the rest a recovered
    // UE's first answer, whose id stays live for a later read).
    bool rel[kNI] = {};
    uint32_t rlw = 0;
    for (unsigned j = 0; j < kNR; ++j)
      if (want_qv[j] && g.below(8) != 0) {
        rel[rdid[j]] = true;
        rlw |= 1u << j;
      }
    b.cov_rel4 += rlw == (1u << kNR) - 1u;
    // Reads, given a response (led last cycle): distinct held ids, the first
    // slot always, if any id is held, the others at random.
    const unsigned rp = rnd ? ((i / 200) % 2 ? 3 : 9) : 6;
    std::vector<unsigned> h;
    for (unsigned id = 0; id < kNI; ++id)
      if (!b.free_[id] && !doomed[id]) h.push_back(id);
    uint32_t qvw = 0, qidw = 0;
    bool rd = false;
    for (unsigned j = 0; j < kNR; ++j) {
      want_qv[j] = false;
      if (!rs || h.empty() || (j && g.below(10) >= rp)) continue;
      const unsigned x = g.below(unsigned(h.size()));
      const unsigned id = h[x];
      h.erase(h.begin() + x);
      qvw |= 1u << j;
      setBits(qidw, j * kIW, kIW, id);
      want_qv[j] = true;
      want_qe[j] = b.ent[id];
      rdid[j] = id;
      ++b.cov_read[id / kQN];
      rd = true;
    }
    // Drive and clock.
    b.dut->lv_cm05h = lvn;
    b.dut->rs_cm04h = rsn;
    b.dut->tk_cm06h = tkw;
    b.dut->dp_cm06h = dp;
    b.dut->te_cm06h = tew;
    b.dut->rl_cm06h = rlw;
    b.dut->qv_cm05h = qvw;
    b.dut->qid_cm05h = qidw;
    b.edge();
    // The model at the edge.
    bool was_empty[kNS];
    for (unsigned k = 0; k < kNS; ++k) was_empty[k] = !b.pv[k];
    if (ctl != Ctl::nodrop)
      for (unsigned id : dpend) rel[id] = true;   // freed as a release, a cycle late
    dpend.clear();
    for (unsigned k = 0; k < kNS; ++k)
      if (dp >> k & 1u) dpend.push_back(dpid[k]);
    std::vector<unsigned> taken;
    for (unsigned k = 0; k < kNS; ++k)
      if (tk[k]) {
        const unsigned id = k * kQN + b.pq[k];
        taken.push_back(id);
        dpid[k] = id;
        b.ent[id] = tew >> (k * kEW) & 63u;
      }
    b.pick(tk, rel);
    for (unsigned id : taken) b.free_[id] = false;
    for (unsigned id = 0; id < kNI; ++id)
      if (rel[id]) b.free_[id] = true;
    for (unsigned k = 0; k < kNS; ++k) b.cov_refill += was_empty[k] && b.pv[k];
    rd_prev = rd;
    dp = dpn;
    b.cov_drop += dpn != 0;
    lv = lvn;
    rs = rsn;
    tk_prev = tkw;
    if (Verilated::gotError() || b.ctx->gotFinish()) {
      ++b.fails;
      std::fprintf(stderr, "ids: cycle %llu: an assertion fired\n", (unsigned long long)b.cyc);
      break;
    }
  }
  if (rnd && (!b.cov_drop || !b.cov_empty || !b.cov_refill || !b.cov_b2b || !b.cov_rel4 || !b.cov_low ||
              !b.cov_read[0] || !b.cov_read[1] || !b.cov_read[2] || !b.cov_read[3])) {
    std::fprintf(stderr,
                 "ids: coverage: drops %u, empty %u, refilled %u, back to back %u, four releases %u, "
                 "id 0 of a quarter %u, reads %u %u %u %u\n",
                 b.cov_drop, b.cov_empty, b.cov_refill, b.cov_b2b, b.cov_rel4, b.cov_low, b.cov_read[0],
                 b.cov_read[1], b.cov_read[2], b.cov_read[3]);
    ++b.fails;
  }
  const char *cn = ctl == Ctl::noskip   ? " control noskip:"
                   : ctl == Ctl::relnow ? " control relnow:"
                   : ctl == Ctl::nodrop ? " control nodrop:"
                                        : ":";
  std::printf("ids%s %s: %llu cycles, %u values checked, %u mismatches: %s\n", cn,
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
  Ctl ctl = Ctl::none;
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control")) {
      if (!std::strcmp(argv[i + 1], "noskip")) ctl = Ctl::noskip;
      else if (!std::strcmp(argv[i + 1], "relnow")) ctl = Ctl::relnow;
      else if (!std::strcmp(argv[i + 1], "nodrop")) ctl = Ctl::nodrop;
      else {
        std::fprintf(stderr, "ids: unknown control %s\n", argv[i + 1]);
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "ids: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
