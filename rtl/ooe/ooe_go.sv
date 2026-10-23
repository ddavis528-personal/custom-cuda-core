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
// The block comes from leads (OA's rev 171 (b)): the warp's hold and a
// restore owning the ports, each its producer's register D a cycle ahead,
// and the slot's squash at the next edge (the ROB's). A blocked warp's fits
// are registered empty. A squash blocks its slot for two cycles: the cycle
// it applies (the model drops the slot's heads at once) and the next, while
// decq still shows them; from the one after, decq's registered flush masks
// them.
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
  // Change leads, each its producer's register enable, for the clock gates
  // (OA's rev 174): decq's arrivals per slot (its heads re-form at the next
  // edge), each slot's ROB room, and rename's pool and floor registers.
  input  logic [S-1:0]      dq_ev_cq01h,
  input  logic [S-1:0]      rob_en_cq01h,
  input  logic              pool_en_cq01h,
  // The take: per slot, a thermometer of its uops (bit r: its r-th uop is
  // taken), to decq (deq_t) and rename's counters; and its take-enable
  // (deq_sel).
  output logic [S*R-1:0]    take_cq02h,
  output logic [S-1:0]      sel_cq02h,
  // Per lane: a uop, and which candidate it is, one-hot (bit r * S + s:
  // slot s's head r).
  output logic [R-1:0]      lane_v_cq02h,
  output logic [R*R*S-1:0]  lane_c_cq02h,
  // Per candidate (bit r * S + s, as the lanes), the uops taken before it
  // in lane order that write a GPR (b 0) or a predicate (b 1), a
  // thermometer (bit j: more than j); and the cycle's totals. Rename takes
  // its names in lane order from these, and asks its free lists for the
  // totals (OI-67).
  output logic [R*S*2*R-1:0] wb_cq02h,
  output logic [2*R-1:0]     wt_cq02h
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
  // S thermometers' sum, saturated at R, added pairwise in log2(S) levels.
  function automatic logic [R-1:0] tsum(input logic [S*R-1:0] x);
    logic [S*R-1:0] y;
    y = x;
    for (int w = 1; w < S; w = w * 2)
      for (int i = 0; i + w < S; i = i + 2 * w) y[i * R +: R] = tadd(y[i * R +: R], y[(i + w) * R +: R]);
    tsum = y[0 +: R];
  endfunction

  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) rst_r01h <= ooe_rst_r00h;


  `CCV_ASSERT_KNOWN(rbusy_known, rbusy_l_cq00h)
  `CCV_ASSERT_KNOWN(hold_known, hold_l_cq00h)
  `CCV_ASSERT_KNOWN(sq_known, sq_l_cq00h)

  // The registered state. The rotation is kept twice (NGD-7): one copy for
  // the take, the outputs' path, one for the rest.
  // The fits and the take register drive the take (required at 14); their
  // copies drive the writer counts, which go further (NGD-7).
  (* keep *) logic [S*(R+1)*R-1:0] fits_cq02h;   // per slot and take k, a thermometer of the run that fits
  (* keep *) logic [S*(R+1)*R-1:0] fitsw_cq02h;  // its copy, for the writer counts
  // Per slot, take k, class b (GPR, predicate) and length m (1 to R): the
  // writers among the m heads past k, a thermometer.
  logic [S*(R+1)*2*R*R-1:0] wc_cq02h;
  (* keep *) logic [S*(R+1)-1:0] tko_cq02h;     // each slot's take this cycle, one-hot
  (* keep *) logic [S*(R+1)-1:0] tkow_cq02h;    // its copy, for the writer counts
  logic [S-1:0]         sel_q_cq02h;     // the slot had a head
  logic [4*(R+1)-1:0]   he_cq02h;        // per credit, min(R, the allowances in force), one-hot
  (* keep *) logic [S-1:0] prio_cq02h;   // the rotation's first slot, one-hot, for the take
  (* keep *) logic [S-1:0] priod_cq02h;  // and for the rest
  logic                 rbusy_cq01h;     // the restore's lead, registered
  logic [S-1:0]         sq_cq01h;        // per slot, its squash at this edge (its lead, registered)
  logic [S-1:0]         blk_cq01h;       // per slot, its block now: hold, restore or squash
  logic [S-1:0]         chg_cq02h;       // per slot, some input its fits read changed at the last edge

  // -- The take ----------------------------------------------------------------
  // Each warp's run, a thermometer: its fits at its own last take, none if
  // it is blocked.
  logic [S*R-1:0] run_t_cq02h;
  always_comb
    for (int s = 0; s < S; s++)
      for (int j = 0; j < R; j++) begin
        run_t_cq02h[s * R + j] = 1'b0;
        for (int k = 0; k < R + 1; k++)
          run_t_cq02h[s * R + j] = run_t_cq02h[s * R + j] |
                                   (fits_cq02h[(s * (R + 1) + k) * R + j] & tko_cq02h[s * (R + 1) + k] & ~blk_cq01h[s]);
      end
  // Slot q is before slot s in this cycle's rotation (from the flops alone).
  logic [S*S-1:0] bef_cq02h;
  always_comb
    for (int s = 0; s < S; s++)
      for (int q = 0; q < S; q++) begin
        bef_cq02h[s * S + q] = 1'b0;
        for (int f = 0; f < S; f++)
          if (prio_cq02h[f] && ((q - f + S) % S) < ((s - f + S) % S)) bef_cq02h[s * S + q] = 1'b1;
      end
  // Candidate (r, s)'s rank, a thermometer: each warp's takes before it,
  // the smaller of its run and r + 1 for a warp before s in rotation, of its
  // run and r for the rest (s itself among them); each a slice of the warp's
  // run, summed in one tree.
  logic [R*S*R-1:0] rk_cq02h;                  // per candidate, its rank
  logic [R*S-1:0]   tk_c_cq02h;
  logic [S*R-1:0]   tq_cq02h;                  // each warp's term
  logic [R-1:0]     ot_cq02h;                  // the other warps' terms summed
  always_comb
    for (int r = 0; r < R; r++)
      for (int s = 0; s < S; s++) begin
        tq_cq02h = '0;
        for (int q = 0; q < S; q++)
          for (int v = 0; v < R; v++)
            if (v < r)       tq_cq02h[q * R + v] = run_t_cq02h[q * R + v];
            else if (v == r) tq_cq02h[q * R + v] = run_t_cq02h[q * R + v] & bef_cq02h[s * S + q];
        rk_cq02h[(r * S + s) * R +: R] = tsum(tq_cq02h);
        // Taken: the warp has its r-th uop, so its own term is r, and the
        // others' sum below R - r (the closed form, for the take's depth).
        for (int q = 0; q < S; q++) if (q == s) tq_cq02h[q * R +: R] = '0;
        ot_cq02h = tsum(tq_cq02h);
        tk_c_cq02h[r * S + s] = run_t_cq02h[s * R + r] & (r == 0 || !ot_cq02h[(R - 1 - r) % R]);
      end
  // Per slot its take; per lane its uop: lane l is taken while the runs sum
  // past l, and its uop is the candidate whose rank is l.
  logic [R:0] rq_cq02h;
  always_comb begin
    lane_c_cq02h = '0;
    for (int s = 0; s < S; s++)
      for (int r = 0; r < R; r++) take_cq02h[s * R + r] = tk_c_cq02h[r * S + s];
    lane_v_cq02h = tsum(run_t_cq02h);
    for (int r = 0; r < R; r++)
      for (int s = 0; s < S; s++) begin
        rq_cq02h = {rk_cq02h[(r * S + s) * R +: R], 1'b1};
        for (int l = 0; l < R; l++)
          lane_c_cq02h[(l * R + r) * S + s] = run_t_cq02h[s * R + r] & rq_cq02h[l] & ~rq_cq02h[l + 1];
      end
  end
  // The writer counts' run and take, from the copies: as the take's.
  logic [S*R-1:0] run_w_cq02h;
  logic [R*S-1:0] tk_w_cq02h;
  logic [S*R-1:0] tqw_cq02h;
  logic [R-1:0]   otw_cq02h;
  always_comb begin
    for (int s = 0; s < S; s++)
      for (int j = 0; j < R; j++) begin
        run_w_cq02h[s * R + j] = 1'b0;
        for (int k = 0; k < R + 1; k++)
          run_w_cq02h[s * R + j] = run_w_cq02h[s * R + j] |
                                   (fitsw_cq02h[(s * (R + 1) + k) * R + j] & tkow_cq02h[s * (R + 1) + k] & ~blk_cq01h[s]);
      end
    for (int r = 0; r < R; r++)
      for (int s = 0; s < S; s++) begin
        tqw_cq02h = '0;
        for (int q = 0; q < S; q++)
          for (int v = 0; v < R; v++)
            if (v < r)       tqw_cq02h[q * R + v] = run_w_cq02h[q * R + v];
            else if (v == r) tqw_cq02h[q * R + v] = run_w_cq02h[q * R + v] & bef_cq02h[s * S + q];
        for (int q = 0; q < S; q++) if (q == s) tqw_cq02h[q * R +: R] = '0;
        otw_cq02h = tsum(tqw_cq02h);
        tk_w_cq02h[r * S + s] = run_w_cq02h[s * R + r] & (r == 0 || !otw_cq02h[(R - 1 - r) % R]);
      end
  end

  // The writers before each candidate: its rank's sum, each warp's term the
  // writers among its candidates before this one: its prefix count (at its
  // own last take) at the length its rank term takes, the OR over the
  // lengths the term reaches, as the counts rise with the length; the
  // totals, over the taken writers.
  logic [S*2*(R+1)*R-1:0] wcs_cq02h;           // per slot, class, length m (0 to R): its writers, a thermometer
  logic [S*R-1:0]         wq_cq02h, wtq_cq02h;
  always_comb begin
    for (int q = 0; q < S; q++)
      for (int b = 0; b < 2; b++) begin
        wcs_cq02h[((q * 2 + b) * (R + 1)) * R +: R] = '0;
        for (int m = 1; m < R + 1; m++) begin
          wcs_cq02h[((q * 2 + b) * (R + 1) + m) * R +: R] = '0;
          for (int k = 0; k < R + 1; k++)
            wcs_cq02h[((q * 2 + b) * (R + 1) + m) * R +: R] = wcs_cq02h[((q * 2 + b) * (R + 1) + m) * R +: R] |
              (wc_cq02h[(((q * (R + 1) + k) * 2 + b) * R + m - 1) * R +: R] & {R{tkow_cq02h[q * (R + 1) + k]}});
        end
      end
    for (int b = 0; b < 2; b++) begin
      for (int r = 0; r < R; r++)
        for (int s = 0; s < S; s++) begin
          for (int q = 0; q < S; q++) begin
            wq_cq02h[q * R +: R] = '0;
            for (int v = 0; v < R; v++)
              if (v < r || v == r)
                wq_cq02h[q * R +: R] = wq_cq02h[q * R +: R] |
                  ({R{run_w_cq02h[q * R + v] && (v < r || bef_cq02h[s * S + q])}} & wcs_cq02h[((q * 2 + b) * (R + 1) + v + 1) * R +: R]);
          end
          wb_cq02h[((r * S + s) * 2 + b) * R +: R] = tsum(wq_cq02h);
        end
      // The writers taken: each warp's prefix count at its own take, summed.
      for (int q = 0; q < S; q++) begin
        wtq_cq02h[q * R +: R] = '0;
        for (int m = 1; m < R + 1; m++)
          wtq_cq02h[q * R +: R] = wtq_cq02h[q * R +: R] |
            ({R{tk_w_cq02h[(m - 1) * S + q]}} & wcs_cq02h[((q * 2 + b) * (R + 1) + m) * R +: R]);
      end
      wt_cq02h[b * R +: R] = tsum(wtq_cq02h);
    end
  end

  // decq's take-enable: the warp had a head, a register (a superset of its
  // take: deq_sel_covers).
  assign sel_cq02h = sel_q_cq02h;

  // -- The registered half: next cycle's allowances ------------------------------
  // The warps with a head; the first in rotation; how many, one-hot (nwh[n],
  // n warps).
  logic [S*S-1:0] befd_cq02h;
  logic [S-1:0]   with_w_cq01h, first_w_cq01h;
  logic [S:0]     nwh_cq01h;
  logic [2:0]     nw_cq01h;
  always_comb begin
    for (int s = 0; s < S; s++)
      for (int q = 0; q < S; q++) begin
        befd_cq02h[s * S + q] = 1'b0;
        for (int f = 0; f < S; f++)
          if (priod_cq02h[f] && ((q - f + S) % S) < ((s - f + S) % S)) befd_cq02h[s * S + q] = 1'b1;
      end
    for (int s = 0; s < S; s++) with_w_cq01h[s] = hv_cq01h[s * H];
    nw_cq01h = '0;
    for (int s = 0; s < S; s++) nw_cq01h = nw_cq01h + 3'(with_w_cq01h[s]);
    for (int n = 0; n < S + 1; n++) nwh_cq01h[n] = nw_cq01h == 3'(n);
    for (int s = 0; s < S; s++) begin
      first_w_cq01h[s] = with_w_cq01h[s];
      for (int q = 0; q < S; q++) if (befd_cq02h[s * S + q] && with_w_cq01h[q]) first_w_cq01h[s] = 1'b0;
    end
  end
  // The pool, what no allowance in force holds: one-hot, pe[c][p], the
  // pool register is p beyond the allowances held (p = PM: PM or more); and
  // pt[c][v], it covers v or more beyond them, to R, for the next holding.
  logic [4*(PM+1)-1:0] pe_cq02h;
  logic [4*(R+1)-1:0]  pt_cq02h;
  logic [LX-1:0]       pxc_cq01h;   // this credit's pool register
  always_comb
    for (int c = 0; c < 4; c++) begin
      pxc_cq01h = px_cq01h[c * LX +: LX];
      for (int p = 0; p < PM + 1; p++) begin
        pe_cq02h[c * (PM + 1) + p] = 1'b0;
        for (int h = 0; h < R + 1; h++)
          pe_cq02h[c * (PM + 1) + p] = pe_cq02h[c * (PM + 1) + p] |
              (he_cq02h[c * (R + 1) + h] & (p == PM ? pxc_cq01h >= LX'(p + h) : pxc_cq01h == LX'(p + h)));
      end
      for (int v = 0; v < R + 1; v++) begin
        pt_cq02h[c * (R + 1) + v] = 1'b0;
        for (int h = 0; h < R + 1; h++)
          pt_cq02h[c * (R + 1) + v] = pt_cq02h[c * (R + 1) + v] | (he_cq02h[c * (R + 1) + h] & (pxc_cq01h >= LX'(v + h)));
      end
    end
  // A warp's share at pool p: floor(p / n), the first's p - (n - 1) floor(p
  // / n), the names' plus its unmet floor u.
  function automatic int share_of(input int p, input int n, input int fst, input int u);
    share_of = (fst != 0 ? p - (n - 1) * (p / n) : p / n) + u;
  endfunction
  // A class's share covers its n heads' needs: its thermometer at n (none
  // needed when n is 0).
  function automatic logic sg_fit(input logic [R-1:0] t, input logic [3:0] n);
    sg_fit = 1'b1;
    for (int v = 1; v < R + 1; v++) if (n == 4'(v)) sg_fit = t[v - 1];
  endfunction
  // Each warp's share, a thermometer to R (sg[s][c][v - 1], v 1 to R): which
  // pools give it v or more is formed from the warps and floors alone (the
  // table's terms chosen at elaboration), and the pool, one-hot, picks;
  // none without a head or under a restore.
  logic [S*4*(R+1)-1:0]      ue_cq01h;         // each slot's floor per credit, one-hot to R (R: R or more)
  logic [LU-1:0]             u_cq01h;
  always_comb
    for (int s = 0; s < S; s++)
      for (int c = 0; c < 4; c++) begin
        u_cq01h = c == 2 ? unmet_g_cq01h[s * LU +: LU] : c == 3 ? unmet_p_cq01h[s * LU +: LU] : '0;
        for (int w = 0; w < R + 1; w++) ue_cq01h[(s * 4 + c) * (R + 1) + w] = w == R ? u_cq01h >= LU'(R) : u_cq01h == LU'(w);
      end
  // The table, at elaboration: for each case t (n warps, the first or not,
  // floor w) and each v, the pools that give a share of v or more.
  localparam int NT = S * 2 * (R + 1);
  function automatic logic [NT*R*(PM+1)-1:0] table_of();
    table_of = '0;
    for (int n = 1; n < S + 1; n++)
      for (int f = 0; f < 2; f++)
        for (int w = 0; w < R + 1; w++)
          for (int v = 1; v < R + 1; v++)
            for (int p = 0; p < PM + 1; p++)
              if (share_of(p, n, f, w) >= v)
                table_of[((((n - 1) * 2 + f) * (R + 1) + w) * R + v - 1) * (PM + 1) + p] = 1'b1;
  endfunction
  localparam logic [NT*R*(PM+1)-1:0] TBL = table_of();
  // Per credit, the pool picks first (tp[c][n][f][w][v]: at this pool, case
  // (n, f, w) gives v or more), then the warps' number, the same for all
  // (tw[c][f][w][v]); each warp's role and floor pick last.
  localparam int NF = 2 * (R + 1);       // a warp's cases: role, floor
  logic [4*S*NF*R-1:0] tp_cq02h;
  logic [4*NF*R-1:0]   tw_cq02h;
  always_comb
    for (int c = 0; c < 4; c++) begin
      for (int t = 0; t < NT; t++)
        for (int v = 1; v < R + 1; v++)
          tp_cq02h[(c * NT + t) * R + v - 1] = |(pe_cq02h[c * (PM + 1) +: PM + 1] & TBL[(t * R + v - 1) * (PM + 1) +: PM + 1]);
      for (int t = 0; t < NF; t++)
        for (int v = 1; v < R + 1; v++) begin
          tw_cq02h[(c * NF + t) * R + v - 1] = 1'b0;
          for (int n = 1; n < S + 1; n++)
            tw_cq02h[(c * NF + t) * R + v - 1] = tw_cq02h[(c * NF + t) * R + v - 1] | (nwh_cq01h[n] & tp_cq02h[(c * NT + (n - 1) * NF + t) * R + v - 1]);
        end
    end
  logic [S*4*R-1:0] sg_cq02h;
  always_comb
    for (int s = 0; s < S; s++)
      for (int c = 0; c < 4; c++)
        for (int v = 1; v < R + 1; v++) begin
          sg_cq02h[(s * 4 + c) * R + v - 1] = 1'b0;
          for (int f = 0; f < 2; f++)
            for (int w = 0; w < R + 1; w++)
              sg_cq02h[(s * 4 + c) * R + v - 1] = sg_cq02h[(s * 4 + c) * R + v - 1] |
                  ((first_w_cq01h[s] == (f != 0)) & ue_cq01h[(s * 4 + c) * (R + 1) + w] & tw_cq02h[(c * NF + f * (R + 1) + w) * R + v - 1] &
                   with_w_cq01h[s] & ~rbusy_cq01h);
        end
  // The allowances to hold next cycle: min(R, the shares' sum). The shares
  // split the pool whole among the warps with a head, so the sum is the pool
  // (the names' plus those warps' unmet floors); none under a restore.
  logic [S*R-1:0]     uw_cq01h;                // each warp's floor (a warp with a head), a thermometer to R
  logic [R-1:0]       ut_cq01h;                // and summed
  logic [4*R-1:0]     held_nx_cq02h;           // a thermometer
  logic [4*(R+1)-1:0] he_nx_cq02h;             // and one-hot
  always_comb
    for (int c = 0; c < 4; c++) begin
      for (int s = 0; s < S; s++)
        for (int v = 1; v < R + 1; v++)
          uw_cq01h[s * R + v - 1] = with_w_cq01h[s] & (c == 2 ? unmet_g_cq01h[s * LU +: LU] >= LU'(v) :
                                           c == 3 ? unmet_p_cq01h[s * LU +: LU] >= LU'(v) : 1'b0);
      ut_cq01h = tsum(uw_cq01h);
      held_nx_cq02h[c * R +: R] = tadd(pt_cq02h[c * (R + 1) + 1 +: R], ut_cq01h) & {R{(nw_cq01h != '0) & ~rbusy_cq01h}};
      for (int h = 0; h < R + 1; h++) begin
        he_nx_cq02h[c * (R + 1) + h] = 1'b1;
        if (h > 0) he_nx_cq02h[c * (R + 1) + h] = he_nx_cq02h[c * (R + 1) + h] & held_nx_cq02h[c * R + h - 1];
        if (h < R) he_nx_cq02h[c * (R + 1) + h] = he_nx_cq02h[c * (R + 1) + h] & ~held_nx_cq02h[c * R + h];
      end
    end

  // -- The registered half: next cycle's fits ------------------------------------
  // Per slot, take k and length m (head k + m - 1 the last): the heads are
  // there, none before the last is serial, the ROB room covers k + m, the
  // run takes at most R of each credit, and each credit's need, one-hot
  // from the heads alone, picks the share's bit that must be set.
  logic [S*(R+1)*R-1:0] fits_nx_cq01h;
  logic [LB+LT:0]       room_cq01h;
  logic [2*R:0]         rm_cq01h;              // room >= n
  logic                 ok_cq02h, ser_cq01h;
  logic [4*4-1:0]       nd_cq01h;              // each credit's need over the run
  logic [PA-1:0]        a_cq01h;
  always_comb
    for (int s = 0; s < S; s++) begin
      room_cq01h = (LB + LT + 1)'(run_cq01h[s * LB +: LB]) +
             (reach_cq01h[s] ? (LB + LT + 1)'(ret_cq01h[s * LT +: LT]) : '0);
      for (int n = 0; n < 2 * R + 1; n++) rm_cq01h[n] = room_cq01h >= (LB + LT + 1)'(n);
      for (int k = 0; k < R + 1; k++) begin
        nd_cq01h = '0;
        ser_cq01h = 1'b0;
        for (int m = 1; m < R + 1; m++) begin
          ok_cq02h = 1'b0;
          if (k + m - 1 < H) begin
            a_cq01h     = ha_cq01h[(s * H + k + m - 1) * PA +: PA];
            nd_cq01h[0 +: 4]  = nd_cq01h[0 +: 4] + 4'(a_cq01h[0]) + 4'(a_cq01h[2]);
            nd_cq01h[4 +: 4]  = nd_cq01h[4 +: 4] + 4'(a_cq01h[1]);
            nd_cq01h[8 +: 4]  = nd_cq01h[8 +: 4] + 4'(a_cq01h[3]);
            nd_cq01h[12 +: 4] = nd_cq01h[12 +: 4] + 4'(a_cq01h[4]);
            ok_cq02h = hv_cq01h[s * H + k + m - 1] && !ser_cq01h && rm_cq01h[k + m] && nd_cq01h[0 +: 4] < 4'(R + 1) &&
                       sg_fit(sg_cq02h[(s * 4 + 0) * R +: R], nd_cq01h[0 +: 4]) &&
                       sg_fit(sg_cq02h[(s * 4 + 1) * R +: R], nd_cq01h[4 +: 4]) &&
                       sg_fit(sg_cq02h[(s * 4 + 2) * R +: R], nd_cq01h[8 +: 4]) &&
                       sg_fit(sg_cq02h[(s * 4 + 3) * R +: R], nd_cq01h[12 +: 4]);
            ser_cq01h = ser_cq01h | a_cq01h[6];
          end
          fits_nx_cq01h[(s * (R + 1) + k) * R + m - 1] = ok_cq02h;
        end
      end
    end

  // Each warp's writer prefix counts past each take k, registered with the
  // fits.
  logic [S*(R+1)*2*R*R-1:0] wc_cq01h;
  logic [R-1:0]             wn_cq01h;
  always_comb
    for (int s = 0; s < S; s++)
      for (int k = 0; k < R + 1; k++)
        for (int b = 0; b < 2; b++) begin
          wn_cq01h = '0;
          for (int m = 1; m < R + 1; m++) begin
            if (k + m - 1 < H && ha_cq01h[(s * H + (k + m - 1) % H) * PA + 3 + b]) wn_cq01h = {wn_cq01h[R-2:0], 1'b1};
            wc_cq01h[(((s * (R + 1) + k) * 2 + b) * R + m - 1) * R +: R] = wn_cq01h;
          end
        end

  // -- The registers -------------------------------------------------------------
  // A squash at this edge empties its slot's fits as they are registered:
  // decq still shows its heads now (its registered flush masks them from the
  // next cycle). The block of the next cycle is registered from the leads.
  logic [S-1:0]       sel_nx_cq01h, blk_nx_cq00h;
  logic [S*(R+1)-1:0] tko_nx_cq01h;
  always_comb
    for (int s = 0; s < S; s++) begin
      blk_nx_cq00h[s] = hold_l_cq00h[s] | rbusy_l_cq00h | sq_l_cq00h[s];
      for (int k = 0; k < R + 1; k++)
        tko_nx_cq01h[s * (R + 1) + k] = (k == 0 || tk_c_cq02h[((k + R - 1) % R) * S + s]) &&
                                  (k == R || !tk_c_cq02h[(k % R) * S + s]);
      // Any take needs the slot's first head now (heads are contiguous).
      sel_nx_cq01h[s] = hv_cq01h[s * H];
    end
  // What changes a slot's fits at the next edge (OA's rev 174), folded per
  // slot into one flop: its heads (decq's arrivals, its take now or in
  // transit, a squash), and, while it has a head, any warp's heads (the
  // shares' count and rotation), its ROB room, rename's pool or floors, a
  // restore starting or ending, the allowances held, and the rotation where
  // the split has a remainder the first warp takes.
  logic [S-1:0] hd_ev_cq02h;
  logic         he_chg_cq02h, rem_cq02h, any_ev_cq02h;
  always_comb begin
    for (int s = 0; s < S; s++)
      hd_ev_cq02h[s] = dq_ev_cq01h[s] | take_cq02h[s * R] | ~tko_cq02h[s * (R + 1)] | sq_l_cq00h[s] | sq_cq01h[s];
    any_ev_cq02h = |hd_ev_cq02h;
    he_chg_cq02h = he_en_cq02h && he_nx_cq02h != he_cq02h;
    rem_cq02h = 1'b0;
    for (int c = 0; c < 4; c++)
      for (int n = 2; n < S + 1; n++)
        for (int p = 0; p < PM + 1; p++)
          if (p % n != 0 && p / n < R) rem_cq02h = rem_cq02h | (nwh_cq01h[n] & pe_cq02h[c * (PM + 1) + p] & prio_en_cq01h);
  end
  logic [S-1:0] chg_nx_cq02h;
  always_comb
    for (int s = 0; s < S; s++)
      chg_nx_cq02h[s] = hd_ev_cq02h[s] | (hv_cq01h[s * H] & (any_ev_cq02h | rob_en_cq01h[s] | pool_en_cq01h |
                                                 (rbusy_l_cq00h ^ rbusy_cq01h) | he_chg_cq02h | rem_cq02h));
  // The leads and the change bits, written every cycle (the module's
  // allowance and its waiver): the restore, each slot's block, squash and
  // change.
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      rbusy_cq01h <= 1'b0;
      sq_cq01h    <= '0;
      blk_cq01h   <= '0;
      chg_cq02h   <= '0;
    end else begin
      rbusy_cq01h <= rbusy_l_cq00h;
      sq_cq01h    <= sq_l_cq00h;
      blk_cq01h   <= blk_nx_cq00h;
      chg_cq02h   <= chg_nx_cq02h;
    end
  end
  // Local clock gating, every enable from this module's flops (CG-5): a
  // slot's fits and take-enable on its change bit; the allowances held on
  // any slot's; the take register while some warp takes or took; the
  // rotation unless a restore owns the ports.
  logic [S-1:0] fits_en_cq02h;
  logic         he_en_cq02h, tko_en_cq02h, prio_en_cq01h;
  always_comb begin
    fits_en_cq02h = chg_cq02h;
    he_en_cq02h   = |chg_cq02h;
    tko_en_cq02h  = 1'b0;
    for (int s = 0; s < S; s++) tko_en_cq02h = tko_en_cq02h | run_t_cq02h[s * R] | ~tko_cq02h[s * (R + 1)];
    prio_en_cq01h = ~rbusy_cq01h;
  end
  for (genvar gs = 0; gs < S; gs++) begin : g_fits
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h) begin
        fits_cq02h[gs * (R + 1) * R +: (R + 1) * R] <= '0;
        fitsw_cq02h[gs * (R + 1) * R +: (R + 1) * R] <= '0;
        wc_cq02h[gs * (R + 1) * 2 * R * R +: (R + 1) * 2 * R * R] <= '0;
        sel_q_cq02h[gs]                             <= 1'b0;
      end else if (fits_en_cq02h[gs]) begin
        fits_cq02h[gs * (R + 1) * R +: (R + 1) * R] <= fits_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R] & {((R + 1) * R){~sq_cq01h[gs]}};
        fitsw_cq02h[gs * (R + 1) * R +: (R + 1) * R] <= fits_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R] & {((R + 1) * R){~sq_cq01h[gs]}};
        wc_cq02h[gs * (R + 1) * 2 * R * R +: (R + 1) * 2 * R * R] <= wc_cq01h[gs * (R + 1) * 2 * R * R +: (R + 1) * 2 * R * R];
        sel_q_cq02h[gs]                             <= sel_nx_cq01h[gs];
      end
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      for (int c = 0; c < 4; c++) he_cq02h[c * (R + 1) +: R + 1] <= (R + 1)'(1);
    end else if (he_en_cq02h) begin
      he_cq02h <= he_nx_cq02h;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      for (int s = 0; s < S; s++) tko_cq02h[s * (R + 1) +: R + 1] <= (R + 1)'(1);
      for (int s = 0; s < S; s++) tkow_cq02h[s * (R + 1) +: R + 1] <= (R + 1)'(1);
    end else if (tko_en_cq02h) begin
      tko_cq02h  <= tko_nx_cq01h;
      tkow_cq02h <= tko_nx_cq01h;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      prio_cq02h  <= S'(1);
      priod_cq02h <= S'(1);
    end else if (prio_en_cq01h) begin
      prio_cq02h  <= {prio_cq02h[S-2:0], prio_cq02h[S-1]};
      priod_cq02h <= {priod_cq02h[S-2:0], priod_cq02h[S-1]};
    end
  end

  // decq's take-enable covers every slot that takes (deq_sel_covers).
  logic [S-1:0] tk_any_cq02h;
  always_comb for (int s = 0; s < S; s++) tk_any_cq02h[s] = take_cq02h[s * R];
  `CCV_ASSERT(sel_covers, (tk_any_cq02h & ~sel_cq02h) == '0)
endmodule
`undef CCV_CLK
`undef CCV_RST
