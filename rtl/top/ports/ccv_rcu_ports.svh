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
  // ooe -> rcu, slot 0 of 9
  input  logic ooe_rcu_issue_s0_valid,
  input  ccv_ooe_rcu_issue_t ooe_rcu_issue_s0_payload,
  output logic ooe_rcu_issue_s0_credit,
  output logic ooe_rcu_issue_s0_stall,
  // ooe -> rcu, slot 1 of 9
  input  logic ooe_rcu_issue_s1_valid,
  input  ccv_ooe_rcu_issue_t ooe_rcu_issue_s1_payload,
  output logic ooe_rcu_issue_s1_credit,
  output logic ooe_rcu_issue_s1_stall,
  // ooe -> rcu, slot 2 of 9
  input  logic ooe_rcu_issue_s2_valid,
  input  ccv_ooe_rcu_issue_t ooe_rcu_issue_s2_payload,
  output logic ooe_rcu_issue_s2_credit,
  output logic ooe_rcu_issue_s2_stall,
  // ooe -> rcu, slot 3 of 9
  input  logic ooe_rcu_issue_s3_valid,
  input  ccv_ooe_rcu_issue_t ooe_rcu_issue_s3_payload,
  output logic ooe_rcu_issue_s3_credit,
  output logic ooe_rcu_issue_s3_stall,
  // ooe -> rcu, slot 4 of 9
  input  logic ooe_rcu_issue_s4_valid,
  input  ccv_ooe_rcu_issue_t ooe_rcu_issue_s4_payload,
  output logic ooe_rcu_issue_s4_credit,
  output logic ooe_rcu_issue_s4_stall,
  // ooe -> rcu, slot 5 of 9
  input  logic ooe_rcu_issue_s5_valid,
  input  ccv_ooe_rcu_issue_t ooe_rcu_issue_s5_payload,
  output logic ooe_rcu_issue_s5_credit,
  output logic ooe_rcu_issue_s5_stall,
  // ooe -> rcu, slot 6 of 9
  input  logic ooe_rcu_issue_s6_valid,
  input  ccv_ooe_rcu_issue_t ooe_rcu_issue_s6_payload,
  output logic ooe_rcu_issue_s6_credit,
  output logic ooe_rcu_issue_s6_stall,
  // ooe -> rcu, slot 7 of 9
  input  logic ooe_rcu_issue_s7_valid,
  input  ccv_ooe_rcu_issue_t ooe_rcu_issue_s7_payload,
  output logic ooe_rcu_issue_s7_credit,
  output logic ooe_rcu_issue_s7_stall,
  // ooe -> rcu, slot 8 of 9
  input  logic ooe_rcu_issue_s8_valid,
  input  ccv_ooe_rcu_issue_t ooe_rcu_issue_s8_payload,
  output logic ooe_rcu_issue_s8_credit,
  output logic ooe_rcu_issue_s8_stall,
  input  logic ooe_rcu_issue_wake,
  // rcu -> lane, copy 0
  output logic rcu_lane_ops_c00_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c00_payload,
  input  logic rcu_lane_ops_c00_credit,
  input  logic rcu_lane_ops_c00_stall,
  output logic rcu_lane_ops_c00_wake,
  // rcu -> lane, copy 1
  output logic rcu_lane_ops_c01_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c01_payload,
  input  logic rcu_lane_ops_c01_credit,
  input  logic rcu_lane_ops_c01_stall,
  output logic rcu_lane_ops_c01_wake,
  // rcu -> lane, copy 2
  output logic rcu_lane_ops_c02_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c02_payload,
  input  logic rcu_lane_ops_c02_credit,
  input  logic rcu_lane_ops_c02_stall,
  output logic rcu_lane_ops_c02_wake,
  // rcu -> lane, copy 3
  output logic rcu_lane_ops_c03_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c03_payload,
  input  logic rcu_lane_ops_c03_credit,
  input  logic rcu_lane_ops_c03_stall,
  output logic rcu_lane_ops_c03_wake,
  // rcu -> lane, copy 4
  output logic rcu_lane_ops_c04_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c04_payload,
  input  logic rcu_lane_ops_c04_credit,
  input  logic rcu_lane_ops_c04_stall,
  output logic rcu_lane_ops_c04_wake,
  // rcu -> lane, copy 5
  output logic rcu_lane_ops_c05_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c05_payload,
  input  logic rcu_lane_ops_c05_credit,
  input  logic rcu_lane_ops_c05_stall,
  output logic rcu_lane_ops_c05_wake,
  // rcu -> lane, copy 6
  output logic rcu_lane_ops_c06_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c06_payload,
  input  logic rcu_lane_ops_c06_credit,
  input  logic rcu_lane_ops_c06_stall,
  output logic rcu_lane_ops_c06_wake,
  // rcu -> lane, copy 7
  output logic rcu_lane_ops_c07_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c07_payload,
  input  logic rcu_lane_ops_c07_credit,
  input  logic rcu_lane_ops_c07_stall,
  output logic rcu_lane_ops_c07_wake,
  // rcu -> lane, copy 8
  output logic rcu_lane_ops_c08_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c08_payload,
  input  logic rcu_lane_ops_c08_credit,
  input  logic rcu_lane_ops_c08_stall,
  output logic rcu_lane_ops_c08_wake,
  // rcu -> lane, copy 9
  output logic rcu_lane_ops_c09_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c09_payload,
  input  logic rcu_lane_ops_c09_credit,
  input  logic rcu_lane_ops_c09_stall,
  output logic rcu_lane_ops_c09_wake,
  // rcu -> lane, copy 10
  output logic rcu_lane_ops_c10_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c10_payload,
  input  logic rcu_lane_ops_c10_credit,
  input  logic rcu_lane_ops_c10_stall,
  output logic rcu_lane_ops_c10_wake,
  // rcu -> lane, copy 11
  output logic rcu_lane_ops_c11_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c11_payload,
  input  logic rcu_lane_ops_c11_credit,
  input  logic rcu_lane_ops_c11_stall,
  output logic rcu_lane_ops_c11_wake,
  // rcu -> lane, copy 12
  output logic rcu_lane_ops_c12_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c12_payload,
  input  logic rcu_lane_ops_c12_credit,
  input  logic rcu_lane_ops_c12_stall,
  output logic rcu_lane_ops_c12_wake,
  // rcu -> lane, copy 13
  output logic rcu_lane_ops_c13_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c13_payload,
  input  logic rcu_lane_ops_c13_credit,
  input  logic rcu_lane_ops_c13_stall,
  output logic rcu_lane_ops_c13_wake,
  // rcu -> lane, copy 14
  output logic rcu_lane_ops_c14_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c14_payload,
  input  logic rcu_lane_ops_c14_credit,
  input  logic rcu_lane_ops_c14_stall,
  output logic rcu_lane_ops_c14_wake,
  // rcu -> lane, copy 15
  output logic rcu_lane_ops_c15_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c15_payload,
  input  logic rcu_lane_ops_c15_credit,
  input  logic rcu_lane_ops_c15_stall,
  output logic rcu_lane_ops_c15_wake,
  // rcu -> lane, copy 16
  output logic rcu_lane_ops_c16_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c16_payload,
  input  logic rcu_lane_ops_c16_credit,
  input  logic rcu_lane_ops_c16_stall,
  output logic rcu_lane_ops_c16_wake,
  // rcu -> lane, copy 17
  output logic rcu_lane_ops_c17_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c17_payload,
  input  logic rcu_lane_ops_c17_credit,
  input  logic rcu_lane_ops_c17_stall,
  output logic rcu_lane_ops_c17_wake,
  // rcu -> lane, copy 18
  output logic rcu_lane_ops_c18_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c18_payload,
  input  logic rcu_lane_ops_c18_credit,
  input  logic rcu_lane_ops_c18_stall,
  output logic rcu_lane_ops_c18_wake,
  // rcu -> lane, copy 19
  output logic rcu_lane_ops_c19_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c19_payload,
  input  logic rcu_lane_ops_c19_credit,
  input  logic rcu_lane_ops_c19_stall,
  output logic rcu_lane_ops_c19_wake,
  // rcu -> lane, copy 20
  output logic rcu_lane_ops_c20_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c20_payload,
  input  logic rcu_lane_ops_c20_credit,
  input  logic rcu_lane_ops_c20_stall,
  output logic rcu_lane_ops_c20_wake,
  // rcu -> lane, copy 21
  output logic rcu_lane_ops_c21_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c21_payload,
  input  logic rcu_lane_ops_c21_credit,
  input  logic rcu_lane_ops_c21_stall,
  output logic rcu_lane_ops_c21_wake,
  // rcu -> lane, copy 22
  output logic rcu_lane_ops_c22_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c22_payload,
  input  logic rcu_lane_ops_c22_credit,
  input  logic rcu_lane_ops_c22_stall,
  output logic rcu_lane_ops_c22_wake,
  // rcu -> lane, copy 23
  output logic rcu_lane_ops_c23_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c23_payload,
  input  logic rcu_lane_ops_c23_credit,
  input  logic rcu_lane_ops_c23_stall,
  output logic rcu_lane_ops_c23_wake,
  // rcu -> lane, copy 24
  output logic rcu_lane_ops_c24_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c24_payload,
  input  logic rcu_lane_ops_c24_credit,
  input  logic rcu_lane_ops_c24_stall,
  output logic rcu_lane_ops_c24_wake,
  // rcu -> lane, copy 25
  output logic rcu_lane_ops_c25_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c25_payload,
  input  logic rcu_lane_ops_c25_credit,
  input  logic rcu_lane_ops_c25_stall,
  output logic rcu_lane_ops_c25_wake,
  // rcu -> lane, copy 26
  output logic rcu_lane_ops_c26_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c26_payload,
  input  logic rcu_lane_ops_c26_credit,
  input  logic rcu_lane_ops_c26_stall,
  output logic rcu_lane_ops_c26_wake,
  // rcu -> lane, copy 27
  output logic rcu_lane_ops_c27_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c27_payload,
  input  logic rcu_lane_ops_c27_credit,
  input  logic rcu_lane_ops_c27_stall,
  output logic rcu_lane_ops_c27_wake,
  // rcu -> lane, copy 28
  output logic rcu_lane_ops_c28_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c28_payload,
  input  logic rcu_lane_ops_c28_credit,
  input  logic rcu_lane_ops_c28_stall,
  output logic rcu_lane_ops_c28_wake,
  // rcu -> lane, copy 29
  output logic rcu_lane_ops_c29_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c29_payload,
  input  logic rcu_lane_ops_c29_credit,
  input  logic rcu_lane_ops_c29_stall,
  output logic rcu_lane_ops_c29_wake,
  // rcu -> lane, copy 30
  output logic rcu_lane_ops_c30_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c30_payload,
  input  logic rcu_lane_ops_c30_credit,
  input  logic rcu_lane_ops_c30_stall,
  output logic rcu_lane_ops_c30_wake,
  // rcu -> lane, copy 31
  output logic rcu_lane_ops_c31_valid,
  output ccv_rcu_lane_ops_t rcu_lane_ops_c31_payload,
  input  logic rcu_lane_ops_c31_credit,
  input  logic rcu_lane_ops_c31_stall,
  output logic rcu_lane_ops_c31_wake,
  // lane -> rcu, copy 0
  input  logic lane_rcu_res_c00_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c00_payload,
  output logic lane_rcu_res_c00_credit,
  output logic lane_rcu_res_c00_stall,
  input  logic lane_rcu_res_c00_wake,
  // lane -> rcu, copy 1
  input  logic lane_rcu_res_c01_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c01_payload,
  output logic lane_rcu_res_c01_credit,
  output logic lane_rcu_res_c01_stall,
  input  logic lane_rcu_res_c01_wake,
  // lane -> rcu, copy 2
  input  logic lane_rcu_res_c02_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c02_payload,
  output logic lane_rcu_res_c02_credit,
  output logic lane_rcu_res_c02_stall,
  input  logic lane_rcu_res_c02_wake,
  // lane -> rcu, copy 3
  input  logic lane_rcu_res_c03_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c03_payload,
  output logic lane_rcu_res_c03_credit,
  output logic lane_rcu_res_c03_stall,
  input  logic lane_rcu_res_c03_wake,
  // lane -> rcu, copy 4
  input  logic lane_rcu_res_c04_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c04_payload,
  output logic lane_rcu_res_c04_credit,
  output logic lane_rcu_res_c04_stall,
  input  logic lane_rcu_res_c04_wake,
  // lane -> rcu, copy 5
  input  logic lane_rcu_res_c05_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c05_payload,
  output logic lane_rcu_res_c05_credit,
  output logic lane_rcu_res_c05_stall,
  input  logic lane_rcu_res_c05_wake,
  // lane -> rcu, copy 6
  input  logic lane_rcu_res_c06_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c06_payload,
  output logic lane_rcu_res_c06_credit,
  output logic lane_rcu_res_c06_stall,
  input  logic lane_rcu_res_c06_wake,
  // lane -> rcu, copy 7
  input  logic lane_rcu_res_c07_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c07_payload,
  output logic lane_rcu_res_c07_credit,
  output logic lane_rcu_res_c07_stall,
  input  logic lane_rcu_res_c07_wake,
  // lane -> rcu, copy 8
  input  logic lane_rcu_res_c08_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c08_payload,
  output logic lane_rcu_res_c08_credit,
  output logic lane_rcu_res_c08_stall,
  input  logic lane_rcu_res_c08_wake,
  // lane -> rcu, copy 9
  input  logic lane_rcu_res_c09_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c09_payload,
  output logic lane_rcu_res_c09_credit,
  output logic lane_rcu_res_c09_stall,
  input  logic lane_rcu_res_c09_wake,
  // lane -> rcu, copy 10
  input  logic lane_rcu_res_c10_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c10_payload,
  output logic lane_rcu_res_c10_credit,
  output logic lane_rcu_res_c10_stall,
  input  logic lane_rcu_res_c10_wake,
  // lane -> rcu, copy 11
  input  logic lane_rcu_res_c11_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c11_payload,
  output logic lane_rcu_res_c11_credit,
  output logic lane_rcu_res_c11_stall,
  input  logic lane_rcu_res_c11_wake,
  // lane -> rcu, copy 12
  input  logic lane_rcu_res_c12_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c12_payload,
  output logic lane_rcu_res_c12_credit,
  output logic lane_rcu_res_c12_stall,
  input  logic lane_rcu_res_c12_wake,
  // lane -> rcu, copy 13
  input  logic lane_rcu_res_c13_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c13_payload,
  output logic lane_rcu_res_c13_credit,
  output logic lane_rcu_res_c13_stall,
  input  logic lane_rcu_res_c13_wake,
  // lane -> rcu, copy 14
  input  logic lane_rcu_res_c14_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c14_payload,
  output logic lane_rcu_res_c14_credit,
  output logic lane_rcu_res_c14_stall,
  input  logic lane_rcu_res_c14_wake,
  // lane -> rcu, copy 15
  input  logic lane_rcu_res_c15_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c15_payload,
  output logic lane_rcu_res_c15_credit,
  output logic lane_rcu_res_c15_stall,
  input  logic lane_rcu_res_c15_wake,
  // lane -> rcu, copy 16
  input  logic lane_rcu_res_c16_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c16_payload,
  output logic lane_rcu_res_c16_credit,
  output logic lane_rcu_res_c16_stall,
  input  logic lane_rcu_res_c16_wake,
  // lane -> rcu, copy 17
  input  logic lane_rcu_res_c17_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c17_payload,
  output logic lane_rcu_res_c17_credit,
  output logic lane_rcu_res_c17_stall,
  input  logic lane_rcu_res_c17_wake,
  // lane -> rcu, copy 18
  input  logic lane_rcu_res_c18_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c18_payload,
  output logic lane_rcu_res_c18_credit,
  output logic lane_rcu_res_c18_stall,
  input  logic lane_rcu_res_c18_wake,
  // lane -> rcu, copy 19
  input  logic lane_rcu_res_c19_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c19_payload,
  output logic lane_rcu_res_c19_credit,
  output logic lane_rcu_res_c19_stall,
  input  logic lane_rcu_res_c19_wake,
  // lane -> rcu, copy 20
  input  logic lane_rcu_res_c20_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c20_payload,
  output logic lane_rcu_res_c20_credit,
  output logic lane_rcu_res_c20_stall,
  input  logic lane_rcu_res_c20_wake,
  // lane -> rcu, copy 21
  input  logic lane_rcu_res_c21_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c21_payload,
  output logic lane_rcu_res_c21_credit,
  output logic lane_rcu_res_c21_stall,
  input  logic lane_rcu_res_c21_wake,
  // lane -> rcu, copy 22
  input  logic lane_rcu_res_c22_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c22_payload,
  output logic lane_rcu_res_c22_credit,
  output logic lane_rcu_res_c22_stall,
  input  logic lane_rcu_res_c22_wake,
  // lane -> rcu, copy 23
  input  logic lane_rcu_res_c23_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c23_payload,
  output logic lane_rcu_res_c23_credit,
  output logic lane_rcu_res_c23_stall,
  input  logic lane_rcu_res_c23_wake,
  // lane -> rcu, copy 24
  input  logic lane_rcu_res_c24_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c24_payload,
  output logic lane_rcu_res_c24_credit,
  output logic lane_rcu_res_c24_stall,
  input  logic lane_rcu_res_c24_wake,
  // lane -> rcu, copy 25
  input  logic lane_rcu_res_c25_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c25_payload,
  output logic lane_rcu_res_c25_credit,
  output logic lane_rcu_res_c25_stall,
  input  logic lane_rcu_res_c25_wake,
  // lane -> rcu, copy 26
  input  logic lane_rcu_res_c26_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c26_payload,
  output logic lane_rcu_res_c26_credit,
  output logic lane_rcu_res_c26_stall,
  input  logic lane_rcu_res_c26_wake,
  // lane -> rcu, copy 27
  input  logic lane_rcu_res_c27_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c27_payload,
  output logic lane_rcu_res_c27_credit,
  output logic lane_rcu_res_c27_stall,
  input  logic lane_rcu_res_c27_wake,
  // lane -> rcu, copy 28
  input  logic lane_rcu_res_c28_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c28_payload,
  output logic lane_rcu_res_c28_credit,
  output logic lane_rcu_res_c28_stall,
  input  logic lane_rcu_res_c28_wake,
  // lane -> rcu, copy 29
  input  logic lane_rcu_res_c29_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c29_payload,
  output logic lane_rcu_res_c29_credit,
  output logic lane_rcu_res_c29_stall,
  input  logic lane_rcu_res_c29_wake,
  // lane -> rcu, copy 30
  input  logic lane_rcu_res_c30_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c30_payload,
  output logic lane_rcu_res_c30_credit,
  output logic lane_rcu_res_c30_stall,
  input  logic lane_rcu_res_c30_wake,
  // lane -> rcu, copy 31
  input  logic lane_rcu_res_c31_valid,
  input  ccv_lane_rcu_res_t lane_rcu_res_c31_payload,
  output logic lane_rcu_res_c31_credit,
  output logic lane_rcu_res_c31_stall,
  input  logic lane_rcu_res_c31_wake,
  // rcu -> ooe, slot 0 of 7
  output logic rcu_ooe_done_s0_valid,
  output ccv_rcu_ooe_done_t rcu_ooe_done_s0_payload,
  input  logic rcu_ooe_done_s0_credit,
  input  logic rcu_ooe_done_s0_stall,
  // rcu -> ooe, slot 1 of 7
  output logic rcu_ooe_done_s1_valid,
  output ccv_rcu_ooe_done_t rcu_ooe_done_s1_payload,
  input  logic rcu_ooe_done_s1_credit,
  input  logic rcu_ooe_done_s1_stall,
  // rcu -> ooe, slot 2 of 7
  output logic rcu_ooe_done_s2_valid,
  output ccv_rcu_ooe_done_t rcu_ooe_done_s2_payload,
  input  logic rcu_ooe_done_s2_credit,
  input  logic rcu_ooe_done_s2_stall,
  // rcu -> ooe, slot 3 of 7
  output logic rcu_ooe_done_s3_valid,
  output ccv_rcu_ooe_done_t rcu_ooe_done_s3_payload,
  input  logic rcu_ooe_done_s3_credit,
  input  logic rcu_ooe_done_s3_stall,
  // rcu -> ooe, slot 4 of 7
  output logic rcu_ooe_done_s4_valid,
  output ccv_rcu_ooe_done_t rcu_ooe_done_s4_payload,
  input  logic rcu_ooe_done_s4_credit,
  input  logic rcu_ooe_done_s4_stall,
  // rcu -> ooe, slot 5 of 7
  output logic rcu_ooe_done_s5_valid,
  output ccv_rcu_ooe_done_t rcu_ooe_done_s5_payload,
  input  logic rcu_ooe_done_s5_credit,
  input  logic rcu_ooe_done_s5_stall,
  // rcu -> ooe, slot 6 of 7
  output logic rcu_ooe_done_s6_valid,
  output ccv_rcu_ooe_done_t rcu_ooe_done_s6_payload,
  input  logic rcu_ooe_done_s6_credit,
  input  logic rcu_ooe_done_s6_stall,
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
  // ooe -> rcu
  input  logic ooe_rcu_map_valid,
  input  ccv_ooe_rcu_map_t ooe_rcu_map_payload,
  output logic ooe_rcu_map_credit,
  output logic ooe_rcu_map_stall,
  input  logic ooe_rcu_map_wake,
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
  , input  logic [63:0] ooe_rcu_issue_s4_tid
  , input  logic [63:0] ooe_rcu_issue_s5_tid
  , input  logic [63:0] ooe_rcu_issue_s6_tid
  , input  logic [63:0] ooe_rcu_issue_s7_tid
  , input  logic [63:0] ooe_rcu_issue_s8_tid
  , output logic [63:0] rcu_lane_ops_c00_tid
  , output logic [63:0] rcu_lane_ops_c01_tid
  , output logic [63:0] rcu_lane_ops_c02_tid
  , output logic [63:0] rcu_lane_ops_c03_tid
  , output logic [63:0] rcu_lane_ops_c04_tid
  , output logic [63:0] rcu_lane_ops_c05_tid
  , output logic [63:0] rcu_lane_ops_c06_tid
  , output logic [63:0] rcu_lane_ops_c07_tid
  , output logic [63:0] rcu_lane_ops_c08_tid
  , output logic [63:0] rcu_lane_ops_c09_tid
  , output logic [63:0] rcu_lane_ops_c10_tid
  , output logic [63:0] rcu_lane_ops_c11_tid
  , output logic [63:0] rcu_lane_ops_c12_tid
  , output logic [63:0] rcu_lane_ops_c13_tid
  , output logic [63:0] rcu_lane_ops_c14_tid
  , output logic [63:0] rcu_lane_ops_c15_tid
  , output logic [63:0] rcu_lane_ops_c16_tid
  , output logic [63:0] rcu_lane_ops_c17_tid
  , output logic [63:0] rcu_lane_ops_c18_tid
  , output logic [63:0] rcu_lane_ops_c19_tid
  , output logic [63:0] rcu_lane_ops_c20_tid
  , output logic [63:0] rcu_lane_ops_c21_tid
  , output logic [63:0] rcu_lane_ops_c22_tid
  , output logic [63:0] rcu_lane_ops_c23_tid
  , output logic [63:0] rcu_lane_ops_c24_tid
  , output logic [63:0] rcu_lane_ops_c25_tid
  , output logic [63:0] rcu_lane_ops_c26_tid
  , output logic [63:0] rcu_lane_ops_c27_tid
  , output logic [63:0] rcu_lane_ops_c28_tid
  , output logic [63:0] rcu_lane_ops_c29_tid
  , output logic [63:0] rcu_lane_ops_c30_tid
  , output logic [63:0] rcu_lane_ops_c31_tid
  , input  logic [63:0] lane_rcu_res_c00_tid
  , input  logic [63:0] lane_rcu_res_c01_tid
  , input  logic [63:0] lane_rcu_res_c02_tid
  , input  logic [63:0] lane_rcu_res_c03_tid
  , input  logic [63:0] lane_rcu_res_c04_tid
  , input  logic [63:0] lane_rcu_res_c05_tid
  , input  logic [63:0] lane_rcu_res_c06_tid
  , input  logic [63:0] lane_rcu_res_c07_tid
  , input  logic [63:0] lane_rcu_res_c08_tid
  , input  logic [63:0] lane_rcu_res_c09_tid
  , input  logic [63:0] lane_rcu_res_c10_tid
  , input  logic [63:0] lane_rcu_res_c11_tid
  , input  logic [63:0] lane_rcu_res_c12_tid
  , input  logic [63:0] lane_rcu_res_c13_tid
  , input  logic [63:0] lane_rcu_res_c14_tid
  , input  logic [63:0] lane_rcu_res_c15_tid
  , input  logic [63:0] lane_rcu_res_c16_tid
  , input  logic [63:0] lane_rcu_res_c17_tid
  , input  logic [63:0] lane_rcu_res_c18_tid
  , input  logic [63:0] lane_rcu_res_c19_tid
  , input  logic [63:0] lane_rcu_res_c20_tid
  , input  logic [63:0] lane_rcu_res_c21_tid
  , input  logic [63:0] lane_rcu_res_c22_tid
  , input  logic [63:0] lane_rcu_res_c23_tid
  , input  logic [63:0] lane_rcu_res_c24_tid
  , input  logic [63:0] lane_rcu_res_c25_tid
  , input  logic [63:0] lane_rcu_res_c26_tid
  , input  logic [63:0] lane_rcu_res_c27_tid
  , input  logic [63:0] lane_rcu_res_c28_tid
  , input  logic [63:0] lane_rcu_res_c29_tid
  , input  logic [63:0] lane_rcu_res_c30_tid
  , input  logic [63:0] lane_rcu_res_c31_tid
  , output logic [63:0] rcu_ooe_done_s0_tid
  , output logic [63:0] rcu_ooe_done_s1_tid
  , output logic [63:0] rcu_ooe_done_s2_tid
  , output logic [63:0] rcu_ooe_done_s3_tid
  , output logic [63:0] rcu_ooe_done_s4_tid
  , output logic [63:0] rcu_ooe_done_s5_tid
  , output logic [63:0] rcu_ooe_done_s6_tid
  , output logic [63:0] rcu_miu_addr_s0_tid
  , output logic [63:0] rcu_miu_addr_s1_tid
  , output logic [63:0] rcu_miu_addr_s2_tid
  , output logic [63:0] rcu_miu_addr_s3_tid
  , input  logic [63:0] miu_rcu_data_s0_tid
  , input  logic [63:0] miu_rcu_data_s1_tid
  , input  logic [63:0] miu_rcu_data_s2_tid
  , input  logic [63:0] miu_rcu_data_s3_tid
  , input  logic [63:0] rau_rcu_mig_tid
  , input  logic [63:0] ooe_rcu_map_tid
  , output logic [63:0] rcu_pca_mig_tid
  , input  logic [63:0] pca_rcu_mig_tid
`endif
