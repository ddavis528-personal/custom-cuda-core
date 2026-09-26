// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_lane: the C++ skeleton's functional stub, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (1116 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (404 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_lane (
  `include "ccv_lane_ports.svh"
);
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_lane(
    input int h, input longint cyc, input bit rst,
    input bit [1115:0] sample, output bit [403:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [403:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  always @(posedge clk) begin
    ccv_dpi_cycle_lane(h, cyc, !rst_n, {
      lane_rcu_res_s3_tid, lane_rcu_res_s2_tid, lane_rcu_res_s1_tid,
      lane_rcu_res_s0_tid, lane_rcu_res_s3_stall, lane_rcu_res_s3_credit,
      lane_rcu_res_s3_payload, lane_rcu_res_s3_valid, lane_rcu_res_s2_stall,
      lane_rcu_res_s2_credit, lane_rcu_res_s2_payload, lane_rcu_res_s2_valid,
      lane_rcu_res_s1_stall, lane_rcu_res_s1_credit, lane_rcu_res_s1_payload,
      lane_rcu_res_s1_valid, lane_rcu_res_s0_stall, lane_rcu_res_s0_credit,
      lane_rcu_res_s0_payload, lane_rcu_res_s0_valid, rcu_lane_ops_s3_tid,
      rcu_lane_ops_s2_tid, rcu_lane_ops_s1_tid, rcu_lane_ops_s0_tid,
      rcu_lane_ops_s3_stall, rcu_lane_ops_s3_credit, rcu_lane_ops_s3_payload,
      rcu_lane_ops_s3_valid, rcu_lane_ops_s2_stall, rcu_lane_ops_s2_credit,
      rcu_lane_ops_s2_payload, rcu_lane_ops_s2_valid, rcu_lane_ops_s1_stall,
      rcu_lane_ops_s1_credit, rcu_lane_ops_s1_payload, rcu_lane_ops_s1_valid,
      rcu_lane_ops_s0_stall, rcu_lane_ops_s0_credit, rcu_lane_ops_s0_payload,
      rcu_lane_ops_s0_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    lane_rcu_res_s3_tid, lane_rcu_res_s2_tid, lane_rcu_res_s1_tid,
    lane_rcu_res_s0_tid, lane_rcu_res_s3_payload, lane_rcu_res_s3_valid,
    lane_rcu_res_s2_payload, lane_rcu_res_s2_valid, lane_rcu_res_s1_payload,
    lane_rcu_res_s1_valid, lane_rcu_res_s0_payload, lane_rcu_res_s0_valid,
    rcu_lane_ops_s3_stall, rcu_lane_ops_s3_credit, rcu_lane_ops_s2_stall,
    rcu_lane_ops_s2_credit, rcu_lane_ops_s1_stall, rcu_lane_ops_s1_credit,
    rcu_lane_ops_s0_stall, rcu_lane_ops_s0_credit
  } = skew ? q2 : q;
`endif
  assign sleep_ok = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign lane_rcu_res_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
