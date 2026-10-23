//===-- ooe_sched.sv - OOE scheduler: ready, request and grant registers --===//
//
// Spec: the design doc's Select and Stage boundaries sections; OA's
//       responses OI-51 (the ready register), OI-53 (the request register,
//       the split of select's terms) and OI-54 (V-73: the ready register
//       captures every edge after which a line or a valid row it reads
//       changes, the stop lead formed here from the replay rule).
//
// Three stages' registers around two helpers, all three registers gated
// from this module's own flops (CG-5):
//
//   Ready: ooe_ready over the RS's matrix and ooe_wake's lines (as they
//   stand after this edge) into the ready register. Its enable is the flop
//   of the leads: ooe_wake's timer lead (a producer's line changes by
//   timer at the edge after next), of lines some row's cell selects, and
//   its event lead (a miss, or a completion past L1,
//   changes lines at the edge after next: each known a cycle ahead, a
//   completion by its channel's valid), ooe_rs's
//   allocation lead (a row written at this edge), and the stop lead,
//   OI-50's replay rule over iss, dep and msd as they stand after this
//   edge (an entry returns to Waiting at the next cycle's hop).
//
//   Request: per entry, valid, not issued, its warp active, and a copy's
//   sources confirmed (its row empty), as they stand after this edge. Its
//   enable: the grant register's OR (a grant's not-issued fall, which the
//   grant register masks at select until then), the stop lead (a replay's
//   return on time), and the flop of "the register differs from its next
//   value, and this edge does not capture it", so anything else (a warp's active, a copy's confirmation, a
//   row written) is captured one edge late. A late rise costs a cycle at most; a late fall
//   is safe, since a warp leaves Active only by a squash of all its
//   entries and valid is read live, with past rename (vel_cq03h).
//
//   Select: ooe_select (FB 1) over those registers and the live memop
//   terms, into the grant register. The grant register is three copies,
//   each (* keep *): one leaves (grant_cq04h), one masks the requests
//   (NGD-7), and one goes to ooe_wake alone (grant_w_cq04h), whose timers
//   take it straight into their enables (OA's response OI-58: ooe_wake's
//   CG-5 waiver, the grant at 2 NGD).
//   Its enable is "something may request or something is held": the
//   request and ready registers' AND, or the mask copy's OR.
//
// The reference is the model's ready and request registers and its
// sectioned select (Core::readyRegister, Core::requestRegister,
// Core::selectSectioned); test/ooe/trio_tb.cpp drives this module with
// ooe_rs and ooe_wake, assembled, from the model and compares the ready
// register, the request register and the grants (OA's response OI-45). It
// is this module's clock-gating bench too: its enables are leads of its
// neighbours' state, which only they give in their own frame.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_sched #(
  parameter int N  = 45,     // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int NR = 30,     // RCU-class entries, [0, NR)
  parameter int S  = 4,      // tier-1 warp slots (CCV_TIER1_WARPS)
  parameter int FB = 1,      // the RCU class's section fallback (OA's response IS-9)
  localparam int NM = N - NR,
  localparam int LS = $clog2(S),
  localparam int W  = $clog2(N),
  localparam int WL = 4,     // wake lines per producer
  localparam int CW = 2      // a cell's line select
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  // The ready and request registers' next values, and the stop lead's
  // terms: the RS's matrix and ooe_wake's lines, and each entry's state
  // (issued counting the grant leaving now and this edge's hop), as they
  // stand after this edge.
  input  logic [N*N-1:0]    dep_cq02h,
  input  logic [N*N*CW-1:0] code_cq02h,
  input  logic [N*WL-1:0]   wake_cq02h,
  input  logic [N-1:0]      valid_cq02h,
  input  logic [N-1:0]      iss_cq02h,
  input  logic [N*LS-1:0]   slot_cq02h,
  input  logic [S-1:0]      active_cq02h,
  input  logic [N-1:0]      copy_cq02h,
  // Leads, into the enable flops.
  input  logic [N-1:0]      msd_cq02h,     // missed: the replay rule's (OI-50)
  input  logic [N-1:0]      mis_cq02h,     // ooe_wake: missed at the last edge, held from the next cycle
  input  logic [N-1:0]      fin_cq02h,     // ooe_wake: the result is final
  input  logic [N-1:0]      prod_cq02h,    // ooe_rs: the entry writes a register some entry may wake on
  input  logic [N*WL-1:0]   wtl_cq02h,     // ooe_wake: a producer's line changes by timer at the edge after next
  input  logic              wml_cq02h,     // ooe_wake: a miss or a completion does
  input  logic              alloc_cq02h,   // ooe_rs: a row is written at this edge
  // Select's live terms.
  input  logic [N-1:0]      vel_cq03h,     // valid and past rename's stages (ooe_rs)
  input  logic [N-1:0]      siss_cq03h,
  input  logic [N*N-1:0]    sdep_cq03h,
  input  logic [N*LS-1:0]   sslot_cq03h,
  input  logic [N*9-1:0]    res_cq03h,
  input  logic [N-1:0]      chas_cq03h,
  input  logic [N*W-1:0]    cidx_cq03h,
  input  logic [NR*NR-1:0]  older_r_cq03h,
  input  logic [NM*NM-1:0]  older_m_cq03h,
  input  logic [3:0]        busy_cq03h,    // MIU pipes a bulk discard took
  input  logic [S-1:0]      block_cq03h,
  output logic [N-1:0]      grant_cq04h,
  output logic [N-1:0]      grant_w_cq04h  // the same, for ooe_wake's timers
);

  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  // -- Leads ----------------------------------------------------------------
  // The stop lead: OI-50's replay rule, an issued entry with a producer
  // not issued or missed, over the state after this edge.
  // The same rule gives this cycle's replays (rep): ooe_rs and ooe_wake
  // take them at this edge, so issued after it is iss less rep (OA's
  // response OI-45: the model's order, a replayed entry requesting at
  // once; V-65 holds it to ooe_rs's issued register an edge later).
  // The stop lead is the next cycle's replays, so the request register
  // captures them on their edge: the rule over issued after this cycle's
  // stops, the matrix as it stands and the held misses with this cycle's
  // pulses. Next cycle's issued and matrix only shrink by then, and its held
  // misses only grow by the pulses, so the lead is a superset.
  logic         stop_cq02h;
  (* keep *) logic [N-1:0] gnt_cq04h;      // the grant register's mask copy
  logic [N-1:0] rep_cq02h, ise_cq02h, gon, isg, cnf;
  logic [N*N-1:0] dpm;                      // the matrix less this cycle's confirmations' columns
  always_comb begin
    // Issued counts the grant leaving now (the grant register), which
    // ooe_wake takes at this edge.
    isg = iss_cq02h | gnt_cq04h;
    // A producer's issued bit before this edge's grants, as ooe_rs's rule
    // reads it (V-65): an entry issued on a producer replayed and granted
    // again at this edge is replayed.
    for (int i = 0; i < N; i++)
      rep_cq02h[i] = isg[i] && (dep_cq02h[i * N +: N] & (~iss_cq02h | msd_cq02h)) != '0;
    ise_cq02h  = isg & ~rep_cq02h;
    // This cycle's confirmations (OA's response OI-45 (1)): ooe_rs and
    // ooe_wake free them at this edge; their columns clear in the matrix an
    // edge later, so the ready and request terms read the matrix less them.
    for (int i = 0; i < N; i++)
      cnf[i] = isg[i] && dep_cq02h[i * N +: N] == '0 && (fin_cq02h[i] || !prod_cq02h[i]);
    for (int i = 0; i < N; i++) dpm[i * N +: N] = dep_cq02h[i * N +: N] & ~cnf;
    gon        = ~ise_cq02h | msd_cq02h | mis_cq02h;
    stop_cq02h = 1'b0;
    for (int i = 0; i < N; i++)
      stop_cq02h = stop_cq02h | (ise_cq02h[i] && (dpm[i * N +: N] & gon) != '0);
  end

  // The timer lead, of lines some row reads: a line no cell selects
  // changes no row.
  logic tl_cq02h;
  always_comb begin
    logic [N*WL-1:0] read;
    read = '0;
    for (int i = 0; i < N; i++)
      for (int j = 0; j < N; j++)
        for (int k = 0; k < WL; k++)
          read[j * WL + k] = read[j * WL + k] | (dep_cq02h[i * N + j] && code_cq02h[(i * N + j) * CW +: CW] == CW'(k));
    tl_cq02h = (wtl_cq02h & read) != '0;
  end

  // -- Ready register ---------------------------------------------------------
  logic [N-1:0] ready_cq02h;
  logic [N-1:0] ready_cq03h;
  logic         ready_en_cq03h, stop_cq03h, alc_cq03h;
  logic         gl_cq05h;                   // a grant some row depends on left at the last edge
  logic         ready_en;
  // A row not valid reads not ready (only a valid row requests): a row
  // written ready then changes its bit, so the allocation lead clocks a change.
  ooe_ready #(.N(N), .W(WL), .CW(CW)) u_ready (.dep_cq02h(dpm), .code_cq02h(code_cq02h),
                                             .wake_cq02h(wake_cq02h), .ready_cq02h(ready_cq02h));

  // -- Request register -------------------------------------------------------
  logic [N-1:0] rq_cq02h, rq_cq03h;
  logic         chg_cq04h, rq_en, gnt_en_cq03h;
  always_comb
    for (int e = 0; e < N; e++)
      rq_cq02h[e] = valid_cq02h[e] && !ise_cq02h[e] && active_cq02h[slot_cq02h[e * LS +: LS]] &&
                    (!copy_cq02h[e] || dpm[e * N +: N] == '0);
  assign rq_en  = chg_cq04h || stop_cq03h || gnt_cq04h != '0 || alc_cq03h;

  // -- Select -----------------------------------------------------------------
  logic [N-1:0] cand_cq03h, grant_cq03h, lost_cq03h;
  ooe_select #(.N(N), .NR(NR), .S(S), .FB(FB)) u_select (
    .rq_cq03h(rq_cq03h), .ready_cq03h(ready_cq03h), .gnt_cq03h(gnt_cq04h), .vel_cq03h(vel_cq03h),
    .iss_cq03h(siss_cq03h), .dep_cq03h(sdep_cq03h), .slot_cq03h(sslot_cq03h), .res_cq03h(res_cq03h),
    .chas_cq03h(chas_cq03h), .cidx_cq03h(cidx_cq03h), .older_r_cq03h(older_r_cq03h),
    .older_m_cq03h(older_m_cq03h), .busy_cq03h(busy_cq03h), .block_cq03h(block_cq03h),
    .cand_cq03h(cand_cq03h), .grant_cq03h(grant_cq03h), .lost_cq03h(lost_cq03h));
  (* keep *) logic [N-1:0] gnt_out_cq04h;  // the grant register's leaving copy
  (* keep *) logic [N-1:0] gnt_w_cq04h;    // and ooe_wake's
  assign gnt_en_cq03h      = (rq_cq03h & ready_cq03h) != '0 || gnt_cq04h != '0;
  assign ready_en    = ready_en_cq03h || gl_cq05h;
  // A grant moves a ready bit at the edge it arrives only through the lead
  // line (WL - 1) of a producer of latency LEAD + 1, threshold age 1; every
  // other line's threshold is age 2 or later, which ooe_wake's timer lead
  // foresees. So the columns some row reads by the lead line.
  logic [N-1:0] dcol_cq02h;
  always_comb begin
    dcol_cq02h = '0;
    for (int i = 0; i < N; i++)
      for (int j = 0; j < N; j++)
        dcol_cq02h[j] = dcol_cq02h[j] | (dep_cq02h[i * N + j] && code_cq02h[(i * N + j) * CW +: CW] == CW'(WL - 1));
  end
  assign grant_cq04h   = gnt_out_cq04h;
  assign grant_w_cq04h = gnt_w_cq04h;

  // -- Registers --------------------------------------------------------------
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      ready_en_cq03h <= 1'b0;
      gl_cq05h       <= 1'b0;
      stop_cq03h     <= 1'b0;
      alc_cq03h      <= 1'b0;

      chg_cq04h      <= 1'b0;
    end else begin
      // A grant leaving now: ooe_wake takes it at this edge, and its lead
      // line may rise there (a latency of LEAD + 1, OA's response OI-45),
      // which no timer lead of ooe_wake's foresees.
      ready_en_cq03h <= tl_cq02h || wml_cq02h || alloc_cq02h || stop_cq02h;
      gl_cq05h       <= (gnt_cq04h & dcol_cq02h) != '0;
      stop_cq03h     <= stop_cq02h;
      alc_cq03h      <= alloc_cq02h;
      chg_cq04h      <= !rq_en && rq_cq02h != rq_cq03h;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      ready_cq03h <= '0;
      rq_cq03h    <= '0;
    end else begin
      if (ready_en) ready_cq03h <= ready_cq02h & valid_cq02h;
      if (rq_en) rq_cq03h <= rq_cq02h;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      gnt_cq04h     <= '0;
      gnt_out_cq04h <= '0;
      gnt_w_cq04h   <= '0;
    end else if (gnt_en_cq03h) begin
      gnt_cq04h     <= grant_cq03h;
      gnt_out_cq04h <= grant_cq03h;
      gnt_w_cq04h   <= grant_cq03h;
    end
  end

  // -- The input contract ------------------------------------------------------
  // What ooe_rs and ooe_wake give this module (test/ooe/trio_tb.cpp drives
  // them assembled): issued and the held misses name valid entries, and
  // every row written was led by alloc_cq02h the cycle before (the ready
  // and request registers' enables). A row not valid is don't-care: ooe_rs
  // leaves a freed row's bits in place.
  `CCV_ASSERT(iss_valid, (iss_cq02h & ~valid_cq02h) == '0)
  `CCV_ASSERT(msd_issued, (msd_cq02h & ~iss_cq02h) == '0)
  `CCV_ASSERT_T(alloc_led, (valid_cq02h & ~`CCV_PAST(valid_cq02h)) == '0 || `CCV_PAST(alloc_cq02h))

endmodule
`undef CCV_CLK
`undef CCV_RST
