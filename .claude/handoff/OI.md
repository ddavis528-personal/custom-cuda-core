# OI handoff (OOE model and RTL)

Updated 2026-11-06 ~14:00 UTC (slice 3 pushed e491f22; sweep merge gating; pruned, the long history is in git). Keep this current at every task's end; it is what
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
- Session settings installed 2026-10-31 and again 2026-11-03 (DA approved both): /home/user/.claude.
  The compact hook prints THIS checkout's .claude/handoff/OI.md: keep
  /home/user/custom-cuda-core's copy current, not only the branch's.

## Register bookmarks (revs read through)
Conventions 17, AR 309, RA 91, IS 190, TI 350, OA 367, OI 306, CP 155, DA 112, RI 21
(sweep 11-06 10:20, plus notices to 13:00). Pings 11-06: all eight pinged; pongs OK from OA TI
AR CP IS RI RH (RA's pending at 10:30). Answered pings from AR OA TI CP IS RA RI.
Settings check passed 11-06 before merging TI's 350k window (DA 111): after this merge,
`--check` should differ; ask DA to approve `python3 tools/setup-session-home.py`.

## Tools (scratchpad, not in the repo)
- fo/path.py / path3.py: `START=<input> python3 fo/path3.py ir|rr <abc-*.blif>` traces the
  deepest path with fanout (3 decimals). Find a unit's blif by grepping a port name in
  build/synth-cache/abc-*.blif. check-ngd --unit returns rc 0 even over caps: compare by hand.
- check-ngd caps (rtl/ngd-ratchet.json "fanout") are strict (EPS 0.005); ABC remaps the
  whole unit on any change (untouched cones move +-0.3..1.7). Try equivalent forms.

## Open work (most urgent first)
1. Sweep merge on branch oi-sweep (scratchpad/wrob): e491f22 + 7 remote branches (TI's
   2281ab8 with 1a9a3e8/0ce9c12/17720a0, RA, IS, AR, RI, OA, RH); full gate-push.
2. RH job (task: AR 300 (5), OA 367, RA 91/DA): price C9 (miu_ooe_cmpl + hint no_flop,
   other OOE ends flopped) and all-flopped, at LANE 8 / SFU 13, as links.json edits under
   bnd_rx; S1, cm32, cm128 vs defaults. Model figure to check: C9 +0.444% S1 (at 7/12).
   C9 BUILD ON HOLD until DA rules (OA 367). OI-115 (DA package) awaits DA.
3. OI-114 (go's floor less own take): ooe_go unchanged; rename form 3 in scratchpad/wtf
   (branch oi-floor114, uncommitted; copies ../ren.r3.sv, r3a, r3c). Under TI's re-seeded
   caps form 3 is over only c_dst (27.5 vs 26.9). Re-measure r3a/r3c after the merge; if none
   fits, row to OA/TI on cap noise. Model/tb done (go_tb 0 mismatches; controls caught).
4. ROB slice 4 (faults): entry fault cause+valid (DEC cause, dispatch F-WIDTH/F-FORMAT/
   F-BARRIER), MIU cmpl fault (cause, lanes, 64-bit addr) into a per-warp fault-address
   register (V-74, oldest), head stop, outputs ccv_ooe_rau_status.fault_taken and
   ccv_ooe_cru_fault (cause, pc, lane_mask, address, cta_slot, warp_id). Check OA's entry
   layout (rev 277 (c)/279) and the PC source first. Then slices 5 (barriers), 6 (demotion).
5. DA 111b / OA 364: a check-ngd/cg unit for every OOE module at each instantiated param set.
6. OA 365 (low priority, OA 366): ooe_sched phys_src0/1 output depth at aa9ad9c; report with
   the next probe. OA 354 (a)+(b) low priority.

## Done 11-06
- Slice 3 (memop commit, OA rev 362) pushed e491f22 (SCOPED PASS 22/22). Final fix: the
  zero-owed term as a match, dn_row 26.04 -> 25.7 under its 26.0 cap.
- OI-115 written (rev 306): RI-11 package for DA (C9 S1 +0.444%, cm128 -0.45%, cm32 -0.08%;
  flopped ~+1.95%; R49 +0.276%; C8 0).
