// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_fet: the C++ skeleton's functional stub, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (4251 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (2094 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_fet (
  `include "ccv_fet_ports.svh"
);
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_fet(
    input int h, input longint cyc, input bit rst,
    input bit [4250:0] sample, output bit [2093:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [2093:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  // No clock gate: a C++ block never sleeps (Q-33), so it runs on
  // core_clk, which is what a real block's gate would pass when open.
  always @(posedge core_clk) begin
    ccv_dpi_cycle_fet(h, cyc, !rst_n, {
      rau_fet_mig_tid, rau_fet_mig_stall, rau_fet_mig_credit,
      rau_fet_mig_payload, rau_fet_mig_valid, pca_fet_mig_tid,
      pca_fet_mig_stall, pca_fet_mig_credit, pca_fet_mig_payload,
      pca_fet_mig_valid, fet_pca_mig_tid, fet_pca_mig_stall,
      fet_pca_mig_credit, fet_pca_mig_payload, fet_pca_mig_valid,
      rau_fet_launch_tid, rau_fet_launch_stall, rau_fet_launch_credit,
      rau_fet_launch_payload, rau_fet_launch_valid, fet_miu_itlb_req_tid,
      fet_miu_itlb_req_stall, fet_miu_itlb_req_credit, fet_miu_itlb_req_payload,
      fet_miu_itlb_req_valid, miu_fet_itlb_tid, miu_fet_itlb_stall,
      miu_fet_itlb_credit, miu_fet_itlb_payload, miu_fet_itlb_valid,
      mlc_fet_ifill_rsp_tid, mlc_fet_ifill_rsp_stall, mlc_fet_ifill_rsp_credit,
      mlc_fet_ifill_rsp_payload, mlc_fet_ifill_rsp_valid, fet_mlc_ifill_tid,
      fet_mlc_ifill_stall, fet_mlc_ifill_credit, fet_mlc_ifill_payload,
      fet_mlc_ifill_valid, ooe_fet_redirect_tid, ooe_fet_redirect_stall,
      ooe_fet_redirect_credit, ooe_fet_redirect_payload, ooe_fet_redirect_valid,
      fet_dec_instr_s7_tid, fet_dec_instr_s6_tid, fet_dec_instr_s5_tid,
      fet_dec_instr_s4_tid, fet_dec_instr_s3_tid, fet_dec_instr_s2_tid,
      fet_dec_instr_s1_tid, fet_dec_instr_s0_tid, fet_dec_instr_s7_stall,
      fet_dec_instr_s7_credit, fet_dec_instr_s7_payload, fet_dec_instr_s7_valid,
      fet_dec_instr_s6_stall, fet_dec_instr_s6_credit, fet_dec_instr_s6_payload,
      fet_dec_instr_s6_valid, fet_dec_instr_s5_stall, fet_dec_instr_s5_credit,
      fet_dec_instr_s5_payload, fet_dec_instr_s5_valid, fet_dec_instr_s4_stall,
      fet_dec_instr_s4_credit, fet_dec_instr_s4_payload, fet_dec_instr_s4_valid,
      fet_dec_instr_s3_stall, fet_dec_instr_s3_credit, fet_dec_instr_s3_payload,
      fet_dec_instr_s3_valid, fet_dec_instr_s2_stall, fet_dec_instr_s2_credit,
      fet_dec_instr_s2_payload, fet_dec_instr_s2_valid, fet_dec_instr_s1_stall,
      fet_dec_instr_s1_credit, fet_dec_instr_s1_payload, fet_dec_instr_s1_valid,
      fet_dec_instr_s0_stall, fet_dec_instr_s0_credit, fet_dec_instr_s0_payload,
      fet_dec_instr_s0_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    rau_fet_mig_stall, rau_fet_mig_credit, pca_fet_mig_stall,
    pca_fet_mig_credit, fet_pca_mig_tid, fet_pca_mig_payload,
    fet_pca_mig_valid, rau_fet_launch_stall, rau_fet_launch_credit,
    fet_miu_itlb_req_tid, fet_miu_itlb_req_payload, fet_miu_itlb_req_valid,
    miu_fet_itlb_stall, miu_fet_itlb_credit, mlc_fet_ifill_rsp_stall,
    mlc_fet_ifill_rsp_credit, fet_mlc_ifill_tid, fet_mlc_ifill_payload,
    fet_mlc_ifill_valid, ooe_fet_redirect_stall, ooe_fet_redirect_credit,
    fet_dec_instr_s7_tid, fet_dec_instr_s6_tid, fet_dec_instr_s5_tid,
    fet_dec_instr_s4_tid, fet_dec_instr_s3_tid, fet_dec_instr_s2_tid,
    fet_dec_instr_s1_tid, fet_dec_instr_s0_tid, fet_dec_instr_s7_payload,
    fet_dec_instr_s7_valid, fet_dec_instr_s6_payload, fet_dec_instr_s6_valid,
    fet_dec_instr_s5_payload, fet_dec_instr_s5_valid, fet_dec_instr_s4_payload,
    fet_dec_instr_s4_valid, fet_dec_instr_s3_payload, fet_dec_instr_s3_valid,
    fet_dec_instr_s2_payload, fet_dec_instr_s2_valid, fet_dec_instr_s1_payload,
    fet_dec_instr_s1_valid, fet_dec_instr_s0_payload, fet_dec_instr_s0_valid
  } = skew ? q2 : q;
`endif
  assign kill_ack = '0;
  assign kill_ack_epoch = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
`ifdef CCV_CHECK
  assign clk_gated = '0;
`endif
  assign fet_dec_instr_wake = '0;
  assign fet_mlc_ifill_wake = '0;
  assign fet_miu_itlb_req_wake = '0;
  assign fet_pca_mig_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
