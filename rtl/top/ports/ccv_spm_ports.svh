// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_spm. Included between the parentheses of the
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
  // miu -> spm, slot 0 of 4
  input  logic miu_spm_req_s0_valid,
  input  ccv_miu_spm_req_t miu_spm_req_s0_payload,
  output logic miu_spm_req_s0_credit,
  output logic miu_spm_req_s0_stall,
  // miu -> spm, slot 1 of 4
  input  logic miu_spm_req_s1_valid,
  input  ccv_miu_spm_req_t miu_spm_req_s1_payload,
  output logic miu_spm_req_s1_credit,
  output logic miu_spm_req_s1_stall,
  // miu -> spm, slot 2 of 4
  input  logic miu_spm_req_s2_valid,
  input  ccv_miu_spm_req_t miu_spm_req_s2_payload,
  output logic miu_spm_req_s2_credit,
  output logic miu_spm_req_s2_stall,
  // miu -> spm, slot 3 of 4
  input  logic miu_spm_req_s3_valid,
  input  ccv_miu_spm_req_t miu_spm_req_s3_payload,
  output logic miu_spm_req_s3_credit,
  output logic miu_spm_req_s3_stall,
  input  logic miu_spm_req_wake,
  // spm -> miu, slot 0 of 4
  output logic spm_miu_rsp_s0_valid,
  output ccv_spm_miu_rsp_t spm_miu_rsp_s0_payload,
  input  logic spm_miu_rsp_s0_credit,
  input  logic spm_miu_rsp_s0_stall,
  // spm -> miu, slot 1 of 4
  output logic spm_miu_rsp_s1_valid,
  output ccv_spm_miu_rsp_t spm_miu_rsp_s1_payload,
  input  logic spm_miu_rsp_s1_credit,
  input  logic spm_miu_rsp_s1_stall,
  // spm -> miu, slot 2 of 4
  output logic spm_miu_rsp_s2_valid,
  output ccv_spm_miu_rsp_t spm_miu_rsp_s2_payload,
  input  logic spm_miu_rsp_s2_credit,
  input  logic spm_miu_rsp_s2_stall,
  // spm -> miu, slot 3 of 4
  output logic spm_miu_rsp_s3_valid,
  output ccv_spm_miu_rsp_t spm_miu_rsp_s3_payload,
  input  logic spm_miu_rsp_s3_credit,
  input  logic spm_miu_rsp_s3_stall,
  output logic spm_miu_rsp_wake
`ifdef CCV_TRACE
  , input  logic [63:0] miu_spm_req_s0_tid
  , input  logic [63:0] miu_spm_req_s1_tid
  , input  logic [63:0] miu_spm_req_s2_tid
  , input  logic [63:0] miu_spm_req_s3_tid
  , output logic [63:0] spm_miu_rsp_s0_tid
  , output logic [63:0] spm_miu_rsp_s1_tid
  , output logic [63:0] spm_miu_rsp_s2_tid
  , output logic [63:0] spm_miu_rsp_s3_tid
`endif
