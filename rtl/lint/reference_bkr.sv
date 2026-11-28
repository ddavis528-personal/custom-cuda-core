//===-- reference_bkr.sv - a reader whose read-back reaches no lane ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 513)
//
// Child of reference_bkp.sv; see there. l reads v_cy01h only; x reads both.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_bkr (
  input  logic v_cy01h,
  input  logic c_cy01h,
  output logic l,
  output logic x
);
  assign l = v_cy01h;
  assign x = v_cy01h & c_cy01h;
endmodule

`undef CCV_CLK
`undef CCV_RST
