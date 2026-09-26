# Physical implementation: getting to abutment

Where the flow meets the floorplan. The top-level rule
([`rtl-coding-style.md`](rtl-coding-style.md), "The top level") makes
`ccv_core_top` block instances and nets, nothing else. Full abutment asks for
more: every net joins two blocks that touch (Q-42). A channel whose two ends
the floorplan can't place side by side needs its distance covered by flops.
This file is about the widget that does that, and what a repeated link
changes around it.

## Sequential repeaters

`rtl/phys/ccv_seq_rpt.sv` repeats **one slot** of a credited channel through
`STAGES` flops in every direction:

| Direction | Signals | Flop |
|---|---|---|
| forward | valid, wake | every cycle, reset low |
| forward | payload, trace id | **enabled by the previous cycle's valid**, no reset |
| forward | lead slice (schema `lead_fields`) | **enabled by the same cycle's valid**, no reset |
| backward | credit, stall | every cycle, reset low |

`STAGES = 0` is wires, so a link can be declared repeated before its length
is known. The module is reusable (`clk`/`rst_n` are generic formals).

**The payload enable is the stage's own valid flop.** The payload follows
valid by one cycle, so the cycle it sits on a stage's input is exactly the
cycle that stage's valid flop is high. That flop is the enable, written as
an `if` in `always_ff` (the style guide's "Sequential enables"). The payload
register then loads once per message and holds otherwise: one shared enable
per stage, a clock-gating candidate, and no toggling on an idle link.

**The lead slice is the exception.** The spec was "always the previous
cycle's valid", but a lead travels *with* valid, a cycle ahead of the rest of
the payload (Q-40). So its register is enabled by the same cycle's valid.
Enabled by the previous cycle's, it would be taken a cycle late, which is the
skeleton's `--break late-lead` failure. Only channels with lead fields
(`rcu_lane_ops`) get this register. Every other channel's payload follows the
previous-cycle rule entirely.

## What a repeated link changes

The widget adds latency. What must move with it is outside the widget.

**The round trip grows by 2N.** For a link with N stages each way:

- every checker on it takes `ROUND_TRIP = CCV_RT_ABUT + 2N`;
- credit depth is at least that;
- `TIMEOUT_N` grows by 2N;
- drain waits and wake leads are counted against the same number.

`ccv_credit_checker` already carried these as one parameter. Its header
anticipated "the day a floorplan produces a non-abutting boundary".

**The stall rule depends on where the checker sits.** Downstream of N
stages, the valids already in flight when the receiver stalls still arrive.
`ccv_credit_checker` now takes `SRC_STAGES`, the number of repeater stages
between it and the sender. The stall it checks against a valid is
`1 + 2 * SRC_STAGES` cycles old: old enough to have stopped that valid. A
checker bank can then sit anywhere along a repeated link, at the sender (0),
mid-link or at the receiver (N). The default of 0 is today's behaviour
exactly.

**Everything else survives repeating:** payload-after-valid and
lead-with-valid at every stage, no phantom credits, no overrun, and wake's
lead over valid (Q-33), since both are delayed alike.

**Every slot of a channel instance takes the same N,** and so does every
copy of a lockstep channel. Otherwise atomic and lockstep delivery are lost.

**The rate is depth / (4 + 2N).** Measured by the testbench and in the
skeleton's own channel model. A credit's whole loop is four cycles at
abutment (valid; payload lands; credit registered; credit usable) plus 2N of
wire:

| N | depth `CCV_RT_ABUT` (2) | depth `CCV_RT_ABUT + 2N` | depth `4 + 2N` |
|---|---|---|---|
| 0 | 0.50 | 0.50 | 1.00 |
| 2 | 0.25 | 0.75 | 1.00 |
| 4 | 0.17 | 0.83 | 1.00 |

A repeated link that forgot to deepen its credits throttles with **no
protocol violation to say so**, the misconfiguration the checker's
`depth_covers_round_trip` exists for. The table also shows a finding about
abutted links: at today's depth of 2, every slot runs at half rate (Q-43).

## Clocking

The widget has a `clk` port and no opinion about what drives it.

**Today it is `core_clk`.** The repeater runs whenever the core does. With
the payload enabled by valid, an idle link costs only its pulse flops'
clock pins.

**Later, some short links may take a clock forwarded from the source
block.** The clock then travels with the data (source-synchronous), and the
repeater sleeps with its source. It is a per-link decision, and a
constrained one (Q-45):

- **Skew.** The last stage launches into the receiver's flops on the
  receiver's clock, and credit and stall come back the other way. Skew
  between the forwarded clock at the far end and the receiver's clock has to
  sit inside the hold and setup margin. That is why this suits short links
  only, and needs timing analysis per link.
- **Gating.** If the forwarded clock is the source's *gated* clock, the
  repeater stops when the source sleeps. A message still in flight would
  sit, and a credit or stall arriving from the receiver would be lost. That
  is safe only if the source's sleep condition includes every outgoing
  repeated link having all its credits home, so that nothing is in flight in
  either direction.

## Wrappers and links

**Decided (Q-44): repeaters live in hardening wrappers above the blocks**,
the physical hierarchy. Every block instance sits in a wrapper of the same
instance name, generated by `tools/gen-top.py` into `rtl/top/wrap/`. The
hierarchy is stable whatever the floorplan decides.

```
ccv_core_top            the 45 wrappers and the nets between them
  u_fet   : ccv_fet_w     the block (u_blk) and one ccv_seq_rpt per channel
    u_blk : ccv_fet       end it owns (u_rpt_<chan>[_c<NN>]), whether or not
    u_rpt_fet_dec_instr   the link is repeated
    ...
  u_lane_05 : ccv_lane_w  32 lanes, one module, per-instance parameters
```

**A wrapper has the block's port list, exactly.** It includes the same
generated `ccv_<blk>_ports.svh`. Block RTL and its port list therefore stay
the swap boundary: C++ shim, stub or RTL, inside a wrapper that doesn't
change.

**Every channel end has its repeater, at `STAGES` 0 unless configured.** A
stage count is a wrapper parameter the top sets (`RPT_<CHAN>[_C<NN>]`), and
only non-zero ones appear. A new split changes parameters, never structure.
32 lanes with the same split stay one module, `ccv_lane_w`.

**The configuration is one file, `params/links.json`.** Each entry gives a
channel instance's route in the direction of valid, as wrapper:stages hops:

```json
{"channel": "fet_dec_instr", "route": "src:1 > dst:1"}
{"channel": "dec_ooe_uop",   "route": "src:0 > miu:2 > dst:1", "why": "passes over MIU"}
{"channel": "rcu_lane_ops",  "copies": "all", "route": "src:1 > dst:1"}
{"channel": "rcu_lane_ops",  "copies": [7],   "route": "src:1 > lane_06:1 > dst:0"}
```

- **Ends:** `src` and `dst` are the channel instance's own endpoints (for a
  replicated channel, this copy's). Anything between them is a
  **feedthrough**: another wrapper the channel crosses, which holds those
  stages. That wrapper gets `fti_*`/`fto_*` ports for the channel, and with
  them a module of its own (`ccv_lane_06_w`), since its ports now differ
  from its type's.
- **Defaults and overlaps:** a channel instance that no entry covers is
  `src:0 > dst:0`. An entry naming `copies` beats an `"all"` entry for those
  copies; any other overlap is an error.
- **Top nets:** a routed channel runs in segments between wrappers,
  `<chan>[_c<NN>]_h<j>...`. An unrouted channel keeps its plain name, so an
  unrepeated top reads as it did before.
- **Checked whenever the generators run** (`tools/ccv_links.py`, one parser
  for both the SV and the C++ side). Every problem is reported together, by
  entry:
  - unknown channels, wrappers and keys;
  - malformed hops, and routes that don't run from `src` to `dst`;
  - stages above 16, or at the EXTERNAL end, which has no wrapper;
  - a route passing its own ends, or any wrapper twice;
  - lockstep copies whose totals or src stages differ. The checker bank
    watches each link where it leaves the source's wrapper, so lockstep
    copies must be level there too.

**What a link's total N derives, from that file and nowhere else:**

| Where | What |
|---|---|
| its checkers (the generated bank) | `ROUND_TRIP` +2N, `TIMEOUT_N` +2N, `SRC_STAGES`; the wake checker's `ARRIVE` |
| the C++ skeleton (`ChanInst.stages`) | the slot's latency, modelled flop for flop as the repeater builds it, and credit depth +2N |
| the SV-hosted run | nothing extra: the wrappers' real repeaters are the latency, and each shim writes its own end of the slot |

The C++ link model and the SV repeaters are checked to be the same machine.
The busy split in `test/phys/links_split.json`, SV-hosted, gives the C++
skeleton's run cycle for cycle (`tools/check-links.sh`).

## Checked

`tools/check-phys.sh`, in the gate, for the widget:

- **Lint:** `-Wall`-clean in six shapes: 0, 1 and 3 stages, with and
  without lead fields and trace.
- **N = 0..4, on Icarus and Verilator** (`test/phys/tb_seq_rpt.sv`):
  - the credit checker is quiet at the sender, mid-link and at the receiver;
  - every message, lead slice and trace id arrives intact;
  - every signal arrives exactly N cycles late, both ways;
  - the three rates in the table above come out exactly.
- **The netlist** (`tools/check-rpt-enables.py`, on Yosys): each stage's
  payload and trace id are enabled by that stage's valid flop, lead slices
  by its input valid, and the four pulses are reset and never enabled.
- **Controls that must fail:**
  - payload enabled by the same cycle's valid: data errors;
  - lead enabled a cycle late: data errors, and refused by the netlist check;
  - credit skipping a stage: latency errors;
  - the receiver-end checker told it sits at the sender: `stall_honoured`
    fires, there and nowhere else;
  - payload loading every cycle: **invisible in simulation**, and the check
    asserts the run is clean, so the netlist check has to refuse it, and
    does.

`tools/check-links.sh`, in the gate, for wrappers and links:

- **Validator:** eleven malformed configurations, each refused with its
  reason named.
- **`test/phys/links_split.json`, end to end in a copy of the tree.** Every
  feature at once: a link split between both ends, feedthroughs across MIU,
  SPM and a neighbouring lane, the lockstep lane channels and both EXTERNAL
  links. 277 slots are repeated. It gets what the real tree gets:
  - the top-level rule at both levels;
  - the S0 suite with every negative control;
  - the wiring traced flop by flop, equal to the C++ skeleton's with stage
    counts, 561 stages;
  - every S1 kernel equal to ccv-sim (vadd in 425 cycles, not 361);
  - SV-hosted equal to C++-hosted: four kernels and 15 controls, with both
    skew controls caught.

**What the first split found, beyond itself:** the S0 exerciser was
**losing credits** in every configuration. A keyed receiver could pop one
slot twice in a cycle, which returns one credit for two messages; that
happened 7 to 10 times a run, abutted. Nothing reported it: the orphaned
message only ages out on an idle slot, and the run's drain ends first. The
deeper queues of a repeated link starved a slot outright. The fix:
- the exerciser takes one head per slot per cycle;
- a receiver counts a double pop as a leak;
- S0 and every kernel run now require `credit_leaks=0`, and S0 also
  requires every sender's credits home after the drain (`credits_home`).

A misorder report capped at five lines across all channels had also let one
busy channel hide another. It now reports the first mismatch on each
channel.

## Not yet

- **No link is repeated in the design.** `params/links.json` is empty until
  the floorplan says otherwise. Clock source per link is Q-45, and the base
  credit depth is Q-43; depth follows N already.
- **Full abutment is Q-42.** The broadcast and star fabrics (clock, reset,
  kill, CSR) are nets at the top, not channels, so `links.json` doesn't
  route them.
