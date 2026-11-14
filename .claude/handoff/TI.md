# TI handoff (top-level implementation)

Updated 2026-11-14. Keep this current at every task's end; it is what
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
TI 434, RA 146, RI 81, OI 349, AR 351, OA 416, MA 54, IS 193, CP 157,
DA 119, Conventions 19 (2026-11-14). MA is session_01QPk2jyUbWA7fW9YpUwqdxk.

## Long runs
Every long tool detaches itself and exits 5 (never 0) when it does (OA-414,
518cb3c3). Wait with `tools/gate-wait.sh <job log>` as a background task,
timeout 7200000 (exit 3 = still running: rerun at once; 4 = killed by a
restart: rerun the job). Logs in /root/ccv-logs/.

## State (2026-11-14 ~16:00Z)
- Landed 11-14: 6061d0ee (RI-44), 7079fc14 (RI-49), 518cb3c3 (OA-414),
  then the daily sweep e48fa517 (full clean gate PASS; release ca10124c;
  snapshot tag refused by the remote, as always).
- Daily sweep conflicts were all .claude/handoff/RA.md: take RA's newest.
  scratchpad premerge.sh pre-merges every branch, keeping ours on RA.md.
- Local, ungated: gate-wait reads only verify-*.log (it printed NO RESULT
  for a sweep's release log); make-release prints its gate verdict. Rides
  the next gate-push.
- Worktree: /home/user/ti-sram. Backups to gate-scratch/TI-<name>, plain
  push only. Disk: deleting other sessions' /tmp/tmp.* was denied; ask.

## Open work (most urgent first)
1. SFU class (OI-145 (3)): TI's half on gate-scratch/TI-sfu 996866d1
   (worktree /home/user/ti-det, branch ti-sfu). RI merges it into
   ri-sfuclass and gates the pair; TI pushes nothing of it till then.
   OI-148: OOE's go; ring OI only if the joint gate fails an OOE check.
2. PF-47 (OI-145 (9)): CCV_LAT_RCU_ADDR_BASE 5 -> 1 (AR 351, RA 145);
   check-ngd ccv_rcu + ooe_wake, SV-hosted with RCU RTL; gate; row to AR,
   RA, OI (AR re-books PF-33/PF-47). If ooe_wake fails, ask OI for the fix.
3. AR 350 cm128 unbounded: the first run was OOM-killed (needs > 6.5 GB,
   ~6 h). Rerun ALONE (scratchpad bin/ccv-skel-memop20480, oracle
   scratchpad oracle/coremark128). Answer AR+MA: cycles, wall, max hold;
   widen the stub to 81920 (MA-14) only if hold > 20480.
4. RA re:RI-46 (3): kill kernel with an SFU op in flight at the kill.
5. OA 413: when ooe_sched gets a parent, its check-ngd proves chas leaves
   ooe_rs from a flop. RI-21 (4): rcu_dec_pkg switch after sign-off.
