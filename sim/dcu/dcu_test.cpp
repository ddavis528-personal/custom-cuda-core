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

#include <cstdio>
#include <cstring>
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
  /// Answer MLC's requests itself, `mlc_lat` cycles after launch.
  bool auto_mlc = true;
  unsigned mlc_lat = 20;
  std::vector<Req> held;   ///< requests the core did not accept yet
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
      Ports p;
      for (unsigned s = 0; s != kSlots; ++s) {
        p.rsp_can[s] = true;
        p.rsp_credits[s] = 8;
        p.ntc_can[s] = true;
      }
      p.mlc_can = true;
      Out o = core.cycle(t, in, f, p);
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

  // A miss: the read goes to MLC; the fill is noticed in its landing cycle F
  // and the refill launches at F + 1 + CCV_LAT_FILL_NOTICE (OA-23).
  test("miss-notice-refill", [] {
    Bench b(cfg(9));
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

  // Holding (TI-22, MA-12): a fifth request to a line whose merge list is
  // full, and a miss with every buffer in use, stall the channel.
  test("hold-merge-full", [] {
    Bench b(cfg(9));
    b.mlc_lat = 40;
    for (unsigned k = 0; k != 6; ++k) b.reqs[k] = {rd(k % 4, k, 0x5000)};
    b.run(5);
    b.run(10);
    EXPECT(!b.core.accepting(), "held with the merge list full");
    b.run(150);
    EXPECT(b.core.accepting() && b.rsp(5), "released after the fill");
  });
  test("hold-buffers-full", [] {
    Bench b(cfg(9));
    b.mlc_lat = 60;
    for (unsigned k = 0; k != 17; ++k) b.reqs[k] = {rd(0, k, 0x10000 + uint64_t(k) * 0x80000)};
    b.run(45);
    EXPECT(!b.core.accepting() && b.h.bins["dcu_buffers_full"], "held with 16 buffers in use");
    b.run(200);
    EXPECT(b.rsp(16) != nullptr, "the 17th answered");
  });

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

  // A UE in a clean line is recovered: invalidated, refetched as a miss.
  test("ue-clean-recover", [] {
    Config c = cfg(9);
    c.ue_every = 1;
    Bench b(c);
    warm(b, 0x7000);
    b.reqs[b.t] = {rd(0, 1, 0x7000)};
    b.run(b.t + 80);
    EXPECT(b.h.bins["ue_recover"] == 1 && b.rsp(1) && !b.rsp(1)->hit, "recovered as a miss");
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

  if (g_fail) std::fprintf(stderr, "dcu-test: %d failure(s)\n", g_fail);
  else std::printf("dcu-test: all passed\n");
  return g_fail ? 1 : 0;
}
