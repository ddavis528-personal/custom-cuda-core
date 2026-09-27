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
  output logic kill_valid,
  output logic [31:0] kill_warp_mask,
  output logic [1:0] kill_epoch,
  // kill_ack of fet, dec, ooe, rcu, miu, spm, syu, pca, in that order
  input  logic [7:0] kill_acks,
  // kill_ack_epoch of fet, dec, ooe, rcu, miu, spm, syu, pca, in that order
  input  logic [15:0] kill_ack_epochs,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // rau -> fet
  output logic rau_fet_launch_valid,
  output ccv_rau_fet_launch_t rau_fet_launch_payload,
  input  logic rau_fet_launch_credit,
  input  logic rau_fet_launch_stall,
  output logic rau_fet_launch_wake,
  // rau -> ooe
  output logic rau_ooe_alloc_valid,
  output ccv_rau_ooe_alloc_t rau_ooe_alloc_payload,
  input  logic rau_ooe_alloc_credit,
  input  logic rau_ooe_alloc_stall,
  output logic rau_ooe_alloc_wake,
  // ooe -> rau
  input  logic ooe_rau_status_valid,
  input  ccv_ooe_rau_status_t ooe_rau_status_payload,
  output logic ooe_rau_status_credit,
  output logic ooe_rau_status_stall,
  input  logic ooe_rau_status_wake,
  // rau -> ooe
  output logic rau_ooe_demote_valid,
  output ccv_rau_ooe_demote_t rau_ooe_demote_payload,
  input  logic rau_ooe_demote_credit,
  input  logic rau_ooe_demote_stall,
  output logic rau_ooe_demote_wake,
  // ooe -> rau
  input  logic ooe_rau_drained_valid,
  input  ccv_ooe_rau_drained_t ooe_rau_drained_payload,
  output logic ooe_rau_drained_credit,
  output logic ooe_rau_drained_stall,
  input  logic ooe_rau_drained_wake,
  // rau -> rcu
  output logic rau_rcu_mig_valid,
  output ccv_rau_rcu_mig_t rau_rcu_mig_payload,
  input  logic rau_rcu_mig_credit,
  input  logic rau_rcu_mig_stall,
  output logic rau_rcu_mig_wake,
  // rau -> fet
  output logic rau_fet_mig_valid,
  output ccv_rau_fet_mig_t rau_fet_mig_payload,
  input  logic rau_fet_mig_credit,
  input  logic rau_fet_mig_stall,
  output logic rau_fet_mig_wake,
  // pca -> rau
  input  logic pca_rau_mig_done_valid,
  input  ccv_pca_rau_mig_done_t pca_rau_mig_done_payload,
  output logic pca_rau_mig_done_credit,
  output logic pca_rau_mig_done_stall,
  input  logic pca_rau_mig_done_wake,
  // rau -> miu
  output logic rau_miu_cta_valid,
  output ccv_rau_miu_cta_t rau_miu_cta_payload,
  input  logic rau_miu_cta_credit,
  input  logic rau_miu_cta_stall,
  output logic rau_miu_cta_wake,
  // rau -> syu
  output logic rau_syu_alloc_valid,
  output ccv_rau_syu_alloc_t rau_syu_alloc_payload,
  input  logic rau_syu_alloc_credit,
  input  logic rau_syu_alloc_stall,
  output logic rau_syu_alloc_wake,
  // cru -> rau
  input  logic cru_rau_cfg_valid,
  input  ccv_cru_rau_cfg_t cru_rau_cfg_payload,
  output logic cru_rau_cfg_credit,
  output logic cru_rau_cfg_stall,
  input  logic cru_rau_cfg_wake
`ifdef CCV_CHECK
  , output logic clk_gated
`endif
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
