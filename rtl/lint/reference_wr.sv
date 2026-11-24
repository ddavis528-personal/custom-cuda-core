//===-- reference_wr.sv - a cross-module loop's writer ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 481-483,
//       TI-554..556; MI-35)
//
// Child of reference_top.sv (reference_conn's trio); see there.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_wr (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic ms_cy03h,
  output logic l0_cy06h
);
  logic q_cy04h;
  logic q_cy05h;
  always_ff @(posedge reference_core_clk) begin
    q_cy04h  <= ms_cy03h;
    q_cy05h  <= q_cy04h;
    l0_cy06h <= q_cy05h;
  end
endmodule

`undef CCV_CLK
`undef CCV_RST
