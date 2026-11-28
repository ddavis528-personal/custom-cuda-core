//===-- reference_csp.sv - a helper sum in a self-loop, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-488 (1),
//       OI-226 (b))
//
// ooe_rename's u_fg shape (ccv_common_csa): u_h, a register-free helper,
// sums op_cy04h, which concatenates the register q_cy04h with f_cy03h and
// t_cy03h, nets at the helper output's own stage (03); its output feeds
// only q_cy04h's next value. A deficit of 1 through a helper, exempt as
// OA-488 (1)'s self-loop. u_h's second output, p_cy03h, is read by
// nothing: it reaches nothing (OI-219).
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_csp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [1:0] f_cy03h,
  input  logic       t_cy03h,
  output logic [3:0] z_cy04h
);
  logic [3:0] q_cy04h;
  logic [3:0] op_cy04h;
  logic [3:0] qn_cy03h;
  logic [3:0] p_cy03h;
  assign op_cy04h = {f_cy03h, t_cy03h, q_cy04h[0]};
  reference_csh u_h (.a(op_cy04h), .y(qn_cy03h), .p(p_cy03h));
  always_ff @(posedge reference_core_clk) q_cy04h <= qn_cy03h;
  assign z_cy04h = q_cy04h;
endmodule

`undef CCV_CLK
`undef CCV_RST
