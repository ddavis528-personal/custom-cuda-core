<!-- design-snapshot url=https://claude.ai/artifact/5vrJfQoctw1tnTcSVZCAvY tab=AR_handoff_—_CCV_top-level_architecture rev=7 exported=2026-10-19 status=closed -->
> **Snapshot: do not edit.** Exported from *AR handoff — CCV top-level architecture*, tab *AR handoff — CCV top-level architecture*, at revision 7 on 2026-10-19 ([live doc](https://claude.ai/artifact/5vrJfQoctw1tnTcSVZCAvY)). The live doc is the source; it is a closed record, whose conversation has ended. This copy pins what the repo was built against; see [README.md](README.md).

# AR handoff

As of October 18, 2026

Context for a fresh instance taking over the top-level architecture role (`AR`) on CCV. Written to be read once, in order, before touching the register.

The conversation this replaces ran from the block-partitioning grill-me through Stage 4c. Nothing in it is load-bearing: every decision, its rationale, and every rejected alternative is in the register or the specification documents, which is what they were built for. This is the orientation, not the content.

## What CCV is, and where it stands

CCV is a CUDA/PTX-compatible vector processing unit, built as a personal project by Daniel — an engineering lead with deep CPU microarchitecture background. Compatibility is defined at the PTX and API level, not the hardware ISA: a custom internal ISA is the compilation target, and an LLVM backend bridges them.

**The machine.** 32 lanes x 32 bits, so 1024 bits of datapath. Four tier-1 warps with 28 parked, demotion on MLC miss via squash-to-retirement. Four issue slots spanning lane, memory and RCU-only classes — **not** four ALU ops; a full-width warp instruction consumes the whole lane array for a cycle. Each lane is four 8-bit sections, so narrow work co-issues in disjoint sections at 2x and 4x. 192 physical GPR rows as a flop array, 48 physical predicates. Target is roughly 1.5 GHz at 0.55V on an N3E-class process, 25 NGD per stage.

**Where it stands.** ISA v1.7 is settled and the LLVM backend compiles and runs the bootstrap kernels against `ccv-sim`, the functional oracle. The RTL work is partitioned into 14 block types and 45 instances, with a full channel schema, generated packages in SystemVerilog and C++, and a skeleton that wires every channel with real checkers. OOE is the first block with design RTL: its C++ timing model matches the oracle on every kernel, and its sequential RTL is being built sub-block by sub-block, each checked live against the model.

**The shape of the work.** Architecture is settled in grill-me sessions — Daniel being questioned relentlessly until a design closes — then implemented by separate agents, with findings flowing back. Most of what AR does is review: reading what the other agents decided and finding the thing that is wrong, missing, or quietly inconsistent with a decision made elsewhere.

## The register, and the conventions that matter

Six agents coordinate through one document, the [CCV cross-agent register](https://claude.ai/artifact/JApHYjaUESeq8tsGMGXMU5). **An agent writes only its own tab.** That is the whole mechanism, and it exists because the previous single-table register produced an ID collision and a near-miss on a lost edit within an hour of each other.

| Prefix | Agent |
| --- | --- |
| `AR` | Top-level architecture — this role |
| `OA` | OOE architecture |
| `IS` | ISA |
| `TI` | Top-level implementation: schema, generated packages, checkers, repository |
| `OI` | OOE implementation: model, RTL, block checkers |
| `CP` | Compiler and backend |
| `DA` | Daniel. Not an agent — a value in **Needs**, and a tab holding his decisions of record |

Each tab has an **Opens** table and a **Responses** table. A response goes in the *responding* agent's tab, never the raiser's — so following one thread means searching its ID across tabs. That is the price of write isolation and it is the right trade.

**Five conventions worth knowing before writing anything:**

**Needs is never empty while an item is open.** If no agent can answer it, it goes to `DA`. Unowned is structurally impossible, and escalation is a search for `DA` rather than a sweep.

**IDs are permanent and nothing is deleted.** A superseded decision stays visible beneath the one that replaced it. This matters more than it sounds: four decisions have been superseded while their original rows still read as current, and `OI-30` exists twice with opposite conclusions.

**Provisional work is legal.** Decision `open` with Impl `implemented` and a commit means built on the implementer's recommendation, pending the owner's ruling — and the implementer unwinds it if the ruling goes the other way.

**Daniel's decisions are recorded by whichever agent he decided with**, in that agent's session, into the `DA` tab. AR has written many of those rows on his behalf.

**At session start, search every tab for `AR` in Needs** and answer those rows before raising anything new.

## Documents of record

Read in this order. Cite them by ID or section rather than restating, since restated facts drift and cited ones cannot.

**[CCV cross-agent register](https://claude.ai/artifact/JApHYjaUESeq8tsGMGXMU5)** — start here. The `DA` tab in particular: it holds every decision Daniel has made with its reasoning and its rejected alternative, which is the fastest route into why the machine is shaped as it is.

**[CCV core — block partitioning and interface spec](https://claude.ai/artifact/7n8Uv33XAvxziZ7Xyz9jCz)** — four tabs. Partitioning (the 14 blocks, what each owns and does not), Interfaces (the conventions every channel obeys — flopped both sides, credited, valid one cycle early, kill and wake sidebands), Ports (41 channels with payloads), Payloads (the three width tiers, and the missing-field findings).

**[CCV per-block architecture specs](https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35)** — one tab per block, plus an Arch opens tab holding `A-1` to `A-24`. Seven of those are still open and were migrated into `AR-4` to `AR-10`.

**[Interface spec changes — sectioned lanes](https://claude.ai/artifact/77e2381f-2a64-4dfa-a3be-e60c82bc5425)** — the current change set. Its **No longer true** section names every superseded decision that still reads as current elsewhere. Read it before building from any row dated before 2026-10-09.

**[Interface spec changes — OOE session](https://claude.ai/artifact/EcuSx6yXG4dCmkT2ky2Cb7)** — the earlier OOE change set, with a Review tab holding `A-25` to `A-59`. Historical now, but it is where the merge-operand, checkpoint and latency decisions were argued.

**In the repository** (`custom-cuda-core`, branch `claude/custom-cuda-core-infra-6msg93`): `docs/open-items.md` holds `Q-n`, the schema and skeleton register, which stays there and is cited by ID; `docs/perf-register.md` holds `PF-n`, deferred higher-performance alternatives; `docs/ooe-model.md` and `docs/ooe-rtl-plan.md` are OI's.

## Positions AR has taken

AR raised `AR-1` to `AR-17` and much of `A-1` to `A-59`. These are the ones whose reasoning is worth carrying rather than rediscovering.

**Structural, and still load-bearing:**

- **Flops on both sides of every interface, no exceptions.** One round-trip number per interface sets credit depth, rescue depth, the timeout and the drain wait. Wakeup is latency-based because no result bus crosses a boundary.
- **Kill by warp mask, not grid ID.** RAU converts grid to a 32-bit mask from tables it owns, so nothing in flight carries a grid field and every receiver just masks its own state. Derive, don't carry.
- **The zero register (A-64).** Mapping all architectural registers to a hardwired zero index at launch removes activation zeroing, its ordering problem and the circular restore dependency at once, and makes isolation hold by construction.
- **One field, one meaning.** Four separate times a field was overloaded — instruction length in `imm`, predicate sources in `imm`, a third source in `dst_arch`, `req_id` on a probe. Each was caught late and cost a rework. Watch for it.
- **Response channels need correlation tags.** Five channels returned data with nothing identifying the request. Unimplementable at rate 4 with unordered completion, and nothing flagged it.

**Judgements that proved right:**

- **AXI cannot express exclusive ownership** — its `AxLOCK` is a reservation monitor, not ownership. TL-C's permission levels map directly.
- **The widest interface in the design is `ccv_rcu_miu_addr`**, and co-locating the AGUs only helps if coalescing moves with them. The question is where coalescing happens; the AGU follows.
- **`CCV_LAT_HOP` must be counted whole per crossing.** A fixed per-crossing cost cancels in linear formulas and not under `max`, which is a silent wrong-answer bug.

**Where AR was wrong, because the corrections are instructive:**

- **Claimed the ISA has no 8-bit FP.** It does — FP format codes read against the operand's own `chwidth`. The claim had already propagated into a generated parameter's documentation.
- **Claimed a load passing a load needs no disambiguation.** True only against stores; read-read coherence binds, and no per-access qualifier exists to separate a plain load from a relaxed atomic one.
- **Traced `vadd16` through a placement rule that was never adopted**, and reported a move-per-iteration cost that did not exist.
- **Assumed wakeup used tag compares.** It is a 45 x 45 dependency matrix, and the old destination was always among the five producers tracked.

The pattern in all four: reasoning from a remembered version of a decision rather than the current one. Read the row before arguing with it.

## What is open

**AR's own rows, still open:**

| ID | Needs | What |
| --- | --- | --- |
| `AR-4` to `AR-10` | mostly `DA` | Seven items migrated from the first register: EXB's credited external port, SPM's kill membership, `lane_fault`'s missing cause, DCU's absent byte mask, the TL deadlock-expressibility limit, per-slot `pc`, SPM's response bound |
| `AR-11` | `TI` | `TI-2` duplicates `IS-1`; TI to mark its own superseded |
| `AR-12` | `OA`, `TI` | Per-unit footprint minimums, and the memop PRF port budget |
| `AR-15` | `OI`, `OA`, `CP` | The sweep should measure footprint width, not moves |
| `AR-16` | `IS`, `OI` | Obligation 4 is now aggregate across warps; IS-5's rewrite must say so |
| `AR-17` | `TI`, `OI` | Merge commits should cite the register rows they implement |

**The real bottleneck is not decisions.** Most `DA` rows wait on block sessions that do not exist. Six of fourteen blocks have no agent: FET, DEC, RCU, LANE, MIU, and the memory blocks. Every item owned by one of them sits at `DA` looking like a decision Daniel owes, when it is a session nobody has scheduled. **RCU and LANE are the most blocking** — they own the swizzle, the section datapaths, FP8's four-way split, and `CCV_LAT_RCU_ADDR_BASE`.

**Genuine decisions outstanding:** `IS-2`, the grid-versus-context termination scope, which the whole fault model and `IS-1` wait on; `CP-5`, whether `gpr-count-decision.md` is IS's to amend or Daniel's; and `OI-43`, whether the RS keeps same-edge reuse at 25.2 NGD against a 25 NGD stage.

**Live threads worth watching:** OI is building OOE's sequential RTL sub-block by sub-block, each checked live against the model, and is finding real things — a Yosys misread that only a replay caught (`OI-44`), a free-list allocation that did not fit a stage (`OI-38`), a decode queue that missed only because of same-edge reuse (`OI-39`). Two rows wait on OA about where registers sit between sub-blocks (`OI-45`, `OI-46`).

## How the role works

**Daniel wants to be argued with.** He has overruled AR on real calls — FP8 at 4x against a recommendation of 2x — and accepted corrections to his own decisions when the reasoning held. A recommendation with its cost stated and its alternative named is worth more than agreement. What he does not want is deference dressed as analysis.

**Check the arithmetic.** Nearly every valuable finding came from summing a payload, deriving a latency from the hop model, or tracing a kernel through a stated rule. The agents are good; what they miss is usually a number that does not reconcile with one stated somewhere else.

**The dangerous findings are absences.** A wrong width fails a test. A missing field generates a struct, runs clean, and surfaces when something built on it fails. Correlation tags, the active-lane mask, the PC-group masks never migrated — all found by asking what a block would need that nobody had given it.

**Watch for decisions that interact.** The costliest near-misses were two correct decisions producing a wrong consequence: `IS-7` preserving obligation 4's generality while `OA-13`'s deferral made it aggregate-only; `OI-31`'s single MIU grant making narrow memory slower than full width on the benchmark the obligation cites.

**Record what lost.** A resolution naming only what was decided leaves the next reader to rediscover why the alternative failed. The entries that have aged best name the rejected option and its specific defect — `A-33`'s supersession is still legible a month later because of it.

**Keep responses in the register, not in chat.** Chat context is lost; the register is not. If something is worth saying to another agent, it goes in a row.
