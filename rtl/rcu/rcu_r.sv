//===-- rcu_r.sv - RCU R pipe: R-only ops and collectives, A to A+2 ------===//
//
// Spec: docs/design-snapshots/rcu-arch-r-unit.md (live: CCV RCU
//       Architecture, R unit and crossbar tab: the A+2 rule, Early R source
//       read (RA-39), Per-stage registers, Ops, Depth);
//       docs/design-snapshots/rcu-arch-partition.md (ccv_rcu_r's row).
//
// One op a cycle from issue slot 8 (CCV_ISSUE_SLOT_R). R0 and R1 are read
// in A by the bank slices, from the payload's phys_src, with the MIU
// write-through, into the slices' rsrc (RA-39, OA rev 336); R2 is read in
// A+1. This module aligns rsrc and computes in A+1, from flops, and drives
// the RW and PR writes and done slots 5 and 6 at A+2 (the A+2 rule, RA-29
// (a)).
//
// Port timing (local stages, cr01h = A-1 ... cr04h = A+2):
//   cr01h  iv: the R issue valid lead (the op is in A next cycle)
//   cr02h  A: the payload, and its class word (rcu_isd decodes the lead's
//          opcode in A-1 by rcu_dec_pkg, the model's op-class decode, to
//          the model's RKind; RA-43, RI-25). rw_v, pr_v: the RW and PR ports' valids
//   cr03h  A+1: the slices' rsrc (R0, R1 raw rows); R2's row; active, RA,
//          RB and rlow from the predicate file's flops. RW's row and
//          sections, PR's row and old row (no-select rows when the op writes no GPR or
//          no predicate); the done valids
//   cr04h  A+2: RW's data (every lane), PR's value and merge mask, the
//          done payload
//
// Width codes: 0 32 bits, 1 16, 2 8, 3 4. A register is (row, pos, width);
// v(R) = (row >> 8 pos) & em(width), zero-extended.
//
// Departures from the spec's register table, each for RA:
//   - active and rlow_a arrive from the predicate file's flops in A+1:
//     rlow_a is one prefix after active, inside the predicate file's A
//     path; taken here from active in A+1, ret measured 30 NGD.
//   - The merge is done in A+2 on the way out (merge(new, old, mask) and
//     steer), as the spec has it; a write with merge_en = 0 takes old = 0.
//   - Branch fields of a done are loaded on a branch, and cleared once on
//     the first slot-5 done after one (they are 0 on every non-branch done,
//     without a clock on each).
//
// The reference is the RCU model (sim/rcu/rcu_core.cpp, issueR);
// test/rcu/r_tb.cpp holds this module to a value model of it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK rcu_core_clk
`define CCV_RST rst_r01h
module rcu_r #(
  localparam int N = 32,                              // lanes
  localparam int WR = 8,                              // a GPR row (CCV_P_W_PHYS_REG)
  localparam int WP = 6,                              // a predicate row (CCV_P_W_PHYS_PRED)
  localparam int WT = ccv_prov_pkg::CCV_P_W_ROB_TAG
) (
  input  logic                rcu_core_clk,
  input  logic                rst_n,
  // The R slot: the valid lead, then the payload.
  input  logic                iv_cr01h,        // R issues next cycle (the lead's valid)
  input  logic [rcu_dec_pkg::CLS_W-1:0] ocl_cr02h, // op class (rcu_isd's flops from the lead)
  input  logic [WT-1:0]       tag_cr02h,       // rob_tag
  input  logic [1:0]          drow_cr02h,      // done_row
  input  logic [N-1:0]        imask_cr02h,     // issue_mask
  input  logic [31:0]         lrp_cr01h,       // lead_rpsrc: R's whole imm, in A-1 only (RA-43)
  input  logic [2*WR-1:0]     lps_cr01h,       // lead_phys_src, R0 at [7:0], R1 at [15:8]: R's rows, in A-1 only (RA-43)
  input  logic [WR-1:0]       dst_cr02h,       // phys_dst
  input  logic [1:0]          dpos_cr02h,      // dst_pos
  input  logic [1:0]          dwid_cr02h,      // dst_width
  input  logic [1:0]          opos_cr02h,      // old_dst_pos
  input  logic [3:0]          spos_cr02h,      // src_pos: R0 at [1:0], R1 at [3:2]
  input  logic [3:0]          swid_cr02h,      // src_width: R0 at [1:0], R1 at [3:2]
  input  logic [WP-1:0]       pd_cr02h,        // phys_pred_dst
  input  logic [WP-1:0]       pold_cr02h,      // phys_pred_old_dst (PR's merge row)
  input  logic                mrg_cr02h,       // merge_en
  input  logic                pwe_cr02h,       // pred_we
  // The bank slices: lane l's 32 bits at 32l.
  input  logic [N*32-1:0]     rs0_cr03h,       // rsrc R0, raw (its row), from the slices' flops
  input  logic [N*32-1:0]     rs1_cr03h,       // rsrc R1
  input  logic [N*32-1:0]     rd2_cr03h,       // R2 in A+1 (the old destination)
  // The predicate file's A flops, read in A+1.
  input  logic [N-1:0]        act_cr03h,       // active = issue_mask & guard
  input  logic [N-1:0]        rpa_cr03h,       // RA, negate and forward applied
  input  logic [N-1:0]        rpb_cr03h,       // RB
  input  logic [N-1:0]        low_cr03h,       // rlow_a: one-hot of active's lowest lane
  // R's source rows for the slices' reads in A, from this module's capture.
  output logic [2*WR-1:0]     rr_row_cr02h,    // R0 at [7:0], R1 at [15:8]
  // RW: valid, row and sections, data on every lane.
  output logic                busy_cr03h,      // to rcu_kill's idle and done wake: R's pipe valid
  output logic                rw_v_cr02h,
  output logic [WR-1:0]       rw_row_cr03h,
  output logic [3:0]          rw_sec_cr03h,
  output logic [N*32-1:0]     rw_dat_cr04h,
  // PR: valid, row, value and merge mask.
  output logic                pr_v_cr02h,
  output logic [WP-1:0]       pr_row_cr03h,
  output logic                pr_mrg_cr03h,    // merge with the old predicate (else old = 0)
  output logic [WP-1:0]       pr_orow_cr03h,   // PR's old row, the predicate file's merge read (RA rev 81)
  output logic [N-1:0]        pr_val_cr04h,
  output logic [N-1:0]        pr_mm_cr04h,
  // Done slots 5 (bit 0) and 6 (bit 1): valids, then one shared payload.
  output logic [1:0]          dn_v_cr03h,
  output logic [WT-1:0]       dn_tag_cr04h,
  output logic [1:0]          dn_row_cr04h,
  output logic                dn_bt_cr04h,     // branch_taken
  output logic [N-1:0]        dn_bm_cr04h,     // branch_mask
  output logic [31:0]         dn_aux_cr04h     // aux
);

  localparam logic [WR-1:0] ZROW = WR'(ccv_prov_pkg::CCV_P_PHYS_ZERO);
  localparam logic [WP-1:0] ZPRD = WP'(ccv_prov_pkg::CCV_P_PRED_ZERO);

  // The model's RKind.
  localparam logic [4:0] K_BRA = 5'd1, K_CALL = 5'd2, K_RET = 5'd3, K_PAND = 5'd4,
    K_POR = 5'd5, K_PXOR = 5'd6, K_PMOVI = 5'd7, K_MOVI = 5'd8, K_SHI = 5'd9,
    K_SHR = 5'd10, K_SHU = 5'd11, K_SHD = 5'd12, K_SHB = 5'd13, K_VANY = 5'd14,
    K_VALL = 5'd15, K_BAL = 5'd16, K_UNB = 5'd17, K_PMOV = 5'd18;

  // The op class (RI-21 (4)), rcu_isd's flops: this module reads only its
  // own fields.
  /* verilator lint_off UNUSEDSIGNAL */
  wire [rcu_dec_pkg::CLS_W-1:0] cls_cr02h = ocl_cr02h;
  /* verilator lint_on UNUSEDSIGNAL */
  wire [4:0] kind_cr02h = cls_cr02h[rcu_dec_pkg::CLS_RK +: 5];
  wire [2:0] unit_cr02h = cls_cr02h[rcu_dec_pkg::CLS_UNIT +: 3];

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge rcu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  function automatic logic [31:0] em(input logic [1:0] w);
    em = (w == 2'd0) ? 32'hffff_ffff : (w == 2'd1) ? 32'h0000_ffff :
         (w == 2'd2) ? 32'h0000_00ff : 32'h0000_000f;
  endfunction
  function automatic logic [31:0] align(input logic [31:0] row, input logic [1:0] pos,
                                        input logic [1:0] w);
    align = (row >> {pos, 3'b000}) & em(w);
  endfunction
  function automatic logic [3:0] secmask(input logic [1:0] w, input logic [1:0] pos);
    logic [3:0] span;
    span = (w == 2'd0) ? 4'b1111 : (w == 2'd1) ? 4'b0011 : 4'b0001;
    secmask = span << pos;
  endfunction

  // ---- Valids, flopped every cycle ---------------------------------------
  logic          iv_cr02h;
  logic          r_v_cr03h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      iv_cr02h  <= 1'b0;
      r_v_cr03h <= 1'b0;
    end else begin
      iv_cr02h  <= iv_cr01h;
      r_v_cr03h <= iv_cr02h;
    end
  end
  // The RW and PR valids drive outputs and the module's enables, all
  // within the output's budget: one flop.
  assign rw_v_cr02h = iv_cr02h;
  assign pr_v_cr02h = iv_cr02h;

  // ---- R's moved leads, kept for A (RA-43) --------------------------------
  // R's payload carries neither its imm nor its source rows: lead_rpsrc and
  // lead_phys_src, beside R's valid in A-1, are captured here under that
  // valid and hold the values in A as the payload would (CG-5 lead waiver,
  // Daniel's ruling on RI-15). The rows drive an output: their own copy.
  wire rl_en_cr01h = iv_cr01h;
  logic [31:0] imm_cr02h;
  (* keep *) logic [2*WR-1:0] rrow_cr02h;
  always_ff @(posedge rcu_core_clk) begin
    if (rl_en_cr01h) begin
      imm_cr02h  <= lrp_cr01h;
      rrow_cr02h <= lps_cr01h;
    end
  end
  assign rr_row_cr02h = rrow_cr02h;

  // ---- A: the payload into r_a -------------------------------------------
  wire k_call_cr02h = kind_cr02h == K_CALL;
  wire k_movi_cr02h = kind_cr02h == K_MOVI;
  wire k_shf_cr02h  = kind_cr02h >= K_SHI && kind_cr02h <= K_SHB;
  wire k_bal_cr02h  = kind_cr02h == K_BAL;
  wire k_vote_cr02h = kind_cr02h == K_VANY || kind_cr02h == K_VALL;
  wire k_unb_cr02h  = kind_cr02h == K_UNB;
  wire k_plog_cr02h = (kind_cr02h >= K_PAND && kind_cr02h <= K_PMOVI) ||
                      kind_cr02h == K_PMOV;
  wire k_br_cr02h   = kind_cr02h >= K_BRA && kind_cr02h <= K_RET;
  wire wg_cr02h     = k_call_cr02h | k_movi_cr02h | k_shf_cr02h | k_bal_cr02h;
  wire wp_cr02h     = k_plog_cr02h | k_vote_cr02h | k_unb_cr02h;
  wire coll_cr02h   = k_shf_cr02h | k_vote_cr02h | k_bal_cr02h | k_unb_cr02h;
  wire ronly_cr02h  = k_br_cr02h | k_plog_cr02h | k_movi_cr02h;

  // The A+1 compute's selects, from the payload: each lane's source index
  // for the immediate forms; the result's masks by op, em applied.
  logic [N*5-1:0] ixv_cr02h;
  always_comb begin
    for (int l = 0; l < N; l++) begin
      logic [5:0] up_cr02h, dn_cr02h;
      up_cr02h = 6'(l) - 6'(imm_cr02h[4:0]);
      dn_cr02h = 6'(l) + 6'(imm_cr02h[4:0]);
      ixv_cr02h[l*5 +: 5] =
        (kind_cr02h == K_SHU) ? (up_cr02h[5] ? 5'(l) : up_cr02h[4:0]) :
        (kind_cr02h == K_SHD) ? (dn_cr02h[5] ? 5'(l) : dn_cr02h[4:0]) :
        (kind_cr02h == K_SHB) ? (5'(l) ^ imm_cr02h[4:0]) : imm_cr02h[4:0];
    end
  end
  wire ix_en_cr02h = iv_cr02h;
  logic [N*5-1:0] ix_cr03h;
  logic           ixr_cr03h;     // the register-index form: idx from v(R1)
  // The register-amount forms of up, down and butterfly (shfl_*_r, the
  // class's ireg): each lane's amount is v(R1)'s low 5 bits, known only in
  // A+1, so their selects are made there (sel_cr03h; out of 0..31 the lane
  // keeps its own, O-85). iim: an immediate form, its index in ix.
  logic           iru_cr03h, ird_cr03h, irb_cr03h, iim_cr03h;
  logic           kshf_cr03h, kimm_cr03h, kbal_cr03h;
  logic [31:0]    em_cr03h;      // em(dst width)
  always_ff @(posedge rcu_core_clk) begin
    if (ix_en_cr02h) begin
      ix_cr03h   <= ixv_cr02h;
      ixr_cr03h  <= kind_cr02h == K_SHR;
      iru_cr03h  <= cls_cr02h[rcu_dec_pkg::CLS_IREG] && kind_cr02h == K_SHU;
      ird_cr03h  <= cls_cr02h[rcu_dec_pkg::CLS_IREG] && kind_cr02h == K_SHD;
      irb_cr03h  <= cls_cr02h[rcu_dec_pkg::CLS_IREG] && kind_cr02h == K_SHB;
      iim_cr03h  <= kind_cr02h != K_SHR && !cls_cr02h[rcu_dec_pkg::CLS_IREG];
      kshf_cr03h <= k_shf_cr02h;
      kimm_cr03h <= k_call_cr02h | k_movi_cr02h;
      kbal_cr03h <= k_bal_cr02h;
      em_cr03h   <= em(dwid_cr02h);
    end
  end

  wire ra_en_cr02h = iv_cr02h;
  logic [4:0]    kind_cr03h;
  logic          wg_cr03h, wp_cr03h, s5_cr03h, mrg_cr03h;
  logic [WT-1:0] tag_cr03h;
  logic [1:0]    drow_cr03h, dpos_cr03h, dwid_cr03h, opos_cr03h;
  // The sources' pos and width, a copy for each 4 lanes (the alignment's
  // fanout: one copy for all 1,024 bits put A+1 at 25.9 NGD).
  localparam int NG = N / 4;
  (* keep *) logic [NG*4-1:0] spos_cr03h, swid_cr03h;
  logic [N-1:0]  imask_cr03h;
  logic [31:0]   imm_cr03h;
  always_ff @(posedge rcu_core_clk) begin
    if (ra_en_cr02h) begin
      kind_cr03h   <= kind_cr02h;
      wg_cr03h     <= wg_cr02h;
      wp_cr03h     <= wp_cr02h;
      s5_cr03h     <= ronly_cr02h;
      mrg_cr03h    <= mrg_cr02h;
      tag_cr03h    <= tag_cr02h;
      drow_cr03h   <= drow_cr02h;
      dpos_cr03h   <= dpos_cr02h;
      dwid_cr03h   <= dwid_cr02h;
      opos_cr03h   <= opos_cr02h;
      spos_cr03h   <= {NG{spos_cr02h}};
      swid_cr03h   <= {NG{swid_cr02h}};
      imask_cr03h  <= imask_cr02h;
      imm_cr03h    <= imm_cr02h;
      // The write ports' rows: no-select when the op writes none.
      rw_row_cr03h <= wg_cr02h ? dst_cr02h : ZROW;
      rw_sec_cr03h <= wg_cr02h ? secmask(dwid_cr02h, dpos_cr02h) : 4'b0000;
      pr_row_cr03h <= wp_cr02h ? pd_cr02h : ZPRD;
      pr_mrg_cr03h <= mrg_cr02h;
      pr_orow_cr03h <= pold_cr02h;
    end
  end
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) dn_v_cr03h <= 2'b00;
    else          dn_v_cr03h <= {iv_cr02h & coll_cr02h, iv_cr02h & ronly_cr02h};
  end

  // ---- A+1: align rsrc, then compute from it -------------------------------
  logic [N*32-1:0] rs0a_cr03h, rs1a_cr03h;   // v(R0), v(R1)
  always_comb begin
    for (int l = 0; l < N; l++) begin
      rs0a_cr03h[l*32 +: 32] = align(rs0_cr03h[l*32 +: 32], spos_cr03h[(l/4)*4 +: 2],
                                     swid_cr03h[(l/4)*4 +: 2]);
      rs1a_cr03h[l*32 +: 32] = align(rs1_cr03h[l*32 +: 32], spos_cr03h[(l/4)*4 + 2 +: 2],
                                     swid_cr03h[(l/4)*4 + 2 +: 2]);
    end
  end

  // Each output lane's one-hot select. The register forms decode the
  // lane's own amount c = v(R1)[4:0] once and rewire it: idx s takes oh[s],
  // up oh[l - s] (and its own lane past 0), down oh[s - l] (its own past
  // 31), butterfly oh[l ^ s]. The immediate forms decode their index.
  logic [N*N-1:0]  sel_cr03h;
  logic [N*32-1:0] xo_cr03h;
  always_comb begin
    for (int l = 0; l < N; l++) begin
      logic [4:0]   c_cr03h;
      logic [N-1:0] oh_cr03h, ohi_cr03h;
      c_cr03h = rs1a_cr03h[l*32 +: 5];
      for (int k = 0; k < N; k++) begin
        oh_cr03h[k]  = c_cr03h == 5'(k);
        ohi_cr03h[k] = ix_cr03h[l*5 +: 5] == 5'(k);
      end
      for (int s = 0; s < N; s++) begin
        logic up_cr03h, dn_cr03h;
        up_cr03h = (l >= s) ? oh_cr03h[l - s] : 1'b0;
        dn_cr03h = (s >= l) ? oh_cr03h[s - l] : 1'b0;
        if (s == l) begin
          up_cr03h = up_cr03h | (c_cr03h > 5'(l));
          dn_cr03h = dn_cr03h | (c_cr03h > 5'(N - 1 - l));
        end
        sel_cr03h[l*N + s] = (ixr_cr03h & oh_cr03h[s]) | (iru_cr03h & up_cr03h) | (ird_cr03h & dn_cr03h) |
                             (irb_cr03h & oh_cr03h[l ^ s]) | (iim_cr03h & ohi_cr03h[s]);
      end
    end
  end
  rcu_xbar #(.LANES(N), .W(32)) u_xbar (.src(rs0a_cr03h), .sel(sel_cr03h), .out(xo_cr03h));

  // The selects are one-hot (RA rev 137): an output lane takes exactly one
  // source lane while a crossbar form is set, none while no form is.
  logic [N-1:0] selbad_cr03h;
  always_comb begin
    for (int l = 0; l < N; l++) begin
      logic [N-1:0] row_cr03h;
      row_cr03h = sel_cr03h[l*N +: N];
      selbad_cr03h[l] = (ixr_cr03h | iru_cr03h | ird_cr03h | irb_cr03h | iim_cr03h)
                        ? (row_cr03h == '0 || (row_cr03h & (row_cr03h - 1'b1)) != '0)
                        : row_cr03h != '0;
    end
  end
  `CCV_ASSERT(xbar_sel_onehot, !(|selbad_cr03h))

  // The result's masks by op, em applied: off the crossbar's path.
  wire [31:0] xm_cr03h   = {32{kshf_cr03h}} & em_cr03h;
  wire [31:0] immv_cr03h = {32{kimm_cr03h}} & imm_cr03h & em_cr03h;
  wire [31:0] bal_cr03h  = {32{kbal_cr03h}} & 32'(rpa_cr03h & act_cr03h) & em_cr03h;
  logic [N*32-1:0] new_cr03h, old_cr03h;
  always_comb begin
    for (int l = 0; l < N; l++) begin
      new_cr03h[l*32 +: 32] = (xo_cr03h[l*32 +: 32] & xm_cr03h) | immv_cr03h | bal_cr03h;
      old_cr03h[l*32 +: 32] = align(rd2_cr03h[l*32 +: 32], opos_cr03h, dwid_cr03h);
    end
  end

  // rres_a1: the GPR result, split by what each part's op uses.
  wire gw_en_cr03h = r_v_cr03h & wg_cr03h;
  wire go_en_cr03h = r_v_cr03h & wg_cr03h & mrg_cr03h;
  logic [N*32-1:0] new_cr04h, old_cr04h;
  logic [N-1:0]    gm_cr04h;
  (* keep *) logic [N*2-1:0] gpos_cr04h;   // a copy a lane (the steer's fanout)
  (* keep *) logic [N-1:0]   gmrg_cr04h;
  always_ff @(posedge rcu_core_clk) begin
    if (gw_en_cr03h) begin
      new_cr04h  <= new_cr03h;
      gm_cr04h   <= act_cr03h;
      gpos_cr04h <= {N{dpos_cr03h}};
      gmrg_cr04h <= {N{mrg_cr03h}};
    end
  end
  always_ff @(posedge rcu_core_clk) begin
    if (go_en_cr03h) old_cr04h <= old_cr03h;
  end
  // A+2: merge and steer, every lane.
  always_comb begin
    for (int l = 0; l < N; l++) begin
      logic [31:0] m_cr04h;
      m_cr04h = gm_cr04h[l] ? new_cr04h[l*32 +: 32] : ({32{gmrg_cr04h[l]}} & old_cr04h[l*32 +: 32]);
      rw_dat_cr04h[l*32 +: 32] = m_cr04h << {gpos_cr04h[l*2 +: 2], 3'b000};
    end
  end

  // rpres_a1: the predicate result and its merge mask.
  logic [N-1:0] pv_cr03h, pm_cr03h;
  always_comb begin
    logic pany_cr03h, pall_cr03h;
    pany_cr03h = |(rpa_cr03h & act_cr03h);
    pall_cr03h = (rpa_cr03h & act_cr03h) == act_cr03h;
    pm_cr03h = imask_cr03h;
    unique case (kind_cr03h)
      K_PAND:  pv_cr03h = rpa_cr03h & rpb_cr03h;
      K_POR:   pv_cr03h = rpa_cr03h | rpb_cr03h;
      K_PXOR:  pv_cr03h = rpa_cr03h ^ rpb_cr03h;
      K_PMOVI: pv_cr03h = imm_cr03h;
      K_PMOV:  pv_cr03h = rpa_cr03h;   // pmov: ps0, its negate applied
      K_VANY:  begin pv_cr03h = {N{pany_cr03h}}; pm_cr03h = act_cr03h; end
      K_VALL:  begin pv_cr03h = {N{pall_cr03h}}; pm_cr03h = act_cr03h; end
      default: begin   // unballot: lane l's bit l, 0 past rs's width
        for (int l = 0; l < N; l++)
          pv_cr03h[l] = rs0a_cr03h[l*32 + l] & (l < (32 >> swid_cr03h[(l/4)*4 +: 2]));
        pm_cr03h = act_cr03h;
      end
    endcase
  end
  wire pw_en_cr03h = r_v_cr03h & wp_cr03h;
  always_ff @(posedge rcu_core_clk) begin
    if (pw_en_cr03h) begin
      pr_val_cr04h <= pv_cr03h;
      pr_mm_cr04h  <= pm_cr03h;
    end
  end

  // The done payload. ret: aux is the lowest active lane's v(R0), the mask
  // the active lanes equal to it; bra and call: the active lanes, aux 0.
  wire k_ret_cr03h = kind_cr03h == K_RET;
  wire k_br_cr03h  = kind_cr03h >= K_BRA && kind_cr03h <= K_RET;
  logic [N-1:0] same_cr03h;
  logic [31:0]  aux_cr03h;
  always_comb begin
    aux_cr03h = '0;
    for (int l = 0; l < N; l++)
      aux_cr03h = aux_cr03h | ({32{low_cr03h[l]}} & rs0a_cr03h[l*32 +: 32]);
    for (int l = 0; l < N; l++)
      same_cr03h[l] = act_cr03h[l] & (rs0a_cr03h[l*32 +: 32] == aux_cr03h);
  end
  wire dn_en_cr03h = r_v_cr03h;
  always_ff @(posedge rcu_core_clk) begin
    if (dn_en_cr03h) begin
      dn_tag_cr04h <= tag_cr03h;
      dn_row_cr04h <= drow_cr03h;
    end
  end
  logic bnz_cr04h;   // the branch fields hold a branch's values
  wire  db_en_cr03h = r_v_cr03h & (k_br_cr03h | (s5_cr03h & bnz_cr04h));
  always_ff @(posedge rcu_core_clk) begin
    if (db_en_cr03h) begin
      bnz_cr04h    <= k_br_cr03h;
      dn_bt_cr04h  <= k_br_cr03h & |act_cr03h;
      dn_bm_cr04h  <= !k_br_cr03h ? '0 : k_ret_cr03h ? same_cr03h : act_cr03h;
      dn_aux_cr04h <= k_ret_cr03h ? aux_cr03h : '0;
    end
  end

  // ---- Checks ----------------------------------------------------------------
  // Every op on R has an R kind; an op that writes a predicate has pred_we.
  wire bad_kind_cr02h = kind_cr02h == 5'd0 || kind_cr02h > K_PMOV ||
                        (unit_cr02h != rcu_dec_pkg::U_RONLY && unit_cr02h != rcu_dec_pkg::U_COLL);
  `CCV_ASSERT(r_kind_named, !(iv_cr02h && bad_kind_cr02h))
  `CCV_ASSERT(pred_write_has_we, !(iv_cr02h && wp_cr02h && !pwe_cr02h))

  // Busy, from flops only (P10, RI-21): rcu_kill's idle and done wake.
  assign busy_cr03h = iv_cr02h | r_v_cr03h | (|dn_v_cr03h);

endmodule
`undef CCV_CLK
`undef CCV_RST
