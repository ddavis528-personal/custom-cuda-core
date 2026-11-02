# RCU implementation: handoff to the RCU implementation session (RI)

RA (the RCU block architect) wrote this on 2026-11-02, at Daniel's request
(DA tab, that date), for the session that builds the RCU. It is RI's first
read and its standing reference for who owns what. It points at the spec
rather than restating it, so it cannot drift from it. Where this file and the
spec disagree, the spec wins. Raise the disagreement as a row.

**Status (2026-11-02).** The RCU architecture is complete to RTL depth, and
Daniel has accepted it as a first pass. That means every stage, register,
enable, mux select, channel field's cycle and FSM is specified, along with
the module partition, the port NGD budgets, the checks and the exit criteria.
Nothing of the RCU's model or RTL exists yet: the RCU in both hosts is the
C++ stub (`class Rcu`, `sim/skel/kernel.cpp`) and its generated SV stub. The
schema and parameter changes the spec needs are agreed but not all applied
(section 7).

**Model first (Daniel, 2026-11-02; DA tab).** RCU gets a cycle-accurate C++
model, in place ahead of the RTL, so that the RTL is verified against it. RI
owns the model, and keeps it in lock-step with the RTL for as long as both
exist. Leverage what already exists: the stub has none of the spec's timing,
but its port handling and semantics are a head start (section 5).

Paths under sim/rcu/, rtl/rcu/ and test/rcu/ are written plain, not as code,
until they exist (the docs check holds every code path to the tree).

---

## 1. Who RI is, and what it owns

- **RI = RCU implementation.** It mints `RI-n` in its own register tab and
  writes nowhere else in the register.
  - Register: https://claude.ai/artifact/JApHYjaUESeq8tsGMGXMU5, tab RI (node
    `8e4547bc-c469`). The tab and its Conventions row were added 2026-11-02.
- **RI owns:**
  - the RCU's cycle-accurate C++ model, sim/rcu/, behind the swap boundary,
    and its lock-step with the RTL: a change to either that changes what the
    other must do lands in both, in one commit;
  - the RCU's RTL, rtl/rcu/;
  - its units, benches and fixtures, test/rcu/;
  - the RCU-internal assertions and the Q-53 checkers the spec assigns to
    RCU's RTL (and their model-side equivalents);
  - every measurement in the spec's exit table, M0 (the model) to M7, and the report of
    each against its criterion;
  - its `<module>.ngd.json` files, whose numbers are RA's (section 4).
- **RI does not own:**
  - **The architecture.** RA owns it. A change to a stage, a register, a port
    budget, the partition or an exit criterion is an `RI-n` row with RA in
    Needs. RI builds what the spec says, even when it looks improvable, until
    RA answers.
  - **The schema, parameters, generators, gate, `rtl/top/` and every stub,**
    the RCU stub included (it stays selectable for A/B runs).
    TI owns these. A change is an `RI-n` row with TI in Needs, never a direct
    edit (CLAUDE.md, "Sessions working side by side").
  - **OOE's side of a contract.** That is OA (architecture) and OI
    (implementation). Cross-block questions go to AR. ISA questions go to IS.
  - **Decisions that are Daniel's.** These are cost, scope, waivers and the
    collective fold (section 7). RI states the measured figures. Daniel
    decides, and his answer is recorded in the DA tab.
- **CLAUDE.md** in this repo is written for TI ("This session is TI"). Read
  it for the gate and the coding rules, which bind RI exactly as they bind
  OI. Your role is this section's.

## 2. Sources of truth, in order of authority

