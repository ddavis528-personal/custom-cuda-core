//===-- dcu_btag.sv - DCU bank tags: one bank's tag RF and its compare ----===//
//
// Spec: docs/design-snapshots/dcu-spec.md (live: CCV per-block architecture
//       specs, DCU tab, "MA's Phase 2", slice 1 (rev 82): the stage table's
//       D0 and D1 rows, the module partition's dcu_btag row and the port
//       budgets).
//
// One instance per bank (8). The bank's tags sit in NRF register files
// (ccv_common_rf_1r1w, 64 x 140 at 8 ways: four ways' entries a word), one
// word per set of the bank. A way's entry is {dirty, state[1:0], tag}: the
// tag is the line PA above the set index (PA[47:16]), and state 0 is
// invalid; what the other states mean is slice 2's (fills, stores, probes).
//
//   H+1  the leads (each slot's valid and lead_set_index's bank bits, on the
//        channel's wires): the lowest slot whose lead names this bank is
//        picked and flopped. MIU's A2 drops every other slot on the bank
//        (MA-27), so one lookup a cycle reads a bank's tags.
//   D0 = H+2  the pick reads the RFs (re from the pick's flops, CG-5), at the
//        set that slot's dcu_cap holds.
//   D1 = H+3  the read words against the picked slot's line PA from its
//        dcu_cap: hit, the way (one-hot), its state and dirty, flopped.
//   D2 = H+4  the flops, to dcu_bctl, read through dcu_bctl's own carry of
//        the lookup (they hold their last value otherwise).
//
// The pick is flopped here from the channel's lead wires rather than decoded
// from dcu_cap's D0 flops: the RFs' read enable must come from this module's
// own flops (CG-5; docs/rtl-coding-style.md, "Hard macros"), and a decode
// of dcu_cap's outputs would be an input. Those pick flops capture an
// interface lead every cycle: a "lead": true waiver, charged to the block's
// 2% (as dcu_cap's lead flops are).
//
// The write port (slice 2's fills and state changes; the bench preloads the
// tags through it) follows the valid-leads-payload rule: twe, a write's
// lead, is flopped here and is the RFs' we; the set and the words come a
// cycle later, straight to the RFs' pins. Its stage tags are placeholders
// until slice 2 times the fill path.
//
// The reference is the DCU model's tag lookup (sim/dcu/dcu_core.cpp,
// find()), and test/dcu/btag_tb.cpp holds this module to a value model.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK dcu_core_clk
`define CCV_RST rst_r01h
module dcu_btag #(
  parameter  int BANK  = 0,                                          // this bank
  parameter  int SLOTS = 4,                                          // ccv_miu_dcu_req slots
  parameter  int NB    = $clog2(ccv_params_pkg::CCV_DCU_BANKS),        // bank bits, 3
  parameter  int WS    = ccv_prov_pkg::CCV_W_DCU_SET,                // set index, 9
  parameter  int WAYS  = ccv_prov_pkg::CCV_DCU_WAYS,                 // 8
  parameter  int WA    = ccv_prov_pkg::CCV_P_W_PA,                   // 48
  parameter  int WO    = $clog2(ccv_prov_pkg::CCV_P_LINE_BYTES),     // 7
  localparam int WL    = WA - WO,                                    // line PA, 41
  localparam int WT    = WL - WS,                                    // tag, 32
  localparam int WE    = WT + 3,                                     // way entry, 35
  localparam int WPR   = 4,                                          // ways per RF word
  localparam int NRF   = (WAYS + WPR - 1) / WPR,                     // 2
  localparam int WW    = WPR * WE,                                   // RF word, 140
  localparam int WR    = WS - NB,                                    // RF address, 6
  localparam int WWY   = WAYS > 1 ? $clog2(WAYS) : 1
) (
  input  logic                   dcu_core_clk,
  input  logic                   rst_n,
  // H+1: the channel's leads, each slot's valid and its set's bank bits.
  input  logic [SLOTS-1:0]       rv_cc01h,
  input  logic [SLOTS*NB-1:0]    lsb_cc01h,
  // D0: each slot's set, from its dcu_cap.
  input  logic [SLOTS*WS-1:0]    lsi_cc02h,
  // D1: each slot's line PA, from its dcu_cap.
  input  logic [SLOTS*WL-1:0]    pa_cc03h,
  // The write port: twe a cycle ahead of the set and the words (slice 2).
  input  logic [NRF-1:0]         twe_cc05h,
  input  logic [WR-1:0]          twa_cc06h,
  input  logic [NRF*WW-1:0]      twd_cc06h,
  // D2: the lookup's tag result.
  output logic                   hit_cc04h,
  output logic [WAYS-1:0]        way_cc04h,      // one-hot, 0 on a miss
  output logic [1:0]             st_cc04h,       // the hit way's state
  output logic                   dty_cc04h       // the hit way's dirty
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge dcu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

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

  // The pick, captured every cycle (an interface lead: CG-5, waived "lead").
  logic [SLOTS-1:0] pk_q_cc02h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) pk_q_cc02h <= '0;
    else          pk_q_cc02h <= pk_cc01h;
  end

  // ---- D0: the RF read ------------------------------------------------------
  wire re_cc02h = |pk_q_cc02h;
  logic [WR-1:0] ra_cc02h;
  always_comb begin
    ra_cc02h = '0;
    for (int s = 0; s < SLOTS; s++)
      if (pk_q_cc02h[s]) ra_cc02h = ra_cc02h | lsi_cc02h[s*WS + NB +: WR];
  end

  // The read's slot, a cycle on, for the PA select (written every cycle: a
  // 0 is no read).
  logic [SLOTS-1:0] pk_q_cc03h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) pk_q_cc03h <= '0;
    else          pk_q_cc03h <= pk_q_cc02h;
  end

  // The write's lead, flopped: the RFs' we (CG-5).
  logic [NRF-1:0] we_q_cc06h;
  always_ff @(posedge dcu_core_clk) begin
    if (rst_r01h) we_q_cc06h <= '0;
    else          we_q_cc06h <= twe_cc05h;
  end

  logic [NRF*WW-1:0] rd_cc03h;
  for (genvar r = 0; r < NRF; r++) begin : g_rf
    ccv_common_rf_1r1w #(.W(WW), .D(1 << WR)) u_rf (
      .clk   (dcu_core_clk),
      .re    (re_cc02h),
      .raddr (ra_cc02h),
      .rdata (rd_cc03h[r*WW +: WW]),
      .we    (we_q_cc06h[r]),
      .waddr (twa_cc06h),
      .wdata (twd_cc06h[r*WW +: WW])
    );
  end

  // ---- D1: the compare ------------------------------------------------------
  wire v_cc03h = |pk_q_cc03h;
  logic [WT-1:0] tg_cc03h;
  always_comb begin
    tg_cc03h = '0;
    for (int s = 0; s < SLOTS; s++)
      if (pk_q_cc03h[s]) tg_cc03h = tg_cc03h | pa_cc03h[s*WL + WS +: WT];
  end

  logic [WAYS-1:0] wh_cc03h;
  logic [1:0]      st_cc03h;
  logic            dty_cc03h;
  always_comb begin
    st_cc03h  = '0;
    dty_cc03h = 1'b0;
    for (int w = 0; w < WAYS; w++) begin
      wh_cc03h[w] = rd_cc03h[w*WE + WT +: 2] != 2'b00 && rd_cc03h[w*WE +: WT] == tg_cc03h;
      if (wh_cc03h[w]) begin
        st_cc03h  = st_cc03h | rd_cc03h[w*WE + WT +: 2];
        dty_cc03h = dty_cc03h | rd_cc03h[w*WE + WT + 2];
      end
    end
  end

  // The result, under the read's flop a cycle on: one clock gate.
  wire res_en_cc03h = v_cc03h;
  logic            hit_q_cc04h;
  logic [WAYS-1:0] way_q_cc04h;
  logic [1:0]      st_q_cc04h;
  logic            dty_q_cc04h;
  always_ff @(posedge dcu_core_clk) begin
    if (res_en_cc03h) begin
      hit_q_cc04h <= |wh_cc03h;
      way_q_cc04h <= wh_cc03h;
      st_q_cc04h  <= st_cc03h;
      dty_q_cc04h <= dty_cc03h;
    end
  end
  assign hit_cc04h = hit_q_cc04h;
  assign way_cc04h = way_q_cc04h;
  assign st_cc04h  = st_q_cc04h;
  assign dty_cc04h = dty_q_cc04h;

  // A line is in one way of its set (the model's find(); slice 2's fills
  // keep it so).
  `CCV_ASSERT(btag_hit_onehot, !v_cc03h || $onehot0(wh_cc03h))
  `CCV_ASSERT(btag_pick_onehot, $onehot0(pk_q_cc02h))

endmodule
`undef CCV_CLK
`undef CCV_RST
