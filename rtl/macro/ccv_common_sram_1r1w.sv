//===-- ccv_common_sram_1r1w.sv - two-port SRAM hard macro: behavioural view --===//
//
// Spec: docs/rtl-coding-style.md, "Hard macros" (AR register rev 344; TI
//       revs 408-410; MA-3, MA-15 item 5).
//
// A large data or tag array is a hard macro, never a flop array. This file
// is the macro's behavioural view, for simulation; synthesis and the gate's
// depth and clock-gating checks read it -lib, ports only (see
// ccv_common_sram_1rw.sv). It is one of the two places a memory array is
// written.
//
// ONE READ PORT AND ONE WRITE PORT on one clock, W bits wide (a whole
// number of bytes), D words deep. Every input is sampled at the rising edge
// of clk, by the macro's own input register, the stage boundary:
//   we         write: each byte b with wmask[b] set takes wdata's byte b
//              at waddr.
//   re         read: rdata is word raddr from the next cycle on. A read of
//              the word written in the same cycle returns the OLD word
//              (read before write).
//   neither    rdata holds the last word read (not X).
//
// The timing model, storage and enables are ccv_common_sram_1rw's: inputs
// are endpoints, rdata launches at 0 NGD (no clock-to-out until Q-48), no
// storage counts as flops, and re and we come from the parent's own flops
// (CG-5).
//
// No reset: an SRAM has none. Its contents are unknown until written.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"

module ccv_common_sram_1r1w #(
  parameter int W = 64,                       // bits per word, a multiple of 8
  parameter int D = 64,                       // words, 2 or more
  localparam int AW = $clog2(D)
) (
  input  logic          clk,
  input  logic          re,
  input  logic [AW-1:0] raddr,
  output logic [W-1:0]  rdata,
  input  logic          we,
  input  logic [AW-1:0] waddr,
  input  logic [W-1:0]  wdata,
  input  logic [W/8-1:0] wmask
);
`define CCV_CLK clk
`define CCV_RST 1'b0
  logic [W-1:0] mem_q [D];
  logic [W-1:0] rdata_q;
  wire          wr_en = we;
  wire          rd_en = re;

  always_ff @(posedge clk) begin
    if (wr_en) begin
      for (int b = 0; b < W / 8; b++) begin
        if (wmask[b]) mem_q[waddr][b*8 +: 8] <= wdata[b*8 +: 8];
      end
    end
  end

  // Nonblocking: the read samples the array as it stood before this
  // edge's write, which is read before write.
  always_ff @(posedge clk) begin
    if (rd_en) rdata_q <= mem_q[raddr];
  end

  assign rdata = rdata_q;

  `CCV_ASSERT_KNOWN(sram_re_known, re)
  `CCV_ASSERT_KNOWN(sram_we_known, we)
  `CCV_ASSERT_KNOWN_IF(sram_raddr_known, re, raddr)
  `CCV_ASSERT_KNOWN_IF(sram_waddr_known, we, waddr)
  `CCV_ASSERT_KNOWN_IF(sram_wmask_known, we, wmask)
  `CCV_ASSERT(sram_raddr_in_range, !re || 32'(raddr) < D)
  `CCV_ASSERT(sram_waddr_in_range, !we || 32'(waddr) < D)
`undef CCV_CLK
`undef CCV_RST
endmodule
