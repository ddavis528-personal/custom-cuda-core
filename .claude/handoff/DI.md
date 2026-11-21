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
  for the daily sweep (Daniel). DI-6 asks TI and MI to move DCU's M0
  blockers up. Hourly check: scheduled task trig_01BqmRibVjxu6zui4nfhhFzo
  (:32 each hour); delete it once DI-6 is met.

## Timing frame (DCU-local; checked against the MIU tab's L1-hit budget)
- L = lead (valid) at DCU = H+2; P = payload lands (Stub::has) = H+3.
- Response valid launches at P + (CCV_LAT_L1_HIT - 5): P+2 at 7, P+3 at 8 (C),
  P+4 at 9 (B). A mispredict (C) re-reads as a bank-conflict loser: due + 2
  at the earliest (DI-2).
- A lookup's data-bank access starts at D (P under A and C, P+1 under B) and
  each bank is arbitrated in work(D) from what DCU holds then; the response
  launches at D+2 (A) or D+3 (B, C).

## Open work, most urgent first
0. 6d65b57a pushed (RESUMED PASS, full): the sweep's 9 merges, MI's
   967914ff and TI's e8d8864b are on the branch.
   With TI's c8d19598 (not yet on a branch here; tried in the scratch
   worktree /tmp/claude-0/-home-user/bfe83fc4-cb75-557c-bad7-b1316bec67fe/scratchpad/p1b,
   never push it), CCV_DCU_IMPL=model check-kernel is clean (rc=0).
   The pair (dcu=model,miu=model) fails 10 lines. TI-504 says 1f781123 has
   them: 5 IMPL_PINS rows, vadd4 orphan=2, and straggler demotion at:342
   keyed through impl_pins. The other 3 lines are MI's own model: predlane
   (MI-8, by design; TI owes the quiesced_at_end exemption), a UE with
   the track table full not being core-fatal, and fet-reset-on-kill not caught.
   Next: once c8d19598 and 1f781123 are on a branch, merge them, rerun
   check-kernel (model, then pair) and write the M0 exit row for MA:
   check-kernel clean, every bin reached, SV-hosted PASS, S1 and cm32priv.
1. Phase 1b (DI-5; AR-394, OA-454): S1 pair +1.62% vs the stubs (worst
   vadd4 +25.4%), DCU alone +1.27%. cm32priv: pair 2090969, DCU alone
   2105390, stubs 2095682. With notices off, fill_notice=0 and cmpl_hint=0.
   RTL waits on MA's Phase 2 (AR-394: a notice from MLC's tag lookup).
2. DI-4 closed (MA rev 135): notices are off by default; an un-noticed
   refill lands at F+4, a noticed one at F+6. SV-hosted PASS with the model.
3. Friday pings: all 11 agents answered. OI's and RH's rosters lack DI
   (sender=stale); they fix it at their session start.
4. Gaps vs spec: probes (no MLC probe traffic in the skeleton), CE injection
   on the DCU side (a DI row to TI), the 2-entry writeback buffer stall (a
   bin now), MA-25 vectors computed but unwired.
5. Session home: installed (Daniel approved); `--check` matches. Recheck in
   the daily sweep and after merges touching .claude/.
6. A gate gate-wait reports killed: once TI's 6464a030 is merged, rerun the
   same command with CCV_RESUME=1 (TI-490; RESUMED PASS counts as full).
7. First push of a new session branch: create the remote branch at its base
   commit first, or gate-push cannot fetch it.

## Register bookmarks
Conventions 20, DI 17, MI 17, MA 135, AR 400, OA 460, TI 504, DA 128
(sweep of 2026-11-20 10:43 UTC; OI 395, RA 157, RI 91, IS 201, CP 160 by search). Others: outline + search DI.
Rows: DI-1 (TI: makeDcu 'model', blocks.list, check-dcu-unit, MA-25/26
params, credit vectors), DI-2 (agreed: mispredict = loser path, due+2;
MA rev 121, 0a96bc26), DI-3 (TI: per-impl check-kernel pins), DI-4 (MA: refill floor;
M0 progress figures).
Sweep task trig_012HeCB5PRdC5uQzvjzTtU7g, 02:43 Pacific.
