//===-- ooe_ren1_tb.sv - bench top: Rename 1 with ooe_rat ------------------===//
//
// Not a block: test/ooe/ren1_tb.cpp's top. Rename 1 as ooe_rename will hold
// it (OI-67): one ooe_headrd per slot reads every candidate's maps, ooe_ren1
// picks the lanes, each with its name index (ooe_go's writer counts) and
// each read's in-group writer as a lane,
// the Rename 1 register captures the lanes and the free lists'
// heads, and ooe_ren1n binds the names from it. That register is the
// pending group: ooe_rat captures it at the next edge and writes it at the
// one after (OI-83 (b)), and the heads read through both. ooe_rat's other ports (the go's leads, retirement, whole-map
// events) and the free lists' heads come from the bench.
//===----------------------------------------------------------------------===//
module ooe_ren1_tb #(
  parameter int S  = 4,
  parameter int R  = 4,                  // rename width: lanes, heads a slot, ooe_rat's ports
  parameter int RP = 2,                  // retire ports per slot
  parameter int C  = 4,
  parameter int GW = 10,
  parameter int GR = 8,
  parameter int PW = 6,
  parameter logic [GW-1:0] GZERO = '1,
  parameter logic [PW-1:0] PZERO = '1,
  localparam int NG = 16,
  localparam int NP = 4,
  localparam int NC = S * R,
  localparam int LS = (S > 1) ? $clog2(S) : 1,
  localparam int LC = (C > 1) ? $clog2(C) : 1,
  localparam int MW = NG * GW + NP * PW
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  // Every candidate (bit h * S + s: slot s's head h), as decq shows it.
  input  logic [NC*3*4-1:0] c_src_cq01h,
  input  logic [NC*4-1:0]   c_dst_cq01h,
  input  logic [NC-1:0]     c_gwe_cq01h,
  input  logic [NC*2-1:0]   c_pguard_cq01h,
  input  logic [NC*2-1:0]   c_pdst_cq01h,
  input  logic [NC-1:0]     c_pwe_cq01h,
  input  logic [NC*2*2-1:0] c_pq_cq01h,
  input  logic [NC-1:0]     c_br_cq01h,
  input  logic [NC*LC-1:0]  c_ckpt_cq01h,
  // The go's lanes and writer counts, and the free lists' heads.
  input  logic [R-1:0]      lane_v_cq02h,
  input  logic [R*NC-1:0]   lane_c_cq02h,
  input  logic [NC*2*R-1:0] wb_cq02h,
  input  logic [R*GR-1:0]   galloc_cq02h,
  input  logic [R*PW-1:0]   palloc_cq02h,
  // ooe_rat's leads and other ports.
  input  logic [S*R-1:0]    tk_cq00h,
  input  logic [S*R-1:0]    hbr_cq00h,
  input  logic [S*R*LC-1:0] hck_cq00h,
  input  logic [S-1:0]      rstl_cq00h,
  input  logic [S*RP-1:0]   rgl_cq00h,
  input  logic [S*RP-1:0]   rpl_cq00h,
  input  logic [S*RP-1:0]   ret_gwe_cq01h,
  input  logic [S*RP*4-1:0] ret_dst_cq01h,
  input  logic [S*RP*GW-1:0] ret_gname_cq01h,
  input  logic [S*RP-1:0]   ret_pwe_cq01h,
  input  logic [S*RP*2-1:0] ret_pdst_cq01h,
  input  logic [S*RP*PW-1:0] ret_pname_cq01h,
  input  logic [S-1:0]      restore_cq00h,
  input  logic [S*LC-1:0]   restore_ckpt_cq00h,
  input  logic [S-1:0]      squash_cq00h,
  input  logic [S-1:0]      release_cq00h,
  // The Rename 1 register.
  output logic [R-1:0]      q_v,
  output logic [R*LS-1:0]   q_slot,
  output logic [R*4-1:0]    q_dst,
  output logic [R-1:0]      q_gwe,
  output logic [R*GW-1:0]   q_gname,
  output logic [R*2-1:0]    q_pdst,
  output logic [R-1:0]      q_pwe,
  output logic [R*PW-1:0]   q_pname,
  output logic [R-1:0]      q_br,
  output logic [R*LC-1:0]   q_ckpt,
  output logic [R*4*GW-1:0] q_g,
  output logic [R*4*PW-1:0] q_p
);
  logic [S*MW-1:0]   rat_cq02h;
  logic [S*MW-1:0]   crat_cq02h;
  logic [S*C*MW-1:0] ckpt_cq02h;
  logic [R*4-1:0]    pw_dst;
  // ooe_rat's capture of the group before last (OI-83 (b)), into the reads.
  logic [R-1:0]      po_v, po_gwe, po_pwe;
  logic [R*LS-1:0]   po_slot;
  logic [R*4-1:0]    po_dst;
  logic [R*GW-1:0]   po_gname;
  logic [R*2-1:0]    po_pdst;
  logic [R*PW-1:0]   po_pname;
  ooe_rat #(.S(S), .A(R), .R(RP), .C(C), .GW(GW), .PW(PW), .GZERO(GZERO), .PZERO(PZERO)) ooe_rat (
    .ooe_core_clk, .ooe_rst_r00h, .tk_cq00h, .hbr_cq00h, .hck_cq00h, .rstl_cq00h,
    .pw_v_cq01h(q_v), .pw_slot_cq01h(q_slot), .pw_rst_cq01h('0), .pw_dst_cq01h(q_dst), .pw_gwe_cq01h(q_gwe),
    .pw_gname_cq01h(q_gname), .pw_pdst_cq01h(q_pdst), .pw_pwe_cq01h(q_pwe), .pw_pname_cq01h(q_pname),
    .pw_br_cq01h(q_br), .pw_ckpt_cq01h(q_ckpt), .rgl_cq00h, .rpl_cq00h, .ret_gwe_cq01h, .ret_dst_cq01h,
    .ret_gname_cq01h, .ret_pwe_cq01h, .ret_pdst_cq01h, .ret_pname_cq01h, .restore_cq00h, .restore_ckpt_cq00h,
    .squash_cq00h, .release_cq00h, .po_v_cq02h(po_v), .po_slot_cq02h(po_slot), .po_dst_cq02h(po_dst),
    .po_gwe_cq02h(po_gwe), .po_gname_cq02h(po_gname), .po_pdst_cq02h(po_pdst), .po_pwe_cq02h(po_pwe),
    .po_pname_cq02h(po_pname), .rat_cq02h, .crat_cq02h, .ckpt_cq02h);

  logic [S*R*4*GW-1:0] c_gv;
  logic [S*R*4*R-1:0]  c_gw;
  logic [S*R*4*PW-1:0] c_pv;
  logic [S*R*4*R-1:0]  c_pw;
  for (genvar s = 0; s < S; s++) begin : g_slot
    logic [R*3*4-1:0] src;
    logic [R*4-1:0]   dst;
    logic [R-1:0]     gwe, pwe;
    logic [R*2-1:0]   pguard, pdst;
    logic [R*2*2-1:0] pq;
    for (genvar h = 0; h < R; h++) begin : g_head
      assign src[h * 12 +: 12]  = c_src_cq01h[(h * S + s) * 12 +: 12];
      assign dst[h * 4 +: 4]    = c_dst_cq01h[(h * S + s) * 4 +: 4];
      assign gwe[h]             = c_gwe_cq01h[h * S + s];
      assign pguard[h * 2 +: 2] = c_pguard_cq01h[(h * S + s) * 2 +: 2];
      assign pdst[h * 2 +: 2]   = c_pdst_cq01h[(h * S + s) * 2 +: 2];
      assign pwe[h]             = c_pwe_cq01h[h * S + s];
      assign pq[h * 4 +: 4]     = c_pq_cq01h[(h * S + s) * 4 +: 4];
    end
    ooe_headrd #(.S(S), .SL(s), .R(R), .A(R), .GW(GW), .PW(PW)) ooe_headrd (
      .rat_cq02h(rat_cq02h[s * MW +: MW]), .h_src_cq01h(src), .h_dst_cq01h(dst), .h_gwe_cq01h(gwe),
      .h_pguard_cq01h(pguard), .h_pdst_cq01h(pdst), .h_pwe_cq01h(pwe), .h_pq_cq01h(pq),
      .po_v_cq02h(po_v), .po_slot_cq02h(po_slot), .po_dst_cq02h(po_dst), .po_gwe_cq02h(po_gwe),
      .po_gname_cq02h(po_gname), .po_pdst_cq02h(po_pdst), .po_pwe_cq02h(po_pwe), .po_pname_cq02h(po_pname),
      .pw_v_cq01h(q_v), .pw_slot_cq01h(q_slot), .pw_dst_cq01h(q_dst), .pw_gwe_cq01h(q_gwe),
      .pw_gname_cq01h(q_gname), .pw_pdst_cq01h(q_pdst), .pw_pwe_cq01h(q_pwe), .pw_pname_cq01h(q_pname),
      .h_gv_cq01h(c_gv[s * R * 4 * GW +: R * 4 * GW]), .h_gw_cq01h(c_gw[s * R * 4 * R +: R * 4 * R]),
      .h_pv_cq01h(c_pv[s * R * 4 * PW +: R * 4 * PW]), .h_pw_cq01h(c_pw[s * R * 4 * R +: R * 4 * R]));
  end

  logic [R-1:0]      l_v, l_gwe, l_pwe, l_br, l_x;
  logic [R*LS-1:0]   l_slot;
  logic [R*4-1:0]    l_dst;
  logic [R*2-1:0]    l_pdst;
  logic [R*2*R-1:0]  l_idx;
  logic [R*LC-1:0]   l_ckpt;
  logic [R*4*GW-1:0] l_g;
  logic [R*4*R-1:0]  l_gl, l_pl;
  logic [R*4*PW-1:0] l_p;
  ooe_ren1 #(.S(S), .R(R), .GW(GW), .PW(PW), .LC(LC), .XW(1)) ooe_ren1 (
    .c_dst_cq01h, .c_gwe_cq01h, .c_pdst_cq01h, .c_pwe_cq01h, .c_br_cq01h, .c_ckpt_cq01h, .c_x_cq01h('0),
    .c_gv_cq01h(c_gv), .c_gw_cq01h(c_gw), .c_pv_cq01h(c_pv), .c_pw_cq01h(c_pw), .lane_v_cq02h, .lane_c_cq02h,
    .wb_cq02h, .l_v, .l_slot, .l_dst, .l_gwe, .l_pdst, .l_pwe, .l_idx, .l_br, .l_ckpt, .l_g, .l_gl, .l_p, .l_pl,
    .l_x);

  // The Rename 1 register (in ooe_rename, gated by the go's sel), with the
  // free lists' heads beside it.
  logic [R*2*R-1:0]  q_idx;
  logic [R*GR-1:0]   q_galloc;
  logic [R*PW-1:0]   q_palloc;
  logic [R*4*GW-1:0] q_gv;
  logic [R*4*R-1:0]  q_gl, q_pl;
  logic [R*4*PW-1:0] q_pv;
  always_ff @(posedge ooe_core_clk)
    if (ooe_rst_r00h) q_v <= '0;
    else begin
      q_v      <= l_v;
      q_slot   <= l_slot;
      q_dst    <= l_dst;
      q_gwe    <= l_gwe;
      q_pdst   <= l_pdst;
      q_pwe    <= l_pwe;
      q_idx    <= l_idx;
      q_br     <= l_br;
      q_ckpt   <= l_ckpt;
      q_gv     <= l_g;
      q_gl     <= l_gl;
      q_pv     <= l_p;
      q_pl     <= l_pl;
      q_galloc <= galloc_cq02h;
      q_palloc <= palloc_cq02h;
    end
  // Rename 2's first gates: the names bound.
  ooe_ren1n #(.R(R), .GW(GW), .GR(GR), .PW(PW)) ooe_ren1n (
    .q_idx_cq01h(q_idx), .q_galloc_cq01h(q_galloc), .q_palloc_cq01h(q_palloc), .q_g_cq01h(q_gv),
    .q_gl_cq01h(q_gl), .q_p_cq01h(q_pv), .q_pl_cq01h(q_pl),
    // Whole rows here (NS 0): rename_tb's sectioned build holds the narrow names.
    .q_slot_cq01h('0), .q_gwe_cq01h('0), .q_na_cq01h('0), .q_nw_cq01h('0), .cand_v_cq01h('0),
    .cand_row_cq01h('0), .cand_same_cq01h('0),
    .n_gname(q_gname), .n_pname(q_pname), .n_g(q_g), .n_p(q_p),
    .n_sa_v(n_sa_v), .n_sa_row(n_sa_row), .n_sa_sec(n_sa_sec), .n_rt_v(n_rt_v), .n_rt_row(n_rt_row));
  logic [R-1:0]    n_sa_v, n_rt_v;
  logic [R*GR-1:0] n_sa_row, n_rt_row;
  logic [R-1:0]    n_sa_sec;
endmodule
