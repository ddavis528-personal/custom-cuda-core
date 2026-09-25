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
  // miu -> dcu, 4 slot(s) x 1212 bit payload
  input  logic [3:0] miu_dcu_req_valid,
  input  logic [4847:0] miu_dcu_req_payload,
  output logic [3:0] miu_dcu_req_credit,
  output logic [3:0] miu_dcu_req_stall,
  // dcu -> miu, 4 slot(s) x 1030 bit payload
  output logic [3:0] dcu_miu_rsp_valid,
  output logic [4119:0] dcu_miu_rsp_payload,
  input  logic [3:0] dcu_miu_rsp_credit,
  input  logic [3:0] dcu_miu_rsp_stall,
  // dcu -> mlc, 1 slot(s) x 1082 bit payload
  output logic dcu_mlc_req_valid,
  output logic [1081:0] dcu_mlc_req_payload,
  input  logic dcu_mlc_req_credit,
  input  logic dcu_mlc_req_stall,
  // mlc -> dcu, 1 slot(s) x 1030 bit payload
  input  logic mlc_dcu_rsp_valid,
  input  logic [1029:0] mlc_dcu_rsp_payload,
  output logic mlc_dcu_rsp_credit,
  output logic mlc_dcu_rsp_stall,
  // mlc -> dcu, 1 slot(s) x 51 bit payload
  input  logic mlc_dcu_probe_valid,
  input  logic [50:0] mlc_dcu_probe_payload,
  output logic mlc_dcu_probe_credit,
  output logic mlc_dcu_probe_stall,
  // dcu -> mlc, 1 slot(s) x 1027 bit payload
  output logic dcu_mlc_probe_ack_valid,
  output logic [1026:0] dcu_mlc_probe_ack_payload,
  input  logic dcu_mlc_probe_ack_credit,
  input  logic dcu_mlc_probe_ack_stall
`ifdef CCV_TRACE
  , input  logic [255:0] miu_dcu_req_tid
  , output logic [255:0] dcu_miu_rsp_tid
  , output logic [63:0] dcu_mlc_req_tid
  , input  logic [63:0] mlc_dcu_rsp_tid
  , input  logic [63:0] mlc_dcu_probe_tid
  , output logic [63:0] dcu_mlc_probe_ack_tid
`endif
