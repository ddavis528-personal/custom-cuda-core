// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_exb: the C++ skeleton's functional stub, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (4841 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (2441 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_exb (
  `include "ccv_exb_ports.svh"
);
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_exb(
    input int h, input longint cyc, input bit rst,
    input bit [4840:0] sample, output bit [2440:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [2440:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  always @(posedge clk) begin
    ccv_dpi_cycle_exb(h, cyc, !rst_n, {
      ext_exb_in_tid, ext_exb_in_stall, ext_exb_in_credit,
      ext_exb_in_payload, ext_exb_in_valid, exb_ext_out_tid,
      exb_ext_out_stall, exb_ext_out_credit, exb_ext_out_payload,
      exb_ext_out_valid, exb_mlc_rsp_tid, exb_mlc_rsp_stall,
      exb_mlc_rsp_credit, exb_mlc_rsp_payload, exb_mlc_rsp_valid,
      mlc_exb_req_tid, mlc_exb_req_stall, mlc_exb_req_credit,
      mlc_exb_req_payload, mlc_exb_req_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    ext_exb_in_stall, ext_exb_in_credit, exb_ext_out_tid,
    exb_ext_out_payload, exb_ext_out_valid, exb_mlc_rsp_tid,
    exb_mlc_rsp_payload, exb_mlc_rsp_valid, mlc_exb_req_stall,
    mlc_exb_req_credit
  } = skew ? q2 : q;
`endif
  assign sleep_ok = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign exb_mlc_rsp_wake = '0;
  assign exb_ext_out_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
