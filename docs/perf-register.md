# Performance-feature register

A first-pass choice that is simpler, and a known alternative that costs more
and is expected to perform better. Every entry is deferred, not rejected. It
names the measurement that says when it is worth building, so the decision
can come from data rather than memory.

IDs run PF-1 upward and are never reused, as in
[`open-items.md`](open-items.md). An entry moves to **adopted** with the
commit that builds it, or to **dropped** with its reason. It is never
deleted. Any block may add entries. Each counter named below is one the
block's model already reports (for OOE, `CCV_OOE_STATS`; see
[`ooe-model.md`](ooe-model.md)), or the entry says it is still to be added.

Every entry today is OOE's, from a scan of the Stage 4 decisions, the
model's decisions 1 to 11 ([`ooe-model.md`](ooe-model.md)) and the
interface review rows. Each entry gives the current choice, the
alternative, what the alternative costs, and the signal that would justify
it.

## Summary

| ID | Feature | Area | Status |
|---|---|---|---|
| PF-1 | Kill a squashed op's write-back in flight | recovery | deferred |
| PF-2 | Cancel squashed memops at MIU | recovery | deferred |
| PF-3 | Free a load's RS entry at issue | scheduler | deferred |
| PF-4 | Speculative memop issue on unconfirmed addresses | scheduler | deferred (Q22) |
| PF-5 | Split store address from store data | scheduler, MIU | deferred |
| PF-6 | Memory disambiguation: loads pass older stores | scheduler, MIU | deferred |
| PF-7 | Store-to-load forwarding | MIU | deferred |
| PF-8 | Early L1 hit/miss indication | MIU, scheduler | deferred (doc: performance item) |
| PF-9 | L1 hit/miss predictor gating speculative wake | scheduler | deferred |
| PF-10 | A second speculative wake at an MLC-hit contract | MIU, scheduler | deferred |
| PF-11 | Completion sent in time with the data, not before it | MIU | deferred |
| PF-12 | More bypass paths between groups | LANE, RCU, scheduler | deferred |
| PF-13 | Non-contiguous squash (stream tags) | recovery | deferred (doc: rejected for now) |
| PF-14 | Younger non-memory ops pass a barrier wait | rename | deferred (doc) |
| PF-15 | `chwidth` without serialising rename | rename | deferred |
| PF-16 | More than one redirect a cycle | recovery | deferred (A-6) |
| PF-17 | More branch checkpoints per warp | recovery, FET | deferred |
| PF-18 | A masked load merged without a copy-only op | issue, RCU, MIU | deferred (A-38) |
| PF-19 | Criticality-aware select | scheduler | deferred |
| PF-20 | Rename in the cycle a uop arrives | front end | deferred |
| PF-21 | Dynamic per-warp RS and decode-queue limits | scheduler | deferred |
| PF-22 | Retire wider than two per ROB | retire | deferred (sweep: not worth it now) |
| PF-23 | Demotion abandons outstanding loads | demotion | deferred |
| PF-24 | Divergent branch prediction | FET | deferred (doc) |
| PF-25 | Predicate renaming in place of the fixed-window holds | rename | adopted (OI-3) |
| PF-26 | Co-issue lane ops whose lane masks are disjoint | scheduler, RCU | deferred |
| PF-27 | Fold section alignment into the producing op | rename, RCU, bypass | deferred (DA, AR-13) |

## Entries

### PF-1 Kill a squashed op's write-back in flight

- **Now:** a squashed op already issued to RCU keeps its destination
  registers and ROB slot until it lands: its done for an RCU op, its landing
  cycle for a copy-only op (model decision 6). Rename stalls if it reaches
  the held slot (`stall.rob_slot_held`). Up to `CCV_LAT_LANE` plus the done
  link, about 10 cycles at no repeaters.
- **Alternative:** a squash vector from OOE to RCU and the lanes that
  suppresses write-back and done for squashed `rob_tag`s in flight. The
  registers and slot are free in the squash cycle.
- **Cost:** a new interface, `rob_tag` matching in RCU's write-back stage
  and the lanes' result path, and a contract that a killed op produces no
  done.
- **Signal:** `squash.deferred` per mispredict, and `stall.rob_slot_held`.
  Worth it if held slots stall rename after a measurable share of
  mispredicts, or held registers press the floor (`stall.gpr_floor`).

### PF-2 Cancel squashed memops at MIU

- **Now:** a squashed load or store already at MIU holds its registers and
  `rob_tag` until MIU completes it (A-41, V-22). Recovery then depends on
  memory latency.
- **Alternative:** a cancel to MIU. A pending miss is dropped, or its
  completion answered at once without data.
