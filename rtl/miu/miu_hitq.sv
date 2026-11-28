//===-- miu_hitq.sv - MIU first-pass delay line: each lookup's MQ entry ----===//
//
// Spec: docs/design-snapshots/miu-spec.md (live: CCV per-block architecture
//       specs, MIU tab, "MA's Phase 2", slice 1): the stage table's R1 row
//       ("the hit delay line names each slot's MQ entry"), the module
//       partition's miu_hitq row (1, H+2 to R1: entry and slot, a lookup
//       slot a cycle), and Port NGD budgets (miu_hitq outputs from flops).
//
// A first-pass lookup on lookup slot k launches at H+2 and its response
// valid lands at R1 = H+7 on rsp slot k; that it lands then is its hit. This
// module carries, per lookup slot, which MQ entry and which address slot the
// lookup belongs to, from the lookup's launch to R1, so miu_rsp can name a
// hit's memop without a req_id read. Stage tags count from the memop's
// arrival M = 00, H = 05 (miu_cap's): R1 = 12.
//
// The path, per cycle:
// - 05: address slot s's valid, miu_cap's a cycle on (v_cm04h), captured
//   every cycle (CG-5): the only ungated flops but the reset's.
// - 06: address slot s's {valid, MQ entry}, the entry from miu_pair's A1
//   flops (a1e_cm05h, held from H until the next pairing), under 05's valid.
// - 07: lookup slot k's {valid, entry, address slot}: the valid is
//   miu_lead's req valid (rv_cm06h), the address slot and entry those of
//   the leader's address slot (miu_lead's one-hot lq_cm06h, an AND-OR).
//   Enabled while an address slot was valid at 06 or the stage holds one.
// - 08 to 12: the same, a stage a cycle, each lookup slot's group enabled
//   from the stage before's valid and its own. At 08 the valid drops a
//   lookup A2 dropped (miu_a2's dr_cm07h): DCU answers no drop (MA-27).
//
// Every group is enabled only while it takes a lookup or clears one, so its
// value changes in each enabled cycle (CG-3), and is closed while idle.
//
// Outputs (R1, 12): per lookup slot, the valid, the entry and the address
// slot, each straight from a flop that feeds nothing else.
//
// The reference is the MIU model's first-pass hit (sim/miu/miu_block.cpp:
// a first pass's response at its contracted slot), and test/miu/hitq_tb.cpp
// holds this module to a value model of the line.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_hitq #(
  parameter  int NS = ccv_params_pkg::CCV_MIU_PIPES,                                   // 4
  parameter  int NE = ccv_params_pkg::CCV_MIU_PIPES * ccv_prov_pkg::CCV_MEMOP_CREDITS, // 40
  parameter  int NL = 32,                                                              // lanes
  localparam int NQ = NL / 8,                                                          // quarters
  localparam int EW = $clog2(NE),
  localparam int SB = (NS > 1) ? $clog2(NS) : 1
) (
  input  logic               miu_core_clk,
  input  logic               rst_n,
  // miu_cap's valids a cycle on: address slot s's address lands in A1 now.
  input  logic [NS-1:0]      v_cm04h,
  // miu_pair's A1 flops: address slot s's MQ entry at [s*EW +: EW].
  input  logic [NS*EW-1:0]   a1e_cm05h,
  // miu_lead's flops: lookup slot k's req valid, and its leader's (address
  // slot a, quarter q) one-hot at [(k*NS + a)*NQ + q].
  input  logic [NS-1:0]      rv_cm06h,
  input  logic [NS*NS*NQ-1:0] lq_cm06h,
  // miu_a2's flops: lookup slot k's drop.
  input  logic [NS-1:0]      dr_cm07h,
  // R1: lookup slot k's first pass, its MQ entry and its address slot.
  output logic [NS-1:0]      hv_cm12h,
  output logic [NS*EW-1:0]   he_cm12h,
  output logic [NS*SB-1:0]   hs_cm12h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge miu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- 05: the address slots' valids, every cycle (CG-5) -----------------
  logic [NS-1:0] v_q_cm05h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) v_q_cm05h <= '0;
    else          v_q_cm05h <= v_cm04h;
  end

  // ---- 06: each address slot's {valid, entry} ----------------------------
  logic [NS-1:0]    av_q_cm06h;
  logic [NS*EW-1:0] ae_q_cm06h;
  logic a_en_cm05h;
  assign a_en_cm05h = |v_q_cm05h || |av_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) av_q_cm06h <= '0;
    else if (a_en_cm05h) av_q_cm06h <= v_q_cm05h;
  end
  always_ff @(posedge miu_core_clk) begin
    if (a_en_cm05h) ae_q_cm06h <= a1e_cm05h;
  end

  // ---- 07: each lookup slot's {valid, entry, address slot} ---------------
  // The leader's address slot from the one-hot (OR over its quarters), and
  // that slot's entry, an AND-OR over the address slots.
  logic [NS*EW-1:0] le_d_cm06h;
  logic [NS*SB-1:0] ls_d_cm06h;
  always_comb begin
    for (int k = 0; k < NS; k++) begin
      logic [EW-1:0] e;
      logic [SB-1:0] s;
      e = '0;
      s = '0;
      for (int a = 0; a < NS; a++)
        if (|lq_cm06h[(k*NS + a)*NQ +: NQ]) begin
          e = e | ae_q_cm06h[a*EW +: EW];
          s = s | SB'(a);
        end
      le_d_cm06h[k*EW +: EW] = e;
      ls_d_cm06h[k*SB +: SB] = s;
    end
  end

  logic [NS-1:0]    v_q_cm07h;
  logic [NS*EW-1:0] e_q_cm07h;
  logic [NS*SB-1:0] s_q_cm07h;
  logic l_en_cm06h;
  assign l_en_cm06h = |av_q_cm06h || |v_q_cm07h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) v_q_cm07h <= '0;
    else if (l_en_cm06h) v_q_cm07h <= rv_cm06h;
  end
  always_ff @(posedge miu_core_clk) begin
    if (l_en_cm06h) begin
      e_q_cm07h <= le_d_cm06h;
      s_q_cm07h <= ls_d_cm06h;
    end
  end

  // ---- 08: less A2's drops -----------------------------------------------
  logic [NS-1:0]    v_q_cm08h;
  logic [NS*EW-1:0] e_q_cm08h;
  logic [NS*SB-1:0] s_q_cm08h;
  for (genvar k = 0; k < NS; k++) begin : g_s08
    logic ln_en_cm07h;
    assign ln_en_cm07h = v_q_cm07h[k] || v_q_cm08h[k];
    always_ff @(posedge miu_core_clk) begin
      if (rst_r01h) v_q_cm08h[k] <= 1'b0;
      else if (ln_en_cm07h) v_q_cm08h[k] <= v_q_cm07h[k] && !dr_cm07h[k];
    end
    always_ff @(posedge miu_core_clk) begin
      if (ln_en_cm07h) begin
        e_q_cm08h[k*EW +: EW] <= e_q_cm07h[k*EW +: EW];
        s_q_cm08h[k*SB +: SB] <= s_q_cm07h[k*SB +: SB];
      end
    end
  end

  // ---- 09 to 11: the line ------------------------------------------------
  logic [NS-1:0]    v_q_cm09h;
  logic [NS*EW-1:0] e_q_cm09h;
  logic [NS*SB-1:0] s_q_cm09h;
  logic [NS-1:0]    v_q_cm10h;
  logic [NS*EW-1:0] e_q_cm10h;
  logic [NS*SB-1:0] s_q_cm10h;
  logic [NS-1:0]    v_q_cm11h;
  logic [NS*EW-1:0] e_q_cm11h;
  logic [NS*SB-1:0] s_q_cm11h;
  for (genvar k = 0; k < NS; k++) begin : g_s09
    logic ln_en_cm08h;
    assign ln_en_cm08h = v_q_cm08h[k] || v_q_cm09h[k];
    always_ff @(posedge miu_core_clk) begin
      if (rst_r01h) v_q_cm09h[k] <= 1'b0;
      else if (ln_en_cm08h) v_q_cm09h[k] <= v_q_cm08h[k];
    end
    always_ff @(posedge miu_core_clk) begin
      if (ln_en_cm08h) begin
        e_q_cm09h[k*EW +: EW] <= e_q_cm08h[k*EW +: EW];
        s_q_cm09h[k*SB +: SB] <= s_q_cm08h[k*SB +: SB];
      end
    end
  end
  for (genvar k = 0; k < NS; k++) begin : g_s10
    logic ln_en_cm09h;
    assign ln_en_cm09h = v_q_cm09h[k] || v_q_cm10h[k];
    always_ff @(posedge miu_core_clk) begin
      if (rst_r01h) v_q_cm10h[k] <= 1'b0;
      else if (ln_en_cm09h) v_q_cm10h[k] <= v_q_cm09h[k];
    end
    always_ff @(posedge miu_core_clk) begin
      if (ln_en_cm09h) begin
        e_q_cm10h[k*EW +: EW] <= e_q_cm09h[k*EW +: EW];
        s_q_cm10h[k*SB +: SB] <= s_q_cm09h[k*SB +: SB];
      end
    end
  end
  for (genvar k = 0; k < NS; k++) begin : g_s11
    logic ln_en_cm10h;
    assign ln_en_cm10h = v_q_cm10h[k] || v_q_cm11h[k];
    always_ff @(posedge miu_core_clk) begin
      if (rst_r01h) v_q_cm11h[k] <= 1'b0;
      else if (ln_en_cm10h) v_q_cm11h[k] <= v_q_cm10h[k];
    end
    always_ff @(posedge miu_core_clk) begin
      if (ln_en_cm10h) begin
        e_q_cm11h[k*EW +: EW] <= e_q_cm10h[k*EW +: EW];
        s_q_cm11h[k*SB +: SB] <= s_q_cm10h[k*SB +: SB];
      end
    end
  end

  // ---- 12 (R1): the outputs ----------------------------------------------
  // The valid's (* keep *) copy is the stage's own enable term; the port's
  // flop feeds nothing inside (a register that drives an output is held on
  // every path it starts to that output's budget).
  (* keep *) logic [NS-1:0] vi_q_cm12h;
  (* keep *) logic [NS-1:0] vo_q_cm12h;
  logic [NS*EW-1:0] e_q_cm12h;
  logic [NS*SB-1:0] s_q_cm12h;
  for (genvar k = 0; k < NS; k++) begin : g_s12
    logic ln_en_cm11h;
    assign ln_en_cm11h = v_q_cm11h[k] || vi_q_cm12h[k];
    always_ff @(posedge miu_core_clk) begin
      if (rst_r01h) begin
        vi_q_cm12h[k] <= 1'b0;
        vo_q_cm12h[k] <= 1'b0;
      end else if (ln_en_cm11h) begin
        vi_q_cm12h[k] <= v_q_cm11h[k];
        vo_q_cm12h[k] <= v_q_cm11h[k];
      end
    end
    always_ff @(posedge miu_core_clk) begin
      if (ln_en_cm11h) begin
        e_q_cm12h[k*EW +: EW] <= e_q_cm11h[k*EW +: EW];
        s_q_cm12h[k*SB +: SB] <= s_q_cm11h[k*SB +: SB];
      end
    end
  end
  assign hv_cm12h = vo_q_cm12h;
  assign he_cm12h = e_q_cm12h;
  assign hs_cm12h = s_q_cm12h;

  // A lookup slot's req valid names exactly one leader (footprints are
  // disjoint, V-60): its one-hot is never two address slots.
  logic [NS-1:0] bad_cm06h;
  for (genvar k = 0; k < NS; k++) begin : g_a
    logic [NS-1:0] as_cm06h;
    for (genvar a = 0; a < NS; a++) begin : g_o
      assign as_cm06h[a] = |lq_cm06h[(k*NS + a)*NQ +: NQ];
    end
    assign bad_cm06h[k] = rv_cm06h[k] && (as_cm06h == '0 || (as_cm06h & (as_cm06h - 1'b1)) != '0);
  end
  `CCV_ASSERT(one_slot, bad_cm06h == '0)

endmodule
`undef CCV_CLK
`undef CCV_RST
