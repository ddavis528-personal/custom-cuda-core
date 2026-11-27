//===-- reference_xc.sv - a child crossed combinationally ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-494)
//
// A child with a register and a combinational path a -> y; see reference_xp.sv.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_xc (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy02h,
  input  logic b_cy01h,
  output logic y_cy02h
);
  logic r_cy02h;
  always_ff @(posedge reference_core_clk) r_cy02h <= b_cy01h;
  assign y_cy02h = a_cy02h ^ r_cy02h;
endmodule

`undef CCV_CLK
`undef CCV_RST
