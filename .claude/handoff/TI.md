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

## State (2026-11-15)
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

## Open work (most urgent first)
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
0b. 11-16: RCU waivers signed (DA rev 122, Daniel in TI's session); RI's 05af449c landed as 93f0d75c (TI 451). OA 419 baseline line: OI carried it (0bd67c2b), nothing for TI. Dated to RI: RA 148 11-17, lane-op kill kernel 11-18.
1. OI-149 done (58d758ce). AR re-books PF-47/PF-33 from AR 356 (1)'s runs.
2. RA re:RI-46 (3): kill kernel with an SFU op in flight at the kill.
3. OA 413: when ooe_sched gets a parent, its check-ngd proves chas leaves
   ooe_rs from a flop. RI-21 (4): rcu_dec_pkg switch after sign-off.
