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
  input  logic [3:0] kill_warp_mask,
  output logic kill_ack,
  input  logic wake_req,
  output logic sleep_ok,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // ooe -> rcu, 4 slot(s) x 56 bit payload
  input  logic [3:0] ooe_rcu_issue_valid,
  input  logic [223:0] ooe_rcu_issue_payload,
  output logic [3:0] ooe_rcu_issue_credit,
  output logic [3:0] ooe_rcu_issue_stall,
  // rcu -> lane, 128 slot(s) x 110 bit payload
  output logic [127:0] rcu_lane_ops_valid,
  output logic [14079:0] rcu_lane_ops_payload,
  input  logic [127:0] rcu_lane_ops_credit,
  input  logic [127:0] rcu_lane_ops_stall,
  // lane -> rcu, 128 slot(s) x 33 bit payload
  input  logic [127:0] lane_rcu_res_valid,
  input  logic [4223:0] lane_rcu_res_payload,
  output logic [127:0] lane_rcu_res_credit,
  output logic [127:0] lane_rcu_res_stall,
  // rcu -> ooe, 4 slot(s) x 40 bit payload
  output logic [3:0] rcu_ooe_done_valid,
  output logic [159:0] rcu_ooe_done_payload,
  input  logic [3:0] rcu_ooe_done_credit,
  input  logic [3:0] rcu_ooe_done_stall,
  // rcu -> miu, 4 slot(s) x 2119 bit payload
  output logic [3:0] rcu_miu_addr_valid,
  output logic [8475:0] rcu_miu_addr_payload,
  input  logic [3:0] rcu_miu_addr_credit,
  input  logic [3:0] rcu_miu_addr_stall,
  // miu -> rcu, 4 slot(s) x 1039 bit payload
  input  logic [3:0] miu_rcu_data_valid,
  input  logic [4155:0] miu_rcu_data_payload,
  output logic [3:0] miu_rcu_data_credit,
  output logic [3:0] miu_rcu_data_stall,
  // rau -> rcu, 1 slot(s) x 9 bit payload
  input  logic rau_rcu_mig_valid,
  input  logic [8:0] rau_rcu_mig_payload,
  output logic rau_rcu_mig_credit,
  output logic rau_rcu_mig_stall,
  // rcu -> pca, 1 slot(s) x 2304 bit payload
  output logic rcu_pca_mig_valid,
  output logic [2303:0] rcu_pca_mig_payload,
  input  logic rcu_pca_mig_credit,
  input  logic rcu_pca_mig_stall,
  // pca -> rcu, 1 slot(s) x 2304 bit payload
  input  logic pca_rcu_mig_valid,
  input  logic [2303:0] pca_rcu_mig_payload,
  output logic pca_rcu_mig_credit,
  output logic pca_rcu_mig_stall
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
