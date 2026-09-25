# Roadmap and handoff

Companion to [`rtl-execution-strategy.md`](rtl-execution-strategy.md), which is
the process contract. This file tracks what is actually built, what is next,
and what is carried.

---

## Part 0 — picking this up again

**State: Stage 1 complete and gated. Stage 2 under way — the block-level
grill-me closed the partition on 2026-09-23, and its topology is encoded.**

```
    ./tools/setup-toolchain.sh   # containers are ephemeral; this restores one
    ./tools/verify.sh            # green
```

**Review response.** The Stage 1 review raised thirteen items. Six are closed
in-repo (C-1, C-2, C-3, D-1, D-2, B-3); the rest need the partition list or a
planning decision and are carried in Part 3 below.

**To hand back to the planning track:**
[`rtl-findings-stage1.md`](rtl-findings-stage1.md) — what Stage 1 found about
the strategy, organised for that audience rather than this one.

**The grill-me has happened.** §8 Stage 2's interface-level session ran on
2026-09-23 and delivered the first three of the four things this repository was
waiting for. Their status now:

| Was waiting for | Status |
|---|---|
| The partition list | ✅ 14 block types, 45 instances, 40 channels — encoded in `params/blocks.json` and `schema/interfaces.json` |
| A block letter per block | ✅ 14 assigned, 2 reserved (`z` reset tree, `y` fixtures), 8 spare — **closes the 24-block ceiling question** |
| Per-block interface contracts | ✅ protocol, signal shape and **all 144 payload field widths** closed — 10 of 40 channels decided end to end, the rest on provisional or preliminary widths |
| Per-block interface NGD budgets | ❌ not started, against the 25 NGD envelope |

So the remaining input is **payload widths and NGD budgets**, not the
partition. The widths are per-block-session work and are listed by channel in
Part 3; they are deliberately not guessed here, because a generated typedef is
the thing downstream code trusts and a generated number gets believed.

Everything that does not depend on those widths is buildable now. Each
interface becomes:

- an entry in `schema/interfaces.json`, which generates the typedef into both
  languages;
- an instantiation of `rtl/if/ccv_credit_checker.sv` at each end, parameterised
  by payload width and the interface's round trip — the latter defaulted to
  the abutting minimum, so in practice only the width is passed.

**The checker is one implementation, not one per interface.** Every boundary
obeys the same conventions — credited, registered both sides, valid one cycle
ahead — so the protocol properties are identical and only the widths differ.
Since no multi-cycle SVA exists (F-2), each of those properties is an explicit
tracking register, which makes a single shared implementation worth far more
than it would be if they were declarative: written once, reviewed once, wrong
in one place at most.

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

**Do not skip ahead to Stage 3.** The skeleton is built against Stage 2's
interface contracts, and §8 open item 6 is explicit that the block-swap
interface must be settled at Stage 2 because the skeleton's block boundaries
*are* the swap boundaries — retrofitting swappability means reworking every
interface.

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
45 instances, 40 channels**. Encoded and machine-checked:

- `params/blocks.json` — the 14 block letters, 8 spare. **Closes A-2**: the
  single-letter stage tag holds and does not need widening.
- `schema/interfaces.json` — all 40 channels, the 11 common ports, and the
  four-signal channel shape. Per-block port lists are **derived** from the
  channel list rather than stated, since the source spec kept both and they
  disagreed.
- `params/ccv_params.json` — 56 machine parameters, each tagged `isa`,
  `arch`, `tunable`, `provisional` or `target`, so a sweep cannot silently
  vary something the compiler is built against. The 12 `provisional` ones
  generate into a **separate package** (`ccv_prov_pkg`, `ccv::prov::`), so a
  module referencing one is visibly unfinished at every use site — which is
  what stops a placeholder from being believed.
