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
-2. SLICE 2 parts 1+2 landed (DCU tab rev 89 "Slice 2, part 1: miss buffers
   and fills", rev 91 "part 2: eviction and writeback"; spec doc
   DJeg9Hh8rkPDecq4hrAz35, DCU tab node c18a112b-d2c6; MA rev 159-160, answers
   DI-21). Parts 3 (stores) and 4 (probes, UE) follow with notices. Plan:
   MODEL FIRST (task #6), then RTL (task #7). Model gaps found:
   (1) MSHR freed at fill receipt -> keep until W and all answers; wait cause
       filled-not-written; at W a dirty victim turns the entry into the
       writeback's (kind wb, unsent) until MLC's ack (ack: no fill buffer,
       credit at once, entry freed F+1).
   (2) install at fill -> victim chosen+reserved+MRU at F+1, line written at W
       (>= F+3 clean, >= F+5 dirty: victim read first, 2 cycles ahead), a
       queue waiter under BANK_AGE; tag-stale re-look for lookups reading
       after W; stores hitting a reserved dirty victim wait (miss-wait).
   (3) channel stall (stalled_/accepting) -> per-bank miss-wait in the bank
       queue holding the entry credit; a bank's waiters retry oldest first
       ahead of new misses; a new miss waits if its bank has a waiter.
   (4) MLC fill credit at take -> creditAtRelease on ccv_mlc_dcu_rsp: 4 fill
       buffers, credit back when written and last answer left. 2 wb buffers;
       wb full: victim read waits, fill buffer (credit) held (DI-21).
   (5) MLC req order: writebacks oldest first, then oldest unsent miss;
       straight-from-D2 (valid H+5) only when neither waits.
   (6) late answer slots: aged bank answer > fill answers oldest first >
       other late lowest bank; fill answers take any slot.
   STATUS: stages A-C (items 1-4, 6) committed f84e9924 (WIP, unpushed),
   unit tests pass; stage A kernel run done/pending; stage D next (H+5
   check, bins, controls' unit tests, tag-stale, reserved-victim stores).
   Parts 3 (stores, rev 94) and 4 (probes, UE 2nd answer, repair/BIST, rev
   96) also landed: transcription in scratchpad dcu-slice2-p34.md (rebuild it
   with an agent if the scratchpad is gone). Part 3 changes slice 1: tag RF
   word 136 bits (no dirty), dirty bits in dcu_bctl flops (512/bank), same
   (set,way) store ordering in the queue, store hit ack on own slot hit=1
   no data, read->write 5, <=2 stores/bank in flight, dcu_bdat wdata 6:1.
   New modules dcu_bstd, dcu_bstm (8 each), dcu_prb. DI-31 (rev 51): asked
   MA to fix stale 140-bit passages; part 3 wins meanwhile.
   Controls: dcu-mshr-nomerge, dcu-fill-nostale, dcu-fill-early,
   dcu-miss-reorder, dcu-wb-drop (= drop-writeback), dcu-wb-early,
   dcu-wb-refetch, dcu-wb-store; part 3 dcu-st-noorder, -mergeall,
   -shared, -dirty; part 4 dcu-ue-noanswer, -stale, dcu-prb-nostore,
   -nodirty, -stale. Bins/CHECKs per the tab. Kernel-level controls go in
   TI's check-kernel.sh: ask TI with a DI row once the model has them.
-1. Phase 2a slice 1 RTL pushed at 3b6b66f2 (full PASS): dcu_cap, dcu_btag,
   dcu_bctl (k=4 after TI-518; budgets by MA rev 157, DI-26 closed).
   DI-27 (rev 44) to TI: TI-518 done in the model; DI-24 (4) run-rtl.sh and
   cg-units.json are in; TI added the dcu_rtl gate section (TI-521, 8e784c88,
   merged at 6da84ccf; DI-27 closed, DI-29). MA's DI-26
   follow-ups done at e68a9ddf (DI-28, rev 45): PLRU at D+3 for every hit,
   dcu_ent_owed_max. Next: slice 2 from MA.
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
Conventions 20, DI 51, MI 35, MA 162, AR 409, OA 468, TI 519, OI 401, DA 131
(sweep of 2026-11-22; RA 157, RI 91, IS 201, CP 160 by search). Others: outline + search DI.
Rows: DI-1 (TI: makeDcu 'model', blocks.list, check-dcu-unit, MA-25/26
params, credit vectors), DI-2 (agreed: mispredict = loser path, due+2;
MA rev 121, 0a96bc26), DI-3 (TI: per-impl check-kernel pins), DI-4 (MA: refill floor;
M0 progress figures).
Sweep task trig_012HeCB5PRdC5uQzvjzTtU7g, 02:43 Pacific.
