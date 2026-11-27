//===-- reference_hp.sv - a loop hop through a helper, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OI-213)
//
// reference_pp.sv's register loop with its first hop through reference_ph,
// a register-free helper: u_c's output enters u_h, whose output feeds
// m_cy03h. The helper is the parent's logic, so the hop is traced through
// it (OI-213); the bench control that breaks conn_m_fresh is conn-m-dup.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_hp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  output logic       e_cy02h
);
  logic       m_cy03h;
  logic       m_cy04h;
  logic [3:0] hy_cy02h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(m_cy04h), .e_cy02h(e_cy02h));
  reference_ph u_h (.a({3'b0, e_cy02h}), .y(hy_cy02h));
  always_ff @(posedge reference_core_clk) begin
    m_cy03h <= hy_cy02h[0];
    m_cy04h <= m_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(m_cy04h && e_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
