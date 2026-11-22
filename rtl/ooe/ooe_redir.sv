//===-- ooe_redir.sv - OOE's redirects and checkpoint frees to FET --------===//
//
// Spec: OA 435 (5a) (re:OI-171, the register's OA tab): ooe_redir drives
//       every FET-bound channel but the decode-queue credit:
//       ccv_ooe_fet_redirect, rate 1 (A-6), and ccv_ooe_fet_ckpt_free, the
//       per-instance frees ORed and flopped (A-56), latency-matched with
//       the redirect (A-58). OA 447 (re:OI-179): the squash's advance,
//       flushes and RAT restore take ooe_rob_w's resolution flop directly;
//       this module only sends to FET. 5a is the mispredict path; the
//       epoch-only notices, the rewind beats (own_pc, held) and the landed
//       pulse land with 5b (OA 435), so those fields are 0 here, and the
//       notice's checkpoint mask (TI-485, OA 438) is an input.
//
// The reference is the model's redirect queue (Core::resolveBranch,
// Core::sendRedirect): a mispredict queues its redirect, a newer one of the
// same slot supersedes it (the newer is for an older branch: the squash of
// the first took the second's), and one leaves a cycle, oldest first, a
// cycle's ties in slot order (OI-179). So at most one waits per slot: each
// slot's entry, valid, and an age order between the slots' entries. A slot
// whose redirect arrives takes the youngest age, as the supersede's
// push_back does.
//
// Timing: ooe_rob_w's resolution flop rd_l is high in the squash's cycle,
// a cycle after the model's resolve; its payload follows a cycle later. The
// redirect's warp and epoch come from ooe_decrx's flopped slot copies, read
// in rd_l's cycle, before that squash's advance: the epoch after the
// slot's, as the model's redirect carries it (squash_act_lag 1). The pick
// is made in rd_l's cycle among the waiting entries and the arriving ones
// (an arriving entry is younger than every waiting one) and registered:
// the channel's valid from a flop a cycle after rd_l, its payload a cycle
// after that, so two cycles after the model's send. The frees: each
// instance's ckf (its checkpoints, OA 427's cycle later) arrives in the
// cycle rd_l would, so the free channel's valid comes from a flop a cycle
// later and its mask a cycle after that, in the same relation as the
// redirect's: a free sent with a redirect lands with it (A-58). A slot's
// frees are masked from its epoch-only notice's cycle (OA 438).
//
// Local clock gating: the entries' order and valids on any waiting entry
// or any slot's resolution lead (rd_e, ooe_rob_w's resolution enable a
// cycle before rd_l, flopped here); each slot's warp and epoch on its own
// lead's flop; each slot's payload on its own flop of rd_l; the channel's
// payload on its valid; the free mask on its valid. The reset is flopped
// (RST-1).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_redir #(
  parameter int S   = 4,       // tier-1 slots (CCV_TIER1_WARPS): one ooe_rob_w each
  parameter int NK  = 4,       // branch checkpoints a slot (CCV_P_BR_CKPTS)
  parameter int PCW = 48,      // ooe_rob_w's pc
  parameter int VA  = 64,      // the channel's target_pc (CCV_W_VA)
  parameter int WW  = 5,       // a warp_id (CCV_W_WARP_ID)
  parameter int EP  = 3,       // a fetch epoch (CCV_P_W_FETCH_EPOCH)
  parameter int PWV = 1,       // OI-184's lag-1 option: the payload leaves with the valid
  localparam int LS = (S > 1) ? $clog2(S) : 1,
  localparam int LK = (NK > 1) ? $clog2(NK) : 1
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  // From each ooe_rob_w (instance s at slot s).
  input  logic [S-1:0]      rd_e_cq02h,     // its resolution enable: rd_l may rise next cycle
  input  logic [S-1:0]      rd_l_cq03h,     // a mispredict's squash: the redirect's lead
  input  logic [S*LK-1:0]   rd_ckpt_cq04h,  // a cycle after it: the checkpoint,
  input  logic [S*32-1:0]   rd_tmask_cq04h, // the lanes that took the branch,
  input  logic [S*PCW-1:0]  rd_tgt_cq04h,   // the target,
  input  logic [S-1:0]      rd_stay_cq04h,  // a ret's stay
  // PWV: the same payload in rd_l's cycle (ooe_rob_w's PWV form), whose
  // cq04h ports are then 0.
  input  logic [S*LK-1:0]   rd_ckpt_cq03h,
  input  logic [S*32-1:0]   rd_tmask_cq03h,
  input  logic [S*PCW-1:0]  rd_tgt_cq03h,
  input  logic [S-1:0]      rd_stay_cq03h,
  input  logic [S-1:0]      ckf_l_cq02h,    // its frees may show next cycle (its frv)
  input  logic [S*NK-1:0]   ckf_cq03h,      // the checkpoints right branches free
  // From ooe_decrx: each slot's warp and the epoch after its own, flopped.
  input  logic [S*WW-1:0]   wid_cq03h,
  input  logic [S*EP-1:0]   ep1_cq03h,
  // From ooe_slot (5b; 0 until then): a slot's epoch-only notice, from
  // whose cycle its frees are dropped (OA 438).
  input  logic [S-1:0]      ntm_cq03h,
  // ccv_ooe_fet_redirect: the valid, then the payload a cycle later.
  output logic              rdr_v_cq04h,
  output logic [WW-1:0]     rdr_warp_cq05h,
  output logic [LS-1:0]     rdr_t1_cq05h,
  output logic [LK-1:0]     rdr_ckpt_cq05h,
  output logic [31:0]       rdr_tmask_cq05h,
  output logic [VA-1:0]     rdr_tgt_cq05h,
  output logic [EP-1:0]     rdr_ep_cq05h,
  output logic              rdr_eo_cq05h,   // epoch_only
  output logic              rdr_rw_cq05h,   // rewind
  output logic              rdr_rh_cq05h,   // rewind_held
  output logic              rdr_hl_cq05h,   // held_long
  output logic              rdr_own_cq05h,  // own_pc
  output logic              rdr_stay_cq05h,
  // ccv_ooe_fet_ckpt_free: the valid, then the mask a cycle later.
  output logic              ckf_v_cq04h,
  output logic [S*NK-1:0]   ckf_m_cq05h
);

  // The reset, flopped before any use (RST-1).
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  `CCV_ASSERT_KNOWN(rd_l_known, rd_l_cq03h)
  `CCV_ASSERT_KNOWN(ckf_known, ckf_cq03h)
  `CCV_ASSERT_KNOWN(ntm_known, ntm_cq03h)

  // The leads, flopped, written every cycle (CG-5's lead capture, within the
  // module's allowance): each slot's resolution enable, and one flop for the
  // frees' lead (only its OR is used).
  logic [S-1:0] re_q_cq03h;
  logic         fl_q_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      re_q_cq03h <= '0;
      fl_q_cq03h <= 1'b0;
    end else begin
      re_q_cq03h <= rd_e_cq02h;
      fl_q_cq03h <= |ckf_l_cq02h;
    end
  end
  `CCV_ASSERT(rd_led, (rd_l_cq03h & ~re_q_cq03h) == '0)
  `CCV_ASSERT(ckf_led, (|ckf_cq03h) == 1'b0 || fl_q_cq03h)

  // The entries: valid (waiting), and the age order between slots
  // (ag[i * S + j]: i's entry is older than j's).
  logic [S-1:0]   pv_cq03h, pv_nx_cq03h, cand_cq03h, nw_cq03h, pick_cq03h;
  logic [S*S-1:0] ag_cq03h, ag_nx_cq03h;
  // i older than j among the candidates: a waiting entry (not superseded
  // now) before an arriving one; two waiting by their order; two arriving
  // lowest slot first.
  function automatic logic older(input logic [S-1:0] w, input logic [S*S-1:0] ag, input int i, input int j);
    if (w[i] && w[j])      older = ag[i * S + j];
    else if (w[i] != w[j]) older = w[i];
    else                   older = i < j;
  endfunction
  logic [S-1:0] wt_cq03h;   // waiting and not superseded now
  always_comb begin
    wt_cq03h   = pv_cq03h & ~rd_l_cq03h;
    nw_cq03h   = rd_l_cq03h;
    cand_cq03h = wt_cq03h | nw_cq03h;
    for (int i = 0; i < S; i++) begin
      pick_cq03h[i] = cand_cq03h[i];
      for (int j = 0; j < S; j++)
        if (j != i && cand_cq03h[j] && !older(wt_cq03h, ag_cq03h, i, j)) pick_cq03h[i] = 1'b0;
      for (int j = 0; j < S; j++) ag_nx_cq03h[i * S + j] = (j != i) && older(wt_cq03h, ag_cq03h, i, j);
    end
    pv_nx_cq03h = cand_cq03h & ~pick_cq03h;
  end
  `CCV_ASSERT(pick_one_hot, $onehot0(pick_cq03h) && ((cand_cq03h == '0) == (pick_cq03h == '0)))

  // The order and the send's valid share one gate: while nothing waits or
  // arrives, the next order is the idle one and the send clears, so the
  // send's own valid only widens it to clear itself. Which slot, and whether
  // it arrived in the pick's cycle (its payload then on ooe_rob_w's outputs,
  // else in its entry), sit in the PWV form's own block.
  logic         ord_en_cq03h;
  assign ord_en_cq03h = (|pv_cq03h) || (|re_q_cq03h) || rdr_v_cq04h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      pv_cq03h    <= '0;
      ag_cq03h    <= '0;
      rdr_v_cq04h <= 1'b0;
    end else if (ord_en_cq03h) begin
      pv_cq03h    <= pv_nx_cq03h;
      ag_cq03h    <= ag_nx_cq03h;
      rdr_v_cq04h <= |pick_cq03h;
    end
  end

  if (PWV == 0) begin : g_f2
  logic [S-1:0] pk_cq04h, pn_cq04h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      pk_cq04h <= '0;
      pn_cq04h <= '0;
    end else if (ord_en_cq03h) begin
      pk_cq04h <= pick_cq03h;
      pn_cq04h <= pick_cq03h & nw_cq03h;
    end
  end
  // Each slot's warp and epoch, read in rd_l's cycle (before the advance),
  // on its own resolution lead's flop; and its payload, on its own flop of
  // rd_l, as it lands.
  logic [S-1:0]       rq_cq04h;
  logic [S*WW-1:0]    ew_cq04h;
  logic [S*EP-1:0]    ee_cq04h;
  logic [S*LK-1:0]    ek_cq05h;
  logic [S*32-1:0]    et_cq05h;
  logic [S*PCW-1:0]   eg_cq05h;
  logic [S-1:0]       es_cq05h;
  for (genvar gs = 0; gs < S; gs++) begin : g_ent
    logic id_en_cq03h, pl_en_cq04h;
    assign id_en_cq03h = re_q_cq03h[gs];
    assign pl_en_cq04h = rq_cq04h[gs];
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h) rq_cq04h[gs] <= 1'b0;
      else if (id_en_cq03h || rq_cq04h[gs]) rq_cq04h[gs] <= rd_l_cq03h[gs];
    end
    always_ff @(posedge ooe_core_clk)
      if (id_en_cq03h) begin   // rd_l a data select: the enable is this module's flop alone (CG-5)
        ew_cq04h[gs * WW +: WW] <= rd_l_cq03h[gs] ? wid_cq03h[gs * WW +: WW] : ew_cq04h[gs * WW +: WW];
        ee_cq04h[gs * EP +: EP] <= rd_l_cq03h[gs] ? ep1_cq03h[gs * EP +: EP] : ee_cq04h[gs * EP +: EP];
      end
    always_ff @(posedge ooe_core_clk)
      if (pl_en_cq04h) begin
        ek_cq05h[gs * LK +: LK]   <= rd_ckpt_cq04h[gs * LK +: LK];
        et_cq05h[gs * 32 +: 32]   <= rd_tmask_cq04h[gs * 32 +: 32];
        eg_cq05h[gs * PCW +: PCW] <= rd_tgt_cq04h[gs * PCW +: PCW];
        es_cq05h[gs]              <= rd_stay_cq04h[gs];
      end
  end

  // The channel's payload, on its valid: the picked slot's entry, its
  // payload from ooe_rob_w's outputs when it arrived in the pick's cycle.
  logic              pl_en_cq04h;
  logic [WW-1:0]     ow_nx_cq04h;
  logic [LS-1:0]     ot_nx_cq04h;
  logic [LK-1:0]     ok_nx_cq04h;
  logic [31:0]       om_nx_cq04h;
  logic [PCW-1:0]    og_nx_cq04h;
  logic [EP-1:0]     oe_nx_cq04h;
  logic              os_nx_cq04h;
  assign pl_en_cq04h = rdr_v_cq04h;
  always_comb begin
    ow_nx_cq04h = '0; ot_nx_cq04h = '0; ok_nx_cq04h = '0; om_nx_cq04h = '0;
    og_nx_cq04h = '0; oe_nx_cq04h = '0; os_nx_cq04h = 1'b0;
    for (int s = 0; s < S; s++)
      if (pk_cq04h[s]) begin
        ow_nx_cq04h = ow_nx_cq04h | ew_cq04h[s * WW +: WW];
        ot_nx_cq04h = ot_nx_cq04h | LS'(s);
        oe_nx_cq04h = oe_nx_cq04h | ee_cq04h[s * EP +: EP];
        ok_nx_cq04h = ok_nx_cq04h | (pn_cq04h[s] ? rd_ckpt_cq04h[s * LK +: LK] : ek_cq05h[s * LK +: LK]);
        om_nx_cq04h = om_nx_cq04h | (pn_cq04h[s] ? rd_tmask_cq04h[s * 32 +: 32] : et_cq05h[s * 32 +: 32]);
        og_nx_cq04h = og_nx_cq04h | (pn_cq04h[s] ? rd_tgt_cq04h[s * PCW +: PCW] : eg_cq05h[s * PCW +: PCW]);
        os_nx_cq04h = os_nx_cq04h | (pn_cq04h[s] ? rd_stay_cq04h[s] : es_cq05h[s]);
      end
  end
  always_ff @(posedge ooe_core_clk)
    if (pl_en_cq04h) begin
      rdr_warp_cq05h  <= ow_nx_cq04h;
      rdr_t1_cq05h    <= ot_nx_cq04h;
      rdr_ckpt_cq05h  <= ok_nx_cq04h;
      rdr_tmask_cq05h <= om_nx_cq04h;
      rdr_tgt_cq05h   <= VA'(og_nx_cq04h);
      rdr_ep_cq05h    <= oe_nx_cq04h;
      rdr_stay_cq05h  <= os_nx_cq04h;
    end
  end else begin : g_f1
  // OI-184's lag-1 option: each slot's whole redirect is taken in rd_l's
  // cycle, on its own resolution lead's flop, and the channel's payload is
  // picked in that cycle and flopped beside the valid, so it leaves with
  // it: an arriving slot's from the ports, a waiting one's from its entry.
  logic [S*WW-1:0]    fw_cq04h;
  logic [S*EP-1:0]    fe_cq04h;
  logic [S*LK-1:0]    fk_cq04h;
  logic [S*32-1:0]    ft_cq04h;
  logic [S*PCW-1:0]   fg_cq04h;
  logic [S-1:0]       fs_cq04h;
  for (genvar gs = 0; gs < S; gs++) begin : g_ent
    logic id_en_cq03h;
    assign id_en_cq03h = re_q_cq03h[gs];
    always_ff @(posedge ooe_core_clk)
      if (id_en_cq03h) begin   // rd_l a data select: the enable is this module's flop alone (CG-5)
        fw_cq04h[gs * WW +: WW]   <= rd_l_cq03h[gs] ? wid_cq03h[gs * WW +: WW]      : fw_cq04h[gs * WW +: WW];
        fe_cq04h[gs * EP +: EP]   <= rd_l_cq03h[gs] ? ep1_cq03h[gs * EP +: EP]      : fe_cq04h[gs * EP +: EP];
        fk_cq04h[gs * LK +: LK]   <= rd_l_cq03h[gs] ? rd_ckpt_cq03h[gs * LK +: LK]  : fk_cq04h[gs * LK +: LK];
        ft_cq04h[gs * 32 +: 32]   <= rd_l_cq03h[gs] ? rd_tmask_cq03h[gs * 32 +: 32] : ft_cq04h[gs * 32 +: 32];
        fg_cq04h[gs * PCW +: PCW] <= rd_l_cq03h[gs] ? rd_tgt_cq03h[gs * PCW +: PCW] : fg_cq04h[gs * PCW +: PCW];
        fs_cq04h[gs]              <= rd_l_cq03h[gs] ? rd_stay_cq03h[gs]             : fs_cq04h[gs];
      end
  end
  logic [WW-1:0]     qw_nx_cq03h, qw_cq04h;
  logic [LS-1:0]     qt_nx_cq03h, qt_cq04h;
  logic [LK-1:0]     qk_nx_cq03h, qk_cq04h;
  logic [31:0]       qm_nx_cq03h, qm_cq04h;
  logic [PCW-1:0]    qg_nx_cq03h, qg_cq04h;
  logic [EP-1:0]     qe_nx_cq03h, qe_cq04h;
  logic              qs_nx_cq03h, qs_cq04h;
  always_comb begin
    qw_nx_cq03h = '0; qt_nx_cq03h = '0; qk_nx_cq03h = '0; qm_nx_cq03h = '0;
    qg_nx_cq03h = '0; qe_nx_cq03h = '0; qs_nx_cq03h = 1'b0;
    for (int s = 0; s < S; s++)
      if (pick_cq03h[s]) begin
        qt_nx_cq03h = qt_nx_cq03h | LS'(s);
        qw_nx_cq03h = qw_nx_cq03h | (nw_cq03h[s] ? wid_cq03h[s * WW +: WW]      : fw_cq04h[s * WW +: WW]);
        qe_nx_cq03h = qe_nx_cq03h | (nw_cq03h[s] ? ep1_cq03h[s * EP +: EP]      : fe_cq04h[s * EP +: EP]);
        qk_nx_cq03h = qk_nx_cq03h | (nw_cq03h[s] ? rd_ckpt_cq03h[s * LK +: LK]  : fk_cq04h[s * LK +: LK]);
        qm_nx_cq03h = qm_nx_cq03h | (nw_cq03h[s] ? rd_tmask_cq03h[s * 32 +: 32] : ft_cq04h[s * 32 +: 32]);
        qg_nx_cq03h = qg_nx_cq03h | (nw_cq03h[s] ? rd_tgt_cq03h[s * PCW +: PCW] : fg_cq04h[s * PCW +: PCW]);
        qs_nx_cq03h = qs_nx_cq03h | (nw_cq03h[s] ? rd_stay_cq03h[s]             : fs_cq04h[s]);
      end
  end
  logic qp_en_cq03h;
  assign qp_en_cq03h = ord_en_cq03h;   // a pick needs a waiting entry or a lead
  always_ff @(posedge ooe_core_clk)
    if (qp_en_cq03h) begin
      qw_cq04h <= qw_nx_cq03h;
      qt_cq04h <= qt_nx_cq03h;
      qk_cq04h <= qk_nx_cq03h;
      qm_cq04h <= qm_nx_cq03h;
      qg_cq04h <= qg_nx_cq03h;
      qe_cq04h <= qe_nx_cq03h;
      qs_cq04h <= qs_nx_cq03h;
    end
  assign rdr_warp_cq05h  = qw_cq04h;
  assign rdr_t1_cq05h    = qt_cq04h;
  assign rdr_ckpt_cq05h  = qk_cq04h;
  assign rdr_tmask_cq05h = qm_cq04h;
  assign rdr_tgt_cq05h   = VA'(qg_cq04h);
  assign rdr_ep_cq05h    = qe_cq04h;
  assign rdr_stay_cq05h  = qs_cq04h;
  end
  // The epoch-only fields: 5b's.
  assign rdr_eo_cq05h  = 1'b0;
  assign rdr_rw_cq05h  = 1'b0;
  assign rdr_rh_cq05h  = 1'b0;
  assign rdr_hl_cq05h  = 1'b0;
  assign rdr_own_cq05h = 1'b0;

  // The frees: every instance's, less a slot's under its notice, the valid
  // a cycle after they show and the mask a cycle after that.
  logic [S*NK-1:0] fm_nx_cq03h, fq_cq04h;
  logic            fv_en_cq03h;
  always_comb
    for (int s = 0; s < S; s++)
      fm_nx_cq03h[s * NK +: NK] = ckf_cq03h[s * NK +: NK] & {NK{~ntm_cq03h[s]}};
  assign fv_en_cq03h = fl_q_cq03h || ckf_v_cq04h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) ckf_v_cq04h <= 1'b0;
    else if (fv_en_cq03h) ckf_v_cq04h <= |fm_nx_cq03h;
  end
  always_ff @(posedge ooe_core_clk)
    if (fv_en_cq03h) fq_cq04h <= fm_nx_cq03h;
  if (PWV == 0) begin : g_ckf2
    logic ckm_en_cq04h;
    assign ckm_en_cq04h = ckf_v_cq04h;
    always_ff @(posedge ooe_core_clk)
      if (ckm_en_cq04h) ckf_m_cq05h <= fq_cq04h;
  end else begin : g_ckf1
    assign ckf_m_cq05h = fq_cq04h;   // the mask leaves with its valid, as the redirect's payload
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
