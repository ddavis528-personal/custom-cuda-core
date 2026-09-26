//===-- layout_probe.cpp - C++ field offsets vs the SV packed structs ----===//
//
// Drives random payloads into ccv_skel_layout_probe, which reads every field
// back through the REAL generated SystemVerilog typedef, and compares each
// against the C++ offset table the skeleton uses. Any disagreement is a
// swap-boundary bug: RTL and model would read the same bits as different
// fields. F-12 is why this is checked rather than assumed.
//===----------------------------------------------------------------------===//
#include "Vccv_skel_layout_probe.h"
#include "verilated.h"

#include "bits.h"

#include <cstdio>
#include <cstring>
#include <set>
#include <string>
#include <type_traits>

using ccv::skel::Bits;

namespace {

uint64_t mix(uint64_t x) {
  x += 0x9e3779b97f4a7c15ull;
  x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9ull;
  x = (x ^ (x >> 27)) * 0x94d049bb133111ebull;
  return x ^ (x >> 31);
}

Bits randomBits(uint32_t n, uint64_t seed) {
  Bits b(n);
  for (uint32_t off = 0; off < n; off += 64)
    b.set(off, n - off < 64 ? n - off : 64, mix(seed + off));
  return b;
}

// Verilator maps a port to CData/SData/IData/QData or VlWide<N> by width.
template <typename T>
typename std::enable_if<std::is_integral<T>::value>::type
put(T &port, const Bits &b) { port = T(b.get(0, b.size())); }

template <std::size_t N> void put(VlWide<N> &port, const Bits &b) {
  for (std::size_t w = 0; w != N; ++w) port[w] = 0;
  for (uint32_t i = 0; i != b.size(); ++i)
    if (b.bit(i)) port[i / 32] |= 1u << (i % 32);
}

template <typename T>
typename std::enable_if<std::is_integral<T>::value, bool>::type
bitOf(const T &port, uint32_t i) { return (uint64_t(port) >> i) & 1u; }

template <std::size_t N> bool bitOf(const VlWide<N> &port, uint32_t i) {
  return (port[i / 32] >> (i % 32)) & 1u;
}

unsigned g_reported = 0;
// --mutate shifts every C++ offset by one bit, where the payload leaves room
// to. The probe must then see EVERY such field disagree -- the negative
// control that a clean result above means agreement rather than a probe that
// cannot tell.
bool g_mutate = false;
std::set<std::string> g_mutable, g_caught;

template <typename T>
unsigned check(const char *chan, const char *field, const T &port,
               const Bits &b, uint32_t lsb, uint32_t width) {
  if (g_mutate) {
    const uint32_t room = b.size() - width + 1;   // legal lsb positions
    if (room == 1)
      return 0;                     // the field IS the payload; cannot shift
    const std::string key = std::string(chan) + "." + field;
    g_mutable.insert(key);
    lsb = (lsb + 1) % room;
    for (uint32_t i = 0; i != width; ++i)
      if (bitOf(port, i) != b.bit(lsb + i)) { g_caught.insert(key); return 1; }
    return 0;
  }
  for (uint32_t i = 0; i != width; ++i)
    if (bitOf(port, i) != b.bit(lsb + i)) {
      if (g_reported++ < 5)
        std::fprintf(stderr, "LAYOUT %s.%s: SV and C++ disagree at bit %u\n",
                     chan, field, i);
      return 1;
    }
  return 0;
}

#include "ccv_skel_layout_probe.inc"

} // namespace

int main(int argc, char **argv) {
  auto ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  for (int i = 1; i < argc; ++i)
    if (!std::strcmp(argv[i], "--mutate")) g_mutate = true;
  Vccv_skel_layout_probe p(ctx.get());
  unsigned bad = 0, rounds = 64;
  for (unsigned r = 0; r != rounds; ++r)
    bad += probeOnce(p, 0x5eed0000ull + r);
  if (g_mutate) {
    std::printf("LAYOUT-MUTATED mutable_fields=%zu caught=%zu\n",
                g_mutable.size(), g_caught.size());
    return g_caught.size() == g_mutable.size() ? 0 : 1;
  }
  std::printf("LAYOUT rounds=%u field_disagreements=%u\n", rounds, bad);
  return bad ? 1 : 0;
}
