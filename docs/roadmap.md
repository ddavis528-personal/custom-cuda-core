# Roadmap and handoff

Companion to [`rtl-execution-strategy.md`](rtl-execution-strategy.md), which is
the process contract. This file tracks what is actually built, what is next,
and what is carried.

---

## Part 0 — picking this up again

**State: Stage 1 complete. Stage 2 closed and encoded, except the
per-interface NGD budgets. Stage 3's skeleton has run `vadd` end to end (S1),
with the final state identical to ccv-sim's. Next: S2, a kernel that stresses
what vadd does not.**

```
    ./tools/setup-toolchain.sh   # containers are ephemeral; this restores one
    ./tools/verify.sh            # green
```

**To hand back to the planning track:**
[`rtl-findings-stage1.md`](rtl-findings-stage1.md) covers what Stage 1 found
about the strategy, organised for that audience rather than this one. The
Stage 1 review raised thirteen items; the ones still open are carried in
[`open-items.md`](open-items.md).

**What Stage 2 was waiting for, and what arrived.** The interface-level
grill-me ran on 2026-09-23. Here is each input's status:

| Was waiting for | Status |
|---|---|
| The partition list | ✅ 14 block types, 45 instances, 40 channels — 46 now: the external port became an out/in pair, branch redirect added `ccv_ooe_fet_redirect`, the PC groups migrate on a FET↔PCA pair, and migration gained a RAU→FET command and a PCA→RAU done (Q-30). Encoded in `params/blocks.json` and `schema/interfaces.json` |
| A block letter per block | ✅ 14 assigned, 2 reserved (`z` reset tree, `y` fixtures), 8 spare — **closes the 24-block ceiling question** |
| Per-block interface contracts | ✅ protocol, signal shape, slot attributes and **all 200 payload field widths**. 8 of 46 channels are decided end to end; the rest are on provisional or preliminary widths, tiered and reported |
| Per-block interface NGD budgets | ❌ not started, against the 25 NGD envelope |

**Next, in order:**

1. **S2: a kernel that stresses what vadd does not.** vadd has no divergence,
   no loop, one warp, and no SPM or barriers, so 20 of the 46 channels carried
   nothing in S1. Kernels that exercise them come from the compiler corpus
   (Part 4). Several are blocked on open payload questions, at least in the
   form S1 worked around (Q-30).
2. **The open items in [`open-items.md`](open-items.md).** Most are owned
   by the per-block sessions, the planning side and the ISA track rather
   than this repository, and each one says what it blocks. The correlation
   criterion is settled: exact match (Q-5).

**The checker is one implementation, not one per interface.** Every boundary
obeys the same conventions — credited, registered both sides, valid one cycle
ahead — so the protocol properties are identical and only the widths differ.
Since no multi-cycle SVA exists (F-2), each of those properties is an explicit
tracking register, which makes a single shared implementation worth far more
than it would be if they were declarative: written once, reviewed once, wrong
in one place at most. Two further checkers span slots and instances rather
than interface types: atomic acceptance across a channel's slots, and
lockstep across the 32 lanes.

### What a new design file has to carry

Twenty-six lint rules is more than anyone will hold in their head, so the
obligations that are not obvious from reading existing code:

```systemverilog
//===-- sched_iq.sv - issue queue ---------------------------------------===//
//
// Spec: docs/blocks/scheduler-4a.md        <- CCV-L11, the Stage 4a spec
// Block: scheduler                          <- CCV-L21, checked against
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"

`define CCV_CLK sched_core_clk              <- CCV-L02
`define CCV_RST sched_rst_r06h

module sched_iq ( ... );                    <- CCV-L01, filename must match

  // The block gates its clock as its first act -- CCV-L22 forbids clocking
  // anything on the ungated core_clk.
  assign sched_core_clk = core_clk & sched_gate_en_cs00h;

  // Every CONTROL input used in an if or a case needs one of these, or the
  // case needs an X-default -- CCV-L08.
  `CCV_ASSERT_KNOWN(iq_push_known, iq_push_cs00h)

  ...

endmodule

