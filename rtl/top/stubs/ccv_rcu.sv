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
// A stub holds no state, so it has no clock gate: clk_gated reports
// the gate open. Real RTL gates core_clk inside itself (CCV-L22).
//
// Replaced at 4c by real RTL with the SAME module name, including
// the same generated port list; the swap is a file-list change.
`include "ccv_interfaces.svh"

// A stub reads none of its inputs, by definition.
/* verilator lint_off UNUSEDSIGNAL */
module ccv_rcu (
  `include "ccv_rcu_ports.svh"
);
  assign kill_ack = '0;
  assign kill_ack_epoch = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
`ifdef CCV_CHECK
  assign clk_gated = '0;
`endif
  assign ooe_rcu_issue_s0_credit = '0;
  assign ooe_rcu_issue_s0_stall = '0;
  assign ooe_rcu_issue_s1_credit = '0;
  assign ooe_rcu_issue_s1_stall = '0;
  assign ooe_rcu_issue_s2_credit = '0;
  assign ooe_rcu_issue_s2_stall = '0;
  assign ooe_rcu_issue_s3_credit = '0;
  assign ooe_rcu_issue_s3_stall = '0;
  assign rcu_lane_ops_c00_s0_valid = '0;
  assign rcu_lane_ops_c00_s0_payload = '0;
  assign rcu_lane_ops_c00_s1_valid = '0;
  assign rcu_lane_ops_c00_s1_payload = '0;
  assign rcu_lane_ops_c00_s2_valid = '0;
  assign rcu_lane_ops_c00_s2_payload = '0;
  assign rcu_lane_ops_c00_s3_valid = '0;
  assign rcu_lane_ops_c00_s3_payload = '0;
  assign rcu_lane_ops_c00_wake = '0;
  assign rcu_lane_ops_c01_s0_valid = '0;
  assign rcu_lane_ops_c01_s0_payload = '0;
  assign rcu_lane_ops_c01_s1_valid = '0;
  assign rcu_lane_ops_c01_s1_payload = '0;
  assign rcu_lane_ops_c01_s2_valid = '0;
  assign rcu_lane_ops_c01_s2_payload = '0;
  assign rcu_lane_ops_c01_s3_valid = '0;
  assign rcu_lane_ops_c01_s3_payload = '0;
  assign rcu_lane_ops_c01_wake = '0;
  assign rcu_lane_ops_c02_s0_valid = '0;
  assign rcu_lane_ops_c02_s0_payload = '0;
  assign rcu_lane_ops_c02_s1_valid = '0;
  assign rcu_lane_ops_c02_s1_payload = '0;
  assign rcu_lane_ops_c02_s2_valid = '0;
  assign rcu_lane_ops_c02_s2_payload = '0;
  assign rcu_lane_ops_c02_s3_valid = '0;
  assign rcu_lane_ops_c02_s3_payload = '0;
  assign rcu_lane_ops_c02_wake = '0;
  assign rcu_lane_ops_c03_s0_valid = '0;
  assign rcu_lane_ops_c03_s0_payload = '0;
  assign rcu_lane_ops_c03_s1_valid = '0;
  assign rcu_lane_ops_c03_s1_payload = '0;
  assign rcu_lane_ops_c03_s2_valid = '0;
  assign rcu_lane_ops_c03_s2_payload = '0;
  assign rcu_lane_ops_c03_s3_valid = '0;
  assign rcu_lane_ops_c03_s3_payload = '0;
  assign rcu_lane_ops_c03_wake = '0;
  assign rcu_lane_ops_c04_s0_valid = '0;
  assign rcu_lane_ops_c04_s0_payload = '0;
  assign rcu_lane_ops_c04_s1_valid = '0;
  assign rcu_lane_ops_c04_s1_payload = '0;
  assign rcu_lane_ops_c04_s2_valid = '0;
  assign rcu_lane_ops_c04_s2_payload = '0;
  assign rcu_lane_ops_c04_s3_valid = '0;
  assign rcu_lane_ops_c04_s3_payload = '0;
  assign rcu_lane_ops_c04_wake = '0;
  assign rcu_lane_ops_c05_s0_valid = '0;
  assign rcu_lane_ops_c05_s0_payload = '0;
  assign rcu_lane_ops_c05_s1_valid = '0;
  assign rcu_lane_ops_c05_s1_payload = '0;
  assign rcu_lane_ops_c05_s2_valid = '0;
  assign rcu_lane_ops_c05_s2_payload = '0;
  assign rcu_lane_ops_c05_s3_valid = '0;
  assign rcu_lane_ops_c05_s3_payload = '0;
  assign rcu_lane_ops_c05_wake = '0;
  assign rcu_lane_ops_c06_s0_valid = '0;
  assign rcu_lane_ops_c06_s0_payload = '0;
  assign rcu_lane_ops_c06_s1_valid = '0;
  assign rcu_lane_ops_c06_s1_payload = '0;
  assign rcu_lane_ops_c06_s2_valid = '0;
  assign rcu_lane_ops_c06_s2_payload = '0;
  assign rcu_lane_ops_c06_s3_valid = '0;
  assign rcu_lane_ops_c06_s3_payload = '0;
  assign rcu_lane_ops_c06_wake = '0;
  assign rcu_lane_ops_c07_s0_valid = '0;
  assign rcu_lane_ops_c07_s0_payload = '0;
  assign rcu_lane_ops_c07_s1_valid = '0;
  assign rcu_lane_ops_c07_s1_payload = '0;
  assign rcu_lane_ops_c07_s2_valid = '0;
  assign rcu_lane_ops_c07_s2_payload = '0;
  assign rcu_lane_ops_c07_s3_valid = '0;
  assign rcu_lane_ops_c07_s3_payload = '0;
  assign rcu_lane_ops_c07_wake = '0;
  assign rcu_lane_ops_c08_s0_valid = '0;
  assign rcu_lane_ops_c08_s0_payload = '0;
  assign rcu_lane_ops_c08_s1_valid = '0;
  assign rcu_lane_ops_c08_s1_payload = '0;
  assign rcu_lane_ops_c08_s2_valid = '0;
  assign rcu_lane_ops_c08_s2_payload = '0;
  assign rcu_lane_ops_c08_s3_valid = '0;
  assign rcu_lane_ops_c08_s3_payload = '0;
  assign rcu_lane_ops_c08_wake = '0;
  assign rcu_lane_ops_c09_s0_valid = '0;
  assign rcu_lane_ops_c09_s0_payload = '0;
  assign rcu_lane_ops_c09_s1_valid = '0;
  assign rcu_lane_ops_c09_s1_payload = '0;
  assign rcu_lane_ops_c09_s2_valid = '0;
  assign rcu_lane_ops_c09_s2_payload = '0;
  assign rcu_lane_ops_c09_s3_valid = '0;
  assign rcu_lane_ops_c09_s3_payload = '0;
  assign rcu_lane_ops_c09_wake = '0;
  assign rcu_lane_ops_c10_s0_valid = '0;
  assign rcu_lane_ops_c10_s0_payload = '0;
  assign rcu_lane_ops_c10_s1_valid = '0;
  assign rcu_lane_ops_c10_s1_payload = '0;
  assign rcu_lane_ops_c10_s2_valid = '0;
  assign rcu_lane_ops_c10_s2_payload = '0;
  assign rcu_lane_ops_c10_s3_valid = '0;
  assign rcu_lane_ops_c10_s3_payload = '0;
  assign rcu_lane_ops_c10_wake = '0;
  assign rcu_lane_ops_c11_s0_valid = '0;
  assign rcu_lane_ops_c11_s0_payload = '0;
  assign rcu_lane_ops_c11_s1_valid = '0;
  assign rcu_lane_ops_c11_s1_payload = '0;
  assign rcu_lane_ops_c11_s2_valid = '0;
  assign rcu_lane_ops_c11_s2_payload = '0;
  assign rcu_lane_ops_c11_s3_valid = '0;
  assign rcu_lane_ops_c11_s3_payload = '0;
  assign rcu_lane_ops_c11_wake = '0;
  assign rcu_lane_ops_c12_s0_valid = '0;
  assign rcu_lane_ops_c12_s0_payload = '0;
  assign rcu_lane_ops_c12_s1_valid = '0;
  assign rcu_lane_ops_c12_s1_payload = '0;
  assign rcu_lane_ops_c12_s2_valid = '0;
  assign rcu_lane_ops_c12_s2_payload = '0;
  assign rcu_lane_ops_c12_s3_valid = '0;
  assign rcu_lane_ops_c12_s3_payload = '0;
  assign rcu_lane_ops_c12_wake = '0;
  assign rcu_lane_ops_c13_s0_valid = '0;
  assign rcu_lane_ops_c13_s0_payload = '0;
  assign rcu_lane_ops_c13_s1_valid = '0;
  assign rcu_lane_ops_c13_s1_payload = '0;
  assign rcu_lane_ops_c13_s2_valid = '0;
  assign rcu_lane_ops_c13_s2_payload = '0;
  assign rcu_lane_ops_c13_s3_valid = '0;
  assign rcu_lane_ops_c13_s3_payload = '0;
  assign rcu_lane_ops_c13_wake = '0;
  assign rcu_lane_ops_c14_s0_valid = '0;
  assign rcu_lane_ops_c14_s0_payload = '0;
  assign rcu_lane_ops_c14_s1_valid = '0;
  assign rcu_lane_ops_c14_s1_payload = '0;
  assign rcu_lane_ops_c14_s2_valid = '0;
  assign rcu_lane_ops_c14_s2_payload = '0;
  assign rcu_lane_ops_c14_s3_valid = '0;
  assign rcu_lane_ops_c14_s3_payload = '0;
  assign rcu_lane_ops_c14_wake = '0;
  assign rcu_lane_ops_c15_s0_valid = '0;
  assign rcu_lane_ops_c15_s0_payload = '0;
  assign rcu_lane_ops_c15_s1_valid = '0;
  assign rcu_lane_ops_c15_s1_payload = '0;
  assign rcu_lane_ops_c15_s2_valid = '0;
  assign rcu_lane_ops_c15_s2_payload = '0;
  assign rcu_lane_ops_c15_s3_valid = '0;
  assign rcu_lane_ops_c15_s3_payload = '0;
  assign rcu_lane_ops_c15_wake = '0;
  assign rcu_lane_ops_c16_s0_valid = '0;
  assign rcu_lane_ops_c16_s0_payload = '0;
  assign rcu_lane_ops_c16_s1_valid = '0;
  assign rcu_lane_ops_c16_s1_payload = '0;
  assign rcu_lane_ops_c16_s2_valid = '0;
  assign rcu_lane_ops_c16_s2_payload = '0;
  assign rcu_lane_ops_c16_s3_valid = '0;
  assign rcu_lane_ops_c16_s3_payload = '0;
  assign rcu_lane_ops_c16_wake = '0;
  assign rcu_lane_ops_c17_s0_valid = '0;
  assign rcu_lane_ops_c17_s0_payload = '0;
  assign rcu_lane_ops_c17_s1_valid = '0;
  assign rcu_lane_ops_c17_s1_payload = '0;
  assign rcu_lane_ops_c17_s2_valid = '0;
  assign rcu_lane_ops_c17_s2_payload = '0;
  assign rcu_lane_ops_c17_s3_valid = '0;
  assign rcu_lane_ops_c17_s3_payload = '0;
  assign rcu_lane_ops_c17_wake = '0;
  assign rcu_lane_ops_c18_s0_valid = '0;
  assign rcu_lane_ops_c18_s0_payload = '0;
  assign rcu_lane_ops_c18_s1_valid = '0;
  assign rcu_lane_ops_c18_s1_payload = '0;
  assign rcu_lane_ops_c18_s2_valid = '0;
  assign rcu_lane_ops_c18_s2_payload = '0;
  assign rcu_lane_ops_c18_s3_valid = '0;
  assign rcu_lane_ops_c18_s3_payload = '0;
  assign rcu_lane_ops_c18_wake = '0;
  assign rcu_lane_ops_c19_s0_valid = '0;
  assign rcu_lane_ops_c19_s0_payload = '0;
  assign rcu_lane_ops_c19_s1_valid = '0;
  assign rcu_lane_ops_c19_s1_payload = '0;
  assign rcu_lane_ops_c19_s2_valid = '0;
  assign rcu_lane_ops_c19_s2_payload = '0;
  assign rcu_lane_ops_c19_s3_valid = '0;
  assign rcu_lane_ops_c19_s3_payload = '0;
  assign rcu_lane_ops_c19_wake = '0;
  assign rcu_lane_ops_c20_s0_valid = '0;
  assign rcu_lane_ops_c20_s0_payload = '0;
  assign rcu_lane_ops_c20_s1_valid = '0;
  assign rcu_lane_ops_c20_s1_payload = '0;
  assign rcu_lane_ops_c20_s2_valid = '0;
  assign rcu_lane_ops_c20_s2_payload = '0;
  assign rcu_lane_ops_c20_s3_valid = '0;
  assign rcu_lane_ops_c20_s3_payload = '0;
  assign rcu_lane_ops_c20_wake = '0;
  assign rcu_lane_ops_c21_s0_valid = '0;
  assign rcu_lane_ops_c21_s0_payload = '0;
  assign rcu_lane_ops_c21_s1_valid = '0;
  assign rcu_lane_ops_c21_s1_payload = '0;
  assign rcu_lane_ops_c21_s2_valid = '0;
  assign rcu_lane_ops_c21_s2_payload = '0;
  assign rcu_lane_ops_c21_s3_valid = '0;
  assign rcu_lane_ops_c21_s3_payload = '0;
  assign rcu_lane_ops_c21_wake = '0;
  assign rcu_lane_ops_c22_s0_valid = '0;
  assign rcu_lane_ops_c22_s0_payload = '0;
  assign rcu_lane_ops_c22_s1_valid = '0;
  assign rcu_lane_ops_c22_s1_payload = '0;
  assign rcu_lane_ops_c22_s2_valid = '0;
  assign rcu_lane_ops_c22_s2_payload = '0;
  assign rcu_lane_ops_c22_s3_valid = '0;
  assign rcu_lane_ops_c22_s3_payload = '0;
  assign rcu_lane_ops_c22_wake = '0;
  assign rcu_lane_ops_c23_s0_valid = '0;
  assign rcu_lane_ops_c23_s0_payload = '0;
  assign rcu_lane_ops_c23_s1_valid = '0;
  assign rcu_lane_ops_c23_s1_payload = '0;
  assign rcu_lane_ops_c23_s2_valid = '0;
  assign rcu_lane_ops_c23_s2_payload = '0;
  assign rcu_lane_ops_c23_s3_valid = '0;
  assign rcu_lane_ops_c23_s3_payload = '0;
  assign rcu_lane_ops_c23_wake = '0;
  assign rcu_lane_ops_c24_s0_valid = '0;
  assign rcu_lane_ops_c24_s0_payload = '0;
  assign rcu_lane_ops_c24_s1_valid = '0;
  assign rcu_lane_ops_c24_s1_payload = '0;
  assign rcu_lane_ops_c24_s2_valid = '0;
  assign rcu_lane_ops_c24_s2_payload = '0;
  assign rcu_lane_ops_c24_s3_valid = '0;
  assign rcu_lane_ops_c24_s3_payload = '0;
  assign rcu_lane_ops_c24_wake = '0;
  assign rcu_lane_ops_c25_s0_valid = '0;
  assign rcu_lane_ops_c25_s0_payload = '0;
  assign rcu_lane_ops_c25_s1_valid = '0;
  assign rcu_lane_ops_c25_s1_payload = '0;
  assign rcu_lane_ops_c25_s2_valid = '0;
  assign rcu_lane_ops_c25_s2_payload = '0;
  assign rcu_lane_ops_c25_s3_valid = '0;
  assign rcu_lane_ops_c25_s3_payload = '0;
  assign rcu_lane_ops_c25_wake = '0;
  assign rcu_lane_ops_c26_s0_valid = '0;
  assign rcu_lane_ops_c26_s0_payload = '0;
  assign rcu_lane_ops_c26_s1_valid = '0;
  assign rcu_lane_ops_c26_s1_payload = '0;
  assign rcu_lane_ops_c26_s2_valid = '0;
  assign rcu_lane_ops_c26_s2_payload = '0;
  assign rcu_lane_ops_c26_s3_valid = '0;
  assign rcu_lane_ops_c26_s3_payload = '0;
  assign rcu_lane_ops_c26_wake = '0;
  assign rcu_lane_ops_c27_s0_valid = '0;
  assign rcu_lane_ops_c27_s0_payload = '0;
  assign rcu_lane_ops_c27_s1_valid = '0;
  assign rcu_lane_ops_c27_s1_payload = '0;
  assign rcu_lane_ops_c27_s2_valid = '0;
  assign rcu_lane_ops_c27_s2_payload = '0;
  assign rcu_lane_ops_c27_s3_valid = '0;
  assign rcu_lane_ops_c27_s3_payload = '0;
  assign rcu_lane_ops_c27_wake = '0;
  assign rcu_lane_ops_c28_s0_valid = '0;
  assign rcu_lane_ops_c28_s0_payload = '0;
  assign rcu_lane_ops_c28_s1_valid = '0;
  assign rcu_lane_ops_c28_s1_payload = '0;
  assign rcu_lane_ops_c28_s2_valid = '0;
  assign rcu_lane_ops_c28_s2_payload = '0;
  assign rcu_lane_ops_c28_s3_valid = '0;
  assign rcu_lane_ops_c28_s3_payload = '0;
  assign rcu_lane_ops_c28_wake = '0;
  assign rcu_lane_ops_c29_s0_valid = '0;
  assign rcu_lane_ops_c29_s0_payload = '0;
  assign rcu_lane_ops_c29_s1_valid = '0;
  assign rcu_lane_ops_c29_s1_payload = '0;
  assign rcu_lane_ops_c29_s2_valid = '0;
  assign rcu_lane_ops_c29_s2_payload = '0;
  assign rcu_lane_ops_c29_s3_valid = '0;
  assign rcu_lane_ops_c29_s3_payload = '0;
  assign rcu_lane_ops_c29_wake = '0;
  assign rcu_lane_ops_c30_s0_valid = '0;
  assign rcu_lane_ops_c30_s0_payload = '0;
  assign rcu_lane_ops_c30_s1_valid = '0;
  assign rcu_lane_ops_c30_s1_payload = '0;
  assign rcu_lane_ops_c30_s2_valid = '0;
  assign rcu_lane_ops_c30_s2_payload = '0;
  assign rcu_lane_ops_c30_s3_valid = '0;
  assign rcu_lane_ops_c30_s3_payload = '0;
  assign rcu_lane_ops_c30_wake = '0;
  assign rcu_lane_ops_c31_s0_valid = '0;
  assign rcu_lane_ops_c31_s0_payload = '0;
  assign rcu_lane_ops_c31_s1_valid = '0;
  assign rcu_lane_ops_c31_s1_payload = '0;
  assign rcu_lane_ops_c31_s2_valid = '0;
  assign rcu_lane_ops_c31_s2_payload = '0;
  assign rcu_lane_ops_c31_s3_valid = '0;
  assign rcu_lane_ops_c31_s3_payload = '0;
  assign rcu_lane_ops_c31_wake = '0;
