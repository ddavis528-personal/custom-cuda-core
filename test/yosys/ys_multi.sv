// Provokes: multiple conflicting drivers
// Two drivers on one net: the netlist keeps both and resolves neither.
module ys_multi (
  input  logic a,
  input  logic b,
  output logic y
);
  wire w;
  assign w = a;
  assign w = b;
  assign y = w;
endmodule
