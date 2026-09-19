//===-- ccv_if.svh - interface checker convention ----------------*- SV -*-===//
//
// Implements docs/interface-checker-convention.md, against what the Stage 1a
// spike found the tools actually do (docs/stage1a-findings.md F-9 … F-13).
//
// The convention's premise is that three otherwise-separate pieces of work are
// the same artifact: interface assertions, formal cut-points, and RTL-side
// event emission are all observations of traffic crossing a block boundary.
// Writing them once per interface TYPE rather than once per boundary INSTANCE
// gives consistency by construction rather than by discipline.
//
//===----------------------------------------------------------------------===//
//
// WHY CHECKERS ARE INSTANTIATED AND NOT BOUND
//
// The convention's §4 specified `bind`. It is not available (F-9):
//
//     under Verilator   works
//     under Icarus      syntax error on the bind statement -- honest, cheap
//     under Yosys/sby   parses it, IGNORES it, garbage-collects the checker
//
// Yosys prints `Removing unused module '\chk'` and the proof then passes a
// property written to be false. Every standalone block proof would have been
// empty, and nothing in the output would have said so. That is a worse outcome
// than a missing feature, so `bind` is banned at design boundaries (CCV-L13)
// and checkers are instantiated.
//
// What that costs: `bind` kept checkers naturally out of synthesis, and
// instantiation does not. Synthesis is deferred (strategy doc §6), so this is
// recorded debt rather than a present cost -- but it is the one part of `bind`
// with no substitute here.
//
//===----------------------------------------------------------------------===//
`ifndef CCV_IF_SVH
`define CCV_IF_SVH

`include "ccv_assert.svh"
`include "ccv_interfaces.svh"

//===----------------------------------------------------------------------===//
// Modes (convention §3.1)
//
// One checker per interface type, instantiated in different roles depending on
// which side of a boundary it watches. This is what makes formal cut-points
// fall out of the convention instead of being hand-built per block.
//===----------------------------------------------------------------------===//
`define CCV_MODE_ASSERT      0
`define CCV_MODE_ASSUME      1
`define CCV_MODE_COVER_ONLY  2

// Mode selection per side, so a block's standalone formal run re-roles its
// input checkers WITHOUT the design source being edited -- which is the
// flexibility §4 wanted from `bind` and which survives its loss.
//
// tools/run-formal.sh passes -D CCV_STANDALONE_FORMAL for a block-level proof.
`ifdef CCV_STANDALONE_FORMAL
  // Black-box the neighbours: what they guarantee becomes what I may assume.
  `define CCV_IF_MODE_IN  `CCV_MODE_ASSUME
`else
  // Full machine, or simulation: everyone owes their own protocol.
  `define CCV_IF_MODE_IN  `CCV_MODE_ASSERT
`endif
// A block's own outputs are always its obligation. There is no configuration
// in which a block may assume its own correctness.
`define CCV_IF_MODE_OUT `CCV_MODE_ASSERT

//===----------------------------------------------------------------------===//
// Mode-resolved contract.
//
// The assert/assume/cover KEYWORD cannot be selected by a parameter; a
// `generate` picks the branch at elaboration (F-11). Confirmed working in all
// three tools, and confirmed that the ASSUME branch genuinely constrains a
// proof rather than merely elaborating -- spike case 33, with a negative
// control.
//
// Checkers use this rather than `CCV_ASSERT directly, so one checker source
// serves the simulation regression, the X-pass and the proof.
//===----------------------------------------------------------------------===//
`define CCV_CONTRACT_M(MODE, NAME, EXPR)                    \
  generate                                                   \
    if ((MODE) == `CCV_MODE_ASSERT) begin : g_``NAME``_as    \
      `CCV_ASSERT(NAME, EXPR)                                \
    end else if ((MODE) == `CCV_MODE_ASSUME) begin : g_``NAME``_am \
      `CCV_ASSUME(NAME, EXPR)                                \
    end else begin : g_``NAME``_cv                           \
      `CCV_COVER(NAME, EXPR)                                 \
    end                                                      \
  endgenerate

