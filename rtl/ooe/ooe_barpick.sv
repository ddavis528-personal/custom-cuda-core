//===-- ooe_barpick.sv - OOE's barrier reports to SYU ---------------------===//
//
// Spec: OA 448 (re:OI-180), option (B): each ooe_rob_w holds one retired
//       barrier report, its side buffer's oldest place marked retired
//       (bq), until this module picks it; one report leaves a cycle on
//       ccv_ooe_syu_bar (rate 1), the slots taken in rotation.
//
// The reference is the model's bar_pend (Core::retire): a retired report
// waits in its slot; each cycle the next waiting slot after the last one
// sent is picked, and its report sent a cycle later.
//
// Timing: a slot's request (bq, from ooe_rob_w's flops) is flopped here,
// and the pick is made from those flops alone, so nothing passes straight
// through. The grant goes back to ooe_rob_w, whose place frees at the end
// of the grant's cycle; until then its payload outputs hold the report, so
// the report register takes them in the grant's cycle. The request flop is
// cleared by its own grant, so a place is never picked twice. Each slot's
// warp and CTA slot come from ooe_slot, which holds them while a report
// waits (the slot does not drain with a report held).
//
// The rotation is a mask of the slots after the last grant (hm): the pick is
// the lowest request in it, else the lowest request, so the grant is two
// priority picks and a select from flops (no index arithmetic), and the
// report's fields are an AND-OR by the one-hot grant.
//
// Local clock gating: the requests and the rotation mask are under 8 flops
// each; the report's payload on a request (|rq), from this module's flops
// alone (CG-5); the report's valid on its own value or a request. The
// reset is flopped (RST-1).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_barpick #(
  parameter int S  = 4,       // tier-1 slots (CCV_TIER1_WARPS): one ooe_rob_w each
  parameter int WW = 5,       // a warp_id (CCV_W_WARP_ID)
  parameter int WT = 4,       // a CTA slot (CCV_P_W_CTA_SLOT)
  parameter int WB = 4        // a barrier id (CCV_W_BAR_ID)
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  // From each ooe_rob_w (instance s at slot s): a report waits, and its
  // payload, held until the cycle after its grant.
  input  logic [S-1:0]      bq_cq02h,
  input  logic [S*2-1:0]    bq_kind_cq03h,
  input  logic [S*WB-1:0]   bq_bid_cq03h,
  input  logic [S*32-1:0]   bq_im_cq03h,
  input  logic [S*32-1:0]   bq_gm_cq03h,
  input  logic [S*32-1:0]   bq_pm_cq03h,
  input  logic [S-1:0]      bq_held_cq03h,
  // From ooe_slot: each slot's warp and CTA slot.
  input  logic [S*WW-1:0]   warp_cq03h,
  input  logic [S*WT-1:0]   cta_cq03h,
  // To each ooe_rob_w: its report is taken (its place frees next cycle).
  output logic [S-1:0]      gn_cq03h,
  // ccv_ooe_syu_bar.
  output logic              bar_v_cq04h,
  output logic [WW-1:0]     bar_warp_cq04h,
  output logic [WT-1:0]     bar_cta_cq04h,
  output logic [WB-1:0]     bar_bid_cq04h,
  output logic [1:0]        bar_kind_cq04h,
  output logic [31:0]       bar_im_cq04h,
  output logic [31:0]       bar_gm_cq04h,
  output logic [31:0]       bar_pm_cq04h,
  output logic              bar_held_cq04h
);

  // The reset, flopped before any use (RST-1).
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  `CCV_ASSERT_KNOWN(bq_known, bq_cq02h)

  // The requests, flopped, each cleared by its own grant; the slots after
  // the last one granted (hm: the rotation, as a mask).
  logic [S-1:0] rq_cq03h, hm_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) rq_cq03h <= '0;
    else          rq_cq03h <= bq_cq02h & ~gn_cq03h;
  end

  // The pick: the lowest request after the last grant, else the lowest.
  logic [S-1:0] ra_cq03h, ga_cq03h, gb_cq03h;
  always_comb begin
    ra_cq03h = rq_cq03h & hm_cq03h;
    ga_cq03h = ra_cq03h & ~(ra_cq03h - S'(1));
    gb_cq03h = rq_cq03h & ~(rq_cq03h - S'(1));
    gn_cq03h = (|ra_cq03h) ? ga_cq03h : gb_cq03h;
  end
  `CCV_ASSERT(pick_one_hot, $onehot0(gn_cq03h) && ((rq_cq03h == '0) == (gn_cq03h == '0)))

  // After a grant, the slots above it.
  logic hm_en_cq03h;
  assign hm_en_cq03h = |rq_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) hm_cq03h <= '1;
    else if (hm_en_cq03h) hm_cq03h <= ~(gn_cq03h | (gn_cq03h - S'(1)));
  end

  // The report.
  logic rv_en_cq03h;
  assign rv_en_cq03h = (|rq_cq03h) || bar_v_cq04h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) bar_v_cq04h <= 1'b0;
    else if (rv_en_cq03h) bar_v_cq04h <= |rq_cq03h;
  end

  // Its fields, by the grant (one-hot).
  logic [WW-1:0] fw_cq03h;
  logic [WT-1:0] ft_cq03h;
  logic [WB-1:0] fb_cq03h;
  logic [1:0]    fk_cq03h;
  logic [31:0]   fi_cq03h, fg_cq03h, fp_cq03h;
  logic          fh_cq03h;
  always_comb begin
    {fw_cq03h, ft_cq03h, fb_cq03h, fk_cq03h, fi_cq03h, fg_cq03h, fp_cq03h, fh_cq03h} = '0;
    for (int s = 0; s < S; s++) begin
      fw_cq03h = fw_cq03h | ({WW{gn_cq03h[s]}} & warp_cq03h[s * WW +: WW]);
      ft_cq03h = ft_cq03h | ({WT{gn_cq03h[s]}} & cta_cq03h[s * WT +: WT]);
      fb_cq03h = fb_cq03h | ({WB{gn_cq03h[s]}} & bq_bid_cq03h[s * WB +: WB]);
      fk_cq03h = fk_cq03h | ({2{gn_cq03h[s]}} & bq_kind_cq03h[s * 2 +: 2]);
      fi_cq03h = fi_cq03h | ({32{gn_cq03h[s]}} & bq_im_cq03h[s * 32 +: 32]);
      fg_cq03h = fg_cq03h | ({32{gn_cq03h[s]}} & bq_gm_cq03h[s * 32 +: 32]);
      fp_cq03h = fp_cq03h | ({32{gn_cq03h[s]}} & bq_pm_cq03h[s * 32 +: 32]);
      fh_cq03h = fh_cq03h | (gn_cq03h[s] & bq_held_cq03h[s]);
    end
  end
  logic rp_en_cq03h;
  assign rp_en_cq03h = |rq_cq03h;
  always_ff @(posedge ooe_core_clk)
    if (rp_en_cq03h) begin
      bar_warp_cq04h <= fw_cq03h;
      bar_cta_cq04h  <= ft_cq03h;
      bar_bid_cq04h  <= fb_cq03h;
      bar_kind_cq04h <= fk_cq03h;
      bar_im_cq04h   <= fi_cq03h;
      bar_gm_cq04h   <= fg_cq03h;
      bar_pm_cq04h   <= fp_cq03h;
      bar_held_cq04h <= fh_cq03h;
    end

endmodule
`undef CCV_CLK
`undef CCV_RST
