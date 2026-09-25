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
  input  logic wake_req,
  output logic sleep_ok,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // dcu -> mlc, 1 slot(s) x 1078 bit payload
  input  logic dcu_mlc_req_valid,
  input  logic [1077:0] dcu_mlc_req_payload,
  output logic dcu_mlc_req_credit,
  output logic dcu_mlc_req_stall,
  // mlc -> dcu, 1 slot(s) x 1026 bit payload
  output logic mlc_dcu_rsp_valid,
  output logic [1025:0] mlc_dcu_rsp_payload,
  input  logic mlc_dcu_rsp_credit,
  input  logic mlc_dcu_rsp_stall,
  // mlc -> dcu, 1 slot(s) x 49 bit payload
  output logic mlc_dcu_probe_valid,
  output logic [48:0] mlc_dcu_probe_payload,
  input  logic mlc_dcu_probe_credit,
  input  logic mlc_dcu_probe_stall,
  // dcu -> mlc, 1 slot(s) x 1025 bit payload
  input  logic dcu_mlc_probe_ack_valid,
  input  logic [1024:0] dcu_mlc_probe_ack_payload,
  output logic dcu_mlc_probe_ack_credit,
  output logic dcu_mlc_probe_ack_stall,
  // fet -> mlc, 1 slot(s) x 56 bit payload
  input  logic fet_mlc_ifill_valid,
  input  logic [55:0] fet_mlc_ifill_payload,
  output logic fet_mlc_ifill_credit,
  output logic fet_mlc_ifill_stall,
  // mlc -> fet, 1 slot(s) x 1024 bit payload
  output logic mlc_fet_ifill_rsp_valid,
  output logic [1023:0] mlc_fet_ifill_rsp_payload,
  input  logic mlc_fet_ifill_rsp_credit,
  input  logic mlc_fet_ifill_rsp_stall,
  // mlc -> exb, 1 slot(s) x 1084 bit payload
  output logic mlc_exb_req_valid,
  output logic [1083:0] mlc_exb_req_payload,
  input  logic mlc_exb_req_credit,
  input  logic mlc_exb_req_stall,
  // exb -> mlc, 1 slot(s) x 1027 bit payload
  input  logic exb_mlc_rsp_valid,
  input  logic [1026:0] exb_mlc_rsp_payload,
  output logic exb_mlc_rsp_credit,
  output logic exb_mlc_rsp_stall
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
