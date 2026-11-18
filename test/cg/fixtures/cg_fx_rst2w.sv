// check-cg fixture: RST-2 at a level with no state of its own (a wrapper),
// which hands the reset on unflopped: u_pad (cg_fx_rst2b, latency 2) and
// u_one (cg_fx_good, latency 1) both take the wrapper's rst, so u_one needs
// +1 reset stage. tools/check-cg.py --selftest.
module cg_fx_rst2w (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        v1,
  output logic [15:0] d1,
  output logic [7:0]  p1,
  output logic        v2,
  output logic [15:0] d2
);
  cg_fx_rst2b u_pad (.clk(clk), .rst(rst), .in_v(in_v), .in_d(in_d), .out_v(v1), .out_d(d1),
                     .p_o(p1));
  cg_fx_good  u_one (.clk(clk), .rst(rst), .in_v(in_v), .in_d(in_d), .out_v(v2), .out_d(d2));
endmodule
