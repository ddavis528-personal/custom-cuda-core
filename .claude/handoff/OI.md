# OI handoff (OOE model and RTL)

Updated 2026-10-31 15:30. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds OI's.

## Working rules
- The user is DA (Daniel). Standing order: rename top, atomics, barriers,
  AR-24 (d), then RTL items 5-8 (done but 7), then the ROB slices; no need
  to ask DA for a go unless there is a key decision point.
- Push only to `ccr-57eff422-5tdecg` (`git push -u origin HEAD:ccr-57eff422-5tdecg`,
  retry with backoff). Never push red: the clean gate is `tools/regen.sh`
  then `CCV_JOBS=4 ./tools/verify.sh`, run alone (no CoreMark beside it:
  memory). No PRs. Don't edit a tree while a gate runs in it.
- Owners: OA the microarchitecture and port budgets; DA waivers and
  anything over OA's 0.5%; TI schema/, params/, tools/ (OI carries a tools
  fix only when TI says so, as OI-89). Never weaken a negative control.
- Commits end with the Co-Authored-By and Claude-Session lines; no model
  ids in commits or artifacts.
- Register: write only the OI tab (node 384bc26c-cef6, table
  m8yvbw8rqgz.11664, rows: title, date, summary ending "Needs: X",
  detail). Notices via `.claude/skills/register/notice.py` and
  send_message. Pings weekly, Fridays (TI-49, DA).
- Trees in the scratchpad (/tmp/claude-0/-home-user/<session>/scratchpad):
  wt the sweep tree, wt3 slice 1 (pushed), wt4 slice 2 model work (at
  21f7150 + uncommitted model edits), wt5 slice 2 RTL (on the branch). Disk is a fixed allowance: delete build dirs
  you no longer need; one gate's build is about 15 GB.

## Daily sweep (scheduled task trig_01RHTzEomNoTP7mgfQxaNkmm)
Read every tab since the bookmarks; merge every remote branch that is
ahead (not release) into wt, gate, push; pongs; pings on Fridays only;
`tools/setup-session-home.py --check` (TI-50; on a mismatch ask DA to
approve the install again, never reinstall unasked).
- Session settings installed 2026-10-31 (DA approved): /home/user/.claude.
  The compact hook prints THIS checkout's .claude/handoff/OI.md: keep
  /home/user/custom-cuda-core's copy current, not only the branch's.

## Register bookmarks (revs read through)
Conventions 15, AR 260, OA 296, IS 182, TI 281, OI 250, CP 149, DA 98 (sweep 11-01). Pings: Friday 10-30's all
answered (checked 10-30); next pings Friday 11-06.

## Compute (DA, 2026-10-31)
- OI-95 raised (rev 245, TI notified): persistent synth-cache incl. ABC,
  map/map -r in parallel, verify.sh --changed for working-branch pushes;
  nightly/release stay full clean. Until TI lands it, the gate is as before.
- Iterate NGD on the one-slot unit ooe_rob_s1 in scratch tree wt7 (unit
  added to wt7's test/ooe/cg-units.json only; never commit it). Confirm
  once at full size. Keep CoreMark on RH, never beside synthesis here.

## State (2026-11-01 15:00)
- 2b LANDED: 969a42b pushed (scoped PASS 21/21; ngd 8290 s, cg 6340 s at
  CCV_JOBS=1). gate-push's own push failed (proxy port changed by a
  container restart mid-gate); pushed by hand after the ancestry check.
- Sweep merge in land: IS, AR, OA, TI branches (handoffs only); gating.
- Next: model fill==alloc+2 assert + control (OA rev 295/296, OI-94);
  floors run on RH with rets (resolve_lag_ret_only, ret_hold) and S1;
  ret_hold flop in ooe_rs + squash_act_lag default 1; Rename's mark with
  OI-94 cond 2 assert; cold-MLC dec_ooe_uop row to its owner.

