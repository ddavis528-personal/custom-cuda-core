//===-- ooe_pl_tb.sv - ooe_rcupl and ooe_mempl side by side ---------------===//
//
// Bench harness only, never RTL: the two payload formatters as ooe_ent_t,
// ooe_mem_t and ooe_dsc_t reach them, so test/ooe/pl_tb.cpp drives each
// RS entry as it packs it and reads both channels. The widths the RTL sums
// (OOE_PL_*W, rtl/include/ooe_pl.svh) come out as constants, which the bench
// holds to its own packing and to the generated channels' widths, and here
// each is held to its struct's $bits.
//===----------------------------------------------------------------------===//
`include "ooe_pl.svh"
module ooe_pl_tb #(
  parameter int NS  = 4,
  localparam int K  = 2 * NS + 1,
  localparam int EW = OOE_PL_EW,
  localparam int MW = OOE_PL_MW,
  localparam int DW = OOE_PL_DW,
  localparam int IW = OOE_PL_IW,
  localparam int OW = OOE_PL_OW,
  localparam int WI = ccv_prov_pkg::CCV_P_W_RS_IDX
) (
  input  logic             ooe_core_clk,
  input  logic             ooe_rst_r00h,
  // ooe_rcupl
  input  logic             gnt_l_cq01h,
  input  logic [K-1:0]     lv_cq02h,
  input  logic [K*EW-1:0]  le_cq02h,
  input  logic [K*EW-1:0]  pe_cq03h,
  output logic [K-1:0]     iss_v_cq03h,
  output logic [K*IW-1:0]  iss_pay_cq04h,
  // ooe_mempl
  input  logic             mgl_cq01h,
  input  logic             dsc_l_cq01h,
  input  logic [NS-1:0]    mlv_cq02h,
  input  logic [NS*NS-1:0] lfp_cq02h,
  input  logic [NS-1:0]    cok_cq02h,
  input  logic             dv_cq02h,
  input  logic [NS*EW-1:0] mpe_cq03h,
  input  logic [NS*MW-1:0] pm_cq03h,
  input  logic [NS*WI-1:0] pi_cq03h,
  input  logic [DW-1:0]    pd_cq03h,
  output logic [NS-1:0]    mv_cq03h,
  output logic [NS*OW-1:0] mo_pay_cq04h,
  // the widths
  output logic [31:0]      ew, mw, dw, iw, ow
);
  assign ew = EW;
  assign mw = MW;
  assign dw = DW;
  assign iw = IW;
  assign ow = OW;
  initial begin
    if ($bits(ooe_ent_t) != EW) $fatal(1, "OOE_PL_EW %0d, ooe_ent_t %0d", EW, $bits(ooe_ent_t));
    if ($bits(ooe_mem_t) != MW) $fatal(1, "OOE_PL_MW %0d, ooe_mem_t %0d", MW, $bits(ooe_mem_t));
    if ($bits(ooe_dsc_t) != DW) $fatal(1, "OOE_PL_DW %0d, ooe_dsc_t %0d", DW, $bits(ooe_dsc_t));
    if ($bits(ccv_ooe_rcu_issue_t) != IW) $fatal(1, "OOE_PL_IW %0d, the channel %0d", IW, $bits(ccv_ooe_rcu_issue_t));
    if ($bits(ccv_ooe_miu_memop_t) != OW) $fatal(1, "OOE_PL_OW %0d, the channel %0d", OW, $bits(ccv_ooe_miu_memop_t));
  end

  ooe_rcupl #(.NS(NS)) u_rcupl (
    .ooe_core_clk, .ooe_rst_r00h, .gnt_l_cq01h, .lv_cq02h, .le_cq02h, .pe_cq03h, .iss_v_cq03h, .iss_pay_cq04h);
  ooe_mempl #(.NS(NS)) u_mempl (
    .ooe_core_clk, .ooe_rst_r00h, .mgl_cq01h, .dsc_l_cq01h, .lv_cq02h(mlv_cq02h), .lfp_cq02h, .cok_cq02h,
    .dv_cq02h, .pe_cq03h(mpe_cq03h), .pm_cq03h, .pi_cq03h, .pd_cq03h, .mv_cq03h, .mo_pay_cq04h);
endmodule
