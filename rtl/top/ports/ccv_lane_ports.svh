// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_lane. Included between the parentheses of the
// module header, in the stub and in the real RTL alike.
//
// Channel ports are named by channel, not stage-tagged: stage
// numbers are assigned at 4a, and the tag belongs on the internal
// flop that drives the port. One group per slot:
//   <chan>[_c<NN>][_s<K>]_{valid,payload,credit,stall}, and
//   <chan>[_c<NN>]_wake per channel instance; `_c` only where a
// block names one of several copies, `_s` only at rate > 1.
// `_payload` is typed ccv_<chan>_t. `_tid` is trace-only (CCV_TRACE).
  input  logic clk,
  input  logic clk_free,
  input  logic rst_n,
  output logic sleep_ok,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // rcu -> lane, slot 0 of 4
  input  logic rcu_lane_ops_s0_valid,
  input  ccv_rcu_lane_ops_t rcu_lane_ops_s0_payload,
  output logic rcu_lane_ops_s0_credit,
  output logic rcu_lane_ops_s0_stall,
  // rcu -> lane, slot 1 of 4
  input  logic rcu_lane_ops_s1_valid,
  input  ccv_rcu_lane_ops_t rcu_lane_ops_s1_payload,
  output logic rcu_lane_ops_s1_credit,
  output logic rcu_lane_ops_s1_stall,
  // rcu -> lane, slot 2 of 4
  input  logic rcu_lane_ops_s2_valid,
  input  ccv_rcu_lane_ops_t rcu_lane_ops_s2_payload,
  output logic rcu_lane_ops_s2_credit,
  output logic rcu_lane_ops_s2_stall,
  // rcu -> lane, slot 3 of 4
  input  logic rcu_lane_ops_s3_valid,
  input  ccv_rcu_lane_ops_t rcu_lane_ops_s3_payload,
  output logic rcu_lane_ops_s3_credit,
  output logic rcu_lane_ops_s3_stall,
  input  logic rcu_lane_ops_wake,
  // lane -> rcu, slot 0 of 4
  output logic lane_rcu_res_s0_valid,
  output ccv_lane_rcu_res_t lane_rcu_res_s0_payload,
  input  logic lane_rcu_res_s0_credit,
  input  logic lane_rcu_res_s0_stall,
  // lane -> rcu, slot 1 of 4
  output logic lane_rcu_res_s1_valid,
  output ccv_lane_rcu_res_t lane_rcu_res_s1_payload,
  input  logic lane_rcu_res_s1_credit,
  input  logic lane_rcu_res_s1_stall,
  // lane -> rcu, slot 2 of 4
  output logic lane_rcu_res_s2_valid,
  output ccv_lane_rcu_res_t lane_rcu_res_s2_payload,
  input  logic lane_rcu_res_s2_credit,
  input  logic lane_rcu_res_s2_stall,
  // lane -> rcu, slot 3 of 4
  output logic lane_rcu_res_s3_valid,
  output ccv_lane_rcu_res_t lane_rcu_res_s3_payload,
  input  logic lane_rcu_res_s3_credit,
  input  logic lane_rcu_res_s3_stall,
  output logic lane_rcu_res_wake
`ifdef CCV_TRACE
  , input  logic [63:0] rcu_lane_ops_s0_tid
  , input  logic [63:0] rcu_lane_ops_s1_tid
  , input  logic [63:0] rcu_lane_ops_s2_tid
  , input  logic [63:0] rcu_lane_ops_s3_tid
  , output logic [63:0] lane_rcu_res_s0_tid
  , output logic [63:0] lane_rcu_res_s1_tid
  , output logic [63:0] lane_rcu_res_s2_tid
  , output logic [63:0] lane_rcu_res_s3_tid
`endif
