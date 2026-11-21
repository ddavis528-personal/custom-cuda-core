# MIU implementation: handoff to the MIU implementation session (MI)

MA (the MIU and DCU block architect) wrote this on 2026-11-19, at Daniel's
request (DA tab, re: MA-23, "go with B, keeping way prediction as a
parameterizable feature"), for the session that builds the MIU. It is MI's
first read and its standing reference for who owns what. It points at the
spec rather than restating it, so it cannot drift from it. Where this file and
the spec disagree, the spec wins; raise the disagreement as a row. Its twin
for the DCU is [`dcu-impl.md`](dcu-impl.md); read section 5 there too, since
the two models meet at the MIU–DCU channels.

**Status (2026-11-19).** MA's Phase 1 architecture is decided (MIU tab of the
per-block specs, rev 144; DCU tab rev 50): the L1-hit budget, the pipes and
lookup slots, entries, credits and req_ids, ordering and the drain,
translation, the miss path, the kill races, and the events the model must
cover. **Phase 2 is not done:** there is no module partition, no per-cycle
stage table and no port NGD budget yet. That is MA's next work
([`miu-arch.md`](miu-arch.md) section 7). So MI starts with the model, which
needs only Phase 1; the RTL phases wait on Phase 2 (section 6).

**Everything still open is a parameter (Daniel, 2026-11-19; DA tab).** No
open item blocks the model. Each has a default the model builds with; a
measurement may move the default later, never the structure (section 7).

**Model first (Daniel, 2026-11-10; DA tab):** "both MIU and DCU
implementation should start with the C++ model. Emphasis should be put on
making sure that all important events are covered in the model. Of course,
the model may evolve as the RTL uncovers timing limitations."

Paths under sim/miu/, rtl/miu/ and test/miu/ are written plain, not as code,
until they exist (the docs check holds every code path to the tree).

---

## 1. Who MI is, and what it owns

- **MI = MIU implementation.** It mints `MI-n` in its own register tab and
  writes nowhere else in the register.
  - Register: https://claude.ai/artifact/JApHYjaUESeq8tsGMGXMU5, tab MI (node
    `c1311541-4219`). The tab, and its Conventions row, were added 2026-11-19
    by MA.
- **MI owns:**
  - the MIU's cycle-accurate C++ model, sim/miu/, behind the swap boundary,
    and its lock-step with the RTL: a change to either that changes what the
    other must do lands in both, in one commit;
  - the MIU's RTL, rtl/miu/, once Phase 2 gives its partition;
  - its units, benches and fixtures, test/miu/;
  - the MIU-internal assertions and the Q-53 checkers the spec assigns to
    the MIU (the model flags the same never-happens conditions);
  - every coverage bin and negative control in section 5, and the
    statistics the spec asks the model to report;
  - its `<module>.ngd.json` files, whose numbers are MA's (section 4).
- **MI does not own:**
  - **The architecture.** MA owns it. A change to a contract, a structure,
    a port budget, the partition or an exit criterion is an `MI-n` row with
    MA in Needs. MI builds what the spec says, even when it looks
    improvable, until MA answers. Where the model finds that the spec is
    silent, ask; MA folds the answer into the spec.
  - **The schema, parameters, generators, gate, `rtl/top/` and every stub,**
    the MIU stub included (it stays selectable for A/B runs). TI owns these.
    A change is an `MI-n` row with TI in Needs, never a direct edit
    (CLAUDE.md, "Sessions working side by side").
  - **The DCU.** DI implements it, from [`dcu-impl.md`](dcu-impl.md). The
    MIU–DCU contract is MA's; a question about what DCU sends goes to MA,
    one about when DI's model sends it goes to DI.
  - **The neighbours' sides of a contract.** OOE is OA (architecture) and
    OI (implementation); RCU is RA and RI; MLC, SPM, the TLB walker's memory
    side and every cross-block question go to AR; ISA questions to IS.
  - **Decisions that are Daniel's:** cost, scope, waivers. MI states the
    measured figures; Daniel decides, and his answer goes in the DA tab.
- **CLAUDE.md** in this repo is written for TI ("This session is TI"). Read
  it for the gate and the coding rules, which bind MI exactly as they bind
  OI and RI. Your role is this section's.

## 2. Sources of truth, in order of authority

