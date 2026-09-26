// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_dcu. Included between the parentheses of the
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
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // miu -> dcu, slot 0 of 4
  input  logic miu_dcu_req_s0_valid,
  input  ccv_miu_dcu_req_t miu_dcu_req_s0_payload,
  output logic miu_dcu_req_s0_credit,
  output logic miu_dcu_req_s0_stall,
  // miu -> dcu, slot 1 of 4
  input  logic miu_dcu_req_s1_valid,
  input  ccv_miu_dcu_req_t miu_dcu_req_s1_payload,
  output logic miu_dcu_req_s1_credit,
  output logic miu_dcu_req_s1_stall,
  // miu -> dcu, slot 2 of 4
  input  logic miu_dcu_req_s2_valid,
  input  ccv_miu_dcu_req_t miu_dcu_req_s2_payload,
  output logic miu_dcu_req_s2_credit,
  output logic miu_dcu_req_s2_stall,
  // miu -> dcu, slot 3 of 4
  input  logic miu_dcu_req_s3_valid,
  input  ccv_miu_dcu_req_t miu_dcu_req_s3_payload,
  output logic miu_dcu_req_s3_credit,
  output logic miu_dcu_req_s3_stall,
  input  logic miu_dcu_req_wake,
  // dcu -> miu, slot 0 of 4
  output logic dcu_miu_rsp_s0_valid,
  output ccv_dcu_miu_rsp_t dcu_miu_rsp_s0_payload,
  input  logic dcu_miu_rsp_s0_credit,
  input  logic dcu_miu_rsp_s0_stall,
  // dcu -> miu, slot 1 of 4
  output logic dcu_miu_rsp_s1_valid,
  output ccv_dcu_miu_rsp_t dcu_miu_rsp_s1_payload,
  input  logic dcu_miu_rsp_s1_credit,
  input  logic dcu_miu_rsp_s1_stall,
  // dcu -> miu, slot 2 of 4
  output logic dcu_miu_rsp_s2_valid,
  output ccv_dcu_miu_rsp_t dcu_miu_rsp_s2_payload,
  input  logic dcu_miu_rsp_s2_credit,
  input  logic dcu_miu_rsp_s2_stall,
  // dcu -> miu, slot 3 of 4
  output logic dcu_miu_rsp_s3_valid,
  output ccv_dcu_miu_rsp_t dcu_miu_rsp_s3_payload,
  input  logic dcu_miu_rsp_s3_credit,
  input  logic dcu_miu_rsp_s3_stall,
  output logic dcu_miu_rsp_wake,
  // dcu -> mlc
  output logic dcu_mlc_req_valid,
  output ccv_dcu_mlc_req_t dcu_mlc_req_payload,
  input  logic dcu_mlc_req_credit,
  input  logic dcu_mlc_req_stall,
  output logic dcu_mlc_req_wake,
  // mlc -> dcu
  input  logic mlc_dcu_rsp_valid,
  input  ccv_mlc_dcu_rsp_t mlc_dcu_rsp_payload,
  output logic mlc_dcu_rsp_credit,
  output logic mlc_dcu_rsp_stall,
  input  logic mlc_dcu_rsp_wake,
  // mlc -> dcu
  input  logic mlc_dcu_probe_valid,
  input  ccv_mlc_dcu_probe_t mlc_dcu_probe_payload,
  output logic mlc_dcu_probe_credit,
  output logic mlc_dcu_probe_stall,
  input  logic mlc_dcu_probe_wake,
  // dcu -> mlc
  output logic dcu_mlc_probe_ack_valid,
  output ccv_dcu_mlc_probe_ack_t dcu_mlc_probe_ack_payload,
  input  logic dcu_mlc_probe_ack_credit,
  input  logic dcu_mlc_probe_ack_stall,
  output logic dcu_mlc_probe_ack_wake
`ifdef CCV_CHECK
  , output logic clk_gated
`endif
`ifdef CCV_TRACE
  , input  logic [63:0] miu_dcu_req_s0_tid
  , input  logic [63:0] miu_dcu_req_s1_tid
  , input  logic [63:0] miu_dcu_req_s2_tid
  , input  logic [63:0] miu_dcu_req_s3_tid
  , output logic [63:0] dcu_miu_rsp_s0_tid
  , output logic [63:0] dcu_miu_rsp_s1_tid
  , output logic [63:0] dcu_miu_rsp_s2_tid
  , output logic [63:0] dcu_miu_rsp_s3_tid
  , output logic [63:0] dcu_mlc_req_tid
  , input  logic [63:0] mlc_dcu_rsp_tid
  , input  logic [63:0] mlc_dcu_probe_tid
  , output logic [63:0] dcu_mlc_probe_ack_tid
`endif
