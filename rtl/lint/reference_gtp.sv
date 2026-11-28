//===-- reference_gtp.sv - a register-free child's port table, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, read through an
//       input port; OA-492 (3), OI-226 (c), OI-230 (f) and (g), OA 514)
//
// ooe_decrx and its clockless u_keep's shape: the parent holds the row in
// its register rd_cy04h; u_r, register-free, reads it at 03 through its
// input port. u_r has no clock to hold an assertion, so the table's,
// hd_read_not_written, is here, where the writer is, and names the table
// (rd_cy04h); it is a `CCV_ASSERT_T, as any assertion macro may be.
// Declared in reference_gtr.feedback.json (control tport-dup).
// tools/check-1d.sh fails if ANY finding is reported here or in
// reference_gtr.sv.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_gtp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] d_cy03h,
  input  logic       en_cy03h,
  input  logic       pw_cy03h,
  output logic [3:0] o_cy04h
);
  logic [3:0] rd_cy04h;
  logic [3:0] h_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (en_cy03h) rd_cy04h <= d_cy03h;
  end
  reference_gtr u_r (.rd_cy04h(rd_cy04h), .pw_cy03h(pw_cy03h), .o_cy03h(h_cy03h));
  always_ff @(posedge reference_core_clk) o_cy04h <= h_cy03h;
  `CCV_ASSERT_KNOWN(en_known, en_cy03h)
  `CCV_ASSERT_T(hd_read_not_written, !(pw_cy03h && en_cy03h && rd_cy04h != d_cy03h))
endmodule

`undef CCV_CLK
`undef CCV_RST
