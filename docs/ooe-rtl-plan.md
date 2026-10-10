# OOE Stage 4c: what the RTL needs decided first

The Stage 4b model ([`ooe-model.md`](ooe-model.md)) is functional and
cycle-defined. Several of its structures are model conveniences that no
hardware builds as written. Strategy §8 opens 4c with an RTL grill-me for
exactly this, and [`ooe-4b.md`](ooe-4b.md) lists the 4a items still missing
for OOE. This file is the agenda: each decision, the options, and a
recommendation. The model changes first wherever a decision changes
behaviour, so the RTL still has one reference to correlate against.

## Status (2026-10-09)

Settled since this agenda was written:

- **1, the stage budget.** Q-7 is closed: NGD is normalized gate delays,
  the same at every corner. OA's paper estimate (OA-1, revised for the
  sectioned select) puts ready at 16.1 NGD and the per-resource select at
  17.6 (30 entries) and 15.7 (15 entries). The model carries rename as
  three stages and a payload stage (OI-26).
- **2, the free list.** (a), a bit-vector with a rotating start (OI-22).
- **5, the S1 modes.** Bypass, L1 speculation and predicate renaming are
  all on in the kernels, so the RTL carries one rename scheme.

Decided at the RTL grill-me (DA's response OI-36, 2026-10-10): **3**, per-warp
decode FIFOs on a shared 12-entry credit pool; **4**, payload in the RS, read
through the grant; **6**, the reset line as the design doc's Reset line
section states it (OA's response OI-36). Sub-blocks are named
`ooe_<name>` and run on `ooe_core_clk` (DA's responses OI-37).

Built (`rtl/ooe/`):

- **`ooe_pick`**, one RS class's per-resource select, combinational.
  `test/ooe/run-rtl.sh` holds it in lockstep with `ooe::pickResources`,
  the function the model's select calls, at both classes' sizes. Its
  controls (youngest-wins, any-wins, no-mask) must each be caught.
  `test/ooe/depth.sh` maps it to NAND-equivalent gates (each gate at its
  fanout-of-4 delay). The 30-entry pick's logic is 9.4 NGD in 7 levels,
  against the estimate's 9.1 of logic. The 15-entry pick's is 8.1 in 6,
  against 7.7. Both are inside the estimate's stated ±15%, so the select
  stage is about 17.9 and 16.1 NGD of 25.
- **`ooe_ready`**, the ready stage over all 45 entries, combinational:
  - each producer drives four wake lines: its fastest bypass point plus
    each of the three bypass penalties, and last the PRF read;
  - each matrix cell selects one line, and a row is ready when every cell
    it depends on sees its line raised.

  The model carries the same structure (`Core::cellCode`,
  `Core::wakeLine`) and checks every cycle that it reproduces `rowReady`
  ("ready-structure"; a one-cycle mutation of the lines is caught).
  `test/ooe/ready_tb.cpp` runs the model's random unit tests and drives
  the RTL from the live core after every cycle. Cycles whose knob-set
  bypass table has more distinct penalties than the lines carry are
  skipped and counted. Controls code-shift and no-late must each be
  caught. Logic depth is 9.8 NGD in 8 levels, against the estimate's 9.1,
  so the ready stage is about 16.8 NGD of 25.

- **`ooe_freelist`**, a free list: a bit per entry, up to four allocations
  a cycle in rotating order from a pointer, any number of frees a cycle.
  It is the first sequential sub-block, with all its state reset. Its state
  is one register, {pointer, free bits}, whose next value is a function of
  that register and the cycle's inputs alone. That is how a one-cycle loop
  over several fields is written under CCV-L23. `test/ooe/freelist_tb.cpp`
  drives it, just before every model cycle, with one clock edge's
  allocations and frees on the model's own `FreeVec`, for the GPR rows
  (192) and the predicates (48). Over 25 seeds and 200 cores it matches
  every grant, every free bit and the pointer. Controls drop-free and
  extra-alloc must each be caught. **Timing is not met.** Written as a
  behavioural scan, the allocation path synthesises to a ripple chain:
  344 NGD in 250 levels at 48 entries. A parallel-prefix form (rotate by
  masking at the pointer, a saturating prefix count, one-hot to index) is
  about 30 NGD on paper at 192 entries, still over a stage. So allocation
  likely needs candidates prepared a cycle ahead, which changes when a
  freed entry can be taken, and with it the model. That is OI-38, for OA.

## Blocking decisions (the agenda as written, 2026-10-04)

**1. Q-7 and the stage budget.** Is 25 NGD a Vmin or a nominal number? The
model wakes and selects in one cycle (a dependant issues exactly its
producer's latency later), squashes in one cycle and renames four uops a
cycle through a chain of resource checks. Whether those loops fit in one
stage decides how the RTL is pipelined. Any extra stage in the wake-select
loop is visible in the model as a latency, so the model takes it first.
*Recommendation:* a paper estimate of the matrix ready-AND, the per-cell
early/late AOI and oldest-first select at 45 entries, against both readings,
before any RTL. The 4a scheduler-ceiling item is this estimate.

**2. The free list.** The model's free list is a FIFO with unbounded push
bandwidth: one squash can return 32 registers in a cycle, and a kill or
restore 16 or more. Options:

- **(a)** A bit-vector free list with four priority-encoded allocations a
  cycle, starting from a rotating pointer so a freed register comes back
  late. Any number of frees a cycle costs nothing.
- **(b)** A circular FIFO whose head is checkpointed per branch (R10000
  style), so a squash is a pointer restore. A deferred-free register then
  sits inside the restored range and must be skipped, which costs as much as
  (a).
- **(c)** A FIFO with a few push ports, and squash frees drained over
  several cycles behind a recovery stall.

*Recommendation:* (a). The model changes to match. Allocation order then
changes, and so does the exact line `--break free-new`'s check greps for, a
top-level edit.

**3. The decode queue.** The model takes each warp's oldest uop from one
shared, collapsing 12-entry queue. *Recommendation:* per-warp FIFOs that
share a 12-entry credit pool, which is the same behaviour at a fraction of
the compaction logic.

**4. Payload storage.** The model reads every uop field from its ROB entry
at issue. *Recommendation:* the payload lives in the ROB, the RS holds the
ROB index and its matrix row, and the ROB has four read ports for issue.

**5. Which S1 modes the RTL carries.** In-context validation at 4d runs the
RTL among the S1 stubs. That needs the modes the stubs force: no bypass, no
L1 speculation, and fixed-window predicates.
*Recommendation:* bypass and L1 speculation as elaboration parameters,
because they are a gate on an existing path. Fixed-window predicates not in
RTL: they are a second rename scheme. So 4d waits on A-75 and the
predicate-map hook (OI-3 in the cross-agent register).

**6. The reset line** ([`reset-line-template.md`](reset-line-template.md)).
Reset state:

- every valid bit: ROB, RS, decode queue, checkpoint, free-list bit;
- ROB head and tail, epochs, warp-to-slot table, RAT and committed RAT;
- the matrix's dependency bits.

Un-reset payload: ROB uop fields, RS ages, and the late bits, each guarded
by its entry's valid bit. *Recommendation:* adopt as listed, one
`CCV_ASSERT_READ_VALID` per row.

## Settled by the model, carried into RTL as written

- The select order and its rotating tie-break.
- Memop program order per warp.
- Masked-load pairing.
- RS hold until the result confirms.
- ROB-outlives-RS.
- Deferred free for every issued op.
- Barrier at the head.
- The V-35 bound.
- The miss-wake delay.

These are decisions 1 to 11 in [`ooe-model.md`](ooe-model.md). Each is
behaviour, and correlation holds the RTL to it.

## Verification plan

- **Standalone**: Verilator, the RTL against `ooe::Core` in lockstep, both
  driven by the unit tests' environment (`sim/ooe/ooe_test.cpp`), comparing
  every output every cycle. This is 4c's standalone testbench and per-block
  correlation at once.
- **Internal assertions**, inline, through the 1b macros: V-01 on one
  symbolic register, V-07, V-10, V-14, V-15, V-17, V-19, V-22, V-29, and the
  reset line's read-valid properties.
- **Formal**, on the reduced configuration the design doc names: 2 warps,
  ROB 4, RS 6.
- **The X-pass** (Icarus) and lint (`tools/lint-rtl.py`), as for every
  block.
