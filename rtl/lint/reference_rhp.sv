//===-- reference_rhp.sv - a registered hop, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-495)
//
// The loop crosses u_d through its register r_cy03h, named as a hop
// "u_d.a_cy02h>r_cy03h>y_cy03h" (OA-495 (c)): a reaches r, and r reaches y,
// each combinationally.
// The bench control that breaks conn_m_fresh is conn-m-dup.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_rhp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic b_cy02h,
  output logic e_cy02h
);
  logic y_cy03h;
  logic m_cy04h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(m_cy04h), .e_cy02h(e_cy02h));
  reference_dc u_d (.reference_core_clk, .ref_rst_r00h, .a_cy02h(e_cy02h), .b_cy02h(b_cy02h),
    .y_cy03h(y_cy03h));
  always_ff @(posedge reference_core_clk) m_cy04h <= y_cy03h;
  `CCV_ASSERT(conn_m_fresh, !(m_cy04h && e_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
