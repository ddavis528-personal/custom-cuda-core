//===-- ooe_rendep_tb.sv - ooe_prodmap and ooe_rendep, as rename wires them ===//
//
// The bench top for test/ooe/rendep_tb.cpp: ooe_prodmap's entry names feed
// ooe_rendep's lookup, both take ooe_rs's registered grant, and the bench
// drives the group's fields at each module's stage (ooe_rendep's Rename 2,
// ooe_prodmap's Rename 3 a cycle later). Its clock-gating unit's scope is
// u_dep.
//===----------------------------------------------------------------------===//
module ooe_rendep_tb #(
  parameter int N  = 45,
  parameter int NR = 30,
  parameter int A  = 4,
  parameter int NG = 768,
  parameter int NP = 48,
  localparam int W   = $clog2(N),
  localparam int P   = 2 * A,
  localparam int LP  = $clog2(P),
  localparam int LG  = $clog2(NG),
  localparam int LQ  = $clog2(NP),
  localparam int NS  = 4
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
  // ooe_rs's registered grant.
  input  logic [P-1:0]      gnt_v,
  input  logic [P*W-1:0]    gnt_idx,
  output logic [P-1:0]      row_prod_cq02h,
  output logic [P*N-1:0]    row_dep_cq02h,
  output logic [2*P*N-1:0]  row_code_cq02h,
  output logic [P*P-1:0]    grp_dep_cq02h,
  output logic [2*P*P-1:0]  grp_code_cq02h,
  output logic [P*P-1:0]    prv_dep_cq02h,
  output logic [2*P*P-1:0]  prv_code_cq02h,
  // ooe_prodmap's entries, for the bench's reports.
  output logic [N-1:0]      dbg_eg, dbg_ep,
  output logic [N*LG-1:0]   dbg_egn,
  output logic [N*LQ-1:0]   dbg_epn
);
  logic [N-1:0]    eg, ec, ep;
  logic [N*LG-1:0] egn;
  logic [N*LQ-1:0] epn;
  ooe_prodmap #(.N(N), .NR(NR), .A(A), .NG(NG), .NP(NP)) u_map (
    .ooe_core_clk, .ooe_rst_r00h, .v_l_cq00h(m_v_l_cq00h), .v_cq01h(m_v_cq01h), .gwe_cq01h(m_gwe_cq01h),
    .gname_cq01h(m_gname_cq01h), .pwe_cq01h(m_pwe_cq01h), .pname_cq01h(m_pname_cq01h), .pm_cq01h(m_pm_cq01h),
    .cv_cq01h(m_cv_cq01h), .pc_cq01h(m_pc_cq01h), .gnt_v_cq02h(gnt_v), .gnt_idx_cq02h(gnt_idx),
    .eg_cq03h(eg), .egn_cq03h(egn), .ec_cq03h(ec), .ep_cq03h(ep), .epn_cq03h(epn));
  ooe_rendep #(.N(N), .A(A), .NG(NG), .NP(NP)) u_dep (
    .ooe_core_clk, .ooe_rst_r00h, .v_l_cq00h(d_v_l_cq00h), .v_cq01h(d_v_cq01h), .mem_cq01h(d_mem_cq01h),
    .cp_cq01h(d_cp_cq01h), .atom_cq01h(d_atom_cq01h), .gwe_cq01h(d_gwe_cq01h), .gname_cq01h(d_gname_cq01h),
    .pwe_cq01h(d_pwe_cq01h), .pname_cq01h(d_pname_cq01h), .gsv_cq01h(d_gsv_cq01h), .gsn_cq01h(d_gsn_cq01h),
    .psv_cq01h(d_psv_cq01h), .psn_cq01h(d_psn_cq01h), .cguard_cq01h(d_cguard_cq01h), .cg_cq01h(d_cg_cq01h),
    .cnone_cq01h(d_cnone_cq01h), .unit_cq01h(d_unit_cq01h), .pg_cq01h(d_pg_cq01h), .nob_cq01h(d_nob_cq01h),
    .eg_cq01h(eg), .egn_cq01h(egn), .ep_cq01h(ep), .epn_cq01h(epn),
    .gnt_v_cq01h(gnt_v), .gnt_idx_cq01h(gnt_idx),
    .row_prod_cq02h, .row_dep_cq02h, .row_code_cq02h, .grp_dep_cq02h, .grp_code_cq02h, .prv_dep_cq02h,
    .prv_code_cq02h);
  // ec (the copy flag) is ooe_prodmap's; the lookup treats a copy's GPR
  // name as any producer's.
  logic unused;
  assign unused = ^ec;
  assign dbg_eg  = eg;
  assign dbg_ep  = ep;
  assign dbg_egn = egn;
  assign dbg_epn = epn;
endmodule
