// case: assert property |->
// expect_sim: CHECK
// expect_formal: CHECK
// The workhorse shape. Nearly every interface contract in §8 Stage 2 is this.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  a_overlap: assert property (@(posedge clk) disable iff (rst) a |-> b)
    else $error("04: |-> fired");
endmodule
