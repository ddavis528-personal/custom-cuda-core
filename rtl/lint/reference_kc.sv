//===-- reference_kc.sv - a registered sibling ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OI-218)
//
// See reference_kp.sv.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_kc (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic x_cy03h,
  output logic y_cy04h
);
  always_ff @(posedge reference_core_clk) y_cy04h <= x_cy03h;
endmodule

`undef CCV_CLK
`undef CCV_RST