- `rtl/if/ccv_credit_checker.sv` — the one parameterised checker.
- `EV_CH_XFER` — the load-bearing event content §8 said would fall out of the
  interface grill-me. The 40-channel list **is** the load-bearing event list.

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
all 40 channels generate a struct. A third package, `ccv_prelim_pkg`, carries
the widths whose *encoding* is undecided — distinct from `ccv_prov_pkg`, where
only the number is. Each preliminary parameter also carries a **churn**
rating: high means a per-block session is likely to change the field's shape,
so code that pattern-matches on its contents will be rewritten, as against
code that merely carries it. See [`payload-spec.md`](payload-spec.md) and the
generated [`trust-report.md`](trust-report.md).

### Stage 3 — skeleton, S0 (plumbing) ✅

See [`skeleton.md`](skeleton.md). The whole machine — 45 block instances,
103 channel instances, 340 credited slots — wired from the schema, every block
running an exerciser stub, every slot judged by the real SV credit checker
Verilated in beside it. ~231k messages per 2000-cycle run, three seeds, zero
violations; each clean result paired with a control that must fail.

- `tools/gen-skel.py` — wiring tables, the checker bank, and a layout probe
  that reads all 144 fields back through the real SV structs
- `sim/skel/` — the two-phase machine, the protocol in one place, the stub
- `tools/check-skel.sh` — exit criteria, in the gate

**Next: S1, `vadd` end to end** against ccv-sim, which now builds here.
**Interface decisions (2026-09-24) built in:** independent slots confirmed,
with per-channel acceptance / ordering / binding; the external port is a pair;
instruction identity is a trace-only sideband with class, sub-index and replay
links. **To confirm:** atomic constrains valids as well as credits, and the
per-channel id-class assignment (both in `skeleton.md`).

### Interface checker convention ✅ (mechanism)

`docs/interface-checker-convention.md`, scheduled as part of Stage 1d. All
five of its spike questions closed — four confirmed, one (`bind`) reversed.

- `schema/interfaces.json` + `tools/gen-interfaces.py` — typedefs into both
  languages, because the C++ boundary sees a packed signal with no field
  information (F-12)
- `rtl/include/ccv_if.svh` — modes, mode-resolved contracts, satisfiability
  covers, guarded emission
- `rtl/if/ccv_credit_checker.sv` — the one parameterised checker, now driven
  by the real 40-channel topology rather than a worked example.
- `tools/check-if.sh` — exit criteria
- CCV-L12 … CCV-L15 in the linter

**What is NOT done here:** nothing, for wiring purposes — all 40 channels
have a full set of widths and generate a struct. What is not *decided* is
tiered and reported rather than missing. There are
no per-type checkers and there will not be: every boundary obeys the same
credited protocol, so one parameterised checker covers all 40, and the widths
are the only thing that differs.

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

Carried from the strategy doc, with current status.

1. **Event taxonomy spec.** Mechanism ✅ at 1c. **Load-bearing content ✅** —
   the 40-channel list *is* the load-bearing event list, emitted as
   `EV_CH_XFER` from the shared checker so every boundary emits identically
   and no per-block drift is possible. **Unit list ✅** — swapped from the
   strategy doc's illustrative names to the real 14 blocks, *derived* from
   `params/blocks.json` and checked against it, since two lists of the same
   thing disagree eventually and this one is read at every emit site. Done
   before Stage 3 rather than after: a unit id is baked into every event
   record, so fixing it later means re-tagging or discarding every trace.
   **Arbitration-sensitive content still pending**, per block at 4a.

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
   scheduler is not built. The block-swap interface was blocked on the Stage 2
   partition, which has now closed — so this is **unblocked and is the next
   real coding task**, alongside the Stage 3 skeleton.

### Opened by Stage 1

7. **Is 25 NGD the Vmin-corner number or a nominal one?** (§2) Recorded in
   `params/ccv_params.json` as `CCV_NGD_BUDGET` with the question attached.
   §2 puts it at Stage 2, and it changes how much margin each block holds
   back: at 0.55 V, variation and the wire/gate delay ratio both worsen, so
   headroom at nominal does not translate linearly.

