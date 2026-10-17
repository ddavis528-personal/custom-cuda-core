// check-ngd fixture: an output its flops reach late, the parity of 64 of
// them, past CCV_NGD_PORT (NGD-2). tools/check-ngd.py --selftest.
module ngd_fx_out (
  input  logic        clk,
  input  logic [63:0] a,
  output logic        y
);
  logic [63:0] q;
  always_ff @(posedge clk) q <= a;
  assign y = ^q;
endmodule
