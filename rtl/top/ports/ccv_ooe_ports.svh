// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_ooe. Included between the parentheses of the
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
  // dec -> ooe, slot 0 of 6
  input  logic dec_ooe_uop_s0_valid,
  input  ccv_dec_ooe_uop_t dec_ooe_uop_s0_payload,
  output logic dec_ooe_uop_s0_credit,
  output logic dec_ooe_uop_s0_stall,
  // dec -> ooe, slot 1 of 6
  input  logic dec_ooe_uop_s1_valid,
  input  ccv_dec_ooe_uop_t dec_ooe_uop_s1_payload,
  output logic dec_ooe_uop_s1_credit,
  output logic dec_ooe_uop_s1_stall,
  // dec -> ooe, slot 2 of 6
  input  logic dec_ooe_uop_s2_valid,
  input  ccv_dec_ooe_uop_t dec_ooe_uop_s2_payload,
  output logic dec_ooe_uop_s2_credit,
  output logic dec_ooe_uop_s2_stall,
  // dec -> ooe, slot 3 of 6
  input  logic dec_ooe_uop_s3_valid,
  input  ccv_dec_ooe_uop_t dec_ooe_uop_s3_payload,
  output logic dec_ooe_uop_s3_credit,
  output logic dec_ooe_uop_s3_stall,
  // dec -> ooe, slot 4 of 6
  input  logic dec_ooe_uop_s4_valid,
  input  ccv_dec_ooe_uop_t dec_ooe_uop_s4_payload,
  output logic dec_ooe_uop_s4_credit,
  output logic dec_ooe_uop_s4_stall,
  // dec -> ooe, slot 5 of 6
  input  logic dec_ooe_uop_s5_valid,
  input  ccv_dec_ooe_uop_t dec_ooe_uop_s5_payload,
  output logic dec_ooe_uop_s5_credit,
  output logic dec_ooe_uop_s5_stall,
  input  logic dec_ooe_uop_wake,
  // ooe -> rcu, slot 0 of 4
  output logic ooe_rcu_issue_s0_valid,
  output ccv_ooe_rcu_issue_t ooe_rcu_issue_s0_payload,
  input  logic ooe_rcu_issue_s0_credit,
  input  logic ooe_rcu_issue_s0_stall,
  // ooe -> rcu, slot 1 of 4
  output logic ooe_rcu_issue_s1_valid,
  output ccv_ooe_rcu_issue_t ooe_rcu_issue_s1_payload,
  input  logic ooe_rcu_issue_s1_credit,
  input  logic ooe_rcu_issue_s1_stall,
  // ooe -> rcu, slot 2 of 4
  output logic ooe_rcu_issue_s2_valid,
  output ccv_ooe_rcu_issue_t ooe_rcu_issue_s2_payload,
  input  logic ooe_rcu_issue_s2_credit,
  input  logic ooe_rcu_issue_s2_stall,
  // ooe -> rcu, slot 3 of 4
  output logic ooe_rcu_issue_s3_valid,
  output ccv_ooe_rcu_issue_t ooe_rcu_issue_s3_payload,
  input  logic ooe_rcu_issue_s3_credit,
  input  logic ooe_rcu_issue_s3_stall,
  output logic ooe_rcu_issue_wake,
  // rcu -> ooe, slot 0 of 4
  input  logic rcu_ooe_done_s0_valid,
  input  ccv_rcu_ooe_done_t rcu_ooe_done_s0_payload,
  output logic rcu_ooe_done_s0_credit,
  output logic rcu_ooe_done_s0_stall,
  // rcu -> ooe, slot 1 of 4
  input  logic rcu_ooe_done_s1_valid,
  input  ccv_rcu_ooe_done_t rcu_ooe_done_s1_payload,
  output logic rcu_ooe_done_s1_credit,
  output logic rcu_ooe_done_s1_stall,
  // rcu -> ooe, slot 2 of 4
  input  logic rcu_ooe_done_s2_valid,
  input  ccv_rcu_ooe_done_t rcu_ooe_done_s2_payload,
  output logic rcu_ooe_done_s2_credit,
  output logic rcu_ooe_done_s2_stall,
  // rcu -> ooe, slot 3 of 4
  input  logic rcu_ooe_done_s3_valid,
  input  ccv_rcu_ooe_done_t rcu_ooe_done_s3_payload,
  output logic rcu_ooe_done_s3_credit,
  output logic rcu_ooe_done_s3_stall,
  input  logic rcu_ooe_done_wake,
  // ooe -> miu, slot 0 of 4
  output logic ooe_miu_memop_s0_valid,
  output ccv_ooe_miu_memop_t ooe_miu_memop_s0_payload,
  input  logic ooe_miu_memop_s0_credit,
  input  logic ooe_miu_memop_s0_stall,
  // ooe -> miu, slot 1 of 4
  output logic ooe_miu_memop_s1_valid,
  output ccv_ooe_miu_memop_t ooe_miu_memop_s1_payload,
  input  logic ooe_miu_memop_s1_credit,
  input  logic ooe_miu_memop_s1_stall,
  // ooe -> miu, slot 2 of 4
  output logic ooe_miu_memop_s2_valid,
  output ccv_ooe_miu_memop_t ooe_miu_memop_s2_payload,
  input  logic ooe_miu_memop_s2_credit,
  input  logic ooe_miu_memop_s2_stall,
  // ooe -> miu, slot 3 of 4
  output logic ooe_miu_memop_s3_valid,
  output ccv_ooe_miu_memop_t ooe_miu_memop_s3_payload,
  input  logic ooe_miu_memop_s3_credit,
  input  logic ooe_miu_memop_s3_stall,
  output logic ooe_miu_memop_wake,
  // miu -> ooe, slot 0 of 4
  input  logic miu_ooe_cmpl_s0_valid,
  input  ccv_miu_ooe_cmpl_t miu_ooe_cmpl_s0_payload,
  output logic miu_ooe_cmpl_s0_credit,
  output logic miu_ooe_cmpl_s0_stall,
  // miu -> ooe, slot 1 of 4
  input  logic miu_ooe_cmpl_s1_valid,
  input  ccv_miu_ooe_cmpl_t miu_ooe_cmpl_s1_payload,
  output logic miu_ooe_cmpl_s1_credit,
  output logic miu_ooe_cmpl_s1_stall,
  // miu -> ooe, slot 2 of 4
  input  logic miu_ooe_cmpl_s2_valid,
  input  ccv_miu_ooe_cmpl_t miu_ooe_cmpl_s2_payload,
  output logic miu_ooe_cmpl_s2_credit,
  output logic miu_ooe_cmpl_s2_stall,
  // miu -> ooe, slot 3 of 4
  input  logic miu_ooe_cmpl_s3_valid,
  input  ccv_miu_ooe_cmpl_t miu_ooe_cmpl_s3_payload,
  output logic miu_ooe_cmpl_s3_credit,
  output logic miu_ooe_cmpl_s3_stall,
  input  logic miu_ooe_cmpl_wake,
  // ooe -> miu, slot 0 of 4
  output logic ooe_miu_retire_s0_valid,
  output ccv_ooe_miu_retire_t ooe_miu_retire_s0_payload,
  input  logic ooe_miu_retire_s0_credit,
  input  logic ooe_miu_retire_s0_stall,
  // ooe -> miu, slot 1 of 4
  output logic ooe_miu_retire_s1_valid,
  output ccv_ooe_miu_retire_t ooe_miu_retire_s1_payload,
  input  logic ooe_miu_retire_s1_credit,
  input  logic ooe_miu_retire_s1_stall,
  // ooe -> miu, slot 2 of 4
  output logic ooe_miu_retire_s2_valid,
  output ccv_ooe_miu_retire_t ooe_miu_retire_s2_payload,
  input  logic ooe_miu_retire_s2_credit,
  input  logic ooe_miu_retire_s2_stall,
  // ooe -> miu, slot 3 of 4
  output logic ooe_miu_retire_s3_valid,
  output ccv_ooe_miu_retire_t ooe_miu_retire_s3_payload,
  input  logic ooe_miu_retire_s3_credit,
  input  logic ooe_miu_retire_s3_stall,
  output logic ooe_miu_retire_wake,
  // ooe -> fet
  output logic ooe_fet_redirect_valid,
  output ccv_ooe_fet_redirect_t ooe_fet_redirect_payload,
  input  logic ooe_fet_redirect_credit,
  input  logic ooe_fet_redirect_stall,
  output logic ooe_fet_redirect_wake,
  // rau -> ooe
  input  logic rau_ooe_alloc_valid,
  input  ccv_rau_ooe_alloc_t rau_ooe_alloc_payload,
  output logic rau_ooe_alloc_credit,
  output logic rau_ooe_alloc_stall,
  input  logic rau_ooe_alloc_wake,
  // ooe -> rau
  output logic ooe_rau_status_valid,
  output ccv_ooe_rau_status_t ooe_rau_status_payload,
  input  logic ooe_rau_status_credit,
  input  logic ooe_rau_status_stall,
  output logic ooe_rau_status_wake,
  // rau -> ooe
  input  logic rau_ooe_demote_valid,
  input  ccv_rau_ooe_demote_t rau_ooe_demote_payload,
  output logic rau_ooe_demote_credit,
  output logic rau_ooe_demote_stall,
  input  logic rau_ooe_demote_wake,
  // ooe -> rau
  output logic ooe_rau_drained_valid,
  output ccv_ooe_rau_drained_t ooe_rau_drained_payload,
  input  logic ooe_rau_drained_credit,
  input  logic ooe_rau_drained_stall,
  output logic ooe_rau_drained_wake,
  // ooe -> syu
  output logic ooe_syu_bar_valid,
  output ccv_ooe_syu_bar_t ooe_syu_bar_payload,
  input  logic ooe_syu_bar_credit,
  input  logic ooe_syu_bar_stall,
  output logic ooe_syu_bar_wake,
  // syu -> ooe
  input  logic syu_ooe_rel_valid,
  input  ccv_syu_ooe_rel_t syu_ooe_rel_payload,
  output logic syu_ooe_rel_credit,
  output logic syu_ooe_rel_stall,
  input  logic syu_ooe_rel_wake,
  // ooe -> cru
  output logic ooe_cru_fault_valid,
  output ccv_ooe_cru_fault_t ooe_cru_fault_payload,
  input  logic ooe_cru_fault_credit,
  input  logic ooe_cru_fault_stall,
  output logic ooe_cru_fault_wake
