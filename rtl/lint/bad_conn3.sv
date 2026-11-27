//===-- bad_conn3.sv - lint fixture: a loop hop through a registered child ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OI-213)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_hp.sv's loop with its first hop through reference_qqreg, a
// child with a register: not combinational, so the hop is not traced.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_qqreg (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy02h,
  output logic y_cy03h
);
  always_ff @(posedge reference_core_clk) y_cy03h <= a_cy02h;
endmodule

module reference_qhp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  output logic       qe_cy02h
);
  logic       qm_cy03h;
  logic       qm_cy04h;
  logic [3:0] qhy_cy02h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(qm_cy04h), .e_cy02h(qe_cy02h));
  logic qqy_cy03h;
  reference_qqreg u_q (.reference_core_clk, .ref_rst_r00h, .a_cy02h(qe_cy02h), .y_cy03h(qqy_cy03h));
  assign qhy_cy02h = {3'b0, qqy_cy03h};
  always_ff @(posedge reference_core_clk) begin
    qm_cy03h <= qhy_cy02h[0];
    qm_cy04h <= qm_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(qm_cy04h && qe_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
