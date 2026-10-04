<!-- design-snapshot url=https://claude.ai/artifact/7tpEyGaCvfdvYYWUQJvJSU tab=OOE_microarchitecture rev=100 exported=2026-10-04 status=living -->
> **Snapshot: do not edit.** Exported from *OOE microarchitecture — Stage 4 grill-me*, tab *OOE microarchitecture*, at revision 100 on 2026-10-04 ([live doc](https://claude.ai/artifact/7tpEyGaCvfdvYYWUQJvJSU)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# OOE microarchitecture — Stage 4 grill-me

Sep 28, 2026 · @Daniel Davis

## Summary

OOE is a latency-scheduled, dependency-matrix out-of-order engine for up to four tier-1 warps. It renames into a global physical pool with per-warp floors and ceilings, schedules everything itself because RCU and LANE latencies are a contract, and recovers by contiguous over-squash with branch checkpoints held in FET.

This is the output of the Stage 4 OOE grill-me. It replaces the Internals section of the OOE tab in the per-block spec. Interface consequences are in the companion doc, *Interface spec changes — OOE session*; the arch agent owns folding both into the high-level spec.

Every size here is provisional for the first build and has a sweep attached. Latencies are assumptions to be verified in the LANE, RCU and MIU sessions.

Three choices shape most of the block:

- **Stream tags are gone.** The implicit old-destination source chains PC groups together through every masked write, so non-contiguous squash would need dependency tracking. Squash is contiguous in ROB order instead.
- **OOE owns all scheduling.** Fixed latency in RCU and LANE is a contract, so wakeup, register ports and write-back are all decided at select. Only memory is variable, and it cancels.
- **RAU allocates nothing.** Physical registers live wherever the RAT puts them, and demotion reads them through the RAT.

### Governing principles

- **Latency is a contract, not an expectation.** RCU and LANE never slip after accepting an issue. The scheduler must be correct at any reasonable latency, provided it is configured with the right one.
- **Latencies are derived, not typed.** Base pipeline plus repeater stages, generated from `params/links.json`, with an arrival checker per completion channel.
- **Variable-latency events cancel transitively.** A load miss is the only one today; any cancelled producer poisons everything woken from it.
- **Nothing leaves OOE speculatively that cannot be recalled.** Memops issue only once their address sources are confirmed.
- **Shared, with limits.** RS, decode queue and rename pool are shared across warps with per-warp limits; the rename pool also has a per-warp floor so no warp starves.
- **Every structural stall has an event.** Undersizing must show up in the first runs, not be inferred.
- **One cleanup path.** Fault cleanup goes through RAU's kill only; OOE never squashes a faulting warp itself.

## Pipeline and structures

Uops flow top to bottom: decode queue, rename, reservation stations, ROBs. Everything to the right is another block, reached only through channels.

> **Figure, as text** (drawn in the live doc): OOE internal structures and channels · 4 stages, 7 peers
>
> *OOE owns rename, scheduling and recovery; peers only execute.* Shaded boxes are other blocks; arrows are channels.
>
> - **Decode queue**: 12 entries shared across warps, per-warp maximum. ← DEC, uop ×6. → Rename, 4 per cycle.
> - **Rename**:
>   - GPR RAT ×4: 16 arch + 4 checkpoints.
>   - Predicate RAT ×4: 4 arch + 4 checkpoints.
>   - GPR free list · 192: floor 16, cap 64 per warp.
>   - Pred free list · 48: floor 4, cap 20 per warp.
>   - Masked or guarded writes add the old destination as a source.
>   - A chwidth change or barrier wait holds that warp's rename.
>   - → SYU: bar. ← SYU: release. → Reservation stations: dispatch.
> - **Reservation stations · 45**:
>   - RCU class · 30: issues up to 4 per cycle; held until sources confirm.
>   - MIU class · 15: issues after address sources are confirmed.
>   - Wakeup: 45 × 45 two-bit cells, early or late wake.
>   - Select: oldest first per class, rotating warp tie-break.
>   - Cancel spreads transitively through the matrix.
>   - → RCU: issue ×4. ← RCU: done. → MIU: memop ×4. ← MIU: cmpl, miss. → ROBs: done, cancel.
> - **ROB ×4 · 32 entries each**:
>   - Allocated at rename; retires up to 2 per warp per cycle.
>   - Squash kills everything younger, in ROB order.
>   - Branch uops carry a FET checkpoint ID, 4 per warp.
>   - Squashed memops keep their registers until MIU completes.
>   - Fault: stop retiring, report, and let RAU's kill clean up.
>   - Demote: squash to retirement, then send the RAT map to RCU.
>   - Drained waits for every outstanding memop.
>   - Commits stores to MIU at retire, bulk discard on squash.
>   - → MIU: retire. → FET: redirect. → RAU: status. ← RAU: demote. → CRU: fault.
> - Peers:
>   - DEC: 6 uops per cycle.
>   - SYU: barrier table.
>   - RCU: fixed-latency contract; gets RAT map on demote.
>   - MIU: variable latency, cancels; stores leave at retire.
>   - FET: PC groups, 4 checkpoints.
>   - RAU: demotion policy, kill.
>   - CRU: first fault record.
Rename and the ROBs are per warp; the free lists, RS and select are shared across all four tier-1 warps, each with a per-warp limit so one stalled warp cannot starve the others. The ROB is allocated at rename even though the drawing shows completion reaching it from below.

## Rename

Rename takes 4 uops per cycle from the decode queue and maps every GPR and predicate destination to a fresh physical register. Renaming is never skipped.

### Decode queue

12 entries, shared across warps, with a per-warp maximum. Rename picks from it using the same rotating warp priority as select, so a warp stalled at rename does not block the others. DEC sees a full queue as ordinary credit backpressure. The depth absorbs 6-wide decode bursts against 4-wide rename and refills quickly after a downstream stall.

### Register alias tables

One GPR RAT (16 entries) and one predicate RAT (4 entries) per tier-1 warp. The guard predicate (`pred_guard`) and the predicate destination (`pred_dst`) are renamed separately (Q-21). Three GPR sources are renamed (Q-20). `add.pp`, `addi.pp` and `cas` write a GPR and a predicate, allocated from the two free lists and tracked in one ROB entry.

Each warp also keeps **4 RAT checkpoints**, GPR and predicate together, one per unresolved branch and indexed by the same `checkpoint_id` as FET's branch checkpoints. A checkpoint is 16 × 8 + 4 × 6 = 152 bits, so 608 bits per warp. It is taken when the branch renames and restored in a single cycle on a mispredict. The alternative, walking back from the ROB tail, costs less area but makes recovery time grow with squash depth.

### Identity shadow

OOE keeps each warp's `warp_base` and `%ctaid`, 37 bits per warp, delivered on `ccv_rau_ooe_alloc` at activation (A-25). For an `srd` of an identity register, OOE substitutes the value into the existing 32-bit `imm` slot at issue, so `ccv_ooe_rcu_issue` does not grow and RCU needs no identity path of its own.

### Free lists

One global GPR pool of 192 and one global predicate pool of 48. There are no per-warp partitions: a warp's architectural registers end up wherever the RAT puts them.

- **Floor.** Each tier-1 slot, occupied or not, reserves 16 rename registers above its 16 architectural registers (A-26, A-34). A floor, not a ceiling, is what prevents starvation. Both pools use one rule: floor = half the fair share of the rename pool, pool / (2 × warps), which is 128 / 8 = 16 for GPRs (A-40). The generator emits the floors from that expression, and an elaboration-time assertion checks ceiling + 3 × floor ≤ pool for both pools. For GPRs that is 112 against 128, 16 spare.
- **Ceiling.** No warp holds more than 64 rename registers beyond its architectural 16.
- **Restore admission.** Each tier-1 slot, occupied or not, keeps 16 architectural GPRs plus a floor of 16, and 4 architectural predicates plus a floor of 4, reserved. Restoring a parked warp into an empty slot therefore always finds its registers, and admission is immediate. Admission never waits and no credit is withheld on ccv\_rau\_ooe\_alloc (A-49). The invariant ceiling + 3 × floor ≤ 128 alone would not cover an empty slot.
- **Predicates.** 48 = 16 architectural + 32 rename. Each tier-1 slot reserves 4 rename predicates whether occupied or not, with a ceiling of 20 per warp, satisfying ceiling + 3 × floor ≤ 32 (A-39). The floor follows the same half-fair-share rule (32 / 8 = 4); the fit is exact, with no slack, and the elaboration-time assertion is what guards it (A-40). Predicate renaming is therefore as provably bounded as GPR renaming. Predicates are expected to need less rename space than GPRs, and the stall events will show if compare-heavy code hits this first.

### Merge semantics

A masked or predicated write leaves inactive lanes holding their old value, but a newly allocated physical register holds nothing useful. The previous mapping of the destination therefore becomes an **implicit source**.

- An RS entry tracks up to 6 producers as dependency-matrix bits: 3 GPR sources, the old GPR destination, the old predicate destination (A-43), and the guard predicate. Six is reached only by ops writing both a GPR and a predicate (`add.pp`, `cas`). There are no tag compares (A-37), so the count costs only rename-time bit setting.
- The implicit source is **elided** when the issue mask is full and the op is unguarded, since the merge is then dead. The guard's value is unknown at rename, so any guarded op keeps it.
- Narrow `chwidth` writes need no merge: widening zero-fills the upper portion of the row, so it is don't-care until then.
- The implicit source links PC groups together: group B's masked write of R3 reads group A's R3 result. This is why squash cannot be made non-contiguous without dependency tracking (see Retire, squash and recovery).

**How the merge happens: fourth source operand (A-33, revised 2026-10-02).** With `merge_en` set, the old destination is read at issue alongside the other sources and carried to the lane on `ccv_rcu_lane_ops`. The lane writes active lanes from the ALU result and inactive lanes from the carried value. Because it is an ordinary operand, the bypass network supplies it like any source. Copy-on-allocate was the first answer, but a register-to-register copy at issue cannot bypass, so every predicated write to a recently written register would have stalled for its producer's full latency.

A masked load gets a distinct copy-only op (`CCV_OP_PRF_COPY`, opcode 0x1FF) on `ccv_ooe_rcu_issue` when it issues to MIU. The copy op writes only the load's inactive lanes and the load data only the active lanes, so the two writes are disjoint and can land in either order. The load's dependants wake on the later of the two. The cost is one RCU issue slot per masked load.

**Masked-load structure (A-38).** At rename a masked load splits into a memop RS entry (MIU class) and a copy RS entry (RCU class). Both point at the load's single ROB entry and `rob_tag`, so no extra ROB entry or register is used. The copy produces no completion message: it is fixed-latency, so OOE knows when it lands. The ROB entry carries a copy-pending bit, cleared at the copy's scheduled landing cycle, and completes when the load has completed and that bit is clear. Dependants wake at the later of the two scheduled times.

**Predicate merge (A-43).** Predicates do not use the fourth operand. RCU merges them itself: at write-back it reads `phys_pred_old_dst` and read-modify-writes the 32-bit predicate row, which is cheap at that width. The old predicate's producer is a tracked dependency, so it has always written first. A masked `cas`'s copy op covers its predicate destination as well as its GPR.

**Write enables (A-44).** RCU writes the PRF through per-lane write enables. With `merge_en` set, a lane outputs `merge_data` (a separate field on `ccv_rcu_lane_ops`, A-51) for its inactive lanes. For a copy op, RCU enables only the inactive lanes, which the load does not own.

### Serialisation points

- **`chwidth` change.** When a `chwidth`-changing instruction renames, younger instructions from that warp hold until it retires, and it updates the committed `chwidth` table at retire. Dispatch-stage checks (F-WIDTH, F-FORMAT) therefore read only committed state. `chwidth` changes are rare, mostly at kernel entry.
- **Barrier wait.** After sending a wait on `ccv_ooe_syu_bar`, that warp's rename holds until `ccv_syu_ooe_rel`. Letting younger non-memory ops proceed would be legal, but a long wait gets demoted anyway, so the gain is limited to short waits and is deferred.

Both holds are warp-local and each has its own stall event.

## Scheduling

OOE owns all scheduling. Fixed latency in RCU and LANE is a contract, so OOE decides at select when every result lands, and RCU never slips after accepting an issue. Memory is the only variable-latency path, and it cancels.

> **Figure, as text** (drawn in the live doc): RS entry lifecycle · 4 states, 1 cancel loop
>
> *An RS entry lives until its sources are confirmed, not until issue.*
>
> - **Waiting**: matrix bits set at rename; up to 5 source producers; per-warp RS cap applies. → *woken* →
> - **Ready**: all producer bits clear; oldest first per class; rotating warp tie-break; memops: sources confirmed. → *selected* →
> - **Issued, speculative**: dependants woken at the producer's latency; entry stays allocated until sources confirm. → *confirmed* →
> - **Freed**: entry returns.
> - Cancel loop, Issued → Waiting: *cancel: a source missed its slot.* The cancel spreads to every dependant in the matrix.
An entry is freed only once every source is confirmed, so a cancelled instruction can reissue from where it sits. The highlighted cancel path is the only way back.

### Latency contract

- **Latencies are parameters, never hardcoded.** The scheduler must be functionally correct at any reasonable latency, provided it is configured with the right one.
- **Derived, not hand-set.** Wake latency = base pipeline + repeater stages from `params/links.json` (N\_out + N\_back over the outbound and return links, A-48), generated into `ccv_params_pkg`. A floorplan change cannot silently break scheduling.

  **Declared on the channels.** `ccv_ooe_rcu_issue`, `ccv_rcu_lane_ops`, `ccv_lane_rcu_res`, `ccv_rcu_ooe_done`, `ccv_miu_ooe_cmpl` and `ccv_miu_rcu_data` carry a fixed-latency attribute: the receiver never stalls and returns credit every cycle, checked per channel (A-47). So do ccv\_ooe\_fet\_redirect and ccv\_ooe\_fet\_ckpt\_free, a latency-matched pair (A-58, A-60). Without it, the ordinary credit convention would let RCU slip, or delay L1-hit data past the cycle its dependants read it.
- **Checked.** Each completion channel gets a checker asserting that the actual arrival cycle equals the scheduled one.
- **Working assumptions**, to be verified in the LANE, RCU and MIU sessions: 3 cycles for RCU-only ops; 7 cycles for lane ops, with a 4-cycle minimum bypass; 7 cycles for an L1 hit.
- **As applied** (custom-cuda-core `3543276`). The tunable bases are `CCV_LAT_RCU_BASE` = 3, `CCV_LAT_LANE_BASE` = 7 and `CCV_LAT_L1_HIT_BASE` = 7. gen-params derives the contracted values from them and refuses any value that disagrees:
  - `CCV_LAT_RCU` = base, since RCU crosses no link.
  - `CCV_LAT_LANE` = base + the repeater stages on `ccv_rcu_lane_ops` and `ccv_lane_rcu_res`, counted from RCU accepting the issue.
  - `CCV_LAT_L1_HIT` = base + the stages on `ccv_miu_dcu_req` and `ccv_dcu_miu_rsp`, counted from MIU accepting the memop.
  - `CCV_LAT_LANE_BYP` = 4, set directly.

  The reference points are confirmed (A-57). Two additions are still to apply. OOE scheduling uses two derived load times, generated so the scheduler never computes them:
  - `CCV_LAT_L1_WAKE` = start + `CCV_LAT_L1_HIT` + `ccv_miu_rcu_data` link − `ccv_ooe_rcu_issue` link. This is when hit data is readable by a dependant, and sets its wake.
  - `CCV_LAT_L1_CMPL` = start + `CCV_LAT_L1_HIT` + `ccv_miu_ooe_cmpl` link. This is when OOE learns hit or miss, and sets the cancel shadow.

  **Start point (A-61, applied 2026-10-03 in custom-cuda-core 0cf039a).** MIU cannot start a load until both the memop and RCU's address on `ccv_rcu_miu_addr` have arrived, and the address path is normally the later one. Counted from OOE's issue, start = max(memop link, issue link + `CCV_LAT_RCU_ADDR` + `ccv_rcu_miu_addr` link). `CCV_LAT_RCU_ADDR` is RCU's issue-to-address time over a new `CCV_LAT_RCU_ADDR_BASE`, and `CCV_LAT_L1_HIT` is measured from the cycle MIU holds both. The parameter grammar gains `max`, so the generator picks the binding path as the floorplan moves. When the address path binds, the issue link cancels out of WAKE.

  **As generated** (A-63). Every link in these formulas is a whole crossing, `CCV_LAT_HOP` + its repeater stages, where `CCV_LAT_HOP` = 2: the valid crosses in half the round trip, and the payload lands a cycle after its valid. Linear latencies such as `CCV_LAT_LANE` fold the fixed part into their base. A max over one crossing and two cannot, and counting stages alone would wake L1-hit dependants 4 cycles early. With no repeater stages, `CCV_LAT_L1_WAKE` = 13 and `CCV_LAT_L1_CMPL` = 15. `CCV_LAT_RCU_ADDR_BASE` = 2 is the accepted starting point (2026-10-03), tunable for the RCU session.

  `CCV_LAT_LANE_BYP` is lane-local (A-59): the 4-cycle base with no link terms, measured from issue to dependent issue, so the floorplan cannot change it. It applies only to op classes flagged bypassable; dependants of cross-lane ops use the full `CCV_LAT_LANE`. The channel attribute is checked now (V-45). The arrival-cycle checker above needs the issuing block's schedule and is built with it (repo Q-53).

### Register ports

The PRF is a flop array with enough ports for peak issue: 16 reads at issue (4 × 3 sources plus old destination) and 8 writes (4 lane results, 4 load returns). A masked load's copy-only op uses a lane write slot. Select checks neither read ports nor write-back slots. This closes Q-51: there is no port grant on `ccv_ooe_rcu_issue`, and a later SRAM PRF would be an interface change (A-28). The area consequence is flagged for the RCU session, along with +128 wires per lane instance on `ccv_rcu_lane_ops` for the carried merge value.

### Reservation stations

45 entries, unified, split by class: 30 RCU-bound and 15 MIU-bound, shared across warps with a per-warp occupancy cap. The cap stops a warp stalled on a miss from filling the RS before demotion fires.

The starting point of 30 came from about 5 cycles of wait at 4 exec plus 2 AGU instructions per cycle, then ×1.5 because entries are now held until confirmation. A knee-finding sweep sets the final number.

The sweep has a hard ceiling to be checked against: a paper estimate of how many entries, with up to 6 producers each and 4 timed wakes per cycle, fit in 25 NGD including select. If the knee lands above that ceiling, the fix is a clustered scheduler, not a bigger RS.

### Scheduling attributes

OOE never decodes `opcode`, whose encoding is preliminary and expected to churn. DEC delivers each uop's scheduling attributes already decoded, in a `sched_attr` field on `ccv_dec_ooe_uop` beside `uop_class` (A-66). About 13 bits, provisional: RS class (1), executes in lane or RCU (1), cross-lane (1), writes GPR (1), writes predicate (1), memory kind load/store/atomic/fence (2), branch (1), serialising none/`chwidth`/barrier/spare (2), and latency class (3). These drive RS class, the early or late column, merge and rename decisions, serialisation and wake timing. DEC owns the opcode-to-attribute table, fed by the LANE and RCU op-class list.

The encoding is confirmed as applied, MSB first: `rs_miu`, `exec_rcu`, `cross_lane`, `writes_gpr`, `writes_pred`, `mem_kind`\[2\], `branch`, `serial`\[2\], `lat_class`\[3\]. `mem_kind` is don't-care unless `rs_miu` is set. `lat_class` codes are 0 RCU, 1 lane, 2 L1-contracted load and 3 on completion. Each further fixed-latency lane unit, such as SFU, takes a spare code from 4 to 7 once the LANE session sets its latency, with its own generated wake parameter.

The memop's `mem_op`, `space` and `ordering` also come from DEC, on `ccv_dec_ooe_uop` (A-68). OOE copies them to `ccv_ooe_miu_memop` unexamined, so opcode decoding lives only in DEC. The one exception is `mem_op` 0xF, which OOE generates itself for bulk discard; DEC never emits it.

### Wakeup: dependency matrix

A 45 × 45 matrix of **two-bit cells** (A-62, A-73). Each cell holds a dependency bit and a **late** bit, both set at rename, for up to 6 producers per uop. Every producer broadcasts two wake signals, early and late. A cell is satisfied by its late wake if the late bit is set, otherwise by its early wake. An entry is ready when every cell in its row is satisfied, so wakeup is a 45-input AND with no tag compares.

- **Lane producers** raise the early wake at `CCV_LAT_LANE_BYP` and the late wake at `CCV_LAT_LANE`. Bypass is lane-local (A-59): producer and dependant execute at the same lane index, so the 4-cycle base needs no link terms.
- **Single-time producers** (RCU-only ops, loads) raise both wakes together.
- **Setting the late bit.** It is clear only if every use the dependant makes of that producer is bypass-eligible: a lane-executing op reading the value as a lane operand, from a non-cross-lane producer. Late cases are a consumer that executes in RCU (shuffle, vote, ballot, a branch on a lane `setp`); a value RCU sends to MIU as an address or store data; a lane-produced predicate used as guard or `pred_data`; and any dependant of a cross-lane producer.

Bypass eligibility belongs to the pair, not the producer, because one producer often has both kinds of dependant: an `add` feeding another `add` and a store address is ordinary loop address arithmetic. Two columns per producer (a 90-input AND) would have added a logic level to the binding path. A per-consumer hold would have delayed every predicate-guarded op by a fixed 3 cycles. The per-cell choice avoids both: it folds into the gate that already combines dependency and wake (an AOI22 in place of an OR), so the AND stays at 45 inputs. Storage is the same, about 4,000 flops; the cost is broadcasting two wake vectors.

A CAM would have needed 30 entries × 5 tags × 4 broadcasts, about 600 8-bit comparators for the RCU class alone, against a 25-NGD budget. The matrix also makes cancellation cheap: poison travels down the same columns.

### Select

Oldest first within each class, using age matrices (30 × 30 and 15 × 15). Age across warps has no global meaning, so warps are peers and a per-cycle rotating warp priority breaks ties. This is the arbitration policy for Q-4.

### Confirmation and transitive cancel

Every wake is speculative until the producer's result is confirmed. When a result misses its scheduled slot, OOE cancels that producer's dependants and everything woken behind them, transitively through the matrix. Cancelled entries return to Waiting.

**Miss detection (A-46).** The L1 outcome is the contract, and nothing beyond it. An L1 hit completes on `ccv_miu_ooe_cmpl` at exactly the contracted cycle, and its data lands on ccv\_miu\_rcu\_data at the contracted cycle too, since dependants woken at hit latency read it. No completion at that cycle is the miss indication, so a load still has exactly one completion. Past L1 (MLC and beyond) no latency is relied on: after a miss, dependants wake on the actual completion. Scratchpad loads, with variable bank-conflict latency, and atomics never wake speculatively. The mechanism is general, so any future variable-latency source can cancel the same way.

> **Figure, as text** (drawn in the live doc): Load-miss cancel · transitive poison through the dependency matrix
>
> *A miss poisons everything woken from the load, transitively.*
>
> 1. Load issues to MIU.
> 2. Wake dependants at L1-hit latency.
> 3. Dependants issue speculatively.
> 4. MIU cmpl: miss?
>    - *No* → sources confirmed, RS entries freed.
>    - *Yes* → poison the load's column.
> 5. **Poisoned entries poison their columns**, repeating until there is no new poison.
> 6. Entries stay in RS until the fill, then *reissue* (back to step 3).
Direct-only replay was rejected because it is not correct: a grandchild of an RCU-only dependant can issue before the miss reaches OOE, and would read poisoned data. Because RS entries are held until their sources confirm, every poisoned instruction is still in the RS and simply returns to Waiting.

An early hit/miss indication from MIU is therefore not needed for correctness. It would still shrink the cancel shadow, so it is worth raising in the MIU session as a performance item.

### Memory operations

A memop issues only once its address sources are confirmed. A poisoned address would start work MIU cannot recall (a TLB walk, an MLC miss, a fault on a garbage address), so there is no cancel path into MIU. The cost is a few cycles on dependent address chains, which GPU code rarely has.

The cost is measured by a counterfactual event: a memop was ready except for an unconfirmed address source, *and* an MIU slot of its class went unused that cycle. At retire, the event records whether those sources confirmed without a cancel. A histogram of hold cycles per memop shows where the cost concentrates.

## Retire, squash and recovery

Four per-warp ROBs of 32 entries retire in order, up to 2 per warp per cycle. Every recovery — mispredict, demotion, and fault via RAU's kill — is contiguous in ROB order.

### Branch prediction boundary

Prediction lives in FET, next to the PC and its update logic, and starts uniform-only. Divergent prediction comes later. OOE's part is verification: compare RCU's resolved taken mask against the prediction, which arrives as a 1-bit pred\_taken per slot from FET through DEC (A-42) and, on a mismatch, squash and redirect. OOE redirects only on a mispredict, so `ccv_ooe_fet_redirect` at rate 1 is a deliberate serialisation (A-6).

> **Figure, as text** (drawn in the live doc): Branch mispredict recovery · 1 decision, 5 effects
>
> *A mispredict squashes every younger entry, in ROB order.*
>
> - **Branch resolves**: RCU reports the taken mask. → *matches prediction?*
>   - *Yes* → **Continue**: no redirect.
>   - *No* → **Squash** every entry younger than the branch in that warp's ROB, with five effects:
>     - RAT and free lists: restore checkpoint, free regs.
>     - Reservation stations: remove younger entries.
>     - Outstanding memops: keep regs until MIU completes.
>     - FET (another block): restore checkpoint, apply mask.
>     - MIU (another block): bulk discard younger stores.
The two shaded effects are the only ones that leave OOE. FET owns the checkpoint, so OOE only names it.

### Why squash is contiguous

Stream-tagged squash was dropped. It would have had two problems:

- **Tag exhaustion.** Every split at a divergent branch mints new tags, a tag frees only when its last ROB entry retires, and a finite pool would have to stall fetch.
- **Lineage.** Squashing group A must also kill its split children and anything A merged into. A merged group has two parents, so the test becomes a graph query.

The implicit old-destination source makes it worse: every masked write reads the previous writer of that register, often from another PC group, so a partial squash would leave stale merge inputs behind. Over-squash in ROB order avoids all of it. Correct work from other PC groups is discarded and refetched; greedy min-PC switching keeps same-stream runs long, which limits that waste.

### Branch checkpoints

FET holds 4 checkpoints per warp, one per unresolved branch. Each captures every PC group's PC and lane mask at that branch. The branch uop carries its `checkpoint_id` from FET through DEC to OOE. On a mispredict, OOE sends the checkpoint ID, the true taken mask and the target PC; FET restores the checkpoint and applies the outcome. Running out of checkpoints stalls that warp's fetch and has its own event.

OOE restores its own RAT from the checkpoint with the same ID in the same cycle, so front-end and rename state recover together. Registers allocated by squashed entries return to the free lists, except those held for outstanding memops.

**Lane mask and fetch epoch arrive with the uop.** OOE learns a uop's PC-group mask from FET, through DEC, on `ccv_dec_ooe_uop` (A-69): it needs the mask at rename for merge elision and at issue for `issue_mask`, and FET knows it at fetch. Each uop also carries a 3-bit `fetch_epoch` (A-70). OOE keeps a current epoch per warp and advances it on every redirect, demotion and kill, then drops any arriving uop whose epoch does not match. That is how wrong-path uops still in the channels, in DEC or in the decode queue are discarded after a redirect. Three bits are needed because up to 4 out-of-order redirects plus a demotion or kill can land within one flight from FET to OOE. OOE owns the epoch (A-74): it tells FET of every change on ccv\_ooe\_fet\_redirect, with an epoch\_only bit for demotion and kill. Both sides keep it per warp\_id and never reset it at launch, and OOE acks a kill, or sends ccv\_ooe\_rau\_drained for a demotion, only once its notice has landed in FET, so neither a relaunch nor a restore can be fetched under the old epoch.

**Checkpoint release (A-56, repo Q-52), resolved 2026-10-02.** Found while applying the change set: OOE told FET about resolutions only on a mispredict, so a correctly predicted branch never freed its checkpoint in FET. Branches resolve out of order, so FET cannot infer frees from a count. OOE now sends `ccv_ooe_fet_ckpt_free`, a rate-1, fixed-latency channel carrying a 16-bit bitmap each cycle (`CCV_P_TIER1` × `CCV_P_BR_CKPTS`), with a bit set for every checkpoint freed by a correct resolution that cycle. One message frees any number of checkpoints across all warps, so nothing queues. A checkpoint is freed exactly once: by this channel, or by FET itself when a redirect restores an older checkpoint or a demotion or kill resets the warp. OOE frees its matching RAT checkpoint in the same cycle. A non-redirecting mode on the rate-1 redirect was rejected: every branch would queue there in bursts, delaying frees.

**No stale frees (A-58).** A free that lands after FET has reallocated its checkpoint would release the new owner's checkpoint. Three rules prevent it. OOE never sends a free for a checkpoint the same cycle's redirect squashes, and drops resolutions of squashed branches as it drops late completions. `ccv_ooe_fet_redirect` and `ccv_ooe_fet_ckpt_free` are a latency-matched pair, with equal link stages checked at elaboration, so arrival order equals send order, and FET applies a redirect before frees in the same cycle. An assertion checks that every free bit names a checkpoint live in FET on arrival.

**Applied** (custom-cuda-core `7e841d5`). The pair needed one tightening (A-60). Equal link stages fix the arrival order, but FET applies a message when it takes it, not when it lands. So `ccv_ooe_fet_redirect` is now fixed-latency as well, and FET never stalls it. The schema's `latency_match` refuses a pair unless both channels are fixed-latency. The S1 FET stub has no wrong path to fetch, so it stops after a branch it will mispredict; the redirect then frees only that branch's own checkpoint.

### Deferred free for outstanding memops

A load already at MIU can be squashed by an older mispredict. If its destination were freed at once, the late data on `ccv_miu_rcu_data` would clobber a reallocated register, and its completion could match a reused `rob_tag`. So a squashed entry with a memop outstanding keeps its destination registers and ROB slot until MIU completes it; the completion is then dropped. Squash recovery depends on memory latency only in that case, and every deferred free has an event. Squashed stores are dropped by one bulk discard (mem\_op 0xF) naming the circular range (branch, tail\] of ROB indices, since rob\_tag carries no age (A-41). The branch rides in rob\_tag and the tail in discard\_tail, a named overlay on displacement\[4:0\], which a discard never uses. MIU still completes every store it accepted, so deferred free and the outstanding-tag checker see one completion per tag.

### Faults

Faults are taken at retirement. When a faulting instruction reaches the head, OOE stops retiring that warp, raises `fault_taken` on `ccv_ooe_rau_status`, and writes the first-fault record to CRU. OOE does not squash; RAU's kill does all the cleanup, so there is one cleanup path and nothing can be freed twice.

Execute-stage faults stay gated by issue mask intersected with predicate, since masked-off lanes routinely compute addresses that must not fault. Dispatch-stage faults (F-WIDTH, F-FORMAT) are predicate-independent and read only the committed `chwidth`.

### Demotion

Demotion triggers are evaluated at the ROB head, because only a warp that cannot retire is worth demoting. Each has a threshold on top of its other inputs:

1. The head is a load with `mlc_miss` set and has been blocked for longer than the threshold.
2. The warp is waiting at a barrier. SYU already tracks non-resident warps.
3. The fallback timer fires on any head stall, for causes nobody anticipated.

On `ccv_rau_ooe_demote`, OOE squashes to retirement and waits for outstanding memops. It then sends the warp's architectural RAT map (16 GPR and 4 predicate physical names) directly to RCU and reports the resume PC on `ccv_ooe_rau_drained`. The registers are freed only after migration completes. Restore reverses this in two steps (A-64): on restore-allocate OOE allocates 16 GPRs and 4 predicates from the slot's reservation and sends the map to RCU so PCA's rows land in the right place; on restore-activate, after the transfer completes, the warp may issue.

### Kill

OOE acks a kill once it holds no state for the killed warps, which includes waiting for every outstanding memop of those warps.

### Warp activation

RAU tells OOE what is happening with a 2-bit `op` on `ccv_rau_ooe_alloc`, and which tier-1 slot the warp occupies with `tier1_id` (A-64, A-65). OOE keeps its own warp-to-slot table from that, which indexes the ROB, the `rob_tag` slot field, the per-slot reservations and the checkpoint-free bitmap.

- **Launch.** OOE maps all 16 architectural GPRs and 4 predicates to the **zero registers**. Each file has one, hardwired and outside the pool: index 0xFF for GPRs and 63 for predicates, derived as the all-ones index of a width sized clog2(pool + 1) so it stays outside the pool under any sweep (A-67). It always reads zero and is never written, allocated or freed. A first write renames to a fresh register as usual, and a masked first write merges from zeros. No zeroing traffic is sent, so the warp can issue at once.
- **Restore, in two steps.** *Restore-allocate*: OOE allocates 16 GPRs and 4 predicates from the slot's reservation, so it never waits, and sends `ccv_ooe_rcu_map` with `direction` 1 so PCA's rows land in the right place. *Restore-activate*, after `ccv_pca_rau_mig_done`: only now may the warp rename and issue. A single activation message would deadlock, since PCA's rows need the map and the map would need the activation.
- **Free.** The warp's state is released.

Stale data from another context can never become visible. A launched warp reads only zero registers until it writes; renamed registers merge from the old destination or are fully overwritten; and widening zero-fills.

Because isolation rests on the merge path and the zero registers, a bug there is a cross-context leak rather than a wrong answer (A-35). Assertions guard it: every lane of a newly allocated physical register is written before any read; a launched warp's RAT maps entirely to the zero registers; and no write, allocation or free ever names a zero register.

## Parameters

Every size is provisional for the first build, in `ccv_prov_pkg`, and gets a knee-finding sweep once the timing model is up. Latencies are assumptions until the LANE, RCU and MIU sessions confirm them.

| Parameter | Value | How it was set | Sweep |
| --- | --- | --- | --- |
| `CCV_P_ROB_DEPTH` | 32 per warp | Q-35; demotion catches a long-blocked head | yes |
| `CCV_P_PHYS_REGS` | 192, global pool | 64 arch + 128 rename, which matches 4 × 32 ROB entries | yes |
| GPR rename floor / ceiling | 16 / 64 per warp | half the fair share; ceiling + 3 × floor ≤ 128, asserted at elaboration (A-34, A-40) | yes |
| `CCV_P_PRED_REGS` | 48 | 16 arch + 32 rename (A-21) | via stall events |
| `CCV_P_W_PHYS_PRED` | 6 bits | follows from 48 | — |
| RS entries | 45: 30 RCU, 15 MIU | about 5 cycles × 6 per cycle, ×1.5 for confirmation hold | yes |
| Per-warp RS cap | to be set by sweep | stops one stalled warp filling the RS | yes |
| Decode queue | 12, shared, per-warp maximum | 2 cycles of full decode | yes |
| Branch checkpoints (in FET) | 4 per warp | fills the 2-bit ID | via stall events |
| Dependency matrix | 45 × 45 cells, 2 bits each (dependency and late) | follows from RS size | — |
| Age matrices | 30 × 30 and 15 × 15 | follows from RS split | — |
| RCU-only op latency | 3 cycles | assumption, RCU session | — |
| Lane op latency | 7 cycles, 4-cycle minimum bypass | assumption, LANE session | — |
| L1 hit latency | 7 cycles | assumption, MIU session | — |
| Demotion thresholds | CSR, one per trigger | to be set with RAU | yes |
| RAT checkpoints | 4 per warp, 152 bits each (608 per warp) | matches FET's 4 branch checkpoints, same ID | with branch checkpoints |
| Predicate rename floor / ceiling | 4 / 20 per warp | ceiling + 3 × floor ≤ 32, exact fit, asserted at elaboration (A-39, A-40) | yes |

**Names in the repository** (`params/ccv_params.json`, `3543276`):

- ROB index width: `CCV_P_W_ROB_IDX` = 5.
- RS: `CCV_P_RS_RCU` = 30 and `CCV_P_RS_MIU` = 15.
- Decode queue: `CCV_P_DECQ` = 12.
- Branch checkpoints: `CCV_P_BR_CKPTS` = 4, with `CCV_P_W_CKPT_ID` = 2. The ID width is provisional, because a derived width may not be more settled than its input.
- GPR rename: `CCV_P_REN_FLOOR` = 16, `CCV_P_REN_CEIL` = 64 and `CCV_P_REN_SLACK` = 16.
- Predicate rename: `CCV_P_PRED_REN_FLOOR` = 4, `CCV_P_PRED_REN_CEIL` = 20 and `CCV_P_PRED_REN_SLACK` = 0.

The floors and ceilings are derived from the pools and refused when they stop fitting. `CCV_P_PHYS_REGS` and `CCV_P_PRED_REGS` must each exceed the resident warps' architectural contents.

The ROB retire asymmetry (4 ROBs × 2 retires = 8 peak against 4-wide issue) is deliberate headroom for an uneven mix, and is a measurement item in the same sweep.

### Sweeps required once the timing model is up

- [ ] RS total, class split and per-warp cap: find the knee on GEMM, reduction and elementwise kernels, and check it against the 25-NGD scheduler ceiling
- [ ] ROB depth, PRF size, and rename floor and ceiling
- [ ] Predicate file size against compare-heavy kernels
- [ ] Decode queue depth and per-warp maximum
- [ ] Retire width: whether 2 per ROB is needed
- [ ] Unresolved branch limit against grid-stride loops

## Events

Every OOE structural stall has its own event, so an undersized structure shows up in early tests rather than as an unexplained slowdown. All are arbitration-sensitive under Q-1 except where noted.

| Event | Fires when | Tells you |
| --- | --- | --- |
| GPR free list empty | rename blocks on a GPR, per warp | pool or ceiling too small |
| Rename floor or ceiling hit | a warp is held at its limit | floor/ceiling tuning |
| Predicate free list empty | rename blocks on a predicate | 48 too small |
| ROB full | a warp's ROB has no entry, per warp | ROB depth |
| RS full | a class has no entry, per class | RS size or split |
| RS per-warp cap hit | a warp is held at its RS cap | cap tuning |
| Decode queue full | DEC is backpressured | queue depth |
| Decode queue per-warp max | a warp is held at its maximum | per-warp limit |
| `chwidth` serialisation | rename held behind a `chwidth` change | cost of serialisation |
| Barrier hold | rename held on a barrier wait | whether to relax the hold later |
| Branch checkpoint exhausted | fetch stalls with 4 branches in flight | checkpoint count (FET event) |
| Redirect busy | a mispredict waits for the rate-1 redirect | A-6 serialisation cost |
| Memop held, would have issued | ready memop held on an unconfirmed address and an MIU slot was free; records later confirmation | what speculative memops would buy |
| Memop hold cycles | per memop, as a histogram | where memop hold cost concentrates |
| Deferred free | a squashed entry keeps registers for an outstanding memop | cost of option (a) |
| Select grant | per slot per cycle | issue utilisation |
| Ready but not selected | per warp per cycle | starvation, select fairness |
| Cancel and replay | per cancelled entry, with depth | shadow size, replay cost |
| Demotion trigger | per trigger type | which trigger dominates |
| `EV_RETIRE` | an instruction retires | retire timing; the per-warp retirement sequence is checked separately against ccv-sim (Q-41) |
| Cross-group squash | a mispredict squashes entries belonging to other PC groups | cost of contiguous over-squash (A-31) |
| Masked-load copy op | a masked load takes an RCU issue slot for its copy | issue bandwidth cost of the masked-load copy op (A-33, A-38) |

## Decision log

Every question the session closed, with where the answer lives above. Q-numbers are the repository register; A-numbers are Arch opens; session numbers are the grill-me rounds.

| Item | Decision |
| --- | --- |
| Q1 — predict or resolve | Predict, high quality; uniform-only first, divergent later. Prediction lives in FET, not OOE |
| Q2 — inactive lanes under rename | Old destination is an implicit source; always rename |
| Q3 / A-21 — predicate file | 48 physical; every structural stall gets an event |
| Q4 — stream tags | Dropped; contiguous over-squash in ROB order |
| Q5 — when to elide | Elide the implicit source for full-mask unguarded ops; narrow `chwidth` writes need no merge |
| Q6 — RS organisation | Unified, split RCU/MIU, shared across warps, per-warp cap |
| RS size | 30, then ×1.5 = 45; knee sweep required |
| Q7, Q10 — latencies and replay | 3 / 7 (4 bypass) / 7 as assumptions; transitive cancellation |
| Q8 — checkpoints | In FET; 4 per warp |
| Q9, Q11 — rename pool | Global, with per-warp floor and ceiling; floor raised from 8 to 16 by A-34 |
| Q12 — RAU allocation | RAU allocates nothing; architectural registers are read through the RAT |
| Q13 — wakeup | Latency-based with correct, parameterised latencies |
| Q14 — replay storage | Hold in the RS until confirmation |
| Q15 — RAT map on migration | Goes directly from OOE to RCU |
| Q16 / Q-51 — ports | Fixed latency is a contract; OOE owns scheduling; PRF has ports for peak issue; no port grant |
| Q17 — latency parameters | Derived from base pipeline + repeater stages; arrival checker per completion channel |
| Q18 — demotion triggers | MLC-miss head, barrier wait, fallback timer; each with a threshold |
| Q19 / Q-1, Q-4 — select | Oldest first per class via age matrices, rotating warp tie-break |
| Q20 / Q-35 — sizing | ROB 32, PRF 192, floor 16 (was 8, A-34), ceiling 64; all provisional, sweeps pending |
| Q21 — `chwidth` drain | Warp-local serialisation at rename, committed at retire |
| Q22 — speculative memops | No; memops wait for confirmed address sources; counterfactual event |
| Q23 — squashed stores | Bulk discard as mem\_op 0xF on `ccv_ooe_miu_memop` |
| Q24 — decode queue | 12, shared, per-warp maximum |
| Q25 — redirect | Checkpoint-based payload, 107 bits |
| Q26 — identity shadow | Stays in OOE; substituted into the imm slot for srd ops (A-25) |
| Q27 — fault cleanup | OOE stops retiring; RAU's kill cleans up |
| Q28 / Q-41 — `EV_RETIRE` | Arbitration-sensitive; retirement sequence correlated against ccv-sim |
| Q29 — late load returns | Deferred free until MIU completes |
| Q30 — change tracking | Targeted change doc; the arch agent updates the high-level spec |
| Q31 — wakeup structure | Dependency matrix, not CAM |
| Q32 — barrier wait | Hold rename until release |
| A-6 — redirect rate | Rate 1 is deliberate; OOE redirects only on a mispredict |
| Replay scope (tab question) | Transitive, not direct-only |
| Demotion inputs (tab question) | Resolved by Q18 |
| RAT recovery on a mispredict | 4 RAT checkpoints per warp, indexed by the FET checkpoint ID; single-cycle restore; no ROB walk-back |
| A-28 — SRAM PRF path | Flop-array PRF; a later SRAM PRF would be an interface change reopening the OOE contract. No reserved grant field |
| A-33 — merge mechanism | Fourth source operand carried to the lane (supersedes copy-on-allocate, which could not bypass); masked loads get a copy-only op writing only inactive lanes, disjoint from the load data |
| A-34 — rename floor | 16 above architectural state, reserved per tier-1 slot; floor = half the fair share of the rename pool (A-40) |
| A-35 — context isolation | Every-lane-written assertion on new registers; a launched warp's RAT maps to the zero registers (A-64) |
| Restore admission | Credit withheld on ccv\_rau\_ooe\_alloc; architectural registers, floor and predicates reserved per tier-1 slot whether occupied or not, so admission is immediate |
| checkpoint\_id width | Per fetch slot, +2 bits per slot |
| A-38 — masked-load completions | One ROB entry, two RS entries; the copy sends no done; copy-pending bit cleared at its scheduled landing |
| A-39 — predicate floor | 4 per tier-1 slot, ceiling 20 per warp |
| A-40 — invariant slack | One floor rule for both pools; elaboration-time assertion for both; slack 16 for GPRs, 0 for predicates |
| A-41 — bulk discard age | Circular range (branch, tail\] in otherwise reserved fields, not a wider tag; every accepted memop gets one completion |
| A-42 — mispredict detection | 1-bit pred\_taken per slot from FET through DEC |
| A-43 — predicate merge | RCU read-modify-writes the predicate row at write-back; up to 6 producers per entry; masked cas copy covers the predicate |
| A-44, A-51 — lane writes | Per-lane write enables in RCU; separate merge\_data field |
| A-45 — migration pairing | RCU pairs the RAU command and the RAT map by warp and direction |
| A-46, A-47 — latency contracts | The L1 hit-or-miss outcome is contracted, nothing beyond it; fixed latency is a declared channel attribute |
| A-48 — latency formula | base + N\_out + N\_back |
| A-49 — restore admission | Never waits; credit withholding dropped |
| A-53 — bulk discard completion | A discard is a command, not a memop, and gets no completion; tail is the youngest allocated entry, inclusive |
| A-54 — early hit/miss | Removed; absence of a hit completion is the miss signal |
| A-55 — predicate-file ports | Counted; RCU sizes issue reads from the ISA, since an op can need a guard and a predicate source |
| A-56 — checkpoint release | New rate-1 ccv\_ooe\_fet\_ckpt\_free bitmap; V-08 to P1 |
| A-57 — latency reference points | Confirmed; add generated CCV\_LAT\_L1\_WAKE and CCV\_LAT\_L1\_CMPL; CCV\_LAT\_LANE\_BYP reference point to LANE and RCU |
| A-58 — redirect and free ordering | No frees for squashed checkpoints; latency-matched channel pair; redirect applied first; every free names a live checkpoint |
| A-59 — bypass locality | Lane-local; CCV\_LAT\_LANE\_BYP is the 4-cycle base with no link terms; bypassable flag per op class, cross-lane ops wake at full CCV\_LAT\_LANE |
| A-60 — redirect fixed-latency | Confirmed: FET applies the redirect the cycle it lands, so frees apply in send order |
| A-61 — L1 wake start point | Start is the later of the memop and RCU's address; new CCV\_LAT\_RCU\_ADDR; max in the parameter grammar |
| A-62 — bypass eligibility | Per producer–consumer pair; two-bit cells (dependency and late) in a 45 × 45 matrix, per A-73 |
| A-63 — counting crossings | Each crossing counted whole, CCV\_LAT\_HOP + link\_n; WAKE 13, CMPL 15 at no repeaters |
| A-64 — launch and restore | 2-bit op (free, launch, restore-allocate, restore-activate); launch maps to hardwired zero registers instead of zeroing |
| A-65 — tier-1 slot | RAU sends tier1\_id to OOE and FET |
| A-66 — scheduling attributes | New sched\_attr field from DEC; OOE never decodes opcode |
| A-67 — zero-register indices | Widths sized clog2(pool + 1); zero index is the all-ones index, checked outside the pool at elaboration |
| A-68 — memop fields | DEC delivers mem\_op, space and ordering; OOE passes them through; 0xF reserved for OOE |
| sched\_attr encoding | Confirmed as applied; mem\_kind don't-care off MIU; spare lat\_class codes for further fixed-latency lane units |
| A-69 — lane mask | Group mask from FET with each uop; per message if bundles are single-group |
| A-70 — wrong-path uops | fetch\_epoch with each uop, 3 bits; advanced on redirect, demotion and kill |
| Prefetch | mem\_kind load, writes\_gpr 0 |
| A-71 — unaligned lane access | Deferred to the ISA track; OOE neutral |
| A-72 — mask variant | Dropped; per-slot masks stand |
| A-73 — matrix logic level | Two-bit cells (dependency and late) replace two columns; ready AND stays at 45 inputs. Zero-register reads use no PRF port |
| A-74 — epoch ownership | OOE owns it; epoch\_only notices on the redirect channel; per warp\_id, never reset; kill acked only after the notice lands |

## Verification

OOE never touches operand data. Every property below is about bookkeeping (tags, masks, matrices, free lists, counters), so the whole block can be proven formally with data abstracted away. Each property has an ID for traceability into SVA, a kind and a priority.

- **Kinds.** *Invariant*: holds every cycle. *Bounded*: must happen within N cycles, which is tractable where true liveness is not. *Elaboration*: a static check on parameters. *Assume/guarantee*: an assumption in the OOE proof that is asserted in the peer block.
- **Priorities.** P1 must be proven before the first integrated run. P2 is proven before tape-in, or covered by simulation until then.

**Status in the repository** (`3543276`). Most properties are about OOE's internals and wait for its RTL. The ones that live at the interface or in the parameters are already checked:

- **V-45:** the credit checker's `fixed_latency_no_stall` and `fixed_latency_prompt` run on all 274 fixed-latency slots, and a control (`--break fixed-all`) fires on every one.
- **V-31 and V-33:** hold by derivation in gen-params, which refuses a hand-set value that disagrees. **V-34** does not apply, because the repository has no RS-total parameter, only the two class sizes.
- **V-41:** the OOE stub implements this rule. The kernel runs, compared with ccv-sim, exercise it, along with a corrupted-checkpoint control that must fail. That is a test, not a proof.
- **V-46 and V-47:**
  - V-46 is asserted in the C++ FET stub, which refuses a free for a checkpoint that is not live, and `--break stale-free` is its control. FET's RTL still owes the assertion.
  - V-47 is the links checker's latency-match rule (schema key `latency_match`), with a refusal case in `check-links.sh`.
- **Built with their blocks (repo Q-53):** V-35 and V-44 (arrival-cycle checkers), V-22 and V-43 (the outstanding-tag checker), V-29 and the A-35 every-lane-written assertion, and V-42 (pairing).
- **Not reached by the S1 kernels:** the masked-load copy op is not modelled, and the GPR merge path is built but unreached. A kernel that reaches them is S2 work.

V-08 is now P1. With `ccv_ooe_fet_ckpt_free` (A-56) it is the one place FET and OOE hold mirrored state, so a mismatch there is a recovery bug, not a performance one.

### Register conservation

| ID | Property | Kind | Priority |
| --- | --- | --- | --- |
| V-01 | The free list, committed RAT, previous mappings held by in-flight ROB entries and deferred-free holds partition all 192 physical GPRs exactly. Catches leaks, double allocation, and any squash or demotion path that drops a register | Invariant | P1 |
| V-02 | Same partition for the 48 physical predicates | Invariant | P1 |
| V-03 | No physical register is allocated while any RAT, RAT checkpoint, RS entry or in-flight op still refers to it | Invariant | P1 |
| V-04 | Each slot stays at or under its ceiling, and free registers always cover every other slot's unmet floor, for both pools (A-34, A-39) | Invariant | P1 |
| V-05 | `merge_en` = 0 implies a full issue mask and no guard predicate | Invariant | P1 |

### Rename recovery

| ID | Property | Kind | Priority |
| --- | --- | --- | --- |
| V-06 | A RAT restored from a checkpoint equals the RAT as it was when that branch renamed. Proven against a reference ROB walk-back, which is cheap to model and obviously correct | Invariant (refinement) | P1 |
| V-07 | At most 4 unresolved branches per warp; `checkpoint_id` unique among them; each freed exactly once, on resolve or squash | Invariant | P1 |
| V-08 | OOE's set of live checkpoint IDs per warp equals FET's, with frees arriving on `ccv_ooe_fet_ckpt_free` and each checkpoint freed exactly once (A-56). Needs a small joint OOE + FET harness | Invariant (cross-block) | P1 |
| V-09 | No younger uop of a warp renames past an in-flight `chwidth` change or a held barrier wait | Invariant | P1 |
| V-46 | Every bit set on ccv\_ooe\_fet\_ckpt\_free names a checkpoint live in FET on arrival; OOE never frees a checkpoint squashed by the same cycle's redirect (A-58) | Invariant (cross-block) | P1 |
| V-56 | One redirect-channel latency after every change, FET's fetch epoch for a warp equals OOE's (A-74) | Invariant (cross-block) | P1 |
| V-57 | OOE acks a kill, and reports a demotion drained, only after its epoch notice has landed in FET, so no relaunched or restored warp is fetched under an epoch older than OOE's (A-74) | Invariant (cross-block) | P1 |

### Scheduling

| ID | Property | Kind | Priority |
| --- | --- | --- | --- |
| V-10 | A dependency bit is set only for an older producer in the same warp, never for the entry itself. The matrix is therefore acyclic, which rules out scheduler deadlock | Invariant | P1 |
| V-11 | An entry is selected only if its matrix row is empty | Invariant | P1 |
| V-12 | No issue slot is granted twice in a cycle; per-class issue never exceeds 4 | Invariant | P1 |
| V-13 | Each age matrix is antisymmetric and transitive, so it is a total order, and the oldest ready entry in each class is the one selected | Invariant | P2 |
| V-14 | The per-warp RS cap holds | Invariant | P1 |
| V-15 | After a cancel settles, no issued-but-unconfirmed entry has a poisoned producer. Transitive cancel is the easiest place to miss a hop | Invariant | P1 |
| V-16 | An RS entry is freed only once every source is confirmed | Invariant | P1 |
| V-17 | A memop issues only when its address sources are confirmed | Invariant | P1 |
| V-18 | A ready entry is selected within a bound set by the rotating warp priority | Bounded | P2 |
| V-38 | An entry's producers include the old predicate destination whenever the op merges a predicate; at most 6 producers per entry (A-43) | Invariant | P1 |
| V-39 | Past L1, no dependant wakes before the producer's actual completion; scratchpad loads and atomics never wake speculatively (A-46) | Invariant | P1 |
| V-48 | A cell's late bit is clear only if every use it makes of that producer is bypass-eligible: a lane-executing op reading the value as a lane operand, from a non-cross-lane producer (A-62) | Invariant | P1 |

### ROB, retire and squash

| ID | Property | Kind | Priority |
| --- | --- | --- | --- |
| V-19 | Retire is in order per warp, of completed entries only, at most 2 per warp per cycle | Invariant | P1 |
| V-20 | A masked load's ROB entry completes only when the load has completed and its copy-pending bit is clear; exactly one copy op exists per masked load (A-38) | Invariant | P1 |
| V-21 | After a squash, nothing younger than the branch remains in that warp, and no other warp's state changed | Invariant | P1 |
| V-22 | A squashed entry with a memop outstanding keeps its registers and `rob_tag` until MIU completes it; that tag is never reallocated while outstanding | Invariant | P1 |
| V-23 | Commit messages go only for retired stores; bulk discard never covers a retired store; bulk discard is never in the same cycle as a new memop for that warp | Invariant | P1 |
| V-24 | After `fault_taken`, nothing more retires for that warp until its kill | Invariant | P1 |
| V-25 | Each resident warp's oldest instruction retires or the warp is demoted within a bound set by the demotion thresholds | Bounded | P2 |
| V-40 | A bulk discard names exactly the warp's stores in the circular range (branch, tail\], with the tail in discard\_tail; every other field of the message is zero (A-41) | Invariant | P1 |
| V-41 | A redirect is raised exactly when a resolved branch disagrees with its pred\_taken (A-42) | Invariant | P1 |
| V-53 | No uop whose fetch\_epoch differs from its warp's current epoch is renamed; the epoch advances on every redirect, demotion and kill (A-70) | Invariant | P1 |
| V-54 | Every issued uop's issue\_mask equals the group mask it arrived with on ccv\_dec\_ooe\_uop (A-69) | Invariant | P1 |

### Demotion, kill and activation

| ID | Property | Kind | Priority |
| --- | --- | --- | --- |
| V-26 | `drained` fires only with an empty ROB, no outstanding memops, and the RAT map already sent to RCU | Invariant | P1 |
| V-27 | A demoted warp's registers are freed only after migration completes | Invariant | P1 |
| V-28 | A kill ack implies OOE holds no state for that warp | Invariant | P1 |
| V-29 | A launched warp's RAT maps all 16 GPRs and 4 predicates to the zero registers, and no write, allocation or free ever names a zero register (A-35, A-64) | Invariant | P1 |
| V-30 | Restore admission never waits: whenever RAU activates or restores a warp, its reserved registers are free and no credit is withheld on `ccv_rau_ooe_alloc` (A-49) | Invariant | P1 |
| V-42 | A migration proceeds only once ccv\_rau\_rcu\_mig and ccv\_ooe\_rcu\_map for the same warp and direction have both arrived; at most one per warp in flight (A-45) | Invariant (RCU) | P1 |
| V-49 | A warp renames and issues only after a launch, or after a restore-activate that follows its restore-allocate; no map with direction 1 is sent except on restore-allocate (A-64) | Invariant | P1 |
| V-50 | OOE's warp-to-slot table matches the tier1\_id RAU sent for every resident warp, and FET's matches the same (A-65) | Invariant (cross-block) | P1 |

### Elaboration-time checks

| ID | Property | Kind | Priority |
| --- | --- | --- | --- |
| V-31 | ceiling + 3 × floor ≤ pool, for both GPRs and predicates (A-40) | Elaboration | P1 |
| V-32 | `CCV_P_PHYS_REGS` = architectural + rename registers | Elaboration | P1 |
| V-33 | The checkpoint-ID width is log2 of the checkpoint count | Elaboration | P1 |
| V-34 | The RS class sizes sum to the RS total | Elaboration | P1 |
| V-47 | ccv\_ooe\_fet\_redirect and ccv\_ooe\_fet\_ckpt\_free have equal link stages (A-58) | Elaboration | P1 |
| V-51 | CCV\_P\_PHYS\_ZERO and CCV\_P\_PRED\_ZERO lie outside their pools; each index width is clog2(pool + 1) (A-67) | Elaboration | P1 |
| V-55 | 2^CCV\_P\_W\_FETCH\_EPOCH exceeds CCV\_P\_BR\_CKPTS + 1, so the epoch cannot wrap within one flight (A-70) | Elaboration | P1 |

### Boundary assumptions

| ID | Property | Kind | Priority |
| --- | --- | --- | --- |
| V-35 | Fixed-latency contract: assumed for RCU and LANE results in the OOE proof, asserted by the arrival checker on each completion channel | Assume/guarantee | P1 |
| V-36 | Every channel checker rule (valid, credit, stall, reserved-zero) is an assumption on OOE's inputs and an assertion on its outputs | Assume/guarantee | P1 |
| V-37 | MIU completes every memop it accepts, even after OOE squashes it | Assume/guarantee | P1 |
| V-43 | Every memop MIU accepts gets exactly one completion, including stores later bulk-discarded (A-41) | Assume/guarantee | P1 |
| V-44 | An L1 hit's completion and its data on ccv\_miu\_rcu\_data both arrive at exactly the contracted cycle; any other completion is a miss (A-46) | Assume/guarantee | P1 |
| V-45 | Fixed-latency channels never stall and return credit every cycle (A-47) | Assume/guarantee | P1 |
| V-52 | DEC never emits mem\_op 0xF, which is reserved for OOE's bulk discard (A-41, A-68) | Assume/guarantee | P1 |

### Making the proofs tractable

- **Prove on a reduced configuration.** Everything is parameterised, so the same RTL can be proven at 2 warps, ROB 4, RS 6 and a minimal PRF. Most bugs in this kind of logic show up at tiny sizes.
- **Track one index symbolically.** For V-01, V-02, V-03 and V-22, pick one arbitrary register index or `rob_tag` and prove the property for it alone. That is much cheaper than whole-set invariants and just as strong.
- **Keep internal state visible.** Expose the free-list bit vectors, matrices and checkpoint valid bits through bind modules, so properties need no hierarchical references.
- **Keep counters small in formal.** Demotion thresholds and the fallback timer must be parameters that formal can set low; otherwise the bound in V-25 explodes.
- **Abstract the data.** Operand and payload data fields are free inputs. None of the properties above depends on them.

## Still open and handed off

One OOE item is open: the scheduler's timing ceiling, which must cover the two wake vectors and the per-cell select (A-62, A-73). Checkpoint release (A-56, A-58, A-60) is applied. The L1 wake start point (A-61) is applied, and so is the two-column matrix (A-62), which is OOE-internal and owed by the RTL as V-48. Everything else is a size awaiting a sweep, or sits with another owner.

| Item | Owner | What is needed |
| --- | --- | --- |
| Identity shadow (`warp_base`, `%ctaid`, 37 bits per warp) | Arch agent | Resolved (A-25): stays in OOE; substituted into the imm slot for srd ops |
| Knee-finding sweeps | Timing model | RS size and split, per-warp RS cap, ROB depth, PRF, rename floor and ceiling, decode queue, retire asymmetry |
| Latency assumptions | LANE, RCU, MIU sessions | Confirm 3 / 7 (4 bypass) / 7 cycles |
| PRF port area | RCU session | A 192-entry flop array with ports for peak issue: 16 reads × 1024 bits at issue and 8 writes; merge value carried to the lanes (A-27, A-33) |
| Divergent branch prediction | FET session | Uniform-only first; recovery already handles divergence as a mispredict |
| Demotion threshold values | RAU session | One CSR per trigger |
| Deferred barrier relaxation | Later | Let younger non-memory ops pass a barrier wait, if the barrier-hold event shows it is worth it |
| Interface changes | Arch agent | Applied in custom-cuda-core `3543276` (2026-10-02), and the per-block specs follow it. Deviations are listed at the top of the Changes tab in *Interface spec changes — OOE session* |
| Scheduler timing ceiling | OOE | Paper estimate of RS entries × up to 6 producers × 4 timed wakes, plus select, in 25 NGD; the hard cap for the RS sweep |
| Early hit/miss indication | MIU session | Optional: not needed for correctness, but shrinks the cancel shadow |
| Checkpoint release on a correct prediction (A-56, repo Q-52) | Coding agent, FET session | Applied in custom-cuda-core `7e841d5`: the new `ccv_ooe_fet_ckpt_free` channel, and the redirect made fixed-latency (A-60). FET implements it and owes the joint V-08 harness. |
| Latency reference points (A-57) | Coding agent; LANE and RCU sessions | Confirmed. `CCV_LAT_LANE_BYP` is applied as lane-local. `CCV_LAT_L1_WAKE` and `CCV_LAT_L1_CMPL` are generated from the A-61 start point in 0cf039a, each link counted as a whole crossing (A-63) |
| Deferred checkers (repo Q-53) | LANE, RCU, MIU sessions | Arrival-cycle checkers, outstanding-tag checker, A-35 assertions and migration pairing, each built with the block whose internals it needs |
| L1 wake start point (A-61, repo Q-54) | Coding agent; RCU session | Resolved 2026-10-02: start = max(memop link, issue link + `CCV_LAT_RCU_ADDR` + address link), with `CCV_LAT_RCU_ADDR_BASE` and `max` in the grammar. Applied in 0cf039a; the base starts at 2 (accepted 2026-10-03), and the RCU session confirms or moves it |
| Bypass eligibility (A-62, repo Q-55) | Coding agent; LANE and RCU sessions | Resolved 2026-10-02: eligibility decided per pair at rename (V-48), stored as a late bit per cell (A-73). Nothing to apply in the schema or the S1 stub, which wakes on completion. The OOE RTL builds it (V-48), and the LANE and RCU sessions list the op classes |
| Launch, restore and slot (A-64, A-65) | Coding agent; RAU and PCA sessions | Applied in custom-cuda-core 1077054: the 2-bit op and tier1\_id on ccv\_rau\_ooe\_alloc, tier1\_id on ccv\_rau\_fet\_launch and ccv\_rau\_fet\_mig, and the zero registers (CCV\_P\_PHYS\_ZERO = 255, CCV\_P\_PRED\_ZERO = 63, kept outside the pool by derivation, A-67). PCA's restore command (repo Q-39) completes the sequence |
| Scheduling attributes (A-66) | DEC session; LANE and RCU sessions | Applied in 1077054: sched\_attr (13 bits) on ccv\_dec\_ooe\_uop, its bit order and codes for confirmation. DEC also delivers the memop's mem\_op, space and ordering, which OOE passes through (A-68, applied in 95eb4f7). DEC owns the opcode-to-attribute table; mem\_op, space and ordering are settled in the same pass |
| Lane mask and epoch (A-69, A-70) | Coding agent; FET and DEC sessions | Applied in 98c0e63, per slot; the per-message variant was dropped (A-72). Epoch ownership (A-74): applied in 47c27dd (epoch\_only on ccv\_ooe\_fet\_redirect, kill\_ack waits for the notice to land) |
| Unaligned lane access (A-71) | ISA track | Legal or fault; OOE neutral either way |
