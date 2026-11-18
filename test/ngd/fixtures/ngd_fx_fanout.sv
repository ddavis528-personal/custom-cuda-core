// check-ngd fixture: one flop's net drives 1,024 loads, the PRF read select's
// shape (RA-33). The fanout term (DA, 2026-11-02) adds ceil(log4(1024/4)) = 4
// inverter stages to every path through that net; at fanout 4 it adds none.
// tools/check-ngd.py --selftest.
module ngd_fx_fanout (
  input  logic          clk,
  input  logic          rst,
  input  logic [1023:0] a,
  output logic [1023:0] y
);
  logic s;
  logic [1023:0] q;
  always_ff @(posedge clk) s <= rst ? 1'b0 : a[0];
  always_ff @(posedge clk) q <= a & {1024{s}};
  assign y = q;
endmodule
