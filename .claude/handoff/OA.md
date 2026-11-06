# OA handoff (OOE architect)

Updated 2026-11-05. Keep this current at every task's end; it is what
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
Conventions 17, OA 363, AR 306, TI 346, OI 306, IS 189, CP 154, DA 112,
RA 82 (tab 9851686b-2b0a), RI 15 (tab 8e4547bc-c469).
OOE doc rev 364. Pings 2026-10-30 (Fri): all ponged ok. Next pings Fri 2026-11-06.
Sweep 11-05: 6 branches (209 commits) merged at 76f0190, full gate green, pushed;
release 5174359; snapshot tag refused by the proxy (known, local only).

## Open work (most urgent first)
-12. RULED 11-06 (OA 363, under 0.5%): RI-11 OOE cmpl+hint ends first kind = C9, +0.444%
   S1 over A6 (model; cm128 -0.45%, cm32 -0.08%); flopped H3+P ~+1.95% not taken. HINT 2/
   FILL 4/MLC 39. TI: links.json no_flop at OOE; OI builds; AR updates specs. OOE doc 365.
   R49 dropped (S1 +0.276% cost); ooe_rs stays 45 rows, 26.2 on cap. Told DA; DA may overrule.
-11. DA APPROVED in OA's session 11-06, verbatim "I approve the token limit" (DA tab 112):
   once TI's autoCompactWindow 350000 push (2d445f5, TI-51) is merged into this branch
   (the daily sweep merges it), run the session-home skill / tools/setup-session-home.py
   so /home/user/.claude takes 350000; check with --check. Not yet on origin at 03:40Z.
   TI-51 (2) sum of parts (DA tab, AR from TI paraphrase): no whole-block synthesis;
   every instantiated module needs a unit per param set; port budgets are the contract.
   When TI posts what it cannot catch, have OI check OOE unit coverage.
-10. OA 357/358: cmpl AND hint ends both first kind (AR 303 ok; shared treatment keeps
   HINT 2/FILL 4); free flops RAU/demote/SYU. A6H=H3: all +0.56% is the hint bundle.
   OI probes the two bypasses (L1 hit->spec timer, ROB done bits; RTL) + S1 delay knob.
   OI-114 (OI 301): pick = unmet registered at ooe_rename (go budget 6->0) + need-side
   shift; price S1 + PHYS160 repro; <0.5% lands, only within ooe_go's caps.
   DA package waits on: bypass probe, R49 S1.
   OI 303 probe (RTL): capture free; sched bypass 23.7 ok; rs cfin 28.5 -> (a) hit
   confirm an edge late (knob) or (b) free cone to 21 if (a)>0.3% S1; ROB done an edge
   late = C1 (audit +0.8%). OA 359: package = first kind (C1+rs a, HINT 2) vs flopped
   (H3+P ~+1.95% over A6) + R49 S1; RH job 2 pricing.
-9. OA 355 (re OI 298/299), reported to DA 11-06: CA rejected; ooe_rs stays on cap 26.2.
   DA picks: R49 (-2.0..-2.4% audit, +1,944 ooe_rs / +3,353 OOE flops; OA rec only
   if S1 >= 1%, OI runs S1). RI-11: H3 params +0.56% S1 (rec accept); hint/RAU/
   demote/SYU flops free; miu_ooe_cmpl flop +1.39% S1 -> rec no-flop end AR-300 kind 1
   if OI confirms RTL + AR confirms kind applies. Record DA's answers in DA tab.
-8. ooe_go depth (OI 297, OA 354): picked (c) keep caps (27.6 f2f/29.9 in/25.8 out,
   RTL); 748e071 stays out. OI prices (a) unmet registered (minus last take) +
   (b) fits on last cycle's pool (never overgrant) as one point, low priority.
   RAT read (OI 296/TI 341): ooe_ratread 17.9 vs 16 alone; 43 caps wait for ooe_rename.
-7. ooe_rs depth (OA 351/352, OI 293/294): copies took ooe_rs 30.1->26.2 (RTL, cap 29.4).
   rs_free_lag DROPPED: free not on valid->grant-prefix path, buys no depth.
   OI prices in one audit: (1) per-port candidates registered a cycle ahead (new
   semantic) + RTL depth est; (2) 49 rows no lag (+3,353 OOE flops, ~5.1%, ooe_rs
   +2,573). Then DA: (a) stay on cap (likely rec), (b) pre-register if <0.5% and
   meets 25, (c) 49 rows only if speedup well over 1%. Told DA in chat 11-05.
