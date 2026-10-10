// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// STUB for ccv_dcu: never sends, never consumes, never stalls.
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
module ccv_dcu (
  `include "ccv_dcu_ports.svh"
);
  // The block's clock gate: ctech ICG, sleep policy, wake path. Tied
  // never to close -- cg_override -- until the block has idle logic;
  // then these ties become its quiesced, stalled and wake. quiesced:
  // a stub holds nothing, so it is always quiesced.
  // The thresholds and the override are CSRs (Q-47): tied to their
  // reset values until the block decodes its own.
  localparam int CG_HW = ccv_prov_pkg::CCV_CG_HYST_W;
  logic gclk, cg_gated;
  ccv_common_clk u_cg (
    .clk         (core_clk),
    .rst_n       (rst_n),
    .quiesced    (1'b1),
    .stalled     (1'b0),
    .hyst_quiesce(CG_HW'(ccv_prov_pkg::CCV_CG_HYST_QUIESCE)),
    .hyst_stall  (CG_HW'(ccv_prov_pkg::CCV_CG_HYST_STALL)),
    .wake        (1'b0),
    .cg_override (1'b1),
    .te          (1'b0),
    .gclk        (gclk),
    .gated       (cg_gated)
  );
`ifdef CCV_CHECK
  assign clk_gated = cg_gated;
`endif
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign miu_dcu_req_s0_credit = '0;
  assign miu_dcu_req_s0_stall = '0;
  assign miu_dcu_req_s1_credit = '0;
  assign miu_dcu_req_s1_stall = '0;
  assign miu_dcu_req_s2_credit = '0;
  assign miu_dcu_req_s2_stall = '0;
  assign miu_dcu_req_s3_credit = '0;
  assign miu_dcu_req_s3_stall = '0;
  assign dcu_miu_rsp_s0_valid = '0;
  assign dcu_miu_rsp_s0_payload = '0;
  assign dcu_miu_rsp_s1_valid = '0;
  assign dcu_miu_rsp_s1_payload = '0;
  assign dcu_miu_rsp_s2_valid = '0;
  assign dcu_miu_rsp_s2_payload = '0;
  assign dcu_miu_rsp_s3_valid = '0;
  assign dcu_miu_rsp_s3_payload = '0;
  assign dcu_miu_rsp_wake = '0;
`ifdef CCV_TRACE
  assign dcu_miu_rsp_s0_tid = '0;
`endif
`ifdef CCV_TRACE
  assign dcu_miu_rsp_s1_tid = '0;
`endif
`ifdef CCV_TRACE
  assign dcu_miu_rsp_s2_tid = '0;
`endif
`ifdef CCV_TRACE
  assign dcu_miu_rsp_s3_tid = '0;
`endif
  assign dcu_mlc_req_valid = '0;
  assign dcu_mlc_req_payload = '0;
  assign dcu_mlc_req_wake = '0;
`ifdef CCV_TRACE
  assign dcu_mlc_req_tid = '0;
`endif
  assign mlc_dcu_rsp_credit = '0;
  assign mlc_dcu_rsp_stall = '0;
  assign mlc_dcu_probe_credit = '0;
  assign mlc_dcu_probe_stall = '0;
  assign dcu_mlc_probe_ack_valid = '0;
  assign dcu_mlc_probe_ack_payload = '0;
  assign dcu_mlc_probe_ack_wake = '0;
`ifdef CCV_TRACE
  assign dcu_mlc_probe_ack_tid = '0;
`endif
endmodule
/* verilator lint_on UNUSEDSIGNAL */
