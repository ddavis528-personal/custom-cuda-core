# CCV core: notes for a coding session

The RTL and verification flow for the CCV GPU core. The process contract is
`docs/rtl-execution-strategy.md`. Current state and what comes next are in
`docs/roadmap.md`, Part 0. Everything open is numbered in
`docs/open-items.md` (Q-n), with its owner.

**An OOE model session starts at `docs/ooe-4b.md`.**

## Sources of truth: edit these, never what is generated from them

- `schema/interfaces.json`: every channel, field, width and contract.
- `params/ccv_params.json`: every size and latency. Derived values carry
  `derive`/`require`, and `tools/gen-params.py` refuses drift.
  A parameter whose status is `isa` cites the ISA (`isa`: a verbatim quote
  and its value over the quote), and `tools/check-isa-params.py` holds it to
  the ISA document in the pinned compiler snapshot (IS-11).
- `params/links.json`: repeater stages per channel.
- Generated, never hand-edited: `sim/generated/`, `rtl/generated/`,
  `rtl/top/`, `docs/payload-spec.md`, `docs/trust-report.md` and
  `docs/walkthrough.md`. Regenerate them with `tools/gen-*.py`;
  `tools/verify.sh` fails if any is stale. Each generated directory's
  `.generated` says which generator wrote which file, and a file no
  generator writes any more is removed (`tools/genout.py`).
- Kernel oracles come from the pinned compiler snapshot (`tools/compiler.lock`,
  `tools/gen-oracle.sh`). Nothing of ccv-sim's output is checked in.

## The gate

```
./tools/setup-toolchain.sh   # a fresh container needs this once
./tools/regen.sh             # every generated file, walkthrough included (~2 min)
./tools/verify.sh            # must be green before a push
```

