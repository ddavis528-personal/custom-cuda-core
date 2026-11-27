//===-- bad_tport2.sv - lint fixture: a sibling table through a second register ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, read through an
//       input port; OA-492 (3))
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_qtpw's table register tab_cy03h reaches its output only through
// a second register, so the declared writer u_w.tab_cy03h is refused.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_qtpr (
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

module reference_qtpw (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] d_cy02h,
  input  logic       en_cy02h,
  output logic [3:0] rd_cy04h
);
  logic [3:0] tab_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (en_cy02h) tab_cy03h <= d_cy02h;
    rd_cy04h <= tab_cy03h;
  end
  `CCV_ASSERT_KNOWN(en_known, en_cy02h)
endmodule

module reference_qtpp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] qd_cy02h,
  input  logic       qen_cy02h,
  input  logic       qpw_cy03h,
  input  logic       qwr_cy03h,
  output logic [3:0] qo_cy04h
);
  logic [3:0] qrd_cy04h;
  reference_qtpw u_w (.reference_core_clk, .ref_rst_r00h, .d_cy02h(qd_cy02h), .en_cy02h(qen_cy02h), .rd_cy04h(qrd_cy04h));
  reference_qtpr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy04h(qrd_cy04h),
    .pw_cy03h(qpw_cy03h), .wr_cy03h(qwr_cy03h), .o_cy04h(qo_cy04h));
endmodule

`undef CCV_CLK
`undef CCV_RST
