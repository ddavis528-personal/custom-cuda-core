//===-- bad_tport.sv - lint fixture for port tables ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, read through an
//       input port; OA-492 (3))
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_tpp.sv's trio with one thing broken: a's declaration says 2
// stages ahead, not 1; g's parent feeds the port through logic, not the
// register directly; s's reader holds no hd_read_not_written assertion.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_atpr (
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

module reference_atpw (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] d_cy03h,
  input  logic       en_cy03h,
  output logic [3:0] rd_cy04h
);
  always_ff @(posedge reference_core_clk) begin
    if (en_cy03h) rd_cy04h <= d_cy03h;
  end
  `CCV_ASSERT_KNOWN(en_known, en_cy03h)
endmodule

module reference_atpp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] ad_cy03h,
  input  logic       aen_cy03h,
  input  logic       apw_cy03h,
  input  logic [3:0] ax_cy04h,
  output logic [3:0] ao_cy04h
);
  logic [3:0] ard_cy04h;
  logic [3:0] ardg_cy04h;
  assign ardg_cy04h = ard_cy04h & ax_cy04h;
  reference_atpw u_w (.reference_core_clk, .ref_rst_r00h, .d_cy03h(ad_cy03h),
    .en_cy03h(aen_cy03h), .rd_cy04h(ard_cy04h));
  reference_atpr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy04h(ard_cy04h),
    .pw_cy03h(apw_cy03h), .wr_cy03h(aen_cy03h), .o_cy04h(ao_cy04h));
endmodule

module reference_gtpr (
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

module reference_gtpw (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] d_cy03h,
  input  logic       en_cy03h,
  output logic [3:0] rd_cy04h
);
  always_ff @(posedge reference_core_clk) begin
    if (en_cy03h) rd_cy04h <= d_cy03h;
  end
  `CCV_ASSERT_KNOWN(en_known, en_cy03h)
endmodule

module reference_gtpp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] gd_cy03h,
  input  logic       gen_cy03h,
  input  logic       gpw_cy03h,
  input  logic [3:0] gx_cy04h,
  output logic [3:0] go_cy04h
);
  logic [3:0] grd_cy04h;
  logic [3:0] grdg_cy04h;
  assign grdg_cy04h = grd_cy04h & gx_cy04h;
  reference_gtpw u_w (.reference_core_clk, .ref_rst_r00h, .d_cy03h(gd_cy03h),
    .en_cy03h(gen_cy03h), .rd_cy04h(grd_cy04h));
  reference_gtpr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy04h(grdg_cy04h),
    .pw_cy03h(gpw_cy03h), .wr_cy03h(gen_cy03h), .o_cy04h(go_cy04h));
endmodule

module reference_stpr (
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
endmodule

module reference_stpw (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] d_cy03h,
  input  logic       en_cy03h,
  output logic [3:0] rd_cy04h
);
  always_ff @(posedge reference_core_clk) begin
    if (en_cy03h) rd_cy04h <= d_cy03h;
  end
  `CCV_ASSERT_KNOWN(en_known, en_cy03h)
endmodule

module reference_stpp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] sd_cy03h,
  input  logic       sen_cy03h,
  input  logic       spw_cy03h,
  input  logic [3:0] sx_cy04h,
  output logic [3:0] so_cy04h
);
  logic [3:0] srd_cy04h;
  logic [3:0] srdg_cy04h;
  assign srdg_cy04h = srd_cy04h & sx_cy04h;
  reference_stpw u_w (.reference_core_clk, .ref_rst_r00h, .d_cy03h(sd_cy03h),
    .en_cy03h(sen_cy03h), .rd_cy04h(srd_cy04h));
  reference_stpr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy04h(srd_cy04h),
    .pw_cy03h(spw_cy03h), .wr_cy03h(sen_cy03h), .o_cy04h(so_cy04h));
endmodule


`undef CCV_CLK
`undef CCV_RST