`undef CCV_CLK                              <- CCV-L02, or the next file
`undef CCV_RST                                 inherits this one's clock
```

A **reusable** module — a checker or a primitive, instantiated inside many
blocks — declares `// Reusable: <why>` instead of `// Block:`, takes
`clk`/`rst` as generic formals, and is exempt from the clock-naming and stage
rules. `rtl/if/ccv_credit_checker.sv` is the worked example.

Run `tools/lint-rtl.py <file>` while writing; it is fast and the messages
name the rule, which the style guide then explains.

**Two things to carry into that session, both from the spike:** a
request-to-response contract needs explicit tracking state, since no
multi-cycle construct exists in any tool (F-2), and every interface needs a
**justified N** for its bounded-latency property, because liveness cannot be
stated at all.

**Keep the swap boundary fixed.** §8 open item 6 is explicit that the skeleton's
block boundaries *are* the swap boundaries, so retrofitting swappability means
reworking every interface. A payload change goes through the schema, and the
S0 checks re-prove the wiring. It never goes through a stub.

---

## Part 1 — what is built

### Stage 1a — tool-support spike ✅

36 cases × 3 tools, plus 5 out-of-band probes. Every case is written so
the fixed stimulus violates it, because the cell that matters is not "does
this parse" but "does this bite" — a property that elaborates and never fires
looks exactly like one that passes.

- `spike/cases/` — the cases
- `tools/run-spike-1a.py` — the runner
- `docs/stage1a-tool-support.md` — the matrix (generated)
- `docs/stage1a-findings.md` — the 18 findings F-1…F-18 (written)
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

### Stage 2 — partition closed, topology encoded ✅

The block-level grill-me (2026-09-23) closed the partition: **14 block types,
45 instances, 40 channels** (46 now: the external port pair, branch
redirect, and two migration pairs). Encoded and machine-checked:

- `params/blocks.json` — the 14 block letters, 8 spare. **Closes Q-9 and
  Q-11**: the single-letter stage tag holds and does not need widening.
- `schema/interfaces.json` — all 46 channels, the common ports, and the
  four-signal channel shape. Per-block port lists are **derived** from the
  channel list rather than stated, since the source spec kept both and they
  disagreed.
- `params/ccv_params.json` — 95 machine parameters, each tagged `isa`,
  `arch`, `tunable`, `target`, `provisional` or `preliminary`, so a sweep
  cannot silently vary something the compiler is built against. The 21
  `provisional` and 22 `preliminary` ones generate into **separate packages**
  (`ccv_prov_pkg`, `ccv_prelim_pkg`), so a module referencing one is visibly
  unfinished at every use site — which is what stops a placeholder from being
  believed.
- `rtl/if/ccv_credit_checker.sv` — the one parameterised checker.
- `EV_CH_XFER` — the load-bearing event content §8 said would fall out of the
  interface grill-me. The channel list **is** the load-bearing event list.

**Round trip: closed.** Flops on both sides with no exceptions, plus
abutment, gives exactly 2 — it is not a per-block choice, so credit depth,
rescue depth and drain wait are not three numbers but one number under three
names, all 2 today, with wake at 4. It nonetheless stays a **per-instance
parameter**, defaulted to that minimum: a non-abutting interface would differ,
and none is known to be non-abutting until floorplan. Nothing is expected to
override it before then, and the default is what makes the override a local
one-line change rather than a sweep.

Two `CCV_IF_CONFIG` checks in the checker enforce that the derived numbers
still cover the round trip. Both guard misconfigurations that break no
protocol rule — a short depth throttles the channel and looks like healthy
backpressure; a short timeout fires on a channel behaving perfectly — so
nothing else would catch either, and `tools/check-if.sh` builds each
misconfiguration to prove the check still bites.

