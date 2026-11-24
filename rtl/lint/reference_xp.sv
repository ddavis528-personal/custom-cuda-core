//===-- reference_xp.sv - a loop hop crossing a child, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-494)
//
// The register loop's first hop crosses u_x, a child with a register of its
// own, through its combinational path a_cy02h -> y_cy02h, named in the loop
// as "u_x.a_cy02h>y_cy02h" (OA-494); the bench control is conn-m-dup.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_xp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic b_cy01h,
  output logic e_cy02h
);
  logic m_cy03h;
  logic m_cy04h;
  logic y_cy02h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(m_cy04h), .e_cy02h(e_cy02h));
  reference_xc u_x (.reference_core_clk, .ref_rst_r00h, .a_cy02h(e_cy02h), .b_cy01h(b_cy01h),
    .y_cy02h(y_cy02h));
  always_ff @(posedge reference_core_clk) begin
    m_cy03h <= y_cy02h;
    m_cy04h <= m_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(m_cy04h && e_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
