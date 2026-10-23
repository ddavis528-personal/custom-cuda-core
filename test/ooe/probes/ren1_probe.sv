// Depth probe (ooe_rename slice 5, OI-67): Rename 1 as ooe_rename will hold
// it, flop to flop. ooe_go's lanes and writer counts, one ooe_headrd per
// slot over decq's heads and the pending group, ooe_ren1, and the Rename 1
// register, which is the pending group. Measured with tools/check-ngd.py as
// a temporary unit (its flop-flop figure is Rename 1's path).
module ren1_probe #(
  parameter int S = 4, parameter int R = 4, parameter int PA = 7, parameter int GW = 10, parameter int PW = 6,
  localparam int H = 2 * R - 1, localparam int NC = S * R, localparam int LS = 2, localparam int LC = 2,
  localparam int MW = 16 * GW + 4 * PW, localparam int LX = $clog2(5 * R + 1)
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  input  logic [S*H-1:0]    hv_cq01h,
  input  logic [S*H*PA-1:0] ha_cq01h,
  input  logic [4*LX-1:0]   px_cq01h,
  input  logic [S*5-1:0]    unmet_g_cq01h,
  input  logic [S*5-1:0]    unmet_p_cq01h,
  input  logic [S*6-1:0]    run_cq01h,
  input  logic [S-1:0]      reach_cq01h,
  input  logic [S*3-1:0]    ret_cq01h,
  input  logic [S-1:0]      hold_l_cq00h,
  input  logic              rbusy_l_cq00h,
  input  logic [S-1:0]      sq_l_cq00h,
  input  logic [S-1:0]      dq_ev_cq01h,
  input  logic [S-1:0]      rob_en_cq01h,
  input  logic              pool_en_cq01h,
  input  logic [S*MW-1:0]   rat_cq02h,
  input  logic [NC*12-1:0]  c_src_cq01h,
  input  logic [NC*4-1:0]   c_dst_cq01h,
  input  logic [NC-1:0]     c_gwe_cq01h,
  input  logic [NC*2-1:0]   c_pguard_cq01h,
  input  logic [NC*2-1:0]   c_pdst_cq01h,
  input  logic [NC-1:0]     c_pwe_cq01h,
  input  logic [NC*4-1:0]   c_pq_cq01h,
  input  logic [NC-1:0]     c_br_cq01h,
  input  logic [NC*LC-1:0]  c_ckpt_cq01h,
  output logic [S*R-1:0]    take_cq02h,
  output logic [2*R-1:0]    wt_cq02h,
  output logic [R-1:0]      q_v,
  output logic [R*LS-1:0]   q_slot,
  output logic [R*4-1:0]    q_dst,
  output logic [R-1:0]      q_gwe, q_pwe, q_br,
  output logic [R*2-1:0]    q_pdst,
  output logic [R*2*R-1:0]  q_idx,
  output logic [R*LC-1:0]   q_ckpt,
  output logic [R*4*GW-1:0] q_g,
  output logic [R*4*R-1:0]  q_gl, q_pl,
  output logic [R*4*PW-1:0] q_p
);
  logic [S-1:0] sel;
  logic [R-1:0] lane_v;
  logic [R*NC-1:0] lane_c;
  logic [NC*2*R-1:0] wb;
  ooe_go #(.S(S), .R(R), .PA(PA)) go (.ooe_core_clk, .ooe_rst_r00h, .hv_cq01h, .ha_cq01h, .px_cq01h,
    .unmet_g_cq01h, .unmet_p_cq01h, .run_cq01h, .reach_cq01h, .ret_cq01h, .hold_l_cq00h, .rbusy_l_cq00h,
    .sq_l_cq00h, .dq_ev_cq01h, .rob_en_cq01h, .pool_en_cq01h, .take_cq02h, .sel_cq02h(sel), .lane_v_cq02h(lane_v),
    .lane_c_cq02h(lane_c), .wb_cq02h(wb), .wt_cq02h);
  // The pending group's names, as ooe_ren1n binds them (here: the lanes' index bits
  // stand in, as the bind is Rename 2's).
  logic [R*GW-1:0] pg;
  logic [R*PW-1:0] pp;
  always_comb for (int l = 0; l < R; l++) begin
    pg[l * GW +: GW] = GW'(q_idx[l * 2 * R +: R]);
    pp[l * PW +: PW] = PW'(q_idx[(l * 2 + 1) * R +: R]);
  end
  logic [S*R*4*GW-1:0] c_gv;
  logic [S*R*4*R-1:0]  c_gw, c_pw;
  logic [S*R*4*PW-1:0] c_pv;
  for (genvar s = 0; s < S; s++) begin : g_slot
    logic [R*12-1:0] src; logic [R*4-1:0] dst, pq; logic [R-1:0] gwe, pwe; logic [R*2-1:0] pguard, pdst;
    for (genvar h = 0; h < R; h++) begin : g_head
      assign src[h * 12 +: 12] = c_src_cq01h[(h * S + s) * 12 +: 12];
      assign dst[h * 4 +: 4] = c_dst_cq01h[(h * S + s) * 4 +: 4];
      assign gwe[h] = c_gwe_cq01h[h * S + s];
      assign pguard[h * 2 +: 2] = c_pguard_cq01h[(h * S + s) * 2 +: 2];
      assign pdst[h * 2 +: 2] = c_pdst_cq01h[(h * S + s) * 2 +: 2];
      assign pwe[h] = c_pwe_cq01h[h * S + s];
      assign pq[h * 4 +: 4] = c_pq_cq01h[(h * S + s) * 4 +: 4];
    end
    ooe_headrd #(.S(S), .SL(s), .R(R), .A(R), .GW(GW), .PW(PW)) rd (.rat_cq02h(rat_cq02h[s * MW +: MW]),
      .h_src_cq01h(src), .h_dst_cq01h(dst), .h_gwe_cq01h(gwe), .h_pguard_cq01h(pguard), .h_pdst_cq01h(pdst),
      .h_pwe_cq01h(pwe), .h_pq_cq01h(pq), .pw_v_cq01h(q_v), .pw_slot_cq01h(q_slot), .pw_dst_cq01h(q_dst),
      .pw_gwe_cq01h(q_gwe), .pw_gname_cq01h(pg), .pw_pdst_cq01h(q_pdst), .pw_pwe_cq01h(q_pwe), .pw_pname_cq01h(pp),
      .h_gv_cq01h(c_gv[s * R * 4 * GW +: R * 4 * GW]), .h_gw_cq01h(c_gw[s * R * 4 * R +: R * 4 * R]),
      .h_pv_cq01h(c_pv[s * R * 4 * PW +: R * 4 * PW]), .h_pw_cq01h(c_pw[s * R * 4 * R +: R * 4 * R]));
  end
  logic [R-1:0] l_v, l_gwe, l_pwe, l_br, l_x;
  logic [R*LS-1:0] l_slot; logic [R*4-1:0] l_dst; logic [R*2-1:0] l_pdst; logic [R*2*R-1:0] l_idx;
  logic [R*LC-1:0] l_ckpt; logic [R*4*GW-1:0] l_g; logic [R*4*R-1:0] l_gl, l_pl; logic [R*4*PW-1:0] l_p;
  ooe_ren1 #(.S(S), .R(R), .GW(GW), .PW(PW), .LC(LC), .XW(1)) r1 (.c_dst_cq01h, .c_gwe_cq01h, .c_pdst_cq01h,
    .c_pwe_cq01h, .c_br_cq01h, .c_ckpt_cq01h, .c_x_cq01h('0), .c_gv_cq01h(c_gv), .c_gw_cq01h(c_gw),
    .c_pv_cq01h(c_pv), .c_pw_cq01h(c_pw), .lane_v_cq02h(lane_v), .lane_c_cq02h(lane_c), .wb_cq02h(wb), .l_v,
    .l_slot, .l_dst, .l_gwe, .l_pdst, .l_pwe, .l_idx, .l_br, .l_ckpt, .l_g, .l_gl, .l_p, .l_pl, .l_x);
  logic en;
  assign en = |sel;
  always_ff @(posedge ooe_core_clk) begin
    if (ooe_rst_r00h) q_v <= '0; else q_v <= l_v;
    if (en) begin
      q_slot <= l_slot; q_dst <= l_dst; q_gwe <= l_gwe; q_pwe <= l_pwe; q_br <= l_br; q_pdst <= l_pdst;
      q_idx <= l_idx; q_ckpt <= l_ckpt; q_g <= l_g; q_gl <= l_gl; q_pl <= l_pl; q_p <= l_p;
    end
  end
endmodule
