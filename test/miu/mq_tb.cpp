//===-- mq_tb.cpp - miu_mq bench: entries, held payloads, memop credits -----===//
//
// Drives ccv_ooe_miu_memop's four slots as OOE does, each slot under its own
// CCV_MEMOP_CREDITS credits: a memop or a bulk discard (mem_op 0xF, the rest
// zero) spends one, the valid at M and the 126-bit payload a cycle on. In
// random mode the payload wires carry noise in cycles with no payload,
// which the module must not keep. The completion side frees held entries
// through the four free ports, at most one port an entry, and returns each
// credit it gets back to the slot's count. Checks, every cycle, against a
// value model of slice 1's MQ:
//   - me: the entry each slot's memop takes is its slot's lowest free one
//     (slot j owns entries j*NC .. j*NC + NC - 1);
//   - every held entry's two views (A1 and HI, miu_mq's) are its payload,
//     from the cycle after it is written until it is freed;
//   - cr: a credit on the entry's slot for each freed entry and each bulk
//     discard, one a cycle a slot, the excess on the following cycles;
//   - lm: A2's write of a held entry's lane map, from any address slot (av
//     at 04, the entry at 05, the lanes' sums and forms at 06), is each
//     lane's formed address [6:0]: S[6:0], {lane, S[1:0]} interleaved,
//     C | lane << 2 local; held from the cycle after until the entry frees.
//     An entry frees only after its write (as in MIU), and the wires carry
//     noise in cycles with no write.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py): idle is reset and no memop; medium memops on about a
// third of the cycles; high nearly every cycle; the payload's wires change
// only with a memop. --control slot models a freed entry's credit returned
// on the next slot, --control discard a bulk discard's credit kept as if
// it took an entry, --control ilv an interleaved lane's word as its sum's,
// and --control local a local lane's byte as its sum's; each must fail.
//===----------------------------------------------------------------------===//
#include "Vmiu_mq.h"
#include "ccv_skel_wiring.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <map>
#include <memory>
#include <random>
#include <set>
#include <string>
#include <vector>

namespace {

constexpr unsigned kNS = 4, kNC = 10, kNE = kNS * kNC, kNF = 4, kEW = 6;
constexpr unsigned kAW = 63, kHW = 63, kPL = kAW + kHW;
constexpr unsigned kMemOpLsb = 51;   // miu_mq's MOP
constexpr unsigned kNL = 32, kNQ = 4, kLB = 7;   // the lane map

/// miu_mq's views against the generated payload layout: HI is rob_tag down
/// to issue_mask, A1 warp_id down to xfer_signed. A schema change that
/// moves a field fails this build, not a run.
constexpr unsigned lsbOf(const char *name) {
  for (const auto &f : ccv::skel::kF_ccv_ooe_miu_memop) {
    const char *a = f.name, *b = name;
    while (*a && *a == *b) ++a, ++b;
    if (*a == *b) return f.lsb;
  }
  return ~0u;
}
static_assert(lsbOf("issue_mask") == kAW, "miu_mq's A1 view is not the payload's low fields");
static_assert(lsbOf("mem_op") == kMemOpLsb, "mem_op moved in the memop payload");
static_assert(lsbOf("warp_id") + 5 == kAW && lsbOf("xfer_signed") == 0, "A1 view's ends moved");
static_assert(lsbOf("rob_tag") + 7 == kPL, "the memop payload is not 126 bits");

int g_argc;
char **g_argv;

struct Pay {
  uint64_t a1 = 0, hi = 0;   // the A1 view (bits 0..62) and HI (63..125)
  bool operator==(const Pay &o) const { return a1 == o.a1 && hi == o.hi; }
  bool discard() const { return ((a1 >> kMemOpLsb) & 0xF) == 0xF; }
};

template <class W> uint64_t getBits(const W &w, unsigned o, unsigned n) {
  uint64_t v = 0;
  for (unsigned b = 0; b < n; ++b) v |= uint64_t((w[(o + b) / 32] >> ((o + b) % 32)) & 1) << b;
  return v;
}
template <class W> void putBits(W &w, unsigned o, unsigned n, uint64_t v) {
  for (unsigned b = 0; b < n; ++b) {
    const unsigned i = (o + b) / 32, s = (o + b) % 32;
    w[i] = (w[i] & ~(1u << s)) | (uint32_t((v >> b) & 1) << s);
  }
}

struct Memop {
  unsigned slot = 0;
  Pay pay;
};

/// A2's write of one entry's lane map from address slot s.
struct A2w {
  unsigned slot = 0, entry = 0, form = 0;   // form 0 ordinary, 1 interleaved, 2 local
  uint8_t c = 0;
  std::array<uint8_t, kNL> sum{};
};

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vmiu_mq> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;
  unsigned cov_full = 0, cov_owed = 0, cov_discard = 0, cov_noise = 0, cov_four_free = 0;
  unsigned cov_ilv = 0, cov_loc = 0, cov_a2four = 0, cov_xslot = 0;
  // A2's writes in flight (at 04, 05, 06), the entries scheduled, and the
  // lane maps landed.
  std::vector<A2w> a2_[3];
  std::set<unsigned> a2_sched;
  std::map<unsigned, std::array<uint8_t, kNL>> lmap;
  std::string control;
  // The model: each slot's free entries, held payloads, credits owed.
  std::set<unsigned> free_[kNS];
  std::map<unsigned, Pay> held;
  unsigned owed[kNS] = {};
  // Last cycle's memops and frees, which the module takes this cycle.
  std::vector<Memop> prev_m;
  std::vector<unsigned> prev_f;
  bool want_cr[kNS] = {};

