//===-- bad_conn6.sv - lint fixture: a cone crossing traced to an unlisted register ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-498)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_okp's cone names the crossing but leaves out oq_cy04h, the
// register its input traces back to; reference_pkp names u_x's output
// directly, but reference_xc has no timing unit, so its tags are not
// verified (OA-499).
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_okp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic ox_cy03h,
  input  logic ob_cy01h,
  output logic oe_cy02h
);
  logic om_cy03h;
  logic om_cy04h;
  logic oq_cy04h;
  logic oxy_cy04h;
  logic ovin_cy04h;
  assign ovin_cy04h = om_cy04h ^ oxy_cy04h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(ovin_cy04h), .e_cy02h(oe_cy02h));
  reference_xc u_x (.reference_core_clk, .ref_rst_r00h, .a_cy02h(oq_cy04h), .b_cy01h(ob_cy01h),
    .y_cy02h(oxy_cy04h));
  always_ff @(posedge reference_core_clk) begin
    om_cy03h <= oe_cy02h;
    om_cy04h <= om_cy03h;
    oq_cy04h <= ox_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(om_cy04h && oe_cy02h))
endmodule

module reference_pkp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic px_cy03h,
  input  logic pb_cy01h,
  output logic pe_cy02h
);
  logic pm_cy03h;
  logic pm_cy04h;
  logic pq_cy04h;
  logic pxy_cy04h;
  logic pvin_cy04h;
  assign pvin_cy04h = pm_cy04h ^ pxy_cy04h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(pvin_cy04h), .e_cy02h(pe_cy02h));
  reference_xc u_x (.reference_core_clk, .ref_rst_r00h, .a_cy02h(pq_cy04h), .b_cy01h(pb_cy01h),
    .y_cy02h(pxy_cy04h));
  always_ff @(posedge reference_core_clk) begin
    pm_cy03h <= pe_cy02h;
    pm_cy04h <= pm_cy03h;
    pq_cy04h <= px_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(pm_cy04h && pe_cy02h))
endmodule

`undef CCV_CLK
`undef CCV_RST
