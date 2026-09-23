//===-- good_naming.sv - net naming, compliant ---------------------------===//
//
// Spec: docs/rtl-coding-style.md, net naming section
// Block: reference
//
// The false-positive regression. A naming rule set that fires on correct code
// gets switched off, so this exercises every construct bad_naming.sv gets
// wrong, done right. tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

module good_naming (
  input  logic       core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] in_data_cy00h,
  output logic [3:0] out_p_cy02h,
  output logic [3:0] out_q_cy01h,
  output logic       out_r_cy01h_b
);

  // The block gates the incoming clock as its first act, and everything
  // sequential below runs on the gated copy.
  logic ref_core_clk;
  logic clk_en_cy00h;
  assign clk_en_cy00h = 1'b1;
  assign ref_core_clk = core_clk & clk_en_cy00h;

  logic [3:0] mid_cy01h;

  // Stage 00 in, stage 01 out: a flop advances exactly one stage.
  always_ff @(posedge ref_core_clk) begin
    if (ref_rst_r00h) mid_cy01h <= '0;
    else              mid_cy01h <= in_data_cy00h;
  end

  // Stage 01 in, stage 02 out.
  always_ff @(posedge ref_core_clk) begin
    if (ref_rst_r00h) out_p_cy02h <= '0;
    else              out_p_cy02h <= mid_cy01h;
  end

  // Combinational: stage preserved, not advanced. The reset net's own tag
  // (block letter `r`) takes no part in the arithmetic, because the reset
  // tree is pipelined by physical distance rather than datapath depth.
  always_comb out_q_cy01h = mid_cy01h + 4'd1;

  // `_b` is a genuine complement of a net that exists, at the same stage --
  // inversion is combinational, so it advances nothing.
  assign out_r_cy01h_b = ~mid_cy01h[0];

endmodule