-6. RI-11 cmpl (AR 298, OA 350): CMPL_HINT 3 / FILL_NOTICE 5 covers noticed-refill
   wakes only. OI splits miu_ooe_cmpl +1.60% S1 (refill/on-completion/cancel shadow)
   + hint point, in the package run, now a links.json no_flop run in both hosts
   (AR 300 link term: crossing = HOP + link_n + bnd_rx; OOE contracts unchanged at
   defaults; OA 353, doc 364). Then OA recommends cmpl treatment to DA.
   lane_rcu_res is the only RCU zero-cycle candidate.
-5. RI-11 / DA 11-05 (via TI rev 321, verbatim; OA recorded DA tab 107): interface
   module default one flop in + out (2 cycles/link), zero-cycle option kept; AR does
   latency accounting first. OA rev 339: RA-39 19/6 lapses; OOE list given to AR;
   OI prices defaults + per-channel zero-cycle -> DA. OOE doc follows AR.
   TI rev 322: HOP 2 already counts a flop each side (CCV_RT_ABUT), so links need
   not grow if block/module output flops merge; what moves is logic before the
   first flop. AR rev 285 accounting: LANE 8, SFU 13, L1_WAKE 17, CMPL 19, RCU 3, bypass
   same. OA rev 340: OI audits OOE receivers (cmpl/hint wakes first) + prices for DA.
   AR 286 final: ADDR_BASE 6, LANE_BASE 8, SFU 13; no credit depth grows; MISS_WAKE,
   HINT, BYP same. OA 341: +1 should sit on PF-47's adopted base 1 (=2, WAKE 13).
   DA 108 (via AR): boundary lead flops count vs receiver's 2% CG; OOE takes
   rcu_ooe_done's 231; OA 342 asked OI for margin, shrink lead fields first if over.
   OI 286: OOE 1.45% ungated with the 231, margin 326; nothing moves. OI 285: receiver
   audit done, rx_lag pricing -> DA next. OA 343: issue timing (A) valid+lead in I
   t+1, payload t+2 via late G copy (HOP already assumes it); select lead muxes dropped.
   TI 332: OOE 978 of 782 with boundary leads (375 = 231 done in + 144 issue out), but
   TI counted rob_w x1 and old ooe_rs; OA 344 asked recount (~1,200 vs ~1,309), OI to
   gate issue lead off G valid, then list movable done-lead fields (<0.5% mine).
   RESOLVED: TI 333 withdrew; OOE ~1,200 of ~1,309, fits; OA 345: no shrink, issue-lead
   gating optional margin; depends on ooe_rs gated payload store landing.
-4. RA-11 PHYS_REGS (OA rev 333): 160 meets Q-35 (ceil 44 >= ROB 32), 128 fails
   (ceil 24 < 32). TI rev 316: runs DID use derived 12/44, 8/24, so my
   16/64 guess was wrong. OI-114 (OI rev 281): go floor term ignores
   the slot's take in flight (model AND ooe_go); OA rev 334 took max(0,want-held-took),
   all unseen takes, within go caps else registered; then TI re-runs 160. After clean 160 re-run (2 four-warp kernels, S1, audit,
   <0.5%) OA recommends 160 to DA via AR; OOE doc keeps 192 until DA decides.
-3a. Landed 11-04: freelist gsec retime 013ed10 (no reuse cycle lost); decq retimed,
   DECQ 15 + lag 1 at 41ebad9 (OI-109/111 closed); sched (b) ret_hold 2 gating.
