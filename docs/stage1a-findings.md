# Stage 1a — findings and the decisions they force

**Companion to [`stage1a-tool-support.md`](stage1a-tool-support.md), which is
generated.** That file is data: rerun `tools/run-spike-1a.py` and it changes.
This file is judgment: what the data means, and what it settles. It changes
only when someone decides something.

**Status: Stage 1a complete.** All four of its exit criteria are met — the
construct × tool matrix exists with a named usable subset, Verible's story is
established, and Verilator's X-randomization flag behaviour is confirmed
rather than assumed.

---

## The headline: the intersection is thin, and §7's posture survives anyway

§8 front-loaded this spike for one specific reason — *"if the intersection
comes back thin, particularly if concurrent/temporal SVA proves unreliable
across the free stack, that is not a minor tooling annoyance, it undercuts §7's
entire lean-into-formal posture."*

**The intersection came back thin.** It is, in full:

> Unlabelled immediate `assert` / `assume` / `cover`, inside a clocked
> `always` block, with no `else` action block, over a pure boolean expression.

Nothing else is green in all three tools. Not `assert property`. Not `|->`.
Not `$past`. Not one multi-cycle sequence.

**But the posture survives, because the thing §7 actually needs survived.**
Case 25 returns `PROVE-PASS`: an `assume` genuinely constrains the solver, so
black-boxing a neighbour and proving the rest of the design against its
contract — §7's cut-point mechanism, the thing that makes formal tractable for
a solo effort — works on this stack. That was the load-bearing question. The
answer is yes, and it is yes with cvc5 doing real work, not with a property
quietly dropped before it reached a solver.

So the conclusion is not "scale back formal." It is **one property source,
tool-specific expansion** — which is what Stage 1b exists to build, and is now
a requirement on it rather than an option.

---

## F-1 — Three tools, three different dialects, no two overlapping

Each tool rejects something the other two accept. This is the finding that
shapes 1b more than any other:

| | Icarus 12.0 | Verilator 5.020 | Yosys 0.33 (native) |
|---|---|---|---|
| assertion **label** (`a_foo: assert`) | **rejected** | accepted | accepted |
| **`else $error(...)`** action block | accepted | accepted | **rejected** |
| **`$past`** | **rejected** | accepted | accepted |
| concurrent `assert property` | **rejected** | accepted | **rejected** |

There is no spelling of a named, message-carrying, temporal property that all
three accept. A property written by hand for one tool is broken in at least
one other, silently or loudly.

**Decision (1b):** every property in this project is written through a macro,
never spelled out. The macro emits a different spelling per tool from one
source. No block-level RTL author ever writes `assert` directly, and lint
(1d) enforces that.

**This is not the `` `ifdef `` that §7 forbids, and the distinction is worth
being precise about,** because it looks identical at a glance. §7's rule is
that a property must never be *compiled out*, because formal would then read
different source than simulation and the one-property-set-serves-both-flows
guarantee dies. What the macro varies is the property's **spelling** — label
present or absent, `else` clause present or absent. The property itself is
elaborated in every flow, in every tool, always. Varying spelling preserves
§7's invariant; varying presence destroys it. The library is the only place
allowed to do either, and it only ever does the first.

## F-2 — Multi-cycle sequences do not exist on this stack

`##n` delays, `sequence` declarations, `throughout`, property local variables
and `s_eventually` are unsupported in *every* tool, including Verilator, which
is otherwise the most capable of the three. Verilator reports them honestly as
`Unsupported:` rather than miscompiling them, which is the good version of this
news.

**Consequence for §8 Stage 2, which needs recording now rather than being
discovered when interface assertions get written:** a request-to-response
contract spanning cycles cannot be stated as a sequence. It has to be stated as
an explicit tracking register plus a boolean property over it — the checker
carries its own state. That is more code per property and it is code that can
itself be wrong, so interface checkers become things to review rather than
things to read.

It also removes the natural way to state deadlock freedom. `s_eventually` is
gone, so "a request is eventually answered" has to become a bounded property:
*a request outstanding for more than N cycles is a failure*. That is strictly
weaker — it cannot prove liveness, only bound latency — and N is a number
somebody has to justify per interface. **This lands on Stage 2's plate**, where
interface contracts are written, and it is the sort of thing that would
otherwise surface at Stage 5 as "we cannot express the property we need."

## F-3 — `$assertoff` is unavailable, and the substitute is better anyway

