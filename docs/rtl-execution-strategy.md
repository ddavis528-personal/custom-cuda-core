# RTL Execution Strategy — v3

**Status:** Aligned through §9 (RTL coding style). Not a design doc — this is the *process* doc: how we get from locked architecture to validated RTL, and in what order. Block-level architecture definition (the "grill-me" sessions) happens elsewhere; this doc assumes that output as an input and doesn't try to pre-decide it.

**Context this builds on:** ISA is locked (v1.6-ish). `ccg-sim` exists and is functionally correct — it retires the right architectural state for real compiled kernels (see `walkthrough.md`), but it is a **functional simulator, not a timing model**. It has no pipeline, no OoO scheduler, no SMT resource contention, no memory latency. That's the gap §1 addresses.

---

## 1. Cycle-accurate timing model

**Terminology, pinned:** `ccg-sim` is the **functional simulator** (what an instruction does). The thing built here is the **timing model** (when it happens). "Architectural simulator" is deliberately avoided in this doc — it's ambiguous between the two, and keeping them distinct is the entire point of the split below.

**Kept separate from `ccg-sim`**, which stays the trusted functional oracle. The timing model calls into it for *what* an instruction does and owns *when* independently — issue width, IQ occupancy, ROB pressure, two-tier SMT tier residency, barrier table contention, memory latency model.

**Event-driven, with per-instruction event streams.** Every event is pinned to a specific instruction and cycle, recorded from first decode through retirement. This buys two things: a debug/visualization tool essentially for free (the format maps directly onto the Chrome trace event format Perfetto renders — one track per instruction or structure, no bespoke viewer needed), and, critically, it upgrades RTL correlation (§5) from "compare cycle counts" to "diff two structured event streams and get exact stage-and-cycle divergence localization."

**Event taxonomy must split into two classes before either side gets built** — this is the sharp edge in "every event has a match in RTL":

