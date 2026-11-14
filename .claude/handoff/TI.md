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
TI 435, RA 146, RI 81, OI 349, AR 351, OA 416, MA 54, IS 193, CP 157,
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
1. PF-47 + SFU pair, ti-sram 880f2d1c (backed up to gate-scratch/TI-sram), NOT pushed:
   PF-47 (base 1; RCU_ADDR 1, L1_WAKE 13, L1_CMPL 14), CCV_P_TIMEOUT_UOP (AR 352 (a):
   derive = CCV_P_TIMEOUT_MEMOP, require >=, on ccv_dec_ooe_uop; chain walk in its doc),
   8192 control needs memop AND uop to fire, RI's SFU pair 9f513f3b merged (held-over-r
   on warp 1). check-kernel, svh, ngd pass. AR 352 (4): before pushing, report uop and memop
   longest holds on UNBOUNDED cm32 and cm128 with AR 350 cond. 1. Running detached,
   binary scratchpad bin/ccv-skel-pf47sfu: /root/ccv-logs/cm32-pf47sfu.log and
   /root/ccv-logs/unbounded-pf47sfu.log (cm128; its cm32 leg failed: no oracle, ignore).
   Wait with gate-wait. Then: TI row to AR, MA, RA, OI, RI (holds, cycles, wall); then
   gate-push (scoped); AR re-books PF-33/PF-47. If cm128 uop hold > 20480: ask AR.
3. AR 350 cm128 unbounded is the run above (same report).
4. RA re:RI-46 (3): kill kernel with an SFU op in flight at the kill.
5. OA 413: when ooe_sched gets a parent, its check-ngd proves chas leaves
   ooe_rs from a flop. RI-21 (4): rcu_dec_pkg switch after sign-off.
