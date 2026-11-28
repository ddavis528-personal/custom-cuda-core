//===-- reference_gc.sv - a child whose path crosses its own helper ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OI-227 (e))
//
// Child of reference_gp.sv; see there.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_gc (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy01h,
  output logic y_cy01h,
  output logic z_cy02h
);
  reference_gg u_g (.a(a_cy01h), .y(y_cy01h));
  always_ff @(posedge reference_core_clk) z_cy02h <= a_cy01h;
endmodule

`undef CCV_CLK
`undef CCV_RST
