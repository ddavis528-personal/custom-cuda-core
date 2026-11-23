// tools/check-skel.sh: the way predictor's fold, RTL (rtl/common/
// ccv_common_wayfold.sv, Verilated through test/vl/vl_wayfold_top.sv at
// K = 4 and 5) against C++ (sim/skel/wayfold.h) on random tags and every
// one-hot tag: the folds agree. And the fold is what MA-30 says: a tag's
// bit i lands on fold bit i mod K (the one-hot tags), and wayFold reads
// PA[47:16] (a PA's bits below 16 and above 47 change nothing).
// Controls, each of which must be caught (VL_CONTROL=...):
//   lo      the C++ side folds the tag from PA bit 15, not 16
//   nozext  the C++ side drops K = 5's last, zero-extended chunk
#include "Vvl_wayfold_top.h"
#include "verilated.h"
#include "wayfold.h"

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <random>
#include <string>

using ccv::skel::wayFold;
using ccv::skel::wayFoldTag;

namespace {
std::string control;
// The C++ fold under test, with the controls' faults.
unsigned model(uint64_t pa, unsigned k) {
  if (control == "lo") return wayFold(pa << 1, k);   // tag from PA bit 15
  if (control == "nozext") {
    const uint64_t tag = (pa >> 16) & 0xffffffffu;
    unsigned f = 0;
    for (unsigned i = 0; i + k <= 32; i += k) f ^= unsigned(tag >> i) & ((1u << k) - 1);
    return f;
  }
  return wayFold(pa, k);
}
} // namespace

int main(int argc, char **argv) {
  const unsigned long n = argc > 1 ? std::strtoul(argv[1], nullptr, 10) : 10000;
  if (const char *c = std::getenv("VL_CONTROL")) control = c;
  auto ctx = std::make_unique<VerilatedContext>();
  auto m = std::make_unique<Vvl_wayfold_top>(ctx.get());
  std::mt19937_64 rng(0x30fa1d);
  unsigned long words = 0, bad = 0;
  auto one = [&](uint64_t pa) {
    const uint32_t tag = uint32_t(pa >> 16);
    m->tag = tag;
    m->eval();
    ++words;
    if (unsigned(m->f4) != model(pa, 4) || unsigned(m->f5) != model(pa, 5)) {
      if (bad++ < 3)
        std::printf("pa %012llx: rtl %x/%x, c++ %x/%x\n", (unsigned long long)pa, unsigned(m->f4),
                    unsigned(m->f5), model(pa, 4), model(pa, 5));
    }
  };
  for (unsigned i = 0; i != 32; ++i) {   // one-hot tags: bit i lands on fold bit i mod K
    const uint64_t pa = uint64_t(1) << (16 + i);
    one(pa);
    if (wayFoldTag(uint64_t(1) << i, 4) != 1u << (i % 4) || wayFoldTag(uint64_t(1) << i, 5) != 1u << (i % 5)) ++bad;
  }
  for (unsigned long i = 0; i != n; ++i) {
    const uint64_t pa = rng() & ((uint64_t(1) << 48) - 1);
    one(pa);
    // PA[15:0] and PA[63:48] are not the tag.
    if (wayFold(pa ^ (rng() & 0xffffu) ^ (rng() << 48), 4) != wayFold(pa, 4)) ++bad;
  }
  if (bad) {
    std::printf("disagree %lu of %lu\n", bad, words);
    return 1;
  }
  std::printf("agree %lu tags at K = 4 and 5\n", words);
  return 0;
}
