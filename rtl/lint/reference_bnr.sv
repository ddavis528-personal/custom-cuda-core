//===-- reference_bnr.sv - a reader of its own names a cycle on ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 513)
//
// Child of reference_bnp.sv; see there. nn reads q_cy01h only; g both.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_bnr (
  input  logic q_cy01h,
  input  logic pn_cy01h,
  output logic nn,
  output logic g
);
  assign nn = !q_cy01h;
  assign g  = q_cy01h ^ pn_cy01h;
endmodule

`undef CCV_CLK
`undef CCV_RST
