//===-- rs_tb.cpp - ooe_rs against the live model --------------------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode,
// and the directed tests) and drives ooe_rs with what the model's RS did in
// each core cycle (Core::wakeLog): its frees, and its allocations in order,
// each on its class's next port, with the row the model wrote: a
// dependency bit and line select for each entry already in the RS, for an
// entry allocated in the same cycle the port that took it, and whether it
// writes a register (Core::rsProduces).
//
// The RTL runs two cycles behind the model, from snapshots, so that every
// lead (OA's response OI-58) is driven before its event: the next cycle's
// allocations per port (req_l) and squash (sq_l), and the completion
// channel's valid two cycles ahead (cmpl_l: an L1 hit's confirmation is
// freed two edges after it). The confirmation leads' terms are the model's
// as they stand: the full-latency line's change at the next edge
// (Core::wakeLineChanges a cycle before), final (Core::rsFinal), issued
// (Core::rsIssued, less this cycle's grants) and the grants.
//
// After the edge, each port's registered grant must be the entry the model
// took, and no other port granted; the valid bits must be the model's, and every valid row's
// dependency bits (Core::depBit) and, where the bit is set and the
// configured penalties fit the lines, its line select (Core::cellCode).
//
// ooe_rs confirms and replays on its own (OI-45): its issued register is
// set from the grants and cleared by its replays and frees, and it reads
// wake's held misses and final bits as the model's pass read them
// (Core::wakeLog hop_msd, cf_fin); the squash's frees are driven apart.
// No entry is allocated in the cycle it is freed (rs_same_edge off, the
// go's counters never counting a free in its own cycle).
//
// Negative controls (RS_CONTROL=<name>) perturb the driving and must be
// caught: no-msd (no held miss reaches the RTL, so its replays are
// missed), drop-squash-free (a squash's frees never reach it), drop-group
// (a row's references to entries allocated in the same cycle never reach
// the RTL), no-req-lead, no-sq-lead, no-cmpl-lead and no-fin (the leads,
// and the final bits, never reach it). The rows' comparison holds column
// clearing: a valid row that kept a freed entry's bit differs.
//
// The column flags (hcol_cq02h) are compared, every column after every
// edge, with their definition kept here: set when a row naming the entry is
// written, clear from the edge that frees it unless a row written at that
// edge names its next occupant. Control stale-hcol keeps the reference's
// flags through a free, and must be caught: the comparison holds clearing.
// Control drop-prv loses the group ahead's producers (prv_dep), and
// stale-live names entries ooe_rs keeps as if stale (below).
//
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: rs_tb [seeds] | rs_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_rs.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Core;

using ccv::ooe::Config;
int ooeTestDirectedHookedWith(void (*hook)(const Core &), void (*cfg)(Config &));
// The RS as built (OI-45): no entry is allocated in the cycle it is freed,
// under the go whose counters never count a free in its own cycle.
void rsConfig(Config &c) {
  c.fits_stale = 6;
  c.rs_same_edge = false;
}

