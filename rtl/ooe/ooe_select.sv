//===-- ooe_select.sv - OOE select: requests and the per-class picks ------===//
//
// Spec: the design doc's Select section (DA's response OI-31: one pick per
//       resource, an entry issues only if it wins every resource in its
//       footprint; OI-33: a memop's footprint is the MIU pipes at its data
//       position), Memory operations (V-17: a memop issues only on
//       confirmed sources; OI-15: memops in program order per warp), the
//       masked load's copy (A-38, V-61: the copy issues in an earlier cycle
//       than its load, on confirmed sources) and bulk discards (V-23: a
//       discard takes P0, and no memop of its warp goes with it).
//
// The requests, then one ooe_pick per class; the RCU class's with the
// section fallback (FB; OA's response IS-9), which the MIU pipes do not
// take. The design is section-only (FB 1): with the aligned-half pick too
// (FB 2) this module measured 26.8 NGD, past its stage; section-only
// measures 24.3, against 19.5 with none. FB defaults to 0 until ooe_sched
// instantiates this module with 1: alone, an inner helper is held to 16
// (NGD-6), and FB 1 adds paths over that which its ratchet entries do not
// name. test/ooe/select_tb.cpp builds it with the model's pick_fallback. An entry requests its
// footprint's resources (S0-S3 and R for the RCU class, bits 0-4; P0-P3
// for the MIU class, bits 5-8) when it is valid, not issued, past rename's
// stages, its warp active, its row ready, and none of its resources is
// taken by a bulk discard. A copy also needs its sources confirmed. A
// memop also needs its sources confirmed, no bulk discard of its warp
// this cycle, its copy (if it has one still in the RS) issued in an
// earlier cycle, and no older unissued memop of its warp: the age matrix
// gives "older", so the order check is one row-wide OR.
//
// Sources confirmed is "no dependency bit left": a confirmed entry is freed
// in the cycle it confirms and its column cleared (ooe_confirm), so a bit
// still set names a producer not yet confirmed.
//
// The reference is the model's selectSectioned, which logs these inputs,
// its candidates and its grants as it runs (Core::wakeLog: sel_*);
// test/ooe/select_tb.cpp drives this module with the inputs and compares
// both.
//
// Combinational: the state it reads is held by ooe_rs (valid, the matrix),
// ooe_wake (issued), ooe_ready, ooe_age, the payload and the warp table.
//===----------------------------------------------------------------------===//
module ooe_select #(
  parameter int N  = 45,     // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int NR = 30,     // RCU-class entries, [0, NR)
  parameter int S  = 4,      // tier-1 warp slots (CCV_TIER1_WARPS)
  parameter int FB = 0,      // the RCU class's section fallback (ooe_pick; OA's response IS-9); ooe_sched sets 1
  localparam int NM = N - NR,
  localparam int LS = $clog2(S),
  localparam int W  = $clog2(N),
  localparam int RR = 5,     // the RCU class's resources: S0-S3, R
  localparam int RM = 4      // the MIU class's: P0-P3
) (
  input  logic [N-1:0]       valid_cq03h,
  input  logic [N-1:0]       iss_cq03h,     // issued
  input  logic [N-1:0]       elig_cq03h,    // past rename's stages
  input  logic [N-1:0]       ready_cq03h,   // ooe_ready
  input  logic [N*N-1:0]     dep_cq03h,     // row i, column j: i waits on j
  input  logic [N*LS-1:0]    slot_cq03h,    // each entry's warp slot
  input  logic [S-1:0]       active_cq03h,  // each slot's warp is active
  input  logic [N*9-1:0]     res_cq03h,     // each entry's footprint
  input  logic [N-1:0]       copy_cq03h,    // a masked load's copy-only op
  input  logic [N-1:0]       chas_cq03h,    // a memop whose copy is in the RS
  input  logic [N*W-1:0]     cidx_cq03h,    // and that copy's entry
  input  logic [NR*NR-1:0]   older_r_cq03h, // the RCU class's age matrix
  input  logic [NM*NM-1:0]   older_m_cq03h, // the MIU class's
  input  logic [8:0]         busy_cq03h,    // resources a bulk discard took
  input  logic [S-1:0]       block_cq03h,   // slots with a bulk discard
  output logic [N-1:0]       cand_cq03h,    // requests this cycle
  output logic [N-1:0]       grant_cq03h,   // issues this cycle
  output logic [N-1:0]       lost_cq03h     // won a resource, lost another
);

  logic [N-1:0]     conf, order_ok, copy_ok, req;
  logic [NR*RR-1:0] req_r;
  logic [NM*RM-1:0] req_m;
  logic [LS-1:0]    sl;

  always_comb begin
    for (int e = 0; e < N; e++) begin
      sl          = slot_cq03h[e * LS +: LS];
      conf[e]     = dep_cq03h[e * N +: N] == '0;
      copy_ok[e]  = !chas_cq03h[e] || iss_cq03h[cidx_cq03h[e * W +: W]];
      order_ok[e] = 1'b1;
      if (e >= NR)
        for (int j = NR; j < N; j++)
          if (older_m_cq03h[(e - NR) * NM + (j - NR)] && valid_cq03h[j] && !iss_cq03h[j] &&
              slot_cq03h[j * LS +: LS] == sl)
            order_ok[e] = 1'b0;
      req[e] = valid_cq03h[e] && !iss_cq03h[e] && elig_cq03h[e] && active_cq03h[sl] && ready_cq03h[e] &&
               (res_cq03h[e * 9 +: 9] & busy_cq03h) == '0;
      if (copy_cq03h[e]) req[e] = req[e] && conf[e];
      if (e >= NR) req[e] = req[e] && conf[e] && !block_cq03h[sl] && copy_ok[e] && order_ok[e];
    end
    for (int e = 0; e < NR; e++) req_r[e * RR +: RR] = req[e] ? res_cq03h[e * 9 +: RR] : '0;
    for (int e = 0; e < NM; e++) req_m[e * RM +: RM] = req[NR + e] ? res_cq03h[(NR + e) * 9 + RR +: RM] : '0;
    cand_cq03h = req;
  end

  logic [NR*RR-1:0] win_r;
  logic [NM*RM-1:0] win_m;
  logic [N-1:0]     fb;          // grants by the RCU class's section fallback
  ooe_pick #(.N(NR), .R(RR), .FB(FB)) pick_r (.req_cq03h(req_r), .older_cq03h(older_r_cq03h),
                                     .issue_cq03h(grant_cq03h[NR-1:0]), .lost_cq03h(lost_cq03h[NR-1:0]),
                                     .win_cq03h(win_r), .fb_cq03h(fb[NR-1:0]));
  ooe_pick #(.N(NM), .R(RM)) pick_m (.req_cq03h(req_m), .older_cq03h(older_m_cq03h),
                                     .issue_cq03h(grant_cq03h[N-1:NR]), .lost_cq03h(lost_cq03h[N-1:NR]),
                                     .win_cq03h(win_m), .fb_cq03h(fb[N-1:NR]));

endmodule
