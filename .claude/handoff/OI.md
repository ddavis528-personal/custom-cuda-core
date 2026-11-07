# OI handoff (OOE model and RTL)

Updated 2026-11-07 12:40 (C9h PUSHED f00c14c; sweep merge 289b880 full gate running 11:30, log scratchpad/gp-sweep7.log;
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
Conventions 17, AR 316, RA 96, IS 190, TI 362, OA 379, OI 319, CP 155, DA 115, RI 31
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

## Open work (most urgent first)
1. Sweep merge (task #27): wc9 (oi-c9) at 289b880 merged 7 branches (TI 5a2f4aa lead_fault, RA, AR,
   RI, OA, RH handoffs) + main checkout's handoff commits; full gate-push launched 11:30, log
   scratchpad/gp-sweep7.log. On red: gate-triage. OI-126 (C9h close-out) written, rev 320, no ring.
2. ROB slice 4 (task #22), tree scratchpad/wr4 (oi-rob4), local commits 644621d + merge 63715f5 (289b880)
   + f48e194 (MIU faults on lead_fault): cmcap fv + fault capture; rob_w mf mark, V-74 register fa_*
   (oldest from head), record reads fa when head's, ft_addr out; cfe also takes fault in its cycle;
   model drops robStop("miu fault"); testMemFault(true) on hooked benches. rob_tb exact live+mispredict
   (faults 6, 2 MIU); all 6 fault controls caught; cmcap_tb exact, 3 controls caught.
   Also unmeasured: dn_row split dra/drb. TODO after the gate: check-ngd ooe_rob_w (caps al_n 29.3,
   dn_row 26.0, NGD-1 31.7) and ooe_cmcap; check-cg both (cmcap: 9 always-clocked flops vs 2% ~9.4);
   ngd.json budgets for cf_* inputs if needed; run-tests.sh; OA row (flops: +mf 32, fa ~200/slot;
   record lanes from fa; head-only fault +1 cycle).
3. TI 360 (task #26), tree scratchpad/wfs (oi-fs), local WIP 5e37a70: floor_held_gate fix + counters
   (restore.alloc_wait, rename.frag, gpr_held_by_memop). TODO: merge 289b880, run-tests, check-ngd/cg
   ooe_go, push, RH price at 128/160/192, rows to OA+TI+AR (asked by TI 360/361, AR 315/316, OA 378).
4. DA 111b / OA 364: a unit for every OOE module at each instantiated param set.
5. OA 365 (low): ooe_sched phys_src0/1 output depth.

## Done 11-06
- Slice 3 (memop commit, OA rev 362) pushed e491f22 (SCOPED PASS 22/22). Final fix: the
  zero-owed term as a match, dn_row 26.04 -> 25.7 under its 26.0 cap.
- OI-115 written (rev 306): RI-11 package for DA (C9 S1 +0.444%, cm128 -0.45%, cm32 -0.08%;
  flopped ~+1.95%; R49 +0.276%; C8 0).
