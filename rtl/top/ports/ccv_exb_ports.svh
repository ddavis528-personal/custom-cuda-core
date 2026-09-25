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
  // mlc -> exb, 1 slot(s) x 1090 bit payload
  input  logic mlc_exb_req_valid,
  input  logic [1089:0] mlc_exb_req_payload,
  output logic mlc_exb_req_credit,
  output logic mlc_exb_req_stall,
  // exb -> mlc, 1 slot(s) x 1082 bit payload
  output logic exb_mlc_rsp_valid,
  output logic [1081:0] exb_mlc_rsp_payload,
  input  logic exb_mlc_rsp_credit,
  input  logic exb_mlc_rsp_stall,
  // exb -> EXTERNAL, 1 slot(s) x 1225 bit payload
  output logic exb_ext_out_valid,
  output logic [1224:0] exb_ext_out_payload,
  input  logic exb_ext_out_credit,
  input  logic exb_ext_out_stall,
  // EXTERNAL -> exb, 1 slot(s) x 1176 bit payload
  input  logic ext_exb_in_valid,
  input  logic [1175:0] ext_exb_in_payload,
  output logic ext_exb_in_credit,
  output logic ext_exb_in_stall
`ifdef CCV_TRACE
  , input  logic [63:0] mlc_exb_req_tid
  , output logic [63:0] exb_mlc_rsp_tid
  , output logic [63:0] exb_ext_out_tid
  , input  logic [63:0] ext_exb_in_tid
`endif
