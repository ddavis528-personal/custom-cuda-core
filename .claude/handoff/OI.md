# OI handoff (OOE model and RTL)

Updated 2026-11-06 ~15:30 UTC (sweep merge fb52948 pushed; RH C9 job out; pruned, the long history is in git). Keep this current at every task's end; it is what
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
Conventions 17, AR 312, RA 91, IS 190, TI 354, OA 368, OI 308, CP 155, DA 114, RI 21
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
1. RH C9 job sent 11-06 15:10 (gate-scratch/OI 7718260 c9job/; + addendum C9h/C9s/C9n S1-only).
   On return: OI row to DA/OA/AR: F-C9, F-C9r (DA 114 bar: <=0.5% returns C9 to DA) and
   the bypass split (C9h hint late, C9s no rs bypass, C9n no bypass).
2. C9 build (task #23), tree scratchpad/wc9 (branch oi-c9 on fb52948: knobs patch + wake/rs
   probe; trio_tb takes TRIO_CS; scratchpad/c9/trio-build.sh <tree>). FINDING: probe's two
   bypasses diverge from model cs=9 at ~120 cycles (V-65). Raw capture lags every hit/hint
   effect: miss check (hit lands at LAT_MISS exactly), msd, fin, lead lines (hint at
   LAT_MISS-LEAD, zero slack), wake's own confirm, rs's cmn (rs takes cmpl_idx too).
   Exact C9 needs bypasses on all; else the model's C9 needs lag bits (RH prices them).
   Block level: cmpl_l feeds wake, rs, rob x4 = 6 pins > 4 (OA 364: copies or one capture).
3. OI-114 BLOCKED on OA (OI-116, rev 308, notice sent 11-06): rename form 3 fits its caps and
   passes every bench, but needs ooe_go's per-take subtraction (5664f5e), which puts ooe_go
   over 13 caps (unmet_g 29.9 and room_g 25.4 new over 25). Tree scratchpad/wtf, branch
   oi-floor114 tip 1f3bb3c (not pushed; model GoLog unmet_on_g/p). Act on OA's ruling.
4. ROB slice 4 (faults): the model's fault at retire (ooe_core.cpp ~2563) reports pc =
   r.u.pc: the 65-bit entry (rev 277 (c)/279) holds no PC: ask OA the PC source first.
   Outputs: ccv_ooe_rau_status.fault_taken, ccv_ooe_cru_fault (first fault of the context,
   written once). V-74 fault-address register per warp. Then slices 5, 6.
5. DA 111b / OA 364: a unit for every OOE module at each instantiated param set
   (ooe_rob_w x4 by WID; ooe_ratread once rename has it).
6. OA 365 (low): ooe_sched phys_src0/1 output depth.

## Done 11-06
- Slice 3 (memop commit, OA rev 362) pushed e491f22 (SCOPED PASS 22/22). Final fix: the
  zero-owed term as a match, dn_row 26.04 -> 25.7 under its 26.0 cap.
- OI-115 written (rev 306): RI-11 package for DA (C9 S1 +0.444%, cm128 -0.45%, cm32 -0.08%;
  flopped ~+1.95%; R49 +0.276%; C8 0).
