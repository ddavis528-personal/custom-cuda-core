//===-- rcu_kdet.sv - RCU's kill detector, on the ungated clock -----------===//
//
// Spec: docs/design-snapshots/rcu-arch-done-kill-reset.md (Kill; RA rev
//       127, RA rev 130); AR 336 (b), AR 338 (the detector's flops are
//       RCU's boundary flops for the kill inputs).
//
// kill_valid comes a cycle ahead of kill_epoch and kill_warp_mask. RCU's
// block clock gate opens on a wake only from the edge after next
// (ccv_common_clk), so asleep, the edge that ends K-1 never reaches
// rcu_kill or rcu_mig. This module runs on the ungated clock, the one wake
// detector CCV-L22 allows: kv_cr01h is kill_v_q in K for both, asleep as
// awake, with no cycle added. The edge that ends K, the first the wake
// opens, takes the epoch and the warp mask, under kv_cr01h: they are here in
// K+1 and held until the next kill, where rcu_mig reads the mask and
// rcu_kill the epoch, each under kill_v_q a cycle on (its own flop). The
// three inputs go straight into these flops (0 NGD in), RCU's boundary
// flops for them (AR's rev 285 (5), AR 338).
//
// Clock gating: the epoch and the mask, one gate (WE + NWP flops) enabled
// by kv_cr01h, this module's own flop (CG-5); kv_cr01h is written every
// cycle (the module's allowance). The reset is flopped before use (RST-1).
// Moved out of ccv_rcu (2026-11-09): a block top holds no flops of its own
// that no unit measures (check-cg).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK core_clk
`define CCV_RST rst_r01h
module rcu_kdet #(
  parameter int WE  = 2,     // kill_epoch
  parameter int NWP = 32     // kill_warp_mask
) (
  input  logic           core_clk,       // the ungated clock
  input  logic           rst_n,
  input  logic           kill_valid,     // K-1
  input  logic [WE-1:0]  kill_epoch,     // K
  input  logic [NWP-1:0] kill_warp_mask, // K
  output logic           kv_cr01h,       // kill_v_q, K
  output logic [WE-1:0]  kep_cr02h,      // the epoch of K, K+1 on
  output logic [NWP-1:0] km_cr02h        // the warp mask of K, K+1 on
);

  logic rst_cr01h_n;
  always_ff @(posedge core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  logic           kv_q_cr01h;
  logic [WE-1:0]  kep_q_cr02h;
  logic [NWP-1:0] km_q_cr02h;
  wire kd_en_cr01h = kv_q_cr01h;   // the epoch and the mask of K
  always_ff @(posedge core_clk) begin
    if (rst_r01h) kv_q_cr01h <= 1'b0;
    else          kv_q_cr01h <= kill_valid;
  end
  always_ff @(posedge core_clk) begin
    if (kd_en_cr01h) begin
      kep_q_cr02h <= kill_epoch;
      km_q_cr02h  <= kill_warp_mask;
    end
  end
  assign kv_cr01h  = kv_q_cr01h;
  assign kep_cr02h = kep_q_cr02h;
  assign km_cr02h  = km_q_cr02h;

endmodule
`undef CCV_CLK
`undef CCV_RST
