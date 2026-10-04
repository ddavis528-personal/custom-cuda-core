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

## Decisions the design doc leaves open

Each of these is a model decision, the RTL follows it, and each is
arbitration policy for Q-4 where it chooses between requesters.

1. **Select order.** Bulk discards take memop slots first. Then the MIU class
   goes, then the RCU class, from the four issue slots of
   `ccv_ooe_rcu_issue`. Every memop also takes an issue slot, because RCU
   reads its address sources. Within a class, each warp in turn, starting from
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
    crossing + 1)` cycles after the completion (`cmpl_wake_delay`, derived
    from the wiring). That is 0 with no repeaters and 2 in
    `test/phys/links_split.json`, whose failure found it. `CCV_LAT_L1_WAKE`
    already makes this correction for a hit; the miss path needs the same.

## The arrival-cycle checker on `ccv_rcu_ooe_done` (V-35, repo Q-53)

A dependant issued at the contracted latency reaches RCU one issue crossing
later, and must read the result there. So RCU has written it by the cycle
before. Its done is sent with the write, so the done lands no later than:

```
issue + (CCV_LAT_HOP + issue stages) + LAT - 1 + (CCV_LAT_HOP + done stages)
```

LAT is `CCV_LAT_RCU` or `CCV_LAT_LANE` by latency class. That is 6 and 10
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
| `bypass` | off | RCU reads the PRF the cycle it takes an issue, after nothing written that cycle. A dependant woken at `CCV_LAT_LANE_BYP` reads stale data. | An RCU or LANE bypass |
| `l1_spec` | off | MIU completes every load as a miss at its own pace. A dependant woken at `CCV_LAT_L1_WAKE` issues on garbage, and the lanes refuse it before the cancel lands. | An MIU that completes an L1 hit at exactly `CCV_LAT_L1_CMPL` (A-46) |
| `rename_preds` | off | RCU reads predicate-logic sources, and `compareFinal` reads final predicates, at fixed `physPred` windows. | A-75's predicate-source fields, and a committed-predicate-map hook |
| `memop_rcu_done` | on | RCU sends a done for loads and stores, which the channel's doc does not mention. A memop completes only after both. | The top level settling whether memops get a done |

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

## Knobs without a parameter

The model reads every size and latency from `ccv_params.h`. These have no
parameter yet. Each defaults to "no limit" or to the nearest parameter, and
each is owed one before the RTL fixes a number:

| Knob | Default | The doc says |
|---|---|---|
| `rs_warp_cap` | the RS size (no cap) | to be set by sweep |
| `decq_warp_max` | `CCV_P_DECQ` (no cap) | "a per-warp maximum" |
| `demote_mlc_miss`, `demote_barrier` | `CCV_DEMOTION_THRESHOLD` | one CSR per trigger |
| `rename_width` | `CCV_ISSUE_WIDTH` | "4 uops per cycle" |

## Events and counters

The model emits the schema's arbitration-sensitive events: `EV_DISPATCH` at
ROB allocation, `EV_ISSUE` (warp, issue slot, RS entry), `EV_WAKEUP` (warp,
dependant, producer) per satisfied cell, and `EV_RETIRE`. The doc's Events
table has about twenty more, mostly structural stalls, which the schema does
not define. Until it does, each is a named counter or histogram in the
`CCV_OOE_STATS` dump: `stall.*`, `hold.*`, `cancel.*`, `squash.*`,
`ready_not_selected`, `memop.held_unconfirmed`, `issue_per_cycle`,
`retire_per_cycle`, `cancel_depth` and `done_after_issue.lat*`.

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
  - V-29 (no zero register is allocated, freed or written).
- **At the point of action:**
  - V-03, V-05, V-17, V-30, V-44 and V-49;
  - V-35 (above);
  - V-43 (a second completion for a tag).
- **Unit tests** (`sim/ooe/run-tests.sh`). An environment stands in for FET,
  DEC, RCU and MIU under their contracts, and checks every issue against a
  dataflow model of when each register becomes readable. It also catches any
  late write into a reallocated register, and checks that retirement equals
  the correct path exactly. The tests cover:
  - exact wake times: bypass, cross-lane, RCU-to-lane, memop-from-lane;
  - L1 hit and miss, with transitive replay of a grandchild;
  - the masked load's copy;
  - a squash with a deferred free;
  - floors and ceilings across two slots;
  - demotion: notice, map, drained, free and restore;
  - kill: ack after the notice and after every completion;
  - a fault at retirement;
  - a barrier and a `chwidth` serialisation;
  - the fixed-window predicate mode;
  - 25 random seeds × four mode combinations, up to four warps, with
    wrong-path fetch, mispredicts and L1 misses.

  Four injected bugs must each fail the harness: freeing the new mapping, a
  cancel that stops after one hop, a wake one cycle early, and a floorplan
  whose load data lands after its completion with the core not told.

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

## Requests to the top-level session

None of these is an interface change except where marked. They are what the
model needs from files the top-level session owns.

1. **Review two gate edits made on this branch** (one commit, so it can be
   redone). First, `Kernel::fail` prints every check failure, up to 10,000, not
   the first 12. With out-of-order issue, which instruction fails first is
   issue order. The greps for dirty-zero, copy-from-new and conflate-pred
   anchor on one instruction's line, and missed it although every count
   matched. Second, movi-in-lane's expectation: the lanes refuse movi48
   (64), and V-35 names its late done. Its readers then see stale data,
   which a latency-scheduled OOE cannot avoid once a contract is broken, so
   "nothing else fails" no longer holds by construction.
2. **Gate the unit tests**: one line in `tools/verify.sh` running
   `sim/ooe/run-tests.sh`.
3. **A committed-predicate-map hook** beside `Kernel::rat0`, for
   `compareFinal`. Together with A-75's predicate sources on the issue
   (interface), it lets `rename_preds` turn on.
4. **Say whether RCU sends a done for memops.** The channel doc says
   arithmetic, and the S1 RCU sends one for loads and stores.
5. **Stub fidelity, to reach the model's speculative paths on kernels**: an
   MIU that completes a hit at exactly `CCV_LAT_L1_CMPL`, and an RCU whose
   operand read sees a same-cycle write or bypass.
6. **Parameters** for the knobs above, and for decision 11's miss-wake
   delay, generated beside `CCV_LAT_L1_WAKE` from the same links; also
   **events** for the doc's Events table in `schema/events.json`.
7. **Consumers in the RAU, CRU and SYU stubs** for status, fault, drained,
   map and barrier, and the kill ports in the C++ machine, so demotion, kill,
   faults and barriers can run on kernels.
