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
// a cycle after the model's resolve, its payload on ports in the same cycle
// and held in ooe_rob_w a cycle later (OA-487). The
// redirect's warp and epoch come from ooe_decrx's flopped slot copies, read
// in rd_l's cycle, before that squash's advance: the epoch after the
// slot's, as the model's redirect carries it (squash_act_lag 1). The pick
// is made in rd_l's cycle among the waiting entries and the arriving ones
// (an arriving entry is younger than every waiting one) and registered:
// the channel's valid and payload from flops a cycle after rd_l, two
// cycles after the model's send at redirect_send_lag 0 (the lag-1 form, DA
// 130; the two-cycle form, PWV=0, retired by OA 492). The frees: each
// instance's ckf (its checkpoints, OA 427's cycle later) arrives in the
// cycle rd_l would, so the free channel's valid and mask come from flops a
// cycle later, in the same relation as the redirect's: a free sent with a
// redirect lands with it (A-58). A slot's
// frees are masked from its epoch-only notice's cycle (OA 438).
//
// Local clock gating: the entries' order and valids on any waiting entry
// or any slot's resolution lead (rd_e, ooe_rob_w's resolution enable a
// cycle before rd_l, flopped here); each slot's warp and epoch on its own
// lead's flop; each slot's held payload in ooe_rob_w, on its resolution
// flop; the channel's payload on the pick's gate; the free mask on its
// valid's. The reset is flopped
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
  // The same payload in rd_l's cycle, for a slot sent in its arrival
  // cycle; the cq04h ports hold a waiting one's (a declared table read, OA
  // 492).
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
  output logic [WW-1:0]     rdr_warp_cq04h,
  output logic [LS-1:0]     rdr_t1_cq04h,
  output logic [LK-1:0]     rdr_ckpt_cq04h,
  output logic [31:0]       rdr_tmask_cq04h,
  output logic [VA-1:0]     rdr_tgt_cq04h,
  output logic [EP-1:0]     rdr_ep_cq04h,
  output logic              rdr_eo_cq04h,   // epoch_only
  output logic              rdr_rw_cq04h,   // rewind
  output logic              rdr_rh_cq04h,   // rewind_held
  output logic              rdr_hl_cq04h,   // held_long
  output logic              rdr_own_cq04h,  // own_pc
  output logic              rdr_stay_cq04h,
  // ccv_ooe_fet_ckpt_free: the valid, then the mask a cycle later.
  output logic              ckf_v_cq04h,
  output logic [S*NK-1:0]   ckf_m_cq04h
