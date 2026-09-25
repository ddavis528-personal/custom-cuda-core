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
- `arch` — decided at a design session. Traceable, and not expected to move.
- `provisional` — a placeholder awaiting the stage named in `decided_at`
  (Stage 4a sizes it, 4b sweeps it). **The number moves.**
- `preliminary` — a width good enough to *wire*, for a field whose encoding is
  not decided at all. **The field's shape may move.**
- `tunable` — expected to move once the timing model runs.
- `target` — a physical target such as the 25 NGD envelope, not a structure
  size.

A sweep that varies an `isa` parameter is varying something the compiler is
built against. The status field is what makes that visible.

### Three packages, because the tier has to be visible at the use site

Status is not just metadata: it picks which package the parameter is
generated into, and the package name appears at every reference.

| Package | C++ | Meaning | What moves |
|---|---|---|---|
| `ccv_params_pkg` | `ccv::` | follows from a settled decision | nothing |
| `ccv_prov_pkg` | `ccv::prov::` | a sizing placeholder | the number |
| `ccv_prelim_pkg` | `ccv::prelim::` | no decided encoding at all | the field's **shape** |

So `ccv_prelim_pkg::CCV_L_W_OPCODE` announces itself as unfinished wherever it
is read, not merely where it is declared. That is the whole mechanism — a
comment next to the declaration is a comment nobody re-reads at the use site.

**The bottom two tiers are genuinely different obligations, which is why they
are not one package.** `provisional` says *we will pick a number*;
`preliminary` says *we do not yet know what this field is*. Collapsing them
would lose exactly the distinction a skeleton author needs.

### Churn: what you may safely do with a preliminary field

Every `preliminary` parameter carries a churn rating, and it rates the
**field**, not the number:

- **low** — only the number moves. Carrying it, storing it and comparing it
  for equality are all safe.
- **med** — the encoding is likely to gain or lose codes.
- **high** — the field's shape is likely to change. **Code that
  pattern-matches on its contents will be rewritten**; code that merely
  carries it end to end will not.

The practical rule for the Stage 3 skeleton: *carry* preliminary fields
freely, *decode* them only where the skeleton would be pointless without it,
and never build control flow on a high-churn field's contents. `opcode`,
`operand`, `pcs`, `pred_state` and `tilelink_tlc` are the high-churn ones
today; `docs/trust-report.md` is generated on every gate run and lists them
with everything that references them.

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

## Net naming

Every net's name states what it is, when it is valid, and which clock made it.
That last part is what turns naming from a readability convention into
something a checker can reason about — the stage tag is why CCV-L21 and
CCV-L23 exist at all.

### The shapes

```
signals   <name>[_<stage>][_n|_b]      iq_issue_valid_cs03h
                                        iq_flush_cs03h_n
                                        iq_en_cs03h_b

clocks    [<block>_]<domain>_clk[_b]   core_clk           top level
                                        sched_core_clk     gated, per block
                                        test_clk           async: no `core`
                                        sched_core_clk_b   inverted

reset     <block>_rst_r<NN><l|h>       sched_rst_r06h

stage     <domain><block><NN><l|h>     c = core domain
                                        s = scheduler block
                                        03 = pipe stage
                                        h = posedge (l = negedge)
```

All lowercase, underscore-separated. Only parameters and localparams carry
upper case.

**`_n` and `_b` are always the outermost suffix**, after the stage tag. Mildly
ugly, and too entrenched to change.

- **`_n`** — the signal is *defined* active-low. A semantic property; carries
  no obligation a checker could test.
- **`_b`** — the *complement* of a value that also exists. CCV-L24 requires it
  to be driven through an inversion.

### The domain segment is the second-to-last segment of a clock name

`sched_core_clk` → `core`. `test_clk` → `test`. That placement is deliberate:
it makes "`_core_` means synchronous to the core domain" a **mechanical**
property rather than a reading convention, so lint can check it and an
asynchronous clock cannot accidentally be named as though it were synchronous.

Registered in `params/blocks.json`, along with the block letters.

### Reset has its own numbering space