namespace {
constexpr unsigned N = RS_N, NR = RS_NR, A = RS_A, P = 2 * A;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned W = bits(N);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_rs> dut;
std::string control;
uint64_t current = 0;
std::vector<uint8_t> hcol;        // the column flags' reference
constexpr unsigned NCL = RS_NC;

// A core cycle as the model ended it.
struct Snap {
  std::vector<unsigned> ralloc, cidx;   // allocations in order; the entries completing
  std::vector<uint8_t> rfree, grant, valid, dep, code, prod, fin, iss, wtl3, msd, cfin, sqf;
  bool sq = false, cmpl = false, codes = false;
};
Snap empty() {
  Snap y;
  y.rfree.assign(N, 0); y.grant.assign(N, 0); y.valid.assign(N, 0); y.dep.assign(N * N, 0);
  y.code.assign(N * N, 0); y.prod.assign(N, 0); y.fin.assign(N, 0); y.iss.assign(N, 0); y.wtl3.assign(N, 0);
  y.msd.assign(N, 0); y.cfin.assign(N, 0); y.sqf.assign(N, 0);
  return y;
}
Snap snapCycle(const Core &c) {
  const Core::WakeLog &w = c.wakeLog();
  Snap y = empty();
  y.ralloc = w.ralloc;
  y.codes = c.wakeLinesFit();
  for (unsigned i = 0; i != N; ++i) {
    y.rfree[i] = w.rfree[i];
    y.grant[i] = i < w.grant.size() && w.grant[i];
    y.valid[i] = c.rsValid(i);
    y.prod[i] = c.rsProduces(i);
    // Final as ooe_wake holds it in the cycle: an entry confirmed in it was.
    y.fin[i] = c.rsFinal(i) || (i < w.conf.size() && w.conf[i]);
    y.iss[i] = c.rsIssued(i);
    y.wtl3[i] = c.rsValid(i) && c.wakeLineChanges(i, 3);
    if (w.rfree[i] && !(i < w.conf.size() && w.conf[i])) y.sq = true;
    // Confirmation's inputs as the model's pass read them in the cycle
    // (ooe_rs runs it from its own issued register and matrix, OI-45), and
    // the frees that are not confirmations: the registered squash's.
    y.msd[i] = i < w.hop_msd.size() && w.hop_msd[i];
    y.cfin[i] = i < w.cf_fin.size() && w.cf_fin[i];
    y.sqf[i] = w.rfree[i] && !(i < w.conf.size() && w.conf[i]);
    if (i < w.cmpl.size() && w.cmpl[i]) { y.cmpl = true; y.cidx.push_back(i); }
    for (unsigned j = 0; j != N; ++j) {
      y.dep[i * N + j] = c.depBit(i, j);
      y.code[i * N + j] = uint8_t(c.cellCode(i, j));
    }
  }
  return y;
}
std::vector<Snap> hist;           // the snapshots not yet driven, oldest first, and the one before
unsigned long long prev = 0;   // cells on the group granted at the last edge (prv_dep)
unsigned long long cycles = 0, cores = 0, allocs = 0, group = 0, frees = 0, reuse = 0, rows = 0, cells = 0,
                   stale = 0, mismatches = 0;

template <typename T> void setBit(T &w, unsigned i, bool v) {
  if constexpr (sizeof(T) <= 8) {
    if (v) w |= (T(1) << i); else w &= ~(T(1) << i);
  } else {
    if (v) w[i / 32] |= (1u << (i % 32)); else w[i / 32] &= ~(1u << (i % 32));
  }
}
template <typename T> bool getBit(const T &w, unsigned i) {
  if constexpr (sizeof(T) <= 8) return (w >> i) & 1u;
  else return (w[i / 32] >> (i % 32)) & 1u;
}
template <typename T> unsigned getField(const T &w, unsigned lsb, unsigned n) {
  unsigned v = 0;
  for (unsigned b = 0; b != n; ++b) v |= unsigned(getBit(w, lsb + b)) << b;
  return v;
}
template <typename T> void clearAll(T &w, unsigned n) { for (unsigned i = 0; i != n; ++i) setBit(w, i, false); }

CgRun cg;   // --cg <scenario> <vcd>: a clock-gating unit's bench (cg_trace.h)

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}

// Each allocation of a cycle on its class's next port, in the model's
// order: the entry on each port (N for none). False if a class overflows.
bool portsOf(const Snap &y, std::vector<unsigned> &entry_of, std::vector<int> &port_of) {
  entry_of.assign(P, N);
  port_of.assign(N, -1);
  unsigned next[2] = {0, 0};
  for (unsigned e : y.ralloc) {
    const unsigned cls = e >= NR;
    if (next[cls] == A) return false;
    const unsigned p = cls * A + next[cls]++;
    port_of[e] = int(p);
    entry_of[p] = e;
  }
  return true;
}

// The completion channel's valid for a cycle's completions, a lane each.
void driveCmplLead(const Snap *c) {
  clearAll(dut->cmpl_l_cq00h, NCL);
  if (!c || control == "no-cmpl-lead") return;
  for (unsigned k = 0; k != c->cidx.size() && k != NCL; ++k) setBit(dut->cmpl_l_cq00h, k, true);
}
// Its payload, the RS entries, on the same lanes.
void drivePayload(const Snap &c) {
  clearAll(dut->cmpl_idx_cq00h, NCL * W);
  for (unsigned k = 0; k != c.cidx.size() && k != NCL; ++k)
    for (unsigned b = 0; b != W; ++b) setBit(dut->cmpl_idx_cq00h, k * W + b, (c.cidx[k] >> b) & 1u);
}

