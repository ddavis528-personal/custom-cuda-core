//===-- bad_feedback.sv - lint fixture for declared feedback ------------===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared feedback)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_nofb declares req_cy02h's read of stat_cy03h as feedback, but
// stat_cy03h's next value does not depend on req_cy02h: there is no loop,
// so the declaration is refused and the stage skip it hides is reported.
// It also lists a declaration by OI, not an architect, and one for a read
// its reader does not make. reference_noloop is reference_loop.sv's loop
// with no declaration: the arithmetic refuses the back edge's read.
// reference_badhop has two three-register loops: q's is declared with a hop
// that does not exist (q1 -> q3, where q3's next value reads q2), and p's
// without its registers, so only a two-register loop is looked for and none
// is found. Both are refused.
//===----------------------------------------------------------------------===//

module reference_nofb (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic req_in_cy01h,
  output logic out_cy03h
);
  logic x_cy02h, stat_cy03h, req_cy02h, own_cy02h;
  always_ff @(posedge reference_core_clk) begin
    x_cy02h    <= req_in_cy01h;
    stat_cy03h <= x_cy02h;
  end
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) req_cy02h <= 1'b0;
    else              req_cy02h <= req_in_cy01h & ~stat_cy03h;
  end
  always_ff @(posedge reference_core_clk) begin
    own_cy02h <= req_in_cy01h;
  end
  assign out_cy03h = stat_cy03h & req_cy02h & own_cy02h;
endmodule

module reference_noloop (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic req_in_cy01h,
  output logic gnt_out_cy03h
);
  logic rqn_cy02h, gnn_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) rqn_cy02h <= 1'b0;
    else              rqn_cy02h <= req_in_cy01h & ~gnn_cy03h;
  end
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) gnn_cy03h <= 1'b0;
    else              gnn_cy03h <= rqn_cy02h;
  end
  assign gnt_out_cy03h = gnn_cy03h;
endmodule

module reference_badhop (
  input  logic reference_core_clk,
  input  logic req_in_cy01h,
  output logic out_cy04h
);
  logic q1_cy02h, q2_cy03h, q3_cy04h, p1_cy02h, p2_cy03h, p3_cy04h;
  always_ff @(posedge reference_core_clk) begin
    q1_cy02h <= req_in_cy01h & ~q3_cy04h;
    q2_cy03h <= q1_cy02h;
    q3_cy04h <= q2_cy03h;
    p1_cy02h <= req_in_cy01h & ~p3_cy04h;
    p2_cy03h <= p1_cy02h;
    p3_cy04h <= p2_cy03h;
  end
  assign out_cy04h = q3_cy04h & p3_cy04h;
endmodule
