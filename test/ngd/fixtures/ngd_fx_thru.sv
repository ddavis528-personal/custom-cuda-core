// check-ngd fixture: a path straight through, input to output, one gate.
// It fits no default port budget; explicit budgets that converge clear it.
// tools/check-ngd.py --selftest.
module ngd_fx_thru (
  input  logic [7:0] a,
  input  logic [7:0] b,
  output logic [7:0] y
);
  assign y = a & b;
endmodule
