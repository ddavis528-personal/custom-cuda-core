//===-- ccv_assert.svh - assertion primitive library ------------*- SV -*-===//
//
// §8 Stage 1b. Built against what Stage 1a actually found usable, not against
// the LRM -- see docs/stage1a-tool-support.md for the matrix and
// docs/stage1a-findings.md for what it forces.
//
//===----------------------------------------------------------------------===//
//
// WHY EVERY PROPERTY GOES THROUGH A MACRO
//
// The three tools accept three different dialects, and no two of them overlap
// (finding F-1):
//
//     assertion label       Icarus rejects,  Verilator/Yosys accept
//     `else $error(...)`    Yosys rejects,   Icarus/Verilator accept
//     $past                 Icarus rejects,  Verilator/Yosys accept
//     assert property(...)  Verilator only
//
// There is no spelling of a named, message-carrying property that all three
// accept. A property written out by hand is therefore broken in at least one
// tool, sometimes loudly and sometimes not. So no block writes `assert`
// directly; tools/lint-rtl.py enforces that.
//
// WHAT THE `ifdef BELOW IS, AND WHAT IT IS NOT
//
// §7 forbids compiling properties out, because formal would then read
// different source than simulation. What varies here is each property's
// SPELLING -- label present or absent, `else` clause present or absent. Every
// property is elaborated in every tool, in every flow, always. Varying
// spelling preserves §7's invariant; varying presence would destroy it. This
// file is the only place allowed to do either, and it only ever does the
// first. The single exception is the temporal tier, which is called out
// explicitly where it is defined.
//
// FORM: IMMEDIATE ASSERTIONS IN A CLOCKED BLOCK, EVERYWHERE
//
// Only Verilator supports concurrent `assert property`. Using it there and
// the immediate form elsewhere would mean the same property is evaluated in a
// different scheduling region depending on the tool -- a difference that would
// surface at §5 correlation as a phantom divergence. So every tool gets the
// immediate form in a clocked `always`, which is semantically identical
// everywhere. Uniformity is worth more here than Verilator's extra fidelity.
//
// CLOCK AND RESET COME FROM TWO PER-FILE DEFINES
//
// Every block gates `core_clk` on entry and uses the uniquified result, so
// there is no single clock name the macros could hardcode -- `sched_core_clk`
// and `alu_core_clk` are different nets. Reset is worse: it is pipelined, and
// which stage of the distribution tree reaches a block depends on physical
// distance, so its name differs per block too.
//
// So each design file names its own, once, and clears them at the end:
//
//     `define CCV_CLK clk          // the block's gated clock port
//     `define CCV_RST !rst_n        // CCV_RST is the IN-RESET condition
//       ... module body, with `CCV_ASSERT(...) as usual ...
//     `undef CCV_CLK
//     `undef CCV_RST
//
// `CCV_RST is the condition that means "currently in reset", not the reset
// net. The block-level grill-me made reset ACTIVE LOW (`rst_n`), so it is
// spelled `!rst_n` at the define and no macro changes -- the expansion
// `if (!(!rst_n) && ...)` reduces to "assertions live when not in reset",
// which is what every branch already meant.
//
// The inner macros expand at USE time rather than at definition time, so each
// file genuinely gets its own clock -- verified in all three tools, and the
// `undef is what stops one file's clock leaking into the next in a shared
// compilation unit. CCV-L02 requires both the defines and the undefs.
//
// Use the `_AT` forms directly for a module that needs two clocks, which under
// §6's single-domain decision should not exist yet outside DFT.
//
//===----------------------------------------------------------------------===//
`ifndef CCV_ASSERT_SVH
`define CCV_ASSERT_SVH

