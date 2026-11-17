// check-ngd's selftest of the block array-efficiency metric (Daniel,
// 2026-11-17): a block of two sram_fx, each an 8 KiB SRAM and a 1 KiB
// register file with byte enables, so the block's line counts four macros
// at their units' parameters, every instance path once.
module ngd_fx_blk_mac (
  input  logic        clk,
  input  logic        rst,
  input  logic        a_v,
  input  logic [15:0] a_d,
  output logic        a_out_v,
  output logic [15:0] a_out_d,
  input  logic        b_v,
  input  logic [15:0] b_d,
  output logic        b_out_v,
  output logic [15:0] b_out_d
);
  sram_fx u_a (.clk, .rst, .in_v(a_v), .in_d(a_d), .out_v(a_out_v), .out_d(a_out_d));
  sram_fx u_b (.clk, .rst, .in_v(b_v), .in_d(b_d), .out_v(b_out_v), .out_d(b_out_d));
endmodule