| What | Where |
|---|---|
| Ports, fields, widths, channel contracts | [`schema/interfaces.json`](../schema/interfaces.json); per channel in [`payload-spec.md`](payload-spec.md) |
| Every size and latency | [`params/ccv_params.json`](../params/ccv_params.json), generated into `rtl/generated/ccv_params_pkg.sv`. Never hard-code a number that has a parameter |
| **The RCU spec**: everything inside the block | *CCV RCU Architecture* (Claude doc): https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB. Pinned copies, which grep can reach: [`design-snapshots/rcu-arch-*.md`](design-snapshots/), ten files, one per tab, refreshed together. The live doc wins |
| Why each RCU decision is what it is | the RA tab of the register, RA-1 onward, with each answerer's response in their own tab. The spec's Overview tab lists every decision with its row |
| OOE's side: issue, done, wake, the lead slice, kill | *OOE microarchitecture, Stage 4*: https://claude.ai/artifact/7tpEyGaCvfdvYYWUQJvJSU ([`design-snapshots/ooe-microarchitecture.md`](design-snapshots/ooe-microarchitecture.md)) |
| Neighbours' specs (LANE, MIU, PCA, RAU) | *CCV per-block architecture specs*: https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35. The RCU tab there is RA's summary and points at the RCU spec |
| Coding rules: NGD, clock gating, reset, stage tags, lint | [`rtl-coding-style.md`](rtl-coding-style.md) and CLAUDE.md |
| What is open repo-wide | [`open-items.md`](open-items.md). Q-53 holds the checkers RCU's RTL owes |
| How OOE's RTL was planned and verified, the nearest precedent | [`ooe-rtl-plan.md`](ooe-rtl-plan.md), and `rtl/ooe/` and `test/ooe/` as worked examples of units, benches and `.ngd.json` files |

**Stale, do not build from it:** [`rcu-arch.md`](rcu-arch.md) is AR's handoff
to RA. It still carries the old port counts and placeholder latencies until
AR updates it (RA-35). Read its sections 1 and 7 only for history.

## 3. Reading order (the first day)

1. **Overview tab:** status, the tab guide, every decision and its row, and
   what is still open.
2. **Conventions tab:** the cycle names (A−1, A, A+1, ...), signal and
   register naming, the stall-safe sender, and how a field's cycle is
   written.
3. **Partition and checks tab, all of it.** This is your work plan:
   - the modules and their flops;
   - the port NGD budgets;
   - the clock enables and the DCGE risks;
   - the issue lead slice;
   - the assertions and Q-53 checkers;
   - the stub controls that must keep failing;
   - the exit table M1 to M7 (M0, the model, is in section 5).
4. **Pipeline tab**, then each structure's tab as you build it:
   - Register file (with "Select fanout");
   - Predicate file (the split guard read);
   - R unit (the crossbar helper);
   - Lane and memory;
   - Migration;
   - Done, kill and reset.
5. **The RCU stub, `class Rcu` in `sim/skel/kernel.cpp`.** This is the
   behaviour the kernels pass with today, and the model's head start
   (section 5). Its timing is not the spec's, and two controls change
   meaning with the spec (Partition tab).
6. **The OOE model, as the precedent:** [`ooe-4b.md`](ooe-4b.md) (how a
   block model sits behind the swap boundary, its hooks and its tests) and
   [`ooe-model.md`](ooe-model.md).

## 4. Where the code goes, and the rules that shape it

- **The model:** sim/rcu/, in the OOE pattern (`sim/ooe/`, `sim/skel/ooe.cpp`):
  - a core class per spec module, holding the spec's named registers as its
    state and advancing them once a cycle, so an RTL module and its model
    class can be compared at the module's ports and registers;
  - a block class at RCU's ports (`sim/skel/stub.h`'s `Stub` interface),
    behind a makeRcu hook that TI adds, with `CCV_RCU_IMPL=stub` keeping
    the stub selectable in both hosts (RA-38);
  - unit tests beside it, run by a gate job TI adds (RA-38 (d));
  - listed in `sim/skel/blocks.list`, so both hosts build it.
- **RTL modules:** `rtl/rcu/ccv_rcu*.sv`, named and partitioned exactly as the
  Partition tab's module table:
  - `ccv_rcu`, the top: `ccv_common_clk`, children and wires only;
  - `ccv_rcu_bank` ×4, `ccv_rcu_pred`, `ccv_rcu_r` with the `ccv_rcu_xbar`
    helper;
  - `ccv_rcu_lanes`, `ccv_rcu_mem`, `ccv_rcu_mig`, `ccv_rcu_kill`.

  The top keeps the generated stub's module name and port list
  (`rtl/top/stubs/ccv_rcu.sv`; `tools/gen-top.py`). That is what makes the
  swap a file-list change.
- **Sizes are module parameters**, each defaulting to its `ccv_params_pkg`
  value, for example `parameter int ROWS = ccv_params_pkg::CCV_P_PHYS_REGS`.
  A package localparam cannot be overridden, so a reduced unit would
  otherwise be impossible (RA-32 (2)).
