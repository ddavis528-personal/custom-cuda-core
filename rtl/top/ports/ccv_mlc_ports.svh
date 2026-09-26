// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_mlc. Included between the parentheses of the
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
  // dcu -> mlc
  input  logic dcu_mlc_req_valid,
  input  ccv_dcu_mlc_req_t dcu_mlc_req_payload,
  output logic dcu_mlc_req_credit,
  output logic dcu_mlc_req_stall,
  input  logic dcu_mlc_req_wake,
  // mlc -> dcu
  output logic mlc_dcu_rsp_valid,
  output ccv_mlc_dcu_rsp_t mlc_dcu_rsp_payload,
  input  logic mlc_dcu_rsp_credit,
  input  logic mlc_dcu_rsp_stall,
  output logic mlc_dcu_rsp_wake,
  // mlc -> dcu
  output logic mlc_dcu_probe_valid,
  output ccv_mlc_dcu_probe_t mlc_dcu_probe_payload,
  input  logic mlc_dcu_probe_credit,
  input  logic mlc_dcu_probe_stall,
  output logic mlc_dcu_probe_wake,
  // dcu -> mlc
  input  logic dcu_mlc_probe_ack_valid,
  input  ccv_dcu_mlc_probe_ack_t dcu_mlc_probe_ack_payload,
  output logic dcu_mlc_probe_ack_credit,
  output logic dcu_mlc_probe_ack_stall,
  input  logic dcu_mlc_probe_ack_wake,
  // fet -> mlc
  input  logic fet_mlc_ifill_valid,
  input  ccv_fet_mlc_ifill_t fet_mlc_ifill_payload,
  output logic fet_mlc_ifill_credit,
  output logic fet_mlc_ifill_stall,
  input  logic fet_mlc_ifill_wake,
  // mlc -> fet
  output logic mlc_fet_ifill_rsp_valid,
  output ccv_mlc_fet_ifill_rsp_t mlc_fet_ifill_rsp_payload,
  input  logic mlc_fet_ifill_rsp_credit,
  input  logic mlc_fet_ifill_rsp_stall,
  output logic mlc_fet_ifill_rsp_wake,
  // mlc -> exb
  output logic mlc_exb_req_valid,
  output ccv_mlc_exb_req_t mlc_exb_req_payload,
  input  logic mlc_exb_req_credit,
  input  logic mlc_exb_req_stall,
  output logic mlc_exb_req_wake,
  // exb -> mlc
  input  logic exb_mlc_rsp_valid,
  input  ccv_exb_mlc_rsp_t exb_mlc_rsp_payload,
  output logic exb_mlc_rsp_credit,
  output logic exb_mlc_rsp_stall,
  input  logic exb_mlc_rsp_wake
`ifdef CCV_CHECK
  , output logic clk_gated
`endif
`ifdef CCV_TRACE
  , input  logic [63:0] dcu_mlc_req_tid
  , output logic [63:0] mlc_dcu_rsp_tid
  , output logic [63:0] mlc_dcu_probe_tid
  , input  logic [63:0] dcu_mlc_probe_ack_tid
  , input  logic [63:0] fet_mlc_ifill_tid
  , output logic [63:0] mlc_fet_ifill_rsp_tid
  , output logic [63:0] mlc_exb_req_tid
  , input  logic [63:0] exb_mlc_rsp_tid
`endif
