//===-- rcu_mig.sv - RCU migration: pairing, demotion and restore engines -===//
//
// Spec: docs/design-snapshots/rcu-arch-migration.md (live: CCV RCU
//       Architecture, Migration tab: Pairing, Demotion engine, Restore
//       engine, Kill, Flops and checks); docs/design-snapshots/
//       rcu-arch-partition.md (rcu_mig's rows).
//
// Migration moves one warp's 16 GPR rows and its predicate row (row 16)
// between RCU and PCA, a 1,024-bit row a message. It owns no PRF port: a
// demotion reads GPR rows on R2 in A+1 of a cycle whose R op does not read
// R2, and the predicate row on D0-D3; a restore writes GPR rows on RW in
// A+2 of a cycle whose R op writes no GPR, and the predicate row on
// PG0-PG3.
//
// Local stages: cr00h a channel's valid on the wire (A-2 for the R slot);
// cr01h the payload lands, the R slot's lead valid (A-1); cr02h A, the
// decision cycle; cr03h A+1, the read; cr04h A+2, the write / payload.
//
// Port boundary (no logic in a parent between children, CLAUDE.md): every
// request this module makes of a shared port comes from its own flops. The
// R2 and RW ports' select between the R op and migration is the bank
// slices' (rcu_bank_slice takes this module's request beside the R op's):
//   R2: r2v_cr01h, a lead from dm_busy (the slices' select flops load it);
//       r2row_cr02h, the next row's map entry; the slices select it in A
//       unless the R op reads R2 (rr2, from its opcode), when this
//       module also holds back (dm_want's ~r2_busy term).
//   RW: rwv_cr02h, the lead of a possible GPR restore write (flops only);
//       rwsel_cr03h, the decision (rs_v_a1, not row 16); rwrow_cr03h, its
//       row (loaded in A); rwdat_cr04h, the row's data in the write cycle.
//   D0-D3 (rcu_pred's demotion reads) and PG0-PG3 (four of rcu_pred's merge
//       write ports, m and mm all ones, no merge) are migration's alone.
// Row data is lane-major, lane l (or predicate p) at [32l+31:32l], as the
// model packs it (sim/rcu/rcu_block.cpp) and the slices' R2 read returns.
//
// Pairing (A-45): a map and a command pair by (warp, direction), in either
// order, in queues of CCV_TIER1_WARPS entries. Each lands in its payload
// cycle into the entry the flopped free one-hot names, under the flopped
// valid. The picks (the lowest map entry with a matching command, per
// direction) are flopped; a launch clears both entries and returns both
// credits, one per channel a cycle, from a pending count that a kill's
// drops add to (RI-6 (a)).
//
// Demotion: the stall-safe sender pattern (Migration tab): dm_want from
// this module's flops and the slot-8 decode, dm_v_q written every cycle
// with D = dm_want & ~stall, and every state change enabled by dm_v_q a
// cycle on. Wake leads by CCV_WAKE_LAT. Rows 0..16 in order, read live.
//
// Restore: a FIFO of CCV_CREDIT_DEPTH rows, landed at the tail. A restore
// launches only for the warp at the head; each row is decided in A,
// written in A+2, popped and its credit set at A+2's edge (TI-13: a credit
// means written). Row 16 closes the transfer. A dead row (a killed warp's)
// pops without a write, one a cycle, never beside a write's pop (RI-6 (c)).
//
// Kill: kill_valid in K-1, the mask in K, both flopped; from K+1 the
// killed warps' pairing entries drop (credits returned), a demotion stops
// at a row boundary, a restore stops and its FIFO rows go dead. quiet
// feeds rcu_kill's ack-ready.
//
// The reference is the RCU model's migration (sim/rcu/rcu_core.cpp,
// migrate(), kill(), killQuiet()); test/rcu/mig_tb.cpp holds this module to
// a value model of the Migration tab, cycle by cycle.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK rcu_core_clk
`define CCV_RST rst_r01h
module rcu_mig #(
  localparam int Q = ccv_params_pkg::CCV_TIER1_WARPS,     // pairing entries, 4
  localparam int F = ccv_params_pkg::CCV_CREDIT_DEPTH,    // restore FIFO, 4
  localparam int NG = ccv_params_pkg::CCV_GPRS,           // GPR rows, 16
  localparam int NP = ccv_params_pkg::CCV_PREDS,          // predicates, 4
  localparam int NR = NG + 1,                             // rows a migration, 17
  localparam int WW = ccv_params_pkg::CCV_W_WARP_ID,      // 5
  localparam int NWP = ccv_params_pkg::CCV_TIER1_WARPS + ccv_params_pkg::CCV_PARKED_WARPS, // 32
  localparam int WMR = ccv_params_pkg::CCV_W_MIG_ROW,     // 5
  localparam int WR = ccv_prov_pkg::CCV_P_W_PHYS_REG,     // 8
  localparam int WP = ccv_prov_pkg::CCV_P_W_PHYS_PRED,    // 6
  localparam int WD = ccv_params_pkg::CCV_W_DATA,         // 1024
  localparam int WL = ccv_params_pkg::CCV_WAKE_LAT,       // 4
  localparam int CD = ccv_params_pkg::CCV_CREDIT_DEPTH    // rcu_pca_mig's credits
) (
  input  logic               rcu_core_clk,
  input  logic               rst_n,
  // ccv_ooe_rcu_map: valid on the wire, then the payload (gpr_pos and
  // gpr_width dropped: OOE keeps them).
  input  logic               mv_cr00h,
  input  logic [WW-1:0]      mw_cr01h,      // warp_id
  input  logic               md_cr01h,      // direction: 0 demote, 1 restore
  input  logic [NG*WR-1:0]   mg_cr01h,      // gpr_map, R_a at [8a+7:8a]
  input  logic [NP*WP-1:0]   mp_cr01h,      // pred_map, P_q at [6q+5:6q]
  output logic               mcr_cr02h,     // its credit
  // ccv_rau_rcu_mig.
  input  logic               cv_cr00h,
  input  logic [WW-1:0]      cw_cr01h,
  input  logic               cd_cr01h,
  output logic               ccr_cr02h,
  // ccv_pca_rcu_mig: restore rows.
  input  logic               pv_cr00h,
  input  logic [WW-1:0]      pw_cr01h,
  input  logic [WMR-1:0]     prow_cr01h,    // mig_row
  input  logic [WD-1:0]      pdat_cr01h,    // row_data
  output logic               pcr_cr04h,     // its credit: the row is written
  // ccv_rcu_pca_mig: demotion rows.
  input  logic               ost_cr02h,     // the channel's stall
  input  logic               ocr_cr01h,     // a credit returned
  output logic               ov_cr03h,      // valid (dm_v_q)
  output logic [WW-1:0]      ow_cr04h,      // payload: warp_id
  output logic [WMR-1:0]     orow_cr04h,    //   mig_row
  output logic [WD-1:0]      odat_cr04h,    //   row_data
  output logic               owk_cr03h,     // rcu_pca_mig_wake
  // Kill: valid in K-1, the warp mask in K.
  input  logic               kv_cr00h,
  input  logic [NWP-1:0]     km_cr01h,
  output logic               quiet_cr02h,   // to rcu_kill: nothing of a killed warp held
  output logic               busy_cr02h,    // to rcu_kill's idle
  // The R slot: its lead valid, then the payload's decode.
  input  logic               riv_cr01h,     // R issues next cycle
  input  logic [rcu_dec_pkg::OPC_W-1:0] ropc_cr02h, // the R op's opcode (decoded here, rcu_dec_pkg)
  input  logic               rmrg_cr02h,    // the R op's merge_en
  // R2 (the slices) and D0-D3 (rcu_pred): requests, then the rows read.
  output logic               r2v_cr01h,     // R2 lead
  output logic [WR-1:0]      r2row_cr02h,   // R2 row
  input  logic [WD-1:0]      rd2_cr03h,     // R2's 32 lanes, lane l at [32l+31:32l]
  output logic [NP-1:0]      dv_cr01h,      // D0-D3 leads
  output logic [NP*WP-1:0]   drow_cr02h,    // D0-D3 rows
  input  logic [NP*32-1:0]   dq_cr03h,      // D_p's 32 lanes at [32p+31:32p]
  // RW (the slices) and PG0-PG3 (rcu_pred): restore writes.
  output logic               rwv_cr02h,     // RW lead: a GPR restore row may be decided
  output logic               rwsel_cr03h,   // RW: the restore writes (else the R op's)
  output logic [WR-1:0]      rwrow_cr03h,   // RW row
  output logic [WD-1:0]      rwdat_cr04h,   // RW data, all 32 lanes
  output logic               gv_cr02h,      // PG lead: the predicate row is decided
  output logic [NP*WP-1:0]   grow_cr03h,    // PG rows
  output logic [NP*32-1:0]   gdat_cr04h     // PG data: P_p = row_data[32p+31:32p]
);

  localparam logic [WR-1:0] ZROW = WR'(ccv_prov_pkg::CCV_P_PHYS_ZERO);
  localparam int WC = $clog2(CD + 1);    // dm_cred, 0..CD
  localparam int WN = $clog2(2 * Q + 1); // pending credits

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_n_r01h;
  always_ff @(posedge rcu_core_clk) begin
    rst_n_r01h <= rst_n;
  end
  wire rst_r01h = !rst_n_r01h;

  function automatic logic [Q-1:0] lowest(input logic [Q-1:0] v);
    logic seen;
    seen = 1'b0;
    for (int i = 0; i < Q; i++) begin
      lowest[i] = v[i] & ~seen;
      seen = seen | v[i];
    end
  endfunction
  function automatic logic [F-1:0] rot(input logic [F-1:0] p);   // the next FIFO place
    rot = {p[F-2:0], p[F-1]};
  endfunction

  // ---- Inbound valids and the R slot's lead, flopped ---------------------
  logic mrxv_cr01h, crxv_cr01h, prxv_cr01h, rivq_cr02h, ocrq_cr02h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      mrxv_cr01h <= 1'b0;
      crxv_cr01h <= 1'b0;
      prxv_cr01h <= 1'b0;
      rivq_cr02h <= 1'b0;
      ocrq_cr02h <= 1'b0;
    end else begin
      mrxv_cr01h <= mv_cr00h;
      crxv_cr01h <= cv_cr00h;
      prxv_cr01h <= pv_cr00h;
      rivq_cr02h <= riv_cr01h;
      ocrq_cr02h <= ocr_cr01h;
    end
  end
  // The R op's class (rcu_dec_pkg, the model's decode; the R slot carries
  // no atomic and no copy): it reads R2 when it merges into a GPR, and holds
  // RW when it writes a GPR or is a collective (the model's r2_busy, rw_busy).
  wire [rcu_dec_pkg::CLS_W-1:0] rcls_cr02h = rcu_dec_pkg::rcu_cls(ropc_cr02h, 2'd0, 1'b0);
  wire rgd_cr02h  = rcls_cr02h[rcu_dec_pkg::CLS_GDST];
  wire rr2_cr02h  = rmrg_cr02h & rgd_cr02h;
  wire rrw_cr02h  = rgd_cr02h | (rcls_cr02h[rcu_dec_pkg::CLS_UNIT +: 3] == rcu_dec_pkg::U_COLL);
  wire r2b_cr02h = rivq_cr02h & rr2_cr02h;   // the R op holds R2
  wire rwb_cr02h = rivq_cr02h & rrw_cr02h;   // the R op holds RW

  // ---- Kill --------------------------------------------------------------
  // kv_q in K, the mask flopped at K's edge: kact and kmn act in K+1.
  // mig_kmask accumulates killed warps until each one's next map lands; a
  // land clears its warp two cycles on (P+2's edge, from flops: the entry's
  // warp and the mask, never the input), unless a kill of that warp acts in
  // P+1 or P+2 (it drops the map). A PCA row of the new migration lands at
  // least two cycles after its map (RI's ordering note; the bench holds it).
  logic kvq_cr01h, kact_cr02h;
  logic [NWP-1:0] kmn_cr02h, kmask_cr02h;
  logic [Q-1:0] mjl_cr02h, kmh_cr03h;   // entry i landed last cycle; its warp clears next
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      kvq_cr01h  <= 1'b0;
      kact_cr02h <= 1'b0;
    end else begin
      kvq_cr01h  <= kv_cr00h;
      kact_cr02h <= kvq_cr01h;
    end
  end
  wire kmn_en_cr01h = kvq_cr01h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) kmn_cr02h <= '0;
    else if (kmn_en_cr01h) kmn_cr02h <= km_cr01h;
  end
  // The killed-now test: a warp in this kill's mask, in K+1.
  function automatic logic killed(input logic [WW-1:0] w, input logic act, input logic [NWP-1:0] m);
    killed = act & m[w];
  endfunction

  // ---- Pairing queues ----------------------------------------------------
  logic [Q-1:0]     mq_v_cr02h, cq_v_cr02h;
  logic [Q-1:0]     mq_free_cr02h, cq_free_cr02h;
  logic [WW-1:0]    mq_w_cr02h [Q];
  logic             mq_d_cr02h [Q];
  logic [NG*WR-1:0] mq_g_cr02h [Q];
  logic [NP*WP-1:0] mq_p_cr02h [Q];
  logic [WW-1:0]    cq_w_cr02h [Q];
  logic             cq_d_cr02h [Q];
  wire [Q-1:0] mq_land_cr01h = mrxv_cr01h ? mq_free_cr02h : '0;   // into the free entry
  wire [Q-1:0] cq_land_cr01h = crxv_cr01h ? cq_free_cr02h : '0;

  // The kmask clear (above): P+1 finds the landed entry's warp in the mask.
  logic [Q-1:0] kmhn_cr02h;
  logic [NWP-1:0] kmclr_cr03h;
  always_comb begin
    kmclr_cr03h = '0;
    for (int i = 0; i < Q; i++) begin
      kmhn_cr02h[i] = mjl_cr02h[i] & kmask_cr02h[mq_w_cr02h[i]] & ~killed(mq_w_cr02h[i], kact_cr02h, kmn_cr02h);
      if (kmh_cr03h[i] & ~killed(mq_w_cr02h[i], kact_cr02h, kmn_cr02h))
        kmclr_cr03h |= NWP'(1) << mq_w_cr02h[i];
    end
  end
  wire kmp_en_cr01h = mrxv_cr01h | (|mjl_cr02h) | (|kmh_cr03h);
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      mjl_cr02h <= '0;
      kmh_cr03h <= '0;
    end else if (kmp_en_cr01h) begin
      mjl_cr02h <= mq_land_cr01h;
      kmh_cr03h <= kmhn_cr02h;
    end
  end
  wire kmask_en_cr01h = kvq_cr01h | (|kmh_cr03h);
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) kmask_cr02h <= '0;
    else if (kmask_en_cr01h)
      kmask_cr02h <= (kmask_cr02h & ~kmclr_cr03h) | (kvq_cr01h ? km_cr01h : '0);
  end

  // ---- Restore FIFO state (declared here: the restore pick reads it) -----
  logic [F-1:0]   f_v_cr02h, f_dead_cr02h, hd_cr02h, tl_cr02h;
  logic           f_r16_cr02h [F];   // mig_row is 16
  logic [WW-1:0]  f_w_cr02h [F];
  logic [NG-1:0]  f_rg_cr02h [F];    // mig_row one-hot, GPR rows (row 16 in f_r16)
  logic [WD-1:0]  f_dat_cr02h [F];
  logic           rs_busy_cr02h;
  (* keep *) logic dm_busy_cr02h;   // dm_wk_cr03h is its copy for the wake
  logic           rs_v_cr03h, rs_v_cr04h;   // rs_v_a1, rs_v_a2

  logic hd_v_cr02h, hd_dead_cr02h;
  logic [WW-1:0] hd_w_cr02h;
  always_comb begin
    hd_v_cr02h = |(hd_cr02h & f_v_cr02h);
    hd_dead_cr02h = |(hd_cr02h & f_dead_cr02h);
    hd_w_cr02h = '0;
    for (int i = 0; i < F; i++) hd_w_cr02h |= {WW{hd_cr02h[i]}} & f_w_cr02h[i];
  end
  // A dead head pops without a write, never beside a write's pop.
  wire dpop_cr02h = hd_v_cr02h & hd_dead_cr02h & ~rs_v_cr03h & ~rs_v_cr04h;
  wire hd_en_cr02h = rs_v_cr03h | dpop_cr02h;
  logic [F-1:0] fvn_cr02h, fdn_cr02h, f16n_cr02h;   // the FIFO's next state (below)
  // Next cycle's head, for the restore pick: the head that stays (live
  // unless it goes dead now), or a row landing into the empty FIFO. A head
  // that moves is not predicted (the pick waits a cycle).
  wire hn_hd_cr02h = ~hd_en_cr02h & hd_v_cr02h & ~|(hd_cr02h & fdn_cr02h);
  wire hn_pw_cr01h = ~hd_en_cr02h & ~hd_v_cr02h & prxv_cr01h & |(tl_cr02h & hd_cr02h);

  // ---- Picks and launch --------------------------------------------------
  // Both picks are flopped one-hots of a map entry and its command, made a
  // cycle ahead from the entries that stay: demotion, the lowest paired
  // entry; restore, the paired map of the FIFO head's warp (PCA sends
  // restores in RAU's order, so the head's warp is the one to launch; a
  // pick by entry order could hold a paired warp that can never launch
  // while the head's waits behind it; RI's reading of the Launch
  // condition). One migration a warp: at most one entry matches.
  // The picks see the entries a kill drops a cycle late; a launch needs its
  // map entry still valid, so a dropped pick only costs a cycle.
  logic [Q-1:0] dk_mi_cr02h, dk_ci_cr02h, rk_mi_cr02h, rk_ci_cr02h;

  // Launch possible, from flops: the engine is free and the pick holds.
  wire dlp_cr02h = |(dk_mi_cr02h & mq_v_cr02h) & ~dm_busy_cr02h;
  wire rlp_cr02h = |(rk_mi_cr02h & mq_v_cr02h) & ~rs_busy_cr02h & hd_v_cr02h & ~hd_dead_cr02h;

  // The picked maps' fields (a 4:1 one-hot AND-OR on flops).
  logic [WW-1:0]    dk_w_cr02h, rk_w_cr02h;
  logic [NG*WR-1:0] dk_g_cr02h, rk_g_cr02h;
  logic [NP*WP-1:0] dk_p_cr02h, rk_p_cr02h;
  always_comb begin
    dk_w_cr02h = '0; dk_g_cr02h = '0; dk_p_cr02h = '0;
    rk_w_cr02h = '0; rk_g_cr02h = '0; rk_p_cr02h = '0;
    for (int i = 0; i < Q; i++) begin
      dk_w_cr02h |= {WW{dk_mi_cr02h[i]}} & mq_w_cr02h[i];
      dk_g_cr02h |= {(NG*WR){dk_mi_cr02h[i]}} & mq_g_cr02h[i];
      dk_p_cr02h |= {(NP*WP){dk_mi_cr02h[i]}} & mq_p_cr02h[i];
      rk_w_cr02h |= {WW{rk_mi_cr02h[i]}} & mq_w_cr02h[i];
      rk_g_cr02h |= {(NG*WR){rk_mi_cr02h[i]}} & mq_g_cr02h[i];
      rk_p_cr02h |= {(NP*WP){rk_mi_cr02h[i]}} & mq_p_cr02h[i];
    end
  end

  // Launch, at the edge ending a cycle whose pick holds, whose engine is
  // free and whose warp this cycle's kill does not name.
  wire dl_cr02h = dlp_cr02h & ~killed(dk_w_cr02h, kact_cr02h, kmn_cr02h);
  wire rl_cr02h = rlp_cr02h & ~killed(hd_w_cr02h, kact_cr02h, kmn_cr02h);

  // Entries a kill drops this cycle, and every entry leaving: a launch the
  // kill blocks drops its entries as a kill's, so the possible launches
  // name them (shallower than the launches).
  logic [Q-1:0] mq_kd_cr02h, cq_kd_cr02h, mq_clr_cr02h, cq_clr_cr02h;
  always_comb begin
    for (int i = 0; i < Q; i++) begin
      mq_kd_cr02h[i] = mq_v_cr02h[i] & killed(mq_w_cr02h[i], kact_cr02h, kmn_cr02h);
      cq_kd_cr02h[i] = cq_v_cr02h[i] & killed(cq_w_cr02h[i], kact_cr02h, kmn_cr02h);
    end
    mq_clr_cr02h = (dlp_cr02h ? dk_mi_cr02h : '0) | (rlp_cr02h ? rk_mi_cr02h : '0) | mq_kd_cr02h;
    cq_clr_cr02h = (dlp_cr02h ? dk_ci_cr02h : '0) | (rlp_cr02h ? rk_ci_cr02h : '0) | cq_kd_cr02h;
  end
  wire [Q-1:0] mq_vn_cr02h = (mq_v_cr02h & ~mq_clr_cr02h) | mq_land_cr01h;
  wire [Q-1:0] cq_vn_cr02h = (cq_v_cr02h & ~cq_clr_cr02h) | cq_land_cr01h;

  // Valid and free flops, under a land, a possible launch or a kill.
  wire qv_en_cr01h = mrxv_cr01h | crxv_cr01h | dlp_cr02h | rlp_cr02h | kact_cr02h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      mq_v_cr02h    <= '0;
      cq_v_cr02h    <= '0;
      mq_free_cr02h <= Q'(1);
      cq_free_cr02h <= Q'(1);
    end else if (qv_en_cr01h) begin
      mq_v_cr02h    <= mq_vn_cr02h;
      cq_v_cr02h    <= cq_vn_cr02h;
      mq_free_cr02h <= lowest(~mq_vn_cr02h);
      cq_free_cr02h <= lowest(~cq_vn_cr02h);
    end
  end
  // Payloads: each entry under its land (the flopped valid and free bit).
  for (genvar i = 0; i < Q; i++) begin : g_q
    wire mq_en_cr01h = mrxv_cr01h & mq_free_cr02h[i];
    wire cq_en_cr01h = crxv_cr01h & cq_free_cr02h[i];
    always_ff @(posedge rcu_core_clk) begin
      if (mq_en_cr01h) begin
        mq_w_cr02h[i] <= mw_cr01h;
        mq_d_cr02h[i] <= md_cr01h;
        mq_g_cr02h[i] <= mg_cr01h;
        mq_p_cr02h[i] <= mp_cr01h;
      end
      if (cq_en_cr01h) begin
        cq_w_cr02h[i] <= cw_cr01h;
        cq_d_cr02h[i] <= cd_cr01h;
      end
    end
  end

  // The next picks, from the entries that stay but for the possible
  // launches (a kill's drops are seen a cycle on, above).
  logic [Q-1:0] dkn_mi_cr02h, dkn_ci_cr02h, rkn_mi_cr02h, rkn_ci_cr02h;
  always_comb begin
    logic [Q-1:0] msa, csa, hit;
    logic [Q-1:0] mat [Q];
    msa = mq_v_cr02h & ~(dlp_cr02h ? dk_mi_cr02h : '0) & ~(rlp_cr02h ? rk_mi_cr02h : '0);
    csa = cq_v_cr02h & ~(dlp_cr02h ? dk_ci_cr02h : '0) & ~(rlp_cr02h ? rk_ci_cr02h : '0);
    for (int i = 0; i < Q; i++)
      for (int j = 0; j < Q; j++)
        mat[i][j] = msa[i] & csa[j] & (mq_w_cr02h[i] == cq_w_cr02h[j]) & (mq_d_cr02h[i] == cq_d_cr02h[j]);
    for (int i = 0; i < Q; i++) begin
      hit[i] = |mat[i] & ~mq_d_cr02h[i];
      rkn_mi_cr02h[i] = |mat[i] & mq_d_cr02h[i] &
                        ((hn_hd_cr02h & (mq_w_cr02h[i] == hd_w_cr02h)) |
                         (hn_pw_cr01h & (mq_w_cr02h[i] == pw_cr01h)));
      // That warp's one restore command (read only beside its map).
      rkn_ci_cr02h[i] = csa[i] & cq_d_cr02h[i] &
                        ((hn_hd_cr02h & (cq_w_cr02h[i] == hd_w_cr02h)) |
                         (hn_pw_cr01h & (cq_w_cr02h[i] == pw_cr01h)));
    end
    dkn_mi_cr02h = lowest(hit);
    dkn_ci_cr02h = '0;
    for (int i = 0; i < Q; i++) dkn_ci_cr02h |= {Q{dkn_mi_cr02h[i]}} & lowest(mat[i]);
  end
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      dk_mi_cr02h <= '0;
      dk_ci_cr02h <= '0;
      rk_mi_cr02h <= '0;
      rk_ci_cr02h <= '0;
    end else begin
      dk_mi_cr02h <= dkn_mi_cr02h;
      dk_ci_cr02h <= dkn_ci_cr02h;
      rk_mi_cr02h <= rkn_mi_cr02h;
      rk_ci_cr02h <= rkn_ci_cr02h;
    end
  end

  // Credits: pending counts, one out a cycle per channel (RI-6 (a)), one
  // per entry leaving: a possible launch's (a kill-blocked one's entries
  // are its kill's), now; a kill's other drops, counted and added a cycle
  // on. The credit outputs have their own flops (an output's register is
  // held to its budget on every path it starts): the next count nonzero.
  localparam int WK = $clog2(Q + 1);
  logic [WN-1:0] mcn_cr02h, ccn_cr02h;
  logic [WK-1:0] mkc_cr03h, ckc_cr03h;   // a kill's other drops, counted
  logic          mcr_o_cr02h, ccr_o_cr02h;
  wire [Q-1:0] mkx_cr02h = mq_kd_cr02h & ~(dlp_cr02h ? dk_mi_cr02h : '0) & ~(rlp_cr02h ? rk_mi_cr02h : '0);
  wire [Q-1:0] ckx_cr02h = cq_kd_cr02h & ~(dlp_cr02h ? dk_ci_cr02h : '0) & ~(rlp_cr02h ? rk_ci_cr02h : '0);
  wire [WN-1:0] madd_cr02h = WN'(dlp_cr02h) + WN'(rlp_cr02h) + WN'(mkc_cr03h);
  wire [WN-1:0] cadd_cr02h = WN'(dlp_cr02h) + WN'(rlp_cr02h) + WN'(ckc_cr03h);
  wire mcn_en_cr02h = (mcn_cr02h != '0) | dlp_cr02h | rlp_cr02h | (mkc_cr03h != '0);
  wire ccn_en_cr02h = (ccn_cr02h != '0) | dlp_cr02h | rlp_cr02h | (ckc_cr03h != '0);
  wire kc_en_cr02h = kact_cr02h | (mkc_cr03h != '0) | (ckc_cr03h != '0);
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      mcn_cr02h   <= '0;
      ccn_cr02h   <= '0;
      mkc_cr03h   <= '0;
      ckc_cr03h   <= '0;
      mcr_o_cr02h <= 1'b0;
      ccr_o_cr02h <= 1'b0;
    end else begin
      if (mcn_en_cr02h) mcn_cr02h <= mcn_cr02h + madd_cr02h - WN'(mcn_cr02h != '0);
      if (ccn_en_cr02h) ccn_cr02h <= ccn_cr02h + cadd_cr02h - WN'(ccn_cr02h != '0);
      if (kc_en_cr02h) begin
        mkc_cr03h <= WK'($countones(mkx_cr02h));
        ckc_cr03h <= WK'($countones(ckx_cr02h));
      end
      // The next count is nonzero: two or more now, or any added.
      mcr_o_cr02h <= (mcn_cr02h > WN'(1)) | dlp_cr02h | rlp_cr02h | (mkc_cr03h != '0);
      ccr_o_cr02h <= (ccn_cr02h > WN'(1)) | dlp_cr02h | rlp_cr02h | (ckc_cr03h != '0);
    end
  end
  assign mcr_cr02h = mcr_o_cr02h;
  assign ccr_cr02h = ccr_o_cr02h;

  // ---- Demotion engine ---------------------------------------------------
  logic [WW-1:0]    dm_w_cr02h;
  logic [NG*WR-1:0] dm_g_cr02h;
  logic [NP*WP-1:0] dm_p_cr02h;
  logic [NR:0]      dm_oh_cr02h;   // the rows sent, one-hot: bit r, row r next (NR: all sent)
  logic [1:0]       dm_wc_cr02h;
  logic [WC-1:0]    dm_cr_cr02h;
  (* keep *) logic  dm_v_cr03h;                 // dm_vo_cr03h is its copy for ov
  (* keep *) logic  dm_vo_cr03h, dm_wk_cr03h, dm_r2_cr03h;   // ov's own flop; the wake's (a block output); R2's lead (the slices)
  logic             dv_o_cr01h;                 // the D leads' own flop
  logic [WW-1:0]    dm_pw_cr04h;
  logic [WMR-1:0]   dm_prow_cr04h;
  logic [WD-1:0]    dm_pd_cr04h;

  // The row decided now, one-hot: past the row in A+1.
  wire [NR:0] dm_noh_cr02h = dm_v_cr03h ? (dm_oh_cr02h << 1) : dm_oh_cr02h;
  wire [WC:0] dm_ncr_cr02h = (WC+1)'(dm_cr_cr02h) - (WC+1)'(dm_v_cr03h) + (WC+1)'(ocrq_cr02h);
  wire dm_p16_cr02h = dm_noh_cr02h[NG];
  wire dm_want_cr02h = dm_busy_cr02h & (dm_wc_cr02h == 2'd0) & ~dm_noh_cr02h[NR] &
                       (dm_ncr_cr02h != '0) & (dm_p16_cr02h | ~r2b_cr02h);
  wire dm_kill_cr02h = killed(dm_w_cr02h, kact_cr02h, kmn_cr02h);
  wire dm_r16_cr03h = dm_oh_cr02h[NG];                            // the row in A+1 is 16
  wire dm_end_cr03h = dm_v_cr03h & dm_r16_cr03h;                  // row 16 goes out
  wire dm_busyn_cr02h = dl_cr02h | (dm_busy_cr02h & ~dm_end_cr03h & ~dm_kill_cr02h);

  // Every cycle: the busy bit, the sender's valid, its row-16 flag, the wake.
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      dm_busy_cr02h <= 1'b0;
      dm_v_cr03h    <= 1'b0;
      dm_vo_cr03h   <= 1'b0;
      dm_wk_cr03h   <= 1'b0;
      dm_r2_cr03h   <= 1'b0;
      dv_o_cr01h    <= 1'b0;
    end else begin
      dm_busy_cr02h <= dm_busyn_cr02h;
      dm_v_cr03h    <= dm_want_cr02h & ~ost_cr02h;
      dm_vo_cr03h   <= dm_want_cr02h & ~ost_cr02h;
      dm_wk_cr03h   <= dm_busyn_cr02h;
      dm_r2_cr03h   <= dm_busyn_cr02h;
      // The D leads from row 14 on (a cycle early at most: a lead only
      // readies the read), while the engine stays busy.
      dv_o_cr01h    <= dm_busy_cr02h & ~dm_end_cr03h & ~dm_kill_cr02h & (|dm_noh_cr02h[NR:NG-2]);
    end
  end
  // The map, whenever the engine is free and a pick holds (the launch but
  // for a kill of its warp, which leaves the engine free: no harm).
  wire dm_ld_en_cr02h = dlp_cr02h;
  always_ff @(posedge rcu_core_clk) begin
    if (dm_ld_en_cr02h) begin
      dm_w_cr02h <= dk_w_cr02h;
      dm_g_cr02h <= dk_g_cr02h;
      dm_p_cr02h <= dk_p_cr02h;
    end
  end
  // Row, wake counter and credits.
  wire dm_row_en_cr02h = dm_v_cr03h | dlp_cr02h;
  wire dm_wc_en_cr02h = dl_cr02h | (dm_wc_cr02h != 2'd0);
  wire dm_cr_en_cr02h = dm_v_cr03h | ocrq_cr02h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      dm_oh_cr02h <= (NR+1)'(1);
      dm_wc_cr02h <= '0;
      dm_cr_cr02h <= WC'(CD);
    end else begin
      if (dm_row_en_cr02h) dm_oh_cr02h <= dm_busy_cr02h ? {dm_oh_cr02h[NR-1:0], 1'b0} : (NR+1)'(1);
      if (dm_wc_en_cr02h) dm_wc_cr02h <= dl_cr02h ? 2'(WL - 1) : dm_wc_cr02h - 2'd1;
      if (dm_cr_en_cr02h) dm_cr_cr02h <= WC'(dm_ncr_cr02h);
    end
  end
  // The payload, under the sender's valid: the row read in A+1, its number
  // the one-hot's.
  logic [WMR-1:0] dm_rown_cr03h;
  always_comb begin
    dm_rown_cr03h = '0;
    for (int r = 0; r < NR + 1; r++) dm_rown_cr03h |= dm_oh_cr02h[r] ? WMR'(r) : '0;
  end
  wire dm_pay_en_cr03h = dm_v_cr03h;
  always_ff @(posedge rcu_core_clk) begin
    if (dm_pay_en_cr03h) begin
      dm_pw_cr04h   <= dm_w_cr02h;
      dm_prow_cr04h <= dm_rown_cr03h;
      dm_pd_cr04h   <= dm_r16_cr03h ? {{(WD - NP * 32){1'b0}}, dq_cr03h} : rd2_cr03h;
    end
  end
  assign ov_cr03h   = dm_vo_cr03h;
  assign ow_cr04h   = dm_pw_cr04h;
  assign orow_cr04h = dm_prow_cr04h;
  assign odat_cr04h = dm_pd_cr04h;
  assign owk_cr03h  = dm_wk_cr03h;

  // Read requests. R2: the next row's map entry (a 16:1 one-hot AND-OR on
  // flops; the zero register past row 15), the lead while busy. D0-D3: the
  // predicate map, the lead from row 15 on (its flop above).
  always_comb begin
    r2row_cr02h = (dm_noh_cr02h[NG] | dm_noh_cr02h[NR]) ? ZROW : '0;
    for (int a = 0; a < NG; a++) r2row_cr02h |= {WR{dm_noh_cr02h[a]}} & dm_g_cr02h[a*WR +: WR];
  end
  assign r2v_cr01h  = dm_r2_cr03h;   // dm_busy, R2's own copy: the wake's drives a block output (NGD-7 at assembly)
  assign dv_cr01h   = {NP{dv_o_cr01h}};
  assign drow_cr02h = dm_p_cr02h;

  // ---- Restore engine ----------------------------------------------------
  logic [WW-1:0]    rs_w_cr02h;
  logic [NG*WR-1:0] rs_g_cr02h;
  logic [NP*WP-1:0] rs_p_cr02h;
  logic             rs_l16_cr03h, rs_l16_cr04h;   // rs_last_a1, and a cycle on
  logic [F-1:0]     rs_sel_cr03h, rs_sel_cr04h;
  logic             rs_cr_cr04h;
  logic             rsc_o_cr02h, e16_o_cr02h;      // rs_can and e_16, for the outputs alone
  logic             rwsel_o_cr03h;                 // rwsel's own flop

  // The entry decided now: the head, past a write already in A+1.
  wire [F-1:0] e_cr02h = rs_v_cr03h ? rot(hd_cr02h) : hd_cr02h;
  wire e_v_cr02h = |(e_cr02h & f_v_cr02h);
  wire e_dead_cr02h = |(e_cr02h & f_dead_cr02h);
  logic e_16_cr02h;
  always_comb begin
    e_16_cr02h = 1'b0;
    for (int i = 0; i < F; i++) e_16_cr02h |= e_cr02h[i] & f_r16_cr02h[i];
  end
  // From flops alone: a live row is at e and nothing blocks it but RW. The
  // row is the engine's warp's (PCA sends a restore's rows contiguously,
  // RA-28 (b); mig_rs_warp below checks it).
  wire rs_can_cr02h = rs_busy_cr02h & e_v_cr02h & ~e_dead_cr02h & ~rs_l16_cr03h & ~rs_l16_cr04h;
  wire rs_want_cr02h = rs_can_cr02h & (e_16_cr02h | ~rwb_cr02h);
  wire rs_end_cr04h = rs_v_cr04h & rs_l16_cr04h;          // row 16 written
  wire rs_kill_cr02h = killed(rs_w_cr02h, kact_cr02h, kmn_cr02h);
  wire rs_busyn_cr02h = rl_cr02h | (rs_busy_cr02h & ~rs_end_cr04h & ~rs_kill_cr02h);

  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      rs_busy_cr02h <= 1'b0;
      rs_v_cr03h    <= 1'b0;
      rs_v_cr04h    <= 1'b0;
      rs_l16_cr03h  <= 1'b0;
      rs_l16_cr04h  <= 1'b0;
      rs_sel_cr03h  <= '0;
      rs_sel_cr04h  <= '0;
      rs_cr_cr04h   <= 1'b0;
      rwsel_o_cr03h <= 1'b0;
    end else begin
      rs_busy_cr02h <= rs_busyn_cr02h;
      rs_v_cr03h    <= rs_want_cr02h;
      rs_v_cr04h    <= rs_v_cr03h;
      rs_l16_cr03h  <= rs_want_cr02h & e_16_cr02h;
      rs_l16_cr04h  <= rs_l16_cr03h;
      rs_sel_cr03h  <= e_cr02h;
      rs_sel_cr04h  <= rs_sel_cr03h;
      rs_cr_cr04h   <= rs_v_cr04h | dpop_cr02h;
      rwsel_o_cr03h <= rs_want_cr02h & ~e_16_cr02h;
    end
  end
  // The map, whenever the engine is free and the head's pick holds.
  wire rs_ld_en_cr02h = rlp_cr02h;
  always_ff @(posedge rcu_core_clk) begin
    if (rs_ld_en_cr02h) begin
      rs_w_cr02h <= rk_w_cr02h;
      rs_g_cr02h <= rk_g_cr02h;
      rs_p_cr02h <= rk_p_cr02h;
    end
  end

  // The FIFO: land at the tail under the flopped valid, pop at the write's
  // A+2 or a dead head, head advanced in the write's A+1. A row of a warp
  // in mig_kmask goes dead a cycle after it lands (or at K+1); one decided
  // or in its write writes all the same (a dead row pops only at the head,
  // never beside a write). The write's pop is the entry behind the head:
  // the head moved past it in A+1.
  wire tl_en_cr01h = prxv_cr01h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      hd_cr02h <= F'(1);
      tl_cr02h <= F'(1);
    end else begin
      if (hd_en_cr02h) hd_cr02h <= rot(hd_cr02h);
      if (tl_en_cr01h) tl_cr02h <= rot(tl_cr02h);
    end
  end
  wire [NR-1:0] prow1h_cr01h = NR'(1) << prow_cr01h;
  for (genvar i = 0; i < F; i++) begin : g_f
    wire land_cr01h = prxv_cr01h & tl_cr02h[i];
    wire pop_cr02h = (rs_v_cr04h & hd_cr02h[(i + 1) % F]) | (dpop_cr02h & hd_cr02h[i]);
    wire kd_cr02h = f_v_cr02h[i] & ~f_dead_cr02h[i] & kmask_cr02h[f_w_cr02h[i]];
    assign fvn_cr02h[i] = land_cr01h | (f_v_cr02h[i] & ~pop_cr02h);
    assign fdn_cr02h[i] = ~land_cr01h & (f_dead_cr02h[i] | kd_cr02h);
    assign f16n_cr02h[i] = land_cr01h ? prow1h_cr01h[NG] : f_r16_cr02h[i];
    wire fv_en_cr02h = land_cr01h | pop_cr02h | kd_cr02h;
    always_ff @(posedge rcu_core_clk) begin
      if (rst_r01h) begin
        f_v_cr02h[i]    <= 1'b0;
        f_dead_cr02h[i] <= 1'b0;
      end else if (fv_en_cr02h) begin
        f_v_cr02h[i]    <= fvn_cr02h[i];
        f_dead_cr02h[i] <= fdn_cr02h[i];
      end
    end
    wire f_en_cr01h = land_cr01h;
    always_ff @(posedge rcu_core_clk) begin
      if (f_en_cr01h) begin
        f_w_cr02h[i]   <= pw_cr01h;
        f_r16_cr02h[i] <= prow1h_cr01h[NG];
        f_rg_cr02h[i]  <= prow1h_cr01h[NG-1:0];
        f_dat_cr02h[i] <= pdat_cr01h;
      end
    end
  end

  // The outputs' own flops: rs_can and e_16 a cycle ahead, from the next
  // state (a register that drives an output is held to its budget on every
  // path it starts, so these feed nothing else but RW's lead).
  wire [F-1:0] hdn_cr02h = hd_en_cr02h ? rot(hd_cr02h) : hd_cr02h;
  wire [F-1:0] en_cr02h = rs_want_cr02h ? rot(hdn_cr02h) : hdn_cr02h;
  wire rscn_cr02h = rs_busyn_cr02h & |(en_cr02h & fvn_cr02h) & ~|(en_cr02h & fdn_cr02h) &
                    ~(rs_want_cr02h & e_16_cr02h) & ~rs_l16_cr03h;
  wire e16n_cr02h = |(en_cr02h & f16n_cr02h);
  `CCV_ASSERT(mig_pop_sel, !(rs_v_cr04h && rs_sel_cr04h != rot(rot(rot(hd_cr02h)))))
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      rsc_o_cr02h <= 1'b0;
      e16_o_cr02h <= 1'b0;
    end else begin
      rsc_o_cr02h <= rscn_cr02h;
      e16_o_cr02h <= e16n_cr02h;
    end
  end

  // The write: RW (a GPR row) or PG0-PG3 (row 16), the entry's data in A+2.
  // RW's row in A+1: the decided entry's mig_row (one-hot) on the map.
  logic [WD-1:0] wdat_cr04h;
  logic [WR-1:0] rwrown_cr03h;
  always_comb begin
    logic [NG-1:0] rg;
    wdat_cr04h = '0;
    for (int i = 0; i < F; i++) wdat_cr04h |= {WD{rs_sel_cr04h[i]}} & f_dat_cr02h[i];
    rg = '0;
    for (int i = 0; i < F; i++) rg |= {NG{rs_sel_cr03h[i]}} & f_rg_cr02h[i];
    rwrown_cr03h = '0;
    for (int a = 0; a < NG; a++) rwrown_cr03h |= {WR{rg[a]}} & rs_g_cr02h[a*WR +: WR];
  end
  assign rwv_cr02h   = rsc_o_cr02h & ~e16_o_cr02h;
  assign rwsel_cr03h = rwsel_o_cr03h;
  assign rwrow_cr03h = rwrown_cr03h;
  assign rwdat_cr04h = wdat_cr04h;
  assign gv_cr02h    = rsc_o_cr02h & e16_o_cr02h;
  assign grow_cr03h  = rs_p_cr02h;
  assign gdat_cr04h  = wdat_cr04h[NP*32-1:0];
  assign pcr_cr04h   = rs_cr_cr04h;

  // ---- Quiesce and busy --------------------------------------------------
  // busy is flopped from this cycle's state and the inbound valids: a cycle
  // late at the end only (conservative for rcu_kill's idle).
  logic quiet_q_cr02h, busy_q_cr02h;
  logic hold_k_cr01h;
  always_comb begin
    hold_k_cr01h = dm_busy_cr02h & kmask_cr02h[dm_w_cr02h];
    for (int i = 0; i < F; i++)
      hold_k_cr01h |= f_v_cr02h[i] & (f_dead_cr02h[i] | kmask_cr02h[f_w_cr02h[i]]);
    for (int i = 0; i < Q; i++)
      hold_k_cr01h |= (mq_v_cr02h[i] & kmask_cr02h[mq_w_cr02h[i]]) | (cq_v_cr02h[i] & kmask_cr02h[cq_w_cr02h[i]]);
  end
  wire busyn_cr01h = dm_busy_cr02h | rs_busy_cr02h | |mq_v_cr02h | |cq_v_cr02h | |f_v_cr02h |
                     (mcn_cr02h != '0) | (ccn_cr02h != '0) | (mkc_cr03h != '0) | (ckc_cr03h != '0) | dm_v_cr03h | rs_v_cr03h | rs_v_cr04h |
                     rs_cr_cr04h | mrxv_cr01h | crxv_cr01h | prxv_cr01h | kvq_cr01h | kact_cr02h |
                     mv_cr00h | cv_cr00h | pv_cr00h | kv_cr00h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      quiet_q_cr02h <= 1'b1;
      busy_q_cr02h  <= 1'b0;
    end else begin
      quiet_q_cr02h <= ~hold_k_cr01h;
      busy_q_cr02h  <= busyn_cr01h;
    end
  end
  assign quiet_cr02h = quiet_q_cr02h;
  assign busy_cr02h  = busy_q_cr02h;

  // ---- Checks (Migration tab, Flops and checks) --------------------------
  // Credits guarantee room: no land into a full queue or FIFO.
  `CCV_ASSERT(mig_map_room, !(mrxv_cr01h && mq_free_cr02h == '0))
  `CCV_ASSERT(mig_cmd_room, !(crxv_cr01h && cq_free_cr02h == '0))
  `CCV_ASSERT(mig_fifo_overrun, !(prxv_cr01h && |(tl_cr02h & f_v_cr02h)))
  `CCV_ASSERT(mig_dm_cred, dm_cr_cr02h <= WC'(CD))
  // A map or command entry leaves only by a launch or the kill event (K+1),
  // never by kmask's level: a relaunched warp's command can land before its
  // map, or its map in the two cycles before kmask clears (RA, re:RI-19).
  logic q_drop_bad_cr02h;
  always_comb begin
    q_drop_bad_cr02h = 1'b0;
    for (int i = 0; i < Q; i++) begin
      q_drop_bad_cr02h |= qv_en_cr01h & mq_v_cr02h[i] & ~mq_vn_cr02h[i] &
                          ~((dlp_cr02h & dk_mi_cr02h[i]) | (rlp_cr02h & rk_mi_cr02h[i])) &
                          ~killed(mq_w_cr02h[i], kact_cr02h, kmn_cr02h);
      q_drop_bad_cr02h |= qv_en_cr01h & cq_v_cr02h[i] & ~cq_vn_cr02h[i] &
                          ~((dlp_cr02h & dk_ci_cr02h[i]) | (rlp_cr02h & rk_ci_cr02h[i])) &
                          ~killed(cq_w_cr02h[i], kact_cr02h, kmn_cr02h);
    end
  end
  `CCV_ASSERT(mig_q_drop, !q_drop_bad_cr02h)
  // Rows go out 0..16, then the engine is done.
  `CCV_ASSERT(mig_dm_row, !(dm_v_cr03h && dm_oh_cr02h[NR]))
  // PCA sends a restore's rows contiguously (RA-28 (b)): a live row at e
  // while the engine is busy is the warp's own.
  logic [WW-1:0] e_w_cr02h;
  always_comb begin
    e_w_cr02h = '0;
    for (int i = 0; i < F; i++) e_w_cr02h |= {WW{e_cr02h[i]}} & f_w_cr02h[i];
  end
  `CCV_ASSERT(mig_rs_warp, !(rs_can_cr02h && e_w_cr02h != rs_w_cr02h))
  // The outputs' flops agree with what they stand for.
  `CCV_ASSERT(mig_rs_oflops, rsc_o_cr02h == rs_can_cr02h && (!rs_can_cr02h || e16_o_cr02h == e_16_cr02h))
  // Row 16 is the last of a restore: nothing of the warp follows it.
  `CCV_ASSERT(mig_rs_last, !(rs_l16_cr04h && rs_v_cr04h && rs_v_cr03h))
  // A restore map names no zero register (A-64) and no row twice (TI-25).
  logic map_bad_cr01h;
  always_comb begin
    map_bad_cr01h = 1'b0;
    for (int a = 0; a < NG; a++) begin
      map_bad_cr01h |= mg_cr01h[a*WR +: WR] == ZROW;
      for (int b = 0; b < a; b++) map_bad_cr01h |= mg_cr01h[a*WR +: WR] == mg_cr01h[b*WR +: WR];
    end
  end
  `CCV_ASSERT(mig_restore_map, !(mrxv_cr01h && md_cr01h && map_bad_cr01h))

endmodule
`undef CCV_CLK
`undef CCV_RST
