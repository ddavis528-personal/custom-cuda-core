# RTL coding style

**§8 Stage 1d.** Written before the first line of design RTL exists, because
§9 is right that retrofitting style across built blocks is the expensive path
and rules added late mostly generate backlog rather than catching bugs.

Enforced by `tools/lint-rtl.py`, not by discipline. Every rule below carries
its lint id, and `tools/check-1d.sh` fails if a rule exists without a
counter-example in a `rtl/lint/bad_*` fixture or without a paragraph here — so
the guide, the linter and the fixture cannot drift apart.

Most of this is ordinary discipline. §9 flags two parts as **load-bearing**:
they hold up machinery this project depends on, and getting them wrong costs
more than style violations normally do. Those are marked.

---

## Enforcement, and what enforces what

Four layers, deliberately not one:

| Layer | Covers | Why not the others |
|---|---|---|
| `tools/lint-rtl.py` | CCV-L01 … CCV-L28 below | Project rules. The central one (CCV-L08) is a *relationship* between a case selector and an assertion elsewhere in the file, which no stock rule set expresses. |
| `verilator --lint-only` | width mismatches, inferred latches, unused and undriven signals, unsupported constructs | Already excellent at these. Reimplementing them would be strictly worse. |
| The three tools themselves | anything that fails to parse | The tool-support intersection is narrow (Stage 1a), so "it compiles everywhere" is a real check, not a formality. |
| `tools/check-cg.py` | CG-1 … CG-3, local clock gating (below) | Two of the three are measurements, not syntax: an enable's depth in a synthesised netlist and its efficiency in simulation. Lint sees neither. |
| `tools/check-ngd.py` | NGD-1 … NGD-4, logic depth (below) | A measurement of the mapped netlist: the stage, each module port against its budget, and the assembled block. |

**On Verible.** §6 adds it as a fourth tool and says "lint enforces it" is
load-bearing for the whole X-safety approach. That second part is right and
this guide depends on it; the fourth tool is not. Stage 1a found Verible
unobtainable here and, more to the point, found the dependency poorly
motivated: CCV-L08 was never expressible in stock rules, so custom rules would
have had to be written against Verible's API regardless. The rules are the
artifact; the tool is an implementation detail. See finding F-5.

### Scopes

Not every rule applies to every file, and pretending otherwise is how a lint
layer gets switched off wholesale.

- **design** — `rtl/`, excluding `include/`, `generated/` and `lint/`.
  Everything applies.
- **tb** — `test/`, `spike/tb/`. `initial` blocks, delays and DPI imports are
  what testbenches are *for*.
- **probe** — `spike/cases/`. Tool probes whose job is to write deliberately
  non-portable assertions and find out what each tool does with them. Linting
  them for style would be linting the measurement instrument. Only CCV-L10
  applies, because a metacomment collision breaks the probe itself.

A single file may opt out:

    // ccv-lint: exempt CCV-L03 -- <why>

The reason is required. An exemption without one is a rule quietly disabled,
which is worse than no rule at all because it still looks enforced.

---

## Load-bearing: names and parameters are cross-language artifacts

§9: every signal and structure exists twice, once in the C++ timing model and
once in RTL, and §5 correlation diffs them against each other.

### Naming must be mechanically consistent across both

A signal that is `iq_issue_valid` in RTL and `issueValid` in the model imposes
a translation tax on every 4d debug session, permanently.

*Mechanically consistent* is not the same as *identical*. Each language keeps
its own idiom; what has to be total and reversible is the **mapping**:

| Artifact | RTL | C++ |
|---|---|---|
| parameter | `CCV_ROB_ENTRIES` | `ccv::kRobEntries` |
| event id | `CCV_EV_ISSUE` | `ccv::EV_ISSUE` |
| signal | `iq_issue_valid` | `iq_issue_valid` |

Signals keep `lower_snake_case` in both, so no mapping is needed at all for
the things §5 diffs most often. Parameters and event ids are generated
(below), so their mapping is applied by a script rather than by whoever writes
the next block.

Event schema **field names** are covered by this rule too, per §9. They live
in `schema/events.json` and reach both languages from there.

### Parameters need a single source of truth — a mechanism, not a convention

§9 is explicit that this is a mechanism decision. The reason is specific: ROB
depth exists as a swept knob in the timing model (Stage 4b) *and* as an RTL
parameter, nothing otherwise prevents them from drifting, and drift means a
correlation run silently comparing two differently-sized machines — a failure
that presents as a timing bug.

`params/ccv_params.json` is the source. `tools/gen-params.py` generates both
`sim/generated/ccv_params.h` and `rtl/generated/ccv_params_pkg.sv`.
`tools/verify.sh` fails if either is stale, and `tools/check-1d.sh` compares
the *values* in both languages against the source — which is the check that
would actually catch the failure §9 describes.

**Never write a structural constant in RTL or in the model.** Add it to the
source and regenerate.

Parameters carry a `status`, and the distinction matters as much as the value:

- `isa` — follows from the locked ISA. **Not ours to sweep**; the compiler
  already depends on it.
- `arch` — decided at a design session. Traceable, and not expected to move.
- `provisional` — a placeholder awaiting the stage named in `decided_at`
  (Stage 4a sizes it, 4b sweeps it). **The number moves.**
- `preliminary` — a width good enough to *wire*, for a field whose encoding is
  not decided at all. **The field's shape may move.**
- `tunable` — expected to move once the timing model runs.
- `target` — a physical target such as the 25 NGD envelope, not a structure
  size.

A sweep that varies an `isa` parameter is varying something the compiler is
built against. The status field is what makes that visible.

### Three packages, because the tier has to be visible at the use site

Status is not just metadata: it picks which package the parameter is
generated into, and the package name appears at every reference.

| Package | C++ | Meaning | What moves |
|---|---|---|---|
| `ccv_params_pkg` | `ccv::` | follows from a settled decision | nothing |
| `ccv_prov_pkg` | `ccv::prov::` | a sizing placeholder | the number |
| `ccv_prelim_pkg` | `ccv::prelim::` | no decided encoding at all | the field's **shape** |

So `ccv_prelim_pkg::CCV_L_W_OPCODE` announces itself as unfinished wherever it
is read, not merely where it is declared. That is the whole mechanism — a
comment next to the declaration is a comment nobody re-reads at the use site.

**The bottom two tiers are genuinely different obligations, which is why they
are not one package.** `provisional` says *we will pick a number*;
`preliminary` says *we do not yet know what this field is*. Collapsing them
would lose exactly the distinction a skeleton author needs.

### Churn: what you may safely do with a preliminary field

Every `preliminary` parameter carries a churn rating, and it rates the
**field**, not the number:

- **low** — only the number moves. Carrying it, storing it and comparing it
  for equality are all safe.
- **med** — the encoding is likely to gain or lose codes.
- **high** — the field's shape is likely to change. **Code that
  pattern-matches on its contents will be rewritten**; code that merely
  carries it end to end will not.

The practical rule for the Stage 3 skeleton: *carry* preliminary fields
freely, *decode* them only where the skeleton would be pointless without it,
and never build control flow on a high-churn field's contents. `opcode`,
`operand` (`CCV_L_OPERANDS_PER_LANE`), `pcs` (`CCV_L_PC_GROUPS`),
`pred_state` and the external port's `tl_out`/`tl_in` are the high-churn ones
today; `docs/trust-report.md` is generated on every gate run and lists them
with everything that references them.

## Load-bearing: interface style constrains block-swap feasibility

**Settled, and not by preference.** §9 left this open, hedging toward plain
ports as the "safer default". Stage 1a closed it (finding F-4):

    %Error-UNSUPPORTED: Unsupported: Interfaced port on top level module

§2 makes block boundaries swap boundaries, and §1's swap mechanism requires a
hand-written C++ timing-model block and a Verilated RTL block to sit behind
the same interface in one executable — which means the boundary must Verilate
as a top-level module. SystemVerilog interfaces are refused at exactly that
boundary. Interfaces *inside* a block do work, but the one place they would
have paid is the one place they cannot be used.

**Rule (CCV-L09): plain ports, with consistent suffix conventions.** Packed
structs are fine and worth using where a boundary carries many related
signals — a struct port does Verilate. The `interface`/`modport` construct
does not.

