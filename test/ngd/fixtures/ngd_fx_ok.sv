// check-ngd fixture: within every default. Its input goes straight to a
// flop, its output is one gate after its flops, and one input is wired
// straight to an output, a wire and not logic (NGD-5).
// tools/check-ngd.py --selftest.
module ngd_fx_ok (
  input  logic       clk,
  input  logic       rst,
  input  logic [7:0] a,
  input  logic [7:0] w,
  output logic [7:0] y,
  output logic [7:0] z
);
  logic [7:0] q;
  always_ff @(posedge clk) q <= rst ? '0 : (q ^ a);
  assign y = q & {q[6:0], q[7]};
  assign z = w;
endmodule
