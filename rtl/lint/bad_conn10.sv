//===-- bad_conn10.sv - lint fixture for a read-back that closes a loop ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 513)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_bkp.sv's shape with the reader's lane l reading c_cy01h too:
// the read-back closes through u_r's port into kp_cy03h's next value, so
// reference_ckp's read-back declaration is refused.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_ckr (
  input  logic v_cy01h,
  input  logic c_cy01h,
  output logic l,
  output logic x
);
  assign l = v_cy01h | c_cy01h;
  assign x = v_cy01h & c_cy01h;
endmodule

module reference_ckp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic kv_cy02h,
  output logic kz_cy03h
);
  logic kp_cy03h;
  logic kc_cy03h;
  logic kl_cy02h;
  logic kx_cy02h;
  reference_bkh u_h (.a(kp_cy03h), .y(kc_cy03h));
  reference_ckr u_r (.v_cy01h(kv_cy02h), .c_cy01h(kc_cy03h), .l(kl_cy02h), .x(kx_cy02h));
  always_ff @(posedge reference_core_clk) begin
    kp_cy03h <= kl_cy02h;
    kz_cy03h <= kx_cy02h;
  end
  `CCV_ASSERT(bk_seen, !(kp_cy03h && !kc_cy03h))
endmodule

`undef CCV_CLK
`undef CCV_RST