Boundary ports follow the credited channel shape (the block-level grill-me),
named by CHANNEL, so instantiation and the swap harness stay mechanical and a
port reads the same in RTL, in the C++ skeleton and in the event schema. One
group of ports per SLOT, the payload typed:

    <chan>[_c<NN>][_s<K>]_valid     producer; one cycle ahead of the payload
    <chan>[_c<NN>][_s<K>]_payload   producer; typed ccv_<chan>_t
    <chan>[_c<NN>][_s<K>]_credit    consumer; credit return
    <chan>[_c<NN>][_s<K>]_stall     consumer; stall-invalidate
    <chan>[_c<NN>][_s<K>]_tid       producer; trace identity, ONLY under CCV_TRACE
    <chan>[_c<NN>]_wake             producer; one per channel instance

`<chan>` is `<src>_<dst>_<what>`, the channel's name without `ccv_`. Each
suffix appears only when its dimension exists: `_s<K>` on a channel of rate
above 1, `_c<NN>` (two digits) on a replicated channel where the name
refers to ONE of its copies. RCU, which owns all 32 lanes' copies, has
`rcu_lane_ops_c05_payload` (rate 1, so no `_s<K>`); the lane that IS copy 5
has `rcu_lane_ops_payload`, and the top's net is `rcu_lane_ops_c05_payload`.
A rated channel adds the slot: `ooe_rcu_issue_s2_payload`.
A slot's four signals share one prefix, so the group is found by name.

Per slot rather than an array of structs, deliberately: a packed array of
packed structs as a port is the one form Yosys 0.33 accepts and gets wrong
(CCV-L26, below).

(An earlier version of this section described a `_ready` handshake. The
grill-me replaced it with credits; the section had not caught up.)

**Boundary ports carry no stage tag.** Stage numbers are assigned per block at
4a, and a port name must not change when a block is retimed. The tag belongs
on the internal flop that drives the port: inside FET, `fet_dec_instr_valid`
is driven by something like `fet_dec_instr_valid_cf05h`. This matches the
rule that the stage tag is an implementation attribute rather than part of a
signal's identity (*Where the stage tag lives*, below).

**A block's port list is generated, never written.** `rtl/top/ports/
ccv_<blk>_ports.svh` is included between the parentheses of the module
header — in the stub and in the real RTL alike — so the two cannot disagree
on a port, and swapping one for the other is a file-list change.

---

## The rules

## Net naming

Every net's name states what it is, when it is valid, and which clock made it.
That last part is what turns naming from a readability convention into
something a checker can reason about — the stage tag is why CCV-L21 and
CCV-L23 exist at all.

### The shapes

```
signals   <name>[_<stage>][_n|_b]      iq_issue_valid_cs03h
                                        iq_flush_cs03h_n
                                        iq_en_cs03h_b

clocks    [<block>_]<domain>_clk[_b]   core_clk           top level
                                        sched_core_clk     gated, per block
                                        test_clk           async: no `core`
                                        sched_core_clk_b   inverted

reset     <block>_rst_r<NN><l|h>       sched_rst_r06h

enables   <name>_en[_<stage>][_n|_b]   ld_en_cs00h        a clock enable:
                                        pay_en             what an always_ff's
                                                           `if` gates on

stage     <domain><block><NN><l|h>     c = core domain
                                        s = scheduler block
                                        03 = pipe stage
                                        h = posedge (l = negedge)
```

All lowercase, underscore-separated. Only parameters and localparams carry
upper case.

**`_n` and `_b` are always the outermost suffix**, after the stage tag. Mildly
ugly, and too entrenched to change.

- **`_n`** — the signal is *defined* active-low. A semantic property; carries
  no obligation a checker could test.
- **`_b`** — the *complement* of a value that also exists. CCV-L24 requires it
  to be driven through an inversion.

### The domain segment is the second-to-last segment of a clock name

`sched_core_clk` → `core`. `test_clk` → `test`. That placement is deliberate:
it makes "`_core_` means synchronous to the core domain" a **mechanical**
property rather than a reading convention, so lint can check it and an
asynchronous clock cannot accidentally be named as though it were synchronous.

Registered in `params/blocks.json`, along with the block letters.

### Reset has its own numbering space

A synchronous reset cannot be delivered globally in one cycle. It is pipelined,
balanced so de-assertion arrives everywhere on the same cycle, and how deep it
is when it reaches a block depends on physical distance.

So reset nets carry block letter **`r`**: `sched_rst_r06h` reads as "six stages
into the reset tree", and cannot be confused with a datapath signal at stage 6.
**Reset nets take no part in stage arithmetic** — their depth measures distance,
not datapath.

### Where the stage tag lives, and where it does not

- **On the net, never on a struct field.** An `issue_t` may be instantiated at
  stage 3 in one place and stage 7 in another, so the type cannot carry a
  stage. The field stays `valid`; the net is `iq_iss_cs03h`, referenced as
  `iq_iss_cs03h.valid`.
- **Not in the C++ timing model.** §9 keeps signal names identical across the
  two languages so §5 correlation needs no mapping, and the stage tag is an
  *implementation attribute*, not part of a signal's identity. Correlation
  matches the base name and carries the tag as metadata. A retimed RTL
  therefore still correlates against an unchanged model — which is the point,
  not a concession. **Event-schema field names carry no stage tags.**
- **Not on a common module's formals.** See *Module names* below.

### CCV-L28 — module names: a module's name says what it is

No comment says what a module is; its name does (DA's response OI-37). Every
module in `rtl/` takes exactly one of six shapes, each decidable from the name
and the block list in `params/blocks.json` alone:

| Shape | What it is | Its gate (CCV-L22) | Today |
|---|---|---|---|
| `ccv_<block>` | a block's top | gates `core_clk`, once | `ccv_ooe` |
| `ccv_<block>_w` | its hardening wrapper: the block and its repeaters, nothing else | none | `ccv_lane_w` |
| `<block>_<name>` | a sub-block, inside one block | none: runs on `<block>_core_clk` | `ooe_pick` |
| `ccv_common_<type>[_<name>]` | a common module, shared across blocks | none | `ccv_common_clk` |
| `<block>_common_<type>[_<name>]` | a common module within one block | none | — |
| `ccv_top` | the core top, the one named exception | gates, if it ever holds logic | `ccv_top` |

Anything else is a finding. A wrapper may carry a tag after `_w`: `_v<N>` for
a hard-reuse template, `_<NN>` for one instance's own wrapper (one with
feedthroughs), so every wrapper's name starts `ccv_<block>_w`. The generated
design (`rtl/top/`, `rtl/generated/`) takes the same shapes, checked by a pass
of its own since the per-file walk skips generated files. Testbenches and
harnesses are outside the namespace: they live in `test/`, `spike/` and
`sim/generated/`, and name themselves (`tb_*`).

**Why names, not markers.** `// Block:` and `// Reusable:` used to declare
this, and `// Ctech:` a ctech cell. A marker is a pragma a reader has to go
and find; a name is read at every instance, and a mistake in it shows at the
use site. So it stays **declared, never inferred**: inferring "common" from
"the clock is not named like a clock" would let every non-compliant file
exempt itself by being non-compliant.

**The block list is part of the rule.** A block name is one lowercase token,
since every shape splits at the first underscore: a block named `ooe_w` would
make OOE's wrapper read as a block top. `common` and `top` are not block
names, or `ccv_common_clk` and `ccv_top` would read as block tops. Where a
block states its `module`, it is `ccv_<name>`. The lint refuses each of these
in `params/blocks.json`.

**What the name gives the other rules:**

- A block top, wrapper or sub-block belongs to its block, whose letter is what
  CCV-L21 checks a stage tag against.
- A common module takes `clk`/`rst` as generic formals and is exempt from the
  clock-naming and stage rules: one instance of it lives inside many blocks and
  binds to each one's own uniquified clock, so a formal named for one block
  would read as a lie in every other.
- A common module's type is what some rules key on: `chk` is an interface
  checker (CCV-L14, CCV-L15), `ctech` a ctech cell (CCV-L27). Today's common
  modules are `ccv_common_clk` (the clock gate), `ccv_common_rpt` (the
  sequential repeater), `ccv_common_ctech_icg` (the ICG, one definition per
  view), `ccv_common_chk_<kind>` (the six channel checkers) and
  `ccv_common_chk_bank` (the generated checker bank).

