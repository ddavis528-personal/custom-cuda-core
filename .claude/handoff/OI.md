# OI handoff (OOE model and RTL)

Updated 2026-11-07 (C9h gate red: OI-122 to OA, kernel retime for TI). Keep this current at every task's end; it is what
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
Conventions 17, AR 313, RA 95, IS 190, TI 357, OA 373, OI 314, CP 155, DA 114, RI 21
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
1. C9 build (task #23; OA 372, DA 114): BUILT in scratchpad/wc9, branch oi-c9 (35999fa, e33da99,
   merges 86b477e, db3ad0b = TI's f4ce0fd; also on gate-scratch/OI). C9h is the model default
   (cmpl_split 9, rx_lag 16); ooe_cmcap new; ooe_rs hit-freed column clear (clr = free|hh, hhv
   flop for CG-2 7.8); ooe_wake hint capture hix+hq one gate. run-rtl and trio exact (no-c9h
   control). regen + walkthrough committed; cmpl_idx_cq00h arrival 2 written (00c77fe, OA 373).
   prv_code split granted (OA 374) and written (5e1b436). Gate on 5e1b436 RED; fixed in OI's files:
   ratchet grp_dep/sqf caps removed (met), no-msd seeds >=200 (f33368b, wc9 tip, unpushed).
   BLOCKED on OA (OI-122, rev 314, notice sent): ooe_wake timer enable 6.1 cone + grant arrival 2 =
   8.1 > CG-2 8 (C9h hm decode). Coarse/group/copies all fail (DCGE 47/55%, copies no-op). Asked:
   ooe_wake.ngd.json grant_cq01h arrival 1, ooe_sched.ngd.json grant_w_cq04h required 1 (out 0.0).
   On grant: write both, restate cg-waivers ooe_wake CG-5 enable_ngd 7.1 + why, check-cg both.
   ALSO RED (TI's tools/check-kernel.sh): privwin priv_form 12 (want 11, line 760); predswap at:58
   crack_split 0 and --break resume-mid. Measuring in wc9 (skel+oracle build, scratchpad/c9/
   skel-build.log, oracle.log); then sweep CCV_RAU_DEMOTE=at:N and raise OI-123 to TI.
   Then gate-push from wc9; then OI-114's row to OA.
2. OI-114 landed as (b) (OA 369), model only: the go reads unmet on time (unmet_reg 0; rename's
   register failed CG-5/CG-3), floor_take_lag 1; rename and go RTL as pushed. RH's S1: 0 cost at 192
   and 160 (X/Y, Z). Row to OA when pushed.
   (c) measured, for that row: unmet into go 23.9/24.2 at arrival 0, but go's own per-take chain stays
   over (ff 28.5, hv 31.4, px 31.1, pl 30.5, ha 28.8, room_p 26.9, room_g 25.4; 23.1 without fanout);
   rename with the (U-L) register: c_dst/c_src 27.3, po_dst 28.0, q_gname 28.5 (caps 26.9/27.5/28.7).
3. ROB slice 4 (faults; OA 370 for the pc): pc[31:1] per entry + pc[47:32] per slot
   (CCV_W_PC_WINDOW), 4,032 flops, written at fill from ccv_dec_ooe_uop.pc.
4. (slice 4 detail) The model's fault at retire (ooe_core.cpp ~2563) reports pc =
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
