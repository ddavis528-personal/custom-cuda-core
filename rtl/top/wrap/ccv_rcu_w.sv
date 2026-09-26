// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_rcu_w: ccv_rcu and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. Every
// end has its repeater whether or not the link is repeated: STAGES is
// a parameter the top sets from params/links.json, 0 meaning wires, so
// a new split changes parameters and never this structure.
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
  logic b_ooe_rcu_issue_wake;
  logic b_rcu_lane_ops_c00_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c00_s0_payload;
  logic b_rcu_lane_ops_c00_s0_credit;
  logic b_rcu_lane_ops_c00_s0_stall;
  logic b_rcu_lane_ops_c00_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c00_s1_payload;
  logic b_rcu_lane_ops_c00_s1_credit;
  logic b_rcu_lane_ops_c00_s1_stall;
  logic b_rcu_lane_ops_c00_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c00_s2_payload;
  logic b_rcu_lane_ops_c00_s2_credit;
  logic b_rcu_lane_ops_c00_s2_stall;
  logic b_rcu_lane_ops_c00_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c00_s3_payload;
  logic b_rcu_lane_ops_c00_s3_credit;
  logic b_rcu_lane_ops_c00_s3_stall;
  logic b_rcu_lane_ops_c00_wake;
  logic b_rcu_lane_ops_c01_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c01_s0_payload;
  logic b_rcu_lane_ops_c01_s0_credit;
  logic b_rcu_lane_ops_c01_s0_stall;
  logic b_rcu_lane_ops_c01_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c01_s1_payload;
  logic b_rcu_lane_ops_c01_s1_credit;
  logic b_rcu_lane_ops_c01_s1_stall;
  logic b_rcu_lane_ops_c01_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c01_s2_payload;
  logic b_rcu_lane_ops_c01_s2_credit;
  logic b_rcu_lane_ops_c01_s2_stall;
  logic b_rcu_lane_ops_c01_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c01_s3_payload;
  logic b_rcu_lane_ops_c01_s3_credit;
  logic b_rcu_lane_ops_c01_s3_stall;
  logic b_rcu_lane_ops_c01_wake;
  logic b_rcu_lane_ops_c02_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c02_s0_payload;
  logic b_rcu_lane_ops_c02_s0_credit;
  logic b_rcu_lane_ops_c02_s0_stall;
  logic b_rcu_lane_ops_c02_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c02_s1_payload;
  logic b_rcu_lane_ops_c02_s1_credit;
  logic b_rcu_lane_ops_c02_s1_stall;
  logic b_rcu_lane_ops_c02_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c02_s2_payload;
  logic b_rcu_lane_ops_c02_s2_credit;
  logic b_rcu_lane_ops_c02_s2_stall;
  logic b_rcu_lane_ops_c02_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c02_s3_payload;
  logic b_rcu_lane_ops_c02_s3_credit;
  logic b_rcu_lane_ops_c02_s3_stall;
  logic b_rcu_lane_ops_c02_wake;
  logic b_rcu_lane_ops_c03_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c03_s0_payload;
  logic b_rcu_lane_ops_c03_s0_credit;
  logic b_rcu_lane_ops_c03_s0_stall;
  logic b_rcu_lane_ops_c03_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c03_s1_payload;
  logic b_rcu_lane_ops_c03_s1_credit;
  logic b_rcu_lane_ops_c03_s1_stall;
  logic b_rcu_lane_ops_c03_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c03_s2_payload;
  logic b_rcu_lane_ops_c03_s2_credit;
  logic b_rcu_lane_ops_c03_s2_stall;
  logic b_rcu_lane_ops_c03_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c03_s3_payload;
  logic b_rcu_lane_ops_c03_s3_credit;
  logic b_rcu_lane_ops_c03_s3_stall;
  logic b_rcu_lane_ops_c03_wake;
  logic b_rcu_lane_ops_c04_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c04_s0_payload;
  logic b_rcu_lane_ops_c04_s0_credit;
  logic b_rcu_lane_ops_c04_s0_stall;
  logic b_rcu_lane_ops_c04_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c04_s1_payload;
  logic b_rcu_lane_ops_c04_s1_credit;
  logic b_rcu_lane_ops_c04_s1_stall;
  logic b_rcu_lane_ops_c04_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c04_s2_payload;
  logic b_rcu_lane_ops_c04_s2_credit;
  logic b_rcu_lane_ops_c04_s2_stall;
  logic b_rcu_lane_ops_c04_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c04_s3_payload;
  logic b_rcu_lane_ops_c04_s3_credit;
  logic b_rcu_lane_ops_c04_s3_stall;
  logic b_rcu_lane_ops_c04_wake;
  logic b_rcu_lane_ops_c05_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c05_s0_payload;
  logic b_rcu_lane_ops_c05_s0_credit;
  logic b_rcu_lane_ops_c05_s0_stall;
  logic b_rcu_lane_ops_c05_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c05_s1_payload;
  logic b_rcu_lane_ops_c05_s1_credit;
  logic b_rcu_lane_ops_c05_s1_stall;
  logic b_rcu_lane_ops_c05_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c05_s2_payload;
  logic b_rcu_lane_ops_c05_s2_credit;
  logic b_rcu_lane_ops_c05_s2_stall;
  logic b_rcu_lane_ops_c05_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c05_s3_payload;
  logic b_rcu_lane_ops_c05_s3_credit;
  logic b_rcu_lane_ops_c05_s3_stall;
  logic b_rcu_lane_ops_c05_wake;
  logic b_rcu_lane_ops_c06_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c06_s0_payload;
  logic b_rcu_lane_ops_c06_s0_credit;
  logic b_rcu_lane_ops_c06_s0_stall;
  logic b_rcu_lane_ops_c06_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c06_s1_payload;
  logic b_rcu_lane_ops_c06_s1_credit;
  logic b_rcu_lane_ops_c06_s1_stall;
  logic b_rcu_lane_ops_c06_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c06_s2_payload;
  logic b_rcu_lane_ops_c06_s2_credit;
  logic b_rcu_lane_ops_c06_s2_stall;
  logic b_rcu_lane_ops_c06_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c06_s3_payload;
  logic b_rcu_lane_ops_c06_s3_credit;
  logic b_rcu_lane_ops_c06_s3_stall;
  logic b_rcu_lane_ops_c06_wake;
  logic b_rcu_lane_ops_c07_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c07_s0_payload;
  logic b_rcu_lane_ops_c07_s0_credit;
  logic b_rcu_lane_ops_c07_s0_stall;
  logic b_rcu_lane_ops_c07_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c07_s1_payload;
  logic b_rcu_lane_ops_c07_s1_credit;
  logic b_rcu_lane_ops_c07_s1_stall;
  logic b_rcu_lane_ops_c07_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c07_s2_payload;
  logic b_rcu_lane_ops_c07_s2_credit;
  logic b_rcu_lane_ops_c07_s2_stall;
  logic b_rcu_lane_ops_c07_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c07_s3_payload;
  logic b_rcu_lane_ops_c07_s3_credit;
  logic b_rcu_lane_ops_c07_s3_stall;
  logic b_rcu_lane_ops_c07_wake;
  logic b_rcu_lane_ops_c08_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c08_s0_payload;
  logic b_rcu_lane_ops_c08_s0_credit;
  logic b_rcu_lane_ops_c08_s0_stall;
  logic b_rcu_lane_ops_c08_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c08_s1_payload;
  logic b_rcu_lane_ops_c08_s1_credit;
  logic b_rcu_lane_ops_c08_s1_stall;
  logic b_rcu_lane_ops_c08_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c08_s2_payload;
  logic b_rcu_lane_ops_c08_s2_credit;
  logic b_rcu_lane_ops_c08_s2_stall;
  logic b_rcu_lane_ops_c08_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c08_s3_payload;
  logic b_rcu_lane_ops_c08_s3_credit;
  logic b_rcu_lane_ops_c08_s3_stall;
  logic b_rcu_lane_ops_c08_wake;
  logic b_rcu_lane_ops_c09_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c09_s0_payload;
  logic b_rcu_lane_ops_c09_s0_credit;
  logic b_rcu_lane_ops_c09_s0_stall;
  logic b_rcu_lane_ops_c09_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c09_s1_payload;
  logic b_rcu_lane_ops_c09_s1_credit;
  logic b_rcu_lane_ops_c09_s1_stall;
  logic b_rcu_lane_ops_c09_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c09_s2_payload;
  logic b_rcu_lane_ops_c09_s2_credit;
  logic b_rcu_lane_ops_c09_s2_stall;
  logic b_rcu_lane_ops_c09_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c09_s3_payload;
  logic b_rcu_lane_ops_c09_s3_credit;
  logic b_rcu_lane_ops_c09_s3_stall;
  logic b_rcu_lane_ops_c09_wake;
  logic b_rcu_lane_ops_c10_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c10_s0_payload;
  logic b_rcu_lane_ops_c10_s0_credit;
  logic b_rcu_lane_ops_c10_s0_stall;
  logic b_rcu_lane_ops_c10_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c10_s1_payload;
  logic b_rcu_lane_ops_c10_s1_credit;
  logic b_rcu_lane_ops_c10_s1_stall;
  logic b_rcu_lane_ops_c10_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c10_s2_payload;
  logic b_rcu_lane_ops_c10_s2_credit;
  logic b_rcu_lane_ops_c10_s2_stall;
  logic b_rcu_lane_ops_c10_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c10_s3_payload;
  logic b_rcu_lane_ops_c10_s3_credit;
  logic b_rcu_lane_ops_c10_s3_stall;
  logic b_rcu_lane_ops_c10_wake;
  logic b_rcu_lane_ops_c11_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c11_s0_payload;
  logic b_rcu_lane_ops_c11_s0_credit;
  logic b_rcu_lane_ops_c11_s0_stall;
  logic b_rcu_lane_ops_c11_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c11_s1_payload;
  logic b_rcu_lane_ops_c11_s1_credit;
  logic b_rcu_lane_ops_c11_s1_stall;
  logic b_rcu_lane_ops_c11_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c11_s2_payload;
  logic b_rcu_lane_ops_c11_s2_credit;
  logic b_rcu_lane_ops_c11_s2_stall;
  logic b_rcu_lane_ops_c11_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c11_s3_payload;
  logic b_rcu_lane_ops_c11_s3_credit;
  logic b_rcu_lane_ops_c11_s3_stall;
  logic b_rcu_lane_ops_c11_wake;
  logic b_rcu_lane_ops_c12_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c12_s0_payload;
  logic b_rcu_lane_ops_c12_s0_credit;
  logic b_rcu_lane_ops_c12_s0_stall;
  logic b_rcu_lane_ops_c12_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c12_s1_payload;
  logic b_rcu_lane_ops_c12_s1_credit;
  logic b_rcu_lane_ops_c12_s1_stall;
  logic b_rcu_lane_ops_c12_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c12_s2_payload;
  logic b_rcu_lane_ops_c12_s2_credit;
  logic b_rcu_lane_ops_c12_s2_stall;
  logic b_rcu_lane_ops_c12_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c12_s3_payload;
  logic b_rcu_lane_ops_c12_s3_credit;
  logic b_rcu_lane_ops_c12_s3_stall;
  logic b_rcu_lane_ops_c12_wake;
  logic b_rcu_lane_ops_c13_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c13_s0_payload;
  logic b_rcu_lane_ops_c13_s0_credit;
  logic b_rcu_lane_ops_c13_s0_stall;
  logic b_rcu_lane_ops_c13_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c13_s1_payload;
  logic b_rcu_lane_ops_c13_s1_credit;
  logic b_rcu_lane_ops_c13_s1_stall;
  logic b_rcu_lane_ops_c13_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c13_s2_payload;
  logic b_rcu_lane_ops_c13_s2_credit;
  logic b_rcu_lane_ops_c13_s2_stall;
  logic b_rcu_lane_ops_c13_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c13_s3_payload;
  logic b_rcu_lane_ops_c13_s3_credit;
  logic b_rcu_lane_ops_c13_s3_stall;
  logic b_rcu_lane_ops_c13_wake;
  logic b_rcu_lane_ops_c14_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c14_s0_payload;
  logic b_rcu_lane_ops_c14_s0_credit;
  logic b_rcu_lane_ops_c14_s0_stall;
  logic b_rcu_lane_ops_c14_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c14_s1_payload;
  logic b_rcu_lane_ops_c14_s1_credit;
  logic b_rcu_lane_ops_c14_s1_stall;
  logic b_rcu_lane_ops_c14_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c14_s2_payload;
  logic b_rcu_lane_ops_c14_s2_credit;
  logic b_rcu_lane_ops_c14_s2_stall;
  logic b_rcu_lane_ops_c14_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c14_s3_payload;
  logic b_rcu_lane_ops_c14_s3_credit;
  logic b_rcu_lane_ops_c14_s3_stall;
  logic b_rcu_lane_ops_c14_wake;
  logic b_rcu_lane_ops_c15_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c15_s0_payload;
  logic b_rcu_lane_ops_c15_s0_credit;
  logic b_rcu_lane_ops_c15_s0_stall;
  logic b_rcu_lane_ops_c15_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c15_s1_payload;
  logic b_rcu_lane_ops_c15_s1_credit;
  logic b_rcu_lane_ops_c15_s1_stall;
  logic b_rcu_lane_ops_c15_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c15_s2_payload;
  logic b_rcu_lane_ops_c15_s2_credit;
  logic b_rcu_lane_ops_c15_s2_stall;
  logic b_rcu_lane_ops_c15_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c15_s3_payload;
  logic b_rcu_lane_ops_c15_s3_credit;
  logic b_rcu_lane_ops_c15_s3_stall;
  logic b_rcu_lane_ops_c15_wake;
  logic b_rcu_lane_ops_c16_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c16_s0_payload;
  logic b_rcu_lane_ops_c16_s0_credit;
  logic b_rcu_lane_ops_c16_s0_stall;
  logic b_rcu_lane_ops_c16_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c16_s1_payload;
  logic b_rcu_lane_ops_c16_s1_credit;
  logic b_rcu_lane_ops_c16_s1_stall;
  logic b_rcu_lane_ops_c16_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c16_s2_payload;
  logic b_rcu_lane_ops_c16_s2_credit;
  logic b_rcu_lane_ops_c16_s2_stall;
  logic b_rcu_lane_ops_c16_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c16_s3_payload;
  logic b_rcu_lane_ops_c16_s3_credit;
  logic b_rcu_lane_ops_c16_s3_stall;
  logic b_rcu_lane_ops_c16_wake;
  logic b_rcu_lane_ops_c17_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c17_s0_payload;
  logic b_rcu_lane_ops_c17_s0_credit;
  logic b_rcu_lane_ops_c17_s0_stall;
  logic b_rcu_lane_ops_c17_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c17_s1_payload;
  logic b_rcu_lane_ops_c17_s1_credit;
  logic b_rcu_lane_ops_c17_s1_stall;
  logic b_rcu_lane_ops_c17_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c17_s2_payload;
  logic b_rcu_lane_ops_c17_s2_credit;
  logic b_rcu_lane_ops_c17_s2_stall;
  logic b_rcu_lane_ops_c17_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c17_s3_payload;
  logic b_rcu_lane_ops_c17_s3_credit;
  logic b_rcu_lane_ops_c17_s3_stall;
  logic b_rcu_lane_ops_c17_wake;
  logic b_rcu_lane_ops_c18_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c18_s0_payload;
  logic b_rcu_lane_ops_c18_s0_credit;
  logic b_rcu_lane_ops_c18_s0_stall;
  logic b_rcu_lane_ops_c18_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c18_s1_payload;
  logic b_rcu_lane_ops_c18_s1_credit;
  logic b_rcu_lane_ops_c18_s1_stall;
  logic b_rcu_lane_ops_c18_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c18_s2_payload;
  logic b_rcu_lane_ops_c18_s2_credit;
  logic b_rcu_lane_ops_c18_s2_stall;
  logic b_rcu_lane_ops_c18_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c18_s3_payload;
  logic b_rcu_lane_ops_c18_s3_credit;
  logic b_rcu_lane_ops_c18_s3_stall;
  logic b_rcu_lane_ops_c18_wake;
  logic b_rcu_lane_ops_c19_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c19_s0_payload;
  logic b_rcu_lane_ops_c19_s0_credit;
  logic b_rcu_lane_ops_c19_s0_stall;
  logic b_rcu_lane_ops_c19_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c19_s1_payload;
  logic b_rcu_lane_ops_c19_s1_credit;
  logic b_rcu_lane_ops_c19_s1_stall;
  logic b_rcu_lane_ops_c19_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c19_s2_payload;
  logic b_rcu_lane_ops_c19_s2_credit;
  logic b_rcu_lane_ops_c19_s2_stall;
  logic b_rcu_lane_ops_c19_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c19_s3_payload;
  logic b_rcu_lane_ops_c19_s3_credit;
  logic b_rcu_lane_ops_c19_s3_stall;
  logic b_rcu_lane_ops_c19_wake;
  logic b_rcu_lane_ops_c20_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c20_s0_payload;
  logic b_rcu_lane_ops_c20_s0_credit;
  logic b_rcu_lane_ops_c20_s0_stall;
  logic b_rcu_lane_ops_c20_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c20_s1_payload;
  logic b_rcu_lane_ops_c20_s1_credit;
  logic b_rcu_lane_ops_c20_s1_stall;
  logic b_rcu_lane_ops_c20_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c20_s2_payload;
  logic b_rcu_lane_ops_c20_s2_credit;
  logic b_rcu_lane_ops_c20_s2_stall;
  logic b_rcu_lane_ops_c20_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c20_s3_payload;
  logic b_rcu_lane_ops_c20_s3_credit;
  logic b_rcu_lane_ops_c20_s3_stall;
  logic b_rcu_lane_ops_c20_wake;
  logic b_rcu_lane_ops_c21_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c21_s0_payload;
  logic b_rcu_lane_ops_c21_s0_credit;
  logic b_rcu_lane_ops_c21_s0_stall;
  logic b_rcu_lane_ops_c21_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c21_s1_payload;
  logic b_rcu_lane_ops_c21_s1_credit;
  logic b_rcu_lane_ops_c21_s1_stall;
  logic b_rcu_lane_ops_c21_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c21_s2_payload;
  logic b_rcu_lane_ops_c21_s2_credit;
  logic b_rcu_lane_ops_c21_s2_stall;
  logic b_rcu_lane_ops_c21_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c21_s3_payload;
  logic b_rcu_lane_ops_c21_s3_credit;
  logic b_rcu_lane_ops_c21_s3_stall;
  logic b_rcu_lane_ops_c21_wake;
  logic b_rcu_lane_ops_c22_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c22_s0_payload;
  logic b_rcu_lane_ops_c22_s0_credit;
  logic b_rcu_lane_ops_c22_s0_stall;
  logic b_rcu_lane_ops_c22_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c22_s1_payload;
  logic b_rcu_lane_ops_c22_s1_credit;
  logic b_rcu_lane_ops_c22_s1_stall;
  logic b_rcu_lane_ops_c22_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c22_s2_payload;
  logic b_rcu_lane_ops_c22_s2_credit;
  logic b_rcu_lane_ops_c22_s2_stall;
  logic b_rcu_lane_ops_c22_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c22_s3_payload;
  logic b_rcu_lane_ops_c22_s3_credit;
  logic b_rcu_lane_ops_c22_s3_stall;
  logic b_rcu_lane_ops_c22_wake;
  logic b_rcu_lane_ops_c23_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c23_s0_payload;
  logic b_rcu_lane_ops_c23_s0_credit;
  logic b_rcu_lane_ops_c23_s0_stall;
  logic b_rcu_lane_ops_c23_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c23_s1_payload;
  logic b_rcu_lane_ops_c23_s1_credit;
  logic b_rcu_lane_ops_c23_s1_stall;
  logic b_rcu_lane_ops_c23_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c23_s2_payload;
  logic b_rcu_lane_ops_c23_s2_credit;
  logic b_rcu_lane_ops_c23_s2_stall;
  logic b_rcu_lane_ops_c23_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c23_s3_payload;
  logic b_rcu_lane_ops_c23_s3_credit;
  logic b_rcu_lane_ops_c23_s3_stall;
  logic b_rcu_lane_ops_c23_wake;
  logic b_rcu_lane_ops_c24_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c24_s0_payload;
  logic b_rcu_lane_ops_c24_s0_credit;
  logic b_rcu_lane_ops_c24_s0_stall;
  logic b_rcu_lane_ops_c24_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c24_s1_payload;
  logic b_rcu_lane_ops_c24_s1_credit;
  logic b_rcu_lane_ops_c24_s1_stall;
  logic b_rcu_lane_ops_c24_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c24_s2_payload;
  logic b_rcu_lane_ops_c24_s2_credit;
  logic b_rcu_lane_ops_c24_s2_stall;
  logic b_rcu_lane_ops_c24_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c24_s3_payload;
  logic b_rcu_lane_ops_c24_s3_credit;
  logic b_rcu_lane_ops_c24_s3_stall;
  logic b_rcu_lane_ops_c24_wake;
  logic b_rcu_lane_ops_c25_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c25_s0_payload;
  logic b_rcu_lane_ops_c25_s0_credit;
  logic b_rcu_lane_ops_c25_s0_stall;
  logic b_rcu_lane_ops_c25_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c25_s1_payload;
  logic b_rcu_lane_ops_c25_s1_credit;
  logic b_rcu_lane_ops_c25_s1_stall;
  logic b_rcu_lane_ops_c25_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c25_s2_payload;
  logic b_rcu_lane_ops_c25_s2_credit;
  logic b_rcu_lane_ops_c25_s2_stall;
  logic b_rcu_lane_ops_c25_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c25_s3_payload;
  logic b_rcu_lane_ops_c25_s3_credit;
  logic b_rcu_lane_ops_c25_s3_stall;
  logic b_rcu_lane_ops_c25_wake;
  logic b_rcu_lane_ops_c26_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c26_s0_payload;
  logic b_rcu_lane_ops_c26_s0_credit;
  logic b_rcu_lane_ops_c26_s0_stall;
  logic b_rcu_lane_ops_c26_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c26_s1_payload;
  logic b_rcu_lane_ops_c26_s1_credit;
  logic b_rcu_lane_ops_c26_s1_stall;
  logic b_rcu_lane_ops_c26_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c26_s2_payload;
  logic b_rcu_lane_ops_c26_s2_credit;
  logic b_rcu_lane_ops_c26_s2_stall;
  logic b_rcu_lane_ops_c26_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c26_s3_payload;
  logic b_rcu_lane_ops_c26_s3_credit;
  logic b_rcu_lane_ops_c26_s3_stall;
  logic b_rcu_lane_ops_c26_wake;
  logic b_rcu_lane_ops_c27_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c27_s0_payload;
  logic b_rcu_lane_ops_c27_s0_credit;
  logic b_rcu_lane_ops_c27_s0_stall;
  logic b_rcu_lane_ops_c27_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c27_s1_payload;
  logic b_rcu_lane_ops_c27_s1_credit;
  logic b_rcu_lane_ops_c27_s1_stall;
  logic b_rcu_lane_ops_c27_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c27_s2_payload;
  logic b_rcu_lane_ops_c27_s2_credit;
  logic b_rcu_lane_ops_c27_s2_stall;
  logic b_rcu_lane_ops_c27_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c27_s3_payload;
  logic b_rcu_lane_ops_c27_s3_credit;
  logic b_rcu_lane_ops_c27_s3_stall;
  logic b_rcu_lane_ops_c27_wake;
  logic b_rcu_lane_ops_c28_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c28_s0_payload;
  logic b_rcu_lane_ops_c28_s0_credit;
  logic b_rcu_lane_ops_c28_s0_stall;
  logic b_rcu_lane_ops_c28_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c28_s1_payload;
  logic b_rcu_lane_ops_c28_s1_credit;
  logic b_rcu_lane_ops_c28_s1_stall;
  logic b_rcu_lane_ops_c28_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c28_s2_payload;
  logic b_rcu_lane_ops_c28_s2_credit;
  logic b_rcu_lane_ops_c28_s2_stall;
  logic b_rcu_lane_ops_c28_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c28_s3_payload;
  logic b_rcu_lane_ops_c28_s3_credit;
  logic b_rcu_lane_ops_c28_s3_stall;
  logic b_rcu_lane_ops_c28_wake;
  logic b_rcu_lane_ops_c29_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c29_s0_payload;
  logic b_rcu_lane_ops_c29_s0_credit;
  logic b_rcu_lane_ops_c29_s0_stall;
  logic b_rcu_lane_ops_c29_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c29_s1_payload;
  logic b_rcu_lane_ops_c29_s1_credit;
  logic b_rcu_lane_ops_c29_s1_stall;
  logic b_rcu_lane_ops_c29_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c29_s2_payload;
  logic b_rcu_lane_ops_c29_s2_credit;
  logic b_rcu_lane_ops_c29_s2_stall;
  logic b_rcu_lane_ops_c29_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c29_s3_payload;
  logic b_rcu_lane_ops_c29_s3_credit;
  logic b_rcu_lane_ops_c29_s3_stall;
  logic b_rcu_lane_ops_c29_wake;
  logic b_rcu_lane_ops_c30_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c30_s0_payload;
  logic b_rcu_lane_ops_c30_s0_credit;
  logic b_rcu_lane_ops_c30_s0_stall;
  logic b_rcu_lane_ops_c30_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c30_s1_payload;
  logic b_rcu_lane_ops_c30_s1_credit;
  logic b_rcu_lane_ops_c30_s1_stall;
  logic b_rcu_lane_ops_c30_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c30_s2_payload;
  logic b_rcu_lane_ops_c30_s2_credit;
  logic b_rcu_lane_ops_c30_s2_stall;
  logic b_rcu_lane_ops_c30_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c30_s3_payload;
  logic b_rcu_lane_ops_c30_s3_credit;
  logic b_rcu_lane_ops_c30_s3_stall;
  logic b_rcu_lane_ops_c30_wake;
  logic b_rcu_lane_ops_c31_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c31_s0_payload;
  logic b_rcu_lane_ops_c31_s0_credit;
  logic b_rcu_lane_ops_c31_s0_stall;
  logic b_rcu_lane_ops_c31_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c31_s1_payload;
  logic b_rcu_lane_ops_c31_s1_credit;
  logic b_rcu_lane_ops_c31_s1_stall;
  logic b_rcu_lane_ops_c31_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c31_s2_payload;
  logic b_rcu_lane_ops_c31_s2_credit;
  logic b_rcu_lane_ops_c31_s2_stall;
  logic b_rcu_lane_ops_c31_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_c31_s3_payload;
  logic b_rcu_lane_ops_c31_s3_credit;
  logic b_rcu_lane_ops_c31_s3_stall;
  logic b_rcu_lane_ops_c31_wake;
  logic b_lane_rcu_res_c00_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c00_s0_payload;
  logic b_lane_rcu_res_c00_s0_credit;
  logic b_lane_rcu_res_c00_s0_stall;
  logic b_lane_rcu_res_c00_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c00_s1_payload;
  logic b_lane_rcu_res_c00_s1_credit;
  logic b_lane_rcu_res_c00_s1_stall;
  logic b_lane_rcu_res_c00_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c00_s2_payload;
  logic b_lane_rcu_res_c00_s2_credit;
  logic b_lane_rcu_res_c00_s2_stall;
  logic b_lane_rcu_res_c00_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c00_s3_payload;
  logic b_lane_rcu_res_c00_s3_credit;
  logic b_lane_rcu_res_c00_s3_stall;
  logic b_lane_rcu_res_c00_wake;
  logic b_lane_rcu_res_c01_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c01_s0_payload;
  logic b_lane_rcu_res_c01_s0_credit;
  logic b_lane_rcu_res_c01_s0_stall;
  logic b_lane_rcu_res_c01_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c01_s1_payload;
  logic b_lane_rcu_res_c01_s1_credit;
  logic b_lane_rcu_res_c01_s1_stall;
  logic b_lane_rcu_res_c01_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c01_s2_payload;
  logic b_lane_rcu_res_c01_s2_credit;
  logic b_lane_rcu_res_c01_s2_stall;
  logic b_lane_rcu_res_c01_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c01_s3_payload;
  logic b_lane_rcu_res_c01_s3_credit;
  logic b_lane_rcu_res_c01_s3_stall;
  logic b_lane_rcu_res_c01_wake;
  logic b_lane_rcu_res_c02_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c02_s0_payload;
  logic b_lane_rcu_res_c02_s0_credit;
  logic b_lane_rcu_res_c02_s0_stall;
  logic b_lane_rcu_res_c02_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c02_s1_payload;
  logic b_lane_rcu_res_c02_s1_credit;
  logic b_lane_rcu_res_c02_s1_stall;
  logic b_lane_rcu_res_c02_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c02_s2_payload;
  logic b_lane_rcu_res_c02_s2_credit;
  logic b_lane_rcu_res_c02_s2_stall;
  logic b_lane_rcu_res_c02_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c02_s3_payload;
  logic b_lane_rcu_res_c02_s3_credit;
  logic b_lane_rcu_res_c02_s3_stall;
  logic b_lane_rcu_res_c02_wake;
  logic b_lane_rcu_res_c03_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c03_s0_payload;
  logic b_lane_rcu_res_c03_s0_credit;
  logic b_lane_rcu_res_c03_s0_stall;
  logic b_lane_rcu_res_c03_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c03_s1_payload;
  logic b_lane_rcu_res_c03_s1_credit;
  logic b_lane_rcu_res_c03_s1_stall;
  logic b_lane_rcu_res_c03_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c03_s2_payload;
  logic b_lane_rcu_res_c03_s2_credit;
  logic b_lane_rcu_res_c03_s2_stall;
  logic b_lane_rcu_res_c03_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c03_s3_payload;
  logic b_lane_rcu_res_c03_s3_credit;
  logic b_lane_rcu_res_c03_s3_stall;
  logic b_lane_rcu_res_c03_wake;
  logic b_lane_rcu_res_c04_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c04_s0_payload;
  logic b_lane_rcu_res_c04_s0_credit;
  logic b_lane_rcu_res_c04_s0_stall;
  logic b_lane_rcu_res_c04_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c04_s1_payload;
  logic b_lane_rcu_res_c04_s1_credit;
  logic b_lane_rcu_res_c04_s1_stall;
  logic b_lane_rcu_res_c04_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c04_s2_payload;
  logic b_lane_rcu_res_c04_s2_credit;
  logic b_lane_rcu_res_c04_s2_stall;
  logic b_lane_rcu_res_c04_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c04_s3_payload;
  logic b_lane_rcu_res_c04_s3_credit;
  logic b_lane_rcu_res_c04_s3_stall;
  logic b_lane_rcu_res_c04_wake;
  logic b_lane_rcu_res_c05_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c05_s0_payload;
  logic b_lane_rcu_res_c05_s0_credit;
  logic b_lane_rcu_res_c05_s0_stall;
  logic b_lane_rcu_res_c05_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c05_s1_payload;
  logic b_lane_rcu_res_c05_s1_credit;
  logic b_lane_rcu_res_c05_s1_stall;
  logic b_lane_rcu_res_c05_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c05_s2_payload;
  logic b_lane_rcu_res_c05_s2_credit;
  logic b_lane_rcu_res_c05_s2_stall;
  logic b_lane_rcu_res_c05_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c05_s3_payload;
  logic b_lane_rcu_res_c05_s3_credit;
  logic b_lane_rcu_res_c05_s3_stall;
  logic b_lane_rcu_res_c05_wake;
  logic b_lane_rcu_res_c06_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c06_s0_payload;
  logic b_lane_rcu_res_c06_s0_credit;
  logic b_lane_rcu_res_c06_s0_stall;
  logic b_lane_rcu_res_c06_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c06_s1_payload;
  logic b_lane_rcu_res_c06_s1_credit;
  logic b_lane_rcu_res_c06_s1_stall;
  logic b_lane_rcu_res_c06_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c06_s2_payload;
  logic b_lane_rcu_res_c06_s2_credit;
  logic b_lane_rcu_res_c06_s2_stall;
  logic b_lane_rcu_res_c06_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c06_s3_payload;
  logic b_lane_rcu_res_c06_s3_credit;
  logic b_lane_rcu_res_c06_s3_stall;
  logic b_lane_rcu_res_c06_wake;
  logic b_lane_rcu_res_c07_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c07_s0_payload;
  logic b_lane_rcu_res_c07_s0_credit;
  logic b_lane_rcu_res_c07_s0_stall;
  logic b_lane_rcu_res_c07_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c07_s1_payload;
  logic b_lane_rcu_res_c07_s1_credit;
  logic b_lane_rcu_res_c07_s1_stall;
  logic b_lane_rcu_res_c07_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c07_s2_payload;
  logic b_lane_rcu_res_c07_s2_credit;
  logic b_lane_rcu_res_c07_s2_stall;
  logic b_lane_rcu_res_c07_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c07_s3_payload;
  logic b_lane_rcu_res_c07_s3_credit;
  logic b_lane_rcu_res_c07_s3_stall;
  logic b_lane_rcu_res_c07_wake;
  logic b_lane_rcu_res_c08_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c08_s0_payload;
  logic b_lane_rcu_res_c08_s0_credit;
  logic b_lane_rcu_res_c08_s0_stall;
  logic b_lane_rcu_res_c08_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c08_s1_payload;
  logic b_lane_rcu_res_c08_s1_credit;
  logic b_lane_rcu_res_c08_s1_stall;
  logic b_lane_rcu_res_c08_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c08_s2_payload;
  logic b_lane_rcu_res_c08_s2_credit;
  logic b_lane_rcu_res_c08_s2_stall;
  logic b_lane_rcu_res_c08_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c08_s3_payload;
  logic b_lane_rcu_res_c08_s3_credit;
  logic b_lane_rcu_res_c08_s3_stall;
  logic b_lane_rcu_res_c08_wake;
  logic b_lane_rcu_res_c09_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c09_s0_payload;
  logic b_lane_rcu_res_c09_s0_credit;
  logic b_lane_rcu_res_c09_s0_stall;
  logic b_lane_rcu_res_c09_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c09_s1_payload;
  logic b_lane_rcu_res_c09_s1_credit;
  logic b_lane_rcu_res_c09_s1_stall;
  logic b_lane_rcu_res_c09_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c09_s2_payload;
  logic b_lane_rcu_res_c09_s2_credit;
  logic b_lane_rcu_res_c09_s2_stall;
  logic b_lane_rcu_res_c09_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c09_s3_payload;
  logic b_lane_rcu_res_c09_s3_credit;
  logic b_lane_rcu_res_c09_s3_stall;
  logic b_lane_rcu_res_c09_wake;
  logic b_lane_rcu_res_c10_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c10_s0_payload;
  logic b_lane_rcu_res_c10_s0_credit;
  logic b_lane_rcu_res_c10_s0_stall;
  logic b_lane_rcu_res_c10_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c10_s1_payload;
  logic b_lane_rcu_res_c10_s1_credit;
  logic b_lane_rcu_res_c10_s1_stall;
  logic b_lane_rcu_res_c10_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c10_s2_payload;
  logic b_lane_rcu_res_c10_s2_credit;
  logic b_lane_rcu_res_c10_s2_stall;
  logic b_lane_rcu_res_c10_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c10_s3_payload;
  logic b_lane_rcu_res_c10_s3_credit;
  logic b_lane_rcu_res_c10_s3_stall;
  logic b_lane_rcu_res_c10_wake;
  logic b_lane_rcu_res_c11_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c11_s0_payload;
  logic b_lane_rcu_res_c11_s0_credit;
  logic b_lane_rcu_res_c11_s0_stall;
  logic b_lane_rcu_res_c11_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c11_s1_payload;
  logic b_lane_rcu_res_c11_s1_credit;
  logic b_lane_rcu_res_c11_s1_stall;
  logic b_lane_rcu_res_c11_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c11_s2_payload;
  logic b_lane_rcu_res_c11_s2_credit;
  logic b_lane_rcu_res_c11_s2_stall;
  logic b_lane_rcu_res_c11_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c11_s3_payload;
  logic b_lane_rcu_res_c11_s3_credit;
  logic b_lane_rcu_res_c11_s3_stall;
  logic b_lane_rcu_res_c11_wake;
  logic b_lane_rcu_res_c12_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c12_s0_payload;
  logic b_lane_rcu_res_c12_s0_credit;
  logic b_lane_rcu_res_c12_s0_stall;
  logic b_lane_rcu_res_c12_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c12_s1_payload;
  logic b_lane_rcu_res_c12_s1_credit;
  logic b_lane_rcu_res_c12_s1_stall;
  logic b_lane_rcu_res_c12_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c12_s2_payload;
  logic b_lane_rcu_res_c12_s2_credit;
  logic b_lane_rcu_res_c12_s2_stall;
  logic b_lane_rcu_res_c12_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c12_s3_payload;
  logic b_lane_rcu_res_c12_s3_credit;
  logic b_lane_rcu_res_c12_s3_stall;
  logic b_lane_rcu_res_c12_wake;
  logic b_lane_rcu_res_c13_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c13_s0_payload;
  logic b_lane_rcu_res_c13_s0_credit;
  logic b_lane_rcu_res_c13_s0_stall;
  logic b_lane_rcu_res_c13_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c13_s1_payload;
  logic b_lane_rcu_res_c13_s1_credit;
  logic b_lane_rcu_res_c13_s1_stall;
  logic b_lane_rcu_res_c13_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c13_s2_payload;
  logic b_lane_rcu_res_c13_s2_credit;
  logic b_lane_rcu_res_c13_s2_stall;
  logic b_lane_rcu_res_c13_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c13_s3_payload;
  logic b_lane_rcu_res_c13_s3_credit;
  logic b_lane_rcu_res_c13_s3_stall;
  logic b_lane_rcu_res_c13_wake;
  logic b_lane_rcu_res_c14_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c14_s0_payload;
  logic b_lane_rcu_res_c14_s0_credit;
  logic b_lane_rcu_res_c14_s0_stall;
  logic b_lane_rcu_res_c14_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c14_s1_payload;
  logic b_lane_rcu_res_c14_s1_credit;
  logic b_lane_rcu_res_c14_s1_stall;
  logic b_lane_rcu_res_c14_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c14_s2_payload;
  logic b_lane_rcu_res_c14_s2_credit;
  logic b_lane_rcu_res_c14_s2_stall;
  logic b_lane_rcu_res_c14_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c14_s3_payload;
  logic b_lane_rcu_res_c14_s3_credit;
  logic b_lane_rcu_res_c14_s3_stall;
  logic b_lane_rcu_res_c14_wake;
  logic b_lane_rcu_res_c15_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c15_s0_payload;
  logic b_lane_rcu_res_c15_s0_credit;
  logic b_lane_rcu_res_c15_s0_stall;
  logic b_lane_rcu_res_c15_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c15_s1_payload;
  logic b_lane_rcu_res_c15_s1_credit;
  logic b_lane_rcu_res_c15_s1_stall;
  logic b_lane_rcu_res_c15_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c15_s2_payload;
  logic b_lane_rcu_res_c15_s2_credit;
  logic b_lane_rcu_res_c15_s2_stall;
  logic b_lane_rcu_res_c15_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c15_s3_payload;
  logic b_lane_rcu_res_c15_s3_credit;
  logic b_lane_rcu_res_c15_s3_stall;
  logic b_lane_rcu_res_c15_wake;
  logic b_lane_rcu_res_c16_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c16_s0_payload;
  logic b_lane_rcu_res_c16_s0_credit;
  logic b_lane_rcu_res_c16_s0_stall;
  logic b_lane_rcu_res_c16_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c16_s1_payload;
  logic b_lane_rcu_res_c16_s1_credit;
  logic b_lane_rcu_res_c16_s1_stall;
  logic b_lane_rcu_res_c16_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c16_s2_payload;
  logic b_lane_rcu_res_c16_s2_credit;
  logic b_lane_rcu_res_c16_s2_stall;
  logic b_lane_rcu_res_c16_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c16_s3_payload;
  logic b_lane_rcu_res_c16_s3_credit;
  logic b_lane_rcu_res_c16_s3_stall;
  logic b_lane_rcu_res_c16_wake;
  logic b_lane_rcu_res_c17_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c17_s0_payload;
  logic b_lane_rcu_res_c17_s0_credit;
  logic b_lane_rcu_res_c17_s0_stall;
  logic b_lane_rcu_res_c17_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c17_s1_payload;
  logic b_lane_rcu_res_c17_s1_credit;
  logic b_lane_rcu_res_c17_s1_stall;
  logic b_lane_rcu_res_c17_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c17_s2_payload;
  logic b_lane_rcu_res_c17_s2_credit;
  logic b_lane_rcu_res_c17_s2_stall;
  logic b_lane_rcu_res_c17_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c17_s3_payload;
  logic b_lane_rcu_res_c17_s3_credit;
  logic b_lane_rcu_res_c17_s3_stall;
  logic b_lane_rcu_res_c17_wake;
  logic b_lane_rcu_res_c18_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c18_s0_payload;
  logic b_lane_rcu_res_c18_s0_credit;
  logic b_lane_rcu_res_c18_s0_stall;
  logic b_lane_rcu_res_c18_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c18_s1_payload;
  logic b_lane_rcu_res_c18_s1_credit;
  logic b_lane_rcu_res_c18_s1_stall;
  logic b_lane_rcu_res_c18_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c18_s2_payload;
  logic b_lane_rcu_res_c18_s2_credit;
  logic b_lane_rcu_res_c18_s2_stall;
  logic b_lane_rcu_res_c18_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c18_s3_payload;
  logic b_lane_rcu_res_c18_s3_credit;
  logic b_lane_rcu_res_c18_s3_stall;
  logic b_lane_rcu_res_c18_wake;
  logic b_lane_rcu_res_c19_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c19_s0_payload;
  logic b_lane_rcu_res_c19_s0_credit;
  logic b_lane_rcu_res_c19_s0_stall;
  logic b_lane_rcu_res_c19_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c19_s1_payload;
  logic b_lane_rcu_res_c19_s1_credit;
  logic b_lane_rcu_res_c19_s1_stall;
  logic b_lane_rcu_res_c19_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c19_s2_payload;
  logic b_lane_rcu_res_c19_s2_credit;
  logic b_lane_rcu_res_c19_s2_stall;
  logic b_lane_rcu_res_c19_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c19_s3_payload;
  logic b_lane_rcu_res_c19_s3_credit;
  logic b_lane_rcu_res_c19_s3_stall;
  logic b_lane_rcu_res_c19_wake;
  logic b_lane_rcu_res_c20_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c20_s0_payload;
  logic b_lane_rcu_res_c20_s0_credit;
  logic b_lane_rcu_res_c20_s0_stall;
  logic b_lane_rcu_res_c20_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c20_s1_payload;
  logic b_lane_rcu_res_c20_s1_credit;
  logic b_lane_rcu_res_c20_s1_stall;
  logic b_lane_rcu_res_c20_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c20_s2_payload;
  logic b_lane_rcu_res_c20_s2_credit;
  logic b_lane_rcu_res_c20_s2_stall;
  logic b_lane_rcu_res_c20_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c20_s3_payload;
  logic b_lane_rcu_res_c20_s3_credit;
  logic b_lane_rcu_res_c20_s3_stall;
  logic b_lane_rcu_res_c20_wake;
  logic b_lane_rcu_res_c21_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c21_s0_payload;
  logic b_lane_rcu_res_c21_s0_credit;
  logic b_lane_rcu_res_c21_s0_stall;
  logic b_lane_rcu_res_c21_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c21_s1_payload;
  logic b_lane_rcu_res_c21_s1_credit;
  logic b_lane_rcu_res_c21_s1_stall;
  logic b_lane_rcu_res_c21_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c21_s2_payload;
  logic b_lane_rcu_res_c21_s2_credit;
  logic b_lane_rcu_res_c21_s2_stall;
  logic b_lane_rcu_res_c21_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c21_s3_payload;
  logic b_lane_rcu_res_c21_s3_credit;
  logic b_lane_rcu_res_c21_s3_stall;
  logic b_lane_rcu_res_c21_wake;
  logic b_lane_rcu_res_c22_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c22_s0_payload;
  logic b_lane_rcu_res_c22_s0_credit;
  logic b_lane_rcu_res_c22_s0_stall;
  logic b_lane_rcu_res_c22_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c22_s1_payload;
  logic b_lane_rcu_res_c22_s1_credit;
  logic b_lane_rcu_res_c22_s1_stall;
  logic b_lane_rcu_res_c22_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c22_s2_payload;
  logic b_lane_rcu_res_c22_s2_credit;
  logic b_lane_rcu_res_c22_s2_stall;
  logic b_lane_rcu_res_c22_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c22_s3_payload;
  logic b_lane_rcu_res_c22_s3_credit;
  logic b_lane_rcu_res_c22_s3_stall;
  logic b_lane_rcu_res_c22_wake;
  logic b_lane_rcu_res_c23_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c23_s0_payload;
  logic b_lane_rcu_res_c23_s0_credit;
  logic b_lane_rcu_res_c23_s0_stall;
  logic b_lane_rcu_res_c23_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c23_s1_payload;
  logic b_lane_rcu_res_c23_s1_credit;
  logic b_lane_rcu_res_c23_s1_stall;
  logic b_lane_rcu_res_c23_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c23_s2_payload;
  logic b_lane_rcu_res_c23_s2_credit;
  logic b_lane_rcu_res_c23_s2_stall;
  logic b_lane_rcu_res_c23_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c23_s3_payload;
  logic b_lane_rcu_res_c23_s3_credit;
  logic b_lane_rcu_res_c23_s3_stall;
  logic b_lane_rcu_res_c23_wake;
  logic b_lane_rcu_res_c24_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c24_s0_payload;
  logic b_lane_rcu_res_c24_s0_credit;
  logic b_lane_rcu_res_c24_s0_stall;
  logic b_lane_rcu_res_c24_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c24_s1_payload;
  logic b_lane_rcu_res_c24_s1_credit;
  logic b_lane_rcu_res_c24_s1_stall;
  logic b_lane_rcu_res_c24_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c24_s2_payload;
  logic b_lane_rcu_res_c24_s2_credit;
  logic b_lane_rcu_res_c24_s2_stall;
  logic b_lane_rcu_res_c24_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c24_s3_payload;
  logic b_lane_rcu_res_c24_s3_credit;
  logic b_lane_rcu_res_c24_s3_stall;
  logic b_lane_rcu_res_c24_wake;
  logic b_lane_rcu_res_c25_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c25_s0_payload;
  logic b_lane_rcu_res_c25_s0_credit;
  logic b_lane_rcu_res_c25_s0_stall;
  logic b_lane_rcu_res_c25_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c25_s1_payload;
  logic b_lane_rcu_res_c25_s1_credit;
  logic b_lane_rcu_res_c25_s1_stall;
  logic b_lane_rcu_res_c25_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c25_s2_payload;
  logic b_lane_rcu_res_c25_s2_credit;
  logic b_lane_rcu_res_c25_s2_stall;
  logic b_lane_rcu_res_c25_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c25_s3_payload;
  logic b_lane_rcu_res_c25_s3_credit;
  logic b_lane_rcu_res_c25_s3_stall;
  logic b_lane_rcu_res_c25_wake;
  logic b_lane_rcu_res_c26_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c26_s0_payload;
  logic b_lane_rcu_res_c26_s0_credit;
  logic b_lane_rcu_res_c26_s0_stall;
  logic b_lane_rcu_res_c26_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c26_s1_payload;
  logic b_lane_rcu_res_c26_s1_credit;
  logic b_lane_rcu_res_c26_s1_stall;
  logic b_lane_rcu_res_c26_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c26_s2_payload;
  logic b_lane_rcu_res_c26_s2_credit;
  logic b_lane_rcu_res_c26_s2_stall;
  logic b_lane_rcu_res_c26_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c26_s3_payload;
  logic b_lane_rcu_res_c26_s3_credit;
  logic b_lane_rcu_res_c26_s3_stall;
  logic b_lane_rcu_res_c26_wake;
  logic b_lane_rcu_res_c27_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c27_s0_payload;
  logic b_lane_rcu_res_c27_s0_credit;
  logic b_lane_rcu_res_c27_s0_stall;
  logic b_lane_rcu_res_c27_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c27_s1_payload;
  logic b_lane_rcu_res_c27_s1_credit;
  logic b_lane_rcu_res_c27_s1_stall;
  logic b_lane_rcu_res_c27_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c27_s2_payload;
  logic b_lane_rcu_res_c27_s2_credit;
  logic b_lane_rcu_res_c27_s2_stall;
  logic b_lane_rcu_res_c27_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c27_s3_payload;
  logic b_lane_rcu_res_c27_s3_credit;
  logic b_lane_rcu_res_c27_s3_stall;
  logic b_lane_rcu_res_c27_wake;
  logic b_lane_rcu_res_c28_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c28_s0_payload;
  logic b_lane_rcu_res_c28_s0_credit;
  logic b_lane_rcu_res_c28_s0_stall;
  logic b_lane_rcu_res_c28_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c28_s1_payload;
  logic b_lane_rcu_res_c28_s1_credit;
  logic b_lane_rcu_res_c28_s1_stall;
  logic b_lane_rcu_res_c28_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c28_s2_payload;
  logic b_lane_rcu_res_c28_s2_credit;
  logic b_lane_rcu_res_c28_s2_stall;
  logic b_lane_rcu_res_c28_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c28_s3_payload;
  logic b_lane_rcu_res_c28_s3_credit;
  logic b_lane_rcu_res_c28_s3_stall;
  logic b_lane_rcu_res_c28_wake;
  logic b_lane_rcu_res_c29_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c29_s0_payload;
  logic b_lane_rcu_res_c29_s0_credit;
  logic b_lane_rcu_res_c29_s0_stall;
  logic b_lane_rcu_res_c29_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c29_s1_payload;
  logic b_lane_rcu_res_c29_s1_credit;
  logic b_lane_rcu_res_c29_s1_stall;
  logic b_lane_rcu_res_c29_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c29_s2_payload;
  logic b_lane_rcu_res_c29_s2_credit;
  logic b_lane_rcu_res_c29_s2_stall;
  logic b_lane_rcu_res_c29_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c29_s3_payload;
  logic b_lane_rcu_res_c29_s3_credit;
  logic b_lane_rcu_res_c29_s3_stall;
  logic b_lane_rcu_res_c29_wake;
  logic b_lane_rcu_res_c30_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c30_s0_payload;
  logic b_lane_rcu_res_c30_s0_credit;
  logic b_lane_rcu_res_c30_s0_stall;
  logic b_lane_rcu_res_c30_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c30_s1_payload;
  logic b_lane_rcu_res_c30_s1_credit;
  logic b_lane_rcu_res_c30_s1_stall;
  logic b_lane_rcu_res_c30_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c30_s2_payload;
  logic b_lane_rcu_res_c30_s2_credit;
  logic b_lane_rcu_res_c30_s2_stall;
  logic b_lane_rcu_res_c30_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c30_s3_payload;
  logic b_lane_rcu_res_c30_s3_credit;
  logic b_lane_rcu_res_c30_s3_stall;
  logic b_lane_rcu_res_c30_wake;
  logic b_lane_rcu_res_c31_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c31_s0_payload;
  logic b_lane_rcu_res_c31_s0_credit;
  logic b_lane_rcu_res_c31_s0_stall;
  logic b_lane_rcu_res_c31_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c31_s1_payload;
  logic b_lane_rcu_res_c31_s1_credit;
  logic b_lane_rcu_res_c31_s1_stall;
  logic b_lane_rcu_res_c31_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c31_s2_payload;
  logic b_lane_rcu_res_c31_s2_credit;
  logic b_lane_rcu_res_c31_s2_stall;
  logic b_lane_rcu_res_c31_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_c31_s3_payload;
  logic b_lane_rcu_res_c31_s3_credit;
  logic b_lane_rcu_res_c31_s3_stall;
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
  logic [63:0] b_rcu_lane_ops_c00_s0_tid;
  logic [63:0] b_rcu_lane_ops_c00_s1_tid;
  logic [63:0] b_rcu_lane_ops_c00_s2_tid;
  logic [63:0] b_rcu_lane_ops_c00_s3_tid;
  logic [63:0] b_rcu_lane_ops_c01_s0_tid;
  logic [63:0] b_rcu_lane_ops_c01_s1_tid;
  logic [63:0] b_rcu_lane_ops_c01_s2_tid;
  logic [63:0] b_rcu_lane_ops_c01_s3_tid;
  logic [63:0] b_rcu_lane_ops_c02_s0_tid;
  logic [63:0] b_rcu_lane_ops_c02_s1_tid;
  logic [63:0] b_rcu_lane_ops_c02_s2_tid;
  logic [63:0] b_rcu_lane_ops_c02_s3_tid;
  logic [63:0] b_rcu_lane_ops_c03_s0_tid;
  logic [63:0] b_rcu_lane_ops_c03_s1_tid;
  logic [63:0] b_rcu_lane_ops_c03_s2_tid;
  logic [63:0] b_rcu_lane_ops_c03_s3_tid;
  logic [63:0] b_rcu_lane_ops_c04_s0_tid;
  logic [63:0] b_rcu_lane_ops_c04_s1_tid;
  logic [63:0] b_rcu_lane_ops_c04_s2_tid;
  logic [63:0] b_rcu_lane_ops_c04_s3_tid;
  logic [63:0] b_rcu_lane_ops_c05_s0_tid;
  logic [63:0] b_rcu_lane_ops_c05_s1_tid;
  logic [63:0] b_rcu_lane_ops_c05_s2_tid;
  logic [63:0] b_rcu_lane_ops_c05_s3_tid;
  logic [63:0] b_rcu_lane_ops_c06_s0_tid;
  logic [63:0] b_rcu_lane_ops_c06_s1_tid;
  logic [63:0] b_rcu_lane_ops_c06_s2_tid;
  logic [63:0] b_rcu_lane_ops_c06_s3_tid;
  logic [63:0] b_rcu_lane_ops_c07_s0_tid;
  logic [63:0] b_rcu_lane_ops_c07_s1_tid;
  logic [63:0] b_rcu_lane_ops_c07_s2_tid;
  logic [63:0] b_rcu_lane_ops_c07_s3_tid;
  logic [63:0] b_rcu_lane_ops_c08_s0_tid;
  logic [63:0] b_rcu_lane_ops_c08_s1_tid;
  logic [63:0] b_rcu_lane_ops_c08_s2_tid;
  logic [63:0] b_rcu_lane_ops_c08_s3_tid;
  logic [63:0] b_rcu_lane_ops_c09_s0_tid;
  logic [63:0] b_rcu_lane_ops_c09_s1_tid;
  logic [63:0] b_rcu_lane_ops_c09_s2_tid;
  logic [63:0] b_rcu_lane_ops_c09_s3_tid;
  logic [63:0] b_rcu_lane_ops_c10_s0_tid;
  logic [63:0] b_rcu_lane_ops_c10_s1_tid;
  logic [63:0] b_rcu_lane_ops_c10_s2_tid;
  logic [63:0] b_rcu_lane_ops_c10_s3_tid;
  logic [63:0] b_rcu_lane_ops_c11_s0_tid;
  logic [63:0] b_rcu_lane_ops_c11_s1_tid;
  logic [63:0] b_rcu_lane_ops_c11_s2_tid;
  logic [63:0] b_rcu_lane_ops_c11_s3_tid;
  logic [63:0] b_rcu_lane_ops_c12_s0_tid;
  logic [63:0] b_rcu_lane_ops_c12_s1_tid;
  logic [63:0] b_rcu_lane_ops_c12_s2_tid;
  logic [63:0] b_rcu_lane_ops_c12_s3_tid;
  logic [63:0] b_rcu_lane_ops_c13_s0_tid;
  logic [63:0] b_rcu_lane_ops_c13_s1_tid;
  logic [63:0] b_rcu_lane_ops_c13_s2_tid;
  logic [63:0] b_rcu_lane_ops_c13_s3_tid;
  logic [63:0] b_rcu_lane_ops_c14_s0_tid;
  logic [63:0] b_rcu_lane_ops_c14_s1_tid;
  logic [63:0] b_rcu_lane_ops_c14_s2_tid;
  logic [63:0] b_rcu_lane_ops_c14_s3_tid;
  logic [63:0] b_rcu_lane_ops_c15_s0_tid;
  logic [63:0] b_rcu_lane_ops_c15_s1_tid;
  logic [63:0] b_rcu_lane_ops_c15_s2_tid;
  logic [63:0] b_rcu_lane_ops_c15_s3_tid;
  logic [63:0] b_rcu_lane_ops_c16_s0_tid;
  logic [63:0] b_rcu_lane_ops_c16_s1_tid;
  logic [63:0] b_rcu_lane_ops_c16_s2_tid;
  logic [63:0] b_rcu_lane_ops_c16_s3_tid;
  logic [63:0] b_rcu_lane_ops_c17_s0_tid;
  logic [63:0] b_rcu_lane_ops_c17_s1_tid;
  logic [63:0] b_rcu_lane_ops_c17_s2_tid;
  logic [63:0] b_rcu_lane_ops_c17_s3_tid;
  logic [63:0] b_rcu_lane_ops_c18_s0_tid;
  logic [63:0] b_rcu_lane_ops_c18_s1_tid;
  logic [63:0] b_rcu_lane_ops_c18_s2_tid;
  logic [63:0] b_rcu_lane_ops_c18_s3_tid;
  logic [63:0] b_rcu_lane_ops_c19_s0_tid;
  logic [63:0] b_rcu_lane_ops_c19_s1_tid;
  logic [63:0] b_rcu_lane_ops_c19_s2_tid;
  logic [63:0] b_rcu_lane_ops_c19_s3_tid;
  logic [63:0] b_rcu_lane_ops_c20_s0_tid;
  logic [63:0] b_rcu_lane_ops_c20_s1_tid;
  logic [63:0] b_rcu_lane_ops_c20_s2_tid;
  logic [63:0] b_rcu_lane_ops_c20_s3_tid;
  logic [63:0] b_rcu_lane_ops_c21_s0_tid;
  logic [63:0] b_rcu_lane_ops_c21_s1_tid;
  logic [63:0] b_rcu_lane_ops_c21_s2_tid;
  logic [63:0] b_rcu_lane_ops_c21_s3_tid;
  logic [63:0] b_rcu_lane_ops_c22_s0_tid;
  logic [63:0] b_rcu_lane_ops_c22_s1_tid;
  logic [63:0] b_rcu_lane_ops_c22_s2_tid;
  logic [63:0] b_rcu_lane_ops_c22_s3_tid;
  logic [63:0] b_rcu_lane_ops_c23_s0_tid;
  logic [63:0] b_rcu_lane_ops_c23_s1_tid;
  logic [63:0] b_rcu_lane_ops_c23_s2_tid;
  logic [63:0] b_rcu_lane_ops_c23_s3_tid;
  logic [63:0] b_rcu_lane_ops_c24_s0_tid;
  logic [63:0] b_rcu_lane_ops_c24_s1_tid;
  logic [63:0] b_rcu_lane_ops_c24_s2_tid;
  logic [63:0] b_rcu_lane_ops_c24_s3_tid;
  logic [63:0] b_rcu_lane_ops_c25_s0_tid;
  logic [63:0] b_rcu_lane_ops_c25_s1_tid;
  logic [63:0] b_rcu_lane_ops_c25_s2_tid;
  logic [63:0] b_rcu_lane_ops_c25_s3_tid;
  logic [63:0] b_rcu_lane_ops_c26_s0_tid;
  logic [63:0] b_rcu_lane_ops_c26_s1_tid;
  logic [63:0] b_rcu_lane_ops_c26_s2_tid;
  logic [63:0] b_rcu_lane_ops_c26_s3_tid;
  logic [63:0] b_rcu_lane_ops_c27_s0_tid;
  logic [63:0] b_rcu_lane_ops_c27_s1_tid;
  logic [63:0] b_rcu_lane_ops_c27_s2_tid;
  logic [63:0] b_rcu_lane_ops_c27_s3_tid;
  logic [63:0] b_rcu_lane_ops_c28_s0_tid;
  logic [63:0] b_rcu_lane_ops_c28_s1_tid;
  logic [63:0] b_rcu_lane_ops_c28_s2_tid;
  logic [63:0] b_rcu_lane_ops_c28_s3_tid;
  logic [63:0] b_rcu_lane_ops_c29_s0_tid;
  logic [63:0] b_rcu_lane_ops_c29_s1_tid;
  logic [63:0] b_rcu_lane_ops_c29_s2_tid;
  logic [63:0] b_rcu_lane_ops_c29_s3_tid;
  logic [63:0] b_rcu_lane_ops_c30_s0_tid;
  logic [63:0] b_rcu_lane_ops_c30_s1_tid;
  logic [63:0] b_rcu_lane_ops_c30_s2_tid;
  logic [63:0] b_rcu_lane_ops_c30_s3_tid;
  logic [63:0] b_rcu_lane_ops_c31_s0_tid;
  logic [63:0] b_rcu_lane_ops_c31_s1_tid;
  logic [63:0] b_rcu_lane_ops_c31_s2_tid;
  logic [63:0] b_rcu_lane_ops_c31_s3_tid;
  logic [63:0] b_lane_rcu_res_c00_s0_tid;
  logic [63:0] b_lane_rcu_res_c00_s1_tid;
  logic [63:0] b_lane_rcu_res_c00_s2_tid;
  logic [63:0] b_lane_rcu_res_c00_s3_tid;
  logic [63:0] b_lane_rcu_res_c01_s0_tid;
  logic [63:0] b_lane_rcu_res_c01_s1_tid;
  logic [63:0] b_lane_rcu_res_c01_s2_tid;
  logic [63:0] b_lane_rcu_res_c01_s3_tid;
  logic [63:0] b_lane_rcu_res_c02_s0_tid;
  logic [63:0] b_lane_rcu_res_c02_s1_tid;
  logic [63:0] b_lane_rcu_res_c02_s2_tid;
  logic [63:0] b_lane_rcu_res_c02_s3_tid;
  logic [63:0] b_lane_rcu_res_c03_s0_tid;
  logic [63:0] b_lane_rcu_res_c03_s1_tid;
  logic [63:0] b_lane_rcu_res_c03_s2_tid;
  logic [63:0] b_lane_rcu_res_c03_s3_tid;
  logic [63:0] b_lane_rcu_res_c04_s0_tid;
  logic [63:0] b_lane_rcu_res_c04_s1_tid;
  logic [63:0] b_lane_rcu_res_c04_s2_tid;
  logic [63:0] b_lane_rcu_res_c04_s3_tid;
  logic [63:0] b_lane_rcu_res_c05_s0_tid;
  logic [63:0] b_lane_rcu_res_c05_s1_tid;
  logic [63:0] b_lane_rcu_res_c05_s2_tid;
  logic [63:0] b_lane_rcu_res_c05_s3_tid;
  logic [63:0] b_lane_rcu_res_c06_s0_tid;
  logic [63:0] b_lane_rcu_res_c06_s1_tid;
  logic [63:0] b_lane_rcu_res_c06_s2_tid;
  logic [63:0] b_lane_rcu_res_c06_s3_tid;
  logic [63:0] b_lane_rcu_res_c07_s0_tid;
  logic [63:0] b_lane_rcu_res_c07_s1_tid;
  logic [63:0] b_lane_rcu_res_c07_s2_tid;
  logic [63:0] b_lane_rcu_res_c07_s3_tid;
  logic [63:0] b_lane_rcu_res_c08_s0_tid;
  logic [63:0] b_lane_rcu_res_c08_s1_tid;
  logic [63:0] b_lane_rcu_res_c08_s2_tid;
  logic [63:0] b_lane_rcu_res_c08_s3_tid;
  logic [63:0] b_lane_rcu_res_c09_s0_tid;
  logic [63:0] b_lane_rcu_res_c09_s1_tid;
  logic [63:0] b_lane_rcu_res_c09_s2_tid;
  logic [63:0] b_lane_rcu_res_c09_s3_tid;
  logic [63:0] b_lane_rcu_res_c10_s0_tid;
  logic [63:0] b_lane_rcu_res_c10_s1_tid;
  logic [63:0] b_lane_rcu_res_c10_s2_tid;
  logic [63:0] b_lane_rcu_res_c10_s3_tid;
  logic [63:0] b_lane_rcu_res_c11_s0_tid;
  logic [63:0] b_lane_rcu_res_c11_s1_tid;
  logic [63:0] b_lane_rcu_res_c11_s2_tid;
  logic [63:0] b_lane_rcu_res_c11_s3_tid;
  logic [63:0] b_lane_rcu_res_c12_s0_tid;
  logic [63:0] b_lane_rcu_res_c12_s1_tid;
  logic [63:0] b_lane_rcu_res_c12_s2_tid;
  logic [63:0] b_lane_rcu_res_c12_s3_tid;
  logic [63:0] b_lane_rcu_res_c13_s0_tid;
  logic [63:0] b_lane_rcu_res_c13_s1_tid;
  logic [63:0] b_lane_rcu_res_c13_s2_tid;
  logic [63:0] b_lane_rcu_res_c13_s3_tid;
  logic [63:0] b_lane_rcu_res_c14_s0_tid;
  logic [63:0] b_lane_rcu_res_c14_s1_tid;
  logic [63:0] b_lane_rcu_res_c14_s2_tid;
  logic [63:0] b_lane_rcu_res_c14_s3_tid;
  logic [63:0] b_lane_rcu_res_c15_s0_tid;
  logic [63:0] b_lane_rcu_res_c15_s1_tid;
  logic [63:0] b_lane_rcu_res_c15_s2_tid;
  logic [63:0] b_lane_rcu_res_c15_s3_tid;
  logic [63:0] b_lane_rcu_res_c16_s0_tid;
  logic [63:0] b_lane_rcu_res_c16_s1_tid;
  logic [63:0] b_lane_rcu_res_c16_s2_tid;
  logic [63:0] b_lane_rcu_res_c16_s3_tid;
  logic [63:0] b_lane_rcu_res_c17_s0_tid;
  logic [63:0] b_lane_rcu_res_c17_s1_tid;
  logic [63:0] b_lane_rcu_res_c17_s2_tid;
  logic [63:0] b_lane_rcu_res_c17_s3_tid;
  logic [63:0] b_lane_rcu_res_c18_s0_tid;
  logic [63:0] b_lane_rcu_res_c18_s1_tid;
  logic [63:0] b_lane_rcu_res_c18_s2_tid;
  logic [63:0] b_lane_rcu_res_c18_s3_tid;
  logic [63:0] b_lane_rcu_res_c19_s0_tid;
  logic [63:0] b_lane_rcu_res_c19_s1_tid;
  logic [63:0] b_lane_rcu_res_c19_s2_tid;
  logic [63:0] b_lane_rcu_res_c19_s3_tid;
  logic [63:0] b_lane_rcu_res_c20_s0_tid;
  logic [63:0] b_lane_rcu_res_c20_s1_tid;
  logic [63:0] b_lane_rcu_res_c20_s2_tid;
  logic [63:0] b_lane_rcu_res_c20_s3_tid;
  logic [63:0] b_lane_rcu_res_c21_s0_tid;
  logic [63:0] b_lane_rcu_res_c21_s1_tid;
  logic [63:0] b_lane_rcu_res_c21_s2_tid;
  logic [63:0] b_lane_rcu_res_c21_s3_tid;
  logic [63:0] b_lane_rcu_res_c22_s0_tid;
  logic [63:0] b_lane_rcu_res_c22_s1_tid;
  logic [63:0] b_lane_rcu_res_c22_s2_tid;
  logic [63:0] b_lane_rcu_res_c22_s3_tid;
  logic [63:0] b_lane_rcu_res_c23_s0_tid;
  logic [63:0] b_lane_rcu_res_c23_s1_tid;
  logic [63:0] b_lane_rcu_res_c23_s2_tid;
  logic [63:0] b_lane_rcu_res_c23_s3_tid;
  logic [63:0] b_lane_rcu_res_c24_s0_tid;
  logic [63:0] b_lane_rcu_res_c24_s1_tid;
  logic [63:0] b_lane_rcu_res_c24_s2_tid;
  logic [63:0] b_lane_rcu_res_c24_s3_tid;
  logic [63:0] b_lane_rcu_res_c25_s0_tid;
  logic [63:0] b_lane_rcu_res_c25_s1_tid;
  logic [63:0] b_lane_rcu_res_c25_s2_tid;
  logic [63:0] b_lane_rcu_res_c25_s3_tid;
  logic [63:0] b_lane_rcu_res_c26_s0_tid;
  logic [63:0] b_lane_rcu_res_c26_s1_tid;
  logic [63:0] b_lane_rcu_res_c26_s2_tid;
  logic [63:0] b_lane_rcu_res_c26_s3_tid;
  logic [63:0] b_lane_rcu_res_c27_s0_tid;
  logic [63:0] b_lane_rcu_res_c27_s1_tid;
  logic [63:0] b_lane_rcu_res_c27_s2_tid;
  logic [63:0] b_lane_rcu_res_c27_s3_tid;
  logic [63:0] b_lane_rcu_res_c28_s0_tid;
  logic [63:0] b_lane_rcu_res_c28_s1_tid;
  logic [63:0] b_lane_rcu_res_c28_s2_tid;
  logic [63:0] b_lane_rcu_res_c28_s3_tid;
  logic [63:0] b_lane_rcu_res_c29_s0_tid;
  logic [63:0] b_lane_rcu_res_c29_s1_tid;
  logic [63:0] b_lane_rcu_res_c29_s2_tid;
  logic [63:0] b_lane_rcu_res_c29_s3_tid;
  logic [63:0] b_lane_rcu_res_c30_s0_tid;
  logic [63:0] b_lane_rcu_res_c30_s1_tid;
  logic [63:0] b_lane_rcu_res_c30_s2_tid;
  logic [63:0] b_lane_rcu_res_c30_s3_tid;
  logic [63:0] b_lane_rcu_res_c31_s0_tid;
  logic [63:0] b_lane_rcu_res_c31_s1_tid;
  logic [63:0] b_lane_rcu_res_c31_s2_tid;
  logic [63:0] b_lane_rcu_res_c31_s3_tid;
  logic [63:0] b_rcu_ooe_done_s0_tid;
  logic [63:0] b_rcu_ooe_done_s1_tid;
  logic [63:0] b_rcu_ooe_done_s2_tid;
  logic [63:0] b_rcu_ooe_done_s3_tid;
  logic [63:0] b_rcu_miu_addr_s0_tid;
  logic [63:0] b_rcu_miu_addr_s1_tid;
  logic [63:0] b_rcu_miu_addr_s2_tid;
  logic [63:0] b_rcu_miu_addr_s3_tid;
  logic [63:0] b_miu_rcu_data_s0_tid;
  logic [63:0] b_miu_rcu_data_s1_tid;
  logic [63:0] b_miu_rcu_data_s2_tid;
  logic [63:0] b_miu_rcu_data_s3_tid;
  logic [63:0] b_rau_rcu_mig_tid;
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
    .ooe_rcu_issue_wake(b_ooe_rcu_issue_wake),
    .rcu_lane_ops_c00_s0_valid(b_rcu_lane_ops_c00_s0_valid),
    .rcu_lane_ops_c00_s0_payload(b_rcu_lane_ops_c00_s0_payload),
    .rcu_lane_ops_c00_s0_credit(b_rcu_lane_ops_c00_s0_credit),
    .rcu_lane_ops_c00_s0_stall(b_rcu_lane_ops_c00_s0_stall),
    .rcu_lane_ops_c00_s1_valid(b_rcu_lane_ops_c00_s1_valid),
    .rcu_lane_ops_c00_s1_payload(b_rcu_lane_ops_c00_s1_payload),
    .rcu_lane_ops_c00_s1_credit(b_rcu_lane_ops_c00_s1_credit),
    .rcu_lane_ops_c00_s1_stall(b_rcu_lane_ops_c00_s1_stall),
    .rcu_lane_ops_c00_s2_valid(b_rcu_lane_ops_c00_s2_valid),
    .rcu_lane_ops_c00_s2_payload(b_rcu_lane_ops_c00_s2_payload),
    .rcu_lane_ops_c00_s2_credit(b_rcu_lane_ops_c00_s2_credit),
    .rcu_lane_ops_c00_s2_stall(b_rcu_lane_ops_c00_s2_stall),
    .rcu_lane_ops_c00_s3_valid(b_rcu_lane_ops_c00_s3_valid),
    .rcu_lane_ops_c00_s3_payload(b_rcu_lane_ops_c00_s3_payload),
    .rcu_lane_ops_c00_s3_credit(b_rcu_lane_ops_c00_s3_credit),
    .rcu_lane_ops_c00_s3_stall(b_rcu_lane_ops_c00_s3_stall),
    .rcu_lane_ops_c00_wake(b_rcu_lane_ops_c00_wake),
    .rcu_lane_ops_c01_s0_valid(b_rcu_lane_ops_c01_s0_valid),
    .rcu_lane_ops_c01_s0_payload(b_rcu_lane_ops_c01_s0_payload),
    .rcu_lane_ops_c01_s0_credit(b_rcu_lane_ops_c01_s0_credit),
    .rcu_lane_ops_c01_s0_stall(b_rcu_lane_ops_c01_s0_stall),
    .rcu_lane_ops_c01_s1_valid(b_rcu_lane_ops_c01_s1_valid),
    .rcu_lane_ops_c01_s1_payload(b_rcu_lane_ops_c01_s1_payload),
    .rcu_lane_ops_c01_s1_credit(b_rcu_lane_ops_c01_s1_credit),
    .rcu_lane_ops_c01_s1_stall(b_rcu_lane_ops_c01_s1_stall),
    .rcu_lane_ops_c01_s2_valid(b_rcu_lane_ops_c01_s2_valid),
    .rcu_lane_ops_c01_s2_payload(b_rcu_lane_ops_c01_s2_payload),
    .rcu_lane_ops_c01_s2_credit(b_rcu_lane_ops_c01_s2_credit),
    .rcu_lane_ops_c01_s2_stall(b_rcu_lane_ops_c01_s2_stall),
    .rcu_lane_ops_c01_s3_valid(b_rcu_lane_ops_c01_s3_valid),
    .rcu_lane_ops_c01_s3_payload(b_rcu_lane_ops_c01_s3_payload),
    .rcu_lane_ops_c01_s3_credit(b_rcu_lane_ops_c01_s3_credit),
    .rcu_lane_ops_c01_s3_stall(b_rcu_lane_ops_c01_s3_stall),
    .rcu_lane_ops_c01_wake(b_rcu_lane_ops_c01_wake),
    .rcu_lane_ops_c02_s0_valid(b_rcu_lane_ops_c02_s0_valid),
    .rcu_lane_ops_c02_s0_payload(b_rcu_lane_ops_c02_s0_payload),
    .rcu_lane_ops_c02_s0_credit(b_rcu_lane_ops_c02_s0_credit),
    .rcu_lane_ops_c02_s0_stall(b_rcu_lane_ops_c02_s0_stall),
    .rcu_lane_ops_c02_s1_valid(b_rcu_lane_ops_c02_s1_valid),
    .rcu_lane_ops_c02_s1_payload(b_rcu_lane_ops_c02_s1_payload),
    .rcu_lane_ops_c02_s1_credit(b_rcu_lane_ops_c02_s1_credit),
    .rcu_lane_ops_c02_s1_stall(b_rcu_lane_ops_c02_s1_stall),
    .rcu_lane_ops_c02_s2_valid(b_rcu_lane_ops_c02_s2_valid),
    .rcu_lane_ops_c02_s2_payload(b_rcu_lane_ops_c02_s2_payload),
    .rcu_lane_ops_c02_s2_credit(b_rcu_lane_ops_c02_s2_credit),
    .rcu_lane_ops_c02_s2_stall(b_rcu_lane_ops_c02_s2_stall),
    .rcu_lane_ops_c02_s3_valid(b_rcu_lane_ops_c02_s3_valid),
    .rcu_lane_ops_c02_s3_payload(b_rcu_lane_ops_c02_s3_payload),
    .rcu_lane_ops_c02_s3_credit(b_rcu_lane_ops_c02_s3_credit),
    .rcu_lane_ops_c02_s3_stall(b_rcu_lane_ops_c02_s3_stall),
    .rcu_lane_ops_c02_wake(b_rcu_lane_ops_c02_wake),
    .rcu_lane_ops_c03_s0_valid(b_rcu_lane_ops_c03_s0_valid),
    .rcu_lane_ops_c03_s0_payload(b_rcu_lane_ops_c03_s0_payload),
    .rcu_lane_ops_c03_s0_credit(b_rcu_lane_ops_c03_s0_credit),
    .rcu_lane_ops_c03_s0_stall(b_rcu_lane_ops_c03_s0_stall),
    .rcu_lane_ops_c03_s1_valid(b_rcu_lane_ops_c03_s1_valid),
    .rcu_lane_ops_c03_s1_payload(b_rcu_lane_ops_c03_s1_payload),
    .rcu_lane_ops_c03_s1_credit(b_rcu_lane_ops_c03_s1_credit),
    .rcu_lane_ops_c03_s1_stall(b_rcu_lane_ops_c03_s1_stall),
    .rcu_lane_ops_c03_s2_valid(b_rcu_lane_ops_c03_s2_valid),
    .rcu_lane_ops_c03_s2_payload(b_rcu_lane_ops_c03_s2_payload),
    .rcu_lane_ops_c03_s2_credit(b_rcu_lane_ops_c03_s2_credit),
    .rcu_lane_ops_c03_s2_stall(b_rcu_lane_ops_c03_s2_stall),
    .rcu_lane_ops_c03_s3_valid(b_rcu_lane_ops_c03_s3_valid),
    .rcu_lane_ops_c03_s3_payload(b_rcu_lane_ops_c03_s3_payload),
    .rcu_lane_ops_c03_s3_credit(b_rcu_lane_ops_c03_s3_credit),
    .rcu_lane_ops_c03_s3_stall(b_rcu_lane_ops_c03_s3_stall),
    .rcu_lane_ops_c03_wake(b_rcu_lane_ops_c03_wake),
    .rcu_lane_ops_c04_s0_valid(b_rcu_lane_ops_c04_s0_valid),
    .rcu_lane_ops_c04_s0_payload(b_rcu_lane_ops_c04_s0_payload),
    .rcu_lane_ops_c04_s0_credit(b_rcu_lane_ops_c04_s0_credit),
    .rcu_lane_ops_c04_s0_stall(b_rcu_lane_ops_c04_s0_stall),
    .rcu_lane_ops_c04_s1_valid(b_rcu_lane_ops_c04_s1_valid),
    .rcu_lane_ops_c04_s1_payload(b_rcu_lane_ops_c04_s1_payload),
    .rcu_lane_ops_c04_s1_credit(b_rcu_lane_ops_c04_s1_credit),
    .rcu_lane_ops_c04_s1_stall(b_rcu_lane_ops_c04_s1_stall),
    .rcu_lane_ops_c04_s2_valid(b_rcu_lane_ops_c04_s2_valid),
    .rcu_lane_ops_c04_s2_payload(b_rcu_lane_ops_c04_s2_payload),
    .rcu_lane_ops_c04_s2_credit(b_rcu_lane_ops_c04_s2_credit),
    .rcu_lane_ops_c04_s2_stall(b_rcu_lane_ops_c04_s2_stall),
    .rcu_lane_ops_c04_s3_valid(b_rcu_lane_ops_c04_s3_valid),
    .rcu_lane_ops_c04_s3_payload(b_rcu_lane_ops_c04_s3_payload),
    .rcu_lane_ops_c04_s3_credit(b_rcu_lane_ops_c04_s3_credit),
    .rcu_lane_ops_c04_s3_stall(b_rcu_lane_ops_c04_s3_stall),
    .rcu_lane_ops_c04_wake(b_rcu_lane_ops_c04_wake),
    .rcu_lane_ops_c05_s0_valid(b_rcu_lane_ops_c05_s0_valid),
    .rcu_lane_ops_c05_s0_payload(b_rcu_lane_ops_c05_s0_payload),
    .rcu_lane_ops_c05_s0_credit(b_rcu_lane_ops_c05_s0_credit),
    .rcu_lane_ops_c05_s0_stall(b_rcu_lane_ops_c05_s0_stall),
    .rcu_lane_ops_c05_s1_valid(b_rcu_lane_ops_c05_s1_valid),
    .rcu_lane_ops_c05_s1_payload(b_rcu_lane_ops_c05_s1_payload),
    .rcu_lane_ops_c05_s1_credit(b_rcu_lane_ops_c05_s1_credit),
    .rcu_lane_ops_c05_s1_stall(b_rcu_lane_ops_c05_s1_stall),
    .rcu_lane_ops_c05_s2_valid(b_rcu_lane_ops_c05_s2_valid),
    .rcu_lane_ops_c05_s2_payload(b_rcu_lane_ops_c05_s2_payload),
    .rcu_lane_ops_c05_s2_credit(b_rcu_lane_ops_c05_s2_credit),
    .rcu_lane_ops_c05_s2_stall(b_rcu_lane_ops_c05_s2_stall),
    .rcu_lane_ops_c05_s3_valid(b_rcu_lane_ops_c05_s3_valid),
    .rcu_lane_ops_c05_s3_payload(b_rcu_lane_ops_c05_s3_payload),
    .rcu_lane_ops_c05_s3_credit(b_rcu_lane_ops_c05_s3_credit),
    .rcu_lane_ops_c05_s3_stall(b_rcu_lane_ops_c05_s3_stall),
    .rcu_lane_ops_c05_wake(b_rcu_lane_ops_c05_wake),
    .rcu_lane_ops_c06_s0_valid(b_rcu_lane_ops_c06_s0_valid),
    .rcu_lane_ops_c06_s0_payload(b_rcu_lane_ops_c06_s0_payload),
    .rcu_lane_ops_c06_s0_credit(b_rcu_lane_ops_c06_s0_credit),
    .rcu_lane_ops_c06_s0_stall(b_rcu_lane_ops_c06_s0_stall),
    .rcu_lane_ops_c06_s1_valid(b_rcu_lane_ops_c06_s1_valid),
    .rcu_lane_ops_c06_s1_payload(b_rcu_lane_ops_c06_s1_payload),
    .rcu_lane_ops_c06_s1_credit(b_rcu_lane_ops_c06_s1_credit),
    .rcu_lane_ops_c06_s1_stall(b_rcu_lane_ops_c06_s1_stall),
    .rcu_lane_ops_c06_s2_valid(b_rcu_lane_ops_c06_s2_valid),
    .rcu_lane_ops_c06_s2_payload(b_rcu_lane_ops_c06_s2_payload),
    .rcu_lane_ops_c06_s2_credit(b_rcu_lane_ops_c06_s2_credit),
    .rcu_lane_ops_c06_s2_stall(b_rcu_lane_ops_c06_s2_stall),
    .rcu_lane_ops_c06_s3_valid(b_rcu_lane_ops_c06_s3_valid),
    .rcu_lane_ops_c06_s3_payload(b_rcu_lane_ops_c06_s3_payload),
    .rcu_lane_ops_c06_s3_credit(b_rcu_lane_ops_c06_s3_credit),
    .rcu_lane_ops_c06_s3_stall(b_rcu_lane_ops_c06_s3_stall),
    .rcu_lane_ops_c06_wake(b_rcu_lane_ops_c06_wake),
    .rcu_lane_ops_c07_s0_valid(b_rcu_lane_ops_c07_s0_valid),
    .rcu_lane_ops_c07_s0_payload(b_rcu_lane_ops_c07_s0_payload),
    .rcu_lane_ops_c07_s0_credit(b_rcu_lane_ops_c07_s0_credit),
    .rcu_lane_ops_c07_s0_stall(b_rcu_lane_ops_c07_s0_stall),
    .rcu_lane_ops_c07_s1_valid(b_rcu_lane_ops_c07_s1_valid),
    .rcu_lane_ops_c07_s1_payload(b_rcu_lane_ops_c07_s1_payload),
    .rcu_lane_ops_c07_s1_credit(b_rcu_lane_ops_c07_s1_credit),
    .rcu_lane_ops_c07_s1_stall(b_rcu_lane_ops_c07_s1_stall),
    .rcu_lane_ops_c07_s2_valid(b_rcu_lane_ops_c07_s2_valid),
    .rcu_lane_ops_c07_s2_payload(b_rcu_lane_ops_c07_s2_payload),
    .rcu_lane_ops_c07_s2_credit(b_rcu_lane_ops_c07_s2_credit),
    .rcu_lane_ops_c07_s2_stall(b_rcu_lane_ops_c07_s2_stall),
    .rcu_lane_ops_c07_s3_valid(b_rcu_lane_ops_c07_s3_valid),
    .rcu_lane_ops_c07_s3_payload(b_rcu_lane_ops_c07_s3_payload),
    .rcu_lane_ops_c07_s3_credit(b_rcu_lane_ops_c07_s3_credit),
    .rcu_lane_ops_c07_s3_stall(b_rcu_lane_ops_c07_s3_stall),
    .rcu_lane_ops_c07_wake(b_rcu_lane_ops_c07_wake),
    .rcu_lane_ops_c08_s0_valid(b_rcu_lane_ops_c08_s0_valid),
    .rcu_lane_ops_c08_s0_payload(b_rcu_lane_ops_c08_s0_payload),
    .rcu_lane_ops_c08_s0_credit(b_rcu_lane_ops_c08_s0_credit),
    .rcu_lane_ops_c08_s0_stall(b_rcu_lane_ops_c08_s0_stall),
    .rcu_lane_ops_c08_s1_valid(b_rcu_lane_ops_c08_s1_valid),
    .rcu_lane_ops_c08_s1_payload(b_rcu_lane_ops_c08_s1_payload),
    .rcu_lane_ops_c08_s1_credit(b_rcu_lane_ops_c08_s1_credit),
    .rcu_lane_ops_c08_s1_stall(b_rcu_lane_ops_c08_s1_stall),
    .rcu_lane_ops_c08_s2_valid(b_rcu_lane_ops_c08_s2_valid),
    .rcu_lane_ops_c08_s2_payload(b_rcu_lane_ops_c08_s2_payload),
    .rcu_lane_ops_c08_s2_credit(b_rcu_lane_ops_c08_s2_credit),
    .rcu_lane_ops_c08_s2_stall(b_rcu_lane_ops_c08_s2_stall),
    .rcu_lane_ops_c08_s3_valid(b_rcu_lane_ops_c08_s3_valid),
    .rcu_lane_ops_c08_s3_payload(b_rcu_lane_ops_c08_s3_payload),
    .rcu_lane_ops_c08_s3_credit(b_rcu_lane_ops_c08_s3_credit),
    .rcu_lane_ops_c08_s3_stall(b_rcu_lane_ops_c08_s3_stall),
    .rcu_lane_ops_c08_wake(b_rcu_lane_ops_c08_wake),
    .rcu_lane_ops_c09_s0_valid(b_rcu_lane_ops_c09_s0_valid),
    .rcu_lane_ops_c09_s0_payload(b_rcu_lane_ops_c09_s0_payload),
    .rcu_lane_ops_c09_s0_credit(b_rcu_lane_ops_c09_s0_credit),
    .rcu_lane_ops_c09_s0_stall(b_rcu_lane_ops_c09_s0_stall),
    .rcu_lane_ops_c09_s1_valid(b_rcu_lane_ops_c09_s1_valid),
    .rcu_lane_ops_c09_s1_payload(b_rcu_lane_ops_c09_s1_payload),
    .rcu_lane_ops_c09_s1_credit(b_rcu_lane_ops_c09_s1_credit),
    .rcu_lane_ops_c09_s1_stall(b_rcu_lane_ops_c09_s1_stall),
    .rcu_lane_ops_c09_s2_valid(b_rcu_lane_ops_c09_s2_valid),
    .rcu_lane_ops_c09_s2_payload(b_rcu_lane_ops_c09_s2_payload),
    .rcu_lane_ops_c09_s2_credit(b_rcu_lane_ops_c09_s2_credit),
    .rcu_lane_ops_c09_s2_stall(b_rcu_lane_ops_c09_s2_stall),
    .rcu_lane_ops_c09_s3_valid(b_rcu_lane_ops_c09_s3_valid),
    .rcu_lane_ops_c09_s3_payload(b_rcu_lane_ops_c09_s3_payload),
    .rcu_lane_ops_c09_s3_credit(b_rcu_lane_ops_c09_s3_credit),
    .rcu_lane_ops_c09_s3_stall(b_rcu_lane_ops_c09_s3_stall),
    .rcu_lane_ops_c09_wake(b_rcu_lane_ops_c09_wake),
    .rcu_lane_ops_c10_s0_valid(b_rcu_lane_ops_c10_s0_valid),
    .rcu_lane_ops_c10_s0_payload(b_rcu_lane_ops_c10_s0_payload),
    .rcu_lane_ops_c10_s0_credit(b_rcu_lane_ops_c10_s0_credit),
    .rcu_lane_ops_c10_s0_stall(b_rcu_lane_ops_c10_s0_stall),
    .rcu_lane_ops_c10_s1_valid(b_rcu_lane_ops_c10_s1_valid),
    .rcu_lane_ops_c10_s1_payload(b_rcu_lane_ops_c10_s1_payload),
    .rcu_lane_ops_c10_s1_credit(b_rcu_lane_ops_c10_s1_credit),
    .rcu_lane_ops_c10_s1_stall(b_rcu_lane_ops_c10_s1_stall),
    .rcu_lane_ops_c10_s2_valid(b_rcu_lane_ops_c10_s2_valid),
    .rcu_lane_ops_c10_s2_payload(b_rcu_lane_ops_c10_s2_payload),
    .rcu_lane_ops_c10_s2_credit(b_rcu_lane_ops_c10_s2_credit),
    .rcu_lane_ops_c10_s2_stall(b_rcu_lane_ops_c10_s2_stall),
    .rcu_lane_ops_c10_s3_valid(b_rcu_lane_ops_c10_s3_valid),
    .rcu_lane_ops_c10_s3_payload(b_rcu_lane_ops_c10_s3_payload),
    .rcu_lane_ops_c10_s3_credit(b_rcu_lane_ops_c10_s3_credit),
    .rcu_lane_ops_c10_s3_stall(b_rcu_lane_ops_c10_s3_stall),
    .rcu_lane_ops_c10_wake(b_rcu_lane_ops_c10_wake),
    .rcu_lane_ops_c11_s0_valid(b_rcu_lane_ops_c11_s0_valid),
    .rcu_lane_ops_c11_s0_payload(b_rcu_lane_ops_c11_s0_payload),
    .rcu_lane_ops_c11_s0_credit(b_rcu_lane_ops_c11_s0_credit),
    .rcu_lane_ops_c11_s0_stall(b_rcu_lane_ops_c11_s0_stall),
    .rcu_lane_ops_c11_s1_valid(b_rcu_lane_ops_c11_s1_valid),
    .rcu_lane_ops_c11_s1_payload(b_rcu_lane_ops_c11_s1_payload),
    .rcu_lane_ops_c11_s1_credit(b_rcu_lane_ops_c11_s1_credit),
    .rcu_lane_ops_c11_s1_stall(b_rcu_lane_ops_c11_s1_stall),
    .rcu_lane_ops_c11_s2_valid(b_rcu_lane_ops_c11_s2_valid),
    .rcu_lane_ops_c11_s2_payload(b_rcu_lane_ops_c11_s2_payload),
    .rcu_lane_ops_c11_s2_credit(b_rcu_lane_ops_c11_s2_credit),
    .rcu_lane_ops_c11_s2_stall(b_rcu_lane_ops_c11_s2_stall),
    .rcu_lane_ops_c11_s3_valid(b_rcu_lane_ops_c11_s3_valid),
    .rcu_lane_ops_c11_s3_payload(b_rcu_lane_ops_c11_s3_payload),
    .rcu_lane_ops_c11_s3_credit(b_rcu_lane_ops_c11_s3_credit),
    .rcu_lane_ops_c11_s3_stall(b_rcu_lane_ops_c11_s3_stall),
    .rcu_lane_ops_c11_wake(b_rcu_lane_ops_c11_wake),
    .rcu_lane_ops_c12_s0_valid(b_rcu_lane_ops_c12_s0_valid),
    .rcu_lane_ops_c12_s0_payload(b_rcu_lane_ops_c12_s0_payload),
    .rcu_lane_ops_c12_s0_credit(b_rcu_lane_ops_c12_s0_credit),
    .rcu_lane_ops_c12_s0_stall(b_rcu_lane_ops_c12_s0_stall),
    .rcu_lane_ops_c12_s1_valid(b_rcu_lane_ops_c12_s1_valid),
    .rcu_lane_ops_c12_s1_payload(b_rcu_lane_ops_c12_s1_payload),
    .rcu_lane_ops_c12_s1_credit(b_rcu_lane_ops_c12_s1_credit),
    .rcu_lane_ops_c12_s1_stall(b_rcu_lane_ops_c12_s1_stall),
    .rcu_lane_ops_c12_s2_valid(b_rcu_lane_ops_c12_s2_valid),
    .rcu_lane_ops_c12_s2_payload(b_rcu_lane_ops_c12_s2_payload),
    .rcu_lane_ops_c12_s2_credit(b_rcu_lane_ops_c12_s2_credit),
    .rcu_lane_ops_c12_s2_stall(b_rcu_lane_ops_c12_s2_stall),
    .rcu_lane_ops_c12_s3_valid(b_rcu_lane_ops_c12_s3_valid),
    .rcu_lane_ops_c12_s3_payload(b_rcu_lane_ops_c12_s3_payload),
    .rcu_lane_ops_c12_s3_credit(b_rcu_lane_ops_c12_s3_credit),
    .rcu_lane_ops_c12_s3_stall(b_rcu_lane_ops_c12_s3_stall),
    .rcu_lane_ops_c12_wake(b_rcu_lane_ops_c12_wake),
    .rcu_lane_ops_c13_s0_valid(b_rcu_lane_ops_c13_s0_valid),
    .rcu_lane_ops_c13_s0_payload(b_rcu_lane_ops_c13_s0_payload),
    .rcu_lane_ops_c13_s0_credit(b_rcu_lane_ops_c13_s0_credit),
    .rcu_lane_ops_c13_s0_stall(b_rcu_lane_ops_c13_s0_stall),
    .rcu_lane_ops_c13_s1_valid(b_rcu_lane_ops_c13_s1_valid),
    .rcu_lane_ops_c13_s1_payload(b_rcu_lane_ops_c13_s1_payload),
    .rcu_lane_ops_c13_s1_credit(b_rcu_lane_ops_c13_s1_credit),
    .rcu_lane_ops_c13_s1_stall(b_rcu_lane_ops_c13_s1_stall),
    .rcu_lane_ops_c13_s2_valid(b_rcu_lane_ops_c13_s2_valid),
    .rcu_lane_ops_c13_s2_payload(b_rcu_lane_ops_c13_s2_payload),
    .rcu_lane_ops_c13_s2_credit(b_rcu_lane_ops_c13_s2_credit),
    .rcu_lane_ops_c13_s2_stall(b_rcu_lane_ops_c13_s2_stall),
    .rcu_lane_ops_c13_s3_valid(b_rcu_lane_ops_c13_s3_valid),
    .rcu_lane_ops_c13_s3_payload(b_rcu_lane_ops_c13_s3_payload),
    .rcu_lane_ops_c13_s3_credit(b_rcu_lane_ops_c13_s3_credit),
    .rcu_lane_ops_c13_s3_stall(b_rcu_lane_ops_c13_s3_stall),
    .rcu_lane_ops_c13_wake(b_rcu_lane_ops_c13_wake),
    .rcu_lane_ops_c14_s0_valid(b_rcu_lane_ops_c14_s0_valid),
    .rcu_lane_ops_c14_s0_payload(b_rcu_lane_ops_c14_s0_payload),
    .rcu_lane_ops_c14_s0_credit(b_rcu_lane_ops_c14_s0_credit),
    .rcu_lane_ops_c14_s0_stall(b_rcu_lane_ops_c14_s0_stall),
    .rcu_lane_ops_c14_s1_valid(b_rcu_lane_ops_c14_s1_valid),
    .rcu_lane_ops_c14_s1_payload(b_rcu_lane_ops_c14_s1_payload),
    .rcu_lane_ops_c14_s1_credit(b_rcu_lane_ops_c14_s1_credit),
    .rcu_lane_ops_c14_s1_stall(b_rcu_lane_ops_c14_s1_stall),
    .rcu_lane_ops_c14_s2_valid(b_rcu_lane_ops_c14_s2_valid),
    .rcu_lane_ops_c14_s2_payload(b_rcu_lane_ops_c14_s2_payload),
    .rcu_lane_ops_c14_s2_credit(b_rcu_lane_ops_c14_s2_credit),
    .rcu_lane_ops_c14_s2_stall(b_rcu_lane_ops_c14_s2_stall),
    .rcu_lane_ops_c14_s3_valid(b_rcu_lane_ops_c14_s3_valid),
    .rcu_lane_ops_c14_s3_payload(b_rcu_lane_ops_c14_s3_payload),
    .rcu_lane_ops_c14_s3_credit(b_rcu_lane_ops_c14_s3_credit),
    .rcu_lane_ops_c14_s3_stall(b_rcu_lane_ops_c14_s3_stall),
    .rcu_lane_ops_c14_wake(b_rcu_lane_ops_c14_wake),
    .rcu_lane_ops_c15_s0_valid(b_rcu_lane_ops_c15_s0_valid),
    .rcu_lane_ops_c15_s0_payload(b_rcu_lane_ops_c15_s0_payload),
    .rcu_lane_ops_c15_s0_credit(b_rcu_lane_ops_c15_s0_credit),
    .rcu_lane_ops_c15_s0_stall(b_rcu_lane_ops_c15_s0_stall),
    .rcu_lane_ops_c15_s1_valid(b_rcu_lane_ops_c15_s1_valid),
    .rcu_lane_ops_c15_s1_payload(b_rcu_lane_ops_c15_s1_payload),
    .rcu_lane_ops_c15_s1_credit(b_rcu_lane_ops_c15_s1_credit),
    .rcu_lane_ops_c15_s1_stall(b_rcu_lane_ops_c15_s1_stall),
    .rcu_lane_ops_c15_s2_valid(b_rcu_lane_ops_c15_s2_valid),
    .rcu_lane_ops_c15_s2_payload(b_rcu_lane_ops_c15_s2_payload),
    .rcu_lane_ops_c15_s2_credit(b_rcu_lane_ops_c15_s2_credit),
    .rcu_lane_ops_c15_s2_stall(b_rcu_lane_ops_c15_s2_stall),
    .rcu_lane_ops_c15_s3_valid(b_rcu_lane_ops_c15_s3_valid),
    .rcu_lane_ops_c15_s3_payload(b_rcu_lane_ops_c15_s3_payload),
    .rcu_lane_ops_c15_s3_credit(b_rcu_lane_ops_c15_s3_credit),
    .rcu_lane_ops_c15_s3_stall(b_rcu_lane_ops_c15_s3_stall),
    .rcu_lane_ops_c15_wake(b_rcu_lane_ops_c15_wake),
    .rcu_lane_ops_c16_s0_valid(b_rcu_lane_ops_c16_s0_valid),
    .rcu_lane_ops_c16_s0_payload(b_rcu_lane_ops_c16_s0_payload),
    .rcu_lane_ops_c16_s0_credit(b_rcu_lane_ops_c16_s0_credit),
    .rcu_lane_ops_c16_s0_stall(b_rcu_lane_ops_c16_s0_stall),
    .rcu_lane_ops_c16_s1_valid(b_rcu_lane_ops_c16_s1_valid),
    .rcu_lane_ops_c16_s1_payload(b_rcu_lane_ops_c16_s1_payload),
    .rcu_lane_ops_c16_s1_credit(b_rcu_lane_ops_c16_s1_credit),
    .rcu_lane_ops_c16_s1_stall(b_rcu_lane_ops_c16_s1_stall),
    .rcu_lane_ops_c16_s2_valid(b_rcu_lane_ops_c16_s2_valid),
    .rcu_lane_ops_c16_s2_payload(b_rcu_lane_ops_c16_s2_payload),
    .rcu_lane_ops_c16_s2_credit(b_rcu_lane_ops_c16_s2_credit),
    .rcu_lane_ops_c16_s2_stall(b_rcu_lane_ops_c16_s2_stall),
    .rcu_lane_ops_c16_s3_valid(b_rcu_lane_ops_c16_s3_valid),
    .rcu_lane_ops_c16_s3_payload(b_rcu_lane_ops_c16_s3_payload),
    .rcu_lane_ops_c16_s3_credit(b_rcu_lane_ops_c16_s3_credit),
    .rcu_lane_ops_c16_s3_stall(b_rcu_lane_ops_c16_s3_stall),
    .rcu_lane_ops_c16_wake(b_rcu_lane_ops_c16_wake),
    .rcu_lane_ops_c17_s0_valid(b_rcu_lane_ops_c17_s0_valid),
    .rcu_lane_ops_c17_s0_payload(b_rcu_lane_ops_c17_s0_payload),
    .rcu_lane_ops_c17_s0_credit(b_rcu_lane_ops_c17_s0_credit),
    .rcu_lane_ops_c17_s0_stall(b_rcu_lane_ops_c17_s0_stall),
    .rcu_lane_ops_c17_s1_valid(b_rcu_lane_ops_c17_s1_valid),
    .rcu_lane_ops_c17_s1_payload(b_rcu_lane_ops_c17_s1_payload),
    .rcu_lane_ops_c17_s1_credit(b_rcu_lane_ops_c17_s1_credit),
    .rcu_lane_ops_c17_s1_stall(b_rcu_lane_ops_c17_s1_stall),
    .rcu_lane_ops_c17_s2_valid(b_rcu_lane_ops_c17_s2_valid),
    .rcu_lane_ops_c17_s2_payload(b_rcu_lane_ops_c17_s2_payload),
    .rcu_lane_ops_c17_s2_credit(b_rcu_lane_ops_c17_s2_credit),
    .rcu_lane_ops_c17_s2_stall(b_rcu_lane_ops_c17_s2_stall),
    .rcu_lane_ops_c17_s3_valid(b_rcu_lane_ops_c17_s3_valid),
    .rcu_lane_ops_c17_s3_payload(b_rcu_lane_ops_c17_s3_payload),
    .rcu_lane_ops_c17_s3_credit(b_rcu_lane_ops_c17_s3_credit),
    .rcu_lane_ops_c17_s3_stall(b_rcu_lane_ops_c17_s3_stall),
    .rcu_lane_ops_c17_wake(b_rcu_lane_ops_c17_wake),
    .rcu_lane_ops_c18_s0_valid(b_rcu_lane_ops_c18_s0_valid),
    .rcu_lane_ops_c18_s0_payload(b_rcu_lane_ops_c18_s0_payload),
    .rcu_lane_ops_c18_s0_credit(b_rcu_lane_ops_c18_s0_credit),
    .rcu_lane_ops_c18_s0_stall(b_rcu_lane_ops_c18_s0_stall),
    .rcu_lane_ops_c18_s1_valid(b_rcu_lane_ops_c18_s1_valid),
    .rcu_lane_ops_c18_s1_payload(b_rcu_lane_ops_c18_s1_payload),
    .rcu_lane_ops_c18_s1_credit(b_rcu_lane_ops_c18_s1_credit),
    .rcu_lane_ops_c18_s1_stall(b_rcu_lane_ops_c18_s1_stall),
    .rcu_lane_ops_c18_s2_valid(b_rcu_lane_ops_c18_s2_valid),
    .rcu_lane_ops_c18_s2_payload(b_rcu_lane_ops_c18_s2_payload),
    .rcu_lane_ops_c18_s2_credit(b_rcu_lane_ops_c18_s2_credit),
    .rcu_lane_ops_c18_s2_stall(b_rcu_lane_ops_c18_s2_stall),
    .rcu_lane_ops_c18_s3_valid(b_rcu_lane_ops_c18_s3_valid),
    .rcu_lane_ops_c18_s3_payload(b_rcu_lane_ops_c18_s3_payload),
    .rcu_lane_ops_c18_s3_credit(b_rcu_lane_ops_c18_s3_credit),
    .rcu_lane_ops_c18_s3_stall(b_rcu_lane_ops_c18_s3_stall),
    .rcu_lane_ops_c18_wake(b_rcu_lane_ops_c18_wake),
    .rcu_lane_ops_c19_s0_valid(b_rcu_lane_ops_c19_s0_valid),
    .rcu_lane_ops_c19_s0_payload(b_rcu_lane_ops_c19_s0_payload),
    .rcu_lane_ops_c19_s0_credit(b_rcu_lane_ops_c19_s0_credit),
    .rcu_lane_ops_c19_s0_stall(b_rcu_lane_ops_c19_s0_stall),
    .rcu_lane_ops_c19_s1_valid(b_rcu_lane_ops_c19_s1_valid),
    .rcu_lane_ops_c19_s1_payload(b_rcu_lane_ops_c19_s1_payload),
    .rcu_lane_ops_c19_s1_credit(b_rcu_lane_ops_c19_s1_credit),
    .rcu_lane_ops_c19_s1_stall(b_rcu_lane_ops_c19_s1_stall),
    .rcu_lane_ops_c19_s2_valid(b_rcu_lane_ops_c19_s2_valid),
    .rcu_lane_ops_c19_s2_payload(b_rcu_lane_ops_c19_s2_payload),
    .rcu_lane_ops_c19_s2_credit(b_rcu_lane_ops_c19_s2_credit),
    .rcu_lane_ops_c19_s2_stall(b_rcu_lane_ops_c19_s2_stall),
    .rcu_lane_ops_c19_s3_valid(b_rcu_lane_ops_c19_s3_valid),
    .rcu_lane_ops_c19_s3_payload(b_rcu_lane_ops_c19_s3_payload),
    .rcu_lane_ops_c19_s3_credit(b_rcu_lane_ops_c19_s3_credit),
    .rcu_lane_ops_c19_s3_stall(b_rcu_lane_ops_c19_s3_stall),
    .rcu_lane_ops_c19_wake(b_rcu_lane_ops_c19_wake),
    .rcu_lane_ops_c20_s0_valid(b_rcu_lane_ops_c20_s0_valid),
    .rcu_lane_ops_c20_s0_payload(b_rcu_lane_ops_c20_s0_payload),
    .rcu_lane_ops_c20_s0_credit(b_rcu_lane_ops_c20_s0_credit),
    .rcu_lane_ops_c20_s0_stall(b_rcu_lane_ops_c20_s0_stall),
    .rcu_lane_ops_c20_s1_valid(b_rcu_lane_ops_c20_s1_valid),
    .rcu_lane_ops_c20_s1_payload(b_rcu_lane_ops_c20_s1_payload),
    .rcu_lane_ops_c20_s1_credit(b_rcu_lane_ops_c20_s1_credit),
    .rcu_lane_ops_c20_s1_stall(b_rcu_lane_ops_c20_s1_stall),
    .rcu_lane_ops_c20_s2_valid(b_rcu_lane_ops_c20_s2_valid),
    .rcu_lane_ops_c20_s2_payload(b_rcu_lane_ops_c20_s2_payload),
    .rcu_lane_ops_c20_s2_credit(b_rcu_lane_ops_c20_s2_credit),
    .rcu_lane_ops_c20_s2_stall(b_rcu_lane_ops_c20_s2_stall),
    .rcu_lane_ops_c20_s3_valid(b_rcu_lane_ops_c20_s3_valid),
    .rcu_lane_ops_c20_s3_payload(b_rcu_lane_ops_c20_s3_payload),
    .rcu_lane_ops_c20_s3_credit(b_rcu_lane_ops_c20_s3_credit),
    .rcu_lane_ops_c20_s3_stall(b_rcu_lane_ops_c20_s3_stall),
    .rcu_lane_ops_c20_wake(b_rcu_lane_ops_c20_wake),
    .rcu_lane_ops_c21_s0_valid(b_rcu_lane_ops_c21_s0_valid),
    .rcu_lane_ops_c21_s0_payload(b_rcu_lane_ops_c21_s0_payload),
    .rcu_lane_ops_c21_s0_credit(b_rcu_lane_ops_c21_s0_credit),
    .rcu_lane_ops_c21_s0_stall(b_rcu_lane_ops_c21_s0_stall),
    .rcu_lane_ops_c21_s1_valid(b_rcu_lane_ops_c21_s1_valid),
    .rcu_lane_ops_c21_s1_payload(b_rcu_lane_ops_c21_s1_payload),
    .rcu_lane_ops_c21_s1_credit(b_rcu_lane_ops_c21_s1_credit),
    .rcu_lane_ops_c21_s1_stall(b_rcu_lane_ops_c21_s1_stall),
    .rcu_lane_ops_c21_s2_valid(b_rcu_lane_ops_c21_s2_valid),
    .rcu_lane_ops_c21_s2_payload(b_rcu_lane_ops_c21_s2_payload),
    .rcu_lane_ops_c21_s2_credit(b_rcu_lane_ops_c21_s2_credit),
    .rcu_lane_ops_c21_s2_stall(b_rcu_lane_ops_c21_s2_stall),
    .rcu_lane_ops_c21_s3_valid(b_rcu_lane_ops_c21_s3_valid),
    .rcu_lane_ops_c21_s3_payload(b_rcu_lane_ops_c21_s3_payload),
    .rcu_lane_ops_c21_s3_credit(b_rcu_lane_ops_c21_s3_credit),
    .rcu_lane_ops_c21_s3_stall(b_rcu_lane_ops_c21_s3_stall),
    .rcu_lane_ops_c21_wake(b_rcu_lane_ops_c21_wake),
    .rcu_lane_ops_c22_s0_valid(b_rcu_lane_ops_c22_s0_valid),
    .rcu_lane_ops_c22_s0_payload(b_rcu_lane_ops_c22_s0_payload),
    .rcu_lane_ops_c22_s0_credit(b_rcu_lane_ops_c22_s0_credit),
    .rcu_lane_ops_c22_s0_stall(b_rcu_lane_ops_c22_s0_stall),
    .rcu_lane_ops_c22_s1_valid(b_rcu_lane_ops_c22_s1_valid),
    .rcu_lane_ops_c22_s1_payload(b_rcu_lane_ops_c22_s1_payload),
    .rcu_lane_ops_c22_s1_credit(b_rcu_lane_ops_c22_s1_credit),
    .rcu_lane_ops_c22_s1_stall(b_rcu_lane_ops_c22_s1_stall),
    .rcu_lane_ops_c22_s2_valid(b_rcu_lane_ops_c22_s2_valid),
    .rcu_lane_ops_c22_s2_payload(b_rcu_lane_ops_c22_s2_payload),
    .rcu_lane_ops_c22_s2_credit(b_rcu_lane_ops_c22_s2_credit),
    .rcu_lane_ops_c22_s2_stall(b_rcu_lane_ops_c22_s2_stall),
    .rcu_lane_ops_c22_s3_valid(b_rcu_lane_ops_c22_s3_valid),
    .rcu_lane_ops_c22_s3_payload(b_rcu_lane_ops_c22_s3_payload),
    .rcu_lane_ops_c22_s3_credit(b_rcu_lane_ops_c22_s3_credit),
    .rcu_lane_ops_c22_s3_stall(b_rcu_lane_ops_c22_s3_stall),
    .rcu_lane_ops_c22_wake(b_rcu_lane_ops_c22_wake),
    .rcu_lane_ops_c23_s0_valid(b_rcu_lane_ops_c23_s0_valid),
    .rcu_lane_ops_c23_s0_payload(b_rcu_lane_ops_c23_s0_payload),
    .rcu_lane_ops_c23_s0_credit(b_rcu_lane_ops_c23_s0_credit),
    .rcu_lane_ops_c23_s0_stall(b_rcu_lane_ops_c23_s0_stall),
    .rcu_lane_ops_c23_s1_valid(b_rcu_lane_ops_c23_s1_valid),
    .rcu_lane_ops_c23_s1_payload(b_rcu_lane_ops_c23_s1_payload),
    .rcu_lane_ops_c23_s1_credit(b_rcu_lane_ops_c23_s1_credit),
    .rcu_lane_ops_c23_s1_stall(b_rcu_lane_ops_c23_s1_stall),
    .rcu_lane_ops_c23_s2_valid(b_rcu_lane_ops_c23_s2_valid),
    .rcu_lane_ops_c23_s2_payload(b_rcu_lane_ops_c23_s2_payload),
    .rcu_lane_ops_c23_s2_credit(b_rcu_lane_ops_c23_s2_credit),
    .rcu_lane_ops_c23_s2_stall(b_rcu_lane_ops_c23_s2_stall),
    .rcu_lane_ops_c23_s3_valid(b_rcu_lane_ops_c23_s3_valid),
    .rcu_lane_ops_c23_s3_payload(b_rcu_lane_ops_c23_s3_payload),
    .rcu_lane_ops_c23_s3_credit(b_rcu_lane_ops_c23_s3_credit),
    .rcu_lane_ops_c23_s3_stall(b_rcu_lane_ops_c23_s3_stall),
    .rcu_lane_ops_c23_wake(b_rcu_lane_ops_c23_wake),
    .rcu_lane_ops_c24_s0_valid(b_rcu_lane_ops_c24_s0_valid),
    .rcu_lane_ops_c24_s0_payload(b_rcu_lane_ops_c24_s0_payload),
    .rcu_lane_ops_c24_s0_credit(b_rcu_lane_ops_c24_s0_credit),
    .rcu_lane_ops_c24_s0_stall(b_rcu_lane_ops_c24_s0_stall),
    .rcu_lane_ops_c24_s1_valid(b_rcu_lane_ops_c24_s1_valid),
    .rcu_lane_ops_c24_s1_payload(b_rcu_lane_ops_c24_s1_payload),
    .rcu_lane_ops_c24_s1_credit(b_rcu_lane_ops_c24_s1_credit),
    .rcu_lane_ops_c24_s1_stall(b_rcu_lane_ops_c24_s1_stall),
    .rcu_lane_ops_c24_s2_valid(b_rcu_lane_ops_c24_s2_valid),
    .rcu_lane_ops_c24_s2_payload(b_rcu_lane_ops_c24_s2_payload),
    .rcu_lane_ops_c24_s2_credit(b_rcu_lane_ops_c24_s2_credit),
    .rcu_lane_ops_c24_s2_stall(b_rcu_lane_ops_c24_s2_stall),
    .rcu_lane_ops_c24_s3_valid(b_rcu_lane_ops_c24_s3_valid),
    .rcu_lane_ops_c24_s3_payload(b_rcu_lane_ops_c24_s3_payload),
    .rcu_lane_ops_c24_s3_credit(b_rcu_lane_ops_c24_s3_credit),
    .rcu_lane_ops_c24_s3_stall(b_rcu_lane_ops_c24_s3_stall),
    .rcu_lane_ops_c24_wake(b_rcu_lane_ops_c24_wake),
    .rcu_lane_ops_c25_s0_valid(b_rcu_lane_ops_c25_s0_valid),
    .rcu_lane_ops_c25_s0_payload(b_rcu_lane_ops_c25_s0_payload),
    .rcu_lane_ops_c25_s0_credit(b_rcu_lane_ops_c25_s0_credit),
    .rcu_lane_ops_c25_s0_stall(b_rcu_lane_ops_c25_s0_stall),
    .rcu_lane_ops_c25_s1_valid(b_rcu_lane_ops_c25_s1_valid),
    .rcu_lane_ops_c25_s1_payload(b_rcu_lane_ops_c25_s1_payload),
    .rcu_lane_ops_c25_s1_credit(b_rcu_lane_ops_c25_s1_credit),
    .rcu_lane_ops_c25_s1_stall(b_rcu_lane_ops_c25_s1_stall),
    .rcu_lane_ops_c25_s2_valid(b_rcu_lane_ops_c25_s2_valid),
    .rcu_lane_ops_c25_s2_payload(b_rcu_lane_ops_c25_s2_payload),
    .rcu_lane_ops_c25_s2_credit(b_rcu_lane_ops_c25_s2_credit),
    .rcu_lane_ops_c25_s2_stall(b_rcu_lane_ops_c25_s2_stall),
    .rcu_lane_ops_c25_s3_valid(b_rcu_lane_ops_c25_s3_valid),
    .rcu_lane_ops_c25_s3_payload(b_rcu_lane_ops_c25_s3_payload),
    .rcu_lane_ops_c25_s3_credit(b_rcu_lane_ops_c25_s3_credit),
    .rcu_lane_ops_c25_s3_stall(b_rcu_lane_ops_c25_s3_stall),
    .rcu_lane_ops_c25_wake(b_rcu_lane_ops_c25_wake),
    .rcu_lane_ops_c26_s0_valid(b_rcu_lane_ops_c26_s0_valid),
    .rcu_lane_ops_c26_s0_payload(b_rcu_lane_ops_c26_s0_payload),
    .rcu_lane_ops_c26_s0_credit(b_rcu_lane_ops_c26_s0_credit),
    .rcu_lane_ops_c26_s0_stall(b_rcu_lane_ops_c26_s0_stall),
    .rcu_lane_ops_c26_s1_valid(b_rcu_lane_ops_c26_s1_valid),
    .rcu_lane_ops_c26_s1_payload(b_rcu_lane_ops_c26_s1_payload),
    .rcu_lane_ops_c26_s1_credit(b_rcu_lane_ops_c26_s1_credit),
    .rcu_lane_ops_c26_s1_stall(b_rcu_lane_ops_c26_s1_stall),
    .rcu_lane_ops_c26_s2_valid(b_rcu_lane_ops_c26_s2_valid),
    .rcu_lane_ops_c26_s2_payload(b_rcu_lane_ops_c26_s2_payload),
    .rcu_lane_ops_c26_s2_credit(b_rcu_lane_ops_c26_s2_credit),
    .rcu_lane_ops_c26_s2_stall(b_rcu_lane_ops_c26_s2_stall),
    .rcu_lane_ops_c26_s3_valid(b_rcu_lane_ops_c26_s3_valid),
    .rcu_lane_ops_c26_s3_payload(b_rcu_lane_ops_c26_s3_payload),
    .rcu_lane_ops_c26_s3_credit(b_rcu_lane_ops_c26_s3_credit),
    .rcu_lane_ops_c26_s3_stall(b_rcu_lane_ops_c26_s3_stall),
    .rcu_lane_ops_c26_wake(b_rcu_lane_ops_c26_wake),
    .rcu_lane_ops_c27_s0_valid(b_rcu_lane_ops_c27_s0_valid),
    .rcu_lane_ops_c27_s0_payload(b_rcu_lane_ops_c27_s0_payload),
    .rcu_lane_ops_c27_s0_credit(b_rcu_lane_ops_c27_s0_credit),
    .rcu_lane_ops_c27_s0_stall(b_rcu_lane_ops_c27_s0_stall),
    .rcu_lane_ops_c27_s1_valid(b_rcu_lane_ops_c27_s1_valid),
    .rcu_lane_ops_c27_s1_payload(b_rcu_lane_ops_c27_s1_payload),
    .rcu_lane_ops_c27_s1_credit(b_rcu_lane_ops_c27_s1_credit),
    .rcu_lane_ops_c27_s1_stall(b_rcu_lane_ops_c27_s1_stall),
    .rcu_lane_ops_c27_s2_valid(b_rcu_lane_ops_c27_s2_valid),
    .rcu_lane_ops_c27_s2_payload(b_rcu_lane_ops_c27_s2_payload),
    .rcu_lane_ops_c27_s2_credit(b_rcu_lane_ops_c27_s2_credit),
    .rcu_lane_ops_c27_s2_stall(b_rcu_lane_ops_c27_s2_stall),
    .rcu_lane_ops_c27_s3_valid(b_rcu_lane_ops_c27_s3_valid),
    .rcu_lane_ops_c27_s3_payload(b_rcu_lane_ops_c27_s3_payload),
    .rcu_lane_ops_c27_s3_credit(b_rcu_lane_ops_c27_s3_credit),
    .rcu_lane_ops_c27_s3_stall(b_rcu_lane_ops_c27_s3_stall),
    .rcu_lane_ops_c27_wake(b_rcu_lane_ops_c27_wake),
    .rcu_lane_ops_c28_s0_valid(b_rcu_lane_ops_c28_s0_valid),
    .rcu_lane_ops_c28_s0_payload(b_rcu_lane_ops_c28_s0_payload),
    .rcu_lane_ops_c28_s0_credit(b_rcu_lane_ops_c28_s0_credit),
    .rcu_lane_ops_c28_s0_stall(b_rcu_lane_ops_c28_s0_stall),
    .rcu_lane_ops_c28_s1_valid(b_rcu_lane_ops_c28_s1_valid),
    .rcu_lane_ops_c28_s1_payload(b_rcu_lane_ops_c28_s1_payload),
    .rcu_lane_ops_c28_s1_credit(b_rcu_lane_ops_c28_s1_credit),
    .rcu_lane_ops_c28_s1_stall(b_rcu_lane_ops_c28_s1_stall),
    .rcu_lane_ops_c28_s2_valid(b_rcu_lane_ops_c28_s2_valid),
    .rcu_lane_ops_c28_s2_payload(b_rcu_lane_ops_c28_s2_payload),
    .rcu_lane_ops_c28_s2_credit(b_rcu_lane_ops_c28_s2_credit),
    .rcu_lane_ops_c28_s2_stall(b_rcu_lane_ops_c28_s2_stall),
    .rcu_lane_ops_c28_s3_valid(b_rcu_lane_ops_c28_s3_valid),
    .rcu_lane_ops_c28_s3_payload(b_rcu_lane_ops_c28_s3_payload),
    .rcu_lane_ops_c28_s3_credit(b_rcu_lane_ops_c28_s3_credit),
    .rcu_lane_ops_c28_s3_stall(b_rcu_lane_ops_c28_s3_stall),
    .rcu_lane_ops_c28_wake(b_rcu_lane_ops_c28_wake),
    .rcu_lane_ops_c29_s0_valid(b_rcu_lane_ops_c29_s0_valid),
    .rcu_lane_ops_c29_s0_payload(b_rcu_lane_ops_c29_s0_payload),
    .rcu_lane_ops_c29_s0_credit(b_rcu_lane_ops_c29_s0_credit),
    .rcu_lane_ops_c29_s0_stall(b_rcu_lane_ops_c29_s0_stall),
    .rcu_lane_ops_c29_s1_valid(b_rcu_lane_ops_c29_s1_valid),
    .rcu_lane_ops_c29_s1_payload(b_rcu_lane_ops_c29_s1_payload),
    .rcu_lane_ops_c29_s1_credit(b_rcu_lane_ops_c29_s1_credit),
    .rcu_lane_ops_c29_s1_stall(b_rcu_lane_ops_c29_s1_stall),
    .rcu_lane_ops_c29_s2_valid(b_rcu_lane_ops_c29_s2_valid),
    .rcu_lane_ops_c29_s2_payload(b_rcu_lane_ops_c29_s2_payload),
    .rcu_lane_ops_c29_s2_credit(b_rcu_lane_ops_c29_s2_credit),
    .rcu_lane_ops_c29_s2_stall(b_rcu_lane_ops_c29_s2_stall),
    .rcu_lane_ops_c29_s3_valid(b_rcu_lane_ops_c29_s3_valid),
    .rcu_lane_ops_c29_s3_payload(b_rcu_lane_ops_c29_s3_payload),
    .rcu_lane_ops_c29_s3_credit(b_rcu_lane_ops_c29_s3_credit),
    .rcu_lane_ops_c29_s3_stall(b_rcu_lane_ops_c29_s3_stall),
    .rcu_lane_ops_c29_wake(b_rcu_lane_ops_c29_wake),
    .rcu_lane_ops_c30_s0_valid(b_rcu_lane_ops_c30_s0_valid),
    .rcu_lane_ops_c30_s0_payload(b_rcu_lane_ops_c30_s0_payload),
    .rcu_lane_ops_c30_s0_credit(b_rcu_lane_ops_c30_s0_credit),
    .rcu_lane_ops_c30_s0_stall(b_rcu_lane_ops_c30_s0_stall),
    .rcu_lane_ops_c30_s1_valid(b_rcu_lane_ops_c30_s1_valid),
    .rcu_lane_ops_c30_s1_payload(b_rcu_lane_ops_c30_s1_payload),
    .rcu_lane_ops_c30_s1_credit(b_rcu_lane_ops_c30_s1_credit),
    .rcu_lane_ops_c30_s1_stall(b_rcu_lane_ops_c30_s1_stall),
    .rcu_lane_ops_c30_s2_valid(b_rcu_lane_ops_c30_s2_valid),
    .rcu_lane_ops_c30_s2_payload(b_rcu_lane_ops_c30_s2_payload),
    .rcu_lane_ops_c30_s2_credit(b_rcu_lane_ops_c30_s2_credit),
    .rcu_lane_ops_c30_s2_stall(b_rcu_lane_ops_c30_s2_stall),
    .rcu_lane_ops_c30_s3_valid(b_rcu_lane_ops_c30_s3_valid),
    .rcu_lane_ops_c30_s3_payload(b_rcu_lane_ops_c30_s3_payload),
    .rcu_lane_ops_c30_s3_credit(b_rcu_lane_ops_c30_s3_credit),
    .rcu_lane_ops_c30_s3_stall(b_rcu_lane_ops_c30_s3_stall),
    .rcu_lane_ops_c30_wake(b_rcu_lane_ops_c30_wake),
    .rcu_lane_ops_c31_s0_valid(b_rcu_lane_ops_c31_s0_valid),
    .rcu_lane_ops_c31_s0_payload(b_rcu_lane_ops_c31_s0_payload),
    .rcu_lane_ops_c31_s0_credit(b_rcu_lane_ops_c31_s0_credit),
    .rcu_lane_ops_c31_s0_stall(b_rcu_lane_ops_c31_s0_stall),
    .rcu_lane_ops_c31_s1_valid(b_rcu_lane_ops_c31_s1_valid),
    .rcu_lane_ops_c31_s1_payload(b_rcu_lane_ops_c31_s1_payload),
    .rcu_lane_ops_c31_s1_credit(b_rcu_lane_ops_c31_s1_credit),
    .rcu_lane_ops_c31_s1_stall(b_rcu_lane_ops_c31_s1_stall),
    .rcu_lane_ops_c31_s2_valid(b_rcu_lane_ops_c31_s2_valid),
    .rcu_lane_ops_c31_s2_payload(b_rcu_lane_ops_c31_s2_payload),
    .rcu_lane_ops_c31_s2_credit(b_rcu_lane_ops_c31_s2_credit),
    .rcu_lane_ops_c31_s2_stall(b_rcu_lane_ops_c31_s2_stall),
    .rcu_lane_ops_c31_s3_valid(b_rcu_lane_ops_c31_s3_valid),
    .rcu_lane_ops_c31_s3_payload(b_rcu_lane_ops_c31_s3_payload),
    .rcu_lane_ops_c31_s3_credit(b_rcu_lane_ops_c31_s3_credit),
    .rcu_lane_ops_c31_s3_stall(b_rcu_lane_ops_c31_s3_stall),
    .rcu_lane_ops_c31_wake(b_rcu_lane_ops_c31_wake),
    .lane_rcu_res_c00_s0_valid(b_lane_rcu_res_c00_s0_valid),
    .lane_rcu_res_c00_s0_payload(b_lane_rcu_res_c00_s0_payload),
    .lane_rcu_res_c00_s0_credit(b_lane_rcu_res_c00_s0_credit),
    .lane_rcu_res_c00_s0_stall(b_lane_rcu_res_c00_s0_stall),
    .lane_rcu_res_c00_s1_valid(b_lane_rcu_res_c00_s1_valid),
    .lane_rcu_res_c00_s1_payload(b_lane_rcu_res_c00_s1_payload),
    .lane_rcu_res_c00_s1_credit(b_lane_rcu_res_c00_s1_credit),
    .lane_rcu_res_c00_s1_stall(b_lane_rcu_res_c00_s1_stall),
    .lane_rcu_res_c00_s2_valid(b_lane_rcu_res_c00_s2_valid),
    .lane_rcu_res_c00_s2_payload(b_lane_rcu_res_c00_s2_payload),
    .lane_rcu_res_c00_s2_credit(b_lane_rcu_res_c00_s2_credit),
    .lane_rcu_res_c00_s2_stall(b_lane_rcu_res_c00_s2_stall),
    .lane_rcu_res_c00_s3_valid(b_lane_rcu_res_c00_s3_valid),
    .lane_rcu_res_c00_s3_payload(b_lane_rcu_res_c00_s3_payload),
    .lane_rcu_res_c00_s3_credit(b_lane_rcu_res_c00_s3_credit),
    .lane_rcu_res_c00_s3_stall(b_lane_rcu_res_c00_s3_stall),
    .lane_rcu_res_c00_wake(b_lane_rcu_res_c00_wake),
    .lane_rcu_res_c01_s0_valid(b_lane_rcu_res_c01_s0_valid),
    .lane_rcu_res_c01_s0_payload(b_lane_rcu_res_c01_s0_payload),
    .lane_rcu_res_c01_s0_credit(b_lane_rcu_res_c01_s0_credit),
    .lane_rcu_res_c01_s0_stall(b_lane_rcu_res_c01_s0_stall),
    .lane_rcu_res_c01_s1_valid(b_lane_rcu_res_c01_s1_valid),
    .lane_rcu_res_c01_s1_payload(b_lane_rcu_res_c01_s1_payload),
    .lane_rcu_res_c01_s1_credit(b_lane_rcu_res_c01_s1_credit),
    .lane_rcu_res_c01_s1_stall(b_lane_rcu_res_c01_s1_stall),
    .lane_rcu_res_c01_s2_valid(b_lane_rcu_res_c01_s2_valid),
    .lane_rcu_res_c01_s2_payload(b_lane_rcu_res_c01_s2_payload),
    .lane_rcu_res_c01_s2_credit(b_lane_rcu_res_c01_s2_credit),
    .lane_rcu_res_c01_s2_stall(b_lane_rcu_res_c01_s2_stall),
    .lane_rcu_res_c01_s3_valid(b_lane_rcu_res_c01_s3_valid),
    .lane_rcu_res_c01_s3_payload(b_lane_rcu_res_c01_s3_payload),
    .lane_rcu_res_c01_s3_credit(b_lane_rcu_res_c01_s3_credit),
    .lane_rcu_res_c01_s3_stall(b_lane_rcu_res_c01_s3_stall),
    .lane_rcu_res_c01_wake(b_lane_rcu_res_c01_wake),
    .lane_rcu_res_c02_s0_valid(b_lane_rcu_res_c02_s0_valid),
    .lane_rcu_res_c02_s0_payload(b_lane_rcu_res_c02_s0_payload),
    .lane_rcu_res_c02_s0_credit(b_lane_rcu_res_c02_s0_credit),
    .lane_rcu_res_c02_s0_stall(b_lane_rcu_res_c02_s0_stall),
    .lane_rcu_res_c02_s1_valid(b_lane_rcu_res_c02_s1_valid),
    .lane_rcu_res_c02_s1_payload(b_lane_rcu_res_c02_s1_payload),
    .lane_rcu_res_c02_s1_credit(b_lane_rcu_res_c02_s1_credit),
    .lane_rcu_res_c02_s1_stall(b_lane_rcu_res_c02_s1_stall),
    .lane_rcu_res_c02_s2_valid(b_lane_rcu_res_c02_s2_valid),
    .lane_rcu_res_c02_s2_payload(b_lane_rcu_res_c02_s2_payload),
    .lane_rcu_res_c02_s2_credit(b_lane_rcu_res_c02_s2_credit),
    .lane_rcu_res_c02_s2_stall(b_lane_rcu_res_c02_s2_stall),
    .lane_rcu_res_c02_s3_valid(b_lane_rcu_res_c02_s3_valid),
    .lane_rcu_res_c02_s3_payload(b_lane_rcu_res_c02_s3_payload),
    .lane_rcu_res_c02_s3_credit(b_lane_rcu_res_c02_s3_credit),
    .lane_rcu_res_c02_s3_stall(b_lane_rcu_res_c02_s3_stall),
    .lane_rcu_res_c02_wake(b_lane_rcu_res_c02_wake),
    .lane_rcu_res_c03_s0_valid(b_lane_rcu_res_c03_s0_valid),
    .lane_rcu_res_c03_s0_payload(b_lane_rcu_res_c03_s0_payload),
    .lane_rcu_res_c03_s0_credit(b_lane_rcu_res_c03_s0_credit),
    .lane_rcu_res_c03_s0_stall(b_lane_rcu_res_c03_s0_stall),
    .lane_rcu_res_c03_s1_valid(b_lane_rcu_res_c03_s1_valid),
    .lane_rcu_res_c03_s1_payload(b_lane_rcu_res_c03_s1_payload),
    .lane_rcu_res_c03_s1_credit(b_lane_rcu_res_c03_s1_credit),
    .lane_rcu_res_c03_s1_stall(b_lane_rcu_res_c03_s1_stall),
    .lane_rcu_res_c03_s2_valid(b_lane_rcu_res_c03_s2_valid),
    .lane_rcu_res_c03_s2_payload(b_lane_rcu_res_c03_s2_payload),
    .lane_rcu_res_c03_s2_credit(b_lane_rcu_res_c03_s2_credit),
    .lane_rcu_res_c03_s2_stall(b_lane_rcu_res_c03_s2_stall),
    .lane_rcu_res_c03_s3_valid(b_lane_rcu_res_c03_s3_valid),
    .lane_rcu_res_c03_s3_payload(b_lane_rcu_res_c03_s3_payload),
    .lane_rcu_res_c03_s3_credit(b_lane_rcu_res_c03_s3_credit),
    .lane_rcu_res_c03_s3_stall(b_lane_rcu_res_c03_s3_stall),
    .lane_rcu_res_c03_wake(b_lane_rcu_res_c03_wake),
    .lane_rcu_res_c04_s0_valid(b_lane_rcu_res_c04_s0_valid),
    .lane_rcu_res_c04_s0_payload(b_lane_rcu_res_c04_s0_payload),
    .lane_rcu_res_c04_s0_credit(b_lane_rcu_res_c04_s0_credit),
    .lane_rcu_res_c04_s0_stall(b_lane_rcu_res_c04_s0_stall),
    .lane_rcu_res_c04_s1_valid(b_lane_rcu_res_c04_s1_valid),
    .lane_rcu_res_c04_s1_payload(b_lane_rcu_res_c04_s1_payload),
    .lane_rcu_res_c04_s1_credit(b_lane_rcu_res_c04_s1_credit),
    .lane_rcu_res_c04_s1_stall(b_lane_rcu_res_c04_s1_stall),
    .lane_rcu_res_c04_s2_valid(b_lane_rcu_res_c04_s2_valid),
    .lane_rcu_res_c04_s2_payload(b_lane_rcu_res_c04_s2_payload),
    .lane_rcu_res_c04_s2_credit(b_lane_rcu_res_c04_s2_credit),
    .lane_rcu_res_c04_s2_stall(b_lane_rcu_res_c04_s2_stall),
    .lane_rcu_res_c04_s3_valid(b_lane_rcu_res_c04_s3_valid),
    .lane_rcu_res_c04_s3_payload(b_lane_rcu_res_c04_s3_payload),
    .lane_rcu_res_c04_s3_credit(b_lane_rcu_res_c04_s3_credit),
    .lane_rcu_res_c04_s3_stall(b_lane_rcu_res_c04_s3_stall),
    .lane_rcu_res_c04_wake(b_lane_rcu_res_c04_wake),
    .lane_rcu_res_c05_s0_valid(b_lane_rcu_res_c05_s0_valid),
    .lane_rcu_res_c05_s0_payload(b_lane_rcu_res_c05_s0_payload),
    .lane_rcu_res_c05_s0_credit(b_lane_rcu_res_c05_s0_credit),
    .lane_rcu_res_c05_s0_stall(b_lane_rcu_res_c05_s0_stall),
    .lane_rcu_res_c05_s1_valid(b_lane_rcu_res_c05_s1_valid),
    .lane_rcu_res_c05_s1_payload(b_lane_rcu_res_c05_s1_payload),
    .lane_rcu_res_c05_s1_credit(b_lane_rcu_res_c05_s1_credit),
    .lane_rcu_res_c05_s1_stall(b_lane_rcu_res_c05_s1_stall),
    .lane_rcu_res_c05_s2_valid(b_lane_rcu_res_c05_s2_valid),
    .lane_rcu_res_c05_s2_payload(b_lane_rcu_res_c05_s2_payload),
    .lane_rcu_res_c05_s2_credit(b_lane_rcu_res_c05_s2_credit),
    .lane_rcu_res_c05_s2_stall(b_lane_rcu_res_c05_s2_stall),
    .lane_rcu_res_c05_s3_valid(b_lane_rcu_res_c05_s3_valid),
    .lane_rcu_res_c05_s3_payload(b_lane_rcu_res_c05_s3_payload),
    .lane_rcu_res_c05_s3_credit(b_lane_rcu_res_c05_s3_credit),
    .lane_rcu_res_c05_s3_stall(b_lane_rcu_res_c05_s3_stall),
    .lane_rcu_res_c05_wake(b_lane_rcu_res_c05_wake),
    .lane_rcu_res_c06_s0_valid(b_lane_rcu_res_c06_s0_valid),
    .lane_rcu_res_c06_s0_payload(b_lane_rcu_res_c06_s0_payload),
    .lane_rcu_res_c06_s0_credit(b_lane_rcu_res_c06_s0_credit),
    .lane_rcu_res_c06_s0_stall(b_lane_rcu_res_c06_s0_stall),
    .lane_rcu_res_c06_s1_valid(b_lane_rcu_res_c06_s1_valid),
    .lane_rcu_res_c06_s1_payload(b_lane_rcu_res_c06_s1_payload),
    .lane_rcu_res_c06_s1_credit(b_lane_rcu_res_c06_s1_credit),
    .lane_rcu_res_c06_s1_stall(b_lane_rcu_res_c06_s1_stall),
    .lane_rcu_res_c06_s2_valid(b_lane_rcu_res_c06_s2_valid),
    .lane_rcu_res_c06_s2_payload(b_lane_rcu_res_c06_s2_payload),
    .lane_rcu_res_c06_s2_credit(b_lane_rcu_res_c06_s2_credit),
    .lane_rcu_res_c06_s2_stall(b_lane_rcu_res_c06_s2_stall),
    .lane_rcu_res_c06_s3_valid(b_lane_rcu_res_c06_s3_valid),
    .lane_rcu_res_c06_s3_payload(b_lane_rcu_res_c06_s3_payload),
    .lane_rcu_res_c06_s3_credit(b_lane_rcu_res_c06_s3_credit),
    .lane_rcu_res_c06_s3_stall(b_lane_rcu_res_c06_s3_stall),
    .lane_rcu_res_c06_wake(b_lane_rcu_res_c06_wake),
    .lane_rcu_res_c07_s0_valid(b_lane_rcu_res_c07_s0_valid),
    .lane_rcu_res_c07_s0_payload(b_lane_rcu_res_c07_s0_payload),
    .lane_rcu_res_c07_s0_credit(b_lane_rcu_res_c07_s0_credit),
    .lane_rcu_res_c07_s0_stall(b_lane_rcu_res_c07_s0_stall),
    .lane_rcu_res_c07_s1_valid(b_lane_rcu_res_c07_s1_valid),
    .lane_rcu_res_c07_s1_payload(b_lane_rcu_res_c07_s1_payload),
    .lane_rcu_res_c07_s1_credit(b_lane_rcu_res_c07_s1_credit),
    .lane_rcu_res_c07_s1_stall(b_lane_rcu_res_c07_s1_stall),
    .lane_rcu_res_c07_s2_valid(b_lane_rcu_res_c07_s2_valid),
    .lane_rcu_res_c07_s2_payload(b_lane_rcu_res_c07_s2_payload),
    .lane_rcu_res_c07_s2_credit(b_lane_rcu_res_c07_s2_credit),
    .lane_rcu_res_c07_s2_stall(b_lane_rcu_res_c07_s2_stall),
    .lane_rcu_res_c07_s3_valid(b_lane_rcu_res_c07_s3_valid),
    .lane_rcu_res_c07_s3_payload(b_lane_rcu_res_c07_s3_payload),
    .lane_rcu_res_c07_s3_credit(b_lane_rcu_res_c07_s3_credit),
    .lane_rcu_res_c07_s3_stall(b_lane_rcu_res_c07_s3_stall),
    .lane_rcu_res_c07_wake(b_lane_rcu_res_c07_wake),
    .lane_rcu_res_c08_s0_valid(b_lane_rcu_res_c08_s0_valid),
    .lane_rcu_res_c08_s0_payload(b_lane_rcu_res_c08_s0_payload),
    .lane_rcu_res_c08_s0_credit(b_lane_rcu_res_c08_s0_credit),
    .lane_rcu_res_c08_s0_stall(b_lane_rcu_res_c08_s0_stall),
    .lane_rcu_res_c08_s1_valid(b_lane_rcu_res_c08_s1_valid),
    .lane_rcu_res_c08_s1_payload(b_lane_rcu_res_c08_s1_payload),
    .lane_rcu_res_c08_s1_credit(b_lane_rcu_res_c08_s1_credit),
    .lane_rcu_res_c08_s1_stall(b_lane_rcu_res_c08_s1_stall),
    .lane_rcu_res_c08_s2_valid(b_lane_rcu_res_c08_s2_valid),
    .lane_rcu_res_c08_s2_payload(b_lane_rcu_res_c08_s2_payload),
    .lane_rcu_res_c08_s2_credit(b_lane_rcu_res_c08_s2_credit),
    .lane_rcu_res_c08_s2_stall(b_lane_rcu_res_c08_s2_stall),
    .lane_rcu_res_c08_s3_valid(b_lane_rcu_res_c08_s3_valid),
    .lane_rcu_res_c08_s3_payload(b_lane_rcu_res_c08_s3_payload),
    .lane_rcu_res_c08_s3_credit(b_lane_rcu_res_c08_s3_credit),
    .lane_rcu_res_c08_s3_stall(b_lane_rcu_res_c08_s3_stall),
    .lane_rcu_res_c08_wake(b_lane_rcu_res_c08_wake),
    .lane_rcu_res_c09_s0_valid(b_lane_rcu_res_c09_s0_valid),
    .lane_rcu_res_c09_s0_payload(b_lane_rcu_res_c09_s0_payload),
    .lane_rcu_res_c09_s0_credit(b_lane_rcu_res_c09_s0_credit),
    .lane_rcu_res_c09_s0_stall(b_lane_rcu_res_c09_s0_stall),
    .lane_rcu_res_c09_s1_valid(b_lane_rcu_res_c09_s1_valid),
    .lane_rcu_res_c09_s1_payload(b_lane_rcu_res_c09_s1_payload),
    .lane_rcu_res_c09_s1_credit(b_lane_rcu_res_c09_s1_credit),
    .lane_rcu_res_c09_s1_stall(b_lane_rcu_res_c09_s1_stall),
    .lane_rcu_res_c09_s2_valid(b_lane_rcu_res_c09_s2_valid),
    .lane_rcu_res_c09_s2_payload(b_lane_rcu_res_c09_s2_payload),
    .lane_rcu_res_c09_s2_credit(b_lane_rcu_res_c09_s2_credit),
    .lane_rcu_res_c09_s2_stall(b_lane_rcu_res_c09_s2_stall),
    .lane_rcu_res_c09_s3_valid(b_lane_rcu_res_c09_s3_valid),
    .lane_rcu_res_c09_s3_payload(b_lane_rcu_res_c09_s3_payload),
    .lane_rcu_res_c09_s3_credit(b_lane_rcu_res_c09_s3_credit),
    .lane_rcu_res_c09_s3_stall(b_lane_rcu_res_c09_s3_stall),
    .lane_rcu_res_c09_wake(b_lane_rcu_res_c09_wake),
    .lane_rcu_res_c10_s0_valid(b_lane_rcu_res_c10_s0_valid),
    .lane_rcu_res_c10_s0_payload(b_lane_rcu_res_c10_s0_payload),
    .lane_rcu_res_c10_s0_credit(b_lane_rcu_res_c10_s0_credit),
    .lane_rcu_res_c10_s0_stall(b_lane_rcu_res_c10_s0_stall),
    .lane_rcu_res_c10_s1_valid(b_lane_rcu_res_c10_s1_valid),
    .lane_rcu_res_c10_s1_payload(b_lane_rcu_res_c10_s1_payload),
    .lane_rcu_res_c10_s1_credit(b_lane_rcu_res_c10_s1_credit),
    .lane_rcu_res_c10_s1_stall(b_lane_rcu_res_c10_s1_stall),
    .lane_rcu_res_c10_s2_valid(b_lane_rcu_res_c10_s2_valid),
    .lane_rcu_res_c10_s2_payload(b_lane_rcu_res_c10_s2_payload),
    .lane_rcu_res_c10_s2_credit(b_lane_rcu_res_c10_s2_credit),
    .lane_rcu_res_c10_s2_stall(b_lane_rcu_res_c10_s2_stall),
    .lane_rcu_res_c10_s3_valid(b_lane_rcu_res_c10_s3_valid),
    .lane_rcu_res_c10_s3_payload(b_lane_rcu_res_c10_s3_payload),
    .lane_rcu_res_c10_s3_credit(b_lane_rcu_res_c10_s3_credit),
    .lane_rcu_res_c10_s3_stall(b_lane_rcu_res_c10_s3_stall),
    .lane_rcu_res_c10_wake(b_lane_rcu_res_c10_wake),
    .lane_rcu_res_c11_s0_valid(b_lane_rcu_res_c11_s0_valid),
    .lane_rcu_res_c11_s0_payload(b_lane_rcu_res_c11_s0_payload),
    .lane_rcu_res_c11_s0_credit(b_lane_rcu_res_c11_s0_credit),
    .lane_rcu_res_c11_s0_stall(b_lane_rcu_res_c11_s0_stall),
    .lane_rcu_res_c11_s1_valid(b_lane_rcu_res_c11_s1_valid),
    .lane_rcu_res_c11_s1_payload(b_lane_rcu_res_c11_s1_payload),
    .lane_rcu_res_c11_s1_credit(b_lane_rcu_res_c11_s1_credit),
    .lane_rcu_res_c11_s1_stall(b_lane_rcu_res_c11_s1_stall),
    .lane_rcu_res_c11_s2_valid(b_lane_rcu_res_c11_s2_valid),
    .lane_rcu_res_c11_s2_payload(b_lane_rcu_res_c11_s2_payload),
    .lane_rcu_res_c11_s2_credit(b_lane_rcu_res_c11_s2_credit),
    .lane_rcu_res_c11_s2_stall(b_lane_rcu_res_c11_s2_stall),
    .lane_rcu_res_c11_s3_valid(b_lane_rcu_res_c11_s3_valid),
    .lane_rcu_res_c11_s3_payload(b_lane_rcu_res_c11_s3_payload),
    .lane_rcu_res_c11_s3_credit(b_lane_rcu_res_c11_s3_credit),
    .lane_rcu_res_c11_s3_stall(b_lane_rcu_res_c11_s3_stall),
    .lane_rcu_res_c11_wake(b_lane_rcu_res_c11_wake),
    .lane_rcu_res_c12_s0_valid(b_lane_rcu_res_c12_s0_valid),
    .lane_rcu_res_c12_s0_payload(b_lane_rcu_res_c12_s0_payload),
    .lane_rcu_res_c12_s0_credit(b_lane_rcu_res_c12_s0_credit),
    .lane_rcu_res_c12_s0_stall(b_lane_rcu_res_c12_s0_stall),
    .lane_rcu_res_c12_s1_valid(b_lane_rcu_res_c12_s1_valid),
    .lane_rcu_res_c12_s1_payload(b_lane_rcu_res_c12_s1_payload),
    .lane_rcu_res_c12_s1_credit(b_lane_rcu_res_c12_s1_credit),
    .lane_rcu_res_c12_s1_stall(b_lane_rcu_res_c12_s1_stall),
    .lane_rcu_res_c12_s2_valid(b_lane_rcu_res_c12_s2_valid),
    .lane_rcu_res_c12_s2_payload(b_lane_rcu_res_c12_s2_payload),
    .lane_rcu_res_c12_s2_credit(b_lane_rcu_res_c12_s2_credit),
    .lane_rcu_res_c12_s2_stall(b_lane_rcu_res_c12_s2_stall),
    .lane_rcu_res_c12_s3_valid(b_lane_rcu_res_c12_s3_valid),
    .lane_rcu_res_c12_s3_payload(b_lane_rcu_res_c12_s3_payload),
    .lane_rcu_res_c12_s3_credit(b_lane_rcu_res_c12_s3_credit),
    .lane_rcu_res_c12_s3_stall(b_lane_rcu_res_c12_s3_stall),
    .lane_rcu_res_c12_wake(b_lane_rcu_res_c12_wake),
    .lane_rcu_res_c13_s0_valid(b_lane_rcu_res_c13_s0_valid),
    .lane_rcu_res_c13_s0_payload(b_lane_rcu_res_c13_s0_payload),
    .lane_rcu_res_c13_s0_credit(b_lane_rcu_res_c13_s0_credit),
    .lane_rcu_res_c13_s0_stall(b_lane_rcu_res_c13_s0_stall),
    .lane_rcu_res_c13_s1_valid(b_lane_rcu_res_c13_s1_valid),
    .lane_rcu_res_c13_s1_payload(b_lane_rcu_res_c13_s1_payload),
    .lane_rcu_res_c13_s1_credit(b_lane_rcu_res_c13_s1_credit),
    .lane_rcu_res_c13_s1_stall(b_lane_rcu_res_c13_s1_stall),
    .lane_rcu_res_c13_s2_valid(b_lane_rcu_res_c13_s2_valid),
    .lane_rcu_res_c13_s2_payload(b_lane_rcu_res_c13_s2_payload),
    .lane_rcu_res_c13_s2_credit(b_lane_rcu_res_c13_s2_credit),
    .lane_rcu_res_c13_s2_stall(b_lane_rcu_res_c13_s2_stall),
    .lane_rcu_res_c13_s3_valid(b_lane_rcu_res_c13_s3_valid),
    .lane_rcu_res_c13_s3_payload(b_lane_rcu_res_c13_s3_payload),
    .lane_rcu_res_c13_s3_credit(b_lane_rcu_res_c13_s3_credit),
    .lane_rcu_res_c13_s3_stall(b_lane_rcu_res_c13_s3_stall),
    .lane_rcu_res_c13_wake(b_lane_rcu_res_c13_wake),
    .lane_rcu_res_c14_s0_valid(b_lane_rcu_res_c14_s0_valid),
    .lane_rcu_res_c14_s0_payload(b_lane_rcu_res_c14_s0_payload),
    .lane_rcu_res_c14_s0_credit(b_lane_rcu_res_c14_s0_credit),
    .lane_rcu_res_c14_s0_stall(b_lane_rcu_res_c14_s0_stall),
    .lane_rcu_res_c14_s1_valid(b_lane_rcu_res_c14_s1_valid),
    .lane_rcu_res_c14_s1_payload(b_lane_rcu_res_c14_s1_payload),
    .lane_rcu_res_c14_s1_credit(b_lane_rcu_res_c14_s1_credit),
    .lane_rcu_res_c14_s1_stall(b_lane_rcu_res_c14_s1_stall),
    .lane_rcu_res_c14_s2_valid(b_lane_rcu_res_c14_s2_valid),
    .lane_rcu_res_c14_s2_payload(b_lane_rcu_res_c14_s2_payload),
    .lane_rcu_res_c14_s2_credit(b_lane_rcu_res_c14_s2_credit),
    .lane_rcu_res_c14_s2_stall(b_lane_rcu_res_c14_s2_stall),
    .lane_rcu_res_c14_s3_valid(b_lane_rcu_res_c14_s3_valid),
    .lane_rcu_res_c14_s3_payload(b_lane_rcu_res_c14_s3_payload),
    .lane_rcu_res_c14_s3_credit(b_lane_rcu_res_c14_s3_credit),
    .lane_rcu_res_c14_s3_stall(b_lane_rcu_res_c14_s3_stall),
    .lane_rcu_res_c14_wake(b_lane_rcu_res_c14_wake),
    .lane_rcu_res_c15_s0_valid(b_lane_rcu_res_c15_s0_valid),
    .lane_rcu_res_c15_s0_payload(b_lane_rcu_res_c15_s0_payload),
    .lane_rcu_res_c15_s0_credit(b_lane_rcu_res_c15_s0_credit),
    .lane_rcu_res_c15_s0_stall(b_lane_rcu_res_c15_s0_stall),
    .lane_rcu_res_c15_s1_valid(b_lane_rcu_res_c15_s1_valid),
    .lane_rcu_res_c15_s1_payload(b_lane_rcu_res_c15_s1_payload),
    .lane_rcu_res_c15_s1_credit(b_lane_rcu_res_c15_s1_credit),
    .lane_rcu_res_c15_s1_stall(b_lane_rcu_res_c15_s1_stall),
    .lane_rcu_res_c15_s2_valid(b_lane_rcu_res_c15_s2_valid),
    .lane_rcu_res_c15_s2_payload(b_lane_rcu_res_c15_s2_payload),
    .lane_rcu_res_c15_s2_credit(b_lane_rcu_res_c15_s2_credit),
    .lane_rcu_res_c15_s2_stall(b_lane_rcu_res_c15_s2_stall),
    .lane_rcu_res_c15_s3_valid(b_lane_rcu_res_c15_s3_valid),
    .lane_rcu_res_c15_s3_payload(b_lane_rcu_res_c15_s3_payload),
    .lane_rcu_res_c15_s3_credit(b_lane_rcu_res_c15_s3_credit),
    .lane_rcu_res_c15_s3_stall(b_lane_rcu_res_c15_s3_stall),
    .lane_rcu_res_c15_wake(b_lane_rcu_res_c15_wake),
    .lane_rcu_res_c16_s0_valid(b_lane_rcu_res_c16_s0_valid),
    .lane_rcu_res_c16_s0_payload(b_lane_rcu_res_c16_s0_payload),
    .lane_rcu_res_c16_s0_credit(b_lane_rcu_res_c16_s0_credit),
    .lane_rcu_res_c16_s0_stall(b_lane_rcu_res_c16_s0_stall),
    .lane_rcu_res_c16_s1_valid(b_lane_rcu_res_c16_s1_valid),
    .lane_rcu_res_c16_s1_payload(b_lane_rcu_res_c16_s1_payload),
    .lane_rcu_res_c16_s1_credit(b_lane_rcu_res_c16_s1_credit),
    .lane_rcu_res_c16_s1_stall(b_lane_rcu_res_c16_s1_stall),
    .lane_rcu_res_c16_s2_valid(b_lane_rcu_res_c16_s2_valid),
    .lane_rcu_res_c16_s2_payload(b_lane_rcu_res_c16_s2_payload),
    .lane_rcu_res_c16_s2_credit(b_lane_rcu_res_c16_s2_credit),
    .lane_rcu_res_c16_s2_stall(b_lane_rcu_res_c16_s2_stall),
    .lane_rcu_res_c16_s3_valid(b_lane_rcu_res_c16_s3_valid),
    .lane_rcu_res_c16_s3_payload(b_lane_rcu_res_c16_s3_payload),
    .lane_rcu_res_c16_s3_credit(b_lane_rcu_res_c16_s3_credit),
    .lane_rcu_res_c16_s3_stall(b_lane_rcu_res_c16_s3_stall),
    .lane_rcu_res_c16_wake(b_lane_rcu_res_c16_wake),
    .lane_rcu_res_c17_s0_valid(b_lane_rcu_res_c17_s0_valid),
    .lane_rcu_res_c17_s0_payload(b_lane_rcu_res_c17_s0_payload),
    .lane_rcu_res_c17_s0_credit(b_lane_rcu_res_c17_s0_credit),
    .lane_rcu_res_c17_s0_stall(b_lane_rcu_res_c17_s0_stall),
    .lane_rcu_res_c17_s1_valid(b_lane_rcu_res_c17_s1_valid),
    .lane_rcu_res_c17_s1_payload(b_lane_rcu_res_c17_s1_payload),
    .lane_rcu_res_c17_s1_credit(b_lane_rcu_res_c17_s1_credit),
    .lane_rcu_res_c17_s1_stall(b_lane_rcu_res_c17_s1_stall),
    .lane_rcu_res_c17_s2_valid(b_lane_rcu_res_c17_s2_valid),
    .lane_rcu_res_c17_s2_payload(b_lane_rcu_res_c17_s2_payload),
    .lane_rcu_res_c17_s2_credit(b_lane_rcu_res_c17_s2_credit),
    .lane_rcu_res_c17_s2_stall(b_lane_rcu_res_c17_s2_stall),
    .lane_rcu_res_c17_s3_valid(b_lane_rcu_res_c17_s3_valid),
    .lane_rcu_res_c17_s3_payload(b_lane_rcu_res_c17_s3_payload),
    .lane_rcu_res_c17_s3_credit(b_lane_rcu_res_c17_s3_credit),
    .lane_rcu_res_c17_s3_stall(b_lane_rcu_res_c17_s3_stall),
    .lane_rcu_res_c17_wake(b_lane_rcu_res_c17_wake),
    .lane_rcu_res_c18_s0_valid(b_lane_rcu_res_c18_s0_valid),
    .lane_rcu_res_c18_s0_payload(b_lane_rcu_res_c18_s0_payload),
    .lane_rcu_res_c18_s0_credit(b_lane_rcu_res_c18_s0_credit),
    .lane_rcu_res_c18_s0_stall(b_lane_rcu_res_c18_s0_stall),
    .lane_rcu_res_c18_s1_valid(b_lane_rcu_res_c18_s1_valid),
    .lane_rcu_res_c18_s1_payload(b_lane_rcu_res_c18_s1_payload),
    .lane_rcu_res_c18_s1_credit(b_lane_rcu_res_c18_s1_credit),
    .lane_rcu_res_c18_s1_stall(b_lane_rcu_res_c18_s1_stall),
    .lane_rcu_res_c18_s2_valid(b_lane_rcu_res_c18_s2_valid),
    .lane_rcu_res_c18_s2_payload(b_lane_rcu_res_c18_s2_payload),
    .lane_rcu_res_c18_s2_credit(b_lane_rcu_res_c18_s2_credit),
    .lane_rcu_res_c18_s2_stall(b_lane_rcu_res_c18_s2_stall),
    .lane_rcu_res_c18_s3_valid(b_lane_rcu_res_c18_s3_valid),
    .lane_rcu_res_c18_s3_payload(b_lane_rcu_res_c18_s3_payload),
    .lane_rcu_res_c18_s3_credit(b_lane_rcu_res_c18_s3_credit),
    .lane_rcu_res_c18_s3_stall(b_lane_rcu_res_c18_s3_stall),
    .lane_rcu_res_c18_wake(b_lane_rcu_res_c18_wake),
    .lane_rcu_res_c19_s0_valid(b_lane_rcu_res_c19_s0_valid),
    .lane_rcu_res_c19_s0_payload(b_lane_rcu_res_c19_s0_payload),
    .lane_rcu_res_c19_s0_credit(b_lane_rcu_res_c19_s0_credit),
    .lane_rcu_res_c19_s0_stall(b_lane_rcu_res_c19_s0_stall),
    .lane_rcu_res_c19_s1_valid(b_lane_rcu_res_c19_s1_valid),
    .lane_rcu_res_c19_s1_payload(b_lane_rcu_res_c19_s1_payload),
    .lane_rcu_res_c19_s1_credit(b_lane_rcu_res_c19_s1_credit),
    .lane_rcu_res_c19_s1_stall(b_lane_rcu_res_c19_s1_stall),
    .lane_rcu_res_c19_s2_valid(b_lane_rcu_res_c19_s2_valid),
    .lane_rcu_res_c19_s2_payload(b_lane_rcu_res_c19_s2_payload),
    .lane_rcu_res_c19_s2_credit(b_lane_rcu_res_c19_s2_credit),
    .lane_rcu_res_c19_s2_stall(b_lane_rcu_res_c19_s2_stall),
    .lane_rcu_res_c19_s3_valid(b_lane_rcu_res_c19_s3_valid),
    .lane_rcu_res_c19_s3_payload(b_lane_rcu_res_c19_s3_payload),
    .lane_rcu_res_c19_s3_credit(b_lane_rcu_res_c19_s3_credit),
    .lane_rcu_res_c19_s3_stall(b_lane_rcu_res_c19_s3_stall),
    .lane_rcu_res_c19_wake(b_lane_rcu_res_c19_wake),
    .lane_rcu_res_c20_s0_valid(b_lane_rcu_res_c20_s0_valid),
    .lane_rcu_res_c20_s0_payload(b_lane_rcu_res_c20_s0_payload),
    .lane_rcu_res_c20_s0_credit(b_lane_rcu_res_c20_s0_credit),
    .lane_rcu_res_c20_s0_stall(b_lane_rcu_res_c20_s0_stall),
    .lane_rcu_res_c20_s1_valid(b_lane_rcu_res_c20_s1_valid),
    .lane_rcu_res_c20_s1_payload(b_lane_rcu_res_c20_s1_payload),
    .lane_rcu_res_c20_s1_credit(b_lane_rcu_res_c20_s1_credit),
    .lane_rcu_res_c20_s1_stall(b_lane_rcu_res_c20_s1_stall),
    .lane_rcu_res_c20_s2_valid(b_lane_rcu_res_c20_s2_valid),
    .lane_rcu_res_c20_s2_payload(b_lane_rcu_res_c20_s2_payload),
    .lane_rcu_res_c20_s2_credit(b_lane_rcu_res_c20_s2_credit),
    .lane_rcu_res_c20_s2_stall(b_lane_rcu_res_c20_s2_stall),
    .lane_rcu_res_c20_s3_valid(b_lane_rcu_res_c20_s3_valid),
    .lane_rcu_res_c20_s3_payload(b_lane_rcu_res_c20_s3_payload),
    .lane_rcu_res_c20_s3_credit(b_lane_rcu_res_c20_s3_credit),
    .lane_rcu_res_c20_s3_stall(b_lane_rcu_res_c20_s3_stall),
    .lane_rcu_res_c20_wake(b_lane_rcu_res_c20_wake),
    .lane_rcu_res_c21_s0_valid(b_lane_rcu_res_c21_s0_valid),
    .lane_rcu_res_c21_s0_payload(b_lane_rcu_res_c21_s0_payload),
    .lane_rcu_res_c21_s0_credit(b_lane_rcu_res_c21_s0_credit),
    .lane_rcu_res_c21_s0_stall(b_lane_rcu_res_c21_s0_stall),
    .lane_rcu_res_c21_s1_valid(b_lane_rcu_res_c21_s1_valid),
    .lane_rcu_res_c21_s1_payload(b_lane_rcu_res_c21_s1_payload),
    .lane_rcu_res_c21_s1_credit(b_lane_rcu_res_c21_s1_credit),
    .lane_rcu_res_c21_s1_stall(b_lane_rcu_res_c21_s1_stall),
    .lane_rcu_res_c21_s2_valid(b_lane_rcu_res_c21_s2_valid),
    .lane_rcu_res_c21_s2_payload(b_lane_rcu_res_c21_s2_payload),
    .lane_rcu_res_c21_s2_credit(b_lane_rcu_res_c21_s2_credit),
    .lane_rcu_res_c21_s2_stall(b_lane_rcu_res_c21_s2_stall),
    .lane_rcu_res_c21_s3_valid(b_lane_rcu_res_c21_s3_valid),
    .lane_rcu_res_c21_s3_payload(b_lane_rcu_res_c21_s3_payload),
    .lane_rcu_res_c21_s3_credit(b_lane_rcu_res_c21_s3_credit),
    .lane_rcu_res_c21_s3_stall(b_lane_rcu_res_c21_s3_stall),
    .lane_rcu_res_c21_wake(b_lane_rcu_res_c21_wake),
    .lane_rcu_res_c22_s0_valid(b_lane_rcu_res_c22_s0_valid),
    .lane_rcu_res_c22_s0_payload(b_lane_rcu_res_c22_s0_payload),
    .lane_rcu_res_c22_s0_credit(b_lane_rcu_res_c22_s0_credit),
    .lane_rcu_res_c22_s0_stall(b_lane_rcu_res_c22_s0_stall),
    .lane_rcu_res_c22_s1_valid(b_lane_rcu_res_c22_s1_valid),
    .lane_rcu_res_c22_s1_payload(b_lane_rcu_res_c22_s1_payload),
    .lane_rcu_res_c22_s1_credit(b_lane_rcu_res_c22_s1_credit),
    .lane_rcu_res_c22_s1_stall(b_lane_rcu_res_c22_s1_stall),
    .lane_rcu_res_c22_s2_valid(b_lane_rcu_res_c22_s2_valid),
    .lane_rcu_res_c22_s2_payload(b_lane_rcu_res_c22_s2_payload),
    .lane_rcu_res_c22_s2_credit(b_lane_rcu_res_c22_s2_credit),
    .lane_rcu_res_c22_s2_stall(b_lane_rcu_res_c22_s2_stall),
    .lane_rcu_res_c22_s3_valid(b_lane_rcu_res_c22_s3_valid),
    .lane_rcu_res_c22_s3_payload(b_lane_rcu_res_c22_s3_payload),
    .lane_rcu_res_c22_s3_credit(b_lane_rcu_res_c22_s3_credit),
    .lane_rcu_res_c22_s3_stall(b_lane_rcu_res_c22_s3_stall),
    .lane_rcu_res_c22_wake(b_lane_rcu_res_c22_wake),
    .lane_rcu_res_c23_s0_valid(b_lane_rcu_res_c23_s0_valid),
    .lane_rcu_res_c23_s0_payload(b_lane_rcu_res_c23_s0_payload),
    .lane_rcu_res_c23_s0_credit(b_lane_rcu_res_c23_s0_credit),
    .lane_rcu_res_c23_s0_stall(b_lane_rcu_res_c23_s0_stall),
    .lane_rcu_res_c23_s1_valid(b_lane_rcu_res_c23_s1_valid),
    .lane_rcu_res_c23_s1_payload(b_lane_rcu_res_c23_s1_payload),
    .lane_rcu_res_c23_s1_credit(b_lane_rcu_res_c23_s1_credit),
    .lane_rcu_res_c23_s1_stall(b_lane_rcu_res_c23_s1_stall),
    .lane_rcu_res_c23_s2_valid(b_lane_rcu_res_c23_s2_valid),
    .lane_rcu_res_c23_s2_payload(b_lane_rcu_res_c23_s2_payload),
    .lane_rcu_res_c23_s2_credit(b_lane_rcu_res_c23_s2_credit),
    .lane_rcu_res_c23_s2_stall(b_lane_rcu_res_c23_s2_stall),
    .lane_rcu_res_c23_s3_valid(b_lane_rcu_res_c23_s3_valid),
    .lane_rcu_res_c23_s3_payload(b_lane_rcu_res_c23_s3_payload),
    .lane_rcu_res_c23_s3_credit(b_lane_rcu_res_c23_s3_credit),
    .lane_rcu_res_c23_s3_stall(b_lane_rcu_res_c23_s3_stall),
    .lane_rcu_res_c23_wake(b_lane_rcu_res_c23_wake),
    .lane_rcu_res_c24_s0_valid(b_lane_rcu_res_c24_s0_valid),
    .lane_rcu_res_c24_s0_payload(b_lane_rcu_res_c24_s0_payload),
    .lane_rcu_res_c24_s0_credit(b_lane_rcu_res_c24_s0_credit),
    .lane_rcu_res_c24_s0_stall(b_lane_rcu_res_c24_s0_stall),
    .lane_rcu_res_c24_s1_valid(b_lane_rcu_res_c24_s1_valid),
    .lane_rcu_res_c24_s1_payload(b_lane_rcu_res_c24_s1_payload),
    .lane_rcu_res_c24_s1_credit(b_lane_rcu_res_c24_s1_credit),
    .lane_rcu_res_c24_s1_stall(b_lane_rcu_res_c24_s1_stall),
    .lane_rcu_res_c24_s2_valid(b_lane_rcu_res_c24_s2_valid),
    .lane_rcu_res_c24_s2_payload(b_lane_rcu_res_c24_s2_payload),
    .lane_rcu_res_c24_s2_credit(b_lane_rcu_res_c24_s2_credit),
    .lane_rcu_res_c24_s2_stall(b_lane_rcu_res_c24_s2_stall),
    .lane_rcu_res_c24_s3_valid(b_lane_rcu_res_c24_s3_valid),
    .lane_rcu_res_c24_s3_payload(b_lane_rcu_res_c24_s3_payload),
    .lane_rcu_res_c24_s3_credit(b_lane_rcu_res_c24_s3_credit),
    .lane_rcu_res_c24_s3_stall(b_lane_rcu_res_c24_s3_stall),
    .lane_rcu_res_c24_wake(b_lane_rcu_res_c24_wake),
    .lane_rcu_res_c25_s0_valid(b_lane_rcu_res_c25_s0_valid),
    .lane_rcu_res_c25_s0_payload(b_lane_rcu_res_c25_s0_payload),
    .lane_rcu_res_c25_s0_credit(b_lane_rcu_res_c25_s0_credit),
    .lane_rcu_res_c25_s0_stall(b_lane_rcu_res_c25_s0_stall),
    .lane_rcu_res_c25_s1_valid(b_lane_rcu_res_c25_s1_valid),
    .lane_rcu_res_c25_s1_payload(b_lane_rcu_res_c25_s1_payload),
    .lane_rcu_res_c25_s1_credit(b_lane_rcu_res_c25_s1_credit),
    .lane_rcu_res_c25_s1_stall(b_lane_rcu_res_c25_s1_stall),
    .lane_rcu_res_c25_s2_valid(b_lane_rcu_res_c25_s2_valid),
    .lane_rcu_res_c25_s2_payload(b_lane_rcu_res_c25_s2_payload),
    .lane_rcu_res_c25_s2_credit(b_lane_rcu_res_c25_s2_credit),
    .lane_rcu_res_c25_s2_stall(b_lane_rcu_res_c25_s2_stall),
    .lane_rcu_res_c25_s3_valid(b_lane_rcu_res_c25_s3_valid),
    .lane_rcu_res_c25_s3_payload(b_lane_rcu_res_c25_s3_payload),
    .lane_rcu_res_c25_s3_credit(b_lane_rcu_res_c25_s3_credit),
    .lane_rcu_res_c25_s3_stall(b_lane_rcu_res_c25_s3_stall),
    .lane_rcu_res_c25_wake(b_lane_rcu_res_c25_wake),
    .lane_rcu_res_c26_s0_valid(b_lane_rcu_res_c26_s0_valid),
    .lane_rcu_res_c26_s0_payload(b_lane_rcu_res_c26_s0_payload),
    .lane_rcu_res_c26_s0_credit(b_lane_rcu_res_c26_s0_credit),
    .lane_rcu_res_c26_s0_stall(b_lane_rcu_res_c26_s0_stall),
    .lane_rcu_res_c26_s1_valid(b_lane_rcu_res_c26_s1_valid),
    .lane_rcu_res_c26_s1_payload(b_lane_rcu_res_c26_s1_payload),
    .lane_rcu_res_c26_s1_credit(b_lane_rcu_res_c26_s1_credit),
    .lane_rcu_res_c26_s1_stall(b_lane_rcu_res_c26_s1_stall),
    .lane_rcu_res_c26_s2_valid(b_lane_rcu_res_c26_s2_valid),
    .lane_rcu_res_c26_s2_payload(b_lane_rcu_res_c26_s2_payload),
    .lane_rcu_res_c26_s2_credit(b_lane_rcu_res_c26_s2_credit),
    .lane_rcu_res_c26_s2_stall(b_lane_rcu_res_c26_s2_stall),
    .lane_rcu_res_c26_s3_valid(b_lane_rcu_res_c26_s3_valid),
    .lane_rcu_res_c26_s3_payload(b_lane_rcu_res_c26_s3_payload),
    .lane_rcu_res_c26_s3_credit(b_lane_rcu_res_c26_s3_credit),
    .lane_rcu_res_c26_s3_stall(b_lane_rcu_res_c26_s3_stall),
    .lane_rcu_res_c26_wake(b_lane_rcu_res_c26_wake),
    .lane_rcu_res_c27_s0_valid(b_lane_rcu_res_c27_s0_valid),
    .lane_rcu_res_c27_s0_payload(b_lane_rcu_res_c27_s0_payload),
    .lane_rcu_res_c27_s0_credit(b_lane_rcu_res_c27_s0_credit),
    .lane_rcu_res_c27_s0_stall(b_lane_rcu_res_c27_s0_stall),
    .lane_rcu_res_c27_s1_valid(b_lane_rcu_res_c27_s1_valid),
    .lane_rcu_res_c27_s1_payload(b_lane_rcu_res_c27_s1_payload),
    .lane_rcu_res_c27_s1_credit(b_lane_rcu_res_c27_s1_credit),
    .lane_rcu_res_c27_s1_stall(b_lane_rcu_res_c27_s1_stall),
    .lane_rcu_res_c27_s2_valid(b_lane_rcu_res_c27_s2_valid),
    .lane_rcu_res_c27_s2_payload(b_lane_rcu_res_c27_s2_payload),
    .lane_rcu_res_c27_s2_credit(b_lane_rcu_res_c27_s2_credit),
    .lane_rcu_res_c27_s2_stall(b_lane_rcu_res_c27_s2_stall),
    .lane_rcu_res_c27_s3_valid(b_lane_rcu_res_c27_s3_valid),
    .lane_rcu_res_c27_s3_payload(b_lane_rcu_res_c27_s3_payload),
    .lane_rcu_res_c27_s3_credit(b_lane_rcu_res_c27_s3_credit),
    .lane_rcu_res_c27_s3_stall(b_lane_rcu_res_c27_s3_stall),
    .lane_rcu_res_c27_wake(b_lane_rcu_res_c27_wake),
    .lane_rcu_res_c28_s0_valid(b_lane_rcu_res_c28_s0_valid),
    .lane_rcu_res_c28_s0_payload(b_lane_rcu_res_c28_s0_payload),
    .lane_rcu_res_c28_s0_credit(b_lane_rcu_res_c28_s0_credit),
    .lane_rcu_res_c28_s0_stall(b_lane_rcu_res_c28_s0_stall),
    .lane_rcu_res_c28_s1_valid(b_lane_rcu_res_c28_s1_valid),
    .lane_rcu_res_c28_s1_payload(b_lane_rcu_res_c28_s1_payload),
    .lane_rcu_res_c28_s1_credit(b_lane_rcu_res_c28_s1_credit),
    .lane_rcu_res_c28_s1_stall(b_lane_rcu_res_c28_s1_stall),
    .lane_rcu_res_c28_s2_valid(b_lane_rcu_res_c28_s2_valid),
    .lane_rcu_res_c28_s2_payload(b_lane_rcu_res_c28_s2_payload),
    .lane_rcu_res_c28_s2_credit(b_lane_rcu_res_c28_s2_credit),
    .lane_rcu_res_c28_s2_stall(b_lane_rcu_res_c28_s2_stall),
    .lane_rcu_res_c28_s3_valid(b_lane_rcu_res_c28_s3_valid),
    .lane_rcu_res_c28_s3_payload(b_lane_rcu_res_c28_s3_payload),
    .lane_rcu_res_c28_s3_credit(b_lane_rcu_res_c28_s3_credit),
    .lane_rcu_res_c28_s3_stall(b_lane_rcu_res_c28_s3_stall),
    .lane_rcu_res_c28_wake(b_lane_rcu_res_c28_wake),
    .lane_rcu_res_c29_s0_valid(b_lane_rcu_res_c29_s0_valid),
    .lane_rcu_res_c29_s0_payload(b_lane_rcu_res_c29_s0_payload),
    .lane_rcu_res_c29_s0_credit(b_lane_rcu_res_c29_s0_credit),
    .lane_rcu_res_c29_s0_stall(b_lane_rcu_res_c29_s0_stall),
    .lane_rcu_res_c29_s1_valid(b_lane_rcu_res_c29_s1_valid),
    .lane_rcu_res_c29_s1_payload(b_lane_rcu_res_c29_s1_payload),
    .lane_rcu_res_c29_s1_credit(b_lane_rcu_res_c29_s1_credit),
    .lane_rcu_res_c29_s1_stall(b_lane_rcu_res_c29_s1_stall),
    .lane_rcu_res_c29_s2_valid(b_lane_rcu_res_c29_s2_valid),
    .lane_rcu_res_c29_s2_payload(b_lane_rcu_res_c29_s2_payload),
    .lane_rcu_res_c29_s2_credit(b_lane_rcu_res_c29_s2_credit),
    .lane_rcu_res_c29_s2_stall(b_lane_rcu_res_c29_s2_stall),
    .lane_rcu_res_c29_s3_valid(b_lane_rcu_res_c29_s3_valid),
    .lane_rcu_res_c29_s3_payload(b_lane_rcu_res_c29_s3_payload),
    .lane_rcu_res_c29_s3_credit(b_lane_rcu_res_c29_s3_credit),
    .lane_rcu_res_c29_s3_stall(b_lane_rcu_res_c29_s3_stall),
    .lane_rcu_res_c29_wake(b_lane_rcu_res_c29_wake),
    .lane_rcu_res_c30_s0_valid(b_lane_rcu_res_c30_s0_valid),
    .lane_rcu_res_c30_s0_payload(b_lane_rcu_res_c30_s0_payload),
    .lane_rcu_res_c30_s0_credit(b_lane_rcu_res_c30_s0_credit),
    .lane_rcu_res_c30_s0_stall(b_lane_rcu_res_c30_s0_stall),
    .lane_rcu_res_c30_s1_valid(b_lane_rcu_res_c30_s1_valid),
    .lane_rcu_res_c30_s1_payload(b_lane_rcu_res_c30_s1_payload),
    .lane_rcu_res_c30_s1_credit(b_lane_rcu_res_c30_s1_credit),
    .lane_rcu_res_c30_s1_stall(b_lane_rcu_res_c30_s1_stall),
    .lane_rcu_res_c30_s2_valid(b_lane_rcu_res_c30_s2_valid),
    .lane_rcu_res_c30_s2_payload(b_lane_rcu_res_c30_s2_payload),
    .lane_rcu_res_c30_s2_credit(b_lane_rcu_res_c30_s2_credit),
    .lane_rcu_res_c30_s2_stall(b_lane_rcu_res_c30_s2_stall),
    .lane_rcu_res_c30_s3_valid(b_lane_rcu_res_c30_s3_valid),
    .lane_rcu_res_c30_s3_payload(b_lane_rcu_res_c30_s3_payload),
    .lane_rcu_res_c30_s3_credit(b_lane_rcu_res_c30_s3_credit),
    .lane_rcu_res_c30_s3_stall(b_lane_rcu_res_c30_s3_stall),
    .lane_rcu_res_c30_wake(b_lane_rcu_res_c30_wake),
    .lane_rcu_res_c31_s0_valid(b_lane_rcu_res_c31_s0_valid),
    .lane_rcu_res_c31_s0_payload(b_lane_rcu_res_c31_s0_payload),
    .lane_rcu_res_c31_s0_credit(b_lane_rcu_res_c31_s0_credit),
    .lane_rcu_res_c31_s0_stall(b_lane_rcu_res_c31_s0_stall),
    .lane_rcu_res_c31_s1_valid(b_lane_rcu_res_c31_s1_valid),
    .lane_rcu_res_c31_s1_payload(b_lane_rcu_res_c31_s1_payload),
    .lane_rcu_res_c31_s1_credit(b_lane_rcu_res_c31_s1_credit),
    .lane_rcu_res_c31_s1_stall(b_lane_rcu_res_c31_s1_stall),
    .lane_rcu_res_c31_s2_valid(b_lane_rcu_res_c31_s2_valid),
    .lane_rcu_res_c31_s2_payload(b_lane_rcu_res_c31_s2_payload),
    .lane_rcu_res_c31_s2_credit(b_lane_rcu_res_c31_s2_credit),
    .lane_rcu_res_c31_s2_stall(b_lane_rcu_res_c31_s2_stall),
    .lane_rcu_res_c31_s3_valid(b_lane_rcu_res_c31_s3_valid),
    .lane_rcu_res_c31_s3_payload(b_lane_rcu_res_c31_s3_payload),
    .lane_rcu_res_c31_s3_credit(b_lane_rcu_res_c31_s3_credit),
    .lane_rcu_res_c31_s3_stall(b_lane_rcu_res_c31_s3_stall),
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
    , .rcu_lane_ops_c00_s0_tid(b_rcu_lane_ops_c00_s0_tid)
    , .rcu_lane_ops_c00_s1_tid(b_rcu_lane_ops_c00_s1_tid)
    , .rcu_lane_ops_c00_s2_tid(b_rcu_lane_ops_c00_s2_tid)
    , .rcu_lane_ops_c00_s3_tid(b_rcu_lane_ops_c00_s3_tid)
    , .rcu_lane_ops_c01_s0_tid(b_rcu_lane_ops_c01_s0_tid)
    , .rcu_lane_ops_c01_s1_tid(b_rcu_lane_ops_c01_s1_tid)
    , .rcu_lane_ops_c01_s2_tid(b_rcu_lane_ops_c01_s2_tid)
    , .rcu_lane_ops_c01_s3_tid(b_rcu_lane_ops_c01_s3_tid)
    , .rcu_lane_ops_c02_s0_tid(b_rcu_lane_ops_c02_s0_tid)
    , .rcu_lane_ops_c02_s1_tid(b_rcu_lane_ops_c02_s1_tid)
    , .rcu_lane_ops_c02_s2_tid(b_rcu_lane_ops_c02_s2_tid)
    , .rcu_lane_ops_c02_s3_tid(b_rcu_lane_ops_c02_s3_tid)
    , .rcu_lane_ops_c03_s0_tid(b_rcu_lane_ops_c03_s0_tid)
    , .rcu_lane_ops_c03_s1_tid(b_rcu_lane_ops_c03_s1_tid)
    , .rcu_lane_ops_c03_s2_tid(b_rcu_lane_ops_c03_s2_tid)
    , .rcu_lane_ops_c03_s3_tid(b_rcu_lane_ops_c03_s3_tid)
    , .rcu_lane_ops_c04_s0_tid(b_rcu_lane_ops_c04_s0_tid)
    , .rcu_lane_ops_c04_s1_tid(b_rcu_lane_ops_c04_s1_tid)
    , .rcu_lane_ops_c04_s2_tid(b_rcu_lane_ops_c04_s2_tid)
    , .rcu_lane_ops_c04_s3_tid(b_rcu_lane_ops_c04_s3_tid)
    , .rcu_lane_ops_c05_s0_tid(b_rcu_lane_ops_c05_s0_tid)
    , .rcu_lane_ops_c05_s1_tid(b_rcu_lane_ops_c05_s1_tid)
    , .rcu_lane_ops_c05_s2_tid(b_rcu_lane_ops_c05_s2_tid)
    , .rcu_lane_ops_c05_s3_tid(b_rcu_lane_ops_c05_s3_tid)
    , .rcu_lane_ops_c06_s0_tid(b_rcu_lane_ops_c06_s0_tid)
    , .rcu_lane_ops_c06_s1_tid(b_rcu_lane_ops_c06_s1_tid)
    , .rcu_lane_ops_c06_s2_tid(b_rcu_lane_ops_c06_s2_tid)
    , .rcu_lane_ops_c06_s3_tid(b_rcu_lane_ops_c06_s3_tid)
    , .rcu_lane_ops_c07_s0_tid(b_rcu_lane_ops_c07_s0_tid)
    , .rcu_lane_ops_c07_s1_tid(b_rcu_lane_ops_c07_s1_tid)
    , .rcu_lane_ops_c07_s2_tid(b_rcu_lane_ops_c07_s2_tid)
    , .rcu_lane_ops_c07_s3_tid(b_rcu_lane_ops_c07_s3_tid)
    , .rcu_lane_ops_c08_s0_tid(b_rcu_lane_ops_c08_s0_tid)
    , .rcu_lane_ops_c08_s1_tid(b_rcu_lane_ops_c08_s1_tid)
    , .rcu_lane_ops_c08_s2_tid(b_rcu_lane_ops_c08_s2_tid)
    , .rcu_lane_ops_c08_s3_tid(b_rcu_lane_ops_c08_s3_tid)
    , .rcu_lane_ops_c09_s0_tid(b_rcu_lane_ops_c09_s0_tid)
    , .rcu_lane_ops_c09_s1_tid(b_rcu_lane_ops_c09_s1_tid)
    , .rcu_lane_ops_c09_s2_tid(b_rcu_lane_ops_c09_s2_tid)
    , .rcu_lane_ops_c09_s3_tid(b_rcu_lane_ops_c09_s3_tid)
    , .rcu_lane_ops_c10_s0_tid(b_rcu_lane_ops_c10_s0_tid)
    , .rcu_lane_ops_c10_s1_tid(b_rcu_lane_ops_c10_s1_tid)
    , .rcu_lane_ops_c10_s2_tid(b_rcu_lane_ops_c10_s2_tid)
    , .rcu_lane_ops_c10_s3_tid(b_rcu_lane_ops_c10_s3_tid)
    , .rcu_lane_ops_c11_s0_tid(b_rcu_lane_ops_c11_s0_tid)
    , .rcu_lane_ops_c11_s1_tid(b_rcu_lane_ops_c11_s1_tid)
    , .rcu_lane_ops_c11_s2_tid(b_rcu_lane_ops_c11_s2_tid)
    , .rcu_lane_ops_c11_s3_tid(b_rcu_lane_ops_c11_s3_tid)
    , .rcu_lane_ops_c12_s0_tid(b_rcu_lane_ops_c12_s0_tid)
    , .rcu_lane_ops_c12_s1_tid(b_rcu_lane_ops_c12_s1_tid)
    , .rcu_lane_ops_c12_s2_tid(b_rcu_lane_ops_c12_s2_tid)
    , .rcu_lane_ops_c12_s3_tid(b_rcu_lane_ops_c12_s3_tid)
    , .rcu_lane_ops_c13_s0_tid(b_rcu_lane_ops_c13_s0_tid)
    , .rcu_lane_ops_c13_s1_tid(b_rcu_lane_ops_c13_s1_tid)
    , .rcu_lane_ops_c13_s2_tid(b_rcu_lane_ops_c13_s2_tid)
    , .rcu_lane_ops_c13_s3_tid(b_rcu_lane_ops_c13_s3_tid)
    , .rcu_lane_ops_c14_s0_tid(b_rcu_lane_ops_c14_s0_tid)
    , .rcu_lane_ops_c14_s1_tid(b_rcu_lane_ops_c14_s1_tid)
    , .rcu_lane_ops_c14_s2_tid(b_rcu_lane_ops_c14_s2_tid)
    , .rcu_lane_ops_c14_s3_tid(b_rcu_lane_ops_c14_s3_tid)
    , .rcu_lane_ops_c15_s0_tid(b_rcu_lane_ops_c15_s0_tid)
    , .rcu_lane_ops_c15_s1_tid(b_rcu_lane_ops_c15_s1_tid)
    , .rcu_lane_ops_c15_s2_tid(b_rcu_lane_ops_c15_s2_tid)
    , .rcu_lane_ops_c15_s3_tid(b_rcu_lane_ops_c15_s3_tid)
    , .rcu_lane_ops_c16_s0_tid(b_rcu_lane_ops_c16_s0_tid)
    , .rcu_lane_ops_c16_s1_tid(b_rcu_lane_ops_c16_s1_tid)
    , .rcu_lane_ops_c16_s2_tid(b_rcu_lane_ops_c16_s2_tid)
    , .rcu_lane_ops_c16_s3_tid(b_rcu_lane_ops_c16_s3_tid)
    , .rcu_lane_ops_c17_s0_tid(b_rcu_lane_ops_c17_s0_tid)
    , .rcu_lane_ops_c17_s1_tid(b_rcu_lane_ops_c17_s1_tid)
    , .rcu_lane_ops_c17_s2_tid(b_rcu_lane_ops_c17_s2_tid)
    , .rcu_lane_ops_c17_s3_tid(b_rcu_lane_ops_c17_s3_tid)
    , .rcu_lane_ops_c18_s0_tid(b_rcu_lane_ops_c18_s0_tid)
    , .rcu_lane_ops_c18_s1_tid(b_rcu_lane_ops_c18_s1_tid)
    , .rcu_lane_ops_c18_s2_tid(b_rcu_lane_ops_c18_s2_tid)
    , .rcu_lane_ops_c18_s3_tid(b_rcu_lane_ops_c18_s3_tid)
    , .rcu_lane_ops_c19_s0_tid(b_rcu_lane_ops_c19_s0_tid)
    , .rcu_lane_ops_c19_s1_tid(b_rcu_lane_ops_c19_s1_tid)
    , .rcu_lane_ops_c19_s2_tid(b_rcu_lane_ops_c19_s2_tid)
    , .rcu_lane_ops_c19_s3_tid(b_rcu_lane_ops_c19_s3_tid)
    , .rcu_lane_ops_c20_s0_tid(b_rcu_lane_ops_c20_s0_tid)
    , .rcu_lane_ops_c20_s1_tid(b_rcu_lane_ops_c20_s1_tid)
    , .rcu_lane_ops_c20_s2_tid(b_rcu_lane_ops_c20_s2_tid)
    , .rcu_lane_ops_c20_s3_tid(b_rcu_lane_ops_c20_s3_tid)
    , .rcu_lane_ops_c21_s0_tid(b_rcu_lane_ops_c21_s0_tid)
    , .rcu_lane_ops_c21_s1_tid(b_rcu_lane_ops_c21_s1_tid)
    , .rcu_lane_ops_c21_s2_tid(b_rcu_lane_ops_c21_s2_tid)
    , .rcu_lane_ops_c21_s3_tid(b_rcu_lane_ops_c21_s3_tid)
    , .rcu_lane_ops_c22_s0_tid(b_rcu_lane_ops_c22_s0_tid)
    , .rcu_lane_ops_c22_s1_tid(b_rcu_lane_ops_c22_s1_tid)
    , .rcu_lane_ops_c22_s2_tid(b_rcu_lane_ops_c22_s2_tid)
    , .rcu_lane_ops_c22_s3_tid(b_rcu_lane_ops_c22_s3_tid)
    , .rcu_lane_ops_c23_s0_tid(b_rcu_lane_ops_c23_s0_tid)
    , .rcu_lane_ops_c23_s1_tid(b_rcu_lane_ops_c23_s1_tid)
    , .rcu_lane_ops_c23_s2_tid(b_rcu_lane_ops_c23_s2_tid)
    , .rcu_lane_ops_c23_s3_tid(b_rcu_lane_ops_c23_s3_tid)
    , .rcu_lane_ops_c24_s0_tid(b_rcu_lane_ops_c24_s0_tid)
    , .rcu_lane_ops_c24_s1_tid(b_rcu_lane_ops_c24_s1_tid)
    , .rcu_lane_ops_c24_s2_tid(b_rcu_lane_ops_c24_s2_tid)
    , .rcu_lane_ops_c24_s3_tid(b_rcu_lane_ops_c24_s3_tid)
    , .rcu_lane_ops_c25_s0_tid(b_rcu_lane_ops_c25_s0_tid)
    , .rcu_lane_ops_c25_s1_tid(b_rcu_lane_ops_c25_s1_tid)
    , .rcu_lane_ops_c25_s2_tid(b_rcu_lane_ops_c25_s2_tid)
    , .rcu_lane_ops_c25_s3_tid(b_rcu_lane_ops_c25_s3_tid)
    , .rcu_lane_ops_c26_s0_tid(b_rcu_lane_ops_c26_s0_tid)
    , .rcu_lane_ops_c26_s1_tid(b_rcu_lane_ops_c26_s1_tid)
    , .rcu_lane_ops_c26_s2_tid(b_rcu_lane_ops_c26_s2_tid)
    , .rcu_lane_ops_c26_s3_tid(b_rcu_lane_ops_c26_s3_tid)
    , .rcu_lane_ops_c27_s0_tid(b_rcu_lane_ops_c27_s0_tid)
    , .rcu_lane_ops_c27_s1_tid(b_rcu_lane_ops_c27_s1_tid)
    , .rcu_lane_ops_c27_s2_tid(b_rcu_lane_ops_c27_s2_tid)
    , .rcu_lane_ops_c27_s3_tid(b_rcu_lane_ops_c27_s3_tid)
    , .rcu_lane_ops_c28_s0_tid(b_rcu_lane_ops_c28_s0_tid)
    , .rcu_lane_ops_c28_s1_tid(b_rcu_lane_ops_c28_s1_tid)
    , .rcu_lane_ops_c28_s2_tid(b_rcu_lane_ops_c28_s2_tid)
    , .rcu_lane_ops_c28_s3_tid(b_rcu_lane_ops_c28_s3_tid)
    , .rcu_lane_ops_c29_s0_tid(b_rcu_lane_ops_c29_s0_tid)
    , .rcu_lane_ops_c29_s1_tid(b_rcu_lane_ops_c29_s1_tid)
    , .rcu_lane_ops_c29_s2_tid(b_rcu_lane_ops_c29_s2_tid)
    , .rcu_lane_ops_c29_s3_tid(b_rcu_lane_ops_c29_s3_tid)
    , .rcu_lane_ops_c30_s0_tid(b_rcu_lane_ops_c30_s0_tid)
    , .rcu_lane_ops_c30_s1_tid(b_rcu_lane_ops_c30_s1_tid)
    , .rcu_lane_ops_c30_s2_tid(b_rcu_lane_ops_c30_s2_tid)
    , .rcu_lane_ops_c30_s3_tid(b_rcu_lane_ops_c30_s3_tid)
    , .rcu_lane_ops_c31_s0_tid(b_rcu_lane_ops_c31_s0_tid)
    , .rcu_lane_ops_c31_s1_tid(b_rcu_lane_ops_c31_s1_tid)
    , .rcu_lane_ops_c31_s2_tid(b_rcu_lane_ops_c31_s2_tid)
    , .rcu_lane_ops_c31_s3_tid(b_rcu_lane_ops_c31_s3_tid)
    , .lane_rcu_res_c00_s0_tid(b_lane_rcu_res_c00_s0_tid)
    , .lane_rcu_res_c00_s1_tid(b_lane_rcu_res_c00_s1_tid)
    , .lane_rcu_res_c00_s2_tid(b_lane_rcu_res_c00_s2_tid)
    , .lane_rcu_res_c00_s3_tid(b_lane_rcu_res_c00_s3_tid)
    , .lane_rcu_res_c01_s0_tid(b_lane_rcu_res_c01_s0_tid)
    , .lane_rcu_res_c01_s1_tid(b_lane_rcu_res_c01_s1_tid)
    , .lane_rcu_res_c01_s2_tid(b_lane_rcu_res_c01_s2_tid)
    , .lane_rcu_res_c01_s3_tid(b_lane_rcu_res_c01_s3_tid)
    , .lane_rcu_res_c02_s0_tid(b_lane_rcu_res_c02_s0_tid)
    , .lane_rcu_res_c02_s1_tid(b_lane_rcu_res_c02_s1_tid)
    , .lane_rcu_res_c02_s2_tid(b_lane_rcu_res_c02_s2_tid)
    , .lane_rcu_res_c02_s3_tid(b_lane_rcu_res_c02_s3_tid)
    , .lane_rcu_res_c03_s0_tid(b_lane_rcu_res_c03_s0_tid)
    , .lane_rcu_res_c03_s1_tid(b_lane_rcu_res_c03_s1_tid)
    , .lane_rcu_res_c03_s2_tid(b_lane_rcu_res_c03_s2_tid)
    , .lane_rcu_res_c03_s3_tid(b_lane_rcu_res_c03_s3_tid)
    , .lane_rcu_res_c04_s0_tid(b_lane_rcu_res_c04_s0_tid)
    , .lane_rcu_res_c04_s1_tid(b_lane_rcu_res_c04_s1_tid)
    , .lane_rcu_res_c04_s2_tid(b_lane_rcu_res_c04_s2_tid)
    , .lane_rcu_res_c04_s3_tid(b_lane_rcu_res_c04_s3_tid)
    , .lane_rcu_res_c05_s0_tid(b_lane_rcu_res_c05_s0_tid)
    , .lane_rcu_res_c05_s1_tid(b_lane_rcu_res_c05_s1_tid)
    , .lane_rcu_res_c05_s2_tid(b_lane_rcu_res_c05_s2_tid)
    , .lane_rcu_res_c05_s3_tid(b_lane_rcu_res_c05_s3_tid)
    , .lane_rcu_res_c06_s0_tid(b_lane_rcu_res_c06_s0_tid)
    , .lane_rcu_res_c06_s1_tid(b_lane_rcu_res_c06_s1_tid)
    , .lane_rcu_res_c06_s2_tid(b_lane_rcu_res_c06_s2_tid)
    , .lane_rcu_res_c06_s3_tid(b_lane_rcu_res_c06_s3_tid)
    , .lane_rcu_res_c07_s0_tid(b_lane_rcu_res_c07_s0_tid)
    , .lane_rcu_res_c07_s1_tid(b_lane_rcu_res_c07_s1_tid)
    , .lane_rcu_res_c07_s2_tid(b_lane_rcu_res_c07_s2_tid)
    , .lane_rcu_res_c07_s3_tid(b_lane_rcu_res_c07_s3_tid)
    , .lane_rcu_res_c08_s0_tid(b_lane_rcu_res_c08_s0_tid)
    , .lane_rcu_res_c08_s1_tid(b_lane_rcu_res_c08_s1_tid)
    , .lane_rcu_res_c08_s2_tid(b_lane_rcu_res_c08_s2_tid)
    , .lane_rcu_res_c08_s3_tid(b_lane_rcu_res_c08_s3_tid)
    , .lane_rcu_res_c09_s0_tid(b_lane_rcu_res_c09_s0_tid)
    , .lane_rcu_res_c09_s1_tid(b_lane_rcu_res_c09_s1_tid)
    , .lane_rcu_res_c09_s2_tid(b_lane_rcu_res_c09_s2_tid)
    , .lane_rcu_res_c09_s3_tid(b_lane_rcu_res_c09_s3_tid)
    , .lane_rcu_res_c10_s0_tid(b_lane_rcu_res_c10_s0_tid)
    , .lane_rcu_res_c10_s1_tid(b_lane_rcu_res_c10_s1_tid)
    , .lane_rcu_res_c10_s2_tid(b_lane_rcu_res_c10_s2_tid)
    , .lane_rcu_res_c10_s3_tid(b_lane_rcu_res_c10_s3_tid)
    , .lane_rcu_res_c11_s0_tid(b_lane_rcu_res_c11_s0_tid)
    , .lane_rcu_res_c11_s1_tid(b_lane_rcu_res_c11_s1_tid)
    , .lane_rcu_res_c11_s2_tid(b_lane_rcu_res_c11_s2_tid)
    , .lane_rcu_res_c11_s3_tid(b_lane_rcu_res_c11_s3_tid)
    , .lane_rcu_res_c12_s0_tid(b_lane_rcu_res_c12_s0_tid)
    , .lane_rcu_res_c12_s1_tid(b_lane_rcu_res_c12_s1_tid)
    , .lane_rcu_res_c12_s2_tid(b_lane_rcu_res_c12_s2_tid)
    , .lane_rcu_res_c12_s3_tid(b_lane_rcu_res_c12_s3_tid)
    , .lane_rcu_res_c13_s0_tid(b_lane_rcu_res_c13_s0_tid)
    , .lane_rcu_res_c13_s1_tid(b_lane_rcu_res_c13_s1_tid)
    , .lane_rcu_res_c13_s2_tid(b_lane_rcu_res_c13_s2_tid)
    , .lane_rcu_res_c13_s3_tid(b_lane_rcu_res_c13_s3_tid)
    , .lane_rcu_res_c14_s0_tid(b_lane_rcu_res_c14_s0_tid)
    , .lane_rcu_res_c14_s1_tid(b_lane_rcu_res_c14_s1_tid)
    , .lane_rcu_res_c14_s2_tid(b_lane_rcu_res_c14_s2_tid)
    , .lane_rcu_res_c14_s3_tid(b_lane_rcu_res_c14_s3_tid)
    , .lane_rcu_res_c15_s0_tid(b_lane_rcu_res_c15_s0_tid)
    , .lane_rcu_res_c15_s1_tid(b_lane_rcu_res_c15_s1_tid)
    , .lane_rcu_res_c15_s2_tid(b_lane_rcu_res_c15_s2_tid)
    , .lane_rcu_res_c15_s3_tid(b_lane_rcu_res_c15_s3_tid)
    , .lane_rcu_res_c16_s0_tid(b_lane_rcu_res_c16_s0_tid)
    , .lane_rcu_res_c16_s1_tid(b_lane_rcu_res_c16_s1_tid)
    , .lane_rcu_res_c16_s2_tid(b_lane_rcu_res_c16_s2_tid)
    , .lane_rcu_res_c16_s3_tid(b_lane_rcu_res_c16_s3_tid)
    , .lane_rcu_res_c17_s0_tid(b_lane_rcu_res_c17_s0_tid)
    , .lane_rcu_res_c17_s1_tid(b_lane_rcu_res_c17_s1_tid)
    , .lane_rcu_res_c17_s2_tid(b_lane_rcu_res_c17_s2_tid)
    , .lane_rcu_res_c17_s3_tid(b_lane_rcu_res_c17_s3_tid)
    , .lane_rcu_res_c18_s0_tid(b_lane_rcu_res_c18_s0_tid)
    , .lane_rcu_res_c18_s1_tid(b_lane_rcu_res_c18_s1_tid)
    , .lane_rcu_res_c18_s2_tid(b_lane_rcu_res_c18_s2_tid)
    , .lane_rcu_res_c18_s3_tid(b_lane_rcu_res_c18_s3_tid)
    , .lane_rcu_res_c19_s0_tid(b_lane_rcu_res_c19_s0_tid)
    , .lane_rcu_res_c19_s1_tid(b_lane_rcu_res_c19_s1_tid)
    , .lane_rcu_res_c19_s2_tid(b_lane_rcu_res_c19_s2_tid)
    , .lane_rcu_res_c19_s3_tid(b_lane_rcu_res_c19_s3_tid)
    , .lane_rcu_res_c20_s0_tid(b_lane_rcu_res_c20_s0_tid)
    , .lane_rcu_res_c20_s1_tid(b_lane_rcu_res_c20_s1_tid)
    , .lane_rcu_res_c20_s2_tid(b_lane_rcu_res_c20_s2_tid)
    , .lane_rcu_res_c20_s3_tid(b_lane_rcu_res_c20_s3_tid)
    , .lane_rcu_res_c21_s0_tid(b_lane_rcu_res_c21_s0_tid)
    , .lane_rcu_res_c21_s1_tid(b_lane_rcu_res_c21_s1_tid)
    , .lane_rcu_res_c21_s2_tid(b_lane_rcu_res_c21_s2_tid)
    , .lane_rcu_res_c21_s3_tid(b_lane_rcu_res_c21_s3_tid)
    , .lane_rcu_res_c22_s0_tid(b_lane_rcu_res_c22_s0_tid)
    , .lane_rcu_res_c22_s1_tid(b_lane_rcu_res_c22_s1_tid)
    , .lane_rcu_res_c22_s2_tid(b_lane_rcu_res_c22_s2_tid)
    , .lane_rcu_res_c22_s3_tid(b_lane_rcu_res_c22_s3_tid)
    , .lane_rcu_res_c23_s0_tid(b_lane_rcu_res_c23_s0_tid)
    , .lane_rcu_res_c23_s1_tid(b_lane_rcu_res_c23_s1_tid)
    , .lane_rcu_res_c23_s2_tid(b_lane_rcu_res_c23_s2_tid)
    , .lane_rcu_res_c23_s3_tid(b_lane_rcu_res_c23_s3_tid)
    , .lane_rcu_res_c24_s0_tid(b_lane_rcu_res_c24_s0_tid)
    , .lane_rcu_res_c24_s1_tid(b_lane_rcu_res_c24_s1_tid)
    , .lane_rcu_res_c24_s2_tid(b_lane_rcu_res_c24_s2_tid)
    , .lane_rcu_res_c24_s3_tid(b_lane_rcu_res_c24_s3_tid)
    , .lane_rcu_res_c25_s0_tid(b_lane_rcu_res_c25_s0_tid)
    , .lane_rcu_res_c25_s1_tid(b_lane_rcu_res_c25_s1_tid)
    , .lane_rcu_res_c25_s2_tid(b_lane_rcu_res_c25_s2_tid)
    , .lane_rcu_res_c25_s3_tid(b_lane_rcu_res_c25_s3_tid)
    , .lane_rcu_res_c26_s0_tid(b_lane_rcu_res_c26_s0_tid)
    , .lane_rcu_res_c26_s1_tid(b_lane_rcu_res_c26_s1_tid)
    , .lane_rcu_res_c26_s2_tid(b_lane_rcu_res_c26_s2_tid)
    , .lane_rcu_res_c26_s3_tid(b_lane_rcu_res_c26_s3_tid)
    , .lane_rcu_res_c27_s0_tid(b_lane_rcu_res_c27_s0_tid)
    , .lane_rcu_res_c27_s1_tid(b_lane_rcu_res_c27_s1_tid)
    , .lane_rcu_res_c27_s2_tid(b_lane_rcu_res_c27_s2_tid)
    , .lane_rcu_res_c27_s3_tid(b_lane_rcu_res_c27_s3_tid)
    , .lane_rcu_res_c28_s0_tid(b_lane_rcu_res_c28_s0_tid)
    , .lane_rcu_res_c28_s1_tid(b_lane_rcu_res_c28_s1_tid)
    , .lane_rcu_res_c28_s2_tid(b_lane_rcu_res_c28_s2_tid)
    , .lane_rcu_res_c28_s3_tid(b_lane_rcu_res_c28_s3_tid)
    , .lane_rcu_res_c29_s0_tid(b_lane_rcu_res_c29_s0_tid)
    , .lane_rcu_res_c29_s1_tid(b_lane_rcu_res_c29_s1_tid)
    , .lane_rcu_res_c29_s2_tid(b_lane_rcu_res_c29_s2_tid)
    , .lane_rcu_res_c29_s3_tid(b_lane_rcu_res_c29_s3_tid)
    , .lane_rcu_res_c30_s0_tid(b_lane_rcu_res_c30_s0_tid)
    , .lane_rcu_res_c30_s1_tid(b_lane_rcu_res_c30_s1_tid)
    , .lane_rcu_res_c30_s2_tid(b_lane_rcu_res_c30_s2_tid)
    , .lane_rcu_res_c30_s3_tid(b_lane_rcu_res_c30_s3_tid)
    , .lane_rcu_res_c31_s0_tid(b_lane_rcu_res_c31_s0_tid)
    , .lane_rcu_res_c31_s1_tid(b_lane_rcu_res_c31_s1_tid)
    , .lane_rcu_res_c31_s2_tid(b_lane_rcu_res_c31_s2_tid)
    , .lane_rcu_res_c31_s3_tid(b_lane_rcu_res_c31_s3_tid)
    , .rcu_ooe_done_s0_tid(b_rcu_ooe_done_s0_tid)
    , .rcu_ooe_done_s1_tid(b_rcu_ooe_done_s1_tid)
    , .rcu_ooe_done_s2_tid(b_rcu_ooe_done_s2_tid)
    , .rcu_ooe_done_s3_tid(b_rcu_ooe_done_s3_tid)
    , .rcu_miu_addr_s0_tid(b_rcu_miu_addr_s0_tid)
    , .rcu_miu_addr_s1_tid(b_rcu_miu_addr_s1_tid)
    , .rcu_miu_addr_s2_tid(b_rcu_miu_addr_s2_tid)
    , .rcu_miu_addr_s3_tid(b_rcu_miu_addr_s3_tid)
    , .miu_rcu_data_s0_tid(b_miu_rcu_data_s0_tid)
    , .miu_rcu_data_s1_tid(b_miu_rcu_data_s1_tid)
    , .miu_rcu_data_s2_tid(b_miu_rcu_data_s2_tid)
    , .miu_rcu_data_s3_tid(b_miu_rcu_data_s3_tid)
    , .rau_rcu_mig_tid(b_rau_rcu_mig_tid)
    , .rcu_pca_mig_tid(b_rcu_pca_mig_tid)
    , .pca_rcu_mig_tid(b_pca_rcu_mig_tid)
`endif
  );

  // ccv_ooe_rcu_issue, destination end
  ccv_seq_rpt #(.STAGES(RPT_OOE_RCU_ISSUE), .SLOTS(4), .PAYLOAD_W(138)) u_rpt_ooe_rcu_issue (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({ooe_rcu_issue_s3_valid, ooe_rcu_issue_s2_valid, ooe_rcu_issue_s1_valid, ooe_rcu_issue_s0_valid}), .src_payload({ooe_rcu_issue_s3_payload, ooe_rcu_issue_s2_payload, ooe_rcu_issue_s1_payload, ooe_rcu_issue_s0_payload}),
    .src_wake(ooe_rcu_issue_wake), .src_credit({ooe_rcu_issue_s3_credit, ooe_rcu_issue_s2_credit, ooe_rcu_issue_s1_credit, ooe_rcu_issue_s0_credit}), .src_stall({ooe_rcu_issue_s3_stall, ooe_rcu_issue_s2_stall, ooe_rcu_issue_s1_stall, ooe_rcu_issue_s0_stall}),
    .dst_valid({b_ooe_rcu_issue_s3_valid, b_ooe_rcu_issue_s2_valid, b_ooe_rcu_issue_s1_valid, b_ooe_rcu_issue_s0_valid}), .dst_payload({b_ooe_rcu_issue_s3_payload, b_ooe_rcu_issue_s2_payload, b_ooe_rcu_issue_s1_payload, b_ooe_rcu_issue_s0_payload}),
    .dst_wake(b_ooe_rcu_issue_wake), .dst_credit({b_ooe_rcu_issue_s3_credit, b_ooe_rcu_issue_s2_credit, b_ooe_rcu_issue_s1_credit, b_ooe_rcu_issue_s0_credit}), .dst_stall({b_ooe_rcu_issue_s3_stall, b_ooe_rcu_issue_s2_stall, b_ooe_rcu_issue_s1_stall, b_ooe_rcu_issue_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({ooe_rcu_issue_s3_tid, ooe_rcu_issue_s2_tid, ooe_rcu_issue_s1_tid, ooe_rcu_issue_s0_tid}), .dst_tid({b_ooe_rcu_issue_s3_tid, b_ooe_rcu_issue_s2_tid, b_ooe_rcu_issue_s1_tid, b_ooe_rcu_issue_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C00), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c00 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c00_s3_valid, b_rcu_lane_ops_c00_s2_valid, b_rcu_lane_ops_c00_s1_valid, b_rcu_lane_ops_c00_s0_valid}), .src_payload({b_rcu_lane_ops_c00_s3_payload, b_rcu_lane_ops_c00_s2_payload, b_rcu_lane_ops_c00_s1_payload, b_rcu_lane_ops_c00_s0_payload}),
    .src_wake(b_rcu_lane_ops_c00_wake), .src_credit({b_rcu_lane_ops_c00_s3_credit, b_rcu_lane_ops_c00_s2_credit, b_rcu_lane_ops_c00_s1_credit, b_rcu_lane_ops_c00_s0_credit}), .src_stall({b_rcu_lane_ops_c00_s3_stall, b_rcu_lane_ops_c00_s2_stall, b_rcu_lane_ops_c00_s1_stall, b_rcu_lane_ops_c00_s0_stall}),
    .dst_valid({rcu_lane_ops_c00_s3_valid, rcu_lane_ops_c00_s2_valid, rcu_lane_ops_c00_s1_valid, rcu_lane_ops_c00_s0_valid}), .dst_payload({rcu_lane_ops_c00_s3_payload, rcu_lane_ops_c00_s2_payload, rcu_lane_ops_c00_s1_payload, rcu_lane_ops_c00_s0_payload}),
    .dst_wake(rcu_lane_ops_c00_wake), .dst_credit({rcu_lane_ops_c00_s3_credit, rcu_lane_ops_c00_s2_credit, rcu_lane_ops_c00_s1_credit, rcu_lane_ops_c00_s0_credit}), .dst_stall({rcu_lane_ops_c00_s3_stall, rcu_lane_ops_c00_s2_stall, rcu_lane_ops_c00_s1_stall, rcu_lane_ops_c00_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c00_s3_tid, b_rcu_lane_ops_c00_s2_tid, b_rcu_lane_ops_c00_s1_tid, b_rcu_lane_ops_c00_s0_tid}), .dst_tid({rcu_lane_ops_c00_s3_tid, rcu_lane_ops_c00_s2_tid, rcu_lane_ops_c00_s1_tid, rcu_lane_ops_c00_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C01), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c01 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c01_s3_valid, b_rcu_lane_ops_c01_s2_valid, b_rcu_lane_ops_c01_s1_valid, b_rcu_lane_ops_c01_s0_valid}), .src_payload({b_rcu_lane_ops_c01_s3_payload, b_rcu_lane_ops_c01_s2_payload, b_rcu_lane_ops_c01_s1_payload, b_rcu_lane_ops_c01_s0_payload}),
    .src_wake(b_rcu_lane_ops_c01_wake), .src_credit({b_rcu_lane_ops_c01_s3_credit, b_rcu_lane_ops_c01_s2_credit, b_rcu_lane_ops_c01_s1_credit, b_rcu_lane_ops_c01_s0_credit}), .src_stall({b_rcu_lane_ops_c01_s3_stall, b_rcu_lane_ops_c01_s2_stall, b_rcu_lane_ops_c01_s1_stall, b_rcu_lane_ops_c01_s0_stall}),
    .dst_valid({rcu_lane_ops_c01_s3_valid, rcu_lane_ops_c01_s2_valid, rcu_lane_ops_c01_s1_valid, rcu_lane_ops_c01_s0_valid}), .dst_payload({rcu_lane_ops_c01_s3_payload, rcu_lane_ops_c01_s2_payload, rcu_lane_ops_c01_s1_payload, rcu_lane_ops_c01_s0_payload}),
    .dst_wake(rcu_lane_ops_c01_wake), .dst_credit({rcu_lane_ops_c01_s3_credit, rcu_lane_ops_c01_s2_credit, rcu_lane_ops_c01_s1_credit, rcu_lane_ops_c01_s0_credit}), .dst_stall({rcu_lane_ops_c01_s3_stall, rcu_lane_ops_c01_s2_stall, rcu_lane_ops_c01_s1_stall, rcu_lane_ops_c01_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c01_s3_tid, b_rcu_lane_ops_c01_s2_tid, b_rcu_lane_ops_c01_s1_tid, b_rcu_lane_ops_c01_s0_tid}), .dst_tid({rcu_lane_ops_c01_s3_tid, rcu_lane_ops_c01_s2_tid, rcu_lane_ops_c01_s1_tid, rcu_lane_ops_c01_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C02), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c02 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c02_s3_valid, b_rcu_lane_ops_c02_s2_valid, b_rcu_lane_ops_c02_s1_valid, b_rcu_lane_ops_c02_s0_valid}), .src_payload({b_rcu_lane_ops_c02_s3_payload, b_rcu_lane_ops_c02_s2_payload, b_rcu_lane_ops_c02_s1_payload, b_rcu_lane_ops_c02_s0_payload}),
    .src_wake(b_rcu_lane_ops_c02_wake), .src_credit({b_rcu_lane_ops_c02_s3_credit, b_rcu_lane_ops_c02_s2_credit, b_rcu_lane_ops_c02_s1_credit, b_rcu_lane_ops_c02_s0_credit}), .src_stall({b_rcu_lane_ops_c02_s3_stall, b_rcu_lane_ops_c02_s2_stall, b_rcu_lane_ops_c02_s1_stall, b_rcu_lane_ops_c02_s0_stall}),
    .dst_valid({rcu_lane_ops_c02_s3_valid, rcu_lane_ops_c02_s2_valid, rcu_lane_ops_c02_s1_valid, rcu_lane_ops_c02_s0_valid}), .dst_payload({rcu_lane_ops_c02_s3_payload, rcu_lane_ops_c02_s2_payload, rcu_lane_ops_c02_s1_payload, rcu_lane_ops_c02_s0_payload}),
    .dst_wake(rcu_lane_ops_c02_wake), .dst_credit({rcu_lane_ops_c02_s3_credit, rcu_lane_ops_c02_s2_credit, rcu_lane_ops_c02_s1_credit, rcu_lane_ops_c02_s0_credit}), .dst_stall({rcu_lane_ops_c02_s3_stall, rcu_lane_ops_c02_s2_stall, rcu_lane_ops_c02_s1_stall, rcu_lane_ops_c02_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c02_s3_tid, b_rcu_lane_ops_c02_s2_tid, b_rcu_lane_ops_c02_s1_tid, b_rcu_lane_ops_c02_s0_tid}), .dst_tid({rcu_lane_ops_c02_s3_tid, rcu_lane_ops_c02_s2_tid, rcu_lane_ops_c02_s1_tid, rcu_lane_ops_c02_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C03), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c03 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c03_s3_valid, b_rcu_lane_ops_c03_s2_valid, b_rcu_lane_ops_c03_s1_valid, b_rcu_lane_ops_c03_s0_valid}), .src_payload({b_rcu_lane_ops_c03_s3_payload, b_rcu_lane_ops_c03_s2_payload, b_rcu_lane_ops_c03_s1_payload, b_rcu_lane_ops_c03_s0_payload}),
    .src_wake(b_rcu_lane_ops_c03_wake), .src_credit({b_rcu_lane_ops_c03_s3_credit, b_rcu_lane_ops_c03_s2_credit, b_rcu_lane_ops_c03_s1_credit, b_rcu_lane_ops_c03_s0_credit}), .src_stall({b_rcu_lane_ops_c03_s3_stall, b_rcu_lane_ops_c03_s2_stall, b_rcu_lane_ops_c03_s1_stall, b_rcu_lane_ops_c03_s0_stall}),
    .dst_valid({rcu_lane_ops_c03_s3_valid, rcu_lane_ops_c03_s2_valid, rcu_lane_ops_c03_s1_valid, rcu_lane_ops_c03_s0_valid}), .dst_payload({rcu_lane_ops_c03_s3_payload, rcu_lane_ops_c03_s2_payload, rcu_lane_ops_c03_s1_payload, rcu_lane_ops_c03_s0_payload}),
    .dst_wake(rcu_lane_ops_c03_wake), .dst_credit({rcu_lane_ops_c03_s3_credit, rcu_lane_ops_c03_s2_credit, rcu_lane_ops_c03_s1_credit, rcu_lane_ops_c03_s0_credit}), .dst_stall({rcu_lane_ops_c03_s3_stall, rcu_lane_ops_c03_s2_stall, rcu_lane_ops_c03_s1_stall, rcu_lane_ops_c03_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c03_s3_tid, b_rcu_lane_ops_c03_s2_tid, b_rcu_lane_ops_c03_s1_tid, b_rcu_lane_ops_c03_s0_tid}), .dst_tid({rcu_lane_ops_c03_s3_tid, rcu_lane_ops_c03_s2_tid, rcu_lane_ops_c03_s1_tid, rcu_lane_ops_c03_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C04), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c04 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c04_s3_valid, b_rcu_lane_ops_c04_s2_valid, b_rcu_lane_ops_c04_s1_valid, b_rcu_lane_ops_c04_s0_valid}), .src_payload({b_rcu_lane_ops_c04_s3_payload, b_rcu_lane_ops_c04_s2_payload, b_rcu_lane_ops_c04_s1_payload, b_rcu_lane_ops_c04_s0_payload}),
    .src_wake(b_rcu_lane_ops_c04_wake), .src_credit({b_rcu_lane_ops_c04_s3_credit, b_rcu_lane_ops_c04_s2_credit, b_rcu_lane_ops_c04_s1_credit, b_rcu_lane_ops_c04_s0_credit}), .src_stall({b_rcu_lane_ops_c04_s3_stall, b_rcu_lane_ops_c04_s2_stall, b_rcu_lane_ops_c04_s1_stall, b_rcu_lane_ops_c04_s0_stall}),
    .dst_valid({rcu_lane_ops_c04_s3_valid, rcu_lane_ops_c04_s2_valid, rcu_lane_ops_c04_s1_valid, rcu_lane_ops_c04_s0_valid}), .dst_payload({rcu_lane_ops_c04_s3_payload, rcu_lane_ops_c04_s2_payload, rcu_lane_ops_c04_s1_payload, rcu_lane_ops_c04_s0_payload}),
    .dst_wake(rcu_lane_ops_c04_wake), .dst_credit({rcu_lane_ops_c04_s3_credit, rcu_lane_ops_c04_s2_credit, rcu_lane_ops_c04_s1_credit, rcu_lane_ops_c04_s0_credit}), .dst_stall({rcu_lane_ops_c04_s3_stall, rcu_lane_ops_c04_s2_stall, rcu_lane_ops_c04_s1_stall, rcu_lane_ops_c04_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c04_s3_tid, b_rcu_lane_ops_c04_s2_tid, b_rcu_lane_ops_c04_s1_tid, b_rcu_lane_ops_c04_s0_tid}), .dst_tid({rcu_lane_ops_c04_s3_tid, rcu_lane_ops_c04_s2_tid, rcu_lane_ops_c04_s1_tid, rcu_lane_ops_c04_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C05), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c05 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c05_s3_valid, b_rcu_lane_ops_c05_s2_valid, b_rcu_lane_ops_c05_s1_valid, b_rcu_lane_ops_c05_s0_valid}), .src_payload({b_rcu_lane_ops_c05_s3_payload, b_rcu_lane_ops_c05_s2_payload, b_rcu_lane_ops_c05_s1_payload, b_rcu_lane_ops_c05_s0_payload}),
    .src_wake(b_rcu_lane_ops_c05_wake), .src_credit({b_rcu_lane_ops_c05_s3_credit, b_rcu_lane_ops_c05_s2_credit, b_rcu_lane_ops_c05_s1_credit, b_rcu_lane_ops_c05_s0_credit}), .src_stall({b_rcu_lane_ops_c05_s3_stall, b_rcu_lane_ops_c05_s2_stall, b_rcu_lane_ops_c05_s1_stall, b_rcu_lane_ops_c05_s0_stall}),
    .dst_valid({rcu_lane_ops_c05_s3_valid, rcu_lane_ops_c05_s2_valid, rcu_lane_ops_c05_s1_valid, rcu_lane_ops_c05_s0_valid}), .dst_payload({rcu_lane_ops_c05_s3_payload, rcu_lane_ops_c05_s2_payload, rcu_lane_ops_c05_s1_payload, rcu_lane_ops_c05_s0_payload}),
    .dst_wake(rcu_lane_ops_c05_wake), .dst_credit({rcu_lane_ops_c05_s3_credit, rcu_lane_ops_c05_s2_credit, rcu_lane_ops_c05_s1_credit, rcu_lane_ops_c05_s0_credit}), .dst_stall({rcu_lane_ops_c05_s3_stall, rcu_lane_ops_c05_s2_stall, rcu_lane_ops_c05_s1_stall, rcu_lane_ops_c05_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c05_s3_tid, b_rcu_lane_ops_c05_s2_tid, b_rcu_lane_ops_c05_s1_tid, b_rcu_lane_ops_c05_s0_tid}), .dst_tid({rcu_lane_ops_c05_s3_tid, rcu_lane_ops_c05_s2_tid, rcu_lane_ops_c05_s1_tid, rcu_lane_ops_c05_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C06), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c06 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c06_s3_valid, b_rcu_lane_ops_c06_s2_valid, b_rcu_lane_ops_c06_s1_valid, b_rcu_lane_ops_c06_s0_valid}), .src_payload({b_rcu_lane_ops_c06_s3_payload, b_rcu_lane_ops_c06_s2_payload, b_rcu_lane_ops_c06_s1_payload, b_rcu_lane_ops_c06_s0_payload}),
    .src_wake(b_rcu_lane_ops_c06_wake), .src_credit({b_rcu_lane_ops_c06_s3_credit, b_rcu_lane_ops_c06_s2_credit, b_rcu_lane_ops_c06_s1_credit, b_rcu_lane_ops_c06_s0_credit}), .src_stall({b_rcu_lane_ops_c06_s3_stall, b_rcu_lane_ops_c06_s2_stall, b_rcu_lane_ops_c06_s1_stall, b_rcu_lane_ops_c06_s0_stall}),
    .dst_valid({rcu_lane_ops_c06_s3_valid, rcu_lane_ops_c06_s2_valid, rcu_lane_ops_c06_s1_valid, rcu_lane_ops_c06_s0_valid}), .dst_payload({rcu_lane_ops_c06_s3_payload, rcu_lane_ops_c06_s2_payload, rcu_lane_ops_c06_s1_payload, rcu_lane_ops_c06_s0_payload}),
    .dst_wake(rcu_lane_ops_c06_wake), .dst_credit({rcu_lane_ops_c06_s3_credit, rcu_lane_ops_c06_s2_credit, rcu_lane_ops_c06_s1_credit, rcu_lane_ops_c06_s0_credit}), .dst_stall({rcu_lane_ops_c06_s3_stall, rcu_lane_ops_c06_s2_stall, rcu_lane_ops_c06_s1_stall, rcu_lane_ops_c06_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c06_s3_tid, b_rcu_lane_ops_c06_s2_tid, b_rcu_lane_ops_c06_s1_tid, b_rcu_lane_ops_c06_s0_tid}), .dst_tid({rcu_lane_ops_c06_s3_tid, rcu_lane_ops_c06_s2_tid, rcu_lane_ops_c06_s1_tid, rcu_lane_ops_c06_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C07), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c07 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c07_s3_valid, b_rcu_lane_ops_c07_s2_valid, b_rcu_lane_ops_c07_s1_valid, b_rcu_lane_ops_c07_s0_valid}), .src_payload({b_rcu_lane_ops_c07_s3_payload, b_rcu_lane_ops_c07_s2_payload, b_rcu_lane_ops_c07_s1_payload, b_rcu_lane_ops_c07_s0_payload}),
    .src_wake(b_rcu_lane_ops_c07_wake), .src_credit({b_rcu_lane_ops_c07_s3_credit, b_rcu_lane_ops_c07_s2_credit, b_rcu_lane_ops_c07_s1_credit, b_rcu_lane_ops_c07_s0_credit}), .src_stall({b_rcu_lane_ops_c07_s3_stall, b_rcu_lane_ops_c07_s2_stall, b_rcu_lane_ops_c07_s1_stall, b_rcu_lane_ops_c07_s0_stall}),
    .dst_valid({rcu_lane_ops_c07_s3_valid, rcu_lane_ops_c07_s2_valid, rcu_lane_ops_c07_s1_valid, rcu_lane_ops_c07_s0_valid}), .dst_payload({rcu_lane_ops_c07_s3_payload, rcu_lane_ops_c07_s2_payload, rcu_lane_ops_c07_s1_payload, rcu_lane_ops_c07_s0_payload}),
    .dst_wake(rcu_lane_ops_c07_wake), .dst_credit({rcu_lane_ops_c07_s3_credit, rcu_lane_ops_c07_s2_credit, rcu_lane_ops_c07_s1_credit, rcu_lane_ops_c07_s0_credit}), .dst_stall({rcu_lane_ops_c07_s3_stall, rcu_lane_ops_c07_s2_stall, rcu_lane_ops_c07_s1_stall, rcu_lane_ops_c07_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c07_s3_tid, b_rcu_lane_ops_c07_s2_tid, b_rcu_lane_ops_c07_s1_tid, b_rcu_lane_ops_c07_s0_tid}), .dst_tid({rcu_lane_ops_c07_s3_tid, rcu_lane_ops_c07_s2_tid, rcu_lane_ops_c07_s1_tid, rcu_lane_ops_c07_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C08), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c08 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c08_s3_valid, b_rcu_lane_ops_c08_s2_valid, b_rcu_lane_ops_c08_s1_valid, b_rcu_lane_ops_c08_s0_valid}), .src_payload({b_rcu_lane_ops_c08_s3_payload, b_rcu_lane_ops_c08_s2_payload, b_rcu_lane_ops_c08_s1_payload, b_rcu_lane_ops_c08_s0_payload}),
    .src_wake(b_rcu_lane_ops_c08_wake), .src_credit({b_rcu_lane_ops_c08_s3_credit, b_rcu_lane_ops_c08_s2_credit, b_rcu_lane_ops_c08_s1_credit, b_rcu_lane_ops_c08_s0_credit}), .src_stall({b_rcu_lane_ops_c08_s3_stall, b_rcu_lane_ops_c08_s2_stall, b_rcu_lane_ops_c08_s1_stall, b_rcu_lane_ops_c08_s0_stall}),
    .dst_valid({rcu_lane_ops_c08_s3_valid, rcu_lane_ops_c08_s2_valid, rcu_lane_ops_c08_s1_valid, rcu_lane_ops_c08_s0_valid}), .dst_payload({rcu_lane_ops_c08_s3_payload, rcu_lane_ops_c08_s2_payload, rcu_lane_ops_c08_s1_payload, rcu_lane_ops_c08_s0_payload}),
    .dst_wake(rcu_lane_ops_c08_wake), .dst_credit({rcu_lane_ops_c08_s3_credit, rcu_lane_ops_c08_s2_credit, rcu_lane_ops_c08_s1_credit, rcu_lane_ops_c08_s0_credit}), .dst_stall({rcu_lane_ops_c08_s3_stall, rcu_lane_ops_c08_s2_stall, rcu_lane_ops_c08_s1_stall, rcu_lane_ops_c08_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c08_s3_tid, b_rcu_lane_ops_c08_s2_tid, b_rcu_lane_ops_c08_s1_tid, b_rcu_lane_ops_c08_s0_tid}), .dst_tid({rcu_lane_ops_c08_s3_tid, rcu_lane_ops_c08_s2_tid, rcu_lane_ops_c08_s1_tid, rcu_lane_ops_c08_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C09), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c09 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c09_s3_valid, b_rcu_lane_ops_c09_s2_valid, b_rcu_lane_ops_c09_s1_valid, b_rcu_lane_ops_c09_s0_valid}), .src_payload({b_rcu_lane_ops_c09_s3_payload, b_rcu_lane_ops_c09_s2_payload, b_rcu_lane_ops_c09_s1_payload, b_rcu_lane_ops_c09_s0_payload}),
    .src_wake(b_rcu_lane_ops_c09_wake), .src_credit({b_rcu_lane_ops_c09_s3_credit, b_rcu_lane_ops_c09_s2_credit, b_rcu_lane_ops_c09_s1_credit, b_rcu_lane_ops_c09_s0_credit}), .src_stall({b_rcu_lane_ops_c09_s3_stall, b_rcu_lane_ops_c09_s2_stall, b_rcu_lane_ops_c09_s1_stall, b_rcu_lane_ops_c09_s0_stall}),
    .dst_valid({rcu_lane_ops_c09_s3_valid, rcu_lane_ops_c09_s2_valid, rcu_lane_ops_c09_s1_valid, rcu_lane_ops_c09_s0_valid}), .dst_payload({rcu_lane_ops_c09_s3_payload, rcu_lane_ops_c09_s2_payload, rcu_lane_ops_c09_s1_payload, rcu_lane_ops_c09_s0_payload}),
    .dst_wake(rcu_lane_ops_c09_wake), .dst_credit({rcu_lane_ops_c09_s3_credit, rcu_lane_ops_c09_s2_credit, rcu_lane_ops_c09_s1_credit, rcu_lane_ops_c09_s0_credit}), .dst_stall({rcu_lane_ops_c09_s3_stall, rcu_lane_ops_c09_s2_stall, rcu_lane_ops_c09_s1_stall, rcu_lane_ops_c09_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c09_s3_tid, b_rcu_lane_ops_c09_s2_tid, b_rcu_lane_ops_c09_s1_tid, b_rcu_lane_ops_c09_s0_tid}), .dst_tid({rcu_lane_ops_c09_s3_tid, rcu_lane_ops_c09_s2_tid, rcu_lane_ops_c09_s1_tid, rcu_lane_ops_c09_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C10), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c10 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c10_s3_valid, b_rcu_lane_ops_c10_s2_valid, b_rcu_lane_ops_c10_s1_valid, b_rcu_lane_ops_c10_s0_valid}), .src_payload({b_rcu_lane_ops_c10_s3_payload, b_rcu_lane_ops_c10_s2_payload, b_rcu_lane_ops_c10_s1_payload, b_rcu_lane_ops_c10_s0_payload}),
    .src_wake(b_rcu_lane_ops_c10_wake), .src_credit({b_rcu_lane_ops_c10_s3_credit, b_rcu_lane_ops_c10_s2_credit, b_rcu_lane_ops_c10_s1_credit, b_rcu_lane_ops_c10_s0_credit}), .src_stall({b_rcu_lane_ops_c10_s3_stall, b_rcu_lane_ops_c10_s2_stall, b_rcu_lane_ops_c10_s1_stall, b_rcu_lane_ops_c10_s0_stall}),
    .dst_valid({rcu_lane_ops_c10_s3_valid, rcu_lane_ops_c10_s2_valid, rcu_lane_ops_c10_s1_valid, rcu_lane_ops_c10_s0_valid}), .dst_payload({rcu_lane_ops_c10_s3_payload, rcu_lane_ops_c10_s2_payload, rcu_lane_ops_c10_s1_payload, rcu_lane_ops_c10_s0_payload}),
    .dst_wake(rcu_lane_ops_c10_wake), .dst_credit({rcu_lane_ops_c10_s3_credit, rcu_lane_ops_c10_s2_credit, rcu_lane_ops_c10_s1_credit, rcu_lane_ops_c10_s0_credit}), .dst_stall({rcu_lane_ops_c10_s3_stall, rcu_lane_ops_c10_s2_stall, rcu_lane_ops_c10_s1_stall, rcu_lane_ops_c10_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c10_s3_tid, b_rcu_lane_ops_c10_s2_tid, b_rcu_lane_ops_c10_s1_tid, b_rcu_lane_ops_c10_s0_tid}), .dst_tid({rcu_lane_ops_c10_s3_tid, rcu_lane_ops_c10_s2_tid, rcu_lane_ops_c10_s1_tid, rcu_lane_ops_c10_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C11), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c11 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c11_s3_valid, b_rcu_lane_ops_c11_s2_valid, b_rcu_lane_ops_c11_s1_valid, b_rcu_lane_ops_c11_s0_valid}), .src_payload({b_rcu_lane_ops_c11_s3_payload, b_rcu_lane_ops_c11_s2_payload, b_rcu_lane_ops_c11_s1_payload, b_rcu_lane_ops_c11_s0_payload}),
    .src_wake(b_rcu_lane_ops_c11_wake), .src_credit({b_rcu_lane_ops_c11_s3_credit, b_rcu_lane_ops_c11_s2_credit, b_rcu_lane_ops_c11_s1_credit, b_rcu_lane_ops_c11_s0_credit}), .src_stall({b_rcu_lane_ops_c11_s3_stall, b_rcu_lane_ops_c11_s2_stall, b_rcu_lane_ops_c11_s1_stall, b_rcu_lane_ops_c11_s0_stall}),
    .dst_valid({rcu_lane_ops_c11_s3_valid, rcu_lane_ops_c11_s2_valid, rcu_lane_ops_c11_s1_valid, rcu_lane_ops_c11_s0_valid}), .dst_payload({rcu_lane_ops_c11_s3_payload, rcu_lane_ops_c11_s2_payload, rcu_lane_ops_c11_s1_payload, rcu_lane_ops_c11_s0_payload}),
    .dst_wake(rcu_lane_ops_c11_wake), .dst_credit({rcu_lane_ops_c11_s3_credit, rcu_lane_ops_c11_s2_credit, rcu_lane_ops_c11_s1_credit, rcu_lane_ops_c11_s0_credit}), .dst_stall({rcu_lane_ops_c11_s3_stall, rcu_lane_ops_c11_s2_stall, rcu_lane_ops_c11_s1_stall, rcu_lane_ops_c11_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c11_s3_tid, b_rcu_lane_ops_c11_s2_tid, b_rcu_lane_ops_c11_s1_tid, b_rcu_lane_ops_c11_s0_tid}), .dst_tid({rcu_lane_ops_c11_s3_tid, rcu_lane_ops_c11_s2_tid, rcu_lane_ops_c11_s1_tid, rcu_lane_ops_c11_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C12), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c12 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c12_s3_valid, b_rcu_lane_ops_c12_s2_valid, b_rcu_lane_ops_c12_s1_valid, b_rcu_lane_ops_c12_s0_valid}), .src_payload({b_rcu_lane_ops_c12_s3_payload, b_rcu_lane_ops_c12_s2_payload, b_rcu_lane_ops_c12_s1_payload, b_rcu_lane_ops_c12_s0_payload}),
    .src_wake(b_rcu_lane_ops_c12_wake), .src_credit({b_rcu_lane_ops_c12_s3_credit, b_rcu_lane_ops_c12_s2_credit, b_rcu_lane_ops_c12_s1_credit, b_rcu_lane_ops_c12_s0_credit}), .src_stall({b_rcu_lane_ops_c12_s3_stall, b_rcu_lane_ops_c12_s2_stall, b_rcu_lane_ops_c12_s1_stall, b_rcu_lane_ops_c12_s0_stall}),
    .dst_valid({rcu_lane_ops_c12_s3_valid, rcu_lane_ops_c12_s2_valid, rcu_lane_ops_c12_s1_valid, rcu_lane_ops_c12_s0_valid}), .dst_payload({rcu_lane_ops_c12_s3_payload, rcu_lane_ops_c12_s2_payload, rcu_lane_ops_c12_s1_payload, rcu_lane_ops_c12_s0_payload}),
    .dst_wake(rcu_lane_ops_c12_wake), .dst_credit({rcu_lane_ops_c12_s3_credit, rcu_lane_ops_c12_s2_credit, rcu_lane_ops_c12_s1_credit, rcu_lane_ops_c12_s0_credit}), .dst_stall({rcu_lane_ops_c12_s3_stall, rcu_lane_ops_c12_s2_stall, rcu_lane_ops_c12_s1_stall, rcu_lane_ops_c12_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c12_s3_tid, b_rcu_lane_ops_c12_s2_tid, b_rcu_lane_ops_c12_s1_tid, b_rcu_lane_ops_c12_s0_tid}), .dst_tid({rcu_lane_ops_c12_s3_tid, rcu_lane_ops_c12_s2_tid, rcu_lane_ops_c12_s1_tid, rcu_lane_ops_c12_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C13), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c13 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c13_s3_valid, b_rcu_lane_ops_c13_s2_valid, b_rcu_lane_ops_c13_s1_valid, b_rcu_lane_ops_c13_s0_valid}), .src_payload({b_rcu_lane_ops_c13_s3_payload, b_rcu_lane_ops_c13_s2_payload, b_rcu_lane_ops_c13_s1_payload, b_rcu_lane_ops_c13_s0_payload}),
    .src_wake(b_rcu_lane_ops_c13_wake), .src_credit({b_rcu_lane_ops_c13_s3_credit, b_rcu_lane_ops_c13_s2_credit, b_rcu_lane_ops_c13_s1_credit, b_rcu_lane_ops_c13_s0_credit}), .src_stall({b_rcu_lane_ops_c13_s3_stall, b_rcu_lane_ops_c13_s2_stall, b_rcu_lane_ops_c13_s1_stall, b_rcu_lane_ops_c13_s0_stall}),
    .dst_valid({rcu_lane_ops_c13_s3_valid, rcu_lane_ops_c13_s2_valid, rcu_lane_ops_c13_s1_valid, rcu_lane_ops_c13_s0_valid}), .dst_payload({rcu_lane_ops_c13_s3_payload, rcu_lane_ops_c13_s2_payload, rcu_lane_ops_c13_s1_payload, rcu_lane_ops_c13_s0_payload}),
    .dst_wake(rcu_lane_ops_c13_wake), .dst_credit({rcu_lane_ops_c13_s3_credit, rcu_lane_ops_c13_s2_credit, rcu_lane_ops_c13_s1_credit, rcu_lane_ops_c13_s0_credit}), .dst_stall({rcu_lane_ops_c13_s3_stall, rcu_lane_ops_c13_s2_stall, rcu_lane_ops_c13_s1_stall, rcu_lane_ops_c13_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c13_s3_tid, b_rcu_lane_ops_c13_s2_tid, b_rcu_lane_ops_c13_s1_tid, b_rcu_lane_ops_c13_s0_tid}), .dst_tid({rcu_lane_ops_c13_s3_tid, rcu_lane_ops_c13_s2_tid, rcu_lane_ops_c13_s1_tid, rcu_lane_ops_c13_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C14), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c14 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c14_s3_valid, b_rcu_lane_ops_c14_s2_valid, b_rcu_lane_ops_c14_s1_valid, b_rcu_lane_ops_c14_s0_valid}), .src_payload({b_rcu_lane_ops_c14_s3_payload, b_rcu_lane_ops_c14_s2_payload, b_rcu_lane_ops_c14_s1_payload, b_rcu_lane_ops_c14_s0_payload}),
    .src_wake(b_rcu_lane_ops_c14_wake), .src_credit({b_rcu_lane_ops_c14_s3_credit, b_rcu_lane_ops_c14_s2_credit, b_rcu_lane_ops_c14_s1_credit, b_rcu_lane_ops_c14_s0_credit}), .src_stall({b_rcu_lane_ops_c14_s3_stall, b_rcu_lane_ops_c14_s2_stall, b_rcu_lane_ops_c14_s1_stall, b_rcu_lane_ops_c14_s0_stall}),
    .dst_valid({rcu_lane_ops_c14_s3_valid, rcu_lane_ops_c14_s2_valid, rcu_lane_ops_c14_s1_valid, rcu_lane_ops_c14_s0_valid}), .dst_payload({rcu_lane_ops_c14_s3_payload, rcu_lane_ops_c14_s2_payload, rcu_lane_ops_c14_s1_payload, rcu_lane_ops_c14_s0_payload}),
    .dst_wake(rcu_lane_ops_c14_wake), .dst_credit({rcu_lane_ops_c14_s3_credit, rcu_lane_ops_c14_s2_credit, rcu_lane_ops_c14_s1_credit, rcu_lane_ops_c14_s0_credit}), .dst_stall({rcu_lane_ops_c14_s3_stall, rcu_lane_ops_c14_s2_stall, rcu_lane_ops_c14_s1_stall, rcu_lane_ops_c14_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c14_s3_tid, b_rcu_lane_ops_c14_s2_tid, b_rcu_lane_ops_c14_s1_tid, b_rcu_lane_ops_c14_s0_tid}), .dst_tid({rcu_lane_ops_c14_s3_tid, rcu_lane_ops_c14_s2_tid, rcu_lane_ops_c14_s1_tid, rcu_lane_ops_c14_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C15), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c15 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c15_s3_valid, b_rcu_lane_ops_c15_s2_valid, b_rcu_lane_ops_c15_s1_valid, b_rcu_lane_ops_c15_s0_valid}), .src_payload({b_rcu_lane_ops_c15_s3_payload, b_rcu_lane_ops_c15_s2_payload, b_rcu_lane_ops_c15_s1_payload, b_rcu_lane_ops_c15_s0_payload}),
    .src_wake(b_rcu_lane_ops_c15_wake), .src_credit({b_rcu_lane_ops_c15_s3_credit, b_rcu_lane_ops_c15_s2_credit, b_rcu_lane_ops_c15_s1_credit, b_rcu_lane_ops_c15_s0_credit}), .src_stall({b_rcu_lane_ops_c15_s3_stall, b_rcu_lane_ops_c15_s2_stall, b_rcu_lane_ops_c15_s1_stall, b_rcu_lane_ops_c15_s0_stall}),
    .dst_valid({rcu_lane_ops_c15_s3_valid, rcu_lane_ops_c15_s2_valid, rcu_lane_ops_c15_s1_valid, rcu_lane_ops_c15_s0_valid}), .dst_payload({rcu_lane_ops_c15_s3_payload, rcu_lane_ops_c15_s2_payload, rcu_lane_ops_c15_s1_payload, rcu_lane_ops_c15_s0_payload}),
    .dst_wake(rcu_lane_ops_c15_wake), .dst_credit({rcu_lane_ops_c15_s3_credit, rcu_lane_ops_c15_s2_credit, rcu_lane_ops_c15_s1_credit, rcu_lane_ops_c15_s0_credit}), .dst_stall({rcu_lane_ops_c15_s3_stall, rcu_lane_ops_c15_s2_stall, rcu_lane_ops_c15_s1_stall, rcu_lane_ops_c15_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c15_s3_tid, b_rcu_lane_ops_c15_s2_tid, b_rcu_lane_ops_c15_s1_tid, b_rcu_lane_ops_c15_s0_tid}), .dst_tid({rcu_lane_ops_c15_s3_tid, rcu_lane_ops_c15_s2_tid, rcu_lane_ops_c15_s1_tid, rcu_lane_ops_c15_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C16), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c16 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c16_s3_valid, b_rcu_lane_ops_c16_s2_valid, b_rcu_lane_ops_c16_s1_valid, b_rcu_lane_ops_c16_s0_valid}), .src_payload({b_rcu_lane_ops_c16_s3_payload, b_rcu_lane_ops_c16_s2_payload, b_rcu_lane_ops_c16_s1_payload, b_rcu_lane_ops_c16_s0_payload}),
    .src_wake(b_rcu_lane_ops_c16_wake), .src_credit({b_rcu_lane_ops_c16_s3_credit, b_rcu_lane_ops_c16_s2_credit, b_rcu_lane_ops_c16_s1_credit, b_rcu_lane_ops_c16_s0_credit}), .src_stall({b_rcu_lane_ops_c16_s3_stall, b_rcu_lane_ops_c16_s2_stall, b_rcu_lane_ops_c16_s1_stall, b_rcu_lane_ops_c16_s0_stall}),
    .dst_valid({rcu_lane_ops_c16_s3_valid, rcu_lane_ops_c16_s2_valid, rcu_lane_ops_c16_s1_valid, rcu_lane_ops_c16_s0_valid}), .dst_payload({rcu_lane_ops_c16_s3_payload, rcu_lane_ops_c16_s2_payload, rcu_lane_ops_c16_s1_payload, rcu_lane_ops_c16_s0_payload}),
    .dst_wake(rcu_lane_ops_c16_wake), .dst_credit({rcu_lane_ops_c16_s3_credit, rcu_lane_ops_c16_s2_credit, rcu_lane_ops_c16_s1_credit, rcu_lane_ops_c16_s0_credit}), .dst_stall({rcu_lane_ops_c16_s3_stall, rcu_lane_ops_c16_s2_stall, rcu_lane_ops_c16_s1_stall, rcu_lane_ops_c16_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c16_s3_tid, b_rcu_lane_ops_c16_s2_tid, b_rcu_lane_ops_c16_s1_tid, b_rcu_lane_ops_c16_s0_tid}), .dst_tid({rcu_lane_ops_c16_s3_tid, rcu_lane_ops_c16_s2_tid, rcu_lane_ops_c16_s1_tid, rcu_lane_ops_c16_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C17), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c17 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c17_s3_valid, b_rcu_lane_ops_c17_s2_valid, b_rcu_lane_ops_c17_s1_valid, b_rcu_lane_ops_c17_s0_valid}), .src_payload({b_rcu_lane_ops_c17_s3_payload, b_rcu_lane_ops_c17_s2_payload, b_rcu_lane_ops_c17_s1_payload, b_rcu_lane_ops_c17_s0_payload}),
    .src_wake(b_rcu_lane_ops_c17_wake), .src_credit({b_rcu_lane_ops_c17_s3_credit, b_rcu_lane_ops_c17_s2_credit, b_rcu_lane_ops_c17_s1_credit, b_rcu_lane_ops_c17_s0_credit}), .src_stall({b_rcu_lane_ops_c17_s3_stall, b_rcu_lane_ops_c17_s2_stall, b_rcu_lane_ops_c17_s1_stall, b_rcu_lane_ops_c17_s0_stall}),
    .dst_valid({rcu_lane_ops_c17_s3_valid, rcu_lane_ops_c17_s2_valid, rcu_lane_ops_c17_s1_valid, rcu_lane_ops_c17_s0_valid}), .dst_payload({rcu_lane_ops_c17_s3_payload, rcu_lane_ops_c17_s2_payload, rcu_lane_ops_c17_s1_payload, rcu_lane_ops_c17_s0_payload}),
    .dst_wake(rcu_lane_ops_c17_wake), .dst_credit({rcu_lane_ops_c17_s3_credit, rcu_lane_ops_c17_s2_credit, rcu_lane_ops_c17_s1_credit, rcu_lane_ops_c17_s0_credit}), .dst_stall({rcu_lane_ops_c17_s3_stall, rcu_lane_ops_c17_s2_stall, rcu_lane_ops_c17_s1_stall, rcu_lane_ops_c17_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c17_s3_tid, b_rcu_lane_ops_c17_s2_tid, b_rcu_lane_ops_c17_s1_tid, b_rcu_lane_ops_c17_s0_tid}), .dst_tid({rcu_lane_ops_c17_s3_tid, rcu_lane_ops_c17_s2_tid, rcu_lane_ops_c17_s1_tid, rcu_lane_ops_c17_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C18), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c18 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c18_s3_valid, b_rcu_lane_ops_c18_s2_valid, b_rcu_lane_ops_c18_s1_valid, b_rcu_lane_ops_c18_s0_valid}), .src_payload({b_rcu_lane_ops_c18_s3_payload, b_rcu_lane_ops_c18_s2_payload, b_rcu_lane_ops_c18_s1_payload, b_rcu_lane_ops_c18_s0_payload}),
    .src_wake(b_rcu_lane_ops_c18_wake), .src_credit({b_rcu_lane_ops_c18_s3_credit, b_rcu_lane_ops_c18_s2_credit, b_rcu_lane_ops_c18_s1_credit, b_rcu_lane_ops_c18_s0_credit}), .src_stall({b_rcu_lane_ops_c18_s3_stall, b_rcu_lane_ops_c18_s2_stall, b_rcu_lane_ops_c18_s1_stall, b_rcu_lane_ops_c18_s0_stall}),
    .dst_valid({rcu_lane_ops_c18_s3_valid, rcu_lane_ops_c18_s2_valid, rcu_lane_ops_c18_s1_valid, rcu_lane_ops_c18_s0_valid}), .dst_payload({rcu_lane_ops_c18_s3_payload, rcu_lane_ops_c18_s2_payload, rcu_lane_ops_c18_s1_payload, rcu_lane_ops_c18_s0_payload}),
    .dst_wake(rcu_lane_ops_c18_wake), .dst_credit({rcu_lane_ops_c18_s3_credit, rcu_lane_ops_c18_s2_credit, rcu_lane_ops_c18_s1_credit, rcu_lane_ops_c18_s0_credit}), .dst_stall({rcu_lane_ops_c18_s3_stall, rcu_lane_ops_c18_s2_stall, rcu_lane_ops_c18_s1_stall, rcu_lane_ops_c18_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c18_s3_tid, b_rcu_lane_ops_c18_s2_tid, b_rcu_lane_ops_c18_s1_tid, b_rcu_lane_ops_c18_s0_tid}), .dst_tid({rcu_lane_ops_c18_s3_tid, rcu_lane_ops_c18_s2_tid, rcu_lane_ops_c18_s1_tid, rcu_lane_ops_c18_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C19), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c19 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c19_s3_valid, b_rcu_lane_ops_c19_s2_valid, b_rcu_lane_ops_c19_s1_valid, b_rcu_lane_ops_c19_s0_valid}), .src_payload({b_rcu_lane_ops_c19_s3_payload, b_rcu_lane_ops_c19_s2_payload, b_rcu_lane_ops_c19_s1_payload, b_rcu_lane_ops_c19_s0_payload}),
    .src_wake(b_rcu_lane_ops_c19_wake), .src_credit({b_rcu_lane_ops_c19_s3_credit, b_rcu_lane_ops_c19_s2_credit, b_rcu_lane_ops_c19_s1_credit, b_rcu_lane_ops_c19_s0_credit}), .src_stall({b_rcu_lane_ops_c19_s3_stall, b_rcu_lane_ops_c19_s2_stall, b_rcu_lane_ops_c19_s1_stall, b_rcu_lane_ops_c19_s0_stall}),
    .dst_valid({rcu_lane_ops_c19_s3_valid, rcu_lane_ops_c19_s2_valid, rcu_lane_ops_c19_s1_valid, rcu_lane_ops_c19_s0_valid}), .dst_payload({rcu_lane_ops_c19_s3_payload, rcu_lane_ops_c19_s2_payload, rcu_lane_ops_c19_s1_payload, rcu_lane_ops_c19_s0_payload}),
    .dst_wake(rcu_lane_ops_c19_wake), .dst_credit({rcu_lane_ops_c19_s3_credit, rcu_lane_ops_c19_s2_credit, rcu_lane_ops_c19_s1_credit, rcu_lane_ops_c19_s0_credit}), .dst_stall({rcu_lane_ops_c19_s3_stall, rcu_lane_ops_c19_s2_stall, rcu_lane_ops_c19_s1_stall, rcu_lane_ops_c19_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c19_s3_tid, b_rcu_lane_ops_c19_s2_tid, b_rcu_lane_ops_c19_s1_tid, b_rcu_lane_ops_c19_s0_tid}), .dst_tid({rcu_lane_ops_c19_s3_tid, rcu_lane_ops_c19_s2_tid, rcu_lane_ops_c19_s1_tid, rcu_lane_ops_c19_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C20), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c20 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c20_s3_valid, b_rcu_lane_ops_c20_s2_valid, b_rcu_lane_ops_c20_s1_valid, b_rcu_lane_ops_c20_s0_valid}), .src_payload({b_rcu_lane_ops_c20_s3_payload, b_rcu_lane_ops_c20_s2_payload, b_rcu_lane_ops_c20_s1_payload, b_rcu_lane_ops_c20_s0_payload}),
    .src_wake(b_rcu_lane_ops_c20_wake), .src_credit({b_rcu_lane_ops_c20_s3_credit, b_rcu_lane_ops_c20_s2_credit, b_rcu_lane_ops_c20_s1_credit, b_rcu_lane_ops_c20_s0_credit}), .src_stall({b_rcu_lane_ops_c20_s3_stall, b_rcu_lane_ops_c20_s2_stall, b_rcu_lane_ops_c20_s1_stall, b_rcu_lane_ops_c20_s0_stall}),
    .dst_valid({rcu_lane_ops_c20_s3_valid, rcu_lane_ops_c20_s2_valid, rcu_lane_ops_c20_s1_valid, rcu_lane_ops_c20_s0_valid}), .dst_payload({rcu_lane_ops_c20_s3_payload, rcu_lane_ops_c20_s2_payload, rcu_lane_ops_c20_s1_payload, rcu_lane_ops_c20_s0_payload}),
    .dst_wake(rcu_lane_ops_c20_wake), .dst_credit({rcu_lane_ops_c20_s3_credit, rcu_lane_ops_c20_s2_credit, rcu_lane_ops_c20_s1_credit, rcu_lane_ops_c20_s0_credit}), .dst_stall({rcu_lane_ops_c20_s3_stall, rcu_lane_ops_c20_s2_stall, rcu_lane_ops_c20_s1_stall, rcu_lane_ops_c20_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c20_s3_tid, b_rcu_lane_ops_c20_s2_tid, b_rcu_lane_ops_c20_s1_tid, b_rcu_lane_ops_c20_s0_tid}), .dst_tid({rcu_lane_ops_c20_s3_tid, rcu_lane_ops_c20_s2_tid, rcu_lane_ops_c20_s1_tid, rcu_lane_ops_c20_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C21), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c21 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c21_s3_valid, b_rcu_lane_ops_c21_s2_valid, b_rcu_lane_ops_c21_s1_valid, b_rcu_lane_ops_c21_s0_valid}), .src_payload({b_rcu_lane_ops_c21_s3_payload, b_rcu_lane_ops_c21_s2_payload, b_rcu_lane_ops_c21_s1_payload, b_rcu_lane_ops_c21_s0_payload}),
    .src_wake(b_rcu_lane_ops_c21_wake), .src_credit({b_rcu_lane_ops_c21_s3_credit, b_rcu_lane_ops_c21_s2_credit, b_rcu_lane_ops_c21_s1_credit, b_rcu_lane_ops_c21_s0_credit}), .src_stall({b_rcu_lane_ops_c21_s3_stall, b_rcu_lane_ops_c21_s2_stall, b_rcu_lane_ops_c21_s1_stall, b_rcu_lane_ops_c21_s0_stall}),
    .dst_valid({rcu_lane_ops_c21_s3_valid, rcu_lane_ops_c21_s2_valid, rcu_lane_ops_c21_s1_valid, rcu_lane_ops_c21_s0_valid}), .dst_payload({rcu_lane_ops_c21_s3_payload, rcu_lane_ops_c21_s2_payload, rcu_lane_ops_c21_s1_payload, rcu_lane_ops_c21_s0_payload}),
    .dst_wake(rcu_lane_ops_c21_wake), .dst_credit({rcu_lane_ops_c21_s3_credit, rcu_lane_ops_c21_s2_credit, rcu_lane_ops_c21_s1_credit, rcu_lane_ops_c21_s0_credit}), .dst_stall({rcu_lane_ops_c21_s3_stall, rcu_lane_ops_c21_s2_stall, rcu_lane_ops_c21_s1_stall, rcu_lane_ops_c21_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c21_s3_tid, b_rcu_lane_ops_c21_s2_tid, b_rcu_lane_ops_c21_s1_tid, b_rcu_lane_ops_c21_s0_tid}), .dst_tid({rcu_lane_ops_c21_s3_tid, rcu_lane_ops_c21_s2_tid, rcu_lane_ops_c21_s1_tid, rcu_lane_ops_c21_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C22), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c22 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c22_s3_valid, b_rcu_lane_ops_c22_s2_valid, b_rcu_lane_ops_c22_s1_valid, b_rcu_lane_ops_c22_s0_valid}), .src_payload({b_rcu_lane_ops_c22_s3_payload, b_rcu_lane_ops_c22_s2_payload, b_rcu_lane_ops_c22_s1_payload, b_rcu_lane_ops_c22_s0_payload}),
    .src_wake(b_rcu_lane_ops_c22_wake), .src_credit({b_rcu_lane_ops_c22_s3_credit, b_rcu_lane_ops_c22_s2_credit, b_rcu_lane_ops_c22_s1_credit, b_rcu_lane_ops_c22_s0_credit}), .src_stall({b_rcu_lane_ops_c22_s3_stall, b_rcu_lane_ops_c22_s2_stall, b_rcu_lane_ops_c22_s1_stall, b_rcu_lane_ops_c22_s0_stall}),
    .dst_valid({rcu_lane_ops_c22_s3_valid, rcu_lane_ops_c22_s2_valid, rcu_lane_ops_c22_s1_valid, rcu_lane_ops_c22_s0_valid}), .dst_payload({rcu_lane_ops_c22_s3_payload, rcu_lane_ops_c22_s2_payload, rcu_lane_ops_c22_s1_payload, rcu_lane_ops_c22_s0_payload}),
    .dst_wake(rcu_lane_ops_c22_wake), .dst_credit({rcu_lane_ops_c22_s3_credit, rcu_lane_ops_c22_s2_credit, rcu_lane_ops_c22_s1_credit, rcu_lane_ops_c22_s0_credit}), .dst_stall({rcu_lane_ops_c22_s3_stall, rcu_lane_ops_c22_s2_stall, rcu_lane_ops_c22_s1_stall, rcu_lane_ops_c22_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c22_s3_tid, b_rcu_lane_ops_c22_s2_tid, b_rcu_lane_ops_c22_s1_tid, b_rcu_lane_ops_c22_s0_tid}), .dst_tid({rcu_lane_ops_c22_s3_tid, rcu_lane_ops_c22_s2_tid, rcu_lane_ops_c22_s1_tid, rcu_lane_ops_c22_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C23), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c23 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c23_s3_valid, b_rcu_lane_ops_c23_s2_valid, b_rcu_lane_ops_c23_s1_valid, b_rcu_lane_ops_c23_s0_valid}), .src_payload({b_rcu_lane_ops_c23_s3_payload, b_rcu_lane_ops_c23_s2_payload, b_rcu_lane_ops_c23_s1_payload, b_rcu_lane_ops_c23_s0_payload}),
    .src_wake(b_rcu_lane_ops_c23_wake), .src_credit({b_rcu_lane_ops_c23_s3_credit, b_rcu_lane_ops_c23_s2_credit, b_rcu_lane_ops_c23_s1_credit, b_rcu_lane_ops_c23_s0_credit}), .src_stall({b_rcu_lane_ops_c23_s3_stall, b_rcu_lane_ops_c23_s2_stall, b_rcu_lane_ops_c23_s1_stall, b_rcu_lane_ops_c23_s0_stall}),
    .dst_valid({rcu_lane_ops_c23_s3_valid, rcu_lane_ops_c23_s2_valid, rcu_lane_ops_c23_s1_valid, rcu_lane_ops_c23_s0_valid}), .dst_payload({rcu_lane_ops_c23_s3_payload, rcu_lane_ops_c23_s2_payload, rcu_lane_ops_c23_s1_payload, rcu_lane_ops_c23_s0_payload}),
    .dst_wake(rcu_lane_ops_c23_wake), .dst_credit({rcu_lane_ops_c23_s3_credit, rcu_lane_ops_c23_s2_credit, rcu_lane_ops_c23_s1_credit, rcu_lane_ops_c23_s0_credit}), .dst_stall({rcu_lane_ops_c23_s3_stall, rcu_lane_ops_c23_s2_stall, rcu_lane_ops_c23_s1_stall, rcu_lane_ops_c23_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c23_s3_tid, b_rcu_lane_ops_c23_s2_tid, b_rcu_lane_ops_c23_s1_tid, b_rcu_lane_ops_c23_s0_tid}), .dst_tid({rcu_lane_ops_c23_s3_tid, rcu_lane_ops_c23_s2_tid, rcu_lane_ops_c23_s1_tid, rcu_lane_ops_c23_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C24), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c24 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c24_s3_valid, b_rcu_lane_ops_c24_s2_valid, b_rcu_lane_ops_c24_s1_valid, b_rcu_lane_ops_c24_s0_valid}), .src_payload({b_rcu_lane_ops_c24_s3_payload, b_rcu_lane_ops_c24_s2_payload, b_rcu_lane_ops_c24_s1_payload, b_rcu_lane_ops_c24_s0_payload}),
    .src_wake(b_rcu_lane_ops_c24_wake), .src_credit({b_rcu_lane_ops_c24_s3_credit, b_rcu_lane_ops_c24_s2_credit, b_rcu_lane_ops_c24_s1_credit, b_rcu_lane_ops_c24_s0_credit}), .src_stall({b_rcu_lane_ops_c24_s3_stall, b_rcu_lane_ops_c24_s2_stall, b_rcu_lane_ops_c24_s1_stall, b_rcu_lane_ops_c24_s0_stall}),
    .dst_valid({rcu_lane_ops_c24_s3_valid, rcu_lane_ops_c24_s2_valid, rcu_lane_ops_c24_s1_valid, rcu_lane_ops_c24_s0_valid}), .dst_payload({rcu_lane_ops_c24_s3_payload, rcu_lane_ops_c24_s2_payload, rcu_lane_ops_c24_s1_payload, rcu_lane_ops_c24_s0_payload}),
    .dst_wake(rcu_lane_ops_c24_wake), .dst_credit({rcu_lane_ops_c24_s3_credit, rcu_lane_ops_c24_s2_credit, rcu_lane_ops_c24_s1_credit, rcu_lane_ops_c24_s0_credit}), .dst_stall({rcu_lane_ops_c24_s3_stall, rcu_lane_ops_c24_s2_stall, rcu_lane_ops_c24_s1_stall, rcu_lane_ops_c24_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c24_s3_tid, b_rcu_lane_ops_c24_s2_tid, b_rcu_lane_ops_c24_s1_tid, b_rcu_lane_ops_c24_s0_tid}), .dst_tid({rcu_lane_ops_c24_s3_tid, rcu_lane_ops_c24_s2_tid, rcu_lane_ops_c24_s1_tid, rcu_lane_ops_c24_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C25), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c25 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c25_s3_valid, b_rcu_lane_ops_c25_s2_valid, b_rcu_lane_ops_c25_s1_valid, b_rcu_lane_ops_c25_s0_valid}), .src_payload({b_rcu_lane_ops_c25_s3_payload, b_rcu_lane_ops_c25_s2_payload, b_rcu_lane_ops_c25_s1_payload, b_rcu_lane_ops_c25_s0_payload}),
    .src_wake(b_rcu_lane_ops_c25_wake), .src_credit({b_rcu_lane_ops_c25_s3_credit, b_rcu_lane_ops_c25_s2_credit, b_rcu_lane_ops_c25_s1_credit, b_rcu_lane_ops_c25_s0_credit}), .src_stall({b_rcu_lane_ops_c25_s3_stall, b_rcu_lane_ops_c25_s2_stall, b_rcu_lane_ops_c25_s1_stall, b_rcu_lane_ops_c25_s0_stall}),
    .dst_valid({rcu_lane_ops_c25_s3_valid, rcu_lane_ops_c25_s2_valid, rcu_lane_ops_c25_s1_valid, rcu_lane_ops_c25_s0_valid}), .dst_payload({rcu_lane_ops_c25_s3_payload, rcu_lane_ops_c25_s2_payload, rcu_lane_ops_c25_s1_payload, rcu_lane_ops_c25_s0_payload}),
    .dst_wake(rcu_lane_ops_c25_wake), .dst_credit({rcu_lane_ops_c25_s3_credit, rcu_lane_ops_c25_s2_credit, rcu_lane_ops_c25_s1_credit, rcu_lane_ops_c25_s0_credit}), .dst_stall({rcu_lane_ops_c25_s3_stall, rcu_lane_ops_c25_s2_stall, rcu_lane_ops_c25_s1_stall, rcu_lane_ops_c25_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c25_s3_tid, b_rcu_lane_ops_c25_s2_tid, b_rcu_lane_ops_c25_s1_tid, b_rcu_lane_ops_c25_s0_tid}), .dst_tid({rcu_lane_ops_c25_s3_tid, rcu_lane_ops_c25_s2_tid, rcu_lane_ops_c25_s1_tid, rcu_lane_ops_c25_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C26), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c26 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c26_s3_valid, b_rcu_lane_ops_c26_s2_valid, b_rcu_lane_ops_c26_s1_valid, b_rcu_lane_ops_c26_s0_valid}), .src_payload({b_rcu_lane_ops_c26_s3_payload, b_rcu_lane_ops_c26_s2_payload, b_rcu_lane_ops_c26_s1_payload, b_rcu_lane_ops_c26_s0_payload}),
    .src_wake(b_rcu_lane_ops_c26_wake), .src_credit({b_rcu_lane_ops_c26_s3_credit, b_rcu_lane_ops_c26_s2_credit, b_rcu_lane_ops_c26_s1_credit, b_rcu_lane_ops_c26_s0_credit}), .src_stall({b_rcu_lane_ops_c26_s3_stall, b_rcu_lane_ops_c26_s2_stall, b_rcu_lane_ops_c26_s1_stall, b_rcu_lane_ops_c26_s0_stall}),
    .dst_valid({rcu_lane_ops_c26_s3_valid, rcu_lane_ops_c26_s2_valid, rcu_lane_ops_c26_s1_valid, rcu_lane_ops_c26_s0_valid}), .dst_payload({rcu_lane_ops_c26_s3_payload, rcu_lane_ops_c26_s2_payload, rcu_lane_ops_c26_s1_payload, rcu_lane_ops_c26_s0_payload}),
    .dst_wake(rcu_lane_ops_c26_wake), .dst_credit({rcu_lane_ops_c26_s3_credit, rcu_lane_ops_c26_s2_credit, rcu_lane_ops_c26_s1_credit, rcu_lane_ops_c26_s0_credit}), .dst_stall({rcu_lane_ops_c26_s3_stall, rcu_lane_ops_c26_s2_stall, rcu_lane_ops_c26_s1_stall, rcu_lane_ops_c26_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c26_s3_tid, b_rcu_lane_ops_c26_s2_tid, b_rcu_lane_ops_c26_s1_tid, b_rcu_lane_ops_c26_s0_tid}), .dst_tid({rcu_lane_ops_c26_s3_tid, rcu_lane_ops_c26_s2_tid, rcu_lane_ops_c26_s1_tid, rcu_lane_ops_c26_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C27), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c27 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c27_s3_valid, b_rcu_lane_ops_c27_s2_valid, b_rcu_lane_ops_c27_s1_valid, b_rcu_lane_ops_c27_s0_valid}), .src_payload({b_rcu_lane_ops_c27_s3_payload, b_rcu_lane_ops_c27_s2_payload, b_rcu_lane_ops_c27_s1_payload, b_rcu_lane_ops_c27_s0_payload}),
    .src_wake(b_rcu_lane_ops_c27_wake), .src_credit({b_rcu_lane_ops_c27_s3_credit, b_rcu_lane_ops_c27_s2_credit, b_rcu_lane_ops_c27_s1_credit, b_rcu_lane_ops_c27_s0_credit}), .src_stall({b_rcu_lane_ops_c27_s3_stall, b_rcu_lane_ops_c27_s2_stall, b_rcu_lane_ops_c27_s1_stall, b_rcu_lane_ops_c27_s0_stall}),
    .dst_valid({rcu_lane_ops_c27_s3_valid, rcu_lane_ops_c27_s2_valid, rcu_lane_ops_c27_s1_valid, rcu_lane_ops_c27_s0_valid}), .dst_payload({rcu_lane_ops_c27_s3_payload, rcu_lane_ops_c27_s2_payload, rcu_lane_ops_c27_s1_payload, rcu_lane_ops_c27_s0_payload}),
    .dst_wake(rcu_lane_ops_c27_wake), .dst_credit({rcu_lane_ops_c27_s3_credit, rcu_lane_ops_c27_s2_credit, rcu_lane_ops_c27_s1_credit, rcu_lane_ops_c27_s0_credit}), .dst_stall({rcu_lane_ops_c27_s3_stall, rcu_lane_ops_c27_s2_stall, rcu_lane_ops_c27_s1_stall, rcu_lane_ops_c27_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c27_s3_tid, b_rcu_lane_ops_c27_s2_tid, b_rcu_lane_ops_c27_s1_tid, b_rcu_lane_ops_c27_s0_tid}), .dst_tid({rcu_lane_ops_c27_s3_tid, rcu_lane_ops_c27_s2_tid, rcu_lane_ops_c27_s1_tid, rcu_lane_ops_c27_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C28), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c28 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c28_s3_valid, b_rcu_lane_ops_c28_s2_valid, b_rcu_lane_ops_c28_s1_valid, b_rcu_lane_ops_c28_s0_valid}), .src_payload({b_rcu_lane_ops_c28_s3_payload, b_rcu_lane_ops_c28_s2_payload, b_rcu_lane_ops_c28_s1_payload, b_rcu_lane_ops_c28_s0_payload}),
    .src_wake(b_rcu_lane_ops_c28_wake), .src_credit({b_rcu_lane_ops_c28_s3_credit, b_rcu_lane_ops_c28_s2_credit, b_rcu_lane_ops_c28_s1_credit, b_rcu_lane_ops_c28_s0_credit}), .src_stall({b_rcu_lane_ops_c28_s3_stall, b_rcu_lane_ops_c28_s2_stall, b_rcu_lane_ops_c28_s1_stall, b_rcu_lane_ops_c28_s0_stall}),
    .dst_valid({rcu_lane_ops_c28_s3_valid, rcu_lane_ops_c28_s2_valid, rcu_lane_ops_c28_s1_valid, rcu_lane_ops_c28_s0_valid}), .dst_payload({rcu_lane_ops_c28_s3_payload, rcu_lane_ops_c28_s2_payload, rcu_lane_ops_c28_s1_payload, rcu_lane_ops_c28_s0_payload}),
    .dst_wake(rcu_lane_ops_c28_wake), .dst_credit({rcu_lane_ops_c28_s3_credit, rcu_lane_ops_c28_s2_credit, rcu_lane_ops_c28_s1_credit, rcu_lane_ops_c28_s0_credit}), .dst_stall({rcu_lane_ops_c28_s3_stall, rcu_lane_ops_c28_s2_stall, rcu_lane_ops_c28_s1_stall, rcu_lane_ops_c28_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c28_s3_tid, b_rcu_lane_ops_c28_s2_tid, b_rcu_lane_ops_c28_s1_tid, b_rcu_lane_ops_c28_s0_tid}), .dst_tid({rcu_lane_ops_c28_s3_tid, rcu_lane_ops_c28_s2_tid, rcu_lane_ops_c28_s1_tid, rcu_lane_ops_c28_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C29), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c29 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c29_s3_valid, b_rcu_lane_ops_c29_s2_valid, b_rcu_lane_ops_c29_s1_valid, b_rcu_lane_ops_c29_s0_valid}), .src_payload({b_rcu_lane_ops_c29_s3_payload, b_rcu_lane_ops_c29_s2_payload, b_rcu_lane_ops_c29_s1_payload, b_rcu_lane_ops_c29_s0_payload}),
    .src_wake(b_rcu_lane_ops_c29_wake), .src_credit({b_rcu_lane_ops_c29_s3_credit, b_rcu_lane_ops_c29_s2_credit, b_rcu_lane_ops_c29_s1_credit, b_rcu_lane_ops_c29_s0_credit}), .src_stall({b_rcu_lane_ops_c29_s3_stall, b_rcu_lane_ops_c29_s2_stall, b_rcu_lane_ops_c29_s1_stall, b_rcu_lane_ops_c29_s0_stall}),
    .dst_valid({rcu_lane_ops_c29_s3_valid, rcu_lane_ops_c29_s2_valid, rcu_lane_ops_c29_s1_valid, rcu_lane_ops_c29_s0_valid}), .dst_payload({rcu_lane_ops_c29_s3_payload, rcu_lane_ops_c29_s2_payload, rcu_lane_ops_c29_s1_payload, rcu_lane_ops_c29_s0_payload}),
    .dst_wake(rcu_lane_ops_c29_wake), .dst_credit({rcu_lane_ops_c29_s3_credit, rcu_lane_ops_c29_s2_credit, rcu_lane_ops_c29_s1_credit, rcu_lane_ops_c29_s0_credit}), .dst_stall({rcu_lane_ops_c29_s3_stall, rcu_lane_ops_c29_s2_stall, rcu_lane_ops_c29_s1_stall, rcu_lane_ops_c29_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c29_s3_tid, b_rcu_lane_ops_c29_s2_tid, b_rcu_lane_ops_c29_s1_tid, b_rcu_lane_ops_c29_s0_tid}), .dst_tid({rcu_lane_ops_c29_s3_tid, rcu_lane_ops_c29_s2_tid, rcu_lane_ops_c29_s1_tid, rcu_lane_ops_c29_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C30), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c30 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c30_s3_valid, b_rcu_lane_ops_c30_s2_valid, b_rcu_lane_ops_c30_s1_valid, b_rcu_lane_ops_c30_s0_valid}), .src_payload({b_rcu_lane_ops_c30_s3_payload, b_rcu_lane_ops_c30_s2_payload, b_rcu_lane_ops_c30_s1_payload, b_rcu_lane_ops_c30_s0_payload}),
    .src_wake(b_rcu_lane_ops_c30_wake), .src_credit({b_rcu_lane_ops_c30_s3_credit, b_rcu_lane_ops_c30_s2_credit, b_rcu_lane_ops_c30_s1_credit, b_rcu_lane_ops_c30_s0_credit}), .src_stall({b_rcu_lane_ops_c30_s3_stall, b_rcu_lane_ops_c30_s2_stall, b_rcu_lane_ops_c30_s1_stall, b_rcu_lane_ops_c30_s0_stall}),
    .dst_valid({rcu_lane_ops_c30_s3_valid, rcu_lane_ops_c30_s2_valid, rcu_lane_ops_c30_s1_valid, rcu_lane_ops_c30_s0_valid}), .dst_payload({rcu_lane_ops_c30_s3_payload, rcu_lane_ops_c30_s2_payload, rcu_lane_ops_c30_s1_payload, rcu_lane_ops_c30_s0_payload}),
    .dst_wake(rcu_lane_ops_c30_wake), .dst_credit({rcu_lane_ops_c30_s3_credit, rcu_lane_ops_c30_s2_credit, rcu_lane_ops_c30_s1_credit, rcu_lane_ops_c30_s0_credit}), .dst_stall({rcu_lane_ops_c30_s3_stall, rcu_lane_ops_c30_s2_stall, rcu_lane_ops_c30_s1_stall, rcu_lane_ops_c30_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c30_s3_tid, b_rcu_lane_ops_c30_s2_tid, b_rcu_lane_ops_c30_s1_tid, b_rcu_lane_ops_c30_s0_tid}), .dst_tid({rcu_lane_ops_c30_s3_tid, rcu_lane_ops_c30_s2_tid, rcu_lane_ops_c30_s1_tid, rcu_lane_ops_c30_s0_tid})
`endif
  );
  // ccv_rcu_lane_ops, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS_C31), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops_c31 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_lane_ops_c31_s3_valid, b_rcu_lane_ops_c31_s2_valid, b_rcu_lane_ops_c31_s1_valid, b_rcu_lane_ops_c31_s0_valid}), .src_payload({b_rcu_lane_ops_c31_s3_payload, b_rcu_lane_ops_c31_s2_payload, b_rcu_lane_ops_c31_s1_payload, b_rcu_lane_ops_c31_s0_payload}),
    .src_wake(b_rcu_lane_ops_c31_wake), .src_credit({b_rcu_lane_ops_c31_s3_credit, b_rcu_lane_ops_c31_s2_credit, b_rcu_lane_ops_c31_s1_credit, b_rcu_lane_ops_c31_s0_credit}), .src_stall({b_rcu_lane_ops_c31_s3_stall, b_rcu_lane_ops_c31_s2_stall, b_rcu_lane_ops_c31_s1_stall, b_rcu_lane_ops_c31_s0_stall}),
    .dst_valid({rcu_lane_ops_c31_s3_valid, rcu_lane_ops_c31_s2_valid, rcu_lane_ops_c31_s1_valid, rcu_lane_ops_c31_s0_valid}), .dst_payload({rcu_lane_ops_c31_s3_payload, rcu_lane_ops_c31_s2_payload, rcu_lane_ops_c31_s1_payload, rcu_lane_ops_c31_s0_payload}),
    .dst_wake(rcu_lane_ops_c31_wake), .dst_credit({rcu_lane_ops_c31_s3_credit, rcu_lane_ops_c31_s2_credit, rcu_lane_ops_c31_s1_credit, rcu_lane_ops_c31_s0_credit}), .dst_stall({rcu_lane_ops_c31_s3_stall, rcu_lane_ops_c31_s2_stall, rcu_lane_ops_c31_s1_stall, rcu_lane_ops_c31_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_lane_ops_c31_s3_tid, b_rcu_lane_ops_c31_s2_tid, b_rcu_lane_ops_c31_s1_tid, b_rcu_lane_ops_c31_s0_tid}), .dst_tid({rcu_lane_ops_c31_s3_tid, rcu_lane_ops_c31_s2_tid, rcu_lane_ops_c31_s1_tid, rcu_lane_ops_c31_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C00), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c00 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c00_s3_valid, lane_rcu_res_c00_s2_valid, lane_rcu_res_c00_s1_valid, lane_rcu_res_c00_s0_valid}), .src_payload({lane_rcu_res_c00_s3_payload, lane_rcu_res_c00_s2_payload, lane_rcu_res_c00_s1_payload, lane_rcu_res_c00_s0_payload}),
    .src_wake(lane_rcu_res_c00_wake), .src_credit({lane_rcu_res_c00_s3_credit, lane_rcu_res_c00_s2_credit, lane_rcu_res_c00_s1_credit, lane_rcu_res_c00_s0_credit}), .src_stall({lane_rcu_res_c00_s3_stall, lane_rcu_res_c00_s2_stall, lane_rcu_res_c00_s1_stall, lane_rcu_res_c00_s0_stall}),
    .dst_valid({b_lane_rcu_res_c00_s3_valid, b_lane_rcu_res_c00_s2_valid, b_lane_rcu_res_c00_s1_valid, b_lane_rcu_res_c00_s0_valid}), .dst_payload({b_lane_rcu_res_c00_s3_payload, b_lane_rcu_res_c00_s2_payload, b_lane_rcu_res_c00_s1_payload, b_lane_rcu_res_c00_s0_payload}),
    .dst_wake(b_lane_rcu_res_c00_wake), .dst_credit({b_lane_rcu_res_c00_s3_credit, b_lane_rcu_res_c00_s2_credit, b_lane_rcu_res_c00_s1_credit, b_lane_rcu_res_c00_s0_credit}), .dst_stall({b_lane_rcu_res_c00_s3_stall, b_lane_rcu_res_c00_s2_stall, b_lane_rcu_res_c00_s1_stall, b_lane_rcu_res_c00_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c00_s3_tid, lane_rcu_res_c00_s2_tid, lane_rcu_res_c00_s1_tid, lane_rcu_res_c00_s0_tid}), .dst_tid({b_lane_rcu_res_c00_s3_tid, b_lane_rcu_res_c00_s2_tid, b_lane_rcu_res_c00_s1_tid, b_lane_rcu_res_c00_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C01), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c01 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c01_s3_valid, lane_rcu_res_c01_s2_valid, lane_rcu_res_c01_s1_valid, lane_rcu_res_c01_s0_valid}), .src_payload({lane_rcu_res_c01_s3_payload, lane_rcu_res_c01_s2_payload, lane_rcu_res_c01_s1_payload, lane_rcu_res_c01_s0_payload}),
    .src_wake(lane_rcu_res_c01_wake), .src_credit({lane_rcu_res_c01_s3_credit, lane_rcu_res_c01_s2_credit, lane_rcu_res_c01_s1_credit, lane_rcu_res_c01_s0_credit}), .src_stall({lane_rcu_res_c01_s3_stall, lane_rcu_res_c01_s2_stall, lane_rcu_res_c01_s1_stall, lane_rcu_res_c01_s0_stall}),
    .dst_valid({b_lane_rcu_res_c01_s3_valid, b_lane_rcu_res_c01_s2_valid, b_lane_rcu_res_c01_s1_valid, b_lane_rcu_res_c01_s0_valid}), .dst_payload({b_lane_rcu_res_c01_s3_payload, b_lane_rcu_res_c01_s2_payload, b_lane_rcu_res_c01_s1_payload, b_lane_rcu_res_c01_s0_payload}),
    .dst_wake(b_lane_rcu_res_c01_wake), .dst_credit({b_lane_rcu_res_c01_s3_credit, b_lane_rcu_res_c01_s2_credit, b_lane_rcu_res_c01_s1_credit, b_lane_rcu_res_c01_s0_credit}), .dst_stall({b_lane_rcu_res_c01_s3_stall, b_lane_rcu_res_c01_s2_stall, b_lane_rcu_res_c01_s1_stall, b_lane_rcu_res_c01_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c01_s3_tid, lane_rcu_res_c01_s2_tid, lane_rcu_res_c01_s1_tid, lane_rcu_res_c01_s0_tid}), .dst_tid({b_lane_rcu_res_c01_s3_tid, b_lane_rcu_res_c01_s2_tid, b_lane_rcu_res_c01_s1_tid, b_lane_rcu_res_c01_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C02), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c02 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c02_s3_valid, lane_rcu_res_c02_s2_valid, lane_rcu_res_c02_s1_valid, lane_rcu_res_c02_s0_valid}), .src_payload({lane_rcu_res_c02_s3_payload, lane_rcu_res_c02_s2_payload, lane_rcu_res_c02_s1_payload, lane_rcu_res_c02_s0_payload}),
    .src_wake(lane_rcu_res_c02_wake), .src_credit({lane_rcu_res_c02_s3_credit, lane_rcu_res_c02_s2_credit, lane_rcu_res_c02_s1_credit, lane_rcu_res_c02_s0_credit}), .src_stall({lane_rcu_res_c02_s3_stall, lane_rcu_res_c02_s2_stall, lane_rcu_res_c02_s1_stall, lane_rcu_res_c02_s0_stall}),
    .dst_valid({b_lane_rcu_res_c02_s3_valid, b_lane_rcu_res_c02_s2_valid, b_lane_rcu_res_c02_s1_valid, b_lane_rcu_res_c02_s0_valid}), .dst_payload({b_lane_rcu_res_c02_s3_payload, b_lane_rcu_res_c02_s2_payload, b_lane_rcu_res_c02_s1_payload, b_lane_rcu_res_c02_s0_payload}),
    .dst_wake(b_lane_rcu_res_c02_wake), .dst_credit({b_lane_rcu_res_c02_s3_credit, b_lane_rcu_res_c02_s2_credit, b_lane_rcu_res_c02_s1_credit, b_lane_rcu_res_c02_s0_credit}), .dst_stall({b_lane_rcu_res_c02_s3_stall, b_lane_rcu_res_c02_s2_stall, b_lane_rcu_res_c02_s1_stall, b_lane_rcu_res_c02_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c02_s3_tid, lane_rcu_res_c02_s2_tid, lane_rcu_res_c02_s1_tid, lane_rcu_res_c02_s0_tid}), .dst_tid({b_lane_rcu_res_c02_s3_tid, b_lane_rcu_res_c02_s2_tid, b_lane_rcu_res_c02_s1_tid, b_lane_rcu_res_c02_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C03), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c03 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c03_s3_valid, lane_rcu_res_c03_s2_valid, lane_rcu_res_c03_s1_valid, lane_rcu_res_c03_s0_valid}), .src_payload({lane_rcu_res_c03_s3_payload, lane_rcu_res_c03_s2_payload, lane_rcu_res_c03_s1_payload, lane_rcu_res_c03_s0_payload}),
    .src_wake(lane_rcu_res_c03_wake), .src_credit({lane_rcu_res_c03_s3_credit, lane_rcu_res_c03_s2_credit, lane_rcu_res_c03_s1_credit, lane_rcu_res_c03_s0_credit}), .src_stall({lane_rcu_res_c03_s3_stall, lane_rcu_res_c03_s2_stall, lane_rcu_res_c03_s1_stall, lane_rcu_res_c03_s0_stall}),
    .dst_valid({b_lane_rcu_res_c03_s3_valid, b_lane_rcu_res_c03_s2_valid, b_lane_rcu_res_c03_s1_valid, b_lane_rcu_res_c03_s0_valid}), .dst_payload({b_lane_rcu_res_c03_s3_payload, b_lane_rcu_res_c03_s2_payload, b_lane_rcu_res_c03_s1_payload, b_lane_rcu_res_c03_s0_payload}),
    .dst_wake(b_lane_rcu_res_c03_wake), .dst_credit({b_lane_rcu_res_c03_s3_credit, b_lane_rcu_res_c03_s2_credit, b_lane_rcu_res_c03_s1_credit, b_lane_rcu_res_c03_s0_credit}), .dst_stall({b_lane_rcu_res_c03_s3_stall, b_lane_rcu_res_c03_s2_stall, b_lane_rcu_res_c03_s1_stall, b_lane_rcu_res_c03_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c03_s3_tid, lane_rcu_res_c03_s2_tid, lane_rcu_res_c03_s1_tid, lane_rcu_res_c03_s0_tid}), .dst_tid({b_lane_rcu_res_c03_s3_tid, b_lane_rcu_res_c03_s2_tid, b_lane_rcu_res_c03_s1_tid, b_lane_rcu_res_c03_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C04), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c04 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c04_s3_valid, lane_rcu_res_c04_s2_valid, lane_rcu_res_c04_s1_valid, lane_rcu_res_c04_s0_valid}), .src_payload({lane_rcu_res_c04_s3_payload, lane_rcu_res_c04_s2_payload, lane_rcu_res_c04_s1_payload, lane_rcu_res_c04_s0_payload}),
    .src_wake(lane_rcu_res_c04_wake), .src_credit({lane_rcu_res_c04_s3_credit, lane_rcu_res_c04_s2_credit, lane_rcu_res_c04_s1_credit, lane_rcu_res_c04_s0_credit}), .src_stall({lane_rcu_res_c04_s3_stall, lane_rcu_res_c04_s2_stall, lane_rcu_res_c04_s1_stall, lane_rcu_res_c04_s0_stall}),
    .dst_valid({b_lane_rcu_res_c04_s3_valid, b_lane_rcu_res_c04_s2_valid, b_lane_rcu_res_c04_s1_valid, b_lane_rcu_res_c04_s0_valid}), .dst_payload({b_lane_rcu_res_c04_s3_payload, b_lane_rcu_res_c04_s2_payload, b_lane_rcu_res_c04_s1_payload, b_lane_rcu_res_c04_s0_payload}),
    .dst_wake(b_lane_rcu_res_c04_wake), .dst_credit({b_lane_rcu_res_c04_s3_credit, b_lane_rcu_res_c04_s2_credit, b_lane_rcu_res_c04_s1_credit, b_lane_rcu_res_c04_s0_credit}), .dst_stall({b_lane_rcu_res_c04_s3_stall, b_lane_rcu_res_c04_s2_stall, b_lane_rcu_res_c04_s1_stall, b_lane_rcu_res_c04_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c04_s3_tid, lane_rcu_res_c04_s2_tid, lane_rcu_res_c04_s1_tid, lane_rcu_res_c04_s0_tid}), .dst_tid({b_lane_rcu_res_c04_s3_tid, b_lane_rcu_res_c04_s2_tid, b_lane_rcu_res_c04_s1_tid, b_lane_rcu_res_c04_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C05), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c05 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c05_s3_valid, lane_rcu_res_c05_s2_valid, lane_rcu_res_c05_s1_valid, lane_rcu_res_c05_s0_valid}), .src_payload({lane_rcu_res_c05_s3_payload, lane_rcu_res_c05_s2_payload, lane_rcu_res_c05_s1_payload, lane_rcu_res_c05_s0_payload}),
    .src_wake(lane_rcu_res_c05_wake), .src_credit({lane_rcu_res_c05_s3_credit, lane_rcu_res_c05_s2_credit, lane_rcu_res_c05_s1_credit, lane_rcu_res_c05_s0_credit}), .src_stall({lane_rcu_res_c05_s3_stall, lane_rcu_res_c05_s2_stall, lane_rcu_res_c05_s1_stall, lane_rcu_res_c05_s0_stall}),
    .dst_valid({b_lane_rcu_res_c05_s3_valid, b_lane_rcu_res_c05_s2_valid, b_lane_rcu_res_c05_s1_valid, b_lane_rcu_res_c05_s0_valid}), .dst_payload({b_lane_rcu_res_c05_s3_payload, b_lane_rcu_res_c05_s2_payload, b_lane_rcu_res_c05_s1_payload, b_lane_rcu_res_c05_s0_payload}),
    .dst_wake(b_lane_rcu_res_c05_wake), .dst_credit({b_lane_rcu_res_c05_s3_credit, b_lane_rcu_res_c05_s2_credit, b_lane_rcu_res_c05_s1_credit, b_lane_rcu_res_c05_s0_credit}), .dst_stall({b_lane_rcu_res_c05_s3_stall, b_lane_rcu_res_c05_s2_stall, b_lane_rcu_res_c05_s1_stall, b_lane_rcu_res_c05_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c05_s3_tid, lane_rcu_res_c05_s2_tid, lane_rcu_res_c05_s1_tid, lane_rcu_res_c05_s0_tid}), .dst_tid({b_lane_rcu_res_c05_s3_tid, b_lane_rcu_res_c05_s2_tid, b_lane_rcu_res_c05_s1_tid, b_lane_rcu_res_c05_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C06), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c06 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c06_s3_valid, lane_rcu_res_c06_s2_valid, lane_rcu_res_c06_s1_valid, lane_rcu_res_c06_s0_valid}), .src_payload({lane_rcu_res_c06_s3_payload, lane_rcu_res_c06_s2_payload, lane_rcu_res_c06_s1_payload, lane_rcu_res_c06_s0_payload}),
    .src_wake(lane_rcu_res_c06_wake), .src_credit({lane_rcu_res_c06_s3_credit, lane_rcu_res_c06_s2_credit, lane_rcu_res_c06_s1_credit, lane_rcu_res_c06_s0_credit}), .src_stall({lane_rcu_res_c06_s3_stall, lane_rcu_res_c06_s2_stall, lane_rcu_res_c06_s1_stall, lane_rcu_res_c06_s0_stall}),
    .dst_valid({b_lane_rcu_res_c06_s3_valid, b_lane_rcu_res_c06_s2_valid, b_lane_rcu_res_c06_s1_valid, b_lane_rcu_res_c06_s0_valid}), .dst_payload({b_lane_rcu_res_c06_s3_payload, b_lane_rcu_res_c06_s2_payload, b_lane_rcu_res_c06_s1_payload, b_lane_rcu_res_c06_s0_payload}),
    .dst_wake(b_lane_rcu_res_c06_wake), .dst_credit({b_lane_rcu_res_c06_s3_credit, b_lane_rcu_res_c06_s2_credit, b_lane_rcu_res_c06_s1_credit, b_lane_rcu_res_c06_s0_credit}), .dst_stall({b_lane_rcu_res_c06_s3_stall, b_lane_rcu_res_c06_s2_stall, b_lane_rcu_res_c06_s1_stall, b_lane_rcu_res_c06_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c06_s3_tid, lane_rcu_res_c06_s2_tid, lane_rcu_res_c06_s1_tid, lane_rcu_res_c06_s0_tid}), .dst_tid({b_lane_rcu_res_c06_s3_tid, b_lane_rcu_res_c06_s2_tid, b_lane_rcu_res_c06_s1_tid, b_lane_rcu_res_c06_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C07), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c07 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c07_s3_valid, lane_rcu_res_c07_s2_valid, lane_rcu_res_c07_s1_valid, lane_rcu_res_c07_s0_valid}), .src_payload({lane_rcu_res_c07_s3_payload, lane_rcu_res_c07_s2_payload, lane_rcu_res_c07_s1_payload, lane_rcu_res_c07_s0_payload}),
    .src_wake(lane_rcu_res_c07_wake), .src_credit({lane_rcu_res_c07_s3_credit, lane_rcu_res_c07_s2_credit, lane_rcu_res_c07_s1_credit, lane_rcu_res_c07_s0_credit}), .src_stall({lane_rcu_res_c07_s3_stall, lane_rcu_res_c07_s2_stall, lane_rcu_res_c07_s1_stall, lane_rcu_res_c07_s0_stall}),
    .dst_valid({b_lane_rcu_res_c07_s3_valid, b_lane_rcu_res_c07_s2_valid, b_lane_rcu_res_c07_s1_valid, b_lane_rcu_res_c07_s0_valid}), .dst_payload({b_lane_rcu_res_c07_s3_payload, b_lane_rcu_res_c07_s2_payload, b_lane_rcu_res_c07_s1_payload, b_lane_rcu_res_c07_s0_payload}),
    .dst_wake(b_lane_rcu_res_c07_wake), .dst_credit({b_lane_rcu_res_c07_s3_credit, b_lane_rcu_res_c07_s2_credit, b_lane_rcu_res_c07_s1_credit, b_lane_rcu_res_c07_s0_credit}), .dst_stall({b_lane_rcu_res_c07_s3_stall, b_lane_rcu_res_c07_s2_stall, b_lane_rcu_res_c07_s1_stall, b_lane_rcu_res_c07_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c07_s3_tid, lane_rcu_res_c07_s2_tid, lane_rcu_res_c07_s1_tid, lane_rcu_res_c07_s0_tid}), .dst_tid({b_lane_rcu_res_c07_s3_tid, b_lane_rcu_res_c07_s2_tid, b_lane_rcu_res_c07_s1_tid, b_lane_rcu_res_c07_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C08), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c08 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c08_s3_valid, lane_rcu_res_c08_s2_valid, lane_rcu_res_c08_s1_valid, lane_rcu_res_c08_s0_valid}), .src_payload({lane_rcu_res_c08_s3_payload, lane_rcu_res_c08_s2_payload, lane_rcu_res_c08_s1_payload, lane_rcu_res_c08_s0_payload}),
    .src_wake(lane_rcu_res_c08_wake), .src_credit({lane_rcu_res_c08_s3_credit, lane_rcu_res_c08_s2_credit, lane_rcu_res_c08_s1_credit, lane_rcu_res_c08_s0_credit}), .src_stall({lane_rcu_res_c08_s3_stall, lane_rcu_res_c08_s2_stall, lane_rcu_res_c08_s1_stall, lane_rcu_res_c08_s0_stall}),
    .dst_valid({b_lane_rcu_res_c08_s3_valid, b_lane_rcu_res_c08_s2_valid, b_lane_rcu_res_c08_s1_valid, b_lane_rcu_res_c08_s0_valid}), .dst_payload({b_lane_rcu_res_c08_s3_payload, b_lane_rcu_res_c08_s2_payload, b_lane_rcu_res_c08_s1_payload, b_lane_rcu_res_c08_s0_payload}),
    .dst_wake(b_lane_rcu_res_c08_wake), .dst_credit({b_lane_rcu_res_c08_s3_credit, b_lane_rcu_res_c08_s2_credit, b_lane_rcu_res_c08_s1_credit, b_lane_rcu_res_c08_s0_credit}), .dst_stall({b_lane_rcu_res_c08_s3_stall, b_lane_rcu_res_c08_s2_stall, b_lane_rcu_res_c08_s1_stall, b_lane_rcu_res_c08_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c08_s3_tid, lane_rcu_res_c08_s2_tid, lane_rcu_res_c08_s1_tid, lane_rcu_res_c08_s0_tid}), .dst_tid({b_lane_rcu_res_c08_s3_tid, b_lane_rcu_res_c08_s2_tid, b_lane_rcu_res_c08_s1_tid, b_lane_rcu_res_c08_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C09), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c09 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c09_s3_valid, lane_rcu_res_c09_s2_valid, lane_rcu_res_c09_s1_valid, lane_rcu_res_c09_s0_valid}), .src_payload({lane_rcu_res_c09_s3_payload, lane_rcu_res_c09_s2_payload, lane_rcu_res_c09_s1_payload, lane_rcu_res_c09_s0_payload}),
    .src_wake(lane_rcu_res_c09_wake), .src_credit({lane_rcu_res_c09_s3_credit, lane_rcu_res_c09_s2_credit, lane_rcu_res_c09_s1_credit, lane_rcu_res_c09_s0_credit}), .src_stall({lane_rcu_res_c09_s3_stall, lane_rcu_res_c09_s2_stall, lane_rcu_res_c09_s1_stall, lane_rcu_res_c09_s0_stall}),
    .dst_valid({b_lane_rcu_res_c09_s3_valid, b_lane_rcu_res_c09_s2_valid, b_lane_rcu_res_c09_s1_valid, b_lane_rcu_res_c09_s0_valid}), .dst_payload({b_lane_rcu_res_c09_s3_payload, b_lane_rcu_res_c09_s2_payload, b_lane_rcu_res_c09_s1_payload, b_lane_rcu_res_c09_s0_payload}),
    .dst_wake(b_lane_rcu_res_c09_wake), .dst_credit({b_lane_rcu_res_c09_s3_credit, b_lane_rcu_res_c09_s2_credit, b_lane_rcu_res_c09_s1_credit, b_lane_rcu_res_c09_s0_credit}), .dst_stall({b_lane_rcu_res_c09_s3_stall, b_lane_rcu_res_c09_s2_stall, b_lane_rcu_res_c09_s1_stall, b_lane_rcu_res_c09_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c09_s3_tid, lane_rcu_res_c09_s2_tid, lane_rcu_res_c09_s1_tid, lane_rcu_res_c09_s0_tid}), .dst_tid({b_lane_rcu_res_c09_s3_tid, b_lane_rcu_res_c09_s2_tid, b_lane_rcu_res_c09_s1_tid, b_lane_rcu_res_c09_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C10), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c10 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c10_s3_valid, lane_rcu_res_c10_s2_valid, lane_rcu_res_c10_s1_valid, lane_rcu_res_c10_s0_valid}), .src_payload({lane_rcu_res_c10_s3_payload, lane_rcu_res_c10_s2_payload, lane_rcu_res_c10_s1_payload, lane_rcu_res_c10_s0_payload}),
    .src_wake(lane_rcu_res_c10_wake), .src_credit({lane_rcu_res_c10_s3_credit, lane_rcu_res_c10_s2_credit, lane_rcu_res_c10_s1_credit, lane_rcu_res_c10_s0_credit}), .src_stall({lane_rcu_res_c10_s3_stall, lane_rcu_res_c10_s2_stall, lane_rcu_res_c10_s1_stall, lane_rcu_res_c10_s0_stall}),
    .dst_valid({b_lane_rcu_res_c10_s3_valid, b_lane_rcu_res_c10_s2_valid, b_lane_rcu_res_c10_s1_valid, b_lane_rcu_res_c10_s0_valid}), .dst_payload({b_lane_rcu_res_c10_s3_payload, b_lane_rcu_res_c10_s2_payload, b_lane_rcu_res_c10_s1_payload, b_lane_rcu_res_c10_s0_payload}),
    .dst_wake(b_lane_rcu_res_c10_wake), .dst_credit({b_lane_rcu_res_c10_s3_credit, b_lane_rcu_res_c10_s2_credit, b_lane_rcu_res_c10_s1_credit, b_lane_rcu_res_c10_s0_credit}), .dst_stall({b_lane_rcu_res_c10_s3_stall, b_lane_rcu_res_c10_s2_stall, b_lane_rcu_res_c10_s1_stall, b_lane_rcu_res_c10_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c10_s3_tid, lane_rcu_res_c10_s2_tid, lane_rcu_res_c10_s1_tid, lane_rcu_res_c10_s0_tid}), .dst_tid({b_lane_rcu_res_c10_s3_tid, b_lane_rcu_res_c10_s2_tid, b_lane_rcu_res_c10_s1_tid, b_lane_rcu_res_c10_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C11), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c11 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c11_s3_valid, lane_rcu_res_c11_s2_valid, lane_rcu_res_c11_s1_valid, lane_rcu_res_c11_s0_valid}), .src_payload({lane_rcu_res_c11_s3_payload, lane_rcu_res_c11_s2_payload, lane_rcu_res_c11_s1_payload, lane_rcu_res_c11_s0_payload}),
    .src_wake(lane_rcu_res_c11_wake), .src_credit({lane_rcu_res_c11_s3_credit, lane_rcu_res_c11_s2_credit, lane_rcu_res_c11_s1_credit, lane_rcu_res_c11_s0_credit}), .src_stall({lane_rcu_res_c11_s3_stall, lane_rcu_res_c11_s2_stall, lane_rcu_res_c11_s1_stall, lane_rcu_res_c11_s0_stall}),
    .dst_valid({b_lane_rcu_res_c11_s3_valid, b_lane_rcu_res_c11_s2_valid, b_lane_rcu_res_c11_s1_valid, b_lane_rcu_res_c11_s0_valid}), .dst_payload({b_lane_rcu_res_c11_s3_payload, b_lane_rcu_res_c11_s2_payload, b_lane_rcu_res_c11_s1_payload, b_lane_rcu_res_c11_s0_payload}),
    .dst_wake(b_lane_rcu_res_c11_wake), .dst_credit({b_lane_rcu_res_c11_s3_credit, b_lane_rcu_res_c11_s2_credit, b_lane_rcu_res_c11_s1_credit, b_lane_rcu_res_c11_s0_credit}), .dst_stall({b_lane_rcu_res_c11_s3_stall, b_lane_rcu_res_c11_s2_stall, b_lane_rcu_res_c11_s1_stall, b_lane_rcu_res_c11_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c11_s3_tid, lane_rcu_res_c11_s2_tid, lane_rcu_res_c11_s1_tid, lane_rcu_res_c11_s0_tid}), .dst_tid({b_lane_rcu_res_c11_s3_tid, b_lane_rcu_res_c11_s2_tid, b_lane_rcu_res_c11_s1_tid, b_lane_rcu_res_c11_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C12), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c12 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c12_s3_valid, lane_rcu_res_c12_s2_valid, lane_rcu_res_c12_s1_valid, lane_rcu_res_c12_s0_valid}), .src_payload({lane_rcu_res_c12_s3_payload, lane_rcu_res_c12_s2_payload, lane_rcu_res_c12_s1_payload, lane_rcu_res_c12_s0_payload}),
    .src_wake(lane_rcu_res_c12_wake), .src_credit({lane_rcu_res_c12_s3_credit, lane_rcu_res_c12_s2_credit, lane_rcu_res_c12_s1_credit, lane_rcu_res_c12_s0_credit}), .src_stall({lane_rcu_res_c12_s3_stall, lane_rcu_res_c12_s2_stall, lane_rcu_res_c12_s1_stall, lane_rcu_res_c12_s0_stall}),
    .dst_valid({b_lane_rcu_res_c12_s3_valid, b_lane_rcu_res_c12_s2_valid, b_lane_rcu_res_c12_s1_valid, b_lane_rcu_res_c12_s0_valid}), .dst_payload({b_lane_rcu_res_c12_s3_payload, b_lane_rcu_res_c12_s2_payload, b_lane_rcu_res_c12_s1_payload, b_lane_rcu_res_c12_s0_payload}),
    .dst_wake(b_lane_rcu_res_c12_wake), .dst_credit({b_lane_rcu_res_c12_s3_credit, b_lane_rcu_res_c12_s2_credit, b_lane_rcu_res_c12_s1_credit, b_lane_rcu_res_c12_s0_credit}), .dst_stall({b_lane_rcu_res_c12_s3_stall, b_lane_rcu_res_c12_s2_stall, b_lane_rcu_res_c12_s1_stall, b_lane_rcu_res_c12_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c12_s3_tid, lane_rcu_res_c12_s2_tid, lane_rcu_res_c12_s1_tid, lane_rcu_res_c12_s0_tid}), .dst_tid({b_lane_rcu_res_c12_s3_tid, b_lane_rcu_res_c12_s2_tid, b_lane_rcu_res_c12_s1_tid, b_lane_rcu_res_c12_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C13), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c13 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c13_s3_valid, lane_rcu_res_c13_s2_valid, lane_rcu_res_c13_s1_valid, lane_rcu_res_c13_s0_valid}), .src_payload({lane_rcu_res_c13_s3_payload, lane_rcu_res_c13_s2_payload, lane_rcu_res_c13_s1_payload, lane_rcu_res_c13_s0_payload}),
    .src_wake(lane_rcu_res_c13_wake), .src_credit({lane_rcu_res_c13_s3_credit, lane_rcu_res_c13_s2_credit, lane_rcu_res_c13_s1_credit, lane_rcu_res_c13_s0_credit}), .src_stall({lane_rcu_res_c13_s3_stall, lane_rcu_res_c13_s2_stall, lane_rcu_res_c13_s1_stall, lane_rcu_res_c13_s0_stall}),
    .dst_valid({b_lane_rcu_res_c13_s3_valid, b_lane_rcu_res_c13_s2_valid, b_lane_rcu_res_c13_s1_valid, b_lane_rcu_res_c13_s0_valid}), .dst_payload({b_lane_rcu_res_c13_s3_payload, b_lane_rcu_res_c13_s2_payload, b_lane_rcu_res_c13_s1_payload, b_lane_rcu_res_c13_s0_payload}),
    .dst_wake(b_lane_rcu_res_c13_wake), .dst_credit({b_lane_rcu_res_c13_s3_credit, b_lane_rcu_res_c13_s2_credit, b_lane_rcu_res_c13_s1_credit, b_lane_rcu_res_c13_s0_credit}), .dst_stall({b_lane_rcu_res_c13_s3_stall, b_lane_rcu_res_c13_s2_stall, b_lane_rcu_res_c13_s1_stall, b_lane_rcu_res_c13_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c13_s3_tid, lane_rcu_res_c13_s2_tid, lane_rcu_res_c13_s1_tid, lane_rcu_res_c13_s0_tid}), .dst_tid({b_lane_rcu_res_c13_s3_tid, b_lane_rcu_res_c13_s2_tid, b_lane_rcu_res_c13_s1_tid, b_lane_rcu_res_c13_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C14), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c14 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c14_s3_valid, lane_rcu_res_c14_s2_valid, lane_rcu_res_c14_s1_valid, lane_rcu_res_c14_s0_valid}), .src_payload({lane_rcu_res_c14_s3_payload, lane_rcu_res_c14_s2_payload, lane_rcu_res_c14_s1_payload, lane_rcu_res_c14_s0_payload}),
    .src_wake(lane_rcu_res_c14_wake), .src_credit({lane_rcu_res_c14_s3_credit, lane_rcu_res_c14_s2_credit, lane_rcu_res_c14_s1_credit, lane_rcu_res_c14_s0_credit}), .src_stall({lane_rcu_res_c14_s3_stall, lane_rcu_res_c14_s2_stall, lane_rcu_res_c14_s1_stall, lane_rcu_res_c14_s0_stall}),
    .dst_valid({b_lane_rcu_res_c14_s3_valid, b_lane_rcu_res_c14_s2_valid, b_lane_rcu_res_c14_s1_valid, b_lane_rcu_res_c14_s0_valid}), .dst_payload({b_lane_rcu_res_c14_s3_payload, b_lane_rcu_res_c14_s2_payload, b_lane_rcu_res_c14_s1_payload, b_lane_rcu_res_c14_s0_payload}),
    .dst_wake(b_lane_rcu_res_c14_wake), .dst_credit({b_lane_rcu_res_c14_s3_credit, b_lane_rcu_res_c14_s2_credit, b_lane_rcu_res_c14_s1_credit, b_lane_rcu_res_c14_s0_credit}), .dst_stall({b_lane_rcu_res_c14_s3_stall, b_lane_rcu_res_c14_s2_stall, b_lane_rcu_res_c14_s1_stall, b_lane_rcu_res_c14_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c14_s3_tid, lane_rcu_res_c14_s2_tid, lane_rcu_res_c14_s1_tid, lane_rcu_res_c14_s0_tid}), .dst_tid({b_lane_rcu_res_c14_s3_tid, b_lane_rcu_res_c14_s2_tid, b_lane_rcu_res_c14_s1_tid, b_lane_rcu_res_c14_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C15), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c15 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c15_s3_valid, lane_rcu_res_c15_s2_valid, lane_rcu_res_c15_s1_valid, lane_rcu_res_c15_s0_valid}), .src_payload({lane_rcu_res_c15_s3_payload, lane_rcu_res_c15_s2_payload, lane_rcu_res_c15_s1_payload, lane_rcu_res_c15_s0_payload}),
    .src_wake(lane_rcu_res_c15_wake), .src_credit({lane_rcu_res_c15_s3_credit, lane_rcu_res_c15_s2_credit, lane_rcu_res_c15_s1_credit, lane_rcu_res_c15_s0_credit}), .src_stall({lane_rcu_res_c15_s3_stall, lane_rcu_res_c15_s2_stall, lane_rcu_res_c15_s1_stall, lane_rcu_res_c15_s0_stall}),
    .dst_valid({b_lane_rcu_res_c15_s3_valid, b_lane_rcu_res_c15_s2_valid, b_lane_rcu_res_c15_s1_valid, b_lane_rcu_res_c15_s0_valid}), .dst_payload({b_lane_rcu_res_c15_s3_payload, b_lane_rcu_res_c15_s2_payload, b_lane_rcu_res_c15_s1_payload, b_lane_rcu_res_c15_s0_payload}),
    .dst_wake(b_lane_rcu_res_c15_wake), .dst_credit({b_lane_rcu_res_c15_s3_credit, b_lane_rcu_res_c15_s2_credit, b_lane_rcu_res_c15_s1_credit, b_lane_rcu_res_c15_s0_credit}), .dst_stall({b_lane_rcu_res_c15_s3_stall, b_lane_rcu_res_c15_s2_stall, b_lane_rcu_res_c15_s1_stall, b_lane_rcu_res_c15_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c15_s3_tid, lane_rcu_res_c15_s2_tid, lane_rcu_res_c15_s1_tid, lane_rcu_res_c15_s0_tid}), .dst_tid({b_lane_rcu_res_c15_s3_tid, b_lane_rcu_res_c15_s2_tid, b_lane_rcu_res_c15_s1_tid, b_lane_rcu_res_c15_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C16), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c16 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c16_s3_valid, lane_rcu_res_c16_s2_valid, lane_rcu_res_c16_s1_valid, lane_rcu_res_c16_s0_valid}), .src_payload({lane_rcu_res_c16_s3_payload, lane_rcu_res_c16_s2_payload, lane_rcu_res_c16_s1_payload, lane_rcu_res_c16_s0_payload}),
    .src_wake(lane_rcu_res_c16_wake), .src_credit({lane_rcu_res_c16_s3_credit, lane_rcu_res_c16_s2_credit, lane_rcu_res_c16_s1_credit, lane_rcu_res_c16_s0_credit}), .src_stall({lane_rcu_res_c16_s3_stall, lane_rcu_res_c16_s2_stall, lane_rcu_res_c16_s1_stall, lane_rcu_res_c16_s0_stall}),
    .dst_valid({b_lane_rcu_res_c16_s3_valid, b_lane_rcu_res_c16_s2_valid, b_lane_rcu_res_c16_s1_valid, b_lane_rcu_res_c16_s0_valid}), .dst_payload({b_lane_rcu_res_c16_s3_payload, b_lane_rcu_res_c16_s2_payload, b_lane_rcu_res_c16_s1_payload, b_lane_rcu_res_c16_s0_payload}),
    .dst_wake(b_lane_rcu_res_c16_wake), .dst_credit({b_lane_rcu_res_c16_s3_credit, b_lane_rcu_res_c16_s2_credit, b_lane_rcu_res_c16_s1_credit, b_lane_rcu_res_c16_s0_credit}), .dst_stall({b_lane_rcu_res_c16_s3_stall, b_lane_rcu_res_c16_s2_stall, b_lane_rcu_res_c16_s1_stall, b_lane_rcu_res_c16_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c16_s3_tid, lane_rcu_res_c16_s2_tid, lane_rcu_res_c16_s1_tid, lane_rcu_res_c16_s0_tid}), .dst_tid({b_lane_rcu_res_c16_s3_tid, b_lane_rcu_res_c16_s2_tid, b_lane_rcu_res_c16_s1_tid, b_lane_rcu_res_c16_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C17), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c17 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c17_s3_valid, lane_rcu_res_c17_s2_valid, lane_rcu_res_c17_s1_valid, lane_rcu_res_c17_s0_valid}), .src_payload({lane_rcu_res_c17_s3_payload, lane_rcu_res_c17_s2_payload, lane_rcu_res_c17_s1_payload, lane_rcu_res_c17_s0_payload}),
    .src_wake(lane_rcu_res_c17_wake), .src_credit({lane_rcu_res_c17_s3_credit, lane_rcu_res_c17_s2_credit, lane_rcu_res_c17_s1_credit, lane_rcu_res_c17_s0_credit}), .src_stall({lane_rcu_res_c17_s3_stall, lane_rcu_res_c17_s2_stall, lane_rcu_res_c17_s1_stall, lane_rcu_res_c17_s0_stall}),
    .dst_valid({b_lane_rcu_res_c17_s3_valid, b_lane_rcu_res_c17_s2_valid, b_lane_rcu_res_c17_s1_valid, b_lane_rcu_res_c17_s0_valid}), .dst_payload({b_lane_rcu_res_c17_s3_payload, b_lane_rcu_res_c17_s2_payload, b_lane_rcu_res_c17_s1_payload, b_lane_rcu_res_c17_s0_payload}),
    .dst_wake(b_lane_rcu_res_c17_wake), .dst_credit({b_lane_rcu_res_c17_s3_credit, b_lane_rcu_res_c17_s2_credit, b_lane_rcu_res_c17_s1_credit, b_lane_rcu_res_c17_s0_credit}), .dst_stall({b_lane_rcu_res_c17_s3_stall, b_lane_rcu_res_c17_s2_stall, b_lane_rcu_res_c17_s1_stall, b_lane_rcu_res_c17_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c17_s3_tid, lane_rcu_res_c17_s2_tid, lane_rcu_res_c17_s1_tid, lane_rcu_res_c17_s0_tid}), .dst_tid({b_lane_rcu_res_c17_s3_tid, b_lane_rcu_res_c17_s2_tid, b_lane_rcu_res_c17_s1_tid, b_lane_rcu_res_c17_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C18), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c18 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c18_s3_valid, lane_rcu_res_c18_s2_valid, lane_rcu_res_c18_s1_valid, lane_rcu_res_c18_s0_valid}), .src_payload({lane_rcu_res_c18_s3_payload, lane_rcu_res_c18_s2_payload, lane_rcu_res_c18_s1_payload, lane_rcu_res_c18_s0_payload}),
    .src_wake(lane_rcu_res_c18_wake), .src_credit({lane_rcu_res_c18_s3_credit, lane_rcu_res_c18_s2_credit, lane_rcu_res_c18_s1_credit, lane_rcu_res_c18_s0_credit}), .src_stall({lane_rcu_res_c18_s3_stall, lane_rcu_res_c18_s2_stall, lane_rcu_res_c18_s1_stall, lane_rcu_res_c18_s0_stall}),
    .dst_valid({b_lane_rcu_res_c18_s3_valid, b_lane_rcu_res_c18_s2_valid, b_lane_rcu_res_c18_s1_valid, b_lane_rcu_res_c18_s0_valid}), .dst_payload({b_lane_rcu_res_c18_s3_payload, b_lane_rcu_res_c18_s2_payload, b_lane_rcu_res_c18_s1_payload, b_lane_rcu_res_c18_s0_payload}),
    .dst_wake(b_lane_rcu_res_c18_wake), .dst_credit({b_lane_rcu_res_c18_s3_credit, b_lane_rcu_res_c18_s2_credit, b_lane_rcu_res_c18_s1_credit, b_lane_rcu_res_c18_s0_credit}), .dst_stall({b_lane_rcu_res_c18_s3_stall, b_lane_rcu_res_c18_s2_stall, b_lane_rcu_res_c18_s1_stall, b_lane_rcu_res_c18_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c18_s3_tid, lane_rcu_res_c18_s2_tid, lane_rcu_res_c18_s1_tid, lane_rcu_res_c18_s0_tid}), .dst_tid({b_lane_rcu_res_c18_s3_tid, b_lane_rcu_res_c18_s2_tid, b_lane_rcu_res_c18_s1_tid, b_lane_rcu_res_c18_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C19), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c19 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c19_s3_valid, lane_rcu_res_c19_s2_valid, lane_rcu_res_c19_s1_valid, lane_rcu_res_c19_s0_valid}), .src_payload({lane_rcu_res_c19_s3_payload, lane_rcu_res_c19_s2_payload, lane_rcu_res_c19_s1_payload, lane_rcu_res_c19_s0_payload}),
    .src_wake(lane_rcu_res_c19_wake), .src_credit({lane_rcu_res_c19_s3_credit, lane_rcu_res_c19_s2_credit, lane_rcu_res_c19_s1_credit, lane_rcu_res_c19_s0_credit}), .src_stall({lane_rcu_res_c19_s3_stall, lane_rcu_res_c19_s2_stall, lane_rcu_res_c19_s1_stall, lane_rcu_res_c19_s0_stall}),
    .dst_valid({b_lane_rcu_res_c19_s3_valid, b_lane_rcu_res_c19_s2_valid, b_lane_rcu_res_c19_s1_valid, b_lane_rcu_res_c19_s0_valid}), .dst_payload({b_lane_rcu_res_c19_s3_payload, b_lane_rcu_res_c19_s2_payload, b_lane_rcu_res_c19_s1_payload, b_lane_rcu_res_c19_s0_payload}),
    .dst_wake(b_lane_rcu_res_c19_wake), .dst_credit({b_lane_rcu_res_c19_s3_credit, b_lane_rcu_res_c19_s2_credit, b_lane_rcu_res_c19_s1_credit, b_lane_rcu_res_c19_s0_credit}), .dst_stall({b_lane_rcu_res_c19_s3_stall, b_lane_rcu_res_c19_s2_stall, b_lane_rcu_res_c19_s1_stall, b_lane_rcu_res_c19_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c19_s3_tid, lane_rcu_res_c19_s2_tid, lane_rcu_res_c19_s1_tid, lane_rcu_res_c19_s0_tid}), .dst_tid({b_lane_rcu_res_c19_s3_tid, b_lane_rcu_res_c19_s2_tid, b_lane_rcu_res_c19_s1_tid, b_lane_rcu_res_c19_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C20), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c20 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c20_s3_valid, lane_rcu_res_c20_s2_valid, lane_rcu_res_c20_s1_valid, lane_rcu_res_c20_s0_valid}), .src_payload({lane_rcu_res_c20_s3_payload, lane_rcu_res_c20_s2_payload, lane_rcu_res_c20_s1_payload, lane_rcu_res_c20_s0_payload}),
    .src_wake(lane_rcu_res_c20_wake), .src_credit({lane_rcu_res_c20_s3_credit, lane_rcu_res_c20_s2_credit, lane_rcu_res_c20_s1_credit, lane_rcu_res_c20_s0_credit}), .src_stall({lane_rcu_res_c20_s3_stall, lane_rcu_res_c20_s2_stall, lane_rcu_res_c20_s1_stall, lane_rcu_res_c20_s0_stall}),
    .dst_valid({b_lane_rcu_res_c20_s3_valid, b_lane_rcu_res_c20_s2_valid, b_lane_rcu_res_c20_s1_valid, b_lane_rcu_res_c20_s0_valid}), .dst_payload({b_lane_rcu_res_c20_s3_payload, b_lane_rcu_res_c20_s2_payload, b_lane_rcu_res_c20_s1_payload, b_lane_rcu_res_c20_s0_payload}),
    .dst_wake(b_lane_rcu_res_c20_wake), .dst_credit({b_lane_rcu_res_c20_s3_credit, b_lane_rcu_res_c20_s2_credit, b_lane_rcu_res_c20_s1_credit, b_lane_rcu_res_c20_s0_credit}), .dst_stall({b_lane_rcu_res_c20_s3_stall, b_lane_rcu_res_c20_s2_stall, b_lane_rcu_res_c20_s1_stall, b_lane_rcu_res_c20_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c20_s3_tid, lane_rcu_res_c20_s2_tid, lane_rcu_res_c20_s1_tid, lane_rcu_res_c20_s0_tid}), .dst_tid({b_lane_rcu_res_c20_s3_tid, b_lane_rcu_res_c20_s2_tid, b_lane_rcu_res_c20_s1_tid, b_lane_rcu_res_c20_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C21), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c21 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c21_s3_valid, lane_rcu_res_c21_s2_valid, lane_rcu_res_c21_s1_valid, lane_rcu_res_c21_s0_valid}), .src_payload({lane_rcu_res_c21_s3_payload, lane_rcu_res_c21_s2_payload, lane_rcu_res_c21_s1_payload, lane_rcu_res_c21_s0_payload}),
    .src_wake(lane_rcu_res_c21_wake), .src_credit({lane_rcu_res_c21_s3_credit, lane_rcu_res_c21_s2_credit, lane_rcu_res_c21_s1_credit, lane_rcu_res_c21_s0_credit}), .src_stall({lane_rcu_res_c21_s3_stall, lane_rcu_res_c21_s2_stall, lane_rcu_res_c21_s1_stall, lane_rcu_res_c21_s0_stall}),
    .dst_valid({b_lane_rcu_res_c21_s3_valid, b_lane_rcu_res_c21_s2_valid, b_lane_rcu_res_c21_s1_valid, b_lane_rcu_res_c21_s0_valid}), .dst_payload({b_lane_rcu_res_c21_s3_payload, b_lane_rcu_res_c21_s2_payload, b_lane_rcu_res_c21_s1_payload, b_lane_rcu_res_c21_s0_payload}),
    .dst_wake(b_lane_rcu_res_c21_wake), .dst_credit({b_lane_rcu_res_c21_s3_credit, b_lane_rcu_res_c21_s2_credit, b_lane_rcu_res_c21_s1_credit, b_lane_rcu_res_c21_s0_credit}), .dst_stall({b_lane_rcu_res_c21_s3_stall, b_lane_rcu_res_c21_s2_stall, b_lane_rcu_res_c21_s1_stall, b_lane_rcu_res_c21_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c21_s3_tid, lane_rcu_res_c21_s2_tid, lane_rcu_res_c21_s1_tid, lane_rcu_res_c21_s0_tid}), .dst_tid({b_lane_rcu_res_c21_s3_tid, b_lane_rcu_res_c21_s2_tid, b_lane_rcu_res_c21_s1_tid, b_lane_rcu_res_c21_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C22), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c22 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c22_s3_valid, lane_rcu_res_c22_s2_valid, lane_rcu_res_c22_s1_valid, lane_rcu_res_c22_s0_valid}), .src_payload({lane_rcu_res_c22_s3_payload, lane_rcu_res_c22_s2_payload, lane_rcu_res_c22_s1_payload, lane_rcu_res_c22_s0_payload}),
    .src_wake(lane_rcu_res_c22_wake), .src_credit({lane_rcu_res_c22_s3_credit, lane_rcu_res_c22_s2_credit, lane_rcu_res_c22_s1_credit, lane_rcu_res_c22_s0_credit}), .src_stall({lane_rcu_res_c22_s3_stall, lane_rcu_res_c22_s2_stall, lane_rcu_res_c22_s1_stall, lane_rcu_res_c22_s0_stall}),
    .dst_valid({b_lane_rcu_res_c22_s3_valid, b_lane_rcu_res_c22_s2_valid, b_lane_rcu_res_c22_s1_valid, b_lane_rcu_res_c22_s0_valid}), .dst_payload({b_lane_rcu_res_c22_s3_payload, b_lane_rcu_res_c22_s2_payload, b_lane_rcu_res_c22_s1_payload, b_lane_rcu_res_c22_s0_payload}),
    .dst_wake(b_lane_rcu_res_c22_wake), .dst_credit({b_lane_rcu_res_c22_s3_credit, b_lane_rcu_res_c22_s2_credit, b_lane_rcu_res_c22_s1_credit, b_lane_rcu_res_c22_s0_credit}), .dst_stall({b_lane_rcu_res_c22_s3_stall, b_lane_rcu_res_c22_s2_stall, b_lane_rcu_res_c22_s1_stall, b_lane_rcu_res_c22_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c22_s3_tid, lane_rcu_res_c22_s2_tid, lane_rcu_res_c22_s1_tid, lane_rcu_res_c22_s0_tid}), .dst_tid({b_lane_rcu_res_c22_s3_tid, b_lane_rcu_res_c22_s2_tid, b_lane_rcu_res_c22_s1_tid, b_lane_rcu_res_c22_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C23), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c23 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c23_s3_valid, lane_rcu_res_c23_s2_valid, lane_rcu_res_c23_s1_valid, lane_rcu_res_c23_s0_valid}), .src_payload({lane_rcu_res_c23_s3_payload, lane_rcu_res_c23_s2_payload, lane_rcu_res_c23_s1_payload, lane_rcu_res_c23_s0_payload}),
    .src_wake(lane_rcu_res_c23_wake), .src_credit({lane_rcu_res_c23_s3_credit, lane_rcu_res_c23_s2_credit, lane_rcu_res_c23_s1_credit, lane_rcu_res_c23_s0_credit}), .src_stall({lane_rcu_res_c23_s3_stall, lane_rcu_res_c23_s2_stall, lane_rcu_res_c23_s1_stall, lane_rcu_res_c23_s0_stall}),
    .dst_valid({b_lane_rcu_res_c23_s3_valid, b_lane_rcu_res_c23_s2_valid, b_lane_rcu_res_c23_s1_valid, b_lane_rcu_res_c23_s0_valid}), .dst_payload({b_lane_rcu_res_c23_s3_payload, b_lane_rcu_res_c23_s2_payload, b_lane_rcu_res_c23_s1_payload, b_lane_rcu_res_c23_s0_payload}),
    .dst_wake(b_lane_rcu_res_c23_wake), .dst_credit({b_lane_rcu_res_c23_s3_credit, b_lane_rcu_res_c23_s2_credit, b_lane_rcu_res_c23_s1_credit, b_lane_rcu_res_c23_s0_credit}), .dst_stall({b_lane_rcu_res_c23_s3_stall, b_lane_rcu_res_c23_s2_stall, b_lane_rcu_res_c23_s1_stall, b_lane_rcu_res_c23_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c23_s3_tid, lane_rcu_res_c23_s2_tid, lane_rcu_res_c23_s1_tid, lane_rcu_res_c23_s0_tid}), .dst_tid({b_lane_rcu_res_c23_s3_tid, b_lane_rcu_res_c23_s2_tid, b_lane_rcu_res_c23_s1_tid, b_lane_rcu_res_c23_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C24), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c24 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c24_s3_valid, lane_rcu_res_c24_s2_valid, lane_rcu_res_c24_s1_valid, lane_rcu_res_c24_s0_valid}), .src_payload({lane_rcu_res_c24_s3_payload, lane_rcu_res_c24_s2_payload, lane_rcu_res_c24_s1_payload, lane_rcu_res_c24_s0_payload}),
    .src_wake(lane_rcu_res_c24_wake), .src_credit({lane_rcu_res_c24_s3_credit, lane_rcu_res_c24_s2_credit, lane_rcu_res_c24_s1_credit, lane_rcu_res_c24_s0_credit}), .src_stall({lane_rcu_res_c24_s3_stall, lane_rcu_res_c24_s2_stall, lane_rcu_res_c24_s1_stall, lane_rcu_res_c24_s0_stall}),
    .dst_valid({b_lane_rcu_res_c24_s3_valid, b_lane_rcu_res_c24_s2_valid, b_lane_rcu_res_c24_s1_valid, b_lane_rcu_res_c24_s0_valid}), .dst_payload({b_lane_rcu_res_c24_s3_payload, b_lane_rcu_res_c24_s2_payload, b_lane_rcu_res_c24_s1_payload, b_lane_rcu_res_c24_s0_payload}),
    .dst_wake(b_lane_rcu_res_c24_wake), .dst_credit({b_lane_rcu_res_c24_s3_credit, b_lane_rcu_res_c24_s2_credit, b_lane_rcu_res_c24_s1_credit, b_lane_rcu_res_c24_s0_credit}), .dst_stall({b_lane_rcu_res_c24_s3_stall, b_lane_rcu_res_c24_s2_stall, b_lane_rcu_res_c24_s1_stall, b_lane_rcu_res_c24_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c24_s3_tid, lane_rcu_res_c24_s2_tid, lane_rcu_res_c24_s1_tid, lane_rcu_res_c24_s0_tid}), .dst_tid({b_lane_rcu_res_c24_s3_tid, b_lane_rcu_res_c24_s2_tid, b_lane_rcu_res_c24_s1_tid, b_lane_rcu_res_c24_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C25), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c25 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c25_s3_valid, lane_rcu_res_c25_s2_valid, lane_rcu_res_c25_s1_valid, lane_rcu_res_c25_s0_valid}), .src_payload({lane_rcu_res_c25_s3_payload, lane_rcu_res_c25_s2_payload, lane_rcu_res_c25_s1_payload, lane_rcu_res_c25_s0_payload}),
    .src_wake(lane_rcu_res_c25_wake), .src_credit({lane_rcu_res_c25_s3_credit, lane_rcu_res_c25_s2_credit, lane_rcu_res_c25_s1_credit, lane_rcu_res_c25_s0_credit}), .src_stall({lane_rcu_res_c25_s3_stall, lane_rcu_res_c25_s2_stall, lane_rcu_res_c25_s1_stall, lane_rcu_res_c25_s0_stall}),
    .dst_valid({b_lane_rcu_res_c25_s3_valid, b_lane_rcu_res_c25_s2_valid, b_lane_rcu_res_c25_s1_valid, b_lane_rcu_res_c25_s0_valid}), .dst_payload({b_lane_rcu_res_c25_s3_payload, b_lane_rcu_res_c25_s2_payload, b_lane_rcu_res_c25_s1_payload, b_lane_rcu_res_c25_s0_payload}),
    .dst_wake(b_lane_rcu_res_c25_wake), .dst_credit({b_lane_rcu_res_c25_s3_credit, b_lane_rcu_res_c25_s2_credit, b_lane_rcu_res_c25_s1_credit, b_lane_rcu_res_c25_s0_credit}), .dst_stall({b_lane_rcu_res_c25_s3_stall, b_lane_rcu_res_c25_s2_stall, b_lane_rcu_res_c25_s1_stall, b_lane_rcu_res_c25_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c25_s3_tid, lane_rcu_res_c25_s2_tid, lane_rcu_res_c25_s1_tid, lane_rcu_res_c25_s0_tid}), .dst_tid({b_lane_rcu_res_c25_s3_tid, b_lane_rcu_res_c25_s2_tid, b_lane_rcu_res_c25_s1_tid, b_lane_rcu_res_c25_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C26), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c26 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c26_s3_valid, lane_rcu_res_c26_s2_valid, lane_rcu_res_c26_s1_valid, lane_rcu_res_c26_s0_valid}), .src_payload({lane_rcu_res_c26_s3_payload, lane_rcu_res_c26_s2_payload, lane_rcu_res_c26_s1_payload, lane_rcu_res_c26_s0_payload}),
    .src_wake(lane_rcu_res_c26_wake), .src_credit({lane_rcu_res_c26_s3_credit, lane_rcu_res_c26_s2_credit, lane_rcu_res_c26_s1_credit, lane_rcu_res_c26_s0_credit}), .src_stall({lane_rcu_res_c26_s3_stall, lane_rcu_res_c26_s2_stall, lane_rcu_res_c26_s1_stall, lane_rcu_res_c26_s0_stall}),
    .dst_valid({b_lane_rcu_res_c26_s3_valid, b_lane_rcu_res_c26_s2_valid, b_lane_rcu_res_c26_s1_valid, b_lane_rcu_res_c26_s0_valid}), .dst_payload({b_lane_rcu_res_c26_s3_payload, b_lane_rcu_res_c26_s2_payload, b_lane_rcu_res_c26_s1_payload, b_lane_rcu_res_c26_s0_payload}),
    .dst_wake(b_lane_rcu_res_c26_wake), .dst_credit({b_lane_rcu_res_c26_s3_credit, b_lane_rcu_res_c26_s2_credit, b_lane_rcu_res_c26_s1_credit, b_lane_rcu_res_c26_s0_credit}), .dst_stall({b_lane_rcu_res_c26_s3_stall, b_lane_rcu_res_c26_s2_stall, b_lane_rcu_res_c26_s1_stall, b_lane_rcu_res_c26_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c26_s3_tid, lane_rcu_res_c26_s2_tid, lane_rcu_res_c26_s1_tid, lane_rcu_res_c26_s0_tid}), .dst_tid({b_lane_rcu_res_c26_s3_tid, b_lane_rcu_res_c26_s2_tid, b_lane_rcu_res_c26_s1_tid, b_lane_rcu_res_c26_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C27), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c27 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c27_s3_valid, lane_rcu_res_c27_s2_valid, lane_rcu_res_c27_s1_valid, lane_rcu_res_c27_s0_valid}), .src_payload({lane_rcu_res_c27_s3_payload, lane_rcu_res_c27_s2_payload, lane_rcu_res_c27_s1_payload, lane_rcu_res_c27_s0_payload}),
    .src_wake(lane_rcu_res_c27_wake), .src_credit({lane_rcu_res_c27_s3_credit, lane_rcu_res_c27_s2_credit, lane_rcu_res_c27_s1_credit, lane_rcu_res_c27_s0_credit}), .src_stall({lane_rcu_res_c27_s3_stall, lane_rcu_res_c27_s2_stall, lane_rcu_res_c27_s1_stall, lane_rcu_res_c27_s0_stall}),
    .dst_valid({b_lane_rcu_res_c27_s3_valid, b_lane_rcu_res_c27_s2_valid, b_lane_rcu_res_c27_s1_valid, b_lane_rcu_res_c27_s0_valid}), .dst_payload({b_lane_rcu_res_c27_s3_payload, b_lane_rcu_res_c27_s2_payload, b_lane_rcu_res_c27_s1_payload, b_lane_rcu_res_c27_s0_payload}),
    .dst_wake(b_lane_rcu_res_c27_wake), .dst_credit({b_lane_rcu_res_c27_s3_credit, b_lane_rcu_res_c27_s2_credit, b_lane_rcu_res_c27_s1_credit, b_lane_rcu_res_c27_s0_credit}), .dst_stall({b_lane_rcu_res_c27_s3_stall, b_lane_rcu_res_c27_s2_stall, b_lane_rcu_res_c27_s1_stall, b_lane_rcu_res_c27_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c27_s3_tid, lane_rcu_res_c27_s2_tid, lane_rcu_res_c27_s1_tid, lane_rcu_res_c27_s0_tid}), .dst_tid({b_lane_rcu_res_c27_s3_tid, b_lane_rcu_res_c27_s2_tid, b_lane_rcu_res_c27_s1_tid, b_lane_rcu_res_c27_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C28), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c28 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c28_s3_valid, lane_rcu_res_c28_s2_valid, lane_rcu_res_c28_s1_valid, lane_rcu_res_c28_s0_valid}), .src_payload({lane_rcu_res_c28_s3_payload, lane_rcu_res_c28_s2_payload, lane_rcu_res_c28_s1_payload, lane_rcu_res_c28_s0_payload}),
    .src_wake(lane_rcu_res_c28_wake), .src_credit({lane_rcu_res_c28_s3_credit, lane_rcu_res_c28_s2_credit, lane_rcu_res_c28_s1_credit, lane_rcu_res_c28_s0_credit}), .src_stall({lane_rcu_res_c28_s3_stall, lane_rcu_res_c28_s2_stall, lane_rcu_res_c28_s1_stall, lane_rcu_res_c28_s0_stall}),
    .dst_valid({b_lane_rcu_res_c28_s3_valid, b_lane_rcu_res_c28_s2_valid, b_lane_rcu_res_c28_s1_valid, b_lane_rcu_res_c28_s0_valid}), .dst_payload({b_lane_rcu_res_c28_s3_payload, b_lane_rcu_res_c28_s2_payload, b_lane_rcu_res_c28_s1_payload, b_lane_rcu_res_c28_s0_payload}),
    .dst_wake(b_lane_rcu_res_c28_wake), .dst_credit({b_lane_rcu_res_c28_s3_credit, b_lane_rcu_res_c28_s2_credit, b_lane_rcu_res_c28_s1_credit, b_lane_rcu_res_c28_s0_credit}), .dst_stall({b_lane_rcu_res_c28_s3_stall, b_lane_rcu_res_c28_s2_stall, b_lane_rcu_res_c28_s1_stall, b_lane_rcu_res_c28_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c28_s3_tid, lane_rcu_res_c28_s2_tid, lane_rcu_res_c28_s1_tid, lane_rcu_res_c28_s0_tid}), .dst_tid({b_lane_rcu_res_c28_s3_tid, b_lane_rcu_res_c28_s2_tid, b_lane_rcu_res_c28_s1_tid, b_lane_rcu_res_c28_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C29), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c29 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c29_s3_valid, lane_rcu_res_c29_s2_valid, lane_rcu_res_c29_s1_valid, lane_rcu_res_c29_s0_valid}), .src_payload({lane_rcu_res_c29_s3_payload, lane_rcu_res_c29_s2_payload, lane_rcu_res_c29_s1_payload, lane_rcu_res_c29_s0_payload}),
    .src_wake(lane_rcu_res_c29_wake), .src_credit({lane_rcu_res_c29_s3_credit, lane_rcu_res_c29_s2_credit, lane_rcu_res_c29_s1_credit, lane_rcu_res_c29_s0_credit}), .src_stall({lane_rcu_res_c29_s3_stall, lane_rcu_res_c29_s2_stall, lane_rcu_res_c29_s1_stall, lane_rcu_res_c29_s0_stall}),
    .dst_valid({b_lane_rcu_res_c29_s3_valid, b_lane_rcu_res_c29_s2_valid, b_lane_rcu_res_c29_s1_valid, b_lane_rcu_res_c29_s0_valid}), .dst_payload({b_lane_rcu_res_c29_s3_payload, b_lane_rcu_res_c29_s2_payload, b_lane_rcu_res_c29_s1_payload, b_lane_rcu_res_c29_s0_payload}),
    .dst_wake(b_lane_rcu_res_c29_wake), .dst_credit({b_lane_rcu_res_c29_s3_credit, b_lane_rcu_res_c29_s2_credit, b_lane_rcu_res_c29_s1_credit, b_lane_rcu_res_c29_s0_credit}), .dst_stall({b_lane_rcu_res_c29_s3_stall, b_lane_rcu_res_c29_s2_stall, b_lane_rcu_res_c29_s1_stall, b_lane_rcu_res_c29_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c29_s3_tid, lane_rcu_res_c29_s2_tid, lane_rcu_res_c29_s1_tid, lane_rcu_res_c29_s0_tid}), .dst_tid({b_lane_rcu_res_c29_s3_tid, b_lane_rcu_res_c29_s2_tid, b_lane_rcu_res_c29_s1_tid, b_lane_rcu_res_c29_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C30), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c30 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c30_s3_valid, lane_rcu_res_c30_s2_valid, lane_rcu_res_c30_s1_valid, lane_rcu_res_c30_s0_valid}), .src_payload({lane_rcu_res_c30_s3_payload, lane_rcu_res_c30_s2_payload, lane_rcu_res_c30_s1_payload, lane_rcu_res_c30_s0_payload}),
    .src_wake(lane_rcu_res_c30_wake), .src_credit({lane_rcu_res_c30_s3_credit, lane_rcu_res_c30_s2_credit, lane_rcu_res_c30_s1_credit, lane_rcu_res_c30_s0_credit}), .src_stall({lane_rcu_res_c30_s3_stall, lane_rcu_res_c30_s2_stall, lane_rcu_res_c30_s1_stall, lane_rcu_res_c30_s0_stall}),
    .dst_valid({b_lane_rcu_res_c30_s3_valid, b_lane_rcu_res_c30_s2_valid, b_lane_rcu_res_c30_s1_valid, b_lane_rcu_res_c30_s0_valid}), .dst_payload({b_lane_rcu_res_c30_s3_payload, b_lane_rcu_res_c30_s2_payload, b_lane_rcu_res_c30_s1_payload, b_lane_rcu_res_c30_s0_payload}),
    .dst_wake(b_lane_rcu_res_c30_wake), .dst_credit({b_lane_rcu_res_c30_s3_credit, b_lane_rcu_res_c30_s2_credit, b_lane_rcu_res_c30_s1_credit, b_lane_rcu_res_c30_s0_credit}), .dst_stall({b_lane_rcu_res_c30_s3_stall, b_lane_rcu_res_c30_s2_stall, b_lane_rcu_res_c30_s1_stall, b_lane_rcu_res_c30_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c30_s3_tid, lane_rcu_res_c30_s2_tid, lane_rcu_res_c30_s1_tid, lane_rcu_res_c30_s0_tid}), .dst_tid({b_lane_rcu_res_c30_s3_tid, b_lane_rcu_res_c30_s2_tid, b_lane_rcu_res_c30_s1_tid, b_lane_rcu_res_c30_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, destination end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES_C31), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res_c31 (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({lane_rcu_res_c31_s3_valid, lane_rcu_res_c31_s2_valid, lane_rcu_res_c31_s1_valid, lane_rcu_res_c31_s0_valid}), .src_payload({lane_rcu_res_c31_s3_payload, lane_rcu_res_c31_s2_payload, lane_rcu_res_c31_s1_payload, lane_rcu_res_c31_s0_payload}),
    .src_wake(lane_rcu_res_c31_wake), .src_credit({lane_rcu_res_c31_s3_credit, lane_rcu_res_c31_s2_credit, lane_rcu_res_c31_s1_credit, lane_rcu_res_c31_s0_credit}), .src_stall({lane_rcu_res_c31_s3_stall, lane_rcu_res_c31_s2_stall, lane_rcu_res_c31_s1_stall, lane_rcu_res_c31_s0_stall}),
    .dst_valid({b_lane_rcu_res_c31_s3_valid, b_lane_rcu_res_c31_s2_valid, b_lane_rcu_res_c31_s1_valid, b_lane_rcu_res_c31_s0_valid}), .dst_payload({b_lane_rcu_res_c31_s3_payload, b_lane_rcu_res_c31_s2_payload, b_lane_rcu_res_c31_s1_payload, b_lane_rcu_res_c31_s0_payload}),
    .dst_wake(b_lane_rcu_res_c31_wake), .dst_credit({b_lane_rcu_res_c31_s3_credit, b_lane_rcu_res_c31_s2_credit, b_lane_rcu_res_c31_s1_credit, b_lane_rcu_res_c31_s0_credit}), .dst_stall({b_lane_rcu_res_c31_s3_stall, b_lane_rcu_res_c31_s2_stall, b_lane_rcu_res_c31_s1_stall, b_lane_rcu_res_c31_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({lane_rcu_res_c31_s3_tid, lane_rcu_res_c31_s2_tid, lane_rcu_res_c31_s1_tid, lane_rcu_res_c31_s0_tid}), .dst_tid({b_lane_rcu_res_c31_s3_tid, b_lane_rcu_res_c31_s2_tid, b_lane_rcu_res_c31_s1_tid, b_lane_rcu_res_c31_s0_tid})
`endif
  );
  // ccv_rcu_ooe_done, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_OOE_DONE), .SLOTS(4), .PAYLOAD_W(73)) u_rpt_rcu_ooe_done (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_rcu_ooe_done_s3_valid, b_rcu_ooe_done_s2_valid, b_rcu_ooe_done_s1_valid, b_rcu_ooe_done_s0_valid}), .src_payload({b_rcu_ooe_done_s3_payload, b_rcu_ooe_done_s2_payload, b_rcu_ooe_done_s1_payload, b_rcu_ooe_done_s0_payload}),
    .src_wake(b_rcu_ooe_done_wake), .src_credit({b_rcu_ooe_done_s3_credit, b_rcu_ooe_done_s2_credit, b_rcu_ooe_done_s1_credit, b_rcu_ooe_done_s0_credit}), .src_stall({b_rcu_ooe_done_s3_stall, b_rcu_ooe_done_s2_stall, b_rcu_ooe_done_s1_stall, b_rcu_ooe_done_s0_stall}),
    .dst_valid({rcu_ooe_done_s3_valid, rcu_ooe_done_s2_valid, rcu_ooe_done_s1_valid, rcu_ooe_done_s0_valid}), .dst_payload({rcu_ooe_done_s3_payload, rcu_ooe_done_s2_payload, rcu_ooe_done_s1_payload, rcu_ooe_done_s0_payload}),
    .dst_wake(rcu_ooe_done_wake), .dst_credit({rcu_ooe_done_s3_credit, rcu_ooe_done_s2_credit, rcu_ooe_done_s1_credit, rcu_ooe_done_s0_credit}), .dst_stall({rcu_ooe_done_s3_stall, rcu_ooe_done_s2_stall, rcu_ooe_done_s1_stall, rcu_ooe_done_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_rcu_ooe_done_s3_tid, b_rcu_ooe_done_s2_tid, b_rcu_ooe_done_s1_tid, b_rcu_ooe_done_s0_tid}), .dst_tid({rcu_ooe_done_s3_tid, rcu_ooe_done_s2_tid, rcu_ooe_done_s1_tid, rcu_ooe_done_s0_tid})
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
  ccv_seq_rpt #(.STAGES(RPT_MIU_RCU_DATA), .SLOTS(4), .PAYLOAD_W(1112)) u_rpt_miu_rcu_data (
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
  // ccv_rcu_pca_mig, source end
  ccv_seq_rpt #(.STAGES(RPT_RCU_PCA_MIG), .SLOTS(1), .PAYLOAD_W(2057)) u_rpt_rcu_pca_mig (
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
  ccv_seq_rpt #(.STAGES(RPT_PCA_RCU_MIG), .SLOTS(1), .PAYLOAD_W(2057)) u_rpt_pca_rcu_mig (
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
