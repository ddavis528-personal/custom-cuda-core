//===-- reference_bnp.sv - a parent register read back, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 513,
//       OA 514, OI-230 (5))
//
// ooe_rename's u_ren1nr shape: m_cy04h holds u_r's new names nn (group
// N's, at 04); u_r reads them back as pn_cy01h, a cycle on, into g only,
// never into nn, so no cycle closes through the port: declared as a
// read-back from the parent register m_cy04h alone in
// reference_bnp.feedback.json (its assertion bn_seen, its control bn-drop).
// tools/check-1d.sh fails if ANY finding is reported here or in
// reference_bnr.sv.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_bnp (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic q_cy03h,
  output logic z_cy04h
);
  logic m_cy04h;
  logic nn_cy03h;
  logic g_cy03h;
  reference_bnr u_r (.q_cy01h(q_cy03h), .pn_cy01h(m_cy04h), .nn(nn_cy03h), .g(g_cy03h));
  always_ff @(posedge reference_core_clk) begin
    m_cy04h <= nn_cy03h;
    z_cy04h <= g_cy03h;
  end
  `CCV_ASSERT(bn_seen, !(m_cy04h && !q_cy03h))
endmodule

`undef CCV_CLK
`undef CCV_RST
