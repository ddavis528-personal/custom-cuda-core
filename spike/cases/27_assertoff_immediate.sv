// case: $assertoff against immediate assertions
// expect_sim: SILENCED
// expect_formal: SKIP
// runners: iverilog,verilator
// Read against case 23/01, which is the same property with no runtime control.
// §7 requires the knob to gate firing WITHOUT removing the property from what
// formal reads, so `ifdef is not an acceptable substitute and this cell is the
// only evidence the supported mechanism works.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  always @(posedge clk) if (!rst) begin
    assert (!(a && !b)) else $error("27: fired while OFF -- $assertoff is a no-op here");
  end
  initial $assertoff(0);   // level 0, all scopes -- a module-name scope arg does not resolve when the TB is top
endmodule