A synchronous reset cannot be delivered globally in one cycle. It is pipelined,
balanced so de-assertion arrives everywhere on the same cycle, and how deep it
is when it reaches a block depends on physical distance.

So reset nets carry block letter **`r`**: `sched_rst_r06h` reads as "six stages
into the reset tree", and cannot be confused with a datapath signal at stage 6.
**Reset nets take no part in stage arithmetic** — their depth measures distance,
not datapath.

### Where the stage tag lives, and where it does not

- **On the net, never on a struct field.** An `issue_t` may be instantiated at
  stage 3 in one place and stage 7 in another, so the type cannot carry a
  stage. The field stays `valid`; the net is `iq_iss_cs03h`, referenced as
  `iq_iss_cs03h.valid`.
- **Not in the C++ timing model.** §9 keeps signal names identical across the
  two languages so §5 correlation needs no mapping, and the stage tag is an
  *implementation attribute*, not part of a signal's identity. Correlation
  matches the base name and carries the tag as metadata. A retimed RTL
  therefore still correlates against an unchanged model — which is the point,
  not a concession. **Event-schema field names carry no stage tags.**
- **Not on a reusable module's formals.** See CCV-L21.

### Design modules and reusable modules

Design RTL declares which block it belongs to:

    // Block: scheduler

A **reusable** module — an interface checker, a primitive — declares itself
instead, with a reason:

    // Reusable: one interface checker is instantiated inside many blocks and
    //           binds to each one's own uniquified clock.

Reusable modules take `clk`/`rst` as generic formals and are exempt from the
clock-naming and stage rules, because a formal named for one block would read
as a lie in every other. This is **declared, never inferred** — inferring it
from "the clock is not named like a clock" would let every non-compliant file
exempt itself by being non-compliant.

### CCV-L02 — every macro user names its own clock and reset

There is no single clock name the assertion macros can hardcode. Each block
gates `core_clk` on entry and uses the uniquified result, so `sched_core_clk`
and `alu_core_clk` are different nets; reset is worse, since which stage of the
distribution tree reaches a block depends on physical distance.

So each file supplies its own:

```systemverilog
`define CCV_CLK sched_core_clk
`define CCV_RST sched_rst_r06h
  ... module body, `CCV_ASSERT(...) as usual ...
`undef CCV_CLK
`undef CCV_RST
```

The inner macros expand at *use* time, so each file genuinely gets its own
clock — verified in all three tools. **The `` `undef `` is required**: a macro
outlives the file in a shared compilation unit, and without it the next file
silently inherits this one's clock. Use the `_AT` forms directly for a module
needing two clocks, which under §6 should not exist outside DFT.

### CCV-L19 — lower_snake_case

Only parameters and localparams carry upper case.

### CCV-L20 — clocks are named as clocks, and used only as clocks

A net driving a clock edge must match the clock shape, and its domain segment
must be registered. Conversely a clock may appear only in an edge expression, a
port map, or **the right-hand side of another clock** — that last one being the
block's gate, which is the whole reason `<block>_core_clk` exists. Anywhere
else is a clock read as data.

Because `_core_` marks synchronous, an `always_ff` mixing a `*_core_clk`-
generated signal with a `test_clk`-generated one is a crossing detectable from
the names alone. Nothing uses `test_clk` yet; it is registered so the first
crossing is a finding rather than a surprise.

### CCV-L21 — stage tags are well-formed and consistent

For every flop, the tag on the assigned net is checked against the block that
generates it:

- **domain letter** matches the domain of the generating clock — a signal
  labelled for the wrong domain is how a crossing hides;
- **edge letter** matches `posedge`/`negedge`;
- **block letter** is registered, and is this file's own block (or `r`).

A design file with sequential logic must declare `// Block:` or `// Reusable:`,
since without a block name there is nothing to check the block letter against.

### CCV-L22 — a block runs on its own gated clock

No `always_ff @(posedge core_clk)` inside a block. Each block gates `core_clk`
as its first act, and clocking logic on the ungated net **silently defeats that
gate**: the design still works, produces identical results, and never saves the
power it was supposed to. Nothing in simulation shows it, which is exactly why
it needs a rule.

