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

## State (2026-11-08 ~21:30Z)
- 20:23Z container restart lost every local worktree (ti-g4, ti-ra43, ...),
  ~/ccv-logs and the scratchpad. ti-pmov rebuilt in /home/user/custom-cuda-core
  (branch ti-pmov), backed up to origin gate-scratch/TI-pmov (a NEW scratch
  branch: overwriting gate-scratch/TI needs a force-push). Back up every
  unpushed commit there before a long job.
- PUSHED 21b4b80 (RA-43 + register pmov) on both branches; TI 391 row and
  notices sent. J11b (TI 390) and J13 (TI 392) relayed; OA 399 closed J13.
- GATING ti-pmov full: 48033c1 merge RI 70cfd51 (rcudec::classOf + CAS copy
  check, PMOV in rcu_decode.h, RKind::Pmov appended = 18, rcu_dec_pkg regen),
  6ad84ca RA 119 (both RCUs refuse pmov ps1 != ps0; control pmov-ps1),
  3239f29 RA 124 schema text, a0b940d rcu_test kill-drain == params on
  RA-43's zero-cycle end (RI's file), d99127ec RI-21 (4) (params/ops.json,
  tools/gen-ops.py -> ccv_ops.h + ccv_ops_pkg.sv, --check/--selftest/
  --crosscheck; SV field cross_lane, opcode 9 bits, SRD_SEL0..3).
  On PASS: TI row; notices RI (OI-18: merge edits, rcu_test fix; ccv_ops_pkg
  can replace gen_dec's package) and RA (119, 124 done). On FAIL: gate-triage.
- User (2026-11-08): "Clear anything required to make room" - disk clearing
  for space is approved (caches, others' /tmp dirs included).
- ti-miu4-local (MIU counters + MULTI) was lost in the restart; it was never
  to be pushed anyway.

## Open work (most urgent first)
-3. 2026-11-03: register rows answered this sweep: RA-37/38 (TI rev 290;
   RI support, task #62), OA-24 (291; ROB split), IS-26 (292) and OA's
   sweep-gate (293; the memory bug), OI-103 (294). Then #52 RA-36/AR
   re:RA-10, #59 ADDR_BASE=1 after OI's ooe_wake fix, #60 port traces.
   Container restarts kill detached gates: arm a send_later check-in for
   every long gate.
-2. 2026-11-01 evening (DA): CI runners died on OI's 2b (runs 538/543/544,
   no logs; NGD+CG on full ooe_rob OOM a 16 GB runner). Built heavy-unit
   lock 0facb89 (CCV_HEAVY_SERIAL=1 in ci.yml, tools/heavy-units.json,
   light limit 2 GB) and gate-scratch.sh ca27c87/6d4a2ae (OI-102; DA chose
   a scratch branch; proxy refuses branch delete (403), so no drop;
   gate-scratch/TI left on origin, CI run 551 on it from 0facb89).
   LOCAL, NOT PUSHED: trial full gate on OI 2b tip + lock in /home/user/ti-coll
   (logs /home/user/ccv-logs/trial), then gate-push --full, then TI rows:
   OI-102 answer + every agent's sweep skips gate-scratch/* (notify all).
   Asked DA: enable the lock for local gates too (sweep) - unanswered.
   Then after the 02:11 sweep: AR re:RA-10 (delete rcu_miu_width, close
   Q-18), RA-16 (schema/params, task list), AR re:RA-11 PHYS_REGS sweep.
   New agent RA (RCU architecture), tab 9851686b-2b0a, read rev 30; AR tab
   read rev 262; OI rev 252.
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
