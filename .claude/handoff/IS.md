# IS handoff (ISA owner)

Updated 2026-10-31. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds IS's.

## Role and working rules
- IS owns the CCV ISA docs, not compiler code:
  custom-cuda-complier `docs/isa-v1.9-operation-map-and-encoding.md`.
  Raise ISA coverage and capability issues, propose efficiency features.
- Encoding or defined-semantics changes go to Daniel (DA) as decisions.
  Record his words verbatim; write adopted items as O-n (log, change
  summary, normative text). Notify the agents a decision affects.
- Branch `ccr-3868632d-p8esoz` in both repos. Merge commits only, never
  rebase or force-push. Push only after a clean gate: core
  `tools/regen.sh` then `tools/verify.sh`; compiler `ninja -C build` then
  `tools/verify.sh`. ISA-only commits: `python3 tools/check-docs.py`, run
  unpiped (a `| tail` once hid a failure).
- Merge rules (DA tab revs 78, 89; CP-69): merge every peer branch at the
  daily sweep, and between sweeps when a peer's pushed work bears on IS's.
  Fast-forward when the peer's head contains IS's; skip a merge whose result
  tree equals IS's own (`git merge-tree --write-tree HEAD <b>` against
  `HEAD^{tree}`); otherwise merge and gate.
- Cite register IDs (CP-n, TI-n) rather than branch-only F-numbers, which
  check-docs rejects until merged.
- Editing ISA text that a status-isa param in core `params/ccv_params.json`
  quotes: notify TI in the same turn (IS-11).
- Register: write only the IS tab (node 60e6f93a-7fdc; opens table
  m8yvbw8rqgz.106, responses table m8yvbw8rqgz.717); DA tab d5076b00-ef1b.
  Notices via `.claude/skills/register/notice.py`, `send_message` priority
  "later". Answer a ping once with `notice.py pong`; never answer a pong.
- Pings weekly, in the Friday sweep only (TI-49, DA 2026-10-30); the
  Saturday sweep checks Friday's pongs.
- Docs tool: a cell replace takes `with` and needs the block's `ifHash`
  and `ifRev`; target paragraph ids, not text ids.

## Daily sweep (scheduled task trig_015FmjgTTHxM4zTcmDTMf4tG, 02:23 PT)
Register section 4 from the bookmarks below; merges in both repos under
the rules above, gated; pings on Fridays; report in a few lines.

## Register bookmarks (revs read through)
Conventions 15, AR 256, OA 286, IS 180, TI 271, OI 239, CP 148, DA 97.
Pings: Friday 2026-10-30 to AR, OA, TI, OI, CP; all ponged. Next pings Friday 2026-11-06.
Read through the register-reader subagent; this file is the durable
bookmark store.

## State
- ISA decisions this cycle: O-73 to O-84. Latest: O-83 (interleaved
  per-thread memory, srd #3 %privoff, DA tab rev 95) and O-84 (address-taken
  frames in the bottom of the O-83 region, R15 = W, recursion refused,
  O-64 frame windows withdrawn, DA tab rev 97).
- Compiler branch fast-forwards to CP's head (CP-69's merge loop ended).
  A new agent RH has a handoff on core (ccr-c22116ce-1vzyjg). CP's snapshot d9ddd2c builds O-83 and O-84; TI pinned it.

## Open work (most urgent first)
1. TI-49 (2) and (3): OA rules on quieter notices and the register-reader
   subagent; follow the skill once it changes.
2. IS-14 item 2 (redux) waits on CP; item 3 (position hints) waits on
   PF-29's return.
3. IS-15: v1.10 work.
4. L1 size (AR-24): rests on TI's eight-trace sweep; not an ISA item, but
   IS reads it for any O-83/O-84 follow-up.
