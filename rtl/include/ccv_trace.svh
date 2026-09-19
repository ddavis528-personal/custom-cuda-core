//===-- ccv_trace.svh - RTL-side event emit -----------------------*- SV -*-===//
//
// The SystemVerilog half of §8's Stage 1c DPI-C decision. Declares the imports
// that sim/dpi/ccv_event_dpi.cpp defines, and wraps them so instrumentation
// reads the same way in RTL as it does in the C++ timing model.
//
// WHERE THIS BELONGS, AND WHERE IT DOES NOT. This is TESTBENCH instrumentation,
// not design RTL. §9 requires assertions to prefer `bind` so properties stay
// out of the synthesizable source; event emission has the same requirement for
// the same reason, and more strongly -- a DPI import in a design module is not
// synthesizable at all. Instrumentation is bound to a block from outside it,
// and tools/lint-rtl.py fails a design file that imports these directly.
//
//===----------------------------------------------------------------------===//
`ifndef CCV_TRACE_SVH
`define CCV_TRACE_SVH

`include "ccv_event_ids.svh"

import "DPI-C" function int  ccv_trace_open(input string path);
import "DPI-C" function void ccv_trace_close();
import "DPI-C" function void ccv_trace_emit(input longint cycle,
                                            input longint instr_uid,
                                            input int     event_id,
                                            input int     unit,
                                            input int     a,
                                            input int     b,
                                            input int     c);
import "DPI-C" function longint ccv_trace_count();

// Emit with the payload fields defaulted, which is the common case. Named to
// match the C++ side's EventWriter::emit so that §9's cross-language naming
// rule holds for the emit path too, not only for signals.
// These expand to a complete STATEMENT, semicolon included, exactly as the
// CCV_ASSERT family does. A macro that expands to a bare expression makes
// every call site a syntax error, and the error is reported at the call site
// rather than here, which is a poor trade for saving one character.
`define CCV_EMIT(CYCLE, UID, EVENT, UNIT) \
  ccv_trace_emit(CYCLE, UID, CCV_``EVENT, CCV_``UNIT, 0, 0, 0);

`define CCV_EMIT3(CYCLE, UID, EVENT, UNIT, A, B, C) \
  ccv_trace_emit(CYCLE, UID, CCV_``EVENT, CCV_``UNIT, A, B, C);

`endif // CCV_TRACE_SVH
