# RTL coding style

**§8 Stage 1d.** Written before the first line of design RTL exists, because
§9 is right that retrofitting style across built blocks is the expensive path
and rules added late mostly generate backlog rather than catching bugs.

Enforced by `tools/lint-rtl.py`, not by discipline. Every rule below carries
its lint id, and `tools/check-1d.sh` fails if a rule exists without a
counter-example in `rtl/lint/bad_module.sv` or without a paragraph here — so
the guide, the linter and the fixture cannot drift apart.

Most of this is ordinary discipline. §9 flags two parts as **load-bearing**:
they hold up machinery this project depends on, and getting them wrong costs
more than style violations normally do. Those are marked.

---

## Enforcement, and what enforces what

Three layers, deliberately not one:

| Layer | Covers | Why not the others |
|---|---|---|
| `tools/lint-rtl.py` | CCV-L01 … CCV-L11 below | Project rules. The central one (CCV-L08) is a *relationship* between a case selector and an assertion elsewhere in the file, which no stock rule set expresses. |
| `verilator --lint-only` | width mismatches, inferred latches, unused and undriven signals, unsupported constructs | Already excellent at these. Reimplementing them would be strictly worse. |
| The three tools themselves | anything that fails to parse | The tool-support intersection is narrow (Stage 1a), so "it compiles everywhere" is a real check, not a formality. |

**On Verible.** §6 adds it as a fourth tool and says "lint enforces it" is
load-bearing for the whole X-safety approach. That second part is right and
this guide depends on it; the fourth tool is not. Stage 1a found Verible
unobtainable here and, more to the point, found the dependency poorly
motivated: CCV-L08 was never expressible in stock rules, so custom rules would
have had to be written against Verible's API regardless. The rules are the
artifact; the tool is an implementation detail. See finding F-5.

### Scopes

Not every rule applies to every file, and pretending otherwise is how a lint
layer gets switched off wholesale.

- **design** — `rtl/`, excluding `include/`, `generated/` and `lint/`.
  Everything applies.
- **tb** — `test/`, `spike/tb/`. `initial` blocks, delays and DPI imports are
  what testbenches are *for*.
- **probe** — `spike/cases/`. Tool probes whose job is to write deliberately
  non-portable assertions and find out what each tool does with them. Linting
  them for style would be linting the measurement instrument. Only CCV-L10
  applies, because a metacomment collision breaks the probe itself.

A single file may opt out:

    // ccv-lint: exempt CCV-L03 -- <why>

The reason is required. An exemption without one is a rule quietly disabled,
which is worse than no rule at all because it still looks enforced.

---

## Load-bearing: names and parameters are cross-language artifacts

§9: every signal and structure exists twice, once in the C++ timing model and
once in RTL, and §5 correlation diffs them against each other.

### Naming must be mechanically consistent across both

A signal that is `iq_issue_valid` in RTL and `issueValid` in the model imposes
a translation tax on every 4d debug session, permanently.

*Mechanically consistent* is not the same as *identical*. Each language keeps
its own idiom; what has to be total and reversible is the **mapping**:

| Artifact | RTL | C++ |
|---|---|---|
| parameter | `CCV_ROB_ENTRIES` | `ccv::kRobEntries` |
| event id | `CCV_EV_DECODE` | `ccv::EV_DECODE` |
| signal | `iq_issue_valid` | `iq_issue_valid` |

Signals keep `lower_snake_case` in both, so no mapping is needed at all for
the things §5 diffs most often. Parameters and event ids are generated
(below), so their mapping is applied by a script rather than by whoever writes
the next block.

Event schema **field names** are covered by this rule too, per §9. They live
in `schema/events.json` and reach both languages from there.

### Parameters need a single source of truth — a mechanism, not a convention

§9 is explicit that this is a mechanism decision. The reason is specific: ROB
depth exists as a swept knob in the timing model (Stage 4b) *and* as an RTL
parameter, nothing otherwise prevents them from drifting, and drift means a
correlation run silently comparing two differently-sized machines — a failure
that presents as a timing bug.