`ifdef CCV_TRACE
  , input  logic [63:0] dec_ooe_uop_s0_tid
  , input  logic [63:0] dec_ooe_uop_s1_tid
  , input  logic [63:0] dec_ooe_uop_s2_tid
  , input  logic [63:0] dec_ooe_uop_s3_tid
  , input  logic [63:0] dec_ooe_uop_s4_tid
  , input  logic [63:0] dec_ooe_uop_s5_tid
  , output logic [63:0] ooe_rcu_issue_s0_tid
  , output logic [63:0] ooe_rcu_issue_s1_tid
  , output logic [63:0] ooe_rcu_issue_s2_tid
  , output logic [63:0] ooe_rcu_issue_s3_tid
  , input  logic [63:0] rcu_ooe_done_s0_tid
  , input  logic [63:0] rcu_ooe_done_s1_tid
  , input  logic [63:0] rcu_ooe_done_s2_tid
  , input  logic [63:0] rcu_ooe_done_s3_tid
  , output logic [63:0] ooe_miu_memop_s0_tid
  , output logic [63:0] ooe_miu_memop_s1_tid
  , output logic [63:0] ooe_miu_memop_s2_tid
  , output logic [63:0] ooe_miu_memop_s3_tid
  , input  logic [63:0] miu_ooe_cmpl_s0_tid
  , input  logic [63:0] miu_ooe_cmpl_s1_tid
  , input  logic [63:0] miu_ooe_cmpl_s2_tid
  , input  logic [63:0] miu_ooe_cmpl_s3_tid
  , output logic [63:0] ooe_miu_retire_s0_tid
  , output logic [63:0] ooe_miu_retire_s1_tid
  , output logic [63:0] ooe_miu_retire_s2_tid
  , output logic [63:0] ooe_miu_retire_s3_tid
  , output logic [63:0] ooe_fet_redirect_tid
  , input  logic [63:0] rau_ooe_alloc_tid
  , output logic [63:0] ooe_rau_status_tid
  , input  logic [63:0] rau_ooe_demote_tid
  , output logic [63:0] ooe_rau_drained_tid
  , output logic [63:0] ooe_syu_bar_tid
  , input  logic [63:0] syu_ooe_rel_tid
  , output logic [63:0] ooe_cru_fault_tid
`endif
