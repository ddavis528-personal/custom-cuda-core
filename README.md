# CCV core — RTL and timing model

**CCV — Custom CUDA Vector processing unit.** The processor design half of the
project; the compiler and the ISA specification live in
[`custom-cuda-complier`](../custom-cuda-complier).

This repository holds what
[`docs/rtl-execution-strategy.md`](docs/rtl-execution-strategy.md) calls for:
the cycle-accurate timing model, the RTL, and the machinery that connects them
— an event schema both sides emit against, an assertion library that works
across three tools that disagree, and a lint layer that enforces the coding
rules before the first block is written.

**Current state: Stage 1 complete.** Stage 1 is the tooling and schema
groundwork, whose membership criterion is *needs no architectural decision as
input*. Everything after it is gated on the Stage 2 interface grill-me, which
happens outside this repository and has not started. `tools/verify.sh` is
green and lists the pending stages rather than omitting them.

## Start here

```
    ./tools/setup-toolchain.sh     # verilator, iverilog, yosys, sby, cvc5
    ./tools/verify.sh              # the gate
```

The toolchain is entirely free and open source, by §6's design — there is no
commercial tool anywhere in the flow. `tools/setup-toolchain.sh` is the record
of what the flow needs, not a one-time action: containers are ephemeral and
this is what restores one.

## Documents

| File | Role |
|---|---|
| [`docs/rtl-execution-strategy.md`](docs/rtl-execution-strategy.md) | **The process contract.** How we get from locked architecture to validated RTL, and in what order. Not a design doc — block-level architecture definition happens elsewhere and is an input to this. Section references throughout the repo (§1, §6, §8 Stage 1c…) point here. |
| [`docs/roadmap.md`](docs/roadmap.md) | **Start here when picking this up again.** Current state, what is built, what is next, and the open items carried forward. |
| [`docs/stage1a-tool-support.md`](docs/stage1a-tool-support.md) | **Generated.** The SVA-construct × three-tool matrix, with a named usable subset. Regenerate with `tools/run-spike-1a.py`. |
| [`docs/stage1a-findings.md`](docs/stage1a-findings.md) | **Written.** What the matrix means and what it settles — eight findings, several of which close questions the strategy doc left open. |
| [`docs/rtl-coding-style.md`](docs/rtl-coding-style.md) | §9's style guide, with every lint rule cited by id. |
| [`docs/interface-checker-convention.md`](docs/interface-checker-convention.md) | How block interfaces are declared and how one checker per interface *type* serves assertions, formal cut-points and event emission at once. Its five spike questions are closed; the answers are folded in inline, marked **ANSWERED**, beside the original reasoning. |

The matrix and the findings are deliberately two files. One is data and is
regenerated; the other is judgment and changes only when someone decides
something.

## Layout

Three files are a single source of truth for something that exists in two
languages, and everything under a `generated/` directory comes from one of
them. Nothing generated is ever edited, and the gate regenerates and then
checks nothing moved.

```
schema/events.json          event schema      -> C++ and RTL headers
schema/interfaces.json      interface typedefs -> C++ accessors and SV structs
params/ccv_params.json      structural parameters -> both languages
params/blocks.json          clock-domain and block letters (lint only)

rtl/include/                ccv_assert.svh   assertion primitives (1b)
                            ccv_if.svh       interface checker convention
                            ccv_xprop.svh    X-determinism constructions
                            ccv_trace.svh    RTL-side event emit (1c)
rtl/if/                     reference interface checker
rtl/lint/                   lint fixtures -- bad_* must fail, good_* must not
rtl/generated/              generated; never edited

sim/include/ sim/src/       C++ timing-model side: event emit API
sim/dpi/                    DPI-C bridge, so RTL feeds the same library
sim/generated/              generated; never edited

synth/                      clock-gating techmap -- exploratory, see F-18
spike/cases/                Stage 1a tool probes -- 36 cases
test/smoke/                 exit-criteria smoke modules
tools/                      generators, checks, and the gate
```

## What Stage 1 established

