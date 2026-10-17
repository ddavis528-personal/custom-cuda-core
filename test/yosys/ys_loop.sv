// Provokes: found logic loop
// A combinational loop: no simulator and no netlist agree on its value.
module ys_loop (
  input  logic a,
  output logic y
);
  logic b;
  assign b = a ^ y;
  assign y = b & a;
endmodule
