// case: unique case implied assertion
// expect_sim: CHECK
// expect_formal: CHECK
// §6 lists this as a rule to encode: the implied assertion fires on no-match,
// which is what an X selector looks like once §6 has banned X on control.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  logic [1:0] selc;
  logic       y;
  assign selc = {a, b};               // takes 2'b00 (no match) and 2'b10
  always_comb begin
    y = 1'b0;                         // no inferred latch
    unique case (selc)
      2'b10: y = 1'b1;
      2'b01: y = 1'b0;
    endcase
  end
  assign o = y & ~rst;
endmodule