Four numbered items, plus four conventions that came out of using them. Each
has its exit criteria as a script (§8: *"anything that can
be a script should be — on a solo project, criteria requiring a manual
checklist decay to nothing"*).

**1a — tool-support spike.** Front-loaded deliberately, because a thin SVA
intersection across the free stack would undercut §7's whole lean-into-formal
posture, and finding that out in week one is cheap. The intersection *is*
thin: unlabelled immediate `assert`/`assume`/`cover` in a clocked block, no
`else` clause, boolean expressions only. No concurrent `assert property`, no
`$past`, and no multi-cycle sequence construct is available in all three
tools.

The posture survives anyway, because the load-bearing question was whether
`assume` genuinely constrains a solver — it does, with cvc5 doing real work.
So the answer is one property source with per-tool expansion, which is what
1b builds.

**1b — assertion primitive library.** `assert`/`assume`/`cover` as distinct
roles, swappable at the call site, plus the X-safety macros. The runtime
knob is a plusarg guard rather than `$assertoff`, which does not exist on this
stack.

**1c — event schema mechanism.** The container, not the event list: the two
event classes are decided, the events themselves are a provisional seed set
that Stage 2 and Stage 4a populate. Binary 32-byte records, a semantic schema
hash in every trace header, and a Perfetto view produced on demand. The RTL
emit path is DPI-C into the same library, decided *and exercised* here rather
than discovered at 4c.

**1d — coding style and lint.** Eleven rules, each with a counter-example in
`rtl/lint/bad_module.sv` and a paragraph in the style guide; `check-1d` fails
if a rule stops firing or stops being documented. Parameters and event ids are
generated into both languages from one source, because §9 is right that
nothing else prevents them from drifting.

## Conventions settled on top of Stage 1

Each is documented, enforced by lint, and backed by a measurement rather than
a preference.

**Interface checkers.** One checker per interface *type* serves protocol
assertions, formal cut-points and event emission at once. Connected by
instantiation, not `bind` — see below.

**X-determinism.** A selection on control must be X-deterministic by one of
three routes: prohibition (assert the control known), tmerge (a ternary, which
is already X-pessimistic in the LRM), or xmerge (a case with an X-default).
Anything else is X-optimistic, which makes the bug invisible rather than merely
unhandled. `casex` is banned outright.

**Net naming.** Every net states what it is, when it is valid and which clock
made it: `iq_issue_valid_cs03h`. That last part is what makes stage arithmetic
checkable — a flop advances exactly one stage, combinational logic advances
none — which is the reason the convention is worth the typing.

**Clock gating.** Enables are written as `if` inside `always_ff`, so they reach
synthesis as gating candidates. Yosys cannot insert gates, so `synth/` carries
a techmap rule standing in for the pass it lacks.

## What Stage 1 settled that the strategy doc left open

- **SystemVerilog interfaces cannot be block boundaries.** Verilator refuses an
  interfaced port at top level, and block boundaries are swap boundaries.
  Plain ports and packed structs. (F-4)
- **Verible is not needed.** Its load-bearing rule was never expressible in
  stock rules, so custom rules were always going to be written. §6's "this
  adds a fourth tool" is retracted. (F-5)
- **`$assertoff` is unavailable**, and the guard-signal substitute is better,
  provided the guard is a constant under formal. (F-3)
- **`$isunknown` cannot state the un-reset-payload invariant under formal** —
  an un-reset register gets a free two-state value there, so the property is
  vacuously true. It is stated structurally over the valid bit instead. (F-8)
- **`bind` is unusable, and Yosys drops it silently** — it parses the bind,
  garbage-collects the checker, and the proof passes having checked nothing.
  Checkers are instantiated instead. (F-9)
- **Packed structs do reach the C++ swap boundary**, as one packed signal —
  but their field offsets do not, so the typedef is generated into both
  languages. (F-12)
- **VCS X-Prop semantics are reachable from plain LRM behaviour** — the
  ternary operator already gives tmerge, and `casex` is banned because it
  silently matches the first branch. (F-16)
- **The stage tag does not cross into C++.** Signal identity is the base name;
  the tag is an implementation attribute, so a retimed RTL still correlates
  against an unchanged model.

Full detail in [`docs/stage1a-findings.md`](docs/stage1a-findings.md).

## Checking it

`tools/verify.sh` is the gate and runs everything: generated artifacts are
current, the Stage 1a matrix still covers every case on disk, each stage's
exit criteria, the project linter, and Verilator's own lint. It grows one
section per stage as that stage defines its criteria, and lists the stages not
yet reached rather than omitting them — a gate that appears to cover the whole
flow while covering part of it is worse than one that says what it does not.
