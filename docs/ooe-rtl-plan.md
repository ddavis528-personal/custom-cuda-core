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

  The section fallback (FB, OA's response IS-9): a lane section whose
  winner does not issue grants its oldest requester naming that section
  alone (FB 1), and with FB 2 an aligned half whose sections both fall
  through grants its oldest half-footprint requester if that is the
  oldest of the half's pair and single-section requesters. Each is one
  more oldest-of-N over the same ages, beside the main pick; only "did
  this section's winner issue" waits for it, a 30-wide reduction after
  the issue AND, so it costs more than OA's estimated 2 NGD: the
  30-entry pick is 17.2 NGD at FB 1 and 19.4 at FB 2. A fallback grant
  (`fb_cq03h`) takes only sections no issued entry holds, so V-60 holds,
  and the check that an issued entry won each resource it names covers
  the rest. pick_tb holds FB 1 and FB 2 to `pickResources` (200,000
  vectors each), with controls no-fallback and no-half beside the three.
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

  The request is registered (OA's response OI-52): what a cycle takes
  leaves the buffer at the next edge, so the buffer's next value and its
  enable come from the module's own flops (CG-5). Those entries, in
  transit, sit at the head a cycle: the ports offer the entries behind
  them (a mux on the registered count), and `avail_cq02h`, the count
  rename sees, leaves them out. A taken entry's free bit clears with them,
  at the late edge, from the registered count (OA's response OI-58, V-75):
  exact, since they stay buffered until then and refill cannot take them
  again. Frees come from the retire stage's register and a registered
  squash, never naming an entry granted that cycle (an assertion), and the
  free list flops their lead, the ROB's decision a cycle earlier
  (`free_l`), as the free bits' enable (L2). The bench runs the RTL an edge
  behind the model to drive the lead, and a third control, no-lead, must
  be caught. The ports read a `(* keep *)` copy of the buffer and its
  count, which start no other path (NGD-7: the state's own paths run
  through the refill). The registered count needs no copy: its paths, 19.4
  NGD, are within the ports' required 20 (OA's response OI-60: rename takes
  the names as data, its go and credits in ooe_decq). The reset is flopped before use
  (RST-1). Depth is 21.6 NGD at 192 entries and 22.2 at 48, the requests
  13.2 and 13.7 to a flop (they reach only the free bits and the
  registered count now), the grant ports 11.5 and 10.4 from flops. In the
  model the late pop costs nothing at the 8-entry buffer (982 cycles in
  the sweep, as before) and 4.8% at 4. The bench also compares the
  entries in transit and the available count. The buffer, its count and
  the entries in transit are bench ports under CCV_CHECK.

  Local clock gating (TI-14): the free bits are one gate, clocked on an
  allocation or a free; the buffer, its count, the bank pointers and the
  buffered mask on an allocation or while the buffer has room. Whether a
  refill really comes is a search of the pool, 9 to 11 NGD as an enable,
  so the gate takes room alone. The buffer's gather and the pointers' moves
  are AND-ORs, not held `if`s, so synthesis keeps those enables rather than
  one per slot or per bank. The two-bit bank order turns every edge,
  ungated, as do the registered count and its copy (six flops, within the
  module's allowance). The free bits' enable is still an allocation or a
  free, from the inputs, the one CG-5 finding left. `check-cg`: worst enable 7.8 NGD
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
  Controls no-valid and port-reverse must each be caught. The update is
  one edge after the RS writes the group's rows (OA's response OI-58,
  V-75): it takes ooe_rs's registered grants and the RS valid bits after
  that edge, as data, and select cannot see the delay, since a new entry
  reaches the request register an edge after its allocation at the
  earliest. The bench runs the RTL a snapshot behind the model for it,
  and a third control, no-lead, must be caught. Logic depth is 11.3 NGD
  at 30 entries. Local clock gating: the matrix is one gate, clocked on a
  group's update; its enable, `older_en`, is age's own flop of rename's
  Rename 3 valid for the class (CG-5, 0 NGD past the flop), and the reset
  is flopped (RST-1). Its column clear is written as an AND, not a held
  `if`, so synthesis keeps that enable rather than a per-bit one.
  `check-cg` measures a DCGE of 100%, medium and high.
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
  5.4 NGD of enable, 97% DCGE in medium and 98% in high, idle clocks
  nothing.

  Leads (OA's response OI-58, V-75): an arrival is led by decq's own flop
  of DEC's channel valid (`enq_l`); a squash's flush is registered per slot
  and applied an edge late (`fl_q`), rename taking nothing from the slot
  meanwhile (its rule, from its own copy of the registered squash: the
  outputs still show the old uops, and an assertion holds rename to it),
  the flushed entries holding their credits that edge longer (the model's
  `decq_flush_late`, 1.9% fewer cycles in the synthetic sweep). No uop
  arrives for a slot in its flush's cycle (0 in 2,357 flushes; an RTL
  assertion and the model's check), so the late flush drops nothing new.
  The reset is flopped (RST-1). The bench runs the RTL a snapshot behind
  the model; control no-enq-lead. (OI-54's late-event control, whose
  random hunt this moved, is now directed: docs/ooe-model.md.)

  The registered take and the output register (OA-21; OA's responses
  OI-65, revs 155 and 156). Rename's take is registered (`tk`) and popped
  at the next edge, the queue clocked on its own flops alone, the taken
  entries holding their credits that edge longer (`decq_take_late`). Each
  slot has an output register showing its 2R - 1 = 7 heads past rename's
  latest take: valid bits, R payloads and the rest's admission bits (the
  payload's low PA = 6). Its D is a 5:1 mux on this edge's `deq_n` over
  candidates read at positions tk + j (j up to 3R - 2), an AND-OR. Arrivals
  show from the next edge (take_young 0), a slot whose flush applies now
  shows empty, and the used count is state, held to the busy bits' count
  by an assertion. Every output leaves from a flop; flop to flop 19.1 NGD,
  `deq_n` to a flop 9.4 (23.4 with OA's 14). Each slot's two output groups
  (take, count and valids, 14 flops; payloads and admission bits, 82) are
  clocked by rename's per-slot take-enable `deq_sel_cq01h`, a superset of
  its take from rename's flops (budget 2.0; asserted, `deq_sel_covers`), or
  by the slot's own transit, arrival and flush flops: CG-5 waived at 4.2
  NGD in all (rtl/cg-waivers.json, OA's response OI-65). One enable shared
  by the slots gave 61 to 71% DCGE; per slot, 90% and over in every
  scenario. Every arrival clocks its slot's groups: an arrival past the
  candidate window still changes the count, which the checked scenarios
  found (DA, 2026-10-21: every scenario is checked traffic). With this,
  ooe_decq leaves both ratchets, and they hold nothing.

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
  an L1-contracted load, or, for a timer that waits, CCV_LAT_L1_MISS_WAKE
  after its completion (no latency class waits for a done, so the timer
  takes none: a timed grant with no latency is an assertion). An L1 load
  with no completion by payload stages + CCV_LAT_L1_CMPL is the miss: the
  line drops and a miss pulse starts cancel's first hop. A replay or a free
  clears issued, which every line is gated by (the reset line's guard).
  Outputs: the lines; fin, the timer's word to confirmation (the
  full-latency line raised and no miss check pending); the miss pulse;
  issued, from a copy of its own (NGD-7); and ooe_sched's leads (OI-54),
  `wtl` (a line the timer changes at the next edge) and `wml` (a miss pulse
  or a registered completion now), each a register.

  Leads (OA's responses OI-58, OI-62; V-75). Every timer is clocked from
  this module's own flops but for its grant: issued with its age not
  saturated; a final flag to clear; issued and final, or issued and writing
  nothing (a prod bit taken at grant), for a free by confirmation; its
  registered completion; and the registered squash's lead, every timer for
  that edge. Completions (L1): the channel's valid leads its payload by a
  cycle and is flopped; the payload's RS indices are decoded per timer as
  they arrive and registered, the restart taken an edge later at age 1 so the line rises
  on the model's cycle; the L1 hit is taken from the payload as it arrives,
  its timer clocked anyway. A replay needs no lead: it comes within a few
  cycles of a producer's miss or of a stale-ready issue, below saturation,
  and an assertion holds every stop to a clocked timer. The grant comes
  from ooe_sched's third copy of its grant register at 2 NGD, into the
  enable: a CG-5 waiver (rtl/cg-waivers.json), 6.1 NGD in all as check-cg
  measures it (the timer's enable cone, 4.1, and the grant's arrival).
  `wtl`'s next value is the change at the edge after next from the state
  alone, or from a grant or a registered restart at this edge, and none on
  a stop; so it leaves from flops and costs no stage.

  The model logs what reached each timer every cycle (`Core::wakeLog`);
  `test/ooe/wake_tb.cpp` drives the RTL a cycle behind the model, so each
  lead goes a cycle before its event, and compares every valid entry's
  lines with `Core::wakeLine`, every entry's issued bit (a free one clear:
  a stop the timer missed would leave it set), every miss, fin with each
  confirmation and `Core::rsFinal`, `wtl` with `Core::wakeLineChanges` a
  cycle before (a timer stopped since excepted) and `wml` with every miss
  and completion past L1. It runs the directed tests as well as the random
  ones; `testSquashSaturated` squashes wrong-path loads past their timers'
  saturation, the case the squash lead is for. Over 25 seeds: 30,397
  grants, 3,423 completions, 420 misses, 23,425 confirmations and 2.42
  million line comparisons, none differ. Cores whose bypass table has four
  penalties or whose completion delay is not the parameter's are skipped
  and counted, 61% of cycles. Controls late-grant, drop-cmpl, drop-stop,
  no-cmpl-lead and no-sq-lead must each be caught. Logic depth is 16.9 NGD
  flop to flop. Local clock gating: each timer, its `wtl` and its issued
  copy are one 26-flop gate; check-cg measures a lowest DCGE of 87%
  (medium) and 98% (high), idle clocks nothing. Its CG bench ages timers
  in the idle ticks between model cycles, past the model's, so there a stop
  for a timer the RTL would not clock takes the squash's lead too. The
  earlier 13.9 NGD was short: Yosys dropped the age increment of the
  `(age == AMAX) ? AMAX : age + 1` form, which only the CG replay (the
  netlist against the bench's trace) showed.
- **`ooe_confirm`**, confirmation and transitive cancel, as a level (OA's
  response OI-50). An issued entry returns to Waiting when it depends on a
  producer that is not issued or has missed its L1 slot (`msd`: the miss,
  held from the cycle after it until the load's completion), decided every
  cycle from flops. A replay reaches the next level only through an edge,
  so it is still one level a cycle; the first hop now comes a cycle after
  the miss, which the model takes too and which costs nothing measured
  (963 cycles over 48 seeds, unchanged). Being a level, it also catches an
  entry granted from a stale ready bit in the cycle it issues (OA-17). There
  is no replay register, so no enable and no column flags to gate it.
  Confirmation takes an issued entry with no dependency bit left whose
  result is final (`ooe_wake`'s fin) or that writes nothing. It is an inner
  helper with no flops (`ooe_confirm.ngd.json`): `ooe_wake` and `ooe_rs` each
  compute it from their own state (OI-50), 8.7 NGD in 7 levels at 45
  entries. The model logs the hop's and the pass's inputs and decisions
  (`Core::wakeLog`, `hop_msd` among them); `test/ooe/confirm_tb.cpp` drives
  the RTL with them and compares both decisions every cycle, then runs
  OA-17's directed case: a missed load's child, issued after the miss,
  must replay in each cycle it is issued. Over 25 seeds: 1,038 replays and
  82,128 confirmations, none differ, never both at once (V-16). Controls
  no-msd, msd-pulse (the pulse hop OA-17 found unsafe), no-fin and no-dep
  must each be caught.
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
  12 NGD and more.

  Leads (OA's responses OI-58, OI-61; V-75): those events reach the gates
  only from this module's own flops. An allocation is led by the flop of
  rename's Rename 2 valid per port (`req_l`, exact). A free by
  confirmation is led by a flop per entry (`cf_en`), set when the entry may
  confirm next cycle: valid, not freed now, its row empty after this edge
  (every producer left in it freed now: the free input, as data), and then
  a producer final at the next edge (ooe_wake's line-3 timer lead `wtl3`,
  final already, or a completion for it: the channel's valid flopped,
  `cva`, with the payload's RS indices as they arrive, held a cycle more
  for a restart, `cvb`), or an entry writing nothing (a prod bit taken at
  allocation) issued then (ooe_wake's issued and ooe_sched's grant). This
  departs from OI-61's "every producer left about to finish": a producer
  final while its own row waits (an add on an L1-speculative load, final
  at 7 and confirmed at 19) held its class's clock for that whole window,
  and the free input makes the row's test exact. A free by squash is led
  by the registered squash's lead's flop (`sq_en`), both classes. The
  grant register is clocked on the request leads and an edge more to
  clear; the reset is flopped (RST-1). Assertions hold every request and
  every free to its lead. The bench runs the RTL two cycles behind the
  model (the completion lead goes two edges before its confirmation's
  free), runs the directed tests too, and its new controls no-req-lead,
  no-sq-lead, no-cmpl-lead and no-fin must each be caught;
  `testFinalBeforeProducer` (an SFU op of 30 cycles bypassed to a lane op
  final at 16) is the case the final term is for. `check-cg`: 7.8 NGD of
  enable, a lowest DCGE of 78% (medium) and 82% (high), nothing clocked in
  idle; its idle ticks between model cycles predict nothing but on the
  last, where the next cycle's leads go.

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

  With the section fallback (FB 1, the design) select is 24.3 NGD, and
  with the half pick too (FB 2) 26.8, past the stage, so the half pick is
  PF-38. That was select with every term live; ooe_sched moved the terms
  that need only earlier state into its registers (below), and select now
  reads them.

- **`ooe_sched`** (OA's responses OI-51, OI-53, OI-54), around `ooe_ready`
  and `ooe_select` (FB 1): three registers, each gated from its own flops
  (CG-5).
  - The ready register: ooe_ready over the RS's matrix and ooe_wake's
    lines as they stand after the edge. Its enable is the flop of the
    leads: ooe_wake's timer lead per line, of lines some row's cell
    selects; its event lead (a miss, or a completion past L1, changes
    lines at the edge after next, each known a cycle ahead); ooe_rs's
    allocation; and the stop lead, OI-50's replay rule over issued, the
    matrix and missed as they stand after the edge.
  - The request register, one bit per entry: valid, not issued, warp
    active and a copy's sources confirmed. Its enable is the grant
    register's OR, the stop lead, and the flop of "differs from its next
    value and not captured at this edge", so a change other than a grant
    or a replay lands one edge late. That is safe: a late fall needs a
    warp leaving Active, which squashes all its entries, and select reads
    valid and past rename live.
  - The grant register, two `(* keep *)` copies: one leaves and one masks
    select (NGD-7). Its enable is "something may request, or something is
    held".

  Select's requests on the lane and RCU side come from its own flops and
  the live valid-and-past-rename bit; the MIU side adds the memop terms
  live. A bulk discard takes only MIU pipes, so busy masks MIU entries
  alone. Flop to flop: 19.9 NGD. With OA's arrivals (4 and 5) the worst
  input is sdep at 24.5. `older_r` and the new `vel` take 4 as proposed
  (OI-55). The clock gates' lowest DCGE is 81% (medium and high).

  `test/ooe/trio_tb.cpp` drives it assembled with ooe_rs and ooe_wake
  (OI-45; it replaced `sched_tb`, which emulated the neighbours in the
  model's frame). It compares the grants, the request register bit for
  bit, and the ready register on V-73's rows. The controls no-msd,
  no-miss-lead, late-leads and no-alloc-lead must each be caught. It is
  the clock-gating bench too: the ready register's enables lead
  ooe_wake's lead lines and ooe_rs's rows, so only the assembled modules
  give them in the frame they clock. The ready register reads a row not
  valid as not ready, so writing a row ready at once is a change its
  allocation lead clocks; the grant's term is of rows reading the lead
  line (WL - 1), the one line a grant may raise at its own edge. DCGE 92%
  medium, 96% high.

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

  The read is Rename 1's logic (OA's response OI-46, reopened): it lives in
  `ooe_ratread`, a combinational inner helper for `ooe_rename`, whose
  Rename 1 register captures what it returns, and `ooe_rat` drives its maps
  straight out (`rat_cq02h`, required at 4). So no rename field passes
  through `ooe_rat`, and its 33 NGD-5 and 2 NGD-2 entries, and 3 of its 5
  NGD-3, are gone. The bench drives both under `test/ooe/ooe_rat_read.sv`
  (101,453 renames, 59,615 in-group, none differ; the four controls
  caught). `ooe_ratread` is 13.3 NGD alone, under the 16 an uninstantiated
  helper is held to; `ooe_rat` is 11.7 flop to flop and 12.5 input to flop.
  Three entries stay: `ret_dst` and `ret_gwe` from the default arrival of
  13 (NGD-3; `ret_gwe` at 25.2, within synthesis noise; an arrival budget
  for retire's ports clears both), and
  `rat_cq02h` (NGD-7), whose flops reach the checkpoint capture (the map
  after a branch port's own writes) 11.7 NGD away against the output's 4,
  the path OA asked to be named.

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
  OI-58's redesign (OA's response, V-75) takes every enable from the
  module's own flops: rename's group writes the speculative maps and
  checkpoints an edge after its go, from rename's register of the group,
  enabled by `ooe_rat`'s flop of the go per slot and per (slot,
  checkpoint) of "a taken branch names it" (formed here from rename's take
  counts and decq's head branch fields, L2); retirement writes the
  committed maps from the retire-stage register, each slot's GPRs one gate
  and its predicates another, enabled by `ooe_rat`'s copy of that
  register's gwe and pwe (from the ROB's decision, L2); restores, squashes
  to retirement and releases are registered and applied an edge late
  (L4); the reset is flopped. `ooe_ratread` reads through the pending
  group, each read a select of the flops' entry or its last writer among
  the pending and in-group ports, compared in parallel: 12.1 NGD alone,
  from 13.3 before the pending group. The bench compares every map an
  edge behind the model (93,330 cycles, 101,578 renames, 2,459 restores,
  65,861 retirements, 36 restore-allocate writes; none differ; controls
  no-pending and no-lead added, all six caught). `check-cg`: 28 gates,
  worst enable 2.2 NGD, lowest DCGE 92%, 61 lead and event flops outside
  any gate, within the 88 allowed; the four CG-5 and RST-1 entries leave
  the ratchet. `rat_cq02h`'s NGD-7 stood: its flops reached the hold mux
  and the checkpoint capture 12.0 NGD away, against the output's 4 (OA-20,
  re-measured). DA chose (b), the copy (2026-10-21): the speculative maps
  are two `(* keep *)` registers, `rto_cq02h` leaving as `rat_cq02h` and
  `rin_cq02h` for the hold and the capture, 736 flops more. NGD-7 is
  clear and the entry is off the ratchet; `ooe_rat` is 12.5 NGD flop to
  flop, and `check-cg` reads 5,213 flops in 28 gates, worst enable 2.2,
  lowest DCGE 92%. rat_tb unchanged: none differ, six controls caught.

- **`ooe_rename`**, rename's pipeline (task 18; the doc at rev 238, its
  Stage boundaries table and OA-21, OA-22), built in slices, each benched
  against the model before the next:

  1. **The producer map** (`ooe_prodmap`), kept by RS entry, not by name:
     each entry's occupant's GPR and predicate names (a masked load's copy,
     the GPR name alone), written a cycle after Rename 3 from ooe_rs's
     registered grant, each class's names one gate enabled from the
     module's flop of the group's ports (L2). A source's producers are the
     entries valid, not allocated at the last edge, whose occupant names
     it, found by comparing the name with all 45. The doc's 768-entry map
     indexed by name would have to clear every name holding a freed entry,
     each name's enable from ooe_rs's free vector (CG-5), and is 11,700
     flops; the compare is exact by construction (a freed entry is
     invalid, a reused one names other registers), gives the dependency
     row's bits directly, and measures 6.4 NGD for 16 GPR lookups and 5.5
     for predicates against the map's 10.8 and a decode
     (`test/ooe/probes/cam_probe.sv`; OI-66). The entries allocated at the
     last edge, whose names are not yet written, are masked, and that
     group's producers come from the registered grant, as the next group
     resolves them already. ooe_rs masks a new row with the frees of its
     own cycle (d4eb78f). `test/ooe/prodmap_tb.cpp` checks, for every name
     after every edge, that the compare finds exactly the model's
     producers: 43.3M name checks over 25 seeds and the directed tests,
     1.59M live producers, none differ; controls no-ename, port-swap and
     no-lead caught. `check-cg`: 917 flops, 914 in 3 gates, worst enable
     4.0 NGD, lowest DCGE 85%. Its port budgets wait on OA (OI-66):
     gnt_idx reaches a flop 19.3 NGD after it arrives.
  2. **Rename 2 and 3** (`ooe_rendep`; built 2026-10-22): the
     compares for each uop's sources (three GPR, the merge source, the
     guard and the old predicate destination, plus predicate logic's two),
     the in-group override, the earlier groups' producers, and each cell's
     wake-line code. Out to ooe_rs from rename's stage register, under
     ooe_rs's budgets (req by 6, grp_dep by 9, the rows and codes by 10).

     *Which groups a source can name.* With G in Rename 2 at cycle t, the
     group ahead (G-1) is in Rename 3 and allocates at this edge, and G-2
     allocated at the last one. ooe_prodmap holds entries allocated two
     edges ago or more (its write is a cycle after Rename 3). So a source's
     newest producer is, in priority: an older uop of G itself (the
     in-group override: the RAT read through the pending group gives the
     younger uop the older one's new name), then G-1's, then G-2's, then
     ooe_prodmap's. Names are unique while allocated, so at most one of
     these holds a live producer, and a hit in an older class beside a newer
     one is stale. Only the port classes keep the order (an in-group
     producer hides G-1's, which `prv_dep` would otherwise carry); an entry
     hit, G-2's or ooe_prodmap's, beside a newer one names an entry that is
     invalid, freed at this edge or re-occupied at the last, and ooe_rs's
     row mask drops each, so the entry classes are left unordered and their
     compares stay off each other's paths.

     *Where each resolves.* ooe_prodmap's hits and G-2's resolve in Rename
     2: G-2's entries are ooe_rs's registered grant at t, and the same grant
     masks ooe_prodmap's stale names for those entries. G-1's entries are
     known only from the grant at t + 1, when G is in Rename 3; mapping them
     in rename would put ooe_rs's grant on a path from rename's input to its
     output (no feedthrough). So rename sends G-1's matches as port-to-port
     bits, `prv_dep` and `prv_code` (port p's uop depends on the last
     group's port q), beside `grp_dep` (this group's port q), and ooe_rs
     maps them through its own registered grant, as it maps `grp_dep`
     through this edge's. ooe_rs also masks a row with its own valid bits
     and last edge's allocations, which drops a hit on an entry freed or
     re-allocated since Rename 2. Proposed budgets: `prv_dep` by 9 and
     `prv_code` by 10, as `grp_dep` and `grp_code` (OA to confirm).

     *Ports.* A group's ports are packed per class in allocation order,
     each uop's main entry then a masked load's copy on the RCU port after
     it, as ooe_rs and ooe_prodmap number them. The group is fixed when it
     leaves the decode queue, so Rename 2 knows each uop's ports and the
     stage register holds the rows by port.

     *Codes.* A cell's code is the producer's wake line for the consumer's
     bypass group: late (3) for a predicate source, for a consumer RCU
     executes, and for a producer with no bypass (a memop, a copy, a
     cross-lane op, a unit with no fastest point, or a pair the bypass
     table lacks); otherwise the index of the pair's penalty among the
     sorted penalties, an elaboration table from the model's settings.
     Each RS entry keeps its occupant's code per consumer group (2 bits by
     the groups) in ooe_prodmap, the entry's record with its names, written
     when they are behind its class's gates (each uop's codes come in with
     its names, `cvc`); G-1's and G-2's ride with their ports. A register
     of its own here, clocked whenever a group allocated, changed on 39%
     of its enabled cycles in medium and 60% in high (an occupant's codes
     often equal the last one's), under CG-3's 75%. Two sources on one producer take the later line
     (the larger code), as the model's dep() keeps the later wake. A code
     is payload, read only through its bit (ooe_rs's code register keeps
     none without one), so it leaves unmasked.

     *Not in this slice.* Atomics (AR-21: three entries and two temporaries
     per uop) reach no RTL bench yet (`main()`-only tests), so the module
     asserts none arrives; they follow with the ROB. A Rename-3 hold (the
     go's skid) is slice 4's: this slice assumes the stage register's group
     allocates at the next edge, which the bench drives.

     *Result.* `test/ooe/rendep_tb.cpp` drives `ooe_rendep` beside the
     `ooe_prodmap` it reads (`test/ooe/ooe_rendep_tb.sv`) from the model's
     renames, each module at its own stage, and checks every port's row in
     the stage register against the model's dependency matrix: 25 seeds and
     the directed tests, 251 cores, 100,454 rows, 68,984 cells (4,276 in
     the group, 10,065 to the group ahead by `prv_dep`), none differ; the
     20,804 row bits the model lacks all fall where ooe_rs masks them.
     Controls no-map, late-code and no-copy-src caught; `run-rtl.sh` also
     holds the bypass table's default to `rendep-params.py`. First built,
     it was 26.4 NGD flop to flop, its port inputs 28.4 in all: each port's
     record was written through the computed port (a priority chain behind
     the prefix count), G-2's codes overrode an entry's in port order, the
     entry hits waited on the newer classes' compares, and each code was
     masked by its hit. One-hot selects for the first two, the entry
     classes unordered and the codes unmasked give 19.3 flop to flop, every
     input at most 19.3 after its 2.0 arrival (`ooe_rendep.ngd.json`, by
     OI: every input by 2.0, proposed to OA). `check-cg`: 1,844 flops,
     1,840 in 2 gates, worst enable 1.7 NGD; ooe_prodmap with the codes,
     1,746 flops in 3 gates, 18.8 NGD. ooe_rs takes `prv_dep` and
     `prv_code` (mapped through its registered grant) and masks a row with
     its valid bits, its frees and its last grant. The last grant is
     registered one-hot beside the grant (no decode, and apart from the
     `gnt_*` outputs, NGD-7), and each new row's cells, codes and empty
     flag go by one-hot select, an entry being in one port's grant at most:
     the override in port order the `prv` term doubled had put ooe_rs at
     26.6 NGD. It is 18.1 flop to flop again, `prv_dep` and `prv_code`
     reaching a flop 15.1 after an arrival of 9 (proposed to OA: they leave
     rename's stage flops as `grp_dep` does). rs_tb drives both, with
     controls drop-prv (the group ahead's producers lost) and stale-live
     (stale bits on entries ooe_rs keeps), both caught, and the trio
     drives them assembled.

     *Assembled (OA's rev 168).* `test/ooe/rnrs_tb.cpp` wires ooe_prodmap,
     ooe_rendep and ooe_rs as rename and the RS do (`test/ooe/ooe_rnrs.sv`):
     the stage register is ooe_rs's rows, ooe_rs's registered grant is
     rename's. The model drives rename's fields and the RS's other inputs
     only, and ooe_rs's grants, valid bits, column flags and rows are held
     to the model's: 25 seeds and the directed tests, 251 cores, 1.66M rows,
     183,212 line selects, none differ (cores with predicate renaming off
     are driven, not compared). The wrapper asserts what OA asked
     (`surviving_named`): after each edge, every bit of every row written
     names an entry of the same group or one whose occupant, in
     ooe_prodmap, produces one of the row's source names. Controls, each
     caught by the assertion: stale-live (a bit on a valid entry from two
     edges ago or more that no source names, joined to a row on its way to
     ooe_rs, which its mask keeps) and wrong-names (the assertion reads
     another port's names). The budgets are OA's now (rev 168):
     `prv_dep` and `prv_code` at 9, every ooe_rendep input at 2.0, each
     source a register with no NGD-7 finding.
  3. **Rename's credits** (`ooe_rencred`, an inner helper: the counters'
     next value; the flops are ooe_rename's): RS room per class, the free
     GPR and predicate names, each slot's ROB room. A counter falls by the
     go's take and any other draw (a restore-allocate's names), and rises
     by the cycle's frees from the next edge: an RS free within ooe_rs's
     prompt count (its free thermometer, capped at 4) at this edge, the
     rest (a squash's, or past the cap) at the next. The go's takes arrive
     late, so each next value is formed for every count the late inputs
     may give (a carry-save step and a prefix add each) and the takes
     select one: 12.8 NGD alone, the takes 7.2 to 11.0 from the output.
     `test/ooe/rencred_tb.cpp` holds the counters and checks them against
     the model's credits (`Core::renCredits`, `renEvents`) every cycle,
     under the go they serve (fits_stale 6), through the random and
     directed tests: 95,364 cycles, none differ; controls no-late, no-draw
     and no-rob-free caught. ooe_rs's prompt count and its register of the
     rest wait on confirmation moving into ooe_rs (OI-45); the ROB's
     frees, on the ROB. Building it found 3's per-cycle shares unsafe as
     registered (OI-65; docs/ooe-model.md, fits_stale 6).
  4. **The go** (`ooe_go`; built 2026-10-23; OA-21, OA-22, OA's revs 171,
     174, 179). Rename's per-cycle shares split from registered state
     (OA's rev 242: the first warp in rotation takes the remainder), the
     fits registered per warp and per own take k, selected next cycle by
     the warp's registered take and interleaved round by round, R uops.
     The model's go_static (docs/ooe-model.md) is its reference.
     *Form.* The pool arrives as rename's pool register (each credit less
     its floors owed, saturated at 5R); ooe_go subtracts its own one-hot
     register of the allowances in force. The share table is a constant
     picked by the pool (one-hot), then the warps' number, then each warp's
     role and floor. The take is a thermometer per slot (a candidate is
     taken while the other warps' terms sum below R - r); the lanes are
     one-hot over the 16 candidates. A warp's block (its hold, a restore
     owning the ports, its squash) is registered from its producers'
     leads (arrival 11) and clips the take; a squash's second cycle masks
     the fits as registered. decq takes the thermometer (`deq_t`), masks a
     slot whose flush is registered, and exports its arrivals.
     *Depth.* 21.6 flop to flop (64.7 in the first build), takes 12.0
     against decq's 14, lanes 15.4 against 16.7, every register-fed input
     by 23.6 at its arrival of 2 (`ooe_go.ngd.json`, OA's).
     *Clock gating.* Each slot's fits and its take-enable are clocked by
     its change bit, which folds its producers' register enables (decq's
     arrivals, the ROB room, rename's pool and floors) with its own takes,
     squash, restore edges, held allowances and rotation. The take and the
     rotation pass CG-3. The fits (64 / 61-68% medium / high) and the held
     allowances (66 / 54%) take DA's waiver at 2 points under (OA's rev
     179): a streaming warp's fits stay all ones while its heads move, so
     no enable from own flops can reach 75%. The flops written every cycle
     are 14: the allowance takes 6, waivers the squash and change bits.
     *The ceiling* (OI-73 (3), OA's rev 207): each slot's room to its
     ceiling per class, rename's register (arrival 2), is a fits term: the
     names of the k heads taken now and the m after must fit it, as the
     ROB room covers k + m. 21.4 NGD flop to flop with it. go_tb's control
     no-room drives no binding room and is caught (the directed test
     ceiling-go makes it bind at the RTL's size).
     *Result.* `test/ooe/go_tb.cpp` drives ooe_go from the model's GoLog a
     cycle behind (the leads are the next cycle's log) and compares every
     take and lane: 25 seeds and the directed tests, 250 cores, 101,393
     takes, none differ; controls no-hold, no-rbusy, no-squash, no-dq-ev,
     no-rob-en, no-pool-en, no-ret and adm-shift caught.
  5. **Rename 1** (built 2026-10-23; OI-67, OI tab). Rename 1 is the go's
     cycle, as the model has it (rename_stages 3: the go and the RAT read
     at t, Rename 2 at t + 1, the RS write at t + 2), and it never stalls:
     take_young is off, so no refill is re-checked and no skid is needed,
     and decq's registered take (OA-21) replaces the credit channel of
     OI-49. The go's lanes come at 15.4 NGD, too late for a read behind
     them, so the read is per candidate: one `ooe_headrd` per slot reads
     each of its R heads from decq's output register, through the pending
     group (the Rename 1 register), in parallel with the go (9.5 NGD
     alone). A warp's take is a prefix of its heads, so head h's in-group
     writers are its own slot's heads below h, always taken with it: the
     read returns each writer one-hot over the heads, not a name.
     *Names.* A uop takes its class's free list head k, k the writers
     before it in lane order. `ooe_go` counts them for every candidate as
     it ranks them (`wb`, its rank's sum over each warp's writer prefix
     counts, registered per own take beside the fits: 16.5 NGD), and the
     cycle's totals (`wt`, 21.5), the free lists' requests. A name picked
     from `wb` and lane-selected would land at about 25, so `ooe_ren1`
     lane-selects each lane's index, its fields, its reads' values and
     each read's writer as a lane (the lane holding (h', s)), and the
     Rename 1 register holds them with the free lists' heads beside it;
     `ooe_ren1n` binds the names from those flops in Rename 2's first
     gates (2.5 NGD for a lane's names, 5 for an in-group read's), for the
     pending group (ooe_rat's write ports, ooe_headrd's override) and
     ooe_rendep. The free lists become ooe_rename's children: their request
     depends on decq's payload, so it cannot leave rename without a
     through path.
     *Depth.* `test/ooe/probes/ren1_probe.sv` (ooe_go, the four reads,
     ooe_ren1 and the register, flattened) is 21.7 NGD flop to flop.
     Budgets proposed to OA (OI-67): ooe_freelist's alloc_req by 21 (it
     reaches only the registered count), ooe_rat's pending names by 3,
     ooe_rendep's names by 3 and its source names by 5 (it is 19.3 after
     its inputs). ooe_go's `wb` required at 17 and `wt` at 22, by OI.
     The fits and the take register drive the take (required at 14) and,
     through the counts, `wt` 14.6 away, so each is copied, `(* keep *)`,
     one for the take and one for the counts (NGD-7; ooe_go 20.9 flop to
     flop). OA's response OI-67 (rev 184) confirmed the form and took
     alloc_req by 21.
     *Clock gating.* The prefix counts and the fits' copy join each slot's
     fits gate, whose change rate in high rises to 73-77% (medium
     unchanged at 64%); the fits waivers' floors stand. 606 flops: the
     module's allowance now takes the change bits too (their waiver is
     gone).
     *Result.* `test/ooe/ren1_tb.cpp` drives ooe_rat, the four reads,
     ooe_ren1, the register and ooe_ren1n (`test/ooe/ooe_ren1_tb.sv`) from
     the model's renames, every other candidate random, and compares each
     lane in the register with the model's after the edge: 25 seeds and
     the directed tests, 51,585 lanes (26,610 with an in-group writer),
     none differ; controls lane-swap, name-reverse and drop-restore
     caught. go_tb holds `wb` and `wt` to the model (81,534 writers, none
     differ; control no-write-bits caught).
     *Not in this slice.* Whole-row names only (sectioned cores are driven
     and skipped): the narrow allocator (a candidate row per warp and
     position, a width table for placement, OI-29) is its own slice. A
     restore-allocate's writes and atomics stop a core's comparison (2
     cores); a uop the model renames as a no-op (a fault) is driven with
     the model's write bits, where the RTL would take a name by the
     decode-time bit.
  6. **The narrow allocator** (DA's response OI-29; OA's response OI-67,
     rev 184: a numbered slice). A narrow destination takes its warp's
     candidate row for the position it needs, an owned row with that
     position free, else a fresh row from the free list; a background
     find-first keeps one candidate per warp and position current, off the
     rename path, from the free list's per-row owner (2 bits) and live
     sections (4). Placement reads the sources' widths and positions (a
     width per name), the old destination's for a merged op, else the
     warp's home position; a second allocation in a group wanting the same
     warp and position takes the next free one (AR-15). A narrowing
     renames in place. Beside it, the parked layout's restore (TI-25): a
     restore-allocate writes each register at its parked position and
     width (the 64-bit layout per warp_id), through the same ports, so it
     shares the allocator's row and section state. Until it is built,
     Rename 1's names are whole rows and its benches skip sectioned cores
     and restore-allocates. Required before the first pass is called
     complete (OA's response OI-67, rev 184: sectioned registers are DA's
     first-build decision, OI-29).
  7. **ooe_rename's top**: ooe_go, the reads and Rename 1, the free lists,
     ooe_rendep and ooe_prodmap, rename's counters (ooe_rencred) and its
     pool and floor registers, assembled and benched against the model.
     *First step (built).* `rtl/ooe/ooe_rename.sv`: ooe_go, one ooe_headrd
     per slot, ooe_ren1, the Rename 1 register and ooe_ren1n, and the two
     free lists, whose requests are the go's taken-writer totals (wt). The
     go's pool, floor and ROB terms and Rename 2's fields are still ports.
     A head's write bits are its admission bits (3 GPR, 4 predicate), as
     the go counts them. Each lane's name index is registered one-hot
     (ooe_ren1 decodes the lane-selected thermometer; OA's response OI-70,
     rev 194), so the names leave a decode sooner. NGD-7 copies: the Rename
     1 register's pending-group fields twice (o_ for the outputs, p_ for
     the heads' reads), and the name index and free-list heads three times
     (q_ for the new names out, r_ for the reads out, p_ for the heads'
     reads), each behind its own ooe_ren1n: 220 flops. Its units (`test/ooe/cg-units.json`, which
     check-ngd reads too) blackbox ooe_go and the free lists, measured in
     their own units: check-ngd times them by their budgets, check-cg
     counts ooe_rename's own flops (749, 9 ungated). The bench
     (`test/ooe/rename_tb.cpp`, beside ooe_rat in
     `test/ooe/ooe_rename_tb.sv`) drives the go from the go log, the
     candidates from the renames and the free lists from the model's frees,
     a model cycle behind; nothing tells the RTL what was taken or which
     names. Before the edge the takes, after it every lane of the Rename 1
     register (slot, destinations, the new names, branch, checkpoint, every
     read) must be the model's: 25 seeds and the directed tests, 48,063
     lanes and 265 no-op lanes (an exit or a decode fault takes a lane and
     renames nothing), none differ; controls drop-free, no-lead,
     no-write-bits, no-hold and drop-restore caught. Skipped: cores the RTL
     is not built for (sectioned, predicates not renamed, other sizes);
     stopped: a restore-allocate or an atomic (2 cores), or a fault found
     at rename (barrier, width, format), where the RTL takes the
     decode-time write bit's name and the model none (none in these runs).
     The model's free lists now refill nothing at their first edge, the
     RTL's last reset edge, so one model cycle is one RTL cycle for the go's
     rotation and the free lists alike (`FreeVec::clock`; freelist_tb's
     reset follows). `check-ngd`: 14.4 NGD flop to flop from the children's
     budgets; flattened whole (before the one-hot index), 22.7. Rename 1's
     names leave at 2.6 NGD (q_gname, q_pname; by 3, ooe_rat's write-port
     arrival) and its reads at 5.6 (q_g, q_p; by 6, into Rename 2): OA's
     rev 194, from the receivers' paths, ooe_rat's 11.3 and 10.1 from
     pw_gname and pw_pname and ooe_rendep's 17.9 and 18.4 from gsn and psn.
     With a thermometer index they left at 3.6 and 6.6. ooe_ren1's index
     path is 7.3, so Rename 1 still converges (wb at 17, 24.3). ooe_rat's
     tk is data only (the D of its lead registers wl and ck), so its
     arrival is the take's 14 (OA's rev 194).
     *Rename 2 (7c, built).* ooe_rendep reads the Rename 1 register: the
     lanes' valid and write bits from its p_ copy, the names and reads
     bound by u_ren1nr from its r_ copy, and each lane's attributes (x_:
     the head's decode-time reads and bypass fields, the c_x port, with its
     class bits from the admission bits; a lane with neither class bit
     takes no RS entry). Rename 1's reads are no longer an output: only
     Rename 2 reads them, and rename_tb through CCV_CHECK_RENAME ports.
     ooe_rendep's lead is the go's registered sel, a superset of a take.
     The Rename 2 register holds the group for Rename 3: ooe_prodmap's
     record (names, ports packed per class in lane order, codes from
     ooe_rendep's table) and ooe_rs's request (clocked while Rename 1 holds a lane or it is set).
     The request's lead leaves from its own copies of the lanes' valid bits
     and the RS ports each takes (o_lv, o_c: 12 flops, decoded so the copy
     is no other register's twin, which the replay would merge), at 7.9
     NGD. GPR names are registered as rows (whole rows until slice 6). ooe_rs's registered grant is an input. The bench
     (rename_tb) drives the grant from the model's allocations three steps
     back, as rendep_tb does. After each edge it holds the request and every
     row of ooe_rendep's stage register to the model's, using rendep_tb's
     compare with ooe_rs's masks allowed. Over 25 seeds and the directed
     tests, 49,764 rows and 32,779 cells (1,912 in-group, 4,015 to the group
     ahead) were compared and none differ. Controls no-reads (no head's
     attributes say it reads) and no-grant (caught by ooe_prodmap's
     granted) are caught. ooe_rendep and ooe_prodmap are blackboxed in
     ooe_rename's unit. check-ngd: 14.4 flop to flop. check-cg: 964 flops,
     947 behind 3 gates. ooe_rendep's gsn and psn budgets move to 6, by
     OA's rev 194 (Rename 1's reads leave at 5.6).
     *Width codes (AR-24 (d), built).* Each slot's committed width
     table (16 registers, 2 bits each) is a register in ooe_rename,
     written a cycle after its lead, the ROB's until it is built (a
     chwidth's or sibling's retire, a launch, a restore-allocate); reset
     is a launch's, every register 32 bits. A width changes only behind
     a chwidth's hold, and a sibling changes no register a younger uop of
     its group reads, so each candidate reads the table directly beside
     ooe_headrd's map reads, with no in-group override. A chwidth's own
     destination takes the width it sets (c_wset, c_wnew; TI's rev 185).
     The four codes ride ooe_ren1's lanes beside the attributes into the
     Rename 1 register (w), out on q_w for the RS payload when it is
     built. Rows stay whole until slice 6, which is full_rows's
     allocation already. rename_tb holds every lane's codes to the
     model's (Core::RatLog's wsrc, wdst; testWidthTraffic gives 84
     narrow lanes in 5 seeds), and control no-cw-write (the table never
     written) is caught. check-ngd: 22.0 flop to flop, unchanged; the
     new inputs reach flops at 8.0 at most. check-cg: 1357 flops, the
     tables four gates of 32, the lead's 4 flops ungated within the
     allowance.
     *CAS pairs (OI-79 (b), built).* A pair is two head-unit candidates
     in consecutive rounds of its warp, taken both or neither (OA's rev
     239). Admission bit 7 marks a first slot and bit 8 an atomic (PA 9):
     the fits count the pair's needs on the first slot (one more RCU row,
     one more MIU row, two names; the second carries none) and its one ROB
     entry (k + m less the first slots before the last head), and refuse a
     need past R. A run never ends on a first slot: where head m is one,
     m + 1 fits exactly when m does and the second is a head within the
     width, so the cut-back reads decq's bits alone beside the fit's own
     terms. Across warps the take stops before the first pair the width
     would split: which head is a first slot is registered with the fits
     (pf, per slot and take k; OA's fallback, the split stop in the
     registered half), and only the compare against the width is on the
     take path: a first slot taken and its second not removes every later
     round and its own round in the warps not before it. With the stop on
     the take path, reading decq's heads live, the take was at 18.3
     against 14 and the totals at 37.8 against 21. The take is now formed
     three times, each from its own copies of the registers it reads
     (NGD-7): the take (13.6, by 14), the lanes and the writers before each
     (14.1 and 11.2, by 16.7 and 17), and the totals and the take register
     (20.3, by 21; the take register follows the take after the cut).
     check-ngd: 22.6 flop to flop (22.4 before). check-cg: 946 flops, 924
     behind 7 gates; the fits' gates at 64 / 72% (medium / high), their
     waivers' measures; 18 flops written every cycle against the 2%
     allowance's 18.9 (the block's two copies take 8). go_tb runs the
     directed pair-cut (two warps, every cut binding) and the random
     atomics, one warp a core (OI-80): 5,617 pair heads, none differ;
     control no-pair-bit (no head marks a first slot) caught. The other
     benches run no atomics yet (ooe_rendep's no_atomic assertion), so
     pair-cut is not among the shared directed tests. go_tb now drives the
     names' pool as the model's split reads it (GoLog::pin, OI-76's lag),
     which trails cred - owed by a cycle when a slot above its floor frees;
     pair-cut's predicate pressure was the first to show it.
     *The shares' liveness (OI-80, built).* The rotation's own slot, when it
     has a head, reserves two of a credit its head needs two of before the
     even split. The need is registered with the rotation (dr, from the
     next rotation slot's head: 8 flops beside the rotation), so it reaches
     the table early. The table gains the reserve as an index, and the
     pool's saturation rises to 4R + 2 (rename's register to 6R + 2), exact
     through the reserve. The pool is now a thermometer (pth: the pool is p
     or more), and each case's pools are read as runs of it (a or more, not
     b or more), not through its one-hot: the late pool meets the share
     after one compare and an AND-OR. Forms tried, in-flop with inputs at 2:
     the first warp's need live, 26.6; registered with the pool's one-hot,
     25.3; with the thermometer, 23.5. check-ngd: 21.5 flop to flop (22.6
     before). check-cg: 952 flops. The thermometer's 0 entry is set
     whenever an allowance is held, as the pool saturates at 0 below them:
     rename_scarce's lagged counters drive a credit below the held, which
     go_tb's exact pool never does.
     *Counters (7b, built).* Rename's counters replace the go's pool,
     floor and room ports (OI-73 to OI-76, OA's revs 215, 216 and 219):
     RS room per class (up by ooe_rs's frees, a lead a cycle ahead), and
     each slot's floor and ceiling remainders per class (arch + floor or
     ceiling less held), signed. No free-names counter: every allocated
     name is a slot's, so the names' pool is the pool less every floor
     less, per slot, its held past its floor. Each counter lacks last
     cycle's take; the take is registered one-hot (tq, in Rename 1) and
     each reader takes it off. The free lists count each slot's frees by
     group (owners written at allocation) and compress the groups to a
     carry-save pair a cycle on (fsp, `ccv_common_csa`), so held sees a
     free three edges late (held_late 3). Each remainder's next value is
     one 4-operand carry-save sum: it, its take's negation and its frees'
     pair. The names' pool register is formed from last cycle's
     remainders, so it lacks two cycles' takes (names_pool_lag): the
     older, registered when it is formed, is taken in the same carry-save
     sum (each slot's held past its floor and the pool less every floor
     less that take, a select of constants), and the go corrects for the
     newer as for the RS credits. OA's rev 219 put both takes in the go's
     correction (hk to 3R, XM to PM + 3R): measured (the earlier library), that
     is 23.1 from px and pl to flops, 25.1 with their arrivals of 2, so the older take
     moved into the register and the go keeps its one-cycle correction
     (22.5). `ccv_common_csa` (rtl/common/, an inner helper; TI's response
     OI-76): 3:2 rows built by generate, then one add (sum) or none
     (pair); a pair of counts summing under 2^W sums to them exactly.
     Benches: csa_tb against arithmetic at eight sizes; freelist_tb holds
     each slot's pair to its frees exactly; rename_tb holds each credit,
     unmet floor and room as the go reads them to the model's, in three
     builds: the design's parameters, the ceiling test's floor and ceiling
     (4, 8), and scarce names (144 rows, ceiling 24), where the names bind.
     Controls: no-take-q (the go's correction dropped) and no-take-q2 (the
     names' pool register's older take dropped), both caught in the
     scarce build; go_tb's no-corr. Audit, 48 seeds (fits_stale 6): at the
     design's parameters every lateness costs 0.00%; with scarce names the
     decided form (held_late 3, owed_lag, names_pool_lag) is 888 cycles
     against 883.4 with everything exact (+0.53%), against 882.8 with
     frees two edges late. check-ngd, with tools/ngd.genlib's XOR cells
     (TI's 985037a): ooe_rename 22.0 flop to flop, ooe_freelist 21.5 (GPR)
     and 22.2 (predicates), ooe_go 22.4; before them, 23.4, 21.6, 22.2 and
     22.5 (29.6 for rename with each slot's sixteen groups summed there).
     check-cg: ooe_rename 1193 flops, 1174 in 6 gates; the names' pools'
     gate (10 flops) changes on 12% / 24% of its enabled cycles (medium /
     high), waived (CG-3, rtl/cg-waivers.json).

## NGD-7 copies: the running tally (DA, 2026-10-21)

DA reviews the copies NGD-7 costs after OOE's first pass. Each is a
`(* keep *)` register duplicated so an output leaves from flops that start
no deeper path; the flops here are the copy's, beyond the register it
copies.

| Module | Copy | Flops |
|---|---|---|
| `ooe_rat` | the speculative maps, for the output (OA-20 (b)) | 736 |
| `ooe_freelist` | the candidate buffer and its count, for the ports: GPR 68, predicate 52 | 120 |
| `ooe_rs` | the valid bits, for the outputs | 45 |
| `ooe_sched` | the grant register's leaving copy, beside its mask copy | 45 |
| `ooe_wake` | the issued bits | 45 |
| `ooe_rename` | the Rename 1 register's pending-group fields (for the heads' reads), name index and free-list heads (twice more: the reads out, the heads' reads); the lanes' valid bits and RS ports for the RS request's lead | 232 |
| **built** | | **1223** |
| `ooe_wake`, OI-45 (on its branch) | the miss pulses and the final bits | 90 |
| `ooe_rs`, OI-45 (on its branch) | the prod bits, for ooe_sched's confirmation | 45 |

Not counted: `ooe_sched`'s third grant copy, for `ooe_wake`'s enables,
which CG-5 asks for (its waiver), not NGD-7.

Beside the copies, the storage the architects' rulings add, for the same
review (TI-25, AR's rev 112, OA's rev 165; the storage form is DA's):

| Module | State | Bits |
|---|---|---|
| OOE, the ROB side (not yet a module) | the parked layout: per warp_id, each GPR's position and committed width, 16 × (2 + 2), written at a demotion's map and read at restore-allocate | 64 × 32 = 2,048 |

The model holds it as `Core::parked_` (`sim/ooe/ooe_core.h`); the unit
tests' parked-layout check and its control (park-layout-lost) are its proof.

**Its form (DA, 2026-10-22; OA's rev 66).** A 1R1W-array wrapper, 32
entries of 64 bits, addressed by warp_id: one write per demotion (the
entry, at the demotion's map) and one 64-bit read per restore-allocate.
For now the wrapper is synthesized as flops, 2,048 of them, each entry
behind its write enable (one clock gate of 64 flops per entry, enabled only
on its warp's demotion; the read is a 32-to-1 mux of 64 bits). Its ports
stay those of an array, so it can be swapped for a compiled 1R1W array
later with no change to its users. It counts in the tally above as 2,048
flops until then.

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
