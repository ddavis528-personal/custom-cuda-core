// check-cg fixture: compliant. The reset and the valid are flopped first
// (RST-1, CG-5), and the bench sends in_d the cycle after in_v, so the
// flopped valid is the enable. d_q and st_q share one clock gate of 20 flops
// on a named _en enable: st_q's reset is the module's, flopped, which acts
// only in reset cycles, so it does not split the group and leave st_q's four
// flops under CCV_CG_MIN_FLOPS. The LFSR runs free and changes every cycle,
// so it is ungated by measurement (CG-1 and CG-4's exception); rst_q and v_q
// are the module allowance's. tools/check-cg.py --selftest.
module cg_fx_good (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  logic        rst_q, v_q;
  logic [15:0] d_q;
  logic [3:0]  st_q;
  logic [7:0]  lfsr_q;
  wire         ld_en = v_q;

  always_ff @(posedge clk) begin
    rst_q <= rst;
    v_q   <= in_v;
  end

  always_ff @(posedge clk) begin
    if (ld_en) d_q <= in_d;
  end

  always_ff @(posedge clk) begin
    if (rst_q)      st_q <= '0;
    else if (ld_en) st_q <= in_d[15:12];
  end

  always_ff @(posedge clk) begin
    if (rst_q) lfsr_q <= 8'h01;
    else       lfsr_q <= {lfsr_q[6:0], lfsr_q[7] ^ lfsr_q[5] ^ lfsr_q[4] ^ lfsr_q[3]};
  end

  assign out_v = lfsr_q[0] ^ (^st_q);
  assign out_d = d_q ^ {8'h00, lfsr_q};
endmodule
