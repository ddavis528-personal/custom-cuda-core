# RA handoff (RCU block architect)

Updated 2026-11-02. Keep this current at every task's end; it is what
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

## Register bookmarks (2026-11-01)
AR 267, OA 307, RA 50, CP 151, IS 184, TI 285, CP 150 (others as at session start: OI 252,
CP 149, DA 99, Conventions 16).

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
  'The issue lead slice' + control lead-promise; Overview table rows. RA response rev 47, TI notified.
- RA-33 (TI, high: fanout buffering in check-ngd's netlist; on answer add a select-replication rule to the
  Register file tab) and RA-34 (TI: RCU cg stimulus from kernel traces) raised rev 48-50 at DA's request.
- Floorplan: DA has an idea but bakes nothing in until bottom-up gate counts exist. Don't raise it.
- Answers due: RA-16, RA-30, RA-33, RA-34 (TI). Lead slice: AR agreed the interface (rev 267); waits on OI select NGD and TI schema. Daniel: review; collective fold 5->3 decision after Phase 1. Fold each answer into
  the spec tab it names (Overview's open-questions table lists where).
- Spec tab reconciliation (rcu-arch.md section 5: per-block specs doc RCU tab
  eda9347a-feaa) after Daniel accepts.
- Implementation session (not RA's): Partition tab's M1-M7 are its exit criteria.
