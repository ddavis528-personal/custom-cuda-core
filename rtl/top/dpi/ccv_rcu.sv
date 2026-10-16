// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_rcu: the C++ skeleton's functional stub, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (36025 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (24113 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_rcu (
  `include "ccv_rcu_ports.svh"
);
  // The block's clock gate: ctech ICG, sleep policy, wake path. Tied
  // never to close -- cg_override -- until the block has idle logic;
  // then these ties become its quiesced, stalled and wake. quiesced:
  // a C++ block's idleness is not visible here.
  // The thresholds and the override are CSRs (Q-47): tied to their
  // reset values until the block decodes its own.
  localparam int CG_HW = ccv_prov_pkg::CCV_CG_HYST_W;
  logic gclk, cg_gated;
  ccv_common_clk u_cg (
    .clk         (core_clk),
    .rst_n       (rst_n),
    .quiesced    (1'b0),
    .stalled     (1'b0),
    .hyst_quiesce(CG_HW'(ccv_prov_pkg::CCV_CG_HYST_QUIESCE)),
    .hyst_stall  (CG_HW'(ccv_prov_pkg::CCV_CG_HYST_STALL)),
    .wake        (1'b0),
    .cg_override (1'b1),
    .te          (1'b0),
    .gclk        (gclk),
    .gated       (cg_gated)
  );
`ifdef CCV_CHECK
  assign clk_gated = cg_gated;
