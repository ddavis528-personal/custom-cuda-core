//===-- ccv_common_sram_1rw.sv - one-port SRAM hard macro: behavioural view ---===//
//
// Spec: docs/rtl-coding-style.md, "Hard macros" (AR register rev 344; TI
//       revs 408-410; MA-3, MA-15 item 5).
//
// A large data or tag array is a hard macro, never a flop array. This file
// is the macro's behavioural view, for simulation; synthesis and the gate's
// depth and clock-gating checks read it -lib, ports only (a unit names it
// under "blackbox", as it does the ctech ICG), since a hard macro has
// nothing inside to measure. It is the one place a memory array is written.
//
// ONE PORT, W bits wide (a whole number of bytes), D words deep. Every input
// is sampled at the rising edge of clk, as the macro's own input register
// does it -- that register is the stage boundary:
//   ce && we   write: each byte b with wmask[b] set takes wdata's byte b at
//              addr; a write takes the port's cycle, so nothing is read.
//   ce && !we  read: rdata is word addr from the next cycle on.
//   !ce        nothing: the array and rdata hold.
// rdata holds the last word read until the next read (not X), so a
// lockstep check of two models compares it on every cycle.
//
// The timing model (tools/check-ngd.py, NGD-8): every input pin is a timing
// endpoint, as a flop's D pin, so the parent's logic into it counts within
// the stage; rdata starts the next stage at 0 NGD, as a flop's Q. No
// clock-to-out is charged until the library gives one (Q-48). Storage is
// not flops: check-cg counts none of it. ce and we must come from the
// parent's own flops (CG-5), as every enable does.
//
// No reset: an SRAM has none. Its contents are unknown until written.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"

module ccv_common_sram_1rw #(
  parameter int W = 64,                       // bits per word, a multiple of 8
  parameter int D = 64,                       // words, 2 or more
  localparam int AW = $clog2(D)
) (
  input  logic          clk,
  input  logic          ce,
  input  logic          we,
  input  logic [AW-1:0] addr,
  input  logic [W-1:0]  wdata,
  input  logic [W/8-1:0] wmask,
  output logic [W-1:0]  rdata
);
`define CCV_CLK clk
`define CCV_RST 1'b0
  logic [W-1:0] mem_q [D];
  logic [W-1:0] rdata_q;
  wire          wr_en = ce & we;
  wire          rd_en = ce & ~we;

  always_ff @(posedge clk) begin
    if (wr_en) begin
      for (int b = 0; b < W / 8; b++) begin
        if (wmask[b]) mem_q[addr][b*8 +: 8] <= wdata[b*8 +: 8];
      end
    end
  end

  always_ff @(posedge clk) begin
    if (rd_en) rdata_q <= mem_q[addr];
  end

  assign rdata = rdata_q;

  // An unknown control or index on a real SRAM corrupts what it touches:
  // prohibited (docs/rtl-coding-style.md, X-propagation).
  `CCV_ASSERT_KNOWN(sram_ce_known, ce)
  `CCV_ASSERT_KNOWN_IF(sram_we_known, ce, we)
  `CCV_ASSERT_KNOWN_IF(sram_addr_known, ce, addr)
  `CCV_ASSERT_KNOWN_IF(sram_wmask_known, ce & we, wmask)
  `CCV_ASSERT(sram_addr_in_range, !ce || 32'(addr) < D)
`undef CCV_CLK
`undef CCV_RST
endmodule
