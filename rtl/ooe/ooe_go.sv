//===-- ooe_go.sv - OOE rename's go: per-warp fits and the interleaved take ===//
//
// Spec: docs/design-snapshots/ooe-microarchitecture.md, "Rename's go
//       decision" (OA-21, OA-22, OI-65); docs/ooe-rtl-plan.md, ooe_rename,
//       slice 4; docs/ooe-model.md, "What the go reads" (go_static); OA's
//       rev 171 (the restructure: leads, a parallel rank, balanced fits).
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
// take, clips it by the warp's block, and interleaves the warps uop by uop
// in the rotating order, R uops at most: round r takes each warp's r-th
// uop, the warps from the rotation's first. Lane l is the l-th uop taken;
// its head is the warp's position past this cycle's earlier takes, which
// decq's output register shows from 0.
//
// The block is this module's own flops, from leads (OA's rev 171 (b)): the
// warp's hold and a restore owning the ports, each its producer's register
// D a cycle ahead, and the slot's squash at the next edge (the ROB's). A
// squash blocks its slot for three cycles: the cycle it applies (the model
// drops the slot's heads at once), and the two after, while decq's output
// register still shows them (its flush lands an edge late). The block is
// folded into the take register, held one-hot: a blocked warp's take
// selects none of its fits.
//
// Each credit arrives as rename's pool register (OA's rev 171 (a)): the
// counter less its floors owed (the names'), saturated at 5R, with the go's
// take on its D. This module subtracts the allowances in force, from its
// own register of them.
//
// The take is parallel (rev 171 (c)): candidate (r, s), warp s's r-th uop,
// is taken while its rank, the candidates before it (every warp's rounds
// before r, and round r's warps before s in rotation), is below R; a
// warp's take is its taken candidates, a thermometer. Ranks are sums of
// thermometers saturated at R, added in trees. The fits are balanced
// (rev 171 (d)): each credit's pool is a thermometer, each warp's share one
// too, and fits_s[k] at length m is one AND over thermometer compares of
// the run's needs, each formed from the heads alone.
//
// Each head's admission bits are decq's (the payload's low PA): bit 0 RCU, 1
// MIU, 2 copy (a second RCU entry), 3 GPR write, 4 predicate write, 5 branch,
// 6 serial. A credit's take in a cycle is at most R: a class's allocation
// ports, a name per uop.
//
// The reference is the model's go under go_static (Core::goLog: the inputs
// as this module holds them, and the takes in lane order); test/ooe/go_tb.cpp
// drives this module from it every cycle and compares the takes and lanes.
//
// Reset line: the fits, the allowances held, the takes and the blocks are
// cleared; the rotation starts at slot 0.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_go #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int R  = 4,                  // uops a cycle (CCV_ISSUE_WIDTH)
  parameter int PA = 7,                  // admission bits a head
  parameter int LU = 5,                  // an unmet floor's width
  parameter int LB = 6,                  // a ROB run's width
  parameter int LT = 3,                  // a cycle's retirements' width
  localparam int H  = 2 * R - 1,         // decq's heads a slot
  localparam int LS = $clog2(S),
  localparam int LK = $clog2(R + 1),     // a take count
  localparam int LH = $clog2(R),         // a head position within a take
  localparam int PM = 4 * R,             // a pool's thermometer, saturated
  localparam int XM = PM + R,            // a credit less its floors owed, saturated
  localparam int LX = $clog2(XM + 1)
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  // decq's output register: each slot's heads past rename's latest take.
  input  logic [S*H-1:0]    hv_cq01h,
  input  logic [S*H*PA-1:0] ha_cq01h,
  // Rename's pool registers, per credit (RS RCU, RS MIU, GPR names,
  // predicate names): the counter less its floors owed, saturated at XM;
  // and each slot's unmet floors.
  input  logic [4*LX-1:0]   px_cq01h,
  input  logic [S*LU-1:0]   unmet_g_cq01h,
  input  logic [S*LU-1:0]   unmet_p_cq01h,
  // Each slot's ROB: the free run from the tail as the cycle started, whether
  // it reaches the head, and this cycle's retirements.
  input  logic [S*LB-1:0]   run_cq01h,
  input  logic [S-1:0]      reach_cq01h,
  input  logic [S*LT-1:0]   ret_cq01h,
  // Leads, each the next cycle's value: a warp hold (inactive, fault,
  // chwidth, barrier), a restore-allocate owning the ports, a slot's squash.
  input  logic [S-1:0]      hold_l_cq00h,
  input  logic              rbusy_l_cq00h,
  input  logic [S-1:0]      sq_l_cq00h,
  // The take: per slot, to decq (deq_n) and its take-enable (deq_sel).
  output logic [S*LK-1:0]   take_cq02h,
  output logic [S-1:0]      sel_cq02h,
  // Per lane: a uop, its slot and its head.
  output logic [R-1:0]      lane_v_cq02h,
  output logic [R*LS-1:0]   lane_s_cq02h,
  output logic [R*LH-1:0]   lane_h_cq02h
);
  // Two thermometers' sum, saturated at R (bit v - 1: the sum is v or more).
  function automatic logic [R-1:0] tadd(input logic [R-1:0] a, input logic [R-1:0] b);
    logic [R:0] x, y;
    x = {a, 1'b1};
    y = {b, 1'b1};
    for (int v = 1; v < R + 1; v++) begin
      tadd[v - 1] = 1'b0;
      for (int j = 0; j < v + 1; j++) tadd[v - 1] = tadd[v - 1] | (x[j] & y[v - j]);
    end
  endfunction

  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) rst_r01h <= ooe_rst_r00h;


  `CCV_ASSERT_KNOWN(rbusy_known, rbusy_l_cq00h)
  `CCV_ASSERT_KNOWN(hold_known, hold_l_cq00h)
  `CCV_ASSERT_KNOWN(sq_known, sq_l_cq00h)

  // The registered state. The rotation is kept twice (NGD-7): one copy for
  // the take, the outputs' path, one for the rest.
  logic [S*(R+1)*R-1:0] fits_cq02h;      // per slot and take k, a thermometer of the run that fits
  logic [S*(R+1)-1:0]   tko_cq02h;       // each slot's take this cycle, one-hot, none if it is blocked
  logic [S-1:0]         sel_q_cq02h;     // some take of its own has a head that fits
  logic [4*R-1:0]       held_cq02h;      // per credit, min(R, the allowances in force), a thermometer
  (* keep *) logic [S-1:0] prio_cq02h;   // the rotation's first slot, one-hot, for the take
  (* keep *) logic [S-1:0] priod_cq02h;  // and for the rest
  logic                 rbusy_cq01h;     // the restore's lead, registered
  logic [S*2-1:0]       sqc_cq01h;       // per slot, the cycles its squash still blocks

  // -- The take ----------------------------------------------------------------
  // Each warp's run, a thermometer: its fits at its own last take, none if
  // it is blocked (the one-hot take register holds no bit then).
  logic [S*R-1:0] run_t;
  always_comb
    for (int s = 0; s < S; s++)
      for (int j = 0; j < R; j++) begin
        run_t[s * R + j] = 1'b0;
        for (int k = 0; k < R + 1; k++)
          run_t[s * R + j] = run_t[s * R + j] | (fits_cq02h[(s * (R + 1) + k) * R + j] & tko_cq02h[s * (R + 1) + k]);
      end
  // Slot q is before slot s in this cycle's rotation (from the flops alone).
  logic [S*S-1:0] bef;
  always_comb
    for (int s = 0; s < S; s++)
      for (int q = 0; q < S; q++) begin
        bef[s * S + q] = 1'b0;
        for (int f = 0; f < S; f++)
          if (prio_cq02h[f] && ((q - f + S) % S) < ((s - f + S) % S)) bef[s * S + q] = 1'b1;
      end
  // Candidate (r, s)'s rank, a thermometer: every warp's takes in the rounds
  // before r (its run, below r) and round r's takers before s, in two trees.
  logic [R*R-1:0]   ra;                  // per round, the takes before it
  logic [R*S*R-1:0] rk;                  // per candidate, its rank
  logic [R*S-1:0]   tk_c;
  logic [R-1:0]     m0, m1, m2, m3, b0, b1, b2, b3;
  always_comb
    for (int r = 0; r < R; r++) begin
      m0 = '0; m1 = '0; m2 = '0; m3 = '0;
      for (int v = 0; v < r; v++) begin
        m0[v] = run_t[0 * R + v];
        if (S > 1) m1[v] = run_t[1 * R + v];
        if (S > 2) m2[v] = run_t[2 * R + v];
        if (S > 3) m3[v] = run_t[3 * R + v];
      end
      ra[r * R +: R] = tadd(tadd(m0, m1), tadd(m2, m3));
      for (int s = 0; s < S; s++) begin
        b0 = {{(R-1){1'b0}}, run_t[0 * R + r] & bef[s * S + 0]};
        b1 = '0; b2 = '0; b3 = '0;
        if (S > 1) b1 = {{(R-1){1'b0}}, run_t[1 * R + r] & bef[s * S + 1]};
        if (S > 2) b2 = {{(R-1){1'b0}}, run_t[2 * R + r] & bef[s * S + 2]};
        if (S > 3) b3 = {{(R-1){1'b0}}, run_t[3 * R + r] & bef[s * S + 3]};
        rk[(r * S + s) * R +: R] = tadd(ra[r * R +: R], tadd(tadd(b0, b1), tadd(b2, b3)));
        tk_c[r * S + s] = run_t[s * R + r] & ~rk[(r * S + s) * R + R - 1];
      end
    end
  // Per slot its take, a thermometer counted; per lane its uop.
  logic [R:0] rq;
  always_comb begin
    take_cq02h   = '0;
    lane_v_cq02h = '0;
    lane_s_cq02h = '0;
    lane_h_cq02h = '0;
    for (int s = 0; s < S; s++)
      for (int r = 0; r < R; r++)
        if (tk_c[r * S + s]) take_cq02h[s * LK +: LK] = LK'(r + 1);
    for (int r = 0; r < R; r++)
      for (int s = 0; s < S; s++) begin
        rq = {rk[(r * S + s) * R +: R], 1'b1};
        for (int l = 0; l < R; l++)
          if (tk_c[r * S + s] && rq[l] && !rq[l + 1]) begin
            lane_v_cq02h[l]            = 1'b1;
            lane_s_cq02h[l * LS +: LS] = lane_s_cq02h[l * LS +: LS] | LS'(s);
            lane_h_cq02h[l * LH +: LH] = lane_h_cq02h[l * LH +: LH] | LH'(r);
          end
      end
  end
  // decq's take-enable: some take of the warp's own has a head that fits, a
  // register (a superset of its take: deq_sel_covers).
  assign sel_cq02h = sel_q_cq02h;

  // -- The registered half: next cycle's allowances ------------------------------
  // The warps with a head; the first in rotation; how many, one-hot (nwh[n],
  // n warps).
  logic [S*S-1:0] befd;
  logic [S-1:0]   with_w, first_w;
  logic [S:0]     nwh;
  logic [2:0]     nw;
  always_comb begin
    for (int s = 0; s < S; s++)
      for (int q = 0; q < S; q++) begin
        befd[s * S + q] = 1'b0;
        for (int f = 0; f < S; f++)
          if (priod_cq02h[f] && ((q - f + S) % S) < ((s - f + S) % S)) befd[s * S + q] = 1'b1;
      end
    for (int s = 0; s < S; s++) with_w[s] = hv_cq01h[s * H];
    nw = '0;
    for (int s = 0; s < S; s++) nw = nw + 3'(with_w[s]);
    for (int n = 0; n < S + 1; n++) nwh[n] = nw == 3'(n);
    for (int s = 0; s < S; s++) begin
      first_w[s] = with_w[s];
      for (int q = 0; q < S; q++) if (befd[s * S + q] && with_w[q]) first_w[s] = 1'b0;
    end
  end
  // The pool, what no allowance in force holds: pt[c][v], the pool register
  // covers v beyond them, a thermometer saturated at PM, and one-hot
  // (pe[c][p], the pool is p; p = PM, PM or more).
  logic [4*(PM+1)-1:0] pt, pe;
  logic [4*(R+1)-1:0]  he;               // held, one-hot
  logic [LX-1:0]       px;
  always_comb
    for (int c = 0; c < 4; c++) begin
      px = px_cq01h[c * LX +: LX];
      for (int h = 0; h < R + 1; h++) begin
        he[c * (R + 1) + h] = 1'b1;
        if (h > 0) he[c * (R + 1) + h] = he[c * (R + 1) + h] & held_cq02h[c * R + h - 1];
        if (h < R) he[c * (R + 1) + h] = he[c * (R + 1) + h] & ~held_cq02h[c * R + h];
      end
      pt[c * (PM + 1)] = 1'b1;
      for (int v = 1; v < PM + 1; v++) begin
        pt[c * (PM + 1) + v] = 1'b0;
        for (int h = 0; h < R + 1; h++)
          pt[c * (PM + 1) + v] = pt[c * (PM + 1) + v] | (he[c * (R + 1) + h] & (px >= LX'(v + h)));
      end
      for (int p = 0; p < PM + 1; p++) begin
        pe[c * (PM + 1) + p] = pt[c * (PM + 1) + p];
        if (p < PM) pe[c * (PM + 1) + p] = pe[c * (PM + 1) + p] & ~pt[c * (PM + 1) + p + 1];
      end
    end
  // A warp's share at pool p: floor(p / n), the first's p - (n - 1) floor(p
  // / n), the names' plus its unmet floor u.
  function automatic int share_of(input int p, input int n, input int fst, input int u);
    share_of = (fst != 0 ? p - (n - 1) * (p / n) : p / n) + u;
  endfunction
  // Each warp's share, a thermometer to R (sg[s][c][v - 1], v 1 to R): which
  // pools give it v or more is formed from the warps and floors alone, and
  // the pool, one-hot, picks; none without a head or under a restore.
  logic [S*4*R-1:0] sg;
  logic [LU-1:0]    u;
  logic [R:0]       ue;                  // u, one-hot to R (R: R or more)
  logic [PM:0]      at;                  // the pools that give v or more
  always_comb
    for (int s = 0; s < S; s++)
      for (int c = 0; c < 4; c++) begin
        u = c == 2 ? unmet_g_cq01h[s * LU +: LU] : c == 3 ? unmet_p_cq01h[s * LU +: LU] : '0;
        for (int w = 0; w < R + 1; w++) ue[w] = w == R ? u >= LU'(R) : u == LU'(w);
        for (int v = 1; v < R + 1; v++) begin
          for (int p = 0; p < PM + 1; p++) begin
            at[p] = 1'b0;
            for (int n = 1; n < S + 1; n++)
              for (int f = 0; f < 2; f++)
                for (int w = 0; w < R + 1; w++)
                  if (share_of(p, n, f, w) >= v)
                    at[p] = at[p] | (nwh[n] & ((f != 0) == first_w[s]) & ue[w]);
          end
          sg[(s * 4 + c) * R + v - 1] = |(at & pe[c * (PM + 1) +: PM + 1]) & with_w[s] & ~rbusy_cq01h;
        end
      end
  // The allowances to hold next cycle: min(R, the shares' sum). The shares
  // split the pool whole among the warps with a head, so the sum is the pool
  // (the names' plus those warps' unmet floors); none under a restore.
  logic [R:0]     ut;                    // the unmet floors summed, a thermometer (ut[v]: v or more)
  logic [LU+2:0]  us;
  logic [4*R-1:0] held_nx;
  always_comb
    for (int c = 0; c < 4; c++) begin
      us = '0;
      for (int s = 0; s < S; s++) begin
        if (with_w[s] && c == 2) us = us + (LU + 3)'(unmet_g_cq01h[s * LU +: LU]);
        if (with_w[s] && c == 3) us = us + (LU + 3)'(unmet_p_cq01h[s * LU +: LU]);
      end
      for (int v = 0; v < R + 1; v++) ut[v] = us >= (LU + 3)'(v);
      for (int v = 1; v < R + 1; v++) begin
        held_nx[c * R + v - 1] = 1'b0;
        for (int j = 0; j < v + 1; j++)
          held_nx[c * R + v - 1] = held_nx[c * R + v - 1] | (pt[c * (PM + 1) + j] & ut[v - j]);
        held_nx[c * R + v - 1] = held_nx[c * R + v - 1] & (nw != '0) & ~rbusy_cq01h;
      end
    end

  // -- The registered half: next cycle's fits ------------------------------------
  // Per slot, take k and length m (head k + m - 1 the last): the heads are
  // there, none before the last is serial, the ROB room covers k + m, the
  // run takes at most R of each credit, and each credit's need, one-hot
  // from the heads alone, picks the share's bit that must be set.
  logic [S*(R+1)*R-1:0] fits_nx;
  logic [LB+LT:0]       room;
  logic [2*R:0]         rm;              // room >= n
  logic                 ok, ser;
  logic [3:0]           nd [4];          // each credit's need over the run
  logic [PA-1:0]        a;
  always_comb
    for (int s = 0; s < S; s++) begin
      room = (LB + LT + 1)'(run_cq01h[s * LB +: LB]) +
             (reach_cq01h[s] ? (LB + LT + 1)'(ret_cq01h[s * LT +: LT]) : '0);
      for (int n = 0; n < 2 * R + 1; n++) rm[n] = room >= (LB + LT + 1)'(n);
      for (int k = 0; k < R + 1; k++) begin
        for (int c = 0; c < 4; c++) nd[c] = '0;
        ser = 1'b0;
        for (int m = 1; m < R + 1; m++) begin
          ok = 1'b0;
          if (k + m - 1 < H) begin
            a     = ha_cq01h[(s * H + k + m - 1) * PA +: PA];
            nd[0] = nd[0] + 4'(a[0]) + 4'(a[2]);
            nd[1] = nd[1] + 4'(a[1]);
            nd[2] = nd[2] + 4'(a[3]);
            nd[3] = nd[3] + 4'(a[4]);
            ok = hv_cq01h[s * H + k + m - 1] && !ser && rm[k + m] && nd[0] < 4'(R + 1);
            for (int c = 0; c < 4; c++)
              for (int v = 1; v < R + 1; v++)
                if (nd[c] == 4'(v)) ok = ok && sg[(s * 4 + c) * R + v - 1];
            ser = ser | a[6];
          end
          fits_nx[(s * (R + 1) + k) * R + m - 1] = ok;
        end
      end
    end

  // -- The registers -------------------------------------------------------------
  // A squash blocks its slot for three cycles, counted down; the take
  // register holds no bit for a slot blocked next cycle.
  logic [S*2-1:0]     sqc_nx;
  logic [S-1:0]       blk_nx, sel_nx;
  logic [S*(R+1)-1:0] tko_nx;
  always_comb
    for (int s = 0; s < S; s++) begin
      sqc_nx[s * 2 +: 2] = sq_l_cq00h[s] ? 2'd3 : sqc_cq01h[s * 2 +: 2] != 2'd0 ? sqc_cq01h[s * 2 +: 2] - 2'd1 : 2'd0;
      blk_nx[s] = hold_l_cq00h[s] | rbusy_l_cq00h | (sqc_nx[s * 2 +: 2] != 2'd0);
      for (int k = 0; k < R + 1; k++)
        tko_nx[s * (R + 1) + k] = take_cq02h[s * LK +: LK] == LK'(k) && !blk_nx[s];
      sel_nx[s] = 1'b0;
      for (int k = 0; k < R + 1; k++) sel_nx[s] = sel_nx[s] | fits_nx[(s * (R + 1) + k) * R];
    end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      rbusy_cq01h  <= 1'b0;
      sqc_cq01h    <= '0;
    end else begin
      rbusy_cq01h  <= rbusy_l_cq00h;
      sqc_cq01h    <= sqc_nx;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      fits_cq02h  <= '0;
      tko_cq02h   <= '0;
      sel_q_cq02h <= '0;
      held_cq02h  <= '0;
      prio_cq02h  <= S'(1);
      priod_cq02h <= S'(1);
    end else begin
      fits_cq02h  <= fits_nx;
      tko_cq02h   <= tko_nx;
      sel_q_cq02h <= sel_nx;
      held_cq02h  <= held_nx;
      if (!rbusy_cq01h) prio_cq02h <= {prio_cq02h[S-2:0], prio_cq02h[S-1]};
      if (!rbusy_cq01h) priod_cq02h <= {priod_cq02h[S-2:0], priod_cq02h[S-1]};
    end
  end

  // decq's take-enable covers every slot that takes (deq_sel_covers).
  logic [S-1:0] tk_any;
  always_comb for (int s = 0; s < S; s++) tk_any[s] = take_cq02h[s * LK +: LK] != '0;
  `CCV_ASSERT(sel_covers, (tk_any & ~sel_cq02h) == '0)
endmodule
`undef CCV_CLK
`undef CCV_RST
