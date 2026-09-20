# RTL-side findings — the Stage 1 review

**Covers:** §8 Stage 1 of [`rtl-execution-strategy.md`](rtl-execution-strategy.md)
— the tooling and schema groundwork, plus four conventions that came out of
using it. Written for the architecture and planning side, so it is organised by
**what the work found about the strategy**, not by what was built.

**Status:** Stage 1 complete and gated. Stage 2 not started, and it is not this
repository's to start — the partition list comes first, and §2 is explicit that
the block names used throughout the strategy doc are illustrative rather than a
proposal.

**Bottom line:** the strategy survives Stage 1 substantially intact. Its
sequencing was right, and front-loading the tool spike paid for itself several
times over. **Six decisions were overturned by measurement**, and one of them —
the formal target in §7 — was going to produce a green result that meant
nothing. Everything below is measured; nothing is argued from documentation.

Detail and evidence for every finding is in
[`stage1a-findings.md`](stage1a-findings.md) (F-1 … F-18); the tool matrix it
rests on is [`stage1a-tool-support.md`](stage1a-tool-support.md), which is
generated.

---

## 1. Six decisions the tools overturned

Each of these is a place the strategy specified a mechanism that does not exist
or does not work on the free stack. In every case there is a replacement, and
in every case the replacement is in the tree and gated.

### 1.1 `$assertoff` is not available anywhere (F-3)

§7 specifies `$assertoff`/`$asserton`/`$assertkill` as the runtime knob, "exactly
the no-recompile knob wanted", and is explicit that `` `ifdef ``-ing properties
out is not an acceptable substitute.

Verilator does not implement them (`Unsupported or unknown PLI call`). Icarus
parses them and has no runtime definition.

**Replacement:** a guard signal ANDed into the property's condition. The
property stays elaborated in every flow; only its ability to fire changes,
which satisfies §7's actual requirement rather than its named mechanism.

**The trap this carries, which is worth the planning side knowing about:** under
`FORMAL` the guard must be a constant. As a free variable the solver sets it to
0 and *every property in the design passes vacuously*, with nothing in the run
looking wrong. There is a permanent regression against exactly that.

### 1.2 SystemVerilog `interface` cannot be a block boundary (F-4)

§9 left this open and hedged toward plain ports. The answer is stronger than a
preference:

```
%Error-UNSUPPORTED: Unsupported: Interfaced port on top level module
```

Interfaces *inside* a block work. §2 makes block boundaries swap boundaries, and
a swap boundary must Verilate as a top-level module — so the one place
interfaces would have paid is the one place they are refused.

**Replacement:** plain ports and packed structs. Packed structs were then
confirmed to reach the C++ boundary correctly (§2.3 below).

### 1.3 `bind` is unusable, and Yosys fails it silently (F-9)

Not from the strategy doc itself but from the interface checker convention,
whose §4 specified `bind` for connecting checkers. The reasons given — RTL stays
readable, checkers stay out of synthesis, modes re-bindable per flow — are all
correct and all unavailable.

| Tool | `bind` |
|---|---|
| Verilator | works |
| Icarus | syntax error on the `bind` statement — honest, cheap |
| Yosys / `sby` | **parses it, ignores it, garbage-collects the checker** |

Yosys prints `Removing unused module '\chk'` and the proof then passes a
property written to be false. **Every standalone block proof would have been
empty**, green, and indistinguishable from a real one.

**Replacement:** direct instantiation, green in all three tools, and the
counterexample keeps the property name through the instance path — which §5
divergence triage needs and which `bind` discards.

**Cost, recorded rather than absorbed:** `bind` kept checkers out of synthesis
for free. Instantiation does not, and there is no substitute. Synthesis is
deferred, so this is debt, but it should be settled before the first synthesis
attempt rather than discovered there.

### 1.4 The third formal target cannot be stated the way §7 implies (F-8)

**The most consequential finding here, because the failure mode is a green
result.**

§7 makes "payload is never read before written" the third formal target, on the
argument that formal "treats uninitialized state as free variables rather than
as whatever value one simulation run produced." The argument is correct. The
natural way to write the property is not.

Two measured facts that pull in opposite directions:

1. **An un-reset register is never X under formal.** It gets a free *two-state*
   value, so `$isunknown(payload)` is identically false and any property built
   on it is vacuously true — **a formal target reported as discharged having
   never been checked**.
2. **An unconstrained module input *is* modelled as possibly-X**, so the same
   macro fails *spuriously* there.

The same construct is vacuously true in one place and spuriously false in
another, and neither result announces itself.

