//===-- bad_conn4.sv - lint fixture for cones and registered hops ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-495)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_kcnp's cone leaves k out (a register reaching the input but not
// listed); reference_srhp's hop names s_cy03h, which its input a does not
// reach.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_kcnp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic kx_cy03h,
  output logic ke_cy02h
);
  logic km_cy03h;
  logic km_cy04h;
  logic kk_cy04h;
  logic kvin_cy04h;
  assign kvin_cy04h = km_cy04h ^ kk_cy04h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(kvin_cy04h), .e_cy02h(ke_cy02h));
  always_ff @(posedge reference_core_clk) begin
    km_cy03h <= ke_cy02h;
    km_cy04h <= km_cy03h;
    kk_cy04h <= kx_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(km_cy04h && ke_cy02h))
endmodule

module reference_sdc (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy02h,
  input  logic b_cy02h,
  output logic y_cy03h
);
  logic r_cy03h;
  logic s_cy03h;
  always_ff @(posedge reference_core_clk) begin
    r_cy03h <= a_cy02h;
    s_cy03h <= b_cy02h;
  end
  assign y_cy03h = r_cy03h ^ s_cy03h;
endmodule

module reference_srhp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic sb_cy02h,
  output logic se_cy02h
);
  logic sy_cy03h;
  logic sm_cy04h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(sm_cy04h), .e_cy02h(se_cy02h));
  reference_sdc u_d (.reference_core_clk, .ref_rst_r00h, .a_cy02h(se_cy02h), .b_cy02h(sb_cy02h),
    .y_cy03h(sy_cy03h));
  always_ff @(posedge reference_core_clk) sm_cy04h <= sy_cy03h;
  `CCV_ASSERT(conn_m_fresh, !(sm_cy04h && se_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
