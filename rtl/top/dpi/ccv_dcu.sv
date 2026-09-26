// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_dcu: the C++ skeleton's functional stub, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (12962 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (6631 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_dcu (
  `include "ccv_dcu_ports.svh"
);
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_dcu(
    input int h, input longint cyc, input bit rst,
    input bit [12961:0] sample, output bit [6630:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [6630:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  // No clock gate: a C++ block never sleeps (Q-33), so it runs on
  // core_clk, which is what a real block's gate would pass when open.
  always @(posedge core_clk) begin
    ccv_dpi_cycle_dcu(h, cyc, !rst_n, {
      dcu_mlc_probe_ack_tid, dcu_mlc_probe_ack_stall, dcu_mlc_probe_ack_credit,
      dcu_mlc_probe_ack_payload, dcu_mlc_probe_ack_valid, mlc_dcu_probe_tid,
      mlc_dcu_probe_stall, mlc_dcu_probe_credit, mlc_dcu_probe_payload,
      mlc_dcu_probe_valid, mlc_dcu_rsp_tid, mlc_dcu_rsp_stall,
      mlc_dcu_rsp_credit, mlc_dcu_rsp_payload, mlc_dcu_rsp_valid,
      dcu_mlc_req_tid, dcu_mlc_req_stall, dcu_mlc_req_credit,
      dcu_mlc_req_payload, dcu_mlc_req_valid, dcu_miu_rsp_s3_tid,
      dcu_miu_rsp_s2_tid, dcu_miu_rsp_s1_tid, dcu_miu_rsp_s0_tid,
      dcu_miu_rsp_s3_stall, dcu_miu_rsp_s3_credit, dcu_miu_rsp_s3_payload,
      dcu_miu_rsp_s3_valid, dcu_miu_rsp_s2_stall, dcu_miu_rsp_s2_credit,
      dcu_miu_rsp_s2_payload, dcu_miu_rsp_s2_valid, dcu_miu_rsp_s1_stall,
      dcu_miu_rsp_s1_credit, dcu_miu_rsp_s1_payload, dcu_miu_rsp_s1_valid,
      dcu_miu_rsp_s0_stall, dcu_miu_rsp_s0_credit, dcu_miu_rsp_s0_payload,
      dcu_miu_rsp_s0_valid, miu_dcu_req_s3_tid, miu_dcu_req_s2_tid,
      miu_dcu_req_s1_tid, miu_dcu_req_s0_tid, miu_dcu_req_s3_stall,
      miu_dcu_req_s3_credit, miu_dcu_req_s3_payload, miu_dcu_req_s3_valid,
      miu_dcu_req_s2_stall, miu_dcu_req_s2_credit, miu_dcu_req_s2_payload,
      miu_dcu_req_s2_valid, miu_dcu_req_s1_stall, miu_dcu_req_s1_credit,
      miu_dcu_req_s1_payload, miu_dcu_req_s1_valid, miu_dcu_req_s0_stall,
      miu_dcu_req_s0_credit, miu_dcu_req_s0_payload, miu_dcu_req_s0_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    dcu_mlc_probe_ack_tid, dcu_mlc_probe_ack_payload, dcu_mlc_probe_ack_valid,
    mlc_dcu_probe_stall, mlc_dcu_probe_credit, mlc_dcu_rsp_stall,
    mlc_dcu_rsp_credit, dcu_mlc_req_tid, dcu_mlc_req_payload,
    dcu_mlc_req_valid, dcu_miu_rsp_s3_tid, dcu_miu_rsp_s2_tid,
    dcu_miu_rsp_s1_tid, dcu_miu_rsp_s0_tid, dcu_miu_rsp_s3_payload,
    dcu_miu_rsp_s3_valid, dcu_miu_rsp_s2_payload, dcu_miu_rsp_s2_valid,
    dcu_miu_rsp_s1_payload, dcu_miu_rsp_s1_valid, dcu_miu_rsp_s0_payload,
    dcu_miu_rsp_s0_valid, miu_dcu_req_s3_stall, miu_dcu_req_s3_credit,
    miu_dcu_req_s2_stall, miu_dcu_req_s2_credit, miu_dcu_req_s1_stall,
    miu_dcu_req_s1_credit, miu_dcu_req_s0_stall, miu_dcu_req_s0_credit
  } = skew ? q2 : q;
`endif
  assign csr_rsp = '0;
  assign csr_credit = '0;
`ifdef CCV_CHECK
  assign clk_gated = '0;
`endif
  assign dcu_miu_rsp_wake = '0;
  assign dcu_mlc_req_wake = '0;
  assign dcu_mlc_probe_ack_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