## State (2026-11-01 10:30)
- TI fixed OI-97 (4c2ce8b: big units map in series; selftest own cache).
  Land 969a42b = c911fe3 + merge of 4c2ce8b; gate-push (scoped, CCV_JOBS=1)
  detached, log scratchpad/gate-land4.log and ~/ccv-logs/verify-969a42b-*;
  waiter task b4g10l07a. After it pushes: sweep merge in land of
  ccr-3868632d (IS), ccr-80102643 (AR), ccr-9eb50716 (OA), ccr-c22116ce
  (RH): handoffs and merges only; gate-push again; sync main checkout.
- OI-98 (rev 248, OA notified): OA rev 293 answered (prices <0.5%) +
  squash_held_room_lag price 0; OA took all (rev 294). OI-99 (rev 249): OI-94 kill price 0 (C''), asked OA if C'' is (c). TODO: rets (ret_only+ret_hold) in next floors run on RH after 2b. Next OI row OI-101. OI-100 (rev 250, OA notified): RTL kill waits on the fill (kill count); TODO after 2b: model assert fill==alloc+2 under kill_free_lag + control delaying one fill; cond 2 (no RS/RAT write after squash) lands with Rename's mark. OA rev 296 accepted; say when both asserts land (OI-94 closes then).

## State (2026-11-01, after gate 3)
- BLOCKED on TI: OI-97 (rev 247, TI notified). Gate 3 (c911fe3, CCV_JOBS=1)
  failed check-ngd: TI's OI-95 runs map and map -r in parallel
  (check-ngd.py ~417), and two yosys-abc at ~6.5 GB on full ooe_rob OOM.
  Selftest "ABC cache keyed map -r as map" fails on a kept synth-cache
  (content key, fixed inputs: a hit after the first run). Wait for TI's
  answer, or TI's go for OI to carry a fix (serialize at CCV_JOBS=1; a temp
  cache for the selftest). Then gate-push land (c911fe3) and sync the main
  checkout. Nothing pushed since 712913d. Next OI row OI-98. OI bookmark 247.

## State (2026-11-01 06:00)
- Gate 2 (beb452e, CCV_JOBS=4) killed at the 2 h bash limit; real fails:
  ooe_unit control count (fixed c911fe3: retire-unresolved, no-ret-hold
  listed, 43) and ngd OOM (full ooe_rob: yosys ~6 GB + ABC ~5.7 GB beside
  other jobs). Gate 3: CCV_JOBS=1, detached (setsid nohup), log
  scratchpad/gate-land3.log; a waiter task polls it. Raise to TI: the gate
  at full-size ooe_rob does not fit 15 GB at CCV_JOBS=4 (serialize cg/ngd
  for big units, or a memory-weighted slot).

