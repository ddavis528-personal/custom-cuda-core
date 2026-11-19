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
- Bank arbitration for the lead cycle L is decided in work(P) (lag 1):
  only the index (bank) is used for it, so it is causal.

## Open work, most urgent first
1. Phase 0: register sweep and bookmarks; DI-1 to TI (makeDcu value, blocks
   list, check-dcu-unit, WAYPRED/QDEPTH/STDATA params, credit-return vectors);
   sweep task at minute 43; session-home (ask Daniel).
2. Model M0: core + block + unit tests; every kernel on both hosts; bins.

## Register bookmarks
(set at first sweep)
