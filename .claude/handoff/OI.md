# OI handoff (OOE model and RTL)

Updated 2026-11-08 (TI 360 pushed 95bf04d, OI-130; OI-127 done f727aed)
survives a compaction. CLAUDE.md holds the repo's rules; this holds OI's.

## Working rules
- The user is DA (Daniel). Standing order: continue OOE RTL until blocked; no need to ask
  for a go unless at a key decision point. Long performance runs go to RH
  (session_01QPk2jvfKM1V5rRfip8FC86).
- Push only with `CCV_PUSH_BRANCHES=ccr-57eff422-5tdecg tools/gate-push.sh` (--full for a
  sweep merge), run detached (setsid nohup script), result to a log a wait loop watches.
  A manual git push is refused ("CI Bypass"). Never push red. No PRs. One gate or heavy
  job at a time; no CoreMark beside it; never pgrep/pkill -f; don't edit a tree while a
  gate or check runs in it. Watch free disk (a full disk stalled a gate 11-06).
- Owners: OA the microarchitecture and port budgets; DA waivers and
  anything over OA's 0.5%; TI schema/, params/, tools/ (OI carries a tools
  fix only when TI says so, as OI-89). Never weaken a negative control.
- Commits end with the Co-Authored-By and Claude-Session lines; no model
  ids in commits or artifacts.
- Register: write only the OI tab (node 384bc26c-cef6, table
  m8yvbw8rqgz.11664, rows: title, date, summary ending "Needs: X",
  detail). Notices via `.claude/skills/register/notice.py` and
  send_message. Pings weekly, Fridays (TI-49, DA).
- Trees: the container was replaced on 11-03 (scratchpad, ~/ccv-logs and every
  worktree lost; unpushed commits went with them). Work in the main checkout
  /home/user/custom-cuda-core; send an unpushed commit to gate-scratch/OI
  (`tools/gate-scratch.sh send-commit OI`) before a long gate. Disk is a fixed
  allowance (~39 GB): delete build dirs you no longer need; a gate's build is ~15 GB.

## Daily sweep (scheduled task trig_01RHTzEomNoTP7mgfQxaNkmm)
Read every tab since the bookmarks; merge every remote branch that is
ahead (not release) into wt, gate, push; pongs; pings on Fridays only;
`tools/setup-session-home.py --check` (TI-50; on a mismatch ask DA to
approve the install again, never reinstall unasked).
- Session settings installed 2026-10-31, 11-03 and 11-06 (350k window; DA approved each): /home/user/.claude.
  The compact hook prints THIS checkout's .claude/handoff/OI.md: keep
  /home/user/custom-cuda-core's copy current, not only the branch's.

## Register bookmarks (revs read through)
Conventions 17, AR 320, RA 96, IS 190, TI 373, OA 382, OI 325, CP 155, DA 115, RI 35
(sweep 11-07 10:16). AR 314/OA 377: lead_fault = status==1, per slot, OI builds capture once TI's schema row lands (none to TI 362). Pings 11-06: all eight pinged; pongs OK from OA TI
AR CP IS RI RH (RA's pending at 10:30). Answered pings from AR OA TI CP IS RA RI.
Settings check passed 11-06 before merging TI's 350k window (DA 111): after this merge,
`--check` should differ; ask DA to approve `python3 tools/setup-session-home.py`.

## Tools (scratchpad, not in the repo)
- fo/path.py / path3.py: `START=<input> python3 fo/path3.py ir|rr <abc-*.blif>` traces the
  deepest path with fanout (3 decimals). Find a unit's blif by grepping a port name in
  build/synth-cache/abc-*.blif. check-ngd --unit returns rc 0 even over caps: compare by hand.
- check-ngd caps (rtl/ngd-ratchet.json "fanout") are strict (EPS 0.005); ABC remaps the
  whole unit on any change (untouched cones move +-0.3..1.7). Try equivalent forms.

## Open work (most urgent first; DA approved this order 11-07)
1. TI 360 (task #26): PUSHED 95bf04d (SCOPED PASS 20/22); OI-130 rev 325 rang OA/TI/AR. Waiting on
   RH (sent 11-08 ~05:00): G/N floor_held_gate at 192/160(ren 12/44)/128(ren 8/24), S1 + cm128 warm.
   On RH's answer: add its numbers to OI-130 (no notice unless OA must act). OA owes: accept the fix;
   ooe_go to 25 needs the share split retimed (~21 NGD hv->sg) or caps stand (#37).
2. OA 382 (task #40): RTL issue payload: A2's RS row carries pd, pred_we, ppold; cas-no-pd control in RTL.
3. OA 365 (task #24): ooe_sched phys_src0/1 output depth (<=6); fold in ooe_sched ratchet (#36).
4. NGD fanout ratchet (rtl/ngd-ratchet.json "fanout"; DA asked 11-07), in order: ooe_rendep (#33,
   worst mem 34.5), ooe_rob_w (#34; caps lowered to 29.9 in b8881c0),
   ooe_rename (#35, 31.1), ooe_rs (#38, 30.2), ooe_ratread (#39, port-budget caps only).
5. DA 111b / OA 364: a unit for every OOE module at each instantiated param set.
6. Optional (OA 381, task #32): fa entry one-hot -> 5-bit index in ooe_rob_w (-108 flops).

## Done 11-07
- ROB slice 4 pushed adfa301 (SCOPED PASS 20/22); OI-128 row rev 322/323, OA accepted at 381.

## Done 11-06
- Slice 3 (memop commit, OA rev 362) pushed e491f22 (SCOPED PASS 22/22). Final fix: the
  zero-owed term as a match, dn_row 26.04 -> 25.7 under its 26.0 cap.
- OI-115 written (rev 306): RI-11 package for DA (C9 S1 +0.444%, cm128 -0.45%, cm32 -0.08%;
  flopped ~+1.95%; R49 +0.276%; C8 0).
