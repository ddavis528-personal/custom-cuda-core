// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_mlc: the C++ skeleton's functional stub, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (6982 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (3465 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_mlc (
  `include "ccv_mlc_ports.svh"
);
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_mlc(
    input int h, input longint cyc, input bit rst,
    input bit [6981:0] sample, output bit [3464:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [3464:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  always @(posedge clk) begin
    ccv_dpi_cycle_mlc(h, cyc, !rst_n, {
      exb_mlc_rsp_tid, exb_mlc_rsp_stall, exb_mlc_rsp_credit,
      exb_mlc_rsp_payload, exb_mlc_rsp_valid, mlc_exb_req_tid,
      mlc_exb_req_stall, mlc_exb_req_credit, mlc_exb_req_payload,
      mlc_exb_req_valid, mlc_fet_ifill_rsp_tid, mlc_fet_ifill_rsp_stall,
      mlc_fet_ifill_rsp_credit, mlc_fet_ifill_rsp_payload, mlc_fet_ifill_rsp_valid,
      fet_mlc_ifill_tid, fet_mlc_ifill_stall, fet_mlc_ifill_credit,
      fet_mlc_ifill_payload, fet_mlc_ifill_valid, dcu_mlc_probe_ack_tid,
      dcu_mlc_probe_ack_stall, dcu_mlc_probe_ack_credit, dcu_mlc_probe_ack_payload,
      dcu_mlc_probe_ack_valid, mlc_dcu_probe_tid, mlc_dcu_probe_stall,
      mlc_dcu_probe_credit, mlc_dcu_probe_payload, mlc_dcu_probe_valid,
      mlc_dcu_rsp_tid, mlc_dcu_rsp_stall, mlc_dcu_rsp_credit,
      mlc_dcu_rsp_payload, mlc_dcu_rsp_valid, dcu_mlc_req_tid,
      dcu_mlc_req_stall, dcu_mlc_req_credit, dcu_mlc_req_payload,
      dcu_mlc_req_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    exb_mlc_rsp_stall, exb_mlc_rsp_credit, mlc_exb_req_tid,
    mlc_exb_req_payload, mlc_exb_req_valid, mlc_fet_ifill_rsp_tid,
    mlc_fet_ifill_rsp_payload, mlc_fet_ifill_rsp_valid, fet_mlc_ifill_stall,
    fet_mlc_ifill_credit, dcu_mlc_probe_ack_stall, dcu_mlc_probe_ack_credit,
    mlc_dcu_probe_tid, mlc_dcu_probe_payload, mlc_dcu_probe_valid,
    mlc_dcu_rsp_tid, mlc_dcu_rsp_payload, mlc_dcu_rsp_valid,
    dcu_mlc_req_stall, dcu_mlc_req_credit
  } = skew ? q2 : q;
`endif
  assign sleep_ok = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign mlc_dcu_rsp_wake = '0;
  assign mlc_dcu_probe_wake = '0;
  assign mlc_fet_ifill_rsp_wake = '0;
  assign mlc_exb_req_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
