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
0. Branch ti-nohit (worktree /home/user/ti-sram) 5cf502aa, backed up to
   gate-scratch/TI-sram, NOT pushed: AR 356 (1) stub MIU MA-4 eligibility +
   early no-hit at CCV_LAT_L1_NOHIT, held completion, OOE l1_nohit on in the
   skeleton (OI's ooe_block.cpp: notify OI on landing), bins l1_inelig/l1_nohit/
   l1_nohit_drop + --break no-nohit, advance() one-line loads first (TI-440).
   check-kernel passes. Pin a9241c2 + -priv benches (incl. coremarkpl32priv).
   Perf job /root/ccv-logs/nohit-priv.log: cm32priv k0=k1=2,253,475 (l1_inelig 0:
   -priv coalesces, the knob does nothing). cm128priv k1 OOM-killed by the bisect;
   k0 running (wait task b73mbp07u). If k0 shows l1_inelig=0, k1 is identical by
   construction: no rerun. Then: TI row to AR (cc OI, MA), gate-push.
   Also queued: RA 148 stub RCU address from CCV_LAT_RCU_ADDR_BASE (+ RTL refusal).
   AR 355 (2) done: TI 443; AR 359 closed it. AR 359 (4) asks: name the block
   behind cm128priv's 672 operand CHECKs (64 KiB, perfect fetch, warm MLC; 21
   uops, operand 0, all 32 lanes, never reexec'd, no def mismatch) and raise it
   in the owner's tab (may be AR 355 (3)'s seq 179681, OI's). Job
   /root/ccv-logs/opchk.log (scratchpad/opchk/run.sh): model, CCV_RCU_IMPL=stub,
   CCV_OOE_IMPL=stub, serial after nohit-priv's pid 16531.
   Daily sweep 11-15: register quiet; repo half (daily-sweep.sh) deferred while
   the perf run holds the machine; run it from a fresh worktree.
1. OI-149 done (58d758ce). AR re-books PF-47/PF-33 from AR 356 (1)'s runs.
2. RA re:RI-46 (3): kill kernel with an SFU op in flight at the kill.
3. OA 413: when ooe_sched gets a parent, its check-ngd proves chas leaves
   ooe_rs from a flop. RI-21 (4): rcu_dec_pkg switch after sign-off.
