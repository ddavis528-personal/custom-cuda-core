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
TI 420, AR 348, OA 414, RI 71, MA 46 (2026-11-13). MA (MIU/DCU architect,
session_01QPk2jyUbWA7fW9YpUwqdxk) is not in the roster: notice.py says
none, so compose with --to AR and edit the header by hand.

## Long runs (DA, 2026-11-13)
Landed in a46afef7: every long tool (verify, gate-push, daily-sweep,
make-release) detaches itself and prints its job log. Wait with
`tools/gate-wait.sh <job log>` as a background task (exit 3 = still
running: rerun at once; 4 = killed by a container restart: rerun the job),
plus a send_later check-in. `tools/bg-run.sh <name> <cmd...>` for others.

## State (2026-11-13 ~13:50Z)
- Daily sweep 11-13 landed a46afef7 on both push branches (full clean gate
  PASS; release fb6d9f23; snapshot tag refused by the remote). It carries
  ti-detach, ti-ma (MA-5 entry-free credits 20dfbaf0) and ti-sram (SRAM
  macros 930f49e9) and every agent branch.
- Rows for all of it written at TI rev 420 (after a docs outage 13:45-14:20Z);
  notices sent to AR OA OI RA RI RH IS CP MA.
- RI-40 (rev 71): info only; RI's event-divergence line 'EVENTS DIVERGE'
  is not what TI's control greps; RI moves to gate-wait.sh.
- Worktree: ti-sram is the current one. Backups to gate-scratch/TI-<name>
  by plain push only (force-push is denied).
- Disk: deleting other sessions' /tmp/tmp.* was denied; ask the user.

## Open work (most urgent first)
1. Pongs: OI had not answered the 11-13 ping.
2. MI/DI homes when their first files land.
3. Older: RI-24 (3) job_rcu_rtl lock-step; RI-23 per-unit records +
   block_report.py.
