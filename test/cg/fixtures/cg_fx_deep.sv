// check-cg fixture: CG-2. deep_en is an add and a 16-bit compare of the
// module's own flops, far more than CCV_NGD_CG_EN into the clock gate.
// tools/check-cg.py --selftest.
module cg_fx_deep (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  logic        rst_q, v_q;
  logic [15:0] acc_q, b_q, d_q;
  wire         acc_en  = v_q;
  wire         deep_en = (acc_q + b_q) == 16'hbeef;

  always_ff @(posedge clk) begin
    rst_q <= rst;
    v_q   <= in_v;
  end

  always_ff @(posedge clk) begin
    if (rst_q)       acc_q <= '0;
    else if (acc_en) acc_q <= acc_q + in_d;
  end

  always_ff @(posedge clk) begin
    if (acc_en) b_q <= in_d;
  end

  always_ff @(posedge clk) begin
    if (deep_en) d_q <= in_d;
  end

  assign out_v = ^acc_q;
  assign out_d = d_q ^ b_q;
endmodule
