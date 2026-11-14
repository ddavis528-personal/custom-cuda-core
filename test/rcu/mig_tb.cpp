//===-- mig_tb.cpp - rcu_mig against the Migration tab --------------------===//
//
// Drives rtl/rcu/rcu_mig.sv inside a model of everything around it and
// checks what crosses its ports, every cycle, against the Migration tab:
//   - OOE (ooe_rcu_map) and RAU (rau_rcu_mig) send each migration's map and
//     command in either order, under the pairing queues' credits;
//   - PCA sends each restore's 17 rows in order, one warp after another in
//     RAU's order, under rcu_pca_mig's credits, and receives demotion rows,
//     stalling at random and returning credits after a random delay;
//   - the R slot issues at random, its op reading R2 and writing a GPR at
//     random (the decode rcu_mig sees);
//   - the register file's R2 and RW ports select the R op over migration as
//     rcu_bank_slice does, and return junk to a read that had no lead or
//     lost R2 to the R op; D0-D3 and PG0-PG3 likewise.
// Checks: rows sent 0..16 per demotion with the register file's live data,
// one demotion at a time, never a valid after a stall, never past the
// receiver's credits, a wake WL cycles before every valid; every restore row
// written once, in order, with PCA's data, to its map's row, never on RW in
// a cycle the R op holds it, never without the lead, row 16 last on PG, and
// then the whole map holds the restore; a kill stops its warp's transfers
// within the tab's cycles and quiet rises; every credit returns; busy is
// low only with nothing held.
//
// M5 (docs/rcu-impl.md, phase 4): with the R slot busy 3 cycles of every 4,
// every op reading R2 and writing a GPR (OOE's idle-R rule at K = 4, its
// worst phase of the four), the 17 rows of a demotion and of a restore each
// take at most 68 cycles counted from c1, the cycle after the launch edge
// (Migration tab, Launch: c0 the launch edge; RA rev 138, rev 140 (2)). c1
// is read from the launch's own credit: launch sets the map and command
// credit-return flops, so their credit is on the wire in c1; a demotion's
// wake is high from c1 too (Wake lead), which the measure checks.
//
// Runs: M5, then random traffic with kills (--seed n picks another run). --cg <idle|medium|high> <vcd>
// runs one clock-gating scenario (tools/check-cg.py). Negative controls,
// each of which must fail (test/rcu/run-rtl.sh): --control rlie tells the
// module the R op never holds R2 or RW while the ports still give it them;
// --control cred gives the receiver one credit fewer than CCV_CREDIT_DEPTH;
// --control wake checks the wake WL + 1 cycles before each valid;
// --control stall2 shows the module each stall a cycle late, so two rows
// follow it.
//===----------------------------------------------------------------------===//
#include "Vrcu_mig.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <array>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <deque>
#include <memory>
#include <random>
#include <string>
#include <type_traits>
#include <vector>

#include "ccv_params.h"
#include "cls_pack.h"
#include "dec_tb.h"

