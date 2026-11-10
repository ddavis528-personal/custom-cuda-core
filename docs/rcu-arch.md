# RCU architecture: handoff to the RCU architect session (RA)

> **Superseded as the RCU reference (2026-11-02, RA-35).** RA's RCU spec is
> complete: live at https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB, pinned
> as `docs/design-snapshots/rcu-arch-*.md`. Where this handoff and the spec
> differ, the spec wins. RA-1 to RA-34 in the register answer section 8's
> questions, and the spec's Overview tab tabulates the decisions. This page is
> kept as the record of what RA started from. Lines corrected since: the port
> counts and the address latency.

Written by AR on 2026-11-01, when Daniel chose RCU as the next major block
after OOE (DA tab, row of that date). This is where the RA session starts. It
says what the RCU is today, what has been decided and where it is written
down, which promises other blocks are already counting on, and what is still
undecided. It also gives a plan skeleton for RA to fill in. **AR expects RA's
first output to be questions, not a plan.** Section 8 lists where those
questions should go.

Read this once, end to end. After that, the sources of truth are the ones in
section 2, not this file. Like every pinned summary, this one goes stale.

## 1. Who RA is, and what it owns

- **RA, RCU architecture.** RA mints `RA-n` in its own register tab. AR made
  the tab empty, at Daniel's request. RA owns:
  - the RCU's block architecture;
  - its spec, the RCU tab of the per-block specs, which passes from AR to RA;
  - its microarchitecture and internal budgets: register-file organisation,
    per-port NGD budgets (`<module>.ngd.json`), the write-port, crossbar and
    migration plans;
  - the RCU's side of every channel contract.
- **AR** stays the top-level architect. AR owns partitioning, cross-block
  contracts and conventions, the performance register (`docs/perf-register.md`,
  PF-30 onward), and the specs of the blocks that have no session. Bring AR
  anything that crosses a block boundary or moves a top-level parameter.
- **TI** owns:
  - `schema/`, `params/`, `tools/`, `rtl/top/`, the gate;
  - every block's stub, including the RCU's C++ stub
    (`class Rcu`, `sim/skel/kernel.cpp`, lines 2395-3267).

  An interface or parameter change is a row in RA's tab with TI in Needs.
  RA never edits the schema directly.
- **OA / OI** own OOE's architecture and implementation. OOE is RCU's main
  partner: it issues to RCU, takes RCU's dones, schedules RCU's write ports,
  and sends RCU the migrating warp's RAT.
- **IS** owns the ISA. RCU executes the warp-uniform ops and the horizontal
  ops, so any opcode-level question about them goes to IS.
- **DA** is Daniel. He decides cost and scope trades, and anything no agent
  owns.
- **Who builds the RCU** (a C++ model and then RTL, as OOE had 4b and 4c) is
  **not decided**. Daniel created RA as the architect. Whether an RCU
  implementation session (RI) follows, and when, is your first question for
  DA (section 8).

## 2. Sources of truth, in order of authority

1. `schema/interfaces.json`: every RCU channel, field, width, rate, lead field
   and slot attribute. `docs/payload-spec.md` is generated from it and is the
   readable form. Where any prose disagrees with the schema, the schema wins.
2. `params/ccv_params.json`: every size and latency (the `CCV_*` names below).
3. The **RCU tab** of *Per-block architecture specs*
   (https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35, RCU tab, rev 20). It is
   yours from now on. Parts of it are stale (section 5). Reconciling it is your
   first task.
