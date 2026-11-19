# DI handoff (DCU implementation)

Session `session_01QPk2jz5TVESyWMKVKjqqEA`, branch `ccr-5e4d6c70-n6402z`
(core and compiler). Start: `docs/dcu-impl.md` (MA's handoff), then
`docs/miu-impl.md` sections 1, 2, 4, 5, 8, 9 read as DI/DCU.

## Working rules beyond CLAUDE.md
- DI writes only the DI tab (node `1ea5d5b3-6e9c`) and mints DI-n.
- Never edit TI's files (schema, params, tools, sim/skel stubs, kernel.cpp's
  makeDcu, blocks.list, rtl/top). Ask with a DI row, TI in Needs.
- `sim/dcu/dcu_p1.cpp` is MA's resource model: read, never edit.
- Model layout (RCU pattern): `sim/dcu/dcu_core.{h,cpp}` (no skeleton
  deps, unit-tested by `sim/dcu/dcu_test.cpp`, `sim/dcu/run-tests.sh`),
  `sim/dcu/dcu_block.cpp` (ports only).
- Until TI lands the makeDcu hook, kernel runs use a local, uncommitted
  patch (scratchpad `makedcu-local.patch`): never commit it.
- No dates on tasks; no model identifiers in anything pushed.

## Timing frame (DCU-local; checked against the MIU tab's L1-hit budget)
- L = lead (valid) at DCU = H+2; P = payload lands (Stub::has) = H+3.
- Response valid launches at P + (CCV_LAT_L1_HIT - 5): P+2 at 7, P+3 at 8 (C),
  P+4 at 9 (B). A mispredict (C) launches one cycle later.
- A lookup's data-bank access starts at D (P under A and C, P+1 under B) and
  each bank is arbitrated in work(D) from what DCU holds then; the response
  launches at D+2 (A) or D+3 (B, C).

## Open work, most urgent first
1. Model M0: core, block, unit tests landed (c0d1d08b, 18 tests). Next: every
   kernel with CCV_DCU_IMPL=model (local patch), both hosts; bins and
   controls; cycles against the stub and p1.
2. Session home: ask Daniel (writes /home/user/.claude).
3. Gaps vs spec: probes (no MLC probe channel in the skeleton yet), CE
   injection (needs a DCU-side knob: a DI row to TI), the 2-entry writeback
   buffer's stall (now a bin), MA-25 vectors unwired (no channel yet).

## Register bookmarks (2026-11-19 start)
Conventions 20, DI 2, MI 1, MA 117, TI 486, DA 128. Others: outline + search DI.
Rows: DI-1 (TI: makeDcu 'model', blocks.list, check-dcu-unit, MA-25/26
params, credit vectors), DI-2 (MA: (C) mispredict vs half-rate bank).
Sweep task trig_012HeCB5PRdC5uQzvjzTtU7g, 02:43 Pacific.
