// check-cg fixture: compliant. Every register is under a named enable,
// except the LFSR, which runs free and changes every cycle, so it is
// ungated by measurement (CG-1's exception). tools/check-cg.py --selftest.
module cg_fx_good (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  logic        v_q;
  logic [15:0] d_q;
  logic [7:0]  lfsr_q;
  wire         v_chg = in_v ^ v_q;

  always_ff @(posedge clk) begin
    if (rst)        v_q <= 1'b0;
    else if (v_chg) v_q <= in_v;
  end

  always_ff @(posedge clk) begin
    if (in_v) d_q <= in_d;
  end

  always_ff @(posedge clk) begin
    if (rst) lfsr_q <= 8'h01;
    else     lfsr_q <= {lfsr_q[6:0], lfsr_q[7] ^ lfsr_q[5] ^ lfsr_q[4] ^ lfsr_q[3]};
  end

  assign out_v = v_q;
  assign out_d = d_q ^ {8'h00, lfsr_q};
endmodule
