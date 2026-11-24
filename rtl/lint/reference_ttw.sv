//===-- reference_ttw.sv - a sibling table's writer ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OI-217)
//
// See reference_ttp.sv.
// The bench control that breaks hd_read_not_written is tport-dup.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_ttw (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] d_cy01h,
  input  logic       en_cy01h,
  output logic [3:0] rd_cy02h
);
  logic [3:0] tab_cy02h;
  always_ff @(posedge reference_core_clk) begin
    if (en_cy01h) tab_cy02h <= d_cy01h;
  end
  assign rd_cy02h = tab_cy02h;
  `CCV_ASSERT_KNOWN(en_known, en_cy01h)
endmodule

`undef CCV_CLK
`undef CCV_RST
