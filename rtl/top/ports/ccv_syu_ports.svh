// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// Port list of ccv_syu. Included between the parentheses of the
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
  // ooe -> syu, 1 slot(s) x 13 bit payload
  input  logic ooe_syu_bar_valid,
  input  logic [12:0] ooe_syu_bar_payload,
  output logic ooe_syu_bar_credit,
  output logic ooe_syu_bar_stall,
  input  logic ooe_syu_bar_wake,
  // syu -> ooe, 1 slot(s) x 36 bit payload
  output logic syu_ooe_rel_valid,
  output logic [35:0] syu_ooe_rel_payload,
  input  logic syu_ooe_rel_credit,
  input  logic syu_ooe_rel_stall,
  output logic syu_ooe_rel_wake,
  // rau -> syu, 1 slot(s) x 17 bit payload
  input  logic rau_syu_alloc_valid,
  input  logic [16:0] rau_syu_alloc_payload,
  output logic rau_syu_alloc_credit,
  output logic rau_syu_alloc_stall,
  input  logic rau_syu_alloc_wake
`ifdef CCV_TRACE
  , input  logic [63:0] ooe_syu_bar_tid
  , output logic [63:0] syu_ooe_rel_tid
  , input  logic [63:0] rau_syu_alloc_tid
`endif
