# OI handoff (OOE model and RTL)

Updated 2026-11-19 late: OA-450 wants D measured (NGD/CG, no waiver); D tree wt-pwv (oi-pwv2). Gate bc4wkcjom in wt-sw expected red; oi-slot 6583cdbf carries the fixes.

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
  Next free ID: OI-186 (OI-185 rev 389: lag-2 C S1 +1.42% vs lag-1 D +0.72%, both to DA; D built on branch oi-pwv 82b0fdd7 (PWV param; ports would rename cq04h + TI lead-field change if adopted); OA 449 explained; rung OA; RH told release rh-oi449, keep 447/447a till DA). Pings Fridays.
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
OI 389, OA 452, TI 487, AR 395, DA 128, MA 127, RA 156, RI 91, IS 199, CP 160 (TI-482 rung separately: answer in #58's landing row).

## Trees and runs in flight
- #61 DONE: pushed b91632b4 to ccr-57eff422-5tdecg (SCOPED PASS), OI-175 rung OA+TI.
  wt-61p (oi-61p) can go once #58's branch is rebuilt from origin.
- #58 lead form: /home/user/wt-58l branch oi-rxl, 942fa18e on oi-rx (the flop-form commits,
  withdrawn by DA rev 127 / OA 433). Rebuild the push branch from origin (now b91632b4) without the flop form.

## Open work (most urgent first)
0. NEXT: gate bc4wkcjom (wt-sw d4c49c15) expected red (decrx lint; and any oi-slot rob build bug). Then merge oi-slot (6583cdbf: lint fixes, bp_hl cast fix f3e47cf1, g_bp locals f-prefix, ooe_test bar_pend + check-ooe-unit 61 controls c0cf82ab) into the sweep in wt-sw, regen, relaunch --full gate-push. OA-450 (OA rev 452): OA recommends D to DA if ooe_rob_w and ooe_redir pass check-ngd/check-cg with no waiver and no cap rise; else back to DA, C stands. D measurement tree: /home/user/wt-pwv branch oi-pwv2 (oi-pwv + oi-slot, PWV=1 by default; rob_tb mispredict 1135 redirects 0 mismatches, all controls caught). After the gate: check-ngd/check-cg --unit ooe_rob_w (_1.._3) and ooe_redir in wt-pwv, one at a time; propose rd_*_cq03h budgets to OA with figures; answer OA-450 in a new OI row. bar-* controls on bar_pend: RTL rob_tb runs bar_pend=1 (all 4 caught, C and D); model testBarrier now runs both forms. run-rtl b53nfm6ap failed only at rob build (the g1'(p) bug, since fixed): rerun run-rtl on oi-slot after the gate. TI-488: drop ooe_wake LAT pins once oi-slot lands.
   TI-488: when oi-slot lands (3ab00269 package defaults), drop the two ooe_wake LAT_SPEC 14/LAT_MISS 17 lines TI pinned in test/ooe/cg-units.json. RH: keep rh-oi447/447a until DA rules on OI-182; others released. Slice 5 gap: the random rob bench never squashes a barrier (bars_sq=0, a95 counter in rob_tb), so ooe_rob_w's bsq path is unexercised: add a directed kill behind a waiting guarded barrier. Owe RH a look at layernorm -6.1%/sgemm -1.2% under bar_pend (report reorder?).
1. TI-485 model bin + control DONE (ef015dab; Env::kill frees FET's ckpts at the kill's notice).
   Left: ooe_redir (#65) masks ckf for a slot from its epoch_only notice, with a bench control.
   OA 444 (DA 128): ooe_wake/ooe_trio LAT_SPEC/LAT_MISS default from ccv_prov_pkg (3ab00269;
   NB those params live in ccv_prov_pkg, not ccv_params_pkg - that was the "Yosys" failure).
   Wake bench, trio, check-cg/ngd ooe_wake+ooe_sched clean, values unchanged 13/16. Left: units at
   both predictor settings once TI lands the predictor param; answer OA 444 in OI-177.
2. #58 (DA rev 127 chose the lead form; AR 380 approved lead_fields [warp_id, fetch_epoch];
   OA 433/434): on oi-rxl (rebased off the flop form): model rx_lag bit 64 withdrawn (default 16);
   decrx.ngd.json lead-field inputs arrival 2 (as enq_l), held to 12 NGD (AR 380 (4)) - measure;
   rtl/cg-waivers.json CG-5 "lead": true waiver of enq_slot (12 flops; RI-15 ruling + OA 434);
   landing row confirms OOE's waived+allowance flops per instance stay within OOE's 2% (else to OA
   first). Push only after TI's lead_fields schema change lands (merge it: 3eb6e8d0 is on
   ccr-183cc441-doowtf). RH OA 428 E (rx_lag=80) vs A0: S1 +0.946%, cm32priv +3.575%,
   cm128priv +1.118%, stall.decq 0: cite in the landing row.
