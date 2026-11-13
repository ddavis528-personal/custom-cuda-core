# OI handoff (OOE model and RTL)

Updated 2026-11-13 (a2c1513a PUSHED, SCOPED PASS: MA-5 RTL+model, l1_nohit, sweep 11-13; OI-141 closed by OI-144 rev 345)
survives a compaction. CLAUDE.md holds the repo's rules; this holds OI's.

## Working rules
- The user is DA (Daniel). Standing order: continue OOE RTL until blocked; no need to ask
  for a go unless at a key decision point. Long performance runs go to RH
  (session_01QPk2jvfKM1V5rRfip8FC86).
- Gates (TI rev 418): launch `setsid nohup <gate> > log 2>&1 < /dev/null &`, never as a harness background
  task (2 h kill); wait in-turn on the log or `while kill -0 <pid>`. Until TI's self-detaching tools land.
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
Conventions 19, AR 348, RA 137, IS 193, TI 420, OA 415, OI 345, CP 157, DA 119, RI 71, MA 48
(sweep 11-13 (late, by hand): merged 8 branches incl. TI a46afef7 (MEMOP_CREDITS, no_hit, gate detach:
use tools/bg-run.sh / gate-wait.sh now), pushed in a2c1513a. Pongs 11-13: all 8 OK. Pings sent 11-13 15:20 UTC to AR OA IS TI CP RA RI RH; check pongs Sat. sweep 11-12, nothing for OI; merged 126afa13 5, 183cc441 3, 3868632d 4, 888218a3 5, 9eb50716 6, c22116ce 1. Sweep 11-10; AR closed OI-136; DA 117-119: MIU next, MA/MI/DI). Earlier: OI-136 (rev 337, Needs AR, RI): aborted sweep merges AR 80102643
(perf-register.md) and RI 888218a3 (cg-waivers.json, rcu_dec_pkg.sv, perf-register.md); rung both.
OA-399 leaves a LANE 8/SFU 13 rerun "if OI has not run 8/13": check against RI-11/OI-115. AR 314/OA 377: lead_fault = status==1, per slot; OI builds the capture
once TI's schema row lands. Pings 11-06: all OK. Settings: after TI's 350k merge `--check` may
differ; if so ask DA to approve `python3 tools/setup-session-home.py`.

## Tools (scratchpad, not in the repo)
- fo/path.py / path3.py: `START=<input> python3 fo/path3.py ir|rr <abc-*.blif>` traces the
  deepest path with fanout (3 decimals). Find a unit's blif by grepping a port name in
  build/synth-cache/abc-*.blif. check-ngd --unit returns rc 0 even over caps: compare by hand.
- check-ngd caps (rtl/ngd-ratchet.json "fanout") are strict (EPS 0.005); ABC remaps the
  whole unit on any change (untouched cones move +-0.3..1.7). Try equivalent forms.

## Open work (most urgent first; DA approved this order 11-07)
-7. DA 11-13 approved, after #39: #51 ooe_rendep to 25 (gsn_cq01h 28.5, psn_cq01h 28.8); #52 ooe_rob_w
   (NGD-1 29.6, al_n 29.2, dn_tag 26.3, fl_slot 28.6, fl_v 29.5); #53 ooe_go (NGD-1 26.1, ha 27.9, hv 28.9,
   pl 27.2, px 28.0, reach 25.3, wt 25.0; leave port-budget caps under 25); #54 ooe_sched (NGD-1 26.7,
   cidx 25.6, res 29.0, vel 28.2). Order: #38, #39, #51-#54, DA 111b, #32 (optional).
   Blocked: #40/#42 (TI schema), #46 (lead set), l1_nohit price (MA stub sends no no-hits),
   cand_indep_pend price (OI-143 rev 344: needs sectioned on).
   Gate note: the first a2c1513a gate was OOM-killed in cg (check-cg python 4.6 GB beside ngd's ABC);
   the identical rerun passed. If it recurs, rerun with fewer CCV_JOBS and raise a TI row.
-5b. #38 ooe_rs started 11-13: flop-flop 28.7 (18.9 without fanout, widest net 595 loads), prv_dep 26.4, req 28.4.
   Worst cone starts at the head pointer hh_cq02h[2] and fans to hm_cq02h (45 endpoints), gnt_v, lgv and gnt_idx.
   Trace it with path3 rr on the blif that holds prv_dep_cq01h (pass the absolute path).
-5. #49 MA-5 model (TI rev 414 asked it): Core::memopCredits() from the block each cycle (Stub::credits on
   ooe_miu P0-P3); select grants a memop only on a credited pipe, sends on the lowest; discards wait for P0's.
   inject_no_memop_credit control, ooe_test testMemopCredits (Env mcred_depth). Opt-in: unit/RTL benches unchanged.
   RTL next, once TI's 0da78445 (gate-scratch/TI-ma, CCV_MEMOP_CREDITS 10) lands: ooe_select cok input
   (proto scratchpad wt-sel, lost on container loss), select_tb/trio_tb drive cok from a new wlog_ sel_cok; tune
   cidx/sdep/chas remap. PUSHED dca29edc (SCOPED PASS); OI-140 (OI rev 341, Needs TI) rung TI: merge before ti-ma.
