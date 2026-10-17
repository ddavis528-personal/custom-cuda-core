// Provokes: Drivers conflicting with a constant
// A net tied off and driven as well: the same fault as two drivers.
module ys_const (
  input  logic a,
  output logic y
);
  wire w;
  assign w = a;
  assign w = 1'b0;
  assign y = w;
endmodule
