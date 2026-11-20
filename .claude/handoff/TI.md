# TI handoff (top-level implementation)

Updated 2026-11-15. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds TI's.

## Working rules
- Push only to `ccr-183cc441-doowtf` and
  `claude/custom-cuda-core-infra-6msg93`, each after
  `git merge-base --is-ancestor origin/<b> HEAD`. No PRs. Never bare `git stash`.
- Push with `CCV_PUSH_BRANCHES=ccr-183cc441-doowtf,claude/custom-cuda-core-infra-6msg93
  tools/gate-push.sh` (regen+commit, scoped gate by default, `--full` for a
  gate-infrastructure change, ancestry, push, clear build but synth-cache);
  run it in the background and read its summary lines only.
- Notices: hand the text to the `register-reader` subagent with prefix TI
  (not loaded in this session: general-purpose, model sonnet, the file's
  body as prompt); act on its digest. Gate red: `gate-triage` subagent.
- Commits end with the Co-Authored-By and Claude-Session lines from the
  session's attribution reminder. No model ids in commits or artifacts.
- Edits to OI's files (sim/ooe/*) follow OI-18: edit, then notify OI.
- Register: write only the TI tab (node e8b1d9d9-df9b; responses table
  m8yvbw8rqgz.217, opens table m8yvbw8rqgz.122). Notices via
  `.claude/skills/register/notice.py`, `send_message` priority "later".
  Never answer a notice with a notice unless the row needs that agent.
- Long runs go in the background, writing logs to files; read summaries,
  not whole logs.

## Daily sweep (scheduled task trig_01A8r3ENUjnLyTaNUcc23ZbF, 02:11 PT)
Register section 4 (read through `register-reader` from the bookmarks
below); then `CCV_PUSH_BRANCHES=... tools/daily-sweep.sh` in the background
(exit 3 = a real merge conflict to resolve); pings and pongs; report in a
few lines.

- Before editing a worktree, check no gate, check or sweep runs in it
  (`ps aux | grep -E 'check-|gate-|verify|daily'`): three check runs were
  spoiled on 11-19 by edits made under them.

## Register bookmarks (revs read through)
Full bookmarks: /home/user/ti-register-bookmarks.json (outside the repo).
TI 487, AR 395, OA 436, DA 127, MA 97, RI 91, CP 160, OI 374 (others per the
JSON file). MA is session_01QPk2jyUbWA7fW9YpUwqdxk.

## Long runs
Every long tool detaches itself and exits 5 (never 0) when it does (OA-414,
518cb3c3). Wait with `tools/gate-wait.sh <job log>` as a background task,
timeout 7200000 (exit 3 = still running: rerun at once; 4 = killed by a
restart: rerun the job). Logs in /root/ccv-logs/.

