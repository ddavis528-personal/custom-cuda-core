//===-- reference_lkp.sv - a cone from a sibling's output through a helper, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-501)
//
// The leads' shape (OI-220, OA-501): u_c's input reads a cone whose source
// is u_x's registered output y_cy02h (a sibling whose tags are verified,
// OA-499), reached through the register-free helper u_h, named as the
// crossing u_h.a>z (OA-494), then the parent's AND. The two forms compose.
// tools/check-1d.sh names reference_xc a verified unit for this file only
// (CCV_LINT_FIXTURE_UNITS); fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_lkp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic x_cy03h,
  input  logic b_cy01h,
  output logic e_cy02h
);
  logic m_cy03h;
  logic m_cy04h;
  logic q_cy04h;
  logic xy_cy04h;
  logic hz_cy04h;
  logic vin_cy04h;
  assign vin_cy04h = m_cy04h & hz_cy04h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(vin_cy04h), .e_cy02h(e_cy02h));
  reference_xc u_x (.reference_core_clk, .ref_rst_r00h, .a_cy02h(q_cy04h), .b_cy01h(b_cy01h),
    .y_cy02h(xy_cy04h));
  reference_lh u_h (.a(xy_cy04h), .z(hz_cy04h));
  always_ff @(posedge reference_core_clk) begin
    m_cy03h <= e_cy02h;
    m_cy04h <= m_cy03h;
    q_cy04h <= x_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(m_cy04h && e_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
