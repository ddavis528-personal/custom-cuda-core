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
- DI-1 landed (TI-497, cb8ca9be, merged here): CCV_DCU_IMPL=model and
  check-dcu-unit are real; the local hook patch is retired.
- No dates on tasks; no model identifiers in anything pushed.
- Merge a blocker the moment it lands on a working branch, never waiting
  for the daily sweep (Daniel). Ask its owner to move it up (a DI row and a
  notice), and set an hourly check while it is pending.

## Timing frame (DCU-local; checked against the MIU tab's L1-hit budget)
- L = lead (valid) at DCU = H+2; P = payload lands (Stub::has) = H+3.
- Response valid launches at P + (CCV_LAT_L1_HIT - 5): P+2 at 7, P+3 at 8 (C),
  P+4 at 9 (B). A mispredict (C) re-reads as a bank-conflict loser: due + 2
  at the earliest (DI-2).
- A lookup's data-bank access starts at D (P under A and C, P+1 under B) and
  each bank is arbitrated in work(D) from what DCU holds then; the response
  launches at D+2 (A) or D+3 (B, C).

- Memory: 15 GB, 4 cores. Never run a coremark ccv-skel (up to 5 GB each)
  beside a gate: it OOM-killed check-cg once. Gates take ~3.5 h (ngd, cg).
- check-cg --unit never applies the module budget (max(2% flops, 7)); use
  scratchpad/cgbudget.py <unit> (execs check-cg with the budget printed).
- Scratch worktrees (never push from them): scratchpad/m0w (old port work),
  scratchpad/ma33 (MA-33 debug instrumentation: g_dbg_site, DBG prints).

## Open work, most urgent first
1. MA-34 RTL GATED AND PUSHED (69659b33, SCOPED PASS 24/28): per-bank
   dcu_mshr, g_mpick in dcu_fill (DI-67), H+6 (DI-66), budgets. DI-68 (DI
   rev 107) told MA. Merged MA's branch (27e67d25): DI-63 p1 fix 669cfdde
   and MA-35 two-field fold (f4952819; its sim/dcu edits reviewed: correct,
   one fold function at the run's sets). DI-63 verified (needs
   CCV_MIU_IMPL=model: vadd4 75 drops / rope 210, 0 CHECKs; control 150) and
   answered with MA-35 in DI-69 (rev 108, notice sent); merge pushed
   05185259. 11-28 sweep merged 8 branches (sweep-merge.sh), gating;
   that answers OA 508.
   Next gate (bundle): increment B, DI-25 btag fill write, rarb/rslot
   growth, bdat wdata select, TI-537 if landed. Later: lone-bank backlog
   report (dcu_mpick_pass, wait cycles, gtw and cm128) with the dcu_fill gtw
   recheck (MA rev 226 (1)).
2. TI-590 (TI rev 592), low: re-measure dcu=model IMPL_PINS rows on ti-rp's
   params (held-wait demote dcu=model 862, pair 876; UE rows); the vadd4-swap
   rows are gone. Answer in the DI tab.
3. DI-38 (1) fill-unheld kernel line; DI-38 (5) coremark128 pair watchdog
   (MI first, TI-547).
4. RTL slice 2 increment B: tag-stale marking in dcu_bctl; a relook that
   misses joins the miss-wait FIFO, retries on port 0 (DCU tab rev 127),
   (dcu-late-miss-port retired by MA rev 222). Then btag's fill tag RF
   write (DI-25), rarb/rslot growth, dcu_bdat wdata select.
5. TI-537: one common credit module (TI); dcu_mshr's cr_q_cc05h moves to it.
6. Later: price VICTIM_AT=2, wb_ack_delay, re-measure DI-23; watch DA rev
   134's TB read class (1000 cycles, 1 line per 8) for MA's fill sizing.
7. Gaps vs spec: probes (no MLC probe traffic), CE injection on DCU side,
   MA-25 vectors unwired.
8. Merges: use tools/sweep-merge.sh <theirs> <msg> (TI-605). Older:
   criss-cross history; ort can hang (timeout 60), resolve refuses
   >8 bases: then read-tree -m -u <newest base> HEAD <theirs>, merge-index,
   commit-tree with both parents. Session home installed; --check in sweep.

## Status
- Pushed 393d8275 (SCOPED PASS 11/28). DI-63 (p1 ignores MA-27 drop, OI-225):
  MA built the fix (588 -> 0), lands after MA's gate. DI-64 confirmed by MA
  rev 225 (DCU tab rev 150). Forced-model kernel diffs (transp4, vadd ue,
  privwin, no-resource-cap) come from TI's params (f1ef8080), told TI (DI-64).
- Pongs 11-27: OI and RH sender=stale; tell Daniel if still stale next Friday.

## Register bookmarks
Conventions 20, DI 108, MI 77, MA 233, AR 437, OA 518, TI 609, OI 439, DA 136,
RA 164, RI 101, IS 201, CP 160 (sweep 2026-11-28). DI tab last row DI-69 (row id .130369).
Sweep task trig_012HeCB5PRdC5uQzvjzTtU7g, 02:43 Pacific.
