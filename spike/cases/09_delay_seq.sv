// case: ##n sequence delay
// expect_sim: CHECK
// expect_formal: CHECK
// Request-to-response contracts at the §8 Stage 2 interfaces need this shape.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  a_delay: assert property (@(posedge clk) disable iff (rst) a ##1 1'b1 |-> b)
    else $error("09: ##1 fired");
endmodule
