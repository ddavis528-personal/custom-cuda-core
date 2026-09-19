// case: disable iff
// expect_sim: CHECK
// expect_formal: CHECK
// Load-bearing for §6's global synchronous reset: every interface property is
// meant to be vacuous under reset rather than hand-guarded at each call site.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  // Without `disable iff` this would also fire during reset. It must fire at
  // cycle 3 and NOT during cycles 0-1.
  a_dis: assert property (@(posedge clk) disable iff (rst) !(a && !b))
    else $error("06: disable iff fired");
endmodule
