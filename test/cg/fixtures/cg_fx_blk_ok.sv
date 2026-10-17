// check-cg fixture: a block whose budget takes cg_fx_small's finding.
// 2 x 128 + 4 = 260 flops; 2% is 5.2, and the finding is 4.
// tools/check-cg.py --selftest.
module cg_fx_blk_ok (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  wire        v0, v1, v2;
  wire [15:0] d0, d1, d2;
  cg_fx_wide  u_w0 (.clk, .rst, .in_v, .in_d,         .out_v(v0), .out_d(d0));
  cg_fx_wide  u_w1 (.clk, .rst, .in_v, .in_d(~in_d),  .out_v(v1), .out_d(d1));
  cg_fx_small u_s0 (.clk, .rst, .in_v, .in_d,         .out_v(v2), .out_d(d2));
  assign out_v = v0 ^ v1 ^ v2;
  assign out_d = d0 ^ d1 ^ d2;
endmodule
