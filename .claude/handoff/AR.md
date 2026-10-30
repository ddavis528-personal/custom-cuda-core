# AR handoff (top-level architect)

Updated 2026-10-30. Keep this current at every task's end; it is what
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
  push; pings per section 6; report in a few lines.
  TI-49 says DA moved pings to Fridays only; not yet confirmed with Daniel
  and the task's prompt is unchanged (ask him before editing it).

## Register
- Doc JApHYjaUESeq8tsGMGXMU5. AR tab node bc521c46-9710, responses table
  m8yvbw8rqgz.2139 (4 cells: title, date, summary, body ending "Needs:").
  DA tab d5076b00-ef1b, table m8yvbw8rqgz.231. Other tabs: OA
  4c6a3151-83eb, TI e8b1d9d9-df9b, IS 60e6f93a-7fdc, CP 099ebfed-9eea, OI
  384bc26c-cef6, Conventions 55232329-ff5c.
- Notices: `python3 .claude/skills/register/notice.py compose --from AR
  --to X --rows re:X-n --rev N --summary "..."`, then send_message with
  priority "later". Rows must look like X-n or re:X-n.
- Bookmarks, revs read through (also in the scratchpad's
  register/bookmarks.json): AR 255, OA 283, TI 267, IS 178, CP 146,
  OI 231, DA 97, Conventions 15. Pings 2026-10-30: all five answered ok.
- Specs doc DJeg9Hh8rkPDecq4hrAz35: RCU eda9347a-feaa (rev 18), MIU
  aa7a288a-dae2 (rev 46), RAU 090626bb-a50c (rev 33), FET 75d75b94-1614
  (rev 45), DEC 1d1fdcda-739e, DCU c18a112b-d2c6, SPM b66e4f64-612c, LANE
  ea1f36a7-0725, SYU 1f8b4472-68c1, OOE 515615a9-8caf (OA's).

## Decided recently (DA tab)
- rev 95: IS-24 option W (O-83); 512 KiB L1 kept as a live candidate.
- rev 96: TI-46 (b) at r = 2; decode-queue share 7, queue 13.
- rev 97: IS-25 (O-84): frames in the bottom of the thread's O-83 region,
  R15 = W. Built by TI in 5fe7177 (pin d9ddd2c); PF-46 adopted and built.

## Open work (most urgent first)
1. L1 size, 64 vs 512 KiB: TI's sweep on CP-64's eight traces, frames in
   place only, 64 KiB at hit base 7 vs 512 KiB at 7, 8, 9. Daniel's test:
   does 512 KiB hold across many traces. CoreMark alone: 512 KiB -7.1%,
   frames -15.7%, both -22.8%; 512 KiB's lead with frames is 8.4%, an
   upper bound (hit latency held at 64 KiB's). Bring it to Daniel.
2. OI-86 mispredict cycle: OA recommends (b), a branch-outcome lead on
   the RCU-only done's fixed slot (33 flops, no waiver; RCU spec rev 14-18
   says RCU can give it), against (a), resolve_lag 1 (S1 +0.81%, audit
   +1.7%). Waits on OI's coremark32/128 figures; then to Daniel.
3. TI-48: this file; answer re:TI-48 with its commit. TI-49: the Friday
   pings question to Daniel.
4. OI-85 row-indexed dones: built (TI 6ba08b1); RCU and MIU text done.
5. Older AR items: AR-4 to AR-10, AR-12, AR-13, AR-15 to AR-17, the AR-20
   table (single-thread trades: 8 checkpoints -4.2%, ROB 48/64
   -3.9%/-5.1%, latency levers), the FET checkpoint cost, Q-50, Q-60.
6. Carry: the next row to CP corrects benchmarks.md's "alu16 1.59x (AR)"
   to OI's 2026-10-20 measurement.
