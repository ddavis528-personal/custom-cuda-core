//===-- reference_kp.sv - a cone over a sibling's output, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OI-218)
//
// u_c's input reads a cone over the parent register m_cy04h and u_k's
// output y_cy04h, both listed (OI-218); the bench control is conn-m-dup.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_kp (
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
  reference_kc u_k (.reference_core_clk, .ref_rst_r00h, .x_cy03h(x_cy03h), .y_cy04h(k_cy04h));
  always_ff @(posedge reference_core_clk) begin
    m_cy03h <= e_cy02h;
    m_cy04h <= m_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(m_cy04h && e_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
