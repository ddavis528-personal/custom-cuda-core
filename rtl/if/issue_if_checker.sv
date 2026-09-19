//===-- issue_if_checker.sv - reference interface checker ---------*- SV -*-===//
//
// Spec: docs/interface-checker-convention.md
//
// REFERENCE EXAMPLE. `issue_t` is the convention doc's own worked interface,
// not a proposed one -- the real interface list follows from the Stage 2
// partition, which the strategy doc §2 is explicit has not been decided. This
// exists so the convention's machinery has something real to exercise: the
// mode parameter, the satisfiability covers, the emission path, and every lint
// rule that governs checkers.
//
// It is also the worked example for the thing that costs most. Stage 1a
// finding F-2: NO multi-cycle sequence construct works in any of the three
// tools -- not `##n`, not `sequence`, not `throughout`, not property local
// variables. The convention's §3.2 property list is mostly temporal, so none
// of it can be written as stated. Every property below that would naturally be
// a sequence is built from an explicit tracking register instead.
//
// The consequence, stated once here because it applies to every checker
// written from Stage 2 onward: a checker CARRIES ITS OWN STATE, so it is a
// thing to review rather than a thing to read, and it can itself be wrong.
// That is what the satisfiability covers at the bottom are for.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

module issue_if_checker #(
  parameter int MODE = `CCV_MODE_ASSERT
) (
  input logic   clk,
  input logic   rst,
  input issue_t iss,
  input logic   iss_ready
);

  // -- tracking state, standing in for the sequences the tools cannot parse --

  logic        rst_q;         // registered reset, for the post-reset property
  logic        stalled_q;     // valid was up and not accepted last cycle
  logic [31:0] payload_q;     // shadow copy, for the stability property
  logic [5:0]  tag_q;
  logic [63:0] inflight_q;    // one bit per tag: is that tag outstanding
  logic [6:0]  inflight_n;    // population, for the bound check
  logic [63:0] cyc_q;

  wire accepted = iss.valid && iss_ready;

  always_ff @(posedge clk) begin
    if (rst) begin
      rst_q      <= 1'b1;
      stalled_q  <= 1'b0;
      inflight_q <= '0;
      inflight_n <= '0;
      cyc_q      <= '0;
    end else begin
      rst_q      <= 1'b0;
      stalled_q  <= iss.valid && !iss_ready;
      payload_q  <= iss.payload;
      tag_q      <= iss.tag;
      cyc_q      <= cyc_q + 1;
      if (accepted) begin
        inflight_q[iss.tag] <= 1'b1;
        inflight_n          <= inflight_n + 1;
      end
    end
  end

  // -- generic protocol properties (convention §3.2) ------------------------

  // X on control is prohibited rather than propagated (§6). These are boolean,
  // so they are the one part of §3.2 that survives F-2 unchanged.
  //
  // Both halves, per F-8: under formal an unconstrained input is modelled as
  // possibly-X, so the assert alone fails spuriously. The block on the far side
  // asserts what this assumes.
  `CCV_ASSUME_KNOWN(iss_valid_known_env, iss.valid)
  `CCV_CONTRACT_M(MODE, iss_valid_known, !$isunknown(iss.valid))
  `CCV_CONTRACT_M(MODE, iss_tag_known, !iss.valid || !$isunknown(iss.tag))
  // NOTE `payload` is deliberately absent: §6 prohibits X on CONTROL and
  // propagates it on DATA, where propagation is cheap and reliable.

  // valid is not withdrawn before it is accepted.
  //   wanted:  valid && !ready |=> valid
  //   built:   a registered `stalled_q`, and a boolean property over it
  `CCV_CONTRACT_M(MODE, iss_valid_stable, !stalled_q || iss.valid)

  // Payload and tag are stable while stalled.
  //   wanted:  $stable(payload) throughout the stall
  //   built:   a shadow copy, compared
  `CCV_CONTRACT_M(MODE, iss_payload_stable,
                  !stalled_q || (iss.payload == payload_q))
  `CCV_CONTRACT_M(MODE, iss_tag_stable, !stalled_q || (iss.tag == tag_q))

  // No valid during reset, or in the cycle after it.
  //   wanted:  $past(rst) |-> !valid
  //   built:   a registered rst_q
  `CCV_CONTRACT_M(MODE, iss_no_valid_at_reset, !rst_q || !iss.valid)

  // Tag uniqueness among in-flight transactions.
  //   wanted:  set membership over time
  //   built:   a scoreboard register, one bit per tag
  `CCV_CONTRACT_M(MODE, iss_tag_unique, !accepted || !inflight_q[iss.tag])

  // In-flight count within its bound.
  `CCV_CONTRACT_M(MODE, iss_inflight_bound, inflight_n <= 7'd64)

  // -- satisfiability covers (convention §3.3) -- MANDATORY -----------------
  //
  // Unconditional, never mode-resolved: a guard that switched off in the mode
  // where assumptions are active would be absent exactly when it is needed.
  //
  // These are what stands between a real proof and case 34's -- a contradictory
  // assume set makes every dependent proof vacuously true, silently, with no
  // counterexample and nothing in the output to distinguish it from success.
  `CCV_IF_SAT(iss_valid_reachable, iss.valid)
  `CCV_IF_SAT(iss_accept_reachable, accepted)
  `CCV_IF_SAT(iss_stall_reachable, iss.valid && !iss_ready)

  // -- event emission (convention §5) ---------------------------------------
  //
  // The load-bearing event class is interface-defined by construction, and the
  // checker already sees every transaction. Emitting here rather than per block
  // means every instance of this interface type emits identically, so there is
  // no per-block opportunity to drift from the schema -- which is the failure
  // that would quietly corrupt correlation.
  //
  // Guarded: Icarus has no DPI (F-13), and this same checker must still compile
  // for the X-pass with its properties intact.
  always_ff @(posedge clk) begin
    if (!rst && accepted) begin
      `CCV_IF_EMIT(cyc_q, {58'b0, iss.tag}, EV_DISPATCH, UNIT_SCHEDULER,
                   iss.payload, {26'b0, iss.tag}, 0)
    end
  end

endmodule
