// case: $assertoff / $asserton runtime control
// expect_sim: SILENCED
// expect_formal: SKIP
// runners: iverilog,verilator
//
// Read against case 01, which is the SAME property with no runtime control:
// 01 must report a failure and 16 must not. A tool where both report a failure
// has parsed $assertoff and ignored it, and the §7 runtime knob would be a
// no-op there -- which is not visible from a compile check.
//
// NOTE the `initial` block: §9 bans `initial` for reset behaviour in design
// RTL. This is a spike case, not design RTL, and the real primitive library
// (1b) centralises this so no block ever writes it by hand.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  a_silenced: assert property (@(posedge clk) disable iff (rst) a |-> b)
    else $error("16: property fired while OFF -- $assertoff is a no-op here");
  initial begin
    $assertoff(0, dut);
  end
endmodule
