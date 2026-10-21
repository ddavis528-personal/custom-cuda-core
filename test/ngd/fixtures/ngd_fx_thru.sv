// check-ngd fixture: a path straight through, input to output, one gate
// (NGD-5). No port budget clears it; an inner helper's declaration, or an
// observation output, does. tools/check-ngd.py --selftest.
module ngd_fx_thru (
  input  logic [7:0] a,
  input  logic [7:0] b,
  output logic [7:0] y
);
  assign y = a & b;
endmodule
