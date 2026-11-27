# RI handoff (RCU implementation)

Updated 2026-11-14. Keep current at every task's end. Role and ownership:
docs/rcu-impl.md (RA's handoff, section 1). Spec: docs/design-snapshots/rcu-arch-*.md
(live doc https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB wins).

## Who and setup
- RI = session_01QPk2jvvXPLs4m8ZQbSk1g6 (roster commit 187048a). Register tab RI node
  8e4547bc-c469; write only there. Daniel (DA) is a senior microprocessor design engineer.
- session-home installed (Daniel OK'd 2026-11-04, re-run 2026-11-06 after the merge: 350k window);
  --check matches.
- Daily sweep scheduled task trig_01YVAyULgv3K9NymwVJXZybD, 02:31 America/Los_Angeles.
- Toolchain: ./tools/setup-toolchain.sh (log ~/ccv-logs/setup-toolchain.log).

## Dates (DA via TI-461, 2026-11-16)
- No task carries a date: best effort in priority order; a dependency is met by reordering. Never put a
  due date on a row, handoff item or promise. Dates in older items below are history or priority, not deadlines.

## Repos, branches, push
- Work trees: /home/user/ri-wt2 (ri-asm2, assembly), ri-wt4 (ri-sweep, pushed); compiler repo read only.
- Push: tools/gate-push.sh with CCV_PUSH_BRANCHES=ccr-888218a3-20cauz. Merge commits only.
  No PRs. No model ids in commits/code. Name commits for TI to merge in the RI tab.
- Last push: 208e9130 (11-27 sweep, PASS full). Earlier: 634bb54e (11-25/26 sweep); 21dd6b95 (11-24 sweep); bd3bf7b8 (handoff, credit module); 9f124ce6 (11-23 sweep); c3f77676 (11-22 sweep); 769e4ca6 (11-21 sweep); 5d1b634d (11-20 sweep); cae55e0c (11-19 sweep); 05af449c (2026-11-15, SCOPED PASS 21/24, ri-signoff in ri-wt12): waivers signed + rcu-exit.md.
  Before: ce5f44dd (2026-11-15, PASS full, ri-sweep15 in ri-wt12): sweep + address from param (RI-54).
  Before: 9f513f3b (2026-11-14, SCOPED PASS 24/24, ri-sfuclass in ri-wt10): SFU pair (TI 996866d1+c27ff714,
  RI decode/dec_pkg/lanes_lockstep sfusec) on sweep 4be9f37b. Before: 7e10e72f (2026-11-13, SCOPED PASS 15/24, ri-svh in ri-wt9): SV top with RTL, Q-53, timing. Before: c64b7417, then 8fcec64b (2026-11-10, SPLIT PASS 23/23, chain-ri17b, branch ri-asm4 in ri-wt7): ccv_rcu.sv
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
- Daily sweep: tools/daily-sweep.sh is safe from our branch (518cb3c3 in since 9f513f3b; detach exits 5).
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
Bookmarks 2026-11-09 (notices; RA since read to rev 140): Conventions 17, AR 336, OA 379, IS 190, TI 395, OI 324, CP 155, DA 115, RA 130, RI 63. (DA 116, TI 396, AR 337)
DA 114/115 bar for zero-cycle rx ends (S1 gain): <=0.2% stays flopped; 0.2-0.5% Daniel; >0.5%
architect may approve only if the end meets module NGD without the flop; can't meet 12 NGD -> Daniel.

## Open work, most urgent first
- (-32) 11-27 sweep: pushed 208e9130 (PASS full; ngd 12.3 ks, cg 11.7 ks). Merged 58815650 63 (MI, with the
  miu_form clang++ fix; RI-64 closed by it), infra 54, miu-dcu-spec 143, 3868632d 48, 126afa13 6, 5e4d6c70 4,
  80102643 3, 9eb50716 1, c22116ce 1. Register: nothing for RI (bookmarks AR 426, OA 506, IS 201, TI 593, OI 427,
  CP 160, DA 136, RA 159, RI 93, MA 221, MI 74, DI 99, Conv 20). Friday pings: all 11 pongs ok.
  Lesson: 9 merge bases (each agent's 11-24 tip) made ort's virtual base explode (90 min timeout, no result);
  resolve caps at 6. Recipe: scratchpad vmerge.sh/vmerge2.sh = flat virtual base (octopus base + merge-tree of the
  tips), final `git merge-tree --merge-base=V`, then every path where one side still equals a base tip takes the
  other side, trust-report ours; commit-tree with both parents. ~2 s per branch.
- (-31) 11-25/26 sweep: pushed 634bb54e (PASS full). Merged infra 2, c22116ce 3, 5e4d6c70 5, miu-dcu-spec 6,
  9eb50716 7, 80102643 12, 3868632d 8, 126afa13 9 (trust-report taken ours, regenerated). Left out ccr-58815650
  (45, MI) after three CG OOMs on miu_form (RI-64). Lesson: a cc1plus OOM in check-cg is a unit, not concurrency;
  find it in dmesg and the cg log, not by rerunning; CCV_RESUME after a FAIL reruns everything (build cleared).
-30. DONE (2026-11-24 sweep) PASS full, pushed 21dd6b95 (ri-sweep24 in ri-wt). Merged: infra 152, 9eb50716 33,
   miu-dcu-spec 20, 58815650 (MI) 12 (resolve), 80102643 4, 57eff422 (OI) 2; no conflicts (1-base branches first).
   Register: nothing for RI (AR 415/416 credit module, see -29; OA 484 RCU feedback decl signed by RA; OA 485 RCU's
   16 schema-channel ports excused untagged; TI-557 RCU 0 back edges; no RCU conn-ratchet entries). Bookmarks:
   Conv 20 AR 421 OA 502 IS 201 TI 582 OI 426 CP 160 DA 134 RA 159 RI 92 MA 211 MI 68 DI 93.
-29. OPEN (waits on TI) TI-537 (DA): one common RTL credit module in rtl/common (TI): ccv_common_cr_src (sender),
   cr_go (comb helper), cr_dst (receiver credit return). No new per-block credit counters from now on. Once it
   lands, migrate rcu_kill (41 credit-on-landing flops) and rcu_mig (map/rau_mig pending-count returns, pca_mig
   credit on write, rcu_pca_mig demotion sender counter) onto it. RI-63 (rev 92) gave TI those ends; noticed TI.
   RA 159 adds rcu_kill's CSR responder credit; TI-539/540 cover all of it (no_flop credit flop WIDTH 41, owed
   counter with rel_n + kill-drop count sized by queue depth, release-at-write, REG form for rcu_pca_mig).
   TI-541 (DA, AR 415 (5)): a credit/stall port may reach its own channel's valid in-cycle only via cr_go; the
   registered form stays legal at +1 depth. AR 415/416: at a flopped end cr_src is only the counter (valid is go,
   the boundary flop is the repeater's); each end's form (COMB full rate at 4+2N; REG/LATE need 4+2N+1) is declared
   per end in params/links.json by the sender's architect (RA for RCU's), TI's generator adds the +1. TI holds the
   one credit:true waiver; migration removes rcu_kill's own credit waivers (flops still count in RCU's 2%).
-28. DONE (2026-11-23 sweep) PASS full, pushed 9f124ce6 (ri-sweep23 in ri-wt). Merged: infra 154 (carried doowtf,
   c22116ce, 3868632d, 126afa13, 57eff422), 58815650 (MI) 18, 5e4d6c70 (DI) 8, 80102643 6, 9eb50716 3,
   miu-dcu-spec 3; no conflicts. Merging the 1-base infra first cut the others' bases to 1-2 (fast). Register:
   nothing for RI (pc_kept on ccv_ooe_rau_drained is TI/OOE, RA 158: no RCU channel). Bookmarks: Conv 20 AR 414
   OA 474 IS 201 TI 529 OI 405 CP 160 DA 131 RA 158 RI 91 MA 173 MI 38 DI 69. Still open: Daniel's RCU sign-off.
-27. DONE (2026-11-22 sweep) PASS full, pushed c3f77676 (ri-sweep22 in ri-wt). Merged: infra 111, 57eff422 (OI,
   AR 402 resolved per OI-196) 17, 5e4d6c70 (DI) 7, 3868632d 6, miu-dcu-spec 6, 9eb50716 5, c22116ce 2,
   80102643 10 (ort ran >2h; -s resolve then conflicted only in sim/skel/main.cpp, a --break list where ours was a
   superset -> ours, and generated trust-report -> regen). Register: nothing for RI. Tab nodes for the reader:
   MA 1f971016-3f72, MI c1311541-4219, DI 1ea5d5b3-6e9c (not in roster.json). Bookmarks: Conv 20 AR 409 OA 468
   IS 201 TI 516 OI 401 CP 160 DA 131 RA 157 RI 91 MA 157 MI 35 DI 41. Still open: Daniel's RCU sign-off.
-26. DONE (2026-11-21 sweep) PASS full, pushed 769e4ca6 (ri-sweep21 in ri-wt). Merged: c22116ce 1, infra 209,
   miu-dcu-spec 15+5 (resolve), 58815650 (MI) 2+2, 5e4d6c70 (DI) 4 (resolve), 80102643 4; no conflicts.
   SKIPPED 57eff422 (20): conflicts in OI/TI files (OI.md, rtl/ooe/*, sim/ooe, sim/skel/kernel.h, test/ooe,
   cg-waivers) - AR 402 raised it, OI resolves; merge in a later sweep once resolved, no RI row.
   Register: nothing for RI (MA-18 MIU no-flop receivers, no RCU change; DI-8/9 RCU-RTL diff was MIU bug fixed
   51cf5dd2; TI-502/OA 462-464 OOE demotion credit). Fri pongs all 11 OK. Bookmarks: Conv 20 AR 406 OA 466
   IS 201 TI 511 OI 399 CP 160 DA 128 RA 157 RI 91 MA 145 MI 29 DI 29. Still open: Daniel's RCU sign-off (RA 155).
-25. DONE (2026-11-20 sweep) PASS full, pushed 5d1b634d (ri-sweep20 in ri-wt). Merged: c22116ce 29, 126afa13 ~9,
   3868632d (TI, has 6464a030 resume) 113 via -s resolve, 80102643 28, doowtf 4, miu-dcu-spec 6, 58815650 (MI) 2+1,
   5e4d6c70 (DI) 7; no conflicts. Merges are slow (2-7 merge bases): run them detached with a per-merge timeout;
   -s resolve fails past 6 bases ("cannot read more than 8 trees"), so let ort run. From now on, a killed gate
   reruns the same command with CCV_RESUME=1 (TI-490/IS-27). Register: nothing for RI; MI's transp4 demotion bug
   routed to the demotion/barrier owner, not RI. Fri pings 2026-11-20: pongs ok from all 11 (AR OA IS TI OI CP RA
   MA RH MI DI); answered 10 pings (all me=ok). Bookmarks: Conv 20 AR 400 OA 460 IS 201 TI 498 OI 395 CP 160 DA 128
   RA 157 RI 91 MA 135 MI 16 DI 12. Waiting: Daniel's sign-off.
-24. DONE (2026-11-19 sweep) PASS full, pushed cae55e0c (ri-sweep19 in ri-wt; two gates lost to container
   restarts first). Merged: ccr-58815650 (MI) 63, ccr-5e4d6c70 (DI; roster.json conflict: both MI and DI rows kept,
   each with its own session id; trust-report.md ours, generated), 9eb50716 27, miu-dcu-spec 9, 80102643 27,
   c22116ce 18, 57eff422 20, 3868632d 10. Register: nothing for RI; Conv 20 adds MI and DI. TI-490 (rev 489, DA):
   RESUMED PASS counts as full; after gate-wait says killed, rerun the same command with CCV_RESUME=1, once TI's
   6464a030 is merged (next sweep). Bookmarks: Conv 20 AR 395 OA 446 IS 199 TI 489 OI 380 CP 160 DA 128 RA 156
   RI 91 MA 127. Waiting: Daniel's sign-off.
-23. DONE (2026-11-18) Daily sweep, PASS full, pushed 54347d2f (ri-sweep18 in ri-wt): c22116ce 92, 57eff422 24,
   9eb50716 11, 80102643 9, miu-dcu-spec 8; no conflicts. Register: nothing for RI. RA 155: RCU reconciled; RA's report
   is with Daniel, who holds final sign-off pending review. RA 156: no RCU macros. OA 434 cites RCU's lead waivers as
   precedent. Bookmarks: Conv 19 AR 384 OA 436 IS 197 TI 480 OI 374 CP 160 DA 127 RA 156 RI 91 MA 97.
   Waiting: Daniel's sign-off.
-22. DONE (2026-11-17) TI-479: lane-tid check fired falsely on SFU-only answers (sgemm, stride benches). Fix 536c9210
   (ri-sfutid in ri-wt; core marks LaneMsg lane/sfu, block keeps sfu_tid_ at kSfuW), SCOPED PASS 10/24, pushed. Benches
   on gate-scratch/TI-stride in ri-wt15 (scratch, detached): sgemm-n256/n512 + transpose-n256 PASS, cycles unchanged.
   RI-62 (rev 91); TI 480: merged as 358ace66, sgemm passes. Bookmarks RI 91, TI 480.
-21. DONE (2026-11-17) Daily sweep, PASS full, pushed 93bf1bb7 (ri-sweep17 in ri-wt): doowtf 38 (incl. TI rokilllane
   1861cc51), miu-dcu-spec 25, 3868632d 42, 80102643 17, 57eff422 24, 9eb50716 7, c22116ce 9; no conflicts. First run
   died on a full disk: deleted build/ in ri-wt3..14 (stale). Register: nothing for RI. RA 152 (no RCU macros), RA 153/154
   (RCU takes the L1-ECC second data beat as is), AR 370/DA 124 machine check uses RAU's kill (TI's). Bookmarks: Conv 19
   AR 372 OA 428 IS 197 TI 477 OI 366 CP 159 DA 124 RA 154 RI 90 MA 82. Waiting: RA's sign-off report, then Daniel.
-20. DONE (2026-11-16 13:15) TI 457: rokilllane kill kernel at 1861cc51 (TI doowtf; NOT in ri-sweep16, whose full gate
   runs in ri-wt13, job-gate-push-20261116-103527-2546.log). Measured in ri-wt14 (detached 1861cc51, scratch): every
   CCV_RCU_KILL_DRAIN_CUT 0-15 passes on rokilllane (kill_lane 1) and rokill; cycles 1214->1206 by cut 8 then flat
   (rokill 104->94 by cut 10). Margin = whole drain 15. Logs ri-wt14/build/margin/. RI-58 (rev 87) + RI-59 correction
   (rev 88: model drops killed entries at Core::kill, not by epoch); notices RA. TODO after sweep push: rcu-exit.md
   M4 + open list: DONE, be4ba8af pushed (SCOPED PASS 4/24 on ac0c899e); RI-60 (rev 89) asks TI to merge; TI 460: merges it after its sweep. b2748371 (dates dropped, TI-461) pushed SCOPED PASS; RI-61 (rev 90); TI 463: landed as 7192d4fc on both TI branches. Bookmark TI 463.
   Next sweep merges TI 1861cc51. Waiting: RA's sign-off report, then Daniel. Sweep 11-16 (item -19 in ri-wt13's handoff) merged
   doowtf 26, miu-dcu 19, 57eff422 15, 80102643 15, 9eb50716 11, 126afa13 10, 3868632d 6, c22116ce 5.
-19. DONE (2026-11-16) Daily sweep, PASS full, pushed ac0c899e: ri-sweep16 in ri-wt13 = origin 05af449c + doowtf 26, miu-dcu-spec 19,
   57eff422 15, 80102643 15, 9eb50716 11, 126afa13 10, 3868632d 6, c22116ce 5, ri-asm 9 (no conflicts).
   Full gate-push log ~/ccv-logs/job-gate-push-20261116-103527-2546.log. Register: nothing for RI. RA 151: RCU has
   no SRAM macro (DA 123's 1RW rule moves nothing); report follows the rokill kernel; RA 148
   stub/refusal is TI's first in priority order. MA tab: tab e87b52b6-d6d0, node 1f971016-3f72 (not in roster).
   Bookmarks: Conv 19 AR 365 OA 421 IS 194 TI 456 OI 358 CP 159 DA 123 RA 151 RI 90 MA 68.
-18. DONE (2026-11-15) Daniel SIGNED the 3 owner CG waivers (RI-47) in conversation. 05af449c on ri-signoff
   (ri-wt12; = ce5f44dd + ri-asm handoff + cg-waivers "by" names signature + rcu-exit.md to ce5f44dd, open list
   refreshed). Scoped gate-push: job-gate-push-20261115-174608-425.log (waiter b4z0hvuku; check-cg/ngd in scope,
   ~3.5h). RI-55 (RI tab rev 84) written, notices TI + RA (asked for dates). ON PUSH: tell TI the commit to merge
   (short RI row or note), update handoff, task 35 done. PUSHED 05af449c (SCOPED PASS 21/24); RI-56 (rev 85)
   asks TI to merge it, notice sent. NEXT: daily sweep merges TI a5481843; then RA's report. Bookmark RI 85.
   DA 122 (via TI): Daniel confirmed the signature to TI; recorded in DA tab. TI gating its merge of 05af449c.
   RA's report has all it needs. Bookmark DA 122.
   TI-451: 05af449c merged as 93f0d75c on both TI working branches. Dates slipped: (c) stub/refusal 11-17,
   (d) kill kernel 11-18, so RA's report (tied to the kernel) likely 11-18. On the kernel: record M4 margin in
   rcu-exit.md. Bookmark TI 451.
   RI-57 (rev 86): Daniel asked TI whether the plain rokill kernel (no SFU) can land before 11-18; notice sent.
   Relay TI's answer to Daniel. Bookmark RI 86.
   TI-452: plain rokill kernel lands 11-17 (SFU variant later); RA 148 stub/refusal moves to 11-18. Tell RA?
   RA ties its report to the kernel, so 11-17. Bookmark TI 452.
   TI-448: (b) addr-late + merge in ti-nohit gate today; (c) RA 148 stub/refusal 11-16; (d) kill kernel 11-17;
   (a) DA-tab record waits on Daniel confirming to TI directly (asked Daniel). Bookmark TI 448.
   RA 150: sign-off report to DA 11-17 (with TI's rokill kernel); reconciliation on tip after ti-nohit; needs
   the waiver signature in the DA tab; nothing more from RI. Bookmark RA 150.
   TI-450: a5481843 landed (ti-nohit): RI-54 merged, addr-late in check-rcu-unit (8), AR 359 (4) stub MIU fix,
   CCV_DCU_SETS 512. Next sweep merges it. Bookmark TI 450.
-17. DONE (2026-11-15) Sweep 2026-11-15 + RA 148/AR 356 (2): pushed ce5f44dd (full clean gate PASS; ri-sweep15
   in ri-wt12) = TI doowtf bd1cc5a2 + 8f00fdf8 (model times address from CCV_LAT_RCU_ADDR; base 2 tried:
   correct, only base-1-tuned bins move, ~/ccv-logs/ri-addrbase2-check-kernel.log) + sweep merges (126afa13,
   57eff422, 80102643, 9eb50716, c22116ce, miu-dcu-spec) + 0fe15d9a (unit test addr-cycle, control addr-late).
   RI-54 (RI tab rev 83) written; notices TI, RA, AR. WAITING: TI adds addr-late to tools/check-rcu-unit.sh
   (count 8), stub timing + RTL base!=1 refusal (TI's); TI merges ce5f44dd. MA tab has no roster node: unread.
   Bookmarks: Conv 19 AR 358 OA 418 IS 194 TI 445 OI 350 CP 158 DA 120 RA 149 RI 83 MA 54. (DA 120 records TI-445 + RA 149's carve-out.)
   TI-445 (DA ruling, FYI): RI may set/move NGD port budgets of modules below ccv_rcu, check-ngd passing
   (by/why named); ccv_rcu block-boundary and lead budgets stay RA's. RA 149: also any child port wired
   straight to a ccv_rcu block port (e.g. rcu_mem miu_addr sender, rcu_pred guard input) stays RA's. No answer owed.
-16. NOW (2026-11-14 ~17:50) SFU pair PUSHED 9f513f3b (SCOPED PASS 24/24). OI-148 (OI rev 349) gave go. RI-53
   (RI tab rev 82) written, notices TI+OI+RA. Task 33 done; RA 146 done. Bookmarks: OI 349, RI 82.
   WAITING: TI merges 9f513f3b; TI kill kernel; DA's RI-47 waivers + sign-off after RA's report.
   TODO: docs/rcu-exit.md open items (split tree done by TI 7079fc14; SFU class landed 9f513f3b).
-15. NOW (2026-11-14 ~11:30) Sweep 2026-11-14: ri-sweep14 in ri-wt9 merged 9 branches clean (TI doowtf 3, c22116ce 4,
   3868632d 10, miu-dcu-spec 13, 126afa13 17, 80102643 61, 57eff422 30, 9eb50716 9); full gate-push running:
   job-gate-push-20261114-103347-8366.log (wait with tools/gate-wait.sh). session-home --check matches (from ri-wt).
   Bookmarks: Conv 19 AR 351 OA 416 IS 193 TI 430 OI 348 CP 157 DA 119 RA 146 RI 80 MA 54. Not Friday: no pings.
   RA 143 CLOSED (TI 7079fc14 verified). SFU class (RA 146: RCP_U32, RSQRT_F32, RCP_F32_P only): RI half on local
   ri-sfuclass (ri-wt10) 26ab1517 + 30e363cc (dec_pkg regen). Alone it fails lnorm1/transp4 (lane stub runs no SFU op,
   result at LAT_LANE not sfu_result at LAT_SFU). RI-51 (rev 80) proposes: RI merges TI's half when on a branch, gates
   the pair, pushes; or sends via gate-scratch/RI. Notices TI, OI (session_01DMw4FtFbGoVboMGxWpLBuv), RA.
   TI rev 431 AGREED: TI rings when its SFU half (ops.json, gen-ops, lane stub SFU, DEC routing) is on its branch;
   then merge into ri-sfuclass, run lnorm1/transp4 + run-rtl + lockstep + svh, gate-push, notify OI for go.
   DONE: merged TI c27ff714 (gate-scratch/TI-sfu); fixed lanes_lockstep (sec_valid = lane ops only; SFU on
   sfu_valid), control sfusec; ri-sfuclass tip d2d4525d clean on RCU side (lockstep all, svh 63 div=0, run-rtl).
   RI-52 (rev 81): TI must fix check-kernel held-over-r regex (warp 3 -> warp 1, same on c27ff714 alone). Then
   merge TI fix, regen, gate-push ri-sfuclass, notify TI+OI (OI go). ri-wt3 is detached at c27ff714 (scratch).
   TI rev 433: fix 996866d1 merged (ri-sfuclass 444f31b3), check-kernel PASS on the pair. NEXT: when the sweep
   gate (4be9f37b) pushes, merge origin/ccr-888218a3-20cauz into ri-sfuclass, gate-push (tools/ changed: all
   sections), then notices TI+OI+RA naming the commit.
-14. NOW (2026-11-14 ~08:00) Pushed 468fb286 (SCOPED PASS 24/24, ri-lat in ri-wt10): a61a79ca (lanes_tb, Q-53
   arrival take derived lane latencies) + 3c304f94 merged. TI rev 427 (TI bookmark 427): 5516e643 landed in
   c99dc88d; asked where a61a79ca is. Answered RI-50 (RI tab rev 79), notices TI+RA. 72a84674 (rcu-exit M7 in
   the gate; open item 1 = TI's links_split credit entry) pushed too (SCOPED PASS 4/24): branch tip 72a84674.
   WAITING: TI merges 468fb286, adds credit_on_receipt miu_rcu_data@rcu to test/phys/links_split.json, drops
   CCV_SVH_RCU_RTL=0 from check-links -> close task 32 / RA rev 143. Then TI kill kernel; DA waivers (RI-47)+sign-off.
-13. NOW (2026-11-14) RA rev 143 (RA bookmark 143): M7 met; RTL must be correct at every derived CCV_LAT_LANE (7-11),
   RI's phase-5 exit item. ri-wt10 branch ri-lat (TI 6061d0ee + ri-exit merged, cd8c9a06): a61a79ca lanes_tb kWB /
   age width / per-age cov bins from params; rcu_q53_chk arrival lat from CCV_LAT_LANE/SFU. RTL needed NO change.
   Split tree (build/lsplit, script scratchpad/split-repro.sh): with params/links.json's credit_on_receipt
   (miu_rcu_data@rcu) added, all 67 lockstep + 12 controls PASS, check-sv-hosted RCU RTL 63 kernels div 0 + controls.
   Without it the RTL drives no miu_rcu_data credit (RA-41) -> TI: links_split.json must carry credit_on_receipt,
   then drop CCV_SVH_RCU_RTL=0 in check-links. Base lanes bench identical (505/430). Base lockstep run: ri-lat-base.log.
   RI-49 written (RI tab rev 78), notices TI+RA. RA rev 144 (bookmark 144): accepted; 7 and 11 suffice; closes when
   a61a79ca merged and check-links passes without CCV_SVH_RCU_RTL=0 (TI). Chain scratchpad/chain-lat.sh: after ri32
   push, merge tip into ri-lat, gate-push (log ~/ccv-logs/ri33-chain.log, ri33-push.log).
-12. NOW (2026-11-14) Pushed 5516e643 (SCOPED PASS 21/24, ri-exit in ri-wt9): RA rev 140 items (1)(2)(3)(7)(8)
   (pzero, lanes SFU + swlate, M5 from c1 68/64, M0 cycles vs stub, waiver texts, 21 ngd budgets -> "RA rev 140").
   RI-48 written (RI tab rev 77), notices RA + TI. WAIT: RA on which 4 of 25 budgets, RA's report to DA; MA on
   (6) multi GPR loads/cycle; TI merge 5516e643, SVHOST selector, kill kernel (rokill variant).
   TI rev 425: SFU class = TI op table + OI unit-4 + RI model decode (RTL ready); rcu_dec_pkg import switch
   after sign-off. TI tab bookmark 425.
   RA rev 142 (RA bookmark 142): 21 budgets right; all rev 140 RI items closed; (6) closed (one_load_a_bank holds
   under FULL_ROW; per bank when FULL_ROW goes). 4 whys edited -> 7e9bf49d in ri-wt9 (local, NOT pushed; push with
   the block report). Left before DA sign-off: TI M7 selector + kill kernel; RI-47 waivers (DA).
   Block report docs/rcu-block-report.md (7acd52eb) + 7e9bf49d + 3c304f94 GATING: ~/ccv-logs/ri32-push.log.
   NEXT: after push, RI row (RA rev 142 done: 4 whys; block report; lanes CG-3 measures 54.9/68.8 > recorded 51/67,
   floors left as RI-47 put them), notice RA cc TI/DA. Then wait: TI M7 selector + kill kernel, DA waivers/sign-off.
   TI rev 426 (TI bookmark 426): RI-44 landed 6061d0ee (ccr-183cc441-doowtf, SCOPED PASS 24/24): RCU RTL in SV top,
   46/46, controls caught; M7 needs nothing more from TI. TI renamed shim ccv_rcu_dpi -> rcu_dpi in test/rcu/svh.py,
   ccv_rcu_svh.sv (CCV-L28): TAKE IT (merge 6061d0ee after ri32 push). OPEN for RI+RA: check-links split tree
   (CCV_LAT_LANE 7->11) fails with RCU RTL (miu_rcu_data fixed_latency_prompt, lockstep.py crash), skipped there.
   Answer in row: RTL verified at base latencies only (lanes' LAT/LSF/DH/DL/DS follow ccv_prov_pkg, but stage names,
   lane-result landing, KILL_DRAIN, miu_rcu_data fixed latency are timed to the base links); RA rules whether RTL
   must take other latencies; if so RI investigates. Then record M7 in rcu-exit.md (gate, 46/46, the split skip).
-11. NOW (2026-11-14) Pushed cd25d3bd (SCOPED PASS 14/24, ri-exit in ri-wt9): docs/rcu-exit.md (exit table
   at 7e10e72f) + test/rcu/guard-ngd.py (M1 guard path: 17.0 vs 16 on map w/ fanout; 13.6 without). RI tab rev 76:
   RI-46 to RA (M1 guard: keep a lead copy or restate; M3 "light unit" wording; M4 margin = whole drain; then
   reconcile), RI-47 to DA (sign/refuse 3 owner waivers: lanes pcm_n_cr04h CG-3, kill kd_cr02h + kaep_q_cr03h CG-4;
   sign-off after RA). Notices: RA (46,47), TI (46). DA has no session: its sweep reads RI-47.
   RA rev 138 accepted RI-43/RI-45 (RA tab bookmark rev 138). KILL_DRAIN already 15 (RA-42 done).
   NEXT: on RA's M1 answer, the lead copy in rcu_pred if asked; block report (task 22); SW write-back same-lane
   (task 20); then reconciliation + DA sign-off.
-10. NOW (2026-11-13 late) Pushed 7e10e72f (SCOPED PASS 15/24, ri-svh in ri-wt9; holds c64b7417 ri-credit and
   ri-q53 28cd347a): RTL in the SV top (test/rcu/ccv_rcu_svh.sv, svh.py prep/compare, lockstep --replayed), Q-53
   checkers, model launch at c0 + fifo_in_, rcu_test migration first row 206. Rows (RI tab rev 75): RI-44 to TI
   (answer rev 422: wrapper interface + host diff spelled per hunk; diff file at scratchpad
   svh/ti-host-rcu-rtl.diff, offered as gate-scratch/RI commit if TI wants a file), RI-45 to RA (timing fixes).
   Notices sent TI (RI-43,44) and RA (RI-43,45). WAIT: TI's merge + gen-top ccv_rcu_dpi + SVHOST 45/46 selector;
   RA's answer on RI-43 (Done tab busy-hold clause) and RI-45.
   NEXT (Daniel's order): exit table M1-M7; SW write-back same-lane (task 20); RA-43 (task 18); block report
   (task 22); RA reconciliation; Daniel's sign-off. ri-wt9 free again (worktree for next work).
-8. NOW (2026-11-13 ~16:00) Pushed 631d7fc6 (SCOPED PASS 14/24, ri-wt4 ri-xsel): rcu_r xbar_sel_onehot assert +
   r_tb --control twohot (RA rev 137). RI-41 (RA, TI: merge 631d7fc6) written, RI tab rev 72, notices sent.
   GATING NOW: ri-wt7 branch ri-credit (on 631d7fc6), log ~/ccv-logs/ri26-push.log (setsid; scoped gate, cg+ngd
   ~2.5h): d92b249f model creditAtLanding(ooe_rcu, lane_rcu) + lockstep --credit-lead default 0; 33c084e6 lockstep
   control lead (must diverge); c64b7417 ccv_rcu wake detector busy hold removed (AR 343), rcu_kill NB 6->5,
   kill_tb kNB 5; wake_detect_iw flop kept (done wake). Local checks: run-rtl 0, lockstep 63/63 + 6 controls,
   cg/ngd rcu_kill + ccv_rcu 0, kernel 0.
   ON PUSH: RI row to RA (+TI merge): (a) landing credits, lead control; (b) wake detector gone, so RA can reword
   the Done tab's done-wake term; notices RA, TI. Then (c) SV-top with RTL, (d) Q-53 checkers.
   TI-420 (rev 420): tools self-detach; wait with tools/gate-wait.sh <job log> (3=rerun at 110 min, 4=killed);
   only once a46afef7 is merged into my branches. OI pong received 15:44 (checked ok): pings settled.
   Bookmarks: TI 420, RI 72 (others as -7).
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
