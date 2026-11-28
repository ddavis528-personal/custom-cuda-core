# OA handoff (OOE architect)

Updated 2026-11-27 (sweep done). Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds OA's.

## Role and rules (from Daniel, in conversation)
- OA 517 (re OI-233; 11-28): THRESHOLD_MLC re-sweep (model; stub MIU at MA-34 sizes plus p1; 3 seeds): nothing beats 50 under OA 476, so 50 stands and the OOE doc is unchanged. gtw32 RAU/PCA hangs at 35 and 100 count as failures; OI reruns on MA's p1 fix. OA 504 closes when no value hangs, 50 included.
- OA 516 (re OI-232; 11-27): pn_gname/pn_pname SIGNED (readback, pn_bound, pn-late). keep_ep_settled (a5230b54) confirmed; the 5 epoch tables are signed on it. ALL #78 declarations are now ruled; OI gate-pushes once once TI's lint (a)(c)(e)(f)(g) lands. WATCH: that push; the OA 511 kernel/SV condition at assembly.
- OA 515 (re TI-600; 11-27): TI's B readback form (2417881e, bad_conn10) and (f)/(g) (f798a4fc) are on gate-scratch/TI-lint4. 'Through' confirmed PER TABLE: u_keep's se/sn/s2/wq/wep stay refused until OI extends keep_row_settled to their write enables, with a control. Connection excuse confirmed (up to the ahead, that port only). u_ren1.c_gk and c_pk readback entries SIGNED (pw_seen, pw-drop). c_gv/c_pv renamed to cq02h (they were mis-tagged). The p_v edge is no finding, dropped. pn_* wait on the Rename 2 assertion.
- OA 514 (re OI-230; 11-27): u_select.rhold RE-SIGNED (loop grant_cq03h>gnt_cq04h>fcp_cq04h via rg/rnx; idle_r, no-force). u_keep readers hit_cq01h/ok_cq01h accepted. pn_gname/pn_pname under option B with u_ren1.c_* (pw_seen's Rename 2 half, to sign when drafted). TI (f) CCV_ASSERT_T and (g) parent assertion endorsed. Signed so far: u_go six, gnt, hold, rhold, u_keep seven. WATCH: TI's B form, (e)/(f)/(g); OI's B drafts.
- OA 513 (re OI-229; 11-27): u_select.hold SIGNED (ret_holds, control no-hold; no-ret-hold kept). u_ren1: option B, a TI form for a register read back with no closing path, after (a); A refused because c_* never reach l_v/l_gkm/l_pkm, so no loop; entries stay on the ratchet until B lands. u_keep: in on decrx_tb plus a model-side check now; kernel and SV-hosted RTL wait for assembly. WATCH: TI's (e) and B form, OI's rhold redraft, the B drafts to sign.
- OA 512 (re TI-599; 11-27): TI's two edits to the signed ooe_rename.feedback.json CONFIRMED (u_go.pl_cq02h removed, its asserts and control keep running; wb out of rt_l's cone and its why). Lint ask (d) WITHDRAWN (OA 481 (1) allows the offsets; no new rule). u_select.rhold signature WITHDRAWN: fcp_cq04h comes from mig/rnx, not grant; OI redrafts it, or declares it as RA-17's lead. pn_gname/pn_pname now on the conn ratchet, for OI to declare. TI's a/b/c/e are on ti-lint4 (36d68ea9, 6bd47aa9); #73 needs ooe_rob_w to instantiate ooe_redir.
- OA 511 (re OI-228; 11-27): u_keep's seven table entries SIGNED (keep_row_settled at 52db5413, control row-early; writer filled per TI (c), no re-sign). Conditions: holds on check-kernel and SV-hosted (if not, add a bypass, don't weaken the assertion); reader named u_keep.enq_v_cq01h.
- OA 510 (re OI-227; 11-27): read the drafts at gate-scratch/OI-oi-map2 9b95e4f8 (docs/drafts/oi-oa509-decls.json). u_select gnt and rhold SIGNED. hold is signed once its assert is the check that no-ret-hold trips (e.g. ret_holds). The u_ren1 c_* four are signed once their loops name nets and the p_v edge (2d) is declared beside them. pw-drop accepted (pw-late optional). px and pool_en committed at 0a5fc65f.
- OA 509 (re OI-226, #78; 11-27): the six u_go loops (px, room_g/p, unmet_g/p, pool_en) SIGNED from the row's text, since go6.json isn't pushed; room and unmet go in after TI's lint (a). u_select 3 accepted as parent-register loops (no_regrant, no-ret-hold, no-force); I sign when the drafts are readable. u_ren1 c_* plus p_v (2d) are one pending-writer loop: assert pw_seen, control pw-late. u_keep: Option A, a declared table (decrx writer, write-before-read assertion, early-read control). Lint a-d endorsed to TI; (c) unblocks #73 PWV. WATCH: OI's u_select, u_ren1 and u_keep drafts to sign.
- OA 508 (11-27): DI's ccr-5e4d6c70 (f2accd75, 5 merge bases) left out of the 11-27 sweep; DI merged 7f5195a4 into it (5a4a865c, DI-62, gated); the next sweep takes it with one base.
- OA 507 (11-27): AR's ccr-183cc441 (10 bases) answered AR 423, covered via ccr-80102643. OA 506 closes OA 505 (miu_form was the g++ harness compile; clang++ at 3826f9cf brings it to 564 MiB; TI-591 takes miu_form off heavy-units).
- OA 505 (11-27): 11-26 sweep (9 branches -> b231aee0) full gate RED: check-cg OOM-killed (python3 6.5 GB; earlier cc1plus 5.5 GB), no rule failed. Likely new miu_* cg units from claude/miu-dcu-microarch-spec-664pgr (miu_form first; dcu_bctl dir also left) not in tools/heavy-units.json. Asked MI to measure (rss-run, cold), TI to list, DI dcu_bctl. Nothing pushed; local red merge kept as branch sweep-1126-red, ccr-9eb50716 reset to d2aea95d. WATCH TI heavy-units row, then re-run sweep.
- OA 504 (MA-34, DA 136 = B, 128 lines in flight, AR's session): OI re-sweeps THRESHOLD_MLC (OA 475) once TI carries MA-34 sizes into stub; 50 stands; OA 476 rule. No OOE doc change.
- DA 135 (11-24, Daniel in OA session): a block's loop declarations are signed by that block's architect (MA for MIU/DCU; MI-39 "by": "MA"). OA 484 CLOSED (OA 503). S1 bar question CLOSED by Daniel (bar stays 0.5%). TI, MA, MI notified.
- OA 502 (re OI-221/222): u_gfree sa_l/rt_l signed (sa_led/rt_led at 9ffba2bd; cone-only, lint traces u_ren1). All 7 u_gfree signed; rt_v/rt_row committed. Remaining: u_go 6 cone loops; u_map table commit after ti-hop.
- OA 501 (re OI-220): rt_v/rt_row signed (rt_of_grant, rt-late); u_gfree sa_* committed cf3ce683. u_map: unread-net output not read (TI); staging regs = OA 500. Leads sa_l/rt_l: source u_go.lane_v + crossing u_ren1.lane_v_cq02h>l_v; TI to let them compose. Remaining: u_go 6 cone loops, sa_l/rt_l drafts.
- OA 500 (re TI-576): writer-input exemption may pass through write-pipeline regs whose whole fanout ends at the table regs; negative test with an extra fanout.
- OA 499 (re TI-575): cone source "<inst>.<output>" with ahead from its verified stage tag accepted (sibling must have a unit, not on stage-ratchet). TI-574 writer-input exemption matches OA 497. TI-hop (e51d25e6) gates after ti-pt.
- OA 498 (re OI-218): u_gfree sa_v/row/sec signed (u_ren1n.n_* ahead 2; sec_alloc_free/sec_free_live; sa-late). rt_v/row pending a late-return control caught by an assertion. sa_l/rt_l: TI cone may list named crossings as sources.
- OA 497 (re OI-217): u_map 5-port table in ooe_rendep.feedback.json signed (prv_carries_g1 at OI 37ed18ae; no-prv caught). TI: writer-input exemption (cone ends only at declared table regs D/en). OI commits by:OA when ten lint clean. u_go.pl on gate-scratch/OI 37ed18ae awaits TI-hop merge. NOTE: gate-scratch.sh fetch-commit checks out detached; return to branch after.
- OA 496 (re OI-215): u_map 10 = table read (m_* pipeline copies; table eg..ecv in ooe_prodmap, reader u_dep at 03, in-flight covered by prv_dep). Retag withdrawn. TI: table form with sibling-child register writer (Q->out comb, wired straight). OI: declare + assert prv_dep carries every in-flight hit + drop-prv control; OA signs once it lints.
- OA 495 (re OI-214): u_go.pl signed as applied (crossing u_ren1.lane_v_cq02h>l_v; lands with TI-hop 55d089a6). 22 loops: (a) u_go 6 -> TI cone-source form, no extra cycle; (b) u_gfree 7 -> child-to-child from source child reg; (c) u_map 10 -> OI reports if m_* is held state (declare via "u_dep.<in>><reg>><out>", TI to admit) or pipeline copy (retag). Each needs assertion over stale window + control.
- OA 494 (re OI-213): pl_cq03h copy + u_go.pl decl (ahead 1, no_over_grant_*, no-take-q) signed in substance; effective once lint traces it. TI asked to extend L23 form: hop "<inst>.<in>><out>" crosses a child only via measured comb port_paths. Then u_go 6/u_map 10/u_gfree 7 loops get declared; OA signs each per OA 489. OI to say if u_go.wt_cq02h is a register.
- OA 493 (re TI-567): TI carries DA 134 via OOE_RISE_CAP (ooe_*/ccv_ooe fanout caps to 30). TODO: when Daniel confirms bottom-up budgets exist, OA writes the row closing the window; TI then drops OOE_RISE_CAP.
- DA 134 (11-24, Daniel in OA session): OOE paths already on the NGD ratchet may rise to 30 NGD, if needed, until block-level assembly (for validated bottom-up budget rebalancing); new/non-OOE paths keep 25. OI and TI notified; TI to say how check-ngd carries it.
- Ownership: RAU spec = AR, RAU stub/skeleton = TI; RA/RI/RH are RCU architect/impl/runs. Route RAU asks to AR/TI.
- OA owns the OOE microarchitecture doc, not code: Claude doc
  7tpEyGaCvfdvYYWUQJvJSU, body node 401b2bac-8176. Update it without asking
  (DA, 2026-10-20); keep it consistent with every decision.
- Register: write only the OA tab (node 4c6a3151-83eb, responses table
  m8yvbw8rqgz.6213; every row exactly 4 cells: title, date, summary, body).
  Record Daniel's decisions verbatim in the DA tab (table m8yvbw8rqgz.231).
- Report to Daniel in a few lines: what changed, then any decision that is
  his. He is a senior microprocessor design engineer; write as to a peer.
- TI-445 and DA rev 120 (11-15; DA 120 adds: architect also keeps boundary-wired budgets): a module's owner sets/moves an NGD port budget where check-ngd's convergence times the connection (parent has a unit), check-ngd passing. OA still sets budgets for OOE modules with no measured parent (ooe_rename, sched, rs, rat, decq, age, rencred, rob_w) and every block-boundary/lead budget; rendep/go/ready/select/wake/pick/confirm etc. are now OI's own. OA reviewed: no budget seen that this lets through without convergence holding.
- TI-461 (DA 11-16): no dated tasks; best effort in priority order; meet dependencies by reordering.
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
Since 11-14 (a46afef7 merged; TI-420): `CCV_PUSH_BRANCHES=ccr-9eb50716-lecnjf
tools/daily-sweep.sh` self-detaches and prints its job log; wait with
`tools/gate-wait.sh <job log>` as a run_in_background task (exit 3: still
running at 110 min, rerun gate-wait; 4: killed, rerun the job). Before it
lands: the TI-418 recipe (setsid nohup bg-run, kill -0 waiter). A 503 from
the proxy's credential service on push: retry by hand (11-13); `python3 tools/setup-session-home.py --check` (exit 1: ask DA to
approve the install again); pings Fridays only (TI-49); report in a few lines.
Session home installed 2026-10-31 with DA's approval (TI-50): /home/user/.claude
holds the 400k window, the handoff hook and the agents link.

## Sessions
TI session_01J4Yp3xeV6DJtgCtcoqVsAq, OI session_01DMw4FtFbGoVboMGxWpLBuv,
AR session_01FnGhxke3r33MeArLeQJRcD, IS session_01989HiTNh4Gx7XMSsdvdE7Z,
CP session_019cSebQ45AT3pSnPU71torg, RA session_01QPk2jzLmjd3MWXjayVUy9d,
RI (session not yet on the roster). OA is session_01TbX2MyX6quhjarDR7J2bMR.

## OI-150 (OA 417, rev 419, 11-15)
Arrivals kept. go: producer encodings (decq one-hot need, Rename thermometer pool) granted at 2. rendep gsn/psn: arrival 2 only if Rename precomputes the one-hot index at no latency. sched res/vel: OI to model-price the fallback a cycle later (OA rules if under 0.5% S1, else DA). ooe_rob_w wid_cq00h: arrival 0, one-hot flop, within the ratchet caps. OI-151/OA 418 (rev 420): WID strap withdrawn (over caps); WID stays a param with units at 1-3. DA's 11-15 ruling was given in OI's session; record it only once Daniel confirms the wording. #52 rob_w: Rename 2 per-slot fill valids and OOE-capture per-slot dn/cm valids granted at 2; OI measures before pushing. OI-152/OA 419 (rev 421): fl_m cap 29.3 (baseline 31.7, TI adds the line), fl_v/fl_slot caps removed; the NGD-1 rise to 30.1 at WID 3 (ABC remap of the retire window) is DA's call, and OA recommends holding 29.6 and isolating the retire window in a child first; (C) withdrawn. DA ruled (a): NGD-1 cap 30.1, #52 pushed (OI-154, b1570e4d); retire-window rework is OI's next priority (OI-153: the child-module lever doesn't fit the baseline/convergence rules). OI-158 (DA in OI's session: push e6, al_n 29.6/dn_tag 26.9 caps raised, restructure to OA, "repipelining") -> OA 420 (rev 422): cut (b), register the retire pick (count one-hot, fault, wrong cand.); next pick on the stale head shifted by the registered count (window 2RP), so bandwidth holds; retire-to-reuse and fault redirect +1. (a) withdrawn. al_n/al_nop/fl_m flopped on arrival (assert no done the next cycle; flush kills the registered alloc; go subtracts last take). OI prices rob_retire_lag 0/1 on RH (S1/cm32/cm128) before RTL; OA rules under 0.5% S1, else DA; then the OOE doc's retire section takes the stage. OI-159 priced (model, a5dc7eed): S1 +0.16%, cm32 +0.50%, cm128 +0.92%; rob_full head-wait flat, so the cost is free-list/redirect lag. OA 421 (rev 423): (b) adopted on S1; the coremark cost is sent to DA, recommended accept (asked Daniel in chat 11-17). OI to split cm128 into retire vs alloc lag and report the shift+pick depth now; the rest of the build after DA answers. OI-160/161: alloc flop 0, shift+pick 17.0 NGD; the -priv costs are cm32 +0.15%, cm128 +0.06%. OA 422 (rev 424): (b) ruled in full, DA ask withdrawn; OI builds. TODO: update the OOE doc's retire section when the RTL lands.
TI-474 (DA array test: BIST, spare row, column repair, SECDED) -> OA 423 (rev 425): OOE has no macros; asked DA to confine items 1-3 to macro instances (flops left to scan). DA answered (TI-476): flop arrays are scan-only; BIST, port-up and repair apply to macros alone, so OOE has no BIST ports. TI-475: ECC events go to an architectural fault system (AR to define); a DED on a load will need an OOE fault path, so answer AR's row.
MA rev 76 (ECC late cancel) -> OA 424 (rev 426): it rides OOE's miss path; L1_HIT stays 7, cmpl one cycle later after the syndrome and withheld on a non-zero one; CCV_LAT_L1_CMPL derive +1 (14 to 15). OI prices CMPL 15 (rule under 0.5% S1); MA confirms the syndrome is one cycle; AR owns the derive (AR 368: CCV_LAT_L1_ECC=1 on CMPL only); TI lands it. MA confirmed a one-cycle syndrome (rev 78). OI-162 priced CMPL 15 (S1 +0.05%, cm32priv -0.35%, cm128priv +0.45%); OA 426 (rev 428) ruled it; TI lands AR 368 with the stub MIU patch. Doc rev 383: memop paragraph (SECDED) and CMPL formula (+L1_ECC). AR 370/IS O-86 (DA 124): ECC fault system; core-fatal via CRU MACHINE_CHECK + RAU kill; no OOE change in v1. RA 153: RCU takes the corrected beat as is; (3) answered in OA 425 (rev 427): the PRF_COPY lands before the first beat.

OI-164 (rob_w step 2, RTL: ckf/ckfa_s NGD-1 31.3 vs fanout cap 28.9; DA: repipeline or add a cycle) -> OA 427 (rev 429): option 2, checkpoint freed a cycle later (free/pick registered at 02); OI brings NGD after (ck->reg <=28.9, reg->ckf well <25, flops, CG) and model S1/cm32priv/cm128priv vs 5e1f3789; <=0.5% S1 ruled, no further row, #61 unparks; over -> option 1 (128 flops) figures beside it, to DA. Option 3 (redirect R+2) rejected. Retire-count paths 29.5 ride OA 420's cut. OI-163: LAT_MISS 16 pushed.
OI-165 (A-70 arrival drop: RTL has no warp-to-slot table/epoch) -> OA 428 (rev 430): (a) new OOE module ooe_decrx ahead of ooe_decq owns warp-to-slot table + per-warp epoch AND the advance (flopped redirect/demotion/kill pulses, same pulse as FET epoch_only notice); ordering invariant: advance visible at compare no later than decq's flush of that slot (bench assertion + delay-by-1 control); cycle: OA raises decq enq_v/enq_slot_cq01h arrival 5->13 if decq converges to 25, else receiver flop priced (<=0.5% S1 OA). OA to add ooe_decrx to doc A-70 para + stage boundaries when OI lands it.
OI-166 (decrx built, local db0d1341; decq at enq arrival 13 = 32.4, so flop route) -> OA 429 (rev 431): decrx arrivals adv/adn 8 (flush cone), rel/al_v/al_warp 2; keep+flop in decrx, decq unchanged; cycle ruled on RH's rx_lag 80 vs 16 price on 5e1f3789 (<=0.5% S1 OA, else DA); (i) double advance, (ii) per-slot alloc ports (rate-1 contract question -> TI row by OI), (iii) alloc bypass accepted. Doc update (A-70 para, stage boundaries, ordering invariant) when db0d1341 lands. Notified OI and RH.
OI-167: OA 427 opt 2 priced S1 +0.002%, cm32priv +0.087% (ruled) but ooe_rob_w NGD-1 30.1 vs 28.9 (fka 30.1, sq_rt 29.9, fa_oh 29.9, run 29.4) and fl_m 29.3 vs 28.8 block #61; DA: repipeline or add a cycle; OA to name cuts. -> OA 431 (rev 433): root cause = run's 2nd subtract (step 2 -al_r) raised ABC no-fanout target 23.8->26.6; cut 1 te_q=rotl(toh,al_r) 32 flops; cut 2 fold rd_s into sqm (reset, 8 sites); measured at 15ef1bd4: NGD-1 28.5, al_n 26.6, fl_m 28.8 (at cap); no cycle. Diffs sent to OI by message (scratchpad exp3-te_q.diff, exp4-sqm-on-exp3.diff, tr/trace.py). Optional oxe flop; fl_m keep on fl_e if needed; watch retire cone 28.4-29.5.
OI-168 -> OA 430 (rev 432): (B) decq late flush drops staged arrivals (fl_q, 0 NGD); no_enq_at_flush replaced by bench assert that each such drop is stale-epoch; controls keep-across-flush + adv-late; credits balance. (ii) no TI row needed (skeleton honours rate 1). RH: rx_lag 80 results go to OI, who books them.
OI-169: decrx flop priced (RH, model, 5e1f3789) S1 +0.946%, cm32priv +3.575%, cm128 pending -> DA's; OI holds push. OA 431 cuts pass rob_tb (wt-61 e29ea4ac), NGD next. OA 429 (i) FET epoch probe 12486 checks 0 mismatches. -> OA 432 (rev 434): no-cycle form = warp_id+fetch_epoch as lead_fields of ccv_dec_ooe_uop; decrx looks up+compares in lead cycle, flops {keep,slot}; B late flush covers; recommended to DA over the cycle; AR decides interface, TI applies, DEC stub sends early; OI rebuilds + lead-late control. Notified OI, AR, TI. AR 380 (rev 383) approved: DEC can lead both (arrive with fetch group, no DEC cycle); AR concurs for DA; DEC spec carries the lead pending TI. DA CHOSE the lead-field form 11-18 in OA's session, verbatim "Yes we should go with the lead field form. The 3.5 percent impact of the added cycle is too much" (DA tab rev 127, row .129003; DA tab node d5076b00-ef1b). OA 433 (rev 435): decrx flop withdrawn; TI adds lead_fields; OI rebuilds decrx on the lead (arrival 2), drops rx_lag bit 64. Doc update when OI lands decrx. OI-170: lead form built (oi-rxl 942fa18e), enq_slot 12 ungated flops over decrx's 7 allowance -> OA 434 (rev 436): lead waiver under DA's RI-15 standing ruling (RA rev 87), OI writes it, block 2% sum confirmed in landing row; told DA (he may object).

## Register bookmarks (revs read through)
Conventions 20, OA 517 (OA 435-517 are OA's own writes), MA 221 (tab 1f971016-3f72), DI 101 (tab 1ea5d5b3-6e9c), MI 74 (tab c1311541-4219, not on roster; only 'OA' hits read), AR 426, OI 436, TI 602, IS 201, CP 160, DA 136,
RA 159 (tab 9851686b-2b0a), RI 93 (tab 8e4547bc-c469), MA 97 (tab 1f971016-3f72; MA session session_01QPk2jyUbWA7fW9YpUwqdxk, roster entry merged 11-13).
OOE doc rev 390 (rev 388: No-stale-frees para back to OA 436 text + FET spec rev 49 + MIU tab rev 140; rev 387: OA 437 version (FET drops killed slot's frees, AR 383; OOE stops new frees at notice; atomic pending MA); rev 386: OA 436 version, superseded; rev 385: ccv_ooe hierarchy table added under Stage boundaries, before Reset line, OA 435; rev 384: As-applied para now states today's L1_WAKE 13 / L1_CMPL 15). Pings Fri 2026-11-13 sent to all 8 roster sessions (AR IS TI OI CP RA RI RH; MA none); all 8 ponged, check ok. Next Fri 2026-11-20.
Sweep 11-27 (Fri): full gate green, pushed 7f5195a4; release c0c73813; tag refused. Merged by hand ccr-3868632d (IS; 10 bases, merge-tree per base, all bases agree except handoffs; b0885311 by commit-tree, so it went out UNSIGNED and GitHub shows it Unverified), which brought in ccr-183cc441 and infra-6msg93; then the sweep merged ccr-c22116ce(1) and ccr-58815650(15, its own commits picked). DI ccr-5e4d6c70 skipped (OA 508). Pings: all 11 ponged ok. Register: nothing for OA; TI-592 landed MA-34 B/ti-hop (c0883a36); MA 221 accepts MI's port budgets (F-SHARED).
SWEEP LESSONS: --skip takes ONE comma list (--skip=a,b); a second --skip overrides the first. Many merge bases: per base, `git merge-tree --write-tree --merge-base=<mb> HEAD <br>`; if the trees agree apart from generated/handoff files, `git commit-tree -p HEAD -p <br>`, then `git commit --amend` it to sign (commit-tree does not sign). ort with 10 bases stalls for more than 30 min. After a reset, clear build/ except synth-cache before gate-push.
Sweep 11-26 (Thu; 11-25 missed, idle): merged ccr-183cc441(2) ccr-c22116ce(3) ccr-5e4d6c70(5) ccr-126afa13(9, resolve retry) ccr-3868632d(8, resolve) ccr-58815650(45, resolve) ccr-80102643(12, resolve) ccr-888218a3(6, resolve) miu-dcu-spec(6, resolve); full gate RED (check-cg OOM, OA 505); nothing pushed. Register: OA 504 (MA-34/DA 136); TI-583/OI-224 rendep NGD fix, TI re-gating ti-hop. No pings.
Sweep 11-24 (Tue): merged ccr-183cc441(150) miu-dcu-spec(20) ccr-58815650(12, resolve retry) ccr-80102643(4) ccr-57eff422(2); release gate green on c919af51, pushed; release fd4d5ee9; tag refused. Register: nothing for OA; DA 134. AR 416 (credit-end depth; OOE P0 discard reads thr_q +1), AR 417 (W_REQ_MLC_EXB 6->8 provisional), MI-43 (L0 6 entries, cm128priv +0.47%). TI-581: b3834897 landed (port tables, OOE cap 30); ti-hop gating. No pings.
Sweep 11-23 (Mon): ccr-58815650 took the resolve fallback but merged clean. Merged ccr-183cc441(155) ccr-58815650(18) ccr-5e4d6c70(8) ccr-80102643(6) miu-dcu-spec(3); full gate + release gate green on 7696e42c, pushed. Register: nothing for OA; DA 131. TI-529 landed pc_kept (ba085cda). TI-531/AR 410: coremark re-baselined (testbench latency artifact); no OOE price near 0.5%; cm128 flip price (OA 466) must use the new baseline. No pings (Mon).
Sweep 11-22 (Sun): run 1 stopped on ccr-80102643 (300s ort timeout, resolve fallback conflicted sim/skel/main.cpp); plain ort merge was clean after 34 min (only AR.md), committed by hand; rerun merged claude/miu-dcu-microarch-spec-664pgr(3). In all: ccr-183cc441(126) ccr-57eff422(17) ccr-5e4d6c70(10) ccr-c22116ce(2) ccr-80102643(10) miu-dcu-spec(3); full gate green, pushed 11f90098; release 6538a2fe; tag refused. Register: nothing for OA; DA 131. TI-519 table form landed 63579fce -> OA 467 accepted (lint checked; assertion content + control by review at signing); OI to bring ratmap declaration for OA to sign. OI-199 -> OA 468 (rev 470): SIGNED pk_cq05h/rd_cq01h (dd296f15, reviewed from row; read_not_written covers write cycle + next; read-at-write control; RTL CG 1.4%, NGD 13.6). WATCH OI push, then OOE doc hierarchy table. OI-200/TI-523(1) -> OA 469 (rev 471, 11-23): pc_kept on ccv_ooe_rau_drained accepted (exact: redirects come only from ROB-held instrs), PC-on-alloc rejected; OI clears next_pc at both allocs + pc-kept-lost control + RTL flop home; AR contract, TI schema, TI's RAU consumes. OI-201 -> OA 470 (rev 472): ooe_slot rsa flop accepted; pc_kept = !rsa alone (dq/held dropped); model assert resume_pc==RAU PC when !rsa; RTL control breaks rsa clear at restore; default budgets. AR 406 confirmed but crossed OA 470 and corrected OA 469's fetch argument (predictor leaves start_pc; exactness rests on arch PC moving only at retire) -> OA 471 (rev 473): accepted; asked AR to drop ROB/decq term from (1) text. OA 472 (rev 474): RAU is AR's spec + TI's stub, NOT RA (RA = RCU; RA 158). AR 408 took OA 471's iff (ROB/decq dropped); AR 407: no new RAU register. TI-525 applies pc_kept. OI-204 (11-24): pc_kept (ooe_slot rsa: set by retire, cleared by load) + mlc_miss false-demotion split landed, f1c58e7d/8e1762ce on ccr-57eff422 (controls pc-kept-lost, mlc-split-all-miss). OOE doc rev 401: 'Resume PCs per group' para now has pc_kept + MLC_HIT_MAX 28 + split + re-sweep. DONE.
Sweep 11-21 (Sat): first run conflicted on OI's ccr-57eff422-5tdecg (test/ooe, rtl/ooe; AR 402 raised it to OI); rerun with --skip=ccr-57eff422-5tdecg merged ccr-58815650(2) ccr-80102643(5) ccr-c22116ce(1) ccr-5e4d6c70(15), full gate green, pushed 55f24ece; release 64431908; tag refused. Register: nothing for OA; DA rev 128. No pings (Sat).
Sweep 11-20 (Fri): first run stopped on OA.md conflict (ccr-126afa13, took ours, a12c7090); second merged 7 branches, then make-release refused (ccr-5e4d6c70 moved +2); third run full gate green, pushed 677852a8; release c324485e; tag refused. Pings sent to all 11; all ponged. Answered pings from OI CP IS RA MA MI DI RI.
Sweep 11-18: first run (135 commits) and a rerun lost to a container restart mid-gate; third run merged ccr-126afa13(143) ccr-183cc441(9) ccr-888218a3(7) ccr-c22116ce(4) claude/miu-dcu(2), full gate green, pushed a10d4dc7; release b6099f92; tag refused. Wednesday, no pings. Read: nothing for OA; TI-482 lead fields landed (3eb6e8d0); MA-23/AR 381 DCU L1_HIT 8 or 9 with way prediction, pending DA.
Sweep 11-17: 7 branches (170 commits), full gate green, pushed f6e40f9a; release bbb19d12; tag refused. Tuesday, no pings. Read: nothing for OA; RA 154 closes RA 153 via OA 425; DA 124 ECC fault system + SPM as RF (no OOE change); OI rob_w retire stage and TI's CMPL 15 (AR 368) landed later at 9682b03a (TI-478; OI asked to move ooe_wake LAT_MISS default to 16).
Sweep 11-16: 7 branches (133 commits), full gate green (~5.5 h, heavy units serial), pushed 3b3db127; release b4603666; tag refused. Monday, no pings.
Sweep 11-15: 5 branches (116 commits), full gate green, pushed 6aa0c403; release 6fa7fc1f; tag refused (known). Sunday, no pings.
Sweep 11-13: 6 branches (76 commits), full gate green, pushed 0bc98973 (first push 503'd, credential service; retried by hand); release 63625551; tag refused (known).

## Open work (most urgent first)
- TI-554/MI-35 (stage skip hidden in a parent connection, miu_a2 reads miu_tlb's cm11h L0 at cm06h) -> OA 481 (rev 481, 11-24): AGREED (tightens CCV-L23; OA's) with: untagged port on a connection = finding; scope every parent with a unit incl block tops, repeater/wrapper conns vs links.json or excluded by name; cross-module loop needs staleness assertion + control (2nd miss in 5-8 cyc window), by MA; TI reports standing mismatch count per block first; OI fixes OOE's at next touch. Notified TI MA MI OI. MA agreed (MA 205): signs at ccv_miu, per-slot pending-VPN match + 2 assertions + miu-l0-dup control. TI-555: tags child-local (equality would flag 213 legal), relative rule P(O)-P(I)>=S(O)-S(I); OOE 124/433 violate -> OA 482 (rev 482): (c) narrow: exempt only the in-module-undeclared shape (OI-65 same-stage feedback, deficit 1 via register), rest ratchet/fix/declare; (b) rejected; TI lists remainder by module/pair for OA review (flag real skips to OI at once). TI-556: exemption cleared 10; 114 pairs left (103 register, 11 comb) on u_go/u_map/u_gfree/u_select -> OA 483 (rev 483): OK to build with them on ratchet after TI reconciles 22 edges vs 28 ports named; entries carry P/S/deficit/kind; they're rename/select counter+grant loops (OA's ooe_go budgets already time them); OI declares in parent feedback.json, OA signs, cite existing conservation assertions; 11 comb pairs reviewed first. WATCH TI build, OI's comb review. MI-39/MA 207 (L0 loop decl at rtl/miu/ccv_miu.feedback.json, by MA, l0_nodup+bound SVA, miu-l0-dup/tight controls; MA approved arrival/out 0 budgets; L0=6 entries per MA) -> OA 484 (rev 484): form CONFIRMED with: (1) MI writes keyed CCV-L23 form, reader at cm06h, from l0*_cm11h ahead 5 (= MA's 5-cycle bound), loop regs listed; (2) TI-554 build admits the parent block's own architect as `by` (MA/RA/OA), bad_feedback case for another block's architect; (3) MI: last-write copy wv cleared on any L0 invalidate, assertion dropped-miss=>match, flush-then-remiss case + control. Notified MI TI MA. TI-557 (conn check built, gate-scratch/TI-conn c4bddcfa; 38 OOE back edges in rtl/conn-ratchet.json: 23 register, 15 comb = u_keep 7, u_ren1 4, u_go pl 1, u_select 3; doc says by = block's architect) -> OA 485 (rev 485): 3 scoping points confirmed (helpers=parent logic, whole subtree register-free, tagged helper ports held; untagged only at block-top schema channel ports; lib dirs + rtl/top/generated out) with tightening: register-free lib module is a helper, not excluded; TI counts added edges then gates. OI does 15 comb first (retag or declare; OA signs OOE's); u_select restates ooe_sched select loop. TI-559: tightening added 4 (ooe_rename ccv_common_csa op inputs, comb, deficit 1) -> ratchet 42, OI comb list 19; TI gating with two-writer lint; no reply needed. WATCH TI gate, OI comb. MI-40: new iv_cm05h invalidate (Q-60, tied 0 until Q-50) clears L0+wv+stages; l0_nodrop + wvkeep control; keyed form 5 entries ahead 5 loop [u_a2,u_tlb] by MA -> OA 486: accepted; (a) list asserts l0_nodup/l0_nodrop/l0_bound + controls miu-l0-dup/wvkeep/tight; (b) request lost in iv cycle must end in refill/re-miss/replay, assertion + control (MA's Q-60). MI-41 closes OA 486: lists declared once TI-560 lands; dropped request ends in re-miss (l0_nodrop), wvkeep+ivkeep fail. No reply. MA 210 agrees OA 486(b): invalidate may lose the request, never the lane (re-miss; assertion + mark-done control). TI-561: ef260513 landed (table form + conn check, 42 OOE edges on rtl/conn-ratchet.json, OI owns); MI list form next push. WATCH MI decl, OI comb 19. OI-206: OI aliased 18 helper reads one stage back (wqk_cq01h=wq_cq02h etc.) + 17 in-module self-loop decls for OA to sign; u_go.pl retag pl_cq01h->cq02h needs ratchet key rename (TI). -> OA 488 (rev 488): NOT signed (aliases are mis-tags); TI extends OA 482 exemption through register-free helpers (deficit 1, O only to D/enable of reg driving I), in-module decls cover helper paths (u_select under ooe_sched rev 187), bad_conn case; OI drops aliases, reruns, declares residual real reads (u_keep enq_v/enq_slot -> decq first) on real nets, OA signs one by one; u_go.pl retag OK, rename at equal cap supported. 23 register edges per OA 483. OI-207/TI-563 (23 register edges = 3 parent-closed loops in ooe_rename: u_map record d3, u_gfree alloc/free d2, u_go counters d3-4; form from=parent reg, loop=[child out, reg]) -> OA 489: intended; assertions cover full stale window (u_map: ideal-map equivalence incl bypass, bypass-off control; u_gfree: no row offered while alloc in flight, delayed-sa control; u_go: name term per in-flight take, no over-grant, drop-one-term control); form + multi parent-register loop list, each hop traced, bad_conn case. TI-564/OI-208 -> OA 490: pl = OI's retag; crossed OI-209 (OI back to declare). TI-565: TI takes OI-209 (declare pl in u_go loop, no rename) unless OA objects; OA did not object (no row) -> pl DECLARED, as OA 489. WATCH TI push, OI drafts, OA signs.
- DI-41 (dcu_bctl fold table ft_q_cc03h: store-fold writer cc02h is a true RMW loop; fill writer from cc04h grant flops is not) -> OA 479 (rev 479, 11-23): (a) loop decl on wfs/wff/gfa rejected (fake back edges), (c) not needed; RECOMMENDED (b) to DA: table may have one loop writer ('reads') + listed later writers, cond 3 per writer, cond-5 assertion on each non-loop enable (fill-write forward declared as bypass if needed), check-1d two-writer pass + refusals (unasserted 2nd enable, undeclared writer). DA APPROVED (b) with the (iii) margin assertions (in DI's session, DI-42, 11-23); TI writes the lint form; MA specs how dcu_bctl keeps the margin (assertions fire today). MA signs DCU's declaration; MA renames DI-40 keys. Blocks DI-39. TI-548: lint built 69381fed -> OA 480 (rev 480, 11-24): accepted after running check-1d (pass + 4 refusals; write-conflict assertion taken into form). Explained 0.2%-vs-0.5% band to Daniel 11-23, recommended single 0.2% S1 bar + CoreMark alongside; AWAITING his answer.
- TI-537 (DA: one common RTL credit impl in rtl/common by TI) -> OA 477 (rev 477, 11-23): shape confirmed for OOE with 4 corrections: (1) registered may-send flag form (cok_cq03h style), fv_link-proved at depth+1; (2) SLOTS vector + K-wide decrement for memop P0 bulk discard, or local by DA exception; (3) credit/lead waivers live once on cr_src/cr_dst, OI's 4-flop ooe_sched entry removed at migration; (4) flopped reset, latency in unit; OA sets OOE boundary arrival for credit_in at migration. ooe_rencred is not a channel, stays. OI migrates sched memop + decq returns after it lands. Notified TI, OI. TI-539: v2 takes all four, instance per slot -> OA 478 (rev 478): accepted; ~20 ungated flops (5/slot, <8-flop gate min) leave cc_en into OOE 2%; OI reports headroom beside mempl's 21; fallback TI SLOTS shared gate, not a waiver. WATCH TI landing, OI headroom. TI-541 (DA to TI, 11-23, AR 415 (5)): option A, named NGD exception credit/stall -> cr_go -> same channel's valid at a flopped sending end, timed as the port-budget pair (credit/stall arrive 0), never NGD-5; depths stay 4+2N; OOE may keep cok per channel at +1 depth (memop: CCV_MEMOP_CREDITS 10 covers it for N<=2). FYI only, no OA row.
- AR 414 -> OA 476 (rev 476, 11-23): took DA 115's band for the THRESHOLD_MLC sweep (S1 <=0.2% OA; 0.2-0.5% and over -> DA with figures). DA 115 was set for zero-cycle receiving ends; ASKED DANIEL (chat, 11-23) whether 0.2% now bounds all OA S1 cost rulings. Until he answers, earlier rulings stand. Record his answer in DA tab.
- AR 413/412 -> OA 475 (rev 475, 11-23): MLC_HIT_MAX 39->28 accepted (derive, not measured); THRESHOLD_MLC re-swept 35/50/75/100 at AR 412 read + swap classes and S1, by OI, only after MA Phase 1 read-path sizes are in the stub (HEAD caps would measure the caps); keep 50 unless >1% win at <=0.5% S1 (mine; >0.5% DA); OI adds false-demotion split to demote_trigger.mlc_miss now. Notices sent OI AR MA. WATCH OI counter, MA Phase 1, then the sweep.
- DA GRANTED OA 446 (11-22, DA tab rev 129, verbatim recorded): ooe_mempl 21-flop gate waiver; OI writes entry (OOE total, lead flag if mgl_cq01h is an input). WATCH OI's entry; OOE doc note.
- DA CHOSE D for OA 450 (11-22, DA rev 130): redirect lag 1 PWV; OI lands + measures NGD/CG (RTL), raises TI row (payload with valid, cq04h); OA sets rd_*_cq03h budgets from OI figures; significant NGD/CG issues -> back to DA. WATCH OI landing row. OI-205 (oi-pwv2 0e9c0703, parked): D as built needs CG-5 waiver on ft_cq04h 364 flops (enable rd_l_cq03h is redir input) + rd_tgt 21.6+5.0=26.6 across rob_w->redir; OI recommends C. -> OA 487 (rev 487): first move ft_cq04h into ooe_rob_w (rd_l own flop => CG-5 ok; rd_tgt ends on internal flop ~23); 4 valid bits ungated, merges stay in redir on read, NGD-7 keep copies; OI brings rob_w NGD/CG vs caps + bench. Fits -> D lands, OA sets ft budgets (out 0/arr 0) + doc redirect lag 1. Else to DA, recommend C (+0.7% S1 model not worth 364-flop waiver). OI-211 (oi-pwv2 dcdb1c5d unpushed): hold in rob_w, redir keeps warp/epoch (ew/ee_cq04h); rd_* 11.7 out/4.8 in/16.5 across; NGD-7 cleared; fl_m NGD-3 28.8->29.3 citing unrecorded DA 11-24 rule (ratcheted path may rise to 30 until final assembly, never past fanout baseline). -> OA 491: D accepted; ew/ee signed (by OA, 2026-11-24, OA 491) once why names epoch-staleness assertion (send ee == current epoch) + control; OI confirms cg-waivers unchanged; fl_m rise needs DA words in DA tab (OI records) + TI row; prefer register-side copy. OI-212: ew/ee applied (hd_read_not_written, redir-epoch control), cg-waivers unchanged, hold gate 83 flops en rd_q_cq03h DCGE '-' (no resolutions in unit); 2 findings -> OA 492: (3) hd_cq03h reads rob_w rd_*_cq04h: table read on an input port (not loop, not retag), TI extends table form, OI adds pick-at-resolution control, OA signs; (4) retire PWV=0, retag rdr_*/ckf_m cq04h via TI row, model redirect_send_lag 1; stimulate resolutions for DCGE; fl_m words to DA tab (OI quotes two versions). TI-566: input-port table form built (gate-scratch/TI-pt 9578fbef), gates after TI's current push; (4) no TI row (OI files only). OA signs hd table when OI applies. TODO after push: OOE doc redirect lag 1, hold in rob_w, warp/epoch in redir, channel cq04h. WATCH OI, TI.
- DA ADOPTED OA 452 (11-22, DA rev 131): CCV-L23 'table' form, all 7 conditions. TI: lint + style doc + check-1d fixtures. OI: ooe_ratmap declaration (OA signs), no-same-cycle assertion + control; ratmap off swept branches until TI lint lands. WATCH TI landing; sign OI's declaration. No DA decisions pending from OA.
- OI-181 slice 5 (B) accepted (OA 449): bar_pend +0.083% S1, side buffer depth 2; gains (layernorm -6.1%, sgemm -1.2%) explained (OA 450: even release spread); WAITING: bar-* controls on bar_pend form, rob_w landing row with budgets (OA's; bh_cq02h from a flop), squashed-place bin.
- OI-197 -> OA 465 (rev 467, 11-22): RTL targets demote_walk=1 (OOE-RTL benches/kernels run at it); OI's decq per-entry held + beat-pending design accepted, group free rejected; default flip still on RH's OA 451 price (<=0.5% S1 mine). Controls: free-before-beat, held-issued, flush-drops-held. CG: bits in gated rows or 2%; beat-sent capture waiver = DA. OA 466 (rev 468): RH priced flip (model, 367bc942, mlc): S1 +0.066%, cm32 +0.147%; accepted, effective once cm128priv runs clean (33b2971c CHECK, 05ee3bdb hang) and RH prices it <=0.5%, then OI flips with no further row; >0.5% -> DA. WATCH OI landing row (RTL NGD/CG), cm128 fix; then doc rev for the walk.
- OI-186 demote walk C (streaming, beats unmerged by PC) accepted OA 451; AR 393 accepted contract (FET tab rev 51, no lane in two beats). decq walk port from its flops, out 6 NGD / in 2.0 arrival, flush held; WAITING RH price (<=0.5% S1 mine) and control for an issued held entry; then model defaults beat_merge 0 + demote_walk. Doc rev 398 records it.
- OA 453/454 (DI-4): refill notices off by default, channel kept (model: off -0.43% mean, 64 kernels); off = no refill hints, completion F+6; Phase 2 prefers MLC tag-lookup notice over a lead field (AR 394). DCU tab corrected (MA rev 59). Closed.
- OA 455 (OI-188) credits option A: FET never reseeds; OOE per-warp_id slotless-drop counter (width from share); FET sends nothing between demote and restore. Drain did not cover DEC (3 uops ~940 cycles): OA 457 accepts AR 395 drain by conservation + walk stragglers (straggler credit returns no earlier than its beat; FET migrates on mig + credits full). OA 456 withdrawn. Doc rev 399. WAITING: TI's FET full-credit wait landing; TI/OI combining drain fix on scratch branches.
- OA 460 (rev 462) accepts AR 397, superseding OA 459's mechanism (OA 459 dropped post-drained stragglers unwalked; wrong). TI-502 deadlock (OA 455 A held drop credits vs AR 395 (3) full-credit wait): OOE keeps demoting warp w bound to tier-1 slot t until launch/restore gives t away; stragglers walked on arrival, credit on t no earlier than beat; order full credits -> FET pca_mig -> PCA done -> RAU reassigns. OA 455 A pending counter -> CHECK (uop for unbound warp_id = error), OI bins 64 kernels + kill/exit; any hit back to OA. (b)/(c) refused. WAITING: OI build + controls (binding-ends-at-drained break must fail), MI rerun MI-11 (2); then OOE doc. TI-501 landed e8d8864b, nothing asked. AR 398 crossed (withdrew 397 for 459); OA 461 confirmed both its points; AR 399: OA 460 final, do not re-flip. CLOSED between OA and AR. OA 462 (rev 464) re OI-193: real cause was a demotion cancelling a due squash without its epoch advance (model; fixed oi-71 c461c1b0; due-epoch-lost caught). Binding DROPPED (unreachable under the wait, unprovable): CHECK on uop for released slot/unbound warp_id; OI-194: not caught (wait never binds: credits home before RAU mig, all 32 parking runs same cycles). OA 463 (rev 465): option (b) OOE credit-return delay knob (default 0) so wait binds on MI-11 repro, held-cycles bin > 0, pass with wait / CHECK with mig-before-credits, gated in check-kernel (TI break+scenario). OI-195: built (model), wait binds from lag 8, break caught from 448, scenario lag 512 --cycles 200000; OA 464 accepted. WAITING only TI gating the scenario; then OOE doc 'Resume PCs per group' records the rule (wait is the rule, CHECK on released slot). rob_w RTL: demote/kill slices never gate rd_e; assertion + masking control (OI).
- OA 458 links check: credit crossing + delay >= redirect crossing; TI-494 added CCV_LAT_DECQ_CREDIT_DELAY (0) + require + selftest. Closed.
- TI-490 (DA): RESUMED PASS = full clean gate; after gate-wait 'killed', rerun same command with CCV_RESUME=1 (once 6464a030 lands).
- TI-487 (B) machine-check fatal retired store: FINAL = option (3) (AR 387; MA accepted, withdrew (1)); OA 441 (rev 443) confirms for OOE: RAU waits for no acks after MACHINE_CHECK, OOE unchanged (still quiesces/acks), V-57 trivial. OA 440 (agreed (1)) replaced; OI-174 confirmed no post-retire store state anyway. MA edits DCU tab. Nothing open for OA.
- #61 (OA 427 opt 2, ckpt_free_lag 1) landed at b91632b4 (OI-175, OI rev 379): within the ruling, no row; OOE doc rev 390 'No stale frees' paragraph records it (OOE releases its own checkpoint at resolution; only the FET send lags; held frees withdrawn on squash; mispredicting slot keeps older held frees a cycle).
- OI-176 ooe_slot built (fd194677, oi-slot, unpushed): OA 443 (rev 445) set al_*/dm_*/kill_mask/kill_ep arrival 2.0 (OI writes by:OA entries; dm_* needs rob_w outs <=2.0); extra verdict cycle (map/drained/release/kill_ack +1): OI to add slot_verdict_lag knob + control and price S1/cm32priv/cm128priv; <=0.5% S1 -> OA absorbs in one line; over -> DA with combinational option. WAITING on OI.
- DA 128 (MA-23): L1_HIT 9 waypred off / 8 on. OA 444 (rev 446): OOE contracts unchanged (WAKE/CMPL derive from L1_HIT); OI makes ooe_wake LAT_SPEC/LAT_MISS defaults come from ccv_params_pkg (replaces OA 439's hand move), units at both settings. WAITING on OI; doc As-applied when TI lands the param (MA-26).
- DI-2 (way mispredict at due+2 on the half-rate bank): OA 442 (rev 444) agrees with MA's default and AR 390: loser's path, TI-478 slot stays due+1, OOE unchanged; supersedes OA 439's due+1 sentence. Notified MA. Nothing open for OA.
- MA-26 / DA rev 128 -> OA 439 (rev 441, 11-19): L1_HIT 7->8 (way pred on; 9 off) => derived L1_WAKE 14, L1_CMPL 16. NOHIT margin gains; way mispredict = late hit at due+1, existing miss path. OI moves ooe_wake defaults LAT_SPEC 14 / LAT_MISS 17 and re-measures. Watch TI landing the param; then OOE doc As-applied paragraph to 14/16.
- TI-485 (5) FINAL = OA 436 (rev 438), confirmed by OA 438 (rev 440). History: AR 383 / OI-172 crossed OA 436; OA 437 (rev 439) took AR 383's form, but AR had already withdrawn it (AR 384, then AR 385: OA 436 final; FET spec rev 49 resets checkpoints on OOE's epoch_only notice, kill_ack after it). OI-173 confirmed the model (no pass after a kill, ack after the in-flight A3, no free after the notice; ooe_redir masks ckf in #65). MA accepted 436 (MIU tab rev 140), then 437 (rev 141), then marked it pending (rev 142, leans 437). OA told MA: AR 385 + OA 438 name 436; MA restores rev 140, or raises its own row to DA. OA WILL NOT SWITCH AGAIN without a DA ruling. TI-487 (TI rev 486): landed in MIU+FET stubs 663bed37, controls kill-drop-atomic and fet-reset-on-kill, 4 kernels back in MC runs. Watch only: MA restores the MIU tab to rev 140's rule.
- OI-171 -> OA 435 (rev 437, 11-18): ccv_ooe split, every module before the top (DA). New ooe_slot (residency, alloc decode, demote/drain/restore/kill seq, rau_status, drained/kill ack, cru_fault merge + cta_slot/warp_id, barrier hold on syu_rel); new ooe_redir (fet_redirect from rob_w mispredicts + slot epoch_only + decrx epoch, decrx advance, per-warp notice-landed pulse A-74/V-57, ckpt_free OR); epochs stay in decrx (OA 428); new ooe_rcupl (2), ooe_mempl (3); (4) decq credit; (6)(7) rob_w slices 5/6 head side only; (8) rcu_map in ooe_rat. Order holds, (5) split 5a (mispredict, in place) / 5b (epoch_only, with (7)). OA sets new modules' boundary budgets; OI proposes in landing rows. Doc rev 385 hierarchy table; update Status column as pieces land. Notified OI.
- OA 415/416 (revs 417-418, 11-15, re TI-437, AR 353/354, MA 55): no-hit under PF-47. AR 354 derives CCV_LAT_L1_NOHIT from the address's arrival + A2 + launch + crossing (superseding OA 415's L1_WAKE-5 form): payload I+9 at wake 13. OOE margin measured in the model (l1-nohit, rx_lag 16): the payload by L1_WAKE-2 passes, at L1_WAKE-1 it replays, so require NOHIT+2 <= L1_WAKE is final. Nothing in OOE hard-codes I+13; only ooe_test.cpp t+12. TI landed NOHIT at bd1cc5a2 (TI-439); MA rev 56 confirmed; OOE doc rev 383 has the derived form. Watch: OI unpins testL1NoHit and adds the L1_WAKE-1 control.
- Sweep 11-14: 8 branches (209 commits) pushed abd2a025 UNGATED (old daily-sweep + new detaching make-release; OA 414, rev 416). Full clean gate run after: PASS. No release cut (ccr-126afa13 gained a commit); next sweep cuts it. TI fixed: 518cb3c3, a detached tool exits 5.
- OI-143: RH's on-vs-off price for cand_indep_pend is identical in all 36 runs because sectioned=0 (placePos returns early); OA 407's 0.5% test passes only vacuously. The real price waits on sectioned=1 (OI-32); OI will ask RH then (~9 h cm128).
- OI-142: l1_nohit model built (off by default); no price until MA Phase 1's stub sends no-hits.
- OA 413 (rev 415, 11-13): signed OI-141's CCV-L23 feedback entry for cok_nx_cq02h (offset 2, loop cok/cokd/ccnt) and chas_cq03h arrival 4.0 (OI-53). Watch OI push ef19544c; the flag rule goes into the OOE doc's memop paragraph.
-24. OA 387 re:RA 104/AR 325 (zero-cycle ooe_rcu_issue leads): YES on OOE side. pred_neg(+(a) bits),
   R-slot phys_src0/1 (slot_fields), opcode (not class bits, A-66) move iss_pay -> iss_lead in ooe_rs;
   no cycle, 0 net flops, out 0. RTL ooe_rs unit: gnt in 8.8/9.5/10.2 at LW 1/16/43; f-f 26.2/26.3/27.4
   (17.6 w/o fanout) < cap 29.4. Watch: RA names (a) bits + approves; TI schema row; OI moves fields,
   sets unit LW real; RH reprices g1'' (expect -3.48% S1, model). OOE doc rev 370 notes it.
   OA 388 re:RA 108: (a) = no new field; guard leads zero on S/P today -> fill every slot (drop
   slot_fields); + lead_rpsrc=imm[13:0] (R). Moved (0 OOE flops) or copied (<=167) per field, RA picks.
   R lead read ~55b > 43 run: few tenths more fanout, OI re-measures. Approval waits on RI.
   RA 109 picked: MOVED guard (all slots; phys_pred_guard leaves payload), rpsrc, phys_src (R);
   COPIED opcode (rides on to lanes/MIU) = +81 OOE flops in iss_lead. Accepted (no row needed).
   RA 111/RI 45: 14 RCU in-paths still >12 (worst lanes dst 20.7); RA asks dst/write fields, cont,
   pred_neg, R imm[31:14] as copies. OA 390: clean, 225 flops (+120 for odst/opos/spos/src on S0-S3),
   0 out, RTL unit LW 63/111: gnt 10.2, f-f 26.8/26.2. Now rests on RI re-run; else RA->AR->DA.
   RA 113: APPROVED zero-cycle issue end under DA 115 (RI worst in-path 10.9). OA 391: copies 353
   (src_pos 6) + opcode 81. Watch: TI schema row, OI build + unit LW + check-ngd, RH g1'' reprice.
   TI 382: built RA-43 on ti-ra43 (d1c65ef; KILL_DRAIN 15, L1_CMPL 18, credit 4), edits sim/ooe+rcu.
   OA 392: keep imm in R payload (copy); S copies 46 fine, src_width only if RI >12 (RA); ~504 flops.
   RA 114 overruled: S copies 32 (no src_width/phys_src2), R imm MOVED to lead_rpsrc[31:0]. Checked:
   nothing in OOE reads R's payload imm after grant (iss_pay -> channel only; tests read Issue struct)
   -> no objection, no row. OOE copies now ~ 207+81+128 = 416.
   OA 393 re:TI 383: R imm settled = move (RA 114), OA 392 withdrawn. C_RECONV = rename-time no-op,
   DEC serial 5 (first spare), done at alloc, no RS/issue; skel op table + control; OI model+RTL nop.
   OA 396: register PMOV EXECUTED on R as plog (imm_kind 1, ps1=ps0), not elided (compiler emits none,
   copies w/ por; elision needs phys-pred refcount, only full-mask/unguarded/unneg). RA 119 confirmed;
   TI built 8dbc152. Reopen only if compiler emits pmov. RA-16 has nothing of OA's.
   OA 397: OI-135 pp_cq01h (rename R1 d_pp_cq03h -> ooe_rendep) arrival 2.0 granted, as OI-66; conditions: keep-copy for port vs m_pp_cq04h, fanout counted in rendep; watch OI push for rendep worst path and caps removed.
   OA 398 re:TI J11b (rev 390, model, clean): g2''' S1 -0.26% cm128 +1.27% (RA's, DA 115); p192' (OOE cmpl/hint flopped) S1 +2.44% cm128 +5.10% loop +71% -> C9 worth more at 8-way. Asked TI/RH for C9 A6 point at 8-way vs w10''': <0.2 close, 0.2-0.5 DA, >0.5 DA.
   OA 399 re:TI J13 (rev 392, model): C9 STANDS at 8-way, no return to DA. Bar = flopped-vs-0cyc gain = 2.44% S1 (p192'); J13 C9-vs-A6 +0.174% S1 / cm128 +0.459% / loop +3.33% is split cost, not the bar (OA 398 framing corrected). Open: reprice cmpl_split (OA's, <0.5%) after lead build; DA 8/13 rerun term still owed if OI has not run it.
   OA 400 re:RA 126 (RI-25 (4) kill wake): OOE does not drive kill_valid (RAU does, schema from: rau); early kill wake only possible from RAU flops, RAU owner/TI call; OOE no objection, would not use it.
   OA 401 re:AR 337 (RI-26, rcu_isd class decode 12.4 vs 12): OOE declares required 0.0 on iss_lead_cq03h (output-only, no keep) in ooe_rs.ngd.json + up to ccv_ooe; OOE recs (a) RCU in-side 13 (AR to DA, pending). (b) lead_pcopy would cost 45+9 flops. DA 116 (11-09) chose 13/0 and kept miu_rcu_data@rcu flopped (AR 334); OA 401 is the confirmation. Watch OI write the decl.
   OA 402 re:TI 396: TI built per-field lead budgets (ti-lead). OI writes ccv_ooe.ngd.json ooe_rcu_issue_payload.{lead_opcode,lead_done_row,lead_pred_we,lead_phys_dst} required 0.0 + ooe_rs iss_lead_cq03h required 0.0 (packed, no carries).
   OA 403 re:RA 132 (RI-31): (a) lead_phys_src2 copy on S0-S3, 32 iss_en flops, 0 out, payload kept (lead copies ~448 total); (b) lead_sec_mask EXACT == footprint (lead slots), 0 on cont; TI built it 7b003e98 (TI 400, lead_why amended).
   OA 404 re:OI-134 (2ff049c7): go reads registered unmet (unmet_reg=1, RTL), cm128 -2.2% vs G at 160/128 (model), c_dst cap back 26.9 (DA 27.5 unused); recorded OOE doc rev 374 floor invariant. OI-134 closed.
   OA 405 (sweep 11-09): skipped ccr-80102643 (AR) + ccr-888218a3 (RI), perf-register/cg-waivers/rcu_dec_pkg conflicts vs TI; TI merged both 0bd5ac02 (TI 401). Next sweep picks it up.
   OA 406 (re:AR 340, DA 117): MA at sweep minute 35 in register skill section 5 (453db334). Notified AR.
   OA 407 (re:OI-137, #35): cand_indep_pend (pending-group writer unseen in narrow placement) accepted if RH prices on/off within 0.5% S1/cm32/cm128 (model); over -> DA. OOE doc rev 376 Placement para. WATCH: RH figures on OI-137.
   OA 408/409 (re:MA-4, MA-5): L1-hit contract view unchanged (cancel shadow 17->19, 1 hop/cycle; asked MA for early no-hit by issue+16 = PF-8 subset); every memop spends a credit, issue does not yet throttle (stub returns on take); entry credits need depth 8/slot or pool (TI), discard credit back on take, OI to gate P grant. WATCH MA/AR answers.
   OA 410/411 (re:MA answers): no_hit[1] on ccv_miu_ooe_cmpl_hint accepted, raised with TI (advice; valid I+12, payload I+13; clears spec wake before I+17; OI knob l1_nohit, RH to price). OOE supports MA shared memop pool (40 entries, 3-bit rate-1 return sideband; per-slot credits stay 4 on take); OOE gate = registered allowance (>=4: up to 4, 1-3: one, 0: none) ~1 NGD. AR to rule pool. TI prefers per-slot 8 (TI rev 411) - pending AR.
   OA 412 (re:AR rev 345, MA-5 RULED): per-slot memop credits 10/slot, NO pool (supersedes OA 411); OOE sends on lowest credited slot of footprint (not ctz(res)); grant request += (footprint & credit_held)!=0 ~2 NGD; slot choice in payload cycle. WATCH: OI model+NGD (if >25, AR takes pool); MA confirm memop slot j pairs with addr slot ctz(footprint); TI schema text, depth 10. Then OOE doc select text. SETTLED: AR 346 (pool) withdrawn by AR 347, AR 345 stands as OA 412 takes it; MA confirmed pairing (~3 NGD MIU side, MA rev 44). CLOSED: OI-139 select worst path unchanged (26.58 ff, res 28.86), pool not needed; TI schema on ti-ma (credits 10, no_hit); OOE doc rev 377 memop paragraph records credits + no_hit. Still WATCH: OI model no_hit + RH price.
   RI session: session_01QPk2jvvXPLs4m8ZQbSk1g6 (roster). RI-34 (11-10): ccv_rcu.sv block top pushed 8fcec64b, per-slot issue ports; no action.
   REGISTER CELL SHAPE: a cell must be {"type":"cell","content":[{"type":"paragraph","content":[{"type":"text","text":"..",("marks":[{"type":"bold"}])}]}]}; a string content is silently dropped (OA 397-404 went in blank, refilled rev 408). Read every row back after insert.
   DISK: a full gate needs ~23 GB free; ccache capped at 2G (ccache -M 2G) after 11-09 filled the disk.
-23. CLOSED (OA 395): OI-133 fix 5559b4f/b90adff/11386e7 accepted, rope cleared (TI 387). Was OA 386 re:OI-133 (OA-17 at L1_WAKE 16: co-grant w/ re-issued producer): YES to replaying a
   consumer co-granted with its producer (always stale). First check ooe_sched RTL (rep_cq02h uses
   pre-grant iss_cq02h, may already catch it) -> if so model-only fix; else add gnt to mask within caps.
   Sweep L1_WAKE 12-20, control drops term; >1-cycle window back to OA. J11 unpriced till lands.
-22. OA 384 re:TI J11 (RH, 8-way DCU, 88c31e7, model): Z S1 -2.47% (was -1.04); ISSUE FLOP at RCU
   costs S1 +3.48%/cm32 +1.98% -> AR 308 premise gone; RA's under DA 115 (NGD w/o flop) else DA; no
   OOE objection. g2'' (miu_rcu_data 0-cyc, L1_WAKE 16) fails OA-17 (stale grant confirms) = OI model
   bug (a timing term not derived from L1_WAKE); cm figures void till fixed. C9 re-price at 8-way owed;
   <=0.5% -> DA (DA 114 term). Watch: OI root cause, RA ruling, C9 re-price.
   AR 323/324 reopened AR 308; OA 385: OOE side 0 NGD out (t+2 reg, OI-131), split 0/12 -> RCU in<=12
   RA approves, >12 DA (OA signs OOE half). OI: issue-port check-ngd unit when payload assembled.
-21. OA 383 re:OI-130 (95bf04d): OI-114 went (b); floor_held_gate fixes fits_stale double floor.
   OA 394 re:OI-134 (RH, model): G S1 = everywhere; cm128 G=B@192, -1.57%@160, +2.75%@128 (redirect_wait);
   N fails fits_stale. KEPT G, closed. Low-pri OI look at 128 (derived floor_take_lag / unmet_reg).
   ooe_go caps all fell (NGD-1 26.x, hv 28.x), stand; no share retime. TI #72 rerun must be clean.
-20. OA 381 re:OI-128: ROB slice 4 pushed adfa301, flops ACCEPTED (rob_w 5,395->8,275; cmcap 61->465);
   optional fa one-hot->5b index (-108). Slice 4 done; next ROB slices.
-19. TI-373: DCU stub default now 8x64 (31168a3): perf baselines moved. Any pricing OA judges
   (OI-114 (b), PHYS 160, C9 reruns) must compare runs on the same side of 31168a3; never mix.
-18. OA 380 re:TI IS-21 OOE's side: CAS pd rides A2 (renamed pd, pred_we, old pd, every pass; OI
   model, RI step table; no field change). A1/A3 never bulk-discarded nor replayed (status 0/1):
   OI-129 model f727aed; OA 382: copy also writes pd (A-43) ok, status-2 assert ok; RTL issue payload
   later must carry A2's pd/pred_we/old pd. TI 366: DONE - pd rides DEC 2nd slot; schema text: mem_op 2/3 exempt, status never 2. OI-127 agrees.
-17. OA 378 re:AR 315 PHYS_REGS 160 (Q-35; ~34k RCU flops, cycles flat, provisional): rerun to report
   floor stalls (OI-114), restore-alloc under demotion, sectioned-row fragmentation, memop-held regs
   (cm128). No stalls -> no OA objection, to DA on area; else OA gives min PHYS. AR 316 took the
   four cases as criteria; TI 360: 160 has 18 fits_stale check fails (OI fix), provisional.
-16. OA 376 re:OI-125 (slice 4 MIU fault capture CG): asked lead_fault (1b, with cv) on
   ccv_miu_ooe_cmpl -> AR confirm MIU knows fault at valid, TI schema row. No CG-3 waiver (b, 408
   flops, DA) unless (a) impossible. AR 314: yes; per-slot (4b), status==1 only (2=replay); MIU
   spec 61. OA 377 accepted. TI pushed lead_fault 5a2f4aa (TI 363). OA 379: OI-125 items 5-6: pc/cause/
   valid written at ALLOCATION (OA 370 amended); per-entry group mask 1,024/slot built (spec IS-4).
   ROB payload ~2,294 flops/slot. Watch OI's build.
-15. OA 370 re:OI-117 (ROB slice 4 fault PC): (b) per-entry PC, per spec (IS-4, payload table;
   rewind beats need every entry's PC). pc[31:1]/entry + pc[47:32]/slot (CCV_W_PC_WINDOW) = 4,032
   flops, written at fill from ccv_dec_ooe_uop.pc, assert upper match. No schema row, no S1 cost.
   Watch OI's flops + head-read depth.
-14. OA 369 re:OI-116 (OI-114 go form): (a) raise ooe_go caps REFUSED (ratchet falls; room_g 25.4,
   unmet_g 29.9 >25 = DA rule); rename has no slack. (c) first: go's unmet arrival budget 0 + keep
   copies of unmet flops (fanout); if caps hold -> push, no S1 cost. Else (b): per-take term
   registered a cycle late, RH prices S1 w/ PHYS160; <0.5% mine, >0.5% DA. OI branch oi-floor114 1f3bb3c.
-13. OA 365/366: zero-cycle ooe_rcu_issue -> AR 308: stays flopped, no splits (gain only
   L1_CMPL -1, V-35 -1; L1_WAKE does NOT move - my 365 claim wrong). OI phys_src depth DONE (OI-131: 0 NGD after flop, out budget 0)
   prio. OA 364: C9 ports must be 0 NGD, <=4 pins (sum of parts boundary); OOE units per param set.
   AR 307 took C9 to DA in AR's session (+0.444% holds only with AR 296; lane cycle hits both).
-12. C9 APPROVED by DA (DA tab 114, 11-06): OOE miu_ooe_cmpl+hint ends first kind, +0.444% S1
   over A6 (model; cm128 -0.45%, cm32 -0.08%); flopped H3+P ~+1.95%, gain ~1.5%. OA 368: hold
   released; OI builds under OA 364 terms (0 NGD, <=4 pins), TI adds links.json no_flop; OOE doc 367.
   RA 95 (TI 357: applied f4ce0fd, full gate PASS): lane_rcu_res zero-cycle (S1 -1.04%) -> LANE 7/SFU 12 = C9's baseline; OA 371
   keeps DA's 8/13 rerun term as written (DA's, not ours to drop).
   OI-118/OA 372: 8/13 rerun DONE: C9 +0.370% vs F +1.581%, gain 1.21% -> STANDS (term met).
   Build C9h (hint raw, no bypass, 0 S1) + RS bypass (worth 0.56%); RTL == model C9h cycle-exact;
   cmpl_l raw -> capture+RS+wake (3 pins), ROB x4 from keep copies of cm_q. Watch caps/flops.
   OI-120/OA 373: C9h built (oi-c9, exact). cmpl_idx_cq00h arrival 2 GRANTED. prv_code_cq01h 25.7
   fanout cap REFUSED (ratchet; remap noise): (a) keep copies (b) arrival 9->8 if sender slack
   (c) only then to DA. OI-121: (a) missed 25.9; OA 374 took (b): rs arrival 8 (24.7), rendep out 8
   (0.0 measured). OI-122/OA 375: wake timer enable 8.1 -> grant_cq01h arrival 2->1, sched grant_w
   out 1 (0.0 meas). C9h released to push; watch OI's commit + rs depths.
   (was) LAPSES if OI's LANE 8/SFU 13 rerun puts the gain at <=0.5% S1 -> back to DA. Watch for it.
   Bar (DA verbatim 11-06): "Bring to me between 0.2 and 0.5 percent impact.  Also come to me if
   we cannot meet the default module boundary NGD rule without the receiver flop". AR's reading:
   gain <=0.2% stays flopped; 0.2-0.5% DA; >0.5% owning architect; needs-flop-for-12-NGD -> DA.
   DA 115 (AR recorded in DA's session), DA verbatim: "Yes, over 0.5% the architect can approve,
   if we also meet the NGD module rules". TI 354: OOE's own no_flop entry (cmpl+hint only) lands
   with ccv_ooe's RTL top; until then OOE stays in the DPI all-list (no crossing moves).
   R49 dropped (S1 +0.276% cost); ooe_rs stays 45 rows, 26.2 on cap.
-11. DONE 11-06 (installed, --check ok). DA APPROVED in OA's session 11-06, verbatim "I approve the token limit" (DA tab 112):
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
