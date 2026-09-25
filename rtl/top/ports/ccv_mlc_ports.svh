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
// flop that drives the port. `_tid` is trace-only (CCV_TRACE).
  input  logic clk,
  input  logic clk_free,
  input  logic rst_n,
  input  logic kill_valid,
  input  logic [3:0] kill_warp_mask,
  output logic kill_ack,
  output logic sleep_ok,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // dcu -> mlc, 1 slot(s) x 1082 bit payload
  input  logic dcu_mlc_req_valid,
  input  logic [1081:0] dcu_mlc_req_payload,
  output logic dcu_mlc_req_credit,
  output logic dcu_mlc_req_stall,
  input  logic dcu_mlc_req_wake,
  // mlc -> dcu, 1 slot(s) x 1030 bit payload
  output logic mlc_dcu_rsp_valid,
  output logic [1029:0] mlc_dcu_rsp_payload,
  input  logic mlc_dcu_rsp_credit,
  input  logic mlc_dcu_rsp_stall,
  output logic mlc_dcu_rsp_wake,
  // mlc -> dcu, 1 slot(s) x 51 bit payload
  output logic mlc_dcu_probe_valid,
  output logic [50:0] mlc_dcu_probe_payload,
  input  logic mlc_dcu_probe_credit,
  input  logic mlc_dcu_probe_stall,
  output logic mlc_dcu_probe_wake,
  // dcu -> mlc, 1 slot(s) x 1027 bit payload
  input  logic dcu_mlc_probe_ack_valid,
  input  logic [1026:0] dcu_mlc_probe_ack_payload,
  output logic dcu_mlc_probe_ack_credit,
  output logic dcu_mlc_probe_ack_stall,
  input  logic dcu_mlc_probe_ack_wake,
  // fet -> mlc, 1 slot(s) x 58 bit payload
  input  logic fet_mlc_ifill_valid,
  input  logic [57:0] fet_mlc_ifill_payload,
  output logic fet_mlc_ifill_credit,
  output logic fet_mlc_ifill_stall,
  input  logic fet_mlc_ifill_wake,
  // mlc -> fet, 1 slot(s) x 1026 bit payload
  output logic mlc_fet_ifill_rsp_valid,
  output logic [1025:0] mlc_fet_ifill_rsp_payload,
  input  logic mlc_fet_ifill_rsp_credit,
  input  logic mlc_fet_ifill_rsp_stall,
  output logic mlc_fet_ifill_rsp_wake,
  // mlc -> exb, 1 slot(s) x 1090 bit payload
  output logic mlc_exb_req_valid,
  output logic [1089:0] mlc_exb_req_payload,
  input  logic mlc_exb_req_credit,
  input  logic mlc_exb_req_stall,
  output logic mlc_exb_req_wake,
  // exb -> mlc, 1 slot(s) x 1082 bit payload
  input  logic exb_mlc_rsp_valid,
  input  logic [1081:0] exb_mlc_rsp_payload,
  output logic exb_mlc_rsp_credit,
  output logic exb_mlc_rsp_stall,
  input  logic exb_mlc_rsp_wake
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
