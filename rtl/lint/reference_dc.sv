//===-- reference_dc.sv - a child with registers on a loop ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-495)
//
// See reference_rhp.sv.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_dc (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy02h,
  input  logic b_cy02h,
  output logic y_cy03h
);
  logic r_cy03h;
  logic s_cy03h;
  always_ff @(posedge reference_core_clk) begin
    r_cy03h <= a_cy02h;
    s_cy03h <= b_cy02h;
  end
  assign y_cy03h = r_cy03h ^ s_cy03h;
endmodule

`undef CCV_CLK
`undef CCV_RST
