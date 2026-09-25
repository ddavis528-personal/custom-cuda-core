# Interface Typedef and Checker Convention — v1

**Status:** v1 as written was a draft pending the Stage 1a spike questions in §7. **Those are now closed** — see `stage1a-findings.md` F-9 … F-13 and the matrix in `stage1a-tool-support.md`. Four of the five answers were as hoped; **one was not, and it changes §4**. The affected sections below carry an inline **ANSWERED** note rather than being silently rewritten, so the original reasoning and what the tools actually did stay side by side.

Scheduled as part of §8 Stage 1d in `rtl-execution-strategy.md` (coding style guide and lint rules), with the per-type checkers themselves authored at Stage 2 alongside the interface-level grill-me.

**Scope:** How block interfaces are declared, how their protocol checkers are built and bound, and how the same checker serves simulation, formal, and event emission. This is the detailed spec for a convention summarized in §9 of the strategy doc; where the two disagree, this document is the more current one.

**Dependencies:** several mechanisms here rested on tool behaviour that is now confirmed. See *Spike questions* at the end for the answers.

**The one thing that changed:** `bind` is unusable, so §4's connection strategy becomes direct instantiation. Everything else in this document survives the spike intact.

---

## 1. Why this exists

Three otherwise-separate pieces of work turn out to be the same artifact:

1. **Interface assertions** — the properties every block boundary must obey (strategy doc §7, interface wave).
2. **Formal cut-points** — the `assume` constraints that make standalone block-level proofs tractable by black-boxing neighbors (§7).
3. **RTL-side event emission** — the load-bearing event class is interface-defined by construction; decode, dispatch, retire, and memory request/response *are* interface transactions (§1).

All three are observations of the same thing: traffic crossing a block boundary. Writing them once, per interface *type*, rather than once per boundary instance, means fewer artifacts, and consistency by construction rather than by discipline.

---

## 2. Interface declaration style

**Packed structs, not SystemVerilog `interface` constructs.**

`interface` is the more elegant answer — single point of definition, modport-enforced direction, and the ability to carry assertions inside the interface itself. It is rejected here for tooling reasons, not design ones: Verilator's support has historically had gaps, Yosys/`sby` frontend support is weaker still, and interface-borne signals complicate the C++ boundary that the block-swap mechanism (strategy doc §1) depends on. That is three of four tools carrying question marks on a construct that would sit at every block boundary.

A packed struct keeps the define-once benefit and is a plain bit vector at the module boundary, so Verilator presents it as one wide signal the C++ harness decomposes.

> **ANSWERED (spike Q3, finding F-12) — confirmed, with one consequence.**
> A struct-typed port surfaces in the generated C++ model as a single packed
> signal: `VL_OUT64(&iss, 38, 0)` for the `issue_t` below — 39 bits, decomposable
> by shift and mask. The block-swap boundary works as this section assumes.
>
> The consequence is that **field offsets are not exposed**. The C++ side has to
> know the layout independently, which is a drift risk of exactly the kind §9 of
> the strategy doc names for parameters: a struct field reordered in RTL and not
> in C++ gives a swap harness that reads the wrong bits and looks like a
> functional bug. So the typedef is **generated into both languages from one
> source** (`schema/interfaces.json`), the same way parameters and event ids
> already are. That is an addition to this section, not a correction of it.
>
> The rejection of `interface` is independently confirmed: Verilator reports
> `Unsupported: Interfaced port on top level module` (F-4). The construct fails
> at precisely the boundary block-swap needs.

```systemverilog
// issue_if.svh — typedef and checker live in one file, per §4
typedef struct packed {
  logic        valid;
  logic [31:0] payload;
  logic [5:0]  tag;
} issue_t;

module issue_queue (
  input  logic   clk,
  input  logic   rst_n,
  output issue_t iss,
  input  logic   iss_ready    // backpressure rides separately
);
```

**What is given up, and how it is recovered:**

| Lost with structs | Recovered by |
|---|---|
| Modport-enforced direction | Lint rules (§9 of strategy doc) plus checker direction properties |
| Interface-resident assertions | The bound checker module, below |
| Bundled backpressure | Convention: a separate `_ready` signal, or a reverse-direction struct for wider return paths |

---

## 3. The checker module

