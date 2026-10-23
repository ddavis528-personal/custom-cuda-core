# OOE Stage 4b: the timing model

The OOE model that replaces the S1 stub, per [`ooe-4b.md`](ooe-4b.md). Its
design is the OOE microarchitecture doc
([snapshot](design-snapshots/ooe-microarchitecture.md)). This file records
what the model decides where that doc is silent, what it cannot use yet and
why, how it is checked, and what it needs from the top-level session.

## Where it is

| File | What |
|---|---|
| [`sim/ooe/ooe_core.h`](../sim/ooe/ooe_core.h), [`ooe_core.cpp`](../sim/ooe/ooe_core.cpp) | The model: decode queue, rename, RAT checkpoints, free lists with floor and ceiling, RS with the two-bit dependency matrix, select, ROBs, squash, deferred free, demotion, kill, restore, faults, barriers. It knows no channel and no testbench. |
| [`sim/ooe/ooe_block.cpp`](../sim/ooe/ooe_block.cpp) | The port adapter at the swap boundary: unpacks OOE's receivers, runs the core, packs its senders. It also holds the testbench hooks, the message-level negative controls and A-75's temporary opcode lookup. |
| [`sim/ooe/ooe_test.cpp`](../sim/ooe/ooe_test.cpp), [`run-tests.sh`](../sim/ooe/run-tests.sh) | Unit tests of the core, covering every path the S1 kernels cannot reach, plus the harness's own negative controls. |
| [`sim/ooe/sweep.sh`](../sim/ooe/sweep.sh) | The sizing sweep. |
| [`sim/skel/ooe.cpp`](../sim/skel/ooe.cpp) | The S1 stub, still selectable. |

```
sim/ooe/run-tests.sh                 # unit tests (seconds); --seeds N for more
./tools/check-kernel.sh              # every kernel and control, on the model
CCV_OOE_IMPL=stub ./tools/check-kernel.sh   # the same on the S1 stub (A/B)
CCV_OOE_CONFIG=rob_depth=16,rs_rcu=20 build/skel/ccv-skel --kernel ...
CCV_OOE_STATS=s.json build/skel/ccv-skel --kernel ...   # counters, histograms
sim/ooe/sweep.sh                     # the sweep, as markdown
```

`makeOoe` selects the model, and `CCV_OOE_IMPL=stub` selects the stub in both
hosts. `CCV_OOE_CONFIG` takes `name=value,...` over the configuration
(`ooe::Config`). The core's elaboration-time checks (V-31, V-51, V-55) refuse
a configuration that breaks them.

## Pipeline

One `cycle()` per clock. Completions taken that cycle act first, and a uop
written into the decode queue in cycle t is renamed in t+1 at the earliest and
selected in t+2. Inside a cycle:

1. Dones and completions: ROB completion, branch outcome, a load's wake when
   it wakes on its completion, and L1-hit confirmation.
2. One cancel hop, from the state at the cycle's start (OI-50). Timed
   wakes. A missed L1 slot withdraws its wake. Copy-only ops land. Results confirm, one level a cycle. Confirmed
   RS entries free. Squashed entries whose op has landed release.
3. RAU's alloc and demote, kill, and barrier release.
4. Retire: up to `CCV_RETIRE_PER_ROB` per warp, with store commits sharing the
   four `ccv_ooe_miu_retire` slots in rotating warp order.
5. Select: bulk discards, then the MIU class, then the RCU class.
6. Rename: up to `CCV_ISSUE_WIDTH` uops from the decode queue.
7. Redirect queue (rate 1) and the checkpoint-free bitmap.

Three stages from the design's 25-NGD split (OA-1; OI-26), each a `Config`
field:

- **Rename takes three stages** (`rename_stages` = 3): RAT read, producer
  lookup and matrix write. An entry renamed in cycle t can be selected from
  t + 3. That costs two front-end cycles on every redirect, not the wake
  loop: `loop` runs 2636 cycles against 2336 with one stage.
- **Payload read** (`payload_stages` = 1): what select grants leaves on
  `ccv_ooe_rcu_issue` and `ccv_ooe_miu_memop` a cycle later. Wakes count
  from the grant, so producer and dependant move together. Only the
  contracts timed from the channel add the stage: the L1 shadow and V-44,
  V-35's done bound, and a copy-only op's landing.
- **Transitive cancel is a level, one hop a cycle** (`cancelHop`), as
  `ooe_confirm` builds it (OA's response OI-50). At the start of every
  cycle, before its misses are found, one hop returns to Waiting every
  issued, unconfirmed entry with a producer that is not issued, or has
  missed its L1 slot: exactly OI-50's rule, as the RTL decides it, not
  "the row is no longer ready" (`msd`, set at the
  miss and cleared at the load's completion, after that cycle's hop, so
  it clears only once nothing issued depends on it, V-68). The hop is
  decided whole before it is applied. A miss's direct dependants therefore
  go back in the cycle after the miss, and each further level a cycle
  later (V-67). That is a cycle later than before; over 48 seeds it costs
  nothing (963 cycles). V-59 still holds the wake offsets at 3 or more,
  now as a performance check (unit test `v-59`). V-15 is checked only
  once a cancel has settled, as before. At today's latencies a second hop
  never happens: the L1 shadow (CCV_LAT_L1_WAKE 16, the miss found at 19)
  is shorter than any dependant's own wake. One random seed in seven runs
  the long shadow the controls use, so the later hops are exercised.
- **Confirmation takes one level a cycle** (`confirmPass`), as
  `ooe_confirm` builds it. An issued entry confirms when every source was
  confirmed before this cycle's pass, which, since a confirmed entry is
  freed and its column cleared, means no dependency bit is left. It also
  needs its own result final (its full-latency wake raised, no L1 check
  pending) or no destination. A consumer of an entry confirmed this cycle
  confirms from the next. Before this, the pass ran oldest first and
  chained within a cycle. Measured with a probe, the chain never went past
  one level in any S1 kernel or random seed, only in the long-shadow
  controls and once in the `l1-spec` test, and no kernel moves by a cycle
  in either mode. Nor did the earlier second hop in a cycle ever happen
  outside the controls.

The post-miss wake's extra cycle (OA's response OI-26) is in
`CCV_LAT_L1_MISS_WAKE`, now defined from the completion's arrival to the
dependant's earliest select: 1 with abutted links, 3 under `links_split`. A
completion-driven wake cannot be raised a cycle early, as a timed one is.
The adapter's check that the parameter matches the wiring carries the same
+1.

## Decisions the design doc leaves open

Each of these is a model decision, the RTL follows it, and each is
arbitration policy for Q-4 where it chooses between requesters. OA
ratified decisions 1 to 9 and 11 on 2026-10-07, with Daniel's approval, in
its responses to OI-10 to OI-15. Decision 5 became the design's invariant
V-58, and OA confirmed decision 10's reading (OI-14). Where a
costlier choice would perform better, it is an entry in
[`perf-register.md`](perf-register.md). Decision 6's in-flight kill, for
example, is PF-1.

