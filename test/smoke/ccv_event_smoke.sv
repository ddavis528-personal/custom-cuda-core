//===-- ccv_event_smoke.sv - Stage 1c exit criteria ---------------------===//
//
// §8's Stage 1c exit criterion, second half:
//
//   "the DPI-C path emits from a trivial SystemVerilog module -- the Stage 1c
//    decision exercised, not merely decided"
//
// This is that trivial module. It exists so the 1c decision is tested at 1c
// rather than at 4c, when a retrofit would cross every block already built.
//
// It emits a plausible instruction lifetime -- decode, dispatch, issue,
// retire -- because a single event would not exercise the parts that actually
// break: instr_uid correlating events across cycles, a mix of load-bearing and
// arbitration-sensitive classes, and non-zero payload fields.
//===----------------------------------------------------------------------===//
`include "ccv_trace.svh"

module ccv_event_smoke;

  longint cycle;
  longint uid;
  int     rc;

  initial begin
    rc = ccv_trace_open("ccv_event_smoke.ccvtrace");
    if (rc == 0) begin
      $display("CCV_EVENT_SMOKE: FAIL -- could not open trace");
      $finish;
    end

    cycle = 0;
    for (int i = 0; i < 4; i++) begin
      uid = 1000 + i;

      // Arbitration-sensitive: the class §1 warns diverges on every tie if the
      // arbiter model is merely plausible rather than faithful. Warp select,
      // ROB allocation (EV_DISPATCH since Q-2) and issue.
      `CCV_EMIT3(cycle + 0, uid, EV_WARP_SELECT, UNIT_OOE, i % 2, 0, 32'h0000000f)
      `CCV_EMIT3(cycle + 1, uid, EV_DISPATCH, UNIT_OOE, i % 2, i, 0)
      `CCV_EMIT3(cycle + 2, uid, EV_ISSUE,    UNIT_OOE, i % 2, 0, i)

      // Load-bearing: the architectural commit.
      `CCV_EMIT3(cycle + 5, uid, EV_RETIRE,   UNIT_OOE, i % 2, i, 32'hffffffff)
      cycle = cycle + 3;
    end

    $display("CCV_EVENT_SMOKE: emitted %0d events", ccv_trace_count());
    ccv_trace_close();
    $display("CCV_EVENT_SMOKE: OK");
    $finish;
  end

endmodule