8. **The bounded-latency N.** Opened by F-2, since liveness cannot be stated.
   **No longer per interface**: the round trip is 2 everywhere by
   construction, so N is one global provisional (`CCV_P_TIMEOUT_N`, 32) plus
   one for the memory path (`CCV_P_TIMEOUT_MEM`, 2048), which must exceed
   worst-case DRAM latency and which the local number does not. Both are in
   `ccv_prov_pkg` and both are **provisional by construction** per A-3 —
   revising them is an expected 4b output, not a spec change. What remains is
   the justification, which needs contention data that does not exist yet.

9. **A-1 — the 4d correlation criterion.** Unchanged and still the tightest
   window: the last cheap moment is before Stage 4a populates the first
   arbitration-sensitive events, after which changing the schema means
   reprocessing or discarding every trace captured. A decision, not an
   investigation.

10. **A-3 — N is provisional by construction.** (One global N, not one per
    interface — see item 8.) It cannot be justified at Stage 2; that needs
    contention data from 4b. Set it from architectural reasoning, record it as
    provisional, and schedule N-revision as an expected **4b output** rather
    than a spec change —
    without that framing, revisiting N later reads as a violation and creates
    friction against doing it. Each N ships with a case that exceeds it and
    must fire (see the fail-open register).

11. ~~**A-2 — do testbench-side memory interfaces consume block letters?**~~
    **Closed.** They do, and they are registered rather than left to collide:
    `y` is reserved for fixtures and `z` for the reset tree, which is not a
    design block but does need stage numbering because a synchronous reset
    cannot be delivered globally in one cycle. 14 design letters + 2 reserved
    leaves 8 spare.

12. **Clock-gating equivalence is unverified.** The gated netlist has never
   been proved against its ungated original — that needs a real ICG cell
   rather than a blackbox, and care about the gated clock not being a free
   variable. Nothing relies on it today. Settle before any synthesis result
   is believed. (F-18)

13. ~~**Block letters, and whether 26 is enough.**~~ **Closed** by the same
   pass as item 11 — the partition is 14 block types, so the single-letter tag
   holds with room to spare. Had it not, the tag format would have widened and
   every tagged net changed, which is exactly why this was worth checking
   against a draft list rather than after a tree of RTL carried the tags.

14. **Synthesis exclusion for checkers.** `bind` provided it for free; F-9
   removed `bind`. Settle before the first synthesis attempt rather than at it.

15. **Direction discipline without modports.** Direction is declared in
    `schema/interfaces.json` and carried into the generated header. 40 real
    interfaces now exist, so the question is answerable — but honestly, not
    yet answered: nothing has been *built* against them. The test is whether a
    block author can get a direction wrong and have it caught, and that is not
    known until the skeleton exists. Re-ask at the end of Stage 3, not before.

16. ~~**Backpressure convention.**~~ **Settled, and not the way Stage 1
    guessed.** The provisional answer was a separate `_ready` signal. The
    grill-me's answer is a **credited protocol**: four signals per channel —
    `_valid` and `_payload` from the producer, `_credit` and `_stall` from the
    consumer. Valid leads the payload by one cycle on every interface without
    exception, a credit is consumed when valid asserts rather than when the
    payload lands, and once asserted valid is binding.

    The Stage 1 reasoning still holds and is why the shape works: backpressure
    stays *outside* the packed struct, so the swap harness still drives the
    payload one way (F-12).

