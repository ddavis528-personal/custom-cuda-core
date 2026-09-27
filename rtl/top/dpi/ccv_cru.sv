// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_cru: the C++ skeleton's functional stub, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (380 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (141 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_cru (
  `include "ccv_cru_ports.svh"
);
  // The block's clock gate: ctech ICG, sleep policy, wake path. Tied
  // never to close -- cg_override -- until the block has idle logic;
  // then these ties become its quiesced, stalled and wake. quiesced:
  // a C++ block's idleness is not visible here.
  logic gclk, cg_gated;
  ccv_clk_gate u_cg (
    .clk        (core_clk),
    .rst_n      (rst_n),
    .quiesced   (1'b0),
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
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_cru(
    input int h, input longint cyc, input bit rst,
    input bit [379:0] sample, output bit [140:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [140:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  // On the gate's clock, as a real block runs. No C++ block sleeps
  // yet (Q-33), so the gate is tied open and gclk is core_clk's
  // edges through the ctech ICG.
  always @(posedge gclk) begin
    ccv_dpi_cycle_cru(h, cyc, !rst_n, {
      cru_rau_cfg_tid, cru_rau_cfg_stall, cru_rau_cfg_credit,
      cru_rau_cfg_payload, cru_rau_cfg_valid, ooe_cru_fault_tid,
      ooe_cru_fault_stall, ooe_cru_fault_credit, ooe_cru_fault_payload,
      ooe_cru_fault_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    cru_rau_cfg_tid, cru_rau_cfg_payload, cru_rau_cfg_valid,
    ooe_cru_fault_stall, ooe_cru_fault_credit
  } = skew ? q2 : q;
`endif
  assign csr_reqs = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign cru_rau_cfg_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
