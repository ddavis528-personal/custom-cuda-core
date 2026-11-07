# OI handoff (OOE model and RTL)

Updated 2026-11-07 10:20 (C9h gate relaunched 10:12, log scratchpad/gp-c9h3.log; sweep merge waits on it; TI 360 fix and ROB slice 4 uncommitted in scratch trees). Keep this current at every task's end; it is what
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
1. C9h push (task #23): wc9 (scratchpad/wc9, oi-c9) merged TI's origin/ccr-183cc441-doowtf (41c82d8,
   tip a6bb2e1) as f00c14c; regen clean. gate-push launched 08:07 11-07 detached, log
   scratchpad/gp-c9h.log (verify log ~/ccv-logs/verify-f00c14c-*). On green: OI-114 row to OA, and
   tell TI. On red: gate-triage.
2. TI 360 (task #26), tree scratchpad/wfs, branch oi-fs off oi-c9 63a0594, UNCOMMITTED:
   root cause = OI-114 (b): under floor_take_lag 1 a slot's floor term is split again while its
   allowance holding it is admitted against (take reaches unmet a cycle late) -> one cycle double
   count -> sum of allowances > credit (all failures credit 2, one slot's floor; trace t=1272/1273).
   Fix: model knob floor_held_gate 1 (floor_held_ per slot/class; no floor term when the registered
   allowance holds one) + ooe_go fh_cq02h flops (enabled with fits, gate ug/up, fhc forces chg).
   cm128 phys128 300k cycles: fits 23 -> 0. go_tb exact live+scarce; control floor-held-off caught.
   Counters added (TI 361/AR 315-316/OA 378): restore.alloc_wait, rename.frag (+.peak, hist),
   gpr_held_by_memop (+.peak, hist; = in-flight memops' GPR names). Debug prints removed.
   TODO: run-tests.sh, check-ngd/check-cg ooe_go, commit, RH price at 128/160/192, row to OA+TI+AR.
   Note: my cm128 runs with CCV_OOE_CONFIG all show order=bad/operand CHECKs even at default (an
   invocation artifact); compare fits counts only.
3. ROB slice 4 (task #22), tree scratchpad/wr4 (oi-rob4 off oi-c9 63a0594), UNCOMMITTED. Fault taken
   at the registered head only (hrf & v & flt & ~hd & ~(rd_s&sqm), !fst; own enable ft_en from
   flops), no ftk_q; model knob fault_head_only 2 (head_since < now_); rob_tb exact live+mispredict;
   controls no-fault, fault-cause, fault-any-port, fault-port0 caught; run-tests PASS.
   NGD (ngd-rob4d): NGD-1 30.8, dn_tag 27.2 ok; OVER: al_n 29.6 (cap 29.3), dn_row 26.4 (cap 26.0).
   Then tried: dn_row decode split into kept copies dra/drb (not yet measured, nor rob_tb rerun).
   Then check-cg, commit, OA row (flops ~2,300/slot vs OA's 1,270; head-only fault +1 cycle).
   MIU lead_fault path waits on TI's schema row (OI-125).
4. DA 111b / OA 364: a unit for every OOE module at each instantiated param set.
5. OA 365 (low): ooe_sched phys_src0/1 output depth.

## Done 11-06
- Slice 3 (memop commit, OA rev 362) pushed e491f22 (SCOPED PASS 22/22). Final fix: the
  zero-owed term as a match, dn_row 26.04 -> 25.7 under its 26.0 cap.
- OI-115 written (rev 306): RI-11 package for DA (C9 S1 +0.444%, cm128 -0.45%, cm32 -0.08%;
  flopped ~+1.95%; R49 +0.276%; C8 0).
