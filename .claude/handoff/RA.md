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
AR 261, OA 296 (RA tab now rev 2), IS 182, TI 282, OI 252, CP 149, DA 99, RA 1, Conventions 16.
Nothing had RA in Needs at session start. AR now 262, OA 297, RA 30.

## Open work, most urgent first
- AR round 1 answered (AR rev 262), RA rows updated (RA rev 30). Settled:
  5 scheduled write ports/bank + migration; SFU 2nd result on lane_rcu_res;
  MIU lead fields (phys_dst..pred_we) for CG-5; A = RCU holding issue
  payload, GPR read A+1, pred read A (+forward), lane gets A+3..A+5;
  done valid leaves by A+L-1; LAT_RCU_ADDR counts to valid launch, plan 1
  (2 fallback), PF-47; collective->3 pursue, hold 5 till Phase 1, then
  OA then DA (changes OA-4), time register-index shfl (~21 NGD est);
  xbar = RCU sub-module; Q-18: AGU in MIU; no area budget before Phase 1
  (report flops / write D-mux / read mux separately); floorplan: 16 lanes
  each long side, MIU one short side, PCA+OOE other, lane links 0 stages;
  widening clear struck; migration borrows R ports + OOE idle-R 1-in-K.
- Round 2 to AR: RA-13 dispatch_fault, RA-14 kill vs migration, RA-15 ops
  on R. RA-16 to TI (schema/params), RA-17 to OA (idle-R rule). Notices
  sent. When AR's round 2 returns and nothing new: write first-pass arch
  doc (Claude doc, intent document), notify Daniel.
- Spec reconciliation (rcu-arch.md section 5) on first edit of RCU tab.
