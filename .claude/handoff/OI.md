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
Conventions 17, AR 313, RA 95, IS 190, TI 354, OA 372, OI 310, CP 155, DA 114, RI 21
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
1. C9 build (task #23; OA 372): C9h + the RS bypass, cycle-exact against the model at
   cmpl_split 9 + rx_lag 16 (the hint late). cmpl_l raw drives capture, RS and wake only (3 pins);
   ROB x4 from (* keep *) copies of cm_q; hint raw to its capture only. Bypass ports: rs
   cmpl_l/cmpl_idx (cfb), wake fin + confirm, the miss check at LAT_MISS, msd. Over a cap: to OA.
   The model's knobs are still a patch (scratchpad/c9/c9knobs.patch); the build makes C9h the
   model's default. Tree scratchpad/wc9 (branch oi-c9 on fb52948: knobs patch + wake/rs probe;
   scratchpad/c9/trio-build.sh <tree>). S1 (OI-118, rev 310): C9 +0.370% vs A6 at 8/13, F +1.581%;
   at 7/12 (the baseline again, RA 95, AR 313) C9 +0.444%, F ~+1.95%. C9h costs 0; no RS bypass +0.56%.
2. OI-114 landed as (b) (OA 369; RH S1 at 0 cost at 192 and 160): pushed ooe_go, rename form 3
   (registered unmet less last take, arrival 6), model floor_take_lag 1. Row to OA when pushed.
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
