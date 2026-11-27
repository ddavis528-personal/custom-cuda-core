//===-- mpick_tb.cpp - dcu_mpick bench: the retry grant and the MLC pick ----===//
//
// Drives dcu_mpick as the 8 banks and MLC do: each bank's dcu_bctl offers
// its oldest miss-wait waiter (a valid and a 10-bit stamp; a bank still
// offers the cycle after its grant, as it learns of it a cycle late) and
// holds its payload in flops; each bank's dcu_mshr offers its oldest unsent
// entry (hv and the 10-bit stamp of its D2, up to 511 cycles old) or, with
// none, a miss its D2 allocates now (sv), and a cycle on the payload of
// what it offered; MLC returns credits for the sends, 3 to 10 cycles on.
//
// Checks, every cycle, against a value model of the DCU model's picks
// (sim/dcu/dcu_core.cpp: retryWaits() and the MLC request in step()) with
// the stamps unwrapped: the retry grant (the oldest offer, ties to the
// lowest bank, last cycle's grant passed over) and its payload at D2; the
// MLC send (the oldest head, ties to the lowest bank, else the lowest bank
// sending straight, the bank sent from last cycle passed over, a credit
// left counting last cycle's send), the bank told of its send, and the
// payload a cycle on (req_id {bank, entry}).
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py). --control retry grants the lowest offering bank, not
// the oldest (DI-35); --control age sends the lowest bank's head, not the
// oldest (DI-64); --control pass sends from the bank sent from last cycle
// (DI-65); --control credit gates on a count that ignores last cycle's send
// (DI-34 update 2); each must fail.
//===----------------------------------------------------------------------===//
#include "Vdcu_mpick.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../../sim/generated/ccv_params.h"   // the req_id widths

#include <algorithm>
#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <optional>
#include <random>
#include <string>
#include <type_traits>
#include <vector>

namespace {

constexpr unsigned kBanks = 8, kCr = 4, kWl = 41, kWts = 10, kWeb = 4;
constexpr unsigned kWi = ccv::prov::kWReqMiuDcu;
constexpr unsigned kStampMask = (1u << kWts) - 1;
constexpr uint64_t kLineMask = (uint64_t(1) << kWl) - 1;

int g_argc;
char **g_argv;

template <typename W> void setBits(W &w, unsigned lsb, unsigned width, uint64_t v) {
  for (unsigned i = 0; i < width; ++i) {
    const unsigned bit = lsb + i, word = bit / 32, off = bit % 32;
    const uint32_t m = uint32_t(1) << off;
    w[word] = (v >> i) & 1 ? (w[word] | m) : (w[word] & ~m);
  }
}
// Any port: an integer one in place, a wide one through its words.
template <typename T> void setInt(T &w, unsigned lsb, unsigned width, uint64_t v) {
  if constexpr (std::is_integral_v<T>) {
    const T m = T(((uint64_t(1) << width) - 1) << lsb);
    w = T((w & ~m) | ((T(v) << lsb) & m));
  } else {
    setBits(w, lsb, width, v);
  }
}

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vdcu_mpick> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;

  explicit Bench(const char *vcd_path) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vdcu_mpick>(ctx.get());
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
    dut->rov_cc02h = 0;
    dut->hv_cc05h = 0;
    dut->sv_cc05h = 0;
    dut->mcr_cc04h = 0;
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
      std::fprintf(stderr, "mpick: cycle %llu: %s\n", (unsigned long long)cyc, what.c_str());
  }
  void expect(bool ok, const std::string &what) {
    ++checked;
    if (!ok) fail(what);
  }
};

struct RPay {   // a retry's payload, as a bank's dcu_bctl holds it
  uint64_t pa = 0;
  unsigned rid = 0, op = 0, fold = 0, sti = 0;
  bool excl = false;
};
struct MPay {   // a miss request's payload, as a bank's dcu_mshr offers it
  unsigned id = 0, coh = 0;
  uint64_t pa = 0;
};

