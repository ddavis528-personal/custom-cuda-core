//===-- reference_compare.sv - a comparison is not an assignment ------===//
//
// Spec: docs/rtl-coding-style.md, net naming section (CCV-L20, L23, L24)
//
// The three rules that read assignments must not read a comparison as one
// (OI-40). Each construct here drew a finding before:
//
//   - `==` in a macro call with no semicolon after it: CCV-L20 read the
//     macro's argument as an assignment running to the next semicolon,
//     past the always_ff header, and reported its clock as read as data;
//   - `<=` in an if-condition: CCV-L23 did stage arithmetic on the
//     condition, as if the compared net were assigned;
//   - a `_b` net compared with `==`: CCV-L24 looked for an inversion on the
//     other side of the comparison.
//
// It is a sub-block of `reference` by its name, on reference_core_clk
// (OI-37).
//
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h
module reference_compare (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       ld_en_cy00h,
  input  logic [3:0] cnt_cy00h,
  input  logic [3:0] lim_cy00h,
  input  logic [7:0] in_data_cy00h,
  output logic [7:0] out_q_cy01h,
  output logic       idle_cy00h_b
);
  assign idle_cy00h_b = ~ld_en_cy00h;

  `CCV_ASSERT_KNOWN(ld_en_known, ld_en_cy00h)
  `CCV_ASSERT_KNOWN(cnt_known, cnt_cy00h)
  `CCV_ASSERT_KNOWN(lim_known, lim_cy00h)
  `CCV_ASSERT(cnt_in_range, ld_en_cy00h == 1'b0 || cnt_cy00h <= lim_cy00h)

  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) out_q_cy01h <= '0;
    else if (idle_cy00h_b == 1'b1 && cnt_cy00h <= lim_cy00h)
      out_q_cy01h <= in_data_cy00h;
  end
endmodule
`undef CCV_CLK
`undef CCV_RST
