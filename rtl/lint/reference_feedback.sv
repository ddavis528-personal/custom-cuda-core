//===-- reference_feedback.sv - state that reads its own stage ---------===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (OI's question, OI-65)
//
// A queue's state at stage 01: its entries and its count. Each register's
// next value reads the stage-01 state it updates, as a state machine's does,
// and the arrival it takes is at stage 00, one stage before. Both feedback
// forms CCV-L23 allows are here:
//
//   - in an always_ff, a stage-01 register reading other stage-01 state
//     (q_cy01h's next value reads cnt_cy01h);
//   - on the D side, a combinational net at stage 00 that only flops read
//     (cnt_nx_cy00h and q_en_cy00h) reading the stage-01 state it updates.
//
// It is a sub-block of `reference` by its name, on reference_core_clk.
//
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h
module reference_feedback (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       push_cy00h,
  input  logic [7:0] in_data_cy00h,
  output logic [7:0] out_q_cy01h,
  output logic [1:0] out_cnt_cy01h
);
  `CCV_ASSERT_KNOWN(push_known, push_cy00h)

  logic [7:0] q_cy01h;
  logic [1:0] cnt_cy01h;
  logic [1:0] cnt_nx_cy00h;
  logic       q_en_cy00h;
  assign cnt_nx_cy00h = cnt_cy01h + {1'b0, push_cy00h};
  assign q_en_cy00h   = push_cy00h && cnt_cy01h != 2'd3;

  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h)    cnt_cy01h <= '0;
    else if (push_cy00h) cnt_cy01h <= cnt_nx_cy00h;
  end
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h)    q_cy01h <= '0;
    else if (q_en_cy00h) q_cy01h <= in_data_cy00h ^ {6'd0, cnt_cy01h};
  end
  assign out_q_cy01h   = q_cy01h;
  assign out_cnt_cy01h = cnt_cy01h;
endmodule
`undef CCV_CLK
`undef CCV_RST
