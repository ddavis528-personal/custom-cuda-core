//===-- fill_tb.cpp - dcu_fill bench: fill buffers, encode, answers, free --===//
//
// Drives dcu_fill as its neighbours do: MLC's fills on ccv_mlc_dcu_rsp (the
// valid at F-1, the payload at F) within the channel's 4 credits, which come
// back on the free; dcu_mshr's read of the fill's entry at F+1 (its answer
// count and merge list); the banks' writes of listed buffers (dcu_bctl's
// wdv and wdb, several banks in a cycle); and dcu_rarb's answer takes, in
// any amount up to what a buffer owes.
//
// Checks, every cycle, against a value model of the DCU model's fill
// buffers (sim/dcu/dcu_core.cpp, onFill() and answered()) at the RTL's
// stages (rtl/dcu/dcu_fill.sv's header): the write request at F+1 (valid,
// buffer, ownership), each listed buffer's data, check bits (SECDED over
// 128-bit words, sim/skel/secded.h), list, count, ownership and miss, and
// the free's credit and entry at its cycle.
// --cg <idle|medium|high> <vcd> runs one clock-gating scenario
// (tools/check-cg.py). --control nowait models a buffer freed once written,
// its answers still owed, and --control highest a fill taking the highest
// free buffer; each must fail.
//===----------------------------------------------------------------------===//
#include "Vdcu_fill.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include "secded.h"
#include "../../sim/generated/ccv_params.h"   // the MIU req_id width

#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <optional>
#include <random>
#include <string>
#include <vector>

namespace {

constexpr unsigned kNfb = 4, kBanks = 8, kLd = 4, kWle = ccv::prov::kWReqMiuDcu + 7, kLb = 1024, kNw = 8, kKw = 128,
                   kR = 9, kCw = kNw * kR, kWfb = 2, kWlc = 3, kCr = 4;

int g_argc;
char **g_argv;

template <typename W> void setBit(W &w, unsigned bit, bool v) {
  const uint32_t m = uint32_t(1) << (bit % 32);
  w[bit / 32] = v ? (w[bit / 32] | m) : (w[bit / 32] & ~m);
}
template <typename W> bool getBit(const W &w, unsigned bit) { return (w[bit / 32] >> (bit % 32)) & 1; }
template <typename W> uint64_t getBits(const W &w, unsigned lsb, unsigned width) {
  uint64_t v = 0;
  for (unsigned i = 0; i < width; ++i) v |= uint64_t(getBit(w, lsb + i)) << i;
  return v;
}
template <typename W> void setBits(W &w, unsigned lsb, unsigned width, uint64_t v) {
  for (unsigned i = 0; i < width; ++i) setBit(w, lsb + i, (v >> i) & 1);
}

using Line = std::array<uint32_t, kLb / 32>;

struct Buf {
  bool busy = false, lst = false, wrt = false, own = false, miss = false;
  unsigned rid = 0, cnt = 0;
  uint64_t list = 0;
  Line data{};
  std::array<uint32_t, kNw> chk{};
};

// The value model: the module's state as the DCU model's fill path keeps it,
// at the RTL's cycles.
struct Model {
  std::array<Buf, kNfb> b;
  bool fv_q = false;
  unsigned fsel = 1;   // one hot
  unsigned newq = 0;   // one hot: captured last cycle
  bool wv = false, wown = false;
  unsigned wb = 0;
  bool crv = false, xv = false;
  unsigned xid = 0;
  bool highest = false, nowait = false;
  unsigned frees = 0, fills = 0, fullStalls = 0, multiWrites = 0, freesOwedLater = 0, b2b = 0;
  ccv::skel::Secded sec{kKw};

  unsigned pick(unsigned busyMask) const {
    if (highest) {
      for (int i = kNfb - 1; i >= 0; --i)
        if (!(busyMask >> i & 1)) return 1u << i;
    } else {
      for (unsigned i = 0; i < kNfb; ++i)
        if (!(busyMask >> i & 1)) return 1u << i;
    }
    return 0;
  }
  unsigned busyMask() const {
    unsigned m = 0;
    for (unsigned i = 0; i < kNfb; ++i) m |= unsigned(b[i].busy) << i;
    return m;
  }