## State (2026-11-18)
- Both working branches at 2d273c9a (11-19): MA-26 (WAYPRED_BITS 5, SEL 1
  recent, L1 hit 8, wake 14, cmpl 16; ooe_wake LAT_SPEC 14 / LAT_MISS 17
  pinned in test/ooe/cg-units.json until OA 439/444's package defaults);
  TI-487 option (3) (DCU withholds; MIU answers a killed warp's owed reads
  empty at the kill; RAU's mce kill needs no MIU ack; control ue-answer);
  OA 436 kill races (MIU atomic hold to A3; FET resets on epoch notice);
  OI's ccr-57eff422 merged. Rows TI-486..488 sent.
- Queue, in order: MI-1 + DI-1 hooks (CCV_MIU_IMPL / CCV_DCU_IMPL=model,
  blocks.list, check-miu-unit / check-dcu-unit) with MI-4 (A) and DI-3
  per-impl pins (priv_form: stub per try, model per memop); MI-5 bins and
  slow regions; MI-7 cold-TLB runs; MI-4 (B) demotion-vs-barrier bug
  (transp4 CCV_RAU_CONCURRENT=1 at:750; narrowadd) likely TI's SYU/RAU;
  MA-25 credits; ccv_common_err; RAS wrapper; AR 392 PT base CSR with Q-50.
- Both working branches at a102383b: AR 370 machine check (ccv_dcu_cru_err,
  F-MACHINE 10, CCV_DCU_UE_TRACK 16, CRU MACHINE_CHECK + kill_req every grid,
  RAU kill-all, DCU stub CCV_DCU_UE_INJECT; bins ue_recover/ue_fatal/
  machine_check; controls ue-no-track, ue-dirty-recover, mce-ignore,
  mce-no-record, mce-no-kill). Row TI-485 (rev 484) to AR MA IS OI OA, sent.
  Open in it: kill races (atom/atomf/cas atomic write after kill; ropediv
  ckpt free after kill) await OI/OA's call on which side fixes; those
  kernels are out of the machine-check runs till then.
- 0767fe1c: MIU stub injected L1 syndrome
  (CCV_MIU_ECC_INJECT, bin l1_ecc_fix, controls ecc-no-fix/ecc-cmpl-on-time,
  both hosts; RA 153 (5)); row TI-484 (rev 483) to RA, MA, OI, sent.
- b407ff71 (SCOPED PASS 24/24): RAS phase 1,
  SECDED enc/syn/fix (rtl/common inner helpers, K=128 units 14.5/15.4/15.4),
  sim/skel/secded.h, check-skel lockstep + controls col/nocorr/dedsec; SRAM
  DATA_W/ECC_K, MACRO-1 on data bits + check-bit width; ooe_wake LAT_MISS
  override dropped (task 35). Row TI-483 (rev 482) to MA, AR, RA, OI, sent.
- Both working branches at 36866ec7 (daily sweep 11-18, full gate PASS;
  release 6a90f970, tag local only). It carries 3eb6e8d0 (AR 380 / OA 433:
  warp_id + fetch_epoch lead on ccv_dec_ooe_uop, check-kernel uop-late-lead
  control on lanectx), row TI-482 (rev 481) to OI, AR, OA, notices sent.
  OA 434 ruled OI-170 option (a): a lead waiver for decrx enq_slot (OI writes it).
- 358ace66: ti-stride (AR 373 (2) stride benches + LOAD key, pin a293afe7,
  gate-scope sim/dcu + sim/miu, RI's 536c9210) and ti-shape (DA 2026-11-17
  macro shape limits). Rows TI-480, TI-481.
- Earlier landed: 9682b03a (AR 368 L1_ECC, TI 478), 117e8117, ddc700a1.
- Daily sweeps 11-17 (release 2e2b5313) and 11-18 (6a90f970) done; its tag push is refused from
  here, local only.
- Disk: a gate failed on a full disk; cleared idle worktrees' synth-cache.
  Scratchpad priv/ (4.3 GB) is unknown, left alone. Worktree ti-size is on
  branch ti-next at 36866ec7; ti-bench is free.
- Open small: task 35, drop the ooe_wake LAT_MISS 16 override in
  test/ooe/cg-units.json once OI's 5e1f3789 (OI-163) is in the base.
  AR may answer the colwalk-p128b anomaly (perfect fetch slower than stub).

## Open work (priority order)
A. Task 28, array RAS (DA rulings TI 474-476): SECDED part landed
   (b407ff71, TI-483); MIU stub injection landed (0767fe1c, TI-484). Left:
   DED test (needs AR 370's machine-error path), Sram1rw injection when a
   block model keeps arrays behind it; then the
   common wrapper (BIST override + spare row outside the macro + spare
   column above 8 KiB logical; macros only, flop arrays scan); BIST
   broadcast groups of up to 32 KiB logical in parallel (group/ID params,
   group-size and chain checks, tie-off only at the block wrapper).
B. Task 30, AR 370: stubs, schema and params landed (a102383b, TI-485). Left:
   ccv_common_err RTL (CE/UE counts saturating popcount up to 8 a cycle,
   first-error log lowest bank + track-hit + overflow, ERR_CTRL CE threshold
   -> ce_alert, INJECT 1/2 bits on next write to a named array, track table
   readable, host-only on the CSR star; MA-19: 16 arrays, 9-bit row). MA's
   224 "scan-only" track flops still owe CG.
C. Task 31, AR 371: SPM banks ccv_common_rf_1r1w 1024x32 (4 KiB, no ECC);
   stub sub-word RMW charged as a bank conflict; CCV_SPM_BANKS doc; check-ngd
   on the 1024-word read (fallback 2 x 512).
E. Offer Daniel cost/bit instead of efficiency if wanted (TI chose bits/cost).

No task carries a date (Daniel, 2026-11-16): everything is best effort, in
priority order. A dependency is met by moving its task up, never by a due
date. A date in another agent's row is read as a priority, not a deadline.
0. LANDED 11-15: a5481843 (SCOPED PASS 24/24 since bd1cc5a2) on both working
   branches: AR 356 (1) stub MIU MA-4 eligibility + early no-hit, OOE l1_nohit
   on in the skeleton (OI's ooe_block.cpp), AR 359 (4) fix (TI's stub MIU: a
   credit-late hit's cmpl could leave at the contract ahead of its data; fixes
   5663e208 + 28f9ab48; cm128priv 64 KiB warm/perfect 0 CHECKs, was 672,
   2,124,002 cycles), RI-54 merge + addr-late control, CCV_DCU_SETS 512,
   DA 2026-11-15 budget rule docs. Landing row: see TI tab after rev 449.
   NEXT (11-16): task 21 AR 362/MA 65 set_index/bank lead on ccv_miu_dcu_req +
   page-offset require; task 19 RA 148; check-ngd 'by' enforcement of the
   budget rule (unmeasured-parent modules, boundary ports/leads, boundary-
   wired child pins), a negative control each; cover bin for the
   credit-starved late hit. Daily sweep repo half: fresh worktree.
0b. 11-16: RCU waivers signed (DA rev 122, Daniel in TI's session); RI's 05af449c landed as 93f0d75c (TI 451). OA 419 baseline line: OI carried it (0bd67c2b), nothing for TI. Promised to RI: RA 148, lane-op kill kernel (no dates: DA 2026-11-16).
0c. LANDED 11-16: 1861cc51 (SCOPED PASS 24/24) on both working branches:
   AR 362/364 (DCU_BANKS 8 on PA[9:7], BANK_AGE 16, W_DCU_SET, page require,
   lead_set_index only; stub MIU drives, stub DCU checks, break dcu-set-lead),
   RI-57 kill kernel rokilllane + bin kill_lane, and an OI-18 edit to
   sim/ooe/ooe_core.cpp (epoch check before slot lookup). TI 457 rang RI, RA,
   OI, AR, MA. Daily sweep 11-16 repo half running from /home/user/ti-sweep
   (branch ti-sweep16; log job-daily-sweep-20261116-125856-*.log).
   OI-157/IS OOM: check-cg holds change counts, not traces (b3e2305f = 804d1e6f
   on ti-sweep16); LANDED: the 11-16 sweep's full gate passed on 804d1e6f,
   pushed to both working branches and release (21d2fb26). TI 458-460. After it lands:
   LANDED 7192d4fc: RI's b2748371 + no-dates CLAUDE.md (SCOPED PASS 4/24); TI 462 rang OI, IS; TI 463 rang RI.
   LANDED 0b270eb3 (SCOPED PASS 24/24): task 22 macro library (every-other-cycle
   sram_1rw, 2-cycle read; ccv_common_rf_1r1w); TI 464 rang MA.
   NEXT, in priority order (no dates, DA 2026-11-16): check-ngd budget-rule 'by'
   enforcement (unmeasured parent, block boundary ports/leads, boundary-wired child
   pins; a control each); credit-starved late-hit cover bin; task 19 RA 148 (low
   priority, post-sign-off); SFU kill variant.
1. OI-149 done (58d758ce). AR re-books PF-47/PF-33 from AR 356 (1)'s runs.
2. RA re:RI-46 (3): kill kernel with an SFU op in flight at the kill.
3. OA 413: when ooe_sched gets a parent, its check-ngd proves chas leaves
   ooe_rs from a flop. RI-21 (4): rcu_dec_pkg switch after sign-off.
