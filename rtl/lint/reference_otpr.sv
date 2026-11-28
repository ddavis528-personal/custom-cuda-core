//===-- reference_otpr.sv - a table read from its parent's register ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, read through an
//       input port; OA-492 (3), OI-226 (c))
//
// Reads its parent's hold register rd_cy04h at stage 03, never in a cycle
// it is written (hd_read_not_written; the bench control that breaks it is
// tport-dup). Declared in reference_otpr.feedback.json; parent
// reference_otpp (OI-226 (c)).
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_otpr (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] rd_cy04h,
  input  logic       pw_cy03h,
  input  logic       wr_cy03h,
  output logic [3:0] o_cy04h
);
  logic [3:0] hd_cy03h;
  assign hd_cy03h = pw_cy03h ? rd_cy04h : 4'd0;
  always_ff @(posedge reference_core_clk) o_cy04h <= hd_cy03h;
  `CCV_ASSERT(hd_read_not_written, !(pw_cy03h && wr_cy03h))
endmodule

`undef CCV_CLK
`undef CCV_RST
