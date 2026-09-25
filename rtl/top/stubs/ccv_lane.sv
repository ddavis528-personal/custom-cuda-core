// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// STUB for ccv_lane: never sends, never consumes, never stalls.
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
module ccv_lane (
  `include "ccv_lane_ports.svh"
);
  assign sleep_ok = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign rcu_lane_ops_credit = '0;
  assign rcu_lane_ops_stall = '0;
  assign lane_rcu_res_valid = '0;
  assign lane_rcu_res_payload = '0;
  assign lane_rcu_res_wake = '0;
`ifdef CCV_TRACE
  assign lane_rcu_res_tid = '0;
`endif
endmodule
/* verilator lint_on UNUSEDSIGNAL */
