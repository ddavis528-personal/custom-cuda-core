//===-- ccv_icg.v - integrated clock gate ------------------------*- V -*-===//
//
// Latch-based ICG, the standard structure: the enable is captured while the
// clock is low, so it cannot change during the high phase and therefore cannot
// glitch the gated clock. An AND of a raw enable with the clock would produce
// a runt pulse whenever the enable moved mid-cycle.
//
// Behavioural, and deliberately so -- this stands in for a library cell. At
// synthesis (deferred, §6) it is replaced by the real ICG from whatever
// library is in use, and this file exists to make the transform expressible
// and testable before that point.
//===----------------------------------------------------------------------===//
module ccv_icg (
  input  wire clk,
  input  wire en,
  output wire gclk
);
  reg en_latched;
  always @* if (!clk) en_latched <= en;
  assign gclk = clk & en_latched;
endmodule