The counter-examples are `rtl/lint/bad_module_names.sv` and
`rtl/lint/bad_blocks.json`, and `tools/check-1d.sh` looks for each one's
refusal by its own name. The compliant side is one fixture per shape, all of
the lint fixtures' own block `reference`: `ccv_reference.sv`,
`ccv_reference_w.sv`, `reference_gated_enable.sv` and
`reference_common_xprop.sv`.

### CCV-L02 — every macro user names its own clock and reset

There is no single clock name the assertion macros can hardcode. Each block
gates `core_clk` on entry and uses the uniquified result, so `sched_core_clk`
and `alu_core_clk` are different nets; reset is worse, since which stage of the
distribution tree reaches a block depends on physical distance.

So each file supplies its own:

```systemverilog
`define CCV_CLK sched_core_clk
`define CCV_RST sched_rst_r06h
  ... module body, `CCV_ASSERT(...) as usual ...
`undef CCV_CLK
`undef CCV_RST
```

The inner macros expand at *use* time, so each file genuinely gets its own
clock — verified in all three tools. **The `` `undef `` is required**: a macro
outlives the file in a shared compilation unit, and without it the next file
silently inherits this one's clock. Use the `_AT` forms directly for a module
needing two clocks, which under §6 should not exist outside DFT.

### CCV-L19 — lower_snake_case

Only parameters and localparams carry upper case.

### CCV-L20 — clocks are named as clocks, and used only as clocks

A net driving a clock edge must match the clock shape, and its domain segment
must be registered. Conversely a clock may appear only in an edge expression
or a port map — the block's gate is `ccv_common_clk`'s `gclk` port, which is the
whole reason `<block>_core_clk` exists. Anywhere else is a clock read as data.
A clock built from a clock with logic is CCV-L27's business: only a ctech cell
does that.

**How an assignment is read.** CCV-L20, L23 and L24 all read assignments,
and read as a pattern a comparison looks like one: `a == b`, or `a <= b` in
a condition or a macro call. The lint counts neither. An `=` that starts
`==` is a comparison, and nothing inside parentheses is an assignment's
left-hand side. Refusing one consumes nothing after it, so a macro call
with no semicolon, `CCV_ASSERT(n, a == b)`, no longer takes the `always_ff`
after it as its right-hand side (OI-40). `rtl/lint/reference_compare.sv`
must stay silent, and two findings behind a comparison in
`rtl/lint/bad_naming.sv` must name the net that is wrong.

Because `_core_` marks synchronous, an `always_ff` mixing a `*_core_clk`-
generated signal with a `test_clk`-generated one is a crossing detectable from
the names alone. Nothing uses `test_clk` yet; it is registered so the first
crossing is a finding rather than a surprise.

### CCV-L21 — stage tags are well-formed and consistent

For every flop, the tag on the assigned net is checked against the block that
generates it:

- **domain letter** matches the domain of the generating clock — a signal
  labelled for the wrong domain is how a crossing hides;
- **edge letter** matches `posedge`/`negedge`;
- **block letter** is registered, and is the block the module's name gives
  (CCV-L28), or `r`.

### CCV-L22 — a block runs on its own gated clock

No `always_ff @(posedge core_clk)` inside a block, except the wake detector.
A block receives one clock, `core_clk`, ungated, and gates it as its first
act, inside itself (see *The top level* below). Clocking logic on the
ungated net **silently defeats that gate**: the design still works, produces
identical results, and never saves the power it was supposed to. Nothing in
simulation shows it, which is exactly why it needs a rule.

The gate is `ccv_common_clk` (`docs/clock-gate.md`): a block top with
sequential logic must instantiate it with `.clk(core_clk)`, and runs on its
`gclk`. The sleep policy, the registered wake and its hold, and the ctech ICG
are all inside it, so no block builds its own. The wake detector the exception allows
is the edge detector a block needs for a level-sensitive wake source, such as
a stall that releases.

```systemverilog
ccv_common_clk u_cg (
  .clk(core_clk), .rst_n(sched_rst_r06h_n),
  .quiesced(sched_idle_cs03h), .stalled(sched_blocked_cs03h),
  .hyst_quiesce(sched_csr_hyst_q), .hyst_stall(sched_csr_hyst_s),
  .wake({ooe_sched_wake, lane_sched_wake}),
  .cg_override(sched_csr_cg_ovr), .te(1'b0),
  .gclk(sched_core_clk), .gated(clk_gated));
```

`check-top-pure.py` R7 checks the same thing on the elaborated netlist: every
block has exactly one `ccv_common_clk`, on its `core_clk` port, and its
`clk_gated` port is that gate's `gated`.

**Only a block top gates, and a sub-block never sees `core_clk`** (OI-37).
The module names say which is which (CCV-L28), so the rule reads:

- a wrapper, a sub-block or a common module that instantiates
  `ccv_common_clk` is refused. A second gate inside a block would make a
  sleep decision where the block's quiescence and stall are not visible;
- a sub-block that names `core_clk` is refused. It takes `<block>_core_clk`,
  which its block top's gate makes, and on `core_clk` it would escape the gate
  as silently as a flop in the top would;
- a sub-block on another block's clock (`ooe_core_clk` inside a `lane_*`
  module) is refused: a crossing nobody declared.

### CCV-L27 — every clock gate is the ctech ICG

Outside `rtl/ctech/`, no clock is built from a clock with logic, and no
`always_latch` exists. A clock gate is `ccv_common_ctech_icg`, reached through
`ccv_common_clk`. It is simulated as a latch and an AND gate, and synthesised as
the library's ICG cell, whatever synthesis would have inferred (see
`docs/clock-gate.md`, *The ctech layer*).

A hand-built `assign x_clk = core_clk & en` works in every RTL simulation. In
silicon it glitches whenever `en` moves while the clock is high, and synthesis
may or may not recognise it as a gate. Renaming a clock (`assign a_clk =
b_clk;`) is wiring, and is allowed.

The rule also ties the name to the directory. A ctech cell is
`ccv_common_ctech_<cell>` (CCV-L28), defined once per view in
`rtl/ctech/<view>/`: a module so named anywhere else is refused, and so is any
other module in a view's directory, since the name is what exempts a file from
CCV-L08's clock check and from this rule. The name says which cell, the
directory which view. A library view's `lib_cells.v` holds the library's port
declarations, not our RTL, and is not linted.

### The top level: block instances and nets, nothing else

`ccv_top` holds hardening wrappers and the nets between them, and each
wrapper holds its one block, its sequential repeaters and the nets between
them. Neither level has a gate, flop, constant tie-off or clock gate, or glue
of any kind, outside a block or a repeater. This is a hard rule, for three
reasons:

- **Everything can be validated at the top.** Pure connectivity is what
  `check-top-wiring.py` checks bit for bit against the C++ skeleton. Logic
  there would be neither a block nor wiring, so no check would own it.
- **The floorplan can abut the blocks.** A top-level cell needs somewhere to
  sit, and glue between two blocks is what stops them touching.
- **Sleep is a block's own decision.** A block enters sleep on local
  quiescence or stall, signals that are internal and stay internal. So the
  clock gate belongs inside the block, next to what drives it. A top-level
  gate would need those signals brought out as ports.

What the rule moved:

- **The clock gates.** Each block now takes `core_clk` ungated and gates it
  itself, where the top used to build `<blk>_core_clk` from a `sleep_ok`
  port.
- **The CSR star's tie-offs.** CRU's own slot in its star vectors was tied to
  zero at the top. It now has no slot, and the vectors index the other 44
  instances.

**One exception, and it observes.** Under `CCV_CHECK` the top also holds the
checker bank. Its ports may take constants (its configuration). It may drive
nothing, and it is absent from every synthesis view. The bank learns a
receiver's gate state from `clk_gated`, an output port each block has only
under `CCV_CHECK`, as `_tid` exists only under `CCV_TRACE`. That is an
observation, not a control: the decision to gate stays inside the block.

**Enforced on the elaborated netlist** by `tools/check-top-pure.py`, in
`check-top.sh`, for both the synthesis and checking views, at the top and in
every wrapper:

- every cell is what that level may hold: at the top, exactly the 45
  wrappers; in a wrapper, one block and its repeaters;
- no constant on any block or top port;
- every bit a block reads has one driver;
- every bit a block drives is read.

Seven impure copies must each be refused for the rule they break: the old
clock gate, a tied reset, a top-level flop, a floating input, an unloaded
output, and a clock gate and a tie-off inside a wrapper.

