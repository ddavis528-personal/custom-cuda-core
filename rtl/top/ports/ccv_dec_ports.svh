// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_dec. Included between the parentheses of the
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
  // fet -> dec, 8 slot(s) x 122 bit payload
  input  logic [7:0] fet_dec_instr_valid,
  input  logic [975:0] fet_dec_instr_payload,
  output logic [7:0] fet_dec_instr_credit,
  output logic [7:0] fet_dec_instr_stall,
  input  logic fet_dec_instr_wake,
  // dec -> ooe, 6 slot(s) x 133 bit payload
  output logic [5:0] dec_ooe_uop_valid,
  output logic [797:0] dec_ooe_uop_payload,
  input  logic [5:0] dec_ooe_uop_credit,
  input  logic [5:0] dec_ooe_uop_stall,
  output logic dec_ooe_uop_wake
`ifdef CCV_TRACE
  , input  logic [511:0] fet_dec_instr_tid
  , output logic [383:0] dec_ooe_uop_tid
`endif
