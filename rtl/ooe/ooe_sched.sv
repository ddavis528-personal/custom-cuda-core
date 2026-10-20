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
//   terms, into the grant register. The grant register is two copies, each
//   (* keep *): one leaves (grant_cq04h), one masks the requests (NGD-7).
//   Its enable is "something may request or something is held": the
//   request and ready registers' AND, or the mask copy's OR.
//
// The reference is the model's ready and request registers and its
// sectioned select (Core::readyRegister, Core::requestRegister,
// Core::selectSectioned); test/ooe/sched_tb.cpp drives this module from
// the model and compares the ready register, the request register and the
// grants.
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
  output logic [N-1:0]      grant_cq04h
);

  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  // -- Leads ----------------------------------------------------------------
  // The stop lead: OI-50's replay rule, an issued entry with a producer
  // not issued or missed, over the state after this edge.
  logic stop_cq02h;
  always_comb begin
    stop_cq02h = 1'b0;
    for (int i = 0; i < N; i++)
      stop_cq02h = stop_cq02h | (iss_cq02h[i] && (dep_cq02h[i * N +: N] & (~iss_cq02h | msd_cq02h)) != '0);
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
  logic         ready_en_cq03h, stop_cq03h;
  ooe_ready #(.N(N), .W(WL), .CW(CW)) u_ready (.dep_cq02h(dep_cq02h), .code_cq02h(code_cq02h),
                                             .wake_cq02h(wake_cq02h), .ready_cq02h(ready_cq02h));

  // -- Request register -------------------------------------------------------
  (* keep *) logic [N-1:0] gnt_cq04h;      // the grant register's mask copy
  logic [N-1:0] rq_cq02h, rq_cq03h;
  logic         chg_cq04h, rq_en, gnt_en;
  always_comb
    for (int e = 0; e < N; e++)
      rq_cq02h[e] = valid_cq02h[e] && !iss_cq02h[e] && active_cq02h[slot_cq02h[e * LS +: LS]] &&
                    (!copy_cq02h[e] || dep_cq02h[e * N +: N] == '0);
  assign rq_en  = chg_cq04h || stop_cq03h || gnt_cq04h != '0;

  // -- Select -----------------------------------------------------------------
  logic [N-1:0] cand, grant_cq03h, lost;
  ooe_select #(.N(N), .NR(NR), .S(S), .FB(FB)) u_select (
    .rq_cq03h(rq_cq03h), .ready_cq03h(ready_cq03h), .gnt_cq03h(gnt_cq04h), .vel_cq03h(vel_cq03h),
    .iss_cq03h(siss_cq03h), .dep_cq03h(sdep_cq03h), .slot_cq03h(sslot_cq03h), .res_cq03h(res_cq03h),
    .chas_cq03h(chas_cq03h), .cidx_cq03h(cidx_cq03h), .older_r_cq03h(older_r_cq03h),
    .older_m_cq03h(older_m_cq03h), .busy_cq03h(busy_cq03h), .block_cq03h(block_cq03h),
    .cand_cq03h(cand), .grant_cq03h(grant_cq03h), .lost_cq03h(lost));
  (* keep *) logic [N-1:0] gnt_out_cq04h;  // the grant register's leaving copy
  assign gnt_en      = (rq_cq03h & ready_cq03h) != '0 || gnt_cq04h != '0;
  assign grant_cq04h = gnt_out_cq04h;

  // -- Registers --------------------------------------------------------------
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      ready_en_cq03h <= 1'b0;
      stop_cq03h     <= 1'b0;
      chg_cq04h      <= 1'b0;
    end else begin
      ready_en_cq03h <= tl_cq02h || wml_cq02h || alloc_cq02h || stop_cq02h;
      stop_cq03h     <= stop_cq02h;
      chg_cq04h      <= !rq_en && rq_cq02h != rq_cq03h;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      ready_cq03h <= '0;
      rq_cq03h    <= '0;
    end else begin
      if (ready_en_cq03h) ready_cq03h <= ready_cq02h;
      if (rq_en) rq_cq03h <= rq_cq02h;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      gnt_cq04h     <= '0;
      gnt_out_cq04h <= '0;
    end else if (gnt_en) begin
      gnt_cq04h     <= grant_cq03h;
      gnt_out_cq04h <= grant_cq03h;
    end
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