1. **Select order.** Bulk discards take memop slots first. Then the MIU class
   goes, then the RCU class, from the four issue slots of
   `ccv_ooe_rcu_issue`. Every memop also takes an issue slot, because RCU
   reads its address sources. That is the unsectioned select, which the
   unit tests still run. The kernels run sectioned (below, "Sectioned
   lanes"), which replaced TI's interim `resource_cap`. Every S1 op is full
   width, so a cycle carries at most one lane op, one memop and one RCU op,
   each in its footprint's lowest slot of the nine with the rest marked as
   continuation. Within a class, each warp in turn, starting from
   a priority that rotates every cycle, issues its oldest ready entry, and the
   rounds repeat until slots run out. Age is allocation order within a warp;
   across warps there is none, as the doc says.
2. **Memops issue in program order per warp.** MIU orders memory, and OOE
   does no disambiguation. A memop is ready only if every older memop of its
   warp has issued, and only with confirmed sources (V-17).
3. **A masked load and its copy issue together**, on adjacent slots, and
   only when both RS entries are ready and confirmed (A-38).
4. **An RS entry with a destination is held until its result is
   confirmed**, not only its sources. The dependency matrix needs the
   producer's column for as long as a dependant may wake on it. A load
   therefore keeps its MIU-class entry until its completion. An entry with no
   destination (a store or a branch) frees as soon as its sources confirm.
   The sweep shows what this costs the MIU class.
5. **A ROB entry outlives its RS entries.** It completes only once every RS
   entry of its uop has confirmed and freed. A branch acts on its outcome
   only then, so a resolution read from a cancelled wake can never squash.
   A cancel also voids a done that has already arrived. The unit tests found
   this one: with an RCU faster than its contract, an entry retired while its
   RS entry was live.
6. **Deferred free covers every issued op, not only memops.** A squashed
   entry with anything outstanding (a done not yet back, a completion, a copy
   not yet landed) keeps its destinations and its ROB slot until it lands.
   Otherwise a fixed-latency write scheduled before the squash lands in a
   register already reallocated, and its done matches a reused `rob_tag`.
   Rename stalls at a held slot (`stall.rob_slot_held`).
7. **A barrier wait is sent at the ROB head**, never from a wrong path,
   since nothing leaves OOE that cannot be recalled. Younger uops of the warp
   hold at rename from the moment the barrier renames (V-09).
8. **A squash drops the warp's uops from the decode queue** at once, since
   their epoch is stale. A queued redirect not yet sent, for a branch a later
   older mispredict has squashed, is dropped. FET's restore of the older
   checkpoint frees the younger one anyway.
9. **The demotion resume PC** is the oldest unretired instruction's, or the
   oldest queued uop's, or the PC after the last retirement.
10. **V-35's bound** (below).
11. **Past L1, a dependant wakes when the data is readable, not when the
    completion lands.** MIU sends the data to RCU and the completion to OOE
    together, over different links. A dependant woken by the completion
    still has to reach RCU after the data does. So it wakes
    `max(0, miu_rcu_data crossing − miu_ooe_cmpl crossing − ooe_rcu_issue
    crossing + 1)` cycles after the completion (`cmpl_wake_delay`, from
    `CCV_LAT_L1_MISS_WAKE`, which TI generates from the links; the adapter
    refuses a build whose wiring disagrees). That is 0 with no repeaters and 2 in
    `test/phys/links_split.json`, whose failure found it. `CCV_LAT_L1_WAKE`
    already makes this correction for a hit; the miss path needs the same.

## Free lists

Each pool (GPRs, predicates) is a bit-vector with rotating-start
allocation, as the RTL builds it (`FreeVec`; OA's answer to OI-17, done
as OI-22), in OA's structure (OA's response OI-38): allocation takes the
head of an 8-entry candidate buffer, which four interleaved banks refill at
each edge, each from the first free, unbuffered register after its own
pointer. A free sets its bit at the clock edge and reaches the buffer at
the next, so a register freed in cycle t is allocatable from t + 2. An
allocation leaves the buffer a cycle late (OA's response OI-52): it sits at
the head in transit for a cycle, and the next allocations take the entries
behind it, so the buffer offers its count less the last cycle's take. That
costs nothing at 8 entries (the sweep's 982 cycles stand) and 4.8% at 4. Any
number of frees a cycle costs nothing, so a squash's 32 or a kill's 16
need no drain. Rename's allocation checks the buffer; its floor and
ceiling checks count every free register not freed this cycle; V-01, V-02
and V-04 count those freed this cycle too. Allocation order is
bank-interleaved, so `--break free-new` first showed at seq 379 (R4),
where it showed at seq 382 (R1) under the rotating pointer. With the pop a
cycle late (OI-52) a reallocation comes a cycle later, and it shows at seq
383 (R4), behind the model's own V-01 and V-62 checks, which now see the
wrong free first.

Restore-allocate takes its 16 GPRs and 4 predicates through the same
buffers and ports (OA's response OI-41). The floor check is made at
acceptance against every free register, buffered or not (V-30). Then the
oldest accepted restore owns the allocation ports: up to `rename_width`
registers a cycle from each buffer, and rename stalls for every warp
until it is done (`stall.restore`). Its map goes to RCU in the cycle the
last register is taken, and V-64 holds that to ceil(16 / width) + 1
cycles from acceptance (`restore_cycles`). A restore-activate before the
map is refused (V-49). An invariant holds every cycle that neither list
makes more allocations than it has ports, as `ooe_freelist` builds them.
`testRestore` covers it: four cycles with a busy second warp, which still
retires its program.

## Bypass groups

A dependant's wake belongs to the producer and consumer pair, not to the
producer alone (OI-16; Daniel's responses OA-4). The scheduler indexes a
table by `sched_attr`'s `bypass_group` (0 integer, 1 FP, 2 address
calculation, 3 SFU, 4 warp-collective, 5 predicate; `CCV_P_BYP_GROUPS`):

- **The producer's `lat_class`** sets its full latency (`unitLat`: RCU 3,
  lane `CCV_LAT_LANE`, SFU `CCV_LAT_SFU`, warp-collective
  `CCV_LAT_COLLECTIVE`) and its fastest bypass point (`Config::fast`;
  the lane's is `CCV_LAT_LANE_BYP`). A unit with no fastest point is
  single-time: RCU, warp-collective, loads, and SFU until a
  `CCV_LAT_SFU_BYP` exists (OA's response OI-16).
- **`byp[producer group][consumer group]`** is a penalty in cycles after
  that point, from the parameters: in-unit `CCV_LAT_BYP_PEN_SAME` (0),
  integer and FP to each other `_INT_FP` (2), integer or FP and SFU to each
  other `_SFU` (3). Address-calculation, warp-collective and predicate
  consumers never bypass (`kNoByp`), nor do warp-collective or predicate
  producers.
- **The wake** is fast + penalty after the producer's issue, if that is
  under the full latency; otherwise the consumer waits for the PRF read.
  A memop consumes as address calculation, and an op RCU executes takes
  no bypass (V-48). A predicate use, a cross-lane producer, a memop
  producer and a copy-only op never bypass.

With today's values a lane producer wakes at 4, 6 or 7 (4 + 3 lands on the
PRF read), so three wakes are distinct; the hardware keeps four select codes,
since the penalties are tunable (OA's response OI-16). In the model, `woff_`
is the per-cell select and `cellOk` the per-cell AOI.

Configure it with `CCV_OOE_CONFIG`: `byp.P.C=N` (255 for none), `fast.U=N`,
`lat.U=N`. The unit tests run an SFU configuration (`fast.4=6`, SFU to SFU
6, SFU to ALU 9, ALU to SFU 5) on odd seeds, and check integer, FP and SFU
pairs cycle by cycle. A control must be caught: a core bypassing faster
than the table its environment holds it to.

## Sectioned lanes (OI-29 to OI-34)

Each lane block has four 32-bit operand ports, each split into four 8-bit
sections. Four-wide issue into a lane block is possible only for narrow
`chwidth` ops in separate sections (DA, OI-28). The model carries this under
`Config::sectioned`, on for the kernels: the adapter sends each operand's
row and position from its name (TI's nine-slot issue, OI-32). Every S1
register is 32-bit, so the kernels exercise full-width footprints only.
The unit tests and sweeps run narrow registers. The kernels' no-resource-cap
control is `inject_double_grant`: select grants one more lane op and one
more memop onto held sections and pipes, and RCU must refuse the overlap
(V-60).

- **Names.** A register is a slice of a PRF row, named `row * 4 + position`.
  A 32-bit register takes the whole row. A 16-bit one takes an aligned pair
  (positions 0 or 2). An 8-bit or 4-bit one takes one section, so 4-bit gets
  4x the rate, not 8x (OI-29).
- **Rows.** One tier-1 slot owns a row while any of its sections is live
  (V-62). Freeing the last live section frees the row.
- **Placement.** A narrow destination goes, in this order:
  1. to its old destination's position, on a merge;
  2. to an existing narrow source's position;
  3. to its home position.

  The home position comes from `place`. 0 is the decided default (DA's
  response OI-35, 2026-10-09); the others are sweep arms, and OA-14's
  rotation is withdrawn:
  - 0: the tier-1 slot index;
  - 1: position 0 for every warp;
  - 2: a per-warp counter, advanced at each taken backward branch;
  - 3: the same counter, starting at the slot index;
  - 4: the slot index plus the architectural destination (OI-34's arm).

  The lane swizzles inside its 32-bit word, so no op ever moves data
  between sections.
- **Footprint** (OI-30 revised, AR-12). An op's footprint is the union of its
  operands' sections, widened to `foot_min[bypass_group]`, which comes from
  the generated `CCV_P_FOOT_MIN_*` (TI's response IS-7):
  - integer 1;
  - FP 2 (a section pair);
  - SFU 4;
  - address calculation 1, counted in MIU pipes;
  - warp-collective and predicate 0, which takes R.

  An op RCU executes takes R. A memop takes the MIU pipes P0-P3 of its data
  register's sections: a load's destination, a store's data source.
- **Select** grants nine resources: S0-S3, R and P0-P3. Each resource picks
  its oldest ready requester. An entry issues only if it wins every resource
  in its footprint, so co-issued footprints are disjoint by construction
  (V-60). An entry that wins some resources but not all counts
  `select.lost_resource`. The issue port is the footprint's lowest resource.
- **A masked load's copy** is a lane op of its own and issues at least a
  cycle before its load (V-61). Its sources are confirmed first, so it
  cannot be cancelled after the load has gone. Unsectioned, the copy leaves
  with its load, as before.
- **Any destination makes the copy** (TI-36 (b), OA's rev 180). A load or
  atomic at a partial mask, or guarded, makes the copy whether its
  destination is a GPR or only a predicate (ld.pred). For ld.pred the copy
  carries the old physical predicate into the new, so the inactive lanes
  keep their bits, and the load itself then reads no old predicate. Control
  `pred-copy-lost` makes none for ld.pred. The test runs from `main()` only:
  no stub carries ld.pred yet, and ooe_rendep's copy reads the old GPR
  destination. The RTL copy must read the old predicate when ld.pred
  reaches the stubs.
- **The local forms** (IS-19, O-69; OA's rev 183). ld.local, st.local and
  their predicate forms are ordinary memops with no base source: DEC sets
  no src_valid for rbase, so rename reads none and the memop waits on
  nothing but its data, and OOE copies local_form to MIU unexamined (TI's
  pass-through); MIU forms the address and ctx itself. A partial ld.local
  makes the masked-load copy; the predicate forms take ld.pred's path.
  Directed test ldLocal, control `local-base` (the load reads a base, so
  it waits for its producer).
- **No GPR destination is the zero register** (TI-37). An op without a
  GPR destination, ld.pred's copy among them, names the zero register's
  name as phys_dst on the issue and the memop (and as its old destination),
  never 0: row 0 is a real row. Nothing writes the zero register (A-64).
  The unit environment's write tracker skips that name, and it checks every
  issue and memop: an op that writes no GPR names the zero register, one
  that writes a GPR never does (OA's rev 182). Control `none-row-zero`
  sends 0 instead.
- **Loads passing loads** (OA-13, deferred to PF-28 by DA's response of
  2026-10-09; a sweep knob only, off): with `loads_pass_loads`, a
  plain load passes older unissued plain loads of its warp. It never passes
  a store, an atomic, a fence or an ordered access. Off, memops issue in
  program order per warp (OI-15).
- **Checks.** V-63: every lane operand sits inside the footprint. V-62: the
  per-cycle partition check is exact per section and per row owner. The
  unit harness checks, from names alone, that no two lane ops in a cycle
  share a section.

Statistics:
- `sections_per_op.wN`: sections per issued op, by destination width;
- `sections_idle`: idle sections per cycle;
- `issue_per_cycle`.

Configure it with `CCV_OOE_CONFIG`: `place=N`, `loads_pass_loads=1`,
`foot.G=N` (0, 1, 2 or 4).

## The arrival-cycle checker on `ccv_rcu_ooe_done` (V-35, repo Q-53)

A dependant issued at the contracted latency reaches RCU one issue crossing
later, and must read the result there. So RCU has written it by the cycle
before. Its done is sent with the write, so the done lands no later than:

```
issue + (CCV_LAT_HOP + issue stages) + LAT - 1 + (CCV_LAT_HOP + done stages)
```

LAT is the producing unit's latency: `CCV_LAT_RCU`, `CCV_LAT_LANE`, or a
configured spare unit's (see "Bypass groups"). That is 6 and 10
cycles at no repeaters. The S1 RCU answers in 4 and 8. Earlier is a faster
RCU, which is safe. Later breaks the contract the dependants were woken on, and
the checker names the instruction. `--break movi-in-lane` is its control. The
RCU session should confirm the bound or name its own; it is the model's
reading, not a parameter yet.

## Atomics: read, lane op, write (AR-21)

The design doc's section of that name, as the model builds it. An atomic
(`mem_kind` atomic) splits at rename into three RS entries under its one ROB
entry and rob_tag:

- **A1**, MIU class: the exclusive read into T, sent as `mem_op` 2
  (atomic-read), with the address source, its displacement and the guard.
- **A2**, RCU class: the lane op, T and the operands into N, its opcode
  DEC's for the atomic, passed through unexamined (A-66). Its wake is the
  lane latency.
- **A3**, MIU class: the write of N and the release, `mem_op` 3
  (atomic-write), with the store data alone.

T is rd's new name for atom, and a temporary for red; N is always a
temporary. Both are taken at rename (an atomic takes two names, two MIU
entries and one RCU entry), are whole rows when sectioned (32-bit data), and
free at retire. A masked or guarded atomic that writes rd gets the copy for
T's inactive lanes, which goes with or before its first read (A-38, V-61).

- **At the head (V-69).** A1 issues only when its ROB entry is its warp's
  head and its sources are confirmed. A2 and A3 issue only inside a pass,
  after its read has issued in an earlier cycle: a return to Waiting
  reaches the registered ready a cycle late (OI-51), and the read, a memop,
  is never replayed to catch a lane op granted on the old bit. Younger
  memops of the warp wait for the atomic's last write; younger lane ops go
  around it.
- **Passes (V-72).** A3's completion carries `more` while lanes remain. On
  it the three steps return to Waiting and issue again. A completion names
  its step by `rs_idx`. The steps are held across passes: confirmation
  frees none of them until the last pass, when A1 and A2 go and A3 confirms
  on its wake.
- **One wake (V-71).** T's consumers name A3 and wake on its last
  completion. The ROB entry completes only then, once every step has
  confirmed and freed (V-58).
- **Faults.** A fault comes on the first read, with no hold. The steps
  free and the entry faults at the head as usual.
- **Demotion and kill (V-70).** While the head is an atomic in progress, no
  demotion trigger is reported (`demote_trigger.held_atomic` counts the
  cycles) and a demote from RAU waits (`demote.held_atomic`) until the last
  pass; a kill meanwhile supersedes it. A kill of a pass in flight keeps the
  three steps, so the pass writes and releases. The steps may issue though
  the warp is killing, no later pass starts, and the entry, held as
  squashed, releases on that write's completion, which the kill's ack waits
  for.
- **Rename's ports.** A cycle's RS rows per class and its GPR names stay
  within the width: ooe_rs has that many allocation ports per class, the
  free list as many, and fits_stale 6's allowances hold back at most the
  width. Only an atomic (two MIU rows, two names) or a masked load with its
  copy (two RCU rows) takes more than one, so with neither nothing changes
  (`stall.rename_ports` is 0 over the 200 ordinary random runs).
- **Measured** (`atomic.passes`, `atomic.hold_cycles` from the read's issue
  to the write's completion, `atomic.head_wait` from the read's first
  ready to its issue). Over 25 seeds of random programs, about one op in
  twelve an atomic: 5,005 atomics, 4.27 passes each, 42.1 cycles held a
  pass, 240.8 cycles waiting for the head. The wait for the head is the
  cost OA named (an earlier non-speculative point is its remedy); CP's
  histogram kernel is the measurement that counts.

The environment's MIU holds a pass's lines from its read to its write and
checks that a read follows every older instruction's retirement, that no
read comes before the last pass's write, and that no hold outlives its
atomic. It holds T's consumers to its last pass. `testAtomic` runs three
passes in five configurations, for atom, red, masked and guarded;
`testAtomicFault`, `testAtomicKill` and `testAtomicDemote` take the other
paths, and `testAtomicRandom` mixes atomics into the random programs in
every select form. They run in `ooe-test` alone, not in the benches'
random set: no OOE RTL re-issues on `more` yet. Controls `atom-off-head`,
`atom-early-wake` and `atom-demote-mid` must be caught.

## Demotion's model side (TI-24) and the swap environment (TI-21)

**What OOE sends now (TI-24's asks, OA's revs 149-151).**

- **The trigger.** The MLC-miss trigger is now "the head is a load still
  outstanding at MIU, blocked longer than `demote_mlc_miss`"
  (CCV_DEMOTION_THRESHOLD_MLC, which exceeds CCV_LAT_MLC_HIT_MAX). The
  completion's `mlc_miss` comes with the data, too late to demote on.
  `mlc_miss_seen` on the status reports that condition.
- **exited.** It is raised once the warp's exit has retired and its ROB
  holds nothing, a deferred free included, so no memop is out at MIU. It
  is sent once, as it rises; the level holds until RAU frees the slot.
- **The rewind.** At a demote, before the squash, OOE takes each lane's
  oldest unretired uop across the ROB and then the decode queue. Lanes that
  share a PC merge into one beat, oldest first. The beats follow the epoch
  notice on the redirect channel (`epoch_only` and `rewind`, the lanes in
  `taken_mask`, the PC in `target_pc`), one a cycle at its rate. `drained`
  waits for the last beat to land, and `resume_pc` is the oldest beat's.
  `demote.rewind_beats` counts the beats per demote.
- **A fix the swap found.** A checkpoint free resolved in the cycle OOE
  demotes or kills the warp would go out with the epoch notice, after FET
  has reset that warp's checkpoints at it (V-46). OOE now drops that
  warp's frees from the cycle's mask, since FET frees them itself.
- **The replay drain and refusal (TI-21, TI-25; TI's edits, OI-18's
  pattern).** A demote's squash always sends a bulk discard of the whole ROB
  (`squashAfter`'s `discard_all`; branch == tail), so MIU ends the warp's
  loads with replay completions and reports it ready to RAU; drained then
  waits for no fill. A discard of an empty ROB carries id class none. The
  discard's trace identity is read before the squash loop releases the head
  (it read a released entry's 0 before). A demote that lands once the
  warp's exit has retired is refused: drained with `refused` set, no squash,
  map or rewind (`demote.refused`). Measured and checked in "The replay
  drain (PF-23) and the refused demote and parked layout (TI-25)", below.
- **The PRF's read ports** (DA's response OA-6: 16; no parameter yet).
  Select keeps a cycle's operand reads within the ports a migration leaves:
  a demote's 17 reads hold one port for 17 cycles. The limit never binds
  without a migration (0 over the 200 ordinary random runs).

**The environment** (`Env::Swap`, ooe_test.cpp). It is AR's rev 86 as OA
adopted it (revs 131-133), standing in for RAU, PCA and FET:

- A crossing is CCV_LAT_HOP and RAU decides in a cycle, so a demote reaches
  OOE 2 hops + 1 after OOE's trigger.
- A demote: drained to RAU, migrate to RCU, 17 rows to PCA, done to RAU,
  and the slot frees. A restore: restore-allocate with PCA's command beside
  it, 17 rows to RCU, done to RAU, activate. RAU frees a slot and picks its
  next warp at the same decision.
- One demote and one restore may be in flight, in different slots.
- Selection is the oldest ready parked warp. A demoted warp is ready when
  its fill lands (DRAM fills drawn from 700 to 1,300 cycles), and its
  replayed load then hits. A restored warp may demote again only after P
  retirements.
- `mode` is `kEvict` (demote on the trigger always; the policy, DA's decision) or `kSwap` (demote only with a ready parked warp; a knob).
- The knob's own bench, `testSwap` in the default run: on the 8-warp
  workload, under every go form, a demote's squash leaves exactly the
  warp's committed registers and no RS entry, the first rewind beat is the
  oldest unretired uop and `drained` names it, no slot runs two warps, and
  every warp retires its whole program. Control `rewind-order` (beats
  youngest first) must be caught.

**stall_hole** (`ooe-test --stall-hole`, 48 seeds, decq 13, the late
take; the old drain, `OOE_TEST_CONFIG=replay_drain=0`). The decided go (interleave, shares), warps 1 to 3 against their solo
time:

| fix | swap off (fill 400), held / fetching | swap, none ready | swap, one ready | evict, none ready | even-stall sweep |
|---|---|---|---|---|---|
| none | 1.543 / 3.206, 44 starved | 2.257 / 3.917 | 1.057 / 1.118, 1 starved | 1.043 / 1.080 | 1.000 |
| stall-aware shares | 1.505 / 3.117 | 2.203 / 3.813 | 1.065 / 1.158 | 1.043 / 1.107 | 1.033 |
| per-class caps 20 / 10 | 1.523 / 3.190 | 2.258 / 3.901 | 1.047 / 1.080 | 1.028 / 1.045 | 1.003 |
| decq per warp 6 | 1.435 / 1.866 | 2.021 / 2.245 | 1.043 / 1.045 | 1.045 / 1.045 | 0.875 |
| decq per warp 4 | 1.415 / 1.673 | 2.006 / 2.116 | 1.046 / 1.045 | 1.047 / 1.047 | 0.826 |
| decq 6, stall-aware shares | 1.261 / 1.566 | 1.447 / 1.460 | 1.042 / 1.042 | 1.040 / 1.040 | 0.899 |

The bounds are 10% held, 15% fetching, and no window of 800 cycles in which
warps 1 to 3 retire nothing.

- **The hole is the decode queue first.** With no per-warp limit
  (CCV_P_DECQ_WARP_MAX = 13), the stalled warp holds all 13 entries: its
  ROB is full of the chain, so it cannot rename them. Warps 1 to 3 then
  rename nothing. RS fixes alone do not touch it. Stall-aware shares cut
  warp 0's RS peak from 28 RCU and 15 MIU entries to 18 and 10, and warps 1
  to 3 move by 3%.
- **No form or fix meets the swap-off bound.** Every swap-off arm misses
  it; the best, decq 6 with stall-aware shares, gives 1.26 and 1.57. Warp 0
  keeps what it took before its stall was known.
- **Swap with a ready warp and evict meet it, with a per-warp decode-queue
  limit.** At decq per warp 6, the swap arm is 1.043 and 1.045, no
  starvation, every gap within T + D + 56 + R, and R = 5. Without the
  limit, one seed in 48 starves after the restore, when warp 0's long
  dependent tail fills the decode queue again.
- **The slot is not freed by a swap.** OOE's drain waits for every
  outstanding memop, and the DRAM load that demoted the warp is one. So the
  slot stays held until the fill lands (D is about 700 to 1,100 cycles),
  and the parked warp goes into a slot an exit frees, not warp 0's. A swap
  buys what its squash frees, the RS and decode-queue room, but not slot
  time. A replay completion for a demoted warp's outstanding load lets
  the slot go at once: that is PF-23's replay drain, below, and these
  figures are the old drain's (`replay_drain=0`).
- The gap is measured from the miss reaching the head to the restored
  warp's first rename. It ends one cycle past T + D + 56 + R, because the
  trigger fires when the stall exceeds T.
- The other forms (one warp, two warps) follow the same pattern; the full
  table is `--stall-hole`'s output.

**The swap sweep** (`ooe-test --swap-sweep`, 48 seeds; the old drain). 8 warps, 4
resident and 4 parked, each a sweep program, with 2% of loads missing to
DRAM. Against swap-off, where the parked warps enter only as residents
exit:

| go | swap at 25 / 50 / 100 | P 1 / 32 | evict |
|---|---|---|---|
| interleave, shares | 0.798 / 0.738 / 0.737 | 0.738 / 0.775 | 0.744 |
| one warp | 0.824 / 0.855 / 0.853 | | |
| two warps | 0.814 / 0.829 / 0.821 | | |

- **The PRF ports cost nothing measurable.** The read-port charge held
  back no read in any run, and a restore's write port was short in at most
  one cycle in 48 runs, under OA's 1%.
- **The threshold.** At 25 the decided go is 8% slower than at 50, so the
  early MLC-miss notice (PF-39) shows no gain there. Under one warp, 25 is
  3% faster.

## The replay drain (PF-23) and the refused demote and parked layout (TI-25)

**The replay drain** (OA's rev 160, AR's revs 106-107; TI's form, merged
from ad6ef02). A demotion's squash always sends a bulk discard of the whole
ROB (`squashAfter`'s `discard_all`), and every bulk discard covers the
warp's loads in its range as well as its stores. MIU answers each covered
load once with status replay (2; 1 is a fault), so `drained` waits for
those completions, not for the fills. A squashed load's destination stays
deferred-free until its completion, and a hint for it was already dropped
by the squash. A replay for a live entry is an error. `replay_drain=0`
sends a demotion's discard only when stores force one, so it is the old
drain only where no store is at MIU.

The environment's MIU follows AR's three conditions: it answers each
covered load once with replay, its data beat and its own response
dropped, so nothing lands in a register freed to the slot's next occupant.
A load whose completion or beat is already under way finishes as it is.
It raises no hint for an orphan. The line still fills, so the replayed load
hits after the restore. A parked warp is ready when its last abandoned
load's own answer comes (`ccv_miu_rau_ready`, AR's rev 107). `testSwap`
spreads the replays over 60 cycles so the drain's wait is visible. It
checks that every demotion abandons loads and that no `drained` comes with
a completion still owed. Control `drain-early` (drained waits for no
replay) must be caught.

**The swap sweep under it** (48 seeds, at the merge with TI's ad6ef02),
against the old drain at 18b33e1:

| go | policy | old drain (18b33e1) | replay drain | gap from the miss at the head, old / replay |
|---|---|---|---|---|
| interleave, shares | swap at 25 / 50 / 100 | 0.798 / 0.738 / 0.737 | 0.684 / 0.646 / 0.649 | 1,351 / 242 at 50 |
| interleave, shares | swap, P 1 / 32 | 0.738 / 0.775 | 0.646 / 0.644 | |
| interleave, shares | evict | 0.744 | 0.588 | 1,286 / 378 |
| one warp | swap at 25 / 50 / 100 | 0.824 / 0.855 / 0.853 | 0.634 / 0.654 / 0.641 | |
| two warps | swap at 25 / 50 / 100 | 0.814 / 0.829 / 0.821 | 0.680 / 0.686 / 0.671 | |

- **The slot now comes back during the fill.** The gap from the miss at
  the head to the next warp's first rename falls from 1,351 cycles to 242
  under the decided go, and the swap goes from 0.738 to 0.646 of swap-off.
- **Evict now beats swap**, 0.588 against 0.646. With the slot returned at
  once, demoting without a ready parked warp costs only the restore.
- **Provisional restore** (AR's rev 115; `Swap::provisional`). A free
  slot with no ready parked warp takes the oldest parked warp whose fill
  is still out. Its P count starts at its ready report, and before then it
  may demote on the trigger. Its replayed load merges at DCU into the fill
  in flight (`merged_fills`). At threshold 50 it gives 0.654 under the
  decided go, against 0.646 without it (57 provisional restores and 45
  merged replays in 48 seeds, and 521 declined demotes against 417). Under
  one warp it gives 0.658 against 0.654, and under two warps 0.690 against
  0.686. The gap falls from 242 to 214 cycles, but the workload's four
  parked warps are ready from the start, so a slot rarely has no ready warp,
  and a provisional warp holds the slot when one becomes ready. In this
  workload it costs about 1%. TI's swap kernel, where a slot otherwise
  idles, gains. `testSwap` runs it on six seeds and checks that
  provisional restores and merged replays both happen.
- Swap-off itself moved at the merge (the decided go 6,727 to 6,442
  cycles), since a branch's discard now also replays its wrong-path loads.
- The PRF ports still cost nothing: no read held back, no write port short.

**Evict, the policy (DA; OA's rev 64), and the provisional restore under
it** (AR's revs 116-117). The environment's RAU now evicts by default
(`Swap::mode` is `kEvict`); swap is the knob, and the bench (`testSwap`)
runs both. AR's provisional restore takes the longest-parked warp whose
fill is still out (the age order, not the soonest fill). PF-41's variant
pre-empts it the moment a parked warp is ready and no slot is free, with
no threshold wait. 48 seeds, against swap-off:

| go | evict at 25 / 50 / 100 / 150 / 200 / 300 | evict, provisional | evict, provisional, pre-empting | swap (knob) |
|---|---|---|---|---|
| interleave, shares | 0.624 / 0.588 / 0.603 / 0.646 / 0.625 / 0.684 | 0.641 (675 provisional) | 0.627 (28 pre-empted) | 0.646 |
| one warp | 0.608 / 0.564 / 0.592 / 0.613 / 0.639 / 0.664 | 0.649 | 0.671 | 0.654 |
| two warps | 0.645 / 0.648 / 0.628 / 0.600 / 0.644 / 0.702 | 0.650 | 0.676 | 0.686 |

- **Neither arm beats evict.** Under evict a slot frees with no ready warp
  often, so the provisional restore fires (675 times against 57 under
  swap). The restored warp is still blocked on its fill, though, and evict
  demotes it again at its next stall: restores double (971 against 470)
  and so do the declined demotes. Pre-empting it when a ready warp appears
  recovers 1.4 points but stays behind plain evict. So evict stays the
  default, and the provisional restore stays a knob, off.
- **The MLC threshold, swept (AR's rev 118).** The first sweep had 100
  beating 50 (0.552 against 0.588), and it was a model bug: the
  fallback's report (any head stall past CCV_DEMOTION_THRESHOLD, 50) set
  mlc_miss_seen whenever the head was an outstanding load, and RAU's MLC
  policy demotes on that bit, so the MLC threshold never governed above
  the fallback's. The report now carries the bit only once the MLC
  trigger itself has fired (a directed test, `testMlcTrigger`, with its
  control fallback-claims-mlc). Fixed, the decided go reads 0.588 at 50
  (unchanged: there the two triggers coincide), 0.603 at 100 and 0.646,
  0.625 and 0.684 at 150, 200 and 300. On this sweep, 50 is best, by 2.5%
  against 100. The declined demotes fall at 100 and above (21 against
  324): those were the duplicate reports at 50, not slow loads spared.
- **S1 under evict (skeleton, CCV_RAU_DEMOTE=mlc), the same fix:** at 50,
  gather and vadd4 demote on a load that would land soon, and take 388
  and 319 cycles; at 100 and above neither demotes, and they take 314
  and 227. stall, swap and vaddslow demote once at every threshold, with
  the same cycles. provswap (its check-kernel run sets both thresholds to
  150) takes 1,947 cycles at 50 and 2,110 at 100. The other 17 kernels
  never demote. So the sweep, whose misses are long, prefers 50, and the
  S1 kernels, whose misses are short, prefer 100: AR's to weigh.
- TI's provswap kernel runs the skeleton's RAU, which has the provisional
  restore but not the pre-empting variant, so the variant is measured
  here only.

**stall_hole under it** (48 seeds, the decided go, at the merge with TI's
ad6ef02; warps 1 to 3 against their solo time, held / fetching):

| fix | swap, one ready, old drain (18b33e1) | swap, one ready, replay drain | four live warps (reference) | slot gap, old / replay |
|---|---|---|---|---|
| none | 1.057 / 1.118 | 1.212 / 1.431, 3 starved | 1.167 / 1.165 | 1,350 / 236 |
| decq per warp 6 | 1.043 / 1.045 | 1.199 / 1.202 | 1.196 / 1.190 | 1,350 / 162 |
| decq per warp 4 | 1.046 / 1.045 | 1.145 / 1.140 | 1.134 / 1.120 | 1,350 / 134 |
| decq 6, stall-aware shares | 1.042 / 1.042 | 1.189 / 1.187 | 1.195 / 1.180 | 1,350 / 168 |

(The decq rows are with the per-slot take below; the stall-aware row is
from before it.)

The other arms barely move: swap off and swap with none ready restore no
warp, and evict with none ready is 1.035 under decq 6. The swap arm now
reads over its 10% bound against solo, because the parked warp is back in
the slot about 188 cycles after the miss, not 1,350, and runs beside warps
1 to 3 for most of their time. Solo is warps 1 to 3 alone, so the bound
also charges an ordinary fourth live warp. `--stall-hole` therefore prints
a reference arm, "four live warps": the parked warp's program in slot 0
from cycle 0, with no stall. Against it the swap arm adds 0.3% and 1.0%
under decq 6, and 1.0% and 1.8% under decq 4. The hole is closed with
the per-warp limit; without it, the stalled warp's decode-queue hold still
costs 4% held and 23% fetching over the reference. The bound for this arm
should be read against the reference (OA's call).

**The decode queue below its depth** (TI's rev 102). At
CCV_P_DECQ_WARP_MAX = 6, ooe_decq's live compare tripped its
`enq_within_credit` assertion. The model freed a slot's room the cycle
rename took from it, and ooe_decq frees it at the next edge, when its
count subtracts the registered take. At a limit of 13 the shared pool binds
first, so the difference never showed. The model now counts a slot's takes
of the cycle against it under `decq_late_credit`, as the pool does
(`decq_slot_take_`). With that, ooe_decq's live compare (25 seeds) and its
four controls pass at 6 and at 4, failing at 6 without it, and check-cg's
bench passes at both (DCGE at least 90% at 6 and 95% at 4, high scenario)
once its unit's D matches the parameter.

With it, the even-stall sweep is 0.863 of no fix at 6 and 0.802 at 4, and
the S1 kernels (one warp each, the swap kernel among them) against no limit:

| limit | kernels slower than at 13 |
|---|---|
| 6 | none of 23 |
| 4 | mlp, 124 against 120 cycles (3.3%) |
| 2 | 22 of 23, up to 10.8% (mlp 133 against 120) |
| 1 | all 23, up to 41% (chains 137 against 97) |

So S1 loses at 4, in mlp alone, and not at 6.

**TI-25 (AR's rev 112, OA's rev 165).**

- **Refused.** Every demote gets exactly one `drained`. If the warp's exit
  has retired when the demote lands, OOE does no squash, sends no map, no
  epoch notice and no rewind beat, and sends `drained` with `refused`.
  `exited` follows at the quiesce, and RAU cancels and frees the slot on
  it. The directed test checks exactly that, and control `no-refuse`
  (demote the exited warp anyway) must be caught. TI's ad6ef02 carries the
  refused bit on `ccv_ooe_rau_drained`, which the adapter sends.
- **The parked layout.** The demotion moves one row per architectural
  register, 16 plus the predicate row, with no merging. OOE keeps, per
  warp_id, each GPR's position and committed width (`Core::parked_`, 64
  bits a warp, 2 Kb for 32 contexts; `docs/ooe-rtl-plan.md`'s tally). It is
  written at the demotion's map. Restore-allocate gives each register its
  own row at that position and width, and restores the committed width
  table (OI-57) from it. The directed test parks a sectioned warp with
  registers at positions 2 and 1 and a chwidth, restores it into another
  slot, and checks 16 distinct rows, each register at its position and
  width, and the table. Control `park-layout-lost` (restore at 32 bits,
  position 0) must be caught.
- **The CTA slot** (TI-34, OA's revs 176-177). Each tier-1 slot holds its
  warp's CTA slot (`Slot::cta_slot`), loaded at launch and at
  restore-allocate (`Alloc::cta_slot`; a parked warp keeps it at RAU), and
  stamps it on every memop, discard included, barrier and fault. The
  environment, as RAU, gives each warp a nonzero slot and checks every
  memop, barrier and fault against it, every cycle of every test. Control
  `cta-slot-zero` (slot 0 stamped) must be caught. The field on
  `ccv_rau_ooe_alloc` is AR's; the adapter passes it when it lands.
- **%lanectx** (srd #2, O-64, OA's rev 177). `UopShape::srd` 2: OOE
  substitutes ((core index << 5) | warp_id) << 5, the lane ORs its index in,
  beside selector 0's warp_in_cta << 5. The core index is
  `Config::core_id`, 0 on a one-core build (CCV_P_CORE_ID, TI's tie-off);
  the 32-bit immediate holds clog2(cores) + 10 bits. The directed test
  issues one at core 0 and core 3. The imm_kind code for it is TI's.
- **The final-exit bit** (TI-27, OA's rev 170, superseding rev 169's parked
  live mask). OOE holds no live mask. FET marks the exit whose fetch clears
  the warp's last live lanes (`UopShape::final_exit`), and the warp is done
  when that uop retires: exited follows at the quiesce, and a demote is
  refused after it. A partial exit (div's or spinwait's shape) leaves the
  warp running. The parked entry stays 64 bits. A check, not design state,
  keeps per warp_id the lanes whose exit has retired; the final exit's
  retire asserts they are all 32. The environment marks the exit as FET
  does, in program order; the adapter marks every exit final until TI puts
  the bit on `ccv_dec_ooe_uop`. The directed test exits lanes 0-15, demotes
  the warp on a miss in lanes 16-31 (drained, not refused, no exited), and
  in a second run ends it at the marked exit of lanes 16-31 (exited once).
  Control `final-exit-early` (the first exit marked) must be caught.
- **A destination's width is its committed width** (OA's rev 166). No
  channel carries a width from DEC, so rename takes a destination's width
  from the committed table (`Core::dstWidth`); chwidth holds rename until it
  retires, so the table is current there. The park asserts that each
  committed name has its register's committed width, so the 64-bit entry is
  the whole state. A test's narrow registers (`Op::w`) become its warp's
  committed widths, set once its launch lands (`Core::presetWidths`, a
  test-only stand-in for chwidths retired before the program). The random
  generator keeps a memory access's data register at 8 bits or wider, since
  a 4-bit one now faults F-WIDTH as the ISA says. A directed test renames
  narrow hints against a 32-bit table and checks 32-bit names; control
  `width-from-dec` (rename at the hint's width) must break the assertion.

## S1 modes: what the neighbours carry today

The adapter configures the core for what the S1 stubs implement. Each mode is
a `Config` flag the unit tests run both ways, so turning one on is a
one-line change when its neighbour is ready.

| Flag | S1 | Why off in S1 | Turned on by |
|---|---|---|---|
| `bypass` | **on** | On since OI-5. TI's lanes answer at `CCV_LAT_LANE` − 1 and forward a dependant's operand at `CCV_LAT_LANE_BYP`, steered by `operand_byp` (TI-8, `8f4345d`). `CCV_OOE_CONFIG=bypass=0` gives the conservative run. | — |
| `l1_spec` | **on** | On since OI-5. MIU completes an L1 hit at exactly `CCV_LAT_L1_CMPL` (A-46, `31f6143`), and RCU's register read sees the same cycle's load data. `CCV_OOE_CONFIG=l1_spec=0` gives the conservative run. | — |
| `rename_preds` | **on** | On since OI-3. Predicate sources reach RCU renamed (TI-1), and the adapter keeps `Kernel::prat0`, warp 0's committed predicate map, at retirement, as it keeps `rat0`, so the final compare reads through it. `CCV_OOE_CONFIG=rename_preds=0` restores the fixed `physPred` windows and the `hold.pred_window` ordering. | — |
| `memop_rcu_done` | off | Settled (OI-4, Daniel 2026-10-08): RCU sends no done for a memop, and a memop completes on MIU's completion alone. The flag stays for the unit tests until OI drops it. | Done: TI's RCU stub stopped sending them |

With `rename_preds` off, each warp's predicates live at their window. OOE
orders a predicate write itself: behind every older writer of that window,
until it completes, and behind every older reader, until it has issued in an
earlier cycle (`hold.pred_window`).

The swap runs end to end (TI-24): the adapter sends status reports (exited
among them), a demoting warp's map and rewind beats, and its drained report;
RAU demotes on a report when `CCV_RAU_DEMOTE` asks it to, parks the warp in
PCA, and restores it into a free slot (restore-allocate, then
restore-activate once PCA's rows are written). The S1 CRU and SYU stubs consume nothing OOE sends them, and no S1
kernel kills, faults or waits at a barrier. So the adapter turns a fault into
a check failure, and fails on a barrier or kill ack.
The kill ports are not in the C++ machine yet, so kill is reached only by the
unit tests.

## Parameters that were knobs

The model reads every size and latency from `ccv_params.h`. TI added the
ones the model's knobs stood for (OI-6, OI-13; `456b3e9`), and each
`Config` field now defaults to its parameter:

| Field | Parameter | First-build value |
|---|---|---|
| `rs_warp_cap` | `CCV_P_RS_WARP_CAP` | 45, both classes: no cap |
| `decq_warp_max` | `CCV_P_DECQ_WARP_MAX` | 12, the queue: no limit |
| `demote_mlc_miss`, `demote_barrier` | `CCV_DEMOTION_THRESHOLD_MLC`, `_BARRIER` | 50 each, values wait on OA-8 |
| `cmpl_wake_delay` | `CCV_LAT_L1_MISS_WAKE` | 0; 2 under `links_split` |
| `byp` shape | `CCV_P_LAT_CLASSES`, `CCV_P_BYP_GROUPS` | 8 × 9; values wait on OA-4 |

`rename_width` stays at `CCV_ISSUE_WIDTH` ("4 uops per cycle"), and
`unit_lat` for `lat_class` 4 to 7 waits on OA-4. The sizing sweep runs with
no per-warp limits unless it sweeps one, since a "no limit" value equal to
today's size would limit a larger one.

`fl_buf` (8) and `fl_banks` (4) are the free lists' candidate buffer and
refill banks (OA's response OI-38): allocation takes the buffer's head, and
each edge refills it from the banks, so a freed row reaches allocation two
cycles later. `fl_buf=0` is the earlier rotating-pointer list, one cycle;
no kernel or sweep arm moves between them. Restore-allocate takes its
registers through the buffer too (OI-41, see Free lists).

`decq_late_credit` (on, DA's response OI-39): a decode-queue entry freed in
a cycle counts as held for that cycle's arrivals, so it takes one only from
the next. That is what lets the RTL's queue fit its stage. `ooe-test
--sweep` runs the old same-edge behaviour (`decq_late_credit=0`) at 6, 8
and 12 entries for comparison.

`decq_take_late` (on; OA-21, DA 2026-10-20): rename's take is
registered in the decode queue and popped an edge late, so the taken
entries hold their credits one cycle more, as `decq_flush_late` holds a
flush's. `ooe-test --sweep` measures it under each go (`rename_one_warp`
0, 1 and 2), 48 seeds: it costs 1.8 points under the interleave, 3.5
under one warp and 3.1 under two. One more decode-queue entry takes back
all of it under the interleave, 2.3 points under one warp and 1.9 under
two.

`fits_conservative` (3; OA-21, DA 2026-10-20, and OA-22): a go that lets several warps take
in a cycle forms each warp's fits alone, so their sum can exceed the
shared credits (RS room per class, GPR and predicate names). The model
admits against running credits, which is exact. 1 forms each warp's fits
against the credits less the rename width; 2 lets one warp take while any
shared credit is below the width. With the late take, 48 seeds, against the
interleave with an on-time take: two warps at decq 13 are +1.1% exact,
+5.3% under 1 and +1.8% under 2; the interleave at 13 is 0.0%, +6.9% and
+1.6%. RS room is what stalls under 1; GPR and predicate names never do.
DA chose the interleave (`rename_one_warp` 0) with 2, the late take and a
13-entry decode queue (TI's `CCV_P_DECQ`); the exact forms measure 29.1
and 37.6 NGD in the go and fit no stage (`test/ooe/probes`). No S1 kernel
moves between the old defaults and these.

3 is OA-22's registered go, 2 as the RTL can build it. Rename's go must
see the cycle's frees (TI-19), but ooe_rs's free thermometer arrives at
15.6 NGD (confirm, 8.7, then a tree of capped thermometers; counted, 30),
and the go compared against it in front measures 25.4. Frees only add
credit and matter only when a credit is short, so in 3 the go reads
registered state alone: short is tested on the credits without this
cycle's RS frees (RS RCU against twice the width when a candidate head
uop is a copy, which takes two), the short cycle's warp takes without
them, and a warp's fits count its ROB retirements a cycle late. 48
seeds, the interleave at decq 13: +2.5% against the on-time exact go,
where 2 was +1.6% but takes no account of a copy's two RCU entries.
OA accepted it as the default (OA-22, 2026-10-20). Under it at decq 13,
two warps are +3.6% and one warp +3.6%, so the interleave stays ahead.

`fits_stale` (6 by default since slice 4, the go DA decided, OA-21, 2026-10-21; see "What the RTL reads" below): rename's per-warp fits registered a
cycle ahead for every take a warp may make, as OA's option (a) has them.
A uop is then taken no sooner than the second cycle after it arrives, and
frees (ROB retirements, the RS frees in the short test) reach the fits
two cycles late. 48 seeds, against today's default: the interleave +4.4%
(the late arrivals +3.1% alone, the late frees +1.0% alone), one warp
+5.9%, two warps +3.5%.
2 is OA's (a2): the held heads' fits as 1, but a refill is taken at once
and re-checked in Rename 1 (a failing tail waits in the skid, which costs
what not taking it does: 10.6% of 28,875 refills fail in 48 runs); ROB
retirements a cycle late, as ret_n reaches the fits in time; the short
test on the last cycle's shared credits against twice the width (RCU
three times with a copy in a head), and a short cycle's warp against the
shared credits less the width. The interleave +7.0%, of which the margin
is about 5.5 points: short cycles go from 38% to 63%.
3 is OA's per-warp shares: as 2, but no short path; each cycle every
shared credit, as registered, is split equally among the warps with a
head (the remainder to the first in rotation), and each warp admits
against its own share. The interleave +0.0%, two warps +0.8%, one warp
+1.3% (13.0% of refills fail). The split and the fits on one D,
flattened (`test/ooe/probes/sharefits_probe.sv`), measure 25.1 NGD with
the remainder added after the divide; with the first warp's share read
from the credit by table, in parallel with the quotient (share_probe
TAB 2, proved equal), 23.4 from the counters and head valids and 22.3
from decq's heads (map -r), which arrive at about 2: 24.3. 5 drops the
remainder instead: 22.5 NGD, but the interleave +0.6%, two warps +0.7%
(floor shares strand credit: 14,526 fragmentation stalls to 3's 5,310).
6 is 3 as the RTL can register it, and corrects 3's figure. The fits
are formed a cycle ahead, so the allowances they hold a warp to are split
a cycle ahead too. A split of the cycle's whole credit is not safe: the
last cycle's takes, unknown to the split, were bounded by the split
before, so one warp's take is counted against two splits and the RS
over-allocates (the model's own RS check stalled it: 259 rs_full stalls
in 48 runs, where the RTL has none). 6 splits the credit no allowance
holds this cycle, less at most the width (a cycle takes no more from any
credit: a class's ports, a name per uop), so no take counts twice: each
allowance holds for one cycle, and its unused part returns to the next
split. Withholding every allowance, not the width, deadlocks: the credit
alternates between two cycles' allowances. 48 seeds at decq 13 against
983: the interleave 1,023 (+4.1%; +6.7% against the ideal 959), two warps
1,024 (+4.2%), one warp 1,035 (+5.3%, every warp's allowance the whole
pool, as only one takes). 3's one-warp +1.3% admitted against running
credits, which a registered go cannot. Rename's counters (`renCredits`)
exclude this cycle's RS frees and last cycle's past ooe_rs's prompt count,
and this cycle's name frees, as the RTL's (`ooe_rencred`, slice 3).
7 is 4, OA's stateful shares, as the RTL can register them: the credit no
share holds is split each cycle into a register and reaches a warp's
fits a cycle later, so a split is usable two cycles on; a warp
`share_return` cycles without a take returns what it held (not a split
just arriving), decided on its registered takes; a restore-allocate's
draw is taken back from the splits in flight, then the shares. 48 seeds
against 983: return after 1 cycle 1,098 (+11.7%), 2 1,105, 3 1,142, 4
1,164; none deadlock. The worst of the registered forms.
4 is OA's stateful shares: each warp keeps its share, its own takes lower
it, and frees and the shares of warps four cycles without a take form a
pool split each cycle among the warps with a head; the shares and pool sum
to the credit (checked). An idle return keyed on "no head" deadlocks: a
stalled warp with a head keeps its share. The interleave +7.4% at a
four-cycle return, +2.8% at two (the earliest the hardware can key on a
registered take), +0.0% at one, which is 3's per-cycle split again. By
OA's rule (OI-65) OA-21 goes to DA with one warp (+1.3%).

`ren_credit` (2 at `ren_free_cap` 4, TI-19's scheme, accepted by Daniel
2026-10-19: "a 0.6 percent penalty is noise with our limited test list")
is when rename's go decision sees this cycle's frees. 0 is the ideal:
rename sees every RS and ROB free in its own cycle. 1 is OA's
stage-boundary item 4, every free a cycle late, which DA did not accept
(2026-10-19). 2 is TI-19 as OA answers it: a confirmation's RS free counts
in its cycle up to `ren_free_cap` per class (ooe_rs's free thermometer,
4; 2 is the trim), and a retirement's ROB free in its cycle (ret_n); a
free past the cap, or from a squash, kill or a squashed op landing, counts
a cycle late. A confirmation reads only flops in the RTL (ooe_confirm's
iss, dep, fin and prod; never this cycle's miss), so no confirmation free
has to wait. `stall.rob_late_credit` counts a ROB slot held only for being
seen late. Allocation itself stays the RS's first fit with same-edge reuse
(OI-43): only rename's go sees a free late, so the RS bench holds the RTL
to the model under every setting. `ooe-test --sweep` measures them over 48
seeds, since six seeds' noise is about the size of the effect. On
2026-10-19, against TI-19 at cap 4 (963 cycles): same edge 956 (0.993), all
late 970 (1.007), cap 2 966 (1.004), with about 0.6% of noise between arms.
(Measured first with allocation also skipping this cycle's late frees,
which no RTL does, all late read +2.7% over same edge, and six seeds put it
at +5.7%.) No S1 kernel moves under any of them (`sweep.sh`).

`ready_reg` (on; OA's response OI-51) makes select read a registered
ready, as ooe_sched does: a row is ready at select if its lines say so
now, or said so at the end of the last cycle for this one. Every wake
rises a cycle early into the register, so rises cost nothing, but a drop
(a producer returned to Waiting) reaches select a cycle late. An entry may
then be granted on a stale bit (`select.stale_grant`), and the next hop
returns it (`cancel.replay_stale`, counted apart from `cancel.replay`); a
check holds that a stale grant never confirms (OA-17). Over 48 seeds that
is 7.9 stale grants a run, each replayed, at 960 cycles against 963 with
the register off: noise. ooe_select's bench logs the registered value as
`sel_ready`, so a bench of ooe_sched can be cycle-exact.

The register has a clock enable (OA's responses OI-53 and OI-54; V-73),
so select reads it alone. It captures each row's lines for next cycle at
every edge after which any line or row it reads changes, and holds
otherwise. Its leads: ooe_wake's timers and its event lead (a miss, or a
completion past L1, changes lines at the edge after next: each known a
cycle ahead, a completion by its channel's valid, since cmpl_wake_delay
is 1), ooe_sched's own OR of the replay rule over its iss, dep and msd
inputs, and the allocation grant. In the model a change
the timers did not predict a cycle ago (a stop, a miss) is captured on
its own edge, as those leads give it, and V-73 checks that a held
register never differs from the lines. Two controls: `no-alloc-lead`
(a new row never captured: caught), and `late-event`, which captures a
stop or miss one edge late, as V-73 first allowed. That lets a replayed
producer be re-granted inside its dependant's stale window; the
dependant, granted on its stale bit, is never replayed by OI-50's rule
and confirms on a result it read too early (OI-54). The control must hit
that OA-17 check, and does: directed, one warp, a load missing by a
cycle, a producer reading it and the producer's dependant (a random hunt
found it in one run in 100 to 700, and rename's traffic kept moving it;
without the injection the directed cases err nowhere). On time it costs nothing: the
48-seed sweep, the four-warp kernels and the S1 kernels are as without
the enable.

`req_reg` (on; OA's response OI-53) is select's request register, one
bit per entry: valid, not issued, warp active and a copy's sources
confirmed, as an earlier cycle ended. Its enable is what ooe_sched can
form from its own flops (CG-5): a grant last cycle (the grant register,
which masks select until the register drops the entry), the stop lead
(a replay's return on time), and the flop of "the register differs from
its next value and this edge does not capture it", so any other change
is captured one edge late. A late
rise costs a cycle at most; a late fall is safe, since a warp leaves
Active only by a squash of all its entries and select reads valid and
past rename's stages live (ooe_rs's bit). An earlier form held past
rename in the register, captured from the allocation grant; a row freed
and written again on one edge then requested on its last occupant's bit
before it was past rename, which the model's check (OI-53: a candidate
issued or of an inactive warp) and ooe_sched's bench both caught. A
memop's terms stay live in the MIU pick. Over the four-warp kernels and
the 48-seed sweep it costs nothing (alu8 589, alu16 823, vadd8 1034,
cvt8 1246, red8 369; 960). ooe_select's bench logs what select used
(`sel_rq`, `sel_gnt`, `sel_elig`), and the assembled bench
(test/ooe/trio_tb.cpp) compares ooe_sched's request register bit for bit.

`branch_ends_group` (KNOB, off; OI-56, OA's measurement): a branch ends
its rename group, so its checkpoint would be the RAT's state at the next
edge, with no capture path and no output copy of the maps. With 1 (the
branch's slot renames nothing more that cycle), the four-warp kernels
measure alu8 587, alu16 838 (+1.8%), vadd8 1049 (+1.5%), vadd16 1030
(−1.3%), red8 371 and cvt8 1257 (+0.9%), and the 48-seed sweep 964
against 960. The S1 kernels are unchanged: one fetch-bound warp, where
even rename_width 1 costs loop one cycle. With 2 (nothing renames after a
branch that cycle) alu16 is 898 (+9.1%). Over 1% on two kernels, so it
went to DA beside the copy (OA's response OI-56).

### What the RTL reads: the settings audit (OA's rev 122)

Three times a knob admitted against state the RTL could not have in that
cycle, and each time a figure moved by one to two points. So each rename
knob is stated here with the registered value the RTL reads, against the
probe the go is built from (`test/ooe/probes/sharefits_probe.sv`: the split
of `share_probe.sv` into `fitsk2_probe.sv`'s per-warp fits, SHR 1, RET 1,
CAP 0, AR 0). `ooe-test --audit` reproduces it: the sweep's workload, 48
seeds, under the decided go (`fits_stale` 6), counting every admission the
registered fits could not make the same way, then the go with each one
removed. The decided go measures 1,023 cycles there.

Slice 4 makes the decided go the default, with OA's rulings on the
corrections below (OA's response to the OI-45 settings audit, rev 138):
`fits_stale` 6, `ret_now` 1 and `take_young` 0. The names are held as two
counts: each slot's floor still unspent (`unmetFloor`), and the pool above
every floor (`floorsOwed`). The shares split only the pool, each warp's
allowance adds its own unmet floor, and rename's admission drops the live
floor check (`ren_floors_in_share_`), so V-04 holds by construction and is
asserted at the counters. The audit measures the go at 1,025 cycles (48
seeds); the kernels, 6,456 to 6,551 cycles (+1.5%), all of it
`fits_stale` 6: loop one cycle on each of its 99 redirects, and vadd4 25
faster.

| Knob (default) | What the RTL reads | The model under `fits_stale` 6 | Audit |
|---|---|---|---|
| `rename_one_warp` (0) | the rotation's priority bit per warp (`prio`) | the interleave, uop by uop in rotation | exact |
| `fits_stale` (6) | per warp, an allowance of each shared credit split a cycle ahead (`share_probe`), registered with the fits | admits against `share_`, split last cycle | exact: no RS or name stall behind an allowance in 48 runs |
| `fits_conservative` (3) | nothing under the shares: no short path | the short test is computed, then overridden | no effect, except that 3 holds this cycle's retirements (next row) |
| `ren_credit` (2), `ren_free_cap` (4) | rename's counters (`ooe_rencred`): this cycle's RS frees unseen, last cycle's past the prompt count added, names freed now unseen | `renCredits` | exact: `rencred_tb` holds the counters to it every cycle |
| ROB room, its retirements | the fits' ROB term: the slot's room and this cycle's retirements (`rob`, `ret`, RET 1) | `robHeld`: under `fits_conservative` 3 and the shares, this cycle's retirements are held a cycle | **differs** (below) |
| ROB room, a held tail | the same term, a count of free slots | the tail slot must be free (`robHeld(tail)`) | **differs** (below) |
| a uop that arrived this edge | nothing: the fits hold only heads registered before it (AR 0) | taken at once if it passes on live state (the refill) | **differs** (below) |
| `rs_warp_cap` (45) | nothing (CAP 0: the cap is the whole RS) | the cap, which never binds | exact: 0 stalls |
| GPR and predicate floors and ceilings (`ren_floor` 16, `ren_ceil` 64; 4 and 20) | nothing: an allowance of ready names only | `gprAllowed`, `predAllowed`, on live counts | 0 stalls in this workload, but not held by the RTL (below) |
| free lists' buffer (`fl_buf` 8) | the name counters count ready names (`gfree_.ready()`), so the allowance is of buffered names | the same | exact: 0 buffer stalls |
| warp holds: inactive, fault, chwidth, barrier | `hold`, a registered bit per warp | read live, so a chwidth or barrier uop taken ends its warp's take that cycle | the sweep has none; the RTL needs a serial bit (below) |
| `decq_take_late`, `decq_late_credit`, `decq_flush_late` (on) | ooe_decq as built (OA-21, OI-39, OI-58) | the same | exact (decq_tb) |
| `branch_ends_group` (0) | — | off | OA-20 to DA: (b), the copy, recommended |
| `rename_stages` (3) | Rename 1 to 3, the doc's stage table | 3 | exact |

Four corrections follow.

**Retirements.** The probe's ROB term takes this cycle's retirements (ret_n
reaches the fits in time, RET 1), but `robHeld` holds them a cycle under
`fits_conservative` 3 and the shares: 136.9 refusals a run that the
registered room would admit. `ret_now` 1 counts them in their cycle, as the
probe does: 1,021 cycles, −0.2%. The RTL is right; the model's default is
the stricter.

**The ROB term counts the wrong thing.** A squashed entry whose op is still
out keeps its slot valid after the count drops, so the tail can be held
while slots past it are free. The model refuses there (57.5 a run); a fits
term built on "slots not valid" admits, and would write over a held slot.
`ooe_rencred`'s ROB counter is right as a count (rencred_tb holds it), but
the go must read the free run from the tail, up to 2R − 1 = 7: a register
per slot formed from the ROB's valid bits at the edge before, with this
cycle's retirements added only when the run reaches the head. With it, the
fits and the model agree (`audit.rob_refused_within_registered` counts the
rest: 63.2 a run under `ret_now` 1, all a held tail).

**The refill.** Under 6 the model takes a uop the cycle after it arrives
when it passes on live state (617 a run, 229 more failing), as OA's (a2)
does with a re-check in Rename 1. The probe has no arrival term (AR 0), so
the RTL as probed cannot. `take_young` 0 waits for the fits instead: 1,027
cycles, +0.4%. With `ret_now` 1 as well: 1,025, +0.2% against 1,023. Taking
the refill costs `fitsk2_probe`'s arrival term (AR 1) and Rename 1's
re-check with a skid; at +0.4% it is a decision for OA.

**Floors, ceilings and serializing uops.** Neither binds in this workload,
and neither is in the probe. A per-cycle share of the ready names can in
principle take a warp past what the others' unmet floors leave free (V-04;
not seen in this workload), and a
chwidth or barrier uop must end its warp's take for the cycle (the model
reads its hold live). The second is one admission bit from decq (a
serializing uop ends the prefix). The first needs either the floor rule in
the fits, on registered counts, or OA's argument that the shares cannot
break V-04.

**What the go reads, made exact for slice 4 (`go_static`, on).** Three
places where the model still admitted on state the fits cannot hold:

- *Needs.* The fits read each head's admission bits from decq, fixed when
  the uop is decoded (RCU, MIU, copy, GPR write, predicate write, branch,
  serial). The model charged what rename finally does: a uop that turns
  into a no-op at rename (a barrier, width or format fault) took no RS
  entry or name, and a narrow GPR write that shares a row (the sectioned
  plan) took no name. Under `go_static` the allowances are charged with
  the decode-time needs; the RS, port and name checks stay exact.
- *Serializing uops.* A chwidth or barrier uop sets its warp's hold as it
  is renamed, so the model's later uops of the cycle saw it live; the
  barrier's only if it does not fault. Under `go_static` either ends the
  warp's take for the cycle, faulting or not (one serial admission bit).
  (The floors are already held by construction: OA's rev 138.)
- *The ROB, and the holds.* The fits for cycle t + 1 are formed in t, from
  the ROB's valid bits as t starts: the free run from the tail, less t's
  take, plus t's retirements where the run reaches the head. The model
  counted t + 1's own retirements and its deferred frees in t + 1's take
  (`ret_now` 1 and a live tail check), which no registered form can. The
  holds (inactive, fault stop, chwidth, barrier) are read as the cycle
  starts, the go's registered bit, so one that rises in the cycle stops
  the next cycle's take; the serial bit covers a hold the take itself
  sets. The live checks stay, as errors: none fires.

48 seeds (the audit's workload): 1,018 cycles to 1,030 (+1.2%), all of it
the ROB term; the needs and the serial bit cost nothing. The S1 kernels:
provswap one cycle slower (2,332 to 2,333), the other 23 unchanged.

### The composed RTL's timing (OI-45)

ooe_rs and ooe_wake take ooe_sched's grant register an edge after
ooe_sched forms it, so they decide model cycle P's confirmations,
replays and frees while ooe_sched is at P + 1 (OA's option (1): ooe_sched
evaluates this cycle's confirmations and replays itself). The assembled
check (`test/ooe/ooe_trio.sv`, `trio_tb`) wires the three modules as the
design does, drives only their outer ports from the model, and holds
ooe_sched's ready, request and grant registers, ooe_rs's valid bits and
rows and ooe_wake's issued bits and lead lines to the model. The model
matches it under three knobs, which apply only to the sectioned select
(the unsectioned one issues a copy with its load, past the request
register, so has no RTL to mirror):

| Knob | What ooe_sched sees, as the RTL composes it |
|---|---|
| `req_rows_late` | The request term: ooe_rs's valid bits, rows and prod bits two cycles back, ooe_wake's issued, final and held-miss bits a cycle nearer (its miss pulse nearer still), issued with the grant register less the replays it derives from them; a rewritten row requests on its last occupant's state. The enable takes ooe_sched's registered stop lead, formed the same way. |
| `miss_lead` | The ready register sees an L1 load's miss two cycles ahead: ooe_wake's lead line drops when no completion hint (OA-23, `Core::hint`) has come by the miss's lead. A hint after it is the miss's own completion. |
| `ready_rep_late` | The ready register sees a source's replay two cycles late, reading the timer the replay withdrew until then. |

With `copy_conf_late`, `req_alloc_lead` and `rs_same_edge` 0, `trio_tb`
matches exactly at 25 seeds (36 compared cores). At 100 seeds (140 cores)
grants and the request register are exact, and 2 ready-register bits
differ, each in the cycle after a replayed source re-issues: the RTL's
register holds its stale ready until one of its enables comes, where the
model captures on its own edge. Neither changes a grant.

The cost, `ooe-test --audit` with `AUDIT_SEEDS=192`, on the sectioned
slice-4 go (1,107 cycles): each knob alone within +0.19%, all together
−0.04%.

## Events and counters

The model emits the schema's arbitration-sensitive events: `EV_DISPATCH` at
ROB allocation, `EV_ISSUE` (warp, issue slot, RS entry), `EV_WAKEUP` (warp,
dependant, producer) per satisfied cell, and `EV_RETIRE`. It also emits the
twenty structural events below as `EV_OOE_*`, ids 13 to 32, which TI
assigned from this list (OI-7; `456b3e9`). The core raises each as an
`OoeEv`, listed in id order, and the adapter maps it to its id. The uid is
the uop the event concerns, or 0 for a decode-queue refusal, which has no
uop yet. Each is also a named counter or histogram in the `CCV_OOE_STATS`
dump: `stall.*`, `hold.*`, `cancel.*`, `squash.*`, `ready_not_selected`,
`memop.held_unconfirmed`, `issue_per_cycle`, `retire_per_cycle`,
`cancel_depth` and `done_after_issue.lat*`.

### The structural events (OI-7)

The list TI assigned ids from, in id order. Each row is one event of the design doc's
Events table: when it fires, its `a`, `b` and `c` payload, and the model
counter or hook that marks the same point today. Every one is
arbitration-sensitive (Q-1): a stall or hold an OOE arbiter decides, never a
channel transfer (Q-2). Rows marked *per cycle* fire every cycle the
condition holds, so their count is a duration.

| Event | Fires when | a | b | c | Model today |
|---|---|---|---|---|---|
| GPR free list empty | rename blocks on a GPR with the free list empty; per cycle | warp_id | owned GPRs | free GPRs | `stall.gpr_empty` |
| Rename floor or ceiling hit | rename blocks on another slot's floor, or this warp's ceiling; per cycle | warp_id | 0 floor, 1 ceiling | 0 GPR, 1 predicate | `stall.gpr_floor`, `stall.gpr_ceiling`, `stall.pred_floor_ceiling` |
| Predicate free list empty | rename blocks on a predicate with the list empty; per cycle | warp_id | owned predicates | 0 | `stall.pred_empty` |
| ROB full | the warp's ROB has no entry at rename; per cycle | warp_id | ROB count | 0 | `stall.rob_full` |
| ROB slot held | the next ROB slot is held by a squashed op still in flight (decision 6); per cycle | warp_id | held rob_tag | 0 | `stall.rob_slot_held` |
| RS full | a class has no free entry at rename; per cycle | warp_id | 0 RCU, 1 MIU | free entries in the class | `stall.rs_full.rcu`, `stall.rs_full.miu` |
| RS per-warp cap hit | the warp holds its cap at rename; per cycle | warp_id | RS entries held | cap | `stall.rs_warp_cap` |
| Decode queue full | DEC is held: a uop stays in the channel with the queue full; per cycle | warp_id of the oldest held uop | queue occupancy | 0 | `stall.decq_full` |
| Decode queue per-warp max | a uop stays in the channel with its warp at its maximum; per cycle | warp_id | that warp's entries | maximum | `stall.decq_warp_max` |
| `chwidth` serialisation | rename held behind an in-flight `chwidth` change; per cycle | warp_id | holding rob_tag | 0 | `hold.chwidth` |
| Barrier hold | rename held on a barrier wait; per cycle | warp_id | barrier_id | 0 | `hold.barrier` |
| Redirect busy | a mispredict or epoch notice waits for the rate-1 redirect; per cycle | warp_id waiting | redirects queued | 0 | `stall.redirect_busy` |
| Memop held, would have issued | a memop is ready but for an unconfirmed source while an MIU slot goes unused; per cycle | warp_id | RS entry | 0 | `memop.held_unconfirmed` |
| Memop hold cycles | a memop issues; once per issue | warp_id | rob_tag | cycles from all operands woken to issue | histogram `memop_hold_cycles` |
| Deferred free | a squash leaves an entry holding its registers for an op in flight | warp_id | rob_tag | 0 | hook `deferred_free`, `squash.deferred` |
| Ready but not selected | an entry is ready and not issued; per cycle, per entry | warp_id | RS entry | 0 | `ready_not_selected` |
| Cancel and replay | a withdrawn wake returns an issued entry to Waiting | warp_id | RS entry | depth from the missed load | hook `cancel`, `cancel.replay`, histogram `cancel_depth` |
| Demotion trigger | a trigger crosses its threshold at the ROB head; once per head | warp_id | 0 MLC miss, 1 barrier, 2 fallback | cycles the head has stalled | `demote_trigger.*` |
| Cross-group squash | a mispredict squashes entries of other PC groups; once per squash | warp_id | entries of other groups | branch rob_tag | `squash.cross_group` |
| Masked-load copy op | a masked load issues its copy-only op | warp_id | rob_tag | issue slot | hook `copy` |

Two in the doc's table are not OOE's: the branch-checkpoint stall is FET's
(its `ckpt_full`), and select grant is `EV_ISSUE`. `EV_OOE_BARRIER_HOLD`
carries the barrier uop's immediate as its `barrier_id` until A-75 names the
field. Not yet in the model: the
"would have issued" event's record, at retire, of whether those sources
later confirmed without a cancel. It needs a field per ROB entry and is
added with the event.

## How it is checked

- **On the kernels** ([`coverage.md`](coverage.md)). Every S1 kernel matches
  ccv-sim on both hosts, and every negative control that lives in OOE still
  fails where it should: `corrupt-ckpt`, `stale-free`, `drop-negate`,
  `skip-copy`, `free-new` and `corrupt-disp`.
- **Invariants, every cycle** (`Core::checkInvariants`), each reported once
  as a check failure:
  - V-01 (the GPR partition, exactly);
  - V-02 (the predicate partition, by count);
  - V-04 (ceilings, and floors covered);
  - V-07 (live checkpoints equal unresolved branches);
  - V-10 (the matrix is acyclic, same-warp and older-only);
  - V-14 (the per-warp RS cap);
  - V-15 (no issued entry rests on a withdrawn wake);
  - V-29 (no zero register is allocated, freed or written);
  - V-58 (a complete ROB entry holds no RS entry).
- **At the point of action:**
  - V-03, V-05, V-17, V-30, V-44 and V-49;
  - V-35 (above);
  - V-43 (a second completion for a tag).
- **Unit tests** (`sim/ooe/run-tests.sh`). An environment stands in for FET,
  DEC, RCU and MIU under their contracts, and checks every issue against a
  dataflow model of when each register becomes readable. It also catches any
  late write into a reallocated register, and checks that retirement equals
  the correct path exactly. The tests cover:
  - exact wake times: bypass, cross-lane, RCU-to-lane, memop-from-lane, and
    every pair of a bypass-group configuration;
  - L1 hit and miss, with transitive replay of a grandchild;
  - the masked load's copy;
  - a squash with a deferred free;
  - floors and ceilings across two slots;
  - demotion: notice, map, drained, free and restore;
  - kill: ack after the notice and after every completion;
  - a fault at retirement;
  - a barrier and a `chwidth` serialisation;
  - F-BARRIER (IS-16, ISA v1.9 O-59): a barrier whose ID is at or above its
    CTA's count, which the launch carries (`barrier_count`) and the core
    keeps per warp across a park, faults at dispatch with cause 9. It
    completes as a no-op, holds nothing and never reaches SYU. One below
    the count waits as before. Control `no-bar-fault` drops the check. The
    count is the slot's, taken at launch and at restore-allocate, since a
    restored warp may land in another slot (OA's response IS-16);
  - fault causes as the ISA fixes them per stage (IS's response IS-16): a
    fault DEC found arrives as the uop's cause (1 F-FETCH, 2 F-ILLEGAL;
    TI's 75b6a19) and is the ROB entry's, RCU's done carries none (its
    exec-fault path is gone), MIU's completion carries its own cause
    (one without is an error, ISA v1.9 section 12.6), and F-BARRIER (9) is
    OOE's at dispatch. F-WIDTH (3) is too: each slot holds the committed
    width of every architectural GPR (OA's response OI-57), written when a
    chwidth retires and 32 at launch and restore-allocate, and a memop
    whose data register (a load's destination, a store's highest read
    source) is at 4 bits faults as a no-op. Control `no-width-fault` drops
    the check. F-FORMAT (4) reads DEC's fmt_rsv and fmt_opnd (TI's
    57048d7): it faults where fmt_rsv's bit for the committed width of
    fmt_opnd's register is set. Control `no-format-fault` drops it.
    Issue still sends one committed chwidth per slot, the model's older
    simplification;
  - V-74: one fault-address register per warp keeps the oldest faulting
    memop's address and ROB index, written by a faulting completion only if
    older, cleared by a squash that takes it, and read for the fault record
    at the head. Two faulting loads, completing in either order, report the
    older's address. Control `fa-youngest` lets every completion write it;
  - V-36 as an input assumption: a uop with an ordering that is not a
    fence (mem_op 0xE) is an error;
  - the fixed-window predicate mode;
  - sectioned lanes:
    - four 8-bit warps co-issue, two 16-bit, one 32-bit;
    - FP widens to a pair, SFU to the whole lane;
    - placement by source and merge over home;
    - narrow loads on their own MIU pipes;
    - V-61's copy before its load;
    - OA-13 on and off;
  - 25 random seeds × eight mode combinations, up to four warps, with
    wrong-path fetch, mispredicts and L1 misses. Modes 4-7 are sectioned,
    with narrow registers, each placement rule and OA-13.

  Seven injected bugs must each fail the harness:
  - freeing the new mapping;
  - a cancel that stops after one hop;
  - a wake one cycle early;
  - a floorplan whose load data lands after its completion, with the core
    not told;
  - a bypass faster than the table the environment holds the core to;
  - a ROB entry that completes before its RS entries free, under an RCU
    faster than its contract (V-58);
  - a footprint narrower than its operands, so two lane ops share a
    section in one cycle.

## Sweeps

`sim/ooe/sweep.sh`, run 2026-10-19 at this commit's defaults (refreshed
for AR-19; the 2026-10-04 figures were stale).

**S1 kernels, cycles.** One warp, short, and DRAM-bound, so they show
latency, not structure size: no RS, ROB, free-list, decode-queue or
redirect stall occurs in any of them (AR-19). The model beats the in-order
stub wherever there is independent work. Of the structures, only a
quarter-size MIU class (rs_miu=2) moves one (vadd, 222 to 237); rename
width and the latencies move them by a cycle or two, loop by up to 200.
None of rename's credit settings moves any. brs is the one kernel the
stub wins (88 against 92), because the window runs out of branch
checkpoints first (AR-20).

| config | vadd | sel | srd | pguard | merge | mload | unal | gather | loop | brs |
|---|---|---|---|---|---|---|---|---|---|---|
| S1 stub (in order) | 291 | 125 | 115 | 136 | 79 | 111 | 236 | 2334 | 3142 | 88 |
| model, S1 modes | 222 | 117 | 110 | 125 | 66 | 99 | 222 | 2302 | 2736 | 92 |
| model, rs_miu=2 | 237 | 117 | 110 | 125 | 66 | 99 | 222 | 2311 | 2736 | 92 |
| model, rename_width=1 | 222 | 118 | 111 | 126 | 67 | 100 | 224 | 2303 | 2737 | 93 |
| model, lat_lane=9 | 224 | 121 | 112 | 131 | 68 | 101 | 226 | 2306 | 2936 | 94 |

**Synthetic, four warps, the design's own modes** (bypass and L1 speculation
on, 20% of loads missing by up to 25 cycles past the L1 contract). The core
alone, six seeds, cycles relative to the defaults; six seeds are noisy at
1 to 2%, so a figure that close to 1.00 is not a finding:

| knob | values → relative cycles |
|---|---|
| `rs_rcu` | 6 → 2.10, 10 → 1.50, 15 → 1.18, 20 → 1.08, **30 → 1.00**, 45 → 0.98 |
| `rs_miu` | 3 → 1.91, 5 → 1.40, 8 → 1.16, **15 → 1.00**, 24 → 0.98 |
| `rs_warp_cap` | 6 → 2.01, 10 → 1.32, 15 → 1.08, **none → 1.00** |
| `rob_depth` | 8 → 2.58, 12 → 1.83, 16 → 1.46, 24 → 1.13, **32 → 1.00** |
| `decq` | 4 → 1.26, 6 → 1.10, 8 → 1.04, **12 → 1.00**, 18 → 0.94 |
| `rename_width` | 1 → 1.62, 2 → 1.12, 3 → 0.99, **4 → 1.00** |
| `retire_per_rob` | 1 → 1.00, **2 → 1.00**, 4 → 1.00 |
| `ren_credit`, 48 seeds | same edge → 0.993, all late → 1.007, **TI-19 at cap 4 → 1.000**, cap 2 → 1.004 |
| `ready_reg`, 48 seeds | off → 1.003, **on → 1.000** (7.9 stale grants a run, each replayed) |

What it says, provisionally (strategy §8: a metric is only as real as the
least-built block on its path, and here every neighbour is a stand-in):

- The RCU class knees between 20 and 30 entries, and the MIU class near 15,
  where decision 4 holds a missing load's entry until its fill. The doc's
  30 and 15 sit at the knee, which leaves the scheduler-ceiling estimate (still
  open) as the binding question.
- ROB depth is still climbing at 32 under 25-cycle misses. Q-35's 32 is not
  past the knee for miss-heavy code. Demotion is the doc's answer to long
  heads, and the corpus has to show which binds first.
- A per-warp RS cap costs throughput at any value below the class size here,
  because the synthetic warps never stall long. Its value comes from
  demotion-heavy runs, which need RAU.
- The decode queue still gains past 12 (18 → 0.94).
- One retire per ROB now costs nothing measurable here (2026-10-04 put it at
  about 6%); the synthetic warps rarely retire two in a cycle. The S1
  kernels gain a cycle or two from the second.

**OI-34: sectioned placement and OA-13** (`sim/ooe/run-tests.sh
--sweep-sections`, 2026-10-09; re-run at the defaults of 2026-10-19 for
IS-9, with select's section fallback, the default since OA's response
IS-9). Synthetic 32-iteration loops, each with its
loop control (an RCU index add, a 32-bit setp, a backward branch). Four
seeds, 10% of loads missing. Cycles, one warp and four (the full table
prints from the command). Under the decided default (home = slot index),
**the one-warp rows are 1.0x by design** (AR-16): one warp's narrow ops
share its home section, so the 2x and 4x rates are aggregate across
warps. A lone warp's narrow rate is PF-29.

| kernel | warps | slot | 0 | rotate from 0 | rotate from slot | slot + reg |
|---|---|---|---|---|---|---|
| alu8 (shared operand) | 1 | 342 | 342 | 342 | 342 | 339 |
| alu8 (shared operand) | 4 | **589** | 1232 | 1232 | 589 | 856 |
| alu16 (shared operand) | 4 | **823** | 1232 | 1232 | 823 | 1103 |
| alu32 (reference) | 1 / 4 | 342 / 1232 | | | | |
| alu8-self | 1 | 340 | 340 | 340 | 340 | **247** |
| alu8-self | 4 | 581 | 1232 | 1232 | 581 | **558** |
| vadd8 | 4 | 1034 | 1079 | 1061 | 1052 | 1036 (1010 with OA-13) |
| vadd16 | 4 | 1044 | 1079 | 1057 | 1052 | 1048 (4.0 sections/op) |
| red8 | 4 | 369 | 369 | 371 | 365 | 369 |
| cvt8 | 4 | 1246 | 1254 | 1244 | 1246 | 1246 |
| fp8-self (FP minimum 1) | 4 | 581 | 1232 | 1232 | 581 | 558 |
| fp32-self (reference) | 4 | 1232 | | | | |

- **Four warps, lane-bound:** home = slot index is 2.09x over home 0 at 8
  bits and 1.50x at 16. Home 0 is exactly alu32: no narrow gain at all.
- **The element-work rate (IS-9), counted at select:** lane ops that write
  a register, per cycle, and per cycle outside the cycles a setp (the loop
  control's one lane op, all four sections) holds the lanes. alu32: 0.86
  and 0.96. alu8: 1.59 and 1.97, **2.05x**. alu16: 1.29 and 1.53,
  **1.59x**. So the rate, not only the kernel, is short of obligation 4's
  4x and 2x; the loop control is one full-footprint op an iteration, not
  three (the index add and the branch take R). At 8 bits the lane
  section-cycles are 40% narrow, 19% setp and 41% idle, and all four
  sections carry a narrow op in 8% of cycles. The first cause measured was
  select's single pass (`lost resource`): a setp oldest in three sections
  and beaten in the fourth issued nothing, and the narrow ops it beat in
  the three didn't issue either. A second pass over the sections the first
  left idle gave alu8 589 cycles (2.4x) and alu16 710 (1.90x). OA's
  parallel fallback pick (`pick_fallback`; OA's response IS-9) gets the
  same without a second pass: a section whose winner does not issue
  grants its oldest single-section requester (1, the default), and with 2
  a half whose sections both fall through may grant its oldest
  half-footprint requester. Section-only gives alu8 589 (2.30 element ops
  a cycle outside setps, **2.40x**) and leaves alu16 at 823 (**1.59x**);
  the half pick takes alu16 to 710 (1.90x) but measures 26.8 NGD in
  ooe_select, past its stage (section-only 24.3, none 19.5), so it is
  PF-38. DA's response OA-19 holds the first build to the measured rate;
  PF-29 and PF-31 (AR's warp-uniform register file, with loop control on
  R) are the levers past it. Rename or issue at 8 wide, or a
  128-entry RCU RS, makes neither faster. Both columns print.
- **OA-14's rotation equals its starting rule.** From 0, every warp rotates
  in lockstep and it equals home 0. From the slot index, it equals home =
  slot. It never moves a loop-carried value, which follows its own
  source, so it gives a lone warp nothing on any kernel. In red8 it widens
  the accumulator's op to 1.75 sections (the accumulator stays put while
  the load moves), at no cycle cost here.
- **A lone warp co-issues only if its independent registers sit apart and
  share no narrow operand.** `place=4` (slot + architectural destination)
  does this: alu8-self runs 1.38x faster until the ROB binds. The same rule
  costs where the code mixes registers. vadd16's a and b land in different
  pairs, so its add takes all 4 sections. A shared narrow operand (alu8's
  R12) puts its section in every op's footprint, which serialises a lone
  warp under any rule and slows four warps by 1.55x under slot + reg.
- **vadd, red and cvt are ROB-bound here** (`stall.rob_full` is most of
  the cycles): placement moves them by 4% at most. Under OA-15 cvt8 is
  placement-blind.
- **Footprint against spread, per bypass group** (AR's response OI-34;
  both columns print). Spread is the union of the operands' own sections;
  footprint is that union widened to `foot_min`. Integer footprint equals
  spread in every run, so any integer width above 1 section is placement's.
  FP at 8 bits (fp8-self, E4M3 per IS-7) at the decided FP minimum of 1
  has footprint 1 and spread 1, and runs as int8 does: 581 cycles, 2.12x
  over fp32 (639 and 1.93x before the section fallback). At a minimum of 2 (AR's recommendation, overruled by DA's
  response IS-7) the footprint was 2 and the 2026-10-09 run took 838,
  1.47x. cvt8's FP ops write 32 bits, so
  their 4 sections come from their operands, under either minimum.
- **OA-13** changes nothing except vadd8 under slot + reg (6%). The loads
  of one iteration become ready together. Its case is gathers and pointer
  chasing, which needs the corpus.

## Requests to other agents

Every request, and every model decision awaiting OA's ratification, lives
in the OI tab of the [CCV cross-agent register](https://claude.ai/artifact/JApHYjaUESeq8tsGMGXMU5),
which is the one place they are tracked:

- Requests to TI: OI-1 to OI-9. OI-1 is review of the two gate edits.
- Decisions 4, 5, 6, 11 and the V-35 bound: OI-10 to OI-14. Decision 6
  was accepted by Daniel 2026-10-04 as the first pass.
- Decisions 1 to 3 and 7 to 9: OI-15.
- Bypass groups: OI-16.
- The RTL grill-me: OI-17.
- Process: OI-18 to OI-21.
