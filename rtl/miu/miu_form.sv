//===-- miu_form.sv - MIU address forms: windows, local base, W, R(ctx) ---===//
//
// Spec: MI-21 (MA's decision, MA tab rev 176; MIU tab rev 165, O-45, O-69
//       and O-83), with the ports MI drafted in MI-22 and R(ctx) by MI-23
//       (b). Not yet a row of the MIU tab's partition.
//
// One instance, beside miu_pair at H-1. It owns the state the slot, local
// and private-window forms read, so that miu_agu8 and miu_lead see only
// flops at H:
//
//   - the launch-slot window table (O-45): 8 CTA slots x 16 windows x 32
//     bits, with a valid bit each, filled from the launch block's lines;
//   - per CTA slot, from ccv_rau_miu_cta's local_base at the CTA's dispatch
//     (TI-47 (a)): O-69's region bits above its narrow sum, O-83's W >> k
//     and its region bits above the narrow sum.
//
// At H-1, for each address slot k, it reads miu_mq's A1 view at the entry
// miu_pair paired (its own 40:1 read of the few fields it needs, so nothing
// crosses a port combinationally), then the CTA slot's state, and flops at
// H (tag 05):
//
//   win  the launch slot's window word, for the slot form's base
//   wv   that window's valid bit: a slot form with wv clear is an L1 miss
//   fs   {elig, local, slot}: elig, a .global memop in neither form whose
//        CTA's run lies below 2^32 windows, may be interleaved (O-83)
//   wh   W >> k, against which miu_agu8 compares each lane's rbase >> k
//   rk   the CTA's region bits for R(ctx), O-69's for the local form, else
//        O-83's: {hi + 1, hi, lo8, bl}, and ctx, from which miu_agu8 forms
//        R(ctx) beside its narrow sum (below)
//   dh   the one-hot of lane d, the issue mask's lowest lane (O-83's
//        decision is lane d's)
//
// R(ctx) (MI-23 (b)): O-69's region is ((local_base + LC) << 16) +
// (ctx << 22) and O-83's ((W + PW) << 16) + (ctx << (21 + k)). Neither base
// need be aligned (the two differ by 2 LC + PW windows, so both cannot be),
// so R is a sum, not wiring. Each CTA's write keeps, per region, its base's
// bits below the narrow sum and its high part split as {hi, lo8}, with hi
// and hi + 1 both kept. ctx's few bits add into lo8 and the carry picks hi
// or hi + 1, giving R_hi and R_hi + 1 with no wide add. That add is
// miu_agu8's, at H, in parallel with its narrow sum (it needs neither the
// lanes nor the sum), so this stage carries only the reads. cta_range
// asserts each base below 2^33 windows, so R fits VW.
//
// Not here yet: the window fill's source (miu_rsp, a launch-block line's
// window words, fv_cm01h and its fields are the port it will drive) and
// the kill's clear of the valid bits, whose trigger MA is to name.
//
// Flops: the table (4,096 + 128), the CTA state (8 x (1 + RB + WHW))
// and the H flops (4 x (4 x 33 + 1 + 3 + WHW + RK + 32)). Clock gates: each window
// word on its fill; each CTA slot's valid bits on its write or fill; each
// CTA slot's state on its write; the H flops on this module's flop of
// miu_pair's pairing enable (CG-5), which is set exactly the cycle a slot
// pairs. The H flops are a guarded payload, read only under miu_pair's a1v.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_form #(
  parameter  int NS  = ccv_params_pkg::CCV_MIU_PIPES,          // slots, 4
  parameter  int NE  = ccv_params_pkg::CCV_MIU_PIPES * ccv_prov_pkg::CCV_MEMOP_CREDITS,   // 40
  // miu_mq's A1 view, as miu_pair reads it (63).
  parameter  int FW  = ccv_params_pkg::CCV_W_WARP_ID + ccv_prov_pkg::CCV_P_W_CTA_SLOT +
                       ccv_prelim_pkg::CCV_L_W_MEM_OP + ccv_params_pkg::CCV_W_CHWIDTH +
                       ccv_params_pkg::CCV_MIU_PIPES + ccv_params_pkg::CCV_W_DISP + 1 +
                       ccv_params_pkg::CCV_L_W_SPACE + ccv_params_pkg::CCV_L_W_ORDERING + 1 + 4 + 1 + 2 + 1,
  parameter  int IW  = ccv_params_pkg::CCV_W_LANE_MASK,        // issue_mask, 32
  parameter  int CSW = ccv_prov_pkg::CCV_P_W_CTA_SLOT,         // 3
  parameter  int WIW = ccv_params_pkg::CCV_W_WARP_ID,          // 5
  parameter  int DCW = ccv_prov_pkg::CCV_P_W_DEV_CORE,       // 2
  parameter  int CORE = ccv_prov_pkg::CCV_P_CORE_ID,         // the strap
  parameter  int LC  = ccv_prov_pkg::CCV_LANE_CONTEXTS,      // 4096
  parameter  int PW  = ccv_prov_pkg::CCV_PRIV_WINDOWS,       // 1
  parameter  int LBW = ccv_params_pkg::CCV_W_VA - 16,          // local_base, 48
  parameter  int VW  = 50,                                     // miu_agu8's exact sum
  localparam int NC  = 1 << CSW,                               // CTA slots, 8
  localparam int NO  = IW / 8,                                 // lane octets a slot, 4
  localparam int NWN = 16,                                     // launch-slot windows
  localparam int EW  = $clog2(NE),
  localparam int CXW = DCW + WIW,                              // ctx, 7
  localparam int PK  = $clog2(PW),                             // k
  localparam int NN  = (21 + PK > 22) ? 21 + PK : 22,          // the narrow sum's width
  localparam int RHW = VW - NN,                                // rh0, rh1: 28
  localparam int WHW = 32 - PK,                                // wh: rbase >> k
  localparam int RK  = CXW + 2 * (RHW - 8) + 8 + NN - 16       // rk: 61
) (
  input  logic             miu_core_clk,
  input  logic             rst_n,
  // ---- the CTA's arrival: ccv_rau_miu_cta's capture, its valid leading
  // its fields by a cycle (RST-1, CG-5) -----------------------------------
  input  logic             ctv_cm01h,
  input  logic [CSW-1:0]   ctc_cm02h,      // cta_slot
  input  logic [LBW-1:0]   ctl_cm02h,      // local_base, a window index
  // ---- the window fill: a launch-block line's windows; the valid, then
  // the CTA slot and the windows the line holds, then their words ---------
  input  logic             fv_cm01h,
  input  logic [CSW-1:0]   fc_cm02h,       // its CTA slot
  input  logic [NWN-1:0]   fm_cm02h,       // the windows the line holds
  input  logic [NWN*32-1:0] fw_cm03h,      // window j's word at [j*32 +: 32]
  // ---- H-1: miu_pair's pairing ------------------------------------------
  input  logic             pen_cm03h,      // a row pairs now: its slots' H next
  input  logic [NS*EW-1:0] pe_cm04h,       // slot k's entry at [k*EW +: EW]
  // miu_mq's A1 view and its issue masks, entry e's at [e*FW], [e*IW].
  input  logic [NE*FW-1:0] mqa_cm02h,
  input  logic [NE*IW-1:0] mqi_cm02h,
  // ---- H: slot k's forms ------------------------------------------------
  // win and fs's slot bit, one (* keep *) copy per lane octet: slot k
  // octet u's at [(k*NO + u)*32 +: 32] and [k*NO + u] (MI-22 (c)).
  output logic [NS*NO*32-1:0] win_cm05h,
  output logic [NS*NO-1:0]  sl_cm05h,
  output logic [NS-1:0]     wv_cm05h,
  output logic [NS*3-1:0]   fs_cm05h,      // {elig, local, slot} at [k*3 +: 3]
  output logic [NS*WHW-1:0] wh_cm05h,
  output logic [NS*RK-1:0]  rk_cm05h,      // {ctx, hi + 1, hi, lo8, bl}
  output logic [NS*IW-1:0]  dh_cm05h,
  // O-69's address less the lane, per slot (MI-25 (D) (3)), at A2 beside
  // miu_agu8's sums: C = ((local_base + LC) << 16) + (ctx << 22) +
  // 128 (b / 4) + b % 4, b the memop's disp, unsigned 17 bits (MA rev 195);
  // a lane's address is C with 4l in bits [6:2], which are 0. Meaningful
  // for a local-form slot only.
  output logic [NS*VW-1:0]  c_cm06h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge miu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- The A1 view's fields (LSB first: xfer_signed, xfer_size,
  // local_form, arg_slot, slot_form, ordering, space, scale_en, disp,
  // pipes, chwidth, mem_op, cta_slot, warp_id), as miu_pair's decode.
  localparam int LF_L = 3;
  localparam int AS_L = 4;
  localparam int SF_L = 8;
  localparam int SP_L = 9 + ccv_params_pkg::CCV_L_W_ORDERING;
  localparam int DS_L = SP_L + 2;                    // disp, above space and scale_en
  localparam int CS_L = FW - WIW - CSW;
  localparam int WI_L = FW - WIW;

  // ---- The writes' capture: each valid flopped, then its fields under it,
  // so every table enable comes from this module's flops (CG-5) ---------
  logic           ctv_q_cm02h, ctv_q_cm03h, fv_q_cm02h, fv_q_cm03h;
  logic [NC-1:0]  cth_q_cm03h, fch_q_cm03h;   // cta_slot one-hot: the enables
  logic [LBW-1:0] ctl_q_cm03h;
  (* keep *) logic [LBW-1:0] ctp_q_cm03h;   // local_base again, for the p adds alone
  logic [NWN-1:0] fm_q_cm03h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) begin
      ctv_q_cm02h <= 1'b0;
      ctv_q_cm03h <= 1'b0;
      fv_q_cm02h  <= 1'b0;
      fv_q_cm03h  <= 1'b0;
    end else begin
      ctv_q_cm02h <= ctv_cm01h;
      ctv_q_cm03h <= ctv_q_cm02h;
      fv_q_cm02h  <= fv_cm01h;
      fv_q_cm03h  <= fv_q_cm02h;
    end
  end
  wire ctf_en_cm02h = ctv_q_cm02h;
  always_ff @(posedge miu_core_clk) begin
    if (ctf_en_cm02h) begin
      cth_q_cm03h <= NC'(1) << ctc_cm02h;
      ctl_q_cm03h <= ctl_cm02h;
      ctp_q_cm03h <= ctl_cm02h;
    end
  end
  wire ff_en_cm02h = fv_q_cm02h;
  always_ff @(posedge miu_core_clk) begin
    if (ff_en_cm02h) begin
      fch_q_cm03h <= NC'(1) << fc_cm02h;
      fm_q_cm03h <= fm_cm02h;
    end
  end

  // ---- The CTA state, written at the CTA's arrival -----------------------
  // x = local_base + LC, O-69's region base; w = local_base + 3 LC, O-83's
  // W; p = W + PW, O-83's region base. Kept per region: the base's BL bits
  // below the narrow sum (R_lo's, above 16 zero bits), and its bits above
  // as lo8 (8 bits, where ctx adds) and hi and hi + 1 (HH bits); and W >> k,
  // with elig's bound: W below 2^32 windows, else no 32-bit rbase equals it.
  localparam int BL = NN - 16;                // 6
  localparam int HH = RHW - 8;                // 20
  localparam int RB = 2 * (BL + 8 + 2 * HH);  // a CTA's region bits
  logic [LBW:0]   x_cm03h, w_cm03h, p_cm03h;
  logic [RB-1:0]  rb_cm03h;
  logic           rg_ok_cm03h;
  // A Kogge-Stone add, log2 levels at fanout 2, so the mapper's area
  // recovery keeps a shallow carry tree rather than a ripple (as miu_agu8).
  function automatic logic [LBW:0] ks_add(input logic [LBW:0] a, input logic [LBW:0] b);
    logic [LBW:0] g, p, gn, pn;
    g = a & b;
    p = a ^ b;
    for (int d = 1; d <= LBW; d = d * 2) begin
      gn = g;
      pn = p;
      for (int i = d; i <= LBW; i = i + 1) begin
        gn[i] = g[i] | (p[i] & g[i-d]);
        pn[i] = p[i] & p[i-d];
      end
      g = gn;
      p = pn;
    end
    ks_add = (a ^ b) ^ {g[LBW-1:0], 1'b0};
  endfunction
  always_comb begin
    logic [LBW:0] x1, p1;
    // Each from local_base and a constant, side by side: hi + 1 is the
    // region base plus 2^(BL + 8), shifted (no add after an add).
    x_cm03h = ks_add((LBW+1)'(ctl_q_cm03h), (LBW+1)'(LC));
    w_cm03h = ks_add((LBW+1)'(ctl_q_cm03h), (LBW+1)'(3 * LC));
    p_cm03h = ks_add((LBW+1)'(ctp_q_cm03h), (LBW+1)'(3 * LC + PW));
    x1 = ks_add((LBW+1)'(ctl_q_cm03h), (LBW+1)'(LC + (1 << (BL + 8))));
    p1 = ks_add((LBW+1)'(ctp_q_cm03h), (LBW+1)'(3 * LC + PW + (1 << (BL + 8))));
    // {p: hi + 1, hi, lo8, bl; x: hi + 1, hi, lo8, bl}, LSB first.
    rb_cm03h = {p1[BL+8 +: HH], p_cm03h[BL+8 +: HH], p_cm03h[BL +: 8], p_cm03h[BL-1:0],
                x1[BL+8 +: HH], x_cm03h[BL+8 +: HH], x_cm03h[BL +: 8], x_cm03h[BL-1:0]};
    rg_ok_cm03h = !ctv_q_cm03h || ((x_cm03h >> 33) == '0 && (p_cm03h >> 33) == '0);
  end
  logic [NC-1:0]     cl_q_cm04h;                       // W below 2^32
  logic [NC*RB-1:0]  rb_q_cm04h;
  logic [NC*WHW-1:0] whq_q_cm04h;
  for (genvar c = 0; c < NC; c++) begin : g_cta
    wire ct_en_cm03h = ctv_q_cm03h && cth_q_cm03h[c];
    always_ff @(posedge miu_core_clk) begin
      if (ct_en_cm03h) begin
        cl_q_cm04h[c]             <= (w_cm03h >> 32) == '0;
        rb_q_cm04h[c*RB +: RB]    <= rb_cm03h;
        whq_q_cm04h[c*WHW +: WHW] <= w_cm03h[31:PK];
      end
    end
  end

  // ---- The window table ---------------------------------------------------
  // A CTA's arrival clears its 16 valid bits (its launch block is new); a
  // fill sets those of the windows its line holds. Each word is written
  // only by its fill.
  logic [NC*NWN-1:0]    tv_q_cm04h;
  logic [NC*NWN*32-1:0] tw_q_cm04h;
  for (genvar c = 0; c < NC; c++) begin : g_tab
    wire ctw_cm03h = ctv_q_cm03h && cth_q_cm03h[c];
    wire fcs_cm03h = fv_q_cm03h && fch_q_cm03h[c];
    // Clocked only when a write changes a bit: a CTA's arrival over a set
    // valid, or a fill of a window not yet valid (CG-3).
    logic tv_en_cm03h;
    assign tv_en_cm03h = (ctw_cm03h && |tv_q_cm04h[c*NWN +: NWN]) ||
                         (fcs_cm03h && |(fm_q_cm03h & ~({NWN{!ctw_cm03h}} & tv_q_cm04h[c*NWN +: NWN])));
    always_ff @(posedge miu_core_clk) begin
      if (rst_r01h)         tv_q_cm04h[c*NWN +: NWN] <= '0;
      else if (tv_en_cm03h) tv_q_cm04h[c*NWN +: NWN] <=
          ({NWN{!ctw_cm03h}} & tv_q_cm04h[c*NWN +: NWN]) | ({NWN{fcs_cm03h}} & fm_q_cm03h);
    end
    for (genvar j = 0; j < NWN; j++) begin : g_w
      wire tw_en_cm03h = fcs_cm03h && fm_q_cm03h[j];
      always_ff @(posedge miu_core_clk) begin
        if (tw_en_cm03h) tw_q_cm04h[(c*NWN + j)*32 +: 32] <= fw_cm03h[j*32 +: 32];
      end
    end
  end

  // ---- H-1: each slot's read ---------------------------------------------
  // The H flops' gate: this module's flop of miu_pair's enable (CG-5).
  logic pnew_q_cm04h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) pnew_q_cm04h <= 1'b0;
    else          pnew_q_cm04h <= pen_cm03h;
  end

  logic [NS*32-1:0]  win_d_cm04h;
  logic [NS-1:0]     wv_d_cm04h;
  logic [NS*3-1:0]   fs_d_cm04h;
  logic [NS*WHW-1:0] wh_d_cm04h;
  logic [NS*RK-1:0]  rk_d_cm04h;
  logic [NS*IW-1:0]  dh_d_cm04h;
  logic [NS*(CXW+RB/2)-1:0] cx_d_cm04h;   // the local region and ctx, for C
  logic [NS*17-1:0]  ds_d_cm04h;
  for (genvar k = 0; k < NS; k++) begin : g_slot
    logic [EW-1:0]  e_cm04h;
    logic [WIW-1:0] wid_cm04h;
    logic           sf_cm04h, lf_cm04h, gl_cm04h;
    logic [IW-1:0]  im_cm04h;
    logic [CXW-1:0] ctx_cm04h;
    logic [RB-1:0]  rb_cm04h;
    logic           cl_cm04h;
    logic [NE-1:0]  oe_cm04h;
    logic [NC-1:0]  oc_cm04h;
    logic [NWN-1:0] oj_cm04h;
    logic [16:0]    ds_cm04h;
    always_comb begin
      e_cm04h   = pe_cm04h[k*EW +: EW];
      // The entry's one-hot, then an AND-OR over 40, as miu_pair reads.
      for (int e = 0; e < NE; e++) oe_cm04h[e] = e_cm04h == EW'(e);
      // The entry's fields, and its CTA slot and window one-hot, decoded
      // per entry from miu_mq's flops beside the entry's decode.
      wid_cm04h = '0;
      sf_cm04h  = 1'b0;
      lf_cm04h  = 1'b0;
      gl_cm04h  = 1'b0;
      im_cm04h  = '0;
      ds_cm04h  = '0;
      oc_cm04h  = '0;
      oj_cm04h  = '0;
      for (int e = 0; e < NE; e++) begin
        wid_cm04h = wid_cm04h | ({WIW{oe_cm04h[e]}} & mqa_cm02h[e*FW + WI_L +: WIW]);
        sf_cm04h  = sf_cm04h  | (oe_cm04h[e] & mqa_cm02h[e*FW + SF_L]);
        lf_cm04h  = lf_cm04h  | (oe_cm04h[e] & mqa_cm02h[e*FW + LF_L]);
        gl_cm04h  = gl_cm04h  | (oe_cm04h[e] & !mqa_cm02h[e*FW + SP_L]);   // space 0: .global
        im_cm04h  = im_cm04h  | ({IW{oe_cm04h[e]}}  & mqi_cm02h[e*IW +: IW]);
        ds_cm04h  = ds_cm04h  | ({17{oe_cm04h[e]}}  & mqa_cm02h[e*FW + DS_L +: 17]);
        for (int c = 0; c < NC; c++)
          oc_cm04h[c] = oc_cm04h[c] |
                        (oe_cm04h[e] & (mqa_cm02h[e*FW + CS_L +: CSW] == CSW'(c)));
        for (int j = 0; j < NWN; j++)
          oj_cm04h[j] = oj_cm04h[j] | (oe_cm04h[e] & (mqa_cm02h[e*FW + AS_L +: 4] == 4'(j)));
      end
      // ctx: the strapped core index above the warp (O-64).
      ctx_cm04h = {DCW'(CORE), wid_cm04h};
      // The CTA slot's state and the window, AND-OR over 8 and 128.
      win_d_cm04h[k*32 +: 32]  = '0;
      wv_d_cm04h[k]            = 1'b0;
      wh_d_cm04h[k*WHW +: WHW] = '0;
      rb_cm04h                 = '0;
      cl_cm04h                 = 1'b0;
      for (int c = 0; c < NC; c++) begin
        wh_d_cm04h[k*WHW +: WHW] = wh_d_cm04h[k*WHW +: WHW] |
                                   ({WHW{oc_cm04h[c]}} & whq_q_cm04h[c*WHW +: WHW]);
        rb_cm04h = rb_cm04h | ({RB{oc_cm04h[c]}} & rb_q_cm04h[c*RB +: RB]);
        cl_cm04h = cl_cm04h | (oc_cm04h[c] & cl_q_cm04h[c]);
        for (int j = 0; j < NWN; j++) begin
          win_d_cm04h[k*32 +: 32] = win_d_cm04h[k*32 +: 32] |
              ({32{oc_cm04h[c] & oj_cm04h[j]}} & tw_q_cm04h[(c*NWN + j)*32 +: 32]);
          wv_d_cm04h[k] = wv_d_cm04h[k] | (oc_cm04h[c] & oj_cm04h[j] & tv_q_cm04h[c*NWN + j]);
        end
      end
      fs_d_cm04h[k*3 +: 3] = {gl_cm04h && !sf_cm04h && !lf_cm04h && cl_cm04h, lf_cm04h, sf_cm04h};
      // R(ctx)'s operands: the form's region, and ctx.
      rk_d_cm04h[k*RK +: RK] = {ctx_cm04h, lf_cm04h ? rb_cm04h[0 +: RB/2] : rb_cm04h[RB/2 +: RB/2]};
      // C's operands, flopped at H: the local region whatever the form.
      cx_d_cm04h[k*(CXW+RB/2) +: CXW+RB/2] = {ctx_cm04h, rb_cm04h[0 +: RB/2]};
      ds_d_cm04h[k*17 +: 17] = ds_cm04h;
      // Lane d: the issue mask's lowest lane, one-hot.
      dh_d_cm04h[k*IW +: IW] = im_cm04h & (~im_cm04h + IW'(1));
    end
  end

  // C's split needs ctx's place (22) at the narrow sum's top: k <= 1.
  if (NN != 22) begin : g_c_nn
    $error("miu_form: C (O-69) assumes NN = 22 (CCV_PRIV_WINDOWS <= 2)");
  end

  // ---- H: the slots' forms ------------------------------------------------
  wire h_en_cm04h = pnew_q_cm04h;
  logic [NS-1:0]     wv_q_cm05h;
  logic [NS*3-1:0]   fs_q_cm05h;
  (* keep *) logic [NS*WHW-1:0] wh_q_cm05h;   // never merged with cx_q (NGD-7)
  (* keep *) logic [NS*RK-1:0]  rk_q_cm05h;   // never merged with cx_q (NGD-7)
  logic [NS*IW-1:0]  dh_q_cm05h;
  (* keep *) logic [NS*(CXW+RB/2)-1:0] cx_q_cm05h;
  logic [NS*17-1:0]  ds_q_cm05h;
  always_ff @(posedge miu_core_clk) begin
    if (h_en_cm04h) begin
      wv_q_cm05h  <= wv_d_cm04h;
      fs_q_cm05h  <= fs_d_cm04h;
      wh_q_cm05h  <= wh_d_cm04h;
      rk_q_cm05h  <= rk_d_cm04h;
      dh_q_cm05h  <= dh_d_cm04h;
      cx_q_cm05h  <= cx_d_cm04h;
      ds_q_cm05h  <= ds_d_cm04h;
    end
  end
  assign wv_cm05h  = wv_q_cm05h;
  assign fs_cm05h  = fs_q_cm05h;
  assign wh_cm05h  = wh_q_cm05h;
  assign rk_cm05h  = rk_q_cm05h;
  assign dh_cm05h  = dh_q_cm05h;

  // ---- A1: C, from the H flops, into A2's -------------------------------
  // b rearranged over bits [21:0] adds to bl at [21:16]; its carry joins
  // lo8 + ctx, whose carry picks hi or hi + 1. b < 2^17 never reaches ctx
  // at bit 22. Clocked by this module's flop of its H enable (CG-5).
  logic pnew_q_cm05h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) pnew_q_cm05h <= 1'b0;
    else          pnew_q_cm05h <= pnew_q_cm04h;
  end
  logic [NS*VW-1:0] c_d_cm05h;
  always_comb begin
    for (int k = 0; k < NS; k++) begin
      logic [CXW+RB/2-1:0] x;
      logic [16:0]         b;
      logic [NN:0]         lo;
      logic [8:0]          t;
      x  = cx_q_cm05h[k*(CXW+RB/2) +: CXW+RB/2];
      b  = ds_q_cm05h[k*17 +: 17];
      lo = (NN+1)'({x[0 +: BL], 16'b0}) + (NN+1)'({b[16:2], 5'b00000, b[1:0]});
      t  = 9'(x[BL +: 8]) + 9'(x[RB/2 +: CXW]) + 9'(lo[NN]);
      c_d_cm05h[k*VW +: VW] = {t[8] ? x[BL + 8 + HH +: HH] : x[BL + 8 +: HH], t[7:0], lo[NN-1:0]};
    end
  end
  wire c_en_cm05h = pnew_q_cm05h;
  logic [NS*VW-1:0] c_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (c_en_cm05h) c_q_cm06h <= c_d_cm05h;
  end
  assign c_cm06h = c_q_cm06h;
  // The base mux's select and window, a copy per octet, so their fanout
  // stays off miu_agu8's adder path.
  for (genvar u = 0; u < NO; u++) begin : g_oct
    (* keep *) logic [NS*32-1:0] win_q_cm05h;
    (* keep *) logic [NS-1:0]    sl_q_cm05h;
    always_ff @(posedge miu_core_clk) begin
      if (h_en_cm04h) begin
        win_q_cm05h <= win_d_cm04h;
        for (int k = 0; k < NS; k++) sl_q_cm05h[k] <= fs_d_cm04h[k*3];
      end
    end
    for (genvar k = 0; k < NS; k++) begin : g_k
      assign win_cm05h[(k*NO + u)*32 +: 32] = win_q_cm05h[k*32 +: 32];
      assign sl_cm05h[k*NO + u]            = sl_q_cm05h[k];
    end
  end

  // Each region's base below 2^33 windows, so R(ctx) fits VW bits.
  `CCV_ASSERT(cta_range, rg_ok_cm03h)

endmodule
`undef CCV_CLK
`undef CCV_RST
