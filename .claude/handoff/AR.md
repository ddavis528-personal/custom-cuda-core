# AR handoff (top-level architect)

Updated 2026-10-31. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds AR's.

## Who and what
- AR is Daniel's (DA's) top-level architect, in Daniel's own session
  (session_01FnGhxke3r33MeArLeQJRcD). Daniel is a senior microprocessor
  design engineer; answer him as one.
- AR owns: the architecture docs and the partitioning spec; the per-block
  specs for blocks with no session (RAU, PCA, DCU, MIU, FET, LANE, DEC, SYU,
  SPM, and RCU's text); the AR register tab; docs/perf-register.md (PF-30
  on); reading traces.
- AR does not write code. It writes only its own tab, plus DA rows that
  record Daniel's own words ("Recorded by AR in Daniel's session").
  Interface changes go to TI as rows; AR writes the spec text.
- Responses record what lost, check the arithmetic, and name what is
  absent. AR may update the register without Daniel's go; decisions are
  Daniel's (DA rows quote him).
- No FP outside LANE. No broadcast channels. The owner wins a crossing.
  Loop guard: never answer a notice only to acknowledge it.

## Repos, branches, push
- Core: /home/user/custom-cuda-core, branch `ccr-80102643-4n8bv4` only.
  Compiler checkout: /home/user/custom-cuda-complier (read only, for the
  ISA and kernels). No PRs. No model ids in commits or artifacts.
- Commits end with the Co-Authored-By and Claude-Session lines from the
  session's attribution reminder.
- Code merges: tools/regen.sh then tools/verify.sh (about an hour; run in
  the background with timeout 7200000, never the 30-minute default), push
  only on PASS. Doc-only commits: tools/check-docs.sh, check its exit code.
- Daily sweep (scheduled task trig_01V1WipqEXd8e7TAaWnKvQGu, 09:04 UTC):
  register section 4 from the bookmarks; fetch; merge every remote branch
  with commits ours lacks except `release` (merge commits only); gate;
  push; report in a few lines. Pings (section 6) on Fridays only; Saturday
  checks Friday's pongs (TI-49; Daniel confirmed 2026-10-30, task updated).
- Credit rules (TI-49, Daniel 2026-10-30: "follow changes to optimize our
  credit usage as described by TI-49"): read a notice's rows, or a sweep's
  rows since the bookmarks, through the `register-reader` subagent and act
  on its digest; ring a notice only for a row that asks something of its
  receiver (an FYI or close-out waits for their sweep); use `gate-triage`
  for a red gate and `run-tabulate` for an experiment's runs.
- Session home (TI-50; Daniel approved 2026-10-31, AR rev 258): installed
  /home/user/.claude (settings.json with autoCompactWindow 400000 and the
  compact hook, agents link, ccv-setup.json) from ~/ccv-tools' copy of
  8dd82a6. It lives in the container, not the repo. The sweep runs --check
  after its merge; on exit 1 it asks Daniel, never reinstalls by itself.

## Register
- Doc JApHYjaUESeq8tsGMGXMU5. AR tab node bc521c46-9710, responses table
  m8yvbw8rqgz.2139 (4 cells: title, date, summary, body ending "Needs:").
  DA tab d5076b00-ef1b, table m8yvbw8rqgz.231. Other tabs: OA
  4c6a3151-83eb, TI e8b1d9d9-df9b, IS 60e6f93a-7fdc, CP 099ebfed-9eea, OI
  384bc26c-cef6, Conventions 55232329-ff5c.
- Notices: `python3 .claude/skills/register/notice.py compose --from AR
  --to X --rows re:X-n --rev N --summary "..."`, then send_message with
  priority "later". Rows must look like X-n or re:X-n.
- Bookmarks, revs read through (the scratchpad is not durable; this is the
  record): AR 260, OA 292, TI 275, IS 180, CP 148, OI 244, DA 98,
  Conventions 15. Pings Fri 2026-10-30: all five answered ok (checked Sat).
- RH (run helper, session_01QPk2jvfKM1V5rRfip8FC86, branch
  ccr-c22116ce-1vzyjg) is DA's offload worker for long runs; it has no
  register tab. Its branch is merged in the sweep like the others.
- Specs doc DJeg9Hh8rkPDecq4hrAz35: RCU eda9347a-feaa (rev 20), MIU
  aa7a288a-dae2 (rev 46), RAU 090626bb-a50c (rev 33), FET 75d75b94-1614
  (rev 45), DEC 1d1fdcda-739e, DCU c18a112b-d2c6, SPM b66e4f64-612c, LANE
  ea1f36a7-0725, SYU 1f8b4472-68c1, OOE 515615a9-8caf (OA's).

## Decided recently (DA tab)
- rev 95: IS-24 option W (O-83); 512 KiB L1 kept as a live candidate.
- rev 96: TI-46 (b) at r = 2; decode-queue share 7, queue 13.
- rev 97: IS-25 (O-84): frames in the bottom of the thread's O-83 region,
  R15 = W. Built by TI in 5fe7177 (pin d9ddd2c); PF-46 adopted and built.
- rev 98 (recorded by OA, Daniel: "I agree with your recommendation for
  OI-86/88"): (b), the RCU branch lead with resolve_lag 0, plus
  squash_act_lag 1 (audit +1.2%).

## Open work (most urgent first)
1. L1 size, 64 vs 512 KiB: TI's sweep on CP-64's eight traces, frames in
   place only, 64 KiB at hit base 7 vs 512 KiB at 7, 8, 9. Daniel's test:
   does 512 KiB hold across many traces. CoreMark alone: 512 KiB -7.1%,
   frames -15.7%, both -22.8%; 512 KiB's lead with frames is 8.4%, an
   upper bound (hit latency held at 64 KiB's). Bring it to Daniel.
2. OI-86/OI-88 adopted (b) (DA rev 98). AR rev 260 / RCU spec rev 20: lead
   fields lead_br_taken (1) + lead_br_mask (32) on ccv_rcu_ooe_done, slot
   CCV_DONE_SLOT_RCU only, no tag; branch and call only. A ret's lead is
   don't-care, so rets stay at resolve_lag 1, which (b)'s figures (all 0)
   did not count; the bound is the ret share of (a)'s S1 +0.8% and
   coremark32 +0.64%. Waiting on TI (schema, per-slot fields, with the
   OI-93 drop), OI (rets at lag 1, the difference), OA (the caveat). If
   the ret cost is material, a ret lead is the next row; bring it to Daniel.
3. TI-48 closed (all handoffs in; autoCompactWindow 400000 at 63a7bd5).
   TI-49 done (AR rev 256; OA put it into the register skill, rev 285).
4. OI-85/OI-90 row-indexed dones: built (TI 6ba08b1; OI per-row 2-bit
   counts, 9be452c, da182a7); RCU and MIU text done.
5. re:OI-93 settled (TI rev 274): shfl.idx is lat_class 5 at
   CCV_LAT_COLLECTIVE (DA's OA-4); the skeleton's 0 was TI's bug. TI fixes
   DEC's table, RCU's shfl timing and the field drop in one push;
   CCV_DONE_SLOTS stays 7. Watch S1's shfl kernels move (+2 cycles a shfl).
6. Older AR items: AR-4 to AR-10, AR-12, AR-13, AR-15 to AR-17, the AR-20
   table (single-thread trades: 8 checkpoints -4.2%, ROB 48/64
   -3.9%/-5.1%, latency levers), the FET checkpoint cost, Q-50, Q-60.
7. Carry: the next row to CP corrects benchmarks.md's "alu16 1.59x (AR)"
   to OI's 2026-10-20 measurement.
