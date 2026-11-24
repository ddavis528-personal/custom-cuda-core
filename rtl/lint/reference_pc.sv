//===-- reference_pc.sv - a child in a register-closed loop ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 481-490,
//       OI-207)
//
// Child of reference_pp.sv; see there.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_pc (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic v_cy01h,
  output logic e_cy02h
);
  always_ff @(posedge reference_core_clk) e_cy02h <= v_cy01h;
endmodule

`undef CCV_CLK
`undef CCV_RST
