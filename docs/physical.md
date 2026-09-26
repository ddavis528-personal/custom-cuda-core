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

## Where repeaters live

Undecided (Q-44), and it doesn't block the widget:

- **Inside the blocks**, at their ports. The block owner can merge the first
  stage with the block's own boundary flop and retime around it. But the
  repeater count is a floorplan outcome, and every floorplan iteration then
  edits block RTL.
- **In hardening wrappers above the blocks**, the final physical hierarchy.
  Block RTL and its generated port list stay the swap boundary: C++, stub,
  shim and RTL all remain interchangeable. The top-level rule applies at
  both levels: a wrapper is a block plus repeaters plus nets, and the top is
  wrappers plus nets.

My recommendation is the wrappers, with one caveat that applies either way:
the receiver's buffer, and so its credit depth, is inside the block. The
block therefore needs a per-channel depth parameter, from the same placement
table that sets N.

## Checked

`tools/check-phys.sh`, in the gate:

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

## Not yet

- **No link is repeated.** Every channel is abutted. There is no placement
  table yet for N per channel instance, clock source per link, or depth per
  receiver.
- **The C++ skeleton models no link latency.** Every slot's `Machine` depth
  is 2. The first repeated link needs a delay line in `Slot`, or the
  SV-hosted comparison (which uses the real top) would stop matching.
- **The SV top doesn't instantiate repeaters.** Where they go is Q-44.