  // One edge: inputs of this cycle in, state of the next cycle out.
  void step(bool fv, unsigned frid, const Line &fdata, bool fown, bool fmiss, unsigned fcnt,
            uint64_t flist, const std::array<std::optional<unsigned>, kBanks> &wd,
            const std::array<unsigned, kNfb> &atk) {
    const unsigned take = fv_q ? fsel : 0;
    // The write request's payload at F+2 (DI-39): the buffer captured last
    // cycle and its ownership.
    wv = newq != 0;
    for (unsigned i = 0; i < kNfb; ++i)
      if (newq >> i & 1) {
        wb = i;
        wown = b[i].own;
      }
    unsigned wdone = 0;
    for (const auto &w : wd)
      if (w) wdone |= 1u << *w;
    unsigned ready = 0;
    for (unsigned i = 0; i < kNfb; ++i) {
      const Buf &x = b[i];
      if (x.busy && x.lst && x.wrt && (x.cnt == 0 || nowait)) ready |= 1u << i;
    }
    const unsigned fr = ready & (~ready + 1);
    unsigned fidx = 0;
    for (unsigned i = 0; i < kNfb; ++i)
      if (fr >> i & 1) fidx = i;
    // The encode of the buffer captured last cycle.
    for (unsigned i = 0; i < kNfb; ++i)
      if (newq >> i & 1) {
        Buf &x = b[i];
        for (unsigned w = 0; w < kNw; ++w) {
          ccv::skel::Bits d(kKw);
          for (unsigned k = 0; k < kKw; ++k) d.setBit(k, getBit(x.data, w * kKw + k));
          x.chk[w] = sec.encode(d);
        }
        x.list = flist;
      }
    crv = xv = fr != 0;
    if (fr) {
      xid = b[fidx].rid;
      ++frees;
      if (nowait && b[fidx].cnt) ++freesOwedLater;
    }
    for (unsigned i = 0; i < kNfb; ++i) {
      Buf &x = b[i];
      const bool f = fr >> i & 1;
      const unsigned cn = (newq >> i & 1) ? fcnt : x.cnt - atk[i];
      x.lst = !f && (x.lst || (newq >> i & 1));
      x.wrt = !f && (x.wrt || (wdone >> i & 1));
      x.cnt = cn & 7;
      if (take >> i & 1) {
        x.data = fdata;
        x.rid = frid;
        x.own = fown;
        x.miss = fmiss;
      }
      x.busy = ((x.busy || (take >> i & 1)) && !f);
    }
    newq = take;
    if (take) ++fills;
    if (fv_q && fv) ++b2b;
    fv_q = fv;
    fsel = pick(busyMask());
    if (__builtin_popcount(wdone) > 1) ++multiWrites;
  }
};

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vdcu_fill> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  uint64_t t = 0, cyc = 0;
  unsigned fails = 0, checked = 0;

  explicit Bench(const char *vcd_path) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vdcu_fill>(ctx.get());
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
    dut->fv_cc03h = 0;
    dut->wdv_cc05h = 0;
    dut->atk_cc05h = 0;
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
      std::fprintf(stderr, "fill: cycle %llu: %s\n", (unsigned long long)cyc, what.c_str());
  }
  void expect(bool ok, const std::string &what) {
    ++checked;
    if (!ok) fail(what);
  }
};

