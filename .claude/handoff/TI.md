# TI handoff (top-level implementation)

Updated 2026-11-13. Keep this current at every task's end; it is what
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
TI 419, AR 348, OA 414, MA 44 (2026-11-13). MA (MIU/DCU architect,
session_01QPk2jyUbWA7fW9YpUwqdxk) is not in the roster: notice.py says
none, so compose with --to AR and edit the header by hand.

## Long runs (DA, 2026-11-13)
An idle container is reclaimed and kills detached jobs; a background task
dies at 2 h. Run a gate detached and keep a background task alive on it:
once ti-detach lands, `tools/gate-push.sh` detaches itself, and
`tools/gate-wait.sh <job log>` as a background task waits (exit 3 =
still running: rerun at once). Before that lands: `setsid nohup ... &` plus a
`while kill -0 <pid>` watcher, restarted before 2 h. Add a send_later check-in.

## State (2026-11-13 ~09:10Z)
- Landed eda137fa (MA-15 1-4, MA-5 memop credits_param 10/slot, no_hit +
  notice_of.unless, CCV_MIU_DCU_IDS, CreditAt::Release opt-in under
  CCV_MIU_MEMOP_CREDIT=entry). Row 419 to MA AR OA OI.
- Gating: /home/user/ti-detach b5cb0fbb (self-detaching long tools,
  gate-wait.sh, check-detach.sh; backup gate-scratch/TI-detach). Job log
  /root/ccv-logs/job-gate-push-20261113-090713-20034.log. On pass: a
  "gates detach: landed" row to AR OA OI RA RI RH IS CP MA (row 418 gave
  the interim manual recipe).
- Worktrees: custom-cuda-core, ti-ops, ti-ma, ti-detach. Backups to
  gate-scratch/TI-<name> by plain push only (force-push is denied).
- Disk: deleting other sessions' /tmp/tmp.* was denied; ask the user.

## Open work (most urgent first)
1. #9 MA-5 entry-free credits: merge OI's dca29edc
   (origin/ccr-57eff422-5tdecg), make CCV_MIU_MEMOP_CREDIT=entry the
   default, controls memop-credit-on-take and inject_no_memop_credit; gate;
   row to OI, MA.
2. #8 SRAM macros (AR 344): ccv_sram_1rw (byte wmask), ccv_sram_1r1w
   (read-before-write) as check-ngd/check-cg black boxes, behavioural models
   in both hosts, a flop-array control.
3. MI/DI homes when their first files land.
4. Older: RI-24 (3) job_rcu_rtl lock-step; RI-23 per-unit records +
   block_report.py.
