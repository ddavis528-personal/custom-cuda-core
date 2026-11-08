//===-- rcu_pred.sv - RCU predicate file: rows, guards, merges ------------===//
//
// Spec: docs/design-snapshots/rcu-arch-predicate-file.md (live: CCV RCU
//       Architecture, Predicate file tab: Organisation, Read ports, The
//       guard path, The split guard read (RA-32), Write ports);
//       docs/design-snapshots/rcu-arch-partition.md (rcu_pred's row, its
//       port budgets).
//
// Rows. 48 rows of 32 bits (CCV_P_PRED_REGS), row p bit l = lane l's bit of
// physical predicate p. The zero predicate (CCV_P_PRED_ZERO, 63) has no row:
// it reads 0 and is never written (A-64, asserted). One clock gate a row,
// its enable the OR of the write ports' hits, all from this module's flops
// (CG-2, CG-5). No reset: OOE maps a launched warp's predicates to the zero
// predicate (A-29).
//
// Predecode. A row index p is held as two one-hots, psel_hi (p[5:3], 6
// bits) and psel_lo (p[2:0], 8 bits); row p is selected by
// psel_hi[p>>3] & psel_lo[p&7], and 63 selects nothing.
//
// Stage I, the guard path (local stages cr01h = A-1, cr02h = A, cr03h =
// A+1). Slots 0-3 are S0-S3, 4-7 P0-P3, 8 R (CCV_ISSUE_SLOT_R).
//   cr01h  iv: the slot's issue valid lead. R's guard lead
//          (lead_guard_used, lead_guard_pred), predecoded into flops under
//          R's valid: in A R's guard is read from flops (RA-32, the split
//          guard read).
//          Each MIU slot's lead (valid, pred_we, phys_pred, active_mask),
//          captured for T (see the MIU lead below).
//   cr02h  A: every slot's payload from RCU's interface flop:
//          phys_pred_guard (S and P slots read it on the wire, 48:1),
//          pred_neg, issue_mask; the op-class decode's guarded, pdata and,
//          for R, whether the op is a branch or call; R's imm[13:0], the
//          predicate sources of pand, por, pxor, vote and ballot (TI-1).
//          MIU's pred_result, landing now (T).
//          guard = the row, with MIU's forward: a slot landing now with
//          pred_we on the guard's row substitutes pred_result on its
//          active lanes, (row & ~m_j) | (pred_result_j & m_j); negated by
//          pred_neg; forced to all ones unless the op is guarded and not
//          pdata. active = issue_mask & guard.
//   cr03h  A+1, from flops loaded under the slot's valid:
//          active_a[s] every slot; gv_a[k] for S slot k, the forwarded,
//          negated guard (a pdata op's sec_pred_data); pst_a[j] for P slot
//          j, the forwarded row without the negate (a predicate store's
//          data, lane 0's word); for R, rpsrc_a (RA, RB: forward, then
//          negate), rlow_a (active's lowest lane, one-hot) and the branch
//          lead lead_br_taken_a (OR of active) and lead_br_mask_a (active),
//          zero unless the op is a branch or call, each (* keep *): they
//          drive ccv_rcu_ooe_done's lead and nothing else.
//          sec_pred_bit_a, rcu_lane_ops' lead (Predicate file tab, step 4;
//          Partition rule 2; RA rev 98, re:RI-20): lane l's bit of
//          section k is active[o][l] for the S slot o that owns k (its
//          footprint, a lane-message op: the Lane and memory tab's own[k]),
//          0 for a section no slot owns. Loaded when an S slot issues, or
//          to clear what the last load left; its Q is the port.
//
// Merge write ports (NQ, 13: PL0-PL3 at 0-3, PR at 4, PC0-PC3 at 5-8,
// PG0-PG3 at 9-12, in the order the parent wires them). A port's valid
// leads its rows by a cycle and its data by two:
//   cr00h  qv: the port writes in two cycles
//   cr01h  its row, its old destination's row and whether it merges,
//          into the select flops under that valid
//   cr02h  the lanes it writes (m), the lanes taking the new value (mm)
//          and the new value; written at the edge ending cr02h:
//          D = mm ? val : (merge ? old : 0) on lanes m
// The old destination is read here, in the write cycle, from the rows as
// they stand (already final: OOE issues an op only once it is ready, A-43,
// and nothing writes a register after that). So OL0-OL3, OR and OC0-OC3
// are this module's own read ports, not outputs:
//   PL (lane op, lead section k, A+7): m all ones, mm = active, val the
//      lanes' sec_pred_out[k]; old from OLk (zero without merge_en, RI-6 (d))
//   PR (R op, A+2): m all ones, mm and val from rcu_r (pr_mm, pr_val), old
//      from OR under pr_mrg
//   PC (predicate-only copy, S slot k, A+2): m = ~active, mm none, old OCk
//   PG (restore row 16, A+2): m and mm all ones, val row_data[32p+31:32p]
//
// MIU write ports (PM0-PM3, NM 4): slot j's lead in T-1 (valid, pred_we,
// phys_pred, active_mask), its pred_result in T, written at T's edge with
// m = active_mask, d = pred_result. The lead is all the channel carries of
// those fields (RA-40): they are on the wire only in T-1, so this module
// keeps them a cycle. The enable that captures them is the lead's own
// valid & pred_we, from RCU's interface flop on ccv_miu_rcu_data (DA's
// ruling on RI-11: a flop at every block boundary), at 0 NGD: a CG-5
// finding, waived in rtl/cg-waivers.json with its depth (Daniel's ruling on
// RI-15, RA rev 87: module-level waivers for interface lead signals, each
// lead flop charged to the RCU block's 2%; the
// alternative, 4 x 47 flops loaded every cycle, is 188 ungated flops, past
// this module's 2%). The slot's write valid itself is flopped every cycle.
//
// Ports hitting one row in a cycle write disjoint lanes (asserted): a
// ld.pred's copy (inactive lanes) and its MIU return (active lanes) may land
// together.
//
// Demotion reads (D0-D3, ND 4): valid in cr00h, row in cr01h, the row on
// dq_cr02h from the select flops, the rows before this cycle's writes.
//
// The reference is the RCU model's predicate rules (sim/rcu/rcu_core.cpp:
// stage I's guard, active and predicate sources; gatherWrites and commit
// for the ports); test/rcu/pred_tb.cpp holds this module to a value model
// of them, cycle by cycle.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK rcu_core_clk
`define CCV_RST rst_r01h
module rcu_pred #(
  localparam int ROWS = ccv_prov_pkg::CCV_P_PRED_REGS,   // 48
  localparam int WP = ccv_prov_pkg::CCV_P_W_PHYS_PRED,   // a predicate row index, 6
  localparam int N = 32,                                 // lanes
  localparam int NS = ccv_params_pkg::CCV_ISSUE_RESOURCES, // issue slots, 9
  localparam int SR = ccv_params_pkg::CCV_ISSUE_SLOT_R,    // R's slot, 8
  localparam int NK = ccv_params_pkg::CCV_SECTIONS,        // S slots 0..NK-1
  localparam int NMP = ccv_params_pkg::CCV_MIU_PIPES,      // P slots NK..NK+NMP-1
  localparam int NQ = 13,                                // merge write ports
  localparam int NM = 4,                                 // MIU slots
  localparam int ND = 4,                                 // demotion read ports
  localparam int NH = (ROWS + 7) / 8,                    // psel_hi bits, 6
  localparam int WR = ccv_prov_pkg::CCV_P_W_PHYS_REG       // a GPR row index, 8
) (
  input  logic               rcu_core_clk,
  input  logic               rst_n,
  // Stage I: the issue slots.
  input  logic [NS-1:0]      iv_cr01h,      // slot s issues next cycle (the lead's valid)
  input  logic               lgu_cr01h,     // R's lead_guard_used
  input  logic [WP-1:0]      lgp_cr01h,     // R's lead_guard_pred
  input  logic [NS*WP-1:0]   gd_cr02h,      // phys_pred_guard
  input  logic [NS-1:0]      ng_cr02h,      // pred_neg
  input  logic [NS*N-1:0]    im_cr02h,      // issue_mask
  input  logic [NS*rcu_dec_pkg::OPC_W-1:0] opc_cr02h, // opcode (decoded here, rcu_dec_pkg)
  input  logic [NS-1:0]      cont_cr02h,    // cont: a continuation, no class of its own
  input  logic [NS*2-1:0]    drw_cr02h,     // done_row (an atomic's step)
  input  logic [NK-1:0]      swe_cr02h,     // S slot s's pred_we (a copy's predicate-only form)
  input  logic [NK*WR-1:0]   sdst_cr02h,    //   and phys_dst (the zero GPR)
  input  logic [2*WP+1:0]    rimm_cr02h,    // R's imm[13:0]: RA [5:0], neg [6]; RB [12:7], neg [13]
  input  logic [NK*NK-1:0]   ft_cr02h,      // S slot s's footprint, section k at s*NK + k
  output logic [NS*N-1:0]    act_cr03h,     // active_a[s]
  output logic               busy_cr03h,    // to rcu_kill's idle: an issue in A or a predicate write pending
  output logic [NK*N-1:0]    gv_cr03h,      // gv_a[k]: S slot k's guard (sec_pred_data)
  output logic [NMP*N-1:0]   pst_cr03h,     // pst_a[j]: P slot j's raw guard row (st.pred data)
  output logic [N-1:0]       rpa_cr03h,     // rpsrc_a RA
  output logic [N-1:0]       rpb_cr03h,     // rpsrc_a RB
  output logic [N-1:0]       low_cr03h,     // rlow_a
  output logic               lbt_cr03h,     // lead_br_taken_a
  output logic [N-1:0]       lbm_cr03h,     // lead_br_mask_a
  output logic [N*NK-1:0]    spb_cr03h,     // sec_pred_bit_a: lane l, section k at l*NK + k (rcu_lane_ops lead)
  // MIU: each slot's lead in T-1, its pred_result in T.
  input  logic [NM-1:0]      mv_cr01h,      // slot j lands next cycle
  input  logic [NM-1:0]      mwe_cr01h,     //   pred_we
  input  logic [NM*WP-1:0]   mp_cr01h,      //   phys_pred
  input  logic [NM*N-1:0]    mam_cr01h,     //   active_mask
  input  logic [NM*N-1:0]    mr_cr02h,      // pred_result, landing now
  // Merge write ports.
  input  logic [NQ-1:0]      qv_cr00h,      // port q writes in two cycles
  input  logic [NQ*WP-1:0]   qrow_cr01h,    //   this row
  input  logic [NQ*WP-1:0]   qorow_cr01h,   //   merging with this one's old value
  input  logic [NQ-1:0]      qmrg_cr01h,    //   if set (else old = 0)
  input  logic [NQ*N-1:0]    qm_cr02h,      //   on these lanes
  input  logic [NQ*N-1:0]    qmm_cr02h,     //   these taking the new value
  input  logic [NQ*N-1:0]    qval_cr02h,    //   this one
  // Demotion reads.
  input  logic [ND-1:0]      dv_cr00h,      // port d reads next cycle
  input  logic [ND*WP-1:0]   drow_cr01h,    //   this row
  output logic [ND*N-1:0]    dq_cr02h       // its 32 lanes
);

  localparam logic [WP-1:0] ZP = WP'(ccv_prov_pkg::CCV_P_PRED_ZERO);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge rcu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- The op-class decode (rcu_dec_pkg, the model's; RI-21 (4)) ------
  // Per slot: guarded and pdata; R's op a branch or call (its lead);
  // S slot s sends a lane message (a lane op or a GPR copy; not a
  // predicate-only copy, which is pwe and the zero GPR). A continuation has
  // no class.
  localparam logic [WR-1:0] ZG = WR'(ccv_prov_pkg::CCV_P_PHYS_ZERO);
  logic [NS-1:0] gt_cr02h, pdt_cr02h;
  logic [NK-1:0] lm_cr02h;
  logic          br_cr02h;
  always_comb begin
    logic [rcu_dec_pkg::CLS_W-1:0] c_cr02h;
    logic                          pc_cr02h;
    lm_cr02h = '0;
    br_cr02h = 1'b0;
    for (int s = 0; s < NS; s++) begin
      pc_cr02h = (s < NK) ? (swe_cr02h[s % NK] && sdst_cr02h[(s % NK)*WR +: WR] == ZG) : 1'b0;
      c_cr02h = rcu_dec_pkg::rcu_cls(opc_cr02h[s*rcu_dec_pkg::OPC_W +: rcu_dec_pkg::OPC_W],
                                     drw_cr02h[s*2 +: 2], pc_cr02h);
      gt_cr02h[s]  = !cont_cr02h[s] && c_cr02h[rcu_dec_pkg::CLS_GUARDED];
      pdt_cr02h[s] = !cont_cr02h[s] && c_cr02h[rcu_dec_pkg::CLS_PDATA];
      if (s < NK)
        lm_cr02h[s % NK] = !cont_cr02h[s] &&
          (c_cr02h[rcu_dec_pkg::CLS_UNIT +: 3] == rcu_dec_pkg::U_LANE ||
           c_cr02h[rcu_dec_pkg::CLS_UNIT +: 3] == rcu_dec_pkg::U_SFU ||
           c_cr02h[rcu_dec_pkg::CLS_UNIT +: 3] == rcu_dec_pkg::U_COPY);
      if (s == SR)
        br_cr02h = !cont_cr02h[s] &&
          (c_cr02h[rcu_dec_pkg::CLS_RK +: 5] == rcu_dec_pkg::RK_BRA ||
           c_cr02h[rcu_dec_pkg::CLS_RK +: 5] == rcu_dec_pkg::RK_CALL);
    end
  end

  function automatic logic [NH-1:0] dec_hi(input logic [WP-1:0] p);
    for (int h = 0; h < NH; h++) dec_hi[h] = p[WP-1:3] == h[WP-4:0];
  endfunction
  function automatic logic [7:0] dec_lo(input logic [WP-1:0] p);
    for (int i = 0; i < 8; i++) dec_lo[i] = p[2:0] == i[2:0];
  endfunction

  logic [ROWS*N-1:0] row_cr02h;   // row p at p*N

  // A row read from its one-hots: an 8:1 AND-OR per group, gated by its
  // psel_hi bit, then an NH:1 OR.
  function automatic logic [N-1:0] rd(input logic [NH-1:0] hi, input logic [7:0] lo,
                                      input logic [ROWS*N-1:0] rows);
    logic [N-1:0] acc;
    acc = '0;
    for (int h = 0; h < NH; h++) begin
      logic [N-1:0] grp;
      grp = '0;
      for (int i = 0; i < 8; i++)
        if (h * 8 + i < ROWS) grp = grp | ({N{lo[i]}} & rows[(h*8 + i)*N +: N]);
      acc = acc | ({N{hi[h]}} & grp);
    end
    rd = acc;
  endfunction

  // ---- Valids, flopped every cycle -------------------------------------
  logic [NS-1:0] iv_cr02h;
  logic [NQ-1:0] qv_cr01h, qa_cr02h;
  logic [ND-1:0] dv_cr01h;
  logic [NM-1:0] mw_cr02h;
  // busy's own copy of qa (NGD-7: qa's write paths run past busy's 12).
  (* keep *) logic qab_cr02h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      iv_cr02h <= '0;
      qv_cr01h <= '0;
      qa_cr02h <= '0;
      qab_cr02h <= 1'b0;
      dv_cr01h <= '0;
      mw_cr02h <= '0;
    end else begin
      iv_cr02h <= iv_cr01h;
      qv_cr01h <= qv_cr00h;
      qa_cr02h <= qv_cr01h;
      qab_cr02h <= |qv_cr01h;
      dv_cr01h <= dv_cr00h;
      mw_cr02h <= mv_cr01h & mwe_cr01h;
    end
  end

  // ---- R's guard lead (RA-32), kept for A -----------------------------
  // Loaded under the lead's valid, from RCU's interface flop on the issue
  // channel (CG-5 waiver under RA rev 87, as MIU's lead below).
  wire rl_en_cr01h = iv_cr01h[SR];
  logic [NH-1:0] rg_hi_cr02h;
  logic [7:0]    rg_lo_cr02h;
  always_ff @(posedge rcu_core_clk) begin
    // Without the lead (an unguarded op) the row decodes to none: it reads 0.
    if (rl_en_cr01h) begin
      rg_hi_cr02h <= lgu_cr01h ? dec_hi(lgp_cr01h) : '0;
      rg_lo_cr02h <= dec_lo(lgp_cr01h);
    end
  end
  logic rgu_cr02h;   // for the lead's contract only
  always_ff @(posedge rcu_core_clk) begin
    rgu_cr02h <= lgu_cr01h;
  end

  // ---- MIU's lead, kept for T ------------------------------------------
  wire [NM-1:0] ml_en_cr01h = mv_cr01h & mwe_cr01h;   // the interface flop's Q (CG-5 waiver)
  logic [NM*NH-1:0] m_hi_cr02h;
  logic [NM*8-1:0]  m_lo_cr02h;
  logic [NM*N-1:0]  m_am_cr02h;
  for (genvar j = 0; j < NM; j++) begin : g_ml
    always_ff @(posedge rcu_core_clk) begin
      if (ml_en_cr01h[j]) begin
        m_hi_cr02h[j*NH +: NH] <= dec_hi(mp_cr01h[j*WP +: WP]);
        m_lo_cr02h[j*8 +: 8]   <= dec_lo(mp_cr01h[j*WP +: WP]);
        m_am_cr02h[j*N +: N]   <= mam_cr01h[j*N +: N];
      end
    end
  end

  // ---- Stage I: guards, forward, active --------------------------------
  // A read in A with MIU's forward: the slots landing now on the row (by
  // its one-hots) substitute pred_result on their active lanes.
  function automatic logic [N-1:0] fwd(input logic [NH-1:0] hi, input logic [7:0] lo,
                                       input logic [N-1:0] r,
                                       input logic [NM-1:0] mw, input logic [NM*NH-1:0] mhi,
                                       input logic [NM*8-1:0] mlo, input logic [NM*N-1:0] mam,
                                       input logic [NM*N-1:0] mr);
    logic [N-1:0] fm, fd;
    fm = '0;
    fd = '0;
    for (int j = 0; j < NM; j++) begin
      logic hit;
      hit = mw[j] & (|(hi & mhi[j*NH +: NH])) & (|(lo & mlo[j*8 +: 8]));
      fm = fm | ({N{hit}} & mam[j*N +: N]);
      fd = fd | ({N{hit}} & mam[j*N +: N] & mr[j*N +: N]);
    end
    fwd = (r & ~fm) | fd;
  endfunction

  logic [NS*NH-1:0] g_hi_cr02h;
  logic [NS*8-1:0]  g_lo_cr02h;
  logic [NS*N-1:0]  graw_cr02h, gv_d_cr02h, act_d_cr02h;
  always_comb begin
    for (int s = 0; s < NS; s++) begin
      logic [N-1:0] r_cr02h, g_cr02h;
      logic         force_cr02h;
      if (s == SR) begin
        g_hi_cr02h[s*NH +: NH] = rg_hi_cr02h;
        g_lo_cr02h[s*8 +: 8]   = rg_lo_cr02h;
      end else begin
        g_hi_cr02h[s*NH +: NH] = dec_hi(gd_cr02h[s*WP +: WP]);
        g_lo_cr02h[s*8 +: 8]   = dec_lo(gd_cr02h[s*WP +: WP]);
      end
      r_cr02h = rd(g_hi_cr02h[s*NH +: NH], g_lo_cr02h[s*8 +: 8], row_cr02h);
      r_cr02h = fwd(g_hi_cr02h[s*NH +: NH], g_lo_cr02h[s*8 +: 8], r_cr02h,
                    mw_cr02h, m_hi_cr02h, m_lo_cr02h, m_am_cr02h, mr_cr02h);
      graw_cr02h[s*N +: N] = r_cr02h;
      g_cr02h = ng_cr02h[s] ? ~r_cr02h : r_cr02h;
      gv_d_cr02h[s*N +: N] = g_cr02h;
      force_cr02h = !gt_cr02h[s] || pdt_cr02h[s];
      act_d_cr02h[s*N +: N] = im_cr02h[s*N +: N] & (g_cr02h | {N{force_cr02h}});
    end
  end

  // R's predicate sources: read on the wire, forward, then negate.
  logic [N-1:0] rpa_d_cr02h, rpb_d_cr02h, low_d_cr02h, lbm_d_cr02h;
  always_comb begin
    logic [WP-1:0] pa_cr02h, pb_cr02h;
    logic [N-1:0]  va_cr02h, vb_cr02h, ar_cr02h;
    pa_cr02h = rimm_cr02h[WP-1:0];
    pb_cr02h = rimm_cr02h[2*WP:WP+1];
    va_cr02h = fwd(dec_hi(pa_cr02h), dec_lo(pa_cr02h), rd(dec_hi(pa_cr02h), dec_lo(pa_cr02h), row_cr02h),
                   mw_cr02h, m_hi_cr02h, m_lo_cr02h, m_am_cr02h, mr_cr02h);
    vb_cr02h = fwd(dec_hi(pb_cr02h), dec_lo(pb_cr02h), rd(dec_hi(pb_cr02h), dec_lo(pb_cr02h), row_cr02h),
                   mw_cr02h, m_hi_cr02h, m_lo_cr02h, m_am_cr02h, mr_cr02h);
    rpa_d_cr02h = rimm_cr02h[WP] ? ~va_cr02h : va_cr02h;
    rpb_d_cr02h = rimm_cr02h[2*WP+1] ? ~vb_cr02h : vb_cr02h;
    ar_cr02h = act_d_cr02h[SR*N +: N];
    low_d_cr02h = ar_cr02h & ~(ar_cr02h - N'(1));
    lbm_d_cr02h = {N{br_cr02h}} & ar_cr02h;
  end

  // ---- Stage I's flops, loaded under the slot's valid ------------------
  wire [NS-1:0] iv_en_cr02h = iv_cr02h;
  for (genvar s = 0; s < NS; s++) begin : g_act
    always_ff @(posedge rcu_core_clk) begin
      if (iv_en_cr02h[s]) act_cr03h[s*N +: N] <= act_d_cr02h[s*N +: N];
    end
  end
  for (genvar k = 0; k < NK; k++) begin : g_gv
    always_ff @(posedge rcu_core_clk) begin
      if (iv_en_cr02h[k]) gv_cr03h[k*N +: N] <= gv_d_cr02h[k*N +: N];
    end
  end
  for (genvar j = 0; j < NMP; j++) begin : g_pst
    always_ff @(posedge rcu_core_clk) begin
      if (iv_en_cr02h[NK + j]) pst_cr03h[j*N +: N] <= graw_cr02h[(NK + j)*N +: N];
    end
  end
  (* keep *) logic           lbt_q_cr03h;
  (* keep *) logic [N-1:0]   lbm_q_cr03h;
  always_ff @(posedge rcu_core_clk) begin
    if (iv_en_cr02h[SR]) begin
      rpa_cr03h   <= rpa_d_cr02h;
      rpb_cr03h   <= rpb_d_cr02h;
      low_cr03h   <= low_d_cr02h;
      lbt_q_cr03h <= |lbm_d_cr02h;
      lbm_q_cr03h <= lbm_d_cr02h;
    end
  end
  assign lbt_cr03h = lbt_q_cr03h;
  assign lbm_cr03h = lbm_q_cr03h;

  // sec_pred_bit_a: section ownership from the S slots' footprints and
  // class (this module's own copy of the decode, Partition rule 1).
  logic [NK*NK-1:0] own_cr02h;     // own[k*NK + s]: S slot s owns section k
  logic [N*NK-1:0]  spb_d_cr02h;
  always_comb begin
    for (int k = 0; k < NK; k++)
      for (int s = 0; s < NK; s++)
        own_cr02h[k*NK + s] = iv_cr02h[s] & lm_cr02h[s] & ft_cr02h[s*NK + k];
    for (int l = 0; l < N; l++)
      for (int k = 0; k < NK; k++) begin
        spb_d_cr02h[l*NK + k] = 1'b0;
        for (int s = 0; s < NK; s++)
          spb_d_cr02h[l*NK + k] = spb_d_cr02h[l*NK + k] | (own_cr02h[k*NK + s] & act_d_cr02h[s*N + l]);
      end
  end
  logic spbnz_cr03h;   // the last load was non-zero
  wire spb_en_cr02h = (|iv_cr02h[NK-1:0]) | spbnz_cr03h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      spb_cr03h   <= '0;
      spbnz_cr03h <= 1'b0;
    end else if (spb_en_cr02h) begin
      spb_cr03h   <= spb_d_cr02h;
      spbnz_cr03h <= |spb_d_cr02h;
    end
  end

  // ---- Merge write ports: selects, old destination, data ---------------
  wire [NQ-1:0] qv_en_cr01h = qv_cr01h;
  (* keep *) logic [NQ*NH-1:0] w_hi_cr02h, o_hi_cr02h;
  (* keep *) logic [NQ*8-1:0]  w_lo_cr02h, o_lo_cr02h;
  for (genvar q = 0; q < NQ; q++) begin : g_qsel
    always_ff @(posedge rcu_core_clk) begin
      if (qv_en_cr01h[q]) begin
        w_hi_cr02h[q*NH +: NH] <= dec_hi(qrow_cr01h[q*WP +: WP]);
        w_lo_cr02h[q*8 +: 8]   <= dec_lo(qrow_cr01h[q*WP +: WP]);
        // No merge: the old destination decodes to no row and reads 0.
        o_hi_cr02h[q*NH +: NH] <= qmrg_cr01h[q] ? dec_hi(qorow_cr01h[q*WP +: WP]) : '0;
        o_lo_cr02h[q*8 +: 8]   <= dec_lo(qorow_cr01h[q*WP +: WP]);
      end
    end
  end

  // Every port into the rows: the merge ports, then MIU's.
  localparam int NP = NQ + NM;
  logic [NP*NH-1:0] p_hi_cr02h;
  logic [NP*8-1:0]  p_lo_cr02h;
  logic [NP-1:0]    p_act_cr02h;
  logic [NP*N-1:0]  p_m_cr02h, p_d_cr02h;
  always_comb begin
    for (int q = 0; q < NQ; q++) begin
      logic [N-1:0] old_cr02h, mm_cr02h;
      old_cr02h = rd(o_hi_cr02h[q*NH +: NH], o_lo_cr02h[q*8 +: 8], row_cr02h);
      mm_cr02h = qmm_cr02h[q*N +: N];
      p_hi_cr02h[q*NH +: NH] = w_hi_cr02h[q*NH +: NH];
      p_lo_cr02h[q*8 +: 8]   = w_lo_cr02h[q*8 +: 8];
      p_act_cr02h[q]         = qa_cr02h[q];
      p_m_cr02h[q*N +: N]    = qm_cr02h[q*N +: N];
      p_d_cr02h[q*N +: N]    = (qval_cr02h[q*N +: N] & mm_cr02h) | (old_cr02h & ~mm_cr02h);
    end
    for (int j = 0; j < NM; j++) begin
      p_hi_cr02h[(NQ + j)*NH +: NH] = m_hi_cr02h[j*NH +: NH];
      p_lo_cr02h[(NQ + j)*8 +: 8]   = m_lo_cr02h[j*8 +: 8];
      p_act_cr02h[NQ + j]           = mw_cr02h[j];
      p_m_cr02h[(NQ + j)*N +: N]    = m_am_cr02h[j*N +: N];
      p_d_cr02h[(NQ + j)*N +: N]    = mr_cr02h[j*N +: N];
    end
  end

  // ---- Rows: hits, enables and D ---------------------------------------
  logic [ROWS*NP-1:0] hit_cr02h;   // row p, port q at p*NP + q
  logic [ROWS-1:0]    row_en_cr02h;
  logic [ROWS*N-1:0]  row_d_cr02h;
  always_comb begin
    for (int p = 0; p < ROWS; p++) begin
      logic [N-1:0] m, dv;
      m = '0;
      dv = '0;
      row_en_cr02h[p] = 1'b0;
      for (int q = 0; q < NP; q++) begin
        logic h;
        h = p_act_cr02h[q] & p_hi_cr02h[q*NH + p/8] & p_lo_cr02h[q*8 + p%8];
        hit_cr02h[p*NP + q] = h;
        row_en_cr02h[p] = row_en_cr02h[p] | h;
        m  = m | ({N{h}} & p_m_cr02h[q*N +: N]);
        dv = dv | ({N{h}} & p_m_cr02h[q*N +: N] & p_d_cr02h[q*N +: N]);
      end
      row_d_cr02h[p*N +: N] = (row_cr02h[p*N +: N] & ~m) | dv;
    end
  end
  for (genvar p = 0; p < ROWS; p++) begin : g_row
    logic [N-1:0] pq_cr02h;
    always_ff @(posedge rcu_core_clk) begin
      if (row_en_cr02h[p]) pq_cr02h <= row_d_cr02h[p*N +: N];
    end
    assign row_cr02h[p*N +: N] = pq_cr02h;
  end

  // ---- Demotion reads --------------------------------------------------
  wire [ND-1:0] dv_en_cr01h = dv_cr01h;
  (* keep *) logic [ND*NH-1:0] d_hi_cr02h;
  (* keep *) logic [ND*8-1:0]  d_lo_cr02h;
  for (genvar d = 0; d < ND; d++) begin : g_dsel
    always_ff @(posedge rcu_core_clk) begin
      if (dv_en_cr01h[d]) begin
        d_hi_cr02h[d*NH +: NH] <= dec_hi(drow_cr01h[d*WP +: WP]);
        d_lo_cr02h[d*8 +: 8]   <= dec_lo(drow_cr01h[d*WP +: WP]);
      end
    end
  end
  always_comb begin
    for (int d = 0; d < ND; d++)
      dq_cr02h[d*N +: N] = rd(d_hi_cr02h[d*NH +: NH], d_lo_cr02h[d*8 +: 8], row_cr02h);
  end

  // ---- Contracts -------------------------------------------------------
  logic overlap_cr02h, bad_q_cr01h, bad_m_cr01h, bad_r_cr01h, hazard_cr02h, lead_cr02h;
  always_comb begin
    overlap_cr02h = 1'b0;
    for (int p = 0; p < ROWS; p++) begin
      logic [N-1:0] seen;
      seen = '0;
      for (int q = 0; q < NP; q++)
        if (hit_cr02h[p*NP + q]) begin
          overlap_cr02h = overlap_cr02h | |(seen & p_m_cr02h[q*N +: N]);
          seen = seen | p_m_cr02h[q*N +: N];
        end
    end
    bad_q_cr01h = 1'b0;
    for (int q = 0; q < NQ; q++)
      bad_q_cr01h = bad_q_cr01h | (qv_cr01h[q] && 32'(qrow_cr01h[q*WP +: WP]) >= ROWS);
    bad_m_cr01h = 1'b0;
    for (int j = 0; j < NM; j++)
      bad_m_cr01h = bad_m_cr01h | (ml_en_cr01h[j] && 32'(mp_cr01h[j*WP +: WP]) >= ROWS);
    bad_r_cr01h = 1'b0;
    for (int d = 0; d < ND; d++)
      bad_r_cr01h = bad_r_cr01h | (dv_cr01h[d] && 32'(drow_cr01h[d*WP +: WP]) >= ROWS &&
                                   drow_cr01h[d*WP +: WP] != ZP);
    // A guard read of a row a merge port writes in the same cycle (only
    // MIU's writes are forwarded), and R's guard lead naming another row.
    hazard_cr02h = 1'b0;
    for (int s = 0; s < NS; s++)
      if (iv_cr02h[s] && (gt_cr02h[s] || pdt_cr02h[s]))
        for (int q = 0; q < NQ; q++)
          hazard_cr02h = hazard_cr02h |
            (qa_cr02h[q] & (|(g_hi_cr02h[s*NH +: NH] & w_hi_cr02h[q*NH +: NH])) &
                           (|(g_lo_cr02h[s*8 +: 8] & w_lo_cr02h[q*8 +: 8])));
    lead_cr02h = iv_cr02h[SR] && gt_cr02h[SR] &&
                 (!rgu_cr02h || rg_hi_cr02h != dec_hi(gd_cr02h[SR*WP +: WP]) ||
                  rg_lo_cr02h != dec_lo(gd_cr02h[SR*WP +: WP]));
  end
  // Ports on one row in a cycle write disjoint lanes.
  `CCV_ASSERT(pred_write_disjoint, !overlap_cr02h)
  // A write never names the zero predicate (A-64) or a row past the pool.
  `CCV_ASSERT(pred_write_row_named, !bad_q_cr01h)
  `CCV_ASSERT(pred_load_row_named, !bad_m_cr01h)
  // A demotion read names a row of the pool or the zero predicate.
  `CCV_ASSERT(pred_read_row_named, !bad_r_cr01h)
  // A guard is never written in its own A but by MIU (the forward).
  `CCV_ASSERT(guard_no_hazard, !hazard_cr02h)
  // R's guard lead names the payload's guard (RA-31, RA-32).
  `CCV_ASSERT(guard_lead_names, !lead_cr02h)
  // One owner a section among the S slots.
  logic own_bad_cr02h;
  always_comb begin
    own_bad_cr02h = 1'b0;
    for (int k = 0; k < NK; k++) own_bad_cr02h |= $countones(own_cr02h[k*NK +: NK]) > 1;
  end
  `CCV_ASSERT(pred_spb_own, !own_bad_cr02h)

  // Busy, from flops only (P10, RI-21): rcu_kill's idle.
  assign busy_cr03h = (|iv_cr02h) | (|qv_cr01h) | qab_cr02h | (|dv_cr01h);

endmodule
`undef CCV_CLK
`undef CCV_RST
