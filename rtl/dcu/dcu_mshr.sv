//===-- dcu_mshr.sv - one DCU bank's miss buffers ---------------------------===//
//
// Spec: docs/design-snapshots/dcu-spec.md (live: CCV per-block architecture
//       specs, DCU tab, "MA's Phase 2", slice 2, part 1: "Miss buffers
//       (dcu_mshr)", "Allocation and merge, at D2", "The request to MLC", the
//       stage table's F row and the module partition's dcu_mshr and
//       dcu_mpick rows; MA-34, DCU tab rev 150). DI-34 records the
//       implementation choices below, DI-64 and DI-65 the split by bank.
//
// One instance a bank (BK), CCV_DCU_MSHR_PER_BANK (16) entries; an entry's
// ccv_dcu_mlc_req req_id is {BK, entry}. An entry holds valid, state
// (unsent, sent, filled), the coh_op it sends, the line's PA[47:7] (its
// bank is BK) and fold, a stamp of its D2 and a merge list of up to 4 MIU
// requests in arrival order (each req_id, op, exclusive and part 3's
// store-data index).
//
// One request a cycle (MA-34): the retry dcu_mpick granted this bank, else
// the bank's own new miss; dcu_bctl queues a new miss behind a waiter or a
// retry pending, so the two never meet.
//
//   D1 = H+3  the slot whose lead names this bank (dcu_cap's lead set index
//        at H+2, flopped here: CG-5) is staged under that flop; A2 sends no
//        two live lookups to one bank (MA-27), and a dropped one is passed
//        over. dcu_cap's copy is the next lookup's by D2 when lookups come
//        back to back.
//   D2 = H+4  the request's line is compared with the 16 entries. It
//        merges into its line's entry (unsent or sent, list not full),
//        allocates the id offered, or waits (list full, filled not written,
//        no id; a new miss behind the bank's waiter of last cycle). The
//        offer is picked a cycle ahead from this module's flops (DI-34 (2)):
//        taken whatever the request did, so an id left unused is offered
//        again two cycles on. An allocation or a merge is written into its
//        entry a cycle on (D3), from this module's record of it, and D2
//        compares against the record while it waits.
//   D3 = H+5  the outcome (placed or waiting, and why) goes back to
//        dcu_bctl from flops.
//   The MLC request (DI-64, DI-65). At T this bank offers dcu_mpick its
//        oldest unsent entry (hv, and the stamp of its D2), from flops
//        picked at T-1; with none, a miss its D2 allocates now (sv, sent
//        straight). At T+1 dcu_mpick names the bank it sent from (snt, from
//        flops): that entry turns sent, and its payload (entry, line,
//        coh_op), captured at T from the entry, the record or the D2
//        request, is offered from flops. The head picked at T for T+1 still
//        names an entry sent at T (the bank learns of it at T+1); dcu_mpick
//        passes over the bank at T+1.
//   F    a fill's req_id, on ccv_mlc_dcu_rsp's wires (arrival 0) under its
//        valid's flop a cycle ahead, reads its entry if the id is this
//        bank's: the line, fold, kind and merge list are flopped here (zero
//        unless it was this bank's, so dcu_fill ORs the banks') and the
//        entry turns filled. A merge in that cycle waits (filled).
//   free dcu_fill names an entry whose line is written and whose answers
//        have all left; it is free a cycle on.
//
// Not here yet: part 2's writeback (an entry's turn into a writeback at W,
// writebacks first in dcu_mpick's request order), part 3's AcquirePerm for a
// full-line store (the store's mask).
//
// Stage tags: the entries, the records, the age matrix, the next ids, the
// offers and the outcome flops are one stage, 05, the block's state
// (CCV-L23's own-stage state), and so is the D2 logic that reads them; what
// reads only the request and the staged slot is 04.
//
// The reference is the DCU model's miss buffers (sim/dcu/dcu_core.cpp,
// missOrWait(), startMiss() and the MLC request in step()), and
// test/dcu/mshr_tb.cpp holds this module to a value model of them.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK dcu_core_clk
`define CCV_RST rst_r01h
module dcu_mshr #(
  parameter  int SLOTS = 4,                                          // ccv_miu_dcu_req slots
  parameter  int NBK   = ccv_params_pkg::CCV_DCU_BANKS,              // 8
  parameter  int BK    = 0,                                          // this bank
  parameter  int WS    = ccv_prov_pkg::CCV_W_DCU_SET,                // lead set index, 9
  parameter  int WI    = ccv_prov_pkg::CCV_P_W_REQ_MIU_DCU,          // MIU req_id, 8
  parameter  int WA    = ccv_prov_pkg::CCV_P_W_PA,                   // PA, 48
  parameter  int WO    = $clog2(ccv_prov_pkg::CCV_P_LINE_BYTES),     // line offset, 7
  parameter  int WF    = ccv_prov_pkg::CCV_DCU_WAYPRED_BITS,         // fold, 4
  parameter  int WC    = ccv_prelim_pkg::CCV_L_W_COH_OP,             // coh_op, 4
  parameter  int WE    = ccv_prov_pkg::CCV_P_W_REQ_DCU_MLC,          // req_id {bank, entry}, 7
  parameter  int LD    = 4,                                          // merge list
  parameter  int WST   = 4,                                          // store-data index
  parameter  int WTS   = 10,                                         // D2 stamp (DI-64)
  localparam int NE    = ccv_params_pkg::CCV_DCU_MSHR_PER_BANK,      // 16
  localparam int WL    = WA - WO,                                    // line, 41
  localparam int WSL   = SLOTS > 1 ? $clog2(SLOTS) : 1,              // 2
  localparam int WB    = NBK > 1 ? $clog2(NBK) : 1,                  // 3
  localparam int WEB   = WE - WB,                                    // entry, 4
  localparam int WLC   = $clog2(LD + 1),                             // list count, 3
  localparam int WLE   = WI + 2 + 1 + WST                            // list item, 15
) (
  input  logic                   dcu_core_clk,
  input  logic                   rst_n,
  // H+2: each slot's lead (valid, set index: its low bits the bank), and
  // D1: each slot's payload, from dcu_cap.
  input  logic [SLOTS-1:0]       v_cc02h,
  input  logic [SLOTS*WS-1:0]    lsi_cc02h,
  input  logic [SLOTS*WI-1:0]    rid_cc03h,
  input  logic [SLOTS*WL-1:0]    pa_cc03h,
  input  logic [SLOTS*WF-1:0]    fold_cc03h,
  input  logic [SLOTS*WC-1:0]    coh_cc03h,
  input  logic [SLOTS-1:0]       excl_cc03h,
  input  logic [SLOTS-1:0]       drop_cc03h,
  // D2: this bank's lookup, from dcu_bctl's flops (its slot names the
  // payload; none while the bank holds a miss-wait waiter), and its tag
  // result from dcu_btag's: a miss is dv && !hit.
  input  logic                   dv_cc04h,
  input  logic                   hit_cc04h,
  input  logic [WSL-1:0]         mslot_cc04h,
  // The retry (DI-35), from dcu_mpick's flops: its grant (R+1, the lead)
  // and at D2 its valid for this bank and its payload.
  input  logic                   rgv_cc03h,
  input  logic [WB-1:0]          rgb_cc03h,
  input  logic                   rv_cc04h,
  input  logic [WL-1:0]          rpa_cc04h,
  input  logic [WI-1:0]          rrid_cc04h,
  input  logic [1:0]             rop_cc04h,      // 0 read, 1 atomic, 2 store
  input  logic                   rexcl_cc04h,
  input  logic [WF-1:0]          rfold_cc04h,
  input  logic [WST-1:0]         rsti_cc04h,
  // D3: the outcome: placed (merged or allocated) or waiting, why.
  output logic                   ov_cc05h,
  output logic                   owait_cc05h,
  output logic [1:0]             owhy_cc05h,     // 0 no entry, 1 list full, 2 filled, 3 bank order
  // The MLC request, with dcu_mpick: the offers (T), whether this bank was
  // sent from (T+1) and the payload of what it offered at T (T+1).
  output logic                   hv_cc05h,
  output logic [WTS-1:0]         hstp_cc05h,
  output logic                   sv_cc05h,
  input  logic                   snt_cc05h,
  output logic [WEB-1:0]         pid_cc05h,
  output logic [WL-1:0]          ppa_cc05h,
  output logic [WC-1:0]          pcoh_cc05h,
  // A fill: its valid's flop a cycle ahead (F-1), its req_id at F.
  input  logic                   fv_cc03h,
  input  logic [WE-1:0]          frid_cc04h,
  // F+1: its entry, for dcu_fill, zero unless the fill was this bank's.
  output logic [WL-1:0]          fpa_cc05h,
  output logic [WF-1:0]          ffold_cc05h,
  output logic [WC-1:0]          fcoh_cc05h,
  output logic [WLC-1:0]         fcnt_cc05h,
  output logic [LD*WLE-1:0]      flist_cc05h,
  // The fill's bank write request (DI-39, MA rev 177), for this bank's
  // dcu_bctl: its lead at F+1 from the F read (the valid and the bank, one
  // hot, this bank's), its line and fold at F+2.
  output logic                   flv_cc05h,
  output logic [NBK-1:0]         fbk_cc05h,
  output logic [WL-1:0]          fwpa_cc06h,
  output logic [WF-1:0]          fwfold_cc06h,
  // dcu_fill: an entry's line is written and its answers have left.
  input  logic                   xv_cc04h,
  input  logic [WE-1:0]          xid_cc04h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge dcu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  localparam logic [1:0] ST_UNSENT = 2'd0, ST_SENT = 2'd1, ST_FILLED = 2'd2;
  localparam logic [WB-1:0] BKW = WB'(BK);

  // A load reads shared; a store or an atomic acquires the line with its
  // data (part 3 adds AcquirePerm for a full-line store).
  function automatic logic [WC-1:0] coh_of(input logic [1:0] op);
    coh_of = op == 2'd0 ? WC'(0) : WC'(2);
  endfunction

  // ---- D1: the slot of this bank, staged under its lead's flop ----------
  // Each slot's lead for this bank, captured every cycle (interface leads:
  // CG-5, waived "lead"), and a cycle on, the request's lead at D2.
  logic [SLOTS-1:0] lb_q_cc03h;
  always_ff @(posedge dcu_core_clk) begin
    for (int s = 0; s < SLOTS; s++)
      lb_q_cc03h[s] <= !rst_r01h && v_cc02h[s] && lsi_cc02h[s*WS +: WB] == BKW;
  end
  logic sl_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) sl_q_cc04h <= 1'b0;
    else          sl_q_cc04h <= |lb_q_cc03h;
  end
  // The live one (a dropped lookup is not looked up), one-hot; the lowest
  // if the rule were broken (mshr_one_lookup).
  logic [SLOTS-1:0] lbs_cc03h, lbo_cc03h;
  assign lbs_cc03h = lb_q_cc03h & ~drop_cc03h;
  assign lbo_cc03h = lbs_cc03h & ~(lbs_cc03h - SLOTS'(1));
  logic [WI-1:0]  sp_rid_q_cc04h;
  logic [WL-1:0]  sp_pa_q_cc04h;
  logic [WF-1:0]  sp_fold_q_cc04h;
  logic [1:0]     sp_op_q_cc04h;
  logic           sp_excl_q_cc04h;
  logic [WSL-1:0] sp_slot_q_cc04h;
  logic           sp_en_cc03h;
  logic [WI-1:0]  srid_cc03h;
  logic [WL-1:0]  spa_cc03h;
  logic [WF-1:0]  sfold_cc03h;
  logic [WC-1:0]  scoh_cc03h;
  logic           sexcl_cc03h;
  logic [WSL-1:0] sslot_cc03h;
  logic [1:0]     sop_cc03h;
  assign sp_en_cc03h = |lb_q_cc03h;
  always_comb begin
    srid_cc03h  = '0;
    spa_cc03h   = '0;
    sfold_cc03h = '0;
    scoh_cc03h  = '0;
    sexcl_cc03h = 1'b0;
    sslot_cc03h = '0;
    for (int s = 0; s < SLOTS; s++)
      if (lbo_cc03h[s]) begin
        srid_cc03h  = srid_cc03h  | rid_cc03h[s*WI +: WI];
        spa_cc03h   = spa_cc03h   | pa_cc03h[s*WL +: WL];
        sfold_cc03h = sfold_cc03h | fold_cc03h[s*WF +: WF];
        scoh_cc03h  = scoh_cc03h  | coh_cc03h[s*WC +: WC];
        sexcl_cc03h = sexcl_cc03h | excl_cc03h[s];
        sslot_cc03h = sslot_cc03h | WSL'(s);
      end
    // MIU's coh_op as the model decodes it (dcu_block.cpp, decode()).
    sop_cc03h = scoh_cc03h == WC'(0) ? 2'd0 : scoh_cc03h == WC'(2) ? 2'd1 : 2'd2;
  end
  always_ff @(posedge dcu_core_clk) begin
    if (sp_en_cc03h) begin
      sp_rid_q_cc04h  <= srid_cc03h;
      sp_pa_q_cc04h   <= spa_cc03h;
      sp_fold_q_cc04h <= sfold_cc03h;
      sp_op_q_cc04h   <= sop_cc03h;
      sp_excl_q_cc04h <= sexcl_cc03h;
      sp_slot_q_cc04h <= sslot_cc03h;
    end
  end

  // The retry's lead: dcu_mpick's grant of this bank, a cycle before its D2.
  logic rl_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    rl_q_cc04h <= !rst_r01h && rgv_cc03h && rgb_cc03h == BKW;
  end
  // A request may be present at D2: this module's own flops (CG-5).
  logic pres_cc04h;
  assign pres_cc04h = sl_q_cc04h || rl_q_cc04h;

  // ---- D2's request (stage 04) -------------------------------------------
  logic           mv_cc04h;                   // the bank's new miss
  logic           pq_cc04h;                   // a request
  logic [WL-1:0]  qpa_cc04h;
  logic [WF-1:0]  qfold_cc04h;
  logic [1:0]     qop_cc04h;
  logic [WLE-1:0] qit_cc04h;                  // {req_id, op, exclusive, store-data index}
  always_comb begin
    mv_cc04h    = dv_cc04h && !hit_cc04h;
    pq_cc04h    = rl_q_cc04h || mv_cc04h;
    qpa_cc04h   = rl_q_cc04h ? rpa_cc04h : sp_pa_q_cc04h;
    qfold_cc04h = rl_q_cc04h ? rfold_cc04h : sp_fold_q_cc04h;
    qop_cc04h   = rl_q_cc04h ? rop_cc04h : sp_op_q_cc04h;
    qit_cc04h   = rl_q_cc04h ? {rrid_cc04h, rop_cc04h, rexcl_cc04h, rsti_cc04h}
                             : {sp_rid_q_cc04h, sp_op_q_cc04h, sp_excl_q_cc04h, WST'(0)};
  end

  // ---- The state (stage 05) ----------------------------------------------
  logic [NE-1:0]  ev_q_cc05h;                 // valid
  logic [1:0]     est_q_cc05h  [NE];          // state
  logic [WLC-1:0] ecnt_q_cc05h [NE];          // list count
  logic [WL-1:0]  epa_q_cc05h  [NE];
  logic [WF-1:0]  efold_q_cc05h[NE];
  logic [WC-1:0]  ecoh_q_cc05h [NE];
  logic [WTS-1:0] estp_q_cc05h [NE];          // its D2's stamp
  logic [WLE-1:0] elist_q_cc05h[NE][LD];

  // The offered id (one-hot, zero when none), the pick that refills it, a
  // cycle ahead (one-hot), and the offer the request took last cycle.
  logic [NE-1:0]  nfoh_q_cc05h;
  logic           nfv_q_cc05h;
  logic [NE-1:0]  pk_q_cc05h;
  logic           pkv_q_cc05h;                // a pick is made
  logic [NE-1:0]  ua_q_cc05h;

  // The record of last cycle's D2, written into the entries now (D3):
  // whether it allocated, whether it merged; its id, the entry its line hit
  // (one-hot), its payload and its stamp.
  logic           rcal_q_cc05h, rcmg_q_cc05h;
  (* keep *) logic rcalh_q_cc05h;             // rcal's copy for D2's compare alone (fanout)
  logic [NE-1:0]  rcio_q_cc05h;               // its id, one-hot
  logic [NE-1:0]  rcmt_q_cc05h;
  logic [WL-1:0]  rcpa_q_cc05h;
  logic [WF-1:0]  rcfold_q_cc05h;
  logic [1:0]     rcop_q_cc05h;
  logic [WLE-1:0] rcit_q_cc05h;
  logic [WTS-1:0] rcst_q_cc05h;

  // The send order: for each two entries, whether the lower is the older
  // (allocation order); the unsent entries go oldest first.
  logic [NE-1:0]  old_q_cc05h [NE];           // [i][j], i < j: i is the older

  // The time, for the stamps: every bank's and dcu_bctl's, reset together.
  logic [WTS-1:0] tnow_q_cc05h;

  // The MLC offer: the head picked last cycle (valid in two copies: the
  // output's and the rest's; its id one-hot; whether it is the record of
  // last cycle's D2, whose entry is written only now; its stamp), and the
  // offer of last cycle (valid, the id, whether it went straight).
  (* keep *) logic hv_q_cc05h;
  (* keep *) logic hvi_q_cc05h;
  logic [NE-1:0]  hoh_q_cc05h;
  logic           hrc_q_cc05h;
  logic [WTS-1:0] hstp_q_cc05h;
  logic           ofv_q_cc05h;
  logic [NE-1:0]  ofh_q_cc05h;
  logic [WEB-1:0] pid_q_cc05h;
  logic [WL-1:0]  ppa_q_cc05h;
  logic [WC-1:0]  pcoh_q_cc05h;

  // The outcome, and a copy of the wait for the bank order (an output's
  // register drives nothing else).
  logic             ov_q_cc05h;
  (* keep *) logic  ow_q_cc05h;
  logic [1:0]       oy_q_cc05h;
  (* keep *) logic  owi_q_cc05h;
  logic             oany_q_cc05h;

  // Captured every cycle: the fill's lead and this bank's free (CG-5; a
  // lead and a 1-flop event under the module's allowance). The free's id is
  // captured only while an entry is filled (below): a free of another bank's
  // entry must not open it, or it would name a stale id here.
  logic          xv_q_cc05h;
  logic [WEB-1:0] xid_q_cc05h;
  logic          fv_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) begin
      xv_q_cc05h <= 1'b0;
      fv_q_cc04h <= 1'b0;
    end else begin
      xv_q_cc05h <= xv_cc04h && xid_cc04h[WE-1:WEB] == BKW;
      fv_q_cc04h <= fv_cc03h;
    end
  end
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) tnow_q_cc05h <= '0;
    else          tnow_q_cc05h <= tnow_q_cc05h + 1'b1;
  end

  // The fill's entry, when its id is this bank's.
  logic          fmine_cc04h;
  logic [WEB-1:0] fe_cc04h;
  assign fmine_cc04h = frid_cc04h[WE-1:WEB] == BKW;
  assign fe_cc04h    = frid_cc04h[WEB-1:0];

  // ---- D3 of last cycle's D2, from the record: per entry ------------------
  // pd: allocated last cycle (its line, valid and state are written now);
  // pdm: merged into last cycle (its count and next list word now). The
  // entry sent now (snt), turned sent now.
  logic [NE-1:0] pd_cc05h, pdm_cc05h, xhit_cc05h, fhit_cc04h, shit_cc05h;
  always_comb begin
    for (int e = 0; e < NE; e++) begin
      pd_cc05h[e]   = rcal_q_cc05h && rcio_q_cc05h[e];
      pdm_cc05h[e]  = rcmg_q_cc05h && rcmt_q_cc05h[e];
      xhit_cc05h[e] = xv_q_cc05h && xid_q_cc05h[WEB-1:0] == WEB'(e);
      fhit_cc04h[e] = fv_q_cc04h && fmine_cc04h && fe_cc04h == WEB'(e);
      shit_cc05h[e] = snt_cc05h && ofh_q_cc05h[e];
    end
  end

  // ---- D2: compare and decide (stage 05: it reads the state) -------------
  // The line compare against the written entries (hent), and against last
  // cycle's allocation, whose entry is written only now.
  logic [NE-1:0] hent_cc05h, hit_cc05h;
  logic          hrec_cc05h;
  always_comb begin
    for (int e = 0; e < NE; e++)
      // An entry being written is free (mshr_pending_free): no !pd term.
      hent_cc05h[e] = ev_q_cc05h[e] && epa_q_cc05h[e] == qpa_cc04h;
    hrec_cc05h = rcalh_q_cc05h && rcpa_q_cc05h == qpa_cc04h;
    hit_cc05h  = hent_cc05h | (rcio_q_cc05h & {NE{hrec_cc05h}});
  end

  // Filled and full read the written entries (one allocated last cycle is
  // unsent with one request); the count takes last cycle's merge.
  logic          any_cc05h, fld_cc05h, ful_cc05h, ord_cc05h;
  logic          mg_cc05h, al_cc05h, wt_cc05h;
  logic [1:0]    why_cc05h;
  logic [NE-1:0] efl_cc05h, efu_cc05h, eflu_cc05h;
  always_comb begin
    for (int e = 0; e < NE; e++) begin
      // An entry its fill reads now is filled: a merge now would miss the
      // list the fill takes.
      efl_cc05h[e] = est_q_cc05h[e] == ST_FILLED || fhit_cc04h[e];
      efu_cc05h[e] = ecnt_q_cc05h[e] == WLC'(LD) ||
                     (pdm_cc05h[e] && ecnt_q_cc05h[e] == WLC'(LD - 1));
      eflu_cc05h[e] = efl_cc05h[e] || efu_cc05h[e];
    end
    any_cc05h = |hent_cc05h || hrec_cc05h;
    fld_cc05h = |(hent_cc05h & efl_cc05h);
    ful_cc05h = |(hent_cc05h & efu_cc05h);
    // A new miss behind the bank's wait of last cycle waits too: the bank
    // holds a waiter dcu_bctl learns of only now (bank order).
    ord_cc05h = !rl_q_cc04h && owi_q_cc05h;
    mg_cc05h  = pq_cc04h && any_cc05h && !fld_cc05h && !ful_cc05h && !ord_cc05h;
    al_cc05h  = pq_cc04h && !any_cc05h && !ord_cc05h && nfv_q_cc05h;
    // The same, written for depth: with no entry hit, filled and full are
    // false; a record hit is neither (unsent, one request).
    wt_cc05h  = pq_cc04h && (ord_cc05h || |(hent_cc05h & eflu_cc05h) ||
                (!nfv_q_cc05h && !any_cc05h));
    why_cc05h = ord_cc05h ? 2'd3 : fld_cc05h ? 2'd2 : ful_cc05h ? 2'd1 : 2'd0;
  end

  // ---- The MLC offer -----------------------------------------------------
  // Unsent: a written entry, less the one sent now (it turns sent only
  // now), and last cycle's allocation unless it went straight and was sent.
  // The head for next cycle: the oldest written one (the age matrix), else
  // the record, else this D2's allocation (each younger than the last).
  logic [NE-1:0]  un_cc05h, uo_cc05h, usv_cc05h;
  logic           fne_cc05h, rcq_cc05h;
  always_comb begin
    for (int e = 0; e < NE; e++) usv_cc05h[e] = est_q_cc05h[e] == ST_UNSENT;
    for (int e = 0; e < NE; e++)
      un_cc05h[e] = ev_q_cc05h[e] && usv_cc05h[e] && !shit_cc05h[e];
    for (int e = 0; e < NE; e++) begin
      uo_cc05h[e] = un_cc05h[e];
      for (int f = 0; f < NE; f++)
        if (f < e && un_cc05h[f] && old_q_cc05h[f][e]) uo_cc05h[e] = 1'b0;
        else if (f > e && un_cc05h[f] && !old_q_cc05h[e][f]) uo_cc05h[e] = 1'b0;
    end
    fne_cc05h = |un_cc05h;
    rcq_cc05h = rcal_q_cc05h && !(|(shit_cc05h & rcio_q_cc05h));
  end
  logic           hvn_cc05h, hrcn_cc05h;
  logic [NE-1:0]  hohn_cc05h;
  logic [WTS-1:0] hstn_cc05h, ustp_cc05h;
  always_comb begin
    ustp_cc05h = '0;
    for (int e = 0; e < NE; e++)
      if (uo_cc05h[e]) ustp_cc05h = ustp_cc05h | estp_q_cc05h[e];
    hvn_cc05h  = fne_cc05h || rcq_cc05h || al_cc05h;
    hrcn_cc05h = !fne_cc05h && !rcq_cc05h;
    hohn_cc05h = fne_cc05h ? uo_cc05h : rcq_cc05h ? rcio_q_cc05h : nfoh_q_cc05h;
    hstn_cc05h = fne_cc05h ? ustp_cc05h : rcq_cc05h ? rcst_q_cc05h : tnow_q_cc05h;
  end
  // The head's flops: the valid every cycle; the rest while one is or may
  // be offered (a request at D2, or an entry or record unsent).
  logic hd_en_cc05h;
  assign hd_en_cc05h = rst_r01h || pres_cc04h || hvi_q_cc05h || rcal_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) begin
      hv_q_cc05h  <= 1'b0;
      hvi_q_cc05h <= 1'b0;
    end else begin
      hv_q_cc05h  <= hvn_cc05h;
      hvi_q_cc05h <= hvn_cc05h;
    end
  end
  always_ff @(posedge dcu_core_clk) begin
    if (hd_en_cc05h) begin
      hoh_q_cc05h  <= hohn_cc05h;
      hrc_q_cc05h  <= hrcn_cc05h;
      hstp_q_cc05h <= hstn_cc05h;
    end
  end
  assign hv_cc05h   = hv_q_cc05h;
  assign hstp_cc05h = hstp_q_cc05h;
  // Straight: this D2 allocates and nothing older is unsent.
  assign sv_cc05h = al_cc05h && !hvi_q_cc05h;

  // What this bank offered (the head, or this D2's allocation), for the
  // cycle on: its id, and its payload from the entry (written by now), the
  // record (the head was last cycle's allocation) or this D2's request.
  logic            of_en_cc05h;
  logic [NE-1:0]   ofhn_cc05h;
  logic [WEB-1:0]  pidn_cc05h;
  logic [WL-1:0]   ppan_cc05h, hpa_cc05h;
  logic [WC-1:0]   pcon_cc05h, hco_cc05h;
  always_comb begin
    hpa_cc05h = '0;
    hco_cc05h = '0;
    for (int e = 0; e < NE; e++)
      if (hoh_q_cc05h[e]) begin
        hpa_cc05h = hpa_cc05h | epa_q_cc05h[e];
        hco_cc05h = hco_cc05h | ecoh_q_cc05h[e];
      end
    ofhn_cc05h = hvi_q_cc05h ? hoh_q_cc05h : nfoh_q_cc05h;
    pidn_cc05h = '0;
    for (int e = 0; e < NE; e++)
      if (ofhn_cc05h[e]) pidn_cc05h = pidn_cc05h | WEB'(e);
    ppan_cc05h = !hvi_q_cc05h ? qpa_cc04h : hrc_q_cc05h ? rcpa_q_cc05h : hpa_cc05h;
    pcon_cc05h = !hvi_q_cc05h ? coh_of(qop_cc04h)
               : hrc_q_cc05h ? coh_of(rcop_q_cc05h) : hco_cc05h;
  end
  // The head changes only when it is sent or a head appears (an allocation
  // is younger than every unsent entry; a record turned entry keeps its id
  // and payload): the flops take a new head the cycle after either (hnw_q,
  // from snt, a flop's enable never an input's, CG-5), and this D2's
  // request while no head is held.
  logic hnw_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) hnw_q_cc05h <= 1'b0;
    else          hnw_q_cc05h <= hvn_cc05h && (!hvi_q_cc05h || snt_cc05h);
  end
  assign of_en_cc05h = rst_r01h || (pres_cc04h && !hvi_q_cc05h) || hnw_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) ofv_q_cc05h <= 1'b0;
    else          ofv_q_cc05h <= hvi_q_cc05h || al_cc05h;
  end
  always_ff @(posedge dcu_core_clk) begin
    if (of_en_cc05h) begin
      ofh_q_cc05h  <= rst_r01h ? '0 : ofhn_cc05h;
      pid_q_cc05h  <= pidn_cc05h;
      ppa_q_cc05h  <= ppan_cc05h;
      pcoh_q_cc05h <= pcon_cc05h;
    end
  end
  assign pid_cc05h  = pid_q_cc05h;
  assign ppa_cc05h  = ppa_q_cc05h;
  assign pcoh_cc05h = pcoh_q_cc05h;

  // ---- The entries, written at D3 from the record (one clock gate) --------
  // Valid, state and count through masks (an AND-OR, not a per-field hold,
  // which synthesis would split into gates of 1 to 3 flops). An entry sent
  // straight is allocated and sent in one write. A send can come only when
  // this bank offered last cycle (ofv_q: snt is an input, CG-5).
  logic ctl_en_cc05h;
  assign ctl_en_cc05h = rst_r01h || rcal_q_cc05h || rcmg_q_cc05h || ofv_q_cc05h ||
                        fv_q_cc04h || xv_q_cc05h;
  for (genvar e = 0; e < NE; e++) begin : g_e
    logic           mvm_cc05h, dv_cc05h;
    logic [1:0]     ms_cc05h, ds_cc05h;
    logic [WLC-1:0] mc_cc05h, dc_cc05h;
    assign mvm_cc05h  = rst_r01h || pd_cc05h[e] || xhit_cc05h[e];
    assign dv_cc05h   = !rst_r01h && pd_cc05h[e];
    assign ms_cc05h   = {2{rst_r01h || pd_cc05h[e] || shit_cc05h[e] || fhit_cc04h[e]}};
    assign ds_cc05h   = rst_r01h ? ST_UNSENT : shit_cc05h[e] ? ST_SENT
                      : pd_cc05h[e] ? ST_UNSENT : ST_FILLED;
    assign mc_cc05h   = {WLC{rst_r01h || pd_cc05h[e] || pdm_cc05h[e] || xhit_cc05h[e]}};
    assign dc_cc05h   = (rst_r01h || xhit_cc05h[e]) ? WLC'(0)
                      : pd_cc05h[e] ? WLC'(1) : ecnt_q_cc05h[e] + WLC'(1);
    always_ff @(posedge dcu_core_clk) begin
      if (ctl_en_cc05h) begin
        ev_q_cc05h[e]   <= (ev_q_cc05h[e] && !mvm_cc05h) || (dv_cc05h && mvm_cc05h);
        est_q_cc05h[e]  <= (est_q_cc05h[e] & ~ms_cc05h) | (ds_cc05h & ms_cc05h);
        ecnt_q_cc05h[e] <= (ecnt_q_cc05h[e] & ~mc_cc05h) | (dc_cc05h & mc_cc05h);
      end
    end

    // A merge's list word: position k is the count before it.
    for (genvar k = 1; k < LD; k++) begin : g_k
      logic li_en_cc05h;
      assign li_en_cc05h = pdm_cc05h[e] && ecnt_q_cc05h[e] == WLC'(k);
      always_ff @(posedge dcu_core_clk) begin
        if (li_en_cc05h) elist_q_cc05h[e][k] <= rcit_q_cc05h;
      end
    end

    // An allocation's line, fold, coh_op, stamp and first list word.
    logic wd_en_cc05h;
    assign wd_en_cc05h = pd_cc05h[e];
    always_ff @(posedge dcu_core_clk) begin
      if (wd_en_cc05h) begin
        epa_q_cc05h[e]      <= rcpa_q_cc05h;
        efold_q_cc05h[e]    <= rcfold_q_cc05h;
        ecoh_q_cc05h[e]     <= coh_of(rcop_q_cc05h);
        estp_q_cc05h[e]     <= rcst_q_cc05h;
        elist_q_cc05h[e][0] <= rcit_q_cc05h;
      end
    end
  end

  // ---- The next free id ---------------------------------------------------
  // The bank holds an offer, the id it allocates; any request present takes
  // it whatever it did, a hit too. It, or an empty offer, takes last
  // cycle's pick. The
  // pick is made a cycle ahead from this module's flops alone: the lowest
  // free entry (one freed now counts) less the offer, the pick and the offer
  // taken last cycle (an allocation's entry is valid only a cycle on); so an
  // id freed, or left unused, is offered two cycles on.
  logic [NE-1:0] av_cc05h, pn_cc05h, l1_cc05h;
  logic          pnv_cc05h;
  always_comb begin
    for (int e = 0; e < NE; e++)
      av_cc05h[e] = ((!ev_q_cc05h[e] && !ua_q_cc05h[e]) || xhit_cc05h[e]) &&
                    !nfoh_q_cc05h[e] && !pk_q_cc05h[e];
    // l1[e]: one free below e (a sum of products: a tree, not a chain).
    for (int e = 0; e < NE; e++) begin
      l1_cc05h[e] = 1'b0;
      for (int i = 0; i < e; i++) l1_cc05h[e] = l1_cc05h[e] || av_cc05h[i];
    end
    pn_cc05h  = av_cc05h & ~l1_cc05h;
    pnv_cc05h = |av_cc05h;
  end
  logic          qf_cc05h;
  logic [NE-1:0] nfoh_cc05h, uan_cc05h;
  logic          nfvn_cc05h;
  always_comb begin
    // Any request present takes the offer, a hit too (the enable is from
    // this module's flops alone, CG-5); one it does not allocate is free
    // again and picked two cycles on.
    qf_cc05h   = pres_cc04h || !nfv_q_cc05h;
    nfoh_cc05h = qf_cc05h ? pk_q_cc05h : nfoh_q_cc05h;
    nfvn_cc05h = qf_cc05h ? |pk_q_cc05h : nfv_q_cc05h;
    uan_cc05h  = nfoh_q_cc05h & {NE{pq_cc04h}};
    // At reset every entry is free: the lowest is offered, the next picked.
    if (rst_r01h) begin
      uan_cc05h  = '0;
      nfoh_cc05h = NE'(1);
      nfvn_cc05h = 1'b1;
    end
  end
  logic nf_en_cc05h;
  assign nf_en_cc05h = rst_r01h || pres_cc04h || xv_q_cc05h || (pkv_q_cc05h && !nfv_q_cc05h);
  always_ff @(posedge dcu_core_clk) begin
    if (nf_en_cc05h) begin
      nfoh_q_cc05h <= nfoh_cc05h;
      pk_q_cc05h   <= rst_r01h ? NE'(2) : pn_cc05h;
      nfv_q_cc05h  <= nfvn_cc05h;
      pkv_q_cc05h  <= rst_r01h || pnv_cc05h;
    end
  end
  logic ua_en_cc05h;
  assign ua_en_cc05h = rst_r01h || pres_cc04h || |ua_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (ua_en_cc05h) ua_q_cc05h <= uan_cc05h;
  end

  // ---- The record ---------------------------------------------------------
  // The decisions share the outcome's gate (oc_en_cc05h, below); the id,
  // hit entry, payload and stamp are under the request's lead.
  logic rcp_en_cc04h;
  assign rcp_en_cc04h = pres_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (rcp_en_cc04h) begin
      rcio_q_cc05h   <= nfoh_q_cc05h;
      rcmt_q_cc05h   <= hit_cc05h;
      rcpa_q_cc05h   <= qpa_cc04h;
      rcfold_q_cc05h <= qfold_cc04h;
      rcop_q_cc05h   <= qop_cc04h;
      rcit_q_cc05h   <= qit_cc04h;
      rcst_q_cc05h   <= tnow_q_cc05h;
    end
  end

  // ---- The send order ----------------------------------------------------
  // At D3 an allocated entry is younger than every other: a bit is written
  // when either of its entries is allocated (one gate, masks).
  logic od_en_cc05h;
  assign od_en_cc05h = rcal_q_cc05h;
  for (genvar i = 0; i < NE; i++) begin : g_od
    logic [NE-1:0] om_cc05h, odn_cc05h;
    always_comb
      for (int j = 0; j < NE; j++) begin
        om_cc05h[j]  = j > i && (pd_cc05h[i] || pd_cc05h[j]);
        odn_cc05h[j] = !pd_cc05h[i];
      end
    always_ff @(posedge dcu_core_clk) begin
      if (od_en_cc05h) old_q_cc05h[i] <= (old_q_cc05h[i] & ~om_cc05h) | (odn_cc05h & om_cc05h);
    end
  end

  // ---- D3: the outcome ---------------------------------------------------
  logic oc_en_cc05h;
  assign oc_en_cc05h = rst_r01h || pres_cc04h || oany_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (oc_en_cc05h) begin
      ov_q_cc05h    <= !rst_r01h && pq_cc04h;
      ow_q_cc05h    <= !rst_r01h && wt_cc05h;
      owi_q_cc05h   <= !rst_r01h && wt_cc05h;
      oy_q_cc05h    <= why_cc05h;
      oany_q_cc05h  <= !rst_r01h && pq_cc04h;
      rcal_q_cc05h  <= !rst_r01h && al_cc05h;
      rcalh_q_cc05h <= !rst_r01h && al_cc05h;
      rcmg_q_cc05h  <= !rst_r01h && mg_cc05h;
    end
  end
  assign ov_cc05h    = ov_q_cc05h;
  assign owait_cc05h = ow_q_cc05h;
  assign owhy_cc05h  = oy_q_cc05h;

  // ---- The free's id ------------------------------------------------------
  // An input cannot enable its own capture (CG-5), so it is captured whenever
  // an entry is filled (own flops), the only time one can be freed.
  logic xid_en_cc05h;
  always_comb begin
    xid_en_cc05h = 1'b0;
    for (int e = 0; e < NE; e++)
      xid_en_cc05h = xid_en_cc05h || (ev_q_cc05h[e] && est_q_cc05h[e] == ST_FILLED);
  end
  always_ff @(posedge dcu_core_clk) begin
    if (xid_en_cc05h) xid_q_cc05h <= xid_cc04h[WEB-1:0];
  end

  // ---- F: the fill's entry read ------------------------------------------
  // Zero unless the fill is this bank's, so dcu_fill ORs the banks' reads.
  logic [WL-1:0]     fpa_q_cc05h;
  logic [WF-1:0]     ffold_q_cc05h;
  logic [WC-1:0]     fcoh_q_cc05h;
  logic [WLC-1:0]    fcnt_q_cc05h;
  logic [LD*WLE-1:0] flist_q_cc05h;
  logic              fr_en_cc04h;
  logic [WLE-1:0]    mitx_cc04h;
  assign fr_en_cc04h = fv_q_cc04h;
  assign mitx_cc04h  = rcit_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (fr_en_cc04h) begin
      fpa_q_cc05h   <= fmine_cc04h ? epa_q_cc05h[fe_cc04h] : '0;
      ffold_q_cc05h <= fmine_cc04h ? efold_q_cc05h[fe_cc04h] : '0;
      fcoh_q_cc05h  <= fmine_cc04h ? ecoh_q_cc05h[fe_cc04h] : '0;
      fcnt_q_cc05h  <= fmine_cc04h ? ecnt_q_cc05h[fe_cc04h] + WLC'(pdm_cc05h[fe_cc04h]) : '0;
      for (int k = 0; k < LD; k++)
        flist_q_cc05h[k*WLE +: WLE] <= !fmine_cc04h ? '0 :
            (pdm_cc05h[fe_cc04h] && ecnt_q_cc05h[fe_cc04h] == WLC'(k))
            ? mitx_cc04h : elist_q_cc05h[fe_cc04h][k];
    end
  end
  // The write request: the lead from the same read, the payload a cycle on.
  logic              flv_q_cc05h;
  logic [NBK-1:0]    fbk_q_cc05h;
  logic [WL-1:0]     fwpa_q_cc06h;
  logic [WF-1:0]     fwfold_q_cc06h;
  always_ff @(posedge dcu_core_clk) begin
    flv_q_cc05h <= !rst_r01h && fv_q_cc04h && fmine_cc04h;
  end
  always_ff @(posedge dcu_core_clk) begin
    if (fr_en_cc04h) fbk_q_cc05h <= fmine_cc04h ? NBK'(1) << BK : '0;
  end
  logic fw_en_cc05h;
  assign fw_en_cc05h = flv_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (fw_en_cc05h) begin
      fwpa_q_cc06h   <= fpa_q_cc05h;
      fwfold_q_cc06h <= ffold_q_cc05h;
    end
  end
  assign flv_cc05h    = flv_q_cc05h;
  assign fbk_cc05h    = fbk_q_cc05h;
  assign fwpa_cc06h   = fwpa_q_cc06h;
  assign fwfold_cc06h = fwfold_q_cc06h;
  assign fpa_cc05h    = fpa_q_cc05h;
  assign ffold_cc05h  = ffold_q_cc05h;
  assign fcoh_cc05h   = fcoh_q_cc05h;
  assign fcnt_cc05h   = fcnt_q_cc05h;
  assign flist_cc05h  = flist_q_cc05h;

  // ---- CHECKs -------------------------------------------------------------
  // No two entries hold one line (an entry's line counts once written); one
  // live lookup a bank (MA-27) and it is the bank's own; dcu_bctl's slot is
  // the one staged; a retry and a new miss never meet; dcu_mpick's retry
  // valid is the grant's; MLC answers only an id in flight and an entry
  // written; a send only of what was offered.
  logic dup_cc05h;
  always_comb begin
    dup_cc05h = 1'b0;
    for (int i = 0; i < NE; i++)
      for (int j = i + 1; j < NE; j++)
        dup_cc05h = dup_cc05h || (ev_q_cc05h[i] && ev_q_cc05h[j] && !pd_cc05h[i] &&
                                  !pd_cc05h[j] && epa_q_cc05h[i] == epa_q_cc05h[j]);
  end
  `CCV_ASSERT(mshr_one_line, !dup_cc05h)
  `CCV_ASSERT(mshr_one_lookup, $onehot0(lbs_cc03h))
  `CCV_ASSERT(mshr_own_bank, !mv_cc04h || sp_pa_q_cc04h[WB-1:0] == BKW)
  `CCV_ASSERT(mshr_own_slot, !mv_cc04h || mslot_cc04h == sp_slot_q_cc04h)
  `CCV_ASSERT(mshr_mv_lead, !mv_cc04h || sl_q_cc04h)
  `CCV_ASSERT(mshr_one_request, !(rl_q_cc04h && mv_cc04h))
  `CCV_ASSERT(mshr_retry_lead, rv_cc04h == rl_q_cc04h)
  `CCV_ASSERT(mshr_retry_bank, !rl_q_cc04h || rpa_cc04h[WB-1:0] == BKW)
  `CCV_ASSERT(mshr_fill_in_flight, !(fv_q_cc04h && fmine_cc04h) ||
              (ev_q_cc05h[fe_cc04h] && !pd_cc05h[fe_cc04h] &&
               est_q_cc05h[fe_cc04h] == ST_SENT))
  `CCV_ASSERT(mshr_free_filled, !xv_q_cc05h ||
              (ev_q_cc05h[xid_q_cc05h] && est_q_cc05h[xid_q_cc05h] == ST_FILLED))
  `CCV_ASSERT(mshr_pending_free, !(|(pd_cc05h & ev_q_cc05h)))
  `CCV_ASSERT(mshr_sent_offered, !snt_cc05h || ofv_q_cc05h)
  `CCV_ASSERT(mshr_sent_unsent, !snt_cc05h || |(ofh_q_cc05h & (pd_cc05h |
              (ev_q_cc05h & usv_cc05h))))

endmodule
`undef CCV_CLK
`undef CCV_RST
