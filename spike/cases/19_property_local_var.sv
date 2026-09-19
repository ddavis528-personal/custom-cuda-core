// case: property local variables
// expect_sim: CHECK
// expect_formal: CHECK
// Needed for any contract that carries a tag or ID from request to response --
// the barrier unit's epoch-tagged arrive/wait (a §7 formal target) is exactly
// this shape, so a SILENT cell here narrows what can be expressed about it.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  property p_carry;
    logic v;
    @(posedge clk) disable iff (rst) (a, v = b) |=> (v == 1'b1);
  endproperty
  a_local: assert property (p_carry) else $error("19: local-var property fired");
endmodule
