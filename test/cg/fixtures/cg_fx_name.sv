// check-cg fixture: a small module whose enable is not named _en. Its 4
// flops are within the module's allowance as flops (CG-4), but a name is
// never auto-waived (CG-1). tools/check-cg.py --selftest.
module cg_fx_name (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  logic [3:0] n_q;
  wire        go = in_v;

  always_ff @(posedge clk) begin
    if (go) n_q <= in_d[3:0];
  end

  assign out_v = ^n_q;
  assign out_d = {12'h000, n_q};
endmodule