## State (2026-11-01 03:50)
- Gate 1 on 82be63e: NOT pushed (disk full -> no result; lint CCV-L23 31
  findings in ooe_rob: 2b's squash regs tagged 03 read by 02 window state).
  Freed disk (rm wt6, wt7/build). Fix beb452e: squash state regs tagged 02
  (sqm sq_rt hrel_q kv_q k*_q m_live), 02 copies rd_s/sp_s beside rd_q/sq_p
  _cq03h (redirect side), ckfa_s for rs_en, discard ports dc_*_cq03h. Lint 0,
  rob_tb clean. Gate 2 task bcet20ffq (log scratchpad/gate-land2.log).
- RULE: lint (tools/lint-rtl.py <file>) before any gate; a state register
  read by the window's 02 logic is tagged 02 (CCV-L23 same-stage exemption).

## State (2026-11-01 02:00)
- Full NGD (CG-fixed RTL): 24.3 flop-flop, in-flop 22.7, no findings
  (4074 s). Full CG after the fix not finished (2 h limit); the gate runs it.
- Landing tree scratchpad/land (worktree, detached): a78cd3f 2b, 4e876b9
  merge of TI ccr-183cc441-doowtf (5918949: OI-95 scoped gate, AR rev 260
  lead, OI-93), 82be63e OI-96 lead-uid bound + replay mark. gate-push
  (scoped vs 712913d) task b93hqodn6, log scratchpad/gate-land.log.
- Docs: plan CHECK_NGD/CG filled; model doc cm32/cm128 prices (cm128 c,
  the hold, still on RH: add its figure in a later docs commit).
- After push: register rows from OI-97 (see Open work 3 + cold-MLC row to
  the dec_ooe_uop owner + OI-96 done + 2b's CG/NGD), sync main checkout.

## State (2026-10-31 22:05)
- RH cold bisect: all 7 points (bbec7c1..712913d) fire dec_ooe_uop_s0/s1
  response_within_n from tick 95945, identically: predates 2a, NOT OI's.
  A stall (credit returns), bursts recur; cold never finishes. Raise a row
  to the owner (dec_ooe_uop / MLC cold) with RH's table. Not blocking 2b.
- RH warm cm32 a (sal=1): 4,584,463; b (+rets lag 1): 4,584,938 (+0.010%); c (+ret_hold): 4,584,938 (+0, hold fired 4). CM32_PRICE text: "+0.010% with rets at lag 1, +0 more with the hold". cm128 a 17,060,800; b 17,023,250 (-0.22%); c 17,009,943 (-0.08% vs b; hold fired 1996). All PASS, warm. RH idle.
- TI rev 279: OI-95 DONE, pushed 5e7c8db (ABC cached, map/map -r parallel,
  verify.sh --changed + gate-scope.py; gate-push scoped by default, --full
  for clean). Land 2b on a tip including 5e7c8db; send TI the gate times.
- 23:20: full NGD OOM-killed (ABC 5.7 GB beside CG): never run NGD and CG
  together at full size. CG full (wt7): new CG-2s, rm_en 15.7 (gfree/pfree,
  via frel) and rs_en 8.5 (cand's hd/sqa terms); fixed: mw uses |rd_q |
  |hrel_q (frel within rd_q), rs_en uses cnx = v&cmp&br&~rsv (superset);
  dc payload enable named dcp_en. Backup scratchpad/ooe_rob.cg0.sv.
  rob_tb clean, 14 controls. s1 CG: worst enable 8.0 but s1 replay mismatches (S=1 artifact; do not use s1 for CG). Container restarted 23:3x; task b1yi5jfx9: NGD full then CG full, serial.

## State (2026-10-31 21:45)
- RH (21:43): coremark128 COLD (no CCV_MLC_WARM) at 712913d, unpatched too,
  fires dec_ooe_uop_s0/s1 response_within_n from tick 95945 and never
  finishes; warm is clean. RH restarted the six rev-293 runs warm (right:
  OI-88 was warm). Asked RH to bisect cold: bbec7c1, 61b444e (2a), a6f9de3,
  a91840a, e44cd78, 4316a51, 712913d; first tick, lost credit vs stall.
  If 2a is the cause, it is OI's to fix before 2b lands.
- wt7 is now the 2b tree (wt6 + edits; wt6 = round-4 RTL). Round 4 full:
  31.9, al_n fixed. ooe_rob_s1 tracks full within ~1 NGD, 10 min a run.
- Round 5 (wt7): squash cycle registers run 0 when it leaves held entries
  (new model knob squash_held_room_lag, rob_tb sets 1; audit price 0:
  911/911, 916/916), drops the squash's xs/ds search -> s1 25.2. Round 6:
  tail/occupancy encodes meet in an OR (task bfn2vbkqn). NGD-7 rd_q->gfree_l
  at s1 is an S=1 merge artifact (sql_q == rd_q), absent at full size.
- squash_held_room_lag goes to OA with its price (0) in the 2b rows.
- OI-96 (rev 246) TI agreed (TI rev 278): OI carries br_lead_tid_ fix at
  its 80697a3 merge; keep the mark across a replay re-issue.

## State (2026-10-31 18:30)
- RH (session_01QPk2jvfKM1V5rRfip8FC86) is usable for compute (DA, 10-31);
  it runs coremark128 for OA rev 293's price (3 configs, ~2 h each, in
  /home/user/rh-oi86 at 712913d + scratchpad/model-rethold.patch).
- Next OI row is OI-95. OA rev 293 (rets at lag 1 + ret_hold, model-only
  price vs (b)): S1 3,914 -> 3,915 / 3,915; cm32 hit the 2 h background limit here, sent to RH with cm128 (10-31 19:5x).
- TI 80697a3 (branch ccr-183cc441-doowtf): AR's lead on rcu_ooe_done; TI
  asks OI to review its ooe_block.cpp lead check: br_lead_tid_ never
  erased (leak; notes scratchpad/ti-lead-review.txt). Answer with the rows.
- wt6 NGD restructure done (thq thermometer reg, hds w/o unfilled mask,
  al_n selected last, ugt thresholds, rd_o copy); NGD re-run bmp613m8k.
  CG still to run (timeout >= 7200 s; clear truncated synth-cache JSON).
- NGD round 2 (19:00): 35.1 (ck->ckf: the if-in-loop OR is a 32-deep
  chain; check-ngd's ABC is strash;dch;map, no balance). Round 3: balanced
  reduce-ORs for ckf/sc/run encode, run = run0 - al_n -> 30.2, al_n 26.2
  (och_nx's al_n term reached the squash branch). Round 4 (20:40, task
  b4qnse7a3): tail search on hd only, squash branch without the subtract,
  ochs. Backups scratchpad/ooe_rob.ngd1.sv, .ngd2.sv. rob_tb clean each.

## State (2026-10-31 17:00)
- 2a gated PASS and pushed (712913d on ccr-57eff422-5tdecg).
- wt6 (detached at 712913d, uncommitted): 2b RTL + bench + model + docs.
  Yosys int' cast fixed (32'(rk)). rob_tb clean (25 seeds, 14 controls).
  Model fix: retire waits on a pending resolution (retire.res_pend); at
  retire_lag 0 + resolve_lag 1 a branch retired before its squash acted
  and every audit seed hung on the wrong path. New test resolve-lag
  retire + control inject_retire_unresolved (caught); suite PASS.
  Plan doc 2b paragraph written with CHECK_NGD / CHECK_CG placeholders.
  CG + NGD running (task b6ct3zb4l waits; logs scratchpad cg-rob.log,
  ngd-rob.log). Then fill placeholders, commit on branch, gate-push.
- Audit at retire_lag 0 (base 901): sal 911, +hrl 916 (+0.55%, to OA/DA),
  +kill 916 (0); rl1 915, +sal 920, +hrl 927, +kill 927.
- register-reader running for the next OI-n and rows needing OI.
- Rulings as before: DA (b) OA rev 292; AR rev 260 lead fields; OA rev
  291 (c) conditions; my C'' differs (to put to OA); fl_brl 2 (OA 289).
- TI 16af94a not yet merged. RH's OI-88 diffs as before (memory-side).

## Open work (most urgent first)
1. Land 2a (gate in flight), then copy this handoff into the branch.
2. 2b in wt6: CG, NGD, plan doc, commit on the branch tip, gate, push.
3. Register rows (OI tab): OI-94 answer (C'' + price), held_room_lag
   price under (b), OI-88 cm128 explanation, TI adapter check kept,
   budgets asked for 2b's four new inputs. Notices to OA (and DA if > 0.5%).
4. After AR's lead + TI's schema: resolution at lag 0 for branches/calls
   from lead_br_*, rets at lag 1 (model knob for the mixed form, priced);
   flip squash_act_lag default to 1 (re-pins).
5. Receivers' squash interface at assembly (RS/RAT/decq/go leads), and
   Rename's mark (OI-94 conditions 2-3, assertion + control).
6. Model fixes in wt4 (release_names_lag V-01; swap seed 2 DRAM miss).
7. OI-87 (go_tb under retire_lag 1), then ROB slices 3-6; RTL 7.
