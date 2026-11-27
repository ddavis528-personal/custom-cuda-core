//===-- reference_mtpp.sv - a sibling's table register read through logic, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, read through an
//       input port; OA-492 (3))
//
// u_map and u_dep's shape (OA-496): u_w's table register tab_cy04h reaches
// its output rd_cy04h through a select, no register between, and the parent
// wires that output straight to u_r's port, declared in reference_mtpr's
// feedback.json with writer u_w.tab_cy04h.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_mtpp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] md_cy03h,
  input  logic       men_cy03h,
  input  logic       msel_cy04h,
  input  logic       mpw_cy03h,
  input  logic       mwr_cy03h,
  output logic [3:0] mo_cy04h
);
  logic [3:0] mrd_cy04h;
  reference_mtpw u_w (.reference_core_clk, .ref_rst_r00h, .d_cy03h(md_cy03h), .en_cy03h(men_cy03h), .sel_cy04h(msel_cy04h), .rd_cy04h(mrd_cy04h));
  reference_mtpr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy04h(mrd_cy04h),
    .pw_cy03h(mpw_cy03h), .wr_cy03h(mwr_cy03h), .o_cy04h(mo_cy04h));
endmodule

`undef CCV_CLK
`undef CCV_RST
