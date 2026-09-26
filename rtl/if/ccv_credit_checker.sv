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
// THE ROUND TRIP IS 2 EVERYWHERE, BY CONSTRUCTION. Flops on both sides with
// no exceptions, plus abutment, gives exactly that -- it is not a per-block
// choice. So credit depth, rescue depth and drain wait are not three numbers
// but one number under three names, and all are 2 today; wake is 4.
//
// They remain PARAMETERS rather than being read straight from the package for
// one reason: a non-abutting interface would differ, and none is known to be
// non-abutting until floorplan. Defaulting them to the global constants means
// the common case needs no override, while the day a floorplan produces a
// non-abutting boundary the change is local and all of them move together --
// which is the correct failure mode.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"
`include "ccv_params_pkg.sv"

`define CCV_CLK clk
`define CCV_RST !rst_n

module ccv_credit_checker #(
  parameter int MODE       = `CCV_MODE_ASSERT,
  parameter int PAYLOAD_W  = 32,
  parameter int ROUND_TRIP = ccv_params_pkg::CCV_RT_ABUT,
  // DERIVED, not chosen: credit depth IS the round trip. Defaulting it from
  // ROUND_TRIP rather than from CCV_CREDIT_DEPTH separately is what stops the
  // two from being overridden apart -- they are the same number.
  parameter int DEPTH      = ROUND_TRIP,
  // PROVISIONAL by construction: N cannot be justified before contention data
  // exists, so revising it is an expected Stage 4b output, not a spec change.
  // The memory path needs CCV_P_TIMEOUT_MEM instead -- it must exceed
  // worst-case DRAM latency, which the local number does not.
  parameter int TIMEOUT_N  = ccv_prov_pkg::CCV_P_TIMEOUT_N,
  parameter int CHANNEL    = 0,          // CCV_CH_* from the generated header
  // Payload bits that LEAD: driven with valid, one cycle ahead of the rest of
  // the payload, in the same register (schema lead_fields). The lane mask is
  // the case -- it gates a lane before the operands it gates arrive. Zero on
  // every channel without lead fields, which makes the property vacuous.
  parameter logic [PAYLOAD_W-1:0] LEAD_MASK = '0,
  // Sequential repeater stages between THIS checker and the sender
  // (rtl/phys/ccv_seq_rpt.sv). Only the stall rule depends on where along a
  // repeated link the checker sits: a stall seen here reaches the sender
  // SRC_STAGES cycles later, and the first valid it can suppress takes as
  // long again to come back. 0 is the sender's own port, as on every
  // abutted link. ROUND_TRIP is the whole link's, wherever the checker is.
  parameter int SRC_STAGES = 0
) (
  input logic                  clk,
  input logic                  rst_n,
  input logic                  ch_valid,
  input logic [PAYLOAD_W-1:0]  ch_payload,
  input logic                  ch_credit,
  input logic                  ch_stall
`ifdef CCV_TRACE
  ,
  // TRACE-ONLY identity of the message whose payload is on the wire, riding
  // beside it -- never inside the payload struct, and absent entirely unless
  // CCV_TRACE is defined, so synthesis never sees it (interface decisions,
  // 2026-09-24). Layout: schema/events.json uid_layout.
  input logic [63:0]           ch_tid
`endif
);

  localparam int CW = $clog2(DEPTH + 2);
  localparam int TW = $clog2(TIMEOUT_N + 2);
  // One slot past the limit, so a message that overruns by one is still aged.
  // Beyond that no_overrun has already fired and the extra messages go
  // untracked -- the checker reports the first thing wrong, not every one.
  localparam int QD = DEPTH + 1;

  // Per-message ages as ONE flat vector, oldest in the low TW bits, indexed
  // with part-selects. Not `logic [QD-1:0][TW-1:0]`: Yosys 0.33 rejects a
  // multi-dimensional packed array outright (a syntax error at the second
  // bracket), and it rejects `int'()` casts too, so both are out of the
  // three-tool intersection this checker has to live in.
  logic [CW-1:0]      outstanding;
  logic [QD*TW-1:0]   age_q;
  logic [QD*TW-1:0]   aged;          // after this cycle's aging
  logic [QD*TW-1:0]   shifted;       // after the oldest leaves, if it does
  logic [QD*TW-1:0]   age_d;         // after a new message joins, if one does
  logic [CW-1:0]      tail;
  logic               valid_q;
  // The stall, as old as the first valid it can have suppressed: one cycle
  // at the sender, 1 + 2 * SRC_STAGES at a point that far downstream.
  localparam int SL = 1 + 2 * SRC_STAGES;
  logic [SL-1:0]      stall_h;

  wire sent     = ch_valid;
  wire returned = ch_credit;

  // A credit only retires a message if one is outstanding. A phantom credit
  // is REPORTED (no_phantom_credit) but must not move the count: letting it
  // wrap made the very next report a bogus no_overrun, which points whoever
  // is debugging at the sender when the receiver is at fault. Found by the
  // phantom negative control under Icarus; Verilator hid it by stopping at
  // the first failure.
  wire pop  = returned && (outstanding != '0);
  wire push = sent;

  // AGE IS PER MESSAGE. The previous version kept one counter for the oldest
  // message and reset it when that message was answered -- so the NEXT
  // message's clock restarted from zero, and anything but the oldest message
  // could be outstanding for up to ~2N before this fired. The timeout_second
  // and second_late negative controls measured it: a second message stuck
  // behind a first answered at exactly N fired 31 cycles late.
  //
  // Credits are fungible, so a returning credit retires the OLDEST message.
  // That is the only reading available at the channel level, and it is the
  // one the protocol's "no message outstanding more than N" needs.
  //
  // An age counts the edges a message has been outstanding at, INCLUDING the
  // edge that consumed its credit -- a credit is consumed when valid asserts,
  // not when the payload lands. So a message consumed at edge k and answered
  // at edge k+N passes, and one answered at k+N+1 fails AT k+N+1: no
  // detection latency. The old counter started one edge late and missed a
  // message answered at exactly N+1 (timeout_n1).
  // Continuous assigns, one per slot, rather than an always_comb that reads
  // and part-selects the vector it is writing. Icarus supports the latter only
  // partially -- it warns that constant selects in always_* are unsupported
  // and falls back to whole-vector sensitivity. The result was right, but a
  // warning printed on every build is one people learn to skip, and Icarus
  // is the ONLY witness for payload_known_when_due.
  for (genvar g = 0; g < QD; g++) begin : g_age
    wire          live = (CW'(g) < outstanding);
    wire [TW-1:0] a    = age_q[g*TW +: TW];
    // Every outstanding message ages by one, saturating.
    assign aged[g*TW +: TW] = (live && (a != {TW{1'b1}})) ? a + 1'b1 : a;
  end

  // The oldest leaves on a credit; everything behind it moves up one.
  assign shifted = pop ? {{TW{1'b0}}, aged[QD*TW-1:TW]} : aged;

  // A new message joins behind the last one still outstanding, having been
  // outstanding at one edge: the one consuming its credit.
  assign tail = pop ? (outstanding - 1'b1) : outstanding;
  for (genvar g = 0; g < QD; g++) begin : g_push
    assign age_d[g*TW +: TW] = (push && (CW'(g) == tail)) ? TW'(1)
                                                         : shifted[g*TW +: TW];
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      outstanding <= '0;
      age_q       <= '0;
      valid_q     <= 1'b0;
      stall_h     <= '0;
    end else begin
      valid_q <= ch_valid;
      stall_h <= SL'({stall_h, ch_stall});
      age_q   <= age_d;

      // Saturating at both ends, for the same reason pop is guarded: a
      // counter that wraps turns one error into a stream of wrong ones.
      if (push && !pop && (outstanding != {CW{1'b1}}))
        outstanding <= outstanding + 1'b1;
      else if (!push && pop)
        outstanding <= outstanding - 1'b1;
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

  // -- configuration is checked, not trusted --------------------------------
  // Both of these are misconfigurations that produce NO protocol violation, so
  // nothing else in this file would catch them:
  //
  //   DEPTH < ROUND_TRIP       the sender runs out of credits before the first
  //                            one returns. The interface still obeys every
  //                            rule below; it just throttles to one message
  //                            per round trip and looks like healthy
  //                            backpressure.
  //   TIMEOUT_N < ROUND_TRIP   response_within_n fires on a channel that is
  //                            behaving perfectly, and the first instinct on
  //                            seeing it is to raise N -- i.e. the check
  //                            teaches you to disbelieve it.
  //
  // `CCV_IF_CONFIG is unconditional by construction -- see ccv_if.svh for why
  // a mode-resolved configuration check is a fail-open.
  `CCV_IF_CONFIG(depth_covers_round_trip,   DEPTH     >= ROUND_TRIP)
  `CCV_IF_CONFIG(timeout_covers_round_trip, TIMEOUT_N >= ROUND_TRIP)

  // -- the credit protocol -------------------------------------------------

  // The property the whole scheme exists to guarantee, and the one whose
  // violation overruns the receiver silently.
  `CCV_CONTRACT_M(MODE, no_overrun, outstanding <= DEPTH[CW-1:0])

  // A credit returned for something never sent: a receiver counting wrong,
  // which surfaces later as a sender that never throttles.
  //
  // Including a credit that arrives on the SAME edge a message is consumed,
  // with nothing outstanding before it. The previous form excused that case
  // (`&& !sent`), but the round trip is at least 2, so a credit cannot belong
  // to a message whose payload has not yet been sent -- it is a phantom that
  // happens to coincide with a send. Found by phantom_with_send.
  `CCV_CONTRACT_M(MODE, no_phantom_credit,
                  !(returned && (outstanding == '0)))

  // No message may be sent the cycle after a stall is received. That
  // guarantee is what makes the in-flight window a fixed count rather than a
  // handshake, and rescue depth, drain wait and sleep entry are all counted
  // against it. Stated at the SENDER: downstream of repeater stages the
  // valids already in flight still arrive, so the stall checked is the one
  // old enough to have stopped the valid seen now.
  `CCV_CONTRACT_M(MODE, stall_honoured, !(stall_h[SL-1] && ch_valid))

  // -- valid one cycle early ----------------------------------------------
  // Once asserted, valid is BINDING: the payload follows on schedule even if
  // a stall arrives in between. A model presenting valid with its data passes
  // functionally and fails the swap test, which is why this is checked rather
  // than assumed.
  `CCV_CONTRACT_M(MODE, payload_known_when_due,
                  !valid_q || !$isunknown(ch_payload))

  // Lead fields are due WITH valid, not after it: a receiver acts on them in
  // the valid cycle (a lane gates itself on its mask before its operands
  // land). Like payload_known_when_due, only a four-state simulator or formal
  // can see it fail.
  // Through a wire: Icarus 12 reports $isunknown of the inline expression
  // as 1 whenever PAYLOAD_W is overridden, with every bit known (F-19).
  wire [PAYLOAD_W-1:0] lead_bits = ch_payload & LEAD_MASK;
  `CCV_CONTRACT_M(MODE, lead_known_at_valid,
                  !ch_valid || !$isunknown(lead_bits))

  // -- bounded response, standing in for liveness -------------------------
  // s_eventually does not exist on this toolchain (F-2), so "eventually
  // answered" cannot be stated. This bounds the wait instead: strictly
  // weaker, and TIMEOUT_N derives from the round trip rather than being
  // chosen per block.
  //
  // PROVISIONAL BY CONSTRUCTION: N cannot be justified before contention data
  // exists. Revising it is an expected Stage 4b output, not a spec change.
  `CCV_CONTRACT_M(MODE, response_within_n, age_q[TW-1:0] <= TIMEOUT_N[TW-1:0])

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

  // The event carries the payload's low 32 bits. Zero-extended first: a
  // payload narrower than 32 bits made `ch_payload[31:0]` an out-of-range
  // select, which no test saw while every checker was instantiated at 32 bits.
  // The skeleton's bank instantiates one per slot at the channel's REAL width,
  // and 10 channels are narrower -- ooe->rau demote is 6 bits.
  // A generate-if rather than a ternary, so each width elaborates only the
  // branch it can: a dead `ch_payload[31:0]` is still an out-of-range select.
  // The schema names EV_CH_XFER's fields channel_id, payload_lo, payload_hi;
  // the hi half was emitted as a constant 0 until the skeleton put real
  // payloads through, so it is filled here for every width.
  //
  // The MESSAGE, not the wire: a lead slice is taken in the valid cycle, as
  // the receiver takes it, because by the time the rest of the payload lands
  // the wire's lead slice may already belong to the next message.
  // Only the bits the event carries are rebuilt.
  localparam int EW = (PAYLOAD_W < 64) ? PAYLOAD_W : 64;
  logic [EW-1:0] lead_q;
  always_ff @(posedge clk) begin
    if (ch_valid) lead_q <= ch_payload[EW-1:0] & LEAD_MASK[EW-1:0];
  end
  wire [EW-1:0] msg = (ch_payload[EW-1:0] & ~LEAD_MASK[EW-1:0]) | lead_q;

  logic [31:0] pl_lo, pl_hi;
  if (PAYLOAD_W <= 32) begin : g_narrow
    assign pl_lo = 32'(msg);
    assign pl_hi = '0;
  end else if (PAYLOAD_W < 64) begin : g_mid
    assign pl_lo = msg[31:0];
    assign pl_hi = 32'(msg[EW-1:32]);
  end else begin : g_wide
    assign pl_lo = msg[31:0];
    assign pl_hi = msg[63:32];
  end

  // The event's instr_uid is the message's trace identity. It used to be the
  // payload's low word, which identified nothing; without CCV_TRACE there is
  // no identity to give, and 0 is class `none`, seq 0 -- honest rather than
  // plausible.
`ifdef CCV_TRACE
  wire [63:0] uid = ch_tid;
`else
  wire [63:0] uid = '0;
`endif

  always_ff @(posedge clk) begin
    if (rst_n && valid_q) begin
      `CCV_IF_EMIT(cyc, uid, EV_CH_XFER, UNIT_UNKNOWN,
                   CHANNEL, pl_lo, pl_hi)
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