namespace {

constexpr unsigned kQ = ccv::kTier1Warps, kCD = ccv::kCreditDepth, kNG = ccv::kGprs,
                   kNP = ccv::kPreds, kWL = ccv::kWakeLat, kWR = ccv::prov::kWPhysReg,
                   kWP = ccv::prov::kWPhysPred, kNW = ccv::kTier1Warps + ccv::kParkedWarps;
constexpr unsigned kZR = ccv::prov::kPhysZero, kZP = ccv::prov::kPredZero;
constexpr unsigned kNPR = ccv::prov::kPhysRegs, kNPP = ccv::prov::kPredRegs;
constexpr unsigned kWords = ccv::kWData / 32, kNR = kNG + 1;
constexpr uint32_t kJunk = 0xBAD0BAD0u;

using Row = std::array<uint32_t, kWords>;

template <typename T> void put(T &s, unsigned lsb, unsigned w, uint64_t v) {
  for (unsigned i = 0; i < w; ++i) {
    const unsigned b = lsb + i;
    const uint64_t bit = (v >> i) & 1u;
    if constexpr (std::is_integral_v<T>) {
      s = T((s & ~(T(1) << b)) | (T(bit) << b));
    } else {
      s[b / 32] = (s[b / 32] & ~(1u << (b % 32))) | (uint32_t(bit) << (b % 32));
    }
  }
}
template <typename T> uint64_t get(const T &s, unsigned lsb, unsigned w) {
  uint64_t v = 0;
  for (unsigned i = 0; i < w; ++i) {
    const unsigned b = lsb + i;
    uint64_t bit;
    if constexpr (std::is_integral_v<T>) bit = (uint64_t(s) >> b) & 1u;
    else bit = (s[b / 32] >> (b % 32)) & 1u;
    v |= bit << i;
  }
  return v;
}

int g_argc;
char **g_argv;
uint64_t g_dbg0 = ~0ull, g_dbg1 = 0;   // MIG_DBG=from,to: a trace of those cycles
unsigned g_seed = 0x316u;

struct Mig {
  unsigned warp = 0;
  bool restore = false;
  std::array<unsigned, kNG> g{};
  std::array<unsigned, kNP> p{};
  std::array<Row, kNR> data{};   // a restore's rows, PCA's
  bool done = false, killed = false;
  uint64_t kcyc = 0;             // K, the cycle the kill's mask is on the wire
  unsigned next = 0;             // demotion: next row out; restore: next row written
  unsigned pca_next = 0;         // restore: next row PCA sends
  bool map_sent = false, cmd_sent = false, map_first = false;
  uint64_t map_ok = ~0ull;       // a map-first warp: rows and the command from here
  unsigned pca_extra = 0;        // rows PCA still sends past a kill
};

struct RSlot {
  bool v = false, r2 = false, rw = false;
};

struct Samp {   // one cycle's outputs
  bool r2v = false, rwv = false, rwsel = false, gv = false, owk = false, ov = false;
  bool mcr = false, ccr = false, pcr = false, quiet = false, busy = false;
  unsigned r2row = 0, rwrow = 0, dv = 0, drow = 0, grow = 0, ow = 0, orow = 0;
  Row odat{}, rwdat{};
  std::array<uint32_t, kNP> gdat{};
};

enum class Ctl { none, rlie, cred, wake, stall2 };

struct Cfg {
  double pnew = 0.3, psend = 0.6, pr = 0.5, pr2 = 0.6, prw = 0.6, pstall = 0.1, pkill = 0.004;
  unsigned cdelay = 6;   // the receiver's credit delay, 1..cdelay
  int rpattern = -1;     // >= 0: the M5 R pattern at this phase (busy 3 of 4, R2 and RW held)
  bool junk = true;      // drive junk on idle payload inputs
  unsigned pca_delay = 2;   // PCA's first row of a restore, cycles after its command may go
};

struct Bench {
  std::unique_ptr<VerilatedContext> ctx;
  std::unique_ptr<Vrcu_mig> dut;
  std::unique_ptr<VerilatedVcdC> vcd;
  std::mt19937_64 rng;
  Cfg cfg;
  Ctl ctl;
  uint64_t t = 0, simt = 0;
  unsigned fails = 0;
  uint64_t checked = 0;
  // The world.
  std::vector<Row> prf;
  std::vector<uint32_t> pf;
  std::vector<bool> row_used, pred_used;
  std::vector<Mig> migs;
  std::array<bool, kNW> warp_live{}, sticky{};
  std::deque<int> mapq, cmdq, pcaq;
  std::array<uint64_t, 4096> ready{};   // per mig: its map/command may go from here
  unsigned mcred = kQ, ccred = kQ, pcred = kCD, ocred = kCD;
  int mout = 0, cout = 0, pout = 0;     // sent, not yet credited
  int mpay = -1, cpay = -1, ppay = -1;  // a payload due this cycle
  bool mnow = false, cnow = false, pnow = false;   // a valid this cycle
  bool mlast = false, clast = false, plast = false;   // and last cycle's: captured, busy a cycle on
  unsigned ppay_row = 0;
  std::deque<uint64_t> ocr_due;
  int cur_dm = -1;
  // A kill: K, its mask, whether quiet has risen since K + 2.
  bool kpend = false, kquiet = true;
  uint64_t kK = 0, last_kill = 0;
  uint32_t kmask = 0;
  // History.
  std::array<Samp, 8> hs{};
  std::array<RSlot, 8> rs{};
  std::array<bool, 8> stall{};
  // Coverage and M5 marks.
  unsigned dm_done = 0, rs_done = 0, kills = 0, dm_killed = 0, rs_killed = 0, held = 0, stalls = 0;
  uint64_t t_wake = 0, t_v16 = 0, t_land0 = 0, t_gv = 0, t_c1 = 0;
  bool rst_now = false, rst_q = false;

  Bench(const char *vcd_path, unsigned seed, Ctl c) : rng(seed), ctl(c) {
    ctx = std::make_unique<VerilatedContext>();
    ctx->commandArgs(g_argc, g_argv);
    if (vcd_path) ctx->traceEverOn(true);
    dut = std::make_unique<Vrcu_mig>(ctx.get());
    if (vcd_path) {
      vcd = std::make_unique<VerilatedVcdC>();
      dut->trace(vcd.get(), 99);
      vcd->open(vcd_path);
    }
    prf.resize(1u << kWR);
    for (auto &r : prf)
      for (auto &w : r) w = uint32_t(rng());
    prf[kZR].fill(0);
    pf.resize(1u << kWP);
    for (auto &w : pf) w = uint32_t(rng());
    pf[kZP] = 0;
    row_used.assign(kNPR, false);
    pred_used.assign(kNPP, false);
    if (ctl == Ctl::cred) ocred = kCD - 1;
  }
  ~Bench() {
    if (vcd) vcd->close();
    dut->final();
  }
  bool coin(double p) { return std::uniform_real_distribution<double>(0, 1)(rng) < p; }
  unsigned pick(unsigned n) { return unsigned(rng() % n); }
  void eval() {
    dut->eval();
    if (vcd) vcd->dump(simt);
    simt += 5;
  }
  void err(const char *what, uint64_t got = 0, uint64_t want = 0) {
    if (++fails <= 20)
      std::fprintf(stderr, "mig: cycle %llu: %s (%llx, want %llx)\n", (unsigned long long)t, what,
                   (unsigned long long)got, (unsigned long long)want);
  }
  void chk(const char *what, uint64_t got, uint64_t want) {
    ++checked;
    if (got != want) err(what, got, want);
  }
  void chkrow(const char *what, const Row &got, const Row &want, unsigned words = kWords) {
    ++checked;
    for (unsigned i = 0; i < words; ++i)
      if (got[i] != want[i]) {
        err(what, got[i], want[i]);
        return;
      }
  }

