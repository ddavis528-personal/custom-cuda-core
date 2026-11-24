//===-- miu_lead.sv - MIU A1 group leaders, set-index lead and the valid --===//
//
// Spec: docs/design-snapshots/miu-spec.md (live: CCV per-block architecture
//       specs, MIU tab, "MA's Phase 2", slice 1: the stage table's H row,
//       the module partition's miu_lead row, "Pipes, lane groups and lookup
//       slots", "The drop"), MI-25 (D) (MA revs 191, 195) for the forms, and
//       MI-27 (MA rev 196): A1 is (b), the narrow sum.
//
// A memop of footprint F (4, 2 or 1 pipes) arrives on address slot s, its
// lead pipe ctz(pipes) = s, and owns the lookup slots of its pipes. Its 32
// lanes split into F groups of 32/F consecutive lanes, group g on the
// footprint's g-th slot, and a group's lookup is the line of its lowest
// active lane, its leader (MA-4), chosen by lane position, never by an
// address compare (AR 362 (2)).
//
// A1 (H, tag 05), (b) of MI-27: a first-pass lookup is a .global load,
// whose base sits at bit 16 and up (the slot form's window too), so below
// bit 16 a lane's sum is (index << scale) + disp. Per lane, three 16-bit
// 2-input adds (scale 0, 1, 2) of the index's low bits and its four lanes'
// copy of disp (miu_pair's a1q, (* keep *) per four lanes, so no disp flop
// drives more than 12 adders), bits [15:2] kept; per address slot and lane
// quarter (8 lanes) one AND-OR on the quarter's lowest active lane and its
// scale picks 14 bits of the 24 sums (both selects early; the scale off
// the adders' path). The form's select joins the route's AND-OR likewise. A group of 16 or 32 lanes takes its first quarter with
// an active lane. Lookup slot k takes the group of the memop whose pipes
// hold k (footprints are disjoint, V-60, so at most one).
//
// The set index (lead_set_index: address bits [15:7]) is a field select on
// that sum, with no add (MI-25 (D) (4)): S[15:7] for an ordinary or
// slot-form access; S[10:2] for an interleaved one (O-83: the address below
// bit 16 is {b >> 2, l, b[1:0]}); disp[10:2] for the local form (O-69: C's
// bits [15:7]). Its low bits are the bank (AR 364).
//
// The gate, on every bank (MI-27 (1)): all of used[b] ? ge2[b] : ge1[b],
// miu_cred's flops ge1/ge2 and used[b], this module's flop of its own
// launches last cycle, so the gate reads no bank of the sum.
//
// The leader's whole sum is A2's (MI-27 (2) (i)): A2 picks S from
// miu_agu8's flops by an AND-OR on the one-hot leader this module flops,
// its lane and its address slot.
//
// Flops (tag 06, H+1), each output from its own: per lookup slot, the req
// valid (DCU and, as the spend, miu_cred) and lead_set_index; the
// leader's lane one-hot and address-slot one-hot (A2). Inside, (* keep *)
// copies: the valid and the bank, for used[b].
//
// Inputs are miu_cap's, miu_pair's, miu_form's and miu_cred's flops (arrival
// 0; MIU tab, "Port NGD budgets"), and every output comes straight from a
// flop.
//
// The reference is the MIU model's leadersOf and the A1 gate
// (sim/miu/miu_block.cpp), and test/miu/lead_tb.cpp holds this module to a
// value model of them.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_lead #(
  parameter  int NS = ccv_params_pkg::CCV_MIU_PIPES,          // address and lookup slots, 4
  parameter  int NL = ccv_params_pkg::CCV_W_LANE_MASK,        // lanes, 32
  parameter  int WL = 32,                                     // a lane's base
  parameter  int NB = ccv_params_pkg::CCV_DCU_BANKS,          // banks, 8
  parameter  int PW = ccv_prov_pkg::CCV_PRIV_WINDOWS,         // 1
  localparam int SW = 9,                                      // lead_set_index: [15:7]
  localparam int BW = (NB > 1) ? $clog2(NB) : 1,
  localparam int NQ = NL / 8,                                 // lane quarters, 4
  localparam int PK = $clog2(PW),
  localparam int WHW = WL - PK
) (
  input  logic                miu_core_clk,
  input  logic                rst_n,
  // miu_cap's valids a cycle on: slot s's address lands in its flops now.
  input  logic [NS-1:0]       v_cm04h,
  // A1: slot s may launch first-pass lookups (a global load on its first
  // A1, contracted, with no hold A1 knows from flopped state).
  input  logic [NS-1:0]       ld_cm05h,
  // A1: the slot's memop fields (miu_pair's flops): its pipes, and per four
  // lanes h a copy of {sh2, sh1, disp[15:0]} at [(s*NQ*2 + h)*18 +: 18].
  input  logic [NS*NS-1:0]    pipes_cm05h,
  input  logic [NS*NQ*2*18-1:0] dq_cm05h,
  // A1: every lane's operands (miu_cap's flops): the mask, the base (the
  // window decision's) and the index's low 16 bits.
  input  logic [NS*NL-1:0]    am_cm05h,
  input  logic [NS*NL*WL-1:0] base_cm05h,
  input  logic [NS*NL*16-1:0] idx_cm05h,
  // A1: the forms (miu_form's flops at H).
  input  logic [NS*3-1:0]     fs_cm05h,      // {interleaved-eligible, local, slot}
  input  logic [NS*WHW-1:0]   wh_cm05h,
  input  logic [NS*NL-1:0]    dh_cm05h,
  // The gate (miu_cred's flops).
  input  logic [NB-1:0]       ge1_cm05h,
  input  logic [NB-1:0]       ge2_cm05h,
  // H+1: lookup slot k's req valid and lead_set_index (DCU), and the spend
  // (miu_cred).
  output logic [NS-1:0]       rv_cm06h,
  output logic [NS*SW-1:0]    lsi_cm06h,
  // A2: lookup slot k's leader: its lane one-hot and address-slot one-hot.
  output logic [NS*NL-1:0]    lo_cm06h,
  output logic [NS*NS-1:0]    so_cm06h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge miu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- The valids, a cycle on: an address in A1 (CG-5) -------------------
  logic [NS-1:0] v_q_cm05h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) v_q_cm05h <= '0;
    else          v_q_cm05h <= v_cm04h;
  end

  function automatic logic [15:0] ks16(input logic [15:0] a, input logic [15:0] b);
    logic [15:0] g, p, gn, pn;
    g = a & b;
    p = a ^ b;
    for (int d = 1; d < 16; d = d * 2) begin
      gn = g;
      pn = p;
      for (int i = d; i < 16; i = i + 1) begin
        gn[i] = g[i] | (p[i] & g[i-d]);
        pn[i] = p[i] & p[i-d];
      end
      g = gn;
      p = pn;
    end
    ks16 = (a ^ b) ^ {g[14:0], 1'b0};
  endfunction

  // ---- The gate, every bank -------------------------------------------------
  logic [NB-1:0] used_cm05h;
  logic          gt_cm05h;
  assign gt_cm05h = &((used_cm05h & ge2_cm05h) | (~used_cm05h & ge1_cm05h));

  // ---- Per address slot and quarter: the leader and its set index --------
  logic [NS*NQ*SW-1:0] qi_cm05h;     // ordinary: S[15:7]
  logic [NS*NQ*SW-1:0] qj_cm05h;     // interleaved: S[10:2]
  logic [NS*NQ*8-1:0]  qo_cm05h;     // the quarter leader's one-hot
  logic [NS*NQ-1:0]    qh_cm05h;     // the quarter has an active lane
  logic [NS-1:0]       sil_cm05h, slc_cm05h;   // the slot's form: interleaved, local
  for (genvar s = 0; s < NS; s = s + 1) begin : g_slot
    always_comb begin
      // Lane d's base by its one-hot, then one compare with W >> k.
      logic [WHW-1:0] bd;
      bd = '0;
      for (int i = 0; i < NL; i++)
        bd = bd | ({WHW{dh_cm05h[s*NL + i]}} & base_cm05h[(s*NL + i)*WL + PK +: WHW]);
      sil_cm05h[s] = fs_cm05h[s*3 + 2] & (bd == wh_cm05h[s*WHW +: WHW]);
      slc_cm05h[s] = fs_cm05h[s*3 + 1];
    end
    for (genvar q = 0; q < NQ; q = q + 1) begin : g_q
      logic [15:0]     d_cm05h, e_cm05h;   // lanes 0-3's copy of disp, 4-7's
      logic            sh1_cm05h, sh2_cm05h;
      logic [8*42-1:0] lix_cm05h;    // per lane, the sums at scale 0, 1, 2, bits [15:2]
      logic [7:0]      amq_cm05h, oh_cm05h;
      logic [13:0]     ix_cm05h;
      always_comb begin
        d_cm05h   = dq_cm05h[(s*NQ + q)*36 +: 16];
        e_cm05h   = dq_cm05h[(s*NQ + q)*36 + 18 +: 16];
        sh1_cm05h = dq_cm05h[(s*NQ + q)*36 + 16];
        sh2_cm05h = dq_cm05h[(s*NQ + q)*36 + 17];
        for (int i = 0; i < 8; i++)
          for (int c = 0; c < 3; c++) begin
            logic [15:0] t;
            t = ks16(idx_cm05h[(s*NL + q*8 + i)*16 +: 16] << c, i < 4 ? d_cm05h : e_cm05h);
            lix_cm05h[(i*3 + c)*14 +: 14] = t[15:2];
          end
        amq_cm05h = am_cm05h[s*NL + q*8 +: 8];
        for (int i = 0; i < 8; i++)
          oh_cm05h[i] = amq_cm05h[i] && ((amq_cm05h & ((8'd1 << i) - 8'd1)) == 8'd0);
        // The pick and the scale in one AND-OR: the selects (the lane's
        // one-hot and the scale, both from flops) are early, the sums late.
        ix_cm05h = '0;
        for (int i = 0; i < 8; i++)
          for (int c = 0; c < 3; c++) begin
            logic sel;
            sel = oh_cm05h[i] && (c == 2 ? sh2_cm05h : c == 1 ? (sh1_cm05h && !sh2_cm05h) :
                                                        !(sh1_cm05h || sh2_cm05h));
            ix_cm05h = ix_cm05h | ({14{sel}} & lix_cm05h[(i*3 + c)*14 +: 14]);
          end
        // Both fields; the slot's form picks after the route.
        qi_cm05h[(s*NQ + q)*SW +: SW] = ix_cm05h[5 +: SW];
        qj_cm05h[(s*NQ + q)*SW +: SW] = ix_cm05h[0 +: SW];
        qo_cm05h[(s*NQ + q)*8 +: 8]   = oh_cm05h;
        qh_cm05h[s*NQ + q]            = |amq_cm05h;
      end
    end
  end

  // ---- Lookup slot k: its group's leader ---------------------------------
  // Slot s's memop owns k when pipes_s[k]; its group is g = the pipes below
  // k, of F = |pipes|, the quarters [g * 4/F, (g + 1) * 4/F); the leader is
  // the first of them with an active lane. One-hot over (s, q).
  logic [NS*NS*NQ-1:0] rsel_cm05h;   // [k][s][q]
  always_comb begin
    rsel_cm05h = '0;
    for (int s = 0; s < NS; s++) begin
      logic [NS-1:0] pp;
      logic [NQ-1:0] h;
      logic          a4, a2, a1;
      pp = pipes_cm05h[s*NS +: NS];
      h  = qh_cm05h[s*NQ +: NQ];
      a4 = &pp;                                    // footprint 4: quarter k
      a1 = (pp & (pp - NS'(1))) == '0;             // footprint 1: the first quarter
      a2 = !a4 && !a1;                             // footprint 2: a half each
      for (int k = s; k < NS; k++) begin
        logic act, up;
        act = v_q_cm05h[s] && ld_cm05h[s] && pp[k];
        up  = k != s;                              // footprint 2's second group
        for (int q = 0; q < NQ; q++) begin
          logic first4, firsth;
          first4 = h[q] && ((h & ((NQ'(1) << q) - NQ'(1))) == '0);
          firsth = h[q] && ((q % 2 == 0) || !h[q & ~1]);
          rsel_cm05h[(k*NS + s)*NQ + q] = act && (
              (a4 && q == k && h[q]) ||
              (a2 && ((q >= 2) == up) && firsth) ||
              (a1 && first4));
        end
      end
    end
  end

  // The selected leader per lookup slot, its set index and the gate.
  logic [NS-1:0]    rv_d_cm05h;
  logic [NS*SW-1:0] lsi_d_cm05h;
  logic [NS*NL-1:0] lo_d_cm05h;
  logic [NS*NS-1:0] so_d_cm05h;
  always_comb begin
    for (int k = 0; k < NS; k++) begin
      logic [SW-1:0] si;
      logic          any;
      si = '0; any = 1'b0;
      lo_d_cm05h[k*NL +: NL] = '0;
      so_d_cm05h[k*NS +: NS] = '0;
      for (int s = 0; s < NS; s++)
        for (int q = 0; q < NQ; q++) begin
          logic h;
          h   = rsel_cm05h[(k*NS + s)*NQ + q];
          any = any | h;
          // The route and the form in one AND-OR (the form's selects are
          // early): local disp[10:2], interleaved S[10:2], else S[15:7].
          si  = si | ({SW{h && slc_cm05h[s]}} & dq_cm05h[(s*NQ + q)*36 + 2 +: SW]) |
                     ({SW{h && !slc_cm05h[s] && sil_cm05h[s]}} & qj_cm05h[(s*NQ + q)*SW +: SW]) |
                     ({SW{h && !slc_cm05h[s] && !sil_cm05h[s]}} & qi_cm05h[(s*NQ + q)*SW +: SW]);
          lo_d_cm05h[k*NL + q*8 +: 8] = lo_d_cm05h[k*NL + q*8 +: 8] |
                                         ({8{h}} & qo_cm05h[(s*NQ + q)*8 +: 8]);
          so_d_cm05h[k*NS + s] = so_d_cm05h[k*NS + s] | h;
        end
      rv_d_cm05h[k]             = any && gt_cm05h;
      lsi_d_cm05h[k*SW +: SW]   = si;
    end
  end

  // ---- Flops: H+1 ----------------------------------------------------------
  // The valids with a memop in A1, or the cycle after a launch to clear
  // them (CG-5: both from this module's own flops); the payload, a guarded
  // one read only under the valid, with a memop in A1. Two (* keep *)
  // copies of the valid and of the bank: one drives the port, the other
  // used[b] (a register that drives an output is held on every path it
  // starts to that output's budget).
  (* keep *) logic [NS-1:0]    ru_q_cm05h;
  (* keep *) logic [NS-1:0]    rvo_q_cm06h;
  (* keep *) logic [NS*BW-1:0] bk_q_cm05h;
  wire pay_en_cm05h = |v_q_cm05h;
  wire rv_en_cm05h  = pay_en_cm05h || (|ru_q_cm05h) || rst_r01h;
  always_ff @(posedge miu_core_clk) begin
    if (rv_en_cm05h) begin
      ru_q_cm05h  <= rst_r01h ? '0 : rv_d_cm05h;
      rvo_q_cm06h <= rst_r01h ? '0 : rv_d_cm05h;
    end
  end
  (* keep *) logic [NS*SW-1:0] lsi_q_cm06h;
  logic [NS*NL-1:0] lo_q_cm06h;
  logic [NS*NS-1:0] so_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (pay_en_cm05h) begin
      lsi_q_cm06h <= lsi_d_cm05h;
      lo_q_cm06h  <= lo_d_cm05h;
      so_q_cm06h  <= so_d_cm05h;
      for (int k = 0; k < NS; k++) bk_q_cm05h[k*BW +: BW] <= lsi_d_cm05h[k*SW +: BW];
    end
  end
  always_comb begin
    used_cm05h = '0;
    for (int k = 0; k < NS; k++)
      used_cm05h = used_cm05h | ({NB{ru_q_cm05h[k]}} & (NB'(1) << bk_q_cm05h[k*BW +: BW]));
  end
  assign rv_cm06h  = rvo_q_cm06h;
  assign lsi_cm06h = lsi_q_cm06h;
  assign lo_cm06h  = lo_q_cm06h;
  assign so_cm06h  = so_q_cm06h;

  // A valid launches only with a memop in A1 (its payload's enable).
  `CCV_ASSERT(rv_pay, (rv_d_cm05h == '0) || pay_en_cm05h)

endmodule
`undef CCV_CLK
`undef CCV_RST