§7 specifies `$assertoff`/`$asserton`/`$assertkill` as the runtime knob,
explicitly preferring them over `` `ifdef `` and calling them "built-in,
hierarchically-scoped, runtime system tasks — exactly the no-recompile knob
wanted."

They are not available:

- **Verilator 5.020** does not implement them at all: `Unsupported or unknown
  PLI call: '$assertoff'`. Not a scope-argument problem — the no-argument form
  fails identically.
- **Icarus 12.0** *parses* them and then has no runtime definition:
  `System task/function $assertoff() is not defined by any module`. It fails at
  elaboration rather than silently, which is the one mercy here.

**Decision (1b): a guard signal ANDed into the property's condition**,
provided by the library and never written by hand. Case 29 confirms it works —
silenced under both simulators, still firing under formal.

**The trap this mechanism carries, and why case 29 checks the formal column:**
if the guard were a free variable under formal, the solver would set it to 0
and *every property in the design* would pass vacuously. A green formal run
would mean nothing, and nothing about the run would look wrong. So under
`FORMAL` the guard is a `localparam` tied to 1, never a signal. Case 29's
`CHECK` in the sby column is the evidence that the knob has not quietly
disarmed the formal flow, and it should stay in the regression permanently for
exactly that reason.

## F-4 — SystemVerilog interfaces cannot be block boundaries. Settled.

§9 left this open — *"SystemVerilog `interface` constructs are the elegant
answer, but Verilator support has historically been limited... Which of these
actually works is a 1a spike question, it should not be assumed."*

Answer: **they do not work, and the reason is exactly the boundary §1's
swap mechanism relies on.**

    %Error-UNSUPPORTED: Unsupported: Interfaced port on top level module

Interfaces *inside* a block are fine — case 18 passes under Verilator, and it
is the only tool where that is true. But §2 makes block boundaries swap
boundaries, and a swap boundary must be Verilatable to C++ as a top-level
module. The one place interfaces would have paid is the one place they are
refused.

**Decision (1d): plain ports with consistent suffix conventions.** Not the
"safer default" §9 hedged toward — the only option. Packed structs remain
available for grouping and are worth using where a boundary has many signals,
since a struct port does Verilate; the interface/modport construct does not.

This is a settled decision rather than a preference, so §9's interface-style
section can be written as a rule with a reason attached.

## F-5 — Verible is not obtainable here, and the lint layer should not wait for it

§6 adds Verible as a fourth tool and is explicit that *"'lint enforces it' is
load-bearing for the whole approach."* Verible ships only as GitHub release
binaries, which this environment cannot reach.

**This matters less than it looks, and the reason is worth stating.** The
central X-safety rule — *no bare `if`/`case` on control without a paired
`$isunknown` assert* — is a relationship between two constructs, not a property
of one. Stock Verible rules do not express that, so it was always going to need
custom rule authoring against Verible's API. Taking the dependency on a
heavyweight fourth tool to end up writing custom rules anyway is a poor trade
for a solo project.

**Decision (1d): the lint layer is written against the project's own rules**
(`tools/lint-rtl.py`), with Verilator's `--lint-only` carrying the generic
checks it already does well (width mismatches, inferred latches, unused and
undriven signals). Verible stays welcome if it ever becomes available — the
rules are the artifact, the tool is an implementation detail — but nothing in
the flow blocks on it. The §6 tooling consequence ("this adds a fourth tool")
is therefore **retracted**: it adds a lint layer, not a fourth tool.

## F-6 — Verilator's X-randomization works, with the exact flags recorded

§6 asks that this be confirmed rather than assumed. Confirmed:

    --x-assign unique --x-initial unique
    +verilator+rand+reset+2 +verilator+seed+N

Case 26's un-reset control bit produces **two distinct traces across four
seeds**. The dependency on uninitialized state is detectable, so §6's
mitigation for the 2-state blind spot is real on this version.

**Read alongside the divergence in cases 26 and 28, which is the finding, not
a gap.** Icarus reports `CHECK` on both; Verilator reports `SILENT` on both and
*structurally cannot* do otherwise, being 2-state. That is precisely §6's
argument for pulling the Icarus X-pass forward to per-block Stage 4c rather
than leaving it at closure, and it is now demonstrated rather than reasoned.
Both cells should stay in the regression as the standing evidence that the two
simulators are answering different questions.

## F-7 — Formal needs cvc5 specifically; two plausible engines do not work

Not a tool-support finding about SVA, but it would have cost a day at Stage 4c
to rediscover:

- **boolector** — Debian ships 1.5 (2012). yosys-smtbmc dies with
  `BrokenPipeError` against it.
- **`abc bmc3`** — crashes with `KeyError: 'asserts'`, a witness-format
  mismatch between this sby and this Yosys.
- **cvc5 1.1.2** — works, and correctly names the failing assertion *and* its
  source line.

`tools/setup-toolchain.sh` installs cvc5 for this reason, and
`tools/run-spike-1a.py` probes for solvers in the order this finding
establishes rather than in a plausible-looking one.

## F-8 — `$isunknown` cannot express the un-reset-payload invariant under formal

Surfaced while building the 1b library against this stack, not during the
spike proper, but it belongs with the other findings because it corrects a
reading of §6/§7 rather than a tool expectation.

§7 makes "payload is never read before written" the third formal target, on
the argument that formal *"treats uninitialized state as free variables rather
than as whatever value one simulation run produced."* The argument is correct.
The natural way to write the property is not.

Two measured facts:

1. **An un-reset register is never X under Yosys formal.** It gets a free
   *two-state* value. So `$isunknown(payload)` is identically false, and any
   property built on it is vacuously true — green, permanently, checking
   nothing. That is the worst available failure mode: a formal target reported
   as discharged when it was never checked at all.
2. **An unconstrained module input IS modelled as possibly-X.** Yosys lowers
   `$isunknown` to `$eqx` cells, and on a free input the comparison is
   satisfiable, so `CCV_ASSERT_KNOWN` on an input fails *spuriously*.

The two pull in opposite directions, which is what makes the naive reading
dangerous: the same macro is vacuously true in one place and spuriously false
in another, and neither result tells you so.

**Decisions, both now in `rtl/include/ccv_assert.svh`:**

- `CCV_ASSUME_KNOWN` is the required companion to `CCV_ASSERT_KNOWN`. A block
  assumes its control inputs are X-free — which its neighbour asserts — and
  proves its own outputs are. §7's cut-point discipline, applied to X, and the
  halves compose into a whole-design argument one boundary at a time. Verified:
  assume-known inputs plus assert-known outputs proves cleanly.
- The un-reset-payload invariant is stated **structurally, over the valid
  bit**, via `CCV_ASSERT_READ_VALID(name, read_en, valid_bit)` — never over the
  payload's value. This is also just a better property, since it is what §6's
  invariant literally says.

**This changes what Stage 4a writes down.** Each block's reset line (§6) has to
name, for every un-reset payload field, the valid bit that guards it — not
merely which state is un-reset. Without that pairing there is nothing for
`CCV_ASSERT_READ_VALID` to reference, and the formal target cannot be stated.

---

# Second round — the interface checker convention's spike questions

`interface-checker-convention.md` §7 listed five questions of its own, all
Stage 1a's to close. **Four came back as hoped. One did not, and it reverses a
decision in that document.**

## F-9 — `bind` is unusable, and Yosys fails it *silently*

The convention's §4 specified `bind` for connecting checkers: *"RTL stays
readable, checkers stay naturally out of synthesis, and a block's checkers can
be re-bound in different modes for different flows without touching the design
source."* Every one of those reasons is correct. The mechanism is not
available.

| Tool | `bind` |
|---|---|
| Verilator | works |
| Icarus | syntax error **on the `bind` statement** — honest, cheap to find |
| Yosys / `sby` | **parses it, ignores it, garbage-collects the checker** |

Yosys prints `Removing unused module '\chk'`, and BMC then returns PASS on a
property written to be false. **Every standalone block proof in the
convention's §3.1 would have been empty**, green, and indistinguishable from a
real one.

**This was nearly missed, and how is worth recording.** Stage 1a's original
`bind` case (17) put a *labelled concurrent* property inside the checker —
which Icarus and Yosys reject on their own account (F-1). Its `PARSE-FAIL`
cells therefore said nothing about binding at all, and reading them as a
`bind` verdict would have produced the right decision for entirely the wrong
reason, with no idea the Yosys column was hiding a silent drop rather than a
parse error. Case **31** re-asks the question using only the all-three
intersection, and case **32** is the identical checker connected by
instantiation.

**Decision: direct instantiation everywhere, via `` `CCV_CHECKER ``.** Green in
all three tools, and under formal the counterexample names the property through
the instance path — `dut.u_chk.<name>` — which §5's divergence triage needs and
which `bind` silently discards.

