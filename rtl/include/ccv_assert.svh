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
// CLOCK AND RESET ARE IMPLICIT
//
// The macros reference `clk` and `rst` by name. §9 requires clock and reset
// ports to be identically named in every module, which the single-clock,
// global-synchronous-reset decision (§6) makes reasonable, and which the swap
// harness depends on anyway. Use the `_AT` forms for the rare module where
// that does not hold.
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

`define CCV_CONTRACT(ROLE, NAME, EXPR) `CCV_CONTRACT_AT(clk, rst, ROLE, NAME, EXPR)
`define CCV_ASSERT(NAME, EXPR)         `CCV_CONTRACT_AT(clk, rst, assert, NAME, EXPR)
`define CCV_ASSUME(NAME, EXPR)         `CCV_CONTRACT_AT(clk, rst, assume, NAME, EXPR)
`define CCV_ASSERT_AT(CLK, RST, NAME, EXPR) `CCV_CONTRACT_AT(CLK, RST, assert, NAME, EXPR)
`define CCV_ASSUME_AT(CLK, RST, NAME, EXPR) `CCV_CONTRACT_AT(CLK, RST, assume, NAME, EXPR)
`define CCV_COVER(NAME, EXPR)          `CCV_COVER_AT(clk, rst, NAME, EXPR)

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
//===----------------------------------------------------------------------===//
`define CCV_ASSERT_KNOWN(NAME, SIG) \
  `CCV_CONTRACT_AT(clk, rst, assert, NAME, !$isunknown(SIG))

`define CCV_ASSERT_KNOWN_IF(NAME, VALID, SIG) \
  `CCV_CONTRACT_AT(clk, rst, assert, NAME, !(VALID) || !$isunknown(SIG))

// The `assume` half, and it is not optional under formal.
//
// Yosys models an unconstrained module INPUT as possibly-X, so
// `CCV_ASSERT_KNOWN on an input is satisfiable and fails spuriously -- a real
// result from the 1b build, not a hypothetical (finding F-8). The fix is the
// cut-point discipline §7 already describes, applied to X: a block ASSUMES its
// inputs are X-free, because its neighbour asserts exactly that, and then
// PROVES its own outputs are. The two halves compose into a whole-design
// argument, one boundary at a time.
//
// Every block's formal run should carry one of these per control input.
`define CCV_ASSUME_KNOWN(NAME, SIG) \
  `CCV_CONTRACT_AT(clk, rst, assume, NAME, !$isunknown(SIG))

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
  `CCV_CONTRACT_AT(clk, rst, assert, NAME, !(READ_EN) || (VALID_BIT))

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
  `define CCV_ASSERT_T(NAME, EXPR) `CCV_CONTRACT_AT(clk, rst, assert, NAME, EXPR)
  `define CCV_ASSUME_T(NAME, EXPR) `CCV_CONTRACT_AT(clk, rst, assume, NAME, EXPR)
  `define CCV_PAST(SIG) $past(SIG)
`endif

`endif // CCV_ASSERT_SVH
