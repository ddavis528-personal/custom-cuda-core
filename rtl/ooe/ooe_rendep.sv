//===-- ooe_rendep.sv - OOE rename's producer lookup: the RS rows -----===//
//
// Spec: docs/design-snapshots/ooe-microarchitecture.md, Stage boundaries
//       (Rename 2: producer map and in-group override; Rename 3: matrix
//       write); docs/ooe-rtl-plan.md, ooe_rename, slice 2.
//
// Rename 2's lookup and rename's stage register: for each uop of the group
// in Rename 2, the RS entries its sources wait on and each cell's wake line,
// registered by allocation port for ooe_rs to write at Rename 3.
//
// A source's newest producer is, in priority: an older uop of this group
// (the RAT read through the pending group gave the younger the older's new
// name), the group in Rename 3 now (G-1, allocating at this edge), the one
// allocated at the last edge (G-2, whose entries are ooe_rs's registered
// grant now), then ooe_prodmap's entries, which hold everything allocated
// two edges ago or more. Names are unique while allocated, so the priority
// only drops a stale hit. G-2's hits and ooe_prodmap's resolve here into
// row bits; the same grant masks ooe_prodmap's names for G-2's entries,
// which it has not rewritten yet. G-1's entries are known only from the
// grant at the next edge, so its hits leave as port-to-port bits (prv_dep,
// prv_code: port p waits on the last group's port q), which ooe_rs maps
// through its own registered grant, as it maps grp_dep (this group's port q)
// through this edge's. ooe_rs masks a row with its valid bits and last
// edge's allocations, which drops a hit on an entry freed or re-allocated
// since Rename 2.
//
// Ports are packed per class in allocation order: each uop's main entry,
// then a masked load's copy on the RCU port after it (as ooe_rs and
// ooe_prodmap number them). A masked load's main entry and its copy both
// produce its GPR name; the predicate's producer is the main entry. The
// main reads the sources; the copy reads the old destination (as kGrpInt)
// and the guard (A-38).
//
// Codes. A cell's code is the producer's wake line for the consumer's
// bypass group, CT[unit][producer group][consumer group]: the pair's
// penalty index, or 3 (the late line, the PRF read) where the model's
// bypWake gives none. A producer with no bypass (a memop, a copy, a
// cross-lane op) is late for every group, and so is a predicate source and
// a consumer RCU executes (cnone). Each RS entry keeps its occupant's code
// per consumer group, written with ooe_prodmap's names (a cycle after
// Rename 3, from the registered grant); G-1's and G-2's ride with their
// ports. Two sources on one producer take the later line, the larger code
// (the model's dep() keeps the later wake).
//
// Not here: atomics (AR-21) reach no RTL bench yet and are asserted absent;
// a Rename-3 hold (the go's skid, slice 4) is assumed away: the stage
// register's group allocates at the next edge.
//
// The reference is the model's dependency matrix (Core::depBit, cellCode)
// for each renamed uop's entries; test/ooe/rendep_tb.cpp drives this module
// and ooe_prodmap from the model's renames (Core::ratLog) and checks each
// port's row, a cycle later, against the model's.
//
// Reset line: the stage register, the per-port producer records and the
// code register are payload behind their valid bits and the RS valid bits.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_rendep #(
  parameter int N  = 45,                 // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int A  = 4,                  // uops a group, allocation ports a class (CCV_ISSUE_WIDTH)
  parameter int NG = 768,                // GPR names
  parameter int NP = 48,                 // predicate names
  parameter int NU = 8,                  // lat_class codes
  parameter int G  = 8,                  // bypass groups (CCV_P_BYP_GROUPS)
  // CT[unit][pg][cg], 2 bits each, unit-major: the code for a producer of
  // that lat_class and group read by a consumer of group cg.
  // The default is test/ooe/rendep-params.py's table at today's parameters;
  // run-rtl.sh checks it.
  parameter logic [2*NU*G*G-1:0] CT = 1024'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3ffffffff1fff4ffffffffffffffffffffffffffffffff,
  localparam int W   = $clog2(N),
  localparam int P   = 2 * A,
  localparam int LG  = $clog2(NG),
  localparam int LQ  = $clog2(NP),
  localparam int CVW = 2 * G,             // a producer's code per consumer group
  localparam int NS  = 4                  // GPR sources a uop: src0..2 and the merge source
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  input  logic              v_l_cq00h,      // a group enters Rename 2 next cycle (Rename 1's valid)
  // The group in Rename 2, uop by uop in order.
  input  logic [A-1:0]      v_cq01h,        // uop u renames
  input  logic [A-1:0]      mem_cq01h,      // its main entry is MIU class
  input  logic [A-1:0]      cp_cq01h,       // it has a copy (a masked load)
  input  logic [A-1:0]      atom_cq01h,     // an atomic (AR-21): asserted absent
  input  logic [A-1:0]      gwe_cq01h,      // it writes a GPR
  input  logic [A*LG-1:0]   gname_cq01h,    //   its new name
  input  logic [A-1:0]      pwe_cq01h,      // it writes a predicate
  input  logic [A*LQ-1:0]   pname_cq01h,    //   its new name
  input  logic [A*NS-1:0]   gsv_cq01h,      // the main reads GPR source s (s 3: the merge source)
  input  logic [A*NS*LG-1:0] gsn_cq01h,     //   its name (s 3: the old destination, which a copy reads)
  input  logic [A*4-1:0]    psv_cq01h,      // the main reads predicate source s (guard, q0, q1, old)
  input  logic [A*4*LQ-1:0] psn_cq01h,      //   its name
  input  logic [A-1:0]      cguard_cq01h,   // the copy reads the guard (psn s 0)
  input  logic [A*3-1:0]    cg_cq01h,       // the main's consumer group
  input  logic [A-1:0]      cnone_cq01h,    //   none: RCU executes it, so it reads the PRF (late)
  input  logic [A*3-1:0]    unit_cq01h,     // as a producer: its lat_class
  input  logic [A*3-1:0]    pg_cq01h,       //   its bypass group
  input  logic [A-1:0]      nob_cq01h,      //   no bypass (a memop, a cross-lane op)
  // ooe_prodmap's entries (their names, two edges after allocation or more).
  input  logic [N-1:0]      eg_cq01h,
  input  logic [N*LG-1:0]   egn_cq01h,
  input  logic [N-1:0]      ep_cq01h,
  input  logic [N*LQ-1:0]   epn_cq01h,
  // ooe_rs's registered grant: the entries G-2's ports took at the last edge.
  input  logic [P-1:0]      gnt_v_cq01h,
  input  logic [P*W-1:0]    gnt_idx_cq01h,
  // Rename's stage register, to ooe_rs at Rename 3.
  output logic [P-1:0]      row_prod_cq02h,
  output logic [P*N-1:0]    row_dep_cq02h,
  output logic [2*P*N-1:0]  row_code_cq02h,
  output logic [P*P-1:0]    grp_dep_cq02h,
  output logic [2*P*P-1:0]  grp_code_cq02h,
  output logic [P*P-1:0]    prv_dep_cq02h,
  output logic [2*P*P-1:0]  prv_code_cq02h
);

  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  `CCV_ASSERT_KNOWN(v_l_known, v_l_cq00h)
  `CCV_ASSERT_KNOWN(v_known, v_cq01h)
  `CCV_ASSERT_KNOWN(gnt_v_known, gnt_v_cq01h)
  `CCV_ASSERT(no_atomic, (atom_cq01h & v_cq01h) == '0)
  `CCV_ASSERT(copy_on_mem, (cp_cq01h & v_cq01h & ~mem_cq01h) == '0)

  localparam logic [1:0] LATE = 2'd3;

  // A producer's code for each consumer group.
  function automatic logic [CVW-1:0] codes_of(input logic [2:0] unit, input logic [2:0] pg, input logic nob);
    logic [CVW-1:0] c;
    for (int g = 0; g < G; g++) begin
      c[g * 2 +: 2] = LATE;
      if (!nob)
        for (int un = 0; un < NU; un++)
          for (int p = 0; p < G; p++)
            if (unit == 3'(un) && pg == 3'(p)) c[g * 2 +: 2] = CT[((un * G + p) * G + g) * 2 +: 2];
    end
    codes_of = c;
  endfunction
  function automatic logic [1:0] code_for(input logic [CVW-1:0] cv, input logic [2:0] cg, input logic none);
    logic [1:0] c;
    c = LATE;
    for (int g = 0; g < G; g++) if (!none && cg == 3'(g)) c = cv[g * 2 +: 2];
    code_for = c;
  endfunction
  function automatic logic [1:0] cmax(input logic [1:0] a, input logic [1:0] b);
    cmax = a > b ? a : b;
  endfunction

  // -- Leads -----------------------------------------------------------------
  // grp_l: a group is in Rename 2 now (Rename 1's valid, flopped); st_v: one
  // is in the stage register (Rename 3); g2_v: one allocated at the last edge.
  logic grp_l_cq01h, st_v_cq02h, g2_v_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      grp_l_cq01h <= 1'b0;
      st_v_cq02h  <= 1'b0;
      g2_v_cq03h  <= 1'b0;
    end else begin
      grp_l_cq01h <= v_l_cq00h;
      st_v_cq02h  <= grp_l_cq01h;
      g2_v_cq03h  <= st_v_cq02h;
    end
  end
  `CCV_ASSERT(grp_led, v_cq01h == '0 || grp_l_cq01h)

  // -- This group's ports --------------------------------------------------------
  // Port of uop u's main entry and of its copy, and per port the producer it
  // holds: its names and its code per consumer group.
  logic [A*3-1:0]   pm, pcp;            // port within its class (0..A-1)
  logic [P-1:0]     pv, pgv, ppv;       // the port is taken; it produces a GPR, a predicate
  logic [P*LG-1:0]  pgn;
  logic [P*LQ-1:0]  ppn;
  logic [P*CVW-1:0] pcv;
  logic [P-1:0]     pprod;
  logic [A*CVW-1:0] pcv_c;              // each uop's main entry's codes, by uop
  always_comb
    for (int u = 0; u < A; u++) pcv_c[u * CVW +: CVW] = codes_of(unit_cq01h[u * 3 +: 3], pg_cq01h[u * 3 +: 3], nob_cq01h[u]);
  int nr, nm;                           // each class's ports taken so far
  always_comb begin
    nr = 0;
    nm = 0;
    pm = '0; pcp = '0;
    for (int u = 0; u < A; u++)
      if (v_cq01h[u]) begin
        if (mem_cq01h[u]) begin
          pm[u * 3 +: 3] = 3'(A + nm);
          nm = nm + 1;
        end else begin
          pm[u * 3 +: 3] = 3'(nr);
          nr = nr + 1;
        end
        if (cp_cq01h[u]) begin
          pcp[u * 3 +: 3] = 3'(nr);
          nr = nr + 1;
        end
      end
  end
  // Rename takes no more than A entries a class (V-55's per-cycle bound).
  `CCV_ASSERT(ports_fit, nr <= A && nm <= A)

  // -- The earlier groups' producers, by port ------------------------------------
  // G-1: the stage register's group (this module registered its ports at the
  // last edge); G-2: the group before it, whose entries the grant names now.
  logic [P-1:0]     g1gv_cq02h, g1pv_cq02h, g2gv_cq03h, g2pv_cq03h;
  logic [P*LG-1:0]  g1gn_cq02h, g2gn_cq03h;
  logic [P*LQ-1:0]  g1pn_cq02h, g2pn_cq03h;
  logic [P*CVW-1:0] g1cv_cq02h, g2cv_cq03h;

  // The grant, decoded: G-2's entry by port, and every entry it took.
  logic [P*N-1:0] g2e;
  logic [N-1:0]   g2any;
  always_comb begin
    g2e   = '0;
    g2any = '0;
    for (int r = 0; r < P; r++)
      for (int j = 0; j < N; j++)
        if (gnt_v_cq01h[r] && gnt_idx_cq01h[r * W +: W] == W'(j)) begin
          g2e[r * N + j] = 1'b1;
          g2any[j]       = 1'b1;
        end
  end

  // The code register: each entry's occupant's code per consumer group.
  logic [N*CVW-1:0] ecv_cq02h;

  // -- Rename 2: each consumer's row, then each port's -----------------------------
  // Consumer c = 2u + k: uop u's main entry (k 0) or its copy (k 1). Every
  // index below is static: a consumer's row is formed by consumer, and the
  // ports take theirs through one-hot selects, so no write goes through a
  // computed index.
  localparam int C = 2 * A;
  logic [C-1:0]      cv;                // consumer c exists
  logic [C*P-1:0]    coh;               // consumer c sits on port p
  logic [C*3-1:0]    ccg;               // its consumer group
  logic [C-1:0]      ccn;               //   none (late)
  logic [C*NS-1:0]   cgs;               // it reads GPR source s
  logic [C*4-1:0]    cps;               // it reads predicate source s
  always_comb
    for (int u = 0; u < A; u++)
      for (int k = 0; k < 2; k++) begin
        cv[2 * u + k]                = v_cq01h[u] && (k == 0 || cp_cq01h[u]);
        ccg[(2 * u + k) * 3 +: 3]    = k == 0 ? cg_cq01h[u * 3 +: 3] : 3'd0;   // the copy reads as kGrpInt
        ccn[2 * u + k]               = k == 0 && cnone_cq01h[u];
        for (int s = 0; s < NS; s++)
          cgs[(2 * u + k) * NS + s]  = k == 0 ? gsv_cq01h[u * NS + s] : (s == 3);
        for (int s = 0; s < 4; s++)
          cps[(2 * u + k) * 4 + s]   = k == 0 ? psv_cq01h[u * 4 + s] : (s == 0 && cguard_cq01h[u]);
        for (int q = 0; q < P; q++)
          coh[(2 * u + k) * P + q]   = cv[2 * u + k] && 32'(k == 0 ? pm[u * 3 +: 3] : pcp[u * 3 +: 3]) == q;
      end

  // Each port's producer, through the one-hot select: consumer c's uop
  // on the port it sits on (a copy produces its GPR alone, with no bypass).
  always_comb begin
    pv = '0; pgv = '0; ppv = '0; pgn = '0; ppn = '0; pcv = '0; pprod = '0;
    for (int q = 0; q < P; q++)
      for (int c = 0; c < C; c++)
        if (coh[c * P + q]) begin
          pv[q]               = 1'b1;
          pgv[q]              = pgv[q] | gwe_cq01h[c / 2];
          pgn[q * LG +: LG]   = pgn[q * LG +: LG] | gname_cq01h[(c / 2) * LG +: LG];
          if (c % 2 == 0) begin
            ppv[q]               = ppv[q] | pwe_cq01h[c / 2];
            ppn[q * LQ +: LQ]    = ppn[q * LQ +: LQ] | pname_cq01h[(c / 2) * LQ +: LQ];
            pcv[q * CVW +: CVW]  = pcv[q * CVW +: CVW] | pcv_c[(c / 2) * CVW +: CVW];
            pprod[q]             = pprod[q] | gwe_cq01h[c / 2] | pwe_cq01h[c / 2];
          end else begin
            pcv[q * CVW +: CVW]  = pcv[q * CVW +: CVW] | {G{LATE}};
            pprod[q]             = 1'b1;
          end
        end
  end

  // A source's newest producer is, by class: an older uop of this group
  // (its main, and its copy), G-1's port, G-2's port, or ooe_prodmap's
  // entry. Names are unique while allocated, so a hit in an older class
  // beside a newer one is stale, and only the port classes need the order:
  // an in-group producer hides G-1's. An entry hit (G-2's or
  // ooe_prodmap's) beside a newer one names an entry no longer the name's
  // producer: invalid, freed at this edge, or re-occupied at the last, and
  // ooe_rs's row mask drops each (its valid bits, its frees, its last
  // grant; G-2's stale names here). Leaving them unordered keeps the
  // compares off each other's paths. First, the in-group class.
  logic [C*NS-1:0] gig;                 // GPR source (c, s) has an in-group producer
  logic [C*4-1:0]  pig;                 // predicate source (c, s)
  always_comb begin
    gig = '0; pig = '0;
    for (int c = 0; c < C; c++) begin
      for (int s = 0; s < NS; s++)
        for (int w = 0; w < A; w++)
          if (w < c / 2 && v_cq01h[w] && gwe_cq01h[w] &&
              gname_cq01h[w * LG +: LG] == gsn_cq01h[((c / 2) * NS + s) * LG +: LG]) gig[c * NS + s] = 1'b1;
      for (int s = 0; s < 4; s++)
        for (int w = 0; w < A; w++)
          if (w < c / 2 && v_cq01h[w] && pwe_cq01h[w] &&
              pname_cq01h[w * LQ +: LQ] == psn_cq01h[((c / 2) * 4 + s) * LQ +: LQ]) pig[c * 4 + s] = 1'b1;
    end
  end
  // Then the hits: G-1's where no older uop of this group produces it, the
  // entries' unordered.
  logic [C*N-1:0]   xr, xrp;            // consumer c's ooe_prodmap and G-2 hits: by GPR, by predicate source
  logic [C*P-1:0]   x1, x1p;            // its G-1 hits (port r)
  logic [C*C-1:0]   xg, xgp;            // its in-group hits (consumer d of an older uop)
  always_comb begin
    xr = '0; xrp = '0; x1 = '0; x1p = '0; xg = '0; xgp = '0;
    for (int c = 0; c < C; c++) begin
      for (int s = 0; s < NS; s++)
        if (cv[c] && cgs[c * NS + s]) begin
          for (int w = 0; w < A; w++)
            if (w < c / 2 && v_cq01h[w] && gwe_cq01h[w] &&
                gname_cq01h[w * LG +: LG] == gsn_cq01h[((c / 2) * NS + s) * LG +: LG]) begin
              xg[c * C + 2 * w] = 1'b1;
              if (cp_cq01h[w]) xg[c * C + 2 * w + 1] = 1'b1;
            end
          for (int r = 0; r < P; r++)
            if (!gig[c * NS + s] && g1gv_cq02h[r] && g1gn_cq02h[r * LG +: LG] == gsn_cq01h[((c / 2) * NS + s) * LG +: LG])
              x1[c * P + r] = 1'b1;
          for (int r = 0; r < P; r++)
            if (g2gv_cq03h[r] && g2gn_cq03h[r * LG +: LG] == gsn_cq01h[((c / 2) * NS + s) * LG +: LG])
              xr[c * N +: N] = xr[c * N +: N] | g2e[r * N +: N];
          for (int j = 0; j < N; j++)
            if (eg_cq01h[j] && !g2any[j] &&
                egn_cq01h[j * LG +: LG] == gsn_cq01h[((c / 2) * NS + s) * LG +: LG])
              xr[c * N + j] = 1'b1;
        end
      for (int s = 0; s < 4; s++)
        if (cv[c] && cps[c * 4 + s]) begin
          for (int w = 0; w < A; w++)
            if (w < c / 2 && v_cq01h[w] && pwe_cq01h[w] &&
                pname_cq01h[w * LQ +: LQ] == psn_cq01h[((c / 2) * 4 + s) * LQ +: LQ])
              xgp[c * C + 2 * w] = 1'b1;
          for (int r = 0; r < P; r++)
            if (!pig[c * 4 + s] && g1pv_cq02h[r] && g1pn_cq02h[r * LQ +: LQ] == psn_cq01h[((c / 2) * 4 + s) * LQ +: LQ])
              x1p[c * P + r] = 1'b1;
          for (int r = 0; r < P; r++)
            if (g2pv_cq03h[r] && g2pn_cq03h[r * LQ +: LQ] == psn_cq01h[((c / 2) * 4 + s) * LQ +: LQ])
              xrp[c * N +: N] = xrp[c * N +: N] | g2e[r * N +: N];
          for (int j = 0; j < N; j++)
            if (ep_cq01h[j] && !g2any[j] &&
                epn_cq01h[j * LQ +: LQ] == psn_cq01h[((c / 2) * 4 + s) * LQ +: LQ])
              xrp[c * N + j] = 1'b1;
        end
    end
  end

  // The codes: a GPR source reads its producer's code for the consumer's
  // group; a predicate source the late line, the largest code, so a cell
  // either source reaches takes the larger by that alone. ooe_prodmap's and
  // G-2's entries share the code register's view: G-2's entries take their
  // port's codes, the rest the register's.
  // An entry is granted to one port at most, so G-2's codes reach it
  // through a one-hot select, not an override in port order.
  logic [N*CVW-1:0] jcv;                // each entry's codes as this lookup sees them
  logic [N*CVW-1:0] g2cv_e;             // G-2's codes, by the entry the grant gives
  always_comb begin
    g2cv_e = '0;
    for (int r = 0; r < P; r++)
      for (int j = 0; j < N; j++)
        if (g2e[r * N + j]) g2cv_e[j * CVW +: CVW] = g2cv_e[j * CVW +: CVW] | g2cv_cq03h[r * CVW +: CVW];
    for (int j = 0; j < N; j++)
      jcv[j * CVW +: CVW] = g2any[j] ? g2cv_e[j * CVW +: CVW] : ecv_cq02h[j * CVW +: CVW];
  end
  logic [C*N*2-1:0] xrc;
  logic [C*P*2-1:0] x1c;
  logic [C*C*2-1:0] xgc;
  always_comb
    for (int c = 0; c < C; c++) begin
      for (int j = 0; j < N; j++)
        xrc[(c * N + j) * 2 +: 2] = code_for(jcv[j * CVW +: CVW], ccg[c * 3 +: 3], ccn[c]) | {2{xrp[c * N + j]}};
      for (int r = 0; r < P; r++)
        x1c[(c * P + r) * 2 +: 2] = code_for(g1cv_cq02h[r * CVW +: CVW], ccg[c * 3 +: 3], ccn[c]) | {2{x1p[c * P + r]}};
      for (int d = 0; d < C; d++)
        xgc[(c * C + d) * 2 +: 2] = xgp[c * C + d] || d % 2 == 1 ? LATE
                                    : code_for(pcv_c[(d / 2) * CVW +: CVW], ccg[c * 3 +: 3], ccn[c]);
    end

  // Each port's row: its consumer's, through the one-hot select; an
  // in-group producer d is the port its consumer sits on.
  logic [P*N-1:0]   rd;
  logic [2*P*N-1:0] rc;
  logic [P*P-1:0]   gd, vd;
  logic [2*P*P-1:0] gc, vc;
  always_comb begin
    rd = '0; rc = '0; gd = '0; gc = '0; vd = '0; vc = '0;
    for (int p = 0; p < P; p++)
      for (int c = 0; c < C; c++)
        if (coh[c * P + p]) begin
          rd[p * N +: N]           = rd[p * N +: N] | xr[c * N +: N] | xrp[c * N +: N];
          rc[p * N * 2 +: N * 2]   = rc[p * N * 2 +: N * 2] | xrc[c * N * 2 +: N * 2];
          vd[p * P +: P]           = vd[p * P +: P] | x1[c * P +: P] | x1p[c * P +: P];
          vc[p * P * 2 +: P * 2]   = vc[p * P * 2 +: P * 2] | x1c[c * P * 2 +: P * 2];
          for (int d = 0; d < C; d++)
            for (int q = 0; q < P; q++)
              if ((xg[c * C + d] || xgp[c * C + d]) && coh[d * P + q]) begin
                gd[p * P + q]           = 1'b1;
                gc[(p * P + q) * 2 +: 2] = gc[(p * P + q) * 2 +: 2] | xgc[(c * C + d) * 2 +: 2];
              end
        end
    // A code is payload, read only through its bit (ooe_rs's code register
    // keeps none without one), so it leaves unmasked: the hits stay off the
    // codes' paths.
  end

  // -- Rename's stage register, and G-1's ports ----------------------------------------
  // Clocked when a group is in Rename 2 now, and the cycle after, to clear
  // (grp_l from Rename 1's valid: the module's own flop).
  logic st_en;
  assign st_en = grp_l_cq01h || st_v_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (st_en) begin
      row_prod_cq02h <= pprod & pv;
      row_dep_cq02h  <= rd;
      row_code_cq02h <= rc;
      grp_dep_cq02h  <= gd;
      grp_code_cq02h <= gc;
      prv_dep_cq02h  <= vd;
      prv_code_cq02h <= vc;
      g1gv_cq02h     <= pgv & pv;
      g1pv_cq02h     <= ppv & pv;
      g1gn_cq02h     <= pgn;
      g1pn_cq02h     <= ppn;
      g1cv_cq02h     <= pcv;
    end
  end
  // G-2: G-1's ports a cycle on, when the stage register held a group, and
  // the cycle after, to clear.
  logic g2_en;
  assign g2_en = st_v_cq02h || g2_v_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (g2_en) begin
      g2gv_cq03h <= g1gv_cq02h & {P{st_v_cq02h}};
      g2pv_cq03h <= g1pv_cq02h & {P{st_v_cq02h}};
      g2gn_cq03h <= g1gn_cq02h;
      g2pn_cq03h <= g1pn_cq02h;
      g2cv_cq03h <= g1cv_cq02h;
    end
  end

  // -- The code register ------------------------------------------------------------
  // Written with ooe_prodmap's names: G-2's ports' codes into the entries
  // the grant gives them, when G-2 holds a group (the module's own flop).
  logic [N*CVW-1:0] ecv_nx;
  assign ecv_nx = jcv;
  always_ff @(posedge ooe_core_clk) begin
    if (g2_v_cq03h) ecv_cq02h <= ecv_nx;
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
