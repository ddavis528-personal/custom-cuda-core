// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_miu. Included between the parentheses of the
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
  // rcu -> miu, slot 0 of 4
  input  logic rcu_miu_addr_s0_valid,
  input  ccv_rcu_miu_addr_t rcu_miu_addr_s0_payload,
  output logic rcu_miu_addr_s0_credit,
  output logic rcu_miu_addr_s0_stall,
  // rcu -> miu, slot 1 of 4
  input  logic rcu_miu_addr_s1_valid,
  input  ccv_rcu_miu_addr_t rcu_miu_addr_s1_payload,
  output logic rcu_miu_addr_s1_credit,
  output logic rcu_miu_addr_s1_stall,
  // rcu -> miu, slot 2 of 4
  input  logic rcu_miu_addr_s2_valid,
  input  ccv_rcu_miu_addr_t rcu_miu_addr_s2_payload,
  output logic rcu_miu_addr_s2_credit,
  output logic rcu_miu_addr_s2_stall,
  // rcu -> miu, slot 3 of 4
  input  logic rcu_miu_addr_s3_valid,
  input  ccv_rcu_miu_addr_t rcu_miu_addr_s3_payload,
  output logic rcu_miu_addr_s3_credit,
  output logic rcu_miu_addr_s3_stall,
  input  logic rcu_miu_addr_wake,
  // miu -> rcu, slot 0 of 4
  output logic miu_rcu_data_s0_valid,
  output ccv_miu_rcu_data_t miu_rcu_data_s0_payload,
  input  logic miu_rcu_data_s0_credit,
  input  logic miu_rcu_data_s0_stall,
  // miu -> rcu, slot 1 of 4
  output logic miu_rcu_data_s1_valid,
  output ccv_miu_rcu_data_t miu_rcu_data_s1_payload,
  input  logic miu_rcu_data_s1_credit,
  input  logic miu_rcu_data_s1_stall,
  // miu -> rcu, slot 2 of 4
  output logic miu_rcu_data_s2_valid,
  output ccv_miu_rcu_data_t miu_rcu_data_s2_payload,
  input  logic miu_rcu_data_s2_credit,
  input  logic miu_rcu_data_s2_stall,
  // miu -> rcu, slot 3 of 4
  output logic miu_rcu_data_s3_valid,
  output ccv_miu_rcu_data_t miu_rcu_data_s3_payload,
  input  logic miu_rcu_data_s3_credit,
  input  logic miu_rcu_data_s3_stall,
  output logic miu_rcu_data_wake,
  // ooe -> miu, slot 0 of 4
  input  logic ooe_miu_memop_s0_valid,
  input  ccv_ooe_miu_memop_t ooe_miu_memop_s0_payload,
  output logic ooe_miu_memop_s0_credit,
  output logic ooe_miu_memop_s0_stall,
  // ooe -> miu, slot 1 of 4
  input  logic ooe_miu_memop_s1_valid,
  input  ccv_ooe_miu_memop_t ooe_miu_memop_s1_payload,
  output logic ooe_miu_memop_s1_credit,
  output logic ooe_miu_memop_s1_stall,
  // ooe -> miu, slot 2 of 4
  input  logic ooe_miu_memop_s2_valid,
  input  ccv_ooe_miu_memop_t ooe_miu_memop_s2_payload,
  output logic ooe_miu_memop_s2_credit,
  output logic ooe_miu_memop_s2_stall,
  // ooe -> miu, slot 3 of 4
  input  logic ooe_miu_memop_s3_valid,
  input  ccv_ooe_miu_memop_t ooe_miu_memop_s3_payload,
  output logic ooe_miu_memop_s3_credit,
  output logic ooe_miu_memop_s3_stall,
  input  logic ooe_miu_memop_wake,
  // miu -> ooe, slot 0 of 4
  output logic miu_ooe_cmpl_s0_valid,
  output ccv_miu_ooe_cmpl_t miu_ooe_cmpl_s0_payload,
  input  logic miu_ooe_cmpl_s0_credit,
  input  logic miu_ooe_cmpl_s0_stall,
  // miu -> ooe, slot 1 of 4
  output logic miu_ooe_cmpl_s1_valid,
  output ccv_miu_ooe_cmpl_t miu_ooe_cmpl_s1_payload,
  input  logic miu_ooe_cmpl_s1_credit,
  input  logic miu_ooe_cmpl_s1_stall,
  // miu -> ooe, slot 2 of 4
  output logic miu_ooe_cmpl_s2_valid,
  output ccv_miu_ooe_cmpl_t miu_ooe_cmpl_s2_payload,
  input  logic miu_ooe_cmpl_s2_credit,
  input  logic miu_ooe_cmpl_s2_stall,
  // miu -> ooe, slot 3 of 4
  output logic miu_ooe_cmpl_s3_valid,
  output ccv_miu_ooe_cmpl_t miu_ooe_cmpl_s3_payload,
  input  logic miu_ooe_cmpl_s3_credit,
  input  logic miu_ooe_cmpl_s3_stall,
  output logic miu_ooe_cmpl_wake,
  // ooe -> miu, slot 0 of 4
  input  logic ooe_miu_retire_s0_valid,
  input  ccv_ooe_miu_retire_t ooe_miu_retire_s0_payload,
  output logic ooe_miu_retire_s0_credit,
  output logic ooe_miu_retire_s0_stall,
  // ooe -> miu, slot 1 of 4
  input  logic ooe_miu_retire_s1_valid,
  input  ccv_ooe_miu_retire_t ooe_miu_retire_s1_payload,
  output logic ooe_miu_retire_s1_credit,
  output logic ooe_miu_retire_s1_stall,
  // ooe -> miu, slot 2 of 4
  input  logic ooe_miu_retire_s2_valid,
  input  ccv_ooe_miu_retire_t ooe_miu_retire_s2_payload,
  output logic ooe_miu_retire_s2_credit,
  output logic ooe_miu_retire_s2_stall,
  // ooe -> miu, slot 3 of 4
  input  logic ooe_miu_retire_s3_valid,
  input  ccv_ooe_miu_retire_t ooe_miu_retire_s3_payload,
  output logic ooe_miu_retire_s3_credit,
  output logic ooe_miu_retire_s3_stall,
  input  logic ooe_miu_retire_wake,
  // miu -> spm, slot 0 of 4
  output logic miu_spm_req_s0_valid,
  output ccv_miu_spm_req_t miu_spm_req_s0_payload,
  input  logic miu_spm_req_s0_credit,
  input  logic miu_spm_req_s0_stall,
  // miu -> spm, slot 1 of 4
  output logic miu_spm_req_s1_valid,
  output ccv_miu_spm_req_t miu_spm_req_s1_payload,
  input  logic miu_spm_req_s1_credit,
  input  logic miu_spm_req_s1_stall,
  // miu -> spm, slot 2 of 4
  output logic miu_spm_req_s2_valid,
  output ccv_miu_spm_req_t miu_spm_req_s2_payload,
  input  logic miu_spm_req_s2_credit,
  input  logic miu_spm_req_s2_stall,
  // miu -> spm, slot 3 of 4
  output logic miu_spm_req_s3_valid,
  output ccv_miu_spm_req_t miu_spm_req_s3_payload,
  input  logic miu_spm_req_s3_credit,
  input  logic miu_spm_req_s3_stall,
  output logic miu_spm_req_wake,
  // spm -> miu, slot 0 of 4
  input  logic spm_miu_rsp_s0_valid,
  input  ccv_spm_miu_rsp_t spm_miu_rsp_s0_payload,
  output logic spm_miu_rsp_s0_credit,
  output logic spm_miu_rsp_s0_stall,
  // spm -> miu, slot 1 of 4
  input  logic spm_miu_rsp_s1_valid,
  input  ccv_spm_miu_rsp_t spm_miu_rsp_s1_payload,
  output logic spm_miu_rsp_s1_credit,
  output logic spm_miu_rsp_s1_stall,
  // spm -> miu, slot 2 of 4
  input  logic spm_miu_rsp_s2_valid,
  input  ccv_spm_miu_rsp_t spm_miu_rsp_s2_payload,
  output logic spm_miu_rsp_s2_credit,
  output logic spm_miu_rsp_s2_stall,
  // spm -> miu, slot 3 of 4
  input  logic spm_miu_rsp_s3_valid,
  input  ccv_spm_miu_rsp_t spm_miu_rsp_s3_payload,
  output logic spm_miu_rsp_s3_credit,
  output logic spm_miu_rsp_s3_stall,
  input  logic spm_miu_rsp_wake,
  // miu -> dcu, slot 0 of 4
  output logic miu_dcu_req_s0_valid,
  output ccv_miu_dcu_req_t miu_dcu_req_s0_payload,
  input  logic miu_dcu_req_s0_credit,
  input  logic miu_dcu_req_s0_stall,
  // miu -> dcu, slot 1 of 4
  output logic miu_dcu_req_s1_valid,
  output ccv_miu_dcu_req_t miu_dcu_req_s1_payload,
  input  logic miu_dcu_req_s1_credit,
  input  logic miu_dcu_req_s1_stall,
  // miu -> dcu, slot 2 of 4
  output logic miu_dcu_req_s2_valid,
  output ccv_miu_dcu_req_t miu_dcu_req_s2_payload,
  input  logic miu_dcu_req_s2_credit,
  input  logic miu_dcu_req_s2_stall,
  // miu -> dcu, slot 3 of 4
  output logic miu_dcu_req_s3_valid,
  output ccv_miu_dcu_req_t miu_dcu_req_s3_payload,
  input  logic miu_dcu_req_s3_credit,
  input  logic miu_dcu_req_s3_stall,
  output logic miu_dcu_req_wake,
  // dcu -> miu, slot 0 of 4
  input  logic dcu_miu_rsp_s0_valid,
  input  ccv_dcu_miu_rsp_t dcu_miu_rsp_s0_payload,
  output logic dcu_miu_rsp_s0_credit,
  output logic dcu_miu_rsp_s0_stall,
  // dcu -> miu, slot 1 of 4
  input  logic dcu_miu_rsp_s1_valid,
  input  ccv_dcu_miu_rsp_t dcu_miu_rsp_s1_payload,
  output logic dcu_miu_rsp_s1_credit,
  output logic dcu_miu_rsp_s1_stall,
  // dcu -> miu, slot 2 of 4
  input  logic dcu_miu_rsp_s2_valid,
  input  ccv_dcu_miu_rsp_t dcu_miu_rsp_s2_payload,
  output logic dcu_miu_rsp_s2_credit,
  output logic dcu_miu_rsp_s2_stall,
  // dcu -> miu, slot 3 of 4
  input  logic dcu_miu_rsp_s3_valid,
  input  ccv_dcu_miu_rsp_t dcu_miu_rsp_s3_payload,
  output logic dcu_miu_rsp_s3_credit,
  output logic dcu_miu_rsp_s3_stall,
  input  logic dcu_miu_rsp_wake,
  // miu -> fet
  output logic miu_fet_itlb_valid,
  output ccv_miu_fet_itlb_t miu_fet_itlb_payload,
  input  logic miu_fet_itlb_credit,
  input  logic miu_fet_itlb_stall,
  output logic miu_fet_itlb_wake,
  // fet -> miu
  input  logic fet_miu_itlb_req_valid,
  input  ccv_fet_miu_itlb_req_t fet_miu_itlb_req_payload,
  output logic fet_miu_itlb_req_credit,
  output logic fet_miu_itlb_req_stall,
  input  logic fet_miu_itlb_req_wake,
  // rau -> miu
  input  logic rau_miu_cta_valid,
  input  ccv_rau_miu_cta_t rau_miu_cta_payload,
  output logic rau_miu_cta_credit,
  output logic rau_miu_cta_stall,
  input  logic rau_miu_cta_wake
