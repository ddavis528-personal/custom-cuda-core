//===-- dcu_bctl.sv - DCU bank control: one bank's arbitration and predictor ===//
//
// Spec: docs/design-snapshots/dcu-spec.md (live: CCV per-block architecture
//       specs, DCU tab, "MA's Phase 2", slice 1 (rev 83): the stage table's
//       D0 to D3 rows, "Bank arbitration", "LRU and the predictor", the
//       module partition's dcu_bctl row and the port budgets).
//
// One instance per bank (8). Slice 1's read lookups: the bank's arbitration
// and its every-other-cycle cadence, the lookup queue, the way predictor's
// fold table, the PLRU bits, the mispredict re-read, the entry credits
// (ent_ret) and the data SRAM's address, ce and we.
//
//   H+1  the leads: the lowest slot whose lead names this bank, flopped
//        (the pick, as dcu_btag's; CG-5).
//   D0 = H+2  the picked slot's set: its fold row read from the fold table,
//        and the payload (req_id, pa_fold, drop) taken from the channel's
//        wires as it lands, so each way's fold compare is made here. The
//        arbitration picks the owner of the H+3 access, in order: the
//        mispredict re-read; the queue's head once CCV_DCU_BANK_AGE old (the
//        head's deadline stored at its push, compared per entry, from flops
//        a cycle ahead); dcu_fix's access; this lead; then the oldest waiter.
//   D1 = H+3  the predicted way, the lowest whose fold matched, is picked. A
//        granted lookup addresses the SRAM with {set, predicted way}; ce is
//        cleared by drop and by no match (a miss), and the cycle is free
//        again. A lead that lost the bank waits for its tag result unless
//        dropped.
//   fix  dcu_fix's request is a lead (fxv) and, a cycle on, its payload (we,
//        address): it is pending until it wins a cycle, and its grant (fxg)
//        goes back from a flop.
//   D2 = H+4  btag's result: a hit on another way than the predicted one is
//        a mispredict and takes the H+5 access (due + 2). A hit updates the
//        set's PLRU bits (a cycle on, from flops: CG-5). A loser that hit
//        joins the queue (or takes the next access straight away when the
//        queue is empty); one that missed, and a granted lookup that missed,
//        leaves for a miss buffer (slice 2: av/mv below).
//   D3      the answer carry: the access two cycles back gave a valid
//        answer (av: req_id, slot, late) or a miss (mv), from flops.
//
// The queue holds only hits: a loser's tag result is known before it waits,
// so a waiter reads its line's way without prediction. A queued lookup keeps
// that result; slice 2's fills and evictions, which can change it, are not
// in slice 1.
//
// Stage tags: the bank's control state (grants, carries, the queue, PLRU,
// the credit count) is one stage, 04, as a queue's entries and count are
// (CCV-L23's own-stage state); the nets that compute its next value read it at
// its own stage. The lookup's own pipeline keeps the channel's stages
// (02 to 04). The fold table's write port is slice 2's; its tags are
// placeholders.
//
// The reference is the DCU model's bank (sim/dcu/dcu_core.cpp, schedule()
// and serveLook()), and test/dcu/bctl_tb.cpp holds this module to a value
// model of it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK dcu_core_clk
`define CCV_RST rst_r01h
module dcu_bctl #(
  parameter  int BANK  = 0,                                          // this bank
  parameter  int SLOTS = 4,                                          // ccv_miu_dcu_req slots
  parameter  int NB    = $clog2(ccv_params_pkg::CCV_DCU_BANKS),      // bank bits, 3
  parameter  int WS    = ccv_prov_pkg::CCV_W_DCU_SET,                // set index, 9
  parameter  int WAYS  = ccv_prov_pkg::CCV_DCU_WAYS,                 // 8
  parameter  int WI    = ccv_prov_pkg::CCV_P_W_REQ_MIU_DCU,          // req_id, 6
  parameter  int WF    = ccv_prov_pkg::CCV_DCU_WAYPRED_BITS,       // fold bits
  parameter  int QD    = ccv_prov_pkg::CCV_DCU_BANK_QDEPTH,        // queue, 16
  parameter  int AGE   = ccv_prov_pkg::CCV_DCU_BANK_AGE,           // 16
  localparam int WR    = WS - NB,                                    // set in the bank, 6
  localparam int NSET  = 1 << WR,                                    // 64
  localparam int WWY   = WAYS > 1 ? $clog2(WAYS) : 1,                // 3
  localparam int WSL   = SLOTS > 1 ? $clog2(SLOTS) : 1,              // 2
  localparam int WQ    = $clog2(QD),                                 // 4
  localparam int WTS   = 8,                                          // age stamp
  localparam int NPL   = WAYS - 1,                                   // PLRU bits a set, 7
  localparam int WFE   = WF + 1                                      // fold entry: valid, fold
) (
  input  logic                   dcu_core_clk,
  input  logic                   rst_n,
  // H+1: the channel's leads, each slot's valid and its set's bank bits.
  input  logic [SLOTS-1:0]       rv_cc01h,
  input  logic [SLOTS*NB-1:0]    lsb_cc01h,
  // D0: each slot's set, from its dcu_cap.
  input  logic [SLOTS*WS-1:0]    lsi_cc02h,
  // D0: each slot's payload on the channel's wires (dcu_cap captures them
  // beside): req_id, pa_fold, drop.
  input  logic [SLOTS*WI-1:0]    rid_cc02h,
  input  logic [SLOTS*WF-1:0]    fold_cc02h,
  input  logic [SLOTS-1:0]       drop_cc02h,
  // D2: the lookup's tag result, from dcu_btag.
  input  logic                   hit_cc04h,
  input  logic [WAYS-1:0]        way_cc04h,      // one-hot
  // dcu_fix's access (one CE rewrite's read or write), from its flops: fxv a
  // one-cycle lead, its payload a cycle on; the next only after fxg.
  input  logic                   fxv_cc03h,
  input  logic                   fxw_cc04h,      // the write
  input  logic [WR+WWY-1:0]      fxa_cc04h,      // {set, way}
  // The fold table's write port (slice 2's fills): fwe a cycle ahead.
  input  logic                   fwe_cc00h,
  input  logic [WR-1:0]          fws_cc01h,
  input  logic [WWY-1:0]         fwy_cc01h,
  input  logic [WF-1:0]          fwf_cc01h,
  // The PLRU victim of a set (slice 2's fills), a cycle on.
  input  logic [WR-1:0]          pvs_cc04h,
  output logic [WWY-1:0]         pvw_cc05h,
  // The data SRAM (dcu_bdat): {set, way}, ce and we, this cycle's access.
  output logic [WR+WWY-1:0]      sa_cc04h,
  output logic                   ce_cc04h,
  output logic                   we_cc04h,
  output logic                   fxg_cc04h,      // this cycle's access is dcu_fix's
  // D3: the access two cycles back answered (or missed).
  output logic                   av_cc04h,
  output logic [WI-1:0]          arid_cc04h,
  output logic [WSL-1:0]         aslot_cc04h,
  output logic                   alate_cc04h,    // not its contracted slot
  output logic                   mv_cc04h,       // a miss (slice 2: a miss buffer)
  output logic [WI-1:0]          mrid_cc04h,
  output logic [WSL-1:0]         mslot_cc04h,
  // An entry credit back to MIU (ccv_dcu_miu_cred's ent_ret for this bank).
  output logic                   ent_ret_cc04h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge dcu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  function automatic logic [WWY-1:0] enc(input logic [WAYS-1:0] oh);
    enc = '0;
    for (int w = 0; w < WAYS; w++) if (oh[w]) enc = enc | WWY'(w);
  endfunction

  // ---- H+1: the lowest slot whose lead names this bank --------------------
  logic [SLOTS-1:0] nm_cc01h, pk_cc01h;
  always_comb begin
    for (int s = 0; s < SLOTS; s++)
      nm_cc01h[s] = rv_cc01h[s] && lsb_cc01h[s*NB +: NB] == NB'(BANK);
    for (int s = 0; s < SLOTS; s++) begin
      pk_cc01h[s] = nm_cc01h[s];
      for (int j = 0; j < s; j++) pk_cc01h[s] = pk_cc01h[s] && !nm_cc01h[j];
    end
  end

  // The pick, captured every cycle (an interface lead: CG-5, waived "lead"),
  // with a copy (keep) that selects the set alone: the set's path, through
  // the fold table's 64:1 row select and the compare, is D0's longest.
  (* keep *) logic [SLOTS-1:0] pk_q_cc02h;
  (* keep *) logic [SLOTS-1:0] pks_q_cc02h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) begin
      pk_q_cc02h  <= '0;
      pks_q_cc02h <= '0;
    end else begin
      pk_q_cc02h  <= pk_cc01h;
      pks_q_cc02h <= pk_cc01h;
    end
  end

  // ---- the fold table's write port (slice 2) --------------------------------
  logic fwe_q_cc01h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) fwe_q_cc01h <= 1'b0;
    else          fwe_q_cc01h <= fwe_cc00h;
  end
  // The write, captured from the pins under its lead's flop.
  logic            fwv_q_cc02h;
  logic [WR-1:0]   fws_q_cc02h;
  logic [WWY-1:0]  fwy_q_cc02h;
  logic [WF-1:0]   fwf_q_cc02h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) fwv_q_cc02h <= 1'b0;
    else          fwv_q_cc02h <= fwe_q_cc01h;
  end
  logic fwd_en_cc01h;
  assign fwd_en_cc01h = fwe_q_cc01h;
  always_ff @(posedge dcu_core_clk) begin
    if (fwd_en_cc01h) begin
      fws_q_cc02h <= fws_cc01h;
      fwy_q_cc02h <= fwy_cc01h;
      fwf_q_cc02h <= fwf_cc01h;
    end
  end

  // The fold table: per set, each way's {valid, fold}. A row is one clock
  // gate (8 x WFE flops), written by a fill, cleared by reset.
  // The row is the gate: a fill clocks its set's 8 x WFE flops and changes
  // one way's, the others written back through a mask (an AND-OR, not a
  // per-way hold, which synthesis would split into gates of WFE flops).
  logic [WAYS*WFE-1:0] ft_q_cc03h [NSET];
  logic [WAYS*WFE-1:0] fm_cc02h, fv_cc02h;
  always_comb begin
    for (int w = 0; w < WAYS; w++) begin
      fm_cc02h[w*WFE +: WFE] = {WFE{rst_r01h || fwy_q_cc02h == WWY'(w)}};
      fv_cc02h[w*WFE +: WFE] = rst_r01h ? '0 : {1'b1, fwf_q_cc02h};
    end
  end
  for (genvar r = 0; r < NSET; r++) begin : g_ft
    logic                ft_en_cc02h;
    logic [WAYS*WFE-1:0] ftn_cc02h;
    assign ft_en_cc02h = rst_r01h || (fwv_q_cc02h && fws_q_cc02h == WR'(r));
    assign ftn_cc02h   = (ft_q_cc03h[r] & ~fm_cc02h) | (fv_cc02h & fm_cc02h);
    always_ff @(posedge dcu_core_clk) begin
      if (ft_en_cc02h) ft_q_cc03h[r] <= ftn_cc02h;
    end
  end

  // ---- D0: the lead's set, its payload and the fold compare ----------------
  // The predicted way is decided here, a cycle ahead of the access, from the
  // fold row and the payload's fold on the channel's wires, so that D1's
  // SRAM address and ce start from flops.
  logic lv_cc02h;
  assign lv_cc02h = |pk_q_cc02h;
  logic [WR-1:0]  set_cc02h;
  logic [WI-1:0]  rids_cc02h;
  logic [WF-1:0]  folds_cc02h;
  logic           drops_cc02h;
  logic [WSL-1:0] slot_cc02h;
  always_comb begin
    set_cc02h   = '0;
    rids_cc02h  = '0;
    folds_cc02h = '0;
    drops_cc02h = 1'b0;
    slot_cc02h  = '0;
    for (int s = 0; s < SLOTS; s++)
      if (pks_q_cc02h[s]) set_cc02h = set_cc02h | lsi_cc02h[s*WS + NB +: WR];
    for (int s = 0; s < SLOTS; s++)
      if (pk_q_cc02h[s]) begin
        rids_cc02h  = rids_cc02h | rid_cc02h[s*WI +: WI];
        folds_cc02h = folds_cc02h | fold_cc02h[s*WF +: WF];
        drops_cc02h = drops_cc02h | drop_cc02h[s];
        slot_cc02h  = slot_cc02h | WSL'(s);
      end
  end
  logic [WAYS*WFE-1:0] fr_cc03h;
  always_comb begin
    fr_cc03h = '0;
    for (int r = 0; r < NSET; r++)
      if (set_cc02h == WR'(r)) fr_cc03h = fr_cc03h | ft_q_cc03h[r];
  end
  logic [WAYS-1:0] fm_cc03h;
  always_comb begin
    for (int w = 0; w < WAYS; w++)
      fm_cc03h[w] = fr_cc03h[w*WFE + WF] && fr_cc03h[w*WFE +: WF] == folds_cc02h;
  end
  logic am_cc03h;
  assign am_cc03h = |fm_cc03h;

  // The lead a cycle on: its slot (every cycle: 0 is none), and under it its
  // set, payload and predicted way. The flops the SRAM's address and ce read
  // are copied (keep): those outputs' budgets hold every path they start
  // (NGD-7), and the arbitration reads the other copies.
  logic [SLOTS-1:0]    pk_q_cc03h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) pk_q_cc03h <= '0;
    else          pk_q_cc03h <= pk_q_cc02h;
  end
  logic ld_en_cc02h;
  assign ld_en_cc02h = lv_cc02h;
  logic [WR-1:0]   set_q_cc03h;
  logic [WI-1:0]   rid_q_cc03h;
  logic [WSL-1:0]  slot_q_cc03h;
  (* keep *) logic drop_q_cc03h;
  logic [WAYS-1:0] fm_q_cc04h;
  (* keep *) logic am_q_cc04h;
  (* keep *) logic            dropo_q_cc03h;
  (* keep *) logic [WAYS-1:0] fmo_q_cc04h;
  (* keep *) logic            amo_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (ld_en_cc02h) begin
      set_q_cc03h   <= set_cc02h;
      rid_q_cc03h   <= rids_cc02h;
      slot_q_cc03h  <= slot_cc02h;
      drop_q_cc03h  <= drops_cc02h;
      fm_q_cc04h    <= fm_cc03h;
      am_q_cc04h    <= am_cc03h;
      dropo_q_cc03h <= drops_cc02h;
      fmo_q_cc04h   <= fm_cc03h;
      amo_q_cc04h   <= am_cc03h;
    end
  end

  // ---- D1 ---------------------------------------------------------------------
  logic v_cc03h;
  assign v_cc03h = |pk_q_cc03h;
  // The predicted way: the lowest whose fold matches (CCV_DCU_WAYPRED_SEL 0).
  function automatic logic [WAYS-1:0] lowest(input logic [WAYS-1:0] m);
    for (int w = 0; w < WAYS; w++) begin
      lowest[w] = m[w];
      for (int j = 0; j < w; j++) lowest[w] = lowest[w] && !m[j];
    end
  endfunction
  logic [WWY-1:0] pw_cc04h;
  assign pw_cc04h = enc(lowest(fmo_q_cc04h));

  // The lookup a cycle on (D2): its req_id, slot, set and predicted way.
  logic lc_en_cc03h;
  assign lc_en_cc03h = v_cc03h;
  logic [WI-1:0]   rid_q_cc04h;
  logic [WSL-1:0]  slot_q_cc04h;
  logic [WR-1:0]   set_q_cc04h;
  logic [WAYS-1:0] pw2_q_cc04h;
  logic            am2_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (lc_en_cc03h) begin
      rid_q_cc04h  <= rid_q_cc03h;
      slot_q_cc04h <= slot_q_cc03h;
      set_q_cc04h  <= set_q_cc03h;
      pw2_q_cc04h  <= lowest(fm_q_cc04h);
      am2_q_cc04h  <= am_q_cc04h;
    end
  end

  // ---- the bank's state (stage 04) ------------------------------------------
  // This cycle's access: whose it is (one-hot, or none) and, for all but a
  // new lookup's, its {set, way}; its answer's req_id and slot.
  (* keep *) logic gn_q_cc04h;     // the new lookup (D1 this cycle)
  // The grants' copies for the SRAM's address and ce (keep; NGD-7).
  (* keep *) logic gno_q_cc04h, gqo_q_cc04h, gro_q_cc04h, gxo_q_cc04h;
  // dcu_fix's request: its lead flopped, then its payload captured and held
  // pending until granted.
  logic            fxv_q_cc04h, fp_q_cc04h, fw_q_cc04h;
  logic [WR+WWY-1:0] fa_q_cc04h;
  (* keep *) logic gq_q_cc04h;     // a waiter (the queue's head, or the bypass)
  (* keep *) logic gr_q_cc04h;     // the mispredict re-read
  (* keep *) logic gx_q_cc04h;     // dcu_fix's
  // ce's own: the new lookup's grant, and any other access's (keep; NGD-7).
  (* keep *) logic gnc_q_cc04h, ceo_q_cc04h, gxg_q_cc04h;
  // The queue's head is CCV_DCU_BANK_AGE old (from flops, a cycle ahead).
  logic            aged_q_cc04h;
  logic            gw_q_cc04h;     // dcu_fix's, a write
  logic [WR+WWY-1:0] ga_q_cc04h, ra_q_cc04h;
  logic [WI-1:0]   grid_q_cc04h, rrid_q_cc04h;
  logic [WSL-1:0]  gslot_q_cc04h, rslot_q_cc04h;
  // The lookup at D2: granted and not dropped (wn), or a loser not dropped (lq).
  logic            wn_q_cc04h, lq_q_cc04h;
  // A loser that hit, waiting to be written into the queue (pq), and its entry.
  logic            pq_q_cc04h;
  logic [WI-1:0]   prid_q_cc04h;
  logic [WSL-1:0]  pslot_q_cc04h;
  logic [WR+WWY-1:0] pa_q_cc04h;
  logic [WTS-1:0]  pts_q_cc04h;
  // The queue: a FIFO of hits.
  logic [WI-1:0]   qrid_q_cc04h  [QD];
  logic [WSL-1:0]  qslot_q_cc04h [QD];
  logic [WR+WWY-1:0] qa_q_cc04h  [QD];
  logic [WTS-1:0]  qts_q_cc04h   [QD];
  logic [WQ-1:0]   qh_q_cc04h, qt_q_cc04h;
  logic [WQ:0]     qn_q_cc04h;
  logic [WTS-1:0]  ts_q_cc04h;
  // The answer carry (a cycle after the access; av a cycle on) and misses.
  logic            oq_q_cc04h;
  logic [WI-1:0]   orid_q_cc04h;
  logic [WSL-1:0]  oslot_q_cc04h;
  logic            av_q_cc04h, alate_q_cc04h;
  logic [WI-1:0]   arid_q_cc04h;
  logic [WSL-1:0]  aslot_q_cc04h;
  logic            mv_q_cc04h;
  logic [WI-1:0]   mrid_q_cc04h;
  logic [WSL-1:0]  mslot_q_cc04h;
  // Entry credits: one a cycle, the rest owed.
  logic [WQ+1:0]   ow_q_cc04h;
  logic            er_q_cc04h;
  // A hit's PLRU update, a cycle on (CG-5: its enable from flops).
  logic            pu_q_cc04h;
  logic [WR-1:0]   pus_q_cc04h;
  logic [WWY-1:0]  puw_q_cc04h;

  // ---- the D side: this cycle's events and the next access's owner (04) ----
  // This cycle's access is real: a new lookup's unless dropped or unmatched.
  logic acc_cc04h;
  assign acc_cc04h = (gn_q_cc04h && !drop_q_cc03h && am_q_cc04h) || gq_q_cc04h ||
                    gr_q_cc04h || gx_q_cc04h;
  // D2: the mispredict, the misses and the loser that hit.
  logic [WWY-1:0] hw_cc04h;
  assign hw_cc04h = enc(way_cc04h);
  logic mp_cc04h;
  assign mp_cc04h = wn_q_cc04h && hit_cc04h && ~|(way_cc04h & pw2_q_cc04h);   // both one-hot on a hit
  logic wm_cc04h;
  assign wm_cc04h = wn_q_cc04h && !hit_cc04h;
  logic lh_cc04h;
  assign lh_cc04h = lq_q_cc04h && hit_cc04h;
  logic lm_cc04h;
  assign lm_cc04h = lq_q_cc04h && !hit_cc04h;
  // The waiter: the queue's head; else the loser written next; else the
  // loser at D2 that hit (the bypass), youngest last.
  logic qne_cc04h;
  assign qne_cc04h = qn_q_cc04h != '0;
  logic wv_cc04h;
  assign wv_cc04h = qne_cc04h || pq_q_cc04h || lh_cc04h;
  logic [WI-1:0]     wrid_cc04h;
  logic [WSL-1:0]    wslot_cc04h;
  logic [WR+WWY-1:0] wa_cc04h;
  always_comb begin
    if (qne_cc04h) begin
      wrid_cc04h  = qrid_q_cc04h[qh_q_cc04h];
      wslot_cc04h = qslot_q_cc04h[qh_q_cc04h];
      wa_cc04h    = qa_q_cc04h[qh_q_cc04h];
    end else if (pq_q_cc04h) begin
      wrid_cc04h  = prid_q_cc04h;
      wslot_cc04h = pslot_q_cc04h;
      wa_cc04h    = pa_q_cc04h;
    end else begin
      wrid_cc04h  = rid_q_cc04h;
      wslot_cc04h = slot_q_cc04h;
      wa_cc04h    = {set_q_cc04h, hw_cc04h};
    end
  end
  // A waiter ages from its D1: the head is aged at the arbitration when
  // CCV_DCU_BANK_AGE has passed by its access (the model's now - born >= age),
  // its stamp taken at its D2. Next cycle's head is this one's, or the one
  // behind it after a pop; a head written into an empty queue is too young.
  // Each entry's age is compared in parallel, the head's then selected.
  logic [WQ-1:0] qh1_cc04h;
  assign qh1_cc04h = qh_q_cc04h + 1'b1;
  logic [QD-1:0] eag_cc04h;
  logic [WTS-1:0] dt_cc04h [QD];
  always_comb begin
    for (int e = 0; e < QD; e++) dt_cc04h[e] = ts_q_cc04h - qts_q_cc04h[e];
  end
  always_comb begin
    for (int e = 0; e < QD; e++)
      eag_cc04h[e] = !dt_cc04h[e][WTS-1];   // ts at or past the deadline
  end
  logic ag0_cc04h, ag1_cc04h;
  assign ag0_cc04h = qne_cc04h && eag_cc04h[qh_q_cc04h];
  assign ag1_cc04h = qn_q_cc04h > (WQ+1)'(1) && eag_cc04h[qh1_cc04h];
  logic aged_cc04h;
  assign aged_cc04h = aged_q_cc04h;
  // The arbitration: the next cycle's access, if this one's is not real.
  logic bf_cc04h;
  assign bf_cc04h = !acc_cc04h;
  logic tr_cc04h;
  assign tr_cc04h = bf_cc04h && mp_cc04h;
  logic ta_cc04h;
  assign ta_cc04h = bf_cc04h && !mp_cc04h && aged_cc04h;
  logic tx_cc04h;
  assign tx_cc04h = bf_cc04h && !mp_cc04h && !aged_cc04h && fp_q_cc04h;
  logic tn_cc04h;
  assign tn_cc04h = bf_cc04h && !mp_cc04h && !aged_cc04h && !fp_q_cc04h && lv_cc02h;
  logic tw_cc04h;
  assign tw_cc04h = bf_cc04h && !mp_cc04h && !aged_cc04h && !fp_q_cc04h && !lv_cc02h &&
                    wv_cc04h;
  logic tq_cc04h;
  assign tq_cc04h = ta_cc04h || tw_cc04h;
  // Which waiter went: the head, the one to be written, or the bypass.
  logic popq_cc04h;
  assign popq_cc04h = tq_cc04h && qne_cc04h;
  logic popp_cc04h;
  assign popp_cc04h = tq_cc04h && !qne_cc04h && pq_q_cc04h;
  logic popl_cc04h;
  assign popl_cc04h = tq_cc04h && !qne_cc04h && !pq_q_cc04h;
  // The queue's write: the loser written last cycle unless it went now.
  logic push_cc04h;
  assign push_cc04h = pq_q_cc04h && !popp_cc04h;
  // Entry credits: the access of a waiter or a new lookup that was not
  // dropped (it read its line, or left as a miss); a loser that missed.
  logic e1_cc04h;
  assign e1_cc04h = (gn_q_cc04h && !drop_q_cc03h) || gq_q_cc04h;
  logic e2_cc04h;
  assign e2_cc04h = lm_cc04h;
  logic [WQ+1:0] ow_cc04h;
  assign ow_cc04h = ow_q_cc04h + (WQ+2)'(e1_cc04h) + (WQ+2)'(e2_cc04h);

  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) begin
      gn_q_cc04h <= 1'b0;
      gno_q_cc04h <= 1'b0;
      gqo_q_cc04h <= 1'b0;
      gro_q_cc04h <= 1'b0;
      gxo_q_cc04h <= 1'b0;
      fxv_q_cc04h <= 1'b0;
      gnc_q_cc04h <= 1'b0;
      gxg_q_cc04h <= 1'b0;
      ceo_q_cc04h <= 1'b0;
      aged_q_cc04h <= 1'b0;
      fp_q_cc04h <= 1'b0;
      gq_q_cc04h <= 1'b0;
      gr_q_cc04h <= 1'b0;
      gx_q_cc04h <= 1'b0;
      gw_q_cc04h <= 1'b0;
      wn_q_cc04h <= 1'b0;
      lq_q_cc04h <= 1'b0;
      pq_q_cc04h <= 1'b0;
      qh_q_cc04h <= '0;
      qt_q_cc04h <= '0;
      qn_q_cc04h <= '0;
      ts_q_cc04h <= '0;
      oq_q_cc04h <= 1'b0;
      av_q_cc04h <= 1'b0;
      mv_q_cc04h <= 1'b0;
      ow_q_cc04h <= '0;
      er_q_cc04h <= 1'b0;
      pu_q_cc04h <= 1'b0;
      hn_q_cc04h <= 1'b0;
    end else begin
      gn_q_cc04h <= tn_cc04h;
      gno_q_cc04h <= tn_cc04h;
      gqo_q_cc04h <= tq_cc04h;
      gro_q_cc04h <= tr_cc04h;
      gxo_q_cc04h <= tx_cc04h;
      fxv_q_cc04h <= fxv_cc03h;
      gnc_q_cc04h <= tn_cc04h;
      gxg_q_cc04h <= tx_cc04h;
      ceo_q_cc04h <= tq_cc04h || tr_cc04h || tx_cc04h;
      aged_q_cc04h <= popq_cc04h ? ag1_cc04h : ag0_cc04h;
      fp_q_cc04h <= (fp_q_cc04h || fxv_q_cc04h) && !tx_cc04h;
      gq_q_cc04h <= tq_cc04h;
      gr_q_cc04h <= tr_cc04h;
      gx_q_cc04h <= tx_cc04h;
      gw_q_cc04h <= tx_cc04h && fw_q_cc04h;
      wn_q_cc04h <= gn_q_cc04h && !drop_q_cc03h;
      lq_q_cc04h <= v_cc03h && !gn_q_cc04h && !drop_q_cc03h;
      pq_q_cc04h <= lh_cc04h && !popl_cc04h;
      qh_q_cc04h <= qh_q_cc04h + WQ'(popq_cc04h);
      qt_q_cc04h <= qt_q_cc04h + WQ'(push_cc04h);
      qn_q_cc04h <= qn_q_cc04h + (WQ+1)'(push_cc04h) - (WQ+1)'(popq_cc04h);
      ts_q_cc04h <= ts_q_cc04h + 1'b1;
      oq_q_cc04h <= gq_q_cc04h || gr_q_cc04h;
      av_q_cc04h <= oq_q_cc04h || (wn_q_cc04h && hit_cc04h && !mp_cc04h);
      mv_q_cc04h <= wm_cc04h || lm_cc04h;
      ow_q_cc04h <= ow_cc04h - (WQ+2)'(ow_cc04h != '0);
      er_q_cc04h <= ow_cc04h != '0;
      pu_q_cc04h <= (wn_q_cc04h || lq_q_cc04h) && hit_cc04h;
      hn_q_cc04h <= popq_cc04h || popp_cc04h || (wnd_cc04h && !ga_en_cc04h);
    end
  end

  // The next access's {set, way} and answer fields (a new lookup's come
  // from its pipeline, dcu_fix's from its pins). The re-read's: the D2
  // lookup's, written under its own flop (wn). A waiter's, written from flops
  // (CG-5) when the bank may be free and a waiter may go: never in a cycle
  // whose access is a waiter's, the re-read's or dcu_fix's; with only queued
  // waiters, only when the head is new (a pop) or the D2 loser may be the
  // next, and again when the bank kept it from being written.
  logic r_en_cc04h;
  assign r_en_cc04h = wn_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (r_en_cc04h) begin
      ra_q_cc04h    <= {set_q_cc04h, hw_cc04h};
      rrid_q_cc04h  <= rid_q_cc04h;
      rslot_q_cc04h <= slot_q_cc04h;
    end
  end
  logic hn_q_cc04h;   // the waiter changed and is not yet written
  logic lb_cc04h, wnd_cc04h, ga_en_cc04h;
  assign lb_cc04h    = lq_q_cc04h && !qne_cc04h && !pq_q_cc04h;   // the D2 loser may be next
  assign wnd_cc04h    = hn_q_cc04h || lb_cc04h;
  assign ga_en_cc04h = !(gq_q_cc04h || gr_q_cc04h || gx_q_cc04h) && wnd_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (ga_en_cc04h) begin
      ga_q_cc04h    <= wa_cc04h;
      grid_q_cc04h  <= wrid_cc04h;
      gslot_q_cc04h <= wslot_cc04h;
    end
  end

  // dcu_fix's payload, a cycle after its lead (CG-5).
  logic f_en_cc04h;
  assign f_en_cc04h = fxv_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (f_en_cc04h) begin
      fw_q_cc04h <= fxw_cc04h;
      fa_q_cc04h <= fxa_cc04h;
    end
  end

  // The answer's fields a cycle after a waiter's or re-read's access.
  logic o_en_cc04h;
  assign o_en_cc04h = gq_q_cc04h || gr_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (o_en_cc04h) begin
      orid_q_cc04h  <= gr_q_cc04h ? rrid_q_cc04h : grid_q_cc04h;
      oslot_q_cc04h <= gr_q_cc04h ? rslot_q_cc04h : gslot_q_cc04h;
    end
  end
  logic a_en_cc04h;
  assign a_en_cc04h = oq_q_cc04h || wn_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (a_en_cc04h) begin
      arid_q_cc04h  <= oq_q_cc04h ? orid_q_cc04h : rid_q_cc04h;
      aslot_q_cc04h <= oq_q_cc04h ? oslot_q_cc04h : slot_q_cc04h;
      alate_q_cc04h <= oq_q_cc04h;
    end
  end
  logic m_en_cc04h;
  assign m_en_cc04h = wn_q_cc04h || lq_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (m_en_cc04h) begin
      mrid_q_cc04h  <= rid_q_cc04h;
      mslot_q_cc04h <= slot_q_cc04h;
    end
  end

  // The loser that hit, its entry captured at D2 (under its own flop).
  logic p_en_cc04h;
  assign p_en_cc04h = lq_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (p_en_cc04h) begin
      prid_q_cc04h  <= rid_q_cc04h;
      pslot_q_cc04h <= slot_q_cc04h;
      pa_q_cc04h    <= {set_q_cc04h, hw_cc04h};
      pts_q_cc04h   <= ts_q_cc04h + WTS'(AGE - 3);   // the deadline
    end
  end

  // The queue's entries: one clock gate each, written from the captured loser.
  for (genvar e = 0; e < QD; e++) begin : g_q
    logic q_en_cc04h;
    assign q_en_cc04h = pq_q_cc04h && qt_q_cc04h == WQ'(e);
    always_ff @(posedge dcu_core_clk) begin
      if (q_en_cc04h) begin
        qrid_q_cc04h[e]  <= prid_q_cc04h;
        qslot_q_cc04h[e] <= pslot_q_cc04h;
        qa_q_cc04h[e]    <= pa_q_cc04h;
        qts_q_cc04h[e]   <= pts_q_cc04h;
      end
    end
  end

  // The PLRU bits: per set, a tree of WAYS-1, a touch pointing every node on
  // the way's path away from it (the model's plruTouch). Two sets a clock
  // gate (a set's 7 alone are under the gate's 8).
  logic [NPL-1:0] pl_q_cc04h [NSET];
  // A touch's nodes (the mask) and their new values: the set's bits are
  // written back through the mask, an AND-OR, so the pair of sets stays one
  // gate (a per-bit hold would split it).
  function automatic logic [2*NPL-1:0] path(input logic [WWY-1:0] way);
    logic [NPL-1:0] m, v;
    int n, lo, half;
    logic right;
    m = '0; v = '0; n = 0; lo = 0;
    for (half = WAYS / 2; half > 0; half = half / 2) begin
      right = {{(32-WWY){1'b0}}, way} >= lo + half;
      m[n] = 1'b1;
      v[n] = !right;
      if (right) lo = lo + half;
      n = 2 * n + 1 + (right ? 1 : 0);
    end
    path = {m, v};
  endfunction
  for (genvar p = 0; p < NSET / 2; p++) begin : g_pl
    logic                 pl_en_cc04h;
    logic [2*NPL-1:0]     pln_cc04h;
    assign pl_en_cc04h = rst_r01h || (pu_q_cc04h && pus_q_cc04h[WR-1:1] == (WR-1)'(p));
    always_comb begin
      for (int h = 0; h < 2; h++) begin
        logic [NPL-1:0] m, v;
        {m, v} = path(puw_q_cc04h);
        m = rst_r01h ? '1 : pus_q_cc04h[0] == 1'(h) ? m : '0;
        v = rst_r01h ? '0 : v;
        pln_cc04h[h*NPL +: NPL] = (pl_q_cc04h[2*p+h] & ~m) | (v & m);
      end
    end
    always_ff @(posedge dcu_core_clk) begin
      if (pl_en_cc04h) begin
        pl_q_cc04h[2*p]   <= pln_cc04h[0 +: NPL];
        pl_q_cc04h[2*p+1] <= pln_cc04h[NPL +: NPL];
      end
    end
  end
  logic pu_en_cc04h;
  assign pu_en_cc04h = (wn_q_cc04h || lq_q_cc04h);
  always_ff @(posedge dcu_core_clk) begin
    if (pu_en_cc04h) begin
      pus_q_cc04h <= set_q_cc04h;
      puw_q_cc04h <= hw_cc04h;
    end
  end

  // A set's victim (the model's plruVictim), a cycle on (slice 2's fills).
  logic [NPL-1:0] pv_cc04h;
  always_comb begin
    pv_cc04h = '0;
    for (int r = 0; r < NSET; r++)
      if (pvs_cc04h == WR'(r)) pv_cc04h = pv_cc04h | pl_q_cc04h[r];
  end
  function automatic logic [WWY-1:0] victim(input logic [NPL-1:0] b);
    int n, lo, half;
    logic right;
    n = 0; lo = 0;
    for (half = WAYS / 2; half > 0; half = half / 2) begin
      right = b[n];
      if (right) lo = lo + half;
      n = 2 * n + 1 + (right ? 1 : 0);
    end
    victim = WWY'(lo);
  endfunction
  logic [WWY-1:0] pvw_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    pvw_q_cc05h <= victim(pv_cc04h);
  end

  // ---- the outputs ----------------------------------------------------------
  // The SRAM: a new lookup's {set, predicted way}, else the flopped access.
  assign sa_cc04h      = gno_q_cc04h ? {set_q_cc03h, pw_cc04h} :
                         gxo_q_cc04h ? fa_q_cc04h : gro_q_cc04h ? ra_q_cc04h : ga_q_cc04h;
  assign ce_cc04h      = (gnc_q_cc04h && !dropo_q_cc03h && amo_q_cc04h) || ceo_q_cc04h;
  assign we_cc04h      = gw_q_cc04h;
  assign fxg_cc04h     = gxg_q_cc04h;
  assign av_cc04h      = av_q_cc04h;
  assign arid_cc04h    = arid_q_cc04h;
  assign aslot_cc04h   = aslot_q_cc04h;
  assign alate_cc04h   = alate_q_cc04h;
  assign mv_cc04h      = mv_q_cc04h;
  assign mrid_cc04h    = mrid_q_cc04h;
  assign mslot_cc04h   = mslot_q_cc04h;
  assign ent_ret_cc04h = er_q_cc04h;
  assign pvw_cc05h     = pvw_q_cc05h;

  // ---- the CHECKs -------------------------------------------------------------
  // One lookup a bank a cycle (MIU's A2, MA-27).
  `CCV_ASSERT(bctl_pick_onehot, $onehot0(pk_q_cc02h))
  // The half-rate bank: never two accesses running (AR 364).
  logic acc_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) acc_q_cc04h <= 1'b0;
    else          acc_q_cc04h <= acc_cc04h;
  end
  `CCV_ASSERT(bctl_half_rate, !(acc_q_cc04h && acc_cc04h))
  // No tag hit without a fold match (MIU's pa_fold is the tags' fold).
  `CCV_ASSERT(bctl_hit_needs_fold, !(wn_q_cc04h && hit_cc04h && !am2_q_cc04h))
  // The credits hold the queue to its depth (MA-25).
  `CCV_ASSERT(bctl_queue_depth, !(push_cc04h && !popq_cc04h && qn_q_cc04h == (WQ+1)'(QD)))
  `CCV_ASSERT(bctl_tag_onehot, !(wn_q_cc04h || lq_q_cc04h) || $onehot0(way_cc04h))

endmodule
`undef CCV_CLK
`undef CCV_RST
