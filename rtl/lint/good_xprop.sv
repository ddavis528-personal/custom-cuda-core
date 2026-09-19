//===-- good_xprop.sv - X-determinism, all three legal routes ------------===//
//
// Spec: docs/rtl-coding-style.md, X-propagation section
//
// The false-positive regression. A rule this aggressive is only usable if
// compliant code is silent, so this exercises each legal route on control
// inputs that are otherwise exactly as suspicious as bad_xprop.sv's.
//
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`include "ccv_xprop.svh"

module good_xprop (
  input  logic       clk,
  input  logic       rst,
  input  logic       ctrl_in,
  input  logic [1:0] sel_in,
  input  logic [3:0] idx_in,
  input  logic [7:0] a_in,
  input  logic [7:0] b_in,
  output logic [7:0] y,
  output logic [7:0] z,
  output logic [7:0] q,
  output logic [7:0] v
);

  logic [7:0] mem [0:15];

  // ROUTE 1 -- PROHIBITION. The control inputs are asserted X-free, so an
  // ordinary `if` and an ordinary `case` are legal and read naturally.
  `CCV_ASSERT_KNOWN(ctrl_known, ctrl_in)
  `CCV_ASSERT_KNOWN(sel_known,  sel_in)
  `CCV_ASSERT_KNOWN(idx_known,  idx_in)

  always_comb begin
    if (ctrl_in) y = a_in;
    else         y = b_in;
  end

  always_ff @(posedge clk) begin
    mem[idx_in] <= a_in;
  end

  // ROUTE 2 -- TMERGE. A ternary is not an if/case, so it never reaches the
  // rules; it merges by LRM semantics. Legal even though nothing asserts the
  // selector known.
  assign v = `CCV_XMUX4(sel_in, a_in, b_in, 8'd0, 8'hff);

  // ROUTE 3 -- XMERGE. A case with an X prologue covering everything it
  // assigns. The selector needs no KNOWN assertion, because an unknown
  // selector produces a deterministic X rather than a silent branch.
  always_comb begin
    z = 'x;
    case (sel_in)
      2'd0: z = a_in;
      2'd1: z = b_in;
      2'd2: z = 8'd0;
      2'd3: z = 8'hff;
    endcase
  end

  // ROUTE 3 again, using a `default:` branch rather than a prologue.
  always_comb begin
    case (sel_in)
      2'd0:    q = a_in;
      2'd1:    q = b_in;
      default: q = 'x;
    endcase
  end

endmodule
