# OI handoff (OOE model and RTL)

Updated 2026-11-18 00:30 UTC. Survives a compaction. CLAUDE.md holds the repo's rules; this holds OI's.

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
  Next free ID: OI-167. Pings Fridays.
- A fresh worktree needs sim/generated: `python3 tools/gen-params.py; tools/gen-ops.py;
  tools/gen-interfaces.py` before sim/ooe/run-tests.sh (the 18 FAIL lines it prints are
  controls; the verdict is the "ooe-test:" line).

## Daily sweep (scheduled task trig_01RHTzEomNoTP7mgfQxaNkmm)
Read every tab since the bookmarks; merge every remote branch ahead (not release,
gate-scratch/*), gate --full, push; pongs; pings Fridays; `tools/setup-session-home.py --check`.

## Register bookmarks (revs read through)
OI 370, OA 428, TI 479, AR 372, DA 124, MA 82, RA 154, RI 90, IS 197, CP 159.

## Trees and runs in flight
- 5e1f3789 (LAT_MISS 16) pushed 11-18 via an imported split gate; OI-163 written, TI rung.
- /home/user/wt-61 (branch oi-af, on 5e1f3789): 9165f35c model knob rob_alloc_lag;
  65d9b55e ooe_rob_w allocation flopped on arrival (OA 422). rob bench + 25 controls pass
  (new control no-alloc-lag); model tests pass. Bench helper scratchpad/af/rob-only.sh.

## Open work (most urgent first)
1. #61 OA 422 in ooe_rob_w: PARKED on OA (OI-164, rev 368, OA rung). Step 1 pushed 69c50111.
   Step 2 in /home/user/wt-61 (branch oi-af): 65d9b55e + b50beabf (ckfa direct, bo_oh valid
   folded, wkf reduce-OR), unpushed; bench + 25 controls pass. NGD-1 31.3 vs cap 28.9 (cone
   ck->free->ckf RTL-identical to base; ABC variance). DA (11-18): stop logical optimization;
   repipeline (move logic between stages) or add a cycle. Await OA's cut, then build it.
   Remove /home/user/wt-61base (git worktree remove) when done. Probes scratchpad/af.
2. #58 OA 428: ooe_decrx built, local commit db0d1341 on oi-af (wt-61, on top of #61's
   commits). Bench 25 seeds + 6 controls pass (test/ooe/run-rtl.sh decrx; rebuild with
   scratchpad/rxbuild.sh); CG pass; NGD f2f 17.0, inputs need arrival budgets (OA).
   decq at enq arrival 13 fails (32.4), so the flop applies. RH is pricing rx_lag=80 vs 16 on
   5e1f3789 (S1/cm32/cm128). OI-166 (rev 370) to OA, rung: budgets, the keep+flop inside decrx,
   adv/adn double advance, per-slot alloc ports. On RH's price + OA: move the keep inside decrx
   with a flopped enq_v/slot/payload, add ooe_decrx.ngd.json, then gate-push.
3. #52/#53/#54/#51 NGD-to-25 refactors: PARKED on OA (notes scratchpad rob52b, go53, s54, rd51).
4. #57 DA 111b: done. TI's coverage check (3e687018, check-ngd/check-cg) fails an instance with no
   unit; scan (scratchpad/s54/cover.py) found none missing.
5. Blocked/parked: #40, #42 (TI schema), #46 (lead set), #32 (optional fa index).
