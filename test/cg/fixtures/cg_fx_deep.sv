// check-cg fixture: CG-2. deep_en is an add and a 16-bit compare, far more
// than CCV_NGD_CG_EN into the clock gate. tools/check-cg.py --selftest.
module cg_fx_deep (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  logic [15:0] acc_q, d_q;
  wire         deep_en = (acc_q + in_d) == 16'hbeef;

  always_ff @(posedge clk) begin
    if (rst)       acc_q <= '0;
    else if (in_v) acc_q <= acc_q + in_d;
  end

  always_ff @(posedge clk) begin
    if (deep_en) d_q <= in_d;
  end

  assign out_v = ^acc_q;
  assign out_d = d_q;
endmodule
