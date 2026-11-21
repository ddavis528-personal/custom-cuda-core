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
0. M0 met (DI-8, sent to MA): 3a2703ef pushed, with TI-506/507 and MI's
   d639adb2 merged. Against the MIU stub, check-kernel and check-sv-hosted
   are clean under CCV_DCU_IMPL=model. Cycles: +1.69% over the stub (66
   kernels), +0.74% over p1 on the 54 where p1 runs. p1 hangs on 12 kernels
   because it sends no MA-25 credit returns (MA's file; asked in DI-8).
   f92a89fc made the credits strict and holds a store miss's store-data
   entry until the fill merges it (DCU spec).
   Phase 1b: the pair passes check-kernel clean. check-sv-hosted: the vadd
   machine check is MI's (it fails with the DCU stub too). lnorm1 SV vs C++
   at cycle 81, and RCU RTL in the SV top (transp4, vadd4), fail only under
   the pair. A rerun is in the scratch worktree
   /tmp/claude-0/-home-user/bfe83fc4-cb75-557c-bad7-b1316bec67fe/scratchpad/m0w
   (logs one level up: m0-*.log, m0-s1.txt); never push from it. Then
   write the phase 1b row.
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
Conventions 20, DI 20, MI 17, MA 135, AR 400, OA 460, TI 504, DA 128
(sweep of 2026-11-20 10:43 UTC; OI 395, RA 157, RI 91, IS 201, CP 160 by search). Others: outline + search DI.
Rows: DI-1 (TI: makeDcu 'model', blocks.list, check-dcu-unit, MA-25/26
params, credit vectors), DI-2 (agreed: mispredict = loser path, due+2;
MA rev 121, 0a96bc26), DI-3 (TI: per-impl check-kernel pins), DI-4 (MA: refill floor;
M0 progress figures).
Sweep task trig_012HeCB5PRdC5uQzvjzTtU7g, 02:43 Pacific.
