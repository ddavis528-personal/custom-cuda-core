//===-- ooe_rnrs.sv - rename's lookup into ooe_rs, as the design wires them ===//
//
// The bench top for test/ooe/rnrs_tb.cpp (OA's rev 168): ooe_prodmap and
// ooe_rendep as rename wires them, rename's stage register straight into
// ooe_rs's rows, and ooe_rs's registered grant back into both. The bench
// drives rename's fields from the model's renames and ooe_rs's other inputs
// from the model's RS, and compares ooe_rs's rows with the model's.
//
// The assertion OA asked for, here because ooe_rs holds no names: after
// each edge, every bit of every row ooe_rs wrote at it names either an
// entry of the same group (granted at that edge too) or an entry whose
// occupant, as ooe_prodmap now holds it, produces one of the row's source
// names: a GPR source of its port's uop, or a predicate source. A surviving
// entry was allocated at the edge before or earlier, so ooe_prodmap has
// written its names by then. The bench gives each port's source names with
// its request (chk_*, bench-only), and this wrapper flops them over the
// write edge. A control's bits join rename's rows on their way to ooe_rs
// (ctl_row, bench-only).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
module ooe_rnrs #(
  parameter int N  = 45,
  parameter int NR = 30,
  parameter int A  = 4,
  parameter int NG = 768,
  parameter int NP = 48,
  parameter int NC = 4,
  localparam int W   = $clog2(N),
  localparam int P   = 2 * A,
  localparam int LP  = $clog2(P),
  localparam int LG  = $clog2(NG),
  localparam int LQ  = $clog2(NP),
  localparam int NS  = 4,
  localparam int CW  = 16
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  // ooe_rendep's Rename 2.
  input  logic              d_v_l_cq00h,
  input  logic [A-1:0]      d_v_cq01h, d_mem_cq01h, d_cp_cq01h, d_atom_cq01h, d_gwe_cq01h, d_pwe_cq01h,
  input  logic [A*LG-1:0]   d_gname_cq01h,
  input  logic [A*LQ-1:0]   d_pname_cq01h,
  input  logic [A*NS-1:0]   d_gsv_cq01h,
  input  logic [A*NS*LG-1:0] d_gsn_cq01h,
  input  logic [A*4-1:0]    d_psv_cq01h,
  input  logic [A*4*LQ-1:0] d_psn_cq01h,
  input  logic [A-1:0]      d_cguard_cq01h, d_cnone_cq01h, d_nob_cq01h,
  input  logic [A*3-1:0]    d_cg_cq01h, d_unit_cq01h, d_pg_cq01h,
  // ooe_prodmap's Rename 3 (the group a cycle on).
  input  logic              m_v_l_cq00h,
  input  logic [A-1:0]      m_v_cq01h, m_gwe_cq01h, m_pwe_cq01h, m_cv_cq01h,
  input  logic [A*LG-1:0]   m_gname_cq01h,
  input  logic [A*LQ-1:0]   m_pname_cq01h,
  input  logic [A*LP-1:0]   m_pm_cq01h, m_pc_cq01h,
  input  logic [A*CW-1:0]   m_cvc_cq01h,
  // ooe_rs, all but its rows.
  input  logic [P-1:0]      req_l_cq00h, req_cq01h,
  input  logic [N-1:0]      sqf_cq01h, msd_cq01h, cfin_cq01h, wtl3_cq00h, fin_cq00h, gnt_cq00h,
  input  logic [NC-1:0]     cmpl_l_cq00h,
  input  logic [NC*W-1:0]   cmpl_idx_cq00h,
  input  logic              sq_l_cq00h,
  // Bench-only: each port's source names, with its request.
  input  logic [P*NS-1:0]   chk_gsv_cq01h,
  input  logic [P*NS*LG-1:0] chk_gsn_cq01h,
  input  logic [P*4-1:0]    chk_psv_cq01h,
  input  logic [P*4*LQ-1:0] chk_psn_cq01h,
  // Bench-only, for a control: bits ORed into rename's rows on their way to
  // ooe_rs (zero but under the control).
  input  logic [P*N-1:0]    ctl_row_cq01h,
  output logic [P-1:0]      gnt_v_cq03h,
  output logic [P*W-1:0]    gnt_idx_cq03h,
  output logic [N-1:0]      valid_out_cq02h,
  output logic [N*N-1:0]    dep_cq02h,
  output logic [2*N*N-1:0]  code_cq02h,
  output logic [N-1:0]      hcol_cq02h,
  output logic [P*N-1:0]    rd_row_dep,     // rename's stage register, for the bench's reports
  output logic [P-1:0]      chk_bad,        // the assertion's ports, for the bench's reports
  output logic [N-1:0]      dbg_eg, dbg_ep, // ooe_prodmap's entries, likewise
  output logic [N*LG-1:0]   dbg_egn,
  output logic [N*LQ-1:0]   dbg_epn
);
  logic [N-1:0]    eg, ec, ep;
  logic [N*LG-1:0] egn;
  logic [N*LQ-1:0] epn;
  logic [N*CW-1:0] ecv;
  logic [P-1:0]    row_prod;
  logic [P*N-1:0]  row_dep;
  logic [2*P*N-1:0] row_code;
  logic [P*P-1:0]  grp_dep, prv_dep;
  logic [2*P*P-1:0] grp_code, prv_code;
  logic [N-1:0]    prod_o;
  ooe_prodmap #(.N(N), .NR(NR), .A(A), .NG(NG), .NP(NP)) u_map (
    .ooe_core_clk, .ooe_rst_r00h, .v_l_cq00h(m_v_l_cq00h), .v_cq01h(m_v_cq01h), .gwe_cq01h(m_gwe_cq01h),
    .gname_cq01h(m_gname_cq01h), .pwe_cq01h(m_pwe_cq01h), .pname_cq01h(m_pname_cq01h), .pm_cq01h(m_pm_cq01h),
    .cv_cq01h(m_cv_cq01h), .pc_cq01h(m_pc_cq01h), .cvc_cq01h(m_cvc_cq01h), .gnt_v_cq02h(gnt_v_cq03h),
    .gnt_idx_cq02h(gnt_idx_cq03h), .eg_cq03h(eg), .egn_cq03h(egn), .ec_cq03h(ec), .ep_cq03h(ep), .epn_cq03h(epn),
    .ecv_cq03h(ecv));
  ooe_rendep #(.N(N), .A(A), .NG(NG), .NP(NP)) u_dep (
    .ooe_core_clk, .ooe_rst_r00h, .v_l_cq00h(d_v_l_cq00h), .v_cq01h(d_v_cq01h), .mem_cq01h(d_mem_cq01h),
    .cp_cq01h(d_cp_cq01h), .atom_cq01h(d_atom_cq01h), .gwe_cq01h(d_gwe_cq01h), .gname_cq01h(d_gname_cq01h),
    .pwe_cq01h(d_pwe_cq01h), .pname_cq01h(d_pname_cq01h), .gsv_cq01h(d_gsv_cq01h), .gsn_cq01h(d_gsn_cq01h),
    .psv_cq01h(d_psv_cq01h), .psn_cq01h(d_psn_cq01h), .cguard_cq01h(d_cguard_cq01h), .cg_cq01h(d_cg_cq01h),
    .cnone_cq01h(d_cnone_cq01h), .unit_cq01h(d_unit_cq01h), .pg_cq01h(d_pg_cq01h), .nob_cq01h(d_nob_cq01h),
    .eg_cq01h(eg), .egn_cq01h(egn), .ep_cq01h(ep), .epn_cq01h(epn), .ecv_cq01h(ecv),
    .gnt_v_cq01h(gnt_v_cq03h), .gnt_idx_cq01h(gnt_idx_cq03h),
    .row_prod_cq02h(row_prod), .row_dep_cq02h(row_dep), .row_code_cq02h(row_code), .grp_dep_cq02h(grp_dep),
    .grp_code_cq02h(grp_code), .prv_dep_cq02h(prv_dep), .prv_code_cq02h(prv_code));
  ooe_rs #(.N(N), .NR(NR), .A(A), .NC(NC)) u_rs (
    .ooe_core_clk, .ooe_rst_r00h, .req_l_cq00h, .req_cq01h, .row_prod_cq01h(row_prod), .row_dep_cq01h(row_dep | ctl_row_cq01h),
    .row_code_cq01h(row_code), .grp_dep_cq01h(grp_dep), .grp_code_cq01h(grp_code), .prv_dep_cq01h(prv_dep),
    .prv_code_cq01h(prv_code), .sqf_cq01h, .msd_cq01h, .cfin_cq01h, .wtl3_cq00h, .fin_cq00h, .gnt_cq00h,
    .cmpl_l_cq00h, .cmpl_idx_cq00h, .sq_l_cq00h, .gnt_v_cq03h, .gnt_idx_cq03h, .valid_out_cq02h, .dep_cq02h,
    .code_cq02h, .prod_o_cq02h(prod_o), .hcol_cq02h);
  assign rd_row_dep = row_dep;
  assign dbg_eg = eg;
  assign dbg_ep = ep;
  assign dbg_egn = egn;
  assign dbg_epn = epn;

  // -- The assertion ------------------------------------------------------------
  // Each port's source names, flopped over the edge that writes its row.
  logic [P*NS-1:0]    gsv_q;
  logic [P*NS*LG-1:0] gsn_q;
  logic [P*4-1:0]     psv_q;
  logic [P*4*LQ-1:0]  psn_q;
  always_ff @(posedge ooe_core_clk) begin
    for (int p = 0; p < P; p++) begin
      gsv_q[p * NS +: NS] <= chk_gsv_cq01h[p * NS +: NS] & {NS{req_cq01h[p]}};
      psv_q[p * 4 +: 4]   <= chk_psv_cq01h[p * 4 +: 4] & {4{req_cq01h[p]}};
    end
    gsn_q <= chk_gsn_cq01h;
    psn_q <= chk_psn_cq01h;
  end
  // After the edge: port p's row is entry gnt_idx[p]'s.
  logic [N-1:0] grp_e;          // the entries granted at the edge
  logic [N-1:0] row, named;
  logic [W-1:0] i;
  always_comb begin
    grp_e = '0;
    for (int q = 0; q < P; q++) if (gnt_v_cq03h[q]) grp_e[gnt_idx_cq03h[q * W +: W]] = 1'b1;
    chk_bad = '0;
    for (int p = 0; p < P; p++) begin
      i     = gnt_idx_cq03h[p * W +: W];
      row   = dep_cq02h[32'(i) * N +: N];
      named = '0;
      for (int j = 0; j < N; j++) begin
        for (int s = 0; s < NS; s++)
          if (gsv_q[p * NS + s] && eg[j] && egn[j * LG +: LG] == gsn_q[(p * NS + s) * LG +: LG]) named[j] = 1'b1;
        for (int s = 0; s < 4; s++)
          if (psv_q[p * 4 + s] && ep[j] && epn[j * LQ +: LQ] == psn_q[(p * 4 + s) * LQ +: LQ]) named[j] = 1'b1;
      end
      if (gnt_v_cq03h[p] && (row & ~grp_e & ~(named & valid_out_cq02h)) != '0) chk_bad[p] = 1'b1;
    end
  end
  `CCV_ASSERT_AT(ooe_core_clk, ooe_rst_r00h, surviving_named, chk_bad == '0)
endmodule
