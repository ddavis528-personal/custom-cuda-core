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

**Current state: Stage 1 complete; Stage 2 partition closed and encoded.**
Stage 1 is the tooling and schema groundwork, whose membership criterion is
*needs no architectural decision as input*. The Stage 2 interface grill-me
happens outside this repository; it ran on 2026-09-23 and closed the partition
at **14 block types, 45 instances, 40 channels**, all now encoded and
machine-checked here. `tools/verify.sh` is green and lists the pending stages
rather than omitting them.

**Every payload field now has a width, so all 40 channels generate a packed
struct and the skeleton can be wired end to end.** The cost is that some
widths are guesses, so the repository carries **three tiers of trust** and the
tier is visible at every use site:

| Package | Meaning | Expected to move |
|---|---|---|
| `ccv_params_pkg` | follows from a settled decision | nothing |
| `ccv_prov_pkg` | a sizing placeholder | the number |
| `ccv_prelim_pkg` | no decided *encoding* at all | possibly the **field itself** |

Classified by the weakest width each carries: **10 of 40** channels are
decided end to end, 14 carry a provisional width, and 16 carry a preliminary
one. [`docs/payload-spec.md`](docs/payload-spec.md) is the per-channel
breakdown; [`docs/trust-report.md`](docs/trust-report.md) is the build
artifact listing everything that references an undecided number, so which
ones are still made up is produced rather than remembered.

Still outside the repository: **per-interface NGD budgets**, and two questions
no width can close — the `src_arch`/`operand` mismatch (an ISA question that
blocks coding rename) and the RCU→MIU width that argues for moving the AGUs
(a partitioning question, before floorplan).

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
| [`docs/rtl-findings-stage1.md`](docs/rtl-findings-stage1.md) | **The report for the architecture and planning track.** What Stage 1 found about the strategy — six decisions measurement overturned, what was confirmed, and what Stage 2 needs. Organised by what was found, not by what was built. |
| [`docs/stage1a-findings.md`](docs/stage1a-findings.md) | **Written.** What the matrix means and what it settles — eighteen findings (F-1…F-18), several of which close questions the strategy doc left open. |
| [`docs/fail-open-register.md`](docs/fail-open-register.md) | Every mechanism in the flow that fails *open* rather than loud, and the negative control that makes its results believable. Stage 1's three worst findings were all fail-open. |
| [`docs/reset-line-template.md`](docs/reset-line-template.md) | The format a block's Stage 4a reset line must take — every un-reset payload field paired with the valid bit that guards it, without which §7's third formal target cannot be written. |
| [`docs/payload-spec.md`](docs/payload-spec.md) | **Generated.** Every channel's payload field by field, with each width's tier and source, and what each channel is *for*. Regenerate with `tools/gen-payload-spec.py`. |
| [`docs/trust-report.md`](docs/trust-report.md) | **Generated.** Every module referencing a width nobody has decided, plus the channels that carry one indirectly and the high-churn parameters. Which numbers are still made up, as a build artifact rather than something to remember. |
| [`docs/rtl-coding-style.md`](docs/rtl-coding-style.md) | §9's style guide, with every lint rule cited by id. |
| [`docs/interface-checker-convention.md`](docs/interface-checker-convention.md) | How block interfaces are declared and how one checker serves assertions, formal cut-points and event emission at once. Its five spike questions are closed; the answers are folded in inline, marked **ANSWERED**, beside the original reasoning. Written expecting one checker per interface *type*; the partition made it **one checker for all 40 channels**, since every boundary runs the same credited protocol. |

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
rtl/if/                     the one parameterised credit checker
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
event classes are decided, the events themselves a seed set that Stage 2 and
Stage 4a populate. Stage 2 has since populated the load-bearing half — the
40-channel list *is* that list, emitted as `EV_CH_XFER`. Binary 32-byte records, a semantic schema
hash in every trace header, and a Perfetto view produced on demand. The RTL
emit path is DPI-C into the same library, decided *and exercised* here rather
than discovered at 4c.

