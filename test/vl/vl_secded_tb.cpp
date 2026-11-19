// tools/check-skel.sh: the SECDED encoder and decoder's RTL (rtl/common/,
// Verilated through test/vl/vl_secded_top.sv, 37 and 128 data bits) and
// their C++ code (sim/skel/secded.h) on the same random words, each with no
// error, one flipped bit (any of data and check bits), two, or three. For
// every word: the check bits agree; the decoder's q, sec, ded and syndrome
// agree; and they are what SECDED promises: no error, q is the data and no
// flag; one, q is the data before the flip and sec; two, ded and not sec.
// (Three may look like one: only agreement is required there.) The check
// width agrees with clog2(K + clog2(K) + 1) + 1, the RTL's, for K = 3..1024.
// Controls, each of which must be caught (VL_CONTROL=...):
//   col      the C++ code's columns 0 and 1 swapped: the codes differ
//   nocorr   one error's q compared with the flipped word, not the original:
//            the decoder corrects, so they differ
//   dedsec   two errors expected as one (sec): the decoder says ded
#include "Vvl_secded_top.h"
#include "verilated.h"
#include "secded.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <random>
#include <string>

using ccv::skel::Bits;
using ccv::skel::Secded;

namespace {
uint32_t clog2(uint32_t v) {
  uint32_t r = 0;
  while ((uint32_t(1) << r) < v) ++r;
  return r;
}

// A Verilated port of up to 64 bits, or a VlWide one, to and from Bits.
template <typename T> void put(T &port, const Bits &b) {
  if constexpr (std::is_integral<T>::value) {
    port = T(b.get(0, b.size()));
  } else {
    for (uint32_t w = 0; w * 32 < b.size(); ++w) {
      const uint32_t n = b.size() - w * 32 < 32 ? b.size() - w * 32 : 32;
      port[w] = uint32_t(b.get(w * 32, n));
    }
  }
}
template <typename T> Bits take(const T &port, uint32_t n) {
  Bits b(n);
  if constexpr (std::is_integral<T>::value) {
    b.set(0, n, uint64_t(port));
  } else {
    for (uint32_t w = 0; w * 32 < n; ++w) {
      const uint32_t m = n - w * 32 < 32 ? n - w * 32 : 32;
      b.set(w * 32, m, port[w]);
    }
  }
  return b;
}
bool same(const Bits &a, const Bits &b) {
  if (a.size() != b.size()) return false;
  for (uint32_t i = 0; i != a.size(); ++i)
    if (a.bit(i) != b.bit(i)) return false;
  return true;
}

struct Tally {
  unsigned long words = 0, bad = 0, sec = 0, ded = 0;
};

// One width's check: `data`, its check bits from the RTL, a flip pattern
// over data and check bits, then the decoder's answer, against the model's
// and SECDED's promise.
template <typename DI, typename EO, typename CI, typename QO, typename SO>
void one(Vvl_secded_top &m, const Secded &code, DI &d_in, EO &e_out, CI &c_in, QO &q_out,
         unsigned char &sec_out, unsigned char &ded_out, SO &syn_out, std::mt19937_64 &rng,
         const std::string &control, Tally &t) {
  const uint32_t k = code.dataBits(), r = code.checkBits();
  Bits d(k);
  for (uint32_t i = 0; i < k; i += 64) d.set(i, k - i < 64 ? k - i : 64, rng());
  put(d_in, d);
  m.eval();
  const uint32_t e_rtl = uint32_t(e_out), e_mod = code.encode(d);
  ++t.words;
  if (e_rtl != e_mod) {
    if (t.bad++ < 3) std::printf("FAIL K=%u check bits: RTL %#x model %#x\n", k, e_rtl, e_mod);
    return;
  }
  // Flip 0 to 3 distinct bits of the k + r stored.
  const unsigned nflip = unsigned(rng() % 4);
  Bits dd = d;
  uint32_t cc = e_rtl;
  std::vector<uint32_t> at;
  while (at.size() != nflip) {
    const uint32_t b = uint32_t(rng() % (k + r));
    bool dup = false;
    for (uint32_t x : at) dup |= x == b;
    if (dup) continue;
    at.push_back(b);
    if (b < k) dd.setBit(b, !dd.bit(b));
    else cc ^= uint32_t(1) << (b - k);
  }
  put(d_in, dd);
  c_in = cc;
  m.eval();
  const Bits q = take(q_out, k);
  const bool sec = sec_out, ded = ded_out;
  const uint32_t syn = uint32_t(syn_out);
  const Secded::Result want = code.decode(dd, cc);
  bool ok = same(q, want.q) && sec == want.sec && ded == want.ded && syn == want.syn;
  if (nflip == 0) ok &= same(q, d) && !sec && !ded;
  if (nflip == 1) ok &= same(q, control == "nocorr" ? dd : d) && sec && !ded;
  if (nflip == 2) ok &= control == "dedsec" ? sec && !ded : ded && !sec;
  t.sec += sec;
  t.ded += ded;
  if (!ok && t.bad++ < 3)
    std::printf("FAIL K=%u, %u flip(s): RTL sec %d ded %d syn %#x, model sec %d ded %d syn %#x\n",
                k, nflip, sec, ded, syn, want.sec, want.ded, want.syn);
}
} // namespace

int main(int argc, char **argv) {
  const unsigned long words = argc > 1 ? std::strtoul(argv[1], nullptr, 10) : 100000;
  const std::string control = std::getenv("VL_CONTROL") ? std::getenv("VL_CONTROL") : "";
  for (uint32_t k = 3; k <= 1024; ++k)
    if (Secded::checkBits(k) != clog2(k + clog2(k) + 1) + 1) {
      std::printf("FAIL K=%u: %u check bits, the RTL's formula %u\n", k, Secded::checkBits(k),
                  clog2(k + clog2(k) + 1) + 1);
      return 1;
    }
  auto ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  auto m = std::make_unique<Vvl_secded_top>(ctx.get());
  Secded c37(37), c128(128);
  if (control == "col") {
    std::swap(c37.columns()[0], c37.columns()[1]);
    std::swap(c128.columns()[0], c128.columns()[1]);
  }
  std::mt19937_64 rng(20261118);
  Tally t;
  for (unsigned long n = 0; n != words; ++n) {
    one(*m, c37, m->d1, m->e1, m->c1, m->q1, m->sec1, m->ded1, m->syn1, rng, control, t);
    one(*m, c128, m->d2, m->e2, m->c2, m->q2, m->sec2, m->ded2, m->syn2, rng, control, t);
  }
  m->final();
  if (t.bad) {
    std::printf("FAIL %lu of %lu words\n", t.bad, t.words);
    return 1;
  }
  std::printf("agree %lu words at K=37 and K=128 (sec %lu, ded %lu)\n", t.words, t.sec, t.ded);
  return 0;
}
