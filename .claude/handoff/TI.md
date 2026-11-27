# TI handoff (top-level implementation)

Updated 2026-11-27. Keep this current at every task's end; it is what
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
The sweep merges fewest bases first, retries a merge past 300 s with
`-s resolve`, and past 8 bases picks the branch's own commits then records an
`-s ours` merge; an empty pick is skipped (be7c37b7). /home/user/ti-ret is
gone: run the sweep from /home/user/ti-rp.

## Register bookmarks
/home/user/ti-register-bookmarks.json (outside the repo). See the file (nested "bookmarks" object; keep updates there). Last row TI-592 (rev 594). Row insert payload: ops insert, target {"kind":"blocks",
"ids":["m8yvbw8rqgz.217"]}, side end, source {"as":"blocks","from":{"kind":
"inline","content":[tableRow of 4 tableCells, each a paragraph of text]}}.

## Long runs
Every long tool detaches and exits 5. Wait with `tools/gate-wait.sh <log>` as
a background task, timeout 7200000 (exit 3: rerun the wait; 4: rerun the job
with CCV_RESUME=1; RESUMED PASS counts as the full gate, Daniel 11-20).
Never run skeleton measurements beside a gate: on 11-23 a coremark run
(2.7 GB) beside check-cg (5.4 GB) OOM-killed the cg job and lost a 7 h gate.
bg-run dies with its 30-min wrapper; a measurement runs `setsid nohup` with a
background `while pgrep` wait.

## State (2026-11-27)
- Landed be7c37b7 on both branches (SCOPED PASS): the sweep's empty-pick skip,
  on the 11-27 sweep db54eeb6 (release 73edf5d5; tag refused, local only).
  Before it c0883a36: MA-34 (B) + AR 417 EXB 8, gate-scope ALWAYS_READERS
  (lint-rtl.py, check-1d.sh name rtl/rcu/ but run in s1d). MI-47's 8566e6ff in.
- TI-591 (RI-64): miu_form OOM is MI's clang++ fix 104678de, on MI's
  ccr-58815650-0ch1hh at 208e4c46, pushed after the 11-27 fetch. Task 90: when
  a landed tip has it, drop miu_form from tools/heavy-units.json.
- TI-592 (AR 422 (1)): colwalk-p1k control dropped. That kernel stalls at
  latency >=300 and has a stale-operand CHECK (seq 131 C_FADD R12 0x5d80):
  trace it to its owner (stub MIU/DCU or OOE) when no gate runs.
- Disk: scratchpad priv/ and ~/.cache/ccache untouched: ask Daniel first.
- Known: MIU-model rows on bank bounds are stub-MIU only (slotform,
  coremark128).

## In flight
- Nothing running. Next: task 90 after the next sweep; colwalk-p1k stall
  trace; then the open work below, plus DI-38 (1) (task 72, needs DI's spec),
  MI 29603c02 held-wait re-pin (task 80), AR 417 swap-class control (task 79),
  task 76 credit modules.

## Open work (priority order)
0. MI-12 order (Daniel via MI): all done (TI-506, 508, 509).
1. Task 55: OI-193/195's fix and decq_credit_lag knob (oi-sw 0fc3dc5a)
   land with OI's sweep merge. Then: lag 512 --cycles 200000 pass
   (mig_credit_wait>0) and mig-before-credits CHECK; due-epoch-lost; and check-kernel line for MI-11 (lnorm1 CCV_MIU_IMPL=model
   CCV_RAU_DEMOTE=mlc clean, parks>0, FET wait on). OA 462: binding dropped;
   once OI shows the released-slot CHECK catches it, --break
   mig-before-credits becomes the full-credit wait's control line.
2. Task 66 rest: once OI sets pc_kept in the OOE model, check-kernel
   at:11 lines for transp4 and narrowadd (pc_kept_launch>0),
   rau-pc-from-drained and OI's pc-kept-lost caught, a pc_kept_restore kernel.
   Task 69 rest: once DI sends the UE first answer and MI's 012519d8 is in,
   ue_second_answer>0 on ldpar CCV_DCU_UE_INJECT=1 for both MIUs and
   ue-close-first caught. Task 68: DI-33 (c) MLC stub probe injection per
   AR 409 (read it in full first). Then dcu-drop-credit / dcu-drop-answers
   controls once MI's drop sender lands.
3. Task 51 rest: MI-7 page-boundary kernel; MI-5 bins/slow regions.
4. AR 370 ccv_common_err RTL; task 28 RAS wrapper (BIST override, spare
   row/column, broadcast groups); AR 371 SPM banks; AR 392 PT base CSR
   with Q-50; AR 393; OI-187.
5. Low: RA re:RI-46 (3) SFU kill variant; RA 148 (post-sign-off).
