# RA handoff (RCU block architect)

Updated 2026-11-04. Keep this current at every task's end; it is what
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
AR 275, OA 331, RA 64, DA 106, Conventions 17, CP 152, IS 189, TI 309, OI 274, RI 3. RA-39 (c) landed (TI rev 309); only OI lead NGD/CG left.
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
