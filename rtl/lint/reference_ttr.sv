//===-- reference_ttr.sv - a sibling table's reader ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OI-217)
//
// See reference_ttp.sv.
// The bench control that breaks hd_read_not_written is tport-dup.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_ttr (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] rd_cy02h,
  input  logic       pw_cy01h,
  input  logic       wr_cy01h,
  output logic [3:0] o_cy02h
);
  logic [3:0] hd_cy01h;
  assign hd_cy01h = pw_cy01h ? rd_cy02h : 4'd0;
  always_ff @(posedge reference_core_clk) o_cy02h <= hd_cy01h;
  `CCV_ASSERT(hd_read_not_written, !(pw_cy01h && wr_cy01h))
endmodule

`undef CCV_CLK
`undef CCV_RST
