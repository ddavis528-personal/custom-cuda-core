// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_rcu_w: ccv_rcu and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. Every
// end has its repeater whether or not the link is repeated.
// STAGES is a parameter the top sets from params/links.json, 0 meaning
// wires, so a new split changes parameters and never this structure.
`include "ccv_interfaces.svh"

module ccv_rcu_w #(
  parameter int RPT_OOE_RCU_ISSUE = 0,
  parameter int RPT_RCU_LANE_OPS_C00 = 0,
  parameter int RPT_RCU_LANE_OPS_C01 = 0,
  parameter int RPT_RCU_LANE_OPS_C02 = 0,
  parameter int RPT_RCU_LANE_OPS_C03 = 0,
  parameter int RPT_RCU_LANE_OPS_C04 = 0,
  parameter int RPT_RCU_LANE_OPS_C05 = 0,
  parameter int RPT_RCU_LANE_OPS_C06 = 0,
  parameter int RPT_RCU_LANE_OPS_C07 = 0,
  parameter int RPT_RCU_LANE_OPS_C08 = 0,
  parameter int RPT_RCU_LANE_OPS_C09 = 0,
  parameter int RPT_RCU_LANE_OPS_C10 = 0,
  parameter int RPT_RCU_LANE_OPS_C11 = 0,
  parameter int RPT_RCU_LANE_OPS_C12 = 0,
  parameter int RPT_RCU_LANE_OPS_C13 = 0,
  parameter int RPT_RCU_LANE_OPS_C14 = 0,
  parameter int RPT_RCU_LANE_OPS_C15 = 0,
  parameter int RPT_RCU_LANE_OPS_C16 = 0,
  parameter int RPT_RCU_LANE_OPS_C17 = 0,
  parameter int RPT_RCU_LANE_OPS_C18 = 0,
  parameter int RPT_RCU_LANE_OPS_C19 = 0,
  parameter int RPT_RCU_LANE_OPS_C20 = 0,
  parameter int RPT_RCU_LANE_OPS_C21 = 0,
  parameter int RPT_RCU_LANE_OPS_C22 = 0,
  parameter int RPT_RCU_LANE_OPS_C23 = 0,
  parameter int RPT_RCU_LANE_OPS_C24 = 0,
  parameter int RPT_RCU_LANE_OPS_C25 = 0,
  parameter int RPT_RCU_LANE_OPS_C26 = 0,
  parameter int RPT_RCU_LANE_OPS_C27 = 0,
  parameter int RPT_RCU_LANE_OPS_C28 = 0,
  parameter int RPT_RCU_LANE_OPS_C29 = 0,
  parameter int RPT_RCU_LANE_OPS_C30 = 0,
  parameter int RPT_RCU_LANE_OPS_C31 = 0,
  parameter int RPT_LANE_RCU_RES_C00 = 0,
  parameter int RPT_LANE_RCU_RES_C01 = 0,
  parameter int RPT_LANE_RCU_RES_C02 = 0,
  parameter int RPT_LANE_RCU_RES_C03 = 0,
  parameter int RPT_LANE_RCU_RES_C04 = 0,
  parameter int RPT_LANE_RCU_RES_C05 = 0,
  parameter int RPT_LANE_RCU_RES_C06 = 0,
  parameter int RPT_LANE_RCU_RES_C07 = 0,
  parameter int RPT_LANE_RCU_RES_C08 = 0,
  parameter int RPT_LANE_RCU_RES_C09 = 0,
  parameter int RPT_LANE_RCU_RES_C10 = 0,
  parameter int RPT_LANE_RCU_RES_C11 = 0,
  parameter int RPT_LANE_RCU_RES_C12 = 0,
  parameter int RPT_LANE_RCU_RES_C13 = 0,
  parameter int RPT_LANE_RCU_RES_C14 = 0,
  parameter int RPT_LANE_RCU_RES_C15 = 0,
  parameter int RPT_LANE_RCU_RES_C16 = 0,
  parameter int RPT_LANE_RCU_RES_C17 = 0,
  parameter int RPT_LANE_RCU_RES_C18 = 0,
  parameter int RPT_LANE_RCU_RES_C19 = 0,
  parameter int RPT_LANE_RCU_RES_C20 = 0,
  parameter int RPT_LANE_RCU_RES_C21 = 0,
  parameter int RPT_LANE_RCU_RES_C22 = 0,
  parameter int RPT_LANE_RCU_RES_C23 = 0,
  parameter int RPT_LANE_RCU_RES_C24 = 0,
  parameter int RPT_LANE_RCU_RES_C25 = 0,
  parameter int RPT_LANE_RCU_RES_C26 = 0,
  parameter int RPT_LANE_RCU_RES_C27 = 0,
  parameter int RPT_LANE_RCU_RES_C28 = 0,
  parameter int RPT_LANE_RCU_RES_C29 = 0,
  parameter int RPT_LANE_RCU_RES_C30 = 0,
  parameter int RPT_LANE_RCU_RES_C31 = 0,
  parameter int RPT_RCU_OOE_DONE = 0,
  parameter int RPT_RCU_MIU_ADDR = 0,
  parameter int RPT_MIU_RCU_DATA = 0,
  parameter int RPT_RAU_RCU_MIG = 0,
  parameter int RPT_OOE_RCU_MAP = 0,
  parameter int RPT_RCU_PCA_MIG = 0,
  parameter int RPT_PCA_RCU_MIG = 0
) (
  `include "ccv_rcu_ports.svh"
);

  // Between the block and its repeaters: b_<port>, one net per port.
  logic b_ooe_rcu_issue_s0_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s0_payload;
  logic b_ooe_rcu_issue_s0_credit;
  logic b_ooe_rcu_issue_s0_stall;
  logic b_ooe_rcu_issue_s1_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s1_payload;
  logic b_ooe_rcu_issue_s1_credit;
  logic b_ooe_rcu_issue_s1_stall;
  logic b_ooe_rcu_issue_s2_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s2_payload;
  logic b_ooe_rcu_issue_s2_credit;
  logic b_ooe_rcu_issue_s2_stall;
  logic b_ooe_rcu_issue_s3_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s3_payload;
  logic b_ooe_rcu_issue_s3_credit;
  logic b_ooe_rcu_issue_s3_stall;
  logic b_ooe_rcu_issue_s4_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s4_payload;
  logic b_ooe_rcu_issue_s4_credit;
  logic b_ooe_rcu_issue_s4_stall;
  logic b_ooe_rcu_issue_s5_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s5_payload;
  logic b_ooe_rcu_issue_s5_credit;
  logic b_ooe_rcu_issue_s5_stall;
  logic b_ooe_rcu_issue_s6_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s6_payload;
  logic b_ooe_rcu_issue_s6_credit;
  logic b_ooe_rcu_issue_s6_stall;
  logic b_ooe_rcu_issue_s7_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s7_payload;
  logic b_ooe_rcu_issue_s7_credit;
  logic b_ooe_rcu_issue_s7_stall;
  logic b_ooe_rcu_issue_s8_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s8_payload;
  logic b_ooe_rcu_issue_s8_credit;
  logic b_ooe_rcu_issue_s8_stall;
  logic b_ooe_rcu_issue_wake;
  logic b_rcu_lane_ops_c00_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c00_payload;
  logic b_rcu_lane_ops_c00_credit;
  logic b_rcu_lane_ops_c00_stall;
  logic b_rcu_lane_ops_c00_wake;
  logic b_rcu_lane_ops_c01_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c01_payload;
  logic b_rcu_lane_ops_c01_credit;
  logic b_rcu_lane_ops_c01_stall;
  logic b_rcu_lane_ops_c01_wake;
  logic b_rcu_lane_ops_c02_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c02_payload;
  logic b_rcu_lane_ops_c02_credit;
  logic b_rcu_lane_ops_c02_stall;
  logic b_rcu_lane_ops_c02_wake;
  logic b_rcu_lane_ops_c03_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c03_payload;
  logic b_rcu_lane_ops_c03_credit;
  logic b_rcu_lane_ops_c03_stall;
  logic b_rcu_lane_ops_c03_wake;
  logic b_rcu_lane_ops_c04_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c04_payload;
  logic b_rcu_lane_ops_c04_credit;
  logic b_rcu_lane_ops_c04_stall;
  logic b_rcu_lane_ops_c04_wake;
  logic b_rcu_lane_ops_c05_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c05_payload;
  logic b_rcu_lane_ops_c05_credit;
  logic b_rcu_lane_ops_c05_stall;
  logic b_rcu_lane_ops_c05_wake;
  logic b_rcu_lane_ops_c06_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c06_payload;
  logic b_rcu_lane_ops_c06_credit;
  logic b_rcu_lane_ops_c06_stall;
  logic b_rcu_lane_ops_c06_wake;
  logic b_rcu_lane_ops_c07_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c07_payload;
  logic b_rcu_lane_ops_c07_credit;
  logic b_rcu_lane_ops_c07_stall;
  logic b_rcu_lane_ops_c07_wake;
  logic b_rcu_lane_ops_c08_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c08_payload;
  logic b_rcu_lane_ops_c08_credit;
  logic b_rcu_lane_ops_c08_stall;
  logic b_rcu_lane_ops_c08_wake;
  logic b_rcu_lane_ops_c09_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c09_payload;
  logic b_rcu_lane_ops_c09_credit;
  logic b_rcu_lane_ops_c09_stall;
  logic b_rcu_lane_ops_c09_wake;
  logic b_rcu_lane_ops_c10_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c10_payload;
  logic b_rcu_lane_ops_c10_credit;
  logic b_rcu_lane_ops_c10_stall;
  logic b_rcu_lane_ops_c10_wake;
  logic b_rcu_lane_ops_c11_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c11_payload;
  logic b_rcu_lane_ops_c11_credit;
  logic b_rcu_lane_ops_c11_stall;
  logic b_rcu_lane_ops_c11_wake;
  logic b_rcu_lane_ops_c12_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c12_payload;
  logic b_rcu_lane_ops_c12_credit;
  logic b_rcu_lane_ops_c12_stall;
  logic b_rcu_lane_ops_c12_wake;
  logic b_rcu_lane_ops_c13_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c13_payload;
  logic b_rcu_lane_ops_c13_credit;
  logic b_rcu_lane_ops_c13_stall;
  logic b_rcu_lane_ops_c13_wake;
  logic b_rcu_lane_ops_c14_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c14_payload;
  logic b_rcu_lane_ops_c14_credit;
  logic b_rcu_lane_ops_c14_stall;
  logic b_rcu_lane_ops_c14_wake;
  logic b_rcu_lane_ops_c15_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c15_payload;
  logic b_rcu_lane_ops_c15_credit;
  logic b_rcu_lane_ops_c15_stall;
  logic b_rcu_lane_ops_c15_wake;
  logic b_rcu_lane_ops_c16_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c16_payload;
  logic b_rcu_lane_ops_c16_credit;
  logic b_rcu_lane_ops_c16_stall;
  logic b_rcu_lane_ops_c16_wake;
  logic b_rcu_lane_ops_c17_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c17_payload;
  logic b_rcu_lane_ops_c17_credit;
  logic b_rcu_lane_ops_c17_stall;
  logic b_rcu_lane_ops_c17_wake;
  logic b_rcu_lane_ops_c18_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c18_payload;
  logic b_rcu_lane_ops_c18_credit;
  logic b_rcu_lane_ops_c18_stall;
  logic b_rcu_lane_ops_c18_wake;
  logic b_rcu_lane_ops_c19_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c19_payload;
  logic b_rcu_lane_ops_c19_credit;
  logic b_rcu_lane_ops_c19_stall;
  logic b_rcu_lane_ops_c19_wake;
  logic b_rcu_lane_ops_c20_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c20_payload;
  logic b_rcu_lane_ops_c20_credit;
  logic b_rcu_lane_ops_c20_stall;
  logic b_rcu_lane_ops_c20_wake;
  logic b_rcu_lane_ops_c21_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c21_payload;
  logic b_rcu_lane_ops_c21_credit;
  logic b_rcu_lane_ops_c21_stall;
  logic b_rcu_lane_ops_c21_wake;
  logic b_rcu_lane_ops_c22_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c22_payload;
  logic b_rcu_lane_ops_c22_credit;
  logic b_rcu_lane_ops_c22_stall;
  logic b_rcu_lane_ops_c22_wake;
  logic b_rcu_lane_ops_c23_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c23_payload;
  logic b_rcu_lane_ops_c23_credit;
  logic b_rcu_lane_ops_c23_stall;
  logic b_rcu_lane_ops_c23_wake;
  logic b_rcu_lane_ops_c24_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c24_payload;
  logic b_rcu_lane_ops_c24_credit;
  logic b_rcu_lane_ops_c24_stall;
  logic b_rcu_lane_ops_c24_wake;
  logic b_rcu_lane_ops_c25_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c25_payload;
  logic b_rcu_lane_ops_c25_credit;
  logic b_rcu_lane_ops_c25_stall;
  logic b_rcu_lane_ops_c25_wake;
  logic b_rcu_lane_ops_c26_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c26_payload;
  logic b_rcu_lane_ops_c26_credit;
  logic b_rcu_lane_ops_c26_stall;
  logic b_rcu_lane_ops_c26_wake;
  logic b_rcu_lane_ops_c27_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c27_payload;
  logic b_rcu_lane_ops_c27_credit;
  logic b_rcu_lane_ops_c27_stall;
  logic b_rcu_lane_ops_c27_wake;
  logic b_rcu_lane_ops_c28_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c28_payload;
  logic b_rcu_lane_ops_c28_credit;
  logic b_rcu_lane_ops_c28_stall;
  logic b_rcu_lane_ops_c28_wake;
  logic b_rcu_lane_ops_c29_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c29_payload;
  logic b_rcu_lane_ops_c29_credit;
  logic b_rcu_lane_ops_c29_stall;
  logic b_rcu_lane_ops_c29_wake;
  logic b_rcu_lane_ops_c30_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c30_payload;
  logic b_rcu_lane_ops_c30_credit;
  logic b_rcu_lane_ops_c30_stall;
  logic b_rcu_lane_ops_c30_wake;
  logic b_rcu_lane_ops_c31_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c31_payload;
  logic b_rcu_lane_ops_c31_credit;
  logic b_rcu_lane_ops_c31_stall;
  logic b_rcu_lane_ops_c31_wake;
  logic b_lane_rcu_res_c00_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c00_payload;
  logic b_lane_rcu_res_c00_credit;
  logic b_lane_rcu_res_c00_stall;
  logic b_lane_rcu_res_c00_wake;
  logic b_lane_rcu_res_c01_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c01_payload;
  logic b_lane_rcu_res_c01_credit;
  logic b_lane_rcu_res_c01_stall;
  logic b_lane_rcu_res_c01_wake;
  logic b_lane_rcu_res_c02_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c02_payload;
  logic b_lane_rcu_res_c02_credit;
  logic b_lane_rcu_res_c02_stall;
  logic b_lane_rcu_res_c02_wake;
  logic b_lane_rcu_res_c03_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c03_payload;
  logic b_lane_rcu_res_c03_credit;
  logic b_lane_rcu_res_c03_stall;
  logic b_lane_rcu_res_c03_wake;
  logic b_lane_rcu_res_c04_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c04_payload;
  logic b_lane_rcu_res_c04_credit;
  logic b_lane_rcu_res_c04_stall;
  logic b_lane_rcu_res_c04_wake;
  logic b_lane_rcu_res_c05_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c05_payload;
  logic b_lane_rcu_res_c05_credit;
  logic b_lane_rcu_res_c05_stall;
  logic b_lane_rcu_res_c05_wake;
  logic b_lane_rcu_res_c06_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c06_payload;
  logic b_lane_rcu_res_c06_credit;
  logic b_lane_rcu_res_c06_stall;
  logic b_lane_rcu_res_c06_wake;
  logic b_lane_rcu_res_c07_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c07_payload;
  logic b_lane_rcu_res_c07_credit;
  logic b_lane_rcu_res_c07_stall;
  logic b_lane_rcu_res_c07_wake;
  logic b_lane_rcu_res_c08_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c08_payload;
  logic b_lane_rcu_res_c08_credit;
  logic b_lane_rcu_res_c08_stall;
  logic b_lane_rcu_res_c08_wake;
  logic b_lane_rcu_res_c09_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c09_payload;
  logic b_lane_rcu_res_c09_credit;
  logic b_lane_rcu_res_c09_stall;
  logic b_lane_rcu_res_c09_wake;
  logic b_lane_rcu_res_c10_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c10_payload;
  logic b_lane_rcu_res_c10_credit;
  logic b_lane_rcu_res_c10_stall;
  logic b_lane_rcu_res_c10_wake;
  logic b_lane_rcu_res_c11_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c11_payload;
  logic b_lane_rcu_res_c11_credit;
  logic b_lane_rcu_res_c11_stall;
  logic b_lane_rcu_res_c11_wake;
  logic b_lane_rcu_res_c12_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c12_payload;
  logic b_lane_rcu_res_c12_credit;
  logic b_lane_rcu_res_c12_stall;
  logic b_lane_rcu_res_c12_wake;
  logic b_lane_rcu_res_c13_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c13_payload;
  logic b_lane_rcu_res_c13_credit;
  logic b_lane_rcu_res_c13_stall;
  logic b_lane_rcu_res_c13_wake;
  logic b_lane_rcu_res_c14_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c14_payload;
  logic b_lane_rcu_res_c14_credit;
  logic b_lane_rcu_res_c14_stall;
  logic b_lane_rcu_res_c14_wake;
  logic b_lane_rcu_res_c15_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c15_payload;
  logic b_lane_rcu_res_c15_credit;
  logic b_lane_rcu_res_c15_stall;
  logic b_lane_rcu_res_c15_wake;
  logic b_lane_rcu_res_c16_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c16_payload;
  logic b_lane_rcu_res_c16_credit;
  logic b_lane_rcu_res_c16_stall;
  logic b_lane_rcu_res_c16_wake;
  logic b_lane_rcu_res_c17_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c17_payload;
  logic b_lane_rcu_res_c17_credit;
  logic b_lane_rcu_res_c17_stall;
  logic b_lane_rcu_res_c17_wake;
  logic b_lane_rcu_res_c18_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c18_payload;
  logic b_lane_rcu_res_c18_credit;
  logic b_lane_rcu_res_c18_stall;
  logic b_lane_rcu_res_c18_wake;
  logic b_lane_rcu_res_c19_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c19_payload;
  logic b_lane_rcu_res_c19_credit;
  logic b_lane_rcu_res_c19_stall;
  logic b_lane_rcu_res_c19_wake;
  logic b_lane_rcu_res_c20_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c20_payload;
  logic b_lane_rcu_res_c20_credit;
  logic b_lane_rcu_res_c20_stall;
  logic b_lane_rcu_res_c20_wake;
  logic b_lane_rcu_res_c21_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c21_payload;
  logic b_lane_rcu_res_c21_credit;
  logic b_lane_rcu_res_c21_stall;
  logic b_lane_rcu_res_c21_wake;
  logic b_lane_rcu_res_c22_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c22_payload;
  logic b_lane_rcu_res_c22_credit;
  logic b_lane_rcu_res_c22_stall;
  logic b_lane_rcu_res_c22_wake;
  logic b_lane_rcu_res_c23_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c23_payload;
  logic b_lane_rcu_res_c23_credit;
  logic b_lane_rcu_res_c23_stall;
  logic b_lane_rcu_res_c23_wake;
  logic b_lane_rcu_res_c24_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c24_payload;
  logic b_lane_rcu_res_c24_credit;
  logic b_lane_rcu_res_c24_stall;
  logic b_lane_rcu_res_c24_wake;
  logic b_lane_rcu_res_c25_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c25_payload;
  logic b_lane_rcu_res_c25_credit;
  logic b_lane_rcu_res_c25_stall;
  logic b_lane_rcu_res_c25_wake;
  logic b_lane_rcu_res_c26_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c26_payload;
  logic b_lane_rcu_res_c26_credit;
  logic b_lane_rcu_res_c26_stall;
  logic b_lane_rcu_res_c26_wake;
  logic b_lane_rcu_res_c27_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c27_payload;
  logic b_lane_rcu_res_c27_credit;
  logic b_lane_rcu_res_c27_stall;
  logic b_lane_rcu_res_c27_wake;
  logic b_lane_rcu_res_c28_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c28_payload;
  logic b_lane_rcu_res_c28_credit;
  logic b_lane_rcu_res_c28_stall;
  logic b_lane_rcu_res_c28_wake;
  logic b_lane_rcu_res_c29_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c29_payload;
  logic b_lane_rcu_res_c29_credit;
  logic b_lane_rcu_res_c29_stall;
  logic b_lane_rcu_res_c29_wake;
  logic b_lane_rcu_res_c30_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c30_payload;
  logic b_lane_rcu_res_c30_credit;
  logic b_lane_rcu_res_c30_stall;
  logic b_lane_rcu_res_c30_wake;
  logic b_lane_rcu_res_c31_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c31_payload;
  logic b_lane_rcu_res_c31_credit;
  logic b_lane_rcu_res_c31_stall;
  logic b_lane_rcu_res_c31_wake;
  logic b_rcu_ooe_done_s0_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s0_payload;
  logic b_rcu_ooe_done_s0_credit;
  logic b_rcu_ooe_done_s0_stall;
  logic b_rcu_ooe_done_s1_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s1_payload;
  logic b_rcu_ooe_done_s1_credit;
  logic b_rcu_ooe_done_s1_stall;
  logic b_rcu_ooe_done_s2_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s2_payload;
  logic b_rcu_ooe_done_s2_credit;
  logic b_rcu_ooe_done_s2_stall;
  logic b_rcu_ooe_done_s3_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s3_payload;
  logic b_rcu_ooe_done_s3_credit;
  logic b_rcu_ooe_done_s3_stall;
  logic b_rcu_ooe_done_s4_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s4_payload;
  logic b_rcu_ooe_done_s4_credit;
  logic b_rcu_ooe_done_s4_stall;
  logic b_rcu_ooe_done_s5_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s5_payload;
  logic b_rcu_ooe_done_s5_credit;
  logic b_rcu_ooe_done_s5_stall;
  logic b_rcu_ooe_done_s6_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s6_payload;
  logic b_rcu_ooe_done_s6_credit;
  logic b_rcu_ooe_done_s6_stall;
  logic b_rcu_ooe_done_wake;
  logic b_rcu_miu_addr_s0_valid;
  ccv_rcu_miu_addr_t b_rcu_miu_addr_s0_payload;
  logic b_rcu_miu_addr_s0_credit;
  logic b_rcu_miu_addr_s0_stall;
  logic b_rcu_miu_addr_s1_valid;
  ccv_rcu_miu_addr_t b_rcu_miu_addr_s1_payload;
  logic b_rcu_miu_addr_s1_credit;
  logic b_rcu_miu_addr_s1_stall;
  logic b_rcu_miu_addr_s2_valid;
  ccv_rcu_miu_addr_t b_rcu_miu_addr_s2_payload;
  logic b_rcu_miu_addr_s2_credit;
  logic b_rcu_miu_addr_s2_stall;
  logic b_rcu_miu_addr_s3_valid;
  ccv_rcu_miu_addr_t b_rcu_miu_addr_s3_payload;
  logic b_rcu_miu_addr_s3_credit;
  logic b_rcu_miu_addr_s3_stall;
  logic b_rcu_miu_addr_wake;
  logic b_miu_rcu_data_s0_valid;
  ccv_miu_rcu_data_t b_miu_rcu_data_s0_payload;
  logic b_miu_rcu_data_s0_credit;
  logic b_miu_rcu_data_s0_stall;
  logic b_miu_rcu_data_s1_valid;
  ccv_miu_rcu_data_t b_miu_rcu_data_s1_payload;
  logic b_miu_rcu_data_s1_credit;
  logic b_miu_rcu_data_s1_stall;
  logic b_miu_rcu_data_s2_valid;
  ccv_miu_rcu_data_t b_miu_rcu_data_s2_payload;
  logic b_miu_rcu_data_s2_credit;
  logic b_miu_rcu_data_s2_stall;
  logic b_miu_rcu_data_s3_valid;
  ccv_miu_rcu_data_t b_miu_rcu_data_s3_payload;
  logic b_miu_rcu_data_s3_credit;
  logic b_miu_rcu_data_s3_stall;
  logic b_miu_rcu_data_wake;
  logic b_rau_rcu_mig_valid;
  ccv_rau_rcu_mig_t b_rau_rcu_mig_payload;
  logic b_rau_rcu_mig_credit;
  logic b_rau_rcu_mig_stall;
  logic b_rau_rcu_mig_wake;
  logic b_ooe_rcu_map_valid;
  ccv_ooe_rcu_map_t b_ooe_rcu_map_payload;
  logic b_ooe_rcu_map_credit;
  logic b_ooe_rcu_map_stall;
  logic b_ooe_rcu_map_wake;
  logic b_rcu_pca_mig_valid;
  ccv_rcu_pca_mig_t b_rcu_pca_mig_payload;
  logic b_rcu_pca_mig_credit;
  logic b_rcu_pca_mig_stall;
  logic b_rcu_pca_mig_wake;
  logic b_pca_rcu_mig_valid;
  ccv_pca_rcu_mig_t b_pca_rcu_mig_payload;
  logic b_pca_rcu_mig_credit;
  logic b_pca_rcu_mig_stall;
  logic b_pca_rcu_mig_wake;
