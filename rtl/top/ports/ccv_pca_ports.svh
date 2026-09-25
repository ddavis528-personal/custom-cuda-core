// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_pca. Included between the parentheses of the
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
  // rcu -> pca, 1 slot(s) x 2304 bit payload
  input  logic rcu_pca_mig_valid,
  input  logic [2303:0] rcu_pca_mig_payload,
  output logic rcu_pca_mig_credit,
  output logic rcu_pca_mig_stall,
  // pca -> rcu, 1 slot(s) x 2304 bit payload
  output logic pca_rcu_mig_valid,
  output logic [2303:0] pca_rcu_mig_payload,
  input  logic pca_rcu_mig_credit,
  input  logic pca_rcu_mig_stall
`ifdef CCV_TRACE
  , input  logic [63:0] rcu_pca_mig_tid
  , output logic [63:0] pca_rcu_mig_tid
`endif