  // ---- The world's traffic --------------------------------------------------
  int live() const {
    int n = 0;
    for (const auto &m : migs) n += !m.done;
    return n;
  }
  unsigned free_row() {
    for (;;) {
      const unsigned r = pick(kNPR);
      if (!row_used[r]) {
        row_used[r] = true;
        return r;
      }
    }
  }
  unsigned free_pred() {
    for (;;) {
      const unsigned r = pick(kNPP);
      if (!pred_used[r]) {
        pred_used[r] = true;
        return r;
      }
    }
  }
  int new_mig(int dir = -1) {
    std::vector<unsigned> ws;
    for (unsigned w = 0; w < kNW; ++w)
      if (!warp_live[w] && !(kpend && ((kmask >> w) & 1u)))   // RAU starts nothing for a warp being killed
        ws.push_back(w);
    if (ws.empty() || migs.size() >= ready.size()) return -1;
    Mig m;
    m.warp = ws[pick(unsigned(ws.size()))];
    m.restore = dir < 0 ? coin(0.5) : dir == 1;
    for (unsigned a = 0; a < kNG; ++a)   // a demotion map may name the zero register
      m.g[a] = !m.restore && coin(0.1) ? kZR : free_row();
    for (unsigned q = 0; q < kNP; ++q) m.p[q] = !m.restore && coin(0.1) ? kZP : free_pred();
    if (m.restore)
      for (auto &r : m.data)
        for (auto &w : r) w = uint32_t(rng());
    m.map_first = sticky[m.warp];
    warp_live[m.warp] = true;
    const int id = int(migs.size());
    if (t + 200 >= g_dbg0 && t <= g_dbg1)
      std::fprintf(stderr, "%6llu new mig %d warp %u %s%s\n", (unsigned long long)t, id, m.warp,
                   m.restore ? "restore" : "demotion", m.map_first ? " map-first" : "");
    migs.push_back(m);
    ready[id] = t + pick(6);
    mapq.push_back(id);
    cmdq.push_back(id);
    if (m.restore) pcaq.push_back(id);
    return id;
  }
  void release(Mig &m) {
    for (unsigned a = 0; a < kNG; ++a)
      if (m.g[a] != kZR) row_used[m.g[a]] = false;
    for (unsigned q = 0; q < kNP; ++q)
      if (m.p[q] != kZP) pred_used[m.p[q]] = false;
    m.done = true;
    warp_live[m.warp] = false;
  }
  bool stopped(const Mig &m) const { return m.killed && t >= m.kcyc; }

  // An R opcode and merge_en with this R2 and RW use: R2 needs a GPR
  // destination (so RW too); RW without R2 is a GPR write without merge or a
  // collective with none.
  void rOp(const RSlot &r, unsigned &opc, bool &mrg) {
    using dectb::R::Unit;
    auto isR = [](const dectb::R::OpClass &oc) { return oc.unit == Unit::ROnly || oc.unit == Unit::Coll; };
    static const dectb::OpPool gd("an R op writing a GPR", 0, [&](const dectb::R::OpClass &oc) { return isR(oc) && oc.gdst; });
    static const dectb::OpPool cl("a collective writing no GPR", 0, [&](const dectb::R::OpClass &oc) { return oc.unit == Unit::Coll && !oc.gdst; });
    static const dectb::OpPool no("an R-only op writing no GPR", 0, [&](const dectb::R::OpClass &oc) { return oc.unit == Unit::ROnly && !oc.gdst; });
    if (r.r2) { opc = gd.pick(rng); mrg = true; return; }
    if (r.rw) {
      if (coin(0.5)) { opc = gd.pick(rng); mrg = false; } else { opc = cl.pick(rng); mrg = coin(0.5); }
      return;
    }
    opc = no.pick(rng); mrg = coin(0.5);
  }

  RSlot gen_r(uint64_t c) {
    RSlot r;
    if (cfg.rpattern >= 0) {
      r.v = (c + unsigned(cfg.rpattern)) % 4 != 0;
      r.r2 = r.rw = true;
    } else {
      r.v = coin(cfg.pr);
      r.r2 = coin(cfg.pr2);
      r.rw = r.r2 || coin(cfg.prw);   // R2 is read only by a GPR write
    }
    return r;
  }