What the rule doesn't yet give is *full* abutment. Every net would have to
join neighbours, and today `core_clk`, `rst_n`, the kill broadcast and the
CSR star fan out across the core. That is Q-42. A channel too long for one
cycle is covered by sequential repeaters (`rtl/phys/ccv_common_rpt.sv`,
[`physical.md`](physical.md)), not by glue at the top.

### CCV-L23 — stage arithmetic

The rule the whole convention exists to make checkable:

| | |
|---|---|
| flop output | `max(input stages) + 1` |
| combinational output | `max(input stages)` |

Catches mislabelled pipelines, accidental combinational paths across a stage
boundary, and retiming that updated the logic but not the names.

Three exemptions, each for a reason:

- **A net's own previous value.** `q_cs04h <= en ? d_cs03h : q_cs04h` is a hold
  or a counter — a self-reference at the *same* stage, not a violation.
- **Reset nets** (block letter `r`), whose numbering measures distribution
  depth rather than datapath depth.
- **Right-hand sides with no tagged signal at all** — constants, parameters.

### CCV-L25 — sequential enables are `if`, not a feedback mux

See *Sequential enables* above. Enforces intent rather than correctness: both
forms give the same enable flop, but only one of them says so.

`` `CCV_XHOLD `` is the sanctioned escape, for an enable that genuinely cannot
be proven X-free.

### Local clock gating: CG-1, CG-2, CG-3

**Every register is behind an enable, and the enable is a good one** (Daniel,
2026-10-16; refined the same day with the gate size, the budget and the
names). Most power in a design like this is clock: a flop clocked on a
cycle it does not change burns it for nothing, and synthesis removes that
clock only where the RTL gives it an enable to build a gate from. So the
non-reset part of every `always_ff` is wrapped in an `if` on a named enable,
and the enable has to be worth gating on. Four rules, checked by
`tools/check-cg.py`:

```systemverilog
always_ff @(posedge `CCV_CLK) begin
  if (`CCV_RST)         q_cs01h <= '0;
  else if (ld_en_cs00h) q_cs01h <= d_cs00h;   // CG-1: a named enable
