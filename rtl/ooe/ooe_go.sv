//===-- ooe_go.sv - OOE rename's go: per-warp fits and the interleaved take ===//
//
// Spec: docs/design-snapshots/ooe-microarchitecture.md, "Rename's go
//       decision" (OA-21, OA-22, OI-65); docs/ooe-rtl-plan.md, ooe_rename,
//       slice 4; docs/ooe-model.md, "What the go reads" (go_static).
//
// Rename's go, from registered state alone. Each cycle it splits each shared
// credit (RS RCU, RS MIU, GPR names, predicate names) among the warps with a
// head, for the next cycle: from the credit no allowance in force holds (the
// counter less min(R, the allowances in force)), the names' pool also less
// every slot's unmet floor, each warp floor(pool / k) and the first in
// rotation the remainder too, each warp's names adding its own unmet floor.
// And it registers, per warp s and per take k of its own this cycle (0 to
// R), fits_s[k]: the length of the run of its heads past its first k that
// fit, against those allowances, the ROB room the take leaves (the free run
// from the tail, its retirements counted where the run reaches the head),
// and no serializing uop (chwidth or barrier) before the last. A restore
// owning the ports registers no allowance and takes nothing.
//
// The next cycle's take selects fits_s[take_s] by the warp's own registered
// take, clips it by its hold and the heads decq shows now (a slot whose
// flush applies shows none), and interleaves the warps uop by uop in the
// rotating order, R uops at most: round r takes each warp's r-th uop, the
// warps from the rotation's first. Lane l is the l-th uop taken; its head is
// the warp's position past this cycle's earlier takes, which decq's output
// register shows from 0.
//
// Each head's admission bits are decq's (the payload's low PA): bit 0 RCU, 1
// MIU, 2 copy (a second RCU entry), 3 GPR write, 4 predicate write, 5 branch,
// 6 serial. A warp's needs per cycle fit 3 bits: at most R uops, each at most
// one of each.
//
// The reference is the model's go under go_static (Core::goLog: the inputs
// as this module holds them, and the takes in lane order); test/ooe/go_tb.cpp
// drives this module from it every cycle and compares the takes and lanes.
//
// Reset line: the fits, the allowances and the takes are cleared; the
// rotation starts at slot 0.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_go #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int R  = 4,                  // uops a cycle (CCV_ISSUE_WIDTH)
  parameter int PA = 7,                  // admission bits a head
  parameter int LC = 10,                 // a credit counter's width
  parameter int LU = 5,                  // an unmet floor's width
  parameter int LB = 6,                  // a ROB run's width
  parameter int LT = 3,                  // a cycle's retirements' width
  localparam int H  = 2 * R - 1,         // decq's heads a slot
  localparam int LS = $clog2(S),
  localparam int LK = $clog2(R + 1),     // a take count
  localparam int LH = $clog2(R),         // a head position within a take
  localparam int LA = $clog2(R + 1)      // an allowance, saturated at R
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  // decq's output register: each slot's heads past rename's latest take.
  input  logic [S*H-1:0]    hv_cq01h,
  input  logic [S*H*PA-1:0] ha_cq01h,
  // Rename's counters: the credits, the floors owed (GPR, predicate) and
  // each slot's unmet floors.
  input  logic [4*LC-1:0]   cred_cq01h,
  input  logic [2*LC-1:0]   owed_cq01h,
  input  logic [S*LU-1:0]   unmet_g_cq01h,
  input  logic [S*LU-1:0]   unmet_p_cq01h,
  // Each slot's ROB: the free run from the tail as the cycle started, whether
  // it reaches the head, and this cycle's retirements.
  input  logic [S*LB-1:0]   run_cq01h,
  input  logic [S-1:0]      reach_cq01h,
  input  logic [S*LT-1:0]   ret_cq01h,
  input  logic [S-1:0]      hold_cq01h,    // a warp hold, registered (inactive, fault, chwidth, barrier)
  input  logic              rbusy_cq01h,   // a restore-allocate owns the ports
  // The take: per slot, to decq (deq_n) and its take-enable (deq_sel).
  output logic [S*LK-1:0]   take_cq01h,
  output logic [S-1:0]      sel_cq01h,
  // Per lane: a uop, its slot and its head.
  output logic [R-1:0]      lane_v_cq01h,
  output logic [R*LS-1:0]   lane_s_cq01h,
  output logic [R*LH-1:0]   lane_h_cq01h
);
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) rst_r01h <= ooe_rst_r00h;

  `CCV_ASSERT_KNOWN(rbusy_known, rbusy_cq01h)
  `CCV_ASSERT_KNOWN(hold_known, hold_cq01h)

  // The registered half's state, and the rotation.
  logic [S*(R+1)*R-1:0] fits_cq02h;      // per slot and take k, a thermometer of the run that fits
  logic [S*LK-1:0]      tk_cq02h;        // each slot's take this cycle, registered
  logic [S*4*LA-1:0]    shr_cq02h;       // the allowances in force this cycle, saturated at R
  logic [S-1:0]         prio_cq02h;      // the rotation's first slot, one-hot

  // -- The take ----------------------------------------------------------------
  // Each warp's run: its fits at its own last take, clipped by its hold and
  // the heads decq shows now.
  logic [S*R-1:0] run_t;
  always_comb
    for (int s = 0; s < S; s++)
      for (int j = 0; j < R; j++) begin
        run_t[s * R + j] = 1'b0;
        for (int k = 0; k <= R; k++)
          if (tk_cq02h[s * LK +: LK] == LK'(k)) run_t[s * R + j] = fits_cq02h[(s * (R + 1) + k) * R + j];
        run_t[s * R + j] = run_t[s * R + j] & hv_cq01h[s * H + j] & ~hold_cq01h[s] & ~rbusy_cq01h;
      end
  // The interleave: candidate (round r, rotation offset o) is slot prio + o's
  // r-th uop; it takes lane rank, the takers before it in round-major order,
  // while rank < R.
  logic [R*S-1:0]  tk_c;                 // candidate (r, o) is taken
  logic [R*S*3-1:0] rank_c;              // its rank, saturated at R
  logic [S*S-1:0]  at_o;                 // offset o is slot s
  always_comb begin
    for (int o = 0; o < S; o++)
      for (int s = 0; s < S; s++) begin
        at_o[o * S + s] = 1'b0;
        for (int f = 0; f < S; f++) if (prio_cq02h[f] && (f + o) % S == s) at_o[o * S + s] = 1'b1;
      end
  end
  logic [2:0] rk;
  logic       want;
  always_comb begin
    rk = '0;
    for (int r = 0; r < R; r++)
      for (int o = 0; o < S; o++) begin
        want = 1'b0;
        for (int s = 0; s < S; s++) if (at_o[o * S + s] && run_t[s * R + r]) want = 1'b1;
        rank_c[(r * S + o) * 3 +: 3] = rk;
        tk_c[r * S + o] = want && rk < 3'(R);
        if (want && rk < 3'(R)) rk = rk + 3'd1;
      end
  end
  // Per slot its take; per lane its uop.
  always_comb begin
    take_cq01h   = '0;
    lane_v_cq01h = '0;
    lane_s_cq01h = '0;
    lane_h_cq01h = '0;
    for (int r = 0; r < R; r++)
      for (int o = 0; o < S; o++)
        for (int s = 0; s < S; s++)
          if (tk_c[r * S + o] && at_o[o * S + s]) begin
            take_cq01h[s * LK +: LK] = LK'(r + 1);
            for (int l = 0; l < R; l++)
              if (rank_c[(r * S + o) * 3 +: 3] == 3'(l)) begin
                lane_v_cq01h[l]             = 1'b1;
                lane_s_cq01h[l * LS +: LS]  = LS'(s);
                lane_h_cq01h[l * LH +: LH]  = LH'(r);
              end
          end
  end
  // decq's take-enable: the warp's fits at its last take, from this module's
  // flops through the mux (a superset of its take: deq_sel_covers).
  always_comb
    for (int s = 0; s < S; s++) begin
      sel_cq01h[s] = 1'b0;
      for (int k = 0; k <= R; k++)
        if (tk_cq02h[s * LK +: LK] == LK'(k)) sel_cq01h[s] = fits_cq02h[(s * (R + 1) + k) * R];
    end

  // -- The registered half: next cycle's allowances ------------------------------
  // The warps with a head; the first in rotation; how many.
  logic [S-1:0] with_w, first_w;
  logic [2:0]   nw;
  logic         seen;
  always_comb begin
    with_w = '0;
    for (int s = 0; s < S; s++) with_w[s] = hv_cq01h[s * H];
    nw = '0;
    for (int s = 0; s < S; s++) nw = nw + 3'(with_w[s]);
    first_w = '0;
    seen    = 1'b0;
    for (int o = 0; o < S; o++)
      for (int s = 0; s < S; s++)
        if (at_o[o * S + s] && with_w[s] && !seen) begin
          first_w[s] = 1'b1;
          seen       = 1'b1;
        end
  end
  // Each credit's pool: what no allowance in force holds, the names' less the
  // floors owed, saturated at 4R (past it every share is R or more).
  logic [4*5-1:0]  pool;
  logic [LC+2:0]   held, avail;
  always_comb
    for (int r = 0; r < 4; r++) begin
      held = '0;
      for (int s = 0; s < S; s++) held = held + (LC + 3)'(shr_cq02h[(s * 4 + r) * LA +: LA]);
      if (held > (LC + 3)'(R)) held = (LC + 3)'(R);
      avail = (LC + 3)'(cred_cq01h[r * LC +: LC]);
      avail = avail > held ? avail - held : '0;
      if (r >= 2) avail = avail > (LC + 3)'(owed_cq01h[(r - 2) * LC +: LC]) ? avail - (LC + 3)'(owed_cq01h[(r - 2) * LC +: LC]) : '0;
      pool[r * 5 +: 5] = avail > (LC + 3)'(4 * R) ? 5'(4 * R) : 5'(avail);
    end
  // The split, by table on (pool, warps): the quotient, and the first's.
  logic [S*4*LA-1:0] split;
  logic [4:0]        q, f;
  logic [LU+5:0]     sh;
  always_comb
    for (int r = 0; r < 4; r++) begin
      q = '0;
      f = '0;
      for (int kk = 1; kk <= S; kk++)
        for (int v = 0; v <= 4 * R; v++)
          if (nw == 3'(kk) && pool[r * 5 +: 5] == 5'(v)) begin
            q = 5'(v / kk);
            f = 5'(v - (kk - 1) * (v / kk));
          end
      for (int s = 0; s < S; s++) begin
        sh = with_w[s] ? (LU + 6)'(first_w[s] ? f : q) : '0;
        if (r == 2 && with_w[s]) sh = sh + (LU + 6)'(unmet_g_cq01h[s * LU +: LU]);
        if (r == 3 && with_w[s]) sh = sh + (LU + 6)'(unmet_p_cq01h[s * LU +: LU]);
        if (rbusy_cq01h) sh = '0;     // a restore owning the ports registers none
        split[(s * 4 + r) * LA +: LA] = sh > (LU + 6)'(R) ? LA'(R) : LA'(sh);
      end
    end

  // -- The registered half: next cycle's fits ------------------------------------
  // Per slot and take k, the run past its first k: head k + m - 1 is valid,
  // none before it in the run is serial, the ROB room covers k + m, and the
  // run's needs fit the allowances.
  logic [S*(R+1)*R-1:0] fits_nx;
  logic [LB+LT:0]       room;
  logic                 ok;
  logic [2:0]           nr, nm, ng, np;
  logic [PA-1:0]        a, ap;
  always_comb
    for (int s = 0; s < S; s++) begin
      room = (LB + LT + 1)'(run_cq01h[s * LB +: LB]) +
             (reach_cq01h[s] ? (LB + LT + 1)'(ret_cq01h[s * LT +: LT]) : '0);
      for (int k = 0; k <= R; k++) begin
        ok = 1'b1;
        nr = '0; nm = '0; ng = '0; np = '0;
        for (int m = 1; m <= R; m++) begin
          if (k + m - 1 < H) begin
            a  = ha_cq01h[(s * H + k + m - 1) * PA +: PA];
            ap = m >= 2 ? ha_cq01h[(s * H + k + m - 2) * PA +: PA] : '0;
            nr = nr + 3'(a[0]) + 3'(a[2]);
            nm = nm + 3'(a[1]);
            ng = ng + 3'(a[3]);
            np = np + 3'(a[4]);
            ok = ok && hv_cq01h[s * H + k + m - 1] && !(m >= 2 && ap[6]) &&
                 (LB + LT + 1)'(k + m) <= room &&
                 nr <= 3'(split[(s * 4 + 0) * LA +: LA]) && nm <= 3'(split[(s * 4 + 1) * LA +: LA]) &&
                 ng <= 3'(split[(s * 4 + 2) * LA +: LA]) && np <= 3'(split[(s * 4 + 3) * LA +: LA]);
          end else begin
            ok = 1'b0;
          end
          fits_nx[(s * (R + 1) + k) * R + m - 1] = ok;
        end
      end
    end

  // -- The registers -------------------------------------------------------------
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      fits_cq02h <= '0;
      tk_cq02h   <= '0;
      shr_cq02h  <= '0;
      prio_cq02h <= S'(1);
    end else begin
      fits_cq02h <= fits_nx;
      tk_cq02h   <= take_cq01h;
      shr_cq02h  <= split;
      if (!rbusy_cq01h) prio_cq02h <= {prio_cq02h[S-2:0], prio_cq02h[S-1]};
    end
  end

  // decq's take-enable covers every slot that takes (deq_sel_covers).
  logic [S-1:0] tk_any;
  always_comb for (int s = 0; s < S; s++) tk_any[s] = take_cq01h[s * LK +: LK] != '0;
  `CCV_ASSERT(sel_covers, (tk_any & ~sel_cq01h) == '0)
endmodule
`undef CCV_CLK
`undef CCV_RST
