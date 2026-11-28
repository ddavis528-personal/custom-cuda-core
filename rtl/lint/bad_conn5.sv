//===-- bad_conn5.sv - lint fixture: a table writer's input around its register ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OI-217)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_lttw's input also reaches its output around the table register
// (rd = tab | d), so its back edge is not the table's write and is reported.
// reference_vttr's table holds no assertion, so it does not verify, and
// reference_vttp's writer inputs keep their back edges (OA-497).
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_lttw (
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
  assign rd_cy02h = tab_cy02h | d_cy01h;
  `CCV_ASSERT_KNOWN(en_known, en_cy01h)
endmodule

module reference_lttr (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] rd_cy02h,
  input  logic       pw_cy01h,
  input  logic       wr_cy01h,
  output logic [3:0] o_cy02h
);
  logic [3:0] hd_cy01h;
  assign hd_cy01h = pw_cy01h ? rd_cy02h : 4'd0;
  always_ff @(posedge reference_core_clk) o_cy02h <= hd_cy01h;
  `CCV_ASSERT(hd_read_not_written, !(pw_cy01h && wr_cy01h))
endmodule

module reference_lttp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] lx_cy03h,
  input  logic       len_cy03h,
  input  logic       lpw_cy01h,
  output logic [3:0] lo_cy02h
);
  logic [3:0] lrd_cy02h;
  logic [3:0] ldd_cy04h;
  logic       lee_cy04h;
  always_ff @(posedge reference_core_clk) begin
    ldd_cy04h <= lx_cy03h;
    lee_cy04h <= len_cy03h;
  end
  reference_lttw u_w (.reference_core_clk, .ref_rst_r00h, .d_cy01h(ldd_cy04h), .en_cy01h(lee_cy04h),
    .rd_cy02h(lrd_cy02h));
  reference_lttr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy02h(lrd_cy02h), .pw_cy01h(lpw_cy01h),
    .wr_cy01h(len_cy03h), .o_cy02h(lo_cy02h));
endmodule

module reference_vttw (
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

module reference_vttr (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] rd_cy02h,
  input  logic       pw_cy01h,
  input  logic       wr_cy01h,
  output logic [3:0] o_cy02h
);
  logic [3:0] hd_cy01h;
  assign hd_cy01h = pw_cy01h ? rd_cy02h : 4'd0;
  always_ff @(posedge reference_core_clk) o_cy02h <= hd_cy01h;
endmodule

module reference_vttp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] vx_cy03h,
  input  logic       ven_cy03h,
  input  logic       vpw_cy01h,
  output logic [3:0] vo_cy02h
);
  logic [3:0] vrd_cy02h;
  logic [3:0] vdd_cy04h;
  logic       vee_cy04h;
  always_ff @(posedge reference_core_clk) begin
    vdd_cy04h <= vx_cy03h;
    vee_cy04h <= ven_cy03h;
  end
  reference_vttw u_w (.reference_core_clk, .ref_rst_r00h, .d_cy01h(vdd_cy04h), .en_cy01h(vee_cy04h),
    .rd_cy02h(vrd_cy02h));
  reference_vttr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy02h(vrd_cy02h), .pw_cy01h(vpw_cy01h),
    .wr_cy01h(ven_cy03h), .o_cy02h(vo_cy02h));
endmodule

`undef CCV_CLK
`undef CCV_RST
