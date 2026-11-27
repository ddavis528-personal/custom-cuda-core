//===-- reference_mtpw.sv - a sibling's table, read through logic ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, read through an
//       input port; OA-492 (3))
//
// See reference_mtpp.sv.
// The bench control that breaks hd_read_not_written is tport-dup.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_mtpw (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] d_cy03h,
  input  logic       en_cy03h,
  input  logic       sel_cy04h,
  output logic [3:0] rd_cy04h
);
  logic [3:0] tab_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (en_cy03h) tab_cy04h <= d_cy03h;
  end
  assign rd_cy04h = sel_cy04h ? tab_cy04h : 4'd0;
  `CCV_ASSERT_KNOWN(en_known, en_cy03h)
endmodule

`undef CCV_CLK
`undef CCV_RST
