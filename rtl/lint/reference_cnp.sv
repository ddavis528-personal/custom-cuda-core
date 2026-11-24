//===-- reference_cnp.sv - a cone source, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-495)
//
// u_c's input reads vin_cy04h, a cone over two parent registers (m_cy04h on
// the loop, k_cy04h beside it), declared with both listed (OA-495 (a)).
// The bench control that breaks conn_m_fresh is conn-m-dup.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_cnp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic x_cy03h,
  output logic e_cy02h
);
  logic m_cy03h;
  logic m_cy04h;
  logic k_cy04h;
  logic vin_cy04h;
  assign vin_cy04h = m_cy04h ^ k_cy04h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(vin_cy04h), .e_cy02h(e_cy02h));
  always_ff @(posedge reference_core_clk) begin
    m_cy03h <= e_cy02h;
    m_cy04h <= m_cy03h;
    k_cy04h <= x_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(m_cy04h && e_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
