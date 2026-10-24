// check-cg fixture (selftest 19b, OI-78): a combinational helper that ties
// one output bit to zero, and a parent that registers its outputs. With the
// helper's boundary kept, the tied bit's flop stays; flattened, as an inner
// helper is, it is constant and synthesis drops it, as the replayed
// netlist does.
module cg_fx_inner_h (
  input  logic [3:0] a,
  output logic [3:0] y
);
  assign y = {a[3:1], 1'b0};
endmodule

module cg_fx_inner (
  input  logic       clk,
  input  logic [3:0] d,
  output logic [3:0] q
);
  logic [3:0] h, q_q;
  cg_fx_inner_h u_h (.a(d), .y(h));
  always_ff @(posedge clk) q_q <= h;
  assign q = q_q;
endmodule
