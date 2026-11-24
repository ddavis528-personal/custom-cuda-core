//===-- bad_conn7.sv - lint fixture: a helper crossing whose sibling source is unlisted ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-501)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_nkp is reference_lkp.sv's shape, linted with reference_xc as a
// verified unit (CCV_LINT_FIXTURE_UNITS), but its cone lists only the
// helper crossing u_h.a>z, not the sibling output u_x.y_cy02h the crossing
// reads: a cone lists every source it reads, so it is refused.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_nkp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic nx_cy03h,
  input  logic nb_cy01h,
  output logic ne_cy02h
);
  logic nm_cy03h;
  logic nm_cy04h;
  logic nq_cy04h;
  logic nxy_cy04h;
  logic nhz_cy04h;
  logic nvin_cy04h;
  assign nvin_cy04h = nm_cy04h & nhz_cy04h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(nvin_cy04h), .e_cy02h(ne_cy02h));
  reference_xc u_x (.reference_core_clk, .ref_rst_r00h, .a_cy02h(nq_cy04h), .b_cy01h(nb_cy01h),
    .y_cy02h(nxy_cy04h));
  reference_lh u_h (.a(nxy_cy04h), .z(nhz_cy04h));
  always_ff @(posedge reference_core_clk) begin
    nm_cy03h <= ne_cy02h;
    nm_cy04h <= nm_cy03h;
    nq_cy04h <= nx_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(nm_cy04h && ne_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