  Bench(const char *vcd_path, std::string ctl) : control(std::move(ctl)) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vmiu_mq>(ctx.get());
    if (vcd_path) {
      vcd = std::make_unique<VerilatedVcdC>();
      dut->trace(vcd.get(), 99);
      vcd->open(vcd_path);
    }
    for (unsigned j = 0; j < kNS; ++j)
      for (unsigned l = 0; l < kNC; ++l) free_[j].insert(j * kNC + l);
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
  void reset() {
    dut->rst_n = 0;
    dut->mv_cm00h = 0;
    dut->fv_cm00h = 0;
    dut->av_cm04h = 0;
    for (unsigned i = 0; i < 4; ++i) edge();
    dut->rst_n = 1;
    edge();   // the flopped reset releases a cycle on (RST-1)
  }
  unsigned lowest(unsigned j) const { return free_[j].empty() ? j * kNC : *free_[j].begin(); }
  /// The lane map the model wants (with its controls).
  std::array<uint8_t, kNL> formed(const A2w &w) const {
    std::array<uint8_t, kNL> m{};
    for (unsigned l = 0; l != kNL; ++l) {
      const uint8_t sv = w.sum[l];
      if (w.form == 2)
        m[l] = control == "local" ? uint8_t((w.c & 0x7C) | (l << 2) | (sv & 3)) : uint8_t(w.c | (l << 2));
      else if (w.form == 1 && control != "ilv")
        m[l] = uint8_t((l << 2) | (sv & 3));
      else
        m[l] = sv;
    }
    return m;
  }
  void bad(const char *what, unsigned a, unsigned b) {
    if (++fails <= 20)
      std::fprintf(stderr, "mq: cycle %llu: %s %u, want %u\n", (unsigned long long)cyc, what, a, b);
  }

