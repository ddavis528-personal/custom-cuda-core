//===-- reference_bkp.sv - a register read back a cycle on, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 513,
//       OI-229 option B)
//
// ooe_rename's u_ren1 shape: p_cy03h is formed from u_r's lanes (l, from
// v_cy01h only); u_h, a register-free head read, reads it back as
// c_cy03h, and u_r takes that into x a cycle on. c_cy01h never reaches l,
// so no cycle closes through u_r's port: declared as a read-back from
// p_cy03h's cone through the crossing u_h.a>y in reference_bkp.feedback.json
// (its assertion bk_seen, its bench control bk-drop).
// tools/check-1d.sh fails if ANY finding is reported here, in
// reference_bkr.sv or in reference_bkh.sv.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_bkp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic v_cy02h,
  output logic z_cy03h
);
  logic p_cy03h;
  logic c_cy03h;
  logic l_cy02h;
  logic x_cy02h;
  reference_bkh u_h (.a(p_cy03h), .y(c_cy03h));
  reference_bkr u_r (.v_cy01h(v_cy02h), .c_cy01h(c_cy03h), .l(l_cy02h), .x(x_cy02h));
  always_ff @(posedge reference_core_clk) begin
    p_cy03h <= l_cy02h;
    z_cy03h <= x_cy02h;
  end
  `CCV_ASSERT(bk_seen, !(p_cy03h && !c_cy03h))
endmodule

`undef CCV_CLK
`undef CCV_RST
