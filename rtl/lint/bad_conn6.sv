//===-- bad_conn6.sv - lint fixture: a cone missing a sibling output ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OI-218)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_okp's cone leaves out u_k.y_cy04h, which reaches the input.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_okp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic ox_cy03h,
  output logic oe_cy02h
);
  logic om_cy03h;
  logic om_cy04h;
  logic ok_cy04h;
  logic ovin_cy04h;
  assign ovin_cy04h = om_cy04h ^ ok_cy04h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(ovin_cy04h), .e_cy02h(oe_cy02h));
  reference_kc u_k (.reference_core_clk, .ref_rst_r00h, .x_cy03h(ox_cy03h), .y_cy04h(ok_cy04h));
  always_ff @(posedge reference_core_clk) begin
    om_cy03h <= oe_cy02h;
    om_cy04h <= om_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(om_cy04h && oe_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
