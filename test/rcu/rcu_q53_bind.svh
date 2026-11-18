// RCU's Q-53 checkers bound into ccv_rcu (test/rcu/rcu_q53_chk.sv): each
// port the checker reads, from the block's own ports, rcu_mig's launch, the
// issue class words, and slice (0, 0)'s and rcu_pred's row hits.
// Written by hand; the slot counts are ccv_rcu's (9 issue, 7 done).
bind ccv_rcu rcu_q53_chk u_q53 (
  .core_clk      (core_clk),
  .rst_n         (rst_n),
  .iv            ({ooe_rcu_issue_s8_valid, ooe_rcu_issue_s7_valid, ooe_rcu_issue_s6_valid, ooe_rcu_issue_s5_valid, ooe_rcu_issue_s4_valid, ooe_rcu_issue_s3_valid, ooe_rcu_issue_s2_valid, ooe_rcu_issue_s1_valid, ooe_rcu_issue_s0_valid}),
  .itag          ({ooe_rcu_issue_s8_payload.rob_tag, ooe_rcu_issue_s7_payload.rob_tag, ooe_rcu_issue_s6_payload.rob_tag, ooe_rcu_issue_s5_payload.rob_tag, ooe_rcu_issue_s4_payload.rob_tag, ooe_rcu_issue_s3_payload.rob_tag, ooe_rcu_issue_s2_payload.rob_tag, ooe_rcu_issue_s1_payload.rob_tag, ooe_rcu_issue_s0_payload.rob_tag}),
  .irow          ({ooe_rcu_issue_s8_payload.done_row, ooe_rcu_issue_s7_payload.done_row, ooe_rcu_issue_s6_payload.done_row, ooe_rcu_issue_s5_payload.done_row, ooe_rcu_issue_s4_payload.done_row, ooe_rcu_issue_s3_payload.done_row, ooe_rcu_issue_s2_payload.done_row, ooe_rcu_issue_s1_payload.done_row, ooe_rcu_issue_s0_payload.done_row}),
  .dv            ({rcu_ooe_done_s6_valid, rcu_ooe_done_s5_valid, rcu_ooe_done_s4_valid, rcu_ooe_done_s3_valid, rcu_ooe_done_s2_valid, rcu_ooe_done_s1_valid, rcu_ooe_done_s0_valid}),
  .dtag          ({rcu_ooe_done_s6_payload.rob_tag, rcu_ooe_done_s5_payload.rob_tag, rcu_ooe_done_s4_payload.rob_tag, rcu_ooe_done_s3_payload.rob_tag, rcu_ooe_done_s2_payload.rob_tag, rcu_ooe_done_s1_payload.rob_tag, rcu_ooe_done_s0_payload.rob_tag}),
  .drow          ({rcu_ooe_done_s6_payload.done_row, rcu_ooe_done_s5_payload.done_row, rcu_ooe_done_s4_payload.done_row, rcu_ooe_done_s3_payload.done_row, rcu_ooe_done_s2_payload.done_row, rcu_ooe_done_s1_payload.done_row, rcu_ooe_done_s0_payload.done_row}),
  .map_v         (ooe_rcu_map_valid),
  .map_w         (ooe_rcu_map_payload.warp_id),
  .map_d         (ooe_rcu_map_payload.direction),
  .map_g         (ooe_rcu_map_payload.gpr_map),
  .map_p         (ooe_rcu_map_payload.pred_map),
  .icls          (i_cls_cr02h),
  .isrc          ({ooe_rcu_issue_s8_payload.phys_src, ooe_rcu_issue_s7_payload.phys_src, ooe_rcu_issue_s6_payload.phys_src, ooe_rcu_issue_s5_payload.phys_src, ooe_rcu_issue_s4_payload.phys_src, ooe_rcu_issue_s3_payload.phys_src, ooe_rcu_issue_s2_payload.phys_src, ooe_rcu_issue_s1_payload.phys_src, ooe_rcu_issue_s0_payload.phys_src}),
  .isrc2         ({ooe_rcu_issue_s8_payload.phys_src2, ooe_rcu_issue_s7_payload.phys_src2, ooe_rcu_issue_s6_payload.phys_src2, ooe_rcu_issue_s5_payload.phys_src2, ooe_rcu_issue_s4_payload.phys_src2, ooe_rcu_issue_s3_payload.phys_src2, ooe_rcu_issue_s2_payload.phys_src2, ooe_rcu_issue_s1_payload.phys_src2, ooe_rcu_issue_s0_payload.phys_src2}),
  .lsrc          ({ooe_rcu_issue_s8_payload.lead_phys_src, ooe_rcu_issue_s7_payload.lead_phys_src, ooe_rcu_issue_s6_payload.lead_phys_src, ooe_rcu_issue_s5_payload.lead_phys_src, ooe_rcu_issue_s4_payload.lead_phys_src, ooe_rcu_issue_s3_payload.lead_phys_src, ooe_rcu_issue_s2_payload.lead_phys_src, ooe_rcu_issue_s1_payload.lead_phys_src, ooe_rcu_issue_s0_payload.lead_phys_src}),
  .lsrc2         ({ooe_rcu_issue_s8_payload.lead_phys_src2, ooe_rcu_issue_s7_payload.lead_phys_src2, ooe_rcu_issue_s6_payload.lead_phys_src2, ooe_rcu_issue_s5_payload.lead_phys_src2, ooe_rcu_issue_s4_payload.lead_phys_src2, ooe_rcu_issue_s3_payload.lead_phys_src2, ooe_rcu_issue_s2_payload.lead_phys_src2, ooe_rcu_issue_s1_payload.lead_phys_src2, ooe_rcu_issue_s0_payload.lead_phys_src2}),
  .lgp           ({ooe_rcu_issue_s8_payload.lead_guard_pred, ooe_rcu_issue_s7_payload.lead_guard_pred, ooe_rcu_issue_s6_payload.lead_guard_pred, ooe_rcu_issue_s5_payload.lead_guard_pred, ooe_rcu_issue_s4_payload.lead_guard_pred, ooe_rcu_issue_s3_payload.lead_guard_pred, ooe_rcu_issue_s2_payload.lead_guard_pred, ooe_rcu_issue_s1_payload.lead_guard_pred, ooe_rcu_issue_s0_payload.lead_guard_pred}),
  .shit          (g_k[0].g_j[0].u_slice.hit_cr02h),
  .sgws          (g_k[0].g_j[0].u_slice.gws_cr02h),
  .phit          (u_pred.hit_cr02h),
  .cmd_v         (rau_rcu_mig_valid),
  .cmd_w         (rau_rcu_mig_payload.warp_id),
  .cmd_d         (rau_rcu_mig_payload.direction),
  .kill_valid    (kill_valid),
  .kill_warp_mask(kill_warp_mask),
  .dl            (u_mig.dl_cr02h),
  .dl_w          (u_mig.dk_w_cr02h),
  .rl            (u_mig.rl_cr02h),
  .rl_w          (u_mig.hd_w_cr02h)
);