- **Units:**
  - test/rcu/cg-units.json for every sequential module;
  - test/rcu/ngd-units.json for any module with no flops.

  Every module gets a reduced unit for loops (a bank at `ROWS` = 32,
  `ccv_rcu_lanes` at `COPIES` = 4) and its full-size unit for its exit. A
  full-size unit that peaks over 2 GB goes on tools/heavy-units.json
  (TI's; on TI's scratch branch, not yet merged, 2026-11-02; ask TI). Copy the shape of `test/ooe/cg-units.json`.
- **Port budgets, `rtl/rcu/<module>.ngd.json`:**
  - The numbers are RA's, from the Partition tab's "Port NGD budgets" table.
    RI transcribes them with `"by": "RA"` and a `why` citing the tab and its
    revision, as OI did for OA's budgets (`rtl/ooe/ooe_rename.ngd.json`).
  - A port that needs a budget the table lacks, or a different number, is an
    `RI-n` row with RA in Needs. Never pick a number yourself.
- **The rules, briefly** (CLAUDE.md and `rtl-coding-style.md` are the text):
  - **Logic depth:** 25 NGD flop to flop; 12 per port side unless budgeted.
    Nothing straight through a module, and no logic in a parent between
    children.
  - **Output registers:** a register that drives an output and anything else
    is split into `(* keep *)` copies. The spec lists RCU's: the lead flops,
    the done valid, the lane-op and address valids, and `dm_v_q`.
  - **Clock gating:**
    - every register sits behind `if (<name>_en)`;
    - each enable comes from the module's own flops (CG-5);
    - `rst_n` is flopped once per sequential module (RST-1);
    - a gate is 8 flops or more, with its enable cone ≤ 8 NGD and DCGE
      ≥ 75%;
    - the allowance is 2% or fewer than 8 flops per module, and 2% per
      block.
  - **Stage tags:** every net of a sequential module carries one (CCV-L29).
  - **Yosys:** every flow uses `tools/shim/yosys`.
  - **Fanout:** check-ngd reports a fanout term, ceil(log4(fanout/4))
    inverter stages at 0.68 NGD each (RA-33, Daniel's option (a)). It is
    report-only today, enforced later. M1 counts it either way.
- **Clock-gating stimulus (RA-34):** check-cg's idle, medium and high
  scenarios come from checked replays of ccv-skel's per-block port-trace
  dump (TI is building it):
  - high = coremark128 and vadd;
  - medium = the same traces with two idle cycles after each;
  - idle = reset and no issue.

  The traces come from ccv-skel runs with RI's model in place, so they carry
  the spec's timing (from the stub, DCGE counts only after its RA-19 merge
  fix). A reduced unit replays traces from a skeleton run at the same sizes.

## 5. The model, and how the RTL is verified against it

**Daniel's decision (2026-11-02, DA tab):** a cycle-accurate C++ model,
in place ahead of the RTL, so the RTL can be verified against it. RI owns
the model and keeps it in lock-step with the RTL. Nothing at the spec's
timing exists today, so RI writes it, starting from what the stub already
gets right.

**What "cycle-accurate" means here.**
- Every RCU output appears on the cycle the spec gives it: valids and
  payloads, leads, dones on their fixed slots, wakes, credits, kill ack.
- Every input is taken on the cycle the spec takes it.
- The model's state is the spec's registers: names, widths, and the cycle
  each loads. An RTL module and its model class therefore agree at their
  ports and their registers, not only at the block's ports.

**The stub as a head start.** Take its port handling, its operand and merge
semantics (the predicate read-modify-write, the zero registers, the
garbage-at-reset PRF), its migration pairing and its controls' hooks. Leave
its queue-based timing, which is not the spec's (the lane hold until every
lane has a credit, the lowest-free done pool). The stub itself stays TI's
and selectable for A/B runs.

**The swap boundary binds the model as it bound OOE's.** Ports only, and
the oracle for checks, never decisions (CLAUDE.md, "The swap boundary").
`tools/check-sv-hosted.sh` proves it.

