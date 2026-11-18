// check-ngd and check-cg fixture: a block whose child the strict Yosys
// (tools/shim/yosys, OI-44) cannot synthesise, a combinational loop. A
// block's checks are a sum of parts (Daniel, 2026-11-06): its hierarchy is
// read structurally and each level timed alone with its children as black
// boxes, so nothing here synthesises ngd_fx_loop, and both checks pass the
// read; synthesising the hierarchy with its children kept fails.
// tools/check-ngd.py --selftest, tools/check-cg.py --selftest.
module ngd_fx_loop (
  input  logic a,
  output logic y
);
  logic x;
  assign x = ~(x & a);
  assign y = x;
endmodule

module ngd_fx_blk_loopkid (
  input  logic       clk,
  input  logic [1:0] i,
  output logic       o
);
  logic [1:0] i_q;
  logic       y;
  always_ff @(posedge clk) i_q <= i;
  ngd_fx_loop u_loop (.a(i_q[0]), .y(y));
  always_ff @(posedge clk) o <= y ^ i_q[1];
endmodule
