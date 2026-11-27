//===-- miu_cred.sv - MIU DCU bank credits and the A1 credit gate ---------===//
//
// Spec: docs/design-snapshots/miu-spec.md (live: CCV per-block architecture
//       specs, MIU tab, "MA's Phase 2", slice 1 (rev 163): the module
//       partition's miu_cred row and "The drop"), with MA-25's bank credits
//       (Mechanisms) and ccv_dcu_miu_cred's contract (schema/interfaces.json).
//
// Per DCU bank b, two counters that reset full: CCV_DCU_BANK_QDEPTH lookup
// entry credits and CCV_DCU_BANK_STDATA store-data credits (MA-25). A lookup
// spends its bank's entry credit at its valid (miu_lead's flops, H+1), a
// store its store-data credit beside it (slice 2: the port is here, tied off
// until then). A2's drop refunds the entry credit from miu_a2's flopped drop
// (H+2; MA-27, DI-12): DCU never returns a dropped lookup's. DCU returns
// credits on ccv_dcu_miu_cred, a bit a bank on ent_ret and std_ret.
//
// The gate (MA-27 (2), MI-17; MIU tab rev 144): ge1[b] is set when bank b's
// entry count, net of every spend launched, every refund and every return
// counted this cycle, is at least CCV_DCACHE_LOOKUPS, and ge2[b] at twice
// that. They are flopped, so A1 reads, in cycle d, the counts after cycle
// d-1; miu_lead's own flop used[b] covers its launch in cycle d, which this
// module counts only then, and A1 gates on used[b] ? ge2[b] : ge1[b].
//
// ccv_dcu_miu_cred is abutted and fixed latency: its valid lands in V, its
// payload in V+1. MIU's end is no-flop (A-61, RI-11): the valid is flopped
// every cycle and enables the payload's capture, and a return is counted
// the cycle after its capture, V+2. The capture flops are a credit waiver
// (DA's ruling on RI-14), counted in MIU's 2%.
//
// Clock gating (CG-5): spends and refunds are inputs, so no enable can see
// them. This module flops its own record of what may change a count this
// cycle: a memop in A1 last cycle (its launch spends now), or the cycle
// before (A2's drop refunds now), or a return captured last cycle. The
// counters and the gate flops sit behind that one enable.
//
// Stage tags: the credit state (the counts and the gate flops) is one
// stage, 07, as a queue's entries and count are (CCV-L23's own-stage state;
// dcu_bctl's credit count is the same). What changes it this cycle arrives
// at 06 or 07: a spend from miu_lead's H+1 flops (06), a refund from
// miu_a2's H+2 flops (07, state of the same stage), and the return's
// capture (06), whose ports are numbered back from it (valid 04, payload
// 05), the channel's own numbering being DCU's. The gate leaves at 07 and
// A1 (05) reads it in the next cycle: the loop A1, launch, spend, gate is
// the credit's own, closed at miu_lead's port.
//
// Inputs are other MIU modules' flops and DCU's link (arrival 0), and every
// output comes straight from a flop.
//
// The reference is the MIU model's bank credits (sim/miu/miu_block.cpp:
// bankTake, a1GateFlop, a1_refund_ and the ccv_dcu_miu_cred receive), and
// test/miu/cred_tb.cpp holds this module to a value model of them.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_cred #(
  parameter  int NS = ccv_params_pkg::CCV_MIU_PIPES,          // lookup slots, 4
  parameter  int NB = ccv_params_pkg::CCV_DCU_BANKS,          // banks, 8
  parameter  int QD = ccv_prov_pkg::CCV_DCU_BANK_QDEPTH,    // entry credits a bank, 16
  parameter  int SD = ccv_prov_pkg::CCV_DCU_BANK_STDATA,    // store-data credits a bank, 12
  parameter  int LK = ccv_prov_pkg::CCV_DCACHE_LOOKUPS,     // the gate's step, 4
  localparam int BW = (NB > 1) ? $clog2(NB) : 1,
  localparam int EW = $clog2(QD + 1),
  localparam int DW = $clog2(SD + 1)
) (
  input  logic          miu_core_clk,
  input  logic          rst_n,
  // A1: slot k holds a memop (miu_pair's valid, one cycle a pairing).
  input  logic [NS-1:0]    a1v_cm05h,
  // H+1: slot k's valid launched to bank sb[k] (miu_lead's flops); ss[k] a
  // store, which spends a store-data credit too (slice 2: tie to 0).
  input  logic [NS-1:0]    sv_cm06h,
  input  logic [NS*BW-1:0] sb_cm06h,
  input  logic [NS-1:0]    ss_cm06h,
  // H+2: A2 dropped slot k's lookup to bank rb[k] (miu_a2's flops).
  input  logic [NS-1:0]    rv_cm07h,
  input  logic [NS*BW-1:0] rb_cm07h,
  // ccv_dcu_miu_cred: the valid in V, the payload in V+1.
  input  logic             cv_cm04h,
  input  logic [NB-1:0]    er_cm05h,      // ent_ret
  input  logic [NB-1:0]    dr_cm05h,      // std_ret
  // The gate, read by miu_lead in A1.
  output logic [NB-1:0]    ge1_cm07h,
  output logic [NB-1:0]    ge2_cm07h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge miu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- The return's capture (no-flop end; a credit waiver) --------------
  logic cv_q_cm05h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) cv_q_cm05h <= 1'b0;
    else          cv_q_cm05h <= cv_cm04h;
  end
  wire ret_en_cm05h = cv_q_cm05h;
  logic [NB-1:0] er_q_cm06h, dr_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (ret_en_cm05h) begin
      er_q_cm06h <= er_cm05h;
      dr_q_cm06h <= dr_cm05h;
    end
  end
  // Fresh: the capture holds a return not yet counted.
  logic rf_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) rf_q_cm06h <= 1'b0;
    else          rf_q_cm06h <= cv_q_cm05h;
  end

  // ---- The counters' enable, from this module's flops (CG-5) ------------
  // av: a memop was in A1 last cycle, so its launch may spend now; cnt_q:
  // anything may change a count this cycle (a spend, a refund a cycle after
  // a spend's, or a fresh return). Written inline: its terms are of
  // different stages, each a flop.
  logic av_q_cm06h, cnt_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) begin
      av_q_cm06h  <= 1'b0;
      cnt_q_cm06h <= 1'b0;
    end else begin
      av_q_cm06h  <= |a1v_cm05h;
      cnt_q_cm06h <= (|a1v_cm05h) | av_q_cm06h | cv_q_cm05h;
    end
  end
  wire cnt_en_cm06h = cnt_q_cm06h;

  // ---- Per bank: this cycle's spends and refunds ------------------------
  // Up to NS of each a cycle; counted, not decoded per slot, below.
  localparam int KW = $clog2(NS + 1);
  logic [NB*KW-1:0] sp_cm06h, ds_cm06h;
  logic [NB*KW-1:0] rf_cm07h;
  always_comb begin
    sp_cm06h = '0;
    ds_cm06h = '0;
    for (int b = 0; b < NB; b++)
      for (int k = 0; k < NS; k++) begin
        sp_cm06h[b*KW +: KW] = sp_cm06h[b*KW +: KW] +
            KW'(sv_cm06h[k] && (sb_cm06h[k*BW +: BW] == BW'(b)));
        ds_cm06h[b*KW +: KW] = ds_cm06h[b*KW +: KW] +
            KW'(sv_cm06h[k] && ss_cm06h[k] && (sb_cm06h[k*BW +: BW] == BW'(b)));
      end
  end
  always_comb begin
    rf_cm07h = '0;
    for (int b = 0; b < NB; b++)
      for (int k = 0; k < NS; k++)
        rf_cm07h[b*KW +: KW] = rf_cm07h[b*KW +: KW] +
            KW'(rv_cm07h[k] && (rb_cm07h[k*BW +: BW] == BW'(b)));
  end

  // ---- The counters and the gate ----------------------------------------
  // A count after this cycle: what it held, less the spends, plus the
  // refunds and the fresh return. The gate flops take the same sum, so
  // both are written inline (their terms are of different stages).
  // Signed one bit wider, so the bound checks below see a spend past 0 or
  // a return past full.
  logic [NB*EW-1:0] ent_q_cm07h;
  logic [NB*DW-1:0] std_q_cm07h;
  logic [NB-1:0]    ge1_q_cm07h, ge2_q_cm07h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) begin
      for (int b = 0; b < NB; b++) begin
        ent_q_cm07h[b*EW +: EW] <= EW'(QD);
        std_q_cm07h[b*DW +: DW] <= DW'(SD);
      end
      ge1_q_cm07h <= {NB{QD >= LK}};
      ge2_q_cm07h <= {NB{QD >= 2 * LK}};
    end else if (cnt_en_cm06h) begin
      for (int b = 0; b < NB; b++) begin
        ent_q_cm07h[b*EW +: EW] <= EW'(ent_q_cm07h[b*EW +: EW] - EW'(sp_cm06h[b*KW +: KW]) +
                                       EW'(rf_cm07h[b*KW +: KW]) +
                                       EW'(rf_q_cm06h && er_q_cm06h[b]));
        std_q_cm07h[b*DW +: DW] <= DW'(std_q_cm07h[b*DW +: DW] - DW'(ds_cm06h[b*KW +: KW]) +
                                       DW'(rf_q_cm06h && dr_q_cm06h[b]));
        ge1_q_cm07h[b] <= (EW+1)'(ent_q_cm07h[b*EW +: EW]) - (EW+1)'(sp_cm06h[b*KW +: KW]) +
                          (EW+1)'(rf_cm07h[b*KW +: KW]) + (EW+1)'(rf_q_cm06h && er_q_cm06h[b])
                          >= (EW+1)'(LK);
        ge2_q_cm07h[b] <= (EW+1)'(ent_q_cm07h[b*EW +: EW]) - (EW+1)'(sp_cm06h[b*KW +: KW]) +
                          (EW+1)'(rf_cm07h[b*KW +: KW]) + (EW+1)'(rf_q_cm06h && er_q_cm06h[b])
                          >= (EW+1)'(2 * LK);
      end
    end
  end
  assign ge1_cm07h = ge1_q_cm07h;
  assign ge2_cm07h = ge2_q_cm07h;

  // ---- Checks -----------------------------------------------------------
  // Every spend has its credit and every return or refund one MIU spent: a
  // count never goes below 0 nor past its reset value (MA-25), and nothing
  // changes a count while its enable is off.
  logic [NB-1:0] bound_ok_cm07h;
  always_comb begin
    for (int b = 0; b < NB; b++) begin
      logic signed [EW+1:0] e;
      logic signed [DW+1:0] d;
      e = $signed({2'b00, ent_q_cm07h[b*EW +: EW]}) - $signed((EW+2)'(sp_cm06h[b*KW +: KW])) +
          $signed((EW+2)'(rf_cm07h[b*KW +: KW])) + $signed((EW+2)'(rf_q_cm06h && er_q_cm06h[b]));
      d = $signed({2'b00, std_q_cm07h[b*DW +: DW]}) - $signed((DW+2)'(ds_cm06h[b*KW +: KW])) +
          $signed((DW+2)'(rf_q_cm06h && dr_q_cm06h[b]));
      bound_ok_cm07h[b] = (e >= 0) && (e <= QD) && (d >= 0) && (d <= SD) &&
                          (cnt_en_cm06h || (sp_cm06h[b*KW +: KW] == '0 && rf_cm07h[b*KW +: KW] == '0 &&
                                            !rf_q_cm06h));
    end
  end
  `CCV_ASSERT(cred_bound, &bound_ok_cm07h)

endmodule
`undef CCV_CLK
`undef CCV_RST
