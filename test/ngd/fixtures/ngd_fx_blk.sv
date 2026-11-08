// check-ngd fixtures: blocks assembled, for the block checks. A source
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

// One gate between an input and its flop: inside the old 12-NGD port budget,
// but a crossing carries no logic (AR's rev 285 (5)), so the block fails.
module ngd_fx_blk_onein (
  input  logic       clk,
  input  logic [1:0] i,
  output logic       o
);
  always_ff @(posedge clk) o <= i[0] & i[1];
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

// The parent's wire, fanned out (RA-33 on the parent's net; 2026-11-06):
// u_src.y straight into N receivers' a. The selftest's budgets meet
// exactly, y required at 15 and a arriving at 15, so the connection
// converges only while its N pins on the parent's net cost no fanout term:
// N = 4 passes, N = 8 is one INV stage past FO4 and does not converge.
module ngd_fx_asm_fan #(parameter int N = 8) (
  input  logic         clk,
  input  logic [3:0]   i,
  output logic [N-1:0] o
);
  logic [3:0] i_q;
  logic       y;
  always_ff @(posedge clk) i_q <= i;
  ngd_fx_bsrc u_src (.clk(clk), .d(i_q), .y(y));
  for (genvar k = 0; k < N; k++) begin : g_dst
    ngd_fx_bdst u_dst (.clk(clk), .a(y), .b(i_q[3]), .q(o[k]));
  end
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

// A parameterised inner helper (OI-69): Yosys names its derived copy
// $paramod$<sha1>\ngd_fx_pinner, its 64-bit parameter string being long, and
// check-ngd must flatten that form into its parent as well.
module ngd_fx_pinner #(
  parameter logic [63:0] K = 64'h0
) (
  input  logic a,
  input  logic b,
  output logic y
);
  assign y = a ^ b ^ K[0];
endmodule

module ngd_fx_asm_pinner (
  input  logic       clk,
  input  logic [3:0] i,
  output logic       o
);
  logic [3:0] i_q;
  logic       y, g;
  always_ff @(posedge clk) i_q <= i;
  ngd_fx_bsrc  u_src (.clk(clk), .d(i_q), .y(y));
  ngd_fx_pinner #(.K(64'hdeadbeef_deadbeef)) u_inn (.a(y), .b(i_q[2]), .y(g));
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

// The boundary rule as a sum of parts (Daniel, 2026-11-06): a block port
// wired straight to a child's pin is held to that pin's own measurement, at
// the child's parameters. Two tops:
//   ngd_fx_blk_kidout  an output wired from ngd_fx_src's y, a multiply after
//                      its flops: not straight from a flop, through the child
//   ngd_fx_blk_kidin   an input wired into ngd_fx_dst's a, a multiply before
//                      its flop: not straight into one, through the child
module ngd_fx_blk_kidout (
  input  logic       clk,
  input  logic [3:0] i,
  output logic [3:0] o
);
  logic [3:0] i_q;
  always_ff @(posedge clk) i_q <= i;
  ngd_fx_src #(.W(2)) u_src (.clk(clk), .d(i_q), .y(o));
endmodule

module ngd_fx_blk_kidin (
  input  logic       clk,
  input  logic [3:0] i,
  output logic [3:0] o
);
  ngd_fx_dst #(.W(2)) u_dst (.clk(clk), .a(i), .q(o));
endmodule

// The boundary with the fanout term (2026-11-06): an input wired straight
// into N children's flops. Its net carries N pins in the parent, so past 4
// it is a buffer tree before those flops, not straight into one: N = 4
// passes, N = 8 does not.
module ngd_fx_reg (
  input  logic clk,
  input  logic a,
  output logic q
);
  always_ff @(posedge clk) q <= a;
endmodule

module ngd_fx_blk_fanin #(parameter int N = 8) (
  input  logic         clk,
  input  logic         i,
  output logic [N-1:0] o
);
  for (genvar k = 0; k < N; k++) begin : g_reg
    ngd_fx_reg u_reg (.clk(clk), .a(i), .q(o[k]));
  end
endmodule

// The hidden stage at a flopped end (AR's rev 310): a block inside a wrapper
// whose own flops stand for the repeaters' boundary flops. Channel c is the
// block's sending end, r its receiving end, each a valid and a 4-bit payload.
//   ngd_fx_hwrp_reg  the block takes r whole straight into its flops and
//                    drives c whole straight from them: at flopped ends, two
//                    registers in series each way; at no-flop ends, fine
//   ngd_fx_hwrp_mix  one payload bit of each through a gate: the port is the
//                    block's logic, timed to its budget, so it passes even
//                    with its other bits straight (held tags)
module ngd_fx_hblk_reg (
  input  logic       clk,
  input  logic       r_valid,
  input  logic [3:0] r_payload,
  output logic       c_valid,
  output logic [3:0] c_payload
);
  always_ff @(posedge clk) begin
    c_valid   <= r_valid;
    c_payload <= r_payload;
  end
