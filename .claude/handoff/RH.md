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
- TI's perf runs (TI, 2026-11-04; DA: all of TI's performance runs go to RH).
  Detached worktree /home/user/rh-ti at 36e2049 (tip of ccr-183cc441-doowtf).
  Commit nothing; params edits stay local. One small table per job to TI,
  priority later. TI writes the register.
  - J1 (RA-11): CCV_P_PHYS_REGS 192/160/128; every S1 kernel in build/oracle plus
    coremark32 and coremark128, warm, with CCV_OOE_STATS. Rename stalls are
    stall.gpr_empty/floor/ceiling/buffer and stall.share.names. Running
    rh-jobs/j1.sh from 12:40Z (resumable by value); logs in ~/ccv-logs/j1/.
  - J2: coremark32/128/pl32 warm and cold, plus CCV_DCU_WAYS=8 warm. A cold
    dec_ooe_uop hang is a result.
  - J5 (after J1, before J2): tools/sweep-fair.sh 0 32 48. Send TI the lnorm1
    row, pass/fail, and the table if it's small.
  - J3: the hold cost (hold.chwidth / cycles from the J1/J2 stats) is approved.
    vadd16 is BLOCKED: the pinned snapshot has only LLVM-style asm, which
    ccv-as rejects; TI is asked for a CP export. chwidth.multi 12288 is a
    register mask (r12, r13), not n. Local configs are in
    /home/user/rh-jobs/local-bench/ (vadd16w4, vadd16loopw4, coremarkpl128,
    whose oracle passes at 4.4 GB). coremarkpl32/128 runs are proposed for
    after J2; waiting on TI's OK.
  - J4: blocked on TI code (CTA queueing, gen-oracle -load). Meanwhile only
    coremark128 at 512 KiB with frames, if there's a frames knob.
  Order J1, J2, J3, then J4. Delete oracles and builds after each job.

## Done
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
