//===-- rs_tb.cpp - ooe_rs against the live model --------------------===//
//
// Runs the model's random unit tests (sim/ooe/ooe_test.cpp, every mode)
// and, after every core cycle, drives ooe_rs with what the model's RS did
// in it (Core::wakeLog): its frees, and its allocations in order, each on
// its class's next port, with the row the model wrote: a dependency bit
// and line select for each entry already in the RS, and for an entry
// allocated in the same cycle, the port that took it.
//
// Before the edge, each port's grant must be the entry the model took.
// After it, the valid bits must be the model's, and every valid row's
// dependency bits (Core::depBit) and, where the bit is set and the
// configured penalties fit the lines, its line select (Core::cellCode).
//
// Negative controls (RS_CONTROL=<name>) perturb the driving and must be
// caught: no-same-edge (a free reaches the RTL a cycle late, so an entry
// freed and reallocated in one cycle is still busy) and drop-group (a
// row's references to entries allocated in the same cycle never reach the
// RTL). The rows' comparison holds column clearing: a valid row that kept
// a freed entry's bit differs.
//
// The column flags (hcol_cq02h) are compared, every column after every
// edge, with their definition kept here: set when a row naming the entry is
// written, clear from the edge that frees it unless a row written at that
// edge names its next occupant. Control stale-hcol keeps the reference's
// flags through a free, and must be caught: the comparison holds clearing.
//
// With --cg <scenario> <vcd> it is ooe_rs's clock-gating bench
// (test/ooe/cg_trace.h), and compares nothing.
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

int ooeTestRandomHooked(unsigned seeds, void (*hook)(const Core &));

