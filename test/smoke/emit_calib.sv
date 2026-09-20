//===-- emit_calib.sv - emit-path cycle calibration ---------------------===//
//
// Spec: docs/rtl-coding-style.md, event emission
// Reusable: calibration fixture; clk/rst are generic formals.
//
// WHY A TEST OF THE EMIT PATH IS NOT ENOUGH.
//
// A test catches a BROKEN emit path -- no events, malformed records, a failed
// open. It does not catch the failure that matters, which is SYSTEMATIC: a DPI
// call placed a cycle off relative to the clock edge, or sampling before
// rather than after the non-blocking update. Such a path emits a complete,
// well-formed, self-consistent stream that is uniformly wrong by one cycle.
//
// At §5 correlation that does not look like an instrumentation fault. It looks
// like a consistent timing divergence in the design under test -- exactly the
// signature of a real finding, and it would be chased as one, through the
// design, for as long as it took to doubt the instrument.
//
// So the emit path is CALIBRATED, not merely exercised: against a block whose
// event timing is derivable on paper, asserting the emitted cycle numbers
// match exactly.
//
// THE REFERENCE. A three-deep fixed-latency pipeline. `go` is asserted for one
// cycle; the tag walks the stages; each stage emits on the cycle it is
// reached. With the cycle counter incrementing on the same edge, the correct
// emitted cycles for a launch observed at cycle C are C+1, C+2, C+3 -- one per
// stage, no gaps, no repeats. Any constant offset in the emit path shifts all
// three together, which is precisely the signature that would otherwise be
// read as a design divergence.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

module emit_calib (
  input  logic clk,
  input  logic rst,
  input  logic go,
  output logic done
);

  logic [63:0] cyc;
  logic        s1, s2, s3;

  always_ff @(posedge clk) begin
    if (rst) begin
      cyc <= 64'd0;
      s1  <= 1'b0;
      s2  <= 1'b0;
      s3  <= 1'b0;
    end else begin
      cyc <= cyc + 64'd1;
      s1  <= go;
      s2  <= s1;
      s3  <= s2;
    end
  end

  assign done = s3;

  // One event per stage, on the cycle that stage is reached. `cyc` is read in
  // the same always_ff, so it holds the pre-increment value -- the cycle being
  // entered, which is what an event is pinned to.
  always_ff @(posedge clk) begin
    if (!rst) begin
      if (s1) `CCV_IF_EMIT(cyc, 64'd7000, EV_DECODE,   UNIT_FRONTEND,  1, 0, 0)
      if (s2) `CCV_IF_EMIT(cyc, 64'd7000, EV_DISPATCH, UNIT_SCHEDULER, 2, 0, 0)
      if (s3) `CCV_IF_EMIT(cyc, 64'd7000, EV_RETIRE,   UNIT_SCHEDULER, 3, 0, 0)
    end
  end

endmodule