**Every interface typedef has exactly one associated checker module.** No typedef may exist without one; lint enforces this.

```systemverilog
module ccv_credit_checker #(
  parameter mode_e MODE = ASSERT
) (
  input logic   clk,
  input logic   rst_n,
  input issue_t iss,
  input logic   iss_ready
);
  // properties instantiated through the Stage 1b primitive library,
  // which resolves MODE into assert / assume / cover form
endmodule
```

### 3.1 Mode parameter

The same checker serves opposite roles depending on where it is instantiated. This is what makes formal cut-points fall out of the convention rather than being hand-built per block.

| MODE | Where | Meaning |
|---|---|---|
| `ASSERT` | On a block's **output** interface | This block must obey the protocol. Checked in simulation, proved in formal. |
| `ASSUME` | On a block's **input** interface, during standalone block-level formal | Constrains the environment so the prover does not explore illegal input sequences. |
| `COVER_ONLY` | Where neither obligation nor constraint is wanted | Reachability and event emission only. |

The mode resolution lives in the Stage 1b primitive library, not in each checker — so the `assert`/`assume`/`cover` role split is implemented once and every checker inherits it.

> **SUPERSEDED BY THE CLOSED PARTITION (2026-09-23).** The sketch above is
> per-interface-type. The block-level grill-me made every one of the 40
> boundaries (41 since the external port became a pair) obey identical conventions -- credited, registered both sides,
> valid one cycle ahead -- so the protocol properties are the same everywhere
> and only widths differ. There is therefore **one** checker,
> `rtl/if/ccv_credit_checker.sv`, parameterised by payload width and round
> trip, not one per type. Everything below about modes, satisfiability covers
> and emission holds unchanged; it simply applies to one module.
>
> **Since (Stage 3).** Two more checkers exist, but not per type:
> `ccv_atomic_checker` looks across a channel's slots, and
> `ccv_lockstep_checker` across the 32 lane instances. The credit checker is
> instantiated once per slot, 340 times.
>
> **ANSWERED (spike Q2, finding F-11) — confirmed, and the mechanism is a `generate`.**
> The `assert`/`assume`/`cover` keyword cannot be selected by a parameter
> directly; a `generate` picks the branch at elaboration. That works in all
> three tools, and `CCV_CONTRACT_M` in the 1b library implements it so no
> checker writes the generate by hand.
>
> Crucially, the `ASSUME` mode **genuinely constrains a `sby` proof** rather than
> merely elaborating — spike case 33 returns `PROVE-PASS` on a property that is
> false without it. The negative control (input checker in `ASSERT` mode
> instead) returns `FAIL`, which is what makes the `PASS` meaningful rather than
> trivially true. This section's cut-point strategy stands.

### 3.2 Property content

Generic protocol properties belong in every checker:

- `valid` stability — held until accepted, not withdrawn
- Payload and tag stability while stalled
- No `valid` asserted during or immediately after reset
- Tag uniqueness among in-flight transactions, and in-flight count within its bound
- `$isunknown` checks on all control fields — this is where the X-safety posture (strategy doc §6) is enforced at boundaries, since control X is prohibited rather than propagated

Type-specific properties are added per interface: ordering guarantees, credit accounting, response-to-request matching.

> **ANSWERED (spike Q5, finding F-2) — and this is the section it costs most.**
> No multi-cycle sequence construct works in ANY of the three tools: not `##n`,
> not `sequence`, not `throughout`, not property local variables, not
> `s_eventually`. Verilator alone takes `$past` and simple `|->` / `|=>`, and
> Yosys and Icarus take neither.
>
> Most properties listed above are temporal, so **they cannot be written as
> stated.** Each becomes an explicit history or tracking register plus a boolean
> property over it:
>
> | Property | As written | As it must be built |
> |---|---|---|
> | `valid` held until accepted | `valid && !ready \|=> valid` | a `was_stalled` register, plus a boolean property over it |
> | payload stable while stalled | `$stable(payload) throughout ...` | shadow-copy the payload on stall, compare |
> | tag uniqueness in flight | set membership over time | an in-flight scoreboard register, one bit per tag |
> | in-flight count within bound | — | an explicit counter, plus a boolean bound check |
> | no `valid` during/after reset | `$past(rst) \|-> !valid` | a registered `rst_q`, plus a boolean property |
>
> The checker therefore **carries its own state**, which makes it a thing to
> review rather than a thing to read, and makes CCV-L14's requirement that every
> checker be exercised by its own covers more than a formality.
>
> One property in §3.2 is unaffected and worth noting for it: the `$isunknown`
> checks on control fields are boolean, so the X-safety posture crosses
> boundaries exactly as this section intends. Pair them with `CCV_ASSUME_KNOWN`
> on the input side — under formal an unconstrained input is modelled as
> possibly-X and the assert alone fails spuriously (F-8).

