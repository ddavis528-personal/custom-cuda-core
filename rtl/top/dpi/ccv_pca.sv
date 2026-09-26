// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_pca: the C++ skeleton's functional stub, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (4976 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (2522 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_pca (
  `include "ccv_pca_ports.svh"
);
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_pca(
    input int h, input longint cyc, input bit rst,
    input bit [4975:0] sample, output bit [2521:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [2521:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  // No clock gate: a C++ block never sleeps (Q-33), so it runs on
  // core_clk, which is what a real block's gate would pass when open.
  always @(posedge core_clk) begin
    ccv_dpi_cycle_pca(h, cyc, !rst_n, {
      pca_rau_mig_done_tid, pca_rau_mig_done_stall, pca_rau_mig_done_credit,
      pca_rau_mig_done_payload, pca_rau_mig_done_valid, pca_fet_mig_tid,
      pca_fet_mig_stall, pca_fet_mig_credit, pca_fet_mig_payload,
      pca_fet_mig_valid, fet_pca_mig_tid, fet_pca_mig_stall,
      fet_pca_mig_credit, fet_pca_mig_payload, fet_pca_mig_valid,
      pca_rcu_mig_tid, pca_rcu_mig_stall, pca_rcu_mig_credit,
      pca_rcu_mig_payload, pca_rcu_mig_valid, rcu_pca_mig_tid,
      rcu_pca_mig_stall, rcu_pca_mig_credit, rcu_pca_mig_payload,
      rcu_pca_mig_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    pca_rau_mig_done_tid, pca_rau_mig_done_payload, pca_rau_mig_done_valid,
    pca_fet_mig_tid, pca_fet_mig_payload, pca_fet_mig_valid,
    fet_pca_mig_stall, fet_pca_mig_credit, pca_rcu_mig_tid,
    pca_rcu_mig_payload, pca_rcu_mig_valid, rcu_pca_mig_stall,
    rcu_pca_mig_credit
  } = skew ? q2 : q;
`endif
  assign kill_ack = '0;
  assign kill_ack_epoch = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
`ifdef CCV_CHECK
  assign clk_gated = '0;
`endif
  assign pca_rcu_mig_wake = '0;
  assign pca_fet_mig_wake = '0;
  assign pca_rau_mig_done_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