end
```

- **CG-1, form.** Each statement of an `always_ff`'s non-reset part is
  `if (<enable>)` with no `else`, the enable a net named
  `<name>_en[_<stage>][_n|_b]` (`ld_en_cs00h`, `pay_en[j]`; a `!` is
  allowed). Inside it, anything. Several enables in one block are fine, one
  `if` each. What fails: a register written with no enable, an enable `if`
  with an `else` (the register is written on both paths, so nothing holds),
  an enable that is an expression, and one not named `_en`. A valid that is
  also an enable gets an `_en` alias (`wire [S-1:0] pay_en = valid_q;`), so
  every clock enable is one name a reader, a timing report, a power report
  and a waiver can find.
- **A clock gate is at least `CCV_CG_MIN_FLOPS` = 8 flops** behind one
  logically distinct enable. A smaller group gets no ICG, which would cost
  about the clock load it saves, so its flops are clocked every cycle and
  count as ungated (CG-4). CG-2 and CG-3 judge clock gates only.
- **CG-2, enable depth.** Every clock gate's enable cone is at most
  `CCV_NGD_CG_EN` = 8 NGD, from the flops and inputs that feed it. A clock
  gate's enable sets up to the rising edge at the root of its clock branch,
  earlier than the flops behind it see that edge, so it gets a fraction of
  the cycle, not the 25 NGD a flop's D gets. The explicit ICG inside every
  `ccv_common_clk` is held to the same number.
- **CG-3, efficiency.** Every clock gate's **DCGE**, the share of its
  enabled cycles in which its value changes, is at least
  `CCV_DCGE_MIN_PCT` = 75%, in each of three scenarios: **idle**, **medium**
  and **high** activity. An enable that is on while nothing changes clocks
  the flops for nothing, which is the power the gate was meant to save. A
  scenario in which the group is never enabled passes: the gate is closed.
- **CG-4, coverage.** Every flop is in a clock gate, or, clocked every
  cycle, changes in at least 75% of counted cycles in every scenario. This
  is where a group under 8 flops lands, and a flop whose enable synthesis
  dropped. A register CG-1 already reports as written every cycle is judged
  there, not twice.

**An enable group is what synthesis would gate**: the flops Yosys infers one
enable for, read from the synthesised netlist, not from the source. A
register written under nested `if`s splits into groups with different
enables, and a register written with no `if` at all may still get enables
Yosys finds in its logic. CG-2 and CG-3 measure those groups, so they hold
however the RTL is written. CG-1 is what makes the enable deliberate. The
unit's own reset does not split a group: it acts only in reset cycles, which
are never counted, so a register with it and one without share a gate when
their enable is the same. Any other synchronous reset with priority over the
enable is part of the group's enable: its clock runs when either is active,
and its depth is the deeper of the two.

**A field held inside a group keeps the group's enable only if it is
written to** (OI, measured converting the OOE RTL, 2026-10-17). Under a
group's `if (<name>_en)`, a field kept through a nested `if`
(`if (sel) f_q <= x;`) gives Yosys a finer enable: `<name>_en && sel` gates
that field alone, a group of its own with its own depth and DCGE. In the
RS that made each row's grant, 12 NGD and more, the enable of the row's
line selects, which fails CG-2. Two forms keep the coarse enable:

- **AND-OR on D.** Write the held value as next-state logic,
  `({W{sel}} & x) | ({W{!sel}} & f_q)`, so the hold costs the 25 NGD path to
  D and not the 8 NGD path to a gate (`ooe_freelist`'s buffer and bank
  pointers). This is not the feedback mux CCV-L25 refuses: the group's
  enable is still the `if`; the AND-OR chooses what the group writes when it
  is clocked.
- **A guarded payload is not held.** A field read only through its own guard
  bit (valid, busy) is written, or cleared, whenever its group is clocked,
  so it has no enable of its own (`ooe_decq`'s payloads, owners and
  positions, read only through busy).

**How it is measured.** A *unit* is one module at one parameterisation, with
a bench that runs the three scenarios and dumps a VCD (`test/**/cg-units.json`;
TI's are in `test/cg/`). `check-cg.py` synthesises the unit with Yosys,
groups its flops by enable, and maps each enable's cone with ABC onto
`test/ooe/ngd.genlib`, the same recipe as `test/ooe/depth.sh`. Then it
replays each scenario's port trace into the netlist, brings every group's
enable and value out on a port, and counts. The replay must reproduce the
bench's outputs on every cycle, so what is measured is what the bench ran;
reset cycles, and cycles before the first reset, are not counted. The
replay is also what shows Yosys reading the RTL differently from Verilator
(OI-44). The block budget counts flops in a netlist synthesised with its
hierarchy kept, which nothing replays, so each unit's module is synthesised
that way too and must count what its replayed netlist counts: its flops, and
those of every finding its module budget took.

**The scenarios are part of the measurement**, and DCGE is only as good as
they are. Idle: the unit's inputs present no work and hold still. Medium:
work on a fraction of cycles, roughly a third, with data that changes when a
message does. High: work every cycle the unit can take it. Each counts at
least 1,000 cycles, and the inputs' toggle rate must rise from idle to
medium to high, or the scenarios are refused as mislabelled. Data that
changes when no message does is the commonest way to get this wrong: it
makes the scenario busier than its traffic, and every DCGE looks better
than it is.

**Exceptions.** Three, in this order, and the order matters:

- **By measurement.** A register clocked every cycle (CG-1, CG-4) is
  accepted when it changes in at least 75% of counted cycles in every
  scenario: a gate would save it little. A free-running LFSR passes this way;
  a status register that holds while idle does not.
- **By budget, at the module and then at the block.** So that a handful of
  flops never forces unnatural RTL, and so that it is settled module by
  module rather than found when a block is assembled:
  - Each module, at each unit's parameters, may leave the larger of
    `CCV_CG_BUDGET_PCT` = 2% of its flops and fewer than
    `CCV_CG_MODULE_FLOPS` = 8 flops outside the rules with no waiver. The
    fixed count is for small modules, whose 2% is less than a flop. Its
    findings are taken smallest first while they fit. Only findings about
    flops count: written every cycle (CG-1), a deep or wasteful gate (CG-2,
    CG-3), a flop in no gate (CG-4). A form or a name (CG-1) is never
    auto-waived, and neither is a scenario problem.
  - What the modules take still counts against each block: per instance,
    over the block's whole hierarchy (its hardening wrapper, the block and
    its repeaters, every common module once for each place it is used), the
    flops its modules auto-waived must stay within 2% of the block's flops.
    Explicit waivers do not count here. This applies once a block top is RTL,
    not a generated stub; today none is.
- **By waiver, last.** `rtl/cg-waivers.json` holds one entry per module,
  rule and register, with who wrote it, when, and why the rule cannot or
  should not be met, citing what was measured. Waivers are the last resort:
  where a rule would be met by refactoring, refactor (the age matrix's 900
  one-flop enables are a refactor, not a waiver). A waiver that excuses
  nothing is refused, and that includes one for a finding a module's budget
  already takes. Today's waivers: two of the repeater's pulse registers,
  past its allowance (an enable that sees a repeater's input reaches the
  gate after a cycle of wire). The clock gate's hysteresis counters had two
  until its threshold compare was registered, which Daniel's CSR contract
  allows (no write-to-use latency, Q-59); they are now one 14-flop gate.

**The ratchet.** RTL written before the rule is listed in
`rtl/cg-ratchet.json` and excused while its owner converts it. The list only
shrinks: `check-cg.py` refuses an entry that was not on it when the rule was
made, and refuses a listed module that now meets the rule until it is
removed. A module with flops that is neither measured by a unit nor on the
list is refused. Checkers (`ccv_common_chk_*`, present only under
`CCV_CHECK`) and ctech cells are not silicon logic and are not checked.

**What this does not see.** An enable's inputs are taken to arrive at zero:
one built from another module's combinational output is measured from the
module boundary only. A group is one enable net and its polarity, with the
unit's reset folded in, so two enables that are logically equal but built
separately count as two groups and may each fall under 8. And a finding's
size in a block's budget is counted by register name, every flop of that
register in each instance, which over-counts a finding that covers only
part of a register.

### Logic depth: NGD-1 … NGD-4

**25 NGD of combinational logic between two flops** (`CCV_NGD_BUDGET`;
Daniel, 2026-10-17). The flop's own clock-to-Q and setup are outside it:
every depth here is measured with the flops cut out, so the whole 25 is
logic. An NGD is a NAND2 at fanout 4; `test/ooe/ngd.genlib` holds the gates
at their fanout-of-4 delays, and broadcast fanout and wire are not in it.

**A module is measured alone, so a path that leaves it is budgeted at the
port.** Each side of a port has a budget, by default `CCV_NGD_PORT` =
floor(`CCV_NGD_BUDGET` / 2) = 12, derived, so it follows the stage:

- an **output** is required within 12 NGD of its module's flops;
- an **input** arrives at 25 − 12 = 13 and must reach its module's flops
  within the rest, 12.

Two defaults meet within the stage, so a port that fits them needs no one's
plan. Anything else needs explicit budgets from the architect: a port over
12, and any path **straight through** a module, input to output, which fits
no default (it would arrive at 13 and be required by 12).

**One budget file per module, beside its RTL**, in one format, listing only
its non-default ports: `ooe_rs.ngd.json` beside `rtl/ooe/ooe_rs.sv`, say, and
today only `rtl/clk/ccv_common_clk.ngd.json`. An example:

```json
{
  "module": "ooe_rs",
  "ports": {
    "free_cq01h":    {"arrival": 3.0,   "by": "OA", "date": "…", "why": "…"},
    "gnt_idx_cq02h": {"required": 20.0, "by": "OA", "date": "…", "why": "…"}
  }
}
```

An input's `arrival` or an output's `required` time, in NGD from the flop
that launches it, with who set it, when and why. The architect sets them (OA
for OOE); the module's owner keeps the file. The module is checked against
its file, and an assembled block is checked from all of them: the budgets
must **converge**, each driver's required time, plus any logic between, no
later than its receiver's arrival.

Four rules, checked by `tools/check-ngd.py` on every module at its units'
parameters (`test/**/cg-units.json`; `test/**/ngd-units.json` for a module
with no flops):

- **NGD-1, the stage.** Flop to flop within a module: at most 25.
- **NGD-2, outputs.** Each output ready by its required time, from the
  module's flops and from each input at its arrival.
- **NGD-3, inputs.** Each input, from its arrival, reaches the module's flops
  within the stage.
- **NGD-4, budget files.** Each named for its module, a design module, each
  entry well formed and on a port of that module, in the right direction.

**How it is measured.** Yosys synthesises the unit flattened; each clock-gated
flop becomes a plain flop on its next value (its enable is timed apart, to its
ICG, by CG-2); ABC maps it onto the genlib, as `test/ooe/depth.sh` does. A
timing pass over the mapped netlist then splits every path by where it starts
and ends: an input or a flop, an output or a flop. Its longest path must equal
ABC's own, or the run stops.

**The assembled block, from its budget files and then whole.** Once a block
top is RTL, it is checked twice. First from the budget files, quickly: each
level of its hierarchy that instantiates others is mapped alone, its
children cut out, each child's output starting at its required time and each
child's input to be reached by its arrival, the block's own inputs arriving
at 13. So every connection, and any glue between children, must converge to
25 as the files say. Then timed whole, synthesised flattened with its
hardening wrapper: every flop to flop path within 25, whatever the files
said. That pass is still needed, but it should find only corner cases, where
synthesis did across a boundary what it could not module by module (two
64-bit parities in series map shallower than their halves; a large function
split across a port may map deeper or shallower than its halves add up to).
And its boundary
is **registered on both sides** (`docs/skeleton.md`): every output straight
from a flop, every input into its flops within 12. With a link at 0 repeater
stages, its default in `params/links.json`, a block port is wired straight to
its neighbour's, so the blocks' own RTL is what keeps the rule. The block
budget of local clock gating (2% per instance) is checked on the same
assembly by `tools/check-cg.py`. Today no block top is RTL, so neither runs
on the tree; the fixtures exercise both.

**The ratchet.** The ports that broke a default when the rule was made sit on
`rtl/ngd-ratchet.json`, each awaiting the architect's budgets or a redesign.
The list only shrinks: an entry that now meets its budget, or one that was
not there when the rule was made, is refused. A design module no unit
measures is refused.

### CCV-L26 — nothing Yosys cannot parse

Both simulators accept these; Yosys 0.33 does not. So a file using them is
green in simulation and dies only when it reaches formal — the flow a designer
is least likely to be running while writing. The credit checker hit exactly
this: its first per-message age queue was a 2-D packed array with `int'()`
casts, and it took down the cover run.

Measured against Yosys, not assumed — and the boundary is not where you would
guess:

| Construct | Yosys 0.33 |
|---|---|
| `logic [A][B] x;` as a declaration or port | **rejected** |
| `logic [A][B] f;` as a member *inside* a packed struct | accepted |
| `int'(e)`, `integer'`, `shortint'`, `longint'`, `byte'` | **rejected** |
| `foo_t'(e)` — a cast to a typedef name | **rejected** |
| `signed'(e)`, `unsigned'(e)`, `W'(e)`, `6'(e)` | accepted |
| `logic [A] x [B];` — unpacked | accepted |
| `foo_t x` — one packed struct, as a declaration or port | accepted |
| `foo_t [A] x` — a packed array of packed structs, as a port | **accepted and mis-elaborated**: sized by `A` alone, fields made implicit 1-bit nets, warnings only |

The idiom to reach for instead is one flat vector indexed with part-selects,
`x[i*W +: W]`, which is what `rtl/if/ccv_common_chk_credit.sv` now does, or,
for an array of structs at a port, one struct-typed port per element, which
is what the generated top does. The array-of-structs case is the dangerous
one: Yosys doesn't reject it, it sizes the port by the array bound, turns the
fields into implicit 1-bit nets, and only warns.
`tools/check-top-wiring.py` refuses those warnings as well as the lint rule
refusing the construct.

