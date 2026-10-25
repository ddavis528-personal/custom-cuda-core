//===-- ooe_rename_tb.sv - bench top: ooe_rename beside ooe_rat -------------===//
//
// Not a block: test/ooe/rename_tb.cpp's top. ooe_rename (the go, Rename 1
// and 2, the free lists) with ooe_rat wired as the core will have them: the take is
// ooe_rat's take lead, the Rename 1 register its pending write, its maps the
// heads' reads; the heads' branch fields go to ooe_rat as decq gives them.
// The rest (decq's heads, rename's registers the go reads, the ROB's
// retirements and whole-map events, the frees, ooe_rs's grant) comes from
// the bench.
//===----------------------------------------------------------------------===//
module ooe_rename_tb #(
  parameter int S  = 4,
  parameter int R  = 4,
  parameter int RP = 2,                  // retire ports per slot
  parameter int C  = 4,
  parameter int NG = 192,
  parameter int NP = 48,
  parameter int GW = 10,
  parameter int PW = 6,
  parameter logic [GW-1:0] GZERO = '1,
  parameter logic [PW-1:0] PZERO = '1,
  parameter int N  = 45,
  parameter int NR = 30,
  parameter int NU = 8,
  parameter int G  = 8,
  parameter logic [2*NU*G*G-1:0] CT = '1,
  parameter int AG = 16,
  parameter int AP = 4,
  parameter int FLG = 16,
  parameter int CLG = 64,
  parameter int FLP = 4,
  parameter int CLP = 20,
  localparam int PA = 7,
  localparam int H  = 2 * R - 1,
  localparam int NC = S * R,
  localparam int LS = (S > 1) ? $clog2(S) : 1,
  localparam int LC = (C > 1) ? $clog2(C) : 1,
  localparam int MW = 16 * GW + 4 * PW,
  localparam int XW = 20,
  localparam int P  = 2 * R,
  localparam int W  = $clog2(N)
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  input  logic [S*H-1:0]    hv_cq01h,
  input  logic [S*H*PA-1:0] ha_cq01h,
  input  logic [NC*3*4-1:0] c_src_cq01h,
  input  logic [NC*4-1:0]   c_dst_cq01h,
  input  logic [NC*2-1:0]   c_pguard_cq01h,
  input  logic [NC*2-1:0]   c_pdst_cq01h,
  input  logic [NC*2*2-1:0] c_pq_cq01h,
  input  logic [NC-1:0]     c_br_cq01h,
  input  logic [NC*LC-1:0]  c_ckpt_cq01h,
  input  logic [NC*XW-1:0]  c_x_cq01h,
  input  logic [NC-1:0]     c_wset_cq01h,
  input  logic [NC*2-1:0]   c_wnew_cq01h,
  input  logic [S-1:0]      cwl_cq00h,
  input  logic [S*32-1:0]   cwd_cq01h,
  input  logic [S*6-1:0]    run_cq01h,
  input  logic [S-1:0]      reach_cq01h,
  input  logic [S*3-1:0]    ret_cq01h,
  input  logic [S-1:0]      hold_l_cq00h,
  input  logic              rbusy_l_cq00h,
  input  logic [S-1:0]      sq_l_cq00h,
  input  logic [S-1:0]      dq_ev_cq01h,
  input  logic [S-1:0]      rob_en_cq01h,
  input  logic [S-1:0]      occ_cq01h,
  input  logic [S-1:0]      occ_l_cq00h,
  input  logic              rsf_l_cq00h,
  input  logic [3:0]        fpr_cq01h,
  input  logic [3:0]        fpm_cq01h,
  input  logic [$clog2(NR+1)-1:0] flr_cq01h,
  input  logic [$clog2(N-NR+1)-1:0] flm_cq01h,
  input  logic              ctl_notq,
  input  logic              ctl_notq2,
  input  logic              gfree_l_cq00h,
  input  logic [NG-1:0]     gfree_cq01h,
  input  logic              pfree_l_cq00h,
  input  logic [NP-1:0]     pfree_cq01h,
  // ooe_rat's other ports.
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
  // ooe_rs's registered grant.
  input  logic [P-1:0]      gnt_v_cq03h,
  input  logic [P*W-1:0]    gnt_idx_cq03h,
  output logic [S*R-1:0]    take_cq02h,
  output logic [S-1:0]      sel_cq02h,
  output logic [R-1:0]      q_v_cq03h,
  output logic [R*LS-1:0]   q_slot_cq03h,
  output logic [R*4-1:0]    q_dst_cq03h,
  output logic [R-1:0]      q_gwe_cq03h,
  output logic [R*GW-1:0]   q_gname_cq03h,
  output logic [R*2-1:0]    q_pdst_cq03h,
  output logic [R-1:0]      q_pwe_cq03h,
  output logic [R*PW-1:0]   q_pname_cq03h,
  output logic [R-1:0]      q_br_cq03h,
  output logic [R*LC-1:0]   q_ckpt_cq03h,
  output logic [R*8-1:0]    q_w_cq03h,
  output logic [R*4*GW-1:0] q_g_cq03h,
  output logic [R*4*PW-1:0] q_p_cq03h,
  output logic [P-1:0]      req_l_cq03h,
  output logic [P-1:0]      req_cq04h,
  output logic [P-1:0]      row_prod_cq04h,
  output logic [P*N-1:0]    row_dep_cq04h,
  output logic [2*P*N-1:0]  row_code_cq04h,
  output logic [P*P-1:0]    grp_dep_cq04h,
  output logic [2*P*P-1:0]  grp_code_cq04h,
  output logic [P*P-1:0]    prv_dep_cq04h,
  output logic [2*P*P-1:0]  prv_code_cq04h,
  output logic [4*8-1:0]    chk_cred_cq04h,
  output logic [S*5-1:0]    chk_unmet_g_cq04h,
  output logic [S*5-1:0]    chk_unmet_p_cq04h,
  output logic [S*5-1:0]    chk_room_g_cq04h,
  output logic [S*5-1:0]    chk_room_p_cq04h
);
  logic [S*MW-1:0]   rat_cq02h;
  logic [S*MW-1:0]   crat_cq02h;
  logic [S*C*MW-1:0] ckpt_cq02h;
  // decq's head branch fields, slot-major as ooe_rat takes them.
  logic [S*R-1:0]    hbr_cq00h;
  logic [S*R*LC-1:0] hck_cq00h;
  for (genvar s = 0; s < S; s++) begin : g_s
    for (genvar h = 0; h < R; h++) begin : g_h
      assign hbr_cq00h[s * R + h]           = c_br_cq01h[h * S + s];
      assign hck_cq00h[(s * R + h) * LC +: LC] = c_ckpt_cq01h[(h * S + s) * LC +: LC];
    end
  end
  ooe_rat #(.S(S), .A(R), .R(RP), .C(C), .GW(GW), .PW(PW), .GZERO(GZERO), .PZERO(PZERO)) u_rat (
    .ooe_core_clk, .ooe_rst_r00h, .tk_cq00h(take_cq02h), .hbr_cq00h, .hck_cq00h, .rstl_cq00h,
    .pw_v_cq01h(q_v_cq03h), .pw_slot_cq01h(q_slot_cq03h), .pw_rst_cq01h('0), .pw_dst_cq01h(q_dst_cq03h),
    .pw_gwe_cq01h(q_gwe_cq03h), .pw_gname_cq01h(q_gname_cq03h), .pw_pdst_cq01h(q_pdst_cq03h),
    .pw_pwe_cq01h(q_pwe_cq03h), .pw_pname_cq01h(q_pname_cq03h), .pw_br_cq01h(q_br_cq03h),
    .pw_ckpt_cq01h(q_ckpt_cq03h), .rgl_cq00h, .rpl_cq00h, .ret_gwe_cq01h, .ret_dst_cq01h, .ret_gname_cq01h,
    .ret_pwe_cq01h, .ret_pdst_cq01h, .ret_pname_cq01h, .restore_cq00h, .restore_ckpt_cq00h, .squash_cq00h,
    .release_cq00h, .rat_cq02h, .crat_cq02h, .ckpt_cq02h);
  ooe_rename #(.S(S), .R(R), .C(C), .NG(NG), .NP(NP), .GW(GW), .PW(PW), .N(N), .NR(NR), .NU(NU), .G(G), .CT(CT),
               .AG(AG), .AP(AP), .FLG(FLG), .CLG(CLG), .FLP(FLP), .CLP(CLP)) u_rename (
    .ooe_core_clk, .ooe_rst_r00h, .hv_cq01h, .ha_cq01h, .c_src_cq01h, .c_dst_cq01h, .c_pguard_cq01h,
    .c_pdst_cq01h, .c_pq_cq01h, .c_br_cq01h, .c_ckpt_cq01h, .c_x_cq01h,
    .c_wset_cq01h, .c_wnew_cq01h, .cwl_cq00h, .cwd_cq01h,
    .run_cq01h, .reach_cq01h, .ret_cq01h, .hold_l_cq00h, .rbusy_l_cq00h, .sq_l_cq00h, .dq_ev_cq01h,
    .rob_en_cq01h, .occ_cq01h, .occ_l_cq00h, .rsf_l_cq00h, .fpr_cq01h, .fpm_cq01h, .flr_cq01h,
    .flm_cq01h, .rat_cq02h, .gfree_l_cq00h, .gfree_cq01h, .pfree_l_cq00h, .pfree_cq01h,
    .gnt_v_cq03h, .gnt_idx_cq03h, .take_cq02h, .sel_cq02h, .q_v_cq03h, .q_slot_cq03h, .q_dst_cq03h, .q_gwe_cq03h, .q_gname_cq03h,
    .q_pdst_cq03h, .q_pwe_cq03h, .q_pname_cq03h, .q_br_cq03h, .q_ckpt_cq03h, .q_w_cq03h, .req_l_cq03h, .req_cq04h,
    .row_prod_cq04h, .row_dep_cq04h, .row_code_cq04h, .grp_dep_cq04h, .grp_code_cq04h, .prv_dep_cq04h,
    .prv_code_cq04h, .q_g_cq03h, .q_p_cq03h, .chk_cred_cq04h, .chk_unmet_g_cq04h,
    .chk_unmet_p_cq04h, .chk_room_g_cq04h, .chk_room_p_cq04h, .ctl_notq, .ctl_notq2);
endmodule
