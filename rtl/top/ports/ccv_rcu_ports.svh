// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_rcu. Included between the parentheses of the
// module header, in the stub and in the real RTL alike.
//
// Channel ports are named by channel, not stage-tagged: stage
// numbers are assigned at 4a, and the tag belongs on the internal
// flop that drives the port. One group per slot:
//   <chan>[_c<NN>][_s<K>]_{valid,payload,credit,stall}, and
//   <chan>[_c<NN>]_wake per channel instance; `_c` only where a
// block names one of several copies, `_s` only at rate > 1.
// `_payload` is typed ccv_<chan>_t. `_tid` is trace-only (CCV_TRACE);
// `clk_gated` is an observation for the checker bank (CCV_CHECK).
//
// One clock, core_clk, UNGATED: the block gates it as its first act,
// inside the block. The top holds only block instances and nets.
  input  logic core_clk,
  input  logic rst_n,
  input  logic kill_valid,
  input  logic [31:0] kill_warp_mask,
  input  logic [1:0] kill_epoch,
  output logic kill_ack,
  output logic [1:0] kill_ack_epoch,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // ooe -> rcu, slot 0 of 4
  input  logic ooe_rcu_issue_s0_valid,
  input  ccv_ooe_rcu_issue_t ooe_rcu_issue_s0_payload,
  output logic ooe_rcu_issue_s0_credit,
  output logic ooe_rcu_issue_s0_stall,
  // ooe -> rcu, slot 1 of 4
  input  logic ooe_rcu_issue_s1_valid,
  input  ccv_ooe_rcu_issue_t ooe_rcu_issue_s1_payload,
  output logic ooe_rcu_issue_s1_credit,
  output logic ooe_rcu_issue_s1_stall,
  // ooe -> rcu, slot 2 of 4
  input  logic ooe_rcu_issue_s2_valid,
  input  ccv_ooe_rcu_issue_t ooe_rcu_issue_s2_payload,
  output logic ooe_rcu_issue_s2_credit,
  output logic ooe_rcu_issue_s2_stall,
  // ooe -> rcu, slot 3 of 4
  input  logic ooe_rcu_issue_s3_valid,
  input  ccv_ooe_rcu_issue_t ooe_rcu_issue_s3_payload,
  output logic ooe_rcu_issue_s3_credit,
  output logic ooe_rcu_issue_s3_stall,
  input  logic ooe_rcu_issue_wake,
  // rcu -> lane, copy 0, slot 0 of 4
  output logic rcu_lane_ops_c00_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c00_s0_payload,
  input  logic rcu_lane_ops_c00_s0_credit,
  input  logic rcu_lane_ops_c00_s0_stall,
  // rcu -> lane, copy 0, slot 1 of 4
  output logic rcu_lane_ops_c00_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c00_s1_payload,
  input  logic rcu_lane_ops_c00_s1_credit,
  input  logic rcu_lane_ops_c00_s1_stall,
  // rcu -> lane, copy 0, slot 2 of 4
  output logic rcu_lane_ops_c00_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c00_s2_payload,
  input  logic rcu_lane_ops_c00_s2_credit,
  input  logic rcu_lane_ops_c00_s2_stall,
  // rcu -> lane, copy 0, slot 3 of 4
  output logic rcu_lane_ops_c00_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c00_s3_payload,
  input  logic rcu_lane_ops_c00_s3_credit,
  input  logic rcu_lane_ops_c00_s3_stall,
  output logic rcu_lane_ops_c00_wake,
  // rcu -> lane, copy 1, slot 0 of 4
  output logic rcu_lane_ops_c01_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c01_s0_payload,
  input  logic rcu_lane_ops_c01_s0_credit,
  input  logic rcu_lane_ops_c01_s0_stall,
  // rcu -> lane, copy 1, slot 1 of 4
  output logic rcu_lane_ops_c01_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c01_s1_payload,
  input  logic rcu_lane_ops_c01_s1_credit,
  input  logic rcu_lane_ops_c01_s1_stall,
  // rcu -> lane, copy 1, slot 2 of 4
  output logic rcu_lane_ops_c01_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c01_s2_payload,
  input  logic rcu_lane_ops_c01_s2_credit,
  input  logic rcu_lane_ops_c01_s2_stall,
  // rcu -> lane, copy 1, slot 3 of 4
  output logic rcu_lane_ops_c01_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c01_s3_payload,
  input  logic rcu_lane_ops_c01_s3_credit,
  input  logic rcu_lane_ops_c01_s3_stall,
  output logic rcu_lane_ops_c01_wake,
  // rcu -> lane, copy 2, slot 0 of 4
  output logic rcu_lane_ops_c02_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c02_s0_payload,
  input  logic rcu_lane_ops_c02_s0_credit,
  input  logic rcu_lane_ops_c02_s0_stall,
  // rcu -> lane, copy 2, slot 1 of 4
  output logic rcu_lane_ops_c02_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c02_s1_payload,
  input  logic rcu_lane_ops_c02_s1_credit,
  input  logic rcu_lane_ops_c02_s1_stall,
  // rcu -> lane, copy 2, slot 2 of 4
  output logic rcu_lane_ops_c02_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c02_s2_payload,
  input  logic rcu_lane_ops_c02_s2_credit,
  input  logic rcu_lane_ops_c02_s2_stall,
  // rcu -> lane, copy 2, slot 3 of 4
  output logic rcu_lane_ops_c02_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c02_s3_payload,
  input  logic rcu_lane_ops_c02_s3_credit,
  input  logic rcu_lane_ops_c02_s3_stall,
  output logic rcu_lane_ops_c02_wake,
  // rcu -> lane, copy 3, slot 0 of 4
  output logic rcu_lane_ops_c03_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c03_s0_payload,
  input  logic rcu_lane_ops_c03_s0_credit,
  input  logic rcu_lane_ops_c03_s0_stall,
  // rcu -> lane, copy 3, slot 1 of 4
  output logic rcu_lane_ops_c03_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c03_s1_payload,
  input  logic rcu_lane_ops_c03_s1_credit,
  input  logic rcu_lane_ops_c03_s1_stall,
  // rcu -> lane, copy 3, slot 2 of 4
  output logic rcu_lane_ops_c03_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c03_s2_payload,
  input  logic rcu_lane_ops_c03_s2_credit,
  input  logic rcu_lane_ops_c03_s2_stall,
  // rcu -> lane, copy 3, slot 3 of 4
  output logic rcu_lane_ops_c03_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c03_s3_payload,
  input  logic rcu_lane_ops_c03_s3_credit,
  input  logic rcu_lane_ops_c03_s3_stall,
  output logic rcu_lane_ops_c03_wake,
  // rcu -> lane, copy 4, slot 0 of 4
  output logic rcu_lane_ops_c04_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c04_s0_payload,
  input  logic rcu_lane_ops_c04_s0_credit,
  input  logic rcu_lane_ops_c04_s0_stall,
  // rcu -> lane, copy 4, slot 1 of 4
  output logic rcu_lane_ops_c04_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c04_s1_payload,
  input  logic rcu_lane_ops_c04_s1_credit,
  input  logic rcu_lane_ops_c04_s1_stall,
  // rcu -> lane, copy 4, slot 2 of 4
  output logic rcu_lane_ops_c04_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c04_s2_payload,
  input  logic rcu_lane_ops_c04_s2_credit,
  input  logic rcu_lane_ops_c04_s2_stall,
  // rcu -> lane, copy 4, slot 3 of 4
  output logic rcu_lane_ops_c04_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c04_s3_payload,
  input  logic rcu_lane_ops_c04_s3_credit,
  input  logic rcu_lane_ops_c04_s3_stall,
  output logic rcu_lane_ops_c04_wake,
  // rcu -> lane, copy 5, slot 0 of 4
  output logic rcu_lane_ops_c05_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c05_s0_payload,
  input  logic rcu_lane_ops_c05_s0_credit,
  input  logic rcu_lane_ops_c05_s0_stall,
  // rcu -> lane, copy 5, slot 1 of 4
  output logic rcu_lane_ops_c05_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c05_s1_payload,
  input  logic rcu_lane_ops_c05_s1_credit,
  input  logic rcu_lane_ops_c05_s1_stall,
  // rcu -> lane, copy 5, slot 2 of 4
  output logic rcu_lane_ops_c05_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c05_s2_payload,
  input  logic rcu_lane_ops_c05_s2_credit,
  input  logic rcu_lane_ops_c05_s2_stall,
  // rcu -> lane, copy 5, slot 3 of 4
  output logic rcu_lane_ops_c05_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c05_s3_payload,
  input  logic rcu_lane_ops_c05_s3_credit,
  input  logic rcu_lane_ops_c05_s3_stall,
  output logic rcu_lane_ops_c05_wake,
  // rcu -> lane, copy 6, slot 0 of 4
  output logic rcu_lane_ops_c06_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c06_s0_payload,
  input  logic rcu_lane_ops_c06_s0_credit,
  input  logic rcu_lane_ops_c06_s0_stall,
  // rcu -> lane, copy 6, slot 1 of 4
  output logic rcu_lane_ops_c06_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c06_s1_payload,
  input  logic rcu_lane_ops_c06_s1_credit,
  input  logic rcu_lane_ops_c06_s1_stall,
  // rcu -> lane, copy 6, slot 2 of 4
  output logic rcu_lane_ops_c06_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c06_s2_payload,
  input  logic rcu_lane_ops_c06_s2_credit,
  input  logic rcu_lane_ops_c06_s2_stall,
  // rcu -> lane, copy 6, slot 3 of 4
  output logic rcu_lane_ops_c06_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c06_s3_payload,
  input  logic rcu_lane_ops_c06_s3_credit,
  input  logic rcu_lane_ops_c06_s3_stall,
  output logic rcu_lane_ops_c06_wake,
  // rcu -> lane, copy 7, slot 0 of 4
  output logic rcu_lane_ops_c07_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c07_s0_payload,
  input  logic rcu_lane_ops_c07_s0_credit,
  input  logic rcu_lane_ops_c07_s0_stall,
  // rcu -> lane, copy 7, slot 1 of 4
  output logic rcu_lane_ops_c07_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c07_s1_payload,
  input  logic rcu_lane_ops_c07_s1_credit,
  input  logic rcu_lane_ops_c07_s1_stall,
  // rcu -> lane, copy 7, slot 2 of 4
  output logic rcu_lane_ops_c07_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c07_s2_payload,
  input  logic rcu_lane_ops_c07_s2_credit,
  input  logic rcu_lane_ops_c07_s2_stall,
  // rcu -> lane, copy 7, slot 3 of 4
  output logic rcu_lane_ops_c07_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c07_s3_payload,
  input  logic rcu_lane_ops_c07_s3_credit,
  input  logic rcu_lane_ops_c07_s3_stall,
  output logic rcu_lane_ops_c07_wake,
  // rcu -> lane, copy 8, slot 0 of 4
  output logic rcu_lane_ops_c08_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c08_s0_payload,
  input  logic rcu_lane_ops_c08_s0_credit,
  input  logic rcu_lane_ops_c08_s0_stall,
  // rcu -> lane, copy 8, slot 1 of 4
  output logic rcu_lane_ops_c08_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c08_s1_payload,
  input  logic rcu_lane_ops_c08_s1_credit,
  input  logic rcu_lane_ops_c08_s1_stall,
  // rcu -> lane, copy 8, slot 2 of 4
  output logic rcu_lane_ops_c08_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c08_s2_payload,
  input  logic rcu_lane_ops_c08_s2_credit,
  input  logic rcu_lane_ops_c08_s2_stall,
  // rcu -> lane, copy 8, slot 3 of 4
  output logic rcu_lane_ops_c08_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c08_s3_payload,
  input  logic rcu_lane_ops_c08_s3_credit,
  input  logic rcu_lane_ops_c08_s3_stall,
  output logic rcu_lane_ops_c08_wake,
  // rcu -> lane, copy 9, slot 0 of 4
  output logic rcu_lane_ops_c09_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c09_s0_payload,
  input  logic rcu_lane_ops_c09_s0_credit,
  input  logic rcu_lane_ops_c09_s0_stall,
  // rcu -> lane, copy 9, slot 1 of 4
  output logic rcu_lane_ops_c09_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c09_s1_payload,
  input  logic rcu_lane_ops_c09_s1_credit,
  input  logic rcu_lane_ops_c09_s1_stall,
  // rcu -> lane, copy 9, slot 2 of 4
  output logic rcu_lane_ops_c09_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c09_s2_payload,
  input  logic rcu_lane_ops_c09_s2_credit,
  input  logic rcu_lane_ops_c09_s2_stall,
  // rcu -> lane, copy 9, slot 3 of 4
  output logic rcu_lane_ops_c09_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c09_s3_payload,
  input  logic rcu_lane_ops_c09_s3_credit,
  input  logic rcu_lane_ops_c09_s3_stall,
  output logic rcu_lane_ops_c09_wake,
  // rcu -> lane, copy 10, slot 0 of 4
  output logic rcu_lane_ops_c10_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c10_s0_payload,
  input  logic rcu_lane_ops_c10_s0_credit,
  input  logic rcu_lane_ops_c10_s0_stall,
  // rcu -> lane, copy 10, slot 1 of 4
  output logic rcu_lane_ops_c10_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c10_s1_payload,
  input  logic rcu_lane_ops_c10_s1_credit,
  input  logic rcu_lane_ops_c10_s1_stall,
  // rcu -> lane, copy 10, slot 2 of 4
  output logic rcu_lane_ops_c10_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c10_s2_payload,
  input  logic rcu_lane_ops_c10_s2_credit,
  input  logic rcu_lane_ops_c10_s2_stall,
  // rcu -> lane, copy 10, slot 3 of 4
  output logic rcu_lane_ops_c10_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c10_s3_payload,
  input  logic rcu_lane_ops_c10_s3_credit,
  input  logic rcu_lane_ops_c10_s3_stall,
  output logic rcu_lane_ops_c10_wake,
  // rcu -> lane, copy 11, slot 0 of 4
  output logic rcu_lane_ops_c11_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c11_s0_payload,
  input  logic rcu_lane_ops_c11_s0_credit,
  input  logic rcu_lane_ops_c11_s0_stall,
  // rcu -> lane, copy 11, slot 1 of 4
  output logic rcu_lane_ops_c11_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c11_s1_payload,
  input  logic rcu_lane_ops_c11_s1_credit,
  input  logic rcu_lane_ops_c11_s1_stall,
  // rcu -> lane, copy 11, slot 2 of 4
  output logic rcu_lane_ops_c11_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c11_s2_payload,
  input  logic rcu_lane_ops_c11_s2_credit,
  input  logic rcu_lane_ops_c11_s2_stall,
  // rcu -> lane, copy 11, slot 3 of 4
  output logic rcu_lane_ops_c11_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c11_s3_payload,
  input  logic rcu_lane_ops_c11_s3_credit,
  input  logic rcu_lane_ops_c11_s3_stall,
  output logic rcu_lane_ops_c11_wake,
  // rcu -> lane, copy 12, slot 0 of 4
  output logic rcu_lane_ops_c12_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c12_s0_payload,
  input  logic rcu_lane_ops_c12_s0_credit,
  input  logic rcu_lane_ops_c12_s0_stall,
  // rcu -> lane, copy 12, slot 1 of 4
  output logic rcu_lane_ops_c12_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c12_s1_payload,
  input  logic rcu_lane_ops_c12_s1_credit,
  input  logic rcu_lane_ops_c12_s1_stall,
  // rcu -> lane, copy 12, slot 2 of 4
  output logic rcu_lane_ops_c12_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c12_s2_payload,
  input  logic rcu_lane_ops_c12_s2_credit,
  input  logic rcu_lane_ops_c12_s2_stall,
  // rcu -> lane, copy 12, slot 3 of 4
  output logic rcu_lane_ops_c12_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c12_s3_payload,
  input  logic rcu_lane_ops_c12_s3_credit,
  input  logic rcu_lane_ops_c12_s3_stall,
  output logic rcu_lane_ops_c12_wake,
  // rcu -> lane, copy 13, slot 0 of 4
  output logic rcu_lane_ops_c13_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c13_s0_payload,
  input  logic rcu_lane_ops_c13_s0_credit,
  input  logic rcu_lane_ops_c13_s0_stall,
  // rcu -> lane, copy 13, slot 1 of 4
  output logic rcu_lane_ops_c13_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c13_s1_payload,
  input  logic rcu_lane_ops_c13_s1_credit,
  input  logic rcu_lane_ops_c13_s1_stall,
  // rcu -> lane, copy 13, slot 2 of 4
  output logic rcu_lane_ops_c13_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c13_s2_payload,
  input  logic rcu_lane_ops_c13_s2_credit,
  input  logic rcu_lane_ops_c13_s2_stall,
  // rcu -> lane, copy 13, slot 3 of 4
  output logic rcu_lane_ops_c13_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c13_s3_payload,
  input  logic rcu_lane_ops_c13_s3_credit,
  input  logic rcu_lane_ops_c13_s3_stall,
  output logic rcu_lane_ops_c13_wake,
  // rcu -> lane, copy 14, slot 0 of 4
  output logic rcu_lane_ops_c14_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c14_s0_payload,
  input  logic rcu_lane_ops_c14_s0_credit,
  input  logic rcu_lane_ops_c14_s0_stall,
  // rcu -> lane, copy 14, slot 1 of 4
  output logic rcu_lane_ops_c14_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c14_s1_payload,
  input  logic rcu_lane_ops_c14_s1_credit,
  input  logic rcu_lane_ops_c14_s1_stall,
  // rcu -> lane, copy 14, slot 2 of 4
  output logic rcu_lane_ops_c14_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c14_s2_payload,
  input  logic rcu_lane_ops_c14_s2_credit,
  input  logic rcu_lane_ops_c14_s2_stall,
  // rcu -> lane, copy 14, slot 3 of 4
  output logic rcu_lane_ops_c14_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c14_s3_payload,
  input  logic rcu_lane_ops_c14_s3_credit,
  input  logic rcu_lane_ops_c14_s3_stall,
  output logic rcu_lane_ops_c14_wake,
  // rcu -> lane, copy 15, slot 0 of 4
  output logic rcu_lane_ops_c15_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c15_s0_payload,
  input  logic rcu_lane_ops_c15_s0_credit,
  input  logic rcu_lane_ops_c15_s0_stall,
  // rcu -> lane, copy 15, slot 1 of 4
  output logic rcu_lane_ops_c15_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c15_s1_payload,
  input  logic rcu_lane_ops_c15_s1_credit,
  input  logic rcu_lane_ops_c15_s1_stall,
  // rcu -> lane, copy 15, slot 2 of 4
  output logic rcu_lane_ops_c15_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c15_s2_payload,
  input  logic rcu_lane_ops_c15_s2_credit,
  input  logic rcu_lane_ops_c15_s2_stall,
  // rcu -> lane, copy 15, slot 3 of 4
  output logic rcu_lane_ops_c15_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c15_s3_payload,
  input  logic rcu_lane_ops_c15_s3_credit,
  input  logic rcu_lane_ops_c15_s3_stall,
  output logic rcu_lane_ops_c15_wake,
  // rcu -> lane, copy 16, slot 0 of 4
  output logic rcu_lane_ops_c16_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c16_s0_payload,
  input  logic rcu_lane_ops_c16_s0_credit,
  input  logic rcu_lane_ops_c16_s0_stall,
  // rcu -> lane, copy 16, slot 1 of 4
  output logic rcu_lane_ops_c16_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c16_s1_payload,
  input  logic rcu_lane_ops_c16_s1_credit,
  input  logic rcu_lane_ops_c16_s1_stall,
  // rcu -> lane, copy 16, slot 2 of 4
  output logic rcu_lane_ops_c16_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c16_s2_payload,
  input  logic rcu_lane_ops_c16_s2_credit,
  input  logic rcu_lane_ops_c16_s2_stall,
  // rcu -> lane, copy 16, slot 3 of 4
  output logic rcu_lane_ops_c16_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c16_s3_payload,
  input  logic rcu_lane_ops_c16_s3_credit,
  input  logic rcu_lane_ops_c16_s3_stall,
  output logic rcu_lane_ops_c16_wake,
  // rcu -> lane, copy 17, slot 0 of 4
  output logic rcu_lane_ops_c17_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c17_s0_payload,
  input  logic rcu_lane_ops_c17_s0_credit,
  input  logic rcu_lane_ops_c17_s0_stall,
  // rcu -> lane, copy 17, slot 1 of 4
  output logic rcu_lane_ops_c17_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c17_s1_payload,
  input  logic rcu_lane_ops_c17_s1_credit,
  input  logic rcu_lane_ops_c17_s1_stall,
  // rcu -> lane, copy 17, slot 2 of 4
  output logic rcu_lane_ops_c17_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c17_s2_payload,
  input  logic rcu_lane_ops_c17_s2_credit,
  input  logic rcu_lane_ops_c17_s2_stall,
  // rcu -> lane, copy 17, slot 3 of 4
  output logic rcu_lane_ops_c17_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c17_s3_payload,
  input  logic rcu_lane_ops_c17_s3_credit,
  input  logic rcu_lane_ops_c17_s3_stall,
  output logic rcu_lane_ops_c17_wake,
  // rcu -> lane, copy 18, slot 0 of 4
  output logic rcu_lane_ops_c18_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c18_s0_payload,
  input  logic rcu_lane_ops_c18_s0_credit,
  input  logic rcu_lane_ops_c18_s0_stall,
  // rcu -> lane, copy 18, slot 1 of 4
  output logic rcu_lane_ops_c18_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c18_s1_payload,
  input  logic rcu_lane_ops_c18_s1_credit,
  input  logic rcu_lane_ops_c18_s1_stall,
  // rcu -> lane, copy 18, slot 2 of 4
  output logic rcu_lane_ops_c18_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c18_s2_payload,
  input  logic rcu_lane_ops_c18_s2_credit,
  input  logic rcu_lane_ops_c18_s2_stall,
  // rcu -> lane, copy 18, slot 3 of 4
  output logic rcu_lane_ops_c18_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c18_s3_payload,
  input  logic rcu_lane_ops_c18_s3_credit,
  input  logic rcu_lane_ops_c18_s3_stall,
  output logic rcu_lane_ops_c18_wake,
  // rcu -> lane, copy 19, slot 0 of 4
  output logic rcu_lane_ops_c19_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c19_s0_payload,
  input  logic rcu_lane_ops_c19_s0_credit,
  input  logic rcu_lane_ops_c19_s0_stall,
  // rcu -> lane, copy 19, slot 1 of 4
  output logic rcu_lane_ops_c19_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c19_s1_payload,
  input  logic rcu_lane_ops_c19_s1_credit,
  input  logic rcu_lane_ops_c19_s1_stall,
  // rcu -> lane, copy 19, slot 2 of 4
  output logic rcu_lane_ops_c19_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c19_s2_payload,
  input  logic rcu_lane_ops_c19_s2_credit,
  input  logic rcu_lane_ops_c19_s2_stall,
  // rcu -> lane, copy 19, slot 3 of 4
  output logic rcu_lane_ops_c19_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c19_s3_payload,
  input  logic rcu_lane_ops_c19_s3_credit,
  input  logic rcu_lane_ops_c19_s3_stall,
  output logic rcu_lane_ops_c19_wake,
  // rcu -> lane, copy 20, slot 0 of 4
  output logic rcu_lane_ops_c20_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c20_s0_payload,
  input  logic rcu_lane_ops_c20_s0_credit,
  input  logic rcu_lane_ops_c20_s0_stall,
  // rcu -> lane, copy 20, slot 1 of 4
  output logic rcu_lane_ops_c20_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c20_s1_payload,
  input  logic rcu_lane_ops_c20_s1_credit,
  input  logic rcu_lane_ops_c20_s1_stall,
  // rcu -> lane, copy 20, slot 2 of 4
  output logic rcu_lane_ops_c20_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c20_s2_payload,
  input  logic rcu_lane_ops_c20_s2_credit,
  input  logic rcu_lane_ops_c20_s2_stall,
  // rcu -> lane, copy 20, slot 3 of 4
  output logic rcu_lane_ops_c20_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c20_s3_payload,
  input  logic rcu_lane_ops_c20_s3_credit,
  input  logic rcu_lane_ops_c20_s3_stall,
  output logic rcu_lane_ops_c20_wake,
  // rcu -> lane, copy 21, slot 0 of 4
  output logic rcu_lane_ops_c21_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c21_s0_payload,
  input  logic rcu_lane_ops_c21_s0_credit,
  input  logic rcu_lane_ops_c21_s0_stall,
  // rcu -> lane, copy 21, slot 1 of 4
  output logic rcu_lane_ops_c21_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c21_s1_payload,
  input  logic rcu_lane_ops_c21_s1_credit,
  input  logic rcu_lane_ops_c21_s1_stall,
  // rcu -> lane, copy 21, slot 2 of 4
  output logic rcu_lane_ops_c21_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c21_s2_payload,
  input  logic rcu_lane_ops_c21_s2_credit,
  input  logic rcu_lane_ops_c21_s2_stall,
  // rcu -> lane, copy 21, slot 3 of 4
  output logic rcu_lane_ops_c21_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c21_s3_payload,
  input  logic rcu_lane_ops_c21_s3_credit,
  input  logic rcu_lane_ops_c21_s3_stall,
  output logic rcu_lane_ops_c21_wake,
  // rcu -> lane, copy 22, slot 0 of 4
  output logic rcu_lane_ops_c22_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c22_s0_payload,
  input  logic rcu_lane_ops_c22_s0_credit,
  input  logic rcu_lane_ops_c22_s0_stall,
  // rcu -> lane, copy 22, slot 1 of 4
  output logic rcu_lane_ops_c22_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c22_s1_payload,
  input  logic rcu_lane_ops_c22_s1_credit,
  input  logic rcu_lane_ops_c22_s1_stall,
  // rcu -> lane, copy 22, slot 2 of 4
  output logic rcu_lane_ops_c22_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c22_s2_payload,
  input  logic rcu_lane_ops_c22_s2_credit,
  input  logic rcu_lane_ops_c22_s2_stall,
  // rcu -> lane, copy 22, slot 3 of 4
  output logic rcu_lane_ops_c22_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c22_s3_payload,
  input  logic rcu_lane_ops_c22_s3_credit,
  input  logic rcu_lane_ops_c22_s3_stall,
  output logic rcu_lane_ops_c22_wake,
  // rcu -> lane, copy 23, slot 0 of 4
  output logic rcu_lane_ops_c23_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c23_s0_payload,
  input  logic rcu_lane_ops_c23_s0_credit,
  input  logic rcu_lane_ops_c23_s0_stall,
  // rcu -> lane, copy 23, slot 1 of 4
  output logic rcu_lane_ops_c23_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c23_s1_payload,
  input  logic rcu_lane_ops_c23_s1_credit,
  input  logic rcu_lane_ops_c23_s1_stall,
  // rcu -> lane, copy 23, slot 2 of 4
  output logic rcu_lane_ops_c23_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c23_s2_payload,
  input  logic rcu_lane_ops_c23_s2_credit,
  input  logic rcu_lane_ops_c23_s2_stall,
  // rcu -> lane, copy 23, slot 3 of 4
  output logic rcu_lane_ops_c23_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c23_s3_payload,
  input  logic rcu_lane_ops_c23_s3_credit,
  input  logic rcu_lane_ops_c23_s3_stall,
  output logic rcu_lane_ops_c23_wake,
  // rcu -> lane, copy 24, slot 0 of 4
  output logic rcu_lane_ops_c24_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c24_s0_payload,
  input  logic rcu_lane_ops_c24_s0_credit,
  input  logic rcu_lane_ops_c24_s0_stall,
  // rcu -> lane, copy 24, slot 1 of 4
  output logic rcu_lane_ops_c24_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c24_s1_payload,
  input  logic rcu_lane_ops_c24_s1_credit,
  input  logic rcu_lane_ops_c24_s1_stall,
  // rcu -> lane, copy 24, slot 2 of 4
  output logic rcu_lane_ops_c24_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c24_s2_payload,
  input  logic rcu_lane_ops_c24_s2_credit,
  input  logic rcu_lane_ops_c24_s2_stall,
  // rcu -> lane, copy 24, slot 3 of 4
  output logic rcu_lane_ops_c24_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c24_s3_payload,
  input  logic rcu_lane_ops_c24_s3_credit,
  input  logic rcu_lane_ops_c24_s3_stall,
  output logic rcu_lane_ops_c24_wake,
  // rcu -> lane, copy 25, slot 0 of 4
  output logic rcu_lane_ops_c25_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c25_s0_payload,
  input  logic rcu_lane_ops_c25_s0_credit,
  input  logic rcu_lane_ops_c25_s0_stall,
  // rcu -> lane, copy 25, slot 1 of 4
  output logic rcu_lane_ops_c25_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c25_s1_payload,
  input  logic rcu_lane_ops_c25_s1_credit,
  input  logic rcu_lane_ops_c25_s1_stall,
  // rcu -> lane, copy 25, slot 2 of 4
  output logic rcu_lane_ops_c25_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c25_s2_payload,
  input  logic rcu_lane_ops_c25_s2_credit,
  input  logic rcu_lane_ops_c25_s2_stall,
  // rcu -> lane, copy 25, slot 3 of 4
  output logic rcu_lane_ops_c25_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c25_s3_payload,
  input  logic rcu_lane_ops_c25_s3_credit,
  input  logic rcu_lane_ops_c25_s3_stall,
  output logic rcu_lane_ops_c25_wake,
  // rcu -> lane, copy 26, slot 0 of 4
  output logic rcu_lane_ops_c26_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c26_s0_payload,
  input  logic rcu_lane_ops_c26_s0_credit,
  input  logic rcu_lane_ops_c26_s0_stall,
  // rcu -> lane, copy 26, slot 1 of 4
  output logic rcu_lane_ops_c26_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c26_s1_payload,
  input  logic rcu_lane_ops_c26_s1_credit,
  input  logic rcu_lane_ops_c26_s1_stall,
  // rcu -> lane, copy 26, slot 2 of 4
  output logic rcu_lane_ops_c26_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c26_s2_payload,
  input  logic rcu_lane_ops_c26_s2_credit,
  input  logic rcu_lane_ops_c26_s2_stall,
  // rcu -> lane, copy 26, slot 3 of 4
  output logic rcu_lane_ops_c26_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c26_s3_payload,
  input  logic rcu_lane_ops_c26_s3_credit,
  input  logic rcu_lane_ops_c26_s3_stall,
  output logic rcu_lane_ops_c26_wake,
  // rcu -> lane, copy 27, slot 0 of 4
  output logic rcu_lane_ops_c27_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c27_s0_payload,
  input  logic rcu_lane_ops_c27_s0_credit,
  input  logic rcu_lane_ops_c27_s0_stall,
  // rcu -> lane, copy 27, slot 1 of 4
  output logic rcu_lane_ops_c27_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c27_s1_payload,
  input  logic rcu_lane_ops_c27_s1_credit,
  input  logic rcu_lane_ops_c27_s1_stall,
  // rcu -> lane, copy 27, slot 2 of 4
  output logic rcu_lane_ops_c27_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c27_s2_payload,
  input  logic rcu_lane_ops_c27_s2_credit,
  input  logic rcu_lane_ops_c27_s2_stall,
  // rcu -> lane, copy 27, slot 3 of 4
  output logic rcu_lane_ops_c27_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c27_s3_payload,
  input  logic rcu_lane_ops_c27_s3_credit,
  input  logic rcu_lane_ops_c27_s3_stall,
  output logic rcu_lane_ops_c27_wake,
  // rcu -> lane, copy 28, slot 0 of 4
  output logic rcu_lane_ops_c28_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c28_s0_payload,
  input  logic rcu_lane_ops_c28_s0_credit,
  input  logic rcu_lane_ops_c28_s0_stall,
  // rcu -> lane, copy 28, slot 1 of 4
  output logic rcu_lane_ops_c28_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c28_s1_payload,
  input  logic rcu_lane_ops_c28_s1_credit,
  input  logic rcu_lane_ops_c28_s1_stall,
  // rcu -> lane, copy 28, slot 2 of 4
  output logic rcu_lane_ops_c28_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c28_s2_payload,
  input  logic rcu_lane_ops_c28_s2_credit,
  input  logic rcu_lane_ops_c28_s2_stall,
  // rcu -> lane, copy 28, slot 3 of 4
  output logic rcu_lane_ops_c28_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c28_s3_payload,
  input  logic rcu_lane_ops_c28_s3_credit,
  input  logic rcu_lane_ops_c28_s3_stall,
  output logic rcu_lane_ops_c28_wake,
  // rcu -> lane, copy 29, slot 0 of 4
  output logic rcu_lane_ops_c29_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c29_s0_payload,
  input  logic rcu_lane_ops_c29_s0_credit,
  input  logic rcu_lane_ops_c29_s0_stall,
  // rcu -> lane, copy 29, slot 1 of 4
  output logic rcu_lane_ops_c29_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c29_s1_payload,
  input  logic rcu_lane_ops_c29_s1_credit,
  input  logic rcu_lane_ops_c29_s1_stall,
  // rcu -> lane, copy 29, slot 2 of 4
  output logic rcu_lane_ops_c29_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c29_s2_payload,
  input  logic rcu_lane_ops_c29_s2_credit,
  input  logic rcu_lane_ops_c29_s2_stall,
  // rcu -> lane, copy 29, slot 3 of 4
  output logic rcu_lane_ops_c29_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c29_s3_payload,
  input  logic rcu_lane_ops_c29_s3_credit,
  input  logic rcu_lane_ops_c29_s3_stall,
  output logic rcu_lane_ops_c29_wake,
  // rcu -> lane, copy 30, slot 0 of 4
  output logic rcu_lane_ops_c30_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c30_s0_payload,
  input  logic rcu_lane_ops_c30_s0_credit,
  input  logic rcu_lane_ops_c30_s0_stall,
  // rcu -> lane, copy 30, slot 1 of 4
  output logic rcu_lane_ops_c30_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c30_s1_payload,
  input  logic rcu_lane_ops_c30_s1_credit,
  input  logic rcu_lane_ops_c30_s1_stall,
  // rcu -> lane, copy 30, slot 2 of 4
  output logic rcu_lane_ops_c30_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c30_s2_payload,
  input  logic rcu_lane_ops_c30_s2_credit,
  input  logic rcu_lane_ops_c30_s2_stall,
  // rcu -> lane, copy 30, slot 3 of 4
  output logic rcu_lane_ops_c30_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c30_s3_payload,
  input  logic rcu_lane_ops_c30_s3_credit,
  input  logic rcu_lane_ops_c30_s3_stall,
  output logic rcu_lane_ops_c30_wake,
  // rcu -> lane, copy 31, slot 0 of 4
  output logic rcu_lane_ops_c31_s0_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c31_s0_payload,
  input  logic rcu_lane_ops_c31_s0_credit,
  input  logic rcu_lane_ops_c31_s0_stall,
  // rcu -> lane, copy 31, slot 1 of 4
  output logic rcu_lane_ops_c31_s1_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c31_s1_payload,
  input  logic rcu_lane_ops_c31_s1_credit,
  input  logic rcu_lane_ops_c31_s1_stall,
  // rcu -> lane, copy 31, slot 2 of 4
  output logic rcu_lane_ops_c31_s2_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c31_s2_payload,
  input  logic rcu_lane_ops_c31_s2_credit,
  input  logic rcu_lane_ops_c31_s2_stall,
  // rcu -> lane, copy 31, slot 3 of 4
  output logic rcu_lane_ops_c31_s3_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c31_s3_payload,
  input  logic rcu_lane_ops_c31_s3_credit,
  input  logic rcu_lane_ops_c31_s3_stall,
  output logic rcu_lane_ops_c31_wake,
  // lane -> rcu, copy 0, slot 0 of 4
  input  logic lane_rcu_res_c00_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c00_s0_payload,
  output logic lane_rcu_res_c00_s0_credit,
  output logic lane_rcu_res_c00_s0_stall,
  // lane -> rcu, copy 0, slot 1 of 4
  input  logic lane_rcu_res_c00_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c00_s1_payload,
  output logic lane_rcu_res_c00_s1_credit,
  output logic lane_rcu_res_c00_s1_stall,
  // lane -> rcu, copy 0, slot 2 of 4
  input  logic lane_rcu_res_c00_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c00_s2_payload,
  output logic lane_rcu_res_c00_s2_credit,
  output logic lane_rcu_res_c00_s2_stall,
  // lane -> rcu, copy 0, slot 3 of 4
  input  logic lane_rcu_res_c00_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c00_s3_payload,
  output logic lane_rcu_res_c00_s3_credit,
  output logic lane_rcu_res_c00_s3_stall,
  input  logic lane_rcu_res_c00_wake,
  // lane -> rcu, copy 1, slot 0 of 4
  input  logic lane_rcu_res_c01_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c01_s0_payload,
  output logic lane_rcu_res_c01_s0_credit,
  output logic lane_rcu_res_c01_s0_stall,
  // lane -> rcu, copy 1, slot 1 of 4
  input  logic lane_rcu_res_c01_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c01_s1_payload,
  output logic lane_rcu_res_c01_s1_credit,
  output logic lane_rcu_res_c01_s1_stall,
  // lane -> rcu, copy 1, slot 2 of 4
  input  logic lane_rcu_res_c01_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c01_s2_payload,
  output logic lane_rcu_res_c01_s2_credit,
  output logic lane_rcu_res_c01_s2_stall,
  // lane -> rcu, copy 1, slot 3 of 4
  input  logic lane_rcu_res_c01_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c01_s3_payload,
  output logic lane_rcu_res_c01_s3_credit,
  output logic lane_rcu_res_c01_s3_stall,
  input  logic lane_rcu_res_c01_wake,
  // lane -> rcu, copy 2, slot 0 of 4
  input  logic lane_rcu_res_c02_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c02_s0_payload,
  output logic lane_rcu_res_c02_s0_credit,
  output logic lane_rcu_res_c02_s0_stall,
  // lane -> rcu, copy 2, slot 1 of 4
  input  logic lane_rcu_res_c02_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c02_s1_payload,
  output logic lane_rcu_res_c02_s1_credit,
  output logic lane_rcu_res_c02_s1_stall,
  // lane -> rcu, copy 2, slot 2 of 4
  input  logic lane_rcu_res_c02_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c02_s2_payload,
  output logic lane_rcu_res_c02_s2_credit,
  output logic lane_rcu_res_c02_s2_stall,
  // lane -> rcu, copy 2, slot 3 of 4
  input  logic lane_rcu_res_c02_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c02_s3_payload,
  output logic lane_rcu_res_c02_s3_credit,
  output logic lane_rcu_res_c02_s3_stall,
  input  logic lane_rcu_res_c02_wake,
  // lane -> rcu, copy 3, slot 0 of 4
  input  logic lane_rcu_res_c03_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c03_s0_payload,
  output logic lane_rcu_res_c03_s0_credit,
  output logic lane_rcu_res_c03_s0_stall,
  // lane -> rcu, copy 3, slot 1 of 4
  input  logic lane_rcu_res_c03_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c03_s1_payload,
  output logic lane_rcu_res_c03_s1_credit,
  output logic lane_rcu_res_c03_s1_stall,
  // lane -> rcu, copy 3, slot 2 of 4
  input  logic lane_rcu_res_c03_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c03_s2_payload,
  output logic lane_rcu_res_c03_s2_credit,
  output logic lane_rcu_res_c03_s2_stall,
  // lane -> rcu, copy 3, slot 3 of 4
  input  logic lane_rcu_res_c03_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c03_s3_payload,
  output logic lane_rcu_res_c03_s3_credit,
  output logic lane_rcu_res_c03_s3_stall,
  input  logic lane_rcu_res_c03_wake,
  // lane -> rcu, copy 4, slot 0 of 4
  input  logic lane_rcu_res_c04_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c04_s0_payload,
  output logic lane_rcu_res_c04_s0_credit,
  output logic lane_rcu_res_c04_s0_stall,
  // lane -> rcu, copy 4, slot 1 of 4
  input  logic lane_rcu_res_c04_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c04_s1_payload,
  output logic lane_rcu_res_c04_s1_credit,
  output logic lane_rcu_res_c04_s1_stall,
  // lane -> rcu, copy 4, slot 2 of 4
  input  logic lane_rcu_res_c04_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c04_s2_payload,
  output logic lane_rcu_res_c04_s2_credit,
  output logic lane_rcu_res_c04_s2_stall,
  // lane -> rcu, copy 4, slot 3 of 4
  input  logic lane_rcu_res_c04_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c04_s3_payload,
  output logic lane_rcu_res_c04_s3_credit,
  output logic lane_rcu_res_c04_s3_stall,
  input  logic lane_rcu_res_c04_wake,
  // lane -> rcu, copy 5, slot 0 of 4
  input  logic lane_rcu_res_c05_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c05_s0_payload,
  output logic lane_rcu_res_c05_s0_credit,
  output logic lane_rcu_res_c05_s0_stall,
  // lane -> rcu, copy 5, slot 1 of 4
  input  logic lane_rcu_res_c05_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c05_s1_payload,
  output logic lane_rcu_res_c05_s1_credit,
  output logic lane_rcu_res_c05_s1_stall,
  // lane -> rcu, copy 5, slot 2 of 4
  input  logic lane_rcu_res_c05_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c05_s2_payload,
  output logic lane_rcu_res_c05_s2_credit,
  output logic lane_rcu_res_c05_s2_stall,
  // lane -> rcu, copy 5, slot 3 of 4
  input  logic lane_rcu_res_c05_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c05_s3_payload,
  output logic lane_rcu_res_c05_s3_credit,
  output logic lane_rcu_res_c05_s3_stall,
  input  logic lane_rcu_res_c05_wake,
  // lane -> rcu, copy 6, slot 0 of 4
  input  logic lane_rcu_res_c06_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c06_s0_payload,
  output logic lane_rcu_res_c06_s0_credit,
  output logic lane_rcu_res_c06_s0_stall,
  // lane -> rcu, copy 6, slot 1 of 4
  input  logic lane_rcu_res_c06_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c06_s1_payload,
  output logic lane_rcu_res_c06_s1_credit,
  output logic lane_rcu_res_c06_s1_stall,
  // lane -> rcu, copy 6, slot 2 of 4
  input  logic lane_rcu_res_c06_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c06_s2_payload,
  output logic lane_rcu_res_c06_s2_credit,
  output logic lane_rcu_res_c06_s2_stall,
  // lane -> rcu, copy 6, slot 3 of 4
  input  logic lane_rcu_res_c06_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c06_s3_payload,
  output logic lane_rcu_res_c06_s3_credit,
  output logic lane_rcu_res_c06_s3_stall,
  input  logic lane_rcu_res_c06_wake,
  // lane -> rcu, copy 7, slot 0 of 4
  input  logic lane_rcu_res_c07_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c07_s0_payload,
  output logic lane_rcu_res_c07_s0_credit,
  output logic lane_rcu_res_c07_s0_stall,
  // lane -> rcu, copy 7, slot 1 of 4
  input  logic lane_rcu_res_c07_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c07_s1_payload,
  output logic lane_rcu_res_c07_s1_credit,
  output logic lane_rcu_res_c07_s1_stall,
  // lane -> rcu, copy 7, slot 2 of 4
  input  logic lane_rcu_res_c07_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c07_s2_payload,
  output logic lane_rcu_res_c07_s2_credit,
  output logic lane_rcu_res_c07_s2_stall,
  // lane -> rcu, copy 7, slot 3 of 4
  input  logic lane_rcu_res_c07_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c07_s3_payload,
  output logic lane_rcu_res_c07_s3_credit,
  output logic lane_rcu_res_c07_s3_stall,
  input  logic lane_rcu_res_c07_wake,
  // lane -> rcu, copy 8, slot 0 of 4
  input  logic lane_rcu_res_c08_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c08_s0_payload,
  output logic lane_rcu_res_c08_s0_credit,
  output logic lane_rcu_res_c08_s0_stall,
  // lane -> rcu, copy 8, slot 1 of 4
  input  logic lane_rcu_res_c08_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c08_s1_payload,
  output logic lane_rcu_res_c08_s1_credit,
  output logic lane_rcu_res_c08_s1_stall,
  // lane -> rcu, copy 8, slot 2 of 4
  input  logic lane_rcu_res_c08_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c08_s2_payload,
  output logic lane_rcu_res_c08_s2_credit,
  output logic lane_rcu_res_c08_s2_stall,
  // lane -> rcu, copy 8, slot 3 of 4
  input  logic lane_rcu_res_c08_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c08_s3_payload,
  output logic lane_rcu_res_c08_s3_credit,
  output logic lane_rcu_res_c08_s3_stall,
  input  logic lane_rcu_res_c08_wake,
  // lane -> rcu, copy 9, slot 0 of 4
  input  logic lane_rcu_res_c09_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c09_s0_payload,
  output logic lane_rcu_res_c09_s0_credit,
  output logic lane_rcu_res_c09_s0_stall,
  // lane -> rcu, copy 9, slot 1 of 4
  input  logic lane_rcu_res_c09_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c09_s1_payload,
  output logic lane_rcu_res_c09_s1_credit,
  output logic lane_rcu_res_c09_s1_stall,
  // lane -> rcu, copy 9, slot 2 of 4
  input  logic lane_rcu_res_c09_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c09_s2_payload,
  output logic lane_rcu_res_c09_s2_credit,
  output logic lane_rcu_res_c09_s2_stall,
  // lane -> rcu, copy 9, slot 3 of 4
  input  logic lane_rcu_res_c09_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c09_s3_payload,
  output logic lane_rcu_res_c09_s3_credit,
  output logic lane_rcu_res_c09_s3_stall,
  input  logic lane_rcu_res_c09_wake,
  // lane -> rcu, copy 10, slot 0 of 4
  input  logic lane_rcu_res_c10_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c10_s0_payload,
  output logic lane_rcu_res_c10_s0_credit,
  output logic lane_rcu_res_c10_s0_stall,
  // lane -> rcu, copy 10, slot 1 of 4
  input  logic lane_rcu_res_c10_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c10_s1_payload,
  output logic lane_rcu_res_c10_s1_credit,
  output logic lane_rcu_res_c10_s1_stall,
  // lane -> rcu, copy 10, slot 2 of 4
  input  logic lane_rcu_res_c10_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c10_s2_payload,
  output logic lane_rcu_res_c10_s2_credit,
  output logic lane_rcu_res_c10_s2_stall,
  // lane -> rcu, copy 10, slot 3 of 4
  input  logic lane_rcu_res_c10_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c10_s3_payload,
  output logic lane_rcu_res_c10_s3_credit,
  output logic lane_rcu_res_c10_s3_stall,
  input  logic lane_rcu_res_c10_wake,
  // lane -> rcu, copy 11, slot 0 of 4
  input  logic lane_rcu_res_c11_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c11_s0_payload,
  output logic lane_rcu_res_c11_s0_credit,
  output logic lane_rcu_res_c11_s0_stall,
  // lane -> rcu, copy 11, slot 1 of 4
  input  logic lane_rcu_res_c11_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c11_s1_payload,
  output logic lane_rcu_res_c11_s1_credit,
  output logic lane_rcu_res_c11_s1_stall,
  // lane -> rcu, copy 11, slot 2 of 4
  input  logic lane_rcu_res_c11_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c11_s2_payload,
  output logic lane_rcu_res_c11_s2_credit,
  output logic lane_rcu_res_c11_s2_stall,
  // lane -> rcu, copy 11, slot 3 of 4
  input  logic lane_rcu_res_c11_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c11_s3_payload,
  output logic lane_rcu_res_c11_s3_credit,
  output logic lane_rcu_res_c11_s3_stall,
  input  logic lane_rcu_res_c11_wake,
  // lane -> rcu, copy 12, slot 0 of 4
  input  logic lane_rcu_res_c12_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c12_s0_payload,
  output logic lane_rcu_res_c12_s0_credit,
  output logic lane_rcu_res_c12_s0_stall,
  // lane -> rcu, copy 12, slot 1 of 4
  input  logic lane_rcu_res_c12_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c12_s1_payload,
  output logic lane_rcu_res_c12_s1_credit,
  output logic lane_rcu_res_c12_s1_stall,
  // lane -> rcu, copy 12, slot 2 of 4
  input  logic lane_rcu_res_c12_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c12_s2_payload,
  output logic lane_rcu_res_c12_s2_credit,
  output logic lane_rcu_res_c12_s2_stall,
  // lane -> rcu, copy 12, slot 3 of 4
  input  logic lane_rcu_res_c12_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c12_s3_payload,
  output logic lane_rcu_res_c12_s3_credit,
  output logic lane_rcu_res_c12_s3_stall,
  input  logic lane_rcu_res_c12_wake,
  // lane -> rcu, copy 13, slot 0 of 4
  input  logic lane_rcu_res_c13_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c13_s0_payload,
  output logic lane_rcu_res_c13_s0_credit,
  output logic lane_rcu_res_c13_s0_stall,
  // lane -> rcu, copy 13, slot 1 of 4
  input  logic lane_rcu_res_c13_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c13_s1_payload,
  output logic lane_rcu_res_c13_s1_credit,
  output logic lane_rcu_res_c13_s1_stall,
  // lane -> rcu, copy 13, slot 2 of 4
  input  logic lane_rcu_res_c13_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c13_s2_payload,
  output logic lane_rcu_res_c13_s2_credit,
  output logic lane_rcu_res_c13_s2_stall,
  // lane -> rcu, copy 13, slot 3 of 4
  input  logic lane_rcu_res_c13_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c13_s3_payload,
  output logic lane_rcu_res_c13_s3_credit,
  output logic lane_rcu_res_c13_s3_stall,
  input  logic lane_rcu_res_c13_wake,
  // lane -> rcu, copy 14, slot 0 of 4
  input  logic lane_rcu_res_c14_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c14_s0_payload,
  output logic lane_rcu_res_c14_s0_credit,
  output logic lane_rcu_res_c14_s0_stall,
  // lane -> rcu, copy 14, slot 1 of 4
  input  logic lane_rcu_res_c14_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c14_s1_payload,
  output logic lane_rcu_res_c14_s1_credit,
  output logic lane_rcu_res_c14_s1_stall,
  // lane -> rcu, copy 14, slot 2 of 4
  input  logic lane_rcu_res_c14_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c14_s2_payload,
  output logic lane_rcu_res_c14_s2_credit,
  output logic lane_rcu_res_c14_s2_stall,
  // lane -> rcu, copy 14, slot 3 of 4
  input  logic lane_rcu_res_c14_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c14_s3_payload,
  output logic lane_rcu_res_c14_s3_credit,
  output logic lane_rcu_res_c14_s3_stall,
  input  logic lane_rcu_res_c14_wake,
  // lane -> rcu, copy 15, slot 0 of 4
  input  logic lane_rcu_res_c15_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c15_s0_payload,
  output logic lane_rcu_res_c15_s0_credit,
  output logic lane_rcu_res_c15_s0_stall,
  // lane -> rcu, copy 15, slot 1 of 4
  input  logic lane_rcu_res_c15_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c15_s1_payload,
  output logic lane_rcu_res_c15_s1_credit,
  output logic lane_rcu_res_c15_s1_stall,
  // lane -> rcu, copy 15, slot 2 of 4
  input  logic lane_rcu_res_c15_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c15_s2_payload,
  output logic lane_rcu_res_c15_s2_credit,
  output logic lane_rcu_res_c15_s2_stall,
  // lane -> rcu, copy 15, slot 3 of 4
  input  logic lane_rcu_res_c15_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c15_s3_payload,
  output logic lane_rcu_res_c15_s3_credit,
  output logic lane_rcu_res_c15_s3_stall,
  input  logic lane_rcu_res_c15_wake,
  // lane -> rcu, copy 16, slot 0 of 4
  input  logic lane_rcu_res_c16_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c16_s0_payload,
  output logic lane_rcu_res_c16_s0_credit,
  output logic lane_rcu_res_c16_s0_stall,
  // lane -> rcu, copy 16, slot 1 of 4
  input  logic lane_rcu_res_c16_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c16_s1_payload,
  output logic lane_rcu_res_c16_s1_credit,
  output logic lane_rcu_res_c16_s1_stall,
  // lane -> rcu, copy 16, slot 2 of 4
  input  logic lane_rcu_res_c16_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c16_s2_payload,
  output logic lane_rcu_res_c16_s2_credit,
  output logic lane_rcu_res_c16_s2_stall,
  // lane -> rcu, copy 16, slot 3 of 4
  input  logic lane_rcu_res_c16_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c16_s3_payload,
  output logic lane_rcu_res_c16_s3_credit,
  output logic lane_rcu_res_c16_s3_stall,
  input  logic lane_rcu_res_c16_wake,
  // lane -> rcu, copy 17, slot 0 of 4
  input  logic lane_rcu_res_c17_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c17_s0_payload,
  output logic lane_rcu_res_c17_s0_credit,
  output logic lane_rcu_res_c17_s0_stall,
  // lane -> rcu, copy 17, slot 1 of 4
  input  logic lane_rcu_res_c17_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c17_s1_payload,
  output logic lane_rcu_res_c17_s1_credit,
  output logic lane_rcu_res_c17_s1_stall,
  // lane -> rcu, copy 17, slot 2 of 4
  input  logic lane_rcu_res_c17_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c17_s2_payload,
  output logic lane_rcu_res_c17_s2_credit,
  output logic lane_rcu_res_c17_s2_stall,
  // lane -> rcu, copy 17, slot 3 of 4
  input  logic lane_rcu_res_c17_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c17_s3_payload,
  output logic lane_rcu_res_c17_s3_credit,
  output logic lane_rcu_res_c17_s3_stall,
  input  logic lane_rcu_res_c17_wake,
  // lane -> rcu, copy 18, slot 0 of 4
  input  logic lane_rcu_res_c18_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c18_s0_payload,
  output logic lane_rcu_res_c18_s0_credit,
  output logic lane_rcu_res_c18_s0_stall,
  // lane -> rcu, copy 18, slot 1 of 4
  input  logic lane_rcu_res_c18_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c18_s1_payload,
  output logic lane_rcu_res_c18_s1_credit,
  output logic lane_rcu_res_c18_s1_stall,
  // lane -> rcu, copy 18, slot 2 of 4
  input  logic lane_rcu_res_c18_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c18_s2_payload,
  output logic lane_rcu_res_c18_s2_credit,
  output logic lane_rcu_res_c18_s2_stall,
  // lane -> rcu, copy 18, slot 3 of 4
  input  logic lane_rcu_res_c18_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c18_s3_payload,
  output logic lane_rcu_res_c18_s3_credit,
  output logic lane_rcu_res_c18_s3_stall,
  input  logic lane_rcu_res_c18_wake,
  // lane -> rcu, copy 19, slot 0 of 4
  input  logic lane_rcu_res_c19_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c19_s0_payload,
  output logic lane_rcu_res_c19_s0_credit,
  output logic lane_rcu_res_c19_s0_stall,
  // lane -> rcu, copy 19, slot 1 of 4
  input  logic lane_rcu_res_c19_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c19_s1_payload,
  output logic lane_rcu_res_c19_s1_credit,
  output logic lane_rcu_res_c19_s1_stall,
  // lane -> rcu, copy 19, slot 2 of 4
  input  logic lane_rcu_res_c19_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c19_s2_payload,
  output logic lane_rcu_res_c19_s2_credit,
  output logic lane_rcu_res_c19_s2_stall,
  // lane -> rcu, copy 19, slot 3 of 4
  input  logic lane_rcu_res_c19_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c19_s3_payload,
  output logic lane_rcu_res_c19_s3_credit,
  output logic lane_rcu_res_c19_s3_stall,
  input  logic lane_rcu_res_c19_wake,
  // lane -> rcu, copy 20, slot 0 of 4
  input  logic lane_rcu_res_c20_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c20_s0_payload,
  output logic lane_rcu_res_c20_s0_credit,
  output logic lane_rcu_res_c20_s0_stall,
  // lane -> rcu, copy 20, slot 1 of 4
  input  logic lane_rcu_res_c20_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c20_s1_payload,
  output logic lane_rcu_res_c20_s1_credit,
  output logic lane_rcu_res_c20_s1_stall,
  // lane -> rcu, copy 20, slot 2 of 4
  input  logic lane_rcu_res_c20_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c20_s2_payload,
  output logic lane_rcu_res_c20_s2_credit,
  output logic lane_rcu_res_c20_s2_stall,
  // lane -> rcu, copy 20, slot 3 of 4
  input  logic lane_rcu_res_c20_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c20_s3_payload,
  output logic lane_rcu_res_c20_s3_credit,
  output logic lane_rcu_res_c20_s3_stall,
  input  logic lane_rcu_res_c20_wake,
  // lane -> rcu, copy 21, slot 0 of 4
  input  logic lane_rcu_res_c21_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c21_s0_payload,
  output logic lane_rcu_res_c21_s0_credit,
  output logic lane_rcu_res_c21_s0_stall,
  // lane -> rcu, copy 21, slot 1 of 4
  input  logic lane_rcu_res_c21_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c21_s1_payload,
  output logic lane_rcu_res_c21_s1_credit,
  output logic lane_rcu_res_c21_s1_stall,
  // lane -> rcu, copy 21, slot 2 of 4
  input  logic lane_rcu_res_c21_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c21_s2_payload,
  output logic lane_rcu_res_c21_s2_credit,
  output logic lane_rcu_res_c21_s2_stall,
  // lane -> rcu, copy 21, slot 3 of 4
  input  logic lane_rcu_res_c21_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c21_s3_payload,
  output logic lane_rcu_res_c21_s3_credit,
  output logic lane_rcu_res_c21_s3_stall,
  input  logic lane_rcu_res_c21_wake,
  // lane -> rcu, copy 22, slot 0 of 4
  input  logic lane_rcu_res_c22_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c22_s0_payload,
  output logic lane_rcu_res_c22_s0_credit,
  output logic lane_rcu_res_c22_s0_stall,
  // lane -> rcu, copy 22, slot 1 of 4
  input  logic lane_rcu_res_c22_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c22_s1_payload,
  output logic lane_rcu_res_c22_s1_credit,
  output logic lane_rcu_res_c22_s1_stall,
  // lane -> rcu, copy 22, slot 2 of 4
  input  logic lane_rcu_res_c22_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c22_s2_payload,
  output logic lane_rcu_res_c22_s2_credit,
  output logic lane_rcu_res_c22_s2_stall,
  // lane -> rcu, copy 22, slot 3 of 4
  input  logic lane_rcu_res_c22_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c22_s3_payload,
  output logic lane_rcu_res_c22_s3_credit,
  output logic lane_rcu_res_c22_s3_stall,
  input  logic lane_rcu_res_c22_wake,
  // lane -> rcu, copy 23, slot 0 of 4
  input  logic lane_rcu_res_c23_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c23_s0_payload,
  output logic lane_rcu_res_c23_s0_credit,
  output logic lane_rcu_res_c23_s0_stall,
  // lane -> rcu, copy 23, slot 1 of 4
  input  logic lane_rcu_res_c23_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c23_s1_payload,
  output logic lane_rcu_res_c23_s1_credit,
  output logic lane_rcu_res_c23_s1_stall,
  // lane -> rcu, copy 23, slot 2 of 4
  input  logic lane_rcu_res_c23_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c23_s2_payload,
  output logic lane_rcu_res_c23_s2_credit,
  output logic lane_rcu_res_c23_s2_stall,
  // lane -> rcu, copy 23, slot 3 of 4
  input  logic lane_rcu_res_c23_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c23_s3_payload,
  output logic lane_rcu_res_c23_s3_credit,
  output logic lane_rcu_res_c23_s3_stall,
  input  logic lane_rcu_res_c23_wake,
  // lane -> rcu, copy 24, slot 0 of 4
  input  logic lane_rcu_res_c24_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c24_s0_payload,
  output logic lane_rcu_res_c24_s0_credit,
  output logic lane_rcu_res_c24_s0_stall,
  // lane -> rcu, copy 24, slot 1 of 4
  input  logic lane_rcu_res_c24_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c24_s1_payload,
  output logic lane_rcu_res_c24_s1_credit,
  output logic lane_rcu_res_c24_s1_stall,
  // lane -> rcu, copy 24, slot 2 of 4
  input  logic lane_rcu_res_c24_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c24_s2_payload,
  output logic lane_rcu_res_c24_s2_credit,
  output logic lane_rcu_res_c24_s2_stall,
  // lane -> rcu, copy 24, slot 3 of 4
  input  logic lane_rcu_res_c24_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c24_s3_payload,
  output logic lane_rcu_res_c24_s3_credit,
  output logic lane_rcu_res_c24_s3_stall,
  input  logic lane_rcu_res_c24_wake,
  // lane -> rcu, copy 25, slot 0 of 4
  input  logic lane_rcu_res_c25_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c25_s0_payload,
  output logic lane_rcu_res_c25_s0_credit,
  output logic lane_rcu_res_c25_s0_stall,
  // lane -> rcu, copy 25, slot 1 of 4
  input  logic lane_rcu_res_c25_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c25_s1_payload,
  output logic lane_rcu_res_c25_s1_credit,
  output logic lane_rcu_res_c25_s1_stall,
  // lane -> rcu, copy 25, slot 2 of 4
  input  logic lane_rcu_res_c25_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c25_s2_payload,
  output logic lane_rcu_res_c25_s2_credit,
  output logic lane_rcu_res_c25_s2_stall,
  // lane -> rcu, copy 25, slot 3 of 4
  input  logic lane_rcu_res_c25_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c25_s3_payload,
  output logic lane_rcu_res_c25_s3_credit,
  output logic lane_rcu_res_c25_s3_stall,
  input  logic lane_rcu_res_c25_wake,
  // lane -> rcu, copy 26, slot 0 of 4
  input  logic lane_rcu_res_c26_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c26_s0_payload,
  output logic lane_rcu_res_c26_s0_credit,
  output logic lane_rcu_res_c26_s0_stall,
  // lane -> rcu, copy 26, slot 1 of 4
  input  logic lane_rcu_res_c26_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c26_s1_payload,
  output logic lane_rcu_res_c26_s1_credit,
  output logic lane_rcu_res_c26_s1_stall,
  // lane -> rcu, copy 26, slot 2 of 4
  input  logic lane_rcu_res_c26_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c26_s2_payload,
  output logic lane_rcu_res_c26_s2_credit,
  output logic lane_rcu_res_c26_s2_stall,
  // lane -> rcu, copy 26, slot 3 of 4
  input  logic lane_rcu_res_c26_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c26_s3_payload,
  output logic lane_rcu_res_c26_s3_credit,
  output logic lane_rcu_res_c26_s3_stall,
  input  logic lane_rcu_res_c26_wake,
  // lane -> rcu, copy 27, slot 0 of 4
  input  logic lane_rcu_res_c27_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c27_s0_payload,
  output logic lane_rcu_res_c27_s0_credit,
  output logic lane_rcu_res_c27_s0_stall,
  // lane -> rcu, copy 27, slot 1 of 4
  input  logic lane_rcu_res_c27_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c27_s1_payload,
  output logic lane_rcu_res_c27_s1_credit,
  output logic lane_rcu_res_c27_s1_stall,
  // lane -> rcu, copy 27, slot 2 of 4
  input  logic lane_rcu_res_c27_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c27_s2_payload,
  output logic lane_rcu_res_c27_s2_credit,
  output logic lane_rcu_res_c27_s2_stall,
  // lane -> rcu, copy 27, slot 3 of 4
  input  logic lane_rcu_res_c27_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c27_s3_payload,
  output logic lane_rcu_res_c27_s3_credit,
  output logic lane_rcu_res_c27_s3_stall,
  input  logic lane_rcu_res_c27_wake,
  // lane -> rcu, copy 28, slot 0 of 4
  input  logic lane_rcu_res_c28_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c28_s0_payload,
  output logic lane_rcu_res_c28_s0_credit,
  output logic lane_rcu_res_c28_s0_stall,
  // lane -> rcu, copy 28, slot 1 of 4
  input  logic lane_rcu_res_c28_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c28_s1_payload,
  output logic lane_rcu_res_c28_s1_credit,
  output logic lane_rcu_res_c28_s1_stall,
  // lane -> rcu, copy 28, slot 2 of 4
  input  logic lane_rcu_res_c28_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c28_s2_payload,
  output logic lane_rcu_res_c28_s2_credit,
  output logic lane_rcu_res_c28_s2_stall,
  // lane -> rcu, copy 28, slot 3 of 4
  input  logic lane_rcu_res_c28_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c28_s3_payload,
  output logic lane_rcu_res_c28_s3_credit,
  output logic lane_rcu_res_c28_s3_stall,
  input  logic lane_rcu_res_c28_wake,
  // lane -> rcu, copy 29, slot 0 of 4
  input  logic lane_rcu_res_c29_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c29_s0_payload,
  output logic lane_rcu_res_c29_s0_credit,
  output logic lane_rcu_res_c29_s0_stall,
  // lane -> rcu, copy 29, slot 1 of 4
  input  logic lane_rcu_res_c29_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c29_s1_payload,
  output logic lane_rcu_res_c29_s1_credit,
  output logic lane_rcu_res_c29_s1_stall,
  // lane -> rcu, copy 29, slot 2 of 4
  input  logic lane_rcu_res_c29_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c29_s2_payload,
  output logic lane_rcu_res_c29_s2_credit,
  output logic lane_rcu_res_c29_s2_stall,
  // lane -> rcu, copy 29, slot 3 of 4
  input  logic lane_rcu_res_c29_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c29_s3_payload,
  output logic lane_rcu_res_c29_s3_credit,
  output logic lane_rcu_res_c29_s3_stall,
  input  logic lane_rcu_res_c29_wake,
  // lane -> rcu, copy 30, slot 0 of 4
  input  logic lane_rcu_res_c30_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c30_s0_payload,
  output logic lane_rcu_res_c30_s0_credit,
  output logic lane_rcu_res_c30_s0_stall,
  // lane -> rcu, copy 30, slot 1 of 4
  input  logic lane_rcu_res_c30_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c30_s1_payload,
  output logic lane_rcu_res_c30_s1_credit,
  output logic lane_rcu_res_c30_s1_stall,
  // lane -> rcu, copy 30, slot 2 of 4
  input  logic lane_rcu_res_c30_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c30_s2_payload,
  output logic lane_rcu_res_c30_s2_credit,
  output logic lane_rcu_res_c30_s2_stall,
  // lane -> rcu, copy 30, slot 3 of 4
  input  logic lane_rcu_res_c30_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c30_s3_payload,
  output logic lane_rcu_res_c30_s3_credit,
  output logic lane_rcu_res_c30_s3_stall,
  input  logic lane_rcu_res_c30_wake,
  // lane -> rcu, copy 31, slot 0 of 4
  input  logic lane_rcu_res_c31_s0_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c31_s0_payload,
  output logic lane_rcu_res_c31_s0_credit,
  output logic lane_rcu_res_c31_s0_stall,
  // lane -> rcu, copy 31, slot 1 of 4
  input  logic lane_rcu_res_c31_s1_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c31_s1_payload,
  output logic lane_rcu_res_c31_s1_credit,
  output logic lane_rcu_res_c31_s1_stall,
  // lane -> rcu, copy 31, slot 2 of 4
  input  logic lane_rcu_res_c31_s2_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c31_s2_payload,
  output logic lane_rcu_res_c31_s2_credit,
  output logic lane_rcu_res_c31_s2_stall,
  // lane -> rcu, copy 31, slot 3 of 4
  input  logic lane_rcu_res_c31_s3_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c31_s3_payload,
  output logic lane_rcu_res_c31_s3_credit,
  output logic lane_rcu_res_c31_s3_stall,
  input  logic lane_rcu_res_c31_wake,
  // rcu -> ooe, slot 0 of 4
  output logic rcu_ooe_done_s0_valid,
  output ccv_rcu_ooe_done_t rcu_ooe_done_s0_payload,
  input  logic rcu_ooe_done_s0_credit,
  input  logic rcu_ooe_done_s0_stall,
  // rcu -> ooe, slot 1 of 4
  output logic rcu_ooe_done_s1_valid,
  output ccv_rcu_ooe_done_t rcu_ooe_done_s1_payload,
  input  logic rcu_ooe_done_s1_credit,
  input  logic rcu_ooe_done_s1_stall,
  // rcu -> ooe, slot 2 of 4
  output logic rcu_ooe_done_s2_valid,
  output ccv_rcu_ooe_done_t rcu_ooe_done_s2_payload,
  input  logic rcu_ooe_done_s2_credit,
  input  logic rcu_ooe_done_s2_stall,
  // rcu -> ooe, slot 3 of 4
  output logic rcu_ooe_done_s3_valid,
  output ccv_rcu_ooe_done_t rcu_ooe_done_s3_payload,
  input  logic rcu_ooe_done_s3_credit,
  input  logic rcu_ooe_done_s3_stall,
  output logic rcu_ooe_done_wake,
  // rcu -> miu, slot 0 of 4
  output logic rcu_miu_addr_s0_valid,
  output ccv_rcu_miu_addr_t rcu_miu_addr_s0_payload,
  input  logic rcu_miu_addr_s0_credit,
  input  logic rcu_miu_addr_s0_stall,
  // rcu -> miu, slot 1 of 4
  output logic rcu_miu_addr_s1_valid,
  output ccv_rcu_miu_addr_t rcu_miu_addr_s1_payload,
  input  logic rcu_miu_addr_s1_credit,
  input  logic rcu_miu_addr_s1_stall,
  // rcu -> miu, slot 2 of 4
  output logic rcu_miu_addr_s2_valid,
  output ccv_rcu_miu_addr_t rcu_miu_addr_s2_payload,
  input  logic rcu_miu_addr_s2_credit,
  input  logic rcu_miu_addr_s2_stall,
  // rcu -> miu, slot 3 of 4
  output logic rcu_miu_addr_s3_valid,
  output ccv_rcu_miu_addr_t rcu_miu_addr_s3_payload,
  input  logic rcu_miu_addr_s3_credit,
  input  logic rcu_miu_addr_s3_stall,
  output logic rcu_miu_addr_wake,
  // miu -> rcu, slot 0 of 4
  input  logic miu_rcu_data_s0_valid,
  input  ccv_miu_rcu_data_t miu_rcu_data_s0_payload,
  output logic miu_rcu_data_s0_credit,
  output logic miu_rcu_data_s0_stall,
  // miu -> rcu, slot 1 of 4
  input  logic miu_rcu_data_s1_valid,
  input  ccv_miu_rcu_data_t miu_rcu_data_s1_payload,
  output logic miu_rcu_data_s1_credit,
  output logic miu_rcu_data_s1_stall,
  // miu -> rcu, slot 2 of 4
  input  logic miu_rcu_data_s2_valid,
  input  ccv_miu_rcu_data_t miu_rcu_data_s2_payload,
  output logic miu_rcu_data_s2_credit,
  output logic miu_rcu_data_s2_stall,
  // miu -> rcu, slot 3 of 4
  input  logic miu_rcu_data_s3_valid,
  input  ccv_miu_rcu_data_t miu_rcu_data_s3_payload,
  output logic miu_rcu_data_s3_credit,
  output logic miu_rcu_data_s3_stall,
  input  logic miu_rcu_data_wake,
  // rau -> rcu
  input  logic rau_rcu_mig_valid,
  input  ccv_rau_rcu_mig_t rau_rcu_mig_payload,
  output logic rau_rcu_mig_credit,
  output logic rau_rcu_mig_stall,
  input  logic rau_rcu_mig_wake,
  // rcu -> pca
  output logic rcu_pca_mig_valid,
  output ccv_rcu_pca_mig_t rcu_pca_mig_payload,
  input  logic rcu_pca_mig_credit,
  input  logic rcu_pca_mig_stall,
  output logic rcu_pca_mig_wake,
  // pca -> rcu
  input  logic pca_rcu_mig_valid,
  input  ccv_pca_rcu_mig_t pca_rcu_mig_payload,
  output logic pca_rcu_mig_credit,
  output logic pca_rcu_mig_stall,
  input  logic pca_rcu_mig_wake
