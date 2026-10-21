// check-ngd fixture: within every default. Its input goes straight to a
// flop, its output is one gate after its flops. tools/check-ngd.py --selftest.
module ngd_fx_ok (
  input  logic       clk,
  input  logic       rst,
  input  logic [7:0] a,
  output logic [7:0] y
);
  logic [7:0] q;
  always_ff @(posedge clk) q <= rst ? '0 : (q ^ a);
  assign y = q & {q[6:0], q[7]};
endmodule
