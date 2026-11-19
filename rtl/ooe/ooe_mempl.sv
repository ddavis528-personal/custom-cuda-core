//===-- ooe_mempl.sv - OOE memop payload: ccv_ooe_miu_memop's format ----===//
//
// Spec: OA 435 (3) (re:OI-171): ooe_mempl formats ccv_ooe_miu_memop's
//       fields from the RS entry it is given at select and drives the
//       channel from flops; the memop credits stay in ooe_sched. MA-5 (AR
//       345/347, OA-412): a memop goes on the lowest credited slot of its
//       footprint. A bulk discard (A-41, A-53, V-40) takes P0 for its
//       cycle, every field but its tag, warp, CTA slot and tail zero.
//
// The memop channel has a slot per MIU pipe, P0-P3. An MIU entry granted
// at select is read out on its home, the lowest pipe of its footprint, as
// ooe_rcupl's P slots are; its memop goes on the lowest pipe of its
// footprint that ooe_sched's credit flags allowed (cok, the flags the
// grant register's grants read), which may lie above its home. Co-issued
// memops have disjoint footprints (V-60), and a discard's cycle keeps
// every memop off P0 (ooe_sched's busy), so no slot takes two.
//
// As in ooe_rcupl, two registers: the slot's valid and its source, on the
// grant register's lead or the discard's (each flopped here, CG-5) and
// while a discard's valid is up, so it clears; and a cycle later the
// payload, from the late read of the source's entry (its ooe_ent_t, its
// ooe_mem_t and its RS index) or the discard's fields.
//
// The reference is the model's memops (Core's out.memops) formatted as
// ooe_block.cpp sends them; test/ooe/pl_tb.cpp compares every slot after
// every edge.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`include "ooe_pl.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_mempl #(
  parameter int NS  = 4,                 // MIU pipes (CCV_SECTIONS): P0..P(NS-1)
  localparam int EW = OOE_PL_EW,
  localparam int MW = OOE_PL_MW,
  localparam int DW = OOE_PL_DW,
  localparam int OW = OOE_PL_OW,
  localparam int WI = ccv_prov_pkg::CCV_P_W_RS_IDX
) (
  input  logic             ooe_core_clk,
  input  logic             ooe_rst_r00h,
  input  logic             gnt_l_cq01h,  // ooe_sched's grant register may change at the next edge
  input  logic             dsc_l_cq01h,  // a bulk discard may take P0 at the next edge
  input  logic [NS-1:0]    lv_cq02h,     // P home h is a granted MIU entry's
  input  logic [NS*NS-1:0] lfp_cq02h,    // its footprint (the lead read)
  input  logic [NS-1:0]    cok_cq02h,    // the credit flags its grant read (ooe_sched's cokd)
  input  logic             dv_cq02h,     // a bulk discard takes P0
  input  logic [NS*EW-1:0] pe_cq03h,     // each home's entry, the late read (ooe_ent_t)
  input  logic [NS*MW-1:0] pm_cq03h,     // its memop fields (ooe_mem_t)
  input  logic [NS*WI-1:0] pi_cq03h,     // its RS index
  input  logic [DW-1:0]    pd_cq03h,     // the discard's fields (ooe_dsc_t)
  output logic [NS-1:0]    mv_cq03h,     // ccv_ooe_miu_memop's valid per slot
  output logic [NS*OW-1:0] mo_pay_cq04h  // its payload, a cycle on
);

  // The reset, flopped before any use (RST-1).
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) rst_r01h <= ooe_rst_r00h;

  // The enables, from this module's own flops (CG-5): the grant
  // register's lead, the discard's, and a discard's valid while it is up;
  // the payload register's a cycle on.
  logic gen_cq02h, den_cq02h, pay_en_cq03h, dq_cq03h;
  logic en_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      gen_cq02h    <= 1'b0;
      den_cq02h    <= 1'b0;
      pay_en_cq03h <= 1'b0;
    end else begin
      gen_cq02h    <= gnt_l_cq01h;
      den_cq02h    <= dsc_l_cq01h;
      pay_en_cq03h <= en_cq03h;
    end
  end
  assign en_cq03h = gen_cq02h || den_cq02h || dq_cq03h;

  // Each home's pipe: the lowest of its footprint the flags allow. sel is
  // slot s's source home, one-hot.
  logic [NS*NS-1:0] sel_cq02h;
  logic [NS-1:0]    v_cq02h;
  always_comb begin
    sel_cq02h = '0;
    for (int h = 0; h < NS; h++) begin
      logic [NS-1:0] f;
      f = lfp_cq02h[h * NS +: NS] & cok_cq02h;
      f = f & (~f + NS'(1));
      for (int s = 0; s < NS; s++)
        sel_cq02h[s * NS + h] = lv_cq02h[h] && f[s];
    end
    for (int s = 0; s < NS; s++)
      v_cq02h[s] = sel_cq02h[s * NS +: NS] != '0 || (s == 0 && dv_cq02h);
  end
  // No slot takes two, and every granted home finds a pipe (V-60, MA-5).
  logic bad_cq02h;
  always_comb begin
    bad_cq02h = dv_cq02h && sel_cq02h[0 +: NS] != '0;
    for (int s = 0; s < NS; s++) bad_cq02h = bad_cq02h || !$onehot0(sel_cq02h[s * NS +: NS]);
    for (int h = 0; h < NS; h++)
      bad_cq02h = bad_cq02h || (lv_cq02h[h] && (lfp_cq02h[h * NS +: NS] & cok_cq02h) == '0);
  end
  `CCV_ASSERT(memop_slot, !en_cq03h || !bad_cq02h)

  // The valid register and each slot's source.
  logic [NS*NS-1:0] selq_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      mv_cq03h <= '0;
      dq_cq03h <= 1'b0;
    end else if (en_cq03h) begin
      mv_cq03h <= v_cq02h;
      dq_cq03h <= dv_cq02h;
    end
  end
  always_ff @(posedge ooe_core_clk)
    if (en_cq03h) selq_cq03h <= sel_cq02h;

  // The payload register: the source's fields, or the discard's on P0.
  for (genvar s = 0; s < NS; s++) begin : g_slot
    logic [EW-1:0] e_cq03h;
    logic [MW-1:0] m_cq03h;
    logic [WI-1:0] i_cq03h;
    always_comb begin
      e_cq03h = '0;
      m_cq03h = '0;
      i_cq03h = '0;
      for (int h = 0; h < NS; h++)
        if (selq_cq03h[s * NS + h]) begin
          e_cq03h = e_cq03h | pe_cq03h[h * EW +: EW];
          m_cq03h = m_cq03h | pm_cq03h[h * MW +: MW];
          i_cq03h = i_cq03h | pi_cq03h[h * WI +: WI];
        end
    end
    // The entry, in ooe_ent_t's order (its sources, positions and the
    // rest the RCU issue reads go unread here).
    logic [OOE_PL_WT-1:0]  etg_cq03h;
    logic [1:0]            erw_cq03h;
    logic [OOE_PL_WW-1:0]  ewp_cq03h;
    logic [OOE_PL_WL-1:0]  eim_cq03h;
    logic [OOE_PL_NS-1:0]  efp_cq03h;
    logic [EW - OOE_PL_WT - 2 - OOE_PL_WW - OOE_PL_WL - OOE_PL_NS - 1:0] ers_cq03h;
    assign {etg_cq03h, erw_cq03h, ewp_cq03h, eim_cq03h, efp_cq03h, ers_cq03h} = e_cq03h;
    // The memop fields, in ooe_mem_t's order.
    logic [OOE_PL_WR-1:0]                         mdr_cq03h;
    logic [OOE_PL_WPS-1:0]                        mdp_cq03h;
    logic [OOE_PL_WPP-1:0]                        mpp_cq03h;
    logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]    mct_cq03h;
    logic [ccv_prelim_pkg::CCV_L_W_MEM_OP-1:0]    mop_cq03h;
    logic [OOE_PL_WCW-1:0]                        mcw_cq03h;
    logic [ccv_params_pkg::CCV_W_DISP-1:0]        mds_cq03h;
    logic                                         mse_cq03h;
    logic [ccv_params_pkg::CCV_L_W_SPACE-1:0]     msp_cq03h;
    logic [ccv_params_pkg::CCV_L_W_ORDERING-1:0]  mor_cq03h;
    logic                                         msf_cq03h;
    logic [3:0]                                   mas_cq03h;
    logic                                         mlf_cq03h;
    logic [1:0]                                   mxs_cq03h;
    logic                                         mxg_cq03h;
    assign {mdr_cq03h, mdp_cq03h, mpp_cq03h, mct_cq03h, mop_cq03h, mcw_cq03h, mds_cq03h, mse_cq03h, msp_cq03h,
            mor_cq03h, msf_cq03h, mas_cq03h, mlf_cq03h, mxs_cq03h, mxg_cq03h} = m_cq03h;
    // The discard's (P0 only).
    logic [OOE_PL_WT-1:0]                       dtg_cq03h;
    logic [OOE_PL_WW-1:0]                       dwp_cq03h;
    logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]  dct_cq03h;
    logic [ccv_prov_pkg::CCV_P_W_ROB_IDX-1:0]   dtl_cq03h;
    logic                                       d_cq03h;
    if (s == 0) begin : g_dsc
      assign {dtg_cq03h, dwp_cq03h, dct_cq03h, dtl_cq03h} = pd_cq03h;
      assign d_cq03h = dq_cq03h;
    end else begin : g_ndsc
      assign {dtg_cq03h, dwp_cq03h, dct_cq03h, dtl_cq03h} = '0;
      assign d_cq03h = 1'b0;
    end

    logic [OOE_PL_WT-1:0]                         tg_cq04h;
    logic [1:0]                                   rw_cq04h;
    logic [WI-1:0]                                ri_cq04h;
    logic [OOE_PL_WR-1:0]                         dr_cq04h;
    logic [OOE_PL_WPS-1:0]                        dp_cq04h;
    logic [OOE_PL_WPP-1:0]                        pp_cq04h;
    logic [OOE_PL_WL-1:0]                         im_cq04h;
    logic [OOE_PL_WW-1:0]                         wp_cq04h;
    logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]    ct_cq04h;
    logic [ccv_prelim_pkg::CCV_L_W_MEM_OP-1:0]    op_cq04h;
    logic [OOE_PL_WCW-1:0]                        cw_cq04h;
    logic [OOE_PL_NS-1:0]                         pi_cq04h;
    logic [ccv_params_pkg::CCV_W_DISP-1:0]        ds_cq04h;
    logic                                         se_cq04h;
    logic [ccv_params_pkg::CCV_L_W_SPACE-1:0]     sp_cq04h;
    logic [ccv_params_pkg::CCV_L_W_ORDERING-1:0]  or_cq04h;
    logic                                         sf_cq04h;
    logic [3:0]                                   as_cq04h;
    logic                                         lf_cq04h;
    logic [1:0]                                   xs_cq04h;
    logic                                         xg_cq04h;
    always_ff @(posedge ooe_core_clk)
      if (pay_en_cq03h) begin
        tg_cq04h <= d_cq03h ? dtg_cq03h : etg_cq03h;
        rw_cq04h <= d_cq03h ? '0 : erw_cq03h;
        ri_cq04h <= d_cq03h ? '0 : i_cq03h;
        dr_cq04h <= d_cq03h ? '0 : mdr_cq03h;
        dp_cq04h <= d_cq03h ? '0 : mdp_cq03h;
        pp_cq04h <= d_cq03h ? '0 : mpp_cq03h;
        im_cq04h <= d_cq03h ? '0 : eim_cq03h;
        wp_cq04h <= d_cq03h ? dwp_cq03h : ewp_cq03h;
        ct_cq04h <= d_cq03h ? dct_cq03h : mct_cq03h;
        op_cq04h <= d_cq03h ? '1 : mop_cq03h;
        cw_cq04h <= d_cq03h ? '0 : mcw_cq03h;
        pi_cq04h <= d_cq03h ? '0 : efp_cq03h;
        ds_cq04h <= d_cq03h ? (ccv_params_pkg::CCV_W_DISP)'(dtl_cq03h) : mds_cq03h;
        se_cq04h <= !d_cq03h && mse_cq03h;
        sp_cq04h <= d_cq03h ? '0 : msp_cq03h;
        or_cq04h <= d_cq03h ? '0 : mor_cq03h;
        sf_cq04h <= !d_cq03h && msf_cq03h;
        as_cq04h <= d_cq03h ? '0 : mas_cq03h;
        lf_cq04h <= !d_cq03h && mlf_cq03h;
        xs_cq04h <= d_cq03h ? '0 : mxs_cq03h;
        xg_cq04h <= !d_cq03h && mxg_cq03h;
      end
    // The channel, in ccv_ooe_miu_memop_t's order.
    assign mo_pay_cq04h[s * OW +: OW] = {tg_cq04h, rw_cq04h, ri_cq04h, dr_cq04h, dp_cq04h, pp_cq04h, im_cq04h,
                                         wp_cq04h, ct_cq04h, op_cq04h, cw_cq04h, pi_cq04h, ds_cq04h, se_cq04h,
                                         sp_cq04h, or_cq04h, sf_cq04h, as_cq04h, lf_cq04h, xs_cq04h, xg_cq04h};
  end
endmodule
`undef CCV_CLK
`undef CCV_RST
