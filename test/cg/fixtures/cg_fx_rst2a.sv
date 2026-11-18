// check-cg fixture: RST-2's control. The reset is flopped (RST-1 holds), but
// a_q takes it at stage 1 and b_q at stage 2, so reset does not arrive in
// one cycle at every endpoint: a_q needs +1 reset stage.
// tools/check-cg.py --selftest.
module cg_fx_rst2a (
  input  logic       clk,
  input  logic       rst,
  input  logic       in_v,
  input  logic [7:0] in_d,
  output logic [7:0] a_o,
  output logic [7:0] b_o
);
  logic       rst_q, rst_q2, v_q;
  logic [7:0] a_q, b_q;
  wire        ld_en = v_q;

  always_ff @(posedge clk) begin
    rst_q  <= rst;
    rst_q2 <= rst_q;
    v_q    <= in_v;
  end

  always_ff @(posedge clk) begin
    if (rst_q)      a_q <= '0;
    else if (ld_en) a_q <= in_d;
  end

  always_ff @(posedge clk) begin
    if (rst_q2)     b_q <= '0;
    else if (ld_en) b_q <= ~in_d;
  end

  assign a_o = a_q;
  assign b_o = b_q;
endmodule