-3. RA-39 early R read (R0/R1 in A; OA revs 328-329): only L1 hits miss A
   (data lands in consumer's A). (i) MIU forward on R0/R1 TAKEN rev 329 (RA:
   ~10k cells, 190 flops, A 16 NGD; overhead list); OOE doc rev 363. (ii) withdrawn.
   OI-115 (rev 335): R lead mux off final grant = sched 38.8 (cap 30.5); OA: probe
   (0) mux off R's own pick (R footprint alone), lane slots off main+fallback picks
   + late 2:1; RA prices fallback R0/R1 from payload wires (~19, RCU in-budget);
   (1) valid a cycle later -> DA last. RA priced (2) 19.5 fits: TAKEN rev 336,
   lead_r_src0/1 WITHDRAWN, phys_src0/1 budgets RCU in 19 / OOE out 6 (rev 337, RI measured 18.4; last move); (0) probe
   still for RA-31 lead fields. ooe_rs has no payload store in RTL yet.
   (b) lead_r_src0/1 accepted; OI lead-mux NGD/CG, TI schema, AR agree.
-2. DA 11-04 (DA tab 105): fanout term ENFORCED in check-ngd; TI seeded the
   ratchet b11e60f (TI rev 304): 109 caps (ratread 43, go 16, rename 11, sched 8,
   freelist 7, rendep 7, rs 7, rob_w 6, decq 4; decq clears with lag 1); caps
   only fall. Freelist (a) BUILT 32ba2d0 (24.1 f-f); OI-106 gsec sa_row/sa_v
   26.7/26.4: rev 330 retime inside freelist, no budget; reuse cycle -> model price.
   OI-107 (rev 331): decq lag built but caps are next_state/arrival (26.4/30.1/
   27.1/25.2), not credits; retime decq at 15 first, lag+15 in same push, no cap
   relief (DA rule); lost cycle -> model, <0.5% mine. TI DECQ stays 13 till then. My rev 326 ratread alone-rule ask still unanswered by TI. OA rev 321 order: go+sched (held) first; then one model
   batch pricing freelist scan (a two-step / b banked) + rs/decq free candidates
   a cycle ahead (<0.5% total mine, else DA); rendep sender probe (else rename
   stage -> DA); rob_w fill probe (input stage?); go remainder; copies last.
   rev 322: TAKEN freelist (a) two-step (final). rs WITHDRAWN rev 325 (+1.1-1.6%
   corrected): OI copies probe, then lag with +2 rows/class, else DA beside decq.
   TI dry run (rev 299): 115 findings; 43 are ooe_ratread NGD-6 alone, asked TI
   if alone-rule applies once instantiated, OI for parent-timed path (rev 326). (was: S1 to
   confirm). decq ADOPTED by DA 11-04 (DA tab 106): 15 entries + free lag 1;
   TI CCV_P_DECQ 15, AR DEC credit pool 15, OI builds (OA rev 327).
-1. OA-24 CLOSED (OA rev 314): OI's split pushed (e35c9f9/4d388f8); budgets
   re-signed; CG 1.03% within 2%; per-net plan still covers ooe_rob_w head_cq02h
   (2205 loads) and rst_r01h; miter depth 16 at 8 entries asked if cheap.
   OI-104 done: kind/class stored in ooe_rs (b23bbd8), rename wired (1f7c642);
   TI reapplies L1 wake 12 (base 1).
   Fanout rulings rev 318 (OI rev 258): no re-budgets; rs registered free
   candidates and freelist two-step vs banked are model-priced (<0.5% mine);
   sched: (b) TAKEN rev 320 (ret_hold 2, hold cancels after pick, 1.25 lost
   slots/kop ret-heavy, 0 on kernels; OOE doc rev 360); OI builds, reports depth;
   go: priod x dr decode, then senders of hv/pl/px/unmet; decq with rs pricing;
   rendep decode cp upstream (extra rename stage
   -> DA); go: OI sends widest series nets. rob_w head fixed 31.9 (7aeb62a).
-0. 11-04 sweep PUSHED ebd3692 (92 commits, 5 branches; full gate ~1.5 h); release
   rejected (TI pushed release meanwhile): re-parented the snapshot on origin/release
   (70ccdf7), raised make-release's stale-parent bug to TI (OA rev 332).
   11-03 sweep PUSHED ae1a316 (full gate, ~1 h 10 min; make-release fixed by TI a933e8d).
   11-02 sweep PUSHED cbe7bad (full gate PASS, cg 6088 s, ngd 4150 s), with
   OI's split and TI's heavy-unit fix 16ab8ae merged. Gates: run detached
   (setsid bg-run) AND a run_in_background waiter loop (2 h cap, re-arm);
   liveness via `ps -eo pid,etime,args | grep "[g]ate-push.sh --full"`.
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
