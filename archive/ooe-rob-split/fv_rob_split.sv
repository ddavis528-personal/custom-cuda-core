//===-- fv_rob_split.sv - the ROB split's miter, for formal proof ---------===//
//
// OA-24 (a), OA rev 312: the pre-split ROB (archive/ooe-rob-split/ooe_rob_ref.sv)
// against the four per-warp ooe_rob_w and the OR of their frees and leads,
// driven by the same inputs from a common all-zero start, reset held four
// cycles, every output compared every cycle after (miter_*; a payload only
// where its valid is set, see below). Archived, never in the gate or any
// build: run.sh beside it, the result in README.md. The reference's own
// assertions are the inputs' constraints (assumed); the split's are removed.
//
// Control FV_MUT_WID, which must fail: instance 1 is built as slot 2.
//===----------------------------------------------------------------------===//

module fv_rob_split #(
  parameter int S = 4,
  parameter int D = 32,
  parameter int RP = 2,
  parameter int A = 4,
  parameter int ND = 7,
  parameter int NM = 4,
  parameter int GW = 10,
  parameter int GR = 8,
  parameter int NG = 192,
  parameter int NS = 4,
  parameter int PW = 6,
  parameter int NP = 48,
  parameter int LB = 6,
  parameter int LT = 3,
  parameter int NK = 4,
  parameter int PCW = 48,
  parameter int BS = ND - 2,
  localparam int NSB = (NS > 0) ? NS : 1,
  localparam int LS = (S > 1) ? $clog2(S) : 1,
  localparam int LD = $clog2(D),
  localparam int TW = LS + LD,
  localparam int LA = $clog2(A + 1),
  localparam int LK = (NK > 1) ? $clog2(NK) : 1,
  localparam int NR = 4
) (
  input logic clk,
  input logic  ooe_rst_r00h,
  input logic [S-1:0] al_l_cq01h,
  input logic [S*LA-1:0] al_n_cq02h,
  input logic [S*A-1:0] al_nop_cq02h,
  input logic  fl_l_cq01h,
  input logic  fl_brl_cq01h,
  input logic [A-1:0] fl_v_cq02h,
  input logic [A*LS-1:0] fl_slot_cq02h,
  input logic [A-1:0] fl_nop_cq02h,
  input logic [A-1:0] fl_mem_cq02h,
  input logic [A*2-1:0] fl_rs_cq02h,
  input logic [A-1:0] fl_gwe_cq02h,
  input logic [A*4-1:0] fl_dst_cq02h,
  input logic [A*GW-1:0] fl_gname_cq02h,
  input logic [A*GW-1:0] fl_gold_cq02h,
  input logic [A*NSB-1:0] fl_gsec_cq02h,
  input logic [A-1:0] fl_pwe_cq02h,
  input logic [A*2-1:0] fl_pdst_cq02h,
  input logic [A*PW-1:0] fl_pname_cq02h,
  input logic [A*PW-1:0] fl_pold_cq02h,
  input logic [A-1:0] fl_pfree_cq02h,
  input logic [A-1:0] fl_br_cq02h,
  input logic [A*LK-1:0] fl_ckpt_cq02h,
  input logic [A-1:0] fl_ptaken_cq02h,
  input logic [A-1:0] fl_ret_cq02h,
  input logic [A*32-1:0] fl_gmask_cq02h,
  input logic [A*PCW-1:0] fl_pcn_cq02h,
  input logic [A*PCW-1:0] fl_tgt_cq02h,
  input logic [A*16-1:0] fl_pchi_cq02h,
  input logic [A*NSB-1:0] fl_gnsec_cq02h,
  input logic [A-1:0] fl_palloc_cq02h,
  input logic [A-1:0] fl_store_cq02h,
  input logic [S-1:0] ev_l_cq01h,
  input logic [S*D*NR-1:0] ev_owe_cq02h,
  input logic [S*D-1:0] ev_cpi_cq02h,
  input logic [S*D-1:0] ev_cpl_cq02h,
  input logic [S*D*2-1:0] ev_rsf_cq02h,
  input logic [S*D-1:0] ev_miu_cq02h,
  input logic [ND-1:0] dn_l_cq01h,
  input logic [ND*TW-1:0] dn_tag_cq02h,
  input logic [ND*2-1:0] dn_row_cq02h,
  input logic  dn_taken_cq02h,
  input logic [31:0] dn_mask_cq02h,
  input logic [31:0] dn_aux_cq02h,
  input logic [NM-1:0] cm_l_cq01h,
  input logic [NM*TW-1:0] cm_tag_cq02h,
  input logic [S-1:0] rel_l_cq01h
);
  // Reset held for the first four cycles, free after: the ROB flops it
  // before use (RST-1), so its state is reset only from the second. Every
  // flop starts at zero on both sides (write_aiger -zinit, as in simulation).
  logic [2:0] ic = 3'd0;
  logic init;
  always_ff @(posedge clk) if (ic != 3'd4) ic <= ic + 3'd1;
  assign init = ic != 3'd4;
  logic rst;
  assign rst = init | ooe_rst_r00h;
  logic [S*RP-1:0] r_rgl_cq02h, s_rgl_cq02h;
  logic [S*RP-1:0] r_rpl_cq02h, s_rpl_cq02h;
  logic  r_gfree_l_cq02h, s_gfree_l_cq02h;
  logic  r_pfree_l_cq02h, s_pfree_l_cq02h;
  logic [S*RP-1:0] r_ret_gwe_cq03h, s_ret_gwe_cq03h;
  logic [S*RP*4-1:0] r_ret_dst_cq03h, s_ret_dst_cq03h;
  logic [S*RP*GW-1:0] r_ret_gname_cq03h, s_ret_gname_cq03h;
  logic [S*RP-1:0] r_ret_pwe_cq03h, s_ret_pwe_cq03h;
  logic [S*RP*2-1:0] r_ret_pdst_cq03h, s_ret_pdst_cq03h;
  logic [S*RP*PW-1:0] r_ret_pname_cq03h, s_ret_pname_cq03h;
  logic [NG*NSB-1:0] r_gfree_cq03h, s_gfree_cq03h;
  logic [NP-1:0] r_pfree_cq03h, s_pfree_cq03h;
  logic [S*LB-1:0] r_run_cq02h, s_run_cq02h;
  logic [S-1:0] r_reach_cq02h, s_reach_cq02h;
  logic [S*LT-1:0] r_ret_cq02h, s_ret_cq02h;
  logic [S-1:0] r_rd_l_cq03h, s_rd_l_cq03h;
  logic [S*NK-1:0] r_ckf_cq03h, s_ckf_cq03h;
  logic [S*LK-1:0] r_rd_ckpt_cq04h, s_rd_ckpt_cq04h;
  logic [S*32-1:0] r_rd_tmask_cq04h, s_rd_tmask_cq04h;
  logic [S*PCW-1:0] r_rd_tgt_cq04h, s_rd_tgt_cq04h;
  logic [S-1:0] r_rd_stay_cq04h, s_rd_stay_cq04h;
  logic [S-1:0] r_dc_v_cq03h, s_dc_v_cq03h;
  logic [S*LD-1:0] r_dc_br_cq03h, s_dc_br_cq03h;
  logic [S*LD-1:0] r_dc_disp_cq03h, s_dc_disp_cq03h;
  ooe_rob_ref #(.S(S), .D(D), .RP(RP), .A(A), .ND(ND), .NM(NM), .GW(GW), .GR(GR), .NG(NG), .NS(NS), .PW(PW), .NP(NP), .LB(LB), .LT(LT), .NK(NK), .PCW(PCW), .BS(BS)) u_ref (
    .ooe_core_clk(clk), .ooe_rst_r00h(rst),
    .al_l_cq01h,
    .al_n_cq02h,
    .al_nop_cq02h,
    .fl_l_cq01h,
    .fl_brl_cq01h,
    .fl_v_cq02h,
    .fl_slot_cq02h,
    .fl_nop_cq02h,
    .fl_mem_cq02h,
    .fl_rs_cq02h,
    .fl_gwe_cq02h,
    .fl_dst_cq02h,
    .fl_gname_cq02h,
    .fl_gold_cq02h,
    .fl_gsec_cq02h,
    .fl_pwe_cq02h,
    .fl_pdst_cq02h,
    .fl_pname_cq02h,
    .fl_pold_cq02h,
    .fl_pfree_cq02h,
    .fl_br_cq02h,
    .fl_ckpt_cq02h,
    .fl_ptaken_cq02h,
    .fl_ret_cq02h,
    .fl_gmask_cq02h,
    .fl_pcn_cq02h,
    .fl_tgt_cq02h,
    .fl_pchi_cq02h,
    .fl_gnsec_cq02h,
    .fl_palloc_cq02h,
    .fl_store_cq02h,
    .ev_l_cq01h,
    .ev_owe_cq02h,
    .ev_cpi_cq02h,
    .ev_cpl_cq02h,
    .ev_rsf_cq02h,
    .ev_miu_cq02h,
    .dn_l_cq01h,
    .dn_tag_cq02h,
    .dn_row_cq02h,
    .dn_taken_cq02h,
    .dn_mask_cq02h,
    .dn_aux_cq02h,
    .cm_l_cq01h,
    .cm_tag_cq02h,
    .rel_l_cq01h,
    .rgl_cq02h(r_rgl_cq02h),
    .rpl_cq02h(r_rpl_cq02h),
    .gfree_l_cq02h(r_gfree_l_cq02h),
    .pfree_l_cq02h(r_pfree_l_cq02h),
    .ret_gwe_cq03h(r_ret_gwe_cq03h),
    .ret_dst_cq03h(r_ret_dst_cq03h),
    .ret_gname_cq03h(r_ret_gname_cq03h),
    .ret_pwe_cq03h(r_ret_pwe_cq03h),
    .ret_pdst_cq03h(r_ret_pdst_cq03h),
    .ret_pname_cq03h(r_ret_pname_cq03h),
    .gfree_cq03h(r_gfree_cq03h),
    .pfree_cq03h(r_pfree_cq03h),
    .run_cq02h(r_run_cq02h),
    .reach_cq02h(r_reach_cq02h),
    .ret_cq02h(r_ret_cq02h),
    .rd_l_cq03h(r_rd_l_cq03h),
    .ckf_cq03h(r_ckf_cq03h),
    .rd_ckpt_cq04h(r_rd_ckpt_cq04h),
    .rd_tmask_cq04h(r_rd_tmask_cq04h),
    .rd_tgt_cq04h(r_rd_tgt_cq04h),
    .rd_stay_cq04h(r_rd_stay_cq04h),
    .dc_v_cq03h(r_dc_v_cq03h),
    .dc_br_cq03h(r_dc_br_cq03h),
    .dc_disp_cq03h(r_dc_disp_cq03h)
  );
  // The split, as test/ooe/ooe_rob_tb.sv assembles it.
  logic [S-1:0]        gfl_w, pfl_w;
  logic [S*NG*NSB-1:0] gf_w;
  logic [S*NP-1:0]     pf_w;
  for (genvar w = 0; w < S; w++) begin : g_w
