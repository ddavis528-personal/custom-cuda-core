//===-- dcu_bctl.sv - DCU bank control: one bank's arbitration and predictor ===//
//
// Spec: docs/design-snapshots/dcu-spec.md (live: CCV per-block architecture
//       specs, DCU tab, "MA's Phase 2", slice 1 (rev 83): the stage table's
//       D0 to D3 rows, "Bank arbitration", "LRU and the predictor", the
//       module partition's dcu_bctl row and the port budgets; slice 2 part 1
//       (rev 112): "Waits", the miss-wait entries and their retry, with
//       DI-34, DI-35 and DI-36 in the DI tab).
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
//        joins the hit FIFO (or takes the next access straight away when it
//        is empty). The lookup goes to dcu_mshr (dv, from flops; dcu_mshr
//        takes dcu_btag's hit beside it), unless this bank holds a miss-wait
//        waiter: then a miss waits here behind it (bank order).
//   D3      the answer carry: the access two cycles back gave a valid
//        answer (av: req_id, slot, late), from flops. dcu_mshr's outcome for
//        a miss: placed, or waiting with its cause.
//
// Slice 2's entries (DI-36): every lookup holds one of the bank's 16 queue
// entries (its MIU credit's) from D1 until it leaves, with the payload a
// retry needs (line, req_id, op, exclusive, fold). A hit leaves at D3; a
// miss leaves when dcu_mshr places it, or is marked miss-wait and joins the
// bank's miss-wait FIFO. The FIFO's head is offered to dcu_mshr's retry
// port (DI-35: rov and a 10-bit stamp of when it became head or last
// waited, its payload from flops), granted a cycle on, and its outcome comes
// at R+3: placed (it leaves) or waiting again (stamped anew). A credit goes
// back as an entry leaves: answered (a waiter's access, a granted hit at D2)
// or placed.
//
// The hit FIFO holds only hits: a loser's tag result is known before it
// waits, so a waiter reads its line's way without prediction. A queued
// lookup keeps that result; fills and evictions, which can change it, come
// with tag-stale marking (slice 2, increment B), and so does a miss-wait
// whose line has been filled (it looks up again instead of retrying).
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
  parameter  int WA    = ccv_prov_pkg::CCV_P_W_PA,                   // PA, 48
  parameter  int WO    = $clog2(ccv_prov_pkg::CCV_P_LINE_BYTES),     // line offset, 7
  parameter  int WC    = ccv_prelim_pkg::CCV_L_W_COH_OP,             // coh_op, 4
  parameter  int WST   = 4,                                          // store-data index
  parameter  int WRS   = 10,                                         // retry stamp (DI-35)
  parameter  int NFB   = ccv_params_pkg::CCV_CREDIT_DEPTH,           // fill buffers, 4
  // The port's credits: the round trip, 4 = a lead at c, its write at c+2
  // at the earliest, fwcr at c+3, the driver's flopped credit usable at c+4,
  // so a lead every cycle (DI-46). Two of them are always outside the
  // queue (a lead's cycle and its payload's; the return's pulse and the
  // driver's flop), so the queue holds PC - 2 entries.
  parameter  int PC    = 4,
  localparam int PD    = PC - 2,
  localparam int WL    = WA - WO,                                    // line, 41
  localparam int WB    = NB,                                         // bank index, 3
  localparam int NBK   = 1 << NB,                                     // banks, 8
  localparam int WR    = WS - NB,                                    // set in the bank, 6
  localparam int NSET  = 1 << WR,                                    // 64
  localparam int WWY   = WAYS > 1 ? $clog2(WAYS) : 1,                // 3
  localparam int WSL   = SLOTS > 1 ? $clog2(SLOTS) : 1,              // 2
  localparam int WQ    = $clog2(QD),                                 // 4
  localparam int WTS   = 8,                                          // age stamp
  localparam int NPL   = WAYS - 1,                                   // PLRU bits a set, 7
  localparam int WFE   = WF + 1,                                     // fold entry: valid, fold
  localparam int WFB   = NFB > 1 ? $clog2(NFB) : 1,                  // fill buffer index, 2
  localparam int NFW   = NFB,                                        // fill writes a bank holds
  localparam int KH    = ccv_prov_pkg::CCV_DCU_FILL_AGE              // DI-37's hold, 4
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
  // D1: the payload a retry needs (slice 2, DI-34 (3)), from each slot's
  // dcu_cap flops: the line, pa_fold, coh_op and exclusive_req, kept in the
  // lookup's queue entry.
  input  logic [SLOTS*WL-1:0]    pa_cc03h,
  input  logic [SLOTS*WF-1:0]    fold_cc03h,
  input  logic [SLOTS*WC-1:0]    coh_cc03h,
  input  logic [SLOTS-1:0]       excl_cc03h,
  // D2: the lookup's tag result, from dcu_btag.
  input  logic                   hit_cc04h,
  input  logic [WAYS-1:0]        way_cc04h,      // one-hot
  // dcu_fix's access (one CE rewrite's read or write), from its flops: fxv a
  // one-cycle lead, its payload a cycle on; the next only after fxg.
  input  logic                   fxv_cc03h,
  input  logic                   fxw_cc04h,      // the write
  input  logic [WR+WWY-1:0]      fxa_cc04h,      // {set, way}
  // The fold table's write port (part 4's invalidations): fwe a cycle
  // ahead of its payload, under PD credits (DI-46, MA rev 193): a lead spends
  // one, and fwcr returns it, a pulse the cycle after the entry's write.
  input  logic                   fwe_cc00h,
  input  logic [WR-1:0]          fws_cc01h,
  input  logic [WWY-1:0]         fwy_cc01h,
  input  logic [WF-1:0]          fwf_cc01h,
  output logic                   fwcr_cc03h,
  // A fill's bank write request (DI-39, MA rev 177): its lead at F+1 from
  // dcu_mshr's F read (the valid and the bank, one hot), its payload at F+2
  // from dcu_mshr's flops (the line's set in the bank, PA[15:10] of fwpa,
  // and the fold) and dcu_fill's (the buffer).
  input  logic                   flv_cc03h,
  input  logic [NBK-1:0]          fbk_cc03h,
  input  logic [WR-1:0]          fwset_cc03h,
  input  logic [WF-1:0]          fwfold_cc03h,
  input  logic [WFB-1:0]         fwb_cc03h,
  // The fill's write, this cycle's access (W): the buffer whose line the
  // SRAM takes (dcu_bdat's select) and which dcu_fill marks written.
  output logic                   wdv_cc04h,
  output logic [WFB-1:0]         wdb_cc04h,
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
  // D2: the lookup at D2, not dropped, for dcu_mshr (which takes dcu_btag's
  // hit beside it: a miss is dv && !hit), unless this bank holds a
  // miss-wait waiter, behind which it waits here (bank order).
  output logic                   dv_cc04h,
  output logic [WSL-1:0]         mslot_cc04h,
  // D3: dcu_mshr's outcome for this bank (its D2 lookup's or its retry's).
  input  logic                   ov_cc04h,
  input  logic                   owait_cc04h,
  input  logic [1:0]             owhy_cc04h,     // 0 no entry, 1 list full, 2 filled, 3 bank order
  // The retry (DI-35): the offer of the bank's oldest miss-wait waiter, its
  // grant a cycle on, and its payload from flops while offered.
  output logic                   rov_cc04h,
  output logic [WRS-1:0]         rstp_cc04h,
  input  logic                   rgv_cc04h,
  input  logic [WB-1:0]          rgb_cc04h,
  output logic [WL-1:0]          rpa_cc04h,
  output logic [WI-1:0]          rrid_cc04h,
  output logic [1:0]             rop_cc04h,      // 0 read, 1 atomic, 2 store
  output logic                   rexcl_cc04h,
  output logic [WF-1:0]          rfold_cc04h,
  output logic [WST-1:0]         rsti_cc04h,
  // An entry credit back to MIU (ccv_dcu_miu_cred's ent_ret for this bank).
  output logic                   ent_ret_cc04h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge dcu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // A set in the bank, predecoded: one-hot halves, {upper, lower} (DI-43's
  // snapshot selects its row by them: an AND of two 8-wide selects, not a
  // 6-bit compare fanned out to 64 rows).
  localparam int WRL = WR - WR / 2, WRH = WR / 2, NRL = 1 << WRL, NRH = 1 << WRH;
  localparam int NSP = NRH + NRL;
  function automatic logic [NSP-1:0] pdec(input logic [WR-1:0] s);
    pdec = '0;
    for (int h = 0; h < NRH; h++) pdec[NRL + h] = s >> WRL == WR'(h);
    for (int l = 0; l < NRL; l++) pdec[l] = s[WRL-1:0] == WRL'(l);
  endfunction
  function automatic logic psame(input logic [NSP-1:0] a, input logic [NSP-1:0] b);
    psame = |(a[NSP-1:NRL] & b[NSP-1:NRL]) && |(a[NRL-1:0] & b[NRL-1:0]);
  endfunction

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
  (* keep *) logic [SLOTS-1:0] pkt_q_cc02h;     // the fold row's upper ways' copy
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) begin
      pk_q_cc02h  <= '0;
      pks_q_cc02h <= '0;
      pkt_q_cc02h <= '0;
    end else begin
      pk_q_cc02h  <= pk_cc01h;
      pks_q_cc02h <= pk_cc01h;
      pkt_q_cc02h <= pk_cc01h;
    end
  end

  // ---- the fold table's write port (slice 2) --------------------------------
  logic fwe_q_cc01h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) fwe_q_cc01h <= 1'b0;
    else          fwe_q_cc01h <= fwe_cc00h;
  end
  // The port's writes wait in PD entries, a shift queue whose head (entry
  // 0) writes in any cycle the fill does not (DI-46): its payload captured
  // from the pins under its lead's flop, into the first entry free once the
  // head has gone.
  logic [PD-1:0]   pv_q_cc02h;
  logic [WR-1:0]   pes_q_cc02h [PD];
  logic [WWY-1:0]  pey_q_cc02h [PD];
  logic [WF-1:0]   pef_q_cc02h [PD];
  (* keep *) logic gfa_q_cc04h;      // the fill's write (W), below
  logic            pw_cc02h;         // the head writes now