- **Cost:** MIU must recall work in flight (DCU, MLC, a page walk). It must
  still give exactly one completion per accepted memop (V-43).
- **Signal:** `squash.deferred` on memops and the cycles they hold (to add:
  a histogram). The same cost reappears in demotion and kill drains
  (PF-23).

### PF-3 Free a load's RS entry at issue

- **Now:** an RS entry with a destination stays until its result confirms,
  because the matrix column is how dependants wake (decision 4). A missing
  load holds an MIU-class entry until its fill.
- **Alternative:** free it at issue, and wake its dependants from a small
  load-completion table that broadcasts the destination, or from per-register
  ready bits set at the fill.
- **Cost:** a second wake path into the ready logic, and a tag compare for
  late wakes. That is the CAM the matrix was chosen to avoid (Q31), here
  only for loads.
- **Signal:** `stall.rs_full.miu` under misses. In the synthetic sweep, MIU
  RS 15 → 8 costs 11%.

### PF-4 Speculative memop issue on unconfirmed addresses

- **Now:** a memop issues only when its sources are confirmed (Q22, V-17).
- **Alternative:** issue on woken sources, and recall from MIU on a cancel.
- **Cost:** a recall path into MIU for TLB walks, misses and faults on a
  garbage address.
- **Signal:** `memop.held_unconfirmed`, the counterfactual the doc defined.
  The doc also wants it recorded with whether the sources later confirmed
  without a cancel (to add).

### PF-5 Split store address from store data

- **Now:** a store is one memop entry. It waits for its data sources as
  well as its address sources, and holds every younger memop of its warp
  behind it (decision 2).
- **Alternative:** separate address and data issue (STA/STD). The address
  goes as soon as it confirms; the data joins at MIU before commit.
- **Cost:** two RS entries per store, a data channel or data-only message
  into MIU, and pairing in MIU.
- **Signal:** cycles a younger load waits behind a store whose address
  confirmed and data did not (to add).

### PF-6 Memory disambiguation: loads pass older stores

- **Now:** memops issue in program order per warp, load behind load as well
  as load behind store. MIU orders memory, and OOE does no disambiguation
  (decision 2). OA ratified this as a conservative first-build choice and
  asked for it here (OA's response to OI-15).
- **Alternative:** a younger load issues past older loads freely, and past
  an older store whose address is unknown with a violation check and
  replay, or a store-set style predictor.
- **Cost:** an address compare against older stores, an ordering-violation
  replay or squash, and a predictor.
- **Signal:** cycles ready loads wait on older unissued memops (to add:
  `hold.memop_order`).

### PF-7 Store-to-load forwarding

- **Now:** the S1 MIU refuses a load overlapping an uncommitted store, and
  nothing forwards.
- **Alternative:** forward committed-but-unwritten and retired store data to
  younger loads.
- **Cost:** MIU's store buffer becomes searchable.
- **Signal:** a corpus kernel with store-then-load to one line. None today.
  MIU's session owns it.

### PF-8 Early L1 hit/miss indication

- **Now:** the absence of a hit completion at `CCV_LAT_L1_CMPL` is the miss
  (A-46, A-54). The cancel shadow runs from `CCV_LAT_L1_WAKE` to
  `CCV_LAT_L1_CMPL`.
- **Alternative:** an early miss signal from DCU's tag compare, sent before
  the data. Fewer dependants issue in the shadow.
- **Cost:** a channel or field from MIU, and its own latency contract.
- **Signal:** `cancel.replay` per miss and `cancel_depth`. The doc named it
  as a performance item for the MIU session.

### PF-9 L1 hit/miss predictor gating speculative wake

- **Now:** every L1-contracted global load wakes its dependants
  speculatively.
- **Alternative:** a per-PC or per-warp predictor. A load predicted to miss
  wakes on its completion and spends no issue slots on replays.
- **Cost:** a small table indexed at rename, and a mispredicted hit becomes
  a missed early wake.
- **Signal:** `cancel.replay` against issue utilisation (`issue_per_cycle`).
  Worth it when replays take a measurable share of issue slots.

### PF-10 A second speculative wake at an MLC-hit contract

- **Now:** past L1, nothing is contracted, and dependants wake on the
  completion (A-46).
- **Alternative:** contract an MLC hit's latency too. A missed L1 load wakes
  its dependants again at the MLC-hit time, cancelling on an MLC miss.
- **Cost:** a second contract for MIU and MLC, and a second cancel shadow.
- **Signal:** the distribution of past-L1 completion latencies (to add) and
  `load.past_l1`. Worth it if most past-L1 loads hit the MLC at a tight
  latency.

### PF-11 Completion sent in time with the data, not before it

- **Now:** OOE wakes a past-L1 load's dependants `cmpl_wake_delay` cycles
  after its completion lands. That delay is how much later the data reaches
  RCU than the completion reaches OOE (decision 11).
- **Alternative:** MIU sends the completion with that lead already
  subtracted, or later, so the delay is zero. Or the data link is placed so
  it never trails.
- **Cost:** a floorplan or MIU timing choice, with no logic in OOE.
- **Signal:** a non-zero derived delay in the design's own `links.json`.

### PF-12 More bypass paths between groups

- **Now:** only lane ALU to lane ALU bypasses (A-59). Every other pair waits
  its producer's full latency (see "Bypass groups" in
  [`ooe-model.md`](ooe-model.md)).
