//===-- dpi_host.cpp - the C++ skeleton's blocks, hosted by the SV top ----===//
//
// The other way round from main.cpp. There, C++ owns the clock and the wires
// -- Machine::step() commits every slot -- and the SV checker bank is a
// Verilated guest. Here the SV top owns both: ccv_core_top is built from the
// DPI shims in rtl/top/dpi/ (tools/gen-top.py), every connection between two
// blocks is a net in that top, and each shim calls in once per clock edge to
// run ITS block's cycle. A C++ block never sees another block's state, only
// what the Verilog carried to its ports -- which is the property that lets a
// shim, a stub and real RTL stand in for one another in any mix.
//
// ONE CALL, ONE BLOCK, ONE CYCLE (ccv_dpi_cycle_<type>):
//   1. the shim's sample -- every channel signal at its ports, its own
//      registered outputs included -- is written into those slots' `cur`;
//   2. the fields this block drives are set to what Slot::begin() would give
//      them: pulses low, payload and trace id holding;
//   3. out of reset, the block runs its cycle, reading `cur`, writing `nxt`;
//   4. the fields it drives go back to the shim, which registers them.
// Each shim writes its own END of the slot (Slot::src() or dst()). On an
// abutted link the two are one object, and both ends sample the same net at
// the same edge, so they write the same `cur`; each writes only its own half
// of `nxt`. On a repeated link they are two objects, and the SV repeaters in
// the hardening wrappers between them are the latency. No block reads
// `nxt`, so the order the simulator calls the shims in cannot matter -- the
// same argument as channel.h's two phases, now made by the Verilog.
//
// The Machine is still built, for three things only: the Slot, Sender and
// Receiver objects each block's ports point at (a block's own protocol state
// lives in them), the finish rule's in-flight count, and the overflow total.
// Its step() is never called: the SV registers are the commit.
//
// Plusargs: +ccv_oracle=<oracle.jsonl> (required) +ccv_trace=<file>
// +ccv_break=<mode> (S1's kernel controls) +ccv_cycles=<cap>
// +ccv_shim_delay=<instance> -- the negative control for THIS build: that
// shim's outputs go through one extra register, a one-cycle skew on every
// port of one block, which the comparison against the C++-hosted run must
// catch.
//===----------------------------------------------------------------------===//
#include "Vtb__Dpi.h"   // the prototypes Verilator derived from the imports
#include "svdpi.h"
#include "verilated.h"

#include "ccv/event.h"
#include "ccv_dpi_ports.h"
#include "exerciser.h"
#include "kernel.h"
#include "machine.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <string>
#include <vector>

using namespace ccv::skel;

