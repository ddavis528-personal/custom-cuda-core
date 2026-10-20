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
// hold them, with the writes of the lower ports naming the same slot in
// front (the in-group override). A restore-allocate port (rst) writes and
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
  output logic [A*3*GW-1:0] ren_psrc_cq01h,
  output logic [A*GW-1:0]   ren_pold_cq01h,
  output logic [A*PW-1:0]   ren_ppguard_cq01h,
  output logic [A*PW-1:0]   ren_ppold_cq01h,
  output logic [A*2*PW-1:0] ren_ppq_cq01h
);

  // Port k's slot's maps as the lower ports of that slot left them. Every
  // write as a decoder: no index computed and written through.
  function automatic logic [MW-1:0] map_before(input int k);
    logic [MW-1:0] m;
    logic [LS-1:0] s;
    s = ren_slot_cq01h[k * LS +: LS];
    m = '0;
    for (int t = 0; t < S; t++) if (s == LS'(t)) m = rat_cq02h[t * MW +: MW];
    for (int p = 0; p < k; p++)
      if (ren_v_cq01h[p] && !ren_rst_cq01h[p] && ren_slot_cq01h[p * LS +: LS] == s) begin
        for (int a = 0; a < NG; a++)
          if (ren_gwe_cq01h[p] && ren_dst_cq01h[p * 4 +: 4] == 4'(a)) m[a * GW +: GW] = ren_gname_cq01h[p * GW +: GW];
        for (int a = 0; a < NP; a++)
          if (ren_pwe_cq01h[p] && ren_pdst_cq01h[p * 2 +: 2] == 2'(a)) m[NG * GW + a * PW +: PW] = ren_pname_cq01h[p * PW +: PW];
      end
    map_before = m;
  endfunction

  // A map's entry by architectural index, as an AND-OR over the entries.
  function automatic logic [GW-1:0] gread(input logic [MW-1:0] m, input logic [3:0] a);
    logic [GW-1:0] r;
    r = '0;
    for (int t = 0; t < NG; t++) r = r | (m[t * GW +: GW] & {GW{a == 4'(t)}});
    gread = r;
  endfunction
  function automatic logic [PW-1:0] pread(input logic [MW-1:0] m, input logic [1:0] a);
    logic [PW-1:0] r;
    r = '0;
    for (int t = 0; t < NP; t++) r = r | (m[NG * GW + t * PW +: PW] & {PW{a == 2'(t)}});
    pread = r;
  endfunction

  logic [A*MW-1:0] rd_map;
  always_comb
    for (int k = 0; k < A; k++) begin
      rd_map[k * MW +: MW] = map_before(k);
      for (int i = 0; i < 3; i++)
        ren_psrc_cq01h[(k * 3 + i) * GW +: GW] = gread(rd_map[k * MW +: MW], ren_src_cq01h[(k * 3 + i) * 4 +: 4]);
      ren_pold_cq01h[k * GW +: GW]    = gread(rd_map[k * MW +: MW], ren_dst_cq01h[k * 4 +: 4]);
      ren_ppguard_cq01h[k * PW +: PW] = pread(rd_map[k * MW +: MW], ren_pguard_cq01h[k * 2 +: 2]);
      ren_ppold_cq01h[k * PW +: PW]   = pread(rd_map[k * MW +: MW], ren_pdst_cq01h[k * 2 +: 2]);
      for (int i = 0; i < 2; i++)
        ren_ppq_cq01h[(k * 2 + i) * PW +: PW] = pread(rd_map[k * MW +: MW], ren_pq_cq01h[(k * 2 + i) * 2 +: 2]);
    end

endmodule
