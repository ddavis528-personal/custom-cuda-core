# AR handoff (top-level architect)

Updated 2026-11-04. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds AR's.

## Who and what
- AR is Daniel's (DA's) top-level architect, in Daniel's own session
  (session_01FnGhxke3r33MeArLeQJRcD). Daniel is a senior microprocessor
  design engineer; answer him as one.
- AR owns: the architecture docs and the partitioning spec; the per-block
  specs for blocks with no session (RAU, PCA, DCU, MIU, FET, LANE, DEC, SYU,
  SPM; RCU's text until RA's first edit); the AR register tab; docs/perf-register.md (PF-30
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
  Gate rule (OI-95, DA 2026-10-31, TI 5e7c8db): a working-branch push may
  take the scoped gate (verify.sh --changed <base>, SCOPED PASS); the
  sweep's merge and releases keep the full clean gate, so AR's sweep is
  unchanged.
- Sweep 2026-11-04 (run early for TI's fbefc16 CI fix): 18be7b6 pushed on
  SPLIT PASS (cg 59 min, rest ~65 min; a container restart lost one rest
  run, rerun from the surviving export). Earlier: 11-02/03 e556fbc on SPLIT PASS (cg alone 75 min,
  exported, then gate-push --full --import; the whole gate in one 2h
  background run timed out with cg and ngd sharing the heavy lock). If a
  full gate times out again, split it the same way: `verify.sh --only cg`
  then `gate-export.sh`, then `gate-push.sh --full --branches=<ours>
  --import=<tgz>`. heavy-units.json conflicts come from older TI text riding
  other agents' sweep merges: take TI's newest side. session-home matches.
- Daily sweep (scheduled task trig_01V1WipqEXd8e7TAaWnKvQGu, 09:04 UTC):
  register section 4 from the bookmarks; fetch; merge every remote branch
  with commits ours lacks except `release` and `gate-scratch/*` (DA
  2026-11-01, TI rev 289; task prompt updated 2026-11-02) (merge commits only); gate;
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
  record): AR 321, OA 382, TI 376, RA 100 (tab 9851686b-2b0a), RI 40, IS 190, CP 157, OI 324, DA 115,
  Conventions 17 (RI tab 8e4547bc-c469). TI 368 (RA-30 at 1d9fa6f; RA 97 accepted), OA 380 (IS-21: atomic A1/A3 never discarded or replayed) written into MIU spec rev 63 (.5742); OI-126 (C9h at f00c14c, counters next push), nothing asks AR. J9 (TI 369): the loop +6.4% is Z (2a7f125) alone, +1,065 cycles (+19%); bnd_rx +55; default flop 0; (e)/(f) recover 14-17%. AR 318: an alignment collision, so fix the penalty, not the latency; asked RH for a stats diff (demotions, replays, port conflicts, RS holds), and for OI/RI to name the resource; Z stands; (e)/(f) priced only on S1/cm32/cm128; Daniel told once the collision is named and costed. perf-register line added (open). RI 36: (i) RCU half ruled out (separate LW/MW bank write ports; fixed-latency outputs fail, never defer); only restore_hold migration can cost >1 cycle in RCU; RI names it from the diff. TI 370 stats: lat1 11->10 as meant, cancels down, loss is ROB head on MIU (load_at_miu +30%, store +20%, rs share +43%, issue idle x2); g1 (Z+ooe_rcu_issue) 5,553. AR 319: the MIU stub (kernel.cpp class Miu) starts 1 job/cycle, committed stores first, global order_ head-of-line blocks all warps; asked start() stall causes + local 4-pipe stub rerun of w9/w10/g1/g2/S1/cm32/cm128; if S1/cm move >0.2%, re-check Z, C9, flop prices, PHYS 160 on it. Daniel hears once that rerun is in. TI 371: de03fd6 (O-85, IS-21 atomics, #88) full PASS; J9 in the L1 (dcu_evict +73%, store_hit -49%, l1_miss +23%, credit_wait x2); J10 = TI local MIU stub patch (stall counters, CCV_MIU_MULTI). AR 320: the stub DCU defaults 64 sets x 1 way (8 KiB DM), nothing sets CCV_DCU_WAYS, spec settled 8 ways (TI 234); 3 arrays 64 KiB-aligned alias one set. Asked: did RH runs set ways; J10 + 8-way axis; TI to move stub default to 8x64 (own push). AR to update DCU spec stub sentence (c18a112b-d2c6 .8185) when it lands. TI 372: most runs were 64x1 (only dcu8/k512 set geometry); arrays confirmed in one set; J10 widened to 1 and 8 ways; stub default to 8x64 being gated, no kernel needed pinning. TI 373: 31168a3 pushed (stub DCU 8x64 default; scoped PASS); J10 vadd loop: Z step +26.8% at 1 way, +3.1% at 8 ways, -0.2% with MIU multi-start (worth 3.3-6.4%). DCU spec rev 17 stub sentences updated. Waiting: S1/cm32/cm128/pl reruns (4-5 h), then TI re-checks Z, C9, flop prices, PHYS 160 vs the 0.2% bar; then AR tells Daniel. TI 375 (J10): 8w cm32 -40.2%, cm128 -48.8%; MULTI=1 cm128 +26.1% at 8w (pipes_full 4.26M->9.59M), S1 -0.04%, cm32 -0.4%; TI keeps stub single-start; pl32 model 14,297,482. AR 321: 8w baseline taken, J9 closed (stub L1), asked TI whether MULTI holds a pipe through a miss; cm128 and OA case 4 (PHYS 160) read as bounds. TI 376 confirms: stub MIU job holds its pipe start-to-completion incl. misses (both modes); MULTI fills pipes with other warps misses; cm128 MULTI a bound. Fix (release pipe at launch) left as TI call. Waiting: TI gate with 8w default, then booked-delta re-check at 8w. Open: should MIU stub default to multi-start (TI call; AR to ask if S1 moves >0.2%). Sweep 11-07: nothing asks AR; merged 57eff422 101, 183cc441 98, 126afa13 19, 9eb50716 13, c22116ce 4, 888218a3 2 (walkthrough theirs); gate PASS ~/ccv-logs/ar-sweep-1107.log; session home OK; Friday pongs all 8 OK. Sweep 11-06: nothing asks AR;
  merged 8 branches (~97 commits), gate log ~/ccv-logs/ar-sweep-1106.log;
  pings sent 11-06 to OA IS TI OI CP RA RI RH (check pongs Saturday). Sweep 11-05: nothing asks AR;
  RI-15 decided (DA 109, option (c)); RI-14 credit pulses charged to block 2% (DA 110).
  AR 269: the heavy-units conflict row for TI (closed by TI a55c0ff/5e5280f).
  DA 104: ROB split adopted. OA 315 (re:OI-104, option B): OI builds
  ooe_wake's allocation lead, then TI reapplies CCV_LAT_RCU_ADDR_BASE 1
  (PF-47 unheld then; check the PF-47 row once TI's notice lands).
  Read by notice 11-04 (not swept: OA 316-326, OI 255-270 unread):
  OA 327 / DA 106 decq 15 + free lag 1 -> DEC spec states CCV_P_DECQ = 15
  (specs DEC tab rev 17), AR rev 270 closes it. DA 105: RA-33 fanout term
  enforced in check-ngd (ratcheted), nothing for AR.
  RA 61 RA-39 (R retime, Daniel asked 11-04): AR rev 271 agrees (d), R lead
  + lead_r_src0/1 (2x8, zero when unused), R reads R0/R1 in A; conditional
  on OA (a) (sources in PRF at issue+latency, no early wake; else OA's
  late wake for R consumers, never an R hold). SUPERSEDED by OA 336
  (re:OI-115, RA 70): option (2), R0/R1 read in A from the payload's
  phys_src0/1 (budgets RCU in 18, OOE out 7), lead_r_src0/1 withdrawn,
  AR's (d) lapses. Partitioning spec Interfaces tab rev 20 says so; the
  L1-hit forward is a bank-level write-through.
  OA 328: L1-hit loads miss a read at A (data lands at T = A). OA's order:
  (i) MIU forward inside RCU (RA prices), (ii) late load wake for R
  consumers if <0.5% (OI prices), else DA. AR rev 272 withdrew 271's
  late-wake line and asked RA to price (i) as a per-lane/field merge
  (active_mask, dst_pos/width sections, right-aligned load_data realigned;
  rev 273 fixed 272's wrong 64-bit second row claim); rests on MIU's
  1-write-per-section rule and AR's owed disjoint-sections assertion.
  Closed 11-04: RA 62/63 priced (i) at ~10k cells + ~185 flops, R A path
  13 -> ~16 NGD, input 5/12 NGD, merge after alignment; OA 329 took (i),
  wake contract unchanged, flops on DA's overhead list. CCV_P_DECQ stays 13
  in params until OI's lag RTL lands (TI rev 301); DEC spec already says 15.
  PF-47: TI reapplied base 1 (rev 298) but holds it on OI's no-rep-lead
  control (6 of 18 seeds miss).
  TI rev 308 (DA asked): AR rev 276 released layernorm; AR 143's hold had
  ended with CP-14 / AR 148 (CCV_FAIR_N 48), never said so then. Lesson:
  close a hold in the row that ends it.
  TI 309: RA-39 (c) in schema (39a1861). AR wrote the partitioning spec's
  Lead fields paragraph (Interfaces tab rev 19). AR rev 277: miu_rcu_data
  has NO lead slice, yet RA 62's forward compares lead phys_dst in T-1;
  asked RA: lead_phys_dst (4x8, TI row, AR writes MIU text) or compare in
  A (~+3 NGD). RA-40 (RA 65): all six RA-4 lead fields (agreed AR 262,
  never reached the schema). AR wrote MIU spec (MIU tab rev 48: lead slice
  + 1-GPR-write-per-section paragraphs); AR rev 278 asks TI for the schema
  row and keep/drop of payload copies (AR prefers drop; 262's "no new
  wires" holds only then). MIU spec made current at Daniel's ask (MIU tab
  rev 54, AR rev 279): kill rule (RA-23), address pairing (RA-21), wire
  table recounted from schema 39a1861 (15 channels, 21,675 in / 15,882
  out; rcu_miu_addr 12,457), L1 WAKE/CMPL 16/18 (12/14 at base 1). RA-40
  built at b85595b (TI 311, on TI's branch until the sweep merges it): the
  six payload fields lead, no copies, no new wires; MIU tab rev 55 says so,
  wire table unchanged. AR-25 (1)-(3),(6) done at b85595b; (4)(5) ride TI's
  RA-16/RA-30 work.
  AR-24 vadd16 at 4 warps (TI 313, AR 283): 72 warp-cycles hold, 18 a warp
  at entry; 0.29%/warp on the loop, 7.9% only on the 228-cycle run. AR read
  PF-15's trigger as not met (fixed launch cost) and recorded it in PF-15;
  the wording is DA's. Next: coremarkpl32/coremark32 at 1 and 4 warps (TI,
  after J2).
  RA-11 PHYS_REGS sweep (TI 315, RA 67 Needs AR+DA; AR 284, Needs OA, DA):
  coremark128 +0.25% at 160, +0.20% at 128; share.names 7/33,194/2,428,849;
  OOE checks fire at 160 (7 fits_stale) and 128 (3,271 + one V-N floor
  cover), so 128's cycles are flattered and not evidence. RCU flops 246k ->
  212k (160) / 179k (128). AR's order: OI answers TI's check question, TI
  re-runs 160 clean on a second 4-warp kernel, OA's view on Q-35 at 160,
  then AR to DA with RA's Phase 1 area. 192 stands until then.
  OA 333: 160 meets Q-35 (REN_CEIL 44 >= ROB 32), 128 fails (24 < 32);
  order agreed; OA recommends 160 to DA after the clean re-run. Waiting on
  OI's check answer and TI's re-run. TI 316: the smaller pools ran with
  their own REN_FLOOR/CEIL (12/44, 8/24), so the firings are OI's question.
  TI 318 (re:AR 276): fair sweep off/32/48, all 57 match, 52 identical,
  lnorm1 2562 flat; spinwait 1494 at 32 vs 2150 at 48 (forward-progress
  test, expected); N = 48 stands. No reply owed. Pings Fri 2026-10-30: all five answered ok (checked Sat).
- RH (run helper, session_01QPk2jvfKM1V5rRfip8FC86, branch
  ccr-c22116ce-1vzyjg) is DA's offload worker for long runs; it has no
  register tab. Its branch is merged in the sweep like the others.
- Specs doc DJeg9Hh8rkPDecq4hrAz35 (tab revs after the 11-04 review): RCU
  eda9347a-feaa (RA's now), MIU aa7a288a-dae2 (63), RAU 090626bb-a50c (60),
  PCA 94b3a0ea-7224 (17), FET 75d75b94-1614 (47), DEC 1d1fdcda-739e (19),
  DCU c18a112b-d2c6 (17), SPM b66e4f64-612c (3), LANE ea1f36a7-0725 (16),
  SYU 1f8b4472-68c1 (8), CRU 5a50fd80-2423 (7), MLC f8873ac6-e74d (3), EXB
  56392a06-86a6 (4), OOE 515615a9-8caf (OA's).
- Spec review of the no-session blocks done 11-04 (Daniel asked; AR rev
  280, AR-25 minted rev 282, TI notified): every tab's widths recounted
  from payload-spec, kill text is RA-14/RA-23's, S1 paragraphs match the
  stubs. AR-25 (TI): six schema/params doc fixes (pca_rcu_mig doc,
  CCV_W_MIG_ROW doc, rcu_lane_ops srd doc, SFU 2nd result RA-3, imm_kind 6
  RA-18, miu_dcu_req backpressure class). DEC's CCV_P_DECQ 15 stays (DA).
- Docs-tool lessons: write ops need FULL ids (session prefix + ".n", e.g.
  m30rdwkg40n.5277 in specs, m8yvbw8rqgz.n in the register); a read prints
  them short. Replace a paragraph by its paragraph id (a cell's paragraph
  is cell id + 1; a list item's is item id + 1), ifHash = the paragraph's
  h, "as":"markdown" so marks are spelled. Never "chars" on run ids; "as":
  "text" can stretch a code mark. Rows: insert {"as":"blocks"} after a row
  id, several rows in one content array. Each op bumps the tab rev.

## Decided recently (DA tab)
- revs 100-103 (2026-11-02): RA-20 adopted (O-85 collectives, diagonal
  unballot); RI, the RCU implementation session, created (RA's handoff
  docs/rcu-impl.md); RI owns a cycle-accurate C++ RCU model (sim/rcu/)
  ahead of the RTL, accurate at interfaces and events, not an RTL clone.
- rev 95: IS-24 option W (O-83); 512 KiB L1 kept as a live candidate.
- rev 96: TI-46 (b) at r = 2; decode-queue share 7, queue 13.
- rev 97: IS-25 (O-84): frames in the bottom of the thread's O-83 region,
  R15 = W. Built by TI in 5fe7177 (pin d9ddd2c); PF-46 adopted and built.
- rev 99 (2026-11-01, AR recorded): RCU is the next major block; a new RCU
  architecture session, RA, owns it; AR stays top-level arch. RA tab node
  9851686b-2b0a (file 8b9d4d3a-16f1), roster entry session null until RA
  writes it, handoff docs/rcu-arch.md, AR rev 261.
- rev 98 (recorded by OA, Daniel: "I agree with your recommendation for
  OI-86/88"): (b), the RCU branch lead with resolve_lag 0, plus
  squash_act_lag 1 (audit +1.2%).

## Open work (most urgent first)
00. RI-11 interface flops (Daniel 11-05 via TI 321). AR rev 285 decided the
   accounting; AR row 286 (rev 286-287) answered TI 323, RA 76, OA 339/340:
   DPI-host ends stay no-flop (RTL replacing a stub takes flops by default);
   +1s sit in bases counted from HOP's landing: RCU_ADDR_BASE 5->6 (PF-47's
   1->2), LANE_BASE 7->8, SFU 12->13; derived L1_WAKE 17, CMPL 19; RCU_BASE
   3, COLLECTIVE 5, MISS_WAKE 1, CMPL_HINT 2, LANE_BYP 4, BYP_AGE 2 unchanged;
   no credit depth grows (exception: a receiver whose credit return was off
   the wire; OI audits OOE's); KILL_DRAIN follows SFU; CCV_LAT_BYP_PEN_SFU's
   doc equality breaks (OA rewords, TI applies). Specs: LANE rev 13
   (latency paragraph), MIU rev 56 (counts from holding, 17/19, PF-47 13/15).
   perf-register PF-47 RI-11 bullet. Waiting: TI lands bases in one push;
   RA restates RCU (confirms the RCU_ADDR +1); OI audit of OOE receivers.
   OA 341 accepts 286; +1 goes on the adopted PF-47 base (1->2, WAKE 13,
   CMPL 15); if the +1 lands before the PF-47 reapply, TI notes it in params
   source so the reapply takes 1+1. Agrees with MIU rev 56 and PF-47 note;
   no AR answer owed (loop guard). RA 77-79 took 286 as final (KILL_DRAIN
   derived, 16; RCU Conventions restated, A from the interface flop); AR
   row 288 confirmed RA's RCU_ADDR_BASE reading (PF-47 2, fallback 3) and
   took RA's lane bypass ages (forward 4-6, PRF from 7; LANE spec rev 14
   corrected AR's "4 to 7"); TI rewords CCV_P_W_LANE_BYP_AGE's doc to LANE-2.
   TI 325: flop built, formal full rate at 4+2N (unbounded conservation
   still running); bases held until RI/OI unit-test fixes. AR row 289: stall
   +1 taken (RESCUE_DEPTH, DRAIN_WAIT 3, derive RT_ABUT+1; stall rule
   3+2xSRC_STAGES). Lead slices ungated (enable would be valid, CG-5): AR
   recommends charging a boundary flop's lead slice to the receiving block's
   per-instance 2% (repeater stages keep own allowance, Daniel 10-19 rule);
   DECIDED by Daniel (DA tab rev 108, "this is where we pay for lead fields -
   no free lunch"); TI applies in check-cg and the rule text.
   TI 332 (f61983f): applied; OOE over its 2% by 196 (leads 375: 231 in,
   144 out). AR row 292: source-end lead charged to the sender (confirmed);
   ASKED DANIEL whether a lead channel's source end may go no-flop where the
   sender's own gated lead register drives the port at 0 NGD (saves OOE 144,
   RCU 487, MIU 204). Record his answer as a DA row. CORRECTED (TI 333,
   AR 293-295): OOE fits, ~1,200 of ~1,309 per instance (ooe_rob_w x4), so
   the source-end no-flop is margin only. TI: no tool change needed if
   allowed (links.json no_flop). N=1,2 unbounded conservation running.
   OI 291 priced: AR params +1.66% S1; all OOE inputs flopped +3.49%;
   miu_ooe_cmpl +1.60, dec_ooe_uop +1.29, rcu_ooe_done +0.62 alone. AR row
   296-297: OOE's ends have logic before first flop, so zero-cycle needs a
   SECOND no-flop kind (<=12 NGD input, link_n 0, abutting blocks), ASKED
   DANIEL; AR recommends (b) for rcu_done + dec_uop, miu_cmpl only if the
   floorplan abuts MIU/OOE (Q-42 plan puts them on opposite RCU ends: add
   MIU-OOE cmpl distance as the first floorplan number).
   OA 347-348 agree the second kind; OA asks CMPL_HINT 3. AR row 298:
   HINT 3 derives FILL_NOTICE 5 (DCU cost on noticed refills), covers refill
   wakes only; OI splits miu_cmpl's +1.60% by cause and prices LANE 7/SFU 12
   (lane_rcu_res zero-cycle, RA confirms MW cone <=12); ooe_rcu_issue stays
   flopped (R read 18.4). All goes to Daniel with AR 296's question.
   OA 349 (re:RA-83): package for DA, run as one config: flopped = issue,
   minor OOE inputs, cmpl if hint 3; zero-cycle = lane_res, rcu_done,
   dec_uop. Agrees with AR 298; no AR answer owed. Read RA-83 at next sweep.
   RA 84: lane_rcu_res feeds LW/SW (not MW), cones ~7 -> qualifies (LANE 7,
   SFU 12 if Daniel allows); miu_rcu_data does NOT (guard forward ~21; needs
   2/23 split or lose forward; RI measures) -> stays flopped, no latency
   moves. LANE spec rev 16 corrected MW -> LW/SW.
   RI-16 (RI 17): asked skeleton to model boundary flops; SV-hosted D fails
   (done 8 vs class-0 6). AR row 299: flop never charged by itself (one of
   HOP's two); D = wrapper flops in series with DPI hosts' registers (AR 287
   (1)), fails by construction (TI may keep as negative control); no skeleton
   change; price via bases: N AR bases (+1.17% S1 RCU model), Z1 RCU_ADDR 5,
   Z2 LANE 7/SFU 12, Z3 none. miu_rcu_data pred guard fwd 16.2 > 12.
   AR 300 (re:RI-16, TI 337) SUPERSEDES 299 and 286's booking: TI's link
   term adopted. Crossing = HOP + link_n + bnd_rx (1 flopped rx end, 0
   no-flop; source-end wrapper flop free). Bases block-internal: LANE 7,
   SFU 12, RCU_ADDR 5 (PF-47 1, not 2). Defaults: lane_res/issue/miu_data
   flopped at RCU; rcu_lane_ops and rcu_miu_addr (MIU stub) no-flop ->
   LANE 8, SFU 13, WAKE 17 (13; issue term cancels, +1 = miu_data end),
   CMPL 19 (15) + bnd_rx(miu_ooe_cmpl), LAT_RCU 3, V-35 base+bnd(issue)
   +bnd(done). D valid; RI's skeleton ask stands; pricing = links.json
   no_flop edits. Done: LANE spec rev 21, MIU spec rev 59 (.11865/.12185/
   .12255), PF-47 row + bullet. Waits: TI link term in gen-params/gen-skel/
   checkers, then RI/OI price D, N, Z1-Z3 and OA 349's package.
   TI 339 / RA 85 took AR 300. AR 301: default ends = TI's option 1 (three
   RCU rx ends flopped; others as built, no-flop today; owners flip their own
   ends by row to TI). CCV_LAT_RCU_ADDR stays = base (5; PF-47 1); RA's
   "RCU_ADDR 6/2" counts from the landing; if gen-params adds bnd_rx inside
   it, WAKE/CMPL read 18/20 (asked TI to assert 17/19/13/15). TI's bases
   push (LANE_BASE 8, SFU 13, ADDR_BASE 6) lands first, then the term push
   reverts bases to 7/12/5.
   OI-299 (RI-11 package v2, rx_lag knobs): hint/RAU/demote/SYU rx flops
   free; global-load cmpl flop +0.74% S1/+0.82% cm32; H3 params (HINT 3,
   FILL 5, MLC_HIT_MAX 40, LANE 7/SFU 12) +0.56% S1, +1.4-1.9% CoreMark over
   A6. AR 302: take free flops; decision = miu_ooe_cmpl's OOE end (no-flop
   keeps HINT 2/FILL 4/MLC 39, H3 overcharges); asked OI for A6L (A6+LANE7/
   SFU12) and A6H (A6+hint bundle), OA/OI for cmpl rx cone depth. Then (a)
   A6L vs (b) Pn2048 goes to Daniel with AR 296.
   OA 355 (pre-302) recommends H3 + all rx flops but cmpl, cmpl first-kind
   if OI's RTL confirms; asked AR to confirm first kind at OOE. AR 303: yes
   (enable from OOE's own flops per CG-5: hit at L1_CMPL after issue, miss
   via hint lead; nothing before the register; else ungated = lead slice in
   OOE 2%). H3 wrong for no-flop cmpl (HINT 3 bundle only for flopped cmpl;
   LANE 7/SFU 12 need AR 296 second kind). Asked OA for any cmpl-independent
   reason for HINT 3. OA 351/352 send ooe_rs 45-49 rows area to DA.
   OA 357: no such reason; hint end must match cmpl's (shared treatment).
   AR 304 corrects 303: package = RAU/demote/SYU flopped (free); cmpl+hint
   both first kind (HINT 2/FILL 4/MLC 39) if OI's RTL confirms both cones,
   else both flopped + HINT 3 bundle (Pn2048); LANE 7/SFU 12 only w/ AR 296.
   Hint capture is a lead slice in OOE 2% either way (no new area).
   OI-300: A6L=A6, A6H=H3 (base already LANE 7/SFU 12): H3 cost is all hint
   bundle. As built neither cmpl nor hint is first kind (cmpl/hint_idx 14.1
   in ooe_wake, cm_tag 22.1 in ooe_rob_w, decoded before first reg); capture
   CG-5 clean via flopped valid leads. AR 305: (b) both flopped ~+2% over A6
   (S1 +1.95, cm32 +2.24, cm128 +1.84); first kind free iff three readers fit
   25 NGD with decode in front: L1 hit->spec timer, ROB done->retire, and
   (AR's add) hint_idx->wake (late hint = lead 1). OI probes; then (a) vs
   (b) + AR 296 go to Daniel.
   OI-302 probe (RTL 93457a4 unpushed): capture free; spec hit bypass fits
   ooe_sched 23.7 but ooe_rs 28.5 (fix (a) confirm late / (b) free cone 21);
   ROB done an edge late (C1, audit s0n0 +0.8%); hint wake 22.8 fits.
   AR 306: first kind for cmpl+hint (HINT 2 stands), rs OA's call (AR leans
   (a) if <=0.1% S1), C1 accepted subject to RH price. Waiting RH prices of
   C1 + rs(a); then package (a) vs (b) ~+2% + AR 296 to Daniel.
   OI-303 corrects 302: rs (a) is C2 (+3.7% audit, sched mirrors rs free) -
   AR 306 (2)'s lean is moot; rs bypass off rmask, entry held a cycle, fits
   24.0, free (C8). First kind = C9 (C8 + ROB a cycle late): audit +0.8/
   +1.0/+1.2/+0.1%. Needs OA, AR to take the form once RH prices C9 on S1/
   CoreMark (job 2b). When it lands: AR row taking the form, noting 306 (2)
   superseded, then the package to Daniel (C9 vs (b) ~+2%, with AR 296).
   OI-115/OA-361: C9 S1 +0.444% over A6, cm128 -0.45%, cm32 -0.08%; flopped
   (H3+P) ~+1.95% S1; C8 0; R49 S1 +0.276% (OA's separate RS-rows item).
   AR 307 endorses C9, caveat: A6 base carries LANE 7/SFU 12 (= AR 296
   second kind) - shifts all options alike. OA 363 RULED C9 (under 0.5%,
   OA's call): cmpl+hint first kind, HINT 2/FILL 4/MLC 39 stand, flopped
   not taken. MIU spec rev 60 (.12255) and PF-47 bullet updated. Still
   Daniel's: AR 296 (lane_rcu_res zero-cycle => LANE 7/SFU 12).
   OA 365/RA 89: zero-cycle ooe_rcu_issue needs splits (OOE 2-6, RCU 19-23).
   AR 308: no splits for now (issue stays flopped); under the link term the
   issue bnd_rx CANCELS in L1_WAKE (and LAT_RCU, lane) - only L1_CMPL -1 and
   V-35 done -1 move; reopen if OI prices those >0.2% S1 (then to Daniel
   with AR 296). OA/RA had claimed WAKE 13->12 (old base booking).
   AR 309 (re:TI 350, bnd_rx pushed 17720a0): no derive term for a source-end
   flop; on a DPI block it is a series stage -> generators should refuse it
   (route src:1 instead). +2 RT/credit per flopped rx end agreed for hosts;
   asked TI to add bnd_rx to CCV_CREDIT_DEPTH + links.json 2N texts, confirm
   rescue +2*bnd_rx, and say which check holds RTL src-end flops. RTL: credit
   need not pass the rx boundary flop (depth 5 not 6; miu_rcu_data +2 entries
   = 8,912 flops) - RA to price when RCU's RTL top lands. Needs TI, RA.
   TI 351: (1) DPI flopped send end refused (255436f), texts done, rescue ok.
   AR 310: TI's check-ngd rule for RTL tops confirmed, amended: refuse a
   hidden stage per WHOLE port (valid/lead incl.), mirrored at flopped rx ends;
   fix = no_flop. Needs TI.
   DA 113 (from RA 91's verbatim quote of Daniel): zero-cycle rx ends only
   for performance, IPC decides; lane_rcu_res stays flopped (LANE 8/SFU 13);
   closes AR 296 the same way. Bar >0.2% S1 is RA's proposal: ASK DANIEL.
   AR 311: corrected RA 90 - credit unflopped through a flopped rx end is
   depth 5 not 4 (miu_rcu_data +4,456 over no-flop). Needs RA.
   OA 367: OA 363 withdrawn as a ruling - C9 (no-flop cmpl+hint) is DANIEL's
   under DA 113; OA recommends (model, 497efb8 @7/12: flopped +1.95% S1 vs C9
   +0.444% => ~1.5% S1 recovered). OI reprices at 8/13; nothing built until DA
   rules. DA 114 (Daniel, asked by AR in this session): C9 APPROVED (lapses
   to Daniel if OI's 8/13 rerun shows <=0.5%). Bar for zero-cycle rx ends:
   <=0.2% S1 stays flopped (architects); 0.2-0.5% -> Daniel; >0.5% owner may
   approve ONLY IF it meets the module NGD rules without the flop (Daniel
   confirmed verbatim, DA rev 115); can't meet 12 NGD w/o rx flop -> Daniel.
   RA 95: lane_rcu_res zero-cycle APPROVED (S1 -1.04%, cm32 -0.93%, cm128
   +0.15%; NGD 10 est., check-ngd passes at 12) -> LANE 7/SFU 12 once TI edits
   links.json. AR 313: checked OK; Partitioning tab rev 55 new 'Floorplan
   constraints' (RCU abuts all 32 lanes, link_n 0; RCU-MIU adjacency); LANE
   spec rev 22 (A+7 write, bypass ages 4-5, 5 deep); PF-47 bullet; C9 8/13
   rerun NOT owed. Needs RA, OI, TI.
   TI 357: Z pushed f4ce0fd (full gate PASS): LANE 7/SFU 12, kill drain 16,
   five controls retimed; TI's C9 question crossed AR 313 (already answered).
   LANE spec rev 24 + PF-47 say it has landed.
   AR 314 (re:OA 376/OI-125): lead_fault on ccv_miu_ooe_cmpl OK - MIU knows
   (all 4 causes from address check); defined status==1 (NOT nonzero: 2 is
   replay), one bit per slot, MIU settles status by the valid's cycle. MIU
   spec rev 61 (.36582). Needs OA, TI (schema row), OI.
   AR 315 (re:TI 360, RA-11 (c)): PHYS_REGS sweep f4ce0fd: 160 free (S1/cm32 =,
   cm128 -0.06%) but provisional (OI fits_stale); 128 cm32 +0.17 cm128 +0.25.
   AR leans 160 (~34k RCU flops): bring to OA (Q-35) then DANIEL once TI #72
   re-runs 160 clean, <=0.1% everywhere. 128 not brought. RA-11 (a) budget
   waits RA Phase 1; (b) answered by Partitioning rev 55.
   AR 316 (re:OA 378): #72 at 160 must also report floor stalls, restore-
   allocate under demotion, sectioned-row fragmentation, memop-held regs
   (cm128); OI adds missing counters. OA: no objection if no new stalls.
   AR 317 (re:TI 367 J8): rel-vadd16 +8.8%, loop +6.0% vs J3 (e533ecd); asked
   RH bisect on loop: e533ecd, 17720a0^, 17720a0, f4ce0fd + local no-flop
   miu_rcu_data / ooe_rcu_issue at f4ce0fd. If bnd_rx carries it: price ends
   (miu_rcu_data >0.2% -> Daniel, can't meet 12). coremarkpl not booked
   (stub vs model) until TI's model reruns.
   DA 109 (2026-11-06, recorded by AR from Daniel's words in RA 87): RI-15
   = RI's (c): module-level CG waivers for interface lead-signal flops OK,
   charged to block's per-instance 2%, validated at final construction; RA
   82 (d) withdrawn. rcu_kill's 45 credit pulses NOT covered (CG-1 waiver
   then DA 110: charged to block 2% too, marked "credit"). TI: check-cg block
   total includes waived leads and credit pulses.
   DA 111 (TI-51, recorded by AR from TI rev 345, no verbatim quote): (1)
   compact at 350k, not 400k: DANIEL APPROVED (2026-11-06, in AR's session)
   re-running the session-home skill once TI's push (2d445f5) is merged, so
   /home/user/.claude takes 350000. DONE in the 11-06 sweep: installed,
   --check rc=0.
   TI 349 (TI-51 done, 0ce9c12): block CG/NGD from module units + structural
   read. Can't catch: cross-boundary synthesis (conservative) and one net's
   loads as a whole (short by <=1 INV stage). No AR spec says "timed whole"
   (checked Common tab, Partitioning); nothing owed. (2) Block NGD/CG limits as sum
   of parts from module units (no whole-block synthesis; replaces "timed
   whole"): every instantiated module needs a unit at each param set.
0. RA (session_01QPk2jzLmjd3MWXjayVUy9d) round 1 answered, AR rev 262
   (RA-2..12); round 2 answered, AR rev 263 (RA-13 dispatch_fault dead, TI
   deletes via RA's row; RA-14 kill: RCU acks after a param drain = issue
   link + CCV_LAT_SFU + done link; rule for all: kill_ack waits for the
   block's last message to land -> AR owes RAU, PCA (stop rows, ack when
   every sent row is credited back), MIU (ack after last beat) spec text;
   RA-15 ops at R: pand/por/pxor/pmov #imm; skeleton lacks PXOR, PMOV reg,
   C_RECONV). Pinned ISA is v1.9 (build/compiler/d9ddd2c.../docs), not the
   stale compiler checkout's v1.7.
   Round 3 answered, AR rev 264: RA-14 CORRECTED (restore rows are PCA's
   on ccv_pca_rcu_mig with warp_id; RCU discards held cmd/map/rows of a
   killed warp and returns credits; discard only under a kill); RA-18 call
   link in imm, DEC imm_kind 6, OOE substitutes pc[31:0]+bytes(ilen) at
   rename (AR owes DEC spec line); RA-21 rcu_miu_addr bound (slot k = Pk)
   + fixed_latency, every memop incl. fence gets one address (AR owes MIU
   spec pairing rule); RA-23 kill_ack a level, all 8 blocks; RA-26 no RCU
   CSRs, answer reads 0 + credit. Lesson: check docs/rcu-arch.md's channel
   table before answering a migration question.
   RA-28/29 answered, AR rev 265: MIU <=1 GPR write/section/cycle (miss
   arbiter; MIU spec), PCA rows contiguous 0..16 (PCA spec), pca_rcu depth
   stays 4 (Q-43), RAU <= CCV_TIER1_WARPS migrations command->mig_done (RAU
   spec); 4 PRF write ports (collectives in R at A+2; supersedes rev 262's
   5th). SFU slot-4 question settled by OA rev 304 (CCV_P_FOOT_MIN_SFU = 4: one SFU
   issue a cycle; TI adds a require tying slot numbers to the terms). RA-29 (c)
   early collective done -> if legal, RA-8 costs RCU nothing; DA gets OOE
   cost + perf. RCU RTL-depth spec: artifact 4k7VrEKJG4KUgMYG1Qz8mB (RA's).
   RA-31 answered, AR rev 266: PF-47 ADOPTED, CCV_LAT_RCU_ADDR_BASE 5 -> 1
   now (param doc delegates to RCU's session; L1 wake 16 -> 12, ~-7.9%);
   TI applies (own commit), fallback 2 if M1 misses; told Daniel. Issue
   lead slice (~9 b/slot) agreed in principle, OA fixes contents. RA
   accepted revs 264/265 (all folded; RA-30 is its TI row). AR owes the
   top-level assertion that coincident miu_rcu_data slots' sections are
   disjoint. Address channel is ~12,400 wires (4 x 3,111), fixed in
   rcu-arch/Q-18; payload-spec.md line 165's 8,400 is schema text (TI's).
   AR rev 267: issue lead slice agreed per OA rev 307 (lead_sec_mask,
   lead_src_used, lead_imm_used, lead_merge_used on 9 slots; R adds
   lead_guard_used + lead_guard_pred, ~88 wires); guard lead replaces
   RA-32's lag-1 fallback (DA only if both fail). TI writes lead_fields and
   applies ADDR_BASE 1. TI rev 288: lead slice BUILT; ADDR_BASE 1 REVERTED,
   held on OI (ooe_wake NGD-3 26.1/25; rs_tb no-msd control missed); TI
   reapplies in one commit. PF-47 row says held. OA tab read rows 306/307 and TI 285 only, so the
   sweep bookmarks for OA/TI stay put. Owed by AR: LANE spec (SFU second result on lane_rcu_res;
   lane pipeline 3 cycles A+3..A+5) and MIU spec (lead fields phys_dst,
   dst_pos, dst_width, active_mask, phys_pred, pred_we) once TI's schema
   rows land; floorplan plan under Q-42 (16 lanes per long side, MIU one
   short side, PCA+OOE the other, lane links abutted). Waiting: TI deletes
   schema question rcu_miu_width (closes Q-18, now awaiting confirmation);
   TI's PHYS_REGS 128/160/192 sweep; RA's Phase 1 (flops, write D-mux,
   read mux GE separately) -> area budget to Daniel; RA-8 (collectives at
   lat 3) to DA with figures via RA/OA. Open risk on AR's list: FP32 in
   the lane's 3 cycles (FP shares lat 7). PF-47 added (RCU_ADDR 5 -> 1).
   Don't edit the RCU spec tab; send text as AR rows with RA in Needs.
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
   Built: TI 80697a3 (lead fields, slot_fields step A, OOE check, control
   lead-corrupt); step B (port narrowing) deferred until a repeated link,
   fine by AR. OA rev 293: no RCU branch/call select the cycle after a ret
   (1 flop) so two resolves never coincide; OI reprices, <0.5% OA's call.
   Watch: rope +14.7% (6763->7757) under shfl lat_class 5, dependent
   branches behind shfl; transp4 +2.2%. A PF row if collective latency
   becomes a lever.
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
