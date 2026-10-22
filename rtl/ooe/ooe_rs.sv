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
// The outputs' grant register is clocked on the request leads; the valid
// copy with its class. The reset is flopped (RST-1).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_rs #(
  parameter int N  = 45,                 // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int NR = 30,                 // RCU-class entries, [0, NR)
  parameter int A  = 4,                  // allocation ports per class (CCV_ISSUE_WIDTH)
  parameter int NC = 4,                  // completions a cycle (ccv_miu_ooe_cmpl's rate)
  localparam int P  = 2 * A,             // ports: RCU's 0..A-1, then MIU's
  localparam int W  = $clog2(N)
) (
  input  logic             ooe_core_clk,
  input  logic             ooe_rst_r00h,
  input  logic [P-1:0]     req_l_cq00h,  // port p allocates next cycle (rename's Rename 2 valid)
  input  logic [P-1:0]     req_cq01h,    // port p allocates
  input  logic [P-1:0]     row_prod_cq01h, // port p's entry writes a register some entry may wake on
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
  input  logic [N-1:0]     gnt_cq00h,    // granted: issued from the next edge
  input  logic [NC-1:0]    cmpl_l_cq00h, // the completion channel's valid: a payload next cycle
  input  logic [NC*W-1:0]  cmpl_idx_cq00h, // each completion's RS entry (its payload)
  input  logic             sq_l_cq00h,   // the registered squash frees next cycle
  output logic [P-1:0]     gnt_v_cq03h,  // port p was granted, at the last edge
  output logic [P*W-1:0]   gnt_idx_cq03h, // port p's entry
  output logic [N-1:0]     valid_out_cq02h, // the valid bits (a copy for the outputs)
  output logic [N*N-1:0]   dep_cq02h,    // row i, column j: i waits on j
  output logic [2*N*N-1:0] code_cq02h,   // the cell's wake-line select
  output logic [N-1:0]     prod_o_cq02h,  // each entry writes a register some entry may wake on (ooe_sched's
                                         // confirmation, OI-45)
  output logic [N-1:0]     hcol_cq02h    // a row has named the entry since it was allocated
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
    d = rd;
    for (int p = 0; p < P; p++)
      for (int j = 0; j < N; j++)
        cd[(p * N + j) * 2 +: 2] = rc[(p * N + j) * 2 +: 2] & {2{keep[j]}};
    for (int p = 0; p < P; p++)
      for (int q = 0; q < P; q++)
        for (int j = 0; j < N; j++) begin
          if (q != p && gd[p * P + q] && g[q * N + j]) begin
            d[p * N + j]             = 1'b1;
            cd[(p * N + j) * 2 +: 2] = cd[(p * N + j) * 2 +: 2] | gc[(p * P + q) * 2 +: 2];
          end
          if (vd[p * P + q] && lg[q * N + j]) begin
            d[p * N + j]             = 1'b1;
            cd[(p * N + j) * 2 +: 2] = cd[(p * N + j) * 2 +: 2] | vc[(p * P + q) * 2 +: 2];
          end
        end
    rows_of = {cd, d};
  endfunction

  (* keep *) logic [N-1:0] valid_cq02h;  // the valid bits, for allocation and the rows
  (* keep *) logic [N-1:0] prod_cq02h;   // payload: read only while its entry is valid
  // The prod bits' copy for ooe_sched (NGD-7: the register starts paths
  // inside deeper than the output's budget allows).
  (* keep *) logic [N-1:0] prod_oc_cq02h;
  assign prod_o_cq02h = prod_oc_cq02h;
  logic [N-1:0]     cf_en_cq01h;          // the confirmation leads' flops
  logic [NC-1:0]    cva_cq01h;            // the completion channel's valid, flopped: its payload is here
  logic             cvb_cq02h;            // a payload arrived at the last edge
  logic             sq_en_cq01h;          // the registered squash's lead's flop
  logic [N-1:0]     hr_cq02h, hm_cq02h;   // the column flags, from RCU rows and MIU rows
  logic [P*N-1:0]   g_cq02h;
  logic [P-1:0]     gv_cq02h;
  logic [P*W-1:0]   gi_cq02h;
  logic [P*N-1:0]   d_cq02h;
  logic [2*P*N-1:0] cd_cq02h;
  // -- Confirmation, here (OI-45, OI-50; V-65) --------------------------------
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
  logic [N-1:0] iss_cq02h, emp_cq02h, gone, rep, conf, free_cq01h;
  always_comb begin
    gone = ~iss_cq02h | msd_cq01h;
    for (int i = 0; i < N; i++) begin
      rep[i]  = iss_cq02h[i] && |(dep_cq02h[i * N +: N] & gone);
      conf[i] = iss_cq02h[i] && emp_cq02h[i] && (cfin_cq01h[i] || !prod_cq02h[i]);
    end
  end
  assign free_cq01h = conf | sqf_cq01h;
  // Outside any gate, within the module's allowance: a grant has no lead
  // here (select's grant register is ooe_sched's), nor has a replay.
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) iss_cq02h <= '0;
    else          iss_cq02h <= (iss_cq02h & ~rep & ~free_cq01h) | gnt_cq00h;
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
  logic [N-1:0] rmask;
  assign rmask = valid_cq02h & ~free_cq01h & ~lga_cq02h;
  always_comb begin
    g_cq02h = grants(valid_cq02h, req_cq01h);
    {cd_cq02h, d_cq02h} = rows_of(g_cq02h, row_dep_cq01h & {P{rmask}}, row_code_cq01h, grp_dep_cq01h,
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
  logic         gnt_en, gnt_v_en;
  assign gnt_en   = req_en_cq01h != '0;
  assign gnt_v_en = req_en_cq01h != gnt_v_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h)      gnt_v_cq03h <= '0;
    else if (gnt_v_en) gnt_v_cq03h <= gv_cq02h;
  end
  always_ff @(posedge ooe_core_clk) begin
    if (gnt_en) gnt_idx_cq03h <= gi_cq02h;   // payload, read through gnt_v
  end
  logic lg_en;
  assign lg_en = gnt_en || gnt_v_en;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      lg_cq02h  <= '0;
      lgv_cq02h <= '0;
      lga_cq02h <= '0;
    end else if (lg_en) begin
      lg_cq02h  <= g_cq02h;
      lgv_cq02h <= gv_cq02h;
      lga_cq02h <= ga_cq02h;
    end
  end
  assign valid_out_cq02h = valid_o_cq02h;

  // Rename checks the RS for room first, so every port that asks is granted.
  `CCV_ASSERT(alloc_granted, (req_cq01h & ~gv_cq02h) == '0)
  // A free names a valid entry.
  `CCV_ASSERT(free_valid, (free_cq01h & ~valid_cq02h) == '0)
  // What ooe_wake and ooe_sched report, and a completion's payload, name
  // only entries valid here (their benches drive them so; the assembled
  // block holds them to it).
  logic [N-1:0] cpv;
  always_comb begin
    cpv = '0;
    for (int k = 0; k < NC; k++)
      if (cva_cq01h[k]) cpv[cmpl_idx_cq00h[k * W +: W]] = 1'b1;
  end
  `CCV_ASSERT(wake_names_valid, ((gnt_cq00h | fin_cq00h | wtl3_cq00h | cpv | msd_cq01h) & ~valid_cq02h) == '0)
  // A valid row's emptiness register is its row's (payload elsewhere).
  logic [N-1:0] emp_ok;
  always_comb
    for (int i = 0; i < N; i++) emp_ok[i] = !valid_cq02h[i] || emp_cq02h[i] == (dep_cq02h[i * N +: N] == '0);
  `CCV_ASSERT(row_empty_kept, emp_ok == '1)
  // A squash frees valid entries, none of them confirming now.
  `CCV_ASSERT(squash_free_valid, (sqf_cq01h & ~valid_cq02h) == '0)
  // Every request and every free was led.
  `CCV_ASSERT(req_led, (req_cq01h & ~req_en_cq01h) == '0)
  `CCV_ASSERT(free_led, sq_en_cq01h || (free_cq01h & ~cf_en_cq01h) == '0)

  // The next state. An entry a port takes gets the port's row; every other
  // row keeps its bits, less the columns freed this cycle, and its line
  // selects where its bits were set (a select is read only there, and
  // taking the bit from its flop keeps the free off the select's write). Per class, a
  // column is flagged from the edge a row of the class naming it is written
  // until the entry is freed, unless a row written at that same edge names
  // its next occupant; a set bit in a class's row is always flagged there.
  logic [N-1:0]     valid_nx, prod_nx, emp_nx;
  logic             emp_g;
  logic [P-1:0]     emp_new;
  logic [N*N-1:0]   dep_nx;
  logic [2*N*N-1:0] code_nx;
  logic [N-1:0]     hr_nx, hm_nx, named_r, named_m;
  logic [2*N*N-1:0] dep2;    // each cell's bit, twice, as the line selects lie
  logic             hit;
  always_comb begin
    for (int c = 0; c < N * N; c++) dep2[c * 2 +: 2] = {2{dep_cq02h[c]}};
    named_r = '0;
    named_m = '0;
    for (int i = 0; i < N; i++) begin
      hit = 1'b0;
      dep_nx[i * N +: N]           = dep_cq02h[i * N +: N] & ~free_cq01h;
      code_nx[i * 2 * N +: 2 * N] = code_cq02h[i * 2 * N +: 2 * N] & dep2[i * 2 * N +: 2 * N];
      for (int p = 0; p < P; p++)
        if (g_cq02h[p * N + i]) begin
          hit                          = 1'b1;
          dep_nx[i * N +: N]           = d_cq02h[p * N +: N];
          code_nx[i * 2 * N +: 2 * N] = cd_cq02h[p * 2 * N +: 2 * N];
        end
      valid_nx[i] = hit || (valid_cq02h[i] && !free_cq01h[i]);
      // Its prod bit, from its port; cleared with its valid bit (read only
      // while valid), so it shares its class's enable.
      prod_nx[i]  = prod_cq02h[i] && !free_cq01h[i];
      for (int p = 0; p < P; p++)
        if (g_cq02h[p * N + i]) prod_nx[i] = row_prod_cq01h[p];
    end
    for (int p = 0; p < P; p++)
      if (|g_cq02h[p * N +: N]) begin
        if (p < A) named_r = named_r | d_cq02h[p * N +: N];
        else       named_m = named_m | d_cq02h[p * N +: N];
      end
    // Emptiness in parallel with the rows: a kept row's from its flops less
    // the frees; a new one's from its port's inputs, before any grant (a
    // row naming a port of its group names a granted entry: every port that
    // asks is granted), then steered with the row.
    for (int p = 0; p < P; p++)
      emp_new[p] = (row_dep_cq01h[p * N +: N] & rmask) == '0 &&
                   (grp_dep_cq01h[p * P +: P] & req_cq01h & ~(P'(1) << p)) == '0 &&
                   (prv_dep_cq01h[p * P +: P] & lgv_cq02h) == '0;
    for (int i = 0; i < N; i++) begin
      // An entry is granted to one port at most: its new row's flag through
      // a one-hot select, not an override in port order (NGD-7: dep).
      emp_g = 1'b0;
      for (int p = 0; p < P; p++) emp_g = emp_g | (g_cq02h[p * N + i] & emp_new[p]);
      emp_nx[i] = ga_cq02h[i] ? emp_g : (dep_cq02h[i * N +: N] & ~free_cq01h) == '0;
    end
    hr_nx = (hr_cq02h & ~free_cq01h) | named_r;
    hm_nx = (hm_cq02h & ~free_cq01h) | named_m;
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
  logic [N-1:0] cmn, cf_d;
  always_comb begin
    cmn = '0;
    for (int k = 0; k < NC; k++)
      for (int i = 0; i < N; i++)
        if (cva_cq01h[k] && cmpl_idx_cq00h[k * W +: W] == W'(i)) cmn[i] = 1'b1;
    for (int i = 0; i < N; i++)
      cf_d[i] = valid_cq02h[i] && !free_cq01h[i] && (dep_cq02h[i * N +: N] & ~free_cq01h) == '0 &&
                (prod_cq02h[i] ? wtl3_cq00h[i] || fin_cq00h[i] || cmn[i] || (cf_en_cq01h[i] && cvb_cq02h)
                               : iss_cq02h[i] || gnt_cq00h[i]);
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      req_en_cq01h <= '0;
      cf_en_cq01h  <= '0;
      cva_cq01h    <= '0;
      cvb_cq02h    <= 1'b0;
      sq_en_cq01h  <= 1'b0;
    end else begin
      req_en_cq01h <= req_l_cq00h;
      cf_en_cq01h  <= cf_d;
      cva_cq01h    <= cmpl_l_cq00h;
      cvb_cq02h    <= cva_cq01h != '0;
      sq_en_cq01h  <= sq_l_cq00h;
    end
  end

  // Local clock gating (docs/rtl-coding-style.md). A class's state, its
  // valid bits, rows, line selects, prod bits and column flags, changes
  // only on an allocation in the class, a free in it, or a free of a column
  // its flags name, and is clocked on those leads alone. An idle RS clocks
  // none of it.
  logic rcu_en_cq01h, miu_en_cq01h;
  logic [N-1:0] fl;                    // a free may come: led by confirmation, or a squash
  assign fl = cf_en_cq01h | {N{sq_en_cq01h}};
  assign rcu_en_cq01h = |req_en_cq01h[A-1:0] || |fl[NR-1:0] || |(fl & hr_cq02h);
  assign miu_en_cq01h = |req_en_cq01h[P-1:A] || |fl[N-1:NR] || |(fl & hm_cq02h);

  always_ff @(posedge ooe_core_clk) begin
    // The reset state: every entry free, no column with a dependant. The
    // rows and line selects are payload.
    if (rst_r01h) begin
      valid_cq02h   <= '0;
      valid_o_cq02h <= '0;
      hr_cq02h      <= '0;
      hm_cq02h      <= '0;
    end else begin
      if (rcu_en_cq01h) begin
        valid_cq02h[NR-1:0]   <= valid_nx[NR-1:0];
        valid_o_cq02h[NR-1:0] <= valid_nx[NR-1:0];
        hr_cq02h              <= hr_nx;
      end
      if (miu_en_cq01h) begin
        valid_cq02h[N-1:NR]   <= valid_nx[N-1:NR];
        valid_o_cq02h[N-1:NR] <= valid_nx[N-1:NR];
        hm_cq02h              <= hm_nx;
      end
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rcu_en_cq01h) begin
      dep_cq02h[NR*N-1:0]    <= dep_nx[NR*N-1:0];
      code_cq02h[2*NR*N-1:0] <= code_nx[2*NR*N-1:0];
      prod_cq02h[NR-1:0]     <= prod_nx[NR-1:0];
      prod_oc_cq02h[NR-1:0]  <= prod_nx[NR-1:0];
      emp_cq02h[NR-1:0]      <= emp_nx[NR-1:0];
    end
    if (miu_en_cq01h) begin
      dep_cq02h[N*N-1:NR*N]    <= dep_nx[N*N-1:NR*N];
      code_cq02h[2*N*N-1:2*NR*N] <= code_nx[2*N*N-1:2*NR*N];
      prod_cq02h[N-1:NR]     <= prod_nx[N-1:NR];
      prod_oc_cq02h[N-1:NR]  <= prod_nx[N-1:NR];
      emp_cq02h[N-1:NR]      <= emp_nx[N-1:NR];
    end
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
