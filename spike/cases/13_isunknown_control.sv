// case: $isunknown on un-reset control
// expect_sim: CHECK
// expect_formal: CHECK
// runners: iverilog,verilator,sby
//
// §6's core move -- prohibit X on control rather than propagate it -- and the
// case that exposes the blind spot the same section warns about. `sel` is
// un-reset control, which is exactly what the §6 invariant forbids (un-reset
// state is payload, guarded by an always-reset valid bit; control is reset).
//
// A 4-state tool sees `sel` as X before cycle 3 and the property fires. A
// 2-state tool gives it a defined value and the property CANNOT fire. That
// divergence is the finding, not a tool bug: it is why §6 pulls the Icarus
// X-pass forward to per-block 4c rather than leaving it at closure.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  logic sel;                          // deliberately un-reset control
  always @(posedge clk) if (a) sel <= b;
  assign o = sel;
  a_ctrl_known: assert property (@(posedge clk) disable iff (rst) !$isunknown(sel))
    else $error("13: X reached control");
endmodule
