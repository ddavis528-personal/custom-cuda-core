# OI handoff (OOE model and RTL)

Updated 2026-11-17 20:20 UTC. Survives a compaction. CLAUDE.md holds the repo's rules; this holds OI's.

## Working rules
- The user is DA (Daniel). Standing order: continue OOE RTL until blocked; ask only at key
  decision points. Long performance runs go to RH (session_01QPk2jvfKM1V5rRfip8FC86).
- Push only with `CCV_JOBS=2 CCV_PUSH_BRANCHES=ccr-57eff422-5tdecg tools/gate-push.sh` (--full
  for a sweep merge). It self-detaches (exit 5, prints the job log); then run
  `tools/gate-wait.sh <job log>` as a background task (timeout 7200000): exit 3 rerun the wait,
  exit 4 relaunch. A detached gate survives a container restart (11-17): re-arm the wait.
  Never push manually or red. No PRs. One gate or heavy job (check-ngd, CoreMark) at a time.
  Never pgrep/pkill -f; never TaskStop bg-run/gate-wait; don't edit a tree a gate runs in.
  CCV_JOBS=2: check-cg OOMs at more (OI-157).
- Owners: OA the microarchitecture and port budgets; DA waivers and anything over OA's 0.5%;
  TI schema/, params/, tools/. Never weaken a negative control; ratchets and caps only fall.
- Commits end with Co-Authored-By and Claude-Session lines; no model ids anywhere pushed.
- Register: write only the OI tab (node 384bc26c-cef6, table m8yvbw8rqgz.11664, rows: title,
  date, summary ending "Needs: X", detail). No dates on rows or promises (DA 11-16).
  Notices: `python3 .claude/skills/register/notice.py compose ...`, send_message priority
  "later". OA session_01TbX2MyX6quhjarDR7J2bMR, TI session_01J4Yp3xeV6DJtgCtcoqVsAq.
  Next free ID: OI-163. Pings Fridays.
- A fresh worktree needs sim/generated: `python3 tools/gen-params.py; tools/gen-ops.py;
  tools/gen-interfaces.py` before sim/ooe/run-tests.sh (the 18 FAIL lines it prints are
  controls; the verdict is the "ooe-test:" line).

## Daily sweep (scheduled task trig_01RHTzEomNoTP7mgfQxaNkmm)
Read every tab since the bookmarks; merge every remote branch ahead (not release,
gate-scratch/*), gate --full, push; pongs; pings Fridays; `tools/setup-session-home.py --check`.

## Register bookmarks (revs read through)
OI 366, OA 428, TI 478, AR 372, DA 124, MA 82, RA 154, RI 90, IS 197, CP 159.

## Trees and runs in flight
- /home/user/wt-s54 (branch oi-rw): 5e1f3789 ooe_wake LAT_MISS default 16 (TI-478, AR 368),
  gate-push in flight, job log /root/ccv-logs/job-gate-push-20261117-193015-15524.log.
  On PASS: OI-163 answering TI-478 (default now 16, TI can drop its override), ring TI.
- /home/user/wt-61 (branch oi-af, on 5e1f3789): 9165f35c model knob rob_alloc_lag;
  65d9b55e ooe_rob_w allocation flopped on arrival (OA 422). rob bench + 25 controls pass
  (new control no-alloc-lag); model tests pass. Bench helper scratchpad/af/rob-only.sh.

## Open work (most urgent first)
1. #61 OA 422 in ooe_rob_w. Step 1 (registered retire pick) pushed 69c50111. Step 2 (arrival
   flops) committed 65d9b55e: next, after the wt-s54 gate, `python3 tools/check-ngd.py --unit
   ooe_rob_w_1` (and _2, _3, ooe_rob_w): lower caps in rtl/ngd-ratchet.json to the measure; check-cg;
   gate-push from wt-61. Before step 2: NGD-1 28.82 (ck->ckfa_s), al_n 29.6, fl_m 28.8 (arrives 2,
   26.8 after: an arrival flop cannot fix it; needs an internal cut ~1050 flops, or back to OA with
   its path), dn_tag 25.04. Then RH prices rob_alloc_lag=1 (with rob_retire_lag 0/1) on S1,
   cm32-priv, cm128-priv. Then an OI row to OA: the go needs no change (the run register takes
   the arriving count late, exact); the no-op/fault cost is now modelled (corrects OI-160's "0");
   whatever is still over 25 with its path (fl_m, ckfa_s). Design notes: scratchpad/af/plan.md.
2. #58 ooe_decq arrival-side A-70 epoch drop (TI-457 / OI-156) + decq_tb case.
3. #52/#53/#54/#51 NGD-to-25 refactors: PARKED on OA (notes scratchpad rob52b, go53, s54, rd51).
4. #57 DA 111b: a timing unit per OOE instance at its parameters (scratchpad/s54/cover.py).
5. Blocked/parked: #40, #42 (TI schema), #46 (lead set), #32 (optional fa index).