  // ---- One cycle --------------------------------------------------------------
  void step(bool rst = false) {
    // Nothing is sent while the module's flopped reset (RST-1) still holds.
    rst_now = rst || rst_q;
    rst_q = rst;
    const Samp &p1 = hs[(t + 7) % 8], &p2 = hs[(t + 6) % 8];
    // The R slot: the lead for t+1, the decode of t's op.
    rs[(t + 1) % 8] = rst ? RSlot{} : gen_r(t + 1);
    const RSlot &rc = rs[t % 8], &rn = rs[(t + 1) % 8];
    dut->riv_cr01h = rn.v;
    const bool lie = ctl == Ctl::rlie;
    // The R op as an opcode and merge_en the model's decode makes its R2 and
    // RW use (test/rcu/dec_tb.h); rlie sends one that uses neither.
    unsigned ropc;
    bool rmrg;
    rOp(lie ? RSlot{true, false, false} : rc.v ? rc : RSlot{cfg.junk && coin(0.5), coin(0.5), coin(0.5)},
        ropc, rmrg);
    if (!rc.v && !cfg.junk) ropc = 0, rmrg = false;
    dut->rcls_cr02h = uint32_t(clspack::clsWord(ropc, 0, false));   // rcu_isd's (RA-43, RI-25)
    dut->rmrg_cr02h = rmrg;

    // A kill: kill_v_q in K (ccv_rcu's kill detector flops the valid of
    // K-1; RA rev 127), the mask in K+1 (the detector's mask flop, AR 338).
    dut->kv_cr01h = 0;
    dut->kmn_cr02h = cfg.junk ? uint32_t(rng()) : 0;
    if (kpend && t == kK + 1) dut->kmn_cr02h = kmask;
    if (!rst_now && !kpend && cfg.pkill > 0 && t > last_kill + 40 && coin(cfg.pkill)) start_kill();
    if (kpend && t == kK) dut->kv_cr01h = 1;

    // New migrations, at most CCV_TIER1_WARPS live (RAU's bound).
    if (!rst_now && live() < int(kQ) && coin(cfg.pnew)) new_mig();

    // Payloads due (valids last cycle), then this cycle's valids.
    drive_map();
    drive_cmd();
    drive_pca();

    // The receiver: stall and credits.
    stall[t % 8] = !rst && coin(cfg.pstall);
    // --control stall2: the module sees each stall a cycle late, so a second
    // row can follow it, which the check above must catch.
    dut->ost_cr02h = ctl == Ctl::stall2 ? stall[(t + 7) % 8] : stall[t % 8];
    dut->ocr_cr01h = 0;
    if (!ocr_due.empty() && ocr_due.front() <= t) {
      ocr_due.pop_front();
      dut->ocr_cr01h = 1;
      ++ocred;
    }

    // The register file's R2 and D reads, a cycle after the row.
    const RSlot &ra1 = rs[(t + 7) % 8];
    for (unsigned i = 0; i < kWords; ++i) dut->rd2_cr03h[i] = kJunk ^ i;
    if (ra1.v && ra1.r2) {
      for (unsigned i = 0; i < kWords; ++i) dut->rd2_cr03h[i] = uint32_t(rng());   // the R op's row
    } else if (p2.r2v) {
      const Row &r = prf[p1.r2row];
      for (unsigned i = 0; i < kWords; ++i) dut->rd2_cr03h[i] = r[i];
    }
    for (unsigned q = 0; q < kNP; ++q) {
      uint32_t v = kJunk;
      if ((p2.dv >> q) & 1u) v = pf[(p1.drow >> (kWP * q)) & ((1u << kWP) - 1)];
      dut->dq_cr03h[q] = v;
    }

    // Evaluate, sample.
    dut->rst_n = !rst;
    dut->rcu_core_clk = 0;
    eval();
    Samp &s = hs[t % 8];
    sample(s);
    if (t >= g_dbg0 && t <= g_dbg1) dbg(s);
    if (!rst) check(s, p1, p2);
    dut->rcu_core_clk = 1;
    eval();
    ++t;
  }

  void start_kill() {
    uint32_t mask = 0;
    std::vector<int> cand;
    for (int i = 0; i < int(migs.size()); ++i)
      if (!migs[i].done && !migs[i].killed) cand.push_back(i);
    for (int n = 0; n < 2 && !cand.empty(); ++n)
      if (n == 0 || coin(0.3)) mask |= 1u << migs[cand[pick(unsigned(cand.size()))]].warp;
    if (coin(0.3)) mask |= 1u << pick(kNW);
    if (!mask) return;
    kpend = true;
    kquiet = false;
    kK = t + 1;
    last_kill = t;
    kmask = mask;
    ++kills;
    if (t + 200 >= g_dbg0 && t <= g_dbg1)
      std::fprintf(stderr, "%6llu kill K=%llu mask %x\n", (unsigned long long)t, (unsigned long long)kK, mask);
    for (auto &m : migs)
      if (!m.done && ((mask >> m.warp) & 1u)) {
        m.killed = true;
        m.kcyc = kK;
        m.pca_extra = pick(4);
        (m.restore ? rs_killed : dm_killed) += m.restore ? (m.pca_next > 0) : (m.next > 0);
      }
    for (unsigned w = 0; w < kNW; ++w)
      if ((mask >> w) & 1u) sticky[w] = true;
  }

