// Provokes: is used but has no driver
// Read but never written: Yosys leaves it floating, which is undef.
module ys_undriven (
  input  logic [3:0] a,
  output logic [3:0] y
);
  logic [3:0] z;
  assign y = a & z;
endmodule
