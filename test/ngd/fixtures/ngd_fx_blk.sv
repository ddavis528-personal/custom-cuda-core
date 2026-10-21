// check-ngd fixtures: blocks assembled, for the whole-block pass. A source
// whose output is a multiply after its flops and a sink whose input is a
// multiply before its flop, 2 bits (shallow) or 8 (deep). Two multiplies in
// series do not merge into one shallower tree, as two parities would when
// flattened; four tops:
//   ngd_fx_blk_ok      shallow into shallow, ports registered: passes
//   ngd_fx_blk_long    deep into deep: flop to flop over the stage
//   ngd_fx_blk_comb    an output driven through a gate after its flops
//   ngd_fx_blk_deepin  an input through 64-bit parity before its flop
// tools/check-ngd.py --selftest.
module ngd_fx_src #(parameter int W = 2) (
  input  logic           clk,
  input  logic [2*W-1:0] d,
  output logic [2*W-1:0] y
);
  logic [2*W-1:0] q;
  always_ff @(posedge clk) q <= d;
  assign y = q[W-1:0] * q[2*W-1:W];
endmodule

module ngd_fx_dst #(parameter int W = 2) (
  input  logic           clk,
  input  logic [2*W-1:0] a,
  output logic [2*W-1:0] q
);
  always_ff @(posedge clk) q <= a[W-1:0] * a[2*W-1:W];
endmodule

module ngd_fx_blk_ok (
  input  logic       clk,
  input  logic [3:0] i,
  output logic [3:0] o
);
  logic [3:0] i_q, y;
  always_ff @(posedge clk) i_q <= i;
  ngd_fx_src #(.W(2)) u_src (.clk(clk), .d(i_q), .y(y));
  ngd_fx_dst #(.W(2)) u_dst (.clk(clk), .a(y), .q(o));
endmodule

module ngd_fx_blk_long (
  input  logic        clk,
  input  logic [15:0] i,
  output logic [15:0] o
);
  logic [15:0] i_q, y;
  always_ff @(posedge clk) i_q <= i;
  ngd_fx_src #(.W(8)) u_src (.clk(clk), .d(i_q), .y(y));
  ngd_fx_dst #(.W(8)) u_dst (.clk(clk), .a(y), .q(o));
endmodule

module ngd_fx_blk_comb (
  input  logic       clk,
  input  logic [1:0] i,
  output logic       o
);
  logic [1:0] q;
  always_ff @(posedge clk) q <= i;
  assign o = q[0] & q[1];
endmodule

module ngd_fx_blk_deepin (
  input  logic        clk,
  input  logic [63:0] i,
  output logic        o
);
  always_ff @(posedge clk) o <= ^i;
endmodule

// The budget files' convergence pass (tools/check-ngd.py converge()): a
// source whose output is one gate after its flops and a sink whose input is
// one gate before its flop, each with a budget file beside it
// (ngd_fx_bsrc.ngd.json: y required at 14; ngd_fx_bdst.ngd.json: a arriving
// at 15), and an inner helper, an XOR (ngd_fx_inner.ngd.json). Four tops:
//   ngd_fx_asm_ok         y straight into a: 14 by 15, converges
//   ngd_fx_asm_gap        y through an XOR into a: logic on a path that
//                         touches none of the parent's flops (NGD-5)
//   ngd_fx_asm_inner      y through the inner helper into the parent's flop:
//                         the helper's XOR is the parent's, 14 plus it within
//                         the stage; cut out at its default ports instead,
//                         14 would miss its input's 13
//   ngd_fx_asm_inner_gap  y through the inner helper into a: glue (NGD-5)
module ngd_fx_bsrc (
  input  logic       clk,
  input  logic [3:0] d,
  output logic       y
);
  logic [3:0] q;
  always_ff @(posedge clk) q <= d;
  assign y = q[0] & q[1];
endmodule

module ngd_fx_bdst (
  input  logic clk,
  input  logic a,
  input  logic b,
  output logic q
);
  always_ff @(posedge clk) q <= a ^ b;
endmodule

module ngd_fx_asm_ok (
  input  logic       clk,
  input  logic [3:0] i,
  output logic       o
);
  logic [3:0] i_q;
  logic       y;
  always_ff @(posedge clk) i_q <= i;
  ngd_fx_bsrc u_src (.clk(clk), .d(i_q), .y(y));
  ngd_fx_bdst u_dst (.clk(clk), .a(y), .b(i_q[3]), .q(o));
endmodule

module ngd_fx_asm_gap (
  input  logic       clk,
  input  logic [3:0] i,
  output logic       o
);
  logic [3:0] i_q;
  logic       y, g;
  always_ff @(posedge clk) i_q <= i;
  ngd_fx_bsrc u_src (.clk(clk), .d(i_q), .y(y));
  assign g = y ^ (i_q[2] & i_q[3]);
  ngd_fx_bdst u_dst (.clk(clk), .a(g), .b(i_q[3]), .q(o));
endmodule

module ngd_fx_inner (
  input  logic a,
  input  logic b,
  output logic y
);
  assign y = a ^ b;
endmodule

module ngd_fx_asm_inner (
  input  logic       clk,
  input  logic [3:0] i,
  output logic       o
);
  logic [3:0] i_q;
  logic       y, g;
  always_ff @(posedge clk) i_q <= i;
  ngd_fx_bsrc  u_src (.clk(clk), .d(i_q), .y(y));
  ngd_fx_inner u_inn (.a(y), .b(i_q[2]), .y(g));
  always_ff @(posedge clk) o <= g;
endmodule

module ngd_fx_asm_inner_gap (
  input  logic       clk,
  input  logic [3:0] i,
  output logic       o
);
  logic [3:0] i_q;
  logic       y, g;
  always_ff @(posedge clk) i_q <= i;
  ngd_fx_bsrc  u_src (.clk(clk), .d(i_q), .y(y));
  ngd_fx_inner u_inn (.a(y), .b(i_q[2]), .y(g));
  ngd_fx_bdst  u_dst (.clk(clk), .a(g), .b(i_q[3]), .q(o));
endmodule
