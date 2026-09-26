//===-- ccv_event_dpi.cpp - SystemVerilog -> event library bridge ---------===//
//
// §8's Stage 1c decision, made here rather than discovered at 4c:
//
//   "The event schema is shared by the timing model AND RTL testbench
//    instrumentation, but its RTL consumer doesn't arrive until 4c. That gap
//    is a trap: designing a C++-only emit API at Stage 1c and discovering at
//    4c that SystemVerilog can't feed it cleanly means a retrofit across every
//    block already built. Given C++ is already the timing-model language, the
//    natural answer is DPI-C into a shared emit library -- but this must be an
//    explicit Stage 1c decision, not an assumption discovered later."
//
// So: DPI-C, into the same ccv::EventWriter the timing model writes through.
// One library, one format, one schema, two producers. test/smoke/ exercises
// this path from a trivial SystemVerilog module at 1c, which is what §8's exit
// criteria ask for -- the decision exercised, not merely decided.
//
// C LINKAGE AND FLAT ARGUMENTS, DELIBERATELY. Everything crossing this
// boundary is a scalar. No structs, no strings, no open arrays: DPI struct
// layout compatibility varies across simulators, and this boundary has to work
// under both Verilator and Icarus without a per-tool variant. The cost is a
// wide argument list; the benefit is that the bridge is the one piece of the
// flow that cannot break differently in two tools.
//
//===----------------------------------------------------------------------===//
#include "ccv/event.h"

#include <cstdint>

extern "C" {

/// Open the trace. Returns 1 on success, 0 on failure -- and failure is NOT an
/// error the design should react to: a trace is an observation, and failing to
/// record one must never change what the design does.
int ccv_trace_open(const char *path) {
  return ccv::traceWriter().open(path ? path : "") ? 1 : 0;
}

void ccv_trace_close() { ccv::traceWriter().close(); }

/// Emit one event. Widths are chosen to match what a SystemVerilog `int` and
/// `longint` map to under DPI without the simulator inserting a conversion.
void ccv_trace_emit(long long cycle, long long instr_uid, int event_id,
                    int unit, int a, int b, int c) {
  ccv::traceWriter().emit(static_cast<uint64_t>(cycle),
                          static_cast<uint64_t>(instr_uid),
                          static_cast<ccv::EventId>(event_id),
                          static_cast<uint16_t>(unit),
                          static_cast<uint32_t>(a), static_cast<uint32_t>(b),
                          static_cast<uint32_t>(c));
}

/// Events written so far, so a testbench can check its own instrumentation
/// fired rather than trusting that it did.
long long ccv_trace_count() {
  return static_cast<long long>(ccv::traceWriter().count());
}

} // extern "C"