`ifdef CCV_TRACE
  logic [63:0] b_ooe_rcu_issue_s0_tid;
  logic [63:0] b_ooe_rcu_issue_s1_tid;
  logic [63:0] b_ooe_rcu_issue_s2_tid;
  logic [63:0] b_ooe_rcu_issue_s3_tid;
  logic [63:0] b_ooe_rcu_issue_s4_tid;
  logic [63:0] b_ooe_rcu_issue_s5_tid;
  logic [63:0] b_ooe_rcu_issue_s6_tid;
  logic [63:0] b_ooe_rcu_issue_s7_tid;
  logic [63:0] b_ooe_rcu_issue_s8_tid;
  logic [63:0] b_rcu_lane_ops_c00_tid;
  logic [63:0] b_rcu_lane_ops_c01_tid;
  logic [63:0] b_rcu_lane_ops_c02_tid;
  logic [63:0] b_rcu_lane_ops_c03_tid;
  logic [63:0] b_rcu_lane_ops_c04_tid;
  logic [63:0] b_rcu_lane_ops_c05_tid;
  logic [63:0] b_rcu_lane_ops_c06_tid;
  logic [63:0] b_rcu_lane_ops_c07_tid;
  logic [63:0] b_rcu_lane_ops_c08_tid;
  logic [63:0] b_rcu_lane_ops_c09_tid;
  logic [63:0] b_rcu_lane_ops_c10_tid;
  logic [63:0] b_rcu_lane_ops_c11_tid;
  logic [63:0] b_rcu_lane_ops_c12_tid;
  logic [63:0] b_rcu_lane_ops_c13_tid;
  logic [63:0] b_rcu_lane_ops_c14_tid;
  logic [63:0] b_rcu_lane_ops_c15_tid;
  logic [63:0] b_rcu_lane_ops_c16_tid;
  logic [63:0] b_rcu_lane_ops_c17_tid;
  logic [63:0] b_rcu_lane_ops_c18_tid;
  logic [63:0] b_rcu_lane_ops_c19_tid;
  logic [63:0] b_rcu_lane_ops_c20_tid;
  logic [63:0] b_rcu_lane_ops_c21_tid;
  logic [63:0] b_rcu_lane_ops_c22_tid;
  logic [63:0] b_rcu_lane_ops_c23_tid;
  logic [63:0] b_rcu_lane_ops_c24_tid;
  logic [63:0] b_rcu_lane_ops_c25_tid;
  logic [63:0] b_rcu_lane_ops_c26_tid;
  logic [63:0] b_rcu_lane_ops_c27_tid;
  logic [63:0] b_rcu_lane_ops_c28_tid;
  logic [63:0] b_rcu_lane_ops_c29_tid;
  logic [63:0] b_rcu_lane_ops_c30_tid;
  logic [63:0] b_rcu_lane_ops_c31_tid;
  logic [63:0] b_lane_rcu_res_c00_tid;
  logic [63:0] b_lane_rcu_res_c01_tid;
  logic [63:0] b_lane_rcu_res_c02_tid;
  logic [63:0] b_lane_rcu_res_c03_tid;
  logic [63:0] b_lane_rcu_res_c04_tid;
  logic [63:0] b_lane_rcu_res_c05_tid;
  logic [63:0] b_lane_rcu_res_c06_tid;
  logic [63:0] b_lane_rcu_res_c07_tid;
  logic [63:0] b_lane_rcu_res_c08_tid;
  logic [63:0] b_lane_rcu_res_c09_tid;
  logic [63:0] b_lane_rcu_res_c10_tid;
  logic [63:0] b_lane_rcu_res_c11_tid;
  logic [63:0] b_lane_rcu_res_c12_tid;
  logic [63:0] b_lane_rcu_res_c13_tid;
  logic [63:0] b_lane_rcu_res_c14_tid;
  logic [63:0] b_lane_rcu_res_c15_tid;
  logic [63:0] b_lane_rcu_res_c16_tid;
  logic [63:0] b_lane_rcu_res_c17_tid;
  logic [63:0] b_lane_rcu_res_c18_tid;
  logic [63:0] b_lane_rcu_res_c19_tid;
  logic [63:0] b_lane_rcu_res_c20_tid;
  logic [63:0] b_lane_rcu_res_c21_tid;
  logic [63:0] b_lane_rcu_res_c22_tid;
  logic [63:0] b_lane_rcu_res_c23_tid;
  logic [63:0] b_lane_rcu_res_c24_tid;
  logic [63:0] b_lane_rcu_res_c25_tid;
  logic [63:0] b_lane_rcu_res_c26_tid;
  logic [63:0] b_lane_rcu_res_c27_tid;
  logic [63:0] b_lane_rcu_res_c28_tid;
  logic [63:0] b_lane_rcu_res_c29_tid;
  logic [63:0] b_lane_rcu_res_c30_tid;
  logic [63:0] b_lane_rcu_res_c31_tid;
  logic [63:0] b_rcu_ooe_done_s0_tid;
  logic [63:0] b_rcu_ooe_done_s1_tid;
  logic [63:0] b_rcu_ooe_done_s2_tid;
  logic [63:0] b_rcu_ooe_done_s3_tid;
  logic [63:0] b_rcu_ooe_done_s4_tid;
  logic [63:0] b_rcu_ooe_done_s5_tid;
  logic [63:0] b_rcu_ooe_done_s6_tid;
  logic [63:0] b_rcu_miu_addr_s0_tid;
  logic [63:0] b_rcu_miu_addr_s1_tid;
  logic [63:0] b_rcu_miu_addr_s2_tid;
  logic [63:0] b_rcu_miu_addr_s3_tid;
  logic [63:0] b_miu_rcu_data_s0_tid;
  logic [63:0] b_miu_rcu_data_s1_tid;
  logic [63:0] b_miu_rcu_data_s2_tid;
  logic [63:0] b_miu_rcu_data_s3_tid;
  logic [63:0] b_rau_rcu_mig_tid;
  logic [63:0] b_ooe_rcu_map_tid;
  logic [63:0] b_rcu_pca_mig_tid;
  logic [63:0] b_pca_rcu_mig_tid;
`endif

  ccv_rcu u_blk (
    .core_clk(core_clk),
    .rst_n(rst_n),
    .kill_valid(kill_valid),
    .kill_warp_mask(kill_warp_mask),
    .kill_epoch(kill_epoch),
    .kill_ack(kill_ack),
    .kill_ack_epoch(kill_ack_epoch),
    .csr_req(csr_req),
    .csr_rsp(csr_rsp),
    .csr_credit(csr_credit),
    .ooe_rcu_issue_s0_valid(b_ooe_rcu_issue_s0_valid),
    .ooe_rcu_issue_s0_payload(b_ooe_rcu_issue_s0_payload),
    .ooe_rcu_issue_s0_credit(b_ooe_rcu_issue_s0_credit),
    .ooe_rcu_issue_s0_stall(b_ooe_rcu_issue_s0_stall),
    .ooe_rcu_issue_s1_valid(b_ooe_rcu_issue_s1_valid),
    .ooe_rcu_issue_s1_payload(b_ooe_rcu_issue_s1_payload),
    .ooe_rcu_issue_s1_credit(b_ooe_rcu_issue_s1_credit),
    .ooe_rcu_issue_s1_stall(b_ooe_rcu_issue_s1_stall),
    .ooe_rcu_issue_s2_valid(b_ooe_rcu_issue_s2_valid),
    .ooe_rcu_issue_s2_payload(b_ooe_rcu_issue_s2_payload),
    .ooe_rcu_issue_s2_credit(b_ooe_rcu_issue_s2_credit),
    .ooe_rcu_issue_s2_stall(b_ooe_rcu_issue_s2_stall),
    .ooe_rcu_issue_s3_valid(b_ooe_rcu_issue_s3_valid),
    .ooe_rcu_issue_s3_payload(b_ooe_rcu_issue_s3_payload),
    .ooe_rcu_issue_s3_credit(b_ooe_rcu_issue_s3_credit),
    .ooe_rcu_issue_s3_stall(b_ooe_rcu_issue_s3_stall),
    .ooe_rcu_issue_s4_valid(b_ooe_rcu_issue_s4_valid),
    .ooe_rcu_issue_s4_payload(b_ooe_rcu_issue_s4_payload),
    .ooe_rcu_issue_s4_credit(b_ooe_rcu_issue_s4_credit),
    .ooe_rcu_issue_s4_stall(b_ooe_rcu_issue_s4_stall),
    .ooe_rcu_issue_s5_valid(b_ooe_rcu_issue_s5_valid),
    .ooe_rcu_issue_s5_payload(b_ooe_rcu_issue_s5_payload),
    .ooe_rcu_issue_s5_credit(b_ooe_rcu_issue_s5_credit),
    .ooe_rcu_issue_s5_stall(b_ooe_rcu_issue_s5_stall),
    .ooe_rcu_issue_s6_valid(b_ooe_rcu_issue_s6_valid),
    .ooe_rcu_issue_s6_payload(b_ooe_rcu_issue_s6_payload),
    .ooe_rcu_issue_s6_credit(b_ooe_rcu_issue_s6_credit),
    .ooe_rcu_issue_s6_stall(b_ooe_rcu_issue_s6_stall),
    .ooe_rcu_issue_s7_valid(b_ooe_rcu_issue_s7_valid),
    .ooe_rcu_issue_s7_payload(b_ooe_rcu_issue_s7_payload),
    .ooe_rcu_issue_s7_credit(b_ooe_rcu_issue_s7_credit),
    .ooe_rcu_issue_s7_stall(b_ooe_rcu_issue_s7_stall),
    .ooe_rcu_issue_s8_valid(b_ooe_rcu_issue_s8_valid),
    .ooe_rcu_issue_s8_payload(b_ooe_rcu_issue_s8_payload),
    .ooe_rcu_issue_s8_credit(b_ooe_rcu_issue_s8_credit),
    .ooe_rcu_issue_s8_stall(b_ooe_rcu_issue_s8_stall),
    .ooe_rcu_issue_wake(b_ooe_rcu_issue_wake),
    .rcu_lane_ops_c00_valid(b_rcu_lane_ops_c00_valid),
    .rcu_lane_ops_c00_payload(b_rcu_lane_ops_c00_payload),
    .rcu_lane_ops_c00_credit(b_rcu_lane_ops_c00_credit),
    .rcu_lane_ops_c00_stall(b_rcu_lane_ops_c00_stall),
    .rcu_lane_ops_c00_wake(b_rcu_lane_ops_c00_wake),
    .rcu_lane_ops_c01_valid(b_rcu_lane_ops_c01_valid),
    .rcu_lane_ops_c01_payload(b_rcu_lane_ops_c01_payload),
    .rcu_lane_ops_c01_credit(b_rcu_lane_ops_c01_credit),
    .rcu_lane_ops_c01_stall(b_rcu_lane_ops_c01_stall),
    .rcu_lane_ops_c01_wake(b_rcu_lane_ops_c01_wake),
    .rcu_lane_ops_c02_valid(b_rcu_lane_ops_c02_valid),
    .rcu_lane_ops_c02_payload(b_rcu_lane_ops_c02_payload),
    .rcu_lane_ops_c02_credit(b_rcu_lane_ops_c02_credit),
    .rcu_lane_ops_c02_stall(b_rcu_lane_ops_c02_stall),
    .rcu_lane_ops_c02_wake(b_rcu_lane_ops_c02_wake),
    .rcu_lane_ops_c03_valid(b_rcu_lane_ops_c03_valid),
    .rcu_lane_ops_c03_payload(b_rcu_lane_ops_c03_payload),
    .rcu_lane_ops_c03_credit(b_rcu_lane_ops_c03_credit),
    .rcu_lane_ops_c03_stall(b_rcu_lane_ops_c03_stall),
    .rcu_lane_ops_c03_wake(b_rcu_lane_ops_c03_wake),
    .rcu_lane_ops_c04_valid(b_rcu_lane_ops_c04_valid),
    .rcu_lane_ops_c04_payload(b_rcu_lane_ops_c04_payload),
    .rcu_lane_ops_c04_credit(b_rcu_lane_ops_c04_credit),
    .rcu_lane_ops_c04_stall(b_rcu_lane_ops_c04_stall),
    .rcu_lane_ops_c04_wake(b_rcu_lane_ops_c04_wake),
    .rcu_lane_ops_c05_valid(b_rcu_lane_ops_c05_valid),
    .rcu_lane_ops_c05_payload(b_rcu_lane_ops_c05_payload),
    .rcu_lane_ops_c05_credit(b_rcu_lane_ops_c05_credit),
    .rcu_lane_ops_c05_stall(b_rcu_lane_ops_c05_stall),
    .rcu_lane_ops_c05_wake(b_rcu_lane_ops_c05_wake),
    .rcu_lane_ops_c06_valid(b_rcu_lane_ops_c06_valid),
    .rcu_lane_ops_c06_payload(b_rcu_lane_ops_c06_payload),
    .rcu_lane_ops_c06_credit(b_rcu_lane_ops_c06_credit),
    .rcu_lane_ops_c06_stall(b_rcu_lane_ops_c06_stall),
    .rcu_lane_ops_c06_wake(b_rcu_lane_ops_c06_wake),
    .rcu_lane_ops_c07_valid(b_rcu_lane_ops_c07_valid),
    .rcu_lane_ops_c07_payload(b_rcu_lane_ops_c07_payload),
    .rcu_lane_ops_c07_credit(b_rcu_lane_ops_c07_credit),
    .rcu_lane_ops_c07_stall(b_rcu_lane_ops_c07_stall),
    .rcu_lane_ops_c07_wake(b_rcu_lane_ops_c07_wake),
    .rcu_lane_ops_c08_valid(b_rcu_lane_ops_c08_valid),
    .rcu_lane_ops_c08_payload(b_rcu_lane_ops_c08_payload),
    .rcu_lane_ops_c08_credit(b_rcu_lane_ops_c08_credit),
    .rcu_lane_ops_c08_stall(b_rcu_lane_ops_c08_stall),
    .rcu_lane_ops_c08_wake(b_rcu_lane_ops_c08_wake),
    .rcu_lane_ops_c09_valid(b_rcu_lane_ops_c09_valid),
    .rcu_lane_ops_c09_payload(b_rcu_lane_ops_c09_payload),
    .rcu_lane_ops_c09_credit(b_rcu_lane_ops_c09_credit),
    .rcu_lane_ops_c09_stall(b_rcu_lane_ops_c09_stall),
    .rcu_lane_ops_c09_wake(b_rcu_lane_ops_c09_wake),
    .rcu_lane_ops_c10_valid(b_rcu_lane_ops_c10_valid),
    .rcu_lane_ops_c10_payload(b_rcu_lane_ops_c10_payload),
    .rcu_lane_ops_c10_credit(b_rcu_lane_ops_c10_credit),
    .rcu_lane_ops_c10_stall(b_rcu_lane_ops_c10_stall),
    .rcu_lane_ops_c10_wake(b_rcu_lane_ops_c10_wake),
    .rcu_lane_ops_c11_valid(b_rcu_lane_ops_c11_valid),
    .rcu_lane_ops_c11_payload(b_rcu_lane_ops_c11_payload),
    .rcu_lane_ops_c11_credit(b_rcu_lane_ops_c11_credit),
    .rcu_lane_ops_c11_stall(b_rcu_lane_ops_c11_stall),
    .rcu_lane_ops_c11_wake(b_rcu_lane_ops_c11_wake),
    .rcu_lane_ops_c12_valid(b_rcu_lane_ops_c12_valid),
    .rcu_lane_ops_c12_payload(b_rcu_lane_ops_c12_payload),
    .rcu_lane_ops_c12_credit(b_rcu_lane_ops_c12_credit),
    .rcu_lane_ops_c12_stall(b_rcu_lane_ops_c12_stall),
    .rcu_lane_ops_c12_wake(b_rcu_lane_ops_c12_wake),
    .rcu_lane_ops_c13_valid(b_rcu_lane_ops_c13_valid),
    .rcu_lane_ops_c13_payload(b_rcu_lane_ops_c13_payload),
    .rcu_lane_ops_c13_credit(b_rcu_lane_ops_c13_credit),
    .rcu_lane_ops_c13_stall(b_rcu_lane_ops_c13_stall),
    .rcu_lane_ops_c13_wake(b_rcu_lane_ops_c13_wake),
    .rcu_lane_ops_c14_valid(b_rcu_lane_ops_c14_valid),
    .rcu_lane_ops_c14_payload(b_rcu_lane_ops_c14_payload),
    .rcu_lane_ops_c14_credit(b_rcu_lane_ops_c14_credit),
    .rcu_lane_ops_c14_stall(b_rcu_lane_ops_c14_stall),
    .rcu_lane_ops_c14_wake(b_rcu_lane_ops_c14_wake),
    .rcu_lane_ops_c15_valid(b_rcu_lane_ops_c15_valid),
    .rcu_lane_ops_c15_payload(b_rcu_lane_ops_c15_payload),
    .rcu_lane_ops_c15_credit(b_rcu_lane_ops_c15_credit),
    .rcu_lane_ops_c15_stall(b_rcu_lane_ops_c15_stall),
    .rcu_lane_ops_c15_wake(b_rcu_lane_ops_c15_wake),
    .rcu_lane_ops_c16_valid(b_rcu_lane_ops_c16_valid),
    .rcu_lane_ops_c16_payload(b_rcu_lane_ops_c16_payload),
    .rcu_lane_ops_c16_credit(b_rcu_lane_ops_c16_credit),
    .rcu_lane_ops_c16_stall(b_rcu_lane_ops_c16_stall),
    .rcu_lane_ops_c16_wake(b_rcu_lane_ops_c16_wake),
    .rcu_lane_ops_c17_valid(b_rcu_lane_ops_c17_valid),
    .rcu_lane_ops_c17_payload(b_rcu_lane_ops_c17_payload),
    .rcu_lane_ops_c17_credit(b_rcu_lane_ops_c17_credit),
    .rcu_lane_ops_c17_stall(b_rcu_lane_ops_c17_stall),
    .rcu_lane_ops_c17_wake(b_rcu_lane_ops_c17_wake),
    .rcu_lane_ops_c18_valid(b_rcu_lane_ops_c18_valid),
    .rcu_lane_ops_c18_payload(b_rcu_lane_ops_c18_payload),
    .rcu_lane_ops_c18_credit(b_rcu_lane_ops_c18_credit),
    .rcu_lane_ops_c18_stall(b_rcu_lane_ops_c18_stall),
    .rcu_lane_ops_c18_wake(b_rcu_lane_ops_c18_wake),
    .rcu_lane_ops_c19_valid(b_rcu_lane_ops_c19_valid),
    .rcu_lane_ops_c19_payload(b_rcu_lane_ops_c19_payload),
    .rcu_lane_ops_c19_credit(b_rcu_lane_ops_c19_credit),
    .rcu_lane_ops_c19_stall(b_rcu_lane_ops_c19_stall),
    .rcu_lane_ops_c19_wake(b_rcu_lane_ops_c19_wake),
    .rcu_lane_ops_c20_valid(b_rcu_lane_ops_c20_valid),
    .rcu_lane_ops_c20_payload(b_rcu_lane_ops_c20_payload),
    .rcu_lane_ops_c20_credit(b_rcu_lane_ops_c20_credit),
    .rcu_lane_ops_c20_stall(b_rcu_lane_ops_c20_stall),
    .rcu_lane_ops_c20_wake(b_rcu_lane_ops_c20_wake),
    .rcu_lane_ops_c21_valid(b_rcu_lane_ops_c21_valid),
    .rcu_lane_ops_c21_payload(b_rcu_lane_ops_c21_payload),
    .rcu_lane_ops_c21_credit(b_rcu_lane_ops_c21_credit),
    .rcu_lane_ops_c21_stall(b_rcu_lane_ops_c21_stall),
    .rcu_lane_ops_c21_wake(b_rcu_lane_ops_c21_wake),
    .rcu_lane_ops_c22_valid(b_rcu_lane_ops_c22_valid),
    .rcu_lane_ops_c22_payload(b_rcu_lane_ops_c22_payload),
    .rcu_lane_ops_c22_credit(b_rcu_lane_ops_c22_credit),
    .rcu_lane_ops_c22_stall(b_rcu_lane_ops_c22_stall),
    .rcu_lane_ops_c22_wake(b_rcu_lane_ops_c22_wake),
    .rcu_lane_ops_c23_valid(b_rcu_lane_ops_c23_valid),
    .rcu_lane_ops_c23_payload(b_rcu_lane_ops_c23_payload),
    .rcu_lane_ops_c23_credit(b_rcu_lane_ops_c23_credit),
    .rcu_lane_ops_c23_stall(b_rcu_lane_ops_c23_stall),
    .rcu_lane_ops_c23_wake(b_rcu_lane_ops_c23_wake),
    .rcu_lane_ops_c24_valid(b_rcu_lane_ops_c24_valid),
    .rcu_lane_ops_c24_payload(b_rcu_lane_ops_c24_payload),
    .rcu_lane_ops_c24_credit(b_rcu_lane_ops_c24_credit),
    .rcu_lane_ops_c24_stall(b_rcu_lane_ops_c24_stall),
    .rcu_lane_ops_c24_wake(b_rcu_lane_ops_c24_wake),
    .rcu_lane_ops_c25_valid(b_rcu_lane_ops_c25_valid),
    .rcu_lane_ops_c25_payload(b_rcu_lane_ops_c25_payload),
    .rcu_lane_ops_c25_credit(b_rcu_lane_ops_c25_credit),
    .rcu_lane_ops_c25_stall(b_rcu_lane_ops_c25_stall),
    .rcu_lane_ops_c25_wake(b_rcu_lane_ops_c25_wake),
    .rcu_lane_ops_c26_valid(b_rcu_lane_ops_c26_valid),
    .rcu_lane_ops_c26_payload(b_rcu_lane_ops_c26_payload),
    .rcu_lane_ops_c26_credit(b_rcu_lane_ops_c26_credit),
    .rcu_lane_ops_c26_stall(b_rcu_lane_ops_c26_stall),
    .rcu_lane_ops_c26_wake(b_rcu_lane_ops_c26_wake),
    .rcu_lane_ops_c27_valid(b_rcu_lane_ops_c27_valid),
    .rcu_lane_ops_c27_payload(b_rcu_lane_ops_c27_payload),
    .rcu_lane_ops_c27_credit(b_rcu_lane_ops_c27_credit),
    .rcu_lane_ops_c27_stall(b_rcu_lane_ops_c27_stall),
    .rcu_lane_ops_c27_wake(b_rcu_lane_ops_c27_wake),
    .rcu_lane_ops_c28_valid(b_rcu_lane_ops_c28_valid),
    .rcu_lane_ops_c28_payload(b_rcu_lane_ops_c28_payload),
    .rcu_lane_ops_c28_credit(b_rcu_lane_ops_c28_credit),
    .rcu_lane_ops_c28_stall(b_rcu_lane_ops_c28_stall),
    .rcu_lane_ops_c28_wake(b_rcu_lane_ops_c28_wake),
    .rcu_lane_ops_c29_valid(b_rcu_lane_ops_c29_valid),
    .rcu_lane_ops_c29_payload(b_rcu_lane_ops_c29_payload),
    .rcu_lane_ops_c29_credit(b_rcu_lane_ops_c29_credit),
    .rcu_lane_ops_c29_stall(b_rcu_lane_ops_c29_stall),
    .rcu_lane_ops_c29_wake(b_rcu_lane_ops_c29_wake),
    .rcu_lane_ops_c30_valid(b_rcu_lane_ops_c30_valid),
    .rcu_lane_ops_c30_payload(b_rcu_lane_ops_c30_payload),
    .rcu_lane_ops_c30_credit(b_rcu_lane_ops_c30_credit),
    .rcu_lane_ops_c30_stall(b_rcu_lane_ops_c30_stall),
    .rcu_lane_ops_c30_wake(b_rcu_lane_ops_c30_wake),
    .rcu_lane_ops_c31_valid(b_rcu_lane_ops_c31_valid),
    .rcu_lane_ops_c31_payload(b_rcu_lane_ops_c31_payload),
    .rcu_lane_ops_c31_credit(b_rcu_lane_ops_c31_credit),
    .rcu_lane_ops_c31_stall(b_rcu_lane_ops_c31_stall),
    .rcu_lane_ops_c31_wake(b_rcu_lane_ops_c31_wake),
    .lane_rcu_res_c00_valid(b_lane_rcu_res_c00_valid),
    .lane_rcu_res_c00_payload(b_lane_rcu_res_c00_payload),
    .lane_rcu_res_c00_credit(b_lane_rcu_res_c00_credit),
    .lane_rcu_res_c00_stall(b_lane_rcu_res_c00_stall),
    .lane_rcu_res_c00_wake(b_lane_rcu_res_c00_wake),
    .lane_rcu_res_c01_valid(b_lane_rcu_res_c01_valid),
    .lane_rcu_res_c01_payload(b_lane_rcu_res_c01_payload),
    .lane_rcu_res_c01_credit(b_lane_rcu_res_c01_credit),
    .lane_rcu_res_c01_stall(b_lane_rcu_res_c01_stall),
    .lane_rcu_res_c01_wake(b_lane_rcu_res_c01_wake),
    .lane_rcu_res_c02_valid(b_lane_rcu_res_c02_valid),
    .lane_rcu_res_c02_payload(b_lane_rcu_res_c02_payload),
    .lane_rcu_res_c02_credit(b_lane_rcu_res_c02_credit),
    .lane_rcu_res_c02_stall(b_lane_rcu_res_c02_stall),
    .lane_rcu_res_c02_wake(b_lane_rcu_res_c02_wake),
    .lane_rcu_res_c03_valid(b_lane_rcu_res_c03_valid),
    .lane_rcu_res_c03_payload(b_lane_rcu_res_c03_payload),
    .lane_rcu_res_c03_credit(b_lane_rcu_res_c03_credit),
    .lane_rcu_res_c03_stall(b_lane_rcu_res_c03_stall),
    .lane_rcu_res_c03_wake(b_lane_rcu_res_c03_wake),
    .lane_rcu_res_c04_valid(b_lane_rcu_res_c04_valid),
    .lane_rcu_res_c04_payload(b_lane_rcu_res_c04_payload),
    .lane_rcu_res_c04_credit(b_lane_rcu_res_c04_credit),
    .lane_rcu_res_c04_stall(b_lane_rcu_res_c04_stall),
    .lane_rcu_res_c04_wake(b_lane_rcu_res_c04_wake),
    .lane_rcu_res_c05_valid(b_lane_rcu_res_c05_valid),
    .lane_rcu_res_c05_payload(b_lane_rcu_res_c05_payload),
    .lane_rcu_res_c05_credit(b_lane_rcu_res_c05_credit),
    .lane_rcu_res_c05_stall(b_lane_rcu_res_c05_stall),
    .lane_rcu_res_c05_wake(b_lane_rcu_res_c05_wake),
    .lane_rcu_res_c06_valid(b_lane_rcu_res_c06_valid),
    .lane_rcu_res_c06_payload(b_lane_rcu_res_c06_payload),
    .lane_rcu_res_c06_credit(b_lane_rcu_res_c06_credit),
    .lane_rcu_res_c06_stall(b_lane_rcu_res_c06_stall),
    .lane_rcu_res_c06_wake(b_lane_rcu_res_c06_wake),
    .lane_rcu_res_c07_valid(b_lane_rcu_res_c07_valid),
    .lane_rcu_res_c07_payload(b_lane_rcu_res_c07_payload),
    .lane_rcu_res_c07_credit(b_lane_rcu_res_c07_credit),
    .lane_rcu_res_c07_stall(b_lane_rcu_res_c07_stall),
    .lane_rcu_res_c07_wake(b_lane_rcu_res_c07_wake),
    .lane_rcu_res_c08_valid(b_lane_rcu_res_c08_valid),
    .lane_rcu_res_c08_payload(b_lane_rcu_res_c08_payload),
    .lane_rcu_res_c08_credit(b_lane_rcu_res_c08_credit),
    .lane_rcu_res_c08_stall(b_lane_rcu_res_c08_stall),
    .lane_rcu_res_c08_wake(b_lane_rcu_res_c08_wake),
    .lane_rcu_res_c09_valid(b_lane_rcu_res_c09_valid),
    .lane_rcu_res_c09_payload(b_lane_rcu_res_c09_payload),
    .lane_rcu_res_c09_credit(b_lane_rcu_res_c09_credit),
    .lane_rcu_res_c09_stall(b_lane_rcu_res_c09_stall),
    .lane_rcu_res_c09_wake(b_lane_rcu_res_c09_wake),
    .lane_rcu_res_c10_valid(b_lane_rcu_res_c10_valid),
    .lane_rcu_res_c10_payload(b_lane_rcu_res_c10_payload),
    .lane_rcu_res_c10_credit(b_lane_rcu_res_c10_credit),
    .lane_rcu_res_c10_stall(b_lane_rcu_res_c10_stall),
    .lane_rcu_res_c10_wake(b_lane_rcu_res_c10_wake),
    .lane_rcu_res_c11_valid(b_lane_rcu_res_c11_valid),
    .lane_rcu_res_c11_payload(b_lane_rcu_res_c11_payload),
    .lane_rcu_res_c11_credit(b_lane_rcu_res_c11_credit),
    .lane_rcu_res_c11_stall(b_lane_rcu_res_c11_stall),
    .lane_rcu_res_c11_wake(b_lane_rcu_res_c11_wake),
    .lane_rcu_res_c12_valid(b_lane_rcu_res_c12_valid),
    .lane_rcu_res_c12_payload(b_lane_rcu_res_c12_payload),
    .lane_rcu_res_c12_credit(b_lane_rcu_res_c12_credit),
    .lane_rcu_res_c12_stall(b_lane_rcu_res_c12_stall),
    .lane_rcu_res_c12_wake(b_lane_rcu_res_c12_wake),
    .lane_rcu_res_c13_valid(b_lane_rcu_res_c13_valid),
    .lane_rcu_res_c13_payload(b_lane_rcu_res_c13_payload),
    .lane_rcu_res_c13_credit(b_lane_rcu_res_c13_credit),
    .lane_rcu_res_c13_stall(b_lane_rcu_res_c13_stall),
    .lane_rcu_res_c13_wake(b_lane_rcu_res_c13_wake),
    .lane_rcu_res_c14_valid(b_lane_rcu_res_c14_valid),
    .lane_rcu_res_c14_payload(b_lane_rcu_res_c14_payload),
    .lane_rcu_res_c14_credit(b_lane_rcu_res_c14_credit),
    .lane_rcu_res_c14_stall(b_lane_rcu_res_c14_stall),
    .lane_rcu_res_c14_wake(b_lane_rcu_res_c14_wake),
    .lane_rcu_res_c15_valid(b_lane_rcu_res_c15_valid),
    .lane_rcu_res_c15_payload(b_lane_rcu_res_c15_payload),
    .lane_rcu_res_c15_credit(b_lane_rcu_res_c15_credit),
    .lane_rcu_res_c15_stall(b_lane_rcu_res_c15_stall),
    .lane_rcu_res_c15_wake(b_lane_rcu_res_c15_wake),
    .lane_rcu_res_c16_valid(b_lane_rcu_res_c16_valid),
    .lane_rcu_res_c16_payload(b_lane_rcu_res_c16_payload),
    .lane_rcu_res_c16_credit(b_lane_rcu_res_c16_credit),
    .lane_rcu_res_c16_stall(b_lane_rcu_res_c16_stall),
    .lane_rcu_res_c16_wake(b_lane_rcu_res_c16_wake),
    .lane_rcu_res_c17_valid(b_lane_rcu_res_c17_valid),
    .lane_rcu_res_c17_payload(b_lane_rcu_res_c17_payload),
    .lane_rcu_res_c17_credit(b_lane_rcu_res_c17_credit),
    .lane_rcu_res_c17_stall(b_lane_rcu_res_c17_stall),
    .lane_rcu_res_c17_wake(b_lane_rcu_res_c17_wake),
    .lane_rcu_res_c18_valid(b_lane_rcu_res_c18_valid),
    .lane_rcu_res_c18_payload(b_lane_rcu_res_c18_payload),
    .lane_rcu_res_c18_credit(b_lane_rcu_res_c18_credit),
    .lane_rcu_res_c18_stall(b_lane_rcu_res_c18_stall),
    .lane_rcu_res_c18_wake(b_lane_rcu_res_c18_wake),
    .lane_rcu_res_c19_valid(b_lane_rcu_res_c19_valid),
    .lane_rcu_res_c19_payload(b_lane_rcu_res_c19_payload),
    .lane_rcu_res_c19_credit(b_lane_rcu_res_c19_credit),
    .lane_rcu_res_c19_stall(b_lane_rcu_res_c19_stall),
    .lane_rcu_res_c19_wake(b_lane_rcu_res_c19_wake),
    .lane_rcu_res_c20_valid(b_lane_rcu_res_c20_valid),
    .lane_rcu_res_c20_payload(b_lane_rcu_res_c20_payload),
    .lane_rcu_res_c20_credit(b_lane_rcu_res_c20_credit),
    .lane_rcu_res_c20_stall(b_lane_rcu_res_c20_stall),
    .lane_rcu_res_c20_wake(b_lane_rcu_res_c20_wake),
    .lane_rcu_res_c21_valid(b_lane_rcu_res_c21_valid),
    .lane_rcu_res_c21_payload(b_lane_rcu_res_c21_payload),
    .lane_rcu_res_c21_credit(b_lane_rcu_res_c21_credit),
    .lane_rcu_res_c21_stall(b_lane_rcu_res_c21_stall),
    .lane_rcu_res_c21_wake(b_lane_rcu_res_c21_wake),
    .lane_rcu_res_c22_valid(b_lane_rcu_res_c22_valid),
    .lane_rcu_res_c22_payload(b_lane_rcu_res_c22_payload),
    .lane_rcu_res_c22_credit(b_lane_rcu_res_c22_credit),
    .lane_rcu_res_c22_stall(b_lane_rcu_res_c22_stall),
    .lane_rcu_res_c22_wake(b_lane_rcu_res_c22_wake),
    .lane_rcu_res_c23_valid(b_lane_rcu_res_c23_valid),
    .lane_rcu_res_c23_payload(b_lane_rcu_res_c23_payload),
    .lane_rcu_res_c23_credit(b_lane_rcu_res_c23_credit),
    .lane_rcu_res_c23_stall(b_lane_rcu_res_c23_stall),
    .lane_rcu_res_c23_wake(b_lane_rcu_res_c23_wake),
    .lane_rcu_res_c24_valid(b_lane_rcu_res_c24_valid),
    .lane_rcu_res_c24_payload(b_lane_rcu_res_c24_payload),
    .lane_rcu_res_c24_credit(b_lane_rcu_res_c24_credit),
    .lane_rcu_res_c24_stall(b_lane_rcu_res_c24_stall),
    .lane_rcu_res_c24_wake(b_lane_rcu_res_c24_wake),
    .lane_rcu_res_c25_valid(b_lane_rcu_res_c25_valid),
    .lane_rcu_res_c25_payload(b_lane_rcu_res_c25_payload),
    .lane_rcu_res_c25_credit(b_lane_rcu_res_c25_credit),
    .lane_rcu_res_c25_stall(b_lane_rcu_res_c25_stall),
    .lane_rcu_res_c25_wake(b_lane_rcu_res_c25_wake),
    .lane_rcu_res_c26_valid(b_lane_rcu_res_c26_valid),
    .lane_rcu_res_c26_payload(b_lane_rcu_res_c26_payload),
    .lane_rcu_res_c26_credit(b_lane_rcu_res_c26_credit),
    .lane_rcu_res_c26_stall(b_lane_rcu_res_c26_stall),
    .lane_rcu_res_c26_wake(b_lane_rcu_res_c26_wake),
    .lane_rcu_res_c27_valid(b_lane_rcu_res_c27_valid),
    .lane_rcu_res_c27_payload(b_lane_rcu_res_c27_payload),
    .lane_rcu_res_c27_credit(b_lane_rcu_res_c27_credit),
    .lane_rcu_res_c27_stall(b_lane_rcu_res_c27_stall),
    .lane_rcu_res_c27_wake(b_lane_rcu_res_c27_wake),
    .lane_rcu_res_c28_valid(b_lane_rcu_res_c28_valid),
    .lane_rcu_res_c28_payload(b_lane_rcu_res_c28_payload),
    .lane_rcu_res_c28_credit(b_lane_rcu_res_c28_credit),
    .lane_rcu_res_c28_stall(b_lane_rcu_res_c28_stall),
    .lane_rcu_res_c28_wake(b_lane_rcu_res_c28_wake),
    .lane_rcu_res_c29_valid(b_lane_rcu_res_c29_valid),
    .lane_rcu_res_c29_payload(b_lane_rcu_res_c29_payload),
    .lane_rcu_res_c29_credit(b_lane_rcu_res_c29_credit),
    .lane_rcu_res_c29_stall(b_lane_rcu_res_c29_stall),
    .lane_rcu_res_c29_wake(b_lane_rcu_res_c29_wake),
    .lane_rcu_res_c30_valid(b_lane_rcu_res_c30_valid),
    .lane_rcu_res_c30_payload(b_lane_rcu_res_c30_payload),
    .lane_rcu_res_c30_credit(b_lane_rcu_res_c30_credit),
    .lane_rcu_res_c30_stall(b_lane_rcu_res_c30_stall),
    .lane_rcu_res_c30_wake(b_lane_rcu_res_c30_wake),
    .lane_rcu_res_c31_valid(b_lane_rcu_res_c31_valid),
    .lane_rcu_res_c31_payload(b_lane_rcu_res_c31_payload),
    .lane_rcu_res_c31_credit(b_lane_rcu_res_c31_credit),
    .lane_rcu_res_c31_stall(b_lane_rcu_res_c31_stall),
    .lane_rcu_res_c31_wake(b_lane_rcu_res_c31_wake),
    .rcu_ooe_done_s0_valid(b_rcu_ooe_done_s0_valid),
    .rcu_ooe_done_s0_payload(b_rcu_ooe_done_s0_payload),
    .rcu_ooe_done_s0_credit(b_rcu_ooe_done_s0_credit),
    .rcu_ooe_done_s0_stall(b_rcu_ooe_done_s0_stall),
    .rcu_ooe_done_s1_valid(b_rcu_ooe_done_s1_valid),
    .rcu_ooe_done_s1_payload(b_rcu_ooe_done_s1_payload),
    .rcu_ooe_done_s1_credit(b_rcu_ooe_done_s1_credit),
    .rcu_ooe_done_s1_stall(b_rcu_ooe_done_s1_stall),
    .rcu_ooe_done_s2_valid(b_rcu_ooe_done_s2_valid),
    .rcu_ooe_done_s2_payload(b_rcu_ooe_done_s2_payload),
    .rcu_ooe_done_s2_credit(b_rcu_ooe_done_s2_credit),
    .rcu_ooe_done_s2_stall(b_rcu_ooe_done_s2_stall),
    .rcu_ooe_done_s3_valid(b_rcu_ooe_done_s3_valid),
    .rcu_ooe_done_s3_payload(b_rcu_ooe_done_s3_payload),
    .rcu_ooe_done_s3_credit(b_rcu_ooe_done_s3_credit),
    .rcu_ooe_done_s3_stall(b_rcu_ooe_done_s3_stall),
    .rcu_ooe_done_s4_valid(b_rcu_ooe_done_s4_valid),
    .rcu_ooe_done_s4_payload(b_rcu_ooe_done_s4_payload),
    .rcu_ooe_done_s4_credit(b_rcu_ooe_done_s4_credit),
    .rcu_ooe_done_s4_stall(b_rcu_ooe_done_s4_stall),
    .rcu_ooe_done_s5_valid(b_rcu_ooe_done_s5_valid),
    .rcu_ooe_done_s5_payload(b_rcu_ooe_done_s5_payload),
    .rcu_ooe_done_s5_credit(b_rcu_ooe_done_s5_credit),
    .rcu_ooe_done_s5_stall(b_rcu_ooe_done_s5_stall),
    .rcu_ooe_done_s6_valid(b_rcu_ooe_done_s6_valid),
    .rcu_ooe_done_s6_payload(b_rcu_ooe_done_s6_payload),
    .rcu_ooe_done_s6_credit(b_rcu_ooe_done_s6_credit),
    .rcu_ooe_done_s6_stall(b_rcu_ooe_done_s6_stall),
    .rcu_ooe_done_wake(b_rcu_ooe_done_wake),
    .rcu_miu_addr_s0_valid(b_rcu_miu_addr_s0_valid),
    .rcu_miu_addr_s0_payload(b_rcu_miu_addr_s0_payload),
    .rcu_miu_addr_s0_credit(b_rcu_miu_addr_s0_credit),
    .rcu_miu_addr_s0_stall(b_rcu_miu_addr_s0_stall),
    .rcu_miu_addr_s1_valid(b_rcu_miu_addr_s1_valid),
    .rcu_miu_addr_s1_payload(b_rcu_miu_addr_s1_payload),
    .rcu_miu_addr_s1_credit(b_rcu_miu_addr_s1_credit),
    .rcu_miu_addr_s1_stall(b_rcu_miu_addr_s1_stall),
    .rcu_miu_addr_s2_valid(b_rcu_miu_addr_s2_valid),
    .rcu_miu_addr_s2_payload(b_rcu_miu_addr_s2_payload),
    .rcu_miu_addr_s2_credit(b_rcu_miu_addr_s2_credit),
    .rcu_miu_addr_s2_stall(b_rcu_miu_addr_s2_stall),
    .rcu_miu_addr_s3_valid(b_rcu_miu_addr_s3_valid),
    .rcu_miu_addr_s3_payload(b_rcu_miu_addr_s3_payload),
    .rcu_miu_addr_s3_credit(b_rcu_miu_addr_s3_credit),
    .rcu_miu_addr_s3_stall(b_rcu_miu_addr_s3_stall),
    .rcu_miu_addr_wake(b_rcu_miu_addr_wake),
    .miu_rcu_data_s0_valid(b_miu_rcu_data_s0_valid),
    .miu_rcu_data_s0_payload(b_miu_rcu_data_s0_payload),
    .miu_rcu_data_s0_credit(b_miu_rcu_data_s0_credit),
    .miu_rcu_data_s0_stall(b_miu_rcu_data_s0_stall),
    .miu_rcu_data_s1_valid(b_miu_rcu_data_s1_valid),
    .miu_rcu_data_s1_payload(b_miu_rcu_data_s1_payload),
    .miu_rcu_data_s1_credit(b_miu_rcu_data_s1_credit),
    .miu_rcu_data_s1_stall(b_miu_rcu_data_s1_stall),
    .miu_rcu_data_s2_valid(b_miu_rcu_data_s2_valid),
    .miu_rcu_data_s2_payload(b_miu_rcu_data_s2_payload),
    .miu_rcu_data_s2_credit(b_miu_rcu_data_s2_credit),
    .miu_rcu_data_s2_stall(b_miu_rcu_data_s2_stall),
    .miu_rcu_data_s3_valid(b_miu_rcu_data_s3_valid),
    .miu_rcu_data_s3_payload(b_miu_rcu_data_s3_payload),
    .miu_rcu_data_s3_credit(b_miu_rcu_data_s3_credit),
    .miu_rcu_data_s3_stall(b_miu_rcu_data_s3_stall),
    .miu_rcu_data_wake(b_miu_rcu_data_wake),
    .rau_rcu_mig_valid(b_rau_rcu_mig_valid),
    .rau_rcu_mig_payload(b_rau_rcu_mig_payload),
    .rau_rcu_mig_credit(b_rau_rcu_mig_credit),
    .rau_rcu_mig_stall(b_rau_rcu_mig_stall),
    .rau_rcu_mig_wake(b_rau_rcu_mig_wake),
    .ooe_rcu_map_valid(b_ooe_rcu_map_valid),
    .ooe_rcu_map_payload(b_ooe_rcu_map_payload),
    .ooe_rcu_map_credit(b_ooe_rcu_map_credit),
    .ooe_rcu_map_stall(b_ooe_rcu_map_stall),
    .ooe_rcu_map_wake(b_ooe_rcu_map_wake),
    .rcu_pca_mig_valid(b_rcu_pca_mig_valid),
    .rcu_pca_mig_payload(b_rcu_pca_mig_payload),
    .rcu_pca_mig_credit(b_rcu_pca_mig_credit),
    .rcu_pca_mig_stall(b_rcu_pca_mig_stall),
    .rcu_pca_mig_wake(b_rcu_pca_mig_wake),
    .pca_rcu_mig_valid(b_pca_rcu_mig_valid),
    .pca_rcu_mig_payload(b_pca_rcu_mig_payload),
    .pca_rcu_mig_credit(b_pca_rcu_mig_credit),
    .pca_rcu_mig_stall(b_pca_rcu_mig_stall),
    .pca_rcu_mig_wake(b_pca_rcu_mig_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .ooe_rcu_issue_s0_tid(b_ooe_rcu_issue_s0_tid)
    , .ooe_rcu_issue_s1_tid(b_ooe_rcu_issue_s1_tid)
    , .ooe_rcu_issue_s2_tid(b_ooe_rcu_issue_s2_tid)
    , .ooe_rcu_issue_s3_tid(b_ooe_rcu_issue_s3_tid)
    , .ooe_rcu_issue_s4_tid(b_ooe_rcu_issue_s4_tid)
    , .ooe_rcu_issue_s5_tid(b_ooe_rcu_issue_s5_tid)
    , .ooe_rcu_issue_s6_tid(b_ooe_rcu_issue_s6_tid)
    , .ooe_rcu_issue_s7_tid(b_ooe_rcu_issue_s7_tid)
    , .ooe_rcu_issue_s8_tid(b_ooe_rcu_issue_s8_tid)
    , .rcu_lane_ops_c00_tid(b_rcu_lane_ops_c00_tid)
    , .rcu_lane_ops_c01_tid(b_rcu_lane_ops_c01_tid)
    , .rcu_lane_ops_c02_tid(b_rcu_lane_ops_c02_tid)
    , .rcu_lane_ops_c03_tid(b_rcu_lane_ops_c03_tid)
    , .rcu_lane_ops_c04_tid(b_rcu_lane_ops_c04_tid)
    , .rcu_lane_ops_c05_tid(b_rcu_lane_ops_c05_tid)
    , .rcu_lane_ops_c06_tid(b_rcu_lane_ops_c06_tid)
    , .rcu_lane_ops_c07_tid(b_rcu_lane_ops_c07_tid)
    , .rcu_lane_ops_c08_tid(b_rcu_lane_ops_c08_tid)
    , .rcu_lane_ops_c09_tid(b_rcu_lane_ops_c09_tid)
    , .rcu_lane_ops_c10_tid(b_rcu_lane_ops_c10_tid)
    , .rcu_lane_ops_c11_tid(b_rcu_lane_ops_c11_tid)
    , .rcu_lane_ops_c12_tid(b_rcu_lane_ops_c12_tid)
    , .rcu_lane_ops_c13_tid(b_rcu_lane_ops_c13_tid)
    , .rcu_lane_ops_c14_tid(b_rcu_lane_ops_c14_tid)
    , .rcu_lane_ops_c15_tid(b_rcu_lane_ops_c15_tid)
    , .rcu_lane_ops_c16_tid(b_rcu_lane_ops_c16_tid)
    , .rcu_lane_ops_c17_tid(b_rcu_lane_ops_c17_tid)
    , .rcu_lane_ops_c18_tid(b_rcu_lane_ops_c18_tid)
    , .rcu_lane_ops_c19_tid(b_rcu_lane_ops_c19_tid)
    , .rcu_lane_ops_c20_tid(b_rcu_lane_ops_c20_tid)
    , .rcu_lane_ops_c21_tid(b_rcu_lane_ops_c21_tid)
    , .rcu_lane_ops_c22_tid(b_rcu_lane_ops_c22_tid)
    , .rcu_lane_ops_c23_tid(b_rcu_lane_ops_c23_tid)
    , .rcu_lane_ops_c24_tid(b_rcu_lane_ops_c24_tid)
    , .rcu_lane_ops_c25_tid(b_rcu_lane_ops_c25_tid)
    , .rcu_lane_ops_c26_tid(b_rcu_lane_ops_c26_tid)
    , .rcu_lane_ops_c27_tid(b_rcu_lane_ops_c27_tid)
    , .rcu_lane_ops_c28_tid(b_rcu_lane_ops_c28_tid)
    , .rcu_lane_ops_c29_tid(b_rcu_lane_ops_c29_tid)
    , .rcu_lane_ops_c30_tid(b_rcu_lane_ops_c30_tid)
    , .rcu_lane_ops_c31_tid(b_rcu_lane_ops_c31_tid)
    , .lane_rcu_res_c00_tid(b_lane_rcu_res_c00_tid)
    , .lane_rcu_res_c01_tid(b_lane_rcu_res_c01_tid)
    , .lane_rcu_res_c02_tid(b_lane_rcu_res_c02_tid)
    , .lane_rcu_res_c03_tid(b_lane_rcu_res_c03_tid)
    , .lane_rcu_res_c04_tid(b_lane_rcu_res_c04_tid)
    , .lane_rcu_res_c05_tid(b_lane_rcu_res_c05_tid)
    , .lane_rcu_res_c06_tid(b_lane_rcu_res_c06_tid)
    , .lane_rcu_res_c07_tid(b_lane_rcu_res_c07_tid)
    , .lane_rcu_res_c08_tid(b_lane_rcu_res_c08_tid)
    , .lane_rcu_res_c09_tid(b_lane_rcu_res_c09_tid)
    , .lane_rcu_res_c10_tid(b_lane_rcu_res_c10_tid)
    , .lane_rcu_res_c11_tid(b_lane_rcu_res_c11_tid)
    , .lane_rcu_res_c12_tid(b_lane_rcu_res_c12_tid)
    , .lane_rcu_res_c13_tid(b_lane_rcu_res_c13_tid)
    , .lane_rcu_res_c14_tid(b_lane_rcu_res_c14_tid)
    , .lane_rcu_res_c15_tid(b_lane_rcu_res_c15_tid)
    , .lane_rcu_res_c16_tid(b_lane_rcu_res_c16_tid)
    , .lane_rcu_res_c17_tid(b_lane_rcu_res_c17_tid)
    , .lane_rcu_res_c18_tid(b_lane_rcu_res_c18_tid)
    , .lane_rcu_res_c19_tid(b_lane_rcu_res_c19_tid)
    , .lane_rcu_res_c20_tid(b_lane_rcu_res_c20_tid)
    , .lane_rcu_res_c21_tid(b_lane_rcu_res_c21_tid)
    , .lane_rcu_res_c22_tid(b_lane_rcu_res_c22_tid)
    , .lane_rcu_res_c23_tid(b_lane_rcu_res_c23_tid)
    , .lane_rcu_res_c24_tid(b_lane_rcu_res_c24_tid)
    , .lane_rcu_res_c25_tid(b_lane_rcu_res_c25_tid)
    , .lane_rcu_res_c26_tid(b_lane_rcu_res_c26_tid)
    , .lane_rcu_res_c27_tid(b_lane_rcu_res_c27_tid)
    , .lane_rcu_res_c28_tid(b_lane_rcu_res_c28_tid)
    , .lane_rcu_res_c29_tid(b_lane_rcu_res_c29_tid)
    , .lane_rcu_res_c30_tid(b_lane_rcu_res_c30_tid)
    , .lane_rcu_res_c31_tid(b_lane_rcu_res_c31_tid)
    , .rcu_ooe_done_s0_tid(b_rcu_ooe_done_s0_tid)
    , .rcu_ooe_done_s1_tid(b_rcu_ooe_done_s1_tid)
    , .rcu_ooe_done_s2_tid(b_rcu_ooe_done_s2_tid)
    , .rcu_ooe_done_s3_tid(b_rcu_ooe_done_s3_tid)
    , .rcu_ooe_done_s4_tid(b_rcu_ooe_done_s4_tid)
    , .rcu_ooe_done_s5_tid(b_rcu_ooe_done_s5_tid)
    , .rcu_ooe_done_s6_tid(b_rcu_ooe_done_s6_tid)
    , .rcu_miu_addr_s0_tid(b_rcu_miu_addr_s0_tid)
    , .rcu_miu_addr_s1_tid(b_rcu_miu_addr_s1_tid)
    , .rcu_miu_addr_s2_tid(b_rcu_miu_addr_s2_tid)
    , .rcu_miu_addr_s3_tid(b_rcu_miu_addr_s3_tid)
    , .miu_rcu_data_s0_tid(b_miu_rcu_data_s0_tid)
    , .miu_rcu_data_s1_tid(b_miu_rcu_data_s1_tid)
    , .miu_rcu_data_s2_tid(b_miu_rcu_data_s2_tid)
    , .miu_rcu_data_s3_tid(b_miu_rcu_data_s3_tid)
    , .rau_rcu_mig_tid(b_rau_rcu_mig_tid)
    , .ooe_rcu_map_tid(b_ooe_rcu_map_tid)
    , .rcu_pca_mig_tid(b_rcu_pca_mig_tid)
    , .pca_rcu_mig_tid(b_pca_rcu_mig_tid)
`endif
  );

  // ccv_ooe_rcu_issue, destination end
  ccv_seq_rpt #(.STAGES(RPT_OOE_RCU_ISSUE), .SLOTS(9), .PAYLOAD_W(175)) u_rpt_ooe_rcu_issue (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({ooe_rcu_issue_s8_valid, ooe_rcu_issue_s7_valid, ooe_rcu_issue_s6_valid, ooe_rcu_issue_s5_valid, ooe_rcu_issue_s4_valid, ooe_rcu_issue_s3_valid, ooe_rcu_issue_s2_valid, ooe_rcu_issue_s1_valid, ooe_rcu_issue_s0_valid}), .src_payload({ooe_rcu_issue_s8_payload, ooe_rcu_issue_s7_payload, ooe_rcu_issue_s6_payload, ooe_rcu_issue_s5_payload, ooe_rcu_issue_s4_payload, ooe_rcu_issue_s3_payload, ooe_rcu_issue_s2_payload, ooe_rcu_issue_s1_payload, ooe_rcu_issue_s0_payload}),
    .src_wake(ooe_rcu_issue_wake), .src_credit({ooe_rcu_issue_s8_credit, ooe_rcu_issue_s7_credit, ooe_rcu_issue_s6_credit, ooe_rcu_issue_s5_credit, ooe_rcu_issue_s4_credit, ooe_rcu_issue_s3_credit, ooe_rcu_issue_s2_credit, ooe_rcu_issue_s1_credit, ooe_rcu_issue_s0_credit}), .src_stall({ooe_rcu_issue_s8_stall, ooe_rcu_issue_s7_stall, ooe_rcu_issue_s6_stall, ooe_rcu_issue_s5_stall, ooe_rcu_issue_s4_stall, ooe_rcu_issue_s3_stall, ooe_rcu_issue_s2_stall, ooe_rcu_issue_s1_stall, ooe_rcu_issue_s0_stall}),
    .dst_valid({b_ooe_rcu_issue_s8_valid, b_ooe_rcu_issue_s7_valid, b_ooe_rcu_issue_s6_valid, b_ooe_rcu_issue_s5_valid, b_ooe_rcu_issue_s4_valid, b_ooe_rcu_issue_s3_valid, b_ooe_rcu_issue_s2_valid, b_ooe_rcu_issue_s1_valid, b_ooe_rcu_issue_s0_valid}), .dst_payload({b_ooe_rcu_issue_s8_payload, b_ooe_rcu_issue_s7_payload, b_ooe_rcu_issue_s6_payload, b_ooe_rcu_issue_s5_payload, b_ooe_rcu_issue_s4_payload, b_ooe_rcu_issue_s3_payload, b_ooe_rcu_issue_s2_payload, b_ooe_rcu_issue_s1_payload, b_ooe_rcu_issue_s0_payload}),
    .dst_wake(b_ooe_rcu_issue_wake), .dst_credit({b_ooe_rcu_issue_s8_credit, b_ooe_rcu_issue_s7_credit, b_ooe_rcu_issue_s6_credit, b_ooe_rcu_issue_s5_credit, b_ooe_rcu_issue_s4_credit, b_ooe_rcu_issue_s3_credit, b_ooe_rcu_issue_s2_credit, b_ooe_rcu_issue_s1_credit, b_ooe_rcu_issue_s0_credit}), .dst_stall({b_ooe_rcu_issue_s8_stall, b_ooe_rcu_issue_s7_stall, b_ooe_rcu_issue_s6_stall, b_ooe_rcu_issue_s5_stall, b_ooe_rcu_issue_s4_stall, b_ooe_rcu_issue_s3_stall, b_ooe_rcu_issue_s2_stall, b_ooe_rcu_issue_s1_stall, b_ooe_rcu_issue_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({ooe_rcu_issue_s8_tid, ooe_rcu_issue_s7_tid, ooe_rcu_issue_s6_tid, ooe_rcu_issue_s5_tid, ooe_rcu_issue_s4_tid, ooe_rcu_issue_s3_tid, ooe_rcu_issue_s2_tid, ooe_rcu_issue_s1_tid, ooe_rcu_issue_s0_tid}), .dst_tid({b_ooe_rcu_issue_s8_tid, b_ooe_rcu_issue_s7_tid, b_ooe_rcu_issue_s6_tid, b_ooe_rcu_issue_s5_tid, b_ooe_rcu_issue_s4_tid, b_ooe_rcu_issue_s3_tid, b_ooe_rcu_issue_s2_tid, b_ooe_rcu_issue_s1_tid, b_ooe_rcu_issue_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C00), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c00 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c00_valid}), .src_payload({b_rcu_lane_ops_c00_payload}),
    .src_wake(b_rcu_lane_ops_c00_wake), .src_credit({b_rcu_lane_ops_c00_credit}), .src_stall({b_rcu_lane_ops_c00_stall}),
    .dst_valid({rcu_lane_ops_c00_valid}), .dst_payload({rcu_lane_ops_c00_payload}),
    .dst_wake(rcu_lane_ops_c00_wake), .dst_credit({rcu_lane_ops_c00_credit}), .dst_stall({rcu_lane_ops_c00_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c00_tid}), .dst_tid({rcu_lane_ops_c00_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C01), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c01 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c01_valid}), .src_payload({b_rcu_lane_ops_c01_payload}),
    .src_wake(b_rcu_lane_ops_c01_wake), .src_credit({b_rcu_lane_ops_c01_credit}), .src_stall({b_rcu_lane_ops_c01_stall}),
    .dst_valid({rcu_lane_ops_c01_valid}), .dst_payload({rcu_lane_ops_c01_payload}),
    .dst_wake(rcu_lane_ops_c01_wake), .dst_credit({rcu_lane_ops_c01_credit}), .dst_stall({rcu_lane_ops_c01_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c01_tid}), .dst_tid({rcu_lane_ops_c01_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C02), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c02 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c02_valid}), .src_payload({b_rcu_lane_ops_c02_payload}),
    .src_wake(b_rcu_lane_ops_c02_wake), .src_credit({b_rcu_lane_ops_c02_credit}), .src_stall({b_rcu_lane_ops_c02_stall}),
    .dst_valid({rcu_lane_ops_c02_valid}), .dst_payload({rcu_lane_ops_c02_payload}),
    .dst_wake(rcu_lane_ops_c02_wake), .dst_credit({rcu_lane_ops_c02_credit}), .dst_stall({rcu_lane_ops_c02_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c02_tid}), .dst_tid({rcu_lane_ops_c02_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C03), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c03 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c03_valid}), .src_payload({b_rcu_lane_ops_c03_payload}),
    .src_wake(b_rcu_lane_ops_c03_wake), .src_credit({b_rcu_lane_ops_c03_credit}), .src_stall({b_rcu_lane_ops_c03_stall}),
    .dst_valid({rcu_lane_ops_c03_valid}), .dst_payload({rcu_lane_ops_c03_payload}),
    .dst_wake(rcu_lane_ops_c03_wake), .dst_credit({rcu_lane_ops_c03_credit}), .dst_stall({rcu_lane_ops_c03_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c03_tid}), .dst_tid({rcu_lane_ops_c03_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C04), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c04 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c04_valid}), .src_payload({b_rcu_lane_ops_c04_payload}),
    .src_wake(b_rcu_lane_ops_c04_wake), .src_credit({b_rcu_lane_ops_c04_credit}), .src_stall({b_rcu_lane_ops_c04_stall}),
    .dst_valid({rcu_lane_ops_c04_valid}), .dst_payload({rcu_lane_ops_c04_payload}),
    .dst_wake(rcu_lane_ops_c04_wake), .dst_credit({rcu_lane_ops_c04_credit}), .dst_stall({rcu_lane_ops_c04_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c04_tid}), .dst_tid({rcu_lane_ops_c04_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C05), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c05 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c05_valid}), .src_payload({b_rcu_lane_ops_c05_payload}),
    .src_wake(b_rcu_lane_ops_c05_wake), .src_credit({b_rcu_lane_ops_c05_credit}), .src_stall({b_rcu_lane_ops_c05_stall}),
    .dst_valid({rcu_lane_ops_c05_valid}), .dst_payload({rcu_lane_ops_c05_payload}),
    .dst_wake(rcu_lane_ops_c05_wake), .dst_credit({rcu_lane_ops_c05_credit}), .dst_stall({rcu_lane_ops_c05_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c05_tid}), .dst_tid({rcu_lane_ops_c05_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C06), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c06 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c06_valid}), .src_payload({b_rcu_lane_ops_c06_payload}),
    .src_wake(b_rcu_lane_ops_c06_wake), .src_credit({b_rcu_lane_ops_c06_credit}), .src_stall({b_rcu_lane_ops_c06_stall}),
    .dst_valid({rcu_lane_ops_c06_valid}), .dst_payload({rcu_lane_ops_c06_payload}),
    .dst_wake(rcu_lane_ops_c06_wake), .dst_credit({rcu_lane_ops_c06_credit}), .dst_stall({rcu_lane_ops_c06_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c06_tid}), .dst_tid({rcu_lane_ops_c06_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C07), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c07 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c07_valid}), .src_payload({b_rcu_lane_ops_c07_payload}),
    .src_wake(b_rcu_lane_ops_c07_wake), .src_credit({b_rcu_lane_ops_c07_credit}), .src_stall({b_rcu_lane_ops_c07_stall}),
    .dst_valid({rcu_lane_ops_c07_valid}), .dst_payload({rcu_lane_ops_c07_payload}),
    .dst_wake(rcu_lane_ops_c07_wake), .dst_credit({rcu_lane_ops_c07_credit}), .dst_stall({rcu_lane_ops_c07_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c07_tid}), .dst_tid({rcu_lane_ops_c07_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C08), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c08 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c08_valid}), .src_payload({b_rcu_lane_ops_c08_payload}),
    .src_wake(b_rcu_lane_ops_c08_wake), .src_credit({b_rcu_lane_ops_c08_credit}), .src_stall({b_rcu_lane_ops_c08_stall}),
    .dst_valid({rcu_lane_ops_c08_valid}), .dst_payload({rcu_lane_ops_c08_payload}),
    .dst_wake(rcu_lane_ops_c08_wake), .dst_credit({rcu_lane_ops_c08_credit}), .dst_stall({rcu_lane_ops_c08_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c08_tid}), .dst_tid({rcu_lane_ops_c08_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C09), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c09 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c09_valid}), .src_payload({b_rcu_lane_ops_c09_payload}),
    .src_wake(b_rcu_lane_ops_c09_wake), .src_credit({b_rcu_lane_ops_c09_credit}), .src_stall({b_rcu_lane_ops_c09_stall}),
    .dst_valid({rcu_lane_ops_c09_valid}), .dst_payload({rcu_lane_ops_c09_payload}),
    .dst_wake(rcu_lane_ops_c09_wake), .dst_credit({rcu_lane_ops_c09_credit}), .dst_stall({rcu_lane_ops_c09_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c09_tid}), .dst_tid({rcu_lane_ops_c09_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C10), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c10 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c10_valid}), .src_payload({b_rcu_lane_ops_c10_payload}),
    .src_wake(b_rcu_lane_ops_c10_wake), .src_credit({b_rcu_lane_ops_c10_credit}), .src_stall({b_rcu_lane_ops_c10_stall}),
    .dst_valid({rcu_lane_ops_c10_valid}), .dst_payload({rcu_lane_ops_c10_payload}),
    .dst_wake(rcu_lane_ops_c10_wake), .dst_credit({rcu_lane_ops_c10_credit}), .dst_stall({rcu_lane_ops_c10_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c10_tid}), .dst_tid({rcu_lane_ops_c10_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C11), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c11 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c11_valid}), .src_payload({b_rcu_lane_ops_c11_payload}),
    .src_wake(b_rcu_lane_ops_c11_wake), .src_credit({b_rcu_lane_ops_c11_credit}), .src_stall({b_rcu_lane_ops_c11_stall}),
    .dst_valid({rcu_lane_ops_c11_valid}), .dst_payload({rcu_lane_ops_c11_payload}),
    .dst_wake(rcu_lane_ops_c11_wake), .dst_credit({rcu_lane_ops_c11_credit}), .dst_stall({rcu_lane_ops_c11_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c11_tid}), .dst_tid({rcu_lane_ops_c11_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C12), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c12 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c12_valid}), .src_payload({b_rcu_lane_ops_c12_payload}),
    .src_wake(b_rcu_lane_ops_c12_wake), .src_credit({b_rcu_lane_ops_c12_credit}), .src_stall({b_rcu_lane_ops_c12_stall}),
    .dst_valid({rcu_lane_ops_c12_valid}), .dst_payload({rcu_lane_ops_c12_payload}),
    .dst_wake(rcu_lane_ops_c12_wake), .dst_credit({rcu_lane_ops_c12_credit}), .dst_stall({rcu_lane_ops_c12_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c12_tid}), .dst_tid({rcu_lane_ops_c12_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C13), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c13 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c13_valid}), .src_payload({b_rcu_lane_ops_c13_payload}),
    .src_wake(b_rcu_lane_ops_c13_wake), .src_credit({b_rcu_lane_ops_c13_credit}), .src_stall({b_rcu_lane_ops_c13_stall}),
    .dst_valid({rcu_lane_ops_c13_valid}), .dst_payload({rcu_lane_ops_c13_payload}),
    .dst_wake(rcu_lane_ops_c13_wake), .dst_credit({rcu_lane_ops_c13_credit}), .dst_stall({rcu_lane_ops_c13_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c13_tid}), .dst_tid({rcu_lane_ops_c13_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C14), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c14 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c14_valid}), .src_payload({b_rcu_lane_ops_c14_payload}),
    .src_wake(b_rcu_lane_ops_c14_wake), .src_credit({b_rcu_lane_ops_c14_credit}), .src_stall({b_rcu_lane_ops_c14_stall}),
    .dst_valid({rcu_lane_ops_c14_valid}), .dst_payload({rcu_lane_ops_c14_payload}),
    .dst_wake(rcu_lane_ops_c14_wake), .dst_credit({rcu_lane_ops_c14_credit}), .dst_stall({rcu_lane_ops_c14_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c14_tid}), .dst_tid({rcu_lane_ops_c14_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C15), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c15 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c15_valid}), .src_payload({b_rcu_lane_ops_c15_payload}),
    .src_wake(b_rcu_lane_ops_c15_wake), .src_credit({b_rcu_lane_ops_c15_credit}), .src_stall({b_rcu_lane_ops_c15_stall}),
    .dst_valid({rcu_lane_ops_c15_valid}), .dst_payload({rcu_lane_ops_c15_payload}),
    .dst_wake(rcu_lane_ops_c15_wake), .dst_credit({rcu_lane_ops_c15_credit}), .dst_stall({rcu_lane_ops_c15_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c15_tid}), .dst_tid({rcu_lane_ops_c15_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C16), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c16 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c16_valid}), .src_payload({b_rcu_lane_ops_c16_payload}),
    .src_wake(b_rcu_lane_ops_c16_wake), .src_credit({b_rcu_lane_ops_c16_credit}), .src_stall({b_rcu_lane_ops_c16_stall}),
    .dst_valid({rcu_lane_ops_c16_valid}), .dst_payload({rcu_lane_ops_c16_payload}),
    .dst_wake(rcu_lane_ops_c16_wake), .dst_credit({rcu_lane_ops_c16_credit}), .dst_stall({rcu_lane_ops_c16_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c16_tid}), .dst_tid({rcu_lane_ops_c16_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C17), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c17 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c17_valid}), .src_payload({b_rcu_lane_ops_c17_payload}),
    .src_wake(b_rcu_lane_ops_c17_wake), .src_credit({b_rcu_lane_ops_c17_credit}), .src_stall({b_rcu_lane_ops_c17_stall}),
    .dst_valid({rcu_lane_ops_c17_valid}), .dst_payload({rcu_lane_ops_c17_payload}),
    .dst_wake(rcu_lane_ops_c17_wake), .dst_credit({rcu_lane_ops_c17_credit}), .dst_stall({rcu_lane_ops_c17_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c17_tid}), .dst_tid({rcu_lane_ops_c17_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C18), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c18 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c18_valid}), .src_payload({b_rcu_lane_ops_c18_payload}),
    .src_wake(b_rcu_lane_ops_c18_wake), .src_credit({b_rcu_lane_ops_c18_credit}), .src_stall({b_rcu_lane_ops_c18_stall}),
    .dst_valid({rcu_lane_ops_c18_valid}), .dst_payload({rcu_lane_ops_c18_payload}),
    .dst_wake(rcu_lane_ops_c18_wake), .dst_credit({rcu_lane_ops_c18_credit}), .dst_stall({rcu_lane_ops_c18_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c18_tid}), .dst_tid({rcu_lane_ops_c18_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C19), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c19 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c19_valid}), .src_payload({b_rcu_lane_ops_c19_payload}),
    .src_wake(b_rcu_lane_ops_c19_wake), .src_credit({b_rcu_lane_ops_c19_credit}), .src_stall({b_rcu_lane_ops_c19_stall}),
    .dst_valid({rcu_lane_ops_c19_valid}), .dst_payload({rcu_lane_ops_c19_payload}),
    .dst_wake(rcu_lane_ops_c19_wake), .dst_credit({rcu_lane_ops_c19_credit}), .dst_stall({rcu_lane_ops_c19_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c19_tid}), .dst_tid({rcu_lane_ops_c19_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C20), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c20 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c20_valid}), .src_payload({b_rcu_lane_ops_c20_payload}),
    .src_wake(b_rcu_lane_ops_c20_wake), .src_credit({b_rcu_lane_ops_c20_credit}), .src_stall({b_rcu_lane_ops_c20_stall}),
    .dst_valid({rcu_lane_ops_c20_valid}), .dst_payload({rcu_lane_ops_c20_payload}),
    .dst_wake(rcu_lane_ops_c20_wake), .dst_credit({rcu_lane_ops_c20_credit}), .dst_stall({rcu_lane_ops_c20_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c20_tid}), .dst_tid({rcu_lane_ops_c20_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C21), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c21 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c21_valid}), .src_payload({b_rcu_lane_ops_c21_payload}),
    .src_wake(b_rcu_lane_ops_c21_wake), .src_credit({b_rcu_lane_ops_c21_credit}), .src_stall({b_rcu_lane_ops_c21_stall}),
    .dst_valid({rcu_lane_ops_c21_valid}), .dst_payload({rcu_lane_ops_c21_payload}),
    .dst_wake(rcu_lane_ops_c21_wake), .dst_credit({rcu_lane_ops_c21_credit}), .dst_stall({rcu_lane_ops_c21_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c21_tid}), .dst_tid({rcu_lane_ops_c21_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C22), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c22 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c22_valid}), .src_payload({b_rcu_lane_ops_c22_payload}),
    .src_wake(b_rcu_lane_ops_c22_wake), .src_credit({b_rcu_lane_ops_c22_credit}), .src_stall({b_rcu_lane_ops_c22_stall}),
    .dst_valid({rcu_lane_ops_c22_valid}), .dst_payload({rcu_lane_ops_c22_payload}),
    .dst_wake(rcu_lane_ops_c22_wake), .dst_credit({rcu_lane_ops_c22_credit}), .dst_stall({rcu_lane_ops_c22_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c22_tid}), .dst_tid({rcu_lane_ops_c22_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C23), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c23 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c23_valid}), .src_payload({b_rcu_lane_ops_c23_payload}),
    .src_wake(b_rcu_lane_ops_c23_wake), .src_credit({b_rcu_lane_ops_c23_credit}), .src_stall({b_rcu_lane_ops_c23_stall}),
    .dst_valid({rcu_lane_ops_c23_valid}), .dst_payload({rcu_lane_ops_c23_payload}),
    .dst_wake(rcu_lane_ops_c23_wake), .dst_credit({rcu_lane_ops_c23_credit}), .dst_stall({rcu_lane_ops_c23_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c23_tid}), .dst_tid({rcu_lane_ops_c23_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C24), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c24 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c24_valid}), .src_payload({b_rcu_lane_ops_c24_payload}),
    .src_wake(b_rcu_lane_ops_c24_wake), .src_credit({b_rcu_lane_ops_c24_credit}), .src_stall({b_rcu_lane_ops_c24_stall}),
    .dst_valid({rcu_lane_ops_c24_valid}), .dst_payload({rcu_lane_ops_c24_payload}),
    .dst_wake(rcu_lane_ops_c24_wake), .dst_credit({rcu_lane_ops_c24_credit}), .dst_stall({rcu_lane_ops_c24_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c24_tid}), .dst_tid({rcu_lane_ops_c24_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C25), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c25 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c25_valid}), .src_payload({b_rcu_lane_ops_c25_payload}),
    .src_wake(b_rcu_lane_ops_c25_wake), .src_credit({b_rcu_lane_ops_c25_credit}), .src_stall({b_rcu_lane_ops_c25_stall}),
    .dst_valid({rcu_lane_ops_c25_valid}), .dst_payload({rcu_lane_ops_c25_payload}),
    .dst_wake(rcu_lane_ops_c25_wake), .dst_credit({rcu_lane_ops_c25_credit}), .dst_stall({rcu_lane_ops_c25_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c25_tid}), .dst_tid({rcu_lane_ops_c25_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C26), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c26 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c26_valid}), .src_payload({b_rcu_lane_ops_c26_payload}),
    .src_wake(b_rcu_lane_ops_c26_wake), .src_credit({b_rcu_lane_ops_c26_credit}), .src_stall({b_rcu_lane_ops_c26_stall}),
    .dst_valid({rcu_lane_ops_c26_valid}), .dst_payload({rcu_lane_ops_c26_payload}),
    .dst_wake(rcu_lane_ops_c26_wake), .dst_credit({rcu_lane_ops_c26_credit}), .dst_stall({rcu_lane_ops_c26_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c26_tid}), .dst_tid({rcu_lane_ops_c26_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C27), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c27 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c27_valid}), .src_payload({b_rcu_lane_ops_c27_payload}),
    .src_wake(b_rcu_lane_ops_c27_wake), .src_credit({b_rcu_lane_ops_c27_credit}), .src_stall({b_rcu_lane_ops_c27_stall}),
    .dst_valid({rcu_lane_ops_c27_valid}), .dst_payload({rcu_lane_ops_c27_payload}),
    .dst_wake(rcu_lane_ops_c27_wake), .dst_credit({rcu_lane_ops_c27_credit}), .dst_stall({rcu_lane_ops_c27_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c27_tid}), .dst_tid({rcu_lane_ops_c27_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C28), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c28 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c28_valid}), .src_payload({b_rcu_lane_ops_c28_payload}),
    .src_wake(b_rcu_lane_ops_c28_wake), .src_credit({b_rcu_lane_ops_c28_credit}), .src_stall({b_rcu_lane_ops_c28_stall}),
    .dst_valid({rcu_lane_ops_c28_valid}), .dst_payload({rcu_lane_ops_c28_payload}),
    .dst_wake(rcu_lane_ops_c28_wake), .dst_credit({rcu_lane_ops_c28_credit}), .dst_stall({rcu_lane_ops_c28_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c28_tid}), .dst_tid({rcu_lane_ops_c28_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C29), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c29 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c29_valid}), .src_payload({b_rcu_lane_ops_c29_payload}),
    .src_wake(b_rcu_lane_ops_c29_wake), .src_credit({b_rcu_lane_ops_c29_credit}), .src_stall({b_rcu_lane_ops_c29_stall}),
    .dst_valid({rcu_lane_ops_c29_valid}), .dst_payload({rcu_lane_ops_c29_payload}),
    .dst_wake(rcu_lane_ops_c29_wake), .dst_credit({rcu_lane_ops_c29_credit}), .dst_stall({rcu_lane_ops_c29_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c29_tid}), .dst_tid({rcu_lane_ops_c29_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C30), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c30 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c30_valid}), .src_payload({b_rcu_lane_ops_c30_payload}),
    .src_wake(b_rcu_lane_ops_c30_wake), .src_credit({b_rcu_lane_ops_c30_credit}), .src_stall({b_rcu_lane_ops_c30_stall}),
    .dst_valid({rcu_lane_ops_c30_valid}), .dst_payload({rcu_lane_ops_c30_payload}),
    .dst_wake(rcu_lane_ops_c30_wake), .dst_credit({rcu_lane_ops_c30_credit}), .dst_stall({rcu_lane_ops_c30_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c30_tid}), .dst_tid({rcu_lane_ops_c30_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C31), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops_c31 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c31_valid}), .src_payload({b_rcu_lane_ops_c31_payload}),
    .src_wake(b_rcu_lane_ops_c31_wake), .src_credit({b_rcu_lane_ops_c31_credit}), .src_stall({b_rcu_lane_ops_c31_stall}),
    .dst_valid({rcu_lane_ops_c31_valid}), .dst_payload({rcu_lane_ops_c31_payload}),
    .dst_wake(rcu_lane_ops_c31_wake), .dst_credit({rcu_lane_ops_c31_credit}), .dst_stall({rcu_lane_ops_c31_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c31_tid}), .dst_tid({rcu_lane_ops_c31_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C00), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c00 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c00_valid}), .src_payload({lane_rcu_res_c00_payload}),
    .src_wake(lane_rcu_res_c00_wake), .src_credit({lane_rcu_res_c00_credit}), .src_stall({lane_rcu_res_c00_stall}),
    .dst_valid({b_lane_rcu_res_c00_valid}), .dst_payload({b_lane_rcu_res_c00_payload}),
    .dst_wake(b_lane_rcu_res_c00_wake), .dst_credit({b_lane_rcu_res_c00_credit}), .dst_stall({b_lane_rcu_res_c00_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c00_tid}), .dst_tid({b_lane_rcu_res_c00_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C01), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c01 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c01_valid}), .src_payload({lane_rcu_res_c01_payload}),
    .src_wake(lane_rcu_res_c01_wake), .src_credit({lane_rcu_res_c01_credit}), .src_stall({lane_rcu_res_c01_stall}),
    .dst_valid({b_lane_rcu_res_c01_valid}), .dst_payload({b_lane_rcu_res_c01_payload}),
    .dst_wake(b_lane_rcu_res_c01_wake), .dst_credit({b_lane_rcu_res_c01_credit}), .dst_stall({b_lane_rcu_res_c01_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c01_tid}), .dst_tid({b_lane_rcu_res_c01_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C02), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c02 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c02_valid}), .src_payload({lane_rcu_res_c02_payload}),
    .src_wake(lane_rcu_res_c02_wake), .src_credit({lane_rcu_res_c02_credit}), .src_stall({lane_rcu_res_c02_stall}),
    .dst_valid({b_lane_rcu_res_c02_valid}), .dst_payload({b_lane_rcu_res_c02_payload}),
    .dst_wake(b_lane_rcu_res_c02_wake), .dst_credit({b_lane_rcu_res_c02_credit}), .dst_stall({b_lane_rcu_res_c02_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c02_tid}), .dst_tid({b_lane_rcu_res_c02_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C03), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c03 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c03_valid}), .src_payload({lane_rcu_res_c03_payload}),
    .src_wake(lane_rcu_res_c03_wake), .src_credit({lane_rcu_res_c03_credit}), .src_stall({lane_rcu_res_c03_stall}),
    .dst_valid({b_lane_rcu_res_c03_valid}), .dst_payload({b_lane_rcu_res_c03_payload}),
    .dst_wake(b_lane_rcu_res_c03_wake), .dst_credit({b_lane_rcu_res_c03_credit}), .dst_stall({b_lane_rcu_res_c03_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c03_tid}), .dst_tid({b_lane_rcu_res_c03_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C04), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c04 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c04_valid}), .src_payload({lane_rcu_res_c04_payload}),
    .src_wake(lane_rcu_res_c04_wake), .src_credit({lane_rcu_res_c04_credit}), .src_stall({lane_rcu_res_c04_stall}),
    .dst_valid({b_lane_rcu_res_c04_valid}), .dst_payload({b_lane_rcu_res_c04_payload}),
    .dst_wake(b_lane_rcu_res_c04_wake), .dst_credit({b_lane_rcu_res_c04_credit}), .dst_stall({b_lane_rcu_res_c04_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c04_tid}), .dst_tid({b_lane_rcu_res_c04_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C05), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c05 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c05_valid}), .src_payload({lane_rcu_res_c05_payload}),
    .src_wake(lane_rcu_res_c05_wake), .src_credit({lane_rcu_res_c05_credit}), .src_stall({lane_rcu_res_c05_stall}),
    .dst_valid({b_lane_rcu_res_c05_valid}), .dst_payload({b_lane_rcu_res_c05_payload}),
    .dst_wake(b_lane_rcu_res_c05_wake), .dst_credit({b_lane_rcu_res_c05_credit}), .dst_stall({b_lane_rcu_res_c05_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c05_tid}), .dst_tid({b_lane_rcu_res_c05_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C06), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c06 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c06_valid}), .src_payload({lane_rcu_res_c06_payload}),
    .src_wake(lane_rcu_res_c06_wake), .src_credit({lane_rcu_res_c06_credit}), .src_stall({lane_rcu_res_c06_stall}),
    .dst_valid({b_lane_rcu_res_c06_valid}), .dst_payload({b_lane_rcu_res_c06_payload}),
    .dst_wake(b_lane_rcu_res_c06_wake), .dst_credit({b_lane_rcu_res_c06_credit}), .dst_stall({b_lane_rcu_res_c06_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c06_tid}), .dst_tid({b_lane_rcu_res_c06_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C07), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c07 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c07_valid}), .src_payload({lane_rcu_res_c07_payload}),
    .src_wake(lane_rcu_res_c07_wake), .src_credit({lane_rcu_res_c07_credit}), .src_stall({lane_rcu_res_c07_stall}),
    .dst_valid({b_lane_rcu_res_c07_valid}), .dst_payload({b_lane_rcu_res_c07_payload}),
    .dst_wake(b_lane_rcu_res_c07_wake), .dst_credit({b_lane_rcu_res_c07_credit}), .dst_stall({b_lane_rcu_res_c07_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c07_tid}), .dst_tid({b_lane_rcu_res_c07_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C08), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c08 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c08_valid}), .src_payload({lane_rcu_res_c08_payload}),
    .src_wake(lane_rcu_res_c08_wake), .src_credit({lane_rcu_res_c08_credit}), .src_stall({lane_rcu_res_c08_stall}),
    .dst_valid({b_lane_rcu_res_c08_valid}), .dst_payload({b_lane_rcu_res_c08_payload}),
    .dst_wake(b_lane_rcu_res_c08_wake), .dst_credit({b_lane_rcu_res_c08_credit}), .dst_stall({b_lane_rcu_res_c08_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c08_tid}), .dst_tid({b_lane_rcu_res_c08_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C09), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c09 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c09_valid}), .src_payload({lane_rcu_res_c09_payload}),
    .src_wake(lane_rcu_res_c09_wake), .src_credit({lane_rcu_res_c09_credit}), .src_stall({lane_rcu_res_c09_stall}),
    .dst_valid({b_lane_rcu_res_c09_valid}), .dst_payload({b_lane_rcu_res_c09_payload}),
    .dst_wake(b_lane_rcu_res_c09_wake), .dst_credit({b_lane_rcu_res_c09_credit}), .dst_stall({b_lane_rcu_res_c09_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c09_tid}), .dst_tid({b_lane_rcu_res_c09_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C10), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c10 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c10_valid}), .src_payload({lane_rcu_res_c10_payload}),
    .src_wake(lane_rcu_res_c10_wake), .src_credit({lane_rcu_res_c10_credit}), .src_stall({lane_rcu_res_c10_stall}),
    .dst_valid({b_lane_rcu_res_c10_valid}), .dst_payload({b_lane_rcu_res_c10_payload}),
    .dst_wake(b_lane_rcu_res_c10_wake), .dst_credit({b_lane_rcu_res_c10_credit}), .dst_stall({b_lane_rcu_res_c10_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c10_tid}), .dst_tid({b_lane_rcu_res_c10_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C11), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c11 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c11_valid}), .src_payload({lane_rcu_res_c11_payload}),
    .src_wake(lane_rcu_res_c11_wake), .src_credit({lane_rcu_res_c11_credit}), .src_stall({lane_rcu_res_c11_stall}),
    .dst_valid({b_lane_rcu_res_c11_valid}), .dst_payload({b_lane_rcu_res_c11_payload}),
    .dst_wake(b_lane_rcu_res_c11_wake), .dst_credit({b_lane_rcu_res_c11_credit}), .dst_stall({b_lane_rcu_res_c11_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c11_tid}), .dst_tid({b_lane_rcu_res_c11_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C12), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c12 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c12_valid}), .src_payload({lane_rcu_res_c12_payload}),
    .src_wake(lane_rcu_res_c12_wake), .src_credit({lane_rcu_res_c12_credit}), .src_stall({lane_rcu_res_c12_stall}),
    .dst_valid({b_lane_rcu_res_c12_valid}), .dst_payload({b_lane_rcu_res_c12_payload}),
    .dst_wake(b_lane_rcu_res_c12_wake), .dst_credit({b_lane_rcu_res_c12_credit}), .dst_stall({b_lane_rcu_res_c12_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c12_tid}), .dst_tid({b_lane_rcu_res_c12_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C13), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c13 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c13_valid}), .src_payload({lane_rcu_res_c13_payload}),
    .src_wake(lane_rcu_res_c13_wake), .src_credit({lane_rcu_res_c13_credit}), .src_stall({lane_rcu_res_c13_stall}),
    .dst_valid({b_lane_rcu_res_c13_valid}), .dst_payload({b_lane_rcu_res_c13_payload}),
    .dst_wake(b_lane_rcu_res_c13_wake), .dst_credit({b_lane_rcu_res_c13_credit}), .dst_stall({b_lane_rcu_res_c13_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c13_tid}), .dst_tid({b_lane_rcu_res_c13_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C14), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c14 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c14_valid}), .src_payload({lane_rcu_res_c14_payload}),
    .src_wake(lane_rcu_res_c14_wake), .src_credit({lane_rcu_res_c14_credit}), .src_stall({lane_rcu_res_c14_stall}),
    .dst_valid({b_lane_rcu_res_c14_valid}), .dst_payload({b_lane_rcu_res_c14_payload}),
    .dst_wake(b_lane_rcu_res_c14_wake), .dst_credit({b_lane_rcu_res_c14_credit}), .dst_stall({b_lane_rcu_res_c14_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c14_tid}), .dst_tid({b_lane_rcu_res_c14_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C15), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c15 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c15_valid}), .src_payload({lane_rcu_res_c15_payload}),
    .src_wake(lane_rcu_res_c15_wake), .src_credit({lane_rcu_res_c15_credit}), .src_stall({lane_rcu_res_c15_stall}),
    .dst_valid({b_lane_rcu_res_c15_valid}), .dst_payload({b_lane_rcu_res_c15_payload}),
    .dst_wake(b_lane_rcu_res_c15_wake), .dst_credit({b_lane_rcu_res_c15_credit}), .dst_stall({b_lane_rcu_res_c15_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c15_tid}), .dst_tid({b_lane_rcu_res_c15_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C16), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c16 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c16_valid}), .src_payload({lane_rcu_res_c16_payload}),
    .src_wake(lane_rcu_res_c16_wake), .src_credit({lane_rcu_res_c16_credit}), .src_stall({lane_rcu_res_c16_stall}),
    .dst_valid({b_lane_rcu_res_c16_valid}), .dst_payload({b_lane_rcu_res_c16_payload}),
    .dst_wake(b_lane_rcu_res_c16_wake), .dst_credit({b_lane_rcu_res_c16_credit}), .dst_stall({b_lane_rcu_res_c16_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c16_tid}), .dst_tid({b_lane_rcu_res_c16_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C17), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c17 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c17_valid}), .src_payload({lane_rcu_res_c17_payload}),
    .src_wake(lane_rcu_res_c17_wake), .src_credit({lane_rcu_res_c17_credit}), .src_stall({lane_rcu_res_c17_stall}),
    .dst_valid({b_lane_rcu_res_c17_valid}), .dst_payload({b_lane_rcu_res_c17_payload}),
    .dst_wake(b_lane_rcu_res_c17_wake), .dst_credit({b_lane_rcu_res_c17_credit}), .dst_stall({b_lane_rcu_res_c17_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c17_tid}), .dst_tid({b_lane_rcu_res_c17_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C18), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c18 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c18_valid}), .src_payload({lane_rcu_res_c18_payload}),
    .src_wake(lane_rcu_res_c18_wake), .src_credit({lane_rcu_res_c18_credit}), .src_stall({lane_rcu_res_c18_stall}),
    .dst_valid({b_lane_rcu_res_c18_valid}), .dst_payload({b_lane_rcu_res_c18_payload}),
    .dst_wake(b_lane_rcu_res_c18_wake), .dst_credit({b_lane_rcu_res_c18_credit}), .dst_stall({b_lane_rcu_res_c18_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c18_tid}), .dst_tid({b_lane_rcu_res_c18_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C19), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c19 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c19_valid}), .src_payload({lane_rcu_res_c19_payload}),
    .src_wake(lane_rcu_res_c19_wake), .src_credit({lane_rcu_res_c19_credit}), .src_stall({lane_rcu_res_c19_stall}),
    .dst_valid({b_lane_rcu_res_c19_valid}), .dst_payload({b_lane_rcu_res_c19_payload}),
    .dst_wake(b_lane_rcu_res_c19_wake), .dst_credit({b_lane_rcu_res_c19_credit}), .dst_stall({b_lane_rcu_res_c19_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c19_tid}), .dst_tid({b_lane_rcu_res_c19_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C20), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c20 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c20_valid}), .src_payload({lane_rcu_res_c20_payload}),
    .src_wake(lane_rcu_res_c20_wake), .src_credit({lane_rcu_res_c20_credit}), .src_stall({lane_rcu_res_c20_stall}),
    .dst_valid({b_lane_rcu_res_c20_valid}), .dst_payload({b_lane_rcu_res_c20_payload}),
    .dst_wake(b_lane_rcu_res_c20_wake), .dst_credit({b_lane_rcu_res_c20_credit}), .dst_stall({b_lane_rcu_res_c20_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c20_tid}), .dst_tid({b_lane_rcu_res_c20_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C21), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c21 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c21_valid}), .src_payload({lane_rcu_res_c21_payload}),
    .src_wake(lane_rcu_res_c21_wake), .src_credit({lane_rcu_res_c21_credit}), .src_stall({lane_rcu_res_c21_stall}),
    .dst_valid({b_lane_rcu_res_c21_valid}), .dst_payload({b_lane_rcu_res_c21_payload}),
    .dst_wake(b_lane_rcu_res_c21_wake), .dst_credit({b_lane_rcu_res_c21_credit}), .dst_stall({b_lane_rcu_res_c21_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c21_tid}), .dst_tid({b_lane_rcu_res_c21_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C22), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c22 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c22_valid}), .src_payload({lane_rcu_res_c22_payload}),
    .src_wake(lane_rcu_res_c22_wake), .src_credit({lane_rcu_res_c22_credit}), .src_stall({lane_rcu_res_c22_stall}),
    .dst_valid({b_lane_rcu_res_c22_valid}), .dst_payload({b_lane_rcu_res_c22_payload}),
    .dst_wake(b_lane_rcu_res_c22_wake), .dst_credit({b_lane_rcu_res_c22_credit}), .dst_stall({b_lane_rcu_res_c22_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c22_tid}), .dst_tid({b_lane_rcu_res_c22_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C23), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c23 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c23_valid}), .src_payload({lane_rcu_res_c23_payload}),
    .src_wake(lane_rcu_res_c23_wake), .src_credit({lane_rcu_res_c23_credit}), .src_stall({lane_rcu_res_c23_stall}),
    .dst_valid({b_lane_rcu_res_c23_valid}), .dst_payload({b_lane_rcu_res_c23_payload}),
    .dst_wake(b_lane_rcu_res_c23_wake), .dst_credit({b_lane_rcu_res_c23_credit}), .dst_stall({b_lane_rcu_res_c23_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c23_tid}), .dst_tid({b_lane_rcu_res_c23_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C24), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c24 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c24_valid}), .src_payload({lane_rcu_res_c24_payload}),
    .src_wake(lane_rcu_res_c24_wake), .src_credit({lane_rcu_res_c24_credit}), .src_stall({lane_rcu_res_c24_stall}),
    .dst_valid({b_lane_rcu_res_c24_valid}), .dst_payload({b_lane_rcu_res_c24_payload}),
    .dst_wake(b_lane_rcu_res_c24_wake), .dst_credit({b_lane_rcu_res_c24_credit}), .dst_stall({b_lane_rcu_res_c24_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c24_tid}), .dst_tid({b_lane_rcu_res_c24_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C25), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c25 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c25_valid}), .src_payload({lane_rcu_res_c25_payload}),
    .src_wake(lane_rcu_res_c25_wake), .src_credit({lane_rcu_res_c25_credit}), .src_stall({lane_rcu_res_c25_stall}),
    .dst_valid({b_lane_rcu_res_c25_valid}), .dst_payload({b_lane_rcu_res_c25_payload}),
    .dst_wake(b_lane_rcu_res_c25_wake), .dst_credit({b_lane_rcu_res_c25_credit}), .dst_stall({b_lane_rcu_res_c25_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c25_tid}), .dst_tid({b_lane_rcu_res_c25_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C26), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c26 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c26_valid}), .src_payload({lane_rcu_res_c26_payload}),
    .src_wake(lane_rcu_res_c26_wake), .src_credit({lane_rcu_res_c26_credit}), .src_stall({lane_rcu_res_c26_stall}),
    .dst_valid({b_lane_rcu_res_c26_valid}), .dst_payload({b_lane_rcu_res_c26_payload}),
    .dst_wake(b_lane_rcu_res_c26_wake), .dst_credit({b_lane_rcu_res_c26_credit}), .dst_stall({b_lane_rcu_res_c26_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c26_tid}), .dst_tid({b_lane_rcu_res_c26_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C27), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c27 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c27_valid}), .src_payload({lane_rcu_res_c27_payload}),
    .src_wake(lane_rcu_res_c27_wake), .src_credit({lane_rcu_res_c27_credit}), .src_stall({lane_rcu_res_c27_stall}),
    .dst_valid({b_lane_rcu_res_c27_valid}), .dst_payload({b_lane_rcu_res_c27_payload}),
    .dst_wake(b_lane_rcu_res_c27_wake), .dst_credit({b_lane_rcu_res_c27_credit}), .dst_stall({b_lane_rcu_res_c27_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c27_tid}), .dst_tid({b_lane_rcu_res_c27_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C28), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c28 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c28_valid}), .src_payload({lane_rcu_res_c28_payload}),
    .src_wake(lane_rcu_res_c28_wake), .src_credit({lane_rcu_res_c28_credit}), .src_stall({lane_rcu_res_c28_stall}),
    .dst_valid({b_lane_rcu_res_c28_valid}), .dst_payload({b_lane_rcu_res_c28_payload}),
    .dst_wake(b_lane_rcu_res_c28_wake), .dst_credit({b_lane_rcu_res_c28_credit}), .dst_stall({b_lane_rcu_res_c28_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c28_tid}), .dst_tid({b_lane_rcu_res_c28_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C29), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c29 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c29_valid}), .src_payload({lane_rcu_res_c29_payload}),
    .src_wake(lane_rcu_res_c29_wake), .src_credit({lane_rcu_res_c29_credit}), .src_stall({lane_rcu_res_c29_stall}),
    .dst_valid({b_lane_rcu_res_c29_valid}), .dst_payload({b_lane_rcu_res_c29_payload}),
    .dst_wake(b_lane_rcu_res_c29_wake), .dst_credit({b_lane_rcu_res_c29_credit}), .dst_stall({b_lane_rcu_res_c29_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c29_tid}), .dst_tid({b_lane_rcu_res_c29_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C30), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c30 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c30_valid}), .src_payload({lane_rcu_res_c30_payload}),
    .src_wake(lane_rcu_res_c30_wake), .src_credit({lane_rcu_res_c30_credit}), .src_stall({lane_rcu_res_c30_stall}),
    .dst_valid({b_lane_rcu_res_c30_valid}), .dst_payload({b_lane_rcu_res_c30_payload}),
    .dst_wake(b_lane_rcu_res_c30_wake), .dst_credit({b_lane_rcu_res_c30_credit}), .dst_stall({b_lane_rcu_res_c30_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c30_tid}), .dst_tid({b_lane_rcu_res_c30_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C31), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res_c31 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c31_valid}), .src_payload({lane_rcu_res_c31_payload}),
    .src_wake(lane_rcu_res_c31_wake), .src_credit({lane_rcu_res_c31_credit}), .src_stall({lane_rcu_res_c31_stall}),
    .dst_valid({b_lane_rcu_res_c31_valid}), .dst_payload({b_lane_rcu_res_c31_payload}),
    .dst_wake(b_lane_rcu_res_c31_wake), .dst_credit({b_lane_rcu_res_c31_credit}), .dst_stall({b_lane_rcu_res_c31_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c31_tid}), .dst_tid({b_lane_rcu_res_c31_tid})
`endif
  );
  // ccv_rcu_ooe_done, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_OOE_DONE), .SLOTS(7), .PAYLOAD_W(73)) u_rpt_rcu_ooe_done (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_ooe_done_s6_valid, b_rcu_ooe_done_s5_valid, b_rcu_ooe_done_s4_valid, b_rcu_ooe_done_s3_valid, b_rcu_ooe_done_s2_valid, b_rcu_ooe_done_s1_valid, b_rcu_ooe_done_s0_valid}), .src_payload({b_rcu_ooe_done_s6_payload, b_rcu_ooe_done_s5_payload, b_rcu_ooe_done_s4_payload, b_rcu_ooe_done_s3_payload, b_rcu_ooe_done_s2_payload, b_rcu_ooe_done_s1_payload, b_rcu_ooe_done_s0_payload}),
    .src_wake(b_rcu_ooe_done_wake), .src_credit({b_rcu_ooe_done_s6_credit, b_rcu_ooe_done_s5_credit, b_rcu_ooe_done_s4_credit, b_rcu_ooe_done_s3_credit, b_rcu_ooe_done_s2_credit, b_rcu_ooe_done_s1_credit, b_rcu_ooe_done_s0_credit}), .src_stall({b_rcu_ooe_done_s6_stall, b_rcu_ooe_done_s5_stall, b_rcu_ooe_done_s4_stall, b_rcu_ooe_done_s3_stall, b_rcu_ooe_done_s2_stall, b_rcu_ooe_done_s1_stall, b_rcu_ooe_done_s0_stall}),
    .dst_valid({rcu_ooe_done_s6_valid, rcu_ooe_done_s5_valid, rcu_ooe_done_s4_valid, rcu_ooe_done_s3_valid, rcu_ooe_done_s2_valid, rcu_ooe_done_s1_valid, rcu_ooe_done_s0_valid}), .dst_payload({rcu_ooe_done_s6_payload, rcu_ooe_done_s5_payload, rcu_ooe_done_s4_payload, rcu_ooe_done_s3_payload, rcu_ooe_done_s2_payload, rcu_ooe_done_s1_payload, rcu_ooe_done_s0_payload}),
    .dst_wake(rcu_ooe_done_wake), .dst_credit({rcu_ooe_done_s6_credit, rcu_ooe_done_s5_credit, rcu_ooe_done_s4_credit, rcu_ooe_done_s3_credit, rcu_ooe_done_s2_credit, rcu_ooe_done_s1_credit, rcu_ooe_done_s0_credit}), .dst_stall({rcu_ooe_done_s6_stall, rcu_ooe_done_s5_stall, rcu_ooe_done_s4_stall, rcu_ooe_done_s3_stall, rcu_ooe_done_s2_stall, rcu_ooe_done_s1_stall, rcu_ooe_done_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_ooe_done_s6_tid, b_rcu_ooe_done_s5_tid, b_rcu_ooe_done_s4_tid, b_rcu_ooe_done_s3_tid, b_rcu_ooe_done_s2_tid, b_rcu_ooe_done_s1_tid, b_rcu_ooe_done_s0_tid}), .dst_tid({rcu_ooe_done_s6_tid, rcu_ooe_done_s5_tid, rcu_ooe_done_s4_tid, rcu_ooe_done_s3_tid, rcu_ooe_done_s2_tid, rcu_ooe_done_s1_tid, rcu_ooe_done_s0_tid})
`endif
  );
  // ccv_rcu_miu_addr, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_MIU_ADDR), .SLOTS(4), .PAYLOAD_W(2151)) u_rpt_rcu_miu_addr (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_miu_addr_s3_valid, b_rcu_miu_addr_s2_valid, b_rcu_miu_addr_s1_valid, b_rcu_miu_addr_s0_valid}), .src_payload({b_rcu_miu_addr_s3_payload, b_rcu_miu_addr_s2_payload, b_rcu_miu_addr_s1_payload, b_rcu_miu_addr_s0_payload}),
    .src_wake(b_rcu_miu_addr_wake), .src_credit({b_rcu_miu_addr_s3_credit, b_rcu_miu_addr_s2_credit, b_rcu_miu_addr_s1_credit, b_rcu_miu_addr_s0_credit}), .src_stall({b_rcu_miu_addr_s3_stall, b_rcu_miu_addr_s2_stall, b_rcu_miu_addr_s1_stall, b_rcu_miu_addr_s0_stall}),
    .dst_valid({rcu_miu_addr_s3_valid, rcu_miu_addr_s2_valid, rcu_miu_addr_s1_valid, rcu_miu_addr_s0_valid}), .dst_payload({rcu_miu_addr_s3_payload, rcu_miu_addr_s2_payload, rcu_miu_addr_s1_payload, rcu_miu_addr_s0_payload}),
    .dst_wake(rcu_miu_addr_wake), .dst_credit({rcu_miu_addr_s3_credit, rcu_miu_addr_s2_credit, rcu_miu_addr_s1_credit, rcu_miu_addr_s0_credit}), .dst_stall({rcu_miu_addr_s3_stall, rcu_miu_addr_s2_stall, rcu_miu_addr_s1_stall, rcu_miu_addr_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_miu_addr_s3_tid, b_rcu_miu_addr_s2_tid, b_rcu_miu_addr_s1_tid, b_rcu_miu_addr_s0_tid}), .dst_tid({rcu_miu_addr_s3_tid, rcu_miu_addr_s2_tid, rcu_miu_addr_s1_tid, rcu_miu_addr_s0_tid})
`endif
  );
  // ccv_miu_rcu_data, destination end
  ccv_seq_rpt #(.STAGES(RPT_MIU_RCU_DATA), .SLOTS(4), .PAYLOAD_W(1114)) u_rpt_miu_rcu_data (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({miu_rcu_data_s3_valid, miu_rcu_data_s2_valid, miu_rcu_data_s1_valid, miu_rcu_data_s0_valid}), .src_payload({miu_rcu_data_s3_payload, miu_rcu_data_s2_payload, miu_rcu_data_s1_payload, miu_rcu_data_s0_payload}),
    .src_wake(miu_rcu_data_wake), .src_credit({miu_rcu_data_s3_credit, miu_rcu_data_s2_credit, miu_rcu_data_s1_credit, miu_rcu_data_s0_credit}), .src_stall({miu_rcu_data_s3_stall, miu_rcu_data_s2_stall, miu_rcu_data_s1_stall, miu_rcu_data_s0_stall}),
    .dst_valid({b_miu_rcu_data_s3_valid, b_miu_rcu_data_s2_valid, b_miu_rcu_data_s1_valid, b_miu_rcu_data_s0_valid}), .dst_payload({b_miu_rcu_data_s3_payload, b_miu_rcu_data_s2_payload, b_miu_rcu_data_s1_payload, b_miu_rcu_data_s0_payload}),
    .dst_wake(b_miu_rcu_data_wake), .dst_credit({b_miu_rcu_data_s3_credit, b_miu_rcu_data_s2_credit, b_miu_rcu_data_s1_credit, b_miu_rcu_data_s0_credit}), .dst_stall({b_miu_rcu_data_s3_stall, b_miu_rcu_data_s2_stall, b_miu_rcu_data_s1_stall, b_miu_rcu_data_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({miu_rcu_data_s3_tid, miu_rcu_data_s2_tid, miu_rcu_data_s1_tid, miu_rcu_data_s0_tid}), .dst_tid({b_miu_rcu_data_s3_tid, b_miu_rcu_data_s2_tid, b_miu_rcu_data_s1_tid, b_miu_rcu_data_s0_tid})
`endif
  );
  // ccv_rau_rcu_mig, destination end
  ccv_seq_rpt #(.STAGES(RPT_RAU_RCU_MIG), .SLOTS(1), .PAYLOAD_W(9)) u_rpt_rau_rcu_mig (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({rau_rcu_mig_valid}), .src_payload({rau_rcu_mig_payload}),
    .src_wake(rau_rcu_mig_wake), .src_credit({rau_rcu_mig_credit}), .src_stall({rau_rcu_mig_stall}),
    .dst_valid({b_rau_rcu_mig_valid}), .dst_payload({b_rau_rcu_mig_payload}),
    .dst_wake(b_rau_rcu_mig_wake), .dst_credit({b_rau_rcu_mig_credit}), .dst_stall({b_rau_rcu_mig_stall})
`ifdef CCV_TRACE
    , .src_tid({rau_rcu_mig_tid}), .dst_tid({b_rau_rcu_mig_tid})
`endif
  );
  // ccv_ooe_rcu_map, destination end
  ccv_seq_rpt #(.STAGES(RPT_OOE_RCU_MAP), .SLOTS(1), .PAYLOAD_W(222)) u_rpt_ooe_rcu_map (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({ooe_rcu_map_valid}), .src_payload({ooe_rcu_map_payload}),
    .src_wake(ooe_rcu_map_wake), .src_credit({ooe_rcu_map_credit}), .src_stall({ooe_rcu_map_stall}),
    .dst_valid({b_ooe_rcu_map_valid}), .dst_payload({b_ooe_rcu_map_payload}),
    .dst_wake(b_ooe_rcu_map_wake), .dst_credit({b_ooe_rcu_map_credit}), .dst_stall({b_ooe_rcu_map_stall})
`ifdef CCV_TRACE
    , .src_tid({ooe_rcu_map_tid}), .dst_tid({b_ooe_rcu_map_tid})
`endif
  );
  // ccv_rcu_pca_mig, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_PCA_MIG), .SLOTS(1), .PAYLOAD_W(1034)) u_rpt_rcu_pca_mig (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_pca_mig_valid}), .src_payload({b_rcu_pca_mig_payload}),
    .src_wake(b_rcu_pca_mig_wake), .src_credit({b_rcu_pca_mig_credit}), .src_stall({b_rcu_pca_mig_stall}),
    .dst_valid({rcu_pca_mig_valid}), .dst_payload({rcu_pca_mig_payload}),
    .dst_wake(rcu_pca_mig_wake), .dst_credit({rcu_pca_mig_credit}), .dst_stall({rcu_pca_mig_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_pca_mig_tid}), .dst_tid({rcu_pca_mig_tid})
`endif
  );
  // ccv_pca_rcu_mig, destination end
  ccv_seq_rpt #(.STAGES(RPT_PCA_RCU_MIG), .SLOTS(1), .PAYLOAD_W(1034)) u_rpt_pca_rcu_mig (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({pca_rcu_mig_valid}), .src_payload({pca_rcu_mig_payload}),
    .src_wake(pca_rcu_mig_wake), .src_credit({pca_rcu_mig_credit}), .src_stall({pca_rcu_mig_stall}),
    .dst_valid({b_pca_rcu_mig_valid}), .dst_payload({b_pca_rcu_mig_payload}),
    .dst_wake(b_pca_rcu_mig_wake), .dst_credit({b_pca_rcu_mig_credit}), .dst_stall({b_pca_rcu_mig_stall})
`ifdef CCV_TRACE
    , .src_tid({pca_rcu_mig_tid}), .dst_tid({b_pca_rcu_mig_tid})
`endif
  );
endmodule
