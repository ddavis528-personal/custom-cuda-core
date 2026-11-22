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

## Open work, most urgent first
-1. Phase 2a slice 1 RTL pushed at 3b6b66f2 (full PASS): dcu_cap, dcu_btag,
   dcu_bctl (k=4 after TI-518; budgets by MA rev 157, DI-26 closed).
   DI-27 (rev 44) to TI: TI-518 done in the model; DI-24 (4) run-rtl.sh and
   cg-units.json are in, TI to add the DCU RTL gate section. Next (MA's DI-26
   answer): model PLRU updates at D2+1 for every hit, losers included; a
   coverage bin for the owed ent_ret count's maximum. Then slice 2 from MA.
0. MA-27/28 (c) built and landed: drop discard and ECC in the arrays
   (8b6090d0, cherry-picked by TI as part of doowtf b8233a39; transp4 pin 55,
   dcu-ecc-recode control). Merged here; once pushed, notify MI (MI-19 (1),
   DI-17): MI pushes its syndrome/drop sender 2d2259bf on top, then merge it
   and run the pair check-kernel plus dcu-drop-credit/dcu-drop-answers under
   dcu=model miu=model (ask TI to add them, DI-16 (c)). 7bf5073a (drop only,
   scratch) is superseded: do not use. DI-18 decided (AR-403, MA rev 148):
   MIU corrects a CE; DCU counts, rewrites, sends nothing more. Next: UE path
   (AR 370: clean line invalidate+refetch, dirty core-fatal) when TI adds UE
   injection; then spec gaps (item 4).
1. Phase 1b met (DI-11) at 9d251d57. TI made the bank controls run under
   all four MIU x DCU sets (TI-512, 0ee1c423); MA's p1 now returns credits
   (d494cf9b) and runs all 66 kernels; model +0.56% over p1. Both merged,
   pushed at 2529d430. Then: the spec gaps (item 4), RTL once MA's Phase 2
   lands (AR-394). Scratch worktree for tests (never push from it):
   /tmp/claude-0/-home-user/bfe83fc4-cb75-557c-bad7-b1316bec67fe/scratchpad/m0w
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
Conventions 20, DI 44, MI 35, MA 157, AR 409, OA 468, TI 517, OI 401, DA 131
(sweep of 2026-11-22; RA 157, RI 91, IS 201, CP 160 by search). Others: outline + search DI.
Rows: DI-1 (TI: makeDcu 'model', blocks.list, check-dcu-unit, MA-25/26
params, credit vectors), DI-2 (agreed: mispredict = loser path, due+2;
MA rev 121, 0a96bc26), DI-3 (TI: per-impl check-kernel pins), DI-4 (MA: refill floor;
M0 progress figures).
Sweep task trig_012HeCB5PRdC5uQzvjzTtU7g, 02:43 Pacific.