### CCV-L23 — stage arithmetic

The rule the whole convention exists to make checkable:

| | |
|---|---|
| flop output | `max(input stages) + 1` |
| combinational output | `max(input stages)` |

Catches mislabelled pipelines, accidental combinational paths across a stage
boundary, and retiming that updated the logic but not the names.

Three exemptions, each for a reason:

- **A net's own previous value.** `q_cs04h <= en ? d_cs03h : q_cs04h` is a hold
  or a counter — a self-reference at the *same* stage, not a violation.
- **Reset nets** (block letter `r`), whose numbering measures distribution
  depth rather than datapath depth.
- **Right-hand sides with no tagged signal at all** — constants, parameters.

### CCV-L25 — sequential enables are `if`, not a feedback mux

See *Sequential enables* above. Enforces intent rather than correctness: both
forms give the same enable flop, but only one of them says so.

`` `CCV_XHOLD `` is the sanctioned escape, for an enable that genuinely cannot
be proven X-free.

### CCV-L24 — `_b` is a complement

A net named `_b` must be driven through an inversion. It complements a *value*,
which is often an expression or a bit-select rather than a net of its own, so
no same-named sibling is required — an earlier version demanded one and was
wrong. Use `_n` for a signal that is simply defined active-low; that carries no
obligation.

### CCV-L01 — one module per file, filename matches module name

Required by build automation and assumed by most lint tooling. Also what makes
a block's file findable from a waveform hierarchy without a search.


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

### CCV-L07 — an unreachable case branch assigns `'x`, never holds

§6's first listed X-safety rule: explicit X-injection for unreachable states,
rather than the implicit hold that squashes the bug.

Either spelling satisfies it — a `default:` branch, or an X prologue before the
case. The prologue is often the more natural style and reaches the same
guarantee, so the rule accepts both:

    always_comb begin
      y = 'x;                 // prologue
      case (sel) ... endcase
    end

    case (sel) ... default: y = 'x; endcase   // or a default branch

    // (neither)              // silently holds, and the bug survives

### X-propagation: matching VCS X-Prop with the tools we have

§6 requires X-correctness to be designed in by convention rather than
inherited, because neither simulator has dependable X-prop semantics. There is
no VCS-equivalent X-propagation mode anywhere in the flow.

**The rule: a selection on control must be X-deterministic.** Exactly three
constructions are legal; anything else is X-optimistic, which means the bug is
invisible rather than merely unhandled.

| Route | Construction | Behaviour on an unknown selector |
|---|---|---|
| **Prohibition** | `if`/`case` whose control **inputs** carry `` `CCV_ASSERT_KNOWN `` | The X is flagged at its source |
| **tmerge** | Ternary (`?:`), or the `` `CCV_XMUX* `` macros | Agreeing bits keep their value, differing bits go X |
| **xmerge** | `case`/`casez` with an X-default covering everything it assigns | The whole result goes X |

All measured, with `i0=1100 i1=1110 i2=1100 i3=1101` (bits 3,2 agree; 1,0
differ):

| Construct | `sel=xx` | `sel=1x` |
|---|---|---|
| `if`-chain | `1101` — the **last** branch | `1101` |
| ternary | `11xx` | `110x` — narrows on partial X |
| `case` + X-default | `xxxx` | `xxxx` |
| `casex` | `1100` — **silently matched branch 0** | `1100` |

Two things to take from that table:

- **The ternary operator is already X-pessimistic in the LRM.** It produces
  exactly what VCS calls tmerge, with no tool mode, no pragma and no primitive
  — and it narrows correctly when only *part* of the selector is unknown. The
  asymmetry against `if`/`case` is the whole lever this section rests on.
- **An `if`-chain does not pick the first branch, it falls through to the
  last.** Every comparison against an unknown selector is itself unknown, so
  the chain lands on the final `else`. Which branch that is depends on the
  ordering, not the design. The answer is definite, arbitrary, and
  indistinguishable from a correct one.

