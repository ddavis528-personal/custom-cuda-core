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
// slot's speculative maps as ooe_rat's flops hold them, with the captured
// group's writes over them (the group before last, in ooe_rat's capture,
// written into its flops at this edge: OI-83 (b)), then the pending
// group's (last cycle's, in rename's Rename 1 register, which ooe_rat
// captures at this edge: OA's response OI-58). The pending group's names
// are bound in Rename 2's first gates, so a read returns its pending
// writer as a port, one-hot, and ooe_ren1 adds that port's name after the
// lanes (#35). The
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
  // The captured group: the one before last, in ooe_rat's capture, written
  // into its flops at this edge (OI-83 (b)).
  input  logic [A-1:0]      po_v_cq02h,
  input  logic [A*LS-1:0]   po_slot_cq02h,
  input  logic [A*4-1:0]    po_dst_cq02h,
  input  logic [A-1:0]      po_gwe_cq02h,
  input  logic [A*GW-1:0]   po_gname_cq02h,
  input  logic [A*2-1:0]    po_pdst_cq02h,
  input  logic [A-1:0]      po_pwe_cq02h,
  input  logic [A*PW-1:0]   po_pname_cq02h,
  // The pending group: last cycle's, in rename's register, which ooe_rat
  // captures at this edge.
  input  logic [A-1:0]      pw_v_cq01h,
  // Its writers of this slot's registers, as the Rename 1 register holds
  // them (ooe_ren1 forms them from the lanes, #35): per register, the last
  // port writing it, one-hot over the ports (GPR e at e * A, predicate e at
  // e * A), valid where the port is.
  input  logic [NG*A-1:0]   pw_gkm_cq01h,
  input  logic [NP*A-1:0]   pw_pkm_cq01h,
  // Per head, its GPR reads (src0..2, then the old destination) and its
  // predicate reads (guard, old destination, q0, q1): each value, the
  // captured group over the flops; its pending writer, the last pending
  // port writing it, one-hot over the ports (ooe_ren1 lane-selects it and
  // ooe_ren1n takes that port's name in Rename 2, #35); and its in-group writer, one-hot
  // over the heads.
  output logic [R*4*GW-1:0] h_gv_cq01h,
  output logic [R*4*A-1:0]  h_gk_cq01h,
  output logic [R*4*R-1:0]  h_gw_cq01h,
  output logic [R*4*PW-1:0] h_pv_cq01h,
  output logic [R*4*A-1:0]  h_pk_cq01h,
  output logic [R*4*R-1:0]  h_pw_cq01h
);

  // A read: the flops' entry, or the last writer of it among the captured
  // group's ports, a one-hot AND-OR after the compares; and, apart, its
  // pending writer, read from the slot's map by address like the flops (its
  // name is bound only in Rename 2's first gates, too late to fan to every
  // read: ooe_ren1n takes it in Rename 2, #35), and the
  // last lower head writing it.
  function automatic logic [GW-1:0] gval(input logic [3:0] a);
    logic [GW-1:0] f, v;
    logic [A-1:0] m, later;
    f = '0;
    for (int e = 0; e < NG; e++) f = f | (rat_cq02h[e * GW +: GW] & {GW{a == 4'(e)}});
    for (int p = 0; p < A; p++)
      m[p] = po_v_cq02h[p] && po_gwe_cq02h[p] && po_slot_cq02h[p * LS +: LS] == LS'(SL) &&
             po_dst_cq02h[p * 4 +: 4] == a;
    later[A-1] = 1'b0;
    for (int w = A - 2; w >= 0; w--) later[w] = later[w + 1] || m[w + 1];
    v = {GW{m == '0}} & f;
    for (int w = 0; w < A; w++) v = v | ({GW{m[w] && !later[w]}} & po_gname_cq02h[w * GW +: GW]);
    gval = v;
  endfunction
  function automatic logic [PW-1:0] pval(input logic [1:0] a);
    logic [PW-1:0] f, v;
    logic [A-1:0] m, later;
    f = '0;
    for (int e = 0; e < NP; e++) f = f | (rat_cq02h[NG * GW + e * PW +: PW] & {PW{a == 2'(e)}});
    for (int p = 0; p < A; p++)
      m[p] = po_v_cq02h[p] && po_pwe_cq02h[p] && po_slot_cq02h[p * LS +: LS] == LS'(SL) &&
             po_pdst_cq02h[p * 2 +: 2] == a;
    later[A-1] = 1'b0;
    for (int w = A - 2; w >= 0; w--) later[w] = later[w + 1] || m[w + 1];
    v = {PW{m == '0}} & f;
    for (int w = 0; w < A; w++) v = v | ({PW{m[w] && !later[w]}} & po_pname_cq02h[w * PW +: PW]);
    pval = v;
  endfunction
  // The pending writer of a read, one-hot over the pending group's ports.
  function automatic logic [A-1:0] gkey(input logic [3:0] a);
    logic [A-1:0] k;
    k = '0;
    for (int e = 0; e < NG; e++) k = k | (pw_gkm_cq01h[e * A +: A] & {A{a == 4'(e)}});
    gkey = k & pw_v_cq01h;
  endfunction
  function automatic logic [A-1:0] pkey(input logic [1:0] a);
    logic [A-1:0] k;
    k = '0;
    for (int e = 0; e < NP; e++) k = k | (pw_pkm_cq01h[e * A +: A] & {A{a == 2'(e)}});
    pkey = k & pw_v_cq01h;
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
        h_gk_cq01h[(h * 4 + i) * A +: A]   = gkey(gaddr(h, i));
        h_gw_cq01h[(h * 4 + i) * R +: R]   = gwho(h, gaddr(h, i));
        h_pv_cq01h[(h * 4 + i) * PW +: PW] = pval(paddr(h, i));
        h_pk_cq01h[(h * 4 + i) * A +: A]   = pkey(paddr(h, i));
        h_pw_cq01h[(h * 4 + i) * R +: R]   = pwho(h, paddr(h, i));
      end

endmodule
