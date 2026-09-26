// case: cover property
// expect_sim: COVER
// expect_formal: COVER
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  c_reach: cover property (@(posedge clk) disable iff (rst) a);
endmodule
