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
