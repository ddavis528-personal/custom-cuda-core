//===-- ooe_headrd.sv - OOE Rename 1: one slot's heads read its maps --------===//
//
// Spec: the design doc's Register alias tables and Stage boundaries
//       (Rename 1: RAT read); OA's response OI-46 (reopened) and OI-58 (the
//       pending group); OI-67 (OI tab, 2026-10-23): the read per candidate.
//
// An inner helper (ooe_headrd.ngd.json): combinational, no flops, timed in
// its parent, ooe_rename's Rename 1, which instantiates one per slot. Rename
// 1 is the go's cycle (the model's rename_stages 3), and the go's lanes are
// too late for a read behind them, so each of a slot's R heads, as decq's
// output register shows them, reads in parallel with the go. A warp's take
// is a prefix of its heads, so head h's in-group writers are its own slot's
// heads below h, taken whenever h is: the read needs no lane.
//
// Each head reads its three GPR sources, its old GPR destination, its guard,
// its old predicate destination and predicate logic's two sources from the
// slot's speculative maps as ooe_rat's flops hold them, with the pending
// group's writes over them (last cycle's group, in rename's Rename 1
// register, which ooe_rat writes an edge late: OA's response OI-58). The
// in-group override cannot name its writer's new name here: names are taken
// in lane order, after the go. So each read also returns its in-group
// writer, the last lower head writing that register, one-hot over the heads
// (bit h': head h'), and ooe_rename substitutes the name once it has the
// lanes. A read with a writer there returns the pending-or-flops value too,
// which the substitution discards.
//
// test/ooe/ren1_tb.cpp drives this beside ooe_ren1 and ooe_rat
// (test/ooe/ooe_ren1_tb.sv) and compares each lane's reads with the model's.
//===----------------------------------------------------------------------===//
module ooe_headrd #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int SL = 0,                  // this instance's slot
  parameter int R  = 4,                  // heads read: rename's width (CCV_ISSUE_WIDTH)
  parameter int A  = 4,                  // the pending group's ports (CCV_ISSUE_WIDTH)
  parameter int GW = 10,                 // GPR name (CCV_P_W_PHYS_REG + CCV_W_PHYS_POS)
  parameter int PW = 6,                  // predicate name (CCV_P_W_PHYS_PRED)
  localparam int NG = 16,
  localparam int NP = 4,
  localparam int LS = (S > 1) ? $clog2(S) : 1,
  localparam int MW = NG * GW + NP * PW
) (
  input  logic [MW-1:0]     rat_cq02h,         // ooe_rat's speculative maps, this slot's
  // The slot's heads, oldest first, as decq's output register holds them.
  input  logic [R*3*4-1:0]  h_src_cq01h,
  input  logic [R*4-1:0]    h_dst_cq01h,
  input  logic [R-1:0]      h_gwe_cq01h,       // writes its GPR destination
  input  logic [R*2-1:0]    h_pguard_cq01h,
  input  logic [R*2-1:0]    h_pdst_cq01h,
  input  logic [R-1:0]      h_pwe_cq01h,       // writes its predicate destination
  input  logic [R*2*2-1:0]  h_pq_cq01h,
  // The pending group: last cycle's, in rename's register, whose writes
  // reach ooe_rat's flops only at this edge.
  input  logic [A-1:0]      pw_v_cq01h,
  input  logic [A*LS-1:0]   pw_slot_cq01h,
  input  logic [A*4-1:0]    pw_dst_cq01h,
  input  logic [A-1:0]      pw_gwe_cq01h,
  input  logic [A*GW-1:0]   pw_gname_cq01h,
  input  logic [A*2-1:0]    pw_pdst_cq01h,
  input  logic [A-1:0]      pw_pwe_cq01h,
  input  logic [A*PW-1:0]   pw_pname_cq01h,
  // Per head, its GPR reads (src0..2, then the old destination) and its
  // predicate reads (guard, old destination, q0, q1): each value, the
  // pending group over the flops, and its in-group writer, one-hot over
  // the heads.
  output logic [R*4*GW-1:0] h_gv_cq01h,
  output logic [R*4*R-1:0]  h_gw_cq01h,
  output logic [R*4*PW-1:0] h_pv_cq01h,
  output logic [R*4*R-1:0]  h_pw_cq01h
);

  // A read: the flops' entry, or the last writer of it among the pending
  // group's ports, a one-hot AND-OR after the compares; and, apart, the
  // last lower head writing it.
  function automatic logic [GW-1:0] gval(input logic [3:0] a);
    logic [GW-1:0] f, v;
    logic [A-1:0] m, later;
    f = '0;
    for (int e = 0; e < NG; e++) f = f | (rat_cq02h[e * GW +: GW] & {GW{a == 4'(e)}});
    for (int p = 0; p < A; p++)
      m[p] = pw_v_cq01h[p] && pw_gwe_cq01h[p] && pw_slot_cq01h[p * LS +: LS] == LS'(SL) &&
             pw_dst_cq01h[p * 4 +: 4] == a;
    later[A-1] = 1'b0;
    for (int p = A - 2; p >= 0; p--) later[p] = later[p + 1] || m[p + 1];
    v = {GW{m == '0}} & f;
    for (int p = 0; p < A; p++) v = v | ({GW{m[p] && !later[p]}} & pw_gname_cq01h[p * GW +: GW]);
    gval = v;
  endfunction
  function automatic logic [PW-1:0] pval(input logic [1:0] a);
    logic [PW-1:0] f, v;
    logic [A-1:0] m, later;
    f = '0;
    for (int e = 0; e < NP; e++) f = f | (rat_cq02h[NG * GW + e * PW +: PW] & {PW{a == 2'(e)}});
    for (int p = 0; p < A; p++)
      m[p] = pw_v_cq01h[p] && pw_pwe_cq01h[p] && pw_slot_cq01h[p * LS +: LS] == LS'(SL) &&
             pw_pdst_cq01h[p * 2 +: 2] == a;
    later[A-1] = 1'b0;
    for (int p = A - 2; p >= 0; p--) later[p] = later[p + 1] || m[p + 1];
    v = {PW{m == '0}} & f;
    for (int p = 0; p < A; p++) v = v | ({PW{m[p] && !later[p]}} & pw_pname_cq01h[p * PW +: PW]);
    pval = v;
  endfunction
  function automatic logic [R-1:0] gwho(input int h, input logic [3:0] a);
    logic [R-1:0] m, w;
    logic later;
    for (int j = 0; j < R; j++) m[j] = j < h && h_gwe_cq01h[j] && h_dst_cq01h[j * 4 +: 4] == a;
    later = 1'b0;
    for (int j = R - 1; j >= 0; j--) begin
      w[j]  = m[j] && !later;
      later = later || m[j];
    end
    gwho = w;
  endfunction
  function automatic logic [R-1:0] pwho(input int h, input logic [1:0] a);
    logic [R-1:0] m, w;
    logic later;
    for (int j = 0; j < R; j++) m[j] = j < h && h_pwe_cq01h[j] && h_pdst_cq01h[j * 2 +: 2] == a;
    later = 1'b0;
    for (int j = R - 1; j >= 0; j--) begin
      w[j]  = m[j] && !later;
      later = later || m[j];
    end
    pwho = w;
  endfunction

  // Read i's register: GPR, a source then the old destination; predicate,
  // the guard, the old destination, q0, q1.
  function automatic logic [3:0] gaddr(input int h, input int i);
    gaddr = i < 3 ? h_src_cq01h[(h * 3 + i) * 4 +: 4] : h_dst_cq01h[h * 4 +: 4];
  endfunction
  function automatic logic [1:0] paddr(input int h, input int i);
    paddr = i == 0 ? h_pguard_cq01h[h * 2 +: 2] : i == 1 ? h_pdst_cq01h[h * 2 +: 2]
          : h_pq_cq01h[(h * 2 + (i % 2)) * 2 +: 2];
  endfunction

  always_comb
    for (int h = 0; h < R; h++)
      for (int i = 0; i < 4; i++) begin
        h_gv_cq01h[(h * 4 + i) * GW +: GW] = gval(gaddr(h, i));
        h_gw_cq01h[(h * 4 + i) * R +: R]   = gwho(h, gaddr(h, i));
        h_pv_cq01h[(h * 4 + i) * PW +: PW] = pval(paddr(h, i));
        h_pw_cq01h[(h * 4 + i) * R +: R]   = pwho(h, paddr(h, i));
      end

endmodule
