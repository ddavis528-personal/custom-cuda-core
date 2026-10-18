// check-cg fixture: CG-3. hit_q, eight flops on one enable, is enabled by
// every valid, and each bit is a five-input AND that is almost never true,
// so it changes on well under CCV_DCGE_MIN_PCT of its enabled cycles.
// tools/check-cg.py --selftest.
module cg_fx_dcge (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  logic       rst_q, v_q;
  logic [7:0] hit_q;
  wire        hit_en = v_q;

  always_ff @(posedge clk) begin
    rst_q <= rst;
    v_q   <= in_v;
  end

  always_ff @(posedge clk) begin
    if (rst_q)       hit_q <= '0;
    else if (hit_en)
      for (int i = 0; i < 8; i++) hit_q[i] <= &in_d[i +: 5];
  end

  assign out_v = ^hit_q;
  assign out_d = {8'h00, hit_q};
endmodule
