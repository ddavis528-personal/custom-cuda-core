//===-- ccv_common_secded_fix.sv - SECDED correct and classify, K data bits --===//
//
// Spec: docs/rtl-coding-style.md, "Array reliability" (DA rulings TI-474 to
//       TI-476, Daniel, 2026-11-17).
//
// An inner helper (ccv_common_secded_fix.ngd.json): combinational, no
// flops, timed in its parent. The second half of the decode, from the
// syndrome ccv_common_secded_syn computed (usually flopped between them;
// see there). Zero: no error, q is data. Equal to a data bit's column: that
// bit was wrong and is flipped in q; a unit vector: a check bit was wrong
// and q is data; both set sec. Anything else (even and nonzero, or odd and
// no column): two or more bits are wrong, ded, and q is data unchanged, not
// to be used.
//===----------------------------------------------------------------------===//
module ccv_common_secded_fix #(
  parameter int K = 64,                       // data bits, 3 or more
  localparam int R = $clog2(K + $clog2(K) + 1) + 1
) (
  input  logic [K-1:0] data,
  input  logic [R-1:0] syn,
  output logic [K-1:0] q,                     // data, a single error corrected
  output logic         sec,                   // one bit was wrong, corrected
  output logic         ded                    // two or more: uncorrectable
);
  `include "ccv_secded.svh"

  // The parity-check matrix's data part, row by row (constants): data bit
  // i's column is bit i of every row.
  logic [K-1:0] h [R];
  for (genvar j = 0; j < R; j++) begin : g_row
    localparam logic [1023:0] ROW = ccv_secded_row(K, R, j);
    assign h[j] = ROW[K-1:0];
  end

  logic [K-1:0] flip;
  always_comb begin
    for (int i = 0; i < K; i++) begin
      flip[i] = 1'b1;
      for (int j = 0; j < R; j++) flip[i] &= syn[j] == h[j][i];
    end
  end

  // A check bit's own error: the syndrome is a unit vector.
  logic chk_err;
  always_comb begin
    chk_err = 1'b0;
    for (int j = 0; j < R; j++) chk_err |= syn == R'(1 << j);
  end

  assign q   = data ^ flip;
  assign sec = |flip | chk_err;
  assign ded = |syn & ~sec;
endmodule