**The cost, stated rather than glossed:** `bind` kept checkers out of synthesis
for free. Instantiation does not, and there is no substitute. Synthesis is
deferred by the strategy doc, so this is recorded debt — but it should be
settled before the first synthesis attempt, not discovered there. The
re-binding flexibility *does* survive, through `` `CCV_IF_MODE_IN ``: a
standalone formal run re-roles input checkers to `ASSUME` without the design
source being edited.

Enforced by **CCV-L13**.

## F-10 — a spike case can be confounded, and the methodology has to allow for it

Not a tool finding; a finding about this spike. It is recorded because it will
recur.

Case 17 asked about `bind` and measured something else, because its checker
used constructs two of the three tools reject independently. The verdict looked
decisive and was meaningless. The whole point of the matrix is to distinguish
"the tool cannot do this" from "the tool did not do this", and a case that
varies two things at once cannot do that for either.

**Rule, now applied to every case:** a case may test exactly one construct
outside the known intersection. Anything else it needs must come from the
all-three-usable subset. Where a case genuinely must combine two, it is paired
with a control that isolates the other one — which is what cases 31 and 32 are
to each other, and 34 and 35.

## F-11 — the MODE parameter works, and `ASSUME` genuinely constrains

The convention's §3.1 has one checker per interface type, instantiated as
`ASSERT` on a block's outputs and `ASSUME` on its inputs, so formal cut-points
fall out of the convention rather than being hand-built per block.

The `assert`/`assume`/`cover` keyword cannot be selected by a parameter
directly. A `generate` picks the branch at elaboration, and that works in all
three tools.

More importantly, the `ASSUME` branch **does real work**: spike case 33 returns
`PROVE-PASS` on a property that is false without it, and the negative control
— the same design with the input checker in `ASSERT` mode — returns `FAIL`.
Without that control the PASS would be consistent with the property simply
being true, which is exactly the vacuity F-9 and the §3.3 covers exist to guard
against.

`CCV_CONTRACT_M` implements this so no checker writes the generate by hand, and
**CCV-L15** requires checkers to use it.

## F-12 — packed structs reach the C++ boundary, and their layout must be generated

Confirmed: a struct-typed port surfaces in the Verilated model as one packed
signal.

    VL_OUT64(&iss, 38, 0)      // 39 bits = 1 valid + 32 payload + 6 tag

Decomposable by shift and mask, exactly as the convention's §2 assumes, so the
block-swap boundary works with structs where it refuses interfaces (F-4).

**The consequence the convention did not anticipate:** field *offsets* are not
exposed. The C++ side has to know the layout independently, and a field
reordered in RTL and not in C++ gives a swap harness reading the wrong bits —
which presents as a functional bug, not as a mismatch. That is precisely the
drift §9 names for parameters, arriving at the one boundary §1's swap mechanism
runs across.

So the typedef is **generated into both languages** from
`schema/interfaces.json`, the same way parameters and event ids already are.
The generator also rejects any interface wider than 64 bits, because above that
the Verilated port becomes a word array rather than a single integer and the
generated accessors would quietly be wrong.

## F-13 — DPI works from a checker, and only under Verilator

Event emission from the checker works — the convention's §5 mechanism is sound,
and it is the right place for it: every instance of an interface type then
emits identically, so blocks get no opportunity to drift from the schema.

The convention's Q4 asked about DPI from a *bound* module. Since `bind` is out
(F-9), the question that matters is DPI from an instantiated checker, and that
is answered yes.

**Icarus has no DPI at all.** `import "DPI-C"` is an invalid module item there
in every form tried — `int`, `longint` and `string` arguments alike. It
implements VPI, not DPI. So a checker's emission half is guarded per tool, and
`ccv_trace.svh` is included only where DPI exists, which is what lets the same
checker still compile for the Icarus X-pass **with its properties fully
intact**.

Note what is and is not conditional there. Event emission is not a property;
guarding it removes no obligation from any flow. The convention's rule — and
§7's — is that a property's *presence* must never vary, and it does not.

**What this does cost:** the event stream has exactly one witness. A bug in the
emission path itself cannot be caught by cross-checking two simulators, and
every load-bearing event flows through it. Worth a deliberate test of that path
at Stage 2.

---

## What this settles for Stage 1b

1. Properties are written through macros. Always. Lint enforces it.
2. The macro emits per-tool spellings: label and `else` under Verilator,
   neither under Yosys, no label under Icarus, `$past`-bearing properties
   omitted under Icarus.
3. The runtime knob is a guard signal, not `$assertoff`. Under `FORMAL` it is
   a constant 1, never a free variable.
4. `assert` / `assume` / `cover` are three distinct macros with distinct
   roles, and `assume` is confirmed to do real work under formal.
5. Temporal properties are a second tier, available under Verilator and Yosys
   but not Icarus, and the library must make that boundary explicit at the call
   site rather than hiding it.

## What this hands to later stages

- **Stage 2** — multi-cycle interface contracts need explicit tracking state,
  and liveness must be restated as a bounded-latency property with a justified
  N. (F-2)
- **Stage 1d** — plain ports, not interfaces, and the reason is the swap
  boundary rather than taste. (F-4)
- **Stage 4c** — the Icarus X-pass is not redundant with Verilator's
  X-randomization; they catch different things, and cases 26/28 are the
  standing demonstration. (F-6)
- **Stage 4a** — a block's reset line must pair every un-reset payload field
  with the valid bit that guards it, or §7's third formal target cannot be
  stated at all. (F-8)
- **Stage 2** — per-type checkers carry their own tracking state, because no
  multi-cycle construct exists (F-2). They are things to review, not things to
  read, and the satisfiability covers are what keeps a wrong one from passing
  silently. (F-9, F-11, CCV-L14)
- **Before first synthesis** — checkers are instantiated, not bound, so they
  are no longer excluded from synthesis for free. Recorded debt. (F-9)
