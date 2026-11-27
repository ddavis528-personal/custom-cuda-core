//===-- dcu_fill.sv - DCU fill buffers: capture, encode, answers owed, free -===//
//
// Spec: docs/design-snapshots/dcu-spec.md (live: CCV per-block architecture
//       specs, DCU tab, "MA's Phase 2", slice 2, part 1 (rev 89): "Fill
//       buffers (dcu_fill)" and "Stages of a fill"; MA rev 177 on DI-39 for
//       the write request).
//
// MA's slice 2, part 1 (DCU tab rev 89, "Fill buffers (dcu_fill)" and
// "Stages of a fill"; DI-39 for the write request). Four fill buffers, one
// per credit of ccv_mlc_dcu_rsp, each holding a fill's 1,024 data bits, its
// 72 check bits, its req_id, ownership and miss, the merge list it answers
// and the answers it still owes.
//
//   F-1  the fill's valid lands (arrival 0) and is flopped. The free buffer
//        it takes was chosen from flops a cycle ahead (the lowest free, one
//        hot), counting a fill that takes one now.
//   F    the payload lands at 0 NGD (no-flop end) into that buffer: the
//        line, req_id, ownership and miss. dcu_mshr reads the entry by the
//        same req_id, wired to it straight from the channel port.
//   F+1  the buffer's 8 code words are encoded (8 ccv_common_secded_enc,
//        K = 128) from a staging copy of the line captured at F beside the
//        buffer (the buffer's own flops drive bdata, NGD-7), and the 72
//        check bits flopped. dcu_mshr's entry read (the answer count and
//        merge list) is captured for the buffer. dcu_mshr launches the
//        write request's lead from its F read (DI-39, MA rev 177): the
//        valid and the bank, one hot.
//   F+2  the write request's payload, from flops: the buffer and its state
//        (ownership) here, the line and fold in dcu_mshr; dcu_bctl picks
//        the victim, and the write waits in its queue from F+4. The
//        buffer's list, count, check bits and data are dcu_rarb's and
//        dcu_rslot's, from flops.
//   W    a bank writes the buffer (wdv, wdb: dcu_bctl's flops); it is written.
//   free a buffer written whose answers have all left frees, one a cycle,
//        lowest first: ccv_mlc_dcu_rsp's credit goes back and dcu_mshr's
//        entry (the buffer's req_id) frees, both from flops a cycle on.
//
// Answers: dcu_rarb takes a buffer's answers in list order and reports how
// many it took each cycle (atk); the count owed falls by them.
//
// Not here yet: part 2's writeback acknowledgement (no buffer, the credit at
// once, the entry freed at F+1), part 3's store merge before the encode, and
// a merged request the fill cannot answer (back to its bank's queue).
//
// Clock gating: a buffer's data, req_id, ownership and miss behind its own
// capture (the flopped valid and its chosen buffer), the staging line behind
// the flopped valid; its check bits, count and list behind the capture a
// cycle on, and the write request's payload behind any capture a cycle on. The control (busy, written, the
// counts owed as they fall, the pick, the pulses) is written every cycle,
// within the module's 2%.
//
// Stage tags: the buffers and their control are one stage, 05, the block's
// state; the flopped valid and pick are 04, the payload 04, dcu_mshr's read
// 05, and the frees 06.
//
// The reference is the DCU model's fill path (sim/dcu/dcu_core.cpp,
// onFill() and answered()), and test/dcu/fill_tb.cpp holds this module to a
// value model of it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK dcu_core_clk
`define CCV_RST rst_r01h
module dcu_fill #(
  parameter  int NFB   = ccv_params_pkg::CCV_CREDIT_DEPTH,           // fill buffers, 4
  parameter  int NBK   = ccv_params_pkg::CCV_DCU_BANKS,              // 8
  parameter  int WE    = ccv_prov_pkg::CCV_P_W_REQ_DCU_MLC,          // req_id {bank, entry}, 7
  parameter  int LB    = 8 * ccv_prov_pkg::CCV_P_LINE_BYTES,         // line bits, 1024
  parameter  int LD    = 4,                                          // merge list
  parameter  int WLE   = ccv_prov_pkg::CCV_P_W_REQ_MIU_DCU + 7,      // list item, 15
  localparam int NW    = 8,                                          // code words
  localparam int KW    = LB / NW,                                    // 128
  localparam int R     = $clog2(KW + $clog2(KW) + 1) + 1,            // 9
  localparam int CW    = NW * R,                                     // 72
  localparam int WFB   = NFB > 1 ? $clog2(NFB) : 1,                  // 2
  localparam int WLC   = $clog2(LD + 1)                              // 3
) (
  input  logic                   dcu_core_clk,
  input  logic                   rst_n,
  // ccv_mlc_dcu_rsp: the valid at F-1, the payload at F (arrival 0).
  input  logic                   fv_cc03h,
  input  logic [WE-1:0]          frid_cc04h,
  input  logic [LB-1:0]          fdata_cc04h,
  input  logic                   fown_cc04h,
  input  logic                   fmiss_cc04h,
  // F+1: each bank's dcu_mshr's read of the fill's entry, zero but the
  // fill's bank's (MA-34).
  input  logic [NBK*WLC-1:0]     fcnt_cc05h,
  input  logic [NBK*LD*WLE-1:0]  flist_cc05h,
  // F+1: the write request (DI-39), beside dcu_mshr's line and fold.
  output logic [WFB-1:0]         wb_cc06h,
  output logic                   wown_cc06h,
  // W: each bank's write of a buffer, from dcu_bctl's flops.
  input  logic [NBK-1:0]         wdv_cc05h,
  input  logic [NBK*WFB-1:0]     wdb_cc05h,
  // The buffers, for dcu_rarb, dcu_rslot and dcu_bdat (from F+2).
  output logic [NFB-1:0]         bv_cc05h,       // listed: its count and list are good
  output logic [NFB*WLC-1:0]     bcnt_cc05h,     // answers still owed
  output logic [NFB*LD*WLE-1:0]  blist_cc05h,
  output logic [NFB-1:0]         bown_cc05h,
  output logic [NFB-1:0]         bmiss_cc05h,
  output logic [NFB*LB-1:0]      bdata_cc05h,
  output logic [NFB*CW-1:0]      bchk_cc05h,
  // dcu_rarb: the answers it took from each buffer this cycle.
  input  logic [NFB*WLC-1:0]     atk_cc05h,
  // The free: ccv_mlc_dcu_rsp's credit back, and dcu_mshr's entry.
  output logic                   crv_cc06h,
  output logic                   xv_cc06h,
  output logic [WE-1:0]          xid_cc06h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge dcu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- F-1: the valid, and the buffer it takes ----------------------------
  logic             fv_q_cc04h;
  logic [NFB-1:0]   fsel_q_cc05h;      // the lowest free buffer, one hot
  logic [NFB-1:0]   busy_q_cc05h;
  logic [NFB-1:0]   take_cc05h, free_cc05h, busyn_cc05h, fseln_cc05h;
  always_comb begin
    take_cc05h  = fv_q_cc04h ? fsel_q_cc05h : '0;
    busyn_cc05h = (busy_q_cc05h | take_cc05h) & ~free_cc05h;
    fseln_cc05h = '0;
    for (int b = NFB - 1; b >= 0; b--)
      if (!busyn_cc05h[b]) fseln_cc05h = NFB'(1) << b;
  end
  always_ff @(posedge dcu_core_clk) begin
    fv_q_cc04h   <= !rst_r01h && fv_cc03h;
    fsel_q_cc05h <= rst_r01h ? NFB'(1) : fseln_cc05h;
    busy_q_cc05h <= rst_r01h ? '0 : busyn_cc05h;
  end

  // ---- F: the payload into the chosen buffer -------------------------------
  logic [LB-1:0]  bd_q_cc05h  [NFB];
  logic [WE-1:0]  brid_q_cc05h[NFB];
  logic [NFB-1:0] bown_q_cc05h, bmiss_q_cc05h;
  for (genvar b = 0; b < NFB; b++) begin : g_cap
    logic cap_en_cc04h;
    assign cap_en_cc04h = take_cc05h[b];
    always_ff @(posedge dcu_core_clk) begin
      if (cap_en_cc04h) begin
        bd_q_cc05h[b]    <= fdata_cc04h;
        brid_q_cc05h[b]  <= frid_cc04h;
        bown_q_cc05h[b]  <= fown_cc04h;
        bmiss_q_cc05h[b] <= fmiss_cc04h;
      end
    end
  end
  // The staging line for the encoders, behind the flopped valid.
  logic [LB-1:0] ed_q_cc05h;
  logic          ed_en_cc04h;
  assign ed_en_cc04h = fv_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (ed_en_cc04h) ed_q_cc05h <= fdata_cc04h;
  end

  // ---- F+1: encode, the entry's list, the write request --------------------
  // The fill's entry read: the banks' reads ORed (only its bank's is not
  // zero).
  logic [WLC-1:0]    frc_cc05h;
  logic [LD*WLE-1:0] frl_cc05h;
  always_comb begin
    frc_cc05h = '0;
    frl_cc05h = '0;
    for (int k = 0; k < NBK; k++) begin
      frc_cc05h = frc_cc05h | fcnt_cc05h[k*WLC +: WLC];
      frl_cc05h = frl_cc05h | flist_cc05h[k*LD*WLE +: LD*WLE];
    end
  end
  logic [NFB-1:0] new_q_cc05h;          // the buffer captured last cycle, one hot
  always_ff @(posedge dcu_core_clk) begin
    new_q_cc05h  <= rst_r01h ? '0 : take_cc05h;
  end

  // ---- F+2: the write request's payload (DI-39) -----------------------------
  logic [WFB-1:0] nidx_cc05h;
  always_comb begin
    nidx_cc05h = '0;
    for (int b = 0; b < NFB; b++)
      if (new_q_cc05h[b]) nidx_cc05h = WFB'(b);
  end
  logic [WFB-1:0] wb_q_cc06h;
  logic           wown_q_cc06h;
  logic           w_en_cc05h;
  assign w_en_cc05h = |new_q_cc05h;
  always_ff @(posedge dcu_core_clk) begin
    if (w_en_cc05h) begin
      wb_q_cc06h   <= nidx_cc05h;
      wown_q_cc06h <= |(bown_q_cc05h & new_q_cc05h);
    end
  end
  assign wb_cc06h   = wb_q_cc06h;
  assign wown_cc06h = wown_q_cc06h;

  logic [CW-1:0] nchk_cc05h;
  for (genvar w = 0; w < NW; w++) begin : g_enc
    ccv_common_secded_enc #(.K(KW)) u_enc (
      .data(ed_q_cc05h[w*KW +: KW]),
      .chk (nchk_cc05h[w*R +: R])
    );
  end

  logic [CW-1:0]       bc_q_cc05h [NFB];
  logic [LD*WLE-1:0]   bl_q_cc05h [NFB];
  for (genvar b = 0; b < NFB; b++) begin : g_enc_cap
    logic enc_en_cc05h;
    assign enc_en_cc05h = new_q_cc05h[b];
    always_ff @(posedge dcu_core_clk) begin
      if (enc_en_cc05h) begin
        bc_q_cc05h[b] <= nchk_cc05h;
        bl_q_cc05h[b] <= frl_cc05h;
      end
    end
  end

  // ---- The control: listed, written, answers owed, the free ---------------
  logic [NFB-1:0] lst_q_cc05h, wrt_q_cc05h;
  logic [WLC-1:0] cnt_q_cc05h [NFB];
  logic [NFB-1:0] wdone_cc05h, ready_cc05h;
  logic [WLC-1:0] cntn_cc05h [NFB];
  always_comb begin
    for (int b = 0; b < NFB; b++) begin
      wdone_cc05h[b] = 1'b0;
      for (int k = 0; k < NBK; k++)
        wdone_cc05h[b] = wdone_cc05h[b] || (wdv_cc05h[k] && wdb_cc05h[k*WFB +: WFB] == WFB'(b));
      cntn_cc05h[b] = new_q_cc05h[b] ? frc_cc05h : cnt_q_cc05h[b] - atk_cc05h[b*WLC +: WLC];
      // Written, listed and owing nothing (its own flops: a free is a cycle
      // after the last answer or the write).
      ready_cc05h[b] = busy_q_cc05h[b] && lst_q_cc05h[b] && wrt_q_cc05h[b] && cnt_q_cc05h[b] == '0;
    end
    free_cc05h = ready_cc05h & ~(ready_cc05h - NFB'(1));   // the lowest
  end
  logic [WFB-1:0] fidx_cc05h;
  always_comb begin
    fidx_cc05h = '0;
    for (int b = 0; b < NFB; b++)
      if (free_cc05h[b]) fidx_cc05h = WFB'(b);
  end
  logic           crv_q_cc06h, xv_q_cc06h;
  logic [WE-1:0]  xid_q_cc06h;
  always_ff @(posedge dcu_core_clk) begin
    for (int b = 0; b < NFB; b++) begin
      lst_q_cc05h[b] <= !rst_r01h && !free_cc05h[b] && (lst_q_cc05h[b] || new_q_cc05h[b]);
      wrt_q_cc05h[b] <= !rst_r01h && !free_cc05h[b] && (wrt_q_cc05h[b] || wdone_cc05h[b]);
      cnt_q_cc05h[b] <= rst_r01h ? '0 : cntn_cc05h[b];
    end
    crv_q_cc06h <= !rst_r01h && |free_cc05h;
    xv_q_cc06h  <= !rst_r01h && |free_cc05h;
    xid_q_cc06h <= brid_q_cc05h[fidx_cc05h];
  end
  assign crv_cc06h = crv_q_cc06h;
  assign xv_cc06h  = xv_q_cc06h;
  assign xid_cc06h = xid_q_cc06h;

  for (genvar b = 0; b < NFB; b++) begin : g_out
    assign bv_cc05h[b]                       = lst_q_cc05h[b];
    assign bcnt_cc05h[b*WLC +: WLC]          = cnt_q_cc05h[b];
    assign blist_cc05h[b*LD*WLE +: LD*WLE]   = bl_q_cc05h[b];
    assign bown_cc05h[b]                     = bown_q_cc05h[b];
    assign bmiss_cc05h[b]                    = bmiss_q_cc05h[b];
    assign bdata_cc05h[b*LB +: LB]           = bd_q_cc05h[b];
    assign bchk_cc05h[b*CW +: CW]            = bc_q_cc05h[b];
  end

  // ---- CHECKs -------------------------------------------------------------
  // A fill always finds a buffer (the channel's credits), a bank writes only
  // a busy, listed buffer not yet written, and dcu_rarb takes no more answers
  // than a buffer owes.
  logic wr_ok_cc05h, tk_ok_cc05h;
  always_comb begin
    wr_ok_cc05h = 1'b1;
    tk_ok_cc05h = 1'b1;
    for (int b = 0; b < NFB; b++) begin
      wr_ok_cc05h = wr_ok_cc05h && (!wdone_cc05h[b] ||
                                    (busy_q_cc05h[b] && lst_q_cc05h[b] && !wrt_q_cc05h[b]));
      tk_ok_cc05h = tk_ok_cc05h && cnt_q_cc05h[b] >= atk_cc05h[b*WLC +: WLC] &&
                    (atk_cc05h[b*WLC +: WLC] == '0 || lst_q_cc05h[b]);
    end
  end
  `CCV_ASSERT(fill_buffer_free, !fv_q_cc04h || !(|(fsel_q_cc05h & busy_q_cc05h)) && |fsel_q_cc05h)
  `CCV_ASSERT(fill_write_once, wr_ok_cc05h)
  `CCV_ASSERT(fill_answers_owed, tk_ok_cc05h)

endmodule
`undef CCV_CLK
`undef CCV_RST
