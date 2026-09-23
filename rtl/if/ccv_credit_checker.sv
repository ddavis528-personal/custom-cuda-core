//===-- ccv_credit_checker.sv - the one interface checker ----------------===//
//
// Spec: docs/interface-checker-convention.md, plus the block-level grill-me's
//       interface conventions (2026-09-23)
// Reusable: one instance sits at every one of the 40 channel boundaries and
//           binds to each block's own clock, so clk/rst_n are generic formals.
//
// ONE parameterized implementation, instantiated per boundary, rather than
// per-interface assertions. Stage 1 found multi-cycle SVA unavailable on this
// toolchain (F-2), so every temporal property here is an explicit tracking
// register -- which makes a single shared implementation worth far more than
// it would be if properties were declarative. Written once, reviewed once,
// wrong in one place at most.
//
// Generic over PAYLOAD WIDTH rather than payload type. The checker never
// interprets the payload; it checks the protocol around it. That is what lets
// one module serve channels carrying an 8-bit opcode and channels carrying a
// 1024-bit GPR row.
//
// THE FOUR NUMBERS ARE ONE NUMBER. Credit depth, rescue depth, timeout N and
// drain wait all derive from the interface's flop-to-flop round trip. They are
// parameters here so a non-abutting interface moves all four together, which
// is the correct failure mode.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

`define CCV_CLK clk
`define CCV_RST !rst_n

module ccv_credit_checker #(
  parameter int MODE       = `CCV_MODE_ASSERT,
  parameter int PAYLOAD_W  = 32,
  parameter int ROUND_TRIP = 2,
  parameter int DEPTH      = ROUND_TRIP,
  parameter int TIMEOUT_N  = 64,
  parameter int CHANNEL    = 0           // CCV_CH_* from the generated header
) (
  input logic                  clk,
  input logic                  rst_n,
  input logic                  ch_valid,
  input logic [PAYLOAD_W-1:0]  ch_payload,
  input logic                  ch_credit,
  input logic                  ch_stall
);

  localparam int CW = $clog2(DEPTH + 2);
  localparam int TW = $clog2(TIMEOUT_N + 2);

  logic [CW-1:0] outstanding;
  logic [TW-1:0] oldest_age;
  logic          valid_q;
  logic          stall_q;

  wire sent     = ch_valid;
  wire returned = ch_credit;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      outstanding <= '0;
      oldest_age  <= '0;
      valid_q     <= 1'b0;
      stall_q     <= 1'b0;
    end else begin
      valid_q <= ch_valid;
      stall_q <= ch_stall;

      // A credit is consumed when valid asserts, not when the payload lands.
      if (sent && !returned)      outstanding <= outstanding + 1'b1;
      else if (!sent && returned) outstanding <= outstanding - 1'b1;

      if (outstanding == '0)             oldest_age <= '0;
      else if (returned)                 oldest_age <= '0;
      else if (oldest_age != {TW{1'b1}}) oldest_age <= oldest_age + 1'b1;
    end
  end

  // -- X on control is prohibited, not propagated (§6) ---------------------
  // The assume half is required under formal: an unconstrained input is
  // modelled as possibly-X there, so the assert alone fails spuriously (F-8).
  `CCV_ASSUME_KNOWN(env_valid_known,  ch_valid)
  `CCV_ASSUME_KNOWN(env_credit_known, ch_credit)
  `CCV_ASSUME_KNOWN(env_stall_known,  ch_stall)
  `CCV_CONTRACT_M(MODE, valid_known,  !$isunknown(ch_valid))
  `CCV_CONTRACT_M(MODE, credit_known, !$isunknown(ch_credit))
  // NOTE payload is absent by design: §6 prohibits X on CONTROL and
  // propagates it on DATA, where propagation is cheap and reliable.

  // -- the credit protocol -------------------------------------------------

  // The property the whole scheme exists to guarantee, and the one whose
  // violation overruns the receiver silently.
  `CCV_CONTRACT_M(MODE, no_overrun, outstanding <= DEPTH[CW-1:0])

  // A credit returned for something never sent: a receiver counting wrong,
  // which surfaces later as a sender that never throttles.
  `CCV_CONTRACT_M(MODE, no_phantom_credit,
                  !(returned && (outstanding == '0) && !sent))

  // No message may be sent the cycle after a stall is received. That
  // guarantee is what makes the in-flight window a fixed count rather than a
  // handshake, and rescue depth, drain wait and sleep entry are all counted
  // against it.
  `CCV_CONTRACT_M(MODE, stall_honoured, !(stall_q && ch_valid))

  // -- valid one cycle early ----------------------------------------------
  // Once asserted, valid is BINDING: the payload follows on schedule even if
  // a stall arrives in between. A model presenting valid with its data passes
  // functionally and fails the swap test, which is why this is checked rather
  // than assumed.
  `CCV_CONTRACT_M(MODE, payload_known_when_due,
                  !valid_q || !$isunknown(ch_payload))

  // -- bounded response, standing in for liveness -------------------------
  // s_eventually does not exist on this toolchain (F-2), so "eventually
  // answered" cannot be stated. This bounds the wait instead: strictly
  // weaker, and TIMEOUT_N derives from the round trip rather than being
  // chosen per block.
  //
  // PROVISIONAL BY CONSTRUCTION: N cannot be justified before contention data
  // exists. Revising it is an expected Stage 4b output, not a spec change.
  `CCV_CONTRACT_M(MODE, response_within_n, oldest_age <= TIMEOUT_N[TW-1:0])

  // -- event emission (§5 of the convention) ------------------------------
  // Emitting HERE, in the shared checker, rather than per block: every
  // boundary then emits identically and there is no per-block opportunity to
  // drift from the schema -- which is the failure that would quietly corrupt
  // correlation. The channel id distinguishes them.
  //
  // Pinned to the cycle the PAYLOAD lands, not the cycle valid asserts. Valid
  // leads by one by convention, so pinning to valid would make every event on
  // every channel uniformly one cycle early -- exactly the systematic offset
  // tools/check-emit-calib.sh exists to catch.
  logic [63:0] cyc;
  always_ff @(posedge clk) begin
    if (!rst_n) cyc <= 64'd0;
    else        cyc <= cyc + 64'd1;
  end

  always_ff @(posedge clk) begin
    if (rst_n && valid_q) begin
      `CCV_IF_EMIT(cyc, {32'b0, ch_payload[31:0]}, EV_CH_XFER, UNIT_UNKNOWN,
                   CHANNEL, ch_payload[31:0], 0)
    end
  end

  // -- satisfiability covers (§3.3) -- MANDATORY --------------------------
  // Unconditional, never mode-resolved: a guard that switched off in the mode
  // where assumptions are active would be absent exactly when needed.
  //
  // They also answer the "instantiated but never reached" case: a boundary
  // carrying no traffic reports nothing forever and looks identical to a
  // clean one. An unreached cover is the only available signal.
  `CCV_IF_SAT(traffic,      ch_valid)
  `CCV_IF_SAT(credit_flow,  ch_credit)
  `CCV_IF_SAT(stall_seen,   ch_stall)
  `CCV_IF_SAT(depth_pushed, outstanding == DEPTH[CW-1:0])

endmodule

`undef CCV_CLK
`undef CCV_RST
