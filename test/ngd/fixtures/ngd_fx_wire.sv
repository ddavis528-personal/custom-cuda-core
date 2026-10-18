// check-ngd fixture: compliant but for one input wired straight to an
// output. A wire, timed as one, and still NGD-5: connect it directly
// (Daniel, 2026-10-18). tools/check-ngd.py --selftest.
module ngd_fx_wire (
  input  logic       clk,
  input  logic [7:0] a,
  input  logic [7:0] w,
  output logic [7:0] y,
  output logic [7:0] z
);
  logic [7:0] q;
  always_ff @(posedge clk) q <= a;
  assign y = q;
  assign z = w;
endmodule