namespace {

[[noreturn]] void die(const char *fmt, const char *a = "", int b = 0) {
  std::fprintf(stderr, "dpi_host: ");
  std::fprintf(stderr, fmt, a, b);
  std::fprintf(stderr, "\n");
  std::exit(2);
}

struct Shim {
  std::string name;              ///< instance name: u_fet, u_lane_07, u_ext
  int inst;                      ///< kBlkInsts index, -1 for EXTERNAL's end
  unsigned type;                 ///< kDpiTypes index
  std::vector<unsigned> slot;    ///< per sampled port, its global slot
  bool skew = false;
};

struct Host {
  Kernel k;
  std::unique_ptr<Machine> m;
  std::vector<Shim> shims;
  KernelEnd end;
  std::string trace, skew_name;
  uint64_t cap = 20000;
  std::vector<bool> seen = std::vector<bool>(kNumBlkInsts + 1, false);
};
Host *g = nullptr;

std::string plusarg(const char *name) {
  const std::string pre = std::string(name) + "=";
  const char *m = Verilated::threadContextp()->commandArgsPlusMatch(pre.c_str());
  if (!m || !*m) return "";
  return std::string(m + 1 + pre.size());   // past "+<name>="
}

void init() {
  g = new Host;
  // Count checker violations and keep going, as the C++ host does.
  Verilated::threadContextp()->errorLimit(1 << 30);
  const std::string oracle = plusarg("ccv_oracle");
  if (oracle.empty()) die("no +ccv_oracle=<oracle.jsonl>");
  if (std::string e = g->k.orc.load(oracle); !e.empty()) die("%s", e.c_str());
  g->k.name = kernelName(oracle);
  const std::string brk = plusarg("ccv_break");
  g->k.brk = brk.empty() ? "none" : brk;
  if (std::string c = plusarg("ccv_cycles"); !c.empty())
    g->cap = std::strtoull(c.c_str(), nullptr, 0);
  g->trace = plusarg("ccv_trace");
  if (!g->trace.empty() && !ccv::traceWriter().open(g->trace))
    die("cannot open trace %s", g->trace.c_str());
  g->skew_name = plusarg("ccv_shim_delay");
  if (unsigned bad = checkFieldTiling()) die("%s%d broken field table(s)", "", int(bad));
  g->m = std::make_unique<Machine>(
      2, [](int inst) { return makeKernelBlock(inst, g->k); });
  if (g->k.brk == "late-lead")
    for (Slot &s : g->m->slots()) s.late_lead = true;
}

/// kBlkInsts index of an instance name, by gen-top.py's naming rule; -1 for
/// the testbench's end of EXTERNAL.
int instOf(const std::string &n) {
  if (n == "u_ext") return -1;
  for (unsigned b = 0; b != kNumBlkInsts; ++b) {
    const BlkInst &bi = kBlkInsts[b];
    unsigned same = 0;
    for (const BlkInst &o : kBlkInsts) same += o.type == bi.type;
    char buf[64];
    if (same == 1) std::snprintf(buf, sizeof buf, "u_%s", blkName(bi.type));
    else std::snprintf(buf, sizeof buf, "u_%s_%02u", blkName(bi.type), bi.index);
    if (n == buf) return int(b);
  }
  die("no block instance named %s", n.c_str());
}

/// The global slot each of a shim's sampled ports belongs to -- and a check
/// that the port's direction is this instance's end of that channel.
void resolve(Shim &s) {
  const DpiType &t = kDpiTypes[s.type];
  for (unsigned j = 0; j != t.nports; ++j) {
    const DpiPort &p = t.ports[j];
    unsigned copy = p.copy >= 0 ? unsigned(p.copy)
                    : (kChans[p.chan].ninst > 1 ? kBlkInsts[s.inst].index : 0);
    const ChanInst *ci = nullptr;
    for (const ChanInst &c : kChanInsts)
      if (c.chan == p.chan && c.inst == copy) ci = &c;
    if (!ci || p.slot >= kChans[p.chan].rate)
      die("%s: a port names no slot", s.name.c_str());
    const bool fwd = p.sig == DpiSig::VALID || p.sig == DpiSig::PAYLOAD ||
                     p.sig == DpiSig::TID;
    const int16_t driver = fwd ? ci->src : ci->dst;
    const int16_t reader = fwd ? ci->dst : ci->src;
    if ((p.out ? driver : reader) != s.inst)
      die("%s: a port is not this instance's end of its channel", s.name.c_str());
    const unsigned w = p.sig == DpiSig::PAYLOAD ? kChans[p.chan].bits
                       : p.sig == DpiSig::TID  ? 64 : 1;
    if (w != p.width) die("%s: a port's width disagrees with the schema", s.name.c_str());
    s.slot.push_back(ci->slot_base + p.slot);
  }
}

uint64_t getv(const svBitVecVal *v, uint32_t off, uint32_t w) {   // w <= 64
  uint64_t r = 0;
  for (uint32_t b = 0; b != w;) {
    const uint32_t i = off + b, sh = i % 32, n = std::min(32 - sh, w - b);
    const uint64_t word = (uint64_t(v[i / 32]) >> sh) & ((1ull << n) - 1);
    r |= word << b;
    b += n;
  }
  return r;
}

void putv(svBitVecVal *v, uint32_t off, uint32_t w, uint64_t x) {  // w <= 64
  for (uint32_t b = 0; b != w;) {
    const uint32_t i = off + b, sh = i % 32, n = std::min(32 - sh, w - b);
    const uint32_t mask = uint32_t(((1ull << n) - 1) << sh);
    v[i / 32] = (v[i / 32] & ~mask) | (uint32_t((x >> b) << sh) & mask);
    b += n;
  }
}

/// The end of its slot a port belongs to: the sender's for what the sender
/// drives or reads back (valid, payload, trace id out; credit, stall in),
/// the receiver's otherwise. On a repeated link the two differ, and the SV
/// repeaters between them are the latency; on an abutted one they are the
/// same object.
SlotEnd &endOf(Slot &sl, const DpiPort &p) {
  const bool fwd = p.sig == DpiSig::VALID || p.sig == DpiSig::PAYLOAD ||
                   p.sig == DpiSig::TID;
  return fwd == p.out ? sl.src() : sl.dst();
}

void cycle(unsigned type, int h, long long cyc, bool rst,
           const svBitVecVal *sample, svBitVecVal *drive) {
  if (!g || h < 0 || size_t(h) >= g->shims.size()) die("unregistered shim");
  Shim &s = g->shims[h];
  if (s.type != type) die("%s called the wrong type's cycle", s.name.c_str());
  const DpiType &t = kDpiTypes[type];
  auto &slots = g->m->slots();

  // 1. sample -> cur
  uint32_t off = 0;
  for (unsigned j = 0; j != t.nports; ++j) {
    const DpiPort &p = t.ports[j];
    SlotSignals &c = endOf(slots[s.slot[j]], p).cur;
    switch (p.sig) {
    case DpiSig::VALID:  c.valid = getv(sample, off, 1); break;
    case DpiSig::CREDIT: c.credit = getv(sample, off, 1); break;
    case DpiSig::STALL:  c.stall = getv(sample, off, 1); break;
    case DpiSig::TID:    c.tid = getv(sample, off, 64); break;
    case DpiSig::PAYLOAD:
      for (uint32_t b = 0; b < p.width; b += 64) {
        const uint32_t n = std::min<uint32_t>(64, p.width - b);
        c.payload.set(b, n, getv(sample, off + b, n));
      }
      break;
    }
    off += p.width;
  }
  // 2. this block's half of nxt, as Slot::begin() leaves it
  for (unsigned j = 0; j != t.nports; ++j) {
    const DpiPort &p = t.ports[j];
    if (!p.out) continue;
    SlotEnd &e = endOf(slots[s.slot[j]], p);
    switch (p.sig) {
    case DpiSig::VALID:   e.nxt.valid = false; break;
    case DpiSig::CREDIT:  e.nxt.credit = false; break;
    case DpiSig::STALL:   e.nxt.stall = false; break;
    case DpiSig::TID:     e.nxt.tid = e.cur.tid; break;
    case DpiSig::PAYLOAD: e.nxt.payload = e.cur.payload; break;
    }
  }
  // 3. the block's cycle
  auto &blocks = g->m->blocks();
  if (!rst) (s.inst < 0 ? blocks.back() : blocks[s.inst])->cycle(uint64_t(cyc));
  // 4. nxt -> drive, first output at the LSB
  std::memset(drive, 0, ((t.drive_bits + 31) / 32) * sizeof(svBitVecVal));
  off = 0;
  for (unsigned j = 0; j != t.nports; ++j) {
    const DpiPort &p = t.ports[j];
    if (!p.out) continue;
    const SlotSignals &n = endOf(slots[s.slot[j]], p).nxt;
    switch (p.sig) {
    case DpiSig::VALID:  putv(drive, off, 1, n.valid); break;
    case DpiSig::CREDIT: putv(drive, off, 1, n.credit); break;
    case DpiSig::STALL:  putv(drive, off, 1, n.stall); break;
    case DpiSig::TID:    putv(drive, off, 64, n.tid); break;
    case DpiSig::PAYLOAD:
      for (uint32_t b = 0; b < p.width; b += 64) {
        const uint32_t n64 = std::min<uint32_t>(64, p.width - b);
        putv(drive, off + b, n64, n.payload.get(b, n64));
      }
      break;
    }
    off += p.width;
  }
}

} // namespace

