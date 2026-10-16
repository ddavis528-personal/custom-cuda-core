// check-cg fixture: CG-3. hit_q is enabled by every valid and almost never
// changes, so its DCGE is near zero whenever anything arrives.
// tools/check-cg.py --selftest.
module cg_fx_dcge (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  logic        hit_q;
  logic [15:0] d_q;

  always_ff @(posedge clk) begin
    if (rst)       hit_q <= 1'b0;
    else if (in_v) hit_q <= (in_d == 16'hffff);
  end

  always_ff @(posedge clk) begin
    if (in_v) d_q <= in_d;
  end

  assign out_v = hit_q;
  assign out_d = d_q;
endmodule