`params/ccv_params.json` is the source. `tools/gen-params.py` generates both
`sim/generated/ccv_params.h` and `rtl/generated/ccv_params_pkg.sv`.
`tools/verify.sh` fails if either is stale, and `tools/check-1d.sh` compares
the *values* in both languages against the source — which is the check that
would actually catch the failure §9 describes.

**Never write a structural constant in RTL or in the model.** Add it to the
source and regenerate.

Parameters carry a `status`, and the distinction matters as much as the value:

- `isa` — follows from the locked ISA. **Not ours to sweep**; the compiler
  already depends on it.
- `provisional` — a placeholder awaiting the stage named in `decided_at`
  (Stage 4a sizes it, 4b sweeps it).
- `target` — a physical target such as the 25 NGD envelope, not a structure
  size.

A sweep that varies an `isa` parameter is varying something the compiler is
built against. The status field is what makes that visible.

## Load-bearing: interface style constrains block-swap feasibility

**Settled, and not by preference.** §9 left this open, hedging toward plain
ports as the "safer default". Stage 1a closed it (finding F-4):

    %Error-UNSUPPORTED: Unsupported: Interfaced port on top level module

§2 makes block boundaries swap boundaries, and §1's swap mechanism requires a
hand-written C++ timing-model block and a Verilated RTL block to sit behind
the same interface in one executable — which means the boundary must Verilate
as a top-level module. SystemVerilog interfaces are refused at exactly that
boundary. Interfaces *inside* a block do work, but the one place they would
have paid is the one place they cannot be used.

**Rule (CCV-L09): plain ports, with consistent suffix conventions.** Packed
structs are fine and worth using where a boundary carries many related
signals — a struct port does Verilate. The `interface`/`modport` construct
does not.

Suffix convention for a ready/valid boundary, so that instantiation and the
swap harness stay mechanical:

    <peer>_<signal>_valid     producer asserts, data is valid this cycle
    <peer>_<signal>_ready     consumer asserts, will accept this cycle
    <peer>_<signal>_<field>   the payload itself

---

## The rules

### CCV-L01 — one module per file, filename matches module name

Required by build automation and assumed by most lint tooling. Also what makes
a block's file findable from a waveform hierarchy without a search.

### CCV-L02 — clock and reset ports are `clk` and `rst`, in every module

§9 asks for this so instantiation and the swap harness are mechanical. The
single-clock, global-synchronous-reset decision (§6) makes it reasonable:
there is one clock and one reset, so there is nothing to disambiguate.

`rst` is **active high and synchronous**. The assertion macros reference `clk`
and `rst` by these names and are unusable in a module that spells them
differently.

*Revisit trigger:* multiple **frequency** domains (§6). Clock gating for power
does not reopen it.

### CCV-L03 — no `initial` blocks and no delays in design RTL

Reset behaviour comes from the synchronous reset. `initial` for state is not
synthesizable intent, and it hides the reset-vs-un-reset decision that §6
requires each block to make explicitly at Stage 4a.

Testbenches and instrumentation are exempt — that is what they are for.

### CCV-L04 — `<=` in sequential logic, `=` in combinational

Ordinary discipline, worth enforcing because the failure is a race that
reproduces intermittently and differently per simulator. Use `always_ff` and
`always_comb` rather than bare `always @`, so the tool checks the intent too.

No inferred latches — left to `verilator --lint-only`, which already detects
them precisely.

### CCV-L05 — no bare `assert` / `assume` / `cover`

Everything goes through the Stage 1b macros in `rtl/include/ccv_assert.svh`.

This is not a formatting preference. Stage 1a finding F-1: the three tools
accept three different dialects and no two overlap — Icarus rejects assertion
labels, Yosys rejects the `else` action block, Icarus rejects `$past`. A
hand-written property is broken in at least one tool, and in the worst case
silently.

### CCV-L06 — no DPI imports in design RTL

Event instrumentation is bound to a block from outside it, never written into
it. A DPI import in a design module is not synthesizable, and §9's argument for
preferring `bind` for assertions applies here with more force.