**1d — coding style and lint.** Twenty-five rules, each with a counter-example
in `rtl/lint/bad_module.sv` and a paragraph in the style guide; `check-1d`
fails if a rule stops firing or stops being documented. Parameters and event ids are
generated into both languages from one source, because §9 is right that
nothing else prevents them from drifting.

## Conventions settled on top of Stage 1

Each is documented, enforced by lint, and backed by a measurement rather than
a preference.

**Interface checkers.** One checker — `rtl/if/ccv_credit_checker.sv`, not one
per interface — serves protocol assertions, formal cut-points and event
emission at all 40 boundaries at once. Every boundary runs the same credited
protocol, so only the payload width differs. Connected by instantiation, not
`bind` — see below. Since no multi-cycle SVA exists (F-2), every temporal
property in it is an explicit tracking register, which is what makes a single
shared implementation worth far more than it would be if properties were
declarative: written once, reviewed once, wrong in one place at most.

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

## What Stage 2 encoded

The grill-me closed the partition; this repository turned it into things that
are checked rather than described.

**The topology.** 14 block types, 45 instances, 40 channels, in
`params/blocks.json` and `schema/interfaces.json`. Per-block port lists are
**derived** from the channel list rather than stated, because the source spec
carried both and they disagreed — and a derived list cannot disagree with
itself. Block letters came in at 14 with 2 reserved (`z` reset tree, `y`
fixtures) and 8 spare, so the single-letter stage tag holds.

**The credited protocol.** Four signals per channel: `_valid` and `_payload`
from the producer, `_credit` and `_stall` from the consumer. Valid leads the
payload by one cycle on every interface without exception, a credit is
consumed when valid asserts rather than when the payload lands, and once
asserted valid is binding. Stage 1 had provisionally guessed a `_ready`
signal; the reasoning behind that guess survived — backpressure stays outside
the packed struct, so the swap harness still drives the payload one way (F-12).

**The round trip is 2, by construction.** Flops on both sides with no
exceptions, plus abutment, gives exactly that. It is not a per-block choice,
so credit depth, rescue depth and drain wait are not three numbers but one
number under three names — all 2 today, with wake at 4. It stays a
per-instance parameter defaulted to that minimum, because a non-abutting
interface would differ and none is known to be non-abutting until floorplan.

**Undecided values are visible at the use site.** Parameters generate into
one of three packages by status — `ccv_params_pkg`, `ccv_prov_pkg`,
`ccv_prelim_pkg` (and `ccv::`, `ccv::prov::`, `ccv::prelim::` in C++) — so a
module referencing an unfinished number says so wherever it is *read*, not
merely where it is declared. That is the whole reason for a package split
rather than a comment.

The bottom two tiers are different obligations, which is why they are not one
package: `prov` means *we will pick a number*, `prelim` means *we do not yet
know what this field is*. Preliminary parameters also carry a **churn** rating
— high means the field's shape will change, so code that pattern-matches on
its contents gets rewritten while code that merely carries it does not.

**Misconfiguration is checked, because it is not a protocol violation.** Two
`CCV_IF_CONFIG` assertions guard the two ways a checker can be set up wrong
without breaking any rule it enforces: a credit depth below the round trip
throttles the channel and reads as healthy backpressure, and a timeout below
it fires on a channel behaving perfectly — teaching the reader to disbelieve
the check. They are unconditional; under `MODE=ASSUME` a mode-resolved version
would turn a misconfiguration into an *assumption* and constrain it away.
`tools/check-if.sh` builds each misconfiguration and requires the matching
assertion to fire, because every other check there is a *stays quiet* check
and a check that has been deleted is very quiet.

## Checking it

`tools/verify.sh` is the gate and runs everything: generated artifacts are
current, the Stage 1a matrix still covers every case on disk, each stage's
exit criteria, the project linter, and Verilator's own lint. It grows one
section per stage as that stage defines its criteria, and lists the stages not
yet reached rather than omitting them — a gate that appears to cover the whole
flow while covering part of it is worse than one that says what it does not.
