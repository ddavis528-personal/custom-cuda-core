//===-- bad_conn8.sv - lint fixture for calls in a cone, helper sums ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-495,
//       OA-488 (1), OI-226 (a) and (b))
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_fanp's cone is a call whose argument fk_cy04h is a register the
// declaration leaves out; reference_fbnp's is a call whose body reads gk_cy04h,
// left out too: a call is logic, and what it reads is the cone's.
// reference_lcsp is reference_csp.sv's helper sum with l_cy04h, a net past
// the helper output's stage, beside the register: not a self-loop.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_fanp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic fx_cy03h,
  output logic fe_cy02h
);
  logic fm_cy03h;
  logic fm_cy04h;
  logic fk_cy04h;
  logic fvin_cy04h;
  always_ff @(posedge reference_core_clk) begin
    fm_cy03h <= fe_cy02h;
    fm_cy04h <= fm_cy03h;
    fk_cy04h <= fx_cy03h;
  end
  function automatic logic fmix(input logic a, input logic b);
    fmix = a ^ b;
  endfunction
  assign fvin_cy04h = fmix(fm_cy04h, fk_cy04h);
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(fvin_cy04h), .e_cy02h(fe_cy02h));
  `CCV_ASSERT(conn_m_fresh, !(fm_cy04h && fe_cy02h))
endmodule

module reference_fbnp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic gx_cy03h,
  output logic ge_cy02h
);
  logic gm_cy03h;
  logic gm_cy04h;
  logic gk_cy04h;
  logic gvin_cy04h;
  always_ff @(posedge reference_core_clk) begin
    gm_cy03h <= ge_cy02h;
    gm_cy04h <= gm_cy03h;
    gk_cy04h <= gx_cy03h;
  end
  function automatic logic gpeek(input logic a);
    gpeek = a ^ gk_cy04h;
  endfunction
  assign gvin_cy04h = gpeek(gm_cy04h);
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(gvin_cy04h), .e_cy02h(ge_cy02h));
  `CCV_ASSERT(conn_m_fresh, !(gm_cy04h && ge_cy02h))
endmodule

module reference_lcsp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [1:0] lf_cy03h,
  input  logic       l_cy04h,
  output logic [3:0] lz_cy04h
);
  logic [3:0] lq_cy04h;
  logic [3:0] lop_cy04h;
  logic [3:0] lqn_cy03h;
  assign lop_cy04h = {lf_cy03h, l_cy04h, lq_cy04h[0]};
  reference_csh u_h (.a(lop_cy04h), .y(lqn_cy03h), .p());
  always_ff @(posedge reference_core_clk) lq_cy04h <= lqn_cy03h;
  assign lz_cy04h = lq_cy04h;
endmodule

`undef CCV_CLK
`undef CCV_RST
