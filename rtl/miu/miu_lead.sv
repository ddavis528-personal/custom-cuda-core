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
// footprint's g-th slot, and a group's lookup is the line of its leader
// (MA-4): its first lane by position, fixed (MA rev 199, re:MI-31), never
// an address compare (AR 362 (2)). The lookup launches when the group has
// an active lane; when the leader lane is not one, A2 drops it (the memop
// finishes in passes).
//
// A1 (H, tag 05), (b) of MI-27: a first-pass lookup is a .global load,
// whose base sits at bit 16 and up (the slot form's window too), so below
// bit 16 a lane's sum is (index << scale) + disp. A leader is a quarter's
// lane 0, so per address slot and quarter only that lane adds: three
// 16-bit 2-input adds (scale 0, 1, 2) of its index's low bits and the
// quarter's copy of disp (miu_pair's a1q, one per quarter), the scale
// picking after. A group of 16 or 32 lanes takes its first quarter.
// Lookup slot k takes the group of the memop whose pipes hold k
// (footprints are disjoint, V-60, so at most one); the route's AND-OR over
// (address slot, quarter) carries the form's select too.
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
// The leader's whole sum is A2's: miu_a2 picks S from miu_agu8's flops by
// an AND-OR on the (address slot, quarter) one-hot this module flops (at
// most three are possible per lookup slot). For an interleaved leader's
// VPN this module flops its low part beside the sum, l6 = {0, S[15:11]} +
// bl (one 3-input 18-bit add per scale, less 32 when S's own add carries
// out of bit 15), and R(ctx)'s VPN[31:6] for l6's carry 0 and 1 (lo8 +
// ctx and + 1, each carry picking hi or hi + 1, as miu_form's C), so A2
// takes the VPN by one 2:1 (miu_a2: 23.3 NGD, MI-32).
//
// Flops (tag 06, H+1), each output from its own: per lookup slot, the req
// valid (DCU and, as the spend, miu_cred) and lead_set_index; for A2 the
// leader's (address slot, quarter) one-hot, its lane's activity, the form
// {interleaved, local}, l6 and R(ctx)'s two VPN highs. Inside, (* keep *)
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
  localparam int WHW = WL - PK,
  localparam int RK = 61                                      // miu_form's rk (k = 0)
) (
  input  logic                miu_core_clk,
  input  logic                rst_n,
  // miu_cap's valids a cycle on: slot s's address lands in its flops now.
  input  logic [NS-1:0]       v_cm04h,
  // A1: slot s may launch first-pass lookups (a global load on its first
  // A1, contracted, with no hold A1 knows from flopped state).
  input  logic [NS-1:0]       ld_cm05h,
  // A1: the slot's memop fields (miu_pair's flops): its pipes, and per lane
  // quarter q a copy of {sh2, sh1, disp[15:0]} at [(s*NQ + q)*18 +: 18].
  input  logic [NS*NS-1:0]    pipes_cm05h,
  input  logic [NS*NQ*18-1:0] dq_cm05h,
  // A1: every lane's operands (miu_cap's flops): the mask, the base (the
  // window decision's) and the index's low 16 bits.
  input  logic [NS*NL-1:0]    am_cm05h,
  input  logic [NS*NL*WL-1:0] base_cm05h,
  input  logic [NS*NL*16-1:0] idx_cm05h,
  // A1: the forms (miu_form's flops at H).
  input  logic [NS*3-1:0]     fs_cm05h,      // {interleaved-eligible, local, slot}
  input  logic [NS*WHW-1:0]   wh_cm05h,
  input  logic [NS*NL-1:0]    dh_cm05h,
  input  logic [NS*RK-1:0]    rk_cm05h,      // {ctx, hi + 1, hi, lo8, bl}, miu_form's
  // The gate (miu_cred's flops).
  input  logic [NB-1:0]       ge1_cm05h,
  input  logic [NB-1:0]       ge2_cm05h,
  // H+1: lookup slot k's req valid and lead_set_index (DCU), and the spend
  // (miu_cred).
  output logic [NS-1:0]       rv_cm06h,
  output logic [NS*SW-1:0]    lsi_cm06h,
  // A2: lookup slot k's fixed leader (MA rev 199): its (address slot,
  // quarter) one-hot at [k*NS*NQ + s*NQ + q], the lane q*8 of slot s; that
  // lane active; the form {interleaved, local}; and the interleaved VPN's
  // parts: l6 = {0, S[15:11]} + bl (VPN[5:0] and the carry), and R(ctx)'s
  // VPN[31:6] for carry 0 and 1 (26 bits each, rh at [k*52 +: 52], carry 0
  // low).
  output logic [NS*NS*NQ-1:0] lq_cm06h,
  output logic [NS-1:0]       la_cm06h,
  output logic [NS*2-1:0]     fm_cm06h,
  output logic [NS*7-1:0]     l6_cm06h,
  output logic [NS*52-1:0]    rh_cm06h
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

  // S[15:11] + bl, beside the sum: a 3:2 of the two operands' low 16 bits
  // and bl << 11, one 18-bit add, bits [17:11]; less 32 when the 16-bit sum
  // carries out of bit 15 (S is that sum's low 16 bits).
  function automatic logic [6:0] l6f(input logic [15:0] a, input logic [15:0] b, input logic [5:0] c);
    logic [17:0] x, y, u, v, g, p, gn, pn;
    logic [16:0] w;
    x = {2'b0, a};
    y = {2'b0, b};
    u = {1'b0, c, 11'b0};
    v = x ^ y ^ u;
    w = (x[16:0] & y[16:0]) | (x[16:0] & u[16:0]) | (y[16:0] & u[16:0]);
    g = v & {w, 1'b0};
    p = v ^ {w, 1'b0};
    for (int d = 1; d < 18; d = d * 2) begin
      gn = g;
      pn = p;
      for (int i = d; i < 18; i = i + 1) begin
        gn[i] = g[i] | (p[i] & g[i-d]);
        pn[i] = p[i] & p[i-d];
      end
      g = gn;
      p = pn;
    end
    x = (v ^ {w, 1'b0}) ^ {g[16:0], 1'b0};
    w = 17'(a) + 17'(b);
    l6f = x[17:11] - {w[16], 5'b0};
  endfunction

  // ---- The gate, every bank -------------------------------------------------
  logic [NB-1:0] used_cm05h;
  logic          gt_cm05h;
  assign gt_cm05h = &((used_cm05h & ge2_cm05h) | (~used_cm05h & ge1_cm05h));

  // ---- Per address slot and quarter: the first lane's sum ----------------
  // The fixed leader (MA rev 199) is a group's first lane by position, a
  // quarter's lane 0, so a quarter adds only that lane: its sums at scale 0,
  // 1 and 2, the scale picking after.
  logic [NS*NQ*SW-1:0] qi_cm05h;     // ordinary: S[15:7]
  logic [NS*NQ*SW-1:0] qj_cm05h;     // interleaved: S[10:2]
  logic [NS*NQ*7-1:0]  q6_cm05h;     // {0, S[15:11]} + bl, the interleaved VPN's low bits
  logic [NS*NQ-1:0]    qh_cm05h;     // the quarter has an active lane
  logic [NS*NQ-1:0]    qa_cm05h;     // its lane 0 is active
  logic [NS-1:0]       sil_cm05h, slc_cm05h;   // the slot's form: interleaved, local
  logic [NS*52-1:0]    sr_cm05h;     // the slot's R(ctx) VPN[31:6], carry 0 and 1
  for (genvar s = 0; s < NS; s = s + 1) begin : g_slot
    always_comb begin
      // Lane d's base by its one-hot, then one compare with W >> k.
      logic [WHW-1:0] bd;
      logic [8:0]     t0, t1;
      logic [6:0]     cx;
      logic [7:0]     l8;
      logic [19:0]    h0, h1;
      bd = '0;
      for (int i = 0; i < NL; i++)
        bd = bd | ({WHW{dh_cm05h[s*NL + i]}} & base_cm05h[(s*NL + i)*WL + PK +: WHW]);
      sil_cm05h[s] = fs_cm05h[s*3 + 2] & (bd == wh_cm05h[s*WHW +: WHW]);
      slc_cm05h[s] = fs_cm05h[s*3 + 1];
      // R(ctx) as miu_form's C: lo8 + ctx, and + 1 for a carry from below;
      // each carry picks hi or hi + 1 (no add after the sum's).
      {cx, h1, h0, l8} = rk_cm05h[s*RK + 6 +: RK - 6];
      t0 = 9'(l8) + 9'(cx);
      t1 = 9'(l8) + 9'(cx) + 9'd1;
      sr_cm05h[s*52 +: 52] = {t1[8] ? h1[17:0] : h0[17:0], t1[7:0],
                              t0[8] ? h1[17:0] : h0[17:0], t0[7:0]};
    end
    for (genvar q = 0; q < NQ; q = q + 1) begin : g_q
      logic [15:0] d_cm05h, ix_cm05h;
      logic        sh1_cm05h, sh2_cm05h;
      logic [47:0] lix_cm05h;        // lane 0's sums at scale 0, 1, 2
      logic [20:0] l6x_cm05h;        // and its l6 at each
      always_comb begin
        d_cm05h   = dq_cm05h[(s*NQ + q)*18 +: 16];
        sh1_cm05h = dq_cm05h[(s*NQ + q)*18 + 16];
        sh2_cm05h = dq_cm05h[(s*NQ + q)*18 + 17];
        for (int c = 0; c < 3; c++)
        begin
          lix_cm05h[c*16 +: 16] = ks16(idx_cm05h[(s*NL + q*8)*16 +: 16] << c, d_cm05h);
          l6x_cm05h[c*7 +: 7]   = l6f(idx_cm05h[(s*NL + q*8)*16 +: 16] << c, d_cm05h,
                                      rk_cm05h[s*RK +: 6]);
        end
        ix_cm05h = ({16{sh2_cm05h}} & lix_cm05h[32 +: 16]) |
                   ({16{sh1_cm05h && !sh2_cm05h}} & lix_cm05h[16 +: 16]) |
                   ({16{!(sh1_cm05h || sh2_cm05h)}} & lix_cm05h[0 +: 16]);
        qi_cm05h[(s*NQ + q)*SW +: SW] = ix_cm05h[7 +: SW];
        qj_cm05h[(s*NQ + q)*SW +: SW] = ix_cm05h[2 +: SW];
        q6_cm05h[(s*NQ + q)*7 +: 7]   = ({7{sh2_cm05h}} & l6x_cm05h[14 +: 7]) |
                                        ({7{sh1_cm05h && !sh2_cm05h}} & l6x_cm05h[7 +: 7]) |
                                        ({7{!(sh1_cm05h || sh2_cm05h)}} & l6x_cm05h[0 +: 7]);
        qh_cm05h[s*NQ + q]            = |am_cm05h[s*NL + q*8 +: 8];
        qa_cm05h[s*NQ + q]            = am_cm05h[s*NL + q*8];
      end
    end
  end

  // ---- Lookup slot k: its group's fixed leader -----------------------------
  // Slot s's memop owns k when pipes_s[k]; its group is g = the pipes below
  // k, of F = |pipes|, the quarters [g * 4/F, (g + 1) * 4/F); the leader is
  // the first of them's lane 0. One-hot over (s, q); the lookup launches if
  // the group has an active lane (A2 drops it if the leader is not one).
  logic [NS*NS*NQ-1:0] rsel_cm05h;   // [k][s][q]
  logic [NS-1:0]       ga_cm05h;     // slot k's group has an active lane
  always_comb begin
    rsel_cm05h = '0;
    ga_cm05h   = '0;
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
        for (int q = 0; q < NQ; q++)
          rsel_cm05h[(k*NS + s)*NQ + q] = act && (
              (a4 && q == k) || (a2 && q == (up ? 2 : 0)) || (a1 && q == 0));
        ga_cm05h[k] = ga_cm05h[k] | (act && (
              (a4 && h[k]) || (a2 && (up ? (h[2] || h[3]) : (h[0] || h[1]))) || (a1 && (|h))));
      end
    end
  end

  // The leader's fields per lookup slot, routed by the one-hot, and the gate.
  logic [NS-1:0]    rv_d_cm05h, la_d_cm05h;
  logic [NS*SW-1:0] lsi_d_cm05h;
  logic [NS*2-1:0]  fm_d_cm05h;
  logic [NS*7-1:0]  l6_d_cm05h;
  logic [NS*52-1:0] rh_d_cm05h;
  always_comb begin
    for (int k = 0; k < NS; k++) begin
      logic [SW-1:0] si;
      logic [6:0]    s6;
      logic [51:0]   r;
      logic          la, il, lc;
      si = '0; s6 = '0; r = '0; la = 1'b0; il = 1'b0; lc = 1'b0;
      for (int s = 0; s < NS; s++)
        for (int q = 0; q < NQ; q++) begin
          logic h;
          h  = rsel_cm05h[(k*NS + s)*NQ + q];
          // The route and the form in one AND-OR (the form's selects are
          // early): local disp[10:2], interleaved S[10:2], else S[15:7].
          si = si | ({SW{h && slc_cm05h[s]}} & dq_cm05h[(s*NQ + q)*18 + 2 +: SW]) |
                    ({SW{h && !slc_cm05h[s] && sil_cm05h[s]}} & qj_cm05h[(s*NQ + q)*SW +: SW]) |
                    ({SW{h && !slc_cm05h[s] && !sil_cm05h[s]}} & qi_cm05h[(s*NQ + q)*SW +: SW]);
          s6 = s6 | ({7{h}} & q6_cm05h[(s*NQ + q)*7 +: 7]);
          r  = r  | ({52{h}} & sr_cm05h[s*52 +: 52]);
          la = la | (h && qa_cm05h[s*NQ + q]);
          il = il | (h && !slc_cm05h[s] && sil_cm05h[s]);
          lc = lc | (h && slc_cm05h[s]);
        end
      rv_d_cm05h[k]           = ga_cm05h[k] && gt_cm05h;
      lsi_d_cm05h[k*SW +: SW] = si;
      la_d_cm05h[k]           = la;
      fm_d_cm05h[k*2 +: 2]    = {il, lc};
      l6_d_cm05h[k*7 +: 7]    = s6;
      rh_d_cm05h[k*52 +: 52]  = r;
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
  logic [NS*NS*NQ-1:0] lq_q_cm06h;
  logic [NS-1:0]       la_q_cm06h;
  logic [NS*2-1:0]     fm_q_cm06h;
  logic [NS*7-1:0]     l6_q_cm06h;
  logic [NS*52-1:0]    rh_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (pay_en_cm05h) begin
      lsi_q_cm06h <= lsi_d_cm05h;
      lq_q_cm06h  <= rsel_cm05h;
      la_q_cm06h  <= la_d_cm05h;
      fm_q_cm06h  <= fm_d_cm05h;
      l6_q_cm06h  <= l6_d_cm05h;
      rh_q_cm06h  <= rh_d_cm05h;
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
  assign lq_cm06h  = lq_q_cm06h;
  assign la_cm06h  = la_q_cm06h;
  assign fm_cm06h  = fm_q_cm06h;
  assign l6_cm06h  = l6_q_cm06h;
  assign rh_cm06h  = rh_q_cm06h;

  // A valid launches only with a memop in A1 (its payload's enable).
  `CCV_ASSERT(rv_pay, (rv_d_cm05h == '0) || pay_en_cm05h)

endmodule
`undef CCV_CLK
`undef CCV_RST