**What Yosys reads, it must read as written** (OI-44, 2026-10-17). Every
Yosys the gate runs, SymbiYosys's included, is `tools/shim/yosys`, which
makes an error of each warning that means the netlist is not the RTL: a
select out of bounds (bits set to undef), an implicitly declared
identifier (the array-of-structs case above among them), conflicting
drivers, a net read with no driver, a combinational loop.
`tools/check-yosys-strict.sh` provokes each with a fixture in `test/yosys/`
that plain Yosys passes with a warning. Run a flow outside the gate the same
way, `PATH="$PWD/tools/shim:$PATH"`; `tools/check-cg.py` does so itself. A
misread with no warning is still possible: Yosys 0.33 once dropped a
saturating increment inside a function in `ooe_wake`, silently, and only
check-cg's replay showed it.

The rule flags only what Yosys rejects. A rule that also flags accepted forms
gets exempted, and an exemption habit is how rules die. To keep that honest in
the direction that matters, `rtl/lint/reference_common_yosys.sv` exercises every
permitted form and `check-1d` reads it **with Yosys** on every run: a form the
rule permits but Yosys rejects would be the worst outcome available — both
simulators green, lint silent, formal dead.

### CCV-L24 — `_b` is a complement

A net named `_b` must be driven through an inversion. It complements a *value*,
which is often an expression or a bit-select rather than a net of its own, so
no same-named sibling is required — an earlier version demanded one and was
wrong. Use `_n` for a signal that is simply defined active-low; that carries no
obligation.

### CCV-L01 — one module per file, filename matches module name

Required by build automation and assumed by most lint tooling. Also what makes
a block's file findable from a waveform hierarchy without a search.


### CCV-L03 — no `initial` blocks and no delays in design RTL

Reset behaviour comes from the synchronous reset. `initial` for state is not
synthesizable intent, and it hides the reset-vs-un-reset decision that §6
requires each block to make explicitly at Stage 4a.

Testbenches and instrumentation are exempt — that is what they are for.

### CCV-L04 — `<=` in sequential logic, `=` in combinational

Ordinary discipline, worth enforcing because the failure is a race that
reproduces intermittently and differently per simulator. Use `always_ff` and
`always_comb` rather than bare `always @`, so the tool checks the intent too.

No inferred latches — left to `verilator --lint-only`, which already detects
them precisely.

### CCV-L05 — no bare `assert` / `assume` / `cover`

Everything goes through the Stage 1b macros in `rtl/include/ccv_assert.svh`.

This is not a formatting preference. Stage 1a finding F-1: the three tools
accept three different dialects and no two overlap — Icarus rejects assertion
labels, Yosys rejects the `else` action block, Icarus rejects `$past`. A
hand-written property is broken in at least one tool, and in the worst case
silently.

### CCV-L06 — no DPI imports in design RTL

Event instrumentation is bound to a block from outside it, never written into
it. A DPI import in a design module is not synthesizable, and §9's argument for
preferring `bind` for assertions applies here with more force.

### CCV-L07 — an unreachable case branch assigns `'x`, never holds

§6's first listed X-safety rule: explicit X-injection for unreachable states,
rather than the implicit hold that squashes the bug.

Either spelling satisfies it — a `default:` branch, or an X prologue before the
case. The prologue is often the more natural style and reaches the same
guarantee, so the rule accepts both:

    always_comb begin
      y = 'x;                 // prologue
      case (sel) ... endcase
    end

    case (sel) ... default: y = 'x; endcase   // or a default branch

    // (neither)              // silently holds, and the bug survives

### X-propagation: matching VCS X-Prop with the tools we have

§6 requires X-correctness to be designed in by convention rather than
inherited, because neither simulator has dependable X-prop semantics. There is
no VCS-equivalent X-propagation mode anywhere in the flow.

**The rule: a selection on control must be X-deterministic.** Exactly three
constructions are legal; anything else is X-optimistic, which means the bug is
invisible rather than merely unhandled.

| Route | Construction | Behaviour on an unknown selector |
|---|---|---|
| **Prohibition** | `if`/`case` whose control **inputs** carry `` `CCV_ASSERT_KNOWN `` | The X is flagged at its source |
| **tmerge** | Ternary (`?:`), or the `` `CCV_XMUX* `` macros | Agreeing bits keep their value, differing bits go X |
| **xmerge** | `case`/`casez` with an X-default covering everything it assigns | The whole result goes X |

All measured, with `i0=1100 i1=1110 i2=1100 i3=1101` (bits 3,2 agree; 1,0
differ):

| Construct | `sel=xx` | `sel=1x` |
|---|---|---|
| `if`-chain | `1101` — the **last** branch | `1101` |
| ternary | `11xx` | `110x` — narrows on partial X |
| `case` + X-default | `xxxx` | `xxxx` |
| `casex` | `1100` — **silently matched branch 0** | `1100` |

Two things to take from that table:

- **The ternary operator is already X-pessimistic in the LRM.** It produces
  exactly what VCS calls tmerge, with no tool mode, no pragma and no primitive
  — and it narrows correctly when only *part* of the selector is unknown. The
  asymmetry against `if`/`case` is the whole lever this section rests on.
- **An `if`-chain does not pick the first branch, it falls through to the
  last.** Every comparison against an unknown selector is itself unknown, so
  the chain lands on the final `else`. Which branch that is depends on the
  ordering, not the design. The answer is definite, arbitrary, and
  indistinguishable from a correct one.

**Prefer prohibition where it applies.** It is the strongest of the three: it
reports X at the source rather than tracking its spread, it works in every
tool, and — unlike propagation — it is *provable under formal*. Choose tmerge
over xmerge where either is allowed, since a blanket X trains people to ignore
X. But `case` is too useful to abandon, and an X-defaulted `case` is a fully
legal, natural-style answer.

**The primitives are conveniences, not requirements.**
`` `CCV_XMUX2/4/8 `` and `` `CCV_XHOLD `` in `rtl/include/ccv_xprop.svh` just
save writing a ternary chain; they introduce no semantics. Code that spells the
chain directly is equally correct and equally lint-clean.

#### This has exactly one witness

Verilator is 2-state and cannot see X at all. Under formal an un-reset register
is a free **two-state** value (F-8), so `$isunknown` is identically false
there. **Icarus is the only tool in the flow that observes any of this.**

That is a structural weakness — the same shape as the event-emission path
(F-13) — and it is the real argument for prohibition being primary: an
assertion fires under Icarus *and* proves under formal, while propagation is
checkable in one place only. It also makes the periodic X-pass (§6, and per
block at Stage 4c) load-bearing rather than supplementary.

`tools/check-xprop.sh` is the differential regression: it asserts the three
constructions **disagree** on an unknown selector. If they ever agree, these
rules are ceremony and should be deleted.

#### Sequential enables: `if` is the right form inside `always_ff`

The one place `if` on control is *preferred* rather than merely tolerated.

    always_ff @(posedge `CCV_CLK) begin
      if (`CCV_RST)         q_cs01h <= '0;
      else if (ld_en_cs00h) q_cs01h <= d_cs00h;
    end

This is the shape that carries an enable to synthesis as a clock-gating
candidate, and since 2026-10-16 it is required, not only preferred: see
*Local clock gating* above for the form (CG-1) and what makes the enable a
good one (CG-2, CG-3). The X obligation is discharged by **prohibition** — a
`` `CCV_ASSERT_KNOWN `` on the enable — not by merging, and the rules as
written already permit exactly this.

**With a real gate, the assertion matters more, not less.** A feedback mux with
an unknown enable holds a stale value. An ICG with an unknown enable produces
an unknown *clock*, and every flop behind it is then undefined. The prohibition
is doing more work in the gated case, which is the opposite of the intuition.

**Measured (F-17):** both spellings synthesise to the *same* enable flop in
Yosys — `$_DFFE_PP_` without reset, `$_SDFFE_PP0P_` with it. Yosys's `opt_dff`
recognises the feedback mux and converts it, so nothing is lost semantically
either way. The reason to prefer `if` is that commercial gating insertion is
more reliably triggered by it, and **that is not something this toolchain can
verify** — Yosys 0.33 has no `clockgate` pass at all. It infers the enable and
stops; turning `$dffe` into an ICG plus a gated clock is a mapping decision it
never makes.

**This is linted (CCV-L25), and the basis matters.** The rule does not claim
the two forms differ — they provably do not, in the only synthesis tool
available here. What it enforces is *intent*: an `if` states "this is a
clock-gating candidate", a feedback mux states "this is a mux", and the
project has chosen to write RTL for where the flow is going rather than for
what Yosys does today.

That distinction is why the earlier decision not to lint it was wrong. It was
right about the evidence and wrong about the rule — what is being enforced is
a design decision, not a belief about a tool, and a design decision is exactly
what lint is for. `rtl/lint/reference_gated_enable.sv` is the standing proof that
the preferred form is clean under every other rule.

`` `CCV_XHOLD `` remains available for the case this does not cover: an enable
that genuinely cannot be proven X-free, where merging beats holding.

