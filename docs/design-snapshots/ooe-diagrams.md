# OOE microarchitecture: the diagrams, as text

The OOE doc's four diagrams are drawn components, which a markdown export
leaves as a one-line placeholder. `tools/snapshot-doc.py` puts each one back
as text, matched by its caption: the title, then every box and arrow as the
diagram draws them. Re-transcribe one only when that diagram changes in the
live doc.

## OOE internal structures and channels · 4 stages, 7 peers

*OOE owns rename, scheduling and recovery; peers only execute.* Shaded boxes are other blocks; arrows are channels.

- **Decode queue**: 12 entries shared across warps, per-warp maximum. ← DEC, uop ×6. → Rename, 4 per cycle.
- **Rename**:
  - GPR RAT ×4: 16 arch + 4 checkpoints.
  - Predicate RAT ×4: 4 arch + 4 checkpoints.
  - GPR free list · 192: floor 16, cap 64 per warp.
  - Pred free list · 48: floor 4, cap 20 per warp.
  - Masked or guarded writes add the old destination as a source.
  - A chwidth change or barrier wait holds that warp's rename.
  - → SYU: bar. ← SYU: release. → Reservation stations: dispatch.
- **Reservation stations · 45**:
  - RCU class · 30: issues up to 4 per cycle; held until sources confirm.
  - MIU class · 15: issues after address sources are confirmed.
  - Wakeup: 45 × 45 two-bit cells, early or late wake.
  - Select: oldest first per class, rotating warp tie-break.
  - Cancel spreads transitively through the matrix.
  - → RCU: issue ×4. ← RCU: done. → MIU: memop ×4. ← MIU: cmpl, miss. → ROBs: done, cancel.
- **ROB ×4 · 32 entries each**:
  - Allocated at rename; retires up to 2 per warp per cycle.
  - Squash kills everything younger, in ROB order.
  - Branch uops carry a FET checkpoint ID, 4 per warp.
  - Squashed memops keep their registers until MIU completes.
  - Fault: stop retiring, report, and let RAU's kill clean up.
  - Demote: squash to retirement, then send the RAT map to RCU.
  - Drained waits for every outstanding memop.
  - Commits stores to MIU at retire, bulk discard on squash.
  - → MIU: retire. → FET: redirect. → RAU: status. ← RAU: demote. → CRU: fault.
- Peers:
  - DEC: 6 uops per cycle.
  - SYU: barrier table.
  - RCU: fixed-latency contract; gets RAT map on demote.
  - MIU: variable latency, cancels; stores leave at retire.
  - FET: PC groups, 4 checkpoints.
  - RAU: demotion policy, kill.
  - CRU: first fault record.

## RS entry lifecycle · 4 states, 1 cancel loop

*An RS entry lives until its sources are confirmed, not until issue.*

- **Waiting**: matrix bits set at rename; up to 5 source producers; per-warp RS cap applies. → *woken* →
- **Ready**: all producer bits clear; oldest first per class; rotating warp tie-break; memops: sources confirmed. → *selected* →
- **Issued, speculative**: dependants woken at the producer's latency; entry stays allocated until sources confirm. → *confirmed* →
- **Freed**: entry returns.
- Cancel loop, Issued → Waiting: *cancel: a source missed its slot.* The cancel spreads to every dependant in the matrix.

## Load-miss cancel · transitive poison through the dependency matrix

*A miss poisons everything woken from the load, transitively.*

1. Load issues to MIU.
2. Wake dependants at L1-hit latency.
3. Dependants issue speculatively.
4. MIU cmpl: miss?
   - *No* → sources confirmed, RS entries freed.
   - *Yes* → poison the load's column.
5. **Poisoned entries poison their columns**, repeating until there is no new poison.
6. Entries stay in RS until the fill, then *reissue* (back to step 3).

## Branch mispredict recovery · 1 decision, 5 effects

*A mispredict squashes every younger entry, in ROB order.*

- **Branch resolves**: RCU reports the taken mask. → *matches prediction?*
  - *Yes* → **Continue**: no redirect.
  - *No* → **Squash** every entry younger than the branch in that warp's ROB, with five effects:
    - RAT and free lists: restore checkpoint, free regs.
    - Reservation stations: remove younger entries.
    - Outstanding memops: keep regs until MIU completes.
    - FET (another block): restore checkpoint, apply mask.
    - MIU (another block): bulk discard younger stores.