`ifdef CCV_CTL_BCTL_PORT_NOWAIT
  assign pw_cc02h = pv_q_cc02h[0];   // the control: the head writes over the fill's
`else
  assign pw_cc02h = pv_q_cc02h[0] && !gfa_q_cc04h;
`endif
  logic [PD-1:0]   pvs_cc02h, pin_cc02h;
  always_comb begin
    pvs_cc02h = pw_cc02h ? pv_q_cc02h >> 1 : pv_q_cc02h;
    // The lowest free entry (the queue fills from 0; PD >= 2).
    pin_cc02h = {PD{fwe_q_cc01h}} & ~pvs_cc02h & {pvs_cc02h[PD-2:0], 1'b1};
  end
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) pv_q_cc02h <= '0;
    else          pv_q_cc02h <= pvs_cc02h | pin_cc02h;
  end
  for (genvar i = 0; i < PD; i++) begin : g_pe
    logic pe_en_cc02h;
    if (i + 1 < PD) begin : g_sh
      assign pe_en_cc02h = pin_cc02h[i] || (pw_cc02h && pv_q_cc02h[i+1]);
      always_ff @(posedge dcu_core_clk) begin
        if (pe_en_cc02h) begin
          pes_q_cc02h[i] <= pin_cc02h[i] ? fws_cc01h : pes_q_cc02h[i+1];
          pey_q_cc02h[i] <= pin_cc02h[i] ? fwy_cc01h : pey_q_cc02h[i+1];
          pef_q_cc02h[i] <= pin_cc02h[i] ? fwf_cc01h : pef_q_cc02h[i+1];
        end
      end
    end else begin : g_last
      assign pe_en_cc02h = pin_cc02h[i];
      always_ff @(posedge dcu_core_clk) begin
        if (pe_en_cc02h) begin
          pes_q_cc02h[i] <= fws_cc01h;
          pey_q_cc02h[i] <= fwy_cc01h;
          pef_q_cc02h[i] <= fwf_cc01h;
        end
      end
    end
  end
  // The credit's return: the cycle after the entry's write.
  logic fwcr_q_cc03h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) fwcr_q_cc03h <= 1'b0;
    else          fwcr_q_cc03h <= pw_cc02h;
  end
  assign fwcr_cc03h = fwcr_q_cc03h;
  // The port holds an entry next cycle (the fill's grant now yields to it).
  logic pwn_cc02h;
  assign pwn_cc02h = |pvs_cc02h || fwe_q_cc01h;

  // The fold table: per set, each way's {valid, fold}. A row is one clock
  // gate (8 x WFE flops), written by a fill at W (from this module's flops,
  // below; ahead of the port, which the bench preloads through and which
  // part 4's invalidations take), cleared by reset.
  // The row is the gate: a fill clocks its set's 8 x WFE flops and changes
  // one way's, the others written back through a mask (an AND-OR, not a
  // per-way hold, which synthesis would split into gates of WFE flops).
  logic [WAYS*WFE-1:0] ft_q_cc03h [NSET];
  logic [WAYS*WFE-1:0] fm_cc02h, fv_cc02h;
  (* keep *) logic [WR-1:0]  wfs_q_cc04h;
  (* keep *) logic [WWY-1:0] wfw_q_cc04h;
  logic [WF-1:0]       wff_q_cc04h;
  logic [WR-1:0]       ftws_cc02h;
  logic                wfc_q_cc04h;      // the fill's write changes its entry (below)
  logic [WWY-1:0]      ftwy_cc02h;
  logic [WF-1:0]       ftwf_cc02h;
  assign ftws_cc02h = gfa_q_cc04h ? wfs_q_cc04h : pes_q_cc02h[0];
  assign ftwy_cc02h = gfa_q_cc04h ? wfw_q_cc04h : pey_q_cc02h[0];
  assign ftwf_cc02h = gfa_q_cc04h ? wff_q_cc04h : pef_q_cc02h[0];
  always_comb begin
    for (int w = 0; w < WAYS; w++) begin
      fm_cc02h[w*WFE +: WFE] = {WFE{rst_r01h || ftwy_cc02h == WWY'(w)}};
      fv_cc02h[w*WFE +: WFE] = rst_r01h ? '0 : {1'b1, ftwf_cc02h};
    end
  end
  for (genvar r = 0; r < NSET; r++) begin : g_ft
    logic                ft_en_cc02h;
    logic [WAYS*WFE-1:0] ftn_cc02h;
    assign ft_en_cc02h = rst_r01h || ((pw_cc02h || (gfa_q_cc04h && wfc_q_cc04h)) &&
                                      ftws_cc02h == WR'(r));
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
  logic          plc_cc04h;            // a miss placed (a credit)
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
  // The row selects, predecoded from each slot's set on the wires (an AND
  // of two 8-wide selects after the pick, not a compare after it).
  logic [NSP-1:0] lsd_cc02h [SLOTS];
  logic [NSP-1:0] sps_cc02h, spt_cc02h;
  always_comb begin
    sps_cc02h = '0;
    spt_cc02h = '0;
    for (int s = 0; s < SLOTS; s++) begin
      lsd_cc02h[s] = pdec(lsi_cc02h[s*WS + NB +: WR]);
      sps_cc02h = sps_cc02h | (lsd_cc02h[s] & {NSP{pks_q_cc02h[s]}});
      spt_cc02h = spt_cc02h | (lsd_cc02h[s] & {NSP{pkt_q_cc02h[s]}});
    end
  end
  logic [WAYS*WFE-1:0] fr_cc03h;
  always_comb begin
    fr_cc03h = '0;
    for (int r = 0; r < NSET; r++) begin
      if (sps_cc02h[NRL + (r >> WRL)] && sps_cc02h[r & (NRL - 1)])
        fr_cc03h[WAYS/2*WFE-1:0] = fr_cc03h[WAYS/2*WFE-1:0] | ft_q_cc03h[r][WAYS/2*WFE-1:0];
      if (spt_cc02h[NRL + (r >> WRL)] && spt_cc02h[r & (NRL - 1)])
        fr_cc03h[WAYS*WFE-1:WAYS/2*WFE] = fr_cc03h[WAYS*WFE-1:WAYS/2*WFE] |
                                          ft_q_cc03h[r][WAYS*WFE-1:WAYS/2*WFE];
    end
  end
  logic [WQ-1:0] fei_cc04h;            // the D1 lookup's entry (the queue entries below)
  logic [WAYS-1:0] fm_cc03h;
  always_comb begin
    for (int w = 0; w < WAYS; w++)
      fm_cc03h[w] = fr_cc03h[w*WFE + WF] && fr_cc03h[w*WFE +: WF] == folds_cc02h;
  end
  logic am_cc03h;
  assign am_cc03h = |fm_cc03h;
  // The read-after-write margin (DI-42, MA's DCU tab rev 121): a lead whose
  // fold row the fill writes this cycle or wrote last cycle discards its fold
  // compare at D2 and takes the mispredict's re-read, which reads its tag's
  // way and never the fold table. Beside the compare, from bctl's flops.
  logic           ftfe_cc04h;           // the fill's fold write, this cycle
  assign ftfe_cc04h = gfa_q_cc04h && wfc_q_cc04h;
  logic           ftp_q_cc04h;          // and last cycle's, with its row
  logic [WR-1:0]  ftps_q_cc04h;
  logic [NSP-1:0] ftpp_q_cc04h;         // its row, predecoded (the fills' snapshot)
  logic [NSP-1:0] wsp_q_cc04h;          // the write's row, predecoded (below)
  // The flags, one gate open in a write's cycle and the next (when they
  // clear); mgp, each fill slot's set is last cycle's write's (DI-43, below).
  logic [NFW-1:0] mgp_q_cc04h, mgpn_cc04h;
  // ftps/ftpp are read only under ftp_q, so they load at every open of the
  // gate (one group with the flags, CG-4): under ftp_q they hold the write's.
  logic ftp_en_cc04h;
  assign ftp_en_cc04h = rst_r01h || ftfe_cc04h || ftp_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (ftp_en_cc04h) begin
      ftp_q_cc04h  <= !rst_r01h && ftfe_cc04h;
      mgp_q_cc04h  <= mgpn_cc04h & {NFW{!rst_r01h}};
      ftps_q_cc04h <= wfs_q_cc04h;
      ftpp_q_cc04h <= wsp_q_cc04h;
    end
  end
  logic           mg_cc04h;
  assign mg_cc04h = lv_cc02h && ((ftfe_cc04h && wfs_q_cc04h == set_cc02h) ||
                                 (ftp_q_cc04h && ftps_q_cc04h == set_cc02h));
  logic           mgq_q_cc04h;          // a cycle on (D1)
  always_ff @(posedge dcu_core_clk) begin
    mgq_q_cc04h <= mg_cc04h;
  end

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
  function automatic logic [NFW-1:0] lowest_f(input logic [NFW-1:0] m);
    for (int f = 0; f < NFW; f++) begin
      lowest_f[f] = m[f];
      for (int j = 0; j < f; j++) lowest_f[f] = lowest_f[f] && !m[j];
    end
  endfunction
  // The predicted way: the lowest whose fold matches (CCV_DCU_WAYPRED_SEL 0).
  function automatic logic [WAYS-1:0] lowest(input logic [WAYS-1:0] m);
    for (int w = 0; w < WAYS; w++) begin
      lowest[w] = m[w];
      for (int j = 0; j < w; j++) lowest[w] = lowest[w] && !m[j];
    end
  endfunction
  // The predicted way: the lowest matching way's index, a priority encoder.
  logic [WWY-1:0] pw_cc04h;
  always_comb begin
    pw_cc04h = '0;
    for (int w = WAYS - 1; w >= 0; w--) if (fmo_q_cc04h[w]) pw_cc04h = WWY'(w);
  end

  // The lookup a cycle on (D2): its req_id, slot, set and predicted way.
  logic lc_en_cc03h;
  assign lc_en_cc03h = v_cc03h;
  logic [WI-1:0]   rid_q_cc04h;
  (* keep *) logic [WSL-1:0] slot_q_cc04h;
  logic [WR-1:0]   set_q_cc04h;
  logic [WAYS-1:0] pw2_q_cc04h;
  logic            am2_q_cc04h;
  logic            mg2_q_cc04h;          // its fold row was read in the margin
  logic [WQ-1:0]   ei_q_cc04h;
  (* keep *) logic [WSL-1:0] mslot_q_cc04h;   // drives the output only
  always_ff @(posedge dcu_core_clk) begin
    if (lc_en_cc03h) begin
      rid_q_cc04h  <= rid_q_cc03h;
      slot_q_cc04h <= slot_q_cc03h;
      ei_q_cc04h   <= fei_cc04h;
      mslot_q_cc04h <= slot_q_cc03h;
      set_q_cc04h  <= set_q_cc03h;
      pw2_q_cc04h  <= lowest(fm_q_cc04h);
      am2_q_cc04h  <= am_q_cc04h;
      mg2_q_cc04h  <= mgq_q_cc04h;
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
  // The fill's write: the SRAM's address, we and the buffer's valid (keep).
  (* keep *) logic gfo_q_cc04h, weo_q_cc04h, gfd_q_cc04h;
  // The queue's head is CCV_DCU_BANK_AGE old (from flops, a cycle ahead).
  logic            aged_q_cc04h;
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
  logic [WRS-1:0]  ts_q_cc04h;      // the time: its low WTS bits the ages', all of it the retry's stamp
  // The answer carry (a cycle after the access; av a cycle on) and misses.
  logic            oq_q_cc04h;
  logic [WI-1:0]   orid_q_cc04h;
  logic [WSL-1:0]  oslot_q_cc04h;
  logic            av_q_cc04h, alate_q_cc04h;
  logic [WI-1:0]   arid_q_cc04h;
  logic [WSL-1:0]  aslot_q_cc04h;
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
                    gr_q_cc04h || gx_q_cc04h || gfa_q_cc04h;
  // D2: the mispredict, the misses and the loser that hit.
  logic [WWY-1:0] hw_cc04h;
  assign hw_cc04h = enc(way_cc04h);
  logic mp_cc04h;
  assign mp_cc04h = wn_q_cc04h && hit_cc04h &&   // both one-hot on a hit
                    (mg2_q_cc04h || ~|(way_cc04h & pw2_q_cc04h));   // or its row in the margin (DI-42)
  logic lh_cc04h;
  assign lh_cc04h = lq_q_cc04h && hit_cc04h;
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
    for (int e = 0; e < QD; e++) dt_cc04h[e] = ts_q_cc04h[WTS-1:0] - qts_q_cc04h[e];
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
  // A held fill's write (DI-37) goes next; an unheld one only when nothing
  // else would take the cycle. Both yield to the fold table's port when it
  // holds an entry next cycle, a held one only once (its yd flag), then it
  // wins and the port's entry waits (DI-46, MA rev 192).
  logic [NFW-1:0] yd_q_cc04h;
  logic ywf_cc04h;
  logic th_cc04h;
  assign th_cc04h = bf_cc04h && !mp_cc04h && hf_cc04h && !ywf_cc04h;
  logic ta_cc04h;
  assign ta_cc04h = bf_cc04h && !mp_cc04h && !hf_cc04h && aged_cc04h;
  logic tx_cc04h;
  assign tx_cc04h = bf_cc04h && !mp_cc04h && !hf_cc04h && !aged_cc04h && fp_q_cc04h;
  logic tn_cc04h;
  assign tn_cc04h = bf_cc04h && !mp_cc04h && !hf_cc04h && !aged_cc04h && !fp_q_cc04h && lv_cc02h;
  logic tw_cc04h;
  assign tw_cc04h = bf_cc04h && !mp_cc04h && !hf_cc04h && !aged_cc04h && !fp_q_cc04h && !lv_cc02h &&
                    wv_cc04h;
  logic tf_cc04h;
  assign tf_cc04h = th_cc04h || (bf_cc04h && !mp_cc04h && !aged_cc04h && !fp_q_cc04h &&
                                 !lv_cc02h && !wv_cc04h && af_cc04h && !ywf_cc04h);
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
  // Entry credits (an entry leaves the queue, answered or gone to MLC): a
  // waiter's access; a granted lookup's hit at D2 (a mispredict's re-read
  // reads from its own flops); a miss dcu_mshr placed, its D2 lookup's or
  // its retry's (one outcome a bank a cycle).
  logic e1_cc04h;
  assign e1_cc04h = gq_q_cc04h || (wn_q_cc04h && hit_cc04h);
  logic e2_cc04h;
  assign e2_cc04h = plc_cc04h;
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
      gfo_q_cc04h <= 1'b0;
      weo_q_cc04h <= 1'b0;
      gfd_q_cc04h <= 1'b0;
      aged_q_cc04h <= 1'b0;
      fp_q_cc04h <= 1'b0;
      gq_q_cc04h <= 1'b0;
      gr_q_cc04h <= 1'b0;
      gx_q_cc04h <= 1'b0;
      wn_q_cc04h <= 1'b0;
      lq_q_cc04h <= 1'b0;
      pq_q_cc04h <= 1'b0;
      qh_q_cc04h <= '0;
      qt_q_cc04h <= '0;
      qn_q_cc04h <= '0;
      ts_q_cc04h <= '0;
      oq_q_cc04h <= 1'b0;
      av_q_cc04h <= 1'b0;
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
      ceo_q_cc04h <= tq_cc04h || tr_cc04h || tx_cc04h || tf_cc04h;
      gfo_q_cc04h <= tf_cc04h;
      weo_q_cc04h <= (tx_cc04h && fw_q_cc04h) || tf_cc04h;
      gfd_q_cc04h <= tf_cc04h;
      aged_q_cc04h <= popq_cc04h ? ag1_cc04h : ag0_cc04h;
      fp_q_cc04h <= (fp_q_cc04h || fxv_q_cc04h) && !tx_cc04h;
      gq_q_cc04h <= tq_cc04h;
      gr_q_cc04h <= tr_cc04h;
      gx_q_cc04h <= tx_cc04h;
      wn_q_cc04h <= gn_q_cc04h && !drop_q_cc03h;
      lq_q_cc04h <= v_cc03h && !gn_q_cc04h && !drop_q_cc03h;
      pq_q_cc04h <= lh_cc04h && !popl_cc04h;
      qh_q_cc04h <= qh_q_cc04h + WQ'(popq_cc04h);
      qt_q_cc04h <= qt_q_cc04h + WQ'(push_cc04h);
      qn_q_cc04h <= qn_q_cc04h + (WQ+1)'(push_cc04h) - (WQ+1)'(popq_cc04h);
      ts_q_cc04h <= ts_q_cc04h + 1'b1;
      oq_q_cc04h <= gq_q_cc04h || gr_q_cc04h;
      av_q_cc04h <= oq_q_cc04h || (wn_q_cc04h && hit_cc04h && !mp_cc04h);
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

  // The loser that hit, its entry captured at D2 (under its own flop).
  logic p_en_cc04h;
  assign p_en_cc04h = lq_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (p_en_cc04h) begin
      prid_q_cc04h  <= rid_q_cc04h;
      pslot_q_cc04h <= slot_q_cc04h;
      pa_q_cc04h    <= {set_q_cc04h, hw_cc04h};
      pts_q_cc04h   <= ts_q_cc04h[WTS-1:0] + WTS'(AGE - 3);   // the deadline
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

  // ---- the queue entries (slice 2: DI-34 (3), DI-36) --------------------------
  // Every lookup the bank takes holds an entry from its D1 until it leaves
  // (answered, or placed in a miss buffer): MIU's entry credit for it
  // guarantees one (CCV_DCU_BANK_QDEPTH). The entry is the lowest free one,
  // picked a cycle ahead; its payload is written at D1 from its slot's
  // dcu_cap flops under the bank's own flop of the lookup (CG-5), and it is
  // valid unless dropped. (D1, not D0: the pick is bank state, and the
  // lookup's own D0 stage cannot read it.) At D3, from flops of D2: a hit leaves (a loser that hit
  // waits in the hit FIFO above, with its own copy of what its access
  // needs); a miss dcu_mshr placed leaves; one that waits, or one this bank
  // held back because it holds a waiter (bank order), is marked miss-wait
  // with its cause and joins the bank's miss-wait FIFO.
  function automatic logic [WQ-1:0] encq(input logic [QD-1:0] oh);
    encq = '0;
    for (int e = 0; e < QD; e++) if (oh[e]) encq = encq | WQ'(e);
  endfunction
  function automatic logic [QD-1:0] lowq(input logic [QD-1:0] m);
    for (int e = 0; e < QD; e++) begin
      lowq[e] = m[e];
      for (int j = 0; j < e; j++) lowq[e] = lowq[e] && !m[j];
    end
  endfunction
  logic [QD-1:0]   ev_q_cc04h;       // valid
  logic [QD-1:0]   mw_q_cc04h;       // miss-wait
  logic [2*QD-1:0] mc_q_cc04h;       // its cause (owhy's code)
  logic [QD-1:0]   fe_q_cc04h;       // the next entry: the lowest free (one-hot)
  logic [WL-1:0]   epa_q_cc04h  [QD];
  logic [WI-1:0]   erid_q_cc04h [QD];
  logic [1:0]      eop_q_cc04h  [QD];
  logic            eexc_q_cc04h [QD];
  logic [WF-1:0]   efld_q_cc04h [QD];
  assign fei_cc04h = encq(fe_q_cc04h);
  // The D1 lookup's payload, from its slot's dcu_cap.
  logic [WL-1:0] pas_cc03h;
  logic [1:0]    ops_cc03h;
  logic          excls_cc03h;
  logic [WF-1:0] folds_cc03h;
  always_comb begin
    pas_cc03h   = '0;
    ops_cc03h   = '0;
    excls_cc03h = 1'b0;
    folds_cc03h = '0;
    // MIU's coh_op as the model decodes it (dcu_block.cpp, decode()).
    for (int s = 0; s < SLOTS; s++)
      if (pk_q_cc03h[s]) begin
        pas_cc03h   = pas_cc03h | pa_cc03h[s*WL +: WL];
        ops_cc03h   = ops_cc03h | (coh_cc03h[s*WC +: WC] == WC'(0) ? 2'd0 :
                                   coh_cc03h[s*WC +: WC] == WC'(2) ? 2'd1 : 2'd2);
        excls_cc03h = excls_cc03h | excl_cc03h[s];
        folds_cc03h = folds_cc03h | fold_cc03h[s*WF +: WF];
      end
  end
  for (genvar e = 0; e < QD; e++) begin : g_e
    logic e_en_cc04h;
    assign e_en_cc04h = v_cc03h && fe_q_cc04h[e];
    always_ff @(posedge dcu_core_clk) begin
      if (e_en_cc04h) begin
        epa_q_cc04h[e]  <= pas_cc03h;
        erid_q_cc04h[e] <= rid_q_cc03h;
        eop_q_cc04h[e]  <= ops_cc03h;
        eexc_q_cc04h[e] <= excls_cc03h;
        efld_q_cc04h[e] <= folds_cc03h;
      end
    end
  end

  // D2's lookup to dcu_mshr, presented unless the bank holds a waiter by
  // then: one marked by D3 this cycle, or the D2 lookup now held back that
  // missed. (One that dcu_mshr makes wait at D3 this cycle is its own
  // bank order: its outcome flops.) A copy drives the output (keep).
  (* keep *) logic dv_q_cc04h;
  (* keep *) logic dvo_q_cc04h;
  // D3: the D2 lookup's record: there was one, it missed, it was presented.
  logic d3v_q_cc04h, d3m_q_cc04h, d3p_q_cc04h;
  logic [WQ-1:0] d3e_q_cc04h;
  // The retry: granted (R+1), its D2 (R+2), its outcome (R+3).
  logic gnt_cc04h;
  assign gnt_cc04h = rgv_cc04h && rgb_cc04h == WB'(BANK);
  logic rg1_q_cc04h, rg2_q_cc04h;
  // The miss-wait FIFO: entry indices, oldest first.
  logic [WQ*QD-1:0] mq_q_cc04h;
  logic [WQ-1:0]    mh_q_cc04h, mt_q_cc04h;
  logic [WQ-1:0]    mh1_q_cc04h;      // mh + 1, kept (off the head's load path)
  logic [WQ:0]      mn_q_cc04h;
  logic [WQ-1:0]    pwi_q_cc04h;      // the last push's entry, written a cycle on
  // The head's offer, its stamp and its payload (from flops: DI-35).
  logic             rov_q_cc04h;
  logic [WRS-1:0]   hst_q_cc04h;
  logic [WQ-1:0]    hix_q_cc04h;      // the head's entry
  logic [WL-1:0]    ypa_q_cc04h;
  logic [WI-1:0]    yrid_q_cc04h;
  logic [1:0]       yop_q_cc04h;
  logic             yexc_q_cc04h;
  logic [WF-1:0]    yfld_q_cc04h;

  // D3's events, from the record and dcu_mshr's outcome.
  logic d3x_cc04h;                     // D3 holds a miss
  assign d3x_cc04h = d3v_q_cc04h && d3m_q_cc04h;
  logic hl_cc04h, mpl_cc04h, mwt_cc04h, rpl_cc04h, rwa_cc04h;
  assign hl_cc04h  = d3v_q_cc04h && !d3m_q_cc04h;                       // a hit leaves
  assign mpl_cc04h = d3x_cc04h && d3p_q_cc04h && ov_cc04h && !owait_cc04h;  // placed
  assign mwt_cc04h = d3x_cc04h && (!d3p_q_cc04h || (ov_cc04h && owait_cc04h));  // waits
  assign rpl_cc04h = rg2_q_cc04h && ov_cc04h && !owait_cc04h;            // the retry placed
  assign rwa_cc04h = rg2_q_cc04h && ov_cc04h && owait_cc04h;             // waits again
  assign plc_cc04h = mpl_cc04h || rpl_cc04h;
  logic [1:0] cz_cc04h;                // a new waiter's cause
  assign cz_cc04h = d3p_q_cc04h ? owhy_cc04h : 2'd3;

  // The entries' state: one clock gate, enabled by an allocation, a D3
  // record or a retry's outcome.
  logic st_en_cc04h;
  assign st_en_cc04h = rst_r01h || v_cc03h || d3v_q_cc04h || rg2_q_cc04h;
  logic [QD-1:0]   evn_cc04h, mwn_cc04h;
  logic [2*QD-1:0] mcn_cc04h;
  always_comb begin
    for (int e = 0; e < QD; e++) begin
      logic al, fr, mk, rh;
      al = v_cc03h && fe_q_cc04h[e];
      rh = hix_q_cc04h == WQ'(e);
      fr = (d3e_q_cc04h == WQ'(e) && (hl_cc04h || mpl_cc04h)) || (rpl_cc04h && rh);
      mk = d3e_q_cc04h == WQ'(e) && mwt_cc04h;
      evn_cc04h[e] = rst_r01h ? 1'b0 : al ? !drop_q_cc03h : fr ? 1'b0 : ev_q_cc04h[e];
      mwn_cc04h[e] = rst_r01h ? 1'b0 : (al || fr) ? 1'b0 : mk ? 1'b1 : mw_q_cc04h[e];
      mcn_cc04h[2*e +: 2] = mk ? cz_cc04h : (rwa_cc04h && rh) ? owhy_cc04h : mc_q_cc04h[2*e +: 2];
    end
  end
  always_ff @(posedge dcu_core_clk) begin
    if (st_en_cc04h) begin
      ev_q_cc04h  <= evn_cc04h;
      mw_q_cc04h  <= mwn_cc04h;
      mc_q_cc04h  <= mcn_cc04h;
      fe_q_cc04h  <= lowq(~evn_cc04h);
      mh_q_cc04h  <= rst_r01h ? '0 : mh_q_cc04h + WQ'(pop_m_cc04h);
      mh1_q_cc04h <= rst_r01h ? WQ'(1) : mh1_q_cc04h + WQ'(pop_m_cc04h);
      mt_q_cc04h  <= rst_r01h ? '0 : mt_q_cc04h + WQ'(push_m_cc04h);
      mn_q_cc04h  <= rst_r01h ? '0 : mnn_cc04h;
      pwi_q_cc04h <= d3e_q_cc04h;
    end
  end

  logic bwd_cc04h;                     // the D2 lookup now held back missed
  assign bwd_cc04h = (wn_q_cc04h || lq_q_cc04h) && !dv_q_cc04h && !hit_cc04h;
  logic dvn_cc04h;
  assign dvn_cc04h = v_cc03h && !drop_q_cc03h && !(|mwn_cc04h) && !bwd_cc04h;
  logic d3_en_cc04h;
  assign d3_en_cc04h = wn_q_cc04h || lq_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) begin
      dv_q_cc04h  <= 1'b0;
      dvo_q_cc04h <= 1'b0;
      d3v_q_cc04h <= 1'b0;
      rg1_q_cc04h <= 1'b0;
      rg2_q_cc04h <= 1'b0;
      rov_q_cc04h <= 1'b0;
    end else begin
      dv_q_cc04h  <= dvn_cc04h;
      dvo_q_cc04h <= dvn_cc04h;
      d3v_q_cc04h <= wn_q_cc04h || lq_q_cc04h;
      rg1_q_cc04h <= gnt_cc04h;
      rg2_q_cc04h <= rg1_q_cc04h;
      rov_q_cc04h <= mnn_cc04h != '0 && !gnt_cc04h && !rg1_q_cc04h;
    end
  end
  always_ff @(posedge dcu_core_clk) begin
    if (d3_en_cc04h) begin
      d3m_q_cc04h <= !hit_cc04h;
      d3p_q_cc04h <= dv_q_cc04h;
      d3e_q_cc04h <= ei_q_cc04h;
    end
  end

  // The miss-wait FIFO: a waiter is pushed at its D3; the head pops when its
  // retry is placed. The pointers and the count are in the entries' clock
  // gate (above), and so is the last D3's entry (pwi, read only the cycle
  // after). The index is written a cycle on, under the bank's flop of the
  // push (CG-5: the push is dcu_mshr's outcome), into the slot behind the
  // tail, through a mask (one gate), and only if it changes the slot (the
  // compare made at the push): a pop reads around it.
  logic push_m_cc04h, pop_m_cc04h;
  assign push_m_cc04h = mwt_cc04h;
  assign pop_m_cc04h  = rpl_cc04h;
  logic [WQ:0] mnn_cc04h;
  assign mnn_cc04h = mn_q_cc04h + (WQ+1)'(push_m_cc04h) - (WQ+1)'(pop_m_cc04h);
  logic pw_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) pw_q_cc04h <= 1'b0;
    else          pw_q_cc04h <= push_m_cc04h && d3e_q_cc04h != mq_q_cc04h[mt_q_cc04h*WQ +: WQ];
  end
  logic [WQ-1:0] mtw_cc04h;
  assign mtw_cc04h = mt_q_cc04h - 1'b1;
  logic mqw_en_cc04h;
  assign mqw_en_cc04h = pw_q_cc04h;
  logic [WQ*QD-1:0] mqm_cc04h;
  always_comb begin
    for (int e = 0; e < QD; e++)
      mqm_cc04h[e*WQ +: WQ] = {WQ{mtw_cc04h == WQ'(e)}};
  end
  always_ff @(posedge dcu_core_clk) begin
    if (mqw_en_cc04h)
      mq_q_cc04h <= (mq_q_cc04h & ~mqm_cc04h) | ({QD{pwi_q_cc04h}} & mqm_cc04h);
  end

  // The next head (after this cycle's push and pop): the one behind a popped
  // head (the entry written now, when it is the second: mt, mh and mn move
  // together, so mt - 1 = mh + 1 just when mn = 2), or a waiter pushed into
  // an empty FIFO; its payload is loaded and
  // stamped, from flops (CG-5), at a retry's outcome (a wait again restamps
  // the same head) or at a D3 miss into an empty FIFO.
  logic [WQ-1:0] mh1_cc04h;
  assign mh1_cc04h = mh1_q_cc04h;
  logic [WQ-1:0] nh_cc04h;
  always_comb begin
    if (pop_m_cc04h) nh_cc04h = mn_q_cc04h < (WQ+1)'(2) ? d3e_q_cc04h :
                                pw_q_cc04h && mn_q_cc04h == (WQ+1)'(2) ? pwi_q_cc04h :
                                mq_q_cc04h[mh1_cc04h*WQ +: WQ];
    else             nh_cc04h = mn_q_cc04h == '0 ? d3e_q_cc04h : hix_q_cc04h;
  end
  logic hd_en_cc04h;
  assign hd_en_cc04h = rg2_q_cc04h || (d3x_cc04h && mn_q_cc04h == '0);
  logic [QD-1:0] nho_cc04h;
  always_comb begin
    for (int e = 0; e < QD; e++) nho_cc04h[e] = nh_cc04h == WQ'(e);
  end
  logic [WL-1:0] npa_cc04h;
  logic [WI-1:0] nrid_cc04h;
  logic [1:0]    nop_cc04h;
  logic          nexc_cc04h;
  logic [WF-1:0] nfld_cc04h;
  always_comb begin
    npa_cc04h = '0; nrid_cc04h = '0; nop_cc04h = '0; nexc_cc04h = 1'b0; nfld_cc04h = '0;
    for (int e = 0; e < QD; e++)
      if (nho_cc04h[e]) begin
        npa_cc04h  = npa_cc04h  | epa_q_cc04h[e];
        nrid_cc04h = nrid_cc04h | erid_q_cc04h[e];
        nop_cc04h  = nop_cc04h  | eop_q_cc04h[e];
        nexc_cc04h = nexc_cc04h | eexc_q_cc04h[e];
        nfld_cc04h = nfld_cc04h | efld_q_cc04h[e];
      end
  end
  always_ff @(posedge dcu_core_clk) begin
    if (hd_en_cc04h) begin
      hix_q_cc04h   <= nh_cc04h;
      hst_q_cc04h   <= ts_q_cc04h;
      ypa_q_cc04h   <= npa_cc04h;
      yrid_q_cc04h  <= nrid_cc04h;
      yop_q_cc04h   <= nop_cc04h;
      yexc_q_cc04h <= nexc_cc04h;
      yfld_q_cc04h <= nfld_cc04h;
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
    assign pl_en_cc04h = rst_r01h || (pu_q_cc04h && pus_q_cc04h[WR-1:1] == (WR-1)'(p)) ||
                         (fu_q_cc04h && fus_q_cc04h[WR-1:1] == (WR-1)'(p));
    // A hit's touch, then a fill's (its victim made most recently used), so
    // a fill's wins where both touch one set.
    always_comb begin
      for (int h = 0; h < 2; h++) begin
        logic [NPL-1:0] m, v, m2, v2, x;
        {m, v}   = path(puw_q_cc04h);
        {m2, v2} = path(fuw_q_cc04h);
        m  = rst_r01h ? '1 : pu_q_cc04h && pus_q_cc04h == WR'(2*p+h) ? m : '0;
        v  = rst_r01h ? '0 : v;
        m2 = !rst_r01h && fu_q_cc04h && fus_q_cc04h == WR'(2*p+h) ? m2 : '0;
        x  = (pl_q_cc04h[2*p+h] & ~m) | (v & m);
        pln_cc04h[h*NPL +: NPL] = (x & ~m2) | (v2 & m2);
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

  // A set's PLRU victim (the model's plruVictim).
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

  // ---- slice 2 part 1: the fill's victim and write (DI-39, DI-37) -----------
  // F+1  the lead: dcu_mshr's valid, for this bank, flopped (a lead, CG-5).
  // F+2  the payload on the wires (dcu_mshr's set and fold, dcu_fill's
  //      buffer) goes into a free write slot, chosen a cycle ahead, and the
  //      state the victim is chosen from is captured: the set's fold-table
  //      valid bits (a way's valid), its PLRU bits and the ways the bank's
  //      other fills reserve.
  // F+3  the victim, from those flops (so it is F+2's choice): the lowest
  //      invalid way, else the PLRU victim, else the lowest way not reserved
  //      (none is: a bank holds at most NFB fills and a set has WAYS ways).
  //      The slot takes it (until then a bypass stands in for the slot's
  //      way: the next fill's reservations, a grant now), and a cycle on, at
  //      F+4 from flops, the PLRU marks it most recently used (seen from
  //      F+5). The write is a waiter from F+3: granted for
  //      F+4 on after the lookups' waiters, or, once its access would be at
  //      F+4+K or later, held (DI-37): ahead of all but the mispredict
  //      re-read.
  // W    the SRAM writes the buffer's line at {set, way} (wdv, wdb), and the
  //      fold table takes the way's fold and valid; the slot frees.
  // The tag RF's write (DI-25's read-modify-write) is dcu_btag's, and
  // tag-stale marking, the next increment's.
  logic fl_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    fl_q_cc04h <= !rst_r01h && flv_cc03h && fbk_cc03h[BANK];
  end
  logic [WR-1:0] fs_cc03h;
  assign fs_cc03h = fwset_cc03h;
  // The write slots: valid, set, way, fold, buffer, the pick's time, held.
  // A ring: a payload takes the tail, a grant frees the head. A slot is held
  // once it is KH old, and holding is sticky, so an older slot is held no
  // later than a younger one; the oldest held slot, else the oldest slot, is
  // always the head, and slots free in the order they were taken.
  logic [NFW-1:0]  sv_q_cc04h, hd_q_cc04h, fsel_q_cc04h;
  (* keep *) logic [NFW-1:0] hp_q_cc04h;
  logic [WR-1:0]   ss_q_cc04h [NFW];
  logic [WWY-1:0]  sw_q_cc04h [NFW];
  logic [WF-1:0]   sf_q_cc04h [NFW];
  logic [WFB-1:0]  sb_q_cc04h [NFW];
  logic [WTS-1:0]  st_q_cc04h [NFW];
  logic [NSP-1:0]  sp_q_cc04h [NFW];   // the set, predecoded
  // F+2's payload, flopped; at F+3 the slot takes it (set, fold, buffer,
  // stamp), and its way when its snapshot was taken at F+2.
  logic            fl2_q_cc04h;
  logic [NFW-1:0]  nsl_q_cc04h;        // the slot F+2 took
  logic [WR-1:0]   fsn_q_cc04h;        // its set
  logic [WF-1:0]   ffd_q_cc04h;        // its fold
  logic [WFB-1:0]  ffb_q_cc04h;        // its buffer
  logic [NSP-1:0]  fsp_q_cc04h;        // its set, predecoded
  // The victim's snapshot (DI-43, MA rev 184): one a cycle, of a set outside
  // the fold table's margin (the fill's fold write this cycle or last):
  // the oldest slot still without a way, else the new payload. A slot
  // without a way (pw) reserves none and is no waiter; it sees the others'
  // reservations when its snapshot is taken.
  logic [NFW-1:0]  fpw_q_cc04h;         // a slot still without a way
  logic            vt_q_cc04h;         // a snapshot taken last cycle
  logic [NFW-1:0]  snt_q_cc04h;        // the slot F+2 took, its payload without one
  logic [NFW-1:0]  tsl_q_cc04h;        // for this slot
  logic [WR-1:0]   sns_q_cc04h;        // of this set
  logic            fu_q_cc04h;         // the victim's PLRU touch, a cycle on
  logic [WR-1:0]   fus_q_cc04h;
  logic [WWY-1:0]  fuw_q_cc04h;
  logic [WAYS-1:0] fvr_q_cc04h, rsv_q_cc04h;
  logic [NPL-1:0]  plr_q_cc04h;
  logic [WAYS-1:0] inv_cc04h;
  logic [WWY-1:0]  pvw_cc04h, vw_cc04h;
  assign inv_cc04h = ~fvr_q_cc04h & ~rsv_q_cc04h;
  assign pvw_cc04h = victim(plr_q_cc04h);
  assign vw_cc04h  = |inv_cc04h ? enc(lowest(inv_cc04h)) :
                     !rsv_q_cc04h[pvw_cc04h] ? pvw_cc04h : enc(lowest(~rsv_q_cc04h));
  logic [WAYS-1:0] vwo_cc04h;          // the same, one-hot (the reservations')
  assign vwo_cc04h = |inv_cc04h ? lowest(inv_cc04h) :
                     !rsv_q_cc04h[pvw_cc04h] ? WAYS'(1) << pvw_cc04h : lowest(~rsv_q_cc04h);
  // Each slot's fields as they stand this cycle, with those written now (the
  // bypass: the reservations, a grant now). An AND-OR, so that synthesis
  // keeps it apart from the slot flops' own enable mux.
  logic [NFW-1:0]  sn_cc04h, vn_cc04h, fhw_cc04h;
  logic [WR-1:0]   sse_cc04h [NFW];
  logic [WWY-1:0]  swe_cc04h [NFW];
  logic [WF-1:0]   sfe_cc04h [NFW];
  logic [WFB-1:0]  sbe_cc04h [NFW];
  logic [NSP-1:0]  spe_cc04h [NFW];
  assign sn_cc04h = nsl_q_cc04h & {NFW{fl2_q_cc04h}};   // the payload's slot
  assign vn_cc04h = tsl_q_cc04h & {NFW{vt_q_cc04h}};    // the way's
  assign fhw_cc04h = vn_cc04h | (~fpw_q_cc04h & ~sn_cc04h); // it has its way (if valid)
  always_comb begin
    for (int f = 0; f < NFW; f++) begin
      sse_cc04h[f] = (fsn_q_cc04h & {WR{sn_cc04h[f]}})  | (ss_q_cc04h[f] & {WR{!sn_cc04h[f]}});
      swe_cc04h[f] = (vw_cc04h    & {WWY{vn_cc04h[f]}}) | (sw_q_cc04h[f] & {WWY{!vn_cc04h[f]}});
      sfe_cc04h[f] = (ffd_q_cc04h & {WF{sn_cc04h[f]}})  | (sf_q_cc04h[f] & {WF{!sn_cc04h[f]}});
      sbe_cc04h[f] = (ffb_q_cc04h & {WFB{sn_cc04h[f]}}) | (sb_q_cc04h[f] & {WFB{!sn_cc04h[f]}});
      spe_cc04h[f] = (fsp_q_cc04h & {NSP{sn_cc04h[f]}}) | (sp_q_cc04h[f] & {NSP{!sn_cc04h[f]}});
    end
  end
  // Which snapshot: each waiting slot's set against the margin, the oldest
  // (the ring from its head) that is outside it, else the new payload's.
  logic [NFW-1:0]  pe_cc04h, ps_cc04h, hpm_cc04h;
  logic [NFW-1:0]  old_cc04h [NFW];
  (* keep *) logic [NFW-1:0] hpo_q_cc04h;   // the head, a copy for the pick's order
  logic            mgn_cc04h;
  // The payload's, a cycle ahead (F+2, from its set on the wires): mwn, its
  // set is the next write's (the one captured now, else the one held);
  // mgn1, this cycle's write is to its set.
  logic            mwn_q_cc04h, mgn1_q_cc04h;
  logic [NSP-1:0]  fsd_cc03h;          // the payload's set, predecoded
  logic            wf_en_cc04h;        // the next write's fields captured (below)
  logic [NSP-1:0]  hsp_cc04h;           // the head's set, predecoded
  always_comb begin
    hsp_cc04h = '0;
    for (int f = 0; f < NFW; f++) hsp_cc04h = hsp_cc04h | (spe_cc04h[f] & {NSP{hp_q_cc04h[f]}});
  end
  logic mwn_en_cc04h;
  assign mwn_en_cc04h = fl_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (mwn_en_cc04h) begin
      mwn_q_cc04h  <= wf_en_cc04h ? psame(hsp_cc04h, fsd_cc03h) : psame(wsp_q_cc04h, fsd_cc03h);
      mgn1_q_cc04h <= ftfe_cc04h && psame(wsp_q_cc04h, fsd_cc03h);
    end
  end
  logic [NFW-1:0]  mwq_q_cc04h;
  always_comb begin
    for (int f = 0; f < NFW; f++) mgpn_cc04h[f] = ftfe_cc04h && psame(wsp_q_cc04h, spe_cc04h[f]);
  end
  always_comb begin
    // (a waiting slot's margin from flops, a cycle ahead: mwq, its set is
    // the write's, captured with the write's fields; mgp, last cycle's write
    // was to its set. The payload F+3 writes, which F+2 found in the margin:
    // one compare, from F+2's set.)
    mgn_cc04h = (ftfe_cc04h && mwn_q_cc04h) || mgn1_q_cc04h;
    for (int f = 0; f < NFW; f++)
      pe_cc04h[f] = (sv_q_cc04h[f] && fpw_q_cc04h[f] && !vn_cc04h[f] &&
                     !((ftfe_cc04h && mwq_q_cc04h[f]) || mgp_q_cc04h[f])) ||
                    (snt_q_cc04h[f] && !mgn_cc04h);   // (valid, and no way yet)
    // (the ring's order from the head, from its flop alone: t is older
    // than f when t is at or past the head and f is not, or both are on
    // one side and t comes first)
    hpm_cc04h[0] = hpo_q_cc04h[0];
    for (int f = 1; f < NFW; f++) hpm_cc04h[f] = hpm_cc04h[f-1] | hpo_q_cc04h[f];
    for (int f = 0; f < NFW; f++)
      for (int t = 0; t < NFW; t++)
        old_cc04h[f][t] = t != f && ((hpm_cc04h[t] && !hpm_cc04h[f]) ||
                                     (hpm_cc04h[t] == hpm_cc04h[f] && t < f));
    for (int f = 0; f < NFW; f++) ps_cc04h[f] = pe_cc04h[f] && !(|(pe_cc04h & old_cc04h[f]));
  end
  logic            pa_cc04h, nm_cc04h, tk_cc04h;
  assign pa_cc04h = |pe_cc04h;
  assign fsd_cc03h = pdec(fs_cc03h);
  assign nm_cc04h = (ftfe_cc04h && psame(wsp_q_cc04h, fsd_cc03h)) ||
                    (ftp_q_cc04h && psame(ftpp_q_cc04h, fsd_cc03h));
  assign tk_cc04h = pa_cc04h || (fl_q_cc04h && !nm_cc04h);
  logic [WR-1:0]   sset_cc04h;
  always_comb begin
    sset_cc04h = fs_cc03h & {WR{!pa_cc04h}};
    for (int f = 0; f < NFW; f++)
      sset_cc04h = sset_cc04h | (sse_cc04h[f] & {WR{ps_cc04h[f]}});
  end
  logic [NSP-1:0]  ssp_cc04h;          // the same, predecoded: the row select
  always_comb begin
    ssp_cc04h = fsd_cc03h & {NSP{!pa_cc04h}};
    for (int f = 0; f < NFW; f++)
      ssp_cc04h = ssp_cc04h | (spe_cc04h[f] & {NSP{ps_cc04h[f]}});
  end
  // The snapshot: the set's rows and the reservations (the slots that have
  // their ways, and the write at W, held until the snapshot sees it: MA rev
  // 184's closing of the gap between a grant and its write's visibility).
  logic            rhv_cc04h;
`ifdef CCV_CTL_BCTL_REL_AT_GRANT
  assign rhv_cc04h = 1'b0;             // the control: released at the grant