// The leads of a cycle's events (n: the next cycle's allocations and
// squash; c: the completions whose valid goes now).
void driveLeads(const Snap *n, const Snap *c) {
  clearAll(dut->req_l_cq00h, P);
  dut->sq_l_cq00h = 0;
  driveCmplLead(c);
  if (!n) return;
  std::vector<unsigned> entry_of;
  std::vector<int> port_of;
  portsOf(*n, entry_of, port_of);
  for (unsigned p = 0; p != P; ++p)
    if (entry_of[p] != N && control != "no-req-lead") setBit(dut->req_l_cq00h, p, true);
  dut->sq_l_cq00h = n->sq && control != "no-sq-lead";
}

void fail(const char *what, unsigned a, unsigned b, unsigned rtl, unsigned model) {
  if (++mismatches <= 5)
    std::fprintf(stderr, "cycle %llu: %s (%u, %u: rtl %u, model %u)\n", cycles, what, a, b, rtl, model);
}

void hook(const Core &c) {
  if (c.rsEntries() != N || c.rsRcuEntries() != NR) {
    std::fprintf(stderr, "rs_tb: the core has %u RS entries (%u RCU), the RTL %u (%u)\n", c.rsEntries(),
                 c.rsRcuEntries(), N, NR);
    std::exit(2);
  }
  if (c.serial() != current) {
    current = c.serial();
    ++cores;
    hcol.assign(N, 0);
    clearAll(dut->req_cq01h, P);
    clearAll(dut->sqf_cq01h, N);
    clearAll(dut->msd_cq01h, N);
    clearAll(dut->cfin_cq01h, N);
    driveLeads(nullptr, nullptr);
    clearAll(dut->cmpl_idx_cq00h, NCL * W);
    dut->ooe_rst_r00h = 1;
    tick();
    dut->ooe_rst_r00h = 0;
    tick();
    // Two empty cycles ahead of the core's first, so that its leads go
    // before it; and an empty one before those, for the timer leads.
    hist.assign(3, empty());
  }
  hist.push_back(snapCycle(c));
  // hist: [a - 1, a, a + 1, a + 2]; drive cycle a.
  const Snap &pm = hist[0], &y = hist[1], &n1 = hist[2], &n2 = hist[3];
  ++cycles;
  std::vector<unsigned> entry_of, entry_prev;
  std::vector<int> port_of, port_prev;
  if (!portsOf(y, entry_of, port_of)) { fail("more allocations than ports", 0, 0, A + 1, A); hist.erase(hist.begin()); return; }
  portsOf(pm, entry_prev, port_prev);   // the last edge's allocations, by port (the registered grant)
  clearAll(dut->req_cq01h, P);
  clearAll(dut->row_dep_cq01h, P * N);
  clearAll(dut->row_code_cq01h, 2 * P * N);
  clearAll(dut->grp_dep_cq01h, P * P);
  clearAll(dut->grp_code_cq01h, 2 * P * P);
  clearAll(dut->prv_dep_cq01h, P * P);
  clearAll(dut->prv_code_cq01h, 2 * P * P);
  clearAll(dut->row_prod_cq01h, P);
  for (unsigned p = 0; p != P; ++p) {
    const unsigned e = entry_of[p];
    if (e == N) continue;
    setBit(dut->req_cq01h, p, true);
    setBit(dut->row_prod_cq01h, p, y.prod[e]);
    ++allocs;
    for (unsigned j = 0; j != N; ++j) {
      if (!y.dep[e * N + j]) continue;
      const unsigned code = y.codes ? y.code[e * N + j] & 3u : 0;
      if (port_of[j] >= 0) {
        const unsigned q = unsigned(port_of[j]);
        setBit(dut->grp_dep_cq01h, p * P + q, control != "drop-group");
        setBit(dut->grp_code_cq01h, (p * P + q) * 2, code & 1u);
        setBit(dut->grp_code_cq01h, (p * P + q) * 2 + 1, (code >> 1) & 1u);
        ++group;
      } else if (port_prev[j] >= 0) {
        // Granted at the last edge: rename knew it by that group's port.
        const unsigned q = unsigned(port_prev[j]);
        setBit(dut->prv_dep_cq01h, p * P + q, control != "drop-prv");
        setBit(dut->prv_code_cq01h, (p * P + q) * 2, code & 1u);
        setBit(dut->prv_code_cq01h, (p * P + q) * 2 + 1, (code >> 1) & 1u);
        ++prev;
      } else {
        setBit(dut->row_dep_cq01h, p * N + j, true);
        setBit(dut->row_code_cq01h, (p * N + j) * 2, code & 1u);
        setBit(dut->row_code_cq01h, (p * N + j) * 2 + 1, (code >> 1) & 1u);
      }
    }
    // Rename looks a row's producers up a stage before it writes it, so a
    // row may name an entry freed now; ooe_rs masks it (the model's row
    // never does). Every allocated row names every entry freed now.
    // Likewise a stale name: rename's lookup ran on ooe_prodmap's names a
    // stage before, which an entry not valid now, or the group ahead's (its
    // names not yet rewritten), may still hold. ooe_rs masks all three; the
    // bench names every one of them in every row. Control stale-live names
    // every other entry too, which ooe_rs keeps, and must be caught: the
    // stale bits reach the comparison, so only the mask drops them.
    for (unsigned j = 0; j != N; ++j)
      if ((y.rfree[j] || !pm.valid[j] || port_prev[j] >= 0 || control == "stale-live") && !y.dep[e * N + j]) {
        setBit(dut->row_dep_cq01h, p * N + j, true);
        ++stale;
      }
  }
  for (unsigned j = 0; j != N; ++j) {
    setBit(dut->sqf_cq01h, j, y.sqf[j] && control != "drop-squash-free");
    setBit(dut->msd_cq01h, j, y.msd[j] && control != "no-msd");
    setBit(dut->cfin_cq01h, j, y.cfin[j]);
    frees += y.rfree[j];
    reuse += y.rfree[j] && port_of[j] >= 0;
    // The confirmation leads' terms as they stand in a.
    setBit(dut->wtl3_cq00h, j, pm.wtl3[j]);
    setBit(dut->fin_cq00h, j, control != "no-fin" && y.fin[j]);
    setBit(dut->gnt_cq00h, j, y.grant[j]);
  }
  // The completions arriving with this edge's valid flop: a + 1's.
  drivePayload(n1);
  driveLeads(&n1, &n2);
  tick();
  // After the edge: the grants, registered, every port's.
  for (unsigned p = 0; p != P; ++p) {
    const unsigned e = entry_of[p];
    const bool v = getBit(dut->gnt_v_cq03h, p);
    if (e == N) {
      if (v) fail("a port the model did not allocate on was granted", p, 0, 1, 0);
      continue;
    }
    const unsigned idx = getField(dut->gnt_idx_cq03h, p * W, W);
    if (!v) fail("a port the model allocated on was not granted", p, e, 0, 1);
    else if (idx != e) fail("granted a different entry", p, 0, idx, e);
  }
  // The column flags' reference, then the RTL's.
  std::vector<uint8_t> named(N, 0);
  for (unsigned p = 0; p != P; ++p)
    if (entry_of[p] != N)
      for (unsigned j = 0; j != N; ++j) named[j] |= y.dep[entry_of[p] * N + j];
  for (unsigned j = 0; j != N; ++j) {
    hcol[j] = ((hcol[j] && (!y.rfree[j] || control == "stale-hcol")) || named[j]) ? 1 : 0;
    const bool h = getBit(dut->hcol_cq02h, j);
    if (h != bool(hcol[j])) fail("column flag differs", j, 0, h, hcol[j]);
  }
  // After it: the valid bits and every valid row.
  for (unsigned i = 0; i != N; ++i) {
    const bool v = getBit(dut->valid_out_cq02h, i);
    if (v != bool(y.valid[i])) { fail("valid differs", i, 0, v, y.valid[i]); continue; }
    if (!v) continue;
    ++rows;
    for (unsigned j = 0; j != N; ++j) {
      const bool d = getBit(dut->dep_cq02h, i * N + j);
      if (d != bool(y.dep[i * N + j])) { fail("dependency bit differs", i, j, d, y.dep[i * N + j]); continue; }
      if (!d || !y.codes) continue;
      ++cells;
      const unsigned code = getField(dut->code_cq02h, (i * N + j) * 2, 2);
      if (code != y.code[i * N + j]) fail("line select differs", i, j, code, y.code[i * N + j]);
    }
  }
  hist.erase(hist.begin());
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("RS_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_rs>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  // The directed tests in the ordinary run; a scenario is the random tests'.
  const int model_fails = (cg.on() ? 0 : ooeTestDirectedHookedWith(hook, rsConfig)) + cg.run(seeds, nullptr, hook, rsConfig);
  cg.close();
  dut->final();
  std::printf("rs_tb control=%s seeds=%u cores=%llu cycles=%llu allocs=%llu in-group=%llu frees=%llu "
              "same-edge=%llu rows=%llu cells=%llu stale=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, allocs, group, frees, reuse,
              rows, cells, stale, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
