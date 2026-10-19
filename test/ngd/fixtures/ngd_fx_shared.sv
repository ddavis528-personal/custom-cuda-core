// check-ngd fixtures for NGD-7: a register that drives an output is held,
// on every path it starts, to that output's required time. a_q drives the
// outputs y and w and, through a 6 by 6 multiply (15.9 NGD as mapped), the
// module's own flop p_q: shared, it is pulled two ways at placement. With y
// and w budgeted at 18 it passes; with only y, w's 12 still holds it. Split
// into two copies,
// each (* keep *), the output's copy reaches only y. Split without the mark,
// synthesis merges the copies back, as a real flow would.
// tools/check-ngd.py --selftest.
module ngd_fx_shared (
  input  logic        clk,
  input  logic [5:0]  d,
  output logic [5:0]  y,
  output logic        w,
  output logic [11:0] z
);
  logic [5:0]  a_q;
  logic [11:0] p_q;
  always_ff @(posedge clk) a_q <= d;
  always_ff @(posedge clk) p_q <= a_q * a_q;
  assign y = a_q;
  assign w = a_q[0] ^ a_q[1];
  assign z = p_q;
endmodule

module ngd_fx_split (
  input  logic        clk,
  input  logic [5:0]  d,
  output logic [5:0]  y,
  output logic [11:0] z
);
  (* keep *) logic [5:0] a_q;
  (* keep *) logic [5:0] a_in_q;
  logic [11:0] p_q;
  always_ff @(posedge clk) begin
    a_q    <= d;
    a_in_q <= d;
  end
  always_ff @(posedge clk) p_q <= a_in_q * a_in_q;
  assign y = a_q;
  assign z = p_q;
endmodule

module ngd_fx_split_bare (
  input  logic        clk,
  input  logic [5:0]  d,
  output logic [5:0]  y,
  output logic [11:0] z
);
  logic [5:0]  a_q, a_in_q;
  logic [11:0] p_q;
  always_ff @(posedge clk) begin
    a_q    <= d;
    a_in_q <= d;
  end
  always_ff @(posedge clk) p_q <= a_in_q * a_in_q;
  assign y = a_q;
  assign z = p_q;
endmodule
