//===-- miu_agu8.sv - MIU A1 address generation, 8 lanes of one slot ------===//
//
// Spec: docs/design-snapshots/miu-spec.md (live: CCV per-block architecture
//       specs, MIU tab, "MA's Phase 2", slice 1 (rev 163): the stage table's
//       H row, the module partition's miu_agu8 row and the port budgets).
//
// One instance per address slot s and lane octet u (16). In A1 (H, tag 05)
// each of its 8 lanes forms the AGU's 3-input sum (section 5.1, O-79, O-80):
//
//   .global: (base << 16) + (index << scale) + disp
//   .shared:  base        + (index << scale) + disp   (modulo 2^32)
//
// base and index are the lane's 32-bit words from miu_cap (a narrow register
// arrives zero-extended, O-79); disp is the memop's, sign-extended from
// CCV_W_DISP; scale is log2 of the transfer, when scale_en, the transfer
// being xfer_size's (1 or 2 bytes, O-80) or else chwidth's span. The sum is
// exact: kept to VW = 50 bits, two's complement, which covers every value
// the three can make ((-2^28, 2^48 + 2^34)), so A2 raises F-ADDR on a
// .global lane whose bits [49:48] are not 0 (O-75: the sum is never
// wrapped) and reports its address in full, the 50 bits sign-extended
// (section 12.6). F-ALIGN (O-58) is checked here, beside the sum: an active
// lane whose low address bits are not 0 at the transfer's size; a byte is
// always aligned.
//
// Flops (tag 06, A2): the 8 lanes' sums and their align faults, ilv, loc,
// ow (an ordinary .global access) and the lanes' window compares, 419 at
// the default sizes, one clock gate enabled by this module's flop of miu_cap's
// valid (CG-5): a new address is in A1 exactly the cycle after it. A lane's
// sum is held whether or not it is active; A2 reads only active lanes.
//
// The forms (MI-21 (a), MI-25 (D); miu_form's flops at H, MI-22): a slot
// form's base is its window word, every lane's, by a 2:1 ahead of the add,
// its select and window this octet's (* keep *) copies from miu_form. The
// local form (O-69) and an interleaved .global access (O-83) need no adder
// of their own (MA's (D), MA rev 191): W is a multiple of 2^k, so an
// interleaved lane's b = S - (W << 16) is S's low 16 + k bits by wiring,
// F-ADDR is S >> (16 + k) != W >> k at A2, and its address is R(ctx) with
// b rearranged (only the leader's VPN takes a (5 + k)-bit add, miu_lead's
// or A2's); the local form's address is miu_form's per-slot C with the lane
// at [6:2]. So A1 here is the ordinary sum S, and the two flags A2 reads to
// pick the form: ilv, O-83's decision (lane d's rbase >> k against W >> k,
// every lane's compare in parallel, the one-hot of d picking, beside the
// adders, for a .global memop in neither form: fs's elig), and loc. F-ALIGN
// stays here: an interleaved lane's two low bits are S's, a local lane's
// disp's.
//
// The window F-ADDR's compare (O-83, IS's rev 171) is here too, beside the
// adders: S[47:16+k] == W >> k, on the carry-save pair (no carry chain but
// the low 16 + k bits'), a flop a lane. A2 (miu_a2) makes it the fault: an
// interleaved lane's b outside [0, L) where it is false, an ordinary
// .global lane in the run's own windows where it is true. S[49:48] (F-ADDR, O-75) needs the whole sum, so
// it is A2's (miu_a2). Not here: the
// predicate transfers' single address (l = 0, lane d's b), miu_lead's.
//
// Inputs are miu_cap's and miu_pair's flops (arrival 0; MIU tab, "Port NGD
// budgets": the adders take the whole 25), and every output comes straight
// from a flop.
//
// The reference is the MIU model's AGU (sim/miu/miu_block.cpp, "The AGU
// (section 5.1)"), and test/miu/agu8_tb.cpp holds this module to a value
// model of it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_agu8 #(
  parameter  int NL = 8,                                  // lanes, one octet
  parameter  int WL = 32,                                 // a lane's base and index
  parameter  int DW = ccv_params_pkg::CCV_W_DISP,         // disp, 29
  parameter  int CW = ccv_params_pkg::CCV_W_CHWIDTH,      // chwidth, 2
  parameter  int VW = 50,                                 // the exact sum
  parameter  int IW = ccv_params_pkg::CCV_W_LANE_MASK,    // a slot's lanes, 32
  parameter  int PW = ccv_prov_pkg::CCV_PRIV_WINDOWS,     // 1
  parameter  int LC = 0,                                  // 1: lc_cm06h, lane 0's line again (MA rev 209)
  localparam int PK = $clog2(PW),                         // k
  localparam int WHW = 32 - PK                            // wh: W >> k
) (
  input  logic             miu_core_clk,
  input  logic             rst_n,
  // miu_cap's valid a cycle on: the slot's address lands in its flops now.
  input  logic             v_cm04h,
  // A1: the octet's lanes from miu_cap, held from H.
  input  logic [NL-1:0]    am_cm05h,      // active_mask
  input  logic [NL*WL-1:0] base_cm05h,    // base_per_lane
  input  logic [NL*WL-1:0] idx_cm05h,     // index_per_lane
  // A1: the slot's memop fields from miu_pair, held from H.
  input  logic [DW-1:0]    disp_cm05h,
  input  logic             shared_cm05h,  // space: 0 .global, 1 .shared
  // The transfer, decoded by miu_pair a stage earlier (from xfer_size,
  // chwidth and scale_en): sh1/sh2 the index's scale (one-hot with 0, both
  // clear for 0), b4/b2 a 4- or 2-byte transfer (else 1), for F-ALIGN.
  input  logic             sh1_cm05h,
  input  logic             sh2_cm05h,
  input  logic             b4_cm05h,
  input  logic             b2_cm05h,
  // A1: the slot's forms, miu_form's flops at H.
  input  logic [31:0]      win_cm05h,     // the slot form's window, this octet's copy
  input  logic             sl_cm05h,      // the slot form, this octet's copy
  input  logic [2:0]       fs_cm05h,      // {elig, local, slot}; the slot bit unread
  input  logic [WHW-1:0]   wh_cm05h,      // W >> k
  input  logic [IW-1:0]    dh_cm05h,      // lane d's one-hot
  // A1: every lane's base, for O-83's decision on lane d (miu_cap's).
  input  logic [IW*WL-1:0] bw_cm05h,
  // A2: each lane's ordinary sum and its align fault; O-83's decision and
  // the local form, for A2 to pick the form by wiring (MI-25 (D)).
  output logic [NL*VW-1:0] va_cm06h,
  output logic [NL-1:0]    fal_cm06h,
  output logic             ilv_cm06h,
  output logic             loc_cm06h,
  output logic             ow_cm06h,      // an ordinary .global access
  output logic [NL-1:0]    we_cm06h,      // each lane's S[47:16+k] == W >> k
  // Lane 0's line, VA[47:7], a (* keep *) copy for miu_grp's far compares
  // (MA rev 209); 0 and no flops at LC = 0.
  output logic [40:0]      lc_cm06h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge miu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- The valid, a cycle on: an address in A1 (CG-5) --------------------
  logic v_q_cm05h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) v_q_cm05h <= 1'b0;
    else          v_q_cm05h <= v_cm04h;
  end

  // A Kogge-Stone carry-propagate add: log2(VW) prefix levels, fanout 2,
  // so the mapper keeps a shallow carry tree rather than a ripple.
  function automatic logic [VW-1:0] ks_add(input logic [VW-1:0] a, input logic [VW-1:0] b);
    logic [VW-1:0] g, p, gn, pn;
    g = a & b;
    p = a ^ b;
    for (int d = 1; d < VW; d = d * 2) begin
      gn = g;
      pn = p;
      for (int i = d; i < VW; i = i + 1) begin
        gn[i] = g[i] | (p[i] & g[i-d]);
        pn[i] = p[i] & p[i-d];
      end
      g = gn;
      p = pn;
    end
    ks_add = (a ^ b) ^ {g[VW-2:0], 1'b0};
  endfunction

  // The carry out of a + b, LW bits, by the same prefix.
  localparam int LW = 16 + PK;
  function automatic logic ks_cout(input logic [LW-1:0] a, input logic [LW-1:0] b);
    logic [LW-1:0] g, p;
    g = a & b;
    p = a ^ b;
    for (int d = 1; d < LW; d = d * 2)
      for (int i = LW - 1; i >= d; i--) begin
        g[i] = g[i] | (p[i] & g[i-d]);
        p[i] = p[i] & p[i-d];
      end
    ks_cout = g[LW-1];
  endfunction

  // ---- The slot's terms: O-83's decision on lane d (MI-25 (D)) ---------
  logic dec_cm05h, ilv_cm05h, loc_cm05h, slt_cm05h, ow_cm05h;
  always_comb begin
    dec_cm05h = 1'b0;
    for (int i = 0; i < IW; i++)
      dec_cm05h = dec_cm05h | (dh_cm05h[i] & (bw_cm05h[i*WL + PK +: WHW] == wh_cm05h));
    slt_cm05h = sl_cm05h;
    loc_cm05h = fs_cm05h[1];
    ilv_cm05h = fs_cm05h[2] & dec_cm05h;
    ow_cm05h  = !shared_cm05h && !loc_cm05h && !ilv_cm05h;
  end

  // ---- Per lane: the ordinary sum S and F-ALIGN ---------------------------
  // (D): an interleaved lane's b is S - (W << 16), S's low 16 + k bits by
  // wiring (W a multiple of 2^k), and its range test S >> (16 + k) == W >> k
  // is A2's; the local form's address is miu_form's C with the lane at
  // [6:2], also A2's. Both keep S's (and disp's) two low bits, so F-ALIGN
  // stays here.
  logic [NL*VW-1:0] va_d_cm05h;
  logic [NL-1:0]    fal_d_cm05h, we_d_cm05h;
  for (genvar l = 0; l < NL; l = l + 1) begin : g_lane
    logic [WL-1:0] b_cm05h, x_cm05h;
    logic [VW-1:0] ob_cm05h, ox_cm05h, od_cm05h, s_cm05h, cs_cm05h, cc_cm05h;
    logic [1:0]    lo_cm05h;
    logic [WHW-1:0] wa_cm05h, wb_cm05h, wz_cm05h;
    logic          wc_cm05h, weq_cm05h;
    always_comb begin
      b_cm05h  = slt_cm05h ? win_cm05h : base_cm05h[l*WL +: WL];
      x_cm05h  = idx_cm05h[l*WL +: WL];
      ob_cm05h = shared_cm05h ? VW'(b_cm05h) : VW'({b_cm05h, 16'b0});
      ox_cm05h = ({VW{sh2_cm05h}} & (VW'(x_cm05h) << 2)) |
                 ({VW{sh1_cm05h}} & (VW'(x_cm05h) << 1)) |
                 ({VW{!sh1_cm05h && !sh2_cm05h}} & VW'(x_cm05h));
      od_cm05h = VW'(signed'(disp_cm05h));
      cs_cm05h = ob_cm05h ^ ox_cm05h ^ od_cm05h;
      cc_cm05h = ((ob_cm05h & ox_cm05h) | (ob_cm05h & od_cm05h) | (ox_cm05h & od_cm05h)) << 1;
      s_cm05h  = ks_add(cs_cm05h, cc_cm05h);
      lo_cm05h = loc_cm05h ? disp_cm05h[1:0] : s_cm05h[1:0];
      va_d_cm05h[l*VW +: VW] = s_cm05h;
      fal_d_cm05h[l] = am_cm05h[l] &&
                       ((b4_cm05h && (lo_cm05h != 2'b00)) || (b2_cm05h && lo_cm05h[0]));
      // The window compare beside the add: S[47:16+k] == W >> k from the
      // carry-save pair. With A, B the pair's bits [47:16+k] and c the carry
      // into bit 16 + k, A + B + c == K (mod 2^n) exactly when A ^ B ^ K ==
      // {Z[n-2:0], c}, Z = A & B | (A | B) & ~K (no carry chain past c).
      wa_cm05h  = cs_cm05h[16+PK +: WHW];
      wb_cm05h  = cc_cm05h[16+PK +: WHW];
      wc_cm05h  = ks_cout(cs_cm05h[LW-1:0], cc_cm05h[LW-1:0]);
      wz_cm05h  = (wa_cm05h & wb_cm05h) | ((wa_cm05h | wb_cm05h) & ~wh_cm05h);
      weq_cm05h = ((wa_cm05h[WHW-1:1] ^ wb_cm05h[WHW-1:1] ^ wh_cm05h[WHW-1:1]) == wz_cm05h[WHW-2:0]) &&
                  ((wa_cm05h[0] ^ wb_cm05h[0] ^ wh_cm05h[0]) == wc_cm05h);
      we_d_cm05h[l] = weq_cm05h;
    end
  end

  // ---- Flops: A2's lanes -------------------------------------------------
  wire va_en_cm05h = v_q_cm05h;
  (* keep *) logic [NL*VW-1:0] va_q_cm06h;   // never merged with lc_q (NGD-7)
  logic [NL-1:0]    fal_q_cm06h;
  logic [NL-1:0]    we_q_cm06h;
  logic             ilv_q_cm06h, loc_q_cm06h, ow_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (va_en_cm05h) begin
      va_q_cm06h  <= va_d_cm05h;
      fal_q_cm06h <= fal_d_cm05h;
      ilv_q_cm06h <= ilv_cm05h;
      loc_q_cm06h <= loc_cm05h;
      ow_q_cm06h  <= ow_cm05h;
      we_q_cm06h  <= we_d_cm05h;
    end
  end
  assign va_cm06h  = va_q_cm06h;
  assign fal_cm06h = fal_q_cm06h;
  assign ilv_cm06h = ilv_q_cm06h;
  assign loc_cm06h = loc_q_cm06h;
  assign ow_cm06h  = ow_q_cm06h;
  assign we_cm06h  = we_q_cm06h;

  if (LC != 0) begin : g_lc
    (* keep *) logic [40:0] lc_q_cm06h;
    always_ff @(posedge miu_core_clk) begin
      if (va_en_cm05h) lc_q_cm06h <= va_d_cm05h[7 +: 41];
    end
    assign lc_cm06h = lc_q_cm06h;
  end else begin : g_nlc
    assign lc_cm06h = '0;
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
