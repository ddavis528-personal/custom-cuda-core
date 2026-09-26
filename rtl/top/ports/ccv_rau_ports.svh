// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_rau. Included between the parentheses of the
// module header, in the stub and in the real RTL alike.
//
// Channel ports are named by channel, not stage-tagged: stage
// numbers are assigned at 4a, and the tag belongs on the internal
// flop that drives the port. `_tid` is trace-only (CCV_TRACE).
  input  logic clk,
  input  logic clk_free,
  input  logic rst_n,
  output logic kill_valid,
  output logic [31:0] kill_warp_mask,
  output logic [1:0] kill_epoch,
  // kill_ack of fet, dec, ooe, rcu, miu, spm, syu, pca, in that order
  input  logic [7:0] kill_acks,
  // kill_ack_epoch of fet, dec, ooe, rcu, miu, spm, syu, pca, in that order
  input  logic [15:0] kill_ack_epochs,
  output logic sleep_ok,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // rau -> fet, 1 slot(s) x 184 bit payload
  output logic rau_fet_launch_valid,
  output logic [183:0] rau_fet_launch_payload,
  input  logic rau_fet_launch_credit,
  input  logic rau_fet_launch_stall,
  output logic rau_fet_launch_wake,
  // rau -> ooe, 1 slot(s) x 59 bit payload
  output logic rau_ooe_alloc_valid,
  output logic [58:0] rau_ooe_alloc_payload,
  input  logic rau_ooe_alloc_credit,
  input  logic rau_ooe_alloc_stall,
  output logic rau_ooe_alloc_wake,
  // ooe -> rau, 1 slot(s) x 16 bit payload
  input  logic ooe_rau_status_valid,
  input  logic [15:0] ooe_rau_status_payload,
  output logic ooe_rau_status_credit,
  output logic ooe_rau_status_stall,
  input  logic ooe_rau_status_wake,
  // rau -> ooe, 1 slot(s) x 6 bit payload
  output logic rau_ooe_demote_valid,
  output logic [5:0] rau_ooe_demote_payload,
  input  logic rau_ooe_demote_credit,
  input  logic rau_ooe_demote_stall,
  output logic rau_ooe_demote_wake,
  // ooe -> rau, 1 slot(s) x 70 bit payload
  input  logic ooe_rau_drained_valid,
  input  logic [69:0] ooe_rau_drained_payload,
  output logic ooe_rau_drained_credit,
  output logic ooe_rau_drained_stall,
  input  logic ooe_rau_drained_wake,
  // rau -> rcu, 1 slot(s) x 9 bit payload
  output logic rau_rcu_mig_valid,
  output logic [8:0] rau_rcu_mig_payload,
  input  logic rau_rcu_mig_credit,
  input  logic rau_rcu_mig_stall,
  output logic rau_rcu_mig_wake,
  // rau -> fet, 1 slot(s) x 9 bit payload
  output logic rau_fet_mig_valid,
  output logic [8:0] rau_fet_mig_payload,
  input  logic rau_fet_mig_credit,
  input  logic rau_fet_mig_stall,
  output logic rau_fet_mig_wake,
  // pca -> rau, 1 slot(s) x 5 bit payload
  input  logic pca_rau_mig_done_valid,
  input  logic [4:0] pca_rau_mig_done_payload,
  output logic pca_rau_mig_done_credit,
  output logic pca_rau_mig_done_stall,
  input  logic pca_rau_mig_done_wake,
  // rau -> miu, 1 slot(s) x 101 bit payload
  output logic rau_miu_cta_valid,
  output logic [100:0] rau_miu_cta_payload,
  input  logic rau_miu_cta_credit,
  input  logic rau_miu_cta_stall,
  output logic rau_miu_cta_wake,
  // rau -> syu, 1 slot(s) x 17 bit payload
  output logic rau_syu_alloc_valid,
  output logic [16:0] rau_syu_alloc_payload,
  input  logic rau_syu_alloc_credit,
  input  logic rau_syu_alloc_stall,
  output logic rau_syu_alloc_wake,
  // cru -> rau, 1 slot(s) x 74 bit payload
  input  logic cru_rau_cfg_valid,
  input  logic [73:0] cru_rau_cfg_payload,
  output logic cru_rau_cfg_credit,
  output logic cru_rau_cfg_stall,
  input  logic cru_rau_cfg_wake
`ifdef CCV_TRACE
  , output logic [63:0] rau_fet_launch_tid
  , output logic [63:0] rau_ooe_alloc_tid
  , input  logic [63:0] ooe_rau_status_tid
  , output logic [63:0] rau_ooe_demote_tid
  , input  logic [63:0] ooe_rau_drained_tid
  , output logic [63:0] rau_rcu_mig_tid
  , output logic [63:0] rau_fet_mig_tid
  , input  logic [63:0] pca_rau_mig_done_tid
  , output logic [63:0] rau_miu_cta_tid
  , output logic [63:0] rau_syu_alloc_tid
  , input  logic [63:0] cru_rau_cfg_tid
`endif
