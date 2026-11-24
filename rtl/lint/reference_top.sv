//===-- reference_top.sv - a declared cross-module loop, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 481-483,
//       TI-554..556; MI-35)
//
// The MIU L0 refill's shape (MI-35): a reader (reference_rd) looks an entry
// up at its stage 02 and flops a miss at 03; a writer (reference_wr) takes
// the miss and writes the entry 3 stages on, at 06, and the parent feeds
// that back to the reader's stage-02 input: 4 stages ahead, a back edge
// across the boundary, declared in reference_top.feedback.json with its
// stale-read assertion. Every other connection keeps the child's latency.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_top (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy01h,
  input  logic x_cy03h,
  output logic ms_cy03h,
  output logic l0_cy06h
);
  reference_rd u_rd (
    .reference_core_clk, .ref_rst_r00h, .a_cy01h(a_cy01h), .l0_cy02h(l0_cy06h),
    .ms_cy03h(ms_cy03h));
  reference_wr u_wr (
    .reference_core_clk, .ref_rst_r00h, .ms_cy03h(ms_cy03h), .l0_cy06h(l0_cy06h));
  `CCV_ASSERT(conn_l0_fresh, !(ms_cy03h && l0_cy06h))
endmodule

`undef CCV_CLK
`undef CCV_RST
