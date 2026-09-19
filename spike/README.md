# Stage 1a — tool-support spike

**Question this answers (§7, §8 Stage 1a, §9):** which SystemVerilog Assertion
constructs are *actually usable* across the free toolchain — Verilator, Icarus
Verilog, and `sby`/Yosys — before §8 Stage 1b locks the assertion primitive
library's syntax. The LRM is not the constraint; the tool-support intersection is.

## Why every cell has two verdicts, not one

A construct that **parses** but is silently **never checked** is the dangerous
cell, not the one that errors out. An error is a compile failure you find in
five seconds; a property that elaborates and never fires looks exactly like a
property that passes. §7's whole formal posture rests on properties that bite,
so the spike measures biting, not parsing.

Every case is therefore written so that the **fixed stimulus below violates it**.
A tool that reports a failure gets `CHECK`. A tool that compiles it cleanly and
reports nothing gets `SILENT` — which for this project is a worse answer than
`PARSE-FAIL`, and is called out as such in the results.

## The fixed stimulus

Uniform across every simulation case, so that cases are comparable and a case
file carries no stimulus of its own:

| signal | behaviour |
|---|---|
| `clk`  | 10ns period, first posedge at t=5ns |
| `rst`  | 1 for the first two cycles, 0 from cycle 2 onward |
| `a`    | 1 on cycle 3 only, 0 otherwise |
| `b`    | 0 always |

Cycle numbering counts posedges from 0. So `a |-> b` is violated at cycle 3,
`a |=> b` at cycle 4, and anything keyed off `$past(a)` at cycle 4.

`cover` cases invert the polarity: they must be **reached**, and an unreached
cover is the failure (§7 — an unreachable `cover` is a dead property or a
mis-written one).

## Formal cases

Under `sby`, DUT inputs are free variables rather than the stimulus above, so a
false property fails by construction. That is the discriminator: BMC reporting
FAIL means the property reached the solver; BMC reporting PASS on a knowingly
false property means it was dropped. Case 12 inverts this to test `assume` as a
cut-point — with the `assume` honoured the proof passes, and a PASS there is
the evidence that `assume` is doing work rather than being ignored.

## Running

    ../tools/run-spike-1a.sh

Writes `../docs/stage1a-tool-support.md` (the matrix §8's exit criteria ask for)
and `../test/golden/stage1a-matrix.json`.
