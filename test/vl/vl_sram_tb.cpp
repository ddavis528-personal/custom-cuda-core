// tools/check-skel.sh: the SRAM macros' RTL (rtl/macro/, Verilated through
// test/vl/vl_sram_top.sv) and their C++ model (sim/skel/sram.h) driven by
// the same random stream, every rdata compared before every edge. Every
// word is written whole first, so neither reads what its simulator left in
// an unwritten word. The stream reads the word the 1r1w writes at the same
// edge about one cycle in four (read before write). Any difference fails.
// Controls, each of which must be caught (VL_CONTROL=...):
//   wbr      the model's 1r1w applies its write before its read
//   nomask   the model writes every byte whatever wmask says
//   late     the model's edge a cycle late: its data a cycle after the RTL's
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
  ccv::skel::Sram1rw a(40, 12);
  ccv::skel::Sram1r1w b(56, 10);
  std::mt19937_64 rng(20261113);
  auto pick = [&](unsigned n) { return unsigned(rng() % n); };
  unsigned long diffs = 0, collide = 0, reads = 0;
  bool pend = false;     // control late: the edge held back a cycle
  ccv::skel::Sram1rw a_late = a;
  m->clk = 0;
  m->eval();
  const unsigned long init = 12;
  for (unsigned long t = 0; t != init + cycles; ++t) {
    const bool fill = t < init;
    // The inputs, the same to both.
    a.ce = fill || pick(4) != 0;
    a.we = fill || pick(2);
    a.addr = fill ? unsigned(t) : pick(12);
    a.wdata = bits(40, rng());
    a.wmask = bits(5, fill ? 0x1f : rng());
    b.we = (fill && t < 10) || (!fill && pick(3) != 0);
    b.waddr = fill ? unsigned(t % 10) : pick(10);
    b.re = !fill && pick(4) != 0;
    b.raddr = !fill && pick(4) == 0 ? b.waddr : pick(10);
    b.wdata = bits(56, rng());
    b.wmask = bits(7, fill ? 0x7f : rng());
    m->ce = a.ce, m->we = a.we, m->addr = a.addr;
    m->wdata = a.wdata.get(0, 40), m->wmask = uint8_t(a.wmask.get(0, 5));
    m->re2 = b.re, m->raddr2 = b.raddr, m->we2 = b.we, m->waddr2 = b.waddr;
    m->wdata2 = b.wdata.get(0, 56), m->wmask2 = uint8_t(b.wmask.get(0, 7));
    m->eval();
    // Before the edge: rdata as both hold it.
    if (!fill) {
      const uint64_t ma = (control == "late" ? a_late : a).rdata().get(0, 40);
      if (m->rdata != ma || m->rdata2 != b.rdata().get(0, 56)) {
        if (++diffs <= 3)
          std::printf("cycle %lu: rtl %010llx %014llx, model %010llx %014llx\n", t,
                      (unsigned long long)m->rdata, (unsigned long long)m->rdata2,
                      (unsigned long long)ma, (unsigned long long)b.rdata().get(0, 56));
      }
    }
    collide += b.re && b.we && b.raddr == b.waddr;
    reads += a.ce && !a.we;
    // The edge.
    m->clk = 1;
    m->eval();
    m->clk = 0;
    m->eval();
    if (control == "nomask" && a.ce && a.we) a.wmask = bits(5, 0x1f);
    if (control == "late") {
      if (pend) a_late.edge();
      a_late.ce = a.ce, a_late.we = a.we, a_late.addr = a.addr;
      a_late.wdata = a.wdata, a_late.wmask = a.wmask;
      pend = true;
    }
    a.edge();
    if (control == "wbr") {
      const bool re = b.re;
      b.re = false;
      b.edge();
      b.re = re, b.we = false;
      b.edge();
    } else {
      b.edge();
    }
  }
  m->final();
  std::printf("%s cycles=%lu reads=%lu same-word=%lu diffs=%lu\n",
              diffs ? "DIFFER" : "agree", cycles, reads, collide, diffs);
  return diffs ? 1 : 0;
}
