# Roadmap and handoff

Companion to [`rtl-execution-strategy.md`](rtl-execution-strategy.md), which is
the process contract. This file tracks what is actually built, what is next,
and what is carried.

---

## Part 0 — picking this up again

**State: Stage 1 complete and gated. Stage 2 not started, and it is not this
repository's to start.**

```
    ./tools/setup-toolchain.sh   # containers are ephemeral; this restores one
    ./tools/verify.sh            # green
```

**The next action is not a coding task.** §8 Stage 2 is the interface-level
grill-me, which *closes the partition list first* and then defines interface
contracts across every block in it. §2 is explicit that the block names used
throughout the strategy doc — OoO scheduler, register file, AGU/windowing,
barrier unit, front-end — are **illustrative examples, not a proposed
partition**, and that closing the list is the first job of that session. That
work happens in the architecture track, not here.

What this repository is waiting for, specifically:

1. **The partition list.** Everything downstream is shaped by it: the unit
   list in `schema/events.json` is currently §2's own illustrative names,
   carried only so the mechanism has something to exercise.
2. **Per-block interface contracts** — signals, protocol, what each block
   consumes and produces.
3. **Per-block interface NGD budgets** against the 25 NGD envelope.

Once those exist, Stage 2's repository-side work is mechanical, and more of it
is in place than the stage numbering suggests. Each interface becomes:

- an entry in `schema/interfaces.json`, which generates the typedef into both
  languages;
- a checker at `rtl/if/<name>_if_checker.sv`, following
  `rtl/if/issue_if_checker.sv`, which carries the protocol properties, the
  satisfiability covers and the load-bearing event emission together;
