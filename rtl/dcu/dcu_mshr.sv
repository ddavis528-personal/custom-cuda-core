//===-- dcu_mshr.sv - DCU miss buffers and the request to MLC --------------===//
//
// Spec: docs/design-snapshots/dcu-spec.md (live: CCV per-block architecture
//       specs, DCU tab, "MA's Phase 2", slice 2, part 1 (rev 104): "Miss
//       buffers (dcu_mshr)", "Allocation and merge, at D2", "The request to
//       MLC", the stage table's F row and the module partition's dcu_mshr
//       row). DI-34 (DI tab) records the implementation choices below.
//
// One instance. 16 entries, one per ccv_dcu_mlc_req req_id; an entry's index
// is its req_id. An entry holds valid, state (unsent, sent, filled), the
// coh_op it sends, the line's PA[47:7] (its bank and set are its low bits)
// and fold, and a merge list of up to 4 MIU requests in arrival order (each
// req_id, op, exclusive and part 3's store-data index).
//
// Requests come on five ports (DI-34 (1)): port 0 is the one retry a cycle
// of a bank's oldest miss-wait waiter, ports 1 to 4 a new miss
// from each ccv_miu_dcu_req slot (a bank's mv names its slot). A line is one
// bank and a bank names one request a cycle, so no two ports hold one line.
//
//   retry  (DI-35) at R each dcu_bctl offers its oldest waiter (valid and
//        a stamp of when it waited); the oldest offer is granted at R+1
//        (rgv/rgb, from flops; the bank granted at R is passed over at R+1);
//        the granted bank's payload, held in its flops, is captured here at
//        R+2, its D2. The bank offers again once it has read its outcome.
//   D1 = H+3  each slot's payload, from dcu_cap's flops, is staged here
//        under this module's own flop of the slot's valid: dcu_cap's copy is
//        the next lookup's by D2 when lookups come back to back.
//   D2 = H+4  each port's line is compared with the 16 entries. It merges
//        into its line's entry (unsent or sent, list not full), allocates the
//        id offered to its port, or waits (list full, filled not written,
//        no id; a slot's new miss behind its bank's waiter). Each port holds
//        an offer, picked a cycle ahead from this module's flops (DI-34 (2);
//        "The next free ids" below): a requesting port's offer is taken
//        whatever it did, so an id left unused is offered again two cycles
//        on. An allocation or a merge is written into its entry a cycle on
//        (D3: valid, state, count, line, fold, coh_op, list word), from this
//        module's record of the port, and D2 compares against those records
//        while they wait.
//   D3 = H+5  each bank's outcome (placed or waiting, and why) goes back to
//        dcu_bctl from flops. ccv_dcu_mlc_req's valid launches: the oldest
//        unsent entry (by an age matrix, then the records not yet written),
//        or, when none is unsent, the first allocating port's (sent
//        straight), if the channel holds a credit (counting last cycle's
//        send). A sent entry turns sent a cycle on.
//   H+6  its payload (req_id, PA, coh_op, core_id), from the entry, or, for
//        one sent straight, from its record.
//   F    a fill's req_id, on ccv_mlc_dcu_rsp's wires (arrival 0) under its
//        valid's flop a cycle ahead, reads its entry: the line, fold, kind
//        and merge list are flopped here for dcu_fill, and the entry turns
//        filled. A merge in that cycle waits (filled).
//   free dcu_fill names an entry whose line is written and whose answers
//        have all left; it is free a cycle on.
//
// Not here yet: part 2's writeback (an entry's turn into a writeback at W,
// writebacks first in the request order, the request's data), part 3's
// AcquirePerm for a full-line store (the store's mask). The retry's payload
// lives in dcu_bctl's queue entries (DI-34 (3)).
//
// Stage tags: the entries, the records, the age matrix, the credit count,
// the next ids and the outcome flops are one stage, 05, the block's state
// (CCV-L23's own-stage state), and so is the D2 logic that reads them; what
// reads only the ports and the staged slots is 04.
//
// The reference is the DCU model's miss buffers (sim/dcu/dcu_core.cpp,
// missOrWait(), startMiss() and mlcReq()), and test/dcu/mshr_tb.cpp holds
// this module to a value model of them with this module's id choice.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK dcu_core_clk
`define CCV_RST rst_r01h
module dcu_mshr #(
  parameter  int SLOTS = 4,                                          // ccv_miu_dcu_req slots
  parameter  int NBK   = ccv_params_pkg::CCV_DCU_BANKS,              // 8
  parameter  int WI    = ccv_prov_pkg::CCV_P_W_REQ_MIU_DCU,          // MIU req_id, 6
  parameter  int WA    = ccv_prov_pkg::CCV_P_W_PA,                   // PA, 48
  parameter  int WO    = $clog2(ccv_prov_pkg::CCV_P_LINE_BYTES),     // line offset, 7
  parameter  int WF    = ccv_prov_pkg::CCV_DCU_WAYPRED_BITS,         // fold, 4
  parameter  int WC    = ccv_prelim_pkg::CCV_L_W_COH_OP,             // coh_op, 4
  parameter  int WE    = ccv_prov_pkg::CCV_P_W_REQ_DCU_MLC,          // entry id, 7
  parameter  int LD    = 4,                                          // merge list
  parameter  int WST   = 4,                                          // store-data index
  parameter  int NCR   = ccv_params_pkg::CCV_CREDIT_DEPTH,           // req credits, 4
  parameter  int WCID  = ccv_params_pkg::CCV_W_CORE_ID,              // 2
  parameter  int CID   = ccv_prov_pkg::CCV_P_CORE_ID,
  parameter  int WTS   = 10,                                         // retry stamp (DI-35)
  localparam int NE    = ccv_params_pkg::CCV_DCU_MSHR_PER_BANK,      // 16 (one bank's, until MA-34's split)
  localparam int WL    = WA - WO,                                    // line, 41
  localparam int WSL   = SLOTS > 1 ? $clog2(SLOTS) : 1,              // 2
  localparam int WB    = NBK > 1 ? $clog2(NBK) : 1,                  // 3
  localparam int WLC   = $clog2(LD + 1),                             // list count, 3
  localparam int WCR   = $clog2(NCR + 1),                            // 3
  localparam int NP    = SLOTS + 1,                                  // request ports, 5
  localparam int WP    = $clog2(NP + 1),                             // a port or a count of them, 3
  localparam int NNF   = NP,                                         // next free ids
  localparam int WLE   = WI + 2 + 1 + WST                            // list item, 13
) (
  input  logic                   dcu_core_clk,
  input  logic                   rst_n,
  // D0 and D1: each slot's lookup, from dcu_cap.
  input  logic [SLOTS-1:0]       v_cc02h,
  input  logic [SLOTS*WI-1:0]    rid_cc03h,
  input  logic [SLOTS*WL-1:0]    pa_cc03h,
  input  logic [SLOTS*WF-1:0]    fold_cc03h,
  input  logic [SLOTS*WC-1:0]    coh_cc03h,
  input  logic [SLOTS-1:0]       excl_cc03h,
  // D2: each bank's lookup, from dcu_bctl's flops (its slot names the
  // payload; none while the bank holds a miss-wait waiter), and its tag
  // result from dcu_btag's: a miss is dv && !hit.
  input  logic [NBK-1:0]         dv_cc04h,
  input  logic [NBK-1:0]         hit_cc04h,
  input  logic [NBK*WSL-1:0]     mslot_cc04h,
  // The retry (DI-35): each bank's offer of its oldest miss-wait waiter
  // (valid and stamp) from dcu_bctl's flops; the oldest is granted a cycle
  // on, and the granted bank's payload, held in its flops, is captured here
  // a cycle later still, for D2.
  input  logic [NBK-1:0]         rov_cc02h,
  input  logic [NBK*WTS-1:0]     rstp_cc02h,
  output logic                   rgv_cc03h,
  output logic [WB-1:0]          rgb_cc03h,
  input  logic [NBK*WL-1:0]      rpa_cc03h,
  input  logic [NBK*WI-1:0]      rrid_cc03h,
  input  logic [NBK*2-1:0]       rop_cc03h,      // 0 read, 1 atomic, 2 store
  input  logic [NBK-1:0]         rexcl_cc03h,
  input  logic [NBK*WF-1:0]      rfold_cc03h,
  input  logic [NBK*WST-1:0]     rsti_cc03h,
  // D3: each bank's outcome: placed (merged or allocated) or waiting, why.
  output logic [NBK-1:0]         ov_cc05h,
  output logic [NBK-1:0]         owait_cc05h,
  output logic [NBK*2-1:0]       owhy_cc05h,     // 0 no entry, 1 list full, 2 filled, 3 bank order
  // ccv_dcu_mlc_req: a credit back from MLC, the valid, then the payload.
  input  logic                   mcr_cc04h,
  output logic                   mv_cc05h,
  output logic [WE-1:0]          mrid_cc06h,
  output logic [WA-1:0]          mpa_cc06h,
  output logic [WC-1:0]          mcoh_cc06h,
  output logic [WCID-1:0]        mcid_cc06h,
  // A fill: its valid's flop a cycle ahead (F-1), its req_id at F.
  input  logic                   fv_cc03h,
  input  logic [WE-1:0]          frid_cc04h,
  // F+1: its entry, for dcu_fill.
  output logic [WL-1:0]          fpa_cc05h,
  output logic [WF-1:0]          ffold_cc05h,
  output logic [WC-1:0]          fcoh_cc05h,
  output logic [WLC-1:0]         fcnt_cc05h,
  output logic [LD*WLE-1:0]      flist_cc05h,
  // The fill's bank write request (DI-39, MA rev 177): its lead at F+1 from
  // the F read (the valid and the bank, one hot; the bank holds its value
  // only under the valid), its line and fold at F+2 (dcu_fill's buffer and
  // ownership beside them).
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

  // A load reads shared; a store or an atomic acquires the line with its
  // data (part 3 adds AcquirePerm for a full-line store).
  function automatic logic [WC-1:0] coh_of(input logic [1:0] op);
    coh_of = op == 2'd0 ? WC'(0) : WC'(2);
  endfunction

  // ---- D1: each slot's payload staged under its valid's flop -------------
  // The valids, captured every cycle (interface leads: CG-5, waived "lead").
  logic [SLOTS-1:0] lv_q_cc03h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) lv_q_cc03h <= '0;
    else          lv_q_cc03h <= v_cc02h;
  end
  logic [SLOTS-1:0] lv_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) lv_q_cc04h <= '0;
    else          lv_q_cc04h <= lv_q_cc03h;
  end
  logic [WI-1:0]  sp_rid_q_cc04h  [SLOTS];
  logic [WL-1:0]  sp_pa_q_cc04h   [SLOTS];
  logic [WF-1:0]  sp_fold_q_cc04h [SLOTS];
  logic [1:0]     sp_op_q_cc04h   [SLOTS];
  logic           sp_excl_q_cc04h [SLOTS];
  for (genvar s = 0; s < SLOTS; s++) begin : g_sp
    logic          sp_en_cc03h;
    logic [WC-1:0] cohs_cc03h;
    logic [1:0]    op_cc03h;
    assign sp_en_cc03h = lv_q_cc03h[s];
    assign cohs_cc03h  = coh_cc03h[s*WC +: WC];
    // MIU's coh_op as the model decodes it (dcu_block.cpp, decode()).
    assign op_cc03h = cohs_cc03h == WC'(0) ? 2'd0 : cohs_cc03h == WC'(2) ? 2'd1 : 2'd2;
    always_ff @(posedge dcu_core_clk) begin
      if (sp_en_cc03h) begin
        sp_rid_q_cc04h[s]  <= rid_cc03h[s*WI +: WI];
        sp_pa_q_cc04h[s]   <= pa_cc03h[s*WL +: WL];
        sp_fold_q_cc04h[s] <= fold_cc03h[s*WF +: WF];
        sp_op_q_cc04h[s]   <= op_cc03h;
        sp_excl_q_cc04h[s] <= excl_cc03h[s];
      end
    end
  end

  // Each bank's new miss at D2.
  logic [NBK-1:0] mv_cc04h;
  assign mv_cc04h = dv_cc04h & ~hit_cc04h;

  // ---- The retry's pick (DI-35) ------------------------------------------
  // The oldest offer by stamp, modulo 2^WTS (a stamp never ages past half
  // of it: a waiter that waits again is stamped anew), ties to the lowest
  // bank. The bank granted last cycle still offers (it learns of its grant
  // only now) and is passed over.
  logic [NBK-1:0] rok_cc02h, rwin_cc02h;
  logic           old_cc02h [NBK][NBK];       // [i][j]: i's stamp strictly older than j's
  logic           gvn_cc02h;
  logic [WB-1:0]  gbn_cc02h;
  (* keep *) logic           gm_q_cc02h, gv_q_cc03h, rgv_q_cc03h;
  (* keep *) logic [WB-1:0]  gmb_q_cc02h, gb_q_cc03h, rgb_q_cc03h;
  always_comb begin
    for (int i = 0; i < NBK; i++)
      for (int j = 0; j < NBK; j++) begin
        logic [WTS-1:0] d;
        d = rstp_cc02h[j*WTS +: WTS] - rstp_cc02h[i*WTS +: WTS];
        old_cc02h[i][j] = |d && !d[WTS-1];
      end
    for (int i = 0; i < NBK; i++)
      rok_cc02h[i] = rov_cc02h[i] && !(gm_q_cc02h && gmb_q_cc02h == WB'(i));
    for (int i = 0; i < NBK; i++) begin
      rwin_cc02h[i] = rok_cc02h[i];
      for (int j = 0; j < NBK; j++)
        if (j < i && rok_cc02h[j] && !old_cc02h[i][j]) rwin_cc02h[i] = 1'b0;
        else if (j > i && rok_cc02h[j] && old_cc02h[j][i]) rwin_cc02h[i] = 1'b0;
    end
    gvn_cc02h = |rok_cc02h;
    gbn_cc02h = '0;
    for (int i = 0; i < NBK; i++)
      if (rwin_cc02h[i]) gbn_cc02h = gbn_cc02h | WB'(i);
  end
  // The grant, every cycle (from offers, which are inputs), in three
  // copies: the pick's own record of it (stage 02 state, read by the next
  // pick), the payload capture's, and the output's, kept apart so the
  // output's path is only its own.
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) begin
      gm_q_cc02h  <= 1'b0;
      gv_q_cc03h  <= 1'b0;
      rgv_q_cc03h <= 1'b0;
    end else begin
      gm_q_cc02h  <= gvn_cc02h;
      gv_q_cc03h  <= gvn_cc02h;
      rgv_q_cc03h <= gvn_cc02h;
    end
  end
  always_ff @(posedge dcu_core_clk) begin
    gmb_q_cc02h <= gbn_cc02h;
    gb_q_cc03h  <= gbn_cc02h;
    rgb_q_cc03h <= gbn_cc02h;
  end
  assign rgv_cc03h = rgv_q_cc03h;
  assign rgb_cc03h = rgb_q_cc03h;

  // The granted bank's payload, captured under the grant (D2's retry port).
  logic           rl_q_cc04h;
  logic [WL-1:0]  rpa_q_cc04h;
  logic [WI-1:0]  rrid_q_cc04h;
  logic [1:0]     rop_q_cc04h;
  logic           rexcl_q_cc04h;
  logic [WF-1:0]  rfold_q_cc04h;
  logic [WST-1:0] rsti_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) rl_q_cc04h <= 1'b0;
    else          rl_q_cc04h <= gv_q_cc03h;
  end
  logic rp_en_cc03h;
  assign rp_en_cc03h = gv_q_cc03h;
  always_ff @(posedge dcu_core_clk) begin
    if (rp_en_cc03h) begin
      rpa_q_cc04h   <= rpa_cc03h[gb_q_cc03h*WL +: WL];
      rrid_q_cc04h  <= rrid_cc03h[gb_q_cc03h*WI +: WI];
      rop_q_cc04h   <= rop_cc03h[gb_q_cc03h*2 +: 2];
      rexcl_q_cc04h <= rexcl_cc03h[gb_q_cc03h];
      rfold_q_cc04h <= rfold_cc03h[gb_q_cc03h*WF +: WF];
      rsti_q_cc04h  <= rsti_cc03h[gb_q_cc03h*WST +: WST];
    end
  end
  // A request may be present at D2: this module's own flops (CG-5).
  logic pres_cc04h;
  assign pres_cc04h = |lv_q_cc04h || rl_q_cc04h;

  // ---- D2's ports (stage 04: the ports and the staged slots) -------------
  logic [NP-1:0]  pq_cc04h;                   // a request on the port
  logic [WL-1:0]  qpa_cc04h   [NP];
  logic [WF-1:0]  qfold_cc04h [NP];
  logic [1:0]     qop_cc04h   [NP];
  logic [WLE-1:0] qit_cc04h   [NP];           // {req_id, op, exclusive, store-data index}
  logic [WB-1:0]  qbk_cc04h   [NP];
  logic [NBK-1:0] qbo_cc04h   [NP];           // the port's request, by bank
  always_comb begin
    pq_cc04h[0]    = rl_q_cc04h;
    qpa_cc04h[0]   = rpa_q_cc04h;
    qfold_cc04h[0] = rfold_q_cc04h;
    qop_cc04h[0]   = rop_q_cc04h;
    qit_cc04h[0]   = {rrid_q_cc04h, rop_q_cc04h, rexcl_q_cc04h, rsti_q_cc04h};
    for (int s = 0; s < SLOTS; s++) begin
      pq_cc04h[s+1] = 1'b0;
      for (int b = 0; b < NBK; b++)
        pq_cc04h[s+1] = pq_cc04h[s+1] || (mv_cc04h[b] && mslot_cc04h[b*WSL +: WSL] == WSL'(s));
      qpa_cc04h[s+1]   = sp_pa_q_cc04h[s];
      qfold_cc04h[s+1] = sp_fold_q_cc04h[s];
      qop_cc04h[s+1]   = sp_op_q_cc04h[s];
      qit_cc04h[s+1]   = {sp_rid_q_cc04h[s], sp_op_q_cc04h[s], sp_excl_q_cc04h[s], WST'(0)};
    end
    for (int p = 0; p < NP; p++) begin
      qbk_cc04h[p] = qpa_cc04h[p][WB-1:0];
      for (int b = 0; b < NBK; b++) qbo_cc04h[p][b] = pq_cc04h[p] && qbk_cc04h[p] == WB'(b);
    end
  end

  // ---- The state (stage 05) ----------------------------------------------
  logic [NE-1:0]  ev_q_cc05h;                 // valid
  logic [1:0]     est_q_cc05h  [NE];          // state
  logic [WLC-1:0] ecnt_q_cc05h [NE];          // list count
  logic [WL-1:0]  epa_q_cc05h  [NE];
  logic [WF-1:0]  efold_q_cc05h[NE];
  logic [WC-1:0]  ecoh_q_cc05h [NE];
  logic [WLE-1:0] elist_q_cc05h[NE][LD];

  // Each port's offered id (one-hot, zero when it has none).
  logic [NE-1:0]  nfoh_q_cc05h[NNF];
  logic [NNF-1:0] nfv_q_cc05h;
  // The picks that refill it, a cycle ahead (one-hot), and the offers the
  // requesting ports took last cycle.
  logic [NE-1:0]  pk_q_cc05h [NNF];
  logic           pkv_q_cc05h;                // a pick is made (the first)
  logic [NE-1:0]  ua_q_cc05h;

  // The records of last cycle's D2, written into the entries now (D3): per
  // port, whether it allocated, whether it waits to be queued, whether it
  // merged; its id, the entry its line hit (one-hot) and its payload.
  logic [NP-1:0]  rcal_q_cc05h, rcmg_q_cc05h;
  (* keep *) logic [NP-1:0] rcalh_q_cc05h;     // rcal's copy for D2's compares alone (fanout)
  logic [NE-1:0]  rcio_q_cc05h [NP];          // its id, one-hot
  logic [NE-1:0]  rcmt_q_cc05h [NP];
  logic [WL-1:0]  rcpa_q_cc05h  [NP];
  logic [WF-1:0]  rcfold_q_cc05h[NP];
  logic [1:0]     rcop_q_cc05h  [NP];
  logic [WLE-1:0] rcit_q_cc05h  [NP];

  // The send order: for each two entries, whether the lower is the older
  // (allocation order, then port order); the unsent entries go oldest first.
  logic [NE-1:0]  old_q_cc05h [NE];           // [i][j], i < j: i is the older
  logic [WCR-1:0] cr_q_cc05h;                 // ccv_dcu_mlc_req's credits

  // The last send, for the payload and the entry's state a cycle on.
  (* keep *) logic mv_q_cc05h;                // drives the output only
  (* keep *) logic mvi_q_cc05h;               // its copy, for the rest
  logic [NE-1:0]  soh_q_cc05h;                // the entry sent from the queue (one-hot)
  logic [NP-1:0]  sport_q_cc05h;              // or the port sent straight (one-hot)
  logic           stq_q_cc05h;                // the last send went straight

  // The outcome, and a copy of the waits for the bank order (an output's
  // register drives nothing else).
  logic [NBK-1:0]   ov_q_cc05h;
  (* keep *) logic [NBK-1:0] ow_q_cc05h;
  logic [NBK*2-1:0] oy_q_cc05h;
  (* keep *) logic [NBK-1:0] owi_q_cc05h;
  logic             oany_q_cc05h;

  // Captured every cycle: the credit pulse, the fill's lead and the free
  // (CG-5; "credit", a lead and a 1-flop event under the module's allowance).
  logic          crq_q_cc05h;
  logic          xv_q_cc05h;
  logic [WE-1:0] xid_q_cc05h;
  logic          fv_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) begin
      crq_q_cc05h <= 1'b0;
      xv_q_cc05h  <= 1'b0;
      fv_q_cc04h  <= 1'b0;
    end else begin
      crq_q_cc05h <= mcr_cc04h;
      xv_q_cc05h  <= xv_cc04h;
      fv_q_cc04h  <= fv_cc03h;
    end
  end

  // ---- D3 of last cycle's D2, from the records: per entry ----------------
  // pd: allocated last cycle (its line, valid and state are written now);
  // pdm: merged into last cycle (its count and next list word now), with
  // that word. A line is one port's a cycle, so an entry takes one merge.
  logic [NE-1:0]  pd_cc05h, pdm_cc05h, xhit_cc05h, fhit_cc04h;
  logic [WLE-1:0] mitx_cc05h [NE];
  always_comb begin
    for (int e = 0; e < NE; e++) begin
      pd_cc05h[e]   = 1'b0;
      pdm_cc05h[e]  = 1'b0;
      mitx_cc05h[e] = '0;
      for (int r = 0; r < NP; r++) begin
        pd_cc05h[e]  = pd_cc05h[e] || (rcal_q_cc05h[r] && rcio_q_cc05h[r][e]);
        pdm_cc05h[e] = pdm_cc05h[e] || (rcmg_q_cc05h[r] && rcmt_q_cc05h[r][e]);
        if (rcmg_q_cc05h[r] && rcmt_q_cc05h[r][e]) mitx_cc05h[e] = mitx_cc05h[e] | rcit_q_cc05h[r];
      end
      xhit_cc05h[e] = xv_q_cc05h && xid_q_cc05h == WE'(e);
      fhit_cc04h[e] = fv_q_cc04h && frid_cc04h == WE'(e);
    end
  end

  // ---- D2: compare and decide (stage 05: it reads the state) -------------
  // A port's id: its own offer (zero when it has none).
  logic [NP-1:0] rok_cc05h;
  logic [NE-1:0] aio_cc05h [NP];
  always_comb begin
    for (int p = 0; p < NP; p++) begin
      rok_cc05h[p] = nfv_q_cc05h[p];
      aio_cc05h[p] = nfoh_q_cc05h[p];
    end
  end

  // The line compare: each port against the written entries (hent), and
  // against last cycle's allocations, whose entries are written only now.
  logic [NE-1:0] hent_cc05h [NP];
  logic [NP-1:0] hrec_cc05h [NP];             // [p][r]: record r's allocation
  logic [NE-1:0] hit_cc05h  [NP];
  always_comb begin
    for (int p = 0; p < NP; p++) begin
      for (int e = 0; e < NE; e++)
        // An entry being written is free (mshr_pending_free): no !pd term.
        hent_cc05h[p][e] = ev_q_cc05h[e] && epa_q_cc05h[e] == qpa_cc04h[p];
      for (int r = 0; r < NP; r++)
        hrec_cc05h[p][r] = rcalh_q_cc05h[r] && rcpa_q_cc05h[r] == qpa_cc04h[p];
      hit_cc05h[p] = hent_cc05h[p];
      for (int r = 0; r < NP; r++)
        if (hrec_cc05h[p][r]) hit_cc05h[p] = hit_cc05h[p] | rcio_q_cc05h[r];
    end
  end

  // Filled and full read the written entries (one allocated last cycle is
  // unsent with one request); the count takes last cycle's merge.
  logic [NP-1:0] any_cc05h, fld_cc05h, ful_cc05h, ord_cc05h;
  logic [NP-1:0] mg_cc05h, al_cc05h, wt_cc05h;
  logic [1:0]    why_cc05h [NP];
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
    for (int p = 0; p < NP; p++) begin
      any_cc05h[p] = |hent_cc05h[p] || |hrec_cc05h[p];
      fld_cc05h[p] = |(hent_cc05h[p] & efl_cc05h);
      ful_cc05h[p] = |(hent_cc05h[p] & efu_cc05h);
      // A slot's new miss behind its bank's wait of last cycle waits too:
      // the bank holds a waiter dcu_bctl learns of only now (bank order).
      ord_cc05h[p] = p != 0 && owi_q_cc05h[qbk_cc04h[p]];
      mg_cc05h[p]  = pq_cc04h[p] && any_cc05h[p] && !fld_cc05h[p] && !ful_cc05h[p] && !ord_cc05h[p];
      al_cc05h[p]  = pq_cc04h[p] && !any_cc05h[p] && !ord_cc05h[p] && rok_cc05h[p];
      // The same, written for depth: with no entry hit, filled and full
      // are false; a record hit is neither (unsent, one request).
      wt_cc05h[p]  = pq_cc04h[p] && (ord_cc05h[p] || |(hent_cc05h[p] & eflu_cc05h) ||
                     (!rok_cc05h[p] && !any_cc05h[p]));
      why_cc05h[p] = ord_cc05h[p] ? 2'd3 : fld_cc05h[p] ? 2'd2 : ful_cc05h[p] ? 2'd1 : 2'd0;
    end
  end

  // ---- The request to MLC: which entry goes this cycle -------------------
  // The last send's id: its record's when it went straight.
  logic [WE-1:0] sidx_cc05h;
  logic [NE-1:0] sohx_cc05h;
  logic [NP-1:0] rcq_cc05h;                   // last cycle's allocations to queue
  logic [NE-1:0] sohm_cc05h;                  // soh_q, unless the send went straight
  always_comb begin
    sohm_cc05h = soh_q_cc05h & ~{NE{stq_q_cc05h}};
    sohx_cc05h = sohm_cc05h;
    for (int r = 0; r < NP; r++)
      if (sport_q_cc05h[r]) sohx_cc05h = sohx_cc05h | rcio_q_cc05h[r];
    sidx_cc05h = '0;
    for (int e = 0; e < NE; e++)
      if (sohx_cc05h[e]) sidx_cc05h = sidx_cc05h | WE'(e);
    rcq_cc05h  = rcal_q_cc05h & ~sport_q_cc05h;
  end
  logic          fne_cc05h, rqa_cc05h, une_cc05h, crok_cc05h;
  logic          snd_cc05h, srec_cc05h, str_cc05h;
  logic [NP-1:0] fa_cc05h;                    // the first allocating port (one-hot)
  logic [NP-1:0] frq_cc05h;                   // the first record to queue (one-hot)
  logic [NE-1:0] sio_cc05h;
  // An entry is unsent once written (D3), less the one whose valid launched
  // last cycle: it turns sent only now.
  logic [NE-1:0] un_cc05h, uo_cc05h, usv_cc05h;
  always_comb begin
    for (int e = 0; e < NE; e++) usv_cc05h[e] = est_q_cc05h[e] == ST_UNSENT;
    for (int e = 0; e < NE; e++)
      un_cc05h[e] = ev_q_cc05h[e] && usv_cc05h[e] &&
                    !(mvi_q_cc05h && sohx_cc05h[e]);
    for (int e = 0; e < NE; e++) begin
      uo_cc05h[e] = un_cc05h[e];
      for (int f = 0; f < NE; f++)
        if (f < e && un_cc05h[f] && old_q_cc05h[f][e]) uo_cc05h[e] = 1'b0;
        else if (f > e && un_cc05h[f] && !old_q_cc05h[e][f]) uo_cc05h[e] = 1'b0;
    end
  end
  always_comb begin
    fne_cc05h  = |un_cc05h;
    rqa_cc05h  = |rcq_cc05h;
    une_cc05h  = fne_cc05h || rqa_cc05h;
    // The count takes last cycle's send only now (mvi_q): a credit is left.
    crok_cc05h = cr_q_cc05h > WCR'(mvi_q_cc05h);
    fa_cc05h   = al_cc05h & ~(al_cc05h - NP'(1));
    frq_cc05h = rcq_cc05h & ~(rcq_cc05h - NP'(1));
    snd_cc05h  = crok_cc05h && (une_cc05h || |al_cc05h);
    srec_cc05h = crok_cc05h && !fne_cc05h && rqa_cc05h;
    str_cc05h  = crok_cc05h && !une_cc05h && |al_cc05h;
    // The queue's head, or the first record waiting to be queued; a
    // straight send's id is its record's, read a cycle on (sidx).
    sio_cc05h  = '0;
    if (fne_cc05h) sio_cc05h = uo_cc05h;
    else
      for (int r = 0; r < NP; r++)
        if (frq_cc05h[r]) sio_cc05h = sio_cc05h | rcio_q_cc05h[r];
  end

  // ---- The entries, written at D3 from the records (one clock gate) -------
  // Valid, state and count through masks (an AND-OR, not a per-field hold,
  // which synthesis would split into gates of 1 to 3 flops). An entry sent
  // straight is allocated and sent in one write.
  logic ctl_en_cc05h;
  assign ctl_en_cc05h = rst_r01h || |rcal_q_cc05h || |rcmg_q_cc05h || mvi_q_cc05h ||
                        fv_q_cc04h || xv_q_cc05h;
  for (genvar e = 0; e < NE; e++) begin : g_e
    logic           shit_cc05h;
    logic           mvm_cc05h, dv_cc05h;
    logic [1:0]     ms_cc05h, ds_cc05h;
    logic [WLC-1:0] mc_cc05h, dc_cc05h;
    assign shit_cc05h = mvi_q_cc05h && sohx_cc05h[e];
    assign mvm_cc05h  = rst_r01h || pd_cc05h[e] || xhit_cc05h[e];
    assign dv_cc05h   = !rst_r01h && pd_cc05h[e];
    assign ms_cc05h   = {2{rst_r01h || pd_cc05h[e] || shit_cc05h || fhit_cc04h[e]}};
    assign ds_cc05h   = rst_r01h ? ST_UNSENT : shit_cc05h ? ST_SENT
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
        if (li_en_cc05h) elist_q_cc05h[e][k] <= mitx_cc05h[e];
      end
    end

    // An allocation's line, fold, coh_op and first list word.
    logic           wd_en_cc05h;
    logic [WL-1:0]  wpa_cc05h;
    logic [WF-1:0]  wfold_cc05h;
    logic [1:0]     wop_cc05h;
    logic [WLE-1:0] wit_cc05h;
    assign wd_en_cc05h = pd_cc05h[e];
    always_comb begin
      wpa_cc05h   = '0;
      wfold_cc05h = '0;
      wop_cc05h   = '0;
      wit_cc05h   = '0;
      for (int r = 0; r < NP; r++)
        if (rcal_q_cc05h[r] && rcio_q_cc05h[r][e]) begin
          wpa_cc05h   = wpa_cc05h   | rcpa_q_cc05h[r];
          wfold_cc05h = wfold_cc05h | rcfold_q_cc05h[r];
          wop_cc05h   = wop_cc05h   | rcop_q_cc05h[r];
          wit_cc05h   = wit_cc05h   | rcit_q_cc05h[r];
        end
    end
    always_ff @(posedge dcu_core_clk) begin
      if (wd_en_cc05h) begin
        epa_q_cc05h[e]      <= wpa_cc05h;
        efold_q_cc05h[e]    <= wfold_cc05h;
        ecoh_q_cc05h[e]     <= coh_of(wop_cc05h);
        elist_q_cc05h[e][0] <= wit_cc05h;
      end
    end
  end

  // ---- The next free ids ------------------------------------------------
  // Each port holds an offer, the id it allocates; a requesting port's
  // offer is taken whatever the port did. It, and a port with none, takes
  // the next of last cycle's picks, in port order. The picks are made a
  // cycle ahead from this module's flops alone: the free entries (one freed
  // now counts) less the offers, the picks and the offers taken last cycle
  // (an allocation's entry is valid only a cycle on); so an id freed, or
  // left unused by a port, is offered two cycles on. A pick takes, in
  // order, the lowest such entry, the highest, the second lowest, the
  // second highest and the third lowest, each only when it is none before
  // it: the picks are a list's prefix, zero past it.
  logic [NE-1:0]  av_cc05h, pn_cc05h [NNF];
  logic           pnv_cc05h;
  always_comb begin
    logic [NE-1:0] l1, l2, l3, h1, h2;
    logic [NE-1:0] o [5];
    for (int e = 0; e < NE; e++)
      av_cc05h[e] = (!ev_q_cc05h[e] && !ua_q_cc05h[e]) || xhit_cc05h[e];
    for (int i = 0; i < NNF; i++)
      av_cc05h = av_cc05h & ~nfoh_q_cc05h[i] & ~pk_q_cc05h[i];
    // l<n>[e]: at least n free below e; h<n>[e]: at least n above e (sums
    // of products, so that synthesis builds trees, not chains).
    for (int e = 0; e < NE; e++) begin
      l1[e] = 1'b0;
      l2[e] = 1'b0;
      l3[e] = 1'b0;
      h1[e] = 1'b0;
      h2[e] = 1'b0;
      for (int i = 0; i < NE; i++) begin
        if (i < e) l1[e] = l1[e] || av_cc05h[i];
        if (i > e) h1[e] = h1[e] || av_cc05h[i];
        for (int j = i + 1; j < NE; j++) begin
          if (j < e) l2[e] = l2[e] || (av_cc05h[i] && av_cc05h[j]);
          if (i > e) h2[e] = h2[e] || (av_cc05h[i] && av_cc05h[j]);
          for (int m = j + 1; m < e; m++) l3[e] = l3[e] || (av_cc05h[i] && av_cc05h[j] && av_cc05h[m]);
        end
      end
    end
    o[0] = av_cc05h & ~l1;
    o[1] = av_cc05h & ~h1;
    o[2] = av_cc05h & l1 & ~l2;
    o[3] = av_cc05h & h1 & ~h2;
    o[4] = av_cc05h & l2 & ~l3;
    // A pick that is one before it means too few are free: it is none.
    pn_cc05h[0] = o[0];
    pn_cc05h[1] = o[1] & ~o[0];
    pn_cc05h[2] = o[2] & ~o[1];
    pn_cc05h[3] = o[3] & ~(o[0] | o[2]);
    pn_cc05h[4] = o[4] & ~(o[1] | o[3]);
    pnv_cc05h = |av_cc05h;
  end
  // A port takes a pick when it requests or has no offer (qf): the pick at
  // its place among those ports (rf, one-hot, a sum of products).
  logic [NP-1:0]  qf_cc05h;
  logic [NNF-1:0] rf_cc05h   [NP];
  logic [NNF-1:0] pkz_cc05h;                  // a pick is made
  logic [NE-1:0]  nfoh_cc05h [NNF];
  logic [NNF-1:0] nfvn_cc05h;
  logic [NE-1:0]  uan_cc05h;
  always_comb begin
    for (int p = 0; p < NP; p++) qf_cc05h[p] = pq_cc04h[p] || !nfv_q_cc05h[p];
    for (int k = 0; k < NNF; k++) pkz_cc05h[k] = |pk_q_cc05h[k];
    for (int p = 0; p < NP; p++) begin
      rf_cc05h[p] = '0;
      for (int m = 0; m < (1 << p); m++) begin
        logic t;
        int   n;
        t = 1'b1;
        n = 0;
        for (int j = 0; j < p; j++) begin
          t = t && (((m >> j) & 1) != 0 ? qf_cc05h[j] : !qf_cc05h[j]);
          n = n + ((m >> j) & 1);
        end
        rf_cc05h[p][n < NNF ? n : 0] = rf_cc05h[p][n < NNF ? n : 0] || t;
      end
    end
    uan_cc05h = '0;
    // Through masks (an AND-OR, not a per-port hold, which synthesis would
    // split into a gate per port on an enable from the inputs).
    for (int p = 0; p < NP; p++) begin
      nfoh_cc05h[p] = nfoh_q_cc05h[p] & ~{NE{qf_cc05h[p]}};
      nfvn_cc05h[p] = nfv_q_cc05h[p] && !qf_cc05h[p];
      for (int k = 0; k < NNF; k++) begin
        nfoh_cc05h[p] = nfoh_cc05h[p] | (pk_q_cc05h[k] & {NE{qf_cc05h[p] && rf_cc05h[p][k]}});
        nfvn_cc05h[p] = nfvn_cc05h[p] || (pkz_cc05h[k] && qf_cc05h[p] && rf_cc05h[p][k]);
      end
      uan_cc05h = uan_cc05h | (nfoh_q_cc05h[p] & {NE{pq_cc04h[p]}});
    end
    // At reset every entry is free: the pick's order over all of them, and
    // the next five after them.
    if (rst_r01h) begin
      uan_cc05h = '0;
      for (int i = 0; i < NNF; i++)
        nfoh_cc05h[i] = NE'(1) << (i % 2 == 0 ? i / 2 : NE - 1 - i / 2);
      nfvn_cc05h = '1;
    end
  end
  logic nf_en_cc05h;
  assign nf_en_cc05h = rst_r01h || pres_cc04h || xv_q_cc05h ||
                       (pkv_q_cc05h && !(&nfv_q_cc05h));
  always_ff @(posedge dcu_core_clk) begin
    if (nf_en_cc05h) begin
      for (int i = 0; i < NNF; i++) begin
        nfoh_q_cc05h[i] <= nfoh_cc05h[i];
        pk_q_cc05h[i]   <= rst_r01h ? NE'(1) << (i % 2 == 0 ? 3 + i / 2 : NE - 3 - i / 2)
                                    : pn_cc05h[i];
      end
      nfv_q_cc05h <= nfvn_cc05h;
      pkv_q_cc05h <= rst_r01h || pnv_cc05h;
    end
  end
  logic ua_en_cc05h;
  assign ua_en_cc05h = rst_r01h || pres_cc04h || |ua_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (ua_en_cc05h) ua_q_cc05h <= uan_cc05h;
  end

  // ---- The records ----------------------------------------------------------
  // The decisions; then each port's id, hit entry and payload, under its own
  // request's lead (a slot's lookup or the retry's lead).
  // The decision records share the outcome's gate (oc_en_cc05h, below): a
  // retry that waits again changes only the outcome, and a record is set
  // only with an outcome, so oany_q_cc05h clears it (CG-3; DI-35's retry
  // lead opens the gate on every granted bank pick).
  logic [NP-1:0] rcp_en_cc04h;
  assign rcp_en_cc04h = {lv_q_cc04h, rl_q_cc04h};
  for (genvar p = 0; p < NP; p++) begin : g_rc
    always_ff @(posedge dcu_core_clk) begin
      if (rcp_en_cc04h[p]) begin
        rcio_q_cc05h[p]   <= aio_cc05h[p];
        rcmt_q_cc05h[p]   <= hit_cc05h[p];
        rcpa_q_cc05h[p]   <= qpa_cc04h[p];
        rcfold_q_cc05h[p] <= qfold_cc04h[p];
        rcop_q_cc05h[p]   <= qop_cc04h[p];
        rcit_q_cc05h[p]   <= qit_cc04h[p];
      end
    end
  end

  // ---- The send order and the credits ------------------------------------
  // At D3 an allocated entry is younger than every other, and than those
  // allocated with it from a later port: a bit is written when either of
  // its entries is allocated (one gate, masks).
  logic [NP-1:0] apo_cc05h [NE];              // [e][r]: entry e allocated by record r
  always_comb
    for (int e = 0; e < NE; e++)
      for (int r = 0; r < NP; r++) apo_cc05h[e][r] = rcal_q_cc05h[r] && rcio_q_cc05h[r][e];
  logic od_en_cc05h;
  assign od_en_cc05h = |rcal_q_cc05h;
  for (genvar i = 0; i < NE; i++) begin : g_od
    logic [NE-1:0] om_cc05h, odn_cc05h;
    always_comb begin
      for (int j = 0; j < NE; j++) begin
        logic ij;
        ij = 1'b0;
        for (int r = 0; r < NP; r++)
          for (int q = r + 1; q < NP; q++) ij = ij || (apo_cc05h[i][r] && apo_cc05h[j][q]);
        om_cc05h[j]  = j > i && (pd_cc05h[i] || pd_cc05h[j]);
        odn_cc05h[j] = pd_cc05h[i] && pd_cc05h[j] ? ij : !pd_cc05h[i];
      end
    end
    always_ff @(posedge dcu_core_clk) begin
      if (od_en_cc05h) old_q_cc05h[i] <= (old_q_cc05h[i] & ~om_cc05h) | (odn_cc05h & om_cc05h);
    end
  end
  // The credits less the sends before last cycle (a send counts a cycle
  // late, from its valid's flop: depth).
  logic cr_en_cc05h;
  assign cr_en_cc05h = rst_r01h || mvi_q_cc05h || crq_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (cr_en_cc05h)
      cr_q_cc05h <= rst_r01h ? WCR'(NCR) : cr_q_cc05h - WCR'(mvi_q_cc05h) + WCR'(crq_q_cc05h);
  end

  // ---- D3: the outcome, and the request's valid --------------------------
  logic [NBK-1:0]   ovn_cc04h, own_cc05h;
  logic [NBK*2-1:0] oyn_cc05h;
  always_comb begin
    for (int b = 0; b < NBK; b++) begin
      ovn_cc04h[b]       = 1'b0;
      own_cc05h[b]       = 1'b0;
      oyn_cc05h[b*2 +: 2] = 2'd0;
      for (int p = 0; p < NP; p++)
        if (qbo_cc04h[p][b]) begin
          ovn_cc04h[b]        = 1'b1;
          own_cc05h[b]        = own_cc05h[b] || wt_cc05h[p];
          oyn_cc05h[b*2 +: 2] = oyn_cc05h[b*2 +: 2] | why_cc05h[p];
        end
    end
  end
  logic oc_en_cc05h;
  assign oc_en_cc05h = rst_r01h || pres_cc04h || oany_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (oc_en_cc05h) begin
      ov_q_cc05h   <= rst_r01h ? '0 : ovn_cc04h;
      ow_q_cc05h   <= rst_r01h ? '0 : own_cc05h;
      owi_q_cc05h  <= rst_r01h ? '0 : own_cc05h;
      oy_q_cc05h   <= oyn_cc05h;
      oany_q_cc05h <= !rst_r01h && |ovn_cc04h;
      for (int p = 0; p < NP; p++) begin
        rcal_q_cc05h[p]  <= !rst_r01h && al_cc05h[p];
        rcalh_q_cc05h[p] <= !rst_r01h && al_cc05h[p];
        rcmg_q_cc05h[p]  <= !rst_r01h && mg_cc05h[p];
      end
    end
  end
  assign ov_cc05h    = ov_q_cc05h;
  assign owait_cc05h = ow_q_cc05h;
  assign owhy_cc05h  = oy_q_cc05h;

  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) begin
      mv_q_cc05h  <= 1'b0;
      mvi_q_cc05h <= 1'b0;
    end else begin
      mv_q_cc05h  <= snd_cc05h;
      mvi_q_cc05h <= snd_cc05h;
    end
  end
  // The send record. soh is read only behind mvi_q (the cycle after a
  // send) and masked by stq (sohm), so it is written only when a send
  // from the queue may happen: a credit is left and an entry is unsent
  // (counting last cycle's, a superset) or a record waits to be queued. A
  // straight send leaves it as it was, and stq masks it then. sport is
  // also read by rcq (not behind mvi_q).
  logic sd_en_cc05h, sp_en_cc05h, unq_cc05h;
  assign unq_cc05h    = |(ev_q_cc05h & usv_cc05h) || rqa_cc05h;
  assign sd_en_cc05h = crok_cc05h && unq_cc05h;
  assign sp_en_cc05h = pres_cc04h || une_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (sd_en_cc05h) soh_q_cc05h <= sio_cc05h;
  end
  always_ff @(posedge dcu_core_clk) begin
    if (sp_en_cc05h) sport_q_cc05h <= str_cc05h ? fa_cc05h : '0;
  end
  // The mask of soh, one flop (|sport would put an OR on the send's loop).
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) stq_q_cc05h <= 1'b0;
    else          stq_q_cc05h <= str_cc05h;
  end
  assign mv_cc05h = mv_q_cc05h;

  // H+6: the payload, from the entry the valid named, or its record.
  logic [WE-1:0] mrid_q_cc06h;
  logic [WL-1:0] mpa_q_cc06h;
  logic [WC-1:0] mcoh_q_cc06h;
  logic          mp_en_cc05h;
  logic [WL-1:0] mpan_cc05h;
  logic [WC-1:0] mcon_cc05h;
  always_comb begin
    // The entry sent (one-hot; none when it went straight), or its record.
    mpan_cc05h = '0;
    mcon_cc05h = '0;
    for (int e = 0; e < NE; e++)
      if (sohm_cc05h[e]) begin
        mpan_cc05h = mpan_cc05h | epa_q_cc05h[e];
        mcon_cc05h = mcon_cc05h | ecoh_q_cc05h[e];
      end
    for (int r = 0; r < NP; r++)
      if (sport_q_cc05h[r]) begin
        mpan_cc05h = mpan_cc05h | rcpa_q_cc05h[r];
        mcon_cc05h = mcon_cc05h | coh_of(rcop_q_cc05h[r]);
      end
  end
  assign mp_en_cc05h = mvi_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (mp_en_cc05h) begin
      mrid_q_cc06h <= sidx_cc05h;
      mpa_q_cc06h  <= mpan_cc05h;
      mcoh_q_cc06h <= mcon_cc05h;
    end
  end
  assign mrid_cc06h = mrid_q_cc06h;
  assign mpa_cc06h  = {mpa_q_cc06h, WO'(0)};
  assign mcoh_cc06h = mcoh_q_cc06h;
  assign mcid_cc06h = WCID'(CID);

  // ---- The free's id ---------------------------------------------------------
  // An input cannot enable its own capture (CG-5), so it is captured whenever
  // an entry is filled (own flops), the only time one can be freed.
  logic xid_en_cc05h;
  always_comb begin
    xid_en_cc05h = 1'b0;
    for (int e = 0; e < NE; e++)
      xid_en_cc05h = xid_en_cc05h || (ev_q_cc05h[e] && est_q_cc05h[e] == ST_FILLED);
  end
  always_ff @(posedge dcu_core_clk) begin
    if (xid_en_cc05h) xid_q_cc05h <= xid_cc04h;
  end

  // ---- F: the fill's entry read ------------------------------------------
  logic [WL-1:0]     fpa_q_cc05h;
  logic [WF-1:0]     ffold_q_cc05h;
  logic [WC-1:0]     fcoh_q_cc05h;
  logic [WLC-1:0]    fcnt_q_cc05h;
  logic [LD*WLE-1:0] flist_q_cc05h;
  logic              fr_en_cc04h;
  assign fr_en_cc04h = fv_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (fr_en_cc04h) begin
      fpa_q_cc05h   <= epa_q_cc05h[frid_cc04h];
      ffold_q_cc05h <= efold_q_cc05h[frid_cc04h];
      fcoh_q_cc05h  <= ecoh_q_cc05h[frid_cc04h];
      fcnt_q_cc05h  <= ecnt_q_cc05h[frid_cc04h] + WLC'(pdm_cc05h[frid_cc04h]);
      for (int k = 0; k < LD; k++)
        flist_q_cc05h[k*WLE +: WLE] <=
            (pdm_cc05h[frid_cc04h] && ecnt_q_cc05h[frid_cc04h] == WLC'(k))
            ? mitx_cc05h[frid_cc04h] : elist_q_cc05h[frid_cc04h][k];
    end
  end
  // The write request: the lead from the same read, the payload a cycle on.
  logic              flv_q_cc05h;
  logic [NBK-1:0]    fbk_q_cc05h;
  logic [WL-1:0]     fwpa_q_cc06h;
  logic [WF-1:0]     fwfold_q_cc06h;
  logic [WB-1:0]     fbn_cc04h;
  assign fbn_cc04h = epa_q_cc05h[frid_cc04h][WB-1:0];
  always_ff @(posedge dcu_core_clk) begin
    flv_q_cc05h <= !rst_r01h && fv_q_cc04h;
  end
  always_ff @(posedge dcu_core_clk) begin
    if (fr_en_cc04h) fbk_q_cc05h <= NBK'(1) << fbn_cc04h;
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
  assign fpa_cc05h   = fpa_q_cc05h;
  assign ffold_cc05h = ffold_q_cc05h;
  assign fcoh_cc05h  = fcoh_q_cc05h;
  assign fcnt_cc05h  = fcnt_q_cc05h;
  assign flist_cc05h = flist_q_cc05h;

  // ---- CHECKs -------------------------------------------------------------
  // No two entries hold one line (an entry's line counts once written), a
  // bank names one request a cycle and a slot's miss is its line's bank, MLC
  // answers only an id in flight and an entry written, the queue never
  // overflows.
  logic dup_cc05h, bank_ok_cc04h;
  always_comb begin
    dup_cc05h = 1'b0;
    for (int i = 0; i < NE; i++)
      for (int j = i + 1; j < NE; j++)
        dup_cc05h = dup_cc05h || (ev_q_cc05h[i] && ev_q_cc05h[j] && !pd_cc05h[i] &&
                                  !pd_cc05h[j] && epa_q_cc05h[i] == epa_q_cc05h[j]);
    bank_ok_cc04h = !(rl_q_cc04h && mv_cc04h[qbk_cc04h[0]]);
    for (int b = 0; b < NBK; b++)
      if (mv_cc04h[b])
        bank_ok_cc04h = bank_ok_cc04h &&
                        sp_pa_q_cc04h[mslot_cc04h[b*WSL +: WSL]][WB-1:0] == WB'(b);
  end
  `CCV_ASSERT(mshr_one_line, !dup_cc05h)
  `CCV_ASSERT(mshr_one_request, bank_ok_cc04h)
  `CCV_ASSERT(mshr_mv_lead, !(|mv_cc04h) || |lv_q_cc04h)
  `CCV_ASSERT(mshr_fill_in_flight, !fv_q_cc04h ||
              (ev_q_cc05h[frid_cc04h] && !pd_cc05h[frid_cc04h] &&
               est_q_cc05h[frid_cc04h] == ST_SENT))
  `CCV_ASSERT(mshr_free_filled, !xv_q_cc05h ||
              (ev_q_cc05h[xid_q_cc05h] && est_q_cc05h[xid_q_cc05h] == ST_FILLED))
  `CCV_ASSERT(mshr_credit, cr_q_cc05h <= WCR'(NCR))
  `CCV_ASSERT(mshr_pending_free, !(|(pd_cc05h & ev_q_cc05h)))
  // Credits never go negative: last cycle's send is in mvi_q, not yet in cr_q.
  `CCV_ASSERT(mshr_credit_floor, cr_q_cc05h >= WCR'(mvi_q_cc05h))

endmodule
`undef CCV_CLK
`undef CCV_RST
