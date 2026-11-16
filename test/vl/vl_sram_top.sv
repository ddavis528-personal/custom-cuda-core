// tools/check-skel.sh's SRAM lockstep (test/vl/vl_sram_tb.cpp): each hard
// macro's behavioural view (rtl/macro/) at a small, odd size -- a depth no
// power of two, a word of a few bytes -- for the C++ model in
// sim/skel/sram.h to follow cycle for cycle.
module vl_sram_top (
  input  logic        clk,
  input  logic        ce,
  input  logic        we,
  input  logic [3:0]  addr,
  input  logic [39:0] wdata,
  input  logic [4:0]  wmask,
  output logic [39:0] rdata,
  input  logic        re2,
  input  logic [3:0]  raddr2,
  output logic [55:0] rdata2,
  input  logic        we2,
  input  logic [3:0]  waddr2,
  input  logic [55:0] wdata2,
  input  logic [6:0]  wmask2
);
  ccv_common_sram_1rw #(.W(40), .D(12)) u_1rw (.clk, .ce, .we, .addr, .wdata, .wmask, .rdata);
  ccv_common_sram_1r1w #(.W(56), .D(10)) u_1r1w (
    .clk, .re(re2), .raddr(raddr2), .rdata(rdata2),
    .we(we2), .waddr(waddr2), .wdata(wdata2), .wmask(wmask2));
endmodule
