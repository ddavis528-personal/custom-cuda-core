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
2. Timed wakes. A missed L1 slot cancels transitively. Copy-only ops land.
   Results confirm oldest first. Confirmed RS entries free. Squashed entries
   whose op has landed release.
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
- **Transitive cancel moves one hop a cycle** (`cancelHop`). A miss returns
  its direct dependants to Waiting at once, and each later cycle takes the
  next hop, deciding the whole hop before applying it, until nothing
  changes. V-59 makes that safe: every wake offset is at least 3, 2 plus
  the hop, so the cancel lands before the next hop's ready computation.
  `Config::check` refuses a shorter offset (unit test `v-59`). V-15 is
  checked only once a cancel has settled. The wavefront it has not reached
  is exactly what V-15 forbids at rest.

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
as OI-22). Allocation takes the first free register at or after a pointer,
which then moves past it, so a freed register comes back only once the
pointer wraps. A free sets its bit at the clock edge: a register freed in a
cycle is not allocated in that cycle. Any number of frees a cycle costs
nothing, so a squash's 32 or a kill's 16 need no drain. Rename's floor and
ceiling checks count only registers allocatable this cycle; V-01, V-02 and
V-04 count those freed this cycle too. On the S1 kernels, one warp freeing
in order, the order is the old FIFO's, so `--break free-new` still fails at
the same line (seq 382).

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

  The home position comes from `place` (OA-14; DA picks from the OI-34 sweep):
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
- **Loads passing loads** (OA-13, pending DA): with `loads_pass_loads`, a
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

`sim/ooe/sweep.sh`, run 2026-10-04 at this commit's defaults.

**S1 kernels, cycles.** One warp, short, and DRAM-bound, so they show
latency, not structure size. The model beats the in-order stub wherever there
is independent work, and no knob down to a quarter of its size moves them,
except rename width and the latencies themselves.

| config | vadd | sel | srd | pguard | merge | mload | unal | gather | loop | brs |
|---|---|---|---|---|---|---|---|---|---|---|
| S1 stub (in order) | 361 | 119 | 111 | 128 | 71 | 126 | 274 | 2364 | 2741 | 82 |
| model, S1 modes | 306 | 117 | 110 | 125 | 67 | 116 | 263 | 2345 | 2636 | 83 |
| model, rename_width=1 | 307 | 118 | 111 | 126 | 68 | 117 | 265 | 2347 | 2737 | 85 |
| model, lat_lane=9 | 308 | 123 | 114 | 133 | 74 | 120 | 267 | 2351 | 3036 | 88 |

**Synthetic, four warps, the design's own modes** (bypass and L1 speculation
on, 20% of loads missing by up to 25 cycles past the L1 contract). The core
alone, six seeds, cycles relative to the defaults:

| knob | values → relative cycles |
|---|---|
| `rs_rcu` | 6 → 2.06, 10 → 1.48, 15 → 1.20, 20 → 1.04, **30 → 1.00**, 45 → 0.99 |
| `rs_miu` | 3 → 1.80, 5 → 1.36, 8 → 1.11, **15 → 1.00**, 24 → 1.00 |
| `rs_warp_cap` | 6 → 1.86, 10 → 1.25, 15 → 1.04, **none → 1.00** |
| `rob_depth` | 8 → 2.45, 12 → 1.77, 16 → 1.47, 24 → 1.15, **32 → 1.00** |
| `decq` | 4 → 1.11, 6 → 1.06, 8 → 1.02, **12 → 1.00**, 18 → 0.95 |
| `rename_width` | 1 → 1.88, 2 → 1.20, 3 → 1.02, **4 → 1.00** |
| `retire_per_rob` | 1 → 1.06, **2 → 1.00**, 4 → 0.99 |

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
- Two retires per ROB is worth about 6% over one. Four buys nothing.

**OI-34: sectioned placement and OA-13** (`sim/ooe/run-tests.sh
--sweep-sections`, 2026-10-09). Synthetic 32-iteration loops, each with its
loop control (an RCU index add, a 32-bit setp, a backward branch). Four
seeds, 10% of loads missing. Cycles, one warp and four (the full table
prints from the command):

| kernel | warps | slot | 0 | rotate from 0 | rotate from slot | slot + reg |
|---|---|---|---|---|---|---|
| alu8 (shared operand) | 1 | 342 | 342 | 342 | 342 | 339 |
| alu8 (shared operand) | 4 | **616** | 1232 | 1232 | 616 | 953 |
| alu16 (shared operand) | 4 | **813** | 1232 | 1232 | 813 | 1113 |
| alu32 (reference) | 1 / 4 | 342 / 1232 | | | | |
| alu8-self | 1 | 340 | 340 | 340 | 340 | **247** |
| alu8-self | 4 | 605 | 1232 | 1232 | 605 | **570** |
| vadd8 | 4 | 1064 | 1067 | 1066 | 1053 | 1067 (996 with OA-13) |
| vadd16 | 4 | 1034 | 1067 | 1059 | 1073 | 1052 (4.0 sections/op) |
| red8 | 4 | 367 | 377 | 372 | 371 | 367 |
| cvt8 | 4 | 1246 | 1254 | 1252 | 1246 | 1246 |
| fp8-self (FP minimum 2) | 4 | 838 | 1232 | 1232 | 838 | 798 |
| fp32-self (reference) | 4 | 1232 | | | | |

- **Four warps, lane-bound:** home = slot index is 2.0x over home 0 at 8
  bits and 1.5x at 16. Home 0 is exactly alu32: no narrow gain at all.
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
  FP at 8 bits (fp8-self, E4M3 per IS-7) has footprint 2 and spread 1:
  the unit minimum, not placement. Four warps of fp8-self take 838 cycles
  at an FP minimum of 2 and 605 at a minimum of 1, the same as int8. That
  is 1.47x over fp32 rather than 2.04x. cvt8's FP ops write 32 bits, so
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
