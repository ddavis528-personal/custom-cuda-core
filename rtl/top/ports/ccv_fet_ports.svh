// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_fet. Included between the parentheses of the
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
  // fet -> dec, 8 slot(s) x 120 bit payload
  output logic [7:0] fet_dec_instr_valid,
  output logic [959:0] fet_dec_instr_payload,
  input  logic [7:0] fet_dec_instr_credit,
  input  logic [7:0] fet_dec_instr_stall,
  // fet -> mlc, 1 slot(s) x 58 bit payload
  output logic fet_mlc_ifill_valid,
  output logic [57:0] fet_mlc_ifill_payload,
  input  logic fet_mlc_ifill_credit,
  input  logic fet_mlc_ifill_stall,
  // mlc -> fet, 1 slot(s) x 1026 bit payload
  input  logic mlc_fet_ifill_rsp_valid,
  input  logic [1025:0] mlc_fet_ifill_rsp_payload,
  output logic mlc_fet_ifill_rsp_credit,
  output logic mlc_fet_ifill_rsp_stall,
  // miu -> fet, 1 slot(s) x 64 bit payload
  input  logic miu_fet_itlb_valid,
  input  logic [63:0] miu_fet_itlb_payload,
  output logic miu_fet_itlb_credit,
  output logic miu_fet_itlb_stall,
  // fet -> miu, 1 slot(s) x 72 bit payload
  output logic fet_miu_itlb_req_valid,
  output logic [71:0] fet_miu_itlb_req_payload,
  input  logic fet_miu_itlb_req_credit,
  input  logic fet_miu_itlb_req_stall,
  // rau -> fet, 1 slot(s) x 184 bit payload
  input  logic rau_fet_launch_valid,
  input  logic [183:0] rau_fet_launch_payload,
  output logic rau_fet_launch_credit,
  output logic rau_fet_launch_stall
`ifdef CCV_TRACE
  , output logic [511:0] fet_dec_instr_tid
  , output logic [63:0] fet_mlc_ifill_tid
  , input  logic [63:0] mlc_fet_ifill_rsp_tid
  , input  logic [63:0] miu_fet_itlb_tid
  , output logic [63:0] fet_miu_itlb_req_tid
  , input  logic [63:0] rau_fet_launch_tid
`endif