4. *OOE microarchitecture, Stage 4*
   (https://claude.ai/artifact/7tpEyGaCvfdvYYWUQJvJSU) and `docs/ooe-rtl-plan.md`
   for OOE's side of each contract. A pinned copy is in
   `docs/design-snapshots/ooe-microarchitecture.md`.
5. The register (https://claude.ai/artifact/JApHYjaUESeq8tsGMGXMU5). Read the
   Conventions tab first. To find any decision's thread, search its ID across
   tabs. The RCU threads that matter most are listed in section 4.
6. `docs/open-items.md` (Q-n), the repository's own tracker.
7. The RCU stub, `class Rcu` in `sim/skel/kernel.cpp`. It is the executable
   reference for RCU behaviour on every kernel the gate runs, on both hosts:
   the C++ skeleton and the SV-hosted top. It is functional, and **its timing
   is a placeholder**. Its `--break` controls are in section 6.

## 3. The RCU in one page

Block R, `ccv_rcu`, one instance. It holds:
- the physical register file, as a flop array;
- the predicate file and its ALU;
- the 32-lane collective crossbar;
- everything that is warp-uniform rather than per-lane.

It does not rename: it receives physical names from OOE. It holds no parked
state; PCA does.

**Its channels** (from the schema; rate = slots a cycle):

| Channel | Direction | Rate | What it carries |
|---|---|---|---|
| `ccv_ooe_rcu_issue` | OOE → RCU | 9 | Selected ops, one slot per select resource: sections S0-S3, P0-P3, and R. Physical names, the guard and predicate destination, `issue_mask`, the immediate, `done_row`. |
| `ccv_rcu_lane_ops` | RCU → LANE ×32 | 1 | Operands and control to each lane, lockstep across all 32. Lead fields `section_en`, `sec_pred_bit`. |
| `ccv_lane_rcu_res` | LANE ×32 → RCU | 1 | Lane results, written at their contracted cycle. |
| `ccv_rcu_ooe_done` | RCU → OOE | 7 | Completions, a free pool of `CCV_DONE_SLOTS` = 7. The RCU-only class sits on the fixed slot `CCV_DONE_SLOT_RCU` (5). Lead fields `lead_br_taken`, `lead_br_mask`. |
| `ccv_rcu_miu_addr` | RCU → MIU | 4 | Memory-op operands (base, index, store data) and `active_mask`. About 12,400 wires (4 × 3,111: base, index and store data at 1,024 bits each, plus `active_mask` and `rob_tag`), the widest interface in the design (Q-18). |
| `ccv_miu_rcu_data` | MIU → RCU | 4 | Load data, written under `active_mask`, plus `pred_result`. |
| `ccv_ooe_rcu_map` | OOE → RCU | 1 | A migrating warp's RAT: 16 GPR and 4 predicate physical names. |
| `ccv_rau_rcu_mig` | RAU → RCU | 1 | The migration command. RCU pairs it with the map, in either order (A-45). |
| `ccv_rcu_pca_mig` | RCU → PCA | 1 | One 1,024-bit row a message on demotion: rows 0-15 GPRs, 16 the predicates. |
| `ccv_pca_rcu_mig` | PCA → RCU | 1 | The same rows back on restore. A credit back means the row is written (TI-13). |

**Its sizes and latencies** (status in brackets):

- **GPR file:** `CCV_P_PHYS_REGS` = 192 rows of 1,024 bits (32 lanes × 32 bits)
  (provisional), in `CCV_SECTIONS` = 4 section banks of 256 bits a row. That
  is about **197k flops, the largest single structure in the design**. 64 of
  the 192 rows are architectural (4 tier-1 slots × 16); the rest are rename
  headroom. The two zero registers sit outside the pool: `CCV_P_PHYS_ZERO` =
  255 for the GPR file, `CCV_P_PRED_ZERO` = 63 for the predicate file.
- **Predicate file:** `CCV_P_PRED_REGS` = 48 entries of 32 bits
  (provisional; A-21: it must exceed the resident warps' 16 architectural
  predicates).
- **Ports:** 10 GPR read ports and 4 write ports a bank (lane, SFU, load,
  and the R pipe, which carries collectives; RA-2, RA-29, the RCU spec's
  Register file tab). Before RA it said 16 reads and 8 writes. The predicate
  file has its own (A-28, A-33, A-43, A-55). There is no port grant
  (Q-51): OOE schedules every write, and fixed latency is a declared channel
  attribute. The budget lines are `CCV_L_PRF_LANE_READ_BITS` = 4096
  (preliminary) and `CCV_PRF_MEMOP_READ_BITS` = 3072 (arch).
- **Latencies:** `CCV_LAT_RCU` = 3 for the RCU-only class,
  `CCV_LAT_COLLECTIVE` = 5 for the warp-collective class (the fold to 3, RA-8,
  waits on Daniel with Phase 1's figures), `CCV_LAT_RCU_ADDR_BASE` from
  issue to the address valid (RA-31 and PF-47 take it to 1; params still
  hold 5 until PF-47 is re-applied, so read params, not this line), `CCV_LAT_LANE` = 7, and `CCV_LAT_HOP` = 2 per
  crossing with no repeaters.

**What RCU executes** (Q-28, Q-32, Q-38, Q-40): any op whose inputs are all
warp-level, which is:
- predicate logic;
- `pmov`;
- `movi` and `movi48`;
- branch resolution;
- the horizontal ops (`shfl`, `vote`, `ballot`, `unballot`).

The lane executes anything whose result differs per lane: `setp`, `add.pp`,
`cas` and `sel` run in lanes although they touch predicates, and so does
`srd`.

**The RCU-only class** completes on its fixed slot: predicate logic, `pmov`,
`movi`/`movi48`, branch, call and ret, and later the barriers. The
warp-collective class is lat_class 5 and completes on the pool. Only the
RCU-only slot carries `branch_taken`, `branch_mask` and `aux` (OI-93; AR rev
259; TI rev 274).

## 4. What is decided, and where each decision is written down

Cite these; don't restate them. Each is a thread in the register or a Q-n.

- **Flop array, no port grant:** the PRF stays a flop array. An SRAM file
  later would be an interface change that reopens the OOE contract (Q-51,
  A-28).
- **OOE schedules write-back** (A-47). Every lane result and load return lands
  at its contracted cycle. The one writer OOE does not schedule is a restore's
  migration rows.
- **Row-indexed dones** (OI-85, OA rev 282, RCU spec rev 11-19). Each done
  echoes the 2-bit `done_row` from its issue. RCU never holds a done. Two
  dones for one entry may land in the same cycle on different slots.
- **The fixed RCU-only slot** (RCU spec rev 14; OI-93; TI 16af94a).
  `CCV_DONE_SLOT_RCU` = `CCV_DONE_SLOTS` - 2. An op's class names its slot
  wherever it ran.
- **The branch lead** (OI-86 (b), DA rev 98; AR rev 260; RCU spec rev 20;
  built by TI in 80697a3):
  - RCU reads the guard and issue mask in arrival cycle A and registers the
    outcome at A's edge.
  - `lead_br_taken` (1) and `lead_br_mask` (32) ride the done's valid cycle,
    on the RCU slot only. They are 33 output flops, separate copies from the
    payload's.
  - The lead covers branches and calls. A ret's lead is don't-care, so rets
    resolve from the payload at lag 1.
  - OA rev 293 adds a rule: OOE selects no RCU branch or call in the cycle
    after a ret. OI is repricing the cost.
- **The shfl latency** (OI-93 thread; TI b0d91c2/f77582b): `shfl` is
  lat_class 5 at `CCV_LAT_COLLECTIVE`. It moved rope by +14.7% (6763 → 7757
  cycles), because branches depend on `shfl` results. The collective latency
  is therefore a live performance lever (section 7).
- **The masked-load copy op** `CCV_OP_PRF_COPY` (A-38). It takes a lane slot.
  RCU writes only the inactive lanes and sends no done.
- **Load write-back is stateless in RCU** (Q-25). MIU echoes `phys_dst`,
  `phys_pred` and `pred_we`.
- **Migration** (A-45, Q-30, Q-39, TI-13, TI-24):
  - RCU pairs RAU's command with OOE's map by warp and direction, in either
    order, and addresses rows by `warp_id` and `mig_row`.
  - A restore row is written as it is consumed, once RCU holds the map.
  - A credit back means the row is written.
- **No faults originate in RCU or a lane** (IS-16). `exec_fault` and
  `fault_lane_mask` were removed from the done.
- **Immediates are substituted at register read** (Q-22). Lanes never see an
  immediate. `active_mask` = issue mask AND guard is computed in RCU, the one
  block holding both (Q-23).
- **Merge** (the stub; A-62):
  - RCU reads the old destination for every op with `merge_en` and sends it to
    the lanes as `merge_data`.
  - Predicates merge in RCU by read-modify-write under the active mask.
  - The lane-local bypass rules are A-62 and Q-55.

## 5. What in the RCU spec is stale (AR's debt, yours to reconcile first)

AR checked the RCU tab against the schema when writing this. Fix these
against the schema before building anything on the spec:

- **Rates in the ports table:** issue shows 4 where the schema has 9
  (sectioned select); done shows 4 where the schema has 7.
- **The done's field table** still lists `exec_fault` and `fault_lane_mask`
  (removed by IS-16). It lacks `done_row`, `aux` and the two lead fields.
- **"Q-39 (open)"** has been closed since 2026-10-21 (`ccv_rau_pca_mig`).
- **The read-port count** ("16 reads at issue, 4 × three sources plus the old
  destination") predates sectioned issue at rate 9. Recount it from the
  schema's issue slots, and count the memory-path and collective reads too.
  The spec's own question list already asks for this.
- **The op lists:**
  - The predicate ALU is listed as `pand, por, pxor, pmov`, but the ISA's
    list is IS's.
  - The horizontal ops are listed as `shfl, vote, ballot, unballot`, but the
    skeleton has only `shfl.idx` today.

  Take both lists from the ISA in the pinned compiler snapshot
  (`tools/compiler.lock`), not from the spec.
- **"At 192 rows the array is about 24 KB of flops"** is right as bytes. Say
  ~197k flops: that is the unit the clock-gating and logic-depth rules count.

## 6. What is open

**Promises OOE is already built against, which only RCU's build can keep.**
These come first: each one that fails sends a change back to OA/OI.

1. **The guard read in A** must fit A with the issue-mask AND and the any-lane
   OR, registered at A's edge, beside the operand read. The branch lead
   depends on this (DA rev 98).
2. **The ret's priority pick and 32-lane compare.** These produce `aux` and
   the same-target mask, and today they are don't-care in the lead. If they
   fit in A, rets can get a lead too. Whether that is worth it depends on OI's
   repricing (OA rev 293).
3. **No held done, ever.** The 7-slot pool and V-35's bound assume it.
4. **Every write lands at its contracted cycle through the bank's write ports** (A-47; 4 a bank since RA-29),
   with the restore's migration rows fitted around OOE's schedule.
5. **`CCV_LAT_COLLECTIVE` = 5 and `CCV_LAT_RCU_ADDR` = 5** were placeholders.
   Settled since: the address time is 1 (RA-31, PF-47), and the collective
   fold to 3 waits on Daniel with Phase 1's figures (RA-8, RA-29).

**The spec's own questions** (RCU tab, "Questions for the session"):

- **The write arbiter:** priority, and whether migration can be preempted
  mid-transfer.
- **The crossbar:** should it be its own block? It shares only floorplan with
  the array, and its NGD budget should be stated separately from the array's
  mux tree.
- **The predicate file:** is 48 entries the right depth, and are predicate
  rows 32 bits or warp-width?
- **The read-port budget,** with memory-path and collective reads counted.
- **The widening clear:** per row, per slice, or lazy with valid bits.

**Repository items:**
- **Q-18 (open; settle before floorplan):** RCU → MIU is about 12,400 wires.
  Co-locate the AGUs, or move address generation into the register-read stage?
  It is a partitioning question, so AR and RA settle it together, with MIU's
  spec (AR's) on the other side. PF-33 is the related performance item.
- **Q-53 (scheduled, with each block):** the OOE-session checkers that need a
  block's internals. Name the RCU's.
- **Preliminary encodings with high churn:** `CCV_L_W_OPCODE` = 9 (whether
  RCU narrows the opcode for the lanes), and `CCV_L_OPERANDS_PER_LANE` = 3.

**Deferred performance items naming RCU** (`docs/perf-register.md`; AR
owns the register, so RA's numbers are welcome there):
- PF-12, more bypass paths;
- PF-18, PF-37, merging masked lanes without the copy op;
- PF-26, co-issuing disjoint-mask ops;
- PF-30, nibble sub-sections;
- PF-31, a warp-uniform register file and scalar datapath;
- PF-32, branch resolution from a lane compare;
- PF-34, PF-35, atomics combining and warp reduction in RCU;
- PF-40, packing parked rows;
- PF-43, a per-lane base field;
- PF-45, self-timed completion.

None needs action now. Read them before deciding the register file's
organisation, since several move ports.

**The stub's controls.** Each claim in the gate has a negative control that
must fail. The RCU-relevant `--break` controls in `sim/skel/kernel.cpp`
include:

`ignore-mask`, `movi-in-lane`, `lead-corrupt`, `slot-field-aux`, `done-row`,
`attr-coll-as-rcu`, `no-rcu-bypass`, `wrong-merge`, `copy-from-new`,
`corrupt-echo`, `drop-writeback`, `mig-row-order`, `guard-at-restore`,
`arch-pred-srcs`, `conflate-pred`, `pdata-guard`.

A real RCU must keep every one of these failing. Never weaken one.

## 7. A plan skeleton for RA to fill

AR's proposed order, not a decision. Each phase ends in something measurable.
Change the order if your questions show a better one, and say why in a row.

- **Phase 0, reconcile (days).** Fix section 5 in the RCU spec against the
  schema. Raise every row section 8 implies. Put this file's open list into
  your own tab as `RA-n` opens, each with an owner in Needs.
- **Phase 1, size the register file first.** This is the measurement that can
  move top-level parameters, so it comes before the microarchitecture.
  - Define a register-file slice small enough for the gate's units:
    - one section bank, at reduced rows;
    - its read muxes and write ports at the real port count;
    - the guard read path.
  - Get its flops, NGD and clock-gate DCGE, and an area per bit, all from the
    flow the gate already runs (`tools/check-cg.py`, `tools/check-ngd.py`,
    the Yosys shim).
  - Extrapolate to 192 rows × 4 banks.
  - **Exit:** a row giving the full array's flops, its deepest read path
    against 25 NGD, the write-enable cones against CG-5, and whether 192 rows
    hold. If the numbers say the PRF cannot be a flop array, bring it to AR
    and DA immediately. Q-51 made "flop array" a decision with a stated
    reopening cost.
- **Phase 2, microarchitecture.** For each item, give the pipeline from
  arrival cycle A to the done at A + `CCV_LAT_RCU` - 1, the internal stages,
  and an NGD budget per port:
  - operand read and immediate substitution;
  - the predicate file and its read-modify-write merge;
  - branch resolution and the lead;
  - the collective crossbar and its latency;
  - the address path to MIU (Q-18);
  - the write ports and the arbiter;
  - migration both ways, and preemption;
  - the widening clear.

  The deliverable is a module partition (sub-blocks, inner helpers, units)
  that the gate can time level by level.
- **Phase 3, implementation plan.** Model first or RTL first? OOE did a C++
  model (4b), then RTL (4c), with `docs/ooe-rtl-plan.md` as the plan.
  Settle with DA who implements (section 8). Then plan:
  - the model behind the swap boundary (`sim/skel/blocks.list`);
  - the RTL's units for check-cg and check-ngd;
  - the RCU-internal checkers (Q-53).
- **Phase 4, verification and closure:**
  - every stub control, carried to the model and the RTL;
  - SV-hosted equivalence;
  - kernel coverage bins for the RCU's paths;
  - the performance items in section 6 that the measurements make worth
    reopening.

**Compute is the constraint that slowed OOE. Design for the gate from day
one:**
- Never put the whole 197k-flop array in a unit. Units measure sub-modules at
  small parameters (see `test/ooe/cg-units.json` and `ngd-units.json`), and
  the assembled block is checked from its `.ngd.json` budgets, level by level.
- A working-branch push takes the scoped gate (`tools/verify.sh --changed
  <base>`, SCOPED PASS; OI-95). The persistent synthesis cache is shared.
  Only the daily sweep's merge runs the full clean gate.
- Long experiments can go to RH, DA's run helper (roster). Ask DA first. RH
  has no register tab.
- Use `run-tabulate` for sweeps and `gate-triage` for a red gate, so their
  logs stay out of your context.

## 8. The questions AR expects, and where each goes

RA should come back with many questions. Raise each as a row in your tab,
with its answerer in Needs, and notify them (the register skill, section 2).
AR expects at least these:

- **To DA:**
  - Who implements the RCU, an RI session or RA itself, and when?
  - What priority does it have against OOE's remaining work on compute (RH,
    `CCV_JOBS`)?
  - What area and power targets apply, if any? No top-level area budget
    exists yet.
- **To AR:**
  - Q-18: where address generation lives.
  - Whether the crossbar becomes its own block (a partitioning change).
  - The register file's area and flops against any top-level budget.
  - Whether `CCV_P_PHYS_REGS` = 192 still holds once Phase 1 measures it. It
    follows from Q-35 and OOE's rename headroom, so OA is in the loop too.
  - Floorplan adjacency to LANE ×32, MIU and PCA.
- **To OA/OI:**
  - The A-cycle promises (section 6, items 1-4).
  - Whether OOE can tolerate a later done for a ret, or for the collective
    class.
  - The migration write's place in OOE's write schedule.
  - What OOE's model assumes about RCU timing that the stub's placeholder
    timing hides.
  - The repricing of rets at lag 1 (OA rev 293).
- **To TI:**
  - The RCU's units in `test/**/cg-units.json` and `ngd-units.json`.
  - A home for RCU RTL and model files.
  - `blocks.list`, and which stub controls move with the model.
  - Every schema or parameter change the spec reconciliation exposes.
- **To IS:**
  - The exact list of warp-uniform and horizontal ops in ISA v1.9, with
    their semantics at narrow widths: `chwidth` and the widening clear.
  - Whether `vote`, `ballot` and `unballot` exist as encoded ops.

## 9. Getting the session set up (first hour)

1. **Roster.** Write your session id into `docs/register/roster.json`, entry
   `RA`, in a commit of its own. AR has added the entry with `session: null`
   and your tab's node id. That entry is how the handoff hook finds your
   prefix and how other agents notify you.
2. **Session home.** Run the `session-home` skill
   (`.claude/skills/session-home/`) so `.claude/settings.json` (the 400k
   compaction window, the handoff hook) and `.claude/agents/` reach a session
   that runs from `/home/user`. It writes into the home directory, so ask
   Daniel to approve first, as every other agent did. Then check it with
   `tools/setup-session-home.py --check`.
3. **Handoff.** Create `.claude/handoff/RA.md` with your working rules,
   branch, bookmarks and open work, a few kB, and keep it current at every
   task's end (CLAUDE.md, "Context and handoff").
4. **Register.**
   - Read the Conventions tab.
   - Read the register skill, `.claude/skills/register/SKILL.md`.
   - Search every tab for `RA` in Needs.
   - Create your daily sweep task as the skill's section 5 says. The skill
     has no minute for RA yet: take minute 27 (the series runs AR 3, OA 7,
     TI 11, OI 15, CP 19, IS 23), and raise a row asking OA, the skill's
     owner, to add it.
   - Read rows through the `register-reader` subagent. Ring a notice only
     for a row that asks something of its receiver (TI-49).
5. **Your branch.** Work on the branch your session was given. Never push to
   another agent's. Merges take merge commits, never a rebase or force-push.
   A push needs a green gate: the scoped gate on a working-branch push.
6. **CLAUDE.md** in this repository is written for TI ("This session is
   TI"). Read it for the rules and the gate. Your role is the one in section
   1 of this file.

## 10. The specs doc's ownership line

The RCU tab of the per-block specs now opens with an owner line naming RA.
From your first edit on, AR stops editing it. AR will send any cross-block
text it needs there as a row in AR's tab, with RA in Needs.