endmodule

module ngd_fx_hblk_mix (
  input  logic       clk,
  input  logic       r_valid,
  input  logic [3:0] r_payload,
  output logic       c_valid,
  output logic [3:0] c_payload
);
  logic [3:0] p;
  always_ff @(posedge clk) begin
    c_valid <= r_valid;
    p       <= {r_payload[3:1], r_payload[0] ^ r_payload[1]};
  end
  assign c_payload = {p[3:1], p[0] & p[1]};
endmodule

module ngd_fx_hwrp_reg (
  input  logic       clk,
  input  logic       r_valid,
  input  logic [3:0] r_payload,
  output logic       c_valid,
  output logic [3:0] c_payload
);
  logic       rv, cv;
  logic [3:0] rp, cp;
  always_ff @(posedge clk) begin
    rv <= r_valid;  rp <= r_payload;
    c_valid <= cv;  c_payload <= cp;
  end
  ngd_fx_hblk_reg u_blk (.clk(clk), .r_valid(rv), .r_payload(rp), .c_valid(cv), .c_payload(cp));
endmodule

module ngd_fx_hwrp_mix (
  input  logic       clk,
  input  logic       r_valid,
  input  logic [3:0] r_payload,
  output logic       c_valid,
  output logic [3:0] c_payload
);
  logic       rv, cv;
  logic [3:0] rp, cp;
  always_ff @(posedge clk) begin
    rv <= r_valid;  rp <= r_payload;
    c_valid <= cv;  c_payload <= cp;
  end
  ngd_fx_hblk_mix u_blk (.clk(clk), .r_valid(rv), .r_payload(rp), .c_valid(cv), .c_payload(cp));
endmodule

// The one-cell capture (AR's rev 326, re:RI-22 (3)): a block input wired to a
// child whose flop takes it under the flop's own synchronous reset (an AND
// with the flopped reset, RST-1) or its own enable from the child's flops
// (CG-5) is straight into that flop. One gate more is logic.
//   MODE 0  reset: if (!rst_q) q <= 0; else q <= a                 straight
//   MODE 1  reset and an own-flop enable                            straight
//   MODE 2  reset, and a & k_q: one gate more                       refused
//   MODE 3  the reset port itself, not flopped (RST-1)              refused
//   MODE 4  an enable from input b, not the child's flops (CG-5)    refused
module ngd_fx_cap #(parameter int MODE = 0) (
  input  logic clk,
  input  logic rst_n,
  input  logic a,
  input  logic b,
  output logic q,
  output logic k
);
  logic rst_q, en_q;
  always_ff @(posedge clk) rst_q <= rst_n;
  always_ff @(posedge clk) begin
    if (!rst_q) begin
      en_q <= 1'b0;
      k    <= 1'b0;
    end else begin
      en_q <= ~en_q;
      k    <= b;
    end
  end
  if (MODE == 0) begin : g_rst
    always_ff @(posedge clk) if (!rst_q) q <= 1'b0; else q <= a;
  end else if (MODE == 1) begin : g_en
    always_ff @(posedge clk) if (!rst_q) q <= 1'b0; else if (en_q) q <= a;
  end else if (MODE == 2) begin : g_gate
    always_ff @(posedge clk) if (!rst_q) q <= 1'b0; else q <= a & k;
  end else if (MODE == 3) begin : g_raw
    always_ff @(posedge clk) if (!rst_n) q <= 1'b0; else q <= a;
  end else begin : g_inen
    always_ff @(posedge clk) if (!rst_q) q <= 1'b0; else if (b) q <= a;
  end
endmodule

module ngd_fx_blk_cap #(parameter int MODE = 0) (
  input  logic clk,
  input  logic rst_n,
  input  logic i,
  input  logic j,
  output logic o,
  output logic p
);
  ngd_fx_cap #(.MODE(MODE)) u_cap (.clk(clk), .rst_n(rst_n), .a(i), .b(j), .q(o), .k(p));
endmodule

// A zero-cycle end of the second kind (params/links.json no_flop_port_budget;
// AR's rev 326): the wrapper wires r_payload straight to the block, whose
// child takes it through logic (a W-bit multiply) before its flop. Held to
// the block's input budget for the port, 12 by default, instead of straight
// in: W = 2 within it, W = 8 over it; unlisted, held straight in.
module ngd_fx_zblk #(parameter int W = 2) (
  input  logic           clk,
  input  logic [2*W-1:0] r_payload,
  output logic [2*W-1:0] q
);
  ngd_fx_dst #(.W(W)) u_dst (.clk(clk), .a(r_payload), .q(q));
endmodule

module ngd_fx_zwrp #(parameter int W = 2) (
  input  logic           clk,
  input  logic [2*W-1:0] r_payload,
  output logic [2*W-1:0] q
);
  ngd_fx_zblk #(.W(W)) u_blk (.clk(clk), .r_payload(r_payload), .q(q));
endmodule
