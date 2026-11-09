//===-- ccv_rcu.sv - the RCU block: its modules, wired ----------------------===//
//
// Spec: docs/design-snapshots/rcu-arch-partition.md (live: CCV RCU
//       Architecture, Partition tab: modules, instances, port budgets) and
//       every tab its modules cite.
//
// The block's top: the generated port list (rtl/top/ports/ccv_rcu_ports.svh,
// the stub's, so the swap is a file-list change), its clock gate and its
// modules, and nothing else. No logic sits here between children
// (docs/rtl-coding-style.md, logic depth): every net is a wire, a
// concatenation, a bit reorder or a constant. The wrapper (rtl/top/wrap/
// ccv_rcu_w.sv) holds the boundary flops of ooe_rcu_issue and miu_rcu_data:
// their valid and lead slice arrive here a cycle before their payload.
//
// Instances (Partition tab): 32 rcu_bank_slice (K section 0..3, J lane
// group 0..7, 192 rows, FULL_ROW 1), rcu_pred, rcu_r (rcu_xbar inside),
// rcu_lanes and rcu_mem (32 copies), rcu_mig, rcu_kill, and ccv_common_clk,
// whose rcu_core_clk clocks them all. Every module flops rst_n itself (RST-1).
//
// Ties, each for a reason:
//   - every _stall output 0: RCU never stalls an inbound channel;
//   - done slots 0-4 and 6: branch_taken, branch_mask, aux and the lead
//     branch fields 0 (the Done tab: only slot 5, R's, carries a branch);
//   - rcu_kill's CSR request marker 0 until Q-59 defines one; its sixth
//     busy term 0 (five modules have one);
//   - the predicate file's unused merge fields (PL, PR, PG lanes all ones;
//     PC takes none of the new value; PG merges nothing);
//   - the gate's stalled 0 and override 0: the block's idle_cr01h (rcu_kill)
//     closes it.
// Trace ids (CCV_TRACE) are not carried: every _tid output is 0.
//
// Stage tags (CCV-L29): each net between modules carries its driver's tag,
// the stage of the flop or port that makes it; a net from a block port
// carries the stage its first reader takes it at. The modules number their
// own ports (a slot's issue lead is cr01h at every reader), so a reader's
// port tag can differ from its net's; CCV-L21 and CCV-L23 check this
// file's flops and assigns, which agree.
// Credits: ooe_rcu_issue's zero-cycle end (RA-43) returns each slot's credit
// from rcu_kill's flop of its valid; miu_rcu_data credits on receipt in the
// wrapper (RA-41, AR rev 331), so this block drives none for it and keeps
// its promise to take every landed message the cycle it lands. rcu_kill's
// 41 credit flops are the 9 issue valids and the 32 lane-result credits.
// The issue's guard is its lead only (RA-43): lead_guard_used and
// lead_guard_pred of every slot go to rcu_pred, which predecodes them.
//===----------------------------------------------------------------------===//
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_rcu (
  `include "ccv_rcu_ports.svh"
);
  localparam int N  = 32;                                   // lanes, lane copies
  localparam int NK = ccv_params_pkg::CCV_SECTIONS;          // S slots, P slots, sections, banks
  localparam int NS = ccv_params_pkg::CCV_ISSUE_RESOURCES;   // issue slots, 9
  localparam int NJ = N / 4;                                 // lane groups a bank: slices J
  localparam int WR = ccv_prov_pkg::CCV_P_W_PHYS_REG;
  localparam int WP = ccv_prov_pkg::CCV_P_W_PHYS_PRED;
  localparam int WT = ccv_prov_pkg::CCV_P_W_ROB_TAG;
  localparam int OW = ccv_prelim_pkg::CCV_L_W_OPCODE;    // = rcu_dec_pkg::OPC_W; not that package: a read in file order reaches this file first
  localparam int NM = ccv_params_pkg::CCV_MIU_PIPES;          // MIU slots, 4
  localparam int NWAKE = 1 + N + 1 + 1 + 1 + 1 + 1;          // issue, lane_res, MIU, map, rau, pca, kill

  // ---- The block's clock gate -------------------------------------------
  logic rcu_core_clk, cg_gated_cr02h, idle_cr01h;
  logic [NWAKE-1:0] wake_cr01h;
  localparam int CG_HW = ccv_prov_pkg::CCV_CG_HYST_W;
  ccv_common_clk #(.NWAKE(NWAKE)) u_cg (
    .clk         (core_clk),
    .rst_n       (rst_n),
    .quiesced    (idle_cr01h),
    .stalled     (1'b0),
    .hyst_quiesce(CG_HW'(ccv_prov_pkg::CCV_CG_HYST_QUIESCE)),
    .hyst_stall  (CG_HW'(ccv_prov_pkg::CCV_CG_HYST_STALL)),
    .wake        (wake_cr01h),
    .cg_override (1'b0),
    .te          (1'b0),
    .gclk        (rcu_core_clk),
    .gated       (cg_gated_cr02h)
  );
`ifdef CCV_CHECK
  assign clk_gated = cg_gated_cr02h;
`endif

  // ---- The issue channel's fields, flat (S slots 0-3, P 4-7, R 8) ---------
  logic [NS-1:0] i_iv_cr00h;
  logic [NS-1:0] i_cont_cr01h;
  logic [NS*4-1:0] i_foot_cr01h;
  logic [NS*OW-1:0] i_opc_cr02h;
  logic [NS*OW-1:0] i_lop_cr01h;    // lead_opcode, lead_done_row, lead_pred_we, lead_phys_dst: rcu_isd's (RA-43, RI-25)
  logic [NS*2-1:0] i_ldrw_cr01h;
  logic [NS-1:0] i_lpwe_cr01h;
  logic [NS*WR-1:0] i_ldst_cr01h;
  logic [NS*2-1:0] i_drw_cr02h;
  logic [NS*WT-1:0] i_tag_cr02h;
  logic [NS*N-1:0] i_im_cr02h;
  logic [NS*WP-1:0] i_pd_cr02h;
  logic [NS*WP-1:0] i_pod_cr02h;
  logic [NS-1:0] i_pwe_cr02h;
  logic [NS-1:0] i_mrg_cr01h;
  logic [NS*WR-1:0] i_dst_cr02h;
  logic [NS*WR-1:0] i_odst_cr01h;
  logic [NS*32-1:0] i_imm_cr02h;
  logic [NS*6-1:0] i_spos_cr02h;
  logic [NS*6-1:0] i_swid_cr02h;
  logic [NS*2-1:0] i_dpos_cr02h;
  logic [NS*2-1:0] i_dwid_cr02h;
  logic [NS*2-1:0] i_opos_cr02h;
  logic [NS*4-1:0] i_lsec_cr00h;
  logic [NS-1:0] i_lng_cr01h;        // lead_pred_neg: rcu_isd's lead copies (RA 131 (1))
  logic [4*WR-1:0]   i_lps2_cr01h;   // S0-S3's lead_phys_src2 (RA 132, OA 403, TI 400)
  logic [4*2*WR-1:0] i_lpsrc_cr01h;  // S0-S3's lead_phys_src, lead_phys_old_dst, lead_old_dst_pos, lead_src_pos
  logic [4*WR-1:0] i_lodst_cr01h;
  logic [4*2-1:0] i_lopos_cr01h;
  logic [4*6-1:0] i_lspos_cr01h;
  logic [NS*3-1:0] i_lsrc_cr01h;
  logic [NS-1:0] i_limm_cr01h;
  logic [NS-1:0] i_lmrg_cr01h;
  logic [NS-1:0] i_lgu_cr01h;
  logic [NS*WP-1:0] i_lgp_cr01h;
  logic [NS-1:0] i_lcont_cr00h;
  logic [NS*3*WR-1:0] i_src_cr01h;   // source i's row at (s*3 + i)*WR: phys_src[15:8], [7:0], phys_src2
  assign i_iv_cr00h[0] = ooe_rcu_issue_s0_valid;
  assign i_cont_cr01h[0] = ooe_rcu_issue_s0_payload.cont;
  assign i_foot_cr01h[0*4 +: 4] = ooe_rcu_issue_s0_payload.footprint;
  assign i_opc_cr02h[0*OW +: OW] = ooe_rcu_issue_s0_payload.opcode;
  assign i_drw_cr02h[0*2 +: 2] = ooe_rcu_issue_s0_payload.done_row;
  assign i_tag_cr02h[0*WT +: WT] = ooe_rcu_issue_s0_payload.rob_tag;
  assign i_im_cr02h[0*N +: N] = ooe_rcu_issue_s0_payload.issue_mask;
  assign i_pd_cr02h[0*WP +: WP] = ooe_rcu_issue_s0_payload.phys_pred_dst;
  assign i_pod_cr02h[0*WP +: WP] = ooe_rcu_issue_s0_payload.phys_pred_old_dst;
  assign i_pwe_cr02h[0] = ooe_rcu_issue_s0_payload.pred_we;
  assign i_mrg_cr01h[0] = ooe_rcu_issue_s0_payload.merge_en;
  assign i_dst_cr02h[0*WR +: WR] = ooe_rcu_issue_s0_payload.phys_dst;
  assign i_odst_cr01h[0*WR +: WR] = ooe_rcu_issue_s0_payload.phys_old_dst;
  assign i_imm_cr02h[0*32 +: 32] = ooe_rcu_issue_s0_payload.imm;
  assign i_spos_cr02h[0*6 +: 6] = ooe_rcu_issue_s0_payload.src_pos;
  assign i_swid_cr02h[0*6 +: 6] = ooe_rcu_issue_s0_payload.src_width;
  assign i_dpos_cr02h[0*2 +: 2] = ooe_rcu_issue_s0_payload.dst_pos;
  assign i_dwid_cr02h[0*2 +: 2] = ooe_rcu_issue_s0_payload.dst_width;
  assign i_opos_cr02h[0*2 +: 2] = ooe_rcu_issue_s0_payload.old_dst_pos;
  assign i_lsec_cr00h[0*4 +: 4] = ooe_rcu_issue_s0_payload.lead_sec_mask;
  assign i_lsrc_cr01h[0*3 +: 3] = ooe_rcu_issue_s0_payload.lead_src_used;
  assign i_limm_cr01h[0] = ooe_rcu_issue_s0_payload.lead_imm_used;
  assign i_lmrg_cr01h[0] = ooe_rcu_issue_s0_payload.lead_merge_used;
  assign i_lgu_cr01h[0] = ooe_rcu_issue_s0_payload.lead_guard_used;
  assign i_lgp_cr01h[0*WP +: WP] = ooe_rcu_issue_s0_payload.lead_guard_pred;
  assign i_lop_cr01h[0*OW +: OW] = ooe_rcu_issue_s0_payload.lead_opcode;
  assign i_ldrw_cr01h[0*2 +: 2] = ooe_rcu_issue_s0_payload.lead_done_row;
  assign i_lpwe_cr01h[0] = ooe_rcu_issue_s0_payload.lead_pred_we;
  assign i_ldst_cr01h[0*WR +: WR] = ooe_rcu_issue_s0_payload.lead_phys_dst;
  assign i_lcont_cr00h[0] = ooe_rcu_issue_s0_payload.lead_cont;
  assign i_lng_cr01h[0] = ooe_rcu_issue_s0_payload.lead_pred_neg;
  assign i_lpsrc_cr01h[0*2*WR +: 2*WR] = ooe_rcu_issue_s0_payload.lead_phys_src;
  assign i_lps2_cr01h[0*WR +: WR] = ooe_rcu_issue_s0_payload.lead_phys_src2;
  assign i_lodst_cr01h[0*WR +: WR] = ooe_rcu_issue_s0_payload.lead_phys_old_dst;
  assign i_lopos_cr01h[0*2 +: 2] = ooe_rcu_issue_s0_payload.lead_old_dst_pos;
  assign i_lspos_cr01h[0*6 +: 6] = ooe_rcu_issue_s0_payload.lead_src_pos;
  assign i_src_cr01h[(0*3 + 0)*WR +: WR] = ooe_rcu_issue_s0_payload.phys_src[2*WR-1:WR];
  assign i_src_cr01h[(0*3 + 1)*WR +: WR] = ooe_rcu_issue_s0_payload.phys_src[WR-1:0];
  assign i_src_cr01h[(0*3 + 2)*WR +: WR] = ooe_rcu_issue_s0_payload.phys_src2;
  assign i_iv_cr00h[1] = ooe_rcu_issue_s1_valid;
  assign i_cont_cr01h[1] = ooe_rcu_issue_s1_payload.cont;
  assign i_foot_cr01h[1*4 +: 4] = ooe_rcu_issue_s1_payload.footprint;
  assign i_opc_cr02h[1*OW +: OW] = ooe_rcu_issue_s1_payload.opcode;
  assign i_drw_cr02h[1*2 +: 2] = ooe_rcu_issue_s1_payload.done_row;
  assign i_tag_cr02h[1*WT +: WT] = ooe_rcu_issue_s1_payload.rob_tag;
  assign i_im_cr02h[1*N +: N] = ooe_rcu_issue_s1_payload.issue_mask;
  assign i_pd_cr02h[1*WP +: WP] = ooe_rcu_issue_s1_payload.phys_pred_dst;
  assign i_pod_cr02h[1*WP +: WP] = ooe_rcu_issue_s1_payload.phys_pred_old_dst;
  assign i_pwe_cr02h[1] = ooe_rcu_issue_s1_payload.pred_we;
  assign i_mrg_cr01h[1] = ooe_rcu_issue_s1_payload.merge_en;
  assign i_dst_cr02h[1*WR +: WR] = ooe_rcu_issue_s1_payload.phys_dst;
  assign i_odst_cr01h[1*WR +: WR] = ooe_rcu_issue_s1_payload.phys_old_dst;
  assign i_imm_cr02h[1*32 +: 32] = ooe_rcu_issue_s1_payload.imm;
  assign i_spos_cr02h[1*6 +: 6] = ooe_rcu_issue_s1_payload.src_pos;
  assign i_swid_cr02h[1*6 +: 6] = ooe_rcu_issue_s1_payload.src_width;
  assign i_dpos_cr02h[1*2 +: 2] = ooe_rcu_issue_s1_payload.dst_pos;
  assign i_dwid_cr02h[1*2 +: 2] = ooe_rcu_issue_s1_payload.dst_width;
  assign i_opos_cr02h[1*2 +: 2] = ooe_rcu_issue_s1_payload.old_dst_pos;
  assign i_lsec_cr00h[1*4 +: 4] = ooe_rcu_issue_s1_payload.lead_sec_mask;
  assign i_lsrc_cr01h[1*3 +: 3] = ooe_rcu_issue_s1_payload.lead_src_used;
  assign i_limm_cr01h[1] = ooe_rcu_issue_s1_payload.lead_imm_used;
  assign i_lmrg_cr01h[1] = ooe_rcu_issue_s1_payload.lead_merge_used;
  assign i_lgu_cr01h[1] = ooe_rcu_issue_s1_payload.lead_guard_used;
  assign i_lgp_cr01h[1*WP +: WP] = ooe_rcu_issue_s1_payload.lead_guard_pred;
  assign i_lop_cr01h[1*OW +: OW] = ooe_rcu_issue_s1_payload.lead_opcode;
  assign i_ldrw_cr01h[1*2 +: 2] = ooe_rcu_issue_s1_payload.lead_done_row;
  assign i_lpwe_cr01h[1] = ooe_rcu_issue_s1_payload.lead_pred_we;
  assign i_ldst_cr01h[1*WR +: WR] = ooe_rcu_issue_s1_payload.lead_phys_dst;
  assign i_lcont_cr00h[1] = ooe_rcu_issue_s1_payload.lead_cont;
  assign i_lng_cr01h[1] = ooe_rcu_issue_s1_payload.lead_pred_neg;
  assign i_lpsrc_cr01h[1*2*WR +: 2*WR] = ooe_rcu_issue_s1_payload.lead_phys_src;
  assign i_lps2_cr01h[1*WR +: WR] = ooe_rcu_issue_s1_payload.lead_phys_src2;
  assign i_lodst_cr01h[1*WR +: WR] = ooe_rcu_issue_s1_payload.lead_phys_old_dst;
  assign i_lopos_cr01h[1*2 +: 2] = ooe_rcu_issue_s1_payload.lead_old_dst_pos;
  assign i_lspos_cr01h[1*6 +: 6] = ooe_rcu_issue_s1_payload.lead_src_pos;
  assign i_src_cr01h[(1*3 + 0)*WR +: WR] = ooe_rcu_issue_s1_payload.phys_src[2*WR-1:WR];
  assign i_src_cr01h[(1*3 + 1)*WR +: WR] = ooe_rcu_issue_s1_payload.phys_src[WR-1:0];
  assign i_src_cr01h[(1*3 + 2)*WR +: WR] = ooe_rcu_issue_s1_payload.phys_src2;
  assign i_iv_cr00h[2] = ooe_rcu_issue_s2_valid;
  assign i_cont_cr01h[2] = ooe_rcu_issue_s2_payload.cont;
  assign i_foot_cr01h[2*4 +: 4] = ooe_rcu_issue_s2_payload.footprint;
  assign i_opc_cr02h[2*OW +: OW] = ooe_rcu_issue_s2_payload.opcode;
  assign i_drw_cr02h[2*2 +: 2] = ooe_rcu_issue_s2_payload.done_row;
  assign i_tag_cr02h[2*WT +: WT] = ooe_rcu_issue_s2_payload.rob_tag;
  assign i_im_cr02h[2*N +: N] = ooe_rcu_issue_s2_payload.issue_mask;
  assign i_pd_cr02h[2*WP +: WP] = ooe_rcu_issue_s2_payload.phys_pred_dst;
  assign i_pod_cr02h[2*WP +: WP] = ooe_rcu_issue_s2_payload.phys_pred_old_dst;
  assign i_pwe_cr02h[2] = ooe_rcu_issue_s2_payload.pred_we;
  assign i_mrg_cr01h[2] = ooe_rcu_issue_s2_payload.merge_en;
  assign i_dst_cr02h[2*WR +: WR] = ooe_rcu_issue_s2_payload.phys_dst;
  assign i_odst_cr01h[2*WR +: WR] = ooe_rcu_issue_s2_payload.phys_old_dst;
  assign i_imm_cr02h[2*32 +: 32] = ooe_rcu_issue_s2_payload.imm;
  assign i_spos_cr02h[2*6 +: 6] = ooe_rcu_issue_s2_payload.src_pos;
  assign i_swid_cr02h[2*6 +: 6] = ooe_rcu_issue_s2_payload.src_width;
  assign i_dpos_cr02h[2*2 +: 2] = ooe_rcu_issue_s2_payload.dst_pos;
  assign i_dwid_cr02h[2*2 +: 2] = ooe_rcu_issue_s2_payload.dst_width;
  assign i_opos_cr02h[2*2 +: 2] = ooe_rcu_issue_s2_payload.old_dst_pos;
  assign i_lsec_cr00h[2*4 +: 4] = ooe_rcu_issue_s2_payload.lead_sec_mask;
  assign i_lsrc_cr01h[2*3 +: 3] = ooe_rcu_issue_s2_payload.lead_src_used;
  assign i_limm_cr01h[2] = ooe_rcu_issue_s2_payload.lead_imm_used;
  assign i_lmrg_cr01h[2] = ooe_rcu_issue_s2_payload.lead_merge_used;
  assign i_lgu_cr01h[2] = ooe_rcu_issue_s2_payload.lead_guard_used;
  assign i_lgp_cr01h[2*WP +: WP] = ooe_rcu_issue_s2_payload.lead_guard_pred;
  assign i_lop_cr01h[2*OW +: OW] = ooe_rcu_issue_s2_payload.lead_opcode;
  assign i_ldrw_cr01h[2*2 +: 2] = ooe_rcu_issue_s2_payload.lead_done_row;
  assign i_lpwe_cr01h[2] = ooe_rcu_issue_s2_payload.lead_pred_we;
  assign i_ldst_cr01h[2*WR +: WR] = ooe_rcu_issue_s2_payload.lead_phys_dst;
  assign i_lcont_cr00h[2] = ooe_rcu_issue_s2_payload.lead_cont;
  assign i_lng_cr01h[2] = ooe_rcu_issue_s2_payload.lead_pred_neg;
  assign i_lpsrc_cr01h[2*2*WR +: 2*WR] = ooe_rcu_issue_s2_payload.lead_phys_src;
  assign i_lps2_cr01h[2*WR +: WR] = ooe_rcu_issue_s2_payload.lead_phys_src2;
  assign i_lodst_cr01h[2*WR +: WR] = ooe_rcu_issue_s2_payload.lead_phys_old_dst;
  assign i_lopos_cr01h[2*2 +: 2] = ooe_rcu_issue_s2_payload.lead_old_dst_pos;
  assign i_lspos_cr01h[2*6 +: 6] = ooe_rcu_issue_s2_payload.lead_src_pos;
  assign i_src_cr01h[(2*3 + 0)*WR +: WR] = ooe_rcu_issue_s2_payload.phys_src[2*WR-1:WR];
  assign i_src_cr01h[(2*3 + 1)*WR +: WR] = ooe_rcu_issue_s2_payload.phys_src[WR-1:0];
  assign i_src_cr01h[(2*3 + 2)*WR +: WR] = ooe_rcu_issue_s2_payload.phys_src2;
  assign i_iv_cr00h[3] = ooe_rcu_issue_s3_valid;
  assign i_cont_cr01h[3] = ooe_rcu_issue_s3_payload.cont;
  assign i_foot_cr01h[3*4 +: 4] = ooe_rcu_issue_s3_payload.footprint;
  assign i_opc_cr02h[3*OW +: OW] = ooe_rcu_issue_s3_payload.opcode;
  assign i_drw_cr02h[3*2 +: 2] = ooe_rcu_issue_s3_payload.done_row;
  assign i_tag_cr02h[3*WT +: WT] = ooe_rcu_issue_s3_payload.rob_tag;
  assign i_im_cr02h[3*N +: N] = ooe_rcu_issue_s3_payload.issue_mask;
  assign i_pd_cr02h[3*WP +: WP] = ooe_rcu_issue_s3_payload.phys_pred_dst;
  assign i_pod_cr02h[3*WP +: WP] = ooe_rcu_issue_s3_payload.phys_pred_old_dst;
  assign i_pwe_cr02h[3] = ooe_rcu_issue_s3_payload.pred_we;
  assign i_mrg_cr01h[3] = ooe_rcu_issue_s3_payload.merge_en;
  assign i_dst_cr02h[3*WR +: WR] = ooe_rcu_issue_s3_payload.phys_dst;
  assign i_odst_cr01h[3*WR +: WR] = ooe_rcu_issue_s3_payload.phys_old_dst;
  assign i_imm_cr02h[3*32 +: 32] = ooe_rcu_issue_s3_payload.imm;
  assign i_spos_cr02h[3*6 +: 6] = ooe_rcu_issue_s3_payload.src_pos;
  assign i_swid_cr02h[3*6 +: 6] = ooe_rcu_issue_s3_payload.src_width;
  assign i_dpos_cr02h[3*2 +: 2] = ooe_rcu_issue_s3_payload.dst_pos;
  assign i_dwid_cr02h[3*2 +: 2] = ooe_rcu_issue_s3_payload.dst_width;
  assign i_opos_cr02h[3*2 +: 2] = ooe_rcu_issue_s3_payload.old_dst_pos;
  assign i_lsec_cr00h[3*4 +: 4] = ooe_rcu_issue_s3_payload.lead_sec_mask;
  assign i_lsrc_cr01h[3*3 +: 3] = ooe_rcu_issue_s3_payload.lead_src_used;
  assign i_limm_cr01h[3] = ooe_rcu_issue_s3_payload.lead_imm_used;
  assign i_lmrg_cr01h[3] = ooe_rcu_issue_s3_payload.lead_merge_used;
  assign i_lgu_cr01h[3] = ooe_rcu_issue_s3_payload.lead_guard_used;
  assign i_lgp_cr01h[3*WP +: WP] = ooe_rcu_issue_s3_payload.lead_guard_pred;
  assign i_lop_cr01h[3*OW +: OW] = ooe_rcu_issue_s3_payload.lead_opcode;
  assign i_ldrw_cr01h[3*2 +: 2] = ooe_rcu_issue_s3_payload.lead_done_row;
  assign i_lpwe_cr01h[3] = ooe_rcu_issue_s3_payload.lead_pred_we;
  assign i_ldst_cr01h[3*WR +: WR] = ooe_rcu_issue_s3_payload.lead_phys_dst;
  assign i_lcont_cr00h[3] = ooe_rcu_issue_s3_payload.lead_cont;
  assign i_lng_cr01h[3] = ooe_rcu_issue_s3_payload.lead_pred_neg;
  assign i_lpsrc_cr01h[3*2*WR +: 2*WR] = ooe_rcu_issue_s3_payload.lead_phys_src;
  assign i_lps2_cr01h[3*WR +: WR] = ooe_rcu_issue_s3_payload.lead_phys_src2;
  assign i_lodst_cr01h[3*WR +: WR] = ooe_rcu_issue_s3_payload.lead_phys_old_dst;
  assign i_lopos_cr01h[3*2 +: 2] = ooe_rcu_issue_s3_payload.lead_old_dst_pos;
  assign i_lspos_cr01h[3*6 +: 6] = ooe_rcu_issue_s3_payload.lead_src_pos;
  assign i_src_cr01h[(3*3 + 0)*WR +: WR] = ooe_rcu_issue_s3_payload.phys_src[2*WR-1:WR];
  assign i_src_cr01h[(3*3 + 1)*WR +: WR] = ooe_rcu_issue_s3_payload.phys_src[WR-1:0];
  assign i_src_cr01h[(3*3 + 2)*WR +: WR] = ooe_rcu_issue_s3_payload.phys_src2;
  assign i_iv_cr00h[4] = ooe_rcu_issue_s4_valid;
  assign i_cont_cr01h[4] = ooe_rcu_issue_s4_payload.cont;
  assign i_foot_cr01h[4*4 +: 4] = ooe_rcu_issue_s4_payload.footprint;
  assign i_opc_cr02h[4*OW +: OW] = ooe_rcu_issue_s4_payload.opcode;
  assign i_drw_cr02h[4*2 +: 2] = ooe_rcu_issue_s4_payload.done_row;
  assign i_tag_cr02h[4*WT +: WT] = ooe_rcu_issue_s4_payload.rob_tag;
  assign i_im_cr02h[4*N +: N] = ooe_rcu_issue_s4_payload.issue_mask;
  assign i_pd_cr02h[4*WP +: WP] = ooe_rcu_issue_s4_payload.phys_pred_dst;
  assign i_pod_cr02h[4*WP +: WP] = ooe_rcu_issue_s4_payload.phys_pred_old_dst;
  assign i_pwe_cr02h[4] = ooe_rcu_issue_s4_payload.pred_we;
  assign i_mrg_cr01h[4] = ooe_rcu_issue_s4_payload.merge_en;
  assign i_dst_cr02h[4*WR +: WR] = ooe_rcu_issue_s4_payload.phys_dst;
  assign i_odst_cr01h[4*WR +: WR] = ooe_rcu_issue_s4_payload.phys_old_dst;
  assign i_imm_cr02h[4*32 +: 32] = ooe_rcu_issue_s4_payload.imm;
  assign i_spos_cr02h[4*6 +: 6] = ooe_rcu_issue_s4_payload.src_pos;
  assign i_swid_cr02h[4*6 +: 6] = ooe_rcu_issue_s4_payload.src_width;
  assign i_dpos_cr02h[4*2 +: 2] = ooe_rcu_issue_s4_payload.dst_pos;
  assign i_dwid_cr02h[4*2 +: 2] = ooe_rcu_issue_s4_payload.dst_width;
  assign i_opos_cr02h[4*2 +: 2] = ooe_rcu_issue_s4_payload.old_dst_pos;
  assign i_lsec_cr00h[4*4 +: 4] = ooe_rcu_issue_s4_payload.lead_sec_mask;
  assign i_lsrc_cr01h[4*3 +: 3] = ooe_rcu_issue_s4_payload.lead_src_used;
  assign i_limm_cr01h[4] = ooe_rcu_issue_s4_payload.lead_imm_used;
  assign i_lmrg_cr01h[4] = ooe_rcu_issue_s4_payload.lead_merge_used;
  assign i_lgu_cr01h[4] = ooe_rcu_issue_s4_payload.lead_guard_used;
  assign i_lgp_cr01h[4*WP +: WP] = ooe_rcu_issue_s4_payload.lead_guard_pred;
  assign i_lop_cr01h[4*OW +: OW] = ooe_rcu_issue_s4_payload.lead_opcode;
  assign i_ldrw_cr01h[4*2 +: 2] = ooe_rcu_issue_s4_payload.lead_done_row;
  assign i_lpwe_cr01h[4] = ooe_rcu_issue_s4_payload.lead_pred_we;
  assign i_ldst_cr01h[4*WR +: WR] = ooe_rcu_issue_s4_payload.lead_phys_dst;
  assign i_lcont_cr00h[4] = ooe_rcu_issue_s4_payload.lead_cont;
  assign i_lng_cr01h[4] = ooe_rcu_issue_s4_payload.lead_pred_neg;
  assign i_src_cr01h[(4*3 + 0)*WR +: WR] = ooe_rcu_issue_s4_payload.phys_src[2*WR-1:WR];
  assign i_src_cr01h[(4*3 + 1)*WR +: WR] = ooe_rcu_issue_s4_payload.phys_src[WR-1:0];
  assign i_src_cr01h[(4*3 + 2)*WR +: WR] = ooe_rcu_issue_s4_payload.phys_src2;
  assign i_iv_cr00h[5] = ooe_rcu_issue_s5_valid;
  assign i_cont_cr01h[5] = ooe_rcu_issue_s5_payload.cont;
  assign i_foot_cr01h[5*4 +: 4] = ooe_rcu_issue_s5_payload.footprint;
  assign i_opc_cr02h[5*OW +: OW] = ooe_rcu_issue_s5_payload.opcode;
  assign i_drw_cr02h[5*2 +: 2] = ooe_rcu_issue_s5_payload.done_row;
  assign i_tag_cr02h[5*WT +: WT] = ooe_rcu_issue_s5_payload.rob_tag;
  assign i_im_cr02h[5*N +: N] = ooe_rcu_issue_s5_payload.issue_mask;
  assign i_pd_cr02h[5*WP +: WP] = ooe_rcu_issue_s5_payload.phys_pred_dst;
  assign i_pod_cr02h[5*WP +: WP] = ooe_rcu_issue_s5_payload.phys_pred_old_dst;
  assign i_pwe_cr02h[5] = ooe_rcu_issue_s5_payload.pred_we;
  assign i_mrg_cr01h[5] = ooe_rcu_issue_s5_payload.merge_en;
  assign i_dst_cr02h[5*WR +: WR] = ooe_rcu_issue_s5_payload.phys_dst;
  assign i_odst_cr01h[5*WR +: WR] = ooe_rcu_issue_s5_payload.phys_old_dst;
  assign i_imm_cr02h[5*32 +: 32] = ooe_rcu_issue_s5_payload.imm;
  assign i_spos_cr02h[5*6 +: 6] = ooe_rcu_issue_s5_payload.src_pos;
  assign i_swid_cr02h[5*6 +: 6] = ooe_rcu_issue_s5_payload.src_width;
  assign i_dpos_cr02h[5*2 +: 2] = ooe_rcu_issue_s5_payload.dst_pos;
  assign i_dwid_cr02h[5*2 +: 2] = ooe_rcu_issue_s5_payload.dst_width;
  assign i_opos_cr02h[5*2 +: 2] = ooe_rcu_issue_s5_payload.old_dst_pos;
  assign i_lsec_cr00h[5*4 +: 4] = ooe_rcu_issue_s5_payload.lead_sec_mask;
  assign i_lsrc_cr01h[5*3 +: 3] = ooe_rcu_issue_s5_payload.lead_src_used;
  assign i_limm_cr01h[5] = ooe_rcu_issue_s5_payload.lead_imm_used;
  assign i_lmrg_cr01h[5] = ooe_rcu_issue_s5_payload.lead_merge_used;
  assign i_lgu_cr01h[5] = ooe_rcu_issue_s5_payload.lead_guard_used;
  assign i_lgp_cr01h[5*WP +: WP] = ooe_rcu_issue_s5_payload.lead_guard_pred;
  assign i_lop_cr01h[5*OW +: OW] = ooe_rcu_issue_s5_payload.lead_opcode;
  assign i_ldrw_cr01h[5*2 +: 2] = ooe_rcu_issue_s5_payload.lead_done_row;
  assign i_lpwe_cr01h[5] = ooe_rcu_issue_s5_payload.lead_pred_we;
  assign i_ldst_cr01h[5*WR +: WR] = ooe_rcu_issue_s5_payload.lead_phys_dst;
  assign i_lcont_cr00h[5] = ooe_rcu_issue_s5_payload.lead_cont;
  assign i_lng_cr01h[5] = ooe_rcu_issue_s5_payload.lead_pred_neg;
  assign i_src_cr01h[(5*3 + 0)*WR +: WR] = ooe_rcu_issue_s5_payload.phys_src[2*WR-1:WR];
  assign i_src_cr01h[(5*3 + 1)*WR +: WR] = ooe_rcu_issue_s5_payload.phys_src[WR-1:0];
  assign i_src_cr01h[(5*3 + 2)*WR +: WR] = ooe_rcu_issue_s5_payload.phys_src2;
  assign i_iv_cr00h[6] = ooe_rcu_issue_s6_valid;
  assign i_cont_cr01h[6] = ooe_rcu_issue_s6_payload.cont;
  assign i_foot_cr01h[6*4 +: 4] = ooe_rcu_issue_s6_payload.footprint;
  assign i_opc_cr02h[6*OW +: OW] = ooe_rcu_issue_s6_payload.opcode;
  assign i_drw_cr02h[6*2 +: 2] = ooe_rcu_issue_s6_payload.done_row;
  assign i_tag_cr02h[6*WT +: WT] = ooe_rcu_issue_s6_payload.rob_tag;
  assign i_im_cr02h[6*N +: N] = ooe_rcu_issue_s6_payload.issue_mask;
  assign i_pd_cr02h[6*WP +: WP] = ooe_rcu_issue_s6_payload.phys_pred_dst;
  assign i_pod_cr02h[6*WP +: WP] = ooe_rcu_issue_s6_payload.phys_pred_old_dst;
  assign i_pwe_cr02h[6] = ooe_rcu_issue_s6_payload.pred_we;
  assign i_mrg_cr01h[6] = ooe_rcu_issue_s6_payload.merge_en;
  assign i_dst_cr02h[6*WR +: WR] = ooe_rcu_issue_s6_payload.phys_dst;
  assign i_odst_cr01h[6*WR +: WR] = ooe_rcu_issue_s6_payload.phys_old_dst;
  assign i_imm_cr02h[6*32 +: 32] = ooe_rcu_issue_s6_payload.imm;
  assign i_spos_cr02h[6*6 +: 6] = ooe_rcu_issue_s6_payload.src_pos;
  assign i_swid_cr02h[6*6 +: 6] = ooe_rcu_issue_s6_payload.src_width;
  assign i_dpos_cr02h[6*2 +: 2] = ooe_rcu_issue_s6_payload.dst_pos;
  assign i_dwid_cr02h[6*2 +: 2] = ooe_rcu_issue_s6_payload.dst_width;
  assign i_opos_cr02h[6*2 +: 2] = ooe_rcu_issue_s6_payload.old_dst_pos;
  assign i_lsec_cr00h[6*4 +: 4] = ooe_rcu_issue_s6_payload.lead_sec_mask;
  assign i_lsrc_cr01h[6*3 +: 3] = ooe_rcu_issue_s6_payload.lead_src_used;
  assign i_limm_cr01h[6] = ooe_rcu_issue_s6_payload.lead_imm_used;
  assign i_lmrg_cr01h[6] = ooe_rcu_issue_s6_payload.lead_merge_used;
  assign i_lgu_cr01h[6] = ooe_rcu_issue_s6_payload.lead_guard_used;
  assign i_lgp_cr01h[6*WP +: WP] = ooe_rcu_issue_s6_payload.lead_guard_pred;
  assign i_lop_cr01h[6*OW +: OW] = ooe_rcu_issue_s6_payload.lead_opcode;
  assign i_ldrw_cr01h[6*2 +: 2] = ooe_rcu_issue_s6_payload.lead_done_row;
  assign i_lpwe_cr01h[6] = ooe_rcu_issue_s6_payload.lead_pred_we;
  assign i_ldst_cr01h[6*WR +: WR] = ooe_rcu_issue_s6_payload.lead_phys_dst;
  assign i_lcont_cr00h[6] = ooe_rcu_issue_s6_payload.lead_cont;
  assign i_lng_cr01h[6] = ooe_rcu_issue_s6_payload.lead_pred_neg;
  assign i_src_cr01h[(6*3 + 0)*WR +: WR] = ooe_rcu_issue_s6_payload.phys_src[2*WR-1:WR];
  assign i_src_cr01h[(6*3 + 1)*WR +: WR] = ooe_rcu_issue_s6_payload.phys_src[WR-1:0];
  assign i_src_cr01h[(6*3 + 2)*WR +: WR] = ooe_rcu_issue_s6_payload.phys_src2;
  assign i_iv_cr00h[7] = ooe_rcu_issue_s7_valid;
  assign i_cont_cr01h[7] = ooe_rcu_issue_s7_payload.cont;
  assign i_foot_cr01h[7*4 +: 4] = ooe_rcu_issue_s7_payload.footprint;
  assign i_opc_cr02h[7*OW +: OW] = ooe_rcu_issue_s7_payload.opcode;
  assign i_drw_cr02h[7*2 +: 2] = ooe_rcu_issue_s7_payload.done_row;
  assign i_tag_cr02h[7*WT +: WT] = ooe_rcu_issue_s7_payload.rob_tag;
  assign i_im_cr02h[7*N +: N] = ooe_rcu_issue_s7_payload.issue_mask;
  assign i_pd_cr02h[7*WP +: WP] = ooe_rcu_issue_s7_payload.phys_pred_dst;
  assign i_pod_cr02h[7*WP +: WP] = ooe_rcu_issue_s7_payload.phys_pred_old_dst;
  assign i_pwe_cr02h[7] = ooe_rcu_issue_s7_payload.pred_we;
  assign i_mrg_cr01h[7] = ooe_rcu_issue_s7_payload.merge_en;
  assign i_dst_cr02h[7*WR +: WR] = ooe_rcu_issue_s7_payload.phys_dst;
  assign i_odst_cr01h[7*WR +: WR] = ooe_rcu_issue_s7_payload.phys_old_dst;
  assign i_imm_cr02h[7*32 +: 32] = ooe_rcu_issue_s7_payload.imm;
  assign i_spos_cr02h[7*6 +: 6] = ooe_rcu_issue_s7_payload.src_pos;
  assign i_swid_cr02h[7*6 +: 6] = ooe_rcu_issue_s7_payload.src_width;
  assign i_dpos_cr02h[7*2 +: 2] = ooe_rcu_issue_s7_payload.dst_pos;
  assign i_dwid_cr02h[7*2 +: 2] = ooe_rcu_issue_s7_payload.dst_width;
  assign i_opos_cr02h[7*2 +: 2] = ooe_rcu_issue_s7_payload.old_dst_pos;
  assign i_lsec_cr00h[7*4 +: 4] = ooe_rcu_issue_s7_payload.lead_sec_mask;
  assign i_lsrc_cr01h[7*3 +: 3] = ooe_rcu_issue_s7_payload.lead_src_used;
  assign i_limm_cr01h[7] = ooe_rcu_issue_s7_payload.lead_imm_used;
  assign i_lmrg_cr01h[7] = ooe_rcu_issue_s7_payload.lead_merge_used;
  assign i_lgu_cr01h[7] = ooe_rcu_issue_s7_payload.lead_guard_used;
  assign i_lgp_cr01h[7*WP +: WP] = ooe_rcu_issue_s7_payload.lead_guard_pred;
  assign i_lop_cr01h[7*OW +: OW] = ooe_rcu_issue_s7_payload.lead_opcode;
  assign i_ldrw_cr01h[7*2 +: 2] = ooe_rcu_issue_s7_payload.lead_done_row;
  assign i_lpwe_cr01h[7] = ooe_rcu_issue_s7_payload.lead_pred_we;
  assign i_ldst_cr01h[7*WR +: WR] = ooe_rcu_issue_s7_payload.lead_phys_dst;
  assign i_lcont_cr00h[7] = ooe_rcu_issue_s7_payload.lead_cont;
  assign i_lng_cr01h[7] = ooe_rcu_issue_s7_payload.lead_pred_neg;
  assign i_src_cr01h[(7*3 + 0)*WR +: WR] = ooe_rcu_issue_s7_payload.phys_src[2*WR-1:WR];
  assign i_src_cr01h[(7*3 + 1)*WR +: WR] = ooe_rcu_issue_s7_payload.phys_src[WR-1:0];
  assign i_src_cr01h[(7*3 + 2)*WR +: WR] = ooe_rcu_issue_s7_payload.phys_src2;
  assign i_iv_cr00h[8] = ooe_rcu_issue_s8_valid;
  assign i_cont_cr01h[8] = ooe_rcu_issue_s8_payload.cont;
  assign i_foot_cr01h[8*4 +: 4] = ooe_rcu_issue_s8_payload.footprint;
  assign i_opc_cr02h[8*OW +: OW] = ooe_rcu_issue_s8_payload.opcode;
  assign i_drw_cr02h[8*2 +: 2] = ooe_rcu_issue_s8_payload.done_row;
  assign i_tag_cr02h[8*WT +: WT] = ooe_rcu_issue_s8_payload.rob_tag;
  assign i_im_cr02h[8*N +: N] = ooe_rcu_issue_s8_payload.issue_mask;
  assign i_pd_cr02h[8*WP +: WP] = ooe_rcu_issue_s8_payload.phys_pred_dst;
  assign i_pod_cr02h[8*WP +: WP] = ooe_rcu_issue_s8_payload.phys_pred_old_dst;
  assign i_pwe_cr02h[8] = ooe_rcu_issue_s8_payload.pred_we;
  assign i_mrg_cr01h[8] = ooe_rcu_issue_s8_payload.merge_en;
  assign i_dst_cr02h[8*WR +: WR] = ooe_rcu_issue_s8_payload.phys_dst;
  assign i_odst_cr01h[8*WR +: WR] = ooe_rcu_issue_s8_payload.phys_old_dst;
  assign i_imm_cr02h[8*32 +: 32] = ooe_rcu_issue_s8_payload.imm;
  assign i_spos_cr02h[8*6 +: 6] = ooe_rcu_issue_s8_payload.src_pos;
  assign i_swid_cr02h[8*6 +: 6] = ooe_rcu_issue_s8_payload.src_width;
  assign i_dpos_cr02h[8*2 +: 2] = ooe_rcu_issue_s8_payload.dst_pos;
  assign i_dwid_cr02h[8*2 +: 2] = ooe_rcu_issue_s8_payload.dst_width;
  assign i_opos_cr02h[8*2 +: 2] = ooe_rcu_issue_s8_payload.old_dst_pos;
  assign i_lsec_cr00h[8*4 +: 4] = ooe_rcu_issue_s8_payload.lead_sec_mask;
  assign i_lsrc_cr01h[8*3 +: 3] = ooe_rcu_issue_s8_payload.lead_src_used;
  assign i_limm_cr01h[8] = ooe_rcu_issue_s8_payload.lead_imm_used;
  assign i_lmrg_cr01h[8] = ooe_rcu_issue_s8_payload.lead_merge_used;
  assign i_lgu_cr01h[8] = ooe_rcu_issue_s8_payload.lead_guard_used;
  assign i_lgp_cr01h[8*WP +: WP] = ooe_rcu_issue_s8_payload.lead_guard_pred;
  assign i_lop_cr01h[8*OW +: OW] = ooe_rcu_issue_s8_payload.lead_opcode;
  assign i_ldrw_cr01h[8*2 +: 2] = ooe_rcu_issue_s8_payload.lead_done_row;
  assign i_lpwe_cr01h[8] = ooe_rcu_issue_s8_payload.lead_pred_we;
  assign i_ldst_cr01h[8*WR +: WR] = ooe_rcu_issue_s8_payload.lead_phys_dst;
  assign i_lcont_cr00h[8] = ooe_rcu_issue_s8_payload.lead_cont;
  assign i_lng_cr01h[8] = ooe_rcu_issue_s8_payload.lead_pred_neg;
  assign i_src_cr01h[(8*3 + 0)*WR +: WR] = ooe_rcu_issue_s8_payload.phys_src[2*WR-1:WR];
  assign i_src_cr01h[(8*3 + 1)*WR +: WR] = ooe_rcu_issue_s8_payload.phys_src[WR-1:0];
  assign i_src_cr01h[(8*3 + 2)*WR +: WR] = ooe_rcu_issue_s8_payload.phys_src2;
  // R's moved leads (RA-43): its whole imm and its source rows, in A-1 only;
  // R's payload imm and phys_src are zero. rcu_r and rcu_pred capture them.
  logic [31:0] i_lrp_cr01h;
  logic [2*WR-1:0] i_lps_cr01h;
  assign i_lrp_cr01h = ooe_rcu_issue_s8_payload.lead_rpsrc;
  assign i_lps_cr01h = ooe_rcu_issue_s8_payload.lead_phys_src;

  // ---- lane_rcu_res, flat ----------------------------------------------------
  logic [N-1:0] lr_v_cr00h;
  logic [N*32-1:0] lr_res_cr02h;
  logic [N*32-1:0] lr_sfu_cr02h;   // SW's data: sfu_result (RA rev 120)
  logic [N*NK-1:0] lr_sv_cr08h, lr_spo_cr02h;   // copy l's section k at l*NK + k
  assign lr_v_cr00h[0] = lane_rcu_res_c00_valid;
  assign lr_res_cr02h[0*32 +: 32] = lane_rcu_res_c00_payload.result;
  assign lr_sfu_cr02h[0*32 +: 32] = lane_rcu_res_c00_payload.sfu_result;
  assign lr_sv_cr08h[0*NK +: NK] = lane_rcu_res_c00_payload.sec_valid;
  assign lr_spo_cr02h[0*NK +: NK] = lane_rcu_res_c00_payload.sec_pred_out;
  assign lr_v_cr00h[1] = lane_rcu_res_c01_valid;
  assign lr_res_cr02h[1*32 +: 32] = lane_rcu_res_c01_payload.result;
  assign lr_sfu_cr02h[1*32 +: 32] = lane_rcu_res_c01_payload.sfu_result;
  assign lr_sv_cr08h[1*NK +: NK] = lane_rcu_res_c01_payload.sec_valid;
  assign lr_spo_cr02h[1*NK +: NK] = lane_rcu_res_c01_payload.sec_pred_out;
  assign lr_v_cr00h[2] = lane_rcu_res_c02_valid;
  assign lr_res_cr02h[2*32 +: 32] = lane_rcu_res_c02_payload.result;
  assign lr_sfu_cr02h[2*32 +: 32] = lane_rcu_res_c02_payload.sfu_result;
  assign lr_sv_cr08h[2*NK +: NK] = lane_rcu_res_c02_payload.sec_valid;
  assign lr_spo_cr02h[2*NK +: NK] = lane_rcu_res_c02_payload.sec_pred_out;
  assign lr_v_cr00h[3] = lane_rcu_res_c03_valid;
  assign lr_res_cr02h[3*32 +: 32] = lane_rcu_res_c03_payload.result;
  assign lr_sfu_cr02h[3*32 +: 32] = lane_rcu_res_c03_payload.sfu_result;
  assign lr_sv_cr08h[3*NK +: NK] = lane_rcu_res_c03_payload.sec_valid;
  assign lr_spo_cr02h[3*NK +: NK] = lane_rcu_res_c03_payload.sec_pred_out;
  assign lr_v_cr00h[4] = lane_rcu_res_c04_valid;
  assign lr_res_cr02h[4*32 +: 32] = lane_rcu_res_c04_payload.result;
  assign lr_sfu_cr02h[4*32 +: 32] = lane_rcu_res_c04_payload.sfu_result;
  assign lr_sv_cr08h[4*NK +: NK] = lane_rcu_res_c04_payload.sec_valid;
  assign lr_spo_cr02h[4*NK +: NK] = lane_rcu_res_c04_payload.sec_pred_out;
  assign lr_v_cr00h[5] = lane_rcu_res_c05_valid;
  assign lr_res_cr02h[5*32 +: 32] = lane_rcu_res_c05_payload.result;
  assign lr_sfu_cr02h[5*32 +: 32] = lane_rcu_res_c05_payload.sfu_result;
  assign lr_sv_cr08h[5*NK +: NK] = lane_rcu_res_c05_payload.sec_valid;
  assign lr_spo_cr02h[5*NK +: NK] = lane_rcu_res_c05_payload.sec_pred_out;
  assign lr_v_cr00h[6] = lane_rcu_res_c06_valid;
  assign lr_res_cr02h[6*32 +: 32] = lane_rcu_res_c06_payload.result;
  assign lr_sfu_cr02h[6*32 +: 32] = lane_rcu_res_c06_payload.sfu_result;
  assign lr_sv_cr08h[6*NK +: NK] = lane_rcu_res_c06_payload.sec_valid;
  assign lr_spo_cr02h[6*NK +: NK] = lane_rcu_res_c06_payload.sec_pred_out;
  assign lr_v_cr00h[7] = lane_rcu_res_c07_valid;
  assign lr_res_cr02h[7*32 +: 32] = lane_rcu_res_c07_payload.result;
  assign lr_sfu_cr02h[7*32 +: 32] = lane_rcu_res_c07_payload.sfu_result;
  assign lr_sv_cr08h[7*NK +: NK] = lane_rcu_res_c07_payload.sec_valid;
  assign lr_spo_cr02h[7*NK +: NK] = lane_rcu_res_c07_payload.sec_pred_out;
  assign lr_v_cr00h[8] = lane_rcu_res_c08_valid;
  assign lr_res_cr02h[8*32 +: 32] = lane_rcu_res_c08_payload.result;
  assign lr_sfu_cr02h[8*32 +: 32] = lane_rcu_res_c08_payload.sfu_result;
  assign lr_sv_cr08h[8*NK +: NK] = lane_rcu_res_c08_payload.sec_valid;
  assign lr_spo_cr02h[8*NK +: NK] = lane_rcu_res_c08_payload.sec_pred_out;
  assign lr_v_cr00h[9] = lane_rcu_res_c09_valid;
  assign lr_res_cr02h[9*32 +: 32] = lane_rcu_res_c09_payload.result;
  assign lr_sfu_cr02h[9*32 +: 32] = lane_rcu_res_c09_payload.sfu_result;
  assign lr_sv_cr08h[9*NK +: NK] = lane_rcu_res_c09_payload.sec_valid;
  assign lr_spo_cr02h[9*NK +: NK] = lane_rcu_res_c09_payload.sec_pred_out;
  assign lr_v_cr00h[10] = lane_rcu_res_c10_valid;
  assign lr_res_cr02h[10*32 +: 32] = lane_rcu_res_c10_payload.result;
  assign lr_sfu_cr02h[10*32 +: 32] = lane_rcu_res_c10_payload.sfu_result;
  assign lr_sv_cr08h[10*NK +: NK] = lane_rcu_res_c10_payload.sec_valid;
  assign lr_spo_cr02h[10*NK +: NK] = lane_rcu_res_c10_payload.sec_pred_out;
  assign lr_v_cr00h[11] = lane_rcu_res_c11_valid;
  assign lr_res_cr02h[11*32 +: 32] = lane_rcu_res_c11_payload.result;
  assign lr_sfu_cr02h[11*32 +: 32] = lane_rcu_res_c11_payload.sfu_result;
  assign lr_sv_cr08h[11*NK +: NK] = lane_rcu_res_c11_payload.sec_valid;
  assign lr_spo_cr02h[11*NK +: NK] = lane_rcu_res_c11_payload.sec_pred_out;
  assign lr_v_cr00h[12] = lane_rcu_res_c12_valid;
  assign lr_res_cr02h[12*32 +: 32] = lane_rcu_res_c12_payload.result;
  assign lr_sfu_cr02h[12*32 +: 32] = lane_rcu_res_c12_payload.sfu_result;
  assign lr_sv_cr08h[12*NK +: NK] = lane_rcu_res_c12_payload.sec_valid;
  assign lr_spo_cr02h[12*NK +: NK] = lane_rcu_res_c12_payload.sec_pred_out;
  assign lr_v_cr00h[13] = lane_rcu_res_c13_valid;
  assign lr_res_cr02h[13*32 +: 32] = lane_rcu_res_c13_payload.result;
  assign lr_sfu_cr02h[13*32 +: 32] = lane_rcu_res_c13_payload.sfu_result;
  assign lr_sv_cr08h[13*NK +: NK] = lane_rcu_res_c13_payload.sec_valid;
  assign lr_spo_cr02h[13*NK +: NK] = lane_rcu_res_c13_payload.sec_pred_out;
  assign lr_v_cr00h[14] = lane_rcu_res_c14_valid;
  assign lr_res_cr02h[14*32 +: 32] = lane_rcu_res_c14_payload.result;
  assign lr_sfu_cr02h[14*32 +: 32] = lane_rcu_res_c14_payload.sfu_result;
  assign lr_sv_cr08h[14*NK +: NK] = lane_rcu_res_c14_payload.sec_valid;
  assign lr_spo_cr02h[14*NK +: NK] = lane_rcu_res_c14_payload.sec_pred_out;
  assign lr_v_cr00h[15] = lane_rcu_res_c15_valid;
  assign lr_res_cr02h[15*32 +: 32] = lane_rcu_res_c15_payload.result;
  assign lr_sfu_cr02h[15*32 +: 32] = lane_rcu_res_c15_payload.sfu_result;
  assign lr_sv_cr08h[15*NK +: NK] = lane_rcu_res_c15_payload.sec_valid;
  assign lr_spo_cr02h[15*NK +: NK] = lane_rcu_res_c15_payload.sec_pred_out;
  assign lr_v_cr00h[16] = lane_rcu_res_c16_valid;
  assign lr_res_cr02h[16*32 +: 32] = lane_rcu_res_c16_payload.result;
  assign lr_sfu_cr02h[16*32 +: 32] = lane_rcu_res_c16_payload.sfu_result;
  assign lr_sv_cr08h[16*NK +: NK] = lane_rcu_res_c16_payload.sec_valid;
  assign lr_spo_cr02h[16*NK +: NK] = lane_rcu_res_c16_payload.sec_pred_out;
  assign lr_v_cr00h[17] = lane_rcu_res_c17_valid;
  assign lr_res_cr02h[17*32 +: 32] = lane_rcu_res_c17_payload.result;
  assign lr_sfu_cr02h[17*32 +: 32] = lane_rcu_res_c17_payload.sfu_result;
  assign lr_sv_cr08h[17*NK +: NK] = lane_rcu_res_c17_payload.sec_valid;
  assign lr_spo_cr02h[17*NK +: NK] = lane_rcu_res_c17_payload.sec_pred_out;
  assign lr_v_cr00h[18] = lane_rcu_res_c18_valid;
  assign lr_res_cr02h[18*32 +: 32] = lane_rcu_res_c18_payload.result;
  assign lr_sfu_cr02h[18*32 +: 32] = lane_rcu_res_c18_payload.sfu_result;
  assign lr_sv_cr08h[18*NK +: NK] = lane_rcu_res_c18_payload.sec_valid;
  assign lr_spo_cr02h[18*NK +: NK] = lane_rcu_res_c18_payload.sec_pred_out;
  assign lr_v_cr00h[19] = lane_rcu_res_c19_valid;
  assign lr_res_cr02h[19*32 +: 32] = lane_rcu_res_c19_payload.result;
  assign lr_sfu_cr02h[19*32 +: 32] = lane_rcu_res_c19_payload.sfu_result;
  assign lr_sv_cr08h[19*NK +: NK] = lane_rcu_res_c19_payload.sec_valid;
  assign lr_spo_cr02h[19*NK +: NK] = lane_rcu_res_c19_payload.sec_pred_out;
  assign lr_v_cr00h[20] = lane_rcu_res_c20_valid;
  assign lr_res_cr02h[20*32 +: 32] = lane_rcu_res_c20_payload.result;
  assign lr_sfu_cr02h[20*32 +: 32] = lane_rcu_res_c20_payload.sfu_result;
  assign lr_sv_cr08h[20*NK +: NK] = lane_rcu_res_c20_payload.sec_valid;
  assign lr_spo_cr02h[20*NK +: NK] = lane_rcu_res_c20_payload.sec_pred_out;
  assign lr_v_cr00h[21] = lane_rcu_res_c21_valid;
  assign lr_res_cr02h[21*32 +: 32] = lane_rcu_res_c21_payload.result;
  assign lr_sfu_cr02h[21*32 +: 32] = lane_rcu_res_c21_payload.sfu_result;
  assign lr_sv_cr08h[21*NK +: NK] = lane_rcu_res_c21_payload.sec_valid;
  assign lr_spo_cr02h[21*NK +: NK] = lane_rcu_res_c21_payload.sec_pred_out;
  assign lr_v_cr00h[22] = lane_rcu_res_c22_valid;
  assign lr_res_cr02h[22*32 +: 32] = lane_rcu_res_c22_payload.result;
  assign lr_sfu_cr02h[22*32 +: 32] = lane_rcu_res_c22_payload.sfu_result;
  assign lr_sv_cr08h[22*NK +: NK] = lane_rcu_res_c22_payload.sec_valid;
  assign lr_spo_cr02h[22*NK +: NK] = lane_rcu_res_c22_payload.sec_pred_out;
  assign lr_v_cr00h[23] = lane_rcu_res_c23_valid;
  assign lr_res_cr02h[23*32 +: 32] = lane_rcu_res_c23_payload.result;
  assign lr_sfu_cr02h[23*32 +: 32] = lane_rcu_res_c23_payload.sfu_result;
  assign lr_sv_cr08h[23*NK +: NK] = lane_rcu_res_c23_payload.sec_valid;
  assign lr_spo_cr02h[23*NK +: NK] = lane_rcu_res_c23_payload.sec_pred_out;
  assign lr_v_cr00h[24] = lane_rcu_res_c24_valid;
  assign lr_res_cr02h[24*32 +: 32] = lane_rcu_res_c24_payload.result;
  assign lr_sfu_cr02h[24*32 +: 32] = lane_rcu_res_c24_payload.sfu_result;
  assign lr_sv_cr08h[24*NK +: NK] = lane_rcu_res_c24_payload.sec_valid;
  assign lr_spo_cr02h[24*NK +: NK] = lane_rcu_res_c24_payload.sec_pred_out;
  assign lr_v_cr00h[25] = lane_rcu_res_c25_valid;
  assign lr_res_cr02h[25*32 +: 32] = lane_rcu_res_c25_payload.result;
  assign lr_sfu_cr02h[25*32 +: 32] = lane_rcu_res_c25_payload.sfu_result;
  assign lr_sv_cr08h[25*NK +: NK] = lane_rcu_res_c25_payload.sec_valid;
  assign lr_spo_cr02h[25*NK +: NK] = lane_rcu_res_c25_payload.sec_pred_out;
  assign lr_v_cr00h[26] = lane_rcu_res_c26_valid;
  assign lr_res_cr02h[26*32 +: 32] = lane_rcu_res_c26_payload.result;
  assign lr_sfu_cr02h[26*32 +: 32] = lane_rcu_res_c26_payload.sfu_result;
  assign lr_sv_cr08h[26*NK +: NK] = lane_rcu_res_c26_payload.sec_valid;
  assign lr_spo_cr02h[26*NK +: NK] = lane_rcu_res_c26_payload.sec_pred_out;
  assign lr_v_cr00h[27] = lane_rcu_res_c27_valid;
  assign lr_res_cr02h[27*32 +: 32] = lane_rcu_res_c27_payload.result;
  assign lr_sfu_cr02h[27*32 +: 32] = lane_rcu_res_c27_payload.sfu_result;
  assign lr_sv_cr08h[27*NK +: NK] = lane_rcu_res_c27_payload.sec_valid;
  assign lr_spo_cr02h[27*NK +: NK] = lane_rcu_res_c27_payload.sec_pred_out;
  assign lr_v_cr00h[28] = lane_rcu_res_c28_valid;
  assign lr_res_cr02h[28*32 +: 32] = lane_rcu_res_c28_payload.result;
  assign lr_sfu_cr02h[28*32 +: 32] = lane_rcu_res_c28_payload.sfu_result;
  assign lr_sv_cr08h[28*NK +: NK] = lane_rcu_res_c28_payload.sec_valid;
  assign lr_spo_cr02h[28*NK +: NK] = lane_rcu_res_c28_payload.sec_pred_out;
  assign lr_v_cr00h[29] = lane_rcu_res_c29_valid;
  assign lr_res_cr02h[29*32 +: 32] = lane_rcu_res_c29_payload.result;
  assign lr_sfu_cr02h[29*32 +: 32] = lane_rcu_res_c29_payload.sfu_result;
  assign lr_sv_cr08h[29*NK +: NK] = lane_rcu_res_c29_payload.sec_valid;
  assign lr_spo_cr02h[29*NK +: NK] = lane_rcu_res_c29_payload.sec_pred_out;
  assign lr_v_cr00h[30] = lane_rcu_res_c30_valid;
  assign lr_res_cr02h[30*32 +: 32] = lane_rcu_res_c30_payload.result;
  assign lr_sfu_cr02h[30*32 +: 32] = lane_rcu_res_c30_payload.sfu_result;
  assign lr_sv_cr08h[30*NK +: NK] = lane_rcu_res_c30_payload.sec_valid;
  assign lr_spo_cr02h[30*NK +: NK] = lane_rcu_res_c30_payload.sec_pred_out;
  assign lr_v_cr00h[31] = lane_rcu_res_c31_valid;
  assign lr_res_cr02h[31*32 +: 32] = lane_rcu_res_c31_payload.result;
  assign lr_sfu_cr02h[31*32 +: 32] = lane_rcu_res_c31_payload.sfu_result;
  assign lr_sv_cr08h[31*NK +: NK] = lane_rcu_res_c31_payload.sec_valid;
  assign lr_spo_cr02h[31*NK +: NK] = lane_rcu_res_c31_payload.sec_pred_out;
  // PL k's new value: lane l's sec_pred_out[k] (a transpose).
  logic [NK*N-1:0] pl_val_cr02h;
  for (genvar k = 0; k < NK; k++) begin : g_plval
    for (genvar l = 0; l < N; l++) begin : g_l
      assign pl_val_cr02h[k*N + l] = lr_spo_cr02h[l*NK + k];
    end
  end

  // ---- miu_rcu_data, flat ----------------------------------------------------
  logic [NM-1:0] md_v_cr00h, md_pwe_cr01h;
  logic [NM*WR-1:0] md_row_cr01h;
  logic [NM*2-1:0] md_wid_cr01h, md_pos_cr01h;
  logic [NM*N-1:0] md_am_cr01h, md_pr_cr02h;
  logic [NM*WP-1:0] md_pp_cr01h;
  logic [NM*N*32-1:0] md_dat_cr02h;
  assign md_v_cr00h[0] = miu_rcu_data_s0_valid;
  assign md_pwe_cr01h[0] = miu_rcu_data_s0_payload.pred_we;
  assign md_row_cr01h[0*WR +: WR] = miu_rcu_data_s0_payload.phys_dst;
  assign md_wid_cr01h[0*2 +: 2] = miu_rcu_data_s0_payload.dst_width;
  assign md_pos_cr01h[0*2 +: 2] = miu_rcu_data_s0_payload.dst_pos;
  assign md_am_cr01h[0*N +: N] = miu_rcu_data_s0_payload.active_mask;
  assign md_pr_cr02h[0*N +: N] = miu_rcu_data_s0_payload.pred_result;
  assign md_pp_cr01h[0*WP +: WP] = miu_rcu_data_s0_payload.phys_pred;
  assign md_dat_cr02h[0*N*32 +: N*32] = miu_rcu_data_s0_payload.load_data;
  assign md_v_cr00h[1] = miu_rcu_data_s1_valid;
  assign md_pwe_cr01h[1] = miu_rcu_data_s1_payload.pred_we;
  assign md_row_cr01h[1*WR +: WR] = miu_rcu_data_s1_payload.phys_dst;
  assign md_wid_cr01h[1*2 +: 2] = miu_rcu_data_s1_payload.dst_width;
  assign md_pos_cr01h[1*2 +: 2] = miu_rcu_data_s1_payload.dst_pos;
  assign md_am_cr01h[1*N +: N] = miu_rcu_data_s1_payload.active_mask;
  assign md_pr_cr02h[1*N +: N] = miu_rcu_data_s1_payload.pred_result;
  assign md_pp_cr01h[1*WP +: WP] = miu_rcu_data_s1_payload.phys_pred;
  assign md_dat_cr02h[1*N*32 +: N*32] = miu_rcu_data_s1_payload.load_data;
  assign md_v_cr00h[2] = miu_rcu_data_s2_valid;
  assign md_pwe_cr01h[2] = miu_rcu_data_s2_payload.pred_we;
  assign md_row_cr01h[2*WR +: WR] = miu_rcu_data_s2_payload.phys_dst;
  assign md_wid_cr01h[2*2 +: 2] = miu_rcu_data_s2_payload.dst_width;
  assign md_pos_cr01h[2*2 +: 2] = miu_rcu_data_s2_payload.dst_pos;
  assign md_am_cr01h[2*N +: N] = miu_rcu_data_s2_payload.active_mask;
  assign md_pr_cr02h[2*N +: N] = miu_rcu_data_s2_payload.pred_result;
  assign md_pp_cr01h[2*WP +: WP] = miu_rcu_data_s2_payload.phys_pred;
  assign md_dat_cr02h[2*N*32 +: N*32] = miu_rcu_data_s2_payload.load_data;
  assign md_v_cr00h[3] = miu_rcu_data_s3_valid;
  assign md_pwe_cr01h[3] = miu_rcu_data_s3_payload.pred_we;
  assign md_row_cr01h[3*WR +: WR] = miu_rcu_data_s3_payload.phys_dst;
  assign md_wid_cr01h[3*2 +: 2] = miu_rcu_data_s3_payload.dst_width;
  assign md_pos_cr01h[3*2 +: 2] = miu_rcu_data_s3_payload.dst_pos;
  assign md_am_cr01h[3*N +: N] = miu_rcu_data_s3_payload.active_mask;
  assign md_pr_cr02h[3*N +: N] = miu_rcu_data_s3_payload.pred_result;
  assign md_pp_cr01h[3*WP +: WP] = miu_rcu_data_s3_payload.phys_pred;
  assign md_dat_cr02h[3*N*32 +: N*32] = miu_rcu_data_s3_payload.load_data;

  assign wake_cr01h = {kill_valid, pca_rcu_mig_wake, rau_rcu_mig_wake, ooe_rcu_map_wake, miu_rcu_data_wake, lane_rcu_res_c31_wake, lane_rcu_res_c30_wake, lane_rcu_res_c29_wake, lane_rcu_res_c28_wake, lane_rcu_res_c27_wake, lane_rcu_res_c26_wake, lane_rcu_res_c25_wake, lane_rcu_res_c24_wake, lane_rcu_res_c23_wake, lane_rcu_res_c22_wake, lane_rcu_res_c21_wake, lane_rcu_res_c20_wake, lane_rcu_res_c19_wake, lane_rcu_res_c18_wake, lane_rcu_res_c17_wake, lane_rcu_res_c16_wake, lane_rcu_res_c15_wake, lane_rcu_res_c14_wake, lane_rcu_res_c13_wake, lane_rcu_res_c12_wake, lane_rcu_res_c11_wake, lane_rcu_res_c10_wake, lane_rcu_res_c09_wake, lane_rcu_res_c08_wake, lane_rcu_res_c07_wake, lane_rcu_res_c06_wake, lane_rcu_res_c05_wake, lane_rcu_res_c04_wake, lane_rcu_res_c03_wake, lane_rcu_res_c02_wake, lane_rcu_res_c01_wake, lane_rcu_res_c00_wake, ooe_rcu_issue_wake};

  // ---- Nets between the modules ---------------------------------------------
  // The bank slices: slice (K, J) is index K*NJ + J.
  localparam int NR = 8, NRR = 2;
  logic [NK*NJ*NR*32-1:0]  sl_rd_cr03h;             // its rd_cr03h: port p's 4 lanes' byte K at p*32 + 8i
  logic [NK*NJ*NRR*32-1:0] sl_rs_cr04h;             // its rs_cr04h: R0, R1
  logic [NK*4*N*8-1:0]     ln_rd_cr03h;             // L0-L3 for rcu_lanes: bank k, port p, lane l at ((k*4 + p)*N + l)*8
  logic [NK*3*N*8-1:0]     mm_rd_cr03h;             // M0-M2 for rcu_mem: ((k*3 + m)*N + l)*8
  logic [N*32-1:0]         r2_rd_cr03h, r0_rs_cr03h, r1_rs_cr03h; // R2, R0, R1: lane l's byte k at l*32 + 8k

  // rcu_isd, one a slot: the slot's class, decoded from its lead in A-1
  // (RA-43, RI-25), and its lead copies (RA 131 (1)): cont and pred_neg on
  // every slot for rcu_pred (cont on S0-S3 for rcu_lanes too); on S0-S3
  // (LS) phys_src, phys_old_dst, old_dst_pos and src_pos for rcu_lanes. Their readers take the copies
  // from these flops in A in place of the payload, whose in-path from the
  // zero-cycle end was over 12.
  localparam int CW = 27;    // = rcu_dec_pkg::CLS_W (as OW above: not that package here)
  localparam int XS = 2 + 2*WR + WR + 2 + 6 + WR;   // an S slot's lead copies, 42
  logic [NS*CW-1:0] i_cls_cr02h;
  logic [NS-1:0]    k_cont_cr02h, k_ng_cr02h;   // every slot's cont and pred_neg, from its copies
  logic [4*3*WR-1:0] k_src_cr02h;               // rcu_lanes' sources: the copies, rows 0-2
  logic [4*WR-1:0]  k_odst_cr02h;
  logic [4*2-1:0]   k_opos_cr02h;
  logic [4*6-1:0]   k_spos_cr02h;
  for (genvar s = 0; s < NS; s++) begin : g_isd
    if (s < 4) begin : g_s
      logic [XS-1:0] x_cr02h;
      rcu_isd #(.LS(1)) u_isd (
        .rcu_core_clk(rcu_core_clk),
        .iv_cr01h   (i_iv_cr00h[s]),
        .lop_cr01h  (i_lop_cr01h[s*OW +: OW]),
        .ldrw_cr01h (i_ldrw_cr01h[s*2 +: 2]),
        .lpwe_cr01h (i_lpwe_cr01h[s]),
        .ldst_cr01h (i_ldst_cr01h[s*WR +: WR]),
        .lx_cr01h   ({i_lps2_cr01h[s*WR +: WR], i_lspos_cr01h[s*6 +: 6], i_lopos_cr01h[s*2 +: 2], i_lodst_cr01h[s*WR +: WR],
                      i_lpsrc_cr01h[s*2*WR +: 2*WR], i_lng_cr01h[s], i_lcont_cr00h[s]}),
        .cls_cr02h  (i_cls_cr02h[s*CW +: CW]),
        .x_cr02h    (x_cr02h)
      );
      assign k_cont_cr02h[s] = x_cr02h[0];
      assign k_ng_cr02h[s]   = x_cr02h[1];
      assign k_src_cr02h[(s*3 + 0)*WR +: WR] = x_cr02h[2 + WR +: WR];   // phys_src[15:8]
      assign k_src_cr02h[(s*3 + 1)*WR +: WR] = x_cr02h[2 +: WR];        // phys_src[7:0]
      assign k_src_cr02h[(s*3 + 2)*WR +: WR] = x_cr02h[2 + 3*WR + 2 + 6 +: WR];   // phys_src2 (RA 132)
      assign k_odst_cr02h[s*WR +: WR] = x_cr02h[2 + 2*WR +: WR];
      assign k_opos_cr02h[s*2 +: 2]   = x_cr02h[2 + 3*WR +: 2];
      assign k_spos_cr02h[s*6 +: 6]   = x_cr02h[2 + 3*WR + 2 +: 6];
    end else begin : g_p
      logic [1:0] x_cr02h;
      rcu_isd u_isd (
        .rcu_core_clk(rcu_core_clk),
        .iv_cr01h   (i_iv_cr00h[s]),
        .lop_cr01h  (i_lop_cr01h[s*OW +: OW]),
        .ldrw_cr01h (i_ldrw_cr01h[s*2 +: 2]),
        .lpwe_cr01h (i_lpwe_cr01h[s]),
        .ldst_cr01h (i_ldst_cr01h[s*WR +: WR]),
        .lx_cr01h   ({i_lng_cr01h[s], i_lcont_cr00h[s]}),
        .cls_cr02h  (i_cls_cr02h[s*CW +: CW]),
        .x_cr02h    (x_cr02h)
      );
      assign k_cont_cr02h[s] = x_cr02h[0];
      assign k_ng_cr02h[s]   = x_cr02h[1];
    end
  end

  // rcu_pred
  logic [NS*N-1:0] p_act_cr03h;
  logic p_busy_cr03h, p_lbt_cr03h;
  logic [NK*N-1:0] p_gv_cr03h, p_pst_cr03h;
  logic [N-1:0] p_rpa_cr03h, p_rpb_cr03h, p_low_cr03h, p_lbm_cr03h;
  logic [N*NK-1:0] p_spb_cr03h;
  logic [NK*N-1:0] p_dq_cr02h;
  // rcu_r
  logic r_busy_cr03h, r_rwv_cr02h, r_prv_cr02h, r_prmrg_cr03h, r_dnbt_cr04h;
  logic [2*WR-1:0] r_rrow_cr02h;   // R's source rows, R0 at [7:0], from rcu_r's lead capture
  logic [WR-1:0] r_rwrow_cr03h;
  logic [3:0] r_rwsec_cr03h;
  logic [N*32-1:0] r_rwdat_cr04h;
  logic [WP-1:0] r_prrow_cr03h, r_prorow_cr03h;
  logic [N-1:0] r_prval_cr04h, r_prmm_cr04h, r_dnbm_cr04h;
  logic [1:0] r_dnv_cr03h, r_dnrow_cr04h;
  logic [WT-1:0] r_dntag_cr04h;
  logic [31:0] r_dnaux_cr04h;
  // rcu_lanes
  localparam int WO = ccv_prelim_pkg::CCV_L_W_OPCODE;
  localparam int NP = ccv_prelim_pkg::CCV_L_OPERANDS_PER_LANE + 1;
  localparam int WB = ccv_prov_pkg::CCV_P_W_LANE_BYP_SEL;
  localparam int NWK = (N + 7) / 8;
  logic [NWK-1:0] l_wk_cr02h;
  logic l_busy_cr03h, l_dbusy_cr03h, l_swv_cr11h, l_sdv_cr13h;
  logic [N-1:0] l_v_cr03h;
  logic [N*NK-1:0] l_sen_cr03h, l_spd_cr04h;
  logic [N*NK*WO-1:0] l_sop_cr04h;
  logic [N*NP*32-1:0] l_opd_cr04h;
  logic [N*NK*2-1:0] l_sown_cr04h, l_sdpos_cr04h, l_sdwid_cr04h;
  logic [N*NK*NP*2-1:0] l_sopos_cr04h, l_sowid_cr04h;
  logic [N*NK*NP*WB-1:0] l_sbyp_cr04h;
  logic [NK-1:0] l_lwv_cr06h, l_plv_cr06h, l_plmrg_cr07h, l_pcv_cr02h, l_dnv_cr08h;
  logic [NK*WR-1:0] l_lwrow_cr07h;
  logic [NK*NK-1:0] l_lwsec_cr07h;
  logic [NK*N-1:0] l_lwlm_cr08h, l_plmm_cr08h, l_pcm_cr04h;
  logic [NK*WP-1:0] l_plrow_cr07h, l_plorow_cr07h, l_pcrow_cr03h, l_pcorow_cr03h;
  logic [WR-1:0] l_swrow_cr12h;
  logic [NK-1:0] l_swsec_cr12h;
  logic [NK*WT-1:0] l_dntag_cr09h;
  logic [NK*2-1:0] l_dnrow_cr09h;
  logic [WT-1:0] l_sdtag_cr14h;
  logic [1:0] l_sdrow_cr14h;
  // rcu_mem
  logic m_wk_cr02h, m_busy_cr03h;
  logic [NK-1:0] m_v_cr03h;
  logic [NK*WT-1:0] m_tag_cr04h;
  logic [NK*N-1:0] m_am_cr04h;
  logic [NK*N*32-1:0] m_base_cr04h, m_idx_cr04h, m_sd_cr04h;
  // rcu_mig
  localparam int WW = ccv_params_pkg::CCV_W_WARP_ID;
  localparam int WMR = ccv_params_pkg::CCV_W_MIG_ROW;
  localparam int WD = ccv_params_pkg::CCV_W_DATA;
  logic g_mcr_cr02h, g_ccr_cr02h, g_pcr_cr04h, g_ov_cr03h, g_owk_cr03h, g_quiet_cr02h, g_busy_cr02h, g_r2v_cr01h, g_rwv_cr02h, g_rwsel_cr03h, g_gv_cr02h;
  logic [WW-1:0] g_ow_cr04h;
  logic [WMR-1:0] g_orow_cr04h;
  logic [WD-1:0] g_odat_cr04h, g_rwdat_cr04h;
  logic [WR-1:0] g_r2row_cr02h, g_rwrow_cr03h;
  logic [NK-1:0] g_dv_cr01h;
  logic [NK*WP-1:0] g_drow_cr02h, g_grow_cr03h;
  logic [NK*32-1:0] g_gdat_cr04h;
  // rcu_kill
  localparam int NCR = NS + N;   // rcu_kill NC: issue valids, then lane-result credits
  logic [NCR-1:0] k_cr_cr01h;
  logic k_dwake_cr01h, k_csr_done_cr01h, k_csr_cr_cr01h;
  logic [31:0] k_csr_data_cr01h;

  // ---- 32 rcu_bank_slice: K the byte section, J the lane group --------------
  for (genvar K = 0; K < NK; K++) begin : g_k
    for (genvar J = 0; J < NJ; J++) begin : g_j
      logic [3*32-1:0] wdat_cr02h;
      logic [3*4-1:0] wlm_cr02h;
      logic [NM*4-1:0] mlm_cr01h;
      logic [NM*4*32-1:0] mdat_cr02h;
      logic [31:0] gdat_cr02h;
      for (genvar i = 0; i < 4; i++) begin : g_i
        assign wdat_cr02h[0*32 + 8*i +: 8] = lr_res_cr02h[(4*J + i)*32 + 8*K +: 8];       // LW: the lanes' results
        assign wdat_cr02h[1*32 + 8*i +: 8] = lr_sfu_cr02h[(4*J + i)*32 + 8*K +: 8];       // SW: sfu_result, never result (RA rev 120)
        assign wdat_cr02h[2*32 + 8*i +: 8] = r_rwdat_cr04h[(4*J + i)*32 + 8*K +: 8];      // RW
        assign gdat_cr02h[8*i +: 8] = g_rwdat_cr04h[(4*J + i)*32 + 8*K +: 8];
        for (genvar j = 0; j < NM; j++) begin : g_m
          assign mlm_cr01h[j*4 + i] = md_am_cr01h[j*N + 4*J + i];
          assign mdat_cr02h[(j*4 + i)*32 +: 32] = md_dat_cr02h[j*N*32 + (4*J + i)*32 +: 32];
        end
      end
      assign wlm_cr02h = {4'hf, 4'hf, l_lwlm_cr08h[K*N + 4*J +: 4]};
      rcu_bank_slice #(.K(K), .FULL_ROW(1)) u_slice (
        .rcu_core_clk(rcu_core_clk),
        .rst_n       (rst_n),
        .sv_cr00h    (i_iv_cr00h[0 +: NK]),
        .scont_cr01h (i_cont_cr01h[0 +: NK]),
        .sfoot_cr01h (i_foot_cr01h[0 +: NK*NK]),
        .slcont_cr00h(i_lcont_cr00h[0 +: NK]),
        .slsec_cr00h (i_lsec_cr00h[0 +: NK*NK]),
        .ssrc_cr01h  (i_src_cr01h[0 +: NK*3*WR]),
        .sodst_cr01h (i_odst_cr01h[0 +: NK*WR]),
        .pv_cr00h    (i_iv_cr00h[NK +: NK]),
        .plcont_cr00h(i_lcont_cr00h[NK +: NK]),
        .plsec_cr00h (i_lsec_cr00h[NK*NK +: NK*NK]),
        .pcont_cr01h (i_cont_cr01h[NK +: NK]),
        .pfoot_cr01h (i_foot_cr01h[NK*NK +: NK*NK]),
        .pcls_cr01h  (i_cls_cr02h[NK*CW +: NK*CW]),
        .psrc_cr01h  (i_src_cr01h[NK*3*WR +: NK*3*WR]),
        .r2v_cr00h   (i_iv_cr00h[8]),
        .r2row_cr01h (i_odst_cr01h[8*WR +: WR]),
        .rd_cr03h    (sl_rd_cr03h[(K*NJ + J)*NR*32 +: NR*32]),
        .rv_cr02h    (i_iv_cr00h[8]),
        .rr_row_cr03h(r_rrow_cr02h),
        .rs_cr04h    (sl_rs_cr04h[(K*NJ + J)*NRR*32 +: NRR*32]),
        .wr_v_cr00h  ({r_rwv_cr02h, l_swv_cr11h, l_lwv_cr06h[K]}),
        .wr_row_cr01h({r_rwrow_cr03h, l_swrow_cr12h, l_lwrow_cr07h[K*WR +: WR]}),
        .wr_sec_cr01h({r_rwsec_cr03h, l_swsec_cr12h, l_lwsec_cr07h[K*NK +: NK]}),
        .wr_dat_cr02h(wdat_cr02h),
        .wr_lm_cr02h (wlm_cr02h),
        .mw_v_cr01h  (md_v_cr00h),
        .mw_row_cr01h(md_row_cr01h),
        .mw_wid_cr01h(md_wid_cr01h),
        .mw_pos_cr01h(md_pos_cr01h),
        .mw_lm_cr01h (mlm_cr01h),
        .mw_dat_cr02h(mdat_cr02h),
        .g2_v_cr00h  (g_r2v_cr01h),
        .g2_row_cr01h(g_r2row_cr02h),
        .rcls_cr01h  (i_cls_cr02h[8*CW +: CW]),
        .rmrg_cr01h  (i_mrg_cr01h[8]),
        .gw_v_cr00h  (g_rwv_cr02h),
        .gw_sel_cr01h(g_rwsel_cr03h),
        .gw_row_cr01h(g_rwrow_cr03h),
        .gw_dat_cr02h(gdat_cr02h)
      );
      // Its reads, to their readers' layouts (bit reorders only).
      for (genvar i = 0; i < 4; i++) begin : g_o
        for (genvar p = 0; p < 4; p++) begin : g_l
          assign ln_rd_cr03h[((K*4 + p)*N + 4*J + i)*8 +: 8] = sl_rd_cr03h[((K*NJ + J)*NR + p)*32 + 8*i +: 8];
        end
        for (genvar m = 0; m < 3; m++) begin : g_mm
          assign mm_rd_cr03h[((K*3 + m)*N + 4*J + i)*8 +: 8] = sl_rd_cr03h[((K*NJ + J)*NR + 4 + m)*32 + 8*i +: 8];
        end
        assign r2_rd_cr03h[(4*J + i)*32 + 8*K +: 8] = sl_rd_cr03h[((K*NJ + J)*NR + 7)*32 + 8*i +: 8];
        assign r0_rs_cr03h[(4*J + i)*32 + 8*K +: 8] = sl_rs_cr04h[((K*NJ + J)*NRR + 0)*32 + 8*i +: 8];
        assign r1_rs_cr03h[(4*J + i)*32 + 8*K +: 8] = sl_rs_cr04h[((K*NJ + J)*NRR + 1)*32 + 8*i +: 8];
      end
    end
  end

  // ---- rcu_pred: the predicate file and the guard path -----------------------
  // Merge ports: PL 0-3 (lane ops), PR 4 (R), PC 5-8 (predicate-only copies),
  // PG 9-12 (restore's row 16).
  rcu_pred u_pred (
    .rcu_core_clk(rcu_core_clk),
    .rst_n      (rst_n),
    .iv_cr01h   (i_iv_cr00h),
    .lgu_cr01h  (i_lgu_cr01h),
    .lgp_cr01h  (i_lgp_cr01h),
    .ng_cr02h   (k_ng_cr02h),
    .im_cr02h   (i_im_cr02h),
    .ocl_cr02h  (i_cls_cr02h),
    .cont_cr02h (k_cont_cr02h),
    .lrp_cr01h  (i_lrp_cr01h[2*WP + 1:0]),
    .ft_cr02h   (i_foot_cr01h[0 +: NK*NK]),
    .act_cr03h  (p_act_cr03h),
    .busy_cr03h (p_busy_cr03h),
    .gv_cr03h   (p_gv_cr03h),
    .pst_cr03h  (p_pst_cr03h),
    .rpa_cr03h  (p_rpa_cr03h),
    .rpb_cr03h  (p_rpb_cr03h),
    .low_cr03h  (p_low_cr03h),
    .lbt_cr03h  (p_lbt_cr03h),
    .lbm_cr03h  (p_lbm_cr03h),
    .spb_cr03h  (p_spb_cr03h),
    .mv_cr01h   (md_v_cr00h),
    .mwe_cr01h  (md_pwe_cr01h),
    .mp_cr01h   (md_pp_cr01h),
    .mam_cr01h  (md_am_cr01h),
    .mr_cr02h   (md_pr_cr02h),
    .qv_cr00h   ({{NK{g_gv_cr02h}}, l_pcv_cr02h, r_prv_cr02h, l_plv_cr06h}),
    .qrow_cr01h ({g_grow_cr03h, l_pcrow_cr03h, r_prrow_cr03h, l_plrow_cr07h}),
    .qorow_cr01h({{NK*WP{1'b0}}, l_pcorow_cr03h, r_prorow_cr03h, l_plorow_cr07h}),
    .qmrg_cr01h ({{NK{1'b0}}, {NK{1'b1}}, r_prmrg_cr03h, l_plmrg_cr07h}),
    .qm_cr02h   ({{NK*N{1'b1}}, l_pcm_cr04h, {N{1'b1}}, {NK*N{1'b1}}}),
    .qmm_cr02h  ({{NK*N{1'b1}}, {NK*N{1'b0}}, r_prmm_cr04h, l_plmm_cr08h}),
    .qval_cr02h ({g_gdat_cr04h, {NK*N{1'b0}}, r_prval_cr04h, pl_val_cr02h}),
    .dv_cr00h   (g_dv_cr01h),
    .drow_cr01h (g_drow_cr02h),
    .dq_cr02h   (p_dq_cr02h)
  );

  // ---- rcu_r: the R pipe -------------------------------------------------------
  rcu_r u_r (
    .rcu_core_clk(rcu_core_clk),
    .rst_n        (rst_n),
    .iv_cr01h     (i_iv_cr00h[8]),
    .ocl_cr02h    (i_cls_cr02h[8*CW +: CW]),
    .tag_cr02h    (i_tag_cr02h[8*WT +: WT]),
    .drow_cr02h   (i_drw_cr02h[8*2 +: 2]),
    .imask_cr02h  (i_im_cr02h[8*N +: N]),
    .lrp_cr01h    (i_lrp_cr01h),
    .lps_cr01h    ({i_lps_cr01h[WR-1:0], i_lps_cr01h[2*WR-1:WR]}),   // R0 (phys_src[15:8]) to [7:0]
    .rr_row_cr02h (r_rrow_cr02h),
    .dst_cr02h    (i_dst_cr02h[8*WR +: WR]),
    .dpos_cr02h   (i_dpos_cr02h[8*2 +: 2]),
    .dwid_cr02h   (i_dwid_cr02h[8*2 +: 2]),
    .opos_cr02h   (i_opos_cr02h[8*2 +: 2]),
    .spos_cr02h   (i_spos_cr02h[8*6 +: 4]),
    .swid_cr02h   (i_swid_cr02h[8*6 +: 4]),
    .pd_cr02h     (i_pd_cr02h[8*WP +: WP]),
    .pold_cr02h   (i_pod_cr02h[8*WP +: WP]),
    .mrg_cr02h    (i_mrg_cr01h[8]),
    .pwe_cr02h    (i_pwe_cr02h[8]),
    .rs0_cr03h    (r0_rs_cr03h),
    .rs1_cr03h    (r1_rs_cr03h),
    .rd2_cr03h    (r2_rd_cr03h),
    .act_cr03h    (p_act_cr03h[8*N +: N]),
    .rpa_cr03h    (p_rpa_cr03h),
    .rpb_cr03h    (p_rpb_cr03h),
    .low_cr03h    (p_low_cr03h),
    .busy_cr03h   (r_busy_cr03h),
    .rw_v_cr02h   (r_rwv_cr02h),
    .rw_row_cr03h (r_rwrow_cr03h),
    .rw_sec_cr03h (r_rwsec_cr03h),
    .rw_dat_cr04h (r_rwdat_cr04h),
    .pr_v_cr02h   (r_prv_cr02h),
    .pr_row_cr03h (r_prrow_cr03h),
    .pr_mrg_cr03h (r_prmrg_cr03h),
    .pr_orow_cr03h(r_prorow_cr03h),
    .pr_val_cr04h (r_prval_cr04h),
    .pr_mm_cr04h  (r_prmm_cr04h),
    .dn_v_cr03h   (r_dnv_cr03h),
    .dn_tag_cr04h (r_dntag_cr04h),
    .dn_row_cr04h (r_dnrow_cr04h),
    .dn_bt_cr04h  (r_dnbt_cr04h),
    .dn_bm_cr04h  (r_dnbm_cr04h),
    .dn_aux_cr04h (r_dnaux_cr04h)
  );

  // ---- rcu_lanes: S slots to the lanes, their write-back and done -------------
  rcu_lanes #(.COPIES(N)) u_lanes (
    .rcu_core_clk(rcu_core_clk),
    .rst_n       (rst_n),
    .iw_cr01h    (ooe_rcu_issue_wake),
    .iv_cr01h    (i_iv_cr00h[0 +: NK]),
    .lsec_cr01h  (i_lsec_cr00h[0 +: NK*NK]),
    .lsrc_cr01h  (i_lsrc_cr01h[0 +: NK*3]),
    .limm_cr01h  (i_limm_cr01h[0 +: NK]),
    .lmrg_cr01h  (i_lmrg_cr01h[0 +: NK]),
    .cont_cr02h  (k_cont_cr02h[0 +: NK]),
    .foot_cr02h  (i_foot_cr01h[0 +: NK*NK]),
    .opc_cr02h   (i_opc_cr02h[0 +: NK*OW]),
    .imm_cr02h   (i_imm_cr02h[0 +: NK*32]),
    .src_cr02h   (k_src_cr02h),
    .spos_cr02h  (k_spos_cr02h),
    .swid_cr02h  (i_swid_cr02h[0 +: NK*6]),
    .dst_cr02h   (i_dst_cr02h[0 +: NK*WR]),
    .odst_cr02h  (k_odst_cr02h),
    .dpos_cr02h  (i_dpos_cr02h[0 +: NK*2]),
    .dwid_cr02h  (i_dwid_cr02h[0 +: NK*2]),
    .opos_cr02h  (k_opos_cr02h),
    .mrg_cr02h   (i_mrg_cr01h[0 +: NK]),
    .pwe_cr02h   (i_pwe_cr02h[0 +: NK]),
    .pd_cr02h    (i_pd_cr02h[0 +: NK*WP]),
    .pod_cr02h   (i_pod_cr02h[0 +: NK*WP]),
    .tag_cr02h   (i_tag_cr02h[0 +: NK*WT]),
    .drow_cr02h  (i_drw_cr02h[0 +: NK*2]),
    .ocl_cr02h   (i_cls_cr02h[0 +: NK*CW]),
    .acta_cr03h  (p_act_cr03h[0 +: NK*N]),
    .gv_cr03h    (p_gv_cr03h),
    .rd_cr03h    (ln_rd_cr03h),
    .lrv_cr07h   (lr_v_cr00h),
    .lsv_cr08h   (lr_sv_cr08h),
    .lwk_cr02h   (l_wk_cr02h),
    .busy_cr03h  (l_busy_cr03h),
    .dbusy_cr03h (l_dbusy_cr03h),
    .lv_cr03h    (l_v_cr03h),
    .sen_cr03h   (l_sen_cr03h),
    .sop_cr04h   (l_sop_cr04h),
    .opd_cr04h   (l_opd_cr04h),
    .sown_cr04h  (l_sown_cr04h),
    .spd_cr04h   (l_spd_cr04h),
    .sopos_cr04h (l_sopos_cr04h),
    .sowid_cr04h (l_sowid_cr04h),
    .sdpos_cr04h (l_sdpos_cr04h),
    .sdwid_cr04h (l_sdwid_cr04h),
    .sbyp_cr04h  (l_sbyp_cr04h),
    .lwv_cr06h   (l_lwv_cr06h),
    .lwrow_cr07h (l_lwrow_cr07h),
    .lwsec_cr07h (l_lwsec_cr07h),
    .lwlm_cr08h  (l_lwlm_cr08h),
    .plv_cr06h   (l_plv_cr06h),
    .plrow_cr07h (l_plrow_cr07h),
    .plorow_cr07h(l_plorow_cr07h),
    .plmrg_cr07h (l_plmrg_cr07h),
    .plmm_cr08h  (l_plmm_cr08h),
    .pcv_cr02h   (l_pcv_cr02h),
    .pcrow_cr03h (l_pcrow_cr03h),
    .pcorow_cr03h(l_pcorow_cr03h),
    .pcm_cr04h   (l_pcm_cr04h),
    .swv_cr11h   (l_swv_cr11h),
    .swrow_cr12h (l_swrow_cr12h),
    .swsec_cr12h (l_swsec_cr12h),
    .dnv_cr08h   (l_dnv_cr08h),
    .dntag_cr09h (l_dntag_cr09h),
    .dnrow_cr09h (l_dnrow_cr09h),
    .sdv_cr13h   (l_sdv_cr13h),
    .sdtag_cr14h (l_sdtag_cr14h),
    .sdrow_cr14h (l_sdrow_cr14h)
  );

  // ---- rcu_mem: P slots' operands to MIU ---------------------------------------
  rcu_mem #(.COPIES(N)) u_mem (
    .rcu_core_clk(rcu_core_clk),
    .rst_n      (rst_n),
    .iw_cr01h   (ooe_rcu_issue_wake),
    .iv_cr01h   (i_iv_cr00h[NK +: NK]),
    .lsrc_cr01h (i_lsrc_cr01h[NK*3 +: NK*3]),
    .ocl_cr02h  (i_cls_cr02h[NK*CW +: NK*CW]),
    .cont_cr02h (i_cont_cr01h[NK +: NK]),
    .foot_cr02h (i_foot_cr01h[NK*NK +: NK*NK]),
    .spos_cr02h (i_spos_cr02h[NK*6 +: NK*6]),
    .swid_cr02h (i_swid_cr02h[NK*6 +: NK*6]),
    .tag_cr02h  (i_tag_cr02h[NK*WT +: NK*WT]),
    .act_cr03h  (p_act_cr03h[NK*N +: NK*N]),
    .pst_cr03h  (p_pst_cr03h),
    .rd_cr03h   (mm_rd_cr03h),
    .mwk_cr02h  (m_wk_cr02h),
    .busy_cr03h (m_busy_cr03h),
    .mv_cr03h   (m_v_cr03h),
    .mtag_cr04h (m_tag_cr04h),
    .mam_cr04h  (m_am_cr04h),
    .mbase_cr04h(m_base_cr04h),
    .midx_cr04h (m_idx_cr04h),
    .msd_cr04h  (m_sd_cr04h)
  );

  // ---- rcu_mig: migration --------------------------------------------------------
  rcu_mig u_mig (
    .rcu_core_clk(rcu_core_clk),
    .rst_n      (rst_n),
    .mv_cr00h   (ooe_rcu_map_valid),
    .mw_cr01h   (ooe_rcu_map_payload.warp_id),
    .md_cr01h   (ooe_rcu_map_payload.direction),
    .mg_cr01h   (ooe_rcu_map_payload.gpr_map),
    .mp_cr01h   (ooe_rcu_map_payload.pred_map),
    .mcr_cr02h  (g_mcr_cr02h),
    .cv_cr00h   (rau_rcu_mig_valid),
    .cw_cr01h   (rau_rcu_mig_payload.warp_id),
    .cd_cr01h   (rau_rcu_mig_payload.direction),
    .ccr_cr02h  (g_ccr_cr02h),
    .pv_cr00h   (pca_rcu_mig_valid),
    .pw_cr01h   (pca_rcu_mig_payload.warp_id),
    .prow_cr01h (pca_rcu_mig_payload.mig_row),
    .pdat_cr01h (pca_rcu_mig_payload.row_data),
    .pcr_cr04h  (g_pcr_cr04h),
    .ost_cr02h  (rcu_pca_mig_stall),
    .ocr_cr01h  (rcu_pca_mig_credit),
    .ov_cr03h   (g_ov_cr03h),
    .ow_cr04h   (g_ow_cr04h),
    .orow_cr04h (g_orow_cr04h),
    .odat_cr04h (g_odat_cr04h),
    .owk_cr03h  (g_owk_cr03h),
    .kv_cr01h   (kill_detect_v_cr01h),
    .kmn_cr02h  (kill_detect_km_cr02h),
    .quiet_cr02h(g_quiet_cr02h),
    .busy_cr02h (g_busy_cr02h),
    .riv_cr01h  (i_iv_cr00h[8]),
    .rcls_cr02h (i_cls_cr02h[8*CW +: CW]),
    .rmrg_cr02h (i_mrg_cr01h[8]),
    .r2v_cr01h  (g_r2v_cr01h),
    .r2row_cr02h(g_r2row_cr02h),
    .rd2_cr03h  (r2_rd_cr03h),
    .dv_cr01h   (g_dv_cr01h),
    .drow_cr02h (g_drow_cr02h),
    .dq_cr03h   (p_dq_cr02h),
    .rwv_cr02h  (g_rwv_cr02h),
    .rwsel_cr03h(g_rwsel_cr03h),
    .rwrow_cr03h(g_rwrow_cr03h),
    .rwdat_cr04h(g_rwdat_cr04h),
    .gv_cr02h   (g_gv_cr02h),
    .grow_cr03h (g_grow_cr03h),
    .gdat_cr04h (g_gdat_cr04h)
  );

  // ---- The kill detector (RA rev 127, AR 336 (b)) -------------------------
  // kill_valid lands in K-1 and is in the gate's wake OR, but a wake opens
  // the gate only from the edge after next (ccv_common_clk), so asleep, the
  // edge that ends K-1 never reaches rcu_kill or rcu_mig. This flop takes it
  // on the ungated clock, the one wake detector CCV-L22 allows: kill_v_q in
  // K for both, asleep as awake, with no cycle added (a hold, not a delay).
  // The edge that ends K, which takes the epoch and the warp mask, is the
  // first the wake opens. The kill's three inputs go straight into these
  // flops, RCU's boundary flops for them (AR's rev 285 (5), AR 338): the
  // epoch and the warp mask of K are here in K+1, where rcu_mig reads the
  // mask with kill_v_q a cycle on and rcu_kill holds the epoch to the ack
  // under its own flop. No reset: OOE holds kill_valid low in reset, and
  // rcu_kill and rcu_mig reset what they enable. 1 + WE + NWP flops, written
  // every cycle, in the block's 2% (RA rev 127, RA rev 130).
  logic        kill_detect_v_cr01h;
  logic [1:0]  kill_detect_ep_cr02h;    // kill_epoch's width (Icarus sizes $bits of a port as 0 here)
  logic [31:0] kill_detect_km_cr02h;    // kill_warp_mask's
  always_ff @(posedge core_clk) begin
    kill_detect_v_cr01h  <= kill_valid;
    kill_detect_ep_cr02h <= kill_epoch;
    kill_detect_km_cr02h <= kill_warp_mask;
  end

  // ---- rcu_kill: kill, the inbound credits, done's wake and the block's idle ---
  rcu_kill u_kill (
    .rcu_core_clk  (rcu_core_clk),
    .rst_n         (rst_n),
    .kv_cr01h      (kill_detect_v_cr01h),
    .kep_cr02h     (kill_detect_ep_cr02h),
    .mq_cr01h      (g_quiet_cr02h),
    .kack_cr02h    (kill_ack),
    .kaep_cr03h    (kill_ack_epoch),
    .iv_cr00h      (i_iv_cr00h),
    .lv_cr00h      (lr_v_cr00h),
    .mv_cr00h      (md_v_cr00h),
    .cr_cr01h      (k_cr_cr01h),
    .dbusy_cr00h   ({r_busy_cr03h, l_dbusy_cr03h}),
    .busy_cr00h    ({1'b0, p_busy_cr03h, m_busy_cr03h, r_busy_cr03h, l_busy_cr03h, g_busy_cr02h}),
    .dwake_cr01h   (k_dwake_cr01h),
    .idle_cr01h    (idle_cr01h),
    .csr_v_cr00h   (1'b0),
    .csr_done_cr01h(k_csr_done_cr01h),
    .csr_data_cr01h(k_csr_data_cr01h),
    .csr_cr_cr01h  (k_csr_cr_cr01h)
  );

  // ---- The block's outputs: every one from a module's flop, or a constant ------
  assign csr_rsp = {k_csr_done_cr01h, k_csr_data_cr01h};
  assign csr_credit = k_csr_cr_cr01h;
  assign ooe_rcu_map_credit = g_mcr_cr02h;
  assign rau_rcu_mig_credit = g_ccr_cr02h;
  assign pca_rcu_mig_credit = g_pcr_cr04h;
  assign ooe_rcu_map_stall = 1'b0;
  assign rau_rcu_mig_stall = 1'b0;
  assign pca_rcu_mig_stall = 1'b0;
  assign rcu_pca_mig_valid = g_ov_cr03h;
  assign rcu_pca_mig_payload.warp_id = g_ow_cr04h;
  assign rcu_pca_mig_payload.mig_row = g_orow_cr04h;
  assign rcu_pca_mig_payload.row_data = g_odat_cr04h;
  assign rcu_pca_mig_wake = g_owk_cr03h;
  assign rcu_ooe_done_wake = k_dwake_cr01h;
  assign rcu_miu_addr_wake = m_wk_cr02h;

  assign ooe_rcu_issue_s0_stall = 1'b0;
  assign ooe_rcu_issue_s0_credit = k_cr_cr01h[0];
  assign ooe_rcu_issue_s1_stall = 1'b0;
  assign ooe_rcu_issue_s1_credit = k_cr_cr01h[1];
  assign ooe_rcu_issue_s2_stall = 1'b0;
  assign ooe_rcu_issue_s2_credit = k_cr_cr01h[2];
  assign ooe_rcu_issue_s3_stall = 1'b0;
  assign ooe_rcu_issue_s3_credit = k_cr_cr01h[3];
  assign ooe_rcu_issue_s4_stall = 1'b0;
  assign ooe_rcu_issue_s4_credit = k_cr_cr01h[4];
  assign ooe_rcu_issue_s5_stall = 1'b0;
  assign ooe_rcu_issue_s5_credit = k_cr_cr01h[5];
  assign ooe_rcu_issue_s6_stall = 1'b0;
  assign ooe_rcu_issue_s6_credit = k_cr_cr01h[6];
  assign ooe_rcu_issue_s7_stall = 1'b0;
  assign ooe_rcu_issue_s7_credit = k_cr_cr01h[7];
  assign ooe_rcu_issue_s8_stall = 1'b0;
  assign ooe_rcu_issue_s8_credit = k_cr_cr01h[8];
  assign rcu_lane_ops_c00_valid = l_v_cr03h[0];
  assign rcu_lane_ops_c00_wake = l_wk_cr02h[0];
  assign rcu_lane_ops_c00_payload.sec_opcode = l_sop_cr04h[0*NK*WO +: NK*WO];
  assign rcu_lane_ops_c00_payload.operand = l_opd_cr04h[0*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c00_payload.merge_data = l_opd_cr04h[0*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c00_payload.section_en = l_sen_cr03h[0*NK +: NK];
  assign rcu_lane_ops_c00_payload.sec_owner = l_sown_cr04h[0*NK*2 +: NK*2];
  assign rcu_lane_ops_c00_payload.sec_pred_bit = p_spb_cr03h[0*NK +: NK];
  assign rcu_lane_ops_c00_payload.sec_pred_data = l_spd_cr04h[0*NK +: NK];
  assign rcu_lane_ops_c00_payload.sec_opnd_pos = l_sopos_cr04h[0*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c00_payload.sec_opnd_width = l_sowid_cr04h[0*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c00_payload.sec_dst_pos = l_sdpos_cr04h[0*NK*2 +: NK*2];
  assign rcu_lane_ops_c00_payload.sec_dst_width = l_sdwid_cr04h[0*NK*2 +: NK*2];
  assign rcu_lane_ops_c00_payload.operand_byp = l_sbyp_cr04h[0*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c00_credit = k_cr_cr01h[NS + 0];
  assign lane_rcu_res_c00_stall = 1'b0;
  assign rcu_lane_ops_c01_valid = l_v_cr03h[1];
  assign rcu_lane_ops_c01_wake = l_wk_cr02h[0];
  assign rcu_lane_ops_c01_payload.sec_opcode = l_sop_cr04h[1*NK*WO +: NK*WO];
  assign rcu_lane_ops_c01_payload.operand = l_opd_cr04h[1*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c01_payload.merge_data = l_opd_cr04h[1*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c01_payload.section_en = l_sen_cr03h[1*NK +: NK];
  assign rcu_lane_ops_c01_payload.sec_owner = l_sown_cr04h[1*NK*2 +: NK*2];
  assign rcu_lane_ops_c01_payload.sec_pred_bit = p_spb_cr03h[1*NK +: NK];
  assign rcu_lane_ops_c01_payload.sec_pred_data = l_spd_cr04h[1*NK +: NK];
  assign rcu_lane_ops_c01_payload.sec_opnd_pos = l_sopos_cr04h[1*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c01_payload.sec_opnd_width = l_sowid_cr04h[1*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c01_payload.sec_dst_pos = l_sdpos_cr04h[1*NK*2 +: NK*2];
  assign rcu_lane_ops_c01_payload.sec_dst_width = l_sdwid_cr04h[1*NK*2 +: NK*2];
  assign rcu_lane_ops_c01_payload.operand_byp = l_sbyp_cr04h[1*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c01_credit = k_cr_cr01h[NS + 1];
  assign lane_rcu_res_c01_stall = 1'b0;
  assign rcu_lane_ops_c02_valid = l_v_cr03h[2];
  assign rcu_lane_ops_c02_wake = l_wk_cr02h[0];
  assign rcu_lane_ops_c02_payload.sec_opcode = l_sop_cr04h[2*NK*WO +: NK*WO];
  assign rcu_lane_ops_c02_payload.operand = l_opd_cr04h[2*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c02_payload.merge_data = l_opd_cr04h[2*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c02_payload.section_en = l_sen_cr03h[2*NK +: NK];
  assign rcu_lane_ops_c02_payload.sec_owner = l_sown_cr04h[2*NK*2 +: NK*2];
  assign rcu_lane_ops_c02_payload.sec_pred_bit = p_spb_cr03h[2*NK +: NK];
  assign rcu_lane_ops_c02_payload.sec_pred_data = l_spd_cr04h[2*NK +: NK];
  assign rcu_lane_ops_c02_payload.sec_opnd_pos = l_sopos_cr04h[2*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c02_payload.sec_opnd_width = l_sowid_cr04h[2*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c02_payload.sec_dst_pos = l_sdpos_cr04h[2*NK*2 +: NK*2];
  assign rcu_lane_ops_c02_payload.sec_dst_width = l_sdwid_cr04h[2*NK*2 +: NK*2];
  assign rcu_lane_ops_c02_payload.operand_byp = l_sbyp_cr04h[2*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c02_credit = k_cr_cr01h[NS + 2];
  assign lane_rcu_res_c02_stall = 1'b0;
  assign rcu_lane_ops_c03_valid = l_v_cr03h[3];
  assign rcu_lane_ops_c03_wake = l_wk_cr02h[0];
  assign rcu_lane_ops_c03_payload.sec_opcode = l_sop_cr04h[3*NK*WO +: NK*WO];
  assign rcu_lane_ops_c03_payload.operand = l_opd_cr04h[3*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c03_payload.merge_data = l_opd_cr04h[3*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c03_payload.section_en = l_sen_cr03h[3*NK +: NK];
  assign rcu_lane_ops_c03_payload.sec_owner = l_sown_cr04h[3*NK*2 +: NK*2];
  assign rcu_lane_ops_c03_payload.sec_pred_bit = p_spb_cr03h[3*NK +: NK];
  assign rcu_lane_ops_c03_payload.sec_pred_data = l_spd_cr04h[3*NK +: NK];
  assign rcu_lane_ops_c03_payload.sec_opnd_pos = l_sopos_cr04h[3*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c03_payload.sec_opnd_width = l_sowid_cr04h[3*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c03_payload.sec_dst_pos = l_sdpos_cr04h[3*NK*2 +: NK*2];
  assign rcu_lane_ops_c03_payload.sec_dst_width = l_sdwid_cr04h[3*NK*2 +: NK*2];
  assign rcu_lane_ops_c03_payload.operand_byp = l_sbyp_cr04h[3*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c03_credit = k_cr_cr01h[NS + 3];
  assign lane_rcu_res_c03_stall = 1'b0;
  assign rcu_lane_ops_c04_valid = l_v_cr03h[4];
  assign rcu_lane_ops_c04_wake = l_wk_cr02h[0];
  assign rcu_lane_ops_c04_payload.sec_opcode = l_sop_cr04h[4*NK*WO +: NK*WO];
  assign rcu_lane_ops_c04_payload.operand = l_opd_cr04h[4*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c04_payload.merge_data = l_opd_cr04h[4*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c04_payload.section_en = l_sen_cr03h[4*NK +: NK];
  assign rcu_lane_ops_c04_payload.sec_owner = l_sown_cr04h[4*NK*2 +: NK*2];
  assign rcu_lane_ops_c04_payload.sec_pred_bit = p_spb_cr03h[4*NK +: NK];
  assign rcu_lane_ops_c04_payload.sec_pred_data = l_spd_cr04h[4*NK +: NK];
  assign rcu_lane_ops_c04_payload.sec_opnd_pos = l_sopos_cr04h[4*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c04_payload.sec_opnd_width = l_sowid_cr04h[4*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c04_payload.sec_dst_pos = l_sdpos_cr04h[4*NK*2 +: NK*2];
  assign rcu_lane_ops_c04_payload.sec_dst_width = l_sdwid_cr04h[4*NK*2 +: NK*2];
  assign rcu_lane_ops_c04_payload.operand_byp = l_sbyp_cr04h[4*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c04_credit = k_cr_cr01h[NS + 4];
  assign lane_rcu_res_c04_stall = 1'b0;
  assign rcu_lane_ops_c05_valid = l_v_cr03h[5];
  assign rcu_lane_ops_c05_wake = l_wk_cr02h[0];
  assign rcu_lane_ops_c05_payload.sec_opcode = l_sop_cr04h[5*NK*WO +: NK*WO];
  assign rcu_lane_ops_c05_payload.operand = l_opd_cr04h[5*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c05_payload.merge_data = l_opd_cr04h[5*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c05_payload.section_en = l_sen_cr03h[5*NK +: NK];
  assign rcu_lane_ops_c05_payload.sec_owner = l_sown_cr04h[5*NK*2 +: NK*2];
  assign rcu_lane_ops_c05_payload.sec_pred_bit = p_spb_cr03h[5*NK +: NK];
  assign rcu_lane_ops_c05_payload.sec_pred_data = l_spd_cr04h[5*NK +: NK];
  assign rcu_lane_ops_c05_payload.sec_opnd_pos = l_sopos_cr04h[5*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c05_payload.sec_opnd_width = l_sowid_cr04h[5*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c05_payload.sec_dst_pos = l_sdpos_cr04h[5*NK*2 +: NK*2];
  assign rcu_lane_ops_c05_payload.sec_dst_width = l_sdwid_cr04h[5*NK*2 +: NK*2];
  assign rcu_lane_ops_c05_payload.operand_byp = l_sbyp_cr04h[5*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c05_credit = k_cr_cr01h[NS + 5];
  assign lane_rcu_res_c05_stall = 1'b0;
  assign rcu_lane_ops_c06_valid = l_v_cr03h[6];
  assign rcu_lane_ops_c06_wake = l_wk_cr02h[0];
  assign rcu_lane_ops_c06_payload.sec_opcode = l_sop_cr04h[6*NK*WO +: NK*WO];
  assign rcu_lane_ops_c06_payload.operand = l_opd_cr04h[6*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c06_payload.merge_data = l_opd_cr04h[6*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c06_payload.section_en = l_sen_cr03h[6*NK +: NK];
  assign rcu_lane_ops_c06_payload.sec_owner = l_sown_cr04h[6*NK*2 +: NK*2];
  assign rcu_lane_ops_c06_payload.sec_pred_bit = p_spb_cr03h[6*NK +: NK];
  assign rcu_lane_ops_c06_payload.sec_pred_data = l_spd_cr04h[6*NK +: NK];
  assign rcu_lane_ops_c06_payload.sec_opnd_pos = l_sopos_cr04h[6*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c06_payload.sec_opnd_width = l_sowid_cr04h[6*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c06_payload.sec_dst_pos = l_sdpos_cr04h[6*NK*2 +: NK*2];
  assign rcu_lane_ops_c06_payload.sec_dst_width = l_sdwid_cr04h[6*NK*2 +: NK*2];
  assign rcu_lane_ops_c06_payload.operand_byp = l_sbyp_cr04h[6*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c06_credit = k_cr_cr01h[NS + 6];
  assign lane_rcu_res_c06_stall = 1'b0;
  assign rcu_lane_ops_c07_valid = l_v_cr03h[7];
  assign rcu_lane_ops_c07_wake = l_wk_cr02h[0];
  assign rcu_lane_ops_c07_payload.sec_opcode = l_sop_cr04h[7*NK*WO +: NK*WO];
  assign rcu_lane_ops_c07_payload.operand = l_opd_cr04h[7*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c07_payload.merge_data = l_opd_cr04h[7*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c07_payload.section_en = l_sen_cr03h[7*NK +: NK];
  assign rcu_lane_ops_c07_payload.sec_owner = l_sown_cr04h[7*NK*2 +: NK*2];
  assign rcu_lane_ops_c07_payload.sec_pred_bit = p_spb_cr03h[7*NK +: NK];
  assign rcu_lane_ops_c07_payload.sec_pred_data = l_spd_cr04h[7*NK +: NK];
  assign rcu_lane_ops_c07_payload.sec_opnd_pos = l_sopos_cr04h[7*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c07_payload.sec_opnd_width = l_sowid_cr04h[7*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c07_payload.sec_dst_pos = l_sdpos_cr04h[7*NK*2 +: NK*2];
  assign rcu_lane_ops_c07_payload.sec_dst_width = l_sdwid_cr04h[7*NK*2 +: NK*2];
  assign rcu_lane_ops_c07_payload.operand_byp = l_sbyp_cr04h[7*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c07_credit = k_cr_cr01h[NS + 7];
  assign lane_rcu_res_c07_stall = 1'b0;
  assign rcu_lane_ops_c08_valid = l_v_cr03h[8];
  assign rcu_lane_ops_c08_wake = l_wk_cr02h[1];
  assign rcu_lane_ops_c08_payload.sec_opcode = l_sop_cr04h[8*NK*WO +: NK*WO];
  assign rcu_lane_ops_c08_payload.operand = l_opd_cr04h[8*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c08_payload.merge_data = l_opd_cr04h[8*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c08_payload.section_en = l_sen_cr03h[8*NK +: NK];
  assign rcu_lane_ops_c08_payload.sec_owner = l_sown_cr04h[8*NK*2 +: NK*2];
  assign rcu_lane_ops_c08_payload.sec_pred_bit = p_spb_cr03h[8*NK +: NK];
  assign rcu_lane_ops_c08_payload.sec_pred_data = l_spd_cr04h[8*NK +: NK];
  assign rcu_lane_ops_c08_payload.sec_opnd_pos = l_sopos_cr04h[8*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c08_payload.sec_opnd_width = l_sowid_cr04h[8*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c08_payload.sec_dst_pos = l_sdpos_cr04h[8*NK*2 +: NK*2];
  assign rcu_lane_ops_c08_payload.sec_dst_width = l_sdwid_cr04h[8*NK*2 +: NK*2];
  assign rcu_lane_ops_c08_payload.operand_byp = l_sbyp_cr04h[8*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c08_credit = k_cr_cr01h[NS + 8];
  assign lane_rcu_res_c08_stall = 1'b0;
  assign rcu_lane_ops_c09_valid = l_v_cr03h[9];
  assign rcu_lane_ops_c09_wake = l_wk_cr02h[1];
  assign rcu_lane_ops_c09_payload.sec_opcode = l_sop_cr04h[9*NK*WO +: NK*WO];
  assign rcu_lane_ops_c09_payload.operand = l_opd_cr04h[9*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c09_payload.merge_data = l_opd_cr04h[9*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c09_payload.section_en = l_sen_cr03h[9*NK +: NK];
  assign rcu_lane_ops_c09_payload.sec_owner = l_sown_cr04h[9*NK*2 +: NK*2];
  assign rcu_lane_ops_c09_payload.sec_pred_bit = p_spb_cr03h[9*NK +: NK];
  assign rcu_lane_ops_c09_payload.sec_pred_data = l_spd_cr04h[9*NK +: NK];
  assign rcu_lane_ops_c09_payload.sec_opnd_pos = l_sopos_cr04h[9*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c09_payload.sec_opnd_width = l_sowid_cr04h[9*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c09_payload.sec_dst_pos = l_sdpos_cr04h[9*NK*2 +: NK*2];
  assign rcu_lane_ops_c09_payload.sec_dst_width = l_sdwid_cr04h[9*NK*2 +: NK*2];
  assign rcu_lane_ops_c09_payload.operand_byp = l_sbyp_cr04h[9*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c09_credit = k_cr_cr01h[NS + 9];
  assign lane_rcu_res_c09_stall = 1'b0;
  assign rcu_lane_ops_c10_valid = l_v_cr03h[10];
  assign rcu_lane_ops_c10_wake = l_wk_cr02h[1];
  assign rcu_lane_ops_c10_payload.sec_opcode = l_sop_cr04h[10*NK*WO +: NK*WO];
  assign rcu_lane_ops_c10_payload.operand = l_opd_cr04h[10*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c10_payload.merge_data = l_opd_cr04h[10*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c10_payload.section_en = l_sen_cr03h[10*NK +: NK];
  assign rcu_lane_ops_c10_payload.sec_owner = l_sown_cr04h[10*NK*2 +: NK*2];
  assign rcu_lane_ops_c10_payload.sec_pred_bit = p_spb_cr03h[10*NK +: NK];
  assign rcu_lane_ops_c10_payload.sec_pred_data = l_spd_cr04h[10*NK +: NK];
  assign rcu_lane_ops_c10_payload.sec_opnd_pos = l_sopos_cr04h[10*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c10_payload.sec_opnd_width = l_sowid_cr04h[10*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c10_payload.sec_dst_pos = l_sdpos_cr04h[10*NK*2 +: NK*2];
  assign rcu_lane_ops_c10_payload.sec_dst_width = l_sdwid_cr04h[10*NK*2 +: NK*2];
  assign rcu_lane_ops_c10_payload.operand_byp = l_sbyp_cr04h[10*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c10_credit = k_cr_cr01h[NS + 10];
  assign lane_rcu_res_c10_stall = 1'b0;
  assign rcu_lane_ops_c11_valid = l_v_cr03h[11];
  assign rcu_lane_ops_c11_wake = l_wk_cr02h[1];
  assign rcu_lane_ops_c11_payload.sec_opcode = l_sop_cr04h[11*NK*WO +: NK*WO];
  assign rcu_lane_ops_c11_payload.operand = l_opd_cr04h[11*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c11_payload.merge_data = l_opd_cr04h[11*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c11_payload.section_en = l_sen_cr03h[11*NK +: NK];
  assign rcu_lane_ops_c11_payload.sec_owner = l_sown_cr04h[11*NK*2 +: NK*2];
  assign rcu_lane_ops_c11_payload.sec_pred_bit = p_spb_cr03h[11*NK +: NK];
  assign rcu_lane_ops_c11_payload.sec_pred_data = l_spd_cr04h[11*NK +: NK];
  assign rcu_lane_ops_c11_payload.sec_opnd_pos = l_sopos_cr04h[11*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c11_payload.sec_opnd_width = l_sowid_cr04h[11*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c11_payload.sec_dst_pos = l_sdpos_cr04h[11*NK*2 +: NK*2];
  assign rcu_lane_ops_c11_payload.sec_dst_width = l_sdwid_cr04h[11*NK*2 +: NK*2];
  assign rcu_lane_ops_c11_payload.operand_byp = l_sbyp_cr04h[11*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c11_credit = k_cr_cr01h[NS + 11];
  assign lane_rcu_res_c11_stall = 1'b0;
  assign rcu_lane_ops_c12_valid = l_v_cr03h[12];
  assign rcu_lane_ops_c12_wake = l_wk_cr02h[1];
  assign rcu_lane_ops_c12_payload.sec_opcode = l_sop_cr04h[12*NK*WO +: NK*WO];
  assign rcu_lane_ops_c12_payload.operand = l_opd_cr04h[12*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c12_payload.merge_data = l_opd_cr04h[12*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c12_payload.section_en = l_sen_cr03h[12*NK +: NK];
  assign rcu_lane_ops_c12_payload.sec_owner = l_sown_cr04h[12*NK*2 +: NK*2];
  assign rcu_lane_ops_c12_payload.sec_pred_bit = p_spb_cr03h[12*NK +: NK];
  assign rcu_lane_ops_c12_payload.sec_pred_data = l_spd_cr04h[12*NK +: NK];
  assign rcu_lane_ops_c12_payload.sec_opnd_pos = l_sopos_cr04h[12*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c12_payload.sec_opnd_width = l_sowid_cr04h[12*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c12_payload.sec_dst_pos = l_sdpos_cr04h[12*NK*2 +: NK*2];
  assign rcu_lane_ops_c12_payload.sec_dst_width = l_sdwid_cr04h[12*NK*2 +: NK*2];
  assign rcu_lane_ops_c12_payload.operand_byp = l_sbyp_cr04h[12*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c12_credit = k_cr_cr01h[NS + 12];
  assign lane_rcu_res_c12_stall = 1'b0;
  assign rcu_lane_ops_c13_valid = l_v_cr03h[13];
  assign rcu_lane_ops_c13_wake = l_wk_cr02h[1];
  assign rcu_lane_ops_c13_payload.sec_opcode = l_sop_cr04h[13*NK*WO +: NK*WO];
  assign rcu_lane_ops_c13_payload.operand = l_opd_cr04h[13*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c13_payload.merge_data = l_opd_cr04h[13*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c13_payload.section_en = l_sen_cr03h[13*NK +: NK];
  assign rcu_lane_ops_c13_payload.sec_owner = l_sown_cr04h[13*NK*2 +: NK*2];
  assign rcu_lane_ops_c13_payload.sec_pred_bit = p_spb_cr03h[13*NK +: NK];
  assign rcu_lane_ops_c13_payload.sec_pred_data = l_spd_cr04h[13*NK +: NK];
  assign rcu_lane_ops_c13_payload.sec_opnd_pos = l_sopos_cr04h[13*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c13_payload.sec_opnd_width = l_sowid_cr04h[13*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c13_payload.sec_dst_pos = l_sdpos_cr04h[13*NK*2 +: NK*2];
  assign rcu_lane_ops_c13_payload.sec_dst_width = l_sdwid_cr04h[13*NK*2 +: NK*2];
  assign rcu_lane_ops_c13_payload.operand_byp = l_sbyp_cr04h[13*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c13_credit = k_cr_cr01h[NS + 13];
  assign lane_rcu_res_c13_stall = 1'b0;
  assign rcu_lane_ops_c14_valid = l_v_cr03h[14];
  assign rcu_lane_ops_c14_wake = l_wk_cr02h[1];
  assign rcu_lane_ops_c14_payload.sec_opcode = l_sop_cr04h[14*NK*WO +: NK*WO];
  assign rcu_lane_ops_c14_payload.operand = l_opd_cr04h[14*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c14_payload.merge_data = l_opd_cr04h[14*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c14_payload.section_en = l_sen_cr03h[14*NK +: NK];
  assign rcu_lane_ops_c14_payload.sec_owner = l_sown_cr04h[14*NK*2 +: NK*2];
  assign rcu_lane_ops_c14_payload.sec_pred_bit = p_spb_cr03h[14*NK +: NK];
  assign rcu_lane_ops_c14_payload.sec_pred_data = l_spd_cr04h[14*NK +: NK];
  assign rcu_lane_ops_c14_payload.sec_opnd_pos = l_sopos_cr04h[14*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c14_payload.sec_opnd_width = l_sowid_cr04h[14*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c14_payload.sec_dst_pos = l_sdpos_cr04h[14*NK*2 +: NK*2];
  assign rcu_lane_ops_c14_payload.sec_dst_width = l_sdwid_cr04h[14*NK*2 +: NK*2];
  assign rcu_lane_ops_c14_payload.operand_byp = l_sbyp_cr04h[14*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c14_credit = k_cr_cr01h[NS + 14];
  assign lane_rcu_res_c14_stall = 1'b0;
  assign rcu_lane_ops_c15_valid = l_v_cr03h[15];
  assign rcu_lane_ops_c15_wake = l_wk_cr02h[1];
  assign rcu_lane_ops_c15_payload.sec_opcode = l_sop_cr04h[15*NK*WO +: NK*WO];
  assign rcu_lane_ops_c15_payload.operand = l_opd_cr04h[15*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c15_payload.merge_data = l_opd_cr04h[15*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c15_payload.section_en = l_sen_cr03h[15*NK +: NK];
  assign rcu_lane_ops_c15_payload.sec_owner = l_sown_cr04h[15*NK*2 +: NK*2];
  assign rcu_lane_ops_c15_payload.sec_pred_bit = p_spb_cr03h[15*NK +: NK];
  assign rcu_lane_ops_c15_payload.sec_pred_data = l_spd_cr04h[15*NK +: NK];
  assign rcu_lane_ops_c15_payload.sec_opnd_pos = l_sopos_cr04h[15*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c15_payload.sec_opnd_width = l_sowid_cr04h[15*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c15_payload.sec_dst_pos = l_sdpos_cr04h[15*NK*2 +: NK*2];
  assign rcu_lane_ops_c15_payload.sec_dst_width = l_sdwid_cr04h[15*NK*2 +: NK*2];
  assign rcu_lane_ops_c15_payload.operand_byp = l_sbyp_cr04h[15*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c15_credit = k_cr_cr01h[NS + 15];
  assign lane_rcu_res_c15_stall = 1'b0;
  assign rcu_lane_ops_c16_valid = l_v_cr03h[16];
  assign rcu_lane_ops_c16_wake = l_wk_cr02h[2];
  assign rcu_lane_ops_c16_payload.sec_opcode = l_sop_cr04h[16*NK*WO +: NK*WO];
  assign rcu_lane_ops_c16_payload.operand = l_opd_cr04h[16*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c16_payload.merge_data = l_opd_cr04h[16*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c16_payload.section_en = l_sen_cr03h[16*NK +: NK];
  assign rcu_lane_ops_c16_payload.sec_owner = l_sown_cr04h[16*NK*2 +: NK*2];
  assign rcu_lane_ops_c16_payload.sec_pred_bit = p_spb_cr03h[16*NK +: NK];
  assign rcu_lane_ops_c16_payload.sec_pred_data = l_spd_cr04h[16*NK +: NK];
  assign rcu_lane_ops_c16_payload.sec_opnd_pos = l_sopos_cr04h[16*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c16_payload.sec_opnd_width = l_sowid_cr04h[16*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c16_payload.sec_dst_pos = l_sdpos_cr04h[16*NK*2 +: NK*2];
  assign rcu_lane_ops_c16_payload.sec_dst_width = l_sdwid_cr04h[16*NK*2 +: NK*2];
  assign rcu_lane_ops_c16_payload.operand_byp = l_sbyp_cr04h[16*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c16_credit = k_cr_cr01h[NS + 16];
  assign lane_rcu_res_c16_stall = 1'b0;
  assign rcu_lane_ops_c17_valid = l_v_cr03h[17];
  assign rcu_lane_ops_c17_wake = l_wk_cr02h[2];
  assign rcu_lane_ops_c17_payload.sec_opcode = l_sop_cr04h[17*NK*WO +: NK*WO];
  assign rcu_lane_ops_c17_payload.operand = l_opd_cr04h[17*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c17_payload.merge_data = l_opd_cr04h[17*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c17_payload.section_en = l_sen_cr03h[17*NK +: NK];
  assign rcu_lane_ops_c17_payload.sec_owner = l_sown_cr04h[17*NK*2 +: NK*2];
  assign rcu_lane_ops_c17_payload.sec_pred_bit = p_spb_cr03h[17*NK +: NK];
  assign rcu_lane_ops_c17_payload.sec_pred_data = l_spd_cr04h[17*NK +: NK];
  assign rcu_lane_ops_c17_payload.sec_opnd_pos = l_sopos_cr04h[17*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c17_payload.sec_opnd_width = l_sowid_cr04h[17*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c17_payload.sec_dst_pos = l_sdpos_cr04h[17*NK*2 +: NK*2];
  assign rcu_lane_ops_c17_payload.sec_dst_width = l_sdwid_cr04h[17*NK*2 +: NK*2];
  assign rcu_lane_ops_c17_payload.operand_byp = l_sbyp_cr04h[17*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c17_credit = k_cr_cr01h[NS + 17];
  assign lane_rcu_res_c17_stall = 1'b0;
  assign rcu_lane_ops_c18_valid = l_v_cr03h[18];
  assign rcu_lane_ops_c18_wake = l_wk_cr02h[2];
  assign rcu_lane_ops_c18_payload.sec_opcode = l_sop_cr04h[18*NK*WO +: NK*WO];
  assign rcu_lane_ops_c18_payload.operand = l_opd_cr04h[18*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c18_payload.merge_data = l_opd_cr04h[18*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c18_payload.section_en = l_sen_cr03h[18*NK +: NK];
  assign rcu_lane_ops_c18_payload.sec_owner = l_sown_cr04h[18*NK*2 +: NK*2];
  assign rcu_lane_ops_c18_payload.sec_pred_bit = p_spb_cr03h[18*NK +: NK];
  assign rcu_lane_ops_c18_payload.sec_pred_data = l_spd_cr04h[18*NK +: NK];
  assign rcu_lane_ops_c18_payload.sec_opnd_pos = l_sopos_cr04h[18*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c18_payload.sec_opnd_width = l_sowid_cr04h[18*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c18_payload.sec_dst_pos = l_sdpos_cr04h[18*NK*2 +: NK*2];
  assign rcu_lane_ops_c18_payload.sec_dst_width = l_sdwid_cr04h[18*NK*2 +: NK*2];
  assign rcu_lane_ops_c18_payload.operand_byp = l_sbyp_cr04h[18*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c18_credit = k_cr_cr01h[NS + 18];
  assign lane_rcu_res_c18_stall = 1'b0;
  assign rcu_lane_ops_c19_valid = l_v_cr03h[19];
  assign rcu_lane_ops_c19_wake = l_wk_cr02h[2];
  assign rcu_lane_ops_c19_payload.sec_opcode = l_sop_cr04h[19*NK*WO +: NK*WO];
  assign rcu_lane_ops_c19_payload.operand = l_opd_cr04h[19*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c19_payload.merge_data = l_opd_cr04h[19*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c19_payload.section_en = l_sen_cr03h[19*NK +: NK];
  assign rcu_lane_ops_c19_payload.sec_owner = l_sown_cr04h[19*NK*2 +: NK*2];
  assign rcu_lane_ops_c19_payload.sec_pred_bit = p_spb_cr03h[19*NK +: NK];
  assign rcu_lane_ops_c19_payload.sec_pred_data = l_spd_cr04h[19*NK +: NK];
  assign rcu_lane_ops_c19_payload.sec_opnd_pos = l_sopos_cr04h[19*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c19_payload.sec_opnd_width = l_sowid_cr04h[19*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c19_payload.sec_dst_pos = l_sdpos_cr04h[19*NK*2 +: NK*2];
  assign rcu_lane_ops_c19_payload.sec_dst_width = l_sdwid_cr04h[19*NK*2 +: NK*2];
  assign rcu_lane_ops_c19_payload.operand_byp = l_sbyp_cr04h[19*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c19_credit = k_cr_cr01h[NS + 19];
  assign lane_rcu_res_c19_stall = 1'b0;
  assign rcu_lane_ops_c20_valid = l_v_cr03h[20];
  assign rcu_lane_ops_c20_wake = l_wk_cr02h[2];
  assign rcu_lane_ops_c20_payload.sec_opcode = l_sop_cr04h[20*NK*WO +: NK*WO];
  assign rcu_lane_ops_c20_payload.operand = l_opd_cr04h[20*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c20_payload.merge_data = l_opd_cr04h[20*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c20_payload.section_en = l_sen_cr03h[20*NK +: NK];
  assign rcu_lane_ops_c20_payload.sec_owner = l_sown_cr04h[20*NK*2 +: NK*2];
  assign rcu_lane_ops_c20_payload.sec_pred_bit = p_spb_cr03h[20*NK +: NK];
  assign rcu_lane_ops_c20_payload.sec_pred_data = l_spd_cr04h[20*NK +: NK];
  assign rcu_lane_ops_c20_payload.sec_opnd_pos = l_sopos_cr04h[20*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c20_payload.sec_opnd_width = l_sowid_cr04h[20*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c20_payload.sec_dst_pos = l_sdpos_cr04h[20*NK*2 +: NK*2];
  assign rcu_lane_ops_c20_payload.sec_dst_width = l_sdwid_cr04h[20*NK*2 +: NK*2];
  assign rcu_lane_ops_c20_payload.operand_byp = l_sbyp_cr04h[20*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c20_credit = k_cr_cr01h[NS + 20];
  assign lane_rcu_res_c20_stall = 1'b0;
  assign rcu_lane_ops_c21_valid = l_v_cr03h[21];
  assign rcu_lane_ops_c21_wake = l_wk_cr02h[2];
  assign rcu_lane_ops_c21_payload.sec_opcode = l_sop_cr04h[21*NK*WO +: NK*WO];
  assign rcu_lane_ops_c21_payload.operand = l_opd_cr04h[21*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c21_payload.merge_data = l_opd_cr04h[21*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c21_payload.section_en = l_sen_cr03h[21*NK +: NK];
  assign rcu_lane_ops_c21_payload.sec_owner = l_sown_cr04h[21*NK*2 +: NK*2];
  assign rcu_lane_ops_c21_payload.sec_pred_bit = p_spb_cr03h[21*NK +: NK];
  assign rcu_lane_ops_c21_payload.sec_pred_data = l_spd_cr04h[21*NK +: NK];
  assign rcu_lane_ops_c21_payload.sec_opnd_pos = l_sopos_cr04h[21*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c21_payload.sec_opnd_width = l_sowid_cr04h[21*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c21_payload.sec_dst_pos = l_sdpos_cr04h[21*NK*2 +: NK*2];
  assign rcu_lane_ops_c21_payload.sec_dst_width = l_sdwid_cr04h[21*NK*2 +: NK*2];
  assign rcu_lane_ops_c21_payload.operand_byp = l_sbyp_cr04h[21*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c21_credit = k_cr_cr01h[NS + 21];
  assign lane_rcu_res_c21_stall = 1'b0;
  assign rcu_lane_ops_c22_valid = l_v_cr03h[22];
  assign rcu_lane_ops_c22_wake = l_wk_cr02h[2];
  assign rcu_lane_ops_c22_payload.sec_opcode = l_sop_cr04h[22*NK*WO +: NK*WO];
  assign rcu_lane_ops_c22_payload.operand = l_opd_cr04h[22*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c22_payload.merge_data = l_opd_cr04h[22*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c22_payload.section_en = l_sen_cr03h[22*NK +: NK];
  assign rcu_lane_ops_c22_payload.sec_owner = l_sown_cr04h[22*NK*2 +: NK*2];
  assign rcu_lane_ops_c22_payload.sec_pred_bit = p_spb_cr03h[22*NK +: NK];
  assign rcu_lane_ops_c22_payload.sec_pred_data = l_spd_cr04h[22*NK +: NK];
  assign rcu_lane_ops_c22_payload.sec_opnd_pos = l_sopos_cr04h[22*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c22_payload.sec_opnd_width = l_sowid_cr04h[22*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c22_payload.sec_dst_pos = l_sdpos_cr04h[22*NK*2 +: NK*2];
  assign rcu_lane_ops_c22_payload.sec_dst_width = l_sdwid_cr04h[22*NK*2 +: NK*2];
  assign rcu_lane_ops_c22_payload.operand_byp = l_sbyp_cr04h[22*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c22_credit = k_cr_cr01h[NS + 22];
  assign lane_rcu_res_c22_stall = 1'b0;
  assign rcu_lane_ops_c23_valid = l_v_cr03h[23];
  assign rcu_lane_ops_c23_wake = l_wk_cr02h[2];
  assign rcu_lane_ops_c23_payload.sec_opcode = l_sop_cr04h[23*NK*WO +: NK*WO];
  assign rcu_lane_ops_c23_payload.operand = l_opd_cr04h[23*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c23_payload.merge_data = l_opd_cr04h[23*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c23_payload.section_en = l_sen_cr03h[23*NK +: NK];
  assign rcu_lane_ops_c23_payload.sec_owner = l_sown_cr04h[23*NK*2 +: NK*2];
  assign rcu_lane_ops_c23_payload.sec_pred_bit = p_spb_cr03h[23*NK +: NK];
  assign rcu_lane_ops_c23_payload.sec_pred_data = l_spd_cr04h[23*NK +: NK];
  assign rcu_lane_ops_c23_payload.sec_opnd_pos = l_sopos_cr04h[23*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c23_payload.sec_opnd_width = l_sowid_cr04h[23*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c23_payload.sec_dst_pos = l_sdpos_cr04h[23*NK*2 +: NK*2];
  assign rcu_lane_ops_c23_payload.sec_dst_width = l_sdwid_cr04h[23*NK*2 +: NK*2];
  assign rcu_lane_ops_c23_payload.operand_byp = l_sbyp_cr04h[23*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c23_credit = k_cr_cr01h[NS + 23];
  assign lane_rcu_res_c23_stall = 1'b0;
  assign rcu_lane_ops_c24_valid = l_v_cr03h[24];
  assign rcu_lane_ops_c24_wake = l_wk_cr02h[3];
  assign rcu_lane_ops_c24_payload.sec_opcode = l_sop_cr04h[24*NK*WO +: NK*WO];
  assign rcu_lane_ops_c24_payload.operand = l_opd_cr04h[24*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c24_payload.merge_data = l_opd_cr04h[24*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c24_payload.section_en = l_sen_cr03h[24*NK +: NK];
  assign rcu_lane_ops_c24_payload.sec_owner = l_sown_cr04h[24*NK*2 +: NK*2];
  assign rcu_lane_ops_c24_payload.sec_pred_bit = p_spb_cr03h[24*NK +: NK];
  assign rcu_lane_ops_c24_payload.sec_pred_data = l_spd_cr04h[24*NK +: NK];
  assign rcu_lane_ops_c24_payload.sec_opnd_pos = l_sopos_cr04h[24*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c24_payload.sec_opnd_width = l_sowid_cr04h[24*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c24_payload.sec_dst_pos = l_sdpos_cr04h[24*NK*2 +: NK*2];
  assign rcu_lane_ops_c24_payload.sec_dst_width = l_sdwid_cr04h[24*NK*2 +: NK*2];
  assign rcu_lane_ops_c24_payload.operand_byp = l_sbyp_cr04h[24*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c24_credit = k_cr_cr01h[NS + 24];
  assign lane_rcu_res_c24_stall = 1'b0;
  assign rcu_lane_ops_c25_valid = l_v_cr03h[25];
  assign rcu_lane_ops_c25_wake = l_wk_cr02h[3];
  assign rcu_lane_ops_c25_payload.sec_opcode = l_sop_cr04h[25*NK*WO +: NK*WO];
  assign rcu_lane_ops_c25_payload.operand = l_opd_cr04h[25*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c25_payload.merge_data = l_opd_cr04h[25*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c25_payload.section_en = l_sen_cr03h[25*NK +: NK];
  assign rcu_lane_ops_c25_payload.sec_owner = l_sown_cr04h[25*NK*2 +: NK*2];
  assign rcu_lane_ops_c25_payload.sec_pred_bit = p_spb_cr03h[25*NK +: NK];
  assign rcu_lane_ops_c25_payload.sec_pred_data = l_spd_cr04h[25*NK +: NK];
  assign rcu_lane_ops_c25_payload.sec_opnd_pos = l_sopos_cr04h[25*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c25_payload.sec_opnd_width = l_sowid_cr04h[25*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c25_payload.sec_dst_pos = l_sdpos_cr04h[25*NK*2 +: NK*2];
  assign rcu_lane_ops_c25_payload.sec_dst_width = l_sdwid_cr04h[25*NK*2 +: NK*2];
  assign rcu_lane_ops_c25_payload.operand_byp = l_sbyp_cr04h[25*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c25_credit = k_cr_cr01h[NS + 25];
  assign lane_rcu_res_c25_stall = 1'b0;
  assign rcu_lane_ops_c26_valid = l_v_cr03h[26];
  assign rcu_lane_ops_c26_wake = l_wk_cr02h[3];
  assign rcu_lane_ops_c26_payload.sec_opcode = l_sop_cr04h[26*NK*WO +: NK*WO];
  assign rcu_lane_ops_c26_payload.operand = l_opd_cr04h[26*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c26_payload.merge_data = l_opd_cr04h[26*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c26_payload.section_en = l_sen_cr03h[26*NK +: NK];
  assign rcu_lane_ops_c26_payload.sec_owner = l_sown_cr04h[26*NK*2 +: NK*2];
  assign rcu_lane_ops_c26_payload.sec_pred_bit = p_spb_cr03h[26*NK +: NK];
  assign rcu_lane_ops_c26_payload.sec_pred_data = l_spd_cr04h[26*NK +: NK];
  assign rcu_lane_ops_c26_payload.sec_opnd_pos = l_sopos_cr04h[26*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c26_payload.sec_opnd_width = l_sowid_cr04h[26*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c26_payload.sec_dst_pos = l_sdpos_cr04h[26*NK*2 +: NK*2];
  assign rcu_lane_ops_c26_payload.sec_dst_width = l_sdwid_cr04h[26*NK*2 +: NK*2];
  assign rcu_lane_ops_c26_payload.operand_byp = l_sbyp_cr04h[26*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c26_credit = k_cr_cr01h[NS + 26];
  assign lane_rcu_res_c26_stall = 1'b0;
  assign rcu_lane_ops_c27_valid = l_v_cr03h[27];
  assign rcu_lane_ops_c27_wake = l_wk_cr02h[3];
  assign rcu_lane_ops_c27_payload.sec_opcode = l_sop_cr04h[27*NK*WO +: NK*WO];
  assign rcu_lane_ops_c27_payload.operand = l_opd_cr04h[27*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c27_payload.merge_data = l_opd_cr04h[27*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c27_payload.section_en = l_sen_cr03h[27*NK +: NK];
  assign rcu_lane_ops_c27_payload.sec_owner = l_sown_cr04h[27*NK*2 +: NK*2];
  assign rcu_lane_ops_c27_payload.sec_pred_bit = p_spb_cr03h[27*NK +: NK];
  assign rcu_lane_ops_c27_payload.sec_pred_data = l_spd_cr04h[27*NK +: NK];
  assign rcu_lane_ops_c27_payload.sec_opnd_pos = l_sopos_cr04h[27*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c27_payload.sec_opnd_width = l_sowid_cr04h[27*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c27_payload.sec_dst_pos = l_sdpos_cr04h[27*NK*2 +: NK*2];
  assign rcu_lane_ops_c27_payload.sec_dst_width = l_sdwid_cr04h[27*NK*2 +: NK*2];
  assign rcu_lane_ops_c27_payload.operand_byp = l_sbyp_cr04h[27*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c27_credit = k_cr_cr01h[NS + 27];
  assign lane_rcu_res_c27_stall = 1'b0;
  assign rcu_lane_ops_c28_valid = l_v_cr03h[28];
  assign rcu_lane_ops_c28_wake = l_wk_cr02h[3];
  assign rcu_lane_ops_c28_payload.sec_opcode = l_sop_cr04h[28*NK*WO +: NK*WO];
  assign rcu_lane_ops_c28_payload.operand = l_opd_cr04h[28*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c28_payload.merge_data = l_opd_cr04h[28*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c28_payload.section_en = l_sen_cr03h[28*NK +: NK];
  assign rcu_lane_ops_c28_payload.sec_owner = l_sown_cr04h[28*NK*2 +: NK*2];
  assign rcu_lane_ops_c28_payload.sec_pred_bit = p_spb_cr03h[28*NK +: NK];
  assign rcu_lane_ops_c28_payload.sec_pred_data = l_spd_cr04h[28*NK +: NK];
  assign rcu_lane_ops_c28_payload.sec_opnd_pos = l_sopos_cr04h[28*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c28_payload.sec_opnd_width = l_sowid_cr04h[28*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c28_payload.sec_dst_pos = l_sdpos_cr04h[28*NK*2 +: NK*2];
  assign rcu_lane_ops_c28_payload.sec_dst_width = l_sdwid_cr04h[28*NK*2 +: NK*2];
  assign rcu_lane_ops_c28_payload.operand_byp = l_sbyp_cr04h[28*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c28_credit = k_cr_cr01h[NS + 28];
  assign lane_rcu_res_c28_stall = 1'b0;
  assign rcu_lane_ops_c29_valid = l_v_cr03h[29];
  assign rcu_lane_ops_c29_wake = l_wk_cr02h[3];
  assign rcu_lane_ops_c29_payload.sec_opcode = l_sop_cr04h[29*NK*WO +: NK*WO];
  assign rcu_lane_ops_c29_payload.operand = l_opd_cr04h[29*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c29_payload.merge_data = l_opd_cr04h[29*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c29_payload.section_en = l_sen_cr03h[29*NK +: NK];
  assign rcu_lane_ops_c29_payload.sec_owner = l_sown_cr04h[29*NK*2 +: NK*2];
  assign rcu_lane_ops_c29_payload.sec_pred_bit = p_spb_cr03h[29*NK +: NK];
  assign rcu_lane_ops_c29_payload.sec_pred_data = l_spd_cr04h[29*NK +: NK];
  assign rcu_lane_ops_c29_payload.sec_opnd_pos = l_sopos_cr04h[29*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c29_payload.sec_opnd_width = l_sowid_cr04h[29*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c29_payload.sec_dst_pos = l_sdpos_cr04h[29*NK*2 +: NK*2];
  assign rcu_lane_ops_c29_payload.sec_dst_width = l_sdwid_cr04h[29*NK*2 +: NK*2];
  assign rcu_lane_ops_c29_payload.operand_byp = l_sbyp_cr04h[29*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c29_credit = k_cr_cr01h[NS + 29];
  assign lane_rcu_res_c29_stall = 1'b0;
  assign rcu_lane_ops_c30_valid = l_v_cr03h[30];
  assign rcu_lane_ops_c30_wake = l_wk_cr02h[3];
  assign rcu_lane_ops_c30_payload.sec_opcode = l_sop_cr04h[30*NK*WO +: NK*WO];
  assign rcu_lane_ops_c30_payload.operand = l_opd_cr04h[30*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c30_payload.merge_data = l_opd_cr04h[30*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c30_payload.section_en = l_sen_cr03h[30*NK +: NK];
  assign rcu_lane_ops_c30_payload.sec_owner = l_sown_cr04h[30*NK*2 +: NK*2];
  assign rcu_lane_ops_c30_payload.sec_pred_bit = p_spb_cr03h[30*NK +: NK];
  assign rcu_lane_ops_c30_payload.sec_pred_data = l_spd_cr04h[30*NK +: NK];
  assign rcu_lane_ops_c30_payload.sec_opnd_pos = l_sopos_cr04h[30*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c30_payload.sec_opnd_width = l_sowid_cr04h[30*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c30_payload.sec_dst_pos = l_sdpos_cr04h[30*NK*2 +: NK*2];
  assign rcu_lane_ops_c30_payload.sec_dst_width = l_sdwid_cr04h[30*NK*2 +: NK*2];
  assign rcu_lane_ops_c30_payload.operand_byp = l_sbyp_cr04h[30*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c30_credit = k_cr_cr01h[NS + 30];
  assign lane_rcu_res_c30_stall = 1'b0;
  assign rcu_lane_ops_c31_valid = l_v_cr03h[31];
  assign rcu_lane_ops_c31_wake = l_wk_cr02h[3];
  assign rcu_lane_ops_c31_payload.sec_opcode = l_sop_cr04h[31*NK*WO +: NK*WO];
  assign rcu_lane_ops_c31_payload.operand = l_opd_cr04h[31*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c31_payload.merge_data = l_opd_cr04h[31*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c31_payload.section_en = l_sen_cr03h[31*NK +: NK];
  assign rcu_lane_ops_c31_payload.sec_owner = l_sown_cr04h[31*NK*2 +: NK*2];
  assign rcu_lane_ops_c31_payload.sec_pred_bit = p_spb_cr03h[31*NK +: NK];
  assign rcu_lane_ops_c31_payload.sec_pred_data = l_spd_cr04h[31*NK +: NK];
  assign rcu_lane_ops_c31_payload.sec_opnd_pos = l_sopos_cr04h[31*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c31_payload.sec_opnd_width = l_sowid_cr04h[31*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c31_payload.sec_dst_pos = l_sdpos_cr04h[31*NK*2 +: NK*2];
  assign rcu_lane_ops_c31_payload.sec_dst_width = l_sdwid_cr04h[31*NK*2 +: NK*2];
  assign rcu_lane_ops_c31_payload.operand_byp = l_sbyp_cr04h[31*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c31_credit = k_cr_cr01h[NS + 31];
  assign lane_rcu_res_c31_stall = 1'b0;
  assign rcu_ooe_done_s0_valid = l_dnv_cr08h[0];
  assign rcu_ooe_done_s0_payload.rob_tag = l_dntag_cr09h[0*WT +: WT];
  assign rcu_ooe_done_s0_payload.done_row = l_dnrow_cr09h[0*2 +: 2];
  assign rcu_ooe_done_s0_payload.branch_taken = 1'b0;
  assign rcu_ooe_done_s0_payload.branch_mask = '0;
  assign rcu_ooe_done_s0_payload.aux = '0;
  assign rcu_ooe_done_s0_payload.lead_br_taken = 1'b0;
  assign rcu_ooe_done_s0_payload.lead_br_mask = '0;
  assign rcu_ooe_done_s1_valid = l_dnv_cr08h[1];
  assign rcu_ooe_done_s1_payload.rob_tag = l_dntag_cr09h[1*WT +: WT];
  assign rcu_ooe_done_s1_payload.done_row = l_dnrow_cr09h[1*2 +: 2];
  assign rcu_ooe_done_s1_payload.branch_taken = 1'b0;
  assign rcu_ooe_done_s1_payload.branch_mask = '0;
  assign rcu_ooe_done_s1_payload.aux = '0;
  assign rcu_ooe_done_s1_payload.lead_br_taken = 1'b0;
  assign rcu_ooe_done_s1_payload.lead_br_mask = '0;
  assign rcu_ooe_done_s2_valid = l_dnv_cr08h[2];
  assign rcu_ooe_done_s2_payload.rob_tag = l_dntag_cr09h[2*WT +: WT];
  assign rcu_ooe_done_s2_payload.done_row = l_dnrow_cr09h[2*2 +: 2];
  assign rcu_ooe_done_s2_payload.branch_taken = 1'b0;
  assign rcu_ooe_done_s2_payload.branch_mask = '0;
  assign rcu_ooe_done_s2_payload.aux = '0;
  assign rcu_ooe_done_s2_payload.lead_br_taken = 1'b0;
  assign rcu_ooe_done_s2_payload.lead_br_mask = '0;
  assign rcu_ooe_done_s3_valid = l_dnv_cr08h[3];
  assign rcu_ooe_done_s3_payload.rob_tag = l_dntag_cr09h[3*WT +: WT];
  assign rcu_ooe_done_s3_payload.done_row = l_dnrow_cr09h[3*2 +: 2];
  assign rcu_ooe_done_s3_payload.branch_taken = 1'b0;
  assign rcu_ooe_done_s3_payload.branch_mask = '0;
  assign rcu_ooe_done_s3_payload.aux = '0;
  assign rcu_ooe_done_s3_payload.lead_br_taken = 1'b0;
  assign rcu_ooe_done_s3_payload.lead_br_mask = '0;
  assign rcu_ooe_done_s4_valid = l_sdv_cr13h;
  assign rcu_ooe_done_s4_payload.rob_tag = l_sdtag_cr14h;
  assign rcu_ooe_done_s4_payload.done_row = l_sdrow_cr14h;
  assign rcu_ooe_done_s4_payload.branch_taken = 1'b0;
  assign rcu_ooe_done_s4_payload.branch_mask = '0;
  assign rcu_ooe_done_s4_payload.aux = '0;
  assign rcu_ooe_done_s4_payload.lead_br_taken = 1'b0;
  assign rcu_ooe_done_s4_payload.lead_br_mask = '0;
  assign rcu_ooe_done_s5_valid = r_dnv_cr03h[0];
  assign rcu_ooe_done_s5_payload.rob_tag = r_dntag_cr04h;
  assign rcu_ooe_done_s5_payload.done_row = r_dnrow_cr04h;
  assign rcu_ooe_done_s5_payload.branch_taken = r_dnbt_cr04h;
  assign rcu_ooe_done_s5_payload.branch_mask = r_dnbm_cr04h;
  assign rcu_ooe_done_s5_payload.aux = r_dnaux_cr04h;
  assign rcu_ooe_done_s5_payload.lead_br_taken = p_lbt_cr03h;
  assign rcu_ooe_done_s5_payload.lead_br_mask = p_lbm_cr03h;
  assign rcu_ooe_done_s6_valid = r_dnv_cr03h[1];
  assign rcu_ooe_done_s6_payload.rob_tag = r_dntag_cr04h;
  assign rcu_ooe_done_s6_payload.done_row = r_dnrow_cr04h;
  assign rcu_ooe_done_s6_payload.branch_taken = 1'b0;
  assign rcu_ooe_done_s6_payload.branch_mask = '0;
  assign rcu_ooe_done_s6_payload.aux = '0;
  assign rcu_ooe_done_s6_payload.lead_br_taken = 1'b0;
  assign rcu_ooe_done_s6_payload.lead_br_mask = '0;
  assign rcu_miu_addr_s0_valid = m_v_cr03h[0];
  assign rcu_miu_addr_s0_payload.rob_tag = m_tag_cr04h[0*WT +: WT];
  assign rcu_miu_addr_s0_payload.active_mask = m_am_cr04h[0*N +: N];
  assign rcu_miu_addr_s0_payload.base_per_lane = m_base_cr04h[0*N*32 +: N*32];
  assign rcu_miu_addr_s0_payload.index_per_lane = m_idx_cr04h[0*N*32 +: N*32];
  assign rcu_miu_addr_s0_payload.store_data = m_sd_cr04h[0*N*32 +: N*32];
  assign miu_rcu_data_s0_stall = 1'b0;
  assign rcu_miu_addr_s1_valid = m_v_cr03h[1];
  assign rcu_miu_addr_s1_payload.rob_tag = m_tag_cr04h[1*WT +: WT];
  assign rcu_miu_addr_s1_payload.active_mask = m_am_cr04h[1*N +: N];
  assign rcu_miu_addr_s1_payload.base_per_lane = m_base_cr04h[1*N*32 +: N*32];
  assign rcu_miu_addr_s1_payload.index_per_lane = m_idx_cr04h[1*N*32 +: N*32];
  assign rcu_miu_addr_s1_payload.store_data = m_sd_cr04h[1*N*32 +: N*32];
  assign miu_rcu_data_s1_stall = 1'b0;
  assign rcu_miu_addr_s2_valid = m_v_cr03h[2];
  assign rcu_miu_addr_s2_payload.rob_tag = m_tag_cr04h[2*WT +: WT];
  assign rcu_miu_addr_s2_payload.active_mask = m_am_cr04h[2*N +: N];
  assign rcu_miu_addr_s2_payload.base_per_lane = m_base_cr04h[2*N*32 +: N*32];
  assign rcu_miu_addr_s2_payload.index_per_lane = m_idx_cr04h[2*N*32 +: N*32];
  assign rcu_miu_addr_s2_payload.store_data = m_sd_cr04h[2*N*32 +: N*32];
  assign miu_rcu_data_s2_stall = 1'b0;
  assign rcu_miu_addr_s3_valid = m_v_cr03h[3];
  assign rcu_miu_addr_s3_payload.rob_tag = m_tag_cr04h[3*WT +: WT];
  assign rcu_miu_addr_s3_payload.active_mask = m_am_cr04h[3*N +: N];
  assign rcu_miu_addr_s3_payload.base_per_lane = m_base_cr04h[3*N*32 +: N*32];
  assign rcu_miu_addr_s3_payload.index_per_lane = m_idx_cr04h[3*N*32 +: N*32];
  assign rcu_miu_addr_s3_payload.store_data = m_sd_cr04h[3*N*32 +: N*32];
  assign miu_rcu_data_s3_stall = 1'b0;
`ifdef CCV_TRACE
  assign rcu_lane_ops_c00_tid = '0;
  assign rcu_lane_ops_c01_tid = '0;
  assign rcu_lane_ops_c02_tid = '0;
  assign rcu_lane_ops_c03_tid = '0;
  assign rcu_lane_ops_c04_tid = '0;
  assign rcu_lane_ops_c05_tid = '0;
  assign rcu_lane_ops_c06_tid = '0;
  assign rcu_lane_ops_c07_tid = '0;
  assign rcu_lane_ops_c08_tid = '0;
  assign rcu_lane_ops_c09_tid = '0;
  assign rcu_lane_ops_c10_tid = '0;
  assign rcu_lane_ops_c11_tid = '0;
  assign rcu_lane_ops_c12_tid = '0;
  assign rcu_lane_ops_c13_tid = '0;
  assign rcu_lane_ops_c14_tid = '0;
  assign rcu_lane_ops_c15_tid = '0;
  assign rcu_lane_ops_c16_tid = '0;
  assign rcu_lane_ops_c17_tid = '0;
  assign rcu_lane_ops_c18_tid = '0;
  assign rcu_lane_ops_c19_tid = '0;
  assign rcu_lane_ops_c20_tid = '0;
  assign rcu_lane_ops_c21_tid = '0;
  assign rcu_lane_ops_c22_tid = '0;
  assign rcu_lane_ops_c23_tid = '0;
  assign rcu_lane_ops_c24_tid = '0;
  assign rcu_lane_ops_c25_tid = '0;
  assign rcu_lane_ops_c26_tid = '0;
  assign rcu_lane_ops_c27_tid = '0;
  assign rcu_lane_ops_c28_tid = '0;
  assign rcu_lane_ops_c29_tid = '0;
  assign rcu_lane_ops_c30_tid = '0;
  assign rcu_lane_ops_c31_tid = '0;
  assign rcu_ooe_done_s0_tid = '0;
  assign rcu_ooe_done_s1_tid = '0;
  assign rcu_ooe_done_s2_tid = '0;
  assign rcu_ooe_done_s3_tid = '0;
  assign rcu_ooe_done_s4_tid = '0;
  assign rcu_ooe_done_s5_tid = '0;
  assign rcu_ooe_done_s6_tid = '0;
  assign rcu_miu_addr_s0_tid = '0;
  assign rcu_miu_addr_s1_tid = '0;
  assign rcu_miu_addr_s2_tid = '0;
  assign rcu_miu_addr_s3_tid = '0;
  assign rcu_pca_mig_tid = '0;
`endif
endmodule
