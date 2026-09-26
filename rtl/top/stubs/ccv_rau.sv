// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// STUB for ccv_rau: never sends, never consumes, never stalls.
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
module ccv_rau (
  `include "ccv_rau_ports.svh"
);
  assign kill_valid = '0;
  assign kill_warp_mask = '0;
  assign kill_epoch = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
`ifdef CCV_CHECK
  assign clk_gated = '0;
`endif
  assign rau_fet_launch_valid = '0;
  assign rau_fet_launch_payload = '0;
  assign rau_fet_launch_wake = '0;
`ifdef CCV_TRACE
  assign rau_fet_launch_tid = '0;
`endif
  assign rau_ooe_alloc_valid = '0;
  assign rau_ooe_alloc_payload = '0;
  assign rau_ooe_alloc_wake = '0;
`ifdef CCV_TRACE
  assign rau_ooe_alloc_tid = '0;
`endif
  assign ooe_rau_status_credit = '0;
  assign ooe_rau_status_stall = '0;
  assign rau_ooe_demote_valid = '0;
  assign rau_ooe_demote_payload = '0;
  assign rau_ooe_demote_wake = '0;
`ifdef CCV_TRACE
  assign rau_ooe_demote_tid = '0;
`endif
  assign ooe_rau_drained_credit = '0;
  assign ooe_rau_drained_stall = '0;
  assign rau_rcu_mig_valid = '0;
  assign rau_rcu_mig_payload = '0;
  assign rau_rcu_mig_wake = '0;
`ifdef CCV_TRACE
  assign rau_rcu_mig_tid = '0;
`endif
  assign rau_fet_mig_valid = '0;
  assign rau_fet_mig_payload = '0;
  assign rau_fet_mig_wake = '0;
`ifdef CCV_TRACE
  assign rau_fet_mig_tid = '0;
`endif
  assign pca_rau_mig_done_credit = '0;
  assign pca_rau_mig_done_stall = '0;
  assign rau_miu_cta_valid = '0;
  assign rau_miu_cta_payload = '0;
  assign rau_miu_cta_wake = '0;
`ifdef CCV_TRACE
  assign rau_miu_cta_tid = '0;
`endif
  assign rau_syu_alloc_valid = '0;
  assign rau_syu_alloc_payload = '0;
  assign rau_syu_alloc_wake = '0;
`ifdef CCV_TRACE
  assign rau_syu_alloc_tid = '0;
`endif
  assign cru_rau_cfg_credit = '0;
  assign cru_rau_cfg_stall = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
