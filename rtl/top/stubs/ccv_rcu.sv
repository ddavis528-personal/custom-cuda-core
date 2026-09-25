// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// STUB for ccv_rcu: never sends, never consumes, never stalls.
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
module ccv_rcu (
  `include "ccv_rcu_ports.svh"
);
  assign kill_ack = '0;
  assign kill_ack_epoch = '0;
  assign sleep_ok = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign ooe_rcu_issue_credit = '0;
  assign ooe_rcu_issue_stall = '0;
  assign rcu_lane_ops_valid = '0;
  /* verilator lint_off WIDTHCONCAT */
  assign rcu_lane_ops_payload = '0;  // 14080 bits, intended
  /* verilator lint_on WIDTHCONCAT */
  assign rcu_lane_ops_wake = '0;
`ifdef CCV_TRACE
  assign rcu_lane_ops_tid = '0;
`endif
  assign lane_rcu_res_credit = '0;
  assign lane_rcu_res_stall = '0;
  assign rcu_ooe_done_valid = '0;
  assign rcu_ooe_done_payload = '0;
  assign rcu_ooe_done_wake = '0;
`ifdef CCV_TRACE
  assign rcu_ooe_done_tid = '0;
`endif
  assign rcu_miu_addr_valid = '0;
  /* verilator lint_off WIDTHCONCAT */
  assign rcu_miu_addr_payload = '0;  // 8604 bits, intended
  /* verilator lint_on WIDTHCONCAT */
  assign rcu_miu_addr_wake = '0;
`ifdef CCV_TRACE
  assign rcu_miu_addr_tid = '0;
`endif
  assign miu_rcu_data_credit = '0;
  assign miu_rcu_data_stall = '0;
  assign rau_rcu_mig_credit = '0;
  assign rau_rcu_mig_stall = '0;
  assign rcu_pca_mig_valid = '0;
  assign rcu_pca_mig_payload = '0;
  assign rcu_pca_mig_wake = '0;
`ifdef CCV_TRACE
  assign rcu_pca_mig_tid = '0;
`endif
  assign pca_rcu_mig_credit = '0;
  assign pca_rcu_mig_stall = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