**Verification, in order:**
1. **The model** (M0):
   - every kernel on both hosts against ccv-sim's oracle;
   - every `--break` control in the Partition tab's list failing;
   - the model's unit tests;
   - the in-module assertions, model-side.

   Report the kernel cycle counts against the stub's. They are the first
   measure of the spec's timing.
2. **Module lock-step** (test/rcu/): each RTL module against its model class
   under Verilator, driven by the same stimulus, comparing every output and
   every named register every cycle. Stimulus is directed tests from the
   spec's per-cycle tables, then port traces cut at the module's boundary.
3. **Block lock-step:** `ccv_rcu` against the model's block, driven by
   ccv-skel port traces (RA-34) recorded with the model in place, comparing
   every output every cycle. This is the gate job RA-38 (e) asks for, the
   RCU's equivalent of ooe_rtl.
4. **In the SV top:**
   - `tools/check-sv-hosted.sh` with the RTL in place of `ccv_rcu`'s DPI shim;
   - every kernel against ccv-sim's oracle;
   - every control still failing (M6);
   - no divergence from the C++ host running the model (M7).

   The selector that swaps the RTL in is TI's to add (RA-37 (c)).

**Lock-step is permanent.** A change to the RTL that changes behaviour
changes the model in the same commit, and the reverse. A fix found in
either is made in both. The lock-step jobs run at every gate that touches
sim/rcu/ or rtl/rcu/.

Never weaken a control to get green. A control that stops failing is a
finding, and gets a row.

## 6. Build order and exit criteria

Each phase ends in a row in RI's tab:
- the figures against the Partition tab's criteria;
- the commit that produced them;
- RA in Needs (and DA where a decision is his).

Use `run-tabulate` for sweeps and `gate-triage` for a red gate, so logs stay
out of your context.

