# OI handoff (OOE model and RTL)

Updated 2026-11-23, MOST CURRENT:
- ef0b49e2 PUSHED (full PASS, sweep 11-23). Then #76 (OA-475 mlc_miss split: .true_miss/.false_hit at the flagged head load's completion, control inject_mlc_split_all_miss) + #75 pc_kept (model rsa/first_pc/next_pc cleared at allocs, OA 470 drain check, bins drained.pc_kept_launch/_restore, control inject_pc_kept_lost; ooe_slot rsa_cq02h (4 ungated, slot now 7 ungated <8) + ret_cq01h in, drn_kept_cq02h out; slot_tb compares, control rsa-no-clear-restore caught 263) committed, gate-push RUNNING. On pass: OI row closing both (Re OA-475, OA-470) ring OA; tell TI pc_kept live for at:11 lines (TI-529). ooe_slot's ret_cq01h has no driver until the top (from ooe_rob_w retire).
- TI-537 (DA): one common credit RTL in rtl/common (TI: cr_src/cr_go/cr_dst); NO new per-block channel credit counters. OI-203 (rev 407, rang TI): OOE ends = ooe_sched MA-5 4-slot memop sender, ooe_decq FET count return; rencred none. HOLD #70's RTL pending counter and #65's decq credit-return wiring until (a)-(c) land, then build on them; migrate sched/decq after. Next OI id OI-204. TI bookmark 535. OA-477 (rev 477) agrees: migrate ooe_sched memop counters + decq FET returns once TI's cr_src/cr_dst land and are proved, keep cok's registered form, same bench cycles; the 4-flop cret_cq03h waiver moves to the common module; rencred stays. OA bookmark 477. TI-539 (rev 537) took OI-203 into TI-537 v2: 4 cr_src instances for memop (count_q flop read by the pick), cr_dst with a RET_MAX count return for decq; rencred stays. TI bookmark 537. OA-478 (rev 478): at migration (#77) report OOE block 2% headroom with ~20 ungated cr_src flops (4 slots x ~5) beside mempl waiver's 21; no fit -> TI SLOTS form with one shared gate, not a waiver. OA bookmark 478.
- OA-475 (rev 475, re AR-413): add false-demotion split to demote_trigger.mlc_miss now (#76): flag head RobEntry when trigger fires (ooe_core.cpp:3185); at MIU completion (:1908, atomic :2061) count .true_miss / .false_hit (hit completing past threshold); flushed first -> .unresolved. Answer Re OA-475 in OI tab. THRESHOLD_MLC re-sweep (35/50/75/100) is OI's later, after MA Phase 1 sizes in stub (AR 412 read+swap classes, S1); keep 50 unless >1% win at <=0.5% S1. OA tab bookmark 475, AR 418.
- 6ff62534 PUSHED (SCOPED PASS, cg 14218s normal); OI-202 closes OI-199 (OI rev 406). Sweep 11-23 merged 7 branches into oi-sw 4654da20 (TI 183cc441 incl ba085cda pc_kept, DI 5e4d6c70, MI 58815650 [ort spun 27 min on 2 merge bases: use -s resolve], spec 664pgr, 9eb50716, 80102643); --full gate-push of it RUNNING. Then #75 pc_kept on it, then #73 rob.sh rerun.
- Sweep 11-23 read: nothing in Needs for OI. Bookmarks OA 474, TI 529, AR 414, MI 38, RA 158, RI 91, MA 173, DI 69, IS 201, CP 160, DA 131, Conv 20 (MI tab c1311541-4219, DI tab 1ea5d5b3-6e9c). AR 408: pc_kept=1 iff no retire since tier-1 alloc (launch/restore-alloc) = !rsa; model CHECKs oracle arch PC == RAU resume PC every drain; bin drained pc_kept=1 split launch/restore. AR 410: slow mem regions end 1 MiB (timed numbers may move). 
- 11-23: gate 6ff62534 relaunched CCV_RESUME=1 (job-gate-push-20261123-065744-27170.log, wait bg). Lesson: a 'container restart' notice may kill only the wait; check the old job pid alive before relaunching (two gates overlapped 05:07-06:41, old one failed ooe_rtl, its cleanup wiped the new one's build/). CCV_RESUME reads build/verify only, so after that cleanup nothing carried: the 06:57 run is a full rerun.
- TI-529 (rev 527): ba085cda on ccr-183cc441-doowtf carries pc_kept on rau_drained (72 bits), bins pc_kept_launch/restore. MERGE it before setting pc_kept in the model (#75); TI then adds at:11 transp4/narrowadd lines + controls. No row needed.
- #74 GATE RED: check-cg CG-1 ooe_ratmap.sv:264 kv_cq05h (kw_w_cq05h in the reset block without an enable). Fix ready: scratchpad/kv5.py <tree> (kw_w_cq05h own block, enable kw5_en_cq04h=kv_cq04h). After the gate ends: apply in wt-sw, local check-cg on ooe_ratmap units + ratmap bench, commit, gate-push again.
- TI-526: pc_kept applied by TI (7beb7cab on gate-scratch/TI-export, schema + RAU stub). OI builds model on it; TI adds at:11 lines in one gate with our branch; TI asks for a pc_kept_restore kernel/cycle (none known yet).
- #75 pc_kept (OA 469 accepted; OI-201 rev 405 proposes ooe_slot home, Needs OA): model after the gate in a fresh worktree off oi-sw: clear next_pc validity at kAllocLaunch/kAllocRestoreAlloc, pc_kept = !rsa ALONE (OA 470: no retire => oldest uop is at RAU's PC; no dq/held inputs); model asserts resume_pc==RAU PC when !rsa; control pc-kept-lost; RTL in ooe_slot (default budgets) with a control breaking rsa's clear at restore; port field after TI's schema row. Next free OI-202.
- TI-523 answered in OI-200 (OI rev 404; next free OI-201), rung TI+OA. (1) drained resume_pc 0 before first fetch: OOE has no PC; proposed drained.pc_kept bit (alt: PC on alloc). On OA/TI's call: model field, clear next_pc at alloc (also stale across slot reuse), control pc-kept-lost. (2) narrowadd R2: not OOE; TI's checkParked should mask to the parked width.
- ratmap.log at 20:18 showed restore-first MISSED, but that predates dd296f15 (20:28); the gate covers it. robpwv.log (37 caught) predates 0e9c0703: rerun.
- #74: OA signed (OA 468). oi-ratmap merged into oi-sw (c4446c3f, lint 0); gate-push RUNNING (job-gate-push-20261122-204332-2011.log; gate-wait bg). On push: OI row closing OI-199 (FYI, no ring).
- #73 (DA 130 PWV) in /home/user/wt-pwv, branch oi-pwv2 (0e9c0703): merged oi-sw (slice 5 stays held there); PWV=0 = oi-sw's form; PWV=1 default, waiting redirects now a declared table ft_cq04h (rtl/ooe/ooe_redir.feedback.json, by OA, UNSIGNED). Bench before the table: both forms 0 mismatches, 37 controls caught (scratchpad rob.sh). Rerun bench after the gate.
  Left lint: PWV form's rdr_*_cq05h / ckf_m_cq05h ports leave from cq04h flops. Plan: measure check-ngd + check-cg (ooe_redir, ooe_rob_w _1.._3) one at a time; if clean (no waiver, no cap rise) drop PWV=0, rename ports cq04h, TI row (payload into valid's cycle) + OA row (sign table, rd_*_cq03h budgets), model redirect_send_lag=1 default; else figures to DA via OA (C stands). Bar controls wait for slice 5's return.

Updated 2026-11-22, earlier:
- PUSHED 0d54027a (sweep merge 11-22, full gate PASS, then RESUMED PASS push): dc2c3697 model defaults demote_walk=1/beat_merge=0 (OA 466; RH: S1 +0.072%, cm32priv +0.149%, cm128priv -0.038%), c69ee1a3 check-kernel provswap CCV_RAU_CONCURRENT=1 (TI confirmed, TI-520), all remote branches incl. TI 63579fce (CCV-L23 table form).
- OI-198 (rev 402) recorded the flip + re-pin. Next free OI-199. RH told rh-oi466 can go.
- Merge lesson: AR's sweep branch had 7 merge bases and ort hung >90 min; merged with git merge-tree --write-tree --merge-base=<best single base>, then commit-tree with both parents. A detached gate that outlives a container restart keeps the old git proxy port and cannot push: relaunch with CCV_RESUME=1 (carries every passed section).
- #74 BUILT on local branch oi-ratmap (dd296f15 on 61e3d035, the hold's revert), NOT pushed: OI-199 (rev 403) asks OA to sign the table entry; on OA's sign, merge oi-ratmap into oi-sw and gate-push. Lint clean, bench 0 mismatches, 5 controls caught (read-at-write new; restore-first revived via testRestoreBesideDemote), CG 35 ungated of 2438 (1.4%), NGD 13.6. Next free OI-200.
- WAS: #74 OA 467/DA 131: rtl/ooe/ooe_ratmap.feedback.json table entry (by OA), no-same-cycle assertion + failing control, landing row for OA to sign, then drop the sweep hold on ooe_ratmap (16d7393a). Then #73 (DA 130 PWV), #71 (OA 465 decq walk), #72 deferred.
- Bookmarks 11-22: OA 469, AR 409, MI 35, TI 518, RA 157, RI 91, MA 157, DI 41, IS 201, CP 160, DA 131, Conventions 20.

Updated 2026-11-21 (5), earlier:
- 8d8577b5 PUSHED (sweep merges, full gate PASS). Bookmarks now TI 513, DI 32 (others as below). Next free OI-197.
- a5d5cb83 on wt-sw (ccr-57eff422-5tdecg): ooe_decrx straggler keep (#71): wo_cq01h in, per-slot walk bit wq + epoch wep, wo_o out for ooe_decq; model RxLog::wopen + walkOpen/walkEpoch; decrx_tb at model default straggler_walk (rxConfig dropped), walk-held=109 at 25 seeds, 0 mismatches, 8 controls caught (new no-walk). NGD wo_cq01h 10.0, CG clean. PUSHED (SCOPED PASS).
- OI-197 (rev 401) raised to OA, rung: decq hold needs the demote_walk=1 walk port (OA 451); proposal per-entry held + beat-pending bits; ANSWERED by OA-465 (OA rev 467): RTL targets demote_walk=1 (benches/kernels with OOE RTL run at it; model default stays 0 until RH prices the flip, <=0.5% S1 OA flips, else DA). decq per-entry held + beat-pending accepted (group free rejected): held on flush of a wo_o slot; one oldest-first walk port on rob_w's flopped request; beat-pending set at read, cleared by beat-sent pulse (tag = entry index); free at read + beat left + decq_credit_delay, credit with free; stragglers enter held. Bits in each entry's gated row, enables from decq flops (CG-5); beat-sent capture outside rules -> credit waiver to DA. Controls: (a) free before beat leaves, (b) held entry issued, (c) no-hold (flush drops held). decq bench vs model at demote_walk=1, 0 mismatches. Build rob_w demotion-walk beats (OA 435 (6)) with it; report NGD/CG in landing row. MI-12 can proceed. Next free OI-198.
- OA-466 (OA rev 468): flip to beat_merge=0 + demote_walk=1 accepted (RH model S1 +0.066%, cm32 +0.147%), effective once cm128priv runs clean with the walk and RH prices B vs A at that commit: <=0.5% OI flips the default itself, no new row; >0.5% to OA then DA. Sent RH the job at a5d5cb83 (S1/cm32priv/cm128priv, mlc, B=CCV_OOE_CONFIG beat_merge=0,demote_walk=1). If cm128priv B fails: that is the OI-188 follow-on to fix first.
- ec2ed823 (local, unpushed): decrx control no-double-adv (caught). Rides the next gate-push.
- NEXT #71 (after OA answers OI-197): ooe_decq holds a walk-open slot's uops on the demotion flush (reads wo_o), frees after beat + credit delay; beats from rob_w demotion walk (OA 435 item 6); ooe_slot drives wo; OI row on scope (MI-12 waits). Then decrx control mask adv when adn; RH pricing; OA 435 items.

Updated 2026-11-21 (4), MOST CURRENT, read first:
- 893f2eed PUSHED (full gate PASS): OA 462 kill exemption (decq_killed_late), decrx bench at straggler_walk=0 until #71 RTL. OI-196 (rev 400) answered AR-402 + DI-15 (re-sweep 893f2eed), both rung (DI session_01QPk2jz5TVESyWMKVKjqqEA, not in roster).
- 969b3267 full gate PASSED but push failed (proxy down after container restart). Re-merged 10 more branches (incl. TI 655286d1, TI-514) -> d516e866, --full gate-push again.
- Daily sweep 11-21 merge on oi-sw 80944e42: TI doowtf 32, MI 0ch1hh 4, DI n6402z 14 (criss-cross: merge-tree with one base; 4 non-OI files took theirs), AR 4n8bv4 4, MA miu-dcu-spec 9. --full gate-push on it (see job log in ~/ccv-logs, newest gate-push).
- Pongs: OA and RI never answered Friday's pings (reported 11-21). Settings check matches. Bookmarks: OA 466, AR 406, MI 29, TI 511, RA 157, RI 91, MA 145, DI 30, IS 201, CP 160, DA 128, Conventions 20. Next free OI-197.
- NEXT: #71 RTL (ooe_decrx/ooe_decq keep a demoted warp's stragglers for the walk; then drop rxConfig in test/ooe/decrx_tb.cpp); MI-12 waits on it. Then decrx control (mask adv_cq01h when adn_cq01h), RH pricing, OA 435 items.

Updated 2026-11-21 (3), MOST CURRENT, read first:
- Full gate on 0fc3dc5a was RED (nothing pushed): (1) split links, rokilllane: OA 462 CHECK fired on a killed warp's uop landing after the kill released its slot -> adapter exempts warp_ids a kill named until relaunched (bin decq_killed_late); all split kernels clean both configs. (2) decrx == model: TI-landed straggler walk (74089cbb) is not in ooe_decrx RTL -> decrx_tb runs model with straggler_walk=0 (25 seeds 0 mismatches, 7 controls caught). Fix commit 763138e3 on oi-sw; handoff commits merged. Re-gate --full next.
- OPEN (#71 RTL): ooe_decrx/ooe_decq must keep a demoted warp's stragglers for the walk (AR 395/OA 457), then drop rxConfig from test/ooe/decrx_tb.cpp.

Updated 2026-11-21 (2), MOST CURRENT, read first:
- GATE IN FLIGHT: wt-sw (oi-sw) 0fc3dc5a --full gate-push, job log /root/ccv-logs/job-gate-push-20261121-015307-29710.log (gate-wait exit 3 rerun; exit 4 relaunch with CCV_RESUME=1). Holds the sweep merge of every remote branch + oi-71 (#71 epoch fix, OA 462, OA 463 knob 1e212fd8) + handoff. Don't edit wt-sw while it runs.
- OA 463 (option b) DONE in model: decq_credit_lag knob, CHECK on slot's next warp with held credits, FET bin mig_credit_wait. lnorm1 mlc lag 512 --cycles 200000 passes (wait 1381), break mig-before-credits = 2 CHECKs; caught from 448, wait binds from 8. OI-195 (rev 399) written, OA + TI rung. TI to add the check-kernel pair.
- Merge workaround (4 criss-cross bases): git merge-tree --write-tree --merge-base=<one base> HEAD <theirs>; merge -s ours --no-commit; read-tree -u --reset <tree>; per conflict: HEAD==base -> theirs, theirs==base -> ours, else by hand.
- NEXT after green: price S1/cm32priv/cm128priv via RH (#71); ooe_decrx bench control (mask adv_cq01h when adn_cq01h; epoch compare must fail) in check-ooe-unit; OA 435 items 6 (+ rob_w rd_e demote/kill assertion), 5b+7, 8, 9, 10 (0ff0b4fd on oi-5b), then ccv_ooe top glue. Next free OI-196. Bookmarks: OA 465, AR 403, MI 18, TI 503. MI session_01QPk2jzH1Gd3DcxK4F4pwCC (not in roster).

Updated 2026-11-20 (5), MOST CURRENT, read first:
- GATE IN FLIGHT: wt-sw f45e1314 scoped gate-push (job log /root/ccv-logs/job-gate-push-20261120-195053-27168.log; gate-wait exit 3 rerun, exit 4 relaunch CCV_RESUME=1). The --full gate on ee4dc573 failed only CG-1 ooe_decrx enq_v_cq02h (rst_r01h+ev_q+enq_v = 8 > 7); f45e1314 adds the DA-approved CG-1 lead waiver (enq_v, 6 flops). ee4dc573 = rcupl/mempl/redir/rob_w CG+NGD fixes, ooe_rsread unit, redir CG-5 lead waiver on ee_cq04h. OI-192 (rev 396) answered MI-12: #71 is first after the gate.
- After green: sweep merge (fetch; TI e8d8864b on ccr-183cc441-doowtf carries my model commits + CCV_LAT_DECQ_CREDIT_DELAY; handoff commit 22bd09fa in custom-cuda-core), --full gate-push.
- #71 (OA 460/461, AR 397/399 ruling, supersedes OA 459/AR 398; TI-502, MI-11): wt-71 branch oi-71 from e8d8864b, commit ded01919 UNTESTED: released slot stays bound to its warp (Slot.bound, boundOf, creditSlotOf, creditWarpOfSlot) until launch/restore reassigns; stragglers walked there, credits on that slot; cred_pend_ gone; uop bound to no slot = k_.fail CHECK; slot leaving warp with credits out = CHECK; bin decq_bound_uop replaces decq_slotless_drop/decq_credit_pend (kernel.h, TI's); break unbind-at-release replaces slotless-drop-lost (main.cpp, TI's); kernel.cpp reseed comment (TI's). Next: build skel, run `CCV_MIU_IMPL=model CCV_RAU_DEMOTE=mlc build/skel/ccv-skel --kernel build/oracle/lnorm1/oracle.jsonl` (must finish clean, parked=5), same with --break unbind-at-release (must hang/fail), no-straggler-walk still caught, ooe unit tests, check-kernel incl. kill/exit (CHECK never fires; report bin counts to OA), price S1/cm32priv/cm128priv on RH. check-kernel.sh (TI's) still names slotless-drop-lost? (grep showed none). Then OI row answering OA 460 + MI-11 + TI-502, ring OA, AR, MI, TI (TI: kernel.h/main.cpp/kernel.cpp lines). Bookmarks: OA 463, AR 403, MI 18, TI 503.

Updated 2026-11-20 (3): oi-sw (wt-sw) local commits: f19c3844 (RS read into rcupl/mempl), b2a90773 (cg trace width), 03bb7a85 (decq: count base registered, take subtracted after the edge from kept tkc; deq_t 24.9, flop-flop 24.1, cnt out 10.2; NGD clean; OI-65 waiver text 14->17 flops), c192bdd2 (#70 OA 455 A: OOE per-warp cred_pend_, FET restore reseed removed [TI's line, tell TI in OI-189], bins decq_slotless_drop/decq_credit_pend in kernel.h [TI's], control slotless-drop-lost; 64 kernels pass under mlc, bins 0 locally; sent to RH on gate-scratch/OI for cm128priv walk on/off + control). Next #69: rob_w NGD-1/3 regressions (measuring, scratchpad ngd-robw.log), rerun pl bench, then --full gate-push. Then OI-189 row (OA 455 answer + RH trace), RTL pending counter beside ooe_decrx, check-kernel bin+control (needs a kernel that reaches it; TI owns tools/).

Updated 2026-11-20 (4): #69 in wt-sw: slice-5 hold revert STAGED, uncommitted (rob_w/barpick/ooe_core etc. back to before c4bfdbec; rob_tb.cpp at c4bfdbec^); run-rtl all benches running (scratchpad runrtl.log, task b53mhlxs9). Then: commit it, remeasure check-ngd --unit ooe_rob_w (lower/remove caps that pass), --full gate-push. #70: straggler walk DONE in model on oi-5b (wt-5b): fd32a5be (= c192bdd2 cherry-pick), 33b2971c (stragglers held to beat send + decq_credit_delay; delay derived in ooe_block from links until TI's CCV_LAT_DECQ_CREDIT_DELAY lands on origin; breaks no-straggler-walk / straggler-early-credit / slotless-drop-lost registered in sim/skel/main.cpp [TI's]; bins decq_straggler(_beat) in kernel.h [TI's]; check-ooe-unit 64 controls). Kernel pair: lnorm1 CCV_RAU_DEMOTE=at:328 PASS, --break no-straggler-walk finished=0 gpr_mismatch=288. OI-189 written (rev 393), rung TI/OA/AR. Landing: cherry-pick b7b3ce5d 367bc942 5e9d1306(model part) 33b2971c onto oi-sw AFTER the #69 gate (oi-5b also holds slice 5, never merge it whole), then gate with TI's ti-mi9 FET wait (TI to push it). Next RTL: pending-drop counter in credit-return formatter + straggler hold in ooe_decq.

Updated 2026-11-20 (5): #69: slice-5 hold committed b9869cf1, run-rtl clean, ooe_rob_w remeasured (NGD-1 28.5, fl_m 28.8, al_n 26.4, dn_tag 25.0 raw ~25.0x): al_n cap 26.6->26.5 committed 6b5789f0. --full gate-push on 6b5789f0 running from wt-sw: job log /root/ccv-logs/job-gate-push-20261120-071116-165.log (verify-6b5789f0-20261120-0711.log); relaunched once after a container restart; re-arm tools/gate-wait.sh on it. After it: today's sweep merge (fetch, merge every remote branch ahead incl. TI cb8ca9be MI-1/DI-1 hooks) + --full gate. #70: 05ee3bdb = oi-mi9 (wt-5b) = 33b2971c + TI ti-mi9 29267873, on gate-scratch/OI (OI-190). RH Bm on 33b2971c: 1 AR 395 CHECK (expected without FET wait); Ck/Dn on cm128priv cannot fail (bins 0). RH Bm on 05ee3bdb (demote_walk=1) did not exit in 49 min, stopped: suspect FET full-credit wait (warps_[w].credits < kDecqWarpMax, ti-mi9) vs ooe_block cred_pend_ (returned only at the warp's next slot). NEXT after the gate: reproduce on a small kernel (lnorm1 at:328, demote_walk=1) in wt-5b, fix, send RH the commit + runs (Bm, Cw = demote_walk=1 --break slotless-drop-lost). OI-191: TI gates ti-mi9b default config only, no demote_walk=1 kernel until the fix (TI-499: tell TI which pair to pin). TI-498: my scratch RTL failed ooe_ratmap pk_q CCV-L29 + decrx lock-step 2 drops (oi-5b, mine to fix). RH holds rh-oi455c/455/451. Next free OI-192. Pings sent Fri 11-20 to AR OA IS TI CP RA RI MA RH; pongs ok from AR CP TI IS RA MA RH; OA, RI pending (check Saturday).

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
  Next free ID: OI-189 (OI-188 rev 392: #70 root cause, FET restore reseed vs in-flight pre-demote uops; options A/B to OA+TI, rung both; RH keeps rh-oi451 till fix. OI-187 ratmap table rule. Before: OI-185 OI-185 rev 389: lag-2 C S1 +1.42% vs lag-1 D +0.72%, both to DA; D built on branch oi-pwv 82b0fdd7 (PWV param; ports would rename cq04h + TI lead-field change if adopted); OA 449 explained; rung OA; RH told release rh-oi449, keep 447/447a till DA). Pings Fridays.
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
OI 395, OA 460, TI 498, AR 400, DA 128, MA 135, RA 157, RI 91, IS 201, CP 160, MI 16, DI 12, Conventions 20 (11-20 sweep; DA/CP/IS/RA/MI/DI read only by rev).

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
