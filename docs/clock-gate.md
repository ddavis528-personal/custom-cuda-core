# Clock gating: the ctech layer and the block clock gate

Every block runs on a clock it gates itself (CCV-L22), and every clock gate in
the design is one module, `ccv_clk_gate`, whose gating element is one ctech
cell, `ccv_ctech_icg`. This page covers both: the ctech mechanism, which forces
a real ICG in synthesis while simulating a behavioural model, and the gate's
sleep policy and wake guarantee.

| Where | What |
|---|---|
| `rtl/ctech/sim/` | simulation and formal view of every ctech cell: behavioural, latch included |
| `rtl/ctech/<library>/` | one view per process library: nothing but an instance of the library's cell |
| `tools/ccv_ctech.py` | picks a view's files; every build takes its view from here |
| `rtl/clk/ccv_clk_gate.sv` | the block clock gate: sleep policy, wake path, the ICG |
| `tools/check-ctech.sh` | the views agree; synthesis gets the cell; simulation is glitch-free |
| `test/formal/fv_clk_gate.sv` | the gate's proofs, run by `tools/check-formal.sh` |

## The ctech layer

A **ctech cell** is a module with one fixed port list and one definition per
**view**. RTL instantiates the ctech module, never a library cell, so the
design is written once and the cell is a file-list choice.

- **The simulation view** (`rtl/ctech/sim/ccv_ctech_<cell>.sv`) models the
  cell's function. For the ICG that includes the latch: the enable is captured
  while `clk` is low and held while it is high, so an enable that moves during
  the high phase cannot chop the gated clock.
- **A library view** (`rtl/ctech/<library>/ccv_ctech_<cell>.sv`) is one
  instance of that library's cell, pins mapped, and nothing else. Its
  `lib_cells.v` declares the ports of the cells it uses, so the view elaborates
  in this repository's checks without the PDK; a synthesis file list leaves it
  out (`--synth`), since there the library supplies the cells.
- **Selection** is by file list only: `python3 tools/ccv_ctech.py [VIEW]`
  prints a view's files, with `VIEW` defaulting to `$CCV_CTECH`, then `sim`.
  The top-level checks, the SV-hosted run and the purity check all take their
  files from it.

**Rules that keep the swap sound:**

- **The simulation view refuses synthesis.** Under `SYNTHESIS` it instantiates
  a module that does not exist, `ccv_ctech_sim_view_in_synthesis`. A
  synthesised behavioural latch would work in every simulation and quietly
  give up the cell's clock-gating timing checks.
- **Only `rtl/ctech/` may hold a latch, a clock built from a clock, or a clock
  read as data.** CCV-L27 enforces it everywhere else, and requires every file
  in `rtl/ctech/` to carry `// Ctech: <cell> -- <view>` (and no file outside
  it).
- **Every view defines the same cells with the same ports.**
  `tools/check-ctech.sh` compares them on every run. Where the vendor's own
  model is vendored (sky130, under `test/ctech/vendor/`), `lib_cells.v` is
  checked against it too.

**Views today.** sky130 and ASAP7 are open libraries, used here because their
cells can be checked. The target library is Q-48.

| View | ICG cell | Pins (clock, enable, test, out) | Checked against |
|---|---|---|---|
| `sim` | behavioural | `clk`, `en`, `te`, `gclk` | the sky130 cell's model, sample for sample |
| `sky130_fd_sc_hd` | `sky130_fd_sc_hd__sdlclkp_1` | CLK, GATE, SCE, GCLK | the vendored cell model, in simulation |
| `asap7` | `ICGx1_ASAP7_75t_R` | CLK, ENA, SE, GCLK | its Liberty pin roles (structurally only) |

**Adding a library:** a directory `rtl/ctech/<library>/` holding a
`ccv_ctech_<cell>.sv` for every cell in `sim/`, plus `lib_cells.v`. The
consistency and synthesis checks pick it up with no edit.

**Adding a cell** (a metaflop is the next one): its simulation view in `sim/`,
one view per library, and a testbench under `test/ctech/` that the check runs,
with a mutant of the simulation view it must catch. Until every library has a
view of it, the consistency check fails, which is the point.

### What `tools/check-ctech.sh` checks

- **The views agree:** same cells and ports in every view, and sky130's
  `lib_cells.v` matches the vendor's cell.
- **Synthesis:** `ccv_clk_gate` with each library view synthesises to exactly
  one library ICG, with `clk` on its clock pin and its output as `gclk`, both
  direct, and no latch. The simulation view is refused, by name.
- **Simulation:** `test/ctech/tb_ctech_icg.sv` moves `en` and `te` at random
  in either phase for 2000 cycles. Every gclk edge must be at a clk edge, and
  each clk rise must pass exactly when `en | te` was high just before it. It
  runs on Icarus and Verilator. The sky130 view also runs through the vendor's
  cell model, and the simulation view runs beside that model, which must agree
  at every sample.
- **Mutants:** the simulation view with no latch, and with its latch open in
  the high phase. Both simulators must fail each one.

## The block clock gate, `ccv_clk_gate`

One per block, the block's first act. It takes `core_clk` ungated.