- **Load-bearing events** — decode, dispatch, retire, memory request/response, any architectural-state-affecting event. Must match exactly; any divergence is a bug.
- **Arbitration-sensitive events** — issue cycle, wakeup-to-issue latency, warp-select outcome. Only meaningfully comparable if the timing model's arbiter is a *faithful* model of RTL's arbiter algorithm, including tie-break rules — not just a statistically plausible one (e.g. "oldest ready wins" vs. RTL's actual priority-encoder tie-break will diverge on every tie, permanently, looking exactly like a bug).

This taxonomy needs to be a single versioned schema that both the timing model and the RTL testbench instrumentation emit against — not invented independently on each side later. **Tracked as an open item** (see below).

**Everything structurally parameterized** that's feasible — ROB depth, IQ size, physical register file rows, barrier table entries, tier-1/tier-2 warp counts — as config knobs, not constants. This is the design-space-exploration tool before any of it becomes RTL area/timing commitment, the same pattern as deferring GPR count to spill data at the ISA level, applied to microarchitectural structures.

**Language: C++.** The deciding factor is the "swap an RTL block for a simulator block" goal: Verilator compiles RTL into a C++ model with a plain clock/eval/signal-poke API. If the timing model is also C++, either the hand-written timing-model block or the Verilator-generated RTL block can sit behind the same interface in the same executable, driven by the same top-level clock loop — no DPI, no cross-language boundary, no separate simulator process to synchronize. This is the mechanism that makes full-trace runs with one unit isolated in real RTL practical.

---

## 2. Design partitioning

**Partition boundaries = verification boundaries.** A block only earns its own partition if it can be given a clean interface and checked standalone; if two structures can only be verified together, they are one block regardless of what the block diagram suggests.

**The partition list is decided at §8 Stage 2, not here.** Block names used throughout this doc — OoO scheduler/SMT resource manager, register file, AGU/windowing, barrier unit, front-end — are **illustrative examples**, not a proposed partition. Closing that list is the first job of the interface-level grill-me.

**Order of definition is risk-first**, not pipeline-order: least-precedent, highest-design-risk blocks first; conventional front-end last, precisely because it has the most existing prior art to lean on.

**Memory is testbench-side, not a design block.** The memory system is modeled as a level N+1 part of the testbench — built as a coequal part of the Stage 3 skeleton, but deliberately never fleshed out. Two boundary questions this forces at Stage 2, since the line doesn't fall out of "memory is testbench" on its own:
- **The load/store unit and exclusive-ownership request logic are core-side.** Per `backend-context.md` §5.3, atomics execute in the core's ALU using the existing load buffer (with an exclusive-ownership request) and store buffer. Those buffers and that request logic are real design blocks; only the thing *servicing* the requests is testbench.
- **Shared memory / scratchpad is probably not in the same bucket as global memory.** It's on-die, explicitly addressed, and banked — bank conflicts are a first-order GEMM effect, not a latency assumption. Modeling it as unfleshed testbench would model away something the machine most needs to get right.

Memory still gets the full Stage 2 interface treatment: memory request/response are in §1's load-bearing event class, so it emits against the schema like any block. Interface assertions at that boundary matter *more* than elsewhere, not less — it's the one place the design meets a model nobody will ever validate.

### Physical target and timing budgets

**Target: ~1.5 GHz at Vmin 0.55 V on an N-1-class process (N3E), giving roughly 25 NGD (normalized gate delay) to work with.** This is a real architectural input, not a later implementation concern — it constrains structure sizing and pipelining decisions made at Stage 4a, so it is recorded here rather than living only in the grill-me sessions.

Per-block NGD budgets are recorded as grill-me output (§8 Stage 2 for interfaces, Stage 4a for internals). Writing them down converts intuition into something checkable: when synthesis eventually happens, it's diffed against a stated expectation rather than producing numbers with nothing to compare against, and a block 2× over budget points at a specific decision rather than general disappointment.

Structures where the budget most needs an explicit number, because timing depends on implementation choice rather than logic depth:
- **Issue wakeup/select.** The canonical single-cycle-or-broken loop — if back-to-back dependent issue is required, wakeup broadcast + match + select + arbitrate must fit one pass, which at 25 NGD constrains IQ entry count and simultaneous result-bus broadcast width. If it doesn't fit, the fallback is speculative wakeup with a replay path — a microarchitecture decision with ISA-visible consequences, not a pipelining tweak. That finding belongs at 4a, not Stage 6.
- **The barrier table's epoch-tagged comparator array.** A wide parallel compare, but almost certainly pipelineable, since arrive/wait is already a split transaction and a cycle of comparator latency costs little architecturally. Worth confirming rather than assuming — it's the cheap escape the wakeup loop doesn't have.
- **The buddy/slab register file.** Rename lookup + row/slice resolution + RF access at 1024-bit datapath width. Note this couples to an open ISA decision: if GPR count reopens from 16 to 32 on spill data, the rename array grows and the timing answer changes with it. The doc elsewhere treats GPR count as a compiler-data question only; it is also a timing question.

**Open question to settle at Stage 2:** whether 25 NGD is the *Vmin-corner* number or a nominal one. At 0.55 V, variation and the wire/gate delay ratio both worsen, so headroom at nominal does not translate linearly — this changes how much margin each block should hold back.

**Each block's partition carries a standalone testbench requirement** decided at grill-me time, not deferred to §7.

**Block boundaries are also swap boundaries.** The §1 block-swap mechanism only works if every partition boundary is clean enough that a hand-written timing-model block and a Verilator-generated RTL block can sit behind the same interface. This is a constraint on partitioning, not a later integration concern — see §8 Stage 2.

---

## 3. Analyzing machine behavior

Metrics: IPC / issue-slot utilization per structure, warp occupancy (resident warps per tier), register-allocation pressure and spill behavior (cross-checked against the compiler's static spill counts — a related but distinct measurement), barrier table contention / stall attribution, divergence/reconvergence behavior (does opportunistic reconvergence's performance risk actually materialize, does `reconv.hint` earn its keep).

**Trace creation and RTL correlation have collapsed into one artifact.** The per-instruction event stream from §1 *is* the trace — there is no separate trace format to design. Trace creation reduces to "define and emit the event schema" (the taxonomy split in §1); §5 reduces to "prove RTL emits the same schema, and diff against it."

---

## 4. Validating the timing model

Two different problems:

- **Functional correctness** — must retire identical architectural state to `ccg-sim` for every walkthrough kernel. Strict lockstep, cheap to automate, runs on every change to either model.
- **Timing correctness** — inherently provisional before RTL exists. The timing model encodes assumptions about latencies and contention; treat those as flagged assumptions (same status as an open ISA item), not fact, until §5 closes the loop.

Trace sources: the growing walkthrough kernel corpus (GEMM tile, reduction, elementwise at varying `chwidth`) plus targeted microbenchmarks engineered to stress one structure at a time (saturate the barrier table, force maximum tier-1/tier-2 SMT churn).

**The memory model's timing assumptions never resolve.** Every design block's timing assumptions get validated when §5 correlation closes the loop at Stage 4d. Memory has no RTL counterpart to correlate against, ever (§2) — so its latency/bandwidth model stays a *permanent* assumption rather than a provisional one. For GEMM especially, that is the assumption most performance conclusions rest on.

The mitigation is not to flesh it out, it's to **parameterize aggressively and sweep**: latency, bandwidth, outstanding-request limits, response reordering. If architectural conclusions hold across a wide sweep, they are robust to the model being wrong — converting an unvalidatable assumption into a bounded one. Note this is a *different practice* from the structure-sizing exploration at Stage 4b: sizing converges on a value, this deliberately does not converge, it establishes a range.

**External dependency, stated explicitly:** that corpus is an output of the LLVM backend bootstrap, which is a parallel effort on its own schedule (see `backend-context.md` §3). The `vadd`-class kernel needed at §8 Stage 3 exists today; the GEMM tile / reduction / elementwise set needed at §8 Stage 6 does not yet. If the compiler effort lags, Stage 6 is gated on it — worth tracking as a cross-project dependency rather than discovering it at the gate.

---

## 5. Correlating the timing model to RTL

**A real codesign opportunity, not just a checking exercise.** Because the timing model and RTL are being built by the same effort with nothing frozen, an arbitration policy can be prototyped cheaply in the model, evaluated against §3's metrics, and only then committed to RTL — the risk shifts from "guess a policy, discover it's wrong after RTL exists" to "test before either implementation is expensive to change."

**Guardrail on the codesign benefit:** the arbitration algorithm must still be written down as its own spec artifact, not left as something two codebases happen to agree on because the same person wrote both.

Be precise about what this buys, though. Written at Stage 4a by the same person who then writes the model (4b) and the RTL (4c), the spec has *temporal precedence*, not independence — it does not make "model and RTL agree" into proof that either is correct. What it does deliver is still worth the cost: a stable reference to diff against, so that a change to the policy becomes a visible decision rather than silent drift in one implementation. Claim that, not independence.

**Correlation harness:** same instruction trace into both; diff at the event-stream level using the load-bearing/arbitration-sensitive split from §1, not full lockstep on every internal event (real OoO hardware and a timing model can legitimately reorder internal micro-events while agreeing on architectural outcome and cycle count).

**Divergence triage process, defined before it's needed:** a mismatch is (a) an RTL bug, (b) a timing-model modeling error, or (c) a genuine spec ambiguity both sides resolved differently. Feedback is bidirectional — RTL findings should update the timing model's assumptions, not just get logged as RTL bugs.

---

## 6. Simulating RTL

**Two-tool split, sequenced by risk, not a single simulator.**

- **Verilator** — fast, 2-state, C++ output (enabling the §1 block-swap mechanism). Default simulator for day-to-day iteration, high-volume functional/performance regression, and the §5 co-sim once a block is known X-clean.
- **Icarus Verilog (`iverilog`)** — genuine 4-state (X/Z) interpreted simulator, GPL/open source, implements the IEEE 1364/1800 LRM's X-propagation rules rather than a fast-path approximation. Run as a periodic X-cleanliness pass (e.g. gating milestone merges), not the per-change default, since it's meaningfully slower. A small targeted test suite exercising known X-prop edge cases (unknown branch conditions, `casez`/`casex` don't-care handling, uninitialized-register propagation) should validate it tracks VCS-like behavior before it's trusted, if any VCS access is available for comparison.

**Sequencing: start with 2-state co-sim validation on Verilator, layer in 4-state `iverilog` validation later.** Early bring-up bugs are overwhelmingly functional (wrong decode, wrong datapath, wrong issue timing) that 2-state catches as well as 4-state at a fraction of the runtime cost. X-prop correctness matters most at reset/init sequencing and don't-care propagation — a narrower, later-stage concern.

### Reset and clock architecture — decided

**Globally synchronous reset, single clock domain, and reset is applied selectively — not to every state node.**

Selective reset makes the X-cleanliness pass one of the *harder* validation activities, not an easier one: un-reset state legitimately comes up X, and the whole question is whether it can reach anything that matters. What makes it safe is an invariant that belongs in the design rules, stated rather than implicit:

> **Un-reset state is payload. Payload is only ever read when an accompanying valid bit says it was written — and valid bits are always reset.**

ROB and IQ payload, register file rows, barrier table entry fields fall on the un-reset side. FSM state, valid bits, head/tail pointers, credit counters fall on the reset side. Drawing that line is a per-block architectural decision and belongs in Stage 4a alongside the arbitration policy.

Three consequences:

- **This pushes work toward formal, which suits the §7 posture.** "Payload is never read before written" is exactly what simulation samples and formal proves. Formal treats uninitialized state as free variables — genuinely pessimistic, unlike simulation, which only sees whatever X pattern that run happened to produce. The reset policy's safety argument is better discharged by `sby` than by `iverilog`, and it gives the formal effort a concrete high-value target beyond the barrier table and allocator.
- **Verilator hides these bugs by default.** 2-state sim gives un-reset state a defined value, so a design that accidentally depends on unreset payload passes every default Verilator run. Given 2-state-first sequencing this is a known blind spot — mitigated two ways: run the X-pass **once per block at Stage 4c** rather than only at closure, and use Verilator's X-randomization across seeds (see X-safety below) so the blind spot doesn't persist between X-passes.
- **`iverilog` cannot close the gap alone.** Verilog's X-optimism means 4-state sim also *hides* X bugs — `if (x)` silently takes the false branch rather than flagging ambiguity. Commercial tools mitigate this with a dedicated X-propagation mode (VCS being the reference point); `iverilog` has no equivalent. It catches X that propagates visibly, not X silently resolved at a branch. Formal covers that gap better than any simulator will.

**Revisit trigger:** multiple *frequency* domains. Clock gating for power does not break the single-domain assumption and can be added later without reopening this decision.

### X-safety by construction — planned up front, not inherited from the tools

*(The highest-priority section of the §9 coding style guide, scheduled at §8 Stage 1d.)*

The available tools do not have dependable X-prop semantics: `iverilog` implements the LRM's rules, which are themselves X-optimistic (`if (x)` silently takes the false branch), and Verilator is 2-state. Rather than depend on a tool behavior that isn't reliably there, **X-correctness is designed in by coding convention and enforced by lint** — scheduled at §8 Stage 1d, before any RTL exists.

**The core move is to prohibit X on control rather than to propagate it.** `$isunknown()` assertions on every control input — selects, enables, valid bits, case selectors — convert the X-optimism hole into a loud assertion failure. That works in every tool regardless of X-prop fidelity, it is formally provable (formal treats un-reset state as free variables, so it is exhaustive rather than sampling whatever X pattern one run produced), and it reuses the §7 assertion machinery instead of being a parallel mechanism. Coding style is then the complement: propagate X on *data*, where it is cheap and reliable; prohibit X on *control*, where propagation is not.

Rules to encode and lint, in rough order of payoff:
- **`default: <= 'x` in case statements** — explicit X-injection for unreachable states, rather than the implicit hold that squashes the bug
- **No bare `if`/`case` on control without a paired `$isunknown` assert** — the rule that closes the X-optimism hole
- **`unique`/`priority case`**, whose implied assertions fire on no-match, which is what an X selector looks like
- **X-aware mux primitives** for data paths where propagation is genuinely wanted, so it's a called function rather than per-instance discipline

**Verilator is less blind than the reset section above implies.** It offers X-assignment and X-initial *randomization*: give un-reset state randomized rather than fixed values, run the same test across several seeds, and divergence between seeds indicates a real dependency on uninitialized state. That is not X-propagation, but it is a genuine detection mechanism for exactly this bug class, and it is fast enough to run constantly rather than periodically. Confirm current flag behavior in the 1a spike rather than assuming it.

**Tooling consequence:** this adds a fourth tool to the flow — **Verible**, the open-source SystemVerilog linter. Whether it can express these rules directly or needs custom rules authored against it is a 1a spike question, since "lint enforces it" is load-bearing for the whole approach.

*(Note: Verilator has an in-progress four-state logic effort (CHIPS Alliance/Antmicro) that isn't production-ready as of now — worth tracking as a future option to consolidate onto one tool, not a current-state assumption.)*

**UPF / power-domain modeling: explicitly deferred for this phase.** Scope decision, not an oversight — recorded with rationale the same way the atomics execution-model reversal is recorded in `backend-context.md`: (1) the project starts with a single power domain, so there's nothing to model yet; (2) no viable free/open UPF-*simulation* tooling exists today — Yosys has early UPF support, but it's synthesis-side elaboration (power intent → netlist), not power-aware simulation semantics, and it depends on Verific's commercial parser plugin, so it isn't actually a free path either way. Revisit if a later phase needs multi-domain power modeling.

**Yosys is not a simulator** — it's a synthesis and formal-verification framework (elaboration, tech mapping, and via SymbiYosys/`sby`, SAT/BMC-based formal proofs). It doesn't compete with Verilator/Icarus; it's the tool for §7's formal work.

---

## 7. Validating RTL

**Block-level testbenches remain primary.** The §5 co-sim strategy augments, it does not replace, per-block validation — block boundaries were chosen specifically because they're well-defined and independently checkable (§2), and that property is wasted if full-chip co-sim becomes the only validation path.

**Full-chip:** kernel-level correlation against the timing model via the §5 harness, using the growing walkthrough/microbenchmark corpus as a permanent regression suite — every kernel that clears the compiler bootstrap becomes a regression test, not a one-off run.

**Formal verification: leaning in hard, designed for from the ground up.** This is treated as a first-class part of the RTL strategy, not an add-on late in the project.

**Assertions get written in two waves, at two different stages** — the doc previously conflated these:
- **Interface assertions**, written at partition time (§8 Stage 2), against the primitives from Stage 1b. The interface contracts defined during the interface-level grill-me should be assertion-checkable from the start; these properties are what the skeleton and every later block-swap are validated against.
- **Internal assertions**, written per block during its RTL build (§8 Stage 4c), covering the block's internal invariants rather than its contract with neighbors.

The interface wave matters more than it looks: those are the properties that become `assume` cut-points when a neighboring block is black-boxed for formal (see below), so they need to exist before the first block is proved in isolation, not after.

**Assertion primitives — three distinct roles, not one:**
- `assert` — an obligation the design must satisfy (checked in sim, proved in formal).
- `assume` — an environment constraint. In sim, largely inert; in formal, it both restricts the search space *and* is the cut-point mechanism — black-box a sub-block, replace its output with a free variable, `assume` the contract the real block would have guaranteed, making the rest of the design tractable to prove without including that block's full state space.
- `cover` — reachability proof, doubles as a sanity check (an unreachable `cover` is either a dead property or a bug in how it was written).

A property that's an `assert` at block level often needs to become an `assume` at system level once that block sits inside a larger cut boundary — the primitive library needs to make these roles explicit and swappable at the call site, not conflated into one generic assertion macro.

**Runtime on/off knob: use SVA's native mechanism, not `` `ifdef ``.** `$assertoff`/`$asserton`/`$assertkill` are built-in, hierarchically-scoped, runtime system tasks — exactly the "no recompile needed" knob wanted. The hard rule: assertions must always stay *elaborated* in the RTL; the knob only gates whether the checker fires in simulation. Compiling them out via `` `ifdef `` would silently remove the properties from what formal tools see when reading the same source — defeating the point of one property set serving both flows. Centralize this in the primitive library so the off-switch is never implemented ad hoc.

**Tool-support spike required before primitive syntax is locked.** SVA support is genuinely uneven across the toolchain: Verilator has real mainline support for global assertion control (enable/disable by directive type, at simulation stages) and growing concurrent-assertion support; Icarus supports immediate assertions (needs explicit `-g2009`+ enablement) with less certain concurrent/temporal coverage; `sby`/Yosys's strongest SVA parsing runs through Verific's commercial frontend, native support is more limited. **Action:** write a handful of representative properties (a `$past`-based sequence, an `assume`-as-cut-point, a clocked `assert property`) and confirm what actually parses and checks cleanly in all three tools before the primitive library's syntax is treated as settled — the tool-support intersection, not the LRM, is the real constraint.

**Formal targets:** the barrier table (epoch-tagged, comparator-driven wake) and the register rename/buddy-slab allocator remain the two structures flagged as highest-value for formal treatment — small enough in scope to be tractable for a solo effort, and exactly where directed testing has the best chance of missing a corner case.

**Third formal target, added by the reset decision (§6):** the un-reset-payload invariant — "payload is never read before written." Formal is the right tool because it treats uninitialized state as free variables rather than as whatever value one simulation run produced, and because `iverilog`'s X-optimism means no simulator will fully discharge this argument.

---

## 8. Staging Plan

How §1–§7 actually unfold over time — what gets built first, what gates what.

1. **Tooling and schema groundwork.** Membership criterion for this stage: *needs no architectural decision as input*. Four items qualify — conventions and mechanisms that every later stage assumes exist, and that are expensive to retrofit once RTL is being written against them.
   - **1a — Tool-support spike.** Establish the actually-usable SVA subset across Icarus, Verilator, and `sby`/Yosys (§7). Also covers two questions 1d depends on: whether **Verible** (open-source SystemVerilog linter) can express the X-safety rules directly or needs custom rules written against it, the current behavior of **Verilator's X-assignment / X-initial randomization flags** (§6), and two §9 style questions — whether SystemVerilog `interface` constructs are usable at block boundaries given the block-swap requirement, and `bind` support for assertion placement. Pure tooling investigation, small, zero architecture dependency. **Front-loaded deliberately for risk reasons:** if the intersection comes back thin — particularly if concurrent/temporal SVA proves unreliable across the free stack — that is not a minor tooling annoyance, it undercuts §7's entire lean-into-formal posture. Finding that out in week one is cheap; finding it out at 4c, after a block's worth of properties have been written against an unsupported subset, is not.
   - **1b — Assertion primitive library.** The `assert`/`assume`/`cover` role split and the `$assertoff` runtime knob (§7), built against whatever 1a found usable.
   - **1c — Event schema mechanism.** Format, versioning, emit API, Perfetto mapping (§1). This is the *container*, not the event list — see the taxonomy note below.
   - **1d — RTL coding style guide and lint rules.** Expectations set before the first line of RTL, enforced by lint rather than by discipline. X-safety (§6) is its highest-priority section, but the guide is broader — and parts of it are load-bearing for the block-swap and correlation machinery, not merely hygiene. See §9.

2. **Interface-level grill-me — all blocks.** **Closes the partition list first** (§2 — block names used elsewhere in this doc are illustrative, not a proposed partition), then a lightweight architectural pass across every block in it: signals, protocol (stall/ready-valid/request-response), what each block consumes from and produces for its neighbors. Produces the interface contracts the skeleton is built against — explicitly *not* the full internal-behavior spec (arbitration policy, structure sizing) each block will eventually need; that's deferred to Stage 4. Two things fall out of this pass nearly for free, because they are interface-defined by nature: the **load-bearing event list** (decode/dispatch/retire/memory events *are* the interface contract, viewed as a trace) and the **interface assertion wave** (§7), written against 1b's primitives at the end of this stage.

3. **Skeleton — all blocks, whole machine.** Built against Stage 2's interface contracts. Internal timing is placeholder (fixed latency, no real arbitration, no real contention). This is the earliest point a kernel can run through the entire wired-together machine, decoupled from whether any single block's internal fidelity is trustworthy yet. Validates the load-bearing event class end-to-end; walkthrough corpus runs through it with `ccg-sim` checking correctness.

4. **Per-block cycle, risk-ordered** (OoO scheduler/SMT resource manager → register file → AGU/windowing → barrier unit → front-end). Repeats once per block, each iteration trailing the previous block's cycle:
   - **4a — Full internal-behavior grill-me for that block.** Arbitration policy, structure sizing, that block's **NGD budget** against the 25 NGD envelope (§2), and its **reset line** — which state is reset vs. which is un-reset payload (§6). Also where that block's **arbitration-sensitive events** get enumerated, since they are internals-defined and cannot be listed before the block's internal structure is known.
   - **4b — Timing-model internal buildout for that block**, using 4a's output. Where the arbitration-sensitive events get real content, and where design-space exploration against §3's metrics happens (structure sizing decisions, same category as GPR count waiting on compiler spill data).
   - **4c — That block's RTL grill-me and build**, standalone, block-level testbench and the **internal assertion wave** (§7) written concurrently — sequenced to trail 4a/4b so the model's internals inform the RTL, not the other way around. Includes a per-block `iverilog` X-cleanliness pass, pulled forward from closure because selective reset (§6) makes Verilator structurally blind to un-reset-payload bugs.
   - **4d — In-context validation, both forms.** The block's timing-model internals drop into the Stage 3 skeleton in place of that block's stub; its RTL drops into the same skeleton via the §1 block-swap. Everything else stays stubbed. This is where **per-block §5 correlation happens** — not later, at integration.

   **Why correlation belongs here and not at integration:** with every neighbor still a deterministic stub, any correlation divergence is attributable to the one block under test by construction. There is no ambiguity about which block caused it, because nothing else in the machine has non-trivial behavior yet. Full-machine correlation can never offer that — once every block is real, a divergence is a search problem. Catching a block's timing-model/RTL disagreements at 4d, in the controlled case, is dramatically cheaper than catching them at Stage 5 in the general one.

5. **Integration — assemble the pieces.** Stage 4 leaves every block built and individually validated, but always in a machine where everything *else* was a stub. Stage 5 removes the stubs: real blocks composed into a genuine cycle-accurate timing model and a genuine full-chip RTL model. Run in the restricted regime first — single lane, single warp, no divergence (the RTL analog of the `vadd` walkthrough milestone).

   **Integrate incrementally, in the same risk order, not big-bang.** Each step replaces one more stub with its real block in both models. The blocks are already validated by Stage 4, so this is not re-doing block build-out — it is isolating *interaction* failures, which are a different class of bug entirely and the first ones no amount of per-block work could have surfaced: cross-block contention, interface-protocol mismatches that only appear under real backpressure, and deadlock across interfaces that each side independently considered legal. This is also where the Stage 4b cross-block metrics caveat finally resolves, since measurements stop being taken against stubs.

6. **Turn on the hard parts** — two-tier SMT, OoO width, real divergence (illustrative; the actual list follows from the Stage 2 partition). **Enable them one at a time, not together.** Each is independently among the riskiest things in the architecture, and turning them on simultaneously destroys the attributability the rest of this plan works to preserve. Full kernel-corpus regression begins (GEMM tile, reduction, elementwise), mirroring the compiler bootstrap set.

7. **Closure.** Co-sim regression suite goes permanent, `iverilog` X-cleanliness pass (§6) added as a periodic gate, formal verification (§7) matures from spot-check to real coverage on the barrier table and register allocator.

### Exit criteria

A stage is not done because it feels done. **Anything that can be a script should be** — on a solo project, criteria requiring a manual checklist decay to nothing, so exit checks belong in the regression, not in discipline.

**Stage 1**
- 1a: written matrix of SVA constructs × three tools, pass/fail per cell, with a named usable subset; Verible's rule-authoring story and Verilator's X-randomization flag behavior both confirmed
- 1b: primitive library compiles in all three tools; a smoke property demonstrably fires, and is demonstrably silenced via `$assertoff` at runtime
- 1c: schema versioned; a stub event stream round-trips into Perfetto, **and** the DPI-C path emits from a trivial SystemVerilog module — the Stage 1c decision exercised, not merely decided
- 1d: style guide written (§9); lint rules **fail** a deliberately non-compliant sample module — demonstrated to bite, not merely configured; shared-parameter generation produces matching C++ and RTL definitions from one source

**Stage 2**
- Partition list closed
- Every block has a written interface contract
- Load-bearing event list complete, every event mapped to a specific interface transaction
- Interface assertions written for every boundary
- Per-block interface NGD budgets recorded against the 25 NGD envelope

**Stage 3**
- `vadd` runs end-to-end through all blocks
- Retires architectural state identical to `ccg-sim`
- Emits a complete load-bearing event stream that loads in Perfetto
- Zero interface assertion violations

**Stage 4, per block**
- 4a: written internal-behavior spec — arbitration policy, NGD budget, reset line, with pipelining decided wherever the budget forces it
- 4b: internals replace the stub; full corpus still functionally correct vs. `ccg-sim`; arbitration-sensitive events emitting; sizing sweep data collected
- 4c: standalone testbench passes; internal assertions clean; lint clean against 1d's rules; X-cleanliness pass clean (including multi-seed Verilator X-randomization); formal run where the block is a formal target
- 4d: correlation clean — **criterion open for arbitration-sensitive events**, see open items

**Stage 5** — all stubs removed except memory; full corpus passes; correlation clean at full machine
**Stage 6** — each hard feature enabled individually, correlation still clean after each
**Stage 7** — CI green, X-clean pass across the design, formal coverage at target on all three formal targets

### Why the event taxonomy is split across stages

The event taxonomy is not one artifact. It is a **mechanism** (Stage 1c) plus **content that populates incrementally**, and only the mechanism needs front-loading. The two classes populate from two different places, each falling out of work already being done:

- **Load-bearing events** are interface-defined → they drop out of the Stage 2 interface grill-me.
- **Arbitration-sensitive events** are internals-defined → they populate per block at 4a.

This is the same shape as the assertion split in §7 — interface wave early, internal wave per block. The taxonomy and the assertion library ending up with parallel lifecycles is a signal the partition is real rather than imposed.

### The RTL emit path is a Stage 1 decision, not a 4c decision

The event schema is shared by the timing model *and* RTL testbench instrumentation, but its RTL consumer doesn't arrive until 4c. That gap is a trap: designing a C++-only emit API at Stage 1c and discovering at 4c that SystemVerilog can't feed it cleanly means a retrofit across every block already built. Given C++ is already the timing-model language (§1), the natural answer is **DPI-C into a shared emit library** — but this must be an explicit Stage 1c decision, not an assumption discovered later.

### The block-swap mechanism has two distinct uses

The §1 block-swap is not only a bring-up device, and the distinction is worth keeping explicit because the two uses run in opposite directions:

- **At 4d — one real block among stubs.** Isolates the block under test. Everything else is deterministic, so divergence is attributable by construction.
- **From Stage 5 onward — all blocks real, then swap *one back* to timing-model form.** Isolates a suspect during debug of an assembled machine: run the full kernel trace against the real core with a single unit replaced by its model, and see whether the symptom follows the unit. This is the ongoing debug capability the C++/Verilator language decision in §1 was chosen to enable, not a transient bring-up step that expires once integration completes.

### Stages 1 and 2 overlap rather than strictly sequencing

Stage 1 is tooling; Stage 2 is architecture. They don't contend except for calendar time, and nothing requires all of Stage 1 to complete before Stage 2 begins. The actual gating relationships are narrower than the numbering implies:

- 1b (primitive library) must exist before Stage 2's **interface assertions are written** — which is at the *end* of Stage 2, not its start.
- 1c (event schema) must exist before Stage 3's skeleton **emits anything**.

Read the stage numbers as dependency order, not as a serialized schedule.

### CI is a Stage 1 concern, not a Stage 7 one

§4 requires lockstep validation against `ccg-sim` "on every change to either model," and the exit criteria above are written to be scripts. Both are implicit CI requirements that no stage previously established — Stage 7 only says the regression suite "goes permanent," by which point it should have been automated for years. **Stand up the harness alongside Stage 1c** (it needs the event schema and nothing else), and add each stage's exit criteria to it as that stage defines them. On a solo project this is the single piece of infrastructure whose absence compounds fastest.

**Two caveats that apply throughout, not just at the stage they're introduced:**

- **Stage 2's interfaces are a starting point, not a frozen contract.** When a block's Stage 4a/4b work finds its Stage 2 interface was wrong or incomplete, that's an expected finding, not a process failure — same bidirectional-feedback posture §5 established for the arbitration model and RTL, one level earlier in the flow.
- **Cross-block metrics are only as trustworthy as the least-built block on that data path.** During a block's Stage 4b buildout, its neighbors may still be Stage 3 skeleton stubs — a scheduler decision measured against a stub memory system isn't fully real yet. Treat such metrics as provisional, the same way §4 already treats pre-RTL timing correctness as provisional, until every block along that path has real internals.

---

---

## 9. RTL coding style

Scheduled at §8 Stage 1d, before any RTL exists. Retrofitting style across built blocks is the expensive path, and lint rules added late mostly generate backlog rather than catching bugs.

Most of this is ordinary discipline. Two parts are not — they are load-bearing for machinery this plan depends on, and getting them wrong costs more than style violations normally do.

### Load-bearing: names and parameters are cross-language artifacts

Every signal and structure exists twice — once in the C++ timing model, once in RTL — and §5 correlation diffs them against each other.

- **Naming must be mechanically consistent across both.** A signal that is `iq_issue_valid` in RTL and `issueValid` in the model imposes a translation tax on every 4d debug session, permanently. Pick one convention and apply it in both languages, including in the event schema's field names (§1).
- **Parameters need a single source of truth.** ROB depth exists as a swept knob in the model (Stage 4b) *and* as an RTL parameter. Nothing currently prevents them from drifting, and drift would mean a correlation run silently comparing two differently-sized machines — a failure that looks like a timing bug. Generate both from one shared definition rather than maintaining two. **This is a mechanism decision to make at 1d, not a convention.**

### Load-bearing: interface style constrains block-swap feasibility

Block boundaries are swap boundaries (§2), so the interface style has to translate mechanically to a C++ boundary. SystemVerilog `interface` constructs are the elegant answer, but Verilator support has historically been limited and they complicate exactly the boundary §1's swap mechanism relies on. Plain ports with consistent suffix conventions, or packed structs, are the safer default. **Which of these actually works is a 1a spike question**, alongside `bind` support (below) — it should not be assumed.

### Ordinary discipline, stated so lint can enforce it

- **Synthesizable subset:** no `initial` blocks for reset behavior, no delays; nonblocking (`<=`) in sequential logic, blocking (`=`) in combinational; no inferred latches.
- **Clock and reset ports** identically named in every module, so instantiation and the swap harness are mechanical. Reasonable given the single-domain, global-sync-reset decision (§6).
- **One module per file, filename matches module name** — required for build automation and most lint tooling.
- **Assertion placement:** prefer `bind` so assertions live in separate files, keeping RTL readable and keeping properties naturally excluded from synthesis. Note this is not free — `bind` support varies across Icarus, Verilator, and `sby`, so it joins the 1a spike list.
- **Each module references the spec artifact it implements** — its Stage 4a internal-behavior spec — so RTL and spec stay traceable to each other as both evolve.

---

## Open items

1. **Event taxonomy spec** — load-bearing vs. arbitration-sensitive event classes, versioned schema shared by the timing model and RTL testbench instrumentation. Scheduled: mechanism at §8 Stage 1c (including the DPI-C emit-path decision), load-bearing content at Stage 2, arbitration-sensitive content per block at Stage 4a. (§1)
2. **Arbitration policy spec** — written as its own artifact once prototyped in the timing model, before RTL commits to it; exists as a stable reference so a policy change is a visible decision rather than silent drift in one implementation (§5 is explicit that this is temporal precedence, not independence). Scheduled: per block at §8 Stage 4a/4b, before that block's 4c RTL build. (§5)
3. **Assertion primitive library + tool-support spike** — validate the common SVA subset actually supported across Icarus, Verilator, and `sby`/Yosys before locking syntax; design the `assert`/`assume`/`cover` primitives and the runtime-knob mechanism against that intersection. Scheduled: §8 Stages 1a/1b, front-loaded because a thin SVA intersection would undercut §7's formal posture. (§7)
4. **4d correlation criterion for arbitration-sensitive events.** Load-bearing events have an unambiguous criterion (exact match, any divergence is a bug). Arbitration-sensitive events do not. If the arbiter model is faithful down to tie-breaks, exact match is achievable and 4d is a clean automated pass/fail gate; if not, a tolerance must be stated (cycle-count delta within N%, or distribution-level agreement) and correlation becomes a judgment call each run. **This choice also constrains how the event schema records those events**, so it wants settling before Stage 1c locks the schema. (§5, §8 Stage 4d)
5. **CI harness** — stand up alongside §8 Stage 1c; accumulate each stage's exit criteria as scripts as those stages define them. (§8)
6. **Timing model implementation details** — C++ is decided; the event-driven scheduler design still needs concrete work. The **block-swap interface is no longer deferred**: it constrains partition boundaries (§2) and must be settled before the skeleton is built (§8 Stage 3), since the skeleton's block boundaries *are* the swap boundaries and retrofitting swappability means reworking every interface. Scheduled: §8 Stage 2, alongside the interface grill-me.

---

## Resolved scope decisions (with rationale, for the record)

- **UPF / multi-domain power modeling: deferred.** Single power domain for this phase; no viable free UPF-simulation tooling exists regardless. Revisit if multi-domain modeling becomes necessary. (§6)
- **RTL simulation: two-tool split.** Verilator (fast, 2-state, default) + Icarus Verilog (4-state, periodic X-cleanliness pass), sequenced 2-state-first. Not consolidating onto one tool because no open-source simulator currently offers both speed and mature 4-state/X-prop fidelity. (§6)
- **Memory system: testbench-side, never fleshed out.** Modeled as level N+1 in the skeleton. Consequence accepted: its timing assumptions are permanent rather than provisional, mitigated by parameter sweeps establishing a range rather than converging on a value. (§2, §4)
- **Synthesis: deferred until after the staged plan is mostly complete.** Process selection, cell libraries, and array mapping are a rabbit hole with no payoff at this stage, and relative sizing decisions need far less absolute accuracy than synthesis provides. Timing feasibility is instead carried by explicit per-block NGD budgets set at grill-me time against a 1.5 GHz / 0.55 V / N3E-class / ~25 NGD target. **The grill-me is therefore the area/timing gate** — a named responsibility, not an implicit one. **Revisit trigger:** the first block whose budget the grill-me cannot confidently bound — i.e. when intuition runs out, which is the only moment tooling would say something new. (§2)
- **Coding style set before RTL, enforced by lint.** Includes two mechanism decisions that are not merely conventional: a single source of truth for parameters shared between the C++ timing model and RTL, and an interface style compatible with the §1 block-swap boundary. (§9, §8 Stage 1d)
- **X-correctness: designed in by coding style and lint, not inherited from tool semantics.** Neither available simulator has dependable X-prop behavior (`iverilog` is LRM-X-optimistic, Verilator is 2-state), so the posture is to prohibit X on control via `$isunknown` assertions and enforce a style guide by lint — planned before any RTL exists rather than discovered later. Adds Verible as a fourth tool. (§6, §8 Stage 1d)
- **Reset and clocking: globally synchronous reset, applied selectively; single clock domain.** Not every state node is reset. Safety rests on the stated invariant that un-reset state is payload guarded by always-reset valid bits, discharged by formal rather than simulation. Revisit trigger for clocking is multiple *frequency* domains; clock gating does not reopen it. (§6)