//===----------------------------------------------------------------------===//
// Tier 1 -- boolean properties. Green in all three tools.
//
// `CCV_CONTRACT is the primitive; ROLE is `assert` or `assume`, chosen at the
// CALL SITE. §7 asks for exactly this: a property that is an obligation at
// block level often has to become an environment constraint at system level,
// once that block sits inside a larger cut boundary, and the two roles must be
// swappable without rewriting the property.
//
// The pattern for a swappable block-output contract -- the preprocessor cannot
// build an `ifdef name from a macro argument, so each block spells its own
// tag out once, near the top of the file:
//
//     `ifdef CCV_BLACKBOX_ROB
//       `define ROB_OUT assume     // black-boxed: its guarantees are my givens
//     `else
//       `define ROB_OUT assert     // real: its guarantees are its obligations
//     `endif
//     ...
//     `CCV_CONTRACT(`ROB_OUT, rob_valid_stable, !(valid && !ready) || stable)
//
// `cover` is deliberately NOT a role here: it takes no `else` clause, so
// folding it into the same macro would make one of the two forms wrong.
//===----------------------------------------------------------------------===//

`ifdef VERILATOR
  `define CCV_CONTRACT_AT(CLK, RST, ROLE, NAME, EXPR) \
    always @(posedge CLK) if (!(RST) && ccv_assert_pkg::enabled()) begin \
      NAME: ROLE (EXPR) else $error("CCV %s failed", `"NAME`"); \
    end
  `define CCV_COVER_AT(CLK, RST, NAME, EXPR) \
    always @(posedge CLK) if (!(RST)) begin \
      NAME: cover (EXPR); \
    end
`elsif FORMAL
  // Yosys's native front end rejects the `else` action block. It DOES accept
  // the label, which is worth keeping: without it a counterexample names the
  // property `$assert$<file>:<line>$<n>` instead of what it is, and §5's
  // divergence triage is the place that costs.
  `define CCV_CONTRACT_AT(CLK, RST, ROLE, NAME, EXPR) \
    always @(posedge CLK) if (!(RST) && ccv_assert_pkg::enabled()) begin \
      NAME: ROLE (EXPR); \
    end
  `define CCV_COVER_AT(CLK, RST, NAME, EXPR) \
    always @(posedge CLK) if (!(RST)) begin \
      NAME: cover (EXPR); \
    end
`elsif __ICARUS__
  // Icarus rejects the label and accepts the `else`, so the property name has
  // to travel inside the message instead.
  `define CCV_CONTRACT_AT(CLK, RST, ROLE, NAME, EXPR) \
    always @(posedge CLK) if (!(RST) && ccv_assert_pkg::enabled()) begin \
      ROLE (EXPR) else $error("CCV %s failed", `"NAME`"); \
    end
  `define CCV_COVER_AT(CLK, RST, NAME, EXPR) \
    always @(posedge CLK) if (!(RST)) begin \
      cover (EXPR); \
    end
`else
  // Unknown tool: emit the all-three intersection and nothing beyond it.
  `define CCV_CONTRACT_AT(CLK, RST, ROLE, NAME, EXPR) \
    always @(posedge CLK) if (!(RST) && ccv_assert_pkg::enabled()) begin \
      ROLE (EXPR); \
    end
  `define CCV_COVER_AT(CLK, RST, NAME, EXPR) \
    always @(posedge CLK) if (!(RST)) begin \
      cover (EXPR); \
    end
`endif

`define CCV_CONTRACT(ROLE, NAME, EXPR) `CCV_CONTRACT_AT(`CCV_CLK, `CCV_RST, ROLE, NAME, EXPR)
`define CCV_ASSERT(NAME, EXPR)         `CCV_CONTRACT_AT(`CCV_CLK, `CCV_RST, assert, NAME, EXPR)
`define CCV_ASSUME(NAME, EXPR)         `CCV_CONTRACT_AT(`CCV_CLK, `CCV_RST, assume, NAME, EXPR)
`define CCV_ASSERT_AT(CLK, RST, NAME, EXPR) `CCV_CONTRACT_AT(CLK, RST, assert, NAME, EXPR)
`define CCV_ASSUME_AT(CLK, RST, NAME, EXPR) `CCV_CONTRACT_AT(CLK, RST, assume, NAME, EXPR)
`define CCV_COVER(NAME, EXPR)          `CCV_COVER_AT(`CCV_CLK, `CCV_RST, NAME, EXPR)

//===----------------------------------------------------------------------===//
// §6 -- X on control is prohibited rather than propagated.
//
// The single highest-payoff rule in the style guide, and the one that closes
// Verilog's X-optimism hole: `if (x)` silently takes the false branch in every
// 4-state simulator, so X on a control signal is invisible unless something
// asks. This asks.
//
// It is also the rule with the widest tool spread, and the spread is the
// point, not a gap (finding F-6): Icarus fires on genuinely-X control,
// while Verilator, being 2-state, structurally cannot. Neither is wrong; they
// answer different questions, which is why §6 runs both. Under formal it is the
// strongest of the three, since un-reset state is a free variable rather than
// whatever one run happened to produce.
//
// UNDER FORMAL THERE IS NO X, and $isunknown is worse than meaningless there
// (finding F-20). The formal model is two-state: an un-reset register is a
// free two-state value (F-8), and so is an input. Yosys lowers $isunknown(s)
// to a case-equality against an x constant, which its SMT backend reads as
// ZERO -- so "unknown" means "equals 0", `assume(!$isunknown(s))` pins s to
// ALL ONES, and `assert(!$isunknown(s))` fails whenever s is 0. Every checker
// that assumed its inputs known was proving things about a sender whose
// valid never fell. So CCV_KNOWN is constant true under FORMAL: X-freedom is
// the simulators' question (the Icarus X-pass, F-6), and formal proves the
// protocol over every two-state value instead.
//===----------------------------------------------------------------------===//
`ifdef FORMAL
  `define CCV_KNOWN(SIG) 1'b1
`else
  `define CCV_KNOWN(SIG) !$isunknown(SIG)
`endif

`define CCV_ASSERT_KNOWN(NAME, SIG) \
  `CCV_CONTRACT_AT(`CCV_CLK, `CCV_RST, assert, NAME, `CCV_KNOWN(SIG))

`define CCV_ASSERT_KNOWN_IF(NAME, VALID, SIG) \
  `CCV_CONTRACT_AT(`CCV_CLK, `CCV_RST, assert, NAME, !(VALID) || `CCV_KNOWN(SIG))

// The `assume` half: in a simulation-driven run it states the contract a
// block's neighbour asserts, one boundary at a time (§7's cut-point
// discipline, applied to X). Under formal it is vacuous by construction,
// through CCV_KNOWN -- F-8 once made it required there, on a reading of
// Yosys's X modelling that F-20 corrected: it pinned every such input to
// all ones.
`define CCV_ASSUME_KNOWN(NAME, SIG) \
  `CCV_CONTRACT_AT(`CCV_CLK, `CCV_RST, assume, NAME, `CCV_KNOWN(SIG))

//===----------------------------------------------------------------------===//
// §6's un-reset-payload invariant:
//
//     "Un-reset state is payload. Payload is only ever read when an
//      accompanying valid bit says it was written -- and valid bits are
//      always reset."
//
// §7 makes this the third formal target, on the argument that formal "treats
// uninitialized state as free variables rather than as whatever value one
// simulation run produced."
//
// That argument is right, but it does NOT license writing the property with
// $isunknown, and the distinction cost a wrong turn during the 1b build
// (finding F-8). Yosys gives an un-reset register a free TWO-state value, not
// X. So `$isunknown(payload)` is identically false under formal, and a
// property built on it is vacuously true -- green, permanently, while proving
// nothing at all. That is the worst failure mode available: a formal target
// reported as discharged when it was never checked.
//
// The invariant has to be stated structurally instead, over the valid bit
// rather than over the payload's value. Which is also simply a better
// property: it is what the invariant actually says.
//===----------------------------------------------------------------------===//
`define CCV_ASSERT_READ_VALID(NAME, READ_EN, VALID_BIT) \
  `CCV_CONTRACT_AT(`CCV_CLK, `CCV_RST, assert, NAME, !(READ_EN) || (VALID_BIT))

//===----------------------------------------------------------------------===//
// Tier 1b -- bounded temporal properties, built from explicit tracking state.
//
// These are the properties that WOULD be sequences if any sequence construct
// were available. None is (F-2): `##n`, `sequence`, `throughout`, property
// local variables and `s_eventually` are rejected by all three tools, and
// $stable is Verilator-only. So each one below is a small counter or shadow
// register plus a boolean property over it -- which is tier 1, and therefore
// green everywhere, including under Icarus and under formal.
//
// They declare state, so they are not pure properties. Two consequences worth
// knowing before using them:
//
//   * The state is REAL. It elaborates in every flow and the solver carries it,
//     so a wide `SIG` or a large `N` costs proof time. Keep N as small as the
//     contract actually requires.
//   * `$bits(SIG)` is taken through a `localparam` rather than used directly
//     in the declaration's range. Using it directly ELABORATES CLEANLY in all
//     three tools and then crashes Icarus at RUNTIME --
//     `internal error: port 0 expects wid=0` -- but only when the shadow
//     register is driven from a different `always` block than SIG, which is
//     exactly what a macro-declared shadow always is. A hand-written test with
//     both in one block passes, which is how this nearly shipped. The
//     indirection costs nothing and is clean everywhere.
//
//   * NAME must be unique in the module -- it is pasted into the declared
//     signal names. A duplicate gives a redeclaration error naming the
//     generated signal, not the macro, so pick names the way you would for
//     ordinary signals.
//
// All three take their clock and reset from `CCV_CLK / `CCV_RST, like the
// rest of the library.
//===----------------------------------------------------------------------===//

// SIG may not change for as long as COND holds continuously.
//
// The convention's §3.2 "payload and tag stability while stalled" is this,
// with COND being the stall. Note the shape: it constrains change ACROSS a
// contiguous window, so it says nothing at the cycle COND first asserts, which
// is correct -- the value is allowed to arrive on that cycle.
`define CCV_TRACK_STABLE_WHILE(NAME, COND, SIG)                        \
  localparam int NAME``_W = $bits(SIG);                                 \
  logic [NAME``_W-1:0]   NAME``_shadow;                                 \
  logic                  NAME``_armed;                                  \
  always_ff @(posedge `CCV_CLK) begin                                        \
    if (`CCV_RST) NAME``_armed <= 1'b0;                                      \
    else begin                                                          \
      NAME``_armed  <= (COND);                                          \
      NAME``_shadow <= (SIG);                                           \
    end                                                                 \
  end                                                                   \
  wire NAME``_ok = !NAME``_armed || !(COND) || ((SIG) == NAME``_shadow)

`define CCV_ASSERT_STABLE_WHILE(NAME, COND, SIG)                       \
  `CCV_TRACK_STABLE_WHILE(NAME, COND, SIG);                             \
  `CCV_ASSERT(NAME, NAME``_ok)

// SIG is sampled when START pulses and may not change for the next N cycles.
//
// The duration-bounded form, for a contract stated in cycles rather than
// against a condition -- "the tag holds for the whole burst", "the address
// holds for N beats".
`define CCV_TRACK_STABLE_FOR(NAME, START, SIG, N)                      \
  localparam int NAME``_W = $bits(SIG);                                 \
  logic [$clog2((N)+2)-1:0] NAME``_cnt;                                 \
  logic [NAME``_W-1:0]      NAME``_hold;                                \
  always_ff @(posedge `CCV_CLK) begin                                        \
    if (`CCV_RST) NAME``_cnt <= '0;                                          \
    else if (START) begin                                               \
      NAME``_cnt  <= (N);                                               \
      NAME``_hold <= (SIG);                                             \
    end else if (NAME``_cnt != 0) begin                                 \
      NAME``_cnt <= NAME``_cnt - 1'b1;                                  \
    end                                                                 \
  end                                                                   \
  wire NAME``_ok = (NAME``_cnt == 0) || ((SIG) == NAME``_hold)

`define CCV_ASSERT_STABLE_FOR(NAME, START, SIG, N)                     \
  `CCV_TRACK_STABLE_FOR(NAME, START, SIG, N);                           \
  `CCV_ASSERT(NAME, NAME``_ok)

// A request is answered within N cycles.
//
// This is what replaces liveness. F-2 removed `s_eventually`, so "a request is
// eventually answered" cannot be stated at all, and the strategy doc's §8 open
// item 8 records the consequence: every interface needs a BOUNDED latency with
// a justified N instead. Strictly weaker than liveness -- it cannot prove the
// absence of deadlock, only bound the wait -- and N is a number somebody has
// to defend per interface rather than a formality.
//
// ONE OUTSTANDING REQUEST is assumed: the age counter clears on any ACK. For a
// pipelined interface with several in flight, this needs a per-tag age array
// instead, which is a Stage 2 decision per interface, not a default.
`define CCV_TRACK_RESPONSE_WITHIN(NAME, REQ, ACK, N)                   \
  logic [$clog2((N)+2)-1:0] NAME``_age;                                 \
  always_ff @(posedge `CCV_CLK) begin                                        \
    if (`CCV_RST) NAME``_age <= '0;                                          \
    else if (ACK) NAME``_age <= '0;                                     \
    else if ((REQ) || NAME``_age != 0) NAME``_age <= NAME``_age + 1'b1; \
  end                                                                   \
  wire NAME``_ok = (NAME``_age <= (N))

`define CCV_ASSERT_RESPONSE_WITHIN(NAME, REQ, ACK, N)                  \
  `CCV_TRACK_RESPONSE_WITHIN(NAME, REQ, ACK, N);                        \
  `CCV_ASSERT(NAME, NAME``_ok)

//===----------------------------------------------------------------------===//
// Tier 2 -- temporal properties. Verilator and formal only.
//
// THIS TIER IS THE ONE EXCEPTION to "every property is elaborated in every
// flow", and it is made explicit at the call site rather than hidden, so that
// reading a block tells you which of its properties the X-pass does not carry.
//
// Icarus has no $past (F-1), and the Stage 1a matrix shows no multi-cycle
// sequence construct works in ANY of the three tools (F-2) -- not `##n`, not
// `sequence`, not `throughout`, not property local variables. So temporal
// contracts are written as an explicit history register plus a boolean
// property over it, and $past is available only as the one-cycle convenience.
//
// The consequence to keep in view: Icarus's job in this flow is the periodic
// X-cleanliness pass (§6), not the assertion regression, and an X-pass runs
// with this tier absent. tools/run-xpass.sh says so on every run rather than
// leaving it to be remembered.
//===----------------------------------------------------------------------===//
`ifdef __ICARUS__
  `define CCV_ASSERT_T(NAME, EXPR)
  `define CCV_ASSUME_T(NAME, EXPR)
  `define CCV_PAST(SIG) (SIG)
`else
  `define CCV_ASSERT_T(NAME, EXPR) `CCV_CONTRACT_AT(`CCV_CLK, `CCV_RST, assert, NAME, EXPR)
  `define CCV_ASSUME_T(NAME, EXPR) `CCV_CONTRACT_AT(`CCV_CLK, `CCV_RST, assume, NAME, EXPR)
  `define CCV_PAST(SIG) $past(SIG)
`endif

`endif // CCV_ASSERT_SVH