- **Alternative:** bypass networks between more pairs: RCU-only results to
  the lanes, SFU to SFU, results to RCU's address path for memops.
- **Cost:** wires and muxes per pair, and one more wake vector per distinct
  offset in the scheduler.
- **Signal:** per pair, the dependants that waited a full latency where a
  bypass would have woken them earlier (to add: a counter per producer unit
  and consumer group).

### PF-13 Non-contiguous squash (stream tags)

- **Now:** squash is contiguous in ROB order. Correct work from other PC
  groups is squashed and refetched (A-31).
- **Alternative:** stream-tagged squash that kills only the mispredicted
  group's descendants.
- **Cost:** tag exhaustion and lineage tracking through merges (the doc's
  reasons). The doc rejected it for the first build.
- **Signal:** `squash.cross_group`, the doc's own event. It needs divergent
  kernels, which no S1 kernel has yet.

### PF-14 Younger non-memory ops pass a barrier wait

- **Now:** the barrier wait holds the warp's rename until release
  (`hold.barrier`). The doc deferred the relaxation.
- **Alternative:** younger non-memory ops rename and execute past the wait.
- **Cost:** memops must still hold, and demotion while waiting gets harder.
- **Signal:** `hold.barrier` on short waits. A long wait demotes anyway.

### PF-15 `chwidth` without serialising rename

- **Now:** a `chwidth` change holds the warp's younger uops at rename until
  it retires (`hold.chwidth`).
- **Alternative:** carry the speculative `chwidth` with each uop, or rename
  it like a register, and recover it on a squash.
- **Cost:** a speculative copy per checkpoint, and the dispatch-stage checks
  (F-WIDTH, F-FORMAT) must read speculative state.
- **Signal:** `hold.chwidth`. The doc expects these changes mostly at kernel
  entry, so it should stay small.

### PF-16 More than one redirect a cycle

- **Now:** `ccv_ooe_fet_redirect` is rate 1. Simultaneous mispredicts queue
  (`stall.redirect_busy`), and epoch notices share the slot (A-6).
- **Alternative:** rate 2, or one per tier-1 slot.
- **Cost:** wires to FET, and FET applying several restores a cycle.
- **Signal:** `stall.redirect_busy` with several warps resident.

### PF-17 More branch checkpoints per warp

- **Now:** 4 per warp, in FET and in OOE's RAT checkpoints. Fetch stalls
  with all four live (`ckpt_full`, a FET counter).
- **Alternative:** more checkpoints, or checkpoints only on low-confidence
  branches with a ROB walk-back for the rest.
- **Cost:** 152 bits per RAT checkpoint plus FET's group state per
  checkpoint, and the 2-bit `checkpoint_id` grows.
- **Signal:** FET's `ckpt_full` cycles on grid-stride loops (the doc's
  sweep item).

### PF-18 A masked load merged without a copy-only op

- **Now:** a masked load issues a copy-only op beside it. That takes a
  second RCU issue slot, and the load's readers wake on the later of the
  two (A-38, `stall.copy_port`).
- **Alternative:** MIU carries the old value, or RCU merges at load
  write-back from `phys_old_dst`, as it does for predicates (A-43).
- **Cost:** a read port on the load write-back path, or 1024 bits more on
  the memop and data channels.
- **Signal:** the doc's masked-load copy-op event (`copy` coverage) and
  `stall.copy_port`.

### PF-19 Criticality-aware select

- **Now:** the MIU class first, then the RCU class. Each picks oldest
  first per warp, with a rotating warp tie-break (decision 1, Q-4).
- **Alternative:** priority for ops on a load's address chain, ops feeding
  an unresolved branch, or a warp at its RS cap.
- **Cost:** a criticality bit per RS entry, set at rename or learnt, and a
  wider select priority.
