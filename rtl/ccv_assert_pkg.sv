//===-- ccv_assert_pkg.sv - assertion runtime control -----------*- SV -*-===//
//
// §7 wants a runtime on/off knob for assertions that needs no recompile, and
// is explicit that compiling properties out with `ifdef is NOT an acceptable
// way to get one: formal and simulation must read the same property set, or
// the single-source guarantee dies.
//
// §7 names $assertoff/$asserton/$assertkill as the mechanism. The Stage 1a
// spike found they do not exist on this toolchain (docs/stage1a-findings.md
// F-3): Verilator reports "Unsupported or unknown PLI call", and Icarus parses
// them and then has no runtime definition. So this package is the substitute.
//
// The knob is a plusarg, read through a function rather than held in a package
// variable, because Icarus rejects an assignment to a package variable from a
// testbench and the variable form is therefore not portable:
//
//     <sim> +ccv_assert_off=1     assertions elaborated, but cannot fire
//
// THE TRAP, and the reason for the `ifdef below. Under formal the guard must
// be a CONSTANT. If it were a free variable the solver would simply choose 0,
// every property in the design would pass vacuously, and the run would look
// green with nothing about it looking wrong. spike/cases/29_enable_gate.sv is
// the standing regression against exactly that, and it belongs in the suite
// permanently.
//
//===----------------------------------------------------------------------===//
package ccv_assert_pkg;

  // Under Verilator each knob is read once and kept: the plusargs are fixed
  // before the first evaluation, and reading them on every check was a third
  // of the skeleton's run time (AR-24). Icarus keeps the function form, for
  // the reason above; the answer is the same either way.
`ifdef VERILATOR
  bit en_known = 1'b0, en_val, tr_known = 1'b0, tr_val, eq_known = 1'b0, eq_val;
`endif

  // Result-assignment style rather than `return`: Yosys's native front end
  // rejects `return` in a function body (Stage 1a).
  function automatic bit enabled();
`ifdef FORMAL
    // Constant, never a free variable. See the note above.
    enabled = 1'b1;
`elsif VERILATOR
    int off;
    if (!en_known) begin
      en_val = 1'b1;
      if ($value$plusargs("ccv_assert_off=%d", off))
        en_val = (off == 0);
      en_known = 1'b1;
    end
    enabled = en_val;
`else
    int off;
    enabled = 1'b1;
    if ($value$plusargs("ccv_assert_off=%d", off))
      enabled = (off == 0);
`endif
  endfunction

  // Event emission has its own switch, separate from assertion firing
  // (interface checker convention §6). A correlation run wants events on and
  // protocol checking on; a throughput regression wants both off; a bring-up
  // run often wants checking on and events off, because the trace is the
  // expensive half. One knob could not express that.
  //
  //     <sim> +ccv_trace_off=1      checkers still check, nothing is emitted
  //
  // Always 0 under formal: there is no DPI in that flow and nothing to emit,
  // so the function folds away rather than becoming a solver input.
  function automatic bit trace_enabled();
`ifdef FORMAL
    trace_enabled = 1'b0;
`elsif VERILATOR
    int off;
    if (!tr_known) begin
      tr_val = 1'b1;
      if ($value$plusargs("ccv_trace_off=%d", off))
        tr_val = (off == 0);
      tr_known = 1'b1;
    end
    trace_enabled = tr_val;
`else
    int off;
    trace_enabled = 1'b1;
    if ($value$plusargs("ccv_trace_off=%d", off))
      trace_enabled = (off == 0);
`endif
  endfunction

  // End-of-test quiescence (the checkers' `quiesced_at_end`): only a run that
  // DRAINED may be judged by it -- a run cut off mid-traffic has messages in
  // flight by design. So it is asked for, per run:
  //
  //     <sim> +ccv_eot_quiesce      nothing may be outstanding at the end
  //
  // Never under formal: there is no end of test there, and the proofs state
  // what quiescence stands in for (tools/check-formal.sh).
  function automatic bit eot_quiesce();
`ifdef FORMAL
    eot_quiesce = 1'b0;
`elsif VERILATOR
    if (!eq_known) begin
      eq_val = $test$plusargs("ccv_eot_quiesce");
      eq_known = 1'b1;
    end
    eot_quiesce = eq_val;
`else
    eot_quiesce = $test$plusargs("ccv_eot_quiesce");
`endif
  endfunction

endpackage
