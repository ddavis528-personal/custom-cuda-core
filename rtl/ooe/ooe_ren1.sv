//===-- ooe_ren1.sv - OOE Rename 1: the lanes, their names and reads -------===//
//
// Spec: the design doc's Stage boundaries (Rename 1) and Free lists; OA-21
//       and OA-22 (the go); OI-67 (OI tab, 2026-10-23): Rename 1 is the go's
//       cycle, its reads per candidate, its names taken in lane order.
//
// An inner helper (ooe_ren1.ngd.json): combinational, no flops, timed in its
// parent, ooe_rename, whose Rename 1 register captures what it returns. The
// go's lanes pick, one-hot, which candidate each lane renames (bit h * S + s:
// slot s's head h). Each lane takes its candidate's fields and reads, which
// ooe_headrd formed for every candidate in parallel with the go.
//
// Names. A uop writing a GPR takes the GPR free list's head k, where k is
// the number of uops before it in lane order writing one: ooe_go counts
// them for every candidate as it ranks the candidates (wb, 16.5 NGD). A
// name picked here and then lane-selected would not fit the stage, so the
// lane carries k, the index, and the Rename 1 register the free list's
// heads beside it; ooe_ren1n binds the names from those flops in Rename 2's
// first gates (OI-67). The go's totals ask the free lists for that many.
// Predicate names likewise, from the predicate free list.
//
// The in-group override: a read whose writer is a lower head h' of the
// candidate's slot carries the lane holding (h', s), one-hot over the lanes
// (it is before this one); ooe_ren1n returns that lane's new name. Else the
// read is ooe_headrd's value (the pending group over the flops), a name.
//
// test/ooe/ren1_tb.cpp drives this beside ooe_headrd and ooe_rat
// (test/ooe/ooe_ren1_tb.sv) from the model's renames and compares each lane,
// as the Rename 1 register holds it, with the model's.
//===----------------------------------------------------------------------===//
module ooe_ren1 #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int R  = 4,                  // lanes, and heads a slot (CCV_ISSUE_WIDTH)
  parameter int GW = 10,                 // GPR name (CCV_P_W_PHYS_REG + CCV_W_PHYS_POS)
  parameter int PW = 6,                  // predicate name (CCV_P_W_PHYS_PRED)
  parameter int LC = 2,                  // a checkpoint id (CCV_P_BR_CKPTS)
  parameter int XW = 1,                  // other fields the lanes carry
  localparam int NC = S * R,             // candidates: bit h * S + s, slot s's head h
  localparam int LS = (S > 1) ? $clog2(S) : 1
) (
  // Every candidate's fields, from decq's output register.
  input  logic [NC*4-1:0]    c_dst_cq01h,
  input  logic [NC-1:0]      c_gwe_cq01h,
  input  logic [NC*2-1:0]    c_pdst_cq01h,
  input  logic [NC-1:0]      c_pwe_cq01h,
  input  logic [NC-1:0]      c_br_cq01h,
  input  logic [NC*LC-1:0]   c_ckpt_cq01h,
  input  logic [NC*XW-1:0]   c_x_cq01h,
  // And its reads, from ooe_headrd (heads major within a slot: slot s's
  // instance gives h * 4 + i for its head h): GPR reads src0..2, the old
  // destination; predicate reads guard, old destination, q0, q1; each with
  // its in-group writer, one-hot over the slot's heads.
  input  logic [S*R*4*GW-1:0] c_gv_cq01h,
  input  logic [S*R*4*R-1:0]  c_gw_cq01h,
  input  logic [S*R*4*PW-1:0] c_pv_cq01h,
  input  logic [S*R*4*R-1:0]  c_pw_cq01h,
  // The go: each lane's uop, and which candidate, one-hot; and each
  // candidate's writers before it in lane order, a thermometer per class
  // (b 0 GPR, 1 predicate).
  input  logic [R-1:0]       lane_v_cq02h,
  input  logic [R*NC-1:0]    lane_c_cq02h,
  input  logic [NC*2*R-1:0]  wb_cq02h,
  // Each lane, as the Rename 1 register captures it.
  output logic [R-1:0]       l_v,
  output logic [R*LS-1:0]    l_slot,
  output logic [R*4-1:0]     l_dst,
  output logic [R-1:0]       l_gwe,
  output logic [R*2-1:0]     l_pdst,
  output logic [R-1:0]       l_pwe,
  output logic [R*2*R-1:0]   l_idx,         // its writers before it, per class, a thermometer
  output logic [R-1:0]       l_br,
  output logic [R*LC-1:0]    l_ckpt,
  output logic [R*4*GW-1:0]  l_g,           // src0..2, the old destination: a value
  output logic [R*4*R-1:0]   l_gl,          //   or its writer's lane, one-hot
  output logic [R*4*PW-1:0]  l_p,           // guard, old destination, q0, q1
  output logic [R*4*R-1:0]   l_pl,
  output logic [R*XW-1:0]    l_x
);

  // Candidate c = h * S + s's reads sit at slot s's instance, head h.
  function automatic int ci(input int c, input int i);
    ci = (c % S) * R * 4 + (c / S) * 4 + i;
  endfunction

  // Lane l's slot.
  function automatic logic [LS-1:0] lslot(input int l);
    logic [LS-1:0] v;
    v = '0;
    for (int c = 0; c < NC; c++) v = v | ({LS{lane_c_cq02h[l * NC + c]}} & LS'(c % S));
    lslot = v;
  endfunction

  // Each candidate's read i's writer, as a lane: head h' of its slot sits
  // in the lane whose candidate is (h', s).
  function automatic logic [R-1:0] cwl(input int c, input logic [R-1:0] m);
    logic [R-1:0] v;
    v = '0;
    for (int j = 0; j < R; j++)
      for (int hp = 0; hp < R; hp++) v[j] = v[j] | (m[hp] & lane_c_cq02h[j * NC + hp * S + c % S]);
    cwl = v;
  endfunction
  logic [NC*4*R-1:0] cgl, cpl;
  always_comb
    for (int c = 0; c < NC; c++)
      for (int i = 0; i < 4; i++) begin
        cgl[(c * 4 + i) * R +: R] = cwl(c, c_gw_cq01h[ci(c, i) * R +: R]);
        cpl[(c * 4 + i) * R +: R] = cwl(c, c_pw_cq01h[ci(c, i) * R +: R]);
      end

  // A field of lane l's candidate, one-hot (k: 0 dst, 1 pdst, 2 br, 3
  // ckpt, 4 the rest), each a W-bit field of its own width.
  function automatic logic [3:0] fdst(input int l);
    logic [3:0] v;
    v = '0;
    for (int c = 0; c < NC; c++) v = v | ({4{lane_c_cq02h[l * NC + c]}} & c_dst_cq01h[c * 4 +: 4]);
    fdst = v;
  endfunction
  function automatic logic [1:0] fpdst(input int l);
    logic [1:0] v;
    v = '0;
    for (int c = 0; c < NC; c++) v = v | ({2{lane_c_cq02h[l * NC + c]}} & c_pdst_cq01h[c * 2 +: 2]);
    fpdst = v;
  endfunction
  function automatic logic fbr(input int l);
    logic v;
    v = 1'b0;
    for (int c = 0; c < NC; c++) v = v | (lane_c_cq02h[l * NC + c] & c_br_cq01h[c]);
    fbr = v;
  endfunction
  function automatic logic [LC-1:0] fckpt(input int l);
    logic [LC-1:0] v;
    v = '0;
    for (int c = 0; c < NC; c++) v = v | ({LC{lane_c_cq02h[l * NC + c]}} & c_ckpt_cq01h[c * LC +: LC]);
    fckpt = v;
  endfunction
  function automatic logic [XW-1:0] fx(input int l);
    logic [XW-1:0] v;
    v = '0;
    for (int c = 0; c < NC; c++) v = v | ({XW{lane_c_cq02h[l * NC + c]}} & c_x_cq01h[c * XW +: XW]);
    fx = v;
  endfunction

  function automatic logic [1:0] fwe(input int l);
    logic [1:0] v;
    v = '0;
    for (int c = 0; c < NC; c++)
      v = v | ({2{lane_c_cq02h[l * NC + c]}} & {c_pwe_cq01h[c], c_gwe_cq01h[c]});
    fwe = v & {2{lane_v_cq02h[l]}};
  endfunction
  function automatic logic [2*R-1:0] fidx(input int l);
    logic [2*R-1:0] v;
    v = '0;
    for (int c = 0; c < NC; c++) v = v | ({2*R{lane_c_cq02h[l * NC + c]}} & wb_cq02h[c * 2 * R +: 2 * R]);
    fidx = v;
  endfunction
  function automatic logic [GW-1:0] fg(input int l, input int i);
    logic [GW-1:0] v;
    v = '0;
    for (int c = 0; c < NC; c++) v = v | ({GW{lane_c_cq02h[l * NC + c]}} & c_gv_cq01h[ci(c, i) * GW +: GW]);
    fg = v;
  endfunction
  function automatic logic [PW-1:0] fp(input int l, input int i);
    logic [PW-1:0] v;
    v = '0;
    for (int c = 0; c < NC; c++) v = v | ({PW{lane_c_cq02h[l * NC + c]}} & c_pv_cq01h[ci(c, i) * PW +: PW]);
    fp = v;
  endfunction
  function automatic logic [R-1:0] fl(input int l, input int i, input int k);
    logic [R-1:0] v;
    v = '0;
    for (int c = 0; c < NC; c++)
      v = v | ({R{lane_c_cq02h[l * NC + c]}} & (k == 0 ? cgl[(c * 4 + i) * R +: R] : cpl[(c * 4 + i) * R +: R]));
    fl = v;
  endfunction

  always_comb
    for (int l = 0; l < R; l++) begin
      l_dst[l * 4 +: 4]    = fdst(l);
      l_pdst[l * 2 +: 2]   = fpdst(l);
      l_br[l]              = fbr(l);
      l_ckpt[l * LC +: LC] = fckpt(l);
      l_x[l * XW +: XW]    = fx(l);
      {l_pwe[l], l_gwe[l]} = fwe(l);
      l_idx[l * 2 * R +: 2 * R] = fidx(l);
      l_slot[l * LS +: LS]  = lslot(l);
      for (int i = 0; i < 4; i++) begin
        l_g[(l * 4 + i) * GW +: GW] = fg(l, i);
        l_p[(l * 4 + i) * PW +: PW] = fp(l, i);
        l_gl[(l * 4 + i) * R +: R]  = fl(l, i, 0);
        l_pl[(l * 4 + i) * R +: R]  = fl(l, i, 1);
      end
    end
  assign l_v = lane_v_cq02h;

endmodule
