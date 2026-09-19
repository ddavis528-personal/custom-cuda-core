// case: $rose/$fell/$stable
// expect_sim: CHECK
// expect_formal: CHECK
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  a_rose: assert property (@(posedge clk) disable iff (rst) $rose(a) |-> b)
    else $error("08: $rose fired");
endmodule
