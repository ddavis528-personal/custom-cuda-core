# OI handoff (OOE model and RTL)

Updated 2026-11-07 15:55 (sweep 289b880 PUSHED; ROB slice 4 committed 965ef34 in wr4 (oi-rob4), gate-push launched, log scratchpad/gp-rob4.log;
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
Conventions 17, AR 316, RA 96, IS 190, TI 365, OA 380, OI 321, CP 155, DA 115, RI 32
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
1. ROB slice 4 (task #22): wr4 (oi-rob4) at merge 8394983 (965ef34 + handoff ec8eb4d), scoped gate-push
   launched, log scratchpad/gp-rob4.log. Done before push: rob bench identical to robrun4h (faults 6, all
   fault controls caught); check-ngd within caps (NGD-1 29.6, al_n 29.1, dn_tag 26.2, fl_slot 31.2, fl_v 29.8;
   dn_row cap removed); check-cg: allocation fault fields staged (as_q/ast, +~336 flops), fa hold in data
   (enable fa_en), named pf_en/pch_en/ftr_en/fv_en; rob_w ~70 flops loose of 165; cmcap 9 of 9.3;
   run-rtl.sh EXIT 0. After push: OA row (flops: rob_w 5395 -> 8275; mf 32, fa ~200, staging ~336, entry
   fault fields 68/entry; head-only MIU fault +1 cycle; assertions port_complete_is_entry,
   release_allocates_nothing, fault_never_done on fle), cite TI 363 / AR 314. Ring OA.
2. Task #28: RI's notice (RI Responses row, tab 8e4547bc-c469 rev 32, Needs TI, OI): a diverged CALL's
   link imm stale on coremarkpl32 (seq 207330 got 0x240, 225077 got 0x3c82). Repro f4ce0fd,
   CCV_MLC_WARM=1 CCV_FET_PERFECT=0, --cycles 16000000. OOE forms it as u.pc+2*(ilen+1) (ooe_core.cpp
   ~3431) from DEC's pc verbatim, and DEC's stub checks pc against the oracle, so suspect another issue
   path (copy/merge, send_imm false), not u.pc. Heavy run: not beside a gate. Answer in OI tab, ring RI+TI.
3. Task #29: OI-127 (rev 321, rang TI+OA). OA rev 380 confirmed: A2 issues with the CAS's renamed pd,
   pred_we 1 and phys_pred_old_dst, every pass; A1/A3 status 0/1 only, assert it. TI to say DEC's pd slot.
   Model: pair join (~4704) carries pred_we/pred_dst; makeIssue atomic (~3406); atomCmpl assertion; test +
   control cas-no-pd. Verify OI-127's claim that RTL carries pred_we per RS row; correct the row if not.
4. TI 360 (task #26), tree scratchpad/wfs (oi-fs), local WIP 5e37a70: floor_held_gate fix + counters
   (restore.alloc_wait, rename.frag, gpr_held_by_memop). TODO: merge 289b880, run-tests, check-ngd/cg
   ooe_go, push, RH price at 128/160/192, rows to OA+TI+AR (asked by TI 360/361, AR 315/316, OA 378).
5. DA 111b / OA 364: a unit for every OOE module at each instantiated param set.
6. OA 365 (low): ooe_sched phys_src0/1 output depth.

## Done 11-06
- Slice 3 (memop commit, OA rev 362) pushed e491f22 (SCOPED PASS 22/22). Final fix: the
  zero-owed term as a match, dn_row 26.04 -> 25.7 under its 26.0 cap.
- OI-115 written (rev 306): RI-11 package for DA (C9 S1 +0.444%, cm128 -0.45%, cm32 -0.08%;
  flopped ~+1.95%; R49 +0.276%; C8 0).