  /// One cycle: this cycle's memops (valid) and frees (valid and entry);
  /// the payload of last cycle's memops on the wires; then the edge and
  /// the checks of what the module holds.
  void step(const std::vector<Memop> &now, const std::vector<unsigned> &frees,
            const std::vector<A2w> &a2now, bool noise, std::mt19937_64 &r) {
    // me now names the entry each of last cycle's memops takes.
    for (const Memop &m : prev_m) {
      if (m.pay.discard()) continue;
      ++checked;
      const unsigned me = (dut->me_cm01h >> (m.slot * kEW)) & ((1u << kEW) - 1);
      if (me != lowest(m.slot)) bad("me", me, lowest(m.slot));
    }
    // Wires.
    uint32_t mv = 0;
    for (const Memop &m : now) mv |= 1u << m.slot;
    dut->mv_cm00h = mv;
    for (unsigned j = 0; j < kNS; ++j) {
      const Memop *m = nullptr;
      for (const Memop &x : prev_m)
        if (x.slot == j) m = &x;
      if (m) {
        putBits(dut->pay_cm01h, j * kPL, kAW, m->pay.a1);
        putBits(dut->pay_cm01h, j * kPL + kAW, kHW, m->pay.hi);
      } else if (noise && r() % 2) {
        putBits(dut->pay_cm01h, j * kPL, kAW, r() & ((1ull << kAW) - 1));
        putBits(dut->pay_cm01h, j * kPL + kAW, kHW, r() & ((1ull << kHW) - 1));
        ++cov_noise;
      }
    }
    uint32_t fv = 0, fe = 0;
    for (unsigned p = 0; p < frees.size(); ++p) {
      fv |= 1u << p;
      fe |= frees[p] << (p * kEW);
    }
    if (noise)
      for (unsigned p = unsigned(frees.size()); p < kNF; ++p) fe |= unsigned(r() % 64) << (p * kEW);
    dut->fv_cm00h = fv;
    dut->fe_cm00h = fe;
    // A2's write: av now for a2now, the entry for a2_[0], the lanes for a2_[1].
    a2_[2] = a2_[1];
    a2_[1] = a2_[0];
    a2_[0] = a2now;
    uint32_t av = 0;
    for (const A2w &w : a2_[0]) av |= 1u << w.slot;
    dut->av_cm04h = av;
    uint32_t ae = noise ? uint32_t(r()) & 0xFFFFFF : dut->ae_cm05h;
    for (const A2w &w : a2_[1]) ae = (ae & ~(0x3Fu << (w.slot * kEW))) | (w.entry << (w.slot * kEW));
    dut->ae_cm05h = ae;
    uint32_t ilv = noise ? uint32_t(r()) & 0xFFFF : dut->ilv_cm06h;
    uint32_t loc = noise ? uint32_t(r()) & 0xFFFF : dut->loc_cm06h;
    uint32_t cl = noise ? uint32_t(r()) & 0xFFFFFFF : dut->cl_cm06h;
    if (noise)
      for (unsigned i = 0; i != kNS * kNL; ++i) putBits(dut->lo_cm06h, i * kLB, kLB, r() & 0x7F);
    if (a2_[2].size() == kNS) ++cov_a2four;
    for (const A2w &w : a2_[2]) {
      const uint32_t q = 0xFu << (w.slot * kNQ);
      ilv = (ilv & ~q) | (w.form == 1 ? q : 0);
      loc = (loc & ~q) | (w.form == 2 ? q : 0);
      cl = (cl & ~(0x7Fu << (w.slot * kLB))) | (uint32_t(w.c) << (w.slot * kLB));
      for (unsigned l = 0; l != kNL; ++l) putBits(dut->lo_cm06h, (w.slot * kNL + l) * kLB, kLB, w.sum[l]);
      cov_ilv += w.form == 1;
      cov_loc += w.form == 2;
      cov_xslot += w.slot != w.entry / kNC;
    }
    dut->ilv_cm06h = ilv;
    dut->loc_cm06h = loc;
    dut->cl_cm06h = cl;
    // The model takes last cycle's memops and frees now.
    unsigned ret[kNS] = {};
    for (const Memop &m : prev_m) {
      if (m.pay.discard()) {
        // --control discard: the discard taken as a memop, its credit not
        // returned until an entry it never held frees (expectation only).
        if (control != "discard") ++ret[m.slot];
        continue;
      }
      const unsigned e = lowest(m.slot);
      free_[m.slot].erase(e);
      held[e] = m.pay;
    }
    unsigned per_slot[kNS] = {};
    for (unsigned e : prev_f) {
      const unsigned j = e / kNC;
      free_[j].insert(e);
      held.erase(e);
      lmap.erase(e);
      a2_sched.erase(e);
      ++per_slot[j];
      ++ret[control == "slot" ? (j + 1) % kNS : j];
    }
    for (unsigned j = 0; j < kNS; ++j) {
      cov_four_free += per_slot[j] >= 3;
      cov_full += free_[j].empty();
      const unsigned due = owed[j] + ret[j];
      want_cr[j] = due != 0;
      owed[j] = due ? due - 1 : 0;
      cov_owed += owed[j] != 0;
    }
    edge();
    prev_m = now;
    prev_f = frees;
    for (const A2w &w : a2_[2]) lmap[w.entry] = formed(w);
    // Visible now: the credits, and every held entry's views.
    for (unsigned j = 0; j < kNS; ++j) {
      ++checked;
      const bool cr = (dut->cr_cm02h >> j) & 1;
      if (cr != want_cr[j]) bad("cr on slot", cr, want_cr[j]);
    }
    for (const auto &[e, p] : held) {
      ++checked;
      const Pay got{getBits(dut->a1_cm02h, e * kAW, kAW), getBits(dut->hi_cm02h, e * kHW, kHW)};
      if (!(got == p)) bad("payload differs in entry", e, e);
    }
    for (const auto &[e, m] : lmap)
      for (unsigned l = 0; l != kNL; ++l) {
        ++checked;
        const unsigned got = unsigned(getBits(dut->lm_cm07h, (e * kNL + l) * kLB, kLB));
        if (got != m[l]) {
          if (fails < 20) std::fprintf(stderr, "mq: entry %u lane %u:\n", e, l);
          bad("lane map", got, m[l]);
        }
      }
  }
};

