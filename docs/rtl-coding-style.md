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
