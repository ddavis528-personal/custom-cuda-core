// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_miu: the C++ skeleton's functional stub, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (35754 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (16857 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_miu (
  `include "ccv_miu_ports.svh"
);
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_miu(
    input int h, input longint cyc, input bit rst,
    input bit [35753:0] sample, output bit [16856:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [16856:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  // No clock gate: a C++ block never sleeps (Q-33), so it runs on
  // core_clk, which is what a real block's gate would pass when open.
  always @(posedge core_clk) begin
    ccv_dpi_cycle_miu(h, cyc, !rst_n, {
      rau_miu_cta_tid, rau_miu_cta_stall, rau_miu_cta_credit,
      rau_miu_cta_payload, rau_miu_cta_valid, fet_miu_itlb_req_tid,
      fet_miu_itlb_req_stall, fet_miu_itlb_req_credit, fet_miu_itlb_req_payload,
      fet_miu_itlb_req_valid, miu_fet_itlb_tid, miu_fet_itlb_stall,
      miu_fet_itlb_credit, miu_fet_itlb_payload, miu_fet_itlb_valid,
      dcu_miu_rsp_s3_tid, dcu_miu_rsp_s2_tid, dcu_miu_rsp_s1_tid,
      dcu_miu_rsp_s0_tid, dcu_miu_rsp_s3_stall, dcu_miu_rsp_s3_credit,
      dcu_miu_rsp_s3_payload, dcu_miu_rsp_s3_valid, dcu_miu_rsp_s2_stall,
      dcu_miu_rsp_s2_credit, dcu_miu_rsp_s2_payload, dcu_miu_rsp_s2_valid,
      dcu_miu_rsp_s1_stall, dcu_miu_rsp_s1_credit, dcu_miu_rsp_s1_payload,
      dcu_miu_rsp_s1_valid, dcu_miu_rsp_s0_stall, dcu_miu_rsp_s0_credit,
      dcu_miu_rsp_s0_payload, dcu_miu_rsp_s0_valid, miu_dcu_req_s3_tid,
      miu_dcu_req_s2_tid, miu_dcu_req_s1_tid, miu_dcu_req_s0_tid,
      miu_dcu_req_s3_stall, miu_dcu_req_s3_credit, miu_dcu_req_s3_payload,
      miu_dcu_req_s3_valid, miu_dcu_req_s2_stall, miu_dcu_req_s2_credit,
      miu_dcu_req_s2_payload, miu_dcu_req_s2_valid, miu_dcu_req_s1_stall,
      miu_dcu_req_s1_credit, miu_dcu_req_s1_payload, miu_dcu_req_s1_valid,
      miu_dcu_req_s0_stall, miu_dcu_req_s0_credit, miu_dcu_req_s0_payload,
      miu_dcu_req_s0_valid, spm_miu_rsp_s3_tid, spm_miu_rsp_s2_tid,
      spm_miu_rsp_s1_tid, spm_miu_rsp_s0_tid, spm_miu_rsp_s3_stall,
      spm_miu_rsp_s3_credit, spm_miu_rsp_s3_payload, spm_miu_rsp_s3_valid,
      spm_miu_rsp_s2_stall, spm_miu_rsp_s2_credit, spm_miu_rsp_s2_payload,
      spm_miu_rsp_s2_valid, spm_miu_rsp_s1_stall, spm_miu_rsp_s1_credit,
      spm_miu_rsp_s1_payload, spm_miu_rsp_s1_valid, spm_miu_rsp_s0_stall,
      spm_miu_rsp_s0_credit, spm_miu_rsp_s0_payload, spm_miu_rsp_s0_valid,
      miu_spm_req_s3_tid, miu_spm_req_s2_tid, miu_spm_req_s1_tid,
      miu_spm_req_s0_tid, miu_spm_req_s3_stall, miu_spm_req_s3_credit,
      miu_spm_req_s3_payload, miu_spm_req_s3_valid, miu_spm_req_s2_stall,
      miu_spm_req_s2_credit, miu_spm_req_s2_payload, miu_spm_req_s2_valid,
      miu_spm_req_s1_stall, miu_spm_req_s1_credit, miu_spm_req_s1_payload,
      miu_spm_req_s1_valid, miu_spm_req_s0_stall, miu_spm_req_s0_credit,
      miu_spm_req_s0_payload, miu_spm_req_s0_valid, ooe_miu_retire_s3_tid,
      ooe_miu_retire_s2_tid, ooe_miu_retire_s1_tid, ooe_miu_retire_s0_tid,
      ooe_miu_retire_s3_stall, ooe_miu_retire_s3_credit, ooe_miu_retire_s3_payload,
      ooe_miu_retire_s3_valid, ooe_miu_retire_s2_stall, ooe_miu_retire_s2_credit,
      ooe_miu_retire_s2_payload, ooe_miu_retire_s2_valid, ooe_miu_retire_s1_stall,
      ooe_miu_retire_s1_credit, ooe_miu_retire_s1_payload, ooe_miu_retire_s1_valid,
      ooe_miu_retire_s0_stall, ooe_miu_retire_s0_credit, ooe_miu_retire_s0_payload,
      ooe_miu_retire_s0_valid, miu_ooe_cmpl_s3_tid, miu_ooe_cmpl_s2_tid,
      miu_ooe_cmpl_s1_tid, miu_ooe_cmpl_s0_tid, miu_ooe_cmpl_s3_stall,
      miu_ooe_cmpl_s3_credit, miu_ooe_cmpl_s3_payload, miu_ooe_cmpl_s3_valid,
      miu_ooe_cmpl_s2_stall, miu_ooe_cmpl_s2_credit, miu_ooe_cmpl_s2_payload,
      miu_ooe_cmpl_s2_valid, miu_ooe_cmpl_s1_stall, miu_ooe_cmpl_s1_credit,
      miu_ooe_cmpl_s1_payload, miu_ooe_cmpl_s1_valid, miu_ooe_cmpl_s0_stall,
      miu_ooe_cmpl_s0_credit, miu_ooe_cmpl_s0_payload, miu_ooe_cmpl_s0_valid,
      ooe_miu_memop_s3_tid, ooe_miu_memop_s2_tid, ooe_miu_memop_s1_tid,
      ooe_miu_memop_s0_tid, ooe_miu_memop_s3_stall, ooe_miu_memop_s3_credit,
      ooe_miu_memop_s3_payload, ooe_miu_memop_s3_valid, ooe_miu_memop_s2_stall,
      ooe_miu_memop_s2_credit, ooe_miu_memop_s2_payload, ooe_miu_memop_s2_valid,
      ooe_miu_memop_s1_stall, ooe_miu_memop_s1_credit, ooe_miu_memop_s1_payload,
      ooe_miu_memop_s1_valid, ooe_miu_memop_s0_stall, ooe_miu_memop_s0_credit,
      ooe_miu_memop_s0_payload, ooe_miu_memop_s0_valid, miu_rcu_data_s3_tid,
      miu_rcu_data_s2_tid, miu_rcu_data_s1_tid, miu_rcu_data_s0_tid,
      miu_rcu_data_s3_stall, miu_rcu_data_s3_credit, miu_rcu_data_s3_payload,
      miu_rcu_data_s3_valid, miu_rcu_data_s2_stall, miu_rcu_data_s2_credit,
      miu_rcu_data_s2_payload, miu_rcu_data_s2_valid, miu_rcu_data_s1_stall,
      miu_rcu_data_s1_credit, miu_rcu_data_s1_payload, miu_rcu_data_s1_valid,
      miu_rcu_data_s0_stall, miu_rcu_data_s0_credit, miu_rcu_data_s0_payload,
      miu_rcu_data_s0_valid, rcu_miu_addr_s3_tid, rcu_miu_addr_s2_tid,
      rcu_miu_addr_s1_tid, rcu_miu_addr_s0_tid, rcu_miu_addr_s3_stall,
      rcu_miu_addr_s3_credit, rcu_miu_addr_s3_payload, rcu_miu_addr_s3_valid,
      rcu_miu_addr_s2_stall, rcu_miu_addr_s2_credit, rcu_miu_addr_s2_payload,
      rcu_miu_addr_s2_valid, rcu_miu_addr_s1_stall, rcu_miu_addr_s1_credit,
      rcu_miu_addr_s1_payload, rcu_miu_addr_s1_valid, rcu_miu_addr_s0_stall,
      rcu_miu_addr_s0_credit, rcu_miu_addr_s0_payload, rcu_miu_addr_s0_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    rau_miu_cta_stall, rau_miu_cta_credit, fet_miu_itlb_req_stall,
    fet_miu_itlb_req_credit, miu_fet_itlb_tid, miu_fet_itlb_payload,
    miu_fet_itlb_valid, dcu_miu_rsp_s3_stall, dcu_miu_rsp_s3_credit,
    dcu_miu_rsp_s2_stall, dcu_miu_rsp_s2_credit, dcu_miu_rsp_s1_stall,
    dcu_miu_rsp_s1_credit, dcu_miu_rsp_s0_stall, dcu_miu_rsp_s0_credit,
    miu_dcu_req_s3_tid, miu_dcu_req_s2_tid, miu_dcu_req_s1_tid,
    miu_dcu_req_s0_tid, miu_dcu_req_s3_payload, miu_dcu_req_s3_valid,
    miu_dcu_req_s2_payload, miu_dcu_req_s2_valid, miu_dcu_req_s1_payload,
    miu_dcu_req_s1_valid, miu_dcu_req_s0_payload, miu_dcu_req_s0_valid,
    spm_miu_rsp_s3_stall, spm_miu_rsp_s3_credit, spm_miu_rsp_s2_stall,
    spm_miu_rsp_s2_credit, spm_miu_rsp_s1_stall, spm_miu_rsp_s1_credit,
    spm_miu_rsp_s0_stall, spm_miu_rsp_s0_credit, miu_spm_req_s3_tid,
    miu_spm_req_s2_tid, miu_spm_req_s1_tid, miu_spm_req_s0_tid,
    miu_spm_req_s3_payload, miu_spm_req_s3_valid, miu_spm_req_s2_payload,
    miu_spm_req_s2_valid, miu_spm_req_s1_payload, miu_spm_req_s1_valid,
    miu_spm_req_s0_payload, miu_spm_req_s0_valid, ooe_miu_retire_s3_stall,
    ooe_miu_retire_s3_credit, ooe_miu_retire_s2_stall, ooe_miu_retire_s2_credit,
    ooe_miu_retire_s1_stall, ooe_miu_retire_s1_credit, ooe_miu_retire_s0_stall,
    ooe_miu_retire_s0_credit, miu_ooe_cmpl_s3_tid, miu_ooe_cmpl_s2_tid,
    miu_ooe_cmpl_s1_tid, miu_ooe_cmpl_s0_tid, miu_ooe_cmpl_s3_payload,
    miu_ooe_cmpl_s3_valid, miu_ooe_cmpl_s2_payload, miu_ooe_cmpl_s2_valid,
    miu_ooe_cmpl_s1_payload, miu_ooe_cmpl_s1_valid, miu_ooe_cmpl_s0_payload,
    miu_ooe_cmpl_s0_valid, ooe_miu_memop_s3_stall, ooe_miu_memop_s3_credit,
    ooe_miu_memop_s2_stall, ooe_miu_memop_s2_credit, ooe_miu_memop_s1_stall,
    ooe_miu_memop_s1_credit, ooe_miu_memop_s0_stall, ooe_miu_memop_s0_credit,
    miu_rcu_data_s3_tid, miu_rcu_data_s2_tid, miu_rcu_data_s1_tid,
    miu_rcu_data_s0_tid, miu_rcu_data_s3_payload, miu_rcu_data_s3_valid,
    miu_rcu_data_s2_payload, miu_rcu_data_s2_valid, miu_rcu_data_s1_payload,
    miu_rcu_data_s1_valid, miu_rcu_data_s0_payload, miu_rcu_data_s0_valid,
    rcu_miu_addr_s3_stall, rcu_miu_addr_s3_credit, rcu_miu_addr_s2_stall,
    rcu_miu_addr_s2_credit, rcu_miu_addr_s1_stall, rcu_miu_addr_s1_credit,
    rcu_miu_addr_s0_stall, rcu_miu_addr_s0_credit
  } = skew ? q2 : q;
`endif
  assign kill_ack = '0;
  assign kill_ack_epoch = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
`ifdef CCV_CHECK
  assign clk_gated = '0;
`endif
  assign miu_rcu_data_wake = '0;
  assign miu_ooe_cmpl_wake = '0;
  assign miu_spm_req_wake = '0;
  assign miu_dcu_req_wake = '0;
  assign miu_fet_itlb_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
