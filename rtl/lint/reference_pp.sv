//===-- reference_pp.sv - a loop through parent registers, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 481-490,
//       OI-207)
//
// u_c's output (stage 02) feeds two parent registers, m_cy03h then
// m_cy04h, and m_cy04h feeds u_c's stage-01 input: a back edge closed by
// the parent's registers (OI-207), declared in reference_pp.feedback.json
// with each hop named, its stale-read assertion conn_m_fresh and the bench
// control that breaks it, conn-m-dup. And u_h, a register-free helper,
// reads q_cy03h and feeds only q_cy03h's next value: a deficit of 1
// through a helper, exempt (OA-488 (1)).
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_pp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       x_cy03h,
  output logic       e_cy02h,
  output logic [3:0] q_cy03h,
  output logic [3:0] z_cy03h
);
  logic m_cy03h;
  logic m_cy04h;
  reference_pc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(m_cy04h), .e_cy02h(e_cy02h));
  always_ff @(posedge reference_core_clk) begin
    m_cy03h <= e_cy02h;
    m_cy04h <= m_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(m_cy04h && e_cy02h))
  // A register-free helper in a same-stage self-loop: its output feeds only
  // the register its input reads.
  logic [3:0] qn_cy02h;
  reference_ph u_h (.a(q_cy03h), .y(qn_cy02h));
  always_ff @(posedge reference_core_clk) q_cy03h <= qn_cy02h;
  always_ff @(posedge reference_core_clk) z_cy03h <= q_cy03h;
endmodule

`undef CCV_CLK
`undef CCV_RST