`else
  assign rhv_cc04h = gfa_q_cc04h;
`endif
  logic [NFW-1:0]  rk_cc04h;           // the slots that reserve
`ifdef CCV_CTL_BCTL_REL_AT_GRANT
  assign rk_cc04h = sv_q_cc04h & fhw_cc04h & ~gf_cc04h;
`else
  assign rk_cc04h = sv_q_cc04h & fhw_cc04h;
`endif
  logic [WAYS-1:0] fvr_cc04h, rsv_cc04h;
  logic [NPL-1:0]  plr_cc04h;
  always_comb begin
    fvr_cc04h = '0;
    plr_cc04h = '0;
    for (int r = 0; r < NSET; r++)
      if (ssp_cc04h[NRL + (r >> WRL)] && ssp_cc04h[r & (NRL - 1)]) begin
        for (int w = 0; w < WAYS; w++) fvr_cc04h[w] = fvr_cc04h[w] | ft_q_cc03h[r][w*WFE + WF];
        plr_cc04h = plr_cc04h | pl_q_cc04h[r];
      end
  end
  // The reservations, each candidate's beside the pick (each slot's, the
  // payload's) and then selected by it; the way chosen this cycle (vn's)
  // joins last, by whether its set is the pick's.
  logic [WAYS-1:0] rwo_cc04h [NFW];
  logic [WAYS-1:0] rsc_cc04h [NFW];
  logic [WAYS-1:0] rsn_cc04h, wwo_cc04h;
  logic [NFW-1:0]  vsc_cc04h;
  logic            vsn_cc04h, vsl_cc04h;
  always_comb begin
    wwo_cc04h = WAYS'(1) << wfw_q_cc04h;
    for (int f = 0; f < NFW; f++) rwo_cc04h[f] = WAYS'(1) << sw_q_cc04h[f];
    rsn_cc04h = wwo_cc04h & {WAYS{rhv_cc04h && psame(wsp_q_cc04h, fsd_cc03h)}};
    vsn_cc04h = 1'b0;
    for (int f = 0; f < NFW; f++) begin
      if (rk_cc04h[f] && !vn_cc04h[f] && psame(spe_cc04h[f], fsd_cc03h))
        rsn_cc04h = rsn_cc04h | rwo_cc04h[f];
      vsn_cc04h = vsn_cc04h || (rk_cc04h[f] && vn_cc04h[f] && psame(spe_cc04h[f], fsd_cc03h));
    end
    for (int g = 0; g < NFW; g++) begin
      rsc_cc04h[g] = wwo_cc04h & {WAYS{rhv_cc04h && psame(wsp_q_cc04h, spe_cc04h[g])}};
      vsc_cc04h[g] = 1'b0;
      for (int f = 0; f < NFW; f++) begin
        if (rk_cc04h[f] && !vn_cc04h[f] && psame(spe_cc04h[f], spe_cc04h[g]))
          rsc_cc04h[g] = rsc_cc04h[g] | rwo_cc04h[f];
        vsc_cc04h[g] = vsc_cc04h[g] || (rk_cc04h[f] && vn_cc04h[f] && psame(spe_cc04h[f], spe_cc04h[g]));
      end
    end
    rsv_cc04h = rsn_cc04h & {WAYS{!pa_cc04h}};
    for (int g = 0; g < NFW; g++) rsv_cc04h = rsv_cc04h | (rsc_cc04h[g] & {WAYS{ps_cc04h[g]}});
    vsl_cc04h = (vsn_cc04h && !pa_cc04h) || |(vsc_cc04h & ps_cc04h);
    rsv_cc04h = rsv_cc04h | (vwo_cc04h & {WAYS{vsl_cc04h}});
  end
  logic [NFW-1:0] nw_cc04h;
  assign nw_cc04h = fsel_q_cc04h & {NFW{fl_q_cc04h}};
  logic fv_en_cc04h;
  assign fv_en_cc04h = fl_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (fv_en_cc04h) begin
      nsl_q_cc04h <= fsel_q_cc04h;
      fsn_q_cc04h <= fs_cc03h;
      ffd_q_cc04h <= fwfold_cc03h;
      ffb_q_cc04h <= fwb_cc03h;
      fsp_q_cc04h <= fsd_cc03h;
    end
  end
  // (opened from flops alone, CG-5: whenever a slot or the payload may take
  // the snapshot; vt says whether one did)
  logic tk_en_cc04h;
  assign tk_en_cc04h = fl_q_cc04h ||
                       |((sv_q_cc04h & fpw_q_cc04h & ~vn_cc04h) | snt_q_cc04h);
  always_ff @(posedge dcu_core_clk) begin
    if (tk_en_cc04h) begin
      tsl_q_cc04h <= pa_cc04h ? ps_cc04h : fsel_q_cc04h;
      sns_q_cc04h <= sset_cc04h;
      fvr_q_cc04h <= fvr_cc04h;
      plr_q_cc04h <= plr_cc04h;
      rsv_q_cc04h <= rsv_cc04h;
    end
  end
  // The slot's fields, one gate a slot: at F+3 the payload's (its stamp
  // F+2's), and its way when its snapshot's victim is known.
  for (genvar f = 0; f < NFW; f++) begin : g_fw
    logic sw_en_cc04h;
    assign sw_en_cc04h = sn_cc04h[f] || vn_cc04h[f];
    always_ff @(posedge dcu_core_clk) begin
      if (sw_en_cc04h) begin
        ss_q_cc04h[f] <= sse_cc04h[f];
        sp_q_cc04h[f] <= spe_cc04h[f];
        sf_q_cc04h[f] <= sfe_cc04h[f];
        sb_q_cc04h[f] <= sbe_cc04h[f];
        sw_q_cc04h[f] <= swe_cc04h[f];
        st_q_cc04h[f] <= sn_cc04h[f] ? ts_q_cc04h[WTS-1:0] - 1'b1 : st_q_cc04h[f];
      end
    end
  end
  // The waiter: the head (the oldest slot; held, if any is), once it has its
  // way.
  logic [NFW-1:0] hc_cc04h, ch_cc04h;
  logic hf_cc04h, af_cc04h;
  assign ch_cc04h = hp_q_cc04h & sv_q_cc04h & fhw_cc04h;
  assign af_cc04h = |ch_cc04h;
  assign hc_cc04h = sv_q_cc04h & hd_q_cc04h;
  assign hf_cc04h = |hc_cc04h && af_cc04h;
  // The slots' next state: a granted one frees, a payload fills one.
  logic [NFW-1:0] gf_cc04h, svn_cc04h;
  assign gf_cc04h  = ch_cc04h & {NFW{tf_cc04h}};
  assign svn_cc04h = (sv_q_cc04h & ~gf_cc04h) | nw_cc04h;
  // The yield to the fold table's port (above): a held fill once.
`ifdef CCV_CTL_BCTL_ALWAYS_YIELD
  assign ywf_cc04h = pwn_cc02h && af_cc04h;   // the control: a held fill yields every time