int run(const std::string &scenario, const char *vcd, const std::string &ctl) {
  Bench b(vcd, ctl);
  std::mt19937_64 r(0x3a7);
  auto below = [&](unsigned n) { return unsigned(r() % n); };
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 60000 : scenario == "idle" ? 3000 : 4000;
  unsigned cred[kNS];
  for (unsigned j = 0; j < kNS; ++j) cred[j] = kNC;
  for (unsigned i = 0; i < n; ++i) {
    // Phases: random mode alternates a filling phase (few frees, slots run
    // out of credits) with a draining one (many frees, slot-heavy bursts).
    const bool fill = rnd && (i / 200) % 2;
    const unsigned busy = scenario == "idle"     ? 0
                          : scenario == "medium" ? (i % 3 == 0 ? 6 : 0)
                          : scenario == "high"   ? 9
                                                 : fill ? 8 : 5;
    std::vector<Memop> now;
    for (unsigned j = 0; j < kNS; ++j) {
      if (!cred[j] || below(10) >= busy) continue;
      Memop m{j, {}};
      if (below(16) == 0) {
        m.pay.a1 = uint64_t(0xF) << kMemOpLsb;   // a bulk discard
        ++b.cov_discard;
      } else {
        m.pay.a1 = r() & ((1ull << kAW) - 1);
        if (((m.pay.a1 >> kMemOpLsb) & 0xF) == 0xF) m.pay.a1 &= ~(uint64_t(1) << kMemOpLsb);
        m.pay.hi = r() & ((1ull << kHW) - 1);
      }
      --cred[j];
      now.push_back(m);
    }
    // Frees: held entries, at most kNF a cycle, slot-heavy when draining.
    std::vector<unsigned> frees;
    std::vector<unsigned> cand;
    // Held, and not freed last cycle (the model takes that free now).
    const std::set<unsigned> pending(b.prev_f.begin(), b.prev_f.end());
    for (const auto &[e, p] : b.held)
      if (!pending.count(e) && b.lmap.count(e)) cand.push_back(e);
    const unsigned pf = scenario == "idle" ? 0 : scenario == "medium" ? 2 : rnd ? (fill ? 1 : 6) : 5;
    if (!rnd || !fill || below(4) == 0) {
      const unsigned hot = below(kNS);
      for (unsigned e : cand)
        if (frees.size() < kNF && below(10) < pf && (!rnd || fill || e / kNC == hot || below(3) == 0))
          frees.push_back(e);
    }
    // A2's writes: held entries not yet written, at most one an address
    // slot, any slot for any entry.
    std::vector<A2w> a2;
    const unsigned pa = scenario == "idle" ? 0 : scenario == "medium" ? 3 : 8;
    unsigned used = 0;
    for (const auto &[e, p] : b.held) {
      if (b.a2_sched.count(e) || pending.count(e) || below(10) >= pa) continue;
      const unsigned s = below(kNS);
      if (used >> s & 1u) continue;
      used |= 1u << s;
      A2w w;
      w.slot = s;
      w.entry = e;
      w.form = below(3);
      w.c = uint8_t(r() & 0x7F);
      for (auto &x : w.sum) x = uint8_t(r() & 0x7F);
      b.a2_sched.insert(e);
      a2.push_back(w);
    }
    b.step(now, frees, a2, rnd, r);
    for (unsigned j = 0; j < kNS; ++j)
      if ((b.dut->cr_cm02h >> j) & 1) ++cred[j];
  }
  if (rnd && (!b.cov_full || !b.cov_owed || !b.cov_discard || !b.cov_noise || !b.cov_four_free ||
              !b.cov_ilv || !b.cov_loc || !b.cov_a2four || !b.cov_xslot)) {
    std::fprintf(stderr, "mq: coverage: slot full %u, credits owed %u, discards %u, noise %u, 3+ frees a slot %u, "
                 "A2 interleaved %u, local %u, four slots %u, another slot's entry %u\n",
                 b.cov_full, b.cov_owed, b.cov_discard, b.cov_noise, b.cov_four_free, b.cov_ilv, b.cov_loc,
                 b.cov_a2four, b.cov_xslot);
    ++b.fails;
  }
  std::printf("mq%s %s: %llu cycles, %u values checked, %u mismatches: %s\n",
              ctl.empty() ? ":" : (" control " + ctl + ":").c_str(), rnd ? "random" : scenario.c_str(),
              (unsigned long long)b.cyc, b.checked, b.fails, b.fails ? "FAIL" : "PASS");
  return b.fails ? 1 : 0;
}

}  // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string scenario, ctl;
  const char *vcd = nullptr;
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control")) {
      ctl = argv[i + 1];
      if (ctl != "slot" && ctl != "discard" && ctl != "ilv" && ctl != "local") {
        std::fprintf(stderr, "mq: unknown control %s\n", ctl.c_str());
        return 2;
      }
    }
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "mq: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl);
}
