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
// `_payload` is typed ccv_<chan>_t. `_tid` is trace-only (CCV_TRACE);
// `clk_gated` is an observation for the checker bank (CCV_CHECK).
//
// One clock, core_clk, UNGATED: the block gates it as its first act,
// inside the block. The top holds only block instances and nets.
  input  logic core_clk,
  input  logic rst_n,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // rcu -> lane
  input  logic rcu_lane_ops_valid,
  input  ccv_rcu_lane_ops_t rcu_lane_ops_payload,
  output logic rcu_lane_ops_credit,
  output logic rcu_lane_ops_stall,
  input  logic rcu_lane_ops_wake,
  // lane -> rcu
  output logic lane_rcu_res_valid,
  output ccv_lane_rcu_res_t lane_rcu_res_payload,
  input  logic lane_rcu_res_credit,
  input  logic lane_rcu_res_stall,
  output logic lane_rcu_res_wake
`ifdef CCV_CHECK
  , output logic clk_gated
`endif
`ifdef CCV_TRACE
  , input  logic [63:0] rcu_lane_ops_tid
  , output logic [63:0] lane_rcu_res_tid
`endif
