# IS handoff (ISA owner)

Updated 2026-11-13. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds IS's.

## Role and working rules
- IS owns the CCV ISA docs, not compiler code:
  custom-cuda-complier `docs/isa-v1.9-operation-map-and-encoding.md`.
  Raise ISA coverage and capability issues, propose efficiency features.
- Encoding or defined-semantics changes go to Daniel (DA) as decisions.
  Record his words verbatim; write adopted items as O-n (log, change
  summary, normative text). Notify the agents a decision affects.
- Branch `ccr-3868632d-p8esoz` in both repos. Merge commits only, never
  rebase or force-push. Push only after a green gate. Core (OI-95, DA
  2026-10-31): a between-sweep push takes the scoped gate
  (`tools/gate-push.sh`, SCOPED PASS); the sweep's merge takes the full
  clean gate (`tools/gate-push.sh --full`, PASS). Compiler: `ninja -C
  build` then `tools/verify.sh`. ISA-only commits: `python3 tools/check-docs.py`, run
  unpiped (a `| tail` once hid a failure).
- Merge rules (DA tab revs 78, 89; CP-69): merge every peer branch at the
  daily sweep, and between sweeps when a peer's pushed work bears on IS's.
  Skip release and gate-scratch/* (OI-102, DA 2026-11-01: unverified scratch
  commits, never merged or gated).
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

## Gate timing
Disk (2026-11-09): the session allowance is ~39 GB and a full gate's build/
peaks near 22 GB (cg alone 13 GB); one gate died 'No space left on device'.
Before a full gate, if df shows under ~25 GB free: clear build/ but
synth-cache/compiler/compiler.git, and `ccache -C` (5 GB). Kill a stuck gate
by its process group (setsid gives it one): kill -TERM -- -<pgid>.
The core full gate can pass 2 h, the background-task limit: start it with
setsid nohup tools/bg-run.sh is-sweep-gate tools/gate-push.sh --full, then
wait in 2 h slices. TI gates-detach (TI 418, 2026-11-13): never run a gate as a background task; setsid nohup ... &, watcher `while kill -0 <pid>`, TI-420 (a46afef7, 11-13): long tools now self-detach; wait with tools/gate-wait.sh <job log> as a background task (exit 3 = rerun the wait, 4 = gate killed). TI re:OA-414 (rev 429): a sweep begun before a46afef7 can push ungated; IS sweeps merge ccr-183cc441-doowtf (TI) first, then check whether gate-push --full detaches (wait with gate-wait.sh) before trusting its exit code. tools/heavy-units.json is TI's: on a conflict there,
take TI's branch's version.

## Daily sweep (scheduled task trig_015FmjgTTHxM4zTcmDTMf4tG, 02:23 PT)
Register section 4 from the bookmarks below; merges in both repos under
the rules above, gated; pings on Fridays; report in a few lines.

## Register bookmarks (revs read through)
Conventions 19, AR 348, OA 414, IS 193, TI 419, OI 341, CP 157, DA 119, RA 136, RI 70, MA 46.
RA (RCU architect, tab 9851686b-2b0a, session session_01QPk2jzLmjd3MWXjayVUy9d;
now in the roster). RI (RCU implementation/model, tab 8e4547bc-c469) is new.
Pings: Friday 2026-10-30 to AR, OA, TI, OI, CP; all ponged. Pings Friday 2026-11-06 sent to AR, OA, TI, OI, CP, RA, RI, RH ; all eight ponged, checked 11-07 with notice.py check. Pings Friday 2026-11-13 sent to AR, OA, TI, OI, CP, RA, RI, MA, RH (MA now in roster, session_01QPk2jyUbWA7fW9YpUwqdxk); all nine ponged 11-13, each checked with notice.py check (Saturday check done). Next pings Friday 2026-11-20.
Read through the register-reader subagent; this file is the durable
bookmark store.

## Session home (TI-50)
Installed 2026-10-31 with Daniel's approval: python3 tools/setup-session-home.py
(writes /home/user/.claude: 400k window, handoff hook, agents link).
Daily sweep runs --check; on exit 1 ask Daniel again, never reinstall unasked.

## State
- 11-12 sweep pushed (core 493d5698 full PASS). 11-13: answered MA-2 (re:MA-2, IS rev 191-192): ISA fixes no page size, all ISA regions 64 KiB-aligned, no objection to CCV_L_PAGE_SHIFT 16; AR owns cross-block cost. AR agreed (AR 348) and TI landed CCV_L_PAGE_SHIFT 16 (eda137fa, MA-15). MA-10: Q-60 whole-TLB invalidate only, no ASID; MA-11 line-granular per-warp ordering; none changes the ISA. DA (MA tab, 11-13): MI/DI start only after AR grill-me + summary to Daniel.
- New agent MA (MIU+DCU architect; DA 117-119), MI/DI implement, C++ model
  first. Sweep minute order: IS 23 (OA 406). MA will lean on the ISA's memory
  semantics (O-72 atomics, O-83/O-84 per-thread memory, fence): answer its
  ISA questions promptly; MA is in the roster (tab 1f971016-3f72) but session null and no rows yet
  (11-12); ping MA on Friday only once the roster has its session.
- Gate build/ now prunes unit dirs (peaks a few GB); disk recipe below is a fallback.
- 2026-11-09: RI/AR merge conflict resolved upstream (TI 401, RI-34); merged 11-10. perf-register.md union-resolved again (AR's J9 notes + TI's RA-43).
  ISA-adjacent, no action: register pmov (Format K 63) executed as por (OA 396;
  elision is a licence); params/ops.json new opcode table (TI 395).
- O-85 follow-ups done: TI de03fd6 (TI-371) builds every collective incl.
  shfl.idx and _R forms (kernel coll; opcodes by name from ccv-sim). IS-21/O-72
  RMW atomics built (kernels atom, atomf); CAS landed 9894da1 (kernel cas,
  guarded CAS merges rd/pd per invariant 10). IS-21 complete in the core.
- reconv.hint: OA 393 makes C_RECONV a rename no-op (matches ISA: ignored by
  Phase 1). ISA says the compiler emits it from day one; it emits none yet
  (CP's F-124). Watch F-124; not an ISA change.
  ISA defines no cross-warp order on one word; raise only if it must be defined.
- 2026-11-07 sweep: nothing for IS. DA 113-115 (Daniel): zero-cycle receiving
  ends only for IPC; bring 0.2-0.5% impacts to him, over 0.5% the architect
  approves if NGD module rules hold. C9 approved. RH has no register tab.
- TI-51 done: merged 2d445f5 (full gate PASS 43cb80ea), re-ran
  setup-session-home.py with Daniel's approval; 350k installed, --check exit 0.
- 2026-11-06 sweep: nothing for IS. DA 109/110 (lead CG-5 waivers and credit
  pulses on the receiving block's 2%), DA 111/112 (350k window; sum of parts).
  AR 296 (second no-flop end kind) and the C9 package wait on Daniel.
- 2026-11-05 sweep: nothing for IS. DA 107 (interface module 1 flop in/out
  default), DA 108 (boundary lead slice counts on receiver's 2%), DA (CI):
  GitHub CI gates only release/weekly/dispatch; red ubuntu-latest runs ignored.
  RA-19 closed in both sims (CP 20db9c9, TI 9ce7381).
- ISA decisions this cycle: O-73 to O-85. O-85 (RA-20, DA 2026-11-02, DA tab
  rev 100): warp-collective semantics, diagonal unballot; compiler a70f392.
  RA-19: pmov merges by issue mask (3f202bc). Waiting: TI opcodes, CP ccv-sim.
  DA-tab decision rows are written in Daniel's session by the agent he answers. Latest: O-83 (interleaved
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