### CCV-L07 — every `case` has a `default`, and an unreachable one assigns `'x`

§6's first listed X-safety rule: explicit X-injection for unreachable states,
rather than the implicit hold that squashes the bug.

    default: state_d = 'x;    // loud
    // (no default)           // silently holds, and the bug survives

### CCV-L08 — a case selector needs a paired `CCV_ASSERT_KNOWN`

**§6's central rule, and the highest-payoff one in this guide.**

The move is to *prohibit* X on control rather than propagate it. `if (x)`
silently takes the false branch in every 4-state simulator — that is the LRM's
own X-optimism, not a tool defect — so X on a control signal is invisible
unless something asks. This asks.

It works in every tool regardless of X-propagation fidelity, it is formally
provable, and it reuses the §7 assertion machinery instead of being a parallel
mechanism. Coding style is then the complement: **propagate X on data, where
it is cheap and reliable; prohibit X on control, where propagation is not.**

    `CCV_ASSERT_KNOWN(mode_known, mode)
    always_comb begin
      unique case (mode)
        ...
        default: dout = 'x;
      endcase
    end

**Under formal, pair it with `CCV_ASSUME_KNOWN` on inputs** (finding F-8).
Yosys models an unconstrained module input as possibly-X, so the assert alone
fails spuriously. A block assumes its control inputs are X-free — which its
neighbour asserts — and proves its own outputs are; the halves compose into a
whole-design argument one boundary at a time.

**Do not use `$isunknown` for the un-reset-payload invariant.** Also F-8: an
un-reset register gets a free *two-state* value under formal, so
`$isunknown(payload)` is identically false and the property is vacuously true.
State it structurally instead, over the valid bit, which is what §6's
invariant literally says:

    `CCV_ASSERT_READ_VALID(rob_read_valid, rob_rd_en, rob_entry_v)

### CCV-L12 — every interface typedef has a checker, referencing every control field

Interface checker convention §3: *"Every interface typedef has exactly one
associated checker module. No typedef may exist without one; lint enforces
this."* And §4: *"a field added to the struct and not to the checker is a lint
failure."*

`schema/interfaces.json` declares the typedef; `rtl/if/<name>_if_checker.sv`
must exist, and must reference every field marked `control: true`.

Control fields specifically, not all fields — §6 prohibits X on control and
propagates it on data, so a control field carries an obligation and a data
field does not. `issue_t`'s `payload` is deliberately unreferenced for exactly
that reason.

This is a cross-file rule, so it has no counter-example in a `.sv` fixture;
`tools/check-1d.sh` points it at `rtl/lint/bad_interfaces.json` instead.

### CCV-L13 — no `bind` at a design boundary

**Stage 1a finding F-9, and the reason is the failure mode, not the missing
feature.**

| Tool | `bind` |
|---|---|
| Verilator | works |
| Icarus | syntax error on the `bind` statement — honest, and cheap |
| Yosys / `sby` | **parses it, ignores it, garbage-collects the checker** |

Yosys prints `Removing unused module '\chk'` and the proof then passes a
property written to be false. Every standalone block proof would have been
empty, and nothing in the output would have said so.

