DA 2026-11-04 (in session): ENFORCE NGD with the fanout term; today's over-25 paths on a ratchet;
cleanup TOP PRIORITY (ahead of ROB slices 3-6): uArch changes get more invasive later.
Recorded OI rev 265; TI (build enforcement + ratchet, seed from pushed tip after 5e81e19 gate)
and OA (order uArch changes by later invasiveness) notified. OI order: go + sched back in, rob_w
fill selects, rename copies, freelist copies + scan pricing, rs/decq candidates priced.
-> put this in .claude/handoff/OI.md item -6 once the gate on 5e81e19 ends.
OA rev 321 ORDER (read 11-04 00:35; bookmark OA 321): 1 model batch NOW: freelist scan (a) cands a cycle
ahead vs (b) 4 banks x48 rotation; rs + decq free candidates a cycle ahead, alone + together; S1, audit,
floors, scarce-names; <0.5% total OA's, else DA. 2 rendep cp sender probe (decode registered at
sender, keep copies by row group; no fit -> rename stage to DA before slices 3-6). 3 rob_w fill probe
(input stage on fl_v/fl_slot? price -> OA first). 4 go remainder report after 1 (+sender-drive table
hv/pl/px/unmet). Parallel: go priod decode + sched (a)+(b) (held on oi-go-sched; fix go 25.8 + sched MiB).
5 copies last (rename out, rst, freelist in2_en/as, decq tk).
11-04 batch DONE on audit (OI rev 266 -> OA notified): freelist (a) 0.00% taken, rs 0.00% taken,
decq +2.1-4.2% -> OI proposes decq tk copies first, DA only if no fit. Knobs on local branch
oi-price-knobs ff3e97f (worktree scratchpad/wtm) -- merge + push with next gate. S1 kernels still to run.
OI rev 267 -> TI: no-rep-lead at base 1 is seed count; 12 seeds fix in 83c2900 (oi-go-sched).
Bookmarks: OI 267.
decq rev 268 sent to OA (lag@14 +0.6%, @15 faster; (ii) out). Bookmarks OI 268, OA 322.
S1 done rev 269 (AR 0/57; A15 -0.03%, B14 +0.06% vadd4 +13%). decq -> DA via OA rev 323 (OA recommends 15+lag). OI bookmark 269, OA 323.
rev 270 CORRECTION: rs lag +1.1-1.6% (renCredits now lagged in wtm, uncommitted). rs build PAUSED for OA. freelist (a) building. OI bookmark 270.
- TI-51 (TI rev 346, DA 11-06): compaction 350k; after merging TI's next push, ask DA to approve re-running session-home. Block NGD/CG limits now sum of module runs (no whole-block synthesis). No answer needed. Bookmark TI 346.
- RH cmpl_split cm128 vs A6 17058622: C1 -0.45%, C2 -0.12% (17037886), C4 +0.25% (17101093); C7, F, then cm32, then job 2b (C8/C9) pending.
- RH job 2 done (cm128/cm32 vs A6 17058622/4586048): C1 -0.45/-0.08, C2 -0.12/+0.23, C4 +0.25/+0.67, C7=F +0.14/+0.82. All clean.
- RH job 2b S1: C8 +0.000% (=A6 every kernel), C9 +0.444% (=C1). Audits: C8 = A6 base at 4 pts, C9 = C1. C8/C9 CoreMark running (~1.6h from 06:10Z).
  -> When C9 CoreMark lands: write DA package row per OA 361 (first kind C9 + HINT 2/FILL_NOTICE 4 vs flopped H3+P ~+1.95% S1; R49 S1 +0.276%), Needs OA/AR/DA, notify OA+AR.