int run(const std::string &scenario, const char *vcd, const std::string &ctl, uint64_t seed) {
  Bench b(vcd);
  std::mt19937_64 r(seed);
  auto below = [&](unsigned n) { return unsigned(r() % n); };
  Model m;
  m.highest = ctl == "highest";
  m.nowait = ctl == "nowait";
  b.reset();
  const bool rnd = scenario.empty();
  const unsigned n = rnd ? 40000 : scenario == "idle" ? 3000 : 4000;
  unsigned credits = kCr;
  // The fill whose valid went last cycle (its payload now), and the one
  // captured last cycle (its entry read now).
  struct Pay {
    unsigned rid;
    Line data;
    bool own, miss;
  };
  std::optional<Pay> pay;
  bool readNow = false;
  std::array<bool, kNfb> wreq{};   // a write already sent for the buffer
  unsigned rid_next = 0;
  unsigned cov_takes_before_write = 0, cov_write_before_takes = 0;

  for (uint64_t c = 0; c < n; ++c) {
    // ---- Outputs of this cycle against the model ----------------------------
    auto &d = *b.dut;
    if (m.wv) {
      b.expect(d.wb_cc06h == m.wb, "write request's buffer " + std::to_string(d.wb_cc06h) +
                                       " want " + std::to_string(m.wb));
      b.expect(bool(d.wown_cc06h) == m.wown, "write request's ownership");
    }
    b.expect(bool(d.crv_cc06h) == m.crv, "credit back");
    b.expect(bool(d.xv_cc06h) == m.xv, "entry free");
    if (m.xv) b.expect(d.xid_cc06h == m.xid, "freed entry " + std::to_string(d.xid_cc06h));
    for (unsigned i = 0; i < kNfb; ++i) {
      const Buf &x = m.b[i];
      b.expect(bool(d.bv_cc05h >> i & 1) == x.lst, "buffer " + std::to_string(i) + " listed");
      if (!x.lst) continue;
      b.expect(((d.bcnt_cc05h >> (i * kWlc)) & 7) == x.cnt,
               "buffer " + std::to_string(i) + " owes " + std::to_string((d.bcnt_cc05h >> (i * kWlc)) & 7) +
                   " want " + std::to_string(x.cnt));
      b.expect(getBits(d.blist_cc05h, i * kLd * kWle, kLd * kWle) == x.list, "buffer list");
      b.expect(bool(d.bown_cc05h >> i & 1) == x.own, "buffer ownership");
      b.expect(bool(d.bmiss_cc05h >> i & 1) == x.miss, "buffer miss");
      bool dok = true;
      for (unsigned k = 0; k < kLb / 32; ++k) dok = dok && d.bdata_cc05h[i * (kLb / 32) + k] == x.data[k];
      b.expect(dok, "buffer " + std::to_string(i) + " data");
      bool cok = true;
      for (unsigned w = 0; w < kNw; ++w)
        cok = cok && getBits(d.bchk_cc05h, i * kCw + w * kR, kR) == x.chk[w];
      b.expect(cok, "buffer " + std::to_string(i) + " check bits");
    }
    if (!ctl.empty() && b.fails) break;   // a control has diverged: stop before the RTL's CHECKs
    // The driver reads the DUT's outputs, as dcu_bctl and dcu_rarb do.
    if (d.crv_cc06h) ++credits;
    std::array<bool, kNfb> lst{};
    std::array<unsigned, kNfb> owe{};
    for (unsigned i = 0; i < kNfb; ++i) {
      lst[i] = d.bv_cc05h >> i & 1;
      owe[i] = (d.bcnt_cc05h >> (i * kWlc)) & 7;
      if (!lst[i]) wreq[i] = false;
    }

    // ---- Inputs of this cycle --------------------------------------------------
    const bool on = scenario == "idle"     ? false
                    : scenario == "medium" ? c % 3 == 0
                    : scenario == "high"   ? true
                                           : below(3) == 0;
    b.quiet();
    bool fv = false;
    if (on && credits) {
      fv = true;
      --credits;
    } else if (on) {
      ++m.fullStalls;
    }
    d.fv_cc03h = fv;
    Line fdata{};
    unsigned frid = 0;
    bool fown = false, fmiss = false;
    if (pay) {
      fdata = pay->data;
      frid = pay->rid;
      fown = pay->own;
      fmiss = pay->miss;
    } else if (rnd) {
      // Noise with no fill, in the random runs only: a clock-gating
      // scenario holds its inputs still between fills (CG-3 orders the
      // scenarios by input activity).
      for (auto &w : fdata) w = uint32_t(r());
      frid = below(16);
      fown = r() & 1;
      fmiss = r() & 1;
    }
    for (unsigned k = 0; k < kLb / 32; ++k) d.fdata_cc04h[k] = fdata[k];
    d.frid_cc04h = frid;
    d.fown_cc04h = fown;
    d.fmiss_cc04h = fmiss;
    const unsigned fcnt = readNow ? below(kLd + 1) : below(8);
    uint64_t flist = 0;
    for (unsigned k = 0; k < kLd; ++k) flist |= uint64_t(below(1u << kWle)) << (k * kWle);
    // Each bank's dcu_mshr's read: one bank's carries it, the rest zero.
    const unsigned rbk = below(kBanks);
    d.fcnt_cc05h = fcnt << (rbk * 3);
    for (unsigned k = 0; k < kBanks; ++k) {
      setBits(d.flist_cc05h, k * kLd * kWle, kLd * kWle, k == rbk ? flist : 0);
    }
    // Banks' writes: a listed buffer not yet written, now and then.
    std::array<std::optional<unsigned>, kBanks> wd{};
    unsigned wdv = 0, wdb = 0;
    for (unsigned i = 0; i < kNfb; ++i) {
      if (!lst[i] || wreq[i]) continue;
      const bool go = rnd ? below(4) == 0 : below(2) == 0;
      if (!go) continue;
      unsigned k = below(kBanks);
      while (wd[k]) k = (k + 1) % kBanks;
      wd[k] = i;
      wreq[i] = true;
      wdv |= 1u << k;
      wdb |= i << (k * kWfb);
      if (owe[i]) ++cov_write_before_takes;
    }
    for (unsigned k = 0; k < kBanks; ++k)
      if (!(wdv >> k & 1)) wdb |= below(4) << (k * kWfb);   // noise under no valid
    d.wdv_cc05h = wdv;
    d.wdb_cc05h = wdb;
    // dcu_rarb's takes: up to what a listed buffer owes.
    std::array<unsigned, kNfb> atk{};
    unsigned atkw = 0;
    for (unsigned i = 0; i < kNfb; ++i) {
      if (!lst[i] || !owe[i]) continue;
      const unsigned tk = rnd ? (below(3) == 0 ? below(owe[i] + 1) : 0) : (below(2) == 0 ? 1 : 0);
      atk[i] = tk;
      atkw |= tk << (i * kWlc);
      if (tk && !wreq[i]) ++cov_takes_before_write;
    }
    d.atk_cc05h = atkw;

    m.step(fv, frid, fdata, fown, fmiss, fcnt, flist, wd, atk);
    b.edge();

    // The next cycle's payload and entry read.
    readNow = pay.has_value();
    pay.reset();
    if (fv) {
      Pay p;
      p.rid = rid_next++ % 16;
      for (auto &w : p.data) w = uint32_t(r());
      p.own = r() & 1;
      p.miss = r() & 1;
      pay = p;
    }
  }
  if (rnd && ctl.empty() &&
      (!m.fills || !m.frees || !m.fullStalls || !m.multiWrites || !m.b2b || !cov_takes_before_write ||
       !cov_write_before_takes)) {
    std::fprintf(stderr,
                 "fill: coverage: fills %u frees %u full stalls %u multi-writes %u back-to-back %u "
                 "takes before write %u write before takes %u\n",
                 m.fills, m.frees, m.fullStalls, m.multiWrites, m.b2b, cov_takes_before_write,
                 cov_write_before_takes);
    ++b.fails;
  }
  const std::string tag = ctl.empty() ? ":" : " control " + ctl + ":";
  std::printf("fill%s %s: %llu cycles, %u values checked, %u mismatches: %s\n", tag.c_str(),
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
      if (ctl != "nowait" && ctl != "highest") {
        std::fprintf(stderr, "fill: unknown control %s\n", ctl.c_str());
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
        std::fprintf(stderr, "fill: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl, seed);
}
