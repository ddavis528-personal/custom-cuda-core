//===-- ooe_rs.sv - OOE reservation stations: valid, allocation, matrix -===//
//
// Spec: the design doc's Reservation stations and dependency matrix
//       (A-62, A-73: a cell per ordered pair, its dependency bit and its
//       2-bit wake-line select), the RS classes (30 RCU, 15 MIU), the reset
//       line (OI-36 (6): valid bits reset; the cells are payload guarded by
//       their row's valid, every one written at allocation) and DA's
//       response OI-39 (the RS keeps same-edge reuse unless its RTL
//       measures over the stage).
//
// The RS valid bits and the dependency matrix. Each class, RCU entries
// [0, NR) and MIU entries [NR, N), has A allocation ports, used in order.
// Port k takes the free entry with exactly k free entries below it in its
// class: first fit, as the model's rsAlloc. An entry freed this cycle (a
// confirmation or a squash) counts as free: the RS keeps same-edge reuse.
// The free count below each entry saturates at A and is kept as a
// thermometer, so two counts add as an AND-OR with no carry; the counts
// come from a Sklansky prefix tree, log2 of the class size deep.
//
// An allocation writes the entry's whole row: its dependency bits and line
// selects for entries already in the RS, and for entries granted this
// cycle to another port (an older producer renamed in the same group, in
// either class), named by port. A free clears the entry's column in every
// row, the rows allocated now included (rename looked their producers up a
// stage before), so a dependant never waits on, nor confirms behind, the
// entry's next occupant.
//
// The reference is the model's rsAlloc, rsFree and dependency cells, which
// log each cycle's allocations in order and its frees (Core::wakeLog:
// ralloc, rfree). test/ooe/rs_tb.cpp drives this module from them and
// compares, after each edge, the registered grants, the valid bits and
// every valid row's dependency bits and line selects. Every row it
// allocates also names every entry freed in its cycle, which the model's
// rows never do: the mask must clear them (without it, an assertion here
// stops the run).
//
// hcol_cq02h is a flag per column, set from the edge a row naming the entry
// is written until the entry is freed: a superset of the entries any row
// waits on, so ooe_confirm can tell a miss that may start a hop from one
// with no dependant, with one AND a column.
//
// Local clock gating (OA's responses OI-58, OI-61; V-75): each class's
// state is clocked on an allocation in it, a free in it, or a free of a
// column one of its rows names (kept as the class's column flags, whose OR
// is hcol_cq02h), each led from this module's own flops:
//   - an allocation by the flop of rename's Rename 2 valid per port
//     (req_l, L2), exact;
//   - a free by confirmation by a lead flop per entry (cf_en, L3), set when
//     the entry may confirm next cycle: its row empty after this edge
//     (every producer left in it freed now, the free input as data), and
//     then, for a producer, final at the next edge: its full-latency line
//     rises at it (ooe_wake's wtl, line 3), it is final, or a completion
//     arrives for it (an L1 hit or a restart raises it by event: the
//     completion channel's valid, flopped, cva, with the payload's RS
//     indices as they arrive, and a lead so set held a cycle more for a
//     restart, cvb); for an entry writing nothing (its prod bit, taken at
//     allocation), issued after the next edge (ooe_wake's issued and
//     ooe_sched's grant). A superset only by a late cancel and a hit's
//     held cycle;
//   - a free by squash by the flop of the registered squash's lead (sq_en),
//     both classes.
// Each entry's timer kind and latency class (ooe_wake's, OA re:OI-104) are
// written with its row and clocked with its class. The outputs' grant
// register is clocked on the request leads; the valid copy with its class. The reset is flopped (RST-1).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_rs #(
  parameter int N  = 45,                 // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int NR = 30,                 // RCU-class entries, [0, NR)
  parameter int A  = 4,                  // allocation ports per class (CCV_ISSUE_WIDTH)
  parameter int NC = 4,                  // completions a cycle (ccv_miu_ooe_cmpl's rate)
  parameter int PW = 1,                  // payload bits an entry holds for its issue (RA-39 (c))
  parameter int LW = 1,                  // its lead slice's bits (RA-31; OA's rev 343, (A))
  parameter int K  = 9,                  // issue slots (CCV_ISSUE_RESOURCES: S0-S3, P0-P3, R)
  localparam int P  = 2 * A,             // ports: RCU's 0..A-1, then MIU's
  localparam int W  = $clog2(N)
) (
  input  logic             ooe_core_clk,
  input  logic             ooe_rst_r00h,
  input  logic [P-1:0]     req_l_cq00h,  // port p allocates next cycle (rename's Rename 2 valid)
  input  logic [P-1:0]     req_cq01h,    // port p allocates
  input  logic [P-1:0]     row_prod_cq01h, // port p's entry writes a register some entry may wake on
  input  logic [2*P-1:0]   akind_cq01h,  // port p's entry's timer kind (ooe_wake's, OA re:OI-104)
  input  logic [3*P-1:0]   acls_cq01h,   // and its latency class
  input  logic [P*N-1:0]   row_dep_cq01h,  // port p's row: entries already in the RS
  input  logic [2*P*N-1:0] row_code_cq01h, // and each one's line select
  input  logic [P*P-1:0]   grp_dep_cq01h,  // port p's row: port q's entry, granted this cycle
  input  logic [2*P*P-1:0] grp_code_cq01h, // and its line select
  input  logic [P*P-1:0]   prv_dep_cq01h,  // port p's row: port q's entry, granted at the last edge
  input  logic [2*P*P-1:0] prv_code_cq01h, // and its line select
  input  logic [N-1:0]     sqf_cq01h,    // entries the registered squash frees this cycle
  input  logic [N-1:0]     msd_cq01h,    // ooe_wake's held misses (FMISS), as confirmation reads them now
  input  logic [N-1:0]     cfin_cq01h,   // ooe_wake's final bits, likewise
  // The confirmation leads' terms, as they stand now (ooe_wake's, ooe_sched's).
  input  logic [N-1:0]     wtl3_cq00h,   // the full-latency line rises at the next edge
  input  logic [N-1:0]     fin_cq00h,    // final
  input  logic [N-1:0]     gnt_cq01h,    // granted: issued from the next edge
  input  logic [NC-1:0]    cmpl_l_cq00h, // the completion channel's valid: a payload next cycle
  input  logic [NC*W-1:0]  cmpl_idx_cq00h, // each completion's RS entry (its payload)
  input  logic             sq_l_cq00h,   // the registered squash frees next cycle
  // The payload (RA-39 (c)): each port's, with its request, and its issue
  // slot, one-hot (the footprint's lowest resource: an RCU entry's S0-S3
  // or R, an MIU entry's P0-P3).
  input  logic [P*PW-1:0]  pay_cq01h,
  input  logic [P*LW-1:0]  lead_cq01h,   // and its lead slice (RA-31's static fields)
  input  logic [P*K-1:0]   home_cq01h,
  input  logic             gnt_l_cq01h,  // ooe_sched's grant register may change at the next edge
  output logic [K-1:0]     iss_v_cq03h,  // the issue register: slot k issues
  output logic [K*LW-1:0]  iss_lead_cq03h, // with its entry's lead slice
  output logic [K*PW-1:0]  iss_pay_cq03h, // the second payload register: the rest, a cycle after its valid
  output logic [P-1:0]     gnt_v_cq03h,  // port p was granted, at the last edge
  output logic [P*W-1:0]   gnt_idx_cq03h, // port p's entry
  output logic [N-1:0]     valid_out_cq02h, // the valid bits (a copy for the outputs)
  output logic [N*N-1:0]   dep_cq02h,    // row i, column j: i waits on j
  output logic [2*N*N-1:0] code_cq02h,   // the cell's wake-line select
  output logic [N-1:0]     prod_o_cq02h,  // each entry writes a register some entry may wake on (ooe_sched's
                                         // confirmation, OI-45)
  output logic [N-1:0]     hcol_cq02h,   // a row has named the entry since it was allocated
  output logic [2*N-1:0]   kind_o_cq02h, // each entry's timer kind, as allocated (ooe_wake's grant)
  output logic [3*N-1:0]   cls_o_cq02h   // and its latency class
);

  // The reset, flopped before any use (RST-1).
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  `CCV_ASSERT_KNOWN(req_known, req_cq01h)
  `CCV_ASSERT_KNOWN(sqf_known, sqf_cq01h)
  `CCV_ASSERT_KNOWN(msd_known, msd_cq01h)
  `CCV_ASSERT_KNOWN(cfin_known, cfin_cq01h)
  `CCV_ASSERT_KNOWN(req_l_known, req_l_cq00h)
  `CCV_ASSERT_KNOWN(sq_l_known, sq_l_cq00h)

  // A free count saturating at A, as a thermometer: bit k set when the count
  // exceeds k. Two counts add as an AND-OR, with no carry chain.
  function automatic logic [A-1:0] tadd(input logic [A-1:0] a, input logic [A-1:0] b);
    logic [A-1:0] c;
    for (int k = 0; k < A; k++) begin
      c[k] = a[k] || b[k];
      for (int i = 0; i < k; i++) c[k] = c[k] || (a[i] && b[k - 1 - i]);
    end
    tadd = c;
  endfunction

  // Each entry's free count below it, within its class [lo, lo + M): an
  // inclusive prefix by a Sklansky tree, log2(M) levels of tadd, then
  // shifted by one entry.
  function automatic logic [N*A-1:0] below(input logic [N-1:0] av);
    logic [N*A-1:0] pf, nx, bl;
    int             lo, m, pos, src;
    pf = '0;
    for (int e = 0; e < N; e++) pf[e * A] = av[e];
    for (int l = 0; (1 << l) < N; l++) begin
      nx = pf;
      for (int e = 0; e < N; e++) begin
        lo  = (e < NR) ? 0 : NR;
        m   = (e < NR) ? NR : N - NR;
        pos = e - lo;
        src = ((pos >> l) << l) - 1;
        if (((pos >> l) & 1) == 1 && (1 << l) < m)
          nx[e * A +: A] = tadd(pf[(lo + src) * A +: A], pf[e * A +: A]);
      end
      pf = nx;
    end
    bl = '0;
    for (int e = 0; e < N; e++)
      if (e != 0 && e != NR) bl[e * A +: A] = pf[(e - 1) * A +: A];
    below = bl;
  endfunction

  // Port p's grant, one-hot over the entries: in its class, free, with as
  // many free below it as the port's number within the class.
  function automatic logic [P*N-1:0] grants(input logic [N-1:0] vl, input logic [P-1:0] req);
    logic [N-1:0]   av;
    logic [N*A-1:0] bl;
    logic [P*N-1:0] g;
    logic           k_ok;
    // An entry freed this cycle is allocatable from the next (OI-45: the
    // free comes from confirmation here, 25.7 NGD into the row write).
    for (int e = 0; e < N; e++) av[e] = !vl[e];
    bl = below(av);
    for (int p = 0; p < P; p++)
      for (int e = 0; e < N; e++) begin
        // Exactly p % A free below: the thermometer is set to p % A and no further.
        k_ok = (p % A == 0 || bl[e * A + ((p % A == 0) ? 0 : p % A - 1)]) && !bl[e * A + p % A];
        g[p * N + e] = req[p] && av[e] && ((p < A) == (e < NR)) && k_ok;
      end
    grants = g;
  endfunction

  // Each port's row as it is written: its bits for entries already in the
  // RS, and for each port it names, that port's grant, one-hot over the
  // entries, with the line select it gave; likewise each port of the group
  // ahead it names (prv_dep), through the last edge's grant. An entry is in
  // one port's grant at most, so each cell takes its select through a
  // one-hot AND-OR, and a row's own code only where kept (keep: valid and
  // not the group ahead's, so neither grant's entry). Computed once per
  // port, then written into whichever entry the port takes.
  function automatic logic [3*P*N-1:0] rows_of(input logic [P*N-1:0] g, input logic [P*N-1:0] rd,
                                               input logic [2*P*N-1:0] rc, input logic [P*P-1:0] gd,
                                               input logic [2*P*P-1:0] gc, input logic [P*N-1:0] lg,
                                               input logic [P*P-1:0] vd, input logic [2*P*P-1:0] vc,
                                               input logic [N-1:0] keep);
    logic [P*N-1:0]   d;
    logic [2*P*N-1:0] cd;
    logic [2*P-1:0]   td, tc0, tc1;   // each cell's terms, one per port it names: OR-reduced, a tree not a chain
    for (int p = 0; p < P; p++)
      for (int j = 0; j < N; j++) begin
        for (int q = 0; q < P; q++) begin
          td[q]      = q != p && gd[p * P + q] && g[q * N + j];
          td[P + q]  = vd[p * P + q] && lg[q * N + j];
          tc0[q]     = td[q] & gc[(p * P + q) * 2];
          tc1[q]     = td[q] & gc[(p * P + q) * 2 + 1];
          tc0[P + q] = td[P + q] & vc[(p * P + q) * 2];
          tc1[P + q] = td[P + q] & vc[(p * P + q) * 2 + 1];
        end
        d[p * N + j]            = rd[p * N + j] | (|td);
        cd[(p * N + j) * 2]     = (rc[(p * N + j) * 2] & keep[j]) | (|tc0);
        cd[(p * N + j) * 2 + 1] = (rc[(p * N + j) * 2 + 1] & keep[j]) | (|tc1);
      end
    rows_of = {cd, d};
  endfunction

  (* keep *) logic [N-1:0] valid_cq02h;  // the valid bits, for allocation and the rows
  // Copies of the valid bits (OA rev 325, step 1): allocation's grant
  // broadcast to the 3N-bit row write is the block's widest net, so each
  // copy's grants drive one group of it, g1 the dep rows, g2 and g3 the code
  // rows' halves, and vc0's g the rest (hit, prod, the column flags). Each
  // holds an entry taken from allocation: valid, or held by C9 (hh_cq02h,
  // below), written from valid's and hh's next values, so no grant starts
  // at hh (it reached 595 loads): an hh bit rises only on a free, which
  // fires its class's enable, and falls on hhv, in both. Reset as
  // valid_cq02h; (* keep *) or synthesis merges them back.
  (* keep *) logic [N-1:0] vc0_cq02h, vc1_cq02h, vc2_cq02h, vc3_cq02h;
  logic [N-1:0] tk_nx_cq02h;            // their next value: valid's, or held
  (* keep *) logic [P*N-1:0] g1_cq02h, g2_cq02h, g3_cq02h;
  (* keep *) logic [N-1:0] prod_cq02h;   // payload: read only while its entry is valid
  // The prod bits' copy for ooe_sched (NGD-7: the register starts paths
  // inside deeper than the output's budget allows).
  (* keep *) logic [N-1:0] prod_oc_cq02h;
  assign prod_o_cq02h = prod_oc_cq02h;
  // Each entry's timer kind and latency class, {class, kind}, written with
  // its row at allocation (OA, re:OI-104) for ooe_wake's timers, which read
  // them at a grant; payload, read only while the entry is valid. Read
  // here only by its own next state, so the outputs come from it directly.
  logic [5*N-1:0] kc_cq02h;
  always_comb
    for (int i = 0; i < N; i++) begin
      kind_o_cq02h[i * 2 +: 2] = kc_cq02h[i * 5 +: 2];
      cls_o_cq02h[i * 3 +: 3]  = kc_cq02h[i * 5 + 2 +: 3];
    end
  logic [N-1:0]     cf_en_cq03h;          // the confirmation leads' flops
  logic [NC-1:0]    cva_cq01h;            // the completion channel's valid, flopped: its payload is here
  logic             cvb_cq02h;            // a payload arrived at the last edge
  logic             sq_en_cq01h;          // the registered squash's lead's flop
  logic [N-1:0]     hr_cq02h, hm_cq02h;   // the column flags, from RCU rows and MIU rows
  logic [P*N-1:0]   g_cq02h;
  logic [P*N-1:0]   gs_cq02h;   // each port's slot: the entry it takes if it asks (g, less the request)
  logic [P-1:0]     gv_cq02h;
  logic [P*W-1:0]   gi_cq02h;
  logic [P*N-1:0]   d_cq02h;
  logic [2*P*N-1:0] cd_cq02h;
  logic [P*N-1:0]   dz_cq02h;    // the rows' named terms alone, no row bits: the free enters named's root
  logic [2*P*N-1:0] cdz_cq02h;
  // -- Confirmation, here (OI-45, OI-50 and its co-grant arm, OI-133; V-65) ----
  // This module's issued register: set at a grant (select's, issued from
  // the next edge), cleared by its own replays and frees, so it is
  // ooe_wake's issued flags (FISS) every cycle. The cancel's level rule and
  // confirmation are ooe_confirm's, run here on this register and the
  // matrix, with wake's held misses and final bits as data. A row's
  // emptiness is a register of its own (emp, set from the row's next
  // value): reducing the 45-bit row in front of confirmation put the
  // matrix flops 18.3 NGD from the next state, over the 12 the dep output
  // holds them to (NGD-7). Confirmed entries are freed, and so are the
  // ones the registered squash frees.
  // The last edge's grant (ng), confirmation's co-grant term (OI-133): an
  // entry and a producer it waits on, both granted at that edge, mean the
  // producer was cancelled and granted again as the entry was granted on
  // the ready bit its first issue woke; the entry returns.
  logic [N-1:0] iss_cq02h, ng_cq02h, emp_cq02h, gone_cq02h, rep_cq02h, conf_cq02h, free_cq02h;
  always_comb begin
    gone_cq02h = ~iss_cq02h | msd_cq01h;
    for (int i = 0; i < N; i++) begin
      rep_cq02h[i]  = iss_cq02h[i] && (|(dep_cq02h[i * N +: N] & gone_cq02h) ||
                                       (ng_cq02h[i] && |(dep_cq02h[i * N +: N] & ng_cq02h)));
      conf_cq02h[i] = iss_cq02h[i] && emp_cq02h[i] && (cfin_cq01h[i] || !prod_cq02h[i]);
    end
  end
  assign free_cq02h = conf_cq02h | sqf_cq01h;
  // Outside any gate, within the module's allowance: a grant has no lead
  // here (select's grant register is ooe_sched's), nor has a replay.
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      iss_cq02h <= '0;
      ng_cq02h  <= '0;
    end else begin
      iss_cq02h <= (iss_cq02h & ~rep_cq02h & ~free_cq02h) | gnt_cq01h;
      ng_cq02h  <= gnt_cq01h;
    end
  end
  // The last edge's grant, one-hot, registered beside the grant itself
  // (lg_cq02h and its union lga_cq02h): the group ahead's entries, which
  // prv_dep names by port (rename knew them only by port), and whose old
  // occupants' names a row may still hold (ooe_prodmap writes an entry's
  // names an edge after its grant). Kept apart from gnt_idx_cq03h, which
  // leaves as an output (NGD-7), and needing no decode. Clocked as the
  // grant is, with any request and the edge after to clear.
  logic [P*N-1:0] lg_cq02h;
  (* keep *) logic [P-1:0] lgv_cq02h;    // its ports: gnt_v_cq03h's copy for this module (NGD-7)
  logic [N-1:0]   lga_cq02h, ga_cq02h;
  always_comb begin
    ga_cq02h = '0;
    for (int q = 0; q < P; q++) ga_cq02h = ga_cq02h | g_cq02h[q * N +: N];
  end
  // A row bit counts only on an entry valid now, not freed now and not the
  // group ahead's: rename's lookup ran a stage earlier, on names that may
  // since have left their entries (ooe_rename, slice 2).
  logic [N-1:0] rmask_cq02h;
  logic [N-1:0] hcq_cq02h, hc_cq02h, hh_cq02h;   // C9's hit-confirm hold (below)
  logic [N-1:0] clr_cq02h;                       // the columns cleared at this edge: the frees and the held
  logic         hhv_cq02h;                       // some entry held (hh): the class enables' term, one flop
  assign rmask_cq02h = valid_cq02h & ~(conf_cq02h & ~hc_cq02h | sqf_cq01h) & ~lga_cq02h;
  always_comb begin
    // A row names a port of its group only when that port asks
    // (grp_named_req), so the rows take the slots, gs, and the request
    // stays off their paths; g is gs where its port asks.
    gs_cq02h = grants(vc0_cq02h, {P{1'b1}});
    for (int p = 0; p < P; p++) g_cq02h[p * N +: N] = gs_cq02h[p * N +: N] & {N{req_cq01h[p]}};
    g1_cq02h = grants(vc1_cq02h, req_cq01h);
    g2_cq02h = grants(vc2_cq02h, req_cq01h);
    g3_cq02h = grants(vc3_cq02h, req_cq01h);
    {cd_cq02h, d_cq02h} = rows_of(gs_cq02h, row_dep_cq01h & {P{rmask_cq02h}}, row_code_cq01h, grp_dep_cq01h,
                                  grp_code_cq01h, lg_cq02h, prv_dep_cq01h, prv_code_cq01h,
                                  valid_cq02h & ~lga_cq02h);
    {cdz_cq02h, dz_cq02h} = rows_of(gs_cq02h, '0, row_code_cq01h, grp_dep_cq01h,
                                    grp_code_cq01h, lg_cq02h, prv_dep_cq01h, prv_code_cq01h,
                                    valid_cq02h & ~lga_cq02h);
    for (int p = 0; p < P; p++) begin
      gv_cq02h[p]           = |g_cq02h[p * N +: N];
      gi_cq02h[p * W +: W] = '0;
      for (int e = 0; e < N; e++) if (g_cq02h[p * N + e]) gi_cq02h[p * W +: W] = W'(e);
    end
  end

  // The outputs leave from registers of their own (OA's stage-boundary map,
  // item 3; TI-20): the grant, registered at the edge it is made, and a
  // copy of the valid bits, so that the valid bits allocation reads serve
  // no output. The grant register is clocked on the request leads and one
  // edge more to clear; the valid copy with its class.
  (* keep *) logic [N-1:0] valid_o_cq02h;
  logic [P-1:0] req_en_cq01h;            // the request leads' flops
  // The valid bits are clocked when they change: every port that asks is
  // granted, so they become the request leads' flops (exact, from this
  // module's own flops); a steady stream of grants on the same ports
  // clocks nothing. The indices, payload read through them, with any
  // request.
  logic         gnt_en_cq01h, gnt_v_en_cq03h;
  assign gnt_en_cq01h   = req_en_cq01h != '0;
  assign gnt_v_en_cq03h = req_en_cq01h != gnt_v_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h)      gnt_v_cq03h <= '0;
    else if (gnt_v_en_cq03h) gnt_v_cq03h <= gv_cq02h;
  end
  always_ff @(posedge ooe_core_clk) begin
    if (gnt_en_cq01h) gnt_idx_cq03h <= gi_cq02h;   // payload, read through gnt_v
  end
  // Its enable as gnt_v's, from its own copy lgv (equal to gnt_v: the same
  // data and enable), so it reads no stage past its own.
  logic lg_en_cq02h;
  assign lg_en_cq02h = gnt_en_cq01h || req_en_cq01h != lgv_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      lg_cq02h  <= '0;
      lgv_cq02h <= '0;
      lga_cq02h <= '0;
    end else if (lg_en_cq02h) begin
      lg_cq02h  <= g_cq02h;
      lgv_cq02h <= req_cq01h;
      lga_cq02h <= ga_cq02h;
    end
  end
  assign valid_out_cq02h = valid_o_cq02h;
  // lgv is gnt_v's copy: lg's enable reads it in gnt_v's place.
  `CCV_ASSERT(lgv_copy, lgv_cq02h == gnt_v_cq03h)

  // Rename checks the RS for room first, so every port that asks is granted.
  `CCV_ASSERT(alloc_granted, (req_cq01h & ~gv_cq02h) == '0)
  // A free names a valid entry.
  `CCV_ASSERT(free_valid, (free_cq02h & ~valid_cq02h) == '0)
  // What ooe_wake and ooe_sched report, and a completion's payload, name
  // only entries valid here (their benches drive them so; the assembled
  // block holds them to it).
  logic [N-1:0] cpv_cq02h;
  always_comb begin
    cpv_cq02h = '0;
    for (int k = 0; k < NC; k++)
      if (cva_cq01h[k]) cpv_cq02h[cmpl_idx_cq00h[k * W +: W]] = 1'b1;
  end
  `CCV_ASSERT(wake_names_valid, ((gnt_cq01h | fin_cq00h | wtl3_cq00h | cpv_cq02h | msd_cq01h) & ~valid_cq02h) == '0)
  // A valid row's emptiness register is its row's (payload elsewhere).
  logic [N-1:0] emp_ok_cq02h;
  always_comb
    for (int i = 0; i < N; i++) emp_ok_cq02h[i] = !valid_cq02h[i] || emp_cq02h[i] == (dep_cq02h[i * N +: N] == '0);
  `CCV_ASSERT(row_empty_kept, emp_ok_cq02h == '1)
  // A squash frees valid entries, none of them confirming now.
  `CCV_ASSERT(squash_free_valid, (sqf_cq01h & ~valid_cq02h) == '0)
  // Every request and every free was led.
  `CCV_ASSERT(req_led, (req_cq01h & ~req_en_cq01h) == '0)
  // A row names a port of its own group only when that port asks (rename's
  // group dependencies are its allocating uops'): the rows read gs.
  logic [P-1:0] gnr_bad_cq01h;
  always_comb
    for (int p = 0; p < P; p++) gnr_bad_cq01h[p] = req_cq01h[p] && (grp_dep_cq01h[p * P +: P] & ~req_cq01h) != '0;
  `CCV_ASSERT(grp_named_req, gnr_bad_cq01h == '0)
  `CCV_ASSERT(free_led, sq_en_cq01h || (free_cq02h & ~cf_en_cq03h) == '0)

  // The next state. An entry a port takes gets the port's row; every other
  // row keeps its bits, less the columns freed this cycle, and its line
  // selects where its bits were set (a select is read only there, and
  // taking the bit from its flop keeps the free off the select's write). Per class, a
  // column is flagged from the edge a row of the class naming it is written
  // until the entry is freed, unless a row written at that same edge names
  // its next occupant; a set bit in a class's row is always flagged there.
  logic [N-1:0]     valid_nx_cq02h, prod_nx_cq01h, emp_nx_cq02h;
  logic [5*N-1:0]   kc_nx_cq01h;
  logic             emp_g_cq02h;
  logic [P-1:0]     emp_new_cq02h;
  logic [N*N-1:0]   dep_nx_cq02h;
  logic [2*N*N-1:0] code_nx_cq02h;
  logic [N-1:0]     hr_nx_cq02h, hm_nx_cq02h, named_r_cq02h, named_m_cq02h;
  logic [2*N*N-1:0] dep2_cq02h;    // each cell's bit, twice, as the line selects lie
  logic             hit_cq02h, ga1_cq02h, ga2_cq02h, ga3_cq02h;
  logic [A-1:0]     nt_r_cq01h, nt_m_cq01h, ny_r_cq02h, ny_m_cq02h;
  always_comb begin
    for (int c = 0; c < N * N; c++) dep2_cq02h[c * 2 +: 2] = {2{dep_cq02h[c]}};
    named_r_cq02h = '0;
    named_m_cq02h = '0;
    for (int i = 0; i < N; i++) begin
      // One-hot AND-OR (an entry is granted to one port at most): the kept
      // row where no port takes it, else the taking port's row; each group
      // of the row through its own grant copy.
      hit_cq02h = 1'b0;
      ga1_cq02h = 1'b0; ga2_cq02h = 1'b0; ga3_cq02h = 1'b0;
      for (int p = 0; p < P; p++) begin
        hit_cq02h = hit_cq02h | g_cq02h[p * N + i];
        ga1_cq02h = ga1_cq02h | g1_cq02h[p * N + i];
        ga2_cq02h = ga2_cq02h | g2_cq02h[p * N + i];
        ga3_cq02h = ga3_cq02h | g3_cq02h[p * N + i];
      end
      dep_nx_cq02h[i * N +: N]           = dep_cq02h[i * N +: N] & ~clr_cq02h & {N{!ga1_cq02h}};
      code_nx_cq02h[i * 2 * N +: N]      = code_cq02h[i * 2 * N +: N] & dep2_cq02h[i * 2 * N +: N] & {N{!ga2_cq02h}};
      code_nx_cq02h[i * 2 * N + N +: N]  = code_cq02h[i * 2 * N + N +: N] & dep2_cq02h[i * 2 * N + N +: N] & {N{!ga3_cq02h}};
      for (int p = 0; p < P; p++) begin
        dep_nx_cq02h[i * N +: N]          = dep_nx_cq02h[i * N +: N] | (d_cq02h[p * N +: N] & {N{g1_cq02h[p * N + i]}});
        code_nx_cq02h[i * 2 * N +: N]     = code_nx_cq02h[i * 2 * N +: N] | (cd_cq02h[p * 2 * N +: N] & {N{g2_cq02h[p * N + i]}});
        code_nx_cq02h[i * 2 * N + N +: N] = code_nx_cq02h[i * 2 * N + N +: N] | (cd_cq02h[p * 2 * N + N +: N] & {N{g3_cq02h[p * N + i]}});
      end
      valid_nx_cq02h[i] = hit_cq02h || (valid_cq02h[i] && !free_cq02h[i]);
      // Its prod bit, from its port; cleared with its valid bit (read only
      // while valid), so it shares its class's enable.
      prod_nx_cq01h[i]  = prod_cq02h[i] && !free_cq02h[i];
      // Its kind and class likewise, cleared with it: the class's enable
      // clocks them, never one of the entry's own.
      kc_nx_cq01h[i * 5 +: 5] = kc_cq02h[i * 5 +: 5] & {5{!free_cq02h[i]}};
      for (int p = 0; p < P; p++)
        if (g_cq02h[p * N + i]) begin
          prod_nx_cq01h[i] = row_prod_cq01h[p];
          kc_nx_cq01h[i * 5 +: 5] = {acls_cq01h[p * 3 +: 3], akind_cq01h[p * 2 +: 2]};
        end
    end
    // Each column's flag from the ports that write a row naming it: an
    // OR-reduce over the class's ports, a tree not a chain.
    for (int j = 0; j < N; j++) begin
      // The free enters at the root: a port's row names column j through
      // its own input (masked, rmask) or through a grant it names (dz, the
      // row less its input), so (rmask & X) | Y, X free of the free.
      // A port writes a row when it asks: every request is granted
      // (alloc_granted), so its request stands for its grant's OR (gv),
      // and the column flags wait on no grant but the rows' own (dz).
      for (int p = 0; p < A; p++) begin
        nt_r_cq01h[p] = req_cq01h[p] & row_dep_cq01h[p * N + j];
        nt_m_cq01h[p] = req_cq01h[A + p] & row_dep_cq01h[(A + p) * N + j];
        ny_r_cq02h[p] = req_cq01h[p] & dz_cq02h[p * N + j];
        ny_m_cq02h[p] = req_cq01h[A + p] & dz_cq02h[(A + p) * N + j];
      end
      named_r_cq02h[j] = (rmask_cq02h[j] & (|nt_r_cq01h)) | (|ny_r_cq02h);
      named_m_cq02h[j] = (rmask_cq02h[j] & (|nt_m_cq01h)) | (|ny_m_cq02h);
    end
    // Emptiness in parallel with the rows: a kept row's from its flops less
    // the frees; a new one's from its port's inputs, before any grant (a
    // row naming a port of its group names a granted entry: every port that
    // asks is granted), then steered with the row.
    for (int p = 0; p < P; p++)
      emp_new_cq02h[p] = (row_dep_cq01h[p * N +: N] & rmask_cq02h) == '0 &&
                   (grp_dep_cq01h[p * P +: P] & req_cq01h & ~(P'(1) << p)) == '0 &&
                   (prv_dep_cq01h[p * P +: P] & lgv_cq02h) == '0;
    for (int i = 0; i < N; i++) begin
      // An entry is granted to one port at most: its new row's flag through
      // a one-hot select, not an override in port order (NGD-7: dep).
      emp_g_cq02h = 1'b0;
      for (int p = 0; p < P; p++) emp_g_cq02h = emp_g_cq02h | (g_cq02h[p * N + i] & emp_new_cq02h[p]);
      emp_nx_cq02h[i] = ga_cq02h[i] ? emp_g_cq02h : (dep_cq02h[i * N +: N] & ~clr_cq02h) == '0;
    end
    hr_nx_cq02h = (hr_cq02h & ~clr_cq02h) | named_r_cq02h;
    hm_nx_cq02h = (hm_cq02h & ~clr_cq02h) | named_m_cq02h;
  end
  assign hcol_cq02h = hr_cq02h | hm_cq02h;

  // -- Leads -------------------------------------------------------------------
  // Each entry's confirmation lead (see the header). Its row is empty
  // after this edge exactly when every producer left in it is freed now;
  // then a producer confirms once final, which it is at the next edge if
  // its full-latency line rises at it (wtl3), it is already, or a
  // completion for it arrives now (cmn: an L1 hit), or arrived at the last
  // edge (a restart: the lead it set, held a cycle by cvb); and an entry
  // writing nothing confirms once issued. An entry freed now, or free,
  // needs none.
  logic [N-1:0] cmn_cq01h, cf_d_cq02h;
  always_comb begin
    cmn_cq01h = '0;
    for (int k = 0; k < NC; k++)
      for (int i = 0; i < N; i++)
        if (cva_cq01h[k] && cmpl_idx_cq00h[k * W +: W] == W'(i)) cmn_cq01h[i] = 1'b1;
    for (int i = 0; i < N; i++)
      cf_d_cq02h[i] = valid_cq02h[i] && !free_cq02h[i] && (dep_cq02h[i * N +: N] & ~clr_cq02h) == '0 &&
                (prod_cq02h[i] ? wtl3_cq00h[i] || fin_cq00h[i] || cmn_cq01h[i] || (cf_en_cq03h[i] && cvb_cq02h)
                               : iss_cq02h[i] || gnt_cq01h[i]);
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      req_en_cq01h <= '0;
      cf_en_cq03h  <= '0;
      cva_cq01h    <= '0;
      cvb_cq02h    <= 1'b0;
      sq_en_cq01h  <= 1'b0;
    end else begin
      req_en_cq01h <= req_l_cq00h;
      cf_en_cq03h  <= cf_d_cq02h;
      cva_cq01h    <= cmpl_l_cq00h;
      cvb_cq02h    <= cva_cq01h != '0;
      sq_en_cq01h  <= sq_l_cq00h;
    end
  end

  // C9 (OA rev 372; the model's cmpl_split 8): a confirmation an L1 hit
  // makes, in its cycle or the next (hc: the hit's bypass from the raw
  // completion, cmn, and its register, hq), frees its entry but stays off
  // rename's row mask, and the entry stays held from allocation (hh) and
  // rename's room through the next cycle. A row written at the free's edge
  // may name it (the mask cannot see it): its column is cleared at the
  // next, the hold's, as a free's is (clr; the class enables take hh on a
  // column their flags name: on hhv, any entry held, one flop of the same
  // term, as hh & hr would put the enable over CG-2's 8).
  assign hc_cq02h = cmn_cq01h | hcq_cq02h;
  assign clr_cq02h = free_cq02h | hh_cq02h;
  assign tk_nx_cq02h = valid_nx_cq02h | (conf_cq02h & hc_cq02h);
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      hcq_cq02h <= '0;
      hh_cq02h <= '0;
      hhv_cq02h <= 1'b0;
    end else begin
      hcq_cq02h <= cmn_cq01h;
      hh_cq02h <= conf_cq02h & hc_cq02h;
      hhv_cq02h <= (conf_cq02h & hc_cq02h) != '0;
    end
  end

  // -- Payload and issue (RA-39 (c); OOE microarchitecture, Payload read) ---
  // Each port's payload and slot are staged at its allocation, on its
  // request lead, and written into the entry at the next edge through the
  // last edge's grant (lg), one entry's flops at a time: both enables are
  // this module's own flops (CG-5). The entry is first read the cycle
  // after its first grant registers, which is no sooner than that write
  // (pay_ready). The free leaves them as they are: payload, read only
  // through a grant of a valid entry.
  logic [P*PW-1:0] pst_cq02h;
  logic [P*LW-1:0] lst_cq02h;
  logic [P*K-1:0]  hst_cq02h;
  always_ff @(posedge ooe_core_clk)
    for (int p = 0; p < P; p++)
      if (req_en_cq01h[p]) begin
        pst_cq02h[p * PW +: PW] <= pay_cq01h[p * PW +: PW];
        lst_cq02h[p * LW +: LW] <= lead_cq01h[p * LW +: LW];
        hst_cq02h[p * K +: K]   <= home_cq01h[p * K +: K];
      end
  // The payload's own flopped reset (RST-1): rst_r01h's loads are the
  // module's widest net, on its worst path.
  (* keep *) logic p_rst_r01h;
  always_ff @(posedge ooe_core_clk) p_rst_r01h <= ooe_rst_r00h;
  // The last edge's grant again, for the write alone (NGD-7: lg's own
  // loads are the rows' path), clocked as lg is.
  (* keep *) logic [P*N-1:0] lgp_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (p_rst_r01h)         lgp_cq02h <= '0;
    else if (lg_en_cq02h) lgp_cq02h <= g_cq02h;
  end
  logic [N-1:0] pw_en_cq02h;
  always_comb begin
    pw_en_cq02h = '0;
    for (int q = 0; q < P; q++) pw_en_cq02h = pw_en_cq02h | lgp_cq02h[q * N +: N];
  end
  logic [N*PW-1:0] pq_cq02h;
  logic [N*LW-1:0] lq_cq02h;
  logic [N*K-1:0]  hq_cq02h;
  logic [N*PW-1:0] pd_cq02h;
  logic [N*LW-1:0] ld_cq02h;
  logic [N*K-1:0]  hd_cq02h;
  always_comb
    for (int i = 0; i < N; i++) begin
      pd_cq02h[i * PW +: PW] = '0;
      ld_cq02h[i * LW +: LW] = '0;
      hd_cq02h[i * K +: K]   = '0;
      for (int p = 0; p < P; p++)
        if (lgp_cq02h[p * N + i]) begin
          pd_cq02h[i * PW +: PW] = pd_cq02h[i * PW +: PW] | pst_cq02h[p * PW +: PW];
          ld_cq02h[i * LW +: LW] = ld_cq02h[i * LW +: LW] | lst_cq02h[p * LW +: LW];
          hd_cq02h[i * K +: K]   = hd_cq02h[i * K +: K] | hst_cq02h[p * K +: K];
        end
    end
  always_ff @(posedge ooe_core_clk)
    for (int i = 0; i < N; i++)
      if (pw_en_cq02h[i]) begin
        pq_cq02h[i * PW +: PW] <= pd_cq02h[i * PW +: PW];
        lq_cq02h[i * LW +: LW] <= ld_cq02h[i * LW +: LW];
        hq_cq02h[i * K +: K]   <= hd_cq02h[i * K +: K];
      end
  // The payload read (OA's rev 343, (A)): slot k takes the granted entry
  // whose slot is k, a one-hot AND-OR over its class. The issue register
  // holds each slot's valid and its lead slice, read exactly through the
  // grant register; the rest of the payload is read through a copy of the
  // grant register a cycle late (gd) into a second register, a cycle after
  // its valid, as the channel's contract and CCV_LAT_HOP count it. Both
  // registers and gd are clocked when ooe_sched's grant register was (its
  // lead, flopped; the second a cycle later), so they clear with it.
  logic iss_en_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (p_rst_r01h) iss_en_cq02h <= 1'b0;
    else          iss_en_cq02h <= gnt_l_cq01h;
  end
  logic [K-1:0]    iv_d_cq02h;
  logic [K*LW-1:0] il_d_cq02h;
  always_comb
    for (int k = 0; k < K; k++) begin
      iv_d_cq02h[k] = 1'b0;
      il_d_cq02h[k * LW +: LW] = '0;
      for (int e = 0; e < N; e++)
        if (gnt_cq01h[e] && hq_cq02h[e * K + k]) begin
          iv_d_cq02h[k] = 1'b1;
          il_d_cq02h[k * LW +: LW] = il_d_cq02h[k * LW +: LW] | lq_cq02h[e * LW +: LW];
        end
    end
  always_ff @(posedge ooe_core_clk) begin
    if (p_rst_r01h)       iss_v_cq03h <= '0;
    else if (iss_en_cq02h) iss_v_cq03h <= iv_d_cq02h;
  end
  always_ff @(posedge ooe_core_clk)
    if (iss_en_cq02h) iss_lead_cq03h <= il_d_cq02h;
  // The late grant (N flops on the issue register's enable) and the second
  // register's enable, the issue register's a cycle on. The store's
  // entries gd reads are as they were when the grant register held them:
  // pay_ready keeps every write off an entry the grant register holds.
  logic [N-1:0] gd_cq02h;
  logic         iss2_en_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (p_rst_r01h) begin
      gd_cq02h      <= '0;
      iss2_en_cq02h <= 1'b0;
    end else begin
      if (iss_en_cq02h) gd_cq02h <= gnt_cq01h;
      iss2_en_cq02h <= iss_en_cq02h;
    end
  end
  logic [K*PW-1:0] ip_d_cq02h;
  always_comb
    for (int k = 0; k < K; k++) begin
      ip_d_cq02h[k * PW +: PW] = '0;
      for (int e = 0; e < N; e++)
        if (gd_cq02h[e] && hq_cq02h[e * K + k])
          ip_d_cq02h[k * PW +: PW] = ip_d_cq02h[k * PW +: PW] | pq_cq02h[e * PW +: PW];
    end
  always_ff @(posedge ooe_core_clk)
    if (iss2_en_cq02h) iss_pay_cq03h <= ip_d_cq02h;
  // A grant the issue register takes never reads an entry whose payload
  // is still in its stage (the design's timing: select reads an entry no
  // sooner than the edge after its allocation, ooe_sched's request
  // register; trio_tb holds it).
  `CCV_ASSERT(pay_ready, !iss_en_cq02h || (gnt_cq01h & lga_cq02h) == '0)
  // A granted entry has one slot, and no two grants share one (V-60).
  logic slot_ok_cq02h;
  always_comb begin
    logic [K-1:0] seen;
    slot_ok_cq02h = 1'b1;
    seen = '0;
    for (int e = 0; e < N; e++)
      if (gnt_cq01h[e]) begin
        if (!$onehot(hq_cq02h[e * K +: K]) || (seen & hq_cq02h[e * K +: K]) != '0) slot_ok_cq02h = 1'b0;
        seen = seen | hq_cq02h[e * K +: K];
      end
  end
  `CCV_ASSERT(slot_onehot, !iss_en_cq02h || slot_ok_cq02h)

  // Local clock gating (docs/rtl-coding-style.md). A class's state, its
  // valid bits, rows, line selects, prod bits and column flags, changes
  // only on an allocation in the class, a free in it, or a free of a column
  // its flags name, and is clocked on those leads alone. An idle RS clocks
  // none of it.
  logic rcu_en_cq01h, miu_en_cq01h;
  logic [N-1:0] fl_cq01h;                    // a free may come: led by confirmation, or a squash
  assign fl_cq01h = cf_en_cq03h | {N{sq_en_cq01h}};
  assign rcu_en_cq01h = |req_en_cq01h[A-1:0] || |fl_cq01h[NR-1:0] || |(fl_cq01h & hr_cq02h) || hhv_cq02h;
  assign miu_en_cq01h = |req_en_cq01h[P-1:A] || |fl_cq01h[N-1:NR] || |(fl_cq01h & hm_cq02h) || hhv_cq02h;

  always_ff @(posedge ooe_core_clk) begin
    // The reset state: every entry free, no column with a dependant. The
    // rows and line selects are payload.
    if (rst_r01h) begin
      valid_cq02h   <= '0;
      valid_o_cq02h <= '0;
      vc0_cq02h <= '0; vc1_cq02h <= '0; vc2_cq02h <= '0; vc3_cq02h <= '0;
      hr_cq02h      <= '0;
      hm_cq02h      <= '0;
    end else begin
      if (rcu_en_cq01h) begin
        valid_cq02h[NR-1:0]   <= valid_nx_cq02h[NR-1:0];
        valid_o_cq02h[NR-1:0] <= valid_nx_cq02h[NR-1:0];
        vc0_cq02h[NR-1:0] <= tk_nx_cq02h[NR-1:0];
        vc1_cq02h[NR-1:0] <= tk_nx_cq02h[NR-1:0];
        vc2_cq02h[NR-1:0] <= tk_nx_cq02h[NR-1:0];
        vc3_cq02h[NR-1:0] <= tk_nx_cq02h[NR-1:0];
        hr_cq02h              <= hr_nx_cq02h;
      end
      if (miu_en_cq01h) begin
        valid_cq02h[N-1:NR]   <= valid_nx_cq02h[N-1:NR];
        valid_o_cq02h[N-1:NR] <= valid_nx_cq02h[N-1:NR];
        vc0_cq02h[N-1:NR] <= tk_nx_cq02h[N-1:NR];
        vc1_cq02h[N-1:NR] <= tk_nx_cq02h[N-1:NR];
        vc2_cq02h[N-1:NR] <= tk_nx_cq02h[N-1:NR];
        vc3_cq02h[N-1:NR] <= tk_nx_cq02h[N-1:NR];
        hm_cq02h              <= hm_nx_cq02h;
      end
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rcu_en_cq01h) begin
      dep_cq02h[NR*N-1:0]    <= dep_nx_cq02h[NR*N-1:0];
      code_cq02h[2*NR*N-1:0] <= code_nx_cq02h[2*NR*N-1:0];
      prod_cq02h[NR-1:0]     <= prod_nx_cq01h[NR-1:0];
      prod_oc_cq02h[NR-1:0]  <= prod_nx_cq01h[NR-1:0];
      emp_cq02h[NR-1:0]      <= emp_nx_cq02h[NR-1:0];
      kc_cq02h[5*NR-1:0]     <= kc_nx_cq01h[5*NR-1:0];
    end
    if (miu_en_cq01h) begin
      dep_cq02h[N*N-1:NR*N]    <= dep_nx_cq02h[N*N-1:NR*N];
      code_cq02h[2*N*N-1:2*NR*N] <= code_nx_cq02h[2*N*N-1:2*NR*N];
      prod_cq02h[N-1:NR]     <= prod_nx_cq01h[N-1:NR];
      prod_oc_cq02h[N-1:NR]  <= prod_nx_cq01h[N-1:NR];
      emp_cq02h[N-1:NR]      <= emp_nx_cq02h[N-1:NR];
      kc_cq02h[5*N-1:5*NR]   <= kc_nx_cq01h[5*N-1:5*NR];
    end
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
