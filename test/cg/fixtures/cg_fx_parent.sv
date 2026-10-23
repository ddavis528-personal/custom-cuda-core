// check-cg fixture: a parent whose design children are blackboxed, each
// measured in its own unit (OI-71). u_ok takes the parent's reset straight on
// its own reset port, rst, which cg_fx_good flops itself (its unit's RST-1
// says so), so the parent's RST-1 passes it. u_bad takes the same reset on a
// data pin, in_v, which no unit flops as a reset: RST-1 refuses it.
// tools/check-cg.py --selftest.
module cg_fx_parent (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d,
  output logic        v2,
  output logic [15:0] d2
);
  cg_fx_good u_ok  (.clk(clk), .rst(rst), .in_v(in_v), .in_d(in_d), .out_v(out_v), .out_d(out_d));
  cg_fx_good u_bad (.clk(clk), .rst(1'b0), .in_v(rst), .in_d(in_d), .out_v(v2), .out_d(d2));
endmodule
