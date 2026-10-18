// check-cg fixture: a large module with a little left over. A 32-deep,
// 16-bit shift register is one 512-flop clock gate; idle_q, 8 flops
// written every cycle, holds still when its input does, and the flopped
// reset and valid are 2 more. 10 is past the fixed allowance of fewer than
// CCV_CG_MODULE_FLOPS, so only the 2% of 522 flops (10.4) takes them.
// tools/check-cg.py --selftest.
module cg_fx_big (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  logic        rst_q, v_q;
  logic [15:0] s_q [32];
  logic [7:0]  idle_q;
  wire         sh_en = v_q;

  always_ff @(posedge clk) begin
    rst_q <= rst;
    v_q   <= in_v;
  end

  always_ff @(posedge clk) begin
    if (sh_en) begin
      s_q[0] <= in_d;
      for (int i = 1; i < 32; i++) s_q[i] <= s_q[i - 1];
    end
  end

  always_ff @(posedge clk) begin
    if (rst_q) idle_q <= '0;
    else       idle_q <= in_d[7:0];
  end

  assign out_v = ^idle_q;
  assign out_d = s_q[31] ^ s_q[15];
endmodule
