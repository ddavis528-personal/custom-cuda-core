// case: priority case implied assertion
// expect_sim: CHECK
// expect_formal: CHECK
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  logic [1:0] selc;
  logic       y;
  assign selc = {a, b};
  always_comb begin
    y = 1'b0;
    priority case (selc)
      2'b10: y = 1'b1;
      2'b01: y = 1'b0;
    endcase
  end
  assign o = y & ~rst;
endmodule
