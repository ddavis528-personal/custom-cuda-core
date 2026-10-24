//===-- ooe_ratread.sv - OOE rename's RAT read, Rename 1's logic ----------===//
//
// Spec: the design doc's Register alias tables and Stage boundaries (Rename
//       1: RAT read), OA's response OI-46 (reopened): the RAT read and its
//       register move from ooe_rat into ooe_rename as Rename 1's logic, so
//       ooe_rat drives its maps straight out and no rename field passes
//       through it.
//
// An inner helper (ooe_ratread.ngd.json): combinational, no flops, timed in
// its parent, ooe_rename's Rename 1, whose register captures what it
// returns. Each rename port reads its three GPR sources, its old GPR
// destination, its guard, its old predicate destination and predicate
// logic's two sources from its slot's speculative maps as ooe_rat's flops
// hold them, with the pending group's writes over them (last cycle's
// group, which ooe_rat writes an edge late: OA's response OI-58), then
// the writes of the lower ports naming the same slot (the in-group
// override). A restore-allocate port (rst) writes and
// reads nothing, so it overrides nothing.
//
// The reference is the model's Slot maps, logged each cycle
// (Core::ratLog); test/ooe/rat_tb.cpp drives ooe_rat and this helper
// together (test/ooe/ooe_rat_read.sv) and compares every read.
//===----------------------------------------------------------------------===//
module ooe_ratread #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int A  = 4,                  // rename ports (CCV_ISSUE_WIDTH)
  parameter int GW = 10,                 // GPR name (CCV_P_W_PHYS_REG + CCV_W_PHYS_POS)
  parameter int PW = 6,                  // predicate name (CCV_P_W_PHYS_PRED)
  localparam int NG = 16,
  localparam int NP = 4,
  localparam int LS = (S > 1) ? $clog2(S) : 1,
  localparam int MW = NG * GW + NP * PW
) (
  input  logic [S*MW-1:0]   rat_cq02h,         // ooe_rat's speculative maps
  input  logic [A-1:0]      ren_v_cq01h,
  input  logic [A*LS-1:0]   ren_slot_cq01h,
  input  logic [A-1:0]      ren_rst_cq01h,
  input  logic [A*3*4-1:0]  ren_src_cq01h,
  input  logic [A*4-1:0]    ren_dst_cq01h,
  input  logic [A-1:0]      ren_gwe_cq01h,
  input  logic [A*GW-1:0]   ren_gname_cq01h,
  input  logic [A*2-1:0]    ren_pguard_cq01h,
  input  logic [A*2-1:0]    ren_pdst_cq01h,
  input  logic [A-1:0]      ren_pwe_cq01h,
  input  logic [A*PW-1:0]   ren_pname_cq01h,
  input  logic [A*2*2-1:0]  ren_pq_cq01h,
  // The pending group: last cycle's, in rename's register, whose writes
  // reach ooe_rat's flops only at this edge (OA's response OI-58).
  input  logic [A-1:0]      pw_v_cq01h,
  input  logic [A*LS-1:0]   pw_slot_cq01h,
  input  logic [A*4-1:0]    pw_dst_cq01h,
  input  logic [A-1:0]      pw_gwe_cq01h,
  input  logic [A*GW-1:0]   pw_gname_cq01h,
  input  logic [A*2-1:0]    pw_pdst_cq01h,
  input  logic [A-1:0]      pw_pwe_cq01h,
  input  logic [A*PW-1:0]   pw_pname_cq01h,
  output logic [A*3*GW-1:0] ren_psrc_cq01h,
  output logic [A*GW-1:0]   ren_pold_cq01h,
  output logic [A*PW-1:0]   ren_ppguard_cq01h,
  output logic [A*PW-1:0]   ren_ppold_cq01h,
  output logic [A*2*PW-1:0] ren_ppq_cq01h
);

  // Each read as a select: the flops' entry, or the last writer of it among
  // the pending group's ports (last cycle's, written at this edge) and then
  // the lower ports of this group naming the same slot. Every writer's
  // match is compared in parallel with the flops' read, so the override is
  // a one-hot AND-OR after both, not a map rebuilt in front of the read.
  localparam int NW = 2 * A;             // the pending group's ports, then this group's
  function automatic logic [GW-1:0] gsel(input int k, input logic [3:0] a);
    logic [LS-1:0] s;
    logic [GW-1:0] f, v;
    logic [NW-1:0] m, later;
    logic [NW*GW-1:0] nm;
    s = ren_slot_cq01h[k * LS +: LS];
    f = '0;
    for (int t = 0; t < S; t++)
      for (int e = 0; e < NG; e++)
        f = f | (rat_cq02h[t * MW + e * GW +: GW] & {GW{s == LS'(t) && a == 4'(e)}});
    for (int p = 0; p < A; p++) begin
      m[p] = pw_v_cq01h[p] && pw_gwe_cq01h[p] && pw_slot_cq01h[p * LS +: LS] == s && pw_dst_cq01h[p * 4 +: 4] == a;
      nm[p * GW +: GW] = pw_gname_cq01h[p * GW +: GW];
      m[A + p] = p < k && ren_v_cq01h[p] && !ren_rst_cq01h[p] && ren_gwe_cq01h[p] &&
                 ren_slot_cq01h[p * LS +: LS] == s && ren_dst_cq01h[p * 4 +: 4] == a;
      nm[(A + p) * GW +: GW] = ren_gname_cq01h[p * GW +: GW];
    end
    later[NW-1] = 1'b0;
    for (int w = NW - 2; w >= 0; w--) later[w] = later[w + 1] || m[w + 1];
    v = {GW{m == '0}} & f;
    for (int w = 0; w < NW; w++) v = v | ({GW{m[w] && !later[w]}} & nm[w * GW +: GW]);
    gsel = v;
  endfunction
  function automatic logic [PW-1:0] psel(input int k, input logic [1:0] a);
    logic [LS-1:0] s;
    logic [PW-1:0] f, v;
    logic [NW-1:0] m, later;
    logic [NW*PW-1:0] nm;
    s = ren_slot_cq01h[k * LS +: LS];
    f = '0;
    for (int t = 0; t < S; t++)
      for (int e = 0; e < NP; e++)
        f = f | (rat_cq02h[t * MW + NG * GW + e * PW +: PW] & {PW{s == LS'(t) && a == 2'(e)}});
    for (int p = 0; p < A; p++) begin
      m[p] = pw_v_cq01h[p] && pw_pwe_cq01h[p] && pw_slot_cq01h[p * LS +: LS] == s && pw_pdst_cq01h[p * 2 +: 2] == a;
      nm[p * PW +: PW] = pw_pname_cq01h[p * PW +: PW];
      m[A + p] = p < k && ren_v_cq01h[p] && !ren_rst_cq01h[p] && ren_pwe_cq01h[p] &&
                 ren_slot_cq01h[p * LS +: LS] == s && ren_pdst_cq01h[p * 2 +: 2] == a;
      nm[(A + p) * PW +: PW] = ren_pname_cq01h[p * PW +: PW];
    end
    later[NW-1] = 1'b0;
    for (int w = NW - 2; w >= 0; w--) later[w] = later[w + 1] || m[w + 1];
    v = {PW{m == '0}} & f;
    for (int w = 0; w < NW; w++) v = v | ({PW{m[w] && !later[w]}} & nm[w * PW +: PW]);
    psel = v;
  endfunction

  always_comb
    for (int k = 0; k < A; k++) begin
      for (int i = 0; i < 3; i++)
        ren_psrc_cq01h[(k * 3 + i) * GW +: GW] = gsel(k, ren_src_cq01h[(k * 3 + i) * 4 +: 4]);
      ren_pold_cq01h[k * GW +: GW]    = gsel(k, ren_dst_cq01h[k * 4 +: 4]);
      ren_ppguard_cq01h[k * PW +: PW] = psel(k, ren_pguard_cq01h[k * 2 +: 2]);
      ren_ppold_cq01h[k * PW +: PW]   = psel(k, ren_pdst_cq01h[k * 2 +: 2]);
      for (int i = 0; i < 2; i++)
        ren_ppq_cq01h[(k * 2 + i) * PW +: PW] = psel(k, ren_pq_cq01h[(k * 2 + i) * 2 +: 2]);
    end

endmodule
