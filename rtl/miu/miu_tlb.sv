//===-- miu_tlb.sv - MIU translation: the L0s at A2 and the TLB at A3 ------===//
//
// Spec: MIU tab of the per-block architecture specs (live doc), MA's rulings
//       on MI-30 and MI-31 (MA revs 198, 199): front (ii), the fixed leader,
//       with an L0 of CCV-sized N0 = 4 entries per lookup slot read at A2,
//       and the 32-entry TLB moved to A3, off the hit path, serving only the
//       L0s' refills (and, from slice 2, the passes' lookups).
//
// Holds the state; miu_a2 does A2's compare. Nothing may run straight
// through a module, input to output (docs/rtl-coding-style.md), so the L0
// compare sits with the payload flops it feeds, in miu_a2, and this module
// gives miu_a2 every L0 entry straight from its flops (out 0):
//
//   l0v, l0vpn, l0ppn, l0fold, l0pm   slot s's entry e at [(s*N0 + e) * width]
//
// The refill (an L0 miss at A2):
//
//   cycle  tag   here
//   A2     06h   rv_cm06h: miu_lead's req valid per slot, the lead
//   A2+1   07h   miu_a2's flopped leader VPN (vpn_cm07h) and L0 miss
//                (ms_cm07h) land; captured under rq, this module's flop
//                of the lead (CG-5: the enable is never an input)
//   A3     08h   pending per slot; one refill a cycle, round robin over the
//                slots (NP = 1 read port; MA rev 199 (2)), compared with
//                the 32 entries; hit, PPN, fold and perms flopped
//   A3+1   09h   the hit written into the slot's L0 at its round-robin
//                pointer; a miss goes to the walker (tm, tmv; slice 2)
//   A3+2   10h   the entry readable at A2
//
// A slot's new capture overwrites a refill still pending on it: that load
// has already taken the no-hit path, and its page comes back on its next
// lookup. Two misses on one page in flight may fill two entries with it;
// both hold the same translation, so A2's AND-OR of a double match is
// still the one PPN.
//
// The 32 entries' fill (the walker's, slice 2): fv_cm05h the lead, the
// payload a cycle on; the fold is ccv_common_wayfold's of the PPN, made by
// the walker before its flop (12 NGD a side leaves no room here) at the
// fill (MA-30, AR 405), so A2 sends pa_fold at 0 NGD of fold logic. The
// entry is the next of a round-robin pointer (MA-8 said LRU; round robin
// is the RTL's, and the model's CCV_MIU_L0 pricing uses the same).
//
// Flops at the defaults (NS 4, N0 4, NT 32, VPN and PPN 32, fold 4, perms
// PM): the L0s 16 x (1 + 32 + 32 + 4 + PM), the TLB 32 x the same, the
// refill path's capture, pending and A3 result, and the pointers.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_tlb #(
  parameter  int NS = ccv_params_pkg::CCV_MIU_PIPES,          // lookup slots, 4
  parameter  int N0 = 4,                                      // L0 entries a slot (MA rev 199)
  parameter  int NT = 32,                                     // TLB entries (MA-8)
  parameter  int VW = 32,                                     // VPN, VA[47:16]
  parameter  int PW = 32,                                     // PPN, PA[47:16]
  parameter  int FW = ccv_prov_pkg::CCV_W_PA_FOLD,            // pa_fold, 4
  parameter  int PM = 1,                                      // perms (slice 2's PTE)
  localparam int E0W = (N0 > 1) ? $clog2(N0) : 1,
  localparam int ETW = (NT > 1) ? $clog2(NT) : 1,
  localparam int SSW = (NS > 1) ? $clog2(NS) : 1
) (  // NS, N0 and NT powers of two: the pointers wrap by their widths
  input  logic               miu_core_clk,
  input  logic               rst_n,
  // ---- the refill: an L0 miss at A2 --------------------------------------
  input  logic [NS-1:0]      rv_cm06h,      // miu_lead's req valid (the lead)
  input  logic [NS*VW-1:0]   vpn_cm07h,     // miu_a2's leader VPN per slot
  input  logic [NS-1:0]      ms_cm07h,      // miu_a2's L0 miss per slot
  // ---- the TLB's fill (the walker's, slice 2) ----------------------------
  input  logic               fv_cm05h,
  input  logic [VW-1:0]      fvpn_cm06h,
  input  logic [PW-1:0]      fppn_cm06h,
  input  logic [FW-1:0]      ffold_cm06h,   // the walker's fold of fppn
  input  logic [PM-1:0]      fpm_cm06h,
  // ---- the L0s, read at A2 by miu_a2 (straight from flops) ---------------
  output logic [NS*N0-1:0]    l0v_cm11h,
  output logic [NS*N0*VW-1:0] l0vpn_cm11h,
  output logic [NS*N0*PW-1:0] l0ppn_cm11h,
  output logic [NS*N0*FW-1:0] l0fold_cm11h,
  output logic [NS*N0*PM-1:0] l0pm_cm11h,
  // ---- A3's miss, to the walker (slice 2) --------------------------------
  output logic               tm_cm10h,
  output logic [VW-1:0]      tmv_cm10h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge miu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- the TLB's 32 entries, written at the fill -------------------------
  logic fv_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) fv_q_cm06h <= 1'b0;
    else          fv_q_cm06h <= fv_cm05h;
  end
  logic [ETW-1:0] tp_q_cm06h;                // the next entry, round robin (own-stage state)
  wire tp_en_cm06h = fv_q_cm06h || rst_r01h;
  always_ff @(posedge miu_core_clk) begin
    if (tp_en_cm06h) tp_q_cm06h <= rst_r01h ? '0 : ETW'(tp_q_cm06h + 1'b1);
  end
  logic [NT-1:0]  te_q_cm07h;
  logic [NT*VW-1:0] tv_q_cm07h;
  logic [NT*PW-1:0] tq_q_cm07h;
  logic [NT*FW-1:0] tf_q_cm07h;
  logic [NT*PM-1:0] tm_q_cm07h;
  for (genvar e = 0; e < NT; e++) begin : g_te
    wire te_en_cm06h = (fv_q_cm06h && tp_q_cm06h == ETW'(e)) || rst_r01h;
    always_ff @(posedge miu_core_clk) begin
      if (te_en_cm06h) begin
        te_q_cm07h[e] <= !rst_r01h;
        tv_q_cm07h[e*VW +: VW] <= fvpn_cm06h;
        tq_q_cm07h[e*PW +: PW] <= fppn_cm06h;
        tf_q_cm07h[e*FW +: FW] <= ffold_cm06h;
        tm_q_cm07h[e*PM +: PM] <= fpm_cm06h;
      end
    end
  end

  // ---- the refill's capture: under this module's flop of the lead --------
  logic [NS-1:0] rq_q_cm07h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) rq_q_cm07h <= '0;
    else          rq_q_cm07h <= rv_cm06h;
  end
  logic [NS*VW-1:0] vq_q_cm08h;
  for (genvar s = 0; s < NS; s++) begin : g_cap
    wire vq_en_cm07h = rq_q_cm07h[s];
    always_ff @(posedge miu_core_clk) begin
      if (vq_en_cm07h) vq_q_cm08h[s*VW +: VW] <= vpn_cm07h[s*VW +: VW];
    end
  end

  // ---- A3: pending and the grant; the compare a cycle on -------------------------------
  logic [NS-1:0]  pm_q_cm08h;                // a refill pending on the slot
  logic [SSW-1:0] rr_q_cm08h;                // the round robin's next slot
  logic [NS-1:0]  gnt_cm08h;
  always_comb begin
    gnt_cm08h = '0;
    for (int k = NS - 1; k >= 0; k--)         // the first pending at or after rr
      if (pm_q_cm08h[SSW'(rr_q_cm08h + SSW'(k))]) gnt_cm08h = NS'(1) << SSW'(rr_q_cm08h + SSW'(k));
  end
  logic [SSW-1:0] gi_cm08h;
  always_comb begin
    gi_cm08h = '0;
    for (int s = 0; s < NS; s++) if (gnt_cm08h[s]) gi_cm08h |= SSW'(s);
  end
  wire any_cm08h = |pm_q_cm08h;
  wire pm_en_cm07h = (|rq_q_cm07h) || any_cm08h || rst_r01h;
  always_ff @(posedge miu_core_clk) begin
    if (pm_en_cm07h)
      for (int s = 0; s < NS; s++)
        pm_q_cm08h[s] <= rst_r01h ? 1'b0
                       : rq_q_cm07h[s] ? ms_cm07h[s]
                       : pm_q_cm08h[s] && !gnt_cm08h[s];
  end
  wire rr_en_cm08h = any_cm08h || rst_r01h;
  always_ff @(posedge miu_core_clk) begin
    if (rr_en_cm08h) rr_q_cm08h <= rst_r01h ? '0 : SSW'(gi_cm08h + 1'b1);
  end

  logic [VW-1:0] sv_cm08h;                   // the granted slot's VPN
  always_comb begin
    sv_cm08h = '0;
    for (int s = 0; s < NS; s++) sv_cm08h |= {VW{gnt_cm08h[s]}} & vq_q_cm08h[s*VW +: VW];
  end
  // ---- the grant and its VPN, flopped before the compare (31 NGD in one) --
  logic          sa_q_cm09h;                 // a refill was granted
  logic [NS-1:0] sg_q_cm09h;                 // its slot
  logic [VW-1:0] sv_q_cm09h;                 // its VPN
  wire sa_en_cm08h = any_cm08h || sa_q_cm09h || rst_r01h;
  always_ff @(posedge miu_core_clk) begin
    if (sa_en_cm08h) sa_q_cm09h <= !rst_r01h && any_cm08h;
  end
  wire sg_en_cm08h = any_cm08h;
  always_ff @(posedge miu_core_clk) begin
    if (sg_en_cm08h) begin
      sg_q_cm09h <= gnt_cm08h;
      sv_q_cm09h <= sv_cm08h;
    end
  end

  logic [NT-1:0] m_cm09h;
  logic [PW-1:0] p_cm09h;
  logic [FW-1:0] f_cm09h;
  logic [PM-1:0] g_cm09h;
  always_comb begin
    p_cm09h = '0;
    f_cm09h = '0;
    g_cm09h = '0;
    for (int e = 0; e < NT; e++) begin
      m_cm09h[e] = te_q_cm07h[e] && tv_q_cm07h[e*VW +: VW] == sv_q_cm09h;
      p_cm09h |= {PW{m_cm09h[e]}} & tq_q_cm07h[e*PW +: PW];
      f_cm09h |= {FW{m_cm09h[e]}} & tf_q_cm07h[e*FW +: FW];
      g_cm09h |= {PM{m_cm09h[e]}} & tm_q_cm07h[e*PM +: PM];
    end
  end

  // ---- A3's result, flopped ----------------------------------------------
  logic          ra_q_cm10h;                 // a refill was compared
  logic          rh_q_cm10h;                 // and hit
  logic [NS-1:0] rs_q_cm10h;                 // its slot
  logic [PW-1:0] rp_q_cm10h;
  logic [FW-1:0] rf_q_cm10h;
  logic [PM-1:0] rg_q_cm10h;
  (* keep *) logic [VW-1:0] rv_q_cm10h;      // the VPN, into the L0
  (* keep *) logic [VW-1:0] rvo_q_cm10h;     // its copy for tmv
  (* keep *) logic          tmo_q_cm10h;     // the miss, for tm
  wire ra_en_cm09h = sa_q_cm09h || ra_q_cm10h || rst_r01h;
  always_ff @(posedge miu_core_clk) begin
    if (ra_en_cm09h) begin
      ra_q_cm10h  <= !rst_r01h && sa_q_cm09h;
      tmo_q_cm10h <= !rst_r01h && sa_q_cm09h && !(|m_cm09h);
    end
  end
  wire rp_en_cm09h = sa_q_cm09h;
  always_ff @(posedge miu_core_clk) begin
    if (rp_en_cm09h) begin
      rh_q_cm10h  <= |m_cm09h;
      rs_q_cm10h  <= sg_q_cm09h;
      rp_q_cm10h  <= p_cm09h;
      rf_q_cm10h  <= f_cm09h;
      rg_q_cm10h  <= g_cm09h;
      rv_q_cm10h  <= sv_q_cm09h;
      rvo_q_cm10h <= sv_q_cm09h;
    end
  end
  assign tm_cm10h  = tmo_q_cm10h;
  assign tmv_cm10h = rvo_q_cm10h;

  // ---- the L0s: written at A3 + 1, a round-robin pointer per slot --------
  for (genvar s = 0; s < NS; s++) begin : g_l0
    wire w_cm10h = ra_q_cm10h && rh_q_cm10h && rs_q_cm10h[s];
    logic [E0W-1:0] wp_q_cm10h;                // own-stage state
    wire wp_en_cm10h = w_cm10h || rst_r01h;
    always_ff @(posedge miu_core_clk) begin
      if (wp_en_cm10h) wp_q_cm10h <= rst_r01h ? '0 : E0W'(wp_q_cm10h + 1'b1);
    end
    for (genvar e = 0; e < N0; e++) begin : g_e
      localparam int I = s * N0 + e;
      wire l0_en_cm10h = (w_cm10h && wp_q_cm10h == E0W'(e)) || rst_r01h;
      logic          v_q_cm11h;
      logic [VW-1:0] vpn_q_cm11h;
      logic [PW-1:0] ppn_q_cm11h;
      logic [FW-1:0] fold_q_cm11h;
      logic [PM-1:0] pm_q_cm11h;
      always_ff @(posedge miu_core_clk) begin
        if (l0_en_cm10h) begin
          v_q_cm11h    <= !rst_r01h;
          vpn_q_cm11h  <= rv_q_cm10h;
          ppn_q_cm11h  <= rp_q_cm10h;
          fold_q_cm11h <= rf_q_cm10h;
          pm_q_cm11h   <= rg_q_cm10h;
        end
      end
      assign l0v_cm11h[I]               = v_q_cm11h;
      assign l0vpn_cm11h[I*VW +: VW]    = vpn_q_cm11h;
      assign l0ppn_cm11h[I*PW +: PW]    = ppn_q_cm11h;
      assign l0fold_cm11h[I*FW +: FW]   = fold_q_cm11h;
      assign l0pm_cm11h[I*PM +: PM]     = pm_q_cm11h;
    end
  end

  // A refill is granted only while one is pending, and one at a time.
  `CCV_ASSERT(gnt_one, $onehot0(gnt_cm08h) && ((gnt_cm08h & ~pm_q_cm08h) == '0) &&
                       (any_cm08h == (|gnt_cm08h)))

endmodule
`undef CCV_CLK
`undef CCV_RST
