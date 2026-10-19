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

Reuse of a freed resource at the edge that frees it is decided structure
by structure, from synthesis serial gate counts (DA's response OI-39,
2026-10-16). It replaces OA's proposed OOE-wide rule. The decode queue
holds a freed entry for a cycle, because it fits its stage only so (OI-39).
The free list does too, in OA's OI-38 design: an 8-entry candidate buffer
refilled from four interleaved banks (built: 23.0 NGD). The RS and ROB keep same-edge reuse
unless their RTL measures over the stage. The design doc states this
rule from rev 193 (OA's response OI-39).

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

- **`ooe_freelist`**, a free list in OA's design (OA's response OI-38):
  a bit per entry, and an 8-entry buffer of free entries that is the only
  source of allocations. Up to four allocations a cycle take the buffer's
  head, so the grant has no search. At each edge four interleaved banks
  (entry mod 4) each find their first free, unbuffered entry after their
  own rotating pointer, and append in a rotating bank order while there is
  room. A free reaches refill a cycle later and allocation the cycle after,
  the one-cycle hold DA's response OI-39 allows where depth needs it. The
  model's `FreeVec` is the same structure (`fl_buf`, `fl_banks`; 0 is the
  old rotating-pointer list), and no S1 kernel or four-warp sweep arm moves
  by a cycle between them. `test/ooe/freelist_tb.cpp` compares, before
  every model cycle, the RTL's state after the last edge with the model's
  (`FreeVec::lastEdge`: free bits, buffer in order, bank pointers, bank
  order), then drives that cycle's allocations and frees. Over 25 seeds and
  200 cores, GPR rows (192) and predicates (48), none differ; controls
  drop-free and extra-alloc must each be caught. Logic depth is 21.6 NGD at
  192 entries and 22.6 at 48, the requests 18.6 and 18.4 to a flop (23.0
  and 23.4 before): a log-depth find-first per bank, the buffer rebuilt
  slot by slot as a gather, the buffered mask kept as state, and the taken
  count one-hot from the request prefix. Every select that depends on how
  many are taken is formed for each count from the state and picked by
  that one-hot, so the requests reach the edge through AND-ORs, never a
  subtract. The free bits, bank pointers and bank order are ports under
  CCV_CHECK only, read by the bench alone (OA's choice, TI-20). The grant ports carry the head
  from the flops alone (OA's stage-boundary map, item 5): head entry k is
  available while the buffer holds more than k, and rename's port k takes
  it when it asks, so no request reaches an output (NGD-5).

  Local clock gating (TI-14): the free bits are one gate, clocked on an
  allocation or a free; the buffer, its count, the bank pointers and the
  buffered mask on an allocation or while the buffer has room. Whether a
  refill really comes is a search of the pool, 9 to 11 NGD as an enable,
  so the gate takes room alone. The buffer's gather and the pointers' moves
  are AND-ORs, not held `if`s, so synthesis keeps those enables rather than
  one per slot or per bank. The two-bit bank order turns every edge,
  ungated, within the module's allowance. `check-cg`: worst enable 7.8 NGD
  (GPR) and 5.6 (predicates), 100% DCGE in every scenario. In its clock-
  gating mode the bench frees through a map from the model's entries to
  the RTL's, since the idle cycles turn the RTL's bank order alone.

  Restore-allocate takes its 16 GPRs and 4 predicates through the same
  buffer and ports, up to four a cycle, while rename stalls for every
  warp (OA's response OI-41). So the RTL needs no second path, and the
  bench fails a cycle with more allocations than ports instead of skipping
  it. The model holds the port count as an invariant every cycle.
- **`ooe_age`**, an RS class's age matrix: a bit per ordered pair, set
  when the column's entry was allocated first. Up to four allocations a
  cycle, in port order; each writes its row (every valid entry, and every
  lower port's, is older) and clears its column. The matrix is un-reset
  payload guarded by the RS valid bits (decision 6), and an assertion
  checks V-13's antisymmetry over every valid pair. `test/ooe/age_tb.cpp`
  snapshots the model's RS ages (`Core::rsAge`) before every cycle and
  drives the RTL with the allocations between snapshots, for both classes:
  25 million RCU pairs and 5 million MIU pairs compared, none differ.
  Controls no-valid and port-reverse must each be caught. Logic depth is
  10.1 NGD in 9 levels at 30 entries. Local clock gating (TI-14): the
  matrix is one gate, clocked on an allocation (`older_en`, 2.2 NGD); its
  column clear is written as an AND, not a held `if`, so synthesis keeps
  that enable rather than a per-bit one. `check-cg` measures a lowest DCGE
  of 99% for the MIU class and 100% for the RCU class, medium and high.
- **`ooe_decq`**, the decode queue (decision 3): 12 entries shared by the
  four tier-1 slots, six arrivals and up to four dequeues per slot a
  cycle. Each entry holds its payload, a busy bit, its owner and its
  position in the owner's FIFO. That is the per-warp FIFO, kept as
  positions rather than pointers: a dequeue of n frees the owner's
  entries below n and moves the rest down by n, and rename reads a slot's
  k-th oldest as the entry it owns at position k. An arrival takes the
  free entry with as many free entries below it as arrivals ahead of its
  port (a banked prefix count). The model now numbers its decode-queue
  uops and records the slots a squash flushed (`Core::decodeQueue`,
  `Core::decqFlushed`); `test/ooe/decq_tb.cpp` drives the RTL from those
  before every cycle and compares every slot's four oldest, its count and
  the credits. Over 25 seeds: 103,896 arrivals, 98,193 dequeues, 2,357
  flushes and 47,940 cycles with the pool full, none differ. Controls
  drop-flush and enq-swap must each be caught. Logic depth is 19.6 NGD
  in 19 levels (gated-flop flow; 23.1 before), inside the stage, because an entry freed at an edge takes
  no arrival until the next (DA's response OI-39; the model's
  `decq_late_credit`, now on). With same-edge reuse, as the model had it,
  it was 31.9 NGD: that path cost about 9 NGD. Turning the knob on moves
  no S1 kernel by a cycle, and the four-warp synthetic sweep stays within
  its own noise.

  Local clock gating (TI-14): the queue is clocked on an arrival, a
  dequeue or a flush. An idle entry's payload, owner and position are
  cleared rather than held (they are read only through busy), so no field
  is held through an `if` and synthesis keeps that one enable. `check-cg`:
  5.5 NGD of enable, 98% DCGE in medium and high, idle clocks nothing.

  Verilator 5.020 miscompiled an earlier form of this module: an
  `always_ff` whose reset and update were an if/else of two function
  calls. `-fno-reorder` fixed it, and Icarus ran it correctly. Each
  sequential sub-block's flop now takes one function, `step()`, with reset
  folded in. The gate now runs Verilator 5.052 (OI-40), and every OOE
  bench passes under it; the `step()` form stays, as the clearer one.
- **`ooe_wake`**, the wake timers (OA-1: "wake generation is registered
  timers, off this path"): one per RS entry, driving the four lines
  `ooe_ready` reads as flops, so each is decided at the edge before the
  cycle it holds for. A grant starts the timer; its age counts cycles
  since and saturates. Line k < 3 rises at the class's fastest bypass
  point plus the k-th penalty. The full-latency line rises at the class's
  latency, at CCV_LAT_LANE for a masked load's copy, at CCV_LAT_L1_WAKE for
  an L1-contracted load, or, for a timer that waits, on its done (RCU
  class) or CCV_LAT_L1_MISS_WAKE after its completion. An L1 load with no
  completion by payload stages + CCV_LAT_L1_CMPL is the miss: the line
  drops and a miss pulse starts cancel's first hop. A replay or a free
  clears issued, which every line is gated by (the reset line's guard).
  A fifth output, fin, is the timer's word to confirmation: the
  full-latency line raised and no miss check pending. Confirmation frees
  an entry in the cycle its line rises, so a completion's effect is seen
  only there. The model logs what reached each timer every cycle
  (`Core::wakeLog`: grants with their kind and class, dones, completions,
  stops, misses, and confirmations on the timer's word);
  `test/ooe/wake_tb.cpp` clocks the RTL with them after every model cycle
  and compares every valid entry's lines with `Core::wakeLine`, every miss,
  and fin with each confirmation and `Core::rsFinal`. Over 25 seeds: 26,771
  grants, 3,068 completions, 427 misses, 20,801 confirmations and 2.15
  million line comparisons, none differ. Cores whose bypass table has four
  penalties (the bypass-group seeds, which `ooe_ready`'s bench skips too)
  or whose completion delay is not the parameter's are skipped and
  counted, 67% of cycles. Controls late-grant, drop-cmpl and drop-stop must
  each be caught. Logic depth is 15.3 NGD in 13 levels at 45 timers.
  Local clock gating (TI-14): each timer is its own 20-flop gate, clocked
  on its grant or stop, while issued until its age saturates, on a done or
  completion after that, and one edge more to clear a miss pulse or a
  final flag a stop left. `tools/check-cg.py --unit ooe_wake` measures
  4.8 NGD of enable and a lowest DCGE of 99% (medium) and 98% (high); idle
  clocks nothing. The earlier 13.9 NGD was short: Yosys dropped the age
  increment of the `(age == AMAX) ? AMAX : age + 1` form, which only the
  CG replay (the netlist against the bench's trace) showed.
- **`ooe_confirm`**, confirmation and transitive cancel. Its hop returns
  to Waiting every issued, unconfirmed entry that depends on an entry
  that missed this cycle or returned to Waiting last cycle, through a
  register of last cycle's replays. The miss comes from the timers' next
  state, so the first hop lands in the miss's own cycle. Confirmation takes
  an issued entry with no dependency bit left whose result is final
  (`ooe_wake`'s fin) or that writes nothing. Both are a row-wide OR over
  the matrix: 9.1 NGD in 7 levels at 45 entries. The model's `confirmPass`
  chained confirmations oldest first within a cycle, and a miss meeting a
  live cancel took two hops in a cycle; both now take one level a cycle,
  as the RTL does. A probe found neither had ever happened in an S1 kernel
  or a random seed, and no kernel moves by a cycle. The model logs each
  hop's and pass's inputs and decisions (`Core::wakeLog`);
  `test/ooe/confirm_tb.cpp` drives the RTL with the inputs and compares
  both decisions every cycle. Over 25 seeds: 961 replays and 82,148
  confirmations, none differ. At today's latencies no cancel needs a
  second hop, so one random seed in seven now runs the controls' long L1
  shadow, which makes the bench's no-carry control (no hop past the first)
  catchable. Controls no-miss, no-fin, no-dep, no-carry and no-hcol must
  each be caught. Local clock gating (TI-14): the replay register is one
  gate, clocked while a cancel spreads: a hop under way, or a miss of an
  entry whose column `ooe_rs` flags (`hcol`, below). Clocked on every miss
  it changed on 65% of its enabled cycles, since a miss nothing waits on
  writes zero over zero; the exact enable, the hop's own OR, is 13.0 NGD.
  With the flags it is 7.3 NGD and 79% (medium and high). The bench keeps
  the flags as `ooe_rs` does, and no-hcol (all clear) starts no hop.
- **`ooe_rs`**, the RS valid bits, allocation and the dependency matrix.
  Each class has four ports; port k takes the free entry with exactly k
  free below it in its class, first fit as the model's `rsAlloc`. An entry
  freed this cycle counts as free, so the RS keeps same-edge reuse. The
  free counts saturate at four and are kept as thermometers, so two add
  as an AND-OR, and they come from a Sklansky prefix tree. Counted with
  saturating adders in banks, the allocation alone was 60 NGD; the tree
  makes it 12.6. An allocation writes the whole row, naming entries
  granted this cycle to another port, in either class, by port; a free
  clears the entry's column. The model logs each cycle's allocations in
  order and its frees (`Core::wakeLog`); `test/ooe/rs_tb.cpp` compares the
  grants, the valid bits and every valid row's bits and line selects. Over
  25 seeds: 100,804 allocations, 36,698 of them into an entry freed that
  cycle, 4,294 in-group references, none differ. Controls no-same-edge,
  drop-group and stale-hcol must each be caught.

  The outputs leave from registers of their own (OA's stage-boundary map,
  item 3; TI-20, NGD-7): the grant, registered at the edge it is made, and
  a `(* keep *)` copy of the valid bits (`valid_out`), so the valid bits
  allocation reads drive no output. These 101 flops change with every
  grant and free, so they take no clock gate, within the module's
  allowance (check-cg: 95 auto-waived of 126). The bench compares the
  registered grants after each edge, every port's. With OA's row_dep
  arrival (by 10, OI-48), the only depth finding left is the confirmation
  path's free (NGD-3, OI-43 and OI-50).

  Column flags (`hcol`, for `ooe_confirm`): per class, a column is flagged
  from the edge a row of the class naming it is written until the entry is
  freed, so a set bit in a valid row is always flagged. The bench keeps
  that definition and compares every column after every edge; stale-hcol
  keeps its reference through a free and must be caught.

  Local clock gating (TI-14): each class's state (valid bits, rows, line
  selects and flags) is one gate, clocked on an allocation in the class, a
  free in it, or a free of a column its flags name, so an MIU row is not
  clocked by an RCU free it does not wait on. A held row keeps its line
  selects where its bits were set, an AND with the bit's flop rather than a
  held `if`: synthesis would otherwise take each row's grant as its enable,
  12 NGD and more. `check-cg`: 7.2 NGD of enable, 98% DCGE in medium and
  high, nothing clocked in idle.

  Depth decides same-edge reuse (DA's response OI-39). `ooe_rs` is 20.2
  NGD in 19 levels with it and 18.4 without. The path that decides it
  starts at the confirmation: `ooe_confirm`'s confirmations, from flops,
  as the frees, through allocation into the row write
  (`test/ooe/ooe_rs_confirm.sv`, a probe). That was 24.5 NGD in 21 levels,
  under the stage, so the RS keeps same-edge reuse, with a margin of
  0.5 NGD, measured as every other block here is: logic only, no flop or
  wire. Clock-gated, it is 25.2 NGD in 23 levels, 0.2 over: the gated RTL
  adds about 0.8 NGD on this path (the committed RTL measures 24.4 under the
  same flow), within the spread ABC shows between equivalent forms (24.7 to
  26.2 here), but over. Open for DA under OI-39.

  `test/ooe/depth.sh` now maps a clock-gated flop as the design has it: a
  plain flop on its next value, the enable timed apart to its ICG and held
  within 8 NGD by `check-cg` (`test/ooe/ungate.py`). Mapped as a flop and a
  hold mux, the probe was 27.6 NGD; that mux is not in a gated design.
- **`ooe_select`**, the requests and the two per-class `ooe_pick`s. An
  entry requests its footprint when it is valid, not issued, past rename's
  stages, its warp active, its row ready and its resources free of a bulk
  discard. A copy also needs confirmed sources, and a memop confirmed
  sources, no bulk discard of its warp, its copy issued in an earlier
  cycle, and no older unissued memop of its warp: a row-wide OR over the
  age matrix. Confirmed sources is "no dependency bit left", since a
  confirmed entry is freed and its column cleared in the cycle it
  confirms. The model's `selectSectioned` logs its inputs, candidates and
  grants as it runs; `test/ooe/select_tb.cpp` drives the RTL with them.
  It follows cores with sectioned lanes, renamed predicates and memops in
  program order (OA-13's relaxation is not built, OI-15 holds). Over 25
  seeds: 18,516 select cycles, 42,610 candidates and 16,642 grants (3,442
  memops), none differ. Controls no-order, no-conf and no-busy must each
  be caught. Logic depth is 19.5 NGD in 16 levels: inside the stage, but
  over OA-1's 14.6 of select logic, which costed the pick alone. The
  request terms (confirmation, memop order, the copy, warp active) come
  first. All of them depend only on state from earlier cycles, so they
  can move into the previous cycle's flops if the margin is needed.

- **`ooe_rat`**, the register alias tables, the first of rename's two
  modules. Per tier-1 slot: the speculative GPR and predicate maps, the
  committed ones (the demotion map) and four checkpoints of the
  speculative maps, taken when a branch renames and restored in one cycle.
  A GPR name is a row and a position. One edge applies, per slot, a
  checkpoint restore, a squash to retirement or a release, then retire's
  writes to the committed maps, then rename's four ports in order; a port
  reads its three sources, old destination, guard, old predicate
  destination and predicate-logic sources as the lower ports of its slot
  left them (the in-group override), and a branch's checkpoint is the maps
  after its own writes. A restore-allocate writes both maps through the
  same ports (OI-41). Rename never names a slot that a whole-map event
  names in the same cycle (a mispredict's epoch drops the warp's queued
  uops; a demoting, killed or freed slot does not rename), so the reads
  come from the flops, and an assertion holds it. Checkpoint live bits
  stay with branch resolution. The model logs what reached its maps each
  cycle (`Core::ratLog`); `test/ooe/rat_tb.cpp` drives the RTL from it,
  through the directed tests (demotion, kill, restore-allocate, which
  random traffic never reaches) and the random ones, and compares every
  read and, after the edge, every map and live checkpoint: 101,484 renames,
  58,373 in-group reads, 7,643 checkpoints, 2,458 restores, 65,854
  retirements and 36 restore-allocate writes, none differ. Controls
  port-reverse, drop-restore, drop-retire and drop-squash must each be
  caught. Logic depth is 13.8 NGD in 13 levels.

  Local clock gating (TI-14): each slot's speculative maps are one gate,
  clocked on a rename write to the slot or a whole-map event; each
  committed GPR entry is its own gate, each slot's committed predicates
  one, and each checkpoint one, written when its branch renames.
  `check-cg`: 88 gates, worst enable 7.8 NGD, lowest DCGE 94%. Per-entry
  gates on the speculative maps measured 69%: a mispredict clocks all
  sixteen entries and most still hold the checkpoint's names. Clocking
  only the changed entries needs a compare (11.8 to 13.0 NGD as an enable)
  or "written since checkpoint c" bits (320 flops), so the slot is one
  gate. Every read and write is a decoder: written through computed
  indices, Yosys built 420,000 gates and ran out of memory; as decoders it
  is 52,000.
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