**Prefer prohibition where it applies.** It is the strongest of the three: it
reports X at the source rather than tracking its spread, it works in every
tool, and — unlike propagation — it is *provable under formal*. Choose tmerge
over xmerge where either is allowed, since a blanket X trains people to ignore
X. But `case` is too useful to abandon, and an X-defaulted `case` is a fully
legal, natural-style answer.

**The primitives are conveniences, not requirements.**
`` `CCV_XMUX2/4/8 `` and `` `CCV_XHOLD `` in `rtl/include/ccv_xprop.svh` just
save writing a ternary chain; they introduce no semantics. Code that spells the
chain directly is equally correct and equally lint-clean.

#### This has exactly one witness

Verilator is 2-state and cannot see X at all. Under formal an un-reset register
is a free **two-state** value (F-8), so `$isunknown` is identically false
there. **Icarus is the only tool in the flow that observes any of this.**

That is a structural weakness — the same shape as the event-emission path
(F-13) — and it is the real argument for prohibition being primary: an
assertion fires under Icarus *and* proves under formal, while propagation is
checkable in one place only. It also makes the periodic X-pass (§6, and per
block at Stage 4c) load-bearing rather than supplementary.

`tools/check-xprop.sh` is the differential regression: it asserts the three
constructions **disagree** on an unknown selector. If they ever agree, these
rules are ceremony and should be deleted.

#### Sequential enables: `if` is the right form inside `always_ff`

The one place `if` on control is *preferred* rather than merely tolerated.

    always_ff @(posedge `CCV_CLK) begin
      if (`CCV_RST)         q_cs01h <= '0;
      else if (ld_en_cs00h) q_cs01h <= d_cs00h;
    end

This is the shape that carries an enable to synthesis as a clock-gating
candidate. The X obligation is discharged by **prohibition** — a
`` `CCV_ASSERT_KNOWN `` on the enable — not by merging, and the rules as
written already permit exactly this.

**With a real gate, the assertion matters more, not less.** A feedback mux with
an unknown enable holds a stale value. An ICG with an unknown enable produces
an unknown *clock*, and every flop behind it is then undefined. The prohibition
is doing more work in the gated case, which is the opposite of the intuition.

**Measured (F-17):** both spellings synthesise to the *same* enable flop in
Yosys — `$_DFFE_PP_` without reset, `$_SDFFE_PP0P_` with it. Yosys's `opt_dff`
recognises the feedback mux and converts it, so nothing is lost semantically
either way. The reason to prefer `if` is that commercial gating insertion is
more reliably triggered by it, and **that is not something this toolchain can
verify** — Yosys 0.33 has no `clockgate` pass at all. It infers the enable and
stops; turning `$dffe` into an ICG plus a gated clock is a mapping decision it
never makes.

**This is linted (CCV-L25), and the basis matters.** The rule does not claim
the two forms differ — they provably do not, in the only synthesis tool
available here. What it enforces is *intent*: an `if` states "this is a
clock-gating candidate", a feedback mux states "this is a mux", and the
project has chosen to write RTL for where the flow is going rather than for
what Yosys does today.

That distinction is why the earlier decision not to lint it was wrong. It was
right about the evidence and wrong about the rule — what is being enforced is
a design decision, not a belief about a tool, and a design decision is exactly
what lint is for. `rtl/lint/good_gated_enable.sv` is the standing proof that
the preferred form is clean under every other rule.

`` `CCV_XHOLD `` remains available for the case this does not cover: an enable
that genuinely cannot be proven X-free, where merging beats holding.

**In `always_comb`, the preference inverts** — there is no gate to infer, so
the ternary's tmerge is free and strictly better.

### CCV-L16 — `casex` is banned outright

Measured above: with an unknown selector `casex` treats X as a don't-care and
matches the **first** branch. That is neither pessimism nor optimism — it is an
arbitrary answer wearing the costume of a real one.

`casez` is permitted, because `z` don't-care does not make `x` a don't-care: a
`casez` with an unknown selector still matches nothing and falls to its
default. It is subject to the same X-default requirement as `case`.

### CCV-L17 — no partially X-defaulted case

A `default:` that assigns some of the signals the case writes and not others
leaves the rest holding their previous value on an unreachable branch — the
implicit hold CCV-L07 exists to remove, reintroduced halfway.

