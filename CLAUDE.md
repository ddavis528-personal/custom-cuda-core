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
- `params/links.json`: repeater stages per channel.
- Generated, never hand-edited: `sim/generated/`, `rtl/generated/`,
  `rtl/top/`, `docs/payload-spec.md`, `docs/trust-report.md` and
  `docs/walkthrough.md`. Regenerate them with `tools/gen-*.py`;
  `tools/verify.sh` fails if any is stale.
- Kernel oracles come from the pinned compiler snapshot (`tools/compiler.lock`,
  `tools/gen-oracle.sh`). Nothing of ccv-sim's output is checked in.

## The gate

```
./tools/setup-toolchain.sh   # a fresh container needs this once
./tools/verify.sh            # ~25 min; must be green before a push
```

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
- A per-block session raises an interface change in its own tab with `TI` in
  Needs. The closed A-n register (A-25 to A-75) is pinned in
  `docs/design-snapshots/interface-review.md`; its open items moved to the
  register (A-75 is TI-1, A-71 is TI-2).
- `docs/open-items.md` (Q-n) stays the repo's own tracker. A Q-n that needs
  an answer from another agent or DA is raised as a TI row citing it.
