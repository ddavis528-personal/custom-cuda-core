// check-ngd fixture: an input that reaches its flop late, the parity of 64
// bits: arriving at 13, past the stage (NGD-3). tools/check-ngd.py --selftest.
module ngd_fx_in (
  input  logic        clk,
  input  logic [63:0] a,
  output logic        y
);
  logic q;
  always_ff @(posedge clk) q <= ^a;
  assign y = q;
endmodule
