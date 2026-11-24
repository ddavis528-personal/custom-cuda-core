//===-- reference_rd.sv - a cross-module loop's reader ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 481-483,
//       TI-554..556; MI-35)
//
// Child of reference_top.sv (reference_conn's trio); see there.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_rd (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy01h,
  input  logic l0_cy02h,
  output logic ms_cy03h
);
  logic a_cy02h;
  logic hit_cy02h;
  always_ff @(posedge reference_core_clk) a_cy02h <= a_cy01h;
  assign hit_cy02h = a_cy02h & l0_cy02h;
  always_ff @(posedge reference_core_clk) ms_cy03h <= hit_cy02h;
endmodule

`undef CCV_CLK
`undef CCV_RST
