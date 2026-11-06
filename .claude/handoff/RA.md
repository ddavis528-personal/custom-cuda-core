# RA handoff (RCU block architect)

Updated 2026-11-06. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules (written for TI);
docs/rcu-arch.md (AR's handoff to RA) holds the role. This holds RA's own.

## Who and what
- RA = RCU architecture, session_01QPk2jzLmjd3MWXjayVUy9d, in Daniel's
  (DA's) session. Daniel is a senior microprocessor design engineer.
- RA owns: the RCU's block architecture; the RCU tab of the per-block
  specs (https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35, tab
  9f16563e-9ee5, body eda9347a-feaa; AR wrote revs 1-20, stops at RA's first
  edit); internal budgets (`<module>.ngd.json`), PRF organisation,
  write-port / crossbar / migration plans; RCU's side of every contract.
- RA does NOT own implementation (Daniel, 2026-11-01: a separate session
  will implement once the arch spec is ready). RA does not edit schema/,
  params/, tools/, rtl/top/ or the stub: changes are RA rows with TI in
  Needs. Cross-block or top-level parameter: AR. OOE side: OA/OI. ISA: IS.
- Register tab RA: node 9851686b-2b0a (file 8b9d4d3a-16f1), doc
  JApHYjaUESeq8tsGMGXMU5. Write only RA tab; respond in RA's responses
  table. Notify per .claude/skills/register/SKILL.md section 2.

## Daniel's instructions (2026-11-01)
1. Setup per rcu-arch.md section 9 (done, below).
2. Grill AR: raise questions as RA rows, Needs AR, notify AR; iterate until
   AR's questions are exhausted.
3. Then write a first-pass RCU Arch document and notify Daniel for review;
   he will iterate on it with RA.

## Daniel's answers on the first pass (2026-11-02)
1. No area target; "see where we land". Goal is synthesizability at a
   reasonable frequency and efficiency: the same NGD and clock-gating rules
   as OOE (25 NGD, 12/port side, .ngd.json, CG-5, RST-1, DCGE 75%).
2. RA is arch only. Runs (Phase 1 sizing etc.) belong to the RCU
   implementation agent (not yet created), helped by RH if needed. RA does
   not run experiments; it states what to measure and the exit criteria.
3. Scope/depth: the full cycle-accurate pipeline and arch description; RTL
   must be implementable from the spec alone. So: every stage, every
   register (name, width, enable), every mux select source, every channel
   field's cycle, every op's per-cycle behaviour, every FSM/counter.

## Setup state
- Roster: RA session written (commit b584233). session-home installed and
  --check matches (2026-11-01). Daily sweep scheduled task
  trig_01JZMJCYRH5T7SqDydL9Smps, 02:27 America/Los_Angeles.
- Raise a row asking OA (skill owner) to add RA minute 27 to the skill.

## Repos, branches, push
- Core: /home/user/custom-cuda-core, branch `ccr-126afa13-clcw9s` only
  (merged AR's ccr-80102643-4n8bv4 at 427aa3c for docs/rcu-arch.md).
  Compiler: /home/user/custom-cuda-complier, same branch name, read only
  (ISA v1.9 at the pinned snapshot d9ddd2c5:
  docs/isa-v1.9-operation-map-and-encoding.md).
- Push: tools/gate-push.sh (scoped gate; docs/ and .claude/ map to no
  sections). Merge commits only. No PRs. No model ids in commits.

## Register bookmarks (2026-11-04 sweep)
AR 284, OA 331, RA 69, DA 106, Conventions 17, CP 152, IS 189, TI 319, OI 274, RI 6. RA-39 (c) landed (TI rev 309); only OI lead NGD/CG left.
TI rev 319: the model is the default (863a374); RI-7 / RA-18 wait on OI's imm_kind 6 (11-06).
RI-9 answered (RA rev 69; RI notified): sub-blocks rcu_<name> (CCV-L28, every tab and
rcu-impl.md); R0/R1/MW selects loaded every cycle, ungated (~31 flops/slice); R0/R1 hold an
8-bit binary row decoded in the slice in A, bank out 13 / r in 12, R2 keeps one-hot, out 11
(RI measured 11.0 at 649ee09, 6,574 flops); fallback one-hot loaded every cycle (~72/slice);
write data straight into D; RCU masks nibble/above dst_width; port hit ORs its lane mask.
Waiting: RI to measure the binary-decode R0/R1 read.
OI-115 (OI rev 282): OOE's R lead mux in select costs 8.3 NGD (ooe_sched 38.8 vs cap 30.5).
OA rev 335 asked RA to price (2): R0/R1 read in A from the payload's phys_src, no lead.
RA rev 70 (OA notified): fits, ~19.5. rsrc_a moves into the slices (raw read; no read-through
of the slice), align to A+1 (~15-16), MIU forward = bank-level MW write-through, lead_src_used
dropped. Asked phys_src RCU in 18 / OOE out 7. RA prefers (2) even if (0) fits. On OA's ruling:
update R unit / Register file / Partition tabs and rcu-impl.md; TI row to drop lead_r_src0/1.
OA rev 336 TOOK (2) (budgets granted; TI removes lead_r_src0/1; AR's (d) lapses; OI records
OOE out 7). RA rev 71-72: spec written (R unit 16, Register file 12, Partition 29, Pipeline 13,
Conventions 5, Overview 38), rcu-impl.md updated; RI notified to build from phys_src and measure
port->rsrc against 18. RI rev 8: 18.4 (15.9 in slice + 2.5 fanout), not retimed.
RA rev 73: asked OA to move 1 NGD (phys_src0/1 RCU in 19, OOE out 6; rr_row arrival 8.5);
RI's departures accepted: rlow from rcu_pred's flop; ngd.json arrivals; RI-9 (e) lane mask as
D-cone hold mux where it arrives with data. Phase 2 figures in Overview (rev 39). OA rev 337 granted 19/6 (last move on the pair); RA rev 74
closed RA-39; spec + snapshots at R unit 20, Register file 15, Partition 33, Overview 43.
RI-11 (RI rev 9): RI reports a DA ruling of 11-05 (flop on both sides of every block boundary;
RCU must not consume inputs off the wire; RA-39 split void). NOT in the DA tab (still rev 106);
DA row .35431 says "registered on both sides". RA rev 75: holding until DA confirms reading
(A) receiver flop at every input (+1 cycle on every RCU latency or two-ahead leads; AR/DA call)
vs (B) the sender's flop is the boundary (today's rule: 12 NGD/port side).
TI rev 321 recorded Daniel's words (TI's session): the interface module defaults to one flop on its
input and output (2 cycles a link; a zero-cycle option is kept); AR decides the latency accounting
first; the lane read-to-writeback latency grows, bypass doesn't. So reading (A). OA rev 338 holds
for a DA-tab row. RA rev 76 (AR notified): RCU internals invariant if lead+payload share a link;
couplings for AR: L1-hit forward (MIU vs issue link), credit depths (map/mig/PCA -> RCU mig FIFOs),
KILL_DRAIN. After AR: restate Conventions (A from receiver flop Q), Partition (arrival 0),
R unit/Register file (RA-39 without the split), rcu-impl.md; RI arrivals 0 / 2.5 / 11.
AR rev 285 accounted it: from the RCU's interface flop, inputs at 0 NGD; LANE 8, SFU 13,
L1_WAKE 17, L1_CMPL 19 (OA confirms), RCU 3, COLLECTIVE 5, bypass unchanged. RA rev 77/78
confirmed (LW A+7, SW A+12; lane done loaded A+6 / wire A+7 / payload A+8, SFU A+11/A+12/A+13;
descriptor ages 6, 11; KILL_DRAIN 16; lane-bypass window 9; guard ~15). OA still holds for a
DA-tab row; TI derives the params once OA confirms. Spec restated (2026-11-05): Conventions 10,
Partition 38, Done 24, Pipeline 17, Lane+memory 8, Predicate 7, Register file 16, R unit 22,
Overview 49; snapshots and rcu-impl.md (block-boundary bullet) current.
AR row 286 (AR rev 287): accounting FINAL. DPI-host ends stay no-flop; +1s in RCU_ADDR_BASE 5->6,
LANE_BASE 8, SFU 13; no credit depth grows; MISS_WAKE/CMPL_HINT/LANE_BYP unchanged. RA rev 79 (AR, TI
notified): KILL_DRAIN derived (16); RA reads ADDR_BASE +1 as the receiving interface flop, so PF-47
reapplies as 2 (RCU-internal 1), L1_WAKE 17->13, fallback 3 - AR to confirm; lane bypass ages 4-6,
compare 12 entries (3 ages x 4 sections), SFU at PRF A_p+12. Spec: Lane 11, Overview 50, Partition 39,
Conventions 11; snapshots current.
AR row 288 CONFIRMED RA rev 79 (PF-47 as 2, L1_WAKE 13, CMPL 15, fallback 3; bypass 4-6). RI rev 10:
RI-11 done for RCU (arrivals 0, rd2 11, check-ngd passes, model params-derived). Nothing open for RA here.
RI rev 11: M3 met (192-row slice: 6,554 flops, CG clean, one row gate 71% medium within allowance; NGD 18.4).
RA rev 80 accepted; asked RI to name that gate and report it at block assembly (split enable before waiver).
DA rev 108 (Daniel, verified in DA tab): receiving boundary flop's lead slice is ungated and counts against
the receiving block's per-instance 2% (RCU: ooe_rcu_issue 144 + miu_rcu_data lead); shrink lead fields first.
Partition rev 40 records it (~4,700-flop block budget at 192 rows, also carries the slices' 71% row gates).
RI-14 (RI rev 14, phase 3): RA rev 81 accepted rcu_pred (2,870 fl, NGD 22.0) / rcu_kill (58 fl) / M1 22.0;
took departures (1) OL/OR/OC in pred, (3) dq 18 but gt/pdt/br at 0, (4) shared epoch reg w/ assertion,
(5) rcu_r pr_orow (Partition rev 41); DECLINED (2) CG-5 waivers on m_am/rg_hi (use interface flop lead
directly, else ungated in allowance). Credit-pulse block-budget ask (rcu_kill 45 cr pulses, CG-1 waiver):
RA supports; DANIEL TO RULE (asked in chat). M4 kill-drain bound unexercised: TI's kernel + V-24 checker.
RI-15 (RI rev 15): strict CG-5 leaves no legal rcu_pred layout (MIU lead 152 fl, R guard 9 fl held into
payload cycle; enable would be an input). RI offered (a) iface-flop Q as enable, (b) 2-cycle leads, (c) waivers.
RA rev 82: (a)/(c) reverse Daniel's CG-5 ruling; RA proposes (d) one-cycle ungated lead holds charged to the
block 2% like DA rev 108 (161 fl; block ~1,500 of ~4,700). DANIEL TO RULE (with credit pulses). rcu_pred/kill held.
Sweep 2026-11-05: merged 57eff422 (139), 888218a3 (20), 183cc441 (7), 80102643 (14), 9eb50716 (15),
c22116ce (5); full gate green, pushed. TI rev 332: RCU leads 835 + controls 420 (Partition rev 42 budget ~2,500/4,700).
Zero-cycle pricing (OA 347, AR 298): RA rev 83/84 - lane_rcu_res zero-cycle recommended (RI rev 16: LW 9.0/10.4,
PL merge 9.0-10.2, sec_valid never an enable) -> LANE 7/SFU 12; miu_rcu_data stays flopped (guard fwd 16.2 > 12;
needs a split); issue stays flopped (18.4). RI model runs (S1, CoreMark) pending for DA.
PF-47 base 2: OA 346 agrees, TI waits on AR (AR 288 confirmed). RI-15 + credit pulses: still DANIEL.
RI-16: zero-cycle model runs blocked (skeleton lacks boundary flops); AR bases alone S1 +1.17%.
AR row 300: receiving flop's cycle is link term bnd_rx; bases back to LANE 7 / SFU 12 / RCU_ADDR 5 (PF-47 base 1,
derived 2). RA rev 85 took it; spec Overview 52, Partition 43, Conventions 12.
AR row 301 CORRECTS: CCV_LAT_RCU_ADDR = its base (5; PF-47 1); bnd_rx(issue) only on the crossing (L1_WAKE/CMPL
17/19, 13/15 after PF-47). Default ends option 1 (RCU's 3 receiving ends flopped). RA rev 86; spec Overview 57,
Partition 44, Conventions 13.
DANIEL 2026-11-06 (RA session, verbatim in RA rev 87): "Yes it's ok to waive module level clock gating
violations for interface lead signals, with the expectation (to be validated at final construction) that these
will fit within the 2 percent block total". RI-15 decided as (c): RI keeps a90cb8f's waivers, pushes rcu_pred/kill.
Not covered: rcu_kill's 45 credit pulses (CG-1) - still open for Daniel. AR asked to record in DA tab; TI asked
to include waived lead flops in check-cg block total. Partition rev 45. Pongs: answered OI's ping 11-06.
TI rev 343: check-cg charges "lead": true waivers to the block 2%. DANIEL 2026-11-06: "Yes, charge the credit
pulses to the block's 2% too" (RA rev 88; TI/RI/AR notified; AR to record in DA tab). Both of Daniel's open
rulings now made. Partition rev 46.
TI-51 (DA 2026-11-06): (1) compact at 350k - AFTER merging TI's next push, re-run session-home installer
(/home/user/.claude takes 350000; needs Daniel's approval here). (2) no whole-block synthesis: block NGD/CG =
sum of parts from module runs; port budgets are the contract; every module needs a unit at each instantiated
parameter set (Partition rev 47). TI rev 344: check-cg charges "credit": true too. DA 110 records RA 88.
RA rev 89 restates latency accounting. AR 308: ooe_rcu_issue stays flopped (zero-cycle gains only L1_CMPL -1 and
V-35 done -1; reopen if OI prices >0.2% S1). OA 348: DA adopted zero-cycle receiving end (cone <=12, link_n 0,
abutting). lane_rcu_res zero-cycle pending DA in RI-11 package; miu_rcu_data stays flopped (16.2 > 12).
RI-17: 198 lead flops as built (MIU 4x46 + R 14); Partition rev 48 snapshotted. DA 111/112 record TI-51.
RI to update rcu-impl.md ("timed whole" -> sum of parts). RI-16: skeleton lacks boundary-flop model.
11-06 sweep: merged 80102643 (30), 9eb50716 (14), 57eff422 (13), 3868632d (11), 888218a3 (7), c22116ce (6).
Friday pings: all ponged ok (OA TI AR CP IS RI OI RH). Pongs sent 11-06: OI AR OA TI CP IS RI.
session-home --check DIFFERS (autoCompactWindow, env): needs Daniel's approval to rerun installer.
AR 309 (re:TI-350): bnd_rx in credit depth, 2(N+bnd_rx); hosts keep it. RA rev 90: at RCU's RTL top, pass the
credit unflopped through BOUNDARY (depth 4 not 6; miu_rcu_data alone 8,912 flops); depth-5 variant priced then
with RI. Rescue sizing is TI's. 11-06 sweep pushed 31db61a (full gate).
DANIEL 2026-11-06 (RA rev 91): zero-cycle receiving end approved ONLY for IPC ("the flop will pay for itself in
convergence turn-around time ... power and area are likely to be a wash. The IPC is where we can't recover").
RA withdrew the timing-based lane_rcu_res recommendation; all three ends flopped (LANE 8/SFU 13) until RI-16 runs
(S1, CoreMark, flopped vs zero-cycle) show IPC. RA proposed AR 308's 0.2% S1 bar - Daniel to confirm. Notified
AR (record in DA tab), RI, OI/OA (price C9 at 8/13), TI. Partition rev 49. session-home installed 11-06 (Daniel approved).
AR 311 (DA rev 113 records Daniel's ruling; 0.2% bar = RA proposal awaiting Daniel) CORRECTS RA 90: unflopped
credit through a flopped rx end is depth 5 (forward flop stays), not 4; miu_rcu_data +4,456. RA rev 92 took it.
TI 352: skeleton already models boundary flops (17720a0); RI-16 zero-cycle arm runnable now; rescue sizing TI 351.
Bookmarks: OA 366, RA 92, RI 21, TI 352, DA 113, AR 312, OI 306, Conventions 17, CP 155.
RI closed RI-4..6 (RI rev 3); RI-3 closes when TI marks the migration channels backpressured.

## Spec doc (RTL-depth spec COMPLETE, 2026-11-02; Daniel notified for review)
Doc 1e5066f9-e4db-4fe3-aabc-0022606c9e96 (https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB).
Tabs (file / body): Overview dfa9bcdb-0b00 / 81a1f5d5-f92b;
Conventions b8c07a83-ca95 / 46057b65-98f1 DONE; Pipeline 8b466d58-aee5 / 37f906fe-2422 DONE;
Register file 13b95959-8f04 / dd7dc786-f025 DONE; Predicate file 0e99a93e-aac2 / fe349acb-7397;
R unit 72c26a02-6c53 / 10fb0241-f5be; Lane+memory 28e9ca7b-9ffb / 6773bf05-88be;
Migration 7ddc7f8b-7c6e / 662008ee-60e7; Done/kill/reset ef251def-47bc / 624901bd-f2e3;
Partition 7a8bcca7-ef25 / 9c653c29-9e9c. All tabs filled; Overview rewritten (status, tab guide, decisions, settled RA-1..17, open RA-16..29, For Daniel).
Digests: scratchpad digest-schema.md, digest-stub.md, digest-isa-ooe.md (lost with container).
Design decisions taken in the rewrite (RA's own): A/A+1/A+2 stages; GPR write ports 4/bank
(LW lane A+6, SW SFU A+11, MW load T, RW R A+2) - collectives run in the R pipe (W=A+2, done
slot 6 at A+1), so the 5th port goes whatever CCV_LAT_COLLECTIVE says; split one-hot row
predecode (hi 12 + lo 16 flops); done slots fixed: lane lead section k->k, SFU 4, R-only 5,
collective 6; pred file: masked write ports (sel, mask, data), old-dst read at write time (no
forward needed: old dst is ready at issue); guard forward only from MIU pred_result in A;
restore staging FIFO depth = CCV_CREDIT_DEPTH (4); demote reads R2 when R op doesn't, restore
writes RW when R op writes no GPR; wake = flop of OR of input wakes.
Partition (RA's, Partition tab): every module decodes the raw issue payload itself (no through-paths);
predicate file + guard/active/branch/leads in ccv_rcu_pred; banks the only combinational-output modules;
modules: ccv_rcu (top), _bank x4, _pred, _r (+_xbar helper), _lanes (done 0-4), _mem, _mig, _kill (drain/ack,
done wake, idle). ~235k flops. Port NGD budgets table in Partition tab (pred guard in 23 from block port 2).
Stall-safe sender: valid flop D = want & ~stall (raw), all state advances enabled by the flopped valid.
Main CG risk: lane/addr payload DCGE at high load (split enables per section/field group; waiver last).
Kill: KILL_DRAIN = 2 + link(issue) + LAT_SFU + 1 + link(done) = 15; ack level + epoch.
Round 3 rows RA-18..RA-27 (rev 41) and RA-28 (AR), RA-29 (AR, TI, OA) at rev 42; notices sent.

## Open work, most urgent first
- RI M0 (model) ACCEPTED at RA rev 68 (5968894; RI rev 5); TI asked to make the model makeRcu's default. RI on to phase 2 (bank slice, r/xbar). RA-36 done (TI rev 317, e60ae23). AR rev 284 sets the PHYS_REGS order: OI's check answer, 160 on a 2nd 4-warp kernel, OA on Q-35, then DA.
- RA-11 PHYS_REGS sweep (TI rev 315): RA rev 67 gave RCU flops 246k/212k/179k at 192/160/128, notice AR; decision AR + DA. 160 ~free; 128 waits OI's fits_stale/V-N check failures. RA-19 stub fix landed (TI rev 314, 9ce7381).
- RA-40 closed: TI landed MIU lead_fields (b85595b, TI rev 311), AR MIU spec rev 48; closure at RA rev 66.
- RI is live: session_01QPk2jvvXPLs4m8ZQbSk1g6, register tab 8e4547bc-c469 (bookmark rev 2).
  RI-3..6 answered at RA rev 64, notice sent: credit at launch intended (TI marks
  ooe_rcu_map / rau_rcu_mig backpressured); LW = footprint (Lane+mem rev 5); FULL_ROW
  parameter, 1 now, SW+MW+RW whole row zero above width (Register file rev 7; asked RI to
  check SW in its model); RI-6 (a)-(d) in Migration rev 7, Predicate file rev 4.
- 2026-11-04 HANDOFF AUDIT DONE (Daniel: "everything ready for handoff to RI"). Spec live revs:
  Overview 31 (status says ready for RI; decisions + open tables cover RA-35..39), Conventions 4,
  Pipeline 5 (IL/I/R rows + R-op cycle table carry RA-39), Register file 6, R unit 8, Done 13,
  Partition 16 (M3 budget 11). Snapshots all current. rcu-impl.md: fanout enforced, RA-39 bullet,
  phase 2 exit (bank-out 11; A path ~16, A+1 compute ~13), waits-on row RA-39 (TI c, OI lead NGD/CG).
  Sizing stand-in archived at archive/rcu-bank-sizing/ (Daniel, 2026-11-04).
  Next: report to Daniel; RI waits on TI (RA-16/30/36/37/38/39c) and OI (ooe_wake, lead NGD/CG).
- RTL-depth spec complete (2026-11-02): https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB.
  Daniel notified for review; iterate on his comments (doc comments or chat).
  First pass is in the Overview tab's history (rev 15).
- Settled 2026-11-02 and folded into the spec: RA-14, RA-18..RA-27, RA-29 (OA, TI halves). O-85 =
  collectives (diagonal unballot). Fence DOES send an address msg. CSR = read-0 responder.
  RA-30 (TI) raised: repo half of AR's answers. RA-28/29 settled too (AR rev 265: pairing queues = CCV_TIER1_WARPS; FIFO stays 4; A+2 rule for
  every R class). Still open: RA-16, RA-30 (TI).
- Daniel 2026-11-02: spec good as a first pass. DCGE = share of ENABLED cycles where the value
  changes (risk = enabling unused fields, not high load). No parity/ECC v1 (PF-48); flops not latches
  (PF-49); PRF fully scanned by synthesis, te only on ccv_common_clk; Daniel spins up the impl agent.
- RA-31 (AR/TI/OA: CCV_LAT_RCU_ADDR 5->1; lead slice section mask + operand use), RA-32 (OA guard
  fallback resolve_lag 1; TI per-unit param overrides) raised rev 45, notices sent.
- OA rev 306 (re RA-31/32): L1 wake follows derive; OOE adds the lead slice from select if OI's NGD fits;
  no lag-1 fallback (DA's call if >0.5%); OOE leads R's guard phys pred so RCU splits the guard read
  (predecode A-1, guard ~22->~16 NGD). Folded into Predicate file tab; RA response at register rev 46.
- RA-31/32 SETTLED (AR 266, OA 307, TI 285): ADDR_BASE=1 (PF-47, AR's number; RA's parity/latch items
  renumbered PF-48/PF-49), lead slice contents fixed, reduced units = module params. Folded: Partition tab
  'The issue lead slice' + control lead-src-clear (TI's name, rev 288; was lead-promise); Overview table rows. RA response rev 47, TI notified.
- RA-33 (TI, high: fanout buffering in check-ngd's netlist; on answer add a select-replication rule to the
  Register file tab) and RA-34 (TI: RCU cg stimulus from kernel traces) raised rev 48-50 at DA's request.
- Floorplan: DA has an idea but bakes nothing in until bottom-up gate counts exist. Don't raise it.
- TI rev 286: RA-33 fanout NOT costed (load-blind genlib); DA to pick (a) check-ngd fanout term or (b) fanout
  limit; spec assumes (a) (Register file tab 'Select fanout': per-bank-section select copies, ~6.3k flops).
  RA-34: scenarios by activity; high = coremark128+vadd traces, medium = +2 idle, idle = reset; RA said yes to
  TI's ccv-skel port-trace dump (rev 51). DCGE accepted only from traces after the stub's RA-19 merge fix.
- DA chose (a) on fanout (2026-11-02); TI told to build it (rev 52). Spec 'Select fanout' marked decided.
- TI rev 287: fanout term built report-only (TI ef51d19, local until its gate). Enforced later.
- Spec snapshot (DA, 2026-11-02): docs/design-snapshots/rcu-arch-<tab>.md, 10 tabs, status living.
  Refresh all ten together when a tab changes (README says how: Docs blob -> Artifact read path, then
  tools/snapshot-doc.py). Tab revs at snapshot: Overview 27, Conv 3, Pipe 4, RF 4, Pred 3, R 5, Lane 4,
  Mig 6, Done 12, Partition 8.
- Top-level docs (DA, 2026-11-02): per-block specs RCU tab reconciled (rev 23, RA's). Repo docs stale, raised
  rev 53: RA-35 (AR: rcu-arch.md ports/latencies/section 8, strategy doc :53 ports) and RA-36 (TI: roadmap Part 0
  RCU status, rcu_miu_width schema question/Q-18, Q-53 pointer, ooe-model.md L1 wake 16->12 for OI). Notices sent.
- RI (RCU implementation) set up 2026-11-02 at DA's request: register tab RI (file 02bd1184-1cfb, node
  8e4547bc-c469, order a56), Conventions row, DA tab row, roster RI (session null), handoff docs/rcu-impl.md.
  DA DECIDED 2026-11-02: cycle-accurate C++ model (sim/rcu/, RI's) ahead of RTL, lock-step for good (DA tab;
  RTL-first lost). Spec: Overview 'Model first' row (rev 28), Partition M0 + swap text (rev 9), snapshots
  refreshed. RA-38 (TI: makeRcu hook + CCV_RCU_IMPL=stub, blocks.list, gate-scope sim/rcu/, model unit job,
  RTL lock-step job). DA refined (DA tab): model cycle-accurate at interfaces + events (writes, dones,
  branches, kill, migration), hazards, stalls, idle/sleep; NOT an RTL clone. RTL modules: own benches; RTL vs
  model lock-step at block ports + events only. Partition rev 10 + rcu-impl.md section 5 say so. RA-37 (TI: gate-scope map, bench job, SV-hosted
  selector, CLAUDE.md line, heavy-units; OA: skill minutes RA 27, RI 31). Answer RI rows (RA in Needs);
  review each phase exit row.
- TI rev 288: lead slice in schema + stub (control lead-src-clear); ADDR_BASE=1 reverted, waits on OI (ooe_wake NGD
  26.1 at new constants; no-msd control seeds). Spec Partition rev 12 says so. Watch for TI's reapply.
- TI rev 289: heavy-unit lock + tools/heavy-units.json (eb170bf, on ccr-183cc441-doowtf; the sweep merges it);
  sweep task prompt now skips gate-scratch/* (updated 2026-11-02). Fanout term first run: 10 OOE units >25
  (ooe_rob 44.3); RCU's spec has per-bank-section select copies already.
- Sweep 2026-11-03 pushed at 047159d (SPLIT SCOPED PASS: cg alone 58 min, exported, then gate-push --import; a
  4-core container can't fit cg+ngd in one 2 h job). TI rev 295 fixed the heavy guard (per-command peaks, 16ab8ae).
  OI's ooe_rob split landed (ooe_rob_w); heavy-units.json merged as ooe_rob_w, ooe_rename, ooe_sched.
- Bank slicing DECIDED (Daniel 2026-11-03/04): ccv_rcu_bank_slice #(K,J) x32 = byte K of lanes 4J..4J+3,
  192x32b, ~6,550 flops, own 14x28 selects, 32-flop row gate groups; physical chunk = 4 slices (4 lanes whole,
  ~770k cells), 8 chunks; flat P&R, chunks keep physical partitioning open. Folded: Register file rev 5,
  Partition rev 13, Overview rev 29 (decisions row), snapshots, rcu-impl.md. Rejected with numbers: 2/8-lane byte
  slices, 1-lane x 4-section lane slice (+27k select flops), one-hot selects (fanout fix, not depth: 8.0/9.3).
  Stand-in + measure.py only in scratchpad sizing/ (lost with the container).
- R read depth: Daniel said go (2026-11-04) on the retime; RA chose the EARLY R SOURCE READ instead of compute-late:
  R0/R1 rows on the R lead (lead_r_src0/1), predecoded A-1, read in A into rsrc_a (2,048 flops), compute A+1 from
  flops (~13), write A+2 unchanged (LAT_RCU 3, collectives, slots 5/6 unchanged). Safe because a result is readable
  at A_p+LAT and R consumers never bypass; other readers read at A+1. RA-39 raised (RA rev 61; OA (a) hazard + (b)
  lead fields, TI (c) schema, AR (d)); notices sent. Spec: R unit rev 7, Partition rev 15 (bank out 11 on all
  reads, r in 14), Register file rev 6. OA rev 328: all classes meet A except L1-hit loads (data lands in the
  consumer's A); lead fields accepted. RA priced (i) MIU forward after alignment (RA rev 62, R unit rev 8): ~10k cells,
  ~190 flops, A path ~16. OA TOOK (i) (rev 329). AR (272-273) asked the partial-write merge be priced: answered RA
  rev 63 (after alignment the source = the written sections; per-lane merge only; input path 5 NGD). Waiting: TI (c)
  schema, OI lead NGD/CG. AR (d) agreed (rev 271). Fanout term now enforced in check-ngd (TI rev 299, DA 2026-11-04).
- Sectioned lanes KEPT (Daniel 2026-11-03; OI-28..31); packed contiguous lanes = PF-50 (c7938fa).
- Answers due: RA-16, RA-30, RA-36 (TI); RA-37/RA-38 AGREED by TI rev 290 (building: gate-scope + CLAUDE.md first, then makeRcu,
  blocks.list, check-rcu-unit, job_rcu_rtl, CCV_RCU_RTL), impl pending; RA-35 (AR); RA-37 (OA: RI 31 only, roster commit bc1c2b4 named at rev 55); port-trace dump. Lead slice: AR agreed the interface (rev 267); waits on OI select NGD and TI schema. Daniel: review; collective fold 5->3 decision after Phase 1. Fold each answer into
  the spec tab it names (Overview's open-questions table lists where).
- Spec tab reconciliation (rcu-arch.md section 5: per-block specs doc RCU tab
  eda9347a-feaa) after Daniel accepts.
- Implementation session (not RA's): Partition tab's M1-M7 are its exit criteria.
