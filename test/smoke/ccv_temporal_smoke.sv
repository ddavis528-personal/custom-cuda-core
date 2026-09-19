//===-- ccv_temporal_smoke.sv - tier-1b macro regression ----------------===//
//
// The bounded temporal macros must be able to FAIL. A stability property that
// cannot fire is worse than no property, because it reads as coverage.
//
// This module violates one property per build, selected by CCV_TSEL, and the
// producer is deliberately non-compliant: it changes a payload while stalled,
// changes it inside a hold window, and raises a request that is never acked.
//
// ONE PROPERTY PER BUILD, and the reason is a tool behaviour worth knowing:
// under Verilator an assertion failure calls $stop and ABORTS THE RUN, so the
// first property to fire is the only one observed. A multi-property negative
// test there silently measures one property and reports on three. Icarus keeps
// going and reports all of them.
//
// Spec: docs/rtl-coding-style.md, tier-1b section
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"

// Test module: `clk`/`rst` formals, driven by the common testbench.
`define CCV_CLK clk
`define CCV_RST rst

module dut (
  input  logic clk,
  input  logic rst,
  input  logic a,
  input  logic b,
  output logic o
);

  logic [7:0] payload;
  logic       stall;
  logic       req;
  logic       ack;

  always_ff @(posedge clk) begin
    if (rst) begin
      payload <= 8'd0;
      stall   <= 1'b0;
      req     <= 1'b0;
      ack     <= 1'b0;
    end else begin
      stall   <= 1'b1;             // held, so the "while" window is open
      payload <= payload + 8'd1;   // ...and the payload keeps moving
      req     <= 1'b1;             // raised and never answered
      ack     <= 1'b0;
    end
  end

  assign o = |payload;

`ifdef CCV_TSEL_WHILE
  `CCV_ASSERT_STABLE_WHILE(t_stable_while, stall, payload)
`endif
`ifdef CCV_TSEL_FOR
  `CCV_ASSERT_STABLE_FOR(t_stable_for, req && !ack, payload, 3)
`endif
`ifdef CCV_TSEL_RESP
  `CCV_ASSERT_RESPONSE_WITHIN(t_resp, req, ack, 4)
`endif

endmodule

`undef CCV_CLK
`undef CCV_RST
