# TI handoff (top-level implementation)

Updated 2026-11-05. Keep this current at every task's end; it is what
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
Conventions 17, AR 301, OA 346, IS 189, TI 340, OI 290, CP 154, DA 108,
RA 82, RI 17 (2026-11-05). Latest TI open: TI-50 (rev 272).
Pings are weekly, on Fridays (DA, 2026-10-30); Saturday's sweep checks the
pongs. Pings 2026-10-30 sent to all five; all ponged ok.

## State
- 2026-11-05 (after a usage halt; container replaced, disk kept): the
  sweep's gate on ti-b2@e89df54 (bases + OI + RI merges + 5 sweep merges)
  FAILED, nothing pushed: OI's RTL defaults kept LANE 7/SFU 12/L1 16 (cg
  replay ooe_wake/ooe_rename, rendep CT). Fixed on ti-b2 in 0ef9831 (wake
  LAT/LAT_COPY/LAT_SPEC/LAT_MISS, CT in rendep+rename, from
  test/ooe/*-params.py); notify OI (OI-18) once gated. Next: full gate on
  ti-b2 via gate-push --full, then notify OI/RI/OA (bases pushed).
- #79 bnd_rx (AR 300/301, option 1) on branch ti-bnd (/home/user/ti-bnd,
  e2b1b90, 947e5a5, ac52d93; base e89df54): links.json except, gen-params
  bnd_rx() + 17/19/13/15 pins, ChanInst bnd_src/bnd_rx (pipe, rtStages: a
  flopped rx end before a DPI block is +2 round trip), OOE/RCU crossings,
  KILL_DRAIN 17, re-pins (held-over-r warp 2, free-new seq 384 R3, predswap
  at:59). check-kernel and check-sv-hosted PASS. Rebase on ti-b2 after the
  bases push (ooe RTL defaults stay 8/13/17/20), full gate, push; then TI
  row to AR (RT +2 finding, src-end flop on a DPI block not in the derives)
  and notices OI/RI (their files edited).
- 2026-11-05 08:50Z: PUSHED f61983f/dbb4cce (full gate PASS): #76, AR 289 /
  DA 108. Rescue/drain 3; checker SRC_BOUNDARY (stall rule 1+B+2S, gen-skel
  sets it); rpt DST_END/BND_FIRST, bnd_lead_q charged to the wrapper
  (check-cg RPT_BOUNDARY); RI-13 took_flops ranged fix. TI rev 332 rows
  re:RI-11 (OOE 978 of 782 with flopped ends; source-end reading for AR/DA)
  and re:RI-13; notices AR, OA, OI, RI. Next: #75 bases (ti-bases c39035a)
  with OI's ccr-57eff422-5tdecg and RI's 600004a, MOVI_TOTAL 354; then #78.
- 2026-11-05 05:15Z: PUSHED 810e35c (full gate PASS): #75 push B, the
  interface module's boundary flop (ccv_common_rpt BOUNDARY, default 1;
  params/links.json no_flop holds all 14 DPI-host types, so the top is
  unchanged), check-ngd's straight-into-flops rule, fv_link FV_BUILT proofs
  (conservation bounded 40 in gate; proved unbounded ad hoc at N=0 in 968 s
  with dc2;scorr). links_split.json carries no_flop too (the first gate
  failed on it). HELD on local branch ti-bases (c39035a): the bases
  LANE_BASE 8, SFU 13, RCU_ADDR_BASE 6 + check-kernel re-pins; merge OI's
  ccr-57eff422-5tdecg (OI rev 285/287; RI-12 decq fix) and RI's 600004a
  (RI rev 12; re-pin MOVI_TOTAL 258->354), re-check pins, push together.
  NEXT #76: AR 289 / DA 108: RESCUE_DEPTH, DRAIN_WAIT 3 (derive RT_ABUT+1);
  checker SRC_BOUNDARY, stall rule 1+SRC_BOUNDARY+2*SRC_STAGES; check-cg
  charges the boundary stage's ungated lead (rename bnd_lead_q) to the
  block's 2%; RI-13 took_flops whole-vector fix; measure receiving blocks;
  TI row re:RI-11 to AR (+ source-end lead goes to the sender: ask).
  CI (DA, 2026-11-05, #77): ci.yml pinned to ubuntu-24.04 (ubuntu-latest
  went to 26.04, apt Yosys 0.52 broke 6 sections), full gate only on push
  to release, weekly and dispatch. RH: J4 512 KiB coremark128 7,924,133
  clean; idle until OI's push (PHYS_REGS 160) and CTA-queueing code.
- 2026-11-05 01:30Z: PUSHED 31e21e0 (full gate PASS, both branches): RI-10
  (a) rtl/rcu+test/rcu scope cg/ngd with a readers check in gate-scope.py,
  (b) check-cg unit key replay_cxx clang++ (clang 18 in toolchain lock) for
  the full rcu_bank_slice (6574 flops, clean, 490 s, 1377 MiB); lead_r_src
  removed with RI's eac3054; ba3549b merged, pmov-all-lanes on the default
  model. TI rev 324 re:RI-10, RI notified (RI is not in roster.json; notice
  composed by hand). Next, #75 interface flops (DA 11-05: ccv_common_rpt
  default one flop at each block end, zero-cycle option kept; DPI ends
  no-flop): AR 288 settled params: LANE_BASE 8, SFU 13, RCU_ADDR_BASE 6
  (incl. receiving iface flop); PF-47 reapply = 2 (1+1, params must say so
  if bases land first) -> L1_WAKE 13, CMPL 15, M1-miss fallback 3;
  KILL_DRAIN 16 derived; reword CCV_P_W_LANE_BYP_AGE doc: lane forwards
  LANE_BYP..LANE-2, PRF serves LANE-1. Merge RI's 0d087e9 first.
- 2026-11-04 later: PUSHED 863a374 (scoped gate PASS 22/22): RI's 5968894
  merged (M0 met, RA rev 68 accepted); RI's model is makeRcu's default,
  CCV_RCU_IMPL=stub selects the stub; check-rcu-unit holds RI's 8
  'control <c> caught' lines; GUARD_FWD doc; pmovdiv kernel (pmov.imm
  merges issue mask, 9ce7381, compiler pin e533ecd) with --break
  pmov-all-lanes run under CCV_RCU_IMPL=stub until RI adds the break to its
  model (asked at TI rev 319, re:RI-8; RI, RA notified). Then move that
  control back to the default. RI-7 waits on OI's imm_kind 6 (11-06).
  #62 left: job_rcu_rtl lock-step (needs RI's RTL), check-sv-hosted
  selector. RH: J1/J3/J5 done (AR revs 283/284, TI 318); J2 running
  (coremark128 cold hangs at 95945, dec_ooe_uop response_within_n), then
  coremarkpl32/128. #72 waits on OI's answer to TI revs 315/316.
- 2026-11-04 15:10Z: PUSHED 6cbabba (RCU events 33-47, RI-2 (d); TI rev
  310) and b85595b (full gate PASS: ccv_miu_rcu_data leads its own six
  fields, RA-40, drop option; OI-111's DECQ-15 checks, each valid at 13 and
  15; AR-25 (1)-(3),(6) docs). TI rev 311 rows re:RA-40, re:AR-25,
  re:OI-111; RA, AR, OI, RI notified. RH: J1 192 done, 160/128 running
  with derived REN_FLOOR/CEIL (confirmed); then J5, J2, coremarkpl32/128
  (OK'd); vadd16 waits on a CP export of vadd16/vadd16_loop as
  release/kernels/ (TI to raise with CP). OI-112: imm_kind 6, arrival-2,
  lead_r_src due 11-06; csa DUAL=0 rides OI's post-decq push.
- 2026-11-04 06:10Z: PUSHED fbefc16 (ooe_sched back on heavy-units: CI
  red on every branch was TI's 4e7186f; TI rev 302 rang all) and b11e60f
  (fanout ratchet live: 109 caps in 9 ooe modules; seed fix 87795bf takes
  a multi-unit module's worst unit; 836fd75 reverted; TI rev 304 rang
  OI/OA/RA). Both branches at b11e60f. Waiting: #66 decq 15 (TI rev 301)
  bumps with OI's decq_free_lag RTL, not before; #67 RA-39 (c) waits on
  AR (d) (OA accepted (b), rev 328). OI-105 answered yes (TI rev 303).
  Open: why CI reads ooe_sched at 2190 MiB vs 975 MiB locally.
  Lesson: `setsid nohup ... & echo $!` gives setsid's pid, not the job's.
- 2026-11-04 01:45Z: RA-33 fanout ENFORCED in check-ngd, local (faf5bf0,
  baa4136): every enforced depth and block level counts the term; ratchet
  'fanout' in rtl/ngd-ratchet.json, baseline rtl/ngd-fanout-baseline.json
  written once by `check-ngd.py --seed-fanout`. Dry run on tip: 115 findings
  (log ~/ccv-logs/lf/ngd-dry.log). TI rev 299 answered OI 265 / DA 105.
  NEXT: when OI's 5e81e19 lands on its branch, merge it, seed (full ngd run
  with --seed-fanout), commit, gate-push --full. Base 1 (#59) waits for OI's
  83c2900 (run-rtl.sh 12 seeds, OI rev 267); TI rev 298 written.
- 2026-11-03 17:50Z: #59 base 1 re-applied on OI's 1f7c642 in local branch
  ti-base1 (ti-ret HEAD 5839ecb, NOT pushed): ooe_wake ok (17.1 NGD), no-msd
  (rs) caught, but no-rep-lead (trio) MISSED -> held for OI. Row written (TI rev
  298), OI and OA notified. ti-ret reset to
  f20f89e (OI's merge, no base 1).
- 2026-11-03 (DA): longest-first queueing built (check-cg/check-ngd queue
  light units slowest first from $CCV_LOGDIR/unit-times/<tool>.json, written
  by clean gates only, CCV_CLEAN_GATE from verify.sh; control + 4 mutants);
  ooe_rob_w stays heavy (DA). Pushed b5b2032 (full PASS, ngd 4604 s, cg
  3912 s); record seeded in /root/ccv-logs/unit-times (cg 17, ngd 28 units).
  Compare the next clean gate's cg/ngd against these.
- 2026-11-03 12:00Z: both branches at bbd23d3 (sweep 2026-11-03: RA's
  ccr-126afa13-clcw9s merged 6ea9720, heavy-units.json kept TI's retune;
  AR's ccr-80102643-4n8bv4 (24); make-release skips gate-scratch/* a933e8d,
  OA rev 316 / TI rev 297). Release fe9fe2a pushed, snapshot tag
  snapshot-2026-11-03-bbd23d3 refused (local only). OA's
  ccr-9eb50716-lecnjf has 4 commits after the sweep: next sweep.
  #59 also waits on OI wiring ooe_rename akind/acls (OA rev 317).
- 2026-11-03 09:40Z: both branches at c5ae668. ROB split (OI-103) in at
  5e5280f; retune 4e7186f (heavy list = ooe_rob_w only, kept 6% under the
  2048 MiB limit while the ROB grows; per-unit wall time and heavy-lock wait
  lines in check-cg/check-ngd); c5ae668 queues heavy units first (control
  added). Full clean gate wall time: ~4h (16ab8ae, full-size ROB) -> 2h25
  (5e5280f) -> 1h37 (4e7186f) -> 1h18 (c5ae668). Critical path now ngd
  (4600 s), led by ooe_rename (2673 s in ngd, 2258 s in cg). Longest-first
  queueing: built (DA, 2026-11-03).
- 2026-11-03: both branches at 16ab8ae (sweep 2026-11-02: six branches
  merged, perf-register conflict resolved 70f8a04; release 40c0816, tag
  refused). It carries eda9ce8 (check-cg's run() measures each command's own
  peak through tools/rss-run.py: Linux carries the parent's RSS across exec
  into ru_maxrss, so every light unit read check-cg's size and IS, OA and
  TI gates went red) and 16ab8ae (ooe_sched heavy, 2190 MiB real).
  All agents rung (TI rev 295). LOCAL, gating: a55c0ff = OI's ROB split
  (OI-103, 4d388f8) merged + stale ooe_rob refs; ti-ret fast-forwarded to it;
  gate-push --full running (logs ~/ccv-logs). Task #63 next (DA,
  2026-11-02): keep every heavy hook, re-read true peaks from this gate,
  drop units under 2048 MiB from heavy-units.json (ooe_rename already 1014;
  ooe_rob_w's 2324 predates eda9ce8), retune check-ngd PARALLEL_BLIF_MAX /
  PARALLEL_FREE_MIN, report cg/ngd times to DA (full-size ROB: cg 14955 s,
  ngd 9607 s; OI's split gate 5642 / 3722 s).
- Earlier tip 7782ce0 (OI-101 split gate: verify --only/--skip, gate-export, gate-push --import, gate-combine; DA ruled same-commit split counts, 2026-11-01; TI rev 282), on 1afee59 (sweep 2026-11-01: 60 commits from five branches; release 1494a06, snapshot-2026-11-01-1afee59 local only, tag refused), on 4c2ce8b (OI-97: big units map in series; ABC selftest own cache), on 5e7c8db (OI-95: ABC cache, parallel map/map -r, scoped gate; DA confirmed in TI's session 2026-10-31; TI rev 279), on 43d92b3, on 80697a3 (AR rev 260 branch lead + slot_fields step A; TI rev 277, notices to AR/OI/OA), on f77582b (b0d91c2 shfl lat_class 5), on a17c736 (gate-push clears on red), on 16af94a (OI-93), on 61339a2 (8dd82a6 session-home), on 3fbb402 (sweep 2026-10-31: 45 commits merged from
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
