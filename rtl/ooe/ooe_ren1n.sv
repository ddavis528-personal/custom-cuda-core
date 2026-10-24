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
// test/ooe/ren1_tb.cpp checks what this returns against the model's names
// (test/ooe/ooe_ren1_tb.sv).
//===----------------------------------------------------------------------===//
module ooe_ren1n #(
  parameter int R  = 4,                  // lanes (CCV_ISSUE_WIDTH)
  parameter int GW = 10,                 // GPR name (CCV_P_W_PHYS_REG + CCV_W_PHYS_POS)
  parameter int GR = 8,                  // a GPR free list entry: the row (CCV_P_W_PHYS_REG)
  parameter int PW = 6,                  // predicate name (CCV_P_W_PHYS_PRED)
  localparam int GP = GW - GR            // a name's position bits
) (
  // The Rename 1 register.
  input  logic [R*2*R-1:0]  q_idx_cq01h,    // per lane and class, its name index, one-hot (its writers before it)
  input  logic [R*GR-1:0]   q_galloc_cq01h, // the GPR free list's heads
  input  logic [R*PW-1:0]   q_palloc_cq01h, // the predicate free list's
  input  logic [R*4*GW-1:0] q_g_cq01h,      // per lane, src0..2, the old destination: a value
  input  logic [R*4*R-1:0]  q_gl_cq01h,     //   or its writer's lane
  input  logic [R*4*PW-1:0] q_p_cq01h,      // guard, old destination, q0, q1
  input  logic [R*4*R-1:0]  q_pl_cq01h,
  // Each lane's new names, and its reads' names.
  output logic [R*GW-1:0]   n_gname,
  output logic [R*PW-1:0]   n_pname,
  output logic [R*4*GW-1:0] n_g,
  output logic [R*4*PW-1:0] n_p
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
  always_comb
    for (int l = 0; l < R; l++) begin
      n_gname[l * GW +: GW] = gname(l);
      n_pname[l * PW +: PW] = pname(l);
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