namespace {
constexpr unsigned N = RS_N, NR = RS_NR, A = RS_A, P = 2 * A;
constexpr unsigned bits(unsigned n) { unsigned w = 0; while ((1u << w) < n) ++w; return w; }
constexpr unsigned W = bits(N);

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_rs> dut;
std::string control;
uint64_t current = 0;
std::vector<uint8_t> late_free;   // no-same-edge: last cycle's frees
std::vector<uint8_t> hcol;        // the column flags' reference
unsigned long long cycles = 0, cores = 0, allocs = 0, group = 0, frees = 0, reuse = 0, rows = 0, cells = 0,
                   mismatches = 0;

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

// An idle cycle: no allocation and no free; the rows hold.
void idleTick() {
  clearAll(dut->req_cq01h, P);
  clearAll(dut->free_cq01h, N);
  tick();
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
    late_free.assign(N, 0);
    hcol.assign(N, 0);
    clearAll(dut->req_cq01h, P);
    clearAll(dut->free_cq01h, N);
    dut->ooe_rst_r00h = 1;
    tick();
    dut->ooe_rst_r00h = 0;
  }
  ++cycles;
  const Core::WakeLog &w = c.wakeLog();
  const bool codes = c.wakeLinesFit();
  // Ports: each allocation on its class's next port, in the model's order.
  std::vector<int> port_of(N, -1);
  std::vector<unsigned> entry_of(P, N);
  unsigned next[2] = {0, 0};
  for (unsigned e : w.ralloc) {
    const unsigned cls = e >= NR;
    if (next[cls] == A) { fail("more allocations than ports", cls, 0, A + 1, A); return; }
    const unsigned p = cls * A + next[cls]++;
    port_of[e] = int(p);
    entry_of[p] = e;
  }
  clearAll(dut->req_cq01h, P);
  clearAll(dut->row_dep_cq01h, P * N);
  clearAll(dut->row_code_cq01h, 2 * P * N);
  clearAll(dut->grp_dep_cq01h, P * P);
  clearAll(dut->grp_code_cq01h, 2 * P * P);
  for (unsigned p = 0; p != P; ++p) {
    const unsigned e = entry_of[p];
    if (e == N) continue;
    setBit(dut->req_cq01h, p, true);
    ++allocs;
    for (unsigned j = 0; j != N; ++j) {
      if (!c.depBit(e, j)) continue;
      const unsigned code = codes ? c.cellCode(e, j) & 3u : 0;
      if (port_of[j] >= 0) {
        const unsigned q = unsigned(port_of[j]);
        setBit(dut->grp_dep_cq01h, p * P + q, control != "drop-group");
        setBit(dut->grp_code_cq01h, (p * P + q) * 2, code & 1u);
        setBit(dut->grp_code_cq01h, (p * P + q) * 2 + 1, (code >> 1) & 1u);
        ++group;
      } else {
        setBit(dut->row_dep_cq01h, p * N + j, true);
        setBit(dut->row_code_cq01h, (p * N + j) * 2, code & 1u);
        setBit(dut->row_code_cq01h, (p * N + j) * 2 + 1, (code >> 1) & 1u);
      }
    }
  }
  for (unsigned j = 0; j != N; ++j) {
    bool f = w.rfree[j];
    if (control == "no-same-edge") { f = late_free[j]; late_free[j] = w.rfree[j]; }
    setBit(dut->free_cq01h, j, f);
    frees += w.rfree[j];
    reuse += w.rfree[j] && port_of[j] >= 0;
  }
  // Before the edge: the grants.
  dut->ooe_core_clk = 0;
  dut->eval();
  for (unsigned p = 0; p != P; ++p) {
    const unsigned e = entry_of[p];
    if (e == N) continue;
    const bool v = getBit(dut->gnt_v_cq02h, p);
    const unsigned idx = getField(dut->gnt_idx_cq02h, p * W, W);
    if (!v) fail("a port the model allocated on was not granted", p, e, 0, 1);
    else if (idx != e) fail("granted a different entry", p, 0, idx, e);
  }
  tick();
  if (cg.on()) {
    for (unsigned g = 0; g != cg.gaps(); ++g) idleTick();
    return;
  }
  // The column flags' reference, then the RTL's.
  std::vector<uint8_t> named(N, 0);
  for (unsigned p = 0; p != P; ++p)
    if (entry_of[p] != N)
      for (unsigned j = 0; j != N; ++j) named[j] |= c.depBit(entry_of[p], j);
  for (unsigned j = 0; j != N; ++j) {
    hcol[j] = ((hcol[j] && (!w.rfree[j] || control == "stale-hcol")) || named[j]) ? 1 : 0;
    const bool h = getBit(dut->hcol_cq02h, j);
    if (h != bool(hcol[j])) fail("column flag differs", j, 0, h, hcol[j]);
  }
  // After it: the valid bits and every valid row.
  for (unsigned i = 0; i != N; ++i) {
    const bool v = getBit(dut->valid_cq02h, i);
    if (v != c.rsValid(i)) { fail("valid differs", i, 0, v, c.rsValid(i)); continue; }
    if (!v) continue;
    ++rows;
    for (unsigned j = 0; j != N; ++j) {
      const bool d = getBit(dut->dep_cq02h, i * N + j);
      if (d != c.depBit(i, j)) { fail("dependency bit differs", i, j, d, c.depBit(i, j)); continue; }
      if (!d || !codes) continue;
      ++cells;
      const unsigned code = getField(dut->code_cq02h, (i * N + j) * 2, 2);
      if (code != c.cellCode(i, j)) fail("line select differs", i, j, code, c.cellCode(i, j));
    }
  }
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
  if (cg.on()) {
    cg.open(*dut, vcd);
    clearAll(dut->req_cq01h, P);
    clearAll(dut->free_cq01h, N);
    dut->ooe_rst_r00h = 1;
    for (unsigned k = 0; k != 4; ++k) tick();
    dut->ooe_rst_r00h = 0;
    if (cg.idle()) {
      for (unsigned k = 0; k != CgRun::kIdleCycles; ++k) idleTick();
    } else {
      ooeTestRandomHooked(CgRun::kSeeds, hook);
    }
    cg.close();
    dut->final();
    cg.vcd.reset();
    dut.reset();
    ctx.reset();
    return 0;
  }
  const int model_fails = ooeTestRandomHooked(seeds, hook);
  dut->final();
  std::printf("rs_tb control=%s seeds=%u cores=%llu cycles=%llu allocs=%llu in-group=%llu frees=%llu "
              "same-edge=%llu rows=%llu cells=%llu mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, cycles, allocs, group, frees, reuse,
              rows, cells, mismatches, model_fails);
  const int rc = mismatches || model_fails ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
