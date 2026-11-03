# OI handoff (OOE model and RTL)

Updated 2026-11-02 01:30. Keep this current at every task's end; it is what
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
Conventions 15, AR 260, OA 305, RA 44 (RA tab 9851686b-2b0a; RA not in local roster),  IS 182, TI 282, OI 250, CP 149, DA 98 (sweep 11-01). Pings: Friday 10-30's all
answered (checked 10-30); next pings Friday 11-06.

## Compute (DA, 2026-10-31)
- OI-95 raised (rev 245, TI notified): persistent synth-cache incl. ABC,
  map/map -r in parallel, verify.sh --changed for working-branch pushes;
  nightly/release stay full clean. Until TI lands it, the gate is as before.
- Iterate NGD on the one-slot unit ooe_rob_s1 in scratch tree wt7 (unit
  added to wt7's test/ooe/cg-units.json only; never commit it). Confirm
  once at full size. Keep CoreMark on RH, never beside synthesis here.

## State (2026-11-02 01:30 UTC)
- wt10 (scratchpad/wt10, tip 4cbb111 = 8 commits on cfa62c6: ret hold after the
  edge, model default flip, one_resolution + control, ooe_go reserve fix, this
  handoff). Gate: detached `setsid nohup tools/gate-push.sh` (pgid 21695, log
  scratchpad/gate10.log, ~/ccv-logs/verify-4cbb111-20261101-2300.log), pushes to
  ccr-57eff422-5tdecg on green. Split gate unusable (OI-102 to TI: the only
  container channel is a 64 KiB message the model retypes). Background tasks cap
  at 2 h: long gates via setsid nohup, a waiter loop on the pgid.
- wt11 (scratchpad/wt11, worktree, branch oi-idle-r): 899b4fc + 88cd231 COMMITTED
  (RA-17 RTL + model registered rule; RA-29 (a) r_class_pair err, testRClass,
  inject_split_r_class, split_r_class price knob, collectives (kColl) in testIdleR
  warp 3; RA-29 (e) env checks pred_logic imm sources readable, testPredSources,
  inject_pq_no_dep). Model suite PASS and trio 25 PASS on 88cd231 (migs 2026,
  forced 396, 0 mismatches, 8 controls caught). Price new rule (scratchpad/idle-r-price24R.txt): K4 forced/R grants
  6.2/11.5/10.5% at 0/50/100% R share, longest migration 44/44/44 (no force
  42/131/494), cycles noise. RA-29 (a) kernel price (S1 = test/kernels via
  scratchpad/lag-kernels4.sh pattern with CCV_OOE_CONFIG=split_r_class=1, floors =
  its check-ooo line, rope, audit = ooe-test --audit AUDIT_CFG, cta-reduce =
  tools/time-bench.sh test/bench/cta-reduce*) NOT RUN: needs skel+oracles, after gate.
- NEW FINDING (raise OI row to OA): V-04 under fits_stale 6, repro in
  scratchpad/v04-repro.md (dense setp+vote/ballot, 2 warps, seed 3): a slot under
  its floor spends it twice over took(t-1)+took(t) (registered share adds
  unmetFloor a cycle early); gone at fits_stale 0. testPredSources adds a lane op
  per pair to stay clear; say so in the row.
- RA-22 checked: model rows A1/ordinary 0, copy 1, A2 2, A3 3 (makeIssue,
  memop m.row); ooe_rob counts dones per row. Confirm to OA.
- Next: commit wt11 (docs in ooe-rtl-plan.md + ooe-model.md done), merge onto the
  pushed branch, gate, push. OI row answering OA rev 299 / RA-17 (price, RTL,
  the registered rule as an RTL-realizable form with the same guarantee,
  mig_cq02h's source = the future control block, arrival free: 1.7 NGD to a
  flop); notify OA (RA: no session in local roster; say so).
- After the 4cbb111 push: OI row to OA (fill assert; OI-94 condition 2 with
  Rename's mark; ret hold budgets ret/brk 4.0 to confirm; f-f 24.4 + vel fix;
  replay-lead fix; one_resolution + control; default flip; ooe_go reserve fix).
  Sync this file to origin.

## Open work (most urgent first)
0. OA revs 306-307 + AR rev 267 (RA-31/32, notices 01:36-01:40 11-02): measure
   ooe_rs select-path NGD for the issue lead slice (selected entry's section mask +
   operand-use bits, R's guard phys pred, grant-muxed and flopped; fallback a
   registered copy of the static fields); confirm no consumer of CCV_LAT_L1_WAKE is
   hardcoded at 16 (speculative wake, miss-check replay, per-row done counts,
   squashed-load free); rerun S1/floors at ~12 (with CCV_LAT_RCU_ADDR_BASE = 1).
   Checked so far: model uses cfg_.lat_l1_wake (core.cpp:1350, unitLat);
   ooe_wake LAT_SPEC param (default 16, benches from wake-params.py). Rows to read.
1. Gate/push 4cbb111; then wt11 (RA-17) as above.
2. OA revs 300-305 (unanswered): RA-22 confirm done_row 0/2/3 (A1 memop,
   A2 lane op, A3 addressless memop) - check model/RTL then answer; RA-18
   (rev 302 supersedes 300): rename writes call link pc[31:0]+bytes(ilen)
   into RS imm (imm_kind 6), target add where the branch's redirect target
   is formed (may move to record fill a cycle later); place both adds, report
   Rename NGD, budgets for moved ports to OA; RA-29 (a): one of RCU-only or
   collective a cycle as one class, both in the idle-R run and ret hold;
   assert + control that splits it; price model-only on S1, audit, floors,
   rope, cta-reduce (<0.5% OA, over DA); after the idle-R counter. RA-29 (e):
   vote/ballot predicate source substituted into imm as pand/por.
3. OA asks: S1 + rets in next floors run; OI-94 (c) price; close OI-88;
   Rename's mark with OI-94 condition 2's assert + control.
4. After AR's lead + TI's schema: branches resolve at lag 0 (lead_br_*),
   rets at 1.
5. Receivers' squash interface at assembly (RS/RAT/decq/go leads).
6. Model fixes in wt4 (release_names_lag V-01; swap seed 2 DRAM miss).
7. OI-87 (go_tb under retire_lag 1), ROB slices 3-6 (the control block that
   drives ooe_sched's mig_cq02h belongs there); RTL 7 (barriers).
