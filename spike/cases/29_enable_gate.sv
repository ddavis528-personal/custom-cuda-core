// case: runtime enable gate (the $assertoff substitute)
// expect_sim: SILENCED
// expect_formal: CHECK
//
// Case 27 establishes that $assertoff is unavailable in the entire free
// simulator stack -- Verilator does not implement it, Icarus parses it and
// then has no runtime definition. §7 nonetheless requires a runtime knob that
// gates *firing* without removing the property from what formal reads, and is
// explicit that `ifdef-ing properties out is not an acceptable substitute.
//
// This case measures the mechanism that satisfies both: a guard signal ANDed
// into the property's condition. The property stays fully elaborated in every
// flow, so formal reads the same source; only whether it can fire changes.
//
// THE TRAP, and why the formal expectation here is CHECK and not SILENCED:
// if the guard were a free variable under formal, the solver would simply
// choose 0 and every property in the design would pass vacuously. So under
// FORMAL the guard must be a constant 1. This case is written that way, and
// the sby column proves the property still bites -- which is the only evidence
// that the knob has not quietly disarmed the formal flow.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
`ifdef FORMAL
  localparam logic assert_en = 1'b1;     // never a free variable
`else
  logic assert_en = 1'b0;                // simulation default for THIS case: off
`endif
  always @(posedge clk) if (!rst && assert_en) begin
`ifdef FORMAL
    // Yosys's native front end rejects the `else` action block (case 01), so
    // the message half is dropped in the formal flow. Note what this `ifdef
    // does and does not do: it varies the property's SPELLING per tool, it
    // does not remove the property from any flow. §7 forbids the latter; this
    // is the former, and the library is where it belongs so that no block ever
    // writes it by hand.
    assert (!(a && !b));
`else
    assert (!(a && !b)) else $error("29: fired while gated off");
`endif
  end
endmodule
