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

PF-1 to PF-29 are OOE's, from a scan of the Stage 4 decisions, the
model's decisions 1 to 11 ([`ooe-model.md`](ooe-model.md)) and the
interface review rows. From PF-30 the top-level architect (AR) adds
entries from the cross-agent register and the compiler's measurements. Each entry gives the current choice, the
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
| PF-15 | `chwidth` without serialising rename | rename | deferred (DA's response OA-16) |
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
| PF-27 | Fold section alignment into the producing op | rename, RCU, bypass | dropped (DA's revised OI-30) |
| PF-28 | Loads pass older loads | scheduler, MIU | deferred (DA's response OA-13) |
| PF-29 | Narrow co-issue within one warp | rename, compiler | deferred (DA's response OI-35; OA-19 (b)) |
| PF-30 | 4-bit work at 8x: nibble sub-sections | LANE, RCU, rename, scheduler | deferred (DA's response OI-29) |
| PF-31 | A warp-uniform register file and scalar datapath | ISA, RCU, rename, compiler | deferred (CP-7, compiler F-106) |
| PF-32 | Branch resolution fed by a lane compare at the bypass point | LANE, RCU, scheduler | deferred (S1 traces) |
| PF-33 | Fewer block crossings on the L1-hit path | MIU, DCU, RCU, partitioning | deferred (S1 traces; Q-18) |
| PF-34 | Same-address combining for atomics, built from lane adds | LANE, RCU, MIU, ISA | deferred (IS-14; DA's response AR-21) |
| PF-35 | A one-instruction warp reduction in RCU | ISA, RCU, compiler | deferred (IS-14) |
| PF-36 | Return-address prediction for `ret` | FET | deferred (CP-9; AR-20) |
| PF-37 | Merge masked lanes at write-back in RCU | RCU, LANE, interfaces | deferred (OA's response IS-10) |
| PF-38 | The aligned-half fallback pick | scheduler | deferred (over the select stage) |
| PF-39 | An early MLC-miss notice for demotion | MLC, DCU, MIU, OOE, RAU | deferred (TI-24 (5)) |
| PF-40 | Pack a parked warp's rows: keep sharing, elide zero rows | OOE, RCU, PCA | deferred (TI-25, closed at OA's rev 165) |
| PF-41 | Restore a parked warp before it is ready, into an idle slot | RAU | deferred (TI-21; OI's rev 155) |
| PF-42 | Store-to-load forwarding within a warp | MIU | deferred (TI-27 (d); TI-36) |
| PF-43 | Carry a per-lane base in a field the memop does not use | RCU, MIU, OOE | deferred (measured: the field stays; TI-32) |
| PF-44 | Fetch past a converged barrier wait | FET, OOE | deferred (TI-40) |

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

- **Now:** lane integer and FP results bypass inside the lane at
  `CCV_LAT_LANE_BYP` (A-59), with penalties set by bypass group: 0 within
  a group, 2 between integer and FP (DA's responses OA-4). SFU has no
  bypass point until a `CCV_LAT_SFU_BYP` exists (OA's response OI-16), so
  its dependants wait the full `CCV_LAT_SFU`. RCU-only, warp-collective,
  predicate and memop-address consumers take no bypass (V-48). See
  "Bypass groups" in [`ooe-model.md`](ooe-model.md). (Updated 2026-10-19
  by AR: this line said only ALU to ALU bypassed, which predates OA-4.)
- **Alternative:** bypass networks between more pairs: RCU-only results to
  the lanes, SFU to SFU, results to RCU's address path for memops.
- **Cost:** wires and muxes per pair, and one more wake vector per distinct
  offset in the scheduler. An SFU bypass point also widens the lane's
  bypass select: `CCV_P_W_LANE_BYP_AGE` is derived from the lane window
  alone, and must then take the widest window over producer groups, or
  RCU cannot name an SFU producer (AR's response TI-8).
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
- **Design of record** (OA-16, deferred by DA's response of 2026-10-09):
  - the width lives in the RAT entry beside row and position: 2 bits per
    entry, 32 per checkpoint;
  - a narrowing `chwidth` renames in place: same row, the low section or
    half of the old set, the new width, with the vacated sections freed
    at retire;
  - every widening, 4 to 8 included, is a lane op that writes the
    zero-extended value, which is what keeps O-38's cleared bits true;
  - `chwidth.multi` becomes a multi-register rename, using rename
    bandwidth in proportion to its register count;
  - F-WIDTH and F-FORMAT move to rename and become speculative;
  - it needs invariant 2's mechanism clause struck (IS's response OA-16),
    and the fault model's stage table and the 4-bit decision's detection
    section rewritten.
- **Measured:** in the pinned compiler snapshot, only vadd16 and
  vadd16_loop carry `chwidth`, one `chwidth.multi` each at kernel entry,
  and none inside a loop. So the hold costs one drain per narrow kernel
  (OI's response OA-16).
- **Trigger:** a corpus kernel that widens inside a loop (asked of CP).

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

- **Now:** a uop is written into the decode queue the cycle it lands, then
  takes three rename stages and a payload stage before it is selectable
  (`rename_stages` = 3 in the model; [`ooe-model.md`](ooe-model.md)).
  (Updated 2026-10-19 by AR: this line said two cycles, which predates the
  three-stage rename.)
- **Measured (S1 traces, 2026-10-19):** on `loop`, every iteration ends in a
  redirect, and the refill from branch issue to the next issue is 15
  cycles. `rename_stages` = 1 takes the kernel from 2,736 to 2,536 cycles
  (7%). FET is a stub that predicts not-taken, so the mispredict rate is
  pessimistic, but the per-redirect cost is the model's.
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

- **Status:** dropped, 2026-10-08. DA's revised response OI-30 replaced
  forced alignment with the footprint rule: an op claims the union of its
  operands' sections, and the lane swizzles bytes within its own 32-bit
  word, so no section moves exist to fold. The entry is kept as the record
  of the alternative.

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

### PF-28 Loads pass older loads

- **Now:** memops issue in program order per warp, one a cycle (decision 2;
  DA's response OA-13, 2026-10-09). PF-6 is the store side.
- **Alternative:** a plain load issues past older unissued loads of its
  warp, never past a store, atomic or fence (OA-13). Read-read coherence
  still binds two loads to the same address, and the ISA has no
  per-access ordering qualifier, so every load must honour it (IS's
  response OA-13). The form of record is detect-and-squash: loads issue
  freely, and a younger load is squashed when an older load to the same
  address returns a different value. The squash uses IS-4's contiguous
  squash. If the replay rate proves material, the escalation is a
  per-access ordering qualifier on Format D.
- **Cost:** a same-address compare against in-flight loads, a second user
  of the CAM that store-to-load forwarding needs (PF-7), and the replay
  path.
- **Measured:** the OI-34 sweep's `loads_pass_loads` arm (a model with no
  addresses, so an upper bound): 0% on every loop but one, 6% on vadd8
  under slot + register placement. One iteration's loads become ready
  together.
- **Signal:** cycles ready loads wait on older unissued loads (to add, a
  split of `hold.memop_order` by the older memop's kind). Revisit when the
  corpus has gathers or pointer chasing, or if the sweep gain exceeds a
  few percent.

### PF-29 Narrow co-issue within one warp

- **Now:** a narrow destination with no narrow source takes the warp's home
  position, its tier-1 slot index (8-bit), or the index mod 2 (16-bit)
  (DA's response OI-35, 2026-10-09). Narrow ops co-issue across warps.
  One warp's narrow ops share a section, so a lone warp runs narrow code
  at the 32-bit rate (AR-16: the 2x and 4x rates are aggregate across
  warps).
- **Alternative:** `chwidth` declares a 2-bit preferred position per
  register, which rename takes as the home for a destination with no
  narrow source. The compiler spreads independent values across sections
  and gives each section with readers its own copy of a shared narrow
  operand, so each reader's footprint stays one section (OA's response
  OI-35). A wrong declaration costs co-issue only (AR-15).
- **Cost:** 2 bits per register in `chwidth` and `chwidth.multi` (IS's
  encoding to find), 2 bits per RAT entry, a CP placement pass, and the
  registers the copies take. Hardware replication was rejected: rename
  cannot tell which values will be shared.
- **Measured (OI-34):** home = slot + architectural register, a stand-in
  for a declared position, gives a lone warp 1.38x on eight independent
  accumulators (alu8-self). It costs 1.55x on four warps when every op
  reads one shared narrow operand, because that operand's section joins
  every footprint. That is the case the per-section copies exist for.
- **Signal:** `foot.*` against `spread.*` and `sections_idle` on one-warp
  narrow kernels. Revisit when a one-warp narrow kernel matters (asked of
  CP).
- **Four warps too (IS-9, OA-19 (b)):** under home = slot index each warp
  has one section at 8 bits, so 4x needs every warp to hold a ready narrow
  op every cycle. With select's section fallback the four-warp element
  rate is 2.40x at 8 bits and 1.59x at 16 over alu32 (`--sweep-sections`,
  element ops per cycle outside setp cycles), and DA's response OA-19 holds
  the first build to it. This is the lever for most of what remains, and
  is unmeasured: it needs a model arm with compiler-chosen positions
  before it is built (OA).

### PF-30 4-bit work at 8x: nibble sub-sections

- **Now:** a `chwidth` = 4 register takes a whole 8-bit section, and every
  write leaves bits [7:4] zero, masked at write-back in the lane (IS-6).
  4-bit work therefore retires at 4x, the 8-bit rate (DA's response OI-29;
  the OOE microarchitecture's "Narrow registers and lane sections").
- **Alternative:** split each section into two independently controlled
  4-bit halves, so eight 4-bit ops co-issue per lane. A register's
  position grows from 2 bits to 3, and the footprint mask from 4 bits to
  8. E2M1 FP then needs eight FP4 units per lane, beside the four FP8
  units DA's response IS-7 already builds.
- **Cost:** every per-section field on `ccv_rcu_lane_ops` doubles. Its
  warp-uniform control is 208 bits a lane today (AR-18), so about 400. The
  lane sections in select go from 4 to 8 (`CCV_ISSUE_RESOURCES` 9 to 13),
  each RAT entry gains a position bit, and IS-6's mask becomes a nibble
  write enable. Memory does not keep up: 4-bit data lives packed two to a
  byte and is reached through `unpacki`, so four MIU pipes supply 256
  elements a cycle (IS's response OI-33). That is level with an 8x ALU,
  with no headroom, and `unpacki` takes lane slots from the arithmetic it
  feeds.
- **Signal:** no kernel exercises it yet, because the compiler has no
  8-bit or 4-bit register class (CP-6). Revisit when an INT4 or FP4
  kernel runs. Measure the rate at which a 4-bit op is ready while all
  four lane sections are held (to add: a split of the section-busy hold by
  width), and `sections_idle` on that kernel. An upper bound comes cheaply
  from an OI-34 sweep arm with eight nibble resources.

### PF-31 A warp-uniform register file and scalar datapath

- **Now:** a warp-uniform value takes a full 1,024-bit GPR row, or the
  compiler re-reads it from the launch block through the slot form (O-45;
  CP-4's 8-byte stride reaches sixteen pointer arguments). Uniform
  arithmetic runs in all 32 lanes. The ISA has 16 GPRs (O-25), and no
  uniform namespace.
- **Alternative:** a small per-warp uniform register file with a scalar
  ALU in RCU, and a uniform-operand selector on vector instructions
  (the compiler's `proposals/warp-uniform.md`, option C; compiler F-106).
- **Cost:** ISA encoding space, with no free format tag left (compiler F-54); a
  second rename table and free list; a scalar datapath and its bypass in
  RCU; uniformity analysis in the compiler, which exists only as lane-0
  masking (O-33, whose reach CP-2 cut). On the hardware side it also pays
  back: every uniform value held in a GPR occupies a whole 192-entry PRF
  row, 31/32 of it redundant.
- **Measured (compiler side):** since CP-4 no shape in the fused corpus
  spills for uniform pressure (CP-7). The cost has moved into instruction
  count: launch-block re-reads are 20 to 27% of the stream on the loop
  rows (compiler F-152; the compiler's `benchmarks.md` §4). GEMM's spills are
  divergent accumulators, which no uniform mechanism reaches (CP-5).
- **Measured (lane side, OI's IS-9 figures):** a loop's back-edge compare
  is a 32-bit lane op, which takes all four lane sections for its cycle.
  At four warps it holds 19.2% of section-cycles at alu8 (21.7% with the
  section fallback) and 15.6% at alu16 (`select.lane_ctl_cycles`). A
  uniform compare on the scalar datapath frees them: at most
  1/(1 - 0.217) = 1.28x on the narrow kernels, so 8 bits reaches at most
  about 3.1x over alu32. Grid-stride loops compare a per-lane index, so
  none of those compares is uniform without CP's loop-uniformization
  transform (CP's correction, OA-19), which this entry's compiler cost
  then includes.
- **Signal:** the dynamic fraction of issued ops whose operands are all
  warp-uniform (to add: a ccv-sim counter), and the PRF rows that uniform
  values hold when rename stalls on an empty free list (to add, in the
  OOE model). Revisit when either is material on a real kernel. The ISA
  half is IS's (CP-7).

### PF-32 Branch resolution fed by a lane compare at the bypass point

- **Now:** `setp` executes in the lane and its predicate returns to RCU in
  `ccv_lane_rcu_res`'s `sec_pred_out`. The branch resolves in RCU, and
  predicate results take no bypass (DA's responses OA-4; V-48), so a
  branch waits the full `CCV_LAT_LANE` = 7 after its compare issues.
- **Measured (S1 traces, 2026-10-19):** on `loop`, compare to branch is 7 of
  each iteration's 27 cycles: fetch to first issue 8, add to compare 4,
  compare to branch 7, branch issue to redirect 5, redirect to FET 2, and
  a section conflict 1.
- **Why it matters beyond a stub:** IS-4 makes prediction uniform-only in
  the first build, so every divergent branch waits for resolution, as does
  every mispredict. Compare-to-branch latency is on the critical path of
  both.
- **Alternative:** deliver a lane compare's predicate to RCU's branch
  resolution at the lane's bypass point, `CCV_LAT_LANE_BYP` = 4, rather than
  at write-back. Branches that consume a lane compare get a wake offset of
  their own.
- **Cost:** the predicate already travels from lane to RCU; it would have to
  leave the lane earlier than the result, as an early field or a narrow
  lockstep channel of its own (32 bits a lane array, one per section).
  RCU's branch unit gains one bypass input, and the scheduler gains one
  offset.
- **Signal:** cycles from a compare's issue to its dependent branch's issue
  (to add), weighted by branches that resolved a divergence or a
  mispredict. Revisit when FET predicts and the corpus has divergent
  kernels, both on roadmap Part 0's next list.

### PF-33 Fewer block crossings on the L1-hit path

- **Now:** an L1-hit load's dependant wakes `CCV_LAT_L1_WAKE` = 16 cycles
  after the load issues. Of those, 5 are RCU's address read
  (`CCV_LAT_RCU_ADDR`, a placeholder) and 7 are the L1 hit
  (`CCV_LAT_L1_HIT`), which itself includes the MIU-to-DCU round trip. The
  rest are crossings at `CCV_LAT_HOP` = 2: issue to RCU, address to MIU, and
  data back to RCU, less the issue crossing the dependant pays too. So
  issue to data in RCU is 2 + 5 + 2 + 7 + 2 = 18 cycles, about 10 of them
  crossings once the MIU-DCU pair is counted. A load whose address comes
  from a load also waits for confirmation (PF-4) and for completion at
  `CCV_LAT_L1_CMPL` = 18.
- **Measured (S1 traces, 2026-10-19):** on `hit`, an L1-hit pointer chase is
  19 cycles from load to load. A miss is 34 cycles from issue to completion
  with a 10-cycle DRAM placeholder; about 20 of the 34 are ten crossings.
  The stubs run at contract latency, so these are the parameters' numbers,
  not the stubs'.
- **Alternative:** return L1-hit data from DCU straight to RCU, one crossing
  instead of two through MIU. Or fold DCU's lookup into MIU, which removes
  the MIU-DCU round trip. Either is a partitioning change. Co-locating the
  AGUs with RCU (Q-18) shrinks the widest interface but removes no crossing
  by itself.
- **Cost:** a block boundary moves, and a block boundary is a swap boundary.
  DCU would need a second data port, to RCU, and MIU would lose sight of
  hit data it now forwards, which matters for store-to-load forwarding
  (PF-7).
- **Signal:** load-to-load interval on address chains, and the share of
  `CCV_LAT_L1_WAKE` that is crossings, which follows from the parameters.
  Revisit with Q-18, before floorplan, and once the corpus has pointer
  chasing or indexed gathers whose index is loaded.

### PF-34 Same-address combining for atomics, built from lane adds

- **Now:** every atomic's operation executes in the lanes, integer and FP,
  global and shared, because no FP arithmetic is built outside the LANE
  blocks (DA's response AR-21, 2026-10-19). MIU holds the line exclusive
  (SPM the bank entry) from the atomic's read to its write. Same-address
  lanes of one instruction go in passes of at most one lane per address,
  in ascending lane order, each pass a round trip (AR-21). So 32 lanes to
  one address cost 32 passes, with the line held throughout. Today
  `atomicAdd(float*)` is still a CAS loop, and `cas.global` is not yet
  selectable (IS-14). The FP32 adder IS-14 asked about costs nothing, since
  the lanes have it.
- **Alternative:** combine same-address lanes before the memory update, for
  the no-return `red` form only, since `atom`'s per-lane old values must
  form a serialisation, which a tree cannot produce in FP (AR's response to
  TI on IS-14). Under DA's ruling the tree must be built from cross-lane
  moves through RCU plus lane adds: five levels for 32 lanes, segmented by
  address. Rejected in its first form, an adder tree at DCU and SPM, by
  DA's response AR-21.
- **Cost:** five RCU-and-lane round trips per combined instruction, a
  segmented-reduction control (lanes grouped by address), and the order IS
  fixes for `red`. Verification is TI's chain check, extended to `red`'s
  tree (TI's response IS-14).
- **Signal:** passes per warp atomic and cycles a line is held exclusive, on
  CP's histogram and scatter-add kernels at low and high contention (IS-14),
  to add once `cas.global` and the atomics are lowered.

### PF-35 A one-instruction warp reduction in RCU

- **Now:** a warp reduction goes through shared memory, because `shfl.down`
  and `shfl.bfly` are specified but not built. A shuffle tree would be five
  `shfl` and five operations, each a warp-collective round trip through RCU
  at `CCV_LAT_COLLECTIVE` (IS-14).
- **Alternative:** `redux` (integer add, min, max, and, or, xor) as a Format G
  point, executed in RCU, which already sees all 32 lanes for every
  collective. PTX has `redux.sync`, so the compatibility target names it.
- **Cost:** a 32-input reduction tree in RCU's collective path, about five
  adder levels for add, so a pipelined unit with its own latency class. Its
  result is warp-uniform, so it also feeds PF-31's case if that returns.
- **Signal:** the shuffle and shared-memory share of the reduction kernels'
  issued instructions, once the shuffles are built (asked of CP in IS-14).

### PF-36 Return-address prediction for `ret`

- **Now:** `ret rs` sets each lane's PC from a register (compiler proposal
  `calling-convention.md`, CP-9). FET predicts uniform branches only (IS-4)
  and nothing names an indirect-target predictor, so every return waits
  for RCU to read `rs` and redirect FET. That costs about the 15-cycle
  refill the S1 traces measured from branch issue to the next issue
  (PF-32's measurement).
- **Alternative:** a per-warp return-address stack in FET, pushed when a
  call writes its link register and popped at `ret`. The prediction is
  checked at resolution like any branch. The convention makes it easy:
  `call` writes a fixed, ABI-named link register (R14 for `call.short`), and
  frames are static with no recursion (CP-9), so the stack's depth bounds
  the call depth that predicts correctly. Compiled code always calls on R14
  and returns with `ret r14`, while an indirect call's stub jumps with
  `ret rF` for some other register, so FET can tell a return from a jump by
  the register alone, and the stack is exact for everything the compiler
  emits (CP's response to AR on CP-9). A direct call's target is PC-relative
  and known at decode.
- **Cost:** a few entries of 32-bit code addresses per tier-1 warp. It must
  be checkpointed with the branch state, so a mispredict or a demotion
  restores it. A divergent return, where lanes' `rs` differ, splits PC
  groups and cannot be predicted by one stack entry; it falls back to
  resolution.
- **Signal:** returns per thousand instructions and cycles each waits for
  resolution, on CoreMark (AR-20), to add when FET models a predictor.

### PF-37 Merge masked lanes at write-back in RCU

- **Now:** a guarded or masked lane op carries the old destination's value
  to the lane as `merge_data`, the fourth operand port on `ccv_rcu_lane_ops`,
  and an inactive lane returns it as its result on `ccv_lane_rcu_res` (A-33,
  A-44, A-51). So the merge value crosses the lane both ways. ISA v1.8 §1a.1
  forbids only toggling the inactive lane's ALU and its operand registers;
  the buses still carry the value (IS-10).
- **Alternative:** RCU merges at write-back. It re-reads the old destination
  from the PRF, as A-43 already does for predicates, and writes only the
  active lanes' results over it. The old destination's producer has always
  written by then (OA's response IS-10). The lanes then never see the merge
  value.
- **Cost:** one 1,024-bit PRF read per GPR write port, eight more reads
  beside the 16 at issue, which is half as many again on a 192-row flop
  array. Against that: `merge_data` leaves `ccv_rcu_lane_ops`, 32 of its 344
  bits a lane and 1,024 of its 11,008 wires (AR-18), and masked-lane toggling
  stops on both lane buses.
- **Signal:** the share of lane ops issued with a partial mask or a guard,
  and the bus toggle energy in masked lanes, on O-33's own kernels (14% and
  21.5% lane-activation savings, ISA v1.8 §1a.1). To be settled by AR with the
  RCU session.

### PF-38 The aligned-half fallback pick

- **Now:** select's fallback is section-only (OA's response IS-9): a lane
  section whose winner does not issue grants its oldest requester naming
  that section alone. 16-bit ops, which name a half, take no fallback.
- **Alternative:** also an aligned-half pick: a half whose two sections
  both fall through grants its oldest half-footprint requester, if that is
  the oldest of the half's pair and single-section requesters
  (`pick_fallback=2`, `ooe_pick` FB 2, both built and checked).
- **Measured:** alu16 at four warps 710 cycles (1.90x) against 823 (1.59x)
  with section-only; alu8 unchanged at 589 (2.40x).
- **Cost:** depth. ooe_select measures 26.8 NGD with it, past the 25 of
  its stage, against 24.3 section-only and 19.5 with none. The half's
  pick is parallel; what it adds is behind "did this section's winner
  issue", a 30-wide reduction after the main pick.
- **Signal:** a select stage with room (a request vector registered a
  stage earlier, or a pick restructured so a section's fall-through is
  known before the issue AND), or 16-bit code that matters at four warps.

### PF-39 An early MLC-miss notice for demotion

- **Now:** OOE learns `mlc_miss` only from a load's completion, which comes
  with the data, when the load stops blocking (TI-24 (5)). So the first
  build's MLC-miss trigger is time-based: the head is a load that missed L1
  (no completion at `CCV_LAT_L1_CMPL`) and has blocked longer than
  `CCV_DEMOTION_THRESHOLD_MLC`, which gen-params requires to exceed
  `CCV_LAT_MLC_HIT_MAX`, MLC's worst hit latency at DCU's boundary.
- **Alternative:** MLC reports a miss at its tag lookup, and the notice
  travels DCU to MIU to OOE, mapped at each hop to the requests it serves.
  A head load whose notice has arrived demotes at once.
- **Cost:** three notice hops, each a `notice_of`-style channel or a field
  on one (TI-23's form). DCU's and MIU's request maps already exist for the
  refill notice (OA-23).
- **What it buys:** each DRAM miss demotes `CCV_DEMOTION_THRESHOLD_MLC`
  minus MLC's hit latency sooner, so the warp holds its RS room and its
  slot that much less, against a fill of about 1,000 cycles.
- **Signal:** OI's swap environment sweeps the threshold at 25, 50 and 100
  (OA's rev 131). If 25 beats 50 by more than 1% on the swap-on sweep, and
  MLC's hit latency keeps the threshold from going that low, the notice is
  worth building.
- **Measured (OI, TI-21, 2026-10-22):** on the 8-warp swap sweep, threshold
  25 is 8% slower than 50 under the decided go (the interleave), and 3%
  faster only under one warp a cycle. Earlier demotion does not pay under
  the go the design uses, so the notice stays deferred. Re-measure once the
  drain stops waiting for the demoting load (AR's response TI-21, OI's
  rev 154), since that changes what a demotion returns.
- **Re-measured (OI's rev 158, AR's response TI-21, 2026-10-22):** under
  evict with the replay drain, on the 48-seed sweep, 25 gives 0.624 of
  swap-off against 0.588 at 50, 6.1% slower. The notice stays deferred. The
  threshold stays at 50: 100 gives 0.603, 2.5% slower, and wins only S1's
  short MLC misses (gather and vadd4), which an earlier trigger would demote
  sooner, not later.

### PF-40 Pack a parked warp's rows: keep sharing, elide zero rows

- **Now:** a demotion moves one row per architectural register, 16 plus the
  predicate row, whatever the warp's rows hold (TI-25). Narrow registers that
  shared a row each take their own, and a register still mapped to the zero
  register moves a row of zeros. Restore gives each register its own row,
  with its position and committed width from OOE's 64-bit entry for the warp.
- **Alternative:** OOE also keeps each register's distinct-row index and a
  zero flag (148 bits a warp against 64). The demotion then moves only the
  distinct non-zero rows, and restore rebuilds the sharing, with zero-flagged
  registers mapped back to the zero register (A-64's launch state).
- **What it buys:** fewer migration cycles each way (up to 16 for a warp that
  never wrote its registers), and fewer PRF rows held after a restore by a
  warp whose narrow registers had been packed.
- **Cost:** 84 more bits a warp context in OOE (about 2.7 Kb), and
  restore-allocate taking a variable count from the slot's reservation.
- **Signal:** the migration cycles in the swap sweep under the replay drain
  (AR's response TI-21, OA's rev 160), and the PRF rows a restored warp holds
  when rename stalls on an empty free list. Revisit if migration is material
  there.

### PF-41 Restore a parked warp before it is ready, into an idle slot

- **Now:** RAU restores only a ready parked warp, one whose last abandoned
  load has been answered (`ccv_miu_rau_ready`, TI-21). A free slot with no
  ready warp idles.
- **Alternative:** restore the oldest not-ready warp into the idle slot,
  marked provisional, with its forward-progress guard starting at its ready
  report. Its replayed load merges at DCU into the fill in flight (AR's
  rev 115; built as a knob in the RAU stub, `CCV_RAU_READY=0`, and in OI's
  environment).
- **Measured:** TI's swap kernel, where the slot would otherwise idle: 605 to
  558 cycles (557 with no swap). OI's 48-seed swap sweep, with four parked
  warps ready from the start: 0.654 against 0.646, about 1% lost. When a
  ready warp appears, a provisional warp holds the slot until the trigger's
  threshold and a drain have passed (57 provisional restores, 521 declined
  demotes against 417).
- **The variant to try:** pre-empt a provisional warp the moment a ready warp
  appears, without waiting for the threshold. It is blocked behind the same
  fill anyway, so only the drain and a migration each way are lost.
- **Signal:** the pre-empting variant at or above the ready-only figure on
  the swap sweep, and still ahead on provswap. Then it becomes the default.
- **Measured under evict (OI, 2026-10-22):** evict alone 0.588 against
  swap-off; with the provisional restore 0.641; with the pre-empting variant
  too 0.627 (675 provisional restores, 28 pre-empted). Neither wins: a
  provisional warp is still blocked on its fill, so evict demotes it again.
  Both stay knobs, default off.

### PF-42 Store-to-load forwarding within a warp

- **Now:** MIU holds a load while any older store or atomic of its warp that
  overlaps one of its lines has not yet written DCU, committed or not, and
  forwards nothing (AR's response TI-27 (d)). It is exact with no
  disambiguation, because a warp's memops issue in program order (OI-15).
- **Alternative:** forward an older store's bytes from the store buffer to a
  younger load of the same warp that they fully cover. Narrow the hold to
  byte overlap, so a load that only shares a line with the store does not wait.
- **What it buys:** a load behind its own warp's store skips the store's
  retirement and the write into DCU. The common case is a `.local` fill after
  its spill, which 16 GPRs make frequent, and a spin-wait that reads a flag
  its own warp just wrote.
- **Cost:** a byte-mask compare of each load's lanes against the warp's
  store-buffer entries, a data mux from the store buffer onto the load's
  return path, and a second source for `ccv_miu_rcu_data`'s fixed-latency
  slot.
- **Signal:** cycles loads spend held behind an older store, per kernel, in
  OI's environment, and the spill and fill count from the compiler's
  register-pressure kernels. Worth building if the held cycles are over 2% of
  any kernel's cycles.
- **Data (CP's AR-20 sweep, 2026-10-22):** the CoreMark-derived workload at
  six callee-saved registers moves 44,125 frame transfers per thread in 2
  iterations, 2.9% of its 1,538,673 issue groups. That is about 92 a call,
  of which at most 12 are saves and restores, so spills and fills dominate.
  Held cycles come from the skeleton once TI times the kernel (AR-20, after
  the kill).
- **The predicate case (TI-36, 2026-10-23):** an ld.pred behind an older
  st.pred to the same word can take the store's word d without waiting for
  the merge, whenever the load's active_mask is a subset of the store's m.
  ld.pred writes only its active lanes (O-62), and those bits are d's. That
  covers a reload by the same group, or by a part of it after a split. It
  costs a word compare, a mask-subset test and a 32-bit path from the store
  buffer to pred_result. Not built: CoreMark-derived reloads a predicate 4
  times in a run. The skeleton's figure, about 960 cycles a reload in
  predswap, is a cold-memory bound with no L1 hit, not a typical cost.

### PF-43 Carry a per-lane base in a field the memop does not use

- **Now:** `ccv_rcu_miu_addr` carries `base_per_lane`, 32 bits a lane beside
  `index_per_lane` and `store_data`, so any Format D form may have a per-lane
  `rbase`, as §3 allows (AR's response TI-32). That is 960 bits more a pipe
  slot than the old 64-bit scalar, 3,840 wires on the design's widest channel.
- **Alternative:** drop the field. A load sends no store data, so its base
  rides `store_data`. A base+disp store has no index, so its base rides
  `index_per_lane`, and every spill is one of these. Only an indexed store
  with a register base needs three per-lane values. It takes a second address
  cycle, with OOE reserving its pipes for two cycles.
- **What it buys:** the 3,840 wires, about 46% of the channel.
- **Cost:** a two-cycle pipe reservation in OOE's select for one memop class
  (OA's), half the address bandwidth for that class, and MIU choosing the
  base's source by form.
- **Signal:** CP's dynamic count of register-base indexed stores as a share of
  memops across the corpus, and the floorplan cost of the RCU-MIU boundary
  once it is known. Worth it if the class is under 1% of memops, or the
  boundary does not close.
- **Measured (CP, release f1fd257, 2026-10-22):** register-base indexed
  stores are 18,157 of the CoreMark-derived workload's 108,170 memops
  (16.8%), from list walking through per-lane pointers. The GPU kernels
  have almost none: 1 of 7 in transpose, 1 of 93 in layernorm, 0 in the
  other ten. The signal fails on general-purpose code, the code AR-20
  exists to measure, so the field stays. Reopen only if the RCU-MIU
  boundary does not close in floorplan.

### PF-44 Fetch past a converged barrier wait

- **Now (proposed, TI-40; OA's rev 195 as AR amends it at AR's rev 160):**
  FET parks a waiting group's lanes at a fetched `bar.wait` or
  `bar.wait.phase`, and they fetch again when SYU's reply to the retired
  wait arrives. So the path from the release to the warp's next issue runs
  through fetch, decode, the decode queue and three rename stages. Under the
  old rename hold it was rename and payload only, with the younger uops
  already waiting in the decode queue.
- **Alternative:** when a wait leaves every live lane of the warp waiting
  (FET's idle mark), FET fetches past it, up to the warp's decode-queue
  share, and OOE holds those uops at rename until the release, as before. A
  diverged warp still parks at fetch, so the deadlock stays fixed.
- **What it buys:** most of the front end's depth, once per barrier per
  warp. PF-32's S1 traces measured 15 cycles from a branch's issue to the
  next issue on a redirect. A release costs most of that, against about 4
  under the hold, so the saving is about 10 cycles a barrier. That figure is
  an estimate, not a measurement.
- **Cost:** two mechanisms for one instruction. The rename hold and V-09 come
  back into OOE. The uops fetched past the wait are squashed when a demotion
  takes the warp.
- **Signal:** cycles from SYU's reply to the warp's next issue, times
  barriers, in the skeleton once barrier kernels run (TI-40). Worth building
  if it exceeds 1% of a barrier kernel's cycles, such as layernorm or a CTA
  reduction.
