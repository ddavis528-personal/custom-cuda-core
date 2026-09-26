// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_ext: the C++ skeleton's testbench end of EXTERNAL, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (2535 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (1243 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_ext (
  input  logic core_clk,
  input  logic rst_n,
  input  logic exb_ext_out_valid,
  input  ccv_exb_ext_out_t exb_ext_out_payload,
  output logic exb_ext_out_credit,
  output logic exb_ext_out_stall,
  input  logic exb_ext_out_wake,
  output logic ext_exb_in_valid,
  output ccv_ext_exb_in_t ext_exb_in_payload,
  input  logic ext_exb_in_credit,
  input  logic ext_exb_in_stall,
  output logic ext_exb_in_wake
`ifdef CCV_TRACE
  , input  logic [63:0] exb_ext_out_tid
  , output logic [63:0] ext_exb_in_tid
`endif
);
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_ext(
    input int h, input longint cyc, input bit rst,
    input bit [2534:0] sample, output bit [1242:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [1242:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  // No clock gate: a C++ block never sleeps (Q-33), so it runs on
  // core_clk, which is what a real block's gate would pass when open.
  always @(posedge core_clk) begin
    ccv_dpi_cycle_ext(h, cyc, !rst_n, {
      ext_exb_in_tid, ext_exb_in_stall, ext_exb_in_credit,
      ext_exb_in_payload, ext_exb_in_valid, exb_ext_out_tid,
      exb_ext_out_stall, exb_ext_out_credit, exb_ext_out_payload,
      exb_ext_out_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    ext_exb_in_tid, ext_exb_in_payload, ext_exb_in_valid,
    exb_ext_out_stall, exb_ext_out_credit
  } = skew ? q2 : q;
`endif
  assign ext_exb_in_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
