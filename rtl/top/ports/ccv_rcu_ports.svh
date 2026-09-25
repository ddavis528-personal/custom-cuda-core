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
// flop that drives the port. `_tid` is trace-only (CCV_TRACE).
  input  logic clk,
  input  logic clk_free,
  input  logic rst_n,
  input  logic kill_valid,
  input  logic [31:0] kill_warp_mask,
  input  logic [1:0] kill_epoch,
  output logic kill_ack,
  output logic [1:0] kill_ack_epoch,
  output logic sleep_ok,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // ooe -> rcu, 4 slot(s) x 129 bit payload
  input  logic [3:0] ooe_rcu_issue_valid,
  input  logic [515:0] ooe_rcu_issue_payload,
  output logic [3:0] ooe_rcu_issue_credit,
  output logic [3:0] ooe_rcu_issue_stall,
  input  logic ooe_rcu_issue_wake,
  // rcu -> lane, 128 slot(s) x 110 bit payload
  output logic [127:0] rcu_lane_ops_valid,
  output logic [14079:0] rcu_lane_ops_payload,
  input  logic [127:0] rcu_lane_ops_credit,
  input  logic [127:0] rcu_lane_ops_stall,
  output logic [31:0] rcu_lane_ops_wake,
  // lane -> rcu, 128 slot(s) x 33 bit payload
  input  logic [127:0] lane_rcu_res_valid,
  input  logic [4223:0] lane_rcu_res_payload,
  output logic [127:0] lane_rcu_res_credit,
  output logic [127:0] lane_rcu_res_stall,
  input  logic [31:0] lane_rcu_res_wake,
  // rcu -> ooe, 4 slot(s) x 73 bit payload
  output logic [3:0] rcu_ooe_done_valid,
  output logic [291:0] rcu_ooe_done_payload,
  input  logic [3:0] rcu_ooe_done_credit,
  input  logic [3:0] rcu_ooe_done_stall,
  output logic rcu_ooe_done_wake,
  // rcu -> miu, 4 slot(s) x 2151 bit payload
  output logic [3:0] rcu_miu_addr_valid,
  output logic [8603:0] rcu_miu_addr_payload,
  input  logic [3:0] rcu_miu_addr_credit,
  input  logic [3:0] rcu_miu_addr_stall,
  output logic rcu_miu_addr_wake,
  // miu -> rcu, 4 slot(s) x 1071 bit payload
  input  logic [3:0] miu_rcu_data_valid,
  input  logic [4283:0] miu_rcu_data_payload,
  output logic [3:0] miu_rcu_data_credit,
  output logic [3:0] miu_rcu_data_stall,
  input  logic miu_rcu_data_wake,
  // rau -> rcu, 1 slot(s) x 9 bit payload
  input  logic rau_rcu_mig_valid,
  input  logic [8:0] rau_rcu_mig_payload,
  output logic rau_rcu_mig_credit,
  output logic rau_rcu_mig_stall,
  input  logic rau_rcu_mig_wake,
  // rcu -> pca, 1 slot(s) x 2304 bit payload
  output logic rcu_pca_mig_valid,
  output logic [2303:0] rcu_pca_mig_payload,
  input  logic rcu_pca_mig_credit,
  input  logic rcu_pca_mig_stall,
  output logic rcu_pca_mig_wake,
  // pca -> rcu, 1 slot(s) x 2304 bit payload
  input  logic pca_rcu_mig_valid,
  input  logic [2303:0] pca_rcu_mig_payload,
  output logic pca_rcu_mig_credit,
  output logic pca_rcu_mig_stall,
  input  logic pca_rcu_mig_wake
`ifdef CCV_TRACE
  , input  logic [255:0] ooe_rcu_issue_tid
  , output logic [8191:0] rcu_lane_ops_tid
  , input  logic [8191:0] lane_rcu_res_tid
  , output logic [255:0] rcu_ooe_done_tid
  , output logic [255:0] rcu_miu_addr_tid
  , input  logic [255:0] miu_rcu_data_tid
  , input  logic [63:0] rau_rcu_mig_tid
  , output logic [63:0] rcu_pca_mig_tid
  , input  logic [63:0] pca_rcu_mig_tid
`endif
