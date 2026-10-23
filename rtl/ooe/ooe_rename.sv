//===-- ooe_rename.sv - OOE rename: the go, Rename 1 and the free lists -----===//
//
// Spec: the design doc's Rename's go decision and Stage boundaries (OA-21,
//       OA-22; Rename 1, OI-67, OOE doc rev 285); docs/ooe-rtl-plan.md,
//       ooe_rename, slices 4, 5 and 7 (this is 7's first step).
//
// Rename's go and its first stage, assembled. ooe_go takes, from decq's
// output register and rename's registered state, each warp's prefix and the
// lanes, and counts every candidate's writers before it in lane order. In
// the same cycle (Rename 1: the model's rename_stages 3) one ooe_headrd per
// slot reads that slot's heads through the pending group, ooe_ren1 picks
// the lanes, each with its name index and each read's in-group writer as a
// lane, and the Rename 1 register captures them beside the free lists'
// heads. The free lists are this module's (OI-67 (3)): their request is the
// go's count of taken writers, which reads decq's payload, so it cannot
// leave rename without a through path. ooe_ren1n binds the names from the
// Rename 1 register for what reads it next: the pending group (ooe_rat's
// write ports and the heads' reads) and Rename 2.
//
// Not yet here (slice 7's next steps): rename's pool and floor registers
// and its counters (ooe_rencred), so the go's pool, floors and ROB terms
// are ports; ooe_rendep and ooe_prodmap, so Rename 2's fields leave as
// outputs; restore-allocate's writes and atomics (asserted absent); the
// narrow allocator (slice 6): names are whole rows.
//
// Clock gating: the Rename 1 register's payload is clocked while some slot
// had a head (ooe_go's registered sel, a superset of a take), its valid bits
// every cycle. The reference is the model: test/ooe/rename_tb.cpp.
//
// Reset line: the go's and the free lists' own; the Rename 1 register's
// valid bits clear.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h