**In `always_comb`, the preference inverts** — there is no gate to infer, so
the ternary's tmerge is free and strictly better.

### CCV-L16 — `casex` is banned outright

Measured above: with an unknown selector `casex` treats X as a don't-care and
matches the **first** branch. That is neither pessimism nor optimism — it is an
arbitrary answer wearing the costume of a real one.

`casez` is permitted, because `z` don't-care does not make `x` a don't-care: a
`casez` with an unknown selector still matches nothing and falls to its
default. It is subject to the same X-default requirement as `case`.

### CCV-L17 — no partially X-defaulted case

A `default:` that assigns some of the signals the case writes and not others
leaves the rest holding their previous value on an unreachable branch — the
implicit hold CCV-L07 exists to remove, reintroduced halfway.

Usually a slip rather than intent, which is exactly why it needs a rule.

### CCV-L18 — array write with an unknown index

An unknown index does **not** propagate X. LRM semantics silently **drop the
write**, and no coding construction changes that — the value simply never
arrives, and the array keeps a stale entry that looks legitimate.

Prohibition is the only route here: assert the index known.

### CCV-L08 — control expressions must be X-deterministic

§6's central rule, and the one no stock rule set expresses: it is a
relationship between a control expression and an assertion elsewhere in the
file, not a property of either alone.

An `if` has only the prohibition route — there is no "X-default" for an `if`,
and the alternative is to write the selection as a ternary, which is not an
`if` and so never reaches this rule. A `case` has both routes.

**Why only input ports must carry the assertion.** X enters a module through
its ports or through un-reset state. A locally derived signal is X-free
whenever the inputs it derives from are, so asserting at the boundary
discharges the interior — the same compositional argument F-8 makes for
`` `CCV_ASSUME_KNOWN ``, one level down. Un-reset state is the other source,
and is covered separately by the reset line at Stage 4a and by
`` `CCV_ASSERT_READ_VALID ``. `rst` is exempt: §6 makes it globally
synchronous and always reset.

**Limits, stated because a rule trusted beyond its reach is worse than one not
trusted at all.** This reads ANSI port lists, matches identifiers textually,
and does not follow hierarchy, `` `include `` boundaries or non-ANSI
declarations. It is a net, not a proof. The proof is the formal run.



**§6's central rule, and the highest-payoff one in this guide.**

The move is to *prohibit* X on control rather than propagate it. `if (x)`
silently takes the false branch in every 4-state simulator — that is the LRM's
own X-optimism, not a tool defect — so X on a control signal is invisible
unless something asks. This asks.

It works in every tool regardless of X-propagation fidelity, it is formally
provable, and it reuses the §7 assertion machinery instead of being a parallel
mechanism. Coding style is then the complement: **propagate X on data, where
it is cheap and reliable; prohibit X on control, where propagation is not.**

    `CCV_ASSERT_KNOWN(mode_known, mode)
    always_comb begin
      unique case (mode)
        ...
        default: dout = 'x;
      endcase
    end

**Under formal the known-macros are constant true** (finding F-20, which
corrects F-8). Yosys reads `$isunknown(s)` as "`s` equals 0", so
`assume(!$isunknown(s))` pinned an input to all ones, and the assert failed on
every legal 0. The formal model has no X: registers and inputs are free
two-state values. So X-freedom is the simulators' question, and formal proves
the protocol over every value instead. Write `` `CCV_KNOWN(s) ``, never a bare
`$isunknown`, in any property Yosys may read.

**Do not use `$isunknown` for the un-reset-payload invariant.** Also F-8: an
un-reset register gets a free *two-state* value under formal, so
`$isunknown(payload)` is identically false and the property is vacuously true.
State it structurally instead, over the valid bit, which is what §6's
invariant literally says:

    `CCV_ASSERT_READ_VALID(rob_read_valid, rob_rd_en, rob_entry_v)

### CCV-L12 — every interface typedef has a checker, referencing every control field

Interface checker convention §3: *"Every interface typedef has exactly one
associated checker module. No typedef may exist without one; lint enforces
this."* And §4: *"a field added to the struct and not to the checker is a lint
failure."*

`schema/interfaces.json` declares the typedef; `rtl/if/ccv_common_chk_<name>.sv`
must exist, and must reference every field marked `control: true`.

Control fields specifically, not all fields — §6 prohibits X on control and
propagates it on data, so a control field carries an obligation and a data
field does not. `issue_t`'s `payload` is deliberately unreferenced for exactly
that reason.

This is a cross-file rule, so it has no counter-example in a `.sv` fixture;
`tools/check-1d.sh` points it at `rtl/lint/bad_interfaces.json` instead.

### CCV-L13 — no `bind` at a design boundary

**Stage 1a finding F-9, and the reason is the failure mode, not the missing
feature.**

| Tool | `bind` |
|---|---|
| Verilator | works |
| Icarus | syntax error on the `bind` statement — honest, and cheap |
| Yosys / `sby` | **parses it, ignores it, garbage-collects the checker** |

Yosys prints `Removing unused module '\chk'` and the proof then passes a
property written to be false. Every standalone block proof would have been
empty, and nothing in the output would have said so.

