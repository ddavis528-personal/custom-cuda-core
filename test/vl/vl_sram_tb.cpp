// tools/check-skel.sh: the array macros' RTL (rtl/macro/, Verilated through
// test/vl/vl_sram_top.sv) and their C++ model (sim/skel/sram.h) driven by
// the same random stream, every rdata compared before every edge. Every
// word is written whole first, so neither reads what its simulator left in
// an unwritten word. The 1RW SRAM is accessed at most every other cycle
// (DA tab rev 123), its read data two cycles on, whole words (no byte
// enables; Daniel, 2026-11-17); each register file every cycle, reading the
// word it writes at the same edge about one cycle in four (read before
// write), the _be one byte-masked. Any difference fails, and so does a
// violation the model counts.
// Controls, each of which must be caught (VL_CONTROL=...):
//   wbr      the model's _be register file applies its write before its read
//   wbr3     the model's plain register file applies its write before its read
//   nomask   the model's _be register file writes every byte whatever wmask says
//   mask     the model's plain register file honours a random byte mask
//   late     the model's 1rw edge a cycle late: its data a cycle after the RTL's
//   early    the model's 1rw data compared a cycle ahead of the RTL's: a read
//            sampled a cycle early
//   b2b      the stream sets the 1rw's ce two cycles running once: the RTL's
//            sram_ce_every_other assertion stops the run (check-skel.sh
//            requires its message) and the model counts the violation
#include "Vvl_sram_top.h"
#include "verilated.h"
#include "sram.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <random>
#include <string>

using ccv::skel::Bits;

namespace {
Bits bits(uint32_t n, uint64_t v) {
  Bits b(n);
  b.set(0, n, v);
  return b;
}
} // namespace

int main(int argc, char **argv) {
  const unsigned long cycles = argc > 1 ? std::strtoul(argv[1], nullptr, 10) : 100000;
  const std::string control = std::getenv("VL_CONTROL") ? std::getenv("VL_CONTROL") : "";
  auto ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  auto m = std::make_unique<Vvl_sram_top>(ctx.get());
  ccv::skel::Sram1rw a(37, 12);
  ccv::skel::Rf1r1w b(56, 10, true);
  ccv::skel::Rf1r1w c(32, 6, control == "mask");
  std::mt19937_64 rng(20261113);
  auto pick = [&](unsigned n) { return unsigned(rng() % n); };
  unsigned long diffs = 0, collide = 0, reads = 0;
  bool pend = false;     // control late: the edge held back a cycle
  ccv::skel::Sram1rw a_late = a;
  bool ce_last = false;  // the 1rw's ce at the last edge
  uint64_t rtl_last = 0; // control early: the RTL's rdata a cycle ago
  m->clk = 0;
  m->eval();
  const unsigned long init = 24;  // 12 words written, every other cycle
  for (unsigned long t = 0; t != init + cycles; ++t) {
    const bool fill = t < init;
    // The inputs, the same to both.
    a.ce = fill ? t % 2 == 0 : !ce_last && pick(4) != 0;
    if (control == "b2b" && (t == init + 100 || t == init + 101)) a.ce = true;
    a.we = fill || pick(2);
    a.addr = fill ? unsigned(t / 2) : pick(12);
    a.wdata = bits(37, rng());
    b.we = (fill && t < 10) || (!fill && pick(3) != 0);
    b.waddr = fill ? unsigned(t % 10) : pick(10);
    b.re = !fill && pick(4) != 0;
    b.raddr = !fill && pick(4) == 0 ? b.waddr : pick(10);
    b.wdata = bits(56, rng());
    b.wmask = bits(7, fill ? 0x7f : rng());
    c.we = (fill && t < 6) || (!fill && pick(3) != 0);
    c.waddr = fill ? unsigned(t % 6) : pick(6);
    c.re = !fill && pick(4) != 0;
    c.raddr = !fill && pick(4) == 0 ? c.waddr : pick(6);
    c.wdata = bits(32, rng());
    c.wmask = bits(4, fill ? 0xf : rng());   // read only by control mask
    m->ce = a.ce, m->we = a.we, m->addr = a.addr;
    m->wdata = a.wdata.get(0, 37);
    m->re2 = b.re, m->raddr2 = b.raddr, m->we2 = b.we, m->waddr2 = b.waddr;
    m->wdata2 = b.wdata.get(0, 56), m->wmask2 = uint8_t(b.wmask.get(0, 7));
    m->re3 = c.re, m->raddr3 = c.raddr, m->we3 = c.we, m->waddr3 = c.waddr;
    m->wdata3 = uint32_t(c.wdata.get(0, 32));
    m->eval();
    // Before the edge: rdata as both hold it.
    if (!fill) {
      const uint64_t ma = (control == "late" ? a_late : a).rdata().get(0, 37);
      const uint64_t ra = control == "early" ? rtl_last : uint64_t(m->rdata);
      if (ra != ma || m->rdata2 != b.rdata().get(0, 56) || m->rdata3 != c.rdata().get(0, 32)) {
        if (++diffs <= 3)
          std::printf("cycle %lu: rtl %010llx %014llx %08llx, model %010llx %014llx %08llx\n",
                      t, (unsigned long long)m->rdata, (unsigned long long)m->rdata2,
                      (unsigned long long)m->rdata3, (unsigned long long)ma,
                      (unsigned long long)b.rdata().get(0, 56),
                      (unsigned long long)c.rdata().get(0, 32));
      }
    }
    rtl_last = m->rdata;
    ce_last = a.ce;
    collide += b.re && b.we && b.raddr == b.waddr;
    collide += c.re && c.we && c.raddr == c.waddr;
    reads += a.ce && !a.we;
    // The edge.
    m->clk = 1;
    m->eval();
    m->clk = 0;
    m->eval();
    if (control == "nomask" && b.we) b.wmask = bits(7, 0x7f);
    if (control == "late") {
      if (pend) a_late.edge();
      a_late.ce = a.ce, a_late.we = a.we, a_late.addr = a.addr;
      a_late.wdata = a.wdata;
      pend = true;
    }
    a.edge();
    auto rf_edge = [](ccv::skel::Rf1r1w &r, bool wbr) {
      if (!wbr) return r.edge();
      const bool re = r.re;
      r.re = false;
      r.edge();
      r.re = re, r.we = false;
      r.edge();
    };
    rf_edge(b, control == "wbr");
    rf_edge(c, control == "wbr3");
  }
  m->final();
  const uint64_t viol = a.violations();
  std::printf("%s cycles=%lu reads=%lu same-word=%lu diffs=%lu violations=%llu\n",
              diffs || viol ? "DIFFER" : "agree", cycles, reads, collide, diffs,
              (unsigned long long)viol);
  return diffs || viol ? 1 : 0;
}