17. ~~**28 payload field widths.**~~ **Closed for wiring** by the payload
    pass (2026-09-25): every field has a width, all 40 channels generate a
    struct. What replaced it is a **tiering** problem rather than a blocking
    one — see [`payload-spec.md`](payload-spec.md) and the generated
    [`trust-report.md`](trust-report.md). 10 of 40 channels are decided end to
    end; 14 carry a provisional width, 16 a preliminary one.

    The pass also corrected four widths that were sized confidently and
    wrongly in the first encoding, which matters more than an open field
    because they generated a struct and nothing flagged them:

    | Field | Was | Now | Why |
    |---|---|---|---|
    | `warp_mask_released` | 5 | 32 | a mask, not an id — a release wakes a *set* |
    | `bank_addr` | 5 | 320 | 5 bits is a bank *index*; 32 banks means 32 independent word addresses |
    | `phys_pred` | `CCV_P_W_PHYS_REG` | `CCV_P_W_PHYS_PRED` | the predicate file is its own namespace with its own RAT |
    | `barrier_entries` | one index | `barrier_base` + `barrier_count` | allocation hands out a *range* |

    `bank_addr` was the worst: at 5 bits it does not merely get a number
    wrong, it assumes every lane shares one address and so deletes the
    bank-conflict model SPM exists to implement.

18. **The `src_arch` / `operand` mismatch.** `ccv_dec_ooe_uop` carries two
    source registers; `ccv_rcu_lane_ops` carries three operands. Either the
    third is the destination read back for accumulate — so rename must treat
    `dst_arch` as a source — or the ISA has true three-source operations and
    `src_arch` is one field short. `dp4`/`dp8` make the second likely. **An
    ISA question, not an RTL one.** It does not block the skeleton, since both
    sides already have a width; it blocks *coding rename* at 4a.

19. **RCU→MIU is ~8,400 wires.** `index_per_lane` (1024) beside `store_data`
    (1024) at rate 4, almost certainly the widest interface in the design. It
    argues for co-locating the AGUs with RCU, or moving address generation
    into the register read stage. A partitioning question that a width
    exposed, and block boundaries are swap boundaries — so settle it before
    floorplan, not after.

    Ranked by blast radius, since a field on several channels is one where two
    per-block sessions deciding independently produce two incompatible
    encodings on channels that abut:

    | Field | Channels | Where |
    |---|---|---|
    | `op` | 5 | dcu↔mlc, miu↔dcu, miu↔spm, mlc↔exb, … |
    | `asid` | 3 | fet↔miu itlb, fet↔mlc ifill, rau→fet launch |
    | `opcode` | 3 | dec→ooe uop, ooe→rcu issue, rcu→lane ops |
    | `pcs`, `pred_state` | 2 each | both directions of the pca↔rcu migration pair |
    | `size` | 2 | miu↔dcu, mlc↔exb |

    The remaining 22 are single-channel: `bank_select`, `byte_mask`, `class`,
    `code_bounds`, `conflict_serialization`, `cta_id`, `data`,
    `demotion_threshold`, `index_per_lane`, `itlb_refill`, `launch_block_addr`,
    `operand`, `ordering`, `ownership_class`, `prf_base`, `prf_size`,
    `progress_threshold`, `retired_since_restore`, `space`, `status`,
    `sub_width`, `tilelink_tlc`.

    `op`, `opcode` and `size` are worth settling **across** sessions rather
    than within one.

---

## Part 4 — dependency on the compiler track

§4 states this explicitly rather than leaving it to be discovered at a gate.
The walkthrough kernel corpus is an output of the LLVM backend bootstrap,
which runs on its own schedule in `custom-cuda-complier`.

- **Stage 3** needs a `vadd`-class kernel. **Available today** —
  `custom-cuda-complier/test/elementwise.s` and the walkthrough there.
- **Stage 6** needs the GEMM tile / reduction / elementwise set. **Not yet
  complete.** If the compiler effort lags, Stage 6 is gated on it.

Worth tracking as a cross-project dependency rather than discovering it at the
gate.

Note also that the functional simulator this project checks against is
`custom-cuda-complier/tools/ccv-sim`, not `ccg-sim` — the target was
renamed from CCG to CCV at the v1.5 audit, and the strategy doc predates that.
It is the trusted functional oracle (§1), and Stage 3's exit criterion is
retiring architectural state identical to it.
