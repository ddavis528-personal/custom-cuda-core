//===-- bad_if_checker.sv - lint fixture for the interface convention ---===//
//
// Spec: docs/interface-checker-convention.md
//
// Companion to bad_module.sv, for the four rules that only apply to interface
// checkers. Every violation is intentional and referenced by rule id in
// docs/rtl-coding-style.md.
//
// DO NOT FIX THE VIOLATIONS IN THIS FILE. tools/check-1d.sh fails if any rule
// stops firing here, which makes this a regression test for the lint layer.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

module bad_if_checker #(
  parameter int MODE = `CCV_MODE_ASSERT
) (
  input logic   clk,
  input logic   rst,
  input issue_t iss,
  input logic   iss_ready
);

  // CCV-L15: bare `CCV_ASSERT in a checker. The MODE parameter above is
  // silently ignored, so this checker cannot act as a formal cut-point and the
  // ASSUME side is absent -- which presents as a proof that succeeded.
  `CCV_ASSERT(bad_not_mode_resolved, !(iss.valid && !iss_ready) || iss.valid)

  // CCV-L14 is violated by omission: no `CCV_IF_SAT anywhere in this file, so
  // a contradictory assumption set here would make every dependent proof
  // vacuously true with nothing to signal it.

endmodule

// CCV-L13: `bind` at a design boundary. Yosys parses this, ignores it, and
// garbage-collects the checker (F-9), so a proof relying on it checks nothing
// and reports success.
bind issue_producer bad_if_checker u_bad (
  .clk(clk), .rst(rst), .iss(iss), .iss_ready(iss_ready)
);
