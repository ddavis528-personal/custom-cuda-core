//===-- reference_gp.sv - a loop through a register-free grandchild ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OI-207,
//       OI-227 (e))
//
// u_c's input a_cy01h reaches its output y_cy01h only through u_c's own
// register-free child u_g (reference_gg): ooe_select's gnt and rhold
// reaching grant_cq03h through ooe_pick. The reach is traced through u_g
// as u_c's logic, so the loop closed by m_cy02h is a back edge, declared
// in reference_gp.feedback.json (its control conn-g-dup).
// tools/check-1d.sh fails if ANY finding is reported here, in
// reference_gc.sv or in reference_gg.sv.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_gp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  output logic z_cy02h
);
  logic m_cy02h;
  logic y_cy01h;
  reference_gc u_c (.reference_core_clk, .ref_rst_r00h, .a_cy01h(m_cy02h), .y_cy01h(y_cy01h),
    .z_cy02h(z_cy02h));
  always_ff @(posedge reference_core_clk) m_cy02h <= y_cy01h;
  `CCV_ASSERT(conn_g_fresh, !(m_cy02h && y_cy01h))
endmodule

`undef CCV_CLK
`undef CCV_RST
