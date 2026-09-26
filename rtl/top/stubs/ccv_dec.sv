// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// STUB for ccv_dec: never sends, never consumes, never stalls.
// That is protocol-legal on every channel -- no valid means no
// credit is owed -- so the top elaborates and simulates with every
// checker quiet. Common-port handshakes (kill, sleep, CSR) have no
// specified semantics yet, so outputs sit at their inactive value:
// sleep_ok low keeps the block's clock running.
//
// Replaced at 4c by real RTL with the SAME module name, including
// the same generated port list; the swap is a file-list change.
`include "ccv_interfaces.svh"

// A stub reads none of its inputs, by definition.
/* verilator lint_off UNUSEDSIGNAL */
module ccv_dec (
  `include "ccv_dec_ports.svh"
);
  assign kill_ack = '0;
  assign kill_ack_epoch = '0;
  assign sleep_ok = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign fet_dec_instr_s0_credit = '0;
  assign fet_dec_instr_s0_stall = '0;
  assign fet_dec_instr_s1_credit = '0;
  assign fet_dec_instr_s1_stall = '0;
  assign fet_dec_instr_s2_credit = '0;
  assign fet_dec_instr_s2_stall = '0;
  assign fet_dec_instr_s3_credit = '0;
  assign fet_dec_instr_s3_stall = '0;
  assign fet_dec_instr_s4_credit = '0;
  assign fet_dec_instr_s4_stall = '0;
  assign fet_dec_instr_s5_credit = '0;
  assign fet_dec_instr_s5_stall = '0;
  assign fet_dec_instr_s6_credit = '0;
  assign fet_dec_instr_s6_stall = '0;
  assign fet_dec_instr_s7_credit = '0;
  assign fet_dec_instr_s7_stall = '0;
  assign dec_ooe_uop_s0_valid = '0;
  assign dec_ooe_uop_s0_payload = '0;
  assign dec_ooe_uop_s1_valid = '0;
  assign dec_ooe_uop_s1_payload = '0;
  assign dec_ooe_uop_s2_valid = '0;
  assign dec_ooe_uop_s2_payload = '0;
  assign dec_ooe_uop_s3_valid = '0;
  assign dec_ooe_uop_s3_payload = '0;
  assign dec_ooe_uop_s4_valid = '0;
  assign dec_ooe_uop_s4_payload = '0;
  assign dec_ooe_uop_s5_valid = '0;
  assign dec_ooe_uop_s5_payload = '0;
  assign dec_ooe_uop_wake = '0;
`ifdef CCV_TRACE
  assign dec_ooe_uop_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign dec_ooe_uop_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign dec_ooe_uop_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign dec_ooe_uop_s3_tid = '0;
`endif
`ifdef CCV_TRACE
  assign dec_ooe_uop_s4_tid = '0;
`endif
`ifdef CCV_TRACE
  assign dec_ooe_uop_s5_tid = '0;
`endif
endmodule
/* verilator lint_on UNUSEDSIGNAL */