`ifdef CCV_CHECK
  , output logic clk_gated
`endif
`ifdef CCV_TRACE
  , input  logic [63:0] ooe_rcu_issue_s0_tid
  , input  logic [63:0] ooe_rcu_issue_s1_tid
  , input  logic [63:0] ooe_rcu_issue_s2_tid
  , input  logic [63:0] ooe_rcu_issue_s3_tid
  , output logic [63:0] rcu_lane_ops_c00_s0_tid
  , output logic [63:0] rcu_lane_ops_c00_s1_tid
  , output logic [63:0] rcu_lane_ops_c00_s2_tid
  , output logic [63:0] rcu_lane_ops_c00_s3_tid
  , output logic [63:0] rcu_lane_ops_c01_s0_tid
  , output logic [63:0] rcu_lane_ops_c01_s1_tid
  , output logic [63:0] rcu_lane_ops_c01_s2_tid
  , output logic [63:0] rcu_lane_ops_c01_s3_tid
  , output logic [63:0] rcu_lane_ops_c02_s0_tid
  , output logic [63:0] rcu_lane_ops_c02_s1_tid
  , output logic [63:0] rcu_lane_ops_c02_s2_tid
  , output logic [63:0] rcu_lane_ops_c02_s3_tid
  , output logic [63:0] rcu_lane_ops_c03_s0_tid
  , output logic [63:0] rcu_lane_ops_c03_s1_tid
  , output logic [63:0] rcu_lane_ops_c03_s2_tid
  , output logic [63:0] rcu_lane_ops_c03_s3_tid
  , output logic [63:0] rcu_lane_ops_c04_s0_tid
  , output logic [63:0] rcu_lane_ops_c04_s1_tid
  , output logic [63:0] rcu_lane_ops_c04_s2_tid
  , output logic [63:0] rcu_lane_ops_c04_s3_tid
  , output logic [63:0] rcu_lane_ops_c05_s0_tid
  , output logic [63:0] rcu_lane_ops_c05_s1_tid
  , output logic [63:0] rcu_lane_ops_c05_s2_tid
  , output logic [63:0] rcu_lane_ops_c05_s3_tid
  , output logic [63:0] rcu_lane_ops_c06_s0_tid
  , output logic [63:0] rcu_lane_ops_c06_s1_tid
  , output logic [63:0] rcu_lane_ops_c06_s2_tid
  , output logic [63:0] rcu_lane_ops_c06_s3_tid
  , output logic [63:0] rcu_lane_ops_c07_s0_tid
  , output logic [63:0] rcu_lane_ops_c07_s1_tid
  , output logic [63:0] rcu_lane_ops_c07_s2_tid
  , output logic [63:0] rcu_lane_ops_c07_s3_tid
  , output logic [63:0] rcu_lane_ops_c08_s0_tid
  , output logic [63:0] rcu_lane_ops_c08_s1_tid
  , output logic [63:0] rcu_lane_ops_c08_s2_tid
  , output logic [63:0] rcu_lane_ops_c08_s3_tid
  , output logic [63:0] rcu_lane_ops_c09_s0_tid
  , output logic [63:0] rcu_lane_ops_c09_s1_tid
  , output logic [63:0] rcu_lane_ops_c09_s2_tid
  , output logic [63:0] rcu_lane_ops_c09_s3_tid
  , output logic [63:0] rcu_lane_ops_c10_s0_tid
  , output logic [63:0] rcu_lane_ops_c10_s1_tid
  , output logic [63:0] rcu_lane_ops_c10_s2_tid
  , output logic [63:0] rcu_lane_ops_c10_s3_tid
  , output logic [63:0] rcu_lane_ops_c11_s0_tid
  , output logic [63:0] rcu_lane_ops_c11_s1_tid
  , output logic [63:0] rcu_lane_ops_c11_s2_tid
  , output logic [63:0] rcu_lane_ops_c11_s3_tid
  , output logic [63:0] rcu_lane_ops_c12_s0_tid
  , output logic [63:0] rcu_lane_ops_c12_s1_tid
  , output logic [63:0] rcu_lane_ops_c12_s2_tid
  , output logic [63:0] rcu_lane_ops_c12_s3_tid
  , output logic [63:0] rcu_lane_ops_c13_s0_tid
  , output logic [63:0] rcu_lane_ops_c13_s1_tid
  , output logic [63:0] rcu_lane_ops_c13_s2_tid
  , output logic [63:0] rcu_lane_ops_c13_s3_tid
  , output logic [63:0] rcu_lane_ops_c14_s0_tid
  , output logic [63:0] rcu_lane_ops_c14_s1_tid
  , output logic [63:0] rcu_lane_ops_c14_s2_tid
  , output logic [63:0] rcu_lane_ops_c14_s3_tid
  , output logic [63:0] rcu_lane_ops_c15_s0_tid
  , output logic [63:0] rcu_lane_ops_c15_s1_tid
  , output logic [63:0] rcu_lane_ops_c15_s2_tid
  , output logic [63:0] rcu_lane_ops_c15_s3_tid
  , output logic [63:0] rcu_lane_ops_c16_s0_tid
  , output logic [63:0] rcu_lane_ops_c16_s1_tid
  , output logic [63:0] rcu_lane_ops_c16_s2_tid
  , output logic [63:0] rcu_lane_ops_c16_s3_tid
  , output logic [63:0] rcu_lane_ops_c17_s0_tid
  , output logic [63:0] rcu_lane_ops_c17_s1_tid
  , output logic [63:0] rcu_lane_ops_c17_s2_tid
  , output logic [63:0] rcu_lane_ops_c17_s3_tid
  , output logic [63:0] rcu_lane_ops_c18_s0_tid
  , output logic [63:0] rcu_lane_ops_c18_s1_tid
  , output logic [63:0] rcu_lane_ops_c18_s2_tid
  , output logic [63:0] rcu_lane_ops_c18_s3_tid
  , output logic [63:0] rcu_lane_ops_c19_s0_tid
  , output logic [63:0] rcu_lane_ops_c19_s1_tid
  , output logic [63:0] rcu_lane_ops_c19_s2_tid
  , output logic [63:0] rcu_lane_ops_c19_s3_tid
  , output logic [63:0] rcu_lane_ops_c20_s0_tid
  , output logic [63:0] rcu_lane_ops_c20_s1_tid
  , output logic [63:0] rcu_lane_ops_c20_s2_tid
  , output logic [63:0] rcu_lane_ops_c20_s3_tid
  , output logic [63:0] rcu_lane_ops_c21_s0_tid
  , output logic [63:0] rcu_lane_ops_c21_s1_tid
  , output logic [63:0] rcu_lane_ops_c21_s2_tid
  , output logic [63:0] rcu_lane_ops_c21_s3_tid
  , output logic [63:0] rcu_lane_ops_c22_s0_tid
  , output logic [63:0] rcu_lane_ops_c22_s1_tid
  , output logic [63:0] rcu_lane_ops_c22_s2_tid
  , output logic [63:0] rcu_lane_ops_c22_s3_tid
  , output logic [63:0] rcu_lane_ops_c23_s0_tid
  , output logic [63:0] rcu_lane_ops_c23_s1_tid
  , output logic [63:0] rcu_lane_ops_c23_s2_tid
  , output logic [63:0] rcu_lane_ops_c23_s3_tid
  , output logic [63:0] rcu_lane_ops_c24_s0_tid
  , output logic [63:0] rcu_lane_ops_c24_s1_tid
  , output logic [63:0] rcu_lane_ops_c24_s2_tid
  , output logic [63:0] rcu_lane_ops_c24_s3_tid
  , output logic [63:0] rcu_lane_ops_c25_s0_tid
  , output logic [63:0] rcu_lane_ops_c25_s1_tid
  , output logic [63:0] rcu_lane_ops_c25_s2_tid
  , output logic [63:0] rcu_lane_ops_c25_s3_tid
  , output logic [63:0] rcu_lane_ops_c26_s0_tid
  , output logic [63:0] rcu_lane_ops_c26_s1_tid
  , output logic [63:0] rcu_lane_ops_c26_s2_tid
  , output logic [63:0] rcu_lane_ops_c26_s3_tid
  , output logic [63:0] rcu_lane_ops_c27_s0_tid
  , output logic [63:0] rcu_lane_ops_c27_s1_tid
  , output logic [63:0] rcu_lane_ops_c27_s2_tid
  , output logic [63:0] rcu_lane_ops_c27_s3_tid
  , output logic [63:0] rcu_lane_ops_c28_s0_tid
  , output logic [63:0] rcu_lane_ops_c28_s1_tid
  , output logic [63:0] rcu_lane_ops_c28_s2_tid
  , output logic [63:0] rcu_lane_ops_c28_s3_tid
  , output logic [63:0] rcu_lane_ops_c29_s0_tid
  , output logic [63:0] rcu_lane_ops_c29_s1_tid
  , output logic [63:0] rcu_lane_ops_c29_s2_tid
  , output logic [63:0] rcu_lane_ops_c29_s3_tid
  , output logic [63:0] rcu_lane_ops_c30_s0_tid
  , output logic [63:0] rcu_lane_ops_c30_s1_tid
  , output logic [63:0] rcu_lane_ops_c30_s2_tid
  , output logic [63:0] rcu_lane_ops_c30_s3_tid
  , output logic [63:0] rcu_lane_ops_c31_s0_tid
  , output logic [63:0] rcu_lane_ops_c31_s1_tid
  , output logic [63:0] rcu_lane_ops_c31_s2_tid
  , output logic [63:0] rcu_lane_ops_c31_s3_tid
  , input  logic [63:0] lane_rcu_res_c00_s0_tid
  , input  logic [63:0] lane_rcu_res_c00_s1_tid
  , input  logic [63:0] lane_rcu_res_c00_s2_tid
  , input  logic [63:0] lane_rcu_res_c00_s3_tid
  , input  logic [63:0] lane_rcu_res_c01_s0_tid
  , input  logic [63:0] lane_rcu_res_c01_s1_tid
  , input  logic [63:0] lane_rcu_res_c01_s2_tid
  , input  logic [63:0] lane_rcu_res_c01_s3_tid
  , input  logic [63:0] lane_rcu_res_c02_s0_tid
  , input  logic [63:0] lane_rcu_res_c02_s1_tid
  , input  logic [63:0] lane_rcu_res_c02_s2_tid
  , input  logic [63:0] lane_rcu_res_c02_s3_tid
  , input  logic [63:0] lane_rcu_res_c03_s0_tid
  , input  logic [63:0] lane_rcu_res_c03_s1_tid
  , input  logic [63:0] lane_rcu_res_c03_s2_tid
  , input  logic [63:0] lane_rcu_res_c03_s3_tid
  , input  logic [63:0] lane_rcu_res_c04_s0_tid
  , input  logic [63:0] lane_rcu_res_c04_s1_tid
  , input  logic [63:0] lane_rcu_res_c04_s2_tid
  , input  logic [63:0] lane_rcu_res_c04_s3_tid
  , input  logic [63:0] lane_rcu_res_c05_s0_tid
  , input  logic [63:0] lane_rcu_res_c05_s1_tid
  , input  logic [63:0] lane_rcu_res_c05_s2_tid
  , input  logic [63:0] lane_rcu_res_c05_s3_tid
  , input  logic [63:0] lane_rcu_res_c06_s0_tid
  , input  logic [63:0] lane_rcu_res_c06_s1_tid
  , input  logic [63:0] lane_rcu_res_c06_s2_tid
  , input  logic [63:0] lane_rcu_res_c06_s3_tid
  , input  logic [63:0] lane_rcu_res_c07_s0_tid
  , input  logic [63:0] lane_rcu_res_c07_s1_tid
  , input  logic [63:0] lane_rcu_res_c07_s2_tid
  , input  logic [63:0] lane_rcu_res_c07_s3_tid
  , input  logic [63:0] lane_rcu_res_c08_s0_tid
  , input  logic [63:0] lane_rcu_res_c08_s1_tid
  , input  logic [63:0] lane_rcu_res_c08_s2_tid
  , input  logic [63:0] lane_rcu_res_c08_s3_tid
  , input  logic [63:0] lane_rcu_res_c09_s0_tid
  , input  logic [63:0] lane_rcu_res_c09_s1_tid
  , input  logic [63:0] lane_rcu_res_c09_s2_tid
  , input  logic [63:0] lane_rcu_res_c09_s3_tid
  , input  logic [63:0] lane_rcu_res_c10_s0_tid
  , input  logic [63:0] lane_rcu_res_c10_s1_tid
  , input  logic [63:0] lane_rcu_res_c10_s2_tid
  , input  logic [63:0] lane_rcu_res_c10_s3_tid
  , input  logic [63:0] lane_rcu_res_c11_s0_tid
  , input  logic [63:0] lane_rcu_res_c11_s1_tid
  , input  logic [63:0] lane_rcu_res_c11_s2_tid
  , input  logic [63:0] lane_rcu_res_c11_s3_tid
  , input  logic [63:0] lane_rcu_res_c12_s0_tid
  , input  logic [63:0] lane_rcu_res_c12_s1_tid
  , input  logic [63:0] lane_rcu_res_c12_s2_tid
  , input  logic [63:0] lane_rcu_res_c12_s3_tid
  , input  logic [63:0] lane_rcu_res_c13_s0_tid
  , input  logic [63:0] lane_rcu_res_c13_s1_tid
  , input  logic [63:0] lane_rcu_res_c13_s2_tid
  , input  logic [63:0] lane_rcu_res_c13_s3_tid
  , input  logic [63:0] lane_rcu_res_c14_s0_tid
  , input  logic [63:0] lane_rcu_res_c14_s1_tid
  , input  logic [63:0] lane_rcu_res_c14_s2_tid
  , input  logic [63:0] lane_rcu_res_c14_s3_tid
  , input  logic [63:0] lane_rcu_res_c15_s0_tid
  , input  logic [63:0] lane_rcu_res_c15_s1_tid
  , input  logic [63:0] lane_rcu_res_c15_s2_tid
  , input  logic [63:0] lane_rcu_res_c15_s3_tid
  , input  logic [63:0] lane_rcu_res_c16_s0_tid
  , input  logic [63:0] lane_rcu_res_c16_s1_tid
  , input  logic [63:0] lane_rcu_res_c16_s2_tid
  , input  logic [63:0] lane_rcu_res_c16_s3_tid
  , input  logic [63:0] lane_rcu_res_c17_s0_tid
  , input  logic [63:0] lane_rcu_res_c17_s1_tid
  , input  logic [63:0] lane_rcu_res_c17_s2_tid
  , input  logic [63:0] lane_rcu_res_c17_s3_tid
  , input  logic [63:0] lane_rcu_res_c18_s0_tid
  , input  logic [63:0] lane_rcu_res_c18_s1_tid
  , input  logic [63:0] lane_rcu_res_c18_s2_tid
  , input  logic [63:0] lane_rcu_res_c18_s3_tid
  , input  logic [63:0] lane_rcu_res_c19_s0_tid
  , input  logic [63:0] lane_rcu_res_c19_s1_tid
  , input  logic [63:0] lane_rcu_res_c19_s2_tid
  , input  logic [63:0] lane_rcu_res_c19_s3_tid
  , input  logic [63:0] lane_rcu_res_c20_s0_tid
  , input  logic [63:0] lane_rcu_res_c20_s1_tid
  , input  logic [63:0] lane_rcu_res_c20_s2_tid
  , input  logic [63:0] lane_rcu_res_c20_s3_tid
  , input  logic [63:0] lane_rcu_res_c21_s0_tid
  , input  logic [63:0] lane_rcu_res_c21_s1_tid
  , input  logic [63:0] lane_rcu_res_c21_s2_tid
  , input  logic [63:0] lane_rcu_res_c21_s3_tid
  , input  logic [63:0] lane_rcu_res_c22_s0_tid
  , input  logic [63:0] lane_rcu_res_c22_s1_tid
  , input  logic [63:0] lane_rcu_res_c22_s2_tid
  , input  logic [63:0] lane_rcu_res_c22_s3_tid
  , input  logic [63:0] lane_rcu_res_c23_s0_tid
  , input  logic [63:0] lane_rcu_res_c23_s1_tid
  , input  logic [63:0] lane_rcu_res_c23_s2_tid
  , input  logic [63:0] lane_rcu_res_c23_s3_tid
  , input  logic [63:0] lane_rcu_res_c24_s0_tid
  , input  logic [63:0] lane_rcu_res_c24_s1_tid
  , input  logic [63:0] lane_rcu_res_c24_s2_tid
  , input  logic [63:0] lane_rcu_res_c24_s3_tid
  , input  logic [63:0] lane_rcu_res_c25_s0_tid
  , input  logic [63:0] lane_rcu_res_c25_s1_tid
  , input  logic [63:0] lane_rcu_res_c25_s2_tid
  , input  logic [63:0] lane_rcu_res_c25_s3_tid
  , input  logic [63:0] lane_rcu_res_c26_s0_tid
  , input  logic [63:0] lane_rcu_res_c26_s1_tid
  , input  logic [63:0] lane_rcu_res_c26_s2_tid
  , input  logic [63:0] lane_rcu_res_c26_s3_tid
  , input  logic [63:0] lane_rcu_res_c27_s0_tid
  , input  logic [63:0] lane_rcu_res_c27_s1_tid
  , input  logic [63:0] lane_rcu_res_c27_s2_tid
  , input  logic [63:0] lane_rcu_res_c27_s3_tid
  , input  logic [63:0] lane_rcu_res_c28_s0_tid
  , input  logic [63:0] lane_rcu_res_c28_s1_tid
  , input  logic [63:0] lane_rcu_res_c28_s2_tid
  , input  logic [63:0] lane_rcu_res_c28_s3_tid
  , input  logic [63:0] lane_rcu_res_c29_s0_tid
  , input  logic [63:0] lane_rcu_res_c29_s1_tid
  , input  logic [63:0] lane_rcu_res_c29_s2_tid
  , input  logic [63:0] lane_rcu_res_c29_s3_tid
  , input  logic [63:0] lane_rcu_res_c30_s0_tid
  , input  logic [63:0] lane_rcu_res_c30_s1_tid
  , input  logic [63:0] lane_rcu_res_c30_s2_tid
  , input  logic [63:0] lane_rcu_res_c30_s3_tid
  , input  logic [63:0] lane_rcu_res_c31_s0_tid
  , input  logic [63:0] lane_rcu_res_c31_s1_tid
  , input  logic [63:0] lane_rcu_res_c31_s2_tid
  , input  logic [63:0] lane_rcu_res_c31_s3_tid
  , output logic [63:0] rcu_ooe_done_s0_tid
  , output logic [63:0] rcu_ooe_done_s1_tid
  , output logic [63:0] rcu_ooe_done_s2_tid
  , output logic [63:0] rcu_ooe_done_s3_tid
  , output logic [63:0] rcu_miu_addr_s0_tid
  , output logic [63:0] rcu_miu_addr_s1_tid
  , output logic [63:0] rcu_miu_addr_s2_tid
  , output logic [63:0] rcu_miu_addr_s3_tid
  , input  logic [63:0] miu_rcu_data_s0_tid
  , input  logic [63:0] miu_rcu_data_s1_tid
  , input  logic [63:0] miu_rcu_data_s2_tid
  , input  logic [63:0] miu_rcu_data_s3_tid
  , input  logic [63:0] rau_rcu_mig_tid
  , output logic [63:0] rcu_pca_mig_tid
  , input  logic [63:0] pca_rcu_mig_tid
`endif
