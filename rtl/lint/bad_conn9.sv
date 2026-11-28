//===-- bad_conn9.sv - lint fixture for a reach through a registered child ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OI-227 (e))
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_gp.sv's shape with a register in the grandchild: reference_rgg
// registers its output, so u_c's input does not reach y_cy01h
// combinationally through it, and reference_rgp's declaration of the loop
// is refused.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_rgg (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy01h,
  output logic y_cy02h
);
  always_ff @(posedge reference_core_clk) y_cy02h <= !a_cy01h;
endmodule

module reference_rgc (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy01h,
  output logic y_cy02h,
  output logic z_cy02h
);
  reference_rgg u_g (.reference_core_clk, .ref_rst_r00h, .a_cy01h(a_cy01h), .y_cy02h(y_cy02h));
  always_ff @(posedge reference_core_clk) z_cy02h <= a_cy01h;
endmodule

module reference_rgp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  output logic rz_cy02h
);
  logic rm_cy02h;
  logic ry_cy02h;
  reference_rgc u_c (.reference_core_clk, .ref_rst_r00h, .a_cy01h(rm_cy02h), .y_cy02h(ry_cy02h),
    .z_cy02h(rz_cy02h));
  always_ff @(posedge reference_core_clk) rm_cy02h <= ry_cy02h;
  `CCV_ASSERT(conn_g_fresh, !(rm_cy02h && ry_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
