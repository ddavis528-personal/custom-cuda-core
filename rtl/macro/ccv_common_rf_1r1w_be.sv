//===-- ccv_common_rf_1r1w_be.sv - 1R1W register file, byte enables -------===//
//
// Spec: docs/rtl-coding-style.md, "Hard macros" (byte enables: Daniel,
//       2026-11-17; the register file: DA tab rev 123, MA-16).
//
// ccv_common_rf_1r1w with a byte mask on its write port: the ONLY array
// macro with byte enables (Daniel, 2026-11-17). An SRAM has none, and a
// register file that writes whole words is ccv_common_rf_1r1w. The byte
// enables cost 1.5 times the register file's area per bit
// (CCV_MACRO_AREA_BYTE_EN_PCT), so 4.5 times an SRAM's, the weight any
// area report gives it. This file is the macro's behavioural view, for
// simulation; synthesis and the gate's depth and clock-gating checks read
// it -lib, ports only (see ccv_common_sram_1rw.sv).
//
// ONE READ PORT AND ONE WRITE PORT on one clock, each usable every cycle,
// W bits wide (a whole number of bytes), D words deep. Every input is
// sampled at the rising edge of clk, by the macro's own input register:
//   we         write: each byte b with wmask[b] set takes wdata's byte b
//              at waddr (bit b of wmask is byte b, byte 0 in bit 0).
//   re         read: rdata is word raddr from the next cycle on. A read of
//              the word written in the same cycle returns the OLD word
//              (read before write).
//   neither    rdata holds the last word read (not X).
//
// The timing model, storage and enables are ccv_common_rf_1r1w's (CCV_NGD_RF_*;
// Daniel, 2026-11-17), wmask timed as write data (CCV_NGD_RF_DATA_SETUP).
//
// No reset: the macro has none. Its contents are unknown until written.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"

module ccv_common_rf_1r1w_be #(
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

  `CCV_ASSERT_KNOWN(rfbe_re_known, re)
  `CCV_ASSERT_KNOWN(rfbe_we_known, we)
  `CCV_ASSERT_KNOWN_IF(rfbe_raddr_known, re, raddr)
  `CCV_ASSERT_KNOWN_IF(rfbe_waddr_known, we, waddr)
  `CCV_ASSERT_KNOWN_IF(rfbe_wmask_known, we, wmask)
  `CCV_ASSERT(rfbe_raddr_in_range, !re || 32'(raddr) < D)
  `CCV_ASSERT(rfbe_waddr_in_range, !we || 32'(waddr) < D)
`undef CCV_CLK
`undef CCV_RST
endmodule
