// check-cg fixture: CG-1. d_q is written every cycle and is idle when its
// input is, so measurement does not excuse it; e_q's enable is an
// expression, not a named signal. tools/check-cg.py --selftest.
module cg_fx_form (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  logic [15:0] d_q, e_q;

  always_ff @(posedge clk) begin
    if (rst) d_q <= '0;
    else     d_q <= in_d;
  end

  always_ff @(posedge clk) begin
    if (in_v && in_d[0]) e_q <= in_d;
  end

  assign out_v = ^e_q;
  assign out_d = d_q;
endmodule
