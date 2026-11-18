//===-- ccv_common_sram_1rw.sv - one-port SRAM hard macro: behavioural view ---===//
//
// Spec: docs/rtl-coding-style.md, "Hard macros" (AR register rev 344; TI
//       revs 408-410; MA-3, MA-15 item 5; no byte enables, Daniel,
//       2026-11-17).
//
// A large data or tag array is a hard macro, never a flop array. This file
// is the macro's behavioural view, for simulation; synthesis and the gate's
// depth and clock-gating checks read it -lib, ports only (a unit names it
// under "blackbox", as it does the ctech ICG), since a hard macro has
// nothing inside to measure. Only rtl/macro/'s views write a memory array.
//
// ONE PORT, W bits wide, D words deep, whole words only, accessed
// at most every other cycle (DA, 2026-11-16, DA tab rev 123; MA-16): a 6T
// array's bank is busy the cycle after an access, so ce is never set two
// cycles running, and every-cycle bandwidth comes from banking. An array
// that needs every cycle, or a read and a write together, is a register
// file (ccv_common_rf_1r1w), not this. An SRAM has NO BYTE ENABLES
// (Daniel, 2026-11-17): it writes whole words, and an array that must
// write part of a word is a register file with them (ccv_common_rf_1r1w_be,
// 1.5 times a register file's area per bit) or merges the bytes itself. Every input is sampled at the rising
// edge of clk, as the macro's own input register does it -- that register
// is the stage boundary:
//   ce && we   write: wdata replaces the word at addr; a write takes the
//              port's cycle, so nothing is read.
//   ce && !we  read: rdata is word addr from two cycles on (the address
//              registered at the edge that samples ce, the data at the
//              edge after it, the bank busy in between).
//   !ce        nothing: the array holds, and rdata holds after a read's
//              data has arrived.
// rdata holds the last word read until the next read's data (not X), so a
// lockstep check of two models compares it on every cycle.
//
// The timing model (tools/check-ngd.py, NGD-8; Daniel, 2026-11-17): every
// input pin is a timing endpoint and rdata a start point, never a path
// through, each dearer than a flop's: addr, ce and we set up a one-hot
// decode of D words plus CCV_NGD_SRAM_ADDR_MARGIN before the edge, wdata
// CCV_NGD_SRAM_DATA_SETUP; rdata launches at a static W-bit D:1
// read mux / 1.5 (CCV_NGD_MACRO_READ_DYN_PCT) + CCV_NGD_SRAM_READ_GUARD,
// the decode and mux measured as check-ngd times any logic. Storage is
// not flops: check-cg counts none of it. ce and we must come from the
// parent's own flops (CG-5), as every enable does.
//
// No reset: an SRAM has none. Its contents are unknown until written.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"

module ccv_common_sram_1rw #(
  parameter int W = 64,                       // bits per word
  parameter int D = 64,                       // words, 2 or more
  localparam int AW = $clog2(D)
) (
  input  logic          clk,
  input  logic          ce,
  input  logic          we,
  input  logic [AW-1:0] addr,
  input  logic [W-1:0]  wdata,
  output logic [W-1:0]  rdata
);
`define CCV_CLK clk
`define CCV_RST 1'b0
  logic [W-1:0]  mem_q [D];
  logic [W-1:0]  rdata_q;
  logic [AW-1:0] raddr_q;
  logic          rd_pend_q, ce_q;
  wire           wr_en = ce & we;
  wire           rd_en = ce & ~we;
  wire           rd_done_en = rd_pend_q;

  always_ff @(posedge clk) begin
    if (wr_en) mem_q[addr] <= wdata;
  end

  // A read: the address at the edge that samples ce, the word at the next.
  always_ff @(posedge clk) begin
    ce_q      <= ce;
    rd_pend_q <= rd_en;
  end

  always_ff @(posedge clk) begin
    if (rd_en) raddr_q <= addr;
  end

  always_ff @(posedge clk) begin
    if (rd_done_en) rdata_q <= mem_q[raddr_q];
  end

  assign rdata = rdata_q;

  // An unknown control or index on a real SRAM corrupts what it touches:
  // prohibited (docs/rtl-coding-style.md, X-propagation).
  `CCV_ASSERT_KNOWN(sram_ce_known, ce)
  `CCV_ASSERT_KNOWN_IF(sram_we_known, ce, we)
  `CCV_ASSERT_KNOWN_IF(sram_addr_known, ce, addr)
  `CCV_ASSERT(sram_addr_in_range, !ce || 32'(addr) < D)
  // Every other cycle at most (DA tab rev 123): the bank is busy the cycle
  // after an access.
  `CCV_ASSERT(sram_ce_every_other, !(ce && ce_q))
`undef CCV_CLK
`undef CCV_RST
endmodule