`endif
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_rcu(
    input int h, input longint cyc, input bit rst,
    input bit [36024:0] sample, output bit [24112:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [24112:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  // On the gate's clock, as a real block runs. No C++ block sleeps
  // yet (Q-33), so the gate is tied open and gclk is core_clk's
  // edges through the ctech ICG.
  always @(posedge gclk) begin
    ccv_dpi_cycle_rcu(h, cyc, !rst_n, {
      pca_rcu_mig_tid, pca_rcu_mig_stall, pca_rcu_mig_credit,
      pca_rcu_mig_payload, pca_rcu_mig_valid, rcu_pca_mig_tid,
      rcu_pca_mig_stall, rcu_pca_mig_credit, rcu_pca_mig_payload,
      rcu_pca_mig_valid, ooe_rcu_map_tid, ooe_rcu_map_stall,
      ooe_rcu_map_credit, ooe_rcu_map_payload, ooe_rcu_map_valid,
      rau_rcu_mig_tid, rau_rcu_mig_stall, rau_rcu_mig_credit,
      rau_rcu_mig_payload, rau_rcu_mig_valid, miu_rcu_data_s3_tid,
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
      rcu_miu_addr_s0_credit, rcu_miu_addr_s0_payload, rcu_miu_addr_s0_valid,
      rcu_ooe_done_s6_tid, rcu_ooe_done_s5_tid, rcu_ooe_done_s4_tid,
      rcu_ooe_done_s3_tid, rcu_ooe_done_s2_tid, rcu_ooe_done_s1_tid,
      rcu_ooe_done_s0_tid, rcu_ooe_done_s6_stall, rcu_ooe_done_s6_credit,
      rcu_ooe_done_s6_payload, rcu_ooe_done_s6_valid, rcu_ooe_done_s5_stall,
      rcu_ooe_done_s5_credit, rcu_ooe_done_s5_payload, rcu_ooe_done_s5_valid,
      rcu_ooe_done_s4_stall, rcu_ooe_done_s4_credit, rcu_ooe_done_s4_payload,
      rcu_ooe_done_s4_valid, rcu_ooe_done_s3_stall, rcu_ooe_done_s3_credit,
      rcu_ooe_done_s3_payload, rcu_ooe_done_s3_valid, rcu_ooe_done_s2_stall,
      rcu_ooe_done_s2_credit, rcu_ooe_done_s2_payload, rcu_ooe_done_s2_valid,
      rcu_ooe_done_s1_stall, rcu_ooe_done_s1_credit, rcu_ooe_done_s1_payload,
      rcu_ooe_done_s1_valid, rcu_ooe_done_s0_stall, rcu_ooe_done_s0_credit,
      rcu_ooe_done_s0_payload, rcu_ooe_done_s0_valid, lane_rcu_res_c31_tid,
      lane_rcu_res_c30_tid, lane_rcu_res_c29_tid, lane_rcu_res_c28_tid,
      lane_rcu_res_c27_tid, lane_rcu_res_c26_tid, lane_rcu_res_c25_tid,
      lane_rcu_res_c24_tid, lane_rcu_res_c23_tid, lane_rcu_res_c22_tid,
      lane_rcu_res_c21_tid, lane_rcu_res_c20_tid, lane_rcu_res_c19_tid,
      lane_rcu_res_c18_tid, lane_rcu_res_c17_tid, lane_rcu_res_c16_tid,
      lane_rcu_res_c15_tid, lane_rcu_res_c14_tid, lane_rcu_res_c13_tid,
      lane_rcu_res_c12_tid, lane_rcu_res_c11_tid, lane_rcu_res_c10_tid,
      lane_rcu_res_c09_tid, lane_rcu_res_c08_tid, lane_rcu_res_c07_tid,
      lane_rcu_res_c06_tid, lane_rcu_res_c05_tid, lane_rcu_res_c04_tid,
      lane_rcu_res_c03_tid, lane_rcu_res_c02_tid, lane_rcu_res_c01_tid,
      lane_rcu_res_c00_tid, lane_rcu_res_c31_stall, lane_rcu_res_c31_credit,
      lane_rcu_res_c31_payload, lane_rcu_res_c31_valid, lane_rcu_res_c30_stall,
      lane_rcu_res_c30_credit, lane_rcu_res_c30_payload, lane_rcu_res_c30_valid,
      lane_rcu_res_c29_stall, lane_rcu_res_c29_credit, lane_rcu_res_c29_payload,
      lane_rcu_res_c29_valid, lane_rcu_res_c28_stall, lane_rcu_res_c28_credit,
      lane_rcu_res_c28_payload, lane_rcu_res_c28_valid, lane_rcu_res_c27_stall,
      lane_rcu_res_c27_credit, lane_rcu_res_c27_payload, lane_rcu_res_c27_valid,
      lane_rcu_res_c26_stall, lane_rcu_res_c26_credit, lane_rcu_res_c26_payload,
      lane_rcu_res_c26_valid, lane_rcu_res_c25_stall, lane_rcu_res_c25_credit,
      lane_rcu_res_c25_payload, lane_rcu_res_c25_valid, lane_rcu_res_c24_stall,
      lane_rcu_res_c24_credit, lane_rcu_res_c24_payload, lane_rcu_res_c24_valid,
      lane_rcu_res_c23_stall, lane_rcu_res_c23_credit, lane_rcu_res_c23_payload,
      lane_rcu_res_c23_valid, lane_rcu_res_c22_stall, lane_rcu_res_c22_credit,
      lane_rcu_res_c22_payload, lane_rcu_res_c22_valid, lane_rcu_res_c21_stall,
      lane_rcu_res_c21_credit, lane_rcu_res_c21_payload, lane_rcu_res_c21_valid,
      lane_rcu_res_c20_stall, lane_rcu_res_c20_credit, lane_rcu_res_c20_payload,
      lane_rcu_res_c20_valid, lane_rcu_res_c19_stall, lane_rcu_res_c19_credit,
      lane_rcu_res_c19_payload, lane_rcu_res_c19_valid, lane_rcu_res_c18_stall,
      lane_rcu_res_c18_credit, lane_rcu_res_c18_payload, lane_rcu_res_c18_valid,
      lane_rcu_res_c17_stall, lane_rcu_res_c17_credit, lane_rcu_res_c17_payload,
      lane_rcu_res_c17_valid, lane_rcu_res_c16_stall, lane_rcu_res_c16_credit,
      lane_rcu_res_c16_payload, lane_rcu_res_c16_valid, lane_rcu_res_c15_stall,
      lane_rcu_res_c15_credit, lane_rcu_res_c15_payload, lane_rcu_res_c15_valid,
      lane_rcu_res_c14_stall, lane_rcu_res_c14_credit, lane_rcu_res_c14_payload,
      lane_rcu_res_c14_valid, lane_rcu_res_c13_stall, lane_rcu_res_c13_credit,
      lane_rcu_res_c13_payload, lane_rcu_res_c13_valid, lane_rcu_res_c12_stall,
      lane_rcu_res_c12_credit, lane_rcu_res_c12_payload, lane_rcu_res_c12_valid,
      lane_rcu_res_c11_stall, lane_rcu_res_c11_credit, lane_rcu_res_c11_payload,
      lane_rcu_res_c11_valid, lane_rcu_res_c10_stall, lane_rcu_res_c10_credit,
      lane_rcu_res_c10_payload, lane_rcu_res_c10_valid, lane_rcu_res_c09_stall,
      lane_rcu_res_c09_credit, lane_rcu_res_c09_payload, lane_rcu_res_c09_valid,
      lane_rcu_res_c08_stall, lane_rcu_res_c08_credit, lane_rcu_res_c08_payload,
      lane_rcu_res_c08_valid, lane_rcu_res_c07_stall, lane_rcu_res_c07_credit,
      lane_rcu_res_c07_payload, lane_rcu_res_c07_valid, lane_rcu_res_c06_stall,
      lane_rcu_res_c06_credit, lane_rcu_res_c06_payload, lane_rcu_res_c06_valid,
      lane_rcu_res_c05_stall, lane_rcu_res_c05_credit, lane_rcu_res_c05_payload,
      lane_rcu_res_c05_valid, lane_rcu_res_c04_stall, lane_rcu_res_c04_credit,
      lane_rcu_res_c04_payload, lane_rcu_res_c04_valid, lane_rcu_res_c03_stall,
      lane_rcu_res_c03_credit, lane_rcu_res_c03_payload, lane_rcu_res_c03_valid,
      lane_rcu_res_c02_stall, lane_rcu_res_c02_credit, lane_rcu_res_c02_payload,
      lane_rcu_res_c02_valid, lane_rcu_res_c01_stall, lane_rcu_res_c01_credit,
      lane_rcu_res_c01_payload, lane_rcu_res_c01_valid, lane_rcu_res_c00_stall,
      lane_rcu_res_c00_credit, lane_rcu_res_c00_payload, lane_rcu_res_c00_valid,
      rcu_lane_ops_c31_tid, rcu_lane_ops_c30_tid, rcu_lane_ops_c29_tid,
      rcu_lane_ops_c28_tid, rcu_lane_ops_c27_tid, rcu_lane_ops_c26_tid,
      rcu_lane_ops_c25_tid, rcu_lane_ops_c24_tid, rcu_lane_ops_c23_tid,
      rcu_lane_ops_c22_tid, rcu_lane_ops_c21_tid, rcu_lane_ops_c20_tid,
      rcu_lane_ops_c19_tid, rcu_lane_ops_c18_tid, rcu_lane_ops_c17_tid,
      rcu_lane_ops_c16_tid, rcu_lane_ops_c15_tid, rcu_lane_ops_c14_tid,
      rcu_lane_ops_c13_tid, rcu_lane_ops_c12_tid, rcu_lane_ops_c11_tid,
      rcu_lane_ops_c10_tid, rcu_lane_ops_c09_tid, rcu_lane_ops_c08_tid,
      rcu_lane_ops_c07_tid, rcu_lane_ops_c06_tid, rcu_lane_ops_c05_tid,
      rcu_lane_ops_c04_tid, rcu_lane_ops_c03_tid, rcu_lane_ops_c02_tid,
      rcu_lane_ops_c01_tid, rcu_lane_ops_c00_tid, rcu_lane_ops_c31_stall,
      rcu_lane_ops_c31_credit, rcu_lane_ops_c31_payload, rcu_lane_ops_c31_valid,
      rcu_lane_ops_c30_stall, rcu_lane_ops_c30_credit, rcu_lane_ops_c30_payload,
      rcu_lane_ops_c30_valid, rcu_lane_ops_c29_stall, rcu_lane_ops_c29_credit,
      rcu_lane_ops_c29_payload, rcu_lane_ops_c29_valid, rcu_lane_ops_c28_stall,
      rcu_lane_ops_c28_credit, rcu_lane_ops_c28_payload, rcu_lane_ops_c28_valid,
      rcu_lane_ops_c27_stall, rcu_lane_ops_c27_credit, rcu_lane_ops_c27_payload,
      rcu_lane_ops_c27_valid, rcu_lane_ops_c26_stall, rcu_lane_ops_c26_credit,
      rcu_lane_ops_c26_payload, rcu_lane_ops_c26_valid, rcu_lane_ops_c25_stall,
      rcu_lane_ops_c25_credit, rcu_lane_ops_c25_payload, rcu_lane_ops_c25_valid,
      rcu_lane_ops_c24_stall, rcu_lane_ops_c24_credit, rcu_lane_ops_c24_payload,
      rcu_lane_ops_c24_valid, rcu_lane_ops_c23_stall, rcu_lane_ops_c23_credit,
      rcu_lane_ops_c23_payload, rcu_lane_ops_c23_valid, rcu_lane_ops_c22_stall,
      rcu_lane_ops_c22_credit, rcu_lane_ops_c22_payload, rcu_lane_ops_c22_valid,
      rcu_lane_ops_c21_stall, rcu_lane_ops_c21_credit, rcu_lane_ops_c21_payload,
      rcu_lane_ops_c21_valid, rcu_lane_ops_c20_stall, rcu_lane_ops_c20_credit,
      rcu_lane_ops_c20_payload, rcu_lane_ops_c20_valid, rcu_lane_ops_c19_stall,
      rcu_lane_ops_c19_credit, rcu_lane_ops_c19_payload, rcu_lane_ops_c19_valid,
      rcu_lane_ops_c18_stall, rcu_lane_ops_c18_credit, rcu_lane_ops_c18_payload,
      rcu_lane_ops_c18_valid, rcu_lane_ops_c17_stall, rcu_lane_ops_c17_credit,
      rcu_lane_ops_c17_payload, rcu_lane_ops_c17_valid, rcu_lane_ops_c16_stall,
      rcu_lane_ops_c16_credit, rcu_lane_ops_c16_payload, rcu_lane_ops_c16_valid,
      rcu_lane_ops_c15_stall, rcu_lane_ops_c15_credit, rcu_lane_ops_c15_payload,
      rcu_lane_ops_c15_valid, rcu_lane_ops_c14_stall, rcu_lane_ops_c14_credit,
      rcu_lane_ops_c14_payload, rcu_lane_ops_c14_valid, rcu_lane_ops_c13_stall,
      rcu_lane_ops_c13_credit, rcu_lane_ops_c13_payload, rcu_lane_ops_c13_valid,
      rcu_lane_ops_c12_stall, rcu_lane_ops_c12_credit, rcu_lane_ops_c12_payload,
      rcu_lane_ops_c12_valid, rcu_lane_ops_c11_stall, rcu_lane_ops_c11_credit,
      rcu_lane_ops_c11_payload, rcu_lane_ops_c11_valid, rcu_lane_ops_c10_stall,
      rcu_lane_ops_c10_credit, rcu_lane_ops_c10_payload, rcu_lane_ops_c10_valid,
      rcu_lane_ops_c09_stall, rcu_lane_ops_c09_credit, rcu_lane_ops_c09_payload,
      rcu_lane_ops_c09_valid, rcu_lane_ops_c08_stall, rcu_lane_ops_c08_credit,
      rcu_lane_ops_c08_payload, rcu_lane_ops_c08_valid, rcu_lane_ops_c07_stall,
      rcu_lane_ops_c07_credit, rcu_lane_ops_c07_payload, rcu_lane_ops_c07_valid,
      rcu_lane_ops_c06_stall, rcu_lane_ops_c06_credit, rcu_lane_ops_c06_payload,
      rcu_lane_ops_c06_valid, rcu_lane_ops_c05_stall, rcu_lane_ops_c05_credit,
      rcu_lane_ops_c05_payload, rcu_lane_ops_c05_valid, rcu_lane_ops_c04_stall,
      rcu_lane_ops_c04_credit, rcu_lane_ops_c04_payload, rcu_lane_ops_c04_valid,
      rcu_lane_ops_c03_stall, rcu_lane_ops_c03_credit, rcu_lane_ops_c03_payload,
      rcu_lane_ops_c03_valid, rcu_lane_ops_c02_stall, rcu_lane_ops_c02_credit,
      rcu_lane_ops_c02_payload, rcu_lane_ops_c02_valid, rcu_lane_ops_c01_stall,
      rcu_lane_ops_c01_credit, rcu_lane_ops_c01_payload, rcu_lane_ops_c01_valid,
      rcu_lane_ops_c00_stall, rcu_lane_ops_c00_credit, rcu_lane_ops_c00_payload,
      rcu_lane_ops_c00_valid, ooe_rcu_issue_s8_tid, ooe_rcu_issue_s7_tid,
      ooe_rcu_issue_s6_tid, ooe_rcu_issue_s5_tid, ooe_rcu_issue_s4_tid,
      ooe_rcu_issue_s3_tid, ooe_rcu_issue_s2_tid, ooe_rcu_issue_s1_tid,
      ooe_rcu_issue_s0_tid, ooe_rcu_issue_s8_stall, ooe_rcu_issue_s8_credit,
      ooe_rcu_issue_s8_payload, ooe_rcu_issue_s8_valid, ooe_rcu_issue_s7_stall,
      ooe_rcu_issue_s7_credit, ooe_rcu_issue_s7_payload, ooe_rcu_issue_s7_valid,
      ooe_rcu_issue_s6_stall, ooe_rcu_issue_s6_credit, ooe_rcu_issue_s6_payload,
      ooe_rcu_issue_s6_valid, ooe_rcu_issue_s5_stall, ooe_rcu_issue_s5_credit,
      ooe_rcu_issue_s5_payload, ooe_rcu_issue_s5_valid, ooe_rcu_issue_s4_stall,
      ooe_rcu_issue_s4_credit, ooe_rcu_issue_s4_payload, ooe_rcu_issue_s4_valid,
      ooe_rcu_issue_s3_stall, ooe_rcu_issue_s3_credit, ooe_rcu_issue_s3_payload,
      ooe_rcu_issue_s3_valid, ooe_rcu_issue_s2_stall, ooe_rcu_issue_s2_credit,
      ooe_rcu_issue_s2_payload, ooe_rcu_issue_s2_valid, ooe_rcu_issue_s1_stall,
      ooe_rcu_issue_s1_credit, ooe_rcu_issue_s1_payload, ooe_rcu_issue_s1_valid,
      ooe_rcu_issue_s0_stall, ooe_rcu_issue_s0_credit, ooe_rcu_issue_s0_payload,
      ooe_rcu_issue_s0_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    pca_rcu_mig_stall, pca_rcu_mig_credit, rcu_pca_mig_tid,
    rcu_pca_mig_payload, rcu_pca_mig_valid, ooe_rcu_map_stall,
    ooe_rcu_map_credit, rau_rcu_mig_stall, rau_rcu_mig_credit,
    miu_rcu_data_s3_stall, miu_rcu_data_s3_credit, miu_rcu_data_s2_stall,
    miu_rcu_data_s2_credit, miu_rcu_data_s1_stall, miu_rcu_data_s1_credit,
    miu_rcu_data_s0_stall, miu_rcu_data_s0_credit, rcu_miu_addr_s3_tid,
    rcu_miu_addr_s2_tid, rcu_miu_addr_s1_tid, rcu_miu_addr_s0_tid,
    rcu_miu_addr_s3_payload, rcu_miu_addr_s3_valid, rcu_miu_addr_s2_payload,
    rcu_miu_addr_s2_valid, rcu_miu_addr_s1_payload, rcu_miu_addr_s1_valid,
    rcu_miu_addr_s0_payload, rcu_miu_addr_s0_valid, rcu_ooe_done_s6_tid,
    rcu_ooe_done_s5_tid, rcu_ooe_done_s4_tid, rcu_ooe_done_s3_tid,
    rcu_ooe_done_s2_tid, rcu_ooe_done_s1_tid, rcu_ooe_done_s0_tid,
    rcu_ooe_done_s6_payload, rcu_ooe_done_s6_valid, rcu_ooe_done_s5_payload,
    rcu_ooe_done_s5_valid, rcu_ooe_done_s4_payload, rcu_ooe_done_s4_valid,
    rcu_ooe_done_s3_payload, rcu_ooe_done_s3_valid, rcu_ooe_done_s2_payload,
    rcu_ooe_done_s2_valid, rcu_ooe_done_s1_payload, rcu_ooe_done_s1_valid,
    rcu_ooe_done_s0_payload, rcu_ooe_done_s0_valid, lane_rcu_res_c31_stall,
    lane_rcu_res_c31_credit, lane_rcu_res_c30_stall, lane_rcu_res_c30_credit,
    lane_rcu_res_c29_stall, lane_rcu_res_c29_credit, lane_rcu_res_c28_stall,
    lane_rcu_res_c28_credit, lane_rcu_res_c27_stall, lane_rcu_res_c27_credit,
    lane_rcu_res_c26_stall, lane_rcu_res_c26_credit, lane_rcu_res_c25_stall,
    lane_rcu_res_c25_credit, lane_rcu_res_c24_stall, lane_rcu_res_c24_credit,
    lane_rcu_res_c23_stall, lane_rcu_res_c23_credit, lane_rcu_res_c22_stall,
    lane_rcu_res_c22_credit, lane_rcu_res_c21_stall, lane_rcu_res_c21_credit,
    lane_rcu_res_c20_stall, lane_rcu_res_c20_credit, lane_rcu_res_c19_stall,
    lane_rcu_res_c19_credit, lane_rcu_res_c18_stall, lane_rcu_res_c18_credit,
    lane_rcu_res_c17_stall, lane_rcu_res_c17_credit, lane_rcu_res_c16_stall,
    lane_rcu_res_c16_credit, lane_rcu_res_c15_stall, lane_rcu_res_c15_credit,
    lane_rcu_res_c14_stall, lane_rcu_res_c14_credit, lane_rcu_res_c13_stall,
    lane_rcu_res_c13_credit, lane_rcu_res_c12_stall, lane_rcu_res_c12_credit,
    lane_rcu_res_c11_stall, lane_rcu_res_c11_credit, lane_rcu_res_c10_stall,
    lane_rcu_res_c10_credit, lane_rcu_res_c09_stall, lane_rcu_res_c09_credit,
    lane_rcu_res_c08_stall, lane_rcu_res_c08_credit, lane_rcu_res_c07_stall,
    lane_rcu_res_c07_credit, lane_rcu_res_c06_stall, lane_rcu_res_c06_credit,
    lane_rcu_res_c05_stall, lane_rcu_res_c05_credit, lane_rcu_res_c04_stall,
    lane_rcu_res_c04_credit, lane_rcu_res_c03_stall, lane_rcu_res_c03_credit,
    lane_rcu_res_c02_stall, lane_rcu_res_c02_credit, lane_rcu_res_c01_stall,
    lane_rcu_res_c01_credit, lane_rcu_res_c00_stall, lane_rcu_res_c00_credit,
    rcu_lane_ops_c31_tid, rcu_lane_ops_c30_tid, rcu_lane_ops_c29_tid,
    rcu_lane_ops_c28_tid, rcu_lane_ops_c27_tid, rcu_lane_ops_c26_tid,
    rcu_lane_ops_c25_tid, rcu_lane_ops_c24_tid, rcu_lane_ops_c23_tid,
    rcu_lane_ops_c22_tid, rcu_lane_ops_c21_tid, rcu_lane_ops_c20_tid,
    rcu_lane_ops_c19_tid, rcu_lane_ops_c18_tid, rcu_lane_ops_c17_tid,
    rcu_lane_ops_c16_tid, rcu_lane_ops_c15_tid, rcu_lane_ops_c14_tid,
    rcu_lane_ops_c13_tid, rcu_lane_ops_c12_tid, rcu_lane_ops_c11_tid,
    rcu_lane_ops_c10_tid, rcu_lane_ops_c09_tid, rcu_lane_ops_c08_tid,
    rcu_lane_ops_c07_tid, rcu_lane_ops_c06_tid, rcu_lane_ops_c05_tid,
    rcu_lane_ops_c04_tid, rcu_lane_ops_c03_tid, rcu_lane_ops_c02_tid,
    rcu_lane_ops_c01_tid, rcu_lane_ops_c00_tid, rcu_lane_ops_c31_payload,
    rcu_lane_ops_c31_valid, rcu_lane_ops_c30_payload, rcu_lane_ops_c30_valid,
    rcu_lane_ops_c29_payload, rcu_lane_ops_c29_valid, rcu_lane_ops_c28_payload,
    rcu_lane_ops_c28_valid, rcu_lane_ops_c27_payload, rcu_lane_ops_c27_valid,
    rcu_lane_ops_c26_payload, rcu_lane_ops_c26_valid, rcu_lane_ops_c25_payload,
    rcu_lane_ops_c25_valid, rcu_lane_ops_c24_payload, rcu_lane_ops_c24_valid,
    rcu_lane_ops_c23_payload, rcu_lane_ops_c23_valid, rcu_lane_ops_c22_payload,
    rcu_lane_ops_c22_valid, rcu_lane_ops_c21_payload, rcu_lane_ops_c21_valid,
    rcu_lane_ops_c20_payload, rcu_lane_ops_c20_valid, rcu_lane_ops_c19_payload,
    rcu_lane_ops_c19_valid, rcu_lane_ops_c18_payload, rcu_lane_ops_c18_valid,
    rcu_lane_ops_c17_payload, rcu_lane_ops_c17_valid, rcu_lane_ops_c16_payload,
    rcu_lane_ops_c16_valid, rcu_lane_ops_c15_payload, rcu_lane_ops_c15_valid,
    rcu_lane_ops_c14_payload, rcu_lane_ops_c14_valid, rcu_lane_ops_c13_payload,
    rcu_lane_ops_c13_valid, rcu_lane_ops_c12_payload, rcu_lane_ops_c12_valid,
    rcu_lane_ops_c11_payload, rcu_lane_ops_c11_valid, rcu_lane_ops_c10_payload,
    rcu_lane_ops_c10_valid, rcu_lane_ops_c09_payload, rcu_lane_ops_c09_valid,
    rcu_lane_ops_c08_payload, rcu_lane_ops_c08_valid, rcu_lane_ops_c07_payload,
    rcu_lane_ops_c07_valid, rcu_lane_ops_c06_payload, rcu_lane_ops_c06_valid,
    rcu_lane_ops_c05_payload, rcu_lane_ops_c05_valid, rcu_lane_ops_c04_payload,
    rcu_lane_ops_c04_valid, rcu_lane_ops_c03_payload, rcu_lane_ops_c03_valid,
    rcu_lane_ops_c02_payload, rcu_lane_ops_c02_valid, rcu_lane_ops_c01_payload,
    rcu_lane_ops_c01_valid, rcu_lane_ops_c00_payload, rcu_lane_ops_c00_valid,
    ooe_rcu_issue_s8_stall, ooe_rcu_issue_s8_credit, ooe_rcu_issue_s7_stall,
    ooe_rcu_issue_s7_credit, ooe_rcu_issue_s6_stall, ooe_rcu_issue_s6_credit,
    ooe_rcu_issue_s5_stall, ooe_rcu_issue_s5_credit, ooe_rcu_issue_s4_stall,
    ooe_rcu_issue_s4_credit, ooe_rcu_issue_s3_stall, ooe_rcu_issue_s3_credit,
    ooe_rcu_issue_s2_stall, ooe_rcu_issue_s2_credit, ooe_rcu_issue_s1_stall,
    ooe_rcu_issue_s1_credit, ooe_rcu_issue_s0_stall, ooe_rcu_issue_s0_credit
  } = skew ? q2 : q;
`endif
  assign kill_ack = '0;
  assign kill_ack_epoch = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign rcu_lane_ops_c00_wake = '0;
  assign rcu_lane_ops_c01_wake = '0;
  assign rcu_lane_ops_c02_wake = '0;
  assign rcu_lane_ops_c03_wake = '0;
  assign rcu_lane_ops_c04_wake = '0;
  assign rcu_lane_ops_c05_wake = '0;
  assign rcu_lane_ops_c06_wake = '0;
  assign rcu_lane_ops_c07_wake = '0;
  assign rcu_lane_ops_c08_wake = '0;
  assign rcu_lane_ops_c09_wake = '0;
  assign rcu_lane_ops_c10_wake = '0;
  assign rcu_lane_ops_c11_wake = '0;
  assign rcu_lane_ops_c12_wake = '0;
  assign rcu_lane_ops_c13_wake = '0;
  assign rcu_lane_ops_c14_wake = '0;
  assign rcu_lane_ops_c15_wake = '0;
  assign rcu_lane_ops_c16_wake = '0;
  assign rcu_lane_ops_c17_wake = '0;
  assign rcu_lane_ops_c18_wake = '0;
  assign rcu_lane_ops_c19_wake = '0;
  assign rcu_lane_ops_c20_wake = '0;
  assign rcu_lane_ops_c21_wake = '0;
  assign rcu_lane_ops_c22_wake = '0;
  assign rcu_lane_ops_c23_wake = '0;
  assign rcu_lane_ops_c24_wake = '0;
  assign rcu_lane_ops_c25_wake = '0;
  assign rcu_lane_ops_c26_wake = '0;
  assign rcu_lane_ops_c27_wake = '0;
  assign rcu_lane_ops_c28_wake = '0;
  assign rcu_lane_ops_c29_wake = '0;
  assign rcu_lane_ops_c30_wake = '0;
  assign rcu_lane_ops_c31_wake = '0;
  assign rcu_ooe_done_wake = '0;
  assign rcu_miu_addr_wake = '0;
  assign rcu_pca_mig_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