  void drive_map() {
    if (mpay >= 0) {
      const Mig &m = migs[mpay];
      dut->mw_cr01h = m.warp;
      dut->md_cr01h = m.restore;
      for (unsigned a = 0; a < kNG; ++a) put(dut->mg_cr01h, kWR * a, kWR, m.g[a]);
      uint32_t pm = 0;
      for (unsigned q = 0; q < kNP; ++q) put(pm, kWP * q, kWP, m.p[q]);
      dut->mp_cr01h = pm;
    } else if (cfg.junk) {
      dut->mw_cr01h = pick(32);
      dut->md_cr01h = coin(0.5);
    }
    mpay = -1;
    mlast = mnow;
    mnow = false;
    dut->mv_cr00h = 0;
    while (!mapq.empty() && stopped(migs[mapq.front()])) mapq.pop_front();
    if (rst_now || mapq.empty() || !mcred || !coin(cfg.psend)) return;
    const int id = mapq.front();
    if (ready[id] > t) return;
    Mig &m = migs[id];
    mapq.pop_front();
    dut->mv_cr00h = 1;
    mpay = id;
    mnow = true;
    --mcred;
    ++mout;
    m.map_sent = true;
    m.map_ok = t + 2;   // lands at the edge ending t+1; kmask clears two cycles on (RI)
    if (m.map_first && !m.killed) sticky[m.warp] = false;   // a kill in K wins the landing edge
  }
  void drive_cmd() {
    if (cpay >= 0) {
      dut->cw_cr01h = migs[cpay].warp;
      dut->cd_cr01h = migs[cpay].restore;
    } else if (cfg.junk) {
      dut->cw_cr01h = pick(32);
      dut->cd_cr01h = coin(0.5);
    }
    cpay = -1;
    clast = cnow;
    cnow = false;
    dut->cv_cr00h = 0;
    while (!cmdq.empty() && stopped(migs[cmdq.front()])) cmdq.pop_front();
    if (rst_now || cmdq.empty() || !ccred || !coin(cfg.psend)) return;
    const int id = cmdq.front();
    Mig &m = migs[id];
    // A relaunched warp's command may land before its map or in kmask's lag
    // (RA, re:RI-19): only its PCA rows wait for the map.
    if (ready[id] > t) return;
    cmdq.pop_front();
    dut->cv_cr00h = 1;
    cpay = id;
    cnow = true;
    --ccred;
    ++cout;
    m.cmd_sent = true;
  }
  void drive_pca() {
    if (ppay >= 0) {
      const Mig &m = migs[ppay];
      dut->pw_cr01h = m.warp;
      dut->prow_cr01h = ppay_row;
      const Row &r = m.data[ppay_row];
      for (unsigned i = 0; i < kWords; ++i) dut->pdat_cr01h[i] = r[i];
      if (!t_land0) t_land0 = t;
    }
    ppay = -1;
    plast = pnow;
    pnow = false;
    dut->pv_cr00h = 0;
    // A killed restore's rows stop a few cycles past K.
    while (!pcaq.empty()) {
      const Mig &m = migs[pcaq.front()];
      if (m.pca_next >= kNR || (m.killed && t > m.kcyc + m.pca_extra)) pcaq.pop_front();
      else break;
    }
    if (rst_now || pcaq.empty() || !pcred || !coin(cfg.psend)) return;
    const int id = pcaq.front();
    Mig &m = migs[id];
    if (ready[id] + cfg.pca_delay > t || (m.map_first && m.map_ok > t)) return;
    dut->pv_cr00h = 1;
    ppay = id;
    ppay_row = m.pca_next++;
    pnow = true;
    --pcred;
    ++pout;
  }

