//===-- sram_test.cpp - the SRAM macros' cycle model, alone --------*- C++ -*-===//
//
// sram.h's two macros against their contract (rtl/macro/, AR's register rev
// 344), directed, cycle by cycle:
//   1rw   a read's data appears the cycle after the edge that samples it,
//         and holds until the next read; a write reads nothing and leaves
//         rdata alone; wmask writes only its bytes; !ce does nothing.
//   1r1w  a read of the word written at the same edge returns the OLD word
//         (read before write), the new one at the next read; a read and a
//         write of different words in one cycle both happen.
// Its controls, each of which must fail the property it guards:
//   wbr      a write-before-read 1r1w (the write applied first): the
//            same-edge read returns the new word
//   nomask   every byte written whatever wmask says: a masked byte changes
//   early    rdata sampled before the edge: the read's data is not there
// The lockstep against the Verilated RTL is test/vl/vl_sram_tb.cpp.
// Prints one line; exits 0 when every check and every control holds.
//===----------------------------------------------------------------------===//
#include "sram.h"

#include <cstdio>

using namespace ccv::skel;

namespace {

Bits word(uint32_t w, uint64_t v) {
  Bits b(w);
  b.set(0, w > 64 ? 64 : w, v);
  if (w > 64) b.set(w - 32, 32, v >> 7);
  return b;
}
Bits ones(uint32_t n) {
  Bits b(n);
  for (uint32_t i = 0; i != n; ++i) b.setBit(i, true);
  return b;
}

// The 1r1w's edge, its write applied before its read: control wbr.
void edgeWbr(Sram1r1w &m) {
  const bool re = m.re;
  m.re = false;
  m.edge();
  m.re = re;
  const bool we = m.we;
  m.we = false;
  m.edge();
  m.we = we;
}

} // namespace

int main() {
  int bad = 0, checks = 0;
  auto expect = [&](bool c, const char *what) {
    ++checks;
    if (!c) {
      std::printf("sram_test: FAIL %s\n", what);
      ++bad;
    }
  };
  const uint32_t W = 128, D = 8;

  // -- 1rw -------------------------------------------------------------------
  {
    Sram1rw m(W, D);
    m.wmask = ones(W / 8);
    // Cycle 0: write A at 3. Cycle 1: write B at 5.
    m.ce = m.we = true;
    m.addr = 3, m.wdata = word(W, 0xa0a0a0a0a0a0a0a0ull);
    m.edge();
    m.addr = 5, m.wdata = word(W, 0xb1b1b1b1b1b1b1b1ull);
    m.edge();
    expect(!m.rdata().any(), "1rw: a write reads nothing");
    // Cycle 2: read 3. Its data is there only after the edge.
    m.we = false, m.addr = 3;
    const Bits before = m.rdata();
    m.edge();
    expect(before != word(W, 0xa0a0a0a0a0a0a0a0ull) &&
               m.rdata() == word(W, 0xa0a0a0a0a0a0a0a0ull),
           "1rw: read data the cycle after the edge that samples it");
    // Control early: the same read, sampled before its edge, misses.
    expect(before != m.rdata(), "control early: data sampled before its edge differs");
    // Cycle 3: idle; cycle 4: a write. rdata holds through both.
    m.ce = false, m.addr = 5;
    m.edge();
    expect(m.rdata() == word(W, 0xa0a0a0a0a0a0a0a0ull), "1rw: !ce holds rdata");
    m.ce = m.we = true, m.addr = 3, m.wdata = word(W, 0);
    Bits mask(W / 8);
    mask.setBit(0, true), mask.setBit(W / 8 - 1, true);
    m.wmask = mask;
    m.edge();
    expect(m.rdata() == word(W, 0xa0a0a0a0a0a0a0a0ull), "1rw: a write leaves rdata alone");
    // Cycle 5: read 3 back: bytes 0 and W/8-1 cleared, the rest kept.
    m.we = false;
    m.edge();
    Bits want = word(W, 0xa0a0a0a0a0a0a0a0ull);
    want.set(0, 8, 0), want.set(W - 8, 8, 0);
    expect(m.rdata() == want, "1rw: wmask writes only its bytes");
    // Control nomask: the same write with every byte written.
    Bits all = word(W, 0xa0a0a0a0a0a0a0a0ull);
    sram_detail::writeBytes(all, word(W, 0), ones(W / 8));
    expect(all != want, "control nomask: ignoring wmask changes the word");
    // !ce with we: nothing written.
    m.ce = false, m.we = true, m.addr = 5, m.wdata = word(W, 0);
    m.edge();
    m.ce = true, m.we = false;
    m.edge();
    expect(m.rdata() == word(W, 0xb1b1b1b1b1b1b1b1ull), "1rw: !ce writes nothing");
  }

  // -- 1r1w ------------------------------------------------------------------
  for (int wbr = 0; wbr != 2; ++wbr) {
    Sram1r1w m(W, D);
    auto edge = [&] { wbr ? edgeWbr(m) : m.edge(); };
    m.wmask = ones(W / 8);
    m.we = true, m.waddr = 2, m.wdata = word(W, 0x1111);
    edge();
    // The same edge reads 2 and writes it: the old word comes back.
    m.re = true, m.raddr = 2, m.we = true, m.waddr = 2, m.wdata = word(W, 0x2222);
    edge();
    const bool old = m.rdata() == word(W, 0x1111);
    if (!wbr)
      expect(old, "1r1w: a read of the word written at the same edge is the old word");
    else
      expect(!old, "control wbr: a write-before-read model returns the new word");
    // The next read sees the write; a write elsewhere at the same edge.
    m.we = true, m.waddr = 6, m.wdata = word(W, 0x6666);
    edge();
    if (!wbr) {
      expect(m.rdata() == word(W, 0x2222), "1r1w: the next read sees the write");
      m.we = false, m.raddr = 6;
      edge();
      expect(m.rdata() == word(W, 0x6666), "1r1w: a read and a write of different words");
      m.re = false, m.raddr = 2;
      edge();
      expect(m.rdata() == word(W, 0x6666), "1r1w: no read holds rdata");
    }
  }

  if (!bad)
    std::printf("sram_test: 1rw read the cycle after, held, byte-masked, no read on a "
                "write; 1r1w read before write (%d checks); controls wbr, nomask, "
                "early caught\n", checks);
  return bad ? 1 : 0;
}
