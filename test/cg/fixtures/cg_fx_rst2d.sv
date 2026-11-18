// check-cg fixture: RST-2 across a blackboxed child (cg_fx_good, its own
// unit), balanced: u_kid takes the raw port reset beside p_q at stage
// 1; cg_fx_good flops it once, so both arrive at cycle 1.
// tools/check-cg.py --selftest.
module cg_fx_rst2d (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d,
  output logic [7:0]  p_o
);
  logic       rst_q, rst_q2, v_q;
  logic [7:0] p_q;
  wire        ld_en = v_q;

  always_ff @(posedge clk) begin
    rst_q  <= rst;
    rst_q2 <= rst_q;
    v_q    <= in_v;
  end

  always_ff @(posedge clk) begin
    if (rst_q)      p_q <= '0;
    else if (ld_en) p_q <= in_d[7:0];
  end

  assign p_o = p_q;
  cg_fx_good u_kid (.clk(clk), .rst(rst), .in_v(in_v), .in_d(in_d), .out_v(out_v),
                    .out_d(out_d));
endmodule