`else
  assign ywf_cc04h = pwn_cc02h && !(hf_cc04h && |(ch_cc04h & yd_q_cc04h));
`endif
  // A held fill that yields marks its slot (cleared by the slot's next fill).
  logic yev_cc04h;
  assign yev_cc04h   = bf_cc04h && !mp_cc04h && hf_cc04h && ywf_cc04h;
  logic yd_en_cc04h;
  assign yd_en_cc04h = rst_r01h || yev_cc04h || fl_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (yd_en_cc04h)
      for (int f = 0; f < NFW; f++)
        yd_q_cc04h[f] <= !rst_r01h && !nw_cc04h[f] && (yd_q_cc04h[f] || (yev_cc04h && ch_cc04h[f]));
  end
  logic [WTS-1:0] sdt_cc04h [NFW];
  always_comb begin
    for (int f = 0; f < NFW; f++) sdt_cc04h[f] = ts_q_cc04h[WTS-1:0] - st_q_cc04h[f];
  end
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) begin
      sv_q_cc04h   <= '0;
      hd_q_cc04h   <= '0;
      fpw_q_cc04h   <= '0;
      fl2_q_cc04h  <= 1'b0;
      vt_q_cc04h   <= 1'b0;
      fu_q_cc04h   <= 1'b0;
      gfa_q_cc04h  <= 1'b0;
    end else begin
      sv_q_cc04h   <= svn_cc04h;
      // (the slot F+3 writes is 1 old: its stamp is not yet written)
      for (int f = 0; f < NFW; f++)
        hd_q_cc04h[f] <= sv_q_cc04h[f] && !gf_cc04h[f] && !sn_cc04h[f] &&
                         (hd_q_cc04h[f] || sdt_cc04h[f] >= WTS'(KH));
      fpw_q_cc04h   <= (fpw_q_cc04h | sn_cc04h) & ~vn_cc04h;
      fl2_q_cc04h  <= fl_q_cc04h;
      vt_q_cc04h   <= tk_cc04h;
      fu_q_cc04h   <= vt_q_cc04h;
      gfa_q_cc04h  <= tf_cc04h;
    end
  end
  // The pointers rotate one slot on a payload (fsel), a grant (hp, hpo),
  // each gated: fsel with the stamps' slot it loads, open on a payload and
  // while a stamp slot is set; the heads on the write fields' gate, which
  // holds every grant (tf needs wf_en's terms; CG-5).
  logic fs_en_cc04h;
  assign fs_en_cc04h = rst_r01h || fl_q_cc04h || |snt_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (fs_en_cc04h) begin
      fsel_q_cc04h <= rst_r01h ? NFW'(1) :
                      ({fsel_q_cc04h[NFW-2:0], fsel_q_cc04h[NFW-1]} & {NFW{fl_q_cc04h}}) |
                      (fsel_q_cc04h & {NFW{!fl_q_cc04h}});
      snt_q_cc04h  <= fsel_q_cc04h & {NFW{!rst_r01h && fl_q_cc04h && (pa_cc04h || nm_cc04h)}};
    end
  end
  logic hp_en_cc04h;
  assign hp_en_cc04h = rst_r01h || wf_en_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (hp_en_cc04h) begin
      hp_q_cc04h  <= rst_r01h ? NFW'(1) :
                     ({hp_q_cc04h[NFW-2:0], hp_q_cc04h[NFW-1]} & {NFW{tf_cc04h}}) |
                     (hp_q_cc04h & {NFW{!tf_cc04h}});
      hpo_q_cc04h <= rst_r01h ? NFW'(1) :
                     ({hp_q_cc04h[NFW-2:0], hp_q_cc04h[NFW-1]} & {NFW{tf_cc04h}}) |
                     (hp_q_cc04h & {NFW{!tf_cc04h}});
    end
  end
  logic fu_en_cc04h;
  assign fu_en_cc04h = vt_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (fu_en_cc04h) begin
      fus_q_cc04h <= sns_q_cc04h;
      fuw_q_cc04h <= vw_cc04h;
    end
  end
  // The next write's fields, in every cycle a write may be granted (from
  // flops, CG-5: the grant's terms but the mispredict and the D2 loser's
  // hit, which are inputs); a grant reads them at W.
  assign wf_en_cc04h = bf_cc04h && af_cc04h &&
                       (hf_cc04h || (!aged_cc04h && !fp_q_cc04h && !lv_cc02h && !qne_cc04h &&
                                     !pq_q_cc04h));
  // Whether the head's fold-table write would change its entry, a cycle
  // ahead from flops: not when the way already holds {valid, the fold} (a
  // line of the same fold refilled), unless the head is the slot F+3 writes
  // now (its fields on the bypass) or a lookup's fold write lands in its set
  // now (the entry then read is not W's). Unchanged, the row stays ungated.
  logic [WR-1:0]  hs_cc04h;
  logic [WWY-1:0] hdw_cc04h;
  logic [WF-1:0]  hfo_cc04h;
  logic [WFE-1:0] he_cc04h;
  logic [NSP-1:0] hsq_cc04h;            // the head's set, predecoded (its row select)
  logic [WAYS*WFE-1:0] hrw_cc04h;       // its row
  logic           chg_cc04h;
  always_comb begin
    hs_cc04h = '0; hdw_cc04h = '0; hfo_cc04h = '0; hsq_cc04h = '0;
    for (int f = 0; f < NFW; f++)
      if (hp_q_cc04h[f]) begin
        hs_cc04h  = hs_cc04h  | ss_q_cc04h[f];
        hsq_cc04h = hsq_cc04h | sp_q_cc04h[f];
        hdw_cc04h  = hdw_cc04h  | sw_q_cc04h[f];
        hfo_cc04h = hfo_cc04h | sf_q_cc04h[f];
      end
    // (the row first, then the way: the way's select drives one row)
    hrw_cc04h = '0;
    for (int r = 0; r < NSET; r++)
      if (hsq_cc04h[NRL + (r >> WRL)] && hsq_cc04h[r & (NRL - 1)])
        hrw_cc04h = hrw_cc04h | ft_q_cc03h[r];
    he_cc04h = hrw_cc04h[hdw_cc04h*WFE +: WFE];
    chg_cc04h = |(hp_q_cc04h & (sn_cc04h | vn_cc04h)) || he_cc04h != {1'b1, hfo_cc04h} ||
                (pw_cc02h && pes_q_cc02h[0] == hs_cc04h);
  end
  (* keep *) logic [WR+WWY-1:0] wfa_q_cc04h;   // the SRAM's address
  logic [WFB-1:0] wfb_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (wf_en_cc04h) begin
      for (int f = 0; f < NFW; f++)
        if (hp_q_cc04h[f]) begin
          wfa_q_cc04h <= {sse_cc04h[f], swe_cc04h[f]};
          wfs_q_cc04h <= sse_cc04h[f];
          wsp_q_cc04h <= spe_cc04h[f];
          for (int t = 0; t < NFW; t++) mwq_q_cc04h[t] <= psame(spe_cc04h[f], spe_cc04h[t]);
          wfw_q_cc04h <= swe_cc04h[f];
          wff_q_cc04h <= sfe_cc04h[f];
          wfb_q_cc04h <= sbe_cc04h[f];
          wfc_q_cc04h <= chg_cc04h;
        end
    end
  end

  // ---- the outputs ----------------------------------------------------------
  // The SRAM: a new lookup's {set, predicted way}, else the flopped access.
  // The grants are one-hot (at most one of new, fix, re-read, waiter), so the
  // select is an AND-OR; with none, ce is low and sa is unread.
  assign sa_cc04h      = ({set_q_cc03h, pw_cc04h} & {(WR+WWY){gno_q_cc04h}}) |
                         (fa_q_cc04h & {(WR+WWY){gxo_q_cc04h}}) |
                         (ra_q_cc04h & {(WR+WWY){gro_q_cc04h}}) |
                         (ga_q_cc04h & {(WR+WWY){gqo_q_cc04h}}) |
                         (wfa_q_cc04h & {(WR+WWY){gfo_q_cc04h}});
  assign ce_cc04h      = (gnc_q_cc04h && !dropo_q_cc03h && amo_q_cc04h) || ceo_q_cc04h;
  assign we_cc04h      = weo_q_cc04h;
  assign wdv_cc04h     = gfd_q_cc04h;
  assign wdb_cc04h     = wfb_q_cc04h;
  assign fxg_cc04h     = gxg_q_cc04h;
  assign av_cc04h      = av_q_cc04h;
  assign arid_cc04h    = arid_q_cc04h;
  assign aslot_cc04h   = aslot_q_cc04h;
  assign alate_cc04h   = alate_q_cc04h;
  assign dv_cc04h      = dvo_q_cc04h;
  assign mslot_cc04h   = mslot_q_cc04h;
  assign rov_cc04h     = rov_q_cc04h;
  assign rstp_cc04h    = hst_q_cc04h;
  assign rpa_cc04h     = ypa_q_cc04h;
  assign rrid_cc04h    = yrid_q_cc04h;
  assign rop_cc04h     = yop_q_cc04h;
  assign rexcl_cc04h   = yexc_q_cc04h;
  assign rfold_cc04h   = yfld_q_cc04h;
  assign rsti_cc04h    = '0;                 // part 3's stores
  assign ent_ret_cc04h = er_q_cc04h;

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
  // No tag hit without a fold match (MIU's pa_fold is the tags' fold), but
  // where the fold row was read inside the fill's margin (DI-42).
  `CCV_ASSERT(bctl_hit_needs_fold, !(wn_q_cc04h && hit_cc04h && !am2_q_cc04h && !mg2_q_cc04h))
  // The fold table's second writer (DA's ruling (b) on DI-41, OA-479): the
  // fill's write never meets the store's fold write at the one write port;
  // no granted lookup answers from a fold row read in the fill's write cycle
  // or the next (it takes the re-read, DI-42); no fill's victim snapshot
  // reads such a row.
  `CCV_ASSERT(bctl_ft_one_writer, !(gfa_q_cc04h && pw_cc02h))
  // The port (DI-46): its credits hold it to PD entries; its head waits for
  // at most NFW fills (each one that yielded to it once); a held fill waits
  // at most HW cycles (DI-37: K + gap + 1 + 11 + 1 in the model's terms).
  `CCV_ASSERT(bctl_port_overflow, !(fwe_q_cc01h && &pvs_cc02h))
  // The wait counters below are the assertions' own state, gated like any
  // register: open while a head waits or a count is left to clear.
  logic [3:0] phw_q_cc03h;
  logic       phw_en_cc03h, phwc_cc02h;
  assign phw_en_cc03h = rst_r01h || pv_q_cc02h[0] || |phw_q_cc03h;
  assign phwc_cc02h   = rst_r01h || !pv_q_cc02h[0] || pw_cc02h;
  always_ff @(posedge dcu_core_clk) begin
    if (phw_en_cc03h)
      phw_q_cc03h <= phwc_cc02h ? 4'd0 : phw_q_cc03h + 4'(phw_q_cc03h != 4'hf);
  end
  `CCV_ASSERT(bctl_port_wait, phw_q_cc03h <= 4'(NFW))
  localparam int HW = 4 * NFW;
  logic [5:0] hw_q_cc04h [NFW];
  logic       hw_ok_cc04h, hw_en_cc04h, hwnz_cc04h;
  always_comb begin
    hwnz_cc04h = 1'b0;
    for (int f = 0; f < NFW; f++) hwnz_cc04h = hwnz_cc04h || (|hw_q_cc04h[f]);
  end
  assign hw_en_cc04h = rst_r01h || |(sv_q_cc04h & hd_q_cc04h) || hwnz_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (hw_en_cc04h)
      for (int f = 0; f < NFW; f++)
        hw_q_cc04h[f] <= (rst_r01h || !(sv_q_cc04h[f] && hd_q_cc04h[f]) || gf_cc04h[f])
                       ? 6'd0 : hw_q_cc04h[f] + 6'(hw_q_cc04h[f] != 6'h3f);
  end
  always_comb begin
    hw_ok_cc04h = 1'b1;
    for (int f = 0; f < NFW; f++) if (hw_q_cc04h[f] > 6'(HW)) hw_ok_cc04h = 1'b0;
  end
  `CCV_ASSERT(bctl_fill_held_wait, hw_ok_cc04h)
  `CCV_ASSERT(bctl_ft_lookup_margin, !(wn_q_cc04h && hit_cc04h && mg2_q_cc04h && !mp_cc04h))
  `CCV_ASSERT(bctl_ft_fill_margin,
              !(tk_cc04h && ((ftfe_cc04h && wfs_q_cc04h == sset_cc04h) ||
                             (ftp_q_cc04h && ftps_q_cc04h == sset_cc04h))))
  // No two fills hold one way (MA rev 184): no two slots with their ways, nor
  // a slot and the write at W, name the same {set, way}.
  logic one_fpw_cc04h;
  always_comb begin
    one_fpw_cc04h = 1'b1;
    for (int f = 0; f < NFW; f++) begin
      if (sv_q_cc04h[f] && fhw_cc04h[f] && gfa_q_cc04h &&
          sse_cc04h[f] == wfs_q_cc04h && swe_cc04h[f] == wfw_q_cc04h)
        one_fpw_cc04h = 1'b0;
      for (int t = f + 1; t < NFW; t++)
        if (sv_q_cc04h[f] && fhw_cc04h[f] && sv_q_cc04h[t] && fhw_cc04h[t] &&
            sse_cc04h[f] == sse_cc04h[t] && swe_cc04h[f] == swe_cc04h[t])
          one_fpw_cc04h = 1'b0;
    end
  end
  `CCV_ASSERT(bctl_one_fill_per_way, one_fpw_cc04h)
  // A slot waits for its snapshot at most 2 x (NFW - 1) + 1 cycles from F+2
  // (MA rev 184): only slots with their ways write a set, oldest first.
  logic snap_wait_ok_cc04h;
  always_comb begin
    snap_wait_ok_cc04h = 1'b1;
    for (int f = 0; f < NFW; f++)
      if (sv_q_cc04h[f] && fpw_q_cc04h[f] && sdt_cc04h[f] > WTS'(3 * (NFW - 1) + 2))
        snap_wait_ok_cc04h = 1'b0;
  end
  `CCV_ASSERT(bctl_snap_wait, snap_wait_ok_cc04h)
  // The credits hold the queue to its depth (MA-25).
  `CCV_ASSERT(bctl_queue_depth, !(push_cc04h && !popq_cc04h && qn_q_cc04h == (WQ+1)'(QD)))
  // Every lookup finds an entry (its credit), and dcu_mshr's outcomes come
  // where expected, one a bank a cycle.
  `CCV_ASSERT(bctl_entry_free, !v_cc03h || |fe_q_cc04h)
  `CCV_ASSERT(bctl_outcome_d3, !(d3x_cc04h && d3p_q_cc04h) || ov_cc04h)
  `CCV_ASSERT(bctl_outcome_retry, !rg2_q_cc04h || ov_cc04h)
  `CCV_ASSERT(bctl_outcome_one, !(d3x_cc04h && d3p_q_cc04h && rg2_q_cc04h))
  `CCV_ASSERT(bctl_outcome_stray, !ov_cc04h || (d3x_cc04h && d3p_q_cc04h) || rg2_q_cc04h)
  `CCV_ASSERT(bctl_grant_offered, !gnt_cc04h || rov_q_cc04h)
  `CCV_ASSERT(bctl_waiters, mn_q_cc04h == (WQ+1)'($countones(mw_q_cc04h)))
  // A fill finds a slot and a way no other fill reserves (DI-39).
  `CCV_ASSERT(bctl_mq_second, (mtw_cc04h == mh1_cc04h) == (mn_q_cc04h == (WQ+1)'(2)))
  `CCV_ASSERT(bctl_fill_same, !gfa_q_cc04h || wfc_q_cc04h ||
                              ft_q_cc03h[wfs_q_cc04h][wfw_q_cc04h*WFE +: WFE] == {1'b1, wff_q_cc04h})
  `CCV_ASSERT(bctl_fill_slot, !fl_q_cc04h || !(|(fsel_q_cc04h & sv_q_cc04h)))
  `CCV_ASSERT(bctl_fill_victim, !fl2_q_cc04h || !rsv_q_cc04h[vw_cc04h])
  `CCV_ASSERT(bctl_fill_grant_one, !tf_cc04h || $onehot(ch_cc04h))
  `CCV_ASSERT(bctl_tag_onehot, !(wn_q_cc04h || lq_q_cc04h) || $onehot0(way_cc04h))

endmodule
`undef CCV_CLK
`undef CCV_RST
