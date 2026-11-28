//===-- bad_tport4.sv - lint fixture for a port table's assertion ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, read through an
//       input port; OI-230 (f) and (g), OA 514)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_gtp.sv's pair with one thing broken: nq's parent holds a
// `CCV_ASSERT_T under another label, none named hd_read_not_written; rq's
// reader has a register, so its assertion must be its own, and the
// parent's is not taken; xq's parent assertion has the label but names
// none of the table's nets (OA 514).
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_nqr (
  input  logic [3:0] rd_cy04h,
  input  logic       pw_cy03h,
  output logic [3:0] o_cy03h
);
  logic [3:0] hd_cy03h;
  assign hd_cy03h = pw_cy03h ? rd_cy04h : 4'd0;
  assign o_cy03h = hd_cy03h;
endmodule

module reference_nqp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] nd_cy03h,
  input  logic       nen_cy03h,
  input  logic       npw_cy03h,
  output logic [3:0] no_cy04h
);
  logic [3:0] nrd_cy04h;
  logic [3:0] nh_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (nen_cy03h) nrd_cy04h <= nd_cy03h;
  end
  reference_nqr u_r (.rd_cy04h(nrd_cy04h), .pw_cy03h(npw_cy03h), .o_cy03h(nh_cy03h));
  always_ff @(posedge reference_core_clk) no_cy04h <= nh_cy03h;
  `CCV_ASSERT_KNOWN(en_known, nen_cy03h)
  `CCV_ASSERT_T(hd_other, !(npw_cy03h && nen_cy03h && nrd_cy04h != nd_cy03h))
endmodule

module reference_rqr (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] rd_cy04h,
  input  logic       pw_cy03h,
  output logic [3:0] o_cy04h
);
  logic [3:0] hd_cy03h;
  assign hd_cy03h = pw_cy03h ? rd_cy04h : 4'd0;
  always_ff @(posedge reference_core_clk) o_cy04h <= hd_cy03h;
endmodule

module reference_rqp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] rd_cy03h,
  input  logic       ren_cy03h,
  input  logic       rpw_cy03h,
  output logic [3:0] ro_cy04h
);
  logic [3:0] rrd_cy04h;
  logic [3:0] rh_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ren_cy03h) rrd_cy04h <= rd_cy03h;
  end
  reference_rqr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy04h(rrd_cy04h), .pw_cy03h(rpw_cy03h), .o_cy04h(rh_cy04h));
  always_ff @(posedge reference_core_clk) ro_cy04h <= rh_cy04h;
  `CCV_ASSERT_KNOWN(en_known, ren_cy03h)
  `CCV_ASSERT(hd_read_not_written, !(rpw_cy03h && ren_cy03h && rrd_cy04h != rd_cy03h))
endmodule

module reference_xqr (
  input  logic [3:0] rd_cy04h,
  input  logic       pw_cy03h,
  output logic [3:0] o_cy03h
);
  logic [3:0] hd_cy03h;
  assign hd_cy03h = pw_cy03h ? rd_cy04h : 4'd0;
  assign o_cy03h = hd_cy03h;
endmodule

module reference_xqp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] xd_cy03h,
  input  logic       xen_cy03h,
  input  logic       xpw_cy03h,
  output logic [3:0] xo_cy04h
);
  logic [3:0] xrd_cy04h;
  logic [3:0] xh_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (xen_cy03h) xrd_cy04h <= xd_cy03h;
  end
  reference_xqr u_r (.rd_cy04h(xrd_cy04h), .pw_cy03h(xpw_cy03h), .o_cy03h(xh_cy03h));
  always_ff @(posedge reference_core_clk) xo_cy04h <= xh_cy03h;
  `CCV_ASSERT_KNOWN(en_known, xen_cy03h)
  `CCV_ASSERT(hd_read_not_written, !(xpw_cy03h && xen_cy03h))
endmodule

`undef CCV_CLK
`undef CCV_RST
