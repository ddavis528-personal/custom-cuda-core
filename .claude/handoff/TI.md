# TI handoff (top-level implementation)

Updated 2026-11-07. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds TI's.

## Working rules
- Worktree /home/user/ti-ret. Push only to `ccr-183cc441-doowtf` and
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
Full bookmarks and ping records: /home/user/ti-register-bookmarks.json
(outside the repo, so the sweep's clean-tree check is not tripped).
Conventions 17, AR 321, OA 380, IS 190, TI 377, OI 324, CP 156, DA 115,
RA 96, RI 34 (2026-11-07 evening). Latest TI open: TI-51 (rev 346).
Pings are weekly, on Fridays (DA, 2026-10-30); Saturday's sweep checks the
pongs. Pings 2026-11-06 sent to AR OA IS OI CP RA RI; all seven ponged ok.

## State (2026-11-09 ~08:30Z)
- PUSHED on both branches, in order: 5271c5e7 (RA 119, RA 124, RI-21 (4)
  ops.json/gen-ops, RI 70cfd51 merge, rcu_lanes floors, bank_slice heavy),
  ea8ae6f1 (RST-2 reset same-cycle check, DA 2026-11-09; kill_valid wake tap
  at 12 + *_wake bounded, AR 336), 4d6065fd (per-field lead budgets, DA 116
  13 RCU / 0 OOE), 7b003e98 (RI-31: lead_phys_src2 copy S0-S3, lead_sec_mask
  exact). TI rows 393-400 written and notified.
- Worktrees: custom-cuda-core, ti-ops, ti-lead, ti-src2 (all at pushed tips).
  Back up unpushed work to origin gate-scratch/TI-<name> (new branches; an
  overwrite needs force-push, denied). Container restarts lose local work.
- User (2026-11-08): "Clear anything required to make room". A gate's cg
  section leaves ~15 GB in build/cg; delete finished sections' build dirs and
  ccache when free disk drops under ~5 GB mid-gate.
- RI-23 (TI 393): TI takes block_report into tools/ once ri-blkrpt lands:
  check-cg/check-ngd write per-unit group/NGD records at a clean gate.
- RI-24 (TI 394): TI owes (1) ccv_rcu.sv into SV-hosted under CCV_RCU_RTL on
  RI's push, (2) shims drive _wake high into RTL receivers now, a staged
  one-cycle lead later, (3) job_rcu_rtl block lock-step from
  ccv-skel --port-dump VCDs + event-log diff.
- RI follow-ups: rcu_core.cpp:317 superset -> equality, then run
  lead-sec-superset on the model RCU too. OI: FS=1 freelist units (TI 397).

## Open work (most urgent first)
1. RI-24 (3) job_rcu_rtl lock-step harness; (2) shim _wake.
2. RI-23 per-unit records + tools/block_report.py.
3. #97 ri-sfu merge with its four check-rcu-unit controls.
4. Blocked: #59, #78, #22, #33, #96 (ccv_rcu.sv), #41, #34/#38/#46.