- 11-06 07:45: OI-115 (DA package, re:OA 361) written, OI tab rev 306; notices sent to OA and AR. Bookmark OI 306.
- Slice 4 (faults) scope: entry fault cause+valid (fill dispatch faults, DEC cause), MIU cmpl fault (cause, lanes, 64-bit addr) -> per-warp fault-address register (V-74, oldest), head stop, outputs ccv_ooe_rau_status.fault_taken + ccv_ooe_cru_fault (cause, pc, lane_mask, address, cta_slot, warp_id). Needs cm port fields + pc source; check OA's entry layout (rev 277 (c)/279) first.
- 11-06 07:50: OA rev 363 rules C9 (re:OI-115): build first-kind cmpl+hint with sched/rs bypasses, HINT 2/FILL 4; flopped not taken; R49 dropped, ooe_rs 45 rows. Task #23. Bookmark OA 363.
- 11-06 07:50: TI rev 347 re:OI-18: 1a9a3e8 pushed (full PASS): OI RTL defaults at bases, five re-seeded fanout caps, cg lead/credit waivers, 350k window. Merge TI after slice-3 gate (before OI-114 renvar compare: caps may move); then session-home --check and ask DA approval (TI-51). Bookmark TI 347.
- 11-06 07:55: TI rev 348 re:OI-115: C9 recorded in links.json (branch ti-bnd 8a25c7a): at OOE's RTL top only miu_ooe_cmpl+hint stay no_flop, rest take the boundary flop. Merge ti-bnd with TI's branch before C9 work. Bookmark TI 348.
- 11-06 09:15: TI rev 349 re:TI-51: 0ce9c12 (full PASS) sum-of-parts block CG/NGD, no block synthesis. Merge with TI's branch. Bookmark TI 349.
- 11-06 09:16: OA rev 364 (re:TI 349): C9 cmpl/hint no-flop ends: each port 0 NGD, <=4 flop pins (cm_l etc. now fanout 1.9); units for every OOE module at each instantiated param set. Task #23. Bookmark OA 364.
- 11-06 10:10: OA rev 365 (re:RA 83): measure ooe_sched phys_src0/1 output depth at aa9ad9c (t+2 payload reg, (A), fanout) and promise budget; <=6 lets zero-cycle ooe_rcu_issue fit RCU R0/R1 read. Task #24. Bookmark OA 365. Pong sent to AR 11-06.
- 11-06 10:20 SWEEP: bookmarks Conventions 17, AR 308, RA 89, IS 190, TI 349, OA 366, OI 306, CP 155, DA 112, RI 21. DA 109/110 lead-signal and credit-pulse CG waivers charged to block 2%; DA 111 350k window (re-run session-home after merge, DA approval needed); DA 111b sum-of-parts: every module needs a unit per instantiated param set, port budgets neighbours can meet. OA 366: sched phys_src measurement low priority. Pongs 11-06: OA TI AR CP IS RI RH ok; RA pending. Pings sent to all 8.
- 11-06 11:50: TI rev 350 re:RI-16: bnd_rx (#79) pushed 17720a0 (full PASS), defaults unchanged, +2 RT finding for flopped rx end before DPI block; OI/RI files edited under OI-18. Merge with sweep merges after slice 3. AR 301/OA 355: reprice D,N,Z1-Z3 + OI package as links.json no_flop edits now that TI's term landed. Bookmark TI 350.
- 11-06 12:48: RA rev 91 (DA): zero-cycle receiving ends only for IPC; lane_rcu_res stays flopped (LANE 8/SFU 13) until measured; price C9 at 8/13 too (task #25). Bookmark RA 91.
- 11-06 12:49: OA rev 367 (re:RA 91): C9 zero-cycle ends are DA's to approve; OA 363 now a recommendation. Price C9 AND flopped at LANE 8/SFU 13 (S1, CoreMark). BUILD NOTHING for C9 until DA rules (task #23 on hold). Bookmark OA 367.
- 11-06 14:45: DA 114: C9 APPROVED (build capture; TI does links no_flop). Bar: zero-cycle rx end gain <=0.2% S1 stays flopped (architects), 0.2-0.5% to DA, >0.5% owner approves; can't meet 12 NGD without rx flop -> DA. C9 lapses to DA if the 8/13 rerun gain <=0.5%. Bookmarks DA 114, AR 312.
- 11-06 14:43: TI rev 354 re:OI-115: C9 recorded; OOE's own no_flop entry for cmpl/hint lands with ccv_ooe's RTL top (as a DPI host, OOE stays on the all-no_flop list; leaving it would flop every other end; sending-end no_flop refused, AR 309). So the 8/13 pricing in the DPI hosts: model knobs (rx flop via model), not links edits, until the RTL top exists. Bookmarks TI 354, OA 368.
- 11-06 15:15: RH C9 job SENT (files on gate-scratch/OI 7718260: c9job/README.txt, c9-run.sh, c9knobs.patch) + addendum: S1-only C9h (rx_lag=23,cs=9: hint late), C9s (rx_lag=7,cs=3: no rs bypass), C9n (rx_lag=23,cs=7: no bypass). On return: OI row to DA/OA/AR with F-C9, F-C9r, and the bypass split.
- C9 BUILD FINDING (wc9 = branch oi-c9 on fb52948, knobs patch + wake/rs probe applied, trio_tb takes TRIO_CS; scratchpad/c9/trio-build.sh <tree> builds trio): the probe (fin bypass + rs cfb) diverges from model cs=9 at ~120 cycles (V-65 issued). Model C9 assumes RS parts + hint act zero-cycle; with raw capture every hit/hint effect lags a cycle: miss check (hit lands at exactly LAT_MISS: mchk&&spec), msd, fin, the lead lines (flm needs the hint by LAT_MISS-LEAD: zero slack), ooe_confirm inside wake, rs's cmn confirm lead (rs takes cmpl_idx at its cq00h too). So exact C9 needs bypasses on fin, miss, msd, wake lines, wake's confirm and rs's cmn; or the model's C9 adds lag bits (priced by C9h/C9s/C9n). Tell OA/DA with the RH numbers.

## RH C9 S1 (20:06Z 11-06), LANE 8/SFU 13, 464 runs ok. geomean cycles (higher worse)
A6 309.88; C9=C9r=C9h 311.03 (+0.370% vs A6); C9s 312.77 (+0.931%); C9n 313.89 (+1.293%);
H3 310.85 (+0.311%); F 314.78 (+1.581%). F-C9r = 1.211% (> DA 114's 0.5% bar: C9 stands).
Hint late (C9h) costs 0 on S1: no hint bypass needed. RS bypass worth 0.56%; all bypasses 0.92%.
CoreMark 128/32 for A6, C9, C9r, F due ~23:40Z. Then OI row to DA/OA/AR.
- RA 95 (re:RI-16): lane_rcu_res zero-cycle, LANE 7/SFU 12 once TI applies; C9 baseline (7/12: C9 +0.444%, F ~+1.95%) holds. AR says whether 8/13 rerun owed. Fold into the C9 row.
- AR 313: 8/13 rerun not owed; C9 returns to DA only if a 7/12 run shows <=0.5%. Told RH to stop the 8/13 CoreMark.
- OI-118 written rev 310 (C9 S1 + bypass split). OA 372: build C9h + RS bypass, cycle-exact vs model
  (cmpl_split=9, rx_lag 16); cmpl_l raw -> capture+RS+wake (3 pins), ROB x4 from keep copies of cm_q; hint raw to capture.
- OI-114: (c) measured: unmet in go 23.9/24.2 but go's own per-take chain stays over (ff 28.5, hv 31.4, px 31.1,
  pl 30.5, ha 28.8, room_p 26.9, room_g 25.4; without fanout 23.1). Rename with the registered (U-L): c_dst/c_src 27.3,
  po_dst 28.0 (caps 26.9/27.5) on first try; second form (no hold muxes) measured in go-check.log.
  (b) on RH: gate-scratch/OI 1621599 (floor_take_lag knob + oi114job/run.sh), worktree scratchpad/wfl.
- OA 370: fault pc per entry pc[31:1] + per slot pc[47:32], 4,032 flops, from ccv_dec_ooe_uop.pc at fill.
- C9h BUILD PLAN (11-06 22:30, after re-reading the model): cs=9 = RS part on arrival (as A6) + ROB part a cycle late
  + bit 8 (hit-confirm free kept off rs rmask, held from alloc/room a cycle); rx_lag 16 = hint acts a cycle late.
  The trio at cs=9 sees RS acts at the same cycle as A6, so wake's raw hit decode (hit_cq01h from cmpl_idx) IS the bypass
  set (fin, confirm, miss check, msd) - REVERT the wc9 wake probe (it lagged the hit: why it diverged). Changes:
  (1) new capture module (cmpl valid+payload, <=4 keep copies to rob_w x4; rob_w ports shift a cycle: cm_l_cq02h/cm_tag_cq03h);
  (2) wake: hint payload captured under hv; hnt/hm/wml a cycle later; trio_tb defers core.hint a cycle (env TRIO_HINT_LATE)
  - in ooe_test.cpp step() the hint is t+2 ahead; (3) rs: probe's confe rmask (bit 8) + the alloc/room hold where RTL picks
  free entries; (4) model defaults cmpl_split=9, rx_lag=16; regen. Check rate/pin limits: cmpl_l -> capture, rs, wake (3).
- 11-06 23:20: 20ddeac pushed (OI-114 (b)); OI-119 close-out row rev 311 (FYI to OA, no notice). Bookmark OI 311. Main checkout ff to 20ddeac.
- 11-07 00:10: wc9 WIP commit: trio EXACT at cs=9 rx=16 (25 seeds, 0 mism); wake hint = capture then decode as hm, hnt=0 (spec timers unhinted: model ignores hints <2 ahead); rs hold hh (conf & (cmn|cmn_q)) off alloc, rmask excludes hit-confirms. cs=0/rx=0 fail vs this RTL (controls). TODO: model defaults, rename room hold (rsHeld prev_hfree) in rencred, ROB capture+copies, NGD/CG, benches rs_tb/wake_tb.

## 11-07 ~00:50 UTC
- wc9 at 35999fa (WIP C9h): model defaults cs 9 / rx 16; trio exact + no-c9h control; rs/rnrs pass
  (rs clears hit-held column via clr = free | hh; benches skip held cols one cycle; rnrs assertion exempts u_rs.hh).
- check-cg on wake/rs/cmcap running (logs scratchpad/c9/cg-*.log). Open: wake hix CG-3 69% in medium.
- TI notice rev 357 (bookmark TI 357): Z pushed f4ce0fd (LANE 7/SFU 12); TI edited defaults in
  ooe_rendep.sv, ooe_rename.sv, ooe_wake.sv. Nothing asked. Merge f4ce0fd into wc9 before gate-push.