  void dbg(const Samp &s) {
    std::fprintf(stderr, "%6llu R%d%d%d mv%d/%u cv%d/%u pv%d/%u.%u kv%d km%x | r2v%d gv%d rwsel%d/%u ov%d owk%d %u.%u mcr%d ccr%d pcr%d q%d b%d\n",
                 (unsigned long long)t, rs[t % 8].v, rs[t % 8].r2, rs[t % 8].rw, dut->mv_cr00h,
                 mpay >= 0 ? migs[mpay].warp : 99, dut->cv_cr00h, cpay >= 0 ? migs[cpay].warp : 99,
                 dut->pv_cr00h, ppay >= 0 ? migs[ppay].warp : 99, ppay_row, dut->kv_cr01h, dut->kmn_cr02h,
                 s.r2v, s.gv, s.rwsel, s.rwrow, s.ov, s.owk, s.ow, s.orow, s.mcr, s.ccr, s.pcr, s.quiet, s.busy);
  }
  void sample(Samp &s) {
    s.r2v = dut->r2v_cr01h;
    s.r2row = dut->r2row_cr02h;
    s.dv = dut->dv_cr01h;
    s.drow = dut->drow_cr02h;
    s.rwv = dut->rwv_cr02h;
    s.rwsel = dut->rwsel_cr03h;
    s.rwrow = dut->rwrow_cr03h;
    s.gv = dut->gv_cr02h;
    s.grow = dut->grow_cr03h;
    s.owk = dut->owk_cr03h;
    s.ov = dut->ov_cr03h;
    s.ow = dut->ow_cr04h;
    s.orow = dut->orow_cr04h;
    for (unsigned i = 0; i < kWords; ++i) {
      s.odat[i] = dut->odat_cr04h[i];
      s.rwdat[i] = dut->rwdat_cr04h[i];
    }
    for (unsigned q = 0; q < kNP; ++q) s.gdat[q] = dut->gdat_cr04h[q];
    s.mcr = dut->mcr_cr02h;
    s.ccr = dut->ccr_cr02h;
    s.pcr = dut->pcr_cr04h;
    s.quiet = dut->quiet_cr02h;
    s.busy = dut->busy_cr02h;
  }

  int find_restore_row(unsigned r, unsigned &a) {
    for (int i = 0; i < int(migs.size()); ++i) {
      const Mig &m = migs[i];
      if (m.done || !m.restore) continue;
      for (unsigned j = 0; j < kNG; ++j)
        if (m.g[j] == r) {
          a = j;
          return i;
        }
    }
    return -1;
  }

  void check(const Samp &s, const Samp &p1, const Samp &p2) {
    // Busy low: nothing sent is uncredited, no migration holds the module.
    if (!s.busy) {
      // (a valid lands at the next edge, into its capture flop, and busy
      // reads the capture: busy from the cycle after that; the raw valids
      // stay off busy, AR rev 285 (5))
      chk("busy low with a map uncredited", std::max(0, mout - int(mnow) - int(mlast)), 0);
      chk("busy low with a command uncredited", std::max(0, cout - int(cnow) - int(clast)), 0);
      chk("busy low with a PCA row uncredited", std::max(0, pout - int(pnow) - int(plast)), 0);
    }
    // Credits: one a cycle per channel, never more than were sent.
    if (s.mcr) {
      if (mout <= 0) err("map credit with none owed");
      --mout;
      ++mcred;
    }
    if (s.ccr) {
      if (!t_c1) t_c1 = t;   // M5: the first launch's credit is on the wire in c1
      if (cout <= 0) err("command credit with none owed");
      --cout;
      ++ccred;
    }
    if (s.pcr) {
      if (pout <= 0) err("PCA credit with none owed");
      --pout;
      ++pcred;
    }
    // Demotion rows: the valid, then the payload.
    if (s.ov) {
      ++checked;
      if (!ocred) err("demotion row past the receiver's credits");
      else --ocred;
      ocr_due.push_back(t + 1 + pick(cfg.cdelay));
      // The stall is flopped in RCU (RI-22 (7)): at most one row follows it,
      // so no valid two cycles after a stall (RA rev 110).
      if (stall[(t + 6) % 8]) err("demotion valid two cycles after a stall");
      const unsigned back = ctl == Ctl::wake ? kWL + 1 : kWL;
      if (t >= back && !hs[(t + 8 - back) % 8].owk) err("demotion valid without its wake");
    }
    if (stall[(t + 7) % 8] && p1.owk) ++stalls;
    if (p1.ov) payload(s, t - 1);
    // R2 used by the R op while migration has the lead.
    if (p1.r2v && rs[(t + 7) % 8].v && rs[(t + 7) % 8].r2) ++held;

    // RW: the restore's GPR write in A+2 (rwsel and the row in A+1).
    if (p1.rwsel) {
      ++checked;
      if (!p2.rwv) err("RW restore write without its lead");
      const RSlot &ra = rs[(t + 6) % 8];
      if (ra.v && ra.rw) err("RW restore write in a cycle the R op holds RW");
      unsigned a = 0;
      const int id = find_restore_row(p1.rwrow, a);
      if (id < 0) {
        err("RW restore write to a row no restore maps", p1.rwrow);
      } else {
        Mig &m = migs[id];
        if (m.killed && t > m.kcyc + 3) err("restore write after its kill", m.warp);
        if (a != m.next) err("restore rows out of order", a, m.next);
        m.next = a + 1;
        chkrow("restore row data", s.rwdat, m.data[a]);
        prf[p1.rwrow] = s.rwdat;
      }
    }
    // PG0-PG3: row 16, decided in A (gv), rows in A+1, data in A+2.
    if (p2.gv) {
      ++checked;
      int id = -1;
      for (int i = 0; i < int(migs.size()); ++i) {
        const Mig &m = migs[i];
        if (m.done || !m.restore) continue;
        bool hit = true;
        for (unsigned q = 0; q < kNP; ++q)
          hit &= ((p1.grow >> (kWP * q)) & ((1u << kWP) - 1)) == m.p[q];
        if (hit) id = i;
      }
      if (id < 0) {
        err("PG write to predicates no restore maps", p1.grow);
      } else {
        Mig &m = migs[id];
        if (m.killed && t > m.kcyc + 3) err("restore row 16 after its kill", m.warp);
        if (m.next != kNG) err("restore row 16 before rows 0-15", m.next, kNG);
        for (unsigned q = 0; q < kNP; ++q) {
          chk("restore predicate data", s.gdat[q], m.data[kNG][q]);
          pf[m.p[q]] = s.gdat[q];
        }
        if (!m.killed) {
          for (unsigned a = 0; a < kNG; ++a) chkrow("restored row", prf[m.g[a]], m.data[a]);
          ++rs_done;
        }
        if (!t_gv) t_gv = t - 2;
        release(m);
      }
    }

    // Kill: quiet from K+2, within the dead rows' drain.
    if (kpend) {
      if (t >= kK + 2 && s.quiet) kquiet = true;
      if (!kquiet && t > kK + 24) {
        err("quiet not risen after a kill", kmask);
        kquiet = true;
      }
      if (kquiet && t > kK + 8) {
        kpend = false;
        for (auto &m : migs)   // the killed migrations are over: free their rows
          if (!m.done && m.killed) release(m);
      }
    }
    if (s.owk && !t_wake) t_wake = t;
  }

