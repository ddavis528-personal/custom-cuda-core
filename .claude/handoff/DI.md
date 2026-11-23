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
-8. DI-43 + fold-table port (DI-44..47) BUILT in scratch worktree m0w
   (scratchpad/m0w; notes scratchpad/handoff-pending.md), NOT on main. Port:
   4 credits, 2 entries, yield-once; controls port_nowait, always_yield,
   credit_plus, rel_at_grant; bench, NGD, CG pass. Blocked on: TI's
   two-writer CCV-L23 form (OA 479 -> DA) for 5 lines, MA-32 (16943021, only on
   gate-scratch/TI-ma32). MA CONFIRMED 4 credits / 2 entries (MA rev 194,
   DCU tab rev 126; overflow control 5 credits = ours); MA signs the port-level
   L23 entry when TI's form lands: send MA its text then. When they
   land: merge, copy bctl.sv, test/dcu/{bctl_tb.cpp,cg-build.sh,run-rtl.sh},
   sim/dcu/{dcu_core.h,.cpp,dcu_test.cpp} from m0w (NOT its *.ngd.json), add
   the port-level feedback entry (MA signs), gate-push.
-7. PUSHED d400b928 (SCOPED PASS 28/28): sweep merge, UE first answer
   (3f8e66c3), dcu_mshr CG-3 (c4061f75), host CCV_DCU_WB_ACK_DELAY=8.
   Register rev 73: DI-38 tip posted, DI-33 (d) done, DI-34 closed; notices
   to TI, MI, MA. When TI moves dcu-wb-refetch under the knob (TI-530 (2)):
   set dcu_block.cpp's default back to 0. When TI's tblat fix (8daf7a2c,
   TI-532/AR-410) lands: re-measure DI-23's localsp numbers
   (CCV_MIU_IMPL=model CCV_MLC_WARM=1, TI-522).
-6. IN FLIGHT: gate-push of a2b4d5c4 (dcu_mshr send record CG fix, credit
   floor; job log /root/ccv-logs/job-gate-push-20261123-055701-29983.log;
   wait with tools/gate-wait.sh <log>). When it passes: cherry-pick m0w's
   aa588624 (dcu_mshr retry port per DI-35: rov/rstp offers, rgv/rgb grant
   from flops, payload captured at R+2 = D2; head stamps; depth 23.7, CG
   ~53/58; model stamps; --control retry) and this handoff into main, then
   gate-push again. m0w = detached worktree at aa588624 (stash holds old
   leftovers, drop it).
-5. NEXT: dcu_bctl slice 2. PLAN (posted as DI-36, tab rev 64, notice sent): every
   lookup the bank takes writes a queue entry at D0 from the channel wires
   (its credit guarantees one; QDEPTH = entries = MIU credits, an entry
   leaves when answered or gone to MLC, per params) holding the full
   payload (PA[47:7] 41, req_id 6, slot 2, op 2, excl 1, fold 4, std 4,
   tag result, miss-wait, cause, stale). The slice 1 queue held only
   losers. A miss-wait marks its entry at D3 from dcu_mshr's outcome;
   one 10-bit head stamp per bank; the offer (rov/rstp) and the head's
   payload from flops; grant rgv/rgb in; outcome (ov/owait/owhy) at D3.
   A bank with a waiter or a retry in flight keeps its new misses itself.
   Then dcu_fill, btag/rarb/rslot growth, parts 2-4.
-5a. INCREMENT A DONE in m0w (commit after aa588624/7d7d0943): dcu_bctl
   slice 2 entries (alloc at D1 from dcu_cap's D1 flops, NOT D0: the pick
   is stage-04 state and D0 cannot read it, CCV-L23), miss-wait FIFO with
   a delayed change-only index write (CG-3), head offer rov/rstp/payload
   (ports tagged _cc04h in bctl's frame; dcu_mshr's names differ), outcome
   in (ov/owait/owhy_cc04h), credits at waiter access / granted D2 hit /
   placement; bank order: no dv while the bank holds a waiter (dcu_mshr's
   owi covers the cycle after a wait). dcu_mshr: mv = dv & !hit (dv from
   bctl flops, hit from btag flops: the D2=H+4 hand-off). Benches: bctl
   (--control order new), mshr; depth bctl 24.3, CG 68/94 loose.
   TELL MA (DI-36 update): D1 not D0; the dv/hit hand-off; ports.
   MODEL FOLLOW-UPS: (1) done a03d2345 (credits at D2 hit / D3
   placement; relook and re-read no second credit); (2) retry lag 5
   (kRetryLag) done, uncommitted until check-kernel reruns; (3) a cause-2
   (filled) waiter must look up again after its fill's write, never
   allocate anew (increment B: btag re-read; tag-stale).
-4b. a2b4d5c4 pushed (SCOPED PASS). ba085cda (TI-529) merged as b11e15bb;
   m0w's commits cherry-picked on it (tip 109f34e0); gate-push running.
   On push: post the tip in DI-38 for TI (TI-530 re-pins with it).
-4c. DI-37 DONE in model (dcbdd930): held fill K=4, CHECK K+gap+1 (MA rev
   115 amended), bins dcu_fill_wait_{victim,store,late}_max, control
   dcu-fill-unheld (needs TI whitelist; proved locally: 11 CHECKs). RTL:
   build the same rule into dcu_bctl's fill arbitration with dcu_fill.
   check-kernel does NOT rebuild skel: run tools/check-skel.sh first.
   Real base worktree scratchpad/m0base (d2d298a2); kern-B.log vs kern-N.log.
