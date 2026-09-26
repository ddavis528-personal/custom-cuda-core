// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// STUB for ccv_ooe: never sends, never consumes, never stalls.
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
module ccv_ooe (
  `include "ccv_ooe_ports.svh"
);
  assign kill_ack = '0;
  assign kill_ack_epoch = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
`ifdef CCV_CHECK
  assign clk_gated = '0;
`endif
  assign dec_ooe_uop_s0_credit = '0;
  assign dec_ooe_uop_s0_stall = '0;
  assign dec_ooe_uop_s1_credit = '0;
  assign dec_ooe_uop_s1_stall = '0;
  assign dec_ooe_uop_s2_credit = '0;
  assign dec_ooe_uop_s2_stall = '0;
  assign dec_ooe_uop_s3_credit = '0;
  assign dec_ooe_uop_s3_stall = '0;
  assign dec_ooe_uop_s4_credit = '0;
  assign dec_ooe_uop_s4_stall = '0;
  assign dec_ooe_uop_s5_credit = '0;
  assign dec_ooe_uop_s5_stall = '0;
  assign ooe_rcu_issue_s0_valid = '0;
  assign ooe_rcu_issue_s0_payload = '0;
  assign ooe_rcu_issue_s1_valid = '0;
  assign ooe_rcu_issue_s1_payload = '0;
  assign ooe_rcu_issue_s2_valid = '0;
  assign ooe_rcu_issue_s2_payload = '0;
  assign ooe_rcu_issue_s3_valid = '0;
  assign ooe_rcu_issue_s3_payload = '0;
  assign ooe_rcu_issue_wake = '0;
`ifdef CCV_TRACE
  assign ooe_rcu_issue_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign ooe_rcu_issue_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign ooe_rcu_issue_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign ooe_rcu_issue_s3_tid = '0;
`endif
  assign rcu_ooe_done_s0_credit = '0;
  assign rcu_ooe_done_s0_stall = '0;
  assign rcu_ooe_done_s1_credit = '0;
  assign rcu_ooe_done_s1_stall = '0;
  assign rcu_ooe_done_s2_credit = '0;
  assign rcu_ooe_done_s2_stall = '0;
  assign rcu_ooe_done_s3_credit = '0;
  assign rcu_ooe_done_s3_stall = '0;
  assign ooe_miu_memop_s0_valid = '0;
  assign ooe_miu_memop_s0_payload = '0;
  assign ooe_miu_memop_s1_valid = '0;
  assign ooe_miu_memop_s1_payload = '0;
  assign ooe_miu_memop_s2_valid = '0;
  assign ooe_miu_memop_s2_payload = '0;
  assign ooe_miu_memop_s3_valid = '0;
  assign ooe_miu_memop_s3_payload = '0;
  assign ooe_miu_memop_wake = '0;
`ifdef CCV_TRACE
  assign ooe_miu_memop_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign ooe_miu_memop_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign ooe_miu_memop_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign ooe_miu_memop_s3_tid = '0;
`endif
  assign miu_ooe_cmpl_s0_credit = '0;
  assign miu_ooe_cmpl_s0_stall = '0;
  assign miu_ooe_cmpl_s1_credit = '0;
  assign miu_ooe_cmpl_s1_stall = '0;
  assign miu_ooe_cmpl_s2_credit = '0;
  assign miu_ooe_cmpl_s2_stall = '0;
  assign miu_ooe_cmpl_s3_credit = '0;
  assign miu_ooe_cmpl_s3_stall = '0;
  assign ooe_miu_retire_s0_valid = '0;
  assign ooe_miu_retire_s0_payload = '0;
  assign ooe_miu_retire_s1_valid = '0;
  assign ooe_miu_retire_s1_payload = '0;
  assign ooe_miu_retire_s2_valid = '0;
  assign ooe_miu_retire_s2_payload = '0;
  assign ooe_miu_retire_s3_valid = '0;
  assign ooe_miu_retire_s3_payload = '0;
  assign ooe_miu_retire_wake = '0;
`ifdef CCV_TRACE
  assign ooe_miu_retire_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign ooe_miu_retire_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign ooe_miu_retire_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign ooe_miu_retire_s3_tid = '0;
`endif
  assign ooe_fet_redirect_valid = '0;
  assign ooe_fet_redirect_payload = '0;
  assign ooe_fet_redirect_wake = '0;
`ifdef CCV_TRACE
  assign ooe_fet_redirect_tid = '0;
`endif
  assign rau_ooe_alloc_credit = '0;
  assign rau_ooe_alloc_stall = '0;
  assign ooe_rau_status_valid = '0;
  assign ooe_rau_status_payload = '0;
  assign ooe_rau_status_wake = '0;
`ifdef CCV_TRACE
  assign ooe_rau_status_tid = '0;
`endif
  assign rau_ooe_demote_credit = '0;
  assign rau_ooe_demote_stall = '0;
  assign ooe_rau_drained_valid = '0;
  assign ooe_rau_drained_payload = '0;
  assign ooe_rau_drained_wake = '0;
`ifdef CCV_TRACE
  assign ooe_rau_drained_tid = '0;
`endif
  assign ooe_syu_bar_valid = '0;
  assign ooe_syu_bar_payload = '0;
  assign ooe_syu_bar_wake = '0;
`ifdef CCV_TRACE
  assign ooe_syu_bar_tid = '0;
`endif
  assign syu_ooe_rel_credit = '0;
  assign syu_ooe_rel_stall = '0;
  assign ooe_cru_fault_valid = '0;
  assign ooe_cru_fault_payload = '0;
  assign ooe_cru_fault_wake = '0;
`ifdef CCV_TRACE
  assign ooe_cru_fault_tid = '0;
`endif
endmodule
/* verilator lint_on UNUSEDSIGNAL */
