// case: $past
// expect_sim: CHECK
// expect_formal: CHECK
// Named explicitly in §7's spike list.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  a_past: assert property (@(posedge clk) disable iff (rst) $past(a) |-> b)
    else $error("07: $past fired");
endmodule