**Replacement:** the invariant is stated structurally, over the valid bit —
which is what §6's invariant literally says anyway. Plus a companion `assume`
on control inputs, composing one boundary at a time.

**This changes what Stage 4a must produce.** A block's reset line (§6) must now
pair *every un-reset payload field with the valid bit that guards it*, not
merely name which state is un-reset. Without that pairing the property cannot be
written at all.

### 1.5 Verible is not needed, and the dependency was poorly motivated (F-5)

§6 adds Verible as a fourth tool and says "lint enforces it" is load-bearing for
the whole X-safety approach. The second part is right and the flow depends on
it; the fourth tool is not.

The central rule — no bare `if`/`case` on control without a paired `$isunknown`
assert — is a *relationship between two constructs*, which stock Verible rules
do not express. Custom rules would have had to be written against its API
regardless, so the trade was a heavyweight dependency in exchange for nothing.

**Replacement:** a project lint layer (25 rules), with Verilator's `--lint-only`
carrying the generic checks it already does well. §6's "this adds a fourth tool"
is **retracted**.

### 1.6 The X-aware mux primitives are optional (F-16)

§6 lists "X-aware mux primitives for data paths where propagation is genuinely
wanted, so it's a called function rather than per-instance discipline" as a rule
to encode.

They are not needed. **The ternary operator is already X-pessimistic in the
LRM** — it produces exactly what VCS calls `tmerge`, with no tool mode, no
pragma and no primitive, and it narrows correctly when only *part* of the
selector is unknown.

| Construct | `sel=xx` | `sel=1x` |
|---|---|---|
| `if`-chain | `1101` — the **last** branch | `1101` |
| ternary | `11xx` | `110x` |
| `case` + X-default | `xxxx` | `xxxx` |
| `casex` | `1100` — **silently matched branch 0** | `1100` |

Two corrections to §6's framing fall out. An `if`-chain does not "take the false
branch" — it falls through to the *last* branch, so there is no
suspicious-looking branch to notice. And `casex` is not merely optimistic but
*arbitrary*; it is banned outright.

---

## 2. What was confirmed, and can now be relied on

Shorter, but load-bearing: these are the mechanisms the rest of the plan is
built on, and they are no longer assumptions.

### 2.1 Formal cut-points work (F-11)

§7's `assume`-as-cut-point — black-box a neighbour, assume its contract, prove
the rest — genuinely constrains a `sby` proof rather than merely elaborating.
Confirmed with a negative control, which matters: without one, a PASS is
consistent with the property simply being true.

**This was the load-bearing question for §7's entire lean-into-formal posture**,
and it survives even though the usable SVA subset turned out to be very thin.

### 2.2 The event schema mechanism works end to end (§1, Stage 1c)

Schema → generated C++ and SV headers → DPI-C from a SystemVerilog module →
binary trace → Perfetto JSON, all gated. §8's warning that a C++-only emit API
would need a retrofit at 4c was worth heeding; the path is exercised now.

### 2.3 Packed structs reach the C++ swap boundary (F-12)

A struct-typed port surfaces as one packed signal, `VL_OUT64(&iss, 38, 0)`,
decomposable by shift and mask. §1's block-swap mechanism works with structs
where it refuses interfaces.

**One consequence the convention did not anticipate:** field *offsets* are not
exposed, so the C++ side must know the layout independently, and a field
reordered on one side gives a harness reading the wrong bits — a functional bug,
not a mismatch. The typedef is therefore generated into both languages.

### 2.4 Verilator's X-randomization works (F-6)

§6 asked for this to be confirmed rather than assumed. Confirmed, with the flags
recorded. Two distinct traces across four seeds on an un-reset control bit.

---

## 3. New constraints that land on later stages

These are not corrections; they are scope the strategy does not currently
account for.

### 3.1 Stage 2 — no multi-cycle SVA exists anywhere (F-2)

Not `##n`, not `sequence`, not `throughout`, not property local variables, not
`s_eventually` — in **any** of the three tools, Verilator included.

Two consequences for the interface grill-me:

- **A request-to-response contract is an explicit tracking register plus a
  boolean property.** The checker carries its own state, so it is a thing to
  review rather than a thing to read, and it can itself be wrong.
- **Liveness cannot be stated at all.** "A request is eventually answered"
  becomes *a request outstanding for more than N cycles is a failure* — strictly
  weaker, since it bounds the wait rather than proving deadlock freedom, and
  **N is a number that must be justified per interface**.

That second point is a real addition to Stage 2's output, not a detail.

### 3.2 Stage 4a — the reset line grows an obligation (F-8)

