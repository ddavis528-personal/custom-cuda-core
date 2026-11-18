# OI handoff (OOE model and RTL)

Updated 2026-11-18 14:20 UTC. Survives a compaction. CLAUDE.md holds the repo's rules; this holds OI's.

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
  Next free ID: OI-171. Pings Fridays.
- A fresh worktree needs sim/generated: `python3 tools/gen-params.py; tools/gen-ops.py;
  tools/gen-interfaces.py` before sim/ooe/run-tests.sh (the 18 FAIL lines it prints are
  controls; the verdict is the "ooe-test:" line).

## Daily sweep (scheduled task trig_01RHTzEomNoTP7mgfQxaNkmm)
Read every tab since the bookmarks; merge every remote branch ahead (not release,
gate-scratch/*), gate --full, push; pongs; pings Fridays; `tools/setup-session-home.py --check`.

## Register bookmarks (revs read through)
OI 374, OA 436, TI 480, AR 384, DA 127, MA 97, RA 156, RI 91, IS 197, CP 160 (TI-482 rung separately: answer in #58's landing row).

## Trees and runs in flight
- #61 push: /home/user/wt-61p branch oi-61p = origin tip 5e1f3789 + the #61 commits (no decrx):
  rob_alloc_lag (OA 422), ckpt free lag (OA 427 opt 2), OA 431's cut (te_q flop, sqm fold),
  caps NGD-1 28.5, al_n 26.6 (exact 28.48/26.58; dn_tag 25.0 now, fl_m 28.8 kept). After the
  4ef48b45 gate FAIL: e64e031e (te_q enable al_q|rel_q|rd_s; check-ooe-unit count 58, TI's file),
  c11f3735 (bo_oh raw one-hot; did NOT fix its CG-3, within allowance), 597fb2bb + 6c984007 (squash
  regs' enable: candidates & a per-slot wrong flop rs_w, CG-2/CG-3 clean). cg budget 164/170.4,
  check-ngd pass, rob bench 26 controls. gate-push from there.
  wt-61 (oi-af) holds the same plus the withdrawn decrx flop commits; wt-61base to remove.
- #58 lead form: /home/user/wt-58l branch oi-rxl, 942fa18e on oi-rx (the flop-form commits,
  withdrawn by DA rev 127 / OA 433). Rebuild the push branch from origin without the flop form.

## Open work (most urgent first)
1. #61: gate-push oi-61p; on green, OI-171 to OA (ring OA; ring TI for check-ooe-unit 58): NGD 28.48,
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
3. #52/#53/#54/#51 NGD-to-25 refactors: PARKED on OA (notes scratchpad rob52b, go53, s54, rd51).
4. Blocked/parked: #40, #42 (TI schema), #46 (lead set), #32 (optional fa index).