-4d. DI-38 (tab rev 68) to TI: whitelist + line for dcu-fill-unheld;
   dcu-wb-refetch kernel control unreachable under RTL credit timing (unit
   test covers); deny-ownership predswap req_id pin; IMPL_PINS transp4 33,
   slotform 49; knob CCV_DCU_WB_ACK_DELAY=32 (fbec626b). TI-531: cm128 memop
   hold is TI's testbench memory map, line kept until AR rules. Tell TI which commit carries the model.
-4. DI-34: MA rev 167/168 accepted all; close the row once bctl growth
   lands. DI-35 (bctl retry): MA rev 169 / DCU tab rev 112 accepted:
   (1) dcu_mshr picks the oldest of 8 bank offers (valid + 10-bit stamp,
   mod-2^10 compare, ties lowest bank), flops it as rtv and returns a
   one-hot grant; picked bank's payload 8:1 from bctl output flops at D2
   (mshr retry port grows to 8 offers + 8 x ~60-bit payloads + grant out).
   (2) a bank offers its oldest waiter from the cycle after it waited, no
   new offer while its retry's outcome is pending; a WAIT-AGAIN RE-STAMPS
   the head with the current count (MA's change; mirror in the model:
   born = now on a failed retry). (3) granted bank reads mshr's D3
   outcome: placed leaves + ent_ret; a bank with a waiter or pending retry
   queues its own new miss itself (never retry + new miss in one cycle).
   Spec digest of bctl slice 2 (rev 111): scratchpad/dcu.txt lines 2-142;
   entry fields ~75 flops (req_id 6, slot 2, PA 41, fold 4, op 2, excl 1,
   std 4, tag result ~5, age 5, mw 1, cause 2, stale 1); fill write as a
   queue waiter; victim choice/reserve/MRU; tag-stale (set,way) compares.
-3. RTL slice 2 part 1, dcu_mshr (task #7). Pushed a6b8a4eb (model parts
   1-4, SCOPED PASS; gate-push needs CCV_PUSH_BRANCHES=ccr-5e4d6c70-n6402z
   or it pushes nothing). v1 failed depth (92 NGD) and CG-4; v2 (ports, not
   banks: retry port + 4 slot ports; per-port ids from nf picked a cycle
   ahead; D3 wide writes from per-port records, D2 forwards from them;
   AND-OR mask writes for ctl flops and the FIFO, as bctl's fold rows; whole
   D2 loop tagged stage 05) is in the scratch worktree m0w: bench 5 seeds
   PASS, controls nomerge/order caught, lint clean; check-ngd/check-cg
   results in scratchpad mshr_ngd2.log / mshr_cg2.log. Plan:
   scratchpad/mshr-plan.md. DI-34 (rev 58) asks MA to accept the 4
   deviations; Q(3) (waiter payload home) still open. TODO after: move the
   C++ model's id choice to the RTL's rule (dcu_core.cpp, startMiss), copy
   m0w's dcu_mshr.sv, .ngd.json, mshr_tb.cpp, cg-units/cg-build/run-rtl
   edits into the main checkout, commit, gate-push. Then dcu_fill.
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
   NOW: parts 1-4 all in the model (part 3 701c7fdc, part 4 + probe
   channels via chanId 8d5bcf64; unpushed). Push waits on DI-32 (TI:
   whitelist + hint_slot_taken from mload; check scheduled
   trig_01D5k3kYXAaxxiZBffJ2UTGZ). DI-33 (rev 54, TI+MI): part 3-4
   controls (dcu-st-shared on narrowadd, dcu-st-dirty on rope; the rest
   whitelist-only), Ch probe handles, MLC-stub probe injection, UE
   first-answer support. On TI's fix: merge, check-kernel
   (CCV_DCU_IMPL=model; never rebuild build/skel during it), gate-push.
   Then RTL (task #7). Kernel run on part 4: ~/ck5.out.
   OLDER STATUS: stages A-D committed (f84e9924, 8b01a601; unpushed). Unit
   tests pass with every part 1-2 control refused. Stage A kernels 393/393;
   A-C kernels fail only "vadd4, both models, notices on" (hint_slot_taken=0,
   MIU-side coverage: needs two notices a cycle on one MIU slot) + its
   hint-same-slot control; rerun on D pending (~/ck-kernel3.log). Next:
   triage that, tabulate new bins over the kernels, a DI row to TI for the
   kernel-level controls (drop-writeback already there), then part 3.
   Transcriptions: scratchpad dcu-slice2-p12.md and dcu-slice2-p34.md.
   Parts 3 (stores, rev 94) and 4 (probes, UE 2nd answer, repair/BIST, rev
   96) also landed: transcription in scratchpad dcu-slice2-p34.md (rebuild it
   with an agent if the scratchpad is gone). Part 3 changes slice 1: tag RF
   word 136 bits (no dirty), dirty bits in dcu_bctl flops (512/bank), same
   (set,way) store ordering in the queue, store hit ack on own slot hit=1
   no data, read->write 5, <=2 stores/bank in flight, dcu_bdat wdata 6:1.
   New modules dcu_bstd, dcu_bstm (8 each), dcu_prb. DI-31 closed (rev 52):
   MA fixed the stale 140-bit passages (DCU tab rev 104).
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
Conventions 20, DI 69, MI 39, MA 173, AR 414, OA 474, TI 529, OI 405, DA 131
(sweep of 2026-11-23; RA 158, RI 91, IS 201, CP 160). Others: outline + search DI.
Rows: DI-1 (TI: makeDcu 'model', blocks.list, check-dcu-unit, MA-25/26
params, credit vectors), DI-2 (agreed: mispredict = loser path, due+2;
MA rev 121, 0a96bc26), DI-3 (TI: per-impl check-kernel pins), DI-4 (MA: refill floor;
M0 progress figures).
Sweep task trig_012HeCB5PRdC5uQzvjzTtU7g, 02:43 Pacific.
