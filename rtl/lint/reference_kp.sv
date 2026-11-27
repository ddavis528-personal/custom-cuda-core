//===-- reference_kp.sv - a cone with a traced crossing, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-498)
//
// u_c's input reads a cone over the parent register m_cy04h and u_x's
// output through its combinational path a_cy02h -> y_cy02h, named as a
// crossing whose input traces back to the listed register q_cy04h (OA-498).
// The bench control is conn-m-dup.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_kp (
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
  logic vin_cy04h;
  assign vin_cy04h = m_cy04h ^ xy_cy04h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(vin_cy04h), .e_cy02h(e_cy02h));
  reference_xc u_x (.reference_core_clk, .ref_rst_r00h, .a_cy02h(q_cy04h), .b_cy01h(b_cy01h),
    .y_cy02h(xy_cy04h));
  always_ff @(posedge reference_core_clk) begin
    m_cy03h <= e_cy02h;
    m_cy04h <= m_cy03h;
    q_cy04h <= x_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(m_cy04h && e_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