- **Signal:** `ready_not_selected` with full issue slots
  (`issue_per_cycle` at 4). There is nothing to gain while slots go unused.

### PF-20 Rename in the cycle a uop arrives

- **Now:** a uop is written into the decode queue the cycle it lands,
  renamed the next and selectable the one after. That is two cycles before a
  ready uop can issue.
- **Alternative:** bypass an empty decode queue straight into rename, and
  select an entry with no producers the cycle it renames.
- **Cost:** a longer rename path, and a select input from the rename
  stage.
- **Signal:** front-end-bound kernels, where the decode queue is often empty
  and `issue_per_cycle` low after redirects. Mispredict recovery pays the
  two cycles every time.

### PF-21 Dynamic per-warp RS and decode-queue limits

- **Now:** static caps, a knob with no parameter yet (`rs_warp_cap`,
  `decq_warp_max`).
- **Alternative:** caps that adapt to stalls, tightening on a warp blocked
  on a miss and loosening when others idle.
- **Cost:** a small controller per warp.
- **Signal:** `stall.rs_warp_cap` with other warps idle. The sweep shows any
  static cap under the class size costs throughput when warps rarely stall.

### PF-22 Retire wider than two per ROB

- **Now:** 2 per ROB per cycle, 8 across the four ROBs.
- **Alternative:** 4 per ROB.
- **Signal:** `retire_per_cycle`. The synthetic sweep says 4 buys about 1%,
  so this is recorded only to keep the measurement.

### PF-23 Demotion abandons outstanding loads

- **Now:** demotion and kill wait for every outstanding memop of the warp
  before `drained` or `kill_ack` (V-26, V-28).
- **Alternative:** abandon pending loads (PF-2's cancel), so a warp demoted
  for a long MLC miss leaves at once. That is often exactly why it was
  demoted.
- **Cost:** PF-2's MIU recall.
- **Signal:** cycles from demote to drained (to add), on MLC-miss demotions.

### PF-24 Divergent branch prediction

- **Now:** FET predicts uniformly. A divergent outcome is a mispredict, and
  the whole warp redirects.
- **Alternative:** predict the taken mask (the doc's FET item).
- **Signal:** mispredicts whose outcome was divergent (to add, in FET or
  from `branch_mask` here).

### PF-25 Predicate renaming in place of the fixed-window holds

- **Now:** S1 mode only. Predicates sit at fixed windows, and OOE orders
  writes behind older readers and writers (`hold.pred_window`).
- **Alternative:** the design's own predicate renaming (Q-21, A-39), which
  the model already has.
- **Status:** adopted. TI-1 (A-75) brought the renamed predicate sources
  and OI-3 the predicate-map hook, so the kernels run renamed by default
  ([`ooe-model.md`](ooe-model.md), "S1 modes").

### PF-26 Co-issue lane ops whose lane masks are disjoint

- **Now:** each lane block has four operand ports, so lane ops share a
  cycle only by taking separate slices of them: narrow `chwidth` ops in
  different sections. Two full-width lane ops never co-issue, even when
  their issue masks are disjoint (Daniel, 2026-10-08).
- **Alternative:** also co-issue lane ops whose lane masks are disjoint,
  for example the divergent PC groups of one warp, or partial-warp ops of
  different warps. RCU steers each lane's ports to the op that owns that
  lane.
- **Cost:** a pairwise mask-disjointness check among one cycle's grants,
  which is the serial path banked select avoids (OA-1). A precomputed
  overlap bit per entry pair, set at rename like the age matrix, keeps it
  off the loop. RCU also needs per-lane port steering.
- **Signal:** cycles where a ready lane op waits behind another lane op
  whose mask is disjoint from it (to add, `ready_not_selected` split by
  that cause).

### PF-27 Fold section alignment into the producing op

- **Now:** where a narrow op's operands sit in different sections, rename
  inserts an explicit move, executed in RCU on RCU's own grant (DA's
  responses OI-30 and AR-13, 2026-10-08). It costs no section throughput,
  but it takes an issue slot and a temporary slice, and it adds RCU's
  latency to the consumer.
- **Alternative:** the producing load or ALU op writes its result straight
  into the section its consumer needs, so no move exists.
- **Cost:** the producer's latency would then depend on its destination's
  slice position. That is variable latency into the bypass network and a
  new set of bypass cases, which is why it was rejected for now. A
  read-path byte rotate on one operand port is the other way to remove
  the moves (AR-13).
- **Signal:** inserted moves per narrow op on `vadd16` (to add, once slice
  placement exists: `rename.section_move`). Also the cycles a move waits
  because four narrow ops hold the four issue slots (AR-13's open point).
