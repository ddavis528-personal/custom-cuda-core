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
// Each credit arrives as rename's pool register (OA's rev 171 (a)) and a
// correction (OI-74, OA's revs 215, 216): rename's counters take the go's
// take a cycle late, so the register is the lagged counter less its floors
// owed (the names', from held before last cycle's takes), saturated at 6R,
// and the correction is last cycle's take of that credit, one-hot to R,
// registered too. This module subtracts both with the allowances in force,
// from its own register of them: the correction joins that one-hot, so it
// takes the same compares.
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
// 6 serial, 7 a CAS pair's first slot (TI-39), 8 an atomic (AR-21: A2's RCU
// entry and A3's MIU entry beside A1's, and two GPR names, its destination's
// or a temporary's and N's). A pair's second slot needs nothing: its needs
// are its first's.
//
// The CAS pair (OI-79 (b), OA's rev 239): its two slots are a warp's heads r
// and r + 1, taken in consecutive rounds, both or neither. A fit never ends
// on a first slot (the registered half cuts the run back before it), so a
// pair's needs are counted together; and the take stops before the first
// pair the width would split, its first slot's lane taken and its second's
// not: that lane and every later one are dropped. Which head is a first
// slot is registered with the fits (OA's fallback: the split stop in the
// registered half), so only the compare against the width is on the take
// path. A credit's take in a cycle is at most R: a class's allocation
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
  parameter int PA = 9,                  // admission bits a head
  parameter int LU = 5,                  // an unmet floor's width
  parameter int LB = 6,                  // a ROB run's width
  parameter int LT = 3,                  // a cycle's retirements' width
  localparam int H  = 2 * R - 1,         // decq's heads a slot
  localparam int PM = 4 * R,             // a pool's thermometer, saturated
  localparam int XM = PM + 2 * R,        // a credit less its floors owed, saturated (with the correction, below)
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
  input  logic [4*(R+1)-1:0] pl_cq01h,    // each credit's correction: last cycle's take of it, one-hot 0 to R
  input  logic [S*LU-1:0]   unmet_g_cq01h,
  input  logic [S*LU-1:0]   unmet_p_cq01h,
  // And each slot's room to its ceiling, per class (GPR rows, predicates),
  // saturated: arch + ceiling - held (OI-73 (3), OA's rev 207).
  input  logic [S*LU-1:0]   room_g_cq01h,
  input  logic [S*LU-1:0]   room_p_cq01h,
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
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end


  `CCV_ASSERT_KNOWN(rbusy_known, rbusy_l_cq00h)
  `CCV_ASSERT_KNOWN(hold_known, hold_l_cq00h)
  `CCV_ASSERT_KNOWN(sq_known, sq_l_cq00h)

  // The registered state. What the take reads is kept three times (NGD-7):
  // for the take (required at 14); for the lanes and the writers before
  // each (w: 16.7, 17); for the writer totals and the take register (x: 21,
  // a flop). The rotation has a fourth copy, for the shares (d).
  (* keep *) logic [S*(R+1)*R-1:0] fits_cq02h;   // per slot and take k, a thermometer of the run that fits
  (* keep *) logic [S*(R+1)*R-1:0] fitsw_cq02h;  // its copies
  (* keep *) logic [S*(R+1)*R-1:0] fitsx_cq02h;
  // Per slot, take k, class b (GPR, predicate) and length m (1 to R): the
  // writers among the m heads past k, a thermometer.
  logic [S*(R+1)*2*R*R-1:0] wc_cq02h;
  (* keep *) logic [S*(R+1)-1:0] tko_cq02h;     // each slot's take this cycle, one-hot
  (* keep *) logic [S*(R+1)-1:0] tkow_cq02h;    // its copies
  (* keep *) logic [S*(R+1)-1:0] tkox_cq02h;
  // Per slot and take k, which of the R heads past k is a CAS pair's first
  // slot (OI-79 (b), OA's rev 239: the split stop in the registered half),
  // registered with the fits, and its copies.
  (* keep *) logic [S*(R+1)*R-1:0] pf_cq02h;
  (* keep *) logic [S*(R+1)*R-1:0] pfw_cq02h;
  (* keep *) logic [S*(R+1)*R-1:0] pfx_cq02h;
  logic [S-1:0]         sel_q_cq02h;     // the slot had a head
  logic [4*(R+1)-1:0]   he_cq02h;        // per credit, min(R, the allowances in force), one-hot
  (* keep *) logic [S-1:0] prio_cq02h;   // the rotation's first slot, one-hot, for the take
  (* keep *) logic [S-1:0] priow_cq02h;  // and its copies
  (* keep *) logic [S-1:0] priox_cq02h;
  (* keep *) logic [S-1:0] priod_cq02h;  // and for the shares
  logic                 rbusy_cq01h;     // the restore's lead, registered
  logic [S-1:0]         sq_cq01h;        // per slot, its squash at this edge (its lead, registered)
  (* keep *) logic [S-1:0] blk_cq01h;    // per slot, its block now: hold, restore or squash
  (* keep *) logic [S-1:0] blkw_cq01h;   // its copies
  (* keep *) logic [S-1:0] blkx_cq01h;
  logic [S-1:0]         chg_cq02h;       // per slot, some input its fits read changed at the last edge

  // -- The take ----------------------------------------------------------------
  // The take is formed three times, each from its own copies of the
  // registers it reads (NGD-7): the take itself (required at 14); the lanes
  // and the writers before each (16.7, 17); the writer totals and the take
  // register (21, a flop).
  //
  // Each warp's run, a thermometer: its fits at its own last take, none if
  // it is blocked.
  function automatic logic [S*R-1:0] run_of(input logic [S*(R+1)*R-1:0] f, input logic [S*(R+1)-1:0] t,
                                            input logic [S-1:0] b);
    for (int s = 0; s < S; s++)
      for (int j = 0; j < R; j++) begin
        run_of[s * R + j] = 1'b0;
        for (int k = 0; k < R + 1; k++) run_of[s * R + j] = run_of[s * R + j] | (f[(s * (R + 1) + k) * R + j] & t[s * (R + 1) + k] & ~b[s]);
      end
  endfunction
  // Slot q is before slot s in this cycle's rotation (from the flops alone).
  function automatic logic [S*S-1:0] bef_of(input logic [S-1:0] p);
    for (int s = 0; s < S; s++)
      for (int q = 0; q < S; q++) begin
        bef_of[s * S + q] = 1'b0;
        for (int f = 0; f < S; f++)
          if (p[f] && ((q - f + S) % S) < ((s - f + S) % S)) bef_of[s * S + q] = 1'b1;
      end
  endfunction
  // Candidate (r, s)'s other warps' terms: each warp's takes before it, the
  // smaller of its run and r + 1 for a warp before s in rotation, of its run
  // and r for the rest; each a slice of the warp's run. With s's own term
  // (r) they give its rank, summed in one tree.
  function automatic logic [S*R-1:0] terms_of(input logic [S*R-1:0] run, input logic [S*S-1:0] bf, input int r,
                                              input int s, input logic own);
    terms_of = '0;
    for (int q = 0; q < S; q++)
      for (int v = 0; v < R; v++)
        if (v < r)       terms_of[q * R + v] = run[q * R + v];
        else if (v == r) terms_of[q * R + v] = run[q * R + v] & bf[s * S + q];
    if (!own) terms_of[s * R +: R] = '0;
  endfunction
  // Taken: the warp has its r-th uop, so its own term is r, and the others'
  // sum below R - r (the closed form, for the take's depth).
  function automatic logic [R*S-1:0] tk_of(input logic [S*R-1:0] run, input logic [S*S-1:0] bf);
    logic [R-1:0] ot;
    for (int r = 0; r < R; r++)
      for (int s = 0; s < S; s++) begin
        ot = tsum(terms_of(run, bf, r, s, 1'b0));
        tk_of[r * S + s] = run[s * R + r] & (r == 0 || !ot[(R - 1 - r) % R]);
      end
  endfunction
  // Each candidate's first-slot bit: its warp's registered vector at its
  // take.
  function automatic logic [S*R-1:0] pr_of(input logic [S*(R+1)*R-1:0] pf, input logic [S*(R+1)-1:0] t);
    for (int s = 0; s < S; s++)
      for (int r = 0; r < R; r++) begin
        pr_of[s * R + r] = 1'b0;
        for (int k = 0; k < R + 1; k++) pr_of[s * R + r] = pr_of[s * R + r] | (pf[(s * (R + 1) + k) * R + r] & t[s * (R + 1) + k]);
      end
  endfunction
  // The cut (OI-79 (b)): a pair's first slot taken and its second not, the
  // width's split. Nothing from its lane on is taken: no candidate of a
  // later round, nor of its round in a warp not before its own. Which head
  // is a first slot is registered (pf, at the warp's take; OA's rev 239);
  // only the compare against the width is here. The candidates the cut
  // removes (a superset beyond the take is harmless).
  function automatic logic [R*S-1:0] st_of(input logic [R*S-1:0] tk, input logic [S*R-1:0] pr);
    for (int r = 0; r < R; r++)
      for (int s = 0; s < S; s++)
        st_of[r * S + s] = pr[s * R + r] & tk[r * S + s] & (r == R - 1 || !tk[((r + 1) % R) * S + s]);
  endfunction
  function automatic logic [R*S-1:0] cut_of(input logic [R*S-1:0] tk, input logic [S*R-1:0] pr,
                                            input logic [S*S-1:0] bf);
    logic [R*S-1:0] st;
    logic [R-1:0]   sr;                         // some warp's round r is cut
    st = st_of(tk, pr);
    for (int r = 0; r < R; r++) begin
      sr[r] = 1'b0;
      for (int s = 0; s < S; s++) sr[r] = sr[r] | st[r * S + s];
    end
    for (int v = 0; v < R; v++)
      for (int q = 0; q < S; q++) begin
        cut_of[v * S + q] = 1'b0;
        for (int r = 0; r < v; r++) if (sr[r]) cut_of[v * S + q] = 1'b1;
        for (int s = 0; s < S; s++) if (st[v * S + s] && !bf[s * S + q]) cut_of[v * S + q] = 1'b1;
      end
  endfunction

  // The take: per slot a thermometer.
  logic [S*R-1:0] run_t_cq02h;
  logic [S*S-1:0] bef_cq02h;
  logic [R*S-1:0] tk_c_cq02h, tk_a_cq02h;      // before the cut and after
  always_comb begin
    run_t_cq02h = run_of(fits_cq02h, tko_cq02h, blk_cq01h);
    bef_cq02h   = bef_of(prio_cq02h);
    tk_c_cq02h  = tk_of(run_t_cq02h, bef_cq02h);
    tk_a_cq02h  = tk_c_cq02h & ~cut_of(tk_c_cq02h, pr_of(pf_cq02h, tko_cq02h), bef_cq02h);
    for (int s = 0; s < S; s++)
      for (int r = 0; r < R; r++) take_cq02h[s * R + r] = tk_a_cq02h[r * S + s];
  end

  // The lanes, from the second copies: lane l is taken while the runs sum
  // past l and the cut is beyond it, and its uop is the candidate whose rank
  // is l.
  logic [S*R-1:0]   run_w_cq02h;
  logic [S*S-1:0]   befw_cq02h;
  logic [R*S-1:0]   tk_w_cq02h, cut_w_cq02h, st_w_cq02h;
  logic [R:0]       rq_cq02h;
  logic [R-1:0]     lv_cq02h;                  // the lanes the runs reach
  always_comb begin
    run_w_cq02h = run_of(fitsw_cq02h, tkow_cq02h, blkw_cq01h);
    befw_cq02h  = bef_of(priow_cq02h);
    tk_w_cq02h  = tk_of(run_w_cq02h, befw_cq02h);
    st_w_cq02h  = st_of(tk_w_cq02h, pr_of(pfw_cq02h, tkow_cq02h));
    cut_w_cq02h = cut_of(tk_w_cq02h, pr_of(pfw_cq02h, tkow_cq02h), befw_cq02h);
    lv_cq02h    = tsum(run_w_cq02h);
    lane_c_cq02h = '0;
    lane_v_cq02h = lv_cq02h;
    for (int r = 0; r < R; r++)
      for (int s = 0; s < S; s++) begin
        rq_cq02h = {tsum(terms_of(run_w_cq02h, befw_cq02h, r, s, 1'b1)), 1'b1};
        for (int l = 0; l < R; l++) begin
          lane_c_cq02h[(l * R + r) * S + s] = run_w_cq02h[s * R + r] & rq_cq02h[l] & ~rq_cq02h[l + 1] & ~cut_w_cq02h[r * S + s];
          // A cut's first slot at rank l or below empties lane l.
          if (st_w_cq02h[r * S + s] && !rq_cq02h[l + 1]) lane_v_cq02h[l] = 1'b0;
        end
      end
  end

  // The writer totals and the take register, from the third copies: the take
  // after the cut.
  logic [S*R-1:0] run_x_cq02h;
  logic [S*S-1:0] befx_cq02h;
  logic [R*S-1:0] tk_y_cq02h, tk_xw_cq02h;
  always_comb begin
    run_x_cq02h = run_of(fitsx_cq02h, tkox_cq02h, blkx_cq01h);
    befx_cq02h  = bef_of(priox_cq02h);
    tk_y_cq02h  = tk_of(run_x_cq02h, befx_cq02h);
    tk_xw_cq02h = tk_y_cq02h & ~cut_of(tk_y_cq02h, pr_of(pfx_cq02h, tkox_cq02h), befx_cq02h);
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
                  ({R{run_w_cq02h[q * R + v] && (v < r || befw_cq02h[s * S + q])}} & wcs_cq02h[((q * 2 + b) * (R + 1) + v + 1) * R +: R]);
          end
          wb_cq02h[((r * S + s) * 2 + b) * R +: R] = tsum(wq_cq02h);
        end
      // The writers taken: each warp's prefix count at its own take after
      // the cut, summed.
      for (int q = 0; q < S; q++) begin
        wtq_cq02h[q * R +: R] = '0;
        for (int m = 1; m < R + 1; m++)
          wtq_cq02h[q * R +: R] = wtq_cq02h[q * R +: R] |
            ({R{tk_xw_cq02h[(m - 1) * S + q]}} & wcs_cq02h[((q * 2 + b) * (R + 1) + m) * R +: R]);
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
  logic [S-1:0]   with_w_cq01h, first_w_cq02h;
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
    // The first warp with a head in rotation: none before it has one.
    for (int s = 0; s < S; s++) first_w_cq02h[s] = with_w_cq01h[s] && (befd_cq02h[s * S +: S] & with_w_cq01h) == '0;
  end
  // The pool, what no allowance in force holds: one-hot, pe[c][p], the
  // pool register is p beyond the allowances held (p = PM: PM or more; p =
  // 0: none beyond them, the register at or below them, as the model's
  // max(0, credit - held)); and
  // pt[c][v], it covers v or more beyond them, to R, for the next holding.
  logic [4*(PM+1)-1:0] pe_cq02h;
  logic [4*(R+1)-1:0]  pt_cq02h;
  logic [LX-1:0]       pxc_cq01h;   // this credit's pool register
  logic [2*R:0]        hk_cq02h;    // the allowances held and the correction, one-hot to 2R
  // Each correction is one-hot (or none, as its register stands before the
  // first reset edge, which this assertion sees).
  logic [3:0] pl_ok_cq01h;
  always_comb
    for (int c = 0; c < 4; c++) begin
      pl_ok_cq01h[c] = pl_cq01h[c * (R + 1) +: R + 1] == '0;
      for (int k = 0; k < R + 1; k++)
        if (pl_cq01h[c * (R + 1) +: R + 1] == (R + 1)'(1) << k) pl_ok_cq01h[c] = 1'b1;
    end
  `CCV_ASSERT(pl_one_hot, pl_ok_cq01h == '1)
  always_comb
    for (int c = 0; c < 4; c++) begin
      pxc_cq01h = px_cq01h[c * LX +: LX];
      hk_cq02h = '0;
      for (int h = 0; h < R + 1; h++)
        for (int k = 0; k < R + 1; k++)
          if (he_cq02h[c * (R + 1) + h] && pl_cq01h[c * (R + 1) + k]) hk_cq02h[h + k] = 1'b1;
      for (int p = 0; p < PM + 1; p++) begin
        pe_cq02h[c * (PM + 1) + p] = 1'b0;
        for (int h = 0; h < 2 * R + 1; h++)
          pe_cq02h[c * (PM + 1) + p] = pe_cq02h[c * (PM + 1) + p] |
              (hk_cq02h[h] & (p == PM ? pxc_cq01h >= LX'(p + h) : p == 0 ? pxc_cq01h <= LX'(h) : pxc_cq01h == LX'(p + h)));
      end
      for (int v = 0; v < R + 1; v++) begin
        pt_cq02h[c * (R + 1) + v] = 1'b0;
        for (int h = 0; h < 2 * R + 1; h++)
          pt_cq02h[c * (R + 1) + v] = pt_cq02h[c * (R + 1) + v] | (hk_cq02h[h] & (pxc_cq01h >= LX'(v + h)));
      end
    end
  // A warp's share at pool p: floor(p / n), the first's p - (n - 1) floor(p
  // / n), the names' plus its unmet floor u.
  function automatic int share_of(input int p, input int n, input int fst, input int u);
    share_of = (fst != 0 ? p - (n - 1) * (p / n) : p / n) + u;
  endfunction
  // A class's share covers its n heads' needs: its thermometer at n (none
  // needed when n is 0).
  // A need past R never fits: a cycle takes at most R of a credit (an
  // atomic's two MIU rows and two names can carry a run past it).
  function automatic logic sg_fit(input logic [R-1:0] t, input logic [3:0] n);
    sg_fit = n == 4'd0;
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
                  ((first_w_cq02h[s] == (f != 0)) & ue_cq01h[(s * 4 + c) * (R + 1) + w] & tw_cq02h[(c * NF + f * (R + 1) + w) * R + v - 1] &
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
  // run takes at most R of each credit, each credit's need, one-hot from
  // the heads alone, picks the share's bit that must be set, and the names
  // of the k heads taken now and the m after fit the warp's room to its
  // ceiling (as the ROB room covers k + m).
  logic [S*(R+1)*R-1:0] fits_nx_cq01h;
  logic [LB+LT:0]       room_cq01h;
  logic [2*R:0]         rm_cq01h;              // room >= n
  logic                 ok_cq02h, ser_cq01h;
  logic [3:0]           npf_cq01h;             // pairs' first slots before the last head
  logic [R-1:0]         okm_cq02h;             // each length's fit, before the cut-back
  logic [4*4-1:0]       nd_cq01h;              // each credit's need over the run
  logic [PA-1:0]        a_cq01h;
  logic [2*4-1:0]       pre_cq01h;             // the names of the k heads taken now, GPR and predicate
  always_comb begin
    fits_nx_cq01h = '0;
    a_cq01h       = '0;
    npf_cq01h     = '0;
    okm_cq02h     = '0;
    for (int s = 0; s < S; s++) begin
      room_cq01h = (LB + LT + 1)'(run_cq01h[s * LB +: LB]) +
             (reach_cq01h[s] ? (LB + LT + 1)'(ret_cq01h[s * LT +: LT]) : '0);
      for (int n = 0; n < 2 * R + 1; n++) rm_cq01h[n] = room_cq01h >= (LB + LT + 1)'(n);
      for (int k = 0; k < R + 1; k++) begin
        pre_cq01h = '0;
        for (int h = 0; h < k; h++)
          if (h < H) pre_cq01h = pre_cq01h + {4'(ha_cq01h[(s * H + h) * PA + 4]),
                                              ha_cq01h[(s * H + h) * PA + 8] ? 4'd2 : 4'(ha_cq01h[(s * H + h) * PA + 3])};
        nd_cq01h = '0;
        ser_cq01h = 1'b0;
        for (int m = 1; m < R + 1; m++) begin
          ok_cq02h = 1'b0;
          if (k + m - 1 < H) begin
            a_cq01h     = ha_cq01h[(s * H + k + m - 1) * PA +: PA];
            nd_cq01h[0 +: 4]  = nd_cq01h[0 +: 4] + 4'(a_cq01h[0]) + 4'(a_cq01h[2]) + 4'(a_cq01h[8]);
            nd_cq01h[4 +: 4]  = nd_cq01h[4 +: 4] + 4'(a_cq01h[1]) + 4'(a_cq01h[8]);
            nd_cq01h[8 +: 4]  = nd_cq01h[8 +: 4] + (a_cq01h[8] ? 4'd2 : 4'(a_cq01h[3]));
            nd_cq01h[12 +: 4] = nd_cq01h[12 +: 4] + 4'(a_cq01h[4]);
            // ROB entries, not heads: a pair's second slot takes none (OI-79).
            npf_cq01h = '0;
            for (int h = 0; h < k + m - 1; h++)
              if (h < H) npf_cq01h = npf_cq01h + 4'(ha_cq01h[(s * H + h) * PA + 7]);
            ok_cq02h = hv_cq01h[s * H + k + m - 1] && !ser_cq01h && rm_cq01h[k + m - 32'(npf_cq01h)] &&
                       sg_fit(sg_cq02h[(s * 4 + 0) * R +: R], nd_cq01h[0 +: 4]) &&
                       sg_fit(sg_cq02h[(s * 4 + 1) * R +: R], nd_cq01h[4 +: 4]) &&
                       sg_fit(sg_cq02h[(s * 4 + 2) * R +: R], nd_cq01h[8 +: 4]) &&
                       sg_fit(sg_cq02h[(s * 4 + 3) * R +: R], nd_cq01h[12 +: 4]) &&
                       room_g_cq01h[s * LU +: LU] >= LU'(pre_cq01h[0 +: 4]) + LU'(nd_cq01h[8 +: 4]) &&
                       room_p_cq01h[s * LU +: LU] >= LU'(pre_cq01h[4 +: 4]) + LU'(nd_cq01h[12 +: 4]);
            ser_cq01h = ser_cq01h | a_cq01h[6];
          end
          okm_cq02h[m - 1] = ok_cq02h;
        end
        // The cut-back (OI-79 (b)): a run never ends on a pair's first slot.
        // The second carries no needs, takes no ROB entry and is never
        // serial, so where head m is a first, m + 1 fits exactly when m does
        // and the second is a head within the width: from decq's bits alone,
        // beside the fit's own terms.
        for (int m = 1; m < R + 1; m++)
          fits_nx_cq01h[(s * (R + 1) + k) * R + m - 1] = okm_cq02h[m - 1] &
              ~(k + m - 1 < H && ha_cq01h[(s * H + (k + m - 1) % H) * PA + 7] &&
                (m == R || k + m >= H || !hv_cq01h[s * H + (k + m) % H]));
      end
    end
  end

  // Each warp's first slots past each take k (OI-79 (b)), registered with
  // the fits.
  logic [S*(R+1)*R-1:0] pf_nx_cq01h;
  always_comb
    for (int s = 0; s < S; s++)
      for (int k = 0; k < R + 1; k++)
        for (int r = 0; r < R; r++)
          pf_nx_cq01h[(s * (R + 1) + k) * R + r] = k + r < H && ha_cq01h[(s * H + (k + r) % H) * PA + 7];

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
        // The take after the pair cut (its copy): decq's heads move by it alone.
        tko_nx_cq01h[s * (R + 1) + k] = (k == 0 || tk_xw_cq02h[((k + R - 1) % R) * S + s]) &&
                                  (k == R || !tk_xw_cq02h[(k % R) * S + s]);
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
      hd_ev_cq02h[s] = dq_ev_cq01h[s] | tk_y_cq02h[s] | ~tko_cq02h[s * (R + 1)] | sq_l_cq00h[s] | sq_cq01h[s];   // the take before the cut, a superset
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
      blkw_cq01h  <= '0;
      blkx_cq01h  <= '0;
      chg_cq02h   <= '0;
    end else begin
      rbusy_cq01h <= rbusy_l_cq00h;
      sq_cq01h    <= sq_l_cq00h;
      blk_cq01h   <= blk_nx_cq00h;
      blkw_cq01h  <= blk_nx_cq00h;
      blkx_cq01h  <= blk_nx_cq00h;
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
        fitsx_cq02h[gs * (R + 1) * R +: (R + 1) * R] <= '0;
        wc_cq02h[gs * (R + 1) * 2 * R * R +: (R + 1) * 2 * R * R] <= '0;
        pf_cq02h[gs * (R + 1) * R +: (R + 1) * R]   <= '0;
        pfw_cq02h[gs * (R + 1) * R +: (R + 1) * R]  <= '0;
        pfx_cq02h[gs * (R + 1) * R +: (R + 1) * R]  <= '0;
        sel_q_cq02h[gs]                             <= 1'b0;
      end else if (fits_en_cq02h[gs]) begin
        fits_cq02h[gs * (R + 1) * R +: (R + 1) * R] <= fits_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R] & {((R + 1) * R){~sq_cq01h[gs]}};
        fitsw_cq02h[gs * (R + 1) * R +: (R + 1) * R] <= fits_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R] & {((R + 1) * R){~sq_cq01h[gs]}};
        fitsx_cq02h[gs * (R + 1) * R +: (R + 1) * R] <= fits_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R] & {((R + 1) * R){~sq_cq01h[gs]}};
        wc_cq02h[gs * (R + 1) * 2 * R * R +: (R + 1) * 2 * R * R] <= wc_cq01h[gs * (R + 1) * 2 * R * R +: (R + 1) * 2 * R * R];
        pf_cq02h[gs * (R + 1) * R +: (R + 1) * R]   <= pf_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R];
        pfw_cq02h[gs * (R + 1) * R +: (R + 1) * R]  <= pf_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R];
        pfx_cq02h[gs * (R + 1) * R +: (R + 1) * R]  <= pf_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R];
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
      for (int s = 0; s < S; s++) tkox_cq02h[s * (R + 1) +: R + 1] <= (R + 1)'(1);
    end else if (tko_en_cq02h) begin
      tko_cq02h  <= tko_nx_cq01h;
      tkow_cq02h <= tko_nx_cq01h;
      tkox_cq02h <= tko_nx_cq01h;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      prio_cq02h  <= S'(1);
      priow_cq02h <= S'(1);
      priox_cq02h <= S'(1);
      priod_cq02h <= S'(1);
    end else if (prio_en_cq01h) begin
      prio_cq02h  <= {prio_cq02h[S-2:0], prio_cq02h[S-1]};
      priow_cq02h <= {priow_cq02h[S-2:0], priow_cq02h[S-1]};
      priox_cq02h <= {priox_cq02h[S-2:0], priox_cq02h[S-1]};
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