  void payload(const Samp &s, uint64_t tv) {
    int id = -1;
    for (int i = 0; i < int(migs.size()); ++i)
      if (!migs[i].done && !migs[i].restore && migs[i].warp == s.ow) id = i;
    if (id < 0) {
      err("demotion row of a warp with no demotion", s.ow);
      return;
    }
    Mig &m = migs[id];
    if (s.orow == 0) {
      if (cur_dm >= 0 && cur_dm != id && !migs[cur_dm].done && !migs[cur_dm].killed)
        err("a demotion started inside another", s.ow);
      cur_dm = id;
    }
    if (m.killed && tv > m.kcyc + 2) err("demotion row after its kill", m.warp);
    chk("demotion row order", s.orow, m.next);
    Row want{};
    if (m.next < kNG) want = prf[m.g[m.next]];
    else
      for (unsigned q = 0; q < kNP; ++q) want[q] = pf[m.p[q]];
    chkrow("demotion row data", s.odat, want);
    if (++m.next == kNR) {
      if (!t_v16) t_v16 = tv;
      if (!m.killed) {
        ++dm_done;
        release(m);
      }
    }
  }

  // Drain: no new work; everything finishes, every credit returns.
  void drain(unsigned max) {
    cfg.pnew = 0;
    cfg.pkill = 0;
    cfg.pstall = 0;
    for (unsigned i = 0; i < max && (live() || kpend || mout || cout || pout || hs[(t + 7) % 8].busy); ++i)
      step();
    for (unsigned i = 0; i < 8; ++i) step();
    chk("live migrations at the end", live(), 0);
    chk("busy at the end", hs[(t + 7) % 8].busy, 0);
    chk("quiet at the end", hs[(t + 7) % 8].quiet, 1);
    chk("map credits at the end", mcred, kQ);
    chk("command credits at the end", ccred, kQ);
    chk("PCA credits at the end", pcred, kCD);
    chk("receiver credits at the end", ocred + unsigned(ocr_due.size()), ctl == Ctl::cred ? kCD - 1 : kCD);
  }
  void reset() {
    for (int i = 0; i < 8; ++i) step(true);
    step();
  }
};

// M5: one migration at a time, the R slot at OOE's idle-R worst case.
struct M5 {
  uint64_t dm = 0, rs = 0, dm0 = 0, rs0 = 0;
  unsigned fails = 0;
  uint64_t checked = 0;
};
M5 measure(Ctl ctl) {
  M5 r;
  for (int dir = 0; dir < 2; ++dir)
    for (int ph = -1; ph < 4; ++ph) {
      Bench b(nullptr, 0x6d35u + unsigned(ph + 1) * 7 + unsigned(dir), ctl);
      b.cfg.pnew = 0;
      b.cfg.pkill = 0;
      b.cfg.pstall = 0;
      b.cfg.psend = 1;
      b.cfg.cdelay = 2;
      b.cfg.rpattern = ph;
      b.cfg.pr = 0;
      b.cfg.pca_delay = 12;   // the restore has launched: the rows set the pace
      b.reset();
      const int id = b.new_mig(dir);
      b.ready[id] = b.t;
      for (unsigned i = 0; i < 400 && !b.migs[id].done; ++i) b.step();
      b.drain(200);
      uint64_t w = ~0ull;
      // From c1 (RA rev 140 (2)): the demotion to row 16's valid, the
      // restore to row 16's write.
      if (b.migs[id].done && b.t_c1 && !dir && b.t_v16) w = b.t_v16 - b.t_c1;
      if (b.migs[id].done && b.t_c1 && dir && b.t_gv) w = b.t_gv - b.t_c1;
      if (!dir && b.t_c1 && b.t_wake != b.t_c1) {
        std::fprintf(stderr, "mig M5: demotion wake at %llu, not c1 %llu\n", (unsigned long long)b.t_wake,
                     (unsigned long long)b.t_c1);
        ++r.fails;
      }
      if (w == ~0ull) {
        std::fprintf(stderr, "mig M5: %s phase %d did not finish\n", dir ? "restore" : "demotion", ph);
        ++r.fails;
      }
      uint64_t &slot = ph < 0 ? (dir ? r.rs0 : r.dm0) : (dir ? r.rs : r.dm);
      if (w != ~0ull && w > slot) slot = w;
      r.fails += b.fails;
      r.checked += b.checked;
    }
  return r;
}


int run(const std::string &scenario, const char *vcd, Ctl ctl, const char *cname) {
  unsigned fails = 0;
  uint64_t checked = 0;
  std::string m5;
  if (scenario.empty()) {
    const M5 r = measure(ctl);
    const uint64_t bound = 17 * 4;
    const bool ok = r.dm <= bound && r.rs <= bound;
    char buf[256];
    std::snprintf(buf, sizeof buf,
                  "M5 from c1: demotion %llu cycles (R idle %llu), restore %llu (R idle %llu), bound %llu: %s",
                  (unsigned long long)r.dm, (unsigned long long)r.dm0, (unsigned long long)r.rs,
                  (unsigned long long)r.rs0, (unsigned long long)bound, ok ? "met" : "MISSED");
    m5 = buf;
    std::printf("mig %s\n", buf);
    fails += r.fails + !ok;
    checked += r.checked;
  }
  Bench b(vcd, g_seed, ctl);
  if (scenario == "idle") {
    b.cfg = Cfg{};
    b.cfg.pnew = b.cfg.pr = b.cfg.pstall = b.cfg.pkill = 0;
    b.cfg.junk = false;
  } else if (scenario == "medium") {
    b.cfg.pnew = 0.03;
    b.cfg.psend = 0.4;
    b.cfg.pr = 0.3;
    b.cfg.pkill = 0.002;
  }
  b.reset();
  const unsigned n = scenario.empty() ? 30000 : scenario == "idle" ? 3000 : 4000;
  for (unsigned i = 0; i < n; ++i) b.step();
  b.drain(2000);
  if (scenario.empty() && (!b.dm_done || !b.rs_done || !b.kills || !b.dm_killed || !b.rs_killed ||
                           !b.held || !b.stalls)) {
    std::fprintf(stderr, "mig: coverage: demotions %u restores %u kills %u (in a demotion %u, a restore %u) R2 held %u stalls %u\n",
                 b.dm_done, b.rs_done, b.kills, b.dm_killed, b.rs_killed, b.held, b.stalls);
    ++b.fails;
  }
  fails += b.fails;
  checked += b.checked;
  std::printf("mig%s%s %s: %llu cycles, %u demotions, %u restores, %u kills, %llu values checked, %u mismatches: %s\n",
              ctl != Ctl::none ? ", control " : "", ctl != Ctl::none ? cname : "",
              scenario.empty() ? "M5+random" : scenario.c_str(), (unsigned long long)b.t, b.dm_done,
              b.rs_done, b.kills, (unsigned long long)checked, fails, fails ? "FAIL" : "PASS");
  return fails ? 1 : 0;
}

} // namespace

