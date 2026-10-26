//===-- ooe_ren1n.sv - OOE Rename 2's first gates: Rename 1's names bound --===//
//
// Spec: the design doc's Stage boundaries (Rename 1, Rename 2) and Free
//       lists; OI-67 (OI tab, 2026-10-23): the names bound from the Rename
//       1 register.
//
// An inner helper (ooe_ren1n.ngd.json): combinational, no flops, timed in its
// parent, ooe_rename, between its Rename 1 register and what reads it: the
// pending group (ooe_rat's write ports, ooe_headrd's override) and Rename 2
// (ooe_rendep). The go's writer counts come too late in Rename 1 to pick a
// name and lane-select it (ooe_ren1), so the register holds each lane's
// index, k, and the free lists' heads as they stood; here each lane takes
// head k of its class, and each read with an in-group writer takes that
// writer's lane's new name, else keeps its value.
//
// Narrow names (NS > 0; slice 6, OI-81 (ii) and OI-82, OA's revs 252-254).
// A GPR writer's allocation width is its destination's code, 32 bits for
// an atomic or under FR (AR-24's interim). A narrow one is placed at its old
// destination's position on a merge, else at its first narrow source's,
// else at its slot's home (one section at the slot index, a pair at
// 2(slot mod 2)); a source or old destination with an in-group writer is
// not seen, so the lanes stay independent. At its home position it takes
// its slot's candidate of that kind unless an earlier lane of the same slot
// wants it (or the slot's other candidate, when the two are one row);
// else the fresh row its index names. A lane that takes a candidate returns
// that fresh row (rt), and every writer's sections go to the free list (sa).
// The model's Core (cand 2, cand_indep, cand_home) is the reference.
//
// test/ooe/ren1_tb.cpp checks what this returns against the model's names
// (test/ooe/ooe_ren1_tb.sv).
//===----------------------------------------------------------------------===//
module ooe_ren1n #(
  parameter int R  = 4,                  // lanes (CCV_ISSUE_WIDTH)
  parameter int GW = 10,                 // GPR name (CCV_P_W_PHYS_REG + CCV_W_PHYS_POS)
  parameter int GR = 8,                  // a GPR free list entry: the row (CCV_P_W_PHYS_REG)
  parameter int PW = 6,                  // predicate name (CCV_P_W_PHYS_PRED)
  parameter int NS = 0,                  // sections a row: 4 the narrow names, 0 whole rows
  parameter int FR = 0,                  // 1: every register a whole row (AR-24's interim, full_rows)
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  localparam int GP = GW - GR,           // a name's position bits
  localparam int LS = (S > 1) ? $clog2(S) : 1,
  localparam int NSB = (NS > 0) ? NS : 1
) (
  // The Rename 1 register.
  input  logic [R*2*R-1:0]  q_idx_cq01h,    // per lane and class, its name index, one-hot (its writers before it)
  input  logic [R*GR-1:0]   q_galloc_cq01h, // the GPR free list's heads
  input  logic [R*PW-1:0]   q_palloc_cq01h, // the predicate free list's
  input  logic [R*4*GW-1:0] q_g_cq01h,      // per lane, src0..2, the old destination: a value
  input  logic [R*4*R-1:0]  q_gl_cq01h,     //   or its writer's lane
  input  logic [R*4*PW-1:0] q_p_cq01h,      // guard, old destination, q0, q1
  input  logic [R*4*R-1:0]  q_pl_cq01h,
  // Narrow names (NS > 0; tie off when 0). Each lane's slot, whether it
  // writes a GPR, its attributes (bit 0 an atomic, 1-3 it reads src0..2,
  // 4 a merge), its width codes (src0..2, the destination's, the old
  // destination's), and the free list's home candidates (slot s's, k 0 one
  // section and 1 two, at s * 2 + k; same: the two are one row).
  input  logic [R*LS-1:0]   q_slot_cq01h,
  input  logic [R-1:0]      q_gwe_cq01h,
  input  logic [R*5-1:0]    q_na_cq01h,
  input  logic [R*10-1:0]   q_nw_cq01h,
  input  logic [S*2-1:0]    cand_v_cq01h,
  input  logic [S*2*GR-1:0] cand_row_cq01h,
  input  logic [S-1:0]      cand_same_cq01h,
  // Each lane's new names, and its reads' names.
  output logic [R*GW-1:0]   n_gname,
  output logic [R*PW-1:0]   n_pname,
  output logic [R*4*GW-1:0] n_g,
  output logic [R*4*PW-1:0] n_p,
  // Narrow names: each writer's sections (sa), and the fresh rows the lanes
  // that took a candidate return (rt).
  output logic [R-1:0]      n_sa_v,
  output logic [R*GR-1:0]   n_sa_row,
  output logic [R*NSB-1:0]  n_sa_sec,
  output logic [R-1:0]      n_rt_v,
  output logic [R*GR-1:0]   n_rt_row
);

  // Lane l's name: head k of its class, k one-hot in the register (OA's
  // response OI-70, rev 194).
  function automatic logic [GW-1:0] gname(input int l);
    logic [GW-1:0] v;
    v = '0;
    for (int k = 0; k < R; k++)
      v = v | ({GW{q_idx_cq01h[(l * 2 + 0) * R + k]}} & {q_galloc_cq01h[k * GR +: GR], GP'(0)});
    gname = v;
  endfunction
  function automatic logic [PW-1:0] pname(input int l);
    logic [PW-1:0] v;
    v = '0;
    for (int k = 0; k < R; k++) v = v | ({PW{q_idx_cq01h[(l * 2 + 1) * R + k]}} & q_palloc_cq01h[k * PW +: PW]);
    pname = v;
  endfunction
  // Lane l's fresh row: head k of the GPR free list.
  function automatic logic [GR-1:0] fresh(input int l);
    logic [GR-1:0] v;
    v = '0;
    for (int k = 0; k < R; k++) v = v | ({GR{q_idx_cq01h[(l * 2 + 0) * R + k]}} & q_galloc_cq01h[k * GR +: GR]);
    fresh = v;
  endfunction
  // Narrow placement, per lane, from the register alone: its allocation
  // width (0 for a whole row), position, whether it wants its slot's
  // candidate, and the candidate's kind.
  logic [R*2-1:0] nw_al, npos;
  logic [R-1:0]   nwant, nkind;
  always_comb
    for (int l = 0; l < R; l++) begin
      logic [1:0]    w, p, home;
      logic [LS-1:0] sl;
      sl    = q_slot_cq01h[l * LS +: LS];
      w     = (FR != 0 || q_na_cq01h[l * 5]) ? 2'd0 : q_nw_cq01h[l * 10 + 6 +: 2];
      home  = (w == 2'd1) ? {sl[0], 1'b0} : 2'(sl);
      p     = home;
      // The first narrow source with no in-group writer, nor the zero row.
      for (int i = 2; i >= 0; i--)
        if (q_na_cq01h[l * 5 + 1 + i] && q_gl_cq01h[(l * 4 + i) * R +: R] == '0 &&
            q_g_cq01h[(l * 4 + i) * GW + GP +: GR] != '1 && q_nw_cq01h[l * 10 + i * 2 +: 2] != 2'd0)
          p = q_g_cq01h[(l * 4 + i) * GW +: 2];
      // A merge keeps its old destination's position, at its width.
      if (q_na_cq01h[l * 5 + 4] && q_gl_cq01h[(l * 4 + 3) * R +: R] == '0 &&
          q_g_cq01h[(l * 4 + 3) * GW + GP +: GR] != '1 && q_nw_cq01h[l * 10 + 8 +: 2] == w)
        p = q_g_cq01h[(l * 4 + 3) * GW +: 2];
      if (w == 2'd1) p[0] = 1'b0;
      if (w == 2'd0) p = 2'd0;
      nw_al[l * 2 +: 2] = w;
      npos[l * 2 +: 2]  = p;
      nkind[l]          = w == 2'd1;
      nwant[l]          = NS != 0 && q_gwe_cq01h[l] && w != 2'd0 && p == home &&
                          cand_v_cq01h[32'(sl) * 2 + (w == 2'd1)];
    end
  // A lane takes the candidate it wants unless an earlier lane of its slot
  // wants it, or wants the slot's other candidate while the two are one row.
  logic [R-1:0] ntake;
  always_comb
    for (int l = 0; l < R; l++) begin
      logic claimed;
      claimed = 1'b0;
      for (int i = 0; i < l; i++)
        claimed = claimed | (nwant[i] && q_slot_cq01h[i * LS +: LS] == q_slot_cq01h[l * LS +: LS] &&
                             (nkind[i] == nkind[l] || cand_same_cq01h[q_slot_cq01h[l * LS +: LS]]));
      ntake[l] = nwant[l] && !claimed;
    end
  // The section mask of a width and position: a row, a pair, or one.
  function automatic logic [3:0] smask(input logic [1:0] w, input logic [1:0] p);
    smask = (w == 2'd0) ? 4'hf : (w == 2'd1) ? (4'h3 << p) : (4'h1 << p);
  endfunction
  always_comb
    for (int l = 0; l < R; l++) begin
      logic [GR-1:0] row;
      row = ntake[l] ? cand_row_cq01h[(32'(q_slot_cq01h[l * LS +: LS]) * 2 + 32'(nkind[l])) * GR +: GR] : fresh(l);
      n_gname[l * GW +: GW] = NS != 0 ? {row, GP'(npos[l * 2 +: 2])} : gname(l);
      n_pname[l * PW +: PW] = pname(l);
      n_sa_v[l]             = NS != 0 && q_gwe_cq01h[l];
      // NS 0: none, so no path through the lanes reaches the free list.
      n_sa_row[l * GR +: GR] = NS != 0 ? row : '0;
      n_sa_sec[l * NSB +: NSB] = NS != 0 ? NSB'(smask(nw_al[l * 2 +: 2], npos[l * 2 +: 2])) : '0;
      n_rt_v[l]             = NS != 0 && ntake[l];
      n_rt_row[l * GR +: GR] = NS != 0 ? fresh(l) : '0;
    end

  // A read with an in-group writer: that lane's new name.
  function automatic logic [GW-1:0] gread(input int l, input int i);
    logic [GW-1:0] w;
    logic [R-1:0] m;
    m = q_gl_cq01h[(l * 4 + i) * R +: R];
    w = '0;
    for (int j = 0; j < R; j++) w = w | ({GW{m[j]}} & n_gname[j * GW +: GW]);
    gread = m != '0 ? w : q_g_cq01h[(l * 4 + i) * GW +: GW];
  endfunction
  function automatic logic [PW-1:0] pread(input int l, input int i);
    logic [PW-1:0] w;
    logic [R-1:0] m;
    m = q_pl_cq01h[(l * 4 + i) * R +: R];
    w = '0;
    for (int j = 0; j < R; j++) w = w | ({PW{m[j]}} & n_pname[j * PW +: PW]);
    pread = m != '0 ? w : q_p_cq01h[(l * 4 + i) * PW +: PW];
  endfunction
  always_comb
    for (int l = 0; l < R; l++)
      for (int i = 0; i < 4; i++) begin
        n_g[(l * 4 + i) * GW +: GW] = gread(l, i);
        n_p[(l * 4 + i) * PW +: PW] = pread(l, i);
      end

endmodule
