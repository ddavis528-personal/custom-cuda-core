// Provokes: is implicitly declared
// A misspelt or missing net becomes a fresh 1-bit wire.
module ys_implicit (
  input  logic [3:0] a,
  output logic [3:0] y
);
  assign t = a[0];
  assign y = {3'b0, t};
endmodule
