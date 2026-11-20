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
  P+4 at 9 (B). A mispredict (C) re-reads as a bank-conflict loser: due + 2
  at the earliest (DI-2).
- A lookup's data-bank access starts at D (P under A and C, P+1 under B) and
  each bank is arbitrated in work(D) from what DCU holds then; the response
  launches at D+2 (A) or D+3 (B, C).

## Open work, most urgent first
0. Last sweep merged 9 branches (a9077fc1, full PASS). MI's model is on
   ccr-58815650-0ch1hh (now merged here): its page walks issue DCU reads that
   count toward CCV_DCU_UE_INJECT; MI-4/MI-5 ask TI to pin UE checks per MIU impl.
   Phase 1b: run DI's model against MI's once both hooks land.
1. Model M0 status (pushed 26740eef, SCOPED PASS): 64/64 kernels == ccv-sim
   with CCV_DCU_IMPL=model, +1.78% mean cycles vs the stub. check-kernel has
   5 timing-only diffs (ldpar, transp4@ECC, late, stall bins; the
   spm-shared-region control's pinned message): DI-3 asks TI for per-impl pins.
   Waiting on DI-1 (hook, blocks.list, check-dcu-unit, params, credit vectors).
2. Local hook patch for runs: scratchpad makedcu-local.patch (re-create from
   DI-1's text if the scratchpad is gone); never commit it; revert before
   gate-push. Sweep script: scratchpad sweep.sh.
3. DI-4 closed (MA rev 135): notices off by default (4cf7c183, pushed);
   un-noticed refill at F+4 (92e6037e); CCV_DCU_NOTICE=1 keeps them.
   S1 off -0.43%; cm32priv off 2105390 / on 2105392 / stub 2095682.
   MI showed the same with its model (MI tab rev 12). TI-495 (on ti-mi9,
   gating after the hooks): IMPL_PINS per CCV_DCU_IMPL, notice pins under
   NOTICE=1, vadd4 orphan=1, class-matched controls. Answered with 4cf7c183.
   SV-hosted PASS with the model. Next: when TI-495/DI-1 land, rerun
   check-kernel with the model and write the M0 exit row (MA reads it);
   check every bin reached; then phase 1b with MI's model.
4. Gaps vs spec: probes (no MLC probe traffic in the skeleton), CE injection
   on the DCU side (a DI row to TI), the 2-entry writeback buffer stall (a
   bin now), MA-25 vectors computed but unwired.
5. Session home: installed (Daniel approved); `--check` matches. Recheck in
   the daily sweep and after merges touching .claude/.
6. A gate gate-wait reports killed: once TI's 6464a030 is merged, rerun the
   same command with CCV_RESUME=1 (TI-490; RESUMED PASS counts as full).
7. First push of a new session branch: create the remote branch at its base
   commit first, or gate-push cannot fetch it.

## Register bookmarks (2026-11-19 start)
Conventions 20, DI 11, MI 12, MA 135, AR 395, OA 455, TI 495, DA 128
(sweep of 2026-11-19 10:43 UTC; OI 380, RA 156, RI 91, IS 199, CP 160 by search). Others: outline + search DI.
Rows: DI-1 (TI: makeDcu 'model', blocks.list, check-dcu-unit, MA-25/26
params, credit vectors), DI-2 (agreed: mispredict = loser path, due+2;
MA rev 121, 0a96bc26), DI-3 (TI: per-impl check-kernel pins), DI-4 (MA: refill floor;
M0 progress figures).
Sweep task trig_012HeCB5PRdC5uQzvjzTtU7g, 02:43 Pacific.
