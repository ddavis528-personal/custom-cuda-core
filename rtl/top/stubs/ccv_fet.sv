// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// STUB for ccv_fet: never sends, never consumes, never stalls.
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
module ccv_fet (
  `include "ccv_fet_ports.svh"
);
  assign kill_ack = '0;
  assign kill_ack_epoch = '0;
  assign sleep_ok = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign fet_dec_instr_valid = '0;
  assign fet_dec_instr_payload = '0;
  assign fet_dec_instr_wake = '0;
`ifdef CCV_TRACE
  assign fet_dec_instr_tid = '0;
`endif
  assign ooe_fet_redirect_credit = '0;
  assign ooe_fet_redirect_stall = '0;
  assign fet_mlc_ifill_valid = '0;
  assign fet_mlc_ifill_payload = '0;
  assign fet_mlc_ifill_wake = '0;
`ifdef CCV_TRACE
  assign fet_mlc_ifill_tid = '0;
`endif
  assign mlc_fet_ifill_rsp_credit = '0;
  assign mlc_fet_ifill_rsp_stall = '0;
  assign miu_fet_itlb_credit = '0;
  assign miu_fet_itlb_stall = '0;
  assign fet_miu_itlb_req_valid = '0;
  assign fet_miu_itlb_req_payload = '0;
  assign fet_miu_itlb_req_wake = '0;
`ifdef CCV_TRACE
  assign fet_miu_itlb_req_tid = '0;
`endif
  assign rau_fet_launch_credit = '0;
  assign rau_fet_launch_stall = '0;
  assign fet_pca_mig_valid = '0;
  assign fet_pca_mig_payload = '0;
  assign fet_pca_mig_wake = '0;
`ifdef CCV_TRACE
  assign fet_pca_mig_tid = '0;
`endif
  assign pca_fet_mig_credit = '0;
  assign pca_fet_mig_stall = '0;
  assign rau_fet_mig_credit = '0;
  assign rau_fet_mig_stall = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
