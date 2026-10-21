// check-cg fixture: compliant and wide. A sixteen-deep, 16-bit shift
// register on one enable, the flopped valid: one clock gate of 256 flops,
// which gives the block budget fixtures (cg_fx_blk_*) their size. It uses no
// reset. tools/check-cg.py --selftest.
module cg_fx_wide (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  logic        v_q;
  logic [15:0] s_q [16];
  wire         sh_en = v_q;

  always_ff @(posedge clk) begin
    v_q <= in_v;
  end

  always_ff @(posedge clk) begin
    if (sh_en) begin
      s_q[0] <= in_d;
      for (int i = 1; i < 16; i++) s_q[i] <= s_q[i - 1];
    end
  end

  assign out_v = ^s_q[3];
  assign out_d = s_q[15];
endmodule
