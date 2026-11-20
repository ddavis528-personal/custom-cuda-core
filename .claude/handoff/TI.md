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
/home/user/ti-register-bookmarks.json (outside the repo). 11-20: TI 503,
AR 401, OA 462, OI 395, DA 128, MA 135, MI 18, DI 16, RA 157, RI 91, CP 160,
IS 201, Conventions 20. Last row TI-504.

## Long runs
Every long tool detaches and exits 5. Wait with `tools/gate-wait.sh <log>` as
a background task, timeout 7200000 (exit 3: rerun the wait; 4: rerun the job
with CCV_RESUME=1; RESUMED PASS counts as the full gate, Daniel 11-20).

## State (2026-11-20, evening)
- Landed e8d8864b (ti-mi9b): MI/DI model hooks, OI's straggler walk.
- 11-20 sweep: /home/user/ti-size, log
  /root/ccv-logs/job-daily-sweep-20261120-165456-13572.log (release gate on
  8c378e12). It carries daily-sweep.sh's merge fixes (41d39cf0, 93adeee1):
  fewest merge bases first; a merge over CCV_SWEEP_MERGE_TIMEOUT retried with
  -s resolve; past resolve's 8 trees, the branch's own commits picked and an
  -s ours merge (AR's branch, 7 bases, needed it).
- ti-wp (/home/user/ti-wp, branch ti-wp; backups on gate-scratch/TI-bank) is
  the next gate-push, after merging the sweep's result: TI-504's IMPL_PINS
  rows and mig-before-credits (from ti-oo), MA-25 (ccv_dcu_miu_cred, QDEPTH
  16, STDATA 12, stub holds/returns, controls bank-credit-ignore,
  dcu-extra-credit), MI-9 (3) waypred kernel + DI's wp-late-at-due fix,
  MI-8 (+ccv_eot_mce on mce_taken; controls mce-no-exempt, miu-keep-credit),
  MI-4 A2/A3 (provswap; fet-reset-on-kill per set via IMPL_PINS). Stub
  check-kernel 365 PASS. Then: landing row to DI (DI-6 asked to be rung with
  the branch), MI (MI-12 order items 2-5), MA (MA-25 spec tabs), RA (TI-499).
- Known after landing: the MIU model (no credits spent until MI's step 5)
  trips the stub DCU's bank bound on slotform/coremark128; pair clean.
  MI-4's replay drain stall and vadd4 still need scenarios from MI.

## Open work (priority order)
0. MI-12 order (Daniel via MI): MA-25, MI-9 (3), MI-8, MI-4 model-side,
   MI-7 cold-TLB. First four in ti-wp; MI-7 next.
1. Task 55: after OI's AR 397 / OA-460 fix (demoting warp keeps its tier-1
   slot) lands: check-kernel line for MI-11 (lnorm1 CCV_MIU_IMPL=model
   CCV_RAU_DEMOTE=mlc clean, parks>0, FET wait on).
2. MI-4 (B) / task 47: demotion vs barrier (transp4 CCV_RAU_CONCURRENT=1
   at:750; narrowadd), likely TI's SYU/RAU stubs.
3. MI-8: quiescence exemption for a machine-checked run, with a control.
4. MA-25: DCU per-bank credits (BANK_QDEPTH 16, BANK_STDATA 12, two 8-bit
   credit-return vectors), stubs, bin, control.
5. Task 51: MI-9 (3) way-mispredict kernel + MI-7 page-boundary kernel;
   MI-5 bins/slow regions; MI-7 cold-TLB runs.
6. AR 370 ccv_common_err RTL; task 28 RAS wrapper (BIST override, spare
   row/column, broadcast groups); AR 371 SPM banks; AR 392 PT base CSR
   with Q-50; AR 393; OI-187 / OA-452.
7. Low: RA re:RI-46 (3) SFU kill variant; RA 148 (post-sign-off).