**Payload widths: closed enough to build on.** Every field has a width, so
all 46 channels generate a struct. A third package, `ccv_prelim_pkg`, carries
the widths whose *encoding* is undecided — distinct from `ccv_prov_pkg`, where
only the number is. Each preliminary parameter also carries a **churn**
rating: high means a per-block session is likely to change the field's shape,
so code that pattern-matches on its contents will be rewritten, as against
code that merely carries it. See [`payload-spec.md`](payload-spec.md) and the
generated [`trust-report.md`](trust-report.md). The partitioning response
(2026-09-25) added `req_id` on every request/response pair, sized per hop,
and `active_mask` on the memory path; see
[`skeleton.md`](skeleton.md#payload-spec-response-2026-09-25-as-built).

The pass also corrected four widths that were sized confidently and wrongly
in the first encoding. That matters more than an open field, because each
generated a struct and nothing flagged it:

| Field | Was | Now | Why |
|---|---|---|---|
| `warp_mask_released` | 5 | 32 | a mask, not an id — a release wakes a *set* |
| `bank_addr` | 5 | 320 | 5 bits is a bank *index*; 32 banks means 32 independent word addresses |
| `phys_pred` | `CCV_P_W_PHYS_REG` | `CCV_P_W_PHYS_PRED` | the predicate file is its own namespace with its own RAT |
| `barrier_entries` | one index | `barrier_base` + `barrier_count` | allocation hands out a *range* |

`bank_addr` was the worst: at 5 bits it doesn't merely get a number wrong. It
assumes every lane shares one address, and so deletes the bank-conflict model
SPM exists to implement.

### Stage 3 — skeleton ✅ S0 (plumbing), ✅ S1 (`vadd`)

See [`skeleton.md`](skeleton.md).

**S0.** The whole machine is wired from the schema: 45 block instances, 108
channel instances, 345 credited slots. Every block runs an exerciser stub, and
every slot is judged by the real SV credit checker Verilated in beside it. A
2000-cycle run carries ~151k messages, and three seeds give zero violations.
Each clean result is paired with a control that must fail it.

- `tools/gen-skel.py` — wiring tables, the checker bank, and a layout probe
  that reads all 200 fields back through the real SV structs
- `sim/skel/` — the two-phase machine, the protocol in one place, the stubs
- `tools/check-skel.sh` — exit criteria, in the gate

**S1 — `vadd` end to end.** It runs on functional stubs over the real
channel path in 355 cycles. The final register file and memory are identical
to ccv-sim's, with 0 interface violations, and each clean result is paired
with a control that must fail it (`tools/check-kernel.sh`). It found six
payload gaps, including store data missing from `ccv_miu_dcu_req` (added
provisionally), and a `mayLoad`/`mayStore` bug in the compiler (compiler F-141). See
[`skeleton.md`](skeleton.md#s1--vadd-through-the-machine).

- `sim/skel/kernel.cpp`, `oracle.cpp` — the functional stubs and the reader
  for ccv-sim's `-oracle` records
- `test/kernels/`, `tools/gen-oracle.sh`, `tools/compiler.lock` — the S1
  kernels' sources, and their ccv-sim oracle records generated each run from
  a pinned compiler snapshot
- `tools/check-kernel.sh` — exit criteria, in the gate

**Interface decisions (2026-09-24, revised 2026-09-25) built in:**
independent slots with per-channel acceptance, binding (with groups) and an
ordering *key*; an instance-level `lockstep` attribute for the lane channels,
checked across all 32 lanes including the instruction id per slot; the
external port is a pair; instruction identity is a trace-only sideband.
Atomic covers valids and credits (confirmed). The fet→dec binding is checked
through `tier1_id`, and FET's single ITLB miss is asserted by a pair checker.
**Skeleton review response (2026-09-25) built in:** `issue_mask` and
`active_mask` as two fields, three source registers, displacement and scale
to MIU's AGU, ALU immediates substituted by RCU, kill broadcast from RAU,
wake per channel, CSR from CRU, and TL-C beats on the link. See
[`skeleton.md`](skeleton.md#skeleton-review-response-2026-09-25-as-built).

### SV top ✅ (structure)

`rtl/top/` — generated and tracked: 45 stub blocks wired by the 108 channel
instances, each block's port list generated and included, the shared checker
bank under `CCV_CHECK`. Clean in all three tools. Its connectivity, extracted
from the elaborated netlist, equals the C++ skeleton's bit for bit. See
`skeleton.md`, "The SV top", for the common-port gaps it exposed.

### Interface checker convention ✅ (mechanism)

`docs/interface-checker-convention.md`, scheduled as part of Stage 1d. All
five of its spike questions closed — four confirmed, one (`bind`) reversed.

- `schema/interfaces.json` + `tools/gen-interfaces.py` — typedefs into both
  languages, because the C++ boundary sees a packed signal with no field
  information (F-12)
- `rtl/include/ccv_if.svh` — modes, mode-resolved contracts, satisfiability
  covers, guarded emission
- `rtl/if/ccv_credit_checker.sv` — the one parameterised checker, now driven
  by the real topology (one instance per slot) rather than a worked example.
- `rtl/if/ccv_atomic_checker.sv`, `ccv_lockstep_checker.sv` — the two
  checkers that look across slots and across lane instances.
- `tools/check-if.sh` — exit criteria
- CCV-L12 … CCV-L15 in the linter

**What is NOT done here:** nothing, for wiring purposes — all 46 channels
have a full set of widths and generate a struct. What is not *decided* is
tiered and reported rather than missing. There are no per-type checkers and
there will not be: every boundary obeys the same credited protocol, so one
parameterised checker covers every channel, and the widths are the only thing
that differs.

### Net naming convention ✅ (mechanism)

`docs/rtl-coding-style.md`, net naming section. Every net states what it is,
when it is valid, and which clock made it — which is what turns naming into
something a checker can reason about.

- `params/blocks.json` — domain and block letters
- CCV-L02 rewritten, CCV-L19 … CCV-L24 added
- `rtl/lint/bad_naming.sv` / `good_naming.sv`

**Block letters: assigned, and the ceiling held.** The partition came in at 14
block types, so with `z` (reset tree) and `y` (fixtures) reserved there are 8
spare letters and the single-letter tag format stands. This was the cheap
check worth doing before a tree of RTL carried the tags; it passed, and the
question is closed rather than carried.

### Clock gating (exploratory) ✅

`synth/` + `tools/check-clockgate.sh`. Synthesis is deferred (§6) and nothing
depends on this; it exists because the coding rules are written for where the
flow is going, and a direction with no artifact behind it drifts.

Yosys has no `clockgate` pass, so a techmap rule stands in for one. Measured:
enable inferred, gate substituted, and one ICG shared across an 8-bit register
rather than one per bit — which is the part that matters and the part a real
pass would have to do (F-18).

**Possible upstream contribution.** If it gets that far, the sharing is the
pass, not the substitution: group flops by enable, clock and reset; pick a
minimum group width; keep reset on the data path. Recorded in F-18 while the
reasoning is fresh.

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

**Moved to [`open-items.md`](open-items.md),** where each item has a running
number (Q-n) that is never renumbered or reused, so a review round can say
"Q-21" instead of "item 4 of the latest five". Closed items stay there with
their resolution. `tools/check-docs.sh` checks that the numbering has no
holes, that the summary matches the rows, and that the schema's
`open_questions` agree with it. The old per-list numbers (this part's items
1–20, the strategy doc's §8 items) are mapped at the bottom of that page.

---

## Part 4 — dependency on the compiler track

§4 states this explicitly rather than leaving it to be discovered at a gate.
The walkthrough kernel corpus is an output of the LLVM backend bootstrap,
which runs on its own schedule in `custom-cuda-complier`.

- **Stage 3** needed a `vadd`-class kernel: `custom-cuda-complier/test/elementwise.s`.
  **Used by S1.** Its ccv-sim `-oracle` record is generated each gate run
  from the compiler snapshot pinned in `tools/compiler.lock`: a commit on the
  compiler repo's `release` branch, carrying a built `ccv-sim`. A compiler
  change reaches this gate only through a reviewed bump. S2's kernels come
  from the same corpus.
- **Stage 6** needs the GEMM tile / reduction / elementwise set. **Not yet
  complete.** If the compiler effort lags, Stage 6 is gated on it.

Worth tracking as a cross-project dependency rather than discovering it at the
gate.

Note also that the functional simulator this project checks against is
`custom-cuda-complier/tools/ccv-sim`, not `ccg-sim` — the target was
renamed from CCG to CCV at the v1.5 audit, and the strategy doc predates that.
It is the trusted functional oracle (§1), and Stage 3's exit criterion is
retiring architectural state identical to it.
