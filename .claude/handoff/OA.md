# OA handoff (OOE architect)

Updated 2026-11-02. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds OA's.

## Role and rules (from Daniel, in conversation)
- OA owns the OOE microarchitecture doc, not code: Claude doc
  7tpEyGaCvfdvYYWUQJvJSU, body node 401b2bac-8176. Update it without asking
  (DA, 2026-10-20); keep it consistent with every decision.
- Register: write only the OA tab (node 4c6a3151-83eb, responses table
  m8yvbw8rqgz.6213; every row exactly 4 cells: title, date, summary, body).
  Record Daniel's decisions verbatim in the DA tab (table m8yvbw8rqgz.231).
- Report to Daniel in a few lines: what changed, then any decision that is
  his. He is a senior microprocessor design engineer; write as to a peer.
- Mine to rule: admission-cost changes under 0.5% on S1, the audit and the
  out-of-order floors. Over 0.5%, a waiver, or any exception narrowing one of
  DA's rules (CG, NGD, lint) goes to DA with figures and a recommendation.
- Every figure is model-only or RTL-bench-held; say which.
- Notices: `notice.py compose`, `send_message` priority "later"; only for
  rows that ask something of the receiver (skill section 2).
- Branch ccr-9eb50716-lecnjf: merges only (merge commits). Pushes take the
  scoped gate (OI-95, DA 2026-10-31): `CCV_PUSH_BRANCHES=ccr-9eb50716-lecnjf
  tools/gate-push.sh`; the sweep's merge takes the full one (add `--full`).
  The sweep's merge skips gate-scratch/* (TI rev 289, DA's choice).
  The stop hook's "unpushed commits" while a gate runs: say the push is held.
- Commits end with the session's Co-Authored-By and Claude-Session lines.

## Daily sweep (trig_017UEX7qaTRGT27eW6yQ1tJo, 02:07 PT)
Skill section 4 (register-reader digest), then
`CCV_PUSH_BRANCHES=ccr-9eb50716-lecnjf tools/daily-sweep.sh` in the
background; `python3 tools/setup-session-home.py --check` (exit 1: ask DA to
approve the install again); pings Fridays only (TI-49); report in a few lines.
Session home installed 2026-10-31 with DA's approval (TI-50): /home/user/.claude
holds the 400k window, the handoff hook and the agents link.

## Sessions
TI session_01J4Yp3xeV6DJtgCtcoqVsAq, OI session_01DMw4FtFbGoVboMGxWpLBuv,
AR session_01FnGhxke3r33MeArLeQJRcD, IS session_01989HiTNh4Gx7XMSsdvdE7Z,
CP session_019cSebQ45AT3pSnPU71torg, RA session_01QPk2jzLmjd3MWXjayVUy9d,
RI (session not yet on the roster). OA is session_01TbX2MyX6quhjarDR7J2bMR.

## Register bookmarks (revs read through)
Conventions 17, OA 313, AR 268, TI 291, OI 252, IS 185, CP 152, DA 104,
RA 58 (tab 9851686b-2b0a), RI 1 (tab 8e4547bc-c469).
OOE doc rev 352. DA tab 98. Pings 2026-10-30 (Fri): all five ponged ok. Next pings Fri 2026-11-06. Roster has RH (run helper, offload worker).

## Open work (most urgent first)
-1. OA-24 (rev 311, DA tab 104): DA's top priority. ooe_rob -> 4x ooe_rob_w #(WID),
   ooe_rob wires only; fill by fl_slot==WID, dones by tag warp bits; each
   instance flops its own gfree/pfree, ooe_freelist ORs the four (OA budget 2.0
   on those inputs). Done when: miter old vs new+OR4, per-warp unit memory
   under 2048 MiB, budgets carried and re-signed by OA, CG allowance check.
   TI took it (rev 291). Miter: test/formal/fv_rob_split.sv vs ooe_rob_ref.sv,
   one-time run, not gate (OA rev 312).