`ifdef CCV_TRACE
  , input  logic [63:0] rcu_miu_addr_s0_tid
  , input  logic [63:0] rcu_miu_addr_s1_tid
  , input  logic [63:0] rcu_miu_addr_s2_tid
  , input  logic [63:0] rcu_miu_addr_s3_tid
  , output logic [63:0] miu_rcu_data_s0_tid
  , output logic [63:0] miu_rcu_data_s1_tid
  , output logic [63:0] miu_rcu_data_s2_tid
  , output logic [63:0] miu_rcu_data_s3_tid
  , input  logic [63:0] ooe_miu_memop_s0_tid
  , input  logic [63:0] ooe_miu_memop_s1_tid
  , input  logic [63:0] ooe_miu_memop_s2_tid
  , input  logic [63:0] ooe_miu_memop_s3_tid
  , output logic [63:0] miu_ooe_cmpl_s0_tid
  , output logic [63:0] miu_ooe_cmpl_s1_tid
  , output logic [63:0] miu_ooe_cmpl_s2_tid
  , output logic [63:0] miu_ooe_cmpl_s3_tid
  , input  logic [63:0] ooe_miu_retire_s0_tid
  , input  logic [63:0] ooe_miu_retire_s1_tid
  , input  logic [63:0] ooe_miu_retire_s2_tid
  , input  logic [63:0] ooe_miu_retire_s3_tid
  , output logic [63:0] miu_spm_req_s0_tid
  , output logic [63:0] miu_spm_req_s1_tid
  , output logic [63:0] miu_spm_req_s2_tid
  , output logic [63:0] miu_spm_req_s3_tid
  , input  logic [63:0] spm_miu_rsp_s0_tid
  , input  logic [63:0] spm_miu_rsp_s1_tid
  , input  logic [63:0] spm_miu_rsp_s2_tid
  , input  logic [63:0] spm_miu_rsp_s3_tid
  , output logic [63:0] miu_dcu_req_s0_tid
  , output logic [63:0] miu_dcu_req_s1_tid
  , output logic [63:0] miu_dcu_req_s2_tid
  , output logic [63:0] miu_dcu_req_s3_tid
  , input  logic [63:0] dcu_miu_rsp_s0_tid
  , input  logic [63:0] dcu_miu_rsp_s1_tid
  , input  logic [63:0] dcu_miu_rsp_s2_tid
  , input  logic [63:0] dcu_miu_rsp_s3_tid
  , output logic [63:0] miu_fet_itlb_tid
  , input  logic [63:0] fet_miu_itlb_req_tid
  , input  logic [63:0] rau_miu_cta_tid
`endif