int run(const std::string &scenario, const char *vcd, const std::string &ctl, uint64_t seed) {
  Bench b(vcd);
  std::mt19937_64 r(seed);
  const auto below = [&](unsigned n) { return unsigned(r() % n); };
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 60000 : scenario == "idle" ? 3000 : 4000;

  // Each bank's offers: a retry waiter's stamp, a head's stamp (unwrapped
  // cycles; the RTL sees the low 10 bits).
  std::array<uint64_t, kBanks> rstamp{}, hstamp{};
  std::optional<unsigned> grantPrev, grant2;   // the grants of 1 and 2 cycles back
  std::optional<RPay> rpayPrev;                // the granted bank's payload, captured last cycle
  std::optional<unsigned> sentPrev;            // the bank sent from last cycle
  std::optional<MPay> mpayPrev;                // its payload, captured last cycle
  int cr = kCr;
  bool sentLast = false, creditPrev = false;
  std::vector<uint64_t> credBack;
  unsigned cov_rgrant = 0, cov_rpass = 0, cov_rtie = 0, cov_head = 0, cov_str = 0, cov_mpass = 0,
           cov_crstall = 0, cov_htie = 0, cov_wrap = 0, cov_strlost = 0;
  uint64_t maxAge = 0;

  for (uint64_t c = 0; c < n; ++c) {
    Vdcu_mpick &d = *b.dut;
    b.quiet();
    const bool on = scenario == "idle"     ? false
                    : scenario == "medium" ? c % 3 == 0
                    : scenario == "high"   ? true
                                           : (c / 200) % 3 != 0;
    // ---- The retry: offers now; the grant's payload; the D2 port.
    std::optional<unsigned> rpick;
    for (unsigned bk = 0; bk < kBanks; ++bk) {
      // A bank offers (a new head now and then); the bank granted last
      // cycle still offers, unaware.
      const bool off = (grantPrev && *grantPrev == bk) ? true : on && below(3) != 0;
      if (!off) {
        setInt(d.rstp_cc02h, bk * kWts, kWts, rnd ? below(1024) : 0);
        continue;
      }
      if (!(grantPrev && *grantPrev == bk) && below(4) == 0)
        rstamp[bk] = c - (below(8) == 0 ? below(512) : below(16));   // up to 511 cycles old
      if (rstamp[bk] > c || c - rstamp[bk] > 511) rstamp[bk] = c;
      d.rov_cc02h |= 1u << bk;
      setInt(d.rstp_cc02h, bk * kWts, kWts, rstamp[bk] & kStampMask);
      if (grantPrev && *grantPrev == bk && ctl != "retry") {
        ++cov_rpass;
        continue;
      }
      if (!rpick) {
        rpick = bk;
      } else if (ctl != "retry") {
        if (rstamp[bk] < rstamp[*rpick]) rpick = bk;
        else if (rstamp[bk] == rstamp[*rpick]) ++cov_rtie;
      }
    }
    // Each bank's held payload (the granted one's is captured now).
    std::optional<RPay> rcap;
    for (unsigned bk = 0; bk < kBanks; ++bk) {
      RPay p;
      p.pa = r() & kLineMask;
      p.rid = below(1u << kWi);
      p.op = below(3);
      p.fold = below(16);
      p.sti = below(16);
      p.excl = r() & 1;
      setInt(d.rpa_cc03h, bk * kWl, kWl, p.pa);
      setInt(d.rrid_cc03h, bk * kWi, kWi, p.rid);
      setInt(d.rop_cc03h, bk * 2, 2, p.op);
      setInt(d.rexcl_cc03h, bk, 1, p.excl);
      setInt(d.rfold_cc03h, bk * 4, 4, p.fold);
      setInt(d.rsti_cc03h, bk * 4, 4, p.sti);
      if (grantPrev && *grantPrev == bk) rcap = p;
    }

    // ---- The MLC request: each bank's offer, then the pick.
    std::array<bool, kBanks> hv{}, sv{};
    for (unsigned bk = 0; bk < kBanks; ++bk) {
      if (on && below(3) == 0) {
        hv[bk] = true;
        if (below(3) == 0) hstamp[bk] = c - 1 - (below(10) == 0 ? below(511) : below(20));
        if (hstamp[bk] >= c || c - hstamp[bk] > 511) hstamp[bk] = c - 1;
        d.hv_cc05h |= 1u << bk;
        maxAge = std::max(maxAge, c - hstamp[bk]);
      } else if (on && below(4) == 0) {
        sv[bk] = true;
        d.sv_cc05h |= 1u << bk;
      }
      setInt(d.hstp_cc05h, bk * kWts, kWts, hv[bk] || rnd ? hstamp[bk] & kStampMask : 0);
    }
    std::optional<unsigned> hpick, spick;
    bool anyHead = false;
    for (unsigned bk = 0; bk < kBanks; ++bk) {
      const bool passed = sentPrev && *sentPrev == bk && ctl != "pass";
      if (passed && (hv[bk] || sv[bk])) ++cov_mpass;
      if (passed) continue;
      if (hv[bk]) {
        anyHead = true;
        if (!hpick) {
          hpick = bk;
        } else if (ctl != "age") {
          if (hstamp[bk] < hstamp[*hpick]) hpick = bk;
          else if (hstamp[bk] == hstamp[*hpick]) ++cov_htie;
        }
      }
      if (sv[bk] && !spick) spick = bk;
    }
    const std::optional<unsigned> mpick = anyHead ? hpick : spick;
    if (anyHead && spick) ++cov_strlost;
    // A credit left: last cycle's send counted (--control credit: not).
    const int crg = cr + (ctl == "credit" && sentLast ? 1 : 0);
    const bool send = mpick && crg > 0;
    if (mpick && crg <= 0) ++cov_crstall;
    if (send) (anyHead ? cov_head : cov_str)++;
    if (send && c - hstamp[*mpick] > 0 && (hstamp[*mpick] & kStampMask) > (c & kStampMask)) ++cov_wrap;
    // Each bank's payload of what it offered last cycle (the sent one's is
    // captured now).
    std::optional<MPay> mcap;
    for (unsigned bk = 0; bk < kBanks; ++bk) {
      MPay p;
      p.id = below(16);
      p.pa = r() & kLineMask;
      p.coh = below(16);
      setInt(d.pid_cc05h, bk * kWeb, kWeb, p.id);
      setInt(d.ppa_cc05h, bk * kWl, kWl, p.pa);
      setInt(d.pcoh_cc05h, bk * 4, 4, p.coh);
      if (sentPrev && *sentPrev == bk) mcap = p;
    }
    // MLC's credits.
    bool credit = false;
    for (size_t i = 0; i < credBack.size(); ++i)
      if (credBack[i] <= c) {
        credBack.erase(credBack.begin() + long(i));
        credit = true;
        break;
      }
    d.mcr_cc04h = credit;

    if (!ctl.empty() && b.fails) break;
    b.edge();
    // The grant, the retry at D2, the send, the bank told, the payload.
    b.expect(bool(d.rgv_cc03h) == bool(rpick), "retry grant valid");
    if (rpick) b.expect(d.rgb_cc03h == *rpick, "retry grant bank");
    b.expect(d.rv_cc04h == (rcap ? 1u << *grantPrev : 0u), "retry at D2: bank");
    if (rcap) {
      b.expect(uint64_t(d.rpa_cc04h) == rcap->pa, "retry at D2: line");
      b.expect(d.rrid_cc04h == rcap->rid, "retry at D2: req_id");
      b.expect(d.rop_cc04h == rcap->op, "retry at D2: op");
      b.expect(bool(d.rexcl_cc04h) == rcap->excl, "retry at D2: exclusive");
      b.expect(d.rfold_cc04h == rcap->fold, "retry at D2: fold");
      b.expect(d.rsti_cc04h == rcap->sti, "retry at D2: store-data index");
      ++cov_rgrant;
    }
    b.expect(bool(d.mv_cc05h) == send, send ? "should send" : "should not send");
    b.expect(d.snt_cc05h == (send ? 1u << *mpick : 0u), "the bank told of its send");
    if (mcap) {
      b.expect(d.mrid_cc06h == ((*sentPrev << kWeb) | mcap->id), "request req_id");
      b.expect(uint64_t(d.mpa_cc06h) == (mcap->pa << 7), "request PA");
      b.expect(d.mcoh_cc06h == mcap->coh, "request coh_op");
      b.expect(d.mcid_cc06h == 0, "request core_id");
    }
    cr = cr - (send ? 1 : 0) + (creditPrev ? 1 : 0);
    creditPrev = credit;
    sentLast = send;
    if (send) credBack.push_back(c + 3 + below(8));
    grant2 = grantPrev;
    grantPrev = rpick;
    sentPrev = send ? mpick : std::nullopt;
    (void)rpayPrev;
    (void)mpayPrev;
  }
  if (rnd && (!cov_rgrant || !cov_rpass || !cov_rtie || !cov_head || !cov_str || !cov_mpass ||
              !cov_crstall || !cov_htie || !cov_wrap || !cov_strlost || maxAge < 500)) {
    std::fprintf(stderr,
                 "mpick: coverage: retries %u passed %u ties %u; sends head %u straight %u passed %u "
                 "credit stalls %u head ties %u wrapped %u straight lost %u oldest %llu\n",
                 cov_rgrant, cov_rpass, cov_rtie, cov_head, cov_str, cov_mpass, cov_crstall, cov_htie,
                 cov_wrap, cov_strlost, (unsigned long long)maxAge);
    if (ctl.empty()) ++b.fails;
  }
  (void)grant2;
  const std::string tag = ctl.empty() ? ":" : " control " + ctl + ":";
  std::printf("mpick%s %s: %llu cycles, %u values checked, %u mismatches: %s\n", tag.c_str(),
              rnd ? "random" : scenario.c_str(), (unsigned long long)b.cyc, b.checked, b.fails,
              b.fails ? "FAIL" : "PASS");
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
      if (ctl != "retry" && ctl != "age" && ctl != "pass" && ctl != "credit") {
        std::fprintf(stderr, "mpick: unknown control %s\n", ctl.c_str());
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
        std::fprintf(stderr, "mpick: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl, seed);
}
