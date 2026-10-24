// check-ngd fixture: area recovery relaxes an input's cone (OI-64). The
// multiplier is the module's longest path; the input's own logic is an
// 8-bit add, but map's area recovery lets it grow toward the multiplier,
// reading about 17.6 NGD to s_q, which at the default arrival of 13 would
// fail NGD-3. map -r maps it at about 9.8. tools/check-ngd.py --selftest.
module ngd_fx_relax (
  input  logic        clk,
  input  logic [7:0]  i,
  output logic [15:0] y
);
  logic [7:0]  a_q, b_q, s_q;
  logic [15:0] p_q;
  always_ff @(posedge clk) begin
    a_q <= a_q + 8'd1;
    b_q <= b_q ^ a_q;
    p_q <= a_q * b_q;
    s_q <= i + a_q;
  end
  assign y = p_q ^ {8'd0, s_q};
endmodule