Usually a slip rather than intent, which is exactly why it needs a rule.

### CCV-L18 — array write with an unknown index

An unknown index does **not** propagate X. LRM semantics silently **drop the
write**, and no coding construction changes that — the value simply never
arrives, and the array keeps a stale entry that looks legitimate.

Prohibition is the only route here: assert the index known.

### CCV-L08 — control expressions must be X-deterministic

§6's central rule, and the one no stock rule set expresses: it is a
relationship between a control expression and an assertion elsewhere in the
file, not a property of either alone.

An `if` has only the prohibition route — there is no "X-default" for an `if`,
and the alternative is to write the selection as a ternary, which is not an
`if` and so never reaches this rule. A `case` has both routes.

**Why only input ports must carry the assertion.** X enters a module through
its ports or through un-reset state. A locally derived signal is X-free
whenever the inputs it derives from are, so asserting at the boundary
discharges the interior — the same compositional argument F-8 makes for
`` `CCV_ASSUME_KNOWN ``, one level down. Un-reset state is the other source,
and is covered separately by the reset line at Stage 4a and by
`` `CCV_ASSERT_READ_VALID ``. `rst` is exempt: §6 makes it globally
synchronous and always reset.

**Limits, stated because a rule trusted beyond its reach is worse than one not
trusted at all.** This reads ANSI port lists, matches identifiers textually,
and does not follow hierarchy, `` `include `` boundaries or non-ANSI
declarations. It is a net, not a proof. The proof is the formal run.



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

#### `cover` does nothing in simulation on this stack

Worth knowing before relying on one. Measured (Stage 1a case 03): an immediate
`cover` is **`SILENT` in both Icarus and Verilator** and `COVER-HIT` only under
`sby -m cover`. Concurrent `cover property` is worse — it does not parse in
Icarus or Yosys at all.

So a `cover` is a **formal-only** construct here. That is not a reason to write
fewer of them; it is a reason to make sure they are *run*, which is why
`tools/check-if.sh` puts the satisfiability covers through `sby -m cover`
rather than trusting a simulation regression to exercise them. A guard that is
never run carries exactly as much information as no guard.

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

Three macros are exempt and intentionally so:

- `` `CCV_ASSUME_KNOWN `` — an environment constraint in every mode. Under
  formal an unconstrained input is modelled as possibly-X, so this is what
  makes the paired `$isunknown` assert provable rather than spurious (F-8).
- `` `CCV_IF_SAT `` — a guard, never mode-resolved, per CCV-L14.
- `` `CCV_IF_CONFIG `` — a check on the checker's own parameters, below.

Each is a *named* macro rather than a bare `` `CCV_ASSERT `` precisely so this
rule keeps full force inside checkers. A file-scope lint exemption would have
switched CCV-L15 off across the one file it matters most in.

### `CCV_IF_CONFIG` — misconfiguration is not a protocol violation

A parameterised checker can be misconfigured, and the interesting
misconfigurations break no protocol rule at all:

| Misconfiguration | What it looks like instead |
| --- | --- |
| credit depth below the round trip | the channel throttles to one message per round trip — indistinguishable from healthy backpressure |
| timeout N below the round trip | `response_within_n` fires on a channel behaving perfectly, and the first instinct on seeing it is to raise N — i.e. the check teaches you to disbelieve it |

Nothing else in a checker catches either, because nothing else looks at the
parameters:

    `CCV_IF_CONFIG(depth_covers_round_trip,   DEPTH     >= ROUND_TRIP)
    `CCV_IF_CONFIG(timeout_covers_round_trip, TIMEOUT_N >= ROUND_TRIP)

**Never mode-resolved.** Under `MODE=ASSUME` a mode-resolved version would turn
a misconfiguration into an *assumption* and constrain it away — the proof would
then hold only over the configurations that are already correct, and say so
nowhere. A configuration error is wrong in every mode.

`tools/check-if.sh` builds each misconfiguration and requires the matching
assertion name to fire. Every other check in that file is a *stays quiet*
check, and a check that has been deleted is very quiet.

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
