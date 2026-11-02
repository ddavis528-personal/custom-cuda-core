# RA handoff (RCU block architect)

Updated 2026-11-01. Keep this current at every task's end; it is what
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
AR 263, OA 299, RA 40 (others as at session start: IS 182, TI 282, OI 252,
CP 149, DA 99, Conventions 16).

## Spec doc (RTL-depth rewrite in progress, 2026-11-02)
Doc 1e5066f9-e4db-4fe3-aabc-0022606c9e96 (https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB).
Tabs (file / body): Overview dfa9bcdb-0b00 / 81a1f5d5-f92b (first pass, to rewrite last);
Conventions b8c07a83-ca95 / 46057b65-98f1 DONE; Pipeline 8b466d58-aee5 / 37f906fe-2422 DONE;
Register file 13b95959-8f04 / dd7dc786-f025 DONE; Predicate file 0e99a93e-aac2 / fe349acb-7397;
R unit 72c26a02-6c53 / 10fb0241-f5be; Lane+memory 28e9ca7b-9ffb / 6773bf05-88be;
Migration 7ddc7f8b-7c6e / 662008ee-60e7; Done/kill/reset ef251def-47bc / 624901bd-f2e3;
Partition 7a8bcca7-ef25 / 9c653c29-9e9c. Each unfilled tab has one pending block (read outline).
Digests: scratchpad digest-schema.md, digest-stub.md, digest-isa-ooe.md (lost with container).
Design decisions taken in the rewrite (RA's own): A/A+1/A+2 stages; GPR write ports 4/bank
(LW lane A+6, SW SFU A+11, MW load T, RW R A+2) - collectives run in the R pipe (W=A+2, done
slot 6 at A+1), so the 5th port goes whatever CCV_LAT_COLLECTIVE says; split one-hot row
predecode (hi 12 + lo 16 flops); done slots fixed: lane lead section k->k, SFU 4, R-only 5,
collective 6; pred file: masked write ports (sel, mask, data), old-dst read at write time (no
forward needed: old dst is ready at issue); guard forward only from MIU pred_result in A;
restore staging FIFO depth = CCV_CREDIT_DEPTH (4); demote reads R2 when R op doesn't, restore
writes RW when R op writes no GPR; wake = flop of OR of input wakes.
Round 3 rows RA-18..RA-27 raised (RA tab rev 41), notices sent to AR, OA, IS, CP, TI.
To raise next: RA-28 (AR: MIU never lands two loads on one section in a cycle; pca_rcu credit
depth / staging; at most one demotion + one restore in flight), RA-29 (AR/TI: write ports 4,
collectives in R pipe; SFU bypass window vs PRF write).

## Open work, most urgent first
- First-pass RCU Arch doc written: https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB
  (doc 1e5066f9-e4db-4fe3-aabc-0022606c9e96, body node 81a1f5d5-f92b,
  tab dfa9bcdb-0b00, timeline widget d460388b-053c). Daniel notified for
  review; iterate on his comments. Asked him: area/power targets; Phase 1
  in this session or on RH; is the scope right.
- AR questions exhausted (rounds 1-2, AR revs 262/263). Settled list is the
  doc's section 1 table (RA-1..RA-17).
- Key correction (AR re:RA-6): migration owns NO port. Demotion reads via
  an idle R read port (10 physical read ports/bank, not 11); restore rows
  staged 1 cycle then written via R's write port; idle-R rule K=4.
- RA-16 (a)-(g) waits on TI (notice sent at rev 40). RA-17 to OI pricing
  (OA row 299, knob idle_r_k).
- Rows still to raise (doc section 13): barrier ambiguity TI-40 vs done
  doc slot 5 (OA/TI); PRF needs no reset, confirm no read-before-write
  (OA); OA to add RA minute 27 to the register skill.
- Spec tab reconciliation (rcu-arch.md section 5) after Daniel accepts.
