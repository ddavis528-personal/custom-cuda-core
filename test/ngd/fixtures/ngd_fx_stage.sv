// check-ngd fixture: flop to flop over the stage, a 16 x 16 multiply
// (NGD-1); also the run whose delay table the selftest corrupts.
// tools/check-ngd.py --selftest.
module ngd_fx_stage (
  input  logic        clk,
  input  logic [15:0] a,
  input  logic [15:0] b,
  output logic [31:0] y
);
  logic [15:0] a_q, b_q;
  logic [31:0] p_q;
  always_ff @(posedge clk) begin
    a_q <= a;
    b_q <= b;
    p_q <= a_q * b_q;
  end
  assign y = p_q;
endmodule
