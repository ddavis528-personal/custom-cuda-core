// check-ngd fixtures: an inner helper of 18.5 NGD input to output, a 6 by 6
// multiply, over the 16 NGD an inner helper is held to while no module
// instantiates it (NGD-6, CCV_NGD_INNER), and well within the stage once a
// parent puts it between two of its flops. tools/check-ngd.py --selftest.
module ngd_fx_helper (
  input  logic [5:0]  a,
  input  logic [5:0]  b,
  output logic [11:0] y
);
  assign y = a * b;
endmodule

module ngd_fx_helper_par (
  input  logic        clk,
  input  logic [5:0]  a,
  input  logic [5:0]  b,
  output logic [11:0] y
);
  logic [5:0]  a_q, b_q;
  logic [11:0] p;
  always_ff @(posedge clk) begin
    a_q <= a;
    b_q <= b;
  end
  ngd_fx_helper u_h (.a(a_q), .b(b_q), .y(p));
  always_ff @(posedge clk) y <= p;
endmodule
