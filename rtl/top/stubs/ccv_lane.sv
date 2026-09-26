// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// STUB for ccv_lane: never sends, never consumes, never stalls.
// That is protocol-legal on every channel -- no valid means no
// credit is owed -- so the top elaborates and simulates with every
// checker quiet. Common-port handshakes (kill, CSR) have no
// specified semantics yet, so outputs sit at their inactive value.
// A stub holds no state, so it has no clock gate: clk_gated reports
// the gate open. Real RTL gates core_clk inside itself (CCV-L22).
//
// Replaced at 4c by real RTL with the SAME module name, including
// the same generated port list; the swap is a file-list change.
`include "ccv_interfaces.svh"

// A stub reads none of its inputs, by definition.
/* verilator lint_off UNUSEDSIGNAL */
module ccv_lane (
  `include "ccv_lane_ports.svh"
);
  assign csr_rsp = '0;
  assign csr_credit = '0;
`ifdef CCV_CHECK
  assign clk_gated = '0;
`endif
  assign rcu_lane_ops_s0_credit = '0;
  assign rcu_lane_ops_s0_stall = '0;
  assign rcu_lane_ops_s1_credit = '0;
  assign rcu_lane_ops_s1_stall = '0;
  assign rcu_lane_ops_s2_credit = '0;
  assign rcu_lane_ops_s2_stall = '0;
  assign rcu_lane_ops_s3_credit = '0;
  assign rcu_lane_ops_s3_stall = '0;
  assign lane_rcu_res_s0_valid = '0;
  assign lane_rcu_res_s0_payload = '0;
  assign lane_rcu_res_s1_valid = '0;
  assign lane_rcu_res_s1_payload = '0;
  assign lane_rcu_res_s2_valid = '0;
  assign lane_rcu_res_s2_payload = '0;
  assign lane_rcu_res_s3_valid = '0;
  assign lane_rcu_res_s3_payload = '0;
  assign lane_rcu_res_wake = '0;
`ifdef CCV_TRACE
  assign lane_rcu_res_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign lane_rcu_res_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign lane_rcu_res_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign lane_rcu_res_s3_tid = '0;
`endif
endmodule
/* verilator lint_on UNUSEDSIGNAL */
