// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// STUB for ccv_rcu: never sends, never consumes, never stalls.
// That is protocol-legal on every channel -- no valid means no
// credit is owed -- so the top elaborates and simulates with every
// checker quiet. Common-port handshakes (kill, CSR) have no
// specified semantics yet, so outputs sit at their inactive value.
// It has its clock gate all the same, tied open, and clk_gated is
// that gate's own report (docs/clock-gate.md).
//
// Replaced at 4c by real RTL with the SAME module name, including
// the same generated port list; the swap is a file-list change.
`include "ccv_interfaces.svh"

// A stub reads none of its inputs, by definition.
/* verilator lint_off UNUSEDSIGNAL */
module ccv_rcu (
  `include "ccv_rcu_ports.svh"
);
  // The block's clock gate: ctech ICG, sleep policy, wake path. Tied
  // never to close -- cg_override -- until the block has idle logic;
  // then these ties become its quiesced, stalled and wake. quiesced:
  // a stub holds nothing, so it is always quiesced.
  // The thresholds and the override are CSRs (Q-47): tied to their
  // reset values until the block decodes its own.
  localparam int CG_HW = ccv_prov_pkg::CCV_CG_HYST_W;
  logic gclk, cg_gated;
  ccv_clk_gate u_cg (
    .clk         (core_clk),
    .rst_n       (rst_n),
    .quiesced    (1'b1),
    .stalled     (1'b0),
    .hyst_quiesce(CG_HW'(ccv_prov_pkg::CCV_CG_HYST_QUIESCE)),
    .hyst_stall  (CG_HW'(ccv_prov_pkg::CCV_CG_HYST_STALL)),
    .wake        (1'b0),
    .cg_override (1'b1),
    .te          (1'b0),
    .gclk        (gclk),
    .gated       (cg_gated)
  );
`ifdef CCV_CHECK
  assign clk_gated = cg_gated;
`endif
  assign kill_ack = '0;
  assign kill_ack_epoch = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign ooe_rcu_issue_s0_credit = '0;
  assign ooe_rcu_issue_s0_stall = '0;
  assign ooe_rcu_issue_s1_credit = '0;
  assign ooe_rcu_issue_s1_stall = '0;
  assign ooe_rcu_issue_s2_credit = '0;
  assign ooe_rcu_issue_s2_stall = '0;
  assign ooe_rcu_issue_s3_credit = '0;
  assign ooe_rcu_issue_s3_stall = '0;
  assign ooe_rcu_issue_s4_credit = '0;
  assign ooe_rcu_issue_s4_stall = '0;
  assign ooe_rcu_issue_s5_credit = '0;
  assign ooe_rcu_issue_s5_stall = '0;
  assign ooe_rcu_issue_s6_credit = '0;
  assign ooe_rcu_issue_s6_stall = '0;
  assign ooe_rcu_issue_s7_credit = '0;
  assign ooe_rcu_issue_s7_stall = '0;
  assign ooe_rcu_issue_s8_credit = '0;
  assign ooe_rcu_issue_s8_stall = '0;
  assign rcu_lane_ops_c00_valid = '0;
  assign rcu_lane_ops_c00_payload = '0;
  assign rcu_lane_ops_c00_wake = '0;
  assign rcu_lane_ops_c01_valid = '0;
  assign rcu_lane_ops_c01_payload = '0;
  assign rcu_lane_ops_c01_wake = '0;
  assign rcu_lane_ops_c02_valid = '0;
  assign rcu_lane_ops_c02_payload = '0;
  assign rcu_lane_ops_c02_wake = '0;
  assign rcu_lane_ops_c03_valid = '0;
  assign rcu_lane_ops_c03_payload = '0;
  assign rcu_lane_ops_c03_wake = '0;
  assign rcu_lane_ops_c04_valid = '0;
  assign rcu_lane_ops_c04_payload = '0;
  assign rcu_lane_ops_c04_wake = '0;
  assign rcu_lane_ops_c05_valid = '0;
  assign rcu_lane_ops_c05_payload = '0;
  assign rcu_lane_ops_c05_wake = '0;
  assign rcu_lane_ops_c06_valid = '0;
  assign rcu_lane_ops_c06_payload = '0;
  assign rcu_lane_ops_c06_wake = '0;
  assign rcu_lane_ops_c07_valid = '0;
  assign rcu_lane_ops_c07_payload = '0;
  assign rcu_lane_ops_c07_wake = '0;
  assign rcu_lane_ops_c08_valid = '0;
  assign rcu_lane_ops_c08_payload = '0;
  assign rcu_lane_ops_c08_wake = '0;
  assign rcu_lane_ops_c09_valid = '0;
  assign rcu_lane_ops_c09_payload = '0;
  assign rcu_lane_ops_c09_wake = '0;
  assign rcu_lane_ops_c10_valid = '0;
  assign rcu_lane_ops_c10_payload = '0;
  assign rcu_lane_ops_c10_wake = '0;
  assign rcu_lane_ops_c11_valid = '0;
  assign rcu_lane_ops_c11_payload = '0;
  assign rcu_lane_ops_c11_wake = '0;
  assign rcu_lane_ops_c12_valid = '0;
  assign rcu_lane_ops_c12_payload = '0;
  assign rcu_lane_ops_c12_wake = '0;
  assign rcu_lane_ops_c13_valid = '0;
  assign rcu_lane_ops_c13_payload = '0;
  assign rcu_lane_ops_c13_wake = '0;
  assign rcu_lane_ops_c14_valid = '0;
  assign rcu_lane_ops_c14_payload = '0;
  assign rcu_lane_ops_c14_wake = '0;
  assign rcu_lane_ops_c15_valid = '0;
  assign rcu_lane_ops_c15_payload = '0;
  assign rcu_lane_ops_c15_wake = '0;
  assign rcu_lane_ops_c16_valid = '0;
  assign rcu_lane_ops_c16_payload = '0;
  assign rcu_lane_ops_c16_wake = '0;
  assign rcu_lane_ops_c17_valid = '0;
  assign rcu_lane_ops_c17_payload = '0;
  assign rcu_lane_ops_c17_wake = '0;
  assign rcu_lane_ops_c18_valid = '0;
  assign rcu_lane_ops_c18_payload = '0;
  assign rcu_lane_ops_c18_wake = '0;
  assign rcu_lane_ops_c19_valid = '0;
  assign rcu_lane_ops_c19_payload = '0;
  assign rcu_lane_ops_c19_wake = '0;
  assign rcu_lane_ops_c20_valid = '0;
  assign rcu_lane_ops_c20_payload = '0;
  assign rcu_lane_ops_c20_wake = '0;
  assign rcu_lane_ops_c21_valid = '0;
  assign rcu_lane_ops_c21_payload = '0;
  assign rcu_lane_ops_c21_wake = '0;
  assign rcu_lane_ops_c22_valid = '0;
  assign rcu_lane_ops_c22_payload = '0;
  assign rcu_lane_ops_c22_wake = '0;
  assign rcu_lane_ops_c23_valid = '0;
  assign rcu_lane_ops_c23_payload = '0;
  assign rcu_lane_ops_c23_wake = '0;
  assign rcu_lane_ops_c24_valid = '0;
  assign rcu_lane_ops_c24_payload = '0;
  assign rcu_lane_ops_c24_wake = '0;
  assign rcu_lane_ops_c25_valid = '0;
  assign rcu_lane_ops_c25_payload = '0;
  assign rcu_lane_ops_c25_wake = '0;
  assign rcu_lane_ops_c26_valid = '0;
  assign rcu_lane_ops_c26_payload = '0;
  assign rcu_lane_ops_c26_wake = '0;
  assign rcu_lane_ops_c27_valid = '0;
  assign rcu_lane_ops_c27_payload = '0;
  assign rcu_lane_ops_c27_wake = '0;
  assign rcu_lane_ops_c28_valid = '0;
  assign rcu_lane_ops_c28_payload = '0;
  assign rcu_lane_ops_c28_wake = '0;
  assign rcu_lane_ops_c29_valid = '0;
  assign rcu_lane_ops_c29_payload = '0;
  assign rcu_lane_ops_c29_wake = '0;
  assign rcu_lane_ops_c30_valid = '0;
  assign rcu_lane_ops_c30_payload = '0;
  assign rcu_lane_ops_c30_wake = '0;
  assign rcu_lane_ops_c31_valid = '0;
  assign rcu_lane_ops_c31_payload = '0;
  assign rcu_lane_ops_c31_wake = '0;
`ifdef CCV_TRACE
  assign rcu_lane_ops_c00_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c01_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c02_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c03_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c04_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c05_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c06_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c07_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c08_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c09_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c10_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c11_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c12_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c13_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c14_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c15_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c16_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c17_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c18_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c19_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c20_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c21_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c22_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c23_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c24_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c25_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c26_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c27_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c28_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c29_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c30_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c31_tid = '0;
`endif
  assign lane_rcu_res_c00_credit = '0;
  assign lane_rcu_res_c00_stall = '0;
  assign lane_rcu_res_c01_credit = '0;
  assign lane_rcu_res_c01_stall = '0;
  assign lane_rcu_res_c02_credit = '0;
  assign lane_rcu_res_c02_stall = '0;
  assign lane_rcu_res_c03_credit = '0;
  assign lane_rcu_res_c03_stall = '0;
  assign lane_rcu_res_c04_credit = '0;
  assign lane_rcu_res_c04_stall = '0;
  assign lane_rcu_res_c05_credit = '0;
  assign lane_rcu_res_c05_stall = '0;
  assign lane_rcu_res_c06_credit = '0;
  assign lane_rcu_res_c06_stall = '0;
  assign lane_rcu_res_c07_credit = '0;
  assign lane_rcu_res_c07_stall = '0;
  assign lane_rcu_res_c08_credit = '0;
  assign lane_rcu_res_c08_stall = '0;
  assign lane_rcu_res_c09_credit = '0;
  assign lane_rcu_res_c09_stall = '0;
  assign lane_rcu_res_c10_credit = '0;
  assign lane_rcu_res_c10_stall = '0;
  assign lane_rcu_res_c11_credit = '0;
  assign lane_rcu_res_c11_stall = '0;
  assign lane_rcu_res_c12_credit = '0;
  assign lane_rcu_res_c12_stall = '0;
  assign lane_rcu_res_c13_credit = '0;
  assign lane_rcu_res_c13_stall = '0;
  assign lane_rcu_res_c14_credit = '0;
  assign lane_rcu_res_c14_stall = '0;
  assign lane_rcu_res_c15_credit = '0;
  assign lane_rcu_res_c15_stall = '0;
  assign lane_rcu_res_c16_credit = '0;
  assign lane_rcu_res_c16_stall = '0;
  assign lane_rcu_res_c17_credit = '0;
  assign lane_rcu_res_c17_stall = '0;
  assign lane_rcu_res_c18_credit = '0;
  assign lane_rcu_res_c18_stall = '0;
  assign lane_rcu_res_c19_credit = '0;
  assign lane_rcu_res_c19_stall = '0;
  assign lane_rcu_res_c20_credit = '0;
  assign lane_rcu_res_c20_stall = '0;
  assign lane_rcu_res_c21_credit = '0;
  assign lane_rcu_res_c21_stall = '0;
  assign lane_rcu_res_c22_credit = '0;
  assign lane_rcu_res_c22_stall = '0;
  assign lane_rcu_res_c23_credit = '0;
  assign lane_rcu_res_c23_stall = '0;
  assign lane_rcu_res_c24_credit = '0;
  assign lane_rcu_res_c24_stall = '0;
  assign lane_rcu_res_c25_credit = '0;
  assign lane_rcu_res_c25_stall = '0;
  assign lane_rcu_res_c26_credit = '0;
  assign lane_rcu_res_c26_stall = '0;
  assign lane_rcu_res_c27_credit = '0;
  assign lane_rcu_res_c27_stall = '0;
  assign lane_rcu_res_c28_credit = '0;
  assign lane_rcu_res_c28_stall = '0;
  assign lane_rcu_res_c29_credit = '0;
  assign lane_rcu_res_c29_stall = '0;
  assign lane_rcu_res_c30_credit = '0;
  assign lane_rcu_res_c30_stall = '0;
  assign lane_rcu_res_c31_credit = '0;
  assign lane_rcu_res_c31_stall = '0;
  assign rcu_ooe_done_s0_valid = '0;
  assign rcu_ooe_done_s0_payload = '0;
  assign rcu_ooe_done_s1_valid = '0;
  assign rcu_ooe_done_s1_payload = '0;
  assign rcu_ooe_done_s2_valid = '0;
  assign rcu_ooe_done_s2_payload = '0;
  assign rcu_ooe_done_s3_valid = '0;
  assign rcu_ooe_done_s3_payload = '0;
  assign rcu_ooe_done_s4_valid = '0;
  assign rcu_ooe_done_s4_payload = '0;
  assign rcu_ooe_done_s5_valid = '0;
  assign rcu_ooe_done_s5_payload = '0;
  assign rcu_ooe_done_s6_valid = '0;
  assign rcu_ooe_done_s6_payload = '0;
  assign rcu_ooe_done_wake = '0;
`ifdef CCV_TRACE
  assign rcu_ooe_done_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_ooe_done_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_ooe_done_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_ooe_done_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_ooe_done_s4_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_ooe_done_s5_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_ooe_done_s6_tid = '0;
`endif
  assign rcu_miu_addr_s0_valid = '0;
  assign rcu_miu_addr_s0_payload = '0;
  assign rcu_miu_addr_s1_valid = '0;
  assign rcu_miu_addr_s1_payload = '0;
  assign rcu_miu_addr_s2_valid = '0;
  assign rcu_miu_addr_s2_payload = '0;
  assign rcu_miu_addr_s3_valid = '0;
  assign rcu_miu_addr_s3_payload = '0;
  assign rcu_miu_addr_wake = '0;
`ifdef CCV_TRACE
  assign rcu_miu_addr_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_miu_addr_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_miu_addr_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_miu_addr_s3_tid = '0;
`endif
  assign miu_rcu_data_s0_credit = '0;
  assign miu_rcu_data_s0_stall = '0;
  assign miu_rcu_data_s1_credit = '0;
  assign miu_rcu_data_s1_stall = '0;
  assign miu_rcu_data_s2_credit = '0;
  assign miu_rcu_data_s2_stall = '0;
  assign miu_rcu_data_s3_credit = '0;
  assign miu_rcu_data_s3_stall = '0;
  assign rau_rcu_mig_credit = '0;
  assign rau_rcu_mig_stall = '0;
  assign ooe_rcu_map_credit = '0;
  assign ooe_rcu_map_stall = '0;
  assign rcu_pca_mig_valid = '0;
  assign rcu_pca_mig_payload = '0;
  assign rcu_pca_mig_wake = '0;
`ifdef CCV_TRACE
  assign rcu_pca_mig_tid = '0;
`endif
  assign pca_rcu_mig_credit = '0;
  assign pca_rcu_mig_stall = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
