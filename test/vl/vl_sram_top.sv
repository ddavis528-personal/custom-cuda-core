// tools/check-skel.sh's array-macro lockstep (test/vl/vl_sram_tb.cpp): each
// macro's behavioural view (rtl/macro/: the 1RW SRAM, the 1R1W register
// file, and the register file with byte enables) at a small, odd size -- a
// depth no power of two, a word no whole number of bytes where the macro
// allows it -- for the C++ model in sim/skel/sram.h to follow cycle for
// cycle. Only the _be register file has a byte mask (Daniel, 2026-11-17).
module vl_sram_top (
  input  logic        clk,
  input  logic        ce,
  input  logic        we,
  input  logic [3:0]  addr,
  input  logic [36:0] wdata,
  output logic [36:0] rdata,
  input  logic        re2,
  input  logic [3:0]  raddr2,
  output logic [55:0] rdata2,
  input  logic        we2,
  input  logic [3:0]  waddr2,
  input  logic [55:0] wdata2,
  input  logic [6:0]  wmask2,
  input  logic        re3,
  input  logic [2:0]  raddr3,
  output logic [31:0] rdata3,
  input  logic        we3,
  input  logic [2:0]  waddr3,
  input  logic [31:0] wdata3
);
  ccv_common_sram_1rw #(.W(37), .D(12)) u_1rw (.clk, .ce, .we, .addr, .wdata, .rdata);
  ccv_common_rf_1r1w_be #(.W(56), .D(10)) u_rfbe (
    .clk, .re(re2), .raddr(raddr2), .rdata(rdata2),
    .we(we2), .waddr(waddr2), .wdata(wdata2), .wmask(wmask2));
  ccv_common_rf_1r1w #(.W(32), .D(6)) u_rf (
    .clk, .re(re3), .raddr(raddr3), .rdata(rdata3),
    .we(we3), .waddr(waddr3), .wdata(wdata3));
endmodule