`ifdef CCV_CHECK_REDIR
  ,
  // Control pw-at-res (OA 492): every pick read as a waiting one, so a
  // pick in its slot's resolution cycle reads the hold word as it is
  // written; hd_read_not_written must catch it.
  input  logic              ctl_pwres
`endif
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
  // send's own valid only widens it to clear itself.
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

  // OI-184's lag-1 option (DA 130): the channel's payload is picked in rd_l's
  // cycle and flopped beside the valid, so it leaves with it. An arriving
  // slot's comes from ooe_rob_w's cq03h ports; a waiting one's from its
  // word: the checkpoint, mask, target and stay in ooe_rob_w's own register
  // (OA-487: the hold table there, enabled by its resolution flop), the
  // warp and epoch here, taken in rd_l's cycle on its lead's flop (CCV-L23's
  // declared table, by OA; a word is never read in the cycle it is
  // written: an arriving slot's payload is the ports').
  localparam int FW = WW + EP + LK + 32 + PCW + 1;
  logic [WW-1:0] ew_cq04h [S];
  logic [EP-1:0] ee_cq04h [S];
  logic [S-1:0] id_en_cq03h;
  assign id_en_cq03h = re_q_cq03h;
  for (genvar gs = 0; gs < S; gs++) begin : g_ent
    always_ff @(posedge ooe_core_clk)
      if (id_en_cq03h[gs]) begin   // rd_l a data select: the enable is this module's flop alone (CG-5)
        ew_cq04h[gs] <= rd_l_cq03h[gs] ? wid_cq03h[gs * WW +: WW] : ew_cq04h[gs];
        ee_cq04h[gs] <= rd_l_cq03h[gs] ? ep1_cq03h[gs * EP +: EP] : ee_cq04h[gs];
      end
  end
  logic [S*FW-1:0] ar_cq03h, hd_cq03h;
  always_comb
    for (int s = 0; s < S; s++) begin
      ar_cq03h[s * FW +: FW] = {wid_cq03h[s * WW +: WW], ep1_cq03h[s * EP +: EP], rd_ckpt_cq03h[s * LK +: LK],
                                rd_tmask_cq03h[s * 32 +: 32], rd_tgt_cq03h[s * PCW +: PCW], rd_stay_cq03h[s]};
      hd_cq03h[s * FW +: FW] = {{(WW + EP){1'b0}}, rd_ckpt_cq04h[s * LK +: LK],
                                rd_tmask_cq04h[s * 32 +: 32], rd_tgt_cq04h[s * PCW +: PCW], rd_stay_cq04h[s]};
    end
  // The pick's slot, and one AND-OR over the arriving and the waiting words
  // (the ports' depth through one level of select).
  logic [LS-1:0] pi_cq03h;
  logic [S-1:0]  pa_cq03h, pw_cq03h;
  always_comb begin
    pi_cq03h = '0;
    for (int s = 0; s < S; s++)
      if (pick_cq03h[s]) pi_cq03h = pi_cq03h | LS'(s);
  end
  assign pa_cq03h = pick_cq03h & nw_cq03h;
`ifdef CCV_CHECK_REDIR
  assign pw_cq03h = pick_cq03h & ~(nw_cq03h & ~{S{ctl_pwres}});
`else
  assign pw_cq03h = pick_cq03h & ~nw_cq03h;
`endif
  `CCV_ASSERT(hd_read_not_written, !((|pw_cq03h) && id_en_cq03h[pi_cq03h] && rd_l_cq03h[pi_cq03h]))
  logic [FW-1:0] q_nx_cq03h, q_cq04h;
  always_comb begin
    q_nx_cq03h = '0;
    for (int s = 0; s < S; s++)
      q_nx_cq03h = q_nx_cq03h | ({FW{pa_cq03h[s]}} & ar_cq03h[s * FW +: FW]) | ({FW{pw_cq03h[s]}} & hd_cq03h[s * FW +: FW]);
    // A waiting slot's warp and epoch: its word of the table, through the pick's index.
    q_nx_cq03h = q_nx_cq03h | ({FW{|pw_cq03h}} & {ew_cq04h[pi_cq03h], ee_cq04h[pi_cq03h], {(FW - WW - EP){1'b0}}});
  end
  logic qp_en_cq03h;
  assign qp_en_cq03h = (|pv_cq03h) || (|re_q_cq03h);   // a pick needs a waiting entry or a lead
  logic [LS-1:0] qt_cq04h;
  always_ff @(posedge ooe_core_clk)
    if (qp_en_cq03h) begin
      q_cq04h  <= q_nx_cq03h;
      qt_cq04h <= pi_cq03h;
    end
  assign {rdr_warp_cq04h, rdr_ep_cq04h, rdr_ckpt_cq04h, rdr_tmask_cq04h} = q_cq04h[FW-1 -: WW + EP + LK + 32];
  assign rdr_tgt_cq04h  = VA'(q_cq04h[1 +: PCW]);
  assign rdr_stay_cq04h = q_cq04h[0];
  assign rdr_t1_cq04h   = qt_cq04h;
  // The epoch-only fields: 5b's.
  assign rdr_eo_cq04h  = 1'b0;
  assign rdr_rw_cq04h  = 1'b0;
  assign rdr_rh_cq04h  = 1'b0;
  assign rdr_hl_cq04h  = 1'b0;
  assign rdr_own_cq04h = 1'b0;

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
  assign ckf_m_cq04h = fq_cq04h;   // the mask leaves with its valid, as the redirect's payload

endmodule
`undef CCV_CLK
`undef CCV_RST
