//===-- ooe_mempl.sv - OOE memop payload: ccv_ooe_miu_memop's format ----===//
//
// Spec: OA 435 (3) (re:OI-171): ooe_mempl formats ccv_ooe_miu_memop's
//       fields from the RS entry it is given at select and drives the
//       channel from flops; the memop credits stay in ooe_sched. MA-5 (AR
//       345/347, OA-412): a memop goes on the lowest credited slot of its
//       footprint. A bulk discard (A-41, A-53, V-40) takes P0 for its
//       cycle, every field but its tag, warp and tail zero.
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
// memop grant's lead or the discard's (each flopped here, CG-5),
// cleared a cycle on behind a cycle with none; and a cycle later each
// slot's payload, loaded only when the slot is valid, from the late read of the source's entry (its ooe_ent_t, its
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
  parameter int N   = 45,                // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int NR  = 30,                // the RCU class's, below the MIU class's
  localparam int K  = 2 * NS + 1,        // ooe_rs's home slots: S0..S(NS-1), P0..P(NS-1), R
  localparam int EW = OOE_PL_EW,
  localparam int MW = OOE_PL_MW,
  localparam int DW = OOE_PL_DW,
  localparam int OW = OOE_PL_OW,
  localparam int WI = ccv_prov_pkg::CCV_P_W_RS_IDX
) (
  input  logic             ooe_core_clk,
  input  logic             ooe_rst_r00h,
  input  logic             mgl_cq01h,    // ooe_sched may grant a memop at the next edge (a lead; a superset will do)
  input  logic             dsc_l_cq01h,  // a bulk discard may take P0 at the next edge
  input  logic [N-1:0]     gnt_cq01h,    // ooe_sched's grant register
  input  logic [N*K-1:0]   hq_cq02h,     // ooe_rs's entries: each one's home slot, one-hot
  input  logic [N*EW-1:0]  lq_cq02h,     // its lead read (ooe_ent_t)
  input  logic [N*EW-1:0]  pq_cq02h,     // its late read (ooe_ent_t)
  input  logic [NS-1:0]    cok_cq02h,    // the credit flags its grant read (ooe_sched's cokd)
  input  logic             dv_cq02h,     // a bulk discard takes P0
  input  logic [NS*MW-1:0] pm_cq03h,     // its memop fields (ooe_mem_t)
  input  logic [NS*WI-1:0] pi_cq03h,     // its RS index
  input  logic [DW-1:0]    pd_cq03h,     // the discard's fields (ooe_dsc_t)
  output logic [NS-1:0]    mv_cq03h,     // ccv_ooe_miu_memop's valid per slot
  output logic [NS*OW-1:0] mo_pay_cq04h  // its payload, a cycle on
);

  // The reset, flopped before any use (RST-1).
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) rst_r01h <= ooe_rst_r00h;

  // The enables, from this module's own flops (CG-5): the memop grant's
  // lead and the discard's, and either a cycle on, which clears the
  // valids behind a cycle with none. Only the memop grant's lead, not the
  // grant register's: memops are a few of the grants, and the valids'
  // gate would idle on the rest.
  logic gen_cq02h, den_cq02h, pay_en_cq03h, dq_cq03h;
  logic ld_en_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      gen_cq02h    <= 1'b0;
      den_cq02h    <= 1'b0;
      pay_en_cq03h <= 1'b0;
    end else begin
      gen_cq02h    <= mgl_cq01h;
      den_cq02h    <= dsc_l_cq01h;
      pay_en_cq03h <= ld_en_cq02h;
    end
  end
  assign ld_en_cq02h = gen_cq02h || den_cq02h;

  // The RS read (OA's rev 343, (A); ooe_rsread) over the MIU entries, P
  // home h's granted entry: its footprint through the grant register (the
  // lead read), the entry through gd, its copy a cycle on, clocked on the
  // memop grant's lead (ooe_rs's pay_ready keeps the entry as it was),
  // loaded under the valid register's gate below.
  logic [N*NS-1:0]  fq_cq02h;
  logic [NS-1:0]    lv_cq02h, gv_cq03h;
  logic [NS*NS-1:0] lfp_cq02h;
  logic [NS*EW-1:0] pe_cq03h;
  logic [N-1:NR]    gd_cq03h;
  always_comb
    for (int e = 0; e < N; e++) fq_cq02h[e * NS +: NS] = lq_cq02h[e * EW + OOE_PL_E_FP_LSB +: NS];
  ooe_rsread #(.N(N), .K(K), .K0(NS), .KS(NS), .E0(NR), .E1(N), .W(NS)) u_l (
    .g_cq01h(gnt_cq01h), .h_cq01h(hq_cq02h), .q_cq01h(fq_cq02h), .v_cq01h(lv_cq02h), .e_cq01h(lfp_cq02h));
  ooe_rsread #(.N(N), .K(K), .K0(NS), .KS(NS), .E0(NR), .E1(N), .W(EW)) u_p (
    .g_cq01h({gd_cq03h, {NR{1'b0}}}), .h_cq01h(hq_cq02h), .q_cq01h(pq_cq02h), .v_cq01h(gv_cq03h),
    .e_cq01h(pe_cq03h));

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
  `CCV_ASSERT(memop_slot, !ld_en_cq02h || !bad_cq02h)
  // A granted memop came with its lead, and a discard with its own.
  `CCV_ASSERT(memop_lead, rst_r01h || ((lv_cq02h == '0 || gen_cq02h) && (!dv_cq02h || den_cq02h)))

  // The valid register, each slot's source, and the payload's enable per
  // slot (a copy of the valid: a register that drives an output starts no
  // other path), all under one gate: loaded on a memop grant or a discard,
  // cleared the cycle after one with none behind it.
  logic             vld_en_cq02h;
  logic [NS*NS-1:0] selq_cq03h;
  (* keep *) logic [NS-1:0] pv_cq03h;
  assign vld_en_cq02h = ld_en_cq02h || pay_en_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      mv_cq03h   <= '0;
      pv_cq03h   <= '0;
      dq_cq03h   <= 1'b0;
      selq_cq03h <= '0;
      gd_cq03h   <= '0;
    end else if (vld_en_cq02h) begin
      mv_cq03h   <= ld_en_cq02h ? v_cq02h : '0;
      pv_cq03h   <= ld_en_cq02h ? v_cq02h : '0;
      dq_cq03h   <= ld_en_cq02h && dv_cq02h;
      selq_cq03h <= ld_en_cq02h ? sel_cq02h : '0;
      // The grant, unconditionally: read only through a home the valid
      // register took, which a discard or a clear never does.
      gd_cq03h   <= gnt_cq01h[N-1:NR];
    end
  end

  // The late read finds every home the valid register took (pay_ready).
  logic [NS-1:0] src_cq03h;
  always_comb begin
    src_cq03h = '0;
    for (int s = 0; s < NS; s++) src_cq03h = src_cq03h | selq_cq03h[s * NS +: NS];
  end
  `CCV_ASSERT(late_read, (src_cq03h & ~gv_cq03h) == '0)

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
    logic [OOE_PL_WPS-1:0]                        mdq_cq03h;
    logic [ccv_params_pkg::CCV_W_DISP-1:0]        mds_cq03h;
    logic                                         mse_cq03h;
    logic [ccv_params_pkg::CCV_L_W_SPACE-1:0]     msp_cq03h;
    logic [ccv_params_pkg::CCV_L_W_ORDERING-1:0]  mor_cq03h;
    logic                                         msf_cq03h;
    logic [3:0]                                   mas_cq03h;
    logic                                         mlf_cq03h;
    logic [1:0]                                   mxs_cq03h;
    logic                                         mxg_cq03h;
    assign {mdr_cq03h, mdp_cq03h, mpp_cq03h, mct_cq03h, mop_cq03h, mcw_cq03h, mdq_cq03h, mds_cq03h, mse_cq03h, msp_cq03h,
            mor_cq03h, msf_cq03h, mas_cq03h, mlf_cq03h, mxs_cq03h, mxg_cq03h} = m_cq03h;
    // The pipes: the data register's sections at its width (stub.h's
    // maskOf: a 32-bit register spans four, 16-bit two, narrower one).
    logic [OOE_PL_NS-1:0] mpi_cq03h;
    always_comb begin
      logic [2*OOE_PL_NS-1:0] span;
      span = mcw_cq03h == '0 ? (2*OOE_PL_NS)'(4'hF) : mcw_cq03h == OOE_PL_WCW'(1) ? (2*OOE_PL_NS)'(4'h3)
                                                                            : (2*OOE_PL_NS)'(4'h1);
      span = span << mdq_cq03h;
      mpi_cq03h = span[OOE_PL_NS-1:0];
    end
    // The discard's (P0 only).
    logic [OOE_PL_WT-1:0]                       dtg_cq03h;
    logic [OOE_PL_WW-1:0]                       dwp_cq03h;
    logic [ccv_prov_pkg::CCV_P_W_ROB_IDX-1:0]   dtl_cq03h;
    logic                                       d_cq03h;
    if (s == 0) begin : g_dsc
      assign {dtg_cq03h, dwp_cq03h, dtl_cq03h} = pd_cq03h;
      assign d_cq03h = dq_cq03h;
    end else begin : g_ndsc
      assign {dtg_cq03h, dwp_cq03h, dtl_cq03h} = '0;
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
    // Loaded only when this slot carries a memop or the discard.
    logic pl_en_cq03h;
    assign pl_en_cq03h = pv_cq03h[s];
    always_ff @(posedge ooe_core_clk)
      if (pl_en_cq03h) begin
        tg_cq04h <= d_cq03h ? dtg_cq03h : etg_cq03h;
        rw_cq04h <= d_cq03h ? '0 : erw_cq03h;
        ri_cq04h <= d_cq03h ? '0 : i_cq03h;
        dr_cq04h <= d_cq03h ? '0 : mdr_cq03h;
        dp_cq04h <= d_cq03h ? '0 : mdp_cq03h;
        pp_cq04h <= d_cq03h ? '0 : mpp_cq03h;
        im_cq04h <= d_cq03h ? '0 : eim_cq03h;
        wp_cq04h <= d_cq03h ? dwp_cq03h : ewp_cq03h;
        ct_cq04h <= d_cq03h ? '0 : mct_cq03h;
        op_cq04h <= d_cq03h ? '1 : mop_cq03h;
        cw_cq04h <= d_cq03h ? '0 : mcw_cq03h;
        pi_cq04h <= d_cq03h ? '0 : mpi_cq03h;
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