### 3.3 Satisfiability covers — mandatory, not optional

**Every checker carries `cover` properties demonstrating its assumption set is satisfiable, and these must run alongside any proof that relies on it.**

An internally contradictory `assume` set makes every proof depending on it vacuously true, and it fails *silently* — the proof passes, reports no counterexample, and means nothing. This is the single most dangerous failure mode in the whole formal strategy, because it produces false confidence rather than a visible error. The covers are the guard, and they are why the `cover` role exists in the primitive library at all.

> **DEMONSTRATED, not merely argued.** Spike cases 34 and 35 are this section
> made executable, and they stay in the regression permanently.
>
> Case 34 carries a contradictory assume set and `assert (1'b0)` — a property
> that cannot hold under any circumstances. BMC returns **PASS**. There is no
> counterexample, no warning, and nothing in the output distinguishes it from a
> real proof.
>
> Case 35 is the same assume set with a `cover` asking whether the assumed state
> is reachable at all. It returns **COVER-MISS** — the guard firing.
>
> `tools/check-1a.sh` fails if either stops behaving this way, so the pair is a
> live check on the argument rather than a historical note.

---

## 4. File organization and binding

- **One file per interface type**, containing the typedef and its checker. They version together; a field added to the struct and not to the checker is a lint failure.
- ~~**Connection via `bind`**, not instantiation inside design modules.~~
  **REVERSED (spike Q1, finding F-9).** See below.

  The original reasoning — RTL stays readable, checkers stay naturally out of
  synthesis, and a block's checkers can be re-bound in different modes for
  different flows without touching the design source — is all correct and all
  still desirable. It is simply not available.

