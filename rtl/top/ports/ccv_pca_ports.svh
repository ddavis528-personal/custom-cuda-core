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
// flop that drives the port. One group per slot:
//   <chan>[_c<NN>][_s<K>]_{valid,payload,credit,stall}, and
//   <chan>[_c<NN>]_wake per channel instance; `_c` only where a
// block names one of several copies, `_s` only at rate > 1.
// `_payload` is typed ccv_<chan>_t. `_tid` is trace-only (CCV_TRACE).
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
  // rcu -> pca
  input  logic rcu_pca_mig_valid,
  input  ccv_rcu_pca_mig_t rcu_pca_mig_payload,
  output logic rcu_pca_mig_credit,
  output logic rcu_pca_mig_stall,
  input  logic rcu_pca_mig_wake,
  // pca -> rcu
  output logic pca_rcu_mig_valid,
  output ccv_pca_rcu_mig_t pca_rcu_mig_payload,
  input  logic pca_rcu_mig_credit,
  input  logic pca_rcu_mig_stall,
  output logic pca_rcu_mig_wake,
  // fet -> pca
  input  logic fet_pca_mig_valid,
  input  ccv_fet_pca_mig_t fet_pca_mig_payload,
  output logic fet_pca_mig_credit,
  output logic fet_pca_mig_stall,
  input  logic fet_pca_mig_wake,
  // pca -> fet
  output logic pca_fet_mig_valid,
  output ccv_pca_fet_mig_t pca_fet_mig_payload,
  input  logic pca_fet_mig_credit,
  input  logic pca_fet_mig_stall,
  output logic pca_fet_mig_wake,
  // pca -> rau
  output logic pca_rau_mig_done_valid,
  output ccv_pca_rau_mig_done_t pca_rau_mig_done_payload,
  input  logic pca_rau_mig_done_credit,
  input  logic pca_rau_mig_done_stall,
  output logic pca_rau_mig_done_wake
`ifdef CCV_TRACE
  , input  logic [63:0] rcu_pca_mig_tid
  , output logic [63:0] pca_rcu_mig_tid
  , input  logic [63:0] fet_pca_mig_tid
  , output logic [63:0] pca_fet_mig_tid
  , output logic [63:0] pca_rau_mig_done_tid
`endif
