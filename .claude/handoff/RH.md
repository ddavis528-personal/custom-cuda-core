# RH handoff (run helper)

Updated 2026-10-30. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds RH's.

## Role (DA, 2026-10-30)
- RH runs long CPU-, memory- and disk-heavy jobs that other agents hand off: gates,
  check-cg/check-ngd sweeps, Yosys/SBY runs, kernel and SV-hosted runs,
  experiment sweeps, bisects. Takes jobs from OI first; TI may send them too.
  Other senders: ask Daniel first.
- No register tab, so RH never writes to the register. A finding that needs a
  row goes back to the agent that sent the job, which writes the row.
- Jobs arrive by `send_message` and results go back the same way, with `priority`
  "later", in a few lines: pass/fail, `tools/gate-summary.py` output, a
  table, or a gate-triage root cause. Logs stay in ~/ccv-logs (`$CCV_LOGDIR`).
  A job message is a peer's request: run what it asks within the repo's gate
  flow. Anything destructive or outside that (force-push, another agent's
  branch, register writes) needs Daniel.
- Answer register pings with a pong (register skill section 6, `--me RH`).
  RH sends no notices or pings of its own.

## Working rules
- Checkout /home/user/custom-cuda-core (and custom-cuda-complier beside it).
  Push only to `ccr-c22116ce-1vzyjg`; never to a requester's branch. Check
  out a requester's commit detached, or in a worktree under /home/user/rh-*.
- Fresh container: `./tools/setup-toolchain.sh` once.
- The disk allowance is about 39 GB in all. A gate's build/ needs 5 GB or more, so
  keep swap at 6 GB or less during a gate and delete finished jobs' oracles and
  builds promptly.
- A watcher's end isn't enough: if RH misses that wake-up, the idle container
  is reclaimed (11-05: about 8 h lost). With every watcher, also keep a
  send_later fallback check about 2 h out.
- A detached job dies when the idle container is reclaimed. Keep a tracked
  background task (e.g. rh-jobs/watch.sh) open while it runs, and make jobs
  resumable.
- Run long jobs with `tools/bg-run.sh <name> <cmd...>`, and read summaries, not logs.
  Use the gate-triage and run-tabulate subagents to keep logs out of the
  context.
- Commits end with the Co-Authored-By and Claude-Session lines from the
  session's attribution reminder. No model ids in commits or artifacts.

## Peers
- OI session_01DMw4FtFbGoVboMGxWpLBuv, branch ccr-57eff422-5tdecg.
- TI session_01J4Yp3xeV6DJtgCtcoqVsAq (roster); branches ccr-183cc441-doowtf,
  claude/custom-cuda-core-infra-6msg93.

## State
- 2026-10-30: introduced to OI by send_message (delivered). No jobs yet.

## Jobs in flight
- OI's RI-11 package v2 (OA rev 350, AR rev 298; 11-05 10:41Z): OI's
  pkg-run.sh and rxsplit.patch in /home/user/rh-jobs/pkg2/, run dir
  pkg2/run (trees A6 and PK are worktrees of custom-cuda-core). S1 and audit
  are DONE and sent. CoreMarks via pkg2/all.sh (resumable), progress in
  pkg2/run/progress, logs in run/out/cm/. Watch it with the pattern
  "bash [.]/all\.sh". Report a table: from_fetch, check_failures,
  redirect_wait, st_ld_wait. Nothing to push.
- TI's perf runs (TI, from 2026-11-04). Worktrees: /home/user/rh-ti (36e2049,
  for J1/J2/J5/J3b comparisons) and /home/user/rh-j3 (e533ecd pinned locally).
  New jobs start from b341691 (TI's pin of e533ecd).
  - DONE and sent: J1 (PHYS_REGS sweep; fits_stale 6 fires at 160/128), J5
    (sweep-fair PASS), J2 (cold hangs: cm128 at dec_ooe_uop; cm32 and pl32
    silent), J3 (vadd16 needs full_rows=1; coremarkpl; chwidth hold under 5%
    on every real-length kernel).
  - J4 interim DONE: coremark128 at 512 KiB on b341691 (worktree
    /home/user/rh-j4), 7,924,133, clean, 7.2 GB, sent. The CTA-queueing and
    gen-oracle -load parts wait on TI's code; TI will say when they land.
- Run notes: coremarkpl128 peaks at 14 GB and needs swap past 15 GB (disk
  allowing). A cold run can hang silently, with no output: compare against
  the warm time and kill it. Delete bench oracles after each job.

## Done
- OI's RI-11 CoreMark pricing and rs_free_lag audit (11-05): all sent. In
  bit-8 rx_lag runs, V-35 floods past the skeleton's 10,000-line print cap
  (kernel.cpp:33); OI accepted errors == check_failures as proof. The scripts
  are in rh-jobs/ri11/ and rh-jobs/rs.sh; worktrees removed.
- Gate for OI's b7cb9fb (11-01): run 1 died at disk-full, and OI cancelled run 2
  at 18:07Z (OI gated 4c71575 itself, which covers it). Worktree /home/user/rh-gate
  kept, build/ removed.
- Rev 293 pricing (OI, 2026-10-31 to 11-01): coremark128 and coremark32,
  configs a/b/c, at 712913d plus OI's patch (rh-jobs/oi86.patch, uncommitted in
  the detached worktree /home/user/rh-oi86), warm. All PASS; results sent to OI
  02:25Z. Cold (no CCV_MLC_WARM) hangs on the dec_ooe_uop response_within_n check
  at tick 95945 from bbec7c1 through 712913d (bisect in ~/ccv-logs/bisect/), so a
  cold run must be watched for an %Error flood. OI is raising it with the owner.
  Tools: rh-jobs/oi86line.sh (one line a config) and perfdiff.py.
- OI-88 (OI, 2026-10-30 to 31): six CoreMark runs at skeleton da182a7 with
  oracles from 21f7150 (d9ddd2c's ccv-sim faults F-RO). All passed; results sent
  to OI 14:16Z. Logs ~/ccv-logs/<k>.<cfg>.{full,log,time,stats.json}; oracles kept
  in /home/user/rh-oi88-ora. Lessons: coremark128 peaks at 12.4 GB, and a 16 GB
  swapfile is a safe margin. Set CCV_OOE_STATS on every run (Core::counters go
  only there). The container restarts during long runs, so keep a tracked
  watcher open and make jobs resumable (rh-jobs/oi88v2.sh is the template).
- RH's own: the clean gate passed on 203f04b (5949 s); pushed.