Run `tools/regen.sh` and commit what it changes before every gate (DA,
2026-10-23). `docs/walkthrough.md` is built from the gate's own runs, so the
gate can compare it whole only at its end; a stale one used to cost a whole
gate. Its inputs that move it most (the compiler pin, schema, params, the lint
rule count, the gate's sections) are fingerprinted into its last line, and the
gate checks that fingerprint in its first minute.

After the generators, the sections run as parallel jobs, `CCV_JOBS` at a
time (default every core; `CCV_JOBS=1` is serial), each section's log in
`build/verify/<job>.log` with its time. A job that reads another's build
products names it in `after` in `tools/verify.sh`; no two jobs that may run
together share a build directory. check-cg and check-ngd measure their units
`CCV_JOBS` at a time too, and share one Yosys netlist per unit through
`build/synth-cache`. The gate clears it first; `tools/verify.sh --cached`
keeps it for an intermediate run, whose result reads `CACHED PASS`. The gate
before a push is the clean one (Daniel, 2026-10-21).

Local clock gating (Daniel, 2026-10-16; `docs/rtl-coding-style.md`): every
register behind an `if` on an enable named `<name>_en`; a clock gate is 8
flops or more, its enable cone within 8 NGD and its DCGE at least 75% in
idle, medium and high scenarios; anything else must toggle 75% of the time.
An enable comes only from the module's own flops, never an input (CG-5), and
the reset is flopped before any use (RST-1; 2026-10-18): that is why valid
leads a payload by a cycle, and why a lead field is rare.
`tools/check-cg.py` measures it from each module's unit
(`test/**/cg-units.json`, and every repeater the design instantiates,
`rtl/top/rpt-units.json`). Each module may leave the larger of 2% of its
flops and fewer than 8 flops outside the rules, and what its modules take
must stay within 2% of each block's flops, per instance; a repeater's
control pulses and flopped reset count only there, against its wrapper's 2%
(2026-10-19), its lead slice against its own allowance. Past that,
refactor; a waiver (`rtl/cg-waivers.json`, written by the module's owner) is
the last resort.
RTL older than the rule sits on `rtl/cg-ratchet.json`, which only shrinks:
its owner removes an entry once the module passes (CG-5 and RST-1 per
register or port).

Logic depth (Daniel, 2026-10-17; `docs/rtl-coding-style.md`): 25 NGD of
combinational logic between flops, the flop outside it. Each module port has
12 NGD a side by default; a port over it needs the architect's budgets, one
file per module beside its RTL (`<module>.ngd.json`). Nothing straight
through a module, input to output, not even a wire, nor logic in a parent
between its children (2026-10-18): connect a wire directly, group logic with
one sequential side, or declare a combinational module an inner helper in
its file, timed as its parent's logic (until a parent instantiates it, held
alone to 16 NGD, floor(2 × 25 / 3); 2026-10-19). A register that drives an
output is held on every path it starts, inside as out, to that output's
budget (2026-10-19): copy it, one for the output and one for the rest, each
`(* keep *)`, or synthesis merges them back. The one feedthrough allowed is a
channel a generated wrapper carries across itself. An
assembled block is checked from those files, level by level, for
convergence to 25, then timed whole, its outputs straight from flops.
`tools/check-ngd.py` measures every module at its units' parameters; what
broke the rules when they were made sits on `rtl/ngd-ratchet.json`, which
only shrinks.

Stage tags (DA, 2026-10-23; CCV-L29 in `docs/rtl-coding-style.md`): every
net of a block's sequential module carries one, since CCV-L21 and CCV-L23
skip a net without. The untagged nets that stood then sit on
`rtl/stage-ratchet.json`, which only shrinks.

Every Yosys the gate runs, SymbiYosys's included, is `tools/shim/yosys`:
the warnings that mean a netlist is not the RTL are errors (OI-44). Run a
Yosys flow alone the same way: `PATH="$PWD/tools/shim:$PATH"`.

Quicker loops: `tools/check-skel.sh` builds `build/skel/ccv-skel`;
`tools/check-kernel.sh` runs every kernel with its coverage bins and its
negative controls; `tools/check-sv-hosted.sh` runs the same blocks inside the
SV top. Every claim in the gate has a negative control that must fail. Never
weaken a control to get green.

## The swap boundary

Each block, stub or model, reads only its own receivers and writes only its
own senders (`sim/skel/stub.h`). It uses ccv-sim's oracle for checks, never
for decisions. The SV-hosted run proves it: a block that shares state behind
the ports diverges there. Block implementations are listed in
`sim/skel/blocks.list`, which both hosts build from.

## Design docs outside the repo (Claude docs, the user's account)

Pinned copies, which grep can reach, are in `docs/design-snapshots/`. The
live doc wins; refresh a copy, never edit it (`docs/design-snapshots/README.md`).

- OOE microarchitecture, Stage 4: https://claude.ai/artifact/7tpEyGaCvfdvYYWUQJvJSU
- Interface changes and the closed Review tab (A-n rows): https://claude.ai/artifact/EcuSx6yXG4dCmkT2ky2Cb7
- Per-block architecture specs: https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35
- Block partitioning and interface spec (the arch agent's): https://claude.ai/artifact/7n8Uv33XAvxziZ7Xyz9jCz

## Context and handoff (DA, 2026-10-30)

Every agent keeps `.claude/handoff/<PREFIX>.md` current: its working rules
beyond this file, branch tips, runs in flight, register bookmarks and open
work, most urgent first, in a few kB. Update it when a task ends, not only
before a compaction: nothing writes it for you. After every compaction the
SessionStart hook in `.claude/settings.json` (`.claude/hooks/handoff.sh`)
prints it, finding the prefix from the session id in
`docs/register/roster.json`. A session in custom-cuda-complier copies the
script and hook unchanged, and the script reads this roster from a
custom-cuda-core checkout beside it (or `$CCV_ROSTER`, or a copy at that
repo's `docs/register/roster.json`, which CP checks against this one in its
daily sweep). Instructions given only in conversation do not
survive a compaction; put them here or in the handoff.

## Sessions working side by side

- The top-level session owns `schema/`, `params/`, `tools/`, `rtl/top/` and
  the block stubs.
- A per-block session owns its own model files.
- An interface change is a row for the top-level session to apply. It is
  never a direct schema edit from a per-block session.

## The cross-agent register

Every agent communicates through *CCV cross-agent register* (Claude doc):
https://claude.ai/artifact/JApHYjaUESeq8tsGMGXMU5. Read its Conventions tab first.
- This session is **TI** (top-level implementation): it writes only the TI
  tab and mints `TI-n`. The OOE model session is **OI**; the OOE architect is
  **OA**; **AR** is the top-level architect; **DA** is Daniel.
- At session start, search every tab for `TI` in a Needs column (OA-11), and
  answer in the TI tab's responses table.
- The register skill, `.claude/skills/register/SKILL.md` (OA-18), says how:
  notify on every write that needs another agent, read only the rows a notice
  names, and sweep daily from per-tab bookmarks.
- A per-block session raises an interface change in its own tab with `TI` in
  Needs. The closed A-n register (A-25 to A-75) is pinned in
  `docs/design-snapshots/interface-review.md`; its open items moved to the
  register (A-75 is TI-1, A-71 is TI-2).
- `docs/open-items.md` (Q-n) stays the repo's own tracker. A Q-n that needs
  an answer from another agent or DA is raised as a TI row citing it.
