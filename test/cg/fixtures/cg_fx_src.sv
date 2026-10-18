// check-cg fixture: where a clock enable and the reset may come from
// (CG-5, RST-1; Daniel, 2026-10-18). Structural only: synthesised, never
// replayed. tools/check-cg.py --selftest.
//   a_q    a gate enabled straight from an input, with a2_q   CG-5
//   b_q    a gate enabled from the module's own flop           passes
//   c_q    the reset port straight into the flops' reset      RST-1
//   d_q    the reset port in a gate's enable                  CG-5, RST-1
//   u_icg  an ICG enabled straight from an input              CG-5
//   rst_o  the reset port straight out                        RST-1
module cg_fx_src (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        gclk,
  output logic        rst_o,
  output logic [15:0] out_d
);
  logic        rst_q, v_q;
  logic [15:0] a_q, a2_q, b_q, c_q, d_q;
  wire         a_en = in_v;
  wire         b_en = v_q;
  wire         d_en = v_q | rst;

  always_ff @(posedge clk) begin
    rst_q <= rst;
    v_q   <= in_v;
  end

  always_ff @(posedge clk) begin
    if (a_en) begin
      a_q  <= in_d;
      a2_q <= in_d + 16'd3;
    end
  end

  always_ff @(posedge clk) begin
    if (b_en) b_q <= ~in_d;
  end

  always_ff @(posedge clk) begin
    if (rst)       c_q <= '0;
    else if (b_en) c_q <= in_d ^ 16'h5a5a;
  end

  always_ff @(posedge clk) begin
    if (d_en) d_q <= rst_q ? '0 : in_d + 1'b1;
  end

  ccv_common_ctech_icg u_icg (.clk(clk), .en(in_v), .te(1'b0), .gclk(gclk));

  assign rst_o = rst;
  assign out_d = a_q ^ a2_q ^ b_q ^ c_q ^ d_q;
endmodule