| What | Where |
|---|---|
| Ports, fields, widths, channel contracts | [`schema/interfaces.json`](../schema/interfaces.json); per channel in [`payload-spec.md`](payload-spec.md) |
| Every size and latency | [`params/ccv_params.json`](../params/ccv_params.json), generated into `sim/generated/ccv_params.h` and `rtl/generated/ccv_params_pkg.sv`. Never hard-code a number that has a parameter |
| **The MIU spec**: everything inside the block | *CCV per-block architecture specs*, MIU tab: https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35. Pinned copy, which grep can reach: [`design-snapshots/miu-spec.md`](design-snapshots/miu-spec.md). The live doc wins |
| The DCU spec, MIU's partner on every L1 access | the same doc, DCU tab ([`design-snapshots/dcu-spec.md`](design-snapshots/dcu-spec.md)) |
| Why each decision is what it is | the MA tab of the register, MA-1 onward, with each answerer's response in their own tab; Daniel's rulings in the DA tab |
| How MA got here, and what was open when MA started | [`miu-arch.md`](miu-arch.md) (AR's handoff to MA). Its sections 3 to 6 are history now; the spec supersedes them |
| OOE's side: the memop issue, credits, discard, replay, kill, wake | *OOE microarchitecture, Stage 4*: https://claude.ai/artifact/7tpEyGaCvfdvYYWUQJvJSU ([`design-snapshots/ooe-microarchitecture.md`](design-snapshots/ooe-microarchitecture.md)) |
| RCU's side: the address channel, the write-through, the MIU write port | *CCV RCU Architecture* ([`design-snapshots/rcu-arch-lane-memory.md`](design-snapshots/rcu-arch-lane-memory.md)) |
| Coding rules: NGD, clock gating, reset, stage tags, lint | [`rtl-coding-style.md`](rtl-coding-style.md) and CLAUDE.md |
| What is open repo-wide | [`open-items.md`](open-items.md). Q-53 holds the checkers the RTL owes |
| The nearest precedents | [`rcu-impl.md`](rcu-impl.md) (RI's handoff, the shape of this one) and `sim/rcu/`; [`ooe-4b.md`](ooe-4b.md) and `sim/ooe/` for how a block model sits behind the swap boundary |

## 3. Reading order (the first day)

1. **This file**, then [`dcu-impl.md`](dcu-impl.md) section 5.
2. **The MIU tab, "MA's Phase 1 architecture"**, all of it. This is your work
   plan for the model:
   - the L1-hit budget (MA-1, MA-2) and its derived latencies;
   - pipes, lane groups and lookup slots (MA-4, MA-7);
   - entries, credits and req_ids (MA-5, MA-6), and the DCU bank credits
     (MA-25);
   - ordering, the drain, translation and the miss path (MA-8, MA-10 to
     MA-12);
   - the kill obligations (TI-485, OA 436);
   - **"Events the model must cover"**: section 5's coverage table.
3. **The MIU tab's "Scope and ports" and "Internals, mechanisms, risks"**:
   the ports and the mechanisms the Phase 1 section builds on.
4. **The DCU tab**: what DCU promises MIU (the hit timing, the refill notice
   and hint, holding a request, the bank queue and its credits, ECC).
5. **The MIU stub, `class Miu` in `sim/skel/kernel.cpp`.** This is the
   behaviour every kernel passes with today, and the model's head start
   (section 5). Its timing is not the spec's.
6. **MA's Phase 1 resource model, `sim/dcu/dcu_p1.cpp`.** It is DCU-side,
   but it carries the MIU side of the bank credits (`CCV_P1_CREDIT`: MIU's
   per-bank counts, the in-order hold, the release after a credit returns).
   Read how it holds and releases; it is not code to copy into the MIU model,
   since it reaches across the boundary by design (it was a sweep tool).
7. **The precedents:** [`rcu-impl.md`](rcu-impl.md) sections 4 and 5, and
   [`ooe-4b.md`](ooe-4b.md).

## 4. Where the code goes, and the rules that shape it

- **The model:** sim/miu/, in the RCU pattern (`sim/rcu/`):
  - its inside is MI's to organise. It is not a clone of the RTL's modules
    and registers (Daniel, 2026-11-02, for the RCU; the same holds here);
  - a block class at MIU's ports (`sim/skel/stub.h`'s `Stub` interface),
    behind a `makeMiu` hook in `sim/skel/kernel.cpp` that TI adds, beside
    `makeDcu`, with `CCV_MIU_IMPL=stub` keeping the stub selectable in both
    hosts. The stub stays the default until the model passes M0 (section 6);
  - unit tests beside it, run by a `check-miu-unit` job TI wires;
  - listed in `sim/skel/blocks.list`, so both hosts build it.
    `tools/gate-scope.py` already maps sim/miu/ to the sections that build
    it.
- **RTL modules: Phase 2 slice 1, the L1-hit path, has landed** (MIU tab rev
  148, section "MA's Phase 2"; MI-15). rtl/miu/, named and partitioned
  exactly as the tab's module table:
  - `ccv_miu`, the top: `ccv_common_clk`, children and wires only, keeping
    the generated stub's name and ports (`rtl/top/stubs/ccv_miu.sv`);
  - A1: `miu_cap` ×4, `miu_pair`, `miu_agu8` ×16 (slot × lane octet),
    `miu_lead`, `miu_cred`;
  - A2: `miu_tlb`, `miu_grp` ×4 (combinational), `miu_a2`, `miu_ids`,
    `miu_mq`;
  - R1 and R2: `miu_hitq`, `miu_rsp`, `miu_rcap` ×4, `miu_ext` ×16,
    `miu_ecc` ×4, `miu_out`.

  AR agreed the two interface parts (AR 400, AR 401; MA rev 143), and TI
  applies them: `miu_a2`'s drop bit on `ccv_miu_dcu_req`, with MIU refunding
  a dropped lookup's credit (MA-27, DI-12), and `miu_ecc` with the check
  bits on `ccv_dcu_miu_rsp` (MA-28 (c)). The model drops what A2 loses,
  holds a load at A1 when its bank lacks `CCV_DCACHE_LOOKUPS` credits, checks
  the syndrome itself and keeps a req_id live until its completion is
  delivered (MIU tab, Phase 2). The miss and refill path, stores and the drain,
  atomics, SPM, the walker, faults, discard, replay and kill come as further
  slices, each announced by a notice, and may add modules or ports to these.
  The units follow `rcu-impl.md`'s pattern: a reduced unit for loops and a
  full-size unit for the exit, sizes as module parameters, heavy units
  listed. The rules that
  will bind it are CLAUDE.md's and [`rtl-coding-style.md`](rtl-coding-style.md):
  25 NGD flop to flop with the fanout term, 12 per port side unless budgeted,
  local clock gating (CG-5, RST-1, DCGE ≥ 75%), stage tags, the Yosys shim,
  sizes as module parameters defaulting to `ccv_params_pkg`, reduced units for
  loops, and heavy units listed in `tools/heavy-units.json`.
  - Port budgets: MA's numbers, transcribed into `rtl/miu/<module>.ngd.json`
    with `"by": "MA"` and a `why` citing the tab and its revision. A port
    that needs a budget the table lacks is an `MI-n` row with MA in Needs.
    Never pick a number yourself.
- **Design for the gate from day one** ([`miu-arch.md`](miu-arch.md)
  section 7): `ccv_rcu_miu_addr` alone is 3,111 bits a slot. Never put a
  whole slot's datapath in one unit; the assembled block is checked from its
  `.ngd.json` budgets, level by level, as a sum of parts.
- **Block boundaries:** every boundary has a flop on each side, built by the
  interface module (`ccv_common_rpt`), and each channel's payload cycle counts
  from MIU's interface flop. Build from the latency parameters, never
  literals.

## 5. The model, and how the RTL is verified against it

**What "cycle-accurate" means here** (Daniel, 2026-11-02, for the RCU, and
2026-11-10 for these blocks): cycle-accurate in how it drives its interfaces
and when the interesting events happen. It tracks and models every hazard,
stall, hold and idle period, but it does not clone the RTL's structures.

The model must get these right, cycle by cycle:
- **Its interfaces.** Every MIU output on the cycle the spec gives it, with
  its payload: the RCU write-back and its wake at `CCV_LAT_L1_HIT` from the
  address; the completion `CCV_LAT_L1_ECC` later (`CCV_LAT_L1_CMPL`); DCU
  lookups on their slots; the memop and miss-path channels to OOE, SPM, MLC
  and the walker; credits returned on the slot of the entry's arrival. Every
  input taken on its cycle, back-pressure honoured as the stall-safe sender
  does.
- **Its events**, through the existing event mechanism (`emit`,
  `sim/skel/stub.h`), each on its cycle: the coverage table below.
- **Its hazards, holds and stalls.** The model reproduces the delay, and
  flags as a failure anything the spec says never happens (a credit
  returned on the wrong slot, a lookup sent to a bank with no credit, a
  cross-warp hold).
- **Sleep and idle**: every period in which the block, or a part of it, does
  nothing. The clock-gating scenarios depend on them.

**The stub as a head start.** Take its port handling, its function (address
forms, coalescing, faults, atomics, the SPM passes, the drain) and its
controls' hooks. Leave its timing, which is not the spec's. The stub stays
TI's, and selectable for A/B runs.

**The swap boundary binds the model.** Ports only, and the oracle for checks,
never decisions (CLAUDE.md, "The swap boundary"). `tools/check-sv-hosted.sh`
proves it. MA's `dcu_p1.cpp` does not meet this bar for the MIU side (its
credit counts live inside DCU's block); the MIU model keeps its own counts
from the credit-return channel alone.

### What the model must do beyond the stub (the obligations)

Each is in the spec; this list is where to find it.

| Obligation | Spec, and the row |
|---|---|
| The L1-hit timing: data at `CCV_LAT_L1_HIT` from the address (8 with way prediction on, 9 off: derived from `CCV_DCU_WAYPRED_BITS`), the completion `CCV_LAT_L1_ECC` (1) later. A way mispredict answers no earlier than due + 2 and takes the bank-conflict loser's path, answered later as a miss would be (DI-2; AR 390, OA-442); a withheld completion (non-zero syndrome) is taken by OOE as a miss | MIU tab, L1-hit budget; DCU tab, arrays and pipeline; TI-478, MA-26 |
| **DCU bank credits (MA-25):** MIU holds per-bank credits, `CCV_DCU_BANK_QDEPTH` (16) lookup entries and `CCV_DCU_BANK_STDATA` (12) store-data entries, a hard reservation that counts every request sent to the bank. A request without its credit waits in MIU, oldest first; a held store blocks younger stores to its bank, and a held request blocks younger ones to its line. Credits return on two 8-bit per-bank vectors from DCU (entry and store data), each within `CCV_DCU_BANK_AGE` | MIU tab, "DCU bank credits"; DCU tab, the bank queue; MA-24, MA-25 |
| The kill races: MIU completes every memop of a killed warp; an atomic keeps its state and hold through the A3 that OOE still sends, completing with more = 0 and releasing; a read DCU withholds as uncorrectable completes with no data | MIU tab, kill obligations; TI-485, OA 436 (final; OA 438, AR 385) |
| ECC error injection: the model passes the `CCV_DCU_ECC_INJECT` runs TI adds (DCU flips a stored bit; MIU's own syndrome over the rsp check bits withholds the completion, MA-28 (c)) (an injected correctable error is corrected and counted; an uncorrectable one follows MA-19) | TI-484; MA-19 |
| RA's MIU conditions on the RCU write port and the write-through | RA 153 (RA tab); RCU lane and memory tab |
| The TLB and walker (MI-2 as settled: a cold TLB each kernel; Common tab rev 9, AR 392). Through M0 the default is `CCV_MIU_TLB=warm`: every page is held and FET's ITLB answers at once, as in the stub. `CCV_MIU_TLB=cold` is the architected behaviour. Its own check-kernel scenarios (TI's) run in every gate with controls: a walk on the shared walker against the ITLB, the three dependent DCU lookups on idle slots, lanes across two pages, and F-ADDR before the walk. A walk's DCU reads count toward `CCV_DCU_UE_INJECT`. The M0 report states the cold cost (110 to 160 cycles a kernel, MI-6) | MIU tab, TLB and walker; MI-6, MA 126 |
| The statistics the spec lists under the events table, per kernel | MIU tab, "Statistics the models report" (AR rev 344) |

### Coverage bins

Every event is a coverage bin, reached by a gate kernel or by directed
stimulus, with a negative control that must fail (DA 119). The table is the
MIU tab's "Events the model must cover"; build from the live table, not a
copy. MA added these since that table was written, and folds them into it:

| Event | Bin counts | Negative control |
|---|---|---|
| A request held for a DCU bank credit, then sent (MA-25) | `credit_hold_then_sent`, per bank, loads and stores apart | a model that sends without a credit trips DCU's queue-overflow check; one that never releases hangs |
| A store held behind an older held store to its bank | held stores | a younger store that overtakes fails the ordering check |
| A way mispredict (MA-26, `CCV_DCU_WAYPRED_BITS` > 0), answered on the loser's path (DI-2) | mispredicted loads, answered as late, never contract-timed | data taken at due fails the oracle |
| A withheld completion (ECC syndrome) taken as a miss | withheld completions | a completion sent anyway retires bad data |
| Kill against an atomic between A2 and A3 | atomics completed with more = 0 | releasing at the kill leaves the A3 orphaned |
| An uncorrectable read completed with no data | UE completions | a model that writes the data retires it |

The stub's controls carry over unchanged (`tools/check-kernel.sh` runs them:
`late-hit-data`, `early-hit`, `hint-wrong-tag`, `notice-wrong-id`,
`dcu-one-miss`, and the rest the table names). Never weaken a control to get
green; a control that stops failing is a finding, and gets a row.