-4. OA 410 (OA rev 413, task #50): model knob l1_nohit beside l1_spec (no_hit[1] on cmpl_hint, valid I+12/payload I+13,
   clear spec wake by I+14, deps wake cmpl+1; refill hint wins), negative control ignoring no-hit; RH prices.
   Needs TI's field; stub sends none until MA Phase 1. AR 345/347 final (346 withdrawn): credits per memop CHANNEL slot P0-P3, 10 each, send on lowest credited
   slot of footprint (OA-412, MA rev 44). OI-139 (rev 340, Needs OA, AR; rung both) supersedes OI-138: worst path unchanged.
   OI-138 (rev 339, Needs MA, rung session_01QPk2jyUbWA7fW9YpUwqdxk, not in roster): credit gate 0 NGD (proto scratchpad/wt-sel).
-3. OA-409 (OA rev 412, re:MA-5): IF memop credits become queue entries, ooe_select gates each P grant on that slot's credit; build it and measure grant NGD then. Waits on MA's decision.
   Sweep 11-12 pushed ae8a6bdf (full PASS). RH CoreMark for OI-137 due ~07:00 UTC 11-13. Pong to OA sent 11-13.
-2. #35 ooe_rename PUSHED d86e3a14 (full PASS, with the 11-10 sweep merge of 183cc441/126afa13/80102643/9eb50716):
   flop-flop 24.73, one cap left (q_pname_cq03h 3.32). Model knob cand_indep_pend (on). OI-137 (rev 338, Needs OA)
   rung OA; RH asked to price on vs off (U/G/L 192/160/128, CoreMark, S1). On RH's table: add to OI-137. OA-407 (OA rev 411): accepted if on/off within 0.5% on S1, cm32, cm128; over goes to DA. RH started 13:33 (S1 first, CoreMark ~8.5 h).
   Asked DA (no answer yet) whether to add tasks for rendep/rob_w/go/sched to 25 after #39.
   LESSON: the container is reclaimed when a turn ends, killing detached gates (3 lost 11-10). Run the gate
   detached AND stay in the turn: `timeout 590 bash -c "until grep -q '^EXIT' $L; do sleep 20; done"` loops.
-1. #34 ooe_rob_w PUSHED 4dfd22cc (full PASS, with the 11-09 sweep merge): hrb binary head, uft
   thermometer, w_h head window copy; caps NGD-1 29.6, al_n 29.2, dn_tag 26.3, fl_slot 28.6, fl_v 29.5
   (measured 29.54/29.12/26.22/28.50/29.49). CG passes within allowance (win_en group 37-39%, pch 0%).
   Next: #35 ooe_rename, then #38, #39, DA 111b, #32. ccv_ooe.ngd.json withdrawn (1bc1e268) until ccv_ooe is RTL.
0. #33 PUSHED (5eb3acb8, SCOPED PASS 23/23, with TI 21b4b80 merged); OI-135 closed at OI rev 334.
   Lesson: any load on ren1's l_x/l_v/tk_* remaps ooe_rename's q_gv cone (+0.5); take from c_xl per class.
1. #26 OI-134: RH 95bf04d: U160 -2.22% vs G160, U128 -2.16%, L160 +1.87%, L128 -2.07%, U192 = G192.
   Local commits f4d5ee10 (model unmet_reg=1 + ur register) and 68817c46 (c_dst cap 27.5, DA's ruling
   11-08; recover <=26.9 in #35), backed up at gate-scratch/OI. First gate FAILED CG-3: ur_g/ur_p
   51-63% DCGE. Uncommitted rework: per-slot enable (occupancy changed / frees / own take, held at 0 and at
   the LU ceiling via top_of; ur_oc per slot, reset 1 because occ rises at reset release with no lead).
   v6 (global ur_o) 50-60%; v7 (per-slot ur_o, +3 CG-1 flops, likely over 35.5 allowance) being measured
   (scratchpad run7.sh -> rn7.log, cg7.log). If v7 clears CG-3 but not the budget, ask DA: allowance
   waiver (4 flops) vs CG-3 waiver (44 flops). On green: OI row (Needs: TI, OA), ring both.
1b. RI-26 (DA 116: 13 RCU / 0 OOE; OA 401/402): add iss_lead_cq03h {"required":0.0,by OA,2026-11-09}
   to rtl/ooe/ooe_rs.ngd.json (no carries); ccv_ooe.ngd.json keys ooe_rcu_issue_payload.{lead_opcode,
   lead_done_row,lead_pred_we,lead_phys_dst} required 0.0 once TI's ti-lead (4d6065fd) lands and ccv_ooe
   is RTL. Then OI row re:RI-26, FYI, rings no one.
1c. TI 397 re:RI-25 (RST-2 landed, TI ea8ae6f1): ooe_rename's u_gfree/u_pfree run at FS=1 but the
   ooe_freelist units are FS=4: add FS=1 units (cg-units, ngd units), merge TI's branch; answer in OI tab.
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