The convention's §4 originally specified `bind`, for good reasons — RTL stays
readable, checkers stay out of synthesis, and modes can be re-bound per flow
without touching design source. Those reasons are still right; the mechanism
is simply not available. Instantiate with `` `CCV_CHECKER `` instead.

**What it costs:** `bind` kept checkers naturally out of synthesis, and
instantiation does not. Synthesis is deferred (§6 resolved scope decisions), so
this is recorded debt rather than a present cost — but it is the one part of
`bind` with no substitute, and it should be settled before the first synthesis
attempt rather than discovered there.

`bind` is still fine for Verilator-only instrumentation, where nothing is lost.

### CCV-L14 — every checker carries a satisfiability cover

Interface checker convention §3.3, which calls a contradictory `assume` set
*"the single most dangerous failure mode in the whole formal strategy, because
it produces false confidence rather than a visible error."*

Spike cases 34 and 35 make that concrete rather than rhetorical. Case 34
carries contradictory assumes and `assert (1'b0)` — a property that cannot hold
— and BMC returns **PASS**, with no counterexample and nothing to distinguish
it from a real proof. Case 35 is the same assume set with a `cover` asking
whether the assumed state is reachable: **COVER-MISS**, the guard firing.

    `CCV_IF_SAT(iss_accept_reachable, accepted)

The covers are **unconditional, never mode-resolved**. A guard that switched
off in the mode where assumptions are active would be absent exactly when it is
needed. They must also *run* alongside any proof relying on the assumption set
— a guard that is never run carries no information — which `tools/check-if.sh`
does.

### CCV-L15 — checker properties must be mode-resolved

Use `` `CCV_CONTRACT_M(MODE, ...) ``, not bare `` `CCV_ASSERT ``.

A bare assertion in a checker ignores the `MODE` parameter, so the checker
cannot act as a formal cut-point: instantiated on an input boundary in `ASSUME`
mode it would still assert, the environment would go unconstrained, and the
proof would fail spuriously — or, worse, the intended constraint would simply
be absent and a neighbouring proof would look fine.

Two macros are exempt and intentionally so:

- `` `CCV_ASSUME_KNOWN `` — an environment constraint in every mode. Under
  formal an unconstrained input is modelled as possibly-X, so this is what
  makes the paired `$isunknown` assert provable rather than spurious (F-8).
- `` `CCV_IF_SAT `` — a guard, never mode-resolved, per CCV-L14.

### CCV-L09 — no `interface`/`modport` on a port list

See *Load-bearing: interface style* above. Settled by F-4.

### CCV-L10 — no comment line opening with a tool's name

A `// verilator ...` comment is parsed as a metacomment pragma and rejected as
an unknown one. This is a prose hazard, not a code one, and it cost three
builds while Stages 1a and 1b were being written — which is precisely the
argument for a lint rule rather than a note. Reword so the line does not start
with the tool name. Genuine pragmas (`lint_off`, `coverage_off`, …) are
recognised and allowed.

### CCV-L11 — every design module cites the spec it implements

§9: "Each module references the spec artifact it implements — its Stage 4a
internal-behavior spec — so RTL and spec stay traceable to each other as both
evolve."

A dedicated comment line, so the reference is findable mechanically:

    // Spec: docs/blocks/scheduler-4a.md

---

## Assertion placement

§9 prefers `bind`, so properties live in separate files, RTL stays readable,
and properties are naturally excluded from synthesis.

**Available, with one constraint.** Stage 1a case 17: `bind` works under
Verilator and is rejected by Icarus and by Yosys's native front end. Since
Verilator is the default simulator (§6) and carries the day-to-day assertion
regression, `bind` is usable for the properties that run there. Properties
that must also hold under the Icarus X-pass or under formal are written
**inline**, through the same macros.

The split follows the tier boundary the macro library already draws, so it
adds no new concept:

- **Inline** — tier-1 boolean properties, `CCV_ASSERT_KNOWN`, and anything a
  formal target depends on.
- **`bind`** — tier-2 temporal properties and testbench-side checkers, which
  Icarus does not carry anyway.

## Stating a property over time

There is no separate assertion clock. Every macro bottoms out in
`always @(posedge clk)`, and `clk`/`rst` are resolved **at the expansion site**
— they are whatever those names mean in the module the macro appears in, which
is why CCV-L02 requires them to be named that. The `_AT` variants take explicit
names for the rare module that cannot. Nothing is generated internally, and
with a single clock domain (§6) there is nothing to disambiguate.

Because these are immediate assertions inside a clocked block rather than
concurrent properties, they see **pre-NBA values** — a register written with
`<=` at the same edge reads as its old value. That matches what a concurrent
property's preponed sampling would give, so the distinction rarely bites; it
holds because CCV-L04 keeps `<=` in sequential logic, which is one more reason
that rule is not cosmetic.

### Tier 1b — bounded temporal properties

No sequence construct exists in any tool (F-2) and `$stable` is
Verilator-only, so anything spanning cycles is a counter or a shadow register
plus a boolean property. Three of those are common enough to be in the library:

| Macro | Contract |
|---|---|
| `` `CCV_ASSERT_STABLE_WHILE(name, cond, sig) `` | `sig` may not change for as long as `cond` holds continuously |
| `` `CCV_ASSERT_STABLE_FOR(name, start, sig, n) `` | `sig` is sampled when `start` pulses and held for `n` cycles |
| `` `CCV_ASSERT_RESPONSE_WITHIN(name, req, ack, n) `` | a request is answered within `n` cycles |

Mode-resolved forms for checkers — `` `CCV_STABLE_WHILE_M ``,
`` `CCV_STABLE_FOR_M ``, `` `CCV_RESPONSE_WITHIN_M `` — take `MODE` first and
are what CCV-L15 requires inside a checker.

These are tier **1b**, not tier 2: being boolean properties over ordinary
state, they are green in all three tools, including under Icarus and under
formal. Only `` `CCV_PAST `` and the `_T` macros are Verilator-and-formal-only.

Three things to know before using them:

- **The state is real.** It elaborates in every flow and the solver carries it,
  so a wide `sig` or a large `n` costs proof time. Keep `n` as small as the
  contract requires.
- **`name` must be unique in the module** — it is pasted into the declared
  signal names, and a collision reports a redeclaration of the generated
  signal rather than pointing at the macro.
- **`CCV_ASSERT_RESPONSE_WITHIN` assumes one outstanding request**; the age
  counter clears on any `ack`. A pipelined interface with several in flight
  needs a per-tag age array, which is a Stage 2 decision per interface.

`CCV_ASSERT_RESPONSE_WITHIN` is what replaces liveness. `s_eventually` does not
exist anywhere (F-2), so "a request is eventually answered" cannot be stated at
all — every interface gets a bounded latency with a **justified N** instead.
That is strictly weaker: it bounds the wait, it does not prove the absence of
deadlock.

**Two tool behaviours that shape how these get tested** — both bit during this
work:

- `$bits()` directly in a declaration range elaborates cleanly everywhere and
  then crashes Icarus at *runtime*, but only when the declared signal is driven
  from a different `always` block. The macros route it through a `localparam`.
  (F-14)
- Verilator `$stop`s on the first assertion failure, so a negative test
  covering several properties in one build only ever observes one. Build one
  property per run. (F-15)

## What cannot be written, and what to write instead

Stage 1a finding F-2: **no multi-cycle sequence construct works in any of the
three tools** — not `##n`, not `sequence`, not `throughout`, not property local
variables, not `s_eventually`. Verilator reports them as `Unsupported:` rather
than miscompiling them, which is the good version of this news.

Consequences, which land on Stage 2 when interface contracts are written:

- A **request-to-response contract** is an explicit tracking register plus a
  boolean property over it. The checker carries its own state, so it is a thing
  to review rather than a thing to read.
- **Deadlock freedom** cannot be stated as liveness. It becomes a bounded
  property — *a request outstanding for more than N cycles is a failure* —
  which is strictly weaker, and N is a number somebody has to justify per
  interface.
- **One-cycle history** is available as `` `CCV_PAST `` in tier 2, which is
  the Verilator-and-formal tier.

## Synthesizable subset

- No `initial` for reset behaviour (CCV-L03), no delays.
- `always_ff` / `always_comb`, not bare `always @`.
- No inferred latches.
- No `casex`. `casez` only with a paired `CCV_ASSERT_KNOWN` on the selector,
  since don't-care matching is exactly where an X selector hides.
- `unique` / `priority case` where the intent is exclusivity — their implied
  assertions fire on no-match, which is what an X selector looks like once
  CCV-L08 has banned X on control. Note Stage 1a: those implied assertions are
  checked by Verilator and are **silent** in Icarus and Yosys, so they
  supplement CCV-L08 rather than replacing it.