**Verification, in order** (as `rcu-impl.md` section 5):
1. **The model (M0):** every kernel on both hosts against ccv-sim's oracle,
   with the DCU stub and with DI's DCU model once it runs; every control
   failing; every bin reached; the unit tests; the never-happens checks.
   Report kernel cycles against the stub's (S1, cm32 and cm128 at 8 ways:
   the deltas booked against the stub are re-checked against Daniel's 0.2%
   bar, DA 114).
2. **Module benches** (test/miu/), once Phase 2 gives the modules: directed
   tests from the spec's per-cycle tables, outputs checked against the
   model's where they are block outputs or events.
3. **Block lock-step:** the RTL against the model at the ports and events,
   every cycle, driven by ccv-skel port traces recorded with the model in
   place.
4. **In the SV top:** `tools/check-sv-hosted.sh` with the RTL in place, every
   kernel and control, and no divergence from the C++ host.

**Lock-step is at the ports and the events, and it is permanent.** A change
that moves behaviour there changes the model and the RTL in one commit. When
the RTL finds a timing limit, the model changes with it, the spec changes by
an MA row when a contract moves, and the bins re-run.

## 6. Build order and exit criteria

Each phase ends in a row in MI's tab: the figures against the criteria, the
commit, MA in Needs (and DA where a decision is his). Use `run-tabulate` for
sweeps and `gate-triage` for a red gate.

