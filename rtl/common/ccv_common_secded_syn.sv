//===-- ccv_common_secded_syn.sv - SECDED syndrome of K data bits -----------===//
//
// Spec: docs/rtl-coding-style.md, "Array reliability" (DA rulings TI-474 to
//       TI-476, Daniel, 2026-11-17).
//
// An inner helper (ccv_common_secded_syn.ngd.json): combinational, no
// flops, timed in its parent. The first half of the decode: the check bits
// of ccv_common_secded_enc's code recomputed from data, XOR the check bits
// stored. ccv_common_secded_fix, the second half, reads it and corrects.
//
// The decode is two helpers so that its latency is the block architect's to
// place (TI-475 (3)): the whole of it at 128 data bits does not fit a stage
// after an SRAM's late rdata (CCV_NGD_SRAM_READ_GUARD), so a parent flops
// the syndrome (and the data) between the two, or uses the data
// speculatively and replays when the flopped syndrome is nonzero. A zero
// syndrome is no error.
//===----------------------------------------------------------------------===//
module ccv_common_secded_syn #(
  parameter int K = 64,                       // data bits, 3 or more
  localparam int R = $clog2(K + $clog2(K) + 1) + 1
) (
  input  logic [K-1:0] data,
  input  logic [R-1:0] chk,
  output logic [R-1:0] syn
);
  `include "ccv_secded.svh"

  for (genvar j = 0; j < R; j++) begin : g_syn
    localparam logic [1023:0] ROW = ccv_secded_row(K, R, j);
    assign syn[j] = ^(data & ROW[K-1:0]) ^ chk[j];
  end
endmodule
