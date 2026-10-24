//===-- ooe_select.sv - OOE select: requests and the per-class picks ------===//
//
// Spec: the design doc's Select section (DA's response OI-31: one pick per
//       resource, an entry issues only if it wins every resource in its
//       footprint; OI-33: a memop's footprint is the MIU pipes at its data
//       position), Memory operations (V-17: a memop issues only on
//       confirmed sources; OI-15: memops in program order per warp), the
//       masked load's copy (A-38, V-61: the copy issues in an earlier cycle
//       than its load, on confirmed sources), bulk discards (V-23: a
//       discard takes P0, and no memop of its warp goes with it), and
//       ooe_sched's registers (OA's responses OI-51, OI-53).
//
// Select's logic in ooe_sched, timed there (an inner helper,
// ooe_select.ngd.json). The requests, then one ooe_pick per class; the RCU
// class's with the section fallback (FB; OA's response IS-9), which the
// MIU pipes do not take. The design is FB 1, which ooe_sched sets.
//
// An entry requests its footprint's resources (S0-S3 and R for the RCU
// class, bits 0-4; P0-P3 for the MIU class, bits 5-8) when ooe_sched's
// request register holds it (not issued, its warp active, and a copy's
// sources confirmed, as an earlier cycle ended), its ready register holds
// it, its grant register does not (granted last cycle, not yet captured
// as issued), and ooe_rs says it is valid and past rename's stages. A
// memop also needs none of its pipes taken by a bulk discard (a discard
// takes MIU pipes only, V-23), its sources confirmed, no bulk discard of
// its warp this cycle, its copy (if it has one still in the RS) issued in
// an earlier cycle, and no older unissued memop of its warp: the age
// matrix gives "older", so the order check is one row-wide OR.
//
// Sources confirmed is "no dependency bit left": a confirmed entry is freed
// in the cycle it confirms and its column cleared (ooe_confirm), so a bit
// still set names a producer not yet confirmed.
//
// The reference is the model's selectSectioned, which logs these inputs,
// its candidates and its grants as it runs (Core::wakeLog: sel_*);
// test/ooe/select_tb.cpp drives this module with the inputs and compares
// both.
//===----------------------------------------------------------------------===//
module ooe_select #(
  parameter int N  = 45,     // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int NR = 30,     // RCU-class entries, [0, NR)
  parameter int S  = 4,      // tier-1 warp slots (CCV_TIER1_WARPS)
  parameter int FB = 1,      // the RCU class's section fallback (ooe_pick; OA's response IS-9)
  localparam int NM = N - NR,
  localparam int LS = $clog2(S),
  localparam int W  = $clog2(N),
  localparam int RR = 5,     // the RCU class's resources: S0-S3, R
  localparam int RM = 4      // the MIU class's: P0-P3
) (
  input  logic [N-1:0]       rq_cq03h,      // ooe_sched's request register
  input  logic [N-1:0]       ready_cq03h,   // its ready register
  input  logic [N-1:0]       gnt_cq03h,     // its grant register: granted last cycle
  input  logic [N-1:0]       vel_cq03h,     // valid and past rename's stages (ooe_rs)
  input  logic [N-1:0]       iss_cq03h,     // issued (ooe_wake)
  input  logic [N*N-1:0]     dep_cq03h,     // row i, column j: i waits on j
  input  logic [N*LS-1:0]    slot_cq03h,    // each entry's warp slot
  input  logic [N*9-1:0]     res_cq03h,     // each entry's footprint
  input  logic [N-1:0]       chas_cq03h,    // a memop whose copy is in the RS
  input  logic [N*W-1:0]     cidx_cq03h,    // and that copy's entry
  input  logic [NR*NR-1:0]   older_r_cq03h, // the RCU class's age matrix
  input  logic [NM*NM-1:0]   older_m_cq03h, // the MIU class's
  input  logic [RM-1:0]      busy_cq03h,    // MIU pipes a bulk discard took (only P0, V-23)
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
          if (older_m_cq03h[(e - NR) * NM + (j - NR)] && vel_cq03h[j] && !iss_cq03h[j] &&
              slot_cq03h[j * LS +: LS] == sl)
            order_ok[e] = 1'b0;
      req[e] = rq_cq03h[e] && ready_cq03h[e] && !gnt_cq03h[e] && vel_cq03h[e];
      if (e >= NR)
        req[e] = req[e] && (res_cq03h[e * 9 + RR +: RM] & busy_cq03h) == '0 && conf[e] && !block_cq03h[sl] &&
                 copy_ok[e] && order_ok[e];
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
