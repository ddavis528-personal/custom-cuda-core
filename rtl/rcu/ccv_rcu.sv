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
// whose gclk clocks them all. Every module flops rst_n itself (RST-1).
//
// Ties, each for a reason:
//   - every _stall output 0: RCU never stalls an inbound channel;
//   - done slots 0-4 and 6: branch_taken, branch_mask, aux and the lead
//     branch fields 0 (the Done tab: only slot 5, R's, carries a branch);
//   - SW's data 0: the SFU's second result is not on lane_rcu_res yet
//     (RA-3; the model does not model it either);
//   - rcu_kill's CSR request marker 0 until Q-59 defines one; its sixth
//     busy term 0 (five modules have one);
//   - the predicate file's unused merge fields (PL, PR, PG lanes all ones;
//     PC takes none of the new value; PG merges nothing);
//   - the gate's stalled 0 and override 0: the block's idle (rcu_kill)
//     closes it.
// Trace ids (CCV_TRACE) are not carried: every _tid output is 0.
// TODO (RA-41, AR rev 322): the credits of ooe_rcu_issue (k_cr[8:0]) and
// miu_rcu_data (k_cr[44:41]) come from rcu_kill's credit flops until TI's
// credit-on-receipt mode lands in the wrapper; then those ports and flops go,
// and RCU keeps its promise to take every landed message the cycle it lands.
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
  localparam int OW = rcu_dec_pkg::OPC_W;
  localparam int NM = ccv_params_pkg::CCV_MIU_PIPES;          // MIU slots, 4
  localparam int NWAKE = 1 + N + 1 + 1 + 1 + 1 + 1;          // issue, lane_res, MIU, map, rau, pca, kill

  // ---- The block's clock gate -------------------------------------------
  logic gclk, cg_gated, idle;
  logic [NWAKE-1:0] wake;
  localparam int CG_HW = ccv_prov_pkg::CCV_CG_HYST_W;
  ccv_common_clk #(.NWAKE(NWAKE)) u_cg (
    .clk         (core_clk),
    .rst_n       (rst_n),
    .quiesced    (idle),
    .stalled     (1'b0),
    .hyst_quiesce(CG_HW'(ccv_prov_pkg::CCV_CG_HYST_QUIESCE)),
    .hyst_stall  (CG_HW'(ccv_prov_pkg::CCV_CG_HYST_STALL)),
    .wake        (wake),
    .cg_override (1'b0),
    .te          (1'b0),
    .gclk        (gclk),
    .gated       (cg_gated)
  );
`ifdef CCV_CHECK
  assign clk_gated = cg_gated;
`endif

  // ---- The issue channel's fields, flat (S slots 0-3, P 4-7, R 8) ---------
  logic [NS-1:0] i_iv;
  logic [NS-1:0] i_cont;
  logic [NS*4-1:0] i_foot;
  logic [NS*OW-1:0] i_opc;
  logic [NS*2-1:0] i_drw;
  logic [NS*WT-1:0] i_tag;
  logic [NS*N-1:0] i_im;
  logic [NS*WP-1:0] i_gd;
  logic [NS-1:0] i_ng;
  logic [NS*WP-1:0] i_pd;
  logic [NS*WP-1:0] i_pod;
  logic [NS-1:0] i_pwe;
  logic [NS-1:0] i_mrg;
  logic [NS*WR-1:0] i_dst;
  logic [NS*WR-1:0] i_odst;
  logic [NS*32-1:0] i_imm;
  logic [NS*6-1:0] i_spos;
  logic [NS*6-1:0] i_swid;
  logic [NS*2-1:0] i_dpos;
  logic [NS*2-1:0] i_dwid;
  logic [NS*2-1:0] i_opos;
  logic [NS*4-1:0] i_lsec;
  logic [NS*3-1:0] i_lsrc;
  logic [NS-1:0] i_limm;
  logic [NS-1:0] i_lmrg;
  logic [NS-1:0] i_lgu;
  logic [NS*WP-1:0] i_lgp;
  logic [NS*3*WR-1:0] i_src;   // source i's row at (s*3 + i)*WR: phys_src[15:8], [7:0], phys_src2
  assign i_iv[0] = ooe_rcu_issue_s0_valid;
  assign i_cont[0] = ooe_rcu_issue_s0_payload.cont;
  assign i_foot[0*4 +: 4] = ooe_rcu_issue_s0_payload.footprint;
  assign i_opc[0*OW +: OW] = ooe_rcu_issue_s0_payload.opcode;
  assign i_drw[0*2 +: 2] = ooe_rcu_issue_s0_payload.done_row;
  assign i_tag[0*WT +: WT] = ooe_rcu_issue_s0_payload.rob_tag;
  assign i_im[0*N +: N] = ooe_rcu_issue_s0_payload.issue_mask;
  assign i_gd[0*WP +: WP] = ooe_rcu_issue_s0_payload.phys_pred_guard;
  assign i_ng[0] = ooe_rcu_issue_s0_payload.pred_neg;
  assign i_pd[0*WP +: WP] = ooe_rcu_issue_s0_payload.phys_pred_dst;
  assign i_pod[0*WP +: WP] = ooe_rcu_issue_s0_payload.phys_pred_old_dst;
  assign i_pwe[0] = ooe_rcu_issue_s0_payload.pred_we;
  assign i_mrg[0] = ooe_rcu_issue_s0_payload.merge_en;
  assign i_dst[0*WR +: WR] = ooe_rcu_issue_s0_payload.phys_dst;
  assign i_odst[0*WR +: WR] = ooe_rcu_issue_s0_payload.phys_old_dst;
  assign i_imm[0*32 +: 32] = ooe_rcu_issue_s0_payload.imm;
  assign i_spos[0*6 +: 6] = ooe_rcu_issue_s0_payload.src_pos;
  assign i_swid[0*6 +: 6] = ooe_rcu_issue_s0_payload.src_width;
  assign i_dpos[0*2 +: 2] = ooe_rcu_issue_s0_payload.dst_pos;
  assign i_dwid[0*2 +: 2] = ooe_rcu_issue_s0_payload.dst_width;
  assign i_opos[0*2 +: 2] = ooe_rcu_issue_s0_payload.old_dst_pos;
  assign i_lsec[0*4 +: 4] = ooe_rcu_issue_s0_payload.lead_sec_mask;
  assign i_lsrc[0*3 +: 3] = ooe_rcu_issue_s0_payload.lead_src_used;
  assign i_limm[0] = ooe_rcu_issue_s0_payload.lead_imm_used;
  assign i_lmrg[0] = ooe_rcu_issue_s0_payload.lead_merge_used;
  assign i_lgu[0] = ooe_rcu_issue_s0_payload.lead_guard_used;
  assign i_lgp[0*WP +: WP] = ooe_rcu_issue_s0_payload.lead_guard_pred;
  assign i_src[(0*3 + 0)*WR +: WR] = ooe_rcu_issue_s0_payload.phys_src[2*WR-1:WR];
  assign i_src[(0*3 + 1)*WR +: WR] = ooe_rcu_issue_s0_payload.phys_src[WR-1:0];
  assign i_src[(0*3 + 2)*WR +: WR] = ooe_rcu_issue_s0_payload.phys_src2;
  assign i_iv[1] = ooe_rcu_issue_s1_valid;
  assign i_cont[1] = ooe_rcu_issue_s1_payload.cont;
  assign i_foot[1*4 +: 4] = ooe_rcu_issue_s1_payload.footprint;
  assign i_opc[1*OW +: OW] = ooe_rcu_issue_s1_payload.opcode;
  assign i_drw[1*2 +: 2] = ooe_rcu_issue_s1_payload.done_row;
  assign i_tag[1*WT +: WT] = ooe_rcu_issue_s1_payload.rob_tag;
  assign i_im[1*N +: N] = ooe_rcu_issue_s1_payload.issue_mask;
  assign i_gd[1*WP +: WP] = ooe_rcu_issue_s1_payload.phys_pred_guard;
  assign i_ng[1] = ooe_rcu_issue_s1_payload.pred_neg;
  assign i_pd[1*WP +: WP] = ooe_rcu_issue_s1_payload.phys_pred_dst;
  assign i_pod[1*WP +: WP] = ooe_rcu_issue_s1_payload.phys_pred_old_dst;
  assign i_pwe[1] = ooe_rcu_issue_s1_payload.pred_we;
  assign i_mrg[1] = ooe_rcu_issue_s1_payload.merge_en;
  assign i_dst[1*WR +: WR] = ooe_rcu_issue_s1_payload.phys_dst;
  assign i_odst[1*WR +: WR] = ooe_rcu_issue_s1_payload.phys_old_dst;
  assign i_imm[1*32 +: 32] = ooe_rcu_issue_s1_payload.imm;
  assign i_spos[1*6 +: 6] = ooe_rcu_issue_s1_payload.src_pos;
  assign i_swid[1*6 +: 6] = ooe_rcu_issue_s1_payload.src_width;
  assign i_dpos[1*2 +: 2] = ooe_rcu_issue_s1_payload.dst_pos;
  assign i_dwid[1*2 +: 2] = ooe_rcu_issue_s1_payload.dst_width;
  assign i_opos[1*2 +: 2] = ooe_rcu_issue_s1_payload.old_dst_pos;
  assign i_lsec[1*4 +: 4] = ooe_rcu_issue_s1_payload.lead_sec_mask;
  assign i_lsrc[1*3 +: 3] = ooe_rcu_issue_s1_payload.lead_src_used;
  assign i_limm[1] = ooe_rcu_issue_s1_payload.lead_imm_used;
  assign i_lmrg[1] = ooe_rcu_issue_s1_payload.lead_merge_used;
  assign i_lgu[1] = ooe_rcu_issue_s1_payload.lead_guard_used;
  assign i_lgp[1*WP +: WP] = ooe_rcu_issue_s1_payload.lead_guard_pred;
  assign i_src[(1*3 + 0)*WR +: WR] = ooe_rcu_issue_s1_payload.phys_src[2*WR-1:WR];
  assign i_src[(1*3 + 1)*WR +: WR] = ooe_rcu_issue_s1_payload.phys_src[WR-1:0];
  assign i_src[(1*3 + 2)*WR +: WR] = ooe_rcu_issue_s1_payload.phys_src2;
  assign i_iv[2] = ooe_rcu_issue_s2_valid;
  assign i_cont[2] = ooe_rcu_issue_s2_payload.cont;
  assign i_foot[2*4 +: 4] = ooe_rcu_issue_s2_payload.footprint;
  assign i_opc[2*OW +: OW] = ooe_rcu_issue_s2_payload.opcode;
  assign i_drw[2*2 +: 2] = ooe_rcu_issue_s2_payload.done_row;
  assign i_tag[2*WT +: WT] = ooe_rcu_issue_s2_payload.rob_tag;
  assign i_im[2*N +: N] = ooe_rcu_issue_s2_payload.issue_mask;
  assign i_gd[2*WP +: WP] = ooe_rcu_issue_s2_payload.phys_pred_guard;
  assign i_ng[2] = ooe_rcu_issue_s2_payload.pred_neg;
  assign i_pd[2*WP +: WP] = ooe_rcu_issue_s2_payload.phys_pred_dst;
  assign i_pod[2*WP +: WP] = ooe_rcu_issue_s2_payload.phys_pred_old_dst;
  assign i_pwe[2] = ooe_rcu_issue_s2_payload.pred_we;
  assign i_mrg[2] = ooe_rcu_issue_s2_payload.merge_en;
  assign i_dst[2*WR +: WR] = ooe_rcu_issue_s2_payload.phys_dst;
  assign i_odst[2*WR +: WR] = ooe_rcu_issue_s2_payload.phys_old_dst;
  assign i_imm[2*32 +: 32] = ooe_rcu_issue_s2_payload.imm;
  assign i_spos[2*6 +: 6] = ooe_rcu_issue_s2_payload.src_pos;
  assign i_swid[2*6 +: 6] = ooe_rcu_issue_s2_payload.src_width;
  assign i_dpos[2*2 +: 2] = ooe_rcu_issue_s2_payload.dst_pos;
  assign i_dwid[2*2 +: 2] = ooe_rcu_issue_s2_payload.dst_width;
  assign i_opos[2*2 +: 2] = ooe_rcu_issue_s2_payload.old_dst_pos;
  assign i_lsec[2*4 +: 4] = ooe_rcu_issue_s2_payload.lead_sec_mask;
  assign i_lsrc[2*3 +: 3] = ooe_rcu_issue_s2_payload.lead_src_used;
  assign i_limm[2] = ooe_rcu_issue_s2_payload.lead_imm_used;
  assign i_lmrg[2] = ooe_rcu_issue_s2_payload.lead_merge_used;
  assign i_lgu[2] = ooe_rcu_issue_s2_payload.lead_guard_used;
  assign i_lgp[2*WP +: WP] = ooe_rcu_issue_s2_payload.lead_guard_pred;
  assign i_src[(2*3 + 0)*WR +: WR] = ooe_rcu_issue_s2_payload.phys_src[2*WR-1:WR];
  assign i_src[(2*3 + 1)*WR +: WR] = ooe_rcu_issue_s2_payload.phys_src[WR-1:0];
  assign i_src[(2*3 + 2)*WR +: WR] = ooe_rcu_issue_s2_payload.phys_src2;
  assign i_iv[3] = ooe_rcu_issue_s3_valid;
  assign i_cont[3] = ooe_rcu_issue_s3_payload.cont;
  assign i_foot[3*4 +: 4] = ooe_rcu_issue_s3_payload.footprint;
  assign i_opc[3*OW +: OW] = ooe_rcu_issue_s3_payload.opcode;
  assign i_drw[3*2 +: 2] = ooe_rcu_issue_s3_payload.done_row;
  assign i_tag[3*WT +: WT] = ooe_rcu_issue_s3_payload.rob_tag;
  assign i_im[3*N +: N] = ooe_rcu_issue_s3_payload.issue_mask;
  assign i_gd[3*WP +: WP] = ooe_rcu_issue_s3_payload.phys_pred_guard;
  assign i_ng[3] = ooe_rcu_issue_s3_payload.pred_neg;
  assign i_pd[3*WP +: WP] = ooe_rcu_issue_s3_payload.phys_pred_dst;
  assign i_pod[3*WP +: WP] = ooe_rcu_issue_s3_payload.phys_pred_old_dst;
  assign i_pwe[3] = ooe_rcu_issue_s3_payload.pred_we;
  assign i_mrg[3] = ooe_rcu_issue_s3_payload.merge_en;
  assign i_dst[3*WR +: WR] = ooe_rcu_issue_s3_payload.phys_dst;
  assign i_odst[3*WR +: WR] = ooe_rcu_issue_s3_payload.phys_old_dst;
  assign i_imm[3*32 +: 32] = ooe_rcu_issue_s3_payload.imm;
  assign i_spos[3*6 +: 6] = ooe_rcu_issue_s3_payload.src_pos;
  assign i_swid[3*6 +: 6] = ooe_rcu_issue_s3_payload.src_width;
  assign i_dpos[3*2 +: 2] = ooe_rcu_issue_s3_payload.dst_pos;
  assign i_dwid[3*2 +: 2] = ooe_rcu_issue_s3_payload.dst_width;
  assign i_opos[3*2 +: 2] = ooe_rcu_issue_s3_payload.old_dst_pos;
  assign i_lsec[3*4 +: 4] = ooe_rcu_issue_s3_payload.lead_sec_mask;
  assign i_lsrc[3*3 +: 3] = ooe_rcu_issue_s3_payload.lead_src_used;
  assign i_limm[3] = ooe_rcu_issue_s3_payload.lead_imm_used;
  assign i_lmrg[3] = ooe_rcu_issue_s3_payload.lead_merge_used;
  assign i_lgu[3] = ooe_rcu_issue_s3_payload.lead_guard_used;
  assign i_lgp[3*WP +: WP] = ooe_rcu_issue_s3_payload.lead_guard_pred;
  assign i_src[(3*3 + 0)*WR +: WR] = ooe_rcu_issue_s3_payload.phys_src[2*WR-1:WR];
  assign i_src[(3*3 + 1)*WR +: WR] = ooe_rcu_issue_s3_payload.phys_src[WR-1:0];
  assign i_src[(3*3 + 2)*WR +: WR] = ooe_rcu_issue_s3_payload.phys_src2;
  assign i_iv[4] = ooe_rcu_issue_s4_valid;
  assign i_cont[4] = ooe_rcu_issue_s4_payload.cont;
  assign i_foot[4*4 +: 4] = ooe_rcu_issue_s4_payload.footprint;
  assign i_opc[4*OW +: OW] = ooe_rcu_issue_s4_payload.opcode;
  assign i_drw[4*2 +: 2] = ooe_rcu_issue_s4_payload.done_row;
  assign i_tag[4*WT +: WT] = ooe_rcu_issue_s4_payload.rob_tag;
  assign i_im[4*N +: N] = ooe_rcu_issue_s4_payload.issue_mask;
  assign i_gd[4*WP +: WP] = ooe_rcu_issue_s4_payload.phys_pred_guard;
  assign i_ng[4] = ooe_rcu_issue_s4_payload.pred_neg;
  assign i_pd[4*WP +: WP] = ooe_rcu_issue_s4_payload.phys_pred_dst;
  assign i_pod[4*WP +: WP] = ooe_rcu_issue_s4_payload.phys_pred_old_dst;
  assign i_pwe[4] = ooe_rcu_issue_s4_payload.pred_we;
  assign i_mrg[4] = ooe_rcu_issue_s4_payload.merge_en;
  assign i_dst[4*WR +: WR] = ooe_rcu_issue_s4_payload.phys_dst;
  assign i_odst[4*WR +: WR] = ooe_rcu_issue_s4_payload.phys_old_dst;
  assign i_imm[4*32 +: 32] = ooe_rcu_issue_s4_payload.imm;
  assign i_spos[4*6 +: 6] = ooe_rcu_issue_s4_payload.src_pos;
  assign i_swid[4*6 +: 6] = ooe_rcu_issue_s4_payload.src_width;
  assign i_dpos[4*2 +: 2] = ooe_rcu_issue_s4_payload.dst_pos;
  assign i_dwid[4*2 +: 2] = ooe_rcu_issue_s4_payload.dst_width;
  assign i_opos[4*2 +: 2] = ooe_rcu_issue_s4_payload.old_dst_pos;
  assign i_lsec[4*4 +: 4] = ooe_rcu_issue_s4_payload.lead_sec_mask;
  assign i_lsrc[4*3 +: 3] = ooe_rcu_issue_s4_payload.lead_src_used;
  assign i_limm[4] = ooe_rcu_issue_s4_payload.lead_imm_used;
  assign i_lmrg[4] = ooe_rcu_issue_s4_payload.lead_merge_used;
  assign i_lgu[4] = ooe_rcu_issue_s4_payload.lead_guard_used;
  assign i_lgp[4*WP +: WP] = ooe_rcu_issue_s4_payload.lead_guard_pred;
  assign i_src[(4*3 + 0)*WR +: WR] = ooe_rcu_issue_s4_payload.phys_src[2*WR-1:WR];
  assign i_src[(4*3 + 1)*WR +: WR] = ooe_rcu_issue_s4_payload.phys_src[WR-1:0];
  assign i_src[(4*3 + 2)*WR +: WR] = ooe_rcu_issue_s4_payload.phys_src2;
  assign i_iv[5] = ooe_rcu_issue_s5_valid;
  assign i_cont[5] = ooe_rcu_issue_s5_payload.cont;
  assign i_foot[5*4 +: 4] = ooe_rcu_issue_s5_payload.footprint;
  assign i_opc[5*OW +: OW] = ooe_rcu_issue_s5_payload.opcode;
  assign i_drw[5*2 +: 2] = ooe_rcu_issue_s5_payload.done_row;
  assign i_tag[5*WT +: WT] = ooe_rcu_issue_s5_payload.rob_tag;
  assign i_im[5*N +: N] = ooe_rcu_issue_s5_payload.issue_mask;
  assign i_gd[5*WP +: WP] = ooe_rcu_issue_s5_payload.phys_pred_guard;
  assign i_ng[5] = ooe_rcu_issue_s5_payload.pred_neg;
  assign i_pd[5*WP +: WP] = ooe_rcu_issue_s5_payload.phys_pred_dst;
  assign i_pod[5*WP +: WP] = ooe_rcu_issue_s5_payload.phys_pred_old_dst;
  assign i_pwe[5] = ooe_rcu_issue_s5_payload.pred_we;
  assign i_mrg[5] = ooe_rcu_issue_s5_payload.merge_en;
  assign i_dst[5*WR +: WR] = ooe_rcu_issue_s5_payload.phys_dst;
  assign i_odst[5*WR +: WR] = ooe_rcu_issue_s5_payload.phys_old_dst;
  assign i_imm[5*32 +: 32] = ooe_rcu_issue_s5_payload.imm;
  assign i_spos[5*6 +: 6] = ooe_rcu_issue_s5_payload.src_pos;
  assign i_swid[5*6 +: 6] = ooe_rcu_issue_s5_payload.src_width;
  assign i_dpos[5*2 +: 2] = ooe_rcu_issue_s5_payload.dst_pos;
  assign i_dwid[5*2 +: 2] = ooe_rcu_issue_s5_payload.dst_width;
  assign i_opos[5*2 +: 2] = ooe_rcu_issue_s5_payload.old_dst_pos;
  assign i_lsec[5*4 +: 4] = ooe_rcu_issue_s5_payload.lead_sec_mask;
  assign i_lsrc[5*3 +: 3] = ooe_rcu_issue_s5_payload.lead_src_used;
  assign i_limm[5] = ooe_rcu_issue_s5_payload.lead_imm_used;
  assign i_lmrg[5] = ooe_rcu_issue_s5_payload.lead_merge_used;
  assign i_lgu[5] = ooe_rcu_issue_s5_payload.lead_guard_used;
  assign i_lgp[5*WP +: WP] = ooe_rcu_issue_s5_payload.lead_guard_pred;
  assign i_src[(5*3 + 0)*WR +: WR] = ooe_rcu_issue_s5_payload.phys_src[2*WR-1:WR];
  assign i_src[(5*3 + 1)*WR +: WR] = ooe_rcu_issue_s5_payload.phys_src[WR-1:0];
  assign i_src[(5*3 + 2)*WR +: WR] = ooe_rcu_issue_s5_payload.phys_src2;
  assign i_iv[6] = ooe_rcu_issue_s6_valid;
  assign i_cont[6] = ooe_rcu_issue_s6_payload.cont;
  assign i_foot[6*4 +: 4] = ooe_rcu_issue_s6_payload.footprint;
  assign i_opc[6*OW +: OW] = ooe_rcu_issue_s6_payload.opcode;
  assign i_drw[6*2 +: 2] = ooe_rcu_issue_s6_payload.done_row;
  assign i_tag[6*WT +: WT] = ooe_rcu_issue_s6_payload.rob_tag;
  assign i_im[6*N +: N] = ooe_rcu_issue_s6_payload.issue_mask;
  assign i_gd[6*WP +: WP] = ooe_rcu_issue_s6_payload.phys_pred_guard;
  assign i_ng[6] = ooe_rcu_issue_s6_payload.pred_neg;
  assign i_pd[6*WP +: WP] = ooe_rcu_issue_s6_payload.phys_pred_dst;
  assign i_pod[6*WP +: WP] = ooe_rcu_issue_s6_payload.phys_pred_old_dst;
  assign i_pwe[6] = ooe_rcu_issue_s6_payload.pred_we;
  assign i_mrg[6] = ooe_rcu_issue_s6_payload.merge_en;
  assign i_dst[6*WR +: WR] = ooe_rcu_issue_s6_payload.phys_dst;
  assign i_odst[6*WR +: WR] = ooe_rcu_issue_s6_payload.phys_old_dst;
  assign i_imm[6*32 +: 32] = ooe_rcu_issue_s6_payload.imm;
  assign i_spos[6*6 +: 6] = ooe_rcu_issue_s6_payload.src_pos;
  assign i_swid[6*6 +: 6] = ooe_rcu_issue_s6_payload.src_width;
  assign i_dpos[6*2 +: 2] = ooe_rcu_issue_s6_payload.dst_pos;
  assign i_dwid[6*2 +: 2] = ooe_rcu_issue_s6_payload.dst_width;
  assign i_opos[6*2 +: 2] = ooe_rcu_issue_s6_payload.old_dst_pos;
  assign i_lsec[6*4 +: 4] = ooe_rcu_issue_s6_payload.lead_sec_mask;
  assign i_lsrc[6*3 +: 3] = ooe_rcu_issue_s6_payload.lead_src_used;
  assign i_limm[6] = ooe_rcu_issue_s6_payload.lead_imm_used;
  assign i_lmrg[6] = ooe_rcu_issue_s6_payload.lead_merge_used;
  assign i_lgu[6] = ooe_rcu_issue_s6_payload.lead_guard_used;
  assign i_lgp[6*WP +: WP] = ooe_rcu_issue_s6_payload.lead_guard_pred;
  assign i_src[(6*3 + 0)*WR +: WR] = ooe_rcu_issue_s6_payload.phys_src[2*WR-1:WR];
  assign i_src[(6*3 + 1)*WR +: WR] = ooe_rcu_issue_s6_payload.phys_src[WR-1:0];
  assign i_src[(6*3 + 2)*WR +: WR] = ooe_rcu_issue_s6_payload.phys_src2;
  assign i_iv[7] = ooe_rcu_issue_s7_valid;
  assign i_cont[7] = ooe_rcu_issue_s7_payload.cont;
  assign i_foot[7*4 +: 4] = ooe_rcu_issue_s7_payload.footprint;
  assign i_opc[7*OW +: OW] = ooe_rcu_issue_s7_payload.opcode;
  assign i_drw[7*2 +: 2] = ooe_rcu_issue_s7_payload.done_row;
  assign i_tag[7*WT +: WT] = ooe_rcu_issue_s7_payload.rob_tag;
  assign i_im[7*N +: N] = ooe_rcu_issue_s7_payload.issue_mask;
  assign i_gd[7*WP +: WP] = ooe_rcu_issue_s7_payload.phys_pred_guard;
  assign i_ng[7] = ooe_rcu_issue_s7_payload.pred_neg;
  assign i_pd[7*WP +: WP] = ooe_rcu_issue_s7_payload.phys_pred_dst;
  assign i_pod[7*WP +: WP] = ooe_rcu_issue_s7_payload.phys_pred_old_dst;
  assign i_pwe[7] = ooe_rcu_issue_s7_payload.pred_we;
  assign i_mrg[7] = ooe_rcu_issue_s7_payload.merge_en;
  assign i_dst[7*WR +: WR] = ooe_rcu_issue_s7_payload.phys_dst;
  assign i_odst[7*WR +: WR] = ooe_rcu_issue_s7_payload.phys_old_dst;
  assign i_imm[7*32 +: 32] = ooe_rcu_issue_s7_payload.imm;
  assign i_spos[7*6 +: 6] = ooe_rcu_issue_s7_payload.src_pos;
  assign i_swid[7*6 +: 6] = ooe_rcu_issue_s7_payload.src_width;
  assign i_dpos[7*2 +: 2] = ooe_rcu_issue_s7_payload.dst_pos;
  assign i_dwid[7*2 +: 2] = ooe_rcu_issue_s7_payload.dst_width;
  assign i_opos[7*2 +: 2] = ooe_rcu_issue_s7_payload.old_dst_pos;
  assign i_lsec[7*4 +: 4] = ooe_rcu_issue_s7_payload.lead_sec_mask;
  assign i_lsrc[7*3 +: 3] = ooe_rcu_issue_s7_payload.lead_src_used;
  assign i_limm[7] = ooe_rcu_issue_s7_payload.lead_imm_used;
  assign i_lmrg[7] = ooe_rcu_issue_s7_payload.lead_merge_used;
  assign i_lgu[7] = ooe_rcu_issue_s7_payload.lead_guard_used;
  assign i_lgp[7*WP +: WP] = ooe_rcu_issue_s7_payload.lead_guard_pred;
  assign i_src[(7*3 + 0)*WR +: WR] = ooe_rcu_issue_s7_payload.phys_src[2*WR-1:WR];
  assign i_src[(7*3 + 1)*WR +: WR] = ooe_rcu_issue_s7_payload.phys_src[WR-1:0];
  assign i_src[(7*3 + 2)*WR +: WR] = ooe_rcu_issue_s7_payload.phys_src2;
  assign i_iv[8] = ooe_rcu_issue_s8_valid;
  assign i_cont[8] = ooe_rcu_issue_s8_payload.cont;
  assign i_foot[8*4 +: 4] = ooe_rcu_issue_s8_payload.footprint;
  assign i_opc[8*OW +: OW] = ooe_rcu_issue_s8_payload.opcode;
  assign i_drw[8*2 +: 2] = ooe_rcu_issue_s8_payload.done_row;
  assign i_tag[8*WT +: WT] = ooe_rcu_issue_s8_payload.rob_tag;
  assign i_im[8*N +: N] = ooe_rcu_issue_s8_payload.issue_mask;
  assign i_gd[8*WP +: WP] = ooe_rcu_issue_s8_payload.phys_pred_guard;
  assign i_ng[8] = ooe_rcu_issue_s8_payload.pred_neg;
  assign i_pd[8*WP +: WP] = ooe_rcu_issue_s8_payload.phys_pred_dst;
  assign i_pod[8*WP +: WP] = ooe_rcu_issue_s8_payload.phys_pred_old_dst;
  assign i_pwe[8] = ooe_rcu_issue_s8_payload.pred_we;
  assign i_mrg[8] = ooe_rcu_issue_s8_payload.merge_en;
  assign i_dst[8*WR +: WR] = ooe_rcu_issue_s8_payload.phys_dst;
  assign i_odst[8*WR +: WR] = ooe_rcu_issue_s8_payload.phys_old_dst;
  assign i_imm[8*32 +: 32] = ooe_rcu_issue_s8_payload.imm;
  assign i_spos[8*6 +: 6] = ooe_rcu_issue_s8_payload.src_pos;
  assign i_swid[8*6 +: 6] = ooe_rcu_issue_s8_payload.src_width;
  assign i_dpos[8*2 +: 2] = ooe_rcu_issue_s8_payload.dst_pos;
  assign i_dwid[8*2 +: 2] = ooe_rcu_issue_s8_payload.dst_width;
  assign i_opos[8*2 +: 2] = ooe_rcu_issue_s8_payload.old_dst_pos;
  assign i_lsec[8*4 +: 4] = ooe_rcu_issue_s8_payload.lead_sec_mask;
  assign i_lsrc[8*3 +: 3] = ooe_rcu_issue_s8_payload.lead_src_used;
  assign i_limm[8] = ooe_rcu_issue_s8_payload.lead_imm_used;
  assign i_lmrg[8] = ooe_rcu_issue_s8_payload.lead_merge_used;
  assign i_lgu[8] = ooe_rcu_issue_s8_payload.lead_guard_used;
  assign i_lgp[8*WP +: WP] = ooe_rcu_issue_s8_payload.lead_guard_pred;
  assign i_src[(8*3 + 0)*WR +: WR] = ooe_rcu_issue_s8_payload.phys_src[2*WR-1:WR];
  assign i_src[(8*3 + 1)*WR +: WR] = ooe_rcu_issue_s8_payload.phys_src[WR-1:0];
  assign i_src[(8*3 + 2)*WR +: WR] = ooe_rcu_issue_s8_payload.phys_src2;

  // ---- lane_rcu_res, flat ----------------------------------------------------
  logic [N-1:0] lr_v;
  logic [N*32-1:0] lr_res;
  logic [N*NK-1:0] lr_sv, lr_spo;   // copy l's section k at l*NK + k
  assign lr_v[0] = lane_rcu_res_c00_valid;
  assign lr_res[0*32 +: 32] = lane_rcu_res_c00_payload.result;
  assign lr_sv[0*NK +: NK] = lane_rcu_res_c00_payload.sec_valid;
  assign lr_spo[0*NK +: NK] = lane_rcu_res_c00_payload.sec_pred_out;
  assign lr_v[1] = lane_rcu_res_c01_valid;
  assign lr_res[1*32 +: 32] = lane_rcu_res_c01_payload.result;
  assign lr_sv[1*NK +: NK] = lane_rcu_res_c01_payload.sec_valid;
  assign lr_spo[1*NK +: NK] = lane_rcu_res_c01_payload.sec_pred_out;
  assign lr_v[2] = lane_rcu_res_c02_valid;
  assign lr_res[2*32 +: 32] = lane_rcu_res_c02_payload.result;
  assign lr_sv[2*NK +: NK] = lane_rcu_res_c02_payload.sec_valid;
  assign lr_spo[2*NK +: NK] = lane_rcu_res_c02_payload.sec_pred_out;
  assign lr_v[3] = lane_rcu_res_c03_valid;
  assign lr_res[3*32 +: 32] = lane_rcu_res_c03_payload.result;
  assign lr_sv[3*NK +: NK] = lane_rcu_res_c03_payload.sec_valid;
  assign lr_spo[3*NK +: NK] = lane_rcu_res_c03_payload.sec_pred_out;
  assign lr_v[4] = lane_rcu_res_c04_valid;
  assign lr_res[4*32 +: 32] = lane_rcu_res_c04_payload.result;
  assign lr_sv[4*NK +: NK] = lane_rcu_res_c04_payload.sec_valid;
  assign lr_spo[4*NK +: NK] = lane_rcu_res_c04_payload.sec_pred_out;
  assign lr_v[5] = lane_rcu_res_c05_valid;
  assign lr_res[5*32 +: 32] = lane_rcu_res_c05_payload.result;
  assign lr_sv[5*NK +: NK] = lane_rcu_res_c05_payload.sec_valid;
  assign lr_spo[5*NK +: NK] = lane_rcu_res_c05_payload.sec_pred_out;
  assign lr_v[6] = lane_rcu_res_c06_valid;
  assign lr_res[6*32 +: 32] = lane_rcu_res_c06_payload.result;
  assign lr_sv[6*NK +: NK] = lane_rcu_res_c06_payload.sec_valid;
  assign lr_spo[6*NK +: NK] = lane_rcu_res_c06_payload.sec_pred_out;
  assign lr_v[7] = lane_rcu_res_c07_valid;
  assign lr_res[7*32 +: 32] = lane_rcu_res_c07_payload.result;
  assign lr_sv[7*NK +: NK] = lane_rcu_res_c07_payload.sec_valid;
  assign lr_spo[7*NK +: NK] = lane_rcu_res_c07_payload.sec_pred_out;
  assign lr_v[8] = lane_rcu_res_c08_valid;
  assign lr_res[8*32 +: 32] = lane_rcu_res_c08_payload.result;
  assign lr_sv[8*NK +: NK] = lane_rcu_res_c08_payload.sec_valid;
  assign lr_spo[8*NK +: NK] = lane_rcu_res_c08_payload.sec_pred_out;
  assign lr_v[9] = lane_rcu_res_c09_valid;
  assign lr_res[9*32 +: 32] = lane_rcu_res_c09_payload.result;
  assign lr_sv[9*NK +: NK] = lane_rcu_res_c09_payload.sec_valid;
  assign lr_spo[9*NK +: NK] = lane_rcu_res_c09_payload.sec_pred_out;
  assign lr_v[10] = lane_rcu_res_c10_valid;
  assign lr_res[10*32 +: 32] = lane_rcu_res_c10_payload.result;
  assign lr_sv[10*NK +: NK] = lane_rcu_res_c10_payload.sec_valid;
  assign lr_spo[10*NK +: NK] = lane_rcu_res_c10_payload.sec_pred_out;
  assign lr_v[11] = lane_rcu_res_c11_valid;
  assign lr_res[11*32 +: 32] = lane_rcu_res_c11_payload.result;
  assign lr_sv[11*NK +: NK] = lane_rcu_res_c11_payload.sec_valid;
  assign lr_spo[11*NK +: NK] = lane_rcu_res_c11_payload.sec_pred_out;
  assign lr_v[12] = lane_rcu_res_c12_valid;
  assign lr_res[12*32 +: 32] = lane_rcu_res_c12_payload.result;
  assign lr_sv[12*NK +: NK] = lane_rcu_res_c12_payload.sec_valid;
  assign lr_spo[12*NK +: NK] = lane_rcu_res_c12_payload.sec_pred_out;
  assign lr_v[13] = lane_rcu_res_c13_valid;
  assign lr_res[13*32 +: 32] = lane_rcu_res_c13_payload.result;
  assign lr_sv[13*NK +: NK] = lane_rcu_res_c13_payload.sec_valid;
  assign lr_spo[13*NK +: NK] = lane_rcu_res_c13_payload.sec_pred_out;
  assign lr_v[14] = lane_rcu_res_c14_valid;
  assign lr_res[14*32 +: 32] = lane_rcu_res_c14_payload.result;
  assign lr_sv[14*NK +: NK] = lane_rcu_res_c14_payload.sec_valid;
  assign lr_spo[14*NK +: NK] = lane_rcu_res_c14_payload.sec_pred_out;
  assign lr_v[15] = lane_rcu_res_c15_valid;
  assign lr_res[15*32 +: 32] = lane_rcu_res_c15_payload.result;
  assign lr_sv[15*NK +: NK] = lane_rcu_res_c15_payload.sec_valid;
  assign lr_spo[15*NK +: NK] = lane_rcu_res_c15_payload.sec_pred_out;
  assign lr_v[16] = lane_rcu_res_c16_valid;
  assign lr_res[16*32 +: 32] = lane_rcu_res_c16_payload.result;
  assign lr_sv[16*NK +: NK] = lane_rcu_res_c16_payload.sec_valid;
  assign lr_spo[16*NK +: NK] = lane_rcu_res_c16_payload.sec_pred_out;
  assign lr_v[17] = lane_rcu_res_c17_valid;
  assign lr_res[17*32 +: 32] = lane_rcu_res_c17_payload.result;
  assign lr_sv[17*NK +: NK] = lane_rcu_res_c17_payload.sec_valid;
  assign lr_spo[17*NK +: NK] = lane_rcu_res_c17_payload.sec_pred_out;
  assign lr_v[18] = lane_rcu_res_c18_valid;
  assign lr_res[18*32 +: 32] = lane_rcu_res_c18_payload.result;
  assign lr_sv[18*NK +: NK] = lane_rcu_res_c18_payload.sec_valid;
  assign lr_spo[18*NK +: NK] = lane_rcu_res_c18_payload.sec_pred_out;
  assign lr_v[19] = lane_rcu_res_c19_valid;
  assign lr_res[19*32 +: 32] = lane_rcu_res_c19_payload.result;
  assign lr_sv[19*NK +: NK] = lane_rcu_res_c19_payload.sec_valid;
  assign lr_spo[19*NK +: NK] = lane_rcu_res_c19_payload.sec_pred_out;
  assign lr_v[20] = lane_rcu_res_c20_valid;
  assign lr_res[20*32 +: 32] = lane_rcu_res_c20_payload.result;
  assign lr_sv[20*NK +: NK] = lane_rcu_res_c20_payload.sec_valid;
  assign lr_spo[20*NK +: NK] = lane_rcu_res_c20_payload.sec_pred_out;
  assign lr_v[21] = lane_rcu_res_c21_valid;
  assign lr_res[21*32 +: 32] = lane_rcu_res_c21_payload.result;
  assign lr_sv[21*NK +: NK] = lane_rcu_res_c21_payload.sec_valid;
  assign lr_spo[21*NK +: NK] = lane_rcu_res_c21_payload.sec_pred_out;
  assign lr_v[22] = lane_rcu_res_c22_valid;
  assign lr_res[22*32 +: 32] = lane_rcu_res_c22_payload.result;
  assign lr_sv[22*NK +: NK] = lane_rcu_res_c22_payload.sec_valid;
  assign lr_spo[22*NK +: NK] = lane_rcu_res_c22_payload.sec_pred_out;
  assign lr_v[23] = lane_rcu_res_c23_valid;
  assign lr_res[23*32 +: 32] = lane_rcu_res_c23_payload.result;
  assign lr_sv[23*NK +: NK] = lane_rcu_res_c23_payload.sec_valid;
  assign lr_spo[23*NK +: NK] = lane_rcu_res_c23_payload.sec_pred_out;
  assign lr_v[24] = lane_rcu_res_c24_valid;
  assign lr_res[24*32 +: 32] = lane_rcu_res_c24_payload.result;
  assign lr_sv[24*NK +: NK] = lane_rcu_res_c24_payload.sec_valid;
  assign lr_spo[24*NK +: NK] = lane_rcu_res_c24_payload.sec_pred_out;
  assign lr_v[25] = lane_rcu_res_c25_valid;
  assign lr_res[25*32 +: 32] = lane_rcu_res_c25_payload.result;
  assign lr_sv[25*NK +: NK] = lane_rcu_res_c25_payload.sec_valid;
  assign lr_spo[25*NK +: NK] = lane_rcu_res_c25_payload.sec_pred_out;
  assign lr_v[26] = lane_rcu_res_c26_valid;
  assign lr_res[26*32 +: 32] = lane_rcu_res_c26_payload.result;
  assign lr_sv[26*NK +: NK] = lane_rcu_res_c26_payload.sec_valid;
  assign lr_spo[26*NK +: NK] = lane_rcu_res_c26_payload.sec_pred_out;
  assign lr_v[27] = lane_rcu_res_c27_valid;
  assign lr_res[27*32 +: 32] = lane_rcu_res_c27_payload.result;
  assign lr_sv[27*NK +: NK] = lane_rcu_res_c27_payload.sec_valid;
  assign lr_spo[27*NK +: NK] = lane_rcu_res_c27_payload.sec_pred_out;
  assign lr_v[28] = lane_rcu_res_c28_valid;
  assign lr_res[28*32 +: 32] = lane_rcu_res_c28_payload.result;
  assign lr_sv[28*NK +: NK] = lane_rcu_res_c28_payload.sec_valid;
  assign lr_spo[28*NK +: NK] = lane_rcu_res_c28_payload.sec_pred_out;
  assign lr_v[29] = lane_rcu_res_c29_valid;
  assign lr_res[29*32 +: 32] = lane_rcu_res_c29_payload.result;
  assign lr_sv[29*NK +: NK] = lane_rcu_res_c29_payload.sec_valid;
  assign lr_spo[29*NK +: NK] = lane_rcu_res_c29_payload.sec_pred_out;
  assign lr_v[30] = lane_rcu_res_c30_valid;
  assign lr_res[30*32 +: 32] = lane_rcu_res_c30_payload.result;
  assign lr_sv[30*NK +: NK] = lane_rcu_res_c30_payload.sec_valid;
  assign lr_spo[30*NK +: NK] = lane_rcu_res_c30_payload.sec_pred_out;
  assign lr_v[31] = lane_rcu_res_c31_valid;
  assign lr_res[31*32 +: 32] = lane_rcu_res_c31_payload.result;
  assign lr_sv[31*NK +: NK] = lane_rcu_res_c31_payload.sec_valid;
  assign lr_spo[31*NK +: NK] = lane_rcu_res_c31_payload.sec_pred_out;
  // PL k's new value: lane l's sec_pred_out[k] (a transpose).
  logic [NK*N-1:0] pl_val;
  for (genvar k = 0; k < NK; k++) begin : g_plval
    for (genvar l = 0; l < N; l++) begin : g_l
      assign pl_val[k*N + l] = lr_spo[l*NK + k];
    end
  end

  // ---- miu_rcu_data, flat ----------------------------------------------------
  logic [NM-1:0] md_v, md_pwe;
  logic [NM*WR-1:0] md_row;
  logic [NM*2-1:0] md_wid, md_pos;
  logic [NM*N-1:0] md_am, md_pr;
  logic [NM*WP-1:0] md_pp;
  logic [NM*N*32-1:0] md_dat;
  assign md_v[0] = miu_rcu_data_s0_valid;
  assign md_pwe[0] = miu_rcu_data_s0_payload.pred_we;
  assign md_row[0*WR +: WR] = miu_rcu_data_s0_payload.phys_dst;
  assign md_wid[0*2 +: 2] = miu_rcu_data_s0_payload.dst_width;
  assign md_pos[0*2 +: 2] = miu_rcu_data_s0_payload.dst_pos;
  assign md_am[0*N +: N] = miu_rcu_data_s0_payload.active_mask;
  assign md_pr[0*N +: N] = miu_rcu_data_s0_payload.pred_result;
  assign md_pp[0*WP +: WP] = miu_rcu_data_s0_payload.phys_pred;
  assign md_dat[0*N*32 +: N*32] = miu_rcu_data_s0_payload.load_data;
  assign md_v[1] = miu_rcu_data_s1_valid;
  assign md_pwe[1] = miu_rcu_data_s1_payload.pred_we;
  assign md_row[1*WR +: WR] = miu_rcu_data_s1_payload.phys_dst;
  assign md_wid[1*2 +: 2] = miu_rcu_data_s1_payload.dst_width;
  assign md_pos[1*2 +: 2] = miu_rcu_data_s1_payload.dst_pos;
  assign md_am[1*N +: N] = miu_rcu_data_s1_payload.active_mask;
  assign md_pr[1*N +: N] = miu_rcu_data_s1_payload.pred_result;
  assign md_pp[1*WP +: WP] = miu_rcu_data_s1_payload.phys_pred;
  assign md_dat[1*N*32 +: N*32] = miu_rcu_data_s1_payload.load_data;
  assign md_v[2] = miu_rcu_data_s2_valid;
  assign md_pwe[2] = miu_rcu_data_s2_payload.pred_we;
  assign md_row[2*WR +: WR] = miu_rcu_data_s2_payload.phys_dst;
  assign md_wid[2*2 +: 2] = miu_rcu_data_s2_payload.dst_width;
  assign md_pos[2*2 +: 2] = miu_rcu_data_s2_payload.dst_pos;
  assign md_am[2*N +: N] = miu_rcu_data_s2_payload.active_mask;
  assign md_pr[2*N +: N] = miu_rcu_data_s2_payload.pred_result;
  assign md_pp[2*WP +: WP] = miu_rcu_data_s2_payload.phys_pred;
  assign md_dat[2*N*32 +: N*32] = miu_rcu_data_s2_payload.load_data;
  assign md_v[3] = miu_rcu_data_s3_valid;
  assign md_pwe[3] = miu_rcu_data_s3_payload.pred_we;
  assign md_row[3*WR +: WR] = miu_rcu_data_s3_payload.phys_dst;
  assign md_wid[3*2 +: 2] = miu_rcu_data_s3_payload.dst_width;
  assign md_pos[3*2 +: 2] = miu_rcu_data_s3_payload.dst_pos;
  assign md_am[3*N +: N] = miu_rcu_data_s3_payload.active_mask;
  assign md_pr[3*N +: N] = miu_rcu_data_s3_payload.pred_result;
  assign md_pp[3*WP +: WP] = miu_rcu_data_s3_payload.phys_pred;
  assign md_dat[3*N*32 +: N*32] = miu_rcu_data_s3_payload.load_data;

  assign wake = {kill_valid, pca_rcu_mig_wake, rau_rcu_mig_wake, ooe_rcu_map_wake, miu_rcu_data_wake, lane_rcu_res_c31_wake, lane_rcu_res_c30_wake, lane_rcu_res_c29_wake, lane_rcu_res_c28_wake, lane_rcu_res_c27_wake, lane_rcu_res_c26_wake, lane_rcu_res_c25_wake, lane_rcu_res_c24_wake, lane_rcu_res_c23_wake, lane_rcu_res_c22_wake, lane_rcu_res_c21_wake, lane_rcu_res_c20_wake, lane_rcu_res_c19_wake, lane_rcu_res_c18_wake, lane_rcu_res_c17_wake, lane_rcu_res_c16_wake, lane_rcu_res_c15_wake, lane_rcu_res_c14_wake, lane_rcu_res_c13_wake, lane_rcu_res_c12_wake, lane_rcu_res_c11_wake, lane_rcu_res_c10_wake, lane_rcu_res_c09_wake, lane_rcu_res_c08_wake, lane_rcu_res_c07_wake, lane_rcu_res_c06_wake, lane_rcu_res_c05_wake, lane_rcu_res_c04_wake, lane_rcu_res_c03_wake, lane_rcu_res_c02_wake, lane_rcu_res_c01_wake, lane_rcu_res_c00_wake, ooe_rcu_issue_wake};

  // ---- Nets between the modules ---------------------------------------------
  // The bank slices: slice (K, J) is index K*NJ + J.
  localparam int NR = 8, NRR = 2;
  logic [NK*NJ*NR*32-1:0]  sl_rd;             // its rd_cr03h: port p's 4 lanes' byte K at p*32 + 8i
  logic [NK*NJ*NRR*32-1:0] sl_rs;             // its rs_cr04h: R0, R1
  logic [NK*4*N*8-1:0]     ln_rd;             // L0-L3 for rcu_lanes: bank k, port p, lane l at ((k*4 + p)*N + l)*8
  logic [NK*3*N*8-1:0]     mm_rd;             // M0-M2 for rcu_mem: ((k*3 + m)*N + l)*8
  logic [N*32-1:0]         r2_rd, r0_rs, r1_rs; // R2, R0, R1: lane l's byte k at l*32 + 8k

  // rcu_pred
  logic [NS*N-1:0] p_act;
  logic p_busy, p_lbt;
  logic [NK*N-1:0] p_gv, p_pst;
  logic [N-1:0] p_rpa, p_rpb, p_low, p_lbm;
  logic [N*NK-1:0] p_spb;
  logic [NK*N-1:0] p_dq;
  // rcu_r
  logic r_busy, r_rwv, r_prv, r_prmrg, r_dnbt;
  logic [WR-1:0] r_rwrow;
  logic [3:0] r_rwsec;
  logic [N*32-1:0] r_rwdat;
  logic [WP-1:0] r_prrow, r_prorow;
  logic [N-1:0] r_prval, r_prmm, r_dnbm;
  logic [1:0] r_dnv, r_dnrow;
  logic [WT-1:0] r_dntag;
  logic [31:0] r_dnaux;
  // rcu_lanes
  localparam int WO = ccv_prelim_pkg::CCV_L_W_OPCODE;
  localparam int NP = ccv_prelim_pkg::CCV_L_OPERANDS_PER_LANE + 1;
  localparam int WB = ccv_prov_pkg::CCV_P_W_LANE_BYP_SEL;
  localparam int NWK = (N + 7) / 8;
  logic [NWK-1:0] l_wk;
  logic l_busy, l_dbusy, l_swv, l_sdv;
  logic [N-1:0] l_v;
  logic [N*NK-1:0] l_sen, l_spd;
  logic [N*NK*WO-1:0] l_sop;
  logic [N*NP*32-1:0] l_opd;
  logic [N*NK*2-1:0] l_sown, l_sdpos, l_sdwid;
  logic [N*NK*NP*2-1:0] l_sopos, l_sowid;
  logic [N*NK*NP*WB-1:0] l_sbyp;
  logic [NK-1:0] l_lwv, l_plv, l_plmrg, l_pcv, l_dnv;
  logic [NK*WR-1:0] l_lwrow;
  logic [NK*NK-1:0] l_lwsec;
  logic [NK*N-1:0] l_lwlm, l_plmm, l_pcm;
  logic [NK*WP-1:0] l_plrow, l_plorow, l_pcrow, l_pcorow;
  logic [WR-1:0] l_swrow;
  logic [NK-1:0] l_swsec;
  logic [NK*WT-1:0] l_dntag;
  logic [NK*2-1:0] l_dnrow;
  logic [WT-1:0] l_sdtag;
  logic [1:0] l_sdrow;
  // rcu_mem
  logic m_wk, m_busy;
  logic [NK-1:0] m_v;
  logic [NK*WT-1:0] m_tag;
  logic [NK*N-1:0] m_am;
  logic [NK*N*32-1:0] m_base, m_idx, m_sd;
  // rcu_mig
  localparam int WW = ccv_params_pkg::CCV_W_WARP_ID;
  localparam int WMR = ccv_params_pkg::CCV_W_MIG_ROW;
  localparam int WD = ccv_params_pkg::CCV_W_DATA;
  logic g_mcr, g_ccr, g_pcr, g_ov, g_owk, g_quiet, g_busy, g_r2v, g_rwv, g_rwsel, g_gv;
  logic [WW-1:0] g_ow;
  logic [WMR-1:0] g_orow;
  logic [WD-1:0] g_odat, g_rwdat;
  logic [WR-1:0] g_r2row, g_rwrow;
  logic [NK-1:0] g_dv;
  logic [NK*WP-1:0] g_drow, g_grow;
  logic [NK*32-1:0] g_gdat;
  // rcu_kill
  localparam int NCR = NS + N + NM;
  logic [NCR-1:0] k_cr;
  logic k_dwake, k_csr_done, k_csr_cr;
  logic [31:0] k_csr_data;

  // ---- 32 rcu_bank_slice: K the byte section, J the lane group --------------
  for (genvar K = 0; K < NK; K++) begin : g_k
    for (genvar J = 0; J < NJ; J++) begin : g_j
      logic [3*32-1:0] wdat;
      logic [3*4-1:0] wlm;
      logic [NM*4-1:0] mlm;
      logic [NM*4*32-1:0] mdat;
      logic [31:0] gdat;
      for (genvar i = 0; i < 4; i++) begin : g_i
        assign wdat[0*32 + 8*i +: 8] = lr_res[(4*J + i)*32 + 8*K +: 8];       // LW: the lanes' results
        assign wdat[1*32 + 8*i +: 8] = 8'h00;                                 // SW: not on lane_rcu_res yet (RA-3)
        assign wdat[2*32 + 8*i +: 8] = r_rwdat[(4*J + i)*32 + 8*K +: 8];      // RW
        assign gdat[8*i +: 8] = g_rwdat[(4*J + i)*32 + 8*K +: 8];
        for (genvar j = 0; j < NM; j++) begin : g_m
          assign mlm[j*4 + i] = md_am[j*N + 4*J + i];
          assign mdat[(j*4 + i)*32 +: 32] = md_dat[j*N*32 + (4*J + i)*32 +: 32];
        end
      end
      assign wlm = {4'hf, 4'hf, l_lwlm[K*N + 4*J +: 4]};
      rcu_bank_slice #(.K(K), .FULL_ROW(1)) u_slice (
        .rcu_core_clk(gclk),
        .rst_n       (rst_n),
        .sv_cr00h    (i_iv[0 +: NK]),
        .scont_cr01h (i_cont[0 +: NK]),
        .sfoot_cr01h (i_foot[0 +: NK*NK]),
        .ssrc_cr01h  (i_src[0 +: NK*3*WR]),
        .sodst_cr01h (i_odst[0 +: NK*WR]),
        .pv_cr00h    (i_iv[NK +: NK]),
        .pcont_cr01h (i_cont[NK +: NK]),
        .pfoot_cr01h (i_foot[NK*NK +: NK*NK]),
        .popc_cr01h  (i_opc[NK*OW +: NK*OW]),
        .pdrw_cr01h  (i_drw[NK*2 +: NK*2]),
        .psrc_cr01h  (i_src[NK*3*WR +: NK*3*WR]),
        .r2v_cr00h   (i_iv[8]),
        .r2row_cr01h (i_odst[8*WR +: WR]),
        .rd_cr03h    (sl_rd[(K*NJ + J)*NR*32 +: NR*32]),
        .rv_cr02h    (i_iv[8]),
        .rr_row_cr03h({i_src[(8*3 + 1)*WR +: WR], i_src[(8*3 + 0)*WR +: WR]}),
        .rs_cr04h    (sl_rs[(K*NJ + J)*NRR*32 +: NRR*32]),
        .wr_v_cr00h  ({r_rwv, l_swv, l_lwv[K]}),
        .wr_row_cr01h({r_rwrow, l_swrow, l_lwrow[K*WR +: WR]}),
        .wr_sec_cr01h({r_rwsec, l_swsec, l_lwsec[K*NK +: NK]}),
        .wr_dat_cr02h(wdat),
        .wr_lm_cr02h (wlm),
        .mw_v_cr01h  (md_v),
        .mw_row_cr01h(md_row),
        .mw_wid_cr01h(md_wid),
        .mw_pos_cr01h(md_pos),
        .mw_lm_cr01h (mlm),
        .mw_dat_cr02h(mdat),
        .g2_v_cr00h  (g_r2v),
        .g2_row_cr01h(g_r2row),
        .ropc_cr01h  (i_opc[8*OW +: OW]),
        .rmrg_cr01h  (i_mrg[8]),
        .gw_v_cr00h  (g_rwv),
        .gw_sel_cr01h(g_rwsel),
        .gw_row_cr01h(g_rwrow),
        .gw_dat_cr02h(gdat)
      );
      // Its reads, to their readers' layouts (bit reorders only).
      for (genvar i = 0; i < 4; i++) begin : g_o
        for (genvar p = 0; p < 4; p++) begin : g_l
          assign ln_rd[((K*4 + p)*N + 4*J + i)*8 +: 8] = sl_rd[((K*NJ + J)*NR + p)*32 + 8*i +: 8];
        end
        for (genvar m = 0; m < 3; m++) begin : g_mm
          assign mm_rd[((K*3 + m)*N + 4*J + i)*8 +: 8] = sl_rd[((K*NJ + J)*NR + 4 + m)*32 + 8*i +: 8];
        end
        assign r2_rd[(4*J + i)*32 + 8*K +: 8] = sl_rd[((K*NJ + J)*NR + 7)*32 + 8*i +: 8];
        assign r0_rs[(4*J + i)*32 + 8*K +: 8] = sl_rs[((K*NJ + J)*NRR + 0)*32 + 8*i +: 8];
        assign r1_rs[(4*J + i)*32 + 8*K +: 8] = sl_rs[((K*NJ + J)*NRR + 1)*32 + 8*i +: 8];
      end
    end
  end

  // ---- rcu_pred: the predicate file and the guard path -----------------------
  // Merge ports: PL 0-3 (lane ops), PR 4 (R), PC 5-8 (predicate-only copies),
  // PG 9-12 (restore's row 16).
  rcu_pred u_pred (
    .rcu_core_clk(gclk),
    .rst_n      (rst_n),
    .iv_cr01h   (i_iv),
    .lgu_cr01h  (i_lgu[8]),
    .lgp_cr01h  (i_lgp[8*WP +: WP]),
    .gd_cr02h   (i_gd),
    .ng_cr02h   (i_ng),
    .im_cr02h   (i_im),
    .opc_cr02h  (i_opc),
    .cont_cr02h (i_cont),
    .drw_cr02h  (i_drw),
    .swe_cr02h  (i_pwe[0 +: NK]),
    .sdst_cr02h (i_dst[0 +: NK*WR]),
    .rimm_cr02h (i_imm[8*32 +: 2*WP + 2]),
    .ft_cr02h   (i_foot[0 +: NK*NK]),
    .act_cr03h  (p_act),
    .busy_cr03h (p_busy),
    .gv_cr03h   (p_gv),
    .pst_cr03h  (p_pst),
    .rpa_cr03h  (p_rpa),
    .rpb_cr03h  (p_rpb),
    .low_cr03h  (p_low),
    .lbt_cr03h  (p_lbt),
    .lbm_cr03h  (p_lbm),
    .spb_cr03h  (p_spb),
    .mv_cr01h   (md_v),
    .mwe_cr01h  (md_pwe),
    .mp_cr01h   (md_pp),
    .mam_cr01h  (md_am),
    .mr_cr02h   (md_pr),
    .qv_cr00h   ({{NK{g_gv}}, l_pcv, r_prv, l_plv}),
    .qrow_cr01h ({g_grow, l_pcrow, r_prrow, l_plrow}),
    .qorow_cr01h({{NK*WP{1'b0}}, l_pcorow, r_prorow, l_plorow}),
    .qmrg_cr01h ({{NK{1'b0}}, {NK{1'b1}}, r_prmrg, l_plmrg}),
    .qm_cr02h   ({{NK*N{1'b1}}, l_pcm, {N{1'b1}}, {NK*N{1'b1}}}),
    .qmm_cr02h  ({{NK*N{1'b1}}, {NK*N{1'b0}}, r_prmm, l_plmm}),
    .qval_cr02h ({g_gdat, {NK*N{1'b0}}, r_prval, pl_val}),
    .dv_cr00h   (g_dv),
    .drow_cr01h (g_drow),
    .dq_cr02h   (p_dq)
  );

  // ---- rcu_r: the R pipe -------------------------------------------------------
  rcu_r u_r (
    .rcu_core_clk(gclk),
    .rst_n        (rst_n),
    .iv_cr01h     (i_iv[8]),
    .opc_cr02h    (i_opc[8*OW +: OW]),
    .tag_cr02h    (i_tag[8*WT +: WT]),
    .drow_cr02h   (i_drw[8*2 +: 2]),
    .imask_cr02h  (i_im[8*N +: N]),
    .imm_cr02h    (i_imm[8*32 +: 32]),
    .dst_cr02h    (i_dst[8*WR +: WR]),
    .dpos_cr02h   (i_dpos[8*2 +: 2]),
    .dwid_cr02h   (i_dwid[8*2 +: 2]),
    .opos_cr02h   (i_opos[8*2 +: 2]),
    .spos_cr02h   (i_spos[8*6 +: 4]),
    .swid_cr02h   (i_swid[8*6 +: 4]),
    .pd_cr02h     (i_pd[8*WP +: WP]),
    .pold_cr02h   (i_pod[8*WP +: WP]),
    .mrg_cr02h    (i_mrg[8]),
    .pwe_cr02h    (i_pwe[8]),
    .rs0_cr03h    (r0_rs),
    .rs1_cr03h    (r1_rs),
    .rd2_cr03h    (r2_rd),
    .act_cr03h    (p_act[8*N +: N]),
    .rpa_cr03h    (p_rpa),
    .rpb_cr03h    (p_rpb),
    .low_cr03h    (p_low),
    .busy_cr03h   (r_busy),
    .rw_v_cr02h   (r_rwv),
    .rw_row_cr03h (r_rwrow),
    .rw_sec_cr03h (r_rwsec),
    .rw_dat_cr04h (r_rwdat),
    .pr_v_cr02h   (r_prv),
    .pr_row_cr03h (r_prrow),
    .pr_mrg_cr03h (r_prmrg),
    .pr_orow_cr03h(r_prorow),
    .pr_val_cr04h (r_prval),
    .pr_mm_cr04h  (r_prmm),
    .dn_v_cr03h   (r_dnv),
    .dn_tag_cr04h (r_dntag),
    .dn_row_cr04h (r_dnrow),
    .dn_bt_cr04h  (r_dnbt),
    .dn_bm_cr04h  (r_dnbm),
    .dn_aux_cr04h (r_dnaux)
  );

  // ---- rcu_lanes: S slots to the lanes, their write-back and done -------------
  rcu_lanes #(.COPIES(N)) u_lanes (
    .rcu_core_clk(gclk),
    .rst_n       (rst_n),
    .iw_cr01h    (ooe_rcu_issue_wake),
    .iv_cr01h    (i_iv[0 +: NK]),
    .lsec_cr01h  (i_lsec[0 +: NK*NK]),
    .lsrc_cr01h  (i_lsrc[0 +: NK*3]),
    .limm_cr01h  (i_limm[0 +: NK]),
    .lmrg_cr01h  (i_lmrg[0 +: NK]),
    .cont_cr02h  (i_cont[0 +: NK]),
    .foot_cr02h  (i_foot[0 +: NK*NK]),
    .opc_cr02h   (i_opc[0 +: NK*OW]),
    .imm_cr02h   (i_imm[0 +: NK*32]),
    .src_cr02h   (i_src[0 +: NK*3*WR]),
    .spos_cr02h  (i_spos[0 +: NK*6]),
    .swid_cr02h  (i_swid[0 +: NK*6]),
    .dst_cr02h   (i_dst[0 +: NK*WR]),
    .odst_cr02h  (i_odst[0 +: NK*WR]),
    .dpos_cr02h  (i_dpos[0 +: NK*2]),
    .dwid_cr02h  (i_dwid[0 +: NK*2]),
    .opos_cr02h  (i_opos[0 +: NK*2]),
    .mrg_cr02h   (i_mrg[0 +: NK]),
    .pwe_cr02h   (i_pwe[0 +: NK]),
    .pd_cr02h    (i_pd[0 +: NK*WP]),
    .pod_cr02h   (i_pod[0 +: NK*WP]),
    .tag_cr02h   (i_tag[0 +: NK*WT]),
    .drow_cr02h  (i_drw[0 +: NK*2]),
    .acta_cr03h  (p_act[0 +: NK*N]),
    .gv_cr03h    (p_gv),
    .rd_cr03h    (ln_rd),
    .lrv_cr07h   (lr_v),
    .lsv_cr08h   (lr_sv),
    .lwk_cr02h   (l_wk),
    .busy_cr03h  (l_busy),
    .dbusy_cr03h (l_dbusy),
    .lv_cr03h    (l_v),
    .sen_cr03h   (l_sen),
    .sop_cr04h   (l_sop),
    .opd_cr04h   (l_opd),
    .sown_cr04h  (l_sown),
    .spd_cr04h   (l_spd),
    .sopos_cr04h (l_sopos),
    .sowid_cr04h (l_sowid),
    .sdpos_cr04h (l_sdpos),
    .sdwid_cr04h (l_sdwid),
    .sbyp_cr04h  (l_sbyp),
    .lwv_cr06h   (l_lwv),
    .lwrow_cr07h (l_lwrow),
    .lwsec_cr07h (l_lwsec),
    .lwlm_cr08h  (l_lwlm),
    .plv_cr06h   (l_plv),
    .plrow_cr07h (l_plrow),
    .plorow_cr07h(l_plorow),
    .plmrg_cr07h (l_plmrg),
    .plmm_cr08h  (l_plmm),
    .pcv_cr02h   (l_pcv),
    .pcrow_cr03h (l_pcrow),
    .pcorow_cr03h(l_pcorow),
    .pcm_cr04h   (l_pcm),
    .swv_cr11h   (l_swv),
    .swrow_cr12h (l_swrow),
    .swsec_cr12h (l_swsec),
    .dnv_cr08h   (l_dnv),
    .dntag_cr09h (l_dntag),
    .dnrow_cr09h (l_dnrow),
    .sdv_cr13h   (l_sdv),
    .sdtag_cr14h (l_sdtag),
    .sdrow_cr14h (l_sdrow)
  );

  // ---- rcu_mem: P slots' operands to MIU ---------------------------------------
  rcu_mem #(.COPIES(N)) u_mem (
    .rcu_core_clk(gclk),
    .rst_n      (rst_n),
    .iw_cr01h   (ooe_rcu_issue_wake),
    .iv_cr01h   (i_iv[NK +: NK]),
    .lsrc_cr01h (i_lsrc[NK*3 +: NK*3]),
    .opc_cr02h  (i_opc[NK*OW +: NK*OW]),
    .cont_cr02h (i_cont[NK +: NK]),
    .drw_cr02h  (i_drw[NK*2 +: NK*2]),
    .foot_cr02h (i_foot[NK*NK +: NK*NK]),
    .spos_cr02h (i_spos[NK*6 +: NK*6]),
    .swid_cr02h (i_swid[NK*6 +: NK*6]),
    .tag_cr02h  (i_tag[NK*WT +: NK*WT]),
    .act_cr03h  (p_act[NK*N +: NK*N]),
    .pst_cr03h  (p_pst),
    .rd_cr03h   (mm_rd),
    .mwk_cr02h  (m_wk),
    .busy_cr03h (m_busy),
    .mv_cr03h   (m_v),
    .mtag_cr04h (m_tag),
    .mam_cr04h  (m_am),
    .mbase_cr04h(m_base),
    .midx_cr04h (m_idx),
    .msd_cr04h  (m_sd)
  );

  // ---- rcu_mig: migration --------------------------------------------------------
  rcu_mig u_mig (
    .rcu_core_clk(gclk),
    .rst_n      (rst_n),
    .mv_cr00h   (ooe_rcu_map_valid),
    .mw_cr01h   (ooe_rcu_map_payload.warp_id),
    .md_cr01h   (ooe_rcu_map_payload.direction),
    .mg_cr01h   (ooe_rcu_map_payload.gpr_map),
    .mp_cr01h   (ooe_rcu_map_payload.pred_map),
    .mcr_cr02h  (g_mcr),
    .cv_cr00h   (rau_rcu_mig_valid),
    .cw_cr01h   (rau_rcu_mig_payload.warp_id),
    .cd_cr01h   (rau_rcu_mig_payload.direction),
    .ccr_cr02h  (g_ccr),
    .pv_cr00h   (pca_rcu_mig_valid),
    .pw_cr01h   (pca_rcu_mig_payload.warp_id),
    .prow_cr01h (pca_rcu_mig_payload.mig_row),
    .pdat_cr01h (pca_rcu_mig_payload.row_data),
    .pcr_cr04h  (g_pcr),
    .ost_cr02h  (rcu_pca_mig_stall),
    .ocr_cr01h  (rcu_pca_mig_credit),
    .ov_cr03h   (g_ov),
    .ow_cr04h   (g_ow),
    .orow_cr04h (g_orow),
    .odat_cr04h (g_odat),
    .owk_cr03h  (g_owk),
    .kv_cr00h   (kill_valid),
    .km_cr01h   (kill_warp_mask),
    .quiet_cr02h(g_quiet),
    .busy_cr02h (g_busy),
    .riv_cr01h  (i_iv[8]),
    .ropc_cr02h (i_opc[8*OW +: OW]),
    .rmrg_cr02h (i_mrg[8]),
    .r2v_cr01h  (g_r2v),
    .r2row_cr02h(g_r2row),
    .rd2_cr03h  (r2_rd),
    .dv_cr01h   (g_dv),
    .drow_cr02h (g_drow),
    .dq_cr03h   (p_dq),
    .rwv_cr02h  (g_rwv),
    .rwsel_cr03h(g_rwsel),
    .rwrow_cr03h(g_rwrow),
    .rwdat_cr04h(g_rwdat),
    .gv_cr02h   (g_gv),
    .grow_cr03h (g_grow),
    .gdat_cr04h (g_gdat)
  );

  // ---- rcu_kill: kill, the inbound credits, done's wake and the block's idle ---
  rcu_kill u_kill (
    .rcu_core_clk  (gclk),
    .rst_n         (rst_n),
    .kv_cr00h      (kill_valid),
    .kep_cr01h     (kill_epoch),
    .mq_cr01h      (g_quiet),
    .kack_cr02h    (kill_ack),
    .kaep_cr02h    (kill_ack_epoch),
    .iv_cr00h      (i_iv),
    .lv_cr00h      (lr_v),
    .mv_cr00h      (md_v),
    .cr_cr01h      (k_cr),
    .dbusy_cr00h   ({r_busy, l_dbusy}),
    .busy_cr00h    ({1'b0, p_busy, m_busy, r_busy, l_busy, g_busy}),
    .dwake_cr01h   (k_dwake),
    .idle_cr01h    (idle),
    .csr_v_cr00h   (1'b0),
    .csr_done_cr01h(k_csr_done),
    .csr_data_cr01h(k_csr_data),
    .csr_cr_cr01h  (k_csr_cr)
  );

  // ---- The block's outputs: every one from a module's flop, or a constant ------
  assign csr_rsp = {k_csr_done, k_csr_data};
  assign csr_credit = k_csr_cr;
  assign ooe_rcu_map_credit = g_mcr;
  assign rau_rcu_mig_credit = g_ccr;
  assign pca_rcu_mig_credit = g_pcr;
  assign ooe_rcu_map_stall = 1'b0;
  assign rau_rcu_mig_stall = 1'b0;
  assign pca_rcu_mig_stall = 1'b0;
  assign rcu_pca_mig_valid = g_ov;
  assign rcu_pca_mig_payload.warp_id = g_ow;
  assign rcu_pca_mig_payload.mig_row = g_orow;
  assign rcu_pca_mig_payload.row_data = g_odat;
  assign rcu_pca_mig_wake = g_owk;
  assign rcu_ooe_done_wake = k_dwake;
  assign rcu_miu_addr_wake = m_wk;

  assign ooe_rcu_issue_s0_credit = k_cr[0];
  assign ooe_rcu_issue_s0_stall = 1'b0;
  assign ooe_rcu_issue_s1_credit = k_cr[1];
  assign ooe_rcu_issue_s1_stall = 1'b0;
  assign ooe_rcu_issue_s2_credit = k_cr[2];
  assign ooe_rcu_issue_s2_stall = 1'b0;
  assign ooe_rcu_issue_s3_credit = k_cr[3];
  assign ooe_rcu_issue_s3_stall = 1'b0;
  assign ooe_rcu_issue_s4_credit = k_cr[4];
  assign ooe_rcu_issue_s4_stall = 1'b0;
  assign ooe_rcu_issue_s5_credit = k_cr[5];
  assign ooe_rcu_issue_s5_stall = 1'b0;
  assign ooe_rcu_issue_s6_credit = k_cr[6];
  assign ooe_rcu_issue_s6_stall = 1'b0;
  assign ooe_rcu_issue_s7_credit = k_cr[7];
  assign ooe_rcu_issue_s7_stall = 1'b0;
  assign ooe_rcu_issue_s8_credit = k_cr[8];
  assign ooe_rcu_issue_s8_stall = 1'b0;
  assign rcu_lane_ops_c00_valid = l_v[0];
  assign rcu_lane_ops_c00_wake = l_wk[0];
  assign rcu_lane_ops_c00_payload.sec_opcode = l_sop[0*NK*WO +: NK*WO];
  assign rcu_lane_ops_c00_payload.operand = l_opd[0*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c00_payload.merge_data = l_opd[0*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c00_payload.section_en = l_sen[0*NK +: NK];
  assign rcu_lane_ops_c00_payload.sec_owner = l_sown[0*NK*2 +: NK*2];
  assign rcu_lane_ops_c00_payload.sec_pred_bit = p_spb[0*NK +: NK];
  assign rcu_lane_ops_c00_payload.sec_pred_data = l_spd[0*NK +: NK];
  assign rcu_lane_ops_c00_payload.sec_opnd_pos = l_sopos[0*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c00_payload.sec_opnd_width = l_sowid[0*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c00_payload.sec_dst_pos = l_sdpos[0*NK*2 +: NK*2];
  assign rcu_lane_ops_c00_payload.sec_dst_width = l_sdwid[0*NK*2 +: NK*2];
  assign rcu_lane_ops_c00_payload.operand_byp = l_sbyp[0*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c00_credit = k_cr[NS + 0];
  assign lane_rcu_res_c00_stall = 1'b0;
  assign rcu_lane_ops_c01_valid = l_v[1];
  assign rcu_lane_ops_c01_wake = l_wk[0];
  assign rcu_lane_ops_c01_payload.sec_opcode = l_sop[1*NK*WO +: NK*WO];
  assign rcu_lane_ops_c01_payload.operand = l_opd[1*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c01_payload.merge_data = l_opd[1*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c01_payload.section_en = l_sen[1*NK +: NK];
  assign rcu_lane_ops_c01_payload.sec_owner = l_sown[1*NK*2 +: NK*2];
  assign rcu_lane_ops_c01_payload.sec_pred_bit = p_spb[1*NK +: NK];
  assign rcu_lane_ops_c01_payload.sec_pred_data = l_spd[1*NK +: NK];
  assign rcu_lane_ops_c01_payload.sec_opnd_pos = l_sopos[1*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c01_payload.sec_opnd_width = l_sowid[1*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c01_payload.sec_dst_pos = l_sdpos[1*NK*2 +: NK*2];
  assign rcu_lane_ops_c01_payload.sec_dst_width = l_sdwid[1*NK*2 +: NK*2];
  assign rcu_lane_ops_c01_payload.operand_byp = l_sbyp[1*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c01_credit = k_cr[NS + 1];
  assign lane_rcu_res_c01_stall = 1'b0;
  assign rcu_lane_ops_c02_valid = l_v[2];
  assign rcu_lane_ops_c02_wake = l_wk[0];
  assign rcu_lane_ops_c02_payload.sec_opcode = l_sop[2*NK*WO +: NK*WO];
  assign rcu_lane_ops_c02_payload.operand = l_opd[2*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c02_payload.merge_data = l_opd[2*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c02_payload.section_en = l_sen[2*NK +: NK];
  assign rcu_lane_ops_c02_payload.sec_owner = l_sown[2*NK*2 +: NK*2];
  assign rcu_lane_ops_c02_payload.sec_pred_bit = p_spb[2*NK +: NK];
  assign rcu_lane_ops_c02_payload.sec_pred_data = l_spd[2*NK +: NK];
  assign rcu_lane_ops_c02_payload.sec_opnd_pos = l_sopos[2*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c02_payload.sec_opnd_width = l_sowid[2*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c02_payload.sec_dst_pos = l_sdpos[2*NK*2 +: NK*2];
  assign rcu_lane_ops_c02_payload.sec_dst_width = l_sdwid[2*NK*2 +: NK*2];
  assign rcu_lane_ops_c02_payload.operand_byp = l_sbyp[2*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c02_credit = k_cr[NS + 2];
  assign lane_rcu_res_c02_stall = 1'b0;
  assign rcu_lane_ops_c03_valid = l_v[3];
  assign rcu_lane_ops_c03_wake = l_wk[0];
  assign rcu_lane_ops_c03_payload.sec_opcode = l_sop[3*NK*WO +: NK*WO];
  assign rcu_lane_ops_c03_payload.operand = l_opd[3*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c03_payload.merge_data = l_opd[3*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c03_payload.section_en = l_sen[3*NK +: NK];
  assign rcu_lane_ops_c03_payload.sec_owner = l_sown[3*NK*2 +: NK*2];
  assign rcu_lane_ops_c03_payload.sec_pred_bit = p_spb[3*NK +: NK];
  assign rcu_lane_ops_c03_payload.sec_pred_data = l_spd[3*NK +: NK];
  assign rcu_lane_ops_c03_payload.sec_opnd_pos = l_sopos[3*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c03_payload.sec_opnd_width = l_sowid[3*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c03_payload.sec_dst_pos = l_sdpos[3*NK*2 +: NK*2];
  assign rcu_lane_ops_c03_payload.sec_dst_width = l_sdwid[3*NK*2 +: NK*2];
  assign rcu_lane_ops_c03_payload.operand_byp = l_sbyp[3*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c03_credit = k_cr[NS + 3];
  assign lane_rcu_res_c03_stall = 1'b0;
  assign rcu_lane_ops_c04_valid = l_v[4];
  assign rcu_lane_ops_c04_wake = l_wk[0];
  assign rcu_lane_ops_c04_payload.sec_opcode = l_sop[4*NK*WO +: NK*WO];
  assign rcu_lane_ops_c04_payload.operand = l_opd[4*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c04_payload.merge_data = l_opd[4*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c04_payload.section_en = l_sen[4*NK +: NK];
  assign rcu_lane_ops_c04_payload.sec_owner = l_sown[4*NK*2 +: NK*2];
  assign rcu_lane_ops_c04_payload.sec_pred_bit = p_spb[4*NK +: NK];
  assign rcu_lane_ops_c04_payload.sec_pred_data = l_spd[4*NK +: NK];
  assign rcu_lane_ops_c04_payload.sec_opnd_pos = l_sopos[4*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c04_payload.sec_opnd_width = l_sowid[4*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c04_payload.sec_dst_pos = l_sdpos[4*NK*2 +: NK*2];
  assign rcu_lane_ops_c04_payload.sec_dst_width = l_sdwid[4*NK*2 +: NK*2];
  assign rcu_lane_ops_c04_payload.operand_byp = l_sbyp[4*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c04_credit = k_cr[NS + 4];
  assign lane_rcu_res_c04_stall = 1'b0;
  assign rcu_lane_ops_c05_valid = l_v[5];
  assign rcu_lane_ops_c05_wake = l_wk[0];
  assign rcu_lane_ops_c05_payload.sec_opcode = l_sop[5*NK*WO +: NK*WO];
  assign rcu_lane_ops_c05_payload.operand = l_opd[5*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c05_payload.merge_data = l_opd[5*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c05_payload.section_en = l_sen[5*NK +: NK];
  assign rcu_lane_ops_c05_payload.sec_owner = l_sown[5*NK*2 +: NK*2];
  assign rcu_lane_ops_c05_payload.sec_pred_bit = p_spb[5*NK +: NK];
  assign rcu_lane_ops_c05_payload.sec_pred_data = l_spd[5*NK +: NK];
  assign rcu_lane_ops_c05_payload.sec_opnd_pos = l_sopos[5*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c05_payload.sec_opnd_width = l_sowid[5*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c05_payload.sec_dst_pos = l_sdpos[5*NK*2 +: NK*2];
  assign rcu_lane_ops_c05_payload.sec_dst_width = l_sdwid[5*NK*2 +: NK*2];
  assign rcu_lane_ops_c05_payload.operand_byp = l_sbyp[5*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c05_credit = k_cr[NS + 5];
  assign lane_rcu_res_c05_stall = 1'b0;
  assign rcu_lane_ops_c06_valid = l_v[6];
  assign rcu_lane_ops_c06_wake = l_wk[0];
  assign rcu_lane_ops_c06_payload.sec_opcode = l_sop[6*NK*WO +: NK*WO];
  assign rcu_lane_ops_c06_payload.operand = l_opd[6*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c06_payload.merge_data = l_opd[6*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c06_payload.section_en = l_sen[6*NK +: NK];
  assign rcu_lane_ops_c06_payload.sec_owner = l_sown[6*NK*2 +: NK*2];
  assign rcu_lane_ops_c06_payload.sec_pred_bit = p_spb[6*NK +: NK];
  assign rcu_lane_ops_c06_payload.sec_pred_data = l_spd[6*NK +: NK];
  assign rcu_lane_ops_c06_payload.sec_opnd_pos = l_sopos[6*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c06_payload.sec_opnd_width = l_sowid[6*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c06_payload.sec_dst_pos = l_sdpos[6*NK*2 +: NK*2];
  assign rcu_lane_ops_c06_payload.sec_dst_width = l_sdwid[6*NK*2 +: NK*2];
  assign rcu_lane_ops_c06_payload.operand_byp = l_sbyp[6*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c06_credit = k_cr[NS + 6];
  assign lane_rcu_res_c06_stall = 1'b0;
  assign rcu_lane_ops_c07_valid = l_v[7];
  assign rcu_lane_ops_c07_wake = l_wk[0];
  assign rcu_lane_ops_c07_payload.sec_opcode = l_sop[7*NK*WO +: NK*WO];
  assign rcu_lane_ops_c07_payload.operand = l_opd[7*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c07_payload.merge_data = l_opd[7*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c07_payload.section_en = l_sen[7*NK +: NK];
  assign rcu_lane_ops_c07_payload.sec_owner = l_sown[7*NK*2 +: NK*2];
  assign rcu_lane_ops_c07_payload.sec_pred_bit = p_spb[7*NK +: NK];
  assign rcu_lane_ops_c07_payload.sec_pred_data = l_spd[7*NK +: NK];
  assign rcu_lane_ops_c07_payload.sec_opnd_pos = l_sopos[7*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c07_payload.sec_opnd_width = l_sowid[7*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c07_payload.sec_dst_pos = l_sdpos[7*NK*2 +: NK*2];
  assign rcu_lane_ops_c07_payload.sec_dst_width = l_sdwid[7*NK*2 +: NK*2];
  assign rcu_lane_ops_c07_payload.operand_byp = l_sbyp[7*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c07_credit = k_cr[NS + 7];
  assign lane_rcu_res_c07_stall = 1'b0;
  assign rcu_lane_ops_c08_valid = l_v[8];
  assign rcu_lane_ops_c08_wake = l_wk[1];
  assign rcu_lane_ops_c08_payload.sec_opcode = l_sop[8*NK*WO +: NK*WO];
  assign rcu_lane_ops_c08_payload.operand = l_opd[8*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c08_payload.merge_data = l_opd[8*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c08_payload.section_en = l_sen[8*NK +: NK];
  assign rcu_lane_ops_c08_payload.sec_owner = l_sown[8*NK*2 +: NK*2];
  assign rcu_lane_ops_c08_payload.sec_pred_bit = p_spb[8*NK +: NK];
  assign rcu_lane_ops_c08_payload.sec_pred_data = l_spd[8*NK +: NK];
  assign rcu_lane_ops_c08_payload.sec_opnd_pos = l_sopos[8*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c08_payload.sec_opnd_width = l_sowid[8*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c08_payload.sec_dst_pos = l_sdpos[8*NK*2 +: NK*2];
  assign rcu_lane_ops_c08_payload.sec_dst_width = l_sdwid[8*NK*2 +: NK*2];
  assign rcu_lane_ops_c08_payload.operand_byp = l_sbyp[8*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c08_credit = k_cr[NS + 8];
  assign lane_rcu_res_c08_stall = 1'b0;
  assign rcu_lane_ops_c09_valid = l_v[9];
  assign rcu_lane_ops_c09_wake = l_wk[1];
  assign rcu_lane_ops_c09_payload.sec_opcode = l_sop[9*NK*WO +: NK*WO];
  assign rcu_lane_ops_c09_payload.operand = l_opd[9*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c09_payload.merge_data = l_opd[9*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c09_payload.section_en = l_sen[9*NK +: NK];
  assign rcu_lane_ops_c09_payload.sec_owner = l_sown[9*NK*2 +: NK*2];
  assign rcu_lane_ops_c09_payload.sec_pred_bit = p_spb[9*NK +: NK];
  assign rcu_lane_ops_c09_payload.sec_pred_data = l_spd[9*NK +: NK];
  assign rcu_lane_ops_c09_payload.sec_opnd_pos = l_sopos[9*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c09_payload.sec_opnd_width = l_sowid[9*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c09_payload.sec_dst_pos = l_sdpos[9*NK*2 +: NK*2];
  assign rcu_lane_ops_c09_payload.sec_dst_width = l_sdwid[9*NK*2 +: NK*2];
  assign rcu_lane_ops_c09_payload.operand_byp = l_sbyp[9*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c09_credit = k_cr[NS + 9];
  assign lane_rcu_res_c09_stall = 1'b0;
  assign rcu_lane_ops_c10_valid = l_v[10];
  assign rcu_lane_ops_c10_wake = l_wk[1];
  assign rcu_lane_ops_c10_payload.sec_opcode = l_sop[10*NK*WO +: NK*WO];
  assign rcu_lane_ops_c10_payload.operand = l_opd[10*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c10_payload.merge_data = l_opd[10*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c10_payload.section_en = l_sen[10*NK +: NK];
  assign rcu_lane_ops_c10_payload.sec_owner = l_sown[10*NK*2 +: NK*2];
  assign rcu_lane_ops_c10_payload.sec_pred_bit = p_spb[10*NK +: NK];
  assign rcu_lane_ops_c10_payload.sec_pred_data = l_spd[10*NK +: NK];
  assign rcu_lane_ops_c10_payload.sec_opnd_pos = l_sopos[10*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c10_payload.sec_opnd_width = l_sowid[10*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c10_payload.sec_dst_pos = l_sdpos[10*NK*2 +: NK*2];
  assign rcu_lane_ops_c10_payload.sec_dst_width = l_sdwid[10*NK*2 +: NK*2];
  assign rcu_lane_ops_c10_payload.operand_byp = l_sbyp[10*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c10_credit = k_cr[NS + 10];
  assign lane_rcu_res_c10_stall = 1'b0;
  assign rcu_lane_ops_c11_valid = l_v[11];
  assign rcu_lane_ops_c11_wake = l_wk[1];
  assign rcu_lane_ops_c11_payload.sec_opcode = l_sop[11*NK*WO +: NK*WO];
  assign rcu_lane_ops_c11_payload.operand = l_opd[11*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c11_payload.merge_data = l_opd[11*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c11_payload.section_en = l_sen[11*NK +: NK];
  assign rcu_lane_ops_c11_payload.sec_owner = l_sown[11*NK*2 +: NK*2];
  assign rcu_lane_ops_c11_payload.sec_pred_bit = p_spb[11*NK +: NK];
  assign rcu_lane_ops_c11_payload.sec_pred_data = l_spd[11*NK +: NK];
  assign rcu_lane_ops_c11_payload.sec_opnd_pos = l_sopos[11*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c11_payload.sec_opnd_width = l_sowid[11*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c11_payload.sec_dst_pos = l_sdpos[11*NK*2 +: NK*2];
  assign rcu_lane_ops_c11_payload.sec_dst_width = l_sdwid[11*NK*2 +: NK*2];
  assign rcu_lane_ops_c11_payload.operand_byp = l_sbyp[11*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c11_credit = k_cr[NS + 11];
  assign lane_rcu_res_c11_stall = 1'b0;
  assign rcu_lane_ops_c12_valid = l_v[12];
  assign rcu_lane_ops_c12_wake = l_wk[1];
  assign rcu_lane_ops_c12_payload.sec_opcode = l_sop[12*NK*WO +: NK*WO];
  assign rcu_lane_ops_c12_payload.operand = l_opd[12*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c12_payload.merge_data = l_opd[12*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c12_payload.section_en = l_sen[12*NK +: NK];
  assign rcu_lane_ops_c12_payload.sec_owner = l_sown[12*NK*2 +: NK*2];
  assign rcu_lane_ops_c12_payload.sec_pred_bit = p_spb[12*NK +: NK];
  assign rcu_lane_ops_c12_payload.sec_pred_data = l_spd[12*NK +: NK];
  assign rcu_lane_ops_c12_payload.sec_opnd_pos = l_sopos[12*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c12_payload.sec_opnd_width = l_sowid[12*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c12_payload.sec_dst_pos = l_sdpos[12*NK*2 +: NK*2];
  assign rcu_lane_ops_c12_payload.sec_dst_width = l_sdwid[12*NK*2 +: NK*2];
  assign rcu_lane_ops_c12_payload.operand_byp = l_sbyp[12*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c12_credit = k_cr[NS + 12];
  assign lane_rcu_res_c12_stall = 1'b0;
  assign rcu_lane_ops_c13_valid = l_v[13];
  assign rcu_lane_ops_c13_wake = l_wk[1];
  assign rcu_lane_ops_c13_payload.sec_opcode = l_sop[13*NK*WO +: NK*WO];
  assign rcu_lane_ops_c13_payload.operand = l_opd[13*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c13_payload.merge_data = l_opd[13*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c13_payload.section_en = l_sen[13*NK +: NK];
  assign rcu_lane_ops_c13_payload.sec_owner = l_sown[13*NK*2 +: NK*2];
  assign rcu_lane_ops_c13_payload.sec_pred_bit = p_spb[13*NK +: NK];
  assign rcu_lane_ops_c13_payload.sec_pred_data = l_spd[13*NK +: NK];
  assign rcu_lane_ops_c13_payload.sec_opnd_pos = l_sopos[13*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c13_payload.sec_opnd_width = l_sowid[13*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c13_payload.sec_dst_pos = l_sdpos[13*NK*2 +: NK*2];
  assign rcu_lane_ops_c13_payload.sec_dst_width = l_sdwid[13*NK*2 +: NK*2];
  assign rcu_lane_ops_c13_payload.operand_byp = l_sbyp[13*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c13_credit = k_cr[NS + 13];
  assign lane_rcu_res_c13_stall = 1'b0;
  assign rcu_lane_ops_c14_valid = l_v[14];
  assign rcu_lane_ops_c14_wake = l_wk[1];
  assign rcu_lane_ops_c14_payload.sec_opcode = l_sop[14*NK*WO +: NK*WO];
  assign rcu_lane_ops_c14_payload.operand = l_opd[14*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c14_payload.merge_data = l_opd[14*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c14_payload.section_en = l_sen[14*NK +: NK];
  assign rcu_lane_ops_c14_payload.sec_owner = l_sown[14*NK*2 +: NK*2];
  assign rcu_lane_ops_c14_payload.sec_pred_bit = p_spb[14*NK +: NK];
  assign rcu_lane_ops_c14_payload.sec_pred_data = l_spd[14*NK +: NK];
  assign rcu_lane_ops_c14_payload.sec_opnd_pos = l_sopos[14*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c14_payload.sec_opnd_width = l_sowid[14*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c14_payload.sec_dst_pos = l_sdpos[14*NK*2 +: NK*2];
  assign rcu_lane_ops_c14_payload.sec_dst_width = l_sdwid[14*NK*2 +: NK*2];
  assign rcu_lane_ops_c14_payload.operand_byp = l_sbyp[14*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c14_credit = k_cr[NS + 14];
  assign lane_rcu_res_c14_stall = 1'b0;
  assign rcu_lane_ops_c15_valid = l_v[15];
  assign rcu_lane_ops_c15_wake = l_wk[1];
  assign rcu_lane_ops_c15_payload.sec_opcode = l_sop[15*NK*WO +: NK*WO];
  assign rcu_lane_ops_c15_payload.operand = l_opd[15*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c15_payload.merge_data = l_opd[15*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c15_payload.section_en = l_sen[15*NK +: NK];
  assign rcu_lane_ops_c15_payload.sec_owner = l_sown[15*NK*2 +: NK*2];
  assign rcu_lane_ops_c15_payload.sec_pred_bit = p_spb[15*NK +: NK];
  assign rcu_lane_ops_c15_payload.sec_pred_data = l_spd[15*NK +: NK];
  assign rcu_lane_ops_c15_payload.sec_opnd_pos = l_sopos[15*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c15_payload.sec_opnd_width = l_sowid[15*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c15_payload.sec_dst_pos = l_sdpos[15*NK*2 +: NK*2];
  assign rcu_lane_ops_c15_payload.sec_dst_width = l_sdwid[15*NK*2 +: NK*2];
  assign rcu_lane_ops_c15_payload.operand_byp = l_sbyp[15*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c15_credit = k_cr[NS + 15];
  assign lane_rcu_res_c15_stall = 1'b0;
  assign rcu_lane_ops_c16_valid = l_v[16];
  assign rcu_lane_ops_c16_wake = l_wk[2];
  assign rcu_lane_ops_c16_payload.sec_opcode = l_sop[16*NK*WO +: NK*WO];
  assign rcu_lane_ops_c16_payload.operand = l_opd[16*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c16_payload.merge_data = l_opd[16*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c16_payload.section_en = l_sen[16*NK +: NK];
  assign rcu_lane_ops_c16_payload.sec_owner = l_sown[16*NK*2 +: NK*2];
  assign rcu_lane_ops_c16_payload.sec_pred_bit = p_spb[16*NK +: NK];
  assign rcu_lane_ops_c16_payload.sec_pred_data = l_spd[16*NK +: NK];
  assign rcu_lane_ops_c16_payload.sec_opnd_pos = l_sopos[16*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c16_payload.sec_opnd_width = l_sowid[16*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c16_payload.sec_dst_pos = l_sdpos[16*NK*2 +: NK*2];
  assign rcu_lane_ops_c16_payload.sec_dst_width = l_sdwid[16*NK*2 +: NK*2];
  assign rcu_lane_ops_c16_payload.operand_byp = l_sbyp[16*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c16_credit = k_cr[NS + 16];
  assign lane_rcu_res_c16_stall = 1'b0;
  assign rcu_lane_ops_c17_valid = l_v[17];
  assign rcu_lane_ops_c17_wake = l_wk[2];
  assign rcu_lane_ops_c17_payload.sec_opcode = l_sop[17*NK*WO +: NK*WO];
  assign rcu_lane_ops_c17_payload.operand = l_opd[17*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c17_payload.merge_data = l_opd[17*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c17_payload.section_en = l_sen[17*NK +: NK];
  assign rcu_lane_ops_c17_payload.sec_owner = l_sown[17*NK*2 +: NK*2];
  assign rcu_lane_ops_c17_payload.sec_pred_bit = p_spb[17*NK +: NK];
  assign rcu_lane_ops_c17_payload.sec_pred_data = l_spd[17*NK +: NK];
  assign rcu_lane_ops_c17_payload.sec_opnd_pos = l_sopos[17*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c17_payload.sec_opnd_width = l_sowid[17*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c17_payload.sec_dst_pos = l_sdpos[17*NK*2 +: NK*2];
  assign rcu_lane_ops_c17_payload.sec_dst_width = l_sdwid[17*NK*2 +: NK*2];
  assign rcu_lane_ops_c17_payload.operand_byp = l_sbyp[17*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c17_credit = k_cr[NS + 17];
  assign lane_rcu_res_c17_stall = 1'b0;
  assign rcu_lane_ops_c18_valid = l_v[18];
  assign rcu_lane_ops_c18_wake = l_wk[2];
  assign rcu_lane_ops_c18_payload.sec_opcode = l_sop[18*NK*WO +: NK*WO];
  assign rcu_lane_ops_c18_payload.operand = l_opd[18*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c18_payload.merge_data = l_opd[18*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c18_payload.section_en = l_sen[18*NK +: NK];
  assign rcu_lane_ops_c18_payload.sec_owner = l_sown[18*NK*2 +: NK*2];
  assign rcu_lane_ops_c18_payload.sec_pred_bit = p_spb[18*NK +: NK];
  assign rcu_lane_ops_c18_payload.sec_pred_data = l_spd[18*NK +: NK];
  assign rcu_lane_ops_c18_payload.sec_opnd_pos = l_sopos[18*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c18_payload.sec_opnd_width = l_sowid[18*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c18_payload.sec_dst_pos = l_sdpos[18*NK*2 +: NK*2];
  assign rcu_lane_ops_c18_payload.sec_dst_width = l_sdwid[18*NK*2 +: NK*2];
  assign rcu_lane_ops_c18_payload.operand_byp = l_sbyp[18*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c18_credit = k_cr[NS + 18];
  assign lane_rcu_res_c18_stall = 1'b0;
  assign rcu_lane_ops_c19_valid = l_v[19];
  assign rcu_lane_ops_c19_wake = l_wk[2];
  assign rcu_lane_ops_c19_payload.sec_opcode = l_sop[19*NK*WO +: NK*WO];
  assign rcu_lane_ops_c19_payload.operand = l_opd[19*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c19_payload.merge_data = l_opd[19*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c19_payload.section_en = l_sen[19*NK +: NK];
  assign rcu_lane_ops_c19_payload.sec_owner = l_sown[19*NK*2 +: NK*2];
  assign rcu_lane_ops_c19_payload.sec_pred_bit = p_spb[19*NK +: NK];
  assign rcu_lane_ops_c19_payload.sec_pred_data = l_spd[19*NK +: NK];
  assign rcu_lane_ops_c19_payload.sec_opnd_pos = l_sopos[19*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c19_payload.sec_opnd_width = l_sowid[19*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c19_payload.sec_dst_pos = l_sdpos[19*NK*2 +: NK*2];
  assign rcu_lane_ops_c19_payload.sec_dst_width = l_sdwid[19*NK*2 +: NK*2];
  assign rcu_lane_ops_c19_payload.operand_byp = l_sbyp[19*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c19_credit = k_cr[NS + 19];
  assign lane_rcu_res_c19_stall = 1'b0;
  assign rcu_lane_ops_c20_valid = l_v[20];
  assign rcu_lane_ops_c20_wake = l_wk[2];
  assign rcu_lane_ops_c20_payload.sec_opcode = l_sop[20*NK*WO +: NK*WO];
  assign rcu_lane_ops_c20_payload.operand = l_opd[20*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c20_payload.merge_data = l_opd[20*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c20_payload.section_en = l_sen[20*NK +: NK];
  assign rcu_lane_ops_c20_payload.sec_owner = l_sown[20*NK*2 +: NK*2];
  assign rcu_lane_ops_c20_payload.sec_pred_bit = p_spb[20*NK +: NK];
  assign rcu_lane_ops_c20_payload.sec_pred_data = l_spd[20*NK +: NK];
  assign rcu_lane_ops_c20_payload.sec_opnd_pos = l_sopos[20*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c20_payload.sec_opnd_width = l_sowid[20*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c20_payload.sec_dst_pos = l_sdpos[20*NK*2 +: NK*2];
  assign rcu_lane_ops_c20_payload.sec_dst_width = l_sdwid[20*NK*2 +: NK*2];
  assign rcu_lane_ops_c20_payload.operand_byp = l_sbyp[20*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c20_credit = k_cr[NS + 20];
  assign lane_rcu_res_c20_stall = 1'b0;
  assign rcu_lane_ops_c21_valid = l_v[21];
  assign rcu_lane_ops_c21_wake = l_wk[2];
  assign rcu_lane_ops_c21_payload.sec_opcode = l_sop[21*NK*WO +: NK*WO];
  assign rcu_lane_ops_c21_payload.operand = l_opd[21*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c21_payload.merge_data = l_opd[21*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c21_payload.section_en = l_sen[21*NK +: NK];
  assign rcu_lane_ops_c21_payload.sec_owner = l_sown[21*NK*2 +: NK*2];
  assign rcu_lane_ops_c21_payload.sec_pred_bit = p_spb[21*NK +: NK];
  assign rcu_lane_ops_c21_payload.sec_pred_data = l_spd[21*NK +: NK];
  assign rcu_lane_ops_c21_payload.sec_opnd_pos = l_sopos[21*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c21_payload.sec_opnd_width = l_sowid[21*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c21_payload.sec_dst_pos = l_sdpos[21*NK*2 +: NK*2];
  assign rcu_lane_ops_c21_payload.sec_dst_width = l_sdwid[21*NK*2 +: NK*2];
  assign rcu_lane_ops_c21_payload.operand_byp = l_sbyp[21*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c21_credit = k_cr[NS + 21];
  assign lane_rcu_res_c21_stall = 1'b0;
  assign rcu_lane_ops_c22_valid = l_v[22];
  assign rcu_lane_ops_c22_wake = l_wk[2];
  assign rcu_lane_ops_c22_payload.sec_opcode = l_sop[22*NK*WO +: NK*WO];
  assign rcu_lane_ops_c22_payload.operand = l_opd[22*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c22_payload.merge_data = l_opd[22*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c22_payload.section_en = l_sen[22*NK +: NK];
  assign rcu_lane_ops_c22_payload.sec_owner = l_sown[22*NK*2 +: NK*2];
  assign rcu_lane_ops_c22_payload.sec_pred_bit = p_spb[22*NK +: NK];
  assign rcu_lane_ops_c22_payload.sec_pred_data = l_spd[22*NK +: NK];
  assign rcu_lane_ops_c22_payload.sec_opnd_pos = l_sopos[22*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c22_payload.sec_opnd_width = l_sowid[22*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c22_payload.sec_dst_pos = l_sdpos[22*NK*2 +: NK*2];
  assign rcu_lane_ops_c22_payload.sec_dst_width = l_sdwid[22*NK*2 +: NK*2];
  assign rcu_lane_ops_c22_payload.operand_byp = l_sbyp[22*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c22_credit = k_cr[NS + 22];
  assign lane_rcu_res_c22_stall = 1'b0;
  assign rcu_lane_ops_c23_valid = l_v[23];
  assign rcu_lane_ops_c23_wake = l_wk[2];
  assign rcu_lane_ops_c23_payload.sec_opcode = l_sop[23*NK*WO +: NK*WO];
  assign rcu_lane_ops_c23_payload.operand = l_opd[23*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c23_payload.merge_data = l_opd[23*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c23_payload.section_en = l_sen[23*NK +: NK];
  assign rcu_lane_ops_c23_payload.sec_owner = l_sown[23*NK*2 +: NK*2];
  assign rcu_lane_ops_c23_payload.sec_pred_bit = p_spb[23*NK +: NK];
  assign rcu_lane_ops_c23_payload.sec_pred_data = l_spd[23*NK +: NK];
  assign rcu_lane_ops_c23_payload.sec_opnd_pos = l_sopos[23*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c23_payload.sec_opnd_width = l_sowid[23*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c23_payload.sec_dst_pos = l_sdpos[23*NK*2 +: NK*2];
  assign rcu_lane_ops_c23_payload.sec_dst_width = l_sdwid[23*NK*2 +: NK*2];
  assign rcu_lane_ops_c23_payload.operand_byp = l_sbyp[23*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c23_credit = k_cr[NS + 23];
  assign lane_rcu_res_c23_stall = 1'b0;
  assign rcu_lane_ops_c24_valid = l_v[24];
  assign rcu_lane_ops_c24_wake = l_wk[3];
  assign rcu_lane_ops_c24_payload.sec_opcode = l_sop[24*NK*WO +: NK*WO];
  assign rcu_lane_ops_c24_payload.operand = l_opd[24*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c24_payload.merge_data = l_opd[24*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c24_payload.section_en = l_sen[24*NK +: NK];
  assign rcu_lane_ops_c24_payload.sec_owner = l_sown[24*NK*2 +: NK*2];
  assign rcu_lane_ops_c24_payload.sec_pred_bit = p_spb[24*NK +: NK];
  assign rcu_lane_ops_c24_payload.sec_pred_data = l_spd[24*NK +: NK];
  assign rcu_lane_ops_c24_payload.sec_opnd_pos = l_sopos[24*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c24_payload.sec_opnd_width = l_sowid[24*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c24_payload.sec_dst_pos = l_sdpos[24*NK*2 +: NK*2];
  assign rcu_lane_ops_c24_payload.sec_dst_width = l_sdwid[24*NK*2 +: NK*2];
  assign rcu_lane_ops_c24_payload.operand_byp = l_sbyp[24*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c24_credit = k_cr[NS + 24];
  assign lane_rcu_res_c24_stall = 1'b0;
  assign rcu_lane_ops_c25_valid = l_v[25];
  assign rcu_lane_ops_c25_wake = l_wk[3];
  assign rcu_lane_ops_c25_payload.sec_opcode = l_sop[25*NK*WO +: NK*WO];
  assign rcu_lane_ops_c25_payload.operand = l_opd[25*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c25_payload.merge_data = l_opd[25*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c25_payload.section_en = l_sen[25*NK +: NK];
  assign rcu_lane_ops_c25_payload.sec_owner = l_sown[25*NK*2 +: NK*2];
  assign rcu_lane_ops_c25_payload.sec_pred_bit = p_spb[25*NK +: NK];
  assign rcu_lane_ops_c25_payload.sec_pred_data = l_spd[25*NK +: NK];
  assign rcu_lane_ops_c25_payload.sec_opnd_pos = l_sopos[25*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c25_payload.sec_opnd_width = l_sowid[25*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c25_payload.sec_dst_pos = l_sdpos[25*NK*2 +: NK*2];
  assign rcu_lane_ops_c25_payload.sec_dst_width = l_sdwid[25*NK*2 +: NK*2];
  assign rcu_lane_ops_c25_payload.operand_byp = l_sbyp[25*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c25_credit = k_cr[NS + 25];
  assign lane_rcu_res_c25_stall = 1'b0;
  assign rcu_lane_ops_c26_valid = l_v[26];
  assign rcu_lane_ops_c26_wake = l_wk[3];
  assign rcu_lane_ops_c26_payload.sec_opcode = l_sop[26*NK*WO +: NK*WO];
  assign rcu_lane_ops_c26_payload.operand = l_opd[26*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c26_payload.merge_data = l_opd[26*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c26_payload.section_en = l_sen[26*NK +: NK];
  assign rcu_lane_ops_c26_payload.sec_owner = l_sown[26*NK*2 +: NK*2];
  assign rcu_lane_ops_c26_payload.sec_pred_bit = p_spb[26*NK +: NK];
  assign rcu_lane_ops_c26_payload.sec_pred_data = l_spd[26*NK +: NK];
  assign rcu_lane_ops_c26_payload.sec_opnd_pos = l_sopos[26*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c26_payload.sec_opnd_width = l_sowid[26*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c26_payload.sec_dst_pos = l_sdpos[26*NK*2 +: NK*2];
  assign rcu_lane_ops_c26_payload.sec_dst_width = l_sdwid[26*NK*2 +: NK*2];
  assign rcu_lane_ops_c26_payload.operand_byp = l_sbyp[26*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c26_credit = k_cr[NS + 26];
  assign lane_rcu_res_c26_stall = 1'b0;
  assign rcu_lane_ops_c27_valid = l_v[27];
  assign rcu_lane_ops_c27_wake = l_wk[3];
  assign rcu_lane_ops_c27_payload.sec_opcode = l_sop[27*NK*WO +: NK*WO];
  assign rcu_lane_ops_c27_payload.operand = l_opd[27*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c27_payload.merge_data = l_opd[27*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c27_payload.section_en = l_sen[27*NK +: NK];
  assign rcu_lane_ops_c27_payload.sec_owner = l_sown[27*NK*2 +: NK*2];
  assign rcu_lane_ops_c27_payload.sec_pred_bit = p_spb[27*NK +: NK];
  assign rcu_lane_ops_c27_payload.sec_pred_data = l_spd[27*NK +: NK];
  assign rcu_lane_ops_c27_payload.sec_opnd_pos = l_sopos[27*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c27_payload.sec_opnd_width = l_sowid[27*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c27_payload.sec_dst_pos = l_sdpos[27*NK*2 +: NK*2];
  assign rcu_lane_ops_c27_payload.sec_dst_width = l_sdwid[27*NK*2 +: NK*2];
  assign rcu_lane_ops_c27_payload.operand_byp = l_sbyp[27*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c27_credit = k_cr[NS + 27];
  assign lane_rcu_res_c27_stall = 1'b0;
  assign rcu_lane_ops_c28_valid = l_v[28];
  assign rcu_lane_ops_c28_wake = l_wk[3];
  assign rcu_lane_ops_c28_payload.sec_opcode = l_sop[28*NK*WO +: NK*WO];
  assign rcu_lane_ops_c28_payload.operand = l_opd[28*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c28_payload.merge_data = l_opd[28*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c28_payload.section_en = l_sen[28*NK +: NK];
  assign rcu_lane_ops_c28_payload.sec_owner = l_sown[28*NK*2 +: NK*2];
  assign rcu_lane_ops_c28_payload.sec_pred_bit = p_spb[28*NK +: NK];
  assign rcu_lane_ops_c28_payload.sec_pred_data = l_spd[28*NK +: NK];
  assign rcu_lane_ops_c28_payload.sec_opnd_pos = l_sopos[28*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c28_payload.sec_opnd_width = l_sowid[28*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c28_payload.sec_dst_pos = l_sdpos[28*NK*2 +: NK*2];
  assign rcu_lane_ops_c28_payload.sec_dst_width = l_sdwid[28*NK*2 +: NK*2];
  assign rcu_lane_ops_c28_payload.operand_byp = l_sbyp[28*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c28_credit = k_cr[NS + 28];
  assign lane_rcu_res_c28_stall = 1'b0;
  assign rcu_lane_ops_c29_valid = l_v[29];
  assign rcu_lane_ops_c29_wake = l_wk[3];
  assign rcu_lane_ops_c29_payload.sec_opcode = l_sop[29*NK*WO +: NK*WO];
  assign rcu_lane_ops_c29_payload.operand = l_opd[29*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c29_payload.merge_data = l_opd[29*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c29_payload.section_en = l_sen[29*NK +: NK];
  assign rcu_lane_ops_c29_payload.sec_owner = l_sown[29*NK*2 +: NK*2];
  assign rcu_lane_ops_c29_payload.sec_pred_bit = p_spb[29*NK +: NK];
  assign rcu_lane_ops_c29_payload.sec_pred_data = l_spd[29*NK +: NK];
  assign rcu_lane_ops_c29_payload.sec_opnd_pos = l_sopos[29*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c29_payload.sec_opnd_width = l_sowid[29*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c29_payload.sec_dst_pos = l_sdpos[29*NK*2 +: NK*2];
  assign rcu_lane_ops_c29_payload.sec_dst_width = l_sdwid[29*NK*2 +: NK*2];
  assign rcu_lane_ops_c29_payload.operand_byp = l_sbyp[29*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c29_credit = k_cr[NS + 29];
  assign lane_rcu_res_c29_stall = 1'b0;
  assign rcu_lane_ops_c30_valid = l_v[30];
  assign rcu_lane_ops_c30_wake = l_wk[3];
  assign rcu_lane_ops_c30_payload.sec_opcode = l_sop[30*NK*WO +: NK*WO];
  assign rcu_lane_ops_c30_payload.operand = l_opd[30*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c30_payload.merge_data = l_opd[30*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c30_payload.section_en = l_sen[30*NK +: NK];
  assign rcu_lane_ops_c30_payload.sec_owner = l_sown[30*NK*2 +: NK*2];
  assign rcu_lane_ops_c30_payload.sec_pred_bit = p_spb[30*NK +: NK];
  assign rcu_lane_ops_c30_payload.sec_pred_data = l_spd[30*NK +: NK];
  assign rcu_lane_ops_c30_payload.sec_opnd_pos = l_sopos[30*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c30_payload.sec_opnd_width = l_sowid[30*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c30_payload.sec_dst_pos = l_sdpos[30*NK*2 +: NK*2];
  assign rcu_lane_ops_c30_payload.sec_dst_width = l_sdwid[30*NK*2 +: NK*2];
  assign rcu_lane_ops_c30_payload.operand_byp = l_sbyp[30*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c30_credit = k_cr[NS + 30];
  assign lane_rcu_res_c30_stall = 1'b0;
  assign rcu_lane_ops_c31_valid = l_v[31];
  assign rcu_lane_ops_c31_wake = l_wk[3];
  assign rcu_lane_ops_c31_payload.sec_opcode = l_sop[31*NK*WO +: NK*WO];
  assign rcu_lane_ops_c31_payload.operand = l_opd[31*NP*32 +: (NP-1)*32];
  assign rcu_lane_ops_c31_payload.merge_data = l_opd[31*NP*32 + (NP-1)*32 +: 32];
  assign rcu_lane_ops_c31_payload.section_en = l_sen[31*NK +: NK];
  assign rcu_lane_ops_c31_payload.sec_owner = l_sown[31*NK*2 +: NK*2];
  assign rcu_lane_ops_c31_payload.sec_pred_bit = p_spb[31*NK +: NK];
  assign rcu_lane_ops_c31_payload.sec_pred_data = l_spd[31*NK +: NK];
  assign rcu_lane_ops_c31_payload.sec_opnd_pos = l_sopos[31*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c31_payload.sec_opnd_width = l_sowid[31*NK*NP*2 +: NK*NP*2];
  assign rcu_lane_ops_c31_payload.sec_dst_pos = l_sdpos[31*NK*2 +: NK*2];
  assign rcu_lane_ops_c31_payload.sec_dst_width = l_sdwid[31*NK*2 +: NK*2];
  assign rcu_lane_ops_c31_payload.operand_byp = l_sbyp[31*NK*NP*WB +: NK*NP*WB];
  assign lane_rcu_res_c31_credit = k_cr[NS + 31];
  assign lane_rcu_res_c31_stall = 1'b0;
  assign rcu_ooe_done_s0_valid = l_dnv[0];
  assign rcu_ooe_done_s0_payload.rob_tag = l_dntag[0*WT +: WT];
  assign rcu_ooe_done_s0_payload.done_row = l_dnrow[0*2 +: 2];
  assign rcu_ooe_done_s0_payload.branch_taken = 1'b0;
  assign rcu_ooe_done_s0_payload.branch_mask = '0;
  assign rcu_ooe_done_s0_payload.aux = '0;
  assign rcu_ooe_done_s0_payload.lead_br_taken = 1'b0;
  assign rcu_ooe_done_s0_payload.lead_br_mask = '0;
  assign rcu_ooe_done_s1_valid = l_dnv[1];
  assign rcu_ooe_done_s1_payload.rob_tag = l_dntag[1*WT +: WT];
  assign rcu_ooe_done_s1_payload.done_row = l_dnrow[1*2 +: 2];
  assign rcu_ooe_done_s1_payload.branch_taken = 1'b0;
  assign rcu_ooe_done_s1_payload.branch_mask = '0;
  assign rcu_ooe_done_s1_payload.aux = '0;
  assign rcu_ooe_done_s1_payload.lead_br_taken = 1'b0;
  assign rcu_ooe_done_s1_payload.lead_br_mask = '0;
  assign rcu_ooe_done_s2_valid = l_dnv[2];
  assign rcu_ooe_done_s2_payload.rob_tag = l_dntag[2*WT +: WT];
  assign rcu_ooe_done_s2_payload.done_row = l_dnrow[2*2 +: 2];
  assign rcu_ooe_done_s2_payload.branch_taken = 1'b0;
  assign rcu_ooe_done_s2_payload.branch_mask = '0;
  assign rcu_ooe_done_s2_payload.aux = '0;
  assign rcu_ooe_done_s2_payload.lead_br_taken = 1'b0;
  assign rcu_ooe_done_s2_payload.lead_br_mask = '0;
  assign rcu_ooe_done_s3_valid = l_dnv[3];
  assign rcu_ooe_done_s3_payload.rob_tag = l_dntag[3*WT +: WT];
  assign rcu_ooe_done_s3_payload.done_row = l_dnrow[3*2 +: 2];
  assign rcu_ooe_done_s3_payload.branch_taken = 1'b0;
  assign rcu_ooe_done_s3_payload.branch_mask = '0;
  assign rcu_ooe_done_s3_payload.aux = '0;
  assign rcu_ooe_done_s3_payload.lead_br_taken = 1'b0;
  assign rcu_ooe_done_s3_payload.lead_br_mask = '0;
  assign rcu_ooe_done_s4_valid = l_sdv;
  assign rcu_ooe_done_s4_payload.rob_tag = l_sdtag;
  assign rcu_ooe_done_s4_payload.done_row = l_sdrow;
  assign rcu_ooe_done_s4_payload.branch_taken = 1'b0;
  assign rcu_ooe_done_s4_payload.branch_mask = '0;
  assign rcu_ooe_done_s4_payload.aux = '0;
  assign rcu_ooe_done_s4_payload.lead_br_taken = 1'b0;
  assign rcu_ooe_done_s4_payload.lead_br_mask = '0;
  assign rcu_ooe_done_s5_valid = r_dnv[0];
  assign rcu_ooe_done_s5_payload.rob_tag = r_dntag;
  assign rcu_ooe_done_s5_payload.done_row = r_dnrow;
  assign rcu_ooe_done_s5_payload.branch_taken = r_dnbt;
  assign rcu_ooe_done_s5_payload.branch_mask = r_dnbm;
  assign rcu_ooe_done_s5_payload.aux = r_dnaux;
  assign rcu_ooe_done_s5_payload.lead_br_taken = p_lbt;
  assign rcu_ooe_done_s5_payload.lead_br_mask = p_lbm;
  assign rcu_ooe_done_s6_valid = r_dnv[1];
  assign rcu_ooe_done_s6_payload.rob_tag = r_dntag;
  assign rcu_ooe_done_s6_payload.done_row = r_dnrow;
  assign rcu_ooe_done_s6_payload.branch_taken = 1'b0;
  assign rcu_ooe_done_s6_payload.branch_mask = '0;
  assign rcu_ooe_done_s6_payload.aux = '0;
  assign rcu_ooe_done_s6_payload.lead_br_taken = 1'b0;
  assign rcu_ooe_done_s6_payload.lead_br_mask = '0;
  assign rcu_miu_addr_s0_valid = m_v[0];
  assign rcu_miu_addr_s0_payload.rob_tag = m_tag[0*WT +: WT];
  assign rcu_miu_addr_s0_payload.active_mask = m_am[0*N +: N];
  assign rcu_miu_addr_s0_payload.base_per_lane = m_base[0*N*32 +: N*32];
  assign rcu_miu_addr_s0_payload.index_per_lane = m_idx[0*N*32 +: N*32];
  assign rcu_miu_addr_s0_payload.store_data = m_sd[0*N*32 +: N*32];
  assign miu_rcu_data_s0_credit = k_cr[NS + N + 0];
  assign miu_rcu_data_s0_stall = 1'b0;
  assign rcu_miu_addr_s1_valid = m_v[1];
  assign rcu_miu_addr_s1_payload.rob_tag = m_tag[1*WT +: WT];
  assign rcu_miu_addr_s1_payload.active_mask = m_am[1*N +: N];
  assign rcu_miu_addr_s1_payload.base_per_lane = m_base[1*N*32 +: N*32];
  assign rcu_miu_addr_s1_payload.index_per_lane = m_idx[1*N*32 +: N*32];
  assign rcu_miu_addr_s1_payload.store_data = m_sd[1*N*32 +: N*32];
  assign miu_rcu_data_s1_credit = k_cr[NS + N + 1];
  assign miu_rcu_data_s1_stall = 1'b0;
  assign rcu_miu_addr_s2_valid = m_v[2];
  assign rcu_miu_addr_s2_payload.rob_tag = m_tag[2*WT +: WT];
  assign rcu_miu_addr_s2_payload.active_mask = m_am[2*N +: N];
  assign rcu_miu_addr_s2_payload.base_per_lane = m_base[2*N*32 +: N*32];
  assign rcu_miu_addr_s2_payload.index_per_lane = m_idx[2*N*32 +: N*32];
  assign rcu_miu_addr_s2_payload.store_data = m_sd[2*N*32 +: N*32];
  assign miu_rcu_data_s2_credit = k_cr[NS + N + 2];
  assign miu_rcu_data_s2_stall = 1'b0;
  assign rcu_miu_addr_s3_valid = m_v[3];
  assign rcu_miu_addr_s3_payload.rob_tag = m_tag[3*WT +: WT];
  assign rcu_miu_addr_s3_payload.active_mask = m_am[3*N +: N];
  assign rcu_miu_addr_s3_payload.base_per_lane = m_base[3*N*32 +: N*32];
  assign rcu_miu_addr_s3_payload.index_per_lane = m_idx[3*N*32 +: N*32];
  assign rcu_miu_addr_s3_payload.store_data = m_sd[3*N*32 +: N*32];
  assign miu_rcu_data_s3_credit = k_cr[NS + N + 3];
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
