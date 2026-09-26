// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_exb. Included between the parentheses of the
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
  output logic sleep_ok,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // mlc -> exb
  input  logic mlc_exb_req_valid,
  input  ccv_mlc_exb_req_t mlc_exb_req_payload,
  output logic mlc_exb_req_credit,
  output logic mlc_exb_req_stall,
  input  logic mlc_exb_req_wake,
  // exb -> mlc
  output logic exb_mlc_rsp_valid,
  output ccv_exb_mlc_rsp_t exb_mlc_rsp_payload,
  input  logic exb_mlc_rsp_credit,
  input  logic exb_mlc_rsp_stall,
  output logic exb_mlc_rsp_wake,
  // exb -> EXTERNAL
  output logic exb_ext_out_valid,
  output ccv_exb_ext_out_t exb_ext_out_payload,
  input  logic exb_ext_out_credit,
  input  logic exb_ext_out_stall,
  output logic exb_ext_out_wake,
  // EXTERNAL -> exb
  input  logic ext_exb_in_valid,
  input  ccv_ext_exb_in_t ext_exb_in_payload,
  output logic ext_exb_in_credit,
  output logic ext_exb_in_stall,
  input  logic ext_exb_in_wake
`ifdef CCV_TRACE
  , input  logic [63:0] mlc_exb_req_tid
  , output logic [63:0] exb_mlc_rsp_tid
  , output logic [63:0] exb_ext_out_tid
  , input  logic [63:0] ext_exb_in_tid
`endif
