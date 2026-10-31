# TI handoff (top-level implementation)

Updated 2026-10-31. Keep this current at every task's end; it is what
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
Conventions 15, AR 260, OA 292, IS 182, TI 279, OI 246, CP 149, DA 97
(sweep 2026-10-31: nothing new for TI). Latest TI open: TI-50 (rev 272).
Pings are weekly, on Fridays (DA, 2026-10-30); Saturday's sweep checks the
pongs. Pings 2026-10-30 sent to all five; all ponged ok.

## State
- Tip of both branches: 5e7c8db (OI-95: ABC cache, parallel map/map -r, scoped gate; DA confirmed in TI's session 2026-10-31; TI rev 279), on 43d92b3, on 80697a3 (AR rev 260 branch lead + slot_fields step A; TI rev 277, notices to AR/OI/OA), on f77582b (b0d91c2 shfl lat_class 5), on a17c736 (gate-push clears on red), on 16af94a (OI-93), on 61339a2 (8dd82a6 session-home), on 3fbb402 (sweep 2026-10-31: 45 commits merged from
  five branches; release b2f4e58), with 47e2622 (OI-92), on c5a1fc0 (OI-91: bench ENTRY 0x332c, gen-oracle
  refuses a stale ENTRY), on 63a7bd5 (autoCompactWindow 400k), on c69475e
  (scripts and subagents), on 5bd4397 (handoff hook), on 6ba08b1 (OI-85 row-indexed dones, OA rev 282). Before: 5fe7177 (W, IS-24/IS-25, TI-47 (a)). Last release 536a893.
- Compiler pin d9ddd2c (source f5fa030; O-83, O-84).
- Frame-interleave experiment done: coremark32 -7.1%, coremark128 -15.7%
  at 64 KiB; at 512 KiB frames -16.9%, both fixes together -22.8%.
- OI's check-cg scope fix (9c079f9): reviewed 2026-10-31, sound (scoped key, base-name fallback, control 15b).
- Settings: sessions' project dir is /home/user, so the repo's
  .claude/settings.json and .claude/agents do not load (2026-10-31). Fix:
  the session-home skill (tools/setup-session-home.py, 8dd82a6); each agent
  runs it once with DA's approval (DA chose this, 2026-10-31), and
  `--check` in its daily sweep. TI's is installed (--check matches); subagent
  types load only at the next session start. TI-50 (rev 272) asks the other
  five; notices sent 2026-10-31. Installed: TI, IS (IS rev 182), CP (CP-74),
  OA (OA rev 288). Waiting: AR, OI.

## Open work (most urgent first)
-1. Done 2026-10-31: shfl lat_class 5 (b0d91c2) and AR rev 260's lead +
   slot_fields step A (80697a3; TI rev 277). Open from it: step B (narrow
   generated ports/nets per slot, ~50 c["bits"] sites) deferred until a
   repeated link or the RTL needs it. OI-96: br_lead_tid_ never erased;
   OI carries the fix at its merge (TI rev 278): TI leaves ooe_block.cpp.
   Side worktree /home/user/ti-coll: scratch for trials.
   Background runs: pass timeout 7200000 to a gate-push (default 30 min
   kills it).
0. Disk: a clean gate needs ~11 GB of the session's allowance; keep
   /home/user/sweep small (oracle13's 4 GB filled it on 2026-10-31). A red
   gate left 16 GB in build/: gate-push now clears it on red too, keeping
   build/verify in $CCV_LOGDIR.
1. TI-48 (TI rev 266): all five handoffs in (files checked in each commit,
   2026-10-30); `"autoCompactWindow": 400000` set in .claude/settings.json.
   Pushed 63a7bd5; TI-48 closed (TI rev 269); CP added the key in
   custom-cuda-complier 64c36f6 (CP-73). Done. This session: /autocompact 500k.
   Answered: AR (62443b5, AR rev 256; also took TI-49), OA (9d2bd00, OA rev
   285; the register skill takes TI-49 (1)-(3) in the same commit), CP
   (compiler 8ebd324, CP-72 at CP rev 147; roster copy checked in its sweep;
   Friday pings), OI (b65a558, OI rev 235; Friday pings; agreed 6ba08b1's
   OI-18 edit), IS (dc2ff40, IS rev 180; Friday pings).
2. Usage (DA, 2026-10-30): scripts and subagents are in (CLAUDE.md, The gate;
   Context and handoff). Still to propose: the sweep as its own cheaper
   session (needs a way for pongs to come from the roster's session).
   TI-49 (open, TI rev 267): Friday pings (DA's); proposals to OA: ring only
   rows that ask the receiver something, read notices via register-reader.
   Notices for TI-48 and TI-49 sent to all five 2026-10-30.
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