int main(int argc, char **argv) {
  g_argc = argc;
  g_argv = argv;
  std::string scenario;
  const char *vcd = nullptr;
  Ctl ctl = Ctl::none;
  const char *cname = "";
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--control")) {
      cname = argv[i + 1];
      if (!std::strcmp(cname, "rlie")) ctl = Ctl::rlie;
      else if (!std::strcmp(cname, "cred")) ctl = Ctl::cred;
      else if (!std::strcmp(cname, "wake")) ctl = Ctl::wake;
      else if (!std::strcmp(cname, "stall2")) ctl = Ctl::stall2;
      else {
        std::fprintf(stderr, "mig: unknown control %s\n", cname);
        return 2;
      }
    }
  if (const char *d = std::getenv("MIG_DBG")) {
    g_dbg0 = std::strtoull(d, nullptr, 0);
    if (const char *c = std::strchr(d, ',')) g_dbg1 = std::strtoull(c + 1, nullptr, 0);
  }
  for (int i = 1; i + 1 < argc; ++i)
    if (!std::strcmp(argv[i], "--seed")) g_seed = unsigned(std::strtoul(argv[i + 1], nullptr, 0));
  for (int i = 1; i + 2 < argc; ++i)
    if (!std::strcmp(argv[i], "--cg")) {
      scenario = argv[i + 1];
      vcd = argv[i + 2];
      if (scenario != "idle" && scenario != "medium" && scenario != "high") {
        std::fprintf(stderr, "mig: unknown scenario %s\n", scenario.c_str());
        return 2;
      }
    }
  return run(scenario, vcd, ctl, cname);
}
