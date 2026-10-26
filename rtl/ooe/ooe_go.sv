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
// owed (the names', from held before last cycle's takes), saturated at 6R + 2,
// and the correction is last cycle's take of that credit, one-hot to R,
// registered too. This module subtracts both with the allowances in force,
// from its own register of them: the correction joins that one-hot, so it
// takes the same compares.
//
// The take is parallel (rev 171 (c)): candidate (j, s), warp s's head j,
// is taken while its rank, the uops before it in lane order, leaves its
// unit's last lane below R; a warp's take is its taken candidates, a
// thermometer. Ranks are sums of thermometers saturated at R, added in
// trees. The fits are balanced (rev 171 (d)): each credit's pool is a
// thermometer, each warp's share one too, and fits_s[k] at length m is one
// AND over thermometer compares of the run's needs, each formed from the
// heads alone.
//
// Each head's admission bits are decq's (the payload's low PA): bit 0 RCU, 1
// MIU, 2 copy (a second RCU entry), 3 GPR write, 4 predicate write, 5 branch,
// 6 serial, 7 a pair's first slot, 8 an atomic's slot (OI-80 (d), DA's rev
// 94: every atomic is two slots, one row a class and one name each; the
// first carries A2's RCU row, the second the copy's).
//
// The pair (OI-84 (a), OA's rev 264): its two slots are a warp's heads j
// and j + 1, one unit of weight two, in adjacent lanes. The interleave is
// over units: round u takes each warp's u-th unit, the warps from the
// rotation's first, so a pair's second takes the lane after its first. A
// candidate's rank is each other warp's heads in its units before u (and
// in unit u, for a warp before it in rotation), and its own heads before
// it. A fit never ends on a first slot, so a unit is whole in a run, and a
// pair is taken while its second's lane is below R: no pair is split, and
// the rotation's first warp always takes its first unit, so a warp whose
// heads are all pairs is never starved. Which head is a first slot and
// each head's unit are registered with the fits, per take. A credit's take
// in a cycle is at most R: a class's allocation ports, a name per uop.
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
  localparam int PM = 4 * R + 2,         // a pool's thermometer, saturated (exact through the first warp's reserve of 2)
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

  // A head's unit past a take (OI-84 (a)): bit ui(v, u), u < v, head v's
  // unit is u or below (a pair is one unit: its second's is its first's).
  localparam int NU = R * (R - 1) / 2;
  function automatic int ui(input int v, input int u);
    ui = v * (v - 1) / 2 + u;
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
  // Per slot and take k, which of the R heads past k is a pair's first slot
  // (OI-84 (a)), registered with the fits, and its copies.
  (* keep *) logic [S*(R+1)*R-1:0] pf_cq02h;
  (* keep *) logic [S*(R+1)*R-1:0] pfw_cq02h;
  (* keep *) logic [S*(R+1)*R-1:0] pfx_cq02h;
  // Per slot and take k, each head's unit (ui), registered with the fits,
  // and its copies.
  (* keep *) logic [S*(R+1)*NU-1:0] ut_cq02h;
  (* keep *) logic [S*(R+1)*NU-1:0] utw_cq02h;
  (* keep *) logic [S*(R+1)*NU-1:0] utx_cq02h;
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
  // Head v's unit is u or below, at the warp's take (registered, ut; u >= v
  // always).
  function automatic logic ut_at(input logic [S*(R+1)*NU-1:0] ut, input int s, input int k, input int v, input int u);
    // (the index kept in range where u is out of it: elaboration reads it)
    ut_at = u >= v ? 1'b1 : u < 0 ? 1'b0 : ut[(s * (R + 1) + k) * NU + (u >= 0 && u < v ? ui(v, u) : 0)];
  endfunction
  // Each warp's heads by unit (au[(s, v, u)]): head v is in the run and its
  // unit is u or below; at u = R - 1, the run. Each a thermometer over v.
  function automatic logic [S*R*R-1:0] au_of(input logic [S*(R+1)*R-1:0] f, input logic [S*(R+1)*NU-1:0] ut,
                                             input logic [S*(R+1)-1:0] t, input logic [S-1:0] b);
    for (int s = 0; s < S; s++)
      for (int v = 0; v < R; v++)
        for (int u = 0; u < R; u++) begin
          au_of[(s * R + v) * R + u] = 1'b0;
          for (int k = 0; k < R + 1; k++)
            au_of[(s * R + v) * R + u] = au_of[(s * R + v) * R + u] |
                (f[(s * (R + 1) + k) * R + v] & t[s * (R + 1) + k] & ~b[s] & ut_at(ut, s, k, v, u));
        end
  endfunction
  // Unit u of warp s: the other warps' terms, each warp's heads in its units
  // before u, and in its unit u too for a warp before s in rotation; each a
  // thermometer (the run never splits a pair, so a unit is whole in it).
  function automatic logic [S*R-1:0] tu_of(input logic [S*R*R-1:0] au, input logic [S*S-1:0] bf, input int u, input int s);
    for (int q = 0; q < S; q++)
      for (int v = 0; v < R; v++)
        tu_of[q * R + v] = q != s && ((u > 0 && au[(q * R + v) * R + (u + R - 1) % R]) || (au[(q * R + v) * R + u] && bf[s * S + q]));
  endfunction
  // Each head's unit, at the warp's take: us[(s, j, u)], one-hot over u <= j.
  function automatic logic [S*R*R-1:0] us_of(input logic [S*(R+1)*NU-1:0] ut, input logic [S*(R+1)-1:0] t);
    for (int s = 0; s < S; s++)
      for (int j = 0; j < R; j++)
        for (int u = 0; u < R; u++) begin
          us_of[(s * R + j) * R + u] = 1'b0;
          for (int k = 0; k < R + 1; k++)
            if (u <= j)
              us_of[(s * R + j) * R + u] = us_of[(s * R + j) * R + u] |
                  (t[s * (R + 1) + k] & ut_at(ut, s, k, j, u) & ~ut_at(ut, s, k, j, u - 1));
        end
  endfunction
  // And with its kind, in its run: zs[(s, j, u, f)], head j in the run, its
  // unit u, a pair's first slot (f 1) or not.
  function automatic logic [S*R*R*2-1:0] zs_of(input logic [S*(R+1)*R-1:0] fi, input logic [S*(R+1)*NU-1:0] ut,
                                               input logic [S*(R+1)*R-1:0] pf, input logic [S*(R+1)-1:0] t,
                                               input logic [S-1:0] b);
    for (int s = 0; s < S; s++)
      for (int j = 0; j < R; j++)
        for (int u = 0; u < R; u++)
          for (int f = 0; f < 2; f++) begin
            zs_of[((s * R + j) * R + u) * 2 + f] = 1'b0;
            for (int k = 0; k < R + 1; k++)
              if (u <= j)
                zs_of[((s * R + j) * R + u) * 2 + f] = zs_of[((s * R + j) * R + u) * 2 + f] |
                    (fi[(s * (R + 1) + k) * R + j] & t[s * (R + 1) + k] & ~b[s] & (pf[(s * (R + 1) + k) * R + j] == (f != 0)) &
                     ut_at(ut, s, k, j, u) & ~ut_at(ut, s, k, j, u - 1));
          end
  endfunction
  // The others' sums, per warp and unit (ou[(s, u)]): a thermometer
  // saturated at R, each in one tree.
  function automatic logic [S*R*R-1:0] ou_of(input logic [S*R*R-1:0] au, input logic [S*S-1:0] bf);
    for (int s = 0; s < S; s++)
      for (int u = 0; u < R; u++) ou_of[(s * R + u) * R +: R] = tsum(tu_of(au, bf, u, s));
  endfunction
  // Taken (OI-84 (a), OA's rev 264): candidate (j, s), warp s's head j, in
  // its unit u, which is a single uop or a pair (weight two) in adjacent
  // lanes. Its rank is the others' sum at u and j, its own heads before it;
  // it is taken while its unit's last lane is below R: the others' sum below
  // R - j, or R - j - 1 for a pair's first slot. Units are taken in order,
  // so no pair is split and no cut is needed.
  function automatic logic [R*S-1:0] tk_of(input logic [S*R*R-1:0] ou, input logic [S*R*R*2-1:0] zs);
    for (int j = 0; j < R; j++)
      for (int s = 0; s < S; s++) begin
        tk_of[j * S + s] = 1'b0;
        for (int u = 0; u < R; u++)
          for (int f = 0; f < 2; f++)
            if (u <= j && j + f < R)
              tk_of[j * S + s] = tk_of[j * S + s] |
                  (zs[((s * R + j) * R + u) * 2 + f] & ~ou[(s * R + u) * R + R - 1 - j - f]);
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

  // The take: per slot a thermometer.
  logic [S*R-1:0]     run_t_cq02h;
  logic [S*S-1:0]     bef_cq02h;
  logic [S*R*R-1:0]   ou_t_cq02h;
  logic [R*S-1:0]     tk_a_cq02h;
  always_comb begin
    run_t_cq02h = run_of(fits_cq02h, tko_cq02h, blk_cq01h);
    bef_cq02h   = bef_of(prio_cq02h);
    ou_t_cq02h  = ou_of(au_of(fits_cq02h, ut_cq02h, tko_cq02h, blk_cq01h), bef_cq02h);
    tk_a_cq02h  = tk_of(ou_t_cq02h, zs_of(fits_cq02h, ut_cq02h, pf_cq02h, tko_cq02h, blk_cq01h));
    for (int s = 0; s < S; s++)
      for (int r = 0; r < R; r++) take_cq02h[s * R + r] = tk_a_cq02h[r * S + s];
  end

  // The lanes, from the second copies: lane l is taken while the runs sum
  // past l, and its uop is the candidate whose rank is l: the others' sum at
  // its unit, then its own heads before it. A pair's first slot at rank
  // R - 1 is not taken (its second would be past the width), and its lane
  // is empty: every candidate after it ranks R or more.
  logic [S*R-1:0]   run_w_cq02h, pfs_w_cq02h;
  logic [S*S-1:0]   befw_cq02h;
  logic [S*R*R-1:0] au_w_cq02h, ou_w_cq02h, us_w_cq02h;
  logic [R-1:0]     os_cq02h;                  // a candidate's others' sum at its unit
  logic [R:0]       rq_cq02h;                  // its rank, a thermometer (bit l: l or more)
  always_comb begin
    run_w_cq02h = run_of(fitsw_cq02h, tkow_cq02h, blkw_cq01h);
    befw_cq02h  = bef_of(priow_cq02h);
    au_w_cq02h  = au_of(fitsw_cq02h, utw_cq02h, tkow_cq02h, blkw_cq01h);
    ou_w_cq02h  = ou_of(au_w_cq02h, befw_cq02h);
    us_w_cq02h  = us_of(utw_cq02h, tkow_cq02h);
    pfs_w_cq02h = pr_of(pfw_cq02h, tkow_cq02h);
    lane_c_cq02h = '0;
    lane_v_cq02h = tsum(run_w_cq02h);
    for (int j = 0; j < R; j++)
      for (int s = 0; s < S; s++) begin
        os_cq02h = '0;
        for (int u = 0; u < R; u++) os_cq02h = os_cq02h | ({R{us_w_cq02h[(s * R + j) * R + u]}} & ou_w_cq02h[(s * R + u) * R +: R]);
        for (int l = 0; l < R + 1; l++) rq_cq02h[l] = l <= j ? 1'b1 : os_cq02h[(l - j - 1 + R) % R];
        for (int l = 0; l < R; l++)
          lane_c_cq02h[(l * R + j) * S + s] = run_w_cq02h[s * R + j] & rq_cq02h[l] & ~rq_cq02h[l + 1] &
                                              ~(pfs_w_cq02h[s * R + j] && l == R - 1);
        if (run_w_cq02h[s * R + j] && pfs_w_cq02h[s * R + j] && rq_cq02h[R - 1] && !rq_cq02h[R]) lane_v_cq02h[R - 1] = 1'b0;
      end
  end

  // The writer totals and the take register, from the third copies.
  logic [R*S-1:0] tk_xw_cq02h;
  always_comb
    tk_xw_cq02h = tk_of(ou_of(au_of(fitsx_cq02h, utx_cq02h, tkox_cq02h, blkx_cq01h), bef_of(priox_cq02h)),
                        zs_of(fitsx_cq02h, utx_cq02h, pfx_cq02h, tkox_cq02h, blkx_cq01h));

  // The writers before each candidate: its rank's sum, each warp's term the
  // writers among its heads before this one: its prefix count (at its own
  // last take) at the length its term takes, the OR over the lengths the
  // term reaches, as the counts rise with the length; the other warps' at
  // the candidate's unit; the totals, over the taken writers.
  logic [S*2*(R+1)*R-1:0] wcs_cq02h;           // per slot, class, length m (0 to R): its writers, a thermometer
  logic [S*R*S*2*R-1:0]   wu_cq02h;            // per slot s, unit u, warp q and class: q's writers before (u, s)
  logic [S*R-1:0]         tu_w_cq02h, wq_cq02h, wtq_cq02h;
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
    for (int s = 0; s < S; s++)
      for (int u = 0; u < R; u++) begin
        tu_w_cq02h = tu_of(au_w_cq02h, befw_cq02h, u, s);
        for (int q = 0; q < S; q++)
          for (int b = 0; b < 2; b++) begin
            wu_cq02h[(((s * R + u) * S + q) * 2 + b) * R +: R] = '0;
            for (int v = 0; v < R; v++)
              wu_cq02h[(((s * R + u) * S + q) * 2 + b) * R +: R] = wu_cq02h[(((s * R + u) * S + q) * 2 + b) * R +: R] |
                ({R{tu_w_cq02h[q * R + v]}} & wcs_cq02h[((q * 2 + b) * (R + 1) + v + 1) * R +: R]);
          end
      end
    for (int b = 0; b < 2; b++) begin
      for (int j = 0; j < R; j++)
        for (int s = 0; s < S; s++) begin
          for (int q = 0; q < S; q++) begin
            wq_cq02h[q * R +: R] = '0;
            if (q == s) begin
              for (int v = 0; v < j; v++)
                wq_cq02h[q * R +: R] = wq_cq02h[q * R +: R] |
                  ({R{run_w_cq02h[q * R + v]}} & wcs_cq02h[((q * 2 + b) * (R + 1) + v + 1) * R +: R]);
            end else begin
              for (int u = 0; u < R; u++)
                wq_cq02h[q * R +: R] = wq_cq02h[q * R +: R] |
                  ({R{us_w_cq02h[(s * R + j) * R + u]}} & wu_cq02h[(((s * R + u) * S + q) * 2 + b) * R +: R]);
            end
          end
          wb_cq02h[((j * S + s) * 2 + b) * R +: R] = tsum(wq_cq02h);
        end
      // The writers taken: each warp's prefix count at its own take, summed.
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
  logic [4*(PM+1)-1:0] pth_cq02h;   // the pool is p or more: a thermometer (pth[c][0] is always set)
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
      // The pool saturates at 0 below the allowances held: 0 or more always.
      pth_cq02h[c * (PM + 1)] = |hk_cq02h;
      for (int p = 1; p < PM + 1; p++) begin
        pth_cq02h[c * (PM + 1) + p] = 1'b0;
        for (int h = 0; h < 2 * R + 1; h++)
          pth_cq02h[c * (PM + 1) + p] = pth_cq02h[c * (PM + 1) + p] | (hk_cq02h[h] & (pxc_cq01h >= LX'(p + h)));
      end
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
  // A warp's share at pool p: the warp first in rotation takes h = min(d,
  // p) first, d its head's need (OI-80's liveness rule, OA's rev 244); of
  // the rest q, each floor(q / n), the first q - (n - 1) floor(q / n) and h;
  // the names' plus its unmet floor u.
  function automatic int share_of(input int p, input int n, input int fst, input int u, input int d);
    int h, q;
    h = d < p ? d : p;
    q = p - h;
    share_of = (fst != 0 ? h + q - (n - 1) * (q / n) : q / n) + u;
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
  // The first warp's reserve per credit, one-hot: none, or two where its
  // head needs two (an atomic's two MIU rows and names, a copy's second RCU
  // row; a need of one the first warp's share always covers while the pool
  // has any), from its admission bits; reserved only when the rotation's
  // own slot has a head (it is then the first). It is registered with the
  // rotation, from the next rotation slot's head now: a head left waiting is
  // the same head.
  localparam int ND = 2;
  logic [4*ND-1:0] dr_cq02h;                   // registered, one-hot per credit
  logic [4*ND-1:0] dr_nx_cq02h, dd_cq02h;
  logic [PA-1:0]   a0_cq02h, a1_cq02h;
  logic [2:0]      dn_cq02h;
  logic [S-1:0]    pn_cq02h;                   // the rotation's next slot
  logic            ph_cq02h;                   // the rotation's slot has a head
  always_comb begin
    pn_cq02h = {priod_cq02h[S-2:0], priod_cq02h[S-1]};
    a0_cq02h = '0;
    a1_cq02h = '0;
    for (int s = 0; s < S; s++) if (pn_cq02h[s] && hv_cq01h[s * H]) a0_cq02h = ha_cq01h[(s * H) * PA +: PA];
    // A pair's first slot's need is the pair's (OI-80 (d)): its second is
    // the next head.
    for (int s = 0; s < S; s++)
      if (pn_cq02h[s] && hv_cq01h[s * H + 1] && ha_cq01h[(s * H) * PA + 7]) a1_cq02h = ha_cq01h[(s * H + 1) * PA +: PA];
    for (int c = 0; c < 4; c++) begin
      dn_cq02h = c == 0 ? 3'(a0_cq02h[0]) + 3'(a0_cq02h[2]) + 3'(a0_cq02h[8] & a0_cq02h[7]) +
                          3'(a1_cq02h[0]) + 3'(a1_cq02h[2]) + 3'(a1_cq02h[8] & a1_cq02h[7]) :
                 c == 1 ? 3'(a0_cq02h[1]) + 3'(a1_cq02h[1]) :
                 c == 2 ? 3'(a0_cq02h[8] | a0_cq02h[3]) + 3'(a1_cq02h[8] | a1_cq02h[3]) :
                          3'(a0_cq02h[4]) + 3'(a1_cq02h[4]);
      dr_nx_cq02h[c * ND +: ND] = dn_cq02h >= 3'd2 ? 2'b10 : 2'b01;
    end
    ph_cq02h = |(priod_cq02h & with_w_cq01h);
    for (int c = 0; c < 4; c++)
      for (int d = 0; d < ND; d++) dd_cq02h[c * ND + d] = ph_cq02h ? dr_cq02h[c * ND + d] : d == 0;
  end
  // The table, at elaboration: for each case t (n warps, the first or not,
  // floor w, the first's need d) and each v, the pools that give a share of
  // v or more.
  localparam int NT = S * 2 * (R + 1) * ND;
  function automatic logic [NT*R*(PM+1)-1:0] table_of();
    table_of = '0;
    for (int n = 1; n < S + 1; n++)
      for (int f = 0; f < 2; f++)
        for (int w = 0; w < R + 1; w++)
          for (int d = 0; d < ND; d++)
            for (int v = 1; v < R + 1; v++)
              for (int p = 0; p < PM + 1; p++)
                if (share_of(p, n, f, w, 2 * d) >= v)
                  table_of[(((((n - 1) * 2 + f) * (R + 1) + w) * ND + d) * R + v - 1) * (PM + 1) + p] = 1'b1;
  endfunction
  localparam logic [NT*R*(PM+1)-1:0] TBL = table_of();
  // A case's pools, as runs of the pool's thermometer (a run from a to b:
  // the pool is a or more and not b or more), so the late pool reaches the
  // share through a compare and one AND-OR, not its one-hot.
  function automatic logic in_of(input logic [PM:0] th, input int row);
    int e;
    in_of = 1'b0;
    for (int a = 0; a < PM + 1; a++)
      if (TBL[row * (PM + 1) + a] && (a == 0 || !TBL[row * (PM + 1) + a - 1])) begin
        e = PM + 1;
        for (int b = PM; b > a; b--) if (!TBL[row * (PM + 1) + b]) e = b;
        in_of = in_of | (th[a] & (e > PM || !th[e % (PM + 1)]));
      end
  endfunction
  // Per credit, the pool picks first (tp[c][n][f][w][d][v]: at this pool,
  // case (n, f, w, d) gives v or more), then the warps' number and the first
  // warp's need, both early, the same for all (tw[c][f][w][v]); each warp's
  // role and floor pick last.
  localparam int NF = 2 * (R + 1);       // a warp's cases: role, floor
  logic [4*NT*R-1:0]   tp_cq02h;
  logic [4*NF*R-1:0]   tw_cq02h;
  logic [S*ND-1:0]     nd_sel_cq02h;     // the warps' number and the first's need, one-hot
  always_comb
    for (int c = 0; c < 4; c++) begin
      // One warp takes the whole pool, its reserve moot: its case reads no need.
      for (int n = 1; n < S + 1; n++)
        for (int d = 0; d < ND; d++)
          nd_sel_cq02h[(n - 1) * ND + d] = n == 1 ? nwh_cq01h[n] & d == 0 : nwh_cq01h[n] & dd_cq02h[c * ND + d];
      for (int t = 0; t < NT; t++)
        for (int v = 1; v < R + 1; v++)
          tp_cq02h[(c * NT + t) * R + v - 1] = in_of(pth_cq02h[c * (PM + 1) +: PM + 1], t * R + v - 1);
      for (int t = 0; t < NF; t++)
        for (int v = 1; v < R + 1; v++) begin
          tw_cq02h[(c * NF + t) * R + v - 1] = 1'b0;
          for (int n = 1; n < S + 1; n++)
            for (int d = 0; d < ND; d++)
              tw_cq02h[(c * NF + t) * R + v - 1] = tw_cq02h[(c * NF + t) * R + v - 1] |
                  (nd_sel_cq02h[(n - 1) * ND + d] & tp_cq02h[(c * NT + ((n - 1) * NF + t) * ND + d) * R + v - 1]);
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
                                              4'(ha_cq01h[(s * H + h) * PA + 8] | ha_cq01h[(s * H + h) * PA + 3])};
        nd_cq01h = '0;
        ser_cq01h = 1'b0;
        for (int m = 1; m < R + 1; m++) begin
          ok_cq02h = 1'b0;
          if (k + m - 1 < H) begin
            a_cq01h     = ha_cq01h[(s * H + k + m - 1) * PA +: PA];
            nd_cq01h[0 +: 4]  = nd_cq01h[0 +: 4] + 4'(a_cq01h[0]) + 4'(a_cq01h[2]) + 4'(a_cq01h[8] & a_cq01h[7]);
            nd_cq01h[4 +: 4]  = nd_cq01h[4 +: 4] + 4'(a_cq01h[1]);
            nd_cq01h[8 +: 4]  = nd_cq01h[8 +: 4] + 4'(a_cq01h[8] | a_cq01h[3]);
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
        // A run never ends on a pair's first slot (OI-84 (a)): where head m
        // is a first, length m fits as m + 1 does, its second's needs counted
        // (OI-80 (d)), and not at all at the width. The fits stay a
        // thermometer, a pair whole in it.
        for (int m = 1; m < R + 1; m++)
          fits_nx_cq01h[(s * (R + 1) + k) * R + m - 1] =
              (k + m - 1 < H && ha_cq01h[(s * H + (k + m - 1) % H) * PA + 7]) ? (m < R && okm_cq02h[m % R]) : okm_cq02h[m - 1];
      end
    end
  end

  // Each warp's first slots past each take k, and each head's unit (OI-84
  // (a)): head v's unit is v less the seconds up to it, a second being the
  // head after a first; registered with the fits.
  logic [S*(R+1)*R-1:0]  pf_nx_cq01h;
  logic [S*(R+1)*NU-1:0] ut_nx_cq01h;
  logic [2:0]            nsec_cq01h;
  always_comb
    for (int s = 0; s < S; s++)
      for (int k = 0; k < R + 1; k++) begin
        for (int r = 0; r < R; r++)
          pf_nx_cq01h[(s * (R + 1) + k) * R + r] = k + r < H && ha_cq01h[(s * H + (k + r) % H) * PA + 7];
        for (int v = 1; v < R; v++) begin
          nsec_cq01h = '0;
          for (int h = 0; h < v; h++) nsec_cq01h = nsec_cq01h + 3'(pf_nx_cq01h[(s * (R + 1) + k) * R + h]);
          for (int u = 0; u < v; u++) ut_nx_cq01h[(s * (R + 1) + k) * NU + ui(v, u)] = 3'(v) <= 3'(u) + nsec_cq01h;
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
        // The take (its copy): decq's heads move by it alone.
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
      hd_ev_cq02h[s] = dq_ev_cq01h[s] | tk_xw_cq02h[s] | ~tko_cq02h[s * (R + 1)] | sq_l_cq00h[s] | sq_cq01h[s];
    any_ev_cq02h = |hd_ev_cq02h;
    he_chg_cq02h = he_en_cq02h && he_nx_cq02h != he_cq02h;
    rem_cq02h = 1'b0;
    for (int c = 0; c < 4; c++)
      for (int n = 2; n < S + 1; n++)
        for (int p = 0; p < PM + 1; p++)
          if (p % n != 0 && p / n < R) rem_cq02h = rem_cq02h | (nwh_cq01h[n] & pe_cq02h[c * (PM + 1) + p] & prio_en_cq01h);
    // The first warp's need reserved moves with the rotation too (OI-80).
    for (int c = 0; c < 4; c++)
      rem_cq02h = rem_cq02h | (~nwh_cq01h[0] & ~nwh_cq01h[1] & ~dd_cq02h[c * ND] & ~pe_cq02h[c * (PM + 1)] & prio_en_cq01h);
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
        ut_cq02h[gs * (R + 1) * NU +: (R + 1) * NU]  <= '0;
        utw_cq02h[gs * (R + 1) * NU +: (R + 1) * NU] <= '0;
        utx_cq02h[gs * (R + 1) * NU +: (R + 1) * NU] <= '0;
        sel_q_cq02h[gs]                             <= 1'b0;
      end else if (fits_en_cq02h[gs]) begin
        fits_cq02h[gs * (R + 1) * R +: (R + 1) * R] <= fits_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R] & {((R + 1) * R){~sq_cq01h[gs]}};
        fitsw_cq02h[gs * (R + 1) * R +: (R + 1) * R] <= fits_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R] & {((R + 1) * R){~sq_cq01h[gs]}};
        fitsx_cq02h[gs * (R + 1) * R +: (R + 1) * R] <= fits_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R] & {((R + 1) * R){~sq_cq01h[gs]}};
        wc_cq02h[gs * (R + 1) * 2 * R * R +: (R + 1) * 2 * R * R] <= wc_cq01h[gs * (R + 1) * 2 * R * R +: (R + 1) * 2 * R * R];
        pf_cq02h[gs * (R + 1) * R +: (R + 1) * R]   <= pf_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R];
        pfw_cq02h[gs * (R + 1) * R +: (R + 1) * R]  <= pf_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R];
        pfx_cq02h[gs * (R + 1) * R +: (R + 1) * R]  <= pf_nx_cq01h[gs * (R + 1) * R +: (R + 1) * R];
        ut_cq02h[gs * (R + 1) * NU +: (R + 1) * NU]  <= ut_nx_cq01h[gs * (R + 1) * NU +: (R + 1) * NU];
        utw_cq02h[gs * (R + 1) * NU +: (R + 1) * NU] <= ut_nx_cq01h[gs * (R + 1) * NU +: (R + 1) * NU];
        utx_cq02h[gs * (R + 1) * NU +: (R + 1) * NU] <= ut_nx_cq01h[gs * (R + 1) * NU +: (R + 1) * NU];
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
      for (int c = 0; c < 4; c++) dr_cq02h[c * ND +: ND] <= ND'(1);
    end else if (prio_en_cq01h) begin
      prio_cq02h  <= {prio_cq02h[S-2:0], prio_cq02h[S-1]};
      priow_cq02h <= {priow_cq02h[S-2:0], priow_cq02h[S-1]};
      priox_cq02h <= {priox_cq02h[S-2:0], priox_cq02h[S-1]};
      priod_cq02h <= {priod_cq02h[S-2:0], priod_cq02h[S-1]};
      dr_cq02h    <= dr_nx_cq02h;
    end
  end

  // decq's take-enable covers every slot that takes (deq_sel_covers).
  logic [S-1:0] tk_any_cq02h;
  always_comb for (int s = 0; s < S; s++) tk_any_cq02h[s] = take_cq02h[s * R];
  `CCV_ASSERT(sel_covers, (tk_any_cq02h & ~sel_cq02h) == '0)
endmodule
`undef CCV_CLK
`undef CCV_RST
