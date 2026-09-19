// case: throughout
// expect_sim: CHECK
// expect_formal: CHECK
// "This holds for the whole transaction" -- the natural way to state a stable-
// while-stalled interface contract, which every ready/valid boundary in §8
// Stage 2 needs.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  a_thru: assert property (@(posedge clk) disable iff (rst) a |-> (b throughout (1'b1 ##1 1'b1)))
    else $error("22: throughout fired");
endmodule
