// check-cg fixture: a block whose 2% must hold what a lead waiver
// took in its modules (DA's ruling on RI-15; RI-17). cg_fx_form's d_q, 16
// flops written every cycle, is cleared in its module by a CG-1 waiver marked
// "lead": true, and still counts here: 128 + 48 = 176 flops, 2% is 3.5, used 16 or
// more. Unmarked, the waiver is not charged and the block holds.
// tools/check-cg.py --selftest.
module cg_fx_blk_wv (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  wire        v0, v1;
  wire [15:0] d0, d1;
  cg_fx_wide u_w0 (.clk, .rst, .in_v, .in_d, .out_v(v0), .out_d(d0));
  cg_fx_form u_f0 (.clk, .rst, .in_v, .in_d, .out_v(v1), .out_d(d1));
  assign out_v = v0 ^ v1;
  assign out_d = d0 ^ d1;
endmodule
