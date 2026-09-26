// case: $isunknown on un-reset control, immediate form
// expect_sim: CHECK
// expect_formal: CHECK
//
// §6's central rule, in the form most likely to survive the toolchain. Read
// this cell against case 13.
//
// The expected result is a DIVERGENCE, and the divergence is the finding:
// Icarus sees `sel` as X before it is first written and fires; Verilator, being
// 2-state, gives it a defined value and structurally CANNOT fire. That is why
// §6 pulls the Icarus X-pass forward to per-block Stage 4c instead of leaving
// it at closure, and why Verilator's X-randomization is run between X-passes.
// A `SILENT` in the Verilator column here is the correct answer, not a gap.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  logic sel;                       // un-reset control -- violates the §6 invariant on purpose
  always @(posedge clk) if (a) sel <= b;
  assign o = sel;
  always @(posedge clk) if (!rst) begin
    assert (!$isunknown(sel)) else $error("26: X reached control");
  end
endmodule
