//===-- ooe_slot.sv - OOE's tier-1 slots: residency, demotion and kill ----===//
//
// Spec: OA 435 (1) (re:OI-171, the register's OA tab): each tier-1 slot's
//       residency state and identity, the decode of ccv_rau_ooe_alloc, and
//       the requests a slot's moves make of the rest of OOE (ooe_rat's
//       squash and release, ooe_decrx's notice and release, ooe_redir's
//       epoch-only notice, the RCU map), with the demotion and kill
//       sequencing that drives them.
//
// The reference is the model's control step (Core::control): the
// allocations, then the demotes (refused once the exit has retired, held
// while an atomic is at the head), then the kill, then each demoting or
// killing slot's progress, which waits for its ROB to empty (held) and for
// its epoch notice and every rewind beat to land in FET (landed). A
// demoting slot sends its map first, then its drained message a later
// cycle; a killing slot releases, and the kill is acked once every slot it
// named has released (or at once when it named none). test/ooe/slot_tb.cpp
// drives this module with the model's log of every cycle (Core::slotLog)
// and compares every verdict and every slot.
//
// States (st, 3 bits): 0 empty, 1 restoring (restore-allocate, until
// restore-activate), 2 resident, 3 demoting (squashed, its map not yet
// sent), 4 draining (map sent, drained not yet), 5 parked (drained, until
// RAU frees it), 6 killing.
//
// Timing: the inputs land a cycle after their leads (ev_l, kill_l), and the
// verdicts come from flops a cycle after them: ntc, a slot squashed with an
// epoch notice (a demote or a kill: ooe_rat's squash, ooe_decrx's adn,
// ooe_redir's epoch-only notice and the checkpoints' withdrawal), map (the
// map to RCU), rel (a release: ooe_rat, ooe_decrx and the free lists), drn
// (ccv_ooe_rau_drained, refused or not) and the kill's ack. So the model's
// control step, one cycle, takes two here: the levels it reads (held,
// landed, ath, xr) are this cycle's, and what other modules do with the
// verdicts starts a cycle after the model's (the landing row prices it).
// kill_ack is the channel's level: high from the kill's quiescence until
// the next kill_valid, with kill_ack_epoch the epoch it answers.
//
// Local clock gating: one gate, on the event and kill leads' flops, any
// slot demoting, draining or killing, a held demote, and any verdict pulse
// still high (so each pulse falls a cycle after it rises). Each slot's
// identity is an AND-OR on D under it (5-bit fields would be gates under
// 8). Reset line: the leads, each slot's state, the held demotes, the
// pulses and the ack level reset; a slot's identity is payload under its
// state, the ack's epoch under the level.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_slot #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int A  = 1,                  // allocations a cycle (ccv_rau_ooe_alloc's rate)
  parameter int D  = 1,                  // demotes a cycle (ccv_rau_ooe_demote's rate)
  parameter int NW = 32,                 // warp_ids (2 ** CCV_W_WARP_ID)
  parameter int WC = 32,                 // ctaid
  parameter int WI = 5,                  // warp_in_cta
  parameter int WB = 5,                  // barrier_count
  parameter int WT = 3,                  // cta_slot
  parameter int KE = 2,                  // kill_epoch
  parameter int LT = 2,                  // a slot's retire count a cycle (CCV_RETIRE_PER_ROB's width)
  parameter int RW = 8,                  // retired_since_restore (CCV_W_RETIRED_CNT)
  parameter int QD = 4,                  // status reports a slot holds
  parameter int CW = 4,                  // a fault cause (CCV_W_FAULT_CAUSE)
  parameter int PCW = 48,                // a pc
  parameter int VA = 64,                 // a fault address (CCV_W_VA)
  localparam int LS = $clog2(S),
  localparam int LW = $clog2(NW)
) (
  input  logic             ooe_core_clk,
  input  logic             ooe_rst_r00h,
  input  logic             ev_l_cq00h,     // an allocation or a demote comes next cycle
  input  logic             kill_l_cq00h,   // kill_valid: the mask comes next cycle
  input  logic [A-1:0]     al_v_cq01h,     // ccv_rau_ooe_alloc
  input  logic [A*LS-1:0]  al_slot_cq01h,  // tier1_id
  input  logic [A*2-1:0]   al_op_cq01h,    // 0 free, 1 launch, 2 restore-allocate, 3 restore-activate
  input  logic [A*LW-1:0]  al_warp_cq01h,
  input  logic [A*WC-1:0]  al_ctaid_cq01h,
  input  logic [A*WI-1:0]  al_wic_cq01h,
  input  logic [A*WB-1:0]  al_barc_cq01h,
  input  logic [A*WT-1:0]  al_cta_cq01h,
  input  logic [D-1:0]     dm_v_cq01h,     // ccv_rau_ooe_demote
  input  logic [D*LW-1:0]  dm_warp_cq01h,
  input  logic [NW-1:0]    kill_mask_cq01h,
  input  logic [KE-1:0]    kill_ep_cq01h,
  input  logic [S-1:0]     held_cq01h,     // slot s holds a valid ROB entry (ooe_rob_w)
  input  logic [S-1:0]     lnd_cq01h,      // slot s's epoch notice and beats have landed (ooe_redir)
  input  logic [S-1:0]     ath_cq01h,      // an atomic in progress at slot s's head (ooe_rob_w)
  input  logic [S-1:0]     xr_cq01h,       // slot s's exit has retired (ooe_rob_w)
  // The reports (OA 435 (9), (10)), from each slot's ooe_rob_w: what it
  // retired this cycle, its demotion triggers (the MLC-miss trigger, and the
  // fallback's or the barrier timer's with its mlc_miss_seen), ordered as
  // the model's, and the fault taken with its record, held to the release.
  input  logic [S*LT-1:0]  rc_cq01h,       // entries retired
  input  logic [S-1:0]     tm_cq01h,       // the MLC-miss trigger fires
  input  logic [S-1:0]     tf_cq01h,       // the fallback or barrier trigger fires
  input  logic [S-1:0]     tfm_cq01h,      // ... with mlc_miss_seen
  input  logic [S-1:0]     ft_v_cq01h,     // a fault taken
  input  logic [S*CW-1:0]  ft_cause_cq01h,
  input  logic [S*PCW-1:0] ft_pc_cq01h,
  input  logic [S*32-1:0]  ft_lanes_cq01h,
  input  logic [S*VA-1:0]  ft_addr_cq01h,
  output logic [S*3-1:0]   st_cq02h,
  output logic [S*LW-1:0]  warp_cq02h,
  output logic [S*WC-1:0]  ctaid_cq02h,
  output logic [S*WI-1:0]  wic_cq02h,
  output logic [S*WB-1:0]  barc_cq02h,
  output logic [S*WT-1:0]  cta_cq02h,
  output logic [S-1:0]     ntc_cq02h,      // squashed, with an epoch notice
  output logic [S-1:0]     map_cq02h,      // the map to RCU goes
  output logic [S-1:0]     rel_cq02h,      // released
  output logic [S-1:0]     drn_cq02h,      // ccv_ooe_rau_drained for slot s's warp
  output logic [S-1:0]     drn_ref_cq02h,  // ... refused
  output logic             kack_cq02h,     // kill_ack (the level)
  output logic [KE-1:0]    kack_ep_cq02h,  // kill_ack_epoch
  output logic             rs_v_cq03h,     // ccv_ooe_rau_status
  output logic [LW-1:0]    rs_warp_cq04h,
  output logic             rs_ft_cq04h,    // fault_taken
  output logic             rs_st_cq04h,    // stalled
  output logic             rs_mlc_cq04h,   // mlc_miss_seen
  output logic [RW-1:0]    rs_rsr_cq04h,   // retired_since_restore
  output logic             rs_ex_cq04h,    // exited
  output logic             cf_v_cq03h,     // ccv_ooe_cru_fault
  output logic [CW-1:0]    cf_cause_cq04h,
  output logic [PCW-1:0]   cf_pc_cq04h,
  output logic [31:0]      cf_lanes_cq04h,
  output logic [VA-1:0]    cf_addr_cq04h,
  output logic [WT-1:0]    cf_cta_cq04h,
  output logic [LW-1:0]    cf_warp_cq04h
);
  localparam logic [2:0] EMPTY = 3'd0, RESTORING = 3'd1, RESIDENT = 3'd2, DEMOTING = 3'd3,
                         DRAINING = 3'd4, PARKED = 3'd5, KILLING = 3'd6;

  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) rst_r01h <= ooe_rst_r00h;

  // The state and the warp drive the next state, so each has a copy for
  // its output (an output's register starts no path inside: NGD-7).
  (* keep *) logic [S*3-1:0]  stq_cq02h;
  (* keep *) logic [S*LW-1:0] wq_cq02h;
  (* keep *) logic [S*3-1:0]  sto_cq02h;
  (* keep *) logic [S*LW-1:0] wo_cq02h;
  assign st_cq02h = sto_cq02h;
  assign warp_cq02h = wo_cq02h;
  logic [S-1:0] dmhq_cq02h;
  logic ev_q_cq01h, kl_q_cq01h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      ev_q_cq01h <= 1'b0;
      kl_q_cq01h <= 1'b0;
    end else begin
      ev_q_cq01h <= ev_l_cq00h;
      kl_q_cq01h <= kill_l_cq00h;
    end
  end

  // The gate: a lead, a slot in progress, a held demote, or a pulse to drop.
  logic [S-1:0] busy_cq02h;
  always_comb
    for (int s = 0; s < S; s++)
      busy_cq02h[s] = stq_cq02h[s * 3 +: 3] == DEMOTING || stq_cq02h[s * 3 +: 3] == DRAINING ||
                      stq_cq02h[s * 3 +: 3] == KILLING || dmhq_cq02h[s] || ntc_cq02h[s] || map_cq02h[s] ||
                      rel_cq02h[s] || drn_cq02h[s];
  logic sl_en_cq01h;
  assign sl_en_cq01h = ev_q_cq01h || kl_q_cq01h || busy_cq02h != '0;

  // The alloc decode: each slot's free, and its other allocation (a launch
  // or a restore), at most one of each a cycle (AND-OR): a free and the
  // slot's next allocation may come at one RAU decision, the free first.
  logic [S-1:0]    fr_cq01h, av_cq01h;
  logic [S*2-1:0]  aop_cq01h;
  logic [S*LW-1:0] aw_cq01h;
  logic [S*WC-1:0] ac_cq01h;
  logic [S*WI-1:0] ai_cq01h;
  logic [S*WB-1:0] ab_cq01h;
  logic [S*WT-1:0] at_cq01h;
  always_comb begin
    fr_cq01h = '0;
    av_cq01h = '0;
    aop_cq01h = '0;
    aw_cq01h = '0;
    ac_cq01h = '0;
    ai_cq01h = '0;
    ab_cq01h = '0;
    at_cq01h = '0;
    for (int s = 0; s < S; s++)
      for (int a = 0; a < A; a++)
        if (al_v_cq01h[a] && al_slot_cq01h[a * LS +: LS] == LS'(s) && al_op_cq01h[a * 2 +: 2] == 2'd0)
          fr_cq01h[s] = 1'b1;
        else if (al_v_cq01h[a] && al_slot_cq01h[a * LS +: LS] == LS'(s)) begin
          av_cq01h[s] = 1'b1;
          aop_cq01h[s * 2 +: 2] |= al_op_cq01h[a * 2 +: 2];
          aw_cq01h[s * LW +: LW] |= al_warp_cq01h[a * LW +: LW];
          ac_cq01h[s * WC +: WC] |= al_ctaid_cq01h[a * WC +: WC];
          ai_cq01h[s * WI +: WI] |= al_wic_cq01h[a * WI +: WI];
          ab_cq01h[s * WB +: WB] |= al_barc_cq01h[a * WB +: WB];
          at_cq01h[s * WT +: WT] |= al_cta_cq01h[a * WT +: WT];
        end
  end

  // Each slot's moves. The model takes them in order (allocation, demote,
  // kill, progress); here each is a condition on the slot's own flops and
  // this cycle's inputs, taken side by side, and the next state is a
  // priority select of them, so no move waits on another's state. That
  // holds because RAU never demotes or kills a warp in the cycle it
  // allocates it (assertions): a demote finds the slot resident from its
  // flops, a kill finds it held from its flops (and not freed now).
  logic [S*3-1:0]  st_nx_cq01h;
  logic [S*LW-1:0] w_nx_cq01h;
  logic [S*WC-1:0] c_nx_cq01h;
  logic [S*WI-1:0] i_nx_cq01h;
  logic [S*WB-1:0] b_nx_cq01h;
  logic [S*WT-1:0] t_nx_cq01h;
  logic [S-1:0] dmh_nx_cq01h, ntc_nx_cq01h, map_nx_cq01h, rel_nx_cq01h, drn_nx_cq01h, ref_nx_cq01h;
  logic [S-1:0] ld_cq01h, klg_cq01h, kdn_cq01h;
  always_comb
    for (int s = 0; s < S; s++) begin
      logic [2:0] st;
      logic [LW-1:0] w;
      logic is_e, is_r, is_rs, is_dm, is_dr, is_k;
      logic rel_fr, act, dm, dmv, refuse, dmo, hitk, prog, drp;
      st = stq_cq02h[s * 3 +: 3];
      w = wq_cq02h[s * LW +: LW];
      is_e = st == EMPTY;
      is_r = st == RESIDENT;
      is_rs = st == RESTORING;
      is_dm = st == DEMOTING;
      is_dr = st == DRAINING;
      is_k = st == KILLING;
      // Allocation: a free releases a held slot; a launch or a
      // restore-allocate takes an empty one (or the one freed beside it)
      // and loads its identity; restore-activate makes a restoring slot
      // resident.
      rel_fr = fr_cq01h[s] && !is_e;
      ld_cq01h[s] = av_cq01h[s] && aop_cq01h[s * 2 +: 2] != 2'd3 && (is_e || fr_cq01h[s]);
      act = av_cq01h[s] && aop_cq01h[s * 2 +: 2] == 2'd3 && is_rs;
      // Demote: a new one for the slot's warp, or a held one retrying (a
      // slot no longer resident drops it). Refused once the exit has
      // retired; held while an atomic is at the head; else squashed.
      dm = dmhq_cq02h[s];
      for (int d = 0; d < D; d++)
        dm = dm | (dm_v_cq01h[d] && dm_warp_cq01h[d * LW +: LW] == w);
      dmv = dm && is_r;
      refuse = dmv && xr_cq01h[s];
      dmh_nx_cq01h[s] = dmv && !xr_cq01h[s] && ath_cq01h[s];
      dmo = dmv && !xr_cq01h[s] && !ath_cq01h[s];
      // Kill: every held slot whose warp the mask names.
      hitk = kl_q_cq01h && !is_e && !fr_cq01h[s] && kill_mask_cq01h[w];
      ntc_nx_cq01h[s] = hitk || dmo;
      // Progress, once the ROB is empty and the notice has landed (never in
      // the notice's own cycle).
      prog = !held_cq01h[s] && lnd_cq01h[s] && !ntc_nx_cq01h[s];
      map_nx_cq01h[s] = prog && is_dm;
      drp = prog && is_dr;
      kdn_cq01h[s] = prog && is_k;
      klg_cq01h[s] = hitk || is_k;
      rel_nx_cq01h[s] = rel_fr || kdn_cq01h[s];
      drn_nx_cq01h[s] = refuse || drp;
      ref_nx_cq01h[s] = refuse;
      if (hitk) st = KILLING;
      else if (ld_cq01h[s]) st = aop_cq01h[s * 2 +: 2] == 2'd1 ? RESIDENT : RESTORING;
      else if (rel_fr) st = EMPTY;
      else if (act) st = RESIDENT;
      else if (dmo) st = DEMOTING;
      else if (map_nx_cq01h[s]) st = DRAINING;
      else if (drp) st = PARKED;
      else if (kdn_cq01h[s]) st = EMPTY;
      st_nx_cq01h[s * 3 +: 3] = st;
      // The identity: an AND-OR on D.
      w_nx_cq01h[s * LW +: LW] = ({LW{ld_cq01h[s]}} & aw_cq01h[s * LW +: LW]) | ({LW{!ld_cq01h[s]}} & w);
      c_nx_cq01h[s * WC +: WC] = ({WC{ld_cq01h[s]}} & ac_cq01h[s * WC +: WC]) |
                                 ({WC{!ld_cq01h[s]}} & ctaid_cq02h[s * WC +: WC]);
      i_nx_cq01h[s * WI +: WI] = ({WI{ld_cq01h[s]}} & ai_cq01h[s * WI +: WI]) |
                                 ({WI{!ld_cq01h[s]}} & wic_cq02h[s * WI +: WI]);
      b_nx_cq01h[s * WB +: WB] = ({WB{ld_cq01h[s]}} & ab_cq01h[s * WB +: WB]) |
                                 ({WB{!ld_cq01h[s]}} & barc_cq02h[s * WB +: WB]);
      t_nx_cq01h[s * WT +: WT] = ({WT{ld_cq01h[s]}} & at_cq01h[s * WT +: WT]) |
                                 ({WT{!ld_cq01h[s]}} & cta_cq02h[s * WT +: WT]);
    end

  // The kill's ack: at once for a kill naming nothing, else when the last
  // slot it holds killing releases. The level falls at the next kill.
  logic ack_cq01h, kack_nx_cq01h;
  logic [KE-1:0] kep_nx_cq01h;
  assign ack_cq01h = (kl_q_cq01h && klg_cq01h == '0) || (klg_cq01h != '0 && (klg_cq01h & ~kdn_cq01h) == '0);
  assign kack_nx_cq01h = ack_cq01h || (kack_cq02h && !kl_q_cq01h);
  // An AND-OR on D, not a select, so it stays in the slots' gate (a
  // 2-flop field would be a gate under 8).
  assign kep_nx_cq01h = ({KE{kl_q_cq01h}} & kill_ep_cq01h) | ({KE{!kl_q_cq01h}} & kack_ep_cq02h);

  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      stq_cq02h <= '0;
      sto_cq02h <= '0;
      dmhq_cq02h <= '0;
      ntc_cq02h <= '0;
      map_cq02h <= '0;
      rel_cq02h <= '0;
      drn_cq02h <= '0;
      kack_cq02h <= 1'b0;
    end else if (sl_en_cq01h) begin
      stq_cq02h <= st_nx_cq01h;
      sto_cq02h <= st_nx_cq01h;
      dmhq_cq02h <= dmh_nx_cq01h;
      ntc_cq02h <= ntc_nx_cq01h;
      map_cq02h <= map_nx_cq01h;
      rel_cq02h <= rel_nx_cq01h;
      drn_cq02h <= drn_nx_cq01h;
      kack_cq02h <= kack_nx_cq01h;
    end
  end
  always_ff @(posedge ooe_core_clk)
    if (sl_en_cq01h) begin
      wq_cq02h <= w_nx_cq01h;
      wo_cq02h <= w_nx_cq01h;
      ctaid_cq02h <= c_nx_cq01h;
      wic_cq02h <= i_nx_cq01h;
      barc_cq02h <= b_nx_cq01h;
      cta_cq02h <= t_nx_cq01h;
      drn_ref_cq02h <= ref_nx_cq01h;
      kack_ep_cq02h <= kep_nx_cq01h;
    end

  // ---- The reports: ccv_ooe_rau_status (OA 435 (9)) and ccv_ooe_cru_fault (10)
  //
  // The reports' inputs are flopped first (cq02h), so none of their logic
  // sits on the slot's own cones; a report leaves a cycle later, off S1:
  // what each slot retired, its triggers, its fault, its exited and its
  // clear at a load or a release.
  //
  // exited (OA's rev 149): once, for a resident slot whose exit has retired
  // and whose ROB holds nothing, a deferred free included (held); not as
  // the slot is killed or freed. xs remembers it was raised until the slot
  // is loaded or released.
  logic [S*LT-1:0] rcr_cq02h;
  logic [S-1:0]    tmr_cq02h, tfr_cq02h, tfmr_cq02h, ftr_cq02h, exr_cq02h, clr_cq02h, xs_q_cq02h;
  logic [S-1:0]    ex_nx_cq01h, clr_nx_cq01h, xs_nx_cq01h;
  logic            ri_en_cq01h;
  always_comb
    for (int s = 0; s < S; s++) begin
      logic ex, clr;
      ex = stq_cq02h[s * 3 +: 3] == RESIDENT && xr_cq01h[s] && !held_cq01h[s] && !xs_q_cq02h[s] &&
           !(kl_q_cq01h && kill_mask_cq01h[wq_cq02h[s * LW +: LW]]) && !fr_cq01h[s];
      clr = ld_cq01h[s] | rel_nx_cq01h[s];
      ex_nx_cq01h[s] = ex;
      clr_nx_cq01h[s] = clr;
      xs_nx_cq01h[s] = (xs_q_cq02h[s] | ex) & ~clr;
    end
  assign ri_en_cq01h = rc_cq01h != '0 || tm_cq01h != '0 || tf_cq01h != '0 || ft_v_cq01h != '0 ||
                       xr_cq01h != '0 || clr_nx_cq01h != '0 || rcr_cq02h != '0 || tmr_cq02h != '0 ||
                       tfr_cq02h != '0 || ftr_cq02h != '0 || exr_cq02h != '0 || clr_cq02h != '0;
  always_ff @(posedge ooe_core_clk)
    if (rst_r01h) begin
      rcr_cq02h <= '0;
      {tmr_cq02h, tfr_cq02h, tfmr_cq02h, ftr_cq02h, exr_cq02h, clr_cq02h, xs_q_cq02h} <= '0;
    end else if (ri_en_cq01h) begin
      rcr_cq02h <= rc_cq01h;
      {tmr_cq02h, tfr_cq02h, tfmr_cq02h, ftr_cq02h, exr_cq02h, clr_cq02h, xs_q_cq02h} <=
        {tm_cq01h, tf_cq01h, tfm_cq01h, ft_v_cq01h, ex_nx_cq01h, clr_nx_cq01h, xs_nx_cq01h};
    end

  // The status queue, a FIFO per slot (a warp's reports stay in order),
  // its entry {fault_taken, exited, stalled, mlc_miss_seen, count}, with
  // retired_since_restore, each slot's count of retirements, saturating at
  // all ones (CCV_W_RETIRED_CNT) and cleared at a load or release (the
  // model clears it at restore-allocate and the release); a report carries
  // the count with its own cycle's retirements in it. A cycle's reports
  // enter in the model's order: exited (its control step), the fault, the
  // MLC-miss trigger, then the fallback's or the barrier's. The channel
  // takes one a cycle, round robin over the slots holding one: RAU reads a
  // warp's reports in order and nothing across warps. The pick (pv, ps) is
  // registered beside the queue, so valid leads, and the entry leaves as
  // its payload is registered a cycle later.
  localparam int EW = 4 + RW;
  localparam int QC = $clog2(QD + 1);
  logic [S*RW-1:0]    rc_q_cq03h, rc_nx_cq02h;
  logic [S*QD*EW-1:0] q_cq03h, q_nx_cq02h;
  logic [S*QC-1:0]    qc_cq03h, qc_nx_cq02h;
  logic [S-1:0]       q_en_cq02h, rc_en_cq02h, ovf_cq02h;
  (* keep *) logic    pv_cq03h;
  (* keep *) logic    pvo_cq03h;
  logic [LS-1:0]      ps_cq03h, rr_cq03h;
  logic               pv_nx_cq02h, rp_en_cq02h;
  logic [LS-1:0]      ps_nx_cq02h;
  always_comb begin
    logic [S-1:0] avail;
    for (int s = 0; s < S; s++) begin
      logic [RW:0] sum;
      logic [RW-1:0] cnt;
      logic [4*EW-1:0] it, cp;
      logic [3:0] iv;
      logic [QD*EW-1:0] sh;
      logic [QC+1:0] n, base;
      logic pop;
      sum = {1'b0, rc_q_cq03h[s * RW +: RW]} + (RW + 1)'(rcr_cq02h[s * LT +: LT]);
      cnt = clr_cq02h[s] ? '0 : sum[RW] ? '1 : sum[RW-1:0];
      rc_nx_cq02h[s * RW +: RW] = cnt;
      rc_en_cq02h[s] = clr_cq02h[s] | (rcr_cq02h[s * LT +: LT] != '0);
      pop = pv_cq03h && ps_cq03h == LS'(s);
      it[0 * EW +: EW] = {1'b0, 1'b1, 1'b0, 1'b0, cnt};
      it[1 * EW +: EW] = {1'b1, 1'b0, 1'b0, 1'b0, cnt};
      it[2 * EW +: EW] = {1'b0, 1'b0, 1'b1, 1'b1, cnt};
      it[3 * EW +: EW] = {1'b0, 1'b0, 1'b1, tfmr_cq02h[s], cnt};
      iv = {tfr_cq02h[s], tmr_cq02h[s], ftr_cq02h[s], exr_cq02h[s]};
      n = '0;
      cp = '0;
      for (int k = 0; k < 4; k++)
        if (iv[k]) begin
          cp[n * EW +: EW] = it[k * EW +: EW];
          n = n + 1'b1;
        end
      for (int i = 0; i < QD; i++)
        sh[i * EW +: EW] = pop ? (i + 1 < QD ? q_cq03h[(s * QD + i + 1) * EW +: EW] : '0)
                               : q_cq03h[(s * QD + i) * EW +: EW];
      base = (QC + 2)'(qc_cq03h[s * QC +: QC]) - (QC + 2)'(pop);
      for (int i = 0; i < QD; i++) begin
        logic [QC+1:0] j;
        j = (QC + 2)'(i) - base;
        q_nx_cq02h[(s * QD + i) * EW +: EW] = (QC + 2)'(i) < base ? sh[i * EW +: EW]
                                            : j < n ? cp[j * EW +: EW] : '0;
      end
      ovf_cq02h[s] = base + n > (QC + 2)'(QD);
      qc_nx_cq02h[s * QC +: QC] = QC'(base + n);
      q_en_cq02h[s] = pop | (iv != '0);
      // The pick: a slot with a report not already picked.
      avail[s] = qc_cq03h[s * QC +: QC] > (pop ? QC'(1) : QC'(0));
    end
    // Round robin from the slot after the last pick.
    pv_nx_cq02h = 1'b0;
    ps_nx_cq02h = '0;
    for (int k = S - 1; k >= 0; k--)
      if (avail[LS'(rr_cq03h + LS'(k))]) begin
        pv_nx_cq02h = 1'b1;
        ps_nx_cq02h = LS'(rr_cq03h + LS'(k));
      end
    rp_en_cq02h = avail != '0 || pv_cq03h;
  end
  for (genvar gs = 0; gs < S; gs++) begin : g_q
    always_ff @(posedge ooe_core_clk)
      if (rst_r01h)              rc_q_cq03h[gs * RW +: RW] <= '0;
      else if (rc_en_cq02h[gs])  rc_q_cq03h[gs * RW +: RW] <= rc_nx_cq02h[gs * RW +: RW];
    always_ff @(posedge ooe_core_clk)
      if (rst_r01h)              qc_cq03h[gs * QC +: QC] <= '0;
      else if (q_en_cq02h[gs])   qc_cq03h[gs * QC +: QC] <= qc_nx_cq02h[gs * QC +: QC];
    always_ff @(posedge ooe_core_clk)
      if (q_en_cq02h[gs]) q_cq03h[gs * QD * EW +: QD * EW] <= q_nx_cq02h[gs * QD * EW +: QD * EW];
  end
  always_ff @(posedge ooe_core_clk)
    if (rst_r01h) begin
      pv_cq03h <= 1'b0;
      pvo_cq03h <= 1'b0;
      ps_cq03h <= '0;
      rr_cq03h <= '0;
    end else if (rp_en_cq02h) begin
      pv_cq03h <= pv_nx_cq02h;
      pvo_cq03h <= pv_nx_cq02h;
      ps_cq03h <= ps_nx_cq02h;
      if (pv_nx_cq02h) rr_cq03h <= LS'(ps_nx_cq02h + LS'(1));
    end
  assign rs_v_cq03h = pvo_cq03h;
  // The payload: the picked slot's head entry and its warp.
  logic [EW-1:0] hd_cq03h;
  logic [LW-1:0] hw_cq03h;
  always_comb begin
    hd_cq03h = '0;
    hw_cq03h = '0;
    for (int s = 0; s < S; s++)
      if (ps_cq03h == LS'(s)) begin
        hd_cq03h = q_cq03h[s * QD * EW +: EW];
        hw_cq03h = wq_cq02h[s * LW +: LW];
      end
  end
  always_ff @(posedge ooe_core_clk)
    if (pv_cq03h) begin
      {rs_ft_cq04h, rs_ex_cq04h, rs_st_cq04h, rs_mlc_cq04h, rs_rsr_cq04h} <= hd_cq03h;
      rs_warp_cq04h <= hw_cq03h;
    end

  // ccv_ooe_cru_fault: a slot's fault waits (pf) until picked, round robin
  // likewise; the record is ooe_rob_w's, held to the release, with the
  // slot's cta_slot and warp. One fault a slot until it is released.
  logic [S-1:0]  pf_cq03h, pf_nx_cq02h;
  (* keep *) logic fv_cq03h;
  (* keep *) logic fvo_cq03h;
  logic          fv_nx_cq02h, f_en_cq02h;
  logic [LS-1:0] fs_cq03h, fs_nx_cq02h, frr_cq03h;
  always_comb begin
    logic [S-1:0] pk;
    logic fv;
    logic [LS-1:0] fs;
    fv = 1'b0;
    fs = '0;
    pk = '0;
    for (int k = S - 1; k >= 0; k--)
      if (pf_cq03h[LS'(frr_cq03h + LS'(k))]) begin
        fv = 1'b1;
        fs = LS'(frr_cq03h + LS'(k));
      end
    if (fv) pk[fs] = 1'b1;
    fv_nx_cq02h = fv;
    fs_nx_cq02h = fs;
    pf_nx_cq02h = (pf_cq03h & ~pk) | ftr_cq02h;
    f_en_cq02h = pf_cq03h != '0 || ftr_cq02h != '0 || fv_cq03h;
  end
  always_ff @(posedge ooe_core_clk)
    if (rst_r01h) begin
      pf_cq03h <= '0;
      fv_cq03h <= 1'b0;
      fvo_cq03h <= 1'b0;
      fs_cq03h <= '0;
      frr_cq03h <= '0;
    end else if (f_en_cq02h) begin
      pf_cq03h <= pf_nx_cq02h;
      fv_cq03h <= fv_nx_cq02h;
      fvo_cq03h <= fv_nx_cq02h;
      fs_cq03h <= fs_nx_cq02h;
      if (fv_nx_cq02h) frr_cq03h <= LS'(fs_nx_cq02h + LS'(1));
    end
  assign cf_v_cq03h = fvo_cq03h;
  logic [CW-1:0]  fc_cq03h;
  logic [PCW-1:0] fp_cq03h;
  logic [31:0]    fl_cq03h;
  logic [VA-1:0]  fa_cq03h;
  logic [WT-1:0]  ft_cq03h;
  logic [LW-1:0]  fw_cq03h;
  always_comb begin
    {fc_cq03h, fp_cq03h, fl_cq03h, fa_cq03h, ft_cq03h, fw_cq03h} = '0;
    for (int s = 0; s < S; s++)
      if (fs_cq03h == LS'(s)) begin
        fc_cq03h = ft_cause_cq01h[s * CW +: CW];
        fp_cq03h = ft_pc_cq01h[s * PCW +: PCW];
        fl_cq03h = ft_lanes_cq01h[s * 32 +: 32];
        fa_cq03h = ft_addr_cq01h[s * VA +: VA];
        ft_cq03h = cta_cq02h[s * WT +: WT];
        fw_cq03h = wq_cq02h[s * LW +: LW];
      end
  end
  always_ff @(posedge ooe_core_clk)
    if (fv_cq03h) begin
      cf_cause_cq04h <= fc_cq03h;
      cf_pc_cq04h <= fp_cq03h;
      cf_lanes_cq04h <= fl_cq03h;
      cf_addr_cq04h <= fa_cq03h;
      cf_cta_cq04h <= ft_cq03h;
      cf_warp_cq04h <= fw_cq03h;
    end

  // The reports' contract: no queue overflows; no slot is loaded while it
  // holds a report or a fault (its warp would be the new one's); a slot
  // takes one fault until released. The round robins wrap in LS bits.
  if (S != (1 << LS)) begin : g_s_pow2
    $error("ooe_slot: S must be a power of two");
  end
  `CCV_ASSERT(rpt_no_overflow, ovf_cq02h == '0)
  logic [S-1:0] ld_busy_cq03h;
  always_comb
    for (int s = 0; s < S; s++)
      ld_busy_cq03h[s] = clr_cq02h[s] && (qc_cq03h[s * QC +: QC] != '0 || pf_cq03h[s] ||
                                          (fv_cq03h && fs_cq03h == LS'(s)));
  `CCV_ASSERT(rpt_drained_at_load, ld_busy_cq03h == '0)
  `CCV_ASSERT(one_fault_a_slot, (ftr_cq02h & pf_cq03h) == '0)
  `CCV_ASSERT_KNOWN(rpt_known, {tm_cq01h, tf_cq01h, ft_v_cq01h, rc_cq01h})

  // The input contract.
  `CCV_ASSERT_KNOWN(ev_l_known, ev_l_cq00h)
  `CCV_ASSERT_KNOWN(kill_l_known, kill_l_cq00h)
  `CCV_ASSERT_KNOWN(al_v_known, al_v_cq01h)
  `CCV_ASSERT_KNOWN(dm_v_known, dm_v_cq01h)
  `CCV_ASSERT_KNOWN_IF(al_known, al_v_cq01h != '0, {al_slot_cq01h, al_op_cq01h, al_warp_cq01h})
  `CCV_ASSERT_KNOWN_IF(dm_known, dm_v_cq01h != '0, dm_warp_cq01h)
  `CCV_ASSERT_KNOWN_IF(kill_known, kl_q_cq01h, {kill_mask_cq01h, kill_ep_cq01h})
  `CCV_ASSERT_KNOWN_IF(lvl_known, busy_cq02h != '0 || ev_q_cq01h || kl_q_cq01h,
                       {held_cq01h, lnd_cq01h, ath_cq01h, xr_cq01h})
  // Every allocation and demote comes under its lead.
  `CCV_ASSERT(ev_led, (al_v_cq01h == '0 && dm_v_cq01h == '0) || ev_q_cq01h)
  // At most one free and one other allocation a slot a cycle.
  logic [S-1:0] al_two_cq01h;
  always_comb begin
    al_two_cq01h = '0;
    for (int s = 0; s < S; s++)
      for (int a = 0; a < A; a++)
        for (int b = a + 1; b < A; b++)
          if (al_v_cq01h[a] && al_v_cq01h[b] && al_slot_cq01h[a * LS +: LS] == LS'(s) &&
              al_slot_cq01h[b * LS +: LS] == LS'(s) &&
              (al_op_cq01h[a * 2 +: 2] == 2'd0) == (al_op_cq01h[b * 2 +: 2] == 2'd0))
            al_two_cq01h[s] = 1'b1;
  end
  `CCV_ASSERT(al_one_a_slot, al_two_cq01h == '0)
  // RAU neither demotes nor kills a warp in the cycle it allocates it.
  logic [S-1:0] new_hit_cq01h;
  always_comb
    for (int s = 0; s < S; s++) begin
      new_hit_cq01h[s] = ld_cq01h[s] && kl_q_cq01h && kill_mask_cq01h[aw_cq01h[s * LW +: LW]];
      for (int d = 0; d < D; d++)
        if (ld_cq01h[s] && dm_v_cq01h[d] && dm_warp_cq01h[d * LW +: LW] == aw_cq01h[s * LW +: LW])
          new_hit_cq01h[s] = 1'b1;
    end
  `CCV_ASSERT(no_hit_at_alloc, new_hit_cq01h == '0)
  // A slot's notice has not landed in the cycle it is sent.
  `CCV_ASSERT(lnd_after_ntc, (lnd_cq01h & ntc_cq02h) == '0)
endmodule
`undef CCV_CLK
`undef CCV_RST
