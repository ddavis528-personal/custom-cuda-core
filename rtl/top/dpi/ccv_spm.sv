// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_spm: the C++ skeleton's functional stub, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (10576 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (4400 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_spm (
  `include "ccv_spm_ports.svh"
);
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_spm(
    input int h, input longint cyc, input bit rst,
    input bit [10575:0] sample, output bit [4399:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [4399:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  // No clock gate: a C++ block never sleeps (Q-33), so it runs on
  // core_clk, which is what a real block's gate would pass when open.
  always @(posedge core_clk) begin
    ccv_dpi_cycle_spm(h, cyc, !rst_n, {
      spm_miu_rsp_s3_tid, spm_miu_rsp_s2_tid, spm_miu_rsp_s1_tid,
      spm_miu_rsp_s0_tid, spm_miu_rsp_s3_stall, spm_miu_rsp_s3_credit,
      spm_miu_rsp_s3_payload, spm_miu_rsp_s3_valid, spm_miu_rsp_s2_stall,
      spm_miu_rsp_s2_credit, spm_miu_rsp_s2_payload, spm_miu_rsp_s2_valid,
      spm_miu_rsp_s1_stall, spm_miu_rsp_s1_credit, spm_miu_rsp_s1_payload,
      spm_miu_rsp_s1_valid, spm_miu_rsp_s0_stall, spm_miu_rsp_s0_credit,
      spm_miu_rsp_s0_payload, spm_miu_rsp_s0_valid, miu_spm_req_s3_tid,
      miu_spm_req_s2_tid, miu_spm_req_s1_tid, miu_spm_req_s0_tid,
      miu_spm_req_s3_stall, miu_spm_req_s3_credit, miu_spm_req_s3_payload,
      miu_spm_req_s3_valid, miu_spm_req_s2_stall, miu_spm_req_s2_credit,
      miu_spm_req_s2_payload, miu_spm_req_s2_valid, miu_spm_req_s1_stall,
      miu_spm_req_s1_credit, miu_spm_req_s1_payload, miu_spm_req_s1_valid,
      miu_spm_req_s0_stall, miu_spm_req_s0_credit, miu_spm_req_s0_payload,
      miu_spm_req_s0_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    spm_miu_rsp_s3_tid, spm_miu_rsp_s2_tid, spm_miu_rsp_s1_tid,
    spm_miu_rsp_s0_tid, spm_miu_rsp_s3_payload, spm_miu_rsp_s3_valid,
    spm_miu_rsp_s2_payload, spm_miu_rsp_s2_valid, spm_miu_rsp_s1_payload,
    spm_miu_rsp_s1_valid, spm_miu_rsp_s0_payload, spm_miu_rsp_s0_valid,
    miu_spm_req_s3_stall, miu_spm_req_s3_credit, miu_spm_req_s2_stall,
    miu_spm_req_s2_credit, miu_spm_req_s1_stall, miu_spm_req_s1_credit,
    miu_spm_req_s0_stall, miu_spm_req_s0_credit
  } = skew ? q2 : q;
`endif
  assign kill_ack = '0;
  assign kill_ack_epoch = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
`ifdef CCV_CHECK
  assign clk_gated = '0;
`endif
  assign spm_miu_rsp_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
