// case: assert property |=>
// expect_sim: CHECK
// expect_formal: CHECK
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  a_nonoverlap: assert property (@(posedge clk) disable iff (rst) a |=> b)
    else $error("05: |=> fired");
endmodule
