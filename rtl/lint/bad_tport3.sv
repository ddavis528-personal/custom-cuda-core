//===-- bad_tport3.sv - lint fixture for port tables held in the parent ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, read through an
//       input port; OA-492 (3), OI-226 (c))
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_otpp.sv's pair with one thing broken: w's declared writer
// wrd_cy04h is a wire of the parent, not its register; u's declaration is
// signed by OI, not an architect.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_wtpr (
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

module reference_wtpp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] wd_cy04h,
  input  logic       wen_cy03h,
  input  logic       wpw_cy03h,
  output logic [3:0] wo_cy04h
);
  logic [3:0] wrd_cy04h;
  assign wrd_cy04h = wd_cy04h;
  reference_wtpr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy04h(wrd_cy04h),
    .pw_cy03h(wpw_cy03h), .wr_cy03h(wen_cy03h), .o_cy04h(wo_cy04h));
endmodule

module reference_utpr (
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

module reference_utpp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] ud_cy03h,
  input  logic       uen_cy03h,
  input  logic       upw_cy03h,
  output logic [3:0] uo_cy04h
);
  logic [3:0] urd_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (uen_cy03h) urd_cy04h <= ud_cy03h;
  end
  reference_utpr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy04h(urd_cy04h),
    .pw_cy03h(upw_cy03h), .wr_cy03h(uen_cy03h), .o_cy04h(uo_cy04h));
  `CCV_ASSERT_KNOWN(en_known, uen_cy03h)
endmodule

`undef CCV_CLK
`undef CCV_RST