`ifdef FV_MUT_WID
    localparam int WI = (w == 1) ? 2 : w;
`else
    localparam int WI = w;
`endif
    ooe_rob_w #(.SA(S), .WID(WI), .D(D), .RP(RP), .A(A), .ND(ND), .NM(NM), .GW(GW), .GR(GR), .NG(NG), .NS(NS), .PW(PW), .NP(NP), .LB(LB), .LT(LT), .NK(NK), .PCW(PCW), .BS(BS)) u_w (
      .ooe_core_clk(clk), .ooe_rst_r00h(rst),
      .al_l_cq01h(al_l_cq01h[w * ($bits(al_l_cq01h) / S) +: $bits(al_l_cq01h) / S]),
      .al_n_cq02h(al_n_cq02h[w * ($bits(al_n_cq02h) / S) +: $bits(al_n_cq02h) / S]),
      .al_nop_cq02h(al_nop_cq02h[w * ($bits(al_nop_cq02h) / S) +: $bits(al_nop_cq02h) / S]),
      .fl_l_cq01h,
      .fl_brl_cq01h,
      .fl_v_cq02h,
      .fl_slot_cq02h,
      .fl_nop_cq02h,
      .fl_mem_cq02h,
      .fl_rs_cq02h,
      .fl_gwe_cq02h,
      .fl_dst_cq02h,
      .fl_gname_cq02h,
      .fl_gold_cq02h,
      .fl_gsec_cq02h,
      .fl_pwe_cq02h,
      .fl_pdst_cq02h,
      .fl_pname_cq02h,
      .fl_pold_cq02h,
      .fl_pfree_cq02h,
      .fl_br_cq02h,
      .fl_ckpt_cq02h,
      .fl_ptaken_cq02h,
      .fl_ret_cq02h,
      .fl_gmask_cq02h,
      .fl_pcn_cq02h,
      .fl_tgt_cq02h,
      .fl_pchi_cq02h,
      .fl_gnsec_cq02h,
      .fl_palloc_cq02h,
      .fl_store_cq02h,
      .ev_l_cq01h(ev_l_cq01h[w * ($bits(ev_l_cq01h) / S) +: $bits(ev_l_cq01h) / S]),
      .ev_owe_cq02h(ev_owe_cq02h[w * ($bits(ev_owe_cq02h) / S) +: $bits(ev_owe_cq02h) / S]),
      .ev_cpi_cq02h(ev_cpi_cq02h[w * ($bits(ev_cpi_cq02h) / S) +: $bits(ev_cpi_cq02h) / S]),
      .ev_cpl_cq02h(ev_cpl_cq02h[w * ($bits(ev_cpl_cq02h) / S) +: $bits(ev_cpl_cq02h) / S]),
      .ev_rsf_cq02h(ev_rsf_cq02h[w * ($bits(ev_rsf_cq02h) / S) +: $bits(ev_rsf_cq02h) / S]),
      .ev_miu_cq02h(ev_miu_cq02h[w * ($bits(ev_miu_cq02h) / S) +: $bits(ev_miu_cq02h) / S]),
      .dn_l_cq01h,
      .dn_tag_cq02h,
      .dn_row_cq02h,
      .dn_taken_cq02h,
      .dn_mask_cq02h,
      .dn_aux_cq02h,
      .cm_l_cq01h,
      .cm_tag_cq02h,
      .rel_l_cq01h(rel_l_cq01h[w * ($bits(rel_l_cq01h) / S) +: $bits(rel_l_cq01h) / S]),
      .rgl_cq02h(s_rgl_cq02h[w * ($bits(s_rgl_cq02h) / S) +: $bits(s_rgl_cq02h) / S]),
      .rpl_cq02h(s_rpl_cq02h[w * ($bits(s_rpl_cq02h) / S) +: $bits(s_rpl_cq02h) / S]),
      .gfree_l_cq02h(gfl_w[w]),
      .pfree_l_cq02h(pfl_w[w]),
      .ret_gwe_cq03h(s_ret_gwe_cq03h[w * ($bits(s_ret_gwe_cq03h) / S) +: $bits(s_ret_gwe_cq03h) / S]),
      .ret_dst_cq03h(s_ret_dst_cq03h[w * ($bits(s_ret_dst_cq03h) / S) +: $bits(s_ret_dst_cq03h) / S]),
      .ret_gname_cq03h(s_ret_gname_cq03h[w * ($bits(s_ret_gname_cq03h) / S) +: $bits(s_ret_gname_cq03h) / S]),
      .ret_pwe_cq03h(s_ret_pwe_cq03h[w * ($bits(s_ret_pwe_cq03h) / S) +: $bits(s_ret_pwe_cq03h) / S]),
      .ret_pdst_cq03h(s_ret_pdst_cq03h[w * ($bits(s_ret_pdst_cq03h) / S) +: $bits(s_ret_pdst_cq03h) / S]),
      .ret_pname_cq03h(s_ret_pname_cq03h[w * ($bits(s_ret_pname_cq03h) / S) +: $bits(s_ret_pname_cq03h) / S]),
      .gfree_cq03h(gf_w[w * NG * NSB +: NG * NSB]),
      .pfree_cq03h(pf_w[w * NP +: NP]),
      .run_cq02h(s_run_cq02h[w * ($bits(s_run_cq02h) / S) +: $bits(s_run_cq02h) / S]),
      .reach_cq02h(s_reach_cq02h[w * ($bits(s_reach_cq02h) / S) +: $bits(s_reach_cq02h) / S]),
      .ret_cq02h(s_ret_cq02h[w * ($bits(s_ret_cq02h) / S) +: $bits(s_ret_cq02h) / S]),
      .rd_l_cq03h(s_rd_l_cq03h[w * ($bits(s_rd_l_cq03h) / S) +: $bits(s_rd_l_cq03h) / S]),
      .ckf_cq03h(s_ckf_cq03h[w * ($bits(s_ckf_cq03h) / S) +: $bits(s_ckf_cq03h) / S]),
      .rd_ckpt_cq04h(s_rd_ckpt_cq04h[w * ($bits(s_rd_ckpt_cq04h) / S) +: $bits(s_rd_ckpt_cq04h) / S]),
      .rd_tmask_cq04h(s_rd_tmask_cq04h[w * ($bits(s_rd_tmask_cq04h) / S) +: $bits(s_rd_tmask_cq04h) / S]),
      .rd_tgt_cq04h(s_rd_tgt_cq04h[w * ($bits(s_rd_tgt_cq04h) / S) +: $bits(s_rd_tgt_cq04h) / S]),
      .rd_stay_cq04h(s_rd_stay_cq04h[w * ($bits(s_rd_stay_cq04h) / S) +: $bits(s_rd_stay_cq04h) / S]),
      .dc_v_cq03h(s_dc_v_cq03h[w * ($bits(s_dc_v_cq03h) / S) +: $bits(s_dc_v_cq03h) / S]),
      .dc_br_cq03h(s_dc_br_cq03h[w * ($bits(s_dc_br_cq03h) / S) +: $bits(s_dc_br_cq03h) / S]),
      .dc_disp_cq03h(s_dc_disp_cq03h[w * ($bits(s_dc_disp_cq03h) / S) +: $bits(s_dc_disp_cq03h) / S])
    );
  end
  always_comb begin
    s_gfree_l_cq02h = |gfl_w;
    s_pfree_l_cq02h = |pfl_w;
    s_gfree_cq03h   = '0;
    s_pfree_cq03h   = '0;
    for (int w = 0; w < S; w++) begin
      s_gfree_cq03h = s_gfree_cq03h | gf_w[w * NG * NSB +: NG * NSB];
      s_pfree_cq03h = s_pfree_cq03h | pf_w[w * NP +: NP];
    end
  end
  // Every output, every cycle out of the reset cycle.
  // A payload is compared only where its valid is set: each instance loads
  // its payload registers on its own enable, where the unsplit ROB loaded
  // every slot's on one, so a lane with no valid may differ (and its
  // consumer ignores it: ooe_rat takes ret_dst and ret_gname only under
  // ret_gwe, ret_pdst and ret_pname under ret_pwe). The redirect's payload
  // at cq04h is valid a cycle after its lead rd_l; a deferred free's
  // dc_br and dc_disp with dc_v. Valids, leads and the ORed free masks are
  // compared whole.
  logic [S-1:0] rdl_q = '0;
  always_ff @(posedge clk) rdl_q <= r_rd_l_cq03h;
  logic [S*RP*4-1:0]  q_dst;
  logic [S*RP*GW-1:0] q_gname;
  logic [S*RP*2-1:0]  q_pdst;
  logic [S*RP*PW-1:0] q_pname;
  logic [S*LK-1:0]    q_ckpt;
  logic [S*32-1:0]    q_tmask;
  logic [S*PCW-1:0]   q_tgt;
  logic [S-1:0]       q_stay;
  logic [S*LD-1:0]    q_dcbr, q_dcdisp;
  always_comb begin
    for (int i = 0; i < S * RP; i++) begin
      q_dst[i * 4 +: 4]     = {4{r_ret_gwe_cq03h[i]}};
      q_gname[i * GW +: GW] = {GW{r_ret_gwe_cq03h[i]}};
      q_pdst[i * 2 +: 2]    = {2{r_ret_pwe_cq03h[i]}};
      q_pname[i * PW +: PW] = {PW{r_ret_pwe_cq03h[i]}};
    end
    for (int w = 0; w < S; w++) begin
      q_ckpt[w * LK +: LK]    = {LK{rdl_q[w]}};
      q_tmask[w * 32 +: 32]   = {32{rdl_q[w]}};
      q_tgt[w * PCW +: PCW]   = {PCW{rdl_q[w]}};
      q_stay[w]               = rdl_q[w];
      q_dcbr[w * LD +: LD]    = {LD{r_dc_v_cq03h[w]}};
      q_dcdisp[w * LD +: LD]  = {LD{r_dc_v_cq03h[w]}};
    end
  end
  always_comb if (!init) begin
    miter_rgl_cq02h: assert (r_rgl_cq02h == s_rgl_cq02h);
    miter_rpl_cq02h: assert (r_rpl_cq02h == s_rpl_cq02h);
    miter_gfree_l_cq02h: assert (r_gfree_l_cq02h == s_gfree_l_cq02h);
    miter_pfree_l_cq02h: assert (r_pfree_l_cq02h == s_pfree_l_cq02h);
    miter_ret_gwe_cq03h: assert (r_ret_gwe_cq03h == s_ret_gwe_cq03h);
    miter_ret_dst_cq03h: assert (((r_ret_dst_cq03h ^ s_ret_dst_cq03h) & q_dst) == '0);
    miter_ret_gname_cq03h: assert (((r_ret_gname_cq03h ^ s_ret_gname_cq03h) & q_gname) == '0);
    miter_ret_pwe_cq03h: assert (r_ret_pwe_cq03h == s_ret_pwe_cq03h);
    miter_ret_pdst_cq03h: assert (((r_ret_pdst_cq03h ^ s_ret_pdst_cq03h) & q_pdst) == '0);
    miter_ret_pname_cq03h: assert (((r_ret_pname_cq03h ^ s_ret_pname_cq03h) & q_pname) == '0);
    miter_gfree_cq03h: assert (r_gfree_cq03h == s_gfree_cq03h);
    miter_pfree_cq03h: assert (r_pfree_cq03h == s_pfree_cq03h);
    miter_run_cq02h: assert (r_run_cq02h == s_run_cq02h);
    miter_reach_cq02h: assert (r_reach_cq02h == s_reach_cq02h);
    miter_ret_cq02h: assert (r_ret_cq02h == s_ret_cq02h);
    miter_rd_l_cq03h: assert (r_rd_l_cq03h == s_rd_l_cq03h);
    miter_ckf_cq03h: assert (r_ckf_cq03h == s_ckf_cq03h);
    miter_rd_ckpt_cq04h: assert (((r_rd_ckpt_cq04h ^ s_rd_ckpt_cq04h) & q_ckpt) == '0);
    miter_rd_tmask_cq04h: assert (((r_rd_tmask_cq04h ^ s_rd_tmask_cq04h) & q_tmask) == '0);
    miter_rd_tgt_cq04h: assert (((r_rd_tgt_cq04h ^ s_rd_tgt_cq04h) & q_tgt) == '0);
    miter_rd_stay_cq04h: assert (((r_rd_stay_cq04h ^ s_rd_stay_cq04h) & q_stay) == '0);
    miter_dc_v_cq03h: assert (r_dc_v_cq03h == s_dc_v_cq03h);
    miter_dc_br_cq03h: assert (((r_dc_br_cq03h ^ s_dc_br_cq03h) & q_dcbr) == '0);
    miter_dc_disp_cq03h: assert (((r_dc_disp_cq03h ^ s_dc_disp_cq03h) & q_dcdisp) == '0);
  end
endmodule