- a `` `CCV_CHECKER `` instantiation at each boundary that uses it.

CCV-L12 then fails if a typedef has no checker or a control field goes
unreferenced, so the interface list and the checkers cannot drift apart.

**Two things to carry into that session, both from the spike:** a
request-to-response contract needs explicit tracking state, since no
multi-cycle construct exists in any tool (F-2), and every interface needs a
**justified N** for its bounded-latency property, because liveness cannot be
stated at all.

**Do not skip ahead to Stage 3.** The skeleton is built against Stage 2's
interface contracts, and §8 open item 6 is explicit that the block-swap
interface must be settled at Stage 2 because the skeleton's block boundaries
*are* the swap boundaries — retrofitting swappability means reworking every
interface.

---

## Part 1 — what is built

### Stage 1a — tool-support spike ✅

30 cases × 3 tools, plus three out-of-band probes. Every case is written so
the fixed stimulus violates it, because the cell that matters is not "does
this parse" but "does this bite" — a property that elaborates and never fires
looks exactly like one that passes.

- `spike/cases/` — the cases
- `tools/run-spike-1a.py` — the runner
- `docs/stage1a-tool-support.md` — the matrix (generated)
- `docs/stage1a-findings.md` — the eight findings (written)
- `tools/check-1a.sh` — cheap validation of the recorded matrix

### Stage 1b — assertion primitive library ✅

- `rtl/include/ccv_assert.svh` — the macros
- `rtl/ccv_assert_pkg.sv` — the runtime knob
- `test/smoke/ccv_assert_smoke.sv`, `tools/check-1b.sh`

### Stage 1c — event schema mechanism ✅

- `schema/events.json` — the source; `tools/gen-event-schema.py` — both headers
- `sim/include/ccv/event.h`, `sim/src/event.cpp` — the C++ emit API
- `sim/dpi/`, `rtl/include/ccv_trace.svh` — the DPI-C path
- `tools/trace2perfetto.py`, `tools/check-1c.sh`

### Stage 1d — coding style and lint ✅

- `docs/rtl-coding-style.md`, `tools/lint-rtl.py`, `rtl/lint/bad_module.sv`
- `params/ccv_params.json` + `tools/gen-params.py`
- `tools/check-1d.sh`

### Interface checker convention ✅ (mechanism)

`docs/interface-checker-convention.md`, scheduled as part of Stage 1d. All
five of its spike questions closed — four confirmed, one (`bind`) reversed.

- `schema/interfaces.json` + `tools/gen-interfaces.py` — typedefs into both
  languages, because the C++ boundary sees a packed signal with no field
  information (F-12)
- `rtl/include/ccv_if.svh` — modes, mode-resolved contracts, satisfiability
  covers, guarded emission
- `rtl/if/issue_if_checker.sv` — the reference checker. `issue_t` is the
  convention doc's own worked example, **not a proposed interface**; the real
  list follows from the Stage 2 partition.
- `tools/check-if.sh` — exit criteria
- CCV-L12 … CCV-L15 in the linter

**What is NOT done here:** the interface list, and the per-type checkers.
Those are Stage 2's, alongside the interface grill-me.

### Net naming convention ✅ (mechanism)

`docs/rtl-coding-style.md`, net naming section. Every net states what it is,
when it is valid, and which clock made it — which is what turns naming into
something a checker can reason about.

- `params/blocks.json` — domain and block letters
- CCV-L02 rewritten, CCV-L19 … CCV-L24 added
- `rtl/lint/bad_naming.sv` / `good_naming.sv`

**What is NOT done here:** the block letters. Single letters cap the partition
at 26 blocks minus reserved ones, and the list is Stage 2's. If the partition
needs more, the tag format has to widen — much cheaper to find now than after
a tree of RTL carries the tags.

### CI harness ✅

`tools/verify.sh` and `.github/workflows/ci.yml`. §8 puts this at Stage 1
rather than Stage 7 because on a solo project its absence compounds fastest.
The workflow deliberately holds no checks of its own: a check that lives only
in CI cannot be run before pushing, which is when it would save time.

---

## Part 2 — findings carried forward

The Stage 1a findings that land on **later** stages, so they are not
rediscovered there. Full text in `stage1a-findings.md`.

| Finding | Lands on | What it changes |
|---|---|---|
| **F-2** — no multi-cycle sequence construct exists in any tool | **Stage 2** | A request-to-response contract is an explicit tracking register plus a boolean property, so interface checkers are things to review rather than read. Deadlock freedom cannot be stated as liveness; it becomes a bounded-latency property, and **N must be justified per interface**. |
| **F-4** — interfaces cannot be block boundaries | **Stage 2**, 1d | Plain ports or packed structs. Settled, not preferred. |
| **F-8** — `$isunknown` cannot state the payload invariant under formal | **Stage 4a** | A block's reset line must pair every un-reset payload field with the valid bit guarding it, not merely name which state is un-reset. Without that pairing §7's third formal target cannot be stated. |
| **F-6** — Icarus and Verilator answer different X questions | **Stage 4c** | The Icarus X-pass is not redundant with Verilator's X-randomization. Spike cases 26 and 28 are the standing demonstration and should stay in the suite. |
| **F-3** — the assertion enable gate must be constant under formal | permanent | Spike case 29 is the standing regression. If the guard became a free variable, every property in the design would pass vacuously and nothing about the run would look wrong. |
| **F-9** — `bind` drops silently under Yosys | **before first synthesis** | Checkers are instantiated, so they are no longer excluded from synthesis for free. Recorded debt with no substitute. |
| **F-10** — a spike case can be confounded | permanent | A case may test exactly one construct outside the known intersection; anything else it needs comes from the all-three subset, or it is paired with a control. Cases 31/32 and 34/35 are those pairs. |
| **F-12** — struct field offsets are invisible at the C++ boundary | **Stage 2**, and every swap | The typedef is generated into both languages. The generator rejects interfaces wider than 64 bits, where the Verilated port stops being a single integer. |
| **F-13** — DPI is Verilator-only | **Stage 2** | The event stream has one witness; a bug in the emission path cannot be caught by cross-checking two simulators. Worth a deliberate test of that path. |

---

## Part 3 — open items

Carried from the strategy doc, with current status.

1. **Event taxonomy spec.** Mechanism ✅ at 1c. **Content pending**:
   load-bearing at Stage 2, arbitration-sensitive per block at 4a. The seed
   set in `schema/events.json` is provisional and marked as such.

2. **Arbitration policy spec.** Not started — per block at Stage 4a/4b, before
   that block's 4c RTL build. §5 is explicit this buys *temporal precedence,
   not independence*: written by the same person who then writes the model and
   the RTL, it does not make agreement into proof. What it delivers is a stable
   reference, so a policy change is a visible decision rather than silent drift
   in one implementation.

3. **Assertion primitive library + tool-support spike.** ✅ Both complete.

4. **4d correlation criterion for arbitration-sensitive events.** **Still
   open, and now more urgent than the strategy doc implies.** The doc notes
   this "wants settling before Stage 1c locks the schema". Stage 1c has
   shipped, so the position is: the schema's `classes` block records the
   criterion as OPEN and the event record carries no tolerance metadata. If
   the answer turns out to be a stated tolerance rather than exact match, the
   schema needs a field for it and the hash changes. **Settle before Stage 4a
   populates the first arbitration-sensitive events**, which is the last cheap
   moment.

5. **CI harness.** ✅ Standing, and accumulating exit criteria per stage.

6. **Timing model implementation details.** C++ decided; the event-driven
   scheduler is not built. The block-swap interface is blocked on the Stage 2
   partition, as §8 requires.

### Opened by Stage 1

7. **Is 25 NGD the Vmin-corner number or a nominal one?** (§2) Recorded in
   `params/ccv_params.json` as `CCV_NGD_BUDGET` with the question attached.
   §2 puts it at Stage 2, and it changes how much margin each block holds
   back: at 0.55 V, variation and the wire/gate delay ratio both worsen, so
   headroom at nominal does not translate linearly.

8. **What is the bounded-latency N for each interface?** Opened by F-2, since
   liveness cannot be stated. One number per interface, each needing a
   justification, at Stage 2.

9. **Block letters, and whether 26 is enough.** The stage tag gives the block
   one letter. The Stage 2 partition decides how many blocks there are; if it
   exceeds the registry, the tag format widens and every tagged net changes.
   Worth a sanity check as soon as the partition list is drafted.

10. **Synthesis exclusion for checkers.** `bind` provided it for free; F-9
   removed `bind`. Settle before the first synthesis attempt rather than at it.

11. **Direction discipline without modports.** Partly addressed — the direction
    is declared in `schema/interfaces.json` and carried into the generated
    header — but whether that is *adequate* will not be known until several
    real interfaces exist at Stage 2.

12. **Backpressure convention.** Provisionally the separate `_ready` signal,
    on the strength of F-12: folding backpressure into the struct would put a
    reverse-direction field inside a signal the swap harness drives one way.
    Wide return paths get their own reverse-direction struct. Revisit at Stage
    2 with real interfaces.

---

## Part 4 — dependency on the compiler track

§4 states this explicitly rather than leaving it to be discovered at a gate.
The walkthrough kernel corpus is an output of the LLVM backend bootstrap,
which runs on its own schedule in `custom-cuda-complier`.

- **Stage 3** needs a `vadd`-class kernel. **Available today** —
  `test/elementwise.s` and the walkthrough in the compiler repo.
- **Stage 6** needs the GEMM tile / reduction / elementwise set. **Not yet
  complete.** If the compiler effort lags, Stage 6 is gated on it.

Worth tracking as a cross-project dependency rather than discovering it at the
gate.

Note also that the functional simulator this project checks against is
`tools/ccv-sim` in the compiler repository, not `ccg-sim` — the target was
renamed from CCG to CCV at the v1.5 audit, and the strategy doc predates that.
It is the trusted functional oracle (§1), and Stage 3's exit criterion is
retiring architectural state identical to it.
