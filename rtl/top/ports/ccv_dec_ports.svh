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
// flop that drives the port. One group per slot:
//   <chan>[_c<NN>][_s<K>]_{valid,payload,credit,stall}, and
//   <chan>[_c<NN>]_wake per channel instance; `_c` only where a
// block names one of several copies, `_s` only at rate > 1.
// `_payload` is typed ccv_<chan>_t. `_tid` is trace-only (CCV_TRACE).
  input  logic clk,
  input  logic clk_free,
  input  logic rst_n,
  input  logic kill_valid,
  input  logic [31:0] kill_warp_mask,
  input  logic [1:0] kill_epoch,
  output logic kill_ack,
  output logic [1:0] kill_ack_epoch,
  output logic sleep_ok,
  input  logic [48:0] csr_req,
  output logic [32:0] csr_rsp,
  output logic csr_credit,
  // fet -> dec, slot 0 of 8
  input  logic fet_dec_instr_s0_valid,
  input  ccv_fet_dec_instr_t fet_dec_instr_s0_payload,
  output logic fet_dec_instr_s0_credit,
  output logic fet_dec_instr_s0_stall,
  // fet -> dec, slot 1 of 8
  input  logic fet_dec_instr_s1_valid,
  input  ccv_fet_dec_instr_t fet_dec_instr_s1_payload,
  output logic fet_dec_instr_s1_credit,
  output logic fet_dec_instr_s1_stall,
  // fet -> dec, slot 2 of 8
  input  logic fet_dec_instr_s2_valid,
  input  ccv_fet_dec_instr_t fet_dec_instr_s2_payload,
  output logic fet_dec_instr_s2_credit,
  output logic fet_dec_instr_s2_stall,
  // fet -> dec, slot 3 of 8
  input  logic fet_dec_instr_s3_valid,
  input  ccv_fet_dec_instr_t fet_dec_instr_s3_payload,
  output logic fet_dec_instr_s3_credit,
  output logic fet_dec_instr_s3_stall,
  // fet -> dec, slot 4 of 8
  input  logic fet_dec_instr_s4_valid,
  input  ccv_fet_dec_instr_t fet_dec_instr_s4_payload,
  output logic fet_dec_instr_s4_credit,
  output logic fet_dec_instr_s4_stall,
  // fet -> dec, slot 5 of 8
  input  logic fet_dec_instr_s5_valid,
  input  ccv_fet_dec_instr_t fet_dec_instr_s5_payload,
  output logic fet_dec_instr_s5_credit,
  output logic fet_dec_instr_s5_stall,
  // fet -> dec, slot 6 of 8
  input  logic fet_dec_instr_s6_valid,
  input  ccv_fet_dec_instr_t fet_dec_instr_s6_payload,
  output logic fet_dec_instr_s6_credit,
  output logic fet_dec_instr_s6_stall,
  // fet -> dec, slot 7 of 8
  input  logic fet_dec_instr_s7_valid,
  input  ccv_fet_dec_instr_t fet_dec_instr_s7_payload,
  output logic fet_dec_instr_s7_credit,
  output logic fet_dec_instr_s7_stall,
  input  logic fet_dec_instr_wake,
  // dec -> ooe, slot 0 of 6
  output logic dec_ooe_uop_s0_valid,
  output ccv_dec_ooe_uop_t dec_ooe_uop_s0_payload,
  input  logic dec_ooe_uop_s0_credit,
  input  logic dec_ooe_uop_s0_stall,
  // dec -> ooe, slot 1 of 6
  output logic dec_ooe_uop_s1_valid,
  output ccv_dec_ooe_uop_t dec_ooe_uop_s1_payload,
  input  logic dec_ooe_uop_s1_credit,
  input  logic dec_ooe_uop_s1_stall,
  // dec -> ooe, slot 2 of 6
  output logic dec_ooe_uop_s2_valid,
  output ccv_dec_ooe_uop_t dec_ooe_uop_s2_payload,
  input  logic dec_ooe_uop_s2_credit,
  input  logic dec_ooe_uop_s2_stall,
  // dec -> ooe, slot 3 of 6
  output logic dec_ooe_uop_s3_valid,
  output ccv_dec_ooe_uop_t dec_ooe_uop_s3_payload,
  input  logic dec_ooe_uop_s3_credit,
  input  logic dec_ooe_uop_s3_stall,
  // dec -> ooe, slot 4 of 6
  output logic dec_ooe_uop_s4_valid,
  output ccv_dec_ooe_uop_t dec_ooe_uop_s4_payload,
  input  logic dec_ooe_uop_s4_credit,
  input  logic dec_ooe_uop_s4_stall,
  // dec -> ooe, slot 5 of 6
  output logic dec_ooe_uop_s5_valid,
  output ccv_dec_ooe_uop_t dec_ooe_uop_s5_payload,
  input  logic dec_ooe_uop_s5_credit,
  input  logic dec_ooe_uop_s5_stall,
  output logic dec_ooe_uop_wake
`ifdef CCV_TRACE
  , input  logic [63:0] fet_dec_instr_s0_tid
  , input  logic [63:0] fet_dec_instr_s1_tid
  , input  logic [63:0] fet_dec_instr_s2_tid
  , input  logic [63:0] fet_dec_instr_s3_tid
  , input  logic [63:0] fet_dec_instr_s4_tid
  , input  logic [63:0] fet_dec_instr_s5_tid
  , input  logic [63:0] fet_dec_instr_s6_tid
  , input  logic [63:0] fet_dec_instr_s7_tid
  , output logic [63:0] dec_ooe_uop_s0_tid
  , output logic [63:0] dec_ooe_uop_s1_tid
  , output logic [63:0] dec_ooe_uop_s2_tid
  , output logic [63:0] dec_ooe_uop_s3_tid
  , output logic [63:0] dec_ooe_uop_s4_tid
  , output logic [63:0] dec_ooe_uop_s5_tid
`endif
