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
// Flops (tag 06, A2): the 8 lanes' sums and their align faults, 408 at the
// default sizes, one clock gate enabled by this module's flop of miu_cap's
// valid (CG-5): a new address is in A1 exactly the cycle after it. A lane's
// sum is held whether or not it is active; A2 reads only active lanes.
//
// The forms (MI-21 (a); miu_form's flops at H, MI-22): a slot form's base
// is its window word, every lane's, by a 2:1 ahead of the add. The local
// form (O-69) and an interleaved .global access (O-83) take a second,
// narrow sum per lane, beside the first: over NN bits, one carry-save level
// over the index (scaled) with ones at [6:2], disp with zeros there and,
// for O-83, rbase's k low bits (rbase - W, W being aligned) at [20+k:21],
// then a carry-propagate add, so bit 1's carry reaches bit 7; bits [6:2]
// are then the lane's index l. R(ctx) is added on top (MI-23 (b)): its
// low bits [NN-1:16] by a 6-bit add after the sum, and its high part from
// miu_form's {hi + 1, hi, lo8} and ctx by an 8-bit add beside the sum,
// picked by the carries. The local form has no index or rbase term, and b
// is disp. O-83's decision is lane d's: every lane's rbase >> k against W >>
// k, in parallel, and the one-hot of d (miu_form's dh) picks the result,
// beside the adders; a .global memop in neither form (fs's elig) whose
// decision holds is interleaved. Each lane's b = ((rbase - W) << 16) +
// (rindex << scale) + disp is formed exactly beside it, and b outside
// [0, L) is F-ADDR (fad) on an interleaved active lane, whose address is
// then the ordinary sum, as the model leaves it. The last select, ordinary
// or narrow, follows both adders.
//
// Not here: an access decided ordinary into the run's own windows (also
// F-ADDR; O-83, IS's rev 171), which compares the full 50-bit sum with W
// and so belongs to A2 (miu_a2, from ilv and W >> k); and predicate
// transfers' single address (l = 0, lane d's b), miu_lead's.
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
  parameter  int CXW = ccv_prov_pkg::CCV_P_W_DEV_CORE + ccv_params_pkg::CCV_W_WARP_ID,   // ctx, 7
  parameter  int PW = ccv_prov_pkg::CCV_PRIV_WINDOWS,     // 1
  localparam int PK = $clog2(PW),                         // k
  localparam int NN = (21 + PK > 22) ? 21 + PK : 22,      // the narrow sum
  localparam int BL = NN - 16,                            // R's bits below NN, above 16
  localparam int HH = VW - NN - 8,                        // R's hi, 20
  localparam int RK = CXW + 2 * HH + 8 + BL,              // miu_form's rk, 61
  localparam int WHW = 32 - PK,
  localparam int MWL = NN - 19,                           // -W's bits in the narrow sum, 3
  localparam int BW = 51                                  // b, exact, signed
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
  // The lane octet u: lanes 8u to 8u + 7, a constant the parent ties.
  input  logic [1:0]       oct_cm05h,
  // A1: the slot's forms, miu_form's flops at H.
  input  logic [31:0]      win_cm05h,     // the slot form's window
  input  logic [2:0]       fs_cm05h,      // {elig, local, slot}
  input  logic [WHW-1:0]   wh_cm05h,      // W >> k
  input  logic [MWL-1:0]   mw_cm05h,      // -W's low bits, at rbase's place
  input  logic [RK-1:0]    rk_cm05h,      // {ctx, hi + 1, hi, lo8, bl}
  input  logic [IW-1:0]    dh_cm05h,      // lane d's one-hot
  // A1: every lane's base, for O-83's decision on lane d (miu_cap's).
  input  logic [IW*WL-1:0] bw_cm05h,
  // A2: each lane's address and its align fault; O-83's F-ADDR on b and
  // the decision.
  output logic [NL*VW-1:0] va_cm06h,
  output logic [NL-1:0]    fal_cm06h,
  output logic [NL-1:0]    fad_cm06h,
  output logic             ilv_cm06h
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

  // ---- The slot's terms: O-83's decision and R(ctx)'s high part --------
  logic          dec_cm05h, ilv_cm05h, loc_cm05h, slt_cm05h;
  logic [NN-1:0] rlo_cm05h;              // R's bits below NN (zero below 16)
  logic [VW-NN-1:0] rh0_cm05h, rh1_cm05h; // R's high part, and plus 1
  logic [VW-1:0] dr_cm05h;               // disp rewired plus R's low bits
  always_comb begin
    logic [CXW-1:0] ctx;
    logic [HH-1:0]  hi, hi1;
    logic [7:0]     lo8;
    logic [BL-1:0]  bl;
    logic [63:0]    cs;
    logic [NN:0]    lo;
    logic [8:0]     t, s0, s1;
    logic [VW-1:0]  od;
    logic [NN+1:0]  dp, dl, dm, ds, dc;
    // Lane d's decision: each lane's compare, picked by the one-hot.
    dec_cm05h = 1'b0;
    for (int i = 0; i < IW; i++)
      dec_cm05h = dec_cm05h | (dh_cm05h[i] & (bw_cm05h[i*WL + PK +: WHW] == wh_cm05h));
    slt_cm05h = fs_cm05h[0];
    loc_cm05h = fs_cm05h[1];
    ilv_cm05h = fs_cm05h[2] & dec_cm05h;
    // R(ctx) = (base << 16) + (ctx << S): S is 22 for O-69, 21 + k for O-83.
    {ctx, hi1, hi, lo8, bl} = rk_cm05h;
    cs = loc_cm05h ? (64'(ctx) << 22) : (64'(ctx) << (21 + PK));
    lo = (NN+1)'({bl, 16'b0}) + (NN+1)'(cs[NN-1:0]);
    t  = 9'(cs >> NN) + 9'(lo[NN]);
    s0 = 9'(lo8) + t;
    s1 = 9'(lo8) + t + 9'(1);
    rlo_cm05h = lo[NN-1:0];
    // disp rewired (zeros at [6:2]) plus R's bits [NN-1:16], and for O-83
    // -W at rbase's place (bit 21), once for the slot's lanes: the narrow
    // sum is then each lane's index and rbase plus this.
    od = VW'(signed'(disp_cm05h));
    dp = (NN+2)'({od[NN-4:2], 5'b00000, od[1:0]});
    dl = (NN+2)'({lo[NN-1:16], 16'b0});
    dm = loc_cm05h ? '0 : (NN+2)'({mw_cm05h, 21'b0});
    ds = dp ^ dl ^ dm;
    dc = ((dp & dl) | (dp & dm) | (dl & dm)) << 1;
    dr_cm05h = ks_add(VW'(ds), VW'(dc));
    rh0_cm05h = {s0[8] ? hi1 : hi, s0[7:0]};
    rh1_cm05h = {s1[8] ? hi1 : hi, s1[7:0]};
  end

  // ---- Per lane: the sums and the faults ---------------------------------
  logic [NL*VW-1:0] va_d_cm05h;
  logic [NL-1:0]    fal_d_cm05h, fad_d_cm05h;
  for (genvar l = 0; l < NL; l = l + 1) begin : g_lane
    logic [WL-1:0] b_cm05h, x_cm05h;
    logic [VW-1:0] ob_cm05h, ox_cm05h, od_cm05h, s_cm05h, cs_cm05h, cc_cm05h, v_cm05h;
    logic [NN+1:0] na_cm05h, nk_cm05h, nr_cm05h, ns_cm05h, nc_cm05h;
    logic [NN+1:0] n_cm05h;
    logic [BW-1:0] ba_cm05h, bd_cm05h, bk_cm05h, bm_cm05h, bt_cm05h, bu_cm05h, bs_cm05h, bc_cm05h;
    logic [BW-17-PK:0] bw_wh_cm05h, bh_cm05h, bg_cm05h, bx_cm05h, bo_cm05h;
    logic          bl_cm05h;
    logic [VW-1:0] nw_cm05h, bw16_cm05h;
    logic [VW-1:0] iv_cm05h;
    logic          in_cm05h, use_cm05h;
    always_comb begin
      b_cm05h  = slt_cm05h ? win_cm05h : base_cm05h[l*WL +: WL];
      x_cm05h  = idx_cm05h[l*WL +: WL];
      ob_cm05h = shared_cm05h ? VW'(b_cm05h) : VW'({b_cm05h, 16'b0});
      ox_cm05h = ({VW{sh2_cm05h}} & (VW'(x_cm05h) << 2)) |
                 ({VW{sh1_cm05h}} & (VW'(x_cm05h) << 1)) |
                 ({VW{!sh1_cm05h && !sh2_cm05h}} & VW'(x_cm05h));
      od_cm05h = VW'(signed'(disp_cm05h));
      // The ordinary sum: one carry-save level, then one carry-propagate add.
      cs_cm05h = ob_cm05h ^ ox_cm05h ^ od_cm05h;
      cc_cm05h = ((ob_cm05h & ox_cm05h) | (ob_cm05h & od_cm05h) | (ox_cm05h & od_cm05h)) << 1;
      s_cm05h  = ks_add(cs_cm05h, cc_cm05h);
      // The narrow sum, b rewired, at NN + 2 bits, its operands sign-
      // extended: the lane's index (none for the local form) with ones at
      // [6:2], the lane's rbase at bit 21 (b's bit 16), and the slot's
      // disp, R low bits and -W, already summed (dr). For b in [0, L) the
      // sum is exact, so bit NN is R's carry: R_hi or R_hi + 1, with no add
      // after it.
      na_cm05h = loc_cm05h ? (NN+2)'(5'b11111 << 2)
                           : {ox_cm05h[NN-4:2], 5'b11111, ox_cm05h[1:0]};
      nr_cm05h = dr_cm05h[NN+1:0];
      nk_cm05h = loc_cm05h ? '0 : (NN+2)'({b_cm05h, 21'b0});
      ns_cm05h = na_cm05h ^ nk_cm05h ^ nr_cm05h;
      nc_cm05h = ((na_cm05h & nk_cm05h) | (na_cm05h & nr_cm05h) | (nk_cm05h & nr_cm05h)) << 1;
      nw_cm05h = ks_add(VW'(ns_cm05h), VW'(nc_cm05h));
      n_cm05h  = nw_cm05h[NN+1:0];
      iv_cm05h = {n_cm05h[NN] ? rh1_cm05h : rh0_cm05h, n_cm05h[NN-1:7],
                  oct_cm05h, 3'(l), n_cm05h[1:0]};
      // b = ((rbase - W) << 16) + (index << s) + disp, exact, beside, each
      // lane from its own rbase: in [0, L) when its bits from 16 + k up
      // are 0. -W is ~W + 1, the 1 at bit 16 + k (W a multiple of 2^k):
      // four operands, two carry-save levels, and the high part tested for
      // all ones, the 1's place.
      ba_cm05h = BW'(ox_cm05h);
      bd_cm05h = BW'(signed'(disp_cm05h));
      bk_cm05h = BW'({b_cm05h, 16'b0});
      bw_wh_cm05h = (BW-16-PK)'(wh_cm05h);
      bm_cm05h = {~bw_wh_cm05h, (16+PK)'(0)};
      bt_cm05h = ba_cm05h ^ bd_cm05h ^ bk_cm05h;
      bu_cm05h = ((ba_cm05h & bd_cm05h) | (ba_cm05h & bk_cm05h) | (bd_cm05h & bk_cm05h)) << 1;
      bs_cm05h = bt_cm05h ^ bu_cm05h ^ bm_cm05h;
      bc_cm05h = ((bt_cm05h & bu_cm05h) | (bt_cm05h & bm_cm05h) | (bu_cm05h & bm_cm05h)) << 1;
      // No add: the high part's sum is all ones, for either carry into it
      // (A + B + c = -1 exactly when ~(A ^ B) = ((A & B) << 1) | c), picked
      // by the low part's carry.
      bh_cm05h = bs_cm05h[BW-1:16+PK];
      bg_cm05h = bc_cm05h[BW-1:16+PK];
      bx_cm05h = ~(bh_cm05h ^ bg_cm05h);
      bo_cm05h = (bh_cm05h & bg_cm05h) << 1;
      bw16_cm05h = ks_add(VW'(bs_cm05h[15+PK:0]), VW'(bc_cm05h[15+PK:0]));
      bl_cm05h = bw16_cm05h[16+PK];
      in_cm05h = bl_cm05h ? (bx_cm05h == (bo_cm05h | (BW-16-PK)'(1))) : (bx_cm05h == bo_cm05h);
      // The last select: the narrow sum for the local form, and for an
      // interleaved lane whose b is in range.
      use_cm05h = loc_cm05h || (ilv_cm05h && in_cm05h);
      v_cm05h   = use_cm05h ? iv_cm05h : s_cm05h;
      va_d_cm05h[l*VW +: VW] = v_cm05h;
      fad_d_cm05h[l] = am_cm05h[l] && ilv_cm05h && !in_cm05h;
      fal_d_cm05h[l] = am_cm05h[l] &&
                       ((b4_cm05h && (v_cm05h[1:0] != 2'b00)) || (b2_cm05h && v_cm05h[0]));
    end
  end

  // ---- Flops: A2's lanes -------------------------------------------------
  // A guarded payload: read only through its memop, so it is written
  // whenever its group is clocked and holds nothing of its own.
  wire va_en_cm05h = v_q_cm05h;
  logic [NL*VW-1:0] va_q_cm06h;
  logic [NL-1:0]    fal_q_cm06h, fad_q_cm06h;
  logic             ilv_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (va_en_cm05h) begin
      va_q_cm06h  <= va_d_cm05h;
      fal_q_cm06h <= fal_d_cm05h;
      fad_q_cm06h <= fad_d_cm05h;
      ilv_q_cm06h <= ilv_cm05h;
    end
  end
  assign va_cm06h  = va_q_cm06h;
  assign fal_cm06h = fal_q_cm06h;
  assign fad_cm06h = fad_q_cm06h;
  assign ilv_cm06h = ilv_q_cm06h;

endmodule
`undef CCV_CLK
`undef CCV_RST
