//===-- reference_fnp.sv - a cone through a function call, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-495,
//       OI-226 (a))
//
// reference_cnp.sv's cone, its input formed by a call: vin_cy04h is
// kpeek(m_cy04h), a function declared right after the registers' always_ff
// that reads its argument and k_cy04h, a register of the module, directly.
// The call is logic, not a register: the cone is m_cy04h, its argument,
// and k_cy04h, its body's read, both listed (reference_fnp.feedback.json).
// The bench control that breaks conn_m_fresh is conn-m-dup.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_fnp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic x_cy03h,
  output logic e_cy02h
);
  logic m_cy03h;
  logic m_cy04h;
  logic k_cy04h;
  logic vin_cy04h;
  always_ff @(posedge reference_core_clk) begin
    m_cy03h <= e_cy02h;
    m_cy04h <= m_cy03h;
    k_cy04h <= x_cy03h;
  end
  function automatic logic kpeek(input logic a);
    logic t;
    t = a ^ k_cy04h;
    kpeek = t;
  endfunction
  assign vin_cy04h = kpeek(m_cy04h);
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(vin_cy04h), .e_cy02h(e_cy02h));
  `CCV_ASSERT(conn_m_fresh, !(m_cy04h && e_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