`ifdef CCV_TRACE
  assign rcu_lane_ops_c00_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c00_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c00_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c00_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c01_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c01_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c01_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c01_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c02_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c02_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c02_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c02_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c03_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c03_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c03_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c03_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c04_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c04_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c04_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c04_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c05_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c05_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c05_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c05_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c06_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c06_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c06_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c06_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c07_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c07_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c07_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c07_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c08_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c08_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c08_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c08_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c09_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c09_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c09_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c09_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c10_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c10_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c10_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c10_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c11_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c11_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c11_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c11_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c12_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c12_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c12_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c12_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c13_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c13_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c13_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c13_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c14_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c14_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c14_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c14_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c15_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c15_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c15_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c15_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c16_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c16_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c16_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c16_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c17_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c17_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c17_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c17_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c18_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c18_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c18_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c18_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c19_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c19_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c19_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c19_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c20_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c20_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c20_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c20_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c21_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c21_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c21_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c21_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c22_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c22_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c22_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c22_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c23_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c23_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c23_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c23_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c24_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c24_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c24_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c24_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c25_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c25_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c25_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c25_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c26_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c26_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c26_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c26_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c27_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c27_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c27_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c27_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c28_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c28_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c28_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c28_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c29_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c29_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c29_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c29_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c30_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c30_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c30_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c30_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c31_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c31_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c31_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign rcu_lane_ops_c31_s3_tid = '0;
`endif
  assign lane_rcu_res_c00_s0_credit = '0;
  assign lane_rcu_res_c00_s0_stall = '0;
  assign lane_rcu_res_c00_s1_credit = '0;
  assign lane_rcu_res_c00_s1_stall = '0;
  assign lane_rcu_res_c00_s2_credit = '0;
  assign lane_rcu_res_c00_s2_stall = '0;
  assign lane_rcu_res_c00_s3_credit = '0;
  assign lane_rcu_res_c00_s3_stall = '0;
  assign lane_rcu_res_c01_s0_credit = '0;
  assign lane_rcu_res_c01_s0_stall = '0;
  assign lane_rcu_res_c01_s1_credit = '0;
  assign lane_rcu_res_c01_s1_stall = '0;
  assign lane_rcu_res_c01_s2_credit = '0;
  assign lane_rcu_res_c01_s2_stall = '0;
  assign lane_rcu_res_c01_s3_credit = '0;
  assign lane_rcu_res_c01_s3_stall = '0;
  assign lane_rcu_res_c02_s0_credit = '0;
  assign lane_rcu_res_c02_s0_stall = '0;
  assign lane_rcu_res_c02_s1_credit = '0;
  assign lane_rcu_res_c02_s1_stall = '0;
  assign lane_rcu_res_c02_s2_credit = '0;
  assign lane_rcu_res_c02_s2_stall = '0;
  assign lane_rcu_res_c02_s3_credit = '0;
  assign lane_rcu_res_c02_s3_stall = '0;
  assign lane_rcu_res_c03_s0_credit = '0;
  assign lane_rcu_res_c03_s0_stall = '0;
  assign lane_rcu_res_c03_s1_credit = '0;
  assign lane_rcu_res_c03_s1_stall = '0;
  assign lane_rcu_res_c03_s2_credit = '0;
  assign lane_rcu_res_c03_s2_stall = '0;
  assign lane_rcu_res_c03_s3_credit = '0;
  assign lane_rcu_res_c03_s3_stall = '0;
  assign lane_rcu_res_c04_s0_credit = '0;
  assign lane_rcu_res_c04_s0_stall = '0;
  assign lane_rcu_res_c04_s1_credit = '0;
  assign lane_rcu_res_c04_s1_stall = '0;
  assign lane_rcu_res_c04_s2_credit = '0;
  assign lane_rcu_res_c04_s2_stall = '0;
  assign lane_rcu_res_c04_s3_credit = '0;
  assign lane_rcu_res_c04_s3_stall = '0;
  assign lane_rcu_res_c05_s0_credit = '0;
  assign lane_rcu_res_c05_s0_stall = '0;
  assign lane_rcu_res_c05_s1_credit = '0;
  assign lane_rcu_res_c05_s1_stall = '0;
  assign lane_rcu_res_c05_s2_credit = '0;
  assign lane_rcu_res_c05_s2_stall = '0;
  assign lane_rcu_res_c05_s3_credit = '0;
  assign lane_rcu_res_c05_s3_stall = '0;
  assign lane_rcu_res_c06_s0_credit = '0;
  assign lane_rcu_res_c06_s0_stall = '0;
  assign lane_rcu_res_c06_s1_credit = '0;
  assign lane_rcu_res_c06_s1_stall = '0;
  assign lane_rcu_res_c06_s2_credit = '0;
  assign lane_rcu_res_c06_s2_stall = '0;
  assign lane_rcu_res_c06_s3_credit = '0;
  assign lane_rcu_res_c06_s3_stall = '0;
  assign lane_rcu_res_c07_s0_credit = '0;
  assign lane_rcu_res_c07_s0_stall = '0;
  assign lane_rcu_res_c07_s1_credit = '0;
  assign lane_rcu_res_c07_s1_stall = '0;
  assign lane_rcu_res_c07_s2_credit = '0;
  assign lane_rcu_res_c07_s2_stall = '0;
  assign lane_rcu_res_c07_s3_credit = '0;
  assign lane_rcu_res_c07_s3_stall = '0;
  assign lane_rcu_res_c08_s0_credit = '0;
  assign lane_rcu_res_c08_s0_stall = '0;
  assign lane_rcu_res_c08_s1_credit = '0;
  assign lane_rcu_res_c08_s1_stall = '0;
  assign lane_rcu_res_c08_s2_credit = '0;
  assign lane_rcu_res_c08_s2_stall = '0;
  assign lane_rcu_res_c08_s3_credit = '0;
  assign lane_rcu_res_c08_s3_stall = '0;
  assign lane_rcu_res_c09_s0_credit = '0;
  assign lane_rcu_res_c09_s0_stall = '0;
  assign lane_rcu_res_c09_s1_credit = '0;
  assign lane_rcu_res_c09_s1_stall = '0;
  assign lane_rcu_res_c09_s2_credit = '0;
  assign lane_rcu_res_c09_s2_stall = '0;
  assign lane_rcu_res_c09_s3_credit = '0;
  assign lane_rcu_res_c09_s3_stall = '0;
  assign lane_rcu_res_c10_s0_credit = '0;
  assign lane_rcu_res_c10_s0_stall = '0;
  assign lane_rcu_res_c10_s1_credit = '0;
  assign lane_rcu_res_c10_s1_stall = '0;
  assign lane_rcu_res_c10_s2_credit = '0;
  assign lane_rcu_res_c10_s2_stall = '0;
  assign lane_rcu_res_c10_s3_credit = '0;
  assign lane_rcu_res_c10_s3_stall = '0;
  assign lane_rcu_res_c11_s0_credit = '0;
  assign lane_rcu_res_c11_s0_stall = '0;
  assign lane_rcu_res_c11_s1_credit = '0;
  assign lane_rcu_res_c11_s1_stall = '0;
  assign lane_rcu_res_c11_s2_credit = '0;
  assign lane_rcu_res_c11_s2_stall = '0;
  assign lane_rcu_res_c11_s3_credit = '0;
  assign lane_rcu_res_c11_s3_stall = '0;
  assign lane_rcu_res_c12_s0_credit = '0;
  assign lane_rcu_res_c12_s0_stall = '0;
  assign lane_rcu_res_c12_s1_credit = '0;
  assign lane_rcu_res_c12_s1_stall = '0;
  assign lane_rcu_res_c12_s2_credit = '0;
  assign lane_rcu_res_c12_s2_stall = '0;
  assign lane_rcu_res_c12_s3_credit = '0;
  assign lane_rcu_res_c12_s3_stall = '0;
  assign lane_rcu_res_c13_s0_credit = '0;
  assign lane_rcu_res_c13_s0_stall = '0;
  assign lane_rcu_res_c13_s1_credit = '0;
  assign lane_rcu_res_c13_s1_stall = '0;
  assign lane_rcu_res_c13_s2_credit = '0;
  assign lane_rcu_res_c13_s2_stall = '0;
  assign lane_rcu_res_c13_s3_credit = '0;
  assign lane_rcu_res_c13_s3_stall = '0;
  assign lane_rcu_res_c14_s0_credit = '0;
  assign lane_rcu_res_c14_s0_stall = '0;
  assign lane_rcu_res_c14_s1_credit = '0;
  assign lane_rcu_res_c14_s1_stall = '0;
  assign lane_rcu_res_c14_s2_credit = '0;
  assign lane_rcu_res_c14_s2_stall = '0;
  assign lane_rcu_res_c14_s3_credit = '0;
  assign lane_rcu_res_c14_s3_stall = '0;
  assign lane_rcu_res_c15_s0_credit = '0;
  assign lane_rcu_res_c15_s0_stall = '0;
  assign lane_rcu_res_c15_s1_credit = '0;
  assign lane_rcu_res_c15_s1_stall = '0;
  assign lane_rcu_res_c15_s2_credit = '0;
  assign lane_rcu_res_c15_s2_stall = '0;
  assign lane_rcu_res_c15_s3_credit = '0;
  assign lane_rcu_res_c15_s3_stall = '0;
  assign lane_rcu_res_c16_s0_credit = '0;
  assign lane_rcu_res_c16_s0_stall = '0;
  assign lane_rcu_res_c16_s1_credit = '0;
  assign lane_rcu_res_c16_s1_stall = '0;
  assign lane_rcu_res_c16_s2_credit = '0;
  assign lane_rcu_res_c16_s2_stall = '0;
  assign lane_rcu_res_c16_s3_credit = '0;
  assign lane_rcu_res_c16_s3_stall = '0;
  assign lane_rcu_res_c17_s0_credit = '0;
  assign lane_rcu_res_c17_s0_stall = '0;
  assign lane_rcu_res_c17_s1_credit = '0;
  assign lane_rcu_res_c17_s1_stall = '0;
  assign lane_rcu_res_c17_s2_credit = '0;
  assign lane_rcu_res_c17_s2_stall = '0;
  assign lane_rcu_res_c17_s3_credit = '0;
  assign lane_rcu_res_c17_s3_stall = '0;
  assign lane_rcu_res_c18_s0_credit = '0;
  assign lane_rcu_res_c18_s0_stall = '0;
  assign lane_rcu_res_c18_s1_credit = '0;
  assign lane_rcu_res_c18_s1_stall = '0;
  assign lane_rcu_res_c18_s2_credit = '0;
  assign lane_rcu_res_c18_s2_stall = '0;
  assign lane_rcu_res_c18_s3_credit = '0;
  assign lane_rcu_res_c18_s3_stall = '0;
  assign lane_rcu_res_c19_s0_credit = '0;
  assign lane_rcu_res_c19_s0_stall = '0;
  assign lane_rcu_res_c19_s1_credit = '0;
  assign lane_rcu_res_c19_s1_stall = '0;
  assign lane_rcu_res_c19_s2_credit = '0;
  assign lane_rcu_res_c19_s2_stall = '0;
  assign lane_rcu_res_c19_s3_credit = '0;
  assign lane_rcu_res_c19_s3_stall = '0;
  assign lane_rcu_res_c20_s0_credit = '0;
  assign lane_rcu_res_c20_s0_stall = '0;
  assign lane_rcu_res_c20_s1_credit = '0;
  assign lane_rcu_res_c20_s1_stall = '0;
  assign lane_rcu_res_c20_s2_credit = '0;
  assign lane_rcu_res_c20_s2_stall = '0;
  assign lane_rcu_res_c20_s3_credit = '0;
  assign lane_rcu_res_c20_s3_stall = '0;
  assign lane_rcu_res_c21_s0_credit = '0;
  assign lane_rcu_res_c21_s0_stall = '0;
  assign lane_rcu_res_c21_s1_credit = '0;
  assign lane_rcu_res_c21_s1_stall = '0;
  assign lane_rcu_res_c21_s2_credit = '0;
  assign lane_rcu_res_c21_s2_stall = '0;
  assign lane_rcu_res_c21_s3_credit = '0;
  assign lane_rcu_res_c21_s3_stall = '0;
  assign lane_rcu_res_c22_s0_credit = '0;
  assign lane_rcu_res_c22_s0_stall = '0;
  assign lane_rcu_res_c22_s1_credit = '0;
  assign lane_rcu_res_c22_s1_stall = '0;
  assign lane_rcu_res_c22_s2_credit = '0;
  assign lane_rcu_res_c22_s2_stall = '0;
  assign lane_rcu_res_c22_s3_credit = '0;
  assign lane_rcu_res_c22_s3_stall = '0;
  assign lane_rcu_res_c23_s0_credit = '0;
  assign lane_rcu_res_c23_s0_stall = '0;
  assign lane_rcu_res_c23_s1_credit = '0;
  assign lane_rcu_res_c23_s1_stall = '0;
  assign lane_rcu_res_c23_s2_credit = '0;
  assign lane_rcu_res_c23_s2_stall = '0;
  assign lane_rcu_res_c23_s3_credit = '0;
  assign lane_rcu_res_c23_s3_stall = '0;
  assign lane_rcu_res_c24_s0_credit = '0;
  assign lane_rcu_res_c24_s0_stall = '0;
  assign lane_rcu_res_c24_s1_credit = '0;
  assign lane_rcu_res_c24_s1_stall = '0;
  assign lane_rcu_res_c24_s2_credit = '0;
  assign lane_rcu_res_c24_s2_stall = '0;
  assign lane_rcu_res_c24_s3_credit = '0;
  assign lane_rcu_res_c24_s3_stall = '0;
  assign lane_rcu_res_c25_s0_credit = '0;
  assign lane_rcu_res_c25_s0_stall = '0;
  assign lane_rcu_res_c25_s1_credit = '0;
  assign lane_rcu_res_c25_s1_stall = '0;
  assign lane_rcu_res_c25_s2_credit = '0;
  assign lane_rcu_res_c25_s2_stall = '0;
  assign lane_rcu_res_c25_s3_credit = '0;
  assign lane_rcu_res_c25_s3_stall = '0;
  assign lane_rcu_res_c26_s0_credit = '0;
  assign lane_rcu_res_c26_s0_stall = '0;
  assign lane_rcu_res_c26_s1_credit = '0;
  assign lane_rcu_res_c26_s1_stall = '0;
  assign lane_rcu_res_c26_s2_credit = '0;
  assign lane_rcu_res_c26_s2_stall = '0;
  assign lane_rcu_res_c26_s3_credit = '0;
  assign lane_rcu_res_c26_s3_stall = '0;
  assign lane_rcu_res_c27_s0_credit = '0;
  assign lane_rcu_res_c27_s0_stall = '0;
  assign lane_rcu_res_c27_s1_credit = '0;
  assign lane_rcu_res_c27_s1_stall = '0;
  assign lane_rcu_res_c27_s2_credit = '0;
  assign lane_rcu_res_c27_s2_stall = '0;
  assign lane_rcu_res_c27_s3_credit = '0;
  assign lane_rcu_res_c27_s3_stall = '0;
  assign lane_rcu_res_c28_s0_credit = '0;
  assign lane_rcu_res_c28_s0_stall = '0;
  assign lane_rcu_res_c28_s1_credit = '0;
  assign lane_rcu_res_c28_s1_stall = '0;
  assign lane_rcu_res_c28_s2_credit = '0;
  assign lane_rcu_res_c28_s2_stall = '0;
  assign lane_rcu_res_c28_s3_credit = '0;
  assign lane_rcu_res_c28_s3_stall = '0;
  assign lane_rcu_res_c29_s0_credit = '0;
  assign lane_rcu_res_c29_s0_stall = '0;
  assign lane_rcu_res_c29_s1_credit = '0;
  assign lane_rcu_res_c29_s1_stall = '0;
  assign lane_rcu_res_c29_s2_credit = '0;
  assign lane_rcu_res_c29_s2_stall = '0;
  assign lane_rcu_res_c29_s3_credit = '0;
  assign lane_rcu_res_c29_s3_stall = '0;
  assign lane_rcu_res_c30_s0_credit = '0;
  assign lane_rcu_res_c30_s0_stall = '0;
  assign lane_rcu_res_c30_s1_credit = '0;
  assign lane_rcu_res_c30_s1_stall = '0;
  assign lane_rcu_res_c30_s2_credit = '0;
  assign lane_rcu_res_c30_s2_stall = '0;
  assign lane_rcu_res_c30_s3_credit = '0;
  assign lane_rcu_res_c30_s3_stall = '0;
  assign lane_rcu_res_c31_s0_credit = '0;
  assign lane_rcu_res_c31_s0_stall = '0;
  assign lane_rcu_res_c31_s1_credit = '0;
  assign lane_rcu_res_c31_s1_stall = '0;
  assign lane_rcu_res_c31_s2_credit = '0;
  assign lane_rcu_res_c31_s2_stall = '0;
  assign lane_rcu_res_c31_s3_credit = '0;
  assign lane_rcu_res_c31_s3_stall = '0;
  assign rcu_ooe_done_s0_valid = '0;
  assign rcu_ooe_done_s0_payload = '0;
  assign rcu_ooe_done_s1_valid = '0;
  assign rcu_ooe_done_s1_payload = '0;
  assign rcu_ooe_done_s2_valid = '0;
  assign rcu_ooe_done_s2_payload = '0;
  assign rcu_ooe_done_s3_valid = '0;
  assign rcu_ooe_done_s3_payload = '0;
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
