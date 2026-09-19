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

  // Result-assignment style rather than `return`: Yosys's native front end
  // rejects `return` in a function body (Stage 1a).
  function automatic bit enabled();
`ifdef FORMAL
    // Constant, never a free variable. See the note above.
    enabled = 1'b1;
`else
    int off;
    enabled = 1'b1;
    if ($value$plusargs("ccv_assert_off=%d", off))
      enabled = (off == 0);
`endif
  endfunction

endpackage
