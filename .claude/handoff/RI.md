# RI handoff (RCU implementation)

Updated 2026-11-13. Keep current at every task's end. Role and ownership:
docs/rcu-impl.md (RA's handoff, section 1). Spec: docs/design-snapshots/rcu-arch-*.md
(live doc https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB wins).

## Who and setup
- RI = session_01QPk2jvvXPLs4m8ZQbSk1g6 (roster commit 187048a). Register tab RI node
  8e4547bc-c469; write only there. Daniel (DA) is a senior microprocessor design engineer.
- session-home installed (Daniel OK'd 2026-11-04, re-run 2026-11-06 after the merge: 350k window);
  --check matches.
- Daily sweep scheduled task trig_01YVAyULgv3K9NymwVJXZybD, 02:31 America/Los_Angeles.
- Toolchain: ./tools/setup-toolchain.sh (log ~/ccv-logs/setup-toolchain.log).

## Repos, branches, push
- Work trees: /home/user/ri-wt2 (ri-asm2, assembly), ri-wt4 (ri-sweep, pushed); compiler repo read only.
- Push: tools/gate-push.sh with CCV_PUSH_BRANCHES=ccr-888218a3-20cauz. Merge commits only.
  No PRs. No model ids in commits/code. Name commits for TI to merge in the RI tab.
- Last push: 8fcec64b (2026-11-10, SPLIT PASS 23/23, chain-ri17b, branch ri-asm4 in ri-wt7): ccv_rcu.sv
  (kill detector in the top, CG unit ccv_rcu, per-slot ngd.json), TI's 079b64c2 and the daily sweep merges.
  RI-34 (RI tab rev 68) written; notices sent to TI (merge 8fcec64b), RA, AR, OA, OI.
- Previous push: ff5ddcca (2026-11-08, SPLIT PASS 23/23, chain-ri10): daily sweep merges (all remote
  branches but OI's ccr-57eff422, aborted on a sim/ooe conflict), ri-sfu (SW from sfu_result, RA 120/124),
  lanes pcm_n_cr04h floors re-based 49/65. Before: 5ac616f (2026-11-07, SPLIT SCOPED PASS 22/22): TI's de03fd6 bundle (O-85, IS-21 atomics,
  #88 fix) and 31168a3 (stub DCU 8x64: rebaseline cycle counts) merged on 64fce0d (RA rev 98).
  Before: ba0df94 (lanes+mem). Before: 350729e (SPLIT SCOPED PASS, 2026-11-07): rcu_mig, slice zero-fill gate, lint
  fixes, TI's Z (f4ce0fd) and RI-18 (43695ae) merged, model --break ret-held-by-lanes.
- RH (session_01QPk2jvfKM1V5rRfip8FC86) takes RI's perf runs (Daniel, 2026-11-06): send base
  commit via gate-scratch/RI, exact arms and what to report; it replies with a table.

## Working rules beyond CLAUDE.md
- Container gets reclaimed when idle: keep a run_in_background until-loop waiter on any
  detached job (setsid nohup ... & disown). Restarts killed runs 3 times and lost commits once.
- Send every unverified commit to gate-scratch/RI (tools/gate-scratch.sh) before gating.
- Split gate: cg part with CCV_JOBS=1 (OOM at 15 GB otherwise), ngd part CCV_JOBS=2, each
  gate-export, then gate-push --import=a.tgz,b.tgz. Chain script pattern ~/ccv-logs/chain-269efe6.sh.
- TI owns schema/params/tools/stub/kernel.cpp. rcu_block.cpp uses ci.stages + ci.bnd_rx.
- Model events: rcu::Ev packed to schema ids in rcu_block.cpp event(); docs/rcu-model.md.

## Rulings (Daniel, 2026-11-06)
- RI-15 = (c): module-level CG-5 waivers for interface leads, `"lead": true`, each flop charged
  to the RCU block's 2% (RA rev 87, DA rev 109). Credit pulses `"credit": true` (RA rev 88, DA 110).
  Block limit = sum of parts (DA 111/112, TI-51); RCU top still a stub, so checked at assembly.
- Zero-cycle receiving ends only if IPC justifies; lane_rcu_res stays flopped; RI-16 runs decide (RA 91).

## Register
Bookmarks 2026-11-09 (notices): Conventions 17, AR 336, OA 379, IS 190, TI 395, OI 324, CP 155, DA 115, RA 130, RI 63. (DA 116, TI 396, AR 337)
DA 114/115 bar for zero-cycle rx ends (S1 gain): <=0.2% stays flopped; 0.2-0.5% Daniel; >0.5%
architect may approve only if the end meets module NGD without the flop; can't meet 12 NGD -> Daniel.

## Open work, most urgent first
-7. NOW (2026-11-13 ~14:00) Pushed 7e29cef5 (SPLIT PASS 24/24, full; cg here chain-ri24, ngd RH):
   daily sweep merges of all 9 remote branches + evmon e9c48768 + CCV-L04 fix 439179d9. rcu_ls (TI's gate job
   = run-lockstep.sh + rcu-ls-corrupt.py) passed with event compare. RI-39 (RA: SHFL_*_R bug, xbar one-hot sel,
   amend Crossbar) and RI-40 (TI: re 415/418) written, RI tab rev 71, notices sent to RA and TI.
   Bookmarks: Conv 19 AR 348 OA 414 IS 193 TI 419 OI 341 CP 157 DA 119 RA 136 RI 71 MA 46.
   Fri pings 2026-11-13: pongs checked ok from AR OA IS TI CP RA MA RH; OI no pong yet (check next sweep).
   NEXT task 16: (a) model: Stub::creditAtLanding(c.ooe_rcu)/(c.lane_rcu) in first work(), take() in landing
   cycle; lockstep --credit-lead default 0; rerun 63 kernels. (b) drop ccv_rcu wake detector (AR 343 hold in
   ccv_common_clk), CG/NGD units, lockstep. (c) SV-top with RTL (CCV_RCU_RTL in check-sv-hosted.sh, TI's).
   (d) Q-53 checkers. Gate: setsid nohup + kill -0 watcher; tools/gate-wait.sh when TI lands it.
-4. (2026-11-13) Last push 0ace219f (sweep, below); before it fca280c3 (13:29, SPLIT SCOPED PASS 14/23; ngd leg by RH, Daniel OK'd RH
   send-export to gate-scratch/*-export for passing legs). RI-36 (TI), RI-37 (RA), RI-38 (TI, AR) written,
   RI tab rev 70; notices sent. Lock-step 63/63; rcu_blk (TI) passes with its expected-fail.
   Sweep pushed: 0ace219f (2026-11-13 02:10, SPLIT PASS 24/24; cg here chain-ri21, ngd RH via
   gate-scratch/RI-export) = bfba7f38 sweep merges + 126afa13. Two container restarts on 11-12 killed
   chain-ri20 and the first chain-ri21 run: relaunch detached and re-arm the waiter after any restart.
   OA ping 2026-11-13 answered with pong (me=ok).
   AR 343 (re:RI-38): ccv_common_clk WAKE_HOLD -> CCV_WAKE_LAT+1 (TI); then ccv_rcu's wake detector may go (RI's call).
   TI 407: run-lockstep.sh becomes the gate job, rcu_blk retired, channel.h landing-cycle credit coming.
   Bookmarks Conv 19 AR 343 OA 411 IS 190 TI 407 OI 338 CP 157 DA 119 RA 136 RI 70 (MA tab: no bookmark yet).
   Long runs: ALWAYS setsid nohup + a waiter; a bg task dies at 2h.
   Next for task 16: model credit move once TI adds channel.h call; RTL event monitor; SV-top with RTL.
-3. NOW (2026-11-09; Daniel's order: class-word NGD -> gate+push ccv_rcu.sv -> lock-step/SV-top -> Q-53 ->
   SW write-back + KILL_DRAIN -> RA reconciliation + Daniel's sign-off). ri-wt7 branch ri-asm3, tip d0076837
   (on gate-scratch/RI): d33d8c70 AR 338/339 kill boundary flops (plain ungated detector flops; rcu_kill epoch at
   K+1 under kvd_cr02h; rcu_mig reads detector mask; kmn waiver gone; killsleep 17/17/17); 905d92bc RA 131 (1)
   rcu_isd lead copies (LS param, unit rcu_isd_s, isd_tb control xfree); d0076837 lanes cont copy, mig kmn arrival,
   one rcu_isd waiver. run-rtl green, units + policy clean (~/ccv-logs/chk9*). RI-31 (rev 65) to RA/TI/AR:
   block read S0-S3 14.1 = lanes src_cr02h 12.7 (phys_src2 payload-only) +1.4 -> asked lead_phys_src2;
   S4-S7 12.8 = K3 slice pfoot 11.4+1.4 -> asked if lead_sec_mask == footprint (then precompute P owner in A-1
   like sk_cr01h); lop 12.4 waits TI ti-lead carries (DA 116: 13).
   Per-field block breakdown: scratchpad blk_ngd_dbg.py + dbgtools/ (debug copy of check-ngd), log ~/ccv-logs/blk-dbg.log;
   per-port unit depth: scratchpad portdepth.py <map.blif> [min] [bits] (TRACE=<bit> prints path).
   NEXT: RA 131 (3) push the module refactor WITHOUT ccv_rcu.sv (hold it and the killsleep bench out of the push
   variant; check-1d, regen, split gate cg CCV_JOBS=1 / ngd CCV_JOBS=2, gate-export, gate-push --import).
   scratchpad asm/verify4.sh = check-1d + top Icarus/Verilator + phantom (verify4.out).
   RA 132: kill + copies accepted; (a) lead_phys_src2 S0-S3 approved RCU side, waits OA+TI schema -> then rcu_isd_s
   captures it (lanes src row 2 from copy); (b) HOLD slice change until OA says lead_sec_mask exact: if yes precompute
   P owner in A-1 + assert equality + extra-bit control; if no, lead_footprint copy. TI 398: per-field keys ~07:15Z.
   2026-11-09 08:50: TI 7b003e98 merged (7ae432df); 2f8bdee6 rcu_isd_s captures lead_phys_src2 (XW 42), lanes row 2
   from copy, model refuses lead_sec wider than foot (controls leadsec-wide/narrow). chk11 ALL CLEAN incl. BLOCK READ
   (no findings) -> ccv_rcu.sv goes in (RA 133). chain-ri13 (push variant) KILLED; chain-ri14 gates ri-asm3 WITH
   ccv_rcu.sv from ri-wt7 (~/ccv-logs/chain-ri14.out). Don't edit ri-wt7 tracked files while it runs. ri-push12 obsolete.
   After push: RI-33 to RA/TI/AR (block in, commit for TI to merge); then lock-step/SV-top (task 16).
   2026-11-09 PM: chain-ri14 CG failed (ccv_rcu flops, no unit; K3 slice idle DCGE) -> 41881d6d rcu_kdet + mv=|pk
   (slice clean). rcu_kdet was WRONG: CCV-L22 allows the ungated wake detector only in a block top, and killsleep
   controls poke ccv_rcu__DOT__kill_detect_v_cr01h. 5c015405 detector back in ccv_rcu (ep/km under kd_en = the valid
   flop, CG-5), unit ccv_rcu in test/rcu/cg-units.json (children black boxes, bench killsleep_tb --cg; 34 in 1 gate,
   DCGE 100%). check-cg's harness reads only the black boxes' files, so the unit also lists ccv_params_pkg,
   rcu_dec_pkg, rcu_xbar, ccv_common_ctech_icg as black boxes (1ab94146, c9a310f8) -- tell TI in RI-33 (a tools fix
   would be cleaner). chain-ri15 NGD-4: ccv_rcu.ngd.json keys must be per slot (0339f719, s0..s8). chain-ri16 on 0339f719: check-1d, cg,
   ngd PASS (exports ~/ccv-logs/gate-{cg,ngd}-ri16.tgz); gate-push FAILED on 3 TI fixtures assuming RCU is DPI
   (gate-scope.py:211 wrapper reader; check-links.sh:86 control; test/phys/links_split.json rcu "all") -> RI-33 (rev 67)
   to TI, cc RA/AR, notices sent. NEXT: wait TI's fix commit; merge it + TI 0bd5ac02 (OA-405) + sweep branches into
   ri-asm3, re-gate (chain-ri17), push. Bookmark RI tab rev 67.
   2026-11-09 22:50Z TI 403: 079b64c2 PUSHED (ccv_rcu.sv in the design, on TI's ccr-183cc441). Merged into ri-asm4 (8fcec64b,
   RA.md from RA's branch). chain-ri17 (~/ccv-logs/chain-ri17.out) gates ri-asm4 full split, pushes to our branch. NEXT after
   push: RI-34 with RA 134 figures + sweep report (RA/TI/AR notices); remove ccv_rcu unit's package black boxes if TI's
   check-cg.py harness change reads them (check); then task 16 lock-step/SV-top.
   2026-11-10: PUSHED 8fcec64b; RI-34 + notices done. TI's 079b64c2 check-cg.py change is build cleanup only, so the
   unit's black boxes stay. A subagent computes per-slot-group block NGD figures (scratchpad ngdfig/). NEXT: RI-35
   to RA with that table (cc TI/AR), then task 16, Q-53 checkers, SW write-back/KILL_DRAIN, RA reconciliation.
   RI-35 (rev 69) written: per-slot NGD table (worst lead_opcode 24.4; miu_rcu_data end must stay flopped);
   notices sent to RA, TI and AR. NEXT: task 16 (lock-step/SV-top), Q-53 checkers. Bookmarks: TI 403, RA 134, RI 69.
   TI 402 (re:RI-33): fixes on gate-scratch/TI-rcutop 079b64c2 (0339f719 merged; gate-scope, links control, split,
   check-cg.py); TI gates + pushes ~23:30Z after the sweep's release gate. ri-asm4 (ri-wt7) = ri-asm3 + 7 sweep
   merges (TI 0bd5ac02 incl.; cg-waivers ours, perf-register TI's), regen+check-1d run ~/ccv-logs/asm4a.log.
   NEXT: when TI pushes, merge TI's pushed commit into ri-asm4, full split gate, push; then RA 134 figures
   (CG: 2703 of 4949.4 used, 825 lead/credit; rev 123 slice waiver gone; NGD per slot group via blk_ngd_dbg.py).
   RA 134 (re:RI-33): detector accepted. After ccv_rcu.sv lands, post in RI tab for the spec's NGD table: block read
   numbers per slot group (the 13 fields, other ports), lead waiver total, 2% use, whether rev 123's slice waiver is gone.
   chain-ri12 FAILED cg: rcu_kill cr_q/kd/kaep had no waivers (d7925bc2 dropped them on scratchpad cgpol.py, which
   is BROKEN: it measures no rcu_kill findings; do not trust it, use the gate's cg log). Restored in both trees
   (ri-asm3 222a3010, ri-push12 41a4fd05, identical file). chain-ri13 (cg at CCV_JOBS=2) running: ~/ccv-logs/chain-ri13.out.
   OLD: chain-ri12 in /home/user/ri-wt8 (branch ri-push12 = ri-asm3 minus ccv_rcu.sv/killsleep/rcu_top unit),
   ~/ccv-logs/chain-ri12.out; it sends gate-scratch/RI itself (don't send from ri-wt7 meanwhile).
   RA 133 (OA 403: lead_sec_mask exact on lead slots; OA's own row text blank, RA paraphrase): DONE ea6d5a39 (local,
   ri-wt7): slice pk_cr01h P owner from plcont/plsec at A-1, assert p_lead_is_footprint, bench exact P leads, control
   psecX (run-rtl greps the assert). Checks: ~/ccv-logs/chk10.sh/.log (run-rtl, slice ngd x4, block read, slice cg x4).
   lead_phys_src2 (S0-S3, 32 iss_en flops OOE side) approved; waits TI schema -> rcu_isd_s XW+8, lanes src row 2.
   chk10 all clean (run-rtl, slice ngd/cg x4). Merged TI 4d6065fd (cd68ff7b) + ccv_rcu.ngd.json lead arrivals (b735c0f1):
   block read (~/ccv-logs/blk-ngd8r.*) S4-S8 CLEAN; only S0-S3 14.1 (phys_src2). RI-32 (rev 66) sent to RA, TI.
   NEXT: when TI pushes ti-src2 (now gate-scratch/TI-src2 7b003e98), merge, regen, rcu_isd_s captures lead_phys_src2
   (XW+8, lx packing, isd_tb), lanes src row 2 from x copy, ngd.json; units; block read; if clean gate+push ccv_rcu.sv.
   Bookmarks (sweep 2026-11-09 10:31): Conv 17, AR 339, OA 409, IS 190, TI 400, OI 336, CP 157, DA 116, RA 133, RI 66.
   OPEN: OA 405 (Needs RI): OA's sweep conflicts on our branch (perf-register.md AR vs TI PF-47; cg-waivers pcm_n floors;
   rcu_dec_pkg regen). After chain-ri14 pushes: daily merge of RA/OI/AR/OA/RH branches (OI's 57eff422 conflicted before),
   full gate, push; then answer OA 405 in RI tab.
   DISK: allowance ~40 GB; delete build/cg *.vcd after each cg unit.
-2. ASSEMBLY (ri-asm2 in ri-wt2, on gate-scratch/RI at 2d107c61; ff5ddcca is an ancestor):
   f37a29cd ccv_rcu.sv (generated by ri-keep/gen_ccv_rcu.py + ccv_rcu_body.svf, untracked; keep them);
   Icarus fixes (pred continuous assigns; |(x&(x-1)) not $onehot0); 3ced62a5 merge TI 21b4b80 (RA-43 +
   pmov); a4d73a69 pmov (model decode PMOV was None!); 76305abc RA-43 RTL (guard/R srcs from leads, issue
   credits = k_cr[s]); 0f8b86a5 slice L rows gated by lead cont/sec (lsecK control); 2d107c61 slice interim
   waiver removed (L gate idle 100/98/98/93 K0-3). Green: run-rtl (22 controls caught), check-1d, top
   Icarus plain+CHECK and Verilator TOP_OK (scratchpad asm/verify3.sh). Next: split gate + push (chain-ri11);
   RI rows: RA (ngd arrivals restated for the zero-cycle end; binary capture of R imm/rows; slice M-row gate
   84 flops at 61/54% idle K2/K3, budget 127/131 at K3, remedy: gate M by lead ownership; KILL_DRAIN 15
   comments), TI (swap ccv_rcu.sv into the top file list; SFU controls into check-rcu-unit.sh; TI's 8dbc152
   missed rcu_decode.h, RI fixed). Then per-level block CG/NGD (sum of parts), M4 kill checker, 5c lock-step.
   Icarus lessons: no always_comb reading back its own slices; $onehot0 args miss sensitivity.
   check-kernel does not rebuild a stale ccv-skel: run tools/check-skel.sh after model edits.
- 2026-11-08 TI rev 383: 9894da1 (on TI branches ccr-183cc441-doowtf / infra) = CAS writes pd + RA-16 + RA-41
  (credit on receipt: 13 credit ports leave ccv_rcu_ports.svh). Reviewed RI rev 48 (adapter OK; suggest scoping
  copy pwe-clear to atomics). After chain-ri6 pushes: merge 9894da1, drop rcu_kill's 13 credit capture flops
  (rcu_kill.sv, ccv_rcu gen, kill_tb), cg-waivers 45->32, rerun kill units + benches. Bookmarks TI 383, RI 48.
- 2026-11-08 chain-ri6 RED (not disk): lanes opc 25.3 + slice_k3 popc 25.8 at arrival 1.4 (interim arrival 0, RI rev 49,
  pending RA); rcu_pred waivers m_am 2.5->3.1, rg_hi 1.0->2.0; slice_k0 bench cov_mw_shift unreachable at K 0 (bin now K>0).
  LESSONS: check-ngd --unit may exit 0 with findings: grep 'check-ngd: NGD'. Run every slice unit (k0,k2,k3, K1) before a gate.
- RA rev 117: interim accepted (bounded): the two entries go in the RA-43 class-flop commit; pre-decode instead if
  RA-43 is not in when ccv_rcu.sv goes in. Measure slices at every K. Bookmarks RA 117, RI 49.
- chain-ri7 = re-gate of ri-dec 4735e95 (fixes 9bd2d74, 2249bf3).
-2. IN FLIGHT 2026-11-08: chain-ri6 (chain-ri5 died: disk full from build/cg VCDs, ~9 GB; chain-ri6 rm -rf build/cg after the cg export). Was chain-ri5 (~/ccv-logs/chain-ri5.sh, out chain-ri5.out) gates ri-wt2 branch ri-dec
   (de9894d: module fixes, ccv_rcu.sv removed) and pushes. ri-dec now fast-forwarded to ri-retime (ri-wt4: d38ab59 retime,
   f3f5de7 arrivals at fanout term + rcu_pred act_d pre-decode, 521d4fa stall flopped + stall2 control;
   all unit NGD/CG + run-rtl clean) and gate it the same way. Then, when TI's ti-ri22 (TI rev 381) lands:
   restore ccv_rcu.sv (gen: /home/user/ri-keep/gen_ccv_rcu.py; in 952dd81) + ccv_rcu.ngd.json (draft in /home/user/ri-keep;
   scratchpad: lane_rcu_res_cNN arrival 13), rerun block check (blk_ngd.py), gate.
   Rows written RI rev 44/45: re:RI-22 rulings (M5 65/67 of 68, RA to confirm), (e): 14 issue in-paths
   over 12 (worst lanes dst 20.7). RA rev 111: M5 confirmed, RI-22 closed; (e) re-run (RI rev 47): only
   lanes 14.5 (odst/opos/spos/src) left; +128 lead flops -> 10.9 block worst; ~567 lead flops vs 2% ~4,850. RA rev 113 / RA-43: zero-cycle ooe_rcu_issue APPROVED. When TI's schema lands: capture leads in lanes/pred/
   bank_slice/r, re-run (e) on RTL vs schema fields (src_pos/src_width per schema), and with the issue boundary
   flop gone KILL_DRAIN goes back to 15 (BND_ISS term = 0, model + RTL) to close RA-42.
   TI rev 382: RA-43 built on TI side (KILL_DRAIN 15, L1_CMPL 18, issue credit 4); TI edits sim/rcu too in that push:
   at merge, reconcile with ri-dec fe76e2a (RTL kill drain 16) and keep TI's model edits.
   RA rev 114: S-slot lead copies = phys_old_dst, old_dst_pos, src_pos, phys_src (32 b); src_width and phys_src2
   stay payload (if either > 12 in the RTL re-run, back to RA). rcu_r takes imm (movi, call link) from the
   lead_rpsrc capture; imm leaves R's payload.
   Still owed: re:RA-42 (BND_ISS term in KILL_DRAIN, model+RTL; checker at KILL_DRAIN-1 control),
   RA rev 102 re:RI-21 (slice L/M owner assert + control; pred drives PC0-3; kill flop TODO).
-2. PHASE 5 (2026-11-08): worktree /home/user/ri-wt2, branch ri-dec: 415b0ca P7, 847d085 P2,
   c8dbab0 pred/mig fixes, fe76e2a ccv_rcu.sv assembled + RA-42 (on gate-scratch/RI). ccv_rcu.sv
   is written by scratchpad gen_ccv_rcu.py + ccv_rcu_body.svf (hand-edit the .sv once settled).
   Block check loop: scratchpad blk_ngd.py (check-ngd's block_check on RCU units only),
   log ~/ccv-logs/blk-ngd.log. New units: rcu_bank_slice_k0/_k2/_k3 (ROWS 192), rcu_clk (NWAKE 37).
   Next: block NGD clean -> regen, check-1d, run-rtl.sh, split gate, gate-push (merge ri-dec into
   ccr-888218a3-20cauz). Then RI rows: re:RA-42 (RTL 15->16 via CCV_LAT_RCU_KILL_DRAIN; the model
   already added bnd_rx via Config; M4 kernel control at cut 1 still to run), re:AR 322 (RA-41 TODO
   flops marked in ccv_rcu.sv header), RA FYI: P2/P7, lanes pcm CG-3 waiver, slice ropc/rmrg
   arrival 0, SFU never decoded, no PXOR, S6 kill credit in series, CSR wake (Q-59).
   Then task 5c: lock-step vs model, RTL event monitor, Q-53 checkers.
-1. J9 settled (AR 320): the cliff was the stub DCU's 8 KiB direct-mapped default; TI made it 8x64
   (31168a3). Not RCU. #88 fixed by TI (21b4356, reviewed RI rev 39); TI rev 367 ran coremarkpl32 to
   the end on the model. OI-127/OI-129: A2 carries ppdst/pred_we/ppold (OI f727aed); the model's
   lane write-back already writes it (RI rev 40). When TI says a CAS-with-pd kernel exists, run it
   on model and stub.
-0.5 RA rev 100 limits: rcu_pred gd_cr02h in-flop must stay <= 24.5 (now 23.9; first remedy:
   pre-decode act_d); class-bit arrival 5 must hold with the atomics term added. TI built an
   rcu_rtl gate section (0a6b7b3, TI rev 374) running test/rcu/run-rtl.sh: merge it at the sweep.
0. RI-19: note 1 confirmed (RA rev 96); mig_q_drop pushed 12e6b7b (RI rev 30). Close when RA has no more. Was: kmask +2 clear vs a
   relaunched warp's first row (>= 2 cycles after its map). Notes 2-9 in the row.
   Lessons: run tools/check-1d.sh before a gate (the linter misreads 1'b0 in a wire's concat and a
   for loop's <= bound); run tools/regen.sh after any merge before testing (sim/generated not checked in).
3. RI-16: RI's part done (rerun at 7/12 passes); NGD read on lane_rcu_res at assembly (12 without flop).
4. RI-11/RI-13 (TI rev 332): verify on merged tip, close RI-13 (and RI-11 for RCU).
   RI-12: close when OI's fix lands (OI rev 287).
5. At bank assembly: row 135's gate (RA rev 80), rcu_r pr_orow output, block CG totals
   (lead/credit waiver flops charged; sum of parts), block NGD for lane_rcu_res, write_row_named vs ZROW.
6. Remove worktrees ri-wt2, ri-wt3 when done.