module ooe_rename #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int R  = 4,                  // rename width (CCV_ISSUE_WIDTH)
  parameter int PA = 7,                  // admission bits a head
  parameter int LU = 5,                  // an unmet floor's width
  parameter int LB = 6,                  // a ROB run's width
  parameter int LT = 3,                  // a cycle's retirements' width
  parameter int C  = 4,                  // checkpoints per slot (CCV_P_BR_CKPTS)
  parameter int NG = 192,                // GPR rows (CCV_P_PHYS_REGS)
  parameter int NP = 48,                 // predicate names (CCV_P_PRED_REGS)
  parameter int GW = 10,                 // GPR name: row and position
  parameter int PW = 6,                  // predicate name (CCV_P_W_PHYS_PRED)
  parameter int FB = 8,                  // a free list's candidate buffer
  parameter int FK = 4,                  // its refill banks
  localparam int H  = 2 * R - 1,
  localparam int NC = S * R,
  localparam int GR = $clog2(NG),
  localparam int LS = (S > 1) ? $clog2(S) : 1,
  localparam int LC = (C > 1) ? $clog2(C) : 1,
  localparam int MW = 16 * GW + 4 * PW,
  localparam int XM = 5 * R,
  localparam int LX = $clog2(XM + 1)
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  // decq's output register: each slot's heads, their admission bits, and
  // the first R's rename fields (bit h * S + s: slot s's head h).
  input  logic [S*H-1:0]    hv_cq01h,
  input  logic [S*H*PA-1:0] ha_cq01h,
  input  logic [NC*3*4-1:0] c_src_cq01h,
  input  logic [NC*4-1:0]   c_dst_cq01h,
  input  logic [NC*2-1:0]   c_pguard_cq01h,
  input  logic [NC*2-1:0]   c_pdst_cq01h,
  input  logic [NC*2*2-1:0] c_pq_cq01h,
  input  logic [NC-1:0]     c_br_cq01h,
  input  logic [NC*LC-1:0]  c_ckpt_cq01h,
  // The go's other inputs (rename's registers and the ROB's, until slice
  // 7 brings them in), and its leads.
  input  logic [4*LX-1:0]   px_cq01h,
  input  logic [S*LU-1:0]   unmet_g_cq01h,
  input  logic [S*LU-1:0]   unmet_p_cq01h,
  input  logic [S*LU-1:0]   room_g_cq01h,   // each slot's room to its ceiling (OI-73 (3))
  input  logic [S*LU-1:0]   room_p_cq01h,
  input  logic [S*LB-1:0]   run_cq01h,
  input  logic [S-1:0]      reach_cq01h,
  input  logic [S*LT-1:0]   ret_cq01h,
  input  logic [S-1:0]      hold_l_cq00h,
  input  logic              rbusy_l_cq00h,
  input  logic [S-1:0]      sq_l_cq00h,
  input  logic [S-1:0]      dq_ev_cq01h,
  input  logic [S-1:0]      rob_en_cq01h,
  input  logic              pool_en_cq01h,
  // ooe_rat's speculative maps.
  input  logic [S*MW-1:0]   rat_cq02h,
  // The free lists' frees (the retire stage's register) and their leads.
  input  logic              gfree_l_cq00h,
  input  logic [NG-1:0]     gfree_cq01h,
  input  logic              pfree_l_cq00h,
  input  logic [NP-1:0]     pfree_cq01h,
  // The take, to decq (deq_t, deq_sel) and ooe_rat (tk).
  output logic [S*R-1:0]    take_cq02h,
  output logic [S-1:0]      sel_cq02h,
  // The Rename 1 register, as ooe_rat's write ports and Rename 2 read it,
  // the names bound.
  output logic [R-1:0]      q_v_cq03h,
  output logic [R*LS-1:0]   q_slot_cq03h,
  output logic [R*4-1:0]    q_dst_cq03h,
  output logic [R-1:0]      q_gwe_cq03h,
  output logic [R*GW-1:0]   q_gname_cq03h,
  output logic [R*2-1:0]    q_pdst_cq03h,
  output logic [R-1:0]      q_pwe_cq03h,
  output logic [R*PW-1:0]   q_pname_cq03h,
  output logic [R-1:0]      q_br_cq03h,
  output logic [R*LC-1:0]   q_ckpt_cq03h,
  output logic [R*4*GW-1:0] q_g_cq03h,      // src0..2, the old destination
  output logic [R*4*PW-1:0] q_p_cq03h       // guard, old destination, q0, q1
);

  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) rst_r01h <= ooe_rst_r00h;

  // -- The go ---------------------------------------------------------------
  logic [R-1:0]      lane_v_cq02h;
  logic [R*NC-1:0]   lane_c_cq02h;
  logic [NC*2*R-1:0] wb_cq02h;
  logic [2*R-1:0]    wt_cq02h;
  ooe_go #(.S(S), .R(R), .PA(PA), .LU(LU), .LB(LB), .LT(LT)) u_go (
    .ooe_core_clk, .ooe_rst_r00h, .hv_cq01h, .ha_cq01h, .px_cq01h, .unmet_g_cq01h, .unmet_p_cq01h, .room_g_cq01h, .room_p_cq01h, .run_cq01h,
    .reach_cq01h, .ret_cq01h, .hold_l_cq00h, .rbusy_l_cq00h, .sq_l_cq00h, .dq_ev_cq01h, .rob_en_cq01h,
    .pool_en_cq01h, .take_cq02h, .sel_cq02h, .lane_v_cq02h, .lane_c_cq02h, .wb_cq02h, .wt_cq02h);

  // -- The free lists ---------------------------------------------------------
  logic [R-1:0]    galv_cq02h, palv_cq02h;
  logic [R*GR-1:0] galloc_cq02h;
  logic [R*PW-1:0] palloc_cq02h;
  logic [$clog2(FB+1)-1:0] gavail_cq02h, pavail_cq02h;   // the counts rename sees: the go's pool, from slice 7's counters
  ooe_freelist #(.N(NG), .A(R), .B(FB), .K(FK)) u_gfree (
    .ooe_core_clk, .ooe_rst_r00h, .alloc_req_cq01h(wt_cq02h[0 +: R]), .free_l_cq00h(gfree_l_cq00h),
    .free_mask_cq01h(gfree_cq01h), .alloc_v_cq02h(galv_cq02h), .alloc_idx_cq02h(galloc_cq02h), .avail_cq02h(gavail_cq02h));
  ooe_freelist #(.N(NP), .A(R), .B(FB), .K(FK)) u_pfree (
    .ooe_core_clk, .ooe_rst_r00h, .alloc_req_cq01h(wt_cq02h[R +: R]), .free_l_cq00h(pfree_l_cq00h),
    .free_mask_cq01h(pfree_cq01h), .alloc_v_cq02h(palv_cq02h), .alloc_idx_cq02h(palloc_cq02h), .avail_cq02h(pavail_cq02h));

  // -- Rename 1: every candidate's reads, then the lanes -----------------------
  // A head's write bits are its admission bits (3 GPR, 4 predicate), as the
  // go counts them.
  logic [NC-1:0] c_gwe_cq01h, c_pwe_cq01h;
  for (genvar s = 0; s < S; s++) begin : g_cw
    for (genvar h = 0; h < R; h++) begin : g_h
      assign c_gwe_cq01h[h * S + s] = ha_cq01h[(s * H + h) * PA + 3];
      assign c_pwe_cq01h[h * S + s] = ha_cq01h[(s * H + h) * PA + 4];
    end
  end
  // The Rename 1 register's copy the heads' reads see as the pending group
  // (NGD-7: the register drives the outputs; its copy, the reads, which go
  // on to the register again), and the names bound from it.
  (* keep *) logic [R-1:0]    o_v_cq03h, o_gwe_cq03h, o_pwe_cq03h;
  (* keep *) logic [R*LS-1:0] o_slot_cq03h;
  (* keep *) logic [R*4-1:0]  o_dst_cq03h;
  (* keep *) logic [R*2-1:0]  o_pdst_cq03h;
  (* keep *) logic [R-1:0]    p_v_cq03h, p_gwe_cq03h, p_pwe_cq03h;
  (* keep *) logic [R*LS-1:0] p_slot_cq03h;
  (* keep *) logic [R*4-1:0]  p_dst_cq03h;
  (* keep *) logic [R*2-1:0]  p_pdst_cq03h;
  logic [R*GW-1:0]     p_gname_cq03h;
  logic [R*PW-1:0]     p_pname_cq03h;
  logic [S*R*4*GW-1:0] c_gv_cq03h;
  logic [S*R*4*R-1:0]  c_gw_cq01h;
  logic [S*R*4*PW-1:0] c_pv_cq03h;
  logic [S*R*4*R-1:0]  c_pw_cq01h;
  for (genvar s = 0; s < S; s++) begin : g_rd
    logic [R*3*4-1:0] src_cq01h;
    logic [R*4-1:0]   dst_cq01h;
    logic [R-1:0]     gwe_cq01h, pwe_cq01h;
    logic [R*2-1:0]   pguard_cq01h, pdst_cq01h;
    logic [R*2*2-1:0] pq_cq01h;
    for (genvar h = 0; h < R; h++) begin : g_h
      assign src_cq01h[h * 12 +: 12]   = c_src_cq01h[(h * S + s) * 12 +: 12];
      assign dst_cq01h[h * 4 +: 4]     = c_dst_cq01h[(h * S + s) * 4 +: 4];
      assign gwe_cq01h[h]              = c_gwe_cq01h[h * S + s];
      assign pguard_cq01h[h * 2 +: 2]  = c_pguard_cq01h[(h * S + s) * 2 +: 2];
      assign pdst_cq01h[h * 2 +: 2]    = c_pdst_cq01h[(h * S + s) * 2 +: 2];
      assign pwe_cq01h[h]              = c_pwe_cq01h[h * S + s];
      assign pq_cq01h[h * 4 +: 4]      = c_pq_cq01h[(h * S + s) * 4 +: 4];
    end
    ooe_headrd #(.S(S), .SL(s), .R(R), .A(R), .GW(GW), .PW(PW)) u_rd (
      .rat_cq02h(rat_cq02h[s * MW +: MW]), .h_src_cq01h(src_cq01h), .h_dst_cq01h(dst_cq01h),
      .h_gwe_cq01h(gwe_cq01h), .h_pguard_cq01h(pguard_cq01h), .h_pdst_cq01h(pdst_cq01h), .h_pwe_cq01h(pwe_cq01h),
      .h_pq_cq01h(pq_cq01h), .pw_v_cq01h(p_v_cq03h), .pw_slot_cq01h(p_slot_cq03h), .pw_dst_cq01h(p_dst_cq03h),
      .pw_gwe_cq01h(p_gwe_cq03h), .pw_gname_cq01h(p_gname_cq03h), .pw_pdst_cq01h(p_pdst_cq03h),
      .pw_pwe_cq01h(p_pwe_cq03h), .pw_pname_cq01h(p_pname_cq03h),
      .h_gv_cq01h(c_gv_cq03h[s * R * 4 * GW +: R * 4 * GW]), .h_gw_cq01h(c_gw_cq01h[s * R * 4 * R +: R * 4 * R]),
      .h_pv_cq01h(c_pv_cq03h[s * R * 4 * PW +: R * 4 * PW]), .h_pw_cq01h(c_pw_cq01h[s * R * 4 * R +: R * 4 * R]));
  end
  logic [R-1:0]      l_v_cq02h, l_gwe_cq02h, l_pwe_cq02h, l_br_cq02h, l_x_cq02h;
  logic [R*LS-1:0]   l_slot_cq02h;
  logic [R*4-1:0]    l_dst_cq02h;
  logic [R*2-1:0]    l_pdst_cq02h;
  logic [R*2*R-1:0]  l_idx_cq02h;
  logic [R*LC-1:0]   l_ckpt_cq02h;
  logic [R*4*GW-1:0] l_g_cq02h;
  logic [R*4*R-1:0]  l_gl_cq02h, l_pl_cq02h;
  logic [R*4*PW-1:0] l_p_cq02h;
  ooe_ren1 #(.S(S), .R(R), .GW(GW), .PW(PW), .LC(LC), .XW(1)) u_ren1 (
    .c_dst_cq01h, .c_gwe_cq01h, .c_pdst_cq01h, .c_pwe_cq01h, .c_br_cq01h, .c_ckpt_cq01h, .c_x_cq01h('0),
    .c_gv_cq01h(c_gv_cq03h), .c_gw_cq01h, .c_pv_cq01h(c_pv_cq03h), .c_pw_cq01h, .lane_v_cq02h, .lane_c_cq02h,
    .wb_cq02h, .l_v(l_v_cq02h), .l_slot(l_slot_cq02h), .l_dst(l_dst_cq02h), .l_gwe(l_gwe_cq02h),
    .l_pdst(l_pdst_cq02h), .l_pwe(l_pwe_cq02h), .l_idx(l_idx_cq02h), .l_br(l_br_cq02h), .l_ckpt(l_ckpt_cq02h),
    .l_g(l_g_cq02h), .l_gl(l_gl_cq02h), .l_p(l_p_cq02h), .l_pl(l_pl_cq02h), .l_x(l_x_cq02h));

  // -- The Rename 1 register ---------------------------------------------------
  // Its payload while some slot had a head (the go's registered sel, a
  // superset of a take); its valid bits every cycle. The pending group's
  // fields twice (NGD-7), each copy (* keep *): o_ for the outputs, p_ for
  // the heads' reads; the name index and the free lists' heads three times:
  // q_ for the new names out (by 3), r_ for the reads out (by 6, an in-group
  // writer's name bound through it), p_ for the heads' reads.
  (* keep *) logic [R*2*R-1:0] q_idx_cq03h;
  (* keep *) logic [R*GR-1:0]  q_galloc_cq03h;
  (* keep *) logic [R*PW-1:0]  q_palloc_cq03h;
  (* keep *) logic [R*2*R-1:0] r_idx_cq03h;
  (* keep *) logic [R*GR-1:0]  r_galloc_cq03h;
  (* keep *) logic [R*PW-1:0]  r_palloc_cq03h;
  (* keep *) logic [R*2*R-1:0] p_idx_cq03h;
  (* keep *) logic [R*GR-1:0]  p_galloc_cq03h;
  (* keep *) logic [R*PW-1:0]  p_palloc_cq03h;
  logic [R*4*GW-1:0] q_gv_cq03h;
  logic [R*4*R-1:0]  q_gl_cq03h, q_pl_cq03h;
  logic [R*4*PW-1:0] q_pv_cq03h;
  logic              r1_en_cq02h;
  assign r1_en_cq02h = sel_cq02h != '0;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      o_v_cq03h <= '0;
      p_v_cq03h <= '0;
    end else begin
      o_v_cq03h <= l_v_cq02h;
      p_v_cq03h <= l_v_cq02h;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (r1_en_cq02h) begin
      o_slot_cq03h   <= l_slot_cq02h;
      o_dst_cq03h    <= l_dst_cq02h;
      o_gwe_cq03h    <= l_gwe_cq02h;
      o_pdst_cq03h   <= l_pdst_cq02h;
      o_pwe_cq03h    <= l_pwe_cq02h;
      q_idx_cq03h    <= l_idx_cq02h;
      q_br_cq03h     <= l_br_cq02h;
      q_ckpt_cq03h   <= l_ckpt_cq02h;
      q_gv_cq03h     <= l_g_cq02h;
      q_gl_cq03h     <= l_gl_cq02h;
      q_pv_cq03h     <= l_p_cq02h;
      q_pl_cq03h     <= l_pl_cq02h;
      q_galloc_cq03h <= galloc_cq02h;
      q_palloc_cq03h <= palloc_cq02h;
      p_slot_cq03h   <= l_slot_cq02h;
      p_dst_cq03h    <= l_dst_cq02h;
      p_gwe_cq03h    <= l_gwe_cq02h;
      p_pdst_cq03h   <= l_pdst_cq02h;
      p_pwe_cq03h    <= l_pwe_cq02h;
      r_idx_cq03h    <= l_idx_cq02h;
      r_galloc_cq03h <= galloc_cq02h;
      r_palloc_cq03h <= palloc_cq02h;
      p_idx_cq03h    <= l_idx_cq02h;
      p_galloc_cq03h <= galloc_cq02h;
      p_palloc_cq03h <= palloc_cq02h;
    end
  end

  assign q_v_cq03h    = o_v_cq03h;
  assign q_slot_cq03h = o_slot_cq03h;
  assign q_dst_cq03h  = o_dst_cq03h;
  assign q_gwe_cq03h  = o_gwe_cq03h;
  assign q_pdst_cq03h = o_pdst_cq03h;
  assign q_pwe_cq03h  = o_pwe_cq03h;

  // -- The names bound ---------------------------------------------------------
  // The new names out, from the q_ copy (its reads unused).
  logic [R*4*GW-1:0] q_gx_cq03h;
  logic [R*4*PW-1:0] q_px_cq03h;
  ooe_ren1n #(.R(R), .GW(GW), .GR(GR), .PW(PW)) u_ren1n (
    .q_idx_cq01h(q_idx_cq03h), .q_galloc_cq01h(q_galloc_cq03h), .q_palloc_cq01h(q_palloc_cq03h),
    .q_g_cq01h('0), .q_gl_cq01h('0), .q_p_cq01h('0), .q_pl_cq01h('0),
    .n_gname(q_gname_cq03h), .n_pname(q_pname_cq03h), .n_g(q_gx_cq03h), .n_p(q_px_cq03h));
  // The reads out, from the r_ copy (its new names used only inside).
  logic [R*GW-1:0] r_gname_cq03h;
  logic [R*PW-1:0] r_pname_cq03h;
  ooe_ren1n #(.R(R), .GW(GW), .GR(GR), .PW(PW)) u_ren1nr (
    .q_idx_cq01h(r_idx_cq03h), .q_galloc_cq01h(r_galloc_cq03h), .q_palloc_cq01h(r_palloc_cq03h),
    .q_g_cq01h(q_gv_cq03h), .q_gl_cq01h(q_gl_cq03h), .q_p_cq01h(q_pv_cq03h), .q_pl_cq01h(q_pl_cq03h),
    .n_gname(r_gname_cq03h), .n_pname(r_pname_cq03h), .n_g(q_g_cq03h), .n_p(q_p_cq03h));
  // From the copy, the pending group's names alone (its reads unused).
  logic [R*4*GW-1:0] p_g_cq03h;
  logic [R*4*PW-1:0] p_p_cq03h;
  ooe_ren1n #(.R(R), .GW(GW), .GR(GR), .PW(PW)) u_ren1np (
    .q_idx_cq01h(p_idx_cq03h), .q_galloc_cq01h(p_galloc_cq03h), .q_palloc_cq01h(p_palloc_cq03h),
    .q_g_cq01h('0), .q_gl_cq01h('0), .q_p_cq01h('0), .q_pl_cq01h('0),
    .n_gname(p_gname_cq03h), .n_pname(p_pname_cq03h), .n_g(p_g_cq03h), .n_p(p_p_cq03h));

  // A lane's names come from what its free list offers: every name a take
  // asks for is there.
  `CCV_ASSERT(gname_offered, (wt_cq02h[0 +: R] & ~galv_cq02h) == '0)
  `CCV_ASSERT(pname_offered, (wt_cq02h[R +: R] & ~palv_cq02h) == '0)
endmodule
`undef CCV_CLK
`undef CCV_RST
