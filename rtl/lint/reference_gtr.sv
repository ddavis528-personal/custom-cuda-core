//===-- reference_gtr.sv - a register-free reader of its parent's table ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, read through an
//       input port; OI-230 (g))
//
// Child of reference_gtp.sv; see there.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_gtr (
  input  logic [3:0] rd_cy04h,
  input  logic       pw_cy03h,
  output logic [3:0] o_cy03h
);
  logic [3:0] hd_cy03h;
  assign hd_cy03h = pw_cy03h ? rd_cy04h : 4'd0;
  assign o_cy03h = hd_cy03h;
endmodule

`undef CCV_CLK
`undef CCV_RST
