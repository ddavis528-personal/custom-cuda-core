//===-- dcu_test.cpp - unit tests of dcu::Core ---------------------------===//
//
// The DCU model's timing, driven at its decoded interface, with no skeleton:
// each test lands requests and fills cycle by cycle and checks the cycle of
// every launch against the DCU tab (docs/design-snapshots/dcu-spec.md; the
// live doc wins), plus the never-happens conditions, each with a negative
// control that must fail. The kernels (tools/check-kernel.sh with the model
// in place) cover the data paths; these pin the cycles.
//
// Usage: dcu-test [-v]. Exit status 0 iff every test passes.
//===----------------------------------------------------------------------===//
#include "dcu_core.h"

#include <algorithm>
#include <array>
#include <cstdio>
#include <cstring>
#include <deque>
#include <functional>
#include <map>
#include <string>
#include <vector>

using namespace ccv::dcu;

namespace {

int g_fail = 0;
bool g_verbose = false;
std::string g_test;

/// MLC's line for an address: distinct per line.
uint8_t pat(uint64_t pa, unsigned k) { return uint8_t(((pa * 2654435761u) >> 24) + k); }

#define EXPECT(c, ...)                                                                      \
  do {                                                                                      \
    if (!(c)) {                                                                             \
      ++g_fail;                                                                             \
      std::fprintf(stderr, "FAIL %s:%d [%s] %s: ", __FILE__, __LINE__, g_test.c_str(), #c); \
      std::fprintf(stderr, __VA_ARGS__);                                                    \
      std::fputc('\n', stderr);                                                             \
    }                                                                                       \
  } while (0)

struct H : Hooks {
  std::vector<std::string> fails;
  std::map<std::string, uint64_t> bins;
  void fail(const std::string &m) override {
    fails.push_back(m);
    if (g_verbose) std::fprintf(stderr, "  core fail: %s\n", m.c_str());
  }
  void hit(const char *b, uint64_t n) override { bins[b] += n; }
  std::map<std::string, uint64_t> peaks;
  void peak(const char *b, uint64_t v) override { peaks[b] = std::max(peaks[b], v); }
};

/// A bench: the core, its inputs by cycle, and what it launched, by cycle.
struct Bench {
  H h;
  Core core;
  uint64_t t = 0;
  std::map<uint64_t, std::vector<Req>> reqs;
  std::map<uint64_t, Fill> fills;
  struct Launch { uint64_t t; Rsp r; };
  std::vector<Launch> rsps;
  std::vector<std::pair<uint64_t, Out::Notice>> notices;
  std::vector<std::pair<uint64_t, MlcReq>> mlc;
  std::map<uint64_t, Probe> probes;   ///< ccv_mlc_dcu_probe landings, by cycle
  std::vector<std::pair<uint64_t, ProbeAck>> acks;
  /// Answer MLC's requests itself, `mlc_lat` cycles after launch.
  bool auto_mlc = true;
  unsigned mlc_lat = 20;
  /// Hold fills to ccv_mlc_dcu_rsp's credits (CCV_CREDIT_DEPTH fill buffers),
  /// as MIU does; off, a fill lands when it is answered.
  bool fill_credits = false;
  unsigned fcred = ccv::kCreditDepth;
  std::deque<Fill> fq;
  bool mlc_block = false;   ///< hold ccv_dcu_mlc_req's credit back
  std::vector<Req> held;   ///< requests the core did not accept yet
  std::array<bool, kSlots> can{{true, true, true, true}};   ///< each rsp slot's rsp_can
  explicit Bench(Config c) : core(c, h) {}

  void run(uint64_t until) {
    for (; t < until; ++t) {
      std::vector<Req> in;
      auto it = reqs.find(t);
      if (it != reqs.end()) held.insert(held.end(), it->second.begin(), it->second.end());
      if (core.accepting()) in.swap(held);
      std::optional<Fill> f;
      auto fi = fills.find(t);
      if (fi != fills.end()) f = fi->second;
      if (fill_credits) {   // MIU's side of ccv_mlc_dcu_rsp: a fill waits for a credit
        if (f) fq.push_back(*f);
        f.reset();
        if (fcred && !fq.empty()) {
          f = fq.front();
          fq.pop_front();
          --fcred;
        }
      }
      Ports p;
      for (unsigned s = 0; s != kSlots; ++s) {
        p.rsp_can[s] = can[s];
        p.rsp_credits[s] = 8;
        p.ntc_can[s] = true;
      }
      p.mlc_can = !mlc_block;
      std::optional<Probe> pr;
      auto pi = probes.find(t);
      if (pi != probes.end()) pr = pi->second;
      Out o = core.cycle(t, in, f, p, pr);
      if (fill_credits) fcred += o.fill_release;
      if (o.prb_ack) acks.push_back({t, *o.prb_ack});
      for (const Rsp &r : o.rsps) rsps.push_back({t, r});
      for (const auto &n : o.notices) notices.push_back({t, n});
      if (o.mlc) {
        mlc.push_back({t, *o.mlc});
        if (auto_mlc) {
          Fill x;
          x.id = o.mlc->id;
          for (unsigned k = 0; k != kLineBytes; ++k) x.line[k] = pat(o.mlc->pa, k);
          x.own = o.mlc->op == MlcOp::AcquireData || o.mlc->op == MlcOp::AcquirePerm;
          x.miss = true;
          // A launch at t lands its payload at t+2; MLC answers, landing
          // mlc_lat later.
          fills[t + mlc_lat] = x;
        }
      }
    }
  }
  /// The launch cycle of req_id's response, or ~0.
  uint64_t at(unsigned id) const {
    for (const Launch &l : rsps)
      if (l.r.req_id == id) return l.t;
    return ~uint64_t(0);
  }
  const Rsp *rsp(unsigned id) const {
    for (const Launch &l : rsps)
      if (l.r.req_id == id) return &l.r;
    return nullptr;
  }
  const Rsp *rspLast(unsigned id) const {
    const Rsp *p = nullptr;
    for (const Launch &l : rsps)
      if (l.r.req_id == id) p = &l.r;
    return p;
  }
};

Req rd(unsigned slot, unsigned id, uint64_t pa) {
  Req r;
  r.slot = slot;
  r.req_id = id;
  r.pa = pa;
  r.op = Op::Read;
  return r;
}
Req st(unsigned slot, unsigned id, uint64_t pa, unsigned byte, uint8_t v) {
  Req r = rd(slot, id, pa);
  r.op = Op::Store;
  r.mask[byte] = true;
  r.wdata[byte] = v;
  return r;
}

/// Lines of one bank (bank 0 at 8 banks: line address [9:7] = 0), distinct sets.
uint64_t bank0(unsigned i) { return uint64_t(i) * 8 * kLineBytes; }

Config cfg(unsigned hit) {
  Config c;
  c.lat_hit = hit;
  c.wp_bits = hit == 8 ? 5 : 0;
  return c;
}

/// Warm a line into L1 (a read miss and its fill), then run quiet.
void warm(Bench &b, uint64_t pa, unsigned id = 60) {
  b.reqs[b.t].push_back(rd(0, id, pa));
  b.run(b.t + 60);
}

/// Whether the core refused something with a message containing `what`.
bool refused(const Bench &b, const char *what) {
  for (const std::string &f : b.h.fails)
    if (f.find(what) != std::string::npos) return true;
  return false;
}

void test(const char *name, const std::function<void()> &f) {
  g_test = name;
  const int before = g_fail;
  f();
  if (g_verbose || g_fail != before)
    std::fprintf(stderr, "%s %s\n", g_fail == before ? "ok  " : "FAIL", name);
}

} // namespace

int main(int argc, char **argv) {
  g_verbose = argc > 1 && !std::strcmp(argv[1], "-v");

  // The hit pipes: a read hit launches at P + 2 (A, L1_HIT 7), P + 3 (C, 8;
  // predicted right) or P + 4 (B, 9). The MIU tab's L1-hit budget.
  for (unsigned hit : {7u, 8u, 9u})
    test(hit == 7 ? "hit-pipe-A" : hit == 8 ? "hit-pipe-C" : "hit-pipe-B", [&] {
      Bench b(cfg(hit));
      warm(b, 0x1000);
      const uint64_t P = b.t;
      b.reqs[P].push_back(rd(1, 1, 0x1000));
      b.run(P + 20);
      EXPECT(b.at(1) == P + hit - 5, "launched at P+%lld, want P+%u", (long long)(b.at(1) - P), hit - 5);
      EXPECT(b.rsp(1) && b.rsp(1)->hit && b.rsp(1)->data, "a hit with data");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // A miss, notices on: the read goes to MLC; the fill is noticed in its landing cycle F
  // and the refill launches at F + 1 + CCV_LAT_FILL_NOTICE (OA-23).
  test("miss-notice-refill", [] {
    Config c = cfg(9);
    c.notice = true;   // CCV_DCU_NOTICE=1: off by default (DI-4), kept working
    Bench b(c);
    b.reqs[0].push_back(rd(2, 7, 0x2000));
    b.run(100);
    EXPECT(b.mlc.size() == 1 && b.mlc[0].second.op == MlcOp::Read, "one MLC read");
    const uint64_t F = b.mlc[0].first + b.mlc_lat;
    EXPECT(b.notices.size() == 1 && b.notices[0].first == F && b.notices[0].second.slot == 2 &&
               b.notices[0].second.req_id == 7, "notice at the fill's cycle");
    EXPECT(b.at(7) == F + 1 + ccv::prov::kLatFillNotice, "refill at F+%lld",
           (long long)(b.at(7) - F));
    EXPECT(b.rsp(7) && !b.rsp(7)->hit && b.rsp(7)->mlc_miss, "a refill, not a hit");
  });

  // Un-noticed (CCV_DCU_NOTICE=0, the default), the refill answers at the floor: its valid
  // at F + CCV_LAT_FILL_NOTICE, so it launches at F + 3 (DI-4, MA rev 129).
  test("unnoticed-refill-floor", [] {
    Config c = cfg(9);
    c.notice = false;
    Bench b(c);
    b.reqs[0].push_back(rd(2, 7, 0x2000));
    b.run(100);
    EXPECT(b.mlc.size() == 1, "one MLC read");
    const uint64_t F = b.mlc[0].first + b.mlc_lat;
    EXPECT(b.notices.empty(), "no notice");
    EXPECT(b.at(7) == F + ccv::prov::kLatFillNotice - 1, "refill at F+%lld, want F+%u",
           (long long)(b.at(7) - F), ccv::prov::kLatFillNotice - 1);
  });

  // Two lookups due in one cycle to one bank: slot order; the loser waits in
  // the bank's queue and is served when the bank frees (2 cycles), late.
  test("bank-conflict-slot-order", [] {
    Bench b(cfg(9));
    warm(b, bank0(1), 60);
    warm(b, bank0(2), 61);
    const uint64_t P = b.t;
    b.reqs[P] = {rd(3, 1, bank0(1)), rd(0, 2, bank0(2))};
    b.run(P + 30);
    EXPECT(b.at(2) == P + 4, "slot 0 on time: P+%lld", (long long)(b.at(2) - P));
    EXPECT(b.at(1) == P + 6, "slot 3 a bank turn later: P+%lld", (long long)(b.at(1) - P));
    EXPECT(b.h.bins["dcu_bank_loser_s3"] == 1, "a slot-3 loser");
  });
  // Control: both granted is two accesses in one bank's busy cycles.
  test("bank-both-granted-control", [] {
    Config c = cfg(9);
    c.brk = "bank-both-granted";
    Bench b(c);
    warm(b, bank0(1), 60);
    warm(b, bank0(2), 61);
    b.reqs[b.t] = {rd(0, 1, bank0(1)), rd(1, 2, bank0(2))};
    b.run(b.t + 30);
    EXPECT(!b.h.fails.empty(), "the control must fail");
  });

  // The age bound (AR 364): a waiter under a stream of on-time hits to its
  // bank is served once it has waited CCV_DCU_BANK_AGE, blocking the stream.
  for (bool ignored : {false, true})
    test(ignored ? "bank-age-ignored-control" : "bank-age-bound", [&] {
      Config c = cfg(9);
      if (ignored) c.brk = "bank-age-ignored";
      Bench b(c);
      warm(b, bank0(1), 60);
      warm(b, bank0(2), 61);
      warm(b, bank0(3), 62);
      const uint64_t P = b.t;
      // Two lookups to bank 0 every other cycle keep it busy; id 1 loses.
      b.reqs[P] = {rd(0, 2, bank0(2)), rd(1, 1, bank0(1))};
      for (unsigned k = 1; k != 40; ++k) b.reqs[P + 2 * k] = {rd(0, 2 + k, bank0(2 + k % 2))};
      b.run(P + 120);
      const uint64_t w = b.at(1) - P;
      if (!ignored)
        EXPECT(w <= 4 + ccv::prov::kDcuBankAge + 2, "served within the bound: P+%lld", (long long)w);
      else
        EXPECT(w > 4 + ccv::prov::kDcuBankAge + 2, "the control must starve it: P+%lld", (long long)w);
      EXPECT(ignored || b.h.bins["dcu_age_block"] >= 1, "an age-bound block");
    });

  // A store hit, variant (b): the ack on the hit's cycle; the read and the
  // write deferred, read to write CCV gap (5); a later load of the line
  // waits for the write; the line is dirty and holds the store's byte.
  for (bool early : {false, true})
    test(early ? "store-write-early-control" : "store-deferred", [&] {
      Config c = cfg(9);
      if (early) c.brk = "store-write-early";
      Bench b(c);
      // Owned: a partial store miss acquires the line with its data.
      b.reqs[0].push_back(st(0, 1, 0x3000, 5, 0xaa));
      b.run(80);
      const uint64_t P = b.t;
      b.reqs[P] = {st(0, 2, 0x3000, 6, 0xbb)};
      b.reqs[P + 1] = {rd(1, 3, 0x3000)};
      b.run(P + 40);
      if (early) {
        EXPECT(!b.h.fails.empty(), "the control must fail");
        return;
      }
      EXPECT(b.at(2) == P + 4, "store ack at P+%lld", (long long)(b.at(2) - P));
      EXPECT(b.h.bins["dcu_store_write"] == 1 && b.h.bins["dcu_store_rdwr_sum"] >= 5, "write 5 after read");
      EXPECT(b.at(3) > P + 1 + 4, "the load waits for the write: P+%lld", (long long)(b.at(3) - P));
      EXPECT(b.rsp(3) && b.rsp(3)->line[5] == 0xaa && b.rsp(3)->line[6] == 0xbb, "merged bytes");
      EXPECT(b.core.dirtyLine(0x3000) && b.core.ownedLine(0x3000), "owned and dirty");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // A merged miss (MA-12): a second read of a line in flight joins its
  // buffer and is answered from the fill; one MLC request.
  test("merged-miss", [] {
    Bench b(cfg(9));
    b.reqs[0] = {rd(0, 1, 0x4000)};
    b.reqs[3] = {rd(1, 2, 0x4000)};
    b.run(80);
    EXPECT(b.mlc.size() == 1, "one MLC request, not %zu", b.mlc.size());
    EXPECT(b.rsp(1) && b.rsp(2), "both answered");
    EXPECT(b.h.bins["dcu_merged"] == 1, "one merged");
  });

  // Waiting (MA-12; slice 2, part 1): a fifth request to a line whose merge
  // list is full, and a miss with every entry in use, wait in their bank's
  // queue as miss-wait, keeping their entry credit; the channel is never
  // held. Each is answered once its fill is written or an entry frees.
  test("wait-merge-full", [] {
    Bench b(cfg(9));
    b.mlc_lat = 40;
    for (unsigned k = 0; k != 6; ++k) b.reqs[k] = {rd(k % 4, k, 0x5000)};
    b.run(15);
    EXPECT(b.core.accepting() && b.h.bins["dcu_miss_wait_list"], "waits with the merge list full, channel open");
    b.run(150);
    EXPECT(b.rsp(4) && b.rsp(5), "both answered after the fill");
    EXPECT(b.mlc.size() == 1, "one MLC request: the waiters hit the written line, not %zu", b.mlc.size());
    EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
  });
  test("wait-entries-full", [] {
    Bench b(cfg(9));
    b.mlc_lat = 60;
    b.fill_credits = true;   // 16 misses' fills, as MIU sends them (DI-48)
    for (unsigned k = 0; k != 17; ++k) b.reqs[k] = {rd(0, k, 0x10000 + uint64_t(k) * 0x80000)};
    b.run(45);
    EXPECT(b.core.accepting() && b.h.bins["dcu_miss_wait_entry"], "waits with 16 entries in use, channel open");
    b.run(200);
    EXPECT(b.rsp(16) != nullptr, "the 17th answered");
    EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
  });

  // DI-43 (the RTL's form, victim at F+2): fills to one set land a cycle
  // apart, so each snapshot waits for the fold table's margin of the one
  // before's write, oldest first, one a bank a cycle, within 3 * (NFW - 1)
  // + 2. Then nine lines more of the set fill a full set: no pick takes a
  // way written that cycle. dcu-fill-nomargin snapshots inside the margin
  // (no lookup sees it; the wait bin stays 0), dcu-fill-rsv-grant releases
  // the written way's reservation at its write, refused.
  for (const char *ctl : {(const char *)nullptr, "dcu-fill-nomargin", "dcu-fill-rsv-grant"})
    test(ctl ? (std::string(ctl) + "-control").c_str() : "fill-snap-margin", [&] {
      bool caught = false;
      uint64_t late = 0, wmax = 0;
      for (unsigned wp : {5u, 0u})
        for (unsigned gap = 1; gap != 4; ++gap) {
          Config c = cfg(wp ? 8 : 9);
          c.victim_at = 2;
          if (ctl) c.brk = ctl;
          Bench b(c);
          b.fill_credits = true;
          for (unsigned k = 0; k != 24; ++k)
            b.reqs[uint64_t(k) * gap] = {rd(0, k, 0x10000 + uint64_t(k) * c.sets * kLineBytes)};
          b.run(600);
          late += b.h.bins["dcu_fill_snap_late"];
          wmax = std::max(wmax, b.h.peaks["dcu_fill_snap_wait_max"]);
          if (refused(b, "writes this cycle")) caught = true;
          else if (!ctl || std::string(ctl) != "dcu-fill-rsv-grant")
            EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
          if (!ctl || std::string(ctl) != "dcu-fill-rsv-grant")
            EXPECT(b.rsp(23) != nullptr, "the last read answered (wp %u, gap %u)", wp, gap);
        }
      // One way a set, no fold table (so no margin): the second fill waits
      // for a free way; the first's write frees it, but the second may take
      // it only a cycle on, once the snapshot can see the write.
      {
        Config c = cfg(9);
        c.victim_at = 2;
        c.ways = 1;
        if (ctl) c.brk = ctl;
        Bench b(c);
        b.fill_credits = true;
        b.reqs[0] = {rd(0, 1, 0x10000)};
        b.reqs[1] = {rd(0, 2, 0x10000 + uint64_t(c.sets) * kLineBytes)};
        b.run(300);
        if (refused(b, "writes this cycle")) caught = true;
        else if (!ctl || std::string(ctl) != "dcu-fill-rsv-grant") {
          EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
          EXPECT(b.rsp(2) != nullptr, "the second read answered");
        }
      }
      if (g_verbose) std::fprintf(stderr, "  late %llu, wait max %llu\n", (unsigned long long)late, (unsigned long long)wmax);
      if (!ctl) EXPECT(late >= 1 && wmax >= 1 && !caught, "snapshots waited (late %llu, max %llu)",
                       (unsigned long long)late, (unsigned long long)wmax);
      else if (std::string(ctl) == "dcu-fill-nomargin") EXPECT(wmax == 0 && !caught, "no wait without the margin");
      else EXPECT(caught, "the control is refused");
    });

  // Replacement is tree-PLRU (MA-30), not true LRU. Ways 0-7 of one set fill
  // in order (the lowest invalid way first) and are read in order; then way
  // 0 is read again. PLRU's victim is way 4 (line 4); true LRU's would be
  // line 1. A ninth line of the set then evicts line 4, and line 1 still hits.
  test("plru-victim", [] {
    Bench b(cfg(9));
    const uint64_t stride = uint64_t(Config{}.sets) * kLineBytes;
    for (unsigned i = 0; i != 8; ++i) warm(b, 0x40000 + i * stride, 60 + i);
    b.reqs[b.t].push_back(rd(0, 1, 0x40000));
    b.run(b.t + 30);
    b.reqs[b.t].push_back(rd(0, 2, 0x40000 + 8 * stride));
    b.run(b.t + 60);
    b.reqs[b.t].push_back(rd(0, 3, 0x40000 + 1 * stride));
    b.run(b.t + 60);
    b.reqs[b.t].push_back(rd(0, 4, 0x40000 + 4 * stride));
    b.run(b.t + 60);
    EXPECT(b.rsp(1) && b.rsp(1)->hit, "line 0 hits");
    EXPECT(b.rsp(2) && !b.rsp(2)->hit, "line 8 misses");
    EXPECT(b.rsp(3) && b.rsp(3)->hit, "line 1 still hits (true LRU would have evicted it)");
    EXPECT(b.rsp(4) && !b.rsp(4)->hit, "line 4 was PLRU's victim");
    EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
  });

  // A hit touches PLRU a cycle after its D2 (D + 3), a bank-conflict loser
  // included, and only then (dcu_bctl's pu_q; MA's DI-26 answer). After
  // ways 0-7 fill and are read in order the victim is way 0; three reads of
  // the set in one cycle (one bank: two lose) touch ways 0, 4 and 2, each
  // moving the victim (to 4, 2, then 6). All three touch at the winner's
  // D + 3, so the victim moves once, 0 to 6. plru-at-serve, the control,
  // touches at serve: the winner at D, the losers as each is served.
  for (bool ctl : {false, true}) {
    test(ctl ? "plru-at-serve-control" : "plru-touch-at-d3", [&] {
      Config c = cfg(9);
      if (ctl) c.brk = "plru-at-serve";
      Bench b(c);
      const uint64_t stride = uint64_t(Config{}.sets) * kLineBytes, base = 0x40000;
      for (unsigned i = 0; i != 8; ++i) warm(b, base + i * stride, 60 + i);
      const unsigned v0 = b.core.victimWay(base);
      b.reqs[b.t] = {rd(0, 1, base), rd(1, 2, base + 4 * stride), rd(2, 3, base + 2 * stride)};
      std::vector<unsigned> moves;
      unsigned v = v0;
      for (uint64_t end = b.t + 40; b.t < end;) {
        b.run(b.t + 1);
        const unsigned n = b.core.victimWay(base);
        if (n != v) moves.push_back(n);
        v = n;
      }
      const bool ok = v0 == 0 && moves.size() == 1 && moves[0] == 6;
      EXPECT(b.rsp(1) && b.rsp(2) && b.rsp(3) && b.rsp(3)->hit, "all three hit");
      EXPECT(ctl ? !ok : ok, "victim %u, then %zu moves (last %u)", v0, moves.size(), moves.empty() ? 99u : moves.back());
    });
  }

  // Eviction: a dirty victim is read from its bank and written back whole.
  test("evict-writeback", [] {
    Config c = cfg(9);
    c.ways = 1;
    Bench b(c);
    b.reqs[0] = {st(0, 1, 0x6000, 0, 0x11)};
    b.run(60);
    b.reqs[60] = {rd(0, 2, 0x6000 + uint64_t(c.sets) * kLineBytes)};   // same set
    b.run(200);
    bool wb = false;
    for (const auto &m : b.mlc) wb |= m.second.op == MlcOp::Write && m.second.pa == 0x6000 &&
                                       m.second.data && m.second.line[0] == 0x11;
    EXPECT(wb, "the dirty line written back with its data");
    EXPECT(b.h.bins["dcu_evict"] == 1 && b.h.bins["dcu_evict_read"] == 1, "evicted, read");
  });

  // Way prediction (pipe C): with two lines whose folds match in one set,
  // index selection predicts the lower way; a hit on the other is a
  // mispredict: a second bank access two cycles on, answered at due + 2 with
  // the right line, as a bank-conflict loser (DI-2, AR 390). The control
  // answers at due with the predicted way's line.
  for (bool ctl : {false, true})
    test(ctl ? "wp-late-at-due-control" : "wp-mispredict", [&] {
      Config c = cfg(8);
      c.wp_recent = false;
      if (ctl) c.brk = "wp-late-at-due";
      Bench b(c);
      // Tags 1 and 67 (chunks 3 and 2) fold alike at 5 bits.
      const uint64_t a = uint64_t(1) * c.sets * kLineBytes, x = uint64_t(67) * c.sets * kLineBytes;
      warm(b, a, 60);
      warm(b, x, 61);
      const uint64_t P = b.t;
      b.reqs[P] = {rd(0, 1, x)};
      b.run(P + 20);
      const Rsp *r = b.rsp(1);
      if (ctl) {
        EXPECT(b.at(1) == P + 3 && r && r->line[0] != pat(x, 0),
               "the control answers at due with the wrong line");
        return;
      }
      EXPECT(b.at(1) == P + 5, "mispredict at due + 2: P+%lld", (long long)(b.at(1) - P));
      EXPECT(b.h.bins["dcu_wp_reread"] == 1, "one re-read");
      EXPECT(r && r->line[0] == pat(x, 0), "the true way's line");
      EXPECT(b.h.bins["dcu_wp_wrong"] == 1, "one mispredict");
    });

  // MA-29's candidate predictor (CCV_DCU_WAYPRED_SEL=mru): the set's most
  // recently used valid way, by LRU state alone. Two lines of one set, x the
  // more recent: a read of a mispredicts (due + 2); a read of a again hits at
  // due, since its first read made it the most recent.
  test("wp-mru", [&] {
    Config c = cfg(8);
    c.wp_mru = true;
    Bench b(c);
    const uint64_t a = uint64_t(1) * c.sets * kLineBytes, x = uint64_t(2) * c.sets * kLineBytes;
    warm(b, a, 60);
    warm(b, x, 61);
    uint64_t P = b.t;
    b.reqs[P] = {rd(0, 1, a)};
    b.run(P + 20);
    EXPECT(b.at(1) == P + 5 && b.h.bins["dcu_wp_wrong"] == 1, "a, not the MRU way: mispredict at due + 2");
    EXPECT(b.rsp(1) && b.rsp(1)->line[0] == pat(a, 0), "a's line");
    P = b.t;
    b.reqs[P] = {rd(0, 2, a)};
    b.run(P + 20);
    EXPECT(b.at(2) == P + 3 && b.h.bins["dcu_wp_wrong"] == 1, "a, now the MRU way: hit at due");
  });

  // A UE in a clean line is recovered: invalidated, refetched as a miss.
  test("ue-clean-recover", [] {
    Config c = cfg(9);
    c.ue_every = 1;
    Bench b(c);
    warm(b, 0x7000);
    b.reqs[b.t] = {rd(0, 1, 0x7000)};
    b.run(b.t + 80);
    // The first answer carries a double-bit syndrome (TI-528); the second,
    // the refetch's, is a clean miss.
    EXPECT(b.rsp(1) && b.rsp(1)->ue_first && b.rsp(1)->flip >= 0 && b.rsp(1)->flip2 >= 0,
           "first answer: a double-bit syndrome");
    EXPECT(b.h.bins["ue_recover"] == 1 && b.rspLast(1) && !b.rspLast(1)->hit && b.rspLast(1)->flip < 0 &&
               b.rspLast(1)->flip2 < 0, "recovered as a miss");
  });

  // A UE in a dirty line is core-fatal: DCU withholds the read (AR 389,
  // TI-487 (3)) and raises ue; the control ue-answer answers it anyway.
  for (bool ctl : {false, true})
    test(ctl ? "ue-answer-control" : "ue-dirty-withheld", [&] {
      Config c = cfg(8);
      c.ue_every = 1;
      if (ctl) c.brk = "ue-answer";
      Bench b(c);
      b.reqs[0] = {st(0, 1, 0x8000, 3, 0x5a)};   // owned and dirty
      b.run(80);
      b.reqs[b.t] = {rd(0, 2, 0x8000)};
      b.run(b.t + 40);
      EXPECT(b.h.bins["ue_fatal"] == 1, "core-fatal");
      if (ctl) EXPECT(b.rsp(2) != nullptr, "the control answers the withheld read");
      else EXPECT(b.rsp(2) == nullptr, "the read is withheld");
    });

  // ECC (MA-28 (c), AR 401): an injected stored-bit error reaches MIU on the
  // read (its check bits are the block's), DCU counts the CE and rewrites the
  // corrected line `gap` cycles on; a read before the rewrite is not held
  // and finds the same bit (MIU corrects it the same way).
  test("ecc-ce-rewrite", [] {
    Config c = cfg(9);
    c.ecc_every = 1;
    Bench b(c);
    warm(b, 0x7000);
    const uint64_t t0 = b.t;
    b.reqs[t0] = {rd(0, 1, 0x7000)};
    b.reqs[t0 + 1] = {rd(1, 2, 0x7000)};
    b.run(t0 + 60);
    const auto *r1 = b.rsp(1), *r2 = b.rsp(2);
    EXPECT(r1 && r1->hit && r1->flip >= 0, "the first read carries the stored bit in error");
    EXPECT(b.h.bins["dcu_ce"] >= 1 && b.h.bins["dcu_ecc_write"] >= 1, "a CE counted and rewritten");
    EXPECT(r2 && r2->hit, "the second read hits");
    uint64_t t1 = 0, t2 = 0;
    for (const auto &l : b.rsps) {
      if (l.r.req_id == 1) t1 = l.t;
      if (l.r.req_id == 2) t2 = l.t;
    }
    EXPECT(t2 < t1 + c.gap && r2->flip == r1->flip, "the second read does not wait, and sees the same bit");
  });

  // dcu_fix (slice 1): one rewrite in flight and one pending. Three CEs in
  // one cycle, in three banks: two are rewritten, read then written 5 cycles
  // later, and the third is counted (ce_rewrite_full) and not rewritten. The
  // control ce-rewrite-unbounded takes all three, which the model refuses.
  for (bool ctl : {false, true})
    test(ctl ? "ecc-ce-rewrite-full-control" : "ecc-ce-rewrite-full", [&] {
      Config c = cfg(9);
      c.ecc_every = 1;
      if (ctl) c.brk = "ce-rewrite-unbounded";
      Bench b(c);
      for (unsigned k = 0; k != 3; ++k) warm(b, 0x10000 + k * kLineBytes, 60 + k);
      const uint64_t t0 = b.t;
      b.reqs[t0] = {rd(0, 1, 0x10000), rd(1, 2, 0x10000 + kLineBytes), rd(2, 3, 0x10000 + 2 * kLineBytes)};
      b.run(t0 + 80);
      if (ctl) {
        EXPECT(!b.h.fails.empty(), "the model refuses a third rewrite held");
        return;
      }
      EXPECT(b.h.bins["dcu_ce"] == 3, "three CEs counted, got %llu", (unsigned long long)b.h.bins["dcu_ce"]);
      EXPECT(b.h.bins["ce_rewrite_full"] == 1, "one CE found dcu_fix full");
      EXPECT(b.h.bins["dcu_ecc_read"] == 2 && b.h.bins["dcu_ecc_write"] == 2, "two rewrites, read and written");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // Pipe C's fold compare (slice 1). Two lines of one set whose folds are
  // equal: the second's first read is a fold-match miss (it reads, and
  // discards); once both are resident, the second (the higher way) is an
  // alias mispredict, re-read at due + 2. A line of no matching fold misses
  // with no read, so its bank serves the next lookup a cycle later, not two.
  test("wp-fold-bins", [] {
    Config c = cfg(8);
    c.wp_recent = false;   // slice 1's SEL 0, the lowest matching way (TI's params change pending, DI-24)
    const unsigned k = c.wp_bits;
    Bench b(c);
    const uint64_t a = 0x50000, alias = a ^ ((uint64_t(1) | uint64_t(1) << k) << 16);
    warm(b, a, 60);
    warm(b, alias, 61);
    EXPECT(b.h.bins["dcu_wp_fold_miss"] == 1, "the alias's miss matched a's fold");
    const uint64_t P = b.t;
    b.reqs[P] = {rd(0, 1, alias)};
    b.run(P + 30);
    EXPECT(b.h.bins["dcu_wp_alias"] == 1, "an alias mispredict");
    EXPECT(b.at(1) == P + 3 + 2, "the alias answers at due + 2, at P+%lld", (long long)(b.at(1) - P));
    EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
  });
  for (bool ctl : {false, true})
    test(ctl ? "wp-nomatch-noread-control" : "wp-nomatch-noread", [&] {
      Config c = cfg(8);
      if (ctl) c.brk = "wp-nomatch-reads";
      Bench b(c);
      warm(b, bank0(1), 60);
      const uint64_t P = b.t;
      b.reqs[P] = {rd(0, 1, bank0(2)), rd(1, 2, bank0(1))};   // one bank: a no-match miss, then a hit
      b.run(P + 60);
      EXPECT(b.h.bins["dcu_wp_nomatch_miss"] >= 1, "a no-match miss");
      const uint64_t want = P + 3 + (ctl ? 2 : 1);
      if (ctl) EXPECT(b.at(2) != P + 3 + 1, "the control reads on no match: the hit waits two cycles");
      else EXPECT(b.at(2) == want, "the hit waits one cycle, at P+%lld", (long long)(b.at(2) - P));
    });

  // Two lookups due in one bank in one cycle: counted (the stub MIU sends
  // them), and refused under the MIU model, whose A2 drops all but one
  // (DI-25 (4), MA rev 156).
  for (bool strict : {false, true})
    test(strict ? "cycle-conflict-refused" : "cycle-conflict-counted", [&] {
      Config c = cfg(9);
      c.no_cycle_conflict = strict;
      Bench b(c);
      warm(b, bank0(1), 60);
      warm(b, bank0(2), 61);
      b.reqs[b.t] = {rd(0, 1, bank0(1)), rd(1, 2, bank0(2))};
      b.run(b.t + 40);
      EXPECT(b.h.bins["dcu_cycle_conflict"] == 1, "one conflict counted");
      EXPECT(b.h.fails.empty() != strict, "refused only under the MIU model");
    });

  // A late answer takes any free response slot (slice 1, response slots;
  // MIU matches by req_id). Two lookups in one bank in one cycle: slot 1's
  // loses and answers late; with slot 1 closed it goes out on slot 0. The
  // control late-own-slot keeps it on slot 1, where it never leaves.
  for (bool ctl : {false, true})
    test(ctl ? "late-any-slot-control" : "late-any-slot", [&] {
      Config c = cfg(9);
      if (ctl) c.brk = "late-own-slot";
      Bench b(c);
      warm(b, bank0(1), 60);
      warm(b, bank0(2), 61);
      b.can[1] = false;
      b.reqs[b.t] = {rd(0, 1, bank0(1)), rd(1, 2, bank0(2))};
      b.run(b.t + 40);
      if (ctl) {
        EXPECT(b.rsp(2) == nullptr, "the control holds the answer on its own slot");
        EXPECT(b.h.bins["dcu_late_holds_bank"] == 0, "a late-own-slot answer is not a bank answer");
        return;
      }
      EXPECT(b.rsp(1) && b.rsp(1)->slot == 0, "the winner on its own slot");
      EXPECT(b.rsp(2) && b.rsp(2)->slot == 0, "the loser on slot 0, the free one");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // ---- Slice 2, parts 1-2 -------------------------------------------------

  // The request to MLC: a miss's tag result is flopped at D2 (H+4 = P+1)
  // under every pipe, and a request picked straight from D2 launches its
  // valid at H+5 (P+2). A second miss the same cycle, in another bank, is
  // the oldest unsent one next cycle: one a cycle.
  for (unsigned hit : {7u, 8u, 9u})
    test(hit == 7 ? "mlc-h5-A" : hit == 8 ? "mlc-h5-C" : "mlc-h5-B", [&] {
      Bench b(cfg(hit));
      b.reqs[3] = {rd(0, 1, 0x2000), rd(1, 2, 0x2080)};
      b.run(60);
      EXPECT(b.mlc.size() == 2, "two requests");
      EXPECT(b.mlc.size() == 2 && b.mlc[0].first == 5 && b.mlc[1].first == 6,
             "valids at P+%lld and P+%lld, want P+2 and P+3",
             (long long)(b.mlc.empty() ? 0 : b.mlc[0].first - 3),
             (long long)(b.mlc.size() < 2 ? 0 : b.mlc[1].first - 3));
      EXPECT(b.h.bins["dcu_mlc_straight"] == 1, "one straight from D2");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // A second miss to a line merges into its entry; dcu-mshr-nomerge, the
  // control, allocates it an entry of its own, which the CHECK refuses.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-mshr-nomerge-control" : "mshr-merge", [&] {
      Config c = cfg(9);
      if (ctl) c.brk = "dcu-mshr-nomerge";
      Bench b(c);
      b.reqs[0] = {rd(0, 1, 0x2000)};
      b.reqs[1] = {rd(1, 2, 0x2000)};
      b.run(80);
      if (ctl) {
        EXPECT(refused(b, "second miss buffer entry"), "the control is refused");
        return;
      }
      EXPECT(b.mlc.size() == 1 && b.h.bins["dcu_merged"] == 1, "one request, merged");
      EXPECT(b.rsp(1) && b.rsp(2), "both answered");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // Fill answers launch at F+3 at the earliest (valid at MIU at F+4);
  // dcu-fill-early answers at F+2, which the CHECK refuses.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-fill-early-control" : "fill-answer-floor", [&] {
      Config c = cfg(9);
      if (ctl) c.brk = "dcu-fill-early";
      Bench b(c);
      b.reqs[0] = {rd(0, 1, 0x2000)};
      b.run(80);
      const uint64_t F = b.mlc.empty() ? 0 : b.mlc[0].first + b.mlc_lat;
      if (ctl) {
        EXPECT(refused(b, "fill answer launched at F+2"), "the control is refused");
        return;
      }
      EXPECT(b.at(1) == F + 3, "answered at F+%lld", (long long)(b.at(1) - F));
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // A full merge list makes the fifth request to its line wait in its
  // bank's queue; a sixth to the line waits behind it, in order.
  // A bank loser that misses (DI-48): its tag result is known at its D2,
  // which is its bank's winner's D2; one dcu_mshr a bank takes one new miss
  // a cycle (MA-34), so the loser's miss waits in its bank's queue and
  // retries on port 0, after the winner's, and its slot's next miss
  // (another bank, a cycle or more later) is unaffected.
  // dcu-bank-two-miss lets the loser's miss in beside the winner's, which
  // the CHECK in startMiss refuses. dcu-loser-miss-late decides the loser's
  // miss at its access, a late miss that retries on port 0 (MA-33): the
  // same outcome, no id reused.
  for (const char *brk : {"", "dcu-bank-two-miss", "dcu-loser-miss-late"})
    test(!*brk ? "loser-miss-retry" : std::string(brk) == "dcu-bank-two-miss" ? "dcu-bank-two-miss-control"
                                                                               : "dcu-loser-miss-late-control",
         [&] {
      const std::string k = brk;
      unsigned caught = 0, two = 0, late = 0, busy = 0;
      for (unsigned d = 1; d != 5; ++d) {
        Config c = cfg(9);
        c.brk = k;
        Bench b(c);
        b.reqs[0] = {rd(0, 1, bank0(1)), rd(3, 2, bank0(2))};   // slot 3 loses bank 0
        b.reqs[d] = {rd(3, 3, bank0(3) + kLineBytes)};          // its next miss, bank 1
        b.run(120);
        if (refused(b, "offered while in use")) ++caught;
        if (refused(b, "started two misses")) ++two;
        busy += b.h.bins["dcu_bank_miss_busy"] != 0;
        uint64_t t1 = ~uint64_t(0), t2 = ~uint64_t(0);
        for (const auto &m : b.mlc) {
          if (m.second.pa == bank0(1)) t1 = m.first;
          if (m.second.pa == bank0(2)) t2 = m.first;
        }
        if (g_verbose) std::fprintf(stderr, "  d %u: winner's MLC request at %llu, loser's at %llu\n", d,
                                    (unsigned long long)t1, (unsigned long long)t2);
        if (t2 > t1 + 1 && t2 != ~uint64_t(0)) ++late;
        if (k != "dcu-bank-two-miss") {
          EXPECT(b.h.fails.empty(), "d %u: %s", d, b.h.fails.empty() ? "" : b.h.fails[0].c_str());
          EXPECT(b.rsp(1) && b.rsp(2) && b.rsp(3), "d %u: every read answered", d);
        }
      }
      if (k == "dcu-bank-two-miss") {
        EXPECT(two == 4, "the control's second miss in bank 0 is refused (%u of 4)", two);
        return;
      }
      EXPECT(late == 4 && caught == 0, "the loser's miss leaves after the winner's (%u of 4), no id reused (%u)",
             late, caught);
      if (k.empty()) EXPECT(busy == 4, "the loser waits for its bank's port (%u of 4)", busy);
    });

  // dcu-miss-reorder lets the sixth pass, which the CHECK refuses.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-miss-reorder-control" : "miss-wait-order", [&] {
      Config c = cfg(9);
      if (ctl) c.brk = "dcu-miss-reorder";
      Bench b(c);
      b.mlc_lat = 40;
      for (unsigned k = 0; k != 4; ++k) b.reqs[k] = {rd(0, k, 0x2000)};
      b.reqs[4] = {rd(0, 4, 0x2000)};
      b.reqs[6] = {rd(0, 5, 0x2000)};
      b.run(120);
      if (ctl) {
        EXPECT(refused(b, "passed a waiting one"), "the control is refused");
        return;
      }
      EXPECT(b.h.bins["dcu_miss_wait_list"] >= 1, "the fifth waits for room in the list");
      EXPECT(b.rsp(4) && b.rsp(5) && b.at(4) <= b.at(5), "answered in order");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // Tag-stale (slice 2, part 1): a lookup that lost its bank with a hit on
  // a clean victim's way, and reads after the fill's write, looks up again
  // and misses. dcu-fill-nostale reads the fill's line under the victim's
  // tag. One way a set, so the victim is the set's only line.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-fill-nostale-control" : "tag-stale-relook", [&] {
      Config c = cfg(9);
      c.ways = 1;
      if (ctl) c.brk = "dcu-fill-nostale";
      Bench b(c);
      const uint64_t v = bank0(1), n = v + uint64_t(c.sets) * kLineBytes, o = bank0(2);
      warm(b, v, 60);
      warm(b, o, 61);
      const uint64_t P = b.t;
      b.reqs[P] = {rd(0, 1, n)};
      b.run(P + 3);
      const uint64_t F = b.mlc.back().first + b.mlc_lat;
      // Under B, D = P + 1: both lookups' D is F + 2, after the victim's
      // choice (F + 1); the victim's lookup loses the bank to o's.
      b.reqs[F + 1] = {rd(0, 2, o), rd(1, 3, v)};
      b.run(F + 80);
      const Rsp *r = b.rsp(3);
      if (ctl) {
        EXPECT(r && r->hit && r->line[0] != pat(v, 0), "the control reads the fill's line");
        return;
      }
      EXPECT(b.h.bins["dcu_tag_stale"] == 1 && b.h.bins["dcu_tag_stale_relook"] == 1,
             "marked stale (%llu), looked up again (%llu)",
             (unsigned long long)b.h.bins["dcu_tag_stale"],
             (unsigned long long)b.h.bins["dcu_tag_stale_relook"]);
      EXPECT(r && !r->hit && r->line[0] == pat(v, 0), "a miss, refilled with its own line");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // A late lookup's miss (MA-33): tag-stale's relook misses at its access,
  // cycles past its D, so it waits and retries on port 0, and its slot's
  // next miss (its bank's, MA-34) has the bank's offer to itself.
  // (dcu-late-miss-port, its control, is retired: per bank the two never
  // share a D2; DCU tab rev 148, DI-61.)
  test("late-miss-retry", [&] {
      unsigned retried = 0;
      for (unsigned d = 0; d != 8; ++d) {
        Config c = cfg(9);
        c.ways = 1;
        Bench b(c);
        const uint64_t v = bank0(1), n = v + uint64_t(c.sets) * kLineBytes, o = bank0(2);
        const uint64_t x = bank0(3);   // bank 0, its own set
        warm(b, v, 60);
        warm(b, o, 61);
        const uint64_t P = b.t;
        b.reqs[P] = {rd(0, 1, n)};
        b.run(P + 3);
        const uint64_t F = b.mlc.back().first + b.mlc_lat;
        b.reqs[F + 1] = {rd(0, 2, o), rd(1, 3, v)};
        b.reqs[F + 1 + d].push_back(rd(1, 4, x));
        b.run(F + 120);
        retried += b.h.bins["dcu_late_miss_retry"] != 0;
        {
          EXPECT(b.h.fails.empty(), "d %u: %s", d, b.h.fails.empty() ? "" : b.h.fails[0].c_str());
          EXPECT(b.rsp(2) && b.rsp(3) && b.rsp(4), "d %u: every read answered", d);
          const Rsp *r = b.rsp(3);
          EXPECT(r && !r->hit && r->line[0] == pat(v, 0), "d %u: the relook misses, refilled", d);
        }
      }
      EXPECT(retried == 8, "the late miss retries on port 0: %u of 8", retried);
    });

  // Part 2's controls on one dirty eviction: one way a set, a store makes
  // the line dirty, a read of another line of its set evicts it.
  struct Evict {
    Config c;
    Bench b;
    uint64_t F = 0;
    static Config conf(const char *brk) {
      Config c = cfg(9);
      c.ways = 1;
      if (brk) c.brk = brk;
      return c;
    }
    explicit Evict(const char *brk) : c(conf(brk)), b(c) {
      b.reqs[0] = {st(0, 1, 0x6000, 0, 0x11)};
      b.run(60);
      b.reqs[60] = {rd(0, 2, 0x6000 + uint64_t(c.sets) * kLineBytes)};
      b.run(63);
      F = b.mlc.back().first + b.mlc_lat;
    }
    bool wroteBack() const {
      for (const auto &m : b.mlc)
        if (m.second.op == MlcOp::Write && m.second.pa == 0x6000 && m.second.line[0] == 0x11) return true;
      return false;
    }
  };
  // DI-42: a read of a line just filled, its D0 in the fill's fold write
  // cycle or the next, takes the re-read (late, answered); dcu-ft-margin
  // answers it from the margin's read, refused. Swept over the read's issue.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-ft-margin-control" : "ft-margin-reread", [&] {
      unsigned hits = 0, refusals = 0;
      for (uint64_t t = 1; t < 80; ++t) {
        Config c = cfg(8);   // pipe C: the fold table
        if (ctl) c.brk = "dcu-ft-margin";
        Bench b(c);
        b.reqs[0] = {rd(0, 1, 0x6000)};
        b.reqs[t] = {rd(1, 2, 0x6000)};
        b.run(t + 120);
        if (b.h.bins["dcu_ft_margin_reread"]) {
          ++hits;
          EXPECT(b.rsp(2), "the re-read answers (issue %llu)", (unsigned long long)t);
        }
        if (refused(b, "write margin")) ++refusals;
        else if (!ctl) EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
      }
      if (ctl) EXPECT(refusals >= 1, "the control is refused");
      else EXPECT(hits >= 1 && refusals == 0, "a read in the margin re-read (%u)", hits);
    });
  for (bool ctl : {false, true})
    test(ctl ? "dcu-wb-drop-control" : "wb-sent", [&] {
      Evict e(ctl ? "dcu-wb-drop" : nullptr);
      e.b.run(200);
      EXPECT(e.wroteBack() != ctl, ctl ? "the control drops the line" : "the line written back");
      if (!ctl) EXPECT(e.b.h.fails.empty(), "%s", e.b.h.fails.empty() ? "" : e.b.h.fails[0].c_str());
    });
  for (bool ctl : {false, true})
    test(ctl ? "dcu-wb-early-control" : "wb-read-first", [&] {
      Evict e(ctl ? "dcu-wb-early" : nullptr);
      e.b.run(200);
      if (ctl) {
        EXPECT(refused(e.b, "before its read"), "the control is refused");
        return;
      }
      EXPECT(e.b.h.bins["dcu_fill_wait_victim"] == 1 && e.wroteBack(), "read, then written");
      EXPECT(e.b.h.fails.empty(), "%s", e.b.h.fails.empty() ? "" : e.b.h.fails[0].c_str());
    });
  // A miss to the line in writeback waits for MLC's ack (its own request
  // after the writeback's); dcu-wb-refetch fetches it at once, refused.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-wb-refetch-control" : "wb-then-refetch", [&] {
      Evict e(ctl ? "dcu-wb-refetch" : nullptr);
      e.b.run(e.F + 8);
      e.b.reqs[e.b.t] = {rd(0, 3, 0x6000)};
      e.b.run(e.b.t + 150);
      if (ctl) {
        EXPECT(refused(e.b, "second miss buffer entry"), "the control is refused");
        return;
      }
      EXPECT(e.b.h.bins["dcu_miss_wait_wb"] >= 1, "it waited for the writeback");
      EXPECT(e.b.rsp(3) && e.b.mlc.back().second.op == MlcOp::Read && e.b.mlc.back().second.pa == 0x6000,
             "answered, from a read sent after the writeback");
      EXPECT(e.b.h.fails.empty(), "%s", e.b.h.fails.empty() ? "" : e.b.h.fails[0].c_str());
    });
  // A store hitting the reserved dirty victim waits (miss-wait) and looks
  // up again after the fill's write, then after the writeback's ack;
  // dcu-wb-store lets it write the reserved victim, refused.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-wb-store-control" : "wb-store-waits", [&] {
      Evict e(ctl ? "dcu-wb-store" : nullptr);
      e.b.run(e.F + 3);   // after the victim's read (F+3), before W (F+5)
      e.b.reqs[e.b.t] = {st(0, 3, 0x6000, 1, 0x22)};
      e.b.run(e.b.t + 200);
      if (ctl) {
        EXPECT(!e.b.h.fails.empty(), "the control is refused");
        return;
      }
      EXPECT(e.b.h.bins["dcu_store_rsv_wait"] >= 1, "the store waited");
      EXPECT(e.wroteBack() && e.b.rsp(3), "written back, the store answered");
      EXPECT(e.b.h.fails.empty(), "%s", e.b.h.fails.empty() ? "" : e.b.h.fails[0].c_str());
    });

  // ---- Slice 2, part 3 -----------------------------------------------------

  // An exclusive read (an atomic's A1) misses with AcquireData: an owned,
  // clean line.
  auto excl = [](unsigned slot, unsigned id, uint64_t pa) {
    Req r = rd(slot, id, pa);
    r.op = Op::AtomRead;
    return r;
  };
  auto own = [&](Bench &b, uint64_t pa, unsigned id) {
    b.reqs[b.t].push_back(excl(0, id, pa));
    b.run(b.t + 60);
  };

  // Store hits book their writes at the read: exactly the gap on, at most
  // two a bank between read and write. Three store hits in one bank: reads
  // at R and R+2, the third once the first write is done.
  test("store-hit-bookings", [&] {
    Bench b(cfg(9));
    for (unsigned i = 1; i != 4; ++i) own(b, bank0(i), 60 + i);
    const uint64_t P = b.t;
    b.reqs[P] = {st(0, 1, bank0(1), 0, 1)};
    b.reqs[P + 1] = {st(0, 2, bank0(2), 0, 2)};
    b.reqs[P + 2] = {st(0, 3, bank0(3), 0, 3)};
    b.run(P + 40);
    EXPECT(b.rsp(1) && b.rsp(2) && b.rsp(3) && b.rsp(1)->hit && !b.rsp(1)->data, "three acks, hit, no data");
    EXPECT(b.h.peaks["dcu_store_booked_max"] == 2, "two bookings at most (%llu)",
           (unsigned long long)b.h.peaks["dcu_store_booked_max"]);
    EXPECT(b.h.bins["dcu_store_write"] == 3, "three writes");
    EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
  });

  // A store miss with a load and a store merged behind it (part 3): the
  // fill takes the leading store only, so the load sees it and not the
  // younger store, which looks up again after W. Answers at F+k+4 (k = 1).
  // dcu-st-mergeall merges the younger store too, refused by the CHECK.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-st-mergeall-control" : "fill-merge-leading-stores", [&] {
      Config c = cfg(9);
      if (ctl) c.brk = "dcu-st-mergeall";
      Bench b(c);
      b.reqs[0] = {st(0, 1, 0x2000, 0, 0x11)};
      b.reqs[1] = {rd(1, 2, 0x2000)};
      b.reqs[2] = {st(2, 3, 0x2000, 1, 0x33)};
      b.run(120);
      if (ctl) {
        EXPECT(refused(b, "merged a store behind a load"), "the control is refused");
        return;
      }
      const uint64_t F = b.mlc.empty() ? 0 : b.mlc[0].first + b.mlc_lat;
      EXPECT(b.mlc.size() == 1 && b.mlc[0].second.op == MlcOp::AcquireData, "one AcquireData");
      EXPECT(b.at(1) == F + 5 && b.rsp(1) && !b.rsp(1)->hit && !b.rsp(1)->data,
             "the merged store answered at F+%lld, hit 0, no data", (long long)(b.at(1) - F));
      EXPECT(b.at(2) == F + 5 && b.rsp(2) && b.rsp(2)->line[0] == 0x11 && b.rsp(2)->line[1] == pat(0x2000, 1),
             "the load at F+%lld sees the older store only", (long long)(b.at(2) - F));
      EXPECT(b.rsp(3) && b.h.bins["dcu_st_relook"] == 1, "the younger store looked up again");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // A store hit on a shared line is an upgrade (AcquireData, its own way);
  // dcu-st-shared writes the shared line in place, refused.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-st-shared-control" : "store-upgrade", [&] {
      Config c = cfg(9);
      if (ctl) c.brk = "dcu-st-shared";
      Bench b(c);
      warm(b, 0x2000);   // a read miss: shared
      const size_t n = b.mlc.size();
      b.reqs[b.t] = {st(0, 1, 0x2000, 0, 0x11)};
      b.run(b.t + 60);
      if (ctl) {
        EXPECT(refused(b, "not owned"), "the control is refused");
        return;
      }
      EXPECT(b.mlc.size() == n + 1 && b.mlc.back().second.op == MlcOp::AcquireData, "an upgrade");
      EXPECT(b.h.bins["dcu_upgrade_data"] == 1 && b.h.bins["dcu_evict"] == 0, "its own way, no victim");
      EXPECT(b.rsp(1) != nullptr, "the store answered");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // A store hit's write sets the dirty bit, so the line goes back to MLC at
  // eviction; dcu-st-dirty leaves it clear, and the line is lost.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-st-dirty-control" : "store-sets-dirty", [&] {
      Config c = cfg(9);
      c.ways = 1;
      if (ctl) c.brk = "dcu-st-dirty";
      Bench b(c);
      own(b, 0x6000, 60);
      b.reqs[b.t] = {st(0, 1, 0x6000, 0, 0x11)};
      b.run(b.t + 30);
      b.reqs[b.t] = {rd(0, 2, 0x6000 + uint64_t(c.sets) * kLineBytes)};
      b.run(b.t + 80);
      bool wb = false;
      for (const auto &m : b.mlc) wb |= m.second.op == MlcOp::Write && m.second.pa == 0x6000;
      EXPECT(wb != ctl, ctl ? "the control loses the line" : "the dirty line written back");
      if (!ctl) EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // A load behind a store hit to its line waits for the store's write;
  // dcu-st-noorder lets it read first, refused.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-st-noorder-control" : "load-after-store", [&] {
      Config c = cfg(9);
      if (ctl) c.brk = "dcu-st-noorder";
      Bench b(c);
      own(b, 0x2000, 60);
      const uint64_t P = b.t;
      b.reqs[P] = {st(0, 1, 0x2000, 0, 0x11)};
      b.reqs[P + 1] = {rd(1, 2, 0x2000)};
      b.run(P + 40);
      if (ctl) {
        EXPECT(refused(b, "before an older store's write"), "the control is refused");
        return;
      }
      EXPECT(b.rsp(2) && b.rsp(2)->line[0] == 0x11, "the load sees the store");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // ---- Slice 2, part 4 -----------------------------------------------------

  // A probe's outcomes (part 4's table): an ack carries data iff the line
  // was dirty; an invalidate leaves the line absent (the next read misses),
  // a downgrade leaves it shared (a store then upgrades).
  test("probe-outcomes", [&] {
    Bench b(cfg(9));
    const uint64_t sh = bank0(1), ow = bank0(2), dt = bank0(3), ab = bank0(4), dd = bank0(5);
    warm(b, sh, 60);
    own(b, ow, 61);
    b.reqs[b.t] = {st(0, 62, dt, 0, 0x44)};
    b.run(b.t + 60);
    b.reqs[b.t] = {st(0, 63, dd, 0, 0x55)};
    b.run(b.t + 60);
    uint64_t T = b.t;
    b.probes[T] = Probe{0, sh, true};
    b.probes[T + 1] = Probe{1, ow, false};
    b.probes[T + 2] = Probe{2, dt, true};
    b.probes[T + 3] = Probe{3, ab, true};
    b.run(T + 20);
    b.probes[b.t] = Probe{0, dd, false};
    b.run(b.t + 20);
    EXPECT(b.acks.size() == 5, "five acks (%zu)", b.acks.size());
    for (const auto &a : b.acks) {
      const bool want = (a.second.id == 2 && a.first < T + 20) || (a.second.id == 0 && a.first >= T + 20);
      EXPECT(a.second.data == want, "probe %u's ack %s data", a.second.id, want ? "with" : "without");
      if (want) EXPECT(a.second.line[0] == (a.second.id == 2 ? 0x44 : 0x55), "the dirty line");
    }
    b.reqs[b.t] = {rd(0, 1, sh), rd(1, 2, dt)};   // invalidated: misses
    b.reqs[b.t + 1] = {st(2, 3, ow, 0, 1)};          // downgraded: an upgrade
    b.run(b.t + 80);
    EXPECT(b.rsp(1) && !b.rsp(1)->hit && b.rsp(2) && !b.rsp(2)->hit, "invalidated lines miss");
    EXPECT(b.h.bins["dcu_upgrade_data"] == 1, "a downgraded line's store upgrades");
    EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
  });

  // A probe of a line whose miss is sent and not filled acks at once with no
  // data; one whose fill is in its buffer, not written, waits for W.
  test("probe-vs-miss-buffers", [&] {
    Bench b(cfg(9));
    b.mlc_lat = 30;
    b.reqs[0] = {rd(0, 1, 0x2000)};
    b.probes[10] = Probe{0, 0x2000, true};
    b.run(40);
    EXPECT(b.acks.size() == 1 && b.acks[0].first <= 12 && !b.acks[0].second.data, "acked at once, no data");
    EXPECT(b.h.bins["dcu_prb_ack_sent"] == 1, "against a sent entry");
    const uint64_t F = b.mlc[0].first + b.mlc_lat;
    b.reqs[b.t] = {rd(0, 2, 0x4000)};
    b.run(b.t + 3);
    const uint64_t F2 = b.mlc.back().first + b.mlc_lat;
    b.probes[F2 + 1] = Probe{1, 0x4000, true};
    b.run(F2 + 30);
    EXPECT(b.h.bins["dcu_prb_wait_fill"] == 1 && b.h.bins["dcu_prb_inval_shared"] == 1,
           "waited for W, then invalidated the line");
    (void)F;
    EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
  });

  // A probe waits behind an older store to its line (part 3's order), so the
  // acked store's bytes leave with the ack; dcu-prb-nostore passes it.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-prb-nostore-control" : "probe-behind-store", [&] {
      Config c = cfg(9);
      if (ctl) c.brk = "dcu-prb-nostore";
      Bench b(c);
      own(b, 0x2000, 60);
      const uint64_t P = b.t;
      b.reqs[P] = {st(0, 1, 0x2000, 0, 0x11)};
      b.probes[P + 1] = Probe{0, 0x2000, true};
      b.run(P + 30);
      if (ctl) {
        EXPECT(refused(b, "before an acked store's write"), "the control is refused");
        return;
      }
      EXPECT(b.acks.size() == 1 && b.acks[0].second.data && b.acks[0].second.line[0] == 0x11,
             "the ack carries the store's bytes");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // A probe of a line whose dirty victim's writeback has not launched takes
  // the line from its buffer, with the data, and cancels the writeback, so
  // the line reaches MLC once (AR-409, rev 108); a miss to it then fetches
  // it again. dcu-prb-double sends the writeback too, refused.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-prb-double-control" : "probe-cancels-writeback", [&] {
      Config c = cfg(9);
      c.ways = 1;
      if (ctl) c.brk = "dcu-prb-double";
      Bench b(c);
      b.reqs[0] = {st(0, 1, 0x6000, 0, 0x11)};
      b.run(60);
      const uint64_t y = 0x6000 + uint64_t(c.sets) * kLineBytes;   // same set
      b.reqs[60] = {rd(0, 2, y)};
      while (b.t < 200 && (b.mlc.empty() || b.mlc.back().second.pa != y)) b.run(b.t + 1);
      b.mlc_block = true;   // the victim's writeback waits for a credit
      b.run(b.t + 60);
      EXPECT(b.h.bins["dcu_evict_read"] == 1, "the victim was read");
      const size_t sent = b.mlc.size();
      b.probes[b.t] = Probe{0, 0x6000, true};
      b.run(b.t + 20);
      b.mlc_block = false;
      b.run(b.t + 40);
      if (ctl) {
        EXPECT(refused(b, "sent after a probe took it"), "the control is refused");
        return;
      }
      EXPECT(b.acks.size() == 1 && b.acks[0].second.data && b.acks[0].second.line[0] == 0x11,
             "the ack carries the dirty line");
      EXPECT(b.h.bins["dcu_prb_wb_cancel"] == 1, "the writeback cancelled");
      for (size_t i = sent; i < b.mlc.size(); ++i)
        EXPECT(b.mlc[i].second.pa != 0x6000, "no writeback of the probed line");
      b.reqs[b.t] = {rd(0, 3, 0x6000)};
      b.run(b.t + 80);
      EXPECT(b.rsp(3) && !b.rsp(3)->hit, "the line is fetched again");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // dcu-prb-nodirty acks a dirty line without its data, refused.
  test("dcu-prb-nodirty-control", [&] {
    Config c = cfg(9);
    c.brk = "dcu-prb-nodirty";
    Bench b(c);
    b.reqs[0] = {st(0, 1, 0x2000, 0, 0x11)};
    b.run(60);
    b.probes[b.t] = Probe{0, 0x2000, false};
    b.run(b.t + 20);
    EXPECT(refused(b, "without data for a dirty line"), "the control is refused");
  });

  // dcu-prb-stale: an invalidate leaves the way's fold valid bit set, which
  // the next lookup of its set (pipe C) refuses.
  for (bool ctl : {false, true})
    test(ctl ? "dcu-prb-stale-control" : "probe-clears-fold", [&] {
      Config c = cfg(8);
      if (ctl) c.brk = "dcu-prb-stale";
      Bench b(c);
      warm(b, 0x2000);
      b.probes[b.t] = Probe{0, 0x2000, true};
      b.run(b.t + 20);
      b.reqs[b.t] = {rd(0, 1, 0x2000)};
      b.run(b.t + 60);
      if (ctl) {
        EXPECT(refused(b, "fold valid bit"), "the control is refused");
        return;
      }
      EXPECT(b.rsp(1) && !b.rsp(1)->hit, "a miss after the invalidate");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  // A recovered UE's second answer comes from a fill (part 4).
  // dcu-ue-noanswer drops the refetch; dcu-ue-stale looks the bad line up
  // again: both refused.
  for (const char *ctl : {"", "dcu-ue-noanswer", "dcu-ue-stale"})
    test(*ctl ? ctl : "ue-second-answer", [&] {
      Config c = cfg(9);
      c.ue_every = 1;
      if (*ctl) c.brk = ctl;
      Bench b(c);
      warm(b, 0x7000);
      b.reqs[b.t] = {rd(0, 1, 0x7000)};
      b.run(b.t + 2200);
      if (*ctl) {
        EXPECT(!b.h.fails.empty(), "the control is refused");
        return;
      }
      EXPECT(b.rsp(1) && b.rsp(1)->ue_first, "first answer before the fill");
      EXPECT(b.rspLast(1) && b.rspLast(1)->fid >= 0, "answered from a fill");
      EXPECT(b.h.fails.empty(), "%s", b.h.fails.empty() ? "" : b.h.fails[0].c_str());
    });

  if (g_fail) std::fprintf(stderr, "dcu-test: %d failure(s)\n", g_fail);
  else std::printf("dcu-test: all passed\n");
  return g_fail ? 1 : 0;
}
