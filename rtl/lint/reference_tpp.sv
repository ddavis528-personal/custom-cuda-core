//===-- reference_tpp.sv - a port table's parent, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, read through an
//       input port; OA-492 (3))
//
// ooe_rob_w and ooe_redir's shape (OA-492 (3)): u_w holds words in a
// register at stage 04, u_r reads them at 03 through its input port, fed
// directly by that register. tools/check-1d.sh fails if ANY finding is
// reported here, in reference_tpr.sv or in reference_tpw.sv.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_tpp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] d_cy03h,
  input  logic       en_cy03h,
  input  logic       pw_cy03h,
  input  logic [3:0] x_cy04h,
  output logic [3:0] o_cy04h
);
  logic [3:0] rd_cy04h;
  logic [3:0] rdg_cy04h;
  assign rdg_cy04h = rd_cy04h & x_cy04h;
  reference_tpw u_w (.reference_core_clk, .ref_rst_r00h, .d_cy03h(d_cy03h),
    .en_cy03h(en_cy03h), .rd_cy04h(rd_cy04h));
  reference_tpr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy04h(rd_cy04h),
    .pw_cy03h(pw_cy03h), .wr_cy03h(en_cy03h), .o_cy04h(o_cy04h));
endmodule

`undef CCV_CLK
`undef CCV_RST
