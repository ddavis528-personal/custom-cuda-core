// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_ooe: the C++ skeleton's functional stub, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (5361 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (2567 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_ooe (
  `include "ccv_ooe_ports.svh"
);
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_ooe(
    input int h, input longint cyc, input bit rst,
    input bit [5360:0] sample, output bit [2566:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [2566:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  // No clock gate: a C++ block never sleeps (Q-33), so it runs on
  // core_clk, which is what a real block's gate would pass when open.
  always @(posedge core_clk) begin
    ccv_dpi_cycle_ooe(h, cyc, !rst_n, {
      ooe_cru_fault_tid, ooe_cru_fault_stall, ooe_cru_fault_credit,
      ooe_cru_fault_payload, ooe_cru_fault_valid, syu_ooe_rel_tid,
      syu_ooe_rel_stall, syu_ooe_rel_credit, syu_ooe_rel_payload,
      syu_ooe_rel_valid, ooe_syu_bar_tid, ooe_syu_bar_stall,
      ooe_syu_bar_credit, ooe_syu_bar_payload, ooe_syu_bar_valid,
      ooe_rau_drained_tid, ooe_rau_drained_stall, ooe_rau_drained_credit,
      ooe_rau_drained_payload, ooe_rau_drained_valid, rau_ooe_demote_tid,
      rau_ooe_demote_stall, rau_ooe_demote_credit, rau_ooe_demote_payload,
      rau_ooe_demote_valid, ooe_rau_status_tid, ooe_rau_status_stall,
      ooe_rau_status_credit, ooe_rau_status_payload, ooe_rau_status_valid,
      rau_ooe_alloc_tid, rau_ooe_alloc_stall, rau_ooe_alloc_credit,
      rau_ooe_alloc_payload, rau_ooe_alloc_valid, ooe_fet_redirect_tid,
      ooe_fet_redirect_stall, ooe_fet_redirect_credit, ooe_fet_redirect_payload,
      ooe_fet_redirect_valid, ooe_miu_retire_s3_tid, ooe_miu_retire_s2_tid,
      ooe_miu_retire_s1_tid, ooe_miu_retire_s0_tid, ooe_miu_retire_s3_stall,
      ooe_miu_retire_s3_credit, ooe_miu_retire_s3_payload, ooe_miu_retire_s3_valid,
      ooe_miu_retire_s2_stall, ooe_miu_retire_s2_credit, ooe_miu_retire_s2_payload,
      ooe_miu_retire_s2_valid, ooe_miu_retire_s1_stall, ooe_miu_retire_s1_credit,
      ooe_miu_retire_s1_payload, ooe_miu_retire_s1_valid, ooe_miu_retire_s0_stall,
      ooe_miu_retire_s0_credit, ooe_miu_retire_s0_payload, ooe_miu_retire_s0_valid,
      miu_ooe_cmpl_s3_tid, miu_ooe_cmpl_s2_tid, miu_ooe_cmpl_s1_tid,
      miu_ooe_cmpl_s0_tid, miu_ooe_cmpl_s3_stall, miu_ooe_cmpl_s3_credit,
      miu_ooe_cmpl_s3_payload, miu_ooe_cmpl_s3_valid, miu_ooe_cmpl_s2_stall,
      miu_ooe_cmpl_s2_credit, miu_ooe_cmpl_s2_payload, miu_ooe_cmpl_s2_valid,
      miu_ooe_cmpl_s1_stall, miu_ooe_cmpl_s1_credit, miu_ooe_cmpl_s1_payload,
      miu_ooe_cmpl_s1_valid, miu_ooe_cmpl_s0_stall, miu_ooe_cmpl_s0_credit,
      miu_ooe_cmpl_s0_payload, miu_ooe_cmpl_s0_valid, ooe_miu_memop_s3_tid,
      ooe_miu_memop_s2_tid, ooe_miu_memop_s1_tid, ooe_miu_memop_s0_tid,
      ooe_miu_memop_s3_stall, ooe_miu_memop_s3_credit, ooe_miu_memop_s3_payload,
      ooe_miu_memop_s3_valid, ooe_miu_memop_s2_stall, ooe_miu_memop_s2_credit,
      ooe_miu_memop_s2_payload, ooe_miu_memop_s2_valid, ooe_miu_memop_s1_stall,
      ooe_miu_memop_s1_credit, ooe_miu_memop_s1_payload, ooe_miu_memop_s1_valid,
      ooe_miu_memop_s0_stall, ooe_miu_memop_s0_credit, ooe_miu_memop_s0_payload,
      ooe_miu_memop_s0_valid, rcu_ooe_done_s3_tid, rcu_ooe_done_s2_tid,
      rcu_ooe_done_s1_tid, rcu_ooe_done_s0_tid, rcu_ooe_done_s3_stall,
      rcu_ooe_done_s3_credit, rcu_ooe_done_s3_payload, rcu_ooe_done_s3_valid,
      rcu_ooe_done_s2_stall, rcu_ooe_done_s2_credit, rcu_ooe_done_s2_payload,
      rcu_ooe_done_s2_valid, rcu_ooe_done_s1_stall, rcu_ooe_done_s1_credit,
      rcu_ooe_done_s1_payload, rcu_ooe_done_s1_valid, rcu_ooe_done_s0_stall,
      rcu_ooe_done_s0_credit, rcu_ooe_done_s0_payload, rcu_ooe_done_s0_valid,
      ooe_rcu_issue_s3_tid, ooe_rcu_issue_s2_tid, ooe_rcu_issue_s1_tid,
      ooe_rcu_issue_s0_tid, ooe_rcu_issue_s3_stall, ooe_rcu_issue_s3_credit,
      ooe_rcu_issue_s3_payload, ooe_rcu_issue_s3_valid, ooe_rcu_issue_s2_stall,
      ooe_rcu_issue_s2_credit, ooe_rcu_issue_s2_payload, ooe_rcu_issue_s2_valid,
      ooe_rcu_issue_s1_stall, ooe_rcu_issue_s1_credit, ooe_rcu_issue_s1_payload,
      ooe_rcu_issue_s1_valid, ooe_rcu_issue_s0_stall, ooe_rcu_issue_s0_credit,
      ooe_rcu_issue_s0_payload, ooe_rcu_issue_s0_valid, dec_ooe_uop_s5_tid,
      dec_ooe_uop_s4_tid, dec_ooe_uop_s3_tid, dec_ooe_uop_s2_tid,
      dec_ooe_uop_s1_tid, dec_ooe_uop_s0_tid, dec_ooe_uop_s5_stall,
      dec_ooe_uop_s5_credit, dec_ooe_uop_s5_payload, dec_ooe_uop_s5_valid,
      dec_ooe_uop_s4_stall, dec_ooe_uop_s4_credit, dec_ooe_uop_s4_payload,
      dec_ooe_uop_s4_valid, dec_ooe_uop_s3_stall, dec_ooe_uop_s3_credit,
      dec_ooe_uop_s3_payload, dec_ooe_uop_s3_valid, dec_ooe_uop_s2_stall,
      dec_ooe_uop_s2_credit, dec_ooe_uop_s2_payload, dec_ooe_uop_s2_valid,
      dec_ooe_uop_s1_stall, dec_ooe_uop_s1_credit, dec_ooe_uop_s1_payload,
      dec_ooe_uop_s1_valid, dec_ooe_uop_s0_stall, dec_ooe_uop_s0_credit,
      dec_ooe_uop_s0_payload, dec_ooe_uop_s0_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    ooe_cru_fault_tid, ooe_cru_fault_payload, ooe_cru_fault_valid,
    syu_ooe_rel_stall, syu_ooe_rel_credit, ooe_syu_bar_tid,
    ooe_syu_bar_payload, ooe_syu_bar_valid, ooe_rau_drained_tid,
    ooe_rau_drained_payload, ooe_rau_drained_valid, rau_ooe_demote_stall,
    rau_ooe_demote_credit, ooe_rau_status_tid, ooe_rau_status_payload,
    ooe_rau_status_valid, rau_ooe_alloc_stall, rau_ooe_alloc_credit,
    ooe_fet_redirect_tid, ooe_fet_redirect_payload, ooe_fet_redirect_valid,
    ooe_miu_retire_s3_tid, ooe_miu_retire_s2_tid, ooe_miu_retire_s1_tid,
    ooe_miu_retire_s0_tid, ooe_miu_retire_s3_payload, ooe_miu_retire_s3_valid,
    ooe_miu_retire_s2_payload, ooe_miu_retire_s2_valid, ooe_miu_retire_s1_payload,
    ooe_miu_retire_s1_valid, ooe_miu_retire_s0_payload, ooe_miu_retire_s0_valid,
    miu_ooe_cmpl_s3_stall, miu_ooe_cmpl_s3_credit, miu_ooe_cmpl_s2_stall,
    miu_ooe_cmpl_s2_credit, miu_ooe_cmpl_s1_stall, miu_ooe_cmpl_s1_credit,
    miu_ooe_cmpl_s0_stall, miu_ooe_cmpl_s0_credit, ooe_miu_memop_s3_tid,
    ooe_miu_memop_s2_tid, ooe_miu_memop_s1_tid, ooe_miu_memop_s0_tid,
    ooe_miu_memop_s3_payload, ooe_miu_memop_s3_valid, ooe_miu_memop_s2_payload,
    ooe_miu_memop_s2_valid, ooe_miu_memop_s1_payload, ooe_miu_memop_s1_valid,
    ooe_miu_memop_s0_payload, ooe_miu_memop_s0_valid, rcu_ooe_done_s3_stall,
    rcu_ooe_done_s3_credit, rcu_ooe_done_s2_stall, rcu_ooe_done_s2_credit,
    rcu_ooe_done_s1_stall, rcu_ooe_done_s1_credit, rcu_ooe_done_s0_stall,
    rcu_ooe_done_s0_credit, ooe_rcu_issue_s3_tid, ooe_rcu_issue_s2_tid,
    ooe_rcu_issue_s1_tid, ooe_rcu_issue_s0_tid, ooe_rcu_issue_s3_payload,
    ooe_rcu_issue_s3_valid, ooe_rcu_issue_s2_payload, ooe_rcu_issue_s2_valid,
    ooe_rcu_issue_s1_payload, ooe_rcu_issue_s1_valid, ooe_rcu_issue_s0_payload,
    ooe_rcu_issue_s0_valid, dec_ooe_uop_s5_stall, dec_ooe_uop_s5_credit,
    dec_ooe_uop_s4_stall, dec_ooe_uop_s4_credit, dec_ooe_uop_s3_stall,
    dec_ooe_uop_s3_credit, dec_ooe_uop_s2_stall, dec_ooe_uop_s2_credit,
    dec_ooe_uop_s1_stall, dec_ooe_uop_s1_credit, dec_ooe_uop_s0_stall,
    dec_ooe_uop_s0_credit
  } = skew ? q2 : q;
`endif
  assign kill_ack = '0;
  assign kill_ack_epoch = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
`ifdef CCV_CHECK
  assign clk_gated = '0;
`endif
  assign ooe_rcu_issue_wake = '0;
  assign ooe_miu_memop_wake = '0;
  assign ooe_miu_retire_wake = '0;
  assign ooe_fet_redirect_wake = '0;
  assign ooe_rau_status_wake = '0;
  assign ooe_rau_drained_wake = '0;
  assign ooe_syu_bar_wake = '0;
  assign ooe_cru_fault_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
