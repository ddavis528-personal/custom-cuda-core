// check-cg fixture: CG-4. A 4-bit counter on a named enable: under
// CCV_CG_MIN_FLOPS, so no clock gate is built for it and its flops count as
// ungated, and it holds still when idle. With the flopped reset and valid,
// 6 loose flops, within the fixed allowance. Also the small finding the block
// budget fixtures (cg_fx_blk_*) absorb or do not, and, read with
// CG_FX_MISREAD, the flop-count cross-check's control. tools/check-cg.py --selftest.
module cg_fx_small (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  logic       rst_q, v_q;
`ifdef CG_FX_MISREAD
  logic [2:0] c_q;
`else
  logic [3:0] c_q;
`endif
  wire        cnt_en = v_q;

  always_ff @(posedge clk) begin
    rst_q <= rst;
    v_q   <= in_v;
  end

  always_ff @(posedge clk) begin
    if (rst_q)       c_q <= '0;
    else if (cnt_en) c_q <= c_q + 1'b1;
  end

  assign out_v = ^in_d;
  assign out_d = 16'(c_q);
endmodule