-0. 11-02 sweep (fe24167, 106 commits unpushed): full gate RED only on the
   heavy-unit guard (11 light units at exactly 2221 MiB, wait4 ru_maxrss
   inherits the parent's peak; TI's e878569/e44d767/0facb89). Raised to TI
   (OA rev 313). Rerun the full gate once TI's fix is on a branch (merge it).
   Container gets reclaimed: run gates detached (setsid bg-run) AND a
   run_in_background waiter loop (2 h cap, re-arm); check liveness with
   `ps -eo pid,etime,args | grep "[g]ate-push.sh --full"`, never pgrep -f.
   The container also restarted once mid check-cg with a waiter live (cause unknown).
0. RCU (RA/RI) rulings 11-01..02, OA revs 297-310: idle-R run bound K 4 (OI
   builds, prices); collectives + RCU-only one issue class (OI, price); call
   link in imm at rename, offset to branch record (OI NGD); atomics/demotion
   answered; barriers don't issue to RCU in first build (rev 301 corrected);
   fixed done slots OK, SFU one a cycle; early collective done legal on 3
   conditions; fold to 3 goes to DA with RA's Phase 1; lead slice on
   ccv_ooe_rcu_issue (AR agreed, 9 b/slot + R guard pred); RA-32 lag-1
   fallback withdrawn; fanout term: OOE's 25 holds, OI per-net plan (rev 310);
   ooe_wake cls/kind_cq01h arrival 2 if flop-driven; L1 wake 12 held on OI.
1. OI-86/OI-88 ADOPTED (b) by DA 10-31 (DA tab 98). AR's lead (RCU spec rev 20)
   branch/call only; TI pushed it (80697a3). OA rev 294 took resolve_lag_ret_only
   1, ret_hold 1, squash_act_lag 1, squash_held_room_lag 1 (S1 +0.03%, cm32
   +0.01%, cm128 -0.30%, audit 912; model). Floors run (RH, after slice 2b)
   adds rets and S1 for OI-94; >0.5% -> OA.
1b. OI-94 (c): accepted as built (OA revs 295-296): RTL kill count waits on the
   fill; model C'' fixed lag. Close OI-94 when OI reports two asserts in:
   model fill = alloc+2, and no RS/RAT write after a squash (with Rename's mark).
   Slice 2b (OI c911fe3/969a42b) blocked on gate memory (OI-97; TI 4c2ce8b).
2. OI-85 ROB: slice 1 pushed 9c079f9 (retire_lag 1 taken, rev 278; default
   waits on OI-87's go_tb fix and TI's re-pins). Row-indexed dones (rev 282,
   283) pushed 6ba08b1. Barrier side buffer 2 deep (rev 279): OI counts holds
   in slice 5; depth 3 if over 0.5%. OI-90 (rev 286): per-row done counts,
   2 bits a row, ooe_rs holds a replay at 3 in flight (asserted, control);
   rev 282's done bit missed A-47 replay. Pushed da182a7; hold 0 outside a replay storm.
3. Overhead review list for DA after the first pass: NGD-7 copies (736, 220,
   340 flops), OI-84's 360 flops, RAT read ~2x, waivers (ooe_go, names' pools
   10 flops, candidates 72), scarce names +0.53%, retire lag +0.25%.
4. OI-93 (rev 287; rev 289 fl_brl_cq01h input 2; rev 290 slot class = all CCV_LAT_RCU ops, TI 16af94a): ROB slice 2a budgets granted; RCU-only dones on fixed slot CCV_DONE_SLOTS-2 (not 0); TI schema contract; AR confirmed (rev 257, RCU spec rev 19: only lat_class 0 sets aux/branch_mask; barriers stay lat_class 0).
5. Overhead list add: rope +994 cycles (+14.7%, model) from shfl's corrected
   CCV_LAT_COLLECTIVE (TI b0d91c2): shfl feeds branch conditions; candidate for
   a shorter collective latency.
6. Watch: L1 size (AR-24 eight-trace sweep, TI); TI-47 done.

## Settled recently (for context)
TI-46 (b) credits, share 7, r 2, queue 13 (231c29e). OI-83 late RAT write,
NS 4. OI-84 adjacent atomic pairs. IS-25 frames in O-83 region (OOE
unchanged). O-80/O-81/O-83 ISA. OA-16 on hold (perf register).