The convention's §4 originally specified `bind`, for good reasons — RTL stays
readable, checkers stay out of synthesis, and modes can be re-bound per flow
without touching design source. Those reasons are still right; the mechanism
is simply not available. Instantiate with `` `CCV_CHECKER `` instead.

**What it costs:** `bind` kept checkers naturally out of synthesis, and
instantiation does not. Synthesis is deferred (§6 resolved scope decisions), so
this is recorded debt rather than a present cost — but it is the one part of
`bind` with no substitute, and it should be settled before the first synthesis
attempt rather than discovered there.

`bind` is still fine for Verilator-only instrumentation, where nothing is lost.

#### `cover` does nothing in simulation on this stack

Worth knowing before relying on one. Measured (Stage 1a case 03): an immediate
`cover` is **`SILENT` in both Icarus and Verilator** and `COVER-HIT` only under
`sby -m cover`. Concurrent `cover property` is worse — it does not parse in
Icarus or Yosys at all.

So a `cover` is a **formal-only** construct here. That is not a reason to write
fewer of them; it is a reason to make sure they are *run*, which is why
`tools/check-if.sh` puts the satisfiability covers through `sby -m cover`
rather than trusting a simulation regression to exercise them. A guard that is
never run carries exactly as much information as no guard.

### CCV-L14 — every checker carries a satisfiability cover

Interface checker convention §3.3, which calls a contradictory `assume` set
*"the single most dangerous failure mode in the whole formal strategy, because
it produces false confidence rather than a visible error."*

Spike cases 34 and 35 make that concrete rather than rhetorical. Case 34
carries contradictory assumes and `assert (1'b0)` — a property that cannot hold
— and BMC returns **PASS**, with no counterexample and nothing to distinguish
it from a real proof. Case 35 is the same assume set with a `cover` asking
whether the assumed state is reachable: **COVER-MISS**, the guard firing.

    `CCV_IF_SAT(iss_accept_reachable, accepted)

The covers are **unconditional, never mode-resolved**. A guard that switched
off in the mode where assumptions are active would be absent exactly when it is
needed. They must also *run* alongside any proof relying on the assumption set
— a guard that is never run carries no information — which `tools/check-if.sh`
does.

### CCV-L15 — checker properties must be mode-resolved

Use `` `CCV_CONTRACT_M(MODE, ...) ``, not bare `` `CCV_ASSERT ``.

A bare assertion in a checker ignores the `MODE` parameter, so the checker
cannot act as a formal cut-point: instantiated on an input boundary in `ASSUME`
mode it would still assert, the environment would go unconstrained, and the
proof would fail spuriously — or, worse, the intended constraint would simply
be absent and a neighbouring proof would look fine.

Three macros are exempt and intentionally so:

- `` `CCV_ASSUME_KNOWN `` — an environment constraint in simulation, constant
  true under formal, where there is no X to constrain (F-20).
- `` `CCV_IF_SAT `` — a guard, never mode-resolved, per CCV-L14.
- `` `CCV_IF_CONFIG `` — a check on the checker's own parameters, below.

Each is a *named* macro rather than a bare `` `CCV_ASSERT `` precisely so this
rule keeps full force inside checkers. A file-scope lint exemption would have
switched CCV-L15 off across the one file it matters most in.

### `CCV_IF_CONFIG` — misconfiguration is not a protocol violation

A parameterised checker can be misconfigured, and the interesting
misconfigurations break no protocol rule at all:

| Misconfiguration | What it looks like instead |
| --- | --- |
| credit depth below the credit loop (round trip + turnaround, Q-43) | the channel runs below full bandwidth, `DEPTH / loop` of it — indistinguishable from healthy backpressure |
| timeout N below the round trip | `response_within_n` fires on a channel behaving perfectly, and the first instinct on seeing it is to raise N — i.e. the check teaches you to disbelieve it |

Nothing else in a checker catches either, because nothing else looks at the
parameters:

    `CCV_IF_CONFIG(depth_covers_credit_loop,  DEPTH     >= ROUND_TRIP + CCV_CREDIT_TURNAROUND)
    `CCV_IF_CONFIG(timeout_covers_round_trip, TIMEOUT_N >= ROUND_TRIP)

**Never mode-resolved.** Under `MODE=ASSUME` a mode-resolved version would turn
a misconfiguration into an *assumption* and constrain it away — the proof would
then hold only over the configurations that are already correct, and say so
nowhere. A configuration error is wrong in every mode.

`tools/check-if.sh` builds each misconfiguration and requires the matching
assertion name to fire. Every other check in that file is a *stays quiet*
check, and a check that has been deleted is very quiet.

### CCV-L09 — no `interface`/`modport` on a port list

See *Load-bearing: interface style* above. Settled by F-4.

### CCV-L10 — no comment line opening with a tool's name

A `// verilator ...` comment is parsed as a metacomment pragma and rejected as
an unknown one. This is a prose hazard, not a code one, and it cost three
builds while Stages 1a and 1b were being written — which is precisely the
argument for a lint rule rather than a note. Reword so the line does not start
with the tool name. Genuine pragmas (`lint_off`, `coverage_off`, …) are
recognised and allowed.

### CCV-L11 — every design module cites the spec it implements

§9: "Each module references the spec artifact it implements — its Stage 4a
internal-behavior spec — so RTL and spec stay traceable to each other as both
evolve."

A dedicated comment line, so the reference is findable mechanically:

    // Spec: docs/blocks/scheduler-4a.md

---

## Assertion placement

§9 prefers `bind`, so properties live in separate files, RTL stays readable,
and properties are naturally excluded from synthesis.

**Available, with one constraint.** Stage 1a case 17: `bind` works under
Verilator and is rejected by Icarus and by Yosys's native front end. Since
Verilator is the default simulator (§6) and carries the day-to-day assertion
regression, `bind` is usable for the properties that run there. Properties
that must also hold under the Icarus X-pass or under formal are written
**inline**, through the same macros.

The split follows the tier boundary the macro library already draws, so it
adds no new concept:

- **Inline** — tier-1 boolean properties, `CCV_ASSERT_KNOWN`, and anything a
  formal target depends on.
- **`bind`** — tier-2 temporal properties and testbench-side checkers, which
  Icarus does not carry anyway.

## Stating a property over time

There is no separate assertion clock. Every macro bottoms out in
`always @(posedge clk)`, and `clk`/`rst` are resolved **at the expansion site**
— they are whatever those names mean in the module the macro appears in, which
is why CCV-L02 requires them to be named that. The `_AT` variants take explicit
names for the rare module that cannot. Nothing is generated internally, and
with a single clock domain (§6) there is nothing to disambiguate.

Because these are immediate assertions inside a clocked block rather than
concurrent properties, they see **pre-NBA values** — a register written with
`<=` at the same edge reads as its old value. That matches what a concurrent
property's preponed sampling would give, so the distinction rarely bites; it
holds because CCV-L04 keeps `<=` in sequential logic, which is one more reason
that rule is not cosmetic.

### Tier 1b — bounded temporal properties

No sequence construct exists in any tool (F-2) and `$stable` is
Verilator-only, so anything spanning cycles is a counter or a shadow register
plus a boolean property. Three of those are common enough to be in the library:

| Macro | Contract |
|---|---|
| `` `CCV_ASSERT_STABLE_WHILE(name, cond, sig) `` | `sig` may not change for as long as `cond` holds continuously |
| `` `CCV_ASSERT_STABLE_FOR(name, start, sig, n) `` | `sig` is sampled when `start` pulses and held for `n` cycles |
| `` `CCV_ASSERT_RESPONSE_WITHIN(name, req, ack, n) `` | a request is answered within `n` cycles |

Mode-resolved forms for checkers — `` `CCV_STABLE_WHILE_M ``,
`` `CCV_STABLE_FOR_M ``, `` `CCV_RESPONSE_WITHIN_M `` — take `MODE` first and
are what CCV-L15 requires inside a checker.

These are tier **1b**, not tier 2: being boolean properties over ordinary
state, they are green in all three tools, including under Icarus and under
formal. Only `` `CCV_PAST `` and the `_T` macros are Verilator-and-formal-only.

Three things to know before using them:

- **The state is real.** It elaborates in every flow and the solver carries it,
  so a wide `sig` or a large `n` costs proof time. Keep `n` as small as the
  contract requires.
- **`name` must be unique in the module** — it is pasted into the declared
  signal names, and a collision reports a redeclaration of the generated
  signal rather than pointing at the macro.
- **`CCV_ASSERT_RESPONSE_WITHIN` assumes one outstanding request**; the age
  counter clears on any `ack`. A pipelined interface with several in flight
  needs one age per outstanding message, which is what
  `ccv_common_chk_credit.sv` carries. It was one counter until its negative
  controls showed a second message could wait ~2N (`fail-open-register.md`).

`CCV_ASSERT_RESPONSE_WITHIN` is what replaces liveness. `s_eventually` does not
exist anywhere (F-2), so "a request is eventually answered" cannot be stated at
all — every interface gets a bounded latency with a **justified N** instead.
That is strictly weaker: it bounds the wait, it does not prove the absence of
deadlock.

**Two tool behaviours that shape how these get tested** — both bit during this
work:

- `$bits()` directly in a declaration range elaborates cleanly everywhere and
  then crashes Icarus at *runtime*, but only when the declared signal is driven
  from a different `always` block. The macros route it through a `localparam`.
  (F-14)
- Verilator `$stop`s on the first assertion failure, so a negative test
  covering several properties in one build only ever observes one. Build one
  property per run. (F-15)

## What cannot be written, and what to write instead

Stage 1a finding F-2: **no multi-cycle sequence construct works in any of the
three tools** — not `##n`, not `sequence`, not `throughout`, not property local
variables, not `s_eventually`. Verilator reports them as `Unsupported:` rather
than miscompiling them, which is the good version of this news.

Consequences, which land on Stage 2 when interface contracts are written:

- A **request-to-response contract** is an explicit tracking register plus a
  boolean property over it. The checker carries its own state, so it is a thing
  to review rather than a thing to read.
- **Deadlock freedom** cannot be stated as liveness. It becomes a bounded
  property — *a request outstanding for more than N cycles is a failure* —
  which is strictly weaker, and N is a number somebody has to justify. The
  round trip turned out uniform, so it is one global N plus one for the
  memory path (`CCV_P_TIMEOUT_N`, `CCV_P_TIMEOUT_MEM`), both provisional.
- **One-cycle history** is available as `` `CCV_PAST `` in tier 2, which is
  the Verilator-and-formal tier.

## Synthesizable subset

- No `initial` for reset behaviour (CCV-L03), no delays.
- `always_ff` / `always_comb`, not bare `always @`.
- No inferred latches.
- No `casex`. `casez` only with a paired `CCV_ASSERT_KNOWN` on the selector,
  since don't-care matching is exactly where an X selector hides.
- `unique` / `priority case` where the intent is exclusivity — their implied
  assertions fire on no-match, which is what an X selector looks like once
  CCV-L08 has banned X on control. Note Stage 1a: those implied assertions are
  checked by Verilator and are **silent** in Icarus and Yosys, so they
  supplement CCV-L08 rather than replacing it.
