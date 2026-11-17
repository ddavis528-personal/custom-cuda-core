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

## Register bookmarks (revs read through)
Full bookmarks: /home/user/ti-register-bookmarks.json (outside the repo).
TI 441, RA 148, RI 82, OI 350, AR 356, OA 418, MA 57, IS 193, CP 157,
DA 119, Conventions 19 (2026-11-15). MA is session_01QPk2jyUbWA7fW9YpUwqdxk.

## Long runs
Every long tool detaches itself and exits 5 (never 0) when it does (OA-414,
518cb3c3). Wait with `tools/gate-wait.sh <job log>` as a background task,
timeout 7200000 (exit 3 = still running: rerun at once; 4 = killed by a
restart: rerun the job). Logs in /root/ccv-logs/.

## State (2026-11-16)
- Landed 11-15: bd1cc5a2 (SCOPED PASS 24/24 since e48fa517) on both working
  branches: PF-47 (base 1: RCU_ADDR 1, L1_WAKE 13, L1_CMPL 14; ooe_wake defaults
  13/15), CCV_P_TIMEOUT_UOP, RI's SFU pair, CCV_LAT_MIU_NOHIT_A2=2 (MA 56),
  CCV_LAT_L1_NOHIT (AR 353/354; require NOHIT+2 <= L1_WAKE, OA 416).
  TI row rev 439 rang OI, AR, MA, OA.
- cm128 unbounded (AR 350/352) answered at TI rev 436: 73.6M cycles, holds
  uop 8252, memop 19201 (< 20480).
- Daily sweep conflicts were all .claude/handoff/RA.md: take RA's newest.
- Worktree: /home/user/ti-sram. Backups to gate-scratch/TI-<name>, plain
  push only. Disk: deleting other sessions' /tmp/tmp.* was denied; ask.

## Open work (priority order)
IN FLIGHT 11-17 (urgent first):
A. Task 26: gate-push of 117e8117 (ti-nohit, worktree /home/user/ti-sram;
   macro pin timing TI 465 + no SRAM byte enables / rf_1r1w_be TI 466), job
   log /root/ccv-logs/job-gate-push-20261117-031815-29294.log. On pass:
   landing row to MA, AR with corrected launches (SRAM 16.3, RF 13.5).
B. Task 27: MACRO-1 size limits (DA 11-17, TI 467 rang MA AR RA): RF 512 B-
   8 KiB, SRAM 4-32 KiB per instance, inclusive (DA), waivers in
   rtl/macro-waivers.json. Commit 2c032fa9 on branch ti-size, worktree
   /home/user/ti-size, backed up to gate-scratch/TI-size. After A lands:
   merge the landed tip into ti-size, gate-push from there, landing row.
C0. Daniel 11-17 (TI 469): efficiency penalty 0 at max size, linear to 20% at min (CCV_MACRO_SIZE_PENALTY_PCT); (6.4% for the 5,760 B RF corrected to 6.3% in TI 470; MA moved data to 16 x 32 KiB, 512 words: launch 18.5, 6.5 NGD left.)
C. Daniel 11-17 (TI 468): limits inclusive; size waivers by the block architect, DA approves before block completion; ce/we/re take the address setup.

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
