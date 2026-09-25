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
// flop that drives the port. `_tid` is trace-only (CCV_TRACE).
  input  logic clk,
  input  logic clk_free,
  input  logic rst_n,
  input  logic kill_valid,
  input  logic [3:0] kill_warp_mask,
  output logic kill_ack,
  output logic sleep_ok,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // rcu -> lane, 4 slot(s) x 110 bit payload
  input  logic [3:0] rcu_lane_ops_valid,
  input  logic [439:0] rcu_lane_ops_payload,
  output logic [3:0] rcu_lane_ops_credit,
  output logic [3:0] rcu_lane_ops_stall,
  input  logic rcu_lane_ops_wake,
  // lane -> rcu, 4 slot(s) x 33 bit payload
  output logic [3:0] lane_rcu_res_valid,
  output logic [131:0] lane_rcu_res_payload,
  input  logic [3:0] lane_rcu_res_credit,
  input  logic [3:0] lane_rcu_res_stall,
  output logic lane_rcu_res_wake
`ifdef CCV_TRACE
  , input  logic [255:0] rcu_lane_ops_tid
  , output logic [255:0] lane_rcu_res_tid
`endif
