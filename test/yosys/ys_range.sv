// Provokes: select out of bounds
// A part-select past the vector: Yosys makes the missing bits undef, which
// synthesis may then set to anything.
module ys_range (
  input  logic [3:0] a,
  output logic [1:0] y
);
  assign y = a[4:3];
endmodule
