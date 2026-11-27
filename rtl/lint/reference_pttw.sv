//===-- reference_pttw.sv - a sibling table's writer behind a write pipeline ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-500)
//
// See reference_pttp.sv.
// The bench control that breaks hd_read_not_written is tport-dup.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_pttw (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] d_cy00h,
  input  logic       en_cy00h,
  output logic [3:0] rd_cy02h
);
  logic [3:0] dq_cy01h;
  logic       eq_cy01h;
  always_ff @(posedge reference_core_clk) begin
    dq_cy01h <= d_cy00h;
    eq_cy01h <= en_cy00h;
  end

  logic [3:0] tab_cy02h;
  always_ff @(posedge reference_core_clk) begin
    if (eq_cy01h) tab_cy02h <= dq_cy01h;
  end
  assign rd_cy02h = tab_cy02h;
  `CCV_ASSERT_KNOWN(en_known, eq_cy01h)
endmodule

`undef CCV_CLK
`undef CCV_RST
