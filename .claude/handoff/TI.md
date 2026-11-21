# TI handoff (top-level implementation)

Updated 2026-11-20 (evening). Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds TI's.

## Working rules
- Push only to `ccr-183cc441-doowtf` and
  `claude/custom-cuda-core-infra-6msg93`, only through
  `CCV_PUSH_BRANCHES=ccr-183cc441-doowtf,claude/custom-cuda-core-infra-6msg93
  tools/gate-push.sh` or `tools/daily-sweep.sh` with the same env (ALWAYS set
  it for the sweep). No PRs, no force-push of a working branch, never ungated.
  Ungated backup: `git push -qf origin HEAD:refs/heads/gate-scratch/TI`.
- Never bare `git stash`. Never edit a worktree while a gate, check or sweep
  runs in it (`ps aux | grep -E 'check-|gate-|verify|daily'`). One heavy job
  at a time (15 GB container).
- Never merge another agent's gate-scratch branch wholesale (OI's ungated RTL
  broke ti-mi9, 11-20): take only the commits or paths needed.
- Deleting other agents' /tmp/tmp.* was denied by the auto-mode classifier:
  don't work around it; ask Daniel if space is needed. Scratchpad priv/ is
  unknown: leave it.
- Commits end with the Co-Authored-By and Claude-Session lines from the
  session's attribution reminder. No model ids in commits or artifacts.
- Edits to OI's files (sim/ooe/*) follow OI-18: edit, then notify OI.
- Record a DA decision only on Daniel's word or a DA-tab entry.
- Register: write only the TI tab (node e8b1d9d9-df9b; responses table
  m8yvbw8rqgz.217). Writes need container {"kind":"project","id":
  "JApHYjaUESeq8tsGMGXMU5"}. Notices via `.claude/skills/register/notice.py
  compose`, `send_message` priority "later". Pongs: `notice.py pong --me TI`.
- Notices' rows: `register-reader` subagent; gate red: `gate-triage`.

## Daily sweep (scheduled task trig_01A8r3ENUjnLyTaNUcc23ZbF, 02:11 PT)
Register section 4 from the bookmarks; then the repo half (daily-sweep.sh,
detached; wait with gate-wait). Exit 3 = a real conflict to resolve.
Since 7b0bbe2a (ti-oo, not yet landed) the sweep merges fewest merge bases
first and retries a merge past CCV_SWEEP_MERGE_TIMEOUT (300 s) with
`-s resolve`. Until it lands: a merge hung for minutes = kill the sweep,
`git merge -s resolve` that branch by hand, rerun the sweep (11-20: OA's
4-base branch hung 25 min; resolve took 0.15 s).

## Register bookmarks
/home/user/ti-register-bookmarks.json (outside the repo). 11-21: TI 505,
MI 20, DI 19; the rest as of the 11-20 sweep. Last row TI-507.

## Long runs
Every long tool detaches and exits 5. Wait with `tools/gate-wait.sh <log>` as
a background task, timeout 7200000 (exit 3: rerun the wait; 4: rerun the job
with CCV_RESUME=1; RESUMED PASS counts as the full gate, Daniel 11-20).

## State (2026-11-21)
- Landed d761c634 (ti-wp, SCOPED PASS on the 11-20 sweep 8c378e12): DI-6's
  pins, MA-25, MI-9 (3) waypred, MI-8, MI-4 A2/A3, TI-499's sweep fallback.
  TI-506 posted; DI, MI, MA, RA rung.
- Landed 836d3f89: impl_pins substitutes every pinned bin (DI re:TI-506;
  TI-507).
- The 11-20 release is 078f102d; the remote refused its tag
  snapshot-2026-11-20-8c378e1 (local only, in /home/user/ti-size).
- Disk: the first gate-push died of a full disk; freed ti-bench and ti-hooks
  synth caches and old scratch dirs (13 GB free). scratchpad priv/ (4.3 GB)
  and ~/.cache/ccache (5.1 GB) untouched: ask Daniel before clearing.
- Known: the MIU model (no credits spent until MI's step 5) trips the stub
  DCU's bank bound on slotform/coremark128; those lines are stub-MIU only.
  MI-4's replay drain stall and vadd4 still need scenarios from MI.

## Open work (priority order)
0. MI-12 order (Daniel via MI): first four landed (TI-506); MI-7 cold-TLB
   next (task 49), with its page-boundary kernel.
1. Task 55: after OI's AR 397 / OA-460 fix (demoting warp keeps its tier-1
   slot) lands: check-kernel line for MI-11 (lnorm1 CCV_MIU_IMPL=model
   CCV_RAU_DEMOTE=mlc clean, parks>0, FET wait on).
2. MI-4 (B) / task 47: demotion vs barrier (transp4 CCV_RAU_CONCURRENT=1
   at:750; narrowadd), likely TI's SYU/RAU stubs.
3. Task 51 rest: MI-7 page-boundary kernel; MI-5 bins/slow regions.
6. AR 370 ccv_common_err RTL; task 28 RAS wrapper (BIST override, spare
   row/column, broadcast groups); AR 371 SPM banks; AR 392 PT base CSR
   with Q-50; AR 393; OI-187 / OA-452.
7. Low: RA re:RI-46 (3) SFU kill variant; RA 148 (post-sign-off).
