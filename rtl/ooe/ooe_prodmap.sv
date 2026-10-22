//===-- ooe_prodmap.sv - OOE producer map: register name to RS entry --===//
//
// Spec: docs/design-snapshots/ooe-microarchitecture.md, Scheduler timing
//       estimate ("Risk handed to the OI track: rename", the
//       physical-register-to-RS map, 768 GPR names) and Stage boundaries
//       (Rename 2: producer lookup); docs/ooe-rtl-plan.md, ooe_rename,
//       slice 1.
//
// Rename's producer map, kept by RS entry: for each entry, the GPR and
// predicate names its occupant produces (a masked load's copy, the GPR
// name alone, A-38: its predicate producer is the main entry). A source's
// producers are the entries valid, not allocated at the last edge, whose
// occupant names it. Rename finds them by comparing the name with every
// entry's (in ooe_rename, from these flops, driven straight out), which
// gives the dependency row's bits directly: no map indexed by name, no
// decode of an entry index, and nothing to clear on a free. A freed entry
// is invalid; a reused one names its new occupant's registers.
//
// A GPR name has at most two producers, a masked load's main entry and its
// copy (ec marks the copy), and a predicate name one; the lookup asserts it
// (OA's response OI-66). The doc's first estimate read a 768-entry map
// indexed by name, 10.8 NGD of lookup mux and a decode. The compare measures 6.4 NGD for 16 GPR
// lookups and 5.5 for predicates (test/ooe/probes/cam_probe.sv), and the
// map's 11,700 flops become these 810.
//
// It is written a cycle after Rename 3, from ooe_rs's registered grant
// (gnt_v, gnt_idx): an entry allocated at an edge has its names after the
// next one, so rename masks the entries its registered grant names (the
// last edge's) and resolves that group's producers from the grant itself.
// Rename gives each uop's names and allocation ports at its Rename 3 (the
// _cq01h inputs), and its Rename 2 valid a cycle before (v_l, L2); this
// module registers them, so the writes a cycle later are enabled by its
// own flops: each RS class's names by its registered ports. The entries
// come from the registered grant by port, as data.
//
// The reference is the model's producer map (Core::gprodOf, pprodOf) and
// its RS valid bits; test/ooe/prodmap_tb.cpp drives this module from the
// model's renames (Core::ratLog: names and entries) and checks, for every
// name after every edge, that the compare finds exactly the model's
// producers.
//
// Each entry also keeps its occupant's wake-line codes by consumer group
// (ooe_rendep's table, given per uop), for ooe_rendep's lookup.
//
// Reset line: the names and codes are payload behind the RS valid bits.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_prodmap #(
  parameter int N  = 45,                 // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int NR = 30,                 // RCU-class entries, [0, NR)
  parameter int A  = 4,                  // allocation ports per class and uops a group (CCV_ISSUE_WIDTH)
  parameter int NG = 768,                // GPR names (CCV_P_PHYS_REGS rows by 4 positions)
  parameter int NP = 48,                 // predicate names (CCV_P_PRED_REGS)
  parameter int G  = 8,                  // bypass groups (CCV_P_BYP_GROUPS)
  localparam int CW = 2 * G,             // a producer's codes, 2 bits a consumer group
  localparam int W  = $clog2(N),
  localparam int P  = 2 * A,             // ports: RCU's 0..A-1, then MIU's
  localparam int LP = $clog2(P),
  localparam int LG = $clog2(NG),
  localparam int LQ = $clog2(NP)
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  input  logic              v_l_cq00h,   // a group allocates next cycle (rename's Rename 2 valid)
  // Each uop of the group in Rename 3, in order: it allocates at this edge.
  input  logic [A-1:0]      v_cq01h,     // uop u allocates (a main entry)
  input  logic [A-1:0]      gwe_cq01h,   // it writes a GPR
  input  logic [A*LG-1:0]   gname_cq01h, // its GPR name
  input  logic [A-1:0]      pwe_cq01h,   // it writes a predicate
  input  logic [A*LQ-1:0]   pname_cq01h, // its predicate name
  input  logic [A*LP-1:0]   pm_cq01h,    // its main entry's port
  input  logic [A-1:0]      cv_cq01h,    // it has a copy (a masked load), on an RCU port
  input  logic [A*LP-1:0]   pc_cq01h,    // the copy's port
  input  logic [A*CW-1:0]   cvc_cq01h,   // its main entry's codes, by consumer group (a copy's are late)
  // ooe_rs's registered grant: the entries those ports took at the edge.
  input  logic [P-1:0]      gnt_v_cq02h,
  input  logic [P*W-1:0]    gnt_idx_cq02h,
  output logic [N-1:0]      eg_cq03h,    // entry e's occupant writes a GPR
  output logic [N*LG-1:0]   egn_cq03h,   // its name
  output logic [N-1:0]      ec_cq03h,    // entry e is a masked load's copy
  output logic [N-1:0]      ep_cq03h,    // and a predicate
  output logic [N*LQ-1:0]   epn_cq03h,   // its name
  output logic [N*CW-1:0]   ecv_cq03h    // its occupant's codes, by consumer group
);

  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  `CCV_ASSERT_KNOWN(v_l_known, v_l_cq00h)
  `CCV_ASSERT_KNOWN(v_known, v_cq01h)
  `CCV_ASSERT_KNOWN_IF(fields_known, |v_cq01h, {gwe_cq01h, pwe_cq01h, cv_cq01h})
  `CCV_ASSERT_KNOWN(gnt_v_known, gnt_v_cq02h)

  // The group, registered: the writes a cycle after Rename 3.
  logic [A-1:0]    v_cq02h, gwe_cq02h, pwe_cq02h, cv_cq02h;
  logic [A*LG-1:0] gname_cq02h;
  logic [A*LQ-1:0] pname_cq02h;
  logic [A*LP-1:0] pm_cq02h, pc_cq02h;
  logic [A*CW-1:0] cvc_cq02h;
  // Leads: grp_l, rename's Rename 2 valid flopped, is set when a group is
  // in Rename 3 now; grp_q, a cycle later, when its writes are.
  logic grp_l_cq01h, grp_q_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      grp_l_cq01h <= 1'b0;
      grp_q_cq02h <= 1'b0;
    end else begin
      grp_l_cq01h <= v_l_cq00h;
      grp_q_cq02h <= grp_l_cq01h;
    end
  end
  `CCV_ASSERT(grp_led, v_cq01h == '0 || grp_l_cq01h)
  // The group's fields are clocked when one is in Rename 3 and cleared the
  // cycle after, so they never hold through an if.
  logic grp_en_cq01h;
  assign grp_en_cq01h = grp_l_cq01h || grp_q_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (grp_en_cq01h) begin
      v_cq02h     <= v_cq01h;
      gwe_cq02h   <= gwe_cq01h & v_cq01h;
      pwe_cq02h   <= pwe_cq01h & v_cq01h;
      cv_cq02h    <= cv_cq01h & v_cq01h;
      gname_cq02h <= gname_cq01h;
      pname_cq02h <= pname_cq01h;
      pm_cq02h    <= pm_cq01h;
      pc_cq02h    <= pc_cq01h;
      cvc_cq02h   <= cvc_cq01h;
    end
  end

  // Each uop's entries, from the grant by its ports.
  logic [A*W-1:0] em_cq02h, ec_cq02h;
  logic [A-1:0]   gm_ok_cq02h, gc_ok_cq02h;
  always_comb begin
    for (int u = 0; u < A; u++) begin
      em_cq02h[u * W +: W] = gnt_idx_cq02h[32'(pm_cq02h[u * LP +: LP]) * W +: W];
      ec_cq02h[u * W +: W] = gnt_idx_cq02h[32'(pc_cq02h[u * LP +: LP]) * W +: W];
      gm_ok_cq02h[u]       = gnt_v_cq02h[pm_cq02h[u * LP +: LP]];
      gc_ok_cq02h[u]       = gnt_v_cq02h[pc_cq02h[u * LP +: LP]];
    end
  end
  // Every uop renamed was granted its ports, and a copy is on an RCU port.
  logic [A-1:0] port_bad_cq02h;
  always_comb
    for (int u = 0; u < A; u++)
      port_bad_cq02h[u] = v_cq02h[u] && (!gm_ok_cq02h[u] || (cv_cq02h[u] && (!gc_ok_cq02h[u] ||
                                                                             32'(pc_cq02h[u * LP +: LP]) >= A)));
  `CCV_ASSERT(granted, grp_q_cq02h == 1'b0 || port_bad_cq02h == '0)

  // -- Each RS entry's names, a gate a class ------------------------------------
  // An entry takes the names of the uop granted it: a main entry both, a
  // copy the GPR name alone (a masked load's predicate producer is its
  // main); and its codes, the uop's for a main entry, the late line for a
  // copy (a copy has no bypass). The codes are the entry's record with its
  // names, written when it is, behind its class's gate.
  logic [N-1:0]    eg_nx, ec_nx, ep_nx;
  logic [N*LG-1:0] egn_nx;
  logic [N*LQ-1:0] epn_nx;
  logic [N*CW-1:0] ecv_nx;
  always_comb begin
    ecv_nx = ecv_cq03h;
    eg_nx  = eg_cq03h;
    ec_nx  = ec_cq03h;
    ep_nx  = ep_cq03h;
    egn_nx = egn_cq03h;
    epn_nx = epn_cq03h;
    for (int u = 0; u < A; u++)
      if (v_cq02h[u]) begin
        for (int e = 0; e < N; e++) begin
          if (em_cq02h[u * W +: W] == W'(e)) begin
            eg_nx[e]               = gwe_cq02h[u];
            ec_nx[e]               = 1'b0;
            egn_nx[e * LG +: LG]   = gname_cq02h[u * LG +: LG];
            ep_nx[e]               = pwe_cq02h[u];
            epn_nx[e * LQ +: LQ]   = pname_cq02h[u * LQ +: LQ];
            ecv_nx[e * CW +: CW]   = cvc_cq02h[u * CW +: CW];
          end
          if (cv_cq02h[u] && ec_cq02h[u * W +: W] == W'(e)) begin
            eg_nx[e]               = gwe_cq02h[u];
            ec_nx[e]               = 1'b1;
            egn_nx[e * LG +: LG]   = gname_cq02h[u * LG +: LG];
            ep_nx[e]               = 1'b0;
            epn_nx[e * LQ +: LQ]   = '0;
            ecv_nx[e * CW +: CW]   = '1;
          end
        end
      end
  end
  // A class is written when a uop of the group takes a main or copy entry
  // in it: from this module's registered ports.
  logic er_en_cq02h, em_en_cq02h;
  always_comb begin
    er_en_cq02h = 1'b0;
    em_en_cq02h = 1'b0;
    for (int u = 0; u < A; u++) begin
      if (v_cq02h[u] && 32'(pm_cq02h[u * LP +: LP]) < A) er_en_cq02h = 1'b1;
      if (v_cq02h[u] && 32'(pm_cq02h[u * LP +: LP]) >= A) em_en_cq02h = 1'b1;
      if (cv_cq02h[u]) er_en_cq02h = 1'b1;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (er_en_cq02h) begin
      eg_cq03h[0 +: NR]        <= eg_nx[0 +: NR];
      ec_cq03h[0 +: NR]        <= ec_nx[0 +: NR];
      ep_cq03h[0 +: NR]        <= ep_nx[0 +: NR];
      egn_cq03h[0 +: NR * LG]  <= egn_nx[0 +: NR * LG];
      epn_cq03h[0 +: NR * LQ]  <= epn_nx[0 +: NR * LQ];
      ecv_cq03h[0 +: NR * CW]  <= ecv_nx[0 +: NR * CW];
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (em_en_cq02h) begin
      eg_cq03h[NR +: N - NR]        <= eg_nx[NR +: N - NR];
      ec_cq03h[NR +: N - NR]        <= ec_nx[NR +: N - NR];
      ep_cq03h[NR +: N - NR]        <= ep_nx[NR +: N - NR];
      egn_cq03h[NR * LG +: (N - NR) * LG] <= egn_nx[NR * LG +: (N - NR) * LG];
      epn_cq03h[NR * LQ +: (N - NR) * LQ] <= epn_nx[NR * LQ +: (N - NR) * LQ];
      ecv_cq03h[NR * CW +: (N - NR) * CW] <= ecv_nx[NR * CW +: (N - NR) * CW];
    end
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
