# OOE Stage 4b: handoff to the OOE model session

The OOE C++ model is written in a session of its own; the top-level session
keeps the schema, parameters, generators, gate and every other block's stub.
This file is where the OOE session starts. It points at the sources of truth
rather than restating them, so it does not drift from them.

Stage 4b, per [`rtl-execution-strategy.md`](rtl-execution-strategy.md) §8: the
block's internals replace its stub; every kernel stays functionally correct
against ccv-sim; arbitration-sensitive events are emitted; sizing-sweep data is
collected. RTL (4c) comes later, after the 4a items still missing for OOE: the
reset line ([`reset-line-template.md`](reset-line-template.md)), per-stage NGD
budgets, and the scheduler's timing-ceiling estimate against 25 NGD per stage
(Q-7 is closed: NGD is normalized gate delays, the same budget at every
corner).

**Status (2026-10-04).** The model is in [`sim/ooe/`](../sim/ooe/) and is
what `makeOoe` builds; the stub stays selectable with `CCV_OOE_IMPL=stub`.
Every kernel and control passes on both hosts. What the model decides, what
it cannot use yet, its tests, the sweep and its requests to the top-level
session are in [`ooe-model.md`](ooe-model.md).

## Sources of truth

| What | Where |
|---|---|
| OOE's internal design: rename, the two-bit wakeup matrix, select, ROB, checkpoints, squash, demotion, kill, activation, parameters, events, the V-properties | *OOE microarchitecture — Stage 4 grill-me* (Claude doc): https://claude.ai/artifact/7tpEyGaCvfdvYYWUQJvJSU. A copy pinned to this repo: [`design-snapshots/ooe-microarchitecture.md`](design-snapshots/ooe-microarchitecture.md) |
| Why each interface is the way it is: Review rows A-25 to A-75 (closed), each with the OOE session's response and where it was applied; and the change set itself. Later rows are in the cross-agent register: https://claude.ai/artifact/JApHYjaUESeq8tsGMGXMU5 | *Interface spec changes — OOE session*, Review and Changes tabs: https://claude.ai/artifact/EcuSx6yXG4dCmkT2ky2Cb7. Copies: [`design-snapshots/interface-review.md`](design-snapshots/interface-review.md), [`design-snapshots/interface-changes.md`](design-snapshots/interface-changes.md) |
| Per-block specs, including OOE's neighbours | *CCV per-block architecture specs*: https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35 |
| Ports, fields, widths, slot attributes, channel contracts (each channel's `doc`) | [`schema/interfaces.json`](../schema/interfaces.json); readable per channel in [`payload-spec.md`](payload-spec.md) |
| Every size and latency | [`params/ccv_params.json`](../params/ccv_params.json), generated into `sim/generated/ccv_params.h` (`ccv::prov::k*`, `ccv::prelim::k*`). Never hard-code a number that has a parameter |
| Placeholder encodings the stubs agree on (`alloc_op`, `mem_op`, `sched_attr` codes, ...) | [`skeleton.md`](skeleton.md), "S1 wire conventions" |
| What is open, and who owns it | [`open-items.md`](open-items.md): Q-53 lists the checkers OOE's implementation owes |
| What the kernels reach, and what they cannot yet | [`coverage.md`](coverage.md) |

## Where the code goes

- `sim/skel/stub.h`: what every block shares. Channel and field access by
  name (`ch()`, `get`, `put`, `msgOf`), the `Stub` base (`has`, `take`,
  `can`, `send`, one `work()` per cycle), `emit` for events, and the S1 wire
  conventions.
- `sim/ooe/`: the model (`ooe_core.*`, the core; `ooe_block.cpp`, its ports,
  behind `makeOoeModel`), listed in `sim/skel/blocks.list`, which both hosts
  build from. Its unit tests (`ooe_test.cpp`, `run-tests.sh`) are gated by
  `tools/check-ooe-unit.sh`, which also holds the harness's controls by name.
- `sim/skel/ooe.cpp`: the in-order stub it replaced, still selectable with
  `CCV_OOE_IMPL=stub` for A/B runs.
- The model reaches the top-level branch by merge: OI names a commit in its
  register tab, and TI merges it and runs the whole gate (register OI-2).

## The swap boundary: rules the gate enforces

- **Ports only.** A block reads its own receivers and writes its own senders,
  and nothing else. `tools/check-sv-hosted.sh` runs every block inside the SV
  top, where only the Verilog nets connect them. A model that shares state
  with another block behind the ports diverges there and fails.
- **The oracle is for checks, never decisions.** `rec(tid)` finds ccv-sim's
  record so a value can be compared. Nothing the model *does* may depend on
  it.
- **Testbench hooks the model must keep** (`Kernel`, in `kernel.h`):
  - retire bookkeeping: `retired`, `retire_order`, and `exited` on the exit;
  - `rat0`, warp 0's final GPR map, which the final-state compare reads
    through;
  - `fail()` for check failures;
  - `hit()` / `peak()` for the coverage bins (`redirect`, `merge`, `copy`,
    `zero_read`, `reg_reuse`, `epoch_drop`). Each kernel is held to its bins
    in `tools/check-kernel.sh`, so a model that stops counting fails the gate;
  - `brk` for negative controls.
- **Negative controls that live in the OOE stub**, and so must keep working
  in the model:
  - `corrupt-ckpt`, `stale-free` and `drop-negate`, which force a mispredict
    through `pred_neg`;
  - `skip-copy`;
  - `free-new`;
  - `corrupt-disp`.

  Each is described in `kernel.h` and checked by name in
  `tools/check-kernel.sh` and `tools/check-sv-hosted.sh`. A control that
  stops failing is a gate failure.

## OOE's ports

| Channel | Dir | Rate | Contract notes |
|---|---|---|---|
| `ccv_dec_ooe_uop` | in | 6 | ordered per `warp_id`; `sched_attr` (A-66), `group_mask` (A-69), `fetch_epoch` (A-70); `mem_op`/`space`/`ordering` passed to MIU unexamined (A-68) |
| `ccv_ooe_rcu_issue` | out | 4 | fixed latency; zero registers (A-64); merge (A-33); `CCV_OP_PRF_COPY` beside a masked load (A-38) |
| `ccv_rcu_ooe_done` | in | 4 | fixed latency, so OOE never stalls it; branch resolution rides here |
| `ccv_ooe_miu_memop` | out | 4 | bulk discard is `mem_op` 0xF with `discard_tail` (A-41, A-53) |
| `ccv_miu_ooe_cmpl` | in | 4 | fixed latency; an L1 hit completes at exactly `CCV_LAT_L1_CMPL` (A-47, A-61) |
| `ccv_ooe_miu_retire` | out | 4 | commit or discard for stores |
| `ccv_ooe_fet_redirect` | out | 1 | fixed latency; latency-matched with `ckpt_free` (A-58); `epoch_only` notices for demotion and kill (A-74) |
| `ccv_ooe_fet_ckpt_free` | out | 1 | fixed latency; bit `tier1_id * CCV_P_BR_CKPTS + checkpoint` (A-56, A-60) |
| `ccv_rau_ooe_alloc` | in | 1 | `alloc_op`: free, launch, restore-allocate, restore-activate (A-64); `tier1_id` (A-65) |
| `ccv_rau_ooe_demote`, `ccv_ooe_rau_drained` | in / out | 1 | drained only after the demotion's epoch notice lands (A-74) |
| `ccv_ooe_rau_status`, `ccv_ooe_cru_fault` | out | 1 | progress, stall and fault reporting |
| `ccv_ooe_rcu_map` | out | 1 | the RAT map for migration (restore direction 1) |
| `ccv_ooe_syu_bar`, `ccv_syu_ooe_rel` | out / in | 1 | barriers |
| `kill_*` common ports | in / out | | `kill_ack` only after the kill's epoch notice lands (A-74) |

Latencies the scheduler wakes on are all generated: `CCV_LAT_RCU`,
`CCV_LAT_LANE`, `CCV_LAT_LANE_BYP`, `CCV_LAT_L1_WAKE`, `CCV_LAT_L1_CMPL` and
`CCV_LAT_HOP`. Each parameter's doc gives its derivation from the links.

## Still open at the interface

- **A-75: what OOE needs from DEC so it never decodes `opcode`.** The stub
  still looks the opcode up in the skeleton's table for five things:
  - which source fields are real reads;
  - whether the predicate is a guard (an enable, so the write merges) or
    data (`sel`);
  - predicate logic's two predicate sources, carried as qualifiers in `imm`
    and needing renaming;
  - exit;
  - which identity `srd` substitutes.

  Now TI-1 in the register (Needs OA, DA); until it is settled, the model
  may use the same table lookup, marked as temporary.
- A-71 (an unaligned lane word), now TI-2, is deferred to the ISA track and
  does not touch OOE.

## What the environment can and cannot exercise yet

Eleven kernels in `test/kernels/` run on both hosts, with ccv-sim's oracle and
coverage counts. They exercise:
- rename, merge, the zero registers and the copy-only op;
- mispredicts with checkpoint restore and free;
- checkpoint pressure;
- the free list wrapping;
- dropping a stale-epoch uop;
- L1 hits at the contract, and the model's `l1_spec` on every kernel
  (`CCV_OOE_CONFIG=l1_spec=1`, held in `tools/check-kernel.sh`; OI-5). The
  kernels also pass with `bypass=1`, but only because the S1 lanes answer
  faster than `CCV_LAT_LANE`: a lane-local bypass is not yet modelled, so
  that pass does not prove one.

They cannot yet exercise the following. Each needs stub work, which belongs
to the top-level session, in this order:
1. **Wrong-path execution and squash**: RAT recovery, free-list return, and
   bulk discard. FET fetches no wrong path.
2. **Several warps**: RAU launches one.
3. **Divergence**: a partial `group_mask`.
4. **Demotion, kill and restore**: neither the RAU nor PCA stub models them,
   and restore is also blocked on Q-39.
5. **Most of the compiler corpus**: DEC's table lacks several ops.

## Running it

```
./tools/setup-toolchain.sh          # a fresh container needs this once
./tools/gen-oracle.sh               # oracles from the pinned compiler snapshot
./tools/check-skel.sh               # builds build/skel/ccv-skel (S0 suite)
./tools/check-kernel.sh             # every kernel, its bins and its controls
./tools/check-ooe-unit.sh           # the OOE model's unit tests and their controls
./tools/check-sv-hosted.sh          # the same blocks inside the SV top
./tools/verify.sh                   # the whole gate (~25 min); must be green to push
build/skel/ccv-skel --kernel build/oracle/loop/oracle.jsonl [--break MODE] [--trace t.ccvtrace]
python3 tools/trace2perfetto.py t.ccvtrace -o t.json   # open in ui.perfetto.dev
```

`tools/verify.sh` also fails when `docs/walkthrough.md` is stale after a
change. Regenerate it with `python3 tools/gen-walkthrough.py` and commit it.

## Working beside the top-level session

- **The OOE session owns** its model files and `sim/skel/ooe.cpp`. **The
  top-level session owns** `schema/`, `params/`, the generators in `tools/`,
  `rtl/top/`, and every other block's stub.
- **All cross-agent traffic goes through the register**, *CCV cross-agent
  register*: https://claude.ai/artifact/JApHYjaUESeq8tsGMGXMU5. Its
  Conventions tab is the process. The OOE model session is **OI** and writes
  only the OI tab; the top-level session is **TI**, the OOE architect **OA**.
  At session start, search every tab for `OI` in a Needs column.
- **An interface change is a row in OI's tab with `TI` in Needs**, for the
  top-level session to apply to schema, parameters and stubs. It is never a
  direct edit of the schema. The Review tab (A-25 to A-75) is closed, and its
  open rows moved to the register.
- **The design snapshots** in [`design-snapshots/`](design-snapshots/) pin the
  docs this repo was built against. Change the microarchitecture doc and
  refresh its snapshot in the same commit as the code that follows it
  ([`design-snapshots/README.md`](design-snapshots/README.md)).
- **Merge the top-level branch in often.** A schema change regenerates
  headers the model compiles against.