| Phase | Build | Measure | Exit, and who reads the row |
|---|---|---|---|
| 0, setup | section 8 | — | roster, session home, handoff, sweep task in place |
| 1, the model | sim/rcu/: the spec's modules as classes, the block at RCU's ports | M0 | every kernel and control passes on both hosts with the model as the default (TI flips makeRcu's default, RA-38 (a)); kernel cycles against the stub's reported. **RA reads it** and folds anything the spec failed to say into the spec |
| 2, the register file and the R pipe | `ccv_rcu_bank` (units at 32 rows, then 192), `ccv_rcu_r` + `ccv_rcu_xbar` | M3; M1 and M2 for both modules; module lock-step | bank read AND-OR ≤ 7 NGD at 192 rows; flops within 1% of 49,550; every write D-cone and enable within budget; the register-index shfl (about 22) and ret (about 23) paths ≤ 25 with the read. **RA and DA:** these are the figures for the collective fold from 5 to 3 (RA-8, RA-29 (c)) and the first real flop count. If a bank cannot be a flop array at 25 NGD, stop and raise it at once (Q-51's reopening cost) |
| 3, predicates and kill | `ccv_rcu_pred` (with and without the guard lead), `ccv_rcu_kill` | M1, M2; M4 | guard path in A ≤ 16 NGD with the lead (≤ 23 without); kill drain bound M4 |
| 4, lanes, memory, migration | `ccv_rcu_lanes` (4 copies, then 32), `ccv_rcu_mem`, `ccv_rcu_mig` | M1, M2 (the lead-slice field groups), M5 | DCGE per field group; the literal-imm group under 75% goes to RA (the remedy is a DEC bit through OA, never a waiver first); migration 17 rows within 68 cycles |
| 5, the block | `ccv_rcu` assembled; Q-53 checkers (arrival-cycle, A-35's two isolation assertions, the A-45 pairing checker) | M1 block convergence from the `.ngd.json` files, level by level, then timed whole; M2 block 2%; M6; M7 | every row of the exit table met, or a waiver Daniel signs. Then RA reconciles the spec with what was built |

From phase 2, every RTL module passes its module lock-step against the model
before its measurements count. Phases 3 and 4 can overlap phase 2 once the
bank's unit runs. Order them by what section 7 has unblocked.

## 7. What RI waits on

| Item | Owner | Row | Blocks | Meanwhile |
|---|---|---|---|---|
| Schema and parameter changes: (a)-(g), 4 write ports, fixed done slots, `dispatch_fault` deleted, the kill-drain parameter | TI | RA-16, RA-29 (a), (b) | ports of `kill`, `r`, `lanes`; phase 4's port list | build to the spec's port names; regen when TI lands them |
| The issue lead slice (`lead_fields`), `CCV_LAT_RCU_ADDR_BASE` = 1, `CCV_LAT_L1_WAKE` 16 → 12 | TI (schema), OI (OOE sends it) | RA-31, RA-32 | `pred`'s split guard read; `lanes` and `mem` field-group enables | build with the lead inputs. Without the slice, every group falls back to the issue valid (Partition tab, "Contingencies") |
| The model's hook (makeRcu, `CCV_RCU_IMPL=stub`), its blocks.list entry, its unit-test job, the RTL lock-step job | TI | RA-38 | the model in kernel runs; the lock-step gate jobs | develop the model under its unit tests; TI's hook lands with RI's first model commit |
| The ccv-skel port-trace dump | TI | RA-34 | M2 with real stimulus; block lock-step | reset/idle and directed stimulus only |
| Fanout term enforced in check-ngd | TI | RA-33 | nothing: report-only numbers count for M1 | record the reported stages beside each path |
| Repo support: the gate-scope map for rtl/rcu/ and test/rcu/, a gate job for RCU's benches, the SV-hosted RTL selector, the CLAUDE.md pointer to this file, and the sweep minutes RA 27 and RI 31 in the register skill | TI, OA | RA-37 | an unmapped path runs every gate section on each push; SV-hosted runs | push less often until the map lands |
| The collective fold, 5 → 3 | DA | RA-29 (c) | nothing: the spec runs collectives in the R pipe either way; only the parameter and OOE's class change | phase 2's figures are the input |

## 8. Getting the session set up (first hour)

1. **Roster.** Write your session id into `docs/register/roster.json`,
   entry `RI` (RA added it with `session: null` and your tab's node id). Do
   it in a commit of its own. That entry is how the handoff hook finds your
   prefix and how other agents notify you.
2. **Session home.** Run the `session-home` skill so `.claude/settings.json`
   (the 400k compaction window, the handoff hook) and `.claude/agents/`
   reach a session that runs from `/home/user`. It writes into the home
   directory, so ask Daniel first. Check it with
   `tools/setup-session-home.py --check`.
3. **Handoff.** Create `.claude/handoff/RI.md`: your working rules, branch,
   bookmarks, runs in flight, and open work, most urgent first, in a few kB.
   Keep it current at every task's end.
4. **Register:**
   - Read the Conventions tab and `.claude/skills/register/SKILL.md`.
   - Search every tab for `RI` in Needs.
   - Create your daily sweep task as the skill's section 5 says, at minute
     31 (the series runs AR 3, OA 7, TI 11, OI 15, CP 19, IS 23, RA 27); RA
     asked OA to add it (RA-37).
   - Read rows through the `register-reader` subagent. Ring a notice only
     for a row that asks something of its receiver.
5. **Toolchain.** In a fresh container, run `./tools/setup-toolchain.sh`.
   Then read CLAUDE.md, "The gate".
6. **Branch.** Work on the branch your session was given. Never push to
   another agent's. Merges take merge commits, never a rebase or
   force-push. Push with `tools/gate-push.sh` (the scoped gate), with
   `CCV_PUSH_BRANCHES` set to your branch. Name each commit you want merged
   in your tab: the top-level branch takes it by merge (as OI-2 set up for
   OOE), and the daily sweep's merge runs the full gate.
7. **No model identifiers** in commits, code comments or anything pushed.

## 9. Working beside the others

- **RA** answers every architecture question, in RA's responses table, and
  folds each answer into the spec and its snapshot. Expect RA to review each
  phase's exit row against the spec. Where the RTL needs something the spec
  never said, RA adds it to the spec, so the next reader finds it there.
- **TI** applies schema, parameter, stub, control and gate changes, and
  merges your named commits. TI keeps the stub, and adds the hook that
  selects your model (RA-38).
- **OI and OA:** OOE sends the lead slice and owns the RS-side contingency.
  A question about what OOE sends goes to OA, and one about when OI's model
  sends it goes to OI.
- **RH**, Daniel's run helper, can take long runs. Ask Daniel first. RH has
  no register tab.
- **Daniel** starts this session and reads the DA-tagged rows. Waivers,
  cost trades and the collective fold are his.
