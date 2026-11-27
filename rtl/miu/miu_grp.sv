// miu_grp: one address slot's group and page check at A2 (MIU tab, MA's
// Phase 2 module table; MA-4, MA-27).
// Spec: docs/design-snapshots/miu-spec.md (live: CCV per-block architecture
//       specs, MIU tab), "The drop" (drop_line, drop_split); MA revs 203, 209.
// Combinational, an inner helper of miu_a2, timed in it (rtl-coding-style.md,
// NGD-5 and NGD-6; MA rev 209): no path may run input to output through a
// module of its own, so it sits inside the module that flops its result.
//
// The memop's F pipes split the warp into F groups of 32/F consecutive
// lanes, each led by its fixed leader, the group's first lane (MA rev 203).
// ok is 0 when an active lane's line (VA[47:7]) is not its leader's
// (drop_line) or two active groups' leaders sit in different pages
// (VA[47:16], drop_split). A group whose leader lane is inactive is the
// parent's drop (la), so a leader is taken as active here. fl is log2 F.
//
// Each lane is compared once with each leader it may have (lane 0's, lane
// 16's, its octet's), and F picks among three OR trees after them, so fl
// drives 3 bits, not every lane's 41-bit leader mux. Lanes 0 and 16 lead
// the most compares; lc is miu_agu8's (* keep *) copy of each (MA rev 209,
// fix (i)), taking the far half of them: lane 0's line drives lanes 1-15
// and the page compares, its copy lanes 16-31; lane 16's drives lanes
// 17-23 and the page compares, its copy lanes 24-31.
module miu_grp #(
  parameter int NL = 32,     // a slot's lanes
  parameter int VW = 50      // a lane's sum, as miu_agu8 flops it
) (
  input  logic [NL-1:0]    am,   // active_mask
  input  logic [NL*VW-1:0] va,
  input  logic [2*41-1:0]  lc,   // lanes 0's and 16's lines again, {16, 0}
  input  logic [1:0]       fl,   // 0: one group, 1: two, 2: four
  output logic             ok
);
  localparam int LW = 41;    // VA[47:7]
  localparam int GW = 32;    // VA[47:16]
  localparam int NO = NL / 8;

  logic [LW-1:0] ln [NL];
  logic [GW-1:0] pg [NL];
  always_comb
    for (int l = 0; l < NL; l++) begin
      ln[l] = va[l*VW+7 +: LW];
      pg[l] = va[l*VW+16 +: GW];
    end
  wire [LW-1:0] c0  = lc[0 +: LW];
  wire [LW-1:0] c16 = lc[LW +: LW];

  // d0: off lane 0's line; d16: off lane 16's (lanes 17-31); d8: off the
  // octet's leader, lanes 9-15 and 25-31 (lane 8's and 24's).
  logic [NL-1:0] d0, d16, d8;
  always_comb
    for (int l = 0; l < NL; l++) begin
      d0[l]  = ln[l] != (l < NL/2 ? ln[0] : c0);
      d16[l] = ln[l] != (l < 3*NL/4 ? ln[NL/2] : c16);
      d8[l]  = ln[l] != ln[l & ~7];
    end

  logic          o8, o16, o32;   // an active lane off its leader, per group size
  logic          spl, spl4, spl2;
  logic [NO-1:0] oa;         // an octet with an active lane
  always_comb begin
    o8 = 1'b0; o16 = 1'b0; o32 = 1'b0;
    for (int l = 1; l < NL; l++) begin
      if (l % 8 != 0)
        o8 = o8 | (am[l] && ((l / 8) % 2 == 0 ? (l < NL/2 ? d0[l] : d16[l]) : d8[l]));
      if (l != NL/2)
        o16 = o16 | (am[l] && (l < NL/2 ? d0[l] : d16[l]));
      o32 = o32 | (am[l] && d0[l]);
    end
    for (int u = 0; u < NO; u++) oa[u] = |am[u*8 +: 8];
    // Four groups: any two active octets' leaders apart; two: the halves'.
    spl4 = 1'b0;
    for (int i = 0; i < NO; i++)
      for (int j = i + 1; j < NO; j++)
        spl4 = spl4 | (oa[i] && oa[j] && pg[i*8] != pg[j*8]);
    spl2 = (|oa[NO/2-1:0]) && (|oa[NO-1:NO/2]) && pg[0] != pg[NL/2];
    spl  = fl[1] ? spl4 : fl[0] ? spl2 : 1'b0;
    ok = !(fl[1] ? o8 : fl[0] ? o16 : o32) && !spl;
  end
endmodule
