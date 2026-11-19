//===-- ccv_common_secded_enc.sv - SECDED check bits for K data bits --------===//
//
// Spec: docs/rtl-coding-style.md, "Hard macros", "Array reliability" (DA
//       rulings TI-474 to TI-476, Daniel, 2026-11-17): every SRAM holds
//       SECDED ECC; the ECC logic is the block's, outside the SRAM wrapper,
//       and hiding its latency is the block architect's job.
//
// An inner helper (ccv_common_secded_enc.ngd.json): combinational, no
// flops, timed in its parent, which flops what it returns or writes it to an
// SRAM's wdata (whose setup is CCV_NGD_SRAM_DATA_SETUP).
//
// A Hsiao code (odd-weight columns): K data bits take R check bits, R the
// least with 2^(R-1) - R >= K, which for the K the design uses is
// clog2(K + clog2(K) + 1) + 1 (CCV_MACRO_SRAM_MAX_W's derive; (72,64),
// (137,128)). Data bit i's column of the parity-check matrix is the i-th
// R-bit vector of odd weight 3 or more, taken by weight and then by value
// (ccv_secded_col); check bit j's is the unit vector j. Check bit j is the
// XOR of the data bits whose column has bit j set. Every column odd makes a
// single error's syndrome odd and a double's even and nonzero, so the
// decoder (ccv_common_secded_syn, then ccv_common_secded_fix) corrects one
// and detects two.
// sim/skel/secded.h is the same code in C++, bit for bit
// (test/vl/vl_secded_tb.cpp holds them together).
//===----------------------------------------------------------------------===//
module ccv_common_secded_enc #(
  parameter int K = 64,                       // data bits, 3 or more
  localparam int R = $clog2(K + $clog2(K) + 1) + 1
) (
  input  logic [K-1:0] data,
  output logic [R-1:0] chk
);
  `include "ccv_secded.svh"

  for (genvar j = 0; j < R; j++) begin : g_chk
    localparam logic [1023:0] ROW = ccv_secded_row(K, R, j);
    assign chk[j] = ^(data & ROW[K-1:0]);
  end
endmodule
