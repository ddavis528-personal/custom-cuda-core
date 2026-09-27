// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// STUB for ccv_exb: never sends, never consumes, never stalls.
// That is protocol-legal on every channel -- no valid means no
// credit is owed -- so the top elaborates and simulates with every
// checker quiet. Common-port handshakes (kill, CSR) have no
// specified semantics yet, so outputs sit at their inactive value.
// It has its clock gate all the same, tied open, and clk_gated is
// that gate's own report (docs/clock-gate.md).
//
// Replaced at 4c by real RTL with the SAME module name, including
// the same generated port list; the swap is a file-list change.
`include "ccv_interfaces.svh"

// A stub reads none of its inputs, by definition.
/* verilator lint_off UNUSEDSIGNAL */
module ccv_exb (
  `include "ccv_exb_ports.svh"
);
  // The block's clock gate: ctech ICG, sleep policy, wake path. Tied
  // never to close -- cg_override -- until the block has idle logic;
  // then these ties become its quiesced, stalled and wake. quiesced:
  // a stub holds nothing, so it is always quiesced.
  logic gclk, cg_gated;
  ccv_clk_gate u_cg (
    .clk        (core_clk),
    .rst_n      (rst_n),
    .quiesced   (1'b1),
    .stalled    (1'b0),
    .wake       (1'b0),
    .cg_override(1'b1),
    .te         (1'b0),
    .gclk       (gclk),
    .gated      (cg_gated)
  );
`ifdef CCV_CHECK
  assign clk_gated = cg_gated;
`endif
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign mlc_exb_req_credit = '0;
  assign mlc_exb_req_stall = '0;
  assign exb_mlc_rsp_valid = '0;
  assign exb_mlc_rsp_payload = '0;
  assign exb_mlc_rsp_wake = '0;
`ifdef CCV_TRACE
  assign exb_mlc_rsp_tid = '0;
`endif
  assign exb_ext_out_valid = '0;
  assign exb_ext_out_payload = '0;
  assign exb_ext_out_wake = '0;
`ifdef CCV_TRACE
  assign exb_ext_out_tid = '0;
`endif
  assign ext_exb_in_credit = '0;
  assign ext_exb_in_stall = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
