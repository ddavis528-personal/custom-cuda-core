//===-- good_gated_enable.sv - the clock-gating enable form --------------===//
//
// Spec: docs/rtl-coding-style.md, sequential enables
// Block: reference
//
// `if (en)` inside always_ff is the form that infers clock gating, and it is
// legal under every X-determinism rule PROVIDED the enable is prohibited from
// being X. This fixture is the proof that the two postures coexist: it uses
// the gating-friendly spelling and reports nothing.
//
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ref_core_clk
`define CCV_RST ref_rst_r00h
module good_gated_enable (
  input  logic       core_clk,
  input  logic       ref_rst_r00h,
  input  logic       ld_en_cx00h,
  input  logic [7:0] in_data_cx00h,
  output logic [7:0] out_q_cx01h
);
  logic ref_core_clk;
  logic blk_en_cx00h;
  assign blk_en_cx00h = 1'b1;
  assign ref_core_clk = core_clk & blk_en_cx00h;

  // The enable is prohibited from being X, so the `if` form is safe -- and
  // with a real ICG it matters MORE than for a feedback mux: an unknown
  // enable gives an unknown CLOCK, not merely a held value.
  `CCV_ASSERT_KNOWN(ld_en_known, ld_en_cx00h)

  always_ff @(posedge ref_core_clk) begin
    if (ref_rst_r00h)   out_q_cx01h <= '0;
    else if (ld_en_cx00h) out_q_cx01h <= in_data_cx00h;
  end
endmodule
`undef CCV_CLK
`undef CCV_RST
