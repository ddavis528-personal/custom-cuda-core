//===-- ccv_reference_w.sv - a hardening wrapper, compliant --------------===//
//
// Spec: docs/rtl-coding-style.md, Module names
//
// A wrapper holds its one block and the repeaters on the block's channel
// ends, and nothing else (check-top-pure.py). Its name, ccv_<block>_w, says
// which block, and that it has no gate: the block inside it gates core_clk
// itself (OI-37). tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

module ccv_reference_w (
  input  logic       core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] in_data_cy00h,
  output logic [3:0] out_p_cy02h,
  output logic [3:0] out_q_cy01h,
  output logic       out_r_cy01h_b
);
  ccv_reference u_blk (
    .core_clk      (core_clk),
    .ref_rst_r00h  (ref_rst_r00h),
    .in_data_cy00h (in_data_cy00h),
    .out_p_cy02h   (out_p_cy02h),
    .out_q_cy01h   (out_q_cy01h),
    .out_r_cy01h_b (out_r_cy01h_b)
  );
endmodule
