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

The S1 RAU, CRU and SYU stubs consume nothing OOE sends them, and no S1
kernel demotes, kills, restores, faults or waits at a barrier. So the
adapter turns a fault into a check failure, counts and drops status reports
(`s1.status_dropped`), and fails on anything else it would have to send there.
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
that OA-17 check, and does (at decq 4). On time it costs nothing: the
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
(`sel_rq`, `sel_gnt`, `sel_elig`), and ooe_sched's
(test/ooe/sched_tb.cpp) compares the request register bit for bit.

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
