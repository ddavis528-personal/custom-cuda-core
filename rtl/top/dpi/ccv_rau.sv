// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_rau: the C++ skeleton's functional stub, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (1287 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (848 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_rau (
  `include "ccv_rau_ports.svh"
);
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_rau(
    input int h, input longint cyc, input bit rst,
    input bit [1286:0] sample, output bit [847:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [847:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  // No clock gate: a C++ block never sleeps (Q-33), so it runs on
  // core_clk, which is what a real block's gate would pass when open.
  always @(posedge core_clk) begin
    ccv_dpi_cycle_rau(h, cyc, !rst_n, {
      cru_rau_cfg_tid, cru_rau_cfg_stall, cru_rau_cfg_credit,
      cru_rau_cfg_payload, cru_rau_cfg_valid, rau_syu_alloc_tid,
      rau_syu_alloc_stall, rau_syu_alloc_credit, rau_syu_alloc_payload,
      rau_syu_alloc_valid, rau_miu_cta_tid, rau_miu_cta_stall,
      rau_miu_cta_credit, rau_miu_cta_payload, rau_miu_cta_valid,
      pca_rau_mig_done_tid, pca_rau_mig_done_stall, pca_rau_mig_done_credit,
      pca_rau_mig_done_payload, pca_rau_mig_done_valid, rau_fet_mig_tid,
      rau_fet_mig_stall, rau_fet_mig_credit, rau_fet_mig_payload,
      rau_fet_mig_valid, rau_rcu_mig_tid, rau_rcu_mig_stall,
      rau_rcu_mig_credit, rau_rcu_mig_payload, rau_rcu_mig_valid,
      ooe_rau_drained_tid, ooe_rau_drained_stall, ooe_rau_drained_credit,
      ooe_rau_drained_payload, ooe_rau_drained_valid, rau_ooe_demote_tid,
      rau_ooe_demote_stall, rau_ooe_demote_credit, rau_ooe_demote_payload,
      rau_ooe_demote_valid, ooe_rau_status_tid, ooe_rau_status_stall,
      ooe_rau_status_credit, ooe_rau_status_payload, ooe_rau_status_valid,
      rau_ooe_alloc_tid, rau_ooe_alloc_stall, rau_ooe_alloc_credit,
      rau_ooe_alloc_payload, rau_ooe_alloc_valid, rau_fet_launch_tid,
      rau_fet_launch_stall, rau_fet_launch_credit, rau_fet_launch_payload,
      rau_fet_launch_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    cru_rau_cfg_stall, cru_rau_cfg_credit, rau_syu_alloc_tid,
    rau_syu_alloc_payload, rau_syu_alloc_valid, rau_miu_cta_tid,
    rau_miu_cta_payload, rau_miu_cta_valid, pca_rau_mig_done_stall,
    pca_rau_mig_done_credit, rau_fet_mig_tid, rau_fet_mig_payload,
    rau_fet_mig_valid, rau_rcu_mig_tid, rau_rcu_mig_payload,
    rau_rcu_mig_valid, ooe_rau_drained_stall, ooe_rau_drained_credit,
    rau_ooe_demote_tid, rau_ooe_demote_payload, rau_ooe_demote_valid,
    ooe_rau_status_stall, ooe_rau_status_credit, rau_ooe_alloc_tid,
    rau_ooe_alloc_payload, rau_ooe_alloc_valid, rau_fet_launch_tid,
    rau_fet_launch_payload, rau_fet_launch_valid
  } = skew ? q2 : q;
`endif
  assign kill_valid = '0;
  assign kill_warp_mask = '0;
  assign kill_epoch = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
`ifdef CCV_CHECK
  assign clk_gated = '0;
`endif
  assign rau_fet_launch_wake = '0;
  assign rau_ooe_alloc_wake = '0;
  assign rau_ooe_demote_wake = '0;
  assign rau_rcu_mig_wake = '0;
  assign rau_fet_mig_wake = '0;
  assign rau_miu_cta_wake = '0;
  assign rau_syu_alloc_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
