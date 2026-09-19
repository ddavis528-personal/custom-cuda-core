//===-- ccv_assert_smoke.sv - Stage 1b exit criteria --------------------===//
//
// §8's exit criterion for Stage 1b: "primitive library compiles in all three
// tools; a smoke property demonstrably fires, and is demonstrably silenced at
// runtime."
//
// Driven by spike/tb/tb_sim.sv, so it sees the same fixed stimulus every
// Stage 1a case does: rst high for cycles 0-1, `a` high on cycle 3 only, `b`
// low always.
//
// Note the deliberate asymmetry below. The firing property proves the library
// checks; the passing properties prove it does not simply fire at everything,
// which a macro library with a botched polarity would also do and which a
// "does it fire" test alone would call a pass.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"

// The role-swap pattern from ccv_assert.svh, exercised rather than only
// documented. Black-boxing a neighbour flips its guarantees from obligations
// into givens; nothing else about the property changes.
`ifdef CCV_BLACKBOX_NEIGHBOUR
  `define NEIGHBOUR_OUT assume
`else
  `define NEIGHBOUR_OUT assert
`endif

module dut (
  input  logic clk,
  input  logic rst,
  input  logic a,
  input  logic b,
  output logic o
);

  logic a_q;
  always_ff @(posedge clk) begin
    if (rst) a_q <= 1'b0;
    else     a_q <= a;
  end

  // §6's reset line, in miniature: the valid bit is reset, the payload is not.
  logic [3:0] payload;
  logic       payload_v;
  logic       payload_rd;
  always_ff @(posedge clk) begin
    if (rst) payload_v <= 1'b0;
    else if (a) begin
      payload   <= {3'b0, b};   // un-reset payload, written under a valid
      payload_v <= 1'b1;
    end
  end
  assign payload_rd = payload_v;   // never read before written, by construction

  assign o = a & b;

  // (1) MUST FIRE. `a` is high at cycle 3 with `b` low.
  `CCV_ASSERT(smoke_fires, !(a && !b))

  // (2) MUST NOT FIRE. Holds under the fixed stimulus.
  `CCV_ASSERT(smoke_holds, !(o && !a))

  // (3) Role swappable at the call site.
  `CCV_CONTRACT(`NEIGHBOUR_OUT, neighbour_contract, !(b && !a))

  // (4) Environment constraint. Inert in simulation; real work under formal.
  `CCV_ASSUME(smoke_env, 1'b1)

  // (5) Reachability. Meaningful under `sby -m cover`; inert in simulation on
  //     this stack, which the Stage 1a matrix records rather than hides.
  `CCV_COVER(smoke_reach, a)

  // (6) §6's control-is-known rule, with its `assume` half. Under formal an
  //     unconstrained input is modelled as possibly-X, so the assert alone
  //     fails spuriously; the neighbour's guarantee is what discharges it
  //     (finding F-8). The rule biting on genuinely-X control is spike case
  //     26's job.
  `CCV_ASSUME_KNOWN(smoke_env_known, a)
  `CCV_ASSERT_KNOWN(smoke_known, o)

  // (6b) §6's un-reset-payload invariant, stated structurally over the valid
  //      bit rather than over the payload's value -- which is the only way it
  //      says anything under formal. `payload` is deliberately never reset.
  `CCV_ASSERT_READ_VALID(smoke_read_valid, payload_rd, payload_v)

  // (7) Temporal tier. Compiled away under Icarus by design, which is why the
  //     expected firing count differs per tool in tools/check-1b.sh.
  `CCV_ASSERT_T(smoke_past, !(`CCV_PAST(a) && !a_q))

endmodule