3. #63 ooe_slot DONE locally (fd194677, oi-slot; bench 25 seeds 0 mismatch, 7 controls; CG pass; NGD f2f 19.2).
   OA 443 set budgets (arrival 2, by OA): ngd.json committed 8501f587, check-ngd passes. OA's dm_* caveat
   (ooe_rob_w flop-out 2.0) is moot: dm_* comes from ccv_rau_ooe_demote's boundary flops; say so in the row.
   OA 443 (2): model slot_verdict_lag (default 1) + testSlotVerdictLag/control 14526054, sent to RH on
   gate-scratch/OI (A lag 0 vs B default; S1/cm32priv/cm128priv). On the price: write the OI row re:OA 443
   (<=0.5% S1: OA absorbs; else the no-cycle option's cone depth/CG). Push waits on that and #58's gate. Rebase/merge oi-slot onto origin after #58 lands.
   #64 ooe_rcupl/ooe_mempl DONE locally (c0584545, 8937a239, c56f9ddb on oi-slot): bench test/ooe/pl_tb.cpp
   (scenario pl, 25 seeds 0 mismatches, 6 controls), cg units added, NGD within 12. OI-178 (rev 382) rung OA:
   mempl's 21-flop valid/source gate 97%/67% (medium/high), over its allowance: (a) DA waiver or (b) slot-indexed
   late read; check-cg fails mempl until answered. Left for #64: integrate with ooe_rs/trio (export reads, rs_idx,
   mem fields, mgl_cq01h from ooe_sched; remove the issue regs; folds #40/#42/#46); run-rtl.sh entry with controls.
   OA 445: verdict lag absorbed, push oi-slot when ready; optional non-gating RH run (cm128priv, CCV_RAU_DEMOTE
   forcing a few hundred demotes, slot_verdict_lag 0 vs 1). OA 446: OA declines (b), recommends (a) to DA (mempl waiver).
   #65 (4) decq credit return DONE locally (6fc15bec on oi-slot): ooe_decq output crd_cq02h[S*LC], per-slot frees
   registered beside frn; decq_tb checks per slot, control stale-credit-apart. check-cg/ngd for ooe_decq not yet run
   (gate was busy). Next: #65 (5a) ooe_redir: b0117b45 (decrx sw_o/sn_o outputs, bench 25 seeds + 7 controls pass; model same-cycle redirects in slot order, ooe tests pass) and ooe_redir b0de1716: rob_w outputs rd_e_cq02h (rs_en) / ckf_l_cq02h (|frp); ooe_redir sits in ooe_rob_tb (u_redir) and rob_tb checks it vs core.out at +2 (25 seeds, 1206 redirects, 0 mismatches; controls redir-warp/epoch/ntm, rd-unled, ckf-unled); cg unit ooe_redir (scope u_redir). OA 447 (re:OI-179) ruled: rd_l plain wire to decrx adv/decq flush/RAT squash; rd_e is decrx's lead (decrx ev_l now [S:0] per source, 8948873d, bench 25 seeds + 7 controls); landing row (OI-180) must state OA 428's invariant (one wire, one cycle, three receivers) + joint-bench assertion plan, slot-order IPC, send+2 price (<=0.5% S1 absorbed, else cost of payload-with-valid to OA), decq check-cg/ngd, budgets proposed for rd_e (~6 NGD)/rd_l. Model knob redirect_send_lag + control inject_send_free_late (582fedae14). RH asked: A 99ee28168b, B 582fedae14, C 582fedae14 with CCV_OOE_CONFIG=redirect_send_lag=2 on S1/cm32priv/cm128priv - awaiting. Left: check-cg/check-ngd ooe_redir + ooe_rob_w + ooe_decrx + ooe_decq (after the gate; re_q/fl_q are 8 ungated flops - watch CG), landing row with budgets (re OI-179, which OA may still change).
   Lint in wt-slot shows 7 CCV-L23 in ooe_decrx/ooe_slot (lint passed on wt-sw's gate): recheck on oi-slot's gate.
   OA 435 module split (re:OI-171), in order: (1) ooe_slot #63, (2)(3) ooe_rcupl/ooe_mempl #64,
   (4) decq credit return + (5a) ooe_redir #65, (6) rob_w slice 5 syu_bar, (5b+7) epoch notices +
   slice 6, (8) rcu_map in ooe_rat, (9) rau_status, (10) cru_fault #66; then ccv_ooe top glue (no
   logic in ccv_ooe). Each lands with a bench vs model, a timing unit, controls, and a row
   proposing port budgets with measured NGD.
3a. #66 slice 5 (OA 448 ruled: barrier state in ooe_rob_w per slot; go takes the hold as its own input, ORed inside;
   report pick (A) retire stop if caps hold else (B); depth 2 unless RH >0.5% vs unbounded -> 3; model counts as RTL).
   DECIDED (B): (A) is structurally impossible: rob_w is one instance per slot, so a cross-slot pick in the window
   would be a path through the parent. Model knob bar_pend (42e8ee74, 31bf4b1e + pv0 stop as the RTL): one pending
   report per slot, a rotating pick a cycle; retire stops at a bar op while the register was full as the cycle
   started (grant is an input to rob_w, so it frees the cycle after) or at a 2nd in a window; pending counts as
   held for drain/exit/kill and holds its side-buffer place. RH asked P0/P1(bar_pend=1)/P2(+bar_buf_depth=2) at 31bf4b1e.
   RTL plan: rob_w side buffer 2 places {v, rt(pending), idx LD, kind 2, bid 4, guarded, bhs(set the hold), long,
   gm 32, guard 32 (dn BS mask), phase 32 (dn aux)}; new alloc inputs al_bar/al_bk/al_bid/al_bgd/al_bhs/al_bl [A];
   hold state bar_hold/bar_retired/bar_long/bar_mask; held = bhs && hold && !retired; release input (syu_rel warp
   matched upstream -> per-slot rel pulse); outputs: req (rt flop) + place0 fields from flops; per-slot hold out to
   ooe_go. New module ooe_barpick: rotating pick over req & ~gnt_q, flops gnt_q (to rob_w as data: rt_en=rt, rt<=~gnt)
   and the ccv_ooe_syu_bar report. rob_tb drives from RobLog (add bar fields to Alloc, report list), compares reports.
3b. (older) #66 (6) slice 5 syu_bar: model knob bar_buf_depth (71feef7e, testBarBufDepth; on gate-scratch/OI); RH asked D0/D2/D3 on
   transpose-128, layernorm-128, cta-reduce-128, sgemm-128 + S1 (>0.5% on any -> depth 3). OI-180 asks OA: hold state
   in rob_w?, report pick as retire stop vs pending register, depth, rename hold timing. RTL waits on OA.
   #64 step 1 (local, uncommitted until trio passes): ooe_rs drops its issue registers, exports lv_cq02h/le_cq02h (LW)/
   pe_cq03h (PW) for rcupl/mempl; ooe_trio.sv keeps bench-side copies of the old registers. Plan: rs store = ooe_ent_t
   split lead (le) / rest (pe) with no duplication, + ooe_mem_t in pe, + RS index output for mempl; wiring at the top.
4. #52/#53/#54/#51 NGD-to-25 refactors: PAUSED (DA 11-18) until the top exists.
5. Blocked/parked: #40, #42 (TI schema), #46 (lead set), #32 (optional fa index).