extern "C" {

int ccv_dpi_register(const char *path) {
  if (!g) init();
  std::string n = path ? path : "";
  // A block sits in its hardening wrapper as u_blk; the wrapper carries the
  // instance's name (tb.u_top.u_lane_05.u_blk). The testbench's end of
  // EXTERNAL is tb.u_ext.
  std::vector<std::string> parts;
  for (size_t a = 0, d; a <= n.size(); a = d + 1) {
    d = n.find('.', a);
    if (d == std::string::npos) d = n.size();
    parts.push_back(n.substr(a, d - a));
  }
  n = parts.back();
  if (n == "u_blk" && parts.size() > 1) n = parts[parts.size() - 2];
  Shim s;
  s.name = n;
  s.inst = instOf(n);
  const char *tn = s.inst < 0 ? "ext" : blkName(kBlkInsts[s.inst].type);
  s.type = kNumDpiTypes;
  for (unsigned t = 0; t != kNumDpiTypes; ++t)
    if (!std::strcmp(kDpiTypes[t].name, tn)) s.type = t;
  if (s.type == kNumDpiTypes) die("no DPI port table for %s", tn);
  const size_t seen = size_t(s.inst < 0 ? kNumBlkInsts : unsigned(s.inst));
  if (g->seen[seen]) die("%s registered twice", n.c_str());
  g->seen[seen] = true;
  s.skew = n == g->skew_name;
  resolve(s);
  g->shims.push_back(std::move(s));
  return int(g->shims.size() - 1);
}

svBit ccv_dpi_skew(int h) { return g->shims.at(size_t(h)).skew; }

#define CCV_DPI_CYCLE(t, i)                                                    \
  void ccv_dpi_cycle_##t(int h, long long cyc, svBit rst,                     \
                         const svBitVecVal *sample, svBitVecVal *drive) {     \
    cycle(i, h, cyc, rst, sample, drive);                                      \
  }
CCV_DPI_TYPES(CCV_DPI_CYCLE)
#undef CCV_DPI_CYCLE

svBit ccv_dpi_done(long long c) {
  if (!g) die("no shim registered: is the top built from rtl/top/dpi/?");
  return g->end.after(uint64_t(c), g->k, *g->m) || uint64_t(c) + 1 == g->cap;
}

void ccv_dpi_report() {
  ccv::traceWriter().close();
  // Which blocks were C++ through a shim: all of them, for this build to mean
  // what it says. A stub left in the file list would be quiet and idle.
  unsigned n = 0;
  for (bool b : g->seen) n += b;
  std::printf("SVHOST shims=%u/%u skewed=%s\n", n, kNumBlkInsts + 1,
              g->skew_name.empty() ? "none" : g->skew_name.c_str());
  printKernelReport(g->k, *g->m, g->end,
                    int(Verilated::threadContextp()->errorCount()));
  if (!g->trace.empty() && g->k.brk == "none") xferCheck(g->trace);
  std::fflush(stdout);
}

} // extern "C"