> **ANSWERED (spike Q1, finding F-9) — `bind` is unusable, and its failure mode
> is the dangerous one.**
>
> | Tool | `bind` |
> |---|---|
> | Verilator | works |
> | Icarus | syntax error on the `bind` statement — honest, and cheap |
> | Yosys / `sby` | **parses it, ignores it, and garbage-collects the checker** |
>
> Yosys emits `Removing unused module '\chk'` and the proof then passes a
> property written to be false. That is not a missing feature you find in five
> seconds; it is a formal run that is green because the properties were never
> there. Every standalone block proof in §3.1 would have been empty, and nothing
> about the output would have said so.
>
> This was nearly missed. Stage 1a's original `bind` case used a labelled
> concurrent property in the checker, which Icarus and Yosys reject on their own
> account — so its `PARSE-FAIL` cells said nothing about binding at all. Spike
> case 31 re-asks the question using only the all-three intersection, and case 32
> is the same checker and the same property connected by instantiation.
>
> **Decision: direct instantiation, in all tools, via `` `CCV_BIND_CHECKER ``.**
> Green in all three (case 32), and under formal the counterexample names the
> property through the instance path — `dut.u_chk.<name>` — which §5 divergence
> triage needs and which the `bind` path silently loses.
>
> **What this costs, stated plainly.** A checker instance now appears in the
> design source, so the clean separation this section wanted is not free. Three
> mitigations, none of which fully replace it:
>
> 1. The instance is one macro line, placed by convention at the end of the
>    module, so the readability cost is small and uniform.
> 2. The macro takes the mode as an argument, so the re-binding flexibility
>    survives: a block's standalone formal run overrides its input-side
>    checkers to `ASSUME` through `` `CCV_IF_MODE_OVERRIDE ``, still without
>    editing the design source.
> 3. Synthesis exclusion is handled by the macro rather than by `bind`'s
>    natural exclusion. Synthesis is deferred (strategy doc §6 resolved scope
>    decisions), so this is a recorded consequence rather than a present cost —
>    but it is a real one to pay later, and it is the part of `bind` that has no
>    substitute.
>
> `bind` remains available and is used for Verilator-only instrumentation, where
> nothing is lost by it. It is banned at design boundaries by **CCV-L13**.
- **Never `` `ifdef `` checkers out.** Assertions stay elaborated; the runtime
  knob controls firing. Compiling them out would remove the properties from what
  formal tools see in the same source, defeating the point of one property set
  serving both flows.

> **Two amendments, neither weakening the rule.**
>
> **The knob is not `$assertoff` (F-3).** It does not exist on this stack —
> Verilator reports `Unsupported or unknown PLI call`, Icarus parses it and has
> no runtime definition. The substitute is a guard signal ANDed into the
> property's condition, which satisfies this rule exactly: the property stays
> elaborated everywhere and only its ability to fire changes. Under `FORMAL` the
> guard is a `localparam` tied to 1 — a free variable there would let the solver
> choose 0 and pass every property in the design vacuously, which is case 34's
> failure mode arriving through the back door.
>
> **Two things in a checker ARE conditional, and the distinction is the whole
> point of this rule.** What must never vary is a property's PRESENCE. What may
> vary is its SPELLING, and whether non-property code compiles:
>
> - *Spelling* — labels and `else` clauses differ per tool because no two of the
>   three accept the same dialect (F-1). The 1b library is the only place this
>   happens.
> - *Emission* — DPI is Verilator-only (F-13), so a checker's emission half is
>   guarded so the same checker still compiles for the Icarus X-pass. Event
>   emission is not a property; guarding it removes no obligation from any flow.
>
> Varying spelling or emission preserves this rule. Varying presence destroys
> it. **CCV-L13** enforces the boundary.

---

## 5. Event emission

The checker already observes every transaction crossing its interface, so it is the natural emitter for the RTL side of the event stream.

- Emission goes through the DPI-C path into the shared event library (strategy doc Stage 1c).
- Because emission lives in the per-type checker, **every instance of an interface type emits identically**. Blocks are not instrumented individually, so there is no per-block opportunity to drift from the schema — which is the failure mode that would quietly corrupt correlation.
- This covers the **load-bearing** event class only. Arbitration-sensitive events are internals-defined and are emitted from inside each block, enumerated per block at Stage 4a.

> **ANSWERED (spike Q4, finding F-13) — works, and it is Verilator-only.**
>
> DPI-C from an instantiated checker works: spike verification emitted three
> events for three active cycles into the shared library, through the same
> `ccv_trace_emit` the C++ timing model writes through. Q4 asked about DPI from
> a *bound* module; since `bind` is out (F-9), the question that matters is this
> one, and it is answered.
>
> **Icarus has no DPI at all** — `import "DPI-C"` is an invalid module item in
> every form tried, int, longint and string alike. It implements VPI, not DPI.
> So a checker's emission half is guarded per tool, and the same checker still
> compiles for the Icarus X-pass with its properties fully intact.
>
> This costs nothing real. The X-pass asks about X propagation, not about event
> streams, and correlation runs happen under Verilator by §6 of the strategy
> doc. It does mean **the event stream cannot be cross-checked between two
> simulators**, so a bug in the emission path itself has only one witness.

---

## 6. Cost and control

Checkers bound at every interface everywhere are not free in simulation.

The `$assertoff` runtime knob (Stage 1b) is the control: full checking during block bring-up, correlation runs, and CI gates; selectively disabled for high-volume regression where throughput dominates. The knob is hierarchical, so disabling by scope rather than globally is the normal case.

Event emission needs its own control, separate from assertion firing — a correlation run wants events on, a throughput regression wants them off, and those are not the same switch as protocol checking.

---

## 7. Spike questions (Stage 1a) — all closed

| # | Question | Answer | Finding | Evidence |
|---|---|---|---|---|
| 1 | `bind` support across the three tools | **NO** — Verilator only, and Yosys drops it *silently* | F-9 | cases 31, 32 |
| 2 | Does `ASSUME` really constrain a `sby` proof? | **YES**, via `generate`; negative control confirms | F-11 | case 33 |
| 3 | Packed struct at the Verilator C++ boundary | **YES** — one packed signal, `VL_OUT64(&iss,38,0)` | F-12 | probe |
| 4 | DPI-C from a checker | **YES**, and Verilator-only — Icarus has no DPI | F-13 | probe |
| 5 | Concurrent/temporal SVA subset | **Almost none.** No multi-cycle construct in any tool | F-2 | cases 04–12, 19–24 |

Four of five as hoped. **Q1 was not**, and it is the one that changes a
decision: §4's binding strategy becomes direct instantiation.

Q5's answer was already known from the Stage 1a spike proper and is the one
with the widest blast radius on this document — §3.2's property list has to be
rebuilt around explicit tracking state, and that lands on Stage 2 when the
per-type checkers are written.

The two questions the spike raised that this document had not asked:

6. **Does the mode mechanism survive in simulation as well as formal?** Yes —
   case 33 is green in all three tools, so one checker source serves the
   simulation regression, the X-pass and the proof.
7. **Can the vacuity guard in §3.3 actually detect a contradictory assume
   set?** Yes — case 35 returns `COVER-MISS` where case 34's proof returns a
   meaningless `PASS`. The argument in §3.3 is now executable.

---

## 8. Open items

- **Direction discipline without modports.** Packed structs give no direction
  enforcement. *Partly addressed:* CCV-L12 requires every interface typedef to
  declare its direction discipline in `schema/interfaces.json`, and the
  generated header carries it, so a port declared against the wrong direction is
  a generated-code mismatch rather than a silent miswiring. Whether that is
  *adequate* is still open and will not be known until several real interfaces
  exist at Stage 2.

  > **Since:** 41 exist, and the S1 stubs are built against them, but no
  > block has yet been written by hand against a generated port list. The
  > question is re-asked at the end of Stage 3 (`roadmap.md` Part 3,
  > item 15).
- **Backpressure convention.** Separate `_ready` signal versus reverse-direction
  struct. *Provisionally decided* in favour of the separate `_ready`, on the
  strength of F-12: the struct surfaces at the C++ boundary as one packed
  signal, so folding backpressure into it would put a reverse-direction field
  inside a signal the swap harness drives in one direction. Wide return paths
  get their own reverse-direction struct, which is the doc's own second option
  applied per direction rather than per interface. Revisit at Stage 2 with real
  interfaces in hand.

  > **SETTLED at Stage 2, and not as guessed.** The grill-me chose a
  > **credited protocol**: `_valid` and `_payload` from the producer,
  > `_credit` and `_stall` from the consumer. The F-12 reasoning survives:
  > backpressure stays outside the packed struct, so the swap harness still
  > drives the payload one way.
- **Checker reuse across block-swap.** Still open, and F-12 sharpens it. The
  struct's field offsets are not exposed at the C++ boundary, so the swap
  harness already needs a generated view of the layout —
  `schema/interfaces.json` now produces one. That makes "generated from a shared
  definition" the cheapest of the three options this item lists, since half the
  generator exists. It still interacts with the unresolved 4d correlation
  criterion, and is not decided here.

  > **ANSWERED at Stage 3: the SV checker itself.** The C++ skeleton
  > Verilates `ccv_skel_checkers`, the bank of real checkers, rather than
  > porting them. So a C++ stub and a swapped-in RTL block are judged by
  > identical logic, and `EV_CH_XFER` comes from identical code on both sides
  > (`skeleton.md`, decision 3).

### Opened by the spike

- **Synthesis exclusion has no substitute now that `bind` is out.** `bind` kept
  checkers naturally out of synthesis; instantiation does not. Synthesis is
  deferred by the strategy doc, so this is a recorded debt rather than a present
  cost — but it is real, and it should be settled before the first synthesis
  attempt rather than discovered there.

  > **Mechanism in place:** the SV top instantiates checkers only under
  > `CCV_CHECK`, and Yosys is asked both ways that the synthesis view has none.
  > The same rule inside real block RTL is still to do, at 4c.
- **The event emission path has one witness.** DPI is Verilator-only (F-13), so
  a bug in emission itself cannot be caught by cross-checking two simulators.
  Worth a deliberate test of the emission path at Stage 2, since every
  load-bearing event in §5 flows through it.

  > **Since:** the skeleton gives the path a second witness. Every
  > `EV_CH_XFER` the Verilated bank emits is compared, as an exact multiset
  > over channel, payload bits and identity, with what the senders launched.