//===----------------------------------------------------------------------===//
// Satisfiability covers (convention §3.3) -- mandatory, not optional.
//
// An internally contradictory `assume` set makes every proof depending on it
// vacuously true, and it fails SILENTLY: the proof passes, reports no
// counterexample, and means nothing. The convention calls this the single most
// dangerous failure mode in the whole formal strategy, and spike cases 34 and
// 35 demonstrate it rather than arguing it -- 34's `assert (1'b0)` PASSES under
// a contradictory assume set; 35's cover returns COVER-MISS and is the only
// signal that anything was wrong.
//
// These covers are UNCONDITIONAL -- never mode-resolved. A cover that
// disappeared in the mode where assumptions are active would be a guard that
// switches off exactly when it is needed. CCV-L14 requires at least one per
// checker.
//===----------------------------------------------------------------------===//
`define CCV_IF_SAT(NAME, EXPR) `CCV_COVER(sat_``NAME, EXPR)

//===----------------------------------------------------------------------===//
// Checker instantiation.
//
// The mode is plumbed by the macro; ports stay explicit, because they differ
// per interface type and hiding them would trade a real readability cost for
// a cosmetic one.
//
//   `CCV_CHECKER(issue_if_checker, u_iss_chk, `CCV_IF_MODE_OUT)
//       (.clk(clk), .rst(rst), .iss(iss), .iss_ready(iss_ready));
//
// Convention: checker instances go at the END of a module, named u_<port>_chk.
//===----------------------------------------------------------------------===//
// The mode formal is named M, not MODE, deliberately. A formal named MODE
// also rewrites the `.MODE(` port name in the body -- the expansion becomes
// `#(.0(0))` -- and the error surfaces at the call site as "unexpected INTEGER
// NUMBER", pointing nowhere near the macro. Cost one build during the 1d work.
`define CCV_CHECKER(TYPE, INST, M) TYPE #(.MODE(M)) INST

//===----------------------------------------------------------------------===//
// Event emission from a checker (convention §5).
//
// The checker already observes every transaction crossing its interface, so it
// is the natural emitter for the load-bearing event class -- which is
// interface-defined by construction. Emission lives in the per-type checker,
// so every instance of an interface type emits IDENTICALLY and blocks get no
// opportunity to drift from the schema.
//
// GUARDED, because Icarus has no DPI at all (F-13): `import "DPI-C"` is an
// invalid module item there in every form. So the same checker still compiles
// for the Icarus X-pass, with its properties fully intact.
//
// Note precisely what is conditional here. Event emission is NOT a property;
// guarding it removes no obligation from any flow. The convention's rule is
// that a property's PRESENCE must never vary, and it does not.
//
// Emission has its own runtime switch, separate from assertion firing
// (convention §6): a correlation run wants events on, a throughput regression
// wants them off, and those are not the same question.
//===----------------------------------------------------------------------===//
`ifdef VERILATOR
  // ccv_trace.svh carries the DPI imports themselves, so it is included HERE
  // rather than at the top of this file: Icarus rejects `import "DPI-C"` as an
  // invalid module item, and including it unconditionally would make every
  // checker uncompilable for the X-pass.
  `include "ccv_trace.svh"
  `define CCV_IF_EMIT(CYCLE, UID, EVENT, UNIT, A, B, C)  \
    if (ccv_assert_pkg::trace_enabled())                 \
      `CCV_EMIT3(CYCLE, UID, EVENT, UNIT, A, B, C)
`else
  // No DPI here. Kept as an empty statement rather than nothing at all, so a
  // call site stays syntactically valid wherever it appears.
  `define CCV_IF_EMIT(CYCLE, UID, EVENT, UNIT, A, B, C) begin end
`endif

`endif // CCV_IF_SVH
