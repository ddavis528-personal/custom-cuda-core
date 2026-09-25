// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// STUB for ccv_spm: never sends, never consumes, never stalls.
// That is protocol-legal on every channel -- no valid means no
// credit is owed -- so the top elaborates and simulates with every
// checker quiet. Common-port handshakes (kill, sleep, CSR) have no
// specified semantics yet, so outputs sit at their inactive value.
//
// Replaced at 4c by real RTL with the SAME module name, including
// the same generated port list; the swap is a file-list change.
`include "ccv_interfaces.svh"

// A stub reads none of its inputs, by definition.
/* verilator lint_off UNUSEDSIGNAL */
module ccv_spm (
  `include "ccv_spm_ports.svh"
);
  assign kill_ack = '0;
  assign sleep_ok = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign miu_spm_req_credit = '0;
  assign miu_spm_req_stall = '0;
  assign spm_miu_rsp_valid = '0;
  assign spm_miu_rsp_payload = '0;
`ifdef CCV_TRACE
  assign spm_miu_rsp_tid = '0;
`endif
endmodule
/* verilator lint_on UNUSEDSIGNAL */