| Port | Dir | Meaning |
|---|---|---|
| `clk`, `rst_n` | in | `core_clk`, ungated; the reset |
| `quiesced` | in | from the block: nothing in flight, nothing owed |
| `stalled` | in | from the block: nothing can move until an input changes |
| `wake[NWAKE]` | in | any one opens the next edge; the block ORs its wake sources in |
| `cg_override` | in | force the clock on (chicken bit) |
| `te` | in | scan test enable, to the cell's own test pin |
| `gclk` | out | the block's clock: everything sequential in the block runs on it |
| `gated` | out | 1: the coming edge will not reach the block. The block's `clk_gated` |

**Sleep entry, with hysteresis.** The gate closes once `quiesced` has held
for `HYST_QUIESCE` consecutive cycles, or `stalled` for `HYST_STALL`. The edge
that ends the last of those cycles is delivered, and the next one is not.
Both conditions come from the gated domain, so once the gate closes they hold
still and the block stays asleep until something outside it changes. The two
are separate because a stall usually ends by itself within a few cycles. The
defaults, `CCV_CG_HYST_QUIESCE` = 8 and `CCV_CG_HYST_STALL` = 16, are
placeholders ("tunable"; decided by power analysis). Each block may override
them on its own instance. A hysteresis below 1 is refused at elaboration:
it would put the block's own combinational idle logic on the enable path.

**Wake, within one cycle.** `wake` goes straight to the ICG's enable, past
every register in the gate. A wake that is high in a cycle therefore opens
the edge that ends that same cycle. The gate then stays open for
`WAKE_HOLD` more edges, whatever the block reports. `WAKE_HOLD` defaults to
`CCV_WAKE_LAT`, and a smaller value is refused at elaboration. The hold is
what makes Q-33 work from the receiver's side: a sender may put valid
`CCV_WAKE_LAT` cycles after its wake, and the receiver must still be running
then, even with nothing to do in between. `ccv_wake_checker` now states that
half too, as `wake_keeps_rx`.

**What a block ORs into `wake`:** anything that must reach it while it sleeps.
- every inbound channel's `_wake`;
- any credit return or request it sleeps waiting for;
- for a condition that is a level, not a pulse (a stall that releases), an
  edge. Detecting that edge needs a flop on the ungated clock. That flop is
  the one thing besides this gate CCV-L22 lets a block clock on `core_clk`.

**Override, reset, test.**
- `cg_override` forces the gate open.
- So does reset: resets are synchronous, so a block in reset must be clocked
  or it never resets, and `!rst_n` opens the gate the cycle it arrives.
- `te` goes to the cell's own test pin, as scan expects. It is not part of
  the functional enable.

**Where the gate's state lives.** The gate has three counters of
`$clog2(max(HYST_QUIESCE, HYST_STALL, WAKE_HOLD) + 1)` bits, 15 flops at the
defaults. They run on the ungated clock, because they must see every cycle and
a gate clocked by its own output is a loop that timing analysis does not like.

**Timing.** The enable path starts at a flop in the gate, or at the far end
of a wake net: a flop in the sender, or the last repeater stage of the link.
It ends at the ICG's enable pin, which sets up to the rising edge at the root
of the block's clock tree, earlier than the flops see it. It is the one path
from another block into a clock gate. If it does not close, registering the
wake at the receiver costs one cycle, which `CCV_WAKE_LAT` = 4 has room for,
since the gate itself uses none of it (Q-49).

**Today.** Every stub and every SV-hosted DPI shim instantiates the gate tied
never to close: `cg_override` = 1, `wake` = 0, `te` = 0 (Q-46, Q-47). Its
`gated` is the block's `clk_gated`, so the checker bank reads the gate's own
decision. The shims clock on `gclk`, and the SV-hosted run still matches the
C++ skeleton cycle for cycle. `check-top-pure.py` rule R7 requires every block
to have exactly one `ccv_clk_gate`, clocked by its `core_clk` port, with
`clk_gated` driven by that gate's `gated`. It also allows the ICG nowhere
else. Mutants `gatetie` and `gateclk` must each be refused.

## Proved: the gate, as it switches

`tools/check-formal.sh` proves `ccv_clk_gate`, with the simulation view of its
ICG, on Yosys's multiclock model. There `clk` is an input and each phase lasts
one global step or two (F-21), so the latch and the AND are modelled as they
switch. The proofs run at hysteresis 3/5 and at the defaults 8/16, with hold
`CCV_WAKE_LAT`, and start from arbitrary flop contents with the first cycle
in reset.

| Property | Stimulus | Fails on |
|---|---|---|
| the gated clock is clean: high only while clk is, rising and falling only with it | every input free at every step | an ICG with no latch; a latch open in the high phase |
| `edge_decides`: the edge that ends a cycle reaches the block exactly when `gated` was low | inputs move as flops on clk | |
| `spec`: `gated` equals a model built from input histories (shift registers, not the gate's counters) | as above | hysteresis one short |
| `wake_next_edge`, `wake_hold`, `override_opens`, `reset_opens`, `te_opens` | as above | a wake registered before the cell (not within a cycle); reset left off the enable |
| `wake_keeps_rx`: running `CCV_WAKE_LAT` cycles after any wake | `ccv_wake_checker`, the sender's half assumed | a wake hold one short |
| `q33_valid_meets_clock`: no contract-keeping valid arrives on a withheld edge | as above | |
| witnesses: the gate closes; a valid is captured right after a sleep | | |

## Open

- **Q-46:** who drives each block's `te`.
- **Q-47:** CSR control of `cg_override` and the hysteresis.
- **Q-48:** the target library.
- **Q-49:** the wake-to-ICG-enable path budget.
