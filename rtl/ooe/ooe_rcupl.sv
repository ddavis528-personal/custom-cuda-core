//===-- ooe_rcupl.sv - OOE RCU issue payload: ccv_ooe_rcu_issue's format -===//
//
// Spec: OA 435 (2) (re:OI-171): ooe_rcupl formats ccv_ooe_rcu_issue's
//       fields from the RS entry it is given at select and drives the
//       channel from flops; OA 382's A2 row and OA 403's lead set apply.
//       The channel's slots, leads and copies: schema/interfaces.json
//       (slot_fields, lead_fields; RA-31, RA-43, RA 109, RA's revs 114 and
//       132, OA's rev 403 on RI-31) and sim/skel/stub.h (putIssueLead,
//       finishIssueLeads).
//
// The channel has a slot per select resource: S0-S3, the lane sections;
// P0-P3, the MIU pipes; R. An op goes on its footprint's lowest slot, its
// home, which ooe_rs reads it out on: the lead read (le) through the grant
// register, the late read (pe) through its copy a cycle later. Every other
// slot of its footprint carries a continuation: its rob tag and cont, the
// rest zero (ooe_block.cpp, sendIssues).
//
// Two registers, as ooe_rs held them before (OA's rev 343, (A)): the
// issue register, each slot's valid and its lead fields, clocked on the
// grant register's lead (gnt_l, flopped); and a cycle later the payload
// register, the rest. A payload field that copies a lead (kIssueLeadCopies)
// is loaded from the lead's flop, not read again: it is the same value a
// cycle on, and it costs the late read nothing. The others come from the
// late read: on its own slot for a lead, the continuation's source slot
// for its rob tag. Where a field leaves the payload (R's sources and imm,
// RA 109 (b), RA's rev 114 (2)) it is zero there, and a slot without a
// field (slot_fields) has no flop for it.
//
// The reference is the model's issues (Core's out.issues) formatted as
// ooe_block.cpp sends them; test/ooe/pl_tb.cpp compares every slot after
// every edge.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`include "ooe_pl.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_rcupl #(
  parameter int NS  = 4,                 // sections (CCV_SECTIONS): S and P slots each
  parameter int N   = 45,                // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int NR  = 30,                // the RCU class's, below the MIU class's
  localparam int K  = 2 * NS + 1,        // issue slots: S0..S(NS-1), P0..P(NS-1), R
  localparam int EW = OOE_PL_EW,
  localparam int IW = OOE_PL_IW
) (
  input  logic            ooe_core_clk,
  input  logic            ooe_rst_r00h,
  input  logic            gnt_l_cq01h,   // ooe_sched's grant register may change at the next edge
  input  logic [N-1:0]    gnt_cq01h,     // ooe_sched's grant register
  input  logic [N*K-1:0]  hq_cq02h,      // ooe_rs's entries: each one's home slot, one-hot
  input  logic [N*EW-1:0] lq_cq02h,      // its lead read (ooe_ent_t)
  input  logic [N*EW-1:0] pq_cq02h,      // its late read (ooe_ent_t)
  output logic [K-1:0]    iss_v_cq03h,   // ccv_ooe_rcu_issue's valid per slot
  output logic [K*IW-1:0] iss_pay_cq04h  // its payload: the lead fields with the valid, the rest a cycle on
);

  // The reset, flopped before any use (RST-1).
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) rst_r01h <= ooe_rst_r00h;

  // The registers' enables, from this module's own flops (CG-5): the
  // issue register's on the grant register's lead, the payload register's
  // a cycle on.
  logic iss_en_cq02h, pay_en_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      iss_en_cq02h <= 1'b0;
      pay_en_cq03h <= 1'b0;
    end else begin
      iss_en_cq02h <= gnt_l_cq01h;
      pay_en_cq03h <= iss_en_cq02h;
    end
  end

  // The RS read (OA's rev 343, (A); ooe_rsread): slot k's granted entry,
  // through the grant register (the lead read) and through its late copy,
  // gd, a cycle on (the rest), each over its slot's class: S and R the RCU
  // entries, P the MIU entries. gd is clocked on the grant register's lead,
  // so it clears with it; ooe_rs's pay_ready keeps every write off an entry
  // the grant register holds, so the late read sees it as it was.
  logic [N-1:0]    gd_cq03h;
  logic [K-1:0]    lv_cq02h, pv_cq03h;
  logic [K*EW-1:0] le_cq02h, pe_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h)          gd_cq03h <= '0;
    else if (iss_en_cq02h) gd_cq03h <= gnt_cq01h;
  end
  for (genvar c = 0; c < 3; c++) begin : g_rd
    localparam int K0 = c == 0 ? 0 : c == 1 ? NS : 2 * NS;
    localparam int KS = c == 2 ? 1 : NS;
    localparam int E0 = c == 1 ? NR : 0;
    localparam int E1 = c == 1 ? N : NR;
    ooe_rsread #(.N(N), .K(K), .K0(K0), .KS(KS), .E0(E0), .E1(E1), .W(EW)) u_l (
      .g_cq01h(gnt_cq01h), .h_cq01h(hq_cq02h), .q_cq01h(lq_cq02h),
      .v_cq01h(lv_cq02h[K0 +: KS]), .e_cq01h(le_cq02h[K0 * EW +: KS * EW]));
    ooe_rsread #(.N(N), .K(K), .K0(K0), .KS(KS), .E0(E0), .E1(E1), .W(EW)) u_p (
      .g_cq01h(gd_cq03h), .h_cq01h(hq_cq02h), .q_cq01h(pq_cq02h),
      .v_cq01h(pv_cq03h[K0 +: KS]), .e_cq01h(pe_cq03h[K0 * EW +: KS * EW]));
  end

  // A continuation on slot k: a lead below it in its group whose footprint
  // spans it (S and P groups; R has none). cs is its source, one-hot over
  // the group: footprints in a cycle are disjoint (V-60).
  logic [K*NS-1:0] cs_cq02h;
  logic [K-1:0]    cv_cq02h;
  always_comb
    for (int k = 0; k < K; k++) begin
      for (int i = 0; i < NS; i++)
        cs_cq02h[k * NS + i] = k < 2 * NS && (k < NS ? i : NS + i) < k && lv_cq02h[k < NS ? i : NS + i] &&
                               le_cq02h[(k < NS ? i : NS + i) * EW + OOE_PL_E_FP_LSB + (k < NS ? k : k - NS)];
      cv_cq02h[k] = cs_cq02h[k * NS +: NS] != '0;
    end
  // No slot takes two (V-60): ooe_rs's slot_onehot holds the leads, and a
  // lead and a continuation never share one.
  logic two_cq02h;
  always_comb begin
    two_cq02h = 1'b0;
    for (int k = 0; k < K; k++)
      two_cq02h = two_cq02h || (lv_cq02h[k] && cv_cq02h[k]) || !$onehot0(cs_cq02h[k * NS +: NS]);
  end
  `CCV_ASSERT(slot_one, !iss_en_cq02h || !two_cq02h)

  // The issue register: valid, own/continuation and the source, every
  // slot.
  logic [K-1:0]    own_cq03h;
  logic [K*NS-1:0] csq_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) iss_v_cq03h <= '0;
    else if (iss_en_cq02h) iss_v_cq03h <= lv_cq02h | cv_cq02h;
    else if (pay_en_cq03h) iss_v_cq03h <= '0;   // the cycle after a grant, with none behind it
  end
  always_ff @(posedge ooe_core_clk)
    if (iss_en_cq02h) begin
      own_cq03h <= lv_cq02h;
      csq_cq03h <= cs_cq02h;
    end
  // The late read finds the lead read's entries (pay_ready).
  `CCV_ASSERT(late_read, !pay_en_cq03h || pv_cq03h == own_cq03h)

  for (genvar k = 0; k < K; k++) begin : g_slot
    localparam bit IS_S = k < NS;
    localparam bit IS_P = k >= NS && k < 2 * NS;
    localparam bit IS_R = k == 2 * NS;
    localparam int G    = IS_P ? NS : 0;

    // The entries, in ooe_ent_t's order: l the lead read, p the late one.
    logic [OOE_PL_WT-1:0]    ltg_cq02h, ptg_cq03h;
    logic [1:0]              lrw_cq02h, prw_cq03h;
    logic [OOE_PL_WW-1:0]    lwp_cq02h, pwp_cq03h;
    logic [OOE_PL_WL-1:0]    lim_cq02h, pim_cq03h;
    logic [OOE_PL_NS-1:0]    lfp_cq02h, pfp_cq03h;
    logic [2:0]              lsu_cq02h, psu_cq03h;
    logic                    liu_cq02h, piu_cq03h, lmu_cq02h, pmu_cq03h, lgu_cq02h, pgu_cq03h;
    logic [OOE_PL_WPP-1:0]   lgp_cq02h, pgp_cq03h;
    logic [OOE_PL_WOP-1:0]   lop_cq02h, pop_cq03h;
    logic [OOE_PL_WR-1:0]    ldr_cq02h, pdr_cq03h;
    logic [OOE_PL_WPS-1:0]   ldp_cq02h, pdp_cq03h;
    logic [OOE_PL_WCW-1:0]   ldw_cq02h, pdw_cq03h;
    logic                    lpw_cq02h, ppw_cq03h;
    logic [OOE_PL_WPP-1:0]   lpd_cq02h, ppd_cq03h;
    logic                    lpn_cq02h, ppn_cq03h;
    logic [2*OOE_PL_WR-1:0]  lps_cq02h, pps_cq03h;
    logic [OOE_PL_WR-1:0]    lp2_cq02h, pp2_cq03h, lpo_cq02h, ppo_cq03h;
    logic [OOE_PL_WPS-1:0]   lod_cq02h, pod_cq03h;
    logic [3*OOE_PL_WPS-1:0] lsp_cq02h, psp_cq03h;
    logic [OOE_PL_WPP-1:0]   lpq_cq02h, ppq_cq03h;
    logic                    lme_cq02h, pme_cq03h;
    logic [OOE_PL_WBG-1:0]   lbg_cq02h, pbg_cq03h;
    logic [3*OOE_PL_WCW-1:0] lsw_cq02h, psw_cq03h;
    logic [OOE_PL_WCW-1:0]   lcw_cq02h, pcw_cq03h;
    logic [OOE_PL_WIM-1:0]   lim2_cq02h, pim2_cq03h;
    assign {ltg_cq02h, lrw_cq02h, lwp_cq02h, lim_cq02h, lfp_cq02h, lsu_cq02h, liu_cq02h, lmu_cq02h, lgu_cq02h,
            lgp_cq02h, lop_cq02h, ldr_cq02h, ldp_cq02h, ldw_cq02h, lpw_cq02h, lpd_cq02h, lpn_cq02h, lps_cq02h,
            lp2_cq02h, lpo_cq02h, lod_cq02h, lsp_cq02h, lpq_cq02h, lme_cq02h, lbg_cq02h, lsw_cq02h, lcw_cq02h,
            lim2_cq02h} = le_cq02h[k * EW +: EW];
    assign {ptg_cq03h, prw_cq03h, pwp_cq03h, pim_cq03h, pfp_cq03h, psu_cq03h, piu_cq03h, pmu_cq03h, pgu_cq03h,
            pgp_cq03h, pop_cq03h, pdr_cq03h, pdp_cq03h, pdw_cq03h, ppw_cq03h, ppd_cq03h, ppn_cq03h, pps_cq03h,
            pp2_cq03h, ppo_cq03h, pod_cq03h, psp_cq03h, ppq_cq03h, pme_cq03h, pbg_cq03h, psw_cq03h, pcw_cq03h,
            pim2_cq03h} = pe_cq03h[k * EW +: EW];

    // -- The lead fields (issue register) ------------------------------
    // Every slot: the enables, the guard, the copies of the op's own
    // fields. A continuation's are zero but cont (finishIssueLeads).
    logic [OOE_PL_NS-1:0]   sm_cq03h;
    logic [2:0]             su_cq03h;
    logic                   iu_cq03h, mu_cq03h, gu_cq03h, pw_cq03h, cn_cq03h, pn_cq03h;
    logic [OOE_PL_WPP-1:0]  gp_cq03h, pd_cq03h;
    logic [OOE_PL_WOP-1:0]  op_cq03h;
    logic [OOE_PL_WR-1:0]   dr_cq03h;
    logic [OOE_PL_WPS-1:0]  dp_cq03h;
    logic [OOE_PL_WCW-1:0]  dw_cq03h;
    logic [1:0]             rw_cq03h;
    always_ff @(posedge ooe_core_clk)
      if (iss_en_cq02h) begin
        sm_cq03h <= lv_cq02h[k] ? lfp_cq02h : '0;
        su_cq03h <= lv_cq02h[k] ? lsu_cq02h : '0;
        iu_cq03h <= lv_cq02h[k] && liu_cq02h;
        mu_cq03h <= lv_cq02h[k] && lmu_cq02h;
        gu_cq03h <= lv_cq02h[k] && lgu_cq02h;
        gp_cq03h <= lv_cq02h[k] ? lgp_cq02h : '0;
        op_cq03h <= lv_cq02h[k] ? lop_cq02h : '0;
        dr_cq03h <= lv_cq02h[k] ? ldr_cq02h : '0;
        dp_cq03h <= lv_cq02h[k] ? ldp_cq02h : '0;
        dw_cq03h <= lv_cq02h[k] ? ldw_cq02h : '0;
        rw_cq03h <= lv_cq02h[k] ? lrw_cq02h : '0;
        pw_cq03h <= lv_cq02h[k] && lpw_cq02h;
        pd_cq03h <= lv_cq02h[k] ? lpd_cq02h : '0;
        cn_cq03h <= !lv_cq02h[k] && cv_cq02h[k];
        pn_cq03h <= lv_cq02h[k] && lpn_cq02h;
      end
    // S0-S3 and R: the sources' rows (a copy on S, moved on R).
    logic [2*OOE_PL_WR-1:0] ps_cq03h;
    logic [OOE_PL_WR-1:0]   p2_cq03h;
    if (IS_S || IS_R) begin : g_src
      always_ff @(posedge ooe_core_clk)
        if (iss_en_cq02h) begin
          ps_cq03h <= lv_cq02h[k] ? lps_cq02h : '0;
          p2_cq03h <= lv_cq02h[k] ? lp2_cq02h : '0;
        end
    end else begin : g_nsrc
      assign ps_cq03h = '0;
      assign p2_cq03h = '0;
    end
    // S0-S3: the old destination and the sources' positions (copies).
    logic [OOE_PL_WR-1:0]    po_cq03h;
    logic [OOE_PL_WPS-1:0]   od_cq03h;
    logic [3*OOE_PL_WPS-1:0] sp_cq03h;
    if (IS_S) begin : g_old
      always_ff @(posedge ooe_core_clk)
        if (iss_en_cq02h) begin
          po_cq03h <= lv_cq02h[k] ? lpo_cq02h : '0;
          od_cq03h <= lv_cq02h[k] ? lod_cq02h : '0;
          sp_cq03h <= lv_cq02h[k] ? lsp_cq02h : '0;
        end
    end else begin : g_nold
      assign po_cq03h = '0;
      assign od_cq03h = '0;
      assign sp_cq03h = '0;
    end
    // R: its imm, moved to lead_rpsrc (RA's rev 114 (2)).
    logic [OOE_PL_WIM-1:0] rp_cq03h;
    if (IS_R) begin : g_rp
      always_ff @(posedge ooe_core_clk)
        if (iss_en_cq02h) rp_cq03h <= lv_cq02h[k] ? lim2_cq02h : '0;
    end else begin : g_nrp
      assign rp_cq03h = '0;
    end

    // -- The payload register, a cycle on ------------------------------
    // The copies, from the lead's flops; the rest from the late read, the
    // slot's own for a lead, the source's rob tag for a continuation.
    logic [OOE_PL_WT-1:0] stg_cq03h;
    always_comb begin
      stg_cq03h = '0;
      for (int i = 0; i < NS; i++)
        if (G + i < k && csq_cq03h[k * NS + i]) stg_cq03h = stg_cq03h | pe_cq03h[(G + i) * EW + OOE_PL_E_TAG_LSB +: OOE_PL_WT];
    end
    logic [OOE_PL_WT-1:0]     tg_cq04h;
    logic [1:0]               rwq_cq04h;
    logic [OOE_PL_WW-1:0]     wp_cq04h;
    logic [OOE_PL_WL-1:0]     im_cq04h;
    logic [OOE_PL_WR-1:0]     drq_cq04h;
    logic                     pnq_cq04h, pwq_cq04h, me_cq04h, cnq_cq04h;
    logic [OOE_PL_WPP-1:0]    pdq_cq04h, ppo_cq04h;
    logic [OOE_PL_NS-1:0]     fp_cq04h;
    logic [OOE_PL_WBG-1:0]    bg_cq04h;
    logic [3*OOE_PL_WCW-1:0]  sw_cq04h;
    logic [OOE_PL_WPS-1:0]    dpq_cq04h;
    logic [OOE_PL_WCW-1:0]    dwq_cq04h, cw_cq04h;
    logic [OOE_PL_WOP-1:0]    opq_cq04h;
    always_ff @(posedge ooe_core_clk)
      if (pay_en_cq03h) begin
        tg_cq04h  <= own_cq03h[k] ? ptg_cq03h : stg_cq03h;
        rwq_cq04h <= rw_cq03h;
        wp_cq04h  <= own_cq03h[k] ? pwp_cq03h : '0;
        im_cq04h  <= own_cq03h[k] ? pim_cq03h : '0;
        drq_cq04h <= dr_cq03h;
        pnq_cq04h <= pn_cq03h;
        pdq_cq04h <= pd_cq03h;
        ppo_cq04h <= own_cq03h[k] ? ppq_cq03h : '0;
        pwq_cq04h <= pw_cq03h;
        me_cq04h  <= own_cq03h[k] && pme_cq03h;
        cnq_cq04h <= cn_cq03h;
        fp_cq04h  <= sm_cq03h;
        bg_cq04h  <= own_cq03h[k] ? pbg_cq03h : '0;
        sw_cq04h  <= own_cq03h[k] ? psw_cq03h : '0;
        dpq_cq04h <= dp_cq03h;
        dwq_cq04h <= dw_cq03h;
        opq_cq04h <= op_cq03h;
        cw_cq04h  <= own_cq03h[k] ? pcw_cq03h : '0;
      end
    // The payload's sources and imm, S0-S3 and P0-P3 (slot_fields): on S
    // the lead's copies, on P the late read.
    logic [2*OOE_PL_WR-1:0] psq_cq04h;
    logic [OOE_PL_WR-1:0]   p2q_cq04h;
    logic [OOE_PL_WIM-1:0]  iq_cq04h;
    if (IS_S) begin : g_psrc
      always_ff @(posedge ooe_core_clk)
        if (pay_en_cq03h) begin
          psq_cq04h <= ps_cq03h;
          p2q_cq04h <= p2_cq03h;
          iq_cq04h  <= own_cq03h[k] ? pim2_cq03h : '0;
        end
    end else if (IS_P) begin : g_psrc
      always_ff @(posedge ooe_core_clk)
        if (pay_en_cq03h) begin
          psq_cq04h <= own_cq03h[k] ? pps_cq03h : '0;
          p2q_cq04h <= own_cq03h[k] ? pp2_cq03h : '0;
          iq_cq04h  <= own_cq03h[k] ? pim2_cq03h : '0;
        end
    end else begin : g_npsrc
      assign psq_cq04h = '0;
      assign p2q_cq04h = '0;
      assign iq_cq04h  = '0;
    end
    // The old destination and the sources' positions: on S the lead's
    // copies, elsewhere the late read.
    logic [OOE_PL_WR-1:0]    poq_cq04h;
    logic [OOE_PL_WPS-1:0]   odq_cq04h;
    logic [3*OOE_PL_WPS-1:0] spq_cq04h;
    always_ff @(posedge ooe_core_clk)
      if (pay_en_cq03h) begin
        poq_cq04h <= IS_S ? po_cq03h : own_cq03h[k] ? ppo_cq03h : '0;
        odq_cq04h <= IS_S ? od_cq03h : own_cq03h[k] ? pod_cq03h : '0;
        spq_cq04h <= IS_S ? sp_cq03h : own_cq03h[k] ? psp_cq03h : '0;
      end

    // -- The channel, in ccv_ooe_rcu_issue_t's order -------------------
    assign iss_pay_cq04h[k * IW +: IW] = {
        tg_cq04h, rwq_cq04h, wp_cq04h, im_cq04h, psq_cq04h, p2q_cq04h, drq_cq04h, poq_cq04h, pnq_cq04h,
        pdq_cq04h, ppo_cq04h, pwq_cq04h, me_cq04h, cnq_cq04h, fp_cq04h, bg_cq04h, spq_cq04h, sw_cq04h,
        dpq_cq04h, odq_cq04h, dwq_cq04h, opq_cq04h, iq_cq04h, cw_cq04h,
        sm_cq03h, su_cq03h, iu_cq03h, mu_cq03h, gu_cq03h, gp_cq03h, op_cq03h, dr_cq03h, dp_cq03h, dw_cq03h,
        rw_cq03h, pw_cq03h, pd_cq03h, cn_cq03h, pn_cq03h, rp_cq03h, ps_cq03h, p2_cq03h, po_cq03h, od_cq03h,
        sp_cq03h};
  end
endmodule
`undef CCV_CLK
`undef CCV_RST
