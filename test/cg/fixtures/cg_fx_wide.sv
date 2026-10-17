// check-cg fixture: compliant and wide. An eight-deep, 16-bit shift
// register on one enable: one clock gate of 128 flops, which gives the block
// budget fixtures (cg_fx_blk_*) their size. tools/check-cg.py --selftest.
module cg_fx_wide (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  logic [15:0] s_q [8];
  wire         sh_en = in_v;

  always_ff @(posedge clk) begin
    if (sh_en) begin
      s_q[0] <= in_d;
      for (int i = 1; i < 8; i++) s_q[i] <= s_q[i - 1];
    end
  end

  assign out_v = ^s_q[3];
  assign out_d = s_q[7];
endmodule
