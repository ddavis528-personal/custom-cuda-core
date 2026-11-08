# OI handoff (OOE model and RTL)

Updated 2026-11-08 15:00 (#33 rendep dc6ba0b in gate-push; RH U192 queued)
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
Conventions 17, AR 332, RA 117, IS 190, TI 387, OA 397, OI 333, CP 157, DA 115, RI 54
(sweep 11-08 plus notices). AR 314/OA 377: lead_fault = status==1, per slot; OI builds the capture
once TI's schema row lands. Pings 11-06: all OK. Settings: after TI's 350k merge `--check` may
differ; if so ask DA to approve `python3 tools/setup-session-home.py`.

## Tools (scratchpad, not in the repo)
- fo/path.py / path3.py: `START=<input> python3 fo/path3.py ir|rr <abc-*.blif>` traces the
  deepest path with fanout (3 decimals). Find a unit's blif by grepping a port name in
  build/synth-cache/abc-*.blif. check-ngd --unit returns rc 0 even over caps: compare by hand.
- check-ngd caps (rtl/ngd-ratchet.json "fanout") are strict (EPS 0.005); ABC remaps the
  whole unit on any change (untouched cones move +-0.3..1.7). Try equivalent forms.

## Open work (most urgent first; DA approved this order 11-07)
0. #33 DONE locally: dc6ba0b (rendep pp_cq01h from rename's keep copy d_ppk_cq03h, OA 397 arrival 2.0;
   five rendep caps gone, gsn 28.5/psn 28.8). gate-push log scratchpad/gp-rendep.log. It also carries
   f2df07a (OI-50 co-grant comments, OA 395) and 881cdd2 (merge of TI a0c2f68; RI 54's sweep waits on it).
   On green: an OI row closing OI-135 with rendep's worst path (gsn 28.44/psn 28.72; OA asked), no ring.
   Lesson: any load on ren1's l_x/l_v/tk_* remaps ooe_rename's q_gv cone (+0.5); take from c_xl per class.
1. #26 OI-134: RH results 95bf04d: U160 -2.22% vs G160, U128 -2.16%, L160 +1.87%, L128 -2.07%; all clean,
   S1 geomean 301.85 0 BAD. U192 queued on RH after J11b (~16:00-17:00). Adopt U (unmet_reg=1) if = G192
   (8,732,687); then OI-134 row with the numbers (ring TI/OA).
2. #42 OA-387 lead move: blocked on TI's schema row (RA 114).
3. #40 OA 382: RTL issue payload, A2's RS row carries pd, pred_we, ppold; cas-no-pd in RTL.
4. NGD fanout ratchets: ooe_rob_w (#34, lower caps; measured 29.8), ooe_rename (#35, 30.58 now; caps c_dst
   26.9 at 26.82, po_dst 27.5 at 27.50), ooe_rs (#38), ooe_ratread last (#39).
5. DA 111b / OA 364: a unit per OOE module per instantiated param set.
6. Optional #32 (OA 381): fa one-hot -> 5-bit index in ooe_rob_w.
- scratchpad/check-ngd3.py regenerated 11-08 from tools/check-ngd.py (CCV_ROOT env picks the tree).

## Done 11-07
- ROB slice 4 pushed adfa301 (SCOPED PASS 20/22); OI-128 row rev 322/323, OA accepted at 381.

## Done 11-06
- Slice 3 (memop commit, OA rev 362) pushed e491f22 (SCOPED PASS 22/22). Final fix: the
  zero-owed term as a match, dn_row 26.04 -> 25.7 under its 26.0 cap.
- OI-115 written (rev 306): RI-11 package for DA (C9 S1 +0.444%, cm128 -0.45%, cm32 -0.08%;
  flopped ~+1.95%; R49 +0.276%; C8 0).