See §1.4. Every un-reset payload field must be paired with its guarding valid
bit.

### 3.3 Stage 4c — the X-pass is the sole witness (F-16)

Verilator is 2-state. Under formal an un-reset register is a free two-state
value, so `$isunknown` is dead there. **Icarus is the only tool in the flow that
observes X at all.**

§6 already pulls the X-pass forward to per-block 4c; this makes it load-bearing
rather than supplementary. It is also the argument for prohibition being the
primary X mechanism over propagation: an assertion fires under Icarus *and*
proves under formal, while propagation is checkable in one place only.

### 3.4 The event stream also has one witness (F-13)

DPI is Verilator-only — Icarus has no DPI at all. Emission cannot be
cross-checked between two simulators, and every load-bearing event flows through
it. Worth a deliberate test of that path at Stage 2.

---

## 4. Open items for the planning side

**Carried from the strategy doc, with changed status:**

- **Open item 4 — the correlation criterion for arbitration-sensitive events —
  is now more urgent than the doc implies.** It notes this "wants settling
  before Stage 1c locks the schema". Stage 1c has shipped. The schema records
  the criterion as OPEN and carries no tolerance metadata; if the answer is a
  stated tolerance rather than exact match, the schema needs a field and its
  hash changes. **Settle before Stage 4a populates the first
  arbitration-sensitive events** — that is the last cheap moment.
- **Is 25 NGD the Vmin-corner number or a nominal one?** (§2) Unchanged, and
  still Stage 2's.

**Opened by Stage 1:**

- **The stage tag gives each block one letter, so ~24 blocks.** If the Stage 2
  partition exceeds that, the tag format widens and every tagged net changes.
  Nearly free to check now against a draft block list; expensive later.
- **A justified N per interface**, from §3.1 above.
- **Synthesis exclusion for checkers**, from §1.3.
- **Clock-gating equivalence is unverified.** The gated netlist has never been
  proved against its ungated original. Nothing relies on it — synthesis is
  deferred — but settle it before any synthesis result is believed.

---

## 5. What Stage 2 needs from the planning side

In dependency order. Once these exist, the repository-side work is mechanical,
and more of it is in place than the stage numbering suggests.

1. **The partition list**, closed — §8 Stage 2's stated first job. Everything
   downstream is shaped by it; the unit list in the event schema is currently
   the strategy doc's own illustrative names, carried only so the mechanism has
   something to exercise.
2. **A block letter per block**, for the net-naming stage tag. Check the count
   against §4's 24-block ceiling while the list is being drafted.
3. **Per-block interface contracts** — signals, protocol, what each block
   consumes and produces — with the F-2 caveat that multi-cycle properties need
   explicit tracking state and a justified N.
4. **Per-block interface NGD budgets** against the 25 NGD envelope.

Each interface then becomes a schema entry, a checker following the reference
one, and an instantiation at each boundary. Lint fails if a typedef has no
checker or a control field goes unreferenced, so the list and the checkers
cannot drift apart.

---

## 6. Two corrections to the strategy doc's own text

- **`ccg-sim` is `ccv-sim`.** The target was renamed from CCG to CCV at the v1.5
  audit; the strategy doc predates it. The functional oracle is
  `custom-cuda-complier/tools/ccv-sim`.
- **Stage 1 has four numbered items and four conventions.** The interface
  checker convention, X-determinism, net naming and clock gating all came out of
  *using* 1a–1d and are enforced alongside them. §9 anticipates some of this;
  the planning side may want to fold the rest into §8 Stage 1d so the stage
  boundary matches what is actually there.

---

## 7. A note on method, since it changed several answers

Every spike case is written so that a **deliberately violated** property must
fire, and a cell that compiles and stays silent is scored *worse* than one that
fails to parse. That polarity is what caught the `bind` result: a property that
elaborates and never fires is indistinguishable from a property that passes.

It also nearly failed. The original `bind` case put a labelled concurrent
property inside the checker, which two of the three tools reject on their own
account — so its `PARSE-FAIL` cells said nothing about binding, and reading them
as a verdict would have reached the right decision for entirely the wrong
reason, with no idea a silent drop was hiding underneath. The rule now is that
**a case may test exactly one construct outside the known-usable subset**, or it
is paired with a control that isolates the other.

The same discipline produced the pair that makes §3.3 of the interface
convention executable: one case demonstrates a contradictory `assume` set
passing `assert (1'b0)`, and its partner shows the satisfiability cover catching
it. Both are permanent regressions, so the argument is a live check rather than
a paragraph.
