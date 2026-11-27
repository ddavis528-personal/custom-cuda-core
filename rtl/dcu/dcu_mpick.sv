//===-- dcu_mpick.sv - DCU's cross-bank picks: the retry grant, the MLC request --===//
//
// Spec: docs/design-snapshots/dcu-spec.md (live: CCV per-block architecture
//       specs, DCU tab rev 150: "Miss buffers (dcu_mshr)" and the module
//       partition's dcu_mpick row; MA-31 B, MA-34). DI-35 (the retry grant),
//       DI-64 (the miss pick's stamp) and DI-65 (passing over last cycle's
//       bank) record the choices below.
//
// One instance, between the 8 banks' dcu_bctl and dcu_mshr and the channel
// ccv_dcu_mlc_req.
//
//   The retry (DI-35, moved here from dcu_mshr unchanged). At R each bank's
//   dcu_bctl offers its oldest miss-wait waiter (valid and a 10-bit stamp
//   of when it became the head). The oldest offer, compared modulo 2^10,
//   ties to the lowest bank, is granted at R+1 (rgv/rgb, from flops); the
//   bank granted at R is passed over at R+1, since it learns of its grant
//   only then. At R+1 the granted bank's payload, from its flops, is
//   captured here; at R+2, the retry's D2, it goes to the bank's dcu_mshr
//   (the payload, from flops; the bank's own flop of rgv/rgb is its valid).
//
//   The MLC request (DI-64, DI-65). Each bank's dcu_mshr offers its oldest
//   unsent entry from flops, picked a cycle ahead (hv, hstp: a 10-bit stamp
//   taken at its D2), a cycle after its D2 at the earliest (no straight
//   offer: DI-66, MA rev 227). The pick at T: the oldest head by stamp
//   modulo 2^10, ties to the lowest bank. A bank sent from at T-1 is passed
//   over at T: its head flops still name the entry sent. The valid
//   launches at T+1 (H+6 at the earliest for a lookup's miss) if the channel holds a
//   credit, counting the send of T-1, which the count takes a cycle late
//   (DI-34 update 2). At T+1 the sent bank's dcu_mshr learns of its send
//   (snt, one-hot, from flops) and offers that entry's payload from its
//   flops; it is captured here and launches at T+2 (req_id {bank, entry}).
//   Writebacks (part 2), first in the request order, are not here yet.
//
// Stage tags: the retry's offers and pick 02, its grant and capture 03, its
// D2 port 04; the MLC pick and its state 05, the payload 06.
//
// The reference is the DCU model (sim/dcu/dcu_core.cpp: retryWaits() and
// the MLC request in step()), and test/dcu/mpick_tb.cpp holds this module
// to a value model of both picks.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK dcu_core_clk
`define CCV_RST rst_r01h
module dcu_mpick #(
  parameter  int NBK   = ccv_params_pkg::CCV_DCU_BANKS,              // 8
  parameter  int WI    = ccv_prov_pkg::CCV_P_W_REQ_MIU_DCU,          // MIU req_id, 8
  parameter  int WA    = ccv_prov_pkg::CCV_P_W_PA,                   // PA, 48
  parameter  int WO    = $clog2(ccv_prov_pkg::CCV_P_LINE_BYTES),     // line offset, 7
  parameter  int WF    = ccv_prov_pkg::CCV_DCU_WAYPRED_BITS,         // fold, 4
  parameter  int WC    = ccv_prelim_pkg::CCV_L_W_COH_OP,             // coh_op, 4
  parameter  int WE    = ccv_prov_pkg::CCV_P_W_REQ_DCU_MLC,          // MLC req_id, 7
  parameter  int WST   = 4,                                          // store-data index
  parameter  int NCR   = ccv_params_pkg::CCV_CREDIT_DEPTH,           // req credits, 4
  parameter  int WCID  = ccv_params_pkg::CCV_W_CORE_ID,              // 2
  parameter  int CID   = ccv_prov_pkg::CCV_P_CORE_ID,
  parameter  int WTS   = 10,                                         // stamps (DI-35, DI-64)
  localparam int WL    = WA - WO,                                    // line, 41
  localparam int WB    = NBK > 1 ? $clog2(NBK) : 1,                  // 3
  localparam int WEB   = WE - WB,                                    // a bank's entry, 4
  localparam int WCR   = $clog2(NCR + 1)                             // 3
) (
  input  logic                   dcu_core_clk,
  input  logic                   rst_n,

  // The retry: each bank's offer from dcu_bctl's flops (R), the grant
  // (R+1), the granted bank's payload (R+1) and the retry's D2 port (R+2).
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
  output logic [WL-1:0]          rpa_cc04h,
  output logic [WI-1:0]          rrid_cc04h,
  output logic [1:0]             rop_cc04h,
  output logic                   rexcl_cc04h,
  output logic [WF-1:0]          rfold_cc04h,
  output logic [WST-1:0]         rsti_cc04h,

  // The MLC request: each bank's offers (T), the bank sent from (T+1), its
  // payload (T+1), the channel's credit, valid (T+1) and payload (T+2).
  input  logic [NBK-1:0]         hv_cc05h,
  input  logic [NBK*WTS-1:0]     hstp_cc05h,
  output logic [WB-1:0]          sbk_cc05h,      // the bank sent from, under mv_cc05h
  input  logic [NBK*WEB-1:0]     pid_cc05h,
  input  logic [NBK*WL-1:0]      ppa_cc05h,
  input  logic [NBK*WC-1:0]      pcoh_cc05h,
  input  logic                   mcr_cc04h,
  output logic                   mv_cc05h,
  output logic [WE-1:0]          mrid_cc06h,
  output logic [WA-1:0]          mpa_cc06h,
  output logic [WC-1:0]          mcoh_cc06h,
  output logic [WCID-1:0]        mcid_cc06h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge dcu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

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

  // The granted bank's payload, captured under the grant, for the retry's
  // D2 in that bank's dcu_mshr (whose own flop of rgv/rgb is its valid).
  logic [WL-1:0]  rpa_q_cc04h;
  logic [WI-1:0]  rrid_q_cc04h;
  logic [1:0]     rop_q_cc04h;
  logic           rexcl_q_cc04h;
  logic [WF-1:0]  rfold_q_cc04h;
  logic [WST-1:0] rsti_q_cc04h;
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
  assign rpa_cc04h   = rpa_q_cc04h;
  assign rrid_cc04h  = rrid_q_cc04h;
  assign rop_cc04h   = rop_q_cc04h;
  assign rexcl_cc04h = rexcl_q_cc04h;
  assign rfold_cc04h = rfold_q_cc04h;
  assign rsti_cc04h  = rsti_q_cc04h;

  // ---- The MLC request's pick (DI-64, DI-65) -----------------------------
  // The bank sent from last cycle, encoded (a valid and its bank: fewer
  // flops written every cycle), in three copies: the pick's (passed over),
  // the payload capture's, and the output's to the banks.
  (* keep *) logic [WB-1:0]  sm_q_cc05h, sb_q_cc05h, snb_q_cc05h;
  (* keep *) logic           mv_q_cc05h, mvi_q_cc05h;
  logic [WCR-1:0] cr_q_cc05h;                 // ccv_dcu_mlc_req's credits
  logic           crq_q_cc05h;                // a credit back, a cycle on
  logic [NBK-1:0] hok_cc05h, hwin_cc05h, win_cc05h;
  logic           hold_cc05h [NBK][NBK];      // [i][j]: head i's stamp strictly older than j's
  logic           crok_cc05h, snd_cc05h;
  logic [NBK-1:0] smh_cc05h;                  // last cycle's send, one-hot
  logic [WB-1:0]  wb_cc05h;                   // this send's bank
  always_comb begin
    smh_cc05h = mvi_q_cc05h ? NBK'(1) << sm_q_cc05h : '0;
    for (int i = 0; i < NBK; i++)
      for (int j = 0; j < NBK; j++) begin
        logic [WTS-1:0] d;
        d = hstp_cc05h[j*WTS +: WTS] - hstp_cc05h[i*WTS +: WTS];
        hold_cc05h[i][j] = |d && !d[WTS-1];
      end
    hok_cc05h = hv_cc05h & ~smh_cc05h;
    for (int i = 0; i < NBK; i++) begin
      hwin_cc05h[i] = hok_cc05h[i];
      for (int j = 0; j < NBK; j++)
        if (j < i && hok_cc05h[j] && !hold_cc05h[i][j]) hwin_cc05h[i] = 1'b0;
        else if (j > i && hok_cc05h[j] && hold_cc05h[j][i]) hwin_cc05h[i] = 1'b0;
    end
    win_cc05h  = hwin_cc05h;
    // The count takes last cycle's send only now (mvi_q): a credit is left.
    crok_cc05h = cr_q_cc05h > WCR'(mvi_q_cc05h);
    snd_cc05h  = crok_cc05h && |win_cc05h;
    wb_cc05h   = '0;
    for (int i = 0; i < NBK; i++)
      if (win_cc05h[i]) wb_cc05h = wb_cc05h | WB'(i);
  end
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) begin
      mv_q_cc05h  <= 1'b0;
      mvi_q_cc05h <= 1'b0;
      sm_q_cc05h  <= '0;
      sb_q_cc05h  <= '0;
      snb_q_cc05h <= '0;
    end else begin
      mv_q_cc05h  <= snd_cc05h;
      mvi_q_cc05h <= snd_cc05h;
      sm_q_cc05h  <= wb_cc05h;
      sb_q_cc05h  <= wb_cc05h;
      snb_q_cc05h <= wb_cc05h;
    end
  end
  assign mv_cc05h  = mv_q_cc05h;
  assign sbk_cc05h = snb_q_cc05h;

  // The credits less the sends before last cycle (a send counts a cycle
  // late, from its valid's flop: depth). The credit pulse is captured
  // every cycle ("credit": a 1-flop event under the module's allowance).
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) crq_q_cc05h <= 1'b0;
    else          crq_q_cc05h <= mcr_cc04h;
  end
  logic cr_en_cc05h;
  assign cr_en_cc05h = rst_r01h || mvi_q_cc05h || crq_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (cr_en_cc05h)
      cr_q_cc05h <= rst_r01h ? WCR'(NCR) : cr_q_cc05h - WCR'(mvi_q_cc05h) + WCR'(crq_q_cc05h);
  end

  // T+2: the payload, from the sent bank's flops (its entry, or the record
  // of its allocation), req_id {bank, entry}.
  logic [WB-1:0]  pb_cc05h;
  logic [WEB-1:0] pidn_cc05h;
  logic [WL-1:0]  ppan_cc05h;
  logic [WC-1:0]  pcon_cc05h;
  always_comb begin
    pb_cc05h   = sb_q_cc05h;
    pidn_cc05h = pid_cc05h[sb_q_cc05h*WEB +: WEB];
    ppan_cc05h = ppa_cc05h[sb_q_cc05h*WL +: WL];
    pcon_cc05h = pcoh_cc05h[sb_q_cc05h*WC +: WC];
  end
  logic [WE-1:0] mrid_q_cc06h;
  logic [WL-1:0] mpa_q_cc06h;
  logic [WC-1:0] mcoh_q_cc06h;
  logic          mp_en_cc05h;
  assign mp_en_cc05h = mvi_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (mp_en_cc05h) begin
      mrid_q_cc06h <= {pb_cc05h, pidn_cc05h};
      mpa_q_cc06h  <= ppan_cc05h;
      mcoh_q_cc06h <= pcon_cc05h;
    end
  end
  assign mrid_cc06h = mrid_q_cc06h;
  assign mpa_cc06h  = {mpa_q_cc06h, WO'(0)};
  assign mcoh_cc06h = mcoh_q_cc06h;
  assign mcid_cc06h = WCID'(CID);

  // ---- CHECKs -------------------------------------------------------------
  // One bank a send, never without a credit, never the bank of last cycle's
  // send.
  `CCV_ASSERT(mpick_one_bank, !snd_cc05h || $onehot(win_cc05h))
  `CCV_ASSERT(mpick_credit, cr_q_cc05h <= WCR'(NCR))
  `CCV_ASSERT(mpick_credit_floor, cr_q_cc05h >= WCR'(mvi_q_cc05h))
  `CCV_ASSERT(mpick_pass_over, !(|(win_cc05h & smh_cc05h)))

endmodule
`undef CCV_CLK
`undef CCV_RST
