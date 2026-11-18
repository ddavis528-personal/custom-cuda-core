# OI handoff (OOE model and RTL)

Updated 2026-11-18 20:00 UTC. Survives a compaction. CLAUDE.md holds the repo's rules; this holds OI's.

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
  Next free ID: OI-172 (the #61 landing row). Pings Fridays.
- DA 11-18 (chat): pause NGD-to-25 fixes until the ccv_ooe top is built (real budgets, no
  false paths); finish ALL modules first so the top is complete when built. OI may move
  internal budgets where a measured parent times the connection and they still converge.
  Caps still only fall: a gate failing an existing cap is fixed, not re-capped upward.
- A fresh worktree needs sim/generated: `python3 tools/gen-params.py; tools/gen-ops.py;
  tools/gen-interfaces.py` before sim/ooe/run-tests.sh (the 18 FAIL lines it prints are
  controls; the verdict is the "ooe-test:" line).

## Daily sweep (scheduled task trig_01RHTzEomNoTP7mgfQxaNkmm)
Read every tab since the bookmarks; merge every remote branch ahead (not release,
gate-scratch/*), gate --full, push; pongs; pings Fridays; `tools/setup-session-home.py --check`.

## Register bookmarks (revs read through)
OI 375, OA 437, TI 480, AR 384, DA 127, MA 97, RA 156, RI 91, IS 197, CP 160 (TI-482 rung separately: answer in #58's landing row).

## Trees and runs in flight
- #61 push: /home/user/wt-61p branch oi-61p = origin 5e1f3789 + #61 commits, tip 2e80c608 (local).
  Gate f25a85da FAILED: CG budget (fixed by 2e80c608: bo_oh = entry bits on every done, qualified
  by flops bo_vw/bo_vr; budget 155/170.5, bench 26 controls) and NGD: fl_m 29.3 > cap 28.8
  (units 0,1,3), NGD-1 28.5 at cap (29.2/29.0 on _1/_2 in the gate). Bisect of 4ef48b45 (passed)
  .. 6c984007 on unit 0 running in /home/user/wt-bis (log scratchpad/af/bis.log); fix the commit
  that raised fl_m/NGD-1, re-measure ALL 4 units (_1.._3 vary), then gate-push. rm wt-bis, wt-61base.
- #58 lead form: /home/user/wt-58l branch oi-rxl, 942fa18e on oi-rx (the flop-form commits,
  withdrawn by DA rev 127 / OA 433). Rebuild the push branch from origin without the flop form.

## Open work (most urgent first)
1. #61: gate-push oi-61p; on green, OI-172 to OA (ring OA; ring TI for check-ooe-unit 58): NGD 28.48,
   caps, CG fixes, RH OA 427: ckpt_free_lag S1 +0.002% cm32priv +0.087% cm128priv +0.420%,
   rob_alloc_lag 0 everywhere. Then rm wt-61base.
2. #58 (DA rev 127 chose the lead form; AR 380 approved lead_fields [warp_id, fetch_epoch];
   OA 433/434): on oi-rxl (rebased off the flop form): model rx_lag bit 64 withdrawn (default 16);
   decrx.ngd.json lead-field inputs arrival 2 (as enq_l), held to 12 NGD (AR 380 (4)) - measure;
   rtl/cg-waivers.json CG-5 "lead": true waiver of enq_slot (12 flops; RI-15 ruling + OA 434);
   landing row confirms OOE's waived+allowance flops per instance stay within OOE's 2% (else to OA
   first). Push only after TI's lead_fields schema change lands (merge it: 3eb6e8d0 is on
   ccr-183cc441-doowtf). RH OA 428 E (rx_lag=80) vs A0: S1 +0.946%, cm32priv +3.575%,
   cm128priv +1.118%, stall.decq 0: cite in the landing row.
3. OA 435 module split (re:OI-171), in order: (1) ooe_slot #63, (2)(3) ooe_rcupl/ooe_mempl #64,
   (4) decq credit return + (5a) ooe_redir #65, (6) rob_w slice 5 syu_bar, (5b+7) epoch notices +
   slice 6, (8) rcu_map in ooe_rat, (9) rau_status, (10) cru_fault #66; then ccv_ooe top glue (no
   logic in ccv_ooe). Each lands with a bench vs model, a timing unit, controls, and a row
   proposing port budgets with measured NGD.
4. #52/#53/#54/#51 NGD-to-25 refactors: PAUSED (DA 11-18) until the top exists.
5. Blocked/parked: #40, #42 (TI schema), #46 (lead set), #32 (optional fa index).
