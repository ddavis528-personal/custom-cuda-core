//===-- reference_otpp.sv - a port table held in the parent, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, read through an
//       input port; OA-492 (3), OI-226 (c))
//
// ooe_rob_w and ooe_redir's shape once rob_w instantiates redir (OA-487):
// the parent holds the words in its own register rd_cy04h, written at
// stage 04, and u_r reads them at 03 through its input port, fed directly
// by that register. Declared in reference_otpr.feedback.json with
// "writer": "rd_cy04h". tools/check-1d.sh fails if ANY finding is reported
// here or in reference_otpr.sv.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_otpp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] d_cy03h,
  input  logic       en_cy03h,
  input  logic       pw_cy03h,
  output logic [3:0] o_cy04h
);
  logic [3:0] rd_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (en_cy03h) rd_cy04h <= d_cy03h;
  end
  reference_otpr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy04h(rd_cy04h),
    .pw_cy03h(pw_cy03h), .wr_cy03h(en_cy03h), .o_cy04h(o_cy04h));
  `CCV_ASSERT_KNOWN(en_known, en_cy03h)
endmodule

`undef CCV_CLK
`undef CCV_RST