| Phase | Build | Exit, and who reads the row |
|---|---|---|
| 0, setup | section 8 | roster, session home, handoff, sweep task in place |
| 1, the model (M0) | sim/miu/: the block at MIU's ports, its events, holds, stalls and idle, the obligations of section 5 | every kernel and control passes on both hosts with the model in place, every bin reached, statistics reported; cycles against the stub's. TI flips `makeMiu`'s default. **MA reads it** and folds anything the spec failed to say into it |
| 1a, cold TLB | `CCV_MIU_TLB=cold` becomes the default (MI-6, MA 126) | the ~30 stub-pinned checks re-pinned under cold by TI; the seven controls MI-6 names fail again under cold (none dropped or weakened); the default flipped. The first item after M0 |
| 1b, with DI's model | both models in place together | every kernel and control passes with both; the cross-block bins (credits, late hits, withheld completions, the refill notice) reached with real DCU timing on both sides |
| 2a, the A1 modules | `miu_cap`, `miu_pair`, `miu_agu8`, `miu_lead`, `miu_cred` (MIU tab, Phase 2 slice 1) | per module: a bench against the model's A1 (lane VAs, leaders, set index, credit gate), check-cg and check-ngd at the tab's budgets |
| 2b, the A2 modules | `miu_tlb`, `miu_grp`, `miu_a2` (drop, MA-27), `miu_ids`, `miu_mq`'s hit-path ports | the same, against the model's eligibility, no-hit and req payload |
| 2c, the return | `miu_hitq`, `miu_rsp`, `miu_rcap`, `miu_ext`, `miu_out`, and `miu_ecc` (MA-28 (c)) | the same, against the model's data and completion at H+8 and H+9 |
| 2d, the L1-hit block | `ccv_miu` from slice 1's modules, the rest still the model's | the block as a sum of parts (check-cg's 2%, check-ngd level by level); an L1-hit kernel lock-stepped against the model in the SV top. **MA reads it** |
| 3 onward, the other paths | each slice MA lands (miss and refill, stores and the drain, atomics, SPM, the walker, faults, discard, replay and kill) | per module as above; then the whole block, then SV-hosted equivalence on every kernel and control |

## 7. What MI waits on

The open items, each a parameter with the default the model builds with.
None blocks the model.

| Item | Owner | Row | Default, and what moves it | Meanwhile |
|---|---|---|---|---|
| The bank-credit parameters and the two credit-return vectors (DCU → MIU); TI picks the channel | TI | MA-25 | `CCV_DCU_BANK_QDEPTH` 16, `CCV_DCU_BANK_STDATA` 12 | build the counts behind named constants; wire the vectors when TI lands them |
| Way prediction: `CCV_DCU_WAYPRED_BITS` (0 = off) and `CCV_DCU_WAYPRED_SEL` (index or recent); `CCV_LAT_L1_HIT` derived from them | TI | MA-26; DA rev 128 | 5 bits, recent select (AR 386, MA rev 112), so L1_HIT 8; runs move the defaults, never the structure | read `CCV_LAT_L1_HIT` from the parameters; test both 8 and 9 |
| A credit's return bound | RH's sweep, then MA | MA-25 | `CCV_DCU_BANK_AGE` 16 (sweep: 8, 16, 32, 64) | nothing waits: it is DCU's bound |
| The within-page bank hash | TI (parameter), RH's sweep | MA-20 | `CCV_DCU_BANK_HASH` off | the bank of a line comes from one function, so the hash changes one place |
| The ECC injection runs | TI | TI-484, AR 401 | `CCV_DCU_ECC_INJECT` (replaces `CCV_MIU_ECC_INJECT`) | develop the error paths under unit tests |
| The `makeMiu` hook, sim/miu/*.cpp in blocks.list, the `check-miu-unit` job, the lock-step job | TI | an MI row with TI in Needs, your first | — | develop the model under its unit tests |
| The ccv-skel port-trace dump for MIU | TI | as RA-34 for the RCU | — | directed stimulus |
| Phase 2, the slices after the L1-hit path | MA | MI-15; MIU tab, "MA's Phase 2" | slice 1 landed (tab rev 147) | slice 1's modules |
| The lookup drop bit, the rsp check bits, `CCV_DCU_ECC_INJECT` | TI | MA-27, MA-28 (AR 400, 401; MA rev 143) | agreed, not yet in the schema | build behind named fields; wire when TI lands them |

## 8. Getting the session set up (first hour)

1. **Roster.** Write your session id into `docs/register/roster.json`, entry
   `MI` (MA added it with `session: null` and your tab's node id), in a
   commit of its own.
2. **Session home.** Run the `session-home` skill so `.claude/settings.json`
   and `.claude/agents/` reach a session that runs from `/home/user`. It
   writes into the home directory, so ask Daniel first. Check it with
   `tools/setup-session-home.py --check`.
3. **Handoff.** Create `.claude/handoff/MI.md`: your working rules, branch,
   bookmarks, runs in flight and open work, most urgent first, in a few kB.
   Keep it current at every task's end.
4. **Register:**
   - Read the Conventions tab and `.claude/skills/register/SKILL.md`.
   - Search every tab for `MI` in Needs.
   - Create your daily sweep task as the skill's section 5 says, at minute
     39 (the series runs AR 3, OA 7, TI 11, OI 15, CP 19, IS 23, RA 27,
     RI 31, MA 35; DI takes 43). Ask OA to add MI and DI to the skill's
     series.
   - Your sweep's merge skips release and gate-scratch/*.
   - Read rows through the `register-reader` subagent. Ring a notice only
     for a row that asks something of its receiver.
5. **Toolchain.** In a fresh container, run `./tools/setup-toolchain.sh`, then
   `./tools/regen.sh`. Then read CLAUDE.md, "The gate".
6. **Branch.** Work on the branch your session was given. Never push to
   another agent's. Merges take merge commits, never a rebase or
   force-push. Push with `tools/gate-push.sh` (the scoped gate), with
   `CCV_PUSH_BRANCHES` set to your branch; it detaches, so follow it with
   `tools/gate-wait.sh`. Name each commit you want merged in your tab.
7. **No model identifiers** in commits, code comments or anything pushed. No
   dates on tasks (Daniel, 2026-11-16): order by priority.

## 9. Working beside the others

- **MA** answers every architecture question, in MA's responses table, and
  folds each answer into the spec and its snapshot. Expect MA to review each
  phase's exit row against the spec.
- **DI** builds the DCU model beside yours. Agree the order you land the
  credit channel and the late-hit timing in your tabs, so each model passes
  against the other's stub first and against the other's model second.
- **TI** applies schema, parameter, stub, control and gate changes, and
  merges your named commits.
- **OA and OI, RA and RI:** the memop, discard, replay and kill contracts
  are OOE's; the address channel and the write port are RCU's. Questions
  about what they send go to the architect, about when its model sends it to
  the implementer.
- **AR** owns the cross-block contracts and the top-level parameters.
- **RH**, Daniel's run helper, can take long runs. Ask Daniel first. RH has
  no register tab.
- **Daniel** starts this session and reads the DA-tagged rows.
