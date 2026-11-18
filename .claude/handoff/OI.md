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
  Next free ID: OI-166. Pings Fridays.
- A fresh worktree needs sim/generated: `python3 tools/gen-params.py; tools/gen-ops.py;
  tools/gen-interfaces.py` before sim/ooe/run-tests.sh (the 18 FAIL lines it prints are
  controls; the verdict is the "ooe-test:" line).

## Daily sweep (scheduled task trig_01RHTzEomNoTP7mgfQxaNkmm)
Read every tab since the bookmarks; merge every remote branch ahead (not release,
gate-scratch/*), gate --full, push; pongs; pings Fridays; `tools/setup-session-home.py --check`.

## Register bookmarks (revs read through)
OI 369, OA 430, TI 479, AR 372, DA 124, MA 82, RA 154, RI 90, IS 197, CP 159.

## Trees and runs in flight
- 5e1f3789 (LAT_MISS 16) pushed 11-18. /home/user/wt-61 (branch oi-af, unpushed): 9165f35c
  rob_alloc_lag knob; 65d9b55e+b50beabf alloc flopped (OA 422); deb4265a ckpt frees a cycle
  after resolution (OA 427 option 2: RTL frp/frv/cfl, model ckpt_free_lag, rob bench control
  no-free-lag); 15ef1bd4 directed test control (Env junk_prog, miss_add). Model suite + rob bench
  + 27 controls pass. 15ef1bd4 on gate-scratch/OI; RH asked to price A/B/C/D (defaults,
  ckpt_free_lag, rob_alloc_lag, both) on S1, cm32-priv, cm128-priv vs 5e1f3789.

## Open work (most urgent first)
1. #61 OA 427 option 2: built (see trees). NGD /root/ccv-logs/ngd-rob.log: frp (ck->registered
   free) 28.84, ckf 21.7; +33 flops; CG pass (new gate 38 flops, enable 7.3, DCGE 100%). Other cones
   over caps after step 2 (fka 30.1, sq_rt 29.9, fa_oh 29.9, run 29.4, fl_m NGD-3 29.3 vs 28.8; base
   measured 28.8): need repipelining. On RH's price: write OI-166 to OA (NGD, flops, CG, price,
   the over-cap cones), ring OA. <= +0.5% S1: ruled, land it; over: bring option 1 figures.
2. #58 A-70 arrival epoch drop: PARKED on OA (OI-165, rev 369, OA rung). RTL has no warp-to-slot
   table/per-warp epoch; proposed a DEC receiver module ahead of ooe_decq (decq unchanged).
3. #52/#53/#54/#51 NGD-to-25 refactors: PARKED on OA (notes scratchpad rob52b, go53, s54, rd51).
4. #57 DA 111b: done. TI's coverage check (3e687018, check-ngd/check-cg) fails an instance with no
   unit; scan (scratchpad/s54/cover.py) found none missing.
5. Blocked/parked: #40, #42 (TI schema), #46 (lead set), #32 (optional fa index).
