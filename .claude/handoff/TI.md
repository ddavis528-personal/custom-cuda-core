# TI handoff (top-level implementation)

Updated 2026-10-30. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds TI's.

## Working rules
- Worktree /home/user/ti-ret. Push only to `ccr-183cc441-doowtf` and
  `claude/custom-cuda-core-infra-6msg93`, each after
  `git merge-base --is-ancestor origin/<b> HEAD`. No PRs. Never bare `git stash`.
- `./tools/regen.sh` and commit what it changes, then a clean
  `./tools/verify.sh` (or make-release's gate), before every push.
- After a push, clear build products but keep build/compiler and
  build/compiler.git.
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
Register section 4; merge all remote branches but release, regen, commit;
`tools/make-release.sh --push`; push both branches; clear build; pings and
pongs; report in a few lines.

## Register bookmarks (revs read through)
Conventions 15, AR 250, OA 279, IS 176, TI 252, OI 234 (FYI re:OI-85,
re:OI-89; OI-89 closed), CP 143, DA 96. Latest TI open: TI-48.
Pings 2026-10-30 sent to all five; all ponged ok.

## State
- Tip of both branches: 6ba08b1 (OI-85 row-indexed dones, OA rev 282).
  Before it: 5fe7177 (W, IS-24/IS-25, TI-47 (a)). Last release 536a893.
- Compiler pin d9ddd2c (source f5fa030; O-83, O-84).
- Frame-interleave experiment done: coremark32 -7.1%, coremark128 -15.7%
  at 64 KiB; at 512 KiB frames -16.9%, both fixes together -22.8%.
- OI pushed 9c079f9 (ROB slice 1, check-cg scope fix + cg_fx_gen control):
  review that check-cg patch when the sweep merges it.

## Open work (most urgent first)
1. Context handoff (TI-48): the shared `autoCompactWindow` 400000 goes in
   `.claude/settings.json` only once every agent has reported its handoff
   in the register (DA, 2026-10-30). This session is at 500k by /autocompact.
2. Usage reductions DA asked about 2026-10-30, not yet approved: sweep and
   gate-push scripts, gate-log summarizer, register digest, sweep as a fresh
   cheaper session, notice-receive subagent.
3. AR-24 capacity sweep on CP-64's eight traces (#46): frames in place
   only plus one interleaved equality check; 64 KiB at hit base 7 vs
   512 KiB at bases 7/8/9. Needs CTA queueing past resident slots and
   gen-oracle `-load`/init records. Scratch in /home/user/sweep.
4. OI-86 (b), if DA takes it: RCU-only done at fixed slot
   CCV_DONE_SLOTS-2 in the stub, plus the lead field.
5. Barriers (TI-40): SYU stub, RAU alloc/exit, DEC bar rows (in progress).
6. Held or pending: layernorm (held by AR rev 143); IS-20 narrow-source
   control; IS-21 atomics; MIU .shared mod 2^32 and .global F-ADDR (CP-33,
   O-75); csa DUAL=1 after OI; AR-24 follow-ups; gate kernels
   coremark-derived-pl-fault and ld.pred.local (AR rev 171); DCU channel
   rates from CCV_DCACHE_LOOKUPS.
